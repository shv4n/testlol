local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")

PhysicsService:RegisterCollisionGroup("Entity")
PhysicsService:RegisterCollisionGroup("Entity2")
PhysicsService:RegisterCollisionGroup("Carried")
PhysicsService:CollisionGroupSetCollidable("Carried", "Default", false)
PhysicsService:CollisionGroupSetCollidable("Entity", "Carried", false)
PhysicsService:CollisionGroupSetCollidable("Entity", "Entity2", false)
PhysicsService:CollisionGroupSetCollidable("Entity2", "Entity2", false)

local CombatManager = require(ServerStorage.Modules.Managers.CombatManager)
local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local RankManager = require(ServerStorage.Modules.Managers.RankManager)
local AntiCheatManager = require(ServerStorage.Modules.Managers.AntiCheatManager)
local ServerSkillReqs = require(ServerStorage.Modules.Utility.ServerSkillReqs)
local TradeablesData = require(ServerStorage.Modules.Utility.TradeablesData)
local InnerWorlds = require(ServerStorage.Modules.Utility.InnerWorlds)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local JailManager = require(ServerStorage.Modules.Managers.JailManager)
local AdminManager = require(ServerStorage.Modules.Managers.AdminManager)
local ProductFunctions = require(ServerStorage.Modules.Utility.ProductFunctions)
local FactionManager = require(ServerStorage.Modules.Managers.FactionManager)
local Teleports = require(ServerStorage.Modules.Utility.Teleports)
local Quests = require(ServerStorage.Modules.Utility.Quests)
local DamageTracker = require(ServerStorage.Modules.Utility.DamageTracker)

task.defer(function()
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.CombatAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.Animations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.ShikaiAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.HollowAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.SkillAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.ResAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.AccessoryAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.SpecAnimations:GetDescendants())
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets.VollstandigAnimations:GetDescendants())
end)

local function PlayerAdded(Player)
	DataManager:PlayerAdded(Player)
	CombatManager:SetupOvertimes(Player)
	AdminManager:CheckWhitelist(Player)
end

local function PlayerRemoved(Player)
	DataManager:PlayerRemoved(Player)
	CombatManager:ResetCombatTags(Player, Player)
	CombatManager:ClearAllTags(Player)
	CombatManager:CleanupOvertimes(Player.Name)
	InnerWorlds:EndShadowGarden(Player)
	InnerWorlds:Cleanup(Player)
	JailManager:Cleanup(Player.Name)
	AdminManager:CleanupData(Player.Name)
	FactionManager:Cleanup(Player.Name)
	FactionManager:RemovePlayer(Player)
	Quests:Cleanup(Player)
	DamageTracker:Cleanup(Player)
	ReplicatedStorage.Remotes.LeaderboardEvent:FireAllClients("Remove", Player.Name, {})
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoved)

-- In case Players have joined the server earlier than this script ran:
for _, Player in ipairs(Players:GetPlayers()) do
	coroutine.wrap(PlayerAdded)(Player)
end

local function CreateSkillTreeButtons()
	local SkillTree = ReplicatedStorage.Assets.UIs.SkillTree
	local Page1 = SkillTree.MainFrame.page1Frame
	local Page2 = SkillTree.MainFrame.page2Frame
	local Categories = {
		Hakuda = Page1.Hakuda.hakudaMain;
		Kendo = Page1.Kendo.kendoMain;
		Kido = Page1.Kido.kidoMain;
		Healing = Page2.Healing.healingMain;
		Speed = Page2.Speed.speedMain;
		Special = Page2.Special.specialMain;
	}

	for SkillName, Info in pairs(ServerSkillReqs) do
		local LayoutOrder = Info.StatReq1.SP
		if Info.StatReq2 then
			LayoutOrder += Info.StatReq2.SP
		end
		if Info.StatReq3 then
			LayoutOrder += Info.StatReq3.SP
		end
		
		local TemplateButton = ReplicatedStorage.Assets.UIs.InventoryTemplate:Clone()
		TemplateButton.Name = SkillName
		TemplateButton.Text = SkillName
		TemplateButton.LayoutOrder = LayoutOrder
		TemplateButton.Parent = Categories[Info.StatReq1.Category]
	end
end

local function GetGameVersion()
	local function FormatDateTime(ISO8601Date)
		local UnixDateTime = DateTime.fromIsoDate(ISO8601Date)
		local Month = UnixDateTime:FormatUniversalTime("MMM", "en-us")
		local Day = UnixDateTime:FormatUniversalTime("DD", "en-us")
		local Hour = UnixDateTime:FormatUniversalTime("HH", "en-us")
		local Minute = UnixDateTime:FormatUniversalTime("mm", "en-us")
		return "T-" .. Month .. "-" .. Day .. "_" .. Hour .. ":" .. Minute
	end

	local GameVersion = "T-" .. game.PlaceVersion
	ServerStorage.Assets.UIs.Settings.Frame.Version.Text = GameVersion

	local Success, Error = pcall(function()
		local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
		GameVersion = FormatDateTime(GameInfo.Updated)
		ServerStorage.Assets.UIs.Settings.Frame.Version.Text = GameVersion
	end)
	if not Success then
		warn(Error)
	end

	for _, Player in ipairs(Players:GetPlayers()) do
		local Settings = Player.PlayerGui:FindFirstChild("Settings")
		if Settings then
			Settings.Frame.Version.Text = GameVersion
		end
	end
end

local function GetServerRegion()
	local Region = "Region failed to load"
	
	if not RunService:IsStudio() then
		local Attempts = 5
		local CurrentAttempt = 0
		local Success, Response
		repeat
			Success, Response = pcall(function()
				return HttpService:GetAsync("http://ip-api.com/json/")
			end)

			CurrentAttempt += 1

			if not Success then
				task.wait(1)
			end
		until Success or CurrentAttempt > Attempts
		if Success then
			Response = HttpService:JSONDecode(Response)
			
			Region = "Server: " .. Response["country"] .. ", " .. Response["regionName"]
			ServerStorage.Assets.UIs.Settings.Frame.Region.Text = Region
			
			for _, Player in ipairs(Players:GetPlayers()) do
				local Settings = Player.PlayerGui:FindFirstChild("Settings")
				if Settings then
					Settings.Frame.Region.Text = Region
				end
			end
		else
			warn(Response)
		end
	else
		ServerStorage.Assets.UIs.Settings.Frame.Region.Text = "Server: STUDIO"
		for _, Player in ipairs(Players:GetPlayers()) do
			local Settings = Player.PlayerGui:FindFirstChild("Settings")
			if Settings then
				Settings.Frame.Region.Text = "Server: STUDIO"
			end
		end
	end
end

local function CreateAccessoryShopButtons()
	local AccessoryShop = ReplicatedStorage.Assets.UIs.ShopUI
	local MainFrame = AccessoryShop.MainBase
	
	local AccessoryTypes = {
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

	for AccessoryName, Info in pairs(TradeablesData) do
		local Type = Info.ItemType
		if table.find(AccessoryTypes, Type) then
			local LayoutOrder = Info.Price
			if LayoutOrder then
				local TemplateButton = ReplicatedStorage.Assets.UIs.AccessoryTemplate:Clone()
				TemplateButton.Name = AccessoryName
				TemplateButton.Text = AccessoryName
				TemplateButton.LayoutOrder = LayoutOrder
				TemplateButton.Parent = MainFrame.AccessoryTypes[Type .. "Frame"]
			end
		end
	end
end

local function CreateProductButtons()
	local SkillTree = ReplicatedStorage.Assets.UIs.SkillTree
	local ProductFrame = SkillTree.MainFrame.page3Frame.devproductsFrame
	local ProductScrollFrame = ProductFrame.devproductsMain
	
	for ProductName, Info in pairs(ProductFunctions.Products) do
		local LayoutOrder = Info.Price

		local TemplateButton = ReplicatedStorage.Assets.UIs.InventoryTemplate:Clone()
		TemplateButton.Name = ProductName
		TemplateButton.Text = ProductName
		TemplateButton.LayoutOrder = LayoutOrder
		TemplateButton.Parent = ProductScrollFrame
	end
end

local function CreateMarketItems()
	local function comma_value(amount)
		local formatted = amount
		local k
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
	end
	
	local AccessoryTypes = {
		"Head";
		"Face";
		"Neck";
		"Shoulder";
		"Arm";
		"Torso";
		"Back";
		"Waist";
		"Leg";
		"Item";
	}	
	
	local Market = ReplicatedStorage.Assets.UIs.MarketUI

	for ItemName, Info in pairs(TradeablesData) do
		local Type = Info.ItemType
		if table.find(AccessoryTypes, Type) then
			local LayoutOrder = Info.MarketPrice
			if LayoutOrder then
				local TemplateButton = ReplicatedStorage.Assets.UIs.MarketTemplateShop:Clone()
				TemplateButton.Name = ItemName
				TemplateButton.Text = ItemName
				TemplateButton.Price.Text = "$" .. comma_value(LayoutOrder)
				TemplateButton.LayoutOrder = LayoutOrder
				TemplateButton.Parent = Market.Shop.ScrollingFrame
			end
		end
	end
end

coroutine.wrap(CreateSkillTreeButtons)()
coroutine.wrap(CreateAccessoryShopButtons)()
coroutine.wrap(CreateProductButtons)()
coroutine.wrap(CreateMarketItems)()
coroutine.wrap(GetGameVersion)()
coroutine.wrap(GetServerRegion)()
