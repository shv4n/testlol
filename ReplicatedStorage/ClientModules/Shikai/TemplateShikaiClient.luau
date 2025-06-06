local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local Effects = ReplicatedStorage.Assets.Effects
local Sounds = ReplicatedStorage.Assets.Sounds

local TemplateEffects
local TemplateSounds

local TemplateShikai = {}

function TemplateShikai.MoveZ(Character)
	print("Client side")
end

function TemplateShikai.MoveX(Character)
	print("Client side")
end

function TemplateShikai.MoveC(Character)
	print("Client side")
end

function TemplateShikai.MoveT(Character)
	print("Client side")
end

function TemplateShikai.MoveG(Character)
	print("Client side")
end

local function CustomRelease(Character, Color)
	local function RandomNumber(Min, Max)
		return Random.new():NextNumber(Min, Max)
	end
	
	local RootPosition = Character.HumanoidRootPart.Position
	
	local Model = Instance.new("Model")
	Model.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Model, 7)
	
	local BankaiReleaseSound = ReplicatedStorage.Assets.ShikaiSounds.BankaiRelease:Clone()
	BankaiReleaseSound.PlayOnRemove = true
	BankaiReleaseSound.Parent = Character.HumanoidRootPart
	BankaiReleaseSound:Destroy()
	BankaiReleaseSound = nil
	
	local Accumulated = 0
	local Lifetime = 2
	local Connection
	Connection = RunService.RenderStepped:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		Lifetime -= DeltaTime
		
		if Lifetime <= 0 then
			Connection:Disconnect()
			Connection = nil
			return
		end
		
		if Accumulated > 0.04 then
			Accumulated -= 0.04
			
			local Shards = ReplicatedStorage.Assets.Effects.Shikais.Shards:GetChildren()
			local Shard = Shards[math.random(1, #Shards)]:Clone()
			Shard.Color = Color
			Shard.CFrame = CFrame.new(RootPosition) * CFrame.new(RandomNumber(-30, 30), -2, RandomNumber(-30, 30)) * CFrame.Angles(RandomNumber(-math.pi*2, math.pi*2), RandomNumber(-math.pi*2, math.pi*2), RandomNumber(-math.pi*2, math.pi*2))
			Shard.Parent = Model

			TweenService:Create(Shard, TweenInfo.new(1), {Position = (Shard.Position + Vector3.new(0, RandomNumber(0, 50), 0))}):Play()

			task.delay(0.8, function()
				TweenService:Create(Shard, TweenInfo.new(0.2), {Size = Vector3.new(0.5, 0.5, Shard.Size.Z)}):Play()
			end)
		end
	end)
	
	local Offset = CFrame.new(1.13000488, -2.76000404, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	
	local DarkBankai = ReplicatedStorage.Assets.Effects.Shikais.DarkBankai:Clone()
	for i, v in ipairs(DarkBankai:GetDescendants()) do
		if v:IsA("ParticleEmitter") and v:GetAttribute("Color") then
			v.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color);
				ColorSequenceKeypoint.new(1, Color);
			})
		end
	end
	DarkBankai:PivotTo(Character.HumanoidRootPart.CFrame * Offset)
	DarkBankai.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(DarkBankai, 7) -- 2.3 max lifetime
	
	local Wind = DarkBankai.Wind
	Wind.Color = Color
	local Size = Wind.Size
	Wind.Position = Wind.Position
	Wind.Transparency = 1
	Wind.Size = Vector3.zero
	Debris:AddItem(Wind, 5)
	
	local Info = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false)
	TweenService:Create(Wind, Info, {Transparency = 0.6, Size = Size}):Play()
	
	local Duration = 2
	
	task.delay(Duration - Info.Time, function()
		TweenService:Create(Wind, Info, {Transparency = 1, Size = Size + Vector3.new(20, 20, 20)}):Play()
	end)
	
	local Connection
	Connection = RunService.RenderStepped:Connect(function(DeltaTime)
		Duration -= DeltaTime
		if Duration <= 0 then
			Connection:Disconnect()
			Connection = nil
			return
		end

		Wind.CFrame *= CFrame.Angles(0, 0.3, 0)
	end)
	
	local Positions = {} -- 6 beams
	for i, v in ipairs(DarkBankai.Beams:GetChildren()) do
		if v.Name == "BeamEnd" then
			Positions[v] = v.WorldPosition
			v.WorldPosition = DarkBankai.PrimaryPart.Position
			for _, Beam in ipairs(v:GetChildren()) do
				Beam.Enabled = false
				Beam.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color);
					ColorSequenceKeypoint.new(1, Color);
				})
			end
		end
	end
	for i, v in pairs(Positions) do
		for _, Beam in ipairs(i:GetChildren()) do
			Beam.Enabled = true
		end
		TweenService:Create(i, TweenInfo.new(0.7), {WorldPosition = v}):Play()
		Positions[i] = nil
		task.wait(1 / 6)
	end
	Positions = nil
	
	for i, v in ipairs(DarkBankai.Particles:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end
	task.delay(2, function()
		task.spawn(function()
			for i, v in ipairs(Model:GetChildren()) do
				TweenService:Create(v, TweenInfo.new(0.15), {Position = Character.HumanoidRootPart.Position}):Play()
				task.wait(1.2 / #Model:GetChildren())
			end
			Model:Destroy()
		end)
		
		for i, v in ipairs(DarkBankai.Beams:GetChildren()) do
			if v.Name == "BeamEnd" then
				TweenService:Create(v, TweenInfo.new(0.7), {WorldPosition = Character.HumanoidRootPart.Position}):Play()
				task.delay(0.7, function()
					for _, Beam in ipairs(v:GetChildren()) do
						Beam.Enabled = false
					end
				end)
				
				task.wait(0.5 / 6)
			end
		end
		
		task.wait(0.7)
		
		for i, v in ipairs(DarkBankai.DarkExplosion:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		for i, v in ipairs(DarkBankai:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Beam") then
				v.Enabled = false
			end
		end
	end)
end

function TemplateShikai.BankaiRelease(Character, EyeColor)
	if not EyeColor then
		EyeColor = {255, 255, 255}
	end
	local Color = Color3.fromRGB(EyeColor[1], EyeColor[2], EyeColor[3])
	
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player and Player.UserId == 57431326 then
		CustomRelease(Character, Color)
		return
	end
	
	local function AdjustColors(ParticleObject)
		for i, v in ipairs(ParticleObject:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Beam") then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color);
					ColorSequenceKeypoint.new(1, Color);
				})
			end
		end
	end
	local function ApplyParticles(Object, ParticleObject, Duration)
		AdjustColors(ParticleObject)
		
		for _, v in ipairs(ParticleObject:GetChildren()) do
			local Particle = v:Clone()
			Particle.Parent = Object

			if tonumber(Particle.Name) then
				Particle:Emit(tonumber(Particle.Name))
				Debris:AddItem(Particle, Particle.Lifetime.Max)
			else
				Debris:AddItem(Particle, Duration + Particle.Lifetime.Max)
				task.delay(Duration, function()
					Particle.Enabled = false
				end)
			end
		end
	end
	local function DisableParticles(ParticleObject, Duration)
		task.delay(Duration, function()
			for i, v in ipairs(ParticleObject:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	end
	local function Weld(Part0, Part1, C0)
		local Weld = Instance.new("Weld")
		Weld.C0 = C0
		Weld.Part0 = Part0
		Weld.Part1 = Part1
		Weld.Parent = Part0
		return Weld
	end
	
	local Stage1Duration = 1
	local Stage2Duration = 1
	local Stage3Duration = 2.5
	
	local BankaiEffects = ReplicatedStorage.Assets.Effects.Shikais.Bankai
	
	local BankaiReleaseSound = ReplicatedStorage.Assets.ShikaiSounds.BankaiRelease:Clone()
	BankaiReleaseSound.PlayOnRemove = true
	BankaiReleaseSound.Parent = Character.HumanoidRootPart
	BankaiReleaseSound:Destroy()
	BankaiReleaseSound = nil
	
	local BankaiStage1Smoke = BankaiEffects.Stage1smoke:Clone()
	AdjustColors(BankaiStage1Smoke)
	BankaiStage1Smoke.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(BankaiStage1Smoke, Stage1Duration + 1)
	DisableParticles(BankaiStage1Smoke, Stage1Duration)
	
	Weld(BankaiStage1Smoke, Character.HumanoidRootPart, CFrame.new(-0.00141906738, 0.768608332, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	
	for i, v in ipairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			ApplyParticles(v, BankaiEffects.Stage1bodyFX, Stage1Duration)
		end
	end
	
	task.wait(Stage1Duration)
	
	local Stage2Smoke = BankaiEffects.Stage1smoke:Clone()
	AdjustColors(Stage2Smoke)
	Stage2Smoke.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Stage2Smoke, Stage2Duration + 1.25)
	DisableParticles(Stage2Smoke, Stage2Duration)
	
	Weld(Stage2Smoke, Character.HumanoidRootPart, CFrame.new(0.0575866699, 0.768608332, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	
	for i, v in ipairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			ApplyParticles(v, BankaiEffects.Stage2FX, Stage2Duration + Stage3Duration)
		end
	end
	
	local Stage2Pressure = BankaiEffects.Stage2pressure:Clone()
	AdjustColors(Stage2Pressure)
	Stage2Pressure.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Stage2Pressure, Stage2Duration + Stage3Duration + 1.4)
	DisableParticles(Stage2Pressure, Stage2Duration + Stage3Duration)
	
	Weld(Stage2Pressure, Character.HumanoidRootPart, CFrame.new(0.000366210938, 0.0576477051, 11.7896032, -4.37113883e-08, 0, 1, 1, -4.37113883e-08, 4.37113883e-08, 4.37113883e-08, 1, 1.91068547e-15))
	
	task.wait(Stage2Duration)
	
	local Stage3Smoke = BankaiEffects.Stage3smoke:Clone()
	AdjustColors(Stage3Smoke)
	Stage3Smoke.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Stage3Smoke, Stage3Duration + 1.25)
	DisableParticles(Stage3Smoke, Stage3Duration)
	
	Weld(Stage3Smoke, Character.HumanoidRootPart, CFrame.new(0.0575866699, 0.768608332, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	
	local Stage3Pressure = BankaiEffects.Stage3pressure:Clone()
	AdjustColors(Stage3Pressure)
	Stage3Pressure.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Stage3Pressure, Stage3Duration + 1.4)
	DisableParticles(Stage3Pressure, Stage3Duration)
	
	Weld(Stage3Pressure, Character.HumanoidRootPart, CFrame.new(0.000366210938, 0.0576477051, 11.7896032, -4.37113883e-08, 0, 1, 1, -4.37113883e-08, 4.37113883e-08, 4.37113883e-08, 1, 1.91068547e-15))
	
	local Stage3Absorb = BankaiEffects.Stage3absorb:Clone()
	AdjustColors(Stage3Absorb)
	Stage3Absorb.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Stage3Absorb, Stage3Duration + 1)
	DisableParticles(Stage3Absorb, Stage3Duration)
	
	Weld(Stage3Absorb, Character.HumanoidRootPart, CFrame.new(0.00048828125, 0, 0.000366210938, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	
	local RootCFrame = Character.HumanoidRootPart.CFrame
	
	local Cylinder = BankaiEffects.cylinder:Clone()
	Cylinder.Color = Color
	Cylinder.Size = Vector3.new(0, Cylinder.Size.Y, 0)
	Cylinder.CFrame = RootCFrame * CFrame.new(0, -2.9, 0) * CFrame.new(0, Cylinder.Size.Y/2, 0)
	Cylinder.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Cylinder, Stage3Duration * 2)
	
	local Wind = BankaiEffects.wind:Clone()
	Wind.Color = Color
	Wind.Size = Vector3.new(0, Wind.Size.Y, 0)
	Wind.CFrame = RootCFrame * CFrame.new(0, -2, 0) * CFrame.new(0, -Wind.Size.Y/2, 0)
	Wind.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Wind, Stage3Duration * 2)
	
	local Info = TweenInfo.new(Stage3Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(Cylinder, Info, {Size = Vector3.new(25, Cylinder.Size.Y, 25)}):Play()
	TweenService:Create(Wind, Info, {Size = Vector3.new(35, Wind.Size.Y, 35)}):Play()
	
	local BankaiRelease = BankaiEffects.BankaiRelease:Clone()
	AdjustColors(BankaiRelease)
	BankaiRelease.CFrame = RootCFrame * CFrame.new(0.0112609863, -0.768608332, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	BankaiRelease.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(BankaiRelease, Stage3Duration + 6)
	
	task.delay(Stage3Duration + 0.25, function()
		for i, v in ipairs(BankaiRelease.Enable:GetChildren()) do
			v.Enabled = false
		end
	end)
	
	local DisconnectLeft = Stage3Duration * 2
	local Counter = 0
	local Movement = 2
	local Connection
	Connection = RunService.RenderStepped:Connect(function(DeltaTime)
		DisconnectLeft -= DeltaTime
		Counter += 1
		if DisconnectLeft <= 0 then
			Connection:Disconnect()
			Connection = nil
		end
		
		Wind.CFrame *= CFrame.Angles(0, 0.5, 0)
		
		if Counter % 10 == 0 then
			Wind.Position = RootCFrame.Position + Vector3.new(Movement, -2, 0)
		elseif Counter % 10 == 2 then
			Wind.Position = RootCFrame.Position + Vector3.new(0, -2, -Movement)
		elseif Counter % 10 == 4 then
			Wind.Position = RootCFrame.Position + Vector3.new(-Movement, -2, 0)
		elseif Counter % 10 == 6 then
			Wind.Position = RootCFrame.Position + Vector3.new(0, -2, Movement)
		elseif Counter % 10 == 8 then
			Wind.Position = RootCFrame.Position + Vector3.new(0, -2, 0)
		end
	end)
	
	task.delay(Stage3Duration, function()
		local Info2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(Cylinder, Info2, {Size = Vector3.new(0, Cylinder.Size.Y, 0), Transparency = 1}):Play()
		TweenService:Create(Wind, Info2, {Size = Vector3.new(65, Wind.Size.Y, 65), Transparency = 1}):Play()
		
		for i, v in ipairs(BankaiRelease.Emit:GetChildren()) do
			local Amount = tonumber(v.Name)
			v:Emit(Amount)
		end
	end)
end

return TemplateShikai
