local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)
local FlashstepClient = require(ReplicatedStorage.Modules.ClientModules.FlashstepClient)
local CameraShaker = require(ReplicatedStorage.Modules.Utility.CameraShaker)

local VampireEffects = ReplicatedStorage.Assets.Effects.Res.Vampire
local VampireSounds = ReplicatedStorage.Assets.ResSounds.Vampire
local Sounds = ReplicatedStorage.Assets.Sounds

local ClientVampireRes = {}

function ClientVampireRes.HealedIndicator(Character, State, Healed)
	if State == "On" then
		local Text = "Healed: " .. Healed
		local PastDamageFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.PastDamage
		PastDamageFrame.TextLabel.Text = Text
		PastDamageFrame.Visible = true
	elseif State == "Off" then
		local PastDamageFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.PastDamage
		PastDamageFrame.Visible = false
	end
end

function ClientVampireRes.Payday(Character, Phase, SpawnPoint, Windup, ParticleColor, Radius)
	if Phase == "1" then
		local PaydayStartupSound = VampireSounds.PaydayStartup:Clone()
		PaydayStartupSound.PlayOnRemove = true
		PaydayStartupSound.Parent = Character.HumanoidRootPart
		PaydayStartupSound:Destroy()
		PaydayStartupSound = nil
	elseif Phase == "2" then
		local ParticleSizes = {
			Enable1 = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0);
				NumberSequenceKeypoint.new(0.38, Radius);
				NumberSequenceKeypoint.new(1, Radius * 2);
			});
			Enable2 = NumberSequence.new({
				NumberSequenceKeypoint.new(0, Radius * 1.1);
				NumberSequenceKeypoint.new(0.66, Radius * 0.85);
				NumberSequenceKeypoint.new(1, Radius * 0.65);
			});
			Enable3 = NumberSequence.new({
				NumberSequenceKeypoint.new(0, Radius * 0.4);
				NumberSequenceKeypoint.new(0.25, Radius * 0.8);
				NumberSequenceKeypoint.new(1, Radius);
			});
		}
		
		local PaydayPull = VampireEffects.PaydayPull:Clone()
		for i, v in ipairs(PaydayPull:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, ParticleColor);
					ColorSequenceKeypoint.new(1, ParticleColor)
				})
				
				if ParticleSizes[v.Name] then
					v.Size = ParticleSizes[v.Name]
				end
			end
		end
		PaydayPull.Position = SpawnPoint
		PaydayPull.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(PaydayPull, Windup + 0.7)

		task.delay(Windup - 0.2, function()
			local PaydayPreSphere = VampireEffects.PaydayPreSphere:Clone()
			PaydayPreSphere.Size = Vector3.zero
			PaydayPreSphere.Position = SpawnPoint
			PaydayPreSphere.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(PaydayPreSphere, 0.6)

			local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(PaydayPreSphere, TweenInfo.new(0.4), {Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2)}):Play()

			task.wait(0.2)

			TweenService:Create(PaydayPreSphere, TweenInfo.new(0.4), {Transparency = 1}):Play()
			
			for i, v in ipairs(PaydayPull:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end

			local PaydayExplosion = VampireEffects.PaydayExplosion:Clone()
			for i, v in ipairs(PaydayExplosion:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, ParticleColor);
						ColorSequenceKeypoint.new(1, ParticleColor)
					})
				end
			end
			PaydayExplosion.Position = SpawnPoint
			PaydayExplosion.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(PaydayPull, 1.2)

			for i, v in ipairs(PaydayExplosion:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.Name))
				end
			end
			
			local PaydayImpactSound = VampireSounds.Payday:Clone()
			PaydayImpactSound.PlayOnRemove = true
			PaydayImpactSound.Parent = PaydayExplosion
			PaydayImpactSound:Destroy()
			PaydayImpactSound = nil

			local Info2 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			
			for i = 1, 3 do
				task.spawn(function()
					local PaydaySphere = VampireEffects.PaydaySphere:Clone()
					PaydaySphere.Color = ParticleColor
					PaydaySphere.Transparency = 1
					PaydaySphere.Size = Vector3.zero
					PaydaySphere.Position = SpawnPoint
					PaydaySphere.Parent = workspace.Effects[Character.Name]
					Debris:AddItem(PaydaySphere, 1.2)

					TweenService:Create(PaydaySphere, Info2, {Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2)}):Play()
					TweenService:Create(PaydaySphere, TweenInfo.new(0.25), {Transparency = 0.3}):Play()

					task.wait(0.2)

					TweenService:Create(PaydaySphere, TweenInfo.new(0.6), {Transparency = 1}):Play()
					TweenService:Create(PaydaySphere, TweenInfo.new(0.6), {Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2) + Vector3.new(30, 30, 30)}):Play()
				end)
			end
		end)
	end
end

function ClientVampireRes.Phage(Character, Phase)
	if Phase == "1" then
		local PhageSound = VampireSounds.PhageStartup:Clone()
		PhageSound.PlayOnRemove = true
		PhageSound.Parent = Character.HumanoidRootPart
		PhageSound:Destroy()
		PhageSound = nil
	elseif Phase == "2" then
		local PhageStartup = VampireEffects.PhageStartup:Clone()
		PhageStartup.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(PhageStartup, 0.75)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = PhageStartup
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = PhageStartup
		
		for i, v in ipairs(PhageStartup:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local PhageSound = VampireSounds.PhageDash:Clone()
		PhageSound.Parent = Character.HumanoidRootPart
		PhageSound:Play()
		Debris:AddItem(PhageSound, PhageSound.TimeLength)
		
		FlashstepClient.Invisible(Character)
		task.delay(0.3, function()
			FlashstepClient.Visible(Character)
		end)
	end
end

function ClientVampireRes.Echo(Character, Duration)
	local Echo = VampireEffects.Echo:Clone()
	Echo.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Echo, Duration + 1.25)
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = Echo
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = Echo
	
	task.delay(Duration, function()
		for i, v in ipairs(Echo:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end)
	
	local EchoSound = VampireSounds.Echo:Clone()
	EchoSound.Parent = Character.HumanoidRootPart
	EchoSound:Play()
	Debris:AddItem(EchoSound, EchoSound.TimeLength)
end

function ClientVampireRes.EchoClient(Character)
	local Effects = ReplicatedStorage.Assets.Effects
	
	local Duration = 4

	local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	local ColorCorrection = Instance.new("ColorCorrectionEffect")
	ColorCorrection.Brightness = 0
	ColorCorrection.Contrast = 0
	ColorCorrection.Saturation = 0
	ColorCorrection.Parent = Lighting
	Debris:AddItem(ColorCorrection, Duration)
	TweenService:Create(ColorCorrection, Info, {
		Brightness = -0.35;
		Contrast = 0.8;
		Saturation = -1;
		TintColor = Color3.fromRGB(255, 255, 255);
	}):Play()

	local Blur = Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = Lighting
	Debris:AddItem(Blur, Duration)
	TweenService:Create(Blur, Info, {
		Size = 5;
	}):Play()

	local DepthOfField = Instance.new("DepthOfFieldEffect")
	DepthOfField.FarIntensity = 0
	DepthOfField.InFocusRadius = 0
	DepthOfField.NearIntensity = 0
	DepthOfField.Parent = Lighting
	Debris:AddItem(DepthOfField, Duration)
	TweenService:Create(DepthOfField, Info, {
		FarIntensity = 0.3;
		InFocusRadius = 15;
		NearIntensity = 1;
	}):Play()

	local Heartbeat = Sounds.Heartbeat:Clone()
	Heartbeat.Parent = workspace.Effects[Character.Name]
	Heartbeat:Play()
	Debris:AddItem(Heartbeat, Duration)

	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.SpiritualPressureMini)

	task.delay(Duration - 1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)

	task.delay(Duration - 2, function()
		TweenService:Create(Heartbeat, TweenInfo.new(2), {Volume = 0}):Play()
		TweenService:Create(DepthOfField, TweenInfo.new(2), {
			FarIntensity = 0;
			InFocusRadius = 0;
			NearIntensity = 0;
		}):Play()
		TweenService:Create(Blur, TweenInfo.new(2), {
			Size = 0;
		}):Play()
		TweenService:Create(ColorCorrection, TweenInfo.new(2), {
			Brightness = 0;
			Contrast = 0;
			Saturation = 0;
			TintColor = Color3.fromRGB(255, 255, 255);
		}):Play()
	end)
end

function ClientVampireRes.Bite(Character, Target)
	local EchoBite = VampireEffects.EchoBite:Clone()
	EchoBite.CFrame = Target.HumanoidRootPart.CFrame
	EchoBite.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(EchoBite, 0.6)
	
	for i, v in ipairs(EchoBite:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(tonumber(v.Name))
		end
	end
	
	local EchoBiteSound = VampireSounds.EchoBite:Clone()
	EchoBiteSound.PlayOnRemove = true
	EchoBiteSound.Parent = Character.HumanoidRootPart
	EchoBiteSound:Destroy()
	EchoBiteSound = nil
end

function ClientVampireRes.Release(Character, EyeColor)
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

return ClientVampireRes
