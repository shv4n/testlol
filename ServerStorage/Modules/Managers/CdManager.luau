local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CooldownManager = {}

function CooldownManager:UpdateToolbar(Player, KeyPressed)
	if Player then
		ReplicatedStorage.Remotes.UpdateToolbarEvent:FireClient(Player, KeyPressed)
	end
end

function CooldownManager:UpdateUniversalKidoCD(Character, KeyPressed, PlayerData, Cooldown, Boolean)
	local Player = Players:GetPlayerFromCharacter(Character)
	local CooldownData = PlayerData.Cooldowns
	if CooldownData then
		if Boolean then
			Character:SetAttribute(KeyPressed, true)
		else
			Character:SetAttribute(KeyPressed, false)
		end

		CooldownManager:UpdateToolbar(Player, KeyPressed)
	end
end

function CooldownManager:UpdateCooldown(Character, KeyPressed, PlayerData, Cooldown, Boolean)
	local Player = Players:GetPlayerFromCharacter(Character)
	local CooldownData = PlayerData.Cooldowns
	if CooldownData then
		if Boolean then
			Character:SetAttribute(KeyPressed, true)
			
			CooldownData[KeyPressed] = DateTime.now().UnixTimestampMillis
		else
			local TimeDifference = DateTime.now().UnixTimestampMillis - CooldownData[KeyPressed]
			if TimeDifference >= Cooldown * 995 then
				Character:SetAttribute(KeyPressed, false)
			end
		end
		
		CooldownManager:UpdateToolbar(Player, KeyPressed)
	end
end

function CooldownManager:ResetCooldown(Character, KeyPressed, PlayerData, NoUpdateTime)
	local Player = Players:GetPlayerFromCharacter(Character)
	local CooldownData = PlayerData.Cooldowns
	
	if not NoUpdateTime then
		CooldownData[KeyPressed] = DateTime.now().UnixTimestampMillis
	end

	Character:SetAttribute(KeyPressed, false)
	CooldownManager:UpdateToolbar(Player, KeyPressed)
end

function CooldownManager:DelayedCooldown(Character, KeyPressed)
	local Player = Players:GetPlayerFromCharacter(Character)
	Character:SetAttribute(KeyPressed, true)
	CooldownManager:UpdateToolbar(Player, KeyPressed)
end

function CooldownManager:ResetSkill(Character, SkillName, PlayerData, SkillInventory)
	local Player = Players:GetPlayerFromCharacter(Character)
	local CooldownData = PlayerData.Cooldowns

	local Player = Players:GetPlayerFromCharacter(Character)
	if SkillInventory then
		for Key, Skill in pairs(SkillInventory) do
			if Skill == SkillName then
				CooldownData[Key] = DateTime.now().UnixTimestampMillis

				Character:SetAttribute(Key, false)
				CooldownManager:UpdateToolbar(Player, Key)
				break
			end
		end
	end
end

function CooldownManager:ResetPastCooldowns(Character, PlayerData, Time, BlacklistedKeys)
	local Player = Players:GetPlayerFromCharacter(Character)
	local CooldownData = PlayerData.Cooldowns
	
	print(CooldownData)
	
	for Key, TimeUsed in pairs(CooldownData) do
		if not BlacklistedKeys[Key] then
			local TimeDifference = DateTime.now().UnixTimestampMillis - TimeUsed
			if TimeDifference < Time * 1000 then
				CooldownManager:ResetCooldown(Character, Key, PlayerData)
			end
		end
	end
end

return CooldownManager
