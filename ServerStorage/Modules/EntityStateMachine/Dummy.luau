local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Animations = ReplicatedStorage.Assets.Animations
local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations

local HitDetection = require(ServerStorage.Modules.Utility.HitDetection)
local CombatManager = require(ServerStorage.Modules.Managers.CombatManager)
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local WeaponData = require(ServerStorage.Modules.Utility.WeaponData)
local KnockbackModule = require(ServerStorage.Modules.Utility.Knockback)
local Ragdoll = require(ServerStorage.Modules.Utility.Ragdoll)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local SkillModule = require(ServerStorage.Modules.SkillModules.Skills.ServerSkills)
local CriticalModule = require(ServerStorage.Modules.SkillModules.Shikais.ShikaiCriticals)
local ClashSystem = require(ReplicatedStorage.Modules.Shared.ClashSystem)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local RankManager = require(ServerStorage.Modules.Managers.RankManager)
local ShikaiWeapons = require(ServerStorage.Modules.SkillModules.Shikais.ShikaiWeapons)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local DamageTracker = require(ServerStorage.Modules.Utility.DamageTracker)

local NPCManager = require(ServerStorage.Modules.Managers.NPCManager)
local SkillData = require(ServerStorage.Modules.Utility.SkillData)

local HitEffectClient = ReplicatedStorage.Modules.ClientModules.ClientHitEffects
local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientSkills
local FlashstepClient = ReplicatedStorage.Modules.ClientModules.FlashstepClient

local Sounds = ReplicatedStorage.Assets.Sounds

local EntityData = {}

local function TrackDamage(Character, AttackOwner, Damage)
	local EntityID = Character:GetAttribute("EntityID")
	local Player = Players:GetPlayerFromCharacter(AttackOwner)
	if Player then
		local Profile = DataManager:RequestProfile(Player)
		if Profile.ClientData.Race ~= "Hollow" then
			DamageTracker:Track(Character, AttackOwner, Damage)
		end
	end

	if Character:GetAttribute("DelayedDeath") then
		if AttackOwner.Name == Character:GetAttribute("DelayedDeathOwner") then
			local DelayedDeathDamage = Character:GetAttribute("DelayedDeath")
			DelayedDeathDamage += Damage
			Character:SetAttribute("DelayedDeath", DelayedDeathDamage)
		end
	end
end

local function DamageTaken(Character, AttackData, AttackOwner, HitType)
	local Damage = AttackData.Damage
	Damage = PassivesManager:ApplyActivePassives(Character, AttackData, AttackOwner, HitType, EntityData[Character.Name].ClientData, EntityData[Character.Name])
	if (Character.Humanoid.Health - Damage) <= 1 then	
		Damage = 0
		EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
	end
	
	local CurrentHealth = Character.Humanoid.Health
	
	Character.Humanoid:TakeDamage(Damage)
	TrackDamage(Character, AttackOwner, Damage)
	
	local DamageIndicator = math.floor((CurrentHealth - Character.Humanoid.Health) * 100) / 100
	local IndicatorPath = {Module = HitEffectClient, Skill = "DamageIndicator"}
	local RenderDistance = 1000
	NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, IndicatorPath, DamageIndicator)
	
	if Character:GetAttribute("CurrentState") ~= "Unconscious" and AttackOwner:GetAttribute("EntityType") ~= "Menos" then
		if Character:GetAttribute("DelayedDeath") then
			if AttackOwner.Name == Character:GetAttribute("DelayedDeathOwner") then
				local DelayedDeathDamage = Character:GetAttribute("DelayedDeath")
				DelayedDeathDamage += Damage
				Character:SetAttribute("DelayedDeath", DelayedDeathDamage)
			end
		end
	end
	
	if not AttackData.NoHitEffect then
		if AttackData.ImpactSound then
			if AttackData.ImpactSound ~= "None" then
				local ImpactSound = AttackData.ImpactSound:Clone()
				ImpactSound.PlayOnRemove = true
				ImpactSound.Parent = Character.HumanoidRootPart
				ImpactSound:Destroy()
				ImpactSound = nil
			end
		else
			local ImpactSound = ReplicatedStorage.Assets.Sounds["ImpactSound" .. math.random(1, 2)]:Clone()
			ImpactSound.PlayOnRemove = true
			ImpactSound.Parent = Character.HumanoidRootPart
			ImpactSound:Destroy()
			ImpactSound = nil
		end

		local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
		local RenderDistance = 1000
		NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, AttackData.HitEffect, AttackOwner)
	end
end

local function PerfectFlashstep(Character, AttackOwner, FlashstepCFrame, AttackData)
	local Race = EntityData[Character.Name].Race

	local PathData = {Module = FlashstepClient, Skill = "Evaded"}
	local RenderDistance = 1000
	NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Race)
	
	local DisabledEnhancedSteps
	if AttackData and AttackData.DisabledEnhancedSteps then
		DisabledEnhancedSteps = true
	end

	if not DisabledEnhancedSteps then
		if Character:GetAttribute("EnhancedSteps") and AttackOwner then
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			Character.HumanoidRootPart.CFrame = AttackOwner.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 0, 3.2))
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Race)
		end
	end
end

local function CounterSuccess(Character, StateMachine, AttackOwner, AttackData)
	local CounterType = Character:GetAttribute("CounterType")
	local SkillCounter = SkillModule[CounterType]
	local ShikaiModule = EntityData[Character.Name].ShikaiModule
	
	local AversionField
	local CurrentTags = CollectionService:GetTags(Character)
	if CurrentTags and #CurrentTags > 0 then
		for _, Tag in ipairs(CurrentTags) do
			if Tag:match("AversionField") then
				AversionField = true
				break
			end
		end
	end

	if AversionField then
		SkillModule["Aversion Field"].CounterSuccess(Character, StateMachine, AttackOwner, EntityData[Character.Name], AttackData)
		return
	end
	
	local CounterFunction
	if SkillCounter and SkillCounter.CounterSuccess then
		CounterFunction = SkillModule[CounterType].CounterSuccess
	elseif ShikaiModule and ShikaiModule["CounterSuccess"] then
		local ShikaiCounter = ShikaiModule["CounterSuccess"]
		if Character:GetAttribute("ZanpakutoState") >= 2 and ShikaiCounter.BankaiCounter then
			CounterFunction = ShikaiCounter.BankaiCounter(Character, StateMachine, AttackOwner, EntityData[Character.Name], AttackData)
		else
			CounterFunction = ShikaiCounter.ShikaiCounter(Character, StateMachine, AttackOwner, EntityData[Character.Name], AttackData)
		end
	end

	if CounterFunction then
		Character:SetAttribute("CounterFrames", false)
		Character:SetAttribute("CounterType", "string")
		CounterFunction(Character, StateMachine, AttackOwner, EntityData[Character.Name], AttackData)
	end
end

local DummyData = {
	Idle = {
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("Idle")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerSprint = function(StateMachine, Character)
			StateMachine:PushState("Idle")
			StateMachine:SetState("Sprinting")
			StateMachine:Trigger("Sprint", StateMachine, Character)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			StateMachine:PushState("Idle")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,	
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			ReiatsuValue -= 5 -- Subtracts the cost of the skill from the players current reiatsu
			if TimeDifference >= Character:GetAttribute("FlashstepCooldown") and ReiatsuValue >= 0 then
				StateMachine:PushState("Idle")
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			end
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:PushState("Idle")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			EntityData[Character.Name].ClientData = ClientData
			--print(ClientData)
			local WeaponModel = Character.Zanpakuto
			WeaponModel.PrimaryPart.Weld.Enabled = false
			WeaponModel.Parent = Character["Right Arm"]

			EntityData[Character.Name].WeaponEquipped = "Katana"

			local Motor6D = Character["Right Arm"]	:FindFirstChild("Handle")
			Motor6D.Part1 = WeaponModel.PrimaryPart
			Motor6D.C0 = WeaponData[EntityData[Character.Name].WeaponEquipped .. "AttackData"].GripData

			local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Katana["Draw" .. 1])
			DrawAnimation:Play()

			local UnsheatheSound = Sounds.Unsheathe:Clone()
			UnsheatheSound.PlayOnRemove = true
			UnsheatheSound.Parent = Character.PrimaryPart
			UnsheatheSound:Destroy()
			UnsheatheSound = nil

			local WeaponName = EntityData[Character.Name].WeaponEquipped
			local IdleNum = math.random(1, 3)
			local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName]["Idle"..IdleNum])
			IdleAnimation:Play()

			StateMachine:SetState("WeaponDrawn")
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Walking = {
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		Walk = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local WalkAnimation = Animations.Walking
			Character.Humanoid.Animator:LoadAnimation(WalkAnimation):Play()
		end,
		ReleaseWalk = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Walking", "SearchByReference")
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	WeaponDrawn = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TriggerExecute = function(StateMachine, Character)
			StateMachine:SetState("Executing")
			StateMachine:Trigger("Execute", StateMachine, Character)
		end,
		TriggerWalk = function(StateMachine, Character)
			StateMachine:SetState("Walking")
			StateMachine:Trigger("Walk", StateMachine, Character)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerLAttack = function(StateMachine, Character, ...)
			StateMachine:SetState("Attacking")
			StateMachine:Trigger("LightAttack", StateMachine, Character, ...)
		end,
		TriggerCAttack = function(StateMachine, Character, ...)
			StateMachine:SetState("CriticalAttacking")
			StateMachine:Trigger("CriticalAttack", StateMachine, Character, ...)
		end,
		TriggerParry = function(StateMachine, Character)
			StateMachine:SetState("Parrying")
			StateMachine:Trigger("Parry", StateMachine, Character)
		end,
		TriggerSprint = function(StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("Sprinting")
			StateMachine:Trigger("Sprint", StateMachine, Character)
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			StateMachine:SetState("ShikaiSkill")
			StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, ...)
		end,
		TriggerShikaiRelease = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("ShikaiRelease", StateMachine, Character, ...)
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiRelease", StateMachine, Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			ReiatsuValue -= 5 -- Subtracts the cost of the skill from the players current reiatsu
			if TimeDifference >= Character:GetAttribute("FlashstepCooldown") and ReiatsuValue >= 0 then
				StateMachine:PushState("WeaponDrawn")
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			else
				local DashKeys = {"A", "S", "D"}
				StateMachine:Trigger("TriggerDash", StateMachine, Character, DashKeys[math.random( #DashKeys)])
			end
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime)		
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", "SearchByReference")
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")

			if Character.Head:FindFirstChild("DashForce") then
				Character.Head.DashForce:Destroy()
			end

			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()

			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Parrying = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		Parry = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("BlockTimer")
			if TimeDifference >= Character:GetAttribute("ParryCooldown") then
				Character:SetAttribute("ParryCooldown", 1700)
				Character:SetAttribute("BlockTimer", DateTime.now().UnixTimestampMillis) 

				local WeaponAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
				local ParryAnimation = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations.Parry)
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
				ParryAnimation:Play()
				ParryAnimation.KeyframeReached:Connect(function(KeyframeName)
					if KeyframeName == "DeflectStart" then
						Character:SetAttribute("DeflectFrames", true)
					elseif KeyframeName == "DeflectEnd" then
						if EntityData[Character.Name].Action == "Parry" then
							Character:SetAttribute("DeflectFrames", true)
							StateMachine:SetState("Parrying")
						else
							Character:SetAttribute("DeflectFrames", false)
							StateMachine:Trigger("TriggerBlock", StateMachine, Character)
						end
					end
				end)
			else
				StateMachine:Trigger("TriggerBlock", StateMachine, Character)
			end	
		end,
		TriggerBlock = function(StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:SetState("Blocking")
			StateMachine:Trigger("TrueBlock", StateMachine, Character)
		end,	
		TriggerTrueStun = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Parry", "SearchByReference")
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Parry", "SearchByReference")
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime)
			EntityData[Character.Name].LastParriedTime = DateTime.now().UnixTimestampMillis
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "Parry", "SearchByReference")
			
			Character:SetAttribute("DeflectFrames", true)
			Character:SetAttribute("ParryCooldown", 0)
			EntityData[Character.Name].BlockHeld = nil
			
			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Parrying" .. DeflectAnimation])
			DeflectAnimation:Play()

			local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "Deflected")

			local Stance = Character:GetAttribute("Posture")
			Stance -= DeflectDamage
			if Stance <= 0 then
				Character:SetAttribute("Posture", 0)
			else
				Character:SetAttribute("Posture", Stance)	
			end
			
			local AutoParryFrame = StatData.AutoParryFrame
			local ParryStunDuration = DeflectAnimation.Length + ParryStunTime
			
			task.delay(AutoParryFrame, function()
				local TimeDifference = DateTime.now().UnixTimestampMillis - EntityData[Character.Name].LastParriedTime
				if TimeDifference >= AutoParryFrame * 995 then
					print(Character.Name .. " auto parry end")
					Character:SetAttribute("DeflectFrames", false)
				end
				
				if EntityData[Character.Name].Action ~= "Parry" then
					
				end
			end)
			task.delay(ParryStunDuration, function()
				StateMachine:Trigger("TriggerWeaponDrawn", StateMachine, Character)
			end)
		end,
		TriggerWeaponDrawn = function(StateMachine, Character)
			if EntityData[Character.Name].Action == "Parry" then
				Character:SetAttribute("DeflectFrames", true)
				StateMachine:SetState("Parrying")
			else
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
				Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
				Character.Humanoid.AutoRotate = true
				StateMachine:SetState("WeaponDrawn")
			end
		end,
	},
	Blocking = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")
			Character:SetAttribute("BlockFrames", false)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TrueBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", true)
			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Block)
			BlockAnimation:Play()

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
		end,
		ReleaseBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", false)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			StateMachine:SetState("WeaponDrawn")	
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			Character:SetAttribute("BlockFrames", false)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		SoftBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", true)
			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Block)
			BlockAnimation:Play()

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
		end,
		BlockedAttack = function(StateMachine, Character, AttackData, AttackOwner)
			local HitBlockAnim = Character.Humanoid.Animator:LoadAnimation(Animations.HitBlock)
			HitBlockAnim:Play()

			local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "Blocked")
			
			local Posture = Character:GetAttribute("Posture")
			Posture += AttackData.BlockDamage
			if Posture >= Character:GetAttribute("MaxPosture") then
				StateMachine:Trigger("TriggerPostureBreak", StateMachine, Character)

				local PostureBrokenDamage = AttackData.Damage / 2

				CombatManager:ApplyDamage(AttackOwner, {[Character] = "FrontalHit"}, {Damage = PostureBrokenDamage})
			else
				if Posture <= 0 then
					Character:SetAttribute("Posture", 0)
				else
					Character:SetAttribute("Posture", Posture)	
				end
				
				PassivesManager:ApplyPassive("Safeguard", Character, AttackOwner, AttackData)
			end
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", false)
			Character:SetAttribute("DeflectFrames", false)

			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Attacking = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", true)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerM2 = function(StateMachine, Character, ...)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FeintTimer")
			if TimeDifference >= 3250 then
				StateMachine:Trigger("LightAttack", StateMachine, Character)

				task.delay(0.25, function()
					Character:SetAttribute("FeintTimer", DateTime.now().UnixTimestampMillis)
					local Combo = Character:GetAttribute("Combo")
					Combo -= 1
					if Combo <= 1 then
						Combo = 1
					else
						Character:SetAttribute("Combo", Combo)
					end

					local FeintSound = Sounds.Feint:Clone()
					FeintSound.PlayOnRemove = true
					FeintSound.Parent = Character.HumanoidRootPart
					FeintSound:Destroy()
					FeintSound = nil	
					SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", true)

					task.delay(0.2, function()
						StateMachine:Trigger("LightAttack", StateMachine, Character)
					end)
				end)
			else
				StateMachine:Trigger("LightAttack", StateMachine, Character)
			end
		end,
		LightAttack = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")
			Character:SetAttribute("BlockFrames", false)

			local WeaponEquipped = EntityData[Character.Name].WeaponEquipped
			local WeaponAnimations = CombatAnimations[WeaponEquipped]

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 2

			local WeaponTable
			if WeaponEquipped == "Katana" then
				if StatData.Factions[EntityData[Character.Name].Race] == "Arrancar" then
					WeaponTable = WeaponData.SpecialKatanaData.LightAttack
				else
					WeaponTable = WeaponData.KatanaAttackData.LightAttack
				end
			else
				WeaponTable = WeaponData[WeaponEquipped.. "AttackData"].LightAttack
			end

			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ComboTimer")
			if TimeDifference >= 3000 or Character:GetAttribute("Combo") >= 6 then 
				Character:SetAttribute("Combo", 1)
			end
			Character:SetAttribute("ComboTimer", DateTime.now().UnixTimestampMillis)

			local Combo = Character:GetAttribute("Combo")
			
			local AttackSpeed = PassivesManager:ApplyAttackSpeed(Character, EntityData[Character.Name], EntityData[Character.Name].ClientData)
			local LightAttack = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations["LightAttack" .. Combo])
			LightAttack:Play()
			LightAttack:AdjustSpeed(AttackSpeed)

			Combo += 1
			Character:SetAttribute("Combo", Combo)

			LightAttack.KeyframeReached:Connect(function(KeyframeName)
				if KeyframeName == "HitFrame" then
					local DetectedEntities = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, WeaponTable.Properties)
					if DetectedEntities then
						local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, WeaponTable)
						if DamagedEntities and Combo >= 6 then
							for _, v in pairs(DamagedEntities) do
								KnockbackModule:Knockback(Character, v, 40)
							end
						end
					end
					local LightAttackSound = Sounds.Swing:Clone()
					LightAttackSound.Parent = Character.HumanoidRootPart
					LightAttackSound:Destroy()
				elseif KeyframeName == "FeintStart" then
					EntityData[Character.Name].AllowFeint = true
				elseif KeyframeName == "FeintEnd" then
					EntityData[Character.Name].AllowFeint = false
					local Sound = ReplicatedStorage.Assets.Sounds:FindFirstChild(WeaponEquipped .. "Swing")
					if Sound then
						local SwingSound = Sound:Clone()
						SwingSound.Parent = Character.HumanoidRootPart
						SwingSound:Destroy()
						SwingSound = nil
					end
				elseif KeyframeName == "AnimationEnd" then
					if Combo >= 6 then
						Character:SetAttribute("Combo", 1)
						Character.Humanoid.WalkSpeed = 0
						task.delay(WeaponTable.Endlag, function()
							StateMachine:Trigger("ReleaseAttacking", StateMachine, Character)
						end)
					else
						StateMachine:Trigger("ReleaseAttacking", StateMachine, Character)
					end
				end
			end)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("WeaponDrawn")
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", true)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleaseAttacking = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.AutoRotate = true
			
			if EntityData[Character.Name].Action == "LightAttack" then
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			else
				StateMachine:SetState("WeaponDrawn")
			end
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime)	
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", "SearchByReference")		

			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()

			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData)
			--StateMachine:SetState("AttackBlocked")
			--StateMachine:Trigger("AttackBlocked", StateMachine, Character, BlockDamage)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	ShikaiSkill = {
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", true)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		SkillReleaseFromHeld = function(StateMachine, Character, KeyPressed)
			local ShikaiModule = EntityData[Character.Name].ShikaiModule
			local ShikaiSkill = ShikaiModule.Held[KeyPressed]
			if ShikaiSkill and Character:GetAttribute(KeyPressed) == false then
				ShikaiSkill(Character, StateMachine, KeyPressed)
			end
		end,
		ShikaiSkillPress = function(StateMachine, Character, ...)
			local Keys = {"Z", "X", "C"}
			local KeyPressed = Keys[math.random(1, 3)]
			local ShikaiModule = EntityData[Character.Name].ShikaiModule
			local ShikaiSkill = ShikaiModule.Keybinds[KeyPressed]
			if ShikaiSkill and Character:GetAttribute(KeyPressed) == false then -- Checks if the keypressed is actually a skill & if off cooldown
				if Character:GetAttribute("ShikaiCD") == false then
					local ReiatsuValue = Character:GetAttribute("Reiatsu")
					ReiatsuValue -= ShikaiModule[ShikaiSkill].ReiatsuCost -- Subtracts the cost of the skill from the players current reiatsu
					if ReiatsuValue >= 0 then -- Player has enough reiatsu to use the skill
						Character:SetAttribute("Reiatsu", ReiatsuValue)
						ShikaiModule[ShikaiSkill].SkillFunction(Character, StateMachine, KeyPressed) -- Starts / calls the shikai skill from the module
						Character:SetAttribute("ShikaiCD", true)

						local ShikeiHeld = ShikaiModule.Held[KeyPressed]
						if ShikeiHeld and Character:GetAttribute(KeyPressed) == false then
							task.delay(Random.new():NextNumber(0, 3), function()
								StateMachine:Trigger("SkillReleaseFromHeld", StateMachine, Character, KeyPressed)
							end)
						end

						task.delay(5, function()
							Character:SetAttribute("ShikaiCD", false)
						end)
					else
						StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
					end
				else
					StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
				end
			else
				StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
			end
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData)
			--StateMachine:SetState("AttackBlocked")
			--StateMachine:Trigger("AttackBlocked", StateMachine, Character, BlockDamage)
		end,
		ReleaseShikaiSkill = function(StateMachine, Character)
			StateMachine:SetState("WeaponDrawn")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.AutoRotate = true
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("WeaponDrawn")
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", true)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime)
			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()

			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")

			if Character.HumanoidRootPart:FindFirstChild("IceClawDashForce") then
				Character.HumanoidRootPart.IceClawDashForce:Destroy()
			end

			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
	},
	CriticalAttacking = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Critical", "SearchByReference")
			Character:SetAttribute("ClashFrames", nil)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		CriticalAttack = function(StateMachine, Character, Location)
			if Character:GetAttribute("CriticalCooldown") == false then
				Character:SetAttribute("CriticalCooldown", true)

				local WeaponEquipped = EntityData[Character.Name].WeaponEquipped
				local Critical = WeaponEquipped .. "HeavyAttack"
				if Character:GetAttribute("ZanpakutoState") >= 2 and StatData.Factions[EntityData[Character.Name].Race] == "Arrancar" and CriticalModule["Bankai" .. WeaponEquipped .. "HeavyAttack"] then
					Critical = "Bankai" .. WeaponEquipped .. "HeavyAttack"
				end

				CriticalModule[Critical](StateMachine, Character, EntityData[Character.Name], EntityData[Character.Name].ClientData, "NPC")
			else
				StateMachine:Trigger("ReleaseHAttack", StateMachine, Character)
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			end
		end,
		TriggerClashing = function(StateMachine, Character, ...)
			EntityData[Character.Name].ClashStage = 0
			StateMachine:SetState("Clashing")
			StateMachine:Trigger("ClashStage1", StateMachine, Character, ...)
		end,
		ReleaseHAttack = function(StateMachine, Character)
			Character:SetAttribute("ClashFrames", nil)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			StateMachine:SetState("WeaponDrawn")
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Critical", "SearchByReference")
			Character:SetAttribute("ClashFrames", nil)		

			if Character.Head:FindFirstChild("DashForce") then
				Character.Head.DashForce:Destroy()
			end

			local CombatAnimations = CombatAnimations[EntityData[Character.Name].WeaponEquipped]
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()

			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Critical", true)
			Character:SetAttribute("ClashFrames", nil)	
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Critical", "SearchByReference")
			Character:SetAttribute("ClashFrames", nil)	

			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Clashing = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,	
		ClashStage1 = function(StateMachine, Character, Opponent, InputSetup)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 0 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			EntityData[EntityID].ClashStage = 1
			Character:SetAttribute("ClashFrames", nil)
			Character:SetAttribute("ClashScore", 0)
			ClashSystem.Stage1(Character, Opponent)

			local FailureChance = 30 -- 30%
			local RNG = Random.new()		
			local Accumulated = 0
			local Min = 0.3
			local Max = 0.45
			local ReactionTime = RNG:NextNumber(Min, Max)
			local ClashScore = 0
			EntityData[EntityID].ClashHeartbeat = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated >= ReactionTime then
					Accumulated = 0
					ReactionTime = RNG:NextNumber(Min, Max)
					local Pass = RNG:NextInteger(1, 100)
					if Pass > FailureChance then
						ClashScore += 1
						if ClashScore >= 8 then
							EntityData[EntityID].ClashHeartbeat:Disconnect()
							EntityData[EntityID].ClashHeartbeat = nil
							EntityManager:ChangeState(Opponent, "ClashStage2", Character, InputSetup)
							StateMachine:Trigger("ClashStage2", StateMachine, Character, Opponent, InputSetup)
						else
							Character:SetAttribute("ClashScore", ClashScore)
						end
					else
						ClashScore -= 1
						Character:SetAttribute("ClashScore", ClashScore)
					end
					print("[Clash Stage 1]", Character.Name, Character:GetAttribute("ClashScore"))
				end		
			end)
		end,
		ClashStage2 = function(StateMachine, Character, Opponent)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 1 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			EntityData[EntityID].ClashStage = 2
			if EntityData[EntityID].ClashHeartbeat then
				EntityData[EntityID].ClashHeartbeat:Disconnect()
				EntityData[EntityID].ClashHeartbeat = nil
			end

			local WaitForKeyframe
			local function KeyframeReached(ClashAnimation) -- Function that just saves us repeating the same lines of code twice
				SharedFunctions:CancelAnimation(Character.Humanoid, "Clash1", true)
				ClashAnimation:Play()
				ClashAnimation.KeyframeReached:Connect(function(KeyframeName) -- Once the keyframes reaches LastFrame
					if KeyframeName == "LastFrame" then
						ClashAnimation:AdjustSpeed(0) -- Pauses the animation
						WaitForKeyframe = true
					elseif KeyframeName == "KnockbackFrame" then

					end
				end)
			end
			Character:SetAttribute("ClashScore", 0)
			local ClashAnimation = ClashSystem.Stage2(Character, Opponent)
			KeyframeReached(ClashAnimation)

			local FailureChance = 30 -- 30%
			local RNG = Random.new()		
			local Accumulated = 0
			local Min = 0.3
			local Max = 0.45
			local ReactionTime = RNG:NextNumber(Min, Max)
			local ClashScore = 0
			EntityData[EntityID].ClashHeartbeat = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if WaitForKeyframe then
					if Accumulated >= ReactionTime then
						Accumulated = 0
						ReactionTime = RNG:NextNumber(Min, Max)
						local Pass = RNG:NextInteger(1, 100)
						if Pass > FailureChance then
							ClashScore += 1
							if ClashScore >= 8 then
								EntityData[EntityID].ClashHeartbeat:Disconnect()
								EntityData[EntityID].ClashHeartbeat = nil
								EntityManager:ChangeState(Opponent, "ClashStage3", Character)
								StateMachine:Trigger("ClashStage3", StateMachine, Character, Opponent)
							else
								Character:SetAttribute("ClashScore", ClashScore)
							end
						else
							ClashScore -= 1
							Character:SetAttribute("ClashScore", ClashScore)
						end
						print("[Clash Stage 2]", Character.Name, Character:GetAttribute("ClashScore"))
					end	
				end
			end)

		end,
		ClashStage3 = function(StateMachine, Character, Opponent)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 2 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			EntityData[EntityID].ClashStage = 3
			if EntityData[EntityID].ClashHeartbeat then
				EntityData[EntityID].ClashHeartbeat:Disconnect()
				EntityData[EntityID].ClashHeartbeat = nil
			end

			if Character:GetAttribute("ClashType") == "Attacker" then
				ClashSystem.Stage3(Character, Opponent)
			end
		end,
		ReleaseClashing = function(StateMachine, Character)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			if EntityData[EntityID].ClashHeartbeat then
				EntityData[EntityID].ClashHeartbeat:Disconnect()
				EntityData[EntityID].ClashHeartbeat = nil
			end
			EntityData[EntityID].ClashStage = nil

			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerKnockout = function(StateMachine, Character)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			if EntityData[EntityID].ClashHeartbeat then
				EntityData[EntityID].ClashHeartbeat:Disconnect()
				EntityData[EntityID].ClashHeartbeat = nil
			end
			EntityData[EntityID].ClashStage = nil

			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("Knockout", StateMachine, Character)
		end,
		ClashPostureBreak = function(StateMachine, Character)
			local EntityID = Character:GetAttribute("EntityID")
			if EntityData[EntityID].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", EntityData[EntityID].ClashStage)
				return
			end
			if EntityData[EntityID].ClashHeartbeat then
				EntityData[EntityID].ClashHeartbeat:Disconnect()
				EntityData[EntityID].ClashHeartbeat = nil
			end
			EntityData[EntityID].ClashStage = nil

			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
	},
	AttackBlocked = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		AttackBlocked = function(StateMachine, Character, BlockDamage)
			EntityData[Character.Name].AttackBlockedTimer = DateTime.now().UnixTimestampMillis

			local Endlag = 0.15

			local Combo = Character:GetAttribute("Combo")
			if Combo >= 6 then
				Character:SetAttribute("Combo", 1)
				Endlag = 0.4
			end

			task.delay(Endlag, function()
				if DateTime.now().UnixTimestampMillis - EntityData[Character.Name].AttackBlockedTimer >= Endlag * 1000 then
					StateMachine:Trigger("ReleaseAttackBlocked", StateMachine, Character)
				end
			end)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("WeaponDrawn")
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", true)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", "SearchByReference")

			if Character.Head:FindFirstChild("DashForce") then
				Character.Head.DashForce:Destroy()
			end

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		ReleaseAttackBlocked = function(StateMachine, Character)
			StateMachine:SetState("WeaponDrawn")
			if EntityData[Character.Name].Action == "LightAttack" then
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			end
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.AutoRotate = true
		end,
	},	
	Action = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		ShikaiRelease = function(StateMachine, Character, ClientData)
			Character:SetAttribute("ShikaiTimer", DateTime.now().UnixTimestampMillis)
			Character:SetAttribute("ZanpakutoState", 1)
			Character:SetAttribute("HyperArmor", true)
			Character.Humanoid.WalkSpeed = 0

			local Race = ClientData.Race
			if StatData.Factions[Race] == "Shinigami" then
				local ShikaiReleaseSound = ReplicatedStorage.Assets.ShikaiSounds.ShikaiRelease:Clone()
				ShikaiReleaseSound.PlayOnRemove = true
				ShikaiReleaseSound.Parent = Character.PrimaryPart
				ShikaiReleaseSound:Destroy()
				ShikaiReleaseSound = nil
			elseif StatData.Factions[Race] == "Arrancar" then
				local ResReleaseSound = ReplicatedStorage.Assets.ShikaiSounds.ResRelease:Clone()
				ResReleaseSound.PlayOnRemove = true
				ResReleaseSound.Parent = Character.PrimaryPart
				ResReleaseSound:Destroy()
				ResReleaseSound = nil
			end

			-- Above stuff will need to be done for all shikais so it can just go here
			EntityData[Character.Name].WeaponEquipped = nil
			local ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[ClientData.Shikai .. "Shikai"]) 
			EntityData[Character.Name].ShikaiModule = ShikaiModule
			local ShikaiWeapon = ShikaiWeapons:WeaponRelease(Character, StateMachine, ClientData, EntityData[Character.Name])
			ShikaiModule:ReleaseShikai(Character, StateMachine, ClientData, EntityData[Character.Name])
			EntityData[Character.Name].WeaponEquipped = ShikaiWeapon
			Character:SetAttribute("Combo", 1)
		end,
		BankaiRelease = function(StateMachine, Character, ClientData)
			local Player = Players:GetPlayerFromCharacter(Character)
			Character:SetAttribute("ZanpakutoState", 2)
			Character:SetAttribute("IFrames", true)
			Character.Humanoid.WalkSpeed = 0

			EntityData[Character.Name].WeaponEquipped = nil
			local ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[ClientData.Shikai .. "Shikai"])
			EntityData[Character.Name].ShikaiModule = ShikaiModule
			local ReleaseBankai = ShikaiModule:ReleaseBankai(Character, StateMachine, ClientData)
			EntityData[Character.Name].WeaponEquipped = ReleaseBankai
			Character:SetAttribute("Combo", 1)

			local DrainRate = 50
			local Accumulated = 0

			EntityData[Character.Name].BankaiTimer = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated >= 1 then
					Accumulated -= 1

					local BankaiUltAmount = 400
					if BankaiUltAmount - DrainRate > 0 then
						BankaiUltAmount -= DrainRate
					else
						EntityData[Character.Name].BankaiTimer:Disconnect()
						EntityData[Character.Name].BankaiTimer = nil

						if StatData.Factions[ClientData.Race] == "Arrancar" then
							Character:SetAttribute("ZanpakutoState", 0)
						elseif StatData.Factions[ClientData.Race] == "Shinigami" then
							Character:SetAttribute("ZanpakutoState", 1)
						end
					end
				end
			end)
		end,
		ReleaseAction = function(StateMachine, Character)
			StateMachine:SetState("WeaponDrawn")
		end,
	},
	TrueStunned = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TrueStun = function(StateMachine, Character, AttackData, AttackOwner)
			if not EntityData[Character.Name].StunnedDuration then
				EntityData[Character.Name].StunnedTime = DateTime.now().UnixTimestampMillis
				EntityData[Character.Name].StunnedDuration = AttackData.TrueStunTime
			elseif AttackData.TrueStunTime >= EntityData[Character.Name].StunnedDuration then
				EntityData[Character.Name].StunnedTime = DateTime.now().UnixTimestampMillis
				EntityData[Character.Name].StunnedDuration = AttackData.TrueStunTime
			end

			Character:SetAttribute("Combo", 1)
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.WalkSpeed = 0

			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			if AttackData.StunAnimation then
				if AttackData.StunAnimation ~= "None" then
					local StunAnimation = Character.Humanoid.Animator:LoadAnimation(AttackData.StunAnimation)
					StunAnimation:Play()
				end
			else
				local HitReaction = Character.Humanoid.Animator:LoadAnimation(Animations["HitReaction" .. math.random(1, 2)])
				HitReaction:Play()
			end
			
			task.delay(AttackData.TrueStunTime, function()
				if EntityData[Character.Name] and DateTime.now().UnixTimestampMillis - EntityData[Character.Name].StunnedTime >= EntityData[Character.Name].StunnedDuration * 995 then
					EntityData[Character.Name].StunnedDuration = 0
					StateMachine:Trigger("TriggerSoftStun", StateMachine, Character, AttackData.SoftStunTime)
				end
			end)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerSoftStun = function(StateMachine, Character, SoftStunTime)
			EntityData[Character.Name].StunnedDuration = 0
			Character.Humanoid.WalkSpeed = 4
			StateMachine:SetState("SoftStunned")	
			StateMachine:Trigger("SoftStun", StateMachine, Character, SoftStunTime)
		end,
		ReleaseFlashstep = function(StateMachine, Character)
			EntityData[Character.Name].Flashstepping = nil

			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop)

			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
		end,
	},
	SoftStunned = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		SoftStun = function(StateMachine, Character, SoftStunTime)
			if SoftStunTime <= 0 then
				StateMachine:Trigger("ReleaseSoftStun", StateMachine, Character)
			else
				task.delay(SoftStunTime, function()
					StateMachine:Trigger("ReleaseSoftStun", StateMachine, Character)
				end)
			end
		end,
		ReleaseSoftStun = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			
			if EntityData[Character.Name].Action == "Block" then
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerParry", StateMachine, Character)
			elseif EntityData[Character.Name].Action == "LightAttack" then
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			elseif EntityData[Character.Name].Action == "Heal" then
				Character.Humanoid.Health = Character.Humanoid.MaxHealth
				StateMachine:PopState()
			elseif EntityData[Character.Name].Action == "Parry" then
				Character:SetAttribute("DeflectFrames", true)
				StateMachine:SetState("Parrying")
			else
				StateMachine:PopState()
			end 
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerBlock = function(StateMachine, Character)
			StateMachine:SetState("Blocking")
			StateMachine:Trigger("TrueBlock", StateMachine, Character)
		end,
	},
	PostureBroken = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		PostureBreak = function(StateMachine, Character)
			EntityData[Character.Name].PostureBreakDuration = DateTime.now().UnixTimestampMillis
			
			local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "PostureBreak")

			local HitReaction = Character.Humanoid.Animator:LoadAnimation(Animations.PostureBroken)
			HitReaction:Play()

			Character:SetAttribute("Posture", 0)
			Character:SetAttribute("Combo", 1)
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.WalkSpeed = 0

			task.delay(StatData.PostureBreakTime, function()
				if DateTime.now().UnixTimestampMillis - EntityData[Character.Name].PostureBreakDuration >= StatData.PostureBreakTime * 995 then
					Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
					Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

					SharedFunctions:CancelAnimation(Character.Humanoid, "PostureBroken")
					StateMachine:Trigger("ReleasePostureBreak", StateMachine, Character)
				end
			end)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "PostureBroken")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleasePostureBreak = function(StateMachine, Character)
			if EntityData[Character.Name].Action == "Block" then
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerParry", StateMachine, Character)
			elseif EntityData[Character.Name].Action == "LightAttack" then
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			elseif  EntityData[Character.Name].Action == "Parry" then
				Character:SetAttribute("DeflectFrames", true)
				StateMachine:SetState("Parrying")
			else
				StateMachine:PopState()
			end
		end,
	},
	Sprinting = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			EntityData[Character.Name].SprintHeld = nil
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		Sprint = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") + 10
			EntityData[Character.Name].SprintHeld = true

			local WeaponEquipped = EntityData[Character.Name].WeaponEquipped

			if WeaponEquipped then
				local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations[WeaponEquipped]
				local SprintAnim = "Sprint"
				Character.Humanoid.Animator:LoadAnimation(CombatAnimations[SprintAnim]):Play()
			else
				Character.Humanoid.Animator:LoadAnimation(Animations["Sprint"]):Play()
			end
		end,
		StopSprint = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			StateMachine:PopState()
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
			StateMachine:PushState("Sprinting")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,
		TriggerExecute = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			StateMachine:SetState("Executing")
			StateMachine:Trigger("Execute", StateMachine, Character)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerLAttack = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			StateMachine:SetState("Attacking")
			StateMachine:Trigger("LightAttack", StateMachine, Character)
		end,
		TriggerDefendChoice = function(StateMachine, Character)
			StateMachine:Trigger("TriggerParry", StateMachine, Character)
		end,
		TriggerCAttack = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
			StateMachine:SetState("CriticalAttacking")
			StateMachine:Trigger("CriticalAttack", StateMachine, Character)
		end,
		TriggerBlock = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			StateMachine:SetState("Blocking")
			StateMachine:Trigger("TrueBlock", StateMachine, Character)
		end,
		TriggerParry = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("BlockTimer")
			if EntityData[Character.Name].WeaponEquipped and TimeDifference >= Character:GetAttribute("ParryCooldown") then
				SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
				StateMachine:SetState("Parrying")
				StateMachine:Trigger("Parry", StateMachine, Character)
			end
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			StateMachine:SetState("ShikaiSkill")
			StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, ...)
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiRelease", StateMachine, Character, ...)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			ReiatsuValue -= 5 -- Subtracts the cost of the skill from the players current reiatsu
			if TimeDifference >= Character:GetAttribute("FlashstepCooldown") and ReiatsuValue >= 0 then
				SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			end
		end,
	},
	Flashstep = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		Flashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			ReiatsuValue -= 5 -- Subtracts the cost of the skill from the players current reiatsu
			if TimeDifference >= Character:GetAttribute("FlashstepCooldown") and ReiatsuValue >= 0 then
				EntityData[Character.Name].Flashstepping = true
				Character:SetAttribute("FlashstepTimer", DateTime.now().UnixTimestampMillis)
				Character:SetAttribute("EvasiveFrames", true)
				Character:SetAttribute("Reiatsu", ReiatsuValue)

				local Race = EntityData[Character.Name].Race				
				local FlashstepSpeed = StatData.BaseFlashstepSpeed
				if StatData.Factions[Race] == "Arrancar" then
					FlashstepSpeed += StatData.ArrancarFlashstepBonus
				elseif StatData.Factions[Race] == "Quincy" then
					FlashstepSpeed += StatData.QuincyFlashstepBonus
				end
				if Character:GetAttribute("Shunko") then
					FlashstepSpeed += SkillData.Shunko.FlashstepSpeedBuff
				end
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					FlashstepSpeed += StatData.BankaiSpeedIncrease
				end
				if Character.Humanoid.Health <= (Character.Humanoid.MaxHealth * 0.3) then
					FlashstepSpeed = math.floor(FlashstepSpeed / 1.5)
				end

				local BonusWalkspeed = FlashstepSpeed + (Character:GetAttribute("Speed") / StatData.SpeedScaling)

				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") + BonusWalkspeed

				local PathDataStart = {Module = FlashstepClient, Skill = "Flashstep"}
				local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
				local RenderDistance = -1
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)
				coroutine.wrap(function()
					for i = 1, 3 do
						if  EntityData[Character.Name] and EntityData[Character.Name].Flashstepping then
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStart, Race)
						else
							return
						end
						task.wait(1)
					end
				end)()

				local WeaponEquipped = EntityData[Character.Name].WeaponEquipped
				if WeaponEquipped then
					local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations[WeaponEquipped]
					Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Sprint):Play()
				else
					Character.Humanoid.Animator:LoadAnimation(Animations["Sprint"]):Play()
				end

				local EvasiveDuration = StatData.FlashstepEvasiveFrames
				if Character:GetAttribute("EnhancedSteps") then
					EvasiveDuration += EvasiveDuration * SkillData["Enhanced Steps"].EvasiveFrameMultiplier
				end

				task.delay(EvasiveDuration, function()
					Character:SetAttribute("EvasiveFrames", false)
				end)
				task.delay(2.5, function()
					if EntityData[Character.Name] and EntityData[Character.Name].Flashstepping then
						StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character)
					end
				end)
			end
		end,
		ReleaseFlashstep = function(StateMachine, Character, State, ...)
			EntityData[Character.Name].Flashstepping = nil
			local Race = EntityData[Character.Name].Race

			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)

			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			StateMachine:PopState()
			StateMachine:Trigger(State, StateMachine, Character, ...)
		end,
		-- Actions below auto exit flash step --
		TriggerLAttack = function(StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "TriggerLAttack")
		end,
		TriggerCAttack = function(StateMachine, Character)
			StateMachine:PushState("CriticalAttacking")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "CriticalAttack")
		end,
		TriggerExecute = function(StateMachine, Character)
			StateMachine:PushState("Executing")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "Execute")
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			StateMachine:PushState("ShikaiSkill")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "ShikaiSkillPress", ...)
		end,
		TriggerParry = function(StateMachine, Character)
			StateMachine:PushState("Parrying")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "Parry")
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "BankaiRelease", ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:PushState("Unconscious")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "TriggerKnockout")
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			EntityData[Character.Name].Flashstepping = nil
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")

			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			EntityData[Character.Name].Flashstepping = nil

			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")

			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Dashing = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		Dash = function(StateMachine, Character, KeyPressed)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("DashTimer")
			if TimeDifference >= 1750 then
				Character.Humanoid.Animator:LoadAnimation(Animations[KeyPressed .. "Dash"]):Play()
				Character:SetAttribute("EvasiveFrames", true)
				Character:SetAttribute("DashTimer", DateTime.now().UnixTimestampMillis)

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Name = "DashForce"
				BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
				if KeyPressed == "W" then
					BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * 45
				elseif KeyPressed == "S" then
					BodyVelocity.Velocity = -Character.HumanoidRootPart.CFrame.LookVector * 6
				elseif KeyPressed == "A" then
					BodyVelocity.Velocity = -Character.HumanoidRootPart.CFrame.RightVector * 8
				elseif KeyPressed == "D" then
					BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.RightVector * 8
				end
				BodyVelocity.Parent = Character.Head
				game:GetService("Debris"):AddItem(BodyVelocity, 0.45)

				local DashSound = Sounds.Dash:Clone()
				DashSound.PlayOnRemove = true
				DashSound.Parent = Character.PrimaryPart
				DashSound:Destroy()
				DashSound = nil
				
				local EvasiveDuration = StatData.DashEvasiveFrames
				if Character:GetAttribute("EnhancedSteps") then
					EvasiveDuration += EvasiveDuration * SkillData["Enhanced Steps"].EvasiveFrameMultiplier
				end

				task.delay(EvasiveDuration, function()
					Character:SetAttribute("EvasiveFrames", false)
				end)
				task.delay(StatData.DashReleaseDuration, function()
					StateMachine:Trigger("ReleaseDashing", StateMachine, Character)
				end)
			end
		end,
		ReleaseDashing = function(StateMachine, Character)
			StateMachine:SetState("WeaponDrawn")
		end,
	},
	Executing = {
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		Execute = function(StateMachine, Character)
			local KillCheck = false
			for i, v in pairs(workspace.Entities:GetChildren()) do
				if v.PrimaryPart and v:GetAttribute("CurrentState") == "Unconscious" and not v:GetAttribute("Carried") and not v:GetAttribute("Death") and v ~= Character  and not KillCheck and not v:GetAttribute("GripBypass") then
					if (v.HumanoidRootPart.Position - Character.PrimaryPart.Position).Magnitude < 7 then
						KillCheck = true

						Character.Humanoid.WalkSpeed = 0
						Character.Humanoid.JumpHeight = 0

						Ragdoll:Disable(v)

						EntityData[Character.Name].Victim = v

						v.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame

						local Weld = Instance.new("Weld")
						Weld.Name = "GripWeld"
						Weld.Part0 = Character.HumanoidRootPart
						Weld.Part1 = v.HumanoidRootPart
						Weld.C0 = CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)
						Weld.Parent = Character

						Character.Humanoid.AutoRotate = false

						EntityManager:ChangeState(v, "TriggerDying")

						local WeaponEquipped = EntityData[Character.Name].WeaponEquipped
						local GripAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponEquipped].Grip)
						local DyingAnimation = v.Humanoid:LoadAnimation(CombatAnimations[WeaponEquipped].Gripped)

						GripAnimation:Play()
						DyingAnimation:Play()

						local ExecutorDestroyed
						local VictimDestroyed

						GripAnimation.KeyframeReached:Connect(function(KeyframeName)
							if KeyframeName == "EventFrame" then
								Weld:Destroy()
								EntityData[Character.Name].VictimDestroyed:Disconnect()
								EntityData[Character.Name].VictimDestroyed = nil
								EntityManager:ChangeState(v, "TriggerDeath", Character)
								EntityData[Character.Name].Victim = nil
								
								local GripSound = Sounds.Grip:Clone()
								GripSound.PlayOnRemove = true
								GripSound.Parent = Character.PrimaryPart
								GripSound:Destroy()
								GripSound = nil
							elseif KeyframeName == "AnimationEnd" then
								EntityData[Character.Name].ExecutorDestroyed:Disconnect()
								EntityData[Character.Name].ExecutorDestroyed = nil
								StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
							end
						end)

						EntityData[Character.Name].ExecutorDestroyed = Character.Destroying:Connect(function() -- Player left
							EntityManager:ChangeState(v, "ReleaseDying")
							VictimDestroyed:Disconnect()
							VictimDestroyed = nil
							ExecutorDestroyed:Disconnect()
							ExecutorDestroyed = nil
						end)

						EntityData[Character.Name].VictimDestroyed = v.Destroying:Connect(function() -- Target left
							StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
							ExecutorDestroyed:Disconnect()
							ExecutorDestroyed = nil
							VictimDestroyed:Disconnect()
							VictimDestroyed = nil
						end)
					end
				end
			end		
			if not KillCheck then
				StateMachine:SetState("WeaponDrawn")
			end
		end,
		TriggerExecute = function(StateMachine, Character)
			--EntityManager:ChangeState(EntityData[Character.Name].Victim, "TriggerUnconscious")
			--EntityData[Character.Name].Victim = nil
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
		end,
		TriggerUnconscious = function(StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleaseExecute = function(StateMachine, Character)
			if EntityData[Character.Name].VictimDestroyed then
				EntityData[Character.Name].VictimDestroyed:Disconnect()
				EntityData[Character.Name].VictimDestroyed = nil
			end

			if EntityData[Character.Name].ExecutorDestroyed then
				EntityData[Character.Name].ExecutorDestroyed:Disconnect()
				EntityData[Character.Name].ExecutorDestroyed = nil
			end

			if EntityData[Character.Name].Victim then
				EntityManager:ChangeState(EntityData[Character.Name].Victim, "ReleaseDying")
				EntityData[Character.Name].Victim = nil
			end
			SharedFunctions:CancelAnimation(Character.Humanoid, "Grip")

			local GripWeld = Character:FindFirstChild("GripWeld")
			if GripWeld then
				GripWeld:Destroy()
				GripWeld = nil
			end
			
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Dying = {
		ReleaseDying = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Gripped")
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerDeath = function(StateMachine, Character, Executor,  Dismembered)
			Character:SetAttribute("Death", true)
			
			if Dismembered then
				local Colors = {}
				for i, v in ipairs(Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Transparency = 1
					elseif v:IsA("SpecialMesh") or v:IsA("MeshPart") then
						v:Destroy()
					elseif v:IsA("Shirt") or v:IsA("Pants") then
						v:Destroy()
					end
				end
				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") and not table.find(Colors, v.Color) and v.Transparency ~= 1 then
						table.insert(Colors, v.Color)
					end
				end

				local function RandomNumber(Min, Max)
					return Random.new():NextNumber(Min, Max)
				end

				for _, BodyPart in ipairs(Character:GetChildren()) do
					if BodyPart:IsA("BasePart") then
						task.spawn(function()
							for i = 1, 13 do
								local Pieces = Instance.new("Part")
								Pieces.Color = Colors[math.random(1, #Colors)]
								Pieces.Size = Vector3.new(0.1, 0.3, 1)
								Pieces.CFrame = BodyPart.CFrame * CFrame.new(RandomNumber(-BodyPart.Size.X/2, BodyPart.Size.X/2), RandomNumber(-BodyPart.Size.Y/2, BodyPart.Size.Y/2), RandomNumber(-BodyPart.Size.Z/2, BodyPart.Size.Z/2))
								Pieces.CollisionGroup = "Entity"
								Pieces.Parent = workspace.Effects[Character.Name]
								Pieces.Velocity = Vector3.new(math.random(-15, 15), math.random(-10, 10), math.random(-15, 15))
								task.wait()
							end
						end)
					end
				end
				
				task.wait(1.5)
				
				Character:BreakJoints()
				Character.Humanoid.Health = -5
				game:GetService("Debris"):AddItem(Character, 2)
			else
				task.spawn(function()
					for i, v in ipairs(Character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = true
							v.Material = Enum.Material.Neon
							TweenService:Create(v, TweenInfo.new(1), {Color = Color3.fromRGB(104, 148, 152)}):Play()
						elseif v:IsA("SpecialMesh") or v:IsA("MeshPart") then
							v:Destroy()
						elseif v:IsA("Shirt") or v:IsA("Pants") then
							v:Destroy()
						end
					end
				end)
				
				Character:BreakJoints()
				Character.Humanoid.Health = -5
				game:GetService("Debris"):AddItem(Character, 2)
			end
		end,
	},
	Unconscious = {
		TakeDamage = function(StateMachine, Character, ...)
			EntityData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			DamageTaken(Character, ...)
		end,
		TriggerDying = function(StateMachine, Character)
			EntityData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			
			local Overtimes = CombatManager:GetOvertimes(Character)
			if Overtimes then
				local TrueBurn = CombatManager:GetOvertimes(Character).TrueBurn
				if TrueBurn then
					CombatManager:CancelOvertime(Character, "TrueBurn")
				end
			end
			
			StateMachine:SetState("Dying")
		end,
		TriggerKnockout = function(StateMachine, Character)
			EntityData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			StateMachine:Trigger("Knockout", StateMachine, Character)
		end,
		Knockout = function(StateMachine, Character)
			local KnockoutDuration = 12

			if not Character:GetAttribute("Carried") then
				Ragdoll:Enable(Character)
			end

			if not EntityData[Character.Name].HealthpackTimer then
				EntityData[Character.Name].HealthpackTimer = true
				PassivesManager:Healthpack(Character, DamageTracker:RetrieveData(Character).Counter, StatData.NPCReiatsuPack)

				task.delay(30, function()
					if EntityData[Character.Name] and EntityData[Character.Name].HealthpackTimer then
						EntityData[Character.Name].HealthpackTimer = nil
					end
				end)
			end

			DamageTracker:Reset(Character)

			task.delay(KnockoutDuration, function()
				if EntityData[Character.Name] and EntityData[Character.Name].KnockoutTime then
					local TimeDifference = DateTime.now().UnixTimestampMillis - EntityData[Character.Name].KnockoutTime
					print(TimeDifference, "/", KnockoutDuration * 1000, "time left for knockout")
					print(Character:GetAttribute("Carried"), "if carried check")
					print(Character:GetAttribute("CurrentState"), "currentstate check")
					if TimeDifference >= KnockoutDuration * 1000 and not Character:GetAttribute("Carried") and Character:GetAttribute("CurrentState") == "Unconscious" then
						StateMachine:Trigger("Wakeup", StateMachine, Character)
						print(Character.Name .. " wakeup")
					else
						StateMachine:Trigger("Knockout", StateMachine, Character)
						print(Character.Name .. " knockout time reset")
					end
				end
			end)
		end,
		Wakeup = function(StateMachine, Character)
			Ragdoll:Disable(Character)
			StateMachine:SetState("WeaponDrawn")
			DamageTracker:Reset(Character)
		end,
		ReleaseCarried = function(StateMachine, Character)
			if EntityData[Character.Name].CarryOwnerLeave and EntityData[Character.Name].CarryOwnerLeave.Connected then
				EntityData[Character.Name].CarryOwnerLeave:Disconnect()
				EntityData[Character.Name].CarryOwnerLeave = nil
			end
			if EntityData[Character.Name].CarryOwnerDied and EntityData[Character.Name].CarryOwnerDied.Connected then
				EntityData[Character.Name].CarryOwnerDied:Disconnect()
				EntityData[Character.Name].CarryOwnerDied = nil
			end
			print("releasing carry")
			for Index, Part in ipairs(Character:GetChildren()) do
				if Part:IsA'BasePart' then
					Part.CollisionGroup = "Entity"
					print(Part.CollisionGroup)
					if Part:GetAttribute("Massless") then
						Part.Massless = Part:GetAttribute("Massless")
						Part:SetAttribute("Massless", nil)
					else
						Part.Massless = false
					end

					if Part:CanSetNetworkOwnership() then
						Part:SetNetworkOwner(nil)
					end
				end
			end

			SharedFunctions:CancelAnimation(Character.Humanoid, "Carried")
			EntityData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			Character:SetAttribute("Carried", nil)
			Character:SetAttribute("IFrames", false)

			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("Knockout", StateMachine, Character)
		end,
		TriggerCarried = function(StateMachine, Character, Carrier)
			Character:SetAttribute("Carried", true)
			Character:SetAttribute("IFrames", true)
			
			local Carried = Animations.Carried
			local CarriedAnimation = Character.Humanoid.Animator:LoadAnimation(Carried)
			CarriedAnimation:Play()
			
			local Overtimes = CombatManager:GetOvertimes(Character)
			if Overtimes then
				local TrueBurn = CombatManager:GetOvertimes(Character).TrueBurn
				if TrueBurn then
					CombatManager:CancelOvertime(Character, "TrueBurn")
				end
			end
			
			local PlayerCarrier = Players:GetPlayerFromCharacter(Carrier)
			if PlayerCarrier then
				EntityData[Character.Name].CarryOwnerLeave = PlayerCarrier.CharacterRemoving:Connect(function()
					StateMachine:Trigger("ReleaseCarried", StateMachine, Character)
					print("carrier removed")
					if EntityData[Character.Name].CarryOwnerLeave and EntityData[Character.Name].CarryOwnerLeave.Connected then
						EntityData[Character.Name].CarryOwnerLeave:Disconnect()
						EntityData[Character.Name].CarryOwnerLeave = nil
					end
				end)
				
				EntityData[Character.Name].CarryOwnerDied = Carrier.Humanoid.Died:Connect(function()
					StateMachine:Trigger("ReleaseCarried", StateMachine, Character)
					print("carrier died")
					if EntityData[Character.Name].CarryOwnerDied and EntityData[Character.Name].CarryOwnerDied.Connected then
						EntityData[Character.Name].CarryOwnerDied:Disconnect()
						EntityData[Character.Name].CarryOwnerDied = nil	
					end
				end)
			end
		end,
	},
}

function DummyData:SetupEntity(EntityID, SpawnPosition, InitialData)	
	EntityData[EntityID] = {}
	EntityData[EntityID].Action = "none"
	
	local Corrupt = InitialData.Corrupt
	local Race = InitialData.Race
	EntityData[EntityID].Race = Race
	
	EntityData[EntityID].Action = InitialData.Action

	local Dummy = ServerStorage.Assets.Entities.Shinigami:Clone()
	Dummy.Name = EntityID
	PassivesManager:CreatePassiveData(Dummy)
	CombatManager:SetupOvertimes(Dummy)
	
	local DummyPassives = {
		"Safeguard"
	}
	PassivesManager:SetupPassives(Dummy, DummyPassives)
	PassivesManager:UpdatePassive(Dummy, {
		Name = "Safeguard",
		Data = true
	})

	local EffectsFolder = Instance.new("Folder")
	EffectsFolder.Name = EntityID
	EffectsFolder.Parent = workspace.Effects

	local LiveAssetsFolder = Instance.new("Folder")
	LiveAssetsFolder.Name = EntityID
	LiveAssetsFolder.Parent = ServerStorage.LiveAssets

	Dummy:SetAttribute("Corrupt", 1)

	local RNG = Random.new()
	local RandomNumber = RNG:NextInteger(1, 100)
	if RandomNumber <= 10 or Corrupt then
		if EntityData[EntityID].Race == "Shinigami" then
			Dummy:SetAttribute("Corrupt", 1.5)

			local LtAccessory = ServerStorage.Assets.Accessories.AccessoryTypes.Shoulder["Lt. Band"]:Clone()
			LtAccessory.Parent = Dummy

			local Weld = Instance.new("Weld")
			Weld.Part1 = Dummy["Left Arm"]
			Weld.C0 = CFrame.new(0.000137329102, -2.62260437e-05, 0.000495910645, 1, 0, 0, 0, 0.999997139, 0, 0, 0, 0.99999994)
			Weld.Part0 = LtAccessory.PrimaryPart
			Weld.Parent = LtAccessory.PrimaryPart
		end
	end

	local function SetupCharacter(Character)
		local BloatStates = {
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.Seated,
			Enum.HumanoidStateType.Climbing,
			Enum.HumanoidStateType.Swimming,
			Enum.HumanoidStateType.Flying,
			Enum.HumanoidStateType.StrafingNoPhysics,
			Enum.HumanoidStateType.GettingUp,
		}

		for _, HumanoidState in pairs(BloatStates) do
			Character.Humanoid:SetStateEnabled(HumanoidState, false)
		end

		local AppearanceColor = "Pastel yellow"

		local BodyColors = Instance.new("BodyColors")
		BodyColors.HeadColor = BrickColor.new(AppearanceColor)
		BodyColors.LeftArmColor = BrickColor.new(AppearanceColor)
		BodyColors.LeftLegColor = BrickColor.new(AppearanceColor)
		BodyColors.RightArmColor = BrickColor.new(AppearanceColor)
		BodyColors.RightLegColor = BrickColor.new(AppearanceColor)
		BodyColors.TorsoColor = BrickColor.new(AppearanceColor)
		BodyColors.Parent = Character

		local FaceDecals = ServerStorage.Assets.Accessories.Faces
		Character.Head.Face:Destroy()

		local FakeHead = Character.Head:Clone()
		FakeHead.Name = Character.Name .. "Head"
		FakeHead.CanCollide = false
		FakeHead.CanQuery = false
		FakeHead.CanTouch = false
		FakeHead.Massless = true
		FakeHead.Transparency = 1

		local Weld = Instance.new("Weld")
		Weld.Part0 = FakeHead
		Weld.Part1 = Character.Head
		Weld.Parent = FakeHead
		FakeHead.Parent = workspace.Effects[Character.Name]

		local RandomHair = math.random(1, #ServerStorage.Assets.ShinigamiHairCombos:GetChildren())
		local HairCombos = ServerStorage.Assets.ShinigamiHairCombos
		for i, v in ipairs(HairCombos[RandomHair]:GetChildren()) do
			local Accessory = v:Clone()
			Accessory.Handle.CanQuery = false
			Accessory.Handle.CanCollide = false
			Accessory.Handle.CanTouch = false
			Accessory.Parent = Character
		end

		-- Clone the players facial features onto the FakeHead
		--[[local RandomEyes = math.random(1, 5)
		local RandomMouth = math.random(1, 2)
		local RandomEyebrows = math.random(1, 2)
		local RandomMarking = math.random(0, 6)
		
		local Eyes =  FaceDecals["Eye" .. RandomEyes]:Clone()
		local Pupils = FaceDecals["Pupil" .. RandomEyes]:Clone()
		local Mouth = FaceDecals["Mouth" .. RandomMouth]:Clone()
		local Eyebrow = FaceDecals["Eyebrow" .. RandomEyebrows]:Clone()
		local Marking = FaceDecals["Markings" .. RandomMarking]:Clone()

		Eyes.Parent = FakeHead
		Pupils.Color3 = Color3.fromRGB(1275, 0, 0)
		Pupils.Parent = FakeHead
		Mouth.Parent = FakeHead
		Eyebrow.Parent = FakeHead
		Marking.Parent = FakeHead]]

		if StatData.Factions[Race] == "Arrancar" then
			local MaskData = require(ServerStorage.Modules.Utility.MaskData)
			local ChosenMask = math.random(1, 11)
			local MaskAccessory = ServerStorage.Assets.Accessories.Masks["Mask" ..ChosenMask]:Clone()
			MaskAccessory.Parent = Character

			local Weld = Instance.new("Weld")
			Weld.Part1 = Character.Head
			Weld.C0 = MaskData["Mask" .. ChosenMask]

			if MaskAccessory:IsA("Model") then
				Weld.Part0 = MaskAccessory.PrimaryPart
				Weld.Parent = MaskAccessory.PrimaryPart
			else
				Weld.Part0 = MaskAccessory
				Weld.Parent = MaskAccessory
			end
		end

		Character.ShinigamiPants1:Destroy()
		Character.ShinigamiShirt1:Destroy()

		if StatData.Factions[Race] == "Shinigami" then
			local Shirt = ServerStorage.Assets.Clothing.Shinigami.ShinigamiShirt1:Clone()
			Shirt.Parent = Character
			local Pants = ServerStorage.Assets.Clothing.Shinigami.ShinigamiPants1:Clone()
			Pants.Parent = Character-- Clone the players clothing based of their current rank & form
		elseif Race == "Arrancar" then
			local Shirt = ServerStorage.Assets.Clothing.Arrancar.ArrancarShirt1:Clone()
			Shirt.Parent = Character
			local Pants = ServerStorage.Assets.Clothing.Arrancar.ArrancarPants1:Clone()
			Pants.Parent = Character
		elseif Race == "Vastocar" then
			-- Vastocars separate clothes froma arracnar probably 
		end

		local Motor6D = Instance.new("Motor6D")
		Motor6D.Name = "Handle"
		Motor6D.Part0 = Character["Right Arm"]
		Motor6D.Parent = Character["Right Arm"]

		local DualMotor6D = Instance.new("Motor6D")
		DualMotor6D.Name = "DualHandle2"
		DualMotor6D.Part0 = Character["Left Arm"]
		DualMotor6D.Parent = Character["Left Arm"]

		Character.Animate.Disabled = false

		local RandomName = {
			"Rikka", "Misaka", "Arcueid", "Alice", "Aoko", "Ilya", "Maria", "Makima", "Nao", "Nayuta",
			"Ciel", "Noel", "Scathach", "Lily", "Rin", "Ryougi", "Mana", "Artoria", "Shinobu", "Mayoi", "Akeno", "Milize",
			"Rias", "Emilia"
		}

		local HumanClans = {
			"Shiba", "Hitsugaya", "Unohana", "Abarai", "Kyoraku", "Shihouin", "Urahara",
			"Hirako","Kuchiki", "Ichimaru", "Hisagi", "Kira", "Kurosaki", "Zaraki", "Yamamoto", "Hyosube"
		}
		local HollowClans = {
			"Harribel", "Gilga", "Llargo", "Granz", "Rureaux", "Arruruerie", "Odelschwanck",
			"Louisenbairn", "Starrk", "Jaegerjaquez", "Cifer"
		}

		local ChosenClan
		if StatData.Factions[Race] == "Arrancar" then
			ChosenClan = HollowClans[math.random(1, #HollowClans)]
		elseif StatData.Factions[Race] == "Shinigami" then
			ChosenClan = HumanClans[math.random(1, #HumanClans)]
		end

		local FirstName = RandomName[math.random(1, #RandomName)]
		Character.Humanoid.DisplayName = FirstName .. " " .. ChosenClan
		Character.Humanoid.NameDisplayDistance = 50
		
		for i, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CollisionGroup = "Entity"
			end
		end
		
		Character.Parent = workspace.Entities
	end

	local function SetupZanpakuto(Character)
		local SheathePositions = {
			Sheathe2 = CFrame.new(1.36058164, 0.196736336, -0.525276184, -0.777146161, -0.629320204, -0, 0.629320204, -0.777146161, 0, 0, 0, 0.999999642),
			Sheathe1 = CFrame.new(0.922791481, 0.825448036, 0.525001526, -0.99026835, -0.139173523, -0, -0.139173508, 0.990268171, 2.2279627e-09, -3.25076389e-11, -1.86236149e-09, -0.999999642),
			Sheathe3 = CFrame.new(0.913573265, -0.781798363, 0.525001526, 0.987688363, -0.156434461, 0, -0.156434461, -0.987688363, -0, 0, 0, -0.999999642),
			Sheathe4 = CFrame.new(0.391113281, -1.10011292, 1.04087448, 0, -0.258819103, 0.965924084, 0, -0.965925932, -0.258818567, 1.00000012, 0, 0)
		}

		local ZanpakutoParts = ServerStorage.Assets.ZanpakutoParts
		local Template = ZanpakutoParts.Template

		local Sheathe = ZanpakutoParts.Sheathe:Clone()
		local Blade = ZanpakutoParts.Blades:Clone()
		local Hilt = ZanpakutoParts.Hilts.Hilt1:Clone()
		local Handle = ZanpakutoParts.Handles.Handle1:Clone()
		local PrimaryHandle = ZanpakutoParts.Handle:Clone()

		Handle.Handles.Color = Color3.fromRGB(255, 255, 255)
		Hilt.HiltColor.Color = Color3.fromRGB(152, 31, 27)
		Handle.HiltColor.Color = Color3.fromRGB(27, 27, 27)
		Blade.Guard.Color = Color3.fromRGB(152, 31, 27)
		for _, v in pairs(Sheathe:GetChildren()) do
			if v.Name == "Wraps" and not v:IsA("Weld") then
				v.Color = Color3.fromRGB(152, 31, 27)
			end
		end
		for _, v in pairs(Handle:GetChildren()) do
			if v.Name == "Wraps" and not v:IsA("Weld") then
				v.Color = Color3.fromRGB(255, 255, 255)
			end
		end

		local ZanpakutoModel = Instance.new("Model")
		ZanpakutoModel.Name = "Zanpakuto"
		ZanpakutoModel.PrimaryPart = PrimaryHandle

		PrimaryHandle.Parent = ZanpakutoModel
		Blade.Parent = PrimaryHandle
		Hilt.Parent = PrimaryHandle
		Handle.Parent = PrimaryHandle

		Sheathe.Parent = Character

		Blade.CFrame = Template.Base.CFrame
		Hilt.CFrame = Template.Hilt.CFrame
		Handle.CFrame = Template.Handle.CFrame
		Sheathe.CFrame = Template.Base.CFrame
		PrimaryHandle.CFrame = Template.Main.CFrame


		local SheatheWeld = Instance.new("Weld")
		SheatheWeld.C0 = SheathePositions.Sheathe1
		SheatheWeld.Part0 = Sheathe
		SheatheWeld.Part1 = Character.Torso
		SheatheWeld.Parent = Sheathe

		local WeaponWeld = Instance.new("Weld")
		WeaponWeld.C0 = CFrame.new(-0.727386475, 0.0504477024, -0.00285339355, -1.66893005e-06, -0.0125809116, 0.999921322, 1.00000012, -1.70303974e-06, 1.68383121e-06, 1.6816349e-06, 0.999920905, 0.0125809042)
		WeaponWeld.Part0 = Sheathe
		WeaponWeld.Part1 = ZanpakutoModel.PrimaryPart
		WeaponWeld.Parent = ZanpakutoModel.PrimaryPart


		for i, v in pairs(PrimaryHandle:GetChildren()) do
			if v:IsA("Part") or v:IsA("MeshPart") then
				local WeldConstraint = Instance.new("WeldConstraint")
				WeldConstraint.Part0 = v
				WeldConstraint.Part1 = PrimaryHandle
				WeldConstraint.Parent = v
			end
		end


		ZanpakutoModel.Name = "Zanpakuto"
		ZanpakutoModel.Parent = Character
	end

	local function CreateAttributes(Character, EntityID)
		-- Only really create attributes for data that would need to be shared or could be shared for future skill
		DamageTracker:Setup(Character)
		
		Character:SetAttribute("EntityType", EntityData[Character.Name].Race)

		Character:SetAttribute("EntityID", EntityID)
		Character:SetAttribute("MaxPosture", 50)
		Character:SetAttribute("Posture", 0)
		Character:SetAttribute("MaxReiatsu", 99999)
		Character:SetAttribute("Reiatsu", 99999)
		Character:SetAttribute("Combo", 1)
		Character:SetAttribute("BaseWalkspeed", StatData.WalkSpeeds.Base)
		Character:SetAttribute("BaseJumpheight", StatData.JumpHeights.Base)

		Character:SetAttribute("CounterType", "string")
		Character:SetAttribute("CounterFrames", false)
		Character:SetAttribute("EvasiveFrames", false)
		Character:SetAttribute("DeflectFrames", false)
		Character:SetAttribute("BlockFrames", false)
		Character:SetAttribute("IFrames", false)
		Character:SetAttribute("HyperArmor", false)

		Character:SetAttribute("ZanpakutoState", 0)

		Character:SetAttribute("CurrentState", "Idle")

		Character:SetAttribute("Speed", 20)
		Character:SetAttribute("Kendo", 0)
		
		Character:SetAttribute("FlashstepCooldown", 4300)
		Character:SetAttribute("ParryCooldown", 500) -- Time in milliseconds for parry to come off cooldown (just checks current time compares to this value)
		Character:SetAttribute("BlockTimer", DateTime.now().UnixTimestampMillis)
		Character:SetAttribute("FlashstepTimer", DateTime.now().UnixTimestampMillis)
		Character:SetAttribute("ComboTimer", DateTime.now().UnixTimestampMillis)
		Character:SetAttribute("DashTimer", DateTime.now().UnixTimestampMillis)
		Character:SetAttribute("FeintTimer", DateTime.now().UnixTimestampMillis)
		Character:SetAttribute("ShikaiTimer", DateTime.now().UnixTimestampMillis)

		Character:SetAttribute("CombatTag", 0)

		Character:SetAttribute("Z", false)
		Character:SetAttribute("X", false)
		Character:SetAttribute("C", false)
		Character:SetAttribute("CriticalCooldown", false)

		Character:SetAttribute("One", false)

		Character:SetAttribute("ShikaiCD", false)
		
		EntityData[Character.Name].Cooldowns = {
			One = 0;
			Two = 0;
			Three = 0;
			Four = 0;
			Five = 0;
			Six = 0;
			Seven = 0;
			Eight = 0;
			Nine = 0;
			Zero = 0;
			Minus = 0;
			Equals = 0;
			Z = 0;
			X = 0;
			C = 0;
			T = 0;
			G = 0;
		}
	end

	SetupCharacter(Dummy)
	CreateAttributes(Dummy, EntityID)
	SetupZanpakuto(Dummy)
	Ragdoll:Setup(Dummy)

	Dummy.PrimaryPart.CFrame = CFrame.new(SpawnPosition)

	for _, v in ipairs(Dummy:GetDescendants()) do
		if v:IsA("BasePart") then
			v:SetNetworkOwner(nil)
			v.Massless = false
		end
	end

	local ShinigamiDeath
	ShinigamiDeath = Dummy.Humanoid.Died:Connect(function()
		EntityManager:CleanupEntity(EntityID)
		PassivesManager:Cleanup(Dummy.Name)
		CombatManager:ResetCombatTags(Dummy)
		CombatManager:CleanupOvertimes(Dummy.Name)
		DamageTracker:Cleanup(Dummy)
		for i, v in pairs(EntityData[EntityID]) do
			if typeof(v) == "RBXScriptConnection" then -- disconnects any existing connections to prevent memory leaks
				EntityData[EntityID][i]:Disconnect()
				EntityData[EntityID][i] = nil
			else
				EntityData[EntityID][i] = nil
			end
		end
		EntityData[EntityID] = nil
		EffectsFolder:Destroy()
		LiveAssetsFolder:Destroy()
		ShinigamiDeath:Disconnect()
		ShinigamiDeath = nil
		SharedFunctions:CancelAllAnimations(Dummy.Humanoid)
	end)

	return Dummy
end

return DummyData
