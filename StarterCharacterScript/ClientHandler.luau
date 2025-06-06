-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGUI = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local PlayerGui = Player.PlayerGui

-- Modules --
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local CameraController = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras()

-- Debounces --
local ViewportAllowed

-- Event Connections & Variables --
local SprintToggle = "Shift"
local FlashstepToggle = "Q"
local Shiftlocked = false
local ControlsInverted = false
local InvertedTimer = 0
local CurrentSaturation = Lighting.ColorCorrection.Saturation

local QueuedBlock = false
local Mouse = Player:GetMouse()
local ShiftlockKeys = {Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt}
local ShikaiInputs = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}
local BankaiInputs = {Enum.KeyCode.G, Enum.KeyCode.T}
local SkillInputs = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
	Enum.KeyCode.Minus,
	Enum.KeyCode.Equals,
}

local ServerIndex = {}
ServerIndex.Skills = {}

local SkillTreeInfo = ServerIndex.SkillTreeInfo

local Places = {
	14069122388; -- Hueco Mundo
	14069678431; -- Karakura Town
	14069956183; -- Rukon District
	14070029709; -- Soul Society
}

--local FrameGUIs = PlayerGui.MainGUI.MainFrame

-- Folders --

local Animations = ReplicatedStorage.Assets.Animations
local Remotes = script.Parent:WaitForChild("CharacterHandler"):WaitForChild("Remotes")
local SharedRemotes = ReplicatedStorage.Remotes

-- GUI Related Code --

local ViewportOffset = CFrame.new(0, 1, -4)

local MainFrame = PlayerGui.DisplayUI.Collage.MainFrame
local HealthBar = MainFrame.Health.HealthBack.ImageLabel
local PostureBar = MainFrame.Posture.Slider
local ReiatsuBar = MainFrame.Rei.Slider.ReiBack.ImageLabel
local CombatTag = MainFrame.deathHUD
local NormalHUD = MainFrame.normalHUD

local PartyFrame = PlayerGui.MissionsUI.MainFrame
local PartyScrollFrame = PartyFrame.ScrollingFrame
local CreatePartyButton = PlayerGui.MissionsUI.CreatePartyFrame.CreateParty
local PartyInviteFrame = PlayerGui.MissionsUI.PartyInvite
local CloseFrame = PlayerGui.MissionsUI.CloseFrame

local BailOfferFrame = PlayerGui.ScreenEffects.BailOffer

local ShikaiBankai = PlayerGui.ShikaiBankai
local BankaiBar = ShikaiBankai.bankaiFrame.backgroundBar.bankaiBar
local SecondBankaiBar = ShikaiBankai.resFrame.backgroundBar.resBar

local SkillTreeClone = ReplicatedStorage.Assets.UIs.SkillTree:Clone()
SkillTreeClone.Parent = PlayerGui

local AccessoryShopClone = ReplicatedStorage.Assets.UIs.ShopUI:Clone()
AccessoryShopClone.Parent = PlayerGui

local MarketClone = ReplicatedStorage.Assets.UIs.MarketUI:Clone()
MarketClone.Parent = PlayerGui

local SkillMainFrame = SkillTreeClone.MainFrame
local SkillKeys = SkillMainFrame.SkillTreeKeys
local SkillPage1 = SkillMainFrame.page1Frame
local SkillPage2 = SkillMainFrame.page2Frame
local AccessoryPage3 = SkillMainFrame.page3Frame
local SkillInfoFrame = SkillMainFrame.skillInfoFrame
local AccessoryInfoFrame = SkillMainFrame.accessoryInfoFrame
local LearnSkillButton = SkillMainFrame.learnSkillFrame.learnSkillBtn
local EquipSkillButton = SkillMainFrame.equipFrame.equipBtn
local NextButton = SkillMainFrame.nextFrame.nextFrameBtn
local BackButton = SkillMainFrame.backFrame.backFrameBtn
local ResetSPButton = SkillMainFrame.resetSPFrame.resetSPBtn
local ServerList = PlayerGui.ServerMenu
local TradeUI = PlayerGui.Trading

local TradeablesFrame = {
	AccessoryPage3.accessoriesFrame.accessoriesMain;
	AccessoryPage3.itemsFrame.itemsMain;
}

local LayoutOrder = {
	Skill = 1;
	Head = 1;
	Face = 2;
	Neck = 3;
	Shoulder = 4;
	Arm = 5;
	Torso = 6;
	Back = 7;
	Waist = 8;
	Leg = 9;
}

local RarityColors = {
	Common = Color3.fromRGB(255, 255, 255);
	Uncommon = Color3.fromRGB(124, 255, 94);
	Rare = Color3.fromRGB(120, 255, 255);
	Legendary = Color3.fromRGB(255, 0, 0);
	Mythical = Color3.fromRGB(207, 115, 167);
	Clan = Color3.fromRGB(207, 179, 232);
	Unobtainable = Color3.fromRGB(255, 251, 184)
}

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

local SkillTreeFrames = {
	SkillMainFrame.page1Frame.Hakuda.hakudaMain;
	SkillMainFrame.page1Frame.Kendo.kendoMain;
	SkillMainFrame.page1Frame.Kido.kidoMain;
	SkillMainFrame.page2Frame.Healing.healingMain;
	SkillMainFrame.page2Frame.Speed.speedMain;
	SkillMainFrame.page2Frame.Special.specialMain;

}

local AddSPButtons = {
	SkillMainFrame.page1Frame.Hakuda.addSP;
	SkillMainFrame.page1Frame.Kendo.addSP;
	SkillMainFrame.page1Frame.Kido.addSP;
	SkillMainFrame.page2Frame.Healing.addSP;
	SkillMainFrame.page2Frame.Speed.addSP;
}

local SPToolTips = {
	SkillMainFrame.page1Frame.Hakuda.Info;
	SkillMainFrame.page1Frame.Kendo.Info;
	SkillMainFrame.page1Frame.Kido.Info;
	SkillMainFrame.page2Frame.Healing.Info;
	SkillMainFrame.page2Frame.Speed.Info;
}

local SkillTreeEquipKeys = {
	SkillKeys.Zero;
	SkillKeys.One;
	SkillKeys.Two;
	SkillKeys.Three;
	SkillKeys.Four;
	SkillKeys.Five;
	SkillKeys.Six;
	SkillKeys.Seven;
	SkillKeys.Eight;
	SkillKeys.Nine;
	SkillKeys.Minus;
	SkillKeys.Equals;
}

local ToolbarDisplayKeys = {
	PlayerGui.Toolbar.Frame.Zero;
	PlayerGui.Toolbar.Frame.One;
	PlayerGui.Toolbar.Frame.Two;
	PlayerGui.Toolbar.Frame.Three;
	PlayerGui.Toolbar.Frame.Four;
	PlayerGui.Toolbar.Frame.Five;
	PlayerGui.Toolbar.Frame.Six;
	PlayerGui.Toolbar.Frame.Seven;
	PlayerGui.Toolbar.Frame.Eight;
	PlayerGui.Toolbar.Frame.Nine;
	PlayerGui.Toolbar.Frame.Minus;
	PlayerGui.Toolbar.Frame.Equals;
}

local CategoryParent = {
	Hakuda = SkillPage1.Hakuda.hakudaMain;
	Kendo = SkillPage1.Kendo.kendoMain;
	Kido = SkillPage1.Kido.kidoMain;
	Healing = SkillPage2.Healing.healingMain;
	Speed = SkillPage2.Speed.speedMain;
	Special = SkillPage2.Special.specialMain;
}

local ShikaiKeys = {
	"Z";
	"X";
	"C";
	"G";
	"T";
}

local Page = 1
local Pages = {
	SkillPage1;
	SkillPage2;
	AccessoryPage3;
}

local DialogueFrame = PlayerGui:WaitForChild("DialogueUI").dialogueFrame

local function UIHoverAudio()
	local UIEnter = ReplicatedStorage.Assets.Sounds.UIHover:Clone()
	UIEnter.PlayOnRemove = true
	UIEnter.Parent = workspace
	UIEnter:Destroy()
	UIEnter = nil
end

local function UIClickAudio()
	local UIClick = ReplicatedStorage.Assets.Sounds.UIClick:Clone()
	UIClick.PlayOnRemove = true
	UIClick.Parent = workspace
	UIClick:Destroy()
	UIClick = nil
end

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

-- Inventory Viewport --

local ViewportConnection
local Viewport = AccessoryInfoFrame.ViewportFrame
local Camera = Instance.new("Camera")

Viewport.CurrentCamera = Camera

local ValidClasses = {
	["MeshPart"] = true; ["Part"] = true; ["Accoutrement"] = true;
	["Pants"] = true; ["Shirt"] = true;
	["Humanoid"] = true;
}

local RenderObjects = {}

local function RemoveObject(Object)
	local Clone = RenderObjects[Object]
	if not Clone then return nil end

	RenderObjects[Object] = nil
	if Clone.Parent:IsA("Accoutrement") then
		Clone.Parent:Destroy()
	else
		Clone:Destroy()
	end
end

local function AddObject(Object)
	if not ValidClasses[Object.ClassName] then
		return nil
	end

	local a = Object.Archivable
	Object.Archivable = true
	local RenderClone = Object:Clone()
	Object.Archivable = a

	if Object.ClassName == "MeshPart" or Object.ClassName == "Part" then
		RenderObjects[Object] = RenderClone
		
	elseif Object:IsA("Accoutrement") then
		RenderObjects[Object.Handle] = RenderClone.Handle

	elseif Object.ClassName == "Humanoid" then
		--Disable all states. We only want it for clothing wrapping.
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Running, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		RenderClone:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		RenderClone.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	
	return RenderClone
end

local function UpdateViewport()
	if ViewportAllowed then
		ViewportConnection = RunService.RenderStepped:Connect(function(DeltaTime)
			if (not Character:FindFirstChild("HumanoidRootPart")) or Page ~= 3 or SkillMainFrame.Parent.Enabled == false then
				ViewportConnection:Disconnect()
				ViewportConnection = nil
				return nil
			end
			
			-- Update camera
			Camera.CFrame = CFrame.new(Character.HumanoidRootPart.CFrame:ToWorldSpace(ViewportOffset).Position, Character.HumanoidRootPart.Position)
			
			-- Update objects
			for Original, Clone in pairs(RenderObjects) do
				if Original and Original.Parent then
					Clone.CFrame = Original.CFrame
				else
					RemoveObject(Original)
				end
			end
		end)
	end
end

local function HandleChar()
	local Viewmodel = Instance.new("Model")
	Viewmodel.Name = "PlayerViewmodel"
	Viewmodel.Parent = Viewport

	local CharObjects = Character:GetDescendants()
	for i, Object in pairs(CharObjects) do
		local RenderClone = AddObject(Object)
		if RenderClone then
			RenderClone.Parent = Viewmodel
		end
	end
	
	local FakeHead = workspace.Effects[Character.Name]:FindFirstChild(Character.Name .. "Head")
	if FakeHead then
		local AddSuccess = AddObject(FakeHead)
		if AddSuccess then
			AddSuccess.Parent = Viewmodel
		end
	end
	
	Character.DescendantAdded:Connect(function(NewObject)
		local RenderClone = AddObject(NewObject)
		if RenderClone then
			RenderClone.Parent = Viewmodel
		end
	end)
	Character.DescendantRemoving:Connect(function(OldObject)
		RemoveObject(OldObject)
	end)
end

-- UI Connections & Tweening
Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	if Character:GetAttribute("MaxHealth") then
		local Health = (Humanoid.Health / Character:GetAttribute("MaxHealth")) -- Humanoid.MaxHealth
		HealthBar:TweenSize(UDim2.new(Health, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
	end
end)

Character:GetAttributeChangedSignal("Posture"):Connect(function()
	local Posture = (Character:GetAttribute("Posture") / Character:GetAttribute("MaxPosture"))
	PostureBar:TweenSize(UDim2.new(Posture, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
end)

Character:GetAttributeChangedSignal("Reiatsu"):Connect(function()
	local Reiatsu = (Character:GetAttribute("Reiatsu") / Character:GetAttribute("TrueMaxReiatsu")) -- Character:GetAttribute("MaxReiatsu")
	ReiatsuBar:TweenSize(UDim2.new(Reiatsu, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
end)

Character:GetAttributeChangedSignal("BankaiMeter"):Connect(function()
	local BankaiMeter = (Character:GetAttribute("BankaiMeter") / Character:GetAttribute("MaxBankaiMeter"))
	BankaiBar:TweenSize(UDim2.new(1, 0, -BankaiMeter, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
end)

Character:GetAttributeChangedSignal("SecondBankaiMeter"):Connect(function()
	local SecondBankaiMeter = (Character:GetAttribute("SecondBankaiMeter") / Character:GetAttribute("MaxSecondBankaiMeter"))
	SecondBankaiBar:TweenSize(UDim2.new(1, 0, -SecondBankaiMeter, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
end)

Character:GetAttributeChangedSignal("Kan"):Connect(function()
	PlayerGui.Currency.Frame.KanLabel.Text = comma_value(Character:GetAttribute("Kan"))
end)

-- Sound Regions --

local CurrentRegion = "Default"
local MusicConnection
local SoundRegions = {
	Palace = {
		workspace.Ambience.Palace
	};
	Default = {
		workspace.Ambience.Ambience;
		workspace.Ambience.Ambience2;
	};
	InnerWorld = {
		workspace.Ambience.InnerWorld;
	};
	BankaiQuest = {
		workspace.Ambience.BankaiOST;
	};
	Raid = {};
}

local PlayerRaid = workspace:FindFirstChild("PlayerRaid")
if PlayerRaid then
	for i = 1, 6 do
		local Audio = PlayerRaid:FindFirstChild("PlayerRaidAudio" .. i)
		if Audio then
			table.insert(SoundRegions.Raid, Audio)
		end
	end
end

local OP = OverlapParams.new()
OP.FilterType = Enum.RaycastFilterType.Include
OP.FilterDescendantsInstances = {Character}

local Accumulated = 0
local Rate = 1
local Ambience = workspace.Ambience

RunService.RenderStepped:Connect(function(DeltaTime)
	Accumulated += DeltaTime
	if Accumulated > Rate then
		Accumulated -= Rate
		
		local InnerWorldRegion = workspace.InnerWorldPlots:FindFirstChild(Player.Name .. "InnerWorld")
		local PalaceRegion = workspace["Royal Palace"]:FindFirstChild("PalaceRegion")
		if Character:GetAttribute("CurrentOST") then
			CurrentRegion = Character:GetAttribute("CurrentOST")
		elseif Character:GetAttribute("RaidMusic") and not Ambience:GetAttribute("HuntActive") then
			CurrentRegion = "Raid"
		elseif InnerWorldRegion and InnerWorldRegion:FindFirstChild("InnerWorldRegion") then
			local RegionCheck = workspace:GetPartsInPart(InnerWorldRegion.InnerWorldRegion, OP)
			if table.find(RegionCheck, Character.PrimaryPart) then
				CurrentRegion = "InnerWorld"
			else
				CurrentRegion = "Default"
			end
		elseif PalaceRegion then
			local RegionCheck = workspace:GetPartsInPart(PalaceRegion, OP)
			if table.find(RegionCheck, Character.PrimaryPart) then
				CurrentRegion = "Palace"
			else
				CurrentRegion = "Default"
			end
		else
			CurrentRegion = "Default"
		end
		
		if CurrentRegion == "Raid" then
			if #workspace.CombatMusic.CurrentMusic:GetChildren() > 0 then
				for i, v in ipairs(workspace.CombatMusic.CurrentMusic:GetChildren()) do
					v:Stop()
					v:Destroy()
				end
			end
		else
			for i, v in pairs(SoundRegions) do
				if i ~= CurrentRegion then
					for _, Sounds in ipairs(v) do
						if Sounds.IsPlaying then
							Sounds:Stop()		
						end
					end
				else
					for _, Sounds in ipairs(v) do
						if not Sounds.IsPlaying and Character:GetAttribute("CombatTag") == 0 and Ambience:GetAttribute("RaidActive") == false and Ambience:GetAttribute("HuntActive") == false then
							Sounds:Play()	
						end
					end
				end
			end
		end
	end
end)

-- Input Related Code --

local function MousePosition(RangeLimit)
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Character}
	
	local Range = RangeLimit or 1000
	
	local MousePosition = Mouse.UnitRay.Origin + (Mouse.UnitRay.Direction * Range)
	local MouseRay = workspace:Raycast(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * Range, Params)
	if MouseRay then
		MousePosition = MouseRay.Position	
	end

	return MousePosition
end

--[[local function TargetByMouse(MouseRange, Range, PartyFilter, PartyBlacklist, UnconsciousBlacklist, UnconsciousFilter)
	local MousePosition = MousePosition(MouseRange)
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Entities}
	
	local Results = workspace:GetPartBoundsInRadius(MousePosition, Range, Params)
	if Results then
		local Detected = {}
		
		local NearestUnconscious, NearestUnconsciousDistance
		local NearestPartyMember, NearestPartyMemberDistance
		local NearestEntity, NearestDistance
		for _, Part in ipairs(Results) do
			local Humanoid = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")
			if Humanoid then
				local Entity = Humanoid.Parent

				if Humanoid:GetState() == Enum.HumanoidStateType.Dead then
					continue
				end

				if Entity.Parent ~= workspace.Entities then
					continue
				end

				if Detected[Entity.Name] then
					continue
				end
				
				Detected[Entity.Name] = true
				
				local ZombieOwner
				if Character:GetAttribute("ZombieOwner") == Entity.Name or (Entity:GetAttribute("ZombieOwner") ~= nil and Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner")) then
					ZombieOwner = true
				end
				
				local NoUnconsciousFilter = true
				if UnconsciousBlacklist and Entity:GetAttribute("CurrentState") == "Unconscious" then
					NoUnconsciousFilter = nil
				end
				
				if Entity.Name ~= Player.Name and Entity.PrimaryPart and Entity:FindFirstChild("Humanoid") and Entity.Humanoid.Health > 0 and Entity:GetAttribute("IFrames") == false and not Entity:GetAttribute("Carried") and not ZombieOwner and NoUnconsciousFilter then	
					local Magnitude = (MousePosition - Entity.HumanoidRootPart.Position).Magnitude
					local NotPartyBlacklist = true
					if PartyBlacklist and Player:GetAttribute("Party") ~= nil then
						local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
						if TargetPlayer then
							if Player:GetAttribute("Party") == TargetPlayer:GetAttribute("Party") then
								NotPartyBlacklist = nil
							end
						end
					end
					
					if Magnitude < Range and NotPartyBlacklist then				
						if not NearestEntity then
							NearestEntity, NearestDistance = Entity, Magnitude
						else
							if Magnitude < NearestDistance then
								NearestEntity, NearestDistance = Entity, Magnitude
							end
						end
					end

					if PartyFilter and Player:GetAttribute("Party") ~= nil then
						local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
						if TargetPlayer then
							if Player:GetAttribute("Party") == TargetPlayer:GetAttribute("Party") then	
								local PartyMagnitude = (MousePosition - Entity.HumanoidRootPart.Position).Magnitude
								if PartyMagnitude < Range then				
									if not NearestPartyMember then
										NearestPartyMember, NearestPartyMemberDistance = Entity, PartyMagnitude
									else
										if PartyMagnitude < NearestPartyMemberDistance then
											NearestPartyMember, NearestPartyMemberDistance = Entity, PartyMagnitude
										end
									end
								end	
							end
						end
					end
					
					if UnconsciousFilter and Entity:GetAttribute("CurrentState") == "Unconscious" then
						local UnconsciousMagnitude = (MousePosition - Entity.HumanoidRootPart.Position).Magnitude
						if not NearestUnconscious then
							NearestUnconscious, NearestUnconsciousDistance = Entity, UnconsciousMagnitude
						else
							if UnconsciousMagnitude < NearestUnconsciousDistance then
								NearestUnconscious, NearestUnconsciousDistance = Entity, UnconsciousMagnitude
							end
						end
					end
				end
			end
		end

		if NearestPartyMember then
			return NearestPartyMember
		elseif NearestUnconscious then
			return NearestUnconscious
		end

		return NearestEntity
	end
end]]

local function TargetByMouse(MouseRange, Range, PartyFilter, PartyBlacklist, UnconsciousBlacklist, UnconsciousFilter)
	local CurrentCamera = workspace.CurrentCamera
	
	local CurrentMousePosition = UserInputService:GetMouseLocation()
	
	local NearestUnconscious, NearestUnconsciousDistance
	local NearestPartyMember, NearestPartyMemberDistance
	local NearestEntity, NearestDistance
	for _, Entity in ipairs(workspace.Entities:GetChildren()) do
		if Entity.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		
		local ZombieOwner
		if Character:GetAttribute("ZombieOwner") == Entity.Name or (Entity:GetAttribute("ZombieOwner") ~= nil and Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner")) then
			ZombieOwner = true
		end
		
		local NoUnconsciousFilter = true
		if UnconsciousBlacklist and Entity:GetAttribute("CurrentState") == "Unconscious" then
			NoUnconsciousFilter = nil
		end
		
		local Encompass
		local EncompassPosition = Entity:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = Entity:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (Entity.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
			end
		end
		
		local CharacterBlacklist
		if Entity:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		if Entity.Name ~= Player.Name and Entity.PrimaryPart and Entity:FindFirstChild("Humanoid") and Entity.Humanoid.Health > 0 and Entity:GetAttribute("IFrames") == false and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Carried") and not ZombieOwner and NoUnconsciousFilter and not Encompass and not CharacterBlacklist then
			local Vector, OnScreen = CurrentCamera:WorldToScreenPoint(Entity.HumanoidRootPart.Position)
			
			if not OnScreen then
				continue
			end
			
			local ScreenPosition = Vector2.new(Vector.X, Vector.Y)	
			local Magnitude = (CurrentMousePosition - ScreenPosition).Magnitude
			
			local NotPartyBlacklist = true
			if PartyBlacklist and Player:GetAttribute("Party") ~= nil then
				local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
				if TargetPlayer then
					if Player:GetAttribute("Party") == TargetPlayer:GetAttribute("Party") then
						NotPartyBlacklist = nil
					end
				end
			end
			
			if Magnitude < Range and NotPartyBlacklist then				
				if not NearestEntity then
					NearestEntity, NearestDistance = Entity, Magnitude
				else
					if Magnitude < NearestDistance then
						NearestEntity, NearestDistance = Entity, Magnitude
					end
				end
			end
			
			if PartyFilter and Player:GetAttribute("Party") ~= nil then
				local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
				if TargetPlayer then
					if Player:GetAttribute("Party") == TargetPlayer:GetAttribute("Party") then	
						local PartyMagnitude = (CurrentMousePosition - ScreenPosition).Magnitude
						
						if PartyMagnitude < Range then				
							if not NearestPartyMember then
								NearestPartyMember, NearestPartyMemberDistance = Entity, PartyMagnitude
							else
								if PartyMagnitude < NearestPartyMemberDistance then
									NearestPartyMember, NearestPartyMemberDistance = Entity, PartyMagnitude
								end
							end
						end	
					end
				end
			end
			
			if UnconsciousFilter and Entity:GetAttribute("CurrentState") == "Unconscious" then
				local UnconsciousMagnitude = (CurrentMousePosition - ScreenPosition).Magnitude
				if not NearestUnconscious then
					NearestUnconscious, NearestUnconsciousDistance = Entity, UnconsciousMagnitude
				else
					if UnconsciousMagnitude < NearestUnconsciousDistance then
						NearestUnconscious, NearestUnconsciousDistance = Entity, UnconsciousMagnitude
					end
				end
			end
		end
	end
	
	if NearestPartyMember then
		return NearestPartyMember
	elseif NearestUnconscious then
		return NearestUnconscious
	end
	
	return NearestEntity
end

local function TradeRequest(Action, TradingPlayer)
	if Action == "Invite" then
		-- send trade request, wait for accept/decline
		if not TradeUI.Requests.ScrollingFrame:FindFirstChild(TradingPlayer.Name) then
			local NameTemplate = TradeUI.NameTemplate:Clone()
			NameTemplate.Visible = true
			NameTemplate.Name = TradingPlayer.Name
			NameTemplate.Text = TradingPlayer.Name
			NameTemplate.Parent = TradeUI.Requests.ScrollingFrame

			local Response = false
			
			NameTemplate.MouseButton1Click:Once(function()
				NameTemplate:Destroy()
				NameTemplate = nil
				Response = true
			end)
			
			local Time = 30
			repeat
				local Step = task.wait()
				Time -= Step
			until Time <= 0 or Response
			
			if NameTemplate then
				NameTemplate:Destroy()
			end
			
			return Response
		else
			return false
		end
	elseif Action == "Update" then
		-- Update items
		return nil
	end
end

ReplicatedStorage.Requests.GetCameraToMouse.OnClientInvoke = MousePosition --[[ function()	
	return Mouse.Hit.Position
end]]

ReplicatedStorage.Requests.GetTargetByMouse.OnClientInvoke = TargetByMouse

ReplicatedStorage.Requests.GetKeyHeld.OnClientInvoke = function(Key)
	return UserInputService:IsKeyDown(Key)
end

ReplicatedStorage.Requests.GetShiftlocked.OnClientInvoke = function()
	return Shiftlocked
end

ReplicatedStorage.Requests.TradeRequest.OnClientInvoke = TradeRequest


ReplicatedStorage.Requests.AfkPrompt.OnClientInvoke = function(Time)
	local Settings = PlayerGui:WaitForChild("Settings", 8)
	if Settings then
		local Confirmed
		local Connections = {}
		
		local Position1 = UDim2.new(0.25, 0, 0.8, 0)
		local Position2 = UDim2.new(0.75, 0, 0.8, 0)
		
		if math.random(1, 2) == 2 then
			Settings.RaidConfirm.Yes.Position = Position2
			Settings.RaidConfirm.No.Position = Position1
		end
		
		Settings.RaidConfirm.Visible = true

		Connections[1] = Settings.RaidConfirm.Yes.MouseButton1Click:Connect(function()
			Confirmed = true
			Settings.RaidConfirm.Visible = false
		end)
		Connections[2] = Settings.RaidConfirm.No.MouseButton1Click:Connect(function()
			Confirmed = false
			Settings.RaidConfirm.Visible = false
		end)
		
		while true do
			task.wait()
			
			Settings.RaidConfirm.Time.Text = "Time Left: " .. math.round((Time - workspace:GetServerTimeNow()) * 10)/10
			
			if Confirmed ~= nil or Time - workspace:GetServerTimeNow() <= 0 then
				break
			end
		end
		
		Settings.RaidConfirm.Visible = false
		
		for i, v in ipairs(Connections) do
			Connections[i]:Disconnect()
			Connections[i] = nil
		end
		
		return Confirmed
	end
end

local function ShikaiSkill(ActionName, InputState, InputObject)	
	if ActionName == "ShikaiSkill" then
		if TradeUI.Enabled then
			return
		end
		
		local KeyPressed = InputObject.KeyCode.Name
		if ControlsInverted then
			KeyPressed = ShikaiInputs[math.random(1, #ShikaiInputs)].Name
		end
		
		if Character:GetAttribute(KeyPressed) ~= true then
			if InputState == Enum.UserInputState.Begin then
				--Remotes.ShikaiSkill:FireServer(KeyPressed, "Pressed")
				SharedRemotes.ServerCombatHandler:FireServer("ShikaiSkill", KeyPressed, "Pressed")
			elseif InputState == Enum.UserInputState.End then
				SharedRemotes.ServerCombatHandler:FireServer("ShikaiSkill", KeyPressed, "Released")
				--Remotes.ShikaiSkill:FireServer(KeyPressed, "Released")
			end
		end
	end
end

local function BankaiSkill(ActionName, InputState, InputObject)
	if ActionName == "BankaiSkill" then
		local KeyPressed = InputObject.KeyCode.Name
		if ControlsInverted then
			KeyPressed = BankaiInputs[math.random(1, #BankaiInputs)].Name
		end
		
		if Character:GetAttribute(KeyPressed) ~= true then
			if InputState == Enum.UserInputState.Begin then
				--Remotes.BankaiSkill:FireServer(KeyPressed, "Pressed")
				SharedRemotes.ServerCombatHandler:FireServer("BankaiSkill", KeyPressed, "Pressed")
			elseif InputState == Enum.UserInputState.End then
				SharedRemotes.ServerCombatHandler:FireServer("BankaiSkill", KeyPressed, "Released")
				--Remotes.BankaiSkill:FireServer(KeyPressed, "Released")
			end
		end
	end
end

local function Skill(ActionName, InputState, InputObject)
	if ActionName == "Skill" then
		local KeyPressed = InputObject.KeyCode.Name
		if ControlsInverted then
			KeyPressed = SkillInputs[math.random(1, #SkillInputs)].Name
		end
		
		if Character:GetAttribute(KeyPressed) ~= true then
			if InputState == Enum.UserInputState.Begin then
				--Remotes.Skill:FireServer(KeyPressed, "Pressed")
				if not SkillMainFrame.Parent.Enabled then
					SharedRemotes.ServerCombatHandler:FireServer("Skill", KeyPressed, "Pressed")
				end
			elseif InputState == Enum.UserInputState.End then
				SharedRemotes.ServerCombatHandler:FireServer("Skill", KeyPressed, "Released")
				Remotes.Skill:FireServer(KeyPressed, "Released")
			end
		end
	end
end


local SprintTimer = 0 -- Double Tap W Sprint --
local function SprintW(ActionName, InputState, InputObject)
    if ActionName == "SprintW" then
        if InputState == Enum.UserInputState.Begin then
            if DateTime.now().UnixTimestampMillis - SprintTimer <= 300 then
                Remotes.Sprint:FireServer("Pressed")
            end
            SprintTimer = DateTime.now().UnixTimestampMillis
        elseif InputState == Enum.UserInputState.End then
            Remotes.Sprint:FireServer("Released")
        end
    end
    return Enum.ContextActionResult.Pass
end


local function Sprint(ActionName, InputState, InputObject)
	if ActionName == "Sprint" then
		if InputState == Enum.UserInputState.Begin then
			local DirectionInputs = {"W", "D", "A"}
			for _, KeyDown in ipairs(DirectionInputs) do
				if UserInputService:IsKeyDown(Enum.KeyCode[KeyDown]) and not UserInputService:IsKeyDown(Enum.KeyCode.S) then
					Remotes.Sprint:FireServer("Pressed")
				end
			end
		elseif InputState == Enum.UserInputState.End then
			Remotes.Sprint:FireServer("Released")
		end
	end
	return Enum.ContextActionResult.Pass
end

local function StopSprint(ActionName, InputState, InputObject)
	if ActionName == "StopSprint" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.Sprint:FireServer("Released")
		end
	end
	return Enum.ContextActionResult.Pass
end

local function LightAttack(ActionName, InputState, InputObject)	
	if ActionName == "LightAttack" then
		if InputState == Enum.UserInputState.Begin then
			if not SkillTreeClone.Enabled then
				SharedRemotes.ServerCombatHandler:FireServer("LightAttack")
				--Character.CharacterHandler.Remotes.LightAttack:FireServer()
			end
		end
	end
	return Enum.ContextActionResult.Pass
end

local function HeavyAttack(ActionName, InputState, InputObject)	
	if ActionName == "HeavyAttack" then
		if InputState == Enum.UserInputState.Begin then
			SharedRemotes.ServerCombatHandler:FireServer("CriticalAttack")
			--Character.CharacterHandler.Remotes.HeavyAttack:FireServer()
		end
	end
end

local function Execute(ActionName, InputState, InputObject)	
	if ActionName == "Execute" then
		if InputState == Enum.UserInputState.Begin then
			Character.CharacterHandler.Remotes.Execute:FireServer()
		end
	end
end

local function Carry(ActionName, InputState, InputObject)	
	if ActionName == "Carry" then
		if InputState == Enum.UserInputState.Begin then
			SharedRemotes.ServerCombatHandler:FireServer("Carry")
			--Character.CharacterHandler.Remotes.Carry:FireServer()
		end
	end
end


local function Flashstep(ActionName, InputState, InputObject)	
	if ActionName == "Flashstep" then
		if InputState == Enum.UserInputState.Begin then
			if not ControlsInverted then
				Remotes.Flashstep:FireServer("Pressed")
			end
		end
	end
end

local function UnsheatheWeapon(ActionName, InputState, InputObject)
	if ActionName == "UnsheatheWeapon" then
		if InputState == Enum.UserInputState.Begin and not Character:GetAttribute("Respawning") then
			Remotes.Weapon:FireServer()
		end
	end
end

local function Dash(ActionName, InputState, InputObject)
	if ActionName == "Dash" then
		if InputState == Enum.UserInputState.Begin then
			local CurrentState = Character:GetAttribute("CurrentState")
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then -- Flashstep trigger is LeftShift + Q / UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				Remotes.Flashstep:FireServer("Pressed")
			elseif CurrentState == "Sprinting" and FlashstepToggle == "Q" then
				Remotes.Flashstep:FireServer("Pressed")
			end
			
			local KeyHeld = "S"
			local DirectionInputs = {"W", "D", "A", "S"}
			for _, KeyDown in ipairs(DirectionInputs) do
				if UserInputService:IsKeyDown(Enum.KeyCode[KeyDown]) then
					KeyHeld = KeyDown
				end
			end
			Character.CharacterHandler.Remotes.Dash:FireServer(KeyHeld, nil)
		end
	end
end

local function Block(ActionName, InputState, InputObject)	
	if ActionName == "Block" then
		if InputState == Enum.UserInputState.Begin then
			if not QueuedBlock then
				QueuedBlock = true
			end
			Remotes.Block:FireServer("Pressed", nil)
		end
		if InputState == Enum.UserInputState.End then
			QueuedBlock = false
			Remotes.Block:FireServer("Released", nil)
		end
	end
end

local function M2(ActionName, InputState, InputObject)
	if ActionName == "M2" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.M2:FireServer()
		end
	end
	return Enum.ContextActionResult.Pass
end

local function ReleaseShikai(ActionName, InputState, InputObject)
	if ActionName == "ReleaseShikai" then
		if InputState == Enum.UserInputState.Begin then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				Remotes.ReleaseBankai:FireServer()
			else
				Remotes.ReleaseShikai:FireServer()
			end
		end
	end
end

local function HollowTransform(ActionName, InputState, InputObject)
	if ActionName == "HollowTransform" then
		if InputState == Enum.UserInputState.Begin then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				Remotes.HollowTransform:FireServer()
			else
				Remotes.ReleaseVisored:FireServer()
			end
		end
	end
	return Enum.ContextActionResult.Pass
end

local function Meditate(ActionName, InputState, InputObject)
	if ActionName == "Meditate" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.Meditate:FireServer()
		end
	end
	return Enum.ContextActionResult.Pass
end

local function Purify(ActionName, InputState, InputObject)
	if ActionName == "Purify" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.Purify:FireServer()
		end
	end
end

local function ToggleSkillTree(ActionName, InputState, InputObject)
	if ActionName == "ToggleSkillTree" then
		if InputState == Enum.UserInputState.Begin then
			SkillMainFrame.Parent.Enabled = not SkillMainFrame.Parent.Enabled
			MainFrame.Visible = not SkillMainFrame.Parent.Enabled
			PlayerGui.Toolbar.Enabled = not SkillMainFrame.Parent.Enabled
			game:GetService("Lighting").Blur.Enabled = SkillMainFrame.Parent.Enabled
			
			if Page == 3 and SkillMainFrame.Parent.Enabled == true then
				UpdateViewport()
			end
			
			local Factions = {
				Arrancar = "Arrancar";
				Vastocar = "Arrancar";
				Shinigami = "Shinigami";
				Visored = "Shinigami";
				Quincy = "Quincy";
				LostSoul = "Both";
				Hollow = "Arrancar";
			}
			
			if Factions[Character:GetAttribute("EntityType")] == "Shinigami" then
				SkillMainFrame.page3Frame.ClanPercentage.SRLegendary.Visible = true
				SkillMainFrame.page3Frame.ClanPercentage.HollowLegendary.Visible = false
				SkillMainFrame.page3Frame.ClanPercentage.QuincyLegendary.Visible = false
				SkillMainFrame.ClanInformation.Soul.Visible = true
				SkillMainFrame.ClanInformation.Quincy.Visible = false
				SkillMainFrame.ClanInformation.Hollow.Visible = false
			elseif Factions[Character:GetAttribute("EntityType")] == "Arrancar" then
				SkillMainFrame.page3Frame.ClanPercentage.SRLegendary.Visible = false
				SkillMainFrame.page3Frame.ClanPercentage.HollowLegendary.Visible = true
				SkillMainFrame.page3Frame.ClanPercentage.QuincyLegendary.Visible = false
				SkillMainFrame.ClanInformation.Soul.Visible = false
				SkillMainFrame.ClanInformation.Quincy.Visible = false
				SkillMainFrame.ClanInformation.Hollow.Visible = true
			elseif Factions[Character:GetAttribute("EntityType")] == "Quincy" then
				SkillMainFrame.page3Frame.ClanPercentage.SRLegendary.Visible = false
				SkillMainFrame.page3Frame.ClanPercentage.HollowLegendary.Visible = false
				SkillMainFrame.page3Frame.ClanPercentage.QuincyLegendary.Visible = true
				SkillMainFrame.ClanInformation.Soul.Visible = false
				SkillMainFrame.ClanInformation.Quincy.Visible = true
				SkillMainFrame.ClanInformation.Hollow.Visible = false
			end
		end
	end
	return Enum.ContextActionResult.Pass
end

local function Shiftlock(ActionName, InputState, InputObject)
	if ActionName == "Shiftlock" then
		if InputState == Enum.UserInputState.Begin then
			Shiftlocked = not Shiftlocked
			if CameraController.activeCameraController then
				CameraController.activeCameraController:SetIsMouseLocked(Shiftlocked)
				if Shiftlocked then
					CameraController.activeCameraController:SetMouseLockOffset(Vector3.new(1.3, 0.35, 0))
				else
					CameraController.activeCameraController:SetMouseLockOffset(Vector3.zero)
				end
			end
			Remotes.Shiftlocked:FireServer(Shiftlocked)
		end
	end
	return Enum.ContextActionResult.Pass
end

local DivisionToggled = false
local DivisionToggleConnections = {}

local function DivisionToggle(ActionName, InputState, InputObject)
	if ActionName == "DivisionToggle" then
		if InputState == Enum.UserInputState.Begin then
			if DivisionToggled == false then
				DivisionToggled = true
				for i, v in ipairs(workspace.DivisionSpawns:GetChildren()) do
					v.DivisionMarker.Enabled = true
					DivisionToggleConnections[i] = RunService.RenderStepped:Connect(function(DeltaTime)
						local Magnitude = (v.Position - Character.HumanoidRootPart.Position).Magnitude
						v.DivisionMarker.Studs.TextLabel.Text = math.floor(Magnitude) .. "m"
					end)
				end
			elseif DivisionToggled == true then
				DivisionToggled = false
				for i, v in ipairs(workspace.DivisionSpawns:GetChildren()) do
					v.DivisionMarker.Enabled = false
				end
				for i, v in ipairs(DivisionToggleConnections) do
					DivisionToggleConnections[i]:Disconnect()
					DivisionToggleConnections[i] = nil
				end
			end
		end
	end
end

local function DropItem(ActionName, InputState, InputObject)
	if ActionName == "DropItem" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.DropItem:FireServer()
		end
	end
end

local function ToggleLightAttack(ActionName, InputState, InputObject)
	if ActionName == "ToggleLightAttack" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.ToggleLightAttack:FireServer()
		end
	end
end

local function ToggleHierro(ActionName, InputState, InputObject)
	if ActionName == "ToggleHierro" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.Hierro:FireServer()
		end
	end
end

local function Return(ActionName, InputState, InputObject)
	if ActionName == "Return" then
		if InputState == Enum.UserInputState.Begin then
			Remotes.Return:FireServer()
		end
	end
end

--[[local PingConnection
local MousePing = "Right"
local PingPosition

local function Ping(ActionName, InputState, InputObject)
	if ActionName == "Ping" then
		if InputState == Enum.UserInputState.Begin then	
			if PingConnection and typeof(PingConnection) == "RBXScriptConnection" and PingConnection.Connected then
				PingConnection:Disconnect()
				PingConnection = nil
			end
			
			PingPosition = MousePosition()
			
			local LastMouseX, LastMouseY = Mouse.X, Mouse.Y
			
			PingConnection = Mouse.Move:Connect(function()
				if math.abs(Mouse.X - LastMouseX) > math.abs(Mouse.Y - LastMouseY) then
					if Mouse.X - LastMouseX > 0 then
						MousePing = "Right"
					else
						MousePing = "Left"
					end
				else
					if Mouse.Y - LastMouseY > 0 then
						MousePing = "Down"
					else
						MousePing = "Up"
					end
				end
				print(MousePing)
				LastMouseX, LastMouseY = Mouse.X, Mouse.Y
			end)
		elseif InputState == Enum.UserInputState.End then
			PingConnection:Disconnect()
			PingConnection = nil
			
			Remotes.PingEvent:FireServer(PingPosition, MousePing)
			
			MousePing = "Right"
		end
	end
end]]

local PingConnection
local MousePing = "Right"
local PingPosition

local function Ping(ActionName, InputState, InputObject)
	if ActionName == "Ping" then
		if InputState == Enum.UserInputState.Begin then	
			if PingConnection and typeof(PingConnection) == "RBXScriptConnection" and PingConnection.Connected then
				PingConnection:Disconnect()
				PingConnection = nil
			end

			PingPosition = MousePosition()
			
			local CurrentCamera = workspace.CurrentCamera		
			
			local LastX, LastY, LastZ = CurrentCamera.CFrame.Rotation:ToOrientation()
			
			PingConnection = Mouse.Move:Connect(function()
				local X, Y, Z = CurrentCamera.CFrame.Rotation:ToOrientation()
			
				if math.abs(X - LastX) > math.abs(Y - LastY) then
					if X - LastX > 0 then
						MousePing = "Up"
					else
						MousePing = "Down"
					end
				else
					if Y - LastY > 0 then
						MousePing = "Left"
					else
						MousePing = "Right"
					end
				end		
				
				LastX, LastY, LastZ = CurrentCamera.CFrame.Rotation:ToOrientation()
			end)
		elseif InputState == Enum.UserInputState.End then
			PingConnection:Disconnect()
			PingConnection = nil

			Remotes.PingEvent:FireServer(PingPosition, MousePing)

			MousePing = "Right"
		end
	end
end

ContextActionService:BindAction("UnsheatheWeapon", UnsheatheWeapon, false, Enum.KeyCode.E)
ContextActionService:BindAction("Dash", Dash, false, Enum.KeyCode.Q)
--ContextActionService:BindAction("SprintW", Sprint, false, Enum.KeyCode.W)
ContextActionService:BindAction("Sprint", Sprint, false, Enum.KeyCode.LeftShift)
ContextActionService:BindAction("StopSprint", StopSprint, false, Enum.KeyCode.S)

ContextActionService:BindAction("ToggleSkillTree", ToggleSkillTree, false, Enum.KeyCode.N)
ContextActionService:BindAction("Skill", Skill, false, unpack(SkillInputs))
ContextActionService:BindAction("ShikaiSkill", ShikaiSkill, false, unpack(ShikaiInputs))
ContextActionService:BindAction("BankaiSkill", BankaiSkill, false, unpack(BankaiInputs))
ContextActionService:BindAction("LightAttack", LightAttack, true, Enum.UserInputType.MouseButton1)
ContextActionService:BindAction("M2", M2, true, Enum.UserInputType.MouseButton2)
ContextActionService:BindAction("HeavyAttack", HeavyAttack, false, Enum.KeyCode.R)
ContextActionService:BindAction("ReleaseShikai", ReleaseShikai, false, Enum.KeyCode.J)
ContextActionService:BindAction("HollowTransform", HollowTransform, false, Enum.KeyCode.K)
ContextActionService:BindAction("Meditate", Meditate, false, Enum.KeyCode.M)
ContextActionService:BindAction("Purify", Purify, false, Enum.KeyCode.P)

ContextActionService:BindAction("Carry", Carry, false, Enum.KeyCode.V)
ContextActionService:BindAction("Execute", Execute, false, Enum.KeyCode.B)
ContextActionService:BindAction("Block", Block, true, Enum.KeyCode.F)

ContextActionService:BindAction("ToggleLightAttack", ToggleLightAttack, false, Enum.KeyCode.Tab)
ContextActionService:BindAction("ToggleHierro", ToggleHierro, false, Enum.KeyCode.U)
ContextActionService:BindAction("Return", Return, false, Enum.KeyCode.Quote)

ContextActionService:BindAction("DropItem", DropItem, false, Enum.KeyCode.Backspace)
ContextActionService:BindAction("Shiftlock", Shiftlock, false, table.unpack(ShiftlockKeys))
ContextActionService:BindAction("Ping", Ping, false, Enum.UserInputType.MouseButton3)
local IsSoulSociety = game.PlaceId == 14070029709
if IsSoulSociety then
	ContextActionService:BindAction("DivisionToggle", DivisionToggle, false, Enum.KeyCode.Comma)
end

Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

-- Event Listeners --
Character:GetAttributeChangedSignal("CurrentState"):Connect(function()
	local CurrentState = Character:GetAttribute("CurrentState")
	if QueuedBlock and CurrentState ~= "Action" then
		Block("Block", Enum.UserInputState.Begin)
	end
end)

local JumpCounter = 0
local JumpTimer = 0
Humanoid.StateChanged:Connect(function(OldState, NewState)
	if NewState == Enum.HumanoidStateType.Jumping and Character:GetAttribute("CombatTag") and Character:GetAttribute("CombatTag") > 0 then
		JumpTimer = DateTime.now().UnixTimestampMillis
		
		local HeightReduction = 1.25 -- 0.75
		Humanoid.JumpHeight -= HeightReduction
		
		local JumpHeightChanged
		local Connection
		Connection = Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(function()
			JumpHeightChanged = true
			Connection:Disconnect()
			Connection = nil
		end)
		
		local Duration = 1.5
		task.delay(Duration, function()
			local TimeDifference = DateTime.now().UnixTimestampMillis - JumpTimer
			if TimeDifference >= Duration * 995 and not JumpHeightChanged then
				Humanoid.JumpHeight = Character:GetAttribute("BaseJumpheight")
			end
		end)
		
		--[[if JumpCounter >= 1 then
			JumpCounter = 0
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			task.delay(0.8, function()
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			end)
		end]]
		
		--[[local TimeDifference = DateTime.now().UnixTimestampMillis - JumpTimer

		if TimeDifference > 1000 then
			JumpCounter = 0
		end
		if TimeDifference <= 1000 then
			JumpCounter += 1

			if JumpCounter >= 1 then
				JumpCounter = 0
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				task.delay(0.8, function()
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end)
			end
		end

		JumpTimer = DateTime.now().UnixTimestampMillis]]
	end
end)

ReplicatedStorage.Remotes.DisableShiftlock.OnClientEvent:Connect(function(State)
	if State == "Disabled" then
		ContextActionService:UnbindAction("Shiftlock")
		CameraController.activeCameraController:SetIsMouseLocked(false)
		CameraController.activeCameraController:SetMouseLockOffset(Vector3.zero)
	elseif State == "Enabled" then
		ContextActionService:BindAction("Shiftlock", Shiftlock, false, table.unpack(ShiftlockKeys))
	end
end)

--[[GuiService.MenuOpened:Connect(function()
	Remotes.ESCCombatTag:FireServer()
end)]]

ReplicatedStorage.Remotes.InvertPlayerControls.OnClientEvent:Connect(function(Duration)
	local PlayerScripts = Player:WaitForChild("PlayerScripts")
	local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
	
	local MovementController = PlayerModule:GetControls()
	MovementController.moveFunction = function(Player, Direction, Relative)
		Player.Move(Player, -Direction, Relative)
	end
	
	ControlsInverted = true
	InvertedTimer = DateTime.now().UnixTimestampMillis
	
	local CurrentCamera = workspace.CurrentCamera	
	local Offset = Character.HumanoidRootPart.CFrame:Inverse() * CurrentCamera.CFrame * CFrame.Angles(0, 0, math.pi)
	CurrentCamera.CameraType = Enum.CameraType.Scriptable

	RunService:BindToRenderStep("InvertedCamera", 1, function()
		CurrentCamera.CFrame = Character.HumanoidRootPart.CFrame * Offset
	end)
	
	Lighting.ColorCorrection.Saturation = -2
	
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
	
	local InvertedInputs = {
		Enum.KeyCode.V;
		Enum.KeyCode.F;
		Enum.KeyCode.B;
		Enum.KeyCode.LeftShift;
		Enum.KeyCode.Q;
		Enum.UserInputType.MouseButton2;
		Enum.UserInputType.MouseButton1;
		Enum.KeyCode.R;
	}
	
	local InvertedControls = {
		Dash = Enum.KeyCode.V;
		LightAttack = Enum.KeyCode.F;
		M2 = Enum.KeyCode.B;
		HeavyAttack = Enum.KeyCode.LeftShift;
		Carry = Enum.KeyCode.Q;
		Execute = Enum.UserInputType.MouseButton2;
		Block = Enum.UserInputType.MouseButton1;
		Sprint = Enum.KeyCode.R;
	}
	
	--[[local CurrentControls = DeepCopyTable(InvertedInputs)
	for i, v in pairs(InvertedControls) do		
		local Input = CurrentControls[math.random(1, #CurrentControls)]
		InvertedControls[i] = Input
		table.remove(CurrentControls, table.find(CurrentControls, Input))
	end]]
	
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	
	ContextActionService:BindAction("Dash", Dash, false, InvertedControls.Dash)
	ContextActionService:BindAction("LightAttack", LightAttack, false, InvertedControls.LightAttack)
	ContextActionService:BindAction("M2", M2, false, InvertedControls.M2)
	ContextActionService:BindAction("HeavyAttack", HeavyAttack, false, InvertedControls.HeavyAttack)
	ContextActionService:BindAction("Carry", Carry, false, InvertedControls.Carry)
	ContextActionService:BindAction("Execute", Execute, false, InvertedControls.Execute)
	ContextActionService:BindAction("Block", Block, false, InvertedControls.Block)
	if SprintToggle == "Shift" then
		ContextActionService:UnbindAction("SprintW")
		ContextActionService:BindAction("Sprint", Sprint, false, Enum.KeyCode.R)
	elseif SprintToggle == "W" then
		ContextActionService:UnbindAction("Sprint")
		ContextActionService:BindAction("SprintW", SprintW, false, Enum.KeyCode.R)
	end
	
	task.delay(Duration, function()
		if DateTime.now().UnixTimestampMillis - InvertedTimer >= Duration * 995 then
			MovementController.moveFunction = Player.Move

			ControlsInverted = false
			Lighting.ColorCorrection.Saturation = CurrentSaturation
			
			RunService:UnbindFromRenderStep("InvertedCamera")
			CurrentCamera.CameraType = Enum.CameraType.Custom
			
			local PlayerControls = {
				UnsheatheWeapon = Enum.KeyCode.E;
				Dash = Enum.KeyCode.Q;
				LightAttack = Enum.UserInputType.MouseButton1;
				M2 = Enum.UserInputType.MouseButton2;
				HeavyAttack = Enum.KeyCode.R;
				Carry = Enum.KeyCode.V;
				Execute = Enum.KeyCode.B;
				Block = Enum.KeyCode.F;
			}
			
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			ContextActionService:BindAction("Dash", Dash, false, PlayerControls.Dash)
			ContextActionService:BindAction("LightAttack", LightAttack, false, PlayerControls.LightAttack)
			ContextActionService:BindAction("M2", M2, false, PlayerControls.M2)
			ContextActionService:BindAction("HeavyAttack", HeavyAttack, false, PlayerControls.HeavyAttack)
			ContextActionService:BindAction("Carry", Carry, false, PlayerControls.Carry)
			ContextActionService:BindAction("Execute", Execute, false, PlayerControls.Execute)
			ContextActionService:BindAction("Block", Block, false, PlayerControls.Block)

			if SprintToggle == "Shift" then
				PlayerControls.Sprint = Enum.KeyCode.LeftShift
				ContextActionService:UnbindAction("SprintW")
				ContextActionService:BindAction("Sprint", Sprint, false, Enum.KeyCode.LeftShift)
			elseif SprintToggle == "W" then
				PlayerControls.Sprint = Enum.KeyCode.W
				ContextActionService:UnbindAction("Sprint")
				ContextActionService:BindAction("SprintW", SprintW, false, Enum.KeyCode.W)
			end
		end
	end)
end)

ReplicatedStorage.Remotes.DisableRagdoll.OnClientEvent:Connect(function(Enabled)
	if Enabled == "Enable" then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
		Humanoid.Jump = false
		Humanoid.PlatformStand = true
	elseif Enabled == "Disable" then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		Humanoid.PlatformStand = false
	end
end)

ReplicatedStorage.Remotes.DisableBlur.OnClientEvent:Connect(function()
	game:GetService("Lighting").Blur.Enabled = false
end)

ReplicatedStorage.Remotes.CancelClientAnimation.OnClientEvent:Connect(function(AnimName, SearchByReference)
	SharedFunctions:CancelAnimation(Character.Humanoid, AnimName, SearchByReference)
end)

ReplicatedStorage.Remotes.RotationalDash.OnClientEvent:Connect(function(BodyVelocity, KeyPressed, Speed, PlayAnim, Name)
	if PlayAnim then
		local DashAnimation = Humanoid:LoadAnimation(Animations[KeyPressed .. "Dash"])DashAnimation:Play()
	end
	
	local StepName = "Dash"
	if Name then
		StepName = Name
	end
	
	RunService:BindToRenderStep(StepName, 1, function()
		if KeyPressed == "W" then
			BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * Speed
		elseif KeyPressed == "S" then
			BodyVelocity.Velocity = -Character.HumanoidRootPart.CFrame.LookVector * Speed
		elseif KeyPressed == "A" then
			BodyVelocity.Velocity = -Character.HumanoidRootPart.CFrame.RightVector * Speed
		elseif KeyPressed == "D" then
			BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.RightVector * Speed
		end
	end)
	local Connection
	Connection = BodyVelocity.AncestryChanged:Connect(function()
		--ReplicatedStorage.Remotes.PositionRequest:FireServer(Character.PrimaryPart.CFrame)
		RunService:UnbindFromRenderStep(StepName)
		SharedFunctions:CancelAnimation(Character.Humanoid, "Dash", "SearchByReference")
		Connection:Disconnect()
		Connection = nil
	end)
end)

ReplicatedStorage.Remotes.ClashEvent.OnClientEvent:Connect(function(ClashStage, ...)
	local ClashSystem = require(ReplicatedStorage.Modules.Shared.ClashSystem)
	ClashSystem[ClashStage](Character, ...)
end)

ReplicatedStorage.Remotes.PartyInvite.OnClientEvent:Connect(function(Party)
	if PartyInviteFrame.Visible == false then
		PartyInviteFrame.Position = UDim2.new(1.1, 0, 0.874, 0)
		PartyInviteFrame.PartyName.Text = Party
		PartyInviteFrame.Visible = true
		PartyInviteFrame:TweenPosition(UDim2.new(0.956, 0, 0.874, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	end
end)

ReplicatedStorage.Remotes.BailEvent.OnClientEvent:Connect(function(Warden, Bond)
	if BailOfferFrame.Visible == false then
		BailOfferFrame.Position = UDim2.new(1.1, 0, 0.801, 0)
		BailOfferFrame.WardenName.Text = Warden
		BailOfferFrame.Price.Text = "$" .. comma_value(Bond)
		BailOfferFrame.Visible = true
		BailOfferFrame:TweenPosition(UDim2.new(0.956, 0, 0.801, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	end
end)

local function Sink()
	return Enum.ContextActionResult.Sink
end

local PlayerMovement = {
	SinkCharacterForward = Enum.PlayerActions.CharacterForward;
	SinkCharacterBackward = Enum.PlayerActions.CharacterBackward;
	SinkCharacterLeft = Enum.PlayerActions.CharacterLeft;
	SinkCharacterRight = Enum.PlayerActions.CharacterRight;
	SinkCharacterJump = Enum.PlayerActions.CharacterJump;
}

ReplicatedStorage.Remotes.PlayerControlEvent.OnClientEvent:Connect(function(State, Controls)
	if State == "Enabled" and not Character:GetAttribute("Zombification") then
		for i, v in pairs(PlayerMovement) do
			ContextActionService:UnbindAction(i)
		end
	elseif State == "Disabled" then
		for i, v in pairs(PlayerMovement) do
			ContextActionService:BindAction(i, Sink, false, v)
		end
	end
end)

local DanceConnection

ReplicatedStorage.Remotes.TriggerDance.OnClientEvent:Connect(function(State, Info)
	if State == "Enabled" then
		local DanceInput = {
			Enum.KeyCode.A;
			Enum.KeyCode.D;
			Enum.KeyCode.W;
			Enum.KeyCode.S;
		}
		
		local InputConvert = {
			Left = "A";
			Right = "D";
			Up = "W";
			Down = "S";
		}

		local function Dance(ActionName, InputState, InputObject)
			if ActionName == "Dance" then
				if InputState == Enum.UserInputState.Begin then
					local KeyPressed = InputObject.KeyCode.Name
					Remotes.DanceEvent:FireServer("Pressed", KeyPressed)
				end
			end
		end
		
		local function ReleaseDance(ActionName, InputState, InputObject)
			if ActionName == "ReleaseDance" then
				if InputState == Enum.UserInputState.Begin then
					Remotes.DanceEvent:FireServer("Release")
				end
			end
		end
		
		if SprintToggle == "W" then
			ContextActionService:UnbindAction("SprintW")
		end

		ContextActionService:BindAction("Dance", Dance, false, unpack(DanceInput))
		ContextActionService:BindAction("ReleaseDance", ReleaseDance, false, Enum.KeyCode.Space)
		
		local RandomNumber = math.random(1, 3)
		local DanceDanceAudio = ReplicatedStorage.Assets.Sounds["DanceDance" .. RandomNumber]:Clone()
		DanceDanceAudio.Name = "DanceDanceAudio"
		DanceDanceAudio.Looped = true
		DanceDanceAudio.Parent = workspace.Effects[Character.Name]
		DanceDanceAudio:Play()
	elseif State == "Trigger" then
		local Direction = Info.Direction
		local Time = Info.Time
		local DanceFrame = Player.PlayerGui.DanceDance.MainFrame

		local Directions = {
			[1] = "W";
			[2] = "S";
			[3] = "A";
			[4] = "D";
		}
		
		local Arrow = DanceFrame[Directions[Direction] .. "Arrow"].Bottom:Clone()
		Arrow.Visible = true
		Arrow.Position = UDim2.new(0.5, 0, 1.1, 0)
		Arrow.Parent = DanceFrame[Directions[Direction] .. "Arrow"]
		game:GetService("Debris"):AddItem(Arrow, Time)
		TweenService:Create(Arrow, TweenInfo.new(Time), {Position = UDim2.new(0.5, 0, 0.091, 0)}):Play()
	elseif State == "Disabled" then
		local DanceDanceAudio = workspace.Effects[Character.Name]:FindFirstChild("DanceDanceAudio")
		if DanceDanceAudio then
			DanceDanceAudio:Stop()
			DanceDanceAudio:Destroy()
		end
		
		if DanceConnection then
			DanceConnection:Disconnect()
			DanceConnection = nil
		end
		ContextActionService:UnbindAction("Dance")
		ContextActionService:UnbindAction("ReleaseDance")
		
		if SprintToggle == "W" then
			ContextActionService:BindAction("SprintW", SprintW, false, Enum.KeyCode.W)
		end
	end
end)

ReplicatedStorage.Remotes.TriggerPiano.OnClientEvent:Connect(function(State, Info)
	if State == "Enabled" then
		local function ReleasePiano(ActionName, InputState, InputObject)
			if ActionName == "ReleasePiano" then
				if InputState == Enum.UserInputState.Begin then
					Remotes.PianoEvent:FireServer("Release")
				end
			end
		end

		ContextActionService:BindAction("ReleasePiano", ReleasePiano, false, Enum.KeyCode.Space)
	elseif State == "Disabled" then
		ContextActionService:UnbindAction("ReleasePiano")
	end
end)

ReplicatedStorage.Remotes.DialogueEvent.OnClientEvent:Connect(function(Remote, Dialogue, Options)
	local DialogueClone = DialogueFrame:Clone()
	DialogueClone.Parent = PlayerGui.DialogueUI
	DialogueClone.Visible = true
	
	MainFrame.Visible = false
	PlayerGui.Toolbar.Enabled = false
	
	if Options then
		for i, v in pairs(Options) do
			DialogueClone[i].Text = v
		end
	end
	
	local CurrentDialogue = true
	local Connection1
	local Connection2
	local Connection3
	
	local function Disconnect()
		Connection1:Disconnect()
		Connection2:Disconnect()
		Connection3:Disconnect()
		Connection1 = nil
		Connection2 = nil
		Connection3 = nil
		
		DialogueClone.Visible = false
		MainFrame.Visible = true
		PlayerGui.Toolbar.Enabled = true
		CurrentDialogue = nil
		DialogueClone:Destroy()
	end
	
	Connection1 = DialogueClone.Yes.MouseButton1Click:Connect(function()
		if Remote then
			Remote:FireServer("Yes")
			if Remote.Name == "Nel Tu" then
				AccessoryShopClone.Enabled = true
			elseif Remote.Name == "Market" and Remote:GetAttribute("Winner") then
				for i, v in ipairs(MarketClone.Shop.ScrollingFrame:GetChildren()) do
					if v:IsA("TextButton") then
						if v:GetAttribute("Rotation") then
							v.Visible = true
						else
							v.Visible = false
						end
					end
				end
				
				MarketClone.Enabled = true
			end
		end
		Disconnect()
	end)
	Connection2 = DialogueClone.No.MouseButton1Click:Connect(function()
		if Remote then
			Remote:FireServer("No")
		end
		Disconnect()
	end)
	Connection3 = DialogueClone.End.MouseButton1Click:Connect(function()
		if Remote then
			Remote:FireServer("End")
		end
		Disconnect()
	end)
	
	if Remote then
		DialogueClone.npcName.Text = Remote.Name
	else
		DialogueClone.npcName.Text = ""
	end
	for i = 1, #Dialogue do
		if not CurrentDialogue then return end
		DialogueClone.mainText.Text = Dialogue:sub(1, i)
		task.wait(0.03)
	end
end)

ReplicatedStorage.Remotes.CooldownUIUpdate.OnClientEvent:Connect(function(UI)
	if UI == "CombatTag" then
		if Character:GetAttribute("CombatTag") > 0 then
			CombatTag.Visible = true
			
			if not Character:GetAttribute("CurrentOST") and Ambience:GetAttribute("HuntActive") == false and Ambience:GetAttribute("RaidActive") == false then
				if not MusicConnection then
					for i, v in ipairs(SoundRegions[CurrentRegion]) do
						v:Stop()
					end

					local function PlayCombatMusic()
						local CombatMusic = workspace.CombatMusic["Combat" .. math.random(1, 5)]:Clone()
						if Character:GetAttribute("CurrentOST") or Ambience:GetAttribute("HuntActive") or Ambience:GetAttribute("RaidActive") then
							CombatMusic.Volume = 0
						end
						CombatMusic.Parent = workspace.CombatMusic.CurrentMusic
						CombatMusic:Play()

						MusicConnection = CombatMusic.Ended:Connect(function()
							if MusicConnection then
								MusicConnection:Disconnect()
								MusicConnection = false
							end
							if Character:GetAttribute("CombatTag") > 0 then
								CombatMusic:Destroy()
								PlayCombatMusic()
							end
						end)
					end
					PlayCombatMusic()
				end
			end
		elseif Character:GetAttribute("CombatTag") == 0 then
			CombatTag.Visible = false
			for i, v in ipairs(workspace.CombatMusic.CurrentMusic:GetChildren()) do
				v:Stop()
				v:Destroy()
			end
			if MusicConnection then
				MusicConnection:Disconnect()
				MusicConnection = false
			end
			
			if Ambience:GetAttribute("HuntActive") == false and Ambience:GetAttribute("RaidActive") == false then
				for i, v in ipairs(SoundRegions[CurrentRegion]) do
					v:Play()
				end
			end
		end
	else
		if Character:GetAttribute(UI) then
			ShikaiBankai[UI].TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			ShikaiBankai[UI].TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

local TradeConnections = {}
local TradeTab = {}

ReplicatedStorage.Remotes.TradeRemote.OnClientEvent:Connect(function(Action, ItemName, Slot, Timer, TradePlayer, Inv)
	if Action == "Enable" then
		if TradeUI.Enabled then
			return
		end
		
		TradeUI.Enabled = true
		TradeUI.Main.Visible = false
		TradeUI.Offer.Visible = true
		TradeUI.Requests.Visible = true
		TradeUI.Main.Player1.InventoryFrame.Visible = false
		TradeUI.Main.Player1.ScrollingFrame.Visible = true
		
		for i, v in ipairs(Players:GetPlayers()) do
			if v.Character and v ~= Player then
				local NameTemplate = TradeUI.NameTemplate:Clone()
				NameTemplate.Visible = true
				NameTemplate.Name = v.Name
				NameTemplate.Text = v.Name
				NameTemplate.Parent = TradeUI.Offer.ScrollingFrame

				NameTemplate.MouseButton1Click:Connect(function()
					local Response = Remotes.Trade:InvokeServer(v.Name)

					local Time = 30
					repeat
						local Step = task.wait()
						Time -= Step
					until Time <= 0 or Response

					if Response then
						TradeUI.Main.Visible = true
						TradeUI.Offer.Visible = false
						TradeUI.Requests.Visible = false
						TradeUI.Main.Player1.InventoryFrame.Visible = false
						TradeUI.Main.Player1.ScrollingFrame.Visible = true

						TradeUI.Main.Player1.PlayerName.Text = Player.Name
						TradeUI.Main.Player2.PlayerName.Text = v.Name

						for i, v in ipairs(TradeConnections) do
							TradeConnections[i]:Disconnect()
							TradeConnections[i] = nil
						end

						table.clear(TradeTab)
						
						local Loaded
						local InventoryItems = Response
						for n = 1, 4 do
							local ItemSlot = TradeUI.Main.Player1.ScrollingFrame["ItemTemplate" .. n]
							ItemSlot.AddItem.Text = "+"
							ItemSlot.AddItem.TextSize = 100

							TradeConnections[n] = ItemSlot.AddItem.MouseButton1Click:Connect(function()
								TradeUI.Main.Player1.InventoryFrame.Visible = true
								TradeUI.Main.Player1.ScrollingFrame.Visible = false

								for i, v in ipairs(TradeUI.Main.Player1.InventoryFrame:GetChildren()) do
									if not v:GetAttribute("Safe") then
										v:Destroy()
									end
								end

								for ItemName, Quantity in pairs(InventoryItems) do
									local Amount = Quantity
									if not TradeTab[ItemName] then
										TradeTab[ItemName] = {Amount = Quantity, Slot = false}
									else
										Amount = TradeTab[ItemName].Amount
									end

									if Amount <= 0 then
										continue
									end

									local ItemTemplate = TradeUI.ItemTemplate:Clone()
									ItemTemplate.LayoutOrder = 1
									ItemTemplate.Visible = true
									ItemTemplate.Name = ItemName
									ItemTemplate.AddItem.Text = ItemName
									ItemTemplate.Parent = TradeUI.Main.Player1.InventoryFrame
									ItemTemplate.AddItem.MouseButton1Click:Connect(function()
										if Loaded and TradeTab[ItemName].Amount > 0 then
											Remotes.TradeEvent:FireServer("AddItem", ItemName, n)
											
											TradeUI.Main.Player1.InventoryFrame.Visible = false
											TradeUI.Main.Player1.ScrollingFrame.Visible = true
											
											--[[for i, v in pairs(TradeTab) do
												if TradeTab[i].Slot and TradeTab[i].Slot == n then
													TradeTab[i].Amount += 1
													TradeTab[i].Slot = false
													break
												end
											end

											TradeTab[ItemName].Amount -= 1
											TradeTab[ItemName].Slot = n

											ItemSlot.AddItem.Text = ItemName
											ItemSlot.AddItem.TextSize = 35

											TradeUI.Main.Player1.InventoryFrame.Visible = false
											TradeUI.Main.Player1.ScrollingFrame.Visible = true]]
										end
									end)
								end

								local ItemTemplate = TradeUI.ItemTemplate:Clone()
								ItemTemplate.LayoutOrder = 0
								ItemTemplate.Visible = true
								ItemTemplate.Name = "None"
								ItemTemplate.AddItem.Text = "None"
								ItemTemplate.Parent = TradeUI.Main.Player1.InventoryFrame
								ItemTemplate.AddItem.MouseButton1Click:Connect(function()
									if Loaded then
										ItemSlot.AddItem.Text = "+"
										ItemSlot.AddItem.TextSize = 100

										TradeUI.Main.Player1.InventoryFrame.Visible = false
										TradeUI.Main.Player1.ScrollingFrame.Visible = true

										for i, v in pairs(TradeTab) do
											if TradeTab[i].Slot and TradeTab[i].Slot == n then
												TradeTab[i].Amount += 1
												TradeTab[i].Slot = false
												break
											end
										end

										Remotes.TradeEvent:FireServer("RemoveItem", ItemName, tonumber(n))
									end
								end)
							end)
						end
						
						Loaded = true
					end
				end)
			end
		end
	elseif Action == "Disable" then
		TradeUI.Enabled = false
		TradeUI.Main.Visible = false
		TradeUI.Offer.Visible = true
		TradeUI.Requests.Visible = true
		TradeUI.Main.Player2.Accepted.Visible = false
		TradeUI.Main.Player1.Accepted.Visible = false
		TradeUI.Main.Player1.InventoryFrame.Visible = false
		TradeUI.Main.Player1.ScrollingFrame.Visible = true
		
		for i = 1, 4 do
			TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. i].AddItem.Text = "+"
			TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. i].AddItem.TextSize = 100
		end
		for i, v in ipairs(TradeConnections) do
			TradeConnections[i]:Disconnect()
			TradeConnections[i] = nil
		end
		for i, v in ipairs(TradeUI.Main.Player1.InventoryFrame:GetChildren()) do
			if not v:GetAttribute("Safe") then
				v:Destroy()
			end
		end
		for i, v in ipairs(TradeUI.Requests.ScrollingFrame:GetChildren()) do
			if not v:GetAttribute("Safe") then
				v:Destroy()
			end
		end
		for i, v in ipairs(TradeUI.Offer.ScrollingFrame:GetChildren()) do
			if not v:GetAttribute("Safe") then
				v:Destroy()
			end
		end
	elseif Action == "Update" then
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. Slot].AddItem.Text = ItemName
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. Slot].AddItem.TextSize = 35
	elseif Action == "UpdateSelf" then
		for i, v in pairs(TradeTab) do
			if TradeTab[i].Slot and TradeTab[i].Slot == Slot then
				TradeTab[i].Amount += 1
				TradeTab[i].Slot = false
				break
			end
		end

		TradeTab[ItemName].Amount -= 1
		TradeTab[ItemName].Slot = tonumber(Slot)

		local ItemSlot = TradeUI.Main.Player1.ScrollingFrame["ItemTemplate" .. Slot]
		ItemSlot.AddItem.Text = ItemName
		ItemSlot.AddItem.TextSize = 35
	elseif Action == "UpdateRemove" then
		print("trade remove:", Slot, ItemName)
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. Slot].AddItem.Text = "+"
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. Slot].AddItem.TextSize = 100
	elseif Action == "Count" then
		for i, v in ipairs(TradeConnections) do
			TradeConnections[i]:Disconnect()
			TradeConnections[i] = nil
		end
		
		TradeUI.Main.Player2.Accepted.Visible = true
		while Timer - workspace:GetServerTimeNow() > 0 do
			TradeUI.Main.Player2.Pend.Text = math.round((Timer - workspace:GetServerTimeNow()) * 10) / 10
			task.wait()
		end
		TradeUI.Main.Player2.Pend.Text = "Pending"
		TradeUI.Main.Player2.Accepted.Visible = false
	elseif Action == "Update2" then
		TradeUI.Main.Player2.Accepted.Visible = true
	elseif Action == "EnablePlayer2" then
		TradeUI.Main.Visible = true
		TradeUI.Offer.Visible = false
		TradeUI.Requests.Visible = false
		TradeUI.Main.Player1.InventoryFrame.Visible = false
		TradeUI.Main.Player1.ScrollingFrame.Visible = true

		TradeUI.Main.Player1.PlayerName.Text = Player.Name
		TradeUI.Main.Player2.PlayerName.Text = TradePlayer

		for i, v in ipairs(TradeConnections) do
			TradeConnections[i]:Disconnect()
			TradeConnections[i] = nil
		end

		table.clear(TradeTab)
		local Loaded
		local InventoryItems = Inv
		for n = 1, 4 do
			local ItemSlot = TradeUI.Main.Player1.ScrollingFrame["ItemTemplate" .. n]
			ItemSlot.AddItem.Text = "+"
			ItemSlot.AddItem.TextSize = 100

			TradeConnections[n] = ItemSlot.AddItem.MouseButton1Click:Connect(function()
				TradeUI.Main.Player1.InventoryFrame.Visible = true
				TradeUI.Main.Player1.ScrollingFrame.Visible = false

				for i, v in ipairs(TradeUI.Main.Player1.InventoryFrame:GetChildren()) do
					if not v:GetAttribute("Safe") then
						v:Destroy()
					end
				end

				for ItemName, Quantity in pairs(InventoryItems) do
					local Amount = Quantity
					if not TradeTab[ItemName] then
						TradeTab[ItemName] = {Amount = Quantity, Slot = false}
					else
						Amount = TradeTab[ItemName].Amount
					end

					if Amount <= 0 then
						continue
					end

					local ItemTemplate = TradeUI.ItemTemplate:Clone()
					ItemTemplate.LayoutOrder = 1
					ItemTemplate.Visible = true
					ItemTemplate.Name = ItemName
					ItemTemplate.AddItem.Text = ItemName
					ItemTemplate.Parent = TradeUI.Main.Player1.InventoryFrame
					ItemTemplate.AddItem.MouseButton1Click:Connect(function()
						if Loaded and TradeTab[ItemName].Amount > 0 then
							Remotes.TradeEvent:FireServer("AddItem", ItemName, n)
							
							TradeUI.Main.Player1.InventoryFrame.Visible = false
							TradeUI.Main.Player1.ScrollingFrame.Visible = true
							
							--[[for i, v in pairs(TradeTab) do
								if TradeTab[i].Slot and TradeTab[i].Slot == n then
									TradeTab[i].Amount += 1
									TradeTab[i].Slot = false
									break
								end
							end

							TradeTab[ItemName].Amount -= 1
							TradeTab[ItemName].Slot = n

							ItemSlot.AddItem.Text = ItemName
							ItemSlot.AddItem.TextSize = 35

							TradeUI.Main.Player1.InventoryFrame.Visible = false
							TradeUI.Main.Player1.ScrollingFrame.Visible = true]]
						end
					end)
				end

				local ItemTemplate = TradeUI.ItemTemplate:Clone()
				ItemTemplate.LayoutOrder = 0
				ItemTemplate.Visible = true
				ItemTemplate.Name = "None"
				ItemTemplate.AddItem.Text = "None"
				ItemTemplate.Parent = TradeUI.Main.Player1.InventoryFrame
				ItemTemplate.AddItem.MouseButton1Click:Connect(function()
					if Loaded then
						ItemSlot.AddItem.Text = "+"
						ItemSlot.AddItem.TextSize = 100

						TradeUI.Main.Player1.InventoryFrame.Visible = false
						TradeUI.Main.Player1.ScrollingFrame.Visible = true

						for i, v in pairs(TradeTab) do
							if TradeTab[i].Slot and TradeTab[i].Slot == n then
								TradeTab[i].Amount += 1
								TradeTab[i].Slot = false
								break
							end
						end
						
						Remotes.TradeEvent:FireServer("RemoveItem", ItemName, n)
					end
				end)
			end)
		end
		Loaded = true
	end
end)

-- TRADING --

local function CancelTrade()
	TradeUI.Enabled = false
	TradeUI.Main.Visible = false
	TradeUI.Offer.Visible = true
	TradeUI.Requests.Visible = true
	TradeUI.Main.Player1.InventoryFrame.Visible = false
	TradeUI.Main.Player1.ScrollingFrame.Visible = true
	TradeUI.Main.Player2.Accepted.Visible = false
	TradeUI.Main.Player1.Accepted.Visible = false
	
	for i = 1, 4 do
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. i].AddItem.Text = "+"
		TradeUI.Main.Player2.ScrollingFrame["ItemTemplate" .. i].AddItem.TextSize = 100
	end
	for i, v in ipairs(TradeConnections) do
		TradeConnections[i]:Disconnect()
		TradeConnections[i] = nil
	end
	for i, v in ipairs(TradeUI.Main.Player1.InventoryFrame:GetChildren()) do
		if not v:GetAttribute("Safe") then
			v:Destroy()
		end
	end
	for i, v in ipairs(TradeUI.Requests.ScrollingFrame:GetChildren()) do
		if not v:GetAttribute("Safe") then
			v:Destroy()
		end
	end
	for i, v in ipairs(TradeUI.Offer.ScrollingFrame:GetChildren()) do
		if not v:GetAttribute("Safe") then
			v:Destroy()
		end
	end
	
	Remotes.TradeEvent:FireServer("Cancel")
end

TradeUI.Offer.Exit.MouseButton1Click:Connect(CancelTrade)
TradeUI.Main.Player1.Cancel.MouseButton1Click:Connect(CancelTrade)
TradeUI.Main.Player1.Accept.MouseButton1Click:Connect(function()
	TradeUI.Main.Player1.Accepted.Visible = true
	Remotes.TradeEvent:FireServer("Accepted")
end)
-------------

AccessoryShopClone.MainBase.Exit.MouseButton1Click:Connect(function()
	AccessoryShopClone.Enabled = false
end)

MarketClone.Shop.Exit.MouseButton1Click:Connect(function()
	MarketClone.Enabled = false
end)

ReplicatedStorage.Remotes.SkillLearnedEvent.OnClientEvent:Connect(function(Skill, Category, Success)
	if not table.find(ServerIndex.Skills, Skill) then
		table.insert(ServerIndex.Skills, Skill)
	end
	
	local SkillOwned = table.find(ServerIndex.Skills, Skill)
	if SkillOwned then
		EquipSkillButton.Parent.Visible = true
		LearnSkillButton.Parent.Visible = false
	else
		EquipSkillButton.Parent.Visible = false
		LearnSkillButton.Parent.Visible = true
	end
	
	if Success then
		local UISkill = CategoryParent[Category][Skill]
		UISkill.Visible = true
		UISkill.Active = true
		UISkill.TextColor3 = UISkill.Parent.Parent.ImageColor3
		
		local SkillLearnedSound = ReplicatedStorage.Assets.Sounds.SkillLearned:Clone()
		SkillLearnedSound.PlayOnRemove = true
		SkillLearnedSound.Parent = workspace.Effects[Character.Name]
		SkillLearnedSound:Destroy()
		SkillLearnedSound = nil
	else
		local ReqNotMetSound = ReplicatedStorage.Assets.Sounds.ReqNotMet:Clone()
		ReqNotMetSound.PlayOnRemove = true
		ReqNotMetSound.Parent = workspace.Effects[Character.Name]
		ReqNotMetSound:Destroy()
		ReqNotMetSound = nil
	end
end)



ReplicatedStorage.Remotes.UpdateSkillTreeEvent.OnClientEvent:Connect(function(PlayerSPTable, UnlockedSkills, Toolbar, DontUpdateSkills, ItemInventory)
	ServerIndex.Skills = UnlockedSkills
	ServerIndex.ItemInventory = ItemInventory
	
	SkillMainFrame.currentSPFrame.currentSPBtn.Text = "Current SP: " .. PlayerSPTable.SP
	SkillMainFrame.page1Frame.Hakuda.title.Text = "HAKUDA - " .. PlayerSPTable.Hakuda
	SkillMainFrame.page1Frame.Kendo.title.Text = "KENDO - " .. PlayerSPTable.Kendo
	SkillMainFrame.page1Frame.Kido.title.Text = "KIDO - " .. PlayerSPTable.Kido
	SkillMainFrame.page2Frame.Healing.title.Text = "HEALING - " .. PlayerSPTable.Healing
	SkillMainFrame.page2Frame.Speed.title.Text = "SPEED - " .. PlayerSPTable.Speed
	SkillMainFrame.playerNameRank.Text = PlayerSPTable.Name

	for i, EquipKey in ipairs(SkillTreeEquipKeys) do
		if Toolbar[EquipKey.Name] then
			if Toolbar[EquipKey.Name] ~= "Empty" then
				EquipKey.SkillName.Text = Toolbar[EquipKey.Name]
			else
				EquipKey.SkillName.Text = ""
			end
		end
	end

	if not DontUpdateSkills then
		if not SkillTreeInfo then
			SkillTreeInfo = ReplicatedStorage.Requests.GetSkillTreeInfo:InvokeServer()
		end
		if not SkillTreeInfo then
			task.wait(1.1)
			SkillTreeInfo = ReplicatedStorage.Requests.GetSkillTreeInfo:InvokeServer()
		end
		ServerIndex.SkillTreeInfo = SkillTreeInfo
		
		for i = 1, 6 do
			for _, SkillFrame in ipairs(SkillTreeFrames[i]:GetChildren()) do
				if SkillFrame:IsA("TextButton") then
					local Skill = SkillFrame.Text
					local ValidSkill = SkillTreeInfo.Info[Skill]
					if ValidSkill then
						if ValidSkill.Race[Character:GetAttribute("EntityType")] or table.find(UnlockedSkills, Skill) then
							SkillFrame.Visible = true
							SkillFrame.Active = true
							if table.find(UnlockedSkills, Skill) then
								SkillFrame.TextColor3 = SkillFrame.Parent.Parent.ImageColor3
							else
								SkillFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
							end
						else
							SkillFrame.Visible = false
							SkillFrame.Active = false
						end
					else
						SkillFrame.Visible = false
						SkillFrame.Active = false
					end
				end
			end
		end
	end
end)

ReplicatedStorage.Remotes.UpdateToolbarEvent.OnClientEvent:Connect(function(Toolbar)
	for i, ToolbarKey in ipairs(ToolbarDisplayKeys) do
		if Toolbar[ToolbarKey.Name] then
			if Toolbar[ToolbarKey.Name] ~= "Empty" then
				ToolbarKey.SkillName.Text = Toolbar[ToolbarKey.Name]
			else
				ToolbarKey.SkillName.Text = ""
			end
		end
		if Character:GetAttribute(ToolbarKey.Name) then
			ToolbarKey.Cooldown.Visible = true
		else
			ToolbarKey.Cooldown.Visible = false
		end
	end
	
	local Keys = {"Z", "X", "C", "T", "G"}
	for i, v in ipairs(Keys) do
		if Character:GetAttribute(v) then
			ShikaiBankai[v].TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			ShikaiBankai[v].TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

ReplicatedStorage.Remotes.UpdateAccessoryEquipButton.OnClientEvent:Connect(function(TradeableName)
	local TradeableEquipped = ReplicatedStorage.Requests.RequestItemEquipped:InvokeServer(TradeableName)

	if TradeableEquipped then
		EquipSkillButton.Parent.Visible = false
		LearnSkillButton.Parent.Visible = true
	else
		EquipSkillButton.Parent.Visible = true
		LearnSkillButton.Parent.Visible = false
	end
end)

ReplicatedStorage.Remotes.UpdateAccessoryUIEvent.OnClientEvent:Connect(function(TradeableInfo, ItemInventory)
	ServerIndex.ItemInventory = ItemInventory
	
	local Category = AccessoryPage3.accessoriesFrame.accessoriesMain
	if TradeableInfo.Info.ItemType == "Item" then
		Category = AccessoryPage3.itemsFrame.itemsMain
	end
	
	if not Category:FindFirstChild(TradeableInfo.ItemName) then
		local TemplateButton = ReplicatedStorage.Assets.UIs.InventoryTemplate:Clone()
		TemplateButton.Name = TradeableInfo.ItemName
		TemplateButton.Text = TradeableInfo.ItemName
		TemplateButton.TextColor3 = RarityColors[TradeableInfo.Info.Rarity]
		TemplateButton.LayoutOrder = LayoutOrder[TradeableInfo.Info.ItemType]
		TemplateButton.Parent = Category

		TemplateButton.MouseButton1Click:Connect(function()
			local TradeableEquipped = ReplicatedStorage.Requests.RequestItemEquipped:InvokeServer(TradeableInfo.ItemName)

			if TradeableEquipped then
				EquipSkillButton.Parent.Visible = false
				LearnSkillButton.Parent.Visible = true
			else
				EquipSkillButton.Parent.Visible = true
				LearnSkillButton.Parent.Visible = false
			end
			EquipSkillButton.Text = "Equip"
			
			AccessoryInfoFrame:WaitForChild("AccessoryName", 6).Text = TradeableInfo.ItemName

			local DescriptionFrame = AccessoryInfoFrame:WaitForChild("descFrame", 6)
			DescriptionFrame:WaitForChild("itemDesc").Text = TradeableInfo.Info.Description
			DescriptionFrame:WaitForChild("itemRarity").Text = TradeableInfo.Info.Rarity
			DescriptionFrame:WaitForChild("itemRarity").TextColor3 = TemplateButton.TextColor3
			DescriptionFrame:WaitForChild("itemType").Text = "Type: " .. TradeableInfo.Info.ItemType
			DescriptionFrame:WaitForChild("itemQuantity").Text = "Quantity: " .. ServerIndex.ItemInventory[TradeableInfo.ItemName]
			UIClickAudio()
		end)
		
		if workspace.NPCs:FindFirstChild("Market") and TradeableInfo.Info.SellPrice then
			local MarketTemplateInventory = ReplicatedStorage.Assets.UIs.MarketTemplateInventory:Clone()
			MarketTemplateInventory.Name = TradeableInfo.ItemName
			MarketTemplateInventory.Text = TradeableInfo.ItemName
			MarketTemplateInventory.Price.Text = "$" .. comma_value(TradeableInfo.Info.SellPrice)
			MarketTemplateInventory.Quantity.Text = ServerIndex.ItemInventory[TradeableInfo.ItemName] .. "x"
			MarketTemplateInventory.Parent = MarketClone.Inventory.ScrollingFrame
			
			MarketTemplateInventory.Sell.MouseButton1Click:Connect(function()
				Remotes.SellAccessory:FireServer(TradeableInfo.ItemName)
			end)
		end
	else
		local ItemQuantity = ServerIndex.ItemInventory[TradeableInfo.ItemName]
		if workspace.NPCs:FindFirstChild("Market") and MarketClone.Inventory.ScrollingFrame:FindFirstChild(TradeableInfo.ItemName) then
			if ItemQuantity <= 0 then
				MarketClone.Inventory.ScrollingFrame[TradeableInfo.ItemName]:Destroy()
			else
				MarketClone.Inventory.ScrollingFrame[TradeableInfo.ItemName].Quantity.Text = ItemQuantity .. "x"
			end
		end
		
		if ItemQuantity then
			if Category:FindFirstChild(TradeableInfo.ItemName) then
				if ItemQuantity <= 0 then
					Category:FindFirstChild(TradeableInfo.ItemName):Destroy()
				else
					if AccessoryInfoFrame.AccessoryName.Text == TradeableInfo.ItemName then
						AccessoryInfoFrame.descFrame.itemQuantity.Text = "Quantity: " .. ItemQuantity
					end
				end
			end
		end
	end
end)

-- Jail event

local JailFrame = Player.PlayerGui.ScreenEffects.JailTimer
local JailTimer = JailFrame.TextLabel

ReplicatedStorage.Remotes.JailEvent.OnClientEvent:Connect(function(Action, Time, Rate)
	if Action == "Jailed" then
		local function FormatTime(Time)
			local Years = math.floor(Time / 31536000);
			local Months = math.floor((Time % 31536000) / 2628000);
			local Days = math.floor(((Time % 31536000) % 2628000) / 86400);
			local Hours = math.floor((Time % (3600 * 24)) / 3600);
			local Minutes = math.floor((Time % 3600) / 60);
			local Seconds = math.floor(Time % 60);
			return Years .. " Years, " .. Months .. " Months, " .. Days .. " Days, " .. Hours .. " Hours, " .. Minutes .. " Minutes, " .. Seconds .. " Seconds"
		end
		
		JailTimer.Text = "Sentence:\n" .. FormatTime(Time) .. "\nBond: $" .. comma_value(Time * Rate)
		JailFrame.Visible = true
	elseif Action == "Free" then
		JailFrame.Visible = false
	end
end)

-- UI Related Code --



-- Currency --

local CurrencyUI = PlayerGui.Currency
CurrencyUI.Frame.KanButton.MouseButton1Click:Connect(function()
	CurrencyUI.Frame.KanBox.Visible = not CurrencyUI.Frame.KanBox.Visible
end)

CurrencyUI.Frame.KanBox.FocusLost:Connect(function(EnterPressed, Input)
	if EnterPressed then
		local Amount = CurrencyUI.Frame.KanBox.Text
		Remotes.DropKan:FireServer(Amount)
	end
	CurrencyUI.Frame.KanBox.Text = ""
end)

-- Settings --

local function Format(Int)
	return string.format("%02i", Int)
end

local function convert(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	local Days = (Hours - Hours%24)/24
	Hours = Hours - Days*24
	return Format(Days)..":"..Format(Hours)..":"..Format(Minutes)
end

local SettingsUI = PlayerGui:WaitForChild("Settings")

local ServerUptime = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Misc"):WaitForChild("ServerTime").Value
SettingsUI.Frame.ServerTime.Text = "Server Time: " .. convert(math.floor(ServerUptime))

ReplicatedStorage.Assets.Misc.ServerTime:GetPropertyChangedSignal("Value"):Connect(function()
	local ServerUptime = ReplicatedStorage.Assets.Misc.ServerTime.Value
	SettingsUI.Frame.ServerTime.Text = "Server Time: " .. convert(math.floor(ServerUptime))
end)

SettingsUI.Frame.Codes.MouseButton1Click:Connect(function()
	SettingsUI.CodeFrame.Visible = not SettingsUI.CodeFrame.Visible
	if SettingsUI.CodeFrame.Visible then
		SettingsUI.CodeFrame.ImageLabel.TextBox.Text = "Enter Code Here"
	end
end)

SettingsUI.CodeFrame.ImageLabel.TextBox.FocusLost:Connect(function(EnterPressed, InputObject)
	if EnterPressed then
		local Text = SettingsUI.CodeFrame.ImageLabel.TextBox.Text
		local Response = Remotes.Codes:InvokeServer(Text)
		if not Response then
			SettingsUI.CodeFrame.ImageLabel.TextBox.Text = "Invalid"
		end
	end
end)

SettingsUI.Frame.MuteMusic.MouseButton1Click:Connect(function()
	local SettingsData = {
		Music = "On"
	}
	
	local BackgroundMusic = SoundService.BackgroundMusic
	if BackgroundMusic.Volume == 1 then
		BackgroundMusic.Volume = 0
		SettingsData.Music = false
	elseif BackgroundMusic.Volume == 0 then
		BackgroundMusic.Volume = 1
		SettingsData.Music = true
	end
	
	Remotes.SettingsEvent:FireServer(SettingsData)
end)

SettingsUI.Frame.SprintToggle.MouseButton1Click:Connect(function()
	Remotes.Sprint:FireServer("Released")
	
	local SettingsData = {
		Sprint = "Shift"
	}
	
	ContextActionService:UnbindAction("Flashstep")
	
	if SprintToggle == "Shift" then
		SprintToggle = "W"
		ContextActionService:UnbindAction("Sprint")
		ContextActionService:BindAction("SprintW", SprintW, false, Enum.KeyCode.W)
		ContextActionService:UnbindAction("Shiftlock")
		ContextActionService:BindAction("Shiftlock", Shiftlock, false, Enum.KeyCode.LeftShift)
		--ContextActionService:BindAction("Flashstep", Flashstep, false, Enum.KeyCode.LeftControl)
		
		SettingsData.Sprint = "W"
		Remotes.SettingsEvent:FireServer(SettingsData)
		
		SettingsUI.Frame.QToggle.Visible = true
	elseif SprintToggle == "W" then
		SprintToggle = "Shift"
		ContextActionService:UnbindAction("SprintW")
		ContextActionService:BindAction("Sprint", Sprint, false, Enum.KeyCode.LeftShift)
		ContextActionService:UnbindAction("Shiftlock")
		ContextActionService:BindAction("Shiftlock", Shiftlock, false, table.unpack(ShiftlockKeys))
		--ContextActionService:UnbindAction("Flashstep")
		Remotes.SettingsEvent:FireServer(SettingsData)
		
		SettingsUI.Frame.QToggle.Visible = false
	end
end)

SettingsUI.Frame.QToggle.MouseButton1Click:Connect(function()
	if SprintToggle == "W" then
		local SettingsData = {
			QToggle = "Q"
		}

		if FlashstepToggle == "Q" then
			FlashstepToggle = "Ctrl"

			ContextActionService:BindAction("Flashstep", Flashstep, false, Enum.KeyCode.LeftControl)

			SettingsData.QToggle = "Ctrl"
			Remotes.SettingsEvent:FireServer(SettingsData)
		elseif FlashstepToggle == "Ctrl" then
			FlashstepToggle = "Q"

			ContextActionService:UnbindAction("Flashstep")

			Remotes.SettingsEvent:FireServer(SettingsData)
		end
	end
end)

SettingsUI.Frame.MainMenu.MouseButton1Click:Connect(function()
	SettingsUI.MainMenuConfirm.Visible = not SettingsUI.MainMenuConfirm.Visible
end)

SettingsUI.MainMenuConfirm.Yes.MouseButton1Click:Connect(function()
	SettingsUI.MainMenuConfirm.Visible = false
	Remotes.MainMenu:FireServer()
end)

SettingsUI.MainMenuConfirm.No.MouseButton1Click:Connect(function()
	SettingsUI.MainMenuConfirm.Visible = false
end)

local CinematicMode = true

SettingsUI.Frame.CinematicMode.MouseButton1Click:Connect(function()
	CinematicMode = not CinematicMode
	PlayerGui.DisplayUI.Enabled = CinematicMode
	PlayerGui.Toolbar.Enabled = CinematicMode
	PlayerGui.ShikaiBankai.Enabled = CinematicMode
	PlayerGui.MissionsUI.Enabled = CinematicMode
	PlayerGui.Leaderboard.Enabled = CinematicMode
	PlayerGui.Currency.Enabled = CinematicMode
end)

local LowGraphicsParts = {}
local Graphics = false
local function LowGraphics(ActionName, InputState, InputObject)
	Graphics = not Graphics

	if Graphics then
		Lighting.GlobalShadows = false
		for i, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				LowGraphicsParts[v] = v.Material
				v.Material = Enum.Material.Plastic
				v.CastShadow = false
			elseif v:IsA("Texture") then
				v:Destroy()
			end
		end
	else
		Lighting.GlobalShadows = true
		for i, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = LowGraphicsParts[v]
				LowGraphicsParts[v] = nil
			end
		end
	end
end

SettingsUI.Frame.LowGraphics.MouseButton1Click:Connect(LowGraphics)

local RefreshCooldown = false
local ServerListConnections = {}

local function Format2(Int)
	return string.format("%02i", Int)
end

local function convert2(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	local Days = (Hours - Hours%24)/24
	Hours = Hours - Days*24
	return Format2(Days).."d "..Format2(Hours).."h "..Format2(Minutes) .. "m"
end

local PlaceIDToButton = {
	[14069122388] = "Hueco Mundo";
	[14069678431] = "Karakura Town";
	[14069956183] = "Rukon District";
	[14070029709] = "Soul Society";
	[14069866342] = "Las Noches";
	[14071822972] = "Wandenreich City"
}

local function CreateCCServer(Location)
	if Player:GetRankInGroup(32740991) > 0 then
		local ServerTemplate = ReplicatedStorage.Assets.UIs.ServerListTemplate:Clone()
		ServerTemplate.ServerName.Text = "CC Server"
		ServerTemplate.Location.Text = Location or "TYPETEST"
		ServerTemplate.ServerSize.Text = "0/30"
		ServerTemplate.ServerRegion.Text = ""
		ServerTemplate.BackgroundColor3 = Color3.fromRGB(60, 0, 255)
		ServerTemplate.ServerTime.Text = convert2(0)
		ServerTemplate.LayoutOrder = 1
		ServerTemplate.Parent = ServerList.Frame.MainUI.ScrollingFrame

		local Connection = ServerTemplate.MouseButton1Click:Connect(function()
			Remotes.ServerListTeleport:FireServer(Location, nil, true)
		end)
		table.insert(ServerListConnections, Connection)
	end
end

SettingsUI.Frame.ServerList.MouseButton1Click:Connect(function()
	ServerList.Enabled = not ServerList.Enabled
	
	if ServerList.Enabled == true and not RefreshCooldown then
		RefreshCooldown = true
		
		task.delay(0.4, function()
			RefreshCooldown = false
		end)
		
		local Servers = ReplicatedStorage.Requests.RequestServerList:InvokeServer(PlaceIDToButton[game.PlaceId])
		--print(Servers)
		if Servers then
			for i, v in pairs(ServerListConnections) do
				ServerListConnections[i]:Disconnect()
				ServerListConnections[i] = nil
			end
			for i, v in ipairs(ServerList.Frame.MainUI.ScrollingFrame:GetChildren()) do
				if v.Name ~= "UIListLayout" then
					v:Destroy()
				end
			end
			
			local CCServer
			for i, v in pairs(Servers) do
				local LayoutOrder = 5
				
				local ServerTemplate = ReplicatedStorage.Assets.UIs.ServerListTemplate:Clone()
				ServerTemplate.ServerName.Text = v.ServerName
				ServerTemplate.ServerSize.Text = v.ServerPlayers --.. " / " .. v.ServerPlayerMax
				ServerTemplate.Location.Text = PlaceIDToButton[game.PlaceId]
				
				if v.ServerPlayerMax then
					ServerTemplate.ServerSize.Text = ServerTemplate.ServerSize.Text .. " / " .. v.ServerPlayerMax
					LayoutOrder += v.ServerPlayerMax
					LayoutOrder -= v.ServerPlayers
				end
				if v.ServerRegion then
					ServerTemplate.ServerRegion.Text = v.ServerRegion
				end
				if v.CCServer then
					CCServer = true
					LayoutOrder = 1
					ServerTemplate.Visible = false
					task.spawn(function()
						if Player:GetRankInGroup(32740991) > 0 then
							ServerTemplate.Visible = true
						end
					end)
					ServerTemplate.BackgroundColor3 = Color3.fromRGB(60, 0, 255)
				else
					ServerTemplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end
				if v.Raid then
					ServerTemplate.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					if not v.CCServer then
						LayoutOrder = 4
					end
				end
				if v.Grace then
					if not v.CCServer then
						LayoutOrder = 3
					end
					ServerTemplate.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
				end
				if v.RankedPlayers then
					ServerTemplate.RankedPlayer.Visible = true
					LayoutOrder = 2
				else
					ServerTemplate.RankedPlayer.Visible = false
				end
				
				ServerTemplate.ServerTime.Text = convert2(math.floor(v.ServerTime or 0))
				
				ServerTemplate.LayoutOrder = LayoutOrder
				ServerTemplate.Parent = ServerList.Frame.MainUI.ScrollingFrame
				
				ServerListConnections[i] = ServerTemplate.MouseButton1Click:Connect(function()
					Remotes.ServerListTeleport:FireServer(PlaceIDToButton[game.PlaceId], v.JobID, v.CCServer)
				end)
			end
			
			if not CCServer then
				CreateCCServer(PlaceIDToButton[game.PlaceId])
			end
		end
	end
end)

local SearchUI = ServerList.Frame.MainUI.Search

SearchUI:GetPropertyChangedSignal("Text"):Connect(function()
	local Text = SearchUI.Text
	
	for i, v in ipairs(ServerList.Frame.MainUI.ScrollingFrame:GetChildren()) do
		if v.Name ~= "UIListLayout" then
			if Text == "" then
				v.Visible = true
			elseif string.lower(v.ServerName.Text):sub(1, #Text) == string.lower(Text) then
				v.Visible = true
			elseif string.lower(v.ServerName.Text) == string.lower(Text) then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end)

local TeleportButtons = {
	ServerList.Frame.MainUI["Hueco Mundo"];
	ServerList.Frame.MainUI["Karakura Town"];
	ServerList.Frame.MainUI["Rukon District"];
	ServerList.Frame.MainUI["Soul Society"];
	ServerList.Frame.MainUI["Las Noches"];
	ServerList.Frame.MainUI["Wandenreich City"]
}

for _, TextButton in ipairs(TeleportButtons) do
	TextButton.MouseButton1Click:Connect(function()
		if not RefreshCooldown then
			RefreshCooldown = true
			
			task.delay(0.4, function()
				RefreshCooldown = false
			end)
			
			local Servers = ReplicatedStorage.Requests.RequestServerList:InvokeServer(TextButton.Name)
			--print(Servers)
			if Servers then
				for i, v in pairs(ServerListConnections) do
					ServerListConnections[i]:Disconnect()
					ServerListConnections[i] = nil
				end
				for i, v in ipairs(ServerList.Frame.MainUI.ScrollingFrame:GetChildren()) do
					if v.Name ~= "UIListLayout" then
						v:Destroy()
					end
				end
				
				local CCServer
				for i, v in pairs(Servers) do
					local LayoutOrder = 5
					
					local ServerTemplate = ReplicatedStorage.Assets.UIs.ServerListTemplate:Clone()
					ServerTemplate.ServerName.Text = v.ServerName
					ServerTemplate.ServerSize.Text = v.ServerPlayers --.. " / " .. v.ServerPlayerMax
					ServerTemplate.Location.Text = TextButton.Name
					if v.ServerPlayerMax then
						ServerTemplate.ServerSize.Text = ServerTemplate.ServerSize.Text .. " / " .. v.ServerPlayerMax
						LayoutOrder += v.ServerPlayerMax
						LayoutOrder -= v.ServerPlayers
					end
					if v.ServerRegion then
						ServerTemplate.ServerRegion.Text = v.ServerRegion
					end
					if v.CCServer then
						CCServer = true
						LayoutOrder = 1
						ServerTemplate.Visible = false
						task.spawn(function()
							if Player:GetRankInGroup(32740991) > 0 then
								ServerTemplate.Visible = true
							end
						end)
						ServerTemplate.BackgroundColor3 = Color3.fromRGB(60, 0, 255)
					else
						ServerTemplate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end
					if v.Raid then
						ServerTemplate.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
						if not v.CCServer then
							LayoutOrder = 4
						end
					end
					if v.Grace then
						if not v.CCServer then
							LayoutOrder = 3
						end
						ServerTemplate.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
					end
					if v.RankedPlayers then
						ServerTemplate.RankedPlayer.Visible = true
						LayoutOrder = 2
					else
						ServerTemplate.RankedPlayer.Visible = false
					end
					ServerTemplate.ServerTime.Text = convert2(math.floor(v.ServerTime or 0))
					ServerTemplate.LayoutOrder = LayoutOrder
					ServerTemplate.Parent = ServerList.Frame.MainUI.ScrollingFrame
					
					ServerListConnections[i] = ServerTemplate.MouseButton1Click:Connect(function()
						Remotes.ServerListTeleport:FireServer(TextButton.Name, v.JobID, v.CCServer)
					end)
				end
				
				if not CCServer then
					CreateCCServer(TextButton.Name)
				end
			end
		end
	end)
end


-- Party UI

CreatePartyButton.MouseButton1Click:Connect(function()
	PartyFrame.Visible = true
	CreatePartyButton.Visible = false
	CloseFrame.Visible = true
	Remotes.PartyCreate:FireServer()
end)

PartyFrame.LeaveParty.MouseButton1Click:Connect(function()
	PartyFrame.Visible = false
	PartyFrame.InvitePlayerBox.Visible = false
	CreatePartyButton.Visible = true
	CloseFrame.Visible = false
	Remotes.PartyLeave:FireServer()
end)

PartyFrame.InvitePlayer.MouseButton1Click:Connect(function()
	PartyFrame.InvitePlayerBox.Visible = not PartyFrame.InvitePlayerBox.Visible
end)

PartyFrame.InvitePlayerBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local function autoFillPlayerName(InvitedPlayer)
			for i, v in ipairs(Players:GetPlayers()) do
				if string.lower(v.Name):sub(1, #InvitedPlayer) == string.lower(InvitedPlayer) then
					return v
				elseif string.lower(v.Name) == InvitedPlayer then
					return v
				end
			end
			return nil
		end

		local InvitedPlayer = PartyFrame.InvitePlayerBox.Text
		local PlayerToInvite = autoFillPlayerName(InvitedPlayer)
		if PlayerToInvite and PlayerToInvite ~= Player then
			ReplicatedStorage.Remotes.PartyInvite:FireServer(PlayerToInvite)
		else
			print("Not a player")
		end
	end
end)

PartyInviteFrame.Decline.MouseButton1Click:Connect(function()
	PartyInviteFrame:TweenPosition(UDim2.new(1.1, 0, 0.874, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	task.delay(0.15, function()
		PartyInviteFrame.Visible = false
	end)
end)

PartyInviteFrame.Accept.MouseButton1Click:Connect(function()
	local PartyLeader = Players:FindFirstChild(PartyInviteFrame.PartyName.Text)
	Remotes.PartyAccept:FireServer(PartyLeader)
	PartyInviteFrame:TweenPosition(UDim2.new(1.1, 0, 0.874, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	task.delay(0.15, function()
		PartyInviteFrame.Visible = false
	end)
end)

CloseFrame.PartyClose.MouseButton1Click:Connect(function()
	PartyFrame.Visible = not PartyFrame.Visible
end)

-- Bail --

BailOfferFrame.Accept.MouseButton1Click:Connect(function()
	Remotes.BailAccept:FireServer(BailOfferFrame.WardenName.Text)
	BailOfferFrame:TweenPosition(UDim2.new(1.1, 0, 0.801, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	task.delay(0.15, function()
		BailOfferFrame.Visible = false
	end)
end)

BailOfferFrame.Decline.MouseButton1Click:Connect(function()
	BailOfferFrame:TweenPosition(UDim2.new(1.1, 0, 0.801, 0), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.15, true)
	task.delay(0.15, function()
		BailOfferFrame.Visible = false
	end)
end)

-- Skill Inventory UI --

NextButton.MouseButton1Click:Connect(function()
	if Page + 1 > #Pages then return end
	Pages[Page].Visible = false
	Page += 1
	Pages[Page].Visible = true
	
	EquipSkillButton.Parent.Visible = false
	LearnSkillButton.Parent.Visible = false
	
	if Page == 3 then
		AccessoryInfoFrame.Visible = true
		SkillInfoFrame.Visible = false
		SkillMainFrame.skilltreeTitle.Text = "- INVENTORY -"
		LearnSkillButton.Text = "Unequip"
		UpdateViewport()
		
		EquipSkillButton.Parent.Visible = false
		LearnSkillButton.Parent.Visible = false
	else
		AccessoryInfoFrame.Visible = false
		SkillInfoFrame.Visible = true
		SkillMainFrame.skilltreeTitle.Text = "- SKILL TREE -"
		LearnSkillButton.Text = "Learn Skill"
		EquipSkillButton.Text = "Equip"
	end
	UIClickAudio()
end)

BackButton.MouseButton1Click:Connect(function()
	if Page - 1 < 1 then return end
	Pages[Page].Visible = false
	Page -= 1
	Pages[Page].Visible = true
	
	if Page == 3 then
		AccessoryInfoFrame.Visible = true
		SkillInfoFrame.Visible = false
		SkillMainFrame.skilltreeTitle.Text = "- INVENTORY -"
		LearnSkillButton.Text = "Unequip"
		UpdateViewport()
		
		EquipSkillButton.Parent.Visible = false
		LearnSkillButton.Parent.Visible = false
	else
		AccessoryInfoFrame.Visible = false
		SkillInfoFrame.Visible = true
		SkillMainFrame.skilltreeTitle.Text = "- SKILL TREE -"
		LearnSkillButton.Text = "Learn Skill"
		EquipSkillButton.Text = "Equip"
	end
	UIClickAudio()
end)

LearnSkillButton.MouseButton1Click:Connect(function()
	if SkillInfoFrame.Visible == true and Page ~= 3 then
		local SkillName = SkillInfoFrame.SkillName.Text
		Remotes.LearnSkill:FireServer(SkillName)
	elseif Page == 3 and AccessoryInfoFrame.Visible == true then
		local AccessoryName = AccessoryInfoFrame.AccessoryName.Text
		Remotes.EquipAccessory:FireServer("Unequip", AccessoryName)
		UIClickAudio()
	end
end)

AccessoryPage3.vanityFrame.vanityBtn.MouseButton1Click:Connect(function()
	if Page == 3 and AccessoryInfoFrame.Visible == true then
		local AccessoryName = AccessoryInfoFrame.AccessoryName.Text
		Remotes.VanityToggle:FireServer(AccessoryName)
		UIClickAudio()
	end
end)

SkillMainFrame.page3Frame.ClanPercentage.ShowClanInfo.MouseButton1Click:Connect(function()
	SkillMainFrame.ClanInformation.Visible = not SkillMainFrame.ClanInformation.Visible
end)

SkillMainFrame.page3Frame.ClanPercentage.ShowModeInfo.MouseButton1Click:Connect(function()
	local Factions = {
		Arrancar = "Arrancar";
		Vastocar = "Arrancar";
		Shinigami = "Shinigami";
		Visored = "Shinigami";
		Quincy = "Quincy";
		LostSoul = "Both";
		Hollow = "Arrancar";
	}

	if Factions[Character:GetAttribute("EntityType")] == "Shinigami" then
		SkillMainFrame.ModeInformation.Res.Visible = false
		SkillMainFrame.ModeInformation.Shikai.Visible = true
		SkillMainFrame.ModeInformation.Volt.Visible = false
	elseif Factions[Character:GetAttribute("EntityType")] == "Arrancar" then
		SkillMainFrame.ModeInformation.Res.Visible = true
		SkillMainFrame.ModeInformation.Shikai.Visible = false
		SkillMainFrame.ModeInformation.Volt.Visible = false
	elseif Factions[Character:GetAttribute("EntityType")] == "Quincy" then
		SkillMainFrame.ModeInformation.Res.Visible = false
		SkillMainFrame.ModeInformation.Shikai.Visible = false
		SkillMainFrame.ModeInformation.Volt.Visible = true
	end
	
	SkillMainFrame.ModeInformation.Visible = not SkillMainFrame.ModeInformation.Visible
end)

SkillMainFrame.page3Frame.ClanPercentage.ShowWeaponInfo.MouseButton1Click:Connect(function()
	SkillMainFrame.ShikaiInformation.Visible = not SkillMainFrame.ShikaiInformation.Visible
end)

local function isHoveringOverGui(Gui)
	local PosX = Gui.AbsolutePosition.X
	local PosY = Gui.AbsolutePosition.Y
	local SizeX = PosX + Gui.AbsoluteSize.X
	local SizeY = PosY + Gui.AbsoluteSize.Y
	if Mouse.X >= PosX and Mouse.Y >= PosY and Mouse.X <= SizeX and Mouse.Y <= SizeY then
		return true
	end
	return nil
end

local EquipConnection = false

EquipSkillButton.MouseButton1Click:Connect(function()
	if Page ~= 3 then
		if EquipConnection == false then		
			EquipConnection = true
			EquipSkillButton.Text = "Select an inventory number"
			UIClickAudio()
			EquipConnection = UserInputService.InputBegan:Connect(function(Input, GPE)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					if Input.UserInputState == Enum.UserInputState.Begin then
						if not isHoveringOverGui(SkillKeys) then
							EquipSkillButton.Text = "Equip"
							EquipConnection:Disconnect()
							EquipConnection = false
						end
						UIClickAudio()
					end
				end
			end)
		end
	else
		local ItemType = AccessoryInfoFrame.descFrame.itemType.Text
		if ItemType == "Type: Item" then
			if EquipConnection == false then		
				EquipConnection = true
				EquipSkillButton.Text = "Select an inventory number"
				UIClickAudio()
				EquipConnection = UserInputService.InputBegan:Connect(function(Input, GPE)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Input.UserInputState == Enum.UserInputState.Begin then
							if not isHoveringOverGui(SkillKeys) then
								EquipSkillButton.Text = "Equip"
								EquipConnection:Disconnect()
								EquipConnection = false
							end
							UIClickAudio()
						end
					end
				end)
			end
		elseif ItemType == "Type: Product" then
			local ProductName = AccessoryInfoFrame.AccessoryName.Text
			Remotes.ProductPurchase:FireServer(ProductName)
			UIClickAudio()
		else
			local AccessoryName = AccessoryInfoFrame.AccessoryName.Text
			Remotes.EquipAccessory:FireServer("Equip", AccessoryName)
			UIClickAudio()
		end
	end
end)

ResetSPButton.MouseButton1Click:Connect(function()
	Remotes.ResetSP:FireServer()
	SkillMainFrame.WipeConfirm.Visible = true
	UIClickAudio()
end)

SkillMainFrame.WipeConfirm.WipeButton.MouseButton1Click:Connect(function()
	Remotes.ResetSP:FireServer("ConfirmedWipe")
end)

SkillMainFrame.WipeConfirm.Decline.MouseButton1Click:Connect(function()
	SkillMainFrame.WipeConfirm.Visible = false
	UIClickAudio()
end)

for i = 1, #AddSPButtons do
	AddSPButtons[i].MouseButton1Click:Connect(function()
		local SPTree = AddSPButtons[i].Parent.Name
		Remotes.AddSP:FireServer(SPTree)
		UIClickAudio()
	end)
	AddSPButtons[i].MouseEnter:Connect(function()
		UIHoverAudio()
		SPToolTips[i].Visible = true
	end)
	AddSPButtons[i].MouseLeave:Connect(function()
		SPToolTips[i].Visible = false
	end)
end

local function SetupSkillTreeEquip()
	for i, v in ipairs(SkillTreeEquipKeys) do
		v.ImageButton.MouseButton1Click:Connect(function()
			if EquipConnection ~= false then
				local SkillToEquip = SkillInfoFrame.SkillName.Text
				if Page == 3 then
					SkillToEquip = AccessoryInfoFrame.AccessoryName.Text
				end
				local InventoryNumber = v.Name

				Remotes.EquipSkill:FireServer(InventoryNumber, SkillToEquip)

				EquipSkillButton.Text = "Equip"
				EquipConnection:Disconnect()
				EquipConnection = false
			end
		end)
	end
end

local CurrentTab = false
local TradeablesInfo = ReplicatedStorage.Requests.GetTradeableInfo:InvokeServer()

local function SetupAccessoryShop()
	for i, v in ipairs(AccessoryTypes) do
		AccessoryShopClone.MainBase.AccessoryTabs[v .. "Tab"].MouseButton1Click:Connect(function()
			if CurrentTab then
				CurrentTab.Visible = false
			end
			CurrentTab = AccessoryShopClone.MainBase.AccessoryTypes[v .. "Frame"]
			CurrentTab.Visible = true
		end)
	end
	
	for i, v in ipairs(AccessoryShopClone.MainBase.AccessoryTypes:GetDescendants()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				local AccessoryName = v.Name
				if TradeablesInfo[AccessoryName] then
					AccessoryShopClone.MainBase.ItemName.TextLabel.Text = AccessoryName
					AccessoryShopClone.MainBase["ItemName - Price"].TextLabel.Text = AccessoryName .. " - " .. TradeablesInfo[AccessoryName].Info.Price .. " Kan"
					AccessoryShopClone.MainBase.Description.TextLabel.Text = TradeablesInfo[AccessoryName].Info.Description
				end
			end)
		end
	end
	
	AccessoryShopClone.MainBase.Buy.TextButton.MouseButton1Click:Connect(function()
		Remotes.PurchaseAccessory:FireServer(AccessoryShopClone.MainBase.ItemName.TextLabel.Text)
	end)
end

local function SetupMarket()
	if workspace.NPCs:FindFirstChild("Market") then
		for i, v in ipairs(MarketClone.Shop.ScrollingFrame:GetChildren()) do
			if v:IsA("TextButton") then
				v.Buy.MouseButton1Click:Connect(function()
					if not SkillTreeClone.Enabled then
						Remotes.PurchaseMarketItem:FireServer(v.Name)
					end
				end)
			end
		end
	end
end

local ReorganizeConnection = false
local PreviousSkillPosition = false
local SkillToMove = false

local function SetupToolbarReorganize()
	for i, v in ipairs(ToolbarDisplayKeys) do
		v.ImageButton.MouseButton1Click:Connect(function()
			if SkillToMove == false then
				v.Select.Visible = true
				SkillToMove = v.SkillName.Text
				PreviousSkillPosition = v.Name

				ReorganizeConnection = UserInputService.InputBegan:Connect(function(Input, GPE)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Input.UserInputState == Enum.UserInputState.Begin then
							if not isHoveringOverGui(PlayerGui.Toolbar.Frame) then
								ReorganizeConnection:Disconnect()
								ReorganizeConnection = false
								SkillToMove = false
								PreviousSkillPosition = false
								v.Select.Visible = false
							end
						end
					end
				end)

				UIClickAudio()
			elseif SkillToMove ~= false then
				local CurrentSkillPosition = v.Name
				local CurrentSkill = v.SkillName.Text
				PlayerGui.Toolbar.Frame[PreviousSkillPosition].Select.Visible = false
				if Character:GetAttribute(PreviousSkillPosition) == false and Character:GetAttribute(CurrentSkillPosition) == false then
					Remotes.EquipSkill:FireServer(CurrentSkillPosition, SkillToMove)
					Remotes.EquipSkill:FireServer(PreviousSkillPosition, CurrentSkill)

					PreviousSkillPosition = false
					SkillToMove = false
					if ReorganizeConnection then
						ReorganizeConnection:Disconnect()
						ReorganizeConnection = false
					end

					UIClickAudio()
				else
					PreviousSkillPosition = false
					SkillToMove = false
					if ReorganizeConnection then
						ReorganizeConnection:Disconnect()
						ReorganizeConnection = false
					end
				end
			end
		end)
	end
end

local function SetupSkilltree()
	for i = 1, 6 do
		for _, SkillFrame in ipairs(SkillTreeFrames[i]:GetChildren()) do
			if SkillFrame:IsA("TextButton") then
				local Skill = SkillFrame.Name
				local SkillInfo = SkillTreeInfo.Info[Skill]
				if SkillInfo then
					SkillMainFrame.playerNameRank.Text = SkillTreeInfo.Name
					
					SkillFrame.MouseButton1Click:Connect(function()
						local SkillOwned = table.find(ServerIndex.Skills, Skill)
						if SkillOwned then
							EquipSkillButton.Parent.Visible = true
							LearnSkillButton.Parent.Visible = false
						else
							EquipSkillButton.Parent.Visible = false
							LearnSkillButton.Parent.Visible = true
						end

						SkillInfoFrame:WaitForChild("SkillName", 6).Text = Skill
						SkillInfoFrame:WaitForChild("descFrame", 6):WaitForChild("descText", 6).Text = SkillInfo.Description

						for i = 1, 3 do
							if SkillInfo["StatReq" .. i] then
								SkillInfoFrame.RequirementsFrame["stat" .. i].Text = SkillInfo["StatReq" .. i].Category .. ": " .. SkillInfo["StatReq" .. i].SP
								SkillInfoFrame.RequirementsFrame["stat" .. i].Visible = true
							else
								SkillInfoFrame.RequirementsFrame["stat" .. i].Visible = false
							end
						end

						UIClickAudio()
					end)
					SkillFrame.MouseButton2Click:Connect(function()
						if SkillInfoFrame.Visible == true and Page ~= 3 then
							Remotes.LearnSkill:FireServer(Skill)
						end
					end)
					local SkillOwned = table.find(ServerIndex.Skills, Skill)
					if SkillInfo.Race[Character:GetAttribute("EntityType")] or SkillOwned then
						SkillFrame.Visible = true
						SkillFrame.Active = true
					else
						SkillFrame.Visible = false
						SkillFrame.Active = false
					end
				else
					SkillFrame.Visible = false
					SkillFrame.Active = false
				end
			end
		end
	end
end

local function SetupProductPurchases()
	local ProductInformation = ReplicatedStorage.Requests.GetProductInfo:InvokeServer()
	
	local Hollows = {
		VastoLorde = true;
		Adjuchas = true;
		Menos = true;
		Fishbone = true;
	}
	
	if Character:GetAttribute("EntityType") == "LostSoul" or Hollows[Character:GetAttribute("EntityType")] then
		return
	end
	
	for i, v in ipairs(AccessoryPage3.devproductsFrame.devproductsMain:GetChildren()) do
		if v:IsA("TextButton") then
			v.MouseButton1Click:Connect(function()
				local ProductName = v.Name
				if ProductInformation then
					EquipSkillButton.Text = "Purchase"
					EquipSkillButton.Parent.Visible = true
					LearnSkillButton.Parent.Visible = false
					
					AccessoryInfoFrame.AccessoryName.Text = ProductName
					
					local DescriptionFrame = AccessoryInfoFrame:WaitForChild("descFrame", 6)
					DescriptionFrame:WaitForChild("itemDesc").Text = ProductInformation[ProductName].Description
					DescriptionFrame:WaitForChild("itemRarity").Text = ProductInformation[ProductName].Price .. " Robux"
					DescriptionFrame:WaitForChild("itemType").Text = "Type: Product"
					DescriptionFrame:WaitForChild("itemQuantity").Text = ""
					UIClickAudio()
				end
			end)
		end
	end
end

local function ResetFunction()	
	local ResetBindable = Instance.new("BindableEvent")
	ResetBindable.Parent = Remotes
	ResetBindable.Event:Connect(function()
		Remotes.CharacterReset:FireServer()
	end)
	
	local Attempts = 0
	local MaxAttempts = 8
	local Success, Error
	repeat
		Success, Error = pcall(function()
			StarterGUI:SetCore("ResetButtonCallback", ResetBindable)
		end)
		if not Success then
			Attempts += 1
			task.wait(1)
		end
	until Success or Attempts >= MaxAttempts
end


ReplicatedStorage.Remotes.MaskCrackUpdate.OnClientEvent:Connect(function(Cracks, Failed)
	SettingsUI.Frame.MaskCracks.Text = "Mask Cracks: " .. Cracks
	if Failed then
		SettingsUI.Frame.MaskCracks.Text = "FAILED VASTO"
	end
	SettingsUI.Frame.MaskCracks.Visible = true
	print("mask cracks:", Cracks)
end)

print("updated group")
ReplicatedStorage.Remotes.LoadClient.OnClientEvent:Connect(function(Settings, Viewport, CatFound)
	print("LoadClient received")
	if Settings.Sprint == "Shift" then
		SprintToggle = "Shift"
		ContextActionService:UnbindAction("SprintW")
		ContextActionService:BindAction("Sprint", Sprint, false, Enum.KeyCode.LeftShift)
		ContextActionService:UnbindAction("Shiftlock")
		ContextActionService:BindAction("Shiftlock", Shiftlock, false, table.unpack(ShiftlockKeys))
		--ContextActionService:UnbindAction("Flashstep")
	elseif Settings.Sprint == "W" then
		SprintToggle = "W"
		ContextActionService:UnbindAction("Sprint")
		ContextActionService:BindAction("SprintW", SprintW, false, Enum.KeyCode.W)
		ContextActionService:UnbindAction("Shiftlock")
		ContextActionService:BindAction("Shiftlock", Shiftlock, false, Enum.KeyCode.LeftShift)
		
		if Settings.FlashstepToggle == "Ctrl" then
			FlashstepToggle = "Ctrl"
			ContextActionService:BindAction("Flashstep", Flashstep, false, Enum.KeyCode.LeftControl)
		end
	end
	
	local BackgroundMusic = SoundService.BackgroundMusic
	if Settings.MusicEnabled == false then
		BackgroundMusic.Volume = 0
	elseif Settings.MusicEnabled == true then
		BackgroundMusic.Volume = 1
	end
	
	--[[local Hollows = {
		VastoLorde = true;
		Adjuchas = true;
		Menos = true;
		Fishbone = true;
	}]]
	
	print("LoadClient - a")
	
	SkillTreeInfo = ReplicatedStorage.Requests.GetSkillTreeInfo:InvokeServer()
	if not SkillTreeInfo then
		task.wait(2.1)
		SkillTreeInfo = ReplicatedStorage.Requests.GetSkillTreeInfo:InvokeServer()
	end
	ServerIndex.SkillTreeInfo = SkillTreeInfo
	
	print("LoadClient - b")
	
	coroutine.wrap(ResetFunction)()
	coroutine.wrap(SetupSkillTreeEquip)()
	coroutine.wrap(SetupToolbarReorganize)()
	coroutine.wrap(SetupSkilltree)()
	coroutine.wrap(SetupAccessoryShop)()
	coroutine.wrap(SetupProductPurchases)()
	coroutine.wrap(SetupMarket)()
	
	print("LoadClient - c")
	
	if Character:GetAttribute("BankaiMeter") then
		local BankaiMeter = (Character:GetAttribute("BankaiMeter") / Character:GetAttribute("MaxBankaiMeter"))
		BankaiBar:TweenSize(UDim2.new(1, 0, -BankaiMeter, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
	end
	
	if Character:GetAttribute("SecondBankaiMeter") then
		local SecondBankaiMeter = (Character:GetAttribute("SecondBankaiMeter") / Character:GetAttribute("MaxSecondBankaiMeter"))
		SecondBankaiBar:TweenSize(UDim2.new(1, 0, -SecondBankaiMeter, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.15, true)
	end

	PlayerGui.Currency.Frame.KanLabel.Text = comma_value(Character:GetAttribute("Kan"))
	
	if Viewport then
		ViewportAllowed = true
		HandleChar()
	end
	
	print("LoadClient finished")
end)

NextButton.MouseEnter:Connect(UIHoverAudio)
BackButton.MouseEnter:Connect(UIHoverAudio)
EquipSkillButton.MouseEnter:Connect(UIHoverAudio)
LearnSkillButton.MouseEnter:Connect(UIHoverAudio)
