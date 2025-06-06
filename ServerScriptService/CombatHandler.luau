local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local InventoryManager = require(ServerStorage.Modules.Managers.InventoryManager)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local TradeablesData = require(ServerStorage.Modules.Utility.TradeablesData)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local Webhooks = require(ServerStorage.Modules.Utility.Webhooks)
local TradeManager = require(ServerStorage.Modules.Managers.TradeManager)
local TradesableData = require(ServerStorage.Modules.Utility.TradeablesData)

local function Zombified(Character)
	local Zombified
	if Character:GetAttribute("ControlsDisabled") or Character:GetAttribute("Zombification") or Character:GetAttribute("PartialResQuest") then
		Zombified = true
	end
	return Zombified
end

local CombatActions = {}

function CombatActions.LightAttack(Player)
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") and not Character:GetAttribute("CatState") then
		EntityManager:ChangeState(Character, "TriggerLAttack")
	end
end

function CombatActions.CriticalAttack(Player)
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") and not Character:GetAttribute("CatState") then
		EntityManager:ChangeState(Character, "TriggerCAttack")
	end
end

function CombatActions.Skill(Player, KeyPressed, InputType)
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
end

function CombatActions.ShikaiSkill(Player, KeyPressed, InputType)
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") and not Character:GetAttribute("CatState") then
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
end

function CombatActions.BankaiSkill(Player, KeyPressed, InputType)
	local Character = Player.Character
	if not Zombified(Character) and not Character:GetAttribute("Forcefield") and not Character:GetAttribute("CatState") then
		local Schrift
		local Profile = DataManager:RequestProfile(Player)
		if StatData.Factions[Profile.ClientData.Race] == "Quincy" and Profile.ClientData.ShikaiUnlocked and not Profile.ClientData.StolenBankai then
			Schrift = true
		end
		
		local SkillAllowed
		if not Character:GetAttribute("ShikaiDisabled") and not Character:GetAttribute("BouncingBomb") then
			if Character:GetAttribute("ZanpakutoState") >= 2 or (Character:GetAttribute("VollstandigBankaiBypass") and not Character:GetAttribute("QuincyDisabled")) or (Schrift and not Character:GetAttribute("VollstandigBypass") and not Character:GetAttribute("QuincyDisabled")) then
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
end

local CarryCDS = {}

function CombatActions.Carry(Player)
	if CarryCDS[Player.Name] then
		return
	end

	CarryCDS[Player.Name] = true
	task.delay(0.3, function()
		CarryCDS[Player.Name] = nil
	end)
	
	local Character = Player.Character
	if not Zombified(Character) then
		if not Character:GetAttribute("CatState") then
			EntityManager:ChangeState(Character, "TriggerCarry")
		else
			local Meow = ReplicatedStorage.Assets.Sounds.nya:Clone()
			Meow.PlayOnRemove = true
			Meow.Parent = Character.YoruichiCat.PrimaryPart
			Meow:Destroy()
			Meow = nil
		end
	end
end

ReplicatedStorage.Remotes.ServerCombatHandler.OnServerEvent:Connect(function(Player, Action, ...)
	if typeof(Action) ~= "string" then
		return
	end

	if CombatActions[Action] then
		CombatActions[Action](Player, ...)
	end
end)

function CombatActions.DropItem(Player, ItemName)
	local Character = Player.Character
	
	if not TradeablesData[ItemName].Undroppable then
		local PlayerAmount = DataManager:CheckItemQuantity(Player, ItemName)
		local ItemRemoved = DataManager:RemoveItem(Player, ItemName, 1)
		if ItemRemoved then
			local Item = ServerStorage.Assets.Items.Models[ItemName]:Clone()
			local TouchedPart = Item
			Item:SetAttribute("Owner", Player.UserId)
			if Item:IsA("Model") then
				for i, v in ipairs(Item:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CollisionGroup = "Entity2"
					end
				end

				Item:PivotTo(Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -3))
				TouchedPart = Item.PrimaryPart
			else
				Item.CollisionGroup = "Entity2"
				Item.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -3)
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
						if Magnitude <= 10 then
							local PickupPlayer = Players:GetPlayerFromCharacter(PickupCharacter)
							if PickupPlayer then
								local PickupProfile = DataManager:RequestProfile(PickupPlayer)
								local CurrentFaction = StatData.Factions[PickupProfile.ClientData.Race]
								if CurrentFaction and StatData.CurrentFactions[CurrentFaction] then
									PickedUp = true
									Connection:Disconnect()
									Connection = nil

									DataManager:AddItem(PickupPlayer, ItemName, 1)

									local PickupPlayerAmount = DataManager:CheckItemQuantity(PickupPlayer, ItemName)

									Item:Destroy()

									local WebhookInfo = {
										Message = PickupPlayer.Name .. " has picked up " .. ItemName .. " from " .. Player.Name .. "\n" .. Player.Name .. " " .. ItemName .. ": " .. PlayerAmount .. "\n" .. PickupPlayer.Name .. ItemName .. ": " .. PickupPlayerAmount;
									}

									Webhooks:Post("ItemUses", WebhookInfo)
								end
							end
						end
					end
				end
			end)
		end
	end
end

function CombatActions.DropKan(Player, Amount)
	if not Amount then
		return
	end
	
	local Kan = tonumber(Amount)
	local FlooredKan = math.floor(Kan)
	if FlooredKan and FlooredKan > 0 and FlooredKan == FlooredKan then
		if FlooredKan >= 10000 then
			FlooredKan = 10000
		end
		InventoryManager:DropKan(Player, FlooredKan)
	end
end

function CombatActions.Trade(Player, TradingPlayer)
	local TradeObject = TradeManager.new(Player, TradingPlayer)
	if not TradeObject then
		return false
	end

	local Profile = DataManager:RequestProfile(Player)
	local TradeProfile = DataManager:RequestProfile(TradingPlayer)

	TradeObject:Connect(Player.Character.CharacterHandler.Remotes.TradeEvent, "OnServerEvent", function(Player1, Action, ItemName, Slot)
		if Action == "Cancel" then
			TradeObject:Destroy()
		elseif Action == "AddItem" then
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
	TradeObject:Connect(TradingPlayer.Character.CharacterHandler.Remotes.TradeEvent, "OnServerEvent", function(Player2, Action, ItemName, Slot)
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

			if TradeProfile.ItemInventory[ItemName] then
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
	
	local Accessories = {}
	if TradeProfile then
		for i, v in pairs(TradeProfile.ItemInventory) do
			if TradesableData[i] and TradesableData[i].Rarity ~= "Clan" and (TradesableData[i].Rarity ~= "Unobtainable" or TradesableData[i].Rarity == "Unobtainable" and TradesableData[i].Tradeable) then
				Accessories[i] = v
			end
		end
	end
	
	ReplicatedStorage.Remotes.TradeRemote:FireClient(TradingPlayer, "EnablePlayer2", nil, nil, nil, Player.Name, Accessories)
end

ServerStorage.Remotes.DropItem.Event:Connect(function(Action, ...)
	if CombatActions[Action] then
		CombatActions[Action](...)
	end
end)
