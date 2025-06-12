local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Chat = game:GetService("Chat")

local Animations = ReplicatedStorage.Assets.Animations
local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations
local Sounds = ReplicatedStorage.Assets.Sounds

local HitDetection = require(ServerStorage.Modules.Utility.HitDetection)
local CombatManager = require(ServerStorage.Modules.Managers.CombatManager)
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local WeaponData = require(ServerStorage.Modules.Utility.WeaponData)
local KnockbackModule = require(ServerStorage.Modules.Utility.Knockback)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local Ragdoll = require(ServerStorage.Modules.Utility.Ragdoll)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local PartyManager = require(ServerStorage.Modules.Managers.PartyManager)
local RankManager = require(ServerStorage.Modules.Managers.RankManager)
local SkillModule = require(ServerStorage.Modules.SkillModules.Skills.ServerSkills)
local ClashSystem = require(ReplicatedStorage.Modules.Shared.ClashSystem)
local CriticalModule = require(ServerStorage.Modules.SkillModules.Shikais.ShikaiCriticals)
local AntiCheatManager = require(ServerStorage.Modules.Managers.AntiCheatManager)
local InnerWorlds = require(ServerStorage.Modules.Utility.InnerWorlds)
local NPCManager = require(ServerStorage.Modules.Managers.NPCManager)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local MaskData = require(ServerStorage.Modules.Utility.MaskData)
local ZanpakutoWeapons = require(ServerStorage.Modules.Utility.ZanpakutoWeapons)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local ShikaiWeapons = require(ServerStorage.Modules.SkillModules.Shikais.ShikaiWeapons)
local InventoryManager = require(ServerStorage.Modules.Managers.InventoryManager)
local TradeablesData = require(ServerStorage.Modules.Utility.TradeablesData)
local SkillData = require(ServerStorage.Modules.Utility.SkillData)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local ResAccessories = require(ServerStorage.Modules.Utility.ResAccessories)
local FactionManager = require(ServerStorage.Modules.Managers.FactionManager)
local JailManager = require(ServerStorage.Modules.Managers.JailManager)
local PositionTitles = require(ServerStorage.Modules.Utility.FactionPositions)
local HairWhitelist = require(ServerStorage.Modules.Utility.HairWhitelist)
local DivisionManager = require(ServerStorage.Modules.Managers.DivisionManager)
local ColorWhitelist = require(ServerStorage.Modules.Utility.ColorWhitelist)
local Projectile = require(ServerStorage.Modules.Utility.Projectile)
local Webhooks = require(ServerStorage.Modules.Utility.Webhooks)
local ItemModule = require(ServerStorage.Modules.SkillModules.Items.ServerItems)
local Teleports = require(ServerStorage.Modules.Utility.Teleports)
local LightAttacks = require(ServerStorage.Modules.Utility.LightAttacks)
local AdminWhitelists = require(ServerStorage.Modules.Utility.AdminWhitelist)
local Penalties = require(ServerStorage.Modules.Utility.Penalties)
local PlayerBonus = require(ServerStorage.Modules.Utility.PlayerBonus)
local ServerSkillReqs = require(ServerStorage.Modules.Utility.ServerSkillReqs)
local SpecData = require(ServerStorage.Modules.Utility.SpecData)
local AirtimeManager = require(ServerStorage.Modules.Managers.AirtimeManager)
local BankaiWeapons = require(ServerStorage.Modules.SkillModules.Shikais.BankaiWeapons)
local ZanpakutoNames = require(ServerStorage.Modules.Utility.ZanpakutoNames)
local ResWeapons = require(ServerStorage.Modules.SkillModules.Res.ResWeapons)
local SpiritBowData = require(ServerStorage.Modules.Utility.SpiritBowData)
local Quests = require(ServerStorage.Modules.Utility.Quests)
local QuincyMedallions = require(ServerStorage.Modules.Utility.QuincyMedallions)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)
local BountyBoardManager = require(ServerStorage.Modules.Managers.BountyBoardManager)
local DamageTracker = require(ServerStorage.Modules.Utility.DamageTracker)
local VollstandigAccessories = require(ServerStorage.Modules.Utility.VollstandigAccessories)

local WebhookChannel = "FactionManager"
local ItemWebhookChannel = "ItemUses"
local BankaiPatrolChannel = "BankaiPatrol"

local RankedLeaderboards
local TYPETEST = StatData.TYPETEST
if TYPETEST then
	RankedLeaderboards = DataStoreService:GetOrderedDataStore("TestPlaceRankedStore")
else
	RankedLeaderboards = DataStoreService:GetOrderedDataStore(StatData.RankedLeaderboardStore)
end

local ClientSpecs = ReplicatedStorage.Modules.ClientModules.ClientSpecs
local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
local HitEffectClient = ReplicatedStorage.Modules.ClientModules.ClientHitEffects
local ClientShikaiProgress = ReplicatedStorage.Modules.ClientModules.ClientShikaiProgress
local FlashstepClient = ReplicatedStorage.Modules.ClientModules.FlashstepClient
local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
local ClientLightAttacks = ReplicatedStorage.Modules.ClientModules.ClientLightAttacks

local VollstandigAnimations = ReplicatedStorage.Assets.VollstandigAnimations

local FlashstepMasteryIndex = {
	[0] = StatData.Flashstep,
	[1] = StatData.FlashstepMastery1,
	[2] = StatData.FlashstepMastery2,
	[3] = StatData.PerfectFlashstep,
	[4] = StatData.EspadaSonido,
	[5] = StatData.SoulStep
}

local HollowRace = {
	Vastocar = true;
	VastoLorde = true;
	Adjuchas = true;
	Menos = true;
	Fishbone = true;
	Frisker = true;
	Hollow = true;
}

local AllowedShikaiRelease = {
	Katana = true;
	Unohana = true;
	Data = true;
	Fist = true;
	Vv = true;
}

local SheatheSoundBlacklist = {
	Fist = true;
	Bambietta = true;
	Grimmjow = true;
	Drakos2 = true;
}

local IdleBlacklist = {
	Bambietta = true;
}

local MultiIdles = {
	Starrk = true;
	Nozarashi = true;
	Schwert = true;
}

local PlayerData = {}

-- Repeat functions so i dont have to copy and paste same lines in 20 different states

local function DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function TrackDamage(Character, AttackOwner, Damage, AttackData, HierroBlutAbsorbedDamage)
	local Player = Players:GetPlayerFromCharacter(AttackOwner)
	local CurrentPlayer = Players:GetPlayerFromCharacter(Character)
	if Player and Character:GetAttribute("CurrentState") ~= "Unconscious" and AttackOwner:GetAttribute("EntityType") ~= "Menos" then
		if not Character:GetAttribute("Zombification") and not AttackOwner:GetAttribute("Zombification") then
			DamageTracker:Track(Character, AttackOwner, Damage)
			DamageTracker:Track(Character, AttackOwner, Damage, "Elo")
		end
		
		local CurrentProfile = DataManager:RequestProfile(CurrentPlayer)
		local Profile = DataManager:RequestProfile(Player)
		local Race = Profile.ClientData.Race
		local UltAmount = Profile.ClientData.BankaiMeter
		local MaxBankaiMeter = Profile.ClientData.MaxBankaiMeter
		
		local ChargeRate = StatData.BankaiChargeRate
		if FactionManager:GladiatorActive() then
			ChargeRate = StatData.GladiatorBankaiChargeRate
		end
		
		local BankaiMeterGain = (Damage + HierroBlutAbsorbedDamage) * ChargeRate
		local AccessoryMeterGain = AttackOwner:GetAttribute("AccessoryMeterGain")
		if AccessoryMeterGain then
			BankaiMeterGain += BankaiMeterGain * AccessoryMeterGain
		end
		
		local OpposingFaction = true
		if StatData.Factions[CurrentProfile.ClientData.Race] == StatData.Factions[Profile.ClientData.Race] then
			--OpposingFaction = nil
		end
		
		local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.BankaiTimer
		
		local BankaiCooldown = StatData.BankaiCooldown * 60
		if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
			BankaiCooldown = StatData.ResCooldown * 60
		end
		
		local BankaiUnlocked = Profile.ClientData.BankaiUnlocked == true or Profile.ClientData.StolenBankai

		if BankaiUnlocked and OpposingFaction then
			if TimeDifference >= BankaiCooldown then
				if AttackOwner:GetAttribute("ZanpakutoState") <= 1 then
					if UltAmount + BankaiMeterGain < MaxBankaiMeter then
						UltAmount += BankaiMeterGain

						Profile.ClientData.BankaiMeter = UltAmount
						AttackOwner:SetAttribute("BankaiMeter", UltAmount)
					else
						Profile.ClientData.BankaiMeter = MaxBankaiMeter
						AttackOwner:SetAttribute("BankaiMeter", AttackOwner:GetAttribute("MaxBankaiMeter"))
					end
				elseif AttackOwner:GetAttribute("ZanpakutoState") == 2 then
					if Race == "Vastocar" then
						local SecondBankaiMeter = AttackOwner:GetAttribute("SecondBankaiMeter")
						if SecondBankaiMeter + BankaiMeterGain < AttackOwner:GetAttribute("MaxSecondBankaiMeter") then
							SecondBankaiMeter += BankaiMeterGain
							AttackOwner:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
						else
							AttackOwner:SetAttribute("SecondBankaiMeter", AttackOwner:GetAttribute("MaxSecondBankaiMeter"))
						end
					end
				end
			end
			
			if AttackOwner:GetAttribute("Kenpachi") then
				local UltAmount = AttackOwner:GetAttribute("BankaiMeter")
				local MaxBankaiMeter = AttackOwner:GetAttribute("MaxBankaiMeter")

				BankaiMeterGain *= SpecData.Nozarashi.DamageToMeterRate

				if UltAmount + BankaiMeterGain < MaxBankaiMeter then
					UltAmount += BankaiMeterGain
					AttackOwner:SetAttribute("BankaiMeter", UltAmount)
				else
					AttackOwner:SetAttribute("BankaiMeter", AttackOwner:GetAttribute("MaxBankaiMeter"))
				end
			elseif AttackOwner:GetAttribute("Unohana") and AttackData.WeaponAttack then
				local UltAmount = AttackOwner:GetAttribute("BankaiMeter")
				local MaxBankaiMeter = AttackOwner:GetAttribute("MaxBankaiMeter")

				BankaiMeterGain *= SpecData.Unohana.MeterStealRate

				if UltAmount + BankaiMeterGain < MaxBankaiMeter then
					UltAmount += BankaiMeterGain
					AttackOwner:SetAttribute("BankaiMeter", UltAmount)
				else
					AttackOwner:SetAttribute("BankaiMeter", AttackOwner:GetAttribute("MaxBankaiMeter"))
				end

				if CurrentProfile.ClientData.BankaiUnlocked then
					local LostUltAmount = Character:GetAttribute("BankaiMeter")
					LostUltAmount -= BankaiMeterGain

					if LostUltAmount > 0 then
						CurrentProfile.ClientData.BankaiMeter = LostUltAmount
						Character:SetAttribute("BankaiMeter", LostUltAmount)
					else
						CurrentProfile.ClientData.BankaiMeter = 0
						Character:SetAttribute("BankaiMeter", 0)
					end
				end
			end
		end
		
		if OpposingFaction then
			if Race == "Visored" then
				local SecondBankaiMeter = AttackOwner:GetAttribute("SecondBankaiMeter")
				local MeterGain = (Damage + HierroBlutAbsorbedDamage)
				local HealthVariant = AttackOwner:GetAttribute("VisoredHealth") or (AttackOwner:GetAttribute("VisoredDownsideHealth") and AttackOwner:GetAttribute("VisoredMastered") == true)

				if not AttackOwner:GetAttribute("VisoredActive") then -- or HealthVariant	
					if SecondBankaiMeter + MeterGain < AttackOwner:GetAttribute("MaxSecondBankaiMeter") then
						if HealthVariant then
							MeterGain *= 0.15
						end
						SecondBankaiMeter += MeterGain
						AttackOwner:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
					else
						AttackOwner:SetAttribute("SecondBankaiMeter", AttackOwner:GetAttribute("MaxSecondBankaiMeter"))
					end
				end
			elseif StatData.Factions[Race] == "Quincy" and Profile.ClientData.LetztStil then
				local SecondBankaiMeter = AttackOwner:GetAttribute("SecondBankaiMeter")
				local MeterGain = (Damage + HierroBlutAbsorbedDamage)

				if not AttackOwner:GetAttribute("LetztStilActive") then	
					if SecondBankaiMeter + MeterGain < AttackOwner:GetAttribute("MaxSecondBankaiMeter") then
						SecondBankaiMeter += MeterGain
						AttackOwner:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
					else
						AttackOwner:SetAttribute("SecondBankaiMeter", AttackOwner:GetAttribute("MaxSecondBankaiMeter"))
					end
				end
			end
		end
	end
	
	--[[if Character:GetAttribute("VisoredActive") then
		local SecondBankaiMeter = Character:GetAttribute("SecondBankaiMeter")
		local MeterLoss = Damage
		MeterLoss *= 0.35
		SecondBankaiMeter -= MeterLoss

		if SecondBankaiMeter > 0 then
			Character:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
		else
			Character:SetAttribute("SecondBankaiMeter", 0)
		end
	end]]
	--[[if Character:GetAttribute("ZanpakutoState") == 2 then
		local BankaiMeter = Character:GetAttribute("BankaiMeter")
		local MeterLoss = Damage
		MeterLoss *= 0.35
		BankaiMeter -= MeterLoss

		if BankaiMeter > 0 then
			Character:SetAttribute("BankaiMeter", BankaiMeter)
		else
			Character:SetAttribute("BankaiMeter", 0)
		end
	end]]
	
	if Character:GetAttribute("CurrentState") ~= "Unconscious" and AttackOwner:GetAttribute("EntityType") ~= "Menos" then
		if Character:GetAttribute("DelayedDeath") then
			if AttackOwner.Name == Character:GetAttribute("DelayedDeathOwner") then
				local DelayedDeathDamage = Character:GetAttribute("DelayedDeath")
				DelayedDeathDamage += Damage
				Character:SetAttribute("DelayedDeath", DelayedDeathDamage)
			end
		end
	end
end

local function DamageTaken(Character, AttackData, AttackOwner, HitType)
	local Player = Players:GetPlayerFromCharacter(Character)
	local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
	local Profile = DataManager:RequestProfile(Player)
	
	local ImpactSound = AttackData.ImpactSound
	local Damage = AttackData.Damage
	local HierroBlutDamageAbsorbed = 0
	local HitEffect = AttackData.HitEffect
	
	if Damage > 0 and not AttackData.OvertimeAttack then
		FactionManager:DropCaptureItem(Player)
		FactionManager:DropKarakuraFlag(Player)
	end

	Damage, HierroBlutDamageAbsorbed = PassivesManager:ApplyActivePassives(Character, AttackData, AttackOwner, HitType, Profile.ClientData, PlayerData[Character.Name])
	
	if not AttackData.TrueDamage then
		if Character:GetAttribute("BlutVene") and Character:GetAttribute("BlutVene") > 0 and not Character:GetAttribute("BlutArterie") then
			HitEffect = "BlutVene"
			ImpactSound = ReplicatedStorage.Assets.SkillSounds.Quincy.BlutVeneHit
		elseif Character:GetAttribute("Hierro") then
			HitEffect = "Hierro"
			
			local RandomHierro = math.random(1, 5)
			ImpactSound = ReplicatedStorage.Assets.SkillSounds.Hollow["HierroImpact" .. RandomHierro]
		end
	end
	if (Character.Humanoid.Health - Damage) <= 1 then	
		Damage = 0
		Character.Humanoid.Health = 1
		EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
	end

	Character.Humanoid:TakeDamage(Damage)
	if AttackOwner ~= Character then
		TrackDamage(Character, AttackOwner, Damage, AttackData, HierroBlutDamageAbsorbed)
	end

	PlayerData[Character.Name].LastHitTime = DateTime.now().UnixTimestampMillis
	
	if Character:GetAttribute("Division11Sparring") then
		Character:SetAttribute("Division11Sparring", Damage) 
	end
	
	if Character:FindFirstChild("Head") then
		local BodyVelocity = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
		if BodyVelocity then
			BodyVelocity:Destroy()
			BodyVelocity = nil
		end
	end
	
	if not AttackData.NoHitEffect then
		if ImpactSound then
			if ImpactSound ~= "None" then
				local Impact = ImpactSound:Clone()
				Impact.PlayOnRemove = true
				Impact.Parent = Character.HumanoidRootPart
				Impact:Destroy()
				Impact = nil
			end
		else
			local Impact = Sounds["ImpactSound" .. math.random(1, 2)]:Clone()
			Impact.PlayOnRemove = true
			Impact.Parent = Character.HumanoidRootPart
			Impact:Destroy()
			Impact = nil
		end
		
		local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
		local RenderDistance = 1000
		NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, HitEffect, AttackOwner)
	end
	
	local Profile = DataManager:RequestProfile(Player)
	if PlayerData[Character.Name].HighSpeedConnection or Profile.ClientData.Race == "Vastocar" or Profile.ClientData.Race == "Visored" then
		local HealCutDuration = 5
		PlayerData[Character.Name].HighSpeedTimer = DateTime.now().UnixTimestampMillis
		Character:SetAttribute("HSPCut", true)
		task.delay(HealCutDuration, function()
			if PlayerData[Character.Name] and DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].HighSpeedTimer >= HealCutDuration * 995 then
				Character:SetAttribute("HSPCut", nil)
			end
		end)
	end
	
	if PlayerData[Character.Name].ExecutionHits and Character:GetAttribute("CurrentState") ~= "Execution" then
		EntityManager:ForceState(Character, "Execution")
	end
	if Character.Humanoid.Health <= Character.Humanoid.MaxHealth * 0.5 and Profile.ClientData.CeroKing then
		Profile.ClientData.CeroKing = nil
		SkillModule.CeroKing.SkillFunction(Character, nil, nil, PlayerData[Character.Name])
	end
end

local function PerfectFlashstep(Character, AttackOwner, FlashstepCFrame, AttackData)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Profile = DataManager:RequestProfile(Player)
	local Race = Profile.ClientData.Race
	
	local PathData = {Module = FlashstepClient, Skill = "Evaded"}
	local RenderDistance = 1000
	NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Race, FlashstepCFrame)
	
	local DisabledEnhancedSteps
	if AttackData and AttackData.DisabledEnhancedSteps then
		DisabledEnhancedSteps = true
	end
	
	if not DisabledEnhancedSteps then
		if Character:GetAttribute("EnhancedSteps") and AttackOwner then
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			Character:SetAttribute("IFrames", true)
			task.delay(SkillData["Enhanced Steps"].IFrameDuration, function()
				Character:SetAttribute("IFrames", false)
			end)

			AntiCheatManager:Teleport(Player, AttackOwner.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.2))
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Race, FlashstepCFrame)
		elseif Character:GetAttribute("HeavenlyRestriction") and AttackOwner then
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end

			Character:SetAttribute("IFrames", true)
			task.delay(SkillData["Heavenly Restriction"].IFrameDuration, function()
				Character:SetAttribute("IFrames", false)
			end)

			AntiCheatManager:Teleport(Player, AttackOwner.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.2))
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Race, FlashstepCFrame)
		end
	end
end

local function CounterSuccess(Character, StateMachine, AttackOwner, AttackData, SoftCounter)
	local CounterType = Character:GetAttribute("CounterType")
	local SoftCounterType = Character:GetAttribute("SoftCounterType")
	local SkillCounter
	if SoftCounter then
		SkillCounter = SkillModule[SoftCounterType]
	else
		SkillCounter = SkillModule[CounterType]
	end
	local ShikaiModule = PlayerData[Character.Name].ShikaiModule
	
	if CollectionService:HasTag(AttackOwner, Character.Name .. "EyeOfAKing") then
		SkillModule["Eye of a King"].CounterSuccess(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
		return
	end
	
	if Character:GetAttribute("FreundReflex") then
		SkillModule["Freund Reflex"].CounterSuccess(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
		return
	end
	
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
		SkillModule["Aversion Field"].CounterSuccess(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
		return
	end

	local CounterFunction
	if SkillCounter and SkillCounter.CounterSuccess then
		CounterFunction = SkillCounter.CounterSuccess
	elseif ShikaiModule and ShikaiModule["CounterSuccess"] then
		local ShikaiCounter = ShikaiModule["CounterSuccess"]
		if Character:GetAttribute("ZanpakutoState") >= 2 and ShikaiCounter.BankaiCounter then
			CounterFunction = ShikaiCounter.BankaiCounter(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
		else
			CounterFunction = ShikaiCounter.ShikaiCounter(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
		end
	end

	if CounterFunction then
		if SoftCounter then
			Character:SetAttribute("SoftCounterFrames", false)
			Character:SetAttribute("SoftCounterType", "string")
		else
			Character:SetAttribute("CounterFrames", false)
			Character:SetAttribute("CounterType", "string")
		end
		CounterFunction(Character, StateMachine, AttackOwner, PlayerData[Character.Name], AttackData)
	end
end

local function RunFunction(Character, StateMachine, PassedFunction)
	if typeof(PassedFunction) == "function" then
		PassedFunction(Character, StateMachine, PlayerData[Character.Name])
	end
end

local function Hierro(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Profile = DataManager:RequestProfile(Player)
	if table.find(Profile.UnlockedSkills, "Hierro") then
		if not PlayerData[Character.Name].HierroTimer then
			PlayerData[Character.Name].HierroTimer = 0
		end
		
		if not PlayerData[Character.Name].HierroEquipTimer then
			PlayerData[Character.Name].HierroEquipTimer = 0
		end
		if DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].HierroEquipTimer < 1000 then
			return
		end
		
		PlayerData[Character.Name].HierroEquipTimer = DateTime.now().UnixTimestampMillis
		
		local HierroTierData = {
			[1] = SkillData.Hierro;
			[2] = SkillData["Hierro Mastery"];
			[3] = SkillData["Hierro Mastery 2"];
		}

		local HierroTier = HierroTierData[PassivesManager:RequestPassives(Player).HierroTier]
		local HierroCooldown = HierroTier.Cooldown
		local HierroHits = HierroTier.HitAmount
		local HierroReduction = HierroTier.Reduction
		
		local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].HierroTimer
		if TimeDifference >= HierroCooldown * 1000 then
			if not Character:GetAttribute("Hierro") and not Character:GetAttribute("DamageReduction") then
				local ActivatePathData = {Module = ClientSkills, Skill = "HierroActivate"}
				local DeactivatePathData = {Module = ClientSkills, Skill = "HierroDeactivate"}
				local HierroIndicator = {Module = ClientSkills, Skill = "HierroIndicator"}
				local RenderDistance = 1000

				Character:SetAttribute("Hierro", HierroReduction)
				Character:SetAttribute("HierroHits", HierroHits)
				Character:SetAttribute("HierroTimer", 0)
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ActivatePathData)

				if Player then
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, HierroIndicator, "On")
				end

				local CharacterRemoving
				local CharacterDied
				local Connection
				Connection = Character:GetAttributeChangedSignal("HierroHits"):Connect(function()
					if Character and Character:FindFirstChild("HumanoidRootPart") then
						if not Character:GetAttribute("Hierro") then
							PlayerData[Character.Name].HierroTimer = DateTime.now().UnixTimestampMillis
							--Character:SetAttribute("Hierro", nil)
							--Character:SetAttribute("HierroHits", nil)

							if Connection then
								Connection:Disconnect()
								Connection = nil
							end
							if CharacterRemoving then
								CharacterRemoving:Disconnect()
								CharacterRemoving = nil
							end
							if CharacterDied then
								CharacterDied:Disconnect()
								CharacterDied = nil
							end

							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, DeactivatePathData)
						end
					else
						if Connection then
							Connection:Disconnect()
							Connection = nil
						end
						if CharacterRemoving then
							CharacterRemoving:Disconnect()
							CharacterRemoving = nil
						end
						if CharacterDied then
							CharacterDied:Disconnect()
							CharacterDied = nil
						end
					end
				end)

				if Player then
					CharacterRemoving = Player.CharacterRemoving:Connect(function()
						if Connection then
							Connection:Disconnect()
							Connection = nil
						end
						if CharacterRemoving then
							CharacterRemoving:Disconnect()
							CharacterRemoving = nil
						end
					end)
				else
					CharacterDied = Character.Humanoid.Died:Connect(function()
						if Connection then
							Connection:Disconnect()
							Connection = nil
						end
						if CharacterDied then
							CharacterDied:Disconnect()
							CharacterDied = nil
						end
					end)
				end
			else
				local Player = Players:GetPlayerFromCharacter(Character)

				Character:SetAttribute("Hierro", nil)
				Character:SetAttribute("HierroHits", 0)
				Character:SetAttribute("HierroHits", nil)

				if Player then
					local HierroIndicator = {Module = ClientSkills, Skill = "HierroIndicator"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, HierroIndicator, "Off")
				end
			end
		end
	end
end

local function SwapBlutMode(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Profile = DataManager:RequestProfile(Player)
	if table.find(Profile.UnlockedSkills, "Blut Vene") then
		local BlutTierData = {
			[1] = SkillData["Blut Vene"];
			[2] = SkillData["Blut Vene 2"];
			[3] = SkillData["Blut Vene 3"];
		}

		local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
		local BlutDamage = BlutTier.DamageBuff
		local BlutReiRegen = BlutTier.ReiatsuRegenBonus

		local BlutIndicator = {Module = ClientSkills, Skill = "BlutIndicator"}
		local RenderDistance = 1000
		
		if Character:GetAttribute("BlutArterie") then
			Character:SetAttribute("BlutArterie", nil)
			Character:SetAttribute("ArterieRegen", nil)
		else
			Character:SetAttribute("BlutArterie", BlutDamage)
			Character:SetAttribute("ArterieRegen", BlutReiRegen)
		end
		
		NetworkManager.FireClient(Player, Character, "ClientEffects", -1, BlutIndicator, "On")
	end
end

local ShinigamiData = {
	Idle = {
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
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
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto
				
				local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData
				
				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Draw" .. ClientData.Sheathe])
					DrawAnimation:Play()
					
					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon == "Fist" then
					IdleNum = 1
				elseif ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1
					
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = false
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 0
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = true
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.UnsheatheFunction then
							ZanpakutoData.UnsheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				end
				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end
				
				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end
				
				StateMachine:SetState("WeaponDrawn")
			end
		end,
		TriggerCarry = function(StateMachine, Character)
			StateMachine:PushState("Idle")
			StateMachine:SetState("Carrying")
			StateMachine:Trigger("Carry", StateMachine, Character)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			StateMachine:PushState("Idle")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,	
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Character).FlashstepMastery
			
			local Cooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			local MaxHealth = Character.Humanoid.MaxHealth
			local Health = Character.Humanoid.Health

			if Health <= MaxHealth * 0.8 then
				local HealthRange = (MaxHealth * 0.8) - 1
				local FlashstepCDRange = FlashstepMasteryIndex[FlashstepMasteries].Cooldown - FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				Cooldown = ScaledFlashstepCD
			end
			
			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end
			
			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= Cooldown and ReiatsuValue >= 0 then
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
		TriggerSkill = function(StateMachine, Character, ...)
			if not PlayerData[Character.Name].Carrying then
				StateMachine:SetState("Skill")
				StateMachine:Trigger("SkillPress", StateMachine, Character, ...)
			end
		end,
		TriggerHierro = function(StateMachine, Character, ...)
			Hierro(Character, ...)
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TriggerReset = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("Reset", StateMachine, Character)
		end,
		TriggerBankaiQuest = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiQuest", StateMachine, Character)
		end,
		TriggerVollstandigQuest = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("VollstandigQuest", StateMachine, Character)
		end,
		TriggerServerHop = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("ServerHop", StateMachine, Character)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TriggerSpectator = function(StateMachine, Character)
			StateMachine:SetState("Spectator")
			StateMachine:Trigger("Spectating", StateMachine, Character)
		end,
		TriggerQuincyMedallion = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("QuincyMedallion", StateMachine, Character, ...)
		end,
	},
	WeaponDrawn = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TriggerExecute = function(StateMachine, Character)
			StateMachine:SetState("Executing")
			StateMachine:Trigger("Execute", StateMachine, Character)
		end,
		TriggerHomeReturn = function(StateMachine, Character)			
			StateMachine:SetState("Executing")
			StateMachine:Trigger("HomeReturn", StateMachine, Character)
		end,
		TriggerReset = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("Reset", StateMachine, Character)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerLAttack = function(StateMachine, Character)
			StateMachine:SetState("Attacking")
			StateMachine:Trigger("LightAttack", StateMachine, Character)
			
			if PlayerData[Character.Name].FeintQueued then
				PlayerData[Character.Name].FeintQueued = nil
				task.delay(0.25, function()
					StateMachine:Trigger("TriggerM2", StateMachine, Character)
				end)
			end
		end,
		TriggerM2 = function(StateMachine, Character)			
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FeintTimer")
			if TimeDifference >= 1500 then
				PlayerData[Character.Name].FeintQueued = true
				task.delay(0.7, function()
					if PlayerData[Character.Name].FeintQueued then
						PlayerData[Character.Name].FeintQueued = nil
					end
				end)
			end
		end,
		TriggerCAttack = function(StateMachine, Character)
			if not Character:GetAttribute("CriticalCooldown") then
				StateMachine:SetState("CriticalAttacking")
				StateMachine:Trigger("CriticalAttack", StateMachine, Character)
			end
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
		TriggerSkill = function(StateMachine, Character, ...)
			StateMachine:SetState("Skill")
			StateMachine:Trigger("SkillPress", StateMachine, Character, ...)
		end,
		TriggerHierro = function(StateMachine, Character, ...)
			Hierro(Character, ...)
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			StateMachine:SetState("ShikaiSkill")
			StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, ...)
		end,
		TriggerShikaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ShikaiTimer")
			local ReleaseAllowed

			if TimeDifference >= 3000 then
				if AllowedShikaiRelease[PlayerData[Character.Name].WeaponEquipped] then
					ReleaseAllowed = true
				end
				if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery >= 1 then
					ReleaseAllowed = true
				end	
			end		
			
			if ReleaseAllowed then
				StateMachine:SetState("Action")
				StateMachine:Trigger("ShikaiRelease", StateMachine, Character, ...)
			end
		end,
		TriggerQuincyMedallion = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("QuincyMedallion", StateMachine, Character, ...)
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local ReleaseAllowed = true
			if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" then
				if Profile.ClientData.NozarashiMastery < 2 then
					ReleaseAllowed = nil
					local PathData = {Module = ClientProgression, Skill = "NozarashiBankaiHint"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData)
				end
			end	
			
			local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.BankaiTimer
			
			local BankaiCooldown = StatData.BankaiCooldown * 60
			if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				BankaiCooldown = StatData.ResCooldown * 60
			end
			
			if TimeDifference < BankaiCooldown then
				ReleaseAllowed = nil
				local PathData = {Module = ClientProgression, Skill = "BankaiTimer"}
				local Text = BankaiCooldown / 60 - math.floor(TimeDifference / 60)
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Text)
			end
			
			if ReleaseAllowed then
				StateMachine:SetState("Action")
				StateMachine:Trigger("BankaiRelease", StateMachine, Character, ...)
			end
		end,
		TriggerBankaiCancel = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("CancelBankai", StateMachine, Character, ...)
		end,
		TriggerSecondBankaiRelease = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("SecondBankaiRelease", StateMachine, Character, ...)
		end,
		TriggerVisoredRelease = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("VisoredRelease", StateMachine, Character, ...)
		end,
		TriggerLetztStilRelease = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("LetztStilRelease", StateMachine, Character, ...)
		end,
		TriggerPurify = function(StateMachine, Character, ...)
			StateMachine:SetState("Action")
			StateMachine:Trigger("Purify", StateMachine, Character)
		end,
		SheatheWeapon = function(StateMachine, Character, ClientData)
			if Character:GetAttribute("ZanpakutoState") <= 1 then
				if Character:GetAttribute("ZanpakutoState") == 0 then
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)
					StateMachine:SetState("Idle")
					
					if not SheatheSoundBlacklist[PlayerData[Character.Name].WeaponEquipped] then
						local SheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].SheatheSound or Sounds.Sheathe
						local ClonedSheathe = SheatheSound:Clone()
						ClonedSheathe.PlayOnRemove = true
						ClonedSheathe.Parent = Character.PrimaryPart
						ClonedSheathe:Destroy()
						ClonedSheathe = nil
					end
					
					PlayerData[Character.Name].WeaponEquipped = nil
					
					local WeaponModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					WeaponModel.PrimaryPart.Weld.Enabled = true
					WeaponModel.Parent = Character
					Motor6D.Part1 = nil
					
					local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = nil

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = true
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 1
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = false
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", true)

								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.SheatheFunction then
							ZanpakutoData.SheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				elseif Character:GetAttribute("ZanpakutoState") == 1 then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					
					Character:SetAttribute("ZanpakutoState", 0)
					
					if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
						local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
						ShikaiModel:Destroy()
						ShikaiModel = nil
						
						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
						local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
		
						WeaponModel.PrimaryPart.Weld.Enabled = false
						WeaponModel.Parent = Character["Right Arm"]
						
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
						Motor6D.Part1 = WeaponModel.PrimaryPart
						Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData
						
						local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
						local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

						if ZanpakutoData and ZanpakutoData.DoubleHandle then
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
						end
					else
						local ZanpakutoModel = Character["Right Arm"].Zanpakuto
						ZanpakutoModel.Handle[ClientData.WeaponModel]:Destroy()
						ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
						ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
						ZanpakutoModel.PrimaryPart.Trail:Destroy()
						ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
					end
					
					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
					
					local WeaponName = PlayerData[Character.Name].WeaponEquipped
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

					local Idle = "Idle"..math.random(1, 3)
					if WeaponName == "Fist" then
						Idle = "Idle1"
					end

					if not IdleBlacklist[ZanpakutoWeapon] then
						local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
						IdleAnimation:Play()
					end
					
					if PlayerData[Character.Name].ShikaiActiveData then
						if PlayerData[Character.Name].ShikaiActiveData.Connections then
							for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
								if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
								end
								
								PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
								PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
							end
						end
						PlayerData[Character.Name].ShikaiActiveData = nil
					end
				end
			end
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TriggerCarry = function(StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("Carrying")
			StateMachine:Trigger("Carry", StateMachine, Character)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Character).FlashstepMastery
			
			local Cooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			local MaxHealth = Character.Humanoid.MaxHealth
			local Health = Character.Humanoid.Health

			if Health <= MaxHealth * 0.8 then
				local HealthRange = (MaxHealth * 0.8) - 1
				local FlashstepCDRange = FlashstepMasteryIndex[FlashstepMasteries].Cooldown - FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				Cooldown = ScaledFlashstepCD
			end
			
			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end

			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= Cooldown and ReiatsuValue >= 0 then
				StateMachine:PushState("WeaponDrawn")
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			end
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "Attack", "SearchByReference")
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")

			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			
			local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
			local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
				CombatAnimations = CombatAnimations.Bankai
			end
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
			
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()
			
			local DashDisabled = {
				Name = "DashDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}
			local FlashstepDisabled = {
				Name = "FlashstepDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}

			PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
			PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)			
			
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
		TriggerMeditate = function(StateMachine, Character)
			StateMachine:SetState("Meditating")
			StateMachine:Trigger("Meditate", StateMachine, Character)
		end,
		TriggerServerHop = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("ServerHop", StateMachine, Character)
		end,
		TriggerBankaiQuest = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiQuest", StateMachine, Character)
		end,
		TriggerVollstandigQuest = function(StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("VollstandigQuest", StateMachine, Character)
		end,
		TriggerDefendChoice = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local Flashstep = table.find(Profile.UnlockedSkills, "Flashstep")
			
			local ReactionTime = Random.new():NextNumber(0, 0.1)
			task.delay(ReactionTime, function()
				if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
				local RNG = Random.new():NextInteger(1, 10)
				if RNG < 5 and Flashstep then
					StateMachine:Trigger("TriggerFlashstep", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerParry", StateMachine, Character)					
				end
			end)
		end,
		TriggerAttackChoice = function(StateMachine, Character, Location, TargetedEntity)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local ReactionTime = Random.new():NextNumber(0, 0.1)
			task.delay(ReactionTime, function()
				if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
				
				local RNG = Random.new():NextInteger(1, 10)
				if RNG <= 3 then
					StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
				elseif RNG > 3 and RNG < 6 then
					if not Character:GetAttribute("ShikaiDisabled") then
						StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
					else
						StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
					end
				elseif RNG >= 6 and RNG < 9 then
					StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
				else
					StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
				end
			end)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Meditating = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseMeditate", StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		ShikaiFight = function(StateMachine, Character)
			if not Character:GetAttribute("InsideInnerWorld") then
				Character:SetAttribute("InsideInnerWorld", true)
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				--Profile.ClientData.ShikaiTimer = DateTime.now().UnixTimestamp
				
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				local Meditate = Animations.Meditate
				local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
				MeditateAnimation:Play()
				MeditateAnimation:AdjustSpeed(0)

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end
				
				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				local InnerWorld = InnerWorlds:Setup(Player, "Shikai")
				local MeditatingCFrame = Character.PrimaryPart.CFrame
				
				local InitialData = {
					Corrupt = false;
					Race = "Shinigami";
					Time = 120;
					ShikaiActive = Player;
					MeditateCFrame = MeditatingCFrame;
				}
				
				local ShikaiNPCData = {
					Shikai = Profile.ClientData.Shikai;
					WeaponType = Profile.ClientData.WeaponType;
					WeaponModel = Profile.ClientData.WeaponModel;
					BankaiWeaponModel = Profile.ClientData.BankaiWeaponModel;
					ReleasePhrase = Profile.ClientData.ReleasePhrase;
					ZanpakutoName = Profile.ClientData.ZanpakutoName;
					ZanpakutoName2 = Profile.ClientData.ZanpakutoName2;
					ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon;
					HandleColor = Profile.ClientData.HandleColor;
				}
				
				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position
				
				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()
				
				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						InitialData.MeditateClone = MeditateClone
						
						local ShikaiFight = NPCManager:Shinigami("ShikaiNPC", "NPCShinigami", SpawnPosition, InitialData, ShikaiNPCData)
						PlayerData[Player.Name].ShikaiFight = true
						
						InnerWorlds:StoreData(Player, MeditateClone, ShikaiFight)
						--print("Position:", InnerWorld.Position)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
						
						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		BankaiFight = function(StateMachine, Character)
			if not Character:GetAttribute("RegenDisabled") then
				Character:SetAttribute("RegenDisabled", true)
				Character:SetAttribute("InsideInnerWorld", true)
				Character:SetAttribute("BankaiFight", true)
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)

				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				local Meditate = Animations.Meditate
				local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
				MeditateAnimation:Play()
				MeditateAnimation:AdjustSpeed(0)

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end

				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				local InnerWorld = InnerWorlds:Setup(Player, "Bankai")
				local MeditatingCFrame = Character.PrimaryPart.CFrame

				local InitialData = {
					Corrupt = false;
					Race = "Shinigami";
					Time = 120;
					BankaiQuestPlayer = Player;
					MeditateCFrame = MeditatingCFrame;
				}

				local BankaiNPCData = {
					Shikai = Profile.ClientData.Shikai;
					WeaponType = Profile.ClientData.WeaponType;
					WeaponModel = Profile.ClientData.WeaponModel;
					BankaiWeaponModel = Profile.ClientData.BankaiWeaponModel;
					ReleasePhrase = Profile.ClientData.ReleasePhrase;
					ZanpakutoName = Profile.ClientData.ZanpakutoName;
					ZanpakutoName2 = Profile.ClientData.ZanpakutoName2;
					ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon;
					HandleColor = Profile.ClientData.HandleColor;
					EyeColor = Profile.ClientData.EyeColor;
				}

				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						InitialData.MeditateClone = MeditateClone

						local BankaiFight = NPCManager:Shinigami("BankaiNPC", "NPCShinigami", SpawnPosition, InitialData, BankaiNPCData)

						InnerWorlds:StoreData(Player, MeditateClone, BankaiFight)
						--print("Position:", InnerWorld.Position)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		VisoredFight = function(StateMachine, Character)
			if not Character:GetAttribute("RegenDisabled") then
				Character:SetAttribute("RegenDisabled", true)
				Character:SetAttribute("InsideInnerWorld", true)
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)

				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				local Meditate = Animations.Meditate
				local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
				MeditateAnimation:Play()
				MeditateAnimation:AdjustSpeed(0)

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end

				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				local InnerWorld = InnerWorlds:Setup(Player, "Shikai")
				local MeditatingCFrame = Character.PrimaryPart.CFrame

				local InitialData = {
					Corrupt = false;
					Race = "Visored";
					Time = 120;
					VisoredTrainer = Player;
					MeditateCFrame = MeditatingCFrame;
				}

				local NPCVisoredData = {
					VisoredMask = Profile.ClientData.VisoredMask;
					Mastered = Profile.ClientData.VisoredPool.Mastered;
					Buff1 = Profile.ClientData.VisoredPool.Buff1;
					Buff2 = Profile.ClientData.VisoredPool.Buff2;
					Downside = Profile.ClientData.VisoredPool.Downside;
					HandleColor = Profile.ClientData.HandleColor;
				}

				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						InitialData.MeditateClone = MeditateClone

						local VisoredFight = NPCManager:Visored("Visored", "NPCVisored", SpawnPosition, InitialData, NPCVisoredData)
						PlayerData[Player.Name].VisoredFight = true

						InnerWorlds:StoreData(Player, MeditateClone, VisoredFight)
						print("Position:", InnerWorld.Position)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		NozarashiFight = function(StateMachine, Character)
			if not Character:GetAttribute("RegenDisabled") then
				Character:SetAttribute("RegenDisabled", true)
				Character:SetAttribute("InsideInnerWorld", true)
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)

				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				local Meditate = Animations.Meditate
				local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
				MeditateAnimation:Play()
				MeditateAnimation:AdjustSpeed(0)

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end

				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				local InnerWorld = InnerWorlds:Setup(Player, "Shikai")
				local MeditatingCFrame = Character.PrimaryPart.CFrame

				local InitialData = {
					Corrupt = false;
					Race = "Shinigami";
					Time = 120;
					Kenpachi = Player;
					MeditateCFrame = MeditatingCFrame;
				}
				local SetData = {
					Shikai = Profile.ClientData.Shikai;
				}

				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						InitialData.MeditateClone = MeditateClone

						local Nozarashi = NPCManager:Nozarashi("Nozarashi", "NPCNozarashi", SpawnPosition, InitialData, SetData)

						InnerWorlds:StoreData(Player, MeditateClone, Nozarashi)
						print("Position:", InnerWorld.Position)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		ResQuest = function(StateMachine, Character)
			if not Character:GetAttribute("RegenDisabled") then
				Character:SetAttribute("RegenDisabled", true)
				Character:SetAttribute("InsideInnerWorld", true)
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				Profile.ClientData.ShikaiTimer = DateTime.now().UnixTimestamp
				
				PlayerData[Character.Name].ResQuest = true
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				local InnerWorld = InnerWorlds:Setup(Player, "Res")
				local MeditatingCFrame = Character.PrimaryPart.CFrame

				local InitialData = {
					Corrupt = false;
					Race = "Arrancar";
					Time = 120;
					BankaiQuestPlayer = Player;
					ResQuest = true;
					MeditateCFrame = MeditatingCFrame;
				}

				local BankaiNPCData = {
					Shikai = Profile.ClientData.Shikai;
					WeaponType = Profile.ClientData.WeaponType;
					WeaponModel = Profile.ClientData.WeaponModel;
					BankaiWeaponModel = Profile.ClientData.BankaiWeaponModel;
					ReleasePhrase = Profile.ClientData.ReleasePhrase;
					ZanpakutoName = Profile.ClientData.ZanpakutoName;
					ZanpakutoName2 = Profile.ClientData.ZanpakutoName2;
					ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon;
				}

				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						InitialData.MeditateClone = MeditateClone

						local ClickConnections = {}
						local HollowSpawns = workspace.InnerWorldPlots[Character.Name .. "InnerWorld"].Spawns:GetChildren()
						local RandomHollow = math.random(1, #HollowSpawns)
						
						local Chances = 2
						
						for i, v in ipairs(HollowSpawns) do
							local ClickDetector = Instance.new("ClickDetector")
							ClickDetector.Parent = v
								
							if i == RandomHollow then								
								local DialogueStages = {
									[1] = {
										Dialogue = "You finally found me, the strength you lost when you evolved.";
										Options = {
											Yes = "...";
											No = "";
											End = "";
										}
									};
									[2] = {
										Dialogue = "I've been waiting all this time.";
										Options = {
											Yes = "...";
											No = "";
											End = "";
										}
									};
									[3] = {
										Dialogue = "From now on we fight together.";
										Options = {
											Yes = "...";
											No = "";
											End = "";
										}
									};
								}

								local CurrentDialogueStage = 0
								local DialogueFinished = true

								local ClickConnection
								ClickConnection = ClickDetector.MouseClick:Connect(function(QuestPlayer)
									if DialogueFinished and CurrentDialogueStage < #DialogueStages and Player == QuestPlayer then
										DialogueFinished = false
										CurrentDialogueStage += 1

										local DialogueTable = DialogueStages[CurrentDialogueStage]

										local Remote = Instance.new("RemoteEvent")
										Remote.Name = ""
										Remote.Parent = Player

										ReplicatedStorage.Remotes.DialogueEvent:FireClient(Player, Remote, DialogueTable.Dialogue, DialogueTable.Options)

										local Connection
										Connection = Remote.OnServerEvent:Connect(function(CurrentPlayer, Choice)
											if CurrentPlayer == QuestPlayer then
												DialogueFinished = true

												if CurrentDialogueStage >= #DialogueStages then
													ClickDetector:Destroy()
													ClickConnection:Disconnect()
													ClickConnection = nil
													
													PlayerData[Character.Name].ResQuest = nil
													
													local StunData = {
														NoHitEffect = true;
														TrueStunTime = 12;
														SoftStunTime = 0;
													}

													StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)
													
													local ResCinematic = Character.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.ResAnimations.ResCinematic)
													ResCinematic:Play()
													
													local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
													local PathData = {Module = ClientProgression, Skill = "ResCinematic"}
													local RenderDistance = -1
													NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData)
													
													MeditateClone:SetAttribute("IFrames", true)
													MeditateClone:SetAttribute("DeathWhitelist", true)

													local Profile = DataManager:RequestProfile(CurrentPlayer)
													
													local function RollRes()
														local StoredRes = StatData.ResPool
														local RNG = Random.new()
														local SelectedNumber = RNG:NextInteger(1, 100)
														if SelectedNumber <= 5 then
															StoredRes = StatData.LegendaryResPool
														end
														table.sort(StoredRes)

														local SelectedRes = StoredRes[math.random(1, #StoredRes)]
														Profile.ClientData.Shikai = SelectedRes

														local ArrancarZanpakutoNames = ZanpakutoNames.Arrancar[SelectedRes]
														local RandomZanpakutoName = ArrancarZanpakutoNames[math.random(1, #ArrancarZanpakutoNames)]
														Profile.ClientData.ZanpakutoName = RandomZanpakutoName

														local RNG = Random.new()
														local RandomNumber = RNG:NextInteger(0, 100)
														if RandomNumber <= 10 then
															Profile.ClientData.ReleasePhrase = ZanpakutoNames.ArrancarReleasePhrases.Rare[math.random(1, #ZanpakutoNames.ArrancarReleasePhrases.Rare)]
														else
															Profile.ClientData.ReleasePhrase = ZanpakutoNames.ArrancarReleasePhrases.Common[math.random(1, #ZanpakutoNames.ArrancarReleasePhrases.Common)]
														end
													end
													
													--RollRes()
													
													Profile.ClientData.ShikaiUnlocked = true
													Profile.ClientData.BankaiUnlocked = true
													
													local Info = {
														Shikai = Profile.ClientData.ShikaiUnlocked;
														Bankai = Profile.ClientData.BankaiUnlocked;
													}
													ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, Info)

													task.delay(8, function()
														Player.PlayerGui.ScreenEffects.MySoulNeverWavers.Visible = true
														
														task.wait(3)
														
														Player.PlayerGui.ScreenEffects.MySoulNeverWavers.Visible = false
														
														Character:SetAttribute("RegenDisabled", nil)
														Character:SetAttribute("InsideInnerWorld", nil)

														EntityManager:ForceState(MeditateClone, "Dying")
														EntityManager:ChangeState(MeditateClone, "TriggerDeath")

														AntiCheatManager:Teleport(Player, MeditatingCFrame)
														AntiCheatManager:UnlockSavedPosition(Player)
														InnerWorlds:Cleanup(Player)
														
														StateMachine:Trigger("TriggerBankaiObtained", StateMachine, Character)
													end)

													local WebhookInfo = {
														Message = "Obtained res";
														Title = Player.Name .. " " .. Player.UserId;
													}

													Webhooks:Post(BankaiPatrolChannel, WebhookInfo)
												end

												Remote:Destroy()
												Connection:Disconnect()
												Connection = nil
											end
										end)
									end
								end)
								
								table.insert(ClickConnections, ClickConnection)
							else
								local DialogueStages = {
									[1] = {
										Dialogue = "Have you forgotten who you are?";
										Options = {
											Yes = "...";
											No = "...";
											End = "...";
										}
									};
								}

								local CurrentDialogueStage = 0
								local DialogueFinished = true

								local ClickConnection
								ClickConnection = ClickDetector.MouseClick:Connect(function(QuestPlayer)
									if DialogueFinished and CurrentDialogueStage < #DialogueStages and Player == QuestPlayer then
										DialogueFinished = false
										CurrentDialogueStage += 1

										local DialogueTable = DialogueStages[CurrentDialogueStage]

										local Remote = Instance.new("RemoteEvent")
										Remote.Name = ""
										Remote.Parent = Player

										ReplicatedStorage.Remotes.DialogueEvent:FireClient(Player, Remote, DialogueTable.Dialogue, DialogueTable.Options)
										
										Chances -= 1

										if Chances <= 0 then
											EntityManager:ForceState(MeditateClone, "Dying")
											EntityManager:ChangeState(MeditateClone, "TriggerDeath")
											StateMachine:SetState("Dying")
											StateMachine:Trigger("TriggerDeath", StateMachine, Character)
										end
										
										local Connection
										Connection = Remote.OnServerEvent:Connect(function(CurrentPlayer, Choice)
											if CurrentPlayer == QuestPlayer then
												DialogueFinished = true

												if CurrentDialogueStage >= #DialogueStages then
													ClickDetector:Destroy()
													ClickConnection:Disconnect()
													ClickConnection = nil
												end

												Remote:Destroy()
												Connection:Disconnect()
												Connection = nil
											end
										end)
									end
								end)

								table.insert(ClickConnections, ClickConnection)
							end
						end
						
						InnerWorlds:StoreData(Player, MeditateClone, nil)
						InnerWorlds:SetupConnections(Player, ClickConnections)
						--print("Position:", InnerWorld.Position)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		Meditation = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local ShinigamiRank = Profile.ClientData.ShinigamiRank
			local ShikaiUnlocked = Profile.ClientData.ShikaiUnlocked
			local BankaiUnlocked = Profile.ClientData.BankaiUnlocked
			local MeditateTier = Profile.ClientData.Meditation
			
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false
			
			local Meditate = Animations.Meditate
			local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
			MeditateAnimation:Play()
			MeditateAnimation:AdjustSpeed(0)

			if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end
			elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				local ArrancarMeditate = ReplicatedStorage.Assets.Effects.ArrancarMeditate:Clone()
				ArrancarMeditate.Parent = workspace.Effects[Character.Name]
				
				local Weld = Instance.new("Weld")
				Weld.C0 = CFrame.new( -0.00048828125, 2.99091148, 0.894779205, 1, 0, -4.37113883e-08, 0, 1, 0, 4.37113883e-08, 0, 1)
				Weld.Part0 = ArrancarMeditate
				Weld.Part1 = Character.HumanoidRootPart
				Weld.Parent = ArrancarMeditate
				
				for i, v in ipairs(Character:GetDescendants()) do
					if v:IsA("BasePart") and v:CanSetNetworkOwnership() then
						v:SetNetworkOwner(Player)
					end
				end
			end	
			
			local ReiatsuRepairData = {Module = ClientProgression, Skill = "ReiatsuRepair"}
			local ReiatsuRepairEnd = {Module = ClientProgression, Skill = "ReiatsuRepairEnd"}
			local WordPathData = {Module = ClientShikaiProgress, Skill = "FloatingWords"}
			local PathData = {Module = ClientShikaiProgress, Skill = "MeditateTier"}
			local ResMeditatePath = {Module = ClientShikaiProgress, Skill = "ResMeditate"}
			local RenderDistance = -1
			
			local PlayerStats = RankManager:RetrievePlayerStats(ShinigamiRank)
			
			if Profile.ClientData.MaxReiatsu < PlayerStats.Reiatsu and StatData.SoulSociety then
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ReiatsuRepairData)
			end
			
			local ShikaiEXP = Profile.ClientData.ShikaiEXP
			local ShikaiEXPReqs = RankManager:RetrieveShikaiEXPReqs()
			
			local ZanpakutoName = Profile.ClientData.ZanpakutoName
			local ShikaiPersonality = Profile.ClientData.ShikaiPersonality
			
			local BankaiReady = Profile.ClientData.BankaiRequirements.BankaiReady
			
			local ReiatsuRestoreRate = 60 * StatData.ReiatsuRestoreRate -- Seconds * Minutes
			local MeditateTime = StatData.MeditateTime
			local WhisperRate = 1
			local MeditateRate = 60 * MeditateTime -- Seconds * how many minutes
			local ResMeditateTime = 60 * StatData.ResMeditateTime
			local Accumulated = 0
			PlayerData[Character.Name].Meditating = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated > 1 then
					Accumulated -= 1
					MeditateRate -= 1
					WhisperRate -= 1
							
					if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						if StatData.SoulSociety then
							ReiatsuRestoreRate -= 1
						end

						local MaxReiatsu = Profile.ClientData.MaxReiatsu
						if ReiatsuRestoreRate <= 0 then
							ReiatsuRestoreRate = 60 * StatData.ReiatsuRestoreRate
							MaxReiatsu += StatData.ReiatsuRestoreAmount
							if MaxReiatsu < PlayerStats.Reiatsu then
								Profile.ClientData.MaxReiatsu = MaxReiatsu

								local SetReiatsu = Profile.ClientData.MaxReiatsu
								SetReiatsu = PlayerBonus:ApplyReiatsu(Player, SetReiatsu)

								Character:SetAttribute("MaxReiatsu", SetReiatsu)
							else
								Profile.ClientData.MaxReiatsu = PlayerStats.Reiatsu

								local SetReiatsu = PlayerStats.Reiatsu
								SetReiatsu = PlayerBonus:ApplyReiatsu(Player, SetReiatsu)

								Character:SetAttribute("MaxReiatsu", SetReiatsu)
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ReiatsuRepairEnd)
							end
						end

						if WhisperRate <= 0 and MaxReiatsu >= PlayerStats.Reiatsu then
							WhisperRate = 3
							if MeditateTier >= 3 then
								MeditateTier = 3
							end
							NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, WordPathData, MeditateTier, ShikaiPersonality)
						end

						if MeditateRate <= 0 and MaxReiatsu >= PlayerStats.Reiatsu then
							MeditateTier += 1

							if ShikaiUnlocked == false and ShinigamiRank <= StatData.ShikaiFightRankRequirement then
								if MeditateTier >= 3 then
									MeditateTier = 3

									if ShikaiEXP >= ShikaiEXPReqs[StatData.ShikaiFightRankRequirement] then
										NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, MeditateTier, ZanpakutoName, ShikaiPersonality)
									end
								end
							elseif ShikaiUnlocked == true and BankaiUnlocked == false and ShinigamiRank <= StatData.BankaiFightRankRequirement then
								MeditateTier = 3
							--[[if MeditateTier >= 6 then
								MeditateTier = 6
								
								if ShikaiEXP >= ShikaiEXPReqs[StatData.BankaiFightRankRequirement] then
									NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, MeditateTier, ZanpakutoName, ShikaiPersonality)
								end
							end]]
							elseif BankaiUnlocked == true then
								MeditateTier = 3
							--[[if MeditateTier >= 9 then
								MeditateTier = 9
								NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, MeditateTier, ZanpakutoName)
							end]]
							end

							DataManager:ModifyProfile(Player, "ClientData", "Meditation", MeditateTier)
							StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
						end
					elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
						local TimeDifference = (DateTime.now().UnixTimestamp - Profile.ClientData.ShikaiTimer)
						local Minutes = TimeDifference / 60
						if BankaiReady and not Profile.ClientData.BankaiUnlocked and Minutes > StatData.BankaiFightCD then
							if StatData.HuecoMundo or TYPETEST then
								local ResBlock = workspace.Res.Block
								if SharedFunctions:InsidePartRegion(ResBlock, Character.HumanoidRootPart.Position) then
									ResMeditateTime -= 1
									--print("ResMeditateTime:", ResMeditateTime)
								end
							end
							
							if WhisperRate <= 0 then
								WhisperRate = 3
								NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, ResMeditatePath)
							end
							
							if ResMeditateTime <= 0 then
								-- Meditate + whispers, if location is on top of hueco cave rock then after 10 mins tp to res inner world
								StateMachine:Trigger("ResQuest", StateMachine, Character)
							end
						end
					end
				end
			end)
		end,
		Meditate = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local ShinigamiRank = Profile.ClientData.ShinigamiRank
			local ShikaiUnlocked = Profile.ClientData.ShikaiUnlocked
			local BankaiUnlocked = Profile.ClientData.BankaiUnlocked
			local MeditateTier = Profile.ClientData.Meditation
			local Race = Profile.ClientData.Race
			local PlayerStats = RankManager:RetrievePlayerStats(ShinigamiRank)
			
			local TimeDifference = (DateTime.now().UnixTimestamp - Profile.ClientData.ShikaiTimer)
			local Minutes = TimeDifference / 60
			
			if Profile.ClientData.MaxReiatsu >= PlayerStats.Reiatsu then
				if Minutes < StatData.ShikaiFightCD and not Profile.ClientData.ShikaiUnlocked and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
					local ClientItems = ReplicatedStorage.Modules.ClientModules.ClientItems
					local PathData = {Module = ClientItems, Skill = "PrintText"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "Shikai cooldown: " .. math.round((StatData.ShikaiFightCD - Minutes) * 10)/10 .. " minutes", true) 
				end
			end
			
			local ShikaiEXP = Profile.ClientData.ShikaiEXP
			local ShikaiEXPReqs = RankManager:RetrieveShikaiEXPReqs()
			
			if Profile.ClientData.MaxReiatsu >= PlayerStats.Reiatsu then
				if ShikaiEXP < ShikaiEXPReqs[StatData.ShikaiFightRankRequirement] and not Profile.ClientData.ShikaiUnlocked and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
					local ClientItems = ReplicatedStorage.Modules.ClientModules.ClientItems
					local PathData = {Module = ClientItems, Skill = "PrintText"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "Not enough shikai exp", true) 
				end
			end
			
			local Nozarashi
			if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" then
				local NozarashiReqs = Profile.ClientData.NozarashiReqs
				if NozarashiReqs then
					local NozarashiMastery = Profile.ClientData.NozarashiMastery
					local NozarashiCombatDuration = Profile.ClientData.NozarashiReqs.CombatDuration
					local NozarashiUnohanaGrips = Profile.ClientData.NozarashiReqs.UnohanaGrips

					if NozarashiMastery == 0 and NozarashiCombatDuration >= StatData.NozarashiCombatDuration and NozarashiUnohanaGrips >= StatData.NozarashiUnohanaGrips then
						Nozarashi = true
					end
				end
			end
			
			local BankaiUnfinished
			if table.find(StatData.LockedBankaiFights, Profile.ClientData.Shikai) then
				BankaiUnfinished = true
			end
			
			if Character:GetAttribute("InsideShadowGarden") then
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				StateMachine:Trigger("Meditation", StateMachine, Character)
			elseif PlayerData[Character.Name].BankaiQuest then
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			elseif PlayerData[Character.Name].MeditatingCFrame and not Character:GetAttribute("RegenDisabled") then
				StateMachine:Trigger("LeaveInnerWorld", StateMachine, Character)
			elseif Profile.ClientData.MaxReiatsu < PlayerStats.Reiatsu then	
				StateMachine:Trigger("Meditation", StateMachine, Character)
			elseif ShikaiUnlocked == false and ShinigamiRank <= StatData.ShikaiFightRankRequirement and Minutes >= StatData.ShikaiFightCD then
				if MeditateTier == 3 and ShikaiEXP >= ShikaiEXPReqs[StatData.ShikaiFightRankRequirement] then
					StateMachine:Trigger("ShikaiFight", StateMachine, Character)
				else
					StateMachine:Trigger("Meditation", StateMachine, Character)
				end
			elseif Race == "Visored" and Profile.ClientData.VisoredPool.Mastered == false and Profile.ClientData.VisoredPool.VisoredType == 3 then
				StateMachine:Trigger("VisoredFight", StateMachine, Character)
			elseif Nozarashi then
				StateMachine:Trigger("NozarashiFight", StateMachine, Character)
			elseif ShikaiUnlocked and BankaiUnlocked == false and Profile.ClientData.BankaiRequirements.BankaiFight and ShinigamiRank <= StatData.BankaiFightRankRequirement and Minutes > StatData.BankaiFightCD and not BankaiUnfinished then
				StateMachine:Trigger("BankaiFight", StateMachine, Character)
			elseif ShikaiUnlocked or BankaiUnlocked then
				StateMachine:Trigger("InnerWorld", StateMachine, Character)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		InnerWorld = function(StateMachine, Character)
			if not PlayerData[Character.Name].InnerWorldTimer then
				PlayerData[Character.Name].InnerWorldTimer = 0
			end
			
			local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].InnerWorldTimer
			if TimeDifference >= 7000 and not Character:GetAttribute("InsideInnerWorld") then
				PlayerData[Character.Name].InnerWorldTimer = DateTime.now().UnixTimestampMillis
				Character:SetAttribute("InsideInnerWorld", Character.HumanoidRootPart.Position)
				
				local PathData = {Module = ClientShikaiProgress, Skill = "BankaiRequest"}
				local RenderDistance = -1
				
				local MeditatingCFrame = Character.PrimaryPart.CFrame
				PlayerData[Character.Name].MeditatingCFrame = MeditatingCFrame
				
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local ShikaiPersonality = Profile.ClientData.ShikaiPersonality
				local ShinigamiRank = Profile.ClientData.ShinigamiRank
				
				AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
				
				local ShikaiEXPReqs = RankManager:RetrieveShikaiEXPReqs()
				
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false
				
				local Meditate = Animations.Meditate
				local MeditateAnimation = Character.Humanoid.Animator:LoadAnimation(Meditate)
				MeditateAnimation:Play()
				MeditateAnimation:AdjustSpeed(0)

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") then
						for i, Particle in ipairs(ReplicatedStorage.Assets.Effects.MeditateFX:GetChildren()) do
							local Rei = Particle:Clone()
							Rei.Parent = v
						end
					end
				end
				
				local WorldType = "Shikai"
				if Profile.ClientData.BankaiUnlocked or Profile.ClientData.BankaiRequirements.BankaiReady then
					WorldType = "Bankai"
				end
				if Profile.ClientData.QuincyMedallion then
					WorldType = "Empty"
				end
				
				local InnerWorld = InnerWorlds:Setup(Player, WorldType)
				local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, 6)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						local MeditateClone = EntityManager:CreateEntity(Character.Name .. "Clone", "ShinigamiCloneLink", Character, MeditatingCFrame)
						
						local ShikaiTrainer
						if not Profile.ClientData.QuincyMedallion then
							local InitialData = {
								Corrupt = false;
								Race = "Shinigami";
								Time = 120;
								InnerWorldTrainer = Player;
							}

							ShikaiTrainer = EntityManager:CreateEntity("Shinigami", "NPCShinigami", SpawnPosition, InitialData)
							ShikaiTrainer:SetAttribute("IFrames", true)			 
							ShikaiTrainer.HumanoidRootPart.Anchored = true

							local DialogueStages = {
								[0] = {
									Options = {
										Yes = "...";
										No = "...";
										End = "..."
									}
								};
								[1] = {
									Dialogue = "Ok ok I'll talk if you stop bothering me. What do you want?";
									Options = {
										Yes = "Power";
										No = "Sorry";
										End = "Nothing";
									}
								};
								[2] = {
									Dialogue = "Power? Discover pride first, are you comfortable not waking up at the top of the world?";
									Options = {
										Yes = "How do I reach it?";
										No = "...";
										End = "...";
									}
								};
								[3] = {
									Dialogue = "Are you able to call yourself unequaled, unrivaled?";
									Options = {
										Yes = "...";
										No = "...";
										End = "...";
									}
								};
								[4] = {
									Dialogue = "Maintain the peak of strength";
									Options = {
										Yes = "...";
										No = "...";
										End = "...";
									}
								};
								[5] = {
									Dialogue = "Sacrifice the promise of rivals";
									Options = {
										Yes = "...";
										No = "...";
										End = "...";
									}
								};
								[6] = {
									Dialogue = "Those once pure must be felled";
									Options = {
										Yes = "...";
										No = "...";
										End = "...";
									}
								};
								[7] = {
									Dialogue = "And Great Bawabawa slain, then I will consider you worthy.";
									Options = {
										Yes = "...";
										No = "...";
										End = "...";
									}
								};
							}

							local Top5 = Profile.ClientData.GlobalRank >= 0 and Profile.ClientData.GlobalRank <= StatData.BankaiRequirements.GlobalRank
							local BankaiDurationFulfilled = Profile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration
							local BankaiHollowsMet = Profile.ClientData.BankaiRequirements.Hollows >= StatData.BankaiRequirements.Hollows
							local BankaiPlayersMet = Profile.ClientData.BankaiRequirements.Players >= StatData.BankaiRequirements.Players
							local BankaiBossesMet = Profile.ClientData.BankaiRequirements.WorldBosses >= StatData.BankaiRequirements.WorldBosses

							if BankaiDurationFulfilled then
								DialogueStages[4].Dialogue = "The strength you hold is authentic."
								DialogueStages[3].Options.Yes = "I am"
							elseif Top5 then
								DialogueStages[3].Options.Yes = "I am"
								DialogueStages[4].Dialogue = "You are unequaled, but for how long?"
							end
							if BankaiPlayersMet then
								DialogueStages[5].Dialogue = "The promises of rivals have been extinguished"
							end
							if BankaiHollowsMet then
								DialogueStages[6].Dialogue = "The once pure have been guided to the afterlife"
							end
							if BankaiBossesMet then
								DialogueStages[7].Dialogue = "Bawabawa no longer roams"
							end

							local Debounce
							local BankaiHint
							local CurrentDialogueStage = 0
							local CurrentDialogues = 0
							local DialogueFinished = true
							local ClickDetector = Instance.new("ClickDetector")
							ClickDetector.Parent = ShikaiTrainer
							PlayerData[Character.Name].ShikaiTrainerConnection = ClickDetector.MouseClick:Connect(function(CurrentPlayer)
								if Debounce then
									return
								end

								Debounce = true
								task.delay(0.1, function()
									Debounce = false
								end)

								local AlreadyTalking
								local RemoteFound = Player:FindFirstChild(Profile.ClientData.ZanpakutoName)
								if RemoteFound and RemoteFound:IsA("RemoteEvent") then
									AlreadyTalking = true
								end

								if AlreadyTalking then
									return
								end

								if CurrentPlayer == Player and DialogueFinished then
									local Dialogues = {
										["Kind Hearted"] = " PURIFICATION EXP left.";
										Squeamish = " MISSION EXP left.";
										Vengeful = " VENGEFUL GRIP EXP left.";
										Hateful = " GRIP EXP left.";
										Chaotic = " GRIPS/PVP MISSION EXP left.";
										Pure = " HOLLOW KILL EXP left.";
									}

									local Dialogue = "You have " .. SharedFunctions:RoundNumber(ShikaiEXPReqs[ShinigamiRank] - Profile.ClientData.ShikaiEXP, 1) .. Dialogues[ShikaiPersonality]
									if ShikaiEXPReqs[ShinigamiRank] - Profile.ClientData.ShikaiEXP <= 0 or ShinigamiRank <= 1 then
										Dialogue = "You have satisifed my requests currently."

										if ShinigamiRank <= 1 and Profile.ClientData.BankaiRequirements.BankaiReady then
											Dialogue = "Guiding you is no longer my task, find someone else to do this sullied job."
										end
									end

									local Remote = Instance.new("RemoteEvent")
									Remote.Name = Profile.ClientData.ZanpakutoName
									Remote.Parent = Player

									if BankaiHint then
										if CurrentDialogueStage > 7 then
											CurrentDialogueStage = 3
										end
										Dialogue = DialogueStages[CurrentDialogueStage].Dialogue
									end

									ReplicatedStorage.Remotes.DialogueEvent:FireClient(Player, Remote, Dialogue, DialogueStages[CurrentDialogueStage].Options)

									local Connection
									Connection = Remote.OnServerEvent:Connect(function(CurrentPlayer, Choice)
										if CurrentPlayer == Player then
											DialogueFinished = true

											CurrentDialogues += 1

											if CurrentDialogues >= 5 and not Profile.ClientData.BankaiRequirements.BankaiReady and Profile.ClientData.ShinigamiRank <= StatData.BankaiRankRequirement then
												BankaiHint = true

												if CurrentDialogueStage == 3 and Choice == "Yes" then
													if Top5 or BankaiDurationFulfilled then
														CurrentDialogueStage += 1
													end
												elseif CurrentDialogueStage <= 2 and Choice == "Yes" then
													CurrentDialogueStage += 1
												elseif CurrentDialogueStage > 3 then
													CurrentDialogueStage += 1
												end
											end

											Remote:Destroy()
											Connection:Disconnect()
											Connection = nil
										end
									end)
								end
							end)
						end
						
						
						InnerWorlds:StoreData(Player, MeditateClone, ShikaiTrainer)
						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
						
						if Profile.ClientData.ShinigamiRank <= StatData.BankaiFightRankRequirement then
							local WhisperRate = 2
							local Accumulated = 0
							
							while true do
								local Step = task.wait(0.05)
								if Character.Humanoid.Health <= 0 or not Character:GetAttribute("InsideInnerWorld") then
									return
								end
								
								Accumulated += Step
								if Accumulated > WhisperRate then
									Accumulated -= WhisperRate
									NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, Profile.ClientData.Shikai)
								end
							end
						end
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			else
				StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
			end
		end,
		LeaveInnerWorld = function(StateMachine, Character)
			if not PlayerData[Character.Name].InnerWorldTimer then
				PlayerData[Character.Name].InnerWorldTimer = 0
			end

			local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].InnerWorldTimer

			if TimeDifference >= 7000 then
				PlayerData[Character.Name].InnerWorldTimer = DateTime.now().UnixTimestampMillis
				Character:SetAttribute("InsideInnerWorld", nil)
				
				local MeditateCFrame = PlayerData[Character.Name].MeditatingCFrame
				PlayerData[Character.Name].MeditatingCFrame = nil
				
				local Player = Players:GetPlayerFromCharacter(Character)

				if PlayerData[Character.Name].ShikaiTrainerConnection then
					PlayerData[Character.Name].ShikaiTrainerConnection:Disconnect()
					PlayerData[Character.Name].ShikaiTrainerConnection = nil
				end

				local Info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

				task.delay(3, function()
					if PlayerData[Player.Name] then
						InnerWorlds:Cleanup(Player)
						AntiCheatManager:Teleport(Player, MeditateCFrame)
						AntiCheatManager:UnlockSavedPosition(Player)
						StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)

						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					end
				end)
			end
		end,
		ReleaseMeditate = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			for _, PlayingTrack in pairs (Character.Humanoid:GetPlayingAnimationTracks()) do
				if PlayingTrack.Name:match("Meditate") then
					PlayingTrack:AdjustSpeed(1)
					PlayingTrack:Stop()
					PlayingTrack:Destroy()
				end
			end
			SharedFunctions:CancelAnimation(Character.Humanoid, "Meditate", "SearchByReference")
			
			
			if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
				for i, v in ipairs(Character:GetDescendants()) do
					if v:IsA("ParticleEmitter") and v.Name == "Rei" then
						v:Destroy()
					end
				end
			elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
					if v.Name == "ArrancarMeditate" then
						v:Destroy()
					end
				end
			end
			
			if PlayerData[Character.Name].Meditating then
				local ReiatsuRepairEnd = {Module = ClientProgression, Skill = "ReiatsuRepairEnd"}
				local RenderDistance = -1
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ReiatsuRepairEnd)

				PlayerData[Character.Name].Meditating:Disconnect()
				PlayerData[Character.Name].Meditating = nil
			end		

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerMeditate = function(StateMachine, Character)
			StateMachine:Trigger("ReleaseMeditate", StateMachine, Character)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Carrying = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		Carry = function(StateMachine, Character)
			local CarryCheck = false
			local CarryTimer = PlayerData[Character.Name].CarryTimer
			if not CarryTimer then
				CarryTimer = 0
			end
			local TimeDifference = DateTime.now().UnixTimestampMillis - CarryTimer
			if TimeDifference >= 500 and not Character:GetAttribute("InsideInnerWorld") then
				for i, v in pairs(workspace.Entities:GetChildren()) do
					if v:FindFirstChild("HumanoidRootPart") and not v:GetAttribute("Carried") and v ~= Character and not CarryCheck and not v:GetAttribute("Death") then	
						if (v.PrimaryPart.Position - Character.HumanoidRootPart.Position).Magnitude < 6 and v:GetAttribute("CurrentState") == "Unconscious" then
							local Whitelisted = true
							if v:GetAttribute("WhitelistedAttacker") and v:GetAttribute("WhitelistedAttacker") ~= Character.Name then
								Whitelisted = nil
							end
							
							if Whitelisted then
								PlayerData[Character.Name].Carrying = v
								CarryCheck = true

								Character:SetAttribute("Carrying", v.Name)
								Ragdoll:CarriedEnabled(v)
								v:SetAttribute("Carried", v.Name)
								EntityManager:ChangeState(v, "TriggerCarried", Character)

								local Weld = Instance.new("Weld")
								Weld.Name = "CarryWeld"
								Weld.Part0 = Character.Torso
								Weld.Part1 = v.HumanoidRootPart
								Weld.C0 = CFrame.new(0.0483903885, 0.199999809, 0.245010376, 1, 0, 0, 0, 1, 0, 0, 0, 1)
								Weld.Parent = Character

								PlayerData[Character.Name].CarriedPlayerMass = {}

								local Player = Players:GetPlayerFromCharacter(Character)						
								for Index, Part in ipairs(v:GetChildren()) do
									if Part:IsA'BasePart' then
										PlayerData[Character.Name].CarriedPlayerMass[Part] = Part.Massless
										Part:SetAttribute("Massless", Part.Massless)
										Part.Massless = true
										Part.CollisionGroup = "Carried"
										if Part:CanSetNetworkOwnership() then
											Part:SetNetworkOwner(Player)
										end
									end
								end

						--[[local RigidConstraint = Instance.new("RigidConstraint")
						RigidConstraint.Name = "CarryWeld"
						RigidConstraint.Attachment0 = v.HumanoidRootPart.RootAttachment
						RigidConstraint.Attachment1 = Character.HumanoidRootPart.RootAttachment
						RigidConstraint.Parent = Character]]

						--[[local AlignOrientation = Instance.new("AlignOrientation")
						AlignOrientation.Name = "CarryOrientation"
						AlignOrientation.Attachment0 = v.HumanoidRootPart.RootAttachment
						AlignOrientation.Attachment1 = Character.HumanoidRootPart.RootAttachment
						AlignOrientation.Responsiveness = 200
						AlignOrientation.MaxTorque = 999999
						AlignOrientation.MaxAngularVelocity = 999999
						AlignOrientation.CFrame = CFrame.new(0.0483903885, 0.199999809, 0.245010376, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						AlignOrientation.Parent = Character]]

								local Carrrying = Animations.Carrying
								local CarryingAnimation = Character.Humanoid.Animator:LoadAnimation(Carrrying)
								CarryingAnimation:Play()

								local CarriedPlayer = Players:GetPlayerFromCharacter(v)
								if CarriedPlayer then
									PlayerData[Character.Name].CarriedLeaving = CarriedPlayer.CharacterRemoving:Connect(function()
										PlayerData[Character.Name].Carrying = nil
										StateMachine:Trigger("TriggerCarry", StateMachine, Character, "CarriedLeft")
									end)
								end

								PlayerData[Character.Name].CarryConnection = v.Humanoid.Died:Connect(function()
									PlayerData[Character.Name].Carrying = nil
									if Weld and Weld.Parent then
										Weld:Destroy()
									end
									--print(v.Name .. " DIED WHILE CARRIED")
									v:BreakJoints()

									SharedFunctions:CancelAnimation(Character.Humanoid, "Carrying")

									Character:SetAttribute("Carrying", nil)

									if PlayerData[Character.Name].Flashstepping then
										StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character)
									end
									if PlayerData[Character.Name].WeaponEquipped then
										StateMachine:SetState("WeaponDrawn")
									else
										StateMachine:SetState("Idle")
									end

									if PlayerData[Character.Name].CarriedLeaving then
										PlayerData[Character.Name].CarriedLeaving:Disconnect()
										PlayerData[Character.Name].CarriedLeaving = nil
									end
									if PlayerData[Character.Name].CarryConnection then
										PlayerData[Character.Name].CarryConnection:Disconnect()
										PlayerData[Character.Name].CarryConnection = nil
									end
								end)

								break
							end
						end
					end
				end	
			end
			
			if not CarryCheck then
				StateMachine:PopState()
			end
		end,
		ReleaseCarrying = function(StateMachine, Character, Stunned)
			local CarryWeld = Character:FindFirstChild("CarryWeld")
			if CarryWeld then
				CarryWeld:Destroy()
				CarryWeld = nil
			end
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "Carrying")
			
			Character:SetAttribute("Carrying", nil)
			
			if PlayerData[Character.Name].Carrying then
				local CarriedPlayer = Players:GetPlayerFromCharacter(PlayerData[Character.Name].Carrying)
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				EntityManager:ChangeState(PlayerData[Character.Name].Carrying, "ReleaseCarried")
				
				for Index, Part in ipairs(PlayerData[Character.Name].Carrying:GetChildren()) do
					if Part:IsA'BasePart' then
						if PlayerData[Character.Name].CarriedPlayerMass and PlayerData[Character.Name].CarriedPlayerMass[Part] then
							Part.Massless = PlayerData[Character.Name].CarriedPlayerMass[Part]
							PlayerData[Character.Name].CarriedPlayerMass[Part] = nil
						else
							Part.Massless = false
						end
						Part.CollisionGroup = "Entity"
						if CarriedPlayer and Part:CanSetNetworkOwnership() then
							Part:SetNetworkOwner(CarriedPlayer)
						end
					end
				end
				PlayerData[Character.Name].CarriedPlayerMass = nil
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				SharedFunctions:CancelAnimation(PlayerData[Character.Name].Carrying.Humanoid, "Carried")
				PlayerData[Character.Name].Carrying:SetAttribute("Carried", nil)
				PlayerData[Character.Name].Carrying:SetAttribute("IFrames", false)				
				Ragdoll:Enable(PlayerData[Character.Name].Carrying)
				
				PlayerData[Character.Name].Carrying = nil
			end
			
			if not Stunned then
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:SetState("WeaponDrawn")
				else
					StateMachine:SetState("Idle")
				end
			end

			if PlayerData[Character.Name].CarriedLeaving then
				PlayerData[Character.Name].CarriedLeaving:Disconnect()
				PlayerData[Character.Name].CarriedLeaving = nil
			end
			if PlayerData[Character.Name].CarryConnection then
				PlayerData[Character.Name].CarryConnection:Disconnect()
				PlayerData[Character.Name].CarryConnection = nil
			end
			if PlayerData[Character.Name].CarryOwnerLeave then
				PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
				PlayerData[Character.Name].CarryOwnerLeave = nil
			end
		end,
		TriggerCarry = function(StateMachine, Character)
			StateMachine:Trigger("ReleaseCarrying", StateMachine, Character)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseCarrying", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseCarrying", StateMachine, Character, "Stunned")
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			StateMachine:PushState("Carrying")
			StateMachine:SetState("Dashing")
			StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Character).FlashstepMastery
			
			local Cooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			local MaxHealth = Character.Humanoid.MaxHealth
			local Health = Character.Humanoid.Health

			if Health <= MaxHealth * 0.8 then
				local HealthRange = (MaxHealth * 0.8) - 1
				local FlashstepCDRange = FlashstepMasteryIndex[FlashstepMasteries].Cooldown - FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				Cooldown = ScaledFlashstepCD
			end
			
			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end

			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= Cooldown and ReiatsuValue >= 0 then
				StateMachine:PushState("Carrying")
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			end
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("ReleaseCarrying", StateMachine, Character, "Stunned")
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerSprint = function(StateMachine, Character)
			StateMachine:PushState("Carrying")
			StateMachine:SetState("Sprinting")
			StateMachine:Trigger("Sprint", StateMachine, Character)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Parrying = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelParryAnimation", StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		CancelParryAnimation = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Parry", true)
			BankaiWeapons:CancelWeaponAnimation(Character, "Parry", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		Parry = function(StateMachine, Character)
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
			if WeaponEquipped then
				local WeaponAnimations = CombatAnimations[WeaponEquipped]
				PlayerData[Character.Name].BlockHeld = true
				local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("BlockTimer")
				if TimeDifference >= Character:GetAttribute("ParryCooldown") then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					
					Character:SetAttribute("ParryCooldown", 1700)
					Character:SetAttribute("BlockTimer", DateTime.now().UnixTimestampMillis) 
					
					BankaiWeapons:PlayWeaponAnimation(Character, "Parry", Profile.ClientData, PlayerData[Character.Name])
					
					local ParryAnimation = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations.Parry)
					Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
					ParryAnimation:Play()
					ParryAnimation.KeyframeReached:Connect(function(KeyframeName)
						if KeyframeName == "DeflectStart" then
							Character:SetAttribute("DeflectFrames", true)
						elseif KeyframeName == "DeflectEnd" then
							Character:SetAttribute("DeflectFrames", false)
							if PlayerData[Character.Name].BlockHeld == true then
								StateMachine:Trigger("TriggerBlock", StateMachine, Character)
							else
								Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
								Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
								Character.Humanoid.AutoRotate = true
								StateMachine:Trigger("TriggerWeaponDrawn", StateMachine, Character)
							end
						end
					end)
				else
					if PlayerData[Character.Name].BlockHeld == true then
						StateMachine:Trigger("TriggerBlock", StateMachine, Character)
					end
				end	
			else
				StateMachine:SetState("Idle")
			end
		end,
		TriggerBlock = function(StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:SetState("Blocking")
			StateMachine:Trigger("TrueBlock", StateMachine, Character)
		end,	
		ReleaseBlock = function(StateMachine, Character)
			PlayerData[Character.Name].BlockHeld = nil
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			PlayerData[Character.Name].BlockHeld = nil
			StateMachine:Trigger("CancelParryAnimation", StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].BlockHeld = nil
			Character:SetAttribute("DeflectFrames", false)
			StateMachine:Trigger("CancelParryAnimation", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			PlayerData[Character.Name].LastParriedTime = DateTime.now().UnixTimestampMillis
			
			StateMachine:Trigger("CancelParryAnimation", StateMachine, Character)
			
			Character:SetAttribute("DeflectFrames", true)
			Character:SetAttribute("ParryCooldown", 0)
			
			--PlayerData[Character.Name].BlockHeld = nil
			
			AirtimeManager:ReleaseAirtime(Character)
			AirtimeManager:ReleaseAirtime(AttackOwner, "Knockback")
			
			local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
			local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
				CombatAnimations = CombatAnimations.Bankai
			end
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Parrying" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
			
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
			
			if Character:GetAttribute("Schrift") == "Explode" then
				local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientPassives
				local SparksData = {Module = ClientModule, Skill = "ReverseCombustionSparks"}
				local PathData = {Module = ClientModule, Skill = "ReverseCombustion"}
				local ScreenShakePath = {Module = ClientModule, Skill = "BambiettaScreenShake"}
				local RenderDistance = 1000

				local CombustedCharacter = AttackOwner
				local Bambietta = Character

				local ReverseCombustion = CombustedCharacter:GetAttribute("ReverseCombustion")
				if not ReverseCombustion then
					ReverseCombustion = 0
				end
				ReverseCombustion += 1

				local SpawnPoint = Bambietta.HumanoidRootPart.CFrame
				NetworkManager.FireAllClients(Bambietta, "ClientEffects", RenderDistance, SparksData, SpawnPoint, ReverseCombustion)

				if ReverseCombustion >= SpecData.Bambietta.ReverseCombustion.Stacks then
					CombustedCharacter:SetAttribute("ReverseCombustion", nil)

					local SpawnPoint = CombustedCharacter.HumanoidRootPart.CFrame
					local BambiettaCFrame = Bambietta.HumanoidRootPart.CFrame
					local DetectedEntities = HitDetection:Magnitude(Bambietta, SpawnPoint.Position, SpecData.Bambietta.ReverseCombustion.Properties.Range)
					if DetectedEntities then
						local DamagedEntities = CombatManager:ApplyDamage(Bambietta, DetectedEntities, SpecData.Bambietta.ReverseCombustion)
						for i, v in ipairs(DamagedEntities) do
							KnockbackModule:Repel(Bambietta, BambiettaCFrame.Position, v, 40)
							Ragdoll:Enable(v)
							task.delay(SpecData.Bambietta.ReverseCombustion.TrueStunTime, function()
								Ragdoll:Disable(v, "UnconsciousCheck")
							end)

							local PlayerEntity = Players:GetPlayerFromCharacter(v)
							if PlayerEntity then
								NetworkManager.FireClient(PlayerEntity, PlayerEntity.Character, "ClientEffects", -1, ScreenShakePath)
							end
						end
					end

					NetworkManager.FireAllClients(CombustedCharacter, "ClientEffects", RenderDistance, PathData, SpawnPoint, ReverseCombustion)
				else
					CombustedCharacter:SetAttribute("ReverseCombustion", ReverseCombustion)
				end
			end
			
			if Character:GetAttribute("ShunkoDuration") then
				Character:SetAttribute("ShunkoDuration", Character:GetAttribute("ShunkoDuration") + SkillData.Shunko.SecondsPerHit)
			end
			
			local BloodPassiveData = PassivesManager:RequestPassives(Character).BloodPassive
			if BloodPassiveData and DateTime.now().UnixTimestampMillis - BloodPassiveData.Timer >= BloodPassiveData.Cooldown * 1000 then
				BloodPassiveData.Timer = DateTime.now().UnixTimestampMillis
				
				local HitType = HitDetection:FocusTarget(Character, AttackOwner)
				if HitType then
					local PositiveHits = CombatManager:ApplyDamage(Character, {[AttackOwner] = HitType}, BloodPassiveData)
					if PositiveHits and #PositiveHits > 0 then
						local ClientBloodShikai = ReplicatedStorage.Modules.ClientModules.Shikais.ClientBloodShikai
						local PathData = {Module = ClientBloodShikai, Skill = "Collapsed"}
						local RenderDistance = 1000
						NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, AttackOwner)
						
						local Amount = BloodPassiveData.BloodGain
						if Character:GetAttribute("ZanpakutoState") >= 2 then
							Amount += Amount * BloodPassiveData.BloodMeterBuff
						end

						local BloodMeter = Character:GetAttribute("BloodMeter")
						BloodMeter += Amount

						if BloodMeter < Character:GetAttribute("BloodCap") then
							Character:SetAttribute("BloodMeter", BloodMeter)
						else
							Character:SetAttribute("BloodMeter", Character:GetAttribute("BloodCap"))
						end
						
						Ragdoll:Enable(AttackOwner)
						task.delay(BloodPassiveData.TrueStunTime, function()
							Ragdoll:Disable(AttackOwner, "UnconsciousCheck")
						end)
					end
				end
			end
			
			if table.find(Profile.UnlockedSkills, "Blut Vene") and Character:GetAttribute("BlutArterie") then
				local BlutTierData = {
					[1] = SkillData["Blut Vene"];
					[2] = SkillData["Blut Vene 2"];
					[3] = SkillData["Blut Vene 3"];
				}

				local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
				local Amount = BlutTier.Amount
				local BlutDamage = BlutTier.DamageBuff

				local BlutVene = Character:GetAttribute("BlutVene")
				if BlutVene then
					BlutVene += BlutTier.ArterieRestore

					if BlutVene < Amount then
						Character:SetAttribute("BlutVene", BlutVene)
					else
						Character:SetAttribute("BlutVene", Amount)
					end
				end		
			end
			
			local AutoParryFrame = StatData.AutoParryFrame
			local ParryStunDuration = DeflectAnimation.Length + ParryStunTime
			
			task.delay(AutoParryFrame, function()				
				if not PlayerData[Character.Name].BankaiActiveData or not PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
					if PlayerData[Character.Name].BlockHeld then
						local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].LastParriedTime
						if TimeDifference >= AutoParryFrame * 995 then
							Character:SetAttribute("DeflectFrames", false)
						end
					else
						Character:SetAttribute("DeflectFrames", false)
					end
				end
			end)
			task.delay(ParryStunDuration, function()
				if Character:GetAttribute("Zombification") then
					StateMachine:Trigger("TriggerAttackChoice", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerWeaponDrawn", StateMachine, Character)
				end
			end)
		end,
		TriggerWeaponDrawn = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerAttackChoice = function(StateMachine, Character)
			Character:SetAttribute("DeflectFrames", false)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local function Attack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			end

			local function CAttack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character)
			end

			local function ShikaiSkill()
				StateMachine:SetState("WeaponDrawn")
				if not Character:GetAttribute("ShikaiDisabled") then
					StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerSkill", StateMachine, Character)
				end
			end

			local function Skill()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerSkill", StateMachine, Character)
			end

			local RNG = Random.new():NextInteger(1, 10)
			if RNG <= 1 then
				CAttack()
			elseif RNG > 1 and RNG < 3 then
				ShikaiSkill()
			elseif RNG >= 3 and RNG <= 4 then
				Skill()
			else
				Attack()
			end
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Blocking = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			Character:SetAttribute("BlockFrames", false)
			Character:SetAttribute("DeflectFrames", false)
			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
				PlayerData[Character.Name].BankaiActiveData.AutoDeflect = false
			end
			
			StateMachine:Trigger("CancelBlockAnimation", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		CancelBlockAnimation = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Block", true)
			BankaiWeapons:CancelWeaponAnimation(Character, "Block", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		TrueBlock = function(StateMachine, Character)
			if Character:GetAttribute("Zombification") then
				StateMachine:Trigger("ZombieBlock", StateMachine, Character)
			else
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				Character:SetAttribute("BlockFrames", true)
				
				local WindTimer = 0
				if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
					WindTimer = PlayerData[Character.Name].BankaiActiveData.Timer
				end
				local TimeDifference = DateTime.now().UnixTimestampMillis - WindTimer

				if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData and TimeDifference >= PlayerData[Character.Name].BankaiActiveData.AutoDeflectData.AutoparryCD * 1000 and Character:GetAttribute("WindShield") > 0 then
					PlayerData[Character.Name].BankaiActiveData.AutoDeflect = true
					Character:SetAttribute("DeflectFrames", true)
					
					local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(VollstandigAnimations.Wind.Block)
					BlockAnimation:Play()
				else
					Character:SetAttribute("DeflectFrames", false)
					
					local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
					local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
					local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
					if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
						CombatAnimations = CombatAnimations.Bankai
					end
					local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Block)
					BlockAnimation:Play()
				end
				
				BankaiWeapons:PlayWeaponAnimation(Character, "Block", Profile.ClientData, PlayerData[Character.Name])
				
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5
			end
		end,
		ZombieBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", true)
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Block)
			BlockAnimation:Play()

			Character.HumanoidRootPart.AlignOrientation.Enabled = true

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") - 5

			local function Attack()
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			end

			local function CAttack()
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character)
			end

			local function ShikaiSkill()
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				if not Character:GetAttribute("ShikaiDisabled") then
					StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerSkill", StateMachine, Character)
				end
			end

			local function Skill()
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				StateMachine:Trigger("TriggerSkill", StateMachine, Character)
			end

			local function Parry()
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				StateMachine:Trigger("TriggerParry", StateMachine, Character)
			end

			local function Block()
				local RNGBlockTime = Random.new():NextNumber(0.05, 0.35)
				task.delay(RNGBlockTime, function()
					StateMachine:Trigger("ReleaseBlock", StateMachine, Character)
				end)
			end

			local ReactionTime = Random.new():NextNumber(0, 0.65)
			task.delay(ReactionTime, function()
				if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
				local RNG = Random.new():NextInteger(1, 10)
				if RNG <= 3 then
					Parry()
				elseif RNG > 3 and RNG <= 5 then
					Block()
				elseif RNG > 5 and RNG <= 7 then
					Attack()
				elseif RNG > 7 and RNG < 10 then
					ShikaiSkill()
				elseif RNG == 10 then
					CAttack()
				end
			end)
		end,
		ReleaseBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", false)
			Character:SetAttribute("DeflectFrames", false)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
				PlayerData[Character.Name].BankaiActiveData.AutoDeflect = false
			end
			
			StateMachine:Trigger("CancelBlockAnimation", StateMachine, Character)
			StateMachine:SetState("WeaponDrawn")	
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			Character:SetAttribute("BlockFrames", false)
			Character:SetAttribute("DeflectFrames", false)
			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
				PlayerData[Character.Name].BankaiActiveData.AutoDeflect = false
			end
			
			StateMachine:Trigger("CancelBlockAnimation", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		SoftBlock = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", true)
			Character:SetAttribute("DeflectFrames", false)
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
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
			
			local PostureRegenDebuff = {
				Name = "PostureDisabled";
				Value = true;
				Duration = 2;
			}

			PassivesManager:ApplyDebuff(AttackOwner, {Character}, PostureRegenDebuff)
			
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
				
				if not AttackData.IgnoreSafeguard then
					PassivesManager:ApplyPassive("Safeguard", Character, AttackOwner, AttackData)
				end
			end
			
			if Character:GetAttribute("Zombification") then
				local ReactionTime = Random.new():NextNumber(0, 0.1)
				task.delay(ReactionTime, function()
					if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
					StateMachine:Trigger("TriggerChoice", StateMachine, Character)
				end)
			end
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			Character:SetAttribute("BlockFrames", false)
			Character:SetAttribute("DeflectFrames", false)
			
			StateMachine:Trigger("CancelBlockAnimation", StateMachine, Character)
			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData then
				PlayerData[Character.Name].BankaiActiveData.AutoDeflect = false
			end
			
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerChoice = function(StateMachine, Character, Location, TargetedEntity)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local RNG = Random.new():NextInteger(1, 10)
			if RNG <= 3 then
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character, Location)
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
			elseif RNG > 3 and RNG < 6 then
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character, Location)
				StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
				if not Character:GetAttribute("ShikaiDisabled") then
					StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
				else
					StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
				end
			elseif RNG >= 6 and RNG <= 8 then
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character, Location)
				StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
			else
				StateMachine:Trigger("ReleaseBlock", StateMachine, Character, Location)
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
			end
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackOwner)
			local WindShield = Character:GetAttribute("WindShield")			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.AutoDeflectData and WindShield then
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)

				PlayerData[Character.Name].LastParriedTime = DateTime.now().UnixTimestampMillis
				
				StateMachine:Trigger("CancelParryAnimation", StateMachine, Character)

				Character:SetAttribute("DeflectFrames", true)
				Character:SetAttribute("ParryCooldown", 0)

				--PlayerData[Character.Name].BlockHeld = nil

				AirtimeManager:ReleaseAirtime(Character)
				AirtimeManager:ReleaseAirtime(AttackOwner, "Knockback")

				local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
				local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
				local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
				if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
					CombatAnimations = CombatAnimations.Bankai
				end

				BankaiWeapons:PlayWeaponAnimation(Character, "Parrying" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])

				--[[local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Parrying" .. DeflectAnimation])
				DeflectAnimation:Play()]]

				local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "TheWind", AttackOwner)

				local Stance = Character:GetAttribute("Posture")
				Stance -= DeflectDamage
				if Stance <= 0 then
					Character:SetAttribute("Posture", 0)
				else
					Character:SetAttribute("Posture", Stance)	
				end

				if table.find(Profile.UnlockedSkills, "Blut Vene") and Character:GetAttribute("BlutArterie") then
					local BlutTierData = {
						[1] = SkillData["Blut Vene"];
						[2] = SkillData["Blut Vene 2"];
						[3] = SkillData["Blut Vene 3"];
					}

					local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
					local Amount = BlutTier.Amount
					local BlutDamage = BlutTier.DamageBuff

					local BlutVene = Character:GetAttribute("BlutVene")
					if BlutVene then
						BlutVene += BlutTier.ArterieRestore

						if BlutVene < Amount then
							Character:SetAttribute("BlutVene", BlutVene)
						else
							Character:SetAttribute("BlutVene", Amount)
						end
					end		
				end
				
				PlayerData[Character.Name].BankaiActiveData.AutoDeflectData.ResetTimer = DateTime.now().UnixTimestampMillis
				
				WindShield -= 1
				if WindShield <= 0 then
					WindShield = 0
					
					PlayerData[Character.Name].BankaiActiveData.Timer = DateTime.now().UnixTimestampMillis
					PlayerData[Character.Name].BankaiActiveData.AutoDeflect = false
					Character:SetAttribute("DeflectFrames", false)
					
					SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Block", "SearchByReference")
					
					local BlockAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations.Block)
					BlockAnimation:Play()

					BankaiWeapons:PlayWeaponAnimation(Character, "Block", Profile.ClientData, PlayerData[Character.Name])
					
					task.delay(PlayerData[Character.Name].BankaiActiveData.AutoDeflectData.AutoparryCD, function()
						Character:SetAttribute("WindShield", SpecData.Wind.Shield)
					end)
				end
				
				Character:SetAttribute("WindShield", WindShield)
			end
		end,
	},
	Attacking = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelAttackAnimation", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		CancelAttackAnimation = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Attack", true)
			BankaiWeapons:CancelWeaponAnimation(Character, "Attack", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		TriggerM2 = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FeintTimer")
			if PlayerData[Character.Name].AllowFeint and TimeDifference >= 1500 then
				PlayerData[Character.Name].AllowFeint = false
				Character:SetAttribute("FeintTimer", DateTime.now().UnixTimestampMillis)
				
				local Combo = Character:GetAttribute("Combo")
				Combo -= 1
				if Combo <= 1 then
					Combo = 1
				end
				Character:SetAttribute("Combo", Combo)
				
				StateMachine:Trigger("CancelAttackAnimation", StateMachine, Character)
				
				Character:SetAttribute("HyperArmor", false)
				local HyperArmorHighlight = Character:FindFirstChild("HyperArmorHighlight")
				if HyperArmorHighlight then
					HyperArmorHighlight:Destroy()
				end
				
				local FeintSound = Sounds.Feint:Clone()
				FeintSound.PlayOnRemove = true
				FeintSound.Parent = Character.HumanoidRootPart
				FeintSound:Destroy()
				FeintSound = nil
				
				task.delay(0.13, function()
					StateMachine:Trigger("ReleaseAttacking", StateMachine, Character)
				end)
			end
		end,
		LightAttack = function(StateMachine, Character, DeflectAnimation)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
			if WeaponEquipped then
				local WeaponAnimations = CombatAnimations[WeaponEquipped]
				local WeaponTable

				if WeaponEquipped == "Katana" then
					WeaponTable = WeaponData.KatanaAttackData.LightAttack
					if StatData.Factions[Profile.ClientData.Race] == "Arrancar" or Character:GetAttribute("ZanpakutoState") == 1 then
						WeaponTable = WeaponData.SpecialKatanaData.LightAttack
					elseif Character:GetAttribute("ZanpakutoState") == 2 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						WeaponTable = WeaponData.KatanaAttackData.BankaiData.LightAttack
					end
				else
					if Character:GetAttribute("ZanpakutoState") == 2 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" and WeaponData[WeaponEquipped.. "AttackData"].BankaiData then
						WeaponTable = WeaponData[WeaponEquipped.. "AttackData"].BankaiData.LightAttack
					else
						WeaponTable = WeaponData[WeaponEquipped.. "AttackData"].LightAttack
					end
				end
				
				LightAttacks:LightAttack(Character, StateMachine, WeaponTable, PlayerData[Character.Name], Profile.ClientData)
				
				--[[local LightAttackData = PassivesManager:CreateM1AttackData(Character, WeaponTable, PlayerData[Character.Name], Profile.ClientData)

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
				
				local HyperArmorHighlight
				local Combo = Character:GetAttribute("Combo")
				if Combo == 1 and HyperArmorM1[WeaponEquipped] and not PlayerData[Player.Name].M1HyperArmorCD then
					PlayerData[Player.Name].M1HyperArmorCD = DateTime.now().UnixTimestampMillis
					
					
					task.delay(0.23, function()
						if Character and Character:FindFirstChild("HumanoidRootPart") then
							Character:SetAttribute("HyperArmor", true)
							HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
							HyperArmorHighlight.Parent = Character
						end
					end)
					
					task.delay(HyperArmorCooldown, function()
						if DateTime.now().UnixTimestampMillis - PlayerData[Player.Name].M1HyperArmorCD >= HyperArmorCooldown * 995 then
							PlayerData[Player.Name].M1HyperArmorCD = nil
						end
					end)
				end
				
				ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
				
				local AttackSpeed = PassivesManager:ApplyAttackSpeed(Character, PlayerData[Character.Name], Profile.ClientData)
				local LightAttack = Character.Humanoid.Animator:LoadAnimation(WeaponAnimations["LightAttack" .. Combo])
				LightAttack:Play()
				LightAttack:AdjustSpeed(AttackSpeed)

				Combo += 1
				Character:SetAttribute("Combo", Combo)
				
				if WeaponEquipped == "Nnoitra" and Combo >= 6 then
					LightAttackData.TrueStunTime = 0.7
					LightAttackData.SoftStunTime = 0
					Character.Humanoid.WalkSpeed = 4
				end
				
				local PreM1PassiveCount = 0
				local PreM1Passives = PassivesManager:RequestPassives(Character).PreM1Passives
				for i, v in pairs(PreM1Passives) do
					PreM1PassiveCount += 1
				end
					
				LightAttack.KeyframeReached:Connect(function(KeyframeName)
					if KeyframeName == "HitFrame" then
						if PreM1PassiveCount > 0 then
							local IncreasedRangeProperties = {
								Range = LightAttackData.Properties.Range + 6;
								Width = LightAttackData.Properties.Width + 4;
								Height = LightAttackData.Properties.Height + 5;
								Length = LightAttackData.Properties.Length;
							}
							
							local PreHitDetection = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, IncreasedRangeProperties)
							if PreHitDetection then
								PassivesManager:ApplyPreM1Passives(Character, PreHitDetection, Profile.ClientData)
							end
						end
						local DetectedEntities = HitDetection:SphereMagnitude(Character, Character.HumanoidRootPart.CFrame, LightAttackData.Properties)
						if DetectedEntities then
							local PositiveHit
							local DamagedEntities = CombatManager:ApplyDamage(Character, DetectedEntities, LightAttackData)
							for i, v in ipairs(DamagedEntities) do
								PositiveHit = true
								PassivesManager:ApplyPassive("DuelistsDance", Character, v)
								PassivesManager:ApplyM1Passives(Character, v, PlayerData[Character.Name])
							end
							if Combo >= 6 then
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
						end
						
						if Combo >= 6 and WeaponEquipped == "Nnoitra" then
							local PathData = {Module = ReplicatedStorage.Modules.ClientModules.ClientShikaiCriticals, Skill = "Nnoitra"}
							local RenderDistance = 1000
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "5thM1")
						end

						PassivesManager:PlayCreationAnimations(Character, PlayerData[Character.Name])	

						local LightAttackSound = ReplicatedStorage.Assets.WeaponSounds[WeaponEquipped .. "Swing"]:Clone()
						LightAttackSound.PlayOnRemove = true
						LightAttackSound.Parent = Character.HumanoidRootPart
						LightAttackSound:Destroy()
						LightAttackSound = nil
					elseif KeyframeName == "FeintStart" then
						PlayerData[Character.Name].AllowFeint = true
					elseif KeyframeName == "FeintEnd" then
						PlayerData[Character.Name].AllowFeint = false
						
						local TrailBlacklist = {
							Fist = true;
							ResFist = true;
						}

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
						
						if HyperArmorHighlight then
							HyperArmorHighlight:Destroy()
						end
					end
				end)]]
			else
				StateMachine:SetState("Idle")
			end
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelAttackAnimation", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleaseAttacking = function(StateMachine, Character)
			Character:SetAttribute("HyperArmor", false)
			StateMachine:SetState("WeaponDrawn")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)	
			StateMachine:Trigger("CancelAttackAnimation", StateMachine, Character)		
			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
			local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
				CombatAnimations = CombatAnimations.Bankai
			end
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()
			
			local DashDisabled = {
				Name = "DashDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}
			local FlashstepDisabled = {
				Name = "FlashstepDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}

			PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
			PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)		
			
			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData, Defender)
			PassivesManager:ApplyPassive("FlashTension", Character, Defender, AttackData)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("CancelAttackAnimation", StateMachine, Character)

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	Skill = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			PlayerData[Character.Name].CurrentSkill = nil
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			Character:SetAttribute("HitCheck", nil)
			Character:SetAttribute("HyperArmor", false)
			Character:SetAttribute("HealSkill", nil)
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "Skill", true)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerM2 = function(StateMachine, Character)
			local CurrentSkill = PlayerData[Character.Name].CurrentSkill
			if CurrentSkill and CurrentSkill.TriggerM2 then
				CurrentSkill.TriggerM2(StateMachine, Character, PlayerData[Character.Name])
			end
		end,
		SkillPress = function(StateMachine, Character, KeyPressed)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			if Character:GetAttribute("Zombification") then
				StateMachine:Trigger("ZombieSkillPress", StateMachine, Character, KeyPressed)
			else
				
				local Profile = DataManager:RequestProfile(Player)
				local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]
				
				if InventorySkill ~= "Empty" then
					local Skill = SkillModule[InventorySkill]
					local Item = ItemModule[InventorySkill]
					
					if ServerSkillReqs[InventorySkill] and ServerSkillReqs[InventorySkill].QuincyAbility and Character:GetAttribute("QuincyDisabled") then
						Skill = nil
					end
					
					local Cat = Character:GetAttribute("CatState")
					if Cat and not Skill.Cat then
						Skill = nil
						return
					end
					
					if Skill then
						if PlayerData[Character.Name].ItemEquipped then
							PlayerData[Character.Name].ItemEquipped.Item:Destroy()
							PlayerData[Character.Name].ItemEquipped = nil
						end
						PlayerData[Character.Name].ClickState = nil

						if not PlayerData[Character.Name].WeaponEquipped then
							StateMachine:Trigger("UnsheatheWeapon", StateMachine, Character, Profile.ClientData)
						end

						local ReiatsuValue = Character:GetAttribute("Reiatsu")
						local ReiatsuCost = Skill.ReiatsuCost
						if Character:GetAttribute("PaintItBlack") then
							ReiatsuCost *= Character:GetAttribute("PaintItBlack")
						end
						ReiatsuValue -= ReiatsuCost
						
						local ReiatsuBypass
						local Instinct = PassivesManager:RequestPassives(Character).Instinct
						if Instinct and Character.Humanoid.Health <= Character.Humanoid.MaxHealth * SkillData.Instinct.HealthToTriggerBuff then
							if Skill.Instinct then
								ReiatsuBypass = true
							end
						end
						if Character:GetAttribute("LichtRegen") and InventorySkill == "Licht Regen" then
							ReiatsuBypass = true
						end

						if Character:GetAttribute(KeyPressed) == false and not Skill.Passive then
							if ReiatsuValue >= 0 or ReiatsuBypass then
								if not ReiatsuBypass then
									if PlayerData[Character.Name].SiphonLink then
										task.spawn(function()
											local SiphonReiatsu = PlayerData[Character.Name].SiphonLink:GetAttribute("Reiatsu")
											SiphonReiatsu -= ReiatsuCost
											if SiphonReiatsu <= 0 then
												PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", 0)
											else
												PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", SiphonReiatsu)
											end
										end)
									else
										Character:SetAttribute("Reiatsu", ReiatsuValue)
									end
								end
								Character:SetAttribute("HitCheck", true)

								ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")

								PlayerData[Character.Name].CurrentSkill = Skill
								Skill.SkillFunction(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
							else
								StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
							end
						else
							StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
						end
					elseif Item then
						-- Sheathe weapon push idle state
						
						SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Idle", "SearchByReference")

						Item.ItemFunction(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
					else
						StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
					end
				else
					StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
				end
			end
		end,
		ZombieSkillPress = function(StateMachine, Character, TargetedEntity)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local KeyPressed
			if PlayerData[Character.Name].QueuedSkill then
				KeyPressed = PlayerData[Character.Name].QueuedSkill.Key
			else
				local Keys = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero"}
				KeyPressed = Keys[math.random(1, #Keys)]
			end
			
			if not PlayerData[Character.Name].AttemptingSkill then
				PlayerData[Character.Name].CurrentKeys = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Zero"}
			end
			PlayerData[Character.Name].AttemptingSkill = true

			local SkillInventory = DataManager:RequestSkillInventory(Player)
			local InventorySkill = SkillInventory[KeyPressed]
			local Skill = SkillModule[InventorySkill]

			--local ReiatsuValue = Character:GetAttribute("Reiatsu")
			--ReiatsuValue -= Skill.ReiatsuCost
			
			local Cat = Character:GetAttribute("CatState")
			if Cat and not Skill.Cat then
				Skill = nil
				return
			end
			
			if Skill and Character:GetAttribute(KeyPressed) == false and not Skill.Passive and ServerSkillReqs[InventorySkill].StatReq1.Category ~= "Healing" then
				PlayerData[Character.Name].AttemptingSkill = nil
				Character:SetAttribute("SkillCD", true)
				Character:SetAttribute("HitCheck", true)
				SharedFunctions:CancelAnimation(Character.Humanoid, "Dash", "SearchByReference")
				Skill.SkillFunction(Character, StateMachine, KeyPressed, PlayerData[Character.Name], TargetedEntity, SkillInventory)

				local SkillM1Function = Skill.M1Function
				local SkillM2Function = Skill.M2Function

				local MouseInputSkill = SkillM1Function
				if SkillM2Function then
					local RandomNumber = math.random(1, 2)
					if RandomNumber == 2 then
						MouseInputSkill = SkillM2Function
					end
				end

				if MouseInputSkill then
					task.delay(Random.new():NextNumber(0, 1), function()
						if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
						local Choice = math.random(1, 2)
						if Choice == 1 then
							StateMachine:Trigger("TriggerLAttack", StateMachine, Character, PlayerData[Character.Name], TargetedEntity, SkillInventory)
						else
							StateMachine:Trigger("TriggerM2", StateMachine, Character, PlayerData[Character.Name], TargetedEntity, SkillInventory)
						end
					end)
				end

				local function CheckKey(Key)
					if Character:GetAttribute(Key) == false and SkillInventory[Key] ~= "Empty" then
						if ServerSkillReqs[InventorySkill].StatReq1.Category ~= "Healing" then
							return true
						end 
					end
					return nil
				end

				local DictionaryKeys = {
					One = CheckKey("One");
					Two = CheckKey("Two");
					Three = CheckKey("Three");
					Four = CheckKey("Four");
					Five = CheckKey("Five");
					Six = CheckKey("Six");
					Seven = CheckKey("Seven");
					Eight = CheckKey("Eight");
					Nine = CheckKey("Nine");
					Zero = CheckKey("Zero");
					Minus = CheckKey("Minus");
					Equals = CheckKey("Equals");
				}

				local Keys = {}
				for i, v in pairs(DictionaryKeys) do
					table.insert(Keys, i)
				end
				print(SkillInventory)
				if #Keys > 0 then
					local QueuedKey = Keys[math.random(1, #Keys)]

					PlayerData[Character.Name].QueuedSkill = {
						Key = QueuedKey;
						Name = SkillInventory[QueuedKey];
					}
					print(Character.Name .. " Queued Skill:", SkillInventory[QueuedKey])
					local SkillRange
					if SkillData[SkillInventory[QueuedKey]] and SkillData[SkillInventory[QueuedKey]].Properties then
						SkillRange = SkillData[SkillInventory[QueuedKey]].Properties.Range
					end
					if SkillData[SkillInventory[QueuedKey]].MouseRange then
						SkillRange = SkillData[SkillInventory[QueuedKey]].MouseRange
					end
					if not SkillRange then
						SkillRange = 8
					end
					
					Character:SetAttribute("SkillRange", SkillRange)
				else
					PlayerData[Character.Name].QueuedSkill = nil
					Character:SetAttribute("SkillRange", 6)
				end

				task.delay(math.random(5, 17), function()
					Character:SetAttribute("SkillCD", false)
				end)
			else
				local Keys = PlayerData[Character.Name].CurrentKeys
				table.remove(Keys, table.find(Keys, KeyPressed))

				if #Keys > 0 then
					local NewKeyPressed = Keys[math.random(1, #Keys)]
					StateMachine:Trigger("SkillPress", StateMachine, Character, NewKeyPressed, TargetedEntity)
				else
					StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
					Character:SetAttribute("SkillCD", true)
					task.delay(math.random(5, 10), function()
						Character:SetAttribute("SkillCD", false)
					end)
				end
			end
		end,
		SkillReleaseFromHeld = function(StateMachine, Character, KeyPressed)
			local Player = Players:GetPlayerFromCharacter(Character)
			local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]
			if InventorySkill ~= "Empty" then
				local Skill = SkillModule[InventorySkill]
				if Skill and Skill.ReleaseFunction and Character:GetAttribute(KeyPressed) == false and not Skill.Passive then
					Skill.ReleaseFunction(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
				end
			end
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		ReleaseSkill = function(StateMachine, Character)	
			PlayerData[Character.Name].CurrentSkill = nil
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			Character:SetAttribute("HitCheck", nil)
			Character:SetAttribute("HealSkill", nil)
			Character:SetAttribute("HyperArmor", false)
			StateMachine:SetState("WeaponDrawn")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			PlayerData[Character.Name].CurrentSkill = nil
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "Skill", true)
			Character:SetAttribute("HitCheck", nil)
			Character:SetAttribute("HealSkill", nil)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].CurrentSkill = nil
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			Character:SetAttribute("HitCheck", nil)
			Character:SetAttribute("HealSkill", nil)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Skill", "SearchByReference")

			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)
			if Character:GetAttribute("HyperArmor") == false or (Character:GetAttribute("HyperArmor") == true and AttackData and AttackData.HyperArmorParryCancel) then
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				
				if Character:GetAttribute("HyperArmor") == true and AttackData.HyperArmorParryCancel then
					Character:SetAttribute("HyperArmor", false)
				end
				
				local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
				local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
				local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
				if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
					CombatAnimations = CombatAnimations.Bankai
				end
				
				BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
				local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
				DeflectAnimation:Play()
				
				
				local DashDisabled = {
					Name = "DashDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}
				local FlashstepDisabled = {
					Name = "FlashstepDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}

				PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
				PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)
				
				local AttackData = {
					ImpactSound = "None",
					StunAnimation = "None",
					TrueStunTime = 0,
					SoftStunTime = DeflectAnimation.Length + ParryStunTime,
				}
				StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
			end
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData, Defender)
			PassivesManager:ApplyPassive("FlashTension", Character, Defender, AttackData)
		end,
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData

				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					--local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Draw" .. ClientData.Sheathe])
					--DrawAnimation:Play()

					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1
					
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = false
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 0
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = true
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.UnsheatheFunction then
							ZanpakutoData.UnsheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				end
				
				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end
				
				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end
				
				StateMachine:PushState("WeaponDrawn")
			end
		end,
		--[[SheatheWeapon = function(StateMachine, Character, ClientData)
			if Character:GetAttribute("ZanpakutoState") <= 1 then
				if Character:GetAttribute("ZanpakutoState") == 0 then
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)
					StateMachine:SetState("Idle")

					if not SheatheSoundBlacklist[PlayerData[Character.Name].WeaponEquipped] then
						local SheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].SheatheSound or Sounds.Sheathe
						local ClonedSheathe = SheatheSound:Clone()
						ClonedSheathe.PlayOnRemove = true
						ClonedSheathe.Parent = Character.PrimaryPart
						ClonedSheathe:Destroy()
						ClonedSheathe = nil
					end

					PlayerData[Character.Name].WeaponEquipped = nil

					local WeaponModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					WeaponModel.PrimaryPart.Weld.Enabled = true
					WeaponModel.Parent = Character
					Motor6D.Part1 = nil

					local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = nil

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = true
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 1
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = false
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", true)

								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.SheatheFunction then
							ZanpakutoData.SheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				elseif Character:GetAttribute("ZanpakutoState") == 1 then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
						
					Character:SetAttribute("ZanpakutoState", 0)
					
					if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
						local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
						ShikaiModel:Destroy()
						ShikaiModel = nil

						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
						local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")

						WeaponModel.PrimaryPart.Weld.Enabled = false
						WeaponModel.Parent = Character["Right Arm"]

						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
						Motor6D.Part1 = WeaponModel.PrimaryPart
						Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData

						local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
						local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

						if ZanpakutoData and ZanpakutoData.DoubleHandle then
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
						end
					else
						local ZanpakutoModel = Character["Right Arm"].Zanpakuto
						ZanpakutoModel.Handle[ClientData.WeaponModel]:Destroy()
						ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
						ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
						ZanpakutoModel.PrimaryPart.Trail:Destroy()
						ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
					end
					
					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
					
					local WeaponName = PlayerData[Character.Name].WeaponEquipped
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

					local Idle = "Idle"..math.random(1, 3)
					if WeaponName == "Fist" then
						Idle = "Idle1"
					end

					if not IdleBlacklist[ZanpakutoWeapon] then
						local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
						IdleAnimation:Play()
					end

					if PlayerData[Character.Name].ShikaiActiveData then
						if PlayerData[Character.Name].ShikaiActiveData.Connections then
							for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
								if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
								end

								PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
								PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
							end
						end
						PlayerData[Character.Name].ShikaiActiveData = nil
					end
				end
			end
		end,]]
	},
	ShikaiSkill = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			Character:SetAttribute("HitCheck", nil)
			StateMachine:Trigger("CancelShikaiSkillAnimations", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerM2 = function(StateMachine, Character)
			local CurrentShikaiSkill = PlayerData[Character.Name].CurrentShikaiSkill
			if CurrentShikaiSkill and CurrentShikaiSkill.TriggerM2 then
				CurrentShikaiSkill.TriggerM2(StateMachine, Character, PlayerData[Character.Name])
			end
		end,
		ShikaiSkillPress = function(StateMachine, Character, KeyPressed, NearestEntity)
			if not Character:GetAttribute("Zombification") then
				local ShikaiModule = PlayerData[Character.Name].ShikaiModule
				local ShikaiSkill = ShikaiModule.Keybinds[KeyPressed]
				if ShikaiSkill and ShikaiModule[ShikaiSkill] and Character:GetAttribute(KeyPressed) == false then -- Checks if the keypressed is actually a skill & if off cooldown
					local ReiatsuValue = Character:GetAttribute("Reiatsu")
					local ReiatsuCost = ShikaiModule[ShikaiSkill].ReiatsuCost
					if Character:GetAttribute("PaintItBlack") then
						ReiatsuCost *= Character:GetAttribute("PaintItBlack")
					end
					ReiatsuValue -= ReiatsuCost

					if ReiatsuValue >= 0 then -- Player has enough reiatsu to use the skill
						if PlayerData[Character.Name].SiphonLink then
							task.spawn(function()
								local SiphonReiatsu = PlayerData[Character.Name].SiphonLink:GetAttribute("Reiatsu")
								SiphonReiatsu -= ReiatsuCost
								if SiphonReiatsu <= 0 then
									PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", 0)
								else
									PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", SiphonReiatsu)
								end
							end)
						else
							Character:SetAttribute("Reiatsu", ReiatsuValue)
						end
						Character:SetAttribute("HitCheck", true)

						local Player = Players:GetPlayerFromCharacter(Character)
						local Profile = DataManager:RequestProfile(Player)
						ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
						
						PlayerData[Character.Name].CurrentShikaiSkill = ShikaiModule[ShikaiSkill]
						ShikaiModule[ShikaiSkill].SkillFunction(Character, StateMachine, KeyPressed, PlayerData[Character.Name], nil, Profile.ClientData) -- Starts / calls the shikai skill from the module
					else
						StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
					end
				else
					StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
				end
			else
				StateMachine:Trigger("ZombieShikaiSkill", StateMachine, Character, KeyPressed, NearestEntity)
			end
		end,
		ZombieShikaiSkill = function(StateMachine, Character, Location, NearestEntity)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Block", "SearchByReference")
			Character:SetAttribute("BlockFrames", false)
			if Character:GetAttribute("ZanpakutoState") >= 1 then
				if not PlayerData[Character.Name].AttemptingShikaiSkill then
					if Character:GetAttribute("ZanpakutoState") >= 2 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						PlayerData[Character.Name].CurrentShikaiKeys = {"Z", "X", "C", "T", "G"}
					else
						PlayerData[Character.Name].CurrentShikaiKeys = {"Z", "X", "C"}
					end
				end
				PlayerData[Character.Name].AttemptingShikaiSkill = true

				local Keys = PlayerData[Character.Name].CurrentShikaiKeys
				if #Keys <= 0 then
					PlayerData[Character.Name].AttemptingShikaiSkill = nil
					StateMachine:Trigger("TriggerChoice", StateMachine, Character, Location)
					return
				end
				local KeyPressed = Keys[math.random(1, #Keys)]

				Character.HumanoidRootPart.AlignOrientation.Enabled = true

				local ShikaiModule = PlayerData[Character.Name].ShikaiModule
				local ShikaiSkill = ShikaiModule.Keybinds[KeyPressed]
				if ShikaiSkill and Character:GetAttribute(KeyPressed) == false then
					PlayerData[Character.Name].AttemptingShikaiSkill = nil

					if Character:GetAttribute("ShikaiCD") == false then
						local ReiatsuValue = Character:GetAttribute("Reiatsu")
						local ReiatsuCost = ShikaiModule[ShikaiSkill].ReiatsuCost
						if Character:GetAttribute("PaintItBlack") then
							ReiatsuCost *= Character:GetAttribute("PaintItBlack")
						end
						ReiatsuValue -= ReiatsuCost
						if ReiatsuValue >= 0 then
							Character:SetAttribute("Reiatsu", ReiatsuValue)
							Character:SetAttribute("HitCheck", true)
							
							ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
							
							PlayerData[Character.Name].CurrentShikaiSkill = ShikaiModule[ShikaiSkill]
							ShikaiModule[ShikaiSkill].SkillFunction(Character, StateMachine, KeyPressed, PlayerData[Character.Name], NearestEntity, Profile.ClientData)
							Character:SetAttribute("ShikaiCD", true)

							local MouseInput = ShikaiModule.MouseInput
							local ShikeiHeld = ShikaiModule.Held[KeyPressed]
							if ShikeiHeld and Character:GetAttribute(KeyPressed) == false then
								task.delay(Random.new():NextNumber(0, 3), function()
									if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
									StateMachine:Trigger("SkillReleaseFromHeld", StateMachine, Character, KeyPressed)
								end)
							elseif MouseInput and Character:GetAttribute(KeyPressed) == false then
								local MouseInputSkill = MouseInput[KeyPressed]
								if MouseInputSkill then
									task.delay(Random.new():NextNumber(0, 1), function()
										if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
										local Choice = math.random(1, 2)
										if Choice == 1 then
											StateMachine:Trigger("TriggerLAttack", StateMachine, Character, NearestEntity)
										else
											StateMachine:Trigger("TriggerM2", StateMachine, Character, NearestEntity)
										end
									end)
								end
							end

							task.delay(5, function()
								if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
								Character:SetAttribute("ShikaiCD", false)
							end)
						else
							StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
							StateMachine:Trigger("TriggerCAttack", StateMachine, Character)
						end
					else
						StateMachine:Trigger("TriggerChoice", StateMachine, Character, Location)
					end
				else
					table.remove(PlayerData[Character.Name].CurrentShikaiKeys, table.find(PlayerData[Character.Name].CurrentShikaiKeys, KeyPressed))

					if #PlayerData[Character.Name].CurrentShikaiKeys > 0 then
						StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, Location, NearestEntity)
					else
						StateMachine:Trigger("TriggerChoice", StateMachine, Character, Location)
					end
				end
			else
				StateMachine:Trigger("TriggerChoice", StateMachine, Character, Location)
			end
		end,
		TriggerChoice = function(StateMachine, Character, Location)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local RNG = Random.new():NextInteger(1, 10)
			if RNG <= 5 then
				StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
			elseif RNG > 5  then
				StateMachine:Trigger("ReleaseShikaiSkill", StateMachine, Character)
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
			end
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData, Defender)
			PassivesManager:ApplyPassive("FlashTension", Character, Defender, AttackData)
		end,
		SkillReleaseFromHeld = function(StateMachine, Character, KeyPressed)
			local ShikaiModule = PlayerData[Character.Name].ShikaiModule
			local ShikaiHeldSkills = ShikaiModule.Held
			if ShikaiHeldSkills then
				local ShikaiSkill = ShikaiHeldSkills[KeyPressed]
				if ShikaiSkill and Character:GetAttribute(KeyPressed) == false then
					ShikaiSkill(Character, StateMachine, KeyPressed, PlayerData[Character.Name])
				end
			end
		end,
		ReleaseShikaiSkill = function(StateMachine, Character)
			PlayerData[Character.Name].CurrentShikaiSkill = nil
			
			Character:SetAttribute("HyperArmor", false)
			Character:SetAttribute("HitCheck", nil)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			PlayerData[Character.Name].CurrentShikaiSkill = nil
			
			Character:SetAttribute("HitCheck", nil)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:Trigger("CancelShikaiSkillAnimations", StateMachine, Character)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].CurrentShikaiSkill = nil
			
			Character:SetAttribute("HitCheck", nil)
			StateMachine:Trigger("CancelShikaiSkillAnimations", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)
			if Character:GetAttribute("HyperArmor") == false then
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)

				local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
				local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
				local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
				if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
					CombatAnimations = CombatAnimations.Bankai
				end
				
				BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
				local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
				DeflectAnimation:Play()
				
				local Velocity = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
				if Velocity then
					Velocity:Destroy()
					Velocity = nil
				end
				
				local DashDisabled = {
					Name = "DashDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}
				local FlashstepDisabled = {
					Name = "FlashstepDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}

				PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
				PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)
				
				local AttackData = {
					ImpactSound = "None",
					StunAnimation = "None",
					TrueStunTime = 0,
					SoftStunTime = DeflectAnimation.Length + ParryStunTime,
				}
				StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
			end
		end,
		CancelShikaiSkillAnimations = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")
			if PlayerData[Character.Name].ResActive then
				local Animator = PlayerData[Character.Name].ResActive.ResAnimator
				SharedFunctions:CancelAnimation(Animator, "ShikaiSkill", "SearchByReference")
			end
			if PlayerData[Character.Name].ShikaiActiveData then
				local Animator = PlayerData[Character.Name].ShikaiActiveData.Animator
				if Animator then
					SharedFunctions:CancelAnimation(Animator, "ShikaiSkill", "SearchByReference")
				end
			end
		end,
	},
	ItemState = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			PlayerData[Character.Name].ClickState = nil
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerHierro = function(StateMachine, Character, ...)
			Hierro(Character, ...)
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TriggerSkill = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].WeaponEquipped then
				local Idle = "Idle"..math.random(1, 2)
				if PlayerData[Character.Name].WeaponEquipped ~= "Katana" then
					Idle = "Idle1"
				end

				local Animation = CombatAnimations[PlayerData[Character.Name].WeaponEquipped][Idle]
				if Character:GetAttribute("ZanpakutoState") >= 2 and CombatAnimations[PlayerData[Character.Name].WeaponEquipped]:FindFirstChild("Bankai") then
					Animation = CombatAnimations[PlayerData[Character.Name].WeaponEquipped].Bankai[Idle]
				end

				if not IdleBlacklist[PlayerData[Character.Name].WeaponEquipped] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(Animation)
					IdleAnimation:Play()
				end
			end
			
			StateMachine:SetState("Skill")
			StateMachine:Trigger("SkillPress", StateMachine, Character, ...)
		end,
		TriggerLAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].ClickState then
				local State = PlayerData[Character.Name].ClickState.State
				local KeyPressed = PlayerData[Character.Name].ClickState.Key
				
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local InventoryItem = DataManager:RequestSkillInventory(Player)[KeyPressed]

				if InventoryItem ~= "Empty" then
					local Item = ItemModule[InventoryItem]

					if Item and Item.M1Function then
						Item.M1Function(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
					else
						StateMachine:Trigger("ReleaseItemState", StateMachine, Character)
					end
				else
					StateMachine:Trigger("ReleaseItemState", StateMachine, Character)
				end
			end
		end,
		TriggerM2 = function(StateMachine, Character)
			if PlayerData[Character.Name].ClickState then
				local State = PlayerData[Character.Name].ClickState.State
				local KeyPressed = PlayerData[Character.Name].ClickState.Key
				
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local InventoryItem = DataManager:RequestSkillInventory(Player)[KeyPressed]

				if InventoryItem ~= "Empty" then
					local Item = ItemModule[InventoryItem]

					if Item and Item.M2Function then
						Item.M2Function(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
					end
				else
					StateMachine:Trigger("ReleaseItemState", StateMachine, Character)
				end
			end
		end,
		TriggerItemDrop = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local ItemName = PlayerData[Character.Name].ItemEquipped.ItemName
			ServerStorage.Remotes.DropItem:Fire("DropItem", Player, ItemName)
			
			Player.Backpack:ClearAllChildren()
			PlayerData[Character.Name].ItemEquipped.Item:Destroy()
			PlayerData[Character.Name].ItemEquipped = nil

			StateMachine:Trigger("ReleaseItemState", StateMachine, Character)
		end,
		ReleaseItemState = function(StateMachine, Character)
			PlayerData[Character.Name].ClickState = nil

			Character:SetAttribute("HyperArmor", false)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			if PlayerData[Character.Name].WeaponEquipped then
				local Idle = "Idle"..math.random(1, 2)
				if PlayerData[Character.Name].WeaponEquipped ~= "Katana" then
					Idle = "Idle1"
				end

				local Animation = CombatAnimations[PlayerData[Character.Name].WeaponEquipped][Idle]
				if Character:GetAttribute("ZanpakutoState") >= 2 and CombatAnimations[PlayerData[Character.Name].WeaponEquipped]:FindFirstChild("Bankai") then
					Animation = CombatAnimations[PlayerData[Character.Name].WeaponEquipped].Bankai[Idle]
				end

				if not IdleBlacklist[PlayerData[Character.Name].WeaponEquipped] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(Animation)
					IdleAnimation:Play()
				end
				
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			PlayerData[Character.Name].ClickState = nil
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].ClickState = nil
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
	},
	ClickState = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			PlayerData[Character.Name].ClickState = nil
			
			StateMachine:Trigger("CancelAnimations", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerLAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].ClickState then
				local State = PlayerData[Character.Name].ClickState.State
				local KeyPressed = PlayerData[Character.Name].ClickState.Key
				
				if State == "Shikai" then
					local ShikaiModule = PlayerData[Character.Name].ShikaiModule
					local ShikaiMouseSkill = ShikaiModule.MouseInput[KeyPressed]
					if ShikaiMouseSkill and ShikaiMouseSkill.M1 then
						if Character:GetAttribute(KeyPressed) == false then
							ShikaiMouseSkill.M1(Character, StateMachine, KeyPressed, PlayerData[Character.Name])
						end
					else
						StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
					end
				elseif State == "Skill" then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]

					if InventorySkill ~= "Empty" then
						local Skill = SkillModule[InventorySkill]

						if Skill and Skill.M1Function then
							if Character:GetAttribute(KeyPressed) == false then
								Character:SetAttribute("HitCheck", true)
								Skill.M1Function(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
							end
						else
							StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
						end
					else
						StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
					end
				end
			else
				StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
			end
		end,
		TriggerM2 = function(StateMachine, Character)
			if PlayerData[Character.Name].ClickState then
				local State = PlayerData[Character.Name].ClickState.State
				local KeyPressed = PlayerData[Character.Name].ClickState.Key
				
				if State == "Shikai" then
					local ShikaiModule = PlayerData[Character.Name].ShikaiModule
					local ShikaiMouseSkill = ShikaiModule.MouseInput[KeyPressed]
					if ShikaiMouseSkill and ShikaiMouseSkill.M2 then
						if Character:GetAttribute(KeyPressed) == false then
							ShikaiMouseSkill.M2(Character, StateMachine, KeyPressed, PlayerData[Character.Name])
						end
					else
						StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
					end
				elseif State == "Skill" then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]

					if InventorySkill ~= "Empty" then
						local Skill = SkillModule[InventorySkill]

						if Skill and Skill.M2Function then
							if Character:GetAttribute(KeyPressed) == false then
								Character:SetAttribute("HitCheck", true)
								Skill.M2Function(Character, StateMachine, KeyPressed, PlayerData[Player.Name])
							end
						else
							StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
						end
					else
						StateMachine:Trigger("ReleaseSkill", StateMachine, Character)
					end
				end
			else
				StateMachine:Trigger("ReleaseClickState", StateMachine, Character)
			end
		end,
		TriggerAttackBlocked = function(StateMachine, Character, AttackData, Defender)
			PassivesManager:ApplyPassive("FlashTension", Character, Defender, AttackData)
		end,
		ReleaseClickState = function(StateMachine, Character)
			PlayerData[Character.Name].ClickState = nil
			
			Character:SetAttribute("HyperArmor", false)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			PlayerData[Character.Name].ClickState = nil
			
			StateMachine:PushState("WeaponDrawn")
			StateMachine:Trigger("CancelAnimations", StateMachine, Character)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].ClickState = nil
			
			StateMachine:Trigger("CancelAnimations", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
			local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
				CombatAnimations = CombatAnimations.Bankai
			end
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()
			
			if Character:GetAttribute("HyperArmor") == false then
				local DashDisabled = {
					Name = "DashDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}
				local FlashstepDisabled = {
					Name = "FlashstepDisabled";
					Value = true;
					Duration = StatData.MovementDisableOnParried;
				}

				PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
				PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)
				
				local AttackData = {
					ImpactSound = "None",
					StunAnimation = "None",
					TrueStunTime = 0,
					SoftStunTime = DeflectAnimation.Length + ParryStunTime,
				}
				StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
			end
		end,
		CancelAnimations = function(StateMachine, Character)
			Character:SetAttribute("HitCheck", nil)
			Character:SetAttribute("HealSkill", nil)
			
			SharedFunctions:CancelAnimation(Character.Humanoid, "ShikaiSkill", "SearchByReference")
			SharedFunctions:CancelAnimation(Character.Humanoid, "Skill", "SearchByReference")
			
			if PlayerData[Character.Name].ResActive then
				local Animator = PlayerData[Character.Name].ResActive.ResAnimator
				SharedFunctions:CancelAnimation(Animator, "ShikaiSkill", "SearchByReference")
			end
			if PlayerData[Character.Name].ShikaiActiveData then
				local Animator = PlayerData[Character.Name].ShikaiActiveData.Animator
				if Animator then
					SharedFunctions:CancelAnimation(Animator, "ShikaiSkill", "SearchByReference")
				end
			end
		end,
	},
	CriticalAttacking = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelCriticalAnimation", StateMachine, Character)
			
			Character:SetAttribute("ClashFrames", nil)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		CancelCriticalAnimation = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Critical", "SearchByReference")
			BankaiWeapons:CancelWeaponAnimation(Character, "Critical", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		CriticalAttack = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
			if WeaponEquipped then
				Character:SetAttribute("CriticalCooldown", true)
				
				--local WeaponAnimations = CombatAnimations[WeaponEquipped]
				--local WeaponTable = WeaponData[WeaponEquipped .. "AttackData"].CriticalAttack
				
				local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
				local Critical = WeaponEquipped .. "HeavyAttack"
				if Character:GetAttribute("ZanpakutoState") >= 2 and BankaiFaction and CriticalModule["Bankai" .. WeaponEquipped .. "HeavyAttack"] then
					Critical = "Bankai" .. WeaponEquipped .. "HeavyAttack"
				end
				
				CriticalModule[Critical](StateMachine, Character, PlayerData[Character.Name], Profile.ClientData)
			else
				StateMachine:SetState("Idle")
			end
		end,
		TriggerClashing = function(StateMachine, Character, ...)
			PlayerData[Character.Name].ClashStage = 0
			StateMachine:SetState("Clashing")
			StateMachine:Trigger("ClashStage1", StateMachine, Character, ...)
		end,
		ReleaseHAttack = function(StateMachine, Character)
			Character:SetAttribute("ClashFrames", nil)
			Character:SetAttribute("HyperArmor", false)
			StateMachine:SetState("WeaponDrawn")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
		end,
		AttackDeflected = function(StateMachine, Character, DeflectDamage, DeflectAnimation, ParryStunTime, AttackData)		
			StateMachine:Trigger("CancelCriticalAnimation", StateMachine, Character)	
			Character:SetAttribute("ClashFrames", nil)
			
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			if Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity") then
				Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
			local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
			local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
			if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
				CombatAnimations = CombatAnimations.Bankai
			end
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Deflected" .. DeflectAnimation, Profile.ClientData, PlayerData[Character.Name])
			local DeflectAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations["Deflected" .. DeflectAnimation])
			DeflectAnimation:Play()
			
			local DashDisabled = {
				Name = "DashDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}
			local FlashstepDisabled = {
				Name = "FlashstepDisabled";
				Value = true;
				Duration = StatData.MovementDisableOnParried;
			}

			PassivesManager:ApplyDebuff(Character, {Character}, DashDisabled)
			PassivesManager:ApplyDebuff(Character, {Character}, FlashstepDisabled)
			
			local AttackData = {
				ImpactSound = "None",
				StunAnimation = "None",
				TrueStunTime = 0,
				SoftStunTime = DeflectAnimation.Length + ParryStunTime,
			}
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, AttackData)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			if Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity") then
				Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			
			StateMachine:Trigger("CancelCriticalAnimation", StateMachine, Character)
			
			Character.Humanoid.AutoRotate = true
			Character:SetAttribute("ClashFrames", nil)
			
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("CancelCriticalAnimation", StateMachine, Character)
			Character:SetAttribute("ClashFrames", nil)
			
			if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
				Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			if Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity") then
				Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
			end
			
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
	},
	Clashing = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		ClashStage1 = function(StateMachine, Character, Opponent, InputSetup, ClashType)
			if PlayerData[Character.Name].ClashStage ~= 0 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			local Player = Players:GetPlayerFromCharacter(Character)
			PlayerData[Character.Name].ClashStage = 1
			
			Character:SetAttribute("ClashFrames", nil)
			Character:SetAttribute("ClashScore", 0)
			Opponent:SetAttribute("ClashScore", 0)
			
			ClashSystem.Stage1(Character, Opponent, ClashType)

			local DisplayKey = Player.PlayerGui.DisplayUI.Key
			DisplayKey.Visible = true
			local ClashScore = 1
			local InProcess = false
			local ArrayPosition = 1
			DisplayKey.Text = InputSetup.Set1[ArrayPosition]			

			ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage1", Opponent, Character)	

			PlayerData[Character.Name].InputListener = Character.CharacterHandler.Remotes.ClientClashInput.OnServerEvent:Connect(function(Player, Input)
				if not InProcess then
					InProcess = true
					ArrayPosition += 1
					if ArrayPosition > #InputSetup.Set1 then
						EntityManager:ChangeState(Opponent, "ClashStage2", Character, InputSetup)
						StateMachine:Trigger("ClashStage2", StateMachine, Character, Opponent, InputSetup)
					else
						task.delay(0.06, function()
							if Input == Enum.KeyCode[DisplayKey.Text] then
								print("Success")
								DisplayKey.Text = InputSetup.Set1[ArrayPosition]
								ClashScore = ClashScore + 1
								Character:SetAttribute("ClashScore", ClashScore)
							else
								print("Failure")
								DisplayKey.Text = InputSetup.Set1[ArrayPosition]
								ClashScore = ClashScore - 1
								Character:SetAttribute("ClashScore", ClashScore)
							end
							InProcess = false
						end)
					end
				end
			end)

			PlayerData[Character.Name].OpponentLeft = Opponent.Destroying:Connect(function()
				local Player = Players:GetPlayerFromCharacter(Character)
				local DisplayKey = Player.PlayerGui.DisplayUI.Key
				DisplayKey.Visible = false	
				PlayerData[Character.Name].InputListener:Disconnect()
				PlayerData[Character.Name].InputListener = nil

				PlayerData[Character.Name].ClashStage = 3

				SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

				StateMachine:Trigger("ReleaseClashing", StateMachine, Character)
			end)
		end,
		ClashStage2 = function(StateMachine, Character, Opponent, InputSetup)	
			if PlayerData[Character.Name].ClashStage ~= 1 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			PlayerData[Character.Name].ClashStage = 2
			local Player = Players:GetPlayerFromCharacter(Character)
			local DisplayKey = Player.PlayerGui.DisplayUI.Key
			DisplayKey.Visible = false

			PlayerData[Character.Name].InputListener:Disconnect() -- Disconnects previous remote event connection so inputs will no longer be registered
			PlayerData[Character.Name].InputListener = nil

			local function KeyframeReached(ClashAnimation) -- Function that just saves us repeating the same lines of code twice
				SharedFunctions:CancelAnimation(Character.Humanoid, "Clash1", true)
				ClashAnimation:Play()
				ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage2", Opponent, Character)	
				ClashAnimation.KeyframeReached:Connect(function(KeyframeName) -- Once the keyframes reaches LastFrame
					if KeyframeName == "LastFrame" then
						ClashAnimation:AdjustSpeed(0) -- Pauses the animation
						DisplayKey.Visible = true -- Sets the key to be visible again which toggles the client input again
					elseif KeyframeName == "KnockbackFrame" then

					end
				end)
			end

			local ClashAnimation = ClashSystem.Stage2(Character, Opponent)
			KeyframeReached(ClashAnimation)

			local InProcess = false
			local ArrayPosition = 1
			local ClashScore = 0
			PlayerData[Character.Name].InputListener = Character.CharacterHandler.Remotes.ClientClashInput.OnServerEvent:Connect(function(Player, Input)
				if not InProcess then
					InProcess = true
					ArrayPosition += 1
					if ArrayPosition > #InputSetup.Set2 then
						EntityManager:ChangeState(Opponent, "ClashStage3", Character)
						StateMachine:Trigger("ClashStage3", StateMachine, Character, Opponent)
					else
						task.delay(0.06, function()
							if Input == Enum.KeyCode[DisplayKey.Text] then
								DisplayKey.Text = InputSetup.Set2[ArrayPosition]
								ClashScore += 1
								Character:SetAttribute("ClashScore", ClashScore)
							else
								DisplayKey.Text = InputSetup.Set2[ArrayPosition]
								ClashScore -= 1
								Character:SetAttribute("ClashScore", ClashScore)
							end
							InProcess = false
						end)
					end
				end
			end)
		end,
		ClashStage3 = function(StateMachine, Character, Opponent)
			if PlayerData[Character.Name].ClashStage ~= 2 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			PlayerData[Character.Name].ClashStage = 3
			local Player = Players:GetPlayerFromCharacter(Character)

			PlayerData[Character.Name].InputListener:Disconnect() -- Disconnects previous remote event connection so inputs will no longer be registered
			PlayerData[Character.Name].InputListener = nil	
			local DisplayKey = Player.PlayerGui.DisplayUI.Key 
			DisplayKey.Visible = false -- Sets the key to be invisible again for the small cutscene that takes places

			if Character:GetAttribute("ClashType") == "Attacker" then
				ClashSystem.Stage3(Character, Opponent)
			end

			ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage2", Opponent, Character)	
		end,
		ReleaseClashing = function(StateMachine, Character)
			if PlayerData[Character.Name].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			PlayerData[Character.Name].OpponentLeft:Disconnect()
			PlayerData[Character.Name].OpponentLeft = nil
			PlayerData[Character.Name].ClashStage = nil
			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			Character.HumanoidRootPart.Anchored = false

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			local Player = Players:GetPlayerFromCharacter(Character)
			ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage3")
			StateMachine:SetState("WeaponDrawn")
		end,
		TriggerKnockout = function(StateMachine, Character)
			if PlayerData[Character.Name].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			PlayerData[Character.Name].OpponentLeft:Disconnect()
			PlayerData[Character.Name].OpponentLeft = nil
			PlayerData[Character.Name].ClashStage = nil
			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			Character.HumanoidRootPart.Anchored = false

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			local Player = Players:GetPlayerFromCharacter(Character)
			ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage3")
			
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("Knockout", StateMachine, Character)
		end,
		ClashPostureBreak = function(StateMachine, Character)
			if PlayerData[Character.Name].ClashStage ~= 3 then
				warn(Character.Name .. " clash stage:", PlayerData[Character.Name].ClashStage)
				return
			end
			PlayerData[Character.Name].OpponentLeft:Disconnect()
			PlayerData[Character.Name].OpponentLeft = nil
			PlayerData[Character.Name].ClashStage = nil
			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("ClashScore", nil)
			Character:SetAttribute("ClashType", nil)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			Character.HumanoidRootPart.Anchored = false

			SharedFunctions:CancelAnimation(Character.Humanoid, "Clash", "SearchByReference")

			local Player = Players:GetPlayerFromCharacter(Character)
			ReplicatedStorage.Remotes.ClashEvent:FireClient(Player, "Stage3")
			
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
	},
	--[[AttackBlocked = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		AttackBlocked = function(StateMachine, Character, BlockDamage, Defender)
			PlayerData[Character.Name].AttackBlockedTimer = DateTime.now().UnixTimestampMillis
			
			local Endlag = 0.15
			
			local Combo = Character:GetAttribute("Combo")
			if Combo >= 6 then
				Character:SetAttribute("Combo", 1)
				Endlag = 0.4
			end
			
			if PassivesManager.Passives[Character.Name].FlashTension and PassivesManager.Passives[Character.Name].FlashTension.Toggle == true then
				if PassivesManager.Passives[Character.Name].FlashTension.Defender ~= Defender then
					PassivesManager.Passives[Character.Name].FlashTension.Defender = Defender
					PassivesManager.Passives[Character.Name].FlashTension.Hits = 0
				end
				
				PassivesManager.Passives[Character.Name].FlashTension.Hits += 1
				if PassivesManager.Passives[Character.Name].FlashTension.Hits >= 3 then
					PassivesManager.Passives[Character.Name].FlashTension.Defender = nil
					PassivesManager.Passives[Character.Name].FlashTension.Hits = 0
					
					PerfectFlashstep(Character)
					Character.PrimaryPart.CFrame = Defender.PrimaryPart.CFrame * CFrame.new(Vector3.new(0, 0, 3.2))
				end
			end
			
			task.delay(Endlag, function()
				print(DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].AttackBlockedTimer, Endlag * 995)
				if DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].AttackBlockedTimer >= Endlag * 995 then
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
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.AutoRotate = true
		end,
	},	]]
	Action = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].Resetting then
				PlayerData[Character.Name].Resetting = nil
				local ResetTimer = workspace.Effects[Character.Name]:FindFirstChild("ResetTimer")
				if ResetTimer then
					ResetTimer:Destroy()
				end
			end
			
			if PlayerData[Character.Name].Dance then
				PlayerData[Character.Name].Dance.DisconnectFunction()
			end
			if PlayerData[Character.Name].Piano then
				PlayerData[Character.Name].Piano.DisconnectFunction()
			end
			
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].Resetting then
				PlayerData[Character.Name].Resetting = nil
				local ResetTimer = workspace.Effects[Character.Name]:FindFirstChild("ResetTimer")
				if ResetTimer then
					ResetTimer:Destroy()
				end
			end
			
			if PlayerData[Character.Name].Dance then
				PlayerData[Character.Name].Dance.DisconnectFunction()
			end
			if PlayerData[Character.Name].Piano then
				PlayerData[Character.Name].Piano.DisconnectFunction()
			end
			
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].Resetting then
				PlayerData[Character.Name].Resetting = nil
				local ResetTimer = workspace.Effects[Character.Name]:FindFirstChild("ResetTimer")
				if ResetTimer then
					ResetTimer:Destroy()
				end
			end
			
			if PlayerData[Character.Name].Dance then
				PlayerData[Character.Name].Dance.DisconnectFunction()
			end
			if PlayerData[Character.Name].Piano then
				PlayerData[Character.Name].Piano.DisconnectFunction()
			end
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ShikaiRelease = function(StateMachine, Character, ClientData)
			Character:SetAttribute("ShikaiTimer", DateTime.now().UnixTimestampMillis)
			Character:SetAttribute("ZanpakutoState", 1)
			Character:SetAttribute("HyperArmor", true)
			Character.Humanoid.WalkSpeed = 0
			
			if Character:GetAttribute("Zombification") then
				Character:SetAttribute("ShikaiCD", false)
			end
			
			StateMachine:PushState("WeaponDrawn")
			
			-- Above stuff will need to be done for all shikais so it can just go here
			PlayerData[Character.Name].WeaponEquipped = nil
			
			local ShikaiModule
			if StatData.Factions[ClientData.Race] == "Shinigami" then
				ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[ClientData.Shikai .. "Shikai"])
				PlayerData[Character.Name].ShikaiModule = ShikaiModule
				
				local ShikaiWeapon = ShikaiWeapons:WeaponRelease(Character, StateMachine, ClientData, PlayerData[Character.Name])
				PlayerData[Character.Name].WeaponEquipped = ShikaiWeapon 
				
				ShikaiModule:ReleaseShikai(Character, StateMachine, ClientData, PlayerData[Character.Name])
				
				local ShikaiReleaseSound = ReplicatedStorage.Assets.ShikaiSounds.ShikaiRelease:Clone()
				ShikaiReleaseSound.PlayOnRemove = true
				ShikaiReleaseSound.Parent = Character.PrimaryPart
				ShikaiReleaseSound:Destroy()
				ShikaiReleaseSound = nil
			elseif StatData.Factions[ClientData.Race] == "Arrancar" then
				ShikaiModule = require(ServerStorage.Modules.SkillModules.Res[ClientData.Shikai .. "Res"])
				
				PlayerData[Character.Name].ShikaiModule = ShikaiModule
				
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		
			Character:SetAttribute("Combo", 1) 
			
			local Player = Players:GetPlayerFromCharacter(Character)
			ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, {SkillNames = ShikaiModule.Keybinds})
		end,
		BankaiRelease = function(StateMachine, Character, ClientData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if not Profile.ClientData.HollowCandyCutscene and Player.UserId == 57431326 then
				StateMachine:Trigger("HollowCandyCutscene", StateMachine, Character, ClientData)
				return
			end
			
			if Character:GetAttribute("ZanpakutoState") < 2 then
				Character:SetAttribute("ZanpakutoState", 2)
				Character:SetAttribute("IFrames", true)
				Character:SetAttribute("BankaiDeactivate", true)
				Character:SetAttribute("MedallionBypass", true)
				task.delay(7, function()
					Character:SetAttribute("MedallionBypass", nil)
				end)
				
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				
				Profile.ClientData.BankaiTimer = DateTime.now().UnixTimestamp
				Profile.ClientData.BankaiRaidCheck = true
				
				if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
					Character:SetAttribute("ResRegen", StatData.ResRegenBuff)
				elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					Character:SetAttribute("VollstandigRegen", StatData.VollstandigRegenBuff)
				end
				
				local BankaiHealing = StatData.BankaiHealing
				if DateTime.now().UnixTimestampMillis - Character:GetAttribute("ModeTimer") < StatData.MeterModeHealCD * 1000 then
					--BankaiHealing *= 0.25
				end
				
				local Health = Character.Humanoid.Health
				Health += (Character.Humanoid.MaxHealth * BankaiHealing)
				if Health < Character.Humanoid.MaxHealth then
					Character.Humanoid.Health = Health
				else
					Character.Humanoid.Health = Character.Humanoid.MaxHealth
				end
				Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
				Character:SetAttribute("ModeTimer", DateTime.now().UnixTimestampMillis)
				
				if Character:GetAttribute(SpecData.Deathdealing.LethalDosage.Name) then
					Character:SetAttribute(SpecData.Deathdealing.LethalDosage.Name, 0)
					
					local ClientDeathdealingVollstandig = ReplicatedStorage.Modules.ClientModules.Vollstandig.ClientDeathdealingVollstandig
					local ClientPath = {Module = ClientDeathdealingVollstandig, Skill = "LethalDosageUI"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, ClientPath, SpecData.Deathdealing.LethalDosage.LethalDose)
				end
				
				local ShikaiModule
				if StatData.Factions[ClientData.Race] == "Shinigami" then
					ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[ClientData.Shikai .. "Shikai"])
					PlayerData[Character.Name].ShikaiModule = ShikaiModule
					
					Character:SetAttribute("BankaiDefense", StatData.BankaiDefense)
				elseif StatData.Factions[ClientData.Race] == "Arrancar" then
					ShikaiModule = require(ServerStorage.Modules.SkillModules.Res[ClientData.Shikai .. "Res"])
					PlayerData[Character.Name].ShikaiModule = ShikaiModule
					
					local HierroTierData = {
						[1] = SkillData.Hierro;
						[2] = SkillData["Hierro Mastery"];
						[3] = SkillData["Hierro Mastery 2"];
					}

					local HierroTier = HierroTierData[PassivesManager:RequestPassives(Player).HierroTier]
					if HierroTier then
						local HierroCooldown = HierroTier.Cooldown
						local HierroHits = HierroTier.HitAmount
						local HierroReduction = HierroTier.Reduction

						if Character:GetAttribute("HierroTier") then
							HierroReduction = Character:GetAttribute("HierroTier")
						end

						Character:SetAttribute("RestoreHierro", HierroReduction)
						Character:SetAttribute("RestoreHierroHits", HierroHits)
						Character:SetAttribute("HierroTimer", 0)
					end
				elseif StatData.Factions[ClientData.Race] == "Quincy" then
					if Profile.ClientData.StolenBankai then
						ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[Profile.ClientData.StolenBankai.Shikai .. "Shikai"])
						PlayerData[Character.Name].ShikaiModule = ShikaiModule
						
						ShikaiModule:ReleaseShikai(Character, StateMachine, ClientData, PlayerData[Character.Name])
						
						Character:SetAttribute("BankaiDefense", StatData.BankaiDefense)
					else
						ShikaiModule = require(ServerStorage.Modules.SkillModules.Vollstandig[ClientData.Shikai .. "Vollstandig"])
						PlayerData[Character.Name].ShikaiModule = ShikaiModule
						
						Chat:Chat(Character, ClientData.ReleasePhrase .. ", " .. ClientData.ZanpakutoName)
					end
				end
				
				local BankaiWeapon = ShikaiModule:ReleaseBankai(Character, StateMachine, ClientData, PlayerData[Character.Name])
				if StatData.Factions[ClientData.Race] == "Shinigami" or StatData.Factions[ClientData.Race] == "Quincy" and ClientData.StolenBankai then
					BankaiWeapon = BankaiWeapons:BankaiWeaponRelease(Character, StateMachine, ClientData, PlayerData[Character.Name])
				end
				
				PlayerData[Character.Name].WeaponEquipped = BankaiWeapon			
				
				Character:SetAttribute("Combo", 1)
				Character:SetAttribute("BaseWalkspeed", StatData.WalkSpeeds.Bankai)
				ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, {SkillNames = ShikaiModule.Keybinds})

				local Rate = 1 / 10
				local DrainRate = 2 / 10 -- 2 /
				
				if FactionManager:GladiatorActive() then
					DrainRate = 5 / 10
				end
				
				local ClanBuff = ClanData[Profile.ClientData.Clan].ClanBuff
				if ClanBuff and ClanBuff.BankaiMeter then
					DrainRate *= ClanBuff.BankaiMeter
				end
				local AccessoryMeterDrain = Character:GetAttribute("AccessoryMeterDrain")
				if AccessoryMeterDrain then
					DrainRate *= AccessoryMeterDrain
				end
				
				local Accumulated = 0
				
				while true do
					local Step = task.wait(0.05)
					Accumulated += Step
					if Accumulated >= Rate then
						Accumulated -= Rate

						local BankaiMeter = Character:GetAttribute("BankaiMeter")
						if BankaiMeter < Character:GetAttribute("MaxBankaiMeter") * 0.5 and Character:GetAttribute("BankaiDeactivate") then
							Character:SetAttribute("BankaiDeactivate", nil)
						end

						if BankaiMeter - DrainRate > 0 and Character:GetAttribute("ZanpakutoState") >= 2 then
							BankaiMeter -= DrainRate

							Profile.ClientData.BankaiMeter = BankaiMeter
							Character:SetAttribute("BankaiMeter", BankaiMeter)
						else
							if not Character:GetAttribute("SelfCancel") then
								Profile.ClientData.BankaiMeter = 0
								Character:SetAttribute("BankaiMeter", 0)
							end
							Character:SetAttribute("SelfCancel", nil)
							Profile.ClientData.BankaiTimer = DateTime.now().UnixTimestamp

							StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character)
							StateMachine:Trigger("StopSprint", StateMachine, Character)

							local BankaiDeactivateSound = ReplicatedStorage.Assets.ResSounds.ResDeactivate:Clone()
							BankaiDeactivateSound.PlayOnRemove = true
							BankaiDeactivateSound.Parent = Character.PrimaryPart
							BankaiDeactivateSound:Destroy()
							BankaiDeactivateSound = nil

							PassivesManager:ResetBaseWalkspeed(Character)

							if PlayerData[Character.Name].BankaiActiveData then
								if PlayerData[Character.Name].BankaiActiveData.Connections then
									for i, v in pairs(PlayerData[Character.Name].BankaiActiveData.Connections) do
										if PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i] then
											PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i]()
											PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i] = nil
										end

										PlayerData[Character.Name].BankaiActiveData.Connections[i]:Disconnect()
										PlayerData[Character.Name].BankaiActiveData.Connections[i] = nil
									end
								end
								if PlayerData[Character.Name].BankaiActiveData.DisableFunction then
									task.spawn(function()
										PlayerData[Character.Name].BankaiActiveData.DisableFunction()
									end)
								end

								PlayerData[Character.Name].BankaiActiveData = nil
							end

							if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
								Character:SetAttribute("ZanpakutoState", 1)
								Character:SetAttribute("BankaiDefense", nil)

								local ShikaiWeapon = BankaiWeapons:BankaiSheathe(Character, StateMachine, ClientData, PlayerData[Character.Name], IdleBlacklist)
								PlayerData[Character.Name].WeaponEquipped = ShikaiWeapon
							elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
								Character:SetAttribute("ZanpakutoState", 0)
								Character:SetAttribute("ResRegen", nil)
								Character:SetAttribute("RestoreHierro", nil)
								Character:SetAttribute("RestoreHierroHits", nil)

								ResAccessories:RemoveAccessories(Character, ClientData)
								ResWeapons:ResSheathe(Character, StateMachine, ClientData, PlayerData[Character.Name], IdleBlacklist)
							elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
								Character:SetAttribute("ZanpakutoState", 0)
								Character:SetAttribute("BankaiDefense", nil)
								Character:SetAttribute("VollstandigRegen", nil)

								if table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title) then
									local VollstandigModule = ServerStorage.Modules.SkillModules.Vollstandig:FindFirstChild(Profile.ClientData.Shikai .. "Vollstandig")
									if VollstandigModule then
										local ShikaiModule = require(VollstandigModule)
										PlayerData[Character.Name].ShikaiModule = ShikaiModule
									end
								end

								if Profile.ClientData.StolenBankai then
									local ShikaiWeapon = BankaiWeapons:BankaiSheathe(Character, StateMachine, ClientData, PlayerData[Character.Name], IdleBlacklist)
									PlayerData[Character.Name].WeaponEquipped = ShikaiWeapon
								else
									VollstandigAccessories:RemoveAccessories(Character, ClientData)
								end
							end

							ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, {SkillNames = PlayerData[Character.Name].ShikaiModule.Keybinds})
							break
						end
					end
				end
			else
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		CancelBankai = function(StateMachine, Character, ClientData, SelfCancel)
			if Character:GetAttribute("ZanpakutoState") >= 2 then
				if SelfCancel then
					Character:SetAttribute("SelfCancel", true)
				end
				
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local ClientData = Profile.ClientData
				if StatData.Factions[ClientData.Race] == "Arrancar" then
					Character:SetAttribute("ZanpakutoState", 0)
				elseif StatData.Factions[ClientData.Race] == "Shinigami" then
					Character:SetAttribute("ZanpakutoState", 1)
				elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					Character:SetAttribute("ZanpakutoState", 0)
				end
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		SecondBankaiRelease = function(StateMachine, Character, ClientData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			Character:SetAttribute("ZanpakutoState", 3)
			Character:SetAttribute("IFrames", true)
			Character.Humanoid.WalkSpeed = 0
			
			-- Disconnect first bankai timer and switch it to 2nd bankai 
			Profile.ClientData.BankaiMeter = 0
			Character:SetAttribute("BankaiMeter", 0)
			
			-- Change ShikaiModule here to the 2nd res/visored module
			-- decide what visored gets later
			
			PlayerData[Character.Name].WeaponEquipped = nil
			
			local OriginalShikaiModule = PlayerData[Character.Name].ShikaiModule
			local ShikaiModule
			if StatData.Factions[ClientData.Race] == "Shinigami" then
				ShikaiModule = require(ServerStorage.Modules.SkillModules.Visored[ClientData.Shikai .. "Visored"])
				PlayerData[Character.Name].ShikaiModule = ShikaiModule
			elseif StatData.Factions[ClientData.Race] == "Arrancar" then
				ShikaiModule = require(ServerStorage.Modules.SkillModules.Res[ClientData.Shikai .. "Res2"])
				PlayerData[Character.Name].ShikaiModule = ShikaiModule
			end
			
			local ReleaseSecondBankai = ShikaiModule:ReleaseSecondBankai(Character, StateMachine, ClientData)
			PlayerData[Character.Name].WeaponEquipped = ReleaseSecondBankai
			Character:SetAttribute("Combo", 1)
			ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, {SkillNames = ShikaiModule.Keybinds})
			
			local Rate = 1 / 10
			local DrainRate = 1 / 10 -- Per rate out of 175 max meter
			local Accumulated = 0
			
			while true do
				local Step = task.wait(0.05)
				Accumulated += Step
				
				if Character.Humanoid.Health <= 0 then
					return
				end
				
				if Accumulated >= 1 then
					Accumulated -= 1

					local SecondBankaiMeter = Character:GetAttribute("SecondBankaiMeter")
					SecondBankaiMeter -= DrainRate
					if SecondBankaiMeter > 0 then
						Character:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
					else
						if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
							Character:SetAttribute("ZanpakutoState", 1)
						elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
							Character:SetAttribute("ZanpakutoState", 0)
						end
						Character:SetAttribute("SecondBankaiMeter", 0)

						local Passives = PassivesManager:RequestPassives(Character)
						Passives.M1Passives.SpecialBleedPassive = nil

						PlayerData[Character.Name].ShikaiModule = OriginalShikaiModule
						break
					end
					print("Draining second bankai ult bar")
				end
			end
		end,
		HollowCandyCutscene = function(StateMachine, Character, ClientData)			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if Profile.ClientData.HollowCandyCutscene then
				return
			end
			if Profile.ClientData.Race ~= "Shinigami" then
				return
			end
			
			Profile.ClientData.HollowCandyCutscene = true
			
			DataManager:ModifyProfile(Player, "ClientData", "Race", "Visored", "DontFireRemote")
			DataManager:AddSkill(Player, "Visored Cero")
			
			local ShikaiInfo = {
				Shikai = Profile.ClientData.ShikaiUnlocked;
				Bankai = Profile.ClientData.BankaiUnlocked;
				SecondBankai = true;
			}
			ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, ShikaiInfo)
			
			local VisoredMasks = ServerStorage.Assets.Accessories.VisoredMasks:GetChildren()
			local SelectedMask = 2
			Profile.ClientData.VisoredMask = SelectedMask
			
			local VisoredPool = {
				"Damage";
				"Defense";
				"Speed";
				"Health";
				"Reiatsu";
			}

			local Buff1 = VisoredPool[math.random(1, #VisoredPool)]
			table.remove(VisoredPool, table.find(VisoredPool, Buff1))

			local Buff2 = VisoredPool[math.random(1, #VisoredPool)]
			table.remove(VisoredPool, table.find(VisoredPool, Buff2))

			Profile.ClientData.VisoredPool = {
				VisoredEXP = 0;
				VisoredType = math.random(1, 3);
				Mastered = true;
				Buff1 = Buff1;
				Buff2 = Buff2;
				Downside = VisoredPool[math.random(1, #VisoredPool)]
			}
			
			local CutscenePathData = {Module = ClientProgression, Skill = "HollowCandyCutscene"}
			local UnequipPathData = {Module = ClientProgression, Skill = "VisoredMaskUnequip"}
			local UnequipPathData2 = {Module = ClientProgression, Skill = "VisoredMaskFall"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Character, "ClientEffects", -1, CutscenePathData)
			
			Profile.ClientData.BankaiMeter = Character:GetAttribute("MaxBankaiMeter")
			Profile.ClientData.BankaiTimer = 0
			Profile.ClientData.BankaiRaidCheck = nil
			Profile.ClientData.CurrentBankaiRaidCheck = nil
			Character:SetAttribute("BankaiMeter", Character:GetAttribute("MaxBankaiMeter"))
			Character:SetAttribute("SecondBankaiMeter", Character:GetAttribute("MaxSecondBankaiMeter"))
			
			Character:SetAttribute("IFrames", true)
			Character.Humanoid.AutoRotate = false
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			
			task.delay(4.467, function()
				local VisoredMasks = ServerStorage.Assets.Accessories.VisoredMasks
				local VisoredMask = VisoredMasks["VisoredMask" .. Profile.ClientData.VisoredMask]:Clone()
				local VisoredColors = {}
				if VisoredMask:IsA("Model") then
					for i, v in ipairs(VisoredMask:GetChildren()) do
						VisoredColors[v] = v.Color
						v.Transparency = 1
						v.Material = Enum.Material.Neon
						v.Color = Color3.fromRGB(255, 255, 143)
						v.Anchored = false
					end
				else
					VisoredColors[VisoredMask] = VisoredMask.Color
					VisoredMask.Transparency = 1
					VisoredMask.Material = Enum.Material.Neon
					VisoredMask.Color = Color3.fromRGB(255, 255, 143)
					VisoredMask.Anchored = false
				end
				VisoredMask.Parent = Character

				if VisoredMask:IsA("Model") then
					for i, v in ipairs(VisoredMask:GetChildren()) do
						game:GetService("TweenService"):Create(v, TweenInfo.new(0.5), {Transparency = 0}):Play()
					end
				else
					game:GetService("TweenService"):Create(VisoredMask, TweenInfo.new(0.5), {Transparency = 0}):Play()
				end
				
				task.delay(0.5, function()
					if VisoredMask:IsA("Model") then
						for i, v in ipairs(VisoredMask:GetChildren()) do
							v.Material = Enum.Material.Glass
							v.Color = VisoredColors[v]
						end
					else
						VisoredMask.Material = Enum.Material.Glass
						VisoredMask.Color = VisoredColors[VisoredMask]
					end

					VisoredColors = nil
				end)

				local Weld = Instance.new("Weld")
				Weld.C0 = MaskData.Visored["VisoredMask" .. Profile.ClientData.VisoredMask]
				Weld.Part1 = Character.Head
				
				if VisoredMask:IsA("Model") then
					Weld.Part0 = VisoredMask.PrimaryPart
					Weld.Parent = VisoredMask.PrimaryPart
				else
					Weld.Part0 = VisoredMask
					Weld.Parent = VisoredMask
				end

				local Buff1 = Profile.ClientData.VisoredPool.Buff1
				local Buff2 = Profile.ClientData.VisoredPool.Buff2
				local Downside = Profile.ClientData.VisoredPool.Downside
				local Mastered = Profile.ClientData.VisoredPool.Mastered
				
				if not Profile.ClientData.WeakVisored then
					Character:SetAttribute("Visored" .. Buff1, true)
					Character:SetAttribute("Visored" .. Buff2, true)
				end
				
				Character:SetAttribute("VisoredDownside" .. Downside, true)
				Character:SetAttribute("VisoredMastered", Mastered)
				Character:SetAttribute("VisoredActive", true)

				if Character:GetAttribute("VisoredSpeed") or (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == true) then
					Character:SetAttribute("BaseWalkspeed", Character:GetAttribute("BaseWalkspeed") + StatData.VisoredData.Buffs.Speed.Base)
				end
				if (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == false) then
					Character:SetAttribute("BaseWalkspeed", Character:GetAttribute("BaseWalkspeed") + StatData.VisoredData.Downsides.Speed.Base)
				end

				local Rate = 1 / 10
				local DrainRate = 1 / 10
				local Accumulated = 0
				if not Mastered then
					DrainRate = 2 / 10
				end
				if Character:GetAttribute("VisoredHealth") or (Character:GetAttribute("VisoredDownsideHealth") and Character:GetAttribute("VisoredMastered") == true) then
					DrainRate *= StatData.VisoredHealthVariantDrainRate
				end
				
				task.delay(0.6, function()
					StateMachine:Trigger("BankaiRelease", StateMachine, Character, ClientData)
				end)
				
				while true do
					local Step = task.wait(0.05)
					if Character.Humanoid.Health <= 0 then
						return
					end
					
					Accumulated += Step
					if Accumulated >= Rate then
						Accumulated -= Rate

						local SecondBankaiMeter = Character:GetAttribute("SecondBankaiMeter")
						if SecondBankaiMeter - DrainRate > 0 then
							SecondBankaiMeter -= DrainRate

							Character:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)

							if not Character:GetAttribute("AntiHeal") then
								if Character:GetAttribute("VisoredHealth") or (Character:GetAttribute("VisoredDownsideHealth") and Character:GetAttribute("VisoredMastered") == true) then
									local Health = Character.Humanoid.Health
									local HealthRegen = StatData.VisoredData.Buffs.Health / 10
									if Character:GetAttribute("HSPCut") or FactionManager:GladiatorActive() then
										HealthRegen *= StatData.VisoredHealthCut
									end
									if Character:GetAttribute("BloodyCanvas") then
										HealthRegen *= Character:GetAttribute("BloodyCanvas")
									end
									Health += HealthRegen
									if Health < Character.Humanoid.MaxHealth then
										Character.Humanoid.Health = Health
										if Character.Humanoid.Health > (Character.Humanoid.MaxHealth * 0.3) then
											PassivesManager:ResetBaseWalkspeed(Character)
										end
									else
										Character.Humanoid.Health = Character.Humanoid.MaxHealth
									end
								end
							end
						else
							Character:SetAttribute("SecondBankaiMeter", 0)
							Character:SetAttribute("Visored" .. Buff1, nil)
							Character:SetAttribute("Visored" .. Buff2, nil)
							Character:SetAttribute("VisoredDownside" .. Downside, nil)
							Character:SetAttribute("VisoredMastered", nil)
							Character:SetAttribute("VisoredActive", nil)

							if Profile.ClientData.VisoredPool.Mastered == true then
								if VisoredMask:IsA("Model") then
									for i, v in ipairs(VisoredMask:GetChildren()) do
										v.Material = Enum.Material.Neon
										v.Color = Color3.fromRGB(255, 255, 143)
										TweenService:Create(v, TweenInfo.new(1), {Transparency = 1}):Play()
									end
								else									
									VisoredMask.Material = Enum.Material.Neon
									VisoredMask.Color = Color3.fromRGB(255, 255, 143)
									TweenService:Create(VisoredMask, TweenInfo.new(1), {Transparency = 1}):Play()
								end
								
								Debris:AddItem(VisoredMask, 1)

								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, UnequipPathData)
							else
								Weld:Destroy()
								
								if VisoredMask:IsA("Model") then
									for i, v in ipairs(VisoredMask:GetChildren()) do
										v.CanCollide = true
										v.Material = Enum.Material.Neon
										v.Color = Color3.fromRGB(255, 255, 143)
										TweenService:Create(v, TweenInfo.new(1.5), {Transparency = 1}):Play()
									end
								else									
									VisoredMask.CanCollide = true
									VisoredMask.Material = Enum.Material.Neon
									VisoredMask.Color = Color3.fromRGB(255, 255, 143)
									TweenService:Create(VisoredMask, TweenInfo.new(1.5), {Transparency = 1}):Play()
								end
								
								Debris:AddItem(VisoredMask, 1.5)

								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, UnequipPathData2, VisoredMask)
							end

							PassivesManager:ResetBaseWalkspeed(Character)

							Character:SetAttribute("VisoredTimer", DateTime.now().UnixTimestampMillis)

							break
						end
					end
				end
			end)
		end,
		VisoredRelease = function(StateMachine, Character, ClientData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			if Profile.ClientData.Race == "Visored" and not Character:GetAttribute("VisoredActive") then
				local PathData = {Module = ClientProgression, Skill = "VisoredMaskEquip"}
				local UnequipPathData = {Module = ClientProgression, Skill = "VisoredMaskUnequip"}
				local UnequipPathData2 = {Module = ClientProgression, Skill = "VisoredMaskFall"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Profile.ClientData.VisoredPool.Mastered)
				
				local VisoredHealing = StatData.VisoredHealing
				if DateTime.now().UnixTimestampMillis - Character:GetAttribute("ModeTimer") < StatData.MeterModeHealCD * 1000 then
					--VisoredHealing *= 0.25
				end
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					VisoredHealing = 0
				end
				Character:SetAttribute("ModeTimer", DateTime.now().UnixTimestampMillis)
				
				local Health = Character.Humanoid.Health
				Health += Character.Humanoid.MaxHealth * VisoredHealing
				if Health < Character.Humanoid.MaxHealth then
					Character.Humanoid.Health = Health
				else
					Character.Humanoid.Health = Character.Humanoid.MaxHealth
				end
				
				local Reiatsu = Character:GetAttribute("Reiatsu")
				Reiatsu += Character:GetAttribute("MaxReiatsu") * VisoredHealing
				if Reiatsu < Character:GetAttribute("MaxReiatsu") then
					Character:SetAttribute("Reiatsu", Reiatsu)
				else
					Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
				end
				
				Character:SetAttribute("VisoredActive", true)
				Character:SetAttribute("IFrames", true)
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				
				local VisoredMasks = ServerStorage.Assets.Accessories.VisoredMasks
				local VisoredMask = VisoredMasks["VisoredMask" .. Profile.ClientData.VisoredMask]:Clone()
				local VisoredColors = {}
				if VisoredMask:IsA("Model") then
					for i, v in ipairs(VisoredMask:GetChildren()) do
						VisoredColors[v] = v.Color
						v.Transparency = 1
						v.Material = Enum.Material.Neon
						v.Color = Color3.fromRGB(255, 255, 143)
						v.Anchored = false
					end
				else
					VisoredColors[VisoredMask] = VisoredMask.Color
					VisoredMask.Transparency = 1
					VisoredMask.Material = Enum.Material.Neon
					VisoredMask.Color = Color3.fromRGB(255, 255, 143)
					VisoredMask.Anchored = false
				end
				VisoredMask.Parent = Character

				if VisoredMask:IsA("Model") then
					for i, v in ipairs(VisoredMask:GetChildren()) do
						game:GetService("TweenService"):Create(v, TweenInfo.new(0.5), {Transparency = 0}):Play()
					end
				else
					game:GetService("TweenService"):Create(VisoredMask, TweenInfo.new(0.5), {Transparency = 0}):Play()
				end
				
				task.delay(0.5, function()
					if VisoredMask:IsA("Model") then
						for i, v in ipairs(VisoredMask:GetChildren()) do
							v.Material = Enum.Material.Glass
							v.Color = VisoredColors[v]
						end
					else
						VisoredMask.Material = Enum.Material.Glass
						VisoredMask.Color = VisoredColors[VisoredMask]
					end

					VisoredColors = nil
				end)

				local Weld = Instance.new("Weld")
				Weld.C0 = MaskData.Visored["VisoredMask" .. Profile.ClientData.VisoredMask]
				Weld.Part1 = Character.Head

				if VisoredMask:IsA("Model") then
					Weld.Part0 = VisoredMask.PrimaryPart
					Weld.Parent = VisoredMask.PrimaryPart
				else
					Weld.Part0 = VisoredMask
					Weld.Parent = VisoredMask
				end
				
				local Player = Players:GetPlayerFromCharacter(Character)
				for i, v in ipairs(Character:GetDescendants()) do
					if v:IsA("BasePart") and v:CanSetNetworkOwnership() then
						v:SetNetworkOwner(Player)
					end
				end
				
				local VisoredMaskEquip = Character.Humanoid.Animator:LoadAnimation(Animations.VisoredMaskEquip)
				VisoredMaskEquip:Play()
				VisoredMaskEquip.KeyframeReached:Connect(function(KeyframeName)
					if KeyframeName == "AnimationEnd" then
						local Buff1 = Profile.ClientData.VisoredPool.Buff1
						local Buff2 = Profile.ClientData.VisoredPool.Buff2
						local Downside = Profile.ClientData.VisoredPool.Downside
						local Mastered = Profile.ClientData.VisoredPool.Mastered
						
						if not Profile.ClientData.WeakVisored then
							Character:SetAttribute("Visored" .. Buff1, true)
							Character:SetAttribute("Visored" .. Buff2, true)
						end
						Character:SetAttribute("VisoredDownside" .. Downside, true)
						Character:SetAttribute("VisoredMastered", Mastered)
						Character:SetAttribute("VisoredActive", true)

						if Character:GetAttribute("VisoredSpeed") or (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == true) then
							Character:SetAttribute("BaseWalkspeed", Character:GetAttribute("BaseWalkspeed") + StatData.VisoredData.Buffs.Speed.Base)
						end
						if (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == false) then
							Character:SetAttribute("BaseWalkspeed", Character:GetAttribute("BaseWalkspeed") + StatData.VisoredData.Downsides.Speed.Base)
						end
						
						local Rate = 1 / 10
						local DrainRate = 1 / 10
						local Accumulated = 0
						if not Mastered then
							DrainRate = 2 / 10
						end
						
						Character:SetAttribute("IFrames", false)
						StateMachine:Trigger("ReleaseAction", StateMachine, Character)
						
						while true do
							local Step = task.wait(0.05)
							
							if Character.Humanoid.Health <= 0 then
								return
							end
							
							Accumulated += Step
							if Accumulated >= Rate then
								Accumulated -= Rate

								local SecondBankaiMeter = Character:GetAttribute("SecondBankaiMeter")
								if SecondBankaiMeter - DrainRate > 0 then
									SecondBankaiMeter -= DrainRate

									Character:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)

									if not Character:GetAttribute("AntiHeal") then
										if Character:GetAttribute("VisoredHealth") or (Character:GetAttribute("VisoredDownsideHealth") and Character:GetAttribute("VisoredMastered") == true) then
											local Health = Character.Humanoid.Health
											local HealthRegen = StatData.VisoredData.Buffs.Health / 10
											if Character:GetAttribute("HSPCut") or FactionManager:GladiatorActive() then
												HealthRegen *= StatData.VisoredHealthCut
											end
											if Character:GetAttribute("BloodyCanvas") then
												HealthRegen *= Character:GetAttribute("BloodyCanvas")
											end
											Health += HealthRegen
											if Health < Character.Humanoid.MaxHealth then
												Character.Humanoid.Health = Health
												if Character.Humanoid.Health > (Character.Humanoid.MaxHealth * 0.3) then
													PassivesManager:ResetBaseWalkspeed(Character)
												end
											else
												Character.Humanoid.Health = Character.Humanoid.MaxHealth
											end
										end
									end
								else
									Character:SetAttribute("SecondBankaiMeter", 0)
									Character:SetAttribute("Visored" .. Buff1, nil)
									Character:SetAttribute("Visored" .. Buff2, nil)
									Character:SetAttribute("VisoredDownside" .. Downside, nil)
									Character:SetAttribute("VisoredMastered", nil)
									Character:SetAttribute("VisoredActive", nil)

									if Profile.ClientData.VisoredPool.Mastered == true then
										if VisoredMask:IsA("Model") then
											for i, v in ipairs(VisoredMask:GetChildren()) do
												v.Material = Enum.Material.Neon
												v.Color = Color3.fromRGB(255, 255, 143)
												TweenService:Create(v, TweenInfo.new(1), {Transparency = 1}):Play()
											end
										else									
											VisoredMask.Material = Enum.Material.Neon
											VisoredMask.Color = Color3.fromRGB(255, 255, 143)
											TweenService:Create(VisoredMask, TweenInfo.new(1), {Transparency = 1}):Play()
										end

										Debris:AddItem(VisoredMask, 1)

										NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, UnequipPathData)
									else
										Weld:Destroy()

										if VisoredMask:IsA("Model") then
											for i, v in ipairs(VisoredMask:GetChildren()) do
												v.CanCollide = true
												v.Material = Enum.Material.Neon
												v.Color = Color3.fromRGB(255, 255, 143)
												TweenService:Create(v, TweenInfo.new(1.5), {Transparency = 1}):Play()
											end
										else									
											VisoredMask.CanCollide = true
											VisoredMask.Material = Enum.Material.Neon
											VisoredMask.Color = Color3.fromRGB(255, 255, 143)
											TweenService:Create(VisoredMask, TweenInfo.new(1.5), {Transparency = 1}):Play()
										end

										Debris:AddItem(VisoredMask, 1.5)

										NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, UnequipPathData2, VisoredMask)
									end

									PassivesManager:ResetBaseWalkspeed(Character)

									Character:SetAttribute("VisoredTimer", DateTime.now().UnixTimestampMillis)
									
									break
								end
							end
						end
					end
				end)
			else
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		LetztStilRelease = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			if StatData.Factions[Profile.ClientData.Race] == "Quincy" and Profile.ClientData.LetztStil and not Character:GetAttribute("LetztStilActive") then
				local PathData = {Module = ClientProgression, Skill = "LetztStil"}
				local RenderDistance = 1000

				local LetztStilHealing = StatData.LetztStilHealing
				if DateTime.now().UnixTimestampMillis - Character:GetAttribute("ModeTimer") < StatData.MeterModeHealCD * 1000 then
					--LetztStilHealing *= 0.25
				end
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					LetztStilHealing = 0
				end
				Character:SetAttribute("ModeTimer", DateTime.now().UnixTimestampMillis)

				local Health = Character.Humanoid.Health
				Health += Character.Humanoid.MaxHealth * LetztStilHealing
				if Health < Character.Humanoid.MaxHealth then
					Character.Humanoid.Health = Health
				else
					Character.Humanoid.Health = Character.Humanoid.MaxHealth
				end

				local Reiatsu = Character:GetAttribute("Reiatsu")
				Reiatsu += Character:GetAttribute("MaxReiatsu") * LetztStilHealing
				if Reiatsu < Character:GetAttribute("MaxReiatsu") then
					Character:SetAttribute("Reiatsu", Reiatsu)
				else
					Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
				end
				
				if Profile.ClientData.WeakLetzt then
					Character:SetAttribute("WeakLetzt", true)
				end
				Character:SetAttribute("LetztStilActive", true)
				Character:SetAttribute("IFrames", true)
				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				
				local LetztStilActivate = Character.Humanoid.Animator:LoadAnimation(Animations.LetztStilActivate)
				LetztStilActivate:Play()
				LetztStilActivate.KeyframeReached:Connect(function(KeyframeName)
					if KeyframeName == "EventFrame" then
						local Welds = {
							Wing1 = CFrame.new(-1.61798096, -1.15788651, -0.459365845, 0.994829416, 0.0523359515, 0.087036103, -0.0521367975, 0.99862951, -0.00456136884, -0.0871555507, 0, 0.99619472);
							Wing2 = CFrame.new(-3.58312988, -1.60050583, -0.459381104, 0.994829416, 0.0523359515, 0.087036103, -0.0521367975, 0.99862951, -0.00456136884, -0.0871555507, 0, 0.99619472);
							Wing3 = CFrame.new(-5.3237915, -2.12236404, -0.459365845, 0.994829416, 0.0523359515, 0.087036103, -0.0521367975, 0.99862951, -0.00456136884, -0.0871555507, 0, 0.99619472);
							Wing4 = CFrame.new(-6.76263428, -2.77490616, -0.459381104, 0.994829416, 0.0523359515, 0.087036103, -0.0521367975, 0.99862951, -0.00456136884, -0.0871555507, 0, 0.99619472);
							Particle = CFrame.new(-0.24130249, -0.789001465, 0.360961914, -0.405188471, 0.913545609, -0.0354493111, 0.910069346, 0.406736255, 0.079620555, 0.0871555284, -2.84470181e-09, -0.99619472);
						}

						local LetztStilWing = ServerStorage.Assets.Quincy.LetztStilWing:Clone()
						for i, v in ipairs(LetztStilWing:GetChildren()) do
							v.Transparency = 1
						end
						LetztStilWing.Parent = Character
						
						for i, v in ipairs(LetztStilWing:GetChildren()) do
							if Welds[v.Name] then
								local Weld = Instance.new("Weld")
								Weld.C0 = Welds[v.Name]
								Weld.Part0 = v
								Weld.Part1 = Character.Torso
								Weld.Parent = v
							end
						end
						
						task.spawn(function()
							for i = 1, 4 do
								local Wing = LetztStilWing["Wing" .. i]
								TweenService:Create(Wing, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
								task.wait(0.1)
							end
						end)
						
						local Player = Players:GetPlayerFromCharacter(Character)
						for i, v in ipairs(Character:GetDescendants()) do
							if v:IsA("BasePart") and v:CanSetNetworkOwnership() then
								v:SetNetworkOwner(Player)
							end
						end
						
						NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)
						
						local LetztStilActivateSound = Sounds.LetztStilActivate:Clone()
						LetztStilActivateSound.PlayOnRemove = true
						LetztStilActivateSound.Parent = Character.PrimaryPart
						LetztStilActivateSound:Destroy()
						LetztStilActivateSound = nil
					elseif KeyframeName == "AnimationEnd" then
						Character:SetAttribute("BaseWalkspeed", Character:GetAttribute("BaseWalkspeed") + StatData.LetztStilBaseWalkspeedBuff)

						local Rate = 1 / 10
						local DrainRate = 1 / 10
						local Accumulated = 0
						
						Character:SetAttribute("IFrames", false)
						StateMachine:Trigger("ReleaseAction", StateMachine, Character)
						
						while true do
							local Step = task.wait(0.05)
							if Character.Humanoid.Health <= 0 then
								return
							end
							
							Accumulated += Step
							if Accumulated >= Rate then
								Accumulated -= Rate

								local SecondBankaiMeter = Character:GetAttribute("SecondBankaiMeter")
								if SecondBankaiMeter - DrainRate > 0 then
									SecondBankaiMeter -= DrainRate

									Character:SetAttribute("SecondBankaiMeter", SecondBankaiMeter)
								else
									Character:SetAttribute("SecondBankaiMeter", 0)
									Character:SetAttribute("LetztStilActive", nil)
									Character:SetAttribute("WeakLetzt", nil)
									Character:SetAttribute("VisoredTimer", DateTime.now().UnixTimestampMillis)
									Character:SetAttribute("QuincyDisabled", true)
									Character:SetAttribute("Schrift", nil)

									PassivesManager:ResetBaseWalkspeed(Character)

									if Character:FindFirstChild("LetztStilWing") then
										Character.LetztStilWing:Destroy()
									end

									local LetztStilDeactivateSound = Sounds.LetztStilDeactivate:Clone()
									LetztStilDeactivateSound.PlayOnRemove = true
									LetztStilDeactivateSound.Parent = Character.PrimaryPart
									LetztStilDeactivateSound:Destroy()
									LetztStilDeactivateSound = nil		
									break
								end
							end
						end
						
						local QuincyDisabledDuration = StatData.LetztStilDisabledDuration
						while true do
							local Step = task.wait(0.05)
							
							QuincyDisabledDuration -= Step
							if QuincyDisabledDuration <= 0 then
								Character:SetAttribute("QuincyDisabled", nil)

								local Schrifts = {
									"The Balance";
									"The Almighty";
									"The Wind";
									"The Fear";
									"The Superstar";
									"The Visionary";
									"The Zombie";
									"The Explode";
									"The Deathdealing";
								}

								local Schrift = table.find(Schrifts, Profile.ClientData.Title)
								if Schrift then
									Schrift = Profile.ClientData.Title
									Character:SetAttribute("Schrift", Schrift:gsub("The ", ""))
								end
								
								break
							end
						end
					end					
				end)
			else
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		Purify = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
			if WeaponEquipped then
				local PurifyCheck
				for i, v in ipairs(workspace.Entities:GetChildren()) do
					if v.PrimaryPart and v:GetAttribute("Purify") and not PurifyCheck and not v:GetAttribute("Carried") and not v:GetAttribute("Death") and v ~= Character then
						local Magnitude = (Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
						if Magnitude < 6 then
							PurifyCheck = true

							Character.Humanoid.WalkSpeed = 0
							v.Humanoid.WalkSpeed = 0
							v.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0.5, 0, -3) * CFrame.Angles(0, math.pi, 0)
							
							local PurifyAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.Purification)
							PurifyAnimation:Play()
							PurifyAnimation.KeyframeReached:Connect(function(KeyframeName)
								if KeyframeName == "HitFrame" then
									EntityManager:ChangeState(v, "TriggerPurified", Player)
									
									if not Players:GetPlayerFromCharacter(v) then
										RankManager:AddEXP(Player, StatData.PurifyEXP)
										RankManager:AddShikaiEXP(Player, "Purification", StatData.ShikaiEXP)
									end
									
									StateMachine:Trigger("ReleaseAction", StateMachine, Character)
								elseif KeyframeName == "AnimationEnd" then
									
								end
							end)
						end
					end
				end
				if not PurifyCheck then
					StateMachine:Trigger("ReleaseAction", StateMachine, Character)
				end
			else
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		Reset = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			
			local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.ResetTimer
			local Minutes = TimeDifference / 60
			
			if Minutes >= StatData.ResetCD then
				local ResetTimer = ServerStorage.Assets.Misc.ResetLabel:Clone()
				ResetTimer.Enabled = true
				ResetTimer.Name = "ResetTimer"
				ResetTimer.ExtentsOffsetWorldSpace += Vector3.new(0, 1, 0)
				ResetTimer.Division:Destroy()
				ResetTimer.PlayerName.Text = 30
				ResetTimer.AlwaysOnTop = true
				ResetTimer.Adornee = Character.HumanoidRootPart
				ResetTimer.MaxDistance = 150
				ResetTimer.PlayerToHideFrom = nil
				ResetTimer.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(ResetTimer, 30)
				
				local Timer = 30
				local Rate = 1
				local Accumulated = 0
				
				PlayerData[Character.Name].Resetting = true
				
				while true do
					local Step = task.wait(0.05)
					if Character.Humanoid.Health <= 0 or Character:GetAttribute("CurrentState") ~= "Action" then
						PlayerData[Character.Name].Resetting = nil
						return
					end
					
					Accumulated += Step
					if Accumulated > Rate then
						Accumulated -= Rate
						Timer -= Rate

						if ResetTimer and ResetTimer.Parent then
							ResetTimer.PlayerName.Text = Timer
						end

						if Timer <= 0 then
							Profile.ClientData.ResetTimer = DateTime.now().UnixTimestamp

							Character:SetAttribute("DeathBypass", true)
							StateMachine:SetState("Dying")
							StateMachine:Trigger("TriggerDeath", StateMachine, Character)
							break
						end
					end
				end
			else
				local ResetTimer = Player.PlayerGui.ScreenEffects.ResetTimer:Clone()
				ResetTimer.TextLabel.Text = StatData.ResetCD - math.floor(Minutes) .. " minutes left until reset is available."
				ResetTimer.TextLabel.TextTransparency = 1
				ResetTimer.TextLabel.TextStrokeTransparency = 1
				ResetTimer.Visible = true
				ResetTimer.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(ResetTimer, 2.5)
				
				TweenService:Create(ResetTimer.TextLabel, TweenInfo.new(0.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
				task.delay(2, function()
					TweenService:Create(ResetTimer.TextLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
				end)
				
				StateMachine:Trigger("ReleaseAction", StateMachine, Character)
			end
		end,
		ServerHop = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0

			Character:SetAttribute("IFrames", true)

			local SpawnPosition = Character.HumanoidRootPart.Position
			local Accumulated = 0
			
			if not PlayerData[Player.Name].ServerHopConnection then
				PlayerData[Player.Name].ServerHopConnection = true
				
				while true do
					local Step = task.wait(0.05)
					if Character.Humanoid.Health <= 0 then
						PlayerData[Player.Name].ServerHopConnection = nil
						return
					end

					Accumulated += Step
					if Accumulated > 8 then
						Character:SetAttribute("IFrames", false)
						StateMachine:Trigger("ReleaseAction", StateMachine, Character)
						PlayerData[Player.Name].ServerHopConnection = nil
						break
					end
				end
			end
		end,
		Dance = function(StateMachine, Character, DanceObject)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false
			
			AntiCheatManager:Teleport(Player, DanceObject.TPPart.CFrame)
			DanceObject:SetAttribute("Active", true)
			
			ReplicatedStorage.Remotes.TriggerDance:FireClient(Player, "Enabled")
			
			local DanceUI = ServerStorage.Assets.UIs.DanceDance:Clone()
			DanceUI.Parent = Player.PlayerGui
			DanceUI.Enabled = true
			
			local function RandomNumber()
				local Min, Max = 1, 2
				local RNG = Random.new()
				return RNG:NextNumber(Min, Max)
			end

			local DanceFrame = DanceUI.MainFrame

			local Directions = {
				[1] = "W";
				[2] = "S";
				[3] = "A";
				[4] = "D";
			}
			
			local ArrowInfo = {}
			local Rate = 0.5
			local Accumulated = 0
			
			PlayerData[Character.Name].Dance = {
				DanceObject = DanceObject;
				Connections = {};
				DisconnectFunction = function()
					ReplicatedStorage.Remotes.TriggerDance:FireClient(Player, "Disabled")
					
					for i, v in ipairs(PlayerData[Character.Name].Dance.Connections) do
						PlayerData[Character.Name].Dance.Connections[i]:Disconnect()
						PlayerData[Character.Name].Dance.Connections[i] = nil
					end
					PlayerData[Character.Name].Dance = nil
					DanceUI:Destroy()
					DanceObject:SetAttribute("Active", false)
				end,
			}
			
			PlayerData[Character.Name].Dance.Connections[3] = Player.CharacterRemoving:Connect(function()
				DanceObject:SetAttribute("Active", false)
			end)
			
			PlayerData[Character.Name].Dance.Connections[2] = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated > Rate then
					Accumulated -= Rate
					
					local Info = {
						Time = Rate;
						Direction = math.random(1, 4);
						DanceTimer = DateTime.now().UnixTimestampMillis;
					}

					table.insert(ArrowInfo, Info)
					task.delay(Rate + 0.25, function()
						table.remove(ArrowInfo, table.find(ArrowInfo, Info))
					end)
					
					ReplicatedStorage.Remotes.TriggerDance:FireClient(Player, "Trigger", Info)
				end
			end)
			
			PlayerData[Character.Name].Dance.Connections[1] = Character.CharacterHandler.Remotes.DanceEvent.OnServerEvent:Connect(function(CurrentPlayer, Action, Input)
				if CurrentPlayer == Player then
					if Action == "Pressed" then
						local Success
						
						for i, v in ipairs(ArrowInfo) do
							local Direction = v.Direction
							local DanceTimer = v.DanceTimer
							local Time = v.Time
							
							if Directions[Direction] == Input and not ArrowInfo[i].Success then
								if DateTime.now().UnixTimestampMillis - DanceTimer >= (Time - 0.25) * 1000 then
									Success = true
									ArrowInfo[i].Success = true
									
									JailManager:Dance(Player, true)
									
									local DanceAnimation = Character.Humanoid.Animator:LoadAnimation(Animations[Input .. "Dance"])
									DanceAnimation:Play()
									task.delay(Rate/2, function()
										SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Dance", "SearchByReference")
									end)
								end
							end
						end
						
						if Success then
							DanceObject.Screen.Neon.Color = Color3.fromRGB(135, 255, 133)
							
							local DanceDanceSuccess = Sounds.DanceDanceSuccess:Clone()
							DanceDanceSuccess.PlayOnRemove = true
							DanceDanceSuccess.Parent = Character.HumanoidRootPart
							DanceDanceSuccess:Destroy()
							DanceDanceSuccess = nil
						else
							JailManager:Dance(Player, false)
							
							DanceObject.Screen.Neon.Color = Color3.fromRGB(165, 0, 0)
							
							local DanceDanceFail = Sounds.DanceDanceFail:Clone()
							DanceDanceFail.PlayOnRemove = true
							DanceDanceFail.Parent = Character.HumanoidRootPart
							DanceDanceFail:Destroy()
							DanceDanceFail = nil
						end
						
						task.delay(Rate/2, function()
							DanceObject.Screen.Neon.Color = Color3.fromRGB(97, 143, 167)
						end)
					elseif Action == "Release" then
						PlayerData[Character.Name].Dance.DisconnectFunction()
						StateMachine:Trigger("ReleaseAction", StateMachine, Character)
					end
				end
			end)
		end,
		Piano = function(StateMachine, Character, PianoObject)
			local Player = Players:GetPlayerFromCharacter(Character)

			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false

			AntiCheatManager:Teleport(Player, PianoObject.TPPart.CFrame)
			PianoObject:SetAttribute("Active", true)
			
			Character.HumanoidRootPart.Anchored = true
			
			ReplicatedStorage.Remotes.TriggerPiano:FireClient(Player, "Enabled")
			
			local MoonlightSonata = Sounds.MoonlightSonata:Clone()
			MoonlightSonata.Looped = true
			MoonlightSonata.Parent = Character.HumanoidRootPart
			MoonlightSonata:Play()
			
			for i, v in ipairs(PianoObject:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			
			local MoonlightSonataAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.MoonlightSonata)
			MoonlightSonataAnimation:Play()
			
			PlayerData[Character.Name].Piano = {
				PianoObject = PianoObject;
				Connections = {};
				DisconnectFunction = function()
					ReplicatedStorage.Remotes.TriggerPiano:FireClient(Player, "Disabled")
					
					for i, v in ipairs(PlayerData[Character.Name].Piano.Connections) do
						PlayerData[Character.Name].Piano.Connections[i]:Disconnect()
						PlayerData[Character.Name].Piano.Connections[i] = nil
					end
					PlayerData[Character.Name].Piano = nil
					PianoObject:SetAttribute("Active", false)
					
					for i, v in ipairs(PianoObject:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
					
					SharedFunctions:CancelAnimation(Character.Humanoid.Animator, MoonlightSonataAnimation.Name)
					
					Character.HumanoidRootPart.Anchored = false
					
					MoonlightSonata:Destroy()
					MoonlightSonata = nil
					
					StateMachine:Trigger("ReleaseAction", StateMachine, Character)
				end,
			}

			PlayerData[Character.Name].Piano.Connections[1] = Player.CharacterRemoving:Connect(function()
				PianoObject:SetAttribute("Active", false)
			end)

			PlayerData[Character.Name].Piano.Connections[2] = Character.CharacterHandler.Remotes.PianoEvent.OnServerEvent:Connect(function(CurrentPlayer)
				if CurrentPlayer == Player then
					PlayerData[Character.Name].Piano.DisconnectFunction()

				end
			end)
		end,
		Zombification = function(StateMachine, Character, ZombieOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local ParryStates = { -- Parry/block these moves even out of attack range
				ShikaiSkill = true;
				Skill = true;
				CriticalAttacking = true;
			}

			local ZombieSettings = {
				AggroDistance = 100;
				ExecuteRange = 5;
				AttackRange = {
					Quincy = 5;
					Shinigami = 5;
					Arrancar = 5;
					Visored = 5;
					Vastocar = 5;
					VastoLorde = 5;
					LostSoul = 5;
					Adjuchas = 5;
					Fishbone = 5;
					Frisker = 5;
					Menos = 5;
					Bawabawa = 15;
				};	
			}
			
			local FlashstepCooldown
			local HasFlashstep
			if table.find(Profile.UnlockedSkills, "Flashstep") then
				HasFlashstep = true
				
				local FlashstepMasteries = PassivesManager:RequestPassives(Character).FlashstepMastery
				FlashstepCooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			end
			
			local Pathcount = 0
			local Wander = false
			
			local function Behavior(Character, NearestEntity)
				if NearestEntity:FindFirstChild("HumanoidRootPart") and NearestEntity:GetAttribute("EntityType") then
					local EntityType = NearestEntity:GetAttribute("EntityType")
					local Direction = (Character.PrimaryPart.Position - NearestEntity.PrimaryPart.Position).Unit
					local Location = (NearestEntity.PrimaryPart.CFrame + Direction * (ZombieSettings.AttackRange[EntityType])).Position
					local Distance = (Character.HumanoidRootPart.Position - Location).Magnitude
					local WaitingLocation = (NearestEntity.PrimaryPart.CFrame + Direction * 25).Position

					local CurrentAttacker = false
					--[[local Player = Players:GetPlayerFromCharacter(NearestEntity)
					if NearestEntity:GetAttribute("CurrentAttacker") ~= nil and NearestEntity:GetAttribute("CurrentAttacker") ~= Character.Name and Player then	
						CurrentAttacker = Character.Name
					end]]

					if CurrentAttacker then
						EntityManager:ChangeState(Character, "TriggerSprint")
						Character.Humanoid:MoveTo(WaitingLocation)
					elseif Distance > ZombieSettings.AggroDistance then
						Pathcount += 1
						EntityManager:ChangeState(Character, "StopSprint")
					elseif Distance <= ZombieSettings.ExecuteRange and NearestEntity:GetAttribute("CurrentState") == "Unconscious" then
						EntityManager:ChangeState(Character, "TriggerExecute")
					elseif Distance <= ZombieSettings.ExecuteRange and NearestEntity:GetAttribute("CurrentState") == "Dying" then
						return
					elseif ParryStates[NearestEntity:GetAttribute("CurrentState")] and not NearestEntity:GetAttribute("HealSkill") then
						--EntityManager:ChangeState(NPC, "TriggerParry", Location)
						EntityManager:ChangeState(Character, "TriggerDefendChoice")
					elseif Distance <= Character:GetAttribute("SkillRange") and Character:GetAttribute("SkillCD") == false and not Character:GetAttribute("SkillDisabled") then
						EntityManager:ChangeState(Character, "TriggerSkill", NearestEntity)
					elseif Distance <= ZombieSettings.AttackRange[EntityType] then
						if NearestEntity:GetAttribute("BlockFrames") then
							if Character:GetAttribute("CriticalCooldown") == false then
								EntityManager:ChangeState(Character, "TriggerCAttack")
							else
								EntityManager:ChangeState(Character, "TriggerAttackChoice", Location, NearestEntity)
							end
						elseif NearestEntity:GetAttribute("CurrentState") == "Attacking" then
							EntityManager:ChangeState(Character, "TriggerDefendChoice")
						elseif Character:GetAttribute("ShikaiCD") == false and not Character:GetAttribute("ShikaiDisabled") then
							EntityManager:ChangeState(Character, "TriggerShikaiSkill", Location, NearestEntity)
						else
							EntityManager:ChangeState(Character, "TriggerLAttack", Location)
						end
					else
						Pathcount += 1
						local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
						local DashTime = DateTime.now().UnixTimestampMillis - Character:GetAttribute("DashTimer")
						
						local Cooldown = FlashstepCooldown
						local MaxHealth = Character.Humanoid.MaxHealth
						local Health = Character.Humanoid.Health

						if Health <= MaxHealth * 0.8 then
							local HealthRange = (MaxHealth * 0.8) - 1
							local FlashstepCDRange = FlashstepCooldown - StatData.FlashstepCooldownScale * FlashstepCooldown
							local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + StatData.FlashstepCooldownScale * FlashstepCooldown
							Cooldown = ScaledFlashstepCD
						end
						
						if FlashstepCooldown and TimeDifference >= Cooldown and not Character:GetAttribute("FlashstepDisabled") then
							EntityManager:ChangeState(Character, "TriggerFlashstep")
						elseif DashTime >= 1750 and not Character:GetAttribute("DashDisabled") then
							EntityManager:ChangeState(Character, "TriggerDash", "W")
						else
							EntityManager:ChangeState(Character, "TriggerSprint")
						end

						Character.Humanoid:MoveTo(NearestEntity.HumanoidRootPart.Position)

						local HeightDifference = (NearestEntity.PrimaryPart.Position.Y - Character.PrimaryPart.Position.Y)
						if HeightDifference > 2 then
							Character.Humanoid.Jump = true
						end
					end
				end
			end
			
			local AlignOrientation = Instance.new("AlignOrientation")
			AlignOrientation.PrimaryAxisOnly = true
			AlignOrientation.Attachment0 = Character.HumanoidRootPart.RootAttachment
			AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			AlignOrientation.RigidityEnabled = true
			AlignOrientation.Parent = Character.HumanoidRootPart
			
			ReplicatedStorage.Remotes.PlayerControlEvent:FireClient(Player, "Disabled")
			
			Character:SetAttribute("Zombification", true)
			Character:SetAttribute("SkillRange", 9)
			Character:SetAttribute("ShikaiCD", true)
			Character:SetAttribute("SkillCD", false)
			
			local Gewelle = Players:GetPlayerFromCharacter(ZombieOwner)
			local GewelleCharacter = ZombieOwner
			
			if Character:GetAttribute("ZanpakutoState") >= 1 then
				Character:SetAttribute("ShikaiCD", false)
			end
			
			local function RandomOffset()
				local Min, Max = -10, 10
				local RNG = Random.new()
				return CFrame.new(RNG:NextNumber(Min, Max), 0, RNG:NextNumber(Min, Max))
			end
			
			local GewelleOffset = RandomOffset()
			
			local Regen = 0 / 10
			local Accumulated = 0
			local RegenRate = 1 / 10
			
			PlayerData[Character.Name].ZombieConnection = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated > RegenRate then
					Accumulated -= RegenRate
					
					local Health = Character.Humanoid.Health + Regen
					if Health < Character.Humanoid.MaxHealth then
						Character.Humanoid.Health = Health
					else
						Character.Humanoid.Health = Character.Humanoid.MaxHealth
					end
					
					Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
				end
				
				local NearestEntity, NearestDistance
				for i, Entity in ipairs(game.Workspace.Entities:GetChildren()) do
					local NotInParty = true
					
					local PlayerEntity = Players:GetPlayerFromCharacter(Entity)
					if PlayerEntity then
						local GewelleParty = Gewelle:GetAttribute("Party")
						local CharacterParty = PlayerEntity:GetAttribute("Party")
						if GewelleParty ~= nil and CharacterParty ~= nil then
							if GewelleParty == CharacterParty then
								NotInParty = nil
							end
						end
					end
					
					local QuincyImmune
					if ZombieOwner:GetAttribute("Schrift") == "Zombie"  then
						QuincyImmune = Entity:GetAttribute("EntityType") == "Quincy"
					end
					
					if Entity.Name ~= Character.Name and Entity.Name ~= Character:GetAttribute("ZombieOwner") and Entity:FindFirstChild("HumanoidRootPart") and Entity.Humanoid.Health > 0 then
						if NotInParty and not Entity:GetAttribute("Zombification") and Entity.PrimaryPart and not Entity:GetAttribute("Execution") and not QuincyImmune then
							local Magnitude = (Character.PrimaryPart.Position - Entity.PrimaryPart.Position).Magnitude
							if Magnitude < ZombieSettings.AggroDistance then
								if not NearestEntity then -- Checks if there is not a target stored in the variable otherwise it will compare to nil and error 
									NearestEntity, NearestDistance = Entity, Magnitude
								else
									if Magnitude < NearestDistance then
										NearestEntity, NearestDistance = Entity, Magnitude
									end
								end
							end
						end
					end
				end
				
				Character.Humanoid.AutoRotate = false
				
				if NearestEntity then
					--EntityManager:ChangeState(Character, "ReleaseWalk")
					AlignOrientation.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, NearestEntity.HumanoidRootPart.Position)
					Behavior(Character, NearestEntity)
				else
					if GewelleCharacter:FindFirstChild("HumanoidRootPart") then
						local Distance = (Character.HumanoidRootPart.Position - (GewelleCharacter.HumanoidRootPart.CFrame * GewelleOffset).Position).Magnitude
						if Distance > 20 and not Character:GetAttribute("InsideShadowGarden") then
							AlignOrientation.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, GewelleCharacter.HumanoidRootPart.Position)
							
							if Distance > 100 then
								AntiCheatManager:Teleport(Player, (GewelleCharacter.HumanoidRootPart.CFrame * GewelleOffset))
							end
							
							Pathcount += 1
							local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
							local DashTime = DateTime.now().UnixTimestampMillis - Character:GetAttribute("DashTimer")
							if FlashstepCooldown and TimeDifference >= FlashstepCooldown and not Character:GetAttribute("FlashstepDisabled") then
								EntityManager:ChangeState(Character, "TriggerFlashstep")
							elseif DashTime >= 1750 and not Character:GetAttribute("DashDisabled") then
								EntityManager:ChangeState(Character, "TriggerDash", "W")
							else
								EntityManager:ChangeState(Character, "TriggerSprint")
							end

							Character.Humanoid:MoveTo((GewelleCharacter.HumanoidRootPart.CFrame * GewelleOffset).Position)

							local HeightDifference = (GewelleCharacter.PrimaryPart.Position.Y - Character.PrimaryPart.Position.Y)
							if HeightDifference > 2 then
								Character.Humanoid.Jump = true
							end
						else
							StateMachine:Trigger("StopSprint", StateMachine, Character)
						end
					else
						-- If Gewelle left the game path randomly

					--[[if Wander == false then
						AlignOrientation.Enabled = false
						Pathcount += 1
						Wander = true
						EntityManager:ChangeState(Character, "TriggerWalk")
					end]]
					end
				end
				
				if Character:GetAttribute("CurrentState") == "Unconscious" then
					AlignOrientation.Enabled = false
				else
					AlignOrientation.Enabled = true
				end
			end)
			
			StateMachine:Trigger("ReleaseAction", StateMachine, Character)
		end,
		BankaiQuest = function(StateMachine, Character)
			PlayerData[Character.Name].BankaiQuest = true
			
			Character:SetAttribute("IFrames", true)
			
			local PathData = {Module = ClientShikaiProgress, Skill = "BankaiRequest"}
			local RenderDistance = -1

			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local ShikaiPersonality = Profile.ClientData.ShikaiPersonality
			local ShinigamiRank = Profile.ClientData.ShinigamiRank
			
			local SavedCFrame = Character.HumanoidRootPart.CFrame
			AntiCheatManager:LockSavedPosition(Player, SavedCFrame.Position)

			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false

			local InnerWorld = InnerWorlds:Setup(Player, "Quest")
			local SpawnPosition = (InnerWorld * CFrame.new(Vector3.new(0, 0, -150))).Position
			
			local function WhiteFade(Time)
				local Info = TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
				WhiteFade.Visible = true
				WhiteFade.Parent = Player.PlayerGui.ScreenEffects
				Debris:AddItem(WhiteFade, Time * 2)
				TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()
				
				task.delay(Time, function()
					TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
				end)
			end
			
			WhiteFade(3)

			task.delay(3, function()
				if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
					Character:SetAttribute("IFrames", false)
					
					AntiCheatManager:Teleport(Player, InnerWorld)
					StateMachine:Trigger("ReleaseAction", StateMachine, Character)
					
					local CorrectSwords = {}
					local BankaiSwords = {}
					local ClickConnections = {}
	
					local SwordSpawns = workspace.InnerWorldPlots[Character.Name .. "InnerWorld"].Swords:GetChildren()
					local SwordAmount = 3
					local Graces = 3
					
					for i, v in ipairs(SwordSpawns) do
						local Sword = ReplicatedStorage.Assets.Effects.KisukeSword:Clone()
						Sword.Anchored = true
						Sword.CFrame = v.CFrame * CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.pi)
						Sword.Parent = workspace.InnerWorldPlots[Character.Name .. "InnerWorld"]
						
						local ClickDetector = Instance.new("ClickDetector")
						ClickDetector.MaxActivationDistance = 8
						ClickDetector.Parent = Sword
						
						local Clicked
						local Connection
						Connection = ClickDetector.MouseClick:Connect(function(CurrentPlayer)
							if CurrentPlayer == Player and not Clicked then
								local Magnitude = (CurrentPlayer.Character.HumanoidRootPart.Position - Sword.Position).Magnitude
								if Magnitude <= 8 then
									Clicked = true
									
									if table.find(BankaiSwords, v) then
										table.remove(BankaiSwords, table.find(BankaiSwords, v))
										SwordAmount -= 1
										
										Sword.Color = Color3.fromRGB(104, 148, 152)
										TweenService:Create(Sword, TweenInfo.new(0.5), {Transparency = 1}):Play()
										ClickDetector:Destroy()
										
										local SwordPositive = ReplicatedStorage.Assets.ShikaiSounds.SwordPositive:Clone()
										SwordPositive.PlayOnRemove = true
										SwordPositive.Parent = Sword
										SwordPositive:Destroy()
										SwordPositive = nil
										
										if SwordAmount <= 0 then
											Profile.ClientData.BankaiRequirements.BankaiReady = true
											Profile.ClientData.BankaiRequirements.BankaiFight = true
											-- success, start bankai fight
											
											WhiteFade(3)

											task.delay(3, function()
												if PlayerData[Player.Name] then
													PlayerData[Character.Name].BankaiQuest = nil

													InnerWorlds:Cleanup(Player)
													AntiCheatManager:Teleport(Player, SavedCFrame)
													AntiCheatManager:UnlockSavedPosition(Player)
												end
											end)
										end
									else
										Graces -= 1
										
										Sword.Color = Color3.fromRGB(255, 0, 0)
										
										local SwordNegative = ReplicatedStorage.Assets.ShikaiSounds.SwordNegative:Clone()
										SwordNegative.PlayOnRemove = true
										SwordNegative.Parent = Sword
										SwordNegative:Destroy()
										SwordNegative = nil
										
										TweenService:Create(Sword, TweenInfo.new(0.5), {Transparency = 1}):Play()
										ClickDetector:Destroy()
										
										if Graces <= 0 then
											Profile.ClientData.BankaiRequirements.BankaiSwordTimer = DateTime.now().UnixTimestamp
											
											WhiteFade(3)

											task.delay(3, function()
												if PlayerData[Player.Name] then
													PlayerData[Character.Name].BankaiQuest = nil

													InnerWorlds:Cleanup(Player)
													AntiCheatManager:Teleport(Player, SavedCFrame)
													AntiCheatManager:UnlockSavedPosition(Player)
												end
											end)
										else
											local GraceSettings = {
												Material = Enum.Material.Neon;
												Transparency = 0;
											}
											local GraceColor = Color3.fromRGB(104, 148, 152)
											local RandomSword = BankaiSwords[math.random(1, #BankaiSwords)]

											local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
											local PathData = {Module = ClientProgression, Skill = "VastoLordeQuest"}
											local RenderDistance = -1
											NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData, RandomSword.CFrame, GraceColor, GraceSettings)
										end
									end
								end
							end
						end)
						table.insert(ClickConnections, Connection)
					end
					
					InnerWorlds:SetupConnections(Player, ClickConnections)
					
					for i = 1, SwordAmount do
						local RandomSword = SwordSpawns[math.random(1, #SwordSpawns)]
						table.insert(BankaiSwords, RandomSword)
						table.remove(SwordSpawns, table.find(SwordSpawns, RandomSword))
					end
				else
					InnerWorlds:Cleanup(Player)
				end
			end)
		end,
		VollstandigQuest = function(StateMachine, Character)
			if not Character:GetAttribute("RegenDisabled") then
				Character:SetAttribute("IFrames", true)
				Character:SetAttribute("RegenDisabled", true)
				Character:SetAttribute("InsideInnerWorld", true)
				Character:SetAttribute("CurrentOST", "BankaiQuest")

				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local ShikaiPersonality = Profile.ClientData.ShikaiPersonality
				local ShinigamiRank = Profile.ClientData.ShinigamiRank

				Profile.ClientData.BankaiRequirements.BankaiSwordTimer = DateTime.now().UnixTimestamp
				
				PlayerData[Character.Name].VollstandigQuest = true
				
				local SavedCFrame = Character.HumanoidRootPart.CFrame
				AntiCheatManager:LockSavedPosition(Player, SavedCFrame.Position)

				Character.Humanoid.WalkSpeed = 0
				Character.Humanoid.JumpHeight = 0
				Character.Humanoid.AutoRotate = false

				local InnerWorld = InnerWorlds:Setup(Player, "VollstandigQuest")

				local function WhiteFade(Time)
					local Info = TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
					local WhiteFade = Player.PlayerGui.ScreenEffects.WhiteFade:Clone()
					WhiteFade.Visible = true
					WhiteFade.Parent = Player.PlayerGui.ScreenEffects
					Debris:AddItem(WhiteFade, Time * 2)
					TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 0}):Play()

					task.delay(Time, function()
						TweenService:Create(WhiteFade, Info, {BackgroundTransparency = 1}):Play()
					end)
				end

				WhiteFade(3)

				task.delay(3, function()
					if PlayerData[Player.Name] and Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
						Character:SetAttribute("IFrames", false)

						AntiCheatManager:Teleport(Player, InnerWorld)
						StateMachine:Trigger("ReleaseAction", StateMachine, Character)

						local Dummy = EntityManager:CreateEntity("Dummy", "Dummy", (InnerWorld * CFrame.new(0, -50, 0)).Position, {Race = "Shinigami"})
						Dummy.HumanoidRootPart.Anchored = true
						EntityManager:ChangeState(Dummy, "UnsheatheWeapon", {})
						Dummy:SetAttribute("IFrames", true)
						Dummy:SetAttribute("GripBypass", true)
						Dummy:SetAttribute("Carried", true)

						local AuswahlenData = {
							Rate = 3;
							Windup = 2;

							RateRestore = 0.5;

							RateDecreaseMin = 0.45;
							RateDecreaseMax = 0.75;
							WindupDecreaseMin = 0.35;
							WindupDecreaseMax = 0.65;
							TimeTillIncrease = 4;

							RateCap = 1.5;
							WindupCap = 0.5;

							HitEffect = "SpiritBow";
							ImpactSound = "None";
							
							DisabledEnhancedSteps = true,
							NoParryCancel = true,

							NoCounter = true,
							Blockable = true,
							Parryable = true,

							Damage = 125,
							TrueDamage = true,
							
							PercentPosture = 1,
							BlockDamage = 99,
							DeflectDamage = 99,

							TrueStunTime = 0.1,
							SoftStunTime = 0.1,

							Properties = {
								Range = 27.5,
								Width = 50,
								Height = 50,
								Length = 0,
							};
						}

						PlayerData[Player.Name].VollstandigQuestDummy = Dummy
						
						local PathData = {Module = ClientProgression, Skill = "Auswahlen"}
						local RenderDistance = 1000
						NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "1")
						
						local CurrentRate = AuswahlenData.Rate
						local CurrentDelay = AuswahlenData.Windup

						local Duration = StatData.VollstandigQuestDuration
						local TickAccumulated = 0
						local Accumulated = 0
						
						while true do
							local Step = task.wait(0.05)
							if Character.Humanoid.Health <= 0 then
								return
							end
							
							Accumulated += Step
							TickAccumulated +=  Step
							Duration -= Step

							if Duration <= 0 then
								PlayerData[Player.Name].VollstandigQuestDummy = nil

								task.delay(2.5, function()
									EntityManager:ForceState(Dummy, "Dying")
									EntityManager:ChangeState(Dummy, "TriggerDeath")
								end)

								local SeatOffset = CFrame.new(0.0975036621, -2.18868256, 1.55093539, 9.9347659e-08, 8.68524799e-15, -1, -8.74227766e-08, 1, 0, 1, 8.74227766e-08, 9.9347659e-08)
								local Offset = CFrame.new(0.396820068, 0, -6.78979349, -1, 0, 0, 0, 1, 0, 0, 0, -1)

								local Almighty = ServerStorage.Assets.Quincy.AlmightyNPC:Clone()
								Almighty:PivotTo(InnerWorld * CFrame.new(0, -3, 0))
								Almighty.Parent = workspace.Effects[Character.Name]

								local AlmightySeat = ServerStorage.Assets.Quincy.AlmightySeat:Clone()
								AlmightySeat:PivotTo(InnerWorld * CFrame.new(0, -3, 0) * SeatOffset)
								AlmightySeat.Parent = workspace.Effects[Character.Name]

								table.insert(PlayerData[Player.Name].Debris, Almighty)
								table.insert(PlayerData[Player.Name].Debris, AlmightySeat)

								local ClickDetector = Instance.new("ClickDetector")
								ClickDetector.Parent = Almighty

								local Connection
								Connection = ClickDetector.MouseClick:Connect(function(CurrentPlayer)
									if CurrentPlayer == Player then
										Connection:Disconnect()
										Connection = nil

										PlayerData[Character.Name].VollstandigQuest = nil

										Character.HumanoidRootPart.Anchored = true
										AntiCheatManager:Teleport(Player, InnerWorld * CFrame.new(0, -3, 0) * Offset)

										local IWorshipTheKingAnimation = Character.Humanoid.Animator:LoadAnimation(VollstandigAnimations.IWorshipTheKingPlayer)
										IWorshipTheKingAnimation:Play()

										local IWorshipTheKingKingAnimation = Almighty.Humanoid.Animator:LoadAnimation(VollstandigAnimations.IWorshipTheKingKing)
										IWorshipTheKingKingAnimation:Play()

										NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "3")

										local StunData = {
											NoHitEffect = true;
											TrueStunTime = 10;
											SoftStunTime = 0;
										}

										StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)										

										Profile.ClientData.ShikaiUnlocked = true
										Profile.ClientData.BankaiUnlocked = true

										local Info = {
											Shikai = Profile.ClientData.ShikaiUnlocked;
											Bankai = Profile.ClientData.BankaiUnlocked;
										}
										ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, Info)

										task.delay(5.65, function()
											Player.PlayerGui.ScreenEffects.IWorshipTheKing.Visible = true

											task.wait(3)

											Player.PlayerGui.ScreenEffects.IWorshipTheKing.Visible = false

											if PlayerData[Player.Name] then
												Character:SetAttribute("RegenDisabled", nil)
												Character:SetAttribute("InsideInnerWorld", nil)
												Character:SetAttribute("CurrentOST", nil)

												Character.HumanoidRootPart.Anchored = false

												InnerWorlds:Cleanup(Player)
												AntiCheatManager:Teleport(Player, SavedCFrame)
												AntiCheatManager:UnlockSavedPosition(Player)

												StateMachine:Trigger("TriggerBankaiObtained", StateMachine, Character)
											end

											Almighty:Destroy()
											AlmightySeat:Destroy()
										end)

										local WebhookInfo = {
											Message = Player.Name .. " obtained vollstandig";
											Title = Player.Name .. " " .. Player.UserId;
										}

										Webhooks:Post(BankaiPatrolChannel, WebhookInfo)
									end
								end)
								return
							end

							if Accumulated > AuswahlenData.TimeTillIncrease then
								Accumulated -= AuswahlenData.TimeTillIncrease

								CurrentRate -= Random.new():NextNumber(AuswahlenData.RateDecreaseMin, AuswahlenData.RateDecreaseMax)
								CurrentDelay -= Random.new():NextNumber(AuswahlenData.WindupDecreaseMin, AuswahlenData.WindupDecreaseMax)

								if CurrentRate < AuswahlenData.RateCap then
									CurrentRate = AuswahlenData.RateCap
								end
								if CurrentDelay < AuswahlenData.WindupCap then
									CurrentDelay = AuswahlenData.WindupCap
								end
							end

							if TickAccumulated > CurrentRate then
								TickAccumulated -= CurrentRate

								local SpawnPoint = CFrame.new(Character.HumanoidRootPart.CFrame.Position)

								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "2", SpawnPoint, CurrentDelay)

								task.delay(CurrentDelay, function()
									local Detection = HitDetection:GetPartBoundsInRadius(Dummy, SpawnPoint.Position, AuswahlenData.Properties.Range)
									if Detection then
										local PositiveHits = CombatManager:ApplyDamage(Dummy, Detection, AuswahlenData)

										local Restore
										for Entity, HitType in pairs(Detection) do
											if HitType == "Evaded" or HitType == "Deflected" then
												Restore = true
											end

											if not Entity:GetAttribute("GripBypass") and not Entity:GetAttribute("Carried") and not Entity:GetAttribute("HogyokuCapture") then
												if Entity:GetAttribute("CurrentState") == "Unconscious" then
													EntityManager:ChangeState(Entity, "TriggerDying")
													EntityManager:ChangeState(Entity, "TriggerDeath")
												end
											end
										end

										if Restore then
											CurrentRate += AuswahlenData.RateRestore
											if CurrentRate > AuswahlenData.Rate then
												CurrentRate = AuswahlenData.Rate
											end

											CurrentDelay += AuswahlenData.RateRestore
											if CurrentDelay > AuswahlenData.Windup then
												CurrentDelay = AuswahlenData.Windup
											end
										end
									end
								end)
							end
						end
					else
						InnerWorlds:Cleanup(Player)
					end
				end)
			end
		end,
		QuincyMedallion = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local Medallion = DataManager:CheckItemQuantity(Player, "Quincy Medallion")
			if Medallion then
				local BankaiTarget
				local ResTarget
				
				if not PlayerData[Character.Name].QuincyDebounce then
					local ClosestPlayerFromMouse = SharedFunctions:GetTargetByMouse(Player, 100, 30)
					if ClosestPlayerFromMouse and not ClosestPlayerFromMouse:GetAttribute("MedallionBypass") and not ClosestPlayerFromMouse:GetAttribute("Zombification") then -- ClosestPlayerFromMouse.Humanoid.Health <= (ClosestPlayerFromMouse.Humanoid.MaxHealth * 0.5)
						local PlayerTarget = Players:GetPlayerFromCharacter(ClosestPlayerFromMouse)
						if PlayerTarget then
							local TargetProfile = DataManager:RequestProfile(PlayerTarget)
							if not TargetProfile.ClientData.HollowCandy then
								if TargetProfile.ClientData.Race == "Shinigami" and ClosestPlayerFromMouse:GetAttribute("ZanpakutoState") >= 2 then
									local Captain = table.find(PositionTitles.ShinigamiCaptainTitles, TargetProfile.ClientData.Title)
									local Sternritter = table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title)

									if Captain then
										if table.find(PositionTitles.LeaderPositions, TargetProfile.ClientData.Title) then
											if table.find(PositionTitles.LeaderPositions, Profile.ClientData.Title) then
												BankaiTarget = ClosestPlayerFromMouse
											end
										else
											if Sternritter then
												BankaiTarget = ClosestPlayerFromMouse
											end
										end
									else
										BankaiTarget = ClosestPlayerFromMouse
									end
								elseif TargetProfile.ClientData.Race == "Arrancar" and ClosestPlayerFromMouse:GetAttribute("ZanpakutoState") >= 2 then
									local Espada = table.find(PositionTitles.ArrancarEspadaTitles, TargetProfile.ClientData.Title)
									local Sternritter = table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title)

									if Espada then
										if table.find(PositionTitles.LeaderPositions, TargetProfile.ClientData.Title) then
											if table.find(PositionTitles.LeaderPositions, Profile.ClientData.Title) then
												ResTarget = ClosestPlayerFromMouse
											end
										else
											if Sternritter then
												ResTarget = ClosestPlayerFromMouse
											end
										end
									else
										ResTarget = ClosestPlayerFromMouse
									end
								end
							else
								print(ClosestPlayerFromMouse.Name .. " immune by Hollow Candy")
							end
						end
					end

					local CancelBankai = function(Character, StateMachine, PlayerData)
						if Character:GetAttribute("ZanpakutoState") >= 2 then
							local Player = Players:GetPlayerFromCharacter(Character)
							local Profile = DataManager:RequestProfile(Player)
							local ClientData = Profile.ClientData
							if StatData.Factions[ClientData.Race] == "Arrancar" then
								Character:SetAttribute("ZanpakutoState", 0)
							elseif StatData.Factions[ClientData.Race] == "Shinigami" then
								Character:SetAttribute("ZanpakutoState", 1)
							elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
								Character:SetAttribute("ZanpakutoState", 0)
							end
						end
					end
					
					local function StealVfx(Entity)
						task.spawn(function()
							local Amount = 30
							local Rate = 0.1

							local function Color(Object)
								local TrailColor = Color3.fromRGB(16, 18, 50)
								if math.random(1, 2) == 2 then
									TrailColor = Color3.fromRGB(255, 66, 157)
								end

								for i, v in ipairs(Object:GetDescendants()) do
									if v:IsA("Trail") or v:IsA("ParticleEmitter") and v.Name ~= "5" then
										v.Color = ColorSequence.new({
											ColorSequenceKeypoint.new(0, TrailColor);
											ColorSequenceKeypoint.new(1, TrailColor);
										})
									end
								end
							end
							
							local QuincyMedallionObject = ServerStorage.Assets.Quincy["Quincy Medallion"]:Clone()
							QuincyMedallionObject.Parent = Character
							Debris:AddItem(QuincyMedallionObject, 3.1)
							
							local Motor6D = Instance.new("Motor6D")
							Motor6D.Name = "QuincyMedallionHandle"
							Motor6D.C0 = CFrame.new(0.0657958984, -1.08089256, 0.00622081757, 0, 1, 0, 0, 0, 1, 1, 0, 0)
							Motor6D.Part0 = Character["Right Arm"]
							Motor6D.Part1 = QuincyMedallionObject
							Motor6D.Parent = Character["Right Arm"]
							Debris:AddItem(Motor6D, 3.1)
							
							for i = 1, Amount do
								if not Entity:FindFirstChild("HumanoidRootPart") then
									break
								end

								local StolenBankaiFX = ServerStorage.Assets.Quincy.StolenBankai:Clone()
								StolenBankaiFX.CFrame = Entity.HumanoidRootPart.CFrame
								Color(StolenBankaiFX)
								StolenBankaiFX.Parent = workspace.Effects[Character.Name]
								StolenBankaiFX.Velocity = Vector3.new(math.random(-50, 50), math.random(40, 80), math.random(-50, 50))

								task.delay(0.5, function()
									local RocketPropulsion = Instance.new("RocketPropulsion")
									RocketPropulsion.ThrustD = 50
									RocketPropulsion.TurnP = 0
									RocketPropulsion.TargetRadius = 0.5
									RocketPropulsion.CartoonFactor = 0.7
									RocketPropulsion.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
									RocketPropulsion.MaxSpeed = 110

									RocketPropulsion.Target = QuincyMedallionObject
									RocketPropulsion.Parent = StolenBankaiFX
									RocketPropulsion:Fire()

									local ReachedConnection
									ReachedConnection = RocketPropulsion.ReachedTarget:Connect(function()
										ReachedConnection:Disconnect()
										ReachedConnection = nil

										Debris:AddItem(StolenBankaiFX, 1.5)
										for i, v in ipairs(StolenBankaiFX:GetDescendants()) do
											if v:IsA("ParticleEmitter") or v:IsA("Trail") then
												v.Enabled = false
											end
										end

										local QuincyMedallionAbsorbAudio = ReplicatedStorage.Assets.VollstandigSounds.QuincyMedallionAbsorb:Clone()
										QuincyMedallionAbsorbAudio.PlayOnRemove = true
										QuincyMedallionAbsorbAudio.Parent = Character.HumanoidRootPart
										QuincyMedallionAbsorbAudio:Destroy()
										QuincyMedallionAbsorbAudio = nil
									end)
								end)

								task.wait(Rate)
							end
						end)
					end					
					
					ResTarget = nil
					
					if BankaiTarget then
						local PlayerTarget = Players:GetPlayerFromCharacter(BankaiTarget)

						PlayerData[Character.Name].QuincyDebounce = true
						task.delay(60, function()
							PlayerData[Character.Name].QuincyDebounce = nil
						end)					

						local MedallionSuccess = QuincyMedallions:UpdateQuincy(Player, PlayerTarget)
						if MedallionSuccess then
							local TargetProfile = DataManager:RequestProfile(PlayerTarget)
							--print(Player.Name .. " stole " .. PlayerTarget.Name .. "'s bankai")
							TargetProfile.ClientData.QuincyMedallion = Player.UserId
							Profile.ClientData.StolenBankai = {
								Shikai = TargetProfile.ClientData.Shikai;
								WeaponType = TargetProfile.ClientData.WeaponType;
								BankaiWeaponModel = TargetProfile.ClientData.BankaiWeaponModel;
							} 
							Profile.ClientData.MedallionTimer = DateTime.now().UnixTimestamp
							TargetProfile.ClientData.MedallionTimer = DateTime.now().UnixTimestamp
							
							DataManager:RemoveItem(Player, "Quincy Medallion", 1)							
							
							local ShikaiInfo = {
								Shikai = true;
								Bankai = true;
							}

							local StolenBankai = Profile.ClientData.StolenBankai
							if StolenBankai then
								ShikaiInfo.SkillNames = require(ServerStorage.Modules.SkillModules.Shikais[StolenBankai.Shikai .. "Shikai"]).Keybinds
							end

							ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, ShikaiInfo)
							Profile.ClientData.BankaiMeter = Profile.ClientData.MaxBankaiMeter
							Character:SetAttribute("BankaiMeter", Character:GetAttribute("MaxBankaiMeter"))

							EntityManager:ChangeState(BankaiTarget, "RunFunction", CancelBankai)
							
							local StunData = {
								NoHitEffect = true;
								TrueStunTime = 5;
								SoftStunTime = 0;
							}

							StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)
							EntityManager:ChangeState(BankaiTarget, "TriggerTrueStun", StunData, Character)
							
							Character.Humanoid.AutoRotate = false
							BankaiTarget.Humanoid.AutoRotate = false
							
							local QuincyMedallionStealAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.QuincyMedallionSteal)
							QuincyMedallionStealAnimation:Play()
							
							-- Stolen = 2.333
							task.delay(2.317, function()
								local QuincyMedallionStolenAnimation = BankaiTarget.Humanoid.Animator:LoadAnimation(Animations.QuincyMedallionStolen)
								QuincyMedallionStolenAnimation:Play()
							end)
							
							local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
							local PathData = {Module = ClientProgression, Skill = "QuincyMedallionCinematic"}
							local RenderDistance = -1
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, BankaiTarget)
							
							StealVfx(BankaiTarget)
							
							local WebhookInfo = {
								Message = Player.Name .. " has used a Quincy Medallion on " .. BankaiTarget.Name .. "'s bankai";
							}

							Webhooks:Post(WebhookChannel, WebhookInfo)
						end
					elseif ResTarget then
						local PlayerTarget = Players:GetPlayerFromCharacter(BankaiTarget)

						PlayerData[Character.Name].QuincyDebounce = true
						task.delay(60, function()
							PlayerData[Character.Name].QuincyDebounce = nil
						end)
						
						local MedallionSuccess = QuincyMedallions:UpdateQuincy(Player, PlayerTarget)
						if MedallionSuccess then
							local TargetProfile = DataManager:RequestProfile(PlayerTarget)
							--print(Player.Name .. " stole " .. PlayerTarget.Name .. "'s bankai")
							TargetProfile.ClientData.QuincyMedallion = Player.UserId
							
							DataManager:RemoveItem(Player, "Quincy Medallion", 1)	
							
							ResTarget:SetAttribute("PartialRes", nil)
							ResTarget:SetAttribute("PartialRes2", nil)
							
							local StunData = {
								NoHitEffect = true;
								TrueStunTime = 5;
								SoftStunTime = 0;
							}

							StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)
							EntityManager:ChangeState(ResTarget, "TriggerTrueStun", StunData, Character)

							local QuincyMedallionStealAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.QuincyMedallionSteal)
							QuincyMedallionStealAnimation:Play()

							-- Stolen = 2.333
							task.delay(2.317, function()
								local QuincyMedallionStolenAnimation = ResTarget.Humanoid.Animator:LoadAnimation(Animations.QuincyMedallionStolen)
								QuincyMedallionStolenAnimation:Play()
							end)

							local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
							local PathData = {Module = ClientProgression, Skill = "QuincyMedallionCinematic"}
							local RenderDistance = -1
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, ResTarget)
							
							StealVfx(ResTarget)
							
							local WebhookInfo = {
								Message = Player.Name .. " has used a Quincy Medallion to seal " .. ResTarget.Name .. "'s res";
							}

							Webhooks:Post(WebhookChannel, WebhookInfo)
						end
					else
						print("no bankai/res target found")
					end
				else
					print(Player.name .. " Quincy Medallion CD")
				end
			end
			
			StateMachine:Trigger("ReleaseAction", StateMachine, Character)
		end,
		ReleaseAction = function(StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
		end,
	},
	TrueStunned = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerSkill = function(StateMachine, Character, KeyPressed)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]

			if InventorySkill ~= "Empty" then
				local Skill = SkillModule[InventorySkill]
				if Skill then
					local ReiatsuValue = Character:GetAttribute("Reiatsu")
					local ReiatsuCost = Skill.ReiatsuCost
					if Character:GetAttribute("PaintItBlack") then
						ReiatsuCost *= Character:GetAttribute("PaintItBlack")
					end
					ReiatsuValue -= ReiatsuCost

					if Character:GetAttribute(KeyPressed) == false and Skill.Evasive and ReiatsuValue >= 0 then
						PlayerData[Character.Name].StunnedDuration = 0
						
						Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
						Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
						Character.Humanoid.AutoRotate = true
						Ragdoll:Disable(Character, "UnconsciousCheck")
						
						StateMachine:SetState("Skill")
						StateMachine:Trigger("SkillPress", StateMachine, Character, KeyPressed)
					end
				end
			end
		end,
		TriggerShikaiSkill = function(StateMachine, Character, KeyPressed)
			local ShikaiModule = PlayerData[Character.Name].ShikaiModule
			local ShikaiSkill = ShikaiModule.Keybinds[KeyPressed]
			if ShikaiSkill and ShikaiModule[ShikaiSkill] and Character:GetAttribute(KeyPressed) == false and ShikaiSkill.Evasive then
				local ReiatsuValue = Character:GetAttribute("Reiatsu")
				local ReiatsuCost = ShikaiModule[ShikaiSkill].ReiatsuCost
				if Character:GetAttribute("PaintItBlack") then
					ReiatsuCost *= Character:GetAttribute("PaintItBlack")
				end
				ReiatsuValue -= ReiatsuCost

				if ReiatsuValue >= 0 then 
					PlayerData[Character.Name].StunnedDuration = 0

					Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
					Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
					Character.Humanoid.AutoRotate = true
					Ragdoll:Disable(Character, "UnconsciousCheck")

					StateMachine:SetState("ShikaiSkill")
					StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, KeyPressed)
				end
			end
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TrueStun = function(StateMachine, Character, AttackData, AttackOwner, NoComboReset)
			if not PlayerData[Character.Name].StunnedDuration then
				PlayerData[Character.Name].StunnedTime = DateTime.now().UnixTimestampMillis
				PlayerData[Character.Name].StunnedDuration = AttackData.TrueStunTime
			elseif AttackData.TrueStunTime >= PlayerData[Character.Name].StunnedDuration then
				PlayerData[Character.Name].StunnedTime = DateTime.now().UnixTimestampMillis
				PlayerData[Character.Name].StunnedDuration = AttackData.TrueStunTime
			end
			
			StateMachine:Trigger("CancelGrip", StateMachine, Character)
			
			if not NoComboReset then
				Character:SetAttribute("Combo", 1)
			end
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.WalkSpeed = 0
			
			if Character:GetAttribute("HyperArmor") == false and Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
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
			
			if PlayerData[Character.Name].Carrying then
				local CarriedPlayer = Players:GetPlayerFromCharacter(PlayerData[Character.Name].Carrying)
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				EntityManager:ChangeState(PlayerData[Character.Name].Carrying, "ReleaseCarried")

				for Index, Part in ipairs(PlayerData[Character.Name].Carrying:GetChildren()) do
					if Part:IsA'BasePart' then
						if PlayerData[Character.Name].CarriedPlayerMass and PlayerData[Character.Name].CarriedPlayerMass[Part] then
							Part.Massless = PlayerData[Character.Name].CarriedPlayerMass[Part]
							PlayerData[Character.Name].CarriedPlayerMass[Part] = nil
						else
							Part.Massless = false
						end
						Part.CollisionGroup = "Entity"

						if CarriedPlayer then
							if Part:CanSetNetworkOwnership() then
								Part:SetNetworkOwner(CarriedPlayer)
							end
						end
					end
				end
				PlayerData[Character.Name].CarriedPlayerMass = nil
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end

				SharedFunctions:CancelAnimation(PlayerData[Character.Name].Carrying.Humanoid, "Carried")
				PlayerData[Character.Name].Carrying:SetAttribute("Carried", nil)
				PlayerData[Character.Name].Carrying:SetAttribute("IFrames", false)				
				
				Ragdoll:Enable(PlayerData[Character.Name].Carrying)
				PlayerData[Character.Name].Carrying = nil
				Character:SetAttribute("Carrying", nil)
				
				local CarryWeld = Character:FindFirstChild("CarryWeld")
				if CarryWeld then
					CarryWeld:Destroy()
					CarryWeld = nil
				end

				SharedFunctions:CancelAnimation(Character.Humanoid, "Carrying")
				
				if PlayerData[Character.Name].CarriedLeaving then
					PlayerData[Character.Name].CarriedLeaving:Disconnect()
					PlayerData[Character.Name].CarriedLeaving = nil
				end
				
				if PlayerData[Character.Name].CarryConnection then
					PlayerData[Character.Name].CarryConnection:Disconnect()
					PlayerData[Character.Name].CarryConnection = nil
				end
				
				if PlayerData[Character.Name].CarryOwnerLeave then
					PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
					PlayerData[Character.Name].CarryOwnerLeave = nil
				end
				

				StateMachine:CleanStack()
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:PushState("WeaponDrawn")
				else
					StateMachine:PushState("Idle")
				end
			end
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			if PlayerData[Character.Name].AttackerRemoving then
				PlayerData[Character.Name].AttackerRemoving:Disconnect()
				PlayerData[Character.Name].AttackerRemoving = nil
			end
			
			local Player = Players:GetPlayerFromCharacter(AttackOwner)
			if Player then
				--[[PlayerData[Character.Name].AttackerRemoving = Player.CharacterRemoving:Connect(function()
					if PlayerData[Character.Name] then
						if PlayerData[Character.Name].AttackerRemoving then
							PlayerData[Character.Name].AttackerRemoving:Disconnect()
							PlayerData[Character.Name].AttackerRemoving = nil
						end
						if PlayerData[Character.Name].StunnedDuration then
							PlayerData[Character.Name].StunnedDuration = 0
						end
					end
					
					Ragdoll:Disable(Character, "UnconsciousCheck")
					Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
					Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
					Character.Humanoid.AutoRotate = true
					StateMachine:PopState()
				end)]]
			end
			
			task.delay(AttackData.TrueStunTime, function()
				--print(Character.Name .. " StunTimer:", DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].StunnedTime, "StunDuration:", PlayerData[Character.Name].StunnedDuration * 995)
				if PlayerData[Character.Name] and DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].StunnedTime >= PlayerData[Character.Name].StunnedDuration * 995 then -- Multiplying the truestuntime by 1000 gives us the time in milliseconds
					PlayerData[Character.Name].StunnedDuration = 0
					StateMachine:Trigger("TriggerSoftStun", StateMachine, Character, AttackData.SoftStunTime)
				end

				if PlayerData[Character.Name].AttackerRemoving then
					PlayerData[Character.Name].AttackerRemoving:Disconnect()
					PlayerData[Character.Name].AttackerRemoving = nil
				end
			end)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerSoftStun = function(StateMachine, Character, SoftStunTime)
			PlayerData[Character.Name].StunnedDuration = 0
			Character.Humanoid.WalkSpeed = 4
			StateMachine:SetState("SoftStunned")	
			StateMachine:Trigger("SoftStun", StateMachine, Character, SoftStunTime)
		end,
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			if not PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
				
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData


				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Draw" .. ClientData.Sheathe])
					DrawAnimation:Play()

					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1
	
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = false
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 0
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = true
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.UnsheatheFunction then
							ZanpakutoData.UnsheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				end
				
				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end
				
				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end
			end
		end,
		SheatheWeapon = function(StateMachine, Character, ClientData)
			if Character:GetAttribute("ZanpakutoState") <= 1 then
				if Character:GetAttribute("ZanpakutoState") == 0 then
					StateMachine:PushState("Idle")
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)
					
					if not SheatheSoundBlacklist[PlayerData[Character.Name].WeaponEquipped] then
						local SheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].SheatheSound or Sounds.Sheathe
						local ClonedSheathe = SheatheSound:Clone()
						ClonedSheathe.PlayOnRemove = true
						ClonedSheathe.Parent = Character.PrimaryPart
						ClonedSheathe:Destroy()
						ClonedSheathe = nil
					end
					
					PlayerData[Character.Name].WeaponEquipped = nil
					
					local WeaponModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					WeaponModel.PrimaryPart.Weld.Enabled = true
					WeaponModel.Parent = Character
					Motor6D.Part1 = nil
					
					local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = nil

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = true
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 1
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = false
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", true)

								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.SheatheFunction then
							ZanpakutoData.SheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				elseif Character:GetAttribute("ZanpakutoState") == 1 then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					
					StateMachine:PushState("Idle")
					
					Character:SetAttribute("ZanpakutoState", 0)
					if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
						local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
						ShikaiModel:Destroy()
						ShikaiModel = nil

						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
						local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")

						WeaponModel.PrimaryPart.Weld.Enabled = false
						WeaponModel.Parent = Character["Right Arm"]

						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
						Motor6D.Part1 = WeaponModel.PrimaryPart
						Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData
						
						local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
						local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

						if ZanpakutoData and ZanpakutoData.DoubleHandle then
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
						end
					else
						local ZanpakutoModel = Character["Right Arm"].Zanpakuto
						ZanpakutoModel.Handle[ClientData.WeaponModel]:Destroy()
						ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
						ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
						ZanpakutoModel.PrimaryPart.Trail:Destroy()
						ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
					end
					
					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon

					local WeaponName = PlayerData[Character.Name].WeaponEquipped
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

					local Idle = "Idle"..math.random(1, 3)
					if WeaponName == "Fist" then
						Idle = "Idle1"
					end

					if not IdleBlacklist[ZanpakutoWeapon] then
						local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
						IdleAnimation:Play()
					end
					
					if PlayerData[Character.Name].ShikaiActiveData then
						if PlayerData[Character.Name].ShikaiActiveData.Connections then
							for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
								if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
								end

								PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
								PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
							end
						end
						PlayerData[Character.Name].ShikaiActiveData = nil
					end
				end
			end
		end,
		TriggerAttackDeflected = function(StateMachine, Character, ...)
			--StateMachine:SetState("AttackDeflected")
			--StateMachine:Trigger("Deflected", StateMachine, ...)
		end,
		CancelGrip = function(StateMachine, Character)
			if PlayerData[Character.Name].VictimDestroyed then
				PlayerData[Character.Name].VictimDestroyed:Disconnect()
				PlayerData[Character.Name].VictimDestroyed = nil
			end

			if PlayerData[Character.Name].ExecutorDestroyed then
				PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
				PlayerData[Character.Name].ExecutorDestroyed = nil
			end

			if PlayerData[Character.Name].VictimDied then
				PlayerData[Character.Name].VictimDied:Disconnect()
				PlayerData[Character.Name].VictimDied = nil
			end

			if PlayerData[Character.Name].Victim then
				PlayerData[Character.Name].Victim.HumanoidRootPart.Anchored = false
				EntityManager:ChangeState(PlayerData[Character.Name].Victim, "ReleaseDying", Character)
				PlayerData[Character.Name].Victim = nil
			end

			SharedFunctions:CancelAnimation(Character.Humanoid, "Grip")

			local GripWeld = Character:FindFirstChild("GripWeld")
			if GripWeld then
				GripWeld:Destroy()
				GripWeld = nil
			end
			local GripWeld2 = Character:FindFirstChild("GripOrientation")
			if GripWeld2 then
				GripWeld2:Destroy()
				GripWeld2 = nil
			end
		end,
		TriggerBankaiObtained = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			Profile.ClientData.BankaiMeter = Character:GetAttribute("MaxBankaiMeter")
			Character:SetAttribute("BankaiMeter", Character:GetAttribute("MaxBankaiMeter"))
			Character:SetAttribute("BankaiFight", nil)
			
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData

				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1

					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

					if ZanpakutoData and ZanpakutoData.DoubleHandle then
						local DualMotor6D = Character["Left Arm"].DualHandle2
						DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
						DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

						WeaponModel.DualShikai2.PrimaryPart.Weld.Enabled = false
					end
					if ZanpakutoData and ZanpakutoData.InvisibleDraw then
						for i, v in ipairs(WeaponModel:GetDescendants()) do
							if v:GetAttribute("InvisibleDraw") then
								v.Transparency = 0
							end
						end
						
						if ZanpakutoData.QuincyDraw then
							WeaponModel.PrimaryPart.PointLight.Enabled = true
							WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
							
							local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
							local RenderDistance = 1000
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
						end
					end
				end

				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end

				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end

				StateMachine:PushState("WeaponDrawn")
			end
			
			if StatData.Factions[Profile.ClientData.Race] == "Shinigami" and Character:GetAttribute("ZanpakutoState") < 1 then
				local ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[Profile.ClientData.Shikai .. "Shikai"])
				ShikaiModule:ReleaseShikai(Character, StateMachine, Profile.ClientData, PlayerData[Character.Name])
				ShikaiWeapons:InstantWeaponRelease(Character, StateMachine, Profile.ClientData, PlayerData[Character.Name])
			end
			
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiRelease", StateMachine, Character, Profile.ClientData)
		end,
	},
	SoftStunned = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerSkill = function(StateMachine, Character, KeyPressed)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local InventorySkill = DataManager:RequestSkillInventory(Player)[KeyPressed]

			if InventorySkill ~= "Empty" then
				local Skill = SkillModule[InventorySkill]
				if Skill then
					local ReiatsuValue = Character:GetAttribute("Reiatsu")
					local ReiatsuCost = Skill.ReiatsuCost
					if Character:GetAttribute("PaintItBlack") then
						ReiatsuCost *= Character:GetAttribute("PaintItBlack")
					end
					ReiatsuValue -= ReiatsuCost

					if Character:GetAttribute(KeyPressed) == false and Skill.Evasive and ReiatsuValue >= 0 then
						Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
						Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
						Character.Humanoid.AutoRotate = true
						Ragdoll:Disable(Character, "UnconsciousCheck")

						StateMachine:SetState("Skill")
						StateMachine:Trigger("SkillPress", StateMachine, Character, KeyPressed)
					end
				end
			end
		end,
		TriggerShikaiSkill = function(StateMachine, Character, KeyPressed)
			local ShikaiModule = PlayerData[Character.Name].ShikaiModule
			local ShikaiSkill = ShikaiModule.Keybinds[KeyPressed]
			if ShikaiSkill and ShikaiModule[ShikaiSkill] and Character:GetAttribute(KeyPressed) == false and ShikaiSkill.Evasive then
				local ReiatsuValue = Character:GetAttribute("Reiatsu")
				local ReiatsuCost = ShikaiModule[ShikaiSkill].ReiatsuCost
				if Character:GetAttribute("PaintItBlack") then
					ReiatsuCost *= Character:GetAttribute("PaintItBlack")
				end
				ReiatsuValue -= ReiatsuCost

				if ReiatsuValue >= 0 then 
					Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
					Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
					Character.Humanoid.AutoRotate = true
					Ragdoll:Disable(Character, "UnconsciousCheck")

					StateMachine:SetState("ShikaiSkill")
					StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, KeyPressed)
				end
			end
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
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
			Character.Humanoid.AutoRotate = true
			
			if Character:GetAttribute("Regenerate") then
				Character.Humanoid.Health = Character.Humanoid.MaxHealth
			end
			
			if Character:GetAttribute("Zombification") then
				StateMachine:Trigger("TriggerChoice", StateMachine, Character)
			else
				StateMachine:PopState()
			end
		end,
		TriggerChoice = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local Flashstep = table.find(Profile.UnlockedSkills, "Flashstep")
			
			local function Attack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character)
			end

			local function CAttack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character)
			end

			local function DefenseChoice()
				local RNG = Random.new():NextInteger(1, 10)
				if RNG < 5 and Flashstep then
					StateMachine:SetState("WeaponDrawn")
					StateMachine:Trigger("TriggerFlashstep", StateMachine, Character)
				else
					StateMachine:SetState("WeaponDrawn")
					StateMachine:Trigger("TriggerParry", StateMachine, Character)
				--[[elseif RNG >= 4 and RNG < 6 then
					StateMachine:SetState("Blocking")
					StateMachine:Trigger("TrueBlock", StateMachine, Character)]]
				end
			end

			local function ShikaiSkill()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character)
				if not Character:GetAttribute("ShikaiDisabled") then
					StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerSkill", StateMachine, Character)
				end
			end

			local function Skill()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerSkill", StateMachine, Character)
			end

			local RNG = Random.new():NextInteger(1, 10)
			if RNG <= 6 then
				DefenseChoice()
			elseif RNG == 7 then
				Attack()
			elseif RNG == 8 then
				ShikaiSkill()
			elseif RNG == 9 then
				Skill()
			elseif RNG == 10 then
				CAttack()
			end
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerBlock = function(StateMachine, Character)
			StateMachine:SetState("Blocking")
			StateMachine:Trigger("SoftBlock", StateMachine, Character)
		end,
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData


				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Draw" .. ClientData.Sheathe])
					DrawAnimation:Play()

					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1
					
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = false
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 0
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = true
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.UnsheatheFunction then
							ZanpakutoData.UnsheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				end
				
				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end
				
				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end
				
				StateMachine:PushState("WeaponDrawn")
			end
		end,
		SheatheWeapon = function(StateMachine, Character, ClientData)
			if Character:GetAttribute("ZanpakutoState") <= 1 then
				if Character:GetAttribute("ZanpakutoState") == 0 then
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)
					StateMachine:PushState("Idle")
					
					if not SheatheSoundBlacklist[PlayerData[Character.Name].WeaponEquipped] then
						local SheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].SheatheSound or Sounds.Sheathe
						local ClonedSheathe = SheatheSound:Clone()
						ClonedSheathe.PlayOnRemove = true
						ClonedSheathe.Parent = Character.PrimaryPart
						ClonedSheathe:Destroy()
						ClonedSheathe = nil
					end
					
					PlayerData[Character.Name].WeaponEquipped = nil
					
					local WeaponModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					WeaponModel.PrimaryPart.Weld.Enabled = true
					WeaponModel.Parent = Character
					Motor6D.Part1 = nil
					
					local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = nil

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = true
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 1
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = false
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", true)

								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.SheatheFunction then
							ZanpakutoData.SheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				elseif Character:GetAttribute("ZanpakutoState") == 1 then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					
					Character:SetAttribute("ZanpakutoState", 0)
					
					if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
						local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
						ShikaiModel:Destroy()
						ShikaiModel = nil

						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
						local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")

						WeaponModel.PrimaryPart.Weld.Enabled = false
						WeaponModel.Parent = Character["Right Arm"]

						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
						Motor6D.Part1 = WeaponModel.PrimaryPart
						Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData
						
						local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
						local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

						if ZanpakutoData and ZanpakutoData.DoubleHandle then
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
						end
					else
						local ZanpakutoModel = Character["Right Arm"].Zanpakuto
						ZanpakutoModel.Handle[ClientData.WeaponModel]:Destroy()
						ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
						ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
						ZanpakutoModel.PrimaryPart.Trail:Destroy()
						ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
					end
					
					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon

					local WeaponName = PlayerData[Character.Name].WeaponEquipped
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

					local Idle = "Idle"..math.random(1, 3)
					if WeaponName == "Fist" then
						Idle = "Idle1"
					end

					if not IdleBlacklist[ZanpakutoWeapon] then
						local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
						IdleAnimation:Play()
					end
					
					if PlayerData[Character.Name].ShikaiActiveData then
						if PlayerData[Character.Name].ShikaiActiveData.Connections then
							for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
								if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
								end

								PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
								PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
							end
						end
						PlayerData[Character.Name].ShikaiActiveData = nil
					end
				end
			end
		end,
	},
	PostureBroken = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		PostureBreak = function(StateMachine, Character)
			PlayerData[Character.Name].PostureBreakDuration = DateTime.now().UnixTimestampMillis
			local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "PostureBreak")
			
			local HitReaction = Character.Humanoid.Animator:LoadAnimation(Animations.PostureBroken)
			HitReaction:Play()
			
			if PlayerData[Character.Name].Carrying then
				local CarriedPlayer = Players:GetPlayerFromCharacter(PlayerData[Character.Name].Carrying)
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				EntityManager:ChangeState(PlayerData[Character.Name].Carrying, "ReleaseCarried")
				
				for Index, Part in ipairs(PlayerData[Character.Name].Carrying:GetChildren()) do
					if Part:IsA'BasePart' then
						if PlayerData[Character.Name].CarriedPlayerMass and PlayerData[Character.Name].CarriedPlayerMass[Part] then
							Part.Massless = PlayerData[Character.Name].CarriedPlayerMass[Part]
							PlayerData[Character.Name].CarriedPlayerMass[Part] = nil
						else
							Part.Massless = false
						end
						Part.CollisionGroup = "Entity"

						if CarriedPlayer and Part:CanSetNetworkOwnership() then
							Part:SetNetworkOwner(CarriedPlayer)
						end
					end
				end
				PlayerData[Character.Name].CarriedPlayerMass = nil
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end

				SharedFunctions:CancelAnimation(PlayerData[Character.Name].Carrying.Humanoid, "Carried")
				PlayerData[Character.Name].Carrying:SetAttribute("Carried", nil)
				PlayerData[Character.Name].Carrying:SetAttribute("IFrames", false)				
				
				Ragdoll:Enable(PlayerData[Character.Name].Carrying)
				PlayerData[Character.Name].Carrying = nil
				Character:SetAttribute("Carrying", nil)
				
				local CarryWeld = Character:FindFirstChild("CarryWeld")
				if CarryWeld then
					CarryWeld:Destroy()
					CarryWeld = nil
				end

				SharedFunctions:CancelAnimation(Character.Humanoid, "Carrying")

				if PlayerData[Character.Name].CarriedLeaving then
					PlayerData[Character.Name].CarriedLeaving:Disconnect()
					PlayerData[Character.Name].CarriedLeaving = nil
				end

				if PlayerData[Character.Name].CarryConnection then
					PlayerData[Character.Name].CarryConnection:Disconnect()
					PlayerData[Character.Name].CarryConnection = nil
				end
				
				if PlayerData[Character.Name].CarryOwnerLeave then
					PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
					PlayerData[Character.Name].CarryOwnerLeave = nil
				end

				StateMachine:CleanStack()
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:PushState("WeaponDrawn")
				else
					StateMachine:PushState("Idle")
				end
			end
			
			Character:SetAttribute("Posture", 0)
			Character:SetAttribute("Combo", 1)
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.WalkSpeed = 0
			
			task.delay(StatData.PostureBreakTime, function()
				if DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].PostureBreakDuration >= StatData.PostureBreakTime * 995 then
					StateMachine:Trigger("ReleasePostureBreak", StateMachine, Character)
				end
			end)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			SharedFunctions:CancelAnimation(Character.Humanoid, "PostureBroken")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleasePostureBreak = function(StateMachine, Character)
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.AutoRotate = true
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "PostureBroken")
			
			StateMachine:PopState()
		end,
	},
	Sprinting = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerCarry = function(StateMachine, Character, CarriedLeft)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			
			if PlayerData[Character.Name].Carrying or CarriedLeft then
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:PushState("WeaponDrawn")
				else
					StateMachine:PushState("Idle")
				end
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("ReleaseCarrying", StateMachine, Character)
			else
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("Carry", StateMachine, Character)
			end
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		Sprint = function(StateMachine, Character)
			local SprintSpeed = 10
			
			if Character:GetAttribute("SprintReduced") then
				SprintSpeed *= Character:GetAttribute("SprintReduced")
			end
			
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") + SprintSpeed
			PlayerData[Character.Name].SprintHeld = true
			
			local Profile = DataManager:RequestProfile(Players:GetPlayerFromCharacter(Character))
			local WeaponModel = Profile.ClientData.WeaponModel
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped

			if WeaponEquipped then
				local BankaiFaction = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Quincy"
				local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
				local CombatAnimations = CombatAnimations[PlayerData[Character.Name].WeaponEquipped]
				if ZanpakutoState >= 2 and BankaiFaction and CombatAnimations:FindFirstChild("Bankai") then
					CombatAnimations = CombatAnimations.Bankai
				end
				
				local SprintAnim = CombatAnimations.Sprint
				if PlayerData[Character.Name].ResActive then
					if PlayerData[Character.Name].ResActive.Sprint then
						SprintAnim = PlayerData[Character.Name].ResActive.Sprint
					end
					if PlayerData[Character.Name].ResActive.AccessoryAnimations then
						local ResAnimator = PlayerData[Character.Name].ResActive.ResAnimator
						local ResSprint = PlayerData[Character.Name].ResActive.AccessoryAnimations.Sprint
						if ResSprint then
							ResAnimator:LoadAnimation(ResSprint):Play()
						end
					end
				end
				if WeaponModel == "Fan4" and PlayerData[Character.Name].WeaponEquipped == "Dagger" and ZanpakutoState == 1 then
					SprintAnim = CombatAnimations.SprintFan
				end
				Character.Humanoid.Animator:LoadAnimation(SprintAnim):Play()
			else
				Character.Humanoid.Animator:LoadAnimation(Animations["Sprint"]):Play()
			end
			
			InventoryManager:PlaySprintAnimations(Character)
			
			BankaiWeapons:PlayWeaponAnimation(Character, "Sprint", Profile.ClientData, PlayerData[Character.Name])
		end,
		StopSprint = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			StateMachine:PopState()
		end,
		CancelSprintAnimations = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Sprint", "SearchByReference")
			
			if PlayerData[Character.Name].ResActive then
				if PlayerData[Character.Name].ResActive.AccessoryAnimations then
					local ResAnimator = PlayerData[Character.Name].ResActive.ResAnimator
					SharedFunctions:CancelAnimation(ResAnimator, "Sprint", "SearchByReference")
				end
			end
			InventoryManager:CancelSprintAnimations(Character)
			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			BankaiWeapons:CancelWeaponAnimation(Character, "Sprint", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		TriggerDash = function(StateMachine, Character, KeyPressed)
			local Cooldown = 1750
			if Character:GetAttribute("EnhancedSteps") then
				Cooldown = SkillData["Enhanced Steps"].DashCooldown
			end
			if Character:GetAttribute("HeavenlyRestriction") then
				Cooldown = SkillData["Heavenly Restriction"].DashCooldown
			end
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("DashTimer")
			if TimeDifference >= Cooldown then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
				StateMachine:SetState("Dashing")
				StateMachine:Trigger("Dash", StateMachine, Character, KeyPressed)
			end
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:PushState("WeaponDrawn")
			else
				StateMachine:PushState("Idle")
			end
			
			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerLAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped and not PlayerData[Character.Name].Carrying then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
				StateMachine:SetState("Attacking")
				StateMachine:Trigger("LightAttack", StateMachine, Character)
			end
		end,
		TriggerServerHop = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("ServerHop", StateMachine, Character)
		end,
		TriggerBankaiQuest = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiQuest", StateMachine, Character)
		end,
		TriggerVollstandigQuest = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("VollstandigQuest", StateMachine, Character)
		end,
		TriggerCAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped and not Character:GetAttribute("CriticalCooldown") and not PlayerData[Character.Name].Carrying  then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
				StateMachine:SetState("CriticalAttacking")
				StateMachine:Trigger("CriticalAttack", StateMachine, Character)
			end
		end,
		TriggerBlock = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Blocking")
				StateMachine:Trigger("TrueBlock", StateMachine, Character)
			end
		end,
		TriggerParry = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("BlockTimer")
			if not PlayerData[Character.Name].Carrying then
				if PlayerData[Character.Name].WeaponEquipped and TimeDifference >= Character:GetAttribute("ParryCooldown") then
					StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
					StateMachine:SetState("Parrying")
					StateMachine:Trigger("Parry", StateMachine, Character)
				else
					StateMachine:Trigger("TriggerBlock", StateMachine, Character)
				end
			end
		end,
		TriggerSkill = function(StateMachine, Character, ...)
			if not PlayerData[Character.Name].Carrying and PlayerData[Character.Name].WeaponEquipped then			
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Skill")
				StateMachine:Trigger("SkillPress", StateMachine, Character, ...)
			end
		end,
		TriggerHierro = function(StateMachine, Character, ...)
			Hierro(Character, ...)
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			if not PlayerData[Character.Name].Carrying then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("ShikaiSkill")
				StateMachine:Trigger("ShikaiSkillPress", StateMachine, Character, ...)
			end
		end,
		TriggerShikaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ShikaiTimer")
			local ReleaseAllowed
			
			if TimeDifference >= 3000 then
				if AllowedShikaiRelease[PlayerData[Character.Name].WeaponEquipped] then
					ReleaseAllowed = true
				end
				if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery >= 1 then
					ReleaseAllowed = true
				end	
			end
			
			if ReleaseAllowed then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Action")
				StateMachine:Trigger("ShikaiRelease", StateMachine, Character, ...)
			end
		end,
		TriggerQuincyMedallion = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("QuincyMedallion", StateMachine, Character, ...)
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local ReleaseAllowed = true
			if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" then
				if Profile.ClientData.NozarashiMastery < 2 then
					ReleaseAllowed = nil
					local PathData = {Module = ClientProgression, Skill = "NozarashiBankaiHint"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData)
				end
			end	
			
			local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.BankaiTimer

			local BankaiCooldown = StatData.BankaiCooldown * 60
			if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				BankaiCooldown = StatData.ResCooldown * 60
			end

			if TimeDifference < BankaiCooldown then
				ReleaseAllowed = nil
				local PathData = {Module = ClientProgression, Skill = "BankaiTimer"}
				local Text = BankaiCooldown / 60 - math.floor(TimeDifference / 60)
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Text)
			end

			if ReleaseAllowed then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Action")
				StateMachine:Trigger("BankaiRelease", StateMachine, Character, ...)
			end
		end,
		TriggerBankaiCancel = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("CancelBankai", StateMachine, Character, ...)
		end,
		TriggerSecondBankaiRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("SecondBankaiRelease", StateMachine, Character, ...)
		end,
		TriggerVisoredRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("VisoredRelease", StateMachine, Character, ...)
		end,
		TriggerLetztStilRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			StateMachine:SetState("Action")
			StateMachine:Trigger("LetztStilRelease", StateMachine, Character, ...)
		end,
		TriggerPurify = function(StateMachine, Character, ...)
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Action")
				StateMachine:Trigger("Purify", StateMachine, Character)
			end
		end,
		TriggerFlashstep = function(StateMachine, Character)
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Character).FlashstepMastery
			
			local Cooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			local MaxHealth = Character.Humanoid.MaxHealth
			local Health = Character.Humanoid.Health

			if Health <= MaxHealth * 0.8 then
				local HealthRange = (MaxHealth * 0.8) - 1
				local FlashstepCDRange = FlashstepMasteryIndex[FlashstepMasteries].Cooldown - FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				Cooldown = ScaledFlashstepCD
			end
			
			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end

			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= Cooldown and ReiatsuValue >= 0 then
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				StateMachine:SetState("Flashstep")
				StateMachine:Trigger("Flashstep", StateMachine, Character)
			end
		end,
		UnsheatheWeapon = function(StateMachine, Character, ClientData)
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData


				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local DrawAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Draw" .. ClientData.Sheathe])
					DrawAnimation:Play()

					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end
				
				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1
					
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = false
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 0
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = true
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.UnsheatheFunction then
							ZanpakutoData.UnsheatheFunction(Character, PlayerData[Character.Name])
						end
					end
				end
				
				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end
				
				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end
				
				StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
				Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon].Sprint):Play()
				
				StateMachine:PushState("WeaponDrawn")
			end
		end,
		SheatheWeapon = function(StateMachine, Character, ClientData)
			if Character:GetAttribute("ZanpakutoState") <= 1 then
				if Character:GetAttribute("ZanpakutoState") == 0 then
					PlayerData[Character.Name].WeaponEquipped = nil
					
					local WeaponModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					WeaponModel.PrimaryPart.Weld.Enabled = true
					WeaponModel.Parent = Character
					Motor6D.Part1 = nil
					
					local ZanpakutoWeapon = ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)
					if ZanpakutoData then
						if ZanpakutoData.DoubleHandle then
							local DualHandle = WeaponModel:GetAttribute("DualHandle") or "DualShikai2"
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = nil

							WeaponModel[DualHandle].PrimaryPart.Weld.Enabled = true
						end
						if ZanpakutoData.InvisibleDraw then
							for i, v in ipairs(WeaponModel:GetDescendants()) do
								if v:GetAttribute("InvisibleDraw") then
									v.Transparency = 1
								end
							end

							if ZanpakutoData.QuincyDraw then
								WeaponModel.PrimaryPart.PointLight.Enabled = false
								WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", true)

								local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
								local RenderDistance = 1000
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
							end
						end
						if ZanpakutoData.SheatheFunction then
							ZanpakutoData.SheatheFunction(Character, PlayerData[Character.Name])
						end
					end
					
					if not SheatheSoundBlacklist[ZanpakutoWeapon] then
						local SheatheSound = WeaponData[ZanpakutoWeapon .. "AttackData"].SheatheSound or Sounds.Sheathe
						local ClonedSheathe = SheatheSound:Clone()
						ClonedSheathe.PlayOnRemove = true
						ClonedSheathe.Parent = Character.PrimaryPart
						ClonedSheathe:Destroy()
						ClonedSheathe = nil
					end
					
					StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)
					
					StateMachine:PushState("Idle")
					
					StateMachine:Trigger("Sprint", StateMachine, Character)
				elseif Character:GetAttribute("ZanpakutoState") == 1 then
					local Player = Players:GetPlayerFromCharacter(Character)
					local Profile = DataManager:RequestProfile(Player)
					
					Character:SetAttribute("ZanpakutoState", 0)
					
					if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
						local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
						ShikaiModel:Destroy()
						ShikaiModel = nil

						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
						local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")

						WeaponModel.PrimaryPart.Weld.Enabled = false
						WeaponModel.Parent = Character["Right Arm"]

						local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
						Motor6D.Part1 = WeaponModel.PrimaryPart
						Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData
						
						local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
						local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

						if ZanpakutoData and ZanpakutoData.DoubleHandle then
							local DualMotor6D = Character["Left Arm"].DualHandle2
							DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
							DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
						end
					else
						local ZanpakutoModel = Character["Right Arm"].Zanpakuto
						ZanpakutoModel.Handle[ClientData.WeaponModel]:Destroy()
						ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
						ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
						ZanpakutoModel.PrimaryPart.Trail:Destroy()
						ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
						
						local Player = Players:GetPlayerFromCharacter(Character)
						local Profile = DataManager:RequestProfile(Player)
						PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
					end
					
					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon

					local WeaponName = PlayerData[Character.Name].WeaponEquipped
					SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

					local Idle = "Idle"..math.random(1, 3)
					if WeaponName == "Fist" then
						Idle = "Idle1"
					end

					if not IdleBlacklist[ZanpakutoWeapon] then
						local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
						IdleAnimation:Play()
					end
					
					if PlayerData[Character.Name].ShikaiActiveData then
						if PlayerData[Character.Name].ShikaiActiveData.Connections then
							for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
								if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
									PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
								end

								PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
								PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
							end
						end
						PlayerData[Character.Name].ShikaiActiveData = nil
					end
					
					StateMachine:PushState("WeaponDrawn")
					StateMachine:Trigger("Sprint", StateMachine, Character)
				end
			end
		end,
		TriggerDefendChoice = function(StateMachine, Character)
			StateMachine:Trigger("TriggerParry", StateMachine, Character)
		end,
		TriggerAttackChoice = function(StateMachine, Character, Location, TargetedEntity)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local ReactionTime = Random.new():NextNumber(0, 0.1)
			task.delay(ReactionTime, function()
				if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
				
				local function ShikaiSkill()
					if not Character:GetAttribute("ShikaiDisabled") then
						StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
					else
						StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
					end
				end
				
				local function Skill()
					StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
				end
				
				local function LAttack()
					StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
				end
				
				local function CAttack()
					StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
				end
				
				local RNG = Random.new():NextInteger(1, 10)
				if RNG <= 3 then
					CAttack()
				elseif RNG > 3 and RNG < 6 then
					ShikaiSkill()
				elseif RNG >= 6 and RNG <= 8 then
					Skill()
				else
					LAttack()
				end
			end)
		end,
	},
	Flashstep = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerCarry = function(StateMachine, Character, CarriedLeft)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			
			PlayerData[Character.Name].Flashstepping = nil
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			
			if PlayerData[Character.Name].Carrying or CarriedLeft then
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:PushState("WeaponDrawn")
				else
					StateMachine:PushState("Idle")
				end
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("ReleaseCarrying", StateMachine, Character)
			else
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("Carry", StateMachine, Character)
			end
		end,
		CancelSprintAnimations = function(StateMachine, Character)
			SharedFunctions:CancelAnimation(Character.Humanoid, "Sprint", "SearchByReference")
			if PlayerData[Character.Name].ResActive then
				if PlayerData[Character.Name].ResActive.AccessoryAnimations then
					local ResAnimator = PlayerData[Character.Name].ResActive.ResAnimator
					SharedFunctions:CancelAnimation(ResAnimator, "Sprint", "SearchByReference")
				end
			end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			BankaiWeapons:CancelWeaponAnimation(Character, "Sprint", Profile.ClientData, PlayerData[Character.Name], true)
		end,
		StopSprint = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
		end,
		TriggerSprint = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = true
		end,
		--[[Flashstep = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			local UnlockedSkills = Profile.UnlockedSkills
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Player).FlashstepMastery

			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end
			
			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= FlashstepMasteryIndex[FlashstepMasteries].Cooldown and ReiatsuValue >= 0 then
				PlayerData[Character.Name].FlashstepDuration = DateTime.now().UnixTimestampMillis
				PlayerData[Character.Name].Flashstepping = true
				Character:SetAttribute("FlashstepTimer", DateTime.now().UnixTimestampMillis)
				Character:SetAttribute("EvasiveFrames", true)
				Character:SetAttribute("Reiatsu", ReiatsuValue)

				local FlashstepDuration = FlashstepMasteryIndex[FlashstepMasteries].Duration

				local FlashstepSpeed = StatData.BaseFlashstepSpeed
				if StatData.Factions[Race] == "Arrancar" then
					FlashstepSpeed += StatData.ArrancarFlashstepBonus
				elseif StatData.Factions[Race] == "Quincy" then
					FlashstepSpeed += StatData.QuincyFlashstepBonus
				end
				end
				if Character:GetAttribute("Shunko") then
					FlashstepSpeed += SkillData.Shunko.FlashstepSpeedBuff
				end
				if Character:GetAttribute("Mashallah") then
					FlashstepSpeed += SkillData.Mashallah.FlashstepSpeedBuff
				end
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					FlashstepSpeed += StatData.BankaiSpeedIncrease
				end
				if Character:GetAttribute("VisoredSpeed") or (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == true) then
					FlashstepSpeed += StatData.VisoredData.Buffs.Speed.Flashstep
				end
				if Character:GetAttribute("VastoSpeed") then
					FlashstepSpeed += StatData.VastocarFlashstepSpeed
				end
				if (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == false) then
					FlashstepSpeed += StatData.VisoredData.Downsides.Speed.Flashstep
				end
				if FlashstepMasteries == 5 then
					FlashstepSpeed += StatData.SoulStep.SpeedBuff
				end
				if Character:GetAttribute("Battery") then
					FlashstepSpeed += Character:GetAttribute("BatteryFlashstepSpeed") * Character:GetAttribute("Battery")
				end
				if table.find(Penalties.Flashstep, Player.UserId) then
					FlashstepSpeed -= 20
				end

				local BonusWalkspeed = FlashstepSpeed + (Profile.ClientData.Speed / StatData.SpeedScaling)
				local MaxHealth = Character.Humanoid.MaxHealth
				local Health = Character.Humanoid.Health

				local HealthRange = MaxHealth - 1
				local FlashstepDurationRange = FlashstepDuration - StatData.FlashstepDurationScale
				local ScaledFlashstepDuration = (((Health - 1) * FlashstepDurationRange) / HealthRange) + StatData.FlashstepDurationScale

				AntiCheatManager:AddDistance(Player, BonusWalkspeed, ScaledFlashstepDuration)

				if Character:GetAttribute("HogyokuCapture") then
					BonusWalkspeed = BonusWalkspeed * 0.5
				end

				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") + BonusWalkspeed

				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local Race = Profile.ClientData.Race

				local PathDataStart = {Module = FlashstepClient, Skill = "Flashstep"}
				local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
				local RenderDistance = -1
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStart, Race)

				local Disconnect
				local Duration = ScaledFlashstepDuration
				local Rate = 0.75
				local Accumulated = 0
				local Connection
				Connection = RunService.Heartbeat:Connect(function(DeltaTime)
					Accumulated += DeltaTime
					Duration -= DeltaTime

					if not PlayerData[Character.Name] or not PlayerData[Character.Name].Flashstepping then
						Disconnect = true
					end

					if Disconnect or Duration <= 0 then
						Connection:Disconnect()
						Connection = nil
						StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character)
						Disconnect = true
					end

					if Accumulated > Rate then
						Accumulated -= Rate

						if not Disconnect then
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStart, Race)
						end	
					end
				end)

				local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
				if WeaponEquipped then
					local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations[WeaponEquipped]
					local SprintAnim = CombatAnimations.Sprint
					if PlayerData[Character.Name].ResActive then
						if PlayerData[Character.Name].ResActive.Sprint then
							SprintAnim = PlayerData[Character.Name].ResActive.Sprint
						end
						if PlayerData[Character.Name].ResActive.AccessoryAnimations then
							local ResAnimator = PlayerData[Character.Name].ResActive.ResAnimator
							local ResSprint = PlayerData[Character.Name].ResActive.AccessoryAnimations.Sprint
							if ResSprint then
								ResAnimator:LoadAnimation(ResSprint):Play()
							end
						end
					end
					Character.Humanoid.Animator:LoadAnimation(SprintAnim):Play()
				else
					Character.Humanoid.Animator:LoadAnimation(Animations["Sprint"]):Play()
				end

				local EvasiveDuration = StatData.FlashstepEvasiveFrames
				if Character:GetAttribute("EnhancedSteps") then
					EvasiveDuration += EvasiveDuration * SkillData["Enhanced Steps"].EvasiveFrameMultiplier
				end
				if Character:GetAttribute("VastoSpeed") then
					EvasiveDuration += EvasiveDuration * StatData.VastocarEvasiveMultipier
				end
				if Character:GetAttribute("SpecterStep") then
					EvasiveDuration += EvasiveDuration * Character:GetAttribute("SpecterStep")
				end

				task.delay(EvasiveDuration, function()
					Character:SetAttribute("EvasiveFrames", false)
				end)
			end
		end,]]
		Flashstep = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			local UnlockedSkills = Profile.UnlockedSkills
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("FlashstepTimer")
			local ReiatsuValue = Character:GetAttribute("Reiatsu")
			local FlashstepMasteries = PassivesManager:RequestPassives(Player).FlashstepMastery
			
			local Cooldown = FlashstepMasteryIndex[FlashstepMasteries].Cooldown
			local MaxHealth = Character.Humanoid.MaxHealth
			local Health = Character.Humanoid.Health

			if Health <= MaxHealth * 0.8 then
				local HealthRange = (MaxHealth * 0.8) - 1
				local FlashstepCDRange = FlashstepMasteryIndex[FlashstepMasteries].Cooldown - FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				local ScaledFlashstepCD = (((Health - 1) * FlashstepCDRange) / HealthRange) + FlashstepMasteryIndex[FlashstepMasteries].CooldownScale * FlashstepMasteryIndex[FlashstepMasteries].Cooldown
				Cooldown = ScaledFlashstepCD
			end
			
			local ReiatsuCost = Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
			if Character:GetAttribute("PaintItBlack") then
				ReiatsuCost *= Character:GetAttribute("PaintItBlack")
			end

			ReiatsuValue -= ReiatsuCost
			if TimeDifference >= Cooldown and ReiatsuValue >= 0 then
				PlayerData[Character.Name].FlashstepDuration = DateTime.now().UnixTimestampMillis
				PlayerData[Character.Name].Flashstepping = true
				Character:SetAttribute("FlashstepTimer", DateTime.now().UnixTimestampMillis)
				Character:SetAttribute("EvasiveFrames", true)
				
				if PlayerData[Character.Name].SiphonLink then
					task.spawn(function()
						local SiphonReiatsu = PlayerData[Character.Name].SiphonLink:GetAttribute("Reiatsu")
						SiphonReiatsu -= Character:GetAttribute("MaxReiatsu") * FlashstepMasteryIndex[FlashstepMasteries].ReiatsuCost
						if SiphonReiatsu <= 0 then
							PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", 0)
						else
							PlayerData[Character.Name].SiphonLink:SetAttribute("Reiatsu", SiphonReiatsu)
						end
					end)
				else
					Character:SetAttribute("Reiatsu", ReiatsuValue)
				end
				
				local FlashstepDuration = FlashstepMasteryIndex[FlashstepMasteries].Duration
				
				local FlashstepSpeed = StatData.BaseFlashstepSpeed
				local AddedFlashstepSpeed = 0
				if StatData.Factions[Race] == "Arrancar" then
					AddedFlashstepSpeed += StatData.ArrancarFlashstepBonus
				elseif StatData.Factions[Race] == "Quincy" then
					AddedFlashstepSpeed += StatData.QuincyFlashstepBonus
				end
				if Character:GetAttribute("SternritterSpeed") then
					AddedFlashstepSpeed += StatData.SternritterFlashstepBonus
				end
				if Character:GetAttribute("Shunko") then
					AddedFlashstepSpeed += SkillData.Shunko.FlashstepSpeedBuff
				end
				if Character:GetAttribute("Mashallah") then
					AddedFlashstepSpeed += SkillData.Mashallah.FlashstepSpeedBuff
				end
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					AddedFlashstepSpeed += StatData.BankaiSpeedIncrease
				end
				if Character:GetAttribute("VisoredSpeed") or (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == true) then
					AddedFlashstepSpeed += StatData.VisoredData.Buffs.Speed.Flashstep
				end
				if Character:GetAttribute("VastoSpeed") then
					AddedFlashstepSpeed += StatData.VastocarFlashstepSpeed
				end
				if Character:GetAttribute("LetztStilActive") then
					AddedFlashstepSpeed += StatData.LetztStilFlashstepSpeed
				end
				if Character:GetAttribute("PassingBreath") then
					AddedFlashstepSpeed += FlashstepSpeed * Character:GetAttribute("PassingBreath")
				end
				if (Character:GetAttribute("VisoredDownsideSpeed") and Character:GetAttribute("VisoredMastered") == false) then
					AddedFlashstepSpeed += StatData.VisoredData.Downsides.Speed.Flashstep
				end
				if FlashstepMasteries == 5 then
					AddedFlashstepSpeed += StatData.SoulStep.SpeedBuff
				end
				if Character:GetAttribute("Battery") then
					AddedFlashstepSpeed += Character:GetAttribute("BatteryFlashstepSpeed") * Character:GetAttribute("Battery")
				end
				if table.find(Penalties.Flashstep, Player.UserId) then
					AddedFlashstepSpeed -= 20
				end
				
				local PlayerSpeed = Profile.ClientData.Speed
				if PlayerSpeed > StatData.SpeedScalingCap then
					PlayerSpeed = StatData.SpeedScalingCap
				end
				
				local SpeedStat = (PlayerSpeed / StatData.SpeedScaling)
				if Character:GetAttribute("BankaiFight") then
					SpeedStat *= 0.5
				end
				
				AddedFlashstepSpeed += SpeedStat
				
				if Character:GetAttribute("FlashstepReduced") then
					AddedFlashstepSpeed *= Character:GetAttribute("FlashstepReduced")
				end
				
				local BonusWalkspeed = FlashstepSpeed + AddedFlashstepSpeed
				local MaxHealth = Character.Humanoid.MaxHealth
				local Health = Character.Humanoid.Health
				
				local HealthRange = MaxHealth - 1
				local FlashstepDurationRange = FlashstepDuration - StatData.FlashstepDurationScale
				local ScaledFlashstepDuration = (((Health - 1) * FlashstepDurationRange) / HealthRange) + StatData.FlashstepDurationScale
				ScaledFlashstepDuration = FlashstepDuration
				AntiCheatManager:AddDistance(Player, BonusWalkspeed, ScaledFlashstepDuration)
				
				if Character:GetAttribute("HogyokuCapture") then
					BonusWalkspeed = BonusWalkspeed * 0.5
				end
				if Character:GetAttribute("TrueFlashstepReduced") then
					BonusWalkspeed *= Character:GetAttribute("TrueFlashstepReduced")
				end
				
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") + BonusWalkspeed
				
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local Race = Profile.ClientData.Race

				local PathDataStart = {Module = FlashstepClient, Skill = "Flashstep"}
				local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
				local RenderDistance = -1
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStart, Race)
				
				local Disconnect
				local Duration = ScaledFlashstepDuration--FlashstepDuration
				local Rate = 0.75
				local Accumulated = 0
				
				task.spawn(function()
					while true do
						local Step = task.wait(0.05)
						if Character.Humanoid.Health <= 0 then
							return
						end

						Accumulated += Step
						Duration -= Step

						if not PlayerData[Character.Name] or not PlayerData[Character.Name].Flashstepping then
							Disconnect = true
						end

						if Disconnect or Duration <= 0 then
							StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character)
							Disconnect = true
							return
						end

						if Accumulated > Rate and Race ~= "Quincy" then
							Accumulated -= Rate

							if not Disconnect then
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStart, Race)
							end	
						end
					end	
				end)			
				
				local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
				if WeaponEquipped then
					local CombatAnimations = ReplicatedStorage.Assets.CombatAnimations[WeaponEquipped]
					local SprintAnim = CombatAnimations.Sprint
					if PlayerData[Character.Name].ResActive then
						if PlayerData[Character.Name].ResActive.Sprint then
							SprintAnim = PlayerData[Character.Name].ResActive.Sprint
						end
						if PlayerData[Character.Name].ResActive.AccessoryAnimations then
							local ResAnimator = PlayerData[Character.Name].ResActive.ResAnimator
							local ResSprint = PlayerData[Character.Name].ResActive.AccessoryAnimations.Sprint
							if ResSprint then
								ResAnimator:LoadAnimation(ResSprint):Play()
							end
						end
					end
					Character.Humanoid.Animator:LoadAnimation(SprintAnim):Play()
				else
					Character.Humanoid.Animator:LoadAnimation(Animations["Sprint"]):Play()
				end
				
				PassivesManager:ApplyFlashstepPassives(Character)
				
				local EvasiveDuration = StatData.FlashstepEvasiveFrames
				if Character:GetAttribute("EnhancedSteps") then
					EvasiveDuration += EvasiveDuration * SkillData["Enhanced Steps"].EvasiveFrameMultiplier
				end
				if Character:GetAttribute("HeavenlyRestriction") then
					EvasiveDuration += EvasiveDuration * SkillData["Heavenly Restriction"].EvasiveFrameMultiplier
				end
				if Character:GetAttribute("VastoSpeed") then
					EvasiveDuration += EvasiveDuration * StatData.VastocarEvasiveMultipier
				end
				if Character:GetAttribute("SpecterStep") then
					EvasiveDuration += EvasiveDuration * Character:GetAttribute("SpecterStep")
				end
				
				task.delay(EvasiveDuration, function()
					Character:SetAttribute("EvasiveFrames", false)
				end)
			end
		end,
		PerfectFlashstep = function(StateMachine, Character, AttackOwner, FlashstepCFrame, AttackData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if Character:GetAttribute("Schrift") == "Explode" then
				local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientPassives
				local SparksData = {Module = ClientModule, Skill = "ReverseCombustionSparks"}
				local PathData = {Module = ClientModule, Skill = "ReverseCombustion"}
				local ScreenShakePath = {Module = ClientModule, Skill = "BambiettaScreenShake"}
				local RenderDistance = 1000

				local CombustedCharacter = AttackOwner
				local Bambietta = Character

				local ReverseCombustion = CombustedCharacter:GetAttribute("ReverseCombustion")
				if not ReverseCombustion then
					ReverseCombustion = 0
				end
				ReverseCombustion += 1

				local SpawnPoint = Bambietta.HumanoidRootPart.CFrame
				NetworkManager.FireAllClients(Bambietta, "ClientEffects", RenderDistance, SparksData, SpawnPoint, ReverseCombustion)

				if ReverseCombustion >= SpecData.Bambietta.ReverseCombustion.Stacks then
					CombustedCharacter:SetAttribute("ReverseCombustion", nil)

					local SpawnPoint = CombustedCharacter.HumanoidRootPart.CFrame
					local BambiettaCFrame = Bambietta.HumanoidRootPart.CFrame
					local DetectedEntities = HitDetection:Magnitude(Bambietta, SpawnPoint.Position, SpecData.Bambietta.ReverseCombustion.Properties.Range)
					if DetectedEntities then
						local DamagedEntities = CombatManager:ApplyDamage(Bambietta, DetectedEntities, SpecData.Bambietta.ReverseCombustion)
						for i, v in ipairs(DamagedEntities) do
							KnockbackModule:Repel(Bambietta, BambiettaCFrame.Position, v, 40)
							Ragdoll:Enable(v)
							task.delay(SpecData.Bambietta.ReverseCombustion.TrueStunTime, function()
								Ragdoll:Disable(v, "UnconsciousCheck")
							end)

							local PlayerEntity = Players:GetPlayerFromCharacter(v)
							if PlayerEntity then
								NetworkManager.FireClient(PlayerEntity, PlayerEntity.Character, "ClientEffects", -1, ScreenShakePath)
							end
						end
					end

					NetworkManager.FireAllClients(CombustedCharacter, "ClientEffects", RenderDistance, PathData, SpawnPoint, ReverseCombustion)
				else
					CombustedCharacter:SetAttribute("ReverseCombustion", ReverseCombustion)
				end
			end
			
			if Character:GetAttribute("VastoSpeed") then
				if PlayerData[Character.Name].VastoDodges < StatData.VastocarMaxDodges then
					PlayerData[Character.Name].VastoDodgeCooldown += StatData.VastocarDodgeRestore
				end
			end			
			
			if table.find(Profile.UnlockedSkills, "Blut Vene") and Character:GetAttribute("BlutArterie") then
				local BlutTierData = {
					[1] = SkillData["Blut Vene"];
					[2] = SkillData["Blut Vene 2"];
					[3] = SkillData["Blut Vene 3"];
				}

				local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
				local Amount = BlutTier.Amount
				local BlutDamage = BlutTier.DamageBuff

				local BlutVene = Character:GetAttribute("BlutVene")
				if BlutVene then
					BlutVene += BlutTier.ArterieRestore

					if BlutVene < Amount then
						Character:SetAttribute("BlutVene", BlutVene)
					else
						Character:SetAttribute("BlutVene", Amount)
					end
				end		
			end
			
			AirtimeManager:ReleaseAirtime(Character)
			AirtimeManager:ReleaseAirtime(AttackOwner, "Knockback")
			
			PerfectFlashstep(Character, AttackOwner, FlashstepCFrame, AttackData)
		end,
		TriggerM2 = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, ...)
		end,
		ReleaseFlashstep = function(StateMachine, Character, State, ...)
			PlayerData[Character.Name].Flashstepping = nil
			
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			
			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)

			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			
			if PlayerData[Character.Name].SprintHeld then
				StateMachine:SetState("Sprinting")
				StateMachine:Trigger("Sprint", StateMachine, Character, ...)
			else
				Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
				StateMachine:PopState()
				StateMachine:Trigger(State, StateMachine, Character, ...)
			end
		end,
		-- Actions below auto exit flash step --
		TriggerLAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped and not PlayerData[Character.Name].Carrying  then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("Attacking")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "LightAttack")
			end
		end,
		TriggerCAttack = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped and not Character:GetAttribute("CriticalCooldown") and not PlayerData[Character.Name].Carrying  then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("CriticalAttacking")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "CriticalAttack")
			end
		end,
		TriggerSkill = function(StateMachine, Character, ...)
			if not PlayerData[Character.Name].Carrying and PlayerData[Character.Name].WeaponEquipped then			
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("Skill")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "SkillPress", ...)
			end
		end,
		TriggerHierro = function(StateMachine, Character, ...)
			Hierro(Character, ...)
		end,
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		TriggerShikaiSkill = function(StateMachine, Character, ...)
			if not PlayerData[Character.Name].Carrying then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("ShikaiSkill")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "ShikaiSkillPress", ...)
			end
		end,
		TriggerServerHop = function(StateMachine, Character)
			PlayerData[Character.Name].Flashstepping = nil

			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race

			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)

			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			
			StateMachine:SetState("Action")
			StateMachine:Trigger("ServerHop", StateMachine, Character)
		end,
		TriggerBankaiQuest = function(StateMachine, Character)
			PlayerData[Character.Name].Flashstepping = nil

			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race

			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)

			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)
			
			StateMachine:SetState("Action")
			StateMachine:Trigger("BankaiQuest", StateMachine, Character)
		end,
		TriggerVollstandigQuest = function(StateMachine, Character)
			PlayerData[Character.Name].Flashstepping = nil

			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race

			local PathDataAudio = {Module = FlashstepClient, Skill = "FlashstepAudio"}
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataAudio, Race)

			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)

			StateMachine:SetState("Action")
			StateMachine:Trigger("VollstandigQuest", StateMachine, Character)
		end,
		TriggerParry = function(StateMachine, Character)
			if PlayerData[Character.Name].WeaponEquipped and not PlayerData[Character.Name].Carrying then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("Parrying")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "Parry")
			end
		end,
		TriggerShikaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("ShikaiTimer")
			local ReleaseAllowed

			if TimeDifference >= 3000 then
				if AllowedShikaiRelease[PlayerData[Character.Name].WeaponEquipped] then
					ReleaseAllowed = true
				end
				if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery >= 1 then
					ReleaseAllowed = true
				end	
			end
			
			if ReleaseAllowed then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("Action")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "ShikaiRelease", ...)
			end
		end,
		TriggerQuincyMedallion = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "QuincyMedallion", ...)
		end,
		TriggerBankaiRelease = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			local ReleaseAllowed = true
			if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" then
				if Profile.ClientData.NozarashiMastery < 2 then
					ReleaseAllowed = nil
					local PathData = {Module = ClientProgression, Skill = "NozarashiBankaiHint"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData)
				end
			end
			
			local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.BankaiTimer

			local BankaiCooldown = StatData.BankaiCooldown * 60
			if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
				BankaiCooldown = StatData.ResCooldown * 60
			end

			if TimeDifference < BankaiCooldown then
				ReleaseAllowed = nil
				local PathData = {Module = ClientProgression, Skill = "BankaiTimer"}
				local Text = BankaiCooldown / 60 - math.floor(TimeDifference / 60)
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Text)
			end

			if ReleaseAllowed then
				StateMachine:Trigger("StopSprint", StateMachine, Character)
				StateMachine:PushState("Action")
				StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "BankaiRelease", ...)
			end
		end,
		TriggerBankaiCancel = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "CancelBankai", ...)
		end,
		TriggerSecondBankaiRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "SecondBankaiRelease", ...)
		end,
		TriggerVisoredRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "VisoredRelease", ...)
		end,
		TriggerLetztStilRelease = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Action")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "LetztStilRelease", ...)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("StopSprint", StateMachine, Character)
			StateMachine:PushState("Unconscious")
			StateMachine:Trigger("ReleaseFlashstep", StateMachine, Character, "TriggerKnockout", ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			
			PlayerData[Character.Name].Flashstepping = nil
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)

			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		TriggerPostureBreak = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local Race = Profile.ClientData.Race
			
			PlayerData[Character.Name].Flashstepping = nil
			
			local PathDataStop = {Module = FlashstepClient, Skill = "StopFlashstep"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathDataStop, Race)
			StateMachine:Trigger("CancelSprintAnimations", StateMachine, Character)

			StateMachine:SetState("PostureBroken")
			StateMachine:Trigger("PostureBreak", StateMachine, Character)	
		end,
		TriggerDefendChoice = function(StateMachine, Character)
			StateMachine:Trigger("TriggerParry", StateMachine, Character)
		end,
		TriggerAttackChoice = function(StateMachine, Character, Location, TargetedEntity)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			
			local ReactionTime = Random.new():NextNumber(0, 0.1)
			task.delay(ReactionTime, function()
				if not Character or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then return end
				
				local function CAttack()
					StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
				end
				
				local function ShikaiSkill()
					if not Character:GetAttribute("ShikaiDisabled") then
						StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
					else
						StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
					end
				end
				
				local function Skill()
					StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
				end
				
				local function LAttack()
					StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
				end
				
				local RNG = Random.new():NextInteger(1, 10)
				if RNG <= 2 then
					CAttack()
				elseif RNG > 2 and RNG <= 5 then
					ShikaiSkill()
				elseif RNG > 5 and RNG < 8 then
					Skill()
				else
					LAttack()
				end
			end)
		end,
	},
	Dashing = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerCarry = function(StateMachine, Character, CarriedLeft)
			if PlayerData[Character.Name].Carrying or CarriedLeft then
				if PlayerData[Character.Name].WeaponEquipped then
					StateMachine:PushState("WeaponDrawn")
				else
					StateMachine:PushState("Idle")
				end
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("ReleaseCarrying", StateMachine, Character)
			else
				StateMachine:SetState("Carrying")
				StateMachine:Trigger("Carry", StateMachine, Character)
			end
		end,
		StopSprint = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = nil
		end,
		TriggerSprint = function(StateMachine, Character)
			PlayerData[Character.Name].SprintHeld = true
		end,
		PerfectFlashstep = function(StateMachine, Character, AttackOwner, FlashstepCFrame, AttackData)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if Character:GetAttribute("Schrift") == "Explode" then
				local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientPassives
				local SparksData = {Module = ClientModule, Skill = "ReverseCombustionSparks"}
				local PathData = {Module = ClientModule, Skill = "ReverseCombustion"}
				local ScreenShakePath = {Module = ClientModule, Skill = "BambiettaScreenShake"}
				local RenderDistance = 1000

				local CombustedCharacter = AttackOwner
				local Bambietta = Character

				local ReverseCombustion = CombustedCharacter:GetAttribute("ReverseCombustion")
				if not ReverseCombustion then
					ReverseCombustion = 0
				end
				ReverseCombustion += 1

				local SpawnPoint = Bambietta.HumanoidRootPart.CFrame
				NetworkManager.FireAllClients(Bambietta, "ClientEffects", RenderDistance, SparksData, SpawnPoint, ReverseCombustion)

				if ReverseCombustion >= SpecData.Bambietta.ReverseCombustion.Stacks then
					CombustedCharacter:SetAttribute("ReverseCombustion", nil)

					local SpawnPoint = CombustedCharacter.HumanoidRootPart.CFrame
					local BambiettaCFrame = Bambietta.HumanoidRootPart.CFrame
					local DetectedEntities = HitDetection:Magnitude(Bambietta, SpawnPoint.Position, SpecData.Bambietta.ReverseCombustion.Properties.Range)
					if DetectedEntities then
						local DamagedEntities = CombatManager:ApplyDamage(Bambietta, DetectedEntities, SpecData.Bambietta.ReverseCombustion)
						for i, v in ipairs(DamagedEntities) do
							KnockbackModule:Repel(Bambietta, BambiettaCFrame.Position, v, 40)
							Ragdoll:Enable(v)
							task.delay(SpecData.Bambietta.ReverseCombustion.TrueStunTime, function()
								Ragdoll:Disable(v, "UnconsciousCheck")
							end)

							local PlayerEntity = Players:GetPlayerFromCharacter(v)
							if PlayerEntity then
								NetworkManager.FireClient(PlayerEntity, PlayerEntity.Character, "ClientEffects", -1, ScreenShakePath)
							end
						end
					end

					NetworkManager.FireAllClients(CombustedCharacter, "ClientEffects", RenderDistance, PathData, SpawnPoint, ReverseCombustion)
				else
					CombustedCharacter:SetAttribute("ReverseCombustion", ReverseCombustion)
				end
			end
			
			AirtimeManager:ReleaseAirtime(Character)
			AirtimeManager:ReleaseAirtime(AttackOwner, "Knockback")
			
			if Character:GetAttribute("VastoSpeed") then
				Character:SetAttribute("DashTimer", 0)
				if PlayerData[Character.Name].VastoDodges < StatData.VastocarMaxDodges then
					PlayerData[Character.Name].VastoDodgeCooldown += StatData.VastocarDodgeRestore
				end
			end
			
			if table.find(Profile.UnlockedSkills, "Blut Vene") and Character:GetAttribute("BlutArterie") then
				local BlutTierData = {
					[1] = SkillData["Blut Vene"];
					[2] = SkillData["Blut Vene 2"];
					[3] = SkillData["Blut Vene 3"];
				}

				local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
				local Amount = BlutTier.Amount
				local BlutDamage = BlutTier.DamageBuff
				
				local BlutVene = Character:GetAttribute("BlutVene")
				if BlutVene then
					BlutVene += BlutTier.ArterieRestore
					
					if BlutVene < Amount then
						Character:SetAttribute("BlutVene", BlutVene)
					else
						Character:SetAttribute("BlutVene", Amount)
					end
				end		
			end
			
			PerfectFlashstep(Character, AttackOwner, FlashstepCFrame, AttackData)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		Dash = function(StateMachine, Character, KeyPressed)
			local Cooldown = 1750
			if Character:GetAttribute("EnhancedSteps") then
				Cooldown = SkillData["Enhanced Steps"].DashCooldown
			end
			if Character:GetAttribute("HeavenlyRestriction") then
				Cooldown = SkillData["Heavenly Restriction"].DashCooldown
			end
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("DashTimer")
			if TimeDifference >= Cooldown then
				Character:SetAttribute("EvasiveFrames", true)
				Character:SetAttribute("DashTimer", DateTime.now().UnixTimestampMillis)
				
				local Player = Players:GetPlayerFromCharacter(Character)
				AntiCheatManager:AddDistance(Player, 45, 0.45)
				
				if Character.Head:FindFirstChildWhichIsA("BodyVelocity") then
					Character.Head:FindFirstChildWhichIsA("BodyVelocity"):Destroy()
				end
				
				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.Name = "DashForce"
				BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
				BodyVelocity.Parent = Character.Head
				Debris:AddItem(BodyVelocity, 0.45)
				
				local DashSound = Sounds.Dash:Clone()
				DashSound.PlayOnRemove = true
				DashSound.Parent = Character.PrimaryPart
				DashSound:Destroy()
				DashSound = nil
				
				local DashVelocity = 45
				if Character:GetAttribute("DashReduced") then
					DashVelocity *= Character:GetAttribute("DashReduced")
				end
				
				ReplicatedStorage.Remotes.RotationalDash:FireClient(Player, BodyVelocity, KeyPressed, DashVelocity, true)
				
				local EvasiveDuration = StatData.DashEvasiveFrames
				if Character:GetAttribute("EnhancedSteps") then
					EvasiveDuration += EvasiveDuration * SkillData["Enhanced Steps"].EvasiveFrameMultiplier
				end
				if Character:GetAttribute("VastoSpeed") then
					EvasiveDuration += EvasiveDuration * StatData.VastocarEvasiveMultipier
				end
				if Character:GetAttribute("HeavenlyRestriction") then
					EvasiveDuration += EvasiveDuration * SkillData["Heavenly Restriction"].EvasiveFrameMultiplier
				end
				if Character:GetAttribute("SpecterStep") then
					EvasiveDuration += EvasiveDuration * Character:GetAttribute("SpecterStep")
				end
				
				task.delay(EvasiveDuration, function()
					Character:SetAttribute("EvasiveFrames", false)
				end)
				task.delay(StatData.DashReleaseDuration, function()
					if Character:GetAttribute("Zombification") then
						if KeyPressed == "W" then
							StateMachine:Trigger("ReleaseDashing", StateMachine, Character)
						else
							StateMachine:Trigger("TriggerAttackChoice", StateMachine, Character)
						end
					else
						StateMachine:Trigger("ReleaseDashing", StateMachine, Character)
					end
				end)
			else
				StateMachine:Trigger("ReleaseDashing", StateMachine, Character)
			end
		end,
		ReleaseDashing = function(StateMachine, Character)
			--local Stack = EntityManager:RetrieveData(Character).EntityMachine.Stack
			--if Stack[#Stack] == "Sprinting" then 
			if PlayerData[Character.Name].SprintHeld then
				StateMachine:SetState("Sprinting")
				StateMachine:Trigger("Sprint", StateMachine, Character)
			else
				StateMachine:PopState()
			end
		end,
		--[[TriggerM2 = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			if Character.Head:FindFirstChild("DashForce") then
				Character.Head.DashForce:Destroy()
			end
			ReplicatedStorage.Remotes.CancelClientAnimation:FireClient(Player, "Dash", "SearchByReference")
			StateMachine:Trigger("ReleaseDashing", StateMachine, Character)
		end,]]
		TriggerAttackChoice = function(StateMachine, Character, Location, TargetedEntity)
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")

			local function Attack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerLAttack", StateMachine, Character, Location)
			end

			local function CAttack()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerCAttack", StateMachine, Character, Location)
			end

			local function ShikaiSkill()
				StateMachine:SetState("WeaponDrawn")
				if not Character:GetAttribute("ShikaiDisabled") then
					StateMachine:Trigger("TriggerShikaiSkill", StateMachine, Character, Location)
				else
					StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
				end
			end

			local function Skill()
				StateMachine:SetState("WeaponDrawn")
				StateMachine:Trigger("TriggerSkill", StateMachine, Character, TargetedEntity)
			end

			local RNG = Random.new():NextInteger(1, 10)
			if RNG <= 1 then
				CAttack()
			elseif RNG > 1 and RNG < 3 then
				ShikaiSkill()
			elseif RNG >= 3 and RNG <= 5 then
				Skill()
			else
				Attack()
			end
		end,
	},
	Executing = {
		TriggerBlutSwap = function(StateMachine, Character, ...)
			SwapBlutMode(Character, ...)
		end,
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		CounterSuccess = function(StateMachine, Character, ...)
			CounterSuccess(Character, StateMachine, ...)
		end,
		PerfectFlashstep = function(StateMachine, Character, ...)
			PerfectFlashstep(Character, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		HomeReturn = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)		
			local PlayerFaction = StatData.Factions[Profile.ClientData.Race]
			
			local ReturnAllowed
			if table.find(PositionTitles.ShinigamiCaptainTitles, Profile.ClientData.Title) and StatData.SoulSociety then
				ReturnAllowed = true
			elseif table.find(PositionTitles.ArrancarEspadaTitles, Profile.ClientData.Title) and StatData.HuecoMundo then
				ReturnAllowed = true
			elseif table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title) and StatData.WandenreichCity then
				ReturnAllowed = true
			end
			
			local KillCheck = false
			if ReturnAllowed then
				local Params = RaycastParams.new()
				Params.FilterType = Enum.RaycastFilterType.Exclude
				Params.FilterDescendantsInstances = {workspace.Entities}

				for i, v in pairs(workspace.Entities:GetChildren()) do
					local GrippedPlayer = Players:GetPlayerFromCharacter(v)
					if v.PrimaryPart and GrippedPlayer and v:GetAttribute("CurrentState") == "Unconscious" and not v:GetAttribute("Carried") and not v:GetAttribute("Death") and v ~= Character  and not KillCheck and not v:GetAttribute("GripBypass") then
						if (v.HumanoidRootPart.Position - Character.PrimaryPart.Position).Magnitude < 6 then
							local FloorCheck = workspace:Raycast(v.HumanoidRootPart.Position, Vector3.new(0, StatData.GripRayHeight, 0), Params)
							if FloorCheck then
								local GrippedProfile = DataManager:RequestProfile(GrippedPlayer)
								local CurrentFaction = StatData.Factions[GrippedProfile.ClientData.Race]
								if StatData.CurrentFactions[CurrentFaction] and CurrentFaction ~= PlayerFaction then
									EntityManager:ChangeState(v, "TriggerDying")

									KillCheck = true

									Character.Humanoid.WalkSpeed = 0
									Character.Humanoid.JumpHeight = 0

									Ragdoll:Disable(v)

									PlayerData[Character.Name].Victim = v
									v.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)
									Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)

									v.HumanoidRootPart.Anchored = true
									Character.Humanoid.AutoRotate = false
									Character.HumanoidRootPart.Anchored = true

									local HomeReturnAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.HomeReturn)
									HomeReturnAnimation:Play()
									HomeReturnAnimation.KeyframeReached:Connect(function(KeyframeName)
										if KeyframeName == "HitFrame" then
											v.HumanoidRootPart.Anchored = false
											Character.HumanoidRootPart.Anchored = false

											if PlayerData[Character.Name].VictimDestroyed then
												PlayerData[Character.Name].VictimDestroyed:Disconnect()
												PlayerData[Character.Name].VictimDestroyed = nil
											end
											v:SetAttribute("ReturnHome", true)
											Character:GetAttribute("ReturnTimer", DateTime.now().UnixTimestampMillis)
											
											GrippedProfile.ClientData.ReturnTimer = DateTime.now().UnixTimestamp
											
											EntityManager:ChangeState(v, "TriggerDeath", Character)
											PlayerData[Character.Name].Victim = nil

											local GripAudio = Sounds.Grip

											local GrippedPlayer = Players:GetPlayerFromCharacter(v)
											if GrippedPlayer then
												if Profile.ClientData.Race ~= GrippedProfile.ClientData.Race then
													RankManager:AddEXP(Player, StatData.ExecuteEXP)
												end
												
												local GrippedFaction = StatData.Factions[GrippedProfile.ClientData.Race]
												local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
												if StatData.CurrentFactions[GrippedFaction] and GrippedFaction ~= CurrentFaction then
													if Profile.ClientData.EloDisabledTimer then
														Profile.ClientData.EloDisabledTimer -= StatData.BountyRankedDisableReduction * 60
													end
													
													if CurrentFaction == "Shinigami" then
														Profile.ClientData.ShikaiTimer -= StatData.ShikaiFightCDGripReduction * 60
														
														if not Profile.ClientData.BankaiUnlocked then
															Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.BankaiSwordCDGripReduction * 60
														end
													elseif CurrentFaction == "Arrancar" then
														Profile.ClientData.ShikaiTimer -= StatData.ResCDGripReduction * 60
													elseif CurrentFaction == "Quincy" then
														if not Profile.ClientData.BankaiUnlocked then
															Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.VollstandigCDGripReduction * 60
														end
													end
												end
											else
												RankManager:AddEXP(Player, StatData.ExecuteEXP)
											end

											local GrippedRace = v:GetAttribute("EntityType")
											if HollowRace[GrippedRace] then
												GrippedRace = "Hollow"
											elseif GrippedRace == "Visored" then
												GrippedRace = "Shinigami"
											end

											local ShikaiEXPAction = "Grip"
											local Profile = DataManager:RequestProfile(Player)
											if Profile.ClientData.ShikaiPersonality == "Vengeful" then
												local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.VengefulTimer
												local Minutes = TimeDifference / 60
												print(Player.Name .. " Vengeful Time Diff:", Minutes, "Duration:", StatData.VengefulEXPDuration)
												if GrippedRace == Profile.ClientData.VengefulRace then
													ShikaiEXPAction = "RevengeGrip"
												end
											end

											RankManager:AddShikaiEXP(Player, ShikaiEXPAction, StatData.ShikaiEXP)

											local GripSound = GripAudio:Clone()
											GripSound.PlayOnRemove = true
											GripSound.Parent = Character.PrimaryPart
											GripSound:Destroy()
											GripSound = nil

											if PlayerData[Character.Name].ExecutorDestroyed then
												PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
												PlayerData[Character.Name].ExecutorDestroyed = nil
											end
										elseif KeyframeName == "AnimationEnd" then
											StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
										end
									end)

									local Player = Players:GetPlayerFromCharacter(Character)
									PlayerData[Character.Name].ExecutorDestroyed = Player.CharacterRemoving:Connect(function() -- Player left
										EntityManager:ChangeState(v, "ReleaseDying", Character)
										if PlayerData[Character.Name].VictimDestroyed then
											PlayerData[Character.Name].VictimDestroyed:Disconnect()
											PlayerData[Character.Name].VictimDestroyed = nil
										end
										if PlayerData[Character.Name].ExecutorDestroyed then
											PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
											PlayerData[Character.Name].ExecutorDestroyed = nil
										end
									end)

									PlayerData[Character.Name].VictimDestroyed = v.Destroying:Connect(function() -- Target left
										Character.HumanoidRootPart.Anchored = false
										StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
										if PlayerData[Character.Name].ExecutorDestroyed then
											PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
											PlayerData[Character.Name].ExecutorDestroyed = nil
										end
										if PlayerData[Character.Name].VictimDestroyed then
											PlayerData[Character.Name].VictimDestroyed:Disconnect()
											PlayerData[Character.Name].VictimDestroyed = nil
										end
									end)
								end
							end
						end
					end
				end	
			end 
			
			if not KillCheck then
				StateMachine:SetState("WeaponDrawn")
			end
		end,
		Execute = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
			if WeaponEquipped then
				local ClosestPlayerFromMouse
				if Character:GetAttribute("Schrift") == "Zombie" and Character:GetAttribute("ZanpakutoState") >= 2 then
					ClosestPlayerFromMouse = SharedFunctions:GetTargetByMouse(Player, SpecData.Giselle.GripRange, 30)
				end
				
				if ClosestPlayerFromMouse and ClosestPlayerFromMouse.PrimaryPart and ClosestPlayerFromMouse:GetAttribute("CurrentState") == "Unconscious" and not ClosestPlayerFromMouse:GetAttribute("Carried") and not ClosestPlayerFromMouse:GetAttribute("Death") and not ClosestPlayerFromMouse:GetAttribute("GripBypass") then
					ClosestPlayerFromMouse.HumanoidRootPart.Anchored = true
					ClosestPlayerFromMouse:SetAttribute("Carried", true)
					ClosestPlayerFromMouse:SetAttribute("GripBypass", true)
					ClosestPlayerFromMouse:SetAttribute("IFrames", true)

					task.delay(2, function()
						ClosestPlayerFromMouse.HumanoidRootPart.Anchored = false

						if PlayerData[Character.Name].ExecutorDestroyed then
							PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
							PlayerData[Character.Name].ExecutorDestroyed = nil
						end
						if PlayerData[Character.Name].VictimDestroyed then
							PlayerData[Character.Name].VictimDestroyed:Disconnect()
							PlayerData[Character.Name].VictimDestroyed = nil
						end

						local PlayerTarget = Players:GetPlayerFromCharacter(ClosestPlayerFromMouse)
						if PlayerTarget and not ClosestPlayerFromMouse:GetAttribute("Zombification") then
							local TargetProfile = DataManager:RequestProfile(PlayerTarget)

							local ReleaseBankai
							local ZombieDataBankaiReleases = PlayerData[Character.Name].ZombieData.BankaiReleases
							if TargetProfile.ClientData.BankaiUnlocked and ZombieDataBankaiReleases < SpecData.Giselle.MaxBankaiRelease then
								PlayerData[Character.Name].ZombieData.BankaiReleases += 1
								ReleaseBankai = true
							end

							ClosestPlayerFromMouse:SetAttribute("ZombieOwner", Character.Name)

							local ClientSpecs = ReplicatedStorage.Modules.ClientModules.ClientSpecs
							local PathData = {Module = ClientSpecs, Skill = "Zombification"}
							local RenderDistance = 1000
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)

							if PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse] then
								PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse]:Disconnect()
								PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse] = nil
							end

							PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse] = PlayerTarget.CharacterRemoving:Connect(function()
								PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse]:Disconnect()
								PlayerData[Character.Name].ZombieData.Connections[ClosestPlayerFromMouse] = nil
								if ReleaseBankai then
									PlayerData[Character.Name].ZombieData.BankaiReleases -= 1
									if PlayerData[Character.Name].ZombieData.BankaiReleases <= 0 then
										PlayerData[Character.Name].ZombieData.BankaiReleases = 0
									end
								end
							end)

							ClosestPlayerFromMouse:SetAttribute("Carried", nil)
							ClosestPlayerFromMouse:SetAttribute("GripBypass", nil)
							ClosestPlayerFromMouse:SetAttribute("IFrames", false)
							
							EntityManager:ChangeState(ClosestPlayerFromMouse, "TriggerDying")
							EntityManager:ChangeState(ClosestPlayerFromMouse, "TriggerZombification", Character, nil, ReleaseBankai)
						else
							EntityManager:ChangeState(ClosestPlayerFromMouse, "TriggerDying")
							EntityManager:ChangeState(ClosestPlayerFromMouse, "TriggerDeath", Character)
						end

						PlayerData[Character.Name].Victim = nil

						local Player = Players:GetPlayerFromCharacter(Character)

						local GrippedPlayer = Players:GetPlayerFromCharacter(ClosestPlayerFromMouse)
						if GrippedPlayer then
							local Profile = DataManager:RequestProfile(Player)
							local GrippedProfile = DataManager:RequestProfile(GrippedPlayer)
							if Profile.ClientData.Race ~= GrippedProfile.ClientData.Race then
								RankManager:AddEXP(Player, StatData.ExecuteEXP)
							end

							local GrippedFaction = StatData.Factions[GrippedProfile.ClientData.Race]
							local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
							if StatData.CurrentFactions[GrippedFaction] and GrippedFaction ~= CurrentFaction then
								if Profile.ClientData.EloDisabledTimer then
									Profile.ClientData.EloDisabledTimer -= StatData.BountyRankedDisableReduction * 60
								end

								if CurrentFaction == "Shinigami" then
									Profile.ClientData.ShikaiTimer -= StatData.ShikaiFightCDGripReduction * 60

									if not Profile.ClientData.BankaiUnlocked then
										Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.BankaiSwordCDGripReduction * 60
									end
								elseif CurrentFaction == "Arrancar" then
									Profile.ClientData.ShikaiTimer -= StatData.ResCDGripReduction * 60
								elseif CurrentFaction == "Quincy" then
									if not Profile.ClientData.BankaiUnlocked then
										Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.VollstandigCDGripReduction * 60
									end
								end
							end
						else
							RankManager:AddEXP(Player, StatData.ExecuteEXP)
						end

						if PlayerData[Character.Name].ExecutorDestroyed then
							PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
							PlayerData[Character.Name].ExecutorDestroyed = nil
						end
					end)

					local ZombieBall = ServerStorage.Assets.Specs.Giselle.ZombieBall:Clone()
					ZombieBall.CFrame = CFrame.new(Character.HumanoidRootPart.Position, ClosestPlayerFromMouse.HumanoidRootPart.Position)
					ZombieBall.Parent = workspace.Effects[Character.Name]
					Debris:AddItem(ZombieBall, 2)

					TweenService:Create(ZombieBall, TweenInfo.new(2), {Position = ClosestPlayerFromMouse.HumanoidRootPart.Position}):Play()

					local BloodFireSound = ReplicatedStorage.Assets.Effects.Giselle.Sounds.BloodFire:Clone()
					BloodFireSound.PlayOnRemove = true
					BloodFireSound.Parent = Character.HumanoidRootPart
					BloodFireSound:Destroy()
					BloodFireSound = nil
					
					StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
				else
					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Exclude
					Params.FilterDescendantsInstances = {workspace.Entities}

					local KillCheck = false
					for i, v in pairs(workspace.Entities:GetChildren()) do
						if v.PrimaryPart and v:GetAttribute("CurrentState") == "Unconscious" and not v:GetAttribute("Carried") and not v:GetAttribute("Death") and v ~= Character  and not KillCheck and not v:GetAttribute("GripBypass") then
							if (v.HumanoidRootPart.Position - Character.PrimaryPart.Position).Magnitude < 6 then
								local Whitelisted = true
								if v:GetAttribute("WhitelistedAttacker") and v:GetAttribute("WhitelistedAttacker") ~= Character.Name then
									Whitelisted = nil
								end
								
								local FloorCheck = workspace:Raycast(v.HumanoidRootPart.Position, Vector3.new(0, StatData.GripRayHeight, 0), Params)
								if FloorCheck and Whitelisted then
									EntityManager:ChangeState(v, "TriggerDying")

									KillCheck = true

									Character.Humanoid.WalkSpeed = 0
									Character.Humanoid.JumpHeight = 0

									Ragdoll:Disable(v)

									PlayerData[Character.Name].Victim = v
									v.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)
									Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)

									--[[local Weld = Instance.new("Weld")
									Weld.Name = "GripWeld"
									Weld.Part0 = Character.HumanoidRootPart
									Weld.Part1 = v.HumanoidRootPart
									Weld.C0 = CFrame.new(0, 0, -2.75) * CFrame.Angles(0, math.pi, 0)
									Weld.Parent = Character]]

									v.HumanoidRootPart.Anchored = true
									Character.Humanoid.AutoRotate = false
									Character.HumanoidRootPart.Anchored = true

									--local WeaponEquipped = PlayerData[Character.Name].WeaponEquipped
									local GripAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponEquipped].Grip)
									local DyingAnimation = v.Humanoid:LoadAnimation(CombatAnimations[WeaponEquipped].Gripped)

									GripAnimation:Play()
									DyingAnimation:Play()

									GripAnimation.KeyframeReached:Connect(function(KeyframeName)
										if KeyframeName == "EventFrame" then
											v.HumanoidRootPart.Anchored = false
											Character.HumanoidRootPart.Anchored = false

											if PlayerData[Character.Name].VictimDestroyed then
												PlayerData[Character.Name].VictimDestroyed:Disconnect()
												PlayerData[Character.Name].VictimDestroyed = nil
											end

											local PlayerTarget = Players:GetPlayerFromCharacter(v)
											if Character:GetAttribute("Schrift") == "Zombie" and PlayerTarget and not v:GetAttribute("Zombification") then
												local TargetProfile = DataManager:RequestProfile(PlayerTarget)

												local ReleaseBankai
												local ZombieDataBankaiReleases = PlayerData[Character.Name].ZombieData.BankaiReleases
												if TargetProfile.ClientData.BankaiUnlocked and ZombieDataBankaiReleases < SpecData.Giselle.MaxBankaiRelease then
													PlayerData[Character.Name].ZombieData.BankaiReleases += 1
													ReleaseBankai = true
												end

												v:SetAttribute("ZombieOwner", Character.Name)

												local ClientSpecs = ReplicatedStorage.Modules.ClientModules.ClientSpecs
												local PathData = {Module = ClientSpecs, Skill = "Zombification"}
												local RenderDistance = 1000
												NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)

												if PlayerData[Character.Name].ZombieData.Connections[v] then
													PlayerData[Character.Name].ZombieData.Connections[v]:Disconnect()
													PlayerData[Character.Name].ZombieData.Connections[v] = nil
												end

												PlayerData[Character.Name].ZombieData.Connections[v] = PlayerTarget.CharacterRemoving:Connect(function()
													PlayerData[Character.Name].ZombieData.Connections[v]:Disconnect()
													PlayerData[Character.Name].ZombieData.Connections[v] = nil
													if ReleaseBankai then
														PlayerData[Character.Name].ZombieData.BankaiReleases -= 1
														if PlayerData[Character.Name].ZombieData.BankaiReleases <= 0 then
															PlayerData[Character.Name].ZombieData.BankaiReleases = 0
														end
													end
												end)

												EntityManager:ChangeState(v, "TriggerZombification", Character, nil, ReleaseBankai)

												local BloodFireSound = ReplicatedStorage.Assets.Effects.Giselle.Sounds.BloodFire:Clone()
												BloodFireSound.PlayOnRemove = true
												BloodFireSound.Parent = Character.HumanoidRootPart
												BloodFireSound:Destroy()
												BloodFireSound = nil
											else
												EntityManager:ChangeState(v, "TriggerDeath", Character)
											end

											PlayerData[Character.Name].Victim = nil

											local GripAudio = Sounds.Grip

											local Player = Players:GetPlayerFromCharacter(Character)

											local GrippedPlayer = Players:GetPlayerFromCharacter(v)
											if GrippedPlayer then
												local Profile = DataManager:RequestProfile(Player)
												local GrippedProfile = DataManager:RequestProfile(GrippedPlayer)
												if Profile.ClientData.Race ~= GrippedProfile.ClientData.Race then
													RankManager:AddEXP(Player, StatData.ExecuteEXP)
												end

												local GrippedFaction = StatData.Factions[GrippedProfile.ClientData.Race]
												local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
												if StatData.CurrentFactions[GrippedFaction] and GrippedFaction ~= CurrentFaction then
													if Profile.ClientData.EloDisabledTimer then
														Profile.ClientData.EloDisabledTimer -= StatData.BountyRankedDisableReduction * 60
													end

													if CurrentFaction == "Shinigami" then
														Profile.ClientData.ShikaiTimer -= StatData.ShikaiFightCDGripReduction * 60

														if not Profile.ClientData.BankaiUnlocked then
															Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.BankaiSwordCDGripReduction * 60
														end
													elseif CurrentFaction == "Arrancar" then
														Profile.ClientData.ShikaiTimer -= StatData.ResCDGripReduction * 60
													elseif CurrentFaction == "Quincy" then
														if not Profile.ClientData.BankaiUnlocked then
															Profile.ClientData.BankaiRequirements.BankaiSwordTimer -= StatData.VollstandigCDGripReduction * 60
														end
													end
												end
											else
												RankManager:AddEXP(Player, StatData.ExecuteEXP)
											end

											local GrippedRace = v:GetAttribute("EntityType")
											if HollowRace[GrippedRace] then
												GrippedRace = "Hollow"
											elseif GrippedRace == "Visored" then
												GrippedRace = "Shinigami"
											end

											local ShikaiEXPAction = "Grip"
											local Profile = DataManager:RequestProfile(Player)
											if Profile.ClientData.ShikaiPersonality == "Vengeful" then
												local TimeDifference = DateTime.now().UnixTimestamp - Profile.ClientData.VengefulTimer
												local Minutes = TimeDifference / 60
												print(Player.Name .. " Vengeful Time Diff:", Minutes, "Duration:", StatData.VengefulEXPDuration)
												if GrippedRace == Profile.ClientData.VengefulRace then
													ShikaiEXPAction = "RevengeGrip"
												end
											end

											RankManager:AddShikaiEXP(Player, ShikaiEXPAction, StatData.ShikaiEXP)

											local GripSound = GripAudio:Clone()
											GripSound.PlayOnRemove = true
											GripSound.Parent = Character.PrimaryPart
											GripSound:Destroy()
											GripSound = nil

											if PlayerData[Character.Name].ExecutorDestroyed then
												PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
												PlayerData[Character.Name].ExecutorDestroyed = nil
											end
										elseif KeyframeName == "AnimationEnd" then
											StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
										end
									end)

									local Player = Players:GetPlayerFromCharacter(Character)
									PlayerData[Character.Name].ExecutorDestroyed = Player.CharacterRemoving:Connect(function() -- Player left
										EntityManager:ChangeState(v, "ReleaseDying", Character)
										if PlayerData[Character.Name].VictimDestroyed then
											PlayerData[Character.Name].VictimDestroyed:Disconnect()
											PlayerData[Character.Name].VictimDestroyed = nil
										end
										if PlayerData[Character.Name].ExecutorDestroyed then
											PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
											PlayerData[Character.Name].ExecutorDestroyed = nil
										end
									end)

									PlayerData[Character.Name].VictimDestroyed = v.Destroying:Connect(function() -- Target left
										if PlayerData[Character.Name].ExecutorDestroyed then
											PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
											PlayerData[Character.Name].ExecutorDestroyed = nil
										end
										if PlayerData[Character.Name].VictimDestroyed then
											PlayerData[Character.Name].VictimDestroyed:Disconnect()
											PlayerData[Character.Name].VictimDestroyed = nil
										end
										Character.HumanoidRootPart.Anchored = false
										StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
									end)
								end
							end
						end
					end		
					if not KillCheck then
						StateMachine:SetState("WeaponDrawn")
					end
				end
			else
				StateMachine:SetState("Idle")
			end
		end,
		TriggerExecute = function(StateMachine, Character)
			--EntityManager:ChangeState(PlayerData[Character.Name].Victim, "TriggerUnconscious")
			--PlayerData[Character.Name].Victim = nil
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerTrueStun = function(StateMachine, Character, ...)
			StateMachine:Trigger("ReleaseExecute", StateMachine, Character)
			StateMachine:PushState("WeaponDrawn")
			StateMachine:SetState("TrueStunned")
			StateMachine:Trigger("TrueStun", StateMachine, Character, ...)
		end,
		ReleaseExecute = function(StateMachine, Character)
			if PlayerData[Character.Name].VictimDestroyed then
				PlayerData[Character.Name].VictimDestroyed:Disconnect()
				PlayerData[Character.Name].VictimDestroyed = nil
			end
			
			if PlayerData[Character.Name].ExecutorDestroyed then
				PlayerData[Character.Name].ExecutorDestroyed:Disconnect()
				PlayerData[Character.Name].ExecutorDestroyed = nil
			end
			
			if PlayerData[Character.Name].VictimDied then
				PlayerData[Character.Name].VictimDied:Disconnect()
				PlayerData[Character.Name].VictimDied = nil
			end
			
			task.spawn(function()
				if PlayerData[Character.Name].Victim then
					PlayerData[Character.Name].Victim.HumanoidRootPart.Anchored = false
					EntityManager:ChangeState(PlayerData[Character.Name].Victim, "ReleaseDying", Character)
					PlayerData[Character.Name].Victim = nil
				end
			end)
			
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Grip")
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "HomeReturn")
			
			local GripWeld = Character:FindFirstChild("GripWeld")
			if GripWeld then
				GripWeld:Destroy()
				GripWeld = nil
			end
			local GripWeld2 = Character:FindFirstChild("GripOrientation")
			if GripWeld2 then
				GripWeld2:Destroy()
				GripWeld2 = nil
			end
			
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed") 
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			Character.HumanoidRootPart.Anchored = false
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
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		ReleaseDying = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Gripped")
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerKnockout", StateMachine, Character, ...)
		end,
		TriggerZombification = function(StateMachine, Character, ...)
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "Gripped")
			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("TriggerZombification", StateMachine, Character, ...)
		end,
		TriggerDeath = function(StateMachine, Character, Executor, Dismembered)
			Character:SetAttribute("Death", true)
			StateMachine:CleanStack()
			
			local ExecutorPlayer = Players:GetPlayerFromCharacter(Executor)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if not Character:GetAttribute("DeathBypass") then
				if ExecutorPlayer then
					local ExecutorProfile = DataManager:RequestProfile(ExecutorPlayer)
					local Race = Profile.ClientData.Race
					local ExecutorShikaiUnlocked = ExecutorProfile.ClientData.ShikaiUnlocked
					local ExecutorBankaiUnlocked = ExecutorProfile.ClientData.BankaiUnlocked

					local function StealItem(Item)
						local RNG = Random.new()
						local RandomNumber = RNG:NextNumber(1, 100)
						if RandomNumber <= 25 then
							if Profile.ItemInventory[Item] then
								DataManager:RemoveItem(Player, Item, 1)
								DataManager:AddItem(ExecutorPlayer, Item, 1)

								local WebhookInfo = {
									Message = ExecutorPlayer.Name .. " has stolen a " .. Item .. " from " .. Player.Name;
								}

								Webhooks:Post(ItemWebhookChannel, WebhookInfo)
							end
						end
					end
					
					StealItem("Hogyoku Fragment")
					StealItem("Skill Box")				
					
					local StolenKan = StatData.KanLossOnDeath
					local CurrentKan = Profile.ClientData.Kan
					CurrentKan -= StolenKan
					if CurrentKan < 0 then
						StolenKan = CurrentKan + StolenKan
					end
					
					DataManager:AddKan(Player, -StolenKan)
					DataManager:AddKan(ExecutorPlayer, StolenKan)
					
					ExecutorProfile.ClientData.Kills += 1
					
					if StatData.Factions[ExecutorProfile.ClientData.Race] == "Arrancar" then
						local MaxHealth = ExecutorProfile.ClientData.MaxHealth
						local ShinigamiRank = ExecutorProfile.ClientData.ShinigamiRank
						local PlayerStats = RankManager:RetrievePlayerStats(ShinigamiRank)
						if MaxHealth < PlayerStats.Health then
							MaxHealth += StatData.HealthRestoreAmount
							if MaxHealth < PlayerStats.Health then
								ExecutorProfile.ClientData.MaxHealth = MaxHealth

								local HealthAmount = ExecutorProfile.ClientData.MaxHealth
								HealthAmount = PlayerBonus:ApplyHealth(ExecutorPlayer, HealthAmount)

								Executor.Humanoid.MaxHealth = HealthAmount
							else
								ExecutorProfile.ClientData.MaxHealth = PlayerStats.Health

								local HealthAmount = PlayerStats.Health
								HealthAmount = PlayerBonus:ApplyHealth(ExecutorPlayer, HealthAmount)

								Executor.Humanoid.MaxHealth = HealthAmount
							end
						end
					elseif StatData.Factions[ExecutorProfile.ClientData.Race] == "Quincy" then
						local MaxHealth = ExecutorProfile.ClientData.MaxHealth
						local PlayerStats = RankManager:RetrievePlayerStats(ExecutorProfile.ClientData.ShinigamiRank)

						if MaxHealth < PlayerStats.Health then
							MaxHealth += StatData.QuincyHealthRestoreAmount
							if MaxHealth < PlayerStats.Health then
								ExecutorProfile.ClientData.MaxHealth = MaxHealth

								local HealthAmount = ExecutorProfile.ClientData.MaxHealth
								HealthAmount = PlayerBonus:ApplyHealth(ExecutorPlayer, HealthAmount)

								Executor.Humanoid.MaxHealth = HealthAmount
							else
								ExecutorProfile.ClientData.MaxHealth = PlayerStats.Health

								local HealthAmount = PlayerStats.Health
								HealthAmount = PlayerBonus:ApplyHealth(ExecutorPlayer, HealthAmount)

								Executor.Humanoid.MaxHealth = HealthAmount
							end
						end

						local MaxReiatsu = ExecutorProfile.ClientData.MaxReiatsu
						if MaxReiatsu < PlayerStats.Reiatsu then
							MaxReiatsu += StatData.QuincyReiatsuRestoreAmount
							if MaxReiatsu < PlayerStats.Reiatsu then
								ExecutorProfile.ClientData.MaxReiatsu = MaxReiatsu

								local SetReiatsu = ExecutorProfile.ClientData.MaxReiatsu
								SetReiatsu = PlayerBonus:ApplyReiatsu(ExecutorPlayer, SetReiatsu)

								Executor:SetAttribute("MaxReiatsu", SetReiatsu)
							else
								ExecutorProfile.ClientData.MaxReiatsu = PlayerStats.Reiatsu

								local SetReiatsu = PlayerStats.Reiatsu
								SetReiatsu = PlayerBonus:ApplyReiatsu(ExecutorPlayer, SetReiatsu)

								Executor:SetAttribute("MaxReiatsu", SetReiatsu)
							end
						end
					elseif StatData.Factions[ExecutorProfile.ClientData.Race] == "Shinigami" then
						if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
							local HollowEssence = DataManager:CheckItemQuantity(ExecutorPlayer, "Hollow Essence")
							if HollowEssence then
								local function RandomInteger(Min, Max)
									local Seed = Random.new():NextNumber(1, 999999)
									local RNG = Random.new(Seed)
									return RNG:NextInteger(Min, Max)
								end

								if RandomInteger(1, 200) <= 1 and ExecutorProfile.ClientData.QuincyMedallion then
									local Removed = DataManager:RemoveItem(ExecutorPlayer, "Hollow Essence", 1)
									if Removed then
										DataManager:AddItem(ExecutorPlayer, "Hollow Candy", 1)

										local WebhookInfo = {
											Message = ExecutorPlayer.Name .. " has upgraded Hollow Essence into Hollow Candy";
										}

										Webhooks:Post(ItemWebhookChannel, WebhookInfo)
									end
								end
							end
						end
					end

					if ExecutorProfile.ClientData.Race == "Visored" then
						if StatData.Factions[Race] == "Shinigami" then
							RankManager:AddVisoredEXP(ExecutorPlayer, "AllianceGrip")
						end
					end
					
					if Profile.ClientData.Title == "Captain of the 4th Division" then
						if ExecutorProfile.ClientData.ZanpakutoWeapon == "Nozarashi" and ExecutorProfile.ClientData.NozarashiMastery == 0 then
							local NozarashiReqs = ExecutorProfile.ClientData.NozarashiReqs
							if NozarashiReqs then
								ExecutorProfile.ClientData.NozarashiReqs.UnohanaGrips += 1
							end
						end
					end
					
					local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
					if StatData.CurrentFactions[CurrentFaction] and ExecutorProfile.ClientData.HollowCandyQuest then
						if not table.find(ExecutorProfile.ClientData.HollowCandyQuest, CurrentFaction) then
							table.insert(ExecutorProfile.ClientData.HollowCandyQuest, CurrentFaction)
							
							local PathData = {Module = ClientProgression, Skill = "HollowCandy"}
							local RenderDistance = 1000
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Executor)
							
							print(Player.Name .. " added to " .. ExecutorPlayer.Name .. " hollow candy quest")
						end
					end
					
					if ExecutorProfile.ClientData.ShinigamiRank <= StatData.SecondaryRankupReqsRank then						
						local RaidActive = FactionManager:IsRaidActive()
						local FactionGrips = {
							Arrancar = {
								Shinigami = true;
								Visored = true;
							};
							Shinigami = {
								Arrancar = true;
								Vastocar = true;
							};
							Quincy = {
								Quincy = true;
							}
						}
						
						local ExecutorFaction = StatData.Factions[ExecutorProfile.ClientData.Race]
						local PlayerFaction = StatData.Factions[Profile.ClientData.Race]
						
						if StatData.CurrentFactions[ExecutorFaction] and StatData.CurrentFactions[PlayerFaction] then
							if ExecutorFaction ~= PlayerFaction then
								ExecutorProfile.ClientData.RankupRequirements.PlayerGrips += 1
								
								if Profile.ClientData.ShinigamiRank <= StatData.BankaiRankRequirement then
									RankManager:AddBankaiStat(ExecutorPlayer, "Players", 1)
								end

								if RaidActive and not FactionManager:IsGrace() then
									ExecutorProfile.ClientData.RankupRequirements.RaidGrips += 1

									if not FactionManager:KarakuraRaidType() and Profile.ClientData.ShinigamiRank <= 4 then
										FactionManager:AddContribution(ExecutorPlayer, StatData.RaidGripContribution, "BypassCap")
									end

									FactionManager:AddKingsGambitMvp(Executor, Character)
									FactionManager:AddKarakuraGrip(ExecutorProfile.ClientData.Race)
								end
								
								if PlayerFaction == "Shinigami" then
									RankManager:AddSchriftProgress(ExecutorPlayer, "Shinigami")
								elseif PlayerFaction == "Arrancar" then
									RankManager:AddSchriftProgress(ExecutorPlayer, "Arrancars")
								end
							end
						end
						
						local TrackedDamage = DamageTracker:RetrieveData(Character).Counter
						local TotalDamage = 0
						for Entity, Damage in pairs(TrackedDamage) do
							TotalDamage += Damage
						end
						for Entity, Damage in pairs(TrackedDamage) do
							local EntityPlayer = Players:GetPlayerFromCharacter(Entity)
							if EntityPlayer then
								local DamagePercent = Damage / TotalDamage
								if DamagePercent == DamagePercent and DamagePercent >= 0.3 then
									local EntityProfile = DataManager:RequestProfile(EntityPlayer)
									if FactionGrips.Shinigami[EntityProfile.ClientData.Race] then
										if FactionGrips.Arrancar[Profile.ClientData.Race] then
											EntityProfile.ClientData.RankupRequirements.PlayerGrips += 0.3
											
											if RaidActive and not FactionManager:IsGrace() then
												EntityProfile.ClientData.RankupRequirements.RaidGrips += 0.3
											end
										end
									elseif FactionGrips.Arrancar[EntityProfile.ClientData.Race] then
										if FactionGrips.Shinigami[Profile.ClientData.Race] then
											EntityProfile.ClientData.RankupRequirements.PlayerGrips += 0.3
											
											if RaidActive and not FactionManager:IsGrace() then
												EntityProfile.ClientData.RankupRequirements.RaidGrips += 0.3
											end
										end
									end
								end
							end
						end
					end
					
					local PathData = {Module = ClientProgression, Skill = "DeathScreen"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, ExecutorPlayer)
				end		
				
				local BankaiDurationFulfilled = Profile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration
				if not Profile.ClientData.BankaiUnlocked and not Profile.ClientData.BankaiRequirements.BankaiReady and BankaiDurationFulfilled and Character:GetAttribute("CombatTag") > 0 then
					local ReqsBeforeDeath = DeepCopyTable(Profile.ClientData.BankaiRequirements)
					local Hollows = ReqsBeforeDeath.Hollows
					local Players = ReqsBeforeDeath.Players
					local WorldBosses = ReqsBeforeDeath.WorldBosses
					
					Profile.ClientData.BankaiRequirements = {
						BankaiReady = ReqsBeforeDeath.BankaiReady;
						BankaiFight = ReqsBeforeDeath.BankaiFight;
						BankaiSwordTimer = ReqsBeforeDeath.BankaiSwordTimer;
						RankDuration = ReqsBeforeDeath.RankDuration;
						Hollows = 0;
						Players = 0;
						WorldBosses = 0;
					}
										
					local WebhookInfo = {
						Message = "1_" .. Hollows .. "\n2_" .. Players .. "\n3_" .. WorldBosses;
						Title = Player.Name .. " " .. Player.UserId
					}
					
					if Executor then
						WebhookInfo.Title = Player.Name .. " " .. Player.UserId .. " died to " .. Executor.Name
					end
					
					Webhooks:Post(BankaiPatrolChannel, WebhookInfo)
				end
			end
			
			if Executor then
				local ExecutorRace = Executor:GetAttribute("EntityType")
				if ExecutorRace then
					local HollowTypes = {
						Adjuchas = true;
						Menos = true;
						Fishbone = true;
						Frisker = true;
					}	

					if HollowRace[ExecutorRace] then
						ExecutorRace = "Hollow"
					elseif ExecutorRace == "Visored" then
						ExecutorRace = "Shinigami"
					elseif HollowTypes[ExecutorRace] then
						ExecutorRace = "Hollow"
					end

					local Profile = DataManager:RequestProfile(Player)
					Profile.ClientData.VengefulRace = ExecutorRace
					Profile.ClientData.VengefulTimer = DateTime.now().UnixTimestamp
				end
				
				if not Executor:GetAttribute("VastoLordeQuest") and not Character:GetAttribute("DeathBypass") then
					Profile.ClientData.Deaths += 1	
					
					local PlayerKDA = SharedFunctions:RoundNumber(Profile.ClientData.Kills / Profile.ClientData.Deaths, 1)
					
					local GripLogChannel = "GripLogs"
					local WebhookInfo = {
						Message = Player.Name .. " died to " .. Executor.Name .. "\n" .. Player.Name .. " K/D: " .. PlayerKDA;
					}
					
					if ExecutorPlayer then
						local ExecutorProfile = DataManager:RequestProfile(ExecutorPlayer)
						local ExecutorKDA = SharedFunctions:RoundNumber(ExecutorProfile.ClientData.Kills / ExecutorProfile.ClientData.Deaths, 1)
						WebhookInfo.Message = WebhookInfo.Message .. "\n" .. ExecutorPlayer.Name .. " K/D: " .. ExecutorKDA
						
						Webhooks:Post(GripLogChannel, WebhookInfo)
					end
				end
			end
			
			FactionManager:DropCaptureItem(Player, "DropBypass")
			FactionManager:DropKarakuraFlag(Player, "DropBypass")
			
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
				
				Character.PrimaryPart:Destroy()
				Character:BreakJoints()
				Character.Humanoid.Health = -5
			end
		end,
	},
	Unconscious = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TakeDamage = function(StateMachine, Character, ...)
			DamageTaken(Character, ...)
		end,
		TriggerDying = function(StateMachine, Character)
			--PlayerData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			
			local Overtimes = CombatManager:GetOvertimes(Character)
			if Overtimes then
				local TrueBurn = CombatManager:GetOvertimes(Character).TrueBurn
				if TrueBurn then
					CombatManager:CancelOvertime(Character, "TrueBurn")
				end
			end
			
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end
			
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false
			
			StateMachine:SetState("Dying")
		end,
		TriggerKnockout = function(StateMachine, Character, AttackOwner)
			--PlayerData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			
			local Player = Players:GetPlayerFromCharacter(Character)
			FactionManager:DropCaptureItem(Player, "DropBypass")
			FactionManager:DropKarakuraFlag(Player, "DropBypass")
			
			if PlayerData[Character.Name].Carrying then
				local CarriedPlayer = Players:GetPlayerFromCharacter(PlayerData[Character.Name].Carrying)
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				EntityManager:ChangeState(PlayerData[Character.Name].Carrying, "ReleaseCarried")
				
				for Index, Part in ipairs(PlayerData[Character.Name].Carrying:GetChildren()) do
					if Part:IsA'BasePart' then
						if PlayerData[Character.Name].CarriedPlayerMass and PlayerData[Character.Name].CarriedPlayerMass[Part] then
							Part.Massless = PlayerData[Character.Name].CarriedPlayerMass[Part]
							PlayerData[Character.Name].CarriedPlayerMass[Part] = nil
						else
							Part.Massless = false
						end
						Part.CollisionGroup = "Entity"

						if CarriedPlayer and Part:CanSetNetworkOwnership() then
							Part:SetNetworkOwner(CarriedPlayer)
						end
					end
				end
				PlayerData[Character.Name].CarriedPlayerMass = nil
				if CarriedPlayer then
					AntiCheatManager:Teleport(CarriedPlayer, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3.5))
				end
				
				SharedFunctions:CancelAnimation(PlayerData[Character.Name].Carrying.Humanoid, "Carried")
				PlayerData[Character.Name].Carrying:SetAttribute("Carried", nil)
				PlayerData[Character.Name].Carrying:SetAttribute("IFrames", false)				
				
				Ragdoll:Enable(PlayerData[Character.Name].Carrying)
				PlayerData[Character.Name].Carrying = nil
				Character:SetAttribute("Carrying", nil)

				local CarryWeld = Character:FindFirstChild("CarryWeld")
				if CarryWeld then
					CarryWeld:Destroy()
					CarryWeld = nil
				end

				SharedFunctions:CancelAnimation(Character.Humanoid, "Carrying")

				if PlayerData[Character.Name].CarriedLeaving then
					PlayerData[Character.Name].CarriedLeaving:Disconnect()
					PlayerData[Character.Name].CarriedLeaving = nil
				end

				if PlayerData[Character.Name].CarryConnection then
					PlayerData[Character.Name].CarryConnection:Disconnect()
					PlayerData[Character.Name].CarryConnection = nil
				end
				
				if PlayerData[Character.Name].CarryOwnerLeave then
					PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
					PlayerData[Character.Name].CarryOwnerLeave = nil
				end
			end
			
			
			if PlayerData[Character.Name].BankaiActiveData and PlayerData[Character.Name].BankaiActiveData.MiraclePassive and not Character:GetAttribute("Reviving") then
				Character:SetAttribute("Carried", true)
				Character:SetAttribute("IFrames", true)
				Character:SetAttribute("GripBypass", true)
				Character:SetAttribute("Reviving", true)
				
				local BankaiMeter = Character:GetAttribute("BankaiMeter")
				BankaiMeter -= PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Meter
				if BankaiMeter < 0 then
					BankaiMeter = 0
				end
				
				Character:SetAttribute("BankaiMeter", BankaiMeter)
				
				Ragdoll:Enable(Character)

				for i, v in pairs(PlayerData[Character.Name].Connections) do
					if PlayerData[Character.Name].DisconnectFunctions[i] then
						PlayerData[Character.Name].DisconnectFunctions[i]()
						PlayerData[Character.Name].DisconnectFunctions[i] = nil
					end
					PlayerData[Character.Name].Connections[i]:Disconnect()
					PlayerData[Character.Name].Connections[i] = nil
				end
				if PlayerData[Character.Name].HighSpeedConnection then
					local StopPathData = {Module = ClientSkills, Skill = "HighSpeedStop"}
					NetworkManager.FireAllClients(Character, "ClientEffects", -1, StopPathData)

					PlayerData[Character.Name].HighSpeedConnection:Disconnect()
					PlayerData[Character.Name].HighSpeedConnection = nil
				end
				
				local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
				if PlayerAttacker then
					--[[PlayerData[Character.Name].KnockoutDisconnect = PlayerAttacker.CharacterRemoving:Connect(function()
						local Health = Character.Humanoid.Health
						Health += Character.Humanoid.MaxHealth * PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Health
						if Health < Character.Humanoid.MaxHealth then
							Character.Humanoid.Health = Health
						else
							Character.Humanoid.Health = Character.Humanoid.MaxHealth
						end
						
						Character:SetAttribute("Carried", false)
						Character:SetAttribute("IFrames", false)
						Character:SetAttribute("GripBypass", nil)

						StateMachine:Trigger("Wakeup", StateMachine, Character)
					end)]]
				end
				
				local MiracleDamage = Character:GetAttribute("MiracleDamage") or 0
				local MiracleDefense = Character:GetAttribute("MiracleDefense") or 1
				MiracleDamage += PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Damage
				MiracleDefense -= PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Defense
				
				Character:SetAttribute("MiracleDamage", MiracleDamage)
				Character:SetAttribute("MiracleDefense", MiracleDefense)
				
				local MiracleBuffFx = ReplicatedStorage.Assets.Effects.Vollstandig.Miracle.MiracleBuff.MiracleBuff:Clone()
				MiracleBuffFx.Parent = Character.HumanoidRootPart
				
				local Profile = DataManager:RequestProfile(Player)
				local EyeColor = {(Profile.ClientData.EyeColor[1] * 2) / 10, (Profile.ClientData.EyeColor[2] * 2) / 10, (Profile.ClientData.EyeColor[3] * 2) / 10}
				
				local ClientMiracleVollstandig = ReplicatedStorage.Modules.ClientModules.Vollstandig.ClientMiracleVollstandig
				local PathData = {Module = ClientMiracleVollstandig, Skill = "Revive"}
				NetworkManager.FireAllClients(Character, "ClientEffects", 1000, PathData, PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Duration, EyeColor)
				
				local Rate = 1 * 0.1
				local HealthPercent = PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Health / (PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Duration / Rate)
				
				local Duration = PlayerData[Character.Name].BankaiActiveData.MiraclePassive.Duration
				local Accumulated = 0
				
				while true do
					local Step = task.wait(0.05)
					if Character.Humanoid.Health <= 0 or Character:GetAttribute("CurrentState") ~= "Unconscious" then
						return
					end

					Accumulated += Step
					if Accumulated > Rate then
						Accumulated -= Rate
						Duration -= Rate

						local Health = Character.Humanoid.Health
						Health += Character.Humanoid.MaxHealth * HealthPercent
						if Health < Character.Humanoid.MaxHealth then
							Character.Humanoid.Health = Health
						else
							Character.Humanoid.Health = Character.Humanoid.MaxHealth
						end

						if Duration <= 0 then
							Character:SetAttribute("Carried", false)
							Character:SetAttribute("IFrames", false)
							Character:SetAttribute("GripBypass", nil)
							Character:SetAttribute("Reviving", nil)
							StateMachine:Trigger("Wakeup", StateMachine, Character, "NoHealth")
							break
						end
					end
				end
				
				return
			end
			
			if PlayerData[Character.Name].DeathdealingTimer and Character:GetAttribute("ZanpakutoState") >= 2 then
				local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].DeathdealingTimer
				if TimeDifference >= SpecData.Deathdealing.DeathDosage.Cooldown * 1000 then	
					PlayerData[Character.Name].DeathdealingTimer = DateTime.now().UnixTimestampMillis
					
					if Character.Humanoid.Health + Character.Humanoid.MaxHealth * SpecData.Deathdealing.DeathDosage.Health < Character.Humanoid.MaxHealth then
						Character.Humanoid.Health += Character.Humanoid.MaxHealth * SpecData.Deathdealing.DeathDosage.Health
					else
						Character.Humanoid.Health = Character.Humanoid.MaxHealth
					end
					
					StateMachine:Trigger("Wakeup", StateMachine, Character, "NoHealth")

					local ClientDeathdealingVollstandig = ReplicatedStorage.Modules.ClientModules.Vollstandig.ClientDeathdealingVollstandig
					local PathData = {Module = ClientDeathdealingVollstandig, Skill = "DeathDosage"}
					local RenderDistance = 1000

					local SpawnPoint = Character.HumanoidRootPart.CFrame
					local Detection = HitDetection:Magnitude(Character, SpawnPoint.Position, SpecData.Deathdealing.DeathDosage.Properties.Range)
					if Detection then
						local PositiveHits = CombatManager:ApplyDamage(Character, Detection, SpecData.Deathdealing.DeathDosage)
						if PositiveHits and #PositiveHits > 0 then
							local ClientDeathdealingVollstandig = ReplicatedStorage.Modules.ClientModules.Vollstandig.ClientDeathdealingVollstandig
							local ClientPath = {Module = ClientDeathdealingVollstandig, Skill = "DeathdealingUI"}
							local PathData = {Module = ClientDeathdealingVollstandig, Skill = "LethalDosage"}
							local RenderDistance = 1000

							for i, v in ipairs(PositiveHits) do
								if v:GetAttribute("Schrift") ~= "Balance" then
									local LethalDosage = v:GetAttribute(SpecData.Deathdealing.LethalDosage.Name) or 0
									LethalDosage += SpecData.Deathdealing.DeathDosage.LethalDosage

									if LethalDosage >= SpecData.Deathdealing.LethalDosage.LethalDose then
										LethalDosage = 0

										EntityManager:ChangeState(v, "TriggerUnconscious")

										NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, v)
									end

									v:SetAttribute(SpecData.Deathdealing.LethalDosage.Name, LethalDosage)

									if Player then
										NetworkManager.FireClient(Player, Character, "ClientEffects", -1, ClientPath, v, SpecData.Deathdealing.LethalDosage.LethalDose)
									end
								end

								KnockbackModule:Repel(Character, SpawnPoint.Position, v, 65)
								Ragdoll:Enable(v)
								task.delay(SpecData.Deathdealing.DeathDosage.TrueStunTime, function()
									Ragdoll:Disable(v, "UnconsciousCheck")
								end)
							end
						end
					end

					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, SpawnPoint)
					return
				end
			end
			
			if Character:GetAttribute("StarrkAwaken") then
				StateMachine:Trigger("StarrkAwaken", StateMachine, Character, AttackOwner)
			else
				StateMachine:Trigger("Knockout", StateMachine, Character, AttackOwner)
			end
		end,
		StarrkAwaken = function(StateMachine, Character, AttackOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			Profile.ClientData.Shikai = "Starrk"
			
			Character:SetAttribute("Carried", true)
			Character:SetAttribute("IFrames", true)
			Character:SetAttribute("GripBypass", true)
			
			StateMachine:Trigger("CancelBankai", StateMachine, Character)
			StateMachine:Trigger("CancelShikai", StateMachine, Character)
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			if PlayerData[Character.Name].HighSpeedConnection then
				local StopPathData = {Module = ClientSkills, Skill = "HighSpeedStop"}
				NetworkManager.FireAllClients(Character, "ClientEffects", -1, StopPathData)

				PlayerData[Character.Name].HighSpeedConnection:Disconnect()
				PlayerData[Character.Name].HighSpeedConnection = nil
			end

			if not PlayerData[Character.Name].HealthpackTimer then
				PlayerData[Character.Name].HealthpackTimer = 0
			end
			if PlayerData[Character.Name] and PlayerData[Character.Name].HealthpackTimer then
				local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].HealthpackTimer
				if TimeDifference >= StatData.HealthpackCD * 995 then
					PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
					PassivesManager:Healthpack(Character, DamageTracker:RetrieveData(Character).Counter, StatData.ReiatsuPack)
				end
			end

			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end

			Character:SetAttribute("ResetDeath", nil)
			Ragdoll:Disable(Character)
			PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
			DamageTracker:Reset(Character)
			
			local Transparency = {}
			local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
			if Weapon then
				for i, v in ipairs(Weapon:GetDescendants()) do
					if v:IsA("BasePart") then
						Transparency[v] = v.Transparency
						v:SetAttribute("TrueTransparency", v.Transparency)
						v.Transparency = 1
					end
				end
			end
			
			task.delay(6.4, function()
				if Weapon then
					for i, v in ipairs(Weapon:GetDescendants()) do
						if v:IsA("BasePart") then
							v.Transparency = Transparency[v]
							Transparency[v] = nil
							v:SetAttribute("TrueTransparency", nil)
						end
					end
				end
				Transparency = nil
			end)
			
			local WeaponModel = ServerStorage.Assets.BaseWeapons.Starrk.Zanpakuto:Clone()
			WeaponModel.Name = "StarrkGuns"
			WeaponModel.Parent = Character["Right Arm"]
			Debris:AddItem(WeaponModel, 6.4)

			local Motor6D = Instance.new("Motor6D")
			Motor6D.C0 = WeaponData.StarrkAttackData.GripData
			Motor6D.Part0 = Character["Right Arm"]
			Motor6D.Part1 = WeaponModel.PrimaryPart
			Motor6D.Name = "CeroHandle1"
			Motor6D.Parent = Character["Right Arm"]
			Debris:AddItem(Motor6D, 6.4)

			local DualHandle =  WeaponModel:GetAttribute("DualHandle")
			if DualHandle then		
				local DualMotor6D = Instance.new("Motor6D")
				DualMotor6D.C0 = WeaponData.StarrkAttackData.Grip2Data
				DualMotor6D.Part0 = Character["Left Arm"]
				DualMotor6D.Part1 = WeaponModel[DualHandle].PrimaryPart
				DualMotor6D.Name = "CeroHandle2"
				DualMotor6D.Parent = Character["Left Arm"]
				Debris:AddItem(DualMotor6D, 6.4)
			end
			
			local PathData = {Module = ClientProgression, Skill = "StarrkAwaken"}			
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)
			
			local StarrkCutscene = Character.Humanoid.Animator:LoadAnimation(Animations.StarrkCutscene)
			StarrkCutscene:Play()
			StarrkCutscene.KeyframeReached:Connect(function(KeyframeName)
				if KeyframeName == "GunJammed" then
					local GunJamSound = Sounds.StarrkGunJam:Clone()
					GunJamSound.PlayOnRemove = true
					GunJamSound.Parent = workspace.Effects
					GunJamSound:Destroy()
					GunJamSound = nil
				end
			end)
			
			local StunData = {
				NoHitEffect = true;
				TrueStunTime = 10;
				SoftStunTime = 0;
			}

			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)		
			
			task.delay(6.4, function()
				local AwakenSound = ReplicatedStorage.Assets.ResSounds.Starrk.Awaken:Clone()
				AwakenSound.Volume = 2
				AwakenSound.Parent = workspace.Effects[Character.Name]
				AwakenSound:Play()
				Debris:AddItem(AwakenSound, 33)
				
				Character:SetAttribute("Carried", false)
				Character:SetAttribute("IFrames", false)
				Character:SetAttribute("GripBypass", nil)
				
				task.delay(2, function()
					StateMachine:Trigger("TriggerBankaiObtained", StateMachine, Character)
				end)
			end)
		end,
		TriggerUnconscious = function(StateMachine, Character, ...)
			StateMachine:Trigger("Knockout", StateMachine, Character, ...)
		end,
		Knockout = function(StateMachine, Character, AttackOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			if not FactionManager:IsGrace() and not FactionManager:IsHuntActive() then
				if FactionManager:GladiatorActive() then
					PassivesManager:Healthpack(Character, DamageTracker:RetrieveData(Character).Counter, StatData.ReiatsuPack, nil, StatData.GladiatorHealthpackCap)

					Ragdoll:Enable(Character)
					Character:SetAttribute("GripBypass", true)
					Character:SetAttribute("Carried", true)
					Character:SetAttribute("Death", true)
					Character:SetAttribute("IFrames", true)
					StateMachine:SetState("Dying")

					task.delay(1, function()
						StateMachine:SetState("Dying")
						StateMachine:Trigger("TriggerDeath", StateMachine, Character, AttackOwner)
					end)
					return
				end
			end
			
			StateMachine:Trigger("CancelBankai", StateMachine, Character)
			StateMachine:Trigger("CancelShikai", StateMachine, Character)
			--StateMachine:Trigger("CancelZombification", StateMachine, Character)
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			if PlayerData[Character.Name].HighSpeedConnection then
				local StopPathData = {Module = ClientSkills, Skill = "HighSpeedStop"}
				NetworkManager.FireAllClients(Character, "ClientEffects", -1, StopPathData)

				PlayerData[Character.Name].HighSpeedConnection:Disconnect()
				PlayerData[Character.Name].HighSpeedConnection = nil
			end
			
			if not PlayerData[Character.Name].HealthpackTimer then
				PlayerData[Character.Name].HealthpackTimer = 0
			end

			local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
			if PlayerAttacker then
				--[[PlayerData[Character.Name].KnockoutDisconnect = PlayerAttacker.CharacterRemoving:Connect(function()
					if PlayerData[Character.Name].KnockoutDisconnect then
						PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
						PlayerData[Character.Name].KnockoutDisconnect = nil
					end
					if PlayerData[Character.Name].KnockoutThread then
						task.cancel(PlayerData[Character.Name].KnockoutThread)
						PlayerData[Character.Name].KnockoutThread = nil
					end

					StateMachine:Trigger("Wakeup", StateMachine, Character)
				end)]]
			end

			local TimeUntilReset = StatData.TimeUntilRaidReset

			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
				PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
			else
				Character:SetAttribute("ResetDeath", DateTime.now().UnixTimestamp)
				Ragdoll:Enable(Character)
				
				if PlayerData[Character.Name] and PlayerData[Character.Name].HealthpackTimer then
					local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].HealthpackTimer
					if TimeDifference >= StatData.HealthpackCD * 995 then
						PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
						PassivesManager:Healthpack(Character, DamageTracker:RetrieveData(Character).Counter, StatData.ReiatsuPack)
					end
				end
				
				if Character:GetAttribute("CatState") then
					local CatState = false
					Character:SetAttribute("CatState", CatState)

					for i, v in ipairs(Character:GetDescendants()) do
						if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
							if PlayerData.CatTracker[v] then
								PlayerData.CatTracker[v] = nil
								v.Transparency = 0
							end
						end
					end

					for _, v in ipairs(workspace.Effects[Character.Name][Character.Name .. "Head"]:GetChildren()) do
						if v:IsA("Decal") then
							v.Transparency = CatState and 1 or 0
						end
					end

					Character.YoruichiCat:Destroy()

					NetworkManager.FireAllClients(Character, "ClientEffects", 1000, {Module = ClientSkills, Skill = "Cat"})
				end
			end

			PlayerData[Character.Name].KnockoutThread = task.delay(StatData.KnockoutDuration, function()
				PlayerData[Character.Name].KnockoutThread = nil
				Character:SetAttribute("ResetDeath", nil)
				StateMachine:Trigger("Wakeup", StateMachine, Character)
			end)
		end,
		Wakeup = function(StateMachine, Character, NoHealth)
			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end

			Character:SetAttribute("ResetDeath", nil)
			Ragdoll:Disable(Character)
			PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
			DamageTracker:Reset(Character)
			
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			
			if not NoHealth then
				if Character.Humanoid.Health + Character.Humanoid.MaxHealth * 0.1 < Character.Humanoid.MaxHealth then
					Character.Humanoid.Health += Character.Humanoid.MaxHealth * 0.1
				else
					Character.Humanoid.Health = Character.Humanoid.MaxHealth
				end
			end
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
		end,
		ReleaseCarried = function(StateMachine, Character)
			PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
			
			if PlayerData[Character.Name].CarryOwnerLeave and PlayerData[Character.Name].CarryOwnerLeave.Connected then
				PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
				PlayerData[Character.Name].CarryOwnerLeave = nil
			end
			if PlayerData[Character.Name].CarryOwnerDied and PlayerData[Character.Name].CarryOwnerDied.Connected then
				PlayerData[Character.Name].CarryOwnerDied:Disconnect()
				PlayerData[Character.Name].CarryOwnerDied = nil	
			end
			
			local Player = Players:GetPlayerFromCharacter(Character)
			AntiCheatManager:DisableFlight(Player)
			
			local Player = Players:GetPlayerFromCharacter(Character)								
			for Index, Part in ipairs(Character:GetChildren()) do
				if Part:IsA'BasePart' then
					Part.CollisionGroup = "Entity"
	
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
			--PlayerData[Character.Name].KnockoutTime = DateTime.now().UnixTimestampMillis
			Character:SetAttribute("Carried", nil)
			Character:SetAttribute("IFrames", false)

			StateMachine:SetState("Unconscious")
			StateMachine:Trigger("Knockout", StateMachine, Character)
		end,
		TriggerCarried = function(StateMachine, Character, CarryOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			
			Character:SetAttribute("Carried", CarryOwner.Name)
			Character:SetAttribute("IFrames", true)
			AntiCheatManager:EnableFlight(Player)

			local Carried = Animations.Carried
			local CarriedAnimation = Character.Humanoid.Animator:LoadAnimation(Carried)
			CarriedAnimation:Play()
			
			local Overtimes = CombatManager:GetOvertimes(Player)
			if Overtimes then
				local TrueBurn = CombatManager:GetOvertimes(Player).TrueBurn
				if TrueBurn then
					CombatManager:CancelOvertime(Character, "TrueBurn")
				end
			end
			
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end
			
			local PlayerCarrier = Players:GetPlayerFromCharacter(CarryOwner)
			if PlayerCarrier then
				PlayerData[Character.Name].CarryOwnerLeave = PlayerCarrier.CharacterRemoving:Connect(function()
					StateMachine:Trigger("ReleaseCarried", StateMachine, Character)
					if PlayerData[Character.Name].CarryOwnerLeave and PlayerData[Character.Name].CarryOwnerLeave.Connected then
						PlayerData[Character.Name].CarryOwnerLeave:Disconnect()
						PlayerData[Character.Name].CarryOwnerLeave = nil
					end
				end)

				PlayerData[Character.Name].CarryOwnerDied = CarryOwner.Humanoid.Died:Connect(function()
					StateMachine:Trigger("ReleaseCarried", StateMachine, Character)
					if PlayerData[Character.Name].CarryOwnerDied and PlayerData[Character.Name].CarryOwnerDied.Connected then
						PlayerData[Character.Name].CarryOwnerDied:Disconnect()
						PlayerData[Character.Name].CarryOwnerDied = nil	
					end
				end)
			end
		end,
		CancelZombification = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			if Character:GetAttribute("Zombification") then
				if PlayerData[Character.Name].ZombieConnection then
					PlayerData[Character.Name].ZombieConnection:Disconnect()
					PlayerData[Character.Name].ZombieConnection = nil
				end
				if PlayerData[Character.Name].ZombieCharacterRemoving then
					PlayerData[Character.Name].ZombieCharacterRemoving:Disconnect()
					PlayerData[Character.Name].ZombieCharacterRemoving = nil
				end

				ReplicatedStorage.Remotes.PlayerControlEvent:FireClient(Player, "Enabled")

				Character:SetAttribute("Zombification", nil)
				Character:SetAttribute("ZombieOwner", nil)
				Character:SetAttribute("SkillRange", nil)
				Character:SetAttribute("ShikaiCD", nil)
				Character:SetAttribute("SkillCD", nil)

				local AlignOrientation = Character.HumanoidRootPart:FindFirstChild("AlignOrientation")
				if AlignOrientation then
					AlignOrientation:Destroy()
					AlignOrientation = nil
				end
			end
		end,
		CancelBankai = function(StateMachine, Character)
			if Character:GetAttribute("ZanpakutoState") >= 2 then
				local Player = Players:GetPlayerFromCharacter(Character)
				local Profile = DataManager:RequestProfile(Player)
				local ClientData = Profile.ClientData
				if StatData.Factions[ClientData.Race] == "Arrancar" then
					Character:SetAttribute("ZanpakutoState", 0)
				elseif StatData.Factions[ClientData.Race] == "Shinigami" then
					Character:SetAttribute("ZanpakutoState", 1)
				elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					Character:SetAttribute("ZanpakutoState", 0)
				end
			end
		end,
		CancelShikai = function(StateMachine, Character)
			task.wait(0.1)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			if Character:GetAttribute("ZanpakutoState") == 1 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
				Character:SetAttribute("ZanpakutoState", 0)
				
				if PlayerData[Character.Name].WeaponEquipped ~= "KatanaShikai" then
					local ShikaiModel = Character["Right Arm"]:FindFirstChildOfClass("Model")
					ShikaiModel:Destroy()
					ShikaiModel = nil

					PlayerData[Character.Name].WeaponEquipped = Profile.ClientData.ZanpakutoWeapon
					local WeaponModel = ServerStorage.LiveAssets[Character.Name].Zanpakuto
					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")

					WeaponModel.PrimaryPart.Weld.Enabled = false
					WeaponModel.Parent = Character["Right Arm"]

					local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
					Motor6D.Part1 = WeaponModel.PrimaryPart
					Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData

					local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

					if ZanpakutoData and ZanpakutoData.DoubleHandle then
						local DualMotor6D = Character["Left Arm"].DualHandle2
						DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
						DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data
					end
				else
					local ZanpakutoModel = Character["Right Arm"].Zanpakuto
					ZanpakutoModel.Handle[Profile.ClientData.WeaponModel]:Destroy()
					ZanpakutoModel.PrimaryPart.Blades.Blade.Transparency = 0
					ZanpakutoModel.PrimaryPart.Blades.BaseWeaponAura.Name = "WeaponAura"
					ZanpakutoModel.PrimaryPart.Trail:Destroy()
					ZanpakutoModel.PrimaryPart.BaseTrail.Name = "Trail"
				end
				
				local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon

				local WeaponName = PlayerData[Character.Name].WeaponEquipped
				SharedFunctions:CancelAnimation(Character.Humanoid, "Idle", true)

				local Idle = "Idle"..math.random(1, 3)
				if WeaponName == "Fist" then
					Idle = "Idle1"
				end

				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName][Idle])
					IdleAnimation:Play()
				end
				
				if PlayerData[Character.Name].ShikaiActiveData then
					if PlayerData[Character.Name].ShikaiActiveData.Connections then
						for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
							if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
								PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
								PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
							end

							PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
							PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
						end
					end
					PlayerData[Character.Name].ShikaiActiveData = nil
				end
			end
		end,
		TriggerBoneKing = function(StateMachine, Character)
			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end

			Ragdoll:Disable(Character)
			DamageTracker:Reset(Character)
			StateMachine:SetState("BoneKing")
			StateMachine:Trigger("BoneKingStart", StateMachine, Character)
		end,
		TriggerExecution = function(StateMachine, Character)
			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end
			
			Ragdoll:Disable(Character)
			DamageTracker:Reset(Character)
			StateMachine:SetState("Execution")
			StateMachine:Trigger("Executed", StateMachine, Character)
		end,
		TriggerZombification = function(StateMachine, Character, Executor, Duration, ReleaseBankai)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
			
			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end
			
			Character:SetAttribute("ResetDeath", nil)
			Ragdoll:Disable(Character)
			PlayerData[Character.Name].HealthpackTimer = DateTime.now().UnixTimestampMillis
			DamageTracker:Reset(Character)

			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true

			Character.Humanoid.Health = Character.Humanoid.MaxHealth
			Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
			
			local Color = Color3.fromRGB(113, 94, 94)
			local BodyColors = Character:FindFirstChild("Body Colors")
			if BodyColors then
				BodyColors.HeadColor3 = Color
				BodyColors.LeftArmColor3 = Color
				BodyColors.LeftLegColor3 = Color
				BodyColors.RightArmColor3 = Color
				BodyColors.RightLegColor3 = Color
				BodyColors.TorsoColor3 = Color
			end
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
				StateMachine:Trigger("UnsheatheWeapon", StateMachine, Character, Profile.ClientData)
			end
			
			if CurrentFaction == "Shinigami" or CurrentFaction == "Arrancar" then
				if ReleaseBankai and Profile.ClientData.BankaiUnlocked then
					Character:SetAttribute("ZanpakutoState", 2)
					Character:SetAttribute("ShikaiCD", false)

					PlayerData[Character.Name].SkipBankaiRelease = true

					local ShikaiModule
					if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						ShikaiModule = require(ServerStorage.Modules.SkillModules.Shikais[Profile.ClientData.Shikai .. "Shikai"])
						PlayerData[Character.Name].ShikaiModule = ShikaiModule
						ShikaiModule:ReleaseShikai(Character, StateMachine, Profile.ClientData, PlayerData[Character.Name])
					elseif StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
						ShikaiModule = require(ServerStorage.Modules.SkillModules.Res[Profile.ClientData.Shikai .. "Res"])
						PlayerData[Character.Name].ShikaiModule = ShikaiModule
					end

					local BankaiWeapon = ShikaiModule:ReleaseBankai(Character, StateMachine, Profile.ClientData, PlayerData[Character.Name])
					if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						BankaiWeapon = BankaiWeapons:InstantBankaiWeaponRelease(Character, StateMachine, Profile.ClientData, PlayerData[Character.Name])
					end

					PlayerData[Character.Name].WeaponEquipped = BankaiWeapon
					PlayerData[Character.Name].SkipBankaiRelease = nil

					local WeaponName = BankaiWeapon
					local IdleNum = 1
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName]["Idle"..IdleNum])
					if StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[WeaponName].Bankai["Idle"..IdleNum])
					end
					IdleAnimation:Play()

					Character:SetAttribute("Combo", 1)
					Character:SetAttribute("BaseWalkspeed", StatData.WalkSpeeds.Bankai)
				elseif Profile.ClientData.ShikaiUnlocked and CurrentFaction == "Shinigami" then
					StateMachine:Trigger("TriggerShikaiRelease", StateMachine, Character, Profile.ClientData)
				end
			end
			
			local PlayerExecutor = Players:GetPlayerFromCharacter(Executor)
			if PlayerExecutor then
				PlayerData[Character.Name].ZombieCharacterRemoving = PlayerExecutor.CharacterRemoving:Connect(function()
					PlayerData[Character.Name].ZombieCharacterRemoving:Disconnect()
					PlayerData[Character.Name].ZombieCharacterRemoving = nil
					
					StateMachine:SetState("Dying")
					StateMachine:Trigger("TriggerDeath", StateMachine, Character, Executor)
				end)
			end
			
			StateMachine:SetState("Action")
			StateMachine:Trigger("Zombification", StateMachine, Character, Executor)
			
			local Highlight = Instance.new("Highlight")
			Highlight.Name = "ZombieHighlight"
			Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			Highlight.OutlineTransparency = 0
			Highlight.FillTransparency = 1
			Highlight.OutlineColor = Color3.fromRGB(255, 178, 172)
			Highlight.Parent = Character
			
			if Duration then
				local ClientFireModule = ReplicatedStorage.Modules.ClientModules.Shikais.ClientFireShikai
				local PathData = {Module = ClientFireModule, Skill = "FlameZombie"}
				local DeathPath = {Module = ClientFireModule, Skill = "FlameDeath"}
				local RenderDistance = -1
				NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, Duration)
				
				Character:SetAttribute("FireZombie", true)
						
				task.delay(Duration, function()
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, DeathPath)
					
					StateMachine:SetState("Dying")
					StateMachine:Trigger("TriggerDeath", StateMachine, Character, Executor)
				end)
			else
				if PlayerExecutor and PlayerExecutor.UserId == 300780145 then
					task.delay(60 * 5, function()
						StateMachine:SetState("Dying")
						StateMachine:Trigger("TriggerDeath", StateMachine, Character, Executor)
					end)
				else
					task.delay(SpecData.Giselle.ZombieDuration, function()
						StateMachine:SetState("Dying")
						StateMachine:Trigger("TriggerDeath", StateMachine, Character, Executor)
					end)
				end
			end
		end,
	},
	BoneKing = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TakeDamage = function(StateMachine, Character, AttackData, AttackOwner)
			local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			if PlayerAttacker then
				local AttackerProfile = DataManager:RequestProfile(PlayerAttacker)

				local Damage = AttackData.Damage
				if AttackData.OriginalDamage then
					Damage = AttackData.OriginalDamage
				end

				local HealthSaveAmount = 20000
				if StatData.Factions[Profile.ClientData.Race] == StatData.Factions[AttackerProfile.ClientData.Race] then
					Damage = 0
				end
				if Damage > 100 then
					Damage = 100
				end

				local Health = workspace.BoneSpec:GetAttribute("Health")
				Health -= Damage
				workspace.BoneSpec:SetAttribute("Health", Health)
			end

			local UnconsciousAttackData = {
				Damage = 0;
				ImpactSound = AttackData.ImpactSound;
				NoHitEffect = AttackData.NoHitEffect;
				HitEffect = AttackData.HitEffect;
			}
			
			Character.Humanoid.Health = Character.Humanoid.MaxHealth

			DamageTaken(Character, UnconsciousAttackData, AttackOwner)
		end,
		BoneKingStart = function(StateMachine, Character, RaidMusic, MusicConnection)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)

			Character:SetAttribute("Execution", true)
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false
			
			local Hitbox = Instance.new("Part")
			Hitbox.Name = "BoneKingHitbox"
			Hitbox.BrickColor = BrickColor.new("Crimson")
			Hitbox.Material = Enum.Material.Neon
			Hitbox.CanCollide = false
			Hitbox.Transparency = 1
			Hitbox.Anchored = true
			Hitbox.Size = Vector3.new(46, 46, 46)
			Hitbox.Parent = Character
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = Hitbox
			Weld.Part1 = Character.HumanoidRootPart
			Weld.Parent = Hitbox
			
			local KingCFrame = workspace.BoneSpec.KingCFrame.CFrame
			AntiCheatManager:Teleport(Player, KingCFrame)
			Character.HumanoidRootPart.Anchored = true
			
			local BoneCage = ServerStorage.Assets.Specs.Ruin.BoneCage:Clone()
			BoneCage:PivotTo(KingCFrame)
			BoneCage.Parent = workspace.Effects[Character.Name]
		end,
		ReleaseBoneKing = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			Character:SetAttribute("Execution", nil)
			
			if Character:FindFirstChild("BoneKingHitbox") then
				Character.BoneKingHitbox:Destroy()
			end
			if workspace.Effects[Character.Name]:FindFirstChild("BoneCage") then
				workspace.Effects[Character.Name].BoneCage:Destroy()
			end
			
			Character:SetAttribute("IFrames", true)
			
			if not PlayerData[Character.Name].WeaponEquipped then
				local WeaponModel = Character.Zanpakuto

				local ZanpakutoWeapon = Profile.ClientData.ZanpakutoWeapon
				PlayerData[Character.Name].WeaponEquipped = ZanpakutoWeapon
				WeaponModel.PrimaryPart.Weld.Enabled = false
				WeaponModel.Parent = Character["Right Arm"]

				local Motor6D = Character["Right Arm"]:FindFirstChild("Handle")
				Motor6D.Part1 = WeaponModel.PrimaryPart
				Motor6D.C0 = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].GripData

				if not SheatheSoundBlacklist[ZanpakutoWeapon] then
					local UnsheatheSound = WeaponData[PlayerData[Character.Name].WeaponEquipped .. "AttackData"].UnsheatheSound or Sounds.Unsheathe
					local ClonedUnsheathe = UnsheatheSound:Clone()
					ClonedUnsheathe.PlayOnRemove = true
					ClonedUnsheathe.Parent = Character.PrimaryPart
					ClonedUnsheathe:Destroy()
					ClonedUnsheathe = nil
				end

				local IdleNum = math.random(1, 3)
				if ZanpakutoWeapon ~= "Katana" then
					IdleNum = 1

					local ZanpakutoData = ZanpakutoWeapons:RetrieveData(ZanpakutoWeapon)

					if ZanpakutoData and ZanpakutoData.DoubleHandle then
						local DualMotor6D = Character["Left Arm"].DualHandle2
						DualMotor6D.Part1 = WeaponModel.DualShikai2.PrimaryPart
						DualMotor6D.C0 = WeaponData[ZanpakutoWeapon .. "AttackData"].Grip2Data

						WeaponModel.DualShikai2.PrimaryPart.Weld.Enabled = false
					end
					if ZanpakutoData and ZanpakutoData.InvisibleDraw then
						for i, v in ipairs(WeaponModel:GetDescendants()) do
							if v:GetAttribute("InvisibleDraw") then
								v.Transparency = 0
							end
						end
						
						if ZanpakutoData.QuincyDraw then
							WeaponModel.PrimaryPart.PointLight.Enabled = true
							WeaponModel.PrimaryPart.PointLight:SetAttribute("DisableFlashstepReenable", nil)
							
							local PathData = {Module = ClientLightAttacks, Skill = "QuincyWeaponSpawn"}
							local RenderDistance = 1000
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, WeaponModel)
						end
					end
				end

				if MultiIdles[ZanpakutoWeapon] then
					IdleNum = math.random(1, 2)
				end

				if not IdleBlacklist[ZanpakutoWeapon] then
					local IdleAnimation = Character.Humanoid.Animator:LoadAnimation(CombatAnimations[ZanpakutoWeapon]["Idle"..IdleNum])
					IdleAnimation:Play()
				end

				StateMachine:PushState("WeaponDrawn")
			end
			
			local PathData = {Module = ClientProgression, Skill = "TheBoneKing"}			
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)

			local BoneKingCutscene = Character.Humanoid.Animator:LoadAnimation(Animations.BoneKingCutscene)
			BoneKingCutscene:Play()

			local StunData = {
				NoHitEffect = true;
				TrueStunTime = 9;
				SoftStunTime = 0;
			}

			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)		

			task.delay(7.3, function()
				Character.HumanoidRootPart.Anchored = false
				Character:SetAttribute("IFrames", false)
				StateMachine:Trigger("TriggerBankaiObtained", StateMachine, Character)
			end)
		end,
	},
	Execution = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		TakeDamage = function(StateMachine, Character, AttackData, AttackOwner)
			local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local PathData = {Module = ClientProgression, Skill = "ExecutionDamage"}
			local RenderDistance = -1
			
			if PlayerAttacker then
				local AttackerProfile = DataManager:RequestProfile(PlayerAttacker)
				
				local Magnitude = (Character.HumanoidRootPart.Position - AttackOwner.HumanoidRootPart.Position).Magnitude				
				if PlayerData[Character.Name].ExecutionHits and Magnitude <= StatData.ExecutionMagnitude then
					local Damage = AttackData.Damage
					if AttackData.OriginalDamage then
						Damage = AttackData.OriginalDamage
					end
					
					local HealthSaveAmount = StatData.ExecutionHealthSave
					if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery == 1 and Profile.ClientData.BankaiUnlocked then
						HealthSaveAmount = 99999
						Damage = 1
					end
					if StatData.SoulSociety then
						if StatData.Factions[AttackerProfile.ClientData.Race] == "Shinigami" and not Profile.ClientData.SternritterHunt then
							Damage = 0
						end
					elseif StatData.HuecoMundo then
						if StatData.Factions[AttackerProfile.ClientData.Race] == "Arrancar" and not Profile.ClientData.SternritterHunt then
							Damage = 0
						end
					elseif StatData.WandenreichCity then
						if StatData.Factions[AttackerProfile.ClientData.Race] == "Quincy" then
							Damage = 0
						end
					end
					
					if Profile.ClientData.SternritterHunt and StatData.Factions[AttackerProfile.ClientData.Race] == "Quincy" or AttackOwner:GetAttribute("Zombification") then
						Damage = 0
					end
					
					PlayerData[Character.Name].ExecutionHits += Damage

					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, PlayerData[Character.Name].ExecutionHits, HealthSaveAmount)
					
					if PlayerData[Character.Name].ExecutionHits >= HealthSaveAmount then
						PlayerData[Character.Name].ExecutionHits = nil

						if PlayerData[Character.Name].ExecutionConnection then
							PlayerData[Character.Name].ExecutionConnection:Disconnect()
							PlayerData[Character.Name].ExecutionConnection = nil				
						end

						StateMachine:Trigger("ReleaseExecution", StateMachine, Character)
					end
				end
			end
			
			local UnconsciousAttackData = {
				Damage = 0;
				ImpactSound = AttackData.ImpactSound;
				NoHitEffect = AttackData.NoHitEffect;
				HitEffect = AttackData.HitEffect;
			}
			
			DamageTaken(Character, UnconsciousAttackData, AttackOwner)
		end,
		NozarashiBankai = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			Profile.ClientData.WipeTag = nil
			Profile.ClientData.NozarashiMastery = 2
			
			PlayerData[Character.Name].ExecutionHits = nil			
			
			Player:SetAttribute("NozarashiBankai", true)
			Character:SetAttribute("Execution", nil)
			Character:SetAttribute("IFrames", true)
			Character:SetAttribute("TempYachiruBuff", true)
			task.delay(124, function()
				Character:SetAttribute("TempYachiruBuff", nil)
			end)
			
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "ExecutionPose")
			
			local PathData = {Module = ClientProgression, Skill = "ThisPowerIsCalledBankai"}			
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData)
			
			local StunData = {
				NoHitEffect = true;
				TrueStunTime = 15;
				SoftStunTime = 0;
			}
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
			StateMachine:Trigger("TriggerTrueStun", StateMachine, Character, StunData)		
			
			local ThisPowerIsBankaiPlayerAnimation = Character.Humanoid.Animator:LoadAnimation(Animations.ThisPowerIsBankaiPlayer)	
			ThisPowerIsBankaiPlayerAnimation:Play()
			
			local Yachiru = ServerStorage.Assets.Specs.Nozarashi.Yachiru:Clone()
			Yachiru.HumanoidRootPart.CFrame = workspace.Execution.YachiruSpawn.CFrame
			Yachiru.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Yachiru, 14)
			
			local ThisPowerIsBankaiPlayerAnimation = Yachiru.Humanoid.Animator:LoadAnimation(Animations.ThisPowerIsBankaiYachiru)	
			ThisPowerIsBankaiPlayerAnimation:Play()
			
			task.delay(14, function()
				Character:SetAttribute("IFrames", false)
				StateMachine:Trigger("TriggerBankaiObtained", StateMachine, Character)
			end)
		end,
		Executed = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			local WandenreichPathData = {Module = ClientProgression, Skill = "WandenreichExecution"}
			local SoulSocietyPathData = {Module = ClientProgression, Skill = "SokyukoExecution"}
			local HuecoPathData = {Module = ClientProgression, Skill = "HuecoExecution"}
			local ExecutionDamage = {Module = ClientProgression, Skill = "ExecutionDamage"}
			local ExecutionTime = {Module = ClientProgression, Skill = "ExecutionTime"}
			local ClearExecution = {Module = ClientProgression, Skill = "ClearExecution"}
			local RenderDistance = -1
			
			local HealthSaveAmount = StatData.ExecutionHealthSave
			if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery == 1 and Profile.ClientData.BankaiUnlocked then
				HealthSaveAmount = 99999
			end			
			
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ExecutionDamage, 0, HealthSaveAmount)
			
			if Profile.ClientData.VastocarSeal then
				Character:SetAttribute("VastocarSeal", true)
			end
			Character:SetAttribute("Execution", true)
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpHeight = 0
			Character.Humanoid.AutoRotate = false
			
			if Profile.ClientData.SternritterHunt or Profile.ClientData.VastocarSeal then
				Character.Humanoid.Animator:LoadAnimation(Animations.SternritterHuntKneel):Play()
			else
				Character.Humanoid.Animator:LoadAnimation(Animations.ExecutionPose):Play()
			end
			
			local ExecuteCFrame
			if Profile.ClientData.SternritterHunt then
				ExecuteCFrame = workspace.Execution.QuincyExecution.Execute.CFrame
			else
				ExecuteCFrame = workspace.Execution.ExecutionBlock.Execute.CFrame
			end
			
			AntiCheatManager:Teleport(Player, ExecuteCFrame)
			Character.HumanoidRootPart.Anchored = true		
			
			PlayerData[Character.Name].ExecutionHits = 0
			
			local function HollowEssence()
				if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
					local ItemName = "Hollow Essence"
					local Item = ServerStorage.Assets.Items.Models[ItemName]:Clone()
					local TouchedPart = Item
					Item:SetAttribute("Owner", Player.UserId)
					if Item:IsA("Model") then
						for i, v in ipairs(Item:GetDescendants()) do
							if v:IsA("BasePart") then
								v.CollisionGroup = "Entity2"
							end
						end

						Item:PivotTo(ExecuteCFrame)
						TouchedPart = Item.PrimaryPart
					else
						Item.CollisionGroup = "Entity2"
						Item.CFrame = ExecuteCFrame
					end
					Item.Parent = workspace.DroppedItems

					local PickedUp
					local Connection
					Connection = TouchedPart.Touched:Connect(function(Part)
						if not PickedUp then
							local Humanoid = Part.Parent:FindFirstChild("Humanoid")
							if Humanoid then
								local PickupCharacter = Humanoid.Parent
								local Magnitude =  (PickupCharacter.HumanoidRootPart.Position - TouchedPart.Position).Magnitude
								if Magnitude <= 10 and PickupCharacter ~= Character then
									local PickupPlayer = Players:GetPlayerFromCharacter(PickupCharacter)
									if PickupPlayer then
										local PickupProfile = DataManager:RequestProfile(PickupPlayer)
										PickedUp = true
										Item:Destroy()
										Connection:Disconnect()
										Connection = nil
										DataManager:AddItem(PickupPlayer, ItemName, 1)

										local PickupPlayerAmount = DataManager:CheckItemQuantity(PickupPlayer, ItemName)

										local WebhookInfo = {
											Message = PickupPlayer.Name .. " has picked up " .. ItemName;
										}

										Webhooks:Post(ItemWebhookChannel, WebhookInfo)
									end
								end
							end
						end
					end)
				end
			end
			
			local Timer = StatData.ExecutionDuration
			if StatData.TYPETEST then
				Timer = 15
			end
			
			local Rate = 1
			local Accumulated = 0
			PlayerData[Character.Name].ExecutionConnection = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated > Rate then
					Accumulated -= Rate
					Timer -= Rate
					
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ExecutionTime, Timer)
					
					if Timer <= 0 then
						if PlayerData[Character.Name].ExecutionConnection then
							Character:SetAttribute("IFrames", true)
							Character.HumanoidRootPart.Anchored = false
							
							PlayerData[Character.Name].ExecutionConnection:Disconnect()
							PlayerData[Character.Name].ExecutionConnection = nil
							
							if Profile.ClientData.SternritterHunt then
								for i, v in ipairs(Players:GetPlayers()) do
									if v ~= Player then
										task.spawn(function()
											local CurrentProfile = DataManager:RequestProfile(v)
											if StatData.Factions[CurrentProfile.ClientData.Race] == "Shinigami" and CurrentProfile.Division.Squad > 0 and StatData.SoulSociety then
												local DivisionSpawn = workspace.DivisionSpawns["Division" .. CurrentProfile.Division.Squad]
												AntiCheatManager:Teleport(v, DivisionSpawn.CFrame * CFrame.new(0, 3, 0))
											elseif StatData.WandenreichCity and StatData.Factions[CurrentProfile.ClientData.Race] == "Quincy" then
												local PlayerSpawns = workspace.QuincySpawns:GetChildren()
												local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
												AntiCheatManager:Teleport(v, RandomSpawn * CFrame.new(0, 3, 0))
											else
												local function RandomOffset()
													local Min, Max = -15, 15
													local RNG = Random.new()
													return CFrame.new(RNG:NextNumber(Min, Max), 0, RNG:NextNumber(Min, Max))
												end

												if StatData.Factions[CurrentProfile.ClientData.Race] == "Arrancar" then
													AntiCheatManager:Teleport(v, workspace.PlayerRaid.ArrancarSpawn.CFrame * RandomOffset())
												elseif StatData.Factions[CurrentProfile.ClientData.Race] == "Shinigami" then
													AntiCheatManager:Teleport(v, workspace.PlayerRaid.SRSpawn.CFrame * RandomOffset())
												elseif StatData.Factions[CurrentProfile.ClientData.Race] == "Quincy" then
													AntiCheatManager:Teleport(v, workspace.PlayerRaid.QuincySpawn.CFrame * RandomOffset())
												else
													local PlayerSpawns = workspace.ShinigamiSpawns:GetChildren()
													local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
													AntiCheatManager:Teleport(v, RandomSpawn)
												end
											end
										end)
									end
								end
								
								Character.HumanoidRootPart.Anchored = true
								
								SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "SternritterHuntKneel")
								
								local CutsceneCFrame = workspace.Execution.QuincyExecution.CutsceneCFrame.CFrame
								Character.HumanoidRootPart.CFrame = CutsceneCFrame
								
								NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, WandenreichPathData)
								
								task.delay(8.6, function()
									HollowEssence()
									
									DataManager:Wipe(Player, "You have been executed by Sternritters.")

									local WebhookInfo = {
										Message = Player.Name .. " has been executed by Sternritters.";
									}

									Webhooks:Post(WebhookChannel, WebhookInfo)
								end)
							elseif Profile.ClientData.VastocarSeal then
								DataManager:RemoveSkill(Player, "Tri Cero")
								DataManager:RemoveSkill(Player, "Cero Cornea")
								DataManager:RemoveSkill(Player, "Blade Cero")
								DataManager:RemoveSkill(Player, "Cero Grab")
								DataManager:RemoveSkill(Player, "Finger Cero")
								DataManager:RemoveSkill(Player, "Cero Oscuras")
								DataManager:RemoveSkill(Player, "Instinct")
								DataManager:AddSkill(Player, "Cero")

								DataManager:ModifyProfile(Player, "ClientData", "Race", "Arrancar", "DontFireRemote")
								Profile.ClientData.VastocarRoll = nil
								Profile.ClientData.VastocarSeal = nil
								Profile.ClientData.SternritterHunt = nil

								PlayerData[Character.Name].ExecutionHits = nil

								Player.Character:SetAttribute("DeathBypass", true)
								Player.Character:BreakJoints()
								Player.Character.Humanoid.Health = -5

								local WebhookInfo = {
									Message = Player.Name .. " has been sealed from Vastocar.";
								}

								Webhooks:Post(WebhookChannel, WebhookInfo)
							elseif Profile.ClientData.WipeTag then
								if StatData.WandenreichCity then
									HollowEssence()
									DataManager:Wipe(Player, "You have been executed.")

									local WebhookInfo = {
										Message = Player.Name .. " has been executed.";
									}

									Webhooks:Post(WebhookChannel, WebhookInfo)
								elseif StatData.SoulSociety then
									NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, SoulSocietyPathData)

									for i, v in ipairs(Character:GetDescendants()) do
										if v:IsA("BasePart") then
											v.CanCollide = false
										end
									end

									AntiCheatManager:EnableFlight(Player)

									task.delay(21, function()
										HollowEssence()
										DataManager:Wipe(Player, "You have been executed.")

										local WebhookInfo = {
											Message = Player.Name .. " has been executed.";
										}

										Webhooks:Post(WebhookChannel, WebhookInfo)
									end)
								elseif StatData.HuecoMundo then
									if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery == 1 and Profile.ClientData.BankaiUnlocked then
										StateMachine:Trigger("NozarashiBankai", StateMachine, Character)
									else
										HollowEssence()
										DataManager:Wipe(Player, "You have been executed.")

										local WebhookInfo = {
											Message = Player.Name .. " has been executed.";
										}

										Webhooks:Post(WebhookChannel, WebhookInfo)
									end
								elseif TYPETEST then
									if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" and Profile.ClientData.NozarashiMastery == 1 and Profile.ClientData.BankaiUnlocked then
										StateMachine:Trigger("NozarashiBankai", StateMachine, Character)
									else
										HollowEssence()
										DataManager:Wipe(Player, "You have been executed.")
									end
								end
							end	
							
							NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ClearExecution)
						end
					end
				end
			end)
		end,
		ReleaseExecution = function(StateMachine, Character)
			Character:SetAttribute("Execution", nil)
			
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "ExecutionPose")
			SharedFunctions:CancelAnimation(Character.Humanoid.Animator, "SternritterHuntKneel")
			
			PlayerData[Character.Name].ExecutionHits = nil
			Character.HumanoidRootPart.Anchored = false
			Character.Humanoid.WalkSpeed = Character:GetAttribute("BaseWalkspeed")
			Character.Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			Character.Humanoid.AutoRotate = true
			
			if PlayerData[Character.Name].WeaponEquipped then
				StateMachine:SetState("WeaponDrawn")
			else
				StateMachine:SetState("Idle")
			end
			
			local ClearExecution = {Module = ClientProgression, Skill = "ClearExecution"}
			local RenderDistance = -1
			NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, ClearExecution)
		end,
	},
	Spectator = {
		RunFunction = function(StateMachine, Character, PassedFunction, ...)
			RunFunction(Character, StateMachine, PassedFunction, ...)
		end,
		Spectating = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			
			Character:SetAttribute("TrueIFrames", true)
			Character:SetAttribute("IFrames", true)
			Character:SetAttribute("Spectator", true)
			
			AntiCheatManager:LockSavedPosition(Player, Character.HumanoidRootPart.Position)
			
			AntiCheatManager:GiveImmunity(Player, 3)
			AntiCheatManager:GiveTpImmunity(Player, 1)
			
			if FactionManager:GladiatorActive() then
				local function RandomOffset()
					local Min, Max = -12, 12
					local RNG = Random.new()
					return CFrame.new(RNG:NextNumber(Min, Max), RNG:NextNumber(1, 5), RNG:NextNumber(Min, Max))
				end
				
				local GladiatorSpawns = workspace.PlayerRaid.Gladiator.SpectatorSpawns:GetChildren()
				local SelectedSpawn = GladiatorSpawns[math.random(1, #GladiatorSpawns)]
				AntiCheatManager:Teleport(Player, SelectedSpawn.CFrame * RandomOffset())
			else
				if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
					AntiCheatManager:Teleport(Player, workspace.PlayerRaid.HollowRoom.PrimaryPart.CFrame)
				elseif StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
					AntiCheatManager:Teleport(Player, workspace.PlayerRaid.SoulReaperRoom.PrimaryPart.CFrame)
				elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					AntiCheatManager:Teleport(Player, workspace.PlayerRaid.QuincyRoom.PrimaryPart.CFrame)
				end
			end
		end,
		TriggerM2 = function(StateMachine, Character)
			--[[local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local SpectatorList
			if FactionManager:ArtOfSoulActive() then
				SpectatorList = FactionManager:GetArtOfSoulData()
			elseif FactionManager:GladiatorActive() then
				SpectatorList = FactionManager:GetGladiatorData()
			end
			
			local CurrentPlayers = 0
			
			local PlayerList = {Player}
			for i, v in pairs(SpectatorList) do
				CurrentPlayers += 1
				
				if Players:FindFirstChild(i) then
					local SpectatorProfile = DataManager:RequestProfile(Players[i])
					if SpectatorProfile then
						if StatData.Factions[Profile.ClientData.Race] == StatData.Factions[SpectatorProfile.ClientData.Race] or FactionManager:GladiatorActive() then
							if FactionManager:GladiatorActive() then
								if FactionManager:HasGladiatorLife(Players[i]) then
									table.insert(PlayerList, Players[i])
								end
							else
								table.insert(PlayerList, Players[i])
							end
						end
					end
				end
			end
			
			if not PlayerData[Character.Name].ArtOfSoulSpectate then
				PlayerData[Character.Name].ArtOfSoulSpectate = CurrentPlayers
			end
			
			PlayerData[Character.Name].ArtOfSoulSpectate -= 1
			if PlayerData[Character.Name].ArtOfSoulSpectate <= 0 then
				PlayerData[Character.Name].ArtOfSoulSpectate = CurrentPlayers
			end
			
			if PlayerList[PlayerData[Character.Name].ArtOfSoulSpectate] then
				local CameraType = Enum.CameraType.Track
				local CameraSubject = PlayerList[PlayerData[Character.Name].ArtOfSoulSpectate].Character
				
				if workspace.StreamingEnabled then
					task.spawn(function()
						local Success, Error = pcall(function()
							Player:RequestStreamAroundAsync(CameraSubject.PrimaryPart.Position)
						end)
					end)
				end				
				
				local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
				local PathData = {Module = ClientProgression, Skill = "Spectate"}
				local RenderDistance = -1
				NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, CameraType, CameraSubject)
			end]]
		end,
		TriggerLAttack = function(StateMachine, Character)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local SpectatorList
			if FactionManager:ArtOfSoulActive() then
				SpectatorList = FactionManager:GetArtOfSoulData()
			elseif FactionManager:GladiatorActive() then
				SpectatorList = FactionManager:GetGladiatorData()
			end
			local CurrentPlayers = 0

			local PlayerList = {Player}
			for i, v in pairs(SpectatorList) do
				CurrentPlayers += 1

				if Players:FindFirstChild(i) then
					local SpectatorProfile = DataManager:RequestProfile(Players[i])
					if SpectatorProfile then
						if StatData.Factions[Profile.ClientData.Race] == StatData.Factions[SpectatorProfile.ClientData.Race] or FactionManager:GladiatorActive() then
							if FactionManager:GladiatorActive() then
								if FactionManager:HasGladiatorLife(Players[i]) then
									table.insert(PlayerList, Players[i])
								end
							else
								table.insert(PlayerList, Players[i])
							end
						end
					end
				end
			end

			if not PlayerData[Character.Name].ArtOfSoulSpectate then
				PlayerData[Character.Name].ArtOfSoulSpectate = 0
			end

			PlayerData[Character.Name].ArtOfSoulSpectate += 1
			if PlayerData[Character.Name].ArtOfSoulSpectate > CurrentPlayers then
				PlayerData[Character.Name].ArtOfSoulSpectate = 1
			end
			
			if PlayerList[PlayerData[Character.Name].ArtOfSoulSpectate] then
				local CameraType = Enum.CameraType.Track
				local CameraSubject = PlayerList[PlayerData[Character.Name].ArtOfSoulSpectate].Character
				
				if workspace.StreamingEnabled then
					task.spawn(function()
						local Success, Error = pcall(function()
							Player:RequestStreamAroundAsync(CameraSubject.PrimaryPart.Position)
						end)
					end)
				end
				
				local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
				local PathData = {Module = ClientProgression, Skill = "Spectate"}
				local RenderDistance = -1
				NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, CameraType, CameraSubject)
			end
		end,
		ReleaseSpectator = function(StateMachine, Character, ReleaseCFrame)
			local Player = Players:GetPlayerFromCharacter(Character)
			local Profile = DataManager:RequestProfile(Player)
			local CameraType = Enum.CameraType.Custom
			local CameraSubject = Character
			
			local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
			local PathData = {Module = ClientProgression, Skill = "Spectate"}
			local RenderDistance = -1
			NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, CameraType, CameraSubject)
			
			if ReleaseCFrame then
				AntiCheatManager:GiveTpImmunity(Player, 1)
				AntiCheatManager:Teleport(Player, ReleaseCFrame)
			else
				if StatData.Factions[Profile.ClientData.Race] == "Shinigami" and Profile.Division.Squad > 0 and StatData.SoulSociety then
					local DivisionSpawn = workspace.DivisionSpawns["Division" .. Profile.Division.Squad]
					AntiCheatManager:Teleport(Player, DivisionSpawn.CFrame * CFrame.new(0, 3, 0))
				elseif StatData.WandenreichCity and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					local PlayerSpawns = workspace.QuincySpawns:GetChildren()
					local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
					AntiCheatManager:Teleport(Player, RandomSpawn * CFrame.new(0, 3, 0))
				else
					local function RandomOffset()
						local Min, Max = -15, 15
						local RNG = Random.new()
						return CFrame.new(RNG:NextNumber(Min, Max), 0, RNG:NextNumber(Min, Max))
					end
					
					if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
						AntiCheatManager:Teleport(Player, workspace.PlayerRaid.ArrancarSpawn.CFrame * RandomOffset())
					elseif StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						AntiCheatManager:Teleport(Player, workspace.PlayerRaid.SRSpawn.CFrame * RandomOffset())
					elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
						AntiCheatManager:Teleport(Player, workspace.PlayerRaid.QuincySpawn.CFrame * RandomOffset())
					else
						local PlayerSpawns = workspace.ShinigamiSpawns:GetChildren()
						local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
						AntiCheatManager:Teleport(Player, RandomSpawn)
					end
				end
			end
			
			AntiCheatManager:UnlockSavedPosition(Player)
			
			Character:SetAttribute("TrueIFrames", nil)
			Character:SetAttribute("IFrames", false)
			Character:SetAttribute("Spectator", nil)
			StateMachine:SetState("Idle")
		end,
	},
}

function ShinigamiData:SetupEntity(EntityID, Player)
	PlayerData[Player.Name] = {}
	PlayerData[Player.Name].Debris = {}
	PlayerData[Player.Name].Connections = {}
	PlayerData[Player.Name].DisconnectFunctions = {}
	PlayerData[Player.Name].LastHitTime = 0
	local Profile = DataManager:RequestProfile(Player)
	
	FactionManager:SetupContributionData(Player)
	
	local function SetupCharacter(Player, Profile)
		local Character = Player.Character
		local PlayerAvatar
		local PlayerId = PlayerData[Character.Name].MimicID or Player.UserId
		
		Character.HumanoidRootPart.CFrame = workspace.ShinigamiSpawns.PlayerSpawn.CFrame
		
		if PlayerId > 0 then
			local Success, Error = pcall(function()
				PlayerAvatar = Players:GetCharacterAppearanceAsync(PlayerId)
			end)
			if not Success then
				PlayerAvatar = ServerStorage.Assets.Misc.AppearanceFailedToLoad:Clone()
				warn(Error)
			end
		else
			PlayerAvatar = ServerStorage.Assets.Misc.AppearanceFailedToLoad:Clone()
		end
		PlayerAvatar.Parent = ServerStorage
		-- Gets players appearance from their actual avatar and clones it to ServerStorage

		local PlayerClan = Profile.ClientData.Clan
		local Mask = Profile.ClientData.Mask
		local ShinigamiRank = Profile.ClientData.ShinigamiRank
		local Race = Profile.ClientData.Race
		local HairColor = Profile.ClientData.HairColor

		task.delay(5, function()
			PlayerAvatar:Destroy()
			PlayerAvatar = nil
		end)	

		local AppearanceData = {
			PlayerHair = {},
			BodyColor = PlayerAvatar["Body Colors"].HeadColor3,
			ColorName = PlayerAvatar["Body Colors"].HeadColor,
		}

		local BodyColor = ColorWhitelist["Pastel brown"]
		for ColorName, Color in pairs(ColorWhitelist) do
			if AppearanceData.ColorName.Name == ColorName then
				BodyColor = AppearanceData.BodyColor
			end
		end
		AppearanceData.BodyColor = BodyColor

		for _, Child in ipairs(PlayerAvatar:GetChildren()) do -- Only stores the players hair accessories
			if Child.ClassName == "Accessory" then
				if Child.Handle:FindFirstChild("HairAttachment") or table.find(HairWhitelist, Child.Name) or Child.Name:match("hair") or Child.Name:match("Hair") or Child.Name:match("bangs") or Child.Name:match("Bangs") then
					table.insert(AppearanceData.PlayerHair, Child)
				end	
			end
		end
		
		local function color3ToVector3(c3)
			return Vector3.new(c3.r, c3.g, c3.b)
		end

		-- Clone and change color of any hair accessories the player has
		
		--[[if Player.UserId == 16900523 then
			local GinHair = ServerStorage.Assets.Specs.Gin.GinHair:Clone()
			GinHair.Parent = Character
			
			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0.0138549805, -0.239180565, 0.0408935547, 1.49011612e-08, 0, 1.00000131, 0, 1, 0, -1.00000131, 0, 1.49011612e-08)
			Weld.Part0 = GinHair
			Weld.Part1 = Character.Head
			Weld.Parent = GinHair
		end]]
		for _, v in pairs(AppearanceData.PlayerHair) do 
			local NewAccessory = v:Clone()
			local Mesh = NewAccessory.Handle:FindFirstChildWhichIsA("SpecialMesh") 
			if Mesh then
				Mesh.TextureId = "rbxassetid://4486606505" -- rbxassetid://2880764254 (OLD TEXTURE) rbxassetid://4486606505
				if ClanData[PlayerClan]["HairColor"] then
					NewAccessory.Handle.Color = Color3.fromRGB(HairColor[1], HairColor[2], HairColor[3])
				end
				Mesh.VertexColor = color3ToVector3(NewAccessory.Handle.Color)

				if Mask and Mask == 99 then
					NewAccessory.Handle.Transparency = 1
				end
			end
			NewAccessory.Handle.CanQuery = false
			NewAccessory.Handle.CanCollide = false
			NewAccessory.Handle.CanTouch = false
			NewAccessory.Parent = Character
		end

		-- Change body colors for the players character so it's all one tone
		
		local BodyColors = Instance.new("BodyColors")
		BodyColors.HeadColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.LeftArmColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.LeftLegColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.RightArmColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.RightLegColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.TorsoColor = BrickColor.new(AppearanceData.BodyColor)
		BodyColors.Parent = Character

		-- Sets up their accessories
		
		InventoryManager:SetupAccessories(Player, Profile)
			
		if Mask then
			local MaskAccessory = ServerStorage.Assets.Accessories.Masks["Mask" .. Mask]:Clone()
			MaskAccessory.Name = Character.Name .. "Mask"
			MaskAccessory.Parent = Character.Accessories
			
			local Weld = Instance.new("Weld")
			Weld.Part1 = Character.Head
			Weld.C0 = MaskData["Mask" .. Mask]

			if MaskAccessory:IsA("Model") then
				Weld.Part0 = MaskAccessory.PrimaryPart
				Weld.Parent = MaskAccessory.PrimaryPart
			else
				Weld.Part0 = MaskAccessory
				Weld.Parent = MaskAccessory
			end
			
			if Mask == 99 then				
				local VVHair = ServerStorage.Assets.Misc.VVHair:Clone()
				VVHair.Parent = Character

				local Weld2 = Instance.new("Weld")
				Weld2.C0 = CFrame.new(-0.279632568, -0.071721077, 0.0187683105, 1.49011612e-08, 0, 1.00000131, 0, 1, 0, -1.00000131, 0, 1.49011612e-08)
				Weld2.Part0 = VVHair
				Weld2.Part1 = Character.Head
				Weld2.Parent = VVHair
			end
		end
		
		-- Create fake head and weld it to the character head, this way decals loaded onto the fake head wont be compressed & can glow (something to do with being inside the character)
		local FaceDecals = ServerStorage.Assets.Accessories.Faces
		local ClanDecals = ServerStorage.Assets.Accessories.ClanFaces:FindFirstChild(Profile.ClientData.Clan)
		Character.Head.face:Destroy()

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
		FakeHead.Parent = workspace.Effects[Player.Name]

		-- Clone the players facial features onto the FakeHead
		
		if Profile.ClientData.Clan == "Ichimaru" then
			if Profile.ClientData.Eyes ~= 1 then
				Profile.ClientData.Eyes = 1
			end
			if Profile.ClientData.Marking ~= 1 or Profile.ClientData.Mouth ~= 102 then
				Profile.ClientData.Marking = 1
			end
			if Profile.ClientData.Mouth < 1 or Profile.ClientData.Mouth > 2 then
				Profile.ClientData.Mouth = 1
			end
		elseif Profile.ClientData.Clan == "Hisgai" then
			if Profile.ClientData.Marking ~= 1 or Profile.ClientData.Mouth ~= 102 or Profile.ClientData.Mouth ~= 0 then
				Profile.ClientData.Marking = 1
			end
		elseif Profile.ClientData.Clan == "Custom" then
			if Profile.ClientData.Eyes ~= 1 then
				Profile.ClientData.Eyes = 1
			end
			if Profile.ClientData.Eyebrow ~= 1 then
				Profile.ClientData.Eyebrow = 1
			end
			if Profile.ClientData.Marking ~= 1 or Profile.ClientData.Mouth ~= 102 or Profile.ClientData.Marking ~= 0 then
				Profile.ClientData.Marking = 1
			end
			if Profile.ClientData.Mouth ~= 1 then
				Profile.ClientData.Mouth = 1
			end
		elseif Profile.ClientData.Clan == "Kira" then
			if Profile.ClientData.Eyes ~= 1 then
				Profile.ClientData.Eyes = 1
			end
			if Profile.ClientData.Marking ~= 1 or Profile.ClientData.Mouth ~= 102 then
				Profile.ClientData.Marking = 1
			end
		end
		
		local Eyes =  FaceDecals["Eye" .. Profile.ClientData.Eyes]:Clone()
		local Pupils = FaceDecals["Pupil" .. Profile.ClientData.Eyes]:Clone()
		local Mouth = FaceDecals["Mouth" .. Profile.ClientData.Mouth]:Clone()
		local Eyebrow = FaceDecals["Eyebrow" .. Profile.ClientData.Eyebrow]:Clone()
		local Marking = FaceDecals["Markings" .. Profile.ClientData.Marking]:Clone()
		
		local PupilColors = Profile.ClientData.EyeColor
		if Profile.ClientData.Eyes == 113 then
			local Eyes2 =  FaceDecals["Eye" .. Profile.ClientData.Eyes .. "b"]:Clone()
			Eyes2.Parent = FakeHead
			local Pupils2 = FaceDecals["Pupil" .. Profile.ClientData.Eyes .."b"]:Clone()
			Pupils2.Color3 = Color3.fromRGB(PupilColors[1] / 2, PupilColors[2] / 2, PupilColors[3] / 2)
			Pupils2.Parent = FakeHead
		elseif Profile.ClientData.Eyes == 116 then
			local PupilColors2 = Profile.ClientData.EyeColor2 or PupilColors
			local Pupils2 = FaceDecals["Pupil" .. Profile.ClientData.Eyes .."b"]:Clone()
			Pupils2.Color3 = Color3.fromRGB(PupilColors2[1]/4, PupilColors2[2]/4, PupilColors2[3]/4)
			Pupils2.Parent = FakeHead
		end
		
		Eyes.Parent = FakeHead
		Pupils.Color3 = Color3.fromRGB(PupilColors[1], PupilColors[2], PupilColors[3])
		Pupils.Parent = FakeHead
		Mouth.Parent = FakeHead
		Eyebrow.Parent = FakeHead
		Marking.Parent = FakeHead
		
		if ClanDecals then
			local function SetupArray(Object, MatchString)
				local Array = {}
				for i, v in pairs(Object:GetChildren()) do
					if string.match(v.Name, MatchString) then
						table.insert(Array, v.Name)
					end
				end
				table.sort(Array)
				return Array
			end
			
			local ClanFaceTypes = {
				SetupArray(ClanDecals, "Eye");
				SetupArray(ClanDecals, "Eyebrow");
				SetupArray(ClanDecals, "Mouth");
				SetupArray(ClanDecals, "Pupil");
				SetupArray(ClanDecals, "Markings");
			}

			local DataIndex = {
				"Eyes";
				"Eyebrow";
				"Mouth";
				"Eyes";
				"Marking";
			}
			
			local DecalIndex = {
				"Eye";
				"Eyebrow";
				"Mouth";
				"Pupil";
				"Markings";
			}

			for i = 1, 5 do
				if #ClanFaceTypes[i] > 0 then
					for _, v in ipairs(FakeHead:GetChildren()) do
						local StringMatch = string.match(v.Name, DecalIndex[i])
						if StringMatch and v.Name:len() == DecalIndex[i]:len() + 1 then
							print(v.Name, "String match")
							v:Destroy()
						end
					end
					
					local Type = Profile.ClientData[DataIndex[i]]
					local Decal = ClanDecals[DecalIndex[i] .. Type]:Clone()
					if DecalIndex[i] == "Pupil" then
						Decal.Color3 = Color3.fromRGB(PupilColors[1], PupilColors[2], PupilColors[3])
					end
					Decal.Parent = FakeHead
				end
			end
		end
		
		local ShinigamiClothes = { -- RANKBASED
			[0] = "Shinigami";
			[1] = "Shinigami";
			[2] = "Shinigami";
			[3] = "Shinigami";
			[4] = "Shinigami";
			[5] = "Shinigami";
			[6] = "Shinigami";
			[7] = "Shinigami";
			[8] = "Shinigami";
			[9] = "Shinigami";
			[10] = "Shinigami";
			[11] = "Shinigami";
			[12] = "Academy";
			[13] = "Academy";
			[14] = "Academy";
		};
		
		local Clothes = Profile.ClientData.Clothes
		local Gender = Profile.ClientData.Gender
		if Clothes > 0 then
			if StatData.Factions[Race] == "Shinigami" then
				local Variant = Clothes
				if ShinigamiRank > 11 then
					if Gender == "Male" then
						Variant = 1
					elseif Gender == "Female" then
						Variant = 2
					end
				end

				local Shirt = ServerStorage.Assets.Clothing.Shinigami[ShinigamiClothes[ShinigamiRank] .. "Shirt" .. Variant]:Clone()
				Shirt.Parent = Character
				local Pants = ServerStorage.Assets.Clothing.Shinigami[ShinigamiClothes[ShinigamiRank] .. "Pants" .. Variant]:Clone()
				Pants.Parent = Character-- Clone the players clothing based of their current rank & form
			elseif StatData.Factions[Race] == "Arrancar" then
				local Shirt = ServerStorage.Assets.Clothing.Arrancar["ArrancarShirt" .. Clothes]:Clone()
				Shirt.Parent = Character
				local Pants = ServerStorage.Assets.Clothing.Arrancar["ArrancarPants" .. Clothes]:Clone()
				Pants.Parent = Character
			elseif StatData.Factions[Race] == "Quincy" then
				local Shirt = ServerStorage.Assets.Clothing.Quincy["QuincyShirt" .. Clothes]:Clone()
				Shirt.Parent = Character
				local Pants = ServerStorage.Assets.Clothing.Quincy["QuincyPants" .. Clothes]:Clone()
				Pants.Parent = Character
			end
		else
			local Shirt = PlayerAvatar:FindFirstChildWhichIsA("Shirt")
			local Pants = PlayerAvatar:FindFirstChildWhichIsA("Pants")
			if Shirt then
				Shirt.Parent = Character
			end
			if Pants then
				Pants.Parent = Character
			end
		end
		
		local RightArm = Character:WaitForChild("Right Arm")
		local LeftArm = Character:WaitForChild("Left Arm")
		
		-- Create Motor6D that will equip weapons, saves us constantly remaking it when we want to equip a model
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Name = "Handle"
		Motor6D.Part0 = RightArm
		Motor6D.Parent = RightArm
		
		local DualMotor6D = Instance.new("Motor6D")
		DualMotor6D.Name = "DualHandle2"
		DualMotor6D.Part0 = LeftArm
		DualMotor6D.Parent = LeftArm
		
		
		--Character.PrimaryPart.CFrame = CFrame.new(Vector3.new(-542.6, 11, 34.1))
		--[[if Profile.ClientData.ZanpakutoWeapon == "Bambietta" then
			Character.Animate.run.RunAnim.AnimationId = "rbxassetid://11583121805"
			Character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://11583121805"
			Character.Animate.idle.Animation1.AnimationId = "rbxassetid://11575276008"
			Character.Animate.idle.Animation2.AnimationId = "rbxassetid://11575276008"
		end]]
		Character.Animate.Disabled = false
		
		local Name
		local FirstName = Profile.ClientData.Name
		local ClanName = Profile.ClientData.Clan
		local Title = Profile.ClientData.Title
		local ClanInfo = ClanData[ClanName]
		local Division = DivisionManager:RetrieveDivision(Profile.Division.Squad)
		
		local Spacer = " "
		if ClanInfo.Spacer then
			Spacer = ClanInfo.Spacer
		end
		
		Name = FirstName .. Spacer .. ClanName
		if ClanInfo.HideClanName then
			Name = FirstName
		end
		
		local Settings = Player.PlayerGui:FindFirstChild("Settings")
		if Settings then
			Settings.Frame.CharacterName.Text = Name
		end
		
		if StatData.Factions[Race] == "Quincy" and table.find(PositionTitles.QuincyRankings, Title) then
			Name = "- " .. Title .. " -\n" .. Name
		elseif StatData.Factions[Race] == "Arrancar" and table.find(PositionTitles.HollowRankings, Title) then
			Name = "- " .. Title .. " -\n" .. Name
		elseif StatData.Factions[Race] == "Arrancar" and Title == "Exequias" then
			Name = "- " .. Title .. " -\n" .. Name
		elseif StatData.Factions[Race] == "Arrancar" and Title == "The Tiger King" then
			Name = "- " .. Title .. " -\n" .. Name
		elseif StatData.Factions[Race] == "Shinigami" and table.find(PositionTitles.SoulReaperRankings, Title) then
			Name = "- " .. Title .. " -\n" .. Name
		elseif StatData.Factions[Race] == "Shinigami" and Title == "Leader of the Royal Guard" then
			Name = "- " .. Title .. " -\n" .. Name
		elseif Division then
			Name = "- " .. Division .. " -\n" .. Name
		end
		if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" or Profile.ClientData.ZanpakutoWeapon == "Unohana" then
			Name = "- Kenpachi -\n" .. Name
		end
		
		if Profile.ClientData.Medic then
			Name = "- Medic -\n" .. Name
		end
		
		Character.Humanoid.DisplayName = Name
		Character.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		Character.Humanoid.NameDisplayDistance = 50
		
		if StatData.Factions[Race] == "Quincy" and Profile.ClientData.LetztStil then
			local Welds = {
				Glove = CFrame.new(0.0120849609, 0.607318878, -0.00271606445, 1, 0, 0, 0, 1, 0, 0, 0, 1);
				["Reishi Part"] = CFrame.new(-0.0350341797, 0.666606903, -0.0106658936, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			}
			
			local LetztStilGlove = ServerStorage.Assets.Quincy.LetztStilGlove:Clone()
			LetztStilGlove.Parent = Character
			
			for i, v in pairs(LetztStilGlove:GetChildren()) do
				if Welds[v.Name] then
					local Weld = Instance.new("Weld")
					Weld.C0 = Welds[v.Name]
					Weld.Part0 = v
					Weld.Part1 = Character["Right Arm"]
					Weld.Parent = v
				end
			end
		end
		
		local SecondBankai
		if Race == "Visored" or (StatData.Factions[Race] == "Quincy" and Profile.ClientData.LetztStil) then --or Race == "Vastocar"
			SecondBankai = true
		end
		local ShikaiInfo = {
			Shikai = Profile.ClientData.ShikaiUnlocked;
			Bankai = Profile.ClientData.BankaiUnlocked;
			SecondBankai = SecondBankai;
		}
		if StatData.Factions[Race] == "Arrancar" then
			ShikaiInfo.SkillNames = require(ServerStorage.Modules.SkillModules.Res[Profile.ClientData.Shikai .. "Res"]).Keybinds
			
			if Profile.ClientData.ShikaiUnlocked == true then
				local PartialRes = Profile.ClientData.PartialRes
				ShikaiInfo.PartialRes = PartialRes
				ShikaiInfo.PartialRes2 = Profile.ClientData.PartialRes2
			end
		elseif StatData.Factions[Race] == "Shinigami" then
			ShikaiInfo.SkillNames = require(ServerStorage.Modules.SkillModules.Shikais[Profile.ClientData.Shikai .. "Shikai"]).Keybinds
		elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			local StolenBankai = Profile.ClientData.StolenBankai
			if StolenBankai then
				ShikaiInfo.Shikai = true
				ShikaiInfo.Bankai = true
				ShikaiInfo.SkillNames = require(ServerStorage.Modules.SkillModules.Shikais[StolenBankai.Shikai .. "Shikai"]).Keybinds
			else
				local VollstandigModule = ServerStorage.Modules.SkillModules.Vollstandig:FindFirstChild(Profile.ClientData.Shikai .. "Vollstandig")
				if VollstandigModule then
					if Profile.ClientData.ShikaiUnlocked then
						ShikaiInfo.Bankai = true
						ShikaiInfo.Shikai = false
						PlayerData[Character.Name].ShikaiModule = require(VollstandigModule)
					end
					if Profile.ClientData.BankaiUnlocked then
						ShikaiInfo.Bankai = true
						ShikaiInfo.Shikai = true
					end
					
					ShikaiInfo.SkillNames = require(VollstandigModule).Keybinds
				end
			end
		end

		local Info = {
			Rank = Profile.ClientData.GlobalRank,
			Grade = DataManager:RequestRank(Player),
			Name = Name,
			ClanName = ClanName,
			Title = Title,
			Race = Race,
		}
		
		if Profile.ClientData.Race == "Visored" or Profile.ClientData.Race == "Vastocar" then
			Info.HiddenGrade = "???"
			if Profile.ClientData.WeakVisored or Profile.ClientData.WeakVasto then
				Info.HiddenGrade = "?"
			end
		end
		
		Player:SetAttribute("Race", Race)
		ReplicatedStorage.Remotes.LeaderboardEvent:FireAllClients("Update", Player.Name, Info)
		if ShikaiInfo.Shikai or ShikaiInfo.Bankai then
			ReplicatedStorage.Remotes.ShikaiBankaiUI:FireClient(Player, ShikaiInfo)
		end
		
		local HealthAmount = PlayerBonus:ApplyHealth(Player, Profile.ClientData.MaxHealth)
		Character.Humanoid.MaxHealth = HealthAmount
		Character.Humanoid.Health = HealthAmount - 2
		
		for i, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CollisionGroup = "Entity"
			end
		end	
		
		Character.Humanoid.BreakJointsOnDeath = false
		Character.PrimaryPart = Character.HumanoidRootPart
		Character.Parent = workspace.Entities
	end
		
	local function CreateAttributes(Character, Profile, EntityID)
		local PlayerSPTable = DataManager:RequestSP(Player)
		local Toolbar = DataManager:RequestSkillInventory(Player)
		local PlayerUnlockedSkills = Profile.UnlockedSkills
		local ItemInventory = Profile.ItemInventory
		
		local TrueMaxReiatsu = RankManager:RetrievePlayerStats(Profile.ClientData.ShinigamiRank).Reiatsu
		local MaxHealth = RankManager:RetrievePlayerStats(Profile.ClientData.ShinigamiRank).Health
		local SetPosture = Profile.ClientData.MaxPosture
		local SetReiatsu = Profile.ClientData.MaxReiatsu
		local SetBankaiMeter = Profile.ClientData.MaxBankaiMeter
		local SetSecondBankaiMeter = StatData.SecondBankaiMeter
		
		TrueMaxReiatsu = PlayerBonus:ApplyReiatsu(Player, TrueMaxReiatsu)
		MaxHealth = PlayerBonus:ApplyHealth(Player, MaxHealth)
		SetPosture = PlayerBonus:ApplyPosture(Player, SetPosture)
		SetReiatsu = PlayerBonus:ApplyReiatsu(Player, SetReiatsu)
		
		DamageTracker:Setup(Character)
		PassivesManager:SetupPassives(Player, PlayerUnlockedSkills)
		local VastocarRoll = Profile.ClientData.VastocarRoll
		if Profile.ClientData.WeakVasto then
			VastocarRoll = nil
		end
		if (table.find(PlayerUnlockedSkills, "Espada Sonido") and Player.UserId == 400349) then
			PassivesManager.Passives[Character.Name].FlashstepMastery = 4
			Character:SetAttribute("EspadaSpeed", true)
		end
		if table.find(PlayerUnlockedSkills, "Heavenly Restriction") then
			Character:SetAttribute("HeavenlyRestriction", true)
			SetPosture += SkillData["Heavenly Restriction"].ExtraPosture
		end
		
		Player:SetAttribute("LastAttacker", nil)
		Character:SetAttribute("Respawning", true)
		Character:SetAttribute("EntityType", Profile.ClientData.Race)
		
		Player:SetAttribute("EntityID", EntityID)
		Character:SetAttribute("EntityID", EntityID)
		Character:SetAttribute("MaxHealth", MaxHealth)
		Character:SetAttribute("TrueMaxReiatsu", TrueMaxReiatsu)
		Character:SetAttribute("MaxPosture", SetPosture)
		Character:SetAttribute("Posture", 0)
		Character:SetAttribute("MaxReiatsu", SetReiatsu)
		Character:SetAttribute("Reiatsu", SetReiatsu - 1)
		Character:SetAttribute("MaxBankaiMeter", SetBankaiMeter)
		Character:SetAttribute("BankaiMeter", Profile.ClientData.BankaiMeter)
		Character:SetAttribute("MaxSecondBankaiMeter", SetSecondBankaiMeter)
		Character:SetAttribute("SecondBankaiMeter", 0)
		Character:SetAttribute("Combo", 1)
		Character:SetAttribute("BaseWalkspeed", StatData.WalkSpeeds.Base)
		Character:SetAttribute("BaseJumpheight", StatData.JumpHeights.Base)
		
		Character:SetAttribute("Clan", Profile.ClientData.Clan)
		
		Character:SetAttribute("Kido", PlayerSPTable.Kido)
		Character:SetAttribute("Speed", PlayerSPTable.Speed)
		Character:SetAttribute("Kendo", PlayerSPTable.Kendo)
		if PlayerSPTable.Kido >= 50 then
			Character:SetAttribute("AdvancedKido", true)
		end
		
		Character:SetAttribute("CounterType", "string")
		Character:SetAttribute("CounterFrames", false)
		Character:SetAttribute("SoftCounterType", "string")
		Character:SetAttribute("SoftCounterFrames", false)
		Character:SetAttribute("EvasiveFrames", false)
		Character:SetAttribute("DeflectFrames", false)
		Character:SetAttribute("BlockFrames", false)
		Character:SetAttribute("IFrames", true)
		Character:SetAttribute("HyperArmor", false)
		
		Character:SetAttribute("ZanpakutoState", 0) 
		--[[
			ZanpakutoState = {
				0 = base weapon;
				1 = shikai;
				2 = bankai;
				3 = secondbankai;
			}
		]]
		
		if Profile.ClientData.WipeTag then
			if not Profile.ClientData.HollowCandyQuest then
				Character:SetAttribute("GripBypass", true)
				if StatData.CurrentFactions[Profile.ClientData.Race] and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
					Character:SetAttribute("QuincyHunted", true)
				end
			end
		end

		if Profile.ClientData.VisoredWorthy then
			Character:SetAttribute("VisoredWorthy", true)
		end
		if Profile.ClientData.ReiatsuDebuff then
			Character:SetAttribute("ReiatsuDebuff", true)
		end
		if FactionManager:IsRaidActive() then
			Character:SetAttribute("RaidMusic", true)
		end
		
		Character:SetAttribute("CurrentState", "Idle")
		
		Character:SetAttribute("ParryCooldown", 1700) -- Time in milliseconds for parry to come off cooldown (just checks current time compares to this value)
		Character:SetAttribute("BlockTimer", 0)
		Character:SetAttribute("FlashstepTimer", 0)
		Character:SetAttribute("ComboTimer", 0)
		Character:SetAttribute("DashTimer", 0)
		Character:SetAttribute("FeintTimer", 0)
		Character:SetAttribute("ShikaiTimer", 0)
		Character:SetAttribute("VisoredTimer", 0)
		Character:SetAttribute("ReturnTimer", 0)
		Character:SetAttribute("ModeTimer", 0)
		
		Character:SetAttribute("CombatTag", 0)
		Character:SetAttribute("PlayerCombatTag", 0)
		Character:SetAttribute("SternritterCombatTag", 0)
		
		Character:SetAttribute("Z", false)
		Character:SetAttribute("X", false)
		Character:SetAttribute("C", false)
		Character:SetAttribute("T", false)
		Character:SetAttribute("G", false)
		Character:SetAttribute("CriticalAttack", false)
		
		Character:SetAttribute("One", false)
		Character:SetAttribute("Two", false)
		Character:SetAttribute("Three", false)
		Character:SetAttribute("Four", false)
		Character:SetAttribute("Five", false)
		Character:SetAttribute("Six", false)
		Character:SetAttribute("Seven", false)
		Character:SetAttribute("Eight", false)
		Character:SetAttribute("Nine", false)
		Character:SetAttribute("Zero", false)
		Character:SetAttribute("Minus", false)
		Character:SetAttribute("Equals", false)
		
		PlayerData[Player.Name].Cooldowns = {
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
		
		Character:SetAttribute("Kan", Profile.ClientData.Kan)
		
		if table.find(PlayerUnlockedSkills, "Infinity") then
			Character:SetAttribute("CounterType", "Infinity")
			Character:SetAttribute("CounterFrames", true)
		end
		if table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title) and not Profile.ClientData.NoSternSpec then
			if not Profile.ClientData.DisableTitleBonus then
				Character:SetAttribute("Sternritter", true)
			end
			
			local Schrifts = {
				"The Balance";
				"The Almighty";
				"The Fear";
				"The Superstar";
				"The Visionary";
				"The Zombie";
				"The Explode";
				"The Deathdealing";
			}
			
			local Schrift = table.find(Schrifts, Profile.ClientData.Title)
			if Schrift then
				Schrift = Profile.ClientData.Title
				Character:SetAttribute("Schrift", Schrift:gsub("The ", ""))
				
				if Schrift == "The Balance" then
					Character:SetAttribute("SternritterSpeed", true)
				elseif Schrift == "The Almighty" then
					Character:SetAttribute("SternritterSpeed", true)
				elseif Schrift == "The Zombie" then
					if not PlayerData[Player.Name].ZombieData then
						PlayerData[Player.Name].ZombieData = {
							Connections = {};
							DisconnectFunctions = {};
							BankaiReleases = 0;
						}
					end
				elseif Schrift == "The Visionary" then
					if not PlayerData[Player.Name].VisionaryData then
						PlayerData[Player.Name].VisionaryData = {
							Clones = {};
							Connections = {};
							DisconnectFunctions = {};
							Thinking = 0;
						}
					end
				elseif Schrift == "The Deathdealing" then
					PlayerData[Player.Name].DeathdealingData = {}
					PlayerData[Player.Name].DeathdealingTimer = 0
					
					local GiftRing = ReplicatedStorage.Assets.Effects.Vollstandig.Deathdealing.GiftRing:Clone()
					GiftRing.Parent = Character

					local Weld = Instance.new("Weld")
					Weld.C0 = CFrame.new(-0.017364502, 0.521453559, 6.10351562e-05, 0.0931464508, -2.37382665e-06, 0.995654821, 0, 1.00000238, -2.38419216e-06, -0.995657206, -2.22077972e-07, 0.0931462273)
					Weld.Part0 = GiftRing
					Weld.Part1 = Character["Right Arm"]
					Weld.Parent = GiftRing
				end
			end
		end
		
		if StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			local SpiritBowInfo = SpiritBowData[Profile.ClientData.SpiritBow .. "AttackData"]
			Character:SetAttribute("SpiritAmmo", SpiritBowInfo.LightAttack.Ammo)
			Character:SetAttribute("MaxSpiritAmmo", SpiritBowInfo.LightAttack.Ammo)
		end
		
		if Profile.ClientData.ZanpakutoWeapon == "Nozarashi" then
			Character:SetAttribute("Kenpachi", true)
		elseif Profile.ClientData.ZanpakutoWeapon == "Starrk" then
			Character:SetAttribute("Ammo", 3)
		elseif Profile.ClientData.ZanpakutoWeapon == "Unohana" then
			Character:SetAttribute("Unohana", true)
		end
		
		local HierroIndicator = {Module = ClientSkills, Skill = "HierroIndicator"}
		if Profile.ClientData.Race == "Vastocar" and VastocarRoll == 1 then
			local HierroTierData = {
				[1] = SkillData.Hierro;
				[2] = SkillData["Hierro Mastery"];
				[3] = SkillData["Hierro Mastery 2"];
			}
			
			local HitIncrease = 10
			local HierroReduction = SkillData.Hierro.Reduction
			local HierroHits = SkillData.Hierro.HitAmount + HitIncrease
			local HierroTier = PassivesManager:RequestPassives(Player).HierroTier
			
			if HierroTier then
				HierroReduction = HierroTierData[HierroTier].Reduction
				HierroHits = HierroTierData[HierroTier].HitAmount + HitIncrease
			end
			HierroReduction -= 0.2
			if HierroReduction < StatData.VastocarHierroDefenseMax then
				HierroReduction = StatData.VastocarHierroDefenseMax
			end
			
			Character:SetAttribute("HierroRegen", true)
			Character:SetAttribute("HierroRegenLimit", HierroHits)
			Character:SetAttribute("HierroTier", HierroReduction)
			Character:SetAttribute("Hierro", HierroReduction)
			Character:SetAttribute("HierroHits", HierroHits)
			Character:SetAttribute("HierroTimer", 0)
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, HierroIndicator, "On")
		else
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, HierroIndicator, "Off")
		end
		
		task.delay(0.3, function()
			local PlayerItemInventory = Profile.ItemInventory
			
			local Cat = table.find(PlayerUnlockedSkills, "Cat")
			if Cat then
				local CatRemote = Instance.new("RemoteEvent")
				CatRemote.Name = "Cat"
				CatRemote.Parent = Player.Character.CharacterHandler.Remotes
			end
			
			ReplicatedStorage.Remotes.LoadClient:FireClient(Player, Profile.Settings, "Viewport", Cat)
			task.delay(0.2, function()
				ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, nil, PlayerItemInventory)
				ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
			end)
			
			local function CreateTradeableButtons()
				for ItemName, Quantity in pairs(ItemInventory) do
					local ValidItem = TradeablesData[ItemName]
					if ValidItem then
						local ItemInfo = {
							ItemName = ItemName;
							Info = ValidItem;
						}
						ReplicatedStorage.Remotes.UpdateAccessoryUIEvent:FireClient(Player, ItemInfo, PlayerItemInventory)
					end
				end
			end
			coroutine.wrap(CreateTradeableButtons)()	
			
			if Profile.ClientData.VastoFailed then
				ReplicatedStorage.Remotes.MaskCrackUpdate:FireClient(Player, 0, "Failed")
			end
		end)
		
		for i, v in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				if v:IsDescendantOf(Players) then
					local Profile = DataManager:RequestProfile(v)
					if Profile then
						local Name
						local FirstName = Profile.ClientData.Name
						local ClanName = Profile.ClientData.Clan
						local ClanInfo = ClanData[ClanName]
						local Spacer = " "
						if ClanInfo.Spacer then
							Spacer = ClanInfo.Spacer
						end

						Name = FirstName .. Spacer .. ClanName
						if ClanInfo.HideClanName then
							Name = FirstName
						end

						local Info = {
							Rank = Profile.ClientData.GlobalRank,
							Grade = DataManager:RequestRank(v),
							Name =  Name,
							Title = Profile.ClientData.Title,
							LeaderboardHidden = ClanInfo.LeaderboardHidden,
							Race = Profile.ClientData.Race,
						}
						
						if Profile.ClientData.Race == "Visored" or Profile.ClientData.Race == "Vastocar" then
							Info.HiddenGrade = "???"
							if Profile.ClientData.WeakVisored or Profile.ClientData.WeakVasto then
								Info.HiddenGrade = "?"
							end
						end

						ReplicatedStorage.Remotes.LeaderboardEvent:FireAllClients("Create", v.Name, Info)
					end
				end
			end)
		end
	end
	
	local function CheckJailed(Player)
		if Profile.ClientData.JailTime then
			JailManager:Jail(Player, Player, Profile.ClientData.JailDuration, nil, "RespawnedJail")
		end
	end
	
	local function ForcefieldOnSpawn(Character)
		Character:SetAttribute("IFrames", true)
		Character:SetAttribute("Forcefield", true)
		
		for i, v in ipairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				if v:CanSetNetworkOwnership() then
					v:SetNetworkOwner(Player)
				end
				v.CollisionGroup = "Entity2"
			end
		end
		
		local ForceFieldHighlight = Instance.new("Highlight")
		ForceFieldHighlight.OutlineColor = Color3.fromRGB(0, 234, 255)
		ForceFieldHighlight.OutlineTransparency = 0.5
		ForceFieldHighlight.FillColor = Color3.fromRGB(0, 234, 255)
		ForceFieldHighlight.FillTransparency = 0.5
		ForceFieldHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		ForceFieldHighlight.Parent = Character

		local SpawnPosition = Character.HumanoidRootPart.Position
		local Accumulated = 0
		
		while true do
			local Step = task.wait(0.05)
			if Character.Humanoid.Health <= 0 then
				return
			end
			
			Accumulated += Step

			if Accumulated > 30 and not Character:GetAttribute("ControlsDisabled") then
				Character:SetAttribute("IFrames", false)
				Character:SetAttribute("Forcefield", nil)

				for i, v in ipairs(Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CollisionGroup = "Entity"
					end
				end

				ForceFieldHighlight:Destroy()
				ForceFieldHighlight = nil
				return
			end

			if Character and Character:FindFirstChild("HumanoidRootPart") then
				local Magnitude = (Character.HumanoidRootPart.Position - SpawnPosition).Magnitude
				if Magnitude >= 10 then
					Character:SetAttribute("IFrames", false)
					Character:SetAttribute("Forcefield", nil)

					for i, v in ipairs(Character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CollisionGroup = "Entity"
						end
					end

					ForceFieldHighlight:Destroy()
					ForceFieldHighlight = nil
					break
				end
			end
		end
	end
	
	local function VisoredTraining(Character, Profile)
		if (Profile.ClientData.VisoredWorthy and Profile.ClientData.Race == "Shinigami") or (Profile.ClientData.Race == "Visored" and Profile.ClientData.VisoredPool.Mastered == false) then
			local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
			local WhisperPath = {Module = ClientProgression, Skill = "VisoredWhispers"}
			local RenderDistance = -1

			local WhisperRate = 3
			local Accumulated = 0
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 then
					return
				end
				
				Accumulated += Step
				if Accumulated > WhisperRate then
					Accumulated -= WhisperRate

					if Profile.ClientData.Race == "Visored" then
						NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, WhisperPath, "Visored", Profile.ClientData.VisoredPool.VisoredType)
					else
						NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, WhisperPath, "Shinigami")
					end

					if Profile.ClientData.Race == "Visored" and Profile.ClientData.VisoredPool.Mastered == true then
						break
					end
				end
			end
		end
	end
	
	local function BankaiCheck(Character, Profile)
		if StatData.IsReserved then
			return
		end
		
		local ShinigamiRankMet = Profile.ClientData.ShinigamiRank <= StatData.BankaiRankRequirement
		local Top5 = Profile.ClientData.GlobalRank >= 1 and Profile.ClientData.GlobalRank <= StatData.BankaiRequirements.GlobalRank
		local BankaiDurationFulfilled = Profile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration
		local BankaiUnlocked = Profile.ClientData.BankaiUnlocked
		local ShikaiUnlocked = Profile.ClientData.ShikaiUnlocked
		
		if StatData.Factions[Profile.ClientData.Race] == "Arrancar" or StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			--ShikaiUnlocked = true
		end
		
		local function InsidePartRegion(PartRegion, Point)
			local v3 = PartRegion.CFrame:PointToObjectSpace(Point)
			return (math.abs(v3.X) <= PartRegion.Size.X / 2)
				and (math.abs(v3.Y) <= PartRegion.Size.Y / 2)
				and (math.abs(v3.Z) <= PartRegion.Size.Z / 2)
		end
		
		if ShikaiUnlocked == true and BankaiUnlocked == false and ShinigamiRankMet and Top5 and not BankaiDurationFulfilled then
			PlayerData[Character.Name].BankaiTop5 = true
			
			local RankDurationAdd = 1
			if StatData.Factions[Profile.ClientData.Race] == "Quincy" then
				RankDurationAdd += RankDurationAdd * StatData.QuincyCatchupBonus
			end
			
			local Rate = 1
			local Accumulated = 0
			
			local function calculateMultiplier(rank)
				local percentIncrease = rank == 1 and 200 or 200-rank;
				if percentIncrease < 1 then
					percentIncrease = 1
				end
				return percentIncrease/100+1;
			end
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 or not Character:FindFirstChild("HumanoidRootPart") then
					return
				end
				
				if Profile.ClientData.GlobalRank > 0 then
					Accumulated += Step
					if Accumulated > Rate and not InsidePartRegion(workspace["Royal Palace"].PalaceRegion, Player.Character.HumanoidRootPart.Position) and not Character:GetAttribute("InDangai") then
						Accumulated -= Rate
						if Character.HumanoidRootPart.Position.Y < 4500 then
							if StatData.WandenreichCity and FactionManager:IsRaidActive() and not FactionManager:IsGrace() then
								Profile.ClientData.BankaiRequirements.RankDuration += RankDurationAdd * calculateMultiplier(Profile.ClientData.GlobalRank)--* 2
							else
								Profile.ClientData.BankaiRequirements.RankDuration += RankDurationAdd * calculateMultiplier(Profile.ClientData.GlobalRank)
							end
						end

						if Profile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration then
							local WebhookInfo = {
								Message = Player.Name .. " is unrivaled";
								Title = Player.Name .. " " .. Player.UserId
							}

							Webhooks:Post(BankaiPatrolChannel, WebhookInfo)

							break
						end
					end
				end
			end
		end
	end
	
	local function VastoSpeed(Character, Profile)
		local VastocarRoll = Profile.ClientData.VastocarRoll
		if Profile.ClientData.WeakVasto then
			VastocarRoll = nil
		end
		if (VastocarRoll == 3 and Profile.ClientData.Race == "Vastocar") then
			Character:SetAttribute("VastoSpeed", true)
			
			local ClientPassives = ReplicatedStorage.Modules.ClientModules.ClientPassives
			local PathData = {Module = ClientPassives, Skill = "VastoDodge"}
			local RenderDistance = -1
			
			PlayerData[Character.Name].VastoDodgeCooldown = StatData.VastocarDodgeRefreshRate
			PlayerData[Character.Name].VastoDodges = StatData.VastocarMaxDodges - 1
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 or not PlayerData[Character.Name] then
					return
				end
				
				if PlayerData[Character.Name].VastoDodges < StatData.VastocarMaxDodges then
					PlayerData[Character.Name].VastoDodgeCooldown += Step
				else
					PlayerData[Character.Name].VastoDodgeCooldown = 0
				end

				if PlayerData[Character.Name].VastoDodgeCooldown >= StatData.VastocarDodgeRefreshRate then
					PlayerData[Character.Name].VastoDodgeCooldown = 0

					PlayerData[Character.Name].VastoDodges += 1
					NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, "2")

					Character:SetAttribute("SoftCounterFrames", true)
					Character:SetAttribute("SoftCounterType", "Vasto Dodge")

					if PlayerData[Character.Name].VastoDodges >= StatData.VastocarMaxDodges then
						PlayerData[Character.Name].VastoDodges = StatData.VastocarMaxDodges
					end
				end
			end
		end
	end
	
	local function CaptainAnnounce(Character, Profile)
		local function FilterMsg(FilterPlayer, Message)
			local TextService = game:GetService("TextService")
			local UserID = FilterPlayer.UserId

			local Blacklist = {
				"Sped", "sped", "Gay", "gay", "Stupid", "stupid", "Dumb", "dumb", "Idiot", "idiot", "Retard", "retard",
				"Nqquher", "nqquher",
			}

			local FilteredMessage
			local Success, Error = pcall(function()
				local Filter = TextService:FilterStringAsync(Message, UserID, Enum.TextFilterContext.PrivateChat)
				FilteredMessage = Filter:GetNonChatStringForBroadcastAsync()
				
				print(FilteredMessage)				
				
				if FilteredMessage then
					for i, v in ipairs(Blacklist) do
						if FilteredMessage:match(v) then
							FilteredMessage = nil
						end
					end
				end
			end)
			if not Success then
				warn(Error)
			end
			return FilteredMessage
		end
		
		local Prefix = "/"
		
		if table.find(PositionTitles.CaptainTitles, Profile.ClientData.Title) or Profile.ClientData.Title == "Exequias" or Profile.ClientData.Medic then
			PlayerData[Character.Name].CaptainAnnounceConnection = Player.Chatted:Connect(function(Message, Recipient)
				if Message:sub(1, 1) == Prefix and Message:sub(1, 3) ~= "/e " and Message:sub(1, 3) ~= "/w " then
					Message = Message:sub(2, #Message)				

					if #Message > 0 then
						local Name
						local FirstName = Profile.ClientData.Name
						local ClanName = Profile.ClientData.Clan
						local ClanInfo = ClanData[ClanName]

						local Spacer = " "
						if ClanInfo.Spacer then
							Spacer = ClanInfo.Spacer
						end

						Name = FirstName .. Spacer .. ClanName
						if ClanInfo.HideClanName then
							Name = FirstName
						end	

						local FilteredMessage = FilterMsg(Player, Message)
						if FilteredMessage then
							for i, v in ipairs(Players:GetPlayers()) do
								task.spawn(function()
									local PlayerProfile = DataManager:RequestProfile(v)						
									if PlayerProfile and StatData.Factions[Profile.ClientData.Race] == StatData.Factions[PlayerProfile.ClientData.Race] then
										if v.PlayerGui:FindFirstChild("ScreenEffects") then
											local Frames = {}
											for _, UIs in ipairs(v.PlayerGui.ScreenEffects:GetChildren()) do
												if UIs.Name == "CloneCaptainMessage" then
													table.insert(Frames, UIs)
												end
											end
											for _, UIs in ipairs(Frames) do
												local NewTransparency = UIs.TextLabel.TextTransparency + 0.34
												if NewTransparency > 1 then
													NewTransparency = 1
												end
												local Position = UIs.Position
												TweenService:Create(UIs, TweenInfo.new(0.1), {Position = UDim2.new(Position.X.Scale, Position.X.Offset, Position.Y.Scale - 0.06, Position.Y.Offset)}):Play()
												TweenService:Create(UIs.TextLabel, TweenInfo.new(0.1), {TextTransparency = NewTransparency, TextStrokeTransparency = NewTransparency}):Play()
											end
											Frames = nil

											local ClonedServerMessage = v.PlayerGui.ScreenEffects.ServerMessage:Clone()
											ClonedServerMessage.Name = "CloneCaptainMessage"
											ClonedServerMessage.Visible = true
											ClonedServerMessage.TextLabel.Text = Name .. ":\n" .. FilteredMessage
											ClonedServerMessage.Parent = v.PlayerGui.ScreenEffects
											Debris:AddItem(ClonedServerMessage, 6)
										end
									end
								end)
							end
						end
					end

					--[[local splitString = Message:split("_")
					local Cmd = splitString[1]
					if CaptainCommands[Cmd] then
						local Args = {}

						for i = 2, #splitString do
							table.insert(Args, splitString[i])
						end

						CaptainCommands[Cmd](Player, Args)
					end]]
				end
			end)
		end
	end
	
	local function BlutVene(Character)
		local Player = Players:GetPlayerFromCharacter(Character)
		local Profile = DataManager:RequestProfile(Player)
		if table.find(Profile.UnlockedSkills, "Blut Vene") then
			local BlutTierData = {
				[1] = SkillData["Blut Vene"];
				[2] = SkillData["Blut Vene 2"];
				[3] = SkillData["Blut Vene 3"];
			}

			local BlutTier = BlutTierData[PassivesManager:RequestPassives(Player).BlutTier]
			if Profile.ClientData.DisableTitleBonus then
				BlutTier = BlutTierData[1]
			end
			
			local BlutCooldown = BlutTier.Cooldown
			local BlutAmount = BlutTier.Amount
			local BlutRegen = BlutTier.Regen
			local ArterieRegen = BlutTier.ArterieRegen
			
			local Accumulated = 0
			local Rate = 1 / 10
			
			local BlutIndicator = {Module = ClientSkills, Skill = "BlutIndicator"}
			local RenderDistance = 1000
			
			Character:SetAttribute("BlutVene", BlutAmount)
			
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, BlutIndicator, "On")
			
			PlayerData[Character.Name].BlutConnection2 = Character:GetAttributeChangedSignal("BlutVene"):Connect(function()
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, BlutIndicator, "On")
			end)
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 or not PlayerData[Character.Name] then
					return
				end
				
				Accumulated += Step
				if Accumulated > Rate then	
					Accumulated -= Rate

					if not Character:GetAttribute("BlutCooldown") then	
						local TimeDifference = DateTime.now().UnixTimestampMillis - PlayerData[Character.Name].LastHitTime
						if TimeDifference >= BlutCooldown * 1000 or Character:GetAttribute("BlutArterie") then
							local RegenAmount = BlutRegen / 10
							if Character:GetAttribute("BlutArterie") then
								RegenAmount = ArterieRegen / 10
							end	

							local CurrentBlut = Character:GetAttribute("BlutVene") + RegenAmount
							if CurrentBlut < BlutAmount then
								Character:SetAttribute("BlutVene", CurrentBlut)
							else
								Character:SetAttribute("BlutVene", BlutAmount)
							end
						end
					end
				end
			end
		end
	end
	
	local function JugramAllyBuff(Character, Profile)
		if Character:GetAttribute("Schrift") == "Balance" then
			Character:SetAttribute("BalanceTracker", 0)
			
			local JugramBuffData = {
				Name = "JugramBuff";
				Value = true;
				Duration = SpecData.Jugram.AllyBuff.Duration;
			}
			
			local MisfortuneRedirectionRate = SpecData.Jugram.MisfortuneRedirection.DamageTrackRate
			local Rate = SpecData.Jugram.AllyBuff.Duration
			local Accumulated = 0
			local MisfortuneRedirectionAccumulated = 0
			local MisfortuneRedirectionReset = MisfortuneRedirectionRate
			
			local ClientBalanceVollstandig = ReplicatedStorage.Modules.ClientModules.Vollstandig.ClientBalanceVollstandig
			local PathData = {Module = ClientBalanceVollstandig, Skill = "BalanceIndicator"}
			local ResetPath = {Module = ClientBalanceVollstandig, Skill = "BalanceIndicatorReset"}
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "On")
			NetworkManager.FireClient(Player, Character, "ClientEffects", -1, ResetPath, MisfortuneRedirectionReset)
			
			PlayerData[Character.Name].JugramDamageConnection = Character:GetAttributeChangedSignal("BalanceTracker"):Connect(function()
				local CurrentDamage = Character:GetAttribute("BalanceTracker")
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, "On")
			end)
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 then
					return
				end
				
				Accumulated += Step
				MisfortuneRedirectionAccumulated += Step

				if MisfortuneRedirectionAccumulated >= 1 then
					MisfortuneRedirectionAccumulated -= 1
					MisfortuneRedirectionReset -= 1

					if MisfortuneRedirectionReset <= 0 then
						MisfortuneRedirectionReset = MisfortuneRedirectionRate
						Character:SetAttribute("BalanceTracker", 0)
					end

					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, ResetPath, MisfortuneRedirectionReset)
				end

				if Accumulated > Rate then
					Accumulated -= Rate

					local MagnitudeCenter = Character.HumanoidRootPart.Position
					local Detection = HitDetection:GetPartBoundsInRadius(Character, MagnitudeCenter, SpecData.Jugram.AllyBuff.Range)
					if Detection then
						for Entity, HitType in pairs(Detection) do
							local PlayerEntity = Players:GetPlayerFromCharacter(Entity)
							if PlayerEntity then
								if Player:GetAttribute("Party") and PlayerEntity:GetAttribute("Party") == Player:GetAttribute("Party") then
									PassivesManager:ApplyDebuff(Character, {Entity}, JugramBuffData)
								end
							end
						end
					end
				end
			end
		end
	end
	
	local function TheFear(Character, Profile)
		if Character:GetAttribute("Schrift") == "Fear" then
			local function ApplyFeared(Character, PositiveHits, Duration)
				local ClientSpecs = ReplicatedStorage.Modules.ClientModules.ClientSpecs

				local DebuffData = {
					Name = "Feared";
					Value = true;
					Duration = Duration;
					ClientPath = {Module = ClientSpecs, Skill = "Feared"};
					AnimationData = {
						Play = ReplicatedStorage.Assets.ShikaiAnimations.Shadow.Feared;
					};
				}

				PassivesManager:ApplyDebuff(Character, PositiveHits, DebuffData)
			end
			
			local FearAura = ReplicatedStorage.Assets.Effects.Vollstandig.Fear.FearAura:Clone()
			FearAura.Parent = Character.HumanoidRootPart
			
			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0.000366210938, 3.81469727e-06, 0.000244140625, -4.37113883e-08, 0, -1, 0, 1, 0, 1, 0, -4.37113883e-08)
			Weld.Part0 = FearAura
			Weld.Part1 = Character.HumanoidRootPart
			Weld.Parent = FearAura
			
			local Rate = 1
			local Accumulated = 0
			
			while true do
				local Step = task.wait(0.05)
				if Character.Humanoid.Health <= 0 then
					return
				end
				
				Accumulated += Step

				if Accumulated > Rate then
					Accumulated -= Rate

					if Character:GetAttribute("CurrentState") ~= "Unconscious" then
						local MagnitudeCenter = Character.HumanoidRootPart.Position
						local Detection = HitDetection:LookMagnitude(Character, MagnitudeCenter, SpecData.Nodt.Fear.Properties.Range, "PartyCheck")
						if Detection then
							local PositiveHits = CombatManager:ApplyDamage(Character, Detection, SpecData.Nodt.Fear)
							for i, v in ipairs(PositiveHits) do
								local FearTimer = v:GetAttribute("TheFearTimer") or 0
								local TimeDifference = DateTime.now().UnixTimestampMillis - FearTimer

								if TimeDifference >= SpecData.Nodt.Fear.FearCD * 1000 and not v:GetAttribute("Feared") then
									local FearData = {
										Name = SpecData.Nodt.Fear.DebuffData.Name;
										Value = SpecData.Nodt.Fear.DebuffData.Value;
										Duration = SpecData.Nodt.Fear.DebuffData.Duration;
										ClientPath = SpecData.Nodt.Fear.DebuffData.ClientPath;
									}

									local FearStacks = v:GetAttribute(SpecData.Nodt.Fear.DebuffData.Name) or 0						
									FearStacks += 1
									if FearStacks >= SpecData.Nodt.Fear.DebuffData.Value then
										FearStacks = SpecData.Nodt.Fear.DebuffData.Value

										CombatManager:ApplyDamage(Character, {[v] = "FrontalHit"}, SpecData.Nodt.Fear.FearedData)
										ApplyFeared(Character, {v}, SpecData.Nodt.Fear.FearedData.TrueStunTime)

										PassivesManager:RemoveDebuff(Character, {v}, FearData)
									else
										FearData.Value = FearStacks
										PassivesManager:ApplyDebuff(Character, {v}, FearData)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	local function SternritterSpec(Character, Profile)
		if StatData.Factions[Profile.ClientData.Race] == "Quincy" and table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title) and table.find(StatData.SpecVollstandigs, Profile.ClientData.Shikai) then
			local VollstandigModule = ServerStorage.Modules.SkillModules.Vollstandig:FindFirstChild(Profile.ClientData.Shikai .. "Vollstandig")
			if VollstandigModule then
				local ShikaiModule = require(VollstandigModule)
				PlayerData[Character.Name].ShikaiModule = ShikaiModule
				Character:SetAttribute("VollstandigBypass", true)
				if Profile.ClientData.Title == "The Balance" or Profile.ClientData.Title == "The Almighty" then
					Character:SetAttribute("VollstandigBankaiBypass", true)
				end
			end
		end
	end
	
	local function PartialRes(Character, Profile)
		if StatData.Factions[Profile.ClientData.Race] == "Arrancar" and Profile.ClientData.ShikaiUnlocked == true and not Profile.ClientData.QuincyMedallion then
			local PartialRes = Profile.ClientData.PartialRes
			local PartialRes2 = Profile.ClientData.PartialRes2
			
			local ResModule = require(ServerStorage.Modules.SkillModules.Res[Profile.ClientData.Shikai .. "Res"])
			PlayerData[Character.Name].ShikaiModule = ResModule
			Character:SetAttribute("PartialRes", PartialRes)
			Character:SetAttribute("PartialRes2", PartialRes2)
		end
	end
	
	local function ReducedRankTimers(Character, Profile)
		while true do
			local Step = task.wait(1)
			if Character.Humanoid.Health <= 0 or not PlayerData[Character.Name] then
				return
			end
			
			Profile.ClientData.RankTimer -= 0.5 -- 0.5s lost
			
			local RankTimer = Profile.ClientData.RankTimer
			local ShinigamiRank = Profile.ClientData.ShinigamiRank
			local TimeDifference = DateTime.now().UnixTimestamp - RankTimer
			local Minutes = TimeDifference / 60
			local RankupText = math.floor(Minutes) .. "/" .. math.floor(StatData.RankTimers[ShinigamiRank] * 60) .." Min"
			if Minutes >= StatData.RankTimers[ShinigamiRank] * 60 then
				RankupText = "CAN RANK"
			end
			
			Player.PlayerGui.Settings.Frame.RankTimer.Text = RankupText
		end
	end
	
	PlayerData[Player.Name].CharacterAdded = Player.CharacterAdded:Connect(function(Character)
		PlayerData[Player.Name].PlayerDied = Character.Humanoid.Died:Connect(function()
			AntiCheatManager:PlayerNotLoaded(Player)
			EntityManager:ForceState(Player.Character, "Dying")
			SharedFunctions:CancelAllAnimations(Character.Humanoid)
			PassivesManager:ResetPassives(Character)
			
			if not Character:GetAttribute("DeathBypass") then
				local TrackedDamage = DamageTracker:RetrieveData(Character).EloCounter
				local CombatTags
				if Player then
					CombatTags = CollectionService:GetTagged(Character.Name .. "CombatTag")
				else
					CombatTags = CollectionService:GetTags(Character)
				end

				if CombatTags and #CombatTags > 0 and Character:GetAttribute("SternritterCombatTag") <= 0 then
					BountyBoardManager:CheckBounty(Player)
					RankManager:ResetSchriftProgress(Player)
					
					if not StatData.IsReserved then
						local EloCharacter, EloDamage
						for Entity, Damage in pairs(TrackedDamage) do
							task.spawn(function()
								local EloAllowed

								local PlayerEntity = Players:GetPlayerFromCharacter(Entity)
								if PlayerEntity then
									if table.find(CombatTags, PlayerEntity) then
										local ExecutorProfile = DataManager:RequestProfile(PlayerEntity)
										if ExecutorProfile.ClientData.ShinigamiRank <= StatData.MinimumRankReq and Profile.ClientData.ShinigamiRank <= StatData.MinimumRankReq then
											if StatData.CurrentFactions[StatData.Factions[Profile.ClientData.Race]] then -- StatData.Factions[Profile.ClientData.Race] ~= StatData.Factions[ExecutorProfile.ClientData.Race]
												EloAllowed = true
											end
										end
									end
								end

								if EloAllowed then
									if not EloCharacter then
										EloCharacter, EloDamage = Entity, Damage
									else
										if Damage > EloDamage then
											EloCharacter, EloDamage = Entity, Damage
										end
									end
								end
							end)
						end

						if EloCharacter then
							local EloPlayer = Players:GetPlayerFromCharacter(EloCharacter)
							local ExecutorProfile = DataManager:RequestProfile(EloPlayer)
							local Elo = Profile.ClientData.Elo
							local ExeuctorElo = ExecutorProfile.ClientData.Elo

							if Profile.ClientData.GlobalRank > 0 then
								local ShinigamiRankMet = ExecutorProfile.ClientData.ShinigamiRank <= StatData.BankaiRankRequirement
								local BankaiDurationFulfilled = ExecutorProfile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration
								local BankaiUnlocked = ExecutorProfile.ClientData.BankaiUnlocked
								local ShikaiUnlocked = ExecutorProfile.ClientData.ShikaiUnlocked

								if StatData.Factions[ExecutorProfile.ClientData.Race] == "Arrancar" then
									ShikaiUnlocked = true
								end

								if not BankaiDurationFulfilled and ShinigamiRankMet and not BankaiUnlocked and ShikaiUnlocked then
									local RankDurationAdd = StatData.RankedPlayerGripBankaiDurationAdd
									if StatData.Factions[ExecutorProfile.ClientData.Race] == "Quincy" then
										RankDurationAdd += RankDurationAdd * StatData.QuincyCatchupBonus
									end

									if StatData.WandenreichCity and FactionManager:IsRaidActive() and not FactionManager:IsGrace() then
										ExecutorProfile.ClientData.BankaiRequirements.RankDuration += RankDurationAdd --* 2
									else
										ExecutorProfile.ClientData.BankaiRequirements.RankDuration += RankDurationAdd
									end

									if ExecutorProfile.ClientData.BankaiRequirements.RankDuration >= StatData.BankaiRequirements.RankDuration then							
										local BankaiWebhookChannel = "BankaiPatrol"
										local WebhookInfo = {
											Message = EloPlayer.Name .. " is unrivaled";
											Title = EloPlayer.Name .. " " .. EloPlayer.UserId
										}


										Webhooks:Post(BankaiWebhookChannel, WebhookInfo)
									end
								end
							end

							if Elo < 0 then
								Elo = 0
							end

							local EloDisabledTimer = ExecutorProfile.ClientData.EloDisabledTimer or 0
							local TimeDifference = DateTime.now().UnixTimestamp - EloDisabledTimer
							local Minutes = TimeDifference / 60

							local EloGained
							local NoElo
							local ReducedElo = 0.35
							local LastPlayerGripped = ExecutorProfile.ClientData.LastPlayerGripped
							if LastPlayerGripped and LastPlayerGripped == Player.UserId then
								NoElo = true
							end
							if ExeuctorElo > 0 and Elo <= 0 then
								NoElo = true
							end
							
							local ExtraEloLoss = 5
							if not NoElo and Minutes >= StatData.BountyRankedDisableCD * 60 then
								if ExecutorProfile.ClientData.GlobalRank > 0 then
									if Profile.ClientData.GlobalRank > 0 then
										if Profile.ClientData.GlobalRank >= ExecutorProfile.ClientData.GlobalRank then
											local SetElo = (Elo * 0.1) + 2
											local ExecutorEloGain = SetElo
											if ExeuctorElo > StatData.EloSoftcap then
												ExecutorEloGain = StatData.EloSoftgain
											end
											if LastPlayerGripped and LastPlayerGripped == Player.UserId then
												ExecutorEloGain *= ReducedElo
											end

											ExeuctorElo += ExecutorEloGain
											ExecutorProfile.ClientData.Elo = ExeuctorElo

											EloGained = true
											SetElo += ExtraEloLoss
											if Elo - SetElo < 0 then
												Profile.ClientData.Elo = -1
											else
												Elo -= SetElo 
												Profile.ClientData.Elo = Elo
											end
										elseif Profile.ClientData.GlobalRank < ExecutorProfile.ClientData.GlobalRank then
											local SetElo = (Elo * 0.05) + 1
											local ExecutorEloGain = SetElo
											if ExeuctorElo > StatData.EloSoftcap then
												ExecutorEloGain = StatData.EloSoftgain
											end
											if LastPlayerGripped and LastPlayerGripped == Player.UserId then
												ExecutorEloGain *= ReducedElo
											end

											ExeuctorElo += ExecutorEloGain
											ExecutorProfile.ClientData.Elo = ExeuctorElo

											EloGained = true
											SetElo += ExtraEloLoss
											if Elo - SetElo < 0 then
												Profile.ClientData.Elo = -1
											else
												Elo -= SetElo
												Profile.ClientData.Elo = Elo
											end
										end
									end
								else
									local SetElo = (Elo * 0.05) + 1
									local ExecutorEloGain = SetElo
									if ExeuctorElo > StatData.EloSoftcap then
										ExecutorEloGain = StatData.EloSoftgain
									end
									if LastPlayerGripped and LastPlayerGripped == Player.UserId then
										ExecutorEloGain *= ReducedElo
									end

									ExeuctorElo += ExecutorEloGain
									ExecutorProfile.ClientData.Elo = ExeuctorElo

									EloGained = true
									--print(SetElo, ExecutorProfile.ClientData.Elo)
									SetElo += ExtraEloLoss
									if Elo - SetElo < 0 then
										Profile.ClientData.Elo = -1
									else
										Elo -= SetElo 
										Profile.ClientData.Elo = Elo
									end
								end
							end

							if EloGained then
								ExecutorProfile.ClientData.LastPlayerGripped = Player.UserId

								local function SyncElo(SyncPlayer)
									task.spawn(function()
										local SyncProfile = DataManager:RequestProfile(SyncPlayer)

										local Success, Error = pcall(function()
											RankedLeaderboards:UpdateAsync(SyncPlayer.UserId, function(oldValue)
												return tonumber(math.floor(SyncProfile.ClientData.Elo))
											end)
										end)
										if Success then
											print(SyncPlayer.Name .. "'s elo successfully synced: " .. SyncProfile.ClientData.Elo)
										else
											warn("[Ranked Leaderboard Sync Error]:", Error)
										end
									end)
								end

								SyncElo(Player)
								SyncElo(EloPlayer)

								task.spawn(function()
									local lowestFirst = false
									local numbersShown = 100 -- Top 100 public
									local min = 20
									local max = 10e30
									local Success, Pages = pcall(function()
										return RankedLeaderboards:GetSortedAsync(lowestFirst, numbersShown, min, max)
									end)
									if Success then
										local TopPage = Pages:GetCurrentPage()
										local Data = {}

										for Rank, PageData in pairs(TopPage) do
											Data[tostring(PageData.key)] = Rank
										end
										local PageSuccess, Error = pcall(function()
											Pages:AdvanceToNextPageAsync()
										end)
										if PageSuccess then
											for Rank, PageData in pairs(Pages:GetCurrentPage()) do
												Data[tostring(PageData.key)] = Rank + 100
											end
										end

										local function SyncRank(SyncPlayer)
											if Data[tostring(SyncPlayer.UserId)] then
												DataManager:ModifyProfile(SyncPlayer, "ClientData", "GlobalRank", Data[tostring(SyncPlayer.UserId)])
											else
												DataManager:ModifyProfile(SyncPlayer, "ClientData", "GlobalRank", -1)
											end
											print("[RunserviceChecks]: Successfully synced rank for ", SyncPlayer.Name)
										end

										SyncRank(Player)
										SyncRank(EloPlayer)
									else
										warn("[Ranked Leaderboard Page Error]:", Pages)
									end
								end)

								local PathData = {Module = ClientProgression, Skill = "EloGained"}
								NetworkManager.FireAllClients(EloCharacter, "ClientEffects", 1000, PathData)

								local GripLogChannel = "GripLogs"
								local WebhookInfo = {
									Message = EloPlayer.Name .. " took elo from " .. Player.Name;
								}

								Webhooks:Post(GripLogChannel, WebhookInfo)
							end
						end
					end
				end	
				
				if Profile.ClientData.ShinigamiRank <= 11 then
					local Race = Profile.ClientData.Race
					if StatData.Factions[Race] == "Arrancar" then
						local MaxHealth = Profile.ClientData.MaxHealth
						MaxHealth -= StatData.HealthLossOnDeath
						if MaxHealth > StatData.MinimumHealth then
							Profile.ClientData.MaxHealth = MaxHealth
						else
							Profile.ClientData.MaxHealth = StatData.MinimumHealth
						end
					elseif StatData.Factions[Race] == "Shinigami" then
						local MaxReiatsu = Profile.ClientData.MaxReiatsu
						MaxReiatsu -= StatData.ReiatsuLossOnDeath
						if MaxReiatsu > StatData.MinimumReiatsu then
							Profile.ClientData.MaxReiatsu = MaxReiatsu
						else
							Profile.ClientData.MaxReiatsu = StatData.MinimumReiatsu
						end
					elseif StatData.Factions[Race] == "Quincy" then
						local MaxReiatsu = Profile.ClientData.MaxReiatsu
						MaxReiatsu -= StatData.ReiatsuLossOnDeath
						if MaxReiatsu > StatData.MinimumReiatsu then
							Profile.ClientData.MaxReiatsu = MaxReiatsu
						else
							Profile.ClientData.MaxReiatsu = StatData.MinimumReiatsu
						end
						local MaxHealth = Profile.ClientData.MaxHealth
						MaxHealth -= StatData.HealthLossOnDeath
						if MaxHealth > StatData.MinimumHealth then
							Profile.ClientData.MaxHealth = MaxHealth
						else
							Profile.ClientData.MaxHealth = StatData.MinimumHealth
						end
					end
				end
				
				local QuincyMedallion = DataManager:RemoveItem(Player, "Quincy Medallion", 1)
				if QuincyMedallion then
					local WebhookInfo = {
						Message = Player.Name .. "'s Quincy Medallion has been destroyed";
					}

					Webhooks:Post(WebhookChannel, WebhookInfo)
				end
			end
			
			ServerStorage.LiveAssets[Character.Name]:ClearAllChildren()
			workspace.Effects[Character.Name]:ClearAllChildren()
			
			for i, v in pairs(PlayerData[Character.Name].Connections) do
				if PlayerData[Character.Name].DisconnectFunctions[i] then
					PlayerData[Character.Name].DisconnectFunctions[i]()
					PlayerData[Character.Name].DisconnectFunctions[i] = nil
				end
				PlayerData[Character.Name].Connections[i]:Disconnect()
				PlayerData[Character.Name].Connections[i] = nil
			end
			
			if PlayerData[Character.Name].ZombieConnection then
				PlayerData[Character.Name].ZombieConnection:Disconnect()
				PlayerData[Character.Name].ZombieConnection = nil
			end
			if PlayerData[Character.Name].Dance then
				PlayerData[Character.Name].Dance.DisconnectFunction()
			end
			if PlayerData[Character.Name].Piano then
				PlayerData[Character.Name].Piano.DisconnectFunction()
			end
			if PlayerData[Character.Name].KnockoutDisconnect then
				PlayerData[Character.Name].KnockoutDisconnect:Disconnect()
				PlayerData[Character.Name].KnockoutDisconnect = nil
			end
			if PlayerData[Character.Name].HighSpeedConnection then
				PlayerData[Character.Name].HighSpeedConnection:Disconnect()
				PlayerData[Character.Name].HighSpeedConnection = nil
			end
			if PlayerData[Character.Name].ShikaiTrainerConnection then
				PlayerData[Character.Name].ShikaiTrainerConnection:Disconnect()
				PlayerData[Character.Name].ShikaiTrainerConnection = nil
			end
			if PlayerData[Character.Name].ZombieCharacterRemoving then
				PlayerData[Character.Name].ZombieCharacterRemoving:Disconnect()
				PlayerData[Character.Name].ZombieCharacterRemoving = nil
			end
			if PlayerData[Character.Name].CaptainAnnounceConnection then
				PlayerData[Character.Name].CaptainAnnounceConnection:Disconnect()
				PlayerData[Character.Name].CaptainAnnounceConnection = nil
			end
			if PlayerData[Character.Name].BlutConnection2 then
				PlayerData[Character.Name].BlutConnection2:Disconnect()
				PlayerData[Character.Name].BlutConnection2 = nil
			end
			if PlayerData[Character.Name].JugramDamageConnection then
				PlayerData[Character.Name].JugramDamageConnection:Disconnect()
				PlayerData[Character.Name].JugramDamageConnection = nil
			end
			if PlayerData[Character.Name].ShunkoConnection then
				PlayerData[Character.Name].ShunkoConnection:Disconnect()
				PlayerData[Character.Name].ShunkoConnection = nil
			end
			if PlayerData[Character.Name].UnohanaConnection then
				PlayerData[Character.Name].UnohanaConnection:Disconnect()
				PlayerData[Character.Name].UnohanaConnection = nil
				PlayerData[Character.Name].UnohanaStacks = nil
				PlayerData[Character.Name].UnohanaDuration = nil
			end
			if PlayerData[Player.Name].VollstandigQuestConnection then
				PlayerData[Player.Name].VollstandigQuestConnection:Disconnect()
				PlayerData[Player.Name].VollstandigQuestConnection = nil
			end
			if PlayerData[Character.Name].KnockoutThread then
				task.cancel(PlayerData[Character.Name].KnockoutThread)
				PlayerData[Character.Name].KnockoutThread = nil
			end
			if PlayerData[Player.Name].VollstandigQuestDummy then
				task.spawn(function()
					EntityManager:ForceState(PlayerData[Player.Name].VollstandigQuestDummy, "Dying")
					EntityManager:ChangeState(PlayerData[Player.Name].VollstandigQuestDummy, "TriggerDeath")
				end)
				PlayerData[Player.Name].VollstandigQuestDummy = nil
			end
			if PlayerData[Character.Name].VollstandigQuest then
				local WebhookInfo = {
					Message = Player.Name .. " failed vollstandig quest";
					Title = Player.Name .. " " .. Player.UserId;
				}

				Webhooks:Post(BankaiPatrolChannel, WebhookInfo)
				InnerWorlds:Cleanup(Player)
				PlayerData[Character.Name].VollstandigQuest = nil
			end

			if PlayerData[Character.Name].WeaponAnimator then
				PlayerData[Character.Name].WeaponAnimator = nil
			end
			if PlayerData[Character.Name].ResActive then
				PlayerData[Character.Name].ResActive = nil
			end
			if PlayerData[Character.Name].BankaiTop5 then				
				PlayerData[Character.Name].BankaiTop5 = nil
			end
			if PlayerData[Character.Name].SiphonLink then
				PlayerData[Character.Name].SiphonLink = nil
			end
			if PlayerData[Character.Name].ShikaiActiveData then
				if PlayerData[Character.Name].ShikaiActiveData.Connections then
					for i, v in pairs(PlayerData[Character.Name].ShikaiActiveData.Connections) do
						if PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] then
							PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i]()
							PlayerData[Character.Name].ShikaiActiveData.DisconnectFunctions[i] = nil
						end
						
						PlayerData[Character.Name].ShikaiActiveData.Connections[i]:Disconnect()
						PlayerData[Character.Name].ShikaiActiveData.Connections[i] = nil
					end
				end
				PlayerData[Character.Name].ShikaiActiveData = nil
			end
			if PlayerData[Character.Name].BankaiActiveData then
				if PlayerData[Character.Name].BankaiActiveData.Connections then
					for i, v in pairs(PlayerData[Character.Name].BankaiActiveData.Connections) do
						if PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i] then
							PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i]()
							PlayerData[Character.Name].BankaiActiveData.DisconnectFunctions[i] = nil
						end

						PlayerData[Character.Name].BankaiActiveData.Connections[i]:Disconnect()
						PlayerData[Character.Name].BankaiActiveData.Connections[i] = nil
					end
				end
				PlayerData[Character.Name].BankaiActiveData = nil
			end
			if PlayerData[Player.Name].VisionaryData then
				for i, v in pairs(PlayerData[Player.Name].VisionaryData.Connections) do
					PlayerData[Player.Name].VisionaryData.Connections[i]:Disconnect()
					PlayerData[Player.Name].VisionaryData.Connections[i] = nil
				end
				for i, v in ipairs(PlayerData[Player.Name].VisionaryData.Clones) do
					task.spawn(function()
						EntityManager:ChangeState(v, "TriggerUnconscious")
					end)
				end
				
				PlayerData[Player.Name].VisionaryData.Thinking = 0
			end
			if PlayerData[Player.Name].CheerBuddy then
				task.spawn(function()
					EntityManager:ChangeState(PlayerData[Player.Name].CheerBuddy, "TriggerUnconscious")
				end)
				PlayerData[Player.Name].CheerBuddy = nil
			end
			for i, v in ipairs(PlayerData[Player.Name].Debris) do
				task.spawn(function()
					PlayerData[Player.Name].Debris[i]:Destroy()
				end)
				PlayerData[Player.Name].Debris[i] = nil
			end
			
			PlayerData[Character.Name].KnockoutTime = nil
			PlayerData[Character.Name].MeditatingCFrame = nil
			PlayerData[Character.Name].WeaponEquipped = nil
			PlayerData[Character.Name].ShikaiFight = nil
			PlayerData[Character.Name].MortalTies = nil
			if PlayerData[Character.Name].BankaiQuest then
				PlayerData[Character.Name].BankaiQuest = nil
				InnerWorlds:Cleanup(Player)
			elseif PlayerData[Character.Name].ResQuest then
				PlayerData[Character.Name].ResQuest = nil
				InnerWorlds:Cleanup(Player)
			end
			Quests:Cleanup(Player)
			
			BountyBoardManager:ClearBounty(Player)
			
			local Teleported
			if not Character:GetAttribute("DeathBypass") and Character:GetAttribute("CombatTag") > 0 then
				RankManager:AddEXP(Player, StatData.DeathEXPLoss)
				RankManager:RemoveShikaiProgress(Player)
				RankManager:RemovePlayerGrips(Player)
				
				if StatData.KarakuraTown or Character:GetAttribute("ReturnHome") then
					if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
						Teleported = StatData.PlaceIDs["Hueco Mundo"]
					elseif StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
						Teleported = StatData.PlaceIDs["Soul Society"]
					elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
						Teleported = StatData.PlaceIDs["Wandenreich City"]
					end
				end
			end
			
			Character:SetAttribute("CombatTag", 0)
			Profile.ClientData.CombatLogged = 0
	
			AntiCheatManager:ClearLastPosition(Player)
			
			CombatManager:ResetCombatTags(Character, Player)
			CombatManager:ClearAllTags(Character)
			
			local RespawnTime = StatData.RespawnTime
			if not Teleported then
				if FactionManager:IsRaidActive() and not FactionManager:IsGrace() or FactionManager:IsHuntActive() then
					if not Character:GetAttribute("DeathBypass") then
						if FactionManager:IsHuntActive() then
							if not PlayerData[Character.Name].HuntRespawnDeaths then
								PlayerData[Character.Name].HuntRespawnDeaths = -1
							end
							PlayerData[Character.Name].HuntRespawnDeaths += 1
							
							RespawnTime = StatData.HuntRespawnTime + (PlayerData[Character.Name].HuntRespawnDeaths * StatData.HuntRespawnTimeIncrease)
						else
							if not PlayerData[Character.Name].RaidRespawnDeaths then
								PlayerData[Character.Name].RaidRespawnDeaths = -1
							end
							PlayerData[Character.Name].RaidRespawnDeaths += 1
							
							RespawnTime = StatData.RaidRespawnTime + (PlayerData[Character.Name].RaidRespawnDeaths * StatData.RaidRespawnTimeIncrease)
						end
						
						FactionManager:RemoveArtOfSoulLife(Player)
						FactionManager:RemoveGladiatorLife(Player)
						
						local PathData = {Module = ClientProgression, Skill = "RespawnTimer"}
						local RenderDistance = -1
						NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData, RespawnTime)
					end
				else
					PlayerData[Character.Name].RaidRespawnDeaths = nil
					PlayerData[Character.Name].HuntRespawnDeaths = nil
				end
			end
			
			if Teleported then
				task.delay(3, function()
					Character:SetAttribute("CombatTag", 0)
					Profile.ClientData.CombatLogged = 0
					AntiCheatManager:ClearLastPosition(Player)
					CombatManager:ResetCombatTags(Character, Player)
					CombatManager:ClearAllTags(Character)
					
					Teleports:TeleportParty({Player}, Teleported)
				end)
			else
				task.delay(RespawnTime, function()
					if Player:IsDescendantOf(Players) and not Player:GetAttribute("Menued") then
						Player:LoadCharacter()
						SetupCharacter(Player, Profile)
						CreateAttributes(Player.Character, Profile, EntityID)
						ZanpakutoWeapons:SetupZanpakuto(Player, Profile)
						Ragdoll:Setup(Player.Character)

						EntityManager:UpdateCharacter(EntityID, Player.Character)
						EntityManager:ForceState(Player.Character, "Idle")
						
						DamageTracker:Reset(Character, "Elo")
						DamageTracker:Reset(Character)
						if PlayerData[Character.Name].KnockoutTime then
							PlayerData[Character.Name].KnockoutTime = nil
						end
						
						local SpawnCFrame
						if PlayerData[Character.Name].DeathCFrame then
							SpawnCFrame = PlayerData[Character.Name].DeathCFrame
							PlayerData[Character.Name].DeathCFrame = nil
						elseif not TYPETEST and table.find(AdminWhitelists.Admin, Player.UserId) and not Profile.ClientData.NoAdminSpawn then
							local PalaceSpawn = workspace["Royal Palace"].ModTP.CFrame * CFrame.new(0, 3, 0)
							SpawnCFrame = PalaceSpawn
						elseif FactionManager:IsRaidActive() and not FactionManager:IsHuntActive() then
							local RaidSpawn = workspace.PlayerRaid.SRSpawn.CFrame
							if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
								RaidSpawn = workspace.PlayerRaid.ArrancarSpawn.CFrame
							elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
								RaidSpawn = workspace.PlayerRaid.QuincySpawn.CFrame
							end
							
							if FactionManager:ArtOfSoulActive() and FactionManager:HasArtOfSoulLives(Player) and FactionManager:ArtOfSoulZone() then
								RaidSpawn = workspace.PlayerRaid.ArtOfSoulSpawn.CFrame
							end
							
							SpawnCFrame = RaidSpawn
						elseif StatData.Factions[Profile.ClientData.Race] == "Shinigami" and Profile.Division.Squad > 0 and StatData.SoulSociety then
							local DivisionSpawn = workspace.DivisionSpawns["Division" .. Profile.Division.Squad]
							SpawnCFrame = DivisionSpawn.CFrame * CFrame.new(0, 3, 0)
						elseif StatData.WandenreichCity and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
							local PlayerSpawns = workspace.QuincySpawns:GetChildren()
							local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame

							SpawnCFrame = RandomSpawn * CFrame.new(0, 3, 0)
						else
							local PlayerSpawns = workspace.ShinigamiSpawns:GetChildren()
							local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
	
							SpawnCFrame = RandomSpawn
						end
						
						local AntiProfile = AntiCheatManager:RequestProfile(Player)
						AntiProfile:Initialize(Player.Character, SpawnCFrame)
						
						task.spawn(function()
							ForcefieldOnSpawn(Player.Character)
						end)
						CheckJailed(Player)
						task.spawn(function()
							VisoredTraining(Player.Character, Profile)
						end)
						task.spawn(function()
							BankaiCheck(Player.Character, Profile)
						end)
						task.spawn(function()
							VastoSpeed(Player.Character, Profile)
						end)
						task.spawn(function()
							BlutVene(Player.Character, Profile)
						end)
						task.spawn(function()
							TheFear(Player.Character, Profile)
						end)
						task.spawn(function()
							JugramAllyBuff(Player.Character, Profile)
						end)
						task.spawn(function()
							ReducedRankTimers(Player.Character, Profile)
						end)
						--CaptainAnnounce(Player.Character, Profile)
						SternritterSpec(Player.Character, Profile)
						
						PartialRes(Player.Character, Profile)
						BountyBoardManager:AssignBounty(Player)
						Player.Character:SetAttribute("Respawning", nil)
						
						if not FactionManager:IsGrace() and not FactionManager:IsHuntActive() then
							if FactionManager:ArtOfSoulActive() and not FactionManager:HasArtOfSoulLives(Player) then
								EntityManager:ChangeState(Player.Character, "TriggerSpectator")
							elseif FactionManager:GladiatorActive() and not FactionManager:HasGladiatorLife(Player) then
								EntityManager:ChangeState(Player.Character, "TriggerSpectator")
							end
						end
						
						local CurrentParty = Player:GetAttribute("Party")
						local Party = PartyManager.Parties[CurrentParty]
						if Party then
							local PartyMembers = Party.Members
							local ClientParty = ReplicatedStorage.Modules.ClientModules.ClientParty
							local RefreshPathData = {Module = ClientParty, Skill = "Refresh"}
							local RenderDistance = -1

							local PartyPosition
							for i, v in ipairs(PartyMembers) do
								if v == Player then
									PartyPosition = i
									break
								end
							end

							for i, Members in ipairs(PartyMembers) do
								NetworkManager.FireClient(Members, Members.Character, "ClientEffects", RenderDistance, RefreshPathData, PartyPosition, Player.Character)
							end
						end

						ReplicatedStorage.Remotes.DisableBlur:FireClient(Player)
					end
				end)
			end
		end)
	end)
	
	Player:LoadCharacter()
	SetupCharacter(Player, Profile)
	CreateAttributes(Player.Character, Profile, EntityID)
	ZanpakutoWeapons:SetupZanpakuto(Player, Profile)
	Ragdoll:Setup(Player.Character)
	
	EntityManager:ForceState(Player.Character, "Idle")
	
	if Profile.ClientData.LoggedPlace ~= StatData.Places[game.PlaceId] then
		Profile.ClientData.LoggedPosition = false
	end
	Profile.ClientData.LoggedPlace = StatData.Places[game.PlaceId]
	local LoggedPosition = Profile.ClientData.LoggedPosition
	
	local SpawnCFrame
	if not TYPETEST and table.find(AdminWhitelists.Admin, Player.UserId) and not Profile.ClientData.NoAdminSpawn then
		local PalaceSpawn = workspace["Royal Palace"].ModTP.CFrame * CFrame.new(0, 3, 0)

		SpawnCFrame = PalaceSpawn
	elseif FactionManager:IsRaidActive() and not FactionManager:IsHuntActive() then
		local RaidSpawn = workspace.PlayerRaid.SRSpawn.CFrame
		if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
			RaidSpawn = workspace.PlayerRaid.ArrancarSpawn.CFrame
		elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			RaidSpawn = workspace.PlayerRaid.QuincySpawn.CFrame
		end
		
		if FactionManager:ArtOfSoulActive() and FactionManager:HasArtOfSoulLives(Player) and FactionManager:ArtOfSoulZone() then
			RaidSpawn = workspace.PlayerRaid.ArtOfSoulSpawn.CFrame
		end
		
		SpawnCFrame = RaidSpawn
	elseif LoggedPosition ~= false then
		local Position = Vector3.new(LoggedPosition[1], LoggedPosition[2], LoggedPosition[3])

		SpawnCFrame = CFrame.new(Position)
	else
		if StatData.Factions[Profile.ClientData.Race] == "Shinigami" and Profile.Division.Squad > 0 and StatData.SoulSociety then
			local DivisionSpawn = workspace.DivisionSpawns["Division" .. Profile.Division.Squad]
			
			SpawnCFrame = DivisionSpawn.CFrame * CFrame.new(0, 3, 0)
		elseif StatData.WandenreichCity and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			local PlayerSpawns = workspace.QuincySpawns:GetChildren()
			local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
			
			SpawnCFrame = RandomSpawn * CFrame.new(0, 3, 0)
		else
			local PlayerSpawns = workspace.ShinigamiSpawns:GetChildren()
			local RandomSpawn = PlayerSpawns[math.random(1, #PlayerSpawns)].CFrame
			
			SpawnCFrame = RandomSpawn
		end
	end
	
	local AntiProfile = AntiCheatManager:RequestProfile(Player)
	AntiProfile:Initialize(Player.Character, SpawnCFrame)
	
	task.spawn(function()
		ForcefieldOnSpawn(Player.Character)
	end)
	CheckJailed(Player)
	task.spawn(function()
		VisoredTraining(Player.Character, Profile)
	end)
	task.spawn(function()
		BankaiCheck(Player.Character, Profile)
	end)
	task.spawn(function()
		VastoSpeed(Player.Character, Profile)
	end)
	task.spawn(function()
		BlutVene(Player.Character, Profile)
	end)
	task.spawn(function()
		TheFear(Player.Character, Profile)
	end)
	task.spawn(function()
		JugramAllyBuff(Player.Character, Profile)
	end)
	task.spawn(function()
		ReducedRankTimers(Player.Character, Profile)
	end)
	--CaptainAnnounce(Player.Character, Profile)
	SternritterSpec(Player.Character, Profile)
	PartialRes(Player.Character, Profile)
	BountyBoardManager:AssignBounty(Player)
	Player.Character:SetAttribute("Respawning", nil)
	
	if Profile.ServerData.FirstLoad then
		ReplicatedStorage.Remotes.ChooseName:FireClient(Player, "Disabled")
	else
		--Player.PlayerGui.DisplayUI.Enabled = true
	end
	
	AntiCheatManager:PlayerLoaded(Player)
	
	if not FactionManager:IsGrace() and not FactionManager:IsHuntActive() then
		if FactionManager:ArtOfSoulActive() and not FactionManager:HasArtOfSoulLives(Player) then
			Player.Character:SetAttribute("Spectator", true)
		elseif FactionManager:GladiatorActive() and not FactionManager:HasGladiatorLife(Player) then
			Player.Character:SetAttribute("Spectator", true)
		end
	end
	
	FactionManager:EnableUI(Player)
	
	local PlayerDisconnected 
	PlayerDisconnected = Player.Destroying:Connect(function()
		if PlayerData[Player.Name].ZombieData then
			for i, v in pairs(PlayerData[Player.Name].ZombieData.Connections) do
				PlayerData[Player.Name].ZombieData.Connections[i]:Disconnect()
				PlayerData[Player.Name].ZombieData.Connections[i] = nil
			end
			PlayerData[Player.Name].ZombieData = nil
		end
		if PlayerData[Player.Name].VisionaryData then
			for i, v in pairs(PlayerData[Player.Name].VisionaryData.Connections) do
				PlayerData[Player.Name].VisionaryData.Connections[i]:Disconnect()
				PlayerData[Player.Name].VisionaryData.Connections[i] = nil
			end
			for i, v in ipairs(PlayerData[Player.Name].VisionaryData.Clones) do
				task.spawn(function()
					EntityManager:ChangeState(v, "TriggerUnconscious")
				end)
			end
			PlayerData[Player.Name].VisionaryData = nil
		end
		if PlayerData[Player.Name].CheerBuddy then
			task.spawn(function()
				EntityManager:ChangeState(PlayerData[Player.Name].CheerBuddy, "TriggerUnconscious")
			end)
			PlayerData[Player.Name].CheerBuddy = nil
		end
		
		for i, v in pairs(PlayerData[Player.Name].Connections) do
			PlayerData[Player.Name].Connections[i]:Disconnect()
			PlayerData[Player.Name].Connections[i] = nil
		end
		
		if PlayerData[Player.Name].ShikaiActiveData then
			if PlayerData[Player.Name].ShikaiActiveData.Connections then
				for i, v in pairs(PlayerData[Player.Name].ShikaiActiveData.Connections) do
					PlayerData[Player.Name].ShikaiActiveData.Connections[i]:Disconnect()
					PlayerData[Player.Name].ShikaiActiveData.Connections[i] = nil
				end
			end
			PlayerData[Player.Name].ShikaiActiveData = nil
		end
		if PlayerData[Player.Name].BankaiActiveData then
			if PlayerData[Player.Name].BankaiActiveData.Connections then
				for i, v in pairs(PlayerData[Player.Name].BankaiActiveData.Connections) do
					PlayerData[Player.Name].BankaiActiveData.Connections[i]:Disconnect()
					PlayerData[Player.Name].BankaiActiveData.Connections[i] = nil
				end
			end
			PlayerData[Player.Name].BankaiActiveData = nil
		end
		
		for i, v in pairs(PlayerData[Player.Name]) do
			if typeof(v) == "RBXScriptConnection" then -- disconnects any existing connections to prevent memory leaks
				PlayerData[Player.Name][i]:Disconnect()
				PlayerData[Player.Name][i] = nil
			else
				PlayerData[Player.Name][i] = nil
			end
		end
		PlayerData[Player.Name] = nil
		PlayerDisconnected:Disconnect()
		PlayerDisconnected = nil
	end)
	
	return Player.Character
end

return ShinigamiData
