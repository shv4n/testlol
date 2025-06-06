local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local TemplateEffects = ReplicatedStorage.Assets.Effects.Res
local TemplateSounds = ReplicatedStorage.Assets.ResSounds

local TemplateRes = {}

function TemplateRes.MoveZ(Character)
	print("Client side")
end

function TemplateRes.MoveX(Character)
	print("Client side")
end

function TemplateRes.MoveC(Character)
	print("Client side")
end

function TemplateRes.Release(Character, EyeColor)
	local ResBeginning = ReplicatedStorage.Assets.Effects.Res["Res Beginning"]:Clone()
	ResBeginning.Anchored = false
	ResBeginning.Parent = workspace.Effects[Character.Name]

	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(3.05175781e-05, 0, 3.05175781e-05, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Part0 = ResBeginning
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = ResBeginning

	local ResBuildupSound = ReplicatedStorage.Assets.ResSounds.ResBuildup:Clone()
	ResBuildupSound.PlayOnRemove = true
	ResBuildupSound.Parent = Character.HumanoidRootPart
	ResBuildupSound:Destroy()
	ResBuildupSound = nil

	for i, v in ipairs(ResBeginning:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Beam") then
			v.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]));
				ColorSequenceKeypoint.new(1, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]));
			})
			v.Enabled = true
		end
	end

	task.delay(2, function()
		for i, v in ipairs(ResBeginning:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Beam") then
				v.Enabled = false
			end
		end
		Debris:AddItem(ResBeginning, 1)

		local TransformEffect = ReplicatedStorage.Assets.Effects.Res.Tranform:Clone()
		TransformEffect:PivotTo(Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(math.pi / 2, 0, 0))
		TransformEffect.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(TransformEffect.EnableBeam:GetDescendants()) do
			if v:IsA("Beam") then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]));
					ColorSequenceKeypoint.new(1, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]));
				})
			end
		end
		for i, v in ipairs(TransformEffect.Emit50:GetChildren()) do
			v:Emit(50)
		end
		for i, v in ipairs(TransformEffect.Ring.Attachment:GetChildren()) do
			v.Enabled = true
			v.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]));
				ColorSequenceKeypoint.new(1, Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3]))
			})
			task.delay(2, function()
				v.Enabled = false
			end)
		end	
		local SphereSize = TransformEffect.Ball.Size
		TransformEffect.Ball.Size = Vector3.zero
		TransformEffect.Ball.Color = Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3])
		TransformEffect.Ball.CFrame = TransformEffect.Ball.CFrame * CFrame.new(0, -3, 0)

		TweenService:Create(TransformEffect.Ball, TweenInfo.new(1), {Size = SphereSize, Transparency = 0}):Play()
		task.delay(1, function()
			for i, v in ipairs(TransformEffect.Enable:GetChildren()) do
				v.Enabled = true
			end
			local Info = TweenInfo.new(0.03, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, -1, true)
			TweenService:Create(TransformEffect.Ball, Info, {Size = SphereSize + Vector3.new(1, 1, 1)}):Play()
			task.wait(2)

			TweenService:Create(TransformEffect.Ball, TweenInfo.new(1), {Size = Vector3.zero, Transparency = 1}):Play()

			for i, v in ipairs(TransformEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") then
					v.Enabled = false
				end
			end
		end)
		Debris:AddItem(TransformEffect, 4)

		local ResSound = ReplicatedStorage.Assets.ResSounds.ResRelease:Clone()
		ResSound.PlayOnRemove = true
		ResSound.Parent = Character.PrimaryPart
		ResSound:Destroy()
		ResSound = nil
	end)
end

return TemplateRes
