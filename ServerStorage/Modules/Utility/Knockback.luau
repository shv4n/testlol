local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local KnockbackModule = {}

function KnockbackModule:DirectionKnockback(Character, Direction, Target, Distance, Duration)
	if Character and Target then
		local Knockback

		if not Target:GetAttribute("KnockbackDisabled") then
			Knockback = true
		else
			if Target:GetAttribute("KnockbackDisabled") == Character.Name then
				Knockback = true
			end
		end
		
		local Lifetime = 0.3
		if Duration then
			Lifetime = Duration
		end
		
		if Knockback then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
			BodyVelocity.Velocity = Direction * Distance
			BodyVelocity.Parent = Target.Head
			Debris:AddItem(BodyVelocity, Lifetime)
			return BodyVelocity
		else
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.zero
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.Parent = Target.Head
			Debris:AddItem(BodyVelocity, Lifetime)
			return BodyVelocity
		end
	end
end

function KnockbackModule:Knockback(Character, Target, Distance)
	if Character and Target then
		local Knockback
		
		if not Target:GetAttribute("KnockbackDisabled") then
			Knockback = true
		else
			if Target:GetAttribute("KnockbackDisabled") == Character.Name then
				Knockback = true
			end
		end
		
		if Knockback then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
			BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * Distance
			BodyVelocity.Parent = Target.Head
			Debris:AddItem(BodyVelocity, 0.3)
			return BodyVelocity
		else
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.zero
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.Parent = Target.Head
			Debris:AddItem(BodyVelocity, 0.3)
			return BodyVelocity
		end
	end
end

function KnockbackModule:Repel(Character, Position, Target, Distance)
	if not Target:GetAttribute("KnockbackDisabled") then
		local TargetPosition = Vector3.new(Target.PrimaryPart.Position.X, 0, Target.PrimaryPart.Position.Z)
		local CharacterPosition = Vector3.new(Position.X, 0, Position.Z)
		local Direction = (TargetPosition - CharacterPosition).Unit
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
		BodyVelocity.Velocity = Direction * Distance
		BodyVelocity.Parent = Target.Head
		Debris:AddItem(BodyVelocity, 0.3)	
	else
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.zero
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = Target.Head
		Debris:AddItem(BodyVelocity, 0.3)	
	end
end

function KnockbackModule:Attract(Character, Position, Target, Distance)
	if not Target:GetAttribute("KnockbackDisabled") then
		local TargetPosition = Vector3.new(Target.PrimaryPart.Position.X, 0, Target.PrimaryPart.Position.Z)
		local MagnitudeCenter = Vector3.new(Position.X, 0, Position.Z)
		local Direction = (TargetPosition - MagnitudeCenter).Unit
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(80000, 0, 80000)
		BodyVelocity.Velocity = Direction * -Distance
		BodyVelocity.Parent = Target.Head
		Debris:AddItem(BodyVelocity, 0.3)
	else
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.zero
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.Parent = Target.Head
		Debris:AddItem(BodyVelocity, 0.3)
	end
end

function KnockbackModule:UpKnockback(Character, Target, Distance, RandomDirection)
	if Target then
		local Knockback

		if not Target.Parent:GetAttribute("KnockbackDisabled") then
			Knockback = true
		else
			if Target.Parent:GetAttribute("KnockbackDisabled") == Character.Name then
				Knockback = true
			end
		end

		if Knockback then
			local BodyVelocity = Instance.new("BodyVelocity")
			if RandomDirection then	
				BodyVelocity.MaxForce = Vector3.new(45000, 45000, 45000)
				BodyVelocity.Velocity = Vector3.new(math.random(-RandomDirection, RandomDirection), Distance, math.random(-RandomDirection, RandomDirection))
			else
				BodyVelocity.MaxForce = Vector3.new(0, 45000, 0)
				BodyVelocity.Velocity = Vector3.new(0, Distance, 0)
			end
			BodyVelocity.Parent = Target
			Debris:AddItem(BodyVelocity, 0.3)
			return BodyVelocity
		else
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.zero
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.Parent = Target
			Debris:AddItem(BodyVelocity, 0.3)
			return BodyVelocity
		end
	end
end

function KnockbackModule:PartLinearVelocity(Origin, Target, Distance)
	local function velocity(vector1, vector2)
		local direction = vector1 - vector2
		local x = direction.X
		local z = direction.Z
		return Vector3.new(x, 2, z)
	end
	
	local a = Instance.new("Attachment")
	a.Name = "aaa"
	local lv = Instance.new("LinearVelocity")
	lv.Name = "bbb"
	a.Parent = Target
	lv.MaxForce = math.huge
	lv.Attachment0 = a
	lv.VectorVelocity = (velocity(Target.Position, Origin.Position)).Unit * Distance
	lv.Parent = Target
	Debris:AddItem(lv, 0.3)
	Debris:AddItem(a, 0.3)
end

function KnockbackModule:AlignPosition(Character, Target, ObjectCFrame, Duration, Speed)
	local A1 = Instance.new("Attachment")
	local A2 = Instance.new("Attachment")
	
	local Part = Instance.new("Part")
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = 1
	Part.CFrame = ObjectCFrame
	Part.Name = "AlignPositionPart"
	Part.Parent = workspace.Effects[Character.Name]
	
	A1.Name = "AlignPositionConstraintAttachment"
	A1.Parent = Target.HumanoidRootPart
	A2.Parent = Part
	
	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Name = "AlignPositionConstraint"
	AlignPosition.Attachment0 = A1
	AlignPosition.Attachment1 = A2
	AlignPosition.Responsiveness = Speed
	AlignPosition.Parent = Target.HumanoidRootPart
	
	Debris:AddItem(Part, Duration)
	Debris:AddItem(A1, Duration)
	Debris:AddItem(AlignPosition, Duration)
end

return KnockbackModule
