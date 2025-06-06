local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer


StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local ChatService = game:GetService("Chat")
ChatService:SetBubbleChatSettings({
	BubbleDuration = 7,
	MaxBubbles = 4,
	VerticalStudsOffset = 0.5,
	MinimizeDistance = 40,
	MaxDistance = 100,
})
	
for _, Module in pairs(ReplicatedStorage.Modules:GetDescendants()) do
	if Module:IsA("ModuleScript") then
		require(Module)
	end
end

ReplicatedStorage.Remotes.ClientEffects.OnClientEvent:Connect(function(Entity, RenderDistance, PathData, ...)	
	local Arguments = {Number = select("#", ...), ...}
	local Success, Error = pcall(function()
		if RenderDistance > 0 then
			if Player.Character and Player.Character.PrimaryPart and Entity and Entity.PrimaryPart then
				local Rendered = true
				if Player.Character ~= Entity then
					if not Entity:FindFirstChild("HumanoidRootPart") then
						Rendered = nil
					end
				end
				
				if (Entity.PrimaryPart.Position - Player.Character.PrimaryPart.Position).Magnitude < RenderDistance and Rendered then
					local requiredModule = require(PathData.Module)
					requiredModule[PathData.Skill](Entity, unpack(Arguments, 1, Arguments.Number))
				end
			end
		else
			local requiredModule = require(PathData.Module)
			requiredModule[PathData.Skill](Entity, unpack(Arguments, 1, Arguments.Number))
		end
	end)
	if not Success then
		warn("ClientEffects_" .. PathData.Skill .. ":", Error)
	end
end)

for i, v in pairs(workspace.Interactables:GetChildren()) do
	v.ProximityPrompt.Triggered:Connect(function(Player)
		ReplicatedStorage.Remotes[v.Name]:FireServer()
	end)
end

-- Admin UI --

local Connection
local SpectateData = {}
local CurrentlySpectating = {}

local function ToggleAdminUI(ActionName, InputState, InputObject)
	if ActionName == "AdminUI" then		
		if InputState == Enum.UserInputState.Begin then
			Player.PlayerGui.AdminUI.Enabled = not Player.PlayerGui.AdminUI.Enabled
		end
	end
	return Enum.ContextActionResult.Pass
end

local function ToggleModUI(ActionName, InputState, InputObject)
	if ActionName == "ModUI" then		
		if InputState == Enum.UserInputState.Begin then
			Player.PlayerGui.ModUI.Enabled = not Player.PlayerGui.ModUI.Enabled
		end
	end
	return Enum.ContextActionResult.Pass
end



local function DragUI(UI, DeltaTime)	
	local MousePos = UserInputService:GetMouseLocation()
	local X = MousePos.X
	local Y = MousePos.Y
	UI.Position = UDim2.new(0, X, 0, Y - 36)
end

local function Spectate(CameraType, CameraSubject)
	local PlayerListFrame = Players.LocalPlayer.PlayerGui.Leaderboard.PlayerList.PlayerListFrame:FindFirstChild(CameraSubject.Name)
	
	workspace.CurrentCamera.CameraType = CameraType
	workspace.CurrentCamera.CameraSubject = CameraSubject

	if CurrentlySpectating.Name then
		if CameraSubject.Name ~= CurrentlySpectating.Name then
			local CurrentlySpectatingPlayerList = Players.LocalPlayer.PlayerGui.Leaderboard.PlayerList.PlayerListFrame:FindFirstChild(CurrentlySpectating.Name)
			if CurrentlySpectatingPlayerList then
				CurrentlySpectatingPlayerList.PlayerName.TextColor3 = CurrentlySpectating.TextColor
			end
		end
	end

	CurrentlySpectating.Name = CameraSubject.Name
	if PlayerListFrame then
		CurrentlySpectating.TextColor = PlayerListFrame.PlayerName.TextColor3
	end
	if CameraSubject.Name ~= Player.Name then
		if PlayerListFrame then
			PlayerListFrame.PlayerName.TextColor3 = Color3.fromRGB(119, 151, 255)
		end
		for i, v in ipairs(Players:GetPlayers()) do
			local Character = v.Character
			--[[local Character = v.Character.Parent
			if v == Players.LocalPlayer then
				Character = v.Character
			end]]
			
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				if not SpectateData[Character.Name] then
					SpectateData[Character.Name] = {}
					
					SpectateData[Character.Name].NameDisplayDistance = Character.Humanoid.NameDisplayDistance

					Character.Humanoid.NameDisplayDistance = math.huge
					
					SpectateData[Character.Name].UILabel = ReplicatedStorage.Assets.UIs.SpectateStatLabel:Clone()
					SpectateData[Character.Name].UILabel.Adornee = Character.HumanoidRootPart
					SpectateData[Character.Name].UILabel.PlayerName.Text = v.Name
					SpectateData[Character.Name].UILabel.Health.Text = math.floor(Character.Humanoid.Health) .. "/" .. Character.Humanoid.MaxHealth
					SpectateData[Character.Name].UILabel.Reiatsu.Text = math.floor(Character:GetAttribute("Reiatsu")) .. "/" .. Character:GetAttribute("MaxReiatsu")
					SpectateData[Character.Name].UILabel.Parent = Character
				end
				SpectateData[Character.Name].HealthConnection = Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					if SpectateData[Character.Name] then
						SpectateData[Character.Name].UILabel.Health.Text = math.floor(Character.Humanoid.Health) .. "/" .. Character.Humanoid.MaxHealth
					end
				end)
				SpectateData[Character.Name].ReiatsuConnection = Character:GetAttributeChangedSignal("Reiatsu"):Connect(function()
					if SpectateData[Character.Name] then
						SpectateData[Character.Name].UILabel.Reiatsu.Text = math.floor(Character:GetAttribute("Reiatsu")) .. "/" .. Character:GetAttribute("MaxReiatsu")
					end
				end)
			end
		end
	else
		for i, v in ipairs(Players:GetPlayers()) do
			if SpectateData[v.Name] then
				local Character = v.Character
				Character.Humanoid.NameDisplayDistance = SpectateData[v.Name].NameDisplayDistance
			end
		end
		for PlayerName, _ in pairs(SpectateData) do			
			for i, v in pairs(SpectateData[PlayerName]) do
				if typeof(v) == "RBXScriptConnection" then
					SpectateData[PlayerName][i]:Disconnect()
					SpectateData[PlayerName][i] = nil
				elseif typeof(v) == "Instance" then
					if v then
						SpectateData[PlayerName][i]:Destroy()
					end
					SpectateData[PlayerName][i] = nil
				else
					SpectateData[PlayerName][i] = nil
				end
			end
			SpectateData[PlayerName] = nil
		end
	end
end

ReplicatedStorage.Remotes.AdminUIEvent.OnClientEvent:Connect(function()
	ContextActionService:BindAction("AdminUI", ToggleAdminUI, false, Enum.KeyCode.Backquote)
	local MainFrame = Player.PlayerGui.AdminUI.Drag

	MainFrame.Frame.TextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local Text = MainFrame.Frame.TextBox.Text
			ReplicatedStorage.Remotes.AdminUIEvent:FireServer(Text)
		end
		MainFrame.Frame.TextBox.Text = "Command"
	end)
	
	MainFrame.Frame.GlobalMessageBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local Text = MainFrame.Frame.GlobalMessageBox.Text
			ReplicatedStorage.Remotes.GlobalMessageEvent:FireServer(Text)
		end
		MainFrame.Frame.GlobalMessageBox.Text = "Global Message"
	end)
	
	MainFrame.Frame.NameBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local Text = MainFrame.Frame.NameBox.Text
			ReplicatedStorage.Remotes.AdminNameEvent:FireServer(Text)
		end
		MainFrame.Frame.NameBox.Text = "Name Command"
	end)
	
	MainFrame.MouseButton1Down:Connect(function()
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			DragUI(MainFrame, DeltaTime)
		end)
		
		local DisconnectConnection
		DisconnectConnection = UserInputService.InputEnded:Connect(function(Input, GPE)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and Input.UserInputState == Enum.UserInputState.End then
				Connection:Disconnect()
				Connection = nil
				DisconnectConnection:Disconnect()
				DisconnectConnection = nil
			end
		end)
	end)
	
	ReplicatedStorage.Remotes.SpectateEvent.OnClientEvent:Connect(Spectate)
end)

ReplicatedStorage.Remotes.ModUIEvent.OnClientEvent:Connect(function(HeadModerator)
	ContextActionService:BindAction("ModUI", ToggleModUI, false, Enum.KeyCode.Backquote)
	local MainFrame = Player.PlayerGui.ModUI.Drag

	MainFrame.Frame.TextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local Text = MainFrame.Frame.TextBox.Text
			ReplicatedStorage.Remotes.ModUIEvent:FireServer(Text)
		end
		MainFrame.Frame.TextBox.Text = "Command"
	end)
	
	if HeadModerator then
		MainFrame.Frame.NameBox.Visible = true
		MainFrame.Frame.NameBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local Text = MainFrame.Frame.NameBox.Text
				ReplicatedStorage.Remotes.AdminNameEvent:FireServer(Text)
			end
			MainFrame.Frame.NameBox.Text = "Name Command"
		end)
	else
		MainFrame.Frame.NameBox.Visible = false
	end
	
	MainFrame.MouseButton1Down:Connect(function()
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			DragUI(MainFrame, DeltaTime)
		end)

		local DisconnectConnection
		DisconnectConnection = UserInputService.InputEnded:Connect(function(Input, GPE)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 and Input.UserInputState == Enum.UserInputState.End then
				Connection:Disconnect()
				Connection = nil
				DisconnectConnection:Disconnect()
				DisconnectConnection = nil
			end
		end)
	end)
	
	ReplicatedStorage.Remotes.SpectateEvent.OnClientEvent:Connect(Spectate)
end)

local function ToggleCaptainUI(ActionName, InputState, InputObject)
	if ActionName == "CaptainUI" then
		if InputState == Enum.UserInputState.Begin then
			Player.PlayerGui.CaptainUI.Enabled = not Player.PlayerGui.CaptainUI.Enabled
		end
	end
	return Enum.ContextActionResult.Pass
end

local LayoutOrder = {
	["A"] = 1;
	["B"] = 2;
	["C"] = 3;
	["D"] = 4;
	["E"] = 5;
	["F"] = 6;
	["G"] = 7;
	["H"] = 8;
	["I"] = 9;
	["J"] = 10;
	["K"] = 11;
	["L"] = 12;
	["M"] = 13;
	["N"] = 14;
	["O"] = 15;
	["P"] = 16;
	["Q"] = 17;
	["R"] = 18;
	["S"] = 19;
	["T"] = 20;
	["U"] = 21;
	["V"] = 22;
	["W"] = 23;
	["X"] = 24;
	["Y"] = 25;
	["Z"] = 26;
}

local JailData = {
	Player = false;
	PlayerList = {};
}

local function ToggleLieutenantUI(ActionName, InputState, InputObject)
	if ActionName == "LieutenantUI" then
		if InputState == Enum.UserInputState.Begin then
			local LieutenantUI = Player.PlayerGui.LieutenantUI
			local PlayerFrame = LieutenantUI.Frame.PlayerFrame
			
			LieutenantUI.Enabled = not LieutenantUI.Enabled
			
			if LieutenantUI.Enabled then
				local Factions = {
					Arrancar = "Arrancar";
					Vastocar = "Arrancar";
					Shinigami = "Shinigami";
					Visored = "Shinigami";
					Quincy = "Quincy";
				}
				
				for i, v in ipairs(Players:GetPlayers()) do
					local CurrentFaction = Factions[v:GetAttribute("Race")]
					local PlayerFaction = Factions[Player:GetAttribute("Race")]
					if CurrentFaction and PlayerFaction == CurrentFaction then
						local Template = ReplicatedStorage.Assets.UIs.JailPlayerNameTemplate:Clone()
						Template.Name = v.Name
						Template.Text = v.Name
						local Letter = string.upper(v.Name:sub(1, 1))
						if LayoutOrder[Letter] then
							Template.LayoutOrder = LayoutOrder[Letter]
						end
						Template.Parent = PlayerFrame

						JailData.PlayerList[v.Name] = {
							Connection = Template.MouseButton1Click:Connect(function()
								if JailData.Player and PlayerFrame:FindFirstChild(JailData.Player) then
									PlayerFrame[JailData.Player].TextColor3 = Color3.fromRGB(255, 255, 255)
									PlayerFrame[JailData.Player].TextStrokeTransparency = 0
								end

								JailData.Player = v.Name
								Template.TextColor3 = Color3.fromRGB(255, 0, 0)
								Template.TextStrokeTransparency = 1
							end);
							Object = Template
						}
					end
				end
			else
				for i, v in pairs(JailData.PlayerList) do
					JailData.PlayerList[i].Connection:Disconnect()
					JailData.PlayerList[i].Connection = nil
					JailData.PlayerList[i].Object:Destroy()
					JailData.PlayerList[i].Object = nil
					JailData.PlayerList[i] = nil
				end
				
				JailData = {
					Player = false;
					PlayerList = {};
				}
			end
		end
	end
	return Enum.ContextActionResult.Pass
end

ReplicatedStorage.Remotes.CaptainUIEvent.OnClientEvent:Connect(function(Disconnect)
	if Disconnect then
		ContextActionService:UnbindAction("CaptainUI")
		local CaptainUI = Player.PlayerGui:FindFirstChild("CaptainUI")
		if CaptainUI then
			Player.PlayerGui.CaptainUI:Destroy()
		end
		return
	end
	
	ContextActionService:BindAction("CaptainUI", ToggleCaptainUI, false, Enum.KeyCode.L)
	
	local CaptainFrame = Player.PlayerGui.CaptainUI.Frame
	local RaidButton = CaptainFrame.PlayerRaidButton
	local HuntBox = CaptainFrame.HuntBox
	
	RaidButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.CaptainUIEvent:FireServer("Raid")
	end)
	HuntBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local Text = HuntBox.Text
			ReplicatedStorage.Remotes.CaptainUIEvent:FireServer("Hunt", Text)
		end
		HuntBox.Text = "Initiate Hunt"
	end)
end)

ReplicatedStorage.Remotes.LieutenantUIEvent.OnClientEvent:Connect(function(Disconnect)
	if Disconnect then
		ContextActionService:UnbindAction("LieutenantUI")
		local LieutenantUI = Player.PlayerGui:FindFirstChild("LieutenantUI")
		if LieutenantUI then
			Player.PlayerGui.LieutenantUI:Destroy()
		end
		return
	end
	
	ContextActionService:BindAction("LieutenantUI", ToggleLieutenantUI, false, Enum.KeyCode.Semicolon)

	local LieutenantFrame = Player.PlayerGui.LieutenantUI.Frame
	local TimeFrame = LieutenantFrame.TimeFrame
	local PlayerFrame = LieutenantFrame.PlayerFrame
	local Duration = 0.5
	local PlayerToJail
	
	TimeFrame.Hour1.MouseButton1Click:Connect(function()
		Duration =  0.5
		TimeFrame.Duration.Text = "Time: 30 mins"
	end)
	TimeFrame.Hour2.MouseButton1Click:Connect(function()
		Duration = 1
		TimeFrame.Duration.Text = "Time: 1 hour"
	end)
	TimeFrame.Hour3.MouseButton1Click:Connect(function()
		Duration = 1.5
		TimeFrame.Duration.Text = "Time: 1 hour 30 mins"
	end)
	LieutenantFrame.Jail.MouseButton1Click:Connect(function()
		if JailData.Player then
			ReplicatedStorage.Remotes.LieutenantUIEvent:FireServer("Jail", JailData.Player, Duration)
		end
	end)
	LieutenantFrame.Bail.MouseButton1Click:Connect(function()
		if JailData.Player then
			ReplicatedStorage.Remotes.BailEvent:FireServer(JailData.Player)
		end
	end)
end)

-- Hollow camera change --

ReplicatedStorage.Remotes.HollowCameraChange.OnClientEvent:Connect(function(Distance)
	Player.CameraMaxZoomDistance = Distance
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = Player.Character
end)

-- Leaderboard UI --

local Factions = {
	Arrancar = "Arrancar";
	Vastocar = "Arrancar";
	Shinigami = "Shinigami";
	Visored = "Shinigami";
	Quincy = "Quincy";
	LostSoul = "Both";
	Hollow = "Arrancar";
}

local Names = {}

ReplicatedStorage.Remotes.LeaderboardEvent.OnClientEvent:Connect(function(Action, UIPlayer, Info)
	local SameRace = true
	local CurrentRace = Player:GetAttribute("Race")
	
	if Factions[CurrentRace] == Factions[Info.Race] or Factions[Info.Race] == "Both" then
		SameRace = true
	end
	
	if not Info.LeaderboardHidden then
		if Action == "Create" then
			if Player.PlayerGui:FindFirstChild("Leaderboard") and not Player.PlayerGui.Leaderboard.PlayerList.PlayerListFrame:FindFirstChild(UIPlayer) then
				local PlayerListInfo = ReplicatedStorage.Assets.UIs.PlayerListInfo:Clone()
				PlayerListInfo.Name = UIPlayer
				PlayerListInfo.PlayerTitle.Text = Info.Title
				
				if #Info.Name > 0 then
					local Letter = string.upper(Info.Name:sub(1, 1))
					if LayoutOrder[Letter] then
						PlayerListInfo.LayoutOrder = LayoutOrder[Letter]
					end
				end
				
				PlayerListInfo.Parent = Player.PlayerGui.Leaderboard.PlayerList.PlayerListFrame
				
				local PlayerName = Info.Name .. " - " .. Info.Grade
				if UIPlayer ~= Player.Name then
					if Info.HiddenGrade then
						PlayerName = Info.Name .. " - " .. Info.HiddenGrade
					end
				end
				
				PlayerListInfo.PlayerName.Text = PlayerName
				PlayerListInfo.PlayerTitle.Text = Info.Title
				
				if Info.Rank > 0 then
					local RankedName = "#" .. Info.Rank .. " - " .. Info.Name .. " - " .. Info.Grade
					if UIPlayer ~= Player.Name then
						if Info.Race == "Visored" or Info.Race == "Vastocar" then
							if Info.HiddenGrade then
								RankedName = "#" .. Info.Rank .. " - " .. Info.Name .. " - " .. Info.HiddenGrade
							end
						end
					end
					PlayerListInfo.PlayerName.Text = RankedName
					PlayerListInfo.LayoutOrder = 0
				end

				PlayerListInfo.PlayerName.MouseEnter:Connect(function()
					Names[UIPlayer] = PlayerListInfo.PlayerName.Text
					PlayerListInfo.PlayerName.Text = UIPlayer
				end)

				PlayerListInfo.PlayerName.MouseLeave:Connect(function()
					PlayerListInfo.PlayerName.Text = Names[UIPlayer]
				end)

				PlayerListInfo.PlayerName.MouseButton1Click:Connect(function()
					ReplicatedStorage.Remotes.SpectateEvent:FireServer(UIPlayer)
				end)
				
				if SameRace or Player:GetAttribute("Admin") or Player:GetAttribute("Mod") then
					PlayerListInfo.Visible = true
					PlayerListInfo.Active = true
				else
					PlayerListInfo.Visible = false
					PlayerListInfo.Active = false
				end
				
				if Info.Rank > 0 then
					if SameRace then
						PlayerListInfo.PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
						if #Info.Name > 0 then
							local Letter = string.upper(Info.Name:sub(1, 1))
							if LayoutOrder[Letter] then
								PlayerListInfo.LayoutOrder = LayoutOrder[Letter]
							end
						end
					else
						PlayerListInfo.PlayerName.TextColor3 = Color3.fromRGB(255, 139, 139)
						PlayerListInfo.LayoutOrder = 27
					end
					
					PlayerListInfo.LayoutOrder = 0
					PlayerListInfo.Visible = true
					PlayerListInfo.Active = true
				end
			end
		elseif Action == "Update" then
			if Player.PlayerGui:FindFirstChild("Leaderboard") then
				local PlayerListInfo = Player.PlayerGui.Leaderboard.PlayerList.PlayerListFrame:WaitForChild(UIPlayer, 8)
				if PlayerListInfo then
					local PlayerName = Info.Name .. " - " .. Info.Grade
					if UIPlayer ~= Player.Name then
						if Info.HiddenGrade then
							PlayerName = Info.Name .. " - " .. Info.HiddenGrade
						end
					end
					
					if #Info.Name > 0 then
						local Letter = string.upper(Info.Name:sub(1, 1))
						if LayoutOrder[Letter] then
							PlayerListInfo.LayoutOrder = LayoutOrder[Letter]
						end
					end
					
					PlayerListInfo.PlayerName.Text = PlayerName
					PlayerListInfo.PlayerTitle.Text = Info.Title

					if Info.Rank > 0 then
						local RankedName = "#" .. Info.Rank .. " - " .. Info.Name .. " - " .. Info.Grade
						if UIPlayer ~= Player.Name then
							if Info.Race == "Visored" or Info.Race == "Vastocar" then
								if Info.HiddenGrade then
									RankedName = "#" .. Info.Rank .. " - " .. Info.Name .. " - " .. Info.HiddenGrade
								end
							end
						end
						PlayerListInfo.PlayerName.Text = RankedName
					end

					if SameRace or Player:GetAttribute("Admin") or Player:GetAttribute("Mod") then
						PlayerListInfo.Visible = true
						PlayerListInfo.Active = true
					else
						PlayerListInfo.Visible = false
						PlayerListInfo.Active = false
					end
					
					if Info.Rank > 0 then
						if SameRace then
							PlayerListInfo.PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
							if #Info.Name > 0 then
								local Letter = string.upper(Info.Name:sub(1, 1))
								if LayoutOrder[Letter] then
									--PlayerListInfo.LayoutOrder = LayoutOrder[Letter]
								end
							end
						else
							PlayerListInfo.PlayerName.TextColor3 = Color3.fromRGB(255, 139, 139)
							PlayerListInfo.LayoutOrder = 27
						end
						PlayerListInfo.LayoutOrder = 0
						PlayerListInfo.Visible = true
						PlayerListInfo.Active = true
					end
				end
			end
		elseif Action == "Remove" then
			if Player.PlayerGui:WaitForChild("Leaderboard").PlayerList.PlayerListFrame:FindFirstChild(UIPlayer) then
				Player.PlayerGui.Leaderboard.PlayerList.PlayerListFrame[UIPlayer]:Destroy()
			end
			if Names[UIPlayer] then
				Names[UIPlayer] = nil
			end
		end
	else
		if Player.PlayerGui:WaitForChild("Leaderboard").PlayerList.PlayerListFrame:FindFirstChild(UIPlayer) then
			Player.PlayerGui.Leaderboard.PlayerList.PlayerListFrame[UIPlayer]:Destroy()
		end
		if Names[UIPlayer] then
			Names[UIPlayer] = nil
		end
	end
end)

ReplicatedStorage.Remotes.DivisionInviteEvent.OnClientEvent:Connect(function(Phase, Division)
	if Phase == "Captain" then
		local CaptainRemote = Player.CaptainRemote
		
		local CommandFrame = Player.PlayerGui.FactionsUI.CommandFrame
		local ScrollFrame = CommandFrame.ScrollFrame
		CommandFrame.Visible = true
		
		local Connections = {}
		
		local function Disconnect()
			for i, v in pairs(Connections) do
				Connections[i]:Disconnect()
				Connections[i] = nil
			end
			Connections = nil
			CommandFrame.Visible = false
		end
		
		Connections.Connection1 = ScrollFrame.Invite.MouseButton1Click:Connect(function()
			CaptainRemote:FireServer("Invite")
			Disconnect()
		end)
		Connections.Connection2 = ScrollFrame.Promote.MouseButton1Click:Connect(function()
			CaptainRemote:FireServer("Promote")
			Disconnect()
		end)
		Connections.Connection3 = ScrollFrame.Demote.MouseButton1Click:Connect(function()
			CaptainRemote:FireServer("Demote")
			Disconnect()
		end)
		Connections.Connection4 = ScrollFrame.Cancel.MouseButton1Click:Connect(function()
			CaptainRemote:FireServer("Cancel")
			Disconnect()
		end)
	elseif Phase == "Invited" then
		local InviteRemote = Player.CaptainInvite

		local DivisionInviteFrame = Player.PlayerGui.FactionsUI.DivisionInviteFrame
		DivisionInviteFrame.Info.Text = "Enter the " .. Division .. "?"
		DivisionInviteFrame.Visible = true

		local Connection1
		local Connection2
		Connection1 = DivisionInviteFrame.Yes.MouseButton1Click:Connect(function()
			InviteRemote:FireServer("Yes")

			DivisionInviteFrame.Visible = false
			Connection1:Disconnect()
			Connection1 = nil
			Connection2:Disconnect()
			Connection2 = nil
		end)
		Connection2 = DivisionInviteFrame.No.MouseButton1Click:Connect(function()
			InviteRemote:FireServer("No")

			DivisionInviteFrame.Visible = false
			Connection1:Disconnect()
			Connection1 = nil
			Connection2:Disconnect()
			Connection2 = nil
		end)
	end
end)

-- Shiftlock

--[[local CameraController = require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetCameras()
local Shiftlocked = false

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
		end
	end
	return Enum.ContextActionResult.Pass
end]]

local function LeaderboardToggle(ActionName, InputState, InputObject)
	if ActionName == "LeaderboardToggle" then
		if InputState == Enum.UserInputState.Begin then
			Players.LocalPlayer.PlayerGui.Leaderboard.Enabled = not Players.LocalPlayer.PlayerGui.Leaderboard.Enabled
		end
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("LeaderboardToggle", LeaderboardToggle, false, Enum.KeyCode.Period)

-- Events for picking first name

local AcceptConnection
local NameConnection
local MaleConnection
local FemaleConnection
local EventListener
local Confirm = nil

EventListener = ReplicatedStorage.Remotes.ChooseName.OnClientEvent:Connect(function(Action, NameConfirmation)
	if Action == "Enabled" then
		NameConnection = Player.PlayerGui.NameSelectionUI.Frame.TextBox.FocusLost:Connect(function(EnterPressed)
			local Name = Player.PlayerGui.NameSelectionUI.Frame.TextBox.Text
			Player.ClientChooseName:FireServer(Name, Player.PlayerGui.NameSelectionUI.Frame.ConfirmFrame.Gender.Text)
		end)
		MaleConnection = Player.PlayerGui.NameSelectionUI.Frame.Male.MouseButton1Click:Connect(function()
			Player.PlayerGui.NameSelectionUI.Frame.ConfirmFrame.Gender.Text = "Male"
		end)
		FemaleConnection = Player.PlayerGui.NameSelectionUI.Frame.Female.MouseButton1Click:Connect(function()
			Player.PlayerGui.NameSelectionUI.Frame.ConfirmFrame.Gender.Text = "Female"
		end)
	elseif Action == "Confirm" then
		local ConfirmFrame = Player.PlayerGui.NameSelectionUI.Frame.ConfirmFrame
		ConfirmFrame.Visible = true
		ConfirmFrame.TextLabel.Text = NameConfirmation
		Confirm = true
		
		AcceptConnection = ConfirmFrame.Accept.MouseButton1Click:Connect(function()
			if Confirm then
				Confirm = nil
				local Gender = ConfirmFrame.Gender.Text
				Player.ClientChooseName:FireServer(ConfirmFrame.TextLabel.Text, Gender, true)
			end
		end)
	elseif Action == "Invalid" then
		local ConfirmFrame = Player.PlayerGui.NameSelectionUI.Frame.ConfirmFrame
		ConfirmFrame.Visible = false
		Confirm = nil
	elseif Action == "Disabled" then
		EventListener:Disconnect()
		EventListener = nil
		if AcceptConnection then
			AcceptConnection:Disconnect()
			AcceptConnection = nil
		end
		if NameConnection then
			NameConnection:Disconnect()
			NameConnection = nil
		end
		if MaleConnection then
			MaleConnection:Disconnect()
			MaleConnection = nil
		end
		if FemaleConnection then
			FemaleConnection:Disconnect()
			FemaleConnection = nil
		end
		
		--[[if game.PlaceId ~= 10604664859 then
			local ShiftlockKeys = {Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt}
			ContextActionService:BindAction("Shiftlock", Shiftlock, false, table.unpack(ShiftlockKeys))

			ReplicatedStorage.Remotes.DisableShiftlock.OnClientEvent:Connect(function()
				ContextActionService:UnbindAction("Shiftlock")
				CameraController.activeCameraController:SetIsMouseLocked(false)
				CameraController.activeCameraController:SetMouseLockOffset(Vector3.zero)
			end)
		end]]
	end
end)

ReplicatedStorage.Remotes.ShikaiBankaiUI.OnClientEvent:Connect(function(Info)
	local ShikaiBankai = Player.PlayerGui.ShikaiBankai
	
	if Info.Shikai then
		ShikaiBankai.Z.Visible = true
		ShikaiBankai.X.Visible = true
		ShikaiBankai.C.Visible = true
	end
	if Info.Bankai then
		if Info.Shikai then
			ShikaiBankai.bankaiFrame.Visible = true
		end
		ShikaiBankai.T.Visible = true
		ShikaiBankai.G.Visible = true
	end
	if Info.SecondBankai then
		ShikaiBankai.resFrame.Visible = true
	end
	if Info.PartialRes and not Info.Bankai then
		ShikaiBankai.Z.Visible = false
		ShikaiBankai.X.Visible = false
		ShikaiBankai.C.Visible = false
		ShikaiBankai[Info.PartialRes].Visible = true
		if Info.PartialRes2 then
			ShikaiBankai[Info.PartialRes2].Visible = true
		end
	end
	
	local SkillNames = Info.SkillNames
	if SkillNames then
		for i, v in pairs(SkillNames) do
			ShikaiBankai[i].TextButton.Text = v
		end
	end
	
	local Keys = {"Z", "X", "C", "T", "G"}
	for i, v in ipairs(Keys) do
		if Player.Character:GetAttribute(v) then
			ShikaiBankai[v].TextButton.TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			ShikaiBankai[v].TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

-- Invisible Hollow Event

ReplicatedStorage.Remotes.InvisibleHollowEvent.OnClientEvent:Connect(function(Action, Hollow)
	if Action == "Enabled" then
		Hollow:SetAttribute("Invisible", true)
		for i, v in ipairs(Hollow:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
	elseif Action == "Disabled" then
		for i, v in ipairs(workspace.Entities:GetChildren()) do
			if v:GetAttribute("Invisible") then
				for _, BaseParts in ipairs(v:GetDescendants()) do
					if BaseParts:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						BaseParts.Transparency = 0
					end
				end
			end
		end
	end
end)
