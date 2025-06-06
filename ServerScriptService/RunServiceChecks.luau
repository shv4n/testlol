local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MemoryStoreService = game:GetService("MemoryStoreService")

local StatData = require(ServerStorage.Modules.Utility.StatData)
local Quests = require(ServerStorage.Modules.Utility.Quests)
local RandomNumber = require(ServerStorage.Modules.Utility.RandomNumber)

local TYPETEST = StatData.TYPETEST

local ReservedServers
local ServerAccessCodes
local RankedLeaderboards
if TYPETEST then
	RankedLeaderboards = DataStoreService:GetOrderedDataStore("TestPlaceRankedStore")
else
	RankedLeaderboards = DataStoreService:GetOrderedDataStore(StatData.RankedLeaderboardStore)
end

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)

local DataManager = require(ServerStorage.Modules.Managers.DataManager)
local QueueManager = require(ServerStorage.Modules.Managers.QueueManager)
local QueueModule = require(ServerStorage.Modules.QueueTypes.Queues)
local EventsModule = require(ServerStorage.Modules.QueueTypes.Events)
local NPCManager = require(ServerStorage.Modules.Managers.NPCManager)
local QueueData = require(ServerStorage.Modules.Utility.QueueData)
local FactionManager = require(ServerStorage.Modules.Managers.FactionManager)
local Teleports = require(ServerStorage.Modules.Utility.Teleports)
local PartyManager = require(ServerStorage.Modules.Managers.PartyManager)

local ClientModule = ReplicatedStorage.Modules.ClientModules.ClientQueues

local LeaderboardRate = 240 -- Seconds
local LeaderboardAccumulated = 0

local QueueRate = 5 -- Seconds
local QueueAccumulated = 0

local HollowRate = 150 -- Seconds
if StatData.LasNoches or StatData.HuecoMundo then
	HollowRate = 120
end
if StatData.RukonDistrict then
	HollowRate = 210
end
local HollowAccumulated = 0

local FactionRate = 600
local FactionAccumulated = 0

local KarakuraRate = 20
local KarakuraAccumulated = 0

local HomeRate = 40 * 60
local HomeAccunulated = 0

local DangaiRate = 10
local DangaiAccumulated = 0

local BawabawaRate = 90 * 60 -- 90 mins
local BawabawaAccumulated = 0

local JidanboRate = 120 * 60 --
local JidanboAccumulated = 0

local ServerRate = Teleports:GetRefreshRate()
local ServerAccumulated = 0

local ServerTimeRate = 60
local ServerTimeAccumulated = 0

local PartialResRate = 600
local PartialResAccumulated = 0

local PlaceID = game.PlaceId

local function CheckIfPlayer(ActiveQueueInfo, Mission)
	if not PartyManager.Parties[ActiveQueueInfo.PartyLeader] then
		return nil
	end
	
	for i, v in ipairs(ActiveQueueInfo.PartyMembers) do
		if not v:IsDescendantOf(Players) then
			return nil
		end
	end
	return true
end

local function CheckMissionReq(ActiveQueueInfo, Mission, Team)
	if not PartyManager.Parties[ActiveQueueInfo.PartyLeader] then
		return nil
	end
	
	for i, v in ipairs(ActiveQueueInfo.PartyMembers) do
		local Profile = DataManager:RequestProfile(v)
		local Race = Profile.ClientData.Race
		local ShinigamiRank = Profile.ClientData.ShinigamiRank
		if ShinigamiRank > Mission.MissionInfo.RankReq then
			print(v.Name .. " does not meet rank requirement of " .. Mission.MissionInfo.RankReq)
			return nil
		end
		if not Mission.MissionInfo.Races[Team][Race] then
			print("Race req not met")
			return nil
		end
		if v.Character:GetAttribute("CombatTag") > 0 then
			print(v.Name .. " is in combat")
			return nil
		end
		if not v.Character or v.Character.Humanoid.Health <= 0 then
			print(v.Name .. " is dead")
			return nil
		end
		if v.Character:GetAttribute("InsideInnerWorld") then
			print(v.Name .. " is within inner world")
			return nil
		end
	end
	return true
end

local SpawnRates = QueueData.SpawnRates
local LocalMissions = QueueData.Missions

RunService.Heartbeat:Connect(function(DeltaTime)
	QueueAccumulated += DeltaTime
	LeaderboardAccumulated += DeltaTime
	FactionAccumulated += DeltaTime
	ServerAccumulated += DeltaTime
	ServerTimeAccumulated += DeltaTime

	if StatData.HuecoMundo or StatData.WandenreichCity or StatData.SoulSociety or StatData.TYPETEST then
		HomeAccunulated += DeltaTime
	end

	if StatData.HuecoMundo then
		BawabawaAccumulated += DeltaTime
		PartialResAccumulated += DeltaTime
	end
	if StatData.SoulSociety then
		JidanboAccumulated += DeltaTime
	end

	if not FactionManager:IsRaidActive() then
		HollowAccumulated += DeltaTime
		KarakuraAccumulated += DeltaTime
	end

	if KarakuraAccumulated > KarakuraRate then
		KarakuraAccumulated -= KarakuraRate
		if tonumber(os.date("%M")) == 0 and not FactionManager:KarakuraRaidType() and not RunService:IsStudio() then
			FactionManager:KarakuraRaidEvent()
		end
	end

	if HomeAccunulated > HomeRate then
		HomeAccunulated -= HomeRate

		FactionManager:InitiateRaid(nil, nil, "Automated")
	end

	if StatData.KarakuraTown then
		DangaiAccumulated += DeltaTime
	end

	if DangaiAccumulated > DangaiRate then
		DangaiAccumulated -= DangaiRate

		local Time = tonumber(os.date("%M"))

		if Time >= 10 and Time <= 20 or Time >= 40 and Time <= 50 or true then
			workspace.Pathway.PortalBlock:SetAttribute("Active", true)
			workspace.Pathway.PortalBlocker.Transparency = 1
			workspace.Pathway.PortalBlocker.CanCollide = false
			workspace.SoulGate.SoulGate:SetAttribute("Active", true)
			workspace.SoulGate.Blocker.Transparency = 1
			workspace.SoulGate.Blocker.CanCollide = false
			workspace.WandenreichGate.WandenGate:SetAttribute("Active", true)
			workspace.WandenreichGate.Blocker.Transparency = 1
			workspace.WandenreichGate.Blocker.CanCollide = false
		else
			workspace.Pathway.PortalBlock:SetAttribute("Active", false)
			workspace.Pathway.PortalBlocker.Transparency = 0
			workspace.Pathway.PortalBlocker.CanCollide = true
			workspace.SoulGate.SoulGate:SetAttribute("Active", false)
			workspace.SoulGate.Blocker.Transparency = 0
			workspace.SoulGate.Blocker.CanCollide = true
			workspace.WandenreichGate.WandenGate:SetAttribute("Active", false)
			workspace.WandenreichGate.Blocker.Transparency = 0
			workspace.WandenreichGate.Blocker.CanCollide = true
		end
	end

	if QueueAccumulated > QueueRate then
		QueueAccumulated -= QueueRate

		local Queue = QueueManager.LocalQueues
		local Array = {}
		for i, v in ipairs(workspace.Missions:GetChildren()) do
			if v:GetAttribute("Active") == false then
				local Mission = {
					MissionInfo = LocalMissions[StatData.Places[PlaceID]][v.Name];
					Object = v;
				}
				table.insert(Array, Mission)
			end
		end

		if #Array >= 1 then
			local Mission = Array[math.random(1, #Array)]
			local TeamReq = Mission.MissionInfo.TeamReq
			if #Queue >= TeamReq then
				print(Mission.MissionInfo.MissionName, TeamReq)
				if TeamReq == 1 then
					local MissionTeam = Queue[math.random(1, #Queue)]
					table.remove(Queue, table.find(Queue, MissionTeam))

					if CheckIfPlayer(MissionTeam, Mission) then
						if not CheckMissionReq(MissionTeam, Mission, "Team1") then
							task.spawn(function()
								QueueManager:LeaveLocalQueue(MissionTeam.PartyLeader)
								MissionTeam = nil
								--[[table.insert(Queue, MissionTeam)
								print("readding to queue")]]
								
								for i, v in ipairs(MissionTeam.PartyMembers) do
									local PathData = {Module = ClientModule, Skill = "LeftQueue"}
									local RenderDistance = -1
									NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData)
								end
							end)
						end
					else
						MissionTeam = nil
						task.spawn(function()
							for i, v in ipairs(MissionTeam.PartyMembers) do
								local PathData = {Module = ClientModule, Skill = "LeftQueue"}
								local RenderDistance = -1
								NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData)
							end
						end)
					end

					if MissionTeam then
						Mission.Object:SetAttribute("Active", true)
						print("found 1 player mission:", Mission.MissionInfo.MissionName)
						QueueModule[Mission.MissionInfo.MissionName](MissionTeam, Mission)

						local PathData = {Module = ClientModule, Skill = "MissionFound"}
						local RenderDistance = -1
						for i, v in ipairs(MissionTeam.PartyMembers) do
							NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData, Mission)
						end
					end
				else
					local TeamsForMission = {}
					print("before mission found:", #Queue)
					for i = 1, TeamReq do
						TeamsForMission[i] = Queue[math.random(1, #Queue)]
						table.remove(Queue, table.find(Queue, TeamsForMission[i]))

						if CheckIfPlayer(TeamsForMission[i], Mission) then
							if not CheckMissionReq(TeamsForMission[i], Mission, "Team" .. i) then
								task.spawn(function()
									QueueManager:LeaveLocalQueue(TeamsForMission[i].PartyLeader)
									TeamsForMission[i] = nil
									
									for i, v in ipairs(TeamsForMission[i].PartyMembers) do
										local PathData = {Module = ClientModule, Skill = "LeftQueue"}
										local RenderDistance = -1
										NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData)
									end
								end)
									--[[table.insert(Queue, TeamsForMission[i])
									print("readding to queue")]]
							end
						else
							TeamsForMission[i] = nil
							task.spawn(function()
								for i, v in ipairs(TeamsForMission[i].PartyMembers) do
									local PathData = {Module = ClientModule, Skill = "LeftQueue"}
									local RenderDistance = -1
									NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData)
								end
							end)
						end
					end

					if #TeamsForMission == TeamReq then
						Mission.Object:SetAttribute("Active", true)
						print("after mission found:", #Queue)
						-- Start Mission
						print(Mission.MissionInfo.MissionName .. " found")
						QueueModule[Mission.MissionInfo.MissionName](TeamsForMission, Mission)

						local PathData = {Module = ClientModule, Skill = "MissionFound"}
						local RenderDistance = -1
						for i, QueueTeams in ipairs(TeamsForMission) do
							for _, v in ipairs(QueueTeams.PartyMembers) do
								NetworkManager.FireClient(v, v.Character, "ClientEffects", RenderDistance, PathData, Mission)
							end
						end
					end
				end
			end
		end
	end

	if BawabawaAccumulated > BawabawaRate then
		BawabawaAccumulated -= BawabawaRate
		NPCManager:NPC("Bawabawa", "NPCBawabawa", workspace.BawabawaSpawn.CFrame.Position)

		local BawabawaSpawnSound = ReplicatedStorage.Assets.HollowSounds.BawabawaSpawn:Clone()
		BawabawaSpawnSound.PlayOnRemove = true
		BawabawaSpawnSound.Parent = workspace
		BawabawaSpawnSound:Destroy()
		BawabawaSpawnSound = nil
	end
	if JidanboAccumulated > JidanboRate then
		JidanboAccumulated -= JidanboRate
		NPCManager:NPC("Jidanbo", "NPCJidanbo", workspace.JidanboSpawn.CFrame.Position)
	end

	if HollowAccumulated > HollowRate then
		HollowAccumulated -= HollowRate

		if #workspace.HollowSpawns:GetChildren() > 0 then
			for i, v in ipairs(workspace.HollowSpawns:GetChildren()) do
				task.wait(0.05)
				local CharacterNearby

				for _, NearestPlayer in ipairs(Players:GetPlayers()) do
					local Character = NearestPlayer.Character
					if Character and Character.PrimaryPart then
						local Magnitude = (Character.PrimaryPart.Position - v.Position).Magnitude
						if Magnitude <= 450 then
							CharacterNearby = true
							break
						end
					end
				end

				if CharacterNearby then
					local SelectedNumber = RandomNumber:RandomInteger(0, 100)

					SpawnRates[StatData.Places[PlaceID]](v, SelectedNumber)
				end
			end
		end

		print(#workspace.Entities:GetChildren() - #Players:GetPlayers() .. " Entities active")
	end

	if PartialResAccumulated > PartialResRate then
		PartialResAccumulated -= PartialResRate

		Quests:PartialRes()
	end

	if LeaderboardAccumulated > LeaderboardRate then
		LeaderboardAccumulated -= LeaderboardRate

			--[[print("[RunserviceChecks]: Checking ranks")
			for _, Player in ipairs(Players:GetPlayers()) do
				if Player:IsDescendantOf(Players) then
					task.spawn(function()
						local Profile = DataManager:RequestProfile(Player)
						local ProfileElo = Profile.ClientData.Elo

						if ProfileElo then
							local Success, Error = pcall(function()
								RankedLeaderboards:UpdateAsync(Player.UserId, function(oldValue)
									return tonumber(math.floor(ProfileElo))
								end)
							end)
							if Success then
								--print(Player.Name .. "'s elo successfully synced: " .. ProfileElo)
							else
								warn("[Ranked Leaderboard Sync Error]:", Error)
							end
						end
					end)
				end
			end]]

			--[[print("[RunserviceChecks]: Updating ranks")
			local lowestFirst = false
			local numbersShown = 20 -- Top 100 public
			local min = 2
			local max = 10e30
			local Success, Pages = pcall(function()
				return RankedLeaderboards:GetSortedAsync(lowestFirst, numbersShown, min, max)
			end)
			if Success then
				local TopPage = Pages:GetCurrentPage()
				local Data = {}

				for Rank, PageData in pairs(TopPage) do
					Data[tostring(PageData.key)] = Rank
					local LivePlayer = Players:GetPlayerByUserId(PageData.key)
					if LivePlayer then
						--print(LivePlayer.Name .. "'s elo successfully synced: " .. PageData.value)
					end
				end

				for i, v in ipairs(Players:GetPlayers()) do
					if v:IsDescendantOf(Players) then
						if Data[tostring(v.UserId)] then
							DataManager:ModifyProfile(v, "ClientData", "GlobalRank", Data[tostring(v.UserId)])
						else
							DataManager:ModifyProfile(v, "ClientData", "GlobalRank", -1)
						end
					end
				end

				print("[RunserviceChecks]: Successfully synced ranks")
			else
				warn("[Ranked Leaderboard Page Error]:", Pages)
			end]]
	end

	if FactionAccumulated > FactionRate then
		FactionAccumulated -= FactionRate
		FactionManager:UpdateFaction()
	end

	if ServerAccumulated > ServerRate and not RunService:IsStudio() then
		ServerRate = Teleports:GetRefreshRate()
		ServerAccumulated -= ServerRate
		Teleports:GetServerRegion()
		
		local RankedPlayers
		xpcall(function()
			for i, v in ipairs(Players:GetPlayers()) do
				local Profile = DataManager:RequestProfile(v)
				if Profile and Profile.ClientData.GlobalRank > 0 then
					RankedPlayers = true
					break
				end
			end
		end, function(Error)
			warn("[Error locating ranked players]:", Error)
		end)
		
		Teleports:UpdateCurrentServerInfo(RankedPlayers)
	end

	if ServerTimeAccumulated > ServerTimeRate then
		ServerTimeAccumulated -= ServerTimeRate

		local ServerUptime = ReplicatedStorage.Assets.Misc.ServerTime.Value
		ServerUptime += ServerTimeRate
		ReplicatedStorage.Assets.Misc.ServerTime.Value = ServerUptime
	end
end)
