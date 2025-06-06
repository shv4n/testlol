-- Services --
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Folders --
local Entities = workspace.Entities
local Effects = ReplicatedStorage.Assets.Effects

-- Modules --
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)

local function SetupInputs()
	local Array = {}
	local ClashInputs = {"Q", "S", "A", "D", "W", "E", "Z", "X", "C"}
	local TotalInputs = 8
	table.insert(Array, ClashInputs[math.random(1, #ClashInputs)])
	for i = 1, TotalInputs do
		local SelectedInput
		repeat 
			SelectedInput = ClashInputs[math.random(1, #ClashInputs)]
		until SelectedInput ~= Array[i - 1]
		table.insert(Array, SelectedInput)
	end
	return Array
end

local HitDetection = {}

function HitDetection:SphereMagnitude(Character, Origin, Properties, NoVictimCone, PartyCheck, HitPosition)
	local Detected = {}
	local ToReturn = false

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Entities}

	local Size = Vector3.new(Properties.Width, Properties.Height, Properties.Range)

	local SpawnPoint = Origin * CFrame.new(0, 0, (-Properties.Range/2) + 1)
	local Results = workspace:GetPartBoundsInBox(SpawnPoint, Size, Params)
	
	local ShowHitbox = false
	if ShowHitbox then
		local Hitbox = Instance.new("Part")
		Hitbox.BrickColor = BrickColor.new("Crimson")
		Hitbox.Material = Enum.Material.Neon
		Hitbox.CanCollide = false
		Hitbox.Transparency = 0.9
		Hitbox.Anchored = true
		Hitbox.CFrame = SpawnPoint
		Hitbox.Size = Size
		Hitbox.Parent = workspace.Effects[Character.Name]
	end
	
	local Player = Players:GetPlayerFromCharacter(Character)
	
	local Client
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
			
			if Detected[Entity] then
				continue
			end
			
			local InParty
			if PartyCheck and Player then
				local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
				if TargetPlayer then
					if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
						InParty = true
					end
				end
			end
			
			if PartyCheck and InParty then
				continue
			end
			if Character:GetAttribute("CheerBuddy") == Entity.Name then
				continue
			end
			
			local ZombieOwner
			if Entity:GetAttribute("ZombieOwner") ~= nil then
				if Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
					ZombieOwner = true
				end
			end
			if Character:GetAttribute("ZombieOwner") == Entity.Name then
				ZombieOwner = true
			end
			
			local Encompass
			local EncompassPosition = Entity:GetAttribute("EncompassPosition")
			if EncompassPosition then
				local EncompassRange = Entity:GetAttribute("EncompassPositionRange")
				local EntityEncompassMagnitude = (Entity.PrimaryPart.Position - EncompassPosition).Magnitude
				local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
				if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
					Encompass = true
					
					if not Client then
						Client = true
						local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
						local PathData = {Module = ClientSkills, Skill = "Encompass"}
						local RenderDistance = 1000
						NetworkManager.FireAllClients(Entity, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
					end
				end
			end
			
			local CharacterBlacklist
			if Entity:GetAttribute("CharacterBlacklist") == Character.Name then
				CharacterBlacklist = true
			end

			if Entity ~= Character and Entity:FindFirstChild("HumanoidRootPart") and Entity.PrimaryPart and Entity:GetAttribute("IFrames") == false and not ZombieOwner and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist then
				local NotInVastoLordeQuest = true
				local VastoLordeQuest = Entity:GetAttribute("VastoLordeQuest")
				if VastoLordeQuest then
					local Player = Players:GetPlayerFromCharacter(Character)
					if Player then
						if VastoLordeQuest ~= Player.UserId then
							NotInVastoLordeQuest = nil
						end
					end
				end
				
				local WhitelistedAttacker = true
				if Entity:GetAttribute("WhitelistedAttacker") and Character.Name ~= Entity:GetAttribute("WhitelistedAttacker") then
					WhitelistedAttacker = nil
				end

				if NotInVastoLordeQuest and WhitelistedAttacker then
					ToReturn = true
					
					local Position = HitPosition or Origin.Position
					local UnitVector = (Entity.PrimaryPart.Position - Position).Unit
					local VictimCone = UnitVector:Dot(Entity.PrimaryPart.CFrame.LookVector)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(Entity)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if Entity:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, Entity.Name .. "EyeOfAKing") or Entity:GetAttribute("FreundReflex") or AversionField then
						Detected[Entity] = "Countered"
					elseif Entity:GetAttribute("EvasiveFrames") then 
						Detected[Entity] = "Evaded"
					elseif Entity:GetAttribute("DeflectFrames") then
						Detected[Entity] = "Deflected"
					elseif VictimCone > 0.3 and not NoVictimCone and not Entity:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
						Detected[Entity] = "BackHit"
					elseif Entity:GetAttribute("BlockFrames")then
						Detected[Entity] = "Blocked"
					elseif Entity:GetAttribute("SoftCounterFrames") then
						Detected[Entity] = "SoftCounter"
					elseif Entity:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}

						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()

						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end

						EntityManager:ChangeState(Entity, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", Entity, Inputs)
						return nil
					else
						Detected[Entity] = "FrontalHit"
					end
				end
			end
		end
	end

	if ToReturn then
		return Detected
	end
end

function HitDetection:SphereMagnitudeCheck(Character, Origin, Properties, NoVictimCone)
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do -- Loops through all the entities inside the live folder than contains players / NPC's
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		if Character:GetAttribute("CheerBuddy") == v.Name then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end

		if v.PrimaryPart and v:GetAttribute("IFrames") == false and WhitelistedAttacker and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			local Result = (v.PrimaryPart.Position - Origin.Position).Magnitude < Properties.Range -- Range of the semi sphere
			if Properties.Length then -- Length of the semi sphere (Too large a value can make the hit detection detect behind the player)
				Result = Result and (Origin:Inverse() * v.PrimaryPart.CFrame).Z < Properties.Length
			end
			if Properties.Width then
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).X) < Properties.Width -- Width of the semi sphere
			end
			if Properties.Height then 
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).Y) < Properties.Height -- Height of the semi sphere
			end
			if Result or (v.PrimaryPart.Position - Origin.Position).Magnitude <= SecondHitbox then -- Above detection returned true (means an entity was detected)
				if Character and v ~= Character then
					ToReturn = true					
					local UnitVector = (v.PrimaryPart.Position - Origin.Position).Unit
					local VictimCone = UnitVector:Dot(v.PrimaryPart.CFrame.LookVector)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(v)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if v:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, v.Name .. "EyeOfAKing") or v:GetAttribute("FreundReflex") or AversionField then
						Detected[v] = "Countered"
					elseif v:GetAttribute("EvasiveFrames") then 
						Detected[v] = "Evaded"
					elseif v:GetAttribute("DeflectFrames") then
						Detected[v] = "Deflected"
					elseif VictimCone > 0.3 and not NoVictimCone and not v:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
						Detected[v] = "BackHit"
					elseif v:GetAttribute("BlockFrames")then
						Detected[v] = "Blocked"
					elseif v:GetAttribute("SoftCounterFrames") then
						Detected[v] = "SoftCounter"
					elseif v:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}

						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()

						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end

						EntityManager:ChangeState(v, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", v, Inputs)
						return nil
					else
						Detected[v] = "FrontalHit"
					end
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

--[[function HitDetection:SphereMagnitude(Character, Origin, Properties, NoVictimCone)	
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do -- Loops through all the entities inside the live folder than contains players / NPC's
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and NotInVastoLordeQuest and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			local Result = (v.PrimaryPart.Position - Origin.Position).Magnitude < Properties.Range -- Range of the semi sphere
			if Properties.Length then -- Length of the semi sphere (Too large a value can make the hit detection detect behind the player)
				Result = Result and (Origin:Inverse() * v.PrimaryPart.CFrame).Z < Properties.Length
			end
			if Properties.Width then
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).X) < Properties.Width -- Width of the semi sphere
			end
			if Properties.Height then 
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).Y) < Properties.Height -- Height of the semi sphere
			end
			if Result or (v.PrimaryPart.Position - Origin.Position).Magnitude <= SecondHitbox then -- Above detection returned true (means an entity was detected)
				if Character and v ~= Character then
					ToReturn = true					
					local UnitVector = (v.PrimaryPart.Position - Origin.Position).Unit
					local VictimCone = UnitVector:Dot(v.PrimaryPart.CFrame.LookVector)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(v)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if v:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, v.Name .. "EyeOfAKing") or v:GetAttribute("FreundReflex") or AversionField then
						Detected[v] = "Countered"
					elseif v:GetAttribute("EvasiveFrames") then 
						Detected[v] = "Evaded"
					elseif v:GetAttribute("DeflectFrames") then
						Detected[v] = "Deflected"
					elseif VictimCone > 0.3 and not NoVictimCone then -- Checks if they are behind the enemy or not
						Detected[v] = "BackHit"
					elseif v:GetAttribute("BlockFrames")then
						Detected[v] = "Blocked"
					elseif v:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}
							
						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()
						
						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end
						
						EntityManager:ChangeState(v, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", v, Inputs)
						return nil
					else
						Detected[v] = "FrontalHit"
					end
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end]]

function HitDetection:Magnitude(Character, MagnitudeCenter, Range, PartyCheck, Height, NoVictimCone, UnconsciousBlacklist)
	local Detected = {}
	local ToReturn = false
	local Player = Players:GetPlayerFromCharacter(Character)
	for i, v in ipairs(workspace.Entities:GetChildren()) do
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		
		local NotInParty = true
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		if Character:GetAttribute("CheerBuddy") == v.Name then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local NoUnconsciousFilter = true
		if UnconsciousBlacklist and v:GetAttribute("CurrentState") == "Unconscious" then
			NoUnconsciousFilter = nil
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and WhitelistedAttacker and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist and NoUnconsciousFilter then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			if PartyCheck and Player then
				local TargetPlayer = Players:GetPlayerFromCharacter(v)
				if TargetPlayer then
					if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
						NotInParty = nil
					end
				end
			end
			
			local AboveHeight
			if Height and math.abs(v.PrimaryPart.Position.Y - MagnitudeCenter.Y) > Height then
				AboveHeight = true
			end
			
			if v:FindFirstChild("HumanoidRootPart") and v ~= Character and NotInParty then	
				if ((v.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range and not AboveHeight) or ((v.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox and not AboveHeight) then
					ToReturn = true
					
					local UnitVector = (v.PrimaryPart.Position - MagnitudeCenter).Unit
					local VictimLook = v.PrimaryPart.CFrame.LookVector
					local VictimCone = UnitVector:Dot(VictimLook)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(v)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if v:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, v.Name .. "EyeOfAKing") or v:GetAttribute("FreundReflex") or AversionField then
						Detected[v] = "Countered"
					elseif v:GetAttribute("EvasiveFrames") then 
						Detected[v] = "Evaded"
					elseif v:GetAttribute("DeflectFrames") then
						Detected[v] = "Deflected"
					elseif VictimCone > 0.3 and not NoVictimCone and not v:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
						Detected[v] = "BackHit"
					elseif v:GetAttribute("BlockFrames")then
						Detected[v] = "Blocked"
					elseif v:GetAttribute("SoftCounterFrames") then
						Detected[v] = "SoftCounter"
					elseif v:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}
						
						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()

						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end

						EntityManager:ChangeState(v, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", v, Inputs)
						return nil
					else
						Detected[v] = "FrontalHit"
					end	
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:LookMagnitude(Character, MagnitudeCenter, Range, PartyCheck)
	local Player = Players:GetPlayerFromCharacter(Character)
	
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		local NotInParty = true
		if PartyCheck and Player then
			local TargetPlayer = Players:GetPlayerFromCharacter(v)
			if TargetPlayer then
				if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
					NotInParty = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		if Character:GetAttribute("CheerBuddy") == v.Name then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and WhitelistedAttacker and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and NotInParty and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			if v:FindFirstChild("HumanoidRootPart") and v ~= Character then	
				if (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range or (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox then
					ToReturn = true

					local UnitVector = (v.PrimaryPart.Position - MagnitudeCenter).Unit
					local VictimLook = v.PrimaryPart.CFrame.LookVector
					local VictimCone = UnitVector:Dot(VictimLook)

					if VictimCone < 0.3 then -- Checks if their character is facing MagnitudeCenter
						Detected[v] = "FrontalHit"
					else
						Detected[v] = "Blocked"
					end	
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:Ring(Character, MagnitudeCenter, Range, RingSize, NoVictimCone)
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and WhitelistedAttacker and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			if v:FindFirstChild("HumanoidRootPart") and v ~= Character then	
				if (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range or (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox then
					if (v.PrimaryPart.Position - MagnitudeCenter).Magnitude > (Range - RingSize) then
						ToReturn = true
						
						local UnitVector = (v.PrimaryPart.Position - MagnitudeCenter).Unit
						local VictimLook = v.PrimaryPart.CFrame.LookVector
						local VictimCone = UnitVector:Dot(VictimLook)
						
						local AversionField
						local CurrentTags = CollectionService:GetTags(v)
						if CurrentTags and #CurrentTags > 0 then
							for _, Tag in ipairs(CurrentTags) do
								if Tag:match("AversionField") then
									AversionField = true
									break
								end
							end
						end
						
						if v:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, v.Name .. "EyeOfAKing") or v:GetAttribute("FreundReflex") or AversionField then
							Detected[v] = "Countered"
						elseif v:GetAttribute("EvasiveFrames") then 
							Detected[v] = "Evaded"
						elseif v:GetAttribute("DeflectFrames") then
							Detected[v] = "Deflected"
						elseif VictimCone > 0.3 and not NoVictimCone and not v:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
							Detected[v] = "BackHit"
						elseif v:GetAttribute("BlockFrames")then
							Detected[v] = "Blocked"
						elseif v:GetAttribute("SoftCounterFrames") then
							Detected[v] = "SoftCounter"
						elseif v:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
							local Inputs = {}

							Inputs.Set1 = SetupInputs()
							Inputs.Set2 = SetupInputs()

							local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
							if DashForce then
								DashForce:Destroy()
								DashForce = nil
							end

							EntityManager:ChangeState(v, "TriggerClashing", Character, Inputs)
							EntityManager:ChangeState(Character, "TriggerClashing", v, Inputs)
							return nil
						else
							Detected[v] = "FrontalHit"
						end	
					end
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:FocusTarget(Character, Target, NoVictimCone, Position)
	local HitType
	
	local Encompass
	local EncompassPosition = Target:GetAttribute("EncompassPosition")
	if EncompassPosition then
		local EncompassRange = Target:GetAttribute("EncompassPositionRange")
		local EntityEncompassMagnitude = (Target.PrimaryPart.Position - EncompassPosition).Magnitude
		local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
		if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
			Encompass = true
			
			local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
			local PathData = {Module = ClientSkills, Skill = "Encompass"}
			local RenderDistance = 1000
			NetworkManager.FireAllClients(Target, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
		end
	end
	
	if Target.PrimaryPart and Target:GetAttribute("IFrames") == false and not Target:GetAttribute("TrueIFrames") and not Target:GetAttribute("Teleporting") and not Encompass then	
		local RootPosition = Position or Character.HumanoidRootPart.Position
		local UnitVector = (Target.HumanoidRootPart.Position - RootPosition).Unit
		local VictimLook = Target.HumanoidRootPart.CFrame.LookVector
		local VictimCone = UnitVector:Dot(VictimLook)
		
		local AversionField
		local CurrentTags = CollectionService:GetTags(Target)
		if CurrentTags and #CurrentTags > 0 then
			for _, Tag in ipairs(CurrentTags) do
				if Tag:match("AversionField") then
					AversionField = true
					break
				end
			end
		end

		if Target:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, Target.Name .. "EyeOfAKing") or Target:GetAttribute("FreundReflex") or AversionField then
			HitType = "Countered"
		else
			if Target:GetAttribute("EvasiveFrames") then 
				HitType = "Evaded"
			elseif Target:GetAttribute("DeflectFrames") then
				HitType = "Deflected"
			elseif VictimCone > 0.3 and not NoVictimCone and not Target:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
				HitType = "BackHit"
			elseif Target:GetAttribute("BlockFrames")then
				HitType = "Blocked"
			elseif Target:GetAttribute("SoftCounterFrames") then
				HitType = "SoftCounter"
			else
				HitType = "FrontalHit"
			end				
		end
	end
	return HitType
end

function HitDetection:SelfMagnitude(MagnitudeCenter, Range, Height)
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do
		if v.PrimaryPart  then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			
			local AboveHeight
			if Height and math.abs(v.PrimaryPart.Position.Y - MagnitudeCenter.Y) > Height then
				AboveHeight = true
			end
			
			if v:FindFirstChild("HumanoidRootPart") and not AboveHeight then	
				if (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range or (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox then
					ToReturn = true
					table.insert(Detected, v)
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:RingSphereMagnitude(Character, Origin, Properties)	
	local Detected = {}
	local ToReturn = false
	for i, v in ipairs(workspace.Entities:GetChildren()) do -- Loops through all the entities inside the live folder than contains players / NPC's
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		if Character:GetAttribute("CheerBuddy") == v.Name then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and WhitelistedAttacker and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			local Result = (v.PrimaryPart.Position - Origin.Position).Magnitude < Properties.Range -- Range of the semi sphere
			Result = Result and (v.PrimaryPart.Position - Origin.Position).Magnitude > Properties.SemiRingSize -- Under this ring is not detected
			if Properties.Length then -- Length of the semi sphere (Too large a value can make the hit detection detect behind the player)
				Result = Result and (Origin:Inverse() * v.PrimaryPart.CFrame).Z < Properties.Length
			end
			if Properties.Width then
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).X) < Properties.Width -- Width of the semi sphere
			end
			if Properties.Height then 
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).Y) < Properties.Height -- Height of the semi sphere
			end
			if Result or (v.PrimaryPart.Position - Origin.Position).Magnitude <= SecondHitbox then -- Above detection returned true (means an entity was detected)
				if Character and v ~= Character then
					ToReturn = true					
					local UnitVector = (v.PrimaryPart.Position - Origin.Position).Unit
					local VictimCone = UnitVector:Dot(v.PrimaryPart.CFrame.LookVector)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(v)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if v:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, v.Name .. "EyeOfAKing") or v:GetAttribute("FreundReflex") or AversionField then
						Detected[v] = "Countered"
					elseif v:GetAttribute("EvasiveFrames") then 
						Detected[v] = "Evaded"
					elseif v:GetAttribute("DeflectFrames") then
						Detected[v] = "Deflected"
					elseif VictimCone > 0.3 and not v:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
						Detected[v] = "BackHit"
					elseif v:GetAttribute("BlockFrames")then
						Detected[v] = "Blocked"
					elseif v:GetAttribute("SoftCounterFrames") then
						Detected[v] = "SoftCounter"
					elseif v:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}

						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()

						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end

						EntityManager:ChangeState(v, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", v, Inputs)
						return nil
					else
						Detected[v] = "FrontalHit"
					end
				end
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:VelocityRadiusCheck(Character, BodyVelocity, Properties)
	local Accumulated = 0
	local Rate = 0.05
	local RadiusCheck
	RadiusCheck = RunService.Heartbeat:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		if Accumulated > Rate then
			Accumulated -= Rate
			for _, v in ipairs(workspace.Entities:GetChildren()) do
				if v.PrimaryPart and v ~= Character and v:GetAttribute("IFrames") == false and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") then
					local Origin = Character.PrimaryPart.CFrame
					local Result = (v.PrimaryPart.Position - Origin.Position).Magnitude < Properties.Range -- Range
					Result = Result and (Origin:Inverse() * v.PrimaryPart.CFrame).Z < Properties.Length
					Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).X) < Properties.Width -- Width
					Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).Y) < Properties.Height -- Height
					if Result then
						if BodyVelocity then
							BodyVelocity:Destroy()
							BodyVelocity = nil
						end
					end
				end
			end
		end
	end)

	local BodyVelocityDestroying
	BodyVelocityDestroying = BodyVelocity.Destroying:Connect(function()
		RadiusCheck:Disconnect()
		RadiusCheck = nil
		BodyVelocityDestroying:Disconnect()
		BodyVelocityDestroying = nil
	end)
end

function HitDetection:SortClosestFromDetection(Character, Detection, Blacklist, AttributeBlacklist)
	local NearestEntity, EntityHitType, NearestDistance
	for Entity, HitType in pairs(Detection) do
		local Immune
		if Blacklist and table.find(Blacklist, Entity) then
			Immune = true
		end
		if AttributeBlacklist then
			for _, Attribute in ipairs(AttributeBlacklist) do
				if Entity:GetAttribute(Attribute) ~= nil then
					Immune = true
					break
				end
			end
		end
		
		if Entity.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		
		if Entity ~= Character and Entity.PrimaryPart and Entity:FindFirstChild("Humanoid") and Entity:GetAttribute("IFrames") == false and not Immune and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Teleporting") then
			local Magnitude = (Character.PrimaryPart.Position - Entity.PrimaryPart.Position).Magnitude
			if not NearestEntity then -- Checks if there is not a target stored in the variable otherwise it will compare to nil and error 
				NearestEntity, EntityHitType, NearestDistance = Entity, HitType, Magnitude
			else
				if Magnitude < NearestDistance then
					NearestEntity, EntityHitType, NearestDistance = Entity, HitType, Magnitude
				end
			end		
		end
	end
	return NearestEntity, EntityHitType
end

function HitDetection:FilterDebuffs(Character, Detection, Debuff)
	local Detected = {}
	local ToReturn = false
	for Entity, HitType in pairs(Detection) do
		if Entity:FindFirstChild("HumanoidRootPart") and Entity ~= Character then
			if Entity:GetAttribute(Debuff) then
				ToReturn = true
				Detected[Entity] = HitType
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:FilterPositiveHitDebuffs(Character, PositiveHits, Debuff)
	local Detected = {}
	local ToReturn = false
	for _, Entity in ipairs(PositiveHits) do
		if Entity:FindFirstChild("HumanoidRootPart") and Entity ~= Character then
			if Entity:GetAttribute(Debuff) then
				ToReturn = true
				Detected[Entity] = "FrontalHit"
			end
		end
	end
	if ToReturn then
		return Detected
	end
end

function HitDetection:NearestSphereMagnitude(Character, Origin, Properties, PartyCheck, UnconsciousBlacklist, Blacklist, AttributeBlacklist)
	local Player = Players:GetPlayerFromCharacter(Character)
	local NearestEntity, NearestDistance

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Entities}

	local Size = Vector3.new(Properties.Width, Properties.Height, Properties.Range)
	
	local SpawnPoint = Origin * CFrame.new(0, 0, (-Properties.Range/2) + 1)
	local Results = workspace:GetPartBoundsInBox(SpawnPoint, Size, Params)	
	
	local Detected = {}
	local Client
	for _, Part in ipairs(Results) do
		local Humanoid = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")
		if Humanoid then
			local Entity = Humanoid.Parent
			
			if Entity.Parent ~= workspace.Entities then
				continue
			end
			
			if Entity.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
				continue
			end
			
			local ZombieOwner
			if Entity:GetAttribute("ZombieOwner") ~= nil then
				if Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
					ZombieOwner = true
				end
			end
			if Character:GetAttribute("ZombieOwner") == Entity.Name then
				ZombieOwner = true
			end
			if Character:GetAttribute("CheerBuddy") == Entity.Name then
				continue
			end
			
			local Encompass
			local EncompassPosition = Entity:GetAttribute("EncompassPosition")
			if EncompassPosition then
				local EncompassRange = Entity:GetAttribute("EncompassPositionRange")
				local EntityEncompassMagnitude = (Entity.PrimaryPart.Position - EncompassPosition).Magnitude
				local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
				if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
					Encompass = true
					
					if not Client then
						Client = true
						local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
						local PathData = {Module = ClientSkills, Skill = "Encompass"}
						local RenderDistance = 1000
						NetworkManager.FireAllClients(Entity, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
					end
				end
			end
			
			local CharacterBlacklist
			if Entity:GetAttribute("CharacterBlacklist") == Character.Name then
				CharacterBlacklist = true
			end
			
			local Immune
			if Blacklist and table.find(Blacklist, Entity) then
				Immune = true
			end
			if AttributeBlacklist then
				for _, Attribute in ipairs(AttributeBlacklist) do
					if Entity:GetAttribute(Attribute) ~= nil then
						Immune = true
						break
					end
				end
			end
			
			if Entity ~= Character and Entity:FindFirstChild("HumanoidRootPart") and Entity.PrimaryPart and Entity:GetAttribute("IFrames") == false and not Detected[Entity] and not ZombieOwner and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist and not Immune then
				local NotInParty = true
				if PartyCheck and Player then
					local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
					if TargetPlayer then
						if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
							NotInParty = nil
						end
					end
				end

				local NotInVastoLordeQuest = true
				local VastoLordeQuest = Entity:GetAttribute("VastoLordeQuest")
				if VastoLordeQuest then
					local Player = Players:GetPlayerFromCharacter(Character)
					if Player then
						if VastoLordeQuest ~= Player.UserId then
							NotInVastoLordeQuest = nil
						end
					end
				end
				
				local NoUnconsciousFilter = true
				if UnconsciousBlacklist and Entity:GetAttribute("CurrentState") == "Unconscious" then
					NoUnconsciousFilter = nil
				end
				
				local WhitelistedAttacker = true
				if Entity:GetAttribute("WhitelistedAttacker") and Character.Name ~= Entity:GetAttribute("WhitelistedAttacker") then
					WhitelistedAttacker = nil
				end
				
				if NotInVastoLordeQuest and NotInParty and NoUnconsciousFilter and WhitelistedAttacker then
					Detected[Entity] = true
					
					local Magnitude = (Character.PrimaryPart.Position - Entity.PrimaryPart.Position).Magnitude
					if not NearestEntity then 
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
	
	return NearestEntity
end

--[[function HitDetection:NearestSphereMagnitude(Character, Origin, Properties, PartyCheck)
	local Player = Players:GetPlayerFromCharacter(Character)
	local NearestEntity, NearestDistance
	for i, v in pairs(workspace.Entities:GetChildren()) do -- Loops through all the entities inside the live folder than contains players / NPC's
		local NotInParty = true
		if PartyCheck and Player then
			local TargetPlayer = Players:GetPlayerFromCharacter(v)
			if TargetPlayer then
				if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
					NotInParty = nil
				end
			end
		end
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.PrimaryPart and v:GetAttribute("IFrames") == false and NotInVastoLordeQuest and NotInParty and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			local Result = (v.PrimaryPart.Position - Origin.Position).Magnitude < Properties.Range -- Range of the semi sphere
			if Properties.Length then -- Length of the semi sphere (Too large a value can make the hit detection detect behind the player)
				Result = Result and (Origin:Inverse() * v.PrimaryPart.CFrame).Z < Properties.Length
			end
			if Properties.Width then
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).X) < Properties.Width -- Width of the semi sphere
			end
			if Properties.Height then 
				Result = Result and math.abs((Origin:Inverse() * v.PrimaryPart.CFrame).Y) < Properties.Height -- Height of the semi sphere
			end
			if Result or (v.PrimaryPart.Position - Origin.Position).Magnitude <= SecondHitbox then -- Above detection returned true (means an entity was detected)
				if Character and v ~= Character then
					local Magnitude = (Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
					if not NearestEntity then -- Checks if there is not a target stored in the variable otherwise it will compare to nil and error 
						NearestEntity, NearestDistance = v, Magnitude
					else
						if Magnitude < NearestDistance then
							NearestEntity, NearestDistance = v, Magnitude
						end
					end				
				end
			end
		end
	end
	return NearestEntity
end]]

function HitDetection:NearestMagnitude(Character, MagnitudeCenter, Range, PartyCheck, UnconsciousBlacklist, Blacklist, AttributeBlacklist)
	local Player = Players:GetPlayerFromCharacter(Character)
	local NearestEntity, NearestDistance
	for i, v in pairs(workspace.Entities:GetChildren()) do
		local ZombieOwner
		if v:GetAttribute("ZombieOwner") ~= nil then
			if v:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
				ZombieOwner = true
			end
		end
		if Character:GetAttribute("ZombieOwner") == v.Name then
			ZombieOwner = true
		end
		
		local NotInParty = true
		if PartyCheck and Player then
			local TargetPlayer = Players:GetPlayerFromCharacter(v)
			if TargetPlayer then
				if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
					NotInParty = nil
				end
			end
		end
		
		local NotInVastoLordeQuest = true
		local VastoLordeQuest = v:GetAttribute("VastoLordeQuest")
		if VastoLordeQuest then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player then
				if VastoLordeQuest ~= Player.UserId then
					NotInVastoLordeQuest = nil
				end
			end
		end
		
		if v.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
			continue
		end
		if Character:GetAttribute("CheerBuddy") == v.Name then
			continue
		end
		
		local Encompass
		local EncompassPosition = v:GetAttribute("EncompassPosition")
		if EncompassPosition then
			local EncompassRange = v:GetAttribute("EncompassPositionRange")
			local EntityEncompassMagnitude = (v.PrimaryPart.Position - EncompassPosition).Magnitude
			local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
			if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
				Encompass = true
				
				local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
				local PathData = {Module = ClientSkills, Skill = "Encompass"}
				local RenderDistance = 1000
				NetworkManager.FireAllClients(v, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
			end
		end
		
		local CharacterBlacklist
		if v:GetAttribute("CharacterBlacklist") == Character.Name then
			CharacterBlacklist = true
		end
		
		local Immune
		if Blacklist and table.find(Blacklist, v) then
			Immune = true
		end
		if AttributeBlacklist then
			for _, Attribute in ipairs(AttributeBlacklist) do
				if v:GetAttribute(Attribute) ~= nil then
					Immune = true
					break
				end
			end
		end
		
		local NoUnconsciousFilter = true
		if UnconsciousBlacklist and v:GetAttribute("CurrentState") == "Unconscious" then
			NoUnconsciousFilter = nil
		end
		
		local WhitelistedAttacker = true
		if v:GetAttribute("WhitelistedAttacker") and Character.Name ~= v:GetAttribute("WhitelistedAttacker") then
			WhitelistedAttacker = nil
		end
		
		if v.PrimaryPart and v:FindFirstChild("HumanoidRootPart") and WhitelistedAttacker and v ~= Character and v:GetAttribute("IFrames") == false and NotInParty and NotInVastoLordeQuest and not ZombieOwner and not v:GetAttribute("TrueIFrames") and not v:GetAttribute("Teleporting") and not Encompass and not CharacterBlacklist and not Immune and NoUnconsciousFilter then
			local SecondHitbox = 3.7
			if v:GetAttribute("EntityType") == "Menos" then
				SecondHitbox = 20
			end
			if (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range or (v.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox then
				local Magnitude = (Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
				if not NearestEntity then -- Checks if there is not a target stored in the variable otherwise it will compare to nil and error 
					NearestEntity, NearestDistance = v, Magnitude
				else
					if Magnitude < NearestDistance then
						NearestEntity, NearestDistance = v, Magnitude
					end
				end	
			end
		end
	end
	return NearestEntity
end

function HitDetection:GetPartBoundsInBox(Character, Origin, Properties, NoVictimCone, Blacklist, UnconsciousBlacklist)
	local Detected = {}
	local ToReturn = false
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Entities}
	
	local Size = Vector3.new(Properties.Width, Properties.Height, Properties.Range)
	
	local SpawnPoint = Origin * CFrame.new(0, 0, (-Properties.Range/2) + 1)
	local Results = workspace:GetPartBoundsInBox(SpawnPoint, Size, Params)
	local Client
	for _, Part in ipairs(Results) do
		local Humanoid = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")
		if Humanoid then
			local Entity = Humanoid.Parent
			
			if Entity.Parent ~= workspace.Entities then
				continue
			end
			if Entity.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
				continue
			end
			if Detected[Entity] then
				continue
			end
			if Blacklist and table.find(Blacklist, Entity) then
				continue
			end
			if Character:GetAttribute("CheerBuddy") == Entity.Name then
				continue
			end
			
			local ZombieOwner
			if Entity:GetAttribute("ZombieOwner") ~= nil then
				if Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
					ZombieOwner = true
				end
			end
			if Character:GetAttribute("ZombieOwner") == Entity.Name then
				ZombieOwner = true
			end
			
			local Encompass
			local EncompassPosition = Entity:GetAttribute("EncompassPosition")
			if EncompassPosition then
				local EncompassRange = Entity:GetAttribute("EncompassPositionRange")
				local EntityEncompassMagnitude = (Entity.PrimaryPart.Position - EncompassPosition).Magnitude
				local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
				if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
					Encompass = true
					
					if not Client then
						Client = true
						local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
						local PathData = {Module = ClientSkills, Skill = "Encompass"}
						local RenderDistance = 1000
						NetworkManager.FireAllClients(Entity, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
					end
				end
			end
			
			local NoUnconsciousFilter = true
			if UnconsciousBlacklist and Entity:GetAttribute("CurrentState") == "Unconscious" then
				NoUnconsciousFilter = nil
			end
			
			local CharacterBlacklist
			if Entity:GetAttribute("CharacterBlacklist") == Character.Name then
				CharacterBlacklist = true
			end
			
			local WhitelistedAttacker = true
			if Entity:GetAttribute("WhitelistedAttacker") and Character.Name ~= Entity:GetAttribute("WhitelistedAttacker") then
				WhitelistedAttacker = nil
			end
			
			if Entity ~= Character and Entity.PrimaryPart and WhitelistedAttacker and Entity:FindFirstChild("HumanoidRootPart") and Entity:GetAttribute("IFrames") == false and not ZombieOwner and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Teleporting") and not Encompass and NoUnconsciousFilter and not CharacterBlacklist then
				local NotInVastoLordeQuest = true
				local VastoLordeQuest = Entity:GetAttribute("VastoLordeQuest")
				if VastoLordeQuest then
					local Player = Players:GetPlayerFromCharacter(Character)
					if Player then
						if VastoLordeQuest ~= Player.UserId then
							NotInVastoLordeQuest = nil
						end
					end
				end
				
				if NotInVastoLordeQuest then
					ToReturn = true

					local UnitVector = (Entity.PrimaryPart.Position - Origin.Position).Unit
					local VictimCone = UnitVector:Dot(Entity.PrimaryPart.CFrame.LookVector)
					
					local AversionField
					local CurrentTags = CollectionService:GetTags(Entity)
					if CurrentTags and #CurrentTags > 0 then
						for _, Tag in ipairs(CurrentTags) do
							if Tag:match("AversionField") then
								AversionField = true
								break
							end
						end
					end
					
					if Entity:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, Entity.Name .. "EyeOfAKing") or Entity:GetAttribute("FreundReflex") or AversionField then
						Detected[Entity] = "Countered"
					elseif Entity:GetAttribute("EvasiveFrames") then 
						Detected[Entity] = "Evaded"
					elseif Entity:GetAttribute("DeflectFrames") then
						Detected[Entity] = "Deflected"
					elseif VictimCone > 0.3 and not NoVictimCone and not Entity:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
						Detected[Entity] = "BackHit"
					elseif Entity:GetAttribute("BlockFrames")then
						Detected[Entity] = "Blocked"
					elseif Entity:GetAttribute("SoftCounterFrames") then
						Detected[Entity] = "SoftCounter"
					elseif Entity:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
						local Inputs = {}

						Inputs.Set1 = SetupInputs()
						Inputs.Set2 = SetupInputs()

						local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
						if DashForce then
							DashForce:Destroy()
							DashForce = nil
						end

						EntityManager:ChangeState(Entity, "TriggerClashing", Character, Inputs)
						EntityManager:ChangeState(Character, "TriggerClashing", Entity, Inputs)
						return nil
					else
						Detected[Entity] = "FrontalHit"
					end
				end
			end
		end
	end
	
	if ToReturn then
		return Detected
	end
end

function HitDetection:GetPartBoundsInRadius(Character, MagnitudeCenter, Range, PartyCheck, Height, NoVictimCone, UnconsciousBlacklist)
	local Detected = {}
	local ToReturn = false
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = {workspace.Entities}
	
	local Results = workspace:GetPartBoundsInRadius(MagnitudeCenter, Range, Params)
	local Client
	local Player = Players:GetPlayerFromCharacter(Character)
	for _, Part in ipairs(Results) do
		local Humanoid = Part.Parent:FindFirstChild("Humanoid") or Part.Parent.Parent:FindFirstChild("Humanoid")
		if Humanoid then
			local Entity = Humanoid.Parent
			
			if Entity.Parent ~= workspace.Entities then
				continue
			end
			if Entity.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
				continue
			end
			if Detected[Entity] then
				continue
			end
			if Character:GetAttribute("CheerBuddy") == Entity.Name then
				continue
			end
			
			local ZombieOwner
			if Entity:GetAttribute("ZombieOwner") ~= nil then
				if Entity:GetAttribute("ZombieOwner") == Character:GetAttribute("ZombieOwner") then
					ZombieOwner = true
				end
			end
			if Character:GetAttribute("ZombieOwner") == Entity.Name then
				ZombieOwner = true
			end
			
			local Encompass
			local EncompassPosition = Entity:GetAttribute("EncompassPosition")
			if EncompassPosition then
				local EncompassRange = Entity:GetAttribute("EncompassPositionRange")
				local EntityEncompassMagnitude = (Entity.PrimaryPart.Position - EncompassPosition).Magnitude
				local CharacterEncompassMagnitude = (Character.PrimaryPart.Position - EncompassPosition).Magnitude
				if EntityEncompassMagnitude <= EncompassRange and CharacterEncompassMagnitude > EncompassRange then
					Encompass = true
					
					if not Client then
						Client = true
						local ClientSkills = ReplicatedStorage.Modules.ClientModules.ClientSkills
						local PathData = {Module = ClientSkills, Skill = "Encompass"}
						local RenderDistance = 1000
						NetworkManager.FireAllClients(Entity, "ClientEffects", RenderDistance, PathData, "2", nil, nil, Character)
					end
				end
			end
			
			local NoUnconsciousFilter = true
			if UnconsciousBlacklist and Entity:GetAttribute("CurrentState") == "Unconscious" then
				NoUnconsciousFilter = nil
			end
			
			local CharacterBlacklist
			if Entity:GetAttribute("CharacterBlacklist") == Character.Name then
				CharacterBlacklist = true
			end
			
			local WhitelistedAttacker = true
			if Entity:GetAttribute("WhitelistedAttacker") and Character.Name ~= Entity:GetAttribute("WhitelistedAttacker") then
				WhitelistedAttacker = nil
			end
			
			if Entity ~= Character and Entity.PrimaryPart and WhitelistedAttacker and Entity:FindFirstChild("HumanoidRootPart") and Entity:GetAttribute("IFrames") == false and not ZombieOwner and not Entity:GetAttribute("TrueIFrames") and not Entity:GetAttribute("Teleporting") and not Encompass and NoUnconsciousFilter and not CharacterBlacklist then
				local NotInParty = true
				local NotInVastoLordeQuest = true
				local VastoLordeQuest = Entity:GetAttribute("VastoLordeQuest")
				if VastoLordeQuest then
					local Player = Players:GetPlayerFromCharacter(Character)
					if Player then
						if VastoLordeQuest ~= Player.UserId then
							NotInVastoLordeQuest = nil
						end
					end
				end

				if NotInVastoLordeQuest then
					local SecondHitbox = 3.7
					if Entity:GetAttribute("EntityType") == "Menos" then
						SecondHitbox = 20
					end
					if PartyCheck and Player then
						local TargetPlayer = Players:GetPlayerFromCharacter(Entity)
						if TargetPlayer then
							if Player:GetAttribute("Party") and TargetPlayer:GetAttribute("Party") == Player:GetAttribute("Party") then
								NotInParty = nil
							end
						end
					end

					local AboveHeight
					if Height and math.abs(Entity.PrimaryPart.Position.Y - MagnitudeCenter.Y) > Height then
						AboveHeight = true
					end

					if NotInParty then	
						if ((Entity.PrimaryPart.Position - MagnitudeCenter).Magnitude < Range and not AboveHeight) or ((Entity.PrimaryPart.Position - MagnitudeCenter).Magnitude < SecondHitbox and not AboveHeight) then
							ToReturn = true

							local UnitVector = (Entity.PrimaryPart.Position - MagnitudeCenter).Unit
							local VictimLook = Entity.PrimaryPart.CFrame.LookVector
							local VictimCone = UnitVector:Dot(VictimLook)
							
							local AversionField
							local CurrentTags = CollectionService:GetTags(Entity)
							if CurrentTags and #CurrentTags > 0 then
								for _, Tag in ipairs(CurrentTags) do
									if Tag:match("AversionField") then
										AversionField = true
										break
									end
								end
							end
							
							if Entity:GetAttribute("CounterFrames") or CollectionService:HasTag(Character, Entity.Name .. "EyeOfAKing") or Entity:GetAttribute("FreundReflex") or AversionField then
								Detected[Entity] = "Countered"
							elseif Entity:GetAttribute("EvasiveFrames") then 
								Detected[Entity] = "Evaded"
							elseif Entity:GetAttribute("DeflectFrames") then
								Detected[Entity] = "Deflected"
							elseif VictimCone > 0.3 and not NoVictimCone and not Entity:GetAttribute("SoftCounterFrames") then -- Checks if they are behind the enemy or not
								Detected[Entity] = "BackHit"
							elseif Entity:GetAttribute("BlockFrames")then
								Detected[Entity] = "Blocked"
							elseif Entity:GetAttribute("SoftCounterFrames") then
								Detected[Entity] = "SoftCounter"
							elseif Entity:GetAttribute("ClashFrames") and Character:GetAttribute("ClashFrames") then
								local Inputs = {}

								Inputs.Set1 = SetupInputs()
								Inputs.Set2 = SetupInputs()

								local DashForce = Character.Head:FindFirstChildWhichIsA("BodyVelocity")
								if DashForce then
									DashForce:Destroy()
									DashForce = nil
								end

								EntityManager:ChangeState(Entity, "TriggerClashing", Character, Inputs)
								EntityManager:ChangeState(Character, "TriggerClashing", Entity, Inputs)
								return nil
							else
								Detected[Entity] = "FrontalHit"
							end	
						end
					end
				end
			end
		end
	end
	
	if ToReturn then
		return Detected
	end
end

return HitDetection
