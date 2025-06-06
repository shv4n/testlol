local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Humanoid = script.Parent.Humanoid
local Character = script.Parent
local Player = Players:GetPlayerFromCharacter(script.Parent)
if Player == nil then
	script:Destroy()
	return
end

local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local SkillData = require(ServerStorage.Modules.Utility.SkillData)
local PositionTitles = require(ServerStorage.Modules.Utility.FactionPositions)
local AntiCheatManager = require(ServerStorage.Modules.Managers.AntiCheatManager)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local PlayerBonus = require(ServerStorage.Modules.Utility.PlayerBonus)
local FactionManager = require(ServerStorage.Modules.Managers.FactionManager)
local DamageTracker = require(ServerStorage.Modules.Utility.DamageTracker)

local Profile = DataManager:RequestProfile(Player)

local RadiusConnection
local NearbyEntities = 0
local YhwachPlayerHealthCap = 20
local YhwachAmountPerPlayer = 0.15 / 10

local VastoRegenRate = 1 / 10
--local VastoRegen = 0.005 / 10
local VastoRegen = StatData.VastocarHealthRegen / 10
local VastoAccumulated = 0
local VastoRegeneration

local RegenRate = 1 / 10
local HealthRegen = 0.025 / 10
local Accumulated = 0
local HealthRegeneration

local ReiatsuRate = 1 / 10
local ReiatsuRegen = 0.008 / 10
local ReiatsuRegeneration
local ReiatsuAccumulated = 0

local PostureRegen = 0.2
local PassivePostureRegen

local Clan = Profile.ClientData.Clan
local ClanBuffs = ClanData[Clan].ClanBuff
if ClanBuffs and ClanBuffs.PostureRegen then
	PassivePostureRegen = ClanBuffs.PostureRegen / 10
end
if ClanBuffs and ClanBuffs.ReiatsuRegen then
	ReiatsuRegen += ReiatsuRegen * ClanBuffs.ReiatsuRegen
end

local AccessoryRegen = PlayerBonus:AccessoryReiRegen(Player, ReiatsuRegen)

local RegenFunction = function(DeltaTime)
	Accumulated += DeltaTime
	if Accumulated >= RegenRate and not Character:GetAttribute("RegenDisabled") and Character:GetAttribute("CurrentState") ~= "Unconscious" and not Character:GetAttribute("WeakerIttoKaso") then
		Accumulated -= RegenRate
		if Humanoid.Health + (Humanoid.MaxHealth * HealthRegen) < Humanoid.MaxHealth then
			Humanoid.Health += (Humanoid.MaxHealth * HealthRegen)
			if Humanoid.Health > (Humanoid.MaxHealth * 0.3) then
				PassivesManager:ResetBaseWalkspeed(Character)
			end
		else
			Humanoid.Health = Humanoid.MaxHealth
		end
		if Character:GetAttribute("Reiatsu") and Character:GetAttribute("MaxReiatsu") and Humanoid.Health > 0 and not Character:GetAttribute("ReiatsuDisabled") then
			if Character:GetAttribute("Reiatsu") + (Character:GetAttribute("MaxReiatsu") * (ReiatsuRegen * 3)) < Character:GetAttribute("MaxReiatsu") then
				Character:SetAttribute("Reiatsu", Character:GetAttribute("Reiatsu") + Character:GetAttribute("MaxReiatsu") * (ReiatsuRegen * 3))
			else
				Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
			end
		end
		if Character:GetAttribute("Posture") - PostureRegen > 0 then
			Character:SetAttribute("Posture", Character:GetAttribute("Posture") - PostureRegen)
		else
			Character:SetAttribute("Posture", 0)
		end
	end
end

local ReiatsuRegenFunction = function(DeltaTime)
	ReiatsuAccumulated += DeltaTime
	if ReiatsuAccumulated >= ReiatsuRate then
		ReiatsuAccumulated -= ReiatsuRate
		if not Character:GetAttribute("ReiatsuDisabled") and not Character:GetAttribute("SelfHealing") and Character:GetAttribute("Reiatsu") and Character:GetAttribute("MaxReiatsu") and Humanoid.Health > 0 and not Character:GetAttribute("HighSpeedRegen") and not Character:GetAttribute("VampireEcho") then
			local Regen = ReiatsuRegen
			if Character:GetAttribute("EyepatchRemoved") then
				Regen += ReiatsuRegen * SkillData["Eyepatch Removal"].ReiRegenIncrease
			end
			if Character:GetAttribute("VisoredReiatsu") or (Character:GetAttribute("VisoredDownsideReiatsu") and Character:GetAttribute("VisoredMastered") == true) then
				Regen += ReiatsuRegen * StatData.VisoredData.Buffs.Reiatsu
			end
			if (Character:GetAttribute("VisoredDownsideReiatsu") and Character:GetAttribute("VisoredMastered") == false) then
				Regen -= ReiatsuRegen * StatData.VisoredData.Downsides.Reiatsu
			end
			local PreservedReserves = PassivesManager:RequestPassives(Character).PreservedReserves
			if PreservedReserves then
				Regen += ReiatsuRegen * SkillData["Preserved Reserves"].ReiIncrease
			end
			if Character:GetAttribute("ResRegen") then
				Regen += ReiatsuRegen * Character:GetAttribute("ResRegen")
			end
			if Character:GetAttribute("VollstandigRegen") then
				Regen += ReiatsuRegen * Character:GetAttribute("VollstandigRegen")
			end
			if Character:GetAttribute("LetztStilActive") then
				Regen += ReiatsuRegen * StatData.LetztStilReiatsuRegen
			end
			if AccessoryRegen then
				Regen += ReiatsuRegen * AccessoryRegen
			end
			if Character:GetAttribute("ArterieRegen") then
				Regen += ReiatsuRegen * Character:GetAttribute("ArterieRegen")
			end
			if Character:GetAttribute("ReiatsuDebuff") then
				Regen = 0
			end
			
			local ReiatsuRestore = Character:GetAttribute("Reiatsu") + Character:GetAttribute("MaxReiatsu") * Regen
			
			if ReiatsuRestore < Character:GetAttribute("MaxReiatsu") then
				Character:SetAttribute("Reiatsu", ReiatsuRestore)
			else
				Character:SetAttribute("Reiatsu", Character:GetAttribute("MaxReiatsu"))
			end
		end
		
		if not Character:GetAttribute("AntiHeal") then
			if RadiusConnection then
				local Health = Humanoid.Health
				local HealAmount = NearbyEntities * YhwachAmountPerPlayer
				if Character:GetAttribute("BloodyCanvas") then
					HealAmount *= Character:GetAttribute("BloodyCanvas")
				end
				Health += HealAmount
				if Health < Humanoid.MaxHealth then
					Humanoid.Health = Health
					if Humanoid.Health > (Humanoid.MaxHealth * 0.3) then
						PassivesManager:ResetBaseWalkspeed(Character)
					end
				else
					Humanoid.Health = Humanoid.MaxHealth
				end
			end
			if Character:GetAttribute("CatRegen") then
				local Health = Humanoid.Health
				local HealAmount = Character:GetAttribute("CatRegen")
				if Character:GetAttribute("BloodyCanvas") then
					HealAmount *= Character:GetAttribute("BloodyCanvas")
				end
				Health += HealAmount
				if Health < Humanoid.MaxHealth then
					Humanoid.Health = Health
					if Humanoid.Health > (Humanoid.MaxHealth * 0.3) then
						PassivesManager:ResetBaseWalkspeed(Character)
					end
				else
					Humanoid.Health = Humanoid.MaxHealth
				end
			end
		end
		if PassivePostureRegen and Character:GetAttribute("Posture") and not Character:GetAttribute("PostureDisabled") then
			if Character:GetAttribute("Posture") - PassivePostureRegen > 0 then
				Character:SetAttribute("Posture", Character:GetAttribute("Posture") - PassivePostureRegen)
			else
				Character:SetAttribute("Posture", 0)
			end
		end
	end
end

local CombatTags = {}
local CombatTagTimer
local CollectionService = game:GetService("CollectionService")
local TagReference = (Character.Name .. "CombatTag")
local PlayerTagReference = (Character.Name .. "PlayerCombatTag")
local SternritterTagReference = (Character.Name .. "SternritterCombatTag")

local TimeAccumulated = 0 
local TagCheckRate = 20 -- at least an even number
local CombatTagFunction = function(DeltaTime)
	TimeAccumulated += DeltaTime	
	if TimeAccumulated >= TagCheckRate then
		TimeAccumulated -= TagCheckRate
		for CombatTagOwner, Info in pairs(CombatTags) do
			local Time = Info.Time
			
			if Character:GetAttribute("Carried") == CombatTagOwner.Name then
				Time = DateTime.now().UnixTimestamp
			end
			
			local TagDuration = StatData.CombatTagDuration.Default
			if Info.Sternritter then
				TagDuration = StatData.CombatTagDuration.Sternritter
			elseif Info.Player and not Info.PartyMember then
				TagDuration = StatData.CombatTagDuration.Player
			end
			
			if DateTime.now().UnixTimestamp - Time >= TagDuration then -- Checks if the time has been 60 seconds or more.
				CombatTags[CombatTagOwner] = nil -- Removes the timer for the AttackOwner from the table
				if CollectionService:HasTag(CombatTagOwner, TagReference) then -- Checks if the AttackOwner still has the tag on them and removes it.
					CollectionService:RemoveTag(CombatTagOwner, TagReference)
				end
				if Info.Player and CollectionService:HasTag(CombatTagOwner, PlayerTagReference) then
					CollectionService:RemoveTag(CombatTagOwner, PlayerTagReference)
				end
				if Info.Sternritter and CollectionService:HasTag(CombatTagOwner, SternritterTagReference) then
					CollectionService:RemoveTag(CombatTagOwner, SternritterTagReference)
				end
			end
		end
	end
end

local Kenpachi = Profile.ClientData.ZanpakutoWeapon == "Nozarashi"
local NozarashiRate = 1
local NozarashiAccumulated = 0
local NozarashiTimer
local NozarashiFunction = function(DeltaTime)
	NozarashiAccumulated += DeltaTime
	if NozarashiAccumulated > NozarashiRate then
		NozarashiAccumulated -= NozarashiRate
		Profile.ClientData.NozarashiReqs.CombatDuration += 1 / 60
	end
end

Character:WaitForChild("CharacterHandler"):WaitForChild("Remotes").CombatTagEvent.Event:Connect(function(AttackOwner, ReducedTime)
	local TagInstance = AttackOwner
	
	local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
	if PlayerAttacker then
		TagInstance = PlayerAttacker
		
		if Kenpachi then
			local AttackerProfile = DataManager:RequestProfile(PlayerAttacker)
			if AttackerProfile.ClientData.Title == "Captain of the 4th Division" and typeof(NozarashiTimer) ~= "RBXScriptConnection" then
				NozarashiTimer = RunService.Heartbeat:Connect(NozarashiFunction)
			end
		end
	end
	local Sternritter
	if Player then
		if AttackOwner:GetAttribute("CorruptMenos") or AttackOwner:GetAttribute("MimicOwner") then -- AttackOwner:GetAttribute("Sternritter")
			Sternritter = true
		end
	end
	
	if typeof(CombatTagTimer) ~= "RBXScriptConnection" then
		CombatTagTimer = RunService.Heartbeat:Connect(CombatTagFunction)
		Character:SetAttribute("CombatTag", 1)
	end
	if PlayerAttacker and Character:GetAttribute("PlayerCombatTag") <= 0 then
		Character:SetAttribute("PlayerCombatTag", 1)
	end
	if Sternritter and Character:GetAttribute("SternritterCombatTag") <= 0 then
		Character:SetAttribute("SternritterCombatTag", 1)
	end
	
	if not CollectionService:HasTag(TagInstance, TagReference) then
		CollectionService:AddTag(TagInstance, TagReference)
	end
	if Player and not CollectionService:HasTag(TagInstance, PlayerTagReference) then
		CollectionService:AddTag(TagInstance, PlayerTagReference)
	end
	if Sternritter and not CollectionService:HasTag(TagInstance, SternritterTagReference) then
		CollectionService:AddTag(TagInstance, SternritterTagReference)
	end
	
	local Info = {
		Time = DateTime.now().UnixTimestamp;
		Player = false;
		Sternritter = false;
		PartyMember = false;
	}

	if PlayerAttacker then
		Info.Player = true
		
		if Player then
			if Player:GetAttribute("Party") and PlayerAttacker:GetAttribute("Party") == Player:GetAttribute("Party") then
				Info.PartyMember = true
			end
		end
	end
	if Sternritter then
		Info.Sternritter = true
	end

	CombatTags[TagInstance] = Info
end)

--[[CollectionService:GetInstanceAddedSignal(TagReference):Connect(function(TagInstance)
	local TagPlayer = TagInstance:IsDescendantOf(Players)
	local Sternritter
	if TagPlayer and TagInstance.Character:GetAttribute("Sternritter") then
		Sternritter = true
	end
	
	if typeof(CombatTagTimer) ~= "RBXScriptConnection" then
		CombatTagTimer = RunService.Heartbeat:Connect(CombatTagFunction)
		Character:SetAttribute("CombatTag", 1)
	end

	if TagPlayer and Character:GetAttribute("PlayerCombatTag") <= 0 then
		Character:SetAttribute("PlayerCombatTag", 1)
	end
	if Sternritter and Character:GetAttribute("SternritterCombatTag") <= 0 then
		Character:SetAttribute("SternritterCombatTag", 1)
	end
	
	local Info = {
		Time = DateTime.now().UnixTimestamp;
		Player = false;
		Sternritter = false;
	}
	
	if TagPlayer then
		Info.Player = true
	end
	if Sternritter then
		Info.Sternritter = true
	end
	
	CombatTags[TagInstance] = Info
end)]]

CollectionService:GetInstanceRemovedSignal(TagReference):Connect(function(TagInstance)
	if typeof(CombatTagTimer) == "RBXScriptConnection" and CombatTagTimer.Connected then
		local TotalTags = CollectionService:GetTagged(TagReference)
		if not TotalTags or #TotalTags <= 0 then
			CombatTagTimer:Disconnect() 
			CombatTagTimer = nil
			
			if NozarashiTimer then
				NozarashiTimer:Disconnect()
				NozarashiTimer = nil
			end
			
			Character:SetAttribute("CombatTag", 0)
			DamageTracker:Reset(Character, "Elo")
		end
		--warn(TagReference .. " removed from " .. TagInstance.Name)
		--warn(TagReference .. "_TAGS:", #TotalTags)
	end
end)

CollectionService:GetInstanceRemovedSignal(PlayerTagReference):Connect(function(TagInstance)
	local TotalTags = CollectionService:GetTagged(PlayerTagReference)
	if not TotalTags or #TotalTags <= 0 then
		Character:SetAttribute("PlayerCombatTag", 0)
	end
end)

CollectionService:GetInstanceRemovedSignal(SternritterTagReference):Connect(function(TagInstance)
	local TotalTags = CollectionService:GetTagged(SternritterTagReference)
	if not TotalTags or #TotalTags <= 0 then
		Character:SetAttribute("SternritterCombatTag", 0)
	end
end)

Character:GetAttributeChangedSignal("CombatTag"):Connect(function()
	if Character:GetAttribute("CombatTag") <= 0 then
		DataManager:ModifyProfile(Player, "ClientData", "CombatLogged", 0) -- 0 means out of combat
		ReplicatedStorage.Remotes.CooldownUIUpdate:FireClient(Player, "CombatTag")
		HealthRegeneration = RunService.Heartbeat:Connect(RegenFunction)
		return
	end
	
	if typeof(HealthRegeneration) == "RBXScriptConnection" and HealthRegeneration.Connected then
		HealthRegeneration:Disconnect()
		HealthRegeneration = nil
		DataManager:ModifyProfile(Player, "ClientData", "CombatLogged", 1) -- 1 means in combat
		ReplicatedStorage.Remotes.CooldownUIUpdate:FireClient(Player, "CombatTag")
	end
end)

ReiatsuRegeneration = RunService.Heartbeat:Connect(ReiatsuRegenFunction)


local ShinigamiRank = Profile.ClientData.ShinigamiRank
local Race = Profile.ClientData.Race
local VastocarRoll = Profile.ClientData.VastocarRoll
if Profile.ClientData.WeakVasto then
	VastocarRoll = nil
end

if StatData.Factions[Race] == "Shinigami" then
	ReiatsuRegen += (ReiatsuRegen * StatData.ShinigamiBonusRegen)
end

if Race == "Vastocar" and VastocarRoll == 2 then -- RANKBASED
	ReiatsuRegen += (ReiatsuRegen * StatData.SpecialRaceBuffs.BonusReiatsuRegen)
	task.spawn(function()
		while true do
			while Character.Humanoid.Health < Character.Humanoid.MaxHealth do
				local Step = task.wait()
				
				VastoAccumulated += Step
				if VastoAccumulated >= VastoRegenRate then
					VastoAccumulated -= VastoRegenRate
					--local Health = Humanoid.MaxHealth * VastoRegen
					local Health = VastoRegen
					if Character:GetAttribute("HSPCut") or FactionManager:GladiatorActive() then
						Health *= StatData.VastocarHealthCut
					end
					if Character:GetAttribute("AntiHeal") then
						Health = 0
					end
					if Character:GetAttribute("BloodyCanvas") then
						Health *= Character:GetAttribute("BloodyCanvas")
					end

					if Health > 0 then
						local HealthRegened = Humanoid.Health + Health
						if HealthRegened < Humanoid.MaxHealth then
							Humanoid.Health = HealthRegened
							if Humanoid.Health > (Humanoid.MaxHealth * 0.3) then
								PassivesManager:ResetBaseWalkspeed(Character)
							end
						else
							Humanoid.Health = Humanoid.MaxHealth
						end
					end
				end
			end
			Character.Humanoid.HealthChanged:Wait()
		end
	end)
elseif Race == "Visored" then
	--ReiatsuRegen += (ReiatsuRegen * StatData.SpecialRaceBuffs.BonusReiatsuRegen)
end
if table.find(PositionTitles.ShinigamiCaptainTitles, Profile.ClientData.Title) then
	ReiatsuRegen += (ReiatsuRegen * PositionTitles.CaptainTitleBonus.ReiatsuRegenBonus)
elseif table.find(PositionTitles.ArrancarEspadaTitles, Profile.ClientData.Title) then
	ReiatsuRegen += (ReiatsuRegen * PositionTitles.EspadaTitleBonus.ReiatsuRegenBonus)
elseif table.find(PositionTitles.SternritterTitles, Profile.ClientData.Title) then
	ReiatsuRegen += (ReiatsuRegen * PositionTitles.SternritterTitleBonus.ReiatsuRegenBonus)
elseif Profile.ClientData.Title == "Leader of the Royal Guard" or Profile.Division.Squad == 0 and StatData.Factions[Race] == "Shinigami" then
	ReiatsuRegen += PositionTitles.RoyalGuardTitleBonus.ReiatsuRegenBonus
end

local Yhwach = 77857290

if Yhwach and Player.UserId == Yhwach then
	local Rate = 5
	local Accumulated = 0
	RadiusConnection = RunService.Heartbeat:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		if Accumulated > Rate then
			Accumulated -= Rate
			
			local NearbyPlayers = 0
			for i, v in ipairs(Players:GetPlayers()) do
				if v:IsDescendantOf(Players) then
					task.spawn(function()
						local AttackOwnerParty = v:GetAttribute("Party")
						local CharacterParty = Player:GetAttribute("Party")

						if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
							local Magnitude = (v.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
							if Magnitude <= 150 then
								if AttackOwnerParty ~= nil and CharacterParty ~= nil then
									if AttackOwnerParty ~= CharacterParty then
										NearbyPlayers += 1
									end
								else
									NearbyPlayers += 1
								end
							end
						end
					end)
				end
			end
			
			if NearbyPlayers > YhwachPlayerHealthCap then
				NearbyPlayers = YhwachPlayerHealthCap
			end
			NearbyEntities = NearbyPlayers
		end
	end)
end
