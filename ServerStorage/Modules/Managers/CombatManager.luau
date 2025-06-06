local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local EntityManager = require(ServerStorage.Modules.Managers.EntityManager)
local ClanData = require(ServerStorage.Modules.Utility.ClanData)
local StatData = require(ServerStorage.Modules.Utility.StatData)
local SkillData = require(ServerStorage.Modules.Utility.SkillData)
local AirtimeManager = require(ServerStorage.Modules.Managers.AirtimeManager)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)
local DamageTracker = require(ServerStorage.Modules.Utility.DamageTracker)
local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local HitEffectClient = ReplicatedStorage.Modules.ClientModules.ClientHitEffects

local PathData = {Module = HitEffectClient, Skill = "ApplyHitEffect"}
local StartOvertimePathData = {Module = HitEffectClient, Skill = "StartOvertime"}
local StackOvertimePathData = {Module = HitEffectClient, Skill = "StackOvertime"}
local EndOvertimePathData = {Module = HitEffectClient, Skill = "EndOvertime"}
local PopOvertimePathData = {Module = HitEffectClient, Skill = "PopOvertime"}
local RenderDistance = 1000

local function DeepcopyTable(Table)
	local copy = {}
	for key, value in pairs(Table) do
		if type(value) == "table" then
			copy[key] = DeepcopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local OvertimeData = {}

local CombatManager = {}

local function TagInstance(AttackOwner, Player)
	local TagInstance = AttackOwner
	
	local PlayerAttacker = Players:GetPlayerFromCharacter(AttackOwner)
	if Player then
		TagInstance = Player
	elseif PlayerAttacker then
		TagInstance = PlayerAttacker
	end
	
	return TagInstance
end

function CombatManager:CombatTag(Character, AttackOwner)
	--[[local Player = Players:GetPlayerFromCharacter(AttackOwner)
	local Sternritter
	if Player and Player.Character:GetAttribute("Sternritter") then
		Sternritter = true
	end
	
	local TagInstance = TagInstance(AttackOwner)
	
	local TagReference = (Character.Name .. "CombatTag")
	local PlayerTagReference = (Character.Name .. "PlayerCombatTag")
	local SternritterTagReference = (Character.Name .. "SternritterCombatTag")
	
	if not CollectionService:HasTag(TagInstance, TagReference) then
		CollectionService:AddTag(TagInstance, TagReference)
	end
	if Player and not CollectionService:HasTag(TagInstance, PlayerTagReference) then
		CollectionService:AddTag(TagInstance, PlayerTagReference)
	end
	if Sternritter and not CollectionService:HasTag(TagInstance, SternritterTagReference) then
		CollectionService:AddTag(TagInstance, SternritterTagReference)
	end]]
	
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and not Character:GetAttribute("IFrames") and not Character:GetAttribute("TrueIFrames") and not Character:GetAttribute("Teleporting") then
		Character.CharacterHandler.Remotes.CombatTagEvent:Fire(AttackOwner)
	end
end

function CombatManager:ResetCombatTags(Entity, Player)
	local TagInstance = TagInstance(Entity, Player)
	
	local CombatTags = CollectionService:GetTags(TagInstance)
	for i, v in ipairs(CombatTags) do
		CollectionService:RemoveTag(TagInstance, v)
	end
end

function CombatManager:ClearAllTags(Entity)
	local TagReference = (Entity.Name .. "CombatTag")
	local PlayerTagReference = (Entity.Name .. "PlayerCombatTag")
	local SternritterTagReference = (Entity.Name .. "SternritterCombatTag")

	local Tagged = CollectionService:GetTagged(TagReference)
	for i, v in ipairs(Tagged) do
		CollectionService:RemoveTag(v, TagReference)
	end

	local PlayerTagged = CollectionService:GetTagged(PlayerTagReference)
	for i, v in ipairs(PlayerTagged) do
		CollectionService:RemoveTag(v, PlayerTagReference)
	end

	local SternritterTagged = CollectionService:GetTagged(SternritterTagReference)
	for i, v in ipairs(SternritterTagged) do
		CollectionService:RemoveTag(v, SternritterTagReference)
	end
end

function CombatManager:ApplyDamage(AttackOwner, DetectedTargets, AttackData)
	local PositiveHit = {}
	for Character, HitType in pairs(DetectedTargets) do
		if AttackOwner and Character and Character:FindFirstChild("HumanoidRootPart") then
			CombatManager:CombatTag(Character, AttackOwner)
			
			if HitType == "Countered" and not AttackData.NoCounter and Character:GetAttribute("CurrentState") ~= "Executing" and not Character:GetAttribute("Execution") then
				EntityManager:ChangeState(Character, "CounterSuccess", AttackOwner, AttackData)
			elseif HitType == "Blocked" and AttackData.Blockable then
				local CopiedAttackData = DeepcopyTable(AttackData)
				local BlockDamage = AttackData.BlockDamage
				if not AttackData.NoPostureScaling then
					if AttackData.MultiHits then
						BlockDamage += (AttackOwner:GetAttribute("Kendo") / StatData.KendoScaling) / AttackData.MultiHits
					else
						BlockDamage += (AttackOwner:GetAttribute("Kendo") / StatData.KendoScaling)
					end
				end
				if AttackOwner:GetAttribute("BankaiDaggerClone") then
					BlockDamage *= 0.5
				end
				if AttackData.PercentPosture then
					BlockDamage = Character:GetAttribute("MaxPosture") * AttackData.PercentPosture
				end
				CopiedAttackData.BlockDamage = BlockDamage

				EntityManager:ChangeState(AttackOwner, "TriggerAttackBlocked", CopiedAttackData, Character)
				EntityManager:ChangeState(Character, "BlockedAttack", CopiedAttackData, AttackOwner)
				if Character:GetAttribute("CurrentState") == "PostureBroken" then
					table.insert(PositiveHit, Character)
					
					if CopiedAttackData.Airtime and Character:GetAttribute("EntityType") ~= "Menos" then
						AirtimeManager:Airtime(AttackOwner, Character, CopiedAttackData.Airtime)
					end
				end
			elseif HitType == "Deflected" and AttackData.Parryable then
				local DeflectAnimation = math.random(1, 2)
				if not AttackData.NoParryCancel then
					EntityManager:ChangeState(AttackOwner, "AttackDeflected", AttackData.DeflectDamage, DeflectAnimation, StatData.ParriedStunTime, AttackData)
				end
				EntityManager:ChangeState(Character, "AttackDeflected", AttackData.DeflectDamage, DeflectAnimation, StatData.ParryStunTime, AttackOwner)
			elseif HitType == "Evaded" and not AttackData.NoEvade then
				Character:SetAttribute("EvasiveFrames", false)
				EntityManager:ChangeState(Character, "PerfectFlashstep", AttackOwner, nil, AttackData)
			elseif HitType == "SoftCounter" and not AttackData.NoCounter and Character:GetAttribute("CurrentState") ~= "Executing" and not Character:GetAttribute("Execution") and Character:GetAttribute("CurrentState") ~= "Unconscious" then
				EntityManager:ChangeState(Character, "CounterSuccess", AttackOwner, AttackData, "SoftCounter")
				
				--[[if AttackData.TrueStunTime then
					if Character:GetAttribute("HyperArmor") == false and not Character:GetAttribute("TrueHyperArmor") then
						local TriggerStun = true
						if Character:GetAttribute("CurrentState") == "PostureBroken" and AttackData.PostureBreakBypass or AttackData.NoHitStun then
							TriggerStun = nil
						end

						if TriggerStun then
							local CopiedAttackData = DeepcopyTable(AttackData)
							CopiedAttackData.StunAnimation = "None"
							CopiedAttackData.TrueStunTime = 0.1
							CopiedAttackData.SoftStunTime = 0
							EntityManager:ChangeState(Character, "TriggerTrueStun", CopiedAttackData, AttackOwner)
						end
					end
				end]]
			else
				local Damage = AttackData.Damage
				if Character:GetAttribute("ShadowGarden") then
					Damage = 0
				end
				
				if (Character.Humanoid.Health - Damage) > 1 and Character:GetAttribute("CurrentState") ~= "Unconscious" then
					local Execution = Character:GetAttribute("Execution")
					
					local TrueStunTime = AttackData.TrueStunTime
					if AttackData.GlobalStunCD and Character:GetAttribute("GlobalStunCD") then
						TrueStunTime = nil
					end
					
					if TrueStunTime then
						if Execution and AttackData.ExecutionPositiveHit then
							Execution = nil
						end
						
						local HyperArmorBypass
						if Character:GetAttribute("HyperArmor") or Character:GetAttribute("TrueHyperArmor") then
							if AttackData.HyperArmorBypass then
								HyperArmorBypass = true
							end
						end
						
						if not Execution then
							if Character:GetAttribute("HyperArmor") == false and not Character:GetAttribute("TrueHyperArmor") or Character:GetAttribute("CurrentState") == "Executing" or HyperArmorBypass then
								table.insert(PositiveHit, Character)

								local TriggerStun = true
								if Character:GetAttribute("CurrentState") == "PostureBroken" and AttackData.PostureBreakBypass or AttackData.NoHitStun then
									TriggerStun = nil
								end
								if AttackData.SpiritBowAttack then
									local SpiritBowTimer = Character:GetAttribute("SpiritBowTimer")
									if not SpiritBowTimer then
										SpiritBowTimer = 0
									end

									local TimeDifference = DateTime.now().UnixTimestampMillis - SpiritBowTimer
									if TimeDifference < StatData.SpiritBowStunCD * 1000 then
										TriggerStun = nil
									end

									Character:SetAttribute("SpiritBowTimer", DateTime.now().UnixTimestampMillis)
								end

								if TriggerStun then
									EntityManager:ChangeState(Character, "TriggerTrueStun", AttackData, AttackOwner)
								end

								if AttackData.Airtime and Character:GetAttribute("EntityType") ~= "Menos" then
									AirtimeManager:Airtime(AttackOwner, Character, AttackData.Airtime)
								end
							elseif Character:GetAttribute("HyperArmor") == true and AttackData.HyperArmorPositiveHit or Character:GetAttribute("TrueHyperArmor") and AttackData.HyperArmorPositiveHit then
								table.insert(PositiveHit, Character)
							end
						end
					end

					if Character.Humanoid.Health - Damage <= (Character.Humanoid.MaxHealth * 0.3) then
						Character:SetAttribute("BaseWalkspeed", StatData.WalkSpeeds.LowHealth)
						--NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, PathData, "Blood")
					end
					
					if AttackOwner ~= Character then
						local Clan = AttackOwner:GetAttribute("Clan")
						if Clan then
							local ClanBuff = ClanData[AttackOwner:GetAttribute("Clan")].ClanBuff
							if ClanBuff then
								local ReiatsuSteal = ClanBuff.ReiatsuSteal
								if AttackData.MultiHits then
									ReiatsuSteal = ReiatsuSteal / AttackData.MultiHits
								end
								
								local CurrentRei = AttackOwner:GetAttribute("Reiatsu")
								CurrentRei += ReiatsuSteal
								if CurrentRei < AttackOwner:GetAttribute("MaxReiatsu") then
									AttackOwner:SetAttribute("Reiatsu", CurrentRei)
								else
									AttackOwner:SetAttribute("Reiatsu", AttackOwner:GetAttribute("MaxReiatsu"))
								end
							end
						end
						
						local Posture = AttackOwner:GetAttribute("Posture")
						Posture -= 2.5
						if Posture <= 0 then
							AttackOwner:SetAttribute("Posture", 0)
						else
							AttackOwner:SetAttribute("Posture", Posture)
						end
					end

					EntityManager:ChangeState(Character, "TakeDamage", AttackData, AttackOwner, HitType) 
					-- Moved it to a state function but with no transitions, it will just run effects and damage humanoid
					-- this way you could do different hit effects for Hollows / Humanoids easier

				else
					if AttackData.KnockedPositiveHit then
						table.insert(PositiveHit, Character)
					end
					
					local UnconsciousAttackData = {
						BlackAnt = true,
						Damage = 0;
						OriginalDamage = Damage;
						ImpactSound = AttackData.ImpactSound;
						NoHitEffect = AttackData.NoHitEffect;
						HitEffect = AttackData.HitEffect;
					}

					EntityManager:ChangeState(Character, "TakeDamage", UnconsciousAttackData, AttackOwner)
					Character.Humanoid.Health = 1
					EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
				end	
			end
		end
	end
	return PositiveHit
end

function CombatManager:SetupOvertimes(Entity)
	OvertimeData[Entity.Name] = {}
end

function CombatManager:CleanupOvertimes(EntityName)
	if OvertimeData[EntityName] then
		for i, v in pairs(OvertimeData[EntityName]) do
			if typeof(v) == "RBXScriptConnection" or typeof(v) == "RBXScriptSignal" then
				OvertimeData[EntityName][i]:Disconnect()
				OvertimeData[EntityName][i] = nil
			else
				OvertimeData[EntityName][i] = nil
			end
		end
		OvertimeData[EntityName] = nil
	end
end

function CombatManager:GetOvertimes(Entity)
	return OvertimeData[Entity.Name]
end

function CombatManager:CancelOvertime(Entity, OvertimeName)
	if OvertimeData[Entity.Name] then
		OvertimeData[Entity.Name][OvertimeName .. "Cancel"] = true
	end
end

function CombatManager:ApplyOvertime(OvertimeName, AttackOwner, DetectedTargets, AttackData)
	local Player = Players:GetPlayerFromCharacter(AttackOwner)
	local StackLimit
	
	for _, Character in ipairs(DetectedTargets) do
		local OvertimeAlreadyApplied = CombatManager:GetOvertimes(Character)[OvertimeName]
		if AttackData.OvertimeStacking then
			OvertimeAlreadyApplied = nil
			if AttackData.OvertimeStacking.Limit > 0 then
				StackLimit = AttackData.OvertimeStacking.Limit
			end
		end
		if AttackOwner and Character and Character:FindFirstChild("HumanoidRootPart") and not OvertimeAlreadyApplied then
			--[[local CurrentState = Character:GetAttribute("CurrentState")
			if (Character.Humanoid.Health - AttackData.Damage) > 1 and CurrentState ~= "Unconscious" then
				
			else
				Character.Humanoid.Health = 1
				EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
			end]]
			
			if Character:GetAttribute("HyperArmor") == false and AttackData.TrueStunTime then
				EntityManager:ChangeState(Character, "TriggerTrueStun", AttackData)
			end

			if OvertimeData[Character.Name] then
				local Accumulated = 0
				local Rate = AttackData.TickRate

				local OvertimeStacks = CombatManager:GetOvertimes(Character)[OvertimeName]
				if not OvertimeStacks then
					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, StartOvertimePathData, OvertimeName, AttackOwner)

					OvertimeData[Character.Name][OvertimeName] = 1
					OvertimeData[Character.Name][OvertimeName .. "Duration"] = AttackData.Ticks

					if AttackData.ExecuteData then
						OvertimeData[Character.Name][OvertimeName .. "ExecuteDuration"] = AttackData.ExecuteData.Ticks
					end
					
					local function OvertimeEnded()
						NetworkManager.FireAllClients(Character, "ClientEffects", -1, EndOvertimePathData, OvertimeName, AttackOwner)

						OvertimeData[Character.Name][OvertimeName] = nil
						OvertimeData[Character.Name][OvertimeName ..  "Cancel"] = nil
						OvertimeData[Character.Name][OvertimeName .. "Duration"] = nil
						OvertimeData[Character.Name][OvertimeName .. "ExecuteDuration"] = nil
						if OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] then
							OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"]:Disconnect()
							OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] = nil
						end
						OvertimeData[Character.Name][OvertimeName .. "Connection"]:Disconnect()
						OvertimeData[Character.Name][OvertimeName .. "Connection"] = nil
						--print(Character.Name .. " " .. OvertimeName .. " ended", OvertimeData[Character.Name])
					end
					
					if Player then
						OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] = Player.CharacterRemoving:Connect(function()
							OvertimeEnded()
						end)
					else
						OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] = AttackOwner.Humanoid.Died:Connect(function()
							OvertimeEnded()
						end)
					end
					
					OvertimeData[Character.Name][OvertimeName .. "Connection"] = RunService.Heartbeat:Connect(function(DeltaTime)
						Accumulated += DeltaTime
						if Accumulated > Rate then
							Accumulated -= Rate
							OvertimeData[Character.Name][OvertimeName .. "Duration"] -= Rate
							local Ticks = OvertimeData[Character.Name][OvertimeName .. "Duration"]
							
							if Ticks <= 0 then
								OvertimeEnded()
								return
							end
							
							if Character and Character:FindFirstChild("HumanoidRootPart") and not OvertimeData[Character.Name][OvertimeName ..  "Cancel"] then
								local Damage = AttackData.Damage * OvertimeData[Character.Name][OvertimeName]
								if AttackData.PercentDamage then
									Damage = (Character.Humanoid.MaxHealth * AttackData.Damage) * OvertimeData[Character.Name][OvertimeName]
								end
								
								local CurrentAttackData = DeepcopyTable(AttackData)
								CurrentAttackData.Damage = Damage
								
								if (Character.Humanoid.Health - Damage) > 1 and Character:GetAttribute("CurrentState") ~= "Unconscious" then
									EntityManager:ChangeState(Character, "TakeDamage", CurrentAttackData, AttackOwner)
									--Character.Humanoid:TakeDamage(Damage)
								else
									Character.Humanoid.Health = 1
									EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
									
									if not AttackData.ExecuteData then
										Ticks = 0
									else
										if Character:GetAttribute("CurrentState") == "Unconscious" and not Character:GetAttribute("Carried") and not Character:GetAttribute("GripBypass") then										
											OvertimeData[Character.Name][OvertimeName .. "ExecuteDuration"] -= Rate
											
											if OvertimeData[Character.Name][OvertimeName .. "ExecuteDuration"] <= 0 then
												Ticks = 0
												
												if OvertimeName == "TrueBurn" and Players:GetPlayerFromCharacter(Character) and Players:GetPlayerFromCharacter(AttackOwner) and not Character:GetAttribute("Zombification") then
													Character:SetAttribute("ZombieOwner", AttackOwner.Name)
													EntityManager:ChangeState(Character, "TriggerZombification", AttackOwner, 30)
												else
													EntityManager:ChangeState(Character, "TriggerDying")
													EntityManager:ChangeState(Character, "TriggerDeath", AttackOwner)
												end
											end
										end
									end
								end
							else
								Ticks = 0
							end
						end
					end)
				else
					OvertimeData[Character.Name][OvertimeName] += 1
					OvertimeData[Character.Name][OvertimeName .. "Duration"] = AttackData.Ticks
					
					if AttackData.OvertimeStacking.MaintainMaxStacks and OvertimeData[Character.Name][OvertimeName] >= StackLimit then
						OvertimeData[Character.Name][OvertimeName] = StackLimit
					end
					
					local Stacks = OvertimeData[Character.Name][OvertimeName]
					if StackLimit and Stacks >= StackLimit and not AttackData.OvertimeStacking.MaintainMaxStacks then
						OvertimeData[Character.Name][OvertimeName .. "Connection"]:Disconnect()
						OvertimeData[Character.Name][OvertimeName .. "Connection"] = nil
						OvertimeData[Character.Name][OvertimeName ..  "Cancel"] = nil
						OvertimeData[Character.Name][OvertimeName .. "Duration"] = nil
						OvertimeData[Character.Name][OvertimeName] = nil
						OvertimeData[Character.Name][OvertimeName .. "ExecuteDuration"] = nil
						if OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] then
							OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"]:Disconnect()
							OvertimeData[Character.Name][OvertimeName .. "CharacterRemoving"] = nil
						end

						--print(Character.Name .. " " .. OvertimeName .. " popped", OvertimeData[Character.Name])

						local Damage = AttackData.OvertimeStacking.Damage
						if (Character.Humanoid.Health - Damage) > 1 and Character:GetAttribute("CurrentState") ~= "Unconscious" then
							if AttackData.OvertimeStacking.TrueStunTime then
								EntityManager:ChangeState(Character, "TriggerTrueStun", AttackData.OvertimeStacking, AttackOwner)
							end
							EntityManager:ChangeState(Character, "TakeDamage", AttackData.OvertimeStacking, AttackOwner)
							
						else
							Character.Humanoid.Health = 1
							EntityManager:ChangeState(Character, "TriggerUnconscious", AttackOwner)
						end	

						NetworkManager.FireAllClients(Character, "ClientEffects", -1, EndOvertimePathData, OvertimeName, AttackOwner)
						NetworkManager.FireAllClients(Character, "ClientEffects", -1, PopOvertimePathData, OvertimeName, AttackOwner)
					end

					NetworkManager.FireAllClients(Character, "ClientEffects", RenderDistance, StackOvertimePathData, OvertimeName, AttackOwner, Stacks)
				end
			end
		end
	end
end

return CombatManager
