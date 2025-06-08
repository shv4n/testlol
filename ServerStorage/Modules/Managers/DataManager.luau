local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DatastoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService('HttpService');

local ProfileService = require((script.ProfileService))
local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local PartyManager = require(ServerStorage.Modules.Managers.PartyManager)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local ServerSkillReqs = require(ServerStorage.Modules.Utility.ServerSkillReqs)
local PassivesManager = require(ServerStorage.Modules.Managers.PassivesManager)
local ZanpakutoWeapons = require(ServerStorage.Modules.Utility.ZanpakutoWeapons)
local TradeablesData = require(ServerStorage.Modules.Utility.TradeablesData)
local ZanpakutoNames = require(ServerStorage.Modules.Utility.ZanpakutoNames)
local PositionTitles = require(ServerStorage.Modules.Utility.FactionPositions)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local Webhooks = require(ServerStorage.Modules.Utility.Webhooks)
local Teleports = require(ServerStorage.Modules.Utility.Teleports)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local PlayerCountManager = require(ServerStorage.Modules.Managers.PlayerCountManager)
local QuincyMedallions = require(ServerStorage.Modules.Utility.QuincyMedallions)
local Whitelists = require(ServerStorage.Modules.Utility.AdminWhitelist)
local RandomNumber = require(ServerStorage.Modules.Utility.RandomNumber)

local WebhookChannel = "FactionManager"
local VastoPatrolChannel = "VastoPatrol"

local TYPETEST = StatData.TYPETEST

local TitleKey = StatData.TitleStoreKey

local TitleDataStore
local RankedLeaderboards
if TYPETEST then
	RankedLeaderboards = DatastoreService:GetOrderedDataStore("TestPlaceRankedStore")
	TitleDataStore = DatastoreService:GetDataStore("TestTitles")
else
	RankedLeaderboards = DatastoreService:GetOrderedDataStore(StatData.RankedLeaderboardStore)
	TitleDataStore = DatastoreService:GetDataStore(StatData.TitleStore)
end

local ProfileTemplate = { -- ProfileTemplate is what empty profiles will default to, updating the template will not include missing template values in existing profiles.
	ClientData = {
		StateModule = "LostSoul", -- Shinigami, Arrancar, Vastocar, and Visored will use shinigami state module
		Race = "LostSoul", -- Races are Lost Soul, Hollow, Shinigami, Arrancar, Vastocar, and Visored
		Name = "",
		Clan = "",
		Title = "",
		EXP = 0,
		Kan = 0,
		ShikaiEXP = 0,
		DivisionEXP = 0,
		RankupRequirements = {
			PlayerGrips = 0,
			RaidGrips = 0,
		},
		BankaiRequirements = {
			BankaiReady = false;
			BankaiFight = false;
			BankaiSwordTimer = 0;
			RankDuration = 0;
			Hollows = 0;
			Players = 0;
			WorldBosses = 0;
		},
		SP = 0,
		Hakuda = 0,
		Kendo = 0,
		Kido = 0,
		Speed = 0,
		Healing = 0,
		MaxHealth = 100,
		MaxReiatsu = 100,
		MaxPosture = 50,
		CombatLogged = 0,
		Elo = 0,
		GlobalRank = -1,
		LastPlayerGripped = false,
		ShinigamiRank = 14; -- RANKBASED
		VengefulRace = "None";
		VengefulTimer = 0;
		LoggedPlace = "Karakura Town";
		LoggedPosition = false;
		Gender = "Male",
	};
	Division = {
		Squad = -1;
		Rank = 4; -- 1, 2, 3, 4
		Captain = false;
	};
	Settings = {
		SoundEnabled = true;
		MusicEnabled = true;
		ScreenShake = true;
		ShadowsEnabled = true;
		Sprint = "Shift";
		FlashstepToggle = "Q";
	};
	ItemInventory = {};
	Accessories = {
		Head = "Empty";
		Face = "Empty";
		Neck = "Empty";
		Shoulder = "Empty";
		Arm = "Empty";
		Torso = "Empty";
		Back = "Empty";
		Waist = "Empty";
		Leg = "Empty";
	};
	AccessoriesVanity = {
		Head = false;
		Face = false;
		Neck = false;
		Shoulder = false;
		Arm = false;
		Torso = false;
		Back = false;
		Waist = false;
		Leg = false;
	};
	UnlockedSkills = {};
	Inventory = {
		One = "Empty";
		Two = "Empty";
		Three = "Empty";
		Four = "Empty";
		Five = "Empty";
		Six = "Empty";
		Seven = "Empty";
		Eight = "Empty";
		Nine = "Empty";
		Zero = "Empty";
		Minus = "Empty";
		Equals = "Empty";
	};
	ServerData = {
		Banned = false;
		Strikes = 0;
	}
}

local Checks = {
	[StatData.PlaceIDs["Hueco Mundo"]] = { -- Hueco
		Arrancar = true;
		Hollow = true;
		Vastocar = true;
	},
	[StatData.PlaceIDs["Soul Society"] ] = { -- Soul Society
		Shinigami = true;
		Visored = true;
	},
	[StatData.PlaceIDs["Karakura Town"] ] = { -- Karakura
		Arrancar = true;
		Hollow = true;
		Vastocar = true;
		Shinigami = true;
		Visored = true;
	}
}

local cachedProfiles = {} -- [Player] = Profile
local GameProfileStore
if TYPETEST then
	GameProfileStore = ProfileService.GetProfileStore("TestEntitiesFolder", ProfileTemplate)
else
	GameProfileStore = ProfileService.GetProfileStore("GameEntitiesFolder", ProfileTemplate)
	--GameProfileStore = GameProfileStore.Mock
end

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

local function createInitialData(Profile, Player) -- shared data for all races
	local function RollZanpakuto()
		-- Roll players weapon type & their weapon model
		local function SetupArray(Object)
			local Array = {}
			for i, v in pairs(Object:GetChildren()) do
				if not v:GetAttribute("Whitelist") then
					table.insert(Array, v.Name)
				end
			end
			table.sort(Array)
			return Array
		end
		
		local CommonShikaiWeapons = {"Dualblade", "Greatsword", "Katana", "Scythe", "Spear", "Twinblade", "Hammer"} -- Gauntlet
		local RareShikaiWeapons = {"Dagger", "Longsword"}

		local WeaponTypes = SetupArray(ServerStorage.Assets.Weapons)
		local SelectedType = WeaponTypes[RandomNumber:RandomInteger(1, #WeaponTypes)]
		
		local ShikaiOdds = RandomNumber:RandomInteger(1, 100)
		if ShikaiOdds <= 1 then
			SelectedType = RareShikaiWeapons[RandomNumber:RandomInteger(1, #RareShikaiWeapons)]
		else
			SelectedType = CommonShikaiWeapons[RandomNumber:RandomInteger(1, #CommonShikaiWeapons)]
		end
		
		Profile.Data.ClientData.WeaponType = SelectedType
		local WeaponModels = SetupArray(ServerStorage.Assets.Weapons[SelectedType])
		Profile.Data.ClientData.WeaponModel = WeaponModels[RandomNumber:RandomInteger(1, #WeaponModels)]
		local BankaiWeaponModels = SetupArray(ServerStorage.Assets.BankaiWeapons[SelectedType])
		Profile.Data.ClientData.BankaiWeaponModel = BankaiWeaponModels[RandomNumber:RandomInteger(1, #BankaiWeaponModels)]
		
		--[[Profile.Data.ClientData.WeaponType = "Katana"
		Profile.Data.ClientData.WeaponModel = "Blade1"
		Profile.Data.ClientData.BankaiWeaponModel = "Katana1"]]
		
		-- Roll zanpakuto colors
		local RNG = Random.new()
		local SelectedNumber = RandomNumber:RandomInteger(1, 2)
		
		local function RGBValue()
			return RNG:NextNumber(0, 255) * 0.6
		end
		
		local R, G, B

		if SelectedNumber == 1 then
			R, G, B = 255, 255, 255
		elseif SelectedNumber == 2 then
			R, G, B = 0, 0, 0
		end
		
		Profile.Data.ClientData.HandleColor = {RGBValue(), RGBValue(), RGBValue()}
		Profile.Data.ClientData.Handle2Color = {R, G, B}
		Profile.Data.ClientData.WrapsColor = {RGBValue(), RGBValue(), RGBValue()}
		
		-- Roll zanpakuto parts

		local HiltTypes = SetupArray(ServerStorage.Assets.ZanpakutoParts.Hilts)
		local HandleTypes = SetupArray(ServerStorage.Assets.ZanpakutoParts.Handles)

		Profile.Data.ClientData.HiltType = HiltTypes[RandomNumber:RandomInteger(1, #HiltTypes)]
		Profile.Data.ClientData.HandleType = HandleTypes[RandomNumber:RandomInteger(1, #HandleTypes)]
	
		-- Select random sheathe / draw animations (draw animation matches sheathe position)
		Profile.Data.ClientData.Sheathe = RandomNumber:RandomInteger(1, 4)
		--Profile.Data.ClientData.Sheathe = 1
	end
	
	local function RollZanpakutoName()
		local ZanpakutoNames = ZanpakutoNames.Shinigami

		local CommonCallouts = {
			"Ascend", "Knock", "Ransack","Unleash", "Hunt", "Howl", "Scatter", "Awaken", "Attack", "Murder", "Brawl", "Punish", "Cut", "Pursue", "Release",
			"Terrorize", "Summon", "Surge", "Unleash", "Ambush", "Fight", "Ravage", "Approach", "Vanquish", "Spark", "Unravel", "Cauterize",
			"Harmonize", "Rise", "Provoke", "Cleanse", "Cure", "Blossom", "Conquer"
		}

		local RareCallouts = {
			"Etch in Flesh", "Pierce through Heaven", "Pierce through Hell", "Dive into the Void", "Shake the World", "Relish in Pain", "Distort Reality",
			"Prey upon the Weak", "Spill Blood", "Burst with Anger", "Descend from Heaven", "Ascend from Hell", "Spread Fear",
			"Reign from Above", "Make them Suffer", "Take their Life", "Show no Mercy", "Deceive the World",
			"Crush their Dreams", "Show no Mercy", "Rip them Apart", 
		}

		local RandomZanpakutoName = ZanpakutoNames[RandomNumber:RandomInteger(1, #ZanpakutoNames)]
		Profile.Data.ClientData.ZanpakutoName = RandomZanpakutoName.Shikai
		Profile.Data.ClientData.ZanpakutoName2 = RandomZanpakutoName.Bankai
		
		if RandomNumber:RandomInteger(1, 100) <= 10 then
			Profile.Data.ClientData.ReleasePhrase = RareCallouts[RandomNumber:RandomInteger(1, #RareCallouts)]
		else
			Profile.Data.ClientData.ReleasePhrase = CommonCallouts[RandomNumber:RandomInteger(1, #CommonCallouts)]
		end
	end
	
	local function RollShikaiPersonality()
		local Personalities = {"Kind Hearted", "Squeamish", "Vengeful", "Hateful", "Chaotic", "Pure"}
		Profile.Data.ClientData.ShikaiPersonality = Personalities[RandomNumber:RandomInteger(1, #Personalities)]
	end
	
	-- Select random eye color
	local R, G, B = (RandomNumber:RandomInteger(1, 255) * 10) / 2 , (RandomNumber:RandomInteger(1, 255) * 10) / 2, (RandomNumber:RandomInteger(1, 255) * 10) / 2
	Profile.Data.ClientData.EyeColor = {R, G, B}
	
	Profile.Data.ClientData.Eyes = RandomNumber:RandomInteger(1, 8)-- No need to roll for pupils as well as they are in pairs e.g. Eye1 only works with Pupil1
	Profile.Data.ClientData.Mouth = RandomNumber:RandomInteger(1, 6)
	Profile.Data.ClientData.Eyebrow = RandomNumber:RandomInteger(1, 4)
	if ServerStorage.Assets.Accessories.Faces["Eye" .. Profile.Data.ClientData.Eyes]:GetAttribute("NoEyebrow") then
		Profile.Data.ClientData.Eyebrow = 0
	end
	
	if RandomNumber:RandomInteger(1, 100) <= 10 then
		Profile.Data.ClientData.Marking = RandomNumber:RandomInteger(1, 13)
	else
		Profile.Data.ClientData.Marking = 0 -- no marking decal
	end
	
	Profile.Data.ClientData.ZanpakutoWeapon = "Katana" -- If vastocar weapon then set Sheathe data to 1
	Profile.Data.ClientData.ShikaiUnlocked = false
	Profile.Data.ClientData.BankaiUnlocked = false
	Profile.Data.ClientData.BankaiMeter = 0
	Profile.Data.ClientData.BankaiTimer = 0
	Profile.Data.ClientData.MaxBankaiMeter = StatData.BankaiMeter
	Profile.Data.ClientData.RankTimer = 0
	Profile.Data.ClientData.ShikaiTimer = 0
	Profile.Data.ClientData.Meditation = 0
	Profile.Data.ClientData.Clothes = 1
	Profile.Data.ClientData.InnerWorld = RandomNumber:RandomInteger(1, 5)
	Profile.Data.ClientData.JailTimer = 0
	Profile.Data.ClientData.ResetTimer = 0
	Profile.Data.ClientData.GargantaBreakTimer = 0
	Profile.Data.ClientData.Wave2 = true
	Profile.Data.ClientData.Kills = 0
	Profile.Data.ClientData.Deaths = 0
	Profile.Data.ClientData.PublicRelease = true
	
	RollZanpakuto()
	RollZanpakutoName()
	RollShikaiPersonality()
	
	local Success, Friends = pcall(function()
		return Players:GetFriendsAsync(Player.UserId)
	end)
	if Success then
		local CurrentFriendPage = Friends:GetCurrentPage()
		
		if #CurrentFriendPage > 0 then
			Profile.Data.ClientData.ShikaiSpiritAppearance = CurrentFriendPage[RandomNumber:RandomInteger(1, #CurrentFriendPage)].Id
		else
			Profile.Data.ClientData.ShikaiSpiritAppearance = Player.UserId
		end
	else
		Profile.Data.ClientData.ShikaiSpiritAppearance = Player.UserId
		warn(Friends)
	end
end

local function RequestRank(Player)
	local Profile = cachedProfiles[Player]
	local Race = Profile.Data.ClientData.Race
	local Rank = Profile.Data.ClientData.ShinigamiRank

	local Ranks = { -- RANKBASED
		SharedRanks = {
			[3] = "Special Grade";
			[4] = "Special Grade 1";
			[5] = "Grade 1";
			[6] = "Semi-Grade 1";
			[7] = "Grade 2";
			[8] = "Semi-Grade 2";
			[9] = "Grade 3";
			[10] = "Grade 4";
			[11] = "Grade 5";
			[12] = "Trainee";
			[13] = "Lost Soul";
			[14] = "Human";
		};
		HollowRanks = {
			[15] = "Vasto Lorde";
			[16] = "Adjuchas";
			[17] = "Menos";
			[18] = "Fishbone";
		};
		ShinigamiRanks = {
			[1] = "Elite Grade"; -- "Captain Grade"
			[2] = "Semi-Elite Grade"; -- "Lt. Grade"
		};
		ArrancarRanks = {
			[1] = "Elite Grade"; -- "Espada Grade"
			[2] = "Semi-Elite Grade"; -- "Fraccion Grade"
		};
		VastocarRanks = {
			[0] = "???";
			[1] = "Elite Grade"; -- "Espada Grade"
			[2] = "Semi-Elite Grade"; -- "Fraccion Grade"
		};
		VisoredRanks = {
			[0] = "???";
			[1] = "Elite Grade"; -- "Captain Grade"
			[2] = "Semi-Elite Grade"; -- "Lt. Grade"
		};
		QuincyRanks = {
			[0] = "???";
			[1] = "Elite Grade"; -- "Captain Grade"
			[2] = "Semi-Elite Grade"; -- "Lt. Grade"
		}
	}
	
	if Profile.Data.ClientData.WeakVisored then
		Ranks.VisoredRanks[0] = "?"
	end
	if Profile.Data.ClientData.WeakVasto then
		Ranks.VastocarRanks[0] = "?"
	end

	if Rank > 2 and Rank < 15 then -- RANKBASED
		return Ranks.SharedRanks[Rank]
	else
		return Ranks[Race .. "Ranks"][Rank]
	end
end

local function GetPlayerName(Player)
	local Profile = cachedProfiles[Player]
	
	local Name
	local FirstName = Profile.Data.ClientData.Name
	local ClanName = Profile.Data.ClientData.Clan
	local ClanInfo = ClanData[ClanName]

	local Spacer = " "
	if ClanInfo.Spacer then
		Spacer = ClanInfo.Spacer
	end

	Name = FirstName .. Spacer .. ClanName
	if ClanInfo.HideClanName then
		Name = FirstName
	end
	
	return Name
end

local function RequestSP(Player)
	local Profile = cachedProfiles[Player]
	local Grade = RequestRank(Player)
	
	local Name = GetPlayerName(Player)
	
	local PlayerSkillSpread = {
		Name = Name .. " - " .. Grade;
		SP = Profile.Data.ClientData.SP;
		Hakuda = Profile.Data.ClientData.Hakuda;
		Kendo = Profile.Data.ClientData.Kendo;
		Kido = Profile.Data.ClientData.Kido;
		Healing = Profile.Data.ClientData.Healing;
		Speed = Profile.Data.ClientData.Speed;
	}
	return PlayerSkillSpread
end

local function SetupUIs(Player)	
	local PlayerProfile = cachedProfiles[Player]
	Player:SetAttribute("Race", PlayerProfile.Data.ClientData.Race)

	if table.find(Whitelists.Admin, Player.UserId) then
		Player:SetAttribute("Admin", true)
	end
	
	local Moderator
	local Success, Error = pcall(function()
		local GroupID = 32740991
		local ModeratorGroupRank = 3
		
		local RankInGroup = Player:GetRankInGroup(GroupID)
		if RankInGroup == ModeratorGroupRank then
			Moderator = true
		end
	end)
	
	if Moderator or table.find(Whitelists.HeadModerator, Player.UserId) then
		Player:SetAttribute("Mod", true)
	end
	
	local function CreateLeaderboard()
		for i, v in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				if v:IsDescendantOf(Players) then
					local Profile = cachedProfiles[v]
					if Profile then
						local Name = GetPlayerName(v)
						local ClanInfo = ClanData[Profile.Data.ClientData.Clan]

						local Info = {
							Rank = Profile.Data.ClientData.GlobalRank,
							Grade = RequestRank(v),
							Name =  Name,
							Title = Profile.Data.ClientData.Title,
							LeaderboardHidden = ClanInfo.LeaderboardHidden,
							Race = Profile.Data.ClientData.Race,
						}
						
						if Profile.Data.ClientData.Race == "Visored" or Profile.Data.ClientData.Race == "Vastocar" then
							Info.HiddenGrade = "???"
							if Profile.Data.ClientData.WeakVisored or Profile.Data.ClientData.WeakVasto then
								Info.HiddenGrade = "?"
							end
						end

						ReplicatedStorage.Remotes.LeaderboardEvent:FireAllClients("Create", v.Name, Info)
					end
				end
			end)
		end
	end
	
	CreateLeaderboard()
	
	local PlayerUnlockedSkills = cachedProfiles[Player].Data.UnlockedSkills
	local PlayerItemInventory = cachedProfiles[Player].Data.ItemInventory
	local PlayerSPTable = RequestSP(Player)
	local Toolbar = cachedProfiles[Player].Data.Inventory
	ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, nil, PlayerItemInventory)
	ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
	
	local HumanCheck = {
		Shinigami = true;
		Visored = true;
	}
	
	if table.find(PositionTitles.CaptainUI, PlayerProfile.Data.ClientData.Title) then
		local CaptainUI = ServerStorage.Assets.UIs.CaptainUI:Clone()
		CaptainUI.Parent = Player.PlayerGui
		ReplicatedStorage.Remotes.CaptainUIEvent:FireClient(Player)
		
		local LieutenantUI = ServerStorage.Assets.UIs.LieutenantUI:Clone()
		LieutenantUI.Parent = Player.PlayerGui
		ReplicatedStorage.Remotes.LieutenantUIEvent:FireClient(Player)
	elseif table.find(PositionTitles.LieutenantUI, PlayerProfile.Data.ClientData.Title) then
		local LieutenantUI = ServerStorage.Assets.UIs.LieutenantUI:Clone()
		LieutenantUI.Parent = Player.PlayerGui
		ReplicatedStorage.Remotes.LieutenantUIEvent:FireClient(Player)
	elseif table.find(PositionTitles.ArrancarEspadaTitles, PlayerProfile.Data.ClientData.Title) then
		local LieutenantUI = ServerStorage.Assets.UIs.LieutenantUI:Clone()
		LieutenantUI.Parent = Player.PlayerGui
		ReplicatedStorage.Remotes.LieutenantUIEvent:FireClient(Player)
	end
end

local function ChooseName(Player)
	local Profile = cachedProfiles[Player]
	
	local NameSelectionUI = ServerStorage.Assets.UIs.NameSelectionUI:Clone()
	NameSelectionUI.Parent = Player.PlayerGui
	
	local Leaderboard = ServerStorage.Assets.UIs.Leaderboard:Clone()
	Leaderboard.Parent = Player.PlayerGui
	
	local Toolbar = ServerStorage.Assets.UIs.Toolbar:Clone()
	Toolbar.Parent = Player.PlayerGui
	
	local RankTimer = Profile.Data.ClientData.RankTimer
	local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
	local TimeDifference = DateTime.now().UnixTimestamp - RankTimer
	local Minutes = TimeDifference / 60
	local RankupText = math.floor(Minutes) .. "/" .. math.floor(StatData.RankTimers[ShinigamiRank] * 60) .." Min"
	if Minutes >= StatData.RankTimers[ShinigamiRank] * 60 then
		RankupText = "CAN RANK"
	end
	
	local Name = GetPlayerName(Player)
	
	local Settings = ServerStorage.Assets.UIs.Settings:Clone()
	Settings.Frame.PlayerName.Text = Player.Name .. "_" .. Player.UserId
	Settings.Frame.CharacterName.Text = Name
	Settings.Frame.RankTimer.Text = RankupText
	Settings.Parent = Player.PlayerGui
	
	local ClientChooseName = Instance.new("RemoteEvent")
	ClientChooseName.Name = "ClientChooseName"
	ClientChooseName.Parent = Player

	ReplicatedStorage.Remotes.ChooseName:FireClient(Player, "Enabled")

	local function FilterName(FilterPlayer, Name)
		local TextService = game:GetService("TextService")
		local UserID = FilterPlayer.UserId
		print(Name, FilterPlayer)
		
		local Blacklist = {
			"Sped", "sped", "Gay", "gay", "Stupid", "stupid", "Dumb", "dumb", "Idiot", "idiot", "Retard", "retard",
			"Nqquher", "nqquher", "Yhwach", "Jugram", "yhwach", "jugram", "Negro", "Bigdick", "ngga" , "negar", "sex",
			"nga", "igger", "niga", "quiger"
		}
		
		local FilteredName
		local Success, Error = pcall(function()
			local Filter = TextService:FilterStringAsync(Name, UserID, Enum.TextFilterContext.PrivateChat)
			FilteredName = Filter:GetNonChatStringForBroadcastAsync()
			FilteredName = FilteredName:sub(1, 8)

			if string.len(FilteredName) < 3 or string.match(FilteredName, "%A+") then
				FilteredName = nil
			end
			
			if FilteredName then
				for i, v in ipairs(Blacklist) do
					if string.lower(FilteredName):match(string.lower(v)) then
						FilteredName = nil
						print("Name blacklist:", v)
					end
				end
			end
		end)
		if not Success then
			warn(Error)
		end
		return FilteredName
	end
	
	local NameCD = 0.1
	local NameDebounce = false
	
	local FinalGender = "Male"
	local FinalName
	local Connection
	Connection = ClientChooseName.OnServerEvent:Connect(function(CurrentPlayer, Name, Gender, Confirmation)
		if NameDebounce then
			return
		end
		
		NameDebounce = true
		task.delay(NameCD, function()
			NameDebounce = false
		end)
		
		if CurrentPlayer == Player and typeof(Name) == "string" then
			if Confirmation == nil then
				local FilteredName = FilterName(CurrentPlayer, Name)
				if FilteredName then
					FinalName = FilteredName
					ReplicatedStorage.Remotes.ChooseName:FireClient(CurrentPlayer, "Confirm", FilteredName)
				else
					ReplicatedStorage.Remotes.ChooseName:FireClient(CurrentPlayer, "Invalid")
				end
				if Gender == "Male" or Gender == "Female" then
					FinalGender = Gender
				end
			elseif Confirmation == true then
				local CurrentProfile = cachedProfiles[CurrentPlayer]
				CurrentProfile.Data.ClientData.Name = FinalName
				CurrentProfile.Data.ClientData.Gender = FinalGender
				
				local SelectedEyes = RandomNumber:RandomInteger(1, 8)
				if CurrentProfile.Data.ClientData.Gender == "Female" then
					SelectedEyes = RandomNumber:RandomInteger(500, 506)
				end
				
				CurrentProfile.Data.ClientData.Eyes = SelectedEyes
				CurrentProfile.MetaData.MetaTags.FirstLoad = true
				CurrentProfile.Data.ServerData.FirstLoad = true
				
				local Name = GetPlayerName(CurrentPlayer)
				
				local Info = {
					Rank = 1,
					Grade = RequestRank(CurrentPlayer),
					Name = Name,
				}

				ReplicatedStorage.Remotes.ChooseName:FireClient(CurrentPlayer, "Disabled")
				
				ClientChooseName:Destroy()
				CurrentPlayer.PlayerGui.NameSelectionUI:Destroy()
				
				local EffectsFolder = Instance.new("Folder")
				EffectsFolder.Name = CurrentPlayer.Name
				EffectsFolder.Parent = workspace.Effects

				local LiveAssetsFolder = Instance.new("Folder")
				LiveAssetsFolder.Name = CurrentPlayer.Name
				LiveAssetsFolder.Parent = ServerStorage.LiveAssets
				
				PassivesManager:CreatePassiveData(CurrentPlayer)
				
				local StateModule = CurrentProfile.Data.ClientData.StateModule
				EntityManager:CreateEntity(CurrentPlayer.Name, StateModule, CurrentPlayer)
				
				SetupUIs(CurrentPlayer)
				
				Connection:Disconnect()
				Connection = nil
			end
		end
	end)
end

local function SpiritualPressure(Player)
	local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
	local PathData = {Module = ClientSkills, Skill = "SpiritualPressureMini"}
	local RenderDistance = -1
	NetworkManager.FireAllClients(Player.Character, "ClientEffects", RenderDistance, PathData)
end

local function RemoveTitles(Player, Title, Squad, SternritterKey)
	local Titles = {
		Captains = true;
		Lieutenants = true;
		ThirdSeats = true;
		Espadas = true;
		Fraccion = true;
		Sternritters = true;
		Jagdarmee = true;
	}

	if Titles[Title] then
		local AllowedDivision
		if Title == "Sternritters" or Title == "Jagdarmee" then
			AllowedDivision = true
		elseif Title == "Captains" or Title == "Lieutenants" or Title == "ThirdSeats" then
			if Squad and tonumber(Squad) >= 0 and tonumber(Squad) <= 13 then
				AllowedDivision = true
			end
		elseif Title == "Espadas" or Title == "Fraccion" then
			if Squad and tonumber(Squad) >= 0 and tonumber(Squad) <= 10 then
				AllowedDivision = true
			end
		end

		if AllowedDivision then
			local PlayerID = Player.UserId
			local PlayerName = Player.Name

			local Removed

			local Success, Error = pcall(function()
				TitleDataStore:UpdateAsync(TitleKey, function(oldValue)
					local Data = oldValue

					local CurrentTitles = Data[Title]
					if Title == "Sternritters" then
						CurrentTitles[SternritterKey] = nil

						Removed = true

						print("[Divisions]: Sternritter " .. PlayerName .. " removed")
					elseif Title == "Fraccion" then
						local SquadKey = Squad
						if Squad == 0 then
							SquadKey = 11
						end

						local Fraccion = table.find(CurrentTitles[SquadKey], PlayerID)
						if Fraccion then
							table.remove(CurrentTitles[SquadKey], Fraccion)

							Removed = true

							print("[Divisions]: Fraccion " .. PlayerName .. " removed from Espada " .. SquadKey)
						end
					elseif Title == "Jagdarmee" and Data.Sternritters[SternritterKey] then
						local Jagdarmee = table.find(Data.Sternritters[SternritterKey], PlayerID)
						if Jagdarmee then
							table.remove(Data.Sternritters[SternritterKey], Jagdarmee)

							Removed = true

							print("[Divisions]: Jagdarmee " .. PlayerName .. " removed from Sternritter " .. SternritterKey)
						end
					else
						local SquadKey = Squad
						if Title == "Captains" then
							if Squad == 0 then
								SquadKey = 14
							end

							if CurrentTitles[SquadKey] == Player.UserId then
								CurrentTitles[SquadKey] = "Empty"
								Data.Lieutenants[SquadKey] = "Empty"
								Data.ThirdSeats[SquadKey] = "Empty"

								Removed = true
							end
						elseif Title == "Espadas" then
							if Squad == 0 then
								SquadKey = 11
							end

							if CurrentTitles[SquadKey] == Player.UserId then
								CurrentTitles[SquadKey] = "Empty"
								Data.Fraccion[SquadKey] = {}

								Removed = true
							end
						else
							if CurrentTitles[SquadKey] == Player.UserId then
								CurrentTitles[SquadKey] = "Empty"
								Removed = true

							end
						end

						if Removed then
							
							print("[Divisions]: " .. Player.Name .. " removed from " .. Title .. " " .. SquadKey)
						end
					end

					return Data
				end)
			end)
		end
	end
end

local function WipeData(Player, Message)
	local Profile = cachedProfiles[Player]
	local CurrentTitle = Profile.Data.ClientData.Title
	local DivisionCaptain = Profile.Data.Division.Captain
	local Division = Profile.Data.Division.Squad
	local QuincyMedallionID
	if Profile.Data.ClientData.QuincyMedallion then
		--QuincyMedallionID = cachedProfiles[Player].Data.ClientData.QuincyMedallion
	elseif Profile.Data.ClientData.StolenBankai then
		QuincyMedallionID = Player.UserId
	end

	Profile.MetaData.MetaTags.FirstLoad = nil

	Profile.Data.ClientData = DeepCopyTable(ProfileTemplate.ClientData)
	Profile.Data.Division = DeepCopyTable(ProfileTemplate.Division)
	Profile.Data.Settings = DeepCopyTable(ProfileTemplate.Settings)
	Profile.Data.ItemInventory = DeepCopyTable(ProfileTemplate.ItemInventory)
	Profile.Data.Accessories = DeepCopyTable(ProfileTemplate.Accessories)
	Profile.Data.AccessoriesVanity = DeepCopyTable(ProfileTemplate.AccessoriesVanity)
	Profile.Data.UnlockedSkills = DeepCopyTable(ProfileTemplate.UnlockedSkills)
	Profile.Data.Inventory = DeepCopyTable(ProfileTemplate.Inventory)
	Profile.Data.ServerData = DeepCopyTable(ProfileTemplate.ServerData)

	local KickMessage = "Your data has been wiped."
	if Message then
		KickMessage = Message
	end
	
	Profile:Release()
	Player:Kick(KickMessage)

	if table.find(PositionTitles.QuincyRankings, CurrentTitle) or table.find(PositionTitles.SoulReaperRankings, CurrentTitle) or table.find(PositionTitles.HollowRankings, CurrentTitle) then
		task.spawn(function()
			if table.find(PositionTitles.SternritterTitles, CurrentTitle) then
				RemoveTitles(Player, "Sternritters", nil, "Player_" .. Player.UserId)
			elseif table.find(PositionTitles.ShinigamiCaptainTitles, CurrentTitle) then
				RemoveTitles(Player, "Captains", Division)
			elseif table.find(PositionTitles.ArrancarEspadaTitles, CurrentTitle) then
				RemoveTitles(Player, "Espadas", Division)
			elseif table.find(PositionTitles.LieutenantUI, CurrentTitle) then
				RemoveTitles(Player, "Lieutenants", Division)
			elseif table.find(PositionTitles.ThirdSeatTitles, CurrentTitle) then
				RemoveTitles(Player, "ThirdSeats", Division)
			elseif CurrentTitle == "Fracción" then
				RemoveTitles(Player, "Fraccion", Division)
			elseif CurrentTitle == "Jagdarmee" then
				RemoveTitles(Player, "Jagdarmee", nil, DivisionCaptain)
			end
		end)
	end

	if QuincyMedallionID then
		task.spawn(function()
			QuincyMedallions:ResetQuincy(tostring(QuincyMedallionID))
		end)
	end
end

local DataManager = {}

local function EntitiesFolderLoaded(Player)
	local Profile = cachedProfiles[Player]	
	local MetaData = Profile.MetaData
	local FirstLoad = MetaData.MetaTags.FirstLoad
	if FirstLoad == nil then
		--MetaData.MetaTags.FirstLoad = true
		--Profile.Data.ServerData.FirstLoad = true
		createInitialData(Profile, Player)
		ChooseName(Player)
		--print("First Load")
		return
	end	
	--print("Normal Load")
	
	local WipeCheck
	if Profile.Data.ClientData.WipeTag == true then
		WipeCheck = true
		
		WipeData(Player, "You have been wiped from an execution.")
		
		local WebhookInfo = {
			Message = Player.Name .. " wiped by logging.";
		}
		

		Webhooks:Post(WebhookChannel, WebhookInfo)
		return
	end
	
	local function AddSkill(Player, SkillName)
		local UnlockedSkills = Profile.Data.UnlockedSkills
		if not table.find(UnlockedSkills, SkillName) and ServerSkillReqs[SkillName] then
			table.insert(UnlockedSkills, SkillName)
			return true
		end
	end
	local function RemoveSkill(Player, SkillName)
		local UnlockedSkills = Profile.Data.UnlockedSkills
		local Inventory = Profile.Data.Inventory
		
		if table.find(UnlockedSkills, SkillName) then
			table.remove(UnlockedSkills, table.find(UnlockedSkills, SkillName))

			local AlreadyEquipped
			for i, v in pairs(Inventory) do
				if v == SkillName then
					AlreadyEquipped = i
				end
			end

			if AlreadyEquipped then
				Inventory[AlreadyEquipped] = "Empty"
			end
			
			return true
		end
	end
	local function RemoveItem(Player, ItemName)
		local ItemInventory = Profile.Data.ItemInventory
		local Inventory = Profile.Data.Inventory
		local ValidItem = TradeablesData[ItemName]
		if ValidItem and ItemInventory[ItemName] then
			ItemInventory[ItemName] = nil

			local ItemType = ValidItem.ItemType
			if ItemType ~= "Skill" then
				for AccessoryType, AccessoryName in pairs(Profile.Data.Accessories) do
					if AccessoryName == ItemName then
						Profile.Data.Accessories[AccessoryType] = "Empty"
					end
				end
			end

			local AlreadyEquipped
			for i, v in pairs(Inventory) do
				if v == ItemName then
					AlreadyEquipped = i
				end
			end

			if AlreadyEquipped then
				Inventory[AlreadyEquipped] = "Empty"
			end
			
			return true
		end
	end
	
	local function UnequipAccessory(Player, AccessoryName)
		local Accessories = Profile.Data.Accessories
		local AlreadyEquipped
		for i, v in pairs(Accessories) do
			if v == AccessoryName then
				AlreadyEquipped = i
			end
		end

		if AlreadyEquipped then
			Accessories[AlreadyEquipped] = "Empty"
			return true
		end
	end
	
	local function AddItem(Player, ItemName, Amount)
		local ItemInventory = Profile.Data.ItemInventory
		local ValidItem = TradeablesData[ItemName]
		if ValidItem then
			if not ItemInventory[ItemName] then
				ItemInventory[ItemName] = 0
			end
			ItemInventory[ItemName] += Amount

			local ItemType = ValidItem.ItemType
			if ItemType == "Skill" then
				AddSkill(ItemName)
			end
		end
	end
	
	local function AdjustSP(Player, Stat, Amount)
		local SPTable = {
			"Hakuda",
			"Kendo",
			"Kido",
			"Healing",
			"Speed",
			"SP",
		}

		if table.find(SPTable, Stat) and tonumber(Amount) then
			local StatSP = Profile.Data.ClientData[Stat]
			StatSP += Amount
			Profile.Data.ClientData[Stat] = StatSP
		end
	end
	
	local function ResetBuild(Player, KeepSkillbox)
		local UnlockedSkills = Profile.Data.UnlockedSkills
		local Inventory = Profile.Data.Inventory

		local SPValues = StatData.SPValues

		local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
		local SP = 0
		for i = 18, 1, -1 do
			SP += SPValues[i]
			local RankSP = SPValues[i]
			if i <= ShinigamiRank then
				break
			end
		end

		local SkillboxSkills = {}
		for i, v in ipairs(UnlockedSkills) do
			if ServerSkillReqs[v].StatReq1 and ServerSkillReqs[v].StatReq1.Category == "Special" then
				table.insert(SkillboxSkills, v)
			end

			if KeepSkillbox and ServerSkillReqs[v].SkillBox then
				AddItem(Player, "Skill Box", 1)
			end
		end

		Profile.Data.UnlockedSkills = SkillboxSkills
		Profile.Data.ClientData.SP = SP
		Profile.Data.ClientData.Kendo = 0
		Profile.Data.ClientData.Kido = 0
		Profile.Data.ClientData.Speed = 0
		Profile.Data.ClientData.Hakuda = 0
		Profile.Data.ClientData.Healing = 0

		local AlreadyEquipped
		for i, v in pairs(Inventory) do
			Inventory[i] = "Empty"
		end

		if Profile.Data.ClientData.ZanpakutoWeapon == "Fist" or Profile.Data.ClientData.ZanpakutoWeapon == "Grimmjow" or Profile.Data.ClientData.ZanpakutoWeapon == "Cang" then
			local LastZanpakutoWeapon = Profile.Data.ClientData.LastZanpakutoWeapon
			if not LastZanpakutoWeapon then
				if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
					Profile.Data.ClientData.LastZanpakutoWeapon = "Schwert"
					LastZanpakutoWeapon = "Schwert"
				else
					Profile.Data.ClientData.LastZanpakutoWeapon = "Katana"
					LastZanpakutoWeapon = "Katana"
				end
			end
			Profile.Data.ClientData.ZanpakutoWeapon = LastZanpakutoWeapon

			if Profile.Data.ClientData.WeaponType == "Gauntlet" then
				local function SetupArray(Object)
					local Array = {}
					for i, v in pairs(Object:GetChildren()) do
						if not v:GetAttribute("Whitelist") then
							table.insert(Array, v.Name)
						end
					end
					table.sort(Array)
					return Array
				end

				local WeaponTypes = {"Dualblade", "Greatsword", "Katana", "Scythe", "Spear", "Twinblade", "Hammer"}
				local SelectedType = WeaponTypes[RandomNumber:RandomInteger(1, #WeaponTypes)]

				local WeaponModels = SetupArray(ServerStorage.Assets.Weapons[SelectedType])	

				if Profile.Data.ClientData.OldWeaponType then
					Profile.Data.ClientData.WeaponType = Profile.Data.ClientData.OldWeaponType
				else
					Profile.Data.ClientData.WeaponType = SelectedType
				end
				if Profile.Data.ClientData.OldWeaponModel then
					Profile.Data.ClientData.WeaponModel = Profile.Data.ClientData.OldWeaponModel
				else
					Profile.Data.ClientData.WeaponModel = WeaponModels[RandomNumber:RandomInteger(1, #WeaponModels)]
				end
			end
		end

		if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
			--AddSkill(Player, "Senkaimon")
			if Profile.Data.ClientData.Race == "Visored" then
				AddSkill(Player, "Visored Cero")
			end
		elseif StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
			AddSkill(Player, "Garganta")
			if Profile.Data.ClientData.Race == "Vastocar" then
				AddSkill(Player, "Cero Oscuras")
				AddSkill(Player, "Instinct")
			elseif Profile.Data.ClientData.Race == "Arrancar" then
				AddSkill(Player, "Cero")
			end
		elseif StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
			AddSkill(Player, "The Key")
			AddSkill(Player, "Blut Vene")
		end

		if table.find(PositionTitles.ShinigamiCaptainTitles, Profile.Data.ClientData.Title) or table.find(PositionTitles.LieutenantUI, Profile.Data.ClientData.Title) then
			AddSkill(Player, "Command")
		elseif table.find(PositionTitles.ArrancarEspadaTitles, Profile.Data.ClientData.Title) then
			AddSkill(Player, "Espada Command")
			AddSkill(Player, "Garganta Break")
		elseif Profile.Data.ClientData.Title == "Fracción" and Profile.Data.Division.Squad >= 1 and Profile.Data.Division.Squad <= 4 then
			AddSkill(Player, "Garganta Break")
		elseif table.find(PositionTitles.SternritterTitles, Profile.Data.ClientData.Title) then
			AddSkill(Player, "Blut Vene 3")
			AddSkill(Player, "Sternritter Command")
		elseif Profile.Data.ClientData.Title == "Jagdarmee" then
			AddSkill(Player, "Blut Vene 2")
		end
	end
	
	if not Profile.Data.ClientData.RemoveButterfly then
		Profile.Data.ClientData.RemoveButterfly = true
		RemoveItem(Player, "Soul Butterfly")
	end
	if not Profile.Data.ClientData.Kills then
		Profile.Data.ClientData.Kills = 0
	end
	if not Profile.Data.ClientData.Deaths then
		Profile.Data.ClientData.Deaths = 0
	end
	
	Profile.Data.ClientData.FraccReset = nil
	Profile.Data.ClientData.CeroUpdate = nil
	Profile.Data.ClientData.ResetLT = nil
	Profile.Data.ClientData.ThirdSeat = nil
	Profile.Data.Division.Lieutenants = nil
	Profile.Data.Division.ThirdSeats = nil
	Profile.Data.ClientData.MimicReset = nil
	Profile.Data.ClientData.EloReset = nil
	Profile.Data.ClientData.HeavenReset = nil
	Profile.Data.ClientData.VastoList = nil
	Profile.Data.ClientData.VastoRoll = nil
	Profile.Data.ClientData.EtherealRework = nil
	Profile.Data.ClientData.SplitGateSP = nil
	Profile.Data.ClientData.SkillAssess = nil
	Profile.Data.ClientData.RemovePuffer = nil
	Profile.Data.ClientData.RemoveBluePill = nil
	Profile.Data.ClientData.RestoreReiatsu = nil
	Profile.Data.ClientData.ArrancarSPR2 = nil
	Profile.Data.ClientData.VastoRoll1 = nil
	Profile.Data.ClientData.ReiPushRemove = nil
	Profile.Data.ClientData.CeroInfuseRemove = nil
	Profile.Data.ClientData.ShortCloakChange = nil
	Profile.Data.ClientData.ResetMedics = nil
	Profile.Data.ClientData.ResetMedics1 = nil
	Profile.Data.ClientData.MirrorUpdate = nil
	Profile.Data.ClientData.FloatingUpdate = nil
	
	if Profile.Data.ClientData.Clan == "Shutara" then
		local Quantity = DataManager:CheckItemQuantity(Player, "Shutara Necklace")
		if not Quantity then
			AddItem(Player, "Shutara Necklace", 1)
		end
	end
	
	if not Profile.Data.ClientData.DataVersion then
		Profile.Data.ClientData.DataVersion = 1
	end
	
	if Profile.Data.ClientData.DataVersion == 1 then
		Profile.Data.ClientData.DataVersion = 2

		Profile.Data.ClientData.Elo = 0
		Profile.Data.ClientData.GlobalRank = -1
	end
	if Profile.Data.ClientData.DataVersion == 2 then
		Profile.Data.ClientData.DataVersion = 3
		
		local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
		Profile.Data.ClientData.MaxHealth = StatData.PlayerStats[ShinigamiRank].Health
		Profile.Data.ClientData.MaxReiatsu = StatData.PlayerStats[ShinigamiRank].Reiatsu
	end
	if Profile.Data.ClientData.DataVersion == 3 then
		Profile.Data.ClientData.DataVersion = 4

		Profile.Data.ServerData.Strikes = 0
	end
	if Profile.Data.ClientData.DataVersion == 4 then
		Profile.Data.ClientData.DataVersion = 5

		Profile.Data.ServerData.Strikes = 0
	end
	if Profile.Data.ClientData.DataVersion == 5 then
		Profile.Data.ClientData.DataVersion = 6

		Profile.Data.ServerData.Strikes = 0
	end
	if Profile.Data.ClientData.DataVersion == 6 then
		Profile.Data.ClientData.DataVersion = 7

		Profile.Data.ServerData.Strikes = 0
	end
	if Profile.Data.ClientData.DataVersion == 7 then
		Profile.Data.ClientData.DataVersion = 8

		if Profile.Data.ClientData.Race == "Vastocar" and table.find(Profile.Data.UnlockedSkills, "Hakuda Style") then
			if Profile.Data.ClientData.ZanpakutoWeapon ~= "Grimmjow" then
				Profile.Data.ClientData.ZanpakutoWeapon = "Grimmjow"
			end
		end
	end
	if Profile.Data.ClientData.DataVersion == 8 then
		Profile.Data.ClientData.DataVersion = 9

		Profile.Data.ClientData.Elo = 0
		Profile.Data.ClientData.GlobalRank = -1
	end
	if Profile.Data.ClientData.DataVersion == 9 then
		Profile.Data.ClientData.DataVersion = 10
		
		if StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
			local PartialRes = {"Z", "X", "C"}
			
			local PartialRes1 = table.find(PartialRes, Profile.Data.ClientData.PartialRes)
			table.remove(PartialRes, PartialRes1)
			
			local SelectedPartialRes = PartialRes[RandomNumber:RandomInteger(1, #PartialRes)]
			Profile.Data.ClientData.PartialRes2 = SelectedPartialRes
		end
	end
	
	if Profile.Data.ClientData.Clan == "Ichimaru" then
		if Profile.Data.ClientData.Eyes ~= 1 then
			Profile.Data.ClientData.Eyes = 1
		end
		if Profile.Data.ClientData.Marking ~= 1 or Profile.Data.ClientData.Mouth ~= 102 then
			Profile.Data.ClientData.Marking = 1
		end
		if Profile.Data.ClientData.Mouth < 1 or Profile.Data.ClientData.Mouth > 2 then
			Profile.Data.ClientData.Mouth = 1
		end
	elseif Profile.Data.ClientData.Clan == "Hisgai" then
		if Profile.Data.ClientData.Marking ~= 1 or Profile.Data.ClientData.Mouth ~= 102 or Profile.Data.ClientData.Mouth ~= 0 then
			Profile.Data.ClientData.Marking = 1
		end
	elseif Profile.Data.ClientData.Clan == "Custom" then
		if Profile.Data.ClientData.Eyes ~= 1 then
			Profile.Data.ClientData.Eyes = 1
		end
		if Profile.Data.ClientData.Eyebrow ~= 1 then
			Profile.Data.ClientData.Eyebrow = 1
		end
		if Profile.Data.ClientData.Marking ~= 1 or Profile.Data.ClientData.Mouth ~= 102 or Profile.Data.ClientData.Marking ~= 0 then
			Profile.Data.ClientData.Marking = 1
		end
		if Profile.Data.ClientData.Mouth ~= 1 then
			Profile.Data.ClientData.Mouth = 1
		end
	elseif Profile.Data.ClientData.Clan == "Kira" then
		if Profile.Data.ClientData.Eyes ~= 1 then
			Profile.Data.ClientData.Eyes = 1
		end
		if Profile.Data.ClientData.Marking ~= 1 or Profile.Data.ClientData.Mouth ~= 102 then
			Profile.Data.ClientData.Marking = 1
		end
	end
	
	if not Profile.Data.ClientData.Shikai then
		if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
			local StoredShikais = StatData.ShikaiPool
			
			local SelectedNumber = RandomNumber:RandomInteger(1, 100)
			if SelectedNumber <= 1 then
				StoredShikais = StatData.LegendaryShikaiPool
			elseif SelectedNumber > 1 and SelectedNumber <= 11 then
				StoredShikais = StatData.RareShikaiPool
			end
			table.sort(StoredShikais)

			local SelectedShikai = StoredShikais[RandomNumber:RandomInteger(1, #StoredShikais)]
			--SelectedShikai = "Creation"
			Profile.Data.ClientData.Shikai = SelectedShikai	
		elseif StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
			local StoredRes = StatData.ResPool
			if RandomNumber:RandomInteger(1, 100) <= 1 then
				StoredRes = StatData.LegendaryResPool
			end
			table.sort(StoredRes)

			local SelectedRes = StoredRes[RandomNumber:RandomInteger(1, #StoredRes)]
			Profile.Data.ClientData.Shikai = SelectedRes
		elseif StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
			local StoredVollstandig = StatData.VollstandigPool

			if RandomNumber:RandomInteger(1, 100) <= 1 then
				StoredVollstandig = StatData.LegendaryVollstandigPool
			end
			table.sort(StoredVollstandig)

			local SelectedVollstandig = StoredVollstandig[RandomNumber:RandomInteger(1, #StoredVollstandig)]
			Profile.Data.ClientData.Shikai = SelectedVollstandig
		end
	end
	
	if Profile.Data.ClientData.Race == "Shinigami" and Profile.Data.ClientData.HairColor == nil then
		DataManager.createRaceData(Player, "Shinigami")
	end
	
	--[[if not Profile.Data.ClientData.PublicRelease then
		local ReleaseDate = DateTime.fromUniversalTime(2023, 7, 11, 21, 0, 0, 0)
		
		if ReleaseDate.UnixTimestamp - DateTime.now().UnixTimestamp > 0 then
			local NotAllowed
			
			local Success, Error = pcall(function()
				local GroupID = 32740991
				local RankInGroup = Player:GetRankInGroup(GroupID)
				if RankInGroup < 2 then
					NotAllowed = true
				end
			end)
			--print(Player.Name, "cc ban:", NotAllowed)
			if NotAllowed then
				Player:Kick("Suspended until 7/11/2023 9:00PM UTC")
				return
			end
		end
	end]]
	
	if not Profile.Data.ClientData.ShutaraUpdate then
		Profile.Data.ClientData.ShutaraUpdate = true
		if Profile.Data.ClientData.Clan == "Shutara" then
			AddItem(Player, "Shutara Necklace", 1)
		end
	end
	
	if not Profile.Data.ClientData.NewVoltUpdate then
		Profile.Data.ClientData.NewVoltUpdate = true
		
		if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" and not Profile.Data.ClientData.BankaiUnlocked and not table.find(StatData.LegendaryVollstandigPool, Profile.Data.ClientData.Shikai) then
			local StoredVollstandig = StatData.VollstandigPool
			table.sort(StoredVollstandig)

			local SelectedVollstandig = StoredVollstandig[RandomNumber:RandomInteger(1, #StoredVollstandig)]
			Profile.Data.ClientData.Shikai = SelectedVollstandig

			local QuincyZanpakutoNames = ZanpakutoNames.Quincy[SelectedVollstandig]
			local RandomZanpakutoName = QuincyZanpakutoNames[RandomNumber:RandomInteger(1, #QuincyZanpakutoNames)]
			Profile.Data.ClientData.ZanpakutoName = RandomZanpakutoName
			Profile.Data.ClientData.ReleasePhrase = "Quincy: Voll Stern Dich"
		end
	end
	if not Profile.Data.ClientData.VollstandigUpdate then
		Profile.Data.ClientData.VollstandigUpdate = true
		
		if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" and not Profile.Data.ClientData.BankaiUnlocked then
			local StoredVollstandig = StatData.VollstandigPool

			if RandomNumber:RandomInteger(1, 100) <= 1 then
				StoredVollstandig = StatData.LegendaryVollstandigPool
			end
			table.sort(StoredVollstandig)

			local SelectedVollstandig = StoredVollstandig[RandomNumber:RandomInteger(1, #StoredVollstandig)]
			Profile.Data.ClientData.Shikai = SelectedVollstandig
		end	
	end
	
	if not Profile.Data.ClientData.FloatingUpdate2 then
		Profile.Data.ClientData.FloatingUpdate2 = true

		RemoveSkill(Player, "Mirror Tempo")
		RemoveSkill(Player, "Floating Strikes")
	end

	if not Profile.Data.ClientData.KanReset then
		Profile.Data.ClientData.KanReset = true

		local Resets = {
			2804385491; -- DisArtillery
			67952654; -- ArcSouls
			1494446782; -- Lobster_Blade
			69618699; -- evigandtake
			44021393; -- janj_n
			89287787; -- brushthemout
			139027675; -- snoweox
			23242593; -- shockerftww
			59316795; -- AccelPoint
			264674514; -- KaichiTheGreat
			1101088949; -- Inner_Darkness
			1101088949; -- yeetesium
			432360403; -- sinfuldms
			472562543; -- ChrisKaiju
			791006518; -- shinIight
			3954269526; -- passalinetrey
			388306396; -- Yasir3520
			30370774; -- Rakutsu
		}
		
		if table.find(Resets, Player.UserId) then
			local Kan = Profile.Data.ClientData.Kan
			local ItemInventory = Profile.Data.ItemInventory
			local Inventory = Profile.Data.Inventory
			
			Profile.Data.ClientData.Kan = 0
			
			for ItemName, ItemQuantity in pairs(ItemInventory) do
				local ValidItem = TradeablesData[ItemName]
				if ValidItem and ValidItem.Rarity ~= "Unobtainable" then
					ItemInventory[ItemName] = nil
				end
			end
			for AccessoryType, AccessoryName in pairs(Profile.Data.Accessories) do
				Profile.Data.Accessories[AccessoryType] = "Empty"
			end
			for i, v in pairs(Inventory) do
				Inventory[i] = "Empty"
			end
			
			local WebhookInfo = {
				Message = Player.Name .. "'s inventory reset. Past Kan: " .. Kan;
			}

			Webhooks:Post("Admin Panel", WebhookInfo)
		end
	end
	
	local log = {}
	if Profile.Data.ItemInventory["Hogyoku Fragment"] and Profile.Data.ItemInventory["Hogyoku Fragment"] >= 3 then
		table.insert(log, Player.Name .. "'s Hogyoku Fragments: " .. Profile.Data.ItemInventory["Hogyoku Fragment"])
	end
	if Profile.Data.ItemInventory["Skill Box"] and Profile.Data.ItemInventory["Skill Box"] >= 3 then
		table.insert(log, Player.Name .. "'s Skill Boxes: " .. Profile.Data.ItemInventory["Skill Box"])
	end
	if #log > 0 then
		local WebhookInfo = {
			Message = table.concat(log, "\n");
		}

		Webhooks:Post("Tracker", WebhookInfo)
	end
	
	if not Profile.Data.ClientData.FengUpdate then
		Profile.Data.ClientData.FengUpdate = true
		
		if Profile.Data.ClientData.Clan == "Feng" then
			Profile.Data.ClientData.Clan = "Shutara"
		end
	end
	
	if not Profile.Data.ClientData.RestoreQuincy then
		Profile.Data.ClientData.RestoreQuincy = true
		
		if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
			if not Profile.Data.ItemInventory["Quincy Cross"] then
				AddItem(Player, "Quincy Cross", 1)
			end
		end
	end
	
	if not Profile.Data.ClientData.SpeedReset then
		Profile.Data.ClientData.SpeedReset = true
		
		RemoveSkill(Player, "Flashstep Mastery 1")
		RemoveSkill(Player, "Flashstep Mastery 2")
		RemoveSkill(Player, "Perfect Flashstep")
		RemoveSkill(Player, "Flash Tension")
		RemoveSkill(Player, "Flash Cut")
		RemoveSkill(Player, "Phantom Trick")
		RemoveSkill(Player, "Flash Fakeout")
		RemoveSkill(Player, "Blooming Cut")
		RemoveSkill(Player, "Shunko")
		RemoveSkill(Player, "Enhanced Steps")
		RemoveSkill(Player, "Mirror Tempo")
		RemoveSkill(Player, "Dropping Fang")
		RemoveSkill(Player, "Waterfall Dance")
		RemoveSkill(Player, "Sonido Break")
		RemoveSkill(Player, "Specter Step")
	end
	
	if not Profile.Data.ClientData.KidoSPUpdate then
		Profile.Data.ClientData.KidoSPUpdate = true
		
		UnequipAccessory(Player, "Short Cloak")
		
		RemoveSkill(Player, "Shakkaho")
		RemoveSkill(Player, "Tenran")
		RemoveSkill(Player, "Hainawa")
		RemoveSkill(Player, "Zangerin")
		RemoveSkill(Player, "Geki")
		RemoveSkill(Player, "Gaki Rekko")
		RemoveSkill(Player, "Tsuzuri Raiden")
		RemoveSkill(Player, "Raikoho")
		RemoveSkill(Player, "Weaker Itto Kaso")
		RemoveSkill(Player, "Sokatsui")
		
		local Flashstep = RemoveSkill(Player, "Flashstep")
		if Flashstep then
			AddSkill(Player, "Flashstep")
			AdjustSP(Player, "Speed", -1)
			AdjustSP(Player, "SP", 1)
		end
	end
	
	if not Profile.Data.ClientData.PartialResUpdate then
		Profile.Data.ClientData.PartialResUpdate = true
		
		if StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
			if not Profile.Data.ClientData.BankaiUnlocked then
				local StoredRes = StatData.ResPool
				if RandomNumber:RandomInteger(1, 100) <= 1 then
					StoredRes = StatData.LegendaryResPool
				end
				table.sort(StoredRes)

				local SelectedRes = StoredRes[RandomNumber:RandomInteger(1, #StoredRes)]
				Profile.Data.ClientData.Shikai = SelectedRes
			end
			
			local PartialRes = {"Z", "X", "C"}
			local SelectedPartialRes = PartialRes[RandomNumber:RandomInteger(1, #PartialRes)]
			Profile.Data.ClientData.PartialRes = SelectedPartialRes
		end
	end
	
	if not Profile.Data.ClientData.TitleRework then
		Profile.Data.ClientData.TitleRework = true
		
		local CurrentTitle = Profile.Data.ClientData.Title
		if table.find(PositionTitles.QuincyRankings, CurrentTitle) or table.find(PositionTitles.SoulReaperRankings, CurrentTitle) or table.find(PositionTitles.HollowRankings, CurrentTitle) then
			Profile.Data.Division.Squad = -1
			Profile.Data.Division.Rank = 4
			Profile.Data.Division.Captain = false
			Profile.Data.ClientData.Title = ""
			
			RemoveSkill(Player, "Sternritter Command")
			RemoveSkill(Player, "Blut Vene 2")
			RemoveSkill(Player, "Blut Vene 3")
			RemoveSkill(Player, "Command")
			RemoveSkill(Player, "Espada Command")
			RemoveSkill(Player, "Garganta Break")
			RemoveItem(Player, "Sternritter Cloak", 1)
			RemoveItem(Player, "Hooded Sternritter Cloak", 1)
			RemoveItem(Player, "Captain Cloak", 1)
			RemoveItem(Player, "Captain Cloak Armless", 1)
			RemoveItem(Player, "Lt. Band", 1)
		end
	end
	
	if not Profile.Data.ClientData.SPUpdate then
		Profile.Data.ClientData.SPUpdate = true
		RemoveSkill(Player, "Delayed Crossings")
		RemoveSkill(Player, "Rising Swallow")
		
		local UnlockedSkills = Profile.Data.UnlockedSkills
		local Inventory = Profile.Data.Inventory

		local SkillboxSkills = {}
		for i, v in ipairs(UnlockedSkills) do
			if ServerSkillReqs[v].StatReq1 then
				local Category = ServerSkillReqs[v].StatReq1.Category
				
				if ServerSkillReqs[v].SkillBox and Profile.Data.ClientData[Category] < 25 then
					table.insert(SkillboxSkills, v)
				end
			end
		end
		
		for i, v in ipairs(SkillboxSkills) do
			RemoveSkill(Player, v)
			AddItem(Player, "Skill Box", 1)
		end
	end
	
	if not Profile.Data.ClientData.CustomReset then
		Profile.Data.ClientData.CustomReset = true
		if Profile.Data.ClientData.Clothes == 0 then
			Profile.Data.ClientData.Clothes = 1
		end
		
		RemoveItem(Player, "Halo Left Arm")
		RemoveItem(Player, "Halo Right Arm")
		RemoveItem(Player, "Data's Crown")
	end
	if not Profile.Data.ClientData.NewEyes then
		Profile.Data.ClientData.NewEyes = true
		if Profile.Data.ClientData.Eyes == 8 then
			Profile.Data.ClientData.Eyes = 502
		end
		if Profile.Data.ClientData.Eyes == 9 then
			Profile.Data.ClientData.Eyes = 8
		end
	end
	
	if not Profile.Data.ClientData.BankaiTimer then
		Profile.Data.ClientData.BankaiTimer = 0
	end
	
	if not Profile.Data.ClientData.ReiPushUpdate then
		Profile.Data.ClientData.ReiPushUpdate = true
		RemoveSkill(Player, "Reiatsu Push")
	end
	
	RemoveSkill(Player, "Zombie Recall")
	RemoveSkill(Player, "Brickbreaker")

	if not Profile.Data.ClientData.HierroRework then
		Profile.Data.ClientData.HierroRework = true
		local Hierro1 = RemoveSkill(Player, "Hierro Mastery")
		local Hierro2 = RemoveSkill(Player, "Hierro Mastery 2")
		if Hierro1 or Hierro2 then
			ResetBuild(Player, "KeepSkillbox")
		end
	end
	
	if not Profile.Data.ClientData.LastPlayerGripped then
		Profile.Data.ClientData.LastPlayerGripped = false
	end
	if not Profile.Data.AccessoriesVanity then
		Profile.Data.AccessoriesVanity = {
			Head = "On";
			Face = "On";
			Neck = "On";
			Shoulder = "On";
			Arm = "On";
			Torso = "On";
			Back = "On";
			Waist = "On";
			Leg = "On";
		};
	end
	
	if not Profile.Data.ClientData.BankaiRequirements then
		Profile.Data.ClientData.BankaiRequirements = {
			BankaiReady = false;
			BankaiFight = false;
			BankaiSwordTimer = 0;
			RankDuration = 0;
			Hollows = 0;
			Players = 0;
			WorldBosses = 0;
		}
	end
	if not Profile.Data.ClientData.BankaiWeaponModel then
		local function SetupArray(Object)
			local Array = {}
			for i, v in pairs(Object:GetChildren()) do
				if not v:GetAttribute("Whitelist") then
					table.insert(Array, v.Name)
				end
			end
			table.sort(Array)
			return Array
		end
		
		local BankaiWeaponModels = SetupArray(ServerStorage.Assets.BankaiWeapons[Profile.Data.ClientData.WeaponType])
		Profile.Data.ClientData.BankaiWeaponModel = BankaiWeaponModels[RandomNumber:RandomInteger(1, #BankaiWeaponModels)]
	end
	
	local function RemoveVastocar()
		local UnlockedSkills = Profile.Data.UnlockedSkills
		local Inventory = Profile.Data.Inventory

		RemoveSkill(Player, "Tri Cero")
		RemoveSkill(Player, "Cero Cornea")
		RemoveSkill(Player, "Blade Cero")
		RemoveSkill(Player, "Cero Grab")
		RemoveSkill(Player, "Finger Cero")
		RemoveSkill(Player, "Finger Cero")
		RemoveSkill(Player, "Cero Oscuras")
		RemoveSkill(Player, "Instinct")
		AddSkill(Player, "Cero")

		Profile.Data.ClientData.Race = "Arrancar"
		Profile.Data.ClientData.VastocarRoll = nil
	end
	
	if Profile.Data.ClientData.VastocarSeal then
		Profile.Data.ClientData.VastocarSeal = nil
		RemoveVastocar()
	end
	
	if Profile.Data.ClientData.VastoWipeTag then
		Profile.Data.ClientData.VastoWipeTag = nil
		Profile.Data.ClientData.VastoFailed = true
		Profile.Data.ClientData.ShinigamiRank = 17
		Profile.Data.ClientData.MaxHealth = StatData.PlayerStats[17].Health
		Profile.Data.ClientData.MaxReiatsu = StatData.PlayerStats[17].Reiatsu
		Profile.Data.ClientData.EXP = 0
	end
	
	if not WipeCheck then
		if Profile.Data.ClientData.CombatLogged == 1 then
			Profile.Data.ClientData.CombatLogged = 0
			Profile.Data.ClientData.LoggedPosition = false
			Profile.Data.ClientData.Deaths += 1	
			
			if StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
				Profile.Data.ClientData.LoggedPlace = "Hueco Mundo"
			elseif StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
				Profile.Data.ClientData.LoggedPlace = "Soul Society"
			else
				Profile.Data.ClientData.LoggedPlace = "Karakura Town"
			end
			
			--local Elo = Profile.Data.ClientData.Elo
			local EXP = Profile.Data.ClientData.EXP
			--local SetElo = math.floor(Elo * 0.3) + 2

			EXP -= 15
			Profile.Data.ClientData.EXP = EXP
			
			local Kan = Profile.Data.ClientData.Kan
			Kan -= StatData.KanLossOnCombatLog
			if Kan < 0 then
				Kan = 0
			end
			Profile.Data.ClientData.Kan = Kan
			
			--[[if Elo - SetElo > 0 then
				Elo -= SetElo
				Profile.Data.ClientData.Elo = Elo
			else
				Profile.Data.ClientData.Elo = -1
			end]]
			
			local Race = Profile.Data.ClientData.Race
			if StatData.Factions[Race] == "Arrancar" then
				local MaxHealth = Profile.Data.ClientData.MaxHealth
				MaxHealth -= StatData.HealthLossOnCombatLog
				if MaxHealth > StatData.MinimumHealth then
					Profile.Data.ClientData.MaxHealth = MaxHealth
				else
					Profile.Data.ClientData.MaxHealth = StatData.MinimumHealth
				end
			elseif StatData.Factions[Race] == "Shinigami" then
				local MaxReiatsu = Profile.Data.ClientData.MaxReiatsu
				MaxReiatsu -= StatData.ReiatsuLossOnCombatLog
				if MaxReiatsu > StatData.MinimumReiatsu then
					Profile.Data.ClientData.MaxReiatsu = MaxReiatsu
				else
					Profile.Data.ClientData.MaxReiatsu = StatData.MinimumReiatsu
				end
			elseif StatData.Factions[Race] == "Quincy" then
				local MaxReiatsu = Profile.Data.ClientData.MaxReiatsu
				MaxReiatsu -= StatData.ReiatsuLossOnCombatLog
				if MaxReiatsu > StatData.MinimumReiatsu then
					Profile.Data.ClientData.MaxReiatsu = MaxReiatsu
				else
					Profile.Data.ClientData.MaxReiatsu = StatData.MinimumReiatsu
				end
				local MaxHealth = Profile.Data.ClientData.MaxHealth
				MaxHealth -= StatData.HealthLossOnCombatLog
				if MaxHealth > StatData.MinimumHealth then
					Profile.Data.ClientData.MaxHealth = MaxHealth
				else
					Profile.Data.ClientData.MaxHealth = StatData.MinimumHealth
				end
			end
			
			if not StatData.LockVasto then
				local VastoLordeReqs = Profile.Data.ClientData.VastoLordeReqs
				if VastoLordeReqs and Profile.Data.ClientData.ShinigamiRank == 16 then
					Profile.Data.ClientData.VastoLordeReqs.MaskCracks = 0
					Profile.Data.ClientData.VastoLordeReqs.RivalCrack = false
					
					local WebhookInfo = {
						Message = Player.Name .. " lost all masks to combat log";
					}

					Webhooks:Post(VastoPatrolChannel, WebhookInfo)	
				end
			end
			
			local QuincyMedallion = RemoveItem(Player, "Quincy Medallion", 1)
			if QuincyMedallion then
				local WebhookInfo = {
					Message = Player.Name .. "'s Quincy Medallion has been destroyed";
				}

				Webhooks:Post("FactionManager", WebhookInfo)
			end
			
			if not Profile.Data.ClientData.BankaiUnlocked and not Profile.Data.ClientData.BankaiRequirements.BankaiReady then
				local ReqsBeforeDeath = DeepCopyTable(Profile.Data.ClientData.BankaiRequirements)
				if ReqsBeforeDeath.RankDuration >= StatData.BankaiRequirements.RankDuration then
					local Hollows = ReqsBeforeDeath.Hollows
					local Players = ReqsBeforeDeath.Players
					local WorldBosses = ReqsBeforeDeath.WorldBosses

					Profile.Data.ClientData.BankaiRequirements = {
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
						Title = Player.Name .. " " .. Player.UserId .. " combat log"
					}

					local BankaiPatrolChannel = "BankaiPatrol"
					Webhooks:Post(BankaiPatrolChannel, WebhookInfo)
				end
			end
			
			local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank

			if Profile.Data.ClientData.Race == "Quincy" and ShinigamiRank <= StatData.ShikaiFightRankRequirement and Profile.Data.ClientData.SchriftQuest and Profile.Data.ClientData.SchriftQuest.Started then
				Profile.Data.ClientData.SchriftQuest = {
					Started = true;
					Arrancars = 0;
					Shinigami = 0;
					Fishbone = 0;
					Menos = 0;
					Adjuchas = 0;
				}
			end
		end
		
		local Leaderboard = ServerStorage.Assets.UIs.Leaderboard:Clone()
		Leaderboard.Parent = Player.PlayerGui

		local Toolbar = ServerStorage.Assets.UIs.Toolbar:Clone()
		Toolbar.Parent = Player.PlayerGui
		
		local RankTimer = Profile.Data.ClientData.RankTimer
		local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
		local TimeDifference = DateTime.now().UnixTimestamp - RankTimer
		local Minutes = TimeDifference / 60
		local RankupText = math.floor(Minutes) .. "/" .. math.floor(StatData.RankTimers[ShinigamiRank] * 60) .." Min"
		if Minutes >= StatData.RankTimers[ShinigamiRank] * 60 then
			RankupText = "CAN RANK"
		end
		
		local Name = GetPlayerName(Player)
		
		local Settings = ServerStorage.Assets.UIs.Settings:Clone()
		Settings.Frame.PlayerName.Text = Player.Name .. "_" .. Player.UserId
		Settings.Frame.CharacterName.Text = Name
		Settings.Frame.RankTimer.Text = RankupText
		Settings.Parent = Player.PlayerGui

		local EffectsFolder = Instance.new("Folder")
		EffectsFolder.Name = Player.Name
		EffectsFolder.Parent = workspace.Effects

		local LiveAssetsFolder = Instance.new("Folder")
		LiveAssetsFolder.Name = Player.Name
		LiveAssetsFolder.Parent = ServerStorage.LiveAssets
		
		Profile.Data.ClientData.RestoreStats = nil
		Profile.Data.ClientData.CleanFragments = nil
		
		if not Profile.Data.ClientData.RestoreStats1 then
			Profile.Data.ClientData.RestoreStats1 = true
			
			local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank

			local MaxHealth = StatData.PlayerStats[ShinigamiRank].Health
			local MaxReiatsu = StatData.PlayerStats[ShinigamiRank].Reiatsu
			Profile.Data.ClientData.MaxHealth = MaxHealth
			Profile.Data.ClientData.MaxReiatsu = MaxReiatsu
		end
		
		--[[if not Profile.Data.ClientData.AssignMissingSP2 then
			Profile.Data.ClientData.AssignMissingSP2 = true
			
			local UnlockedSkills = Profile.Data.UnlockedSkills
			local Inventory = Profile.Data.Inventory

			local SPValues = StatData.SPValues

			local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
			local SP = 0
			local CurrentSP = 0
			for i = 18, 1, -1 do
				SP += SPValues[i]
				local RankSP = SPValues[i]
				if i <= ShinigamiRank then
					break
				end
			end
			CurrentSP += Profile.Data.ClientData.SP
			CurrentSP += Profile.Data.ClientData.Kendo
			CurrentSP += Profile.Data.ClientData.Kido
			CurrentSP += Profile.Data.ClientData.Speed
			CurrentSP += Profile.Data.ClientData.Hakuda
			CurrentSP += Profile.Data.ClientData.Healing
			
			local MissingSP = SP - CurrentSP
			Profile.Data.ClientData.SP += MissingSP
		end]]
		
		PassivesManager:CreatePassiveData(Player)
		
		local StateModule = Profile.Data.ClientData.StateModule
		EntityManager:CreateEntity(Player.Name, StateModule, Player)
		if Player.Character:GetAttribute("Spectator") then
			EntityManager:ChangeState(Player.Character, "TriggerSpectator")
		end
		
		SetupUIs(Player)
		
		if Profile.Data.ClientData.GlobalRank >= 1 and Profile.Data.ClientData.GlobalRank <= 3 then
			SpiritualPressure(Player)
		end
	end
end

local function createShinigamiData(Player)
	local Profile = cachedProfiles[Player]

	-- Roll players clan & their accessories
	local function RollClanData()
		-- Roll clan
		local CommonClans = {"Shiba", "Hitsugaya", "Unohana", "Abarai", "Kyoraku", "Shihouin", "Urahara", "Hirako", "Kuchiki", "Ichimaru", "Hisagi", "Kira", "Ukitake",
			"Azashiro",  "Nishimura",
		}
		local LegendaryClans = {"Kurosaki", "Zaraki", "Yamamoto", "Hyosube", "Shutara", "Tsunayashiro"}

		local SelectedClan
		if RandomNumber:RandomInteger(1, 100) >= 1 then
			local ArrayIndex = RandomNumber:RandomInteger(1, #CommonClans)
			SelectedClan = CommonClans[ArrayIndex]
		else
			local ArrayIndex = RandomNumber:RandomInteger(1, #LegendaryClans)
			SelectedClan = LegendaryClans[ArrayIndex]
		end

 		Profile.Data.ClientData.Clan = SelectedClan

		-- Select accessory for the chosen clan
		local ClanData = require(ServerStorage.Modules.Utility.ClanData)	
		if ClanData[SelectedClan].Accessories then
			local SelectedAccessory = ClanData[SelectedClan].Accessories[RandomNumber:RandomInteger(1, #ClanData[SelectedClan].Accessories)]
			DataManager:AddItem(Player, SelectedAccessory, 1)
			print(SelectedAccessory)
		else
			print(SelectedClan .. " Has no accessory data")
		end

		-- Select hair color for the chosen clan
		if ClanData[SelectedClan]["HairColor"] then
			local HairColors = ClanData[SelectedClan]["HairColor"]
			local SelectedHairColor = HairColors[RandomNumber:RandomInteger(1, #HairColors)]
			
			local function RandomShade(Color)
				local RNG = Random.new()
				local Min, Max = 0.4, 1
				local Factor = RNG:NextNumber(Min, Max)
				local H, S, V = Color:ToHSV()
				return Color3.fromHSV(H, S * Factor, V * Factor)
			end

			local function Color3ToRGB(Color)
				local R = math.clamp(math.round(Color.R * 255), 0, 255)
				local G = math.clamp(math.round(Color.G * 255), 0, 255)
				local B = math.clamp(math.round(Color.B * 255), 0, 255)
				return {R, G, B}
			end
			local Color = Color3.fromRGB(SelectedHairColor[1], SelectedHairColor[2], SelectedHairColor[3])
			SelectedHairColor = Color3ToRGB(RandomShade(Color))			
			
			Profile.Data.ClientData.HairColor = SelectedHairColor
		end
		
		-- Select 
		local function SetupArray(Object, MatchString)
			local Array = {}
			for i, v in pairs(Object:GetChildren()) do
				if string.match(v.Name, MatchString) and not v:GetAttribute("Whitelist") then
					table.insert(Array, v.Name)
				end
			end
			table.sort(Array)
			return Array
		end
		
		-- Select random clan facial features
		local ClanFaces = ServerStorage.Assets.Accessories.ClanFaces:FindFirstChild(Profile.Data.ClientData.Clan)
		if ClanFaces then
			local ClanFaceTypes = {
				SetupArray(ClanFaces, "Eye");
				SetupArray(ClanFaces, "Eyebrow");
				SetupArray(ClanFaces, "Mouth");
				SetupArray(ClanFaces, "Pupil");
				SetupArray(ClanFaces, "Markings");
			}
			
			local DataIndex = {
				"Eyes";
				"Eyebrow";
				"Mouth";
				"Eyes";
				"Marking";
			}
			
			for i = 1, 5 do
				if #ClanFaceTypes[i] > 0 then
					print("Found " .. tostring(ClanFaces) .. " " .. DataIndex[i])
					Profile.Data.ClientData[DataIndex[i]] = RandomNumber:RandomInteger(1, #ClanFaceTypes[i])
				end
			end
		end
	end
	
	-- Roll players shikai element & weapon

	local function RollShikai()
		-- Roll players shikai
		
		local StoredShikais = StatData.ShikaiPool

		local SelectedNumber = RandomNumber:RandomInteger(1, 100)
		if SelectedNumber <= 1 then
			StoredShikais = StatData.LegendaryShikaiPool
		elseif SelectedNumber > 1 and SelectedNumber <= 11 then
			StoredShikais = StatData.RareShikaiPool
		end
		table.sort(StoredShikais)
		
		local SelectedShikai = StoredShikais[RandomNumber:RandomInteger(1, #StoredShikais)]
		--SelectedShikai = "Creation"
		Profile.Data.ClientData.Shikai = SelectedShikai		
	end

	RollClanData()
	RollShikai()
end

local function createArrancarData(Player) -- arrancars roll different clans/res than shinigami
	local Profile = cachedProfiles[Player]
	-- Roll players clan & their accessories
	local function RollClanData()
		-- Roll clan

		local CommonClans = {"Harribel", "Gilga", "Llargo", "Granz", "Rureaux", "Arruruerie", "Appaci", "Mila Rose", "Aivirrne", "Vega",
			"Gingerbuck", "Margela",
		}
		local LegendaryClans = {"Louisenbairn", "Starrk", "Jaegerjaquez", "Cifer", "Odelschwanck"}

		local SelectedClan
		if RandomNumber:RandomInteger(1, 100) >= 1 then
			local ArrayIndex = RandomNumber:RandomInteger(1, #CommonClans)
			SelectedClan = CommonClans[ArrayIndex]
		else
			local ArrayIndex = RandomNumber:RandomInteger(1, #LegendaryClans)
			SelectedClan = LegendaryClans[ArrayIndex]
		end

		Profile.Data.ClientData.Clan = SelectedClan

		-- Select accessory for the chosen clan
		local ClanData = require(ServerStorage.Modules.Utility.ClanData)	
		if ClanData[SelectedClan].Accessories then
			local SelectedAccessory = ClanData[SelectedClan].Accessories[RandomNumber:RandomInteger(1, #ClanData[SelectedClan].Accessories)]
			DataManager:AddItem(Player, SelectedAccessory, 1)
			print(SelectedAccessory)
		else
			print(SelectedClan .. " Has no accessory data")
		end

		-- Select hair color for the chosen clan
		if ClanData[SelectedClan]["HairColor"] then
			local HairColors = ClanData[SelectedClan]["HairColor"]
			local SelectedHairColor = HairColors[RandomNumber:RandomInteger(1, #HairColors)]
			
			local function RandomShade(Color)
				local RNG = Random.new()
				local Min, Max = 0.4, 1
				local Factor = RNG:NextNumber(Min, Max)
				local H, S, V = Color:ToHSV()
				return Color3.fromHSV(H, S * Factor, V * Factor)
			end

			local function Color3ToRGB(Color)
				local R = math.clamp(math.round(Color.R * 255), 0, 255)
				local G = math.clamp(math.round(Color.G * 255), 0, 255)
				local B = math.clamp(math.round(Color.B * 255), 0, 255)
				return {R, G, B}
			end

			local Color = Color3.fromRGB(SelectedHairColor[1], SelectedHairColor[2], SelectedHairColor[3])
			SelectedHairColor = Color3ToRGB(RandomShade(Color))			
			
			Profile.Data.ClientData.HairColor = SelectedHairColor
		end
		
		-- Select 
		local function SetupArray(Object, MatchString)
			local Array = {}
			for i, v in pairs(Object:GetChildren()) do
				if string.match(v.Name, MatchString) and not v:GetAttribute("Whitelist") then
					table.insert(Array, v.Name)
				end
			end
			table.sort(Array)
			return Array
		end

		-- Select random clan facial features
		local ClanFaces = ServerStorage.Assets.Accessories.ClanFaces:FindFirstChild(Profile.Data.ClientData.Clan)
		if ClanFaces then
			local ClanFaceTypes = {
				SetupArray(ClanFaces, "Eye");
				SetupArray(ClanFaces, "Eyebrow");
				SetupArray(ClanFaces, "Mouth");
				SetupArray(ClanFaces, "Pupil");
				SetupArray(ClanFaces, "Markings");
			}

			local DataIndex = {
				"Eyes";
				"Eyebrow";
				"Mouth";
				"Eyes";
				"Marking";
			}

			for i = 1, 5 do
				if #ClanFaceTypes[i] > 0 then
					print("Found " .. tostring(ClanFaces) .. " " .. DataIndex[i])
					Profile.Data.ClientData[DataIndex[i]] = RandomNumber:RandomInteger(1, #ClanFaceTypes[i])
				end
			end
		end
	end

	-- Roll players shikai element & weapon

	local function RollRes() -- change 2 res when implemented, merged shinigami/arrancar states since theyre the same, reuse shikai stuff but for unique res's
		-- Roll players res

		local StoredRes = StatData.ResPool
		if RandomNumber:RandomInteger(1, 100) <= 1 then
			StoredRes = StatData.LegendaryResPool
		end
		table.sort(StoredRes)
		
		local SelectedRes = StoredRes[RandomNumber:RandomInteger(1, #StoredRes)]
		Profile.Data.ClientData.Shikai = SelectedRes
		
		local ArrancarZanpakutoNames = ZanpakutoNames.Arrancar[SelectedRes]
		local RandomZanpakutoName = ArrancarZanpakutoNames[RandomNumber:RandomInteger(1, #ArrancarZanpakutoNames)]
		Profile.Data.ClientData.ZanpakutoName = RandomZanpakutoName
		
		if RandomNumber:RandomInteger(1, 100) <= 10 then
			Profile.Data.ClientData.ReleasePhrase = ZanpakutoNames.ArrancarReleasePhrases.Rare[RandomNumber:RandomInteger(1, #ZanpakutoNames.ArrancarReleasePhrases.Rare)]
		else
			Profile.Data.ClientData.ReleasePhrase = ZanpakutoNames.ArrancarReleasePhrases.Common[RandomNumber:RandomInteger(1, #ZanpakutoNames.ArrancarReleasePhrases.Common)]
		end
		
		local PartialRes = {"Z", "X", "C"}
		local SelectedPartialRes = PartialRes[RandomNumber:RandomInteger(1, #PartialRes)]
		Profile.Data.ClientData.PartialRes = SelectedPartialRes
		
		local PartialRes1 = table.find(PartialRes, Profile.Data.ClientData.PartialRes)
		table.remove(PartialRes, PartialRes1)

		local SelectedPartialRes2 = PartialRes[RandomNumber:RandomInteger(1, #PartialRes)]
		Profile.Data.ClientData.PartialRes2 = SelectedPartialRes2
	end

	RollClanData()
	RollRes()
end

local function createQuincyData(Player)
	local Profile = cachedProfiles[Player]

	-- Roll players clan & their accessories
	local function RollClanData()
		-- Roll clan
		local CommonClans = {"Lamperd", "Waccabrada", "McAllon", "Gabrielli", "Guizbatt", "Najahkoop", "Kruniel", "Landaire", "Lloyd", "Dalein",
			"Ehrenfenn", "Furraire", "Kinling", "Ouritt", "Opia", "Bachmann",
		}
		local LegendaryClans = {"Le Vaar", "Parnkgjas", "Du", "Valkyrie", "B"}

		local SelectedClan
		if RandomNumber:RandomInteger(1, 100) >= 1 then
			local ArrayIndex = RandomNumber:RandomInteger(1, #CommonClans)
			SelectedClan = CommonClans[ArrayIndex]
		else
			local ArrayIndex = RandomNumber:RandomInteger(1, #LegendaryClans)
			SelectedClan = LegendaryClans[ArrayIndex]
		end

		Profile.Data.ClientData.Clan = SelectedClan

		-- Select accessory for the chosen clan
		local ClanData = require(ServerStorage.Modules.Utility.ClanData)	
		if ClanData[SelectedClan].Accessories then
			local SelectedAccessory = ClanData[SelectedClan].Accessories[RandomNumber:RandomInteger(1, #ClanData[SelectedClan].Accessories)]
			DataManager:AddItem(Player, SelectedAccessory, 1)
			print(SelectedAccessory)
		else
			print(SelectedClan .. " Has no accessory data")
		end

		-- Select hair color for the chosen clan
		if ClanData[SelectedClan]["HairColor"] then
			local HairColors = ClanData[SelectedClan]["HairColor"]
			local SelectedHairColor = HairColors[RandomNumber:RandomInteger(1, #HairColors)]

			local function RandomShade(Color)
				local RNG = Random.new()
				local Min, Max = 0.4, 1
				local Factor = RNG:NextNumber(Min, Max)
				local H, S, V = Color:ToHSV()
				return Color3.fromHSV(H, S * Factor, V * Factor)
			end

			local function Color3ToRGB(Color)
				local R = math.clamp(math.round(Color.R * 255), 0, 255)
				local G = math.clamp(math.round(Color.G * 255), 0, 255)
				local B = math.clamp(math.round(Color.B * 255), 0, 255)
				return {R, G, B}
			end
			local Color = Color3.fromRGB(SelectedHairColor[1], SelectedHairColor[2], SelectedHairColor[3])
			SelectedHairColor = Color3ToRGB(RandomShade(Color))			

			Profile.Data.ClientData.HairColor = SelectedHairColor
		end

		-- Select 
		local function SetupArray(Object, MatchString)
			local Array = {}
			for i, v in pairs(Object:GetChildren()) do
				if string.match(v.Name, MatchString) and not v:GetAttribute("Whitelist") then
					table.insert(Array, v.Name)
				end
			end
			table.sort(Array)
			return Array
		end

		-- Select random clan facial features
		local ClanFaces = ServerStorage.Assets.Accessories.ClanFaces:FindFirstChild(Profile.Data.ClientData.Clan)
		if ClanFaces then
			local ClanFaceTypes = {
				SetupArray(ClanFaces, "Eye");
				SetupArray(ClanFaces, "Eyebrow");
				SetupArray(ClanFaces, "Mouth");
				SetupArray(ClanFaces, "Pupil");
				SetupArray(ClanFaces, "Markings");
			}

			local DataIndex = {
				"Eyes";
				"Eyebrow";
				"Mouth";
				"Eyes";
				"Marking";
			}

			for i = 1, 5 do
				if #ClanFaceTypes[i] > 0 then
					print("Found " .. tostring(ClanFaces) .. " " .. DataIndex[i])
					Profile.Data.ClientData[DataIndex[i]] = RandomNumber:RandomInteger(1, #ClanFaceTypes[i])
				end
			end
		end
	end

	-- Roll players shikai element & weapon

	local function RollVollstandig()
		-- Roll players shikai

		local StoredVollstandig = StatData.VollstandigPool

		if RandomNumber:RandomInteger(1, 100) <= 1 then
			StoredVollstandig = StatData.LegendaryVollstandigPool
		end
		table.sort(StoredVollstandig)

		local SelectedVollstandig = StoredVollstandig[RandomNumber:RandomInteger(1, #StoredVollstandig)]
		Profile.Data.ClientData.Shikai = SelectedVollstandig
		
		local QuincyZanpakutoNames = ZanpakutoNames.Quincy[SelectedVollstandig]
		local RandomZanpakutoName = QuincyZanpakutoNames[RandomNumber:RandomInteger(1, #QuincyZanpakutoNames)]
		Profile.Data.ClientData.ZanpakutoName = RandomZanpakutoName
		Profile.Data.ClientData.ReleasePhrase = "Quincy: Voll Stern Dich"
	end

	RollClanData()
	RollVollstandig()
	
	Profile.Data.ClientData.LastZanpakutoWeapon = "Schwert"
	Profile.Data.ClientData.ZanpakutoWeapon = "Schwert"
	Profile.Data.ClientData.SpiritBow = "Bogen"
	Profile.Data.ClientData.Sheathe = 1
	Profile.Data.ClientData.QuincyEXP = 0
end

local function createHollowData(Player)
	local Profile = cachedProfiles[Player]
	
	--[[local HollowForms = { -- RANKBASED
		[15] = "VastoLorde";
		[16] = "Adjuchas";
		[17] = "Menos";
		[18] = "Fishbone";
	}]]
	
	Profile.Data.ClientData.VastoLordeReqs = {
		MaskCracks = 0;
		MaskCracked = false;
		MaskCrackTimer = 0;
		RivalCrack = false;
	}

	Profile.Data.ClientData.Mask = RandomNumber:RandomInteger(1, 11)
end

function DataManager.createRaceData(Player, Race)
	if StatData.Factions[Race] == "Shinigami" then
		createShinigamiData(Player)
	elseif StatData.Factions[Race] == "Arrancar" then
		createArrancarData(Player)
	elseif StatData.Factions[Race] == "Quincy" then
		createQuincyData(Player)
	elseif Race == "Hollow" then
		createHollowData(Player)
		DataManager:AddSkill(Player, "Garganta")
	end
end

function DataManager:RequestSkillInventory(Player)
	local Profile = cachedProfiles[Player]
	return Profile.Data.Inventory
end

function DataManager:RequestSP(Player)
	return RequestSP(Player)
end

function DataManager:AddKan(Player, Amount)
	local Profile = cachedProfiles[Player]
	local Kan = Profile.Data.ClientData.Kan
	Kan += Amount
	if Kan < 0 then
		Kan = 0
	end
	
	local FlooredKan = math.floor(Kan)
	
	Profile.Data.ClientData.Kan = FlooredKan

	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		Player.Character:SetAttribute("Kan", FlooredKan)
	end
end

function DataManager:RemoveItem(Player, ItemName, Amount)
	local Profile = cachedProfiles[Player]
	
	local ItemInventory = Profile.Data.ItemInventory
	local Inventory = Profile.Data.Inventory
	local ValidItem = TradeablesData[ItemName]
	if ValidItem and ItemInventory[ItemName] and Profile:IsActive() then
		Profile.Data.ItemInventory[ItemName] -= Amount
		
		if Profile.Data.ItemInventory[ItemName] <= 0 then
			Profile.Data.ItemInventory[ItemName] = nil
			
			local ItemType = ValidItem.ItemType
			if ItemType == "Skill" then
				DataManager:RemoveSkill(ItemName)
			else
				for AccessoryType, AccessoryName in pairs(Profile.Data.Accessories) do
					if AccessoryName == ItemName then
						Profile.Data.Accessories[AccessoryType] = "Empty"
						task.spawn(function()
							Player.Character.Accessories[AccessoryType]:ClearAllChildren()
						end)
					end
				end
			end
			
			local AlreadyEquipped
			for i, v in pairs(Inventory) do
				if v == ItemName then
					AlreadyEquipped = i
				end
			end

			if AlreadyEquipped then
				Inventory[AlreadyEquipped] = "Empty"
			end
			
			local PlayerItemInventory = Profile.Data.ItemInventory
			local PlayerSPTable = RequestSP(Player)
			local PlayerUnlockedSkills = Profile.Data.UnlockedSkills
			local Toolbar = DataManager:RequestSkillInventory(Player)

			ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
			ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
		end
		
		local ItemInfo = {
			ItemName = ItemName;
			Info = ValidItem;
		}
		
		local PlayerItemInventory = Profile.Data.ItemInventory
		ReplicatedStorage.Remotes.UpdateAccessoryUIEvent:FireClient(Player, ItemInfo, PlayerItemInventory)
		
		return true
	else
		warn("[DataManager]: Not a valid item:", ItemName)
	end
end

function DataManager:CheckItemQuantity(Player, ItemName)
	local Profile = cachedProfiles[Player]
	local ItemInventory = Profile.Data.ItemInventory
	local ValidItem = TradeablesData[ItemName]
	
	if ValidItem then
		return ItemInventory[ItemName]
	end
end

function DataManager:AddItem(Player, ItemName, Amount)
	local Profile = cachedProfiles[Player]
	local ItemInventory = Profile.Data.ItemInventory
	local ValidItem = TradeablesData[ItemName]
	if ValidItem then
		if not ItemInventory[ItemName] then
			ItemInventory[ItemName] = 0
		end
		ItemInventory[ItemName] += Amount

		local ItemType = ValidItem.ItemType
		if ItemType == "Skill" then
			DataManager:AddSkill(ItemName)
		end
		
		local ItemInfo = {
			ItemName = ItemName;
			Info = ValidItem;
		}
		ReplicatedStorage.Remotes.UpdateAccessoryUIEvent:FireClient(Player, ItemInfo, ItemInventory)
		
		local ClientItems = ReplicatedStorage.Modules.ClientModules.ClientItems
		local PathData = {Module = ClientItems, Skill = "ItemObtained"}
		local RenderDistance = -1
		NetworkManager.FireClient(Player, Player.Character, "ClientEffects", RenderDistance, PathData, ItemName)
	else
		warn("[DataManager]: Not a valid item:", ItemName)
	end
end

function DataManager:AddSkill(Player, SkillName)
	local Profile = cachedProfiles[Player]
	local UnlockedSkills = Profile.Data.UnlockedSkills
	if not table.find(UnlockedSkills, SkillName) and ServerSkillReqs[SkillName] then
		table.insert(UnlockedSkills, SkillName)
		
		if ServerSkillReqs[SkillName].PassiveData then
			PassivesManager:UpdatePassive(Player, ServerSkillReqs[SkillName].PassiveData)
		end
		if ServerSkillReqs[SkillName].Attributes then
			PassivesManager:UpdateAttributes(Player.Character, ServerSkillReqs[SkillName].Attributes)
		end
		if ServerSkillReqs[SkillName].M1PassiveData then
			PassivesManager:UpdateM1Passive(Player, ServerSkillReqs[SkillName].M1PassiveData)
		end
		if SkillName == "Hakuda Style" then
			local LastZanpakutoWeapon = Profile.Data.ClientData.ZanpakutoWeapon

			Profile.Data.ClientData.ZanpakutoWeapon = "Fist"
			if LastZanpakutoWeapon == "Grimmjow" or LastZanpakutoWeapon == "Cang" then
				Profile.Data.ClientData.ZanpakutoWeapon = LastZanpakutoWeapon
			end
			Profile.Data.ClientData.Sheathe = 1
			
			Profile.Data.ClientData.OldWeaponType = Profile.Data.ClientData.WeaponType
			Profile.Data.ClientData.OldWeaponModel = Profile.Data.ClientData.WeaponModel
			Profile.Data.ClientData.OldBankaiWeaponModel = Profile.Data.ClientData.BankaiWeaponModel
			
			Profile.Data.ClientData.WeaponType = "Gauntlet"
			Profile.Data.ClientData.WeaponModel = "Gauntlet" .. RandomNumber:RandomInteger(1, 2)
			Profile.Data.ClientData.BankaiWeaponModel = "Gauntlet1"
			if Player.Character then
				Player.Character:SetAttribute("DeathBypass", true)
				EntityManager:ForceState(Player.Character, "Dying")
				EntityManager:ChangeState(Player.Character, "TriggerDeath")
			end
		end
		
		local PlayerSPTable = RequestSP(Player)
		local PlayerUnlockedSkills = UnlockedSkills
		local Toolbar = DataManager:RequestSkillInventory(Player)
		local PlayerItemInventory = Profile.Data.ItemInventory
		
		local Category = ServerSkillReqs[SkillName].StatReq1.Category
		
		ReplicatedStorage.Remotes.SkillLearnedEvent:FireClient(Player, SkillName, Category, true)
		ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, UnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
		ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
	end
end

function DataManager:RemoveSkill(Player, SkillName)
	local Profile = cachedProfiles[Player]
	local UnlockedSkills = Profile.Data.UnlockedSkills
	local Inventory = Profile.Data.Inventory
	if table.find(UnlockedSkills, SkillName) then
		table.remove(UnlockedSkills, table.find(UnlockedSkills, SkillName))
		
		local AlreadyEquipped
		for i, v in pairs(Inventory) do
			if v == SkillName then
				AlreadyEquipped = i
			end
		end
		
		if AlreadyEquipped then
			Inventory[AlreadyEquipped] = "Empty"
		end
		
		local PlayerSPTable = RequestSP(Player)
		local PlayerUnlockedSkills = UnlockedSkills
		local Toolbar = DataManager:RequestSkillInventory(Player)
		local PlayerItemInventory = Profile.Data.ItemInventory
		
		ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, nil, PlayerItemInventory)
		ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
	end
end

function DataManager:AddSP(Player, Stat)
	local Profile = cachedProfiles[Player]
	local SPPoints = Profile.Data.ClientData.SP
	
	local SPTable = {
		"Hakuda",
		"Kendo",
		"Kido",
		"Healing",
		"Speed",
	}
	
	if table.find(SPTable, Stat) and SPPoints > 0 then
		local HakudaSP = Profile.Data.ClientData.Hakuda
		local AllowedSPAdd = Stat
		
		if HakudaSP > 0 then
			if Stat == "Kendo" then
				AllowedSPAdd = "[Kendo locked from Hakuda]"
			end
			
			if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
				if Stat == "Kido" then
					--AllowedSPAdd = "[Shinigami Kido locked from Hakuda]"
				end
			end
		else
			if Stat == "Hakuda" then
				if Profile.Data.ClientData.Kendo > 0 then
					AllowedSPAdd = "[Hakuda locked from Kendo]"
				end
				
				if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
					if Profile.Data.ClientData.Kido > 0 then
						--AllowedSPAdd = "[Hakuda locked from Shinigami Kido]"
					end
				end
			end
		end
		
		if table.find(SPTable, AllowedSPAdd) then
			local StatSP = Profile.Data.ClientData[Stat]
			StatSP += 1
			Profile.Data.ClientData[Stat] = StatSP

			SPPoints -= 1
			Profile.Data.ClientData.SP = SPPoints

			
			local PlayerSPTable = RequestSP(Player)
			local PlayerUnlockedSkills = Profile.Data.UnlockedSkills
			local Toolbar = DataManager:RequestSkillInventory(Player)
			local PlayerItemInventory = Profile.Data.ItemInventory
			
			if Player.Character then
				Player.Character:SetAttribute("Speed", PlayerSPTable.Speed)
				Player.Character:SetAttribute("Kendo", PlayerSPTable.Kendo)
				Player.Character:SetAttribute("MaxPosture", 50 + PlayerSPTable.Kendo)
			end

			ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
			ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
		else
			warn(AllowedSPAdd)
		end
	else
		warn("[AddSP] Could not add sp to:", Stat)
	end
end

function DataManager:AdjustSP(Player, Stat, Amount)
	local Profile = cachedProfiles[Player]

	local SPTable = {
		"Hakuda",
		"Kendo",
		"Kido",
		"Healing",
		"Speed",
		"SP",
	}
	
	if table.find(SPTable, Stat) and tonumber(Amount) then
		local StatSP = Profile.Data.ClientData[Stat]
		StatSP += Amount
		Profile.Data.ClientData[Stat] = StatSP

		local PlayerSPTable = RequestSP(Player)
		local PlayerUnlockedSkills = Profile.Data.UnlockedSkills
		local Toolbar = DataManager:RequestSkillInventory(Player)
		local PlayerItemInventory = Profile.Data.ItemInventory
		
		if Player.Character then
			Player.Character:SetAttribute("Speed", PlayerSPTable.Speed)
			Player.Character:SetAttribute("Kendo", PlayerSPTable.Kendo)
			Player.Character:SetAttribute("MaxPosture", Profile.Data.ClientData.MaxPosture + PlayerSPTable.Kendo)
			
			ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
			ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
		end
	else
		warn(Stat .. " is not a valid SP stat for " .. Player.Name)
	end
end

function DataManager:ModifySkillInventory(Player, InventoryNumber, SkillName)
	local Profile = cachedProfiles[Player]
	local UnlockedSkills = Profile.Data.UnlockedSkills
	local ItemInventory = Profile.Data.ItemInventory
	local Inventory = Profile.Data.Inventory
	
	local AlreadyEquipped
	for i, v in pairs(Inventory) do
		if v == SkillName then
			AlreadyEquipped = i
		end
	end
	
	local SkillOrItem = false
	if table.find(UnlockedSkills, SkillName) then
		SkillOrItem = true
	elseif ItemInventory[SkillName] then
		SkillOrItem = true
	end
	
	if SkillOrItem and Inventory[InventoryNumber] then
		if Player.Character:GetAttribute(InventoryNumber) == false and Player.Character:GetAttribute("CurrentState") ~= "ItemState" then
			local ValidEquip = true
			if AlreadyEquipped then
				if Player.Character:GetAttribute(AlreadyEquipped) ~= true then
					Inventory[AlreadyEquipped] = "Empty"
				else
					ValidEquip = nil
				end
			end
			
			if ValidEquip then
				Inventory[InventoryNumber] = SkillName

				local PlayerSPTable = RequestSP(Player)
				local PlayerUnlockedSkills = Profile.Data.UnlockedSkills
				local Toolbar = DataManager:RequestSkillInventory(Player)
				local PlayerItemInventory = Profile.Data.ItemInventory
				
				ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, PlayerUnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
				ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
			else
				warn("[Error]: Skill on CD")
			end
		else
			warn("[Error]: Skill on CD or holding Item")
		end
	else
		warn("[Error] Player does not own " .. SkillName ..  " or invalid inventory number " .. InventoryNumber)
	end
end

function DataManager:ModifyEquippedAccessories(Player, ItemType, AccessoryName)
	local Profile = cachedProfiles[Player]
	local ItemInventory = Profile.Data.ItemInventory
	local Accessories = Profile.Data.Accessories
	
	local Success
	
	if Accessories[ItemType] and ItemInventory[AccessoryName] then
		Accessories[ItemType] = AccessoryName
		Success = "EquipSuccess"
	elseif Accessories[ItemType] and AccessoryName == "Empty" then
		Accessories[ItemType] = "Empty"
		Success = "UnequipSuccess"
	else
		warn("[DataManager]: Player does not own", AccessoryName, "or invalid item type:", ItemType)
	end

	return Success
end

function DataManager:ModifyProfile(Player, Data, DataType, NewData, Remote)
	local Profile = cachedProfiles[Player]
	if Profile and Profile.Data[Data] and Profile.Data[Data][DataType] then
		--print(Player.Name .."'s " .. DataType .. " modified.", "OldData:", Profile.Data[Data][DataType] .. " | " .. "NewData:", NewData)
		Profile.Data[Data][DataType] = NewData
		
		Player:SetAttribute("Race", Profile.Data.ClientData.Race)
		
		if not Remote then
			local Name = GetPlayerName(Player)
			local ClanInfo = ClanData[Profile.Data.ClientData.Clan]
			
			local Info = {
				Rank = Profile.Data.ClientData.GlobalRank,
				Grade = RequestRank(Player),
				Name =  Name,
				Title = Profile.Data.ClientData.Title,
				LeaderboardHidden = ClanInfo.LeaderboardHidden,
				Race = Profile.Data.ClientData.Race,
			}
			
			if Profile.Data.ClientData.Race == "Visored" or Profile.Data.ClientData.Race == "Vastocar" then
				Info.HiddenGrade = "???"
				if Profile.Data.ClientData.WeakVisored or Profile.Data.ClientData.WeakVasto then
					Info.HiddenGrade = "?"
				end
			end
			
			ReplicatedStorage.Remotes.LeaderboardEvent:FireAllClients("Update", Player.Name, Info)
		end
	end
end

function DataManager:RequestFullProfile(Player)
	local Profile = cachedProfiles[Player]
	if Profile then
		return Profile
	end
end

function DataManager:RequestProfile(Player)
	local Profile = cachedProfiles[Player]
	if Profile then
		return Profile.Data
	end
end

function DataManager:RequestProfileMetaTags(Player)
	local Profile = cachedProfiles[Player]
	if Profile then
		return Profile.MetaData.MetaTags
	end
end

function DataManager:RequestRank(Player)
	return RequestRank(Player)
end

function DataManager:ResetBuild(Player, KeepSkillbox)
	local Profile = cachedProfiles[Player]
	local UnlockedSkills = Profile.Data.UnlockedSkills
	local Inventory = Profile.Data.Inventory
	
	local SPValues = StatData.SPValues
	
	local ShinigamiRank = Profile.Data.ClientData.ShinigamiRank
	local SP = 0
	for i = 18, 1, -1 do
		SP += SPValues[i]
		local RankSP = SPValues[i]
		if i <= ShinigamiRank then
			break
		end
	end
	
	local SkillboxSkills = {}
	for i, v in ipairs(UnlockedSkills) do
		if ServerSkillReqs[v].StatReq1 and ServerSkillReqs[v].StatReq1.Category == "Special" then
			table.insert(SkillboxSkills, v)
		elseif v == "Hierro Mastery" or v == "Hierro Mastery 2" then
			table.insert(SkillboxSkills, v)
		end
		
		if KeepSkillbox and ServerSkillReqs[v].SkillBox then
			DataManager:AddItem(Player, "Skill Box", 1)
		end
	end
	
	Profile.Data.UnlockedSkills = SkillboxSkills
	Profile.Data.ClientData.SP = SP
	Profile.Data.ClientData.Kendo = 0
	Profile.Data.ClientData.Kido = 0
	Profile.Data.ClientData.Speed = 0
	Profile.Data.ClientData.Hakuda = 0
	Profile.Data.ClientData.Healing = 0
	
	local AlreadyEquipped
	for i, v in pairs(Inventory) do
		Inventory[i] = "Empty"
	end
	
	if Profile.Data.ClientData.ZanpakutoWeapon == "Fist" or Profile.Data.ClientData.ZanpakutoWeapon == "Grimmjow" or Profile.Data.ClientData.ZanpakutoWeapon == "Cang" then
		local LastZanpakutoWeapon = Profile.Data.ClientData.LastZanpakutoWeapon
		if not LastZanpakutoWeapon then
			if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
				Profile.Data.ClientData.LastZanpakutoWeapon = "Schwert"
				LastZanpakutoWeapon = "Schwert"
			else
				Profile.Data.ClientData.LastZanpakutoWeapon = "Katana"
				LastZanpakutoWeapon = "Katana"
			end
		end
		Profile.Data.ClientData.ZanpakutoWeapon = LastZanpakutoWeapon
		
		if Profile.Data.ClientData.WeaponType == "Gauntlet" then
			local function SetupArray(Object)
				local Array = {}
				for i, v in pairs(Object:GetChildren()) do
					if not v:GetAttribute("Whitelist") then
						table.insert(Array, v.Name)
					end
				end
				table.sort(Array)
				return Array
			end
			
			local WeaponTypes = {"Dualblade", "Greatsword", "Katana", "Scythe", "Spear", "Twinblade", "Hammer"}
			local SelectedType = WeaponTypes[RandomNumber:RandomInteger(1, #WeaponTypes)]
			
			local WeaponModels = SetupArray(ServerStorage.Assets.Weapons[SelectedType])	
			local BankaiWeaponModels = SetupArray(ServerStorage.Assets.BankaiWeapons[SelectedType])
			
			
			if Profile.Data.ClientData.OldWeaponType then
				Profile.Data.ClientData.WeaponType = Profile.Data.ClientData.OldWeaponType
			else
				Profile.Data.ClientData.WeaponType = SelectedType
			end
			if Profile.Data.ClientData.OldWeaponModel then
				Profile.Data.ClientData.WeaponModel = Profile.Data.ClientData.OldWeaponModel
			else
				Profile.Data.ClientData.WeaponModel = WeaponModels[RandomNumber:RandomInteger(1, #WeaponModels)]
			end
			if Profile.Data.ClientData.OldBankaiWeaponModel then
				Profile.Data.ClientData.BankaiWeaponModel = Profile.Data.ClientData.OldBankaiWeaponModel
			else
				Profile.Data.ClientData.BankaiWeaponModel = BankaiWeaponModels[RandomNumber:RandomInteger(1, #BankaiWeaponModels)]
			end
		end
	end
	
	if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
		--DataManager:AddSkill(Player, "Senkaimon")
		if Profile.Data.ClientData.Race == "Visored" then
			DataManager:AddSkill(Player, "Visored Cero")
		end
	elseif StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
		DataManager:AddSkill(Player, "Garganta")
		if Profile.Data.ClientData.Race == "Vastocar" then
			DataManager:AddSkill(Player, "Cero Oscuras")
			DataManager:AddSkill(Player, "Instinct")
			DataManager:AddSkill(Player, "Hierro")
		elseif Profile.Data.ClientData.Race == "Arrancar" then
			DataManager:AddSkill(Player, "Cero")
			DataManager:AddSkill(Player, "Hierro")
		end
	elseif StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
		DataManager:AddSkill(Player, "Blut Vene")
		DataManager:AddSkill(Player, "The Key")
	end
	
	if table.find(PositionTitles.ShinigamiCaptainTitles, Profile.Data.ClientData.Title) or table.find(PositionTitles.LieutenantUI, Profile.Data.ClientData.Title) then
		DataManager:AddSkill(Player, "Command")
	elseif table.find(PositionTitles.ArrancarEspadaTitles, Profile.Data.ClientData.Title) then
		DataManager:AddSkill(Player, "Espada Command")
		DataManager:AddSkill(Player, "Garganta Break")
	elseif Profile.Data.ClientData.Title == "Fracción" and Profile.Data.Division.Squad >= 1 and Profile.Data.Division.Squad <= 4 then
		DataManager:AddSkill(Player, "Garganta Break")
	elseif table.find(PositionTitles.SternritterTitles, Profile.Data.ClientData.Title) then
		DataManager:AddSkill(Player, "Blut Vene 3")
		DataManager:AddSkill(Player, "Sternritter Command")
	elseif Profile.Data.ClientData.Title == "Jagdarmee" then
		DataManager:AddSkill(Player, "Blut Vene 2")
	end
	
	local PlayerSPTable = RequestSP(Player)
	local Toolbar = DataManager:RequestSkillInventory(Player)
	local PlayerItemInventory = Profile.Data.ItemInventory
	
	ReplicatedStorage.Remotes.UpdateSkillTreeEvent:FireClient(Player, PlayerSPTable, UnlockedSkills, Toolbar, "DontUpdateSkills", PlayerItemInventory)
	ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, Toolbar)
end

function DataManager:PlayerRemoved(Player)
	local Profile = cachedProfiles[Player]
	local CombatLogged
	if Profile then
		if ProfileService.ServiceLocked then
			Profile.Data.ClientData.CombatLogged = 0
		end
		if Profile.Data.ClientData.CombatLogged == 1 then
			CombatLogged = true
		end
		
		local LastPosition = Profile.Data.ClientData.LoggedPosition or Profile.Data.ClientData.DeathPosition
		if LastPosition then
			LastPosition = Vector3.new(LastPosition[1], LastPosition[2], LastPosition[3])
		end
		
		local function DropItem(ItemName)
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

					Item:PivotTo(CFrame.new(LastPosition) * CFrame.new(0, 2, -3))
					TouchedPart = Item.PrimaryPart
				else
					Item.CollisionGroup = "Entity2"
					Item.CFrame = CFrame.new(LastPosition) * CFrame.new(0, 2, -3)
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
									PickedUp = true
									Item:Destroy()
									Connection:Disconnect()
									Connection = nil
									DataManager:AddItem(PickupPlayer, ItemName, 1)

									local PickupPlayerAmount = DataManager:CheckItemQuantity(PickupPlayer, ItemName)

									local WebhookInfo = {
										Message = PickupPlayer.Name .. " has picked up " .. ItemName .. " from " .. Player.Name .. "\n" .. Player.Name .. " " .. ItemName .. ": " .. PlayerAmount .. "\n" .. PickupPlayer.Name .. ItemName .. ": " .. PickupPlayerAmount;
									}

									Webhooks:Post("ItemUses", WebhookInfo)
								end
							end
						end
					end
				end)
			end
		end
		
		if CombatLogged then
			if LastPosition then
				DropItem("Hogyoku Fragment")
				DropItem("Skill Box")
			end
			
			task.defer(function()
				local LastAttacker = Player:GetAttribute("LastAttacker")
				if LastAttacker then
					local EloCharacter = workspace.Entities:FindFirstChild(LastAttacker)
					local EloPlayer = Players:GetPlayerFromCharacter(EloCharacter)
					local ExecutorProfile = DataManager:RequestProfile(EloPlayer)
					local Elo = Profile.Data.ClientData.Elo
					local ExeuctorElo = ExecutorProfile.ClientData.Elo
					
					local EloAllowed
					if ExecutorProfile.ClientData.ShinigamiRank <= StatData.MinimumRankReq and Profile.Data.ClientData.ShinigamiRank <= StatData.MinimumRankReq then
						if StatData.CurrentFactions[StatData.Factions[Profile.Data.ClientData.Race]] and Elo > 0 then
							EloAllowed = true
						end
					end
					
					if EloAllowed then
						if Profile.Data.ClientData.GlobalRank > 0 then
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

								ExecutorProfile.ClientData.BankaiRequirements.RankDuration += RankDurationAdd

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
								if Profile.Data.ClientData.GlobalRank > 0 then
									if Profile.Data.ClientData.GlobalRank >= ExecutorProfile.ClientData.GlobalRank then
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
											Profile.Data.ClientData.Elo = -1
										else
											Elo -= SetElo 
											Profile.Data.ClientData.Elo = Elo
										end
									elseif Profile.Data.ClientData.GlobalRank < ExecutorProfile.ClientData.GlobalRank then
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
											Profile.Data.ClientData.Elo = -1
										else
											Elo -= SetElo
											Profile.Data.ClientData.Elo = Elo
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
									Profile.Data.ClientData.Elo = -1
								else
									Elo -= SetElo 
									Profile.Data.ClientData.Elo = Elo
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

									SyncRank(EloPlayer)
								else
									warn("[Ranked Leaderboard Page Error]:", Pages)
								end
							end)

							local ClientProgression = ReplicatedStorage.Modules.ClientModules.ClientProgression
							local PathData = {Module = ClientProgression, Skill = "EloGained"}
							NetworkManager.FireAllClients(EloCharacter, "ClientEffects", 1000, PathData)

							local GripLogChannel = "GripLogs"
							local WebhookInfo = {
								Message = EloPlayer.Name .. " took elo from " .. Player.Name .. " combat log";
							}

							Webhooks:Post(GripLogChannel, WebhookInfo)
						end
					end
				end
			end)
		end
		
		Profile:Release()
		print(Player.Name .. " has left the game, profile has been released")
		task.defer(function() 
			Player:Destroy()
		end)
	end
	
	EntityManager:CleanupEntity(Player)
	PassivesManager:Cleanup(Player.Name)
	
	if ServerStorage.LiveAssets:FindFirstChild(Player.Name) then
		ServerStorage.LiveAssets[Player.Name]:Destroy()
	end
	if workspace.Effects:FindFirstChild(Player.Name) then
		workspace.Effects[Player.Name]:Destroy()
	end
	
	local CurrentParty = Player:GetAttribute("Party")
	local Party = PartyManager.Parties[CurrentParty]
	if Party then
		local PartyMembers = Party.Members

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
					NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, RemovePathData, OtherMembers)
				end 
				NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, ClearPathData)
			end
			-- Leader left
		else
			-- Member left
			for _, Member in ipairs(PartyMembers) do
				NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, RemovePathData, Player)
				for i, UpdatedMember in ipairs(PartyMembers) do
					NetworkManager.FireClient(Member, Member.Character, "ClientEffects", RenderDistance, UpdatePathData, i, UpdatedMember.Character)
				end
			end
		end]]
	end
end

local RestoreQueue = {}

function DataManager:AddMasks(PlayerId, Amount, SenderName)
	local Player = Players:GetPlayerByUserId(PlayerId)
	if Player then
		local Profile = cachedProfiles[Player]
		
		if Profile.Data.ClientData.VastoLordeReqs then
			Profile.Data.ClientData.VastoLordeReqs.MaskCracks += Amount
			
			ReplicatedStorage.Remotes.MaskCrackUpdate:FireClient(Player, Profile.Data.ClientData.VastoLordeReqs.MaskCracks)
			
			local WebhookInfo = {
				Message = SenderName .. " added " .. Amount .. " masks to " .. Player.Name .. " total: " .. Profile.Data.ClientData.VastoLordeReqs.MaskCracks;
			}

			Webhooks:Post("HeadModLogs", WebhookInfo)
			
			print(Player.Name .."_MaskCrackTimer:", (DateTime.now().UnixTimestamp - Profile.Data.ClientData.VastoLordeReqs.MaskCrackTimer) / 60, "/", 60)
			print(Player.Name .. "_MaskCracks:", Profile.Data.ClientData.VastoLordeReqs.MaskCracks)
		end
		
		return true
	else
		if not RestoreQueue[PlayerId] then
			RestoreQueue[PlayerId] = true

			local profileKey = "Player_" .. PlayerId
			local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
			if not Profile then
				RestoreQueue[PlayerId] = nil
				return nil
			end
			if Profile.MetaData.ActiveSession then
				print(PlayerId, " active profile session located for mask restore")
				RestoreQueue[PlayerId] = nil
				return false
			else
				local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
				if Profile.Data.ClientData.VastoLordeReqs then
					OfflineProfile.Data.ClientData.VastoLordeReqs.MaskCracks += Amount
				end
				OfflineProfile:Release()

				RestoreQueue[PlayerId] = nil
				return true
			end
		end

	end
end

local ViewQueue = {}

function DataManager:ViewProfileItemAsync(PlayerId, ItemName)
	if not ViewQueue[PlayerId] then
		ViewQueue[PlayerId] = true
		
		local profileKey = "Player_" .. PlayerId

		local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
		if not Profile then
			ViewQueue[PlayerId] = nil
			return nil
		end
		warn(PlayerId .. " ViewFullProfileAsync:", Profile and true)
		warn(PlayerId .. " ActiveSession:", Profile.MetaData.ActiveSession or "nil")

		local ItemInventory = Profile.Data.ItemInventory
		if ItemInventory[ItemName] then
			print(PlayerId .. " owns " .. ItemInventory[ItemName] .." " .. ItemName)
		else
			print(PlayerId .. " does not own " .. ItemName)
		end
		
		ViewQueue[PlayerId] = nil
	end
end

function DataManager:ViewProfileAsync(PlayerId)
	if not ViewQueue[PlayerId] then
		ViewQueue[PlayerId] = true
		
		local profileKey = "Player_" .. PlayerId

		local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
		if not Profile then
			ViewQueue[PlayerId] = nil
			return nil
		end
		
		warn(PlayerId .. " ViewFullProfileAsync:", Profile and true)
		warn(PlayerId .. " ActiveSession:", Profile.MetaData.ActiveSession or "nil")
		warn(PlayerId .. " Banned:", Profile.Data.ServerData.Banned or "false")
		warn(PlayerId .. " BanSource:", Profile.Data.ServerData.BanSource or "nil")
		warn(PlayerId .. " DelayBanned:", Profile.Data.ServerData.DelayBan or "nil")
		warn(PlayerId .. " VIM:", Profile.Data.ServerData.VIM or "nil")
		warn(PlayerId .. " 32Bit:", Profile.Data.ServerData.Is32Bit or "false")
		warn(PlayerId .. " RemoteEventBan", Profile.Data.ServerData.RemoteEventBan or "nil")
		
		local TotalSp = 0
		TotalSp += Profile.Data.ClientData.SP
		TotalSp += Profile.Data.ClientData.Kendo
		TotalSp += Profile.Data.ClientData.Hakuda
		TotalSp += Profile.Data.ClientData.Speed
		TotalSp += Profile.Data.ClientData.Healing
		TotalSp += Profile.Data.ClientData.Kido

		warn(PlayerId .. "_ShinigamiRank: " .. Profile.Data.ClientData.ShinigamiRank)
		warn(PlayerId .. "_StateModule: " .. Profile.Data.ClientData.StateModule)
		warn(PlayerId .. "_Race: " .. Profile.Data.ClientData.Race)
		warn(PlayerId .. "_TotalSP: " .. TotalSp)
		warn(PlayerId .. "_SP: " .. Profile.Data.ClientData.SP)
		warn(PlayerId .. "_Kendo: " .. Profile.Data.ClientData.Kendo)
		warn(PlayerId .. "_Hakuda: " .. Profile.Data.ClientData.Hakuda)
		warn(PlayerId .. "_Speed: " .. Profile.Data.ClientData.Speed)
		warn(PlayerId .. "_Healing: " .. Profile.Data.ClientData.Healing)
		warn(PlayerId .. "_Kido: " .. Profile.Data.ClientData.Kido)
		warn(PlayerId .. "_Kan:", Profile.Data.ClientData.Kan)
		warn(PlayerId .. "_Elo:", Profile.Data.ClientData.Elo)
		warn(PlayerId .. "_Shikai:", Profile.Data.ClientData.Shikai)
		warn(PlayerId .. "_WeaponType:", Profile.Data.ClientData.WeaponType)
		warn(PlayerId .. "_WeaponModel:", Profile.Data.ClientData.WeaponModel)
		warn(PlayerId .. "_PartialRes:", Profile.Data.ClientData.PartialRes)
		warn(PlayerId .. "_PartialRes2:", Profile.Data.ClientData.PartialRes2)
		
		ViewQueue[PlayerId] = nil
	end
end

local BanQueue = {}

function DataManager:Ban(PlayerId, Source)
	local Player = Players:GetPlayerByUserId(PlayerId)
	if Player then
		local Profile = cachedProfiles[Player]
		Profile.Data.ServerData.Banned = true
		Profile.Data.ServerData.BanSource = Source
		Player:Kick("You have been permanently banned from this game.")
		Profile:Release()
		return true
	else
		if not BanQueue[PlayerId] then
			BanQueue[PlayerId] = true
			
			local profileKey = "Player_" .. PlayerId
			local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
			if not Profile then
				BanQueue[PlayerId] = nil
				return nil
			end
			if Profile.MetaData.ActiveSession then
				print(PlayerId, " active profile session located for ban")
				BanQueue[PlayerId] = nil
				return false
			else
				local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
				OfflineProfile.Data.ServerData.Banned = true
				OfflineProfile.Data.ServerData.BanSource = Source
				OfflineProfile:Release()

				BanQueue[PlayerId] = nil
				return true
			end
		end
		
	end
end

function DataManager:SystemBan(PlayerId, Source)
	local Player = Players:GetPlayerByUserId(PlayerId)
	if Player then
		local Profile = cachedProfiles[Player]
		Profile.Data.ServerData.DelayBan = DateTime.now().UnixTimestamp
		Profile.Data.ServerData.BanSource = Source
		Player:Kick("You have been permanently banned from this game.")
		Profile:Release()
		return true
	else
		if not BanQueue[PlayerId] then
			BanQueue[PlayerId] = true

			local profileKey = "Player_" .. PlayerId
			local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
			if not Profile then
				BanQueue[PlayerId] = nil
				return nil
			end
			if Profile.MetaData.ActiveSession then
				print(PlayerId, " active profile session located for system ban")
				BanQueue[PlayerId] = nil
				return false
			else
				local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
				OfflineProfile.Data.ServerData.DelayBan = DateTime.now().UnixTimestamp
				OfflineProfile.Data.ServerData.BanSource = Source
				OfflineProfile:Release()

				BanQueue[PlayerId] = nil
				return true
			end
		end

	end
end

local JailQueue = {}

function DataManager:Jail(PlayerId, Hours)
	if not JailQueue[PlayerId] then
		JailQueue[PlayerId] = true
		
		local profileKey = "Player_" .. PlayerId
		local Profile = GameProfileStore:ViewFullProfileAsync(profileKey)
		if not Profile then
			JailQueue[PlayerId] = nil
			return nil
		end
		
		if Profile.MetaData.ActiveSession then
			print(PlayerId, " active profile session located for jail")
			
			JailQueue[PlayerId] = nil
			return false
		else
			local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
			OfflineProfile.Data.ClientData.JailDuration = Hours
			OfflineProfile.Data.ClientData.JailTime = true
			OfflineProfile:Release()

			JailQueue[PlayerId] = nil
			return true
		end
	end
end

function DataManager:Check32Bit(PlayerId)
	local Player = Players:GetPlayerByUserId(PlayerId)
	if Player then
		local Profile = cachedProfiles[Player]
		warn(Player.Name .. " 32Bit:", Profile.Data.ServerData.Is32Bit)
	else
		local profileKey = "Player_" .. PlayerId
		local Profile = GameProfileStore:ViewProfileAsync(profileKey)
		if Profile then
			warn(profileKey .. " 32Bit:", Profile.Data.ServerData.Is32Bit)
		else
			warn(PlayerId .. " profile nil")
		end
	end
end

function DataManager:Unban(PlayerId, Source)
	local Unbanned
	
	local profileKey = "Player_" .. PlayerId
	local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
	if OfflineProfile.Data.BanSource == Source or table.find(Whitelists.Admin, Source) or table.find(Whitelists.HeadModerator, Source) then
		OfflineProfile.Data.ServerData.Banned = false
		Unbanned = true
	end
	OfflineProfile:Release()
	
	return Unbanned
end

function DataManager:SystemUnban(PlayerId)
	local profileKey = "Player_" .. PlayerId
	local OfflineProfile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
	OfflineProfile.Data.ServerData.DelayBan = nil
	OfflineProfile:Release()
end

function DataManager:FullWipePlayer(Player)
	local Profile = cachedProfiles[Player]
	Profile:Release()
	Player:Kick("Full Wipe Initiated")
	GameProfileStore:WipeProfileAsync("Player_" .. Profile.PlayerId)
end

function DataManager:OfflineWipe(PlayerId)
	local Player = Players:GetPlayerByUserId(PlayerId)
	GameProfileStore:GlobalUpdateProfileAsync(
		"Player_" .. PlayerId,
		function(Global_Updates)
			Global_Updates:AddActiveUpdate({
				Action = "Wipe";
			})
		end
	)
end

function DataManager:OfflineElo(PlayerId, Elo)
	local Player = Players:GetPlayerByUserId(PlayerId)
	GameProfileStore:GlobalUpdateProfileAsync(
		"Player_" .. PlayerId,
		function(Global_Updates)
			Global_Updates:AddActiveUpdate({
				Action = "Elo";
				Amount = Elo;
			})
		end
	)
end

function DataManager:ReiatsuDebuff(PlayerId)
	local Player = Players:GetPlayerByUserId(PlayerId)
	GameProfileStore:GlobalUpdateProfileAsync(
		"Player_" .. PlayerId,
		function(Global_Updates)
			Global_Updates:AddActiveUpdate({
				Action = "ReiatsuDebuff";
			})
		end
	)
end

function DataManager:RemoveReiatsuDebuff(PlayerId)
	local Player = Players:GetPlayerByUserId(PlayerId)
	GameProfileStore:GlobalUpdateProfileAsync(
		"Player_" .. PlayerId,
		function(Global_Updates)
			Global_Updates:AddActiveUpdate({
				Action = "RemoveReiatsuDebuff";
			})
		end
	)
end

function DataManager:Wipe(Player, Message)
	WipeData(Player)
end

--[[function DataManager:Wipe(Player, Message)
	local CurrentTitle = cachedProfiles[Player].Data.ClientData.Title
	local DivisionCaptain = cachedProfiles[Player].Data.Division.Captain
	local Division = cachedProfiles[Player].Data.Division.Squad
	local QuincyMedallionID
	if cachedProfiles[Player].Data.ClientData.QuincyMedallion then
		--QuincyMedallionID = cachedProfiles[Player].Data.ClientData.QuincyMedallion
	elseif cachedProfiles[Player].Data.ClientData.StolenBankai then
		QuincyMedallionID = Player.UserId
	end
	
	cachedProfiles[Player]:Release()
	GameProfileStore:WipeProfileAsync("Player_" .. Player.UserId)
	
	local KickMessage = "Your data has been wiped."
	if Message then
		KickMessage = Message
	end
	
	Player:Kick(KickMessage)
	
	if table.find(PositionTitles.QuincyRankings, CurrentTitle) or table.find(PositionTitles.SoulReaperRankings, CurrentTitle) or table.find(PositionTitles.HollowRankings, CurrentTitle) then
		task.spawn(function()
			if table.find(PositionTitles.SternritterTitles, CurrentTitle) then
				RemoveTitles(Player, "Sternritters", nil, "Player_" .. Player.UserId)
			elseif table.find(PositionTitles.ShinigamiCaptainTitles, CurrentTitle) then
				RemoveTitles(Player, "Captains", Division)
			elseif table.find(PositionTitles.ArrancarEspadaTitles, CurrentTitle) then
				RemoveTitles(Player, "Espadas", Division)
			elseif table.find(PositionTitles.LieutenantUI, CurrentTitle) then
				RemoveTitles(Player, "Lieutenants", Division)
			elseif table.find(PositionTitles.ThirdSeatTitles, CurrentTitle) then
				RemoveTitles(Player, "ThirdSeats", Division)
			elseif CurrentTitle == "Fracción" then
				RemoveTitles(Player, "Fraccion", Division)
			elseif CurrentTitle == "Jagdarmee" then
				RemoveTitles(Player, "Jagdarmee", nil, DivisionCaptain)
			end
		end)
	end
	
	
	if QuincyMedallionID then
		task.spawn(function()
			QuincyMedallions:ResetQuincy(QuincyMedallionID)
		end)
	end
end]]

function DataManager:PlayerAdded(Player)
	local Whitelist = {
		4665346366; -- milkiiiana
		3954269526; 
		4812111635; -- typesoullol
	}
	
	if Player.AccountAge < 31 and not table.find(Whitelist, Player.UserId) then
		Player:Kick("Account age must exceed a month")
		return
	end
	
	local LoadingUI = ReplicatedStorage.Assets.UIs.LoadScreen:Clone()
	LoadingUI.Parent = Player.PlayerGui
	
	local profileKey = "Player_" .. Player.UserId
	local Profile = GameProfileStore:LoadProfileAsync(profileKey, "ForceLoad")
	if Profile ~= nil then
		local OfflineWipe
		for _, Update in ipairs(Profile.GlobalUpdates:GetActiveUpdates()) do
			Profile.GlobalUpdates:LockActiveUpdate(Update[1])
		end
		for _, Update in ipairs(Profile.GlobalUpdates:GetLockedUpdates()) do
			local update_id = Update[1]
			local update_data = Update[2]
			if update_data.Action == "Ban" then
				Profile.Data.ServerData.Banned = true
			elseif update_data.Action == "Unban" then
				Profile.Data.ServerData.Banned = false
			elseif update_data.Action == "Wipe" then
				OfflineWipe = true
			elseif update_data.Action == "ReiatsuDebuff" then
				Profile.Data.ClientData.ReiatsuDebuff = true
			elseif update_data.Action == "RemoveReiatsuDebuff" then
				Profile.Data.ClientData.ReiatsuDebuff = nil
			elseif update_data.Action == "Elo" then
				Profile.Data.ClientData.Elo += update_data.Amount
			end
			Profile.GlobalUpdates:ClearLockedUpdate(update_id)
		end
		
		--Profile:AddUserId(Player.UserId)
		Profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		Profile:ListenToRelease(function()
			cachedProfiles[Player] = nil
			Player:Kick("Profile has been loaded on another server. Please rejoin.") 
		end)
		if Player:IsDescendantOf(Players) then
			cachedProfiles[Player] = Profile

			Profile.GlobalUpdates:ListenToNewActiveUpdate(function(update_id, update_data)
				Profile.GlobalUpdates:LockActiveUpdate(update_id)
			end)
			Profile.GlobalUpdates:ListenToNewLockedUpdate(function(update_id, update_data)
				if update_data.Action == "Unban" then
					Profile.Data.ServerData.Banned = false
				elseif update_data.Action == "Ban" then
					Profile.Data.ServerData.Banned = true
					Player:Kick("You have been permanently banned from this game.")
				elseif update_data.Action == "Wipe" then
					DataManager:Wipe(Player)
				elseif update_data.Action == "ReiatsuDebuff" then
					Profile.Data.ClientData.ReiatsuDebuff = true
					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
						Player.Character:SetAttribute("ReiatsuDebuff", true)
					end
				elseif update_data.Action == "RemoveReiatsuDebuff" then
					Profile.Data.ClientData.ReiatsuDebuff = nil
					if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
						Player.Character:SetAttribute("ReiatsuDebuff", nil)
					end
				elseif update_data.Action == "Elo" then
					Profile.Data.ClientData.Elo += update_data.Amount
				end
				Profile.GlobalUpdates:ClearLockedUpdate(update_id)
			end)
			
			local aes = require(ServerStorage.Modules.Utility.AES256);
			local base64 = require(ServerStorage.Modules.Utility.Base64);

			local function fromHex(str)
				return (str:gsub('..', function (cc)
					return string.char(tonumber(cc, 16));
				end));
			end;

			local key = fromHex('f3d762f46f256d992886f215df78436cf5d998beaf8ca1f3bee7517b526dcf31') -- CHANGE THIS KEY;

			--Modifying TeleportData is not possible due to Roblox using a signed format for the data
			--There is a thread on this on the devforum, but for your sanity I will include checks
			local function checkIfTransferred(player: Player, profile) 
				if profile.Data.dataTransferred then return true; end --If we already transferred/created their data from the old game

				local joinData = player:GetJoinData();
				if joinData.SourcePlaceId == 10604664859 or joinData.SourcePlaceId == 11259125783 then --We can start the decrypting process
					local encryptedData = joinData.TeleportData;

					local b64Decoded = base64.dec(encryptedData);
					local aesDecrypted = aes.decrypt(key, b64Decoded);

					local decodedData = HttpService:JSONDecode(aesDecrypted);
					if not decodedData.userId then return; end --Data may not decode properly due to being modified

					if decodedData.userId ~= player.UserId then return; end --We check if the data was used in a replay attack
					--You can have an additional check if dataTransferred is true, to see if any data is corrupted (it wont be)

					profile.Data = decodedData.data; --All done they now have completed their data transfer
					profile.MetaData.MetaTags = decodedData.metatags;
					return true; --You can let the player play the game now
				end
			end
			
			if not StatData.TYPETEST then
				local Success = checkIfTransferred(Player, Profile)
				if not Success then
					TeleportService:TeleportAsync(10604664859, {Player}) --CHANGE PLACEID: Send them to old game if they have not transferred 
					return
				else
					--print(Player.Name, "data transfer success")
				end
			end
			
			if Profile.Data.ServerData.Banned or Profile.Data.ServerData.DelayBan and Profile.Data.ServerData.DelayBan - DateTime.now().UnixTimestamp <= 0 then
				Profile:Release()
				Player:Kick("You have been permanently banned from this game.")
				print(Player.Name .. " banned from the game, profile has been released")
				return
			end
			
			if OfflineWipe then
				DataManager:Wipe(Player)
				return
			end
			
			LoadingUI:Destroy()

			if StatData.MainMenu then
				local UI = ServerStorage.Assets.UIs.MainMenu:Clone()
				UI.Parent = Player.PlayerGui
				
				if Player.FollowUserId and Player.FollowUserId ~= 0 then
					local Race = Profile.Data.ClientData.Race
					--print("FollowUserId found")
					local CurrentInstance, Error, _, PlaceID, InstanceID = pcall(function()
						return TeleportService:GetPlayerPlaceInstanceAsync(Player.FollowUserId)
					end)
					if CurrentInstance then						
						if Profile.Data.ClientData.LoggedPlace == StatData.Places[PlaceID] then
							Teleports:TeleportParty({Player}, PlaceID, InstanceID)
						elseif Checks[PlaceID][Race] then
							Teleports:TeleportParty({Player}, PlaceID, InstanceID)
						else
							if Profile.Data.ClientData.ShinigamiRank == 12 and Profile.Data.ClientData.Race == "Lost Soul" then
								Teleports:TeleportParty({Player}, StatData.PlaceIDs["Rukon District"])
							else
								Teleports:TeleportParty({Player}, StatData.PlaceIDs["Karakura Town"])
							end
						end
					end
				end
				
				local CurrentTitle = Profile.Data.ClientData.Title
				if table.find(PositionTitles.QuincyRankings, CurrentTitle) or table.find(PositionTitles.SoulReaperRankings, CurrentTitle) or table.find(PositionTitles.HollowRankings, CurrentTitle) then
					task.spawn(function()
						local TitleData

						local Success, Error = pcall(function()
							TitleDataStore:UpdateAsync(StatData.TitleStoreKey, function(oldValue)
								TitleData = oldValue
								return oldValue
							end)
						end)

						if Success then
							local function ClearDivision()
								Profile.Data.Division.Squad = -1
								Profile.Data.Division.Rank = 4
								Profile.Data.Division.Captain = false

								DataManager:RemoveSkill(Player, "Sternritter Command")
								DataManager:RemoveSkill(Player, "Blut Vene 2")
								DataManager:RemoveSkill(Player, "Blut Vene 3")
								DataManager:RemoveItem(Player, "Sternritter Cloak", 1)
								DataManager:RemoveItem(Player, "Hooded Sternritter Cloak", 1)

								DataManager:RemoveItem(Player, "Captain Cloak", 1)
								DataManager:RemoveItem(Player, "Captain Cloak Armless", 1)
								DataManager:RemoveItem(Player, "Lt. Band", 1)
								DataManager:RemoveSkill(Player, "Command")
								DataManager:RemoveSkill(Player, "Espada Command")
								DataManager:RemoveSkill(Player, "Garganta Break")
								DataManager:ModifyProfile(Player, "ClientData", "Title", "")
								
								local SpiritWeapons = {"Schwert"; "Antithesis"; "Cang"; "Cutlass"}
								
								if StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" and not table.find(SpiritWeapons, Profile.Data.ClientData.ZanpakutoWeapon) then
									Profile.Data.ClientData.ZanpakutoWeapon = "Schwert"
									Profile.Data.ClientData.Sheathe = 1
								end
								
								--[[ReplicatedStorage.Remotes.CaptainUIEvent:FireClient(Player, "Disconnect")
								ReplicatedStorage.Remotes.LieutenantUIEvent:FireClient(Player, "Disconnect")

								if Player.Character then
									local Name = GetPlayerName(Player)
	
									Player.Character.Humanoid.DisplayName = Name
								end]]
							end

							if table.find(PositionTitles.SternritterTitles, CurrentTitle) then
								if not TitleData.Sternritters["Player_" .. Player.UserId] then
									ClearDivision()
								end
							elseif table.find(PositionTitles.ShinigamiCaptainTitles, CurrentTitle) then
								local SquadKey = Profile.Data.Division.Squad
								if SquadKey == 0 then
									SquadKey = 14
								end

								if TitleData.Captains[SquadKey] ~= Player.UserId then
									ClearDivision()
								end
							elseif table.find(PositionTitles.ArrancarEspadaTitles, CurrentTitle) then
								local SquadKey = Profile.Data.Division.Squad
								if SquadKey == 0 then
									SquadKey = 11
								end

								if TitleData.Espadas[SquadKey] ~= Player.UserId then
									ClearDivision()
								end
							elseif table.find(PositionTitles.LieutenantUI, CurrentTitle) then
								local SquadKey = Profile.Data.Division.Squad
								if SquadKey == 0 then
									SquadKey = 14
								end

								if TitleData.Lieutenants[SquadKey] ~= Player.UserId then
									ClearDivision()
								end
							elseif table.find(PositionTitles.ThirdSeatTitles, CurrentTitle) then
								local SquadKey = Profile.Data.Division.Squad
								if SquadKey == 0 then
									SquadKey = 14
								end

								if TitleData.ThirdSeats[SquadKey] ~= Player.UserId then
									ClearDivision()
								end
							elseif CurrentTitle == "Fracción" then
								local SquadKey = Profile.Data.Division.Squad
								if SquadKey == 0 then
									SquadKey = 11
								end

								if not table.find(TitleData.Fraccion[SquadKey], Player.UserId) then
									ClearDivision()
								end
							elseif CurrentTitle == "Jagdarmee" then
								if not TitleData.Sternritters[Profile.Data.Division.Captain] or not table.find(TitleData.Sternritters[Profile.Data.Division.Captain], Player.UserId) then
									ClearDivision()
								end
							end
						end
					end)
				end
				
				if Profile.Data.ClientData.StolenBankai or Profile.Data.ClientData.QuincyMedallion then
					task.spawn(function()
						local MedallionID = Profile.Data.ClientData.QuincyMedallion or Player.UserId
						
						if not Profile.Data.ClientData.MedallionTimer then
							Profile.Data.ClientData.MedallionTimer = DateTime.now().UnixTimestamp
						end
						
						local TimeDifference = DateTime.now().UnixTimestamp - Profile.Data.ClientData.MedallionTimer
						local Minutes = TimeDifference / 60
						local Hours = Minutes / 60
						
						if Hours >= StatData.QuincyMedallionTimer then
							QuincyMedallions:ResetQuincy(tostring(MedallionID))
							Profile.Data.ClientData.StolenBankai = nil
							Profile.Data.ClientData.QuincyMedallion = nil
							Profile.Data.ClientData.MedallionTimer = nil
						end
						--[[if QuincyMedallions:CheckMedallionMissing(tostring(MedallionID)) then
							
						end]]
					end)
				end
			else
				local JoinData = Player:GetJoinData()
				local TeleportData = JoinData.TeleportData
				
				if TeleportData and TeleportData.Server or game:GetService("RunService"):IsStudio() then
					if TeleportData and TeleportData.To then
						if Profile.Data.ClientData.LoggedPlace ~= StatData.Places[TeleportData.To] then
							Profile.Data.ClientData.LoggedPosition = false
						end
						
						Profile.Data.ClientData.LoggedPlace = StatData.Places[TeleportData.To] 
					end
					
					local Teleported
					if Profile.Data.ClientData.JailTime then
						local PlaceToJail
						if StatData.Factions[Profile.Data.ClientData.Race] == "Shinigami" then
							PlaceToJail = StatData.PlaceIDs["Soul Society"]
						elseif StatData.Factions[Profile.Data.ClientData.Race] == "Arrancar" then
							PlaceToJail = StatData.PlaceIDs["Hueco Mundo"]
						elseif StatData.Factions[Profile.Data.ClientData.Race] == "Quincy" then
							PlaceToJail = StatData.PlaceIDs["Wandenreich City"]
						end

						if game.PlaceId ~= PlaceToJail then
							Teleported = true
							Teleports:TeleportParty({Player}, PlaceToJail)
						end
					end
					if not Teleported and Profile.Data.ClientData.GlobalRank > 0 and Profile.Data.ClientData.GlobalRank <= StatData.BankaiRequirements.GlobalRank then
						local Whitelist = {
							3427072680; -- haniyura
							400349; -- streak
							300780145; -- invictal
							57431326; -- Khaotxc
							77857290; -- 4Data
							232346707; -- Drakos
							59903508; --cartier361
							194177872; -- ezguap
						};
						
						if not table.find(Whitelist, Player.UserId) then
							if StatData.RukonDistrict or StatData.LasNoches then
								Teleported = true
								Profile.Data.ClientData.LoggedPlace = StatData.Places[StatData.PlaceIDs["Karakura Town"]] 
								Profile:Release()
								Player:Kick("Ranked ban")
								return
							end
						end
					end
					
					if not Teleported then
						if Profile.Data.ClientData.LoggedPlace ~= StatData.Places[game.PlaceId] and not game:GetService("RunService"):IsStudio() then
							Profile:Release()
							Player:Kick("Location mismatch.")
							return
						end

						EntitiesFolderLoaded(Player)
						
						task.spawn(function()
							local Success, Error = pcall(RankedLeaderboards.SetAsync, RankedLeaderboards, Player.UserId, tonumber(math.floor(Profile.Data.ClientData.Elo)))
							if not Success then
								warn("[Ranked Leaderboard Sync Error]:", Error)
							else
								print(Player.Name .. "'s elo successfully synced: " .. Profile.Data.ClientData.Elo)

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

									if Data[tostring(Player.UserId)] then
										DataManager:ModifyProfile(Player, "ClientData", "GlobalRank", Data[tostring(Player.UserId)])
									else
										DataManager:ModifyProfile(Player, "ClientData", "GlobalRank", -1)
									end

									print("[RunserviceChecks]: Successfully synced rank for ", Player.Name)
								else
									warn("[Ranked Leaderboard Page Error]:", Pages)
								end
							end
						end)
						
						--[[if Profile.Data.ClientData.Race == "Vastocar" then
							local WebhookInfo = {
								Message = Player.Name .. " is in " .. StatData.Places[game.PlaceId] .. " " .. Teleports:RetrieveServerName();
							}

							Webhooks:Post(VastoPatrolChannel, WebhookInfo)	
						end]]
					end
					
					print(Player.Name .. "'s profile has successfully loaded")
				else
					Profile:Release()
					Player:Kick("Please join through the Main Menu.")
				end
			end
		else
			print(Player.Name ..  "left before the profile loaded")
			Profile:Release()
		end
	else
		Player:Kick("Data failed to load saved data. Please rejoin.")
	end
end

return DataManager
