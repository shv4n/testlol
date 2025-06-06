local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local ServerSkillReqs = require(ServerStorage.Modules.Utility.ServerSkillReqs)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local TradeablesData = require(ServerStorage.Modules.Utility.TradeablesData)
local ItemModule = require(ServerStorage.Modules.SkillModules.Items.ServerItems)
local ServerItemReqs = require(ServerStorage.Modules.Utility.ServerItemReqs)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local ClothesData = require(ServerStorage.Modules.Utility.ClothesData)
local PlayerBonus = require(ServerStorage.Modules.Utility.PlayerBonus)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local AdminWhitelist = require(ServerStorage.Modules.Utility.AdminWhitelist)
local Webhooks = require(ServerStorage.Modules.Utility.Webhooks)

local ClientItems = ReplicatedStorage.Modules.ClientModules.ClientItems

local ItemWebhookChannel = "ItemUses"

local AccessoryData = {}
local InventoryManager = {}

function InventoryManager:PlaySprintAnimations(Character)
	if AccessoryData[Character.Name] then
		for i, v in pairs(AccessoryData[Character.Name]) do
			local AnimateAccessory = Character.Accessories[i]:FindFirstChildWhichIsA("Model")
			if AnimateAccessory then
				AnimateAccessory.AnimationController.Animator:LoadAnimation(v):Play()
			end
		end
	end
end

function InventoryManager:CancelSprintAnimations(Character)
	if AccessoryData[Character.Name] then
		for i, v in pairs(AccessoryData[Character.Name]) do
			local AnimateAccessory = Character.Accessories[i]:FindFirstChildWhichIsA("Model")
			if AnimateAccessory then
				SharedFunctions:CancelAnimation(AnimateAccessory.AnimationController.Animator, "Sprint", "SearchByReference")
			end
		end
	end
end

function InventoryManager:CleanupAccessoryData(PlayerName)
	if AccessoryData[PlayerName] then
		for i, v in pairs(AccessoryData[PlayerName]) do
			AccessoryData[PlayerName][i] = nil
		end
		AccessoryData[PlayerName] = nil
	end
end

function InventoryManager:SetupAccessories(Player, Profile)
	local EquippedAccessories = Profile.Accessories
	local Character = Player.Character
	local Accessories = {
		"Head";
		"Face";
		"Neck";
		"Shoulder";
		"Arm";
		"Torso";
		"Back";
		"Waist";
		"Leg";
	}
	
	AccessoryData[Player.Name] = {}
	
	local AccessoryFolder = Instance.new("Folder")
	AccessoryFolder.Name = "Accessories"
	AccessoryFolder.Parent = Character
	
	for i = 1, #Accessories do
		local Accessory = Instance.new("Folder")
		Accessory.Name = Accessories[i]
		Accessory.Parent = AccessoryFolder
	end
	
	for AccessoryType, AccessoryName in pairs(EquippedAccessories) do
		if AccessoryName ~= "Empty" and TradeablesData[AccessoryName] and not Profile.AccessoriesVanity[AccessoryType] then
			local Accessory = ServerStorage.Assets.Accessories.AccessoryTypes[AccessoryType][AccessoryName]:Clone()
			local WrapsColor = Profile.ClientData.WrapsColor
			local HairColor = Profile.ClientData.HairColor
			if Accessory:IsA("Model") then
				for i, v in ipairs(Accessory:GetDescendants()) do
					if v:IsA("BasePart") and v:GetAttribute("Color") then
						v.Color = Color3.fromRGB(WrapsColor[1], WrapsColor[2], WrapsColor[3])
					elseif v:GetAttribute("HairColor") then
						v.Color = Color3.fromRGB(HairColor[1], HairColor[2], HairColor[3])
					end
				end
			else
				if Accessory:GetAttribute("Color") then
					Accessory.Color = Color3.fromRGB(WrapsColor[1], WrapsColor[2], WrapsColor[3])
				elseif Accessory:GetAttribute("HairColor") then
					Accessory.Color = Color3.fromRGB(HairColor[1], HairColor[2], HairColor[3])
				end
			end
			Accessory.Parent = AccessoryFolder[AccessoryType]
			
			for _, AccessoryData in ipairs(TradeablesData[AccessoryName].AccessoryData) do
				local AccessoryPart = AccessoryData.Part0
				local BodyPart = Character[AccessoryData.Part1]
				
				local Weld = Instance.new("Weld")
				Weld.Part1 = BodyPart
				Weld.C0 = AccessoryData.C0
				
				if AccessoryPart == "self" then
					Weld.Part0 = Accessory
					Weld.Parent = Accessory
				else
					Weld.Part0 = Accessory[AccessoryPart]
					Weld.Parent = Accessory[AccessoryPart]
				end
			end
			
			if TradeablesData[AccessoryName].AnimationData then
				local Animation = TradeablesData[AccessoryName].AnimationData.Idle
				Accessory.AnimationController.Animator:LoadAnimation(Animation):Play()
				
				if TradeablesData[AccessoryName].AnimationData.Sprint then
					AccessoryData[Player.Name][AccessoryType] = TradeablesData[AccessoryName].AnimationData.Sprint
				end
				
				if TradeablesData[AccessoryName].AnimationData.Idle2 then
					local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle2
					Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
				end
				if TradeablesData[AccessoryName].AnimationData.Idle3 then
					local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle3
					Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
				end
				if TradeablesData[AccessoryName].AnimationData.Idle4 then
					local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle4
					Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
				end
			end
			
			if TradeablesData[AccessoryName].HideName then
				Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
			if TradeablesData[AccessoryName].HideHair then
				for _, Child in ipairs(Character:GetChildren()) do
					if Child.ClassName == "Accessory" then
						if Child.Handle:FindFirstChild("AccessoryWeld") then
							Child.Handle.AccessoryWeld:Destroy()
						end
						Child.Parent = ServerStorage.LiveAssets[Character.Name]
					end
				end
			end
			if TradeablesData[AccessoryName].StatBuffs then
				local AccessoryReduction = Character:GetAttribute("AccessoryReduction") or 1
				AccessoryReduction -= TradeablesData[AccessoryName].StatBuffs.Defense
				Character:SetAttribute("AccessoryReduction", AccessoryReduction)
				
				if TradeablesData[AccessoryName].StatBuffs.MeterGain then
					local AccessoryMeterGain = Character:GetAttribute("AccessoryMeterGain") or 0
					AccessoryMeterGain += TradeablesData[AccessoryName].StatBuffs.MeterGain
					Character:SetAttribute("AccessoryMeterGain", AccessoryMeterGain)
				end
				if TradeablesData[AccessoryName].StatBuffs.MeterDrain then
					local AccessoryMeterDrainValue = 1 - TradeablesData[AccessoryName].StatBuffs.MeterDrain
					local AccessoryMeterDrain = Character:GetAttribute("AccessoryMeterDrain") or 1
					AccessoryMeterDrain -= AccessoryMeterDrainValue
					Character:SetAttribute("AccessoryMeterDrain", AccessoryMeterDrain)
				end
				if TradeablesData[AccessoryName].StatBuffs.HierroPen then
					local AccessoryHierroPen = Character:GetAttribute("AccessoryHierroPen") or 0
					AccessoryHierroPen += TradeablesData[AccessoryName].StatBuffs.HierroPen
					Character:SetAttribute("AccessoryHierroPen", AccessoryHierroPen)
				end
			end
		end
	end
end

function InventoryManager:EquipAccessory(Player, AccessoryName)
	if Player.Character:FindFirstChild("Accessories") then
		local Profile = DataManager:RequestProfile(Player)
		if Profile.ItemInventory[AccessoryName] then
			local ItemType = TradeablesData[AccessoryName].ItemType
			local CurrentAccessory = Profile.Accessories[ItemType]
			local SuccessfulEquip = DataManager:ModifyEquippedAccessories(Player, ItemType, AccessoryName)
			if SuccessfulEquip == "EquipSuccess" then
				local Character = Player.Character
				
				if TradeablesData[CurrentAccessory] then
					if TradeablesData[CurrentAccessory].StatBuffs then
						local AccessoryReduction = Character:GetAttribute("AccessoryReduction")
						if AccessoryReduction then
							AccessoryReduction += TradeablesData[CurrentAccessory].StatBuffs.Defense
							Character:SetAttribute("AccessoryReduction", AccessoryReduction)
						end
					end
					if TradeablesData[CurrentAccessory].HideName then
						Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
					end
					if TradeablesData[CurrentAccessory].HideHair then
						for _, Child in ipairs(ServerStorage.LiveAssets[Character.Name]:GetChildren()) do
							if Child.ClassName == "Accessory" then
								Child.Parent = Character
							end
						end
					end
					if TradeablesData[CurrentAccessory].AnimationData then
						if TradeablesData[CurrentAccessory].AnimationData.Sprint then
							AccessoryData[Player.Name][ItemType] = nil
						end
					end
				end
				
				Character.Accessories[ItemType]:ClearAllChildren()
				
				if not Profile.AccessoriesVanity[ItemType] then
					local Accessory = ServerStorage.Assets.Accessories.AccessoryTypes[ItemType][AccessoryName]:Clone()
					local WrapsColor = Profile.ClientData.WrapsColor
					local HairColor = Profile.ClientData.HairColor
					if Accessory:IsA("Model") then
						for i, v in ipairs(Accessory:GetDescendants()) do
							if v:IsA("BasePart") and v:GetAttribute("Color") then
								v.Color = Color3.fromRGB(WrapsColor[1], WrapsColor[2], WrapsColor[3])
							elseif v:GetAttribute("HairColor") then
								v.Color = Color3.fromRGB(HairColor[1], HairColor[2], HairColor[3])
							end
						end
					else
						if Accessory:GetAttribute("Color") then
							Accessory.Color = Color3.fromRGB(WrapsColor[1], WrapsColor[2], WrapsColor[3])
						elseif Accessory:GetAttribute("HairColor") then
							Accessory.Color = Color3.fromRGB(HairColor[1], HairColor[2], HairColor[3])
						end
					end
					Accessory.Parent = Character.Accessories[ItemType]

					for _, AccessoryData in ipairs(TradeablesData[AccessoryName].AccessoryData) do
						local AccessoryPart = AccessoryData.Part0
						local BodyPart = Character[AccessoryData.Part1]

						local Weld = Instance.new("Weld")
						Weld.Part1 = BodyPart
						Weld.C0 = AccessoryData.C0

						if AccessoryPart == "self" then
							Weld.Part0 = Accessory
							Weld.Parent = Accessory
						else
							Weld.Part0 = Accessory[AccessoryPart]
							Weld.Parent = Accessory[AccessoryPart]
						end
					end

					if TradeablesData[AccessoryName].AnimationData then
						local Animation = TradeablesData[AccessoryName].AnimationData.Idle
						Accessory.AnimationController.Animator:LoadAnimation(Animation):Play()

						if TradeablesData[AccessoryName].AnimationData.Sprint then
							AccessoryData[Player.Name][ItemType] = TradeablesData[AccessoryName].AnimationData.Sprint
						end
						
						if TradeablesData[AccessoryName].AnimationData.Idle2 then
							local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle2
							Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
						end
						if TradeablesData[AccessoryName].AnimationData.Idle3 then
							local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle3
							Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
						end
						if TradeablesData[AccessoryName].AnimationData.Idle4 then
							local IdleAnimation = TradeablesData[AccessoryName].AnimationData.Idle4
							Accessory.AnimationController.Animator:LoadAnimation(IdleAnimation):Play()
						end
					end

					if TradeablesData[AccessoryName].HideName then
						Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					end
					if TradeablesData[AccessoryName].HideHair then
						for _, Child in ipairs(Character:GetChildren()) do
							if Child.ClassName == "Accessory" then
								if Child.Handle:FindFirstChild("AccessoryWeld") then
									Child.Handle.AccessoryWeld:Destroy()
								end
								Child.Parent = ServerStorage.LiveAssets[Character.Name]
							end
						end
					end
				end
				
				if TradeablesData[AccessoryName].StatBuffs then
					local Health = PlayerBonus:ApplyHealth(Player, Profile.ClientData.MaxHealth)
					local Reiatsu = PlayerBonus:ApplyReiatsu(Player, Profile.ClientData.MaxReiatsu)
					local Posture = PlayerBonus:ApplyPosture(Player, Profile.ClientData.MaxPosture)
					local TrueMaxReiatsu = PlayerBonus:ApplyReiatsu(Player, StatData.PlayerStats[Profile.ClientData.ShinigamiRank].Reiatsu)
					
					Character:SetAttribute("MaxHealth", Health)
					Character:SetAttribute("MaxReiatsu", Reiatsu)
					Character:SetAttribute("TrueMaxReiatsu", TrueMaxReiatsu)
					Character:SetAttribute("MaxPosture", Posture)
					
					Character.Humanoid.MaxHealth = Health
					if Character.Humanoid.Health >= Health then
						Character.Humanoid.Health = Health
					end
					if Character:GetAttribute("Reiatsu") > Reiatsu then
						Character:SetAttribute("Reiatsu", Reiatsu)
					end
					if Character:GetAttribute("Posture") > Posture then
						Character:SetAttribute("Posture", Posture)
					end
					
					local AccessoryReduction = Character:GetAttribute("AccessoryReduction") or 1
					AccessoryReduction -= TradeablesData[AccessoryName].StatBuffs.Defense
					Character:SetAttribute("AccessoryReduction", AccessoryReduction)
					
					if TradeablesData[AccessoryName].StatBuffs.MeterGain then
						local AccessoryMeterGain = Character:GetAttribute("AccessoryMeterGain") or 0
						AccessoryMeterGain += TradeablesData[AccessoryName].StatBuffs.MeterGain
						Character:SetAttribute("AccessoryMeterGain", AccessoryMeterGain)
					end
					if TradeablesData[AccessoryName].StatBuffs.MeterDrain then
						local AccessoryMeterDrainValue = 1 - TradeablesData[AccessoryName].StatBuffs.MeterDrain
						local AccessoryMeterDrain = Character:GetAttribute("AccessoryMeterDrain") or 1
						AccessoryMeterDrain -= AccessoryMeterDrainValue
						Character:SetAttribute("AccessoryMeterDrain", AccessoryMeterDrain)
					end
					if TradeablesData[AccessoryName].StatBuffs.HierroPen then
						local AccessoryHierroPen = Character:GetAttribute("AccessoryHierroPen") or 0
						AccessoryHierroPen += TradeablesData[AccessoryName].StatBuffs.HierroPen
						Character:SetAttribute("AccessoryHierroPen", AccessoryHierroPen)
					end
				end
			end
			
			ReplicatedStorage.Remotes.UpdateAccessoryEquipButton:FireClient(Player, AccessoryName)
		end
	end
end

function InventoryManager:UnequipAccessory(Player, AccessoryName)
	local Profile = DataManager:RequestProfile(Player)
	if Profile.ItemInventory[AccessoryName] then
		local ItemType = TradeablesData[AccessoryName].ItemType
		local SuccessfulUnequip = DataManager:ModifyEquippedAccessories(Player, ItemType, "Empty")
		if SuccessfulUnequip == "UnequipSuccess" then
			Profile.AccessoriesVanity[ItemType] = false
			
			if #Player.Character.Accessories[ItemType]:GetChildren() > 0 then
				Player.Character.Accessories[ItemType]:ClearAllChildren()
			end
			
			if TradeablesData[AccessoryName].AnimationData then
				if TradeablesData[AccessoryName].AnimationData.Sprint then
					AccessoryData[Player.Name][ItemType] = nil
				end
			end
			
			local Character = Player.Character
			if Character then
				if TradeablesData[AccessoryName].StatBuffs then
					local Health = PlayerBonus:ApplyHealth(Player, Profile.ClientData.MaxHealth)
					local Reiatsu = PlayerBonus:ApplyReiatsu(Player, Profile.ClientData.MaxReiatsu)
					local Posture = PlayerBonus:ApplyPosture(Player, Profile.ClientData.MaxPosture)
					local TrueMaxReiatsu = PlayerBonus:ApplyReiatsu(Player, StatData.PlayerStats[Profile.ClientData.ShinigamiRank].Reiatsu)
					
					Character:SetAttribute("MaxHealth", Health)
					Character:SetAttribute("MaxReiatsu", Reiatsu)
					Character:SetAttribute("TrueMaxReiatsu", TrueMaxReiatsu)
					Character:SetAttribute("MaxPosture", Posture)

					Character.Humanoid.MaxHealth = Health
					if Character.Humanoid.Health >= Health then
						Character.Humanoid.Health = Health
					end
					if Character:GetAttribute("Reiatsu") > Reiatsu then
						Character:SetAttribute("Reiatsu", Reiatsu)
					end
					if Character:GetAttribute("Posture") > Posture then
						Character:SetAttribute("Posture", Posture)
					end
					
					local AccessoryReduction = Character:GetAttribute("AccessoryReduction")
					if AccessoryReduction then
						AccessoryReduction += TradeablesData[AccessoryName].StatBuffs.Defense
						if AccessoryReduction == 1 then
							Character:SetAttribute("AccessoryReduction", nil)
						else
							Character:SetAttribute("AccessoryReduction", AccessoryReduction)
						end
					end
					
					if TradeablesData[AccessoryName].StatBuffs.MeterGain and Character:GetAttribute("AccessoryMeterGain") then
						local AccessoryMeterGain = Character:GetAttribute("AccessoryMeterGain")
						AccessoryMeterGain -= TradeablesData[AccessoryName].StatBuffs.MeterGain
						if AccessoryMeterGain == 0 then
							Character:SetAttribute("AccessoryMeterGain", nil)
						else
							Character:SetAttribute("AccessoryMeterGain", AccessoryMeterGain)
						end
					end
					if TradeablesData[AccessoryName].StatBuffs.MeterDrain and Character:GetAttribute("AccessoryMeterDrain") then
						local AccessoryMeterDrainValue = 1 - TradeablesData[AccessoryName].StatBuffs.MeterDrain
						local AccessoryMeterDrain = Character:GetAttribute("AccessoryMeterDrain")
						AccessoryMeterDrain += AccessoryMeterDrainValue
						if AccessoryMeterDrain == 1 then
							Character:SetAttribute("AccessoryMeterDrain", nil)
						else
							Character:SetAttribute("AccessoryMeterDrain", AccessoryMeterDrain)
						end
					end
					if TradeablesData[AccessoryName].StatBuffs.HierroPen and Character:GetAttribute("AccessoryHierroPen") then
						local AccessoryHierroPen = Character:GetAttribute("AccessoryHierroPen")
						AccessoryHierroPen -= TradeablesData[AccessoryName].StatBuffs.HierroPen
						if AccessoryHierroPen == 0 then
							Character:SetAttribute("AccessoryHierroPen", nil)
						else
							Character:SetAttribute("AccessoryHierroPen", AccessoryHierroPen)
						end
					end
				end
				
				if TradeablesData[AccessoryName].HideName then
					Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
				end
				if TradeablesData[AccessoryName].HideHair then
					for _, Child in ipairs(ServerStorage.LiveAssets[Character.Name]:GetChildren()) do
						if Child.ClassName == "Accessory" then
							Child.Parent = Character
						end
					end
				end
			end
		end
		
		ReplicatedStorage.Remotes.UpdateAccessoryEquipButton:FireClient(Player, AccessoryName)
	end
end

function InventoryManager:ToggleVanity(Player, AccessoryName)
	local Profile = DataManager:RequestProfile(Player)
	if Profile.ItemInventory[AccessoryName] then
		local ItemType = TradeablesData[AccessoryName].ItemType
		if Profile.Accessories[ItemType] == AccessoryName and Profile.AccessoriesVanity[ItemType] ~= nil then
			Profile.AccessoriesVanity[ItemType] = not Profile.AccessoriesVanity[ItemType]

			if not Profile.AccessoriesVanity[ItemType] then
				InventoryManager:EquipAccessory(Player, Profile.Accessories[ItemType])
			else
				if Player.Character.Accessories and #Player.Character.Accessories[ItemType]:GetChildren() > 0 then
					Player.Character.Accessories[ItemType]:ClearAllChildren()
				end
			end
		end
	end
end

function InventoryManager:CheckSkillReqs(Player, SkillName, Equipping)
	if ServerSkillReqs[SkillName] then
		local Profile = DataManager:RequestProfile(Player)	
		local Race = Profile.ClientData.Race
		local ShinigamiRank = Profile.ClientData.ShinigamiRank
		local DoesNotMeetReqs = nil
		
		if Equipping and ServerSkillReqs[SkillName].Unequippable then
			return nil
		end
		
		if table.find(Profile.UnlockedSkills, SkillName) then
			return SkillName
		end
		
		if table.find(AdminWhitelist.Admin, Player.UserId) and ServerSkillReqs[SkillName].SkillBox then
			return SkillName
		end
		
		if ServerSkillReqs[SkillName].Rank then
			if ShinigamiRank > ServerSkillReqs[SkillName].Rank then
				DoesNotMeetReqs = true
			end
		end
		
		for i = 1, 3 do
			if ServerSkillReqs[SkillName]["StatReq" .. i] then
				local Category = ServerSkillReqs[SkillName]["StatReq" .. i].Category
				local SPAmount = ServerSkillReqs[SkillName]["StatReq" .. i].SP
				if Category == "Special" then
					DoesNotMeetReqs = true
					break
				end
				if Profile.ClientData[Category] < SPAmount then
					DoesNotMeetReqs = true
				end
			end
		end
		
		if ServerSkillReqs[SkillName].StatReq1.Category == "Hakuda" and SkillName ~= "Hakuda Style" then
			if not table.find(Profile.UnlockedSkills, "Hakuda Style") then
				DoesNotMeetReqs = true
			end
		end
		
		if not ServerSkillReqs[SkillName].Race[Race] then
			DoesNotMeetReqs = true
		end

		if DoesNotMeetReqs then
			return nil
		end
		return SkillName
	else
		warn("[InventoryManager] Invalid skill name:", SkillName)
		return nil
	end
end

function InventoryManager:CheckItem(Player, ItemName, Equipping)
	if ServerItemReqs[ItemName] then
		local Profile = DataManager:RequestProfile(Player)	
		local Race = Profile.ClientData.Race
		local ShinigamiRank = Profile.ClientData.ShinigamiRank
		local DoesNotMeetReqs = nil
		
		if Equipping and ServerItemReqs[ItemName].Unequippable then
			return nil
		end

		if table.find(Profile.ItemInventory, ItemName) then
			return ItemName
		end

		if ServerItemReqs[ItemName].Rank then
			if ShinigamiRank > ServerItemReqs[ItemName].Rank then
				DoesNotMeetReqs = true
			end
		end

		if not ServerItemReqs[ItemName].Race[Race] then
			DoesNotMeetReqs = true
		end

		if DoesNotMeetReqs then
			return nil
		end
		return ItemName
	else
		warn("[InventoryManager]: Invalid item name:", ItemName)
		return nil
	end
end

function InventoryManager:PurchaseClothes(Player, Variant, Type)
	local Profile = DataManager:RequestProfile(Player)
	local Kan = Profile.ClientData.Kan	
	
	if StatData.Factions[Profile.ClientData.Race] == "Arrancar" and Type == "Arrancar" then
		if ServerStorage.Assets.Clothing.Arrancar:FindFirstChild("ArrancarShirt" .. Variant) then
			local KanPrice = ClothesData.Arrancar[Variant]
			if Kan >= KanPrice then
				KanPrice *= -1
				DataManager:AddKan(Player, KanPrice)
				
				Profile.ClientData.Clothes = Variant
				
				local Character = Player.Character
				local PreviousShirt = Character:FindFirstChildWhichIsA("Shirt")
				local PreviousPants = Character:FindFirstChildWhichIsA("Pants")
				if PreviousShirt then
					PreviousShirt:Destroy()
				end
				if PreviousPants then
					PreviousPants:Destroy()
				end

				local Shirt = ServerStorage.Assets.Clothing.Arrancar["ArrancarShirt" .. Variant]:Clone()
				Shirt.Parent = Character
				local Pants = ServerStorage.Assets.Clothing.Arrancar["ArrancarPants" .. Variant]:Clone()
				Pants.Parent = Character
			end
		end
	elseif StatData.Factions[Profile.ClientData.Race] == "Shinigami" and Type == "Shinigami" then
		if ServerStorage.Assets.Clothing.Shinigami:FindFirstChild("ShinigamiShirt" .. Variant) then
			local KanPrice = ClothesData.Shinigami[Variant]
			if Kan >= KanPrice then
				KanPrice *= -1
				DataManager:AddKan(Player, KanPrice)

				Profile.ClientData.Clothes = Variant
				
				local Character = Player.Character
				local PreviousShirt = Character:FindFirstChildWhichIsA("Shirt")
				local PreviousPants = Character:FindFirstChildWhichIsA("Pants")
				if PreviousShirt then
					PreviousShirt:Destroy()
				end
				if PreviousPants then
					PreviousPants:Destroy()
				end
				
				local Shirt = ServerStorage.Assets.Clothing.Shinigami["ShinigamiShirt" .. Variant]:Clone()
				Shirt.Parent = Character
				local Pants = ServerStorage.Assets.Clothing.Shinigami["ShinigamiPants" .. Variant]:Clone()
				Pants.Parent = Character
			end
		end
	end
end

function InventoryManager:CheckCeroPath(Player, SkillName)
	if ServerSkillReqs[SkillName] then
		local Profile = DataManager:RequestProfile(Player)	
		local UnlockedSkills = Profile.UnlockedSkills
		local NoPath = true
		
		local CeroPaths = {
			"Blade Cero";
			"Cero Cornea";
			"Finger Cero";
			"Tri Cero";
			"Cero Grab";
		}
		
		for i, CeroSkill in ipairs(CeroPaths) do
			if table.find(UnlockedSkills, CeroSkill) then
				NoPath = nil
			end
		end
		
		return NoPath
	end
end

function InventoryManager:PurchaseAccessory(Player, AccessoryName)
	if TradeablesData[AccessoryName] and Player:IsDescendantOf(Players) then
		local Profile = DataManager:RequestProfile(Player)
		local Kan = Profile.ClientData.Kan
		local KanPrice = TradeablesData[AccessoryName].Price
		local AllowedRaces = TradeablesData[AccessoryName].Race
		if KanPrice then
			if Kan >= KanPrice then
				if AllowedRaces then
					if AllowedRaces[Profile.ClientData.Race] then
						KanPrice *= -1
						DataManager:AddKan(Player, KanPrice)
						DataManager:AddItem(Player, AccessoryName, 1)

						local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientItems
						local PathData = {Module = ClientModule, Skill = "AccessoryBought"}
						local RenderDistance = -1
						NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData)
					end
				else
					KanPrice *= -1
					DataManager:AddKan(Player, KanPrice)
					DataManager:AddItem(Player, AccessoryName, 1)

					local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientItems
					local PathData = {Module = ClientModule, Skill = "AccessoryBought"}
					local RenderDistance = -1
					NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData)
				end
			end
		end
	end
end

function InventoryManager:PurchaseMarketItem(Player, ItemName)
	if TradeablesData[ItemName] and Player:IsDescendantOf(Players) then
		local Profile = DataManager:RequestProfile(Player)
		local Kan = Profile.ClientData.Kan
		local KanPrice = TradeablesData[ItemName].MarketPrice
		local AllowedRaces = TradeablesData[ItemName].Race
		local RaidPool = TradeablesData[ItemName].RaidPool
		
		local Pools = {
			Arrancar = {
				Arrancar = true;
				Vastocar = true;
			};
			Shinigami = {
				Shinigami = true;
				Visored = true;
			};
			Quincy = {
				Quincy = true;
			}
		}
		
		local RaceAllowed = true
		
		if KanPrice then
			if Kan >= KanPrice then
				if RaidPool and not Pools[RaidPool][Profile.ClientData.Race] then
					RaceAllowed = nil
				end
				if AllowedRaces and not AllowedRaces[Profile.ClientData.Race] then
					RaceAllowed = nil
				end
				
				if RaceAllowed then
					KanPrice *= -1
					DataManager:AddKan(Player, KanPrice)
					DataManager:AddItem(Player, ItemName, 1)

					local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientItems
					local PathData = {Module = ClientModule, Skill = "ItemBought"}
					local RenderDistance = -1
					NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData)
				end
			end
		end
	end
end

function InventoryManager:SellAccessory(Player, AccessoryName)
	if TradeablesData[AccessoryName] and TradeablesData[AccessoryName].SellPrice and Player:IsDescendantOf(Players) then
		local SellPrice = TradeablesData[AccessoryName].SellPrice
		
		local Profile = DataManager:RequestProfile(Player)
		local Accessories = Profile.Accessories
		local ItemInventory = Profile.ItemInventory
		
		if ItemInventory[AccessoryName] then
			local AlreadyEquipped
			for i, v in pairs(Accessories) do
				if v == AccessoryName then
					AlreadyEquipped = true
					break
				end
			end
			
			local LockedAccessory
			if AlreadyEquipped and ItemInventory[AccessoryName] <= 1 then
				LockedAccessory = true
			end
			
			if not LockedAccessory then
				local ItemRemoved = DataManager:RemoveItem(Player, AccessoryName, 1)
				if ItemRemoved then
					DataManager:AddKan(Player, SellPrice)

					local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientItems
					local PathData = {Module = ClientModule, Skill = "ItemSold"}
					local RenderDistance = -1
					NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData)
				end
			end
		end
	end
end

function InventoryManager:DropKan(Player, Amount)
	local Profile = DataManager:RequestProfile(Player)
	local Kan = Profile.ClientData.Kan
	local Character = Player.Character
	
	local DroppedKan = Amount
	if DroppedKan >= StatData.MaxKanDrop then
		DroppedKan = StatData.MaxKanDrop
	end
	
	local CurrentKan = Profile.ClientData.Kan
	CurrentKan -= DroppedKan
	if CurrentKan < 0 then
		DroppedKan = CurrentKan + DroppedKan
	end

	if DroppedKan > 0 then
		DataManager:AddKan(Player, -DroppedKan)
		Player:SetAttribute("DroppedKan", true)
		
		local Item = ServerStorage.Assets.Items.Models.Kan:Clone()
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
		
		local PathData = {Module = ClientItems, Skill = "ItemSold"}
		local RenderDistance = -1
		
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
							PickedUp = true
							Item:Destroy()
							Connection:Disconnect()
							Connection = nil
							DataManager:AddKan(PickupPlayer, DroppedKan)
							
							NetworkManager.FireClient(PickupPlayer, PickupCharacter, "ClientEffects", RenderDistance, PathData)
							
							local WebhookInfo = {
								Message = PickupPlayer.Name .. " has picked up " .. DroppedKan .. " kan from " .. Player.Name .. "\n" .. PickupPlayer.Name .. " kan: " .. PickupProfile.ClientData.Kan .. "\n" .. Player.Name .. " kan: " .. Profile.ClientData.Kan;
							}

							--Webhooks:Post(ItemWebhookChannel, WebhookInfo)
							
							if Player and Player:IsDescendantOf(Players) then
								Player:SetAttribute("DroppedKan", nil)
							end
						end
					end
				end
			end
		end)
	end
end

local ItemEquipCds = {}

ReplicatedStorage.Requests.RequestItemEquipped.OnServerInvoke = function(Player, TradeableName)
	if not RunService:IsServer() then return end
	if ItemEquipCds[Player.Name] then
		return
	end
	
	ItemEquipCds[Player.Name] = true
	task.delay(0.1, function()
		ItemEquipCds[Player.Name] = nil
	end)
	
	if TradeablesData[TradeableName] and Player:IsDescendantOf(Players) then
		local Profile = DataManager:RequestProfile(Player)
		local Accessories = Profile.Accessories
		
		local AlreadyEquipped
		for i, v in pairs(Accessories) do
			if v == TradeableName then
				AlreadyEquipped = true
			end
		end

		return AlreadyEquipped
	end
	return nil
end

--[[ReplicatedStorage.Requests.RequestSkillOwned.OnServerInvoke = function(Player, SkillName)
	if not RunService:IsServer() then return end
	if ServerSkillReqs[SkillName] and Player:IsDescendantOf(Players) then
		local Profile = DataManager:RequestProfile(Player)
		local UnlockedSkills = Profile.UnlockedSkills
		
		if table.find(UnlockedSkills, SkillName) then
			return true
		end
	end
	return nil
end]]

local SkillTreeInfoCds = {}

ReplicatedStorage.Requests.GetSkillTreeInfo.OnServerInvoke = function(Player)
	if not RunService:IsServer() then return end
	if Player:IsDescendantOf(Players) then
		if SkillTreeInfoCds[Player.Name] then
			return
		end
		
		SkillTreeInfoCds[Player.Name] = true
		task.delay(0.6, function()
			SkillTreeInfoCds[Player.Name] = nil
		end)

		local Profile = DataManager:RequestProfile(Player)
		local Grade = DataManager:RequestRank(Player)
		local ClanInfo = ClanData[Profile.ClientData.Clan]
		
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

		local ReturnInfo = {
			Name = Name .. " - " .. Grade;
			Info = ServerSkillReqs;
		}

		return ReturnInfo
	end
end

local TradeablesInfoCD = {}

ReplicatedStorage.Requests.GetTradeableInfo.OnServerInvoke = function(Player)
	if not RunService:IsServer() then return end
	if Player:IsDescendantOf(Players) then
		if TradeablesInfoCD[Player.Name] then
			return
		end

		TradeablesInfoCD[Player.Name] = true
		task.delay(1, function()
			TradeablesInfoCD[Player.Name] = nil
		end)
		
		local Profile = DataManager:RequestProfile(Player)
		local Grade = DataManager:RequestRank(Player)
		local ClanInfo = ClanData[Profile.ClientData.Clan]

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
		
		return TradeablesData
	end
end

--[[ReplicatedStorage.Requests.GetItemQuantity.OnServerInvoke = function(Player, Item)
	if not RunService:IsServer() then return end
	if TradeablesData[Item] and Player:IsDescendantOf(Players) then
		local Profile = DataManager:RequestProfile(Player)
		
		local Quantity = 0
		if Profile.ItemInventory[Item] then
			Quantity = Profile.ItemInventory[Item]
		end
		return Quantity
	end
end]]

--[[ReplicatedStorage.Requests.GetEntireInventory.OnServerInvoke = function(Player)
	if not RunService:IsServer() then return end
	local Accessories = {}

	local Profile = DataManager:RequestProfile(Player)
	if Profile then
		for i, v in pairs(Profile.ItemInventory) do
			if TradeablesData[i] and TradeablesData[i].Rarity ~= "Clan" and (TradeablesData[i].Rarity ~= "Unobtainable" or TradeablesData[i].Rarity == "Unobtainable" and TradeablesData[i].Tradeable) then
				Accessories[i] = v
			end
		end
	end

	return Accessories
end]]

return InventoryManager
