-- Services --
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Modules --
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local PartyManager = require(ServerStorage.Modules.Managers.PartyManager)
local InventoryManager = require(ServerStorage.Modules.Managers.InventoryManager)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local CombatManager = require(ServerStorage.Modules.Managers.CombatManager)
local QueueManager = require(ServerStorage.Modules.Managers.QueueManager)
local Teleports = require(ServerStorage.Modules.Utility.Teleports)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local ProductFunctions = require(ServerStorage.Modules.Utility.ProductFunctions)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local Webhooks = require(ServerStorage.Modules.Utility.Webhooks)
local FactionManager = require(ServerStorage.Modules.Managers.FactionManager)
local AntiCheatManager = require(ServerStorage.Modules.Managers.AntiCheatManager)
local ServerSkills = require(ServerStorage.Modules.SkillModules.Skills.ServerSkills)
local PositionTitles = require(ServerStorage.Modules.Utility.FactionPositions)
local QuincyMedallions = require(ServerStorage.Modules.Utility.QuincyMedallions)
local JailManager = require(ServerStorage.Modules.Managers.JailManager)
local VollstandigAccessories = require(ServerStorage.Modules.Utility.VollstandigAccessories)
local TradeManager = require(ServerStorage.Modules.Managers.TradeManager)
local TradesableData = require(ServerStorage.Modules.Utility.TradeablesData)
local Codes = require(ServerStorage.Modules.Utility.Codes)

-- Player References --
--local Character = script.Parent
--local Player = Players:GetPlayerFromCharacter(Character)

-- Folders and Data References --
local SharedRemotes = ReplicatedStorage.Remotes
local ClientRemotes = script.Remotes

local RequiredZanpakutoState = {
	Arrancar = 0;
	Vastocar = 0;
	Shinigami = 1;
	Visored = 1;
	Quincy = 0;
}

-- Variables --
local ShikaiConnection

-- Main Code --

local function Zombified(Character)
	local Zombified
	if Character:GetAttribute("ControlsDisabled") or Character:GetAttribute("Zombification") or Character:GetAttribute("PartialResQuest") then
		Zombified = true
	end
	return Zombified
end

ClientRemotes.ShikaiSkill.OnServerEvent:Connect(function(Player, KeyPressed, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "ShikaiSkill")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		local SkillAllowed
		if not Character:GetAttribute("ShikaiDisabled") and not Character:GetAttribute("BloodArt") and not Character:GetAttribute("BouncingBomb") then
			if Character:GetAttribute("ZanpakutoState") >= 1 or Character:GetAttribute("PartialRes") == KeyPressed or Character:GetAttribute("PartialRes2") == KeyPressed or (Character:GetAttribute("VollstandigBypass") and not Character:GetAttribute("QuincyDisabled")) then
				SkillAllowed = true
			end
		end
		
		if SkillAllowed then
			if InputType == "Pressed" then
				EntityManager:ChangeState(Character, "TriggerShikaiSkill", KeyPressed)
			elseif InputType == "Released" then
				EntityManager:ChangeState(Character, "SkillReleaseFromHeld", KeyPressed)
			end
		end
	end
end)

ClientRemotes.BankaiSkill.OnServerEvent:Connect(function(Player, KeyPressed, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "BankaiSkill")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		local SkillAllowed
		
		local Schrift
		local Profile = DataManager:RequestProfile(Player)
		if StatData.Factions[Profile.ClientData.Race] == "Quincy" and Profile.ClientData.ShikaiUnlocked then
			Schrift = true
		end
		
		if not Character:GetAttribute("ShikaiDisabled") and not Character:GetAttribute("BouncingBomb") then
			if Character:GetAttribute("ZanpakutoState") >= 2 or (Character:GetAttribute("VollstandigBankaiBypass") and not Character:GetAttribute("QuincyDisabled")) or Schrift then
				SkillAllowed = true
			end
			if Character:GetAttribute("BloodArt") and KeyPressed ~= "T" then
				SkillAllowed = nil
			end
		end

		if SkillAllowed then
			if InputType == "Pressed" then
				EntityManager:ChangeState(Character, "TriggerShikaiSkill", KeyPressed)
			elseif InputType == "Released" then
				EntityManager:ChangeState(Character, "SkillReleaseFromHeld", KeyPressed)
			end
		end
	end
end)

ClientRemotes.Skill.OnServerEvent:Connect(function(Player, KeyPressed, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "Skill")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		local SkillDisabled
		if Character:GetAttribute("SkillDisabled") or Character:GetAttribute("BloodArt") or Character:GetAttribute("BouncingBomb") then
			SkillDisabled = true
		end
		local Nameless = {
			Six = true;
			Seven = true;
			Eight = true;
			Nine = true;
			Zero = true;
			Minus = true;
			Equals = true;
		}

		if Character:GetAttribute("Nameless") and Nameless[KeyPressed] then
			SkillDisabled = true
		end
		
		if not SkillDisabled then
			if InputType == "Pressed" then
				EntityManager:ChangeState(Character, "TriggerSkill", KeyPressed)
			elseif InputType == "Released" then
				EntityManager:ChangeState(Character, "SkillReleaseFromHeld", KeyPressed)
			end
		end
	end
end)

ClientRemotes.M2.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "M2")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		EntityManager:ChangeState(Character, "TriggerM2")
	end
end)

local CarryCD = false

ClientRemotes.Carry.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "Carry")
	
	if CarryCD then
		return
	end
	
	CarryCD = true
	task.delay(0.3, function()
		CarryCD = false
	end)
	
	local Character = Player.Character
	if not Zombified(Character) then
		EntityManager:ChangeState(Character, "TriggerCarry")
	end
end)

local GripCD = false

ClientRemotes.Execute.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "Execute")
	
	if GripCD then
		return
	end
	GripCD = true
	task.delay(0.1, function()
		GripCD = false
	end)
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		if not Character:GetAttribute("GripDisabled") then
			EntityManager:ChangeState(Character, "TriggerExecute")
		end
	end
end)

local CatWeld
local CatSit
local CatCD = false
local CatConnection

ClientRemotes.Block.OnServerEvent:Connect(function(Player, InputType, ...)
	AntiCheatManager:CheckRemoteHistory(Player, "Block")
	
	local Arguments = {Number = select("#", ...), ...}
	if Arguments.Number ~= 1 then
		ServerStorage.Remotes.DelayBanEvent:Fire(Player, "autoparry")
	end
	
	local Character = Player.Character
	if Character:GetAttribute("CatState") then
		if CatCD then
			return
		end

		CatCD = true
		task.delay(0.5, function()
			CatCD = false
		end)

		local Sitting = Character:GetAttribute("Sitting") or false
		if Sitting then
			CatWeld:Destroy()
			CatWeld = nil

			Character:SetAttribute("Sitting", nil)
			Character:SetAttribute("TrueIFrames", nil)

			CatSit:SetAttribute("CatDefense", nil)
			CatSit:SetAttribute("CatDamage", nil)
			CatSit:SetAttribute("CatRegen", nil)
			CatSit = nil

			if CatConnection then
				CatConnection:Disconnect()
				CatConnection = nil
			end

			Character.Humanoid.AutoRotate = true

			for i, v in ipairs(Character:GetChildren()) do
				if v:IsA("BasePart") then
					v.Massless = false
					if v:CanSetNetworkOwnership() then
						v:SetNetworkOwner(Player)
					end
				end
			end

			ReplicatedStorage.Remotes.PlayerControlEvent:FireClient(Player, "Enabled")
		else
			local ClosestPlayerFromMouse = SharedFunctions:GetTargetByMouse(Player, 20, 30)
			if ClosestPlayerFromMouse and Players:GetPlayerFromCharacter(ClosestPlayerFromMouse) then
				local CurrentFaction = StatData.Factions[ClosestPlayerFromMouse:GetAttribute("EntityType")]
				if StatData.CurrentFactions[CurrentFaction] then
					Character:SetAttribute("Sitting", true)

					Character:SetAttribute("TrueIFrames", true)
					Character.Humanoid.AutoRotate = false

					local Weld = Instance.new("Weld")
					Weld.C0 = CFrame.new(-4.29153442e-05, -3.52576399, -0.0196824074, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					Weld.Part0 = Character.HumanoidRootPart
					Weld.Part1 = ClosestPlayerFromMouse.Head
					Weld.Name = "CatWeld"
					Weld.Parent = Character.HumanoidRootPart

					CatWeld = Weld
					CatSit = ClosestPlayerFromMouse

					CatSit:SetAttribute("CatDefense", 0.7)
					CatSit:SetAttribute("CatDamage", 0.3)
					CatSit:SetAttribute("CatRegen", 4)

					local PlayerTarget = Players:GetPlayerFromCharacter(ClosestPlayerFromMouse)

					for i, v in ipairs(Character:GetChildren()) do
						if v:IsA("BasePart") then
							v.Massless = true
							if v:CanSetNetworkOwnership() then
								v:SetNetworkOwner(PlayerTarget)
							end
						end
					end

					CatConnection = Player.CharacterRemoving:Connect(function()
						if CatConnection then
							CatConnection:Disconnect()
							CatConnection = nil
						end

						CatSit:SetAttribute("CatDefense", nil)
						CatSit:SetAttribute("CatDamage", nil)
						CatSit:SetAttribute("CatRegen", nil)
					end)

					ReplicatedStorage.Remotes.PlayerControlEvent:FireClient(Player, "Disabled")
				end
			end
		end
	else
		if not Zombified(Character) and not Character:GetAttribute("ParryDisabled") then
			if InputType == "Pressed" then
				EntityManager:ChangeState(Character, "TriggerParry")
			elseif InputType == "Released" then
				EntityManager:ChangeState(Character, "ReleaseBlock")
			end
		end
	end
end)


ClientRemotes.Sprint.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "Sprint")
	
	local Character = Player.Character
	if not Zombified(Character) then
		if not Character:GetAttribute("SprintDisabled") then
			if InputType == "Pressed" then
				EntityManager:ChangeState(Character, "TriggerSprint")
			elseif InputType == "Released" then
				EntityManager:ChangeState(Character, "StopSprint")
			end
		end
	end
end)

ClientRemotes.Flashstep.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "Flashstep")
	
	local PlayerProfile = DataManager:RequestProfile(Player)
	local Character = Player.Character
	
	local function Extinguish(Player)
		local Overtimes = CombatManager:GetOvertimes(Player)
		if Overtimes then
			local Burn = CombatManager:GetOvertimes(Player).Burn
			if Burn then
				CombatManager:CancelOvertime(Character, "Burn")
			end
		end
	end
	
	local HollowFlashstep
	if PlayerProfile.ClientData.Race == "Hollow" then
		if PlayerProfile.ClientData.ShinigamiRank == 15 then
			HollowFlashstep = true
		end
		if PlayerProfile.ClientData.ShinigamiRank == 17 and Character:GetAttribute("CorruptMenos") then
			HollowFlashstep = true
		end
	end
	
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		if not Character:GetAttribute("FlashstepDisabled") and not Character:GetAttribute("HeavenlyRestriction") then
			if InputType == "Pressed" and table.find(PlayerProfile.UnlockedSkills, "Flashstep") then
				EntityManager:ChangeState(Character, "TriggerFlashstep")
				Extinguish(Player)
			elseif InputType == "Pressed" and HollowFlashstep then
				EntityManager:ChangeState(Character, "TriggerFlashstep")
				Extinguish(Player)
			end
		end
	end
end)


ClientRemotes.LightAttack.OnServerEvent:Connect(function(Player, Time)
	AntiCheatManager:CheckRemoteHistory(Player, "LightAttack")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		EntityManager:ChangeState(Character, "TriggerLAttack")
	end
end) 

ClientRemotes.HeavyAttack.OnServerEvent:Connect(function(Player, Time)
	AntiCheatManager:CheckRemoteHistory(Player, "HeavyAttack")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") then
		EntityManager:ChangeState(Character, "TriggerCAttack")
	end
end) 

ClientRemotes.Dash.OnServerEvent:Connect(function(Player, KeyPressed, ...)
	AntiCheatManager:CheckRemoteHistory(Player, "Dash")
	
	local Arguments = {Number = select("#", ...), ...}
	if Arguments.Number ~= 1 then
		ServerStorage.Remotes.DelayBanEvent:Fire(Player, "autododge")
	end
	
	local Character = Player.Character
	if not Zombified(Character) then
		if not Character:GetAttribute("DashDisabled") and not Character:GetAttribute("CatState") then
			EntityManager:ChangeState(Character, "TriggerDash", KeyPressed)
			local Overtimes = CombatManager:GetOvertimes(Player)
			if Overtimes then
				local Burn = CombatManager:GetOvertimes(Player).Burn
				if Burn then
					CombatManager:CancelOvertime(Character, "Burn")
				end
			end
		end
	end
end) 

ClientRemotes.ReleaseShikai.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "ReleaseShikai")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		local PlayerProfile = DataManager:RequestProfile(Player)
		local Race = PlayerProfile.ClientData.Race
		if PlayerProfile.ClientData.ShikaiUnlocked and StatData.Factions[Race] == "Shinigami" then
			if Character:GetAttribute("ZanpakutoState") == 0 then
				EntityManager:ChangeState(Character, "TriggerShikaiRelease", PlayerProfile.ClientData)
			elseif Character:GetAttribute("ZanpakutoState") == 1 then
				EntityManager:ChangeState(Character, "SheatheWeapon", PlayerProfile.ClientData)
			end
		elseif StatData.Factions[Race] == "Quincy" and PlayerProfile.ClientData.GlobalRank >= 0 and PlayerProfile.ClientData.GlobalRank <= StatData.BankaiRequirements.GlobalRank then
			EntityManager:ChangeState(Character, "TriggerQuincyMedallion", PlayerProfile.ClientData)
		end
	end
end)

local MeditateCD = 0.2
local MeditateDebounce = false

ClientRemotes.Meditate.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "Meditate")
	
	if not MeditateDebounce then
		MeditateDebounce = true
		
		task.delay(MeditateCD, function()
			MeditateDebounce = false
		end)
		
		local Character = Player.Character
		local Player = Players:GetPlayerFromCharacter(Character)
		local Profile = DataManager:RequestProfile(Player)
		
		local MeditateRace = StatData.Factions[Profile.ClientData.Race] == "Shinigami" or StatData.Factions[Profile.ClientData.Race] == "Arrancar"
		
		if not Zombified(Character) and MeditateRace and not Character:GetAttribute("HogyokuFragment") and not Character:GetAttribute("KarakuraFlag") and not Character:GetAttribute("CatState") then
			EntityManager:ChangeState(Character, "TriggerMeditate")
		end
	end
end)

local QuincyMedallionCD

ClientRemotes.ReleaseBankai.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "ReleaseBankai")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		local PlayerProfile = DataManager:RequestProfile(Player)
		
		local BankaiUnlocked = PlayerProfile.ClientData.BankaiUnlocked or PlayerProfile.ClientData.StolenBankai
		if BankaiUnlocked then
			if Character:GetAttribute("ZanpakutoState") == 2 then
				local CurrentFaction = StatData.Factions[PlayerProfile.ClientData.Race]
				if StatData.CurrentFactions[CurrentFaction] and not Character:GetAttribute("BankaiDeactivate") then
					EntityManager:ChangeState(Character, "TriggerBankaiCancel", PlayerProfile.ClientData, true)
				end
			elseif Character:GetAttribute("ZanpakutoState") <= 1 then
				local TimeDifference = DateTime.now().UnixTimestamp - PlayerProfile.ClientData.BankaiTimer
				local BankaiCooldown = StatData.BankaiCooldown * 60
				if StatData.Factions[PlayerProfile.ClientData.Race] == "Arrancar" then
					BankaiCooldown = StatData.ResCooldown * 60
				end

				PlayerProfile.ClientData.BankaiRaidCheck = nil
				PlayerProfile.ClientData.CurrentBankaiRaidCheck = nil
				
				if PlayerProfile.ClientData.QuincyMedallion then
					if not PlayerProfile.ClientData.HollowCandyCutscene and Player.UserId == 57431326 then
						
						QuincyMedallions:ResetQuincy(PlayerProfile.ClientData.QuincyMedallion)
						PlayerProfile.ClientData.QuincyMedallion = nil
						EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
						return
					end
					
					if not QuincyMedallionCD then
						QuincyMedallionCD = true
						
						task.spawn(function()
							if QuincyMedallions:CheckMedallionMissing(PlayerProfile.ClientData.QuincyMedallion) then
								PlayerProfile.ClientData.QuincyMedallion = nil
							end
						end)
						
						task.delay(60, function()
							QuincyMedallionCD = nil
						end)
					end
					
					local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
					local PathData = {Module = ClientProgression, Skill = "StolenBankai"}
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData)
				elseif TimeDifference < BankaiCooldown then
					local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
					local PathData = {Module = ClientProgression, Skill = "BankaiTimer"}
					local Text = BankaiCooldown / 60 - math.floor(TimeDifference / 60)
					NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Text)
				else
					if PlayerProfile.ClientData.BankaiRaidCheck then
						local ResetCooldown = 6 * 60 * 60
						if TimeDifference >= ResetCooldown then
							PlayerProfile.ClientData.BankaiRaidCheck = nil
							PlayerProfile.ClientData.CurrentBankaiRaidCheck = nil
						else
							local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
							local PathData = {Module = ClientProgression, Skill = "BankaiTimer2"}
							local Text = ResetCooldown / 60 - math.floor(TimeDifference / 60)
							NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Text)
						end
					end
				end
				
				local CurrentFaction = StatData.Factions[PlayerProfile.ClientData.Race]
				if StatData.CurrentFactions[CurrentFaction] then
					if not PlayerProfile.ClientData.BankaiRaidCheck and not PlayerProfile.ClientData.QuincyMedallion and Character:GetAttribute("ZanpakutoState") == RequiredZanpakutoState[PlayerProfile.ClientData.Race] and Character:GetAttribute("BankaiMeter") >= Character:GetAttribute("MaxBankaiMeter") then
						if CurrentFaction == "Quincy" then
							if PlayerProfile.ClientData.StolenBankai then
								EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
							elseif VollstandigAccessories:CheckVollstandig(PlayerProfile.ClientData.Shikai) then
								EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
							end
							
							--[[if not Character:GetAttribute("VollstandigBankaiBypass") then
								if PlayerProfile.ClientData.StolenBankai then
									EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
								elseif VollstandigAccessories:CheckVollstandig(PlayerProfile.ClientData.Shikai) then
									EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
								end
							end]]
						else
							EntityManager:ChangeState(Character, "TriggerBankaiRelease", PlayerProfile.ClientData)
						end
					end
				end
			--[[elseif Character:GetAttribute("ZanpakutoState") == 2 and PlayerProfile.ClientData.Race == "Vastocar" then
				if Character:GetAttribute("SecondBankaiMeter") >= Character:GetAttribute("MaxSecondBankaiMeter") then
					EntityManager:ChangeState(Character, "TriggerSecondBankaiRelease", PlayerProfile.ClientData)
				end]]
			end
		end
	end
end)

ClientRemotes.ReleaseVisored.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "ReleaseVisored")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		local PlayerProfile = DataManager:RequestProfile(Player)

		if PlayerProfile.ClientData.Race == "Visored" then
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("VisoredTimer")
			if TimeDifference >= StatData.VisoredCooldown * 1000 and Character:GetAttribute("SecondBankaiMeter") >= Character:GetAttribute("MaxSecondBankaiMeter") then
				EntityManager:ChangeState(Character, "TriggerVisoredRelease", PlayerProfile.ClientData)
			end
		elseif StatData.Factions[PlayerProfile.ClientData.Race] == "Quincy" and PlayerProfile.ClientData.LetztStil then
			local TimeDifference = DateTime.now().UnixTimestampMillis - Character:GetAttribute("VisoredTimer")
			if TimeDifference >= StatData.LetztStilCooldown * 1000 and Character:GetAttribute("SecondBankaiMeter") >= Character:GetAttribute("MaxSecondBankaiMeter") then
				EntityManager:ChangeState(Character, "TriggerLetztStilRelease", PlayerProfile.ClientData)
			end
		end
	end
end)

local EquipCD = false
ClientRemotes.Weapon.OnServerEvent:Connect(function(Player, InputType)
	AntiCheatManager:CheckRemoteHistory(Player, "Weapon")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		local PlayerProfile = DataManager:RequestProfile(Player)
		local ZanpakutoState = Character:GetAttribute("ZanpakutoState")
		if ZanpakutoState and ZanpakutoState < 2 then
			if PlayerProfile.ClientData.StateModule == "Shinigami" and not EquipCD then
				EquipCD = true

				if Character["Right Arm"]:FindFirstChild("Zanpakuto") then
					EntityManager:ChangeState(Character, "SheatheWeapon", PlayerProfile.ClientData)
				elseif Character:FindFirstChild("Zanpakuto") then
					EntityManager:ChangeState(Character, "UnsheatheWeapon", PlayerProfile.ClientData)
				end

				task.delay(0.5, function()
					EquipCD = false
				end)
			end
		end
	end
end)

ClientRemotes.HollowTransform.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "HollowTransform")
	
	local Character = Player.Character
	if not Zombified(Character) then
		EntityManager:ChangeState(Character, "TriggerHollowTransform")
	end
end)

ClientRemotes.Purify.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "Purify")
	
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("CatState") then
		local PlayerProfile = DataManager:RequestProfile(Player)
		if PlayerProfile.ClientData.Race == "Shinigami" or PlayerProfile.ClientData.Race == "Visored" then
			EntityManager:ChangeState(Character, "TriggerPurify")
		end
	end
end)

local DataStoreService = game:GetService("DataStoreService")
local WipeStore = DataStoreService:GetDataStore("WipeStore")
local Key = "TestWipe_"

local cachedWipeData

local WipeDebounce = false

ClientRemotes.ResetSP.OnServerEvent:Connect(function(Player, ConfirmedWipe)
	if ConfirmedWipe and not WipeDebounce then
		WipeDebounce = true
		task.delay(1, function()
			WipeDebounce = false
		end)
		
		MarketplaceService:PromptProductPurchase(Player, 1581655464)
		
		--[[local Profile = DataManager:RequestProfile(Player)
		local MetaTags = DataManager:RequestProfileMetaTags(Player)
		
		if not MetaTags.UsedFreeWipeProduct or MetaTags.UsedFreeWipeProduct < 3 then	
			local AllowedWipe = true
			
			if AllowedWipe then
				if not MetaTags.UsedFreeWipeProduct then
					MetaTags.UsedFreeWipeProduct = 1
				else
					MetaTags.UsedFreeWipeProduct += 1
				end

				local WebhookChannel = "TempWipes"
				local WebhookInfo = {
					Message = Player.Name .. " used temp wipe";
					Title = Player.Name .. " " .. Player.UserId
				}
				--Webhooks:Post(WebhookChannel, WebhookInfo)
			else
				local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
				local PathData = {Module = ClientProgression, Skill = "WipeDeclined"}
				local RenderDistance = -1
				NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData)
			end
		end]]
	end
end)

-- Settings Related Code --

ClientRemotes.SettingsEvent.OnServerEvent:Connect(function(Player, SettingsData)
	AntiCheatManager:CheckRemoteHistory(Player, "SettingsEvent")
	
	local PlayerProfile = DataManager:RequestProfile(Player)
	if SettingsData.Sprint == "Shift" or SettingsData.Sprint == "W" then
		PlayerProfile.Settings.Sprint = SettingsData.Sprint
	end
	if SettingsData.QToggle == "Q" or SettingsData.QToggle == "Ctrl" then
		PlayerProfile.Settings.FlashstepToggle = SettingsData.QToggle
	end
	if SettingsData.Music == true or SettingsData.Music == false then
		PlayerProfile.Settings.MusicEnabled = SettingsData.Music
	end
end)

-- Party Related Code -- 

ClientRemotes.PartyCreate.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "PartyCreate")
	
	local Party = PartyManager:CreateParty(Player)
	
	local ClientParty = ReplicatedStorage.Modules.ClientModules.ClientParty
	local PathData = {Module = ClientParty, Skill = "Create"}
	local RenderDistance = -1
	
	NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData, 1, Player.Character)
end)

ClientRemotes.PartyLeave.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "PartyLeave")
	
	local CurrentParty = Player:GetAttribute("Party")
	local Party = PartyManager.Parties[CurrentParty]
	local PartyMembers = Party.Members
	local PartySize = #PartyMembers
	
	QueueManager:LeaveLocalQueue(CurrentParty)
	PartyManager:LeaveParty(Player)
	
	--[[local ClientParty = ReplicatedStorage.Modules.ClientModules.ClientParty
	local PathData = {Module = ClientParty, Skill = "Create"}
	local RemovePathData = {Module = ClientParty, Skill = "Remove"}
	local UpdatePathData = {Module = ClientParty, Skill = "Update"}
	local ClearPathData = {Module = ClientParty, Skill = "Clear"}
	local RenderDistance = -1
	
	
	if Player.Name == CurrentParty then
		for i, Member in ipairs(PartyMembers) do
			for _, OtherMembers in ipairs(PartyMembers) do
				NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, RemovePathData, OtherMembers.Character)
			end
			NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, ClearPathData)
		end
		-- Leader left
	else
		-- Member left
		for _, Member in ipairs(PartyMembers) do
			NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, RemovePathData, Member.Character)
			NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, RemovePathData, Player.Character)
			for i, UpdatedMember in ipairs(PartyMembers) do
				NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, UpdatePathData, i, UpdatedMember.Character)
			end
		end
	end]]
end)

SharedRemotes.PartyInvite.OnServerEvent:Connect(function(Player, InvitedPlayer)
	AntiCheatManager:CheckRemoteHistory(Player, "PartyInvite")
	
	local CurrentParty = Player:GetAttribute("Party")
	SharedRemotes.PartyInvite:FireClient(InvitedPlayer, CurrentParty)
end)

ClientRemotes.PartyAccept.OnServerEvent:Connect(function(Player, PartyLeader)
	AntiCheatManager:CheckRemoteHistory(Player, "PartyAccept")
	
	local Party = PartyManager.Parties[PartyLeader.Name]
	if Party then
		local PartyMembers = Party.Members
		
		local InParty
		for i, v in ipairs(PartyMembers) do
			if Player == v then
				InParty = true
			end
		end
		
		if #PartyMembers < 8 and not InParty then
			PartyManager:AddToParty(PartyLeader, Player)
		end
	end
end)

-- Bail --

SharedRemotes.BailEvent.OnServerEvent:Connect(function(Player, BailPlayerName)
	if typeof(BailPlayerName) ~= "string" then
		return
	end
	
	local BailPlayer = Players:FindFirstChild(BailPlayerName)
	if BailPlayer then
		JailManager:OfferBail(Player, BailPlayer)
	end
end)

ClientRemotes.BailAccept.OnServerEvent:Connect(function(Player, WardenName)
	if typeof(WardenName) ~= "string" then
		return
	end
	
	local Warden = Players:FindFirstChild(WardenName)
	if Warden then
		JailManager:Bail(Player, Warden)
	end
end)

-- Inventory Related Code --

local EquipCD2

ClientRemotes.EquipAccessory.OnServerEvent:Connect(function(Player, Action, AccessoryName)
	AntiCheatManager:CheckRemoteHistory(Player, "EquipAccessory")
	
	if not EquipCD2 then
		EquipCD2 = true
		
		if Action == "Equip" then
			InventoryManager:EquipAccessory(Player, AccessoryName)
		elseif Action == "Unequip" then
			InventoryManager:UnequipAccessory(Player, AccessoryName)
		end
		
		task.delay(0.2, function()
			EquipCD2 = false
		end)
	end
end)

ClientRemotes.EquipSkill.OnServerEvent:Connect(function(Player, InventoryNumber, SkillName)
	AntiCheatManager:CheckRemoteHistory(Player, "EquipSkill")
	
	local MeetsReq = InventoryManager:CheckSkillReqs(Player, SkillName, "Equipping")
	if MeetsReq then
		local Profile = DataManager:RequestProfile(Player)
		local UnlockedSkills = Profile.UnlockedSkills
		if table.find(UnlockedSkills, MeetsReq) then
			DataManager:ModifySkillInventory(Player, InventoryNumber, SkillName)
		else
			print("learn the skill")
		end
	elseif InventoryManager:CheckItem(Player, SkillName, "Equipping") then
		DataManager:ModifySkillInventory(Player, InventoryNumber, SkillName)
	else
		print("reqs not met to equip")
	end
	
	--print(InventoryNumber, SkillName)
end)

ClientRemotes.LearnSkill.OnServerEvent:Connect(function(Player, SkillName)
	AntiCheatManager:CheckRemoteHistory(Player, "LearnSkill")
	
	local MeetsReq = InventoryManager:CheckSkillReqs(Player, SkillName)
	if MeetsReq then
		local CeroPaths = {
			["Blade Cero"] = "Blade Cero";
			["Cero Cornea"] = "Cero Cornea";
			["Finger Cero"] = "Finger Cero";
			["Tri Cero"] = "Tri Cero";
			["Cero Grab"] = "Cero Grab";
		}
		
		local CeroWhitelist = {
			["Cero Grab"] = true;
			["Finger Cero"] = true;
		}
		
		if CeroPaths[SkillName] then
			local NoPath = InventoryManager:CheckCeroPath(Player, SkillName)
			if NoPath then
				DataManager:AddSkill(Player, MeetsReq)
				--[[if not CeroWhitelist[SkillName] then
					DataManager:RemoveSkill(Player, "Cero")
					DataManager:RemoveSkill(Player, "Cero Oscuras")
				end]]
			end
		else
			DataManager:AddSkill(Player, MeetsReq)
		end
	else
		ReplicatedStorage.Remotes.SkillLearnedEvent:FireClient(Player, nil, nil, nil)
	end
end)

ClientRemotes.AddSP.OnServerEvent:Connect(function(Player, SPTree)
	AntiCheatManager:CheckRemoteHistory(Player, "AddSP")
	
	DataManager:AddSP(Player, SPTree)
end)

--[[ClientRemotes.ESCCombatTag.OnServerEvent:Connect(function(Player)
	local Character = Player.Character
	
	local AttackData = {
		ImpactSound = "None", -- "None" for no impact sound, put the sound object and set play on remove true
		NoHitEffect = true, -- true for no hit effect

		Blockable = false,	
		Parryable = false,
		Damage = 0,

		BlockDamage = 0,
		DeflectDamage = 0,
		
		TrueStunTime = 0,
		SoftStunTime = 0,
		StunAnimation = "None", -- "None" for no stun anim, put anim object

		Properties = {
			Range = 8,
			Width = 6,
			Height = 7,
			Length = 0,
		},
	}
	
	if Character and Character.PrimaryPart and Character.Humanoid.Health > 0 then
		CombatManager:ApplyDamage(Character, {[Character] = "FrontalHit"}, AttackData)
		print(Character.Name .. " Menu opened")
	end
end)]]

local MainMenuCD = 0.1
local MenuDebounce

ClientRemotes.MainMenu.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "MainMenu")
	
	if not MenuDebounce then
		MenuDebounce = true
		
		task.delay(MainMenuCD, function()
			MenuDebounce = false
		end)
		
		local Profile = DataManager:RequestProfile(Player)
		if Player.Character:GetAttribute("CombatTag") <= 0 and Profile.ClientData.CombatLogged == 0 and not Profile.ClientData.WipeTag and not Profile.ClientData.VastoWipeTag and Player.Character:GetAttribute("CurrentState") ~= "Executing" then			
			Player:SetAttribute("Menued", true)
			Teleports:TeleportParty({Player}, StatData.PlaceIDs["Main Menu"])
		end
	end
end)

local RefreshCooldown = false
ClientRemotes.ServerListTeleport.OnServerEvent:Connect(function(Player, PlaceName, JobID, CCServer)
	AntiCheatManager:CheckRemoteHistory(Player, "ServerListTeleport")
	
	if not RefreshCooldown and not Player.Character:GetAttribute("Death") and Player.Character:GetAttribute("CurrentState") ~= "Executing" and not Player.Character:GetAttribute("Teleporting") then
		RefreshCooldown = true
		
		task.delay(1, function()
			RefreshCooldown = false
		end)
		
		local Checks = {
			[StatData.PlaceIDs["Hueco Mundo"]] = { -- Hueco
				Arrancar = true;
				Hollow = true;
				Vastocar = true;
			},
			[StatData.PlaceIDs["Soul Society"]] = { -- Soul Society
				Shinigami = true;
				Visored = true;
			},
			[StatData.PlaceIDs["Karakura Town"]] = { -- Karakura
				Arrancar = true;
				Hollow = true;
				Vastocar = true;
				Shinigami = true;
				Visored = true;
				Quincy = true;
			};
			[StatData.PlaceIDs["Rukon District"]] = { -- Rukon District
				
			};
			[StatData.PlaceIDs["Las Noches"]] = { -- Las Noches
				
			};
			[StatData.PlaceIDs["Wandenreich City"]] = { -- Wandenreich City
				Quincy = true;
			}
		}

		local PlaceID = StatData.PlaceIDs[PlaceName]
		if PlaceID then
			if CCServer then
				if Player:GetRankInGroup(32740991) > 0 then
					local Profile = DataManager:RequestProfile(Player)
					local TeleportAllowed = true
					
					if Profile.ClientData.CombatLogged == 0 and not Profile.ClientData.WipeTag and not Profile.ClientData.VastoWipeTag and TeleportAllowed then
						if Profile.ClientData.LoggedPlace == StatData.Places[PlaceID] then
							Teleports:TeleportPartyToCC({Player}, PlaceID)
						elseif Checks[PlaceID][Profile.ClientData.Race] then
							Teleports:TeleportPartyToCC({Player}, PlaceID)
						elseif PlaceID == StatData.PlaceIDs["Rukon District"] then
							if Profile.ClientData.ShinigamiRank >= 10 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
								Teleports:TeleportPartyToCC({Player}, PlaceID)
							end
						else
							print(Player.Name .. " not allowed to use " .. PlaceName)
						end
					end
				end
				return
			end
			
			if game.JobId ~= JobID then				
				local Profile = DataManager:RequestProfile(Player)
				local TeleportAllowed = true

				--[[local CurrentFaction = StatData.Factions[Profile.ClientData.Race]
				if PlaceID == StatData.PlaceIDs["Soul Society"] and StatData.CurrentFactions[CurrentFaction] and CurrentFaction == "Shinigami" then
					if not table.find(Profile.UnlockedSkills, "Senkaimon") then
						TeleportAllowed = nil
					end
				end]]
				
				if Profile.ClientData.CombatLogged == 0 and not Profile.ClientData.WipeTag and not Profile.ClientData.VastoWipeTag and TeleportAllowed then
					if Profile.ClientData.LoggedPlace == StatData.Places[PlaceID] then
						Teleports:TeleportParty({Player}, PlaceID, JobID)
					elseif Checks[PlaceID][Profile.ClientData.Race] then
						Teleports:TeleportParty({Player}, PlaceID, JobID)
					elseif PlaceID == StatData.PlaceIDs["Rukon District"] then
						if Profile.ClientData.ShinigamiRank >= 10 and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
							Teleports:TeleportParty({Player}, PlaceID, JobID)
						end
					else
						print(Player.Name .. " not allowed to use " .. PlaceName)
					end
				end
			end
		end
	end
end)

ClientRemotes.CharacterReset.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "CharacterReset")
	
	local Character = Player.Character
	if not Zombified(Character) then
		local Profile = DataManager:RequestProfile(Player)
		if Character:GetAttribute("ResetDeath") then
			print(DateTime.now())
			if DateTime.now().UnixTimestamp - Character:GetAttribute("ResetDeath") >= 5 * 60 then -- Seconds
				EntityManager:ForceState(Character, "Dying")
				EntityManager:ChangeState(Character, "TriggerDeath")
			else
				local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
				local PathData = {Module = ClientProgression, Skill = "ResetDeath"}
				NetworkManager.FireClient(Player, Character, "ClientEffects", -1, PathData, Character:GetAttribute("ResetDeath"))
			end
		elseif Profile.ClientData.CombatLogged == 0 and not Profile.ClientData.WipeTag and not Profile.ClientData.VastoWipeTag then
			EntityManager:ChangeState(Character, "TriggerReset")
		end
	end
end)

local DropCD = 0.2
local DropDebounce = false

ClientRemotes.DropItem.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "DropItem")
	
	if not DropDebounce then
		DropDebounce = true
		
		task.delay(DropCD, function()
			DropDebounce = false
		end)
		
		local Character = Player.Character
		SharedRemotes.ServerDropItem:Fire(Character)
	end
end)

ClientRemotes.PurchaseAccessory.OnServerEvent:Connect(function(Player, AccessoryName)
	if typeof(AccessoryName) ~= "string" then
		return
	end
	
	AntiCheatManager:CheckRemoteHistory(Player, "PurchaseAccessory")
	
	InventoryManager:PurchaseAccessory(Player, AccessoryName)
end)

ClientRemotes.ProductPurchase.OnServerEvent:Connect(function(Player, ProductName)
	if typeof(ProductName) ~= "string" then
		return
	end
	
	AntiCheatManager:CheckRemoteHistory(Player, "ProductPurchase")
	
	local ProductInfo = ProductFunctions.Products[ProductName]
	
	local Profile = DataManager:RequestProfile(Player)
	if Profile.ClientData.CombatLogged == 0 and not Profile.ClientData.WipeTag and not Profile.ClientData.VastoWipeTag then
		if ProductInfo and ProductInfo.Race[Profile.ClientData.Race] then	
			--local Handler = ProductFunctions[ProductInfo.ProductId]({PurchaseId = 1}, Player)
			MarketplaceService:PromptProductPurchase(Player, ProductInfo.ProductId)
		end
	end
end)

ClientRemotes.PurchaseMarketItem.OnServerEvent:Connect(function(Player, ItemName)
	if typeof(ItemName) ~= "string" then
		return
	end
	
	AntiCheatManager:CheckRemoteHistory(Player, "PurchaseMarketItem")
	
	local Profile = DataManager:RequestProfile(Player)
	local MarketAllowed
	local MarketNPC = workspace.NPCs:FindFirstChild("Market")
	if MarketNPC then
		if MarketNPC:GetAttribute("ArrancarBuyers") and StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
			MarketAllowed = true
		end
		if MarketNPC:GetAttribute("ShinigamiBuyers") and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
			MarketAllowed = true
		end
		if MarketNPC:GetAttribute("QuincyBuyers") and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			MarketAllowed = true
		end
	end

	if typeof(ItemName) == "string" and MarketAllowed and FactionManager:InMarketRotation(ItemName) then
		InventoryManager:PurchaseMarketItem(Player, ItemName)
	end
end)

ClientRemotes.SellAccessory.OnServerEvent:Connect(function(Player, AccessoryName)
	if typeof(AccessoryName) ~= "string" then
		return
	end
	
	AntiCheatManager:CheckRemoteHistory(Player, "SellAccessory")
	
	local Profile = DataManager:RequestProfile(Player)
	local MarketAllowed
	local MarketNPC = workspace.NPCs:FindFirstChild("Market")
	if MarketNPC then
		if MarketNPC:GetAttribute("ArrancarBuyers") and StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
			MarketAllowed = true
		end
		if MarketNPC:GetAttribute("ShinigamiBuyers") and StatData.Factions[Profile.ClientData.Race] == "Shinigami" then
			MarketAllowed = true
		end
		if MarketNPC:GetAttribute("QuincyBuyers") and StatData.Factions[Profile.ClientData.Race] == "Quincy" then
			MarketAllowed = true
		end
	end

	if typeof(AccessoryName) == "string" and MarketAllowed then
		InventoryManager:SellAccessory(Player, AccessoryName)
	end
end)

local VanityCD = 0.5
local VanityDebounce

ClientRemotes.VanityToggle.OnServerEvent:Connect(function(Player, AccessoryName)
	if typeof(AccessoryName) ~= "string" then
		return
	end
	
	AntiCheatManager:CheckRemoteHistory(Player, "VanityToggle")
	
	if not VanityDebounce then
		VanityDebounce = true
		
		task.delay(VanityCD, function()
			VanityDebounce = false
		end)
		
		InventoryManager:ToggleVanity(Player, AccessoryName)
	end
end)

ClientRemotes.Hierro.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "Hierro")
	
	local Profile = DataManager:RequestProfile(Player)
	if StatData.Factions[Profile.ClientData.Race] == "Arrancar" then
		EntityManager:ChangeState(Player.Character, "TriggerHierro")
	elseif StatData.Factions[Profile.ClientData.Race] == "Quincy" then
		EntityManager:ChangeState(Player.Character, "TriggerBlutSwap")
	end
end)

ClientRemotes.Return.OnServerEvent:Connect(function(Player)
	AntiCheatManager:CheckRemoteHistory(Player, "Return")
	
	local Character = Player.Character
	
	if StatData.HuecoMundo or StatData.TYPETEST or StatData.SoulSociety or StatData.WandenreichCity then
		local Timer = Character:GetAttribute("ReturnTimer")
		if Timer then
			local TimeDifference = DateTime.now().UnixTimestampMillis - Timer
			if TimeDifference >= 120 * 1000 and not FactionManager:IsRaidActive() and not FactionManager:IsHuntActive() then
				EntityManager:ChangeState(Player.Character, "TriggerHomeReturn")
			end
		end
	end
end)

local KanCD = false

ClientRemotes.DropKan.OnServerEvent:Connect(function(Player, Amount)
	AntiCheatManager:CheckRemoteHistory(Player, "DropKan")
	
	if typeof(Amount) ~= "string" then
		return
	end
	
	if KanCD then
		return
	end
	if Player:GetAttribute("DroppedKan") then
		return
	end
	
	ServerStorage.Remotes.DropItem:Fire("DropKan", Player, Amount)
	
	KanCD = true
	task.delay(0.1, function()
		KanCD = false
	end)
end)

ClientRemotes.ToggleLightAttack.OnServerEvent:Connect(function(Player)
	local Profile = DataManager:RequestProfile(Player)
	local Character = Player.Character
	local LightAttackToggled = Character:GetAttribute("LightAttackToggled")
	if LightAttackToggled then
		Character:SetAttribute("LightAttackToggled", nil)
	else
		Character:SetAttribute("LightAttackToggled", true)
	end
	
	local ToggleIndicator = Profile.ClientData.ZanpakutoWeapon
	
	if Profile.ClientData.Race == "Quincy" and ToggleIndicator == "Fist" then
		ToggleIndicator = "QuincyFist"
	end
	
	local ClientLightAttacks = ReplicatedStorage.Modules.ClientModules.ClientLightAttacks
	local PathData = {Module = ClientLightAttacks, Skill = "LightAttackToggled"}
	local RenderDistance = -1
	NetworkManager.FireClient(Player, Character, "ClientEffects", RenderDistance, PathData, ToggleIndicator, Character:GetAttribute("LightAttackToggled"))
end)

ClientRemotes.Shiftlocked.OnServerEvent:Connect(function(Player, Shiftlocked)
	local Character = Player.Character
	if Shiftlocked then
		Character:SetAttribute("Shiftlocked", true)
	else
		Character:SetAttribute("Shiftlocked", nil)
	end
end)

local PingDebounce

ClientRemotes.PingEvent.OnServerEvent:Connect(function(Player, MousePosition, Direction)
	if typeof(Direction) ~= "string" then
		return
	end
	
	if PingDebounce then
		return
	end
	
	local Types = {
		Right = "Exclamation";
		Left = "Heal";
		Up = "Assist";
		Down = "Come";
	}
	
	local CurrentParty = Player:GetAttribute("Party")
	
	if CurrentParty and MousePosition and Types[Direction] then
		PingDebounce = true
		task.delay(7, function()
			PingDebounce = nil
		end)
		
		local Profile = DataManager:RequestProfile(Player)
		
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
		
		local Party = PartyManager.Parties[CurrentParty]
		local PartyMembers = Party.Members

		local ClientParty = ReplicatedStorage.Modules.ClientModules.ClientParty
		local PathData = {Module = ClientParty, Skill = "PartyPing"}
		local RenderDistance = -1
		
		for _, Member in ipairs(PartyMembers) do
			NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, PathData, MousePosition, Types[Direction], Name)
		end
	end
end)

local TradeInvokeTimouts

ClientRemotes.Trade.OnServerInvoke = function(Player, TradingPlayer)
	if typeof(TradingPlayer) ~= "string" then
		return
	end
	
	if Player:GetAttribute("ActiveTrade") then
		return
	end
	
	if TradeInvokeTimouts then
		return nil
	end
	TradeInvokeTimouts = true
	task.delay(0.2, function()
		TradeInvokeTimouts = nil
	end)
	
	local TradePlayerFound = Players:FindFirstChild(TradingPlayer)
	if TradePlayerFound and TradePlayerFound ~= Player and not TradePlayerFound:GetAttribute("ActiveTrade") then
		local Profile = DataManager:RequestProfile(Player)
		local TradeProfile = DataManager:RequestProfile(TradePlayerFound)
		local Response = ReplicatedStorage.Requests.TradeRequest:InvokeClient(TradePlayerFound, "Invite", Player)

		repeat
			task.wait()
		until Response ~= nil
		
		if Player.Character:GetAttribute("CurrentState") == "ItemState" or TradePlayerFound.Character:GetAttribute("CurrentState") == "ItemState" then
			Response = nil
		end
		
		if Response == true then
			ServerStorage.Remotes.DropItem:Fire("Trade", Player, TradePlayerFound)
			
			--[[local TradeObject = TradeManager.new(Player, TradePlayerFound)
			if not TradeObject then
				return false
			end

			TradeObject:Connect(Player.Character.CharacterHandler.Remotes.TradeEvent, "OnServerEvent", function(Player1, Action, ItemName, Slot)
				if Action == "Cancel" then
					TradeObject:Destroy()
				elseif Action == "AddItem" then
					print(Player.Name, ItemName, Slot)
					if typeof(ItemName) ~= "string" then
						return
					end	
					if typeof(Slot) ~= "number" or Slot < 1 or Slot > 4 then
						return
					end
					if Player1 ~= TradeObject.Player1Info.Player then
						return
					end

					if Profile.ItemInventory[ItemName] then
						if StatData.Factions[Profile.ClientData.Race] == StatData.Factions[TradeProfile.ClientData.Race] then
							TradeObject:AddItem(Player1, Slot, ItemName)
						else
							if TradesableData[ItemName].GlobalTrade then
								TradeObject:AddItem(Player1, Slot, ItemName)
							end
						end
					end
				elseif Action == "RemoveItem" then
					if typeof(Slot) ~= "number" or Slot < 1 or Slot > 4 then
						return
					end

					if Player1 ~= TradeObject.Player1Info.Player then
						return
					end
					
					TradeObject:RemoveItem(Player1, Slot, ItemName)
				elseif Action == "Accepted" then
					if Player1 ~= TradeObject.Player1Info.Player then
						return
					end

					TradeObject:Accept(Player1)
				end
			end)
			TradeObject:Connect(TradePlayerFound.Character.CharacterHandler.Remotes.TradeEvent, "OnServerEvent", function(Player2, Action, ItemName, Slot)
				if Action == "Cancel" then
					TradeObject:Destroy()
				elseif Action == "AddItem" then
					print(Player.Name, ItemName, Slot)
					if typeof(ItemName) ~= "string" then
						return
					end	
					if typeof(Slot) ~= "number" or Slot < 1 or Slot > 4 then
						return
					end
					if Player2 ~= TradeObject.Player2Info.Player then
						return
					end

					if Profile.ItemInventory[ItemName] then
						if StatData.Factions[Profile.ClientData.Race] == StatData.Factions[TradeProfile.ClientData.Race] then
							TradeObject:AddItem(Player2, Slot, ItemName)
						else
							if TradesableData[ItemName].GlobalTrade then
								TradeObject:AddItem(Player2, Slot, ItemName)
							end
						end
					end
				elseif Action == "RemoveItem" then
					if typeof(Slot) ~= "number" or Slot < 1 or Slot > 4 then
						return
					end
					if Player2 ~= TradeObject.Player2Info.Player then
						return
					end
					TradeObject:RemoveItem(Player2, Slot, ItemName)
				elseif Action == "Accepted" then
					if Player2 ~= TradeObject.Player2Info.Player then
						return
					end

					TradeObject:Accept(Player2)
				end			
			end)

			ReplicatedStorage.Remotes.TradeRemote:FireClient(TradePlayerFound, "EnablePlayer2", nil, nil, nil, Player.Name)]]
		elseif Response == false then

		end
		
		if Response == true then
			local Accessories = {}

			local Profile = DataManager:RequestProfile(Player)
			if Profile then
				for i, v in pairs(Profile.ItemInventory) do
					if TradesableData[i] and TradesableData[i].Rarity ~= "Clan" and (TradesableData[i].Rarity ~= "Unobtainable" or TradesableData[i].Rarity == "Unobtainable" and TradesableData[i].Tradeable) then
						Accessories[i] = v
					end
				end
			end

			return Accessories
		else
			return nil
		end
	end
end

local CodeCD = false

ClientRemotes.Codes.OnServerInvoke = function(Player, Code)
	if typeof(Code) ~= "string" then
		return
	end
	
	if CodeCD then
		return nil
	end
	CodeCD = true
	
	task.delay(0.2, function()
		CodeCD = false
	end)
	
	return Codes:CheckCode(Player, Code)
end

local AntiProfile

repeat
	task.wait()
	AntiProfile	= AntiCheatManager:RequestProfile(script.Parent)
until AntiProfile

while true do
	local Step = task.wait(0.03)
	AntiProfile:Update(Step)
end
