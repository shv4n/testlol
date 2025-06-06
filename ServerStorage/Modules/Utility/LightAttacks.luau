local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientLightAttacks
local HitEffectClient = ReplicatedStorage.Modules.ClientModules.ClientHitEffects
local RenderDistance = 1000

local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local CombatManager = require(ServerStorage.Modules.Managers.CombatManager)
local HitDetection = require(ServerStorage.Modules.Utility.HitDetection)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local Ragdoll = require(ServerStorage.Modules.Utility.Ragdoll)
local KnockbackModule = require(ServerStorage.Modules.Utility.Knockback)
local WeaponData = require(ServerStorage.Modules.Utility.WeaponData)
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local Projectile = require(ServerStorage.Modules.Utility.Projectile)
local AirtimeManager = require(ServerStorage.Modules.Managers.AirtimeManager)
local SkillData = require(ServerStorage.Modules.Utility.SkillData)
local BankaiWeapons = require(ServerStorage.Modules.SkillModules.Shikais.BankaiWeapons)
local SpiritBowData = require(ServerStorage.Modules.Utility.SpiritBowData)
local SpiritBows = require(ServerStorage.Modules.Utility.SpiritBows)
local ServerSkills = require(ServerStorage.Modules.SkillModules.Skills.ServerSkills)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations

local TrailBlacklist = {
	Fist = true;
	ResFist = true;
	Grimmjow = true;
	Drakos2 = true;
	Cang = true;
}

local function GetStats(Player, Character)
	local SPTable
	if Player then
		SPTable = DataManager:RequestSP(Player)
	else
		SPTable = {
			Kido = Character:GetAttribute("Kido");
			Kendo = Character:GetAttribute("Kendo");
			Speed = Character:GetAttribute("Speed");
			Hakuda = 0;
			Healing = 0;
		}
	end
	local ReturnedStats = {}

	local Blacklist = {
		Name = true;
		SP = true;
	}

	local HighestStat, StatValue
	for i, v in pairs(SPTable) do
		if not Blacklist[i] then
			if not HighestStat then
				HighestStat, StatValue = i, v
			else
				if v > StatValue then
					HighestStat, StatValue = i, v
				end
			end
		end
	end

	ReturnedStats.HighestStat = HighestStat;
	ReturnedStats.Kido = SPTable.Kido;
	ReturnedStats.Kendo = SPTable.Kendo;
	ReturnedStats.Speed = SPTable.Speed;
	ReturnedStats.Hakuda = SPTable.Hakuda;
	ReturnedStats.Healing = SPTable.Healing;

	return ReturnedStats
end

local function GetTargetByMouse(Player, MouseRange, Range, NPCTarget, PartyFilter, PartyBlacklist, UnconsciousBlacklist, UnconsciousFilter)
	local Target
	if Player and not Player.Character:GetAttribute("Zombification") then
		Target = SharedFunctions:GetTargetByMouse(Player, MouseRange, Range, PartyFilter, PartyBlacklist, UnconsciousBlacklist, UnconsciousFilter)
	else
		Target = NPCTarget
	end
	return Target
end

local ToggledLightAttacks = {
	LetztStil = function(Character, StateMachine, LightAttackData, PlayerData, ClientData, NPCDebuffData, NPCTarget)
		local Player = Players:GetPlayerFromCharacter(Character)
		local CeroStats = GetStats(Player, Character)
		
		--[[ give own m1 scaling
		
		LightAttackData.Damage += (CeroStats.Kendo / LightAttackData.QuincyKendo) + (CeroStats.Hakuda / LightAttackData.QuincyHakuda)
		LightAttackData.AutoTrackingSpeed += CeroStats.Speed * LightAttackData.QuincySpeed
		LightAttackData.Speed += CeroStats.Speed * LightAttackData.QuincySpeed
		LightAttackData.MouseRange += CeroStats.Kido * LightAttackData.QuincyKido]]

		Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
		Character.Humanoid.JumpHeight = 0
		
		local SpiritAmmo = Character:GetAttribute("SpiritAmmo")
		if not SpiritAmmo then
			SpiritAmmo = LightAttackData.Ammo
		end
		SpiritAmmo -= 1
		Character:SetAttribute("SpiritAmmo", SpiritAmmo)
		
		local AmmoPath = {Module = ClientModule, Skill = "SpiritBowAmmo"}
		if Player then
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, AmmoPath, "On")
		end
		
		local PathData = {Module = ClientModule, Skill = "LetztStil"}
		
		local SpawnPoint = Character.HumanoidRootPart.CFrame
		
		if Player and not Character:GetAttribute("Shiftlocked") then
			local MousePosition = SharedFunctions.GetCameraToMouse(Player)
			SpawnPoint = CFrame.new(SpawnPoint.Position, MousePosition)
		end
		
		NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, SpawnPoint, LightAttackData.Properties)
		
		local DetectedEntities = HitDetection:GetPartBoundsInBox(Character, SpawnPoint, LightAttackData.Properties)
		if DetectedEntities then
			local PositiveHit
			local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
			if LightAttackData.DebuffData then
				PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData)
			end
			if NPCDebuffData then
				PassivesManager:ApplyDebuff(Character, DamagedEntities, NPCDebuffData)
			end
			for i, v in ipairs(DamagedEntities) do
				if not v:GetAttribute("PhantomTrick") then
					PositiveHit = true
				end
				PassivesManager:ApplyPassive("DuelistsDance", Character, v)
				PassivesManager:ApplyM1Passives(Character, v, PlayerData)
				
				KnockbackModule:Repel(Character, Character.HumanoidRootPart.Position, v, 80)
			end

			PassivesManager:ApplyPassive("Lifesteal", Character, PositiveHit)

			if PositiveHit and not Character:GetAttribute("FeintDisabled") then
				Character:SetAttribute("FeintTimer", 0)
			end
		end
		
		local AudioBlock = ReplicatedStorage.Assets.Effects.AudioBlock:Clone()
		AudioBlock.CFrame = SpawnPoint * CFrame.new(0, 0, -LightAttackData.Properties.Range/2)
		AudioBlock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AudioBlock, 0.1)
		
		local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds.LetztStilSwing:Clone()
		LightAttackSound.PlayOnRemove = true
		LightAttackSound.Parent = AudioBlock
		LightAttackSound:Destroy()
		LightAttackSound = nil
	end,
	Bogen = function(Character, StateMachine, LightAttackData, PlayerData, ClientData, NPCDebuffData, NPCTarget)
		local Player = Players:GetPlayerFromCharacter(Character)
		local CeroStats = GetStats(Player, Character)
		
		LightAttackData.Damage += (CeroStats.Kendo / LightAttackData.QuincyKendo) + (CeroStats.Hakuda / LightAttackData.QuincyHakuda)
		LightAttackData.AutoTrackingSpeed += CeroStats.Speed * LightAttackData.QuincySpeed
		LightAttackData.Speed += CeroStats.Speed * LightAttackData.QuincySpeed
		LightAttackData.MouseRange += CeroStats.Kido * LightAttackData.QuincyKido
		
		Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 10
		Character.Humanoid.JumpHeight = 0
		
		local FirstShot
		local SpiritAmmo = Character:GetAttribute("SpiritAmmo")
		if not SpiritAmmo then
			SpiritAmmo = LightAttackData.Ammo
		end
		if SpiritAmmo == LightAttackData.Ammo or SpiritAmmo == LightAttackData.Ammo - 1 then
			FirstShot = true
		end
		SpiritAmmo -= 1
		
		--[[PlayerData.BowReloadTimer = DateTime.now().UnixTimestampMillis
		
		if SpiritAmmo <= 0 then
			Ammo = 0
			if not PlayerData.BowTimer then
				PlayerData.BowTimer = DateTime.now().UnixTimestampMillis
				
				local BowCD = LightAttackData.BowCD
				BowCD -= CeroStats.Speed * LightAttackData.QuincySpeedReload
				if BowCD <= 0 then
					BowCD = 0
				end
				
				local PathData = {Module = ClientModule, Skill = "SpiritBowIndicator"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, BowCD)
			end
		end]]
		Character:SetAttribute("SpiritAmmo", SpiritAmmo)
		
		local AmmoPath = {Module = ClientModule, Skill = "SpiritBowAmmo"}
		if Player then
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, AmmoPath, "On")
		end
		
		local Arrow
		if LightAttackData.Closer then
			Arrow = ServerStorage.Assets.Quincy.CloserArrow:Clone()
		else
			Arrow = ServerStorage.Assets.Quincy.Arrow:Clone()
		end
		
		local ClosestPlayerFromMouse
		local Passives = PassivesManager:RequestPassives(Player)
		if Passives.ReishiTip and FirstShot then
			ClosestPlayerFromMouse = GetTargetByMouse(Player, LightAttackData.MouseRange, 50, NPCTarget, nil, nil, "UnconsciousBlacklist")
			if LightAttackData.Closer then
				LightAttackData.PercentPosture = nil
			end
		end
		
		if ClosestPlayerFromMouse then
			Arrow.CFrame = CFrame.new(Character["Right Arm"].Position, ClosestPlayerFromMouse.HumanoidRootPart.Position)
			Arrow.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Arrow, 2)
			Arrow:SetNetworkOwner(nil)
			
			local RocketPropulsion = Instance.new("RocketPropulsion")
			RocketPropulsion.ThrustD = 50
			RocketPropulsion.TurnP = 0
			RocketPropulsion.TargetRadius = 0.5
			RocketPropulsion.CartoonFactor = 1
			RocketPropulsion.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
			RocketPropulsion.MaxSpeed = LightAttackData.AutoTrackingSpeed

			RocketPropulsion.Target = ClosestPlayerFromMouse.HumanoidRootPart
			RocketPropulsion.Parent = Arrow
			RocketPropulsion:Fire()
			
			local ReachedConnection
			ReachedConnection = RocketPropulsion.ReachedTarget:Connect(function()
				ReachedConnection:Disconnect()
				ReachedConnection = nil
				
				for i, v in ipairs(Arrow:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
				Debris:AddItem(Arrow, 1)
				
				if ClosestPlayerFromMouse:FindFirstChild("HumanoidRootPart") then
					local HitType = HitDetection:FocusTarget(Character, ClosestPlayerFromMouse)
					
					local PositiveHit
					local DamagedEntities = CombatManager:ApplyDamage(Character, {[ClosestPlayerFromMouse] = HitType}, LightAttackData)
					if LightAttackData.DebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData)
					end
					if NPCDebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, NPCDebuffData)
					end
					if CeroStats.HighestStat == "Healing" then
						PassivesManager:Slowed(Character, DamagedEntities, LightAttackData.SlowData)
					end
					for i, v in ipairs(DamagedEntities) do
						if not v:GetAttribute("PhantomTrick") then
							PositiveHit = true
						end
						PassivesManager:ApplyPassive("DuelistsDance", Character, v)
						PassivesManager:ApplyM1Passives(Character, v, PlayerData)
					end
					PassivesManager:ApplyPassive("Lifesteal", Character, PositiveHit)
				end
			end)
			
			task.delay(2, function()
				if ReachedConnection then
					ReachedConnection:Disconnect()
					ReachedConnection = nil
				end
			end)
		else			
			Arrow.CFrame = (Character.HumanoidRootPart.CFrame.Rotation + Character["Right Arm"].Position)
			Arrow.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Arrow, 2)
			Arrow:SetNetworkOwner(nil)
			
			local Reached
			
			if Player and not Character:GetAttribute("Shiftlocked") then
				local MousePosition = SharedFunctions.GetCameraToMouse(Player)
				Projectile:Projectile(Character, Arrow, MousePosition, LightAttackData.Speed)
			else
				Projectile:ProjectileStraight(Character, Arrow, LightAttackData.Speed)
			end
			
			task.delay(1, function()
				if not Reached then
					for i, v in ipairs(Arrow:GetDescendants()) do
						if v:IsA("Trail") or v:IsA("PointLight") then
							v.Enabled = false
						elseif v:IsA("ParticleEmitter") then
							v:Destroy()
						end
					end
				end
			end)
			
			local AlreadyHit = {}
			local Duration = 1
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Duration -= DeltaTime
				if Duration <= 0 or not Arrow.Parent then
					Connection:Disconnect()
					Connection = nil
					return
				end
				
				local SpawnPoint = Arrow.CFrame
				local NearestEntity = HitDetection:NearestSphereMagnitude(Character, SpawnPoint, LightAttackData.Properties, nil, "UnconsciousBlacklist")
				if NearestEntity then
					Reached = true
					Duration = 0
					
					task.delay(0.2, function()
						if Arrow and Arrow.Parent then
							for i, v in ipairs(Arrow:GetDescendants()) do
								if v:IsA("Trail") or v:IsA("PointLight") then
									v.Enabled = false
								elseif v:IsA("ParticleEmitter") then
									v:Destroy()
								end
							end
						end
					end)
					
					local HitType = HitDetection:FocusTarget(Character, NearestEntity)
					local DamagedEntities = CombatManager:ApplyDamage(Character, {[NearestEntity] = HitType}, LightAttackData)
					if LightAttackData.DebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData)
					end
					if NPCDebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, NPCDebuffData)
					end
					for i, v in ipairs(DamagedEntities) do
						PassivesManager:ApplyPassive("DuelistsDance", Character, v)
						PassivesManager:ApplyM1Passives(Character, v, PlayerData)
					end
					if CeroStats.HighestStat == "Healing" then
						PassivesManager:Slowed(Character, DamagedEntities, LightAttackData.SlowData)
					end
					PassivesManager:ApplyPassive("Lifesteal", Character, DamagedEntities)
					
					--[[if DamagedEntities and #DamagedEntities > 0 then
						local DebuffedTargets = HitDetection:FilterPositiveHitDebuffs(Character, DamagedEntities, SkillData["Holy Selection"].DebuffData.Name)
						if DebuffedTargets then
							local NearestEntity, HitType = HitDetection:SortClosestFromDetection(Character, DebuffedTargets)
							ServerSkills["Holy Selection"].SkillFunction(Character, StateMachine, NearestEntity)
						end
					end

					if LightAttackData.Closer then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, SkillData["Holy Selection"].DebuffData)
					end]]
				end
			end)
		end

		local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds.BowSwing:Clone()
		LightAttackSound.PlayOnRemove = true
		LightAttackSound.Parent = Character.HumanoidRootPart
		LightAttackSound:Destroy()
		LightAttackSound = nil
	end,
}

local Attacks = {}

Attacks.Default = function(Character, StateMachine, WeaponTable, PlayerData, ClientData, NPCDebuffData)
	local Player = Players:GetPlayerFromCharacter(Character)
	
	local BankaiFaction = StatData.Factions[ClientData.Race] == "Shinigami" or StatData.Factions[ClientData.Race] == "Quincy"
	local WeaponEquipped = PlayerData.WeaponEquipped
	local WeaponAnimations = CombatAnimations[WeaponEquipped]
	if Character:GetAttribute("ZanpakutoState") >= 2 and BankaiFaction and CombatAnimations[WeaponEquipped]:FindFirstChild("Bankai") then
		WeaponAnimations = CombatAnimations[WeaponEquipped].Bankai
	end
	local LightAttackData = PassivesManager:CreateM1AttackData(Character, WeaponTable, PlayerData, ClientData)
	
	Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 2
	Character.Humanoid.JumpHeight = 0

	local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ComboTimer")
	if TimeDifference >= 1500 or Character:GetAttribute("Combo") >= 6 then 
		Character:SetAttribute("Combo", 1)
	end
	Character:SetAttribute("ComboTimer", DateTime.now().UnixTimestampMillis)

	local HyperArmorCooldown = StatData.HeavyWeaponM1HyperArmorCD
	local HyperArmorM1 = {
		Greatsword = true;
		Hammer = true;
	}
	
	local HyperArmorHit
	local HyperArmorHighlight
	local Combo = Character:GetAttribute("Combo")
	if Combo == 1 and HyperArmorM1[WeaponEquipped] and not PlayerData.M1HyperArmorCD then
		PlayerData.M1HyperArmorCD = DateTime.now().UnixTimestampMillis
		HyperArmorHit = true
		task.delay(0.23, function()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				PassivesManager:ApplyTrueHyperArmor(Character, 1)
				HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
				HyperArmorHighlight.Parent = Character
				Debris:AddItem(HyperArmorHighlight, 1)
			end
		end)

		task.delay(HyperArmorCooldown, function()
			if PlayerData and PlayerData.M1HyperArmorCD and DateTime.now().UnixTimestampMillis - PlayerData.M1HyperArmorCD >= HyperArmorCooldown * 995 then
				PlayerData.M1HyperArmorCD = nil
			end
		end)
	end
	
	local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
	if WeaponEquipped == "Nnoitra" then
		if Combo >= 5 then
			LightAttackData.TrueStunTime = 0.7
			LightAttackData.SoftStunTime = 0
			Character.Humanoid.WalkSpeed = 4
		end
	elseif WeaponEquipped == "Twinblade" then
		if Combo >= 5 and ZanpakutoState >= 2 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Name = "DashForce"
			BodyVelocity.MaxForce = Vector3.new(60000, 0, 60000)
			BodyVelocity.P = 1250
			BodyVelocity.Parent = Character.HumanoidRootPart
			Debris:AddItem(BodyVelocity, 0.3)
			if Player then
				ReplicatedStorage.Remotes.RotationalDash:FireClient(Player, BodyVelocity, "W", 50, false, "ChakramDash")
			else
				BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * 50
			end

			LightAttackData.Properties.Range += 3
		end
	elseif WeaponEquipped == "Scythe" then
		if ZanpakutoState >= 2 then
			if Combo == 2 then
				LightAttackData.Properties.Range += 4
				LightAttackData.Properties.Width += 1
			elseif Combo == 4 then
				LightAttackData.Properties.Range += 6
			end
		end
	elseif WeaponEquipped == "Gauntlet" then
		if ZanpakutoState >= 2 then
			if Combo < 5 then
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Name = "DashForce"
				BodyVelocity.MaxForce = Vector3.new(60000, 0, 60000)
				BodyVelocity.P = 1250
				BodyVelocity.Parent = Character.HumanoidRootPart
				Debris:AddItem(BodyVelocity, 0.2)
				if Player then
					ReplicatedStorage.Remotes.RotationalDash:FireClient(Player, BodyVelocity, "W", WeaponTable.Speed, false, "GauntletDance")
				else
					BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * WeaponTable.Speed
				end
			end
		end
	elseif WeaponEquipped == "Drakos2" then
		if Combo < 5 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Name = "DashForce"
			BodyVelocity.MaxForce = Vector3.new(60000, 0, 60000)
			BodyVelocity.P = 1250
			BodyVelocity.Parent = Character.HumanoidRootPart
			Debris:AddItem(BodyVelocity, 0.2)
			if Player then
				ReplicatedStorage.Remotes.RotationalDash:FireClient(Player, BodyVelocity, "W", WeaponTable.Speed, false, "GauntletDance")
			else
				BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * WeaponTable.Speed
			end
		end
	elseif WeaponEquipped == "Hammer" then
		if ZanpakutoState >= 2 then
			if HyperArmorHit then
				LightAttackData.PosturePercent = 1
				LightAttackData.BlockDamage = 99
				LightAttackData.DeflectDamage = 99
				LightAttackData.Damage += 7.5
				LightAttackData.TrueStunTime = 1
				LightAttackData.SoftStunTime = 0
			end
		end
	elseif WeaponEquipped == "Ruin" and ClientData.BoneKing then
		if ZanpakutoState >= 2 then
			local Ranges = {
				[1] = {
					Range = 30;
					Width = 40;
				};
				[2] = {
					Range = 30;
					Width = 40;
				};
				[3] = {
					Range = 35;
					Width = 3;
				};
				[4] = {
					Range = 30;
					Width = 25;
				};
				[5] = {
					Range = 30;
					Width = 40;
				};
			}
			
			LightAttackData.Properties.Range += Ranges[Combo].Range
			LightAttackData.Properties.Width += Ranges[Combo].Width
			LightAttackData.Damage = 15
		end
	elseif WeaponEquipped == "Fist" and ClientData.Race == "Quincy" then
		LightAttackData.SpiritBow = true
	end
	
	if Character:GetAttribute("PaintItBlackBuff") then
		LightAttackData.Properties.Range = 18
		LightAttackData.Properties.Width = 11
	end
	local DivinitySlashes = Character:GetAttribute("DivinitySlashes")
	if DivinitySlashes then
		LightAttackData.Properties.Range = 30
		LightAttackData.Properties.Width = 45
		LightAttackData.Damage += SkillData.Divinity.M1Damage
		LightAttackData.BlockDamage += SkillData.Divinity.M1Posture
		LightAttackData.DeflectDamage += SkillData.Divinity.M1Posture
	end
	
	local LightAttackToggled = Character:GetAttribute("LightAttackToggled")
	if Player then
		ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
	else
		SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Dash", "SearchByReference")
	end
	
	local ToggledSpiritBow
	local AttackAnimation = WeaponAnimations["LightAttack" .. Combo]
	if LightAttackData.SpiritBow and ClientData.SpiritBow then
		--[[local ReloadTimer = PlayerData.BowReloadTimer
		if not ReloadTimer then
			ReloadTimer = 0
		end
		local CeroStats = GetStats(Player, Character)
		local BowCD = SpiritBowData[ClientData.SpiritBow .. "AttackData"].LightAttack.BowCD
		BowCD -= CeroStats.Speed * SpiritBowData[ClientData.SpiritBow .. "AttackData"].LightAttack.QuincySpeedReload
		
		if BowCD <= 0 then
			BowCD = 0
		end
		
		local ReloadTimeDifference = DateTime.now().UnixTimestampMillis - ReloadTimer
		if ReloadTimeDifference >= BowCD * 995 then
			Character:SetAttribute("SpiritAmmo", LightAttackData.Ammo)
		end
		
		PlayerData.BowReloadTimer = DateTime.now().UnixTimestampMillis
		
		if PlayerData.BowTimer then
			local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData.BowTimer
			if TimeDifference < BowCD * 1000 then
				LightAttackToggled = nil
			else
				PlayerData.BowTimer = nil
				Character:SetAttribute("SpiritAmmo", LightAttackData.Ammo)
			end
		end]]
		
		if Character:GetAttribute("LetztStilActive") and not Character:GetAttribute("WeakLetzt") then
			Character:SetAttribute("SpiritAmmo", Character:GetAttribute("MaxSpiritAmmo"))
		end
		
		if Character:GetAttribute("SpiritAmmo") <= 0 or Character:GetAttribute("QuincyDisabled") then
			LightAttackToggled = nil
		end
		
		local AmmoPath = {Module = ClientModule, Skill = "SpiritBowAmmo"}
		if Player then
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, AmmoPath, "On")
		end

		if LightAttackToggled then
			local Duration = 0.5
			if Combo >= 5 then
				Duration = 0.7
			end
			
			ToggledSpiritBow = ClientData.SpiritBow
			if Character:GetAttribute("LetztStilActive") then
				ToggledSpiritBow = "LetztStil"
				Duration = 0.9
				
				local LetztStilPath = {Module = ClientModule, Skill = "LetztStilCharge"}
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, LetztStilPath)
			end
			
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
			
			AttackAnimation = CombatAnimations[ToggledSpiritBow]["LightAttack" .. Combo]
			LightAttackData = PassivesManager:CreateM1AttackData(Character, SpiritBowData[ToggledSpiritBow .. "AttackData"].LightAttack, PlayerData, ClientData)
			
			if Character:GetAttribute("WeakLetzt") then
				LightAttackData.Properties.Range = LightAttackData.Properties.WeakRange
			end
			
			SpiritBows:CreateBow(Character, Duration)
		end
	end
	
	local HellfreezeSlashes = Character:GetAttribute("HellfreezeSlashes")
	if HellfreezeSlashes then
		--[[local Hit = 2
		if Character:GetAttribute("HellfreezeSlashes") % 2 == 0 then
			Hit = 1
		end
		AttackAnimation = ReplicatedStorage.Assets.SpecAnimations.Hellfreeze["LightAttack" .. Hit]]
		
		LightAttackData.Properties.Range = 30
		LightAttackData.Properties.Width = 40
		LightAttackData.Damage += SkillData["Grand Requiem"].HellfreezeDamage
		LightAttackData.BlockDamage += SkillData["Grand Requiem"].HellfreezePosture
		LightAttackData.DeflectDamage += SkillData["Grand Requiem"].HellfreezePosture
		LightAttackData.TrueStunTime = SkillData["Grand Requiem"].HellfreezeStunTime
		LightAttackData.SoftStunTime = 0
		LightAttackData.StunAnimation = ReplicatedStorage.Assets.ShikaiAnimations.Ice.FrozenAnim
	end
	
	local BloodArt
	if PlayerData.BankaiActiveData and PlayerData.BankaiActiveData.BloodArt and PlayerData.BankaiActiveData.BloodArt.Active then
		BloodArt = PlayerData.BankaiActiveData.BloodArt.BloodMeterCost
		LightAttackData.Properties.Range = 35
		LightAttackData.Properties.Width = 40
		LightAttackData.Damage += PlayerData.BankaiActiveData.BloodArt.Damage
		LightAttackData.BlockDamage += PlayerData.BankaiActiveData.BloodArt.Posture
		LightAttackData.DeflectDamage += PlayerData.BankaiActiveData.BloodArt.Posture
	end
	
	local CurrentM1Passives = PassivesManager:RequestPassives(Character).M1Passives
	if CurrentM1Passives.BurnPassive then
		LightAttackData.ImpactSound = ReplicatedStorage.Assets.ShikaiSounds.Fire.FireHit
	elseif CurrentM1Passives.VoltagePassive then
		LightAttackData.ImpactSound = ReplicatedStorage.Assets.SkillSounds.Special.VoltageImpact
	end
	
	local NearestImpale, ImpaleDistance
	local NearestBite, BiteDistance
	
	local PreM1PassiveCount = 0
	local PreM1Passives = PassivesManager:RequestPassives(Character).PreM1Passives
	for i, v in pairs(PreM1Passives) do
		PreM1PassiveCount += 1
	end
	
	local AttackSpeed = PassivesManager:ApplyAttackSpeed(Character, PlayerData, ClientData)
	BankaiWeapons:PlayWeaponAnimation(Character, "LightAttack" .. Combo, ClientData, PlayerData, AttackSpeed)
	
	local VacuumShunko
	if Character:GetAttribute("AdvShunko") == "Wind" then
		if Combo % 2 == 0 then
			VacuumShunko = true
		end
		
		AttackAnimation = CombatAnimations.AdvancedShunko["LightAttack" .. Combo]
	end
	if VacuumShunko then
		LightAttackData.Properties.Range = 17
		LightAttackData.Properties.Width = 10
		LightAttackData.Damage += 5
	end
	
	local LightAttack = Character.Humanoid.Animator:LoadAnimation(AttackAnimation)
	LightAttack:Play()
	LightAttack:AdjustSpeed(AttackSpeed)

	Combo += 1
	Character:SetAttribute("Combo", Combo)
	
	LightAttack.KeyframeReached:Connect(function(KeyframeName)
		if KeyframeName == "HitFrame" then
			if ToggledSpiritBow then
				ToggledLightAttacks[ToggledSpiritBow](Character, StateMachine, LightAttackData, PlayerData, ClientData, NPCDebuffData)
			elseif LightAttackToggled and ToggledLightAttacks[WeaponEquipped] then
				ToggledLightAttacks[WeaponEquipped](Character, StateMachine, LightAttackData, PlayerData, ClientData, NPCDebuffData)
			else
				if DivinitySlashes then
					local DivinityPath = {Module = ClientModule, Skill = "Divinity"}
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, DivinityPath, DivinitySlashes)

					DivinitySlashes -= 1
					if DivinitySlashes > 0 then
						Character:SetAttribute("DivinitySlashes", DivinitySlashes)
					else
						Character:SetAttribute("DivinitySlashes", nil)
					end
				end
				if HellfreezeSlashes then
					local PathData = {Module = ClientModule, Skill = "Hellfreeze"}
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "1")

					HellfreezeSlashes -= 1
					if HellfreezeSlashes > 0 then
						Character:SetAttribute("HellfreezeSlashes", HellfreezeSlashes)
					else
						Character:SetAttribute("HellfreezeSlashes", nil)
					end
				end
				if BloodArt then
					local PathData = {Module = ClientModule, Skill = "BloodArt"}
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)
				end
				if VacuumShunko then
					local PathData = {Module = ClientModule, Skill = "MukyuShunko"}
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "1")
				end
				
				if PreM1PassiveCount > 0 then
					local IncreasedRangeProperties = {
						Range = LightAttackData.Properties.Range + 8;
						Width = LightAttackData.Properties.Width + 5;
						Height = LightAttackData.Properties.Height + 5;
						Length = LightAttackData.Properties.Length;
					}

					--local PreHitDetection = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, IncreasedRangeProperties)
					local PreHitDetection = HitDetection:GetPartBoundsInBox(Character, Character.HumanoidRootPart.CFrame, IncreasedRangeProperties)
					if PreHitDetection then
						PassivesManager:ApplyPreM1Passives(Character, PreHitDetection, ClientData)
					end
				end
				--local DetectedEntities = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, LightAttackData.Properties)
				local DetectedEntities = HitDetection:GetPartBoundsInBox(Character, Character.HumanoidRootPart.CFrame, LightAttackData.Properties)
				if DetectedEntities then
					local PositiveHit
					local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
					if LightAttackData.DebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData)
					end
					if NPCDebuffData then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, NPCDebuffData)
					end
					if WeaponEquipped == "Ruin" and ZanpakutoState >= 2 then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData2)
						PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData3)
					end
					if DivinitySlashes then
						PassivesManager:ApplyDebuff(Character, DamagedEntities, SkillData.Divinity.DebuffData)
						PassivesManager:Slowed(Character, DamagedEntities, SkillData.Divinity.SlowData)
					end
					for i, v in ipairs(DamagedEntities) do
						if not v:GetAttribute("PhantomTrick") then
							PositiveHit = true
						end
						PassivesManager:ApplyPassive("DuelistsDance", Character, v)
						PassivesManager:ApplyM1Passives(Character, v, PlayerData)

						if WeaponEquipped == "Spear" then
							if ZanpakutoState >= 2 and not BloodArt then
								if not PlayerData.ImpaleData then
									PlayerData.ImpaleData = {}
								end
								if not PlayerData.ImpaleData[v.Name] then
									PlayerData.ImpaleData[v.Name] = {
										Impales = 0;
										ImpaleTimer = DateTime.now().UnixTimestampMillis;
									}
								end

								local ImpaleData = PlayerData.ImpaleData[v.Name]
								local ImpaleTimer = DateTime.now().UnixTimestampMillis - ImpaleData.ImpaleTimer
								if ImpaleTimer >= 6000 then
									ImpaleData.Impales = 0
								end

								ImpaleData.Impales += 1
								ImpaleData.ImpaleTimer = DateTime.now().UnixTimestampMillis

								--print(v.Name .. "_ImpaleCounter:", ImpaleData.Impales)

								local Impales = 2
								if ImpaleData.Impales >= Impales then
									local Magnitude = (v.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude
									if not NearestImpale then
										NearestImpale, ImpaleDistance = v, Magnitude
									else
										if Magnitude < ImpaleDistance then
											NearestImpale, ImpaleDistance = v, Magnitude
										end
									end
								end
							end
						elseif WeaponEquipped == "Hammer" then
							if ZanpakutoState >= 2 and HyperArmorHit then
								if v:GetAttribute("CurrentState") ~= "PostureBroken" then
									KnockbackModule:Knockback(Character, v, 45)

									Ragdoll:Enable(v)
									task.delay(LightAttackData.TrueStunTime, function()
										Ragdoll:Disable(v, "UnconsciousCheck")
									end)
								end
							end
						elseif WeaponEquipped == "Katana" then
							if ZanpakutoState >= 2 then
								local PathData = {Module = ClientModule, Skill = "WakizashiGhost"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, v, WeaponTable.GhostData.GhostDelay)

								task.delay(WeaponTable.GhostData.GhostDelay, function()
									local HitType = HitDetection:FocusTarget(Character, v, "NoVictimCone")
									local PositiveHit = CombatManager:ApplyDamage(Character, {[v] = HitType}, WeaponTable.GhostData)
									if PositiveHit and #PositiveHit > 0 then
										-- Apply anti heal to target
									end
								end)
							end
						elseif WeaponEquipped == "Fist" or WeaponEquipped == "Gauntlet" then
							if not Character:GetAttribute("AirDuration") and VacuumShunko then
								local BodyPosition = Instance.new("BodyPosition")
								BodyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
								BodyPosition.P = 40000
								BodyPosition.Position = (Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)).Position
								BodyPosition.Parent = v.HumanoidRootPart
								Debris:AddItem(BodyPosition, 0.3)
							end
						end
						
						if v:GetAttribute("VampireEcho") and PlayerData.EchoBiteData then
							local Magnitude = (v.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude
							if not NearestBite then
								NearestBite, BiteDistance = v, Magnitude
							else
								if Magnitude < BiteDistance then
									NearestBite, BiteDistance = v, Magnitude
								end
							end
						end
						
						if HellfreezeSlashes then
							task.delay(LightAttackData.TrueStunTime, function()
								SharedFunctions:CancelAnimation(v.Humanoid.Animator, "FrozenAnim", "SearchByReference")
							end)
						end
					end
					
					PassivesManager:ApplyPassive("Lifesteal", Character, PositiveHit)

					if PositiveHit then
						if HellfreezeSlashes then
							local PathData = {Module = ClientModule, Skill = "Hellfreeze"}
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "2", DamagedEntities, LightAttackData.TrueStunTime)
						end
						
						Character:SetAttribute("FeintTimer", 0)

						if PlayerData.WeaponEquipped == "Ruin" then
							local RuinPassiveData = SharedFunctions:DeepCopyTable(WeaponData.RuinAttackData.RuinPassiveData)

							local RuinStacks = Character:GetAttribute("RuinStacks")
							if not RuinStacks then
								RuinStacks = 1
							else
								RuinStacks += 1
								if RuinStacks > RuinPassiveData.MaxStacks then
									RuinStacks = RuinPassiveData.MaxStacks
								end
							end
							local RuinStackData = {
								Name = RuinPassiveData.Name;
								Value = RuinStacks;
								Duration = RuinPassiveData.Duration;
							}

							PassivesManager:ApplyDebuff(Character, {Character}, RuinStackData)
						end
						
						if PlayerData.WeaponEquipped == "Unohana" or PlayerData.WeaponEquipped == "UnohanaShikai" then
							local PathData = {Module = ClientModule, Skill = "UnohanaHeal"}
							local RenderDistance = 1000
							
							local Rate = 1 / 10
							local Accumulated = 0				
							
							if not PlayerData.UnohanaConnection then
								PlayerData.UnohanaStacks = 1
								PlayerData.UnohanaDuration = WeaponData.UnohanaAttackData.HealData.Duration
								PlayerData.UnohanaConnection = RunService.Heartbeat:Connect(function(DeltaTime)
									Accumulated += DeltaTime
									PlayerData.UnohanaDuration -= DeltaTime
									
									if PlayerData.UnohanaDuration <= 0 then
										PlayerData.UnohanaConnection:Disconnect()
										PlayerData.UnohanaConnection = nil
										PlayerData.UnohanaStacks = nil
										PlayerData.UnohanaDuration = nil
										Character:SetAttribute("UnohanaStacks", nil)
										NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "2")
										return
									end

									if Accumulated > Rate then
										Accumulated -= Rate

										local HealAmount = WeaponData.UnohanaAttackData.HealData.Heal / 10
										HealAmount *= PlayerData.UnohanaStacks
										local Health = Character.Humanoid.Health

										if Character:GetAttribute("HealingBuff") then
											HealAmount += HealAmount * Character:GetAttribute("HealingBuff")
										end
										if Character:GetAttribute("BloodyCanvas") then
											HealAmount *= Character:GetAttribute("BloodyCanvas")
										end
										
										if not Character:GetAttribute("AntiHeal") then
											Health += HealAmount
											if Health < Character.Humanoid.MaxHealth then
												Character.Humanoid.Health = Health
											else
												Character.Humanoid.Health = Character.Humanoid.MaxHealth
											end
										end
									end
								end)
								
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "1")
							else
								PlayerData.UnohanaDuration = WeaponData.UnohanaAttackData.HealData.Duration
								PlayerData.UnohanaStacks += 1
								if PlayerData.UnohanaStacks > WeaponData.UnohanaAttackData.HealData.MaxStacks then
									PlayerData.UnohanaStacks = WeaponData.UnohanaAttackData.HealData.MaxStacks
								end
							end
							
							Character:SetAttribute("UnohanaStacks", PlayerData.UnohanaStacks)
						end
					end

					if NearestImpale then
						Character.Humanoid.AutoRotate = false
						Character.Humanoid.WalkSpeed = 0
						Character.Humanoid.JumpHeight = 0

						SharedFunctions:CancelAnimation(Character.Humanoid.Animator, LightAttack.Name)

						local ImpaleData = PlayerData.ImpaleData[NearestImpale.Name]
						ImpaleData.Impales = 0

						local CharacterRemoving
						local ImpaleAttackData = PassivesManager:CreateM1AttackData(Character, WeaponData.SpearAttackData.BankaiData.ImpaleData, PlayerData, ClientData)

						EntityManager:ChangeState(NearestImpale, "TriggerTrueStun", ImpaleAttackData.StunProperties, Character)

						if NearestImpale:GetAttribute("EntityType") ~= "Menos" then
							NearestImpale.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)

							local Weld = Instance.new("Weld")
							Weld.C0 = CFrame.new(0, 0, -4.00000048, -1, 0, 8.74216397e-08, 0, 1, 0, -8.74239134e-08, 0, -1)
							Weld.Part0 = NearestImpale.HumanoidRootPart
							Weld.Part1 = Character.HumanoidRootPart
							Weld.Parent = NearestImpale
							Debris:AddItem(Weld, WeaponData.SpearAttackData.BankaiData.ImpaleData.TrueStunTime)

							if Player then
								CharacterRemoving = Player.CharacterRemoving:Connect(function()
									if CharacterRemoving then
										CharacterRemoving:Disconnect()
										CharacterRemoving = nil
									end
									if Weld.Parent then
										Weld:Destroy()
										Weld = nil
									end
								end)
							end

							local PlayerTarget = Players:GetPlayerFromCharacter(NearestImpale)
							for i, v in ipairs(NearestImpale:GetDescendants()) do
								if v:IsA("BasePart") and v:CanSetNetworkOwnership() then
									if PlayerTarget then
										v:SetNetworkOwner(PlayerTarget)
									else
										v:SetNetworkOwner(nil)
									end
								end
							end
						end

						Character:SetAttribute("IFrames", true)
						task.delay(0.73, function()
							Character:SetAttribute("IFrames", false)
							if CharacterRemoving then
								CharacterRemoving:Disconnect()
								CharacterRemoving = nil
							end
						end)

						local PathData = {Module = ClientModule, Skill = "Impaled"}
						local RenderDistance = 1000

						local ImpaledAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Spear.Bankai.Impaled)
						ImpaledAnimation:Play()
						ImpaledAnimation.KeyframeReached:Connect(function(KeyframeName)
							if KeyframeName == "HitFrame" then
								CombatManager:ApplyDamage(Character, {[NearestImpale] = "FrontalHit"}, ImpaleAttackData)
								Ragdoll:Enable(NearestImpale)
								task.delay(WeaponData.SpearAttackData.BankaiData.ImpaleData.TrueStunTime, function()
									Ragdoll:Disable(NearestImpale, "UnconsciousCheck")
								end)

								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, NearestImpale)
							elseif KeyframeName == "AnimationEnd" then
								if CharacterRemoving then
									CharacterRemoving:Disconnect()
									CharacterRemoving = nil
								end

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
					end
					
					if NearestBite then
						PassivesManager:RemoveDebuff(Character, {NearestBite}, PlayerData.EchoBiteData.DebuffData)
						
						Character.Humanoid.AutoRotate = false
						Character.Humanoid.WalkSpeed = 0
						Character.Humanoid.JumpHeight = 0

						SharedFunctions:CancelAnimation(Character.Humanoid.Animator, LightAttack.Name)

						local CharacterRemoving
						local BiteAttackData = PassivesManager:CreateM1AttackData(Character, PlayerData.EchoBiteData, PlayerData, ClientData)

						EntityManager:ChangeState(NearestBite, "TriggerTrueStun", BiteAttackData.StunProperties, Character)

						if NearestBite:GetAttribute("EntityType") ~= "Menos" then
							NearestBite.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(-0.0791625977, 0.0127067566, -3.17485046, -1, 0, 0, 0, 1, 0, 0, 0, -1)

							local Weld = Instance.new("Weld")
							Weld.C0 = CFrame.new(-0.0791625977, -0.0127067566, -3.17485046, -1, 0, 0, 0, 1, 0, 0, 0, -1)
							Weld.Part0 = Character.HumanoidRootPart
							Weld.Part1 = NearestBite.HumanoidRootPart
							Weld.Parent = NearestBite
							Debris:AddItem(Weld, BiteAttackData.StunProperties.TrueStunTime)

							if Player then
								CharacterRemoving = Player.CharacterRemoving:Connect(function()
									if CharacterRemoving then
										CharacterRemoving:Disconnect()
										CharacterRemoving = nil
									end
									if Weld.Parent then
										Weld:Destroy()
										Weld = nil
									end
								end)
							end

							local PlayerTarget = Players:GetPlayerFromCharacter(NearestBite)
							for i, v in ipairs(NearestBite:GetDescendants()) do
								if v:IsA("BasePart") then
									if PlayerTarget then
										v:SetNetworkOwner(PlayerTarget)
									else
										v:SetNetworkOwner(nil)
									end
								end
							end
						end

						Character:SetAttribute("IFrames", true)
						task.delay(0.86, function()
							Character:SetAttribute("IFrames", false)
							if CharacterRemoving then
								CharacterRemoving:Disconnect()
								CharacterRemoving = nil
							end
						end)
						
						local ClientVampireRes = ReplicatedStorage.Modules.ClientModules.Res.ClientVampireRes
						local PathData = {Module = ClientVampireRes, Skill = "Bite"}
						local ClientPathData = {Module = ClientVampireRes, Skill = "HealedIndicator"}
						local RenderDistance = 1000
						
						local EchoBiteAnimation = Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.ResAnimations.Vampire.LightAttackEchoBite)
						EchoBiteAnimation:Play()
						EchoBiteAnimation.KeyframeReached:Connect(function(KeyframeName)
							if KeyframeName == "HitFrame" then
								CombatManager:ApplyDamage(Character, {[NearestBite] = "FrontalHit"}, BiteAttackData)
								
								if not Character:GetAttribute("AntiHeal") then
									local Health = Character.Humanoid.Health
									Health += BiteAttackData.Health
									if Health < Character.Humanoid.MaxHealth then
										Character.Humanoid.Health = Health
									else
										Character.Humanoid.Health = Character.Humanoid.MaxHealth
									end

									if PlayerData.BankaiActiveData then
										PlayerData.BankaiActiveData.Healing += BiteAttackData.Health
										
										if Player then
											NetworkManager.FireClient(Player, Character, "ClientEffects", -1, ClientPathData, "On", PlayerData.BankaiActiveData.Healing)
										end
									end
								end
								
								Ragdoll:Enable(NearestBite)
								task.delay(BiteAttackData.TrueStunTime, function()
									Ragdoll:Disable(NearestBite, "UnconsciousCheck")
								end)
								
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, NearestBite)
							elseif KeyframeName == "AnimationEnd" then
								if CharacterRemoving then
									CharacterRemoving:Disconnect()
									CharacterRemoving = nil
								end
								
								Character:SetAttribute("IFrames", false)
								
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
					end
					
					if Combo >= 6 and not NearestImpale and not NearestBite then					
						for _, v in pairs(DamagedEntities) do
							if WeaponEquipped == "Nnoitra" then
								Ragdoll:Enable(v)
								task.delay(LightAttackData.TrueStunTime, function()
									Ragdoll:Disable(v, "UnconsciousCheck")
								end)
							else
								KnockbackModule:Knockback(Character, v, 40)
							end
						end
					end
				else
					if BloodArt then
						if not Character:GetAttribute("BankaiFighter") then
							local BloodMeter = Character:GetAttribute("BloodMeter")
							BloodMeter -= BloodArt

							if BloodMeter >= 0 then
								Character:SetAttribute("BloodMeter", BloodMeter)
							else
								Character:SetAttribute("BloodMeter", 0)

								local Health = Character.Humanoid.Health
								Health += BloodMeter
								if Health > 1 then
									Character.Humanoid.Health = Health
								else
									Character.Humanoid.Health = 1
								end
								LightAttackData.NoBloodRestore = true
							end
						end
					end
				end

				if WeaponEquipped == "Ruin" and ZanpakutoState >= 2 and ClientData.BoneKing then
					local PathData = {Module = ClientModule, Skill = "RuinRes"}
					local RenderDistance = 1000
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Combo - 1)
				end
				
				if Character:GetAttribute("PaintItBlackBuff") then
					local PathData = {Module = ClientModule, Skill = "PaintItBlack"}
					local RenderDistance = 1000
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Combo - 1)
				end

				if Combo >= 6 and WeaponEquipped == "Nnoitra" then
					local PathData = {Module = ReplicatedStorage.Modules.ClientModules.ClientShikaiCriticals, Skill = "Nnoitra"}
					local RenderDistance = 1000
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "5thM1")
				end

				local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds[WeaponEquipped .. "Swing"]:Clone()
				LightAttackSound.PlayOnRemove = true
				LightAttackSound.Parent = Character.HumanoidRootPart
				LightAttackSound:Destroy()
				LightAttackSound = nil
			end
			
			PassivesManager:PlayCreationAnimations(Character, PlayerData)
		elseif KeyframeName == "FeintStart" then
			PlayerData.AllowFeint = true
		elseif KeyframeName == "FeintEnd" then
			PlayerData.AllowFeint = false

			if not TrailBlacklist[WeaponEquipped] then
				local PathData = {Module = HitEffectClient, Skill = "WeaponTrail"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)
			end

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
end

Attacks.Starrk = function(Character, StateMachine, WeaponTable, PlayerData, ClientData)
	local Player = Players:GetPlayerFromCharacter(Character)
	local WeaponEquipped = PlayerData.WeaponEquipped
	local WeaponAnimations = CombatAnimations[WeaponEquipped]
	local LightAttackData = PassivesManager:CreateM1AttackData(Character, WeaponTable, PlayerData, ClientData)
	local CeroStats = GetStats(Player, Character)
	
	local PathData = {Module = ClientModule, Skill = "Starrk"}
	local ChargePath = {Module = ClientModule, Skill = "StarrkCharge"}
	local ScreenShakePath = {Module = ClientModule, Skill = "CeroScreenShake"}
	
	Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 10
	Character.Humanoid.JumpHeight = 0

	local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ComboTimer")
	if TimeDifference >= 1500 or Character:GetAttribute("Combo") >= 6 then 
		--Character:SetAttribute("Combo", 1)
	end
	Character:SetAttribute("ComboTimer", DateTime.now().UnixTimestampMillis)
	
	if Player then
		ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
	else
		SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Dash", "SearchByReference")
	end
	
	local Combo = Character:GetAttribute("Combo")
	local Ammo = Character:GetAttribute("Ammo")
	if not Ammo then
		Ammo = LightAttackData.Ammo
	end
	
	if Ammo <= 0 then
		Character:SetAttribute("Ammo", LightAttackData.Ammo)
		
		local StunData = {
			TrueStunTime = 0,
			SoftStunTime = WeaponData.StarrkAttackData.LightAttack.ReloadTime,
			StunAnimation = "None",
		}
		
		StunData.SoftStunTime -= CeroStats.Speed * LightAttackData.CeroSpeed
		local Percent = WeaponData.StarrkAttackData.LightAttack.ReloadTime / StunData.SoftStunTime
		
		local ReloadAnimation = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations.Reload)
		ReloadAnimation:Play()
		ReloadAnimation:AdjustSpeed(Percent)
		
		StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData, Character, "NoComboReset")
		
		local ReloadPath = {Module = ClientModule, Skill = "StarrkReload"}
		NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ReloadPath, CeroStats, StunData.SoftStunTime)
		return
	end
	
	NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ChargePath, CeroStats)
	
	LightAttackData.Damage += (CeroStats.Kendo / LightAttackData.CeroKendo) + (CeroStats.Hakuda / LightAttackData.CeroHakuda)
	LightAttackData.Properties.Range += CeroStats.Kido * LightAttackData.CeroKidoRange
	LightAttackData.Properties.Width += CeroStats.Kido / LightAttackData.CeroKidoWidth
	LightAttackData.Properties.Height += CeroStats.Kido / LightAttackData.CeroKidoWidth

	local AttackSpeed = PassivesManager:ApplyAttackSpeed(Character, PlayerData, ClientData)
	local LightAttack = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations["LightAttack" .. Combo])
	LightAttack:Play()
	LightAttack:AdjustSpeed(AttackSpeed)

	Combo += 1
	Character:SetAttribute("Combo", Combo)

	local PreM1PassiveCount = 0
	local PreM1Passives = PassivesManager:RequestPassives(Character).PreM1Passives
	for i, v in pairs(PreM1Passives) do
		PreM1PassiveCount += 1
	end

	LightAttack.KeyframeReached:Connect(function(KeyframeName)
		if KeyframeName == "HitFrame" then			
			Ammo -= 1
			Character:SetAttribute("Ammo", Ammo)
			
			local SpawnPoint = Character.HumanoidRootPart.CFrame

			if PreM1PassiveCount > 0 then
				local IncreasedRangeProperties = {
					Range = LightAttackData.Properties.Range + 6;
					Width = LightAttackData.Properties.Width + 4;
					Height = LightAttackData.Properties.Height + 5;
					Length = LightAttackData.Properties.Length;
				}

				--local PreHitDetection = HitDetection:SphereMagnitude(Character, SpawnPoint, IncreasedRangeProperties)
				local PreHitDetection = HitDetection:GetPartBoundsInBox(Character, SpawnPoint, IncreasedRangeProperties)
				if PreHitDetection then
					PassivesManager:ApplyPreM1Passives(Character, PreHitDetection, ClientData)
				end
			end
			--local DetectedEntities = HitDetection:SphereMagnitude(Character, SpawnPoint, LightAttackData.Properties)
			local DetectedEntities = HitDetection:GetPartBoundsInBox(Character, SpawnPoint, LightAttackData.Properties)
			if DetectedEntities then
				local PositiveHit
				local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
				for i, v in ipairs(DamagedEntities) do
					PositiveHit = true
					PassivesManager:ApplyPassive("DuelistsDance", Character, v)
					PassivesManager:ApplyM1Passives(Character, v, PlayerData)
				end
				
				if CeroStats.HighestStat == "Healing" then
					PassivesManager:ApplyDebuff(Character, DamagedEntities, LightAttackData.DebuffData)
				end
				
					--[[local SlowData = {
						Duration = 4;
						Tier = 3;
					}

					PassivesManager:Slowed(Character, DamagedEntities, SlowData)]]
				if Combo >= 6 then
						--[[for _, v in pairs(DamagedEntities) do
							KnockbackModule:Knockback(Character, v, 40)
						end]]
				end
			end
			
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, SpawnPoint, CeroStats, LightAttackData.Properties)
			if Player then
				NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, ScreenShakePath)
			end

			local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds[WeaponEquipped .. "Swing"]:Clone()
			LightAttackSound.PlayOnRemove = true
			LightAttackSound.Parent = Character.HumanoidRootPart
			LightAttackSound:Destroy()
			LightAttackSound = nil
		elseif KeyframeName == "FeintStart" then
			PlayerData.AllowFeint = true

			local Sound = ReplicatedStorage.Assets.Sounds.StarrkEquip
			local EquipSound = Sound:Clone()
			EquipSound.PlayOnRemove = true
			EquipSound.Parent = Character.HumanoidRootPart
			EquipSound:Destroy()
			EquipSound = nil
		elseif KeyframeName == "FeintEnd" then
			PlayerData.AllowFeint = false
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
end

Attacks.Bambietta = function(Character, StateMachine, WeaponTable, PlayerData, ClientData)
	local Player = Players:GetPlayerFromCharacter(Character)
	local WeaponEquipped = PlayerData.WeaponEquipped
	local WeaponAnimations = CombatAnimations[WeaponEquipped]
	local LightAttackData = PassivesManager:CreateM1AttackData(Character, WeaponTable, PlayerData, ClientData)

	Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 2
	Character.Humanoid.JumpHeight = 0

	local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ComboTimer")
	if TimeDifference >= 1500 or Character:GetAttribute("Combo") >= 6 then 
		Character:SetAttribute("Combo", 1)
	end
	Character:SetAttribute("ComboTimer", DateTime.now().UnixTimestampMillis)

	local Combo = Character:GetAttribute("Combo")

	ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
	
	local BambiettaTimer = PlayerData.BambiettaTimer or 0
	local BambiettaTimeDifference = DateTime.now().UnixTimestampMillis - BambiettaTimer
	
	local LightAttackToggled = Character:GetAttribute("LightAttackToggled")
	local ClosestPlayerFromMouse 
	if LightAttackToggled and BambiettaTimeDifference >= LightAttackData.AutotrackingCD * 1000 then
		ClosestPlayerFromMouse = SharedFunctions:GetTargetByMouse(Player, WeaponTable.MouseRange, 50,  nil, "PartyBlacklist", "UnconsciousBlacklist")
	end
	
	if Character:GetAttribute("ZanpakutoState") >= 2 then
		LightAttackData.TrueDamage = true
	end
	
	local AttackSpeed = PassivesManager:ApplyAttackSpeed(Character, PlayerData, ClientData)
	local LightAttack = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations["LightAttack" .. Combo])
	LightAttack:Play()
	LightAttack:AdjustSpeed(AttackSpeed)

	Combo += 1
	Character:SetAttribute("Combo", Combo)

	local PreM1PassiveCount = 0
	local PreM1Passives = PassivesManager:RequestPassives(Character).PreM1Passives
	for i, v in pairs(PreM1Passives) do
		PreM1PassiveCount += 1
	end
	
	local SparksData = {Module = ClientModule, Skill = "BambiettaSparks"}
	local PathData = {Module = ClientModule, Skill = "Bambietta"}
	local ScreenShakePath = {Module = ClientModule, Skill = "BambiettaScreenShake"}
	
	local Ammo = Character:GetAttribute("Ammo") or LightAttackData.Ammo
	
	LightAttack.KeyframeReached:Connect(function(KeyframeName)
		if KeyframeName == "HitFrame" then
			if ClosestPlayerFromMouse and ClosestPlayerFromMouse:FindFirstChild("HumanoidRootPart") and Ammo > 0 then
				Ammo -= 1
				Character:SetAttribute("Ammo", Ammo)
				if Ammo <= 0 then
					PlayerData.BambiettaTimer = DateTime.now().UnixTimestampMillis
					task.delay(LightAttackData.AutotrackingCD, function()
						Character:SetAttribute("Ammo", LightAttackData.Ammo)
					end)
				end
				
				LightAttackData.BlockDamage = LightAttackData.ToggledBlockDamage
				LightAttackData.DeflectDamage = LightAttackData.ToggledDeflectDamage
				LightAttackData.Damage = LightAttackData.ToggledDamage
				
				local ReiatsuBall = ServerStorage.Assets.Specs.Bambietta.ReiatsuBall:Clone()
				ReiatsuBall.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
				ReiatsuBall.Parent = workspace.Effects[Character.Name]
				
				local RocketPropulsion = Instance.new("RocketPropulsion")
				RocketPropulsion.ThrustD = 150
				RocketPropulsion.TurnP = 0
				RocketPropulsion.TargetRadius = 9
				RocketPropulsion.CartoonFactor = 0.7
				RocketPropulsion.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				RocketPropulsion.MaxSpeed = WeaponTable.Speed

				RocketPropulsion.Target = ClosestPlayerFromMouse.HumanoidRootPart
				RocketPropulsion.Parent = ReiatsuBall
				RocketPropulsion:Fire()
				
				--local Rocket = Projectile:RocketXZ(ReiatsuBall, ClosestPlayerFromMouse.HumanoidRootPart, WeaponTable.Speed, 9)
				local ReachedConnection
				ReachedConnection = RocketPropulsion.ReachedTarget:Connect(function()
					ReachedConnection:Disconnect()
					ReachedConnection = nil
					
					local SpawnPoint = ReiatsuBall.CFrame
					ReiatsuBall:Destroy()
					ReiatsuBall = nil
					
					local DetectedEntities = HitDetection:GetPartBoundsInRadius(Character, SpawnPoint.Position, LightAttackData.Properties.Range)
					--local DetectedEntities = HitDetection:Magnitude(Character, SpawnPoint.Position, LightAttackData.Properties.Range)
					if DetectedEntities then
						local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
						for i, v in ipairs(DamagedEntities) do
							PassivesManager:ApplyPassive("DuelistsDance", Character, v)
							PassivesManager:ApplyM1Passives(Character, v, PlayerData)

							KnockbackModule:Repel(Character, SpawnPoint.Position, v, 40)
							Ragdoll:Enable(v)
							task.delay(LightAttackData.TrueStunTime, function()
								Ragdoll:Disable(v, "UnconsciousCheck")
							end)

							local PlayerEntity = Players:GetPlayerFromCharacter(v)
							if PlayerEntity then
								NetworkManager.FireClient(PlayerEntity, PlayerEntity.Character, "ClientEffects", -1, ScreenShakePath)
							end
						end
					end
					
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, SparksData, SpawnPoint)
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, SpawnPoint)
				end)
				
				local LightAttackSound = ReplicatedStorage.Assets.Effects.Bambietta.Sounds.ReiatsuBall:Clone()
				LightAttackSound.PlayOnRemove = true
				LightAttackSound.Parent = Character.HumanoidRootPart
				LightAttackSound:Destroy()
				LightAttackSound = nil
			else
				local SpawnPoint = Character.HumanoidRootPart.CFrame * CFrame.new(0, -2, -13)

				if PreM1PassiveCount > 0 then
					local IncreasedRangeProperties = {
						Range = LightAttackData.Properties.Range + 6;
						Width = LightAttackData.Properties.Width + 4;
						Height = LightAttackData.Properties.Height + 5;
						Length = LightAttackData.Properties.Length;
					}

					--local PreHitDetection = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, IncreasedRangeProperties)
					local PreHitDetection = HitDetection:GetPartBoundsInBox(Character, Character.HumanoidRootPart.CFrame, IncreasedRangeProperties, "NoVictimCone")
					if PreHitDetection then
						PassivesManager:ApplyPreM1Passives(Character, PreHitDetection, ClientData)
					end
				end
				--local DetectedEntities = HitDetection:Magnitude(Character, SpawnPoint.Position, LightAttackData.Properties.Range)
				local DetectedEntities = HitDetection:GetPartBoundsInRadius(Character, SpawnPoint.Position, LightAttackData.Properties.Range)
				if DetectedEntities then
					local PositiveHit
					local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
					for i, v in ipairs(DamagedEntities) do
						PositiveHit = true

						PassivesManager:ApplyPassive("DuelistsDance", Character, v)
						PassivesManager:ApplyM1Passives(Character, v, PlayerData)

						KnockbackModule:Repel(Character, SpawnPoint.Position, v, 40)
						Ragdoll:Enable(v)
						task.delay(LightAttackData.TrueStunTime, function()
							Ragdoll:Disable(v, "UnconsciousCheck")
						end)
						
						local PlayerEntity = Players:GetPlayerFromCharacter(v)
						if PlayerEntity then
							NetworkManager.FireClient(PlayerEntity, PlayerEntity.Character, "ClientEffects", -1, ScreenShakePath)
						end
					end
				end

				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, SpawnPoint)
				if Player then
					NetworkManager.FireClient(Player, Player.Character, "ClientEffects", -1, ScreenShakePath)
				end

				PassivesManager:PlayCreationAnimations(Character, PlayerData)	
			end
			
			local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds[WeaponEquipped .. "Swing"]:Clone()
			LightAttackSound.PlayOnRemove = true
			LightAttackSound.Parent = Character.HumanoidRootPart
			LightAttackSound:Destroy()
			LightAttackSound = nil
		elseif KeyframeName == "FeintStart" then
			PlayerData.AllowFeint = true
			if not LightAttackToggled then
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, SparksData, Character.HumanoidRootPart.CFrame)
			end
		elseif KeyframeName == "FeintEnd" then
			PlayerData.AllowFeint = false
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
end

local LightAttacks = {}

function LightAttacks:LightAttack(Character, StateMachine, WeaponTable, PlayerData, ClientData, NPCDebuffData)
	if Attacks[PlayerData.WeaponEquipped] then
		Attacks[PlayerData.WeaponEquipped](Character, StateMachine, WeaponTable, PlayerData, ClientData, NPCDebuffData)
	else
		Attacks.Default(Character, StateMachine, WeaponTable, PlayerData, ClientData, NPCDebuffData)
	end
end

return LightAttacks
