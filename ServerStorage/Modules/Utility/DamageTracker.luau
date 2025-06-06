local ServerStorage = game:GetService("ServerStorage")

local DamageTrackData = {}
local DamageTracker = {}

function DamageTracker:Setup(Character)
	DamageTracker:Cleanup(Character)
	
	DamageTrackData[Character.Name] = {
		EloCounter = {};
		Counter = {};
	}
end

function DamageTracker:Track(Character, AttackOwner, Damage, Elo)
	if DamageTrackData[Character.Name] then
		if Elo then
			if not DamageTrackData[Character.Name].EloCounter[AttackOwner] then
				DamageTrackData[Character.Name].EloCounter[AttackOwner] = 0
			end
			DamageTrackData[Character.Name].EloCounter[AttackOwner] += Damage
		else
			if not DamageTrackData[Character.Name].Counter[AttackOwner] then
				DamageTrackData[Character.Name].Counter[AttackOwner] = 0
			end
			DamageTrackData[Character.Name].Counter[AttackOwner] += Damage
		end
	end
end

function DamageTracker:Reset(Character, Elo)
	if DamageTrackData[Character.Name] then
		if Elo then
			for i, v in pairs(DamageTrackData[Character.Name].EloCounter) do
				if typeof(v) == "RBXScriptConnection" or typeof(v) == "RBXScriptSignal" then
					DamageTrackData[Character.Name].EloCounter[i]:Disconnect()
					DamageTrackData[Character.Name].EloCounter[i] = nil
				else
					DamageTrackData[Character.Name].EloCounter[i] = nil
				end
			end
		else
			for i, v in pairs(DamageTrackData[Character.Name].Counter) do
				if typeof(v) == "RBXScriptConnection" or typeof(v) == "RBXScriptSignal" then
					DamageTrackData[Character.Name].Counter[i]:Disconnect()
					DamageTrackData[Character.Name].Counter[i] = nil
				else
					DamageTrackData[Character.Name].Counter[i] = nil
				end
			end
		end
	end
end

function DamageTracker:Cleanup(Character)
	if DamageTrackData[Character.Name] then
		for i, v in pairs(DamageTrackData[Character.Name].EloCounter) do
			if typeof(v) == "RBXScriptConnection" or typeof(v) == "RBXScriptSignal" then
				DamageTrackData[Character.Name].EloCounter[i]:Disconnect()
				DamageTrackData[Character.Name].EloCounter[i] = nil
			else
				DamageTrackData[Character.Name].EloCounter[i] = nil
			end
		end
		for i, v in pairs(DamageTrackData[Character.Name].Counter) do
			if typeof(v) == "RBXScriptConnection" or typeof(v) == "RBXScriptSignal" then
				DamageTrackData[Character.Name].Counter[i]:Disconnect()
				DamageTrackData[Character.Name].Counter[i] = nil
			else
				DamageTrackData[Character.Name].Counter[i] = nil
			end
		end
		DamageTrackData[Character.Name] = nil
	end	
end

function DamageTracker:RetrieveData(Character)
	return DamageTrackData[Character.Name]
end

return DamageTracker
