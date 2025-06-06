local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local ClientProjectile = require(ReplicatedStorage.Modules.Utility.ClientProjectile)
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local ImpactCrater = require(ReplicatedStorage.Modules.Utility.ImpactCrater)
local Bezier = require(ReplicatedStorage.Modules.Utility.Bezier)
local CameraShaker = require(ReplicatedStorage.Modules.Utility.CameraShaker)
local FlashstepClient = require(ReplicatedStorage.Modules.ClientModules.FlashstepClient)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local KendoEffects = ReplicatedStorage.Assets.Effects.Kendo
local KidoEffects = ReplicatedStorage.Assets.Effects.Kido
local SpeedEffects = ReplicatedStorage.Assets.Effects.Speed
local HakudaEffects = ReplicatedStorage.Assets.Effects.Hakuda
local SpecialEffects = ReplicatedStorage.Assets.Effects.Special
local HealingEffects = ReplicatedStorage.Assets.Effects.Healing
local HollowEffects = ReplicatedStorage.Assets.Effects.Hollow
local QuincyKidoEffects = ReplicatedStorage.Assets.Effects.QuincyKido

local KendoSounds = ReplicatedStorage.Assets.SkillSounds.Kendo
local KidoSounds = ReplicatedStorage.Assets.SkillSounds.Kido
local SpeedSounds = ReplicatedStorage.Assets.SkillSounds.Speed
local HakudaSounds = ReplicatedStorage.Assets.SkillSounds.Hakuda
local SpecialSounds = ReplicatedStorage.Assets.SkillSounds.Special
local HealingSounds = ReplicatedStorage.Assets.SkillSounds.Healing
local HollowSounds = ReplicatedStorage.Assets.SkillSounds.Hollow
local QuincyKidoSounds = ReplicatedStorage.Assets.SkillSounds.QuincyKido

--[[
function ClientSkills.TEMPLATE(Character)
	print("Client side")
end
]]

local HumanCheck = {
	Shinigami = true;
	Visored = true;
}

local HollowCheck = {
	VastoLorde = true;
	Arrancar = true;
	Vastocar = true;
	Hollow = true;
}

local CeroColors = {
	Hakuda = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page1Frame.Hakuda.ImageColor3;
	Kendo = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page1Frame.Kendo.ImageColor3;
	Kido = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page1Frame.Kido.ImageColor3;
	Healing = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page2Frame.Healing.ImageColor3;
	Speed = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page2Frame.Speed.ImageColor3;
	--Special = ReplicatedStorage.Assets.UIs.SkillTree.MainFrame.page2Frame.Special.ImageColor3;
	Visored = Color3.fromRGB(191, 191, 191);
}

local function GetXandZPosition(Angle, Radius)
	local X = math.cos(Angle) * Radius
	local Z = math.sin(Angle) * Radius
	return X, Z
end

local function color3ToVector3(c3)
	return Vector3.new(c3.r, c3.g, c3.b)
end

local function PaleColor(Color, Factor)
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S * Factor, V * Factor)
end

local ClientSkills = {}

function ClientSkills.GrayScreen(Character, Duration)
	local GrayScreen = Instance.new("ColorCorrectionEffect")
	GrayScreen.Saturation = -1
	GrayScreen.Parent = game:GetService("Lighting")
	Debris:AddItem(GrayScreen, Duration)
end

function ClientSkills.ScreenShake(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)
	
	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Explosion2)
	
	task.delay(1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end

function ClientSkills.ScreenShake3(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Explosion3)

	task.delay(1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end

function ClientSkills.ScreenShake4(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Explosion4)

	task.delay(1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end

function ClientSkills.CeroScreenShake(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Cero)

	task.delay(1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end

function ClientSkills.CeroScreenShake2(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Cero2)

	task.delay(1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end


-- Organized by category -- 

--==================================================
--=====================Hollow=======================
--==================================================

function ClientSkills.CeroIndicator(Character, SpawnPoint, Properties, HighestStat)
	local CeroFloor = HollowEffects.CeroFloorIndicator:Clone()
	if HighestStat then
		CeroFloor.Color = CeroColors[HighestStat]
	end
	CeroFloor.Size = Vector3.new(Properties.Width * 2, 0.1, Properties.Range)
	CeroFloor.CFrame = SpawnPoint * CFrame.new(0, -2.5, -Properties.Range / 2)
	CeroFloor.Transparency = 1
	CeroFloor.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(CeroFloor, 0.8)
	
	TweenService:Create(CeroFloor, TweenInfo.new(0.3), {Transparency = 0}):Play()
	task.delay(0.5, function()
		TweenService:Create(CeroFloor, TweenInfo.new(0.3), {Transparency = 1}):Play()
	end)
end

function ClientSkills.Bala(Character, MousePosition, Speed, HighestStat)
	local Bala = HollowEffects.Bala:Clone()
	Bala.CFrame = CFrame.new((Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)).Position, MousePosition)
	Bala.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Bala, 2)
	
	ClientProjectile:Projectile(Character, Bala, MousePosition, Speed)
	
	if HighestStat then
		Bala.Color = CeroColors[HighestStat]
		Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
		Bala.Attachment.ParticleColor.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
			ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
		})
		Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
			ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
		})
	end
	
	local BalaSound = HollowSounds.Bala:Clone()
	BalaSound.PlayOnRemove = true
	BalaSound.Parent = Character.PrimaryPart
	BalaSound:Destroy()
	BalaSound = nil
end

function ClientSkills.PoweredBala(Character, Target, Speed)
	local BalaSound = HollowSounds.Bala:Clone()
	BalaSound.PlayOnRemove = true
	BalaSound.Parent = Character.PrimaryPart
	BalaSound:Destroy()
	BalaSound = nil
end

function ClientSkills.Cero(Character, Phase, HeadCFrame, RootCFrame, CeroStats, ReleaseSpeed, Properties)
	if Phase == "1" then
		local CeroCharge = HollowEffects.CeroCharge.Attachment:Clone()
		CeroCharge.Position = Vector3.new(0, 0, -2)
		CeroCharge.Parent = Character.Head
		Debris:AddItem(CeroCharge, 3)
		
		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		
		if HighestStat then
			for i, v in ipairs(CeroCharge:GetChildren()) do
				if v.Name == "Smoke" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
					})
				elseif v.Name == "Rays" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.3)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.3)),
					})
				elseif v.Name ~= "Particle" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
						ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
					})
				end
			end
		end
		
		local ChargeSound = HollowSounds.CeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)
		
		local DelayTime = 1.7
		if CeroStats then
			DelayTime -= (2 - ReleaseSpeed)
		end
		local BallLifeTime = DelayTime / 4.25
		
		for i, v in ipairs(CeroCharge:GetChildren()) do
			if v.Name ~= "Ball" then
				v.Enabled = true
			end
		end
		CeroCharge.Ball.Lifetime = NumberRange.new(BallLifeTime, BallLifeTime)
		CeroCharge.Ball:Emit(1)
		
		task.delay(DelayTime, function()
			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			for i, v in ipairs(CeroCharge:GetChildren()) do
				v.Enabled = false
			end
			
			local CeroIndication = HollowEffects.CeroIndication:Clone()
			if HighestStat then
				for i, v in ipairs(CeroIndication:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
							ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
						})
					end
				end
			end
			CeroIndication.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(CeroIndication, 0.2)
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = CeroIndication
			Weld.Part1 = Character.HumanoidRootPart
			Weld.Parent = CeroIndication
			
			for i, v in ipairs(CeroIndication:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.Name))
				end
			end
		end)
	elseif Phase == "2" then	
		local Cero = HollowEffects.Cero:Clone()
		
		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end
		
		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil
		
		local HeadRX, HeadRY, HeadRZ = HeadCFrame:ToOrientation()
		local RootRX, RootRY, RootRZ = RootCFrame:ToOrientation()
		
		local MultiplierIncrease = 0.6
		if CeroStats and CeroStats.Kido >= 40 then
			MultiplierIncrease = 0.45
		end
		local BeamSize = Vector3.new(11.71, 11.042, 53.064)
		local CeroSize = Vector3.new(9.569, 9.538, 52.213)
		if CeroStats then
			BeamSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
			CeroSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
		end
		
		Cero.PrimaryPart.CFrame = CFrame.new(HeadCFrame.Position) * CFrame.fromOrientation(0, RootRY, RootRZ) * CFrame.new(Vector3.new(0, 0, (-BeamSize.Z / 2) - 1))
		Cero.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end
		
		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)
		
		TweenService:Create(Cero.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(Cero.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)
		
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = Cero.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)
		
		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)
	end
end

function ClientSkills.MenosCero(Character, Phase, HeadCFrame, LookAt, HighestStat)
	if Phase == "1" then
		local CeroCharge = HollowEffects.MenosCeroCharge.Attachment:Clone()
		CeroCharge.Position = Vector3.new(0, 0, -10)
		CeroCharge.Parent = Character.Head
		Debris:AddItem(CeroCharge, 6)
		
		if HighestStat then
			for i, v in ipairs(CeroCharge:GetChildren()) do
				if v.Name == "Smoke" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
					})
				elseif v.Name == "Rays" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.3)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.3)),
					})
				elseif v.Name ~= "Particle" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
						ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
					})
				end
			end
		end

		local ChargeSound = HollowSounds.CeroChargeMenos:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		ChargeSound.Volume = 8

		for i, v in ipairs(CeroCharge:GetChildren()) do
			if v.Name ~= "Ball" then
				v.Enabled = true
			end
		end
		CeroCharge.Ball:Emit(1)

		task.delay(4.7, function()
			for i, v in ipairs(CeroCharge:GetChildren()) do
				v.Enabled = false
			end
			TweenService:Create(ChargeSound, TweenInfo.new(0.5), {Volume = 0}):Play()
			Debris:AddItem(ChargeSound, 0.5)
		end)
	elseif Phase == "2" then	
		local Cero = HollowEffects.MenosCero:Clone()
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end
		Cero.PrimaryPart.CFrame = CFrame.new(HeadCFrame.Position, LookAt) * CFrame.new(Vector3.new(0, 0, (-Cero.Beam.Size.Z / 2) - 10))
		Cero.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound.Volume = 8
		CeroFireSound:Destroy()
		CeroFireSound = nil

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(34.278, 31.923, 246.167)}):Play()
		TweenService:Create(Cero.cero, Info, {Size = Vector3.new(26.72, 26.612, 242.817)}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(35.278, 36.923, 251.167)}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(31.72, 31.612, 247.817)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = Cero.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, 251.167), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, 247.817), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)
	end
end

function ClientSkills.CeroOscuras(Character, Phase, SpawnCFrame, CeroStats, ReleaseSpeed, Properties)
	if Phase == "1" then
		local OscurasCharge = HollowEffects.CeroOscurasCharge:Clone()
		OscurasCharge.Anchored = false
		OscurasCharge.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(OscurasCharge, 2)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0, -5.4359436e-05, 1.25244141, 1, 0, 0, 0, 0, -1, 0, 1, 0)
		Weld.Part0 = OscurasCharge
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = OscurasCharge
		
		local OscurasStartup = HollowEffects.CeroOscurasStartup:Clone()
		OscurasStartup.Anchored = false
		OscurasStartup.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(OscurasStartup, 2)
		
		local StartupWeld = Instance.new("Weld")
		StartupWeld.C0 = CFrame.new(0, -7.96318054e-05, 1.25250244, 1, 0, 0, 0, 0, -1, 0, 1, 0)
		StartupWeld.Part0 = OscurasStartup
		StartupWeld.Part1 = Character["Left Arm"]
		StartupWeld.Parent = OscurasStartup
		
		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		if HighestStat then
			OscurasCharge.AbsorbShard2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			
			for i, v in ipairs(OscurasStartup.Enable:GetChildren()) do
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
					ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
				})
			end
			for i, v in ipairs(OscurasStartup.Emit1:GetChildren()) do
				if v.Name ~= "Ball" then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
					})
				end
			end
		end

		local ChargeSound = HollowSounds.CeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)
		
		local DelayTime = 1.7
		if CeroStats then
			DelayTime -= (2 - ReleaseSpeed)
		end
		local BallLifeTime = DelayTime + 1
		
		for i, v in ipairs(OscurasStartup:GetDescendants()) do
			if v:IsA("ParticleEmitter") and v.Name ~= "Ball" then
				v.Enabled = true
			end
		end
		OscurasStartup.Emit1.Ball.Lifetime = NumberRange.new(BallLifeTime, BallLifeTime)
		OscurasStartup.Emit1.Ball:Emit(1)

		task.delay(DelayTime, function()
			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			for i, v in ipairs(OscurasStartup:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			for i, v in ipairs(OscurasCharge:GetChildren()) do
				v.Enabled = false
			end
		end)
	elseif Phase == "2" then					
		local Cero = HollowEffects.CeroOscuras:Clone()
		Debris:AddItem(Cero, 1.95)
		
		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end
		
		local OscurasRelease = HollowEffects.OscurasRelease:Clone()
		OscurasRelease.CFrame = SpawnCFrame * CFrame.new(0, 0, -3) * CFrame.Angles(-math.pi/2, 0, 0)
		OscurasRelease.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(OscurasRelease, 2.75)
		
		for i, v in ipairs(OscurasRelease.Attachment:GetChildren()) do
			if HighestStat then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
					ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
				})
			end
			v.Enabled = true
			task.delay(0.3, function()
				v.Enabled = false
			end)
		end
		
		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil
		
		local MultiplierIncrease = 0.6
		if CeroStats and CeroStats.Kido >= 40 then
			MultiplierIncrease = 0.45
		end
		local BeamSize = Vector3.new(17.264, 16.279, 138.582)
		local CeroSize = Vector3.new(14.107, 14.062, 137.108)
		if CeroStats then
			BeamSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
			CeroSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
		end
		
		Cero.PrimaryPart.CFrame = SpawnCFrame * CFrame.new(Vector3.new(0, 0, (-BeamSize.Z / 2) - 4))
		Cero.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize}):Play()
		task.delay(0.5, function() -- 0.5
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(Cero.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)
		
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated >= 1.95 then
				Connection:Disconnect()
				Connection = nil
				return
			end
			
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)

		task.delay(1.05, function() -- 1.55
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
		end)
	end
end

function ClientSkills.Instinct(Character, Phase)
	if Phase == "Enabled" then
		local InstinctActivate = HollowSounds.InstinctActivate:Clone()
		InstinctActivate.PlayOnRemove = true
		InstinctActivate.Parent = Character.HumanoidRootPart
		InstinctActivate:Destroy()
		InstinctActivate = nil
	elseif Phase == "Disabled" then
		local InstinctDeactivate = HollowSounds.InstinctDeactivate:Clone()
		InstinctDeactivate.PlayOnRemove = true
		InstinctDeactivate.Parent = Character.HumanoidRootPart
		InstinctDeactivate:Destroy()
		InstinctDeactivate = nil
	end
end

function ClientSkills.HierroActivate(Character)
	local HierroActivateSound = KendoSounds.HierroActivate:Clone()
	HierroActivateSound.Parent = Character.PrimaryPart
	HierroActivateSound:Play()
	Debris:AddItem(HierroActivateSound, HierroActivateSound.TimeLength)
end

function ClientSkills.HierroDeactivate(Character)
	local HierroDeactivateSound = KendoSounds.HierroDeactivate:Clone()
	HierroDeactivateSound.Parent = Character.PrimaryPart
	HierroDeactivateSound:Play()
	Debris:AddItem(HierroDeactivateSound, HierroDeactivateSound.TimeLength)
end

function ClientSkills.HierroIndicator(Character, State)
	if State == "On" and Character:GetAttribute("HierroHits")then
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.TextLabel.Text = "Hierro: " .. Character:GetAttribute("HierroHits")
		HierroFrame.Visible = true
	elseif State == "Off" then
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.Visible = false
	end
end

function ClientSkills.HighSpeedStart(Character)
	local SelfHealSound = HealingSounds.SelfHeal:Clone()
	SelfHealSound.Parent = Character.HumanoidRootPart
	SelfHealSound:Play()
	Debris:AddItem(SelfHealSound, SelfHealSound.TimeLength)

	local SelfHealEffect = HealingEffects.HealFX:Clone()
	SelfHealEffect.Anchored = false
	SelfHealEffect.Name = "HighSpeedFX"
	SelfHealEffect.Parent = workspace.Effects[Character.Name]

	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(8.77380371e-05, 2.99953294, 0.00020980835, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Part0 = SelfHealEffect
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = SelfHealEffect

	SelfHealEffect.Specs.Enabled = true
	SelfHealEffect.Attachment.Particle.Enabled = true
end

function ClientSkills.HighSpeedStop(Character)
	for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
		if v.Name == "HighSpeedFX" then
			v.Specs.Enabled = false
			v.Attachment.Particle.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
end

function ClientSkills.HighSpeedAudio(Character)
	local SelfHealSound = HealingSounds.SelfHeal:Clone()
	SelfHealSound.Parent = Character.HumanoidRootPart
	SelfHealSound:Play()
	Debris:AddItem(SelfHealSound, SelfHealSound.TimeLength)
end

function ClientSkills.FingerCero(Character, Phase, RootCFrame, HighestStat, CeroStats, Properties)
	if Phase == "1" then
		local FingerCeroStartup = HollowEffects.FingerCeroStartup:Clone()
		FingerCeroStartup.PrimaryPart.Anchored = false
		FingerCeroStartup.Ball.Transparency = 1
		FingerCeroStartup.Ball.Size = Vector3.zero
		FingerCeroStartup.Center.Transparency = 1
		FingerCeroStartup.Center.Size = Vector3.zero
		FingerCeroStartup.Parent = Character["Left Arm"]
		Debris:AddItem(FingerCeroStartup, 3)
		
		local InitialInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(FingerCeroStartup.Ball, InitialInfo, {Transparency = 0.75, Size = Vector3.new(1.5, 1.5, 1.5)}):Play()
		TweenService:Create(FingerCeroStartup.Center, InitialInfo, {Transparency = 0, Size = Vector3.new(1.223, 1.223, 1.223)}):Play()
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0, -4.76837158e-07, 1.85787964, 1, -7.22266691e-12, -2.64662264e-10, 2.48291887e-10, 3.08318648e-10, -0.999996483, 1.40438772e-11, 1, -3.08317732e-10)
		Weld.Part0 = FingerCeroStartup.PrimaryPart
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = FingerCeroStartup.PrimaryPart

		if HighestStat then
			FingerCeroStartup.Ball.Color = CeroColors[HighestStat]
			FingerCeroStartup.Ring1.Color = CeroColors[HighestStat]
			FingerCeroStartup.Ring2.Color = CeroColors[HighestStat]
			
			for i, v in ipairs(FingerCeroStartup.Ball.Attachment:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
					})
				elseif v:IsA("PointLight") then
					v.Color = CeroColors[HighestStat]
				end
			end
		end

		local ChargeSound = HollowSounds.CeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)

		local DelayTime = 0.41
		local BallLifeTime = DelayTime / 4.25

		task.delay(DelayTime, function()
			Weld:Destroy()
			FingerCeroStartup.PrimaryPart.Anchored = true
			Debris:AddItem(FingerCeroStartup, 0.5)
			
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
			local Info2 = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true)
			for i = 1, 2 do
				local Ring = FingerCeroStartup["Ring" .. i]
				Ring.Anchored = true
				Ring.WeldConstraint:Destroy()
				
				local Size = Ring.Size
				Ring.Size = Vector3.zero
				
				TweenService:Create(Ring, Info, {CFrame = Ring.CFrame * CFrame.new(0, -3, 0), Size = Size}):Play()
				TweenService:Create(Ring, Info2, {Transparency = 0.75}):Play()
			end
			
			TweenService:Create(FingerCeroStartup.Ball, InitialInfo, {Transparency = 1}):Play()
			TweenService:Create(FingerCeroStartup.Center, InitialInfo, {Transparency = 1}):Play()
			
			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			for i, v in ipairs(FingerCeroStartup.Ball.Attachment:GetChildren()) do
				v.Enabled = false
			end
		end)
	elseif Phase == "2" then	
		local Cero = HollowEffects.FingerCero:Clone()
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil

		local BeamSize = Vector3.new(2, 2, 141.321)
		local CeroSize = Vector3.new(0.4, 0.4, 140.629)
		if CeroStats then
			local MultiplierIncrease =  0.6
			
			BeamSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
			CeroSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
		end
		
		Cero.PrimaryPart.CFrame = RootCFrame * CFrame.new(0, 0.4, -3)
		Cero.Parent = workspace.Effects[Character.Name]
		
		local BeamPosition = (Cero.Beam.CFrame * CFrame.new(0, 0, -BeamSize.Z / 2)).Position
		local CeroPosition = (Cero.cero.CFrame * CFrame.new(0, 0, -CeroSize.Z / 2)).Position
		
		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = BeamSize, Position = BeamPosition}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize, Position = CeroPosition}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 0.5), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 0.5), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 0.5)
		end)
		local DestroyConnection
		DestroyConnection = Cero.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)
	end
end

function ClientSkills.TriCero(Character, Phase, RootCFrame, HighestStat, CeroNumber, CeroStats, Properties)
	if Phase == "1" then
		local CeroSpawns = {
			[1] = Vector3.new(0, 1.5, -2);
			[2] = Vector3.new(-2, 1, -2);
			[3] = Vector3.new(2, 1, -2);
		}
		
		local FakeRoot = HollowEffects.TriCeroStartup:Clone()
		FakeRoot.Anchored = false
		if HighestStat then
			FakeRoot.Beam1.Color = CeroColors[HighestStat]
			FakeRoot.Beam2.Color = CeroColors[HighestStat]
		end
		FakeRoot.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FakeRoot, 2)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = FakeRoot
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = FakeRoot
		
		local DelayTime = 1
		local BallLifeTime = DelayTime / 4.25
		
		for i, v in ipairs(FakeRoot:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 1

				local Info = TweenInfo.new(DelayTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
				TweenService:Create(v, Info, {Transparency = 0}):Play()
			end
		end
		
		for i = 1, 3 do
			local CeroCharge = HollowEffects.CeroCharge.Attachment:Clone()
			CeroCharge.Position = CeroSpawns[i]
			CeroCharge.Parent = FakeRoot

			if HighestStat then
				for i, v in ipairs(CeroCharge:GetChildren()) do
					if v.Name == "Smoke" then
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
							ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
						})
					elseif v.Name == "Rays" then
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.3)),
							ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.3)),
						})
					elseif v.Name ~= "Particle" then
						v.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
							ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
						})
					end
				end
			end
			
			local ChargeSound
			ChargeSound = HollowSounds.CeroCharge:Clone()
			ChargeSound.Parent = Character.PrimaryPart
			ChargeSound:Play()
			Debris:AddItem(ChargeSound, 2.2)

			for i, v in ipairs(CeroCharge:GetChildren()) do
				if v.Name ~= "Ball" then
					v.Enabled = true
				end
			end
			CeroCharge.Ball.Lifetime = NumberRange.new(BallLifeTime, BallLifeTime)
			CeroCharge.Ball:Emit(1)
			
			task.delay(BallLifeTime, function()
				if Weld then
					Weld:Destroy()
					FakeRoot.Anchored = true
				end
			end)

			task.delay(DelayTime, function()
				if ChargeSound then
					TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
				end
				for i, v in ipairs(CeroCharge:GetChildren()) do
					v.Enabled = false
				end
			end)
		end
	elseif Phase == "2" then	
		local Cero = HollowEffects.TriCero:Clone()
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil

		local BeamSize = Vector3.new(2.5, 2.5, 75.853)
		local CeroSize = Vector3.new(1.5, 1.5, 75.653)
		if CeroStats then
			local MultiplierIncrease =  0.6

			BeamSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
			CeroSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
		end
		
		Cero.PrimaryPart.CFrame = RootCFrame * CFrame.new(0, 0, -3)
		Cero.Parent = workspace.Effects[Character.Name]

		local BeamPosition = (Cero.Beam.CFrame * CFrame.new(0, 0, -BeamSize.Z / 2))
		local CeroPosition = (Cero.cero.CFrame * CFrame.new(0, 0, -CeroSize.Z / 2))
		
		local AngledCFrame
		if CeroNumber == 2 then
			AngledCFrame = Cero.Beam.CFrame * CFrame.Angles(0, math.pi/2.5, 0) * CFrame.new(0, 0, -BeamSize.Z / 2)
		elseif CeroNumber == 3 then
			AngledCFrame = Cero.Beam.CFrame * CFrame.Angles(0, -math.pi/2.5, 0) * CFrame.new(0, 0, -BeamSize.Z / 2)
		end
		
		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local Info = TweenInfo.new(0.22, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize}):Play()
		TweenService:Create(Cero.PrimaryPart, Info, {CFrame = BeamPosition}):Play()
		task.delay(0.25, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			local Info2 = TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)
			local SizeChange = 0.45
			TweenService:Create(Cero.Beam, Info2, {Size = BeamSize + Vector3.new(SizeChange, SizeChange, SizeChange)}):Play()
			TweenService:Create(Cero.cero, Info2, {Size = CeroSize + Vector3.new(SizeChange, SizeChange, SizeChange)}):Play()
			if AngledCFrame then
				TweenService:Create(Cero.PrimaryPart, Info, {CFrame = AngledCFrame}):Play()
			end
		end)

		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 0.5), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 0.5), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)
	end
end

function ClientSkills.CeroCornea(Character, Phase, MousePosition, HighestStat, Radius, Speed)
	if Phase == "1" then
		local CeroCorneaIndicator = HollowEffects.CeroCorneaIndicator:Clone()
		CeroCorneaIndicator.CFrame = CFrame.new(MousePosition) * CFrame.Angles(math.pi / 2, 0, 0)
		CeroCorneaIndicator.Size = Vector3.new(Radius, Radius, 0.5)
		CeroCorneaIndicator.Transparency = 1
		
		if HighestStat then
			CeroCorneaIndicator.Color = CeroColors[HighestStat]
			CeroCorneaIndicator.ColorParticle.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			
			
			CeroCorneaIndicator.PointLight.Color = CeroColors[HighestStat]
			CeroCorneaIndicator.PointLight.Range = Radius
		end
		
		CeroCorneaIndicator.Parent = workspace.Effects[Character.Name]
		CeroCorneaIndicator.ColorParticle.Enabled = true
		
		local PercentDecrease = 1 / Speed
		
		local RetinaFadeTime = 0.2
		local WindupTime = 0.47 * PercentDecrease
		
		local CeroRetina = HollowEffects.CeroRetina:Clone()
		CeroRetina.PrimaryPart.Anchored = false
		CeroRetina.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroRetina, WindupTime + RetinaFadeTime)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-1.29766083, -1.94099998, -0.522506714, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		Weld.Part0 = CeroRetina.PrimaryPart
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = CeroRetina.PrimaryPart
		
		
		local RetinaInfo = TweenInfo.new(RetinaFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		for i = 1, 2 do
			if HighestStat then
				CeroRetina["Retina" .. i].Color = CeroColors[HighestStat]
			end
			CeroRetina["Retina" .. i].Transparency = 1
			TweenService:Create(CeroRetina["Retina" .. i], RetinaInfo, {Transparency = 0}):Play()
			task.delay(WindupTime - RetinaFadeTime, function()
				TweenService:Create(CeroRetina["Retina" .. i], TweenInfo.new(WindupTime), {Transparency = 1}):Play()
			end)
		end
		
		local RetinaAnimation = ReplicatedStorage.Assets.SkillAnimations.Hollow.CeroRetina
		local CeroRetinaAnimation = CeroRetina.AnimationController.Animator:LoadAnimation(RetinaAnimation)
		CeroRetinaAnimation:Play()
		
		local Info = TweenInfo.new(WindupTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(CeroCorneaIndicator, Info, {Transparency = 0.4, Size = Vector3.new(Radius * 2, Radius * 2, 0.5)}):Play()
		
		local ChargeSound
		ChargeSound = HollowSounds.CeroCorneaInitial:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)
		
		task.delay(WindupTime, function()
			if ChargeSound then
				TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			end
			CeroCorneaIndicator.ColorParticle.Enabled = false
			TweenService:Create(CeroCorneaIndicator, Info, {Transparency = 1}):Play()
			Debris:AddItem(CeroCorneaIndicator, WindupTime)
		end)
	elseif Phase == "2" then
		local CeroCorneaExplosion = HollowEffects.CeroCorneaExplosion:Clone()
		CeroCorneaExplosion.CFrame = CFrame.new(MousePosition)
		CeroCorneaExplosion.Size = Vector3.zero
		CeroCorneaExplosion.Parent = workspace.Effects[Character.Name]
		
		if HighestStat then
			CeroCorneaExplosion.Color = CeroColors[HighestStat]
		end

		local CeroFireSound = HollowSounds.CeroCorneaImpact:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = CeroCorneaExplosion
		CeroFireSound:Destroy()
		CeroFireSound = nil
		
		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(CeroCorneaExplosion, Info, {Transparency = 1, Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2)}):Play()
		Debris:AddItem(CeroCorneaExplosion, 0.55)
		
		local CeroExplosionEffect = HollowEffects.CeroExplosionEffect:Clone()
		CeroExplosionEffect.CFrame = CFrame.new(MousePosition)		
		CeroExplosionEffect.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroExplosionEffect, 2)
		
		for i, v in ipairs(CeroExplosionEffect.Attachment:GetChildren()) do
			if v.Name == "COLOR" and v:IsA("ParticleEmitter") then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
					ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
				})
			end
		end
		for i, v in ipairs(CeroExplosionEffect.Attachment:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(50)
			end
		end
		
		local RetinaPosition = (Character.HumanoidRootPart.CFrame * CFrame.new(0.522506714, 1.94099998, -1.29766083)).Position
		local Magnitude = (Character.Head.Position - MousePosition).Magnitude
		local CorneaBeam = HollowEffects.CorneaBeam:Clone()
		if HighestStat then
			CorneaBeam.Color = CeroColors[HighestStat]
		end
		
		CorneaBeam.Size = Vector3.new(Magnitude, 0.12, 0.12)
		CorneaBeam.CFrame = CFrame.new(RetinaPosition, MousePosition) * CFrame.new(0, 0, -Magnitude/2) * CFrame.Angles(0, math.pi/2, 0)
		CorneaBeam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CorneaBeam, 0.416)
		
		local Transparencies = {
			[1] = 1;
			[2] = 0;
		}
		
		for i = 1, 2 do
			CorneaBeam.Transparency = Transparencies[i]
			task.wait(0.06)
		end
		for i = 1, 2 do
			CorneaBeam.Transparency = Transparencies[i]
			task.wait(0.02)
		end
		
		local Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(CorneaBeam, Info, {Transparency = 1}):Play()
	end
end

function ClientSkills.BladeCero(Character, Phase, HighestStat, Speed, RootCFrame, ReleaseSpeed)
	if Phase == "1" then
		local WeaponColor = Color3.fromRGB(255, 35, 35)
		if HighestStat then
			WeaponColor = PaleColor(CeroColors[HighestStat], 0.5)
		end
		
		local ReleasedTime = ReleaseSpeed --- (ReleaseSpeed * 0.73)
		local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
		if Weapon then
			for i, v in ipairs(Weapon:GetDescendants()) do
				if v:IsA("BasePart") then
					local PreviousColor = v.Color
					local PreviousMaterial = v.Material
					v.Material = Enum.Material.Neon
					TweenService:Create(v, TweenInfo.new(ReleasedTime), {Color = WeaponColor}):Play()

					task.delay(ReleasedTime, function()
						TweenService:Create(v, TweenInfo.new(0.3), {Color = PreviousColor}):Play()
						task.wait(0.3)
						v.Material = PreviousMaterial
					end)
				end
			end
		end
		
		local BallLifeTime = ReleasedTime / 4.25
		
		local BladeCeroEffect = HollowEffects.BladeCeroBall:Clone()
		BladeCeroEffect.Anchored = false
		BladeCeroEffect.Emit1.Ball.Lifetime = NumberRange.new(BallLifeTime)
		BladeCeroEffect.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BladeCeroEffect, ReleaseSpeed + 1)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.0166320801, 1.5, 0.0432739258, -0.999999046, 0, 0, 0, 1, 0, 0, 0, -1)
		Weld.Part0 = BladeCeroEffect
		Weld.Part1 = Character["Right Arm"]
		Weld.Parent = BladeCeroEffect
		
		if HighestStat then
			for i, v in ipairs(BladeCeroEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
						ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
					})
				end
			end
		end
		
		for i, v in ipairs(BladeCeroEffect.Emit10:GetChildren()) do
			v:Emit(10)
		end
		for i, v in ipairs(BladeCeroEffect.Emit1:GetChildren()) do
			v:Emit(1)
		end
		
		local ChargeSound = HollowSounds.BladeCeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)

		task.delay(ReleaseSpeed - 0.3, function()
			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			for i, v in ipairs(BladeCeroEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "2" then
		local BladeCero = HollowEffects.BladeCero:Clone()
		
		local Highlight = Instance.new("Highlight")
		Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		Highlight.FillTransparency = 1
		Highlight.FillColor = Color3.fromRGB(0, 0, 0)
		Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		Highlight.Parent = BladeCero
		
		if HighestStat then
			BladeCero.Color = CeroColors[HighestStat]
			BladeCero.Trail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})
			BladeCero.PointLight.Color = CeroColors[HighestStat]
		end

		BladeCero.CFrame = RootCFrame * CFrame.new(0, BladeCero.Size.Y/2 - 2.75, 0)
		BladeCero.Parent = workspace.Effects[Character.Name]
		
		ClientProjectile:ProjectileStraight(Character, BladeCero, Speed)
		
		local SizeIncrease = 1.5
		local BladeInfo = TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)
		TweenService:Create(BladeCero, BladeInfo, {Size = BladeCero.Size + Vector3.new(SizeIncrease, SizeIncrease, SizeIncrease)}):Play()
		
		local ShakeMagnitudes = {
			Close = {
				Magnitude = 5;
				Roughness = 45;
				FadeInTime = 0;
				FadeOutTime = 0.1;
				PosInfluence = 0.25;
				RotInfluence = 0.25;
			};
			Midway = {
				Magnitude = 3;
				Roughness = 25;
				FadeInTime = 0;
				FadeOutTime = 0.1;
				PosInfluence = 0.25;
				RotInfluence = 0.25;
			};
			Far = {
				Magnitude = 0.5;
				Roughness = 10;
				FadeInTime = 0;
				FadeOutTime = 0.1;
				PosInfluence = 0.25;
				RotInfluence = 0.25;
			};
		}
		
		local Camera = workspace.CurrentCamera
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
			Camera.CFrame = Camera.CFrame * shakeCFrame
		end)
		camShake:Start()
		
		local LocalCharacter = Players.LocalPlayer.Character
		local Accumulated = 0
		local Rate = 0.1
		local Connection
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated > Rate then
				Accumulated -= Rate
				
				local Magnitude = (LocalCharacter.HumanoidRootPart.Position - BladeCero.Position).Magnitude
				if Magnitude < 100 then
					local ShakeInfo = ShakeMagnitudes.Far
					if Magnitude <= 25 then
						ShakeInfo = ShakeMagnitudes.Close
					elseif Magnitude > 25 and Magnitude < 100 then
						ShakeInfo = ShakeMagnitudes.Midway
					end
					
					camShake:ShakeOnce(ShakeInfo.Magnitude, ShakeInfo.Roughness, ShakeInfo.FadeInTime, ShakeInfo.FadeOutTime, ShakeInfo.PosInfluence, ShakeInfo.RotInfluence)
				end
			end
		end)
		
		local BladeCeroRelease = HollowSounds.BladeCeroRelease:Clone()
		BladeCeroRelease.PlayOnRemove = true
		BladeCeroRelease.Parent = Character.PrimaryPart
		BladeCeroRelease:Destroy()
		BladeCeroRelease = nil
		
		task.delay(4, function()
			BladeCero.Anchored = true
			BladeCero.Shards.Enabled = false
			BladeCero.Shards2.Enabled = false
			BladeCero.PointLight.Enabled = false
			TweenService:Create(BladeCero, TweenInfo.new(1), {Transparency = 1}):Play()
			Debris:AddItem(BladeCero, 4)			
			
			camShake:Stop()
			Camera.CameraType = Enum.CameraType.Custom
			Connection:Disconnect()
			Connection = nil
		end)
		
		local Model = Instance.new("Model")
		Model.Name = "BladeCeroTrail"
		Model.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Model, 7)

		local Info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		local function CreateTrailPart()
			local Trail = HollowEffects.BladeCeroTrail:Clone()
			Trail.Size = Vector3.new(0.1, 0.1, 4)
			Trail.Color = Color3.fromRGB(255, 92, 60)
			Trail.Parent = Model

			task.delay(0.3, function()
				TweenService:Create(Trail, Info, {Color = Color3.fromRGB(0, 0, 0)}):Play()
				Debris:AddItem(Trail, 4)
			end)

			return Trail
		end
		
		local Distance = 200
		local TrailParts = {}

		for i = 1, Distance / 4 do
			TrailParts[i] = CreateTrailPart()
			if i == 1 then
				TrailParts[i].CFrame = RootCFrame * CFrame.new(0, -2.75, 0)
			else
				TrailParts[i].CFrame = TrailParts[i - 1].CFrame * CFrame.new(0, 0, -4)
			end
			task.wait()
		end
	end
end

function ClientSkills.CeroGrab(Character, Phase, HighestStat)
	if Phase == "0" then
		local CeroGrabStart = HollowEffects.CeroGrabIndicator.CeroGrab:Clone()
		CeroGrabStart.Parent = Character["Left Arm"]
		Debris:AddItem(CeroGrabStart, 1)
		
		local CeroGrabEnable = HollowEffects.CeroGrabIndicator.Enable:Clone()
		CeroGrabEnable.Parent = Character["Left Arm"]
		Debris:AddItem(CeroGrabEnable, 1)
		if HighestStat then
			CeroGrabEnable.Particle.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			
			for i, v in ipairs(CeroGrabStart:GetChildren()) do
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
					ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
				})
			end
		end

		CeroGrabStart.Ball:Emit(1)
		
		task.delay(0.35, function()
			CeroGrabEnable.Particle.Enabled = false
		end)
		task.delay(0.5, function()
			for i = 1, 2 do
				local Shatter = CeroGrabStart["Shatter" .. i]
				Shatter:Emit(15)
			end
		end)
	elseif Phase == "1" then
		local CeroGrabStartup = HollowEffects.CeroGrabStartup:Clone()
		CeroGrabStartup.PrimaryPart.Anchored = false
		CeroGrabStartup.Ball.Transparency = 1
		CeroGrabStartup.Ball.Size = Vector3.zero
		CeroGrabStartup.Center.Transparency = 1
		CeroGrabStartup.Center.Size = Vector3.zero
		CeroGrabStartup.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroGrabStartup, 3)
		
		local InitialInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(CeroGrabStartup.Ball, InitialInfo, {Transparency = 0.75, Size = Vector3.new(2.168, 2.168, 2.168)}):Play()
		TweenService:Create(CeroGrabStartup.Center, InitialInfo, {Transparency = 0, Size = Vector3.new(1.767, 1.767, 1.767)}):Play()

		local Weld = Instance.new("Weld")
		--Weld.C0 = CFrame.new(0, -4.76837158e-07, 1.85787964, 1, -7.22266691e-12, -2.64662264e-10, 2.48291887e-10, 3.08318648e-10, -0.999996483, 1.40438772e-11, 1, -3.08317732e-10)
		Weld.C0 = CFrame.new(-0.00040435791, -1.56018329, 1.58404541, 1, 3.44297497e-08, 9.68529076e-11, -3.02388798e-08, 0.999993443, 1.23417569e-08, -7.4718641e-11, -1.3324037e-08, 1)
		Weld.Part0 = CeroGrabStartup.PrimaryPart
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = CeroGrabStartup.PrimaryPart

		if HighestStat then
			CeroGrabStartup.Ball.Color = CeroColors[HighestStat]
			CeroGrabStartup.Ring1.Color = CeroColors[HighestStat]
			CeroGrabStartup.Ring2.Color = CeroColors[HighestStat]

			for i, v in ipairs(CeroGrabStartup.Ball.Attachment:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
						ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
					})
				elseif v:IsA("PointLight") then
					v.Color = CeroColors[HighestStat]
				end
			end
		end

		local ChargeSound = HollowSounds.CeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)

		local DelayTime = 0.5
		local BallLifeTime = DelayTime / 4.25

		task.delay(DelayTime, function()
			Weld:Destroy()
			CeroGrabStartup.PrimaryPart.Anchored = true
			Debris:AddItem(CeroGrabStartup, 0.5)

			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			local Info2 = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
			for i = 1, 2 do
				local Ring = CeroGrabStartup["Ring" .. i]
				Ring.Anchored = true
				Ring.WeldConstraint:Destroy()

				local Size = Ring.Size
				Ring.Size = Vector3.zero

				TweenService:Create(Ring, Info, {CFrame = Ring.CFrame * CFrame.new(0, -3, 0), Size = Size}):Play()
				TweenService:Create(Ring, Info2, {Transparency = 0}):Play()
			end

			TweenService:Create(CeroGrabStartup.Ball, InitialInfo, {Transparency = 1}):Play()
			TweenService:Create(CeroGrabStartup.Center, InitialInfo, {Transparency = 1}):Play()

			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			for i, v in ipairs(CeroGrabStartup.Ball.Attachment:GetChildren()) do
				v.Enabled = false
			end
		end)
	elseif Phase == "2" then
		--local Offset = CFrame.new(-5.08486176, -16.0044174, 3.33786011e-05, -0.946700096, -2.72848107e-12, -0.322114974, 0.322114289, 0, -0.94669807, -2.58305616e-12, -0.999998927, -8.78885614e-13)
		local Offset = CFrame.new(-0.00025177002, 5.42875004, -16.4597473, -0.999997318, 2.12916772e-12, -7.9036673e-12, 0, 0.965577364, 0.260115385, 8.18543063e-12, 0.260116071, -0.96557492)
		local BeamSize = Vector3.new(7.71, 7.042, 33)
		local CeroSize = Vector3.new(5.569, 5.538, 32)
		
		local CeroGrab = HollowEffects.CeroGrab:Clone()
		if HighestStat then
			CeroGrab.Beam.Color = CeroColors[HighestStat]
		end
		
		--CeroGrab.PrimaryPart.CFrame = Character["Left Arm"].CFrame * Offset * CFrame.new(0, 0, -BeamSize.Z / 2)
		CeroGrab.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * Offset * CFrame.new(0, 0, -BeamSize.Z / 2)
		CeroGrab.Parent = workspace.Effects[Character.Name]
		
		for i, v in ipairs(CeroGrab:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end
		
		local BeamPosition = (CeroGrab.PrimaryPart.CFrame * CFrame.new(0, 0, BeamSize.Z / 2)).Position
		local CeroPosition = (CeroGrab.PrimaryPart.CFrame * CFrame.new(0, 0, CeroSize.Z / 2)).Position
		
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(CeroGrab.Beam, Info, {Size = BeamSize, Position = BeamPosition}):Play()
		TweenService:Create(CeroGrab.cero, Info, {Size = CeroSize, Position = CeroPosition}):Play()
		task.delay(0.25, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(CeroGrab.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(CeroGrab.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			CeroGrab.PrimaryPart.CFrame = CeroGrab.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = CeroGrab.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(0.4, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(CeroGrab.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(CeroGrab.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			task.wait(0.4)
			CeroGrab:Destroy()
		end)
		
		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil
	end
end

function ClientSkills.BalaDrive(Character, Phase, MousePosition, Speed, HighestStat, Target)
	if Phase == "0" then
		local Bala = HollowEffects.BalaDrive:Clone()
		Bala.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		Bala.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Bala, 0.7)
		
		if HighestStat then
			Bala.Color = CeroColors[HighestStat]
			Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
			Bala.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			Bala.A1.DriveTrail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000335693359, 1.68572283, 0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = Bala
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = Bala
		
		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
	elseif Phase == "1" then
		local Bala = HollowEffects.BalaDrive:Clone()
		Bala.Name = "BalaDrive"
		Bala.CFrame = CFrame.new((Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)).Position, MousePosition)
		Bala.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Bala, 1)

		ClientProjectile:Projectile(Character, Bala, MousePosition, Speed)
		
		if HighestStat then
			Bala.Color = CeroColors[HighestStat]
			Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
			Bala.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			Bala.A1.DriveTrail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end

		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
		
		local BalaDriveKick = HollowSounds.BalaDriveKick:Clone()
		BalaDriveKick.PlayOnRemove = true
		BalaDriveKick.Parent = Character.PrimaryPart
		BalaDriveKick:Destroy()
		BalaDriveKick = nil
	elseif Phase == "2" then
		local BalaDrive = workspace.Effects[Character.Name]:FindFirstChild("BalaDrive")
		if BalaDrive then
			local BalaCFrame = BalaDrive.CFrame
			local BalaDriveClone = BalaDrive:Clone()
			BalaDriveClone.CFrame = BalaCFrame
			BalaDriveClone.Anchored = true
			BalaDriveClone.Material = Enum.Material.ForceField
			BalaDriveClone.Parent = workspace.Effects[Character.Name]
			TweenService:Create(BalaDriveClone, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(10, 10, 10)}):Play()
			Debris:AddItem(BalaDriveClone, 0.5)
			
			BalaDrive:Destroy()
		end
	elseif Phase == "3" then		
		local Bala = HollowEffects.BalaDrive:Clone()
		Bala.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Bala, 1)
		
		if HighestStat then
			Bala.Color = CeroColors[HighestStat]
			Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
			Bala.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			Bala.A1.DriveTrail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000274658203, 1.71706462, 0.000183105469, 1, -1.42107734e-12, 1.19208579e-07, 1.42107734e-12, 1, 0, -1.19208579e-07, 0, 1)
		Weld.Part0 = Bala
		Weld.Part1 = Character["Right Leg"]
		Weld.Parent = Bala
		
		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
	elseif Phase == "4" then
		local BalaDriveSlam = HollowEffects.BalaDriveSlam:Clone()
		BalaDriveSlam.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
		BalaDriveSlam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BalaDriveSlam, 2)
		
		if HighestStat then
			BalaDriveSlam.Emit30.Dots.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			BalaDriveSlam.Emit30.Lines.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			BalaDriveSlam.Emit30["Specs 2"].Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			BalaDriveSlam.Emit30.Summon.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
		end
		
		BalaDriveSlam.Emit1.Ring:Emit(1)
		for i, v in ipairs(BalaDriveSlam.Emit30:GetChildren()) do
			v:Emit(30)
		end
		
		local Shockwave = ReplicatedStorage.Assets.Effects.Shockwave:Clone()
		Shockwave.Size = Vector3.zero
		Shockwave.CFrame = Target.HumanoidRootPart.CFrame
		Shockwave.Transparency = 0.6
		if HighestStat then
			Shockwave.Color = CeroColors[HighestStat]
		end
		Shockwave.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Shockwave, 2.5)
		
		local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(Shockwave, Info, {Size = Vector3.new(40, 1, 40)}):Play()
		task.delay(0.5, function()
			TweenService:Create(Shockwave, Info, {Transparency = 1}):Play()
		end)
		
		local BalaDriveSlamSound = HollowSounds.BalaDriveSlam:Clone()
		BalaDriveSlamSound.PlayOnRemove = true
		BalaDriveSlamSound.Parent = Character.PrimaryPart
		BalaDriveSlamSound:Destroy()
		BalaDriveSlamSound = nil
	end
end

function ClientSkills.BalaBarrage(Character, Phase, Target)
	if Phase == "1" then
		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
	elseif Phase == "2" then
		local BalaImpactSound = HollowSounds.BalaBarrageImpact:Clone()
		BalaImpactSound.PlayOnRemove = true
		BalaImpactSound.Parent = Target.PrimaryPart
		BalaImpactSound:Destroy()
		BalaImpactSound = nil
	end
end

function ClientSkills.CeroSweep(Character, Phase, Blade, HighestStat, HitCounter)
	if Phase == "1" then
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		for i, v in ipairs(Blade:GetChildren()) do
			if v.Name ~= "CeroHandle" then
				v.Transparency = 1
				TweenService:Create(v, Info, {Transparency = 0}):Play()
				task.delay(1.9, function()
					TweenService:Create(v, Info, {Transparency = 1}):Play()
				end)
			end
		end

		for _, v in ipairs(HollowEffects.CeroSweepSummon:GetChildren()) do
			local SummonEffect = v:Clone()
			if HighestStat and v.Name == "Smoke" then
				SummonEffect.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
					ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
				})
			end
			SummonEffect.Parent = Blade.Red
			Debris:AddItem(SummonEffect, 2.9)
			SummonEffect:Emit(50)
			task.delay(1.9, function()
				if not Blade:GetAttribute("Disconnected") then
					SummonEffect:Emit(50)
				end
			end)
		end
	elseif Phase == "2" then
		if HitCounter >= 3 then
			local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
			GSCritEffect.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -1, -4))
			GSCritEffect.Parent = workspace.Effects[Character.Name]
			for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
				v:Emit(50)
			end
			Debris:AddItem(GSCritEffect, 1.5)
			
			local CeroSweepSlam = HollowSounds.CeroSweepSlam:Clone()
			CeroSweepSlam.PlayOnRemove = true
			CeroSweepSlam.Parent = Character.HumanoidRootPart
			CeroSweepSlam:Destroy()
			CeroSweepSlam = nil
		else
			local CeroSweepSwing = HollowSounds.CeroSweepSwing:Clone()
			CeroSweepSwing.PlayOnRemove = true
			CeroSweepSwing.Parent = Character.HumanoidRootPart
			CeroSweepSwing:Destroy()
			CeroSweepSwing = nil
		end
	end
end

function ClientSkills.CeroSweepDisperse(Character, Blade, HighestStat)
	Blade:SetAttribute("Disconnected", true)
	
	local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

	for i, v in ipairs(Blade:GetChildren()) do
		if v.Name ~= "CeroHandle" then
			TweenService:Create(v, Info, {Transparency = 1}):Play()
		end
	end

	for _, v in ipairs(HollowEffects.CeroSweepSummon:GetChildren()) do
		local SummonEffect = v:Clone()
		if HighestStat and v.Name == "Smoke" then
			SummonEffect.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		SummonEffect.Parent = Blade.Red
		Debris:AddItem(SummonEffect, 1)
		SummonEffect:Emit(50)
	end
end

function ClientSkills.CeroInfuse(Character, Duration, HighestStat)	
	local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
	if Weapon then
		for i, v in ipairs(Weapon:GetDescendants()) do
			if v:IsA("BasePart") and v.Name == "WeaponAura" then
				for _, Particle in ipairs(HollowEffects.CeroInfuse:GetChildren()) do
					local CeroCoat = Particle:Clone()
					if HighestStat then
						if CeroCoat.Name == "Smoke" then
							CeroCoat.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
								ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
							})
						else
							CeroCoat.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
								ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
							})
						end
					end
					CeroCoat.Parent = v
					Debris:AddItem(CeroCoat, Duration)
					task.delay(Duration - 1, function()
						CeroCoat.Enabled = false
					end)
				end
			end
		end
	end
	
	local CeroInfuseSound = HollowSounds.CeroInfuse:Clone()
	CeroInfuseSound.PlayOnRemove = true
	CeroInfuseSound.Parent = Character.HumanoidRootPart
	CeroInfuseSound:Destroy()
	CeroInfuseSound = nil
end

function ClientSkills.BalaBlackout(Character, Phase, Debuffed, Duration, HighestStat)
	if Phase == "1" then
		local Bala = HollowEffects.Bala:Clone()
		Bala.CFrame = Character["Left Arm"].CFrame
		if HighestStat then
			Bala.Color = CeroColors[HighestStat]
			Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
			Bala.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		Bala.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Bala, 1.6)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000335693359, 1.68572283, 0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = Bala
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = Bala
		
		task.delay(0.6, function()
			Weld:Destroy()
			TweenService:Create(Bala, TweenInfo.new(0.5), {Position = Bala.Position + Vector3.new(0, 8, 0)}):Play()
			
			task.delay(0.2, function()
				Bala.Anchored = true
				Bala.Material = Enum.Material.ForceField
				TweenService:Create(Bala, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(10, 10, 10)}):Play()
				
				local BalaBlackourBurst = HollowSounds.BalaBlackoutBurst:Clone()
				BalaBlackourBurst.PlayOnRemove = true
				BalaBlackourBurst.Parent = Bala
				BalaBlackourBurst:Destroy()
				BalaBlackourBurst = nil
			end)
		end)
		
		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
	elseif Phase == "2" then
		for i, v in ipairs(workspace.Entities:GetChildren()) do
			local PlayerEntity = Players:GetPlayerFromCharacter(v)
			if PlayerEntity then
				local DisplayType = v.Humanoid.DisplayDistanceType
				v.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				task.delay(Duration, function()
					v.Humanoid.DisplayDistanceType = DisplayType
				end)
			end
		end
		
		TweenService:Create(Lighting, TweenInfo.new(0.25), {ExposureCompensation = -10}):Play()
		task.delay(Duration, function()
			TweenService:Create(Lighting, TweenInfo.new(0.25), {ExposureCompensation = 0}):Play()
		end)
	end
end

function ClientSkills.CeroConfinementPunch(Character)
	local CeroConfinementWelded = HollowEffects.CeroConfinementWeld:Clone()
	CeroConfinementWelded.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(CeroConfinementWelded, 0.68)
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(0.000274658203, 1.13545156, -0.000183105469, -1, 0, 8.74227766e-08, 0, 1, 0, -8.74227766e-08, 0, -1)
	Weld.Part0 = CeroConfinementWelded.PrimaryPart
	Weld.Part1 = Character["Right Arm"]
	Weld.Parent = CeroConfinementWelded.PrimaryPart
end

function ClientSkills.CeroConfinement(Character, Phase, RootCFrame, Duration, PositiveHits, Radius)
	if Phase == "1" then
		local CeroConfinement = HollowEffects.CeroConfinement:Clone()
		CeroConfinement:PivotTo(RootCFrame)
		CeroConfinement.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroConfinement, 0.7)

		local CeroConfineSlam = HollowEffects.CeroConfineSlam:Clone()
		CeroConfineSlam.CFrame = RootCFrame * CFrame.new(-0.5, 2.5, 2)
		CeroConfineSlam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroConfineSlam, 2)

		CeroConfineSlam.Emit4.NeonCircle:Emit(4)
		CeroConfineSlam.Emit50.Particle3:Emit(50)

		local Info = TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)

		for i, v in ipairs(CeroConfinement:GetChildren()) do
			TweenService:Create(v, Info, {Size = Vector3.new(v.Size.X + 0.5, v.Size.Y + 0.5, v.Size.Z + 0.5)}):Play()
		end
		
		local CeroConfinementSound = HollowSounds.CeroConfinement:Clone()
		CeroConfinementSound.PlayOnRemove = true
		CeroConfinementSound.Parent = CeroConfinement.PrimaryPart
		CeroConfinementSound:Destroy()
		CeroConfinementSound = nil
		
		local CeroConfinementIndicator = HollowEffects.CeroConfinementIndicator:Clone()
		CeroConfinementIndicator.Size = Vector3.zero
		CeroConfinementIndicator.CFrame = RootCFrame
		CeroConfinementIndicator.Transparency = 1
		CeroConfinementIndicator.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroConfinementIndicator, 1)
		
		TweenService:Create(CeroConfinementIndicator, TweenInfo.new(0.5), {Transparency = 0, Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2)}):Play()
		task.delay(0.85, function()
			TweenService:Create(CeroConfinementIndicator, TweenInfo.new(0.15), {Size = Vector3.zero}):Play()
		end)
	elseif Phase == "2" then
		local CeroConfinement = HollowEffects.CeroConfinement:Clone()
		CeroConfinement:PivotTo(RootCFrame)
		CeroConfinement.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroConfinement, Duration + 0.4)

		local CeroConfineSlam = HollowEffects.CeroConfineSlam:Clone()
		CeroConfineSlam.CFrame = RootCFrame * CFrame.new(-0.5, 2.5, 2)
		CeroConfineSlam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroConfineSlam, 2)

		CeroConfineSlam.Emit4.NeonCircle:Emit(4)
		CeroConfineSlam.Emit50.Particle3:Emit(50)

		local Info = TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)

		for i, v in ipairs(CeroConfinement:GetChildren()) do
			TweenService:Create(v, Info, {Size = Vector3.new(v.Size.X + 0.5, v.Size.Y + 0.5, v.Size.Z + 0.5)}):Play()
		end

		local Attachment = Instance.new("Attachment")
		Attachment.Parent = CeroConfinement.PrimaryPart

		task.delay(Duration, function()
			for i, v in ipairs(CeroConfinement:GetDescendants()) do
				if v:IsA("BasePart") then
					TweenService:Create(v, TweenInfo.new(0.4), {Size = Vector3.zero, Transparency = 1}):Play()
				elseif v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			
			local CeroExplosionEffect = HollowEffects.CeroExplosionEffect:Clone()
			CeroExplosionEffect.CFrame = RootCFrame		
			CeroExplosionEffect.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(CeroExplosionEffect, 2)
			
			for i, v in ipairs(CeroExplosionEffect.Attachment:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(50)
				end
			end
			
			local CeroFireSound = HollowSounds.CeroCorneaImpact:Clone()
			CeroFireSound.PlayOnRemove = true
			CeroFireSound.Parent = CeroConfinement.PrimaryPart
			CeroFireSound:Destroy()
			CeroFireSound = nil
		end)

		if PositiveHits and #PositiveHits > 0 then
			for _, v in ipairs(PositiveHits) do
				local CeroConfinementString = HollowEffects.CeroConfinementString.Attachment1.Beam:Clone()
				CeroConfinementString.Attachment0 = v.HumanoidRootPart.RootAttachment
				CeroConfinementString.Attachment1 = Attachment
				CeroConfinementString.Parent = Attachment
			end
		end
		
		local CeroConfinementSound = HollowSounds.CeroConfinement:Clone()
		CeroConfinementSound.PlayOnRemove = true
		CeroConfinementSound.Parent = CeroConfinement.PrimaryPart
		CeroConfinementSound:Destroy()
		CeroConfinementSound = nil
	end
end

function ClientSkills.CeroBurst(Character, RootCFrame, HighestStat)
	local Offset = CFrame.new(-2.90444946, 0.581439495, -0.455444336, 0, 0, -1, 0, -1, 0, -1, -0, -0)
	
	local CeroBurst = HollowEffects.CeroBurst:Clone()
	CeroBurst.CFrame = RootCFrame * Offset
	CeroBurst.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(CeroBurst, 1)
	
	for i, v in ipairs(CeroBurst.Emit80:GetChildren()) do
		if HighestStat and v.Name ~= "BurstWhite" then
			v.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		v:Emit(80)
	end
	
	local CeroBurstSound = HollowSounds.CeroBurst:Clone()
	CeroBurstSound.PlayOnRemove = true
	CeroBurstSound.Parent = Character.HumanoidRootPart
	CeroBurstSound:Destroy()
	CeroBurstSound = nil
end

function ClientSkills.BalaGum(Character, Phase, Target, HighestStat)
	if Phase == "0" then
		local Bala = HollowEffects.Bala:Clone()
		Bala.CFrame = Character["Left Arm"].CFrame
		if HighestStat then
			Bala.Color = CeroColors[HighestStat]
			Bala.Attachment.PointLight.Color = CeroColors[HighestStat]
			Bala.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			Bala.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		Bala.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Bala, 0.53)

		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000335693359, 1.68572283, 0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = Bala
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = Bala
		
		local BalaSound = HollowSounds.Bala:Clone()
		BalaSound.PlayOnRemove = true
		BalaSound.Parent = Character.PrimaryPart
		BalaSound:Destroy()
		BalaSound = nil
	elseif Phase == "1" then
		local BalaGum = HollowEffects.Bala:Clone()
		BalaGum.Name = "BalaGum"
		BalaGum.Parent = workspace.Effects[Character.Name]
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.428375244, -0.29851675, 0.102966309, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = BalaGum
		Weld.Part1 = Target.Head
		Weld.Parent = BalaGum

		local BalaGumString = HollowEffects.BalaGumString.GumBeam:Clone()
		BalaGumString.Attachment0 = Character.HumanoidRootPart.RootAttachment
		BalaGumString.Attachment1 = BalaGum.Attachment
		BalaGumString.Parent = BalaGum
		
		if HighestStat then
			BalaGum.Color = CeroColors[HighestStat]
			BalaGum.Attachment.PointLight.Color = CeroColors[HighestStat]
			BalaGum.Attachment.ParticleColor.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, PaleColor(CeroColors[HighestStat], 0.6)),
				ColorSequenceKeypoint.new(1, PaleColor(CeroColors[HighestStat], 0.6)),
			})
			BalaGum.Attachment.ParticleColor2.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
			BalaGumString.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		
		local BalaGumAttach = HollowSounds.BalaGumAttach:Clone()
		BalaGumAttach.PlayOnRemove = true
		BalaGumAttach.Parent = Target.PrimaryPart
		BalaGumAttach:Destroy()
		BalaGumAttach = nil
	elseif Phase == "2" then
		local BalaGum = workspace.Effects[Character.Name]:FindFirstChild("BalaGum")
		if BalaGum then
			BalaGum:Destroy()
		end
	elseif Phase == "4" then
		local BalaGumSling = HollowSounds.BalaGumSling:Clone()
		BalaGumSling.PlayOnRemove = true
		BalaGumSling.Parent = Character.PrimaryPart
		BalaGumSling:Destroy()
		BalaGumSling = nil
	elseif Phase == "5" then
		local BalaGumStar = HollowEffects.GumIndicator.Emit2B:Clone()
		if HighestStat then
			BalaGumStar.Star.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
				ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
			})
		end
		BalaGumStar.Parent = Target.HumanoidRootPart
		Debris:AddItem(BalaGumStar, 1.5)
		BalaGumStar.Star:Emit(2)
	end
end

function ClientSkills.CeroFireflies(Character, Phase, Firefly)
	if Phase == "1" then
		local CeroFirefliesStartup = HollowEffects.CeroFirefliesStartup.FireflyStartup:Clone()
		CeroFirefliesStartup.Parent = Character["Left Arm"]
		Debris:AddItem(CeroFirefliesStartup, 0.53)
		
		for i, v in ipairs(CeroFirefliesStartup:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local CeroFirefliesSound = HollowSounds.CeroFirefliesStartup:Clone()
		CeroFirefliesSound.PlayOnRemove = true
		CeroFirefliesSound.Parent = Character.PrimaryPart
		CeroFirefliesSound:Destroy()
		CeroFirefliesSound = nil
	elseif Phase == "2" then
		for i, v in ipairs(Firefly:GetDescendants()) do
			if v:IsA("ParticleEmitter") and tonumber(v.Name) then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local CeroFirefliesSound = HollowSounds.CeroFireflies:Clone()
		CeroFirefliesSound.PlayOnRemove = true
		CeroFirefliesSound.Parent = Firefly
		CeroFirefliesSound:Destroy()
		CeroFirefliesSound = nil
	elseif Phase == "3" then
		local CeroFirefliesSound = HollowSounds.CeroFirefliesStartup:Clone()
		CeroFirefliesSound.PlayOnRemove = true
		CeroFirefliesSound.Parent = Firefly
		CeroFirefliesSound:Destroy()
		CeroFirefliesSound = nil
	end
end

function ClientSkills.HollowBite(Character, Phase, Target, Windup)
	if Phase == "1" then
		local HollowBite = HollowEffects.HollowBite:Clone()
		HollowBite.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HollowBite, Windup + 1)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.0390701294, 2.95334864, -0.044418335, -1, 0, 0, 0, 1, 0, 0, 0, -1)
		Weld.Part0 = HollowBite.PrimaryPart
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = HollowBite
		
		for i, v in ipairs(HollowBite:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
				TweenService:Create(v, TweenInfo.new(0.35), {Transparency = 0}):Play()
			end
		end
		
		local HollowBiteFloor = HollowEffects.HollowBiteFloor.HollowBiteFloor:Clone()
		HollowBiteFloor.Parent = Target.HumanoidRootPart
		Debris:AddItem(HollowBiteFloor, 1.45)
		
		for i, v in ipairs(HollowBiteFloor:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local Offset = CFrame.new(0.0572509766, -2.95334864, -0.994817257, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local HollowBiteSpawn = HollowEffects.HollowBiteSpawn:Clone()
		HollowBiteSpawn:PivotTo(Target.HumanoidRootPart.CFrame * Offset)
		HollowBiteSpawn.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HollowBiteSpawn, 1.35)
		
		for i, v in ipairs(HollowBiteSpawn:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local HollowBiteSpawnSound = HollowSounds.HollowBiteSpawn:Clone()
		HollowBiteSpawnSound.PlayOnRemove = true
		HollowBiteSpawnSound.Parent = HollowBite.PrimaryPart
		HollowBiteSpawnSound:Destroy()
		HollowBiteSpawnSound = nil
		
		task.delay(Windup - 0.3, function()
			Weld:Destroy()
			HollowBite.PrimaryPart.Anchored = true
			
			local MaskAnimation = HollowBite.AnimationController.Animator:LoadAnimation(ReplicatedStorage.Assets.SkillAnimations.Hollow.HollowBiteMask)
			MaskAnimation:Play()

			task.delay(0.3, function()
				local LoopedMaskAnimation = HollowBite.AnimationController.Animator:LoadAnimation(ReplicatedStorage.Assets.SkillAnimations.Hollow.HollowBiteMaskLooped)
				LoopedMaskAnimation:Play()
				
				local HollowBiteSound = HollowSounds.HollowBite:Clone()
				HollowBiteSound.PlayOnRemove = true
				HollowBiteSound.Parent = HollowBite.PrimaryPart
				HollowBiteSound:Destroy()
				HollowBiteSound = nil
			end)
			
			task.wait(0.5)
			
			for i, v in ipairs(HollowBite:GetChildren()) do
				if v:IsA("BasePart") then
					TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
				end
			end
		end)
	end
end

function ClientSkills.BalaBurner(Character, Phase, Target, Windup, HighestStat, RootCFrame)
	if Phase == "1" then
		-- startup effect
	elseif Phase == "2" then
		local BalaBurner = HollowEffects.BalaBurner:Clone()
		if HighestStat then
			BalaBurner.cero.Color = CeroColors[HighestStat]
		end
		BalaBurner.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BalaBurner, Windup)

		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.517211914, -0.763549089, -0.20010376, -0.999997377, 0, 0, 0, 1, 0, 0, 0, -1)
		Weld.Part0 = BalaBurner.PrimaryPart
		Weld.Part1 = Target.Torso
		Weld.Parent = BalaBurner
		
		local Rate = Windup / 2
		for i = 1, 10 do
			if BalaBurner.Parent then
				Rate *= 0.75

				for i, v in ipairs(BalaBurner:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						if HighestStat then
							v.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
								ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
							})
						end
						v:Emit(tonumber(v.Name))
					elseif v:IsA("PointLight") then
						v.Color = CeroColors[HighestStat]
					end
				end
				
				local BalaBurnerTick = HollowSounds.BalaBurnerTick:Clone()
				BalaBurnerTick.PlayOnRemove = true
				BalaBurnerTick.Parent = BalaBurner.PrimaryPart
				BalaBurnerTick:Destroy()
				BalaBurnerTick = nil
			end
			
			task.wait(Rate)
		end
	elseif Phase == "3" then
		local BalaBurnerExplode = HollowEffects.BalaBurnerExplode:Clone()
		BalaBurnerExplode.CFrame = RootCFrame
		BalaBurnerExplode.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BalaBurnerExplode, 2.7)
		
		for i, v in ipairs(BalaBurnerExplode:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				if HighestStat then
					v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CeroColors[HighestStat]),
					ColorSequenceKeypoint.new(1, CeroColors[HighestStat]),
					})
				end
				v:Emit(tonumber(v.Name))
			elseif v:IsA("PointLight") then
				v.Color = CeroColors[HighestStat]
			end
		end
		
		local BalaBurnerSound = HollowSounds.BalaBurner:Clone()
		BalaBurnerSound.PlayOnRemove = true
		BalaBurnerSound.Parent = Target.HumanoidRootPart
		BalaBurnerSound:Destroy()
		BalaBurnerSound = nil
	end
end

function ClientSkills.Volley(Character, Phase, MousePosition, Duration)
	if Phase == "1" then
		local VolleySound = QuincyKidoSounds.VolleyStart:Clone()
		VolleySound.PlayOnRemove = true
		VolleySound.Parent = Character.HumanoidRootPart
		VolleySound:Destroy()
		VolleySound = nil
	elseif Phase == "2" then
		local Volley = QuincyKidoEffects.VolleyRework:Clone()
		Volley:PivotTo(CFrame.new(MousePosition))
		Volley.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Volley, Duration + 0.8)
		
		task.delay(Duration, function()
			for i, v in ipairs(Volley:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
		
		local VolleySound = QuincyKidoSounds.VolleySplit:Clone()
		VolleySound.PlayOnRemove = true
		VolleySound.Parent = Volley.PrimaryPart
		VolleySound:Destroy()
		VolleySound = nil
		
		local VolleySound = QuincyKidoSounds.VolleyRelease:Clone()
		VolleySound.PlayOnRemove = true
		VolleySound.Parent = Character.HumanoidRootPart
		VolleySound:Destroy()
		VolleySound = nil
	end
end

function ClientSkills.Waveshot(Character, Phase, SpawnCFrame, PositiveHits, Duration)
	if Phase == "1" then
		local Waveshot = QuincyKidoEffects.Waveshot:Clone()
		Waveshot.CFrame = SpawnCFrame * CFrame.new(0, 0, -3)
		Waveshot.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Waveshot, 0.75)

		for i, v in ipairs(Waveshot:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local WaveshotSound = QuincyKidoSounds.Waveshot:Clone()
		WaveshotSound.PlayOnRemove = true
		WaveshotSound.Parent = Character.HumanoidRootPart
		WaveshotSound:Destroy()
		WaveshotSound = nil
	elseif Phase == "2" then
		local function ApplySlow(BodyPart)
			if BodyPart and not BodyPart:FindFirstChild("WaveshotSlow") then
				local WaveshotSlow = QuincyKidoEffects.WaveshotSlow.WaveshotSlow:Clone()
				WaveshotSlow.Parent = BodyPart
				Debris:AddItem(WaveshotSlow, Duration + 1)

				task.delay(Duration, function()
					for i, v in ipairs(WaveshotSlow:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
				end)
			end
		end
		
		for i, v in ipairs(PositiveHits) do
			ApplySlow(v["Left Leg"])
			ApplySlow(v["Right Leg"])
		end
	end
end

function ClientSkills.ReishiString(Character, Phase, PositiveHits, Duration, Target, Windup)
	if Phase == "1" then
		local ReishiStringSound = QuincyKidoSounds.ReishiStringRelease:Clone()
		ReishiStringSound.PlayOnRemove = true
		ReishiStringSound.Parent = Character.HumanoidRootPart
		ReishiStringSound:Destroy()
		ReishiStringSound = nil
	elseif Phase == "2" then
		for _, Entities in ipairs(PositiveHits) do
			local ReishiString = QuincyKidoEffects.ReishiStringRoot:Clone()
			ReishiString.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(ReishiString, Duration + 0.7)
			
			local BodyParts = {
				"Left Arm";
				"Left Leg";
				"Right Arm";
				"Right Leg";
				"HumanoidRootPart";
			}
			
			for i, v in ipairs(BodyParts) do
				if Entities:FindFirstChild(v) then
					local Weld = Instance.new("Weld")
					Weld.Part0 = ReishiString[v]
					Weld.Part1 = Entities[v]
					Weld.Parent = ReishiString
					
					local ReishiStringStunnedSound = QuincyKidoSounds.ReishiStringStunned:Clone()
					ReishiStringStunnedSound.PlayOnRemove = true
					ReishiStringStunnedSound.Parent = v.HumanoidRootPart
					ReishiStringStunnedSound:Destroy()
					ReishiStringStunnedSound = nil
					
					task.delay(Duration - 0.2, function()
						for _, Particle in ipairs(ReishiString:GetDescendants()) do
							if Particle:IsA("ParticleEmitter") then
								if tonumber(Particle.Name) then
									Particle:Emit(tonumber(Particle.Name))
								else
									Particle.Enabled = false
								end
							end
						end
					end)
				end
			end
			
			if Entities:FindFirstChild("ReishiStringHighlight") then
				Entities.ReishiStringHighlight:Destroy()
			end
		end
	elseif Phase == "3" then
		local ReishiStringHighlight = Instance.new("Highlight")
		ReishiStringHighlight.Name = "ReishiStringHighlight"
		ReishiStringHighlight.OutlineColor = Color3.fromRGB(108, 248, 255)
		ReishiStringHighlight.FillTransparency = 1
		ReishiStringHighlight.FillColor = Color3.fromRGB(108, 248, 255)
		ReishiStringHighlight.OutlineTransparency = 1
		ReishiStringHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		ReishiStringHighlight.Parent = Target
		Debris:AddItem(ReishiStringHighlight, Windup + Duration)

		local Info = TweenInfo.new(Windup - 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(ReishiStringHighlight, Info, {FillTransparency = 0.3}):Play()
		
		local ReishiStringSpreadSound = QuincyKidoSounds.ReishiStringSpread:Clone()
		ReishiStringSpreadSound.PlayOnRemove = true
		ReishiStringSpreadSound.Parent = Target.HumanoidRootPart
		ReishiStringSpreadSound:Destroy()
		ReishiStringSpreadSound = nil
	elseif Phase == "4" then
		Target.ReishiStringHighlight:Destroy()
	end
end

function ClientSkills.Slide(Character, Phase, BodyVelocity, Speed)
	if Phase == "1" then
		local Duration = 1.4
		
		for i, v in ipairs(QuincyKidoEffects.Slide:GetChildren()) do
			local Slide = v:Clone()
			Slide.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Slide, Duration + 1.25) 
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = Slide
			Weld.Part1 = Character[v.Name]
			Weld.Parent = Slide
			
			task.delay(Duration, function()
				for _, Particle in ipairs(Slide:GetDescendants()) do
					if Particle:IsA("ParticleEmitter") then
						Particle.Enabled = false
					end
				end
			end)
		end
		
		local SlideSound = QuincyKidoSounds.Slide:Clone()
		SlideSound.Parent = Character.HumanoidRootPart
		SlideSound:Play()
		Debris:AddItem(SlideSound, Duration + 0.2)
		
		task.delay(Duration, function()
			TweenService:Create(SlideSound, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local Player = Players.LocalPlayer
		local StepName = "Slide"
		
		local CurrentDirection = "A"
		
		RunService:BindToRenderStep(StepName, 1, function()
			local Direction
			
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				CurrentDirection = "A"
			elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
				CurrentDirection = "D"
			end
			
			if CurrentDirection == "A" then
				Direction = -Character.HumanoidRootPart.CFrame.RightVector * Speed
			elseif CurrentDirection == "D" then
				Direction = Character.HumanoidRootPart.CFrame.RightVector * Speed 
			end
			
			BodyVelocity.Velocity = Direction
		end)
		local Connection
		Connection = BodyVelocity.AncestryChanged:Connect(function()
			--ReplicatedStorage.Remotes.PositionRequest:FireServer(Character.PrimaryPart.CFrame)
			RunService:UnbindFromRenderStep(StepName)
			Connection:Disconnect()
			Connection = nil
		end)
	end
end

function ClientSkills.PiercingLight(Character, Phase, Blade, RootCFrame)
	if Phase == "1" then
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		for i, v in ipairs(Blade:GetDescendants()) do
			if v:IsA("BasePart") then
				if v ~= Blade.PrimaryPart then
					v.Transparency = 1
					TweenService:Create(v, Info, {Transparency = 0}):Play()
					task.delay(0.9, function()
						TweenService:Create(v, Info, {Transparency = 1}):Play()
					end)
				end
			elseif v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		task.delay(0.9, function()
			TweenService:Create(Blade.PiercingLight.PointLight, TweenInfo.new(0.3), {Brightness = 0}):Play()
			Blade.PiercingLight.T1.BlindingTrail.Enabled = false
		end)
	elseif Phase == "2" then
		local ShadowsTeleport = QuincyKidoEffects.ShadowsTeleport:Clone()
		ShadowsTeleport.CFrame = RootCFrame
		ShadowsTeleport.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShadowsTeleport, 0.7)

		for i, v in ipairs(ShadowsTeleport:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local ShadowsSound = QuincyKidoSounds.ShadowsTP:Clone()
		ShadowsSound.PlayOnRemove = true
		ShadowsSound.Parent = ShadowsTeleport
		ShadowsSound:Destroy()
		ShadowsSound = nil
		
		local ShadowsTeleport2 = QuincyKidoEffects.ShadowsTeleport:Clone()
		ShadowsTeleport2.CFrame = Character.HumanoidRootPart.CFrame
		ShadowsTeleport2.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShadowsTeleport2, 0.7)

		for i, v in ipairs(ShadowsTeleport2:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local ShadowsSound2 = QuincyKidoSounds.ShadowsTP:Clone()
		ShadowsSound2.PlayOnRemove = true
		ShadowsSound2.Parent = ShadowsTeleport2
		ShadowsSound2:Destroy()
		ShadowsSound2 = nil
	end
end

function ClientSkills.FocalPoint(Character, Phase)
	if Phase == "1" then
		local FocalPoint = QuincyKidoEffects.FocalPoint:Clone()
		FocalPoint.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FocalPoint, 0.85)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-6.10351562e-05, 1.10925674, -0.00048828125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = FocalPoint
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = FocalPoint
	elseif Phase == "2" then
		local FocalPointSound = QuincyKidoSounds.FocalPoint:Clone()
		FocalPointSound.PlayOnRemove = true
		FocalPointSound.Parent = Character.HumanoidRootPart
		FocalPointSound:Destroy()
		FocalPointSound = nil
	end
end

function ClientSkills.CrossShot(Character, Target, Windup, ArrowPosition)
	local Direction = (ArrowPosition - Target.HumanoidRootPart.Position).Unit
	local Position = (Target.HumanoidRootPart.CFrame + Direction * 14).Position
	
	local CrossShot = Instance.new("Model")
	CrossShot.Name = "CrossShot"
	CrossShot.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(CrossShot, Windup + 0.5)
	
	local Circle = QuincyKidoEffects.CrossShot.Circle:Clone()
	local CircleSize = Circle.Size
	Circle.Size = Vector3.zero
	Circle.CFrame = CFrame.new(Position, Target.HumanoidRootPart.Position)
	Circle.Parent = CrossShot
	
	TweenService:Create(Circle, TweenInfo.new(0.3), {Size = CircleSize}):Play()
	
	local Offsets = {
		[1] = CFrame.Angles(0, 0, 0);
		[2] = CFrame.Angles(math.pi/2, 0, 0); 
		[3] = CFrame.Angles(math.pi, 0, 0);
		[4] = CFrame.Angles(-math.pi/2, 0, 0);
		[5] = CFrame.Angles(0, math.pi, math.pi/2)
	}
	
	local Info = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	
	for i = 1, 5 do
		local Point = QuincyKidoEffects.CrossShot.Point:Clone()
		if i == 5 then
			Point.Size = Vector3.new(Point.Size.Z, 11, Point.Size.Z)
		end
		local Size = Point.Size
		Point.CFrame = Circle.CFrame * CFrame.Angles(0, math.pi/2, 0)
		Point.CFrame *= Offsets[i]
		Point.Size = Vector3.new(Size.X, 0, Size.Z)
		Point.Parent = CrossShot
		
		TweenService:Create(Point, Info, {Size = Size, CFrame = Point.CFrame * CFrame.new(0, Size.Y/2, 0)}):Play()
		task.wait((Windup - 0.25) / 5)
	end
	
	task.wait(0.15)
	
	local Info2 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	for i, v in ipairs(CrossShot:GetChildren()) do
		if v ~= Circle then
			local C0 = v.CFrame:ToObjectSpace(Circle.CFrame)
			local Weld = Instance.new("Weld")
			Weld.C0 = C0
			Weld.Part0 = v
			Weld.Part1 = Circle
			Weld.Parent = v
			v.Anchored = false
		end
	end
	
	local Direction2 = (ArrowPosition - Target.HumanoidRootPart.Position).Unit
	local Position2 = (Target.HumanoidRootPart.CFrame + Direction * 2).Position
	
	local FinalCFrame = CFrame.new(Position2, Target.HumanoidRootPart.Position)
	TweenService:Create(Circle, TweenInfo.new(0.1), {CFrame = FinalCFrame}):Play()	
	
	task.delay(0.1, function()
		local CrossShotImpact = QuincyKidoEffects.CrossShot.Impact:Clone()
		CrossShotImpact.CFrame = FinalCFrame
		CrossShotImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CrossShotImpact, 3.5)
		
		for i, v in ipairs(CrossShotImpact:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
	end)
	
	task.wait(0.15)
	
	for i, v in ipairs(CrossShot:GetChildren()) do
		TweenService:Create(v, Info2, {Transparency = 1}):Play()
	end
end

function ClientSkills.StillSilver(Character, Phase, PositiveHits, RootCFrame, Projectile, Duration)
	if Phase == "1" then
		local StillSilverJumpSound = QuincyKidoSounds.StillSilverStart:Clone()
		StillSilverJumpSound.PlayOnRemove = true
		StillSilverJumpSound.Parent = Character.HumanoidRootPart
		StillSilverJumpSound:Destroy()
		StillSilverJumpSound = nil
	elseif Phase == "2" then
		local Lifetime = Duration
		local Rate = 0.05
		local Accumulated = Rate
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			Lifetime -= DeltaTime
			if Lifetime <= 0 or not Projectile or not Projectile.Parent then
				Connection:Disconnect()
				Connection = nil
				return
			end
			
			if Accumulated > Rate and Projectile.Parent then
				Accumulated -= Rate
				
				local StillSilverWave = QuincyKidoEffects.StillSilverWaves:Clone()
				StillSilverWave.CFrame = Projectile.CFrame
				StillSilverWave.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(StillSilverWave, 1)
				
				for i, v in ipairs(StillSilverWave:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(tonumber(v.Name))
					end
				end
			end
		end)
		
		local StillSilverReleaseSound = QuincyKidoSounds.StillSilverRelease:Clone()
		StillSilverReleaseSound.PlayOnRemove = true
		StillSilverReleaseSound.Parent = Character.HumanoidRootPart
		StillSilverReleaseSound:Destroy()
		StillSilverReleaseSound = nil
		
		--[[
		local Offset = CFrame.new(-0.490844727, 0.239709854, -3.25982666, 0.766044557, -2.28299069e-08, 0.642787516, -0.642787516, 1.91565608e-08, 0.766044557, -2.98023206e-08, -0.99999994, 0)
		
		task.spawn(function()
			for i = 1, 5 do
				local StillSilverShockwave = QuincyKidoEffects.StillSilverShockwave:Clone()
				StillSilverShockwave.CFrame = RootCFrame * Offset
				StillSilverShockwave.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(StillSilverShockwave, 0.3)

				if i < 3 then
					for i, v in ipairs(StillSilverShockwave:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v:Emit(tonumber(v.Name))
						end
					end
				end

				local Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

				TweenService:Create(StillSilverShockwave, Info, {Position = (RootCFrame * CFrame.new(0, 0, -20)).Position}):Play()

				task.delay(0.15, function()
					local Size = StillSilverShockwave.Size
					TweenService:Create(StillSilverShockwave, TweenInfo.new(0.25), {Transparency = 1, Size = Vector3.new(Size.X/4, Size.Y/4, Size.Z/4)}):Play()	
				end)

				local Duration = 0.4
				local Connection
				Connection = RunService.RenderStepped:Connect(function(DeltaTime)
					Duration -= DeltaTime
					if Duration <= 0 then
						Connection:Disconnect()
						Connection = nil
						return
					end

					StillSilverShockwave.CFrame *= CFrame.Angles(0, 0.3, 0)
				end)

				task.wait(0.1)
			end
		end)
		
		for i = 1, 5 do
			local StillSilverShockwave = QuincyKidoEffects.StillSilverShockwave:Clone()
			StillSilverShockwave.CFrame = RootCFrame * Offset
			StillSilverShockwave.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(StillSilverShockwave, 0.3)

			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

			TweenService:Create(StillSilverShockwave, Info, {Position = (RootCFrame * CFrame.new(0, 0, 6)).Position}):Play()

			task.delay(0.15, function()
				local Size = StillSilverShockwave.Size
				TweenService:Create(StillSilverShockwave, TweenInfo.new(0.25), {Transparency = 1, Size = Vector3.new(Size.X * 2, Size.Y * 2, Size.Z * 2)}):Play()	
			end)

			local Duration = 0.4
			local Connection
			Connection = RunService.RenderStepped:Connect(function(DeltaTime)
				Duration -= DeltaTime
				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
					return
				end

				StillSilverShockwave.CFrame *= CFrame.Angles(0, 0.3, 0)
			end)

			task.wait(0.1)
		end]]
	elseif Phase == "3" then
		for i, v in ipairs(PositiveHits) do
			local StillSilver = QuincyKidoEffects.StillSilverHit:Clone()
			StillSilver.CFrame = v.HumanoidRootPart.CFrame
			StillSilver.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(StillSilver)
			
			for i, v in ipairs(StillSilver:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.Name))
				end
			end
			
			local StillSilverImpactSound = QuincyKidoSounds.StillSilverImpact:Clone()
			StillSilverImpactSound.PlayOnRemove = true
			StillSilverImpactSound.Parent = v.HumanoidRootPart
			StillSilverImpactSound:Destroy()
			StillSilverImpactSound = nil
		end
	end
end

function ClientSkills.Shadows(Character, Phase, Target, Windup, RootCFrame)
	if Phase == "1" then
		local Shadows = QuincyKidoEffects.Shadows:Clone()
		Shadows.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Shadows, Windup + 1)
		
		local OriginalDistance = 12
		local Distance = OriginalDistance
		
		local Duration = Windup
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Duration -= DeltaTime
			if Duration <= 0 or not Target:FindFirstChild("HumanoidRootPart") or Character:GetAttribute("CurrentState") == "TrueStunned" and Character:GetAttribute("CurrentState") == "PostureBroken" then
				Connection:Disconnect()
				Connection = nil
				
				for i, v in ipairs(Shadows:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
				return
			end
			
			local WindupRange = 0 - Windup
			local DistanceRange = 0 - OriginalDistance
			local ScaledDistance = (((Duration - Windup) * DistanceRange) / WindupRange) + OriginalDistance
			
			local Direction = (Character.HumanoidRootPart.Position - Target.HumanoidRootPart.Position).Unit
			local Position = (Target.HumanoidRootPart.CFrame + Direction * ScaledDistance).Position

			local ShadowsCFrame = CFrame.new(Position, Target.HumanoidRootPart.Position)
			Shadows.CFrame = ShadowsCFrame
		end)
		
		local ShadowsSound = QuincyKidoSounds.ShadowsSpawn:Clone()
		ShadowsSound.Parent = Shadows
		ShadowsSound:Play()
		Debris:AddItem(ShadowsSound, Windup + 0.2)
		
		task.delay(Windup, function()
			TweenService:Create(ShadowsSound, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local function RandomNumber(Min, Max)
			local RNG = Random.new()
			return RNG:NextNumber(Min, Max)
		end
		
		local Distance = 0.7
		local Rate = 0.03
		local Info = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		
		local Entity = Target or Character		
		
		local ShadowsSound = QuincyKidoSounds.ShadowsEncapsulate:Clone()
		ShadowsSound.Parent = Entity.HumanoidRootPart
		ShadowsSound:Play()
		Debris:AddItem(ShadowsSound, ShadowsSound.TimeLength)
		
		local Duration = Windup
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			Duration -= DeltaTime
			
			if Duration <= 0 or not Entity:FindFirstChild("HumanoidRootPart") then
				Connection:Disconnect()
				Connection = nil
				return
			end
			
			if Accumulated > Rate then
				Accumulated -= Rate
				
				for i, v in ipairs(Entity:GetChildren()) do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "Head" then
						local Shadow = v:Clone()
						Shadow.Color = Color3.fromRGB(50, 50, 50)
						Shadow.Material = Enum.Material.Neon
						Shadow.Transparency = 0.1
						Shadow.CFrame = v.CFrame
						Shadow.CanCollide = false
						Shadow.Anchored = true
						Shadow:ClearAllChildren()
						Shadow.Parent = workspace.Effects[Character.Name]
						Debris:AddItem(Shadow, 0.2)
						
						local ShadowCFrame = Shadow.CFrame * CFrame.new(RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance))
						TweenService:Create(Shadow, Info, {CFrame = ShadowCFrame, Transparency = 1}):Play()
					elseif v:IsA("Accessory") then
						if v:FindFirstChild("Handle") then
							local Handle = v.Handle:Clone()
							Handle.AccessoryWeld:Destroy()
							Handle.Anchored = true
							Handle.CanCollide = false
							Handle.Color = Color3.fromRGB(50, 50, 50)
							Handle.Material = Enum.Material.Neon
							Handle.Transparency = 0.1
							Handle.CFrame = v.Handle.CFrame

							local Mesh = Handle:FindFirstChildWhichIsA("SpecialMesh")
							if Mesh then
								Mesh.VertexColor = color3ToVector3(Handle.Color)
							end
							Handle.Parent = workspace.Effects[Character.Name]
							Debris:AddItem(Handle, 0.2)

							local ShadowCFrame = Handle.CFrame * CFrame.new(RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance))
							TweenService:Create(Handle, Info, {CFrame = ShadowCFrame, Transparency = 1}):Play()
						end
					end
				end
			end
		end)
	elseif Phase == "3" then
		local ShadowsTeleport = QuincyKidoEffects.ShadowsTeleport:Clone()
		ShadowsTeleport.CFrame = RootCFrame
		ShadowsTeleport.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShadowsTeleport, 0.7)
		
		for i, v in ipairs(ShadowsTeleport:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local ShadowsSound = QuincyKidoSounds.ShadowsTP:Clone()
		ShadowsSound.PlayOnRemove = true
		ShadowsSound.Parent = ShadowsTeleport
		ShadowsSound:Destroy()
		ShadowsSound = nil
		
		local ShadowsTeleport2 = QuincyKidoEffects.ShadowsTeleport:Clone()
		ShadowsTeleport2.CFrame = Character.HumanoidRootPart.CFrame
		ShadowsTeleport2.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShadowsTeleport2, 0.7)

		for i, v in ipairs(ShadowsTeleport2:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local ShadowsSound2 = QuincyKidoSounds.ShadowsTP:Clone()
		ShadowsSound2.PlayOnRemove = true
		ShadowsSound2.Parent = ShadowsTeleport2
		ShadowsSound2:Destroy()
		ShadowsSound2 = nil
	elseif Phase == "4" then
		local function roundNumber(num, numDecimalPlaces)
			return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
		end
		
		local Health = (Target.Humanoid.Health / Target.Humanoid.MaxHealth) * 100
		local Reiatsu = (Target:GetAttribute("Reiatsu") / Target:GetAttribute("MaxReiatsu")) * 100
		
		local ShadowsUI = ReplicatedStorage.Assets.UIs.EyeOfAKing:Clone()
		ShadowsUI.Adornee = Target.HumanoidRootPart
		ShadowsUI.TextLabel.Text = roundNumber(Health, 1) .. "%\n" .. roundNumber(Reiatsu, 1) .. "%"
		ShadowsUI.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShadowsUI, Windup)
		
		local Connection
		Connection = Target.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			local CurrentHealth = (Target.Humanoid.Health / Target.Humanoid.MaxHealth) * 100
			local CurrenReiatsu = (Target:GetAttribute("Reiatsu") / Target:GetAttribute("MaxReiatsu")) * 100

			if ShadowsUI and ShadowsUI.Parent then
				ShadowsUI.TextLabel.Text = roundNumber(CurrentHealth, 1) .. "%\n" .. roundNumber(CurrenReiatsu, 1) .. "%"
			end
		end)

		task.delay(Windup, function()
			Connection:Disconnect()
			Connection = nil
		end)
	end
end

function ClientSkills.HolySelection(Character, Target, Windup)
	local PillarOffset = CFrame.new(0, 258.357147, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	
	local RootCFrame = Target.HumanoidRootPart.CFrame
	
	local HolySelection = QuincyKidoEffects.HolySelectionPillar:Clone()
	local Size = HolySelection.Size
	HolySelection.CFrame = RootCFrame * PillarOffset * CFrame.new(0, Size.Y/2, 0)
	HolySelection.Size = Vector3.new(Size.X, 0, Size.Z)
	HolySelection.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(HolySelection, Windup + 0.4)

	local Info = TweenInfo.new(Windup, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	local Info2 = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(HolySelection, Info, {Size = Size, CFrame = HolySelection.CFrame * CFrame.new(0, -Size.Y/2, 0)}):Play()

	task.delay(Windup, function()
		local AudioBlock = ReplicatedStorage.Assets.Effects.AudioBlock:Clone()
		AudioBlock.CFrame = RootCFrame
		AudioBlock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AudioBlock, 0.3)

		local HolySelectionSound = QuincyKidoSounds.HolySelection:Clone()
		HolySelectionSound.PlayOnRemove = true
		HolySelectionSound.Parent = AudioBlock
		HolySelectionSound:Destroy()
		HolySelectionSound = nil

		task.wait(0.25)

		TweenService:Create(HolySelection, Info2, {Size = Vector3.new(0, HolySelection.Size.Y, 0), Transparency = 1}):Play()
		TweenService:Create(HolySelection.Attachment.PointLight, Info2, {Brightness = 0}):Play()

		local HolySelectionSound = QuincyKidoSounds.HolySelection:Clone()
		HolySelectionSound.PlayOnRemove = true
		HolySelectionSound.Parent = AudioBlock
		HolySelectionSound:Destroy()
		HolySelectionSound = nil

		local HolySelectionDespawnSound = QuincyKidoSounds.HolySelectionDespawn:Clone()
		HolySelectionDespawnSound.PlayOnRemove = true
		HolySelectionDespawnSound.Parent = AudioBlock
		HolySelectionDespawnSound:Destroy()
		HolySelectionDespawnSound = nil
	end)
end

function ClientSkills.LichtRegen(Character, Phase, Duration, Speed, Remote, SpawnPoint, Radius)
	if Phase == "1" then
		for i, v in ipairs(QuincyKidoEffects.Slide:GetChildren()) do
			local Slide = v:Clone()
			Slide.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Slide, Duration + 1.25) 

			local Weld = Instance.new("Weld")
			Weld.Part0 = Slide
			Weld.Part1 = Character[v.Name]
			Weld.Parent = Slide

			task.delay(Duration, function()
				for _, Particle in ipairs(Slide:GetDescendants()) do
					if Particle:IsA("ParticleEmitter") then
						Particle.Enabled = false
					end
				end
			end)
		end

		local SlideSound = QuincyKidoSounds.Slide:Clone()
		SlideSound.Parent = Character.HumanoidRootPart
		SlideSound:Play()
		Debris:AddItem(SlideSound, Duration + 0.2)

		task.delay(Duration, function()
			TweenService:Create(SlideSound, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Phase == "1slide" then
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {workspace.Entities, workspace.Effects}
		
		local ClimbCooldown
		local Climbing = false
		local BodyPosition
		local BodyGyro
		
		local function CreateBodyVelocity()
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Name = "DashForce"
			BodyVelocity.MaxForce = Vector3.new(60000, 0, 60000)
			BodyVelocity.P = 1250
			BodyVelocity.Parent = Character.HumanoidRootPart
			return BodyVelocity
		end
		
		local BodyVelocity = CreateBodyVelocity()
		
		local UpdatedPosition
		local UpdatedCFrame
		
		local Lifetime = Duration
		while true do
			local Step = task.wait()
			local RootCFrame = Character.HumanoidRootPart.CFrame
			local Wall
			if Climbing then
				Wall = workspace:Raycast(RootCFrame.Position, RootCFrame.UpVector * -5, Params)
			else
				Wall = workspace:Raycast(RootCFrame.Position, RootCFrame.LookVector * 5, Params)
			end
			
			if Wall or Climbing then
				if not Climbing then
					Climbing = true
					Remote:FireServer(true)
					Lifetime = Duration * 0.6
				end

				Character.Humanoid.AutoRotate = false
				if BodyVelocity then
					BodyVelocity:Destroy()
					BodyVelocity = nil
				end
				
				local ClimbCFrame = RootCFrame
				
				local ClimbSpeed = 7
				if Wall then
					local Position = Wall.Position + Wall.Normal * 3
					UpdatedPosition = CFrame.new(Wall.Position + Wall.Normal, Wall.Position)
					UpdatedCFrame = UpdatedPosition.Rotation + Position
				end
				
				if not BodyPosition then
					BodyPosition = Instance.new("BodyPosition")
					BodyPosition.Name = "ClimbMover"
					BodyPosition.Position = UpdatedCFrame.Position
					BodyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
					BodyPosition.P = 50000
					BodyPosition.Parent = Character.Head
					
					BodyGyro = Instance.new("BodyGyro")
					BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
					BodyGyro.P = 50000
					BodyGyro.CFrame = CFrame.new(UpdatedCFrame.Position, Wall.Position)
					BodyGyro.Parent = Character.HumanoidRootPart
				end
				
				if Wall then
					UpdatedCFrame *= CFrame.new(0, ClimbSpeed, 0)
				else
					UpdatedCFrame *= CFrame.new(0, ClimbSpeed / ClimbSpeed, 0)
				end
				
				ClimbCFrame = UpdatedCFrame
				
				if Wall then
					if Wall.Normal.Y > 0.2 or Wall.Normal.Y < -0.75 then
						Climbing = false
					end
				end
				
				BodyPosition.Position = ClimbCFrame.Position
				BodyGyro.CFrame = ClimbCFrame * CFrame.Angles(math.pi/2, 0, 0)
			else
				if Climbing then
					Climbing = false
					Remote:FireServer(false)
				end
				
				Character.Humanoid.AutoRotate = true
				if BodyPosition then
					BodyPosition:Destroy()
					BodyPosition = nil
				end
				if BodyGyro then
					BodyGyro:Destroy()
					BodyGyro = nil
				end
				if not BodyVelocity then
					BodyVelocity = CreateBodyVelocity()
				end
				BodyVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * Speed
			end
			
			Lifetime -= Step
			
			if Lifetime <= 0 or not Character:GetAttribute("LichtRegen") then
				break
			end
		end
		
		if BodyVelocity then
			BodyVelocity:Destroy()
			BodyVelocity = nil
		end
		if BodyPosition then
			BodyPosition:Destroy()
			BodyPosition = nil
		end
		if BodyGyro then
			BodyGyro:Destroy()
			BodyGyro = nil
		end
		
		local Mouse = Players.LocalPlayer:GetMouse()			
		
		local Wall
		local Speed = 70
		if not Climbing then
			Speed = 85
		else
			local RootCFrame = Character.HumanoidRootPart.CFrame
			Wall = workspace:Raycast(RootCFrame.Position, RootCFrame.UpVector * -5, Params)
			if not Wall then
				Speed = 1
			end
		end
		
		local Vector = Character.HumanoidRootPart.CFrame.UpVector

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		BodyVelocity.Velocity = Vector * Speed
		BodyVelocity.Parent = Character.Head

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		BodyGyro.P = 50000
		BodyGyro.Parent = Character.HumanoidRootPart

		local Cancel
		local Freeze
		while true do
			if Cancel or Speed <= -10 then
				Character.Humanoid.AutoRotate = true
				return
			end
			Speed -= task.wait() * 120

			BodyGyro.CFrame = CFrame.lookAt(Character.HumanoidRootPart.Position, Mouse.Hit.Position)

			if not Freeze then
				if Speed <= 0 then
					Freeze = true
					
					local Duration = 0.3
					if not Wall then
						Duration = 0.5
					end
					
					Debris:AddItem(BodyVelocity, Duration)
					task.delay(Duration, function()
						BodyGyro:Destroy()
						BodyGyro = nil
						Cancel = true
					end)
				else
					if Speed <= 0 then
						Speed = 0
					end
					BodyVelocity.Velocity = Vector * Speed
				end
			end
		end
	elseif Phase == "2" then
		local LichtStar = QuincyKidoEffects.LichtRegenStar.LichtStar:Clone()
		LichtStar.Parent = Character.HumanoidRootPart
		Debris:AddItem(LichtStar, 0.7)
		
		for i, v in ipairs(LichtStar:GetChildren()) do
			v:Emit(tonumber(v.Name))
		end
		
		local AudioBlock = ReplicatedStorage.Assets.Effects.AudioBlock:Clone()
		AudioBlock.CFrame = Character.HumanoidRootPart.CFrame
		AudioBlock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AudioBlock, 0.6)
		
		local LichtRegenFire = QuincyKidoSounds.LichtRegenFire:Clone()
		LichtRegenFire.PlayOnRemove = true
		LichtRegenFire.Parent = AudioBlock
		LichtRegenFire:Destroy()
		LichtRegenFire = nil
		
		if Duration then
			for i = 1, 3 do
				task.wait(0.1)
				
				local LichtRegenFire = QuincyKidoSounds.LichtRegenFire:Clone()
				LichtRegenFire.PlayOnRemove = true
				LichtRegenFire.Parent = AudioBlock
				LichtRegenFire:Destroy()
				LichtRegenFire = nil
			end
		end
	elseif Phase == "3" then
		local EffectInfo = {
			Explosion = {
				Spin = CFrame.fromEulerAnglesXYZ(0.5, 0.5, 0.5);

				SizeTween = {
					Size = Vector3.new(Radius * 2 - 0.4, Radius * 2 - 0.4, Radius * 2 - 0.4);
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
				};
				SizeFade = {
					Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.zero;
					TimeDelay = 0.2;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.27;
				};
			};
			ExplosionRing = {
				Spin = CFrame.fromEulerAnglesXYZ(0.5, 0.5, 0.5);

				SizeTween = {
					Size = Vector3.new(Radius * 2 + 0.5, Radius * 2 + 0.5, Radius * 2 + 0.5);
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
				};
				SizeFade = {
					Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.zero;
					TimeDelay = 0.2;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.25;
				};
			};
			XShockwave = {
				Spin = CFrame.fromEulerAnglesXYZ(0, 0.5, 0);

				SizeTween = {
					Size = Vector3.new(Radius * 3, 1, Radius * 3);
					Info = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false);	
				};
				SizeFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(Radius * 3.5, 1, Radius * 3.5);
					TimeDelay = 0.27;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0.5;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.3;
				};
			};
			YShockwave = {
				Spin = CFrame.fromEulerAnglesXYZ(0, 0.5, 0);

				SizeTween = {
					Size = Vector3.new(Radius * 3, 3.2, Radius * 3);
					Info = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)	
				};
				SizeFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(Radius * 3.5, 1, Radius * 3.5);
					TimeDelay = 0.47;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0.5;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.5;
				};
			};
		}

		local function RandomAngle(SpawnCFrame)
			local Min, Max = -math.pi * 2, math.pi * 2
			local RNG = Random.new()
			return SpawnCFrame * CFrame.Angles(RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max))
		end

		local Explosion = QuincyKidoEffects.LichtRegen:Clone()
		Explosion:PivotTo(RandomAngle(SpawnPoint))
		for i, v in ipairs(Explosion:GetChildren()) do
			local Info = EffectInfo[v.Name]
			if Info then
				if Info.SizeTween then
					v.Size = Vector3.zero
				end
				if Info.TransparencyTween then
					v.Transparency = 1
				end
			end
		end
		Explosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Explosion, 1)

		for i, v in ipairs(Explosion:GetChildren()) do
			local Info = EffectInfo[v.Name]
			if Info then
				if Info.SizeTween then
					TweenService:Create(v, Info.SizeTween.Info, {Size = Info.SizeTween.Size}):Play()
				end
				if Info.TransparencyTween then
					TweenService:Create(v, Info.TransparencyTween.Info, {Transparency = Info.TransparencyTween.Transparency}):Play()
				end
				if Info.SizeFade then
					task.delay(Info.SizeFade.TimeDelay, function()
						TweenService:Create(v, Info.SizeFade.Info, {Size = Info.SizeFade.Size}):Play()
					end)
				end
				if Info.TransparencyFade then
					task.delay(Info.TransparencyFade.TimeDelay, function()
						TweenService:Create(v, Info.TransparencyFade.Info, {Transparency = 1}):Play()
					end)
				end
			end
		end

		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated > 1 then
				Connection:Disconnect()
				Connection = nil
				return
			end

			for i, v in ipairs(Explosion:GetChildren()) do
				if EffectInfo[v.Name] and EffectInfo[v.Name].Spin then
					v.CFrame *= EffectInfo[v.Name].Spin
				end
			end
		end)
		
		local LichtRegenExplode = QuincyKidoSounds.LichtRegenExplosion:Clone()
		LichtRegenExplode.PlayOnRemove = true
		LichtRegenExplode.Parent = Explosion.PrimaryPart
		LichtRegenExplode:Destroy()
		LichtRegenExplode = nil
		
		task.delay(0.5, function()	
			for i, v in ipairs(Explosion.Effects:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				elseif v:IsA("PointLight") then
					TweenService:Create(v, TweenInfo.new(0.5), {Range = 0}):Play()
				end
			end
		end)
	end
end

--==================================================
--======================Kendo=======================
--==================================================

function ClientSkills.DuelistsDance(Character)

end

function ClientSkills.Brace(Character, Duration)
	local BraceSound = KendoSounds.Brace:Clone()
	BraceSound.Parent = Character.PrimaryPart
	BraceSound:Play()
	Debris:AddItem(BraceSound, BraceSound.TimeLength)
	
	local Brace = KendoEffects.Brace:Clone()
	Brace.Anchored = false
	Brace.Parent = Character
	Debris:AddItem(Brace, Duration)
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(0, 2.9000001, -1.14440918e-05, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Part0 = Brace
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = Brace
	
	for i, v in ipairs(Brace:GetChildren()) do
		v.Enabled = true
	end
end

function ClientSkills.Safeguard(Character)

end

function ClientSkills.OverpoweringSlash(Character, Phase)
	if Phase == "1" then
		local SmoothSlash = KendoEffects["Smooth Slash"]:Clone()
		SmoothSlash.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(math.pi/2, 0, math.pi/2)
		SmoothSlash.Parent = Character.HumanoidRootPart
		Debris:AddItem(SmoothSlash, 1)
		
		for i, v in ipairs(SmoothSlash.Attachment:GetChildren()) do
			if Character:GetAttribute("VisoredActive") then
				v.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0));
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				})
			end
			v:Emit(5)
		end
		
		
	elseif Phase == "2" then
		local GreatswordSound = ReplicatedStorage.Assets.ShikaiSounds.GreatswordCrit:Clone()
		GreatswordSound.PlayOnRemove = true
		GreatswordSound.Parent = Character.HumanoidRootPart
		GreatswordSound:Destroy()
		GreatswordSound = nil

		local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
		GSCritEffect.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -1, -2))
		GSCritEffect.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
			v:Emit(50)
		end
		Debris:AddItem(GSCritEffect, 1.5)

		local DebrisData = {
			Amount = math.random(3, 5),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 1.5,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5), DebrisData)
	elseif Phase == "Startup" then
		local KendoUnsheathe = KendoSounds.KendoUnsheathe:Clone()
		KendoUnsheathe.PlayOnRemove = true
		KendoUnsheathe.Parent = Character.HumanoidRootPart
		KendoUnsheathe:Destroy()
		KendoUnsheathe = nil
		
		task.delay(0.23, function()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				local HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
				HyperArmorHighlight.Parent = Character
				Debris:AddItem(HyperArmorHighlight, 0.77)
			end
		end)
	end
end

function ClientSkills.Thrust(Character, RootCFrame)
	local ThrustEffect = KendoEffects.Thrust:Clone()
	ThrustEffect:PivotTo(RootCFrame * CFrame.new(0.5, 0, -3) * CFrame.Angles(0, math.pi, 0))
	ThrustEffect.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(ThrustEffect, 1.5)
	for i, v in ipairs(ThrustEffect:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(10)
		end
	end
	
	local ThrustSound = KendoSounds.Thrust:Clone()
	ThrustSound.PlayOnRemove = true
	ThrustSound.Parent = Character.PrimaryPart
	ThrustSound:Destroy()
	ThrustSound = nil
end

function ClientSkills.Suikawari(Character)
	local SuikawariSound = KendoSounds.Suikawari:Clone()
	SuikawariSound.Parent = Character.PrimaryPart
	SuikawariSound:Play()
	Debris:AddItem(SuikawariSound, SuikawariSound.TimeLength)
	
	local DownwardSlash = KendoEffects.DownwardSlash:Clone()
	DownwardSlash.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -2, -5)
	DownwardSlash.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(DownwardSlash, 1)
	
	for i, v in ipairs(DownwardSlash:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(3)
		end
	end
end

function ClientSkills.Senmaioroshi(Character, RootCFrame)
	local Clone = SharedFunctions:CreateClone(Character, RootCFrame)
	Debris:AddItem(Clone, 1)
	
	local Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	
	for i, v in ipairs(Clone:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Entity2"
			TweenService:Create(v, Info, {Transparency = 1}):Play()
		elseif v:IsA("Decal") then
			TweenService:Create(v, Info, {Transparency = 1}):Play()
		end
	end
	
	local MultiSlashEffect = KendoEffects.Multi_front_slash:Clone()
	MultiSlashEffect.CFrame = RootCFrame
	MultiSlashEffect.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(MultiSlashEffect, 1)

	for i, v in ipairs(MultiSlashEffect.Slashes:GetChildren()) do
		v:Emit(7)
	end
	
	local SenmaioroshiSound = KendoSounds.Senmaioroshi:Clone()
	SenmaioroshiSound.Parent = Character.PrimaryPart
	SenmaioroshiSound:Play()
	Debris:AddItem(SenmaioroshiSound, SenmaioroshiSound.TimeLength)
	
	local SenmaioroshiAnimation = Clone.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.SkillAnimations.Kendo.SkillSenmaioroshi)
	SenmaioroshiAnimation:Play()
	SenmaioroshiAnimation.KeyframeReached:Connect(function(KeyframeName)
		if KeyframeName == "HitFrame" then
			local MultiSlashEffect = KendoEffects.Multi_front_slash:Clone()
			MultiSlashEffect.CFrame = RootCFrame
			MultiSlashEffect.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(MultiSlashEffect, 1)

			for i, v in ipairs(MultiSlashEffect.Slashes:GetChildren()) do
				v:Emit(7)
			end
		end
	end)
end

function ClientSkills.PressureShift(Character, Counter, CounterOwner, CounterDuration)
	if Counter == "Counter" then
		local KendoSheathe = KendoSounds.KendoSheathe:Clone()
		KendoSheathe.PlayOnRemove = true
		KendoSheathe.Parent = Character.HumanoidRootPart
		KendoSheathe:Destroy()
		KendoSheathe = nil
	elseif Counter == "Countered" then
		local PressureShiftSlashes = KendoEffects.PressureShiftSlashes:Clone()
		PressureShiftSlashes.Anchored = false
		PressureShiftSlashes.Parent = workspace.Effects[CounterOwner.Name]
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = PressureShiftSlashes
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = PressureShiftSlashes
		
		PressureShiftSlashes.shard.Enabled = true
		PressureShiftSlashes.shard2.Enabled = true
		
		task.delay(0.8, function()
			PressureShiftSlashes.shard.Enabled = false
			PressureShiftSlashes.shard2.Enabled = false
			PressureShiftSlashes.PointLight.Enabled = false
			Debris:AddItem(PressureShiftSlashes, 1)
		end)
		
		local KendoUnsheathe = KendoSounds.KendoUnsheathe:Clone()
		KendoUnsheathe.PlayOnRemove = true
		KendoUnsheathe.Parent = CounterOwner.HumanoidRootPart
		KendoUnsheathe:Destroy()
		KendoUnsheathe = nil
		
		local JudgementCut = KendoSounds.JudgementCut:Clone()
		JudgementCut.Parent = Character.HumanoidRootPart
		JudgementCut:Play()
		
		task.delay(1.4, function()
			if JudgementCut then
				TweenService:Create(JudgementCut, TweenInfo.new(0.2), {Volume = 0}):Play()
				Debris:AddItem(JudgementCut, 0.2)
			end
		end)
	end
end

function ClientSkills.Bisection(Character, RootCFrame)		
	local Bisection = KendoEffects.Bisection:Clone()
	if Character:GetAttribute("VisoredActive") then
		Bisection.Color = Color3.fromRGB(255, 0, 0)
	end	
	if Character:GetAttribute("LetztStilActive") then
		Bisection.Color = Color3.fromRGB(234, 226, 132) -- 148, 235, 255
	end
	local BisectionSize = Bisection.Size
	Bisection.Size = Vector3.zero
	Bisection.Transparency = 1
	Bisection.CFrame = RootCFrame * CFrame.Angles(0, -math.pi/2, 0) * CFrame.new(-7, -BisectionSize.Y/2 + 2, 0) 
	Bisection.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Bisection, 1.5)

	local Info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(Bisection, Info, {Transparency = 0, Size = BisectionSize, CFrame = Bisection.CFrame * CFrame.new(-BisectionSize.X/2, BisectionSize.Y/2, 0)}):Play()

	task.delay(1, function()
		TweenService:Create(Bisection, Info, {Transparency = 1, Size = Vector3.new(BisectionSize.X, 0, BisectionSize.Z), CFrame = Bisection.CFrame * CFrame.new(0, -BisectionSize.Y/2, 0)}):Play()
	end)
	
	local BisectionSound = KendoSounds.Bisection:Clone()
	BisectionSound.PlayOnRemove = true
	BisectionSound.Parent = Character.HumanoidRootPart
	BisectionSound:Destroy()
	BisectionSound = nil
end

function ClientSkills.RisingSwallow(Character)
	local RisingSwallowUp = KendoEffects.RisingSwallowUP:Clone()
	RisingSwallowUp.Anchored = false
	RisingSwallowUp.Parent = workspace.Effects[Character.Name]
	RisingSwallowUp.Weld.Part0 = Character.HumanoidRootPart
	
	local RisingSwallowSpin = KendoEffects.RisingSwallowSpin.Enable:Clone()
	for i, v in ipairs(RisingSwallowSpin:GetChildren()) do
		if Character:GetAttribute("VisoredActive") then
			v.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 1, 1));
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0));
			})
		end	
	end
	RisingSwallowSpin.Parent = Character.HumanoidRootPart
	
	local RisingSwallowUptilt = KendoSounds.RisingSwallowUptilt:Clone()
	RisingSwallowUptilt.Parent = Character.HumanoidRootPart
	RisingSwallowUptilt:Play()
	Debris:AddItem(RisingSwallowUptilt, RisingSwallowUptilt.TimeLength)
	
	task.delay(0.7, function()
		for i, v in ipairs(RisingSwallowSpin:GetChildren()) do
			v.Enabled = false
		end
		Debris:AddItem(RisingSwallowSpin, 1)
	end)
	
	task.delay(0.1, function()
		for i, v in ipairs(RisingSwallowUp:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
		Debris:AddItem(RisingSwallowUp, 1)
	end)
end

function ClientSkills.SplitGate(Character, Phase)
	if Phase == "1" then
		local SplitGateSound = KendoSounds.SplitGate:Clone()
		SplitGateSound.PlayOnRemove = true
		SplitGateSound.Parent = Character.HumanoidRootPart
		SplitGateSound:Destroy()
		SplitGateSound = nil
	elseif Phase == "2" then
		local SplitGate = KendoEffects.SplitGate:Clone()
		SplitGate.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, -4)
		SplitGate.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SplitGate, 3.5)
		
		TweenService:Create(SplitGate.PointLight, TweenInfo.new(3.5), {Brightness = 0}):Play()
		
		for i, v in ipairs(SplitGate:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end
		
		local SplitGateOpen = KendoSounds.SplitGateOpen:Clone()
		SplitGateOpen.PlayOnRemove = true
		SplitGateOpen.Parent = Character.HumanoidRootPart
		SplitGateOpen:Destroy()
		SplitGateOpen = nil
	end
end

function ClientSkills.VerticalDown(Character, Phase)
	if Phase == "1" then
		local VerticalDownSound = KendoSounds.VerticalDown:Clone()
		VerticalDownSound.PlayOnRemove = true
		VerticalDownSound.Parent = Character.HumanoidRootPart
		VerticalDownSound:Destroy()
		VerticalDownSound = nil
	elseif Phase == "2" then
		local VerticalDown = KendoEffects.VerticalDown:Clone()
		VerticalDown.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, -4)
		VerticalDown.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(VerticalDown, 3.5)

		TweenService:Create(VerticalDown.PointLight, TweenInfo.new(3.5), {Brightness = 0}):Play()

		for i, v in ipairs(VerticalDown:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end
		
		local VerticalDownOpen = KendoSounds.VerticalDownOpen:Clone()
		VerticalDownOpen.PlayOnRemove = true
		VerticalDownOpen.Parent = Character.HumanoidRootPart
		VerticalDownOpen:Destroy()
		VerticalDownOpen = nil
	end
end

function ClientSkills.TruePierce(Character, Target)
	local TruePierce = KendoEffects.TruePierce:Clone()
	TruePierce.CFrame = Target.HumanoidRootPart.CFrame
	TruePierce.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(TruePierce, 3.5)
	
	for i, v in ipairs(TruePierce:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(10)
		end
	end
	
	TweenService:Create(TruePierce.PointLight, TweenInfo.new(3.5), {Brightness = 0}):Play()
	
	local TruePierceSound = KendoSounds.TruePierce:Clone()
	TruePierceSound.PlayOnRemove = true
	TruePierceSound.Parent = Target.HumanoidRootPart
	TruePierceSound:Destroy()
	TruePierceSound = nil	
end

function ClientSkills.FlowerPassage(Character, Phase, AerialHitCounter, RootCFrame)
	if Phase == "1" then
		local FlowerPassageShine = KendoEffects.FlowerPassageShine.Shine:Clone()
		FlowerPassageShine.Parent = Character["Right Arm"]
		Debris:AddItem(FlowerPassageShine, 1)
		
		FlowerPassageShine.Shine1:Emit(1)
		
		local FlowerPassageStartSound = KendoSounds.FlowerPassageStart:Clone()
		FlowerPassageStartSound.PlayOnRemove = true
		FlowerPassageStartSound.Parent = Character.HumanoidRootPart
		FlowerPassageStartSound:Destroy()
		FlowerPassageStartSound = nil
	elseif Phase == "2" then
		local HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
		HyperArmorHighlight.Parent = Character
		Debris:AddItem(HyperArmorHighlight, 0.8)
	elseif Phase == "3" then
		local FlowerPassage = KendoEffects.FlowerPassage:Clone()
		FlowerPassage.CFrame = RootCFrame * CFrame.new(0, -1.00000143, 6.10351562e-05, 0, -1, 0, 0, 0, -1, 1, 0, 0)
		FlowerPassage.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FlowerPassage, 3)
		
		if AerialHitCounter == 1 then
			FlowerPassage.Left:Emit(180)
		else
			FlowerPassage.Right:Emit(180)
		end
		
		local FlowerPassageSlashSound = KendoSounds.FlowerPassageSlash:Clone()
		FlowerPassageSlashSound.PlayOnRemove = true
		FlowerPassageSlashSound.Parent = Character.HumanoidRootPart
		FlowerPassageSlashSound:Destroy()
		FlowerPassageSlashSound = nil
	elseif Phase == "4" then
		local FlowerPassagePetals = KendoEffects.FlowerPassagePetals.Blossom:Clone()
		FlowerPassagePetals.Parent = Character.HumanoidRootPart
		Debris:AddItem(FlowerPassagePetals, 4)
		task.delay(1, function()
			FlowerPassagePetals.Enabled = false
		end)
		
		local FlowerPassageThrust = KendoSounds.FlowerPassageThrust:Clone()
		FlowerPassageThrust.PlayOnRemove = true
		FlowerPassageThrust.Parent = Character.HumanoidRootPart
		FlowerPassageThrust:Destroy()
		FlowerPassageThrust = nil
		
		local FlowerPassageDash = KendoSounds.FlowerPassageDash:Clone()
		FlowerPassageDash.PlayOnRemove = true
		FlowerPassageDash.Parent = Character.HumanoidRootPart
		FlowerPassageDash:Destroy()
		FlowerPassageDash = nil
	end
end

function ClientSkills.CrescentRelief(Character, Phase, SpawnCFrame, Speed)
	if Phase == "1" then
		local CrescentReliefStart = KendoEffects.CrescentReliefStart:Clone()
		CrescentReliefStart.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CrescentReliefStart, 2.2)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = CrescentReliefStart
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = CrescentReliefStart

		task.delay(0.217, function()
			for i, v in ipairs(CrescentReliefStart.Emit5:GetChildren()) do
				v:Emit(5)
			end
		end)
		task.delay(0.65, function()
			for i, v in ipairs(CrescentReliefStart.Emit3:GetChildren()) do
				v:Emit(3)
			end
			for i, v in ipairs(CrescentReliefStart.Emit20:GetChildren()) do
				v:Emit(20)
			end
		end)
		
		local CrescentReliefStartSound = KendoSounds.CrescentReliefStartup:Clone()
		CrescentReliefStartSound.PlayOnRemove = true
		CrescentReliefStartSound.Parent = Character.HumanoidRootPart
		CrescentReliefStartSound:Destroy()
		CrescentReliefStartSound = nil
	elseif Phase == "2" then
		local CrescentReliefSound = KendoSounds.CrescentRelief:Clone()
		CrescentReliefSound.PlayOnRemove = true
		CrescentReliefSound.Parent = Character.HumanoidRootPart
		CrescentReliefSound:Destroy()
		CrescentReliefSound = nil

		local function RandomAngle(StartingCFrame)
			local Min, Max = 0, math.pi * 2
			local RNG = Random.new()
			return StartingCFrame * CFrame.Angles(RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max))
		end

		local CrescentRelief = KendoEffects.CrescentRelief:Clone()
		CrescentRelief:PivotTo(SpawnCFrame)
		for i, v in ipairs(CrescentRelief:GetChildren()) do
			v.Transparency = 1
			if Character:GetAttribute("VisoredActive") then
				v.Color = Color3.fromRGB(255, 0, 0)
			end	
		end
		CrescentRelief.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CrescentRelief, 13 * Speed + 1)

		local CrescentAmount = #CrescentRelief:GetChildren() - 1

		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		local Info2 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		for i = 1, CrescentAmount do
			local Crescent = CrescentRelief["Union" .. i]
			Crescent.CFrame = RandomAngle(Crescent.CFrame)
			TweenService:Create(Crescent, Info, {Transparency = 0}):Play()
			TweenService:Create(Crescent, Info2, {CFrame = Crescent.CFrame * CFrame.Angles(math.pi, 0, 0)}):Play()
			task.delay(0.2, function()
				TweenService:Create(Crescent, Info2, {CFrame = Crescent.CFrame * CFrame.Angles(math.pi, 0, 0)}):Play()

				task.wait(0.2)

				TweenService:Create(Crescent, TweenInfo.new(0.3), {Transparency = 1}):Play()
				TweenService:Create(Crescent, Info2, {CFrame = Crescent.CFrame * CFrame.Angles(math.pi, 0, 0)}):Play()
			end)

			task.wait(Speed / CrescentAmount)
		end
	end
end

function ClientSkills.SonataFlow(Character, Phase, RootCFrame)
	if Phase == "1" then
		local SonataFX = KendoEffects.SonataFX.Emit1:Clone()
		SonataFX.Parent = Character.HumanoidRootPart
		Debris:AddItem(SonataFX, 0.4)

		for i, v in ipairs(SonataFX:GetChildren()) do
			v:Emit(1)
		end
		
		local KendoUnsheathe = KendoSounds.KendoUnsheathe:Clone()
		KendoUnsheathe.PlayOnRemove = true
		KendoUnsheathe.Parent = Character.HumanoidRootPart
		KendoUnsheathe:Destroy()
		KendoUnsheathe = nil
	elseif Phase == "2" then
		local SonataFX = KendoEffects.SonataFX:Clone()
		SonataFX.Anchored = true
		SonataFX.CFrame = Character.HumanoidRootPart.CFrame
		SonataFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SonataFX, 0.5)
		
		for i, v in ipairs(SonataFX.Emit1a:GetChildren()) do
			v:Emit(1)
		end
	elseif Phase == "3" then
		local function RandomOrder(Amount, MaxAmount)
			local Array = {}
			local Order = {}
			for i = 1, MaxAmount do
				table.insert(Array, i)
			end
			for i = 1, Amount do
				local Number = Array[math.random(1, #Array)]
				table.remove(Array, table.find(Array, Number))
				table.insert(Order, Number)
			end
			return Order
		end

		local SlashOrder = RandomOrder(8, 13)
		
		local SonataSlash = KendoEffects.SonataSlash:Clone()
		SonataSlash.Anchored = true
		SonataSlash.CFrame = RootCFrame
		SonataSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SonataSlash, 1)
		
		local SonataFlowStrike = KendoSounds.SonataFlow:Clone()
		SonataFlowStrike.PlayOnRemove = true
		SonataFlowStrike.Parent = Character.HumanoidRootPart
		SonataFlowStrike:Destroy()
		SonataFlowStrike = nil
		
		for i, v in ipairs(SlashOrder) do
			SonataSlash["Slash" .. v].Main:Emit(15)
			task.wait(0.012)
		end
	elseif Phase == "4" then
		local KendoSheathe = KendoSounds.KendoSheathe:Clone()
		KendoSheathe.PlayOnRemove = true
		KendoSheathe.Parent = Character.HumanoidRootPart
		KendoSheathe:Destroy()
		KendoSheathe = nil
	end
end

function ClientSkills.Eviscerate(Character, Phase, Duration, Target)
	if Phase == "1" then
		local EviscerateStart = KendoSounds.EviscerateStart:Clone()
		EviscerateStart.PlayOnRemove = true
		EviscerateStart.Parent = Character.HumanoidRootPart
		EviscerateStart:Destroy()
		EviscerateStart = nil
		
		local EviscerateStartup = KendoEffects.EviscerateStartup:Clone()
		EviscerateStartup.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(EviscerateStartup, 0.7)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = EviscerateStartup
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = EviscerateStartup
		
		for i, v in ipairs(EviscerateStartup.Emit1:GetChildren()) do
			v:Emit(1)
		end
		for i, v in ipairs(EviscerateStartup.Emit15:GetChildren()) do
			v:Emit(15)
		end
		for i, v in ipairs(EviscerateStartup.Emit5:GetChildren()) do
			v:Emit(5)
		end
	elseif Phase == "2" then
		
	elseif Phase == "3" then
		local EviscerateTrail = KendoEffects.EviscerateTrail:Clone()
		EviscerateTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(EviscerateTrail, Duration + 0.4)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = EviscerateTrail
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = EviscerateTrail
		
		FlashstepClient.Invisible(Character, 0.15)
	elseif Phase == "4" then
		local RandomNumber = math.random(1, 8)
		local Eviscerate = KendoEffects.Eviscerate["Emit15" .. RandomNumber]:Clone()
		Eviscerate.Parent = Target.HumanoidRootPart
		Debris:AddItem(Eviscerate, 0.4)
		
		for i, v in ipairs(Eviscerate:GetChildren()) do
			v:Emit(15)
		end
		
		local EviscerateSound = KendoSounds.Eviscerate:Clone()
		EviscerateSound.Parent = Character.HumanoidRootPart
		EviscerateSound:Play()
		Debris:AddItem(EviscerateSound, 1.5)
		task.delay(1, function()
			TweenService:Create(EviscerateSound, TweenInfo.new(0.5), {Volume = 0}):Play()
		end)
	elseif Phase == "5" then
		FlashstepClient.Visible(Character, 0.1)
		
		local EviscerateTrail = workspace.Effects[Character.Name]:FindFirstChild("EviscerateTrail")
		if EviscerateTrail then
			EviscerateTrail.A1.EviscerateTrail.Enabled = false
		end
	end
end

function ClientSkills.DelayedCrossings(Character, Phase)
	if Phase == "0" then
		local DelayedCrossingSound = KendoSounds.DelayedCrossingStartup:Clone()
		DelayedCrossingSound.PlayOnRemove = true
		DelayedCrossingSound.Parent = Character.HumanoidRootPart
		DelayedCrossingSound:Destroy()
		DelayedCrossingSound = nil
	elseif Phase == "1" then
		local DelayedCrossingSound = KendoSounds.DelayedCrossingLeap:Clone()
		DelayedCrossingSound.PlayOnRemove = true
		DelayedCrossingSound.Parent = Character.HumanoidRootPart
		DelayedCrossingSound:Destroy()
		DelayedCrossingSound = nil
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.000106811523, -0.000474452972, 0.000350952148, -0.358368278, 0.379721612, 0.852867782, -6.81520646e-07, -0.91354537, 0.406736702, 0.933580279, 0.145760968, 0.327385992)
		
		local EffectInfo = {
			SlashX = {
				SizeTween = {
					Size = Vector3.new(26.1, 0.607, 26.1);
					Info = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false);	
				};
				SizeFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(34.1, 0.607, 34.1);
					TimeDelay = 0.27;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0.5;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.3;
				};
			};
			SlashY = {
				SizeTween = {
					Size = Vector3.new(26.1, 1.942, 26.1);
					Info = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)	
				};
				SizeFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(34.1, 1.942, 34.1);
					TimeDelay = 0.47;
				};

				TransparencyTween = {
					Info = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Transparency = 0.5;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 0.5;
				};
			};
		}		
		
		local DelayedCrossing = KendoEffects.DelayedCrossings:Clone()
		DelayedCrossing:PivotTo(Character.HumanoidRootPart.CFrame * Offset)
		for i, v in ipairs(DelayedCrossing:GetChildren()) do
			if Character:GetAttribute("VisoredActive") and v:IsA("BasePart") then
				v.Color = Color3.fromRGB(255, 0, 0)
			end
			if Character:GetAttribute("LetztStilActive") and v:IsA("BasePart") then
				v.Color = Color3.fromRGB(234, 226, 132)
			end

			local Info = EffectInfo[v.Name]
			if Info then
				if Info.SizeTween then
					v.Size = Vector3.zero
				end
				if Info.TransparencyTween then
					v.Transparency = 1
				end
			end
		end
		DelayedCrossing.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DelayedCrossing, 1)

		for i, v in ipairs(DelayedCrossing:GetChildren()) do
			local Info = EffectInfo[v.Name]
			if Info then
				if Info.SizeTween then
					TweenService:Create(v, Info.SizeTween.Info, {Size = Info.SizeTween.Size}):Play()
				end
				if Info.TransparencyTween then
					TweenService:Create(v, Info.TransparencyTween.Info, {Transparency = Info.TransparencyTween.Transparency}):Play()
				end
				if Info.SizeFade then
					task.delay(Info.SizeFade.TimeDelay, function()
						TweenService:Create(v, Info.SizeFade.Info, {Size = Info.SizeFade.Size}):Play()
					end)
				end
				if Info.TransparencyFade then
					task.delay(Info.TransparencyFade.TimeDelay, function()
						TweenService:Create(v, Info.TransparencyFade.Info, {Transparency = 1}):Play()
					end)
				end
			end
		end
		
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime

			if Accumulated > 1 or not DelayedCrossing.Parent then
				Connection:Disconnect()
				Connection = nil
				return
			end
			
			for i, v in ipairs(DelayedCrossing:GetChildren()) do
				v.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.5, 0)
			end
		end)
		
		local SmokeOffset = CFrame.new(0.0793914795, -2.97981358, -0.0647125244, 1, -2.84984537e-07, -3.57627584e-07, 2.84984367e-07, 1, -4.60999189e-07, 3.57627727e-07, 4.61008028e-07, 1)
		
		local DelayedSmoke = KendoEffects.DelayedSmoke:Clone()
		DelayedSmoke.CFrame = CFrame.new(Character.HumanoidRootPart.Position) * SmokeOffset * CFrame.Angles(0, math.pi/2, 0)
		DelayedSmoke.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DelayedSmoke, 1)
		
		for i, v in ipairs(DelayedSmoke:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local Offset2 = CFrame.new(-0.179244995, 0.619720936, 1.13363647, -0.29237178, 0.956304789, 3.57627584e-07, 0.956304789, 0.29237178, 4.60999189e-07, 3.36304026e-07, 4.76786738e-07, -1)
		
		local DelayedSlash = KendoEffects.DelayedSlash:Clone()
		DelayedSlash.CFrame = Character.HumanoidRootPart.CFrame * Offset2
		DelayedSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DelayedSlash, 0.4)
		
		for i, v in ipairs(DelayedSlash:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local DelayedCrossingSound = KendoSounds.DelayedCrossing:Clone()
		DelayedCrossingSound.PlayOnRemove = true
		DelayedCrossingSound.Parent = Character.HumanoidRootPart
		DelayedCrossingSound:Destroy()
		DelayedCrossingSound = nil
		
		local DebrisData = {
			Amount = math.random(5, 7),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 2,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Character.HumanoidRootPart.CFrame, DebrisData)
	end
end

function ClientSkills.MortalTies(Character, Phase, Duration, Target, Link)
	if Phase == "1" then
		local MortalTiesAudio = KendoSounds.MortalTiesStart:Clone()
		MortalTiesAudio.PlayOnRemove = true
		MortalTiesAudio.Parent = Character.PrimaryPart
		MortalTiesAudio:Destroy()
		MortalTiesAudio = nil
	elseif Phase == "2" then
		local EffectInfo = {
			Vertical = {
				Offset = CFrame.new(-0.179901123, 0.116163015, -0.277145386, -0.756375313, -0.53229481, -0.380208492, -0.504332066, 0.104374148, 0.857178688, -0.416587859, 0.840100169, -0.347399473);
				SizeTween = {
					Size = Vector3.new(17.26, 0.509, 0.301);
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);	
				};
				SizeFade = {
					Info = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(24.26, 1, 0.801);
					TimeDelay = 0.17;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 1; 
				};
				SizeFade2 = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(24.26, 0, 0);
					TimeDelay = 1;
				};
			};
			Horizontal = {
				Offset = CFrame.new(-0.179901123, 0.116163015, -0.277145386, 0.53229481, 0.756375313, 0.380208492, -0.104374148, 0.504332066, -0.857178688, -0.840100169, 0.416587859, 0.347399473);
				SizeTween = {
					Size = Vector3.new(17.26, 0.509, 0.301);
					Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);	
				};
				SizeFade = {
					Info = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(24.26, 1, 0.801);
					TimeDelay = 0.17;
				};
				TransparencyFade = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					TimeDelay = 1;
				};
				SizeFade2 = {
					Info = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false);
					Size = Vector3.new(24.26, 0, 0);
					TimeDelay = 1;
				};
			};
		}
		
		local MortalTiesSlash = KendoEffects.MortalTies:Clone()
		for i, v in ipairs(MortalTiesSlash:GetChildren()) do
			if v:IsA("BasePart") and Character:GetAttribute("VisoredActive") then
				v.Color = Color3.fromRGB(255, 0, 0)
			end

			local Info = EffectInfo[v.Name]
			if Info then
				v.CFrame = Target.HumanoidRootPart.CFrame * Info.Offset
				
				if Info.SizeTween then
					v.Size = Vector3.zero
				end
			end
		end
		MortalTiesSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(MortalTiesSlash, 1.4)
		
		for i, v in ipairs(MortalTiesSlash:GetChildren()) do
			local Info = EffectInfo[v.Name]
			if Info then
				if Info.SizeTween then
					TweenService:Create(v, Info.SizeTween.Info, {Size = Info.SizeTween.Size}):Play()
				end
				if Info.SizeFade then
					task.delay(Info.SizeFade.TimeDelay, function()
						TweenService:Create(v, Info.SizeFade.Info, {Size = Info.SizeFade.Size}):Play()
					end)
				end
				if Info.SizeFade2 then
					task.delay(Info.SizeFade2.TimeDelay, function()
						TweenService:Create(v, Info.SizeFade2.Info, {Size = Info.SizeFade2.Size}):Play()
					end)
				end
				if Info.TransparencyFade then
					task.delay(Info.TransparencyFade.TimeDelay, function()
						TweenService:Create(v, Info.TransparencyFade.Info, {Transparency = 1}):Play()
					end)
				end
			end
		end
		
		local Offset = CFrame.new(1.7538147, 1.50000906, -2.69396973, 0.661465228, -0.749794722, 0.0164786298, -0.736964345, -0.653907657, -0.171137482, 0.139093474, 0.101057351, -0.985109329)
		local MortalTiesSlash = KendoEffects.MortalTiesSlash:Clone()
		MortalTiesSlash.CFrame = Character.HumanoidRootPart.CFrame * Offset
		MortalTiesSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(MortalTiesSlash, 0.35)
		
		for i, v in ipairs(MortalTiesSlash:GetChildren()) do
			v:Emit(tonumber(v.Name))
		end
		
		local MortalTiesAudio = KendoSounds.MortalTies:Clone()
		MortalTiesAudio.PlayOnRemove = true
		MortalTiesAudio.Parent = Character.PrimaryPart
		MortalTiesAudio:Destroy()
		MortalTiesAudio = nil
		
		local MortalTiesLinkAudio = KendoSounds.MortalTiesLink:Clone()
		MortalTiesLinkAudio.PlayOnRemove = true
		MortalTiesLinkAudio.Parent = Link
		MortalTiesLinkAudio:Destroy()
		MortalTiesLinkAudio = nil
	end
end

--==================================================
--======================Kido========================
--==================================================

function ClientSkills.Hainawa(Character, Phase, ClosestPlayerFromMouse, StunTime)
	if Phase == "1" then
		local HainawaSound = KidoSounds.Hainawa:Clone()
		HainawaSound.Parent = Character.PrimaryPart
		HainawaSound:Play()
		Debris:AddItem(HainawaSound, HainawaSound.TimeLength)
	elseif Phase == "2" then
		local HainawaChain = KidoEffects.HainawaChain:Clone()
		HainawaChain.Anchored = false
		HainawaChain.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HainawaChain, StunTime)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = HainawaChain
		Weld.Part1 = ClosestPlayerFromMouse.HumanoidRootPart
		Weld.Parent = HainawaChain
		
		for i, v in ipairs(ClosestPlayerFromMouse:GetChildren()) do
			if v:IsA("BasePart") then
				local LightningSparks = HainawaChain.LightningSparks:Clone()
				LightningSparks.Enabled = true
				LightningSparks.Parent = v
				
				task.delay(StunTime, function()
					if LightningSparks then
						LightningSparks.Enabled = false
						Debris:AddItem(LightningSparks, 0.5)
					end
				end)
			end
		end
	end
end

function ClientSkills.Seki(Character, Counter, CounterOwner, CounterDuration)
	if Counter == "Counter" then
		local SekiShield = KidoEffects.SekiShield:Clone()
		SekiShield.PrimaryPart.Anchored = false
		SekiShield.Parent = workspace.Effects[CounterOwner.Name]
		SekiShield.PrimaryPart.Transparency = 1
		SekiShield["Mesh Parts"].Transparency = 1
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.188226223, 2.28604889, -0.0900115967, 3.64153254e-14, -1.00000036, 1.54972111e-06, 2.9802333e-08, 8.34465254e-07, 1.00000036, -1.00000072, 1.77635515e-15, -5.96046661e-08)
		Weld.Part0 = SekiShield.PrimaryPart
		Weld.Part1 = CounterOwner.HumanoidRootPart
		Weld.Parent = SekiShield.PrimaryPart
		
		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		
		TweenService:Create(SekiShield.PrimaryPart, Info, {Transparency = 0.3}):Play()
		TweenService:Create(SekiShield["Mesh Parts"], Info, {Transparency = 0.9}):Play()
		task.delay(CounterDuration, function()
			TweenService:Create(SekiShield.PrimaryPart, Info, {Transparency = 1}):Play()
			TweenService:Create(SekiShield["Mesh Parts"], Info, {Transparency = 1}):Play()
			Debris:AddItem(SekiShield, 0.2)
		end)
		
		local SekiSound = KidoSounds.Seki:Clone()
		SekiSound.PlayOnRemove = true
		SekiSound.Parent = Character.PrimaryPart
		SekiSound:Destroy()
		SekiSound = nil
	elseif Counter == "Countered" then
		
	end
end

function ClientSkills.Geki(Character, Phase, ClosestPlayerFromMouse, Startup, StunTime)
	if Phase == "1" then
		-- cast effect
	elseif Phase == "2" then
		local GekiHighlight = Instance.new("Highlight")
		GekiHighlight.Name = "GekiHighlight"
		GekiHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		GekiHighlight.FillTransparency = 1
		GekiHighlight.FillColor = Color3.fromRGB(255, 0, 0)
		GekiHighlight.OutlineTransparency = 1
		GekiHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		GekiHighlight.Parent = ClosestPlayerFromMouse
		Debris:AddItem(GekiHighlight, Startup + StunTime)
		
		local Info = TweenInfo.new(Startup - 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(GekiHighlight, Info, {FillTransparency = 0.3}):Play()

		--[[local GekiIndicator = KidoEffects.GekiIndicator:Clone()
		GekiIndicator.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GekiIndicator, Startup + StunTime)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = GekiIndicator
		Weld.Part1 = ClosestPlayerFromMouse.Torso
		Weld.Parent = GekiIndicator]]
		
		local GekiSound = KidoSounds.Geki:Clone()
		GekiSound.PlayOnRemove = true
		GekiSound.Parent = ClosestPlayerFromMouse.PrimaryPart
		GekiSound:Destroy()
		GekiSound = nil
	elseif Phase == "3" then
		ClosestPlayerFromMouse.GekiHighlight.FillTransparency = 1
		ClosestPlayerFromMouse.GekiHighlight.OutlineTransparency = 0
		Debris:AddItem(ClosestPlayerFromMouse.GekiHighlight, StunTime)
	elseif Phase == "Blocked" then
		--[[local GekiIndicator = workspace.Effects[Character.Name]:FindFirstChild("GekiIndicator")
		if GekiIndicator then
			Debris:AddItem(GekiIndicator, 0.5)
			for i, v in ipairs(GekiIndicator:GetDescendants()) do
				if v:IsA("Beam") or v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end]]
		ClosestPlayerFromMouse.GekiHighlight:Destroy()
	end
end

function ClientSkills.Byakurai(Character, RootCFrame)
	local RootRX, RootRY, RootRZ = RootCFrame:ToOrientation()
	local Byakurai = KidoEffects.Byakurai:Clone()
	Byakurai.PrimaryPart.CFrame = RootCFrame * CFrame.new(0, 0.5, -2.5)
	Byakurai.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Byakurai, 0.5)
	
	if Character:GetAttribute("VisoredActive") then
		Byakurai.Beam.Color = Color3.fromRGB(13, 13, 13)
		Byakurai.cero.Color = Color3.fromRGB(61, 61, 61)
	end	
	
	local ByakuraiSound = KidoSounds.Byakurai:Clone()
	ByakuraiSound.PlayOnRemove = true
	ByakuraiSound.Parent = Character.PrimaryPart
	ByakuraiSound:Destroy()
	ByakuraiSound = nil
	
	local Info = TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
	
	for i, v in ipairs(Byakurai:GetChildren()) do
		local OriginalSize = v.Size
		local OriginalPosition = v.CFrame.Position
		v.Size = Vector3.new(0, 0, 0)
		local NewSize = Vector3.new(OriginalSize.X, OriginalSize.Y, OriginalSize.Z)
		local NewPosition = (v.CFrame * CFrame.new(0, 0, -OriginalSize.Z / 2)).Position
		TweenService:Create(v, Info, {Size = NewSize, Position = NewPosition}):Play()
		task.delay(0.3, function()
			local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(v, Info, {Size = Vector3.new(0, 0, OriginalSize.Z), Transparency = 1}):Play()
		end)
	end

	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Byakurai.PrimaryPart.CFrame = Byakurai.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 0.3)
	end)
	local DestroyConnection
	DestroyConnection = Byakurai.Destroying:Connect(function()
		Connection:Disconnect()
		Connection = nil
		DestroyConnection:Disconnect()
		DestroyConnection = nil
	end)
end

function ClientSkills.Shakkaho(Character, Phase, Speed, RootCFrame, MousePosition)
	if Phase == "1" then
		local Shakkaho = KidoEffects.Shakkaho:Clone()
		Shakkaho.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Shakkaho, 0.91)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-3.42474365, -0.217346191, 0.32574892, 0, 0, -1, 1, 0, 0, 0, -1, 0)
		Weld.Part0 = Shakkaho
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = Shakkaho
		
		for i, v in ipairs(Shakkaho.StartupPt1:GetChildren()) do
			v.Enabled = true
		end
		
		task.delay(0.7, function()
			if Shakkaho.Parent then
				for i, v in ipairs(Shakkaho.StartupPt1:GetChildren()) do
					v.Enabled = false
				end
			end
		end)
		
		local ShakkahoCharge = KidoSounds.ShakkahoCharge:Clone()
		ShakkahoCharge.Parent = Character.HumanoidRootPart
		ShakkahoCharge:Play()
		Debris:AddItem(ShakkahoCharge, ShakkahoCharge.TimeLength)
	elseif Phase == "2" then
		local Shakkaho = KidoEffects.Shakkaho:Clone()
		Shakkaho.CFrame = CFrame.new(RootCFrame.Position, MousePosition)
		Shakkaho.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Shakkaho, 4)
		
		ClientProjectile:ProjectileStraight(Character, Shakkaho, Speed)
	elseif Phase == "3" then
		local Shakkaho = workspace.Effects[Character.Name]:FindFirstChild("Shakkaho")
		if Shakkaho then
			Shakkaho:Destroy()
			Shakkaho = nil
		end
		
		local ShakkahoExplosion = KidoEffects.ShakkahoExplosion:Clone()
		ShakkahoExplosion.CFrame = RootCFrame
		ShakkahoExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShakkahoExplosion, 3)
		
		for i, v in ipairs(ShakkahoExplosion.Emit100:GetChildren()) do
			v:Emit(100)
		end
		for i, v in ipairs(ShakkahoExplosion.Emit30:GetChildren()) do
			v:Emit(30)
		end
		
		local ShakkahoImpact = KidoSounds.ShakkahoImpact:Clone()
		ShakkahoImpact.PlayOnRemove = true
		ShakkahoImpact.Parent = ShakkahoExplosion
		ShakkahoImpact:Destroy()
		ShakkahoImpact = nil
	end
end

function ClientSkills.Tenran(Character, Phase, RootCFrame)
	if Phase == "1" then
		local Tenran1 = KidoEffects.Tenran.TenranSwirl:Clone()
		Tenran1.Parent = Character.HumanoidRootPart
		Tenran1.ParticleEmitter.Enabled = true
		Debris:AddItem(Tenran1, 3)
	elseif Phase == "2" then
		local Tenran = KidoEffects.Tenran:Clone()
		Tenran.CFrame = RootCFrame
		Tenran.TenranSwirl:Destroy()
		Character.HumanoidRootPart.TenranSwirl.ParticleEmitter.Enabled = false
		Tenran.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Tenran, 2.5)
		Debris:AddItem(Character.HumanoidRootPart.TenranSwirl, 2.5)
		
		for i, v in ipairs(Tenran.WindParticle:GetChildren()) do
			v.Enabled = true
			task.delay(1, function()
				v.Enabled = false
			end)
		end
		
		local TenranSound = KidoSounds.Tenran:Clone()
		TenranSound.PlayOnRemove = true
		TenranSound.Parent = Character.PrimaryPart
		TenranSound:Destroy()
		TenranSound = nil
	end
end

function ClientSkills.Raikoho(Character, Phase, RootCFrame, VisoredActive)
	if Phase == "1" then
		local RaikohoCharge = KidoEffects.RaikohoBeam.RaikohoStartup:Clone()
		RaikohoCharge.Anchored = false
		RaikohoCharge.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RaikohoCharge, 2)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(1.91175175, -0.0922646523, 0.0051651001, -0.0235654581, 0.999714434, 0.00398040749, -0.202839851, -0.00867999438, 0.979172945, 0.978928387, 0.0222672895, 0.202986553)
		Weld.Part0 = RaikohoCharge
		Weld.Part1 = Character["Right Arm"]
		Weld.Parent = RaikohoCharge
		
		if Character:GetAttribute("VisoredActive") then
			RaikohoCharge.Color = Color3.fromRGB(0, 0, 0)
			RaikohoCharge.ParticleEmitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255));
			})
		end
		
		RaikohoCharge.ParticleEmitter.Enabled = true
		
		local Info = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, -1, true)
		
		TweenService:Create(RaikohoCharge, TweenInfo.new(1), {Transparency = 0}):Play()
		TweenService:Create(RaikohoCharge, Info, {Size = Vector3.new(RaikohoCharge.Size.X + 0.5, RaikohoCharge.Size.Y + 0.5, RaikohoCharge.Size.Z + 0.5)}):Play()
		
		local RaikohoChargeSound = KidoSounds.RaikohoCharge:Clone()
		RaikohoChargeSound.Parent = Character.PrimaryPart
		RaikohoChargeSound:Play()
		Debris:AddItem(RaikohoChargeSound, 4)
		
		task.delay(0.5, function()
			RaikohoCharge.ParticleEmitter.Enabled = false
			TweenService:Create(RaikohoCharge, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end)
	elseif Phase == "2" then
		local Raikoho = KidoEffects.RaikohoBeam:Clone()
		Raikoho.RaikohoStartup:Destroy()
		Raikoho.PrimaryPart.CFrame = RootCFrame * CFrame.new(Vector3.new(0, 0, -3))
		Raikoho.Parent = workspace.Effects[Character.Name]
		
		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)
		
		if Character:GetAttribute("VisoredActive") then
			Raikoho.RaikohoBeam.Color = Color3.fromRGB(0, 0, 0)
		end
		
		for i, v in ipairs(Raikoho:GetChildren()) do
			local OriginalSize = v.Size
			if VisoredActive then
				OriginalSize = Vector3.new(OriginalSize.X + VisoredActive.Width, OriginalSize.Y + VisoredActive.Height, OriginalSize.Z + VisoredActive.Range)
			end
			local OriginalCFrame = v.CFrame
			v.Size = Vector3.new(0, 0, 0)
			TweenService:Create(v, Info, {Size = OriginalSize, Position = (OriginalCFrame * CFrame.new(0, 0, OriginalSize.Z / 2).Position)}):play()
			task.delay(0.45, function()
				local Info2 =  TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				TweenService:Create(v, Info2, {Size = Vector3.new(v.Size.X + 1, v.Size.Y + 1, v.Size.Z + 1)})
			end)
		end

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Raikoho.PrimaryPart.CFrame = Raikoho.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 0.5)
		end)
		local DestroyConnection
		DestroyConnection = Raikoho.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(0.7, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Raikoho.RaikohoBeam, Info, {Size = Vector3.new(0, 0, 32.762), Transparency = 1}):Play()
			TweenService:Create(Raikoho.RaikohoBeam2, Info, {Size = Vector3.new(0, 0, 33.234), Transparency = 1}):Play()
			Debris:AddItem(Raikoho, 0.4)
		end)
	end
end

function ClientSkills.Zangerin(Character, Phase, RootCFrame, Speed)
	if Phase == "1" then
		local Color = Color3.fromRGB(188, 188, 125)
		if Character:GetAttribute("VisoredActive") then
			Color = Color3.fromRGB(21, 21, 21)
		end	
		
		local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
		if Weapon then
			for i, v in ipairs(Weapon:GetDescendants()) do
				if v:IsA("BasePart") then
					local PreviousColor = v.Color
					local PreviousMaterial = v.Material
					v.Material = Enum.Material.Neon
					TweenService:Create(v, TweenInfo.new(0.3), {Color = Color}):Play()
					
					task.delay(1.06, function()
						TweenService:Create(v, TweenInfo.new(0.3), {Color = PreviousColor}):Play()
						task.wait(0.3)
						v.Material = PreviousMaterial
					end)
				end
			end
		end
		
		local ZangerinChargeSound = KidoSounds.ZangerinCharge:Clone()
		ZangerinChargeSound.Parent = Character.PrimaryPart
		ZangerinChargeSound:Play()
		task.delay(0.5, function()
			TweenService:Create(ZangerinChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			Debris:AddItem(ZangerinChargeSound, 0.3)
		end)
	elseif Phase == "2" then
		local Zangerin = KidoEffects.Zangerin:Clone()
		Zangerin.CFrame = RootCFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(111), math.rad(-90))
		Zangerin.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Zangerin, 4)
		
		ClientProjectile:ProjectileFacing(Character, Zangerin, RootCFrame.LookVector, Speed)
		
		if Character:GetAttribute("VisoredActive") then
			Zangerin.Color = Color3.fromRGB(21, 21, 21)
		end		
		
		local ZangerinSound = KidoSounds.Zangerin:Clone()
		ZangerinSound.Parent = Character.PrimaryPart
		ZangerinSound:Play()
		task.delay(0.6, function()
			TweenService:Create(ZangerinSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			Debris:AddItem(ZangerinSound, 0.3)
		end)
	end
end

function ClientSkills.GakiRekko(Character, RootCFrame, Speed)
	local GakiRekko = KidoEffects["Gaki Rekko"]:Clone()
	GakiRekko:PivotTo(RootCFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, -math.pi / 2, 0))
	GakiRekko.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(GakiRekko, 2.5)
	
	local GakiRekkoSound = KidoSounds["Gaki Rekko"]:Clone()
	GakiRekkoSound.PlayOnRemove = true
	GakiRekkoSound.Parent = GakiRekko.Circle
	GakiRekkoSound:Destroy()
	GakiRekkoSound = nil
	
	local Info = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
	
	task.delay(0.7, function()
		for i = 1, 8 do
			
			local Projectile = GakiRekko["Projectile" .. i]

			Projectile.Anchored = false
			ClientProjectile:ProjectileFacing(Character, Projectile, RootCFrame.LookVector, Speed)
			
			local GakiRekkoFire = KidoSounds["Gaki Rekko Fire"]:Clone()
			GakiRekkoFire.PlayOnRemove = true
			GakiRekkoFire.Parent = GakiRekko.Circle
			GakiRekkoFire:Destroy()
			GakiRekkoFire = nil
			
			task.wait(0.05)
		end
		
		task.wait(0.5)
		for i = 1, 8 do
			local Beam = GakiRekko["Beam" .. i]
			TweenService:Create(Beam, Info, {Transparency = 1}):Play()
		end
		TweenService:Create(GakiRekko.Circle, Info, {Transparency = 1}):Play()
	end)
	
	
	TweenService:Create(GakiRekko.Circle, Info, {Transparency = 0.3}):Play()
	
	for i = 1, 8 do
		local Beam = GakiRekko["Beam" .. i]
		local Projectile = GakiRekko["Projectile" .. i]
		TweenService:Create(Beam, Info, {Transparency = 0}):Play()
		TweenService:Create(Projectile, Info, {Transparency = 0}):Play()
		task.wait(0.1)
	end	
end

function ClientSkills.AdvancedGakiRekko(Character, Phase, RootCFrame, Duration)
	if Phase == "1" then
		local AdvancedGakiRekko = KidoEffects.AdvancedGakiRekko:Clone()
		AdvancedGakiRekko.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AdvancedGakiRekko, 3)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-1.19713211, 3.58734131, 0.0531616211, 0, 1, 0, 0, 0, 1, 1, 0, 0)
		Weld.Part0 = AdvancedGakiRekko
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = AdvancedGakiRekko
		
		for i, v in ipairs(AdvancedGakiRekko.Startup:GetChildren()) do
			v:Emit(1)
		end		
		
		local Stunned
		local StunConnection
		StunConnection = Character:GetAttributeChangedSignal("CurrentState"):Connect(function()
			if Character:GetAttribute("CurrentState") == "TrueStunned" or Character:GetAttribute("CurrentState") == "PostureBroken" then
				AdvancedGakiRekko:Destroy()
				AdvancedGakiRekko = nil
				
				Stunned = true
				
				if StunConnection then
					StunConnection:Disconnect()
					StunConnection = nil
				end
			end
		end)
		
		task.delay(0.53, function()
			if not Stunned then
				for i, v in ipairs(AdvancedGakiRekko:GetChildren()) do
					if v:IsA("Beam") then
						v.Enabled = true
					end
				end
			end
			
			task.wait(2.26)
			if not Stunned then
				for i, v in ipairs(AdvancedGakiRekko:GetChildren()) do
					if v:IsA("Beam") then
						v.Enabled = false
					end
				end
			end
		end)
		
		local GakiRekkoSound = KidoSounds["Gaki Rekko"]:Clone()
		GakiRekkoSound.PlayOnRemove = true
		GakiRekkoSound.Parent = Character.HumanoidRootPart
		GakiRekkoSound:Destroy()
		GakiRekkoSound = nil
	elseif Phase == "2" then
		local GakiRekkoFire = KidoSounds["Gaki Rekko Fire"]:Clone()
		GakiRekkoFire.PlayOnRemove = true
		GakiRekkoFire.Parent = Character.HumanoidRootPart
		GakiRekkoFire:Destroy()
		GakiRekkoFire = nil
	end
end

function ClientSkills.Rikujokoro(Character, Phase, ClosestPlayerFromMouse, StartUp, StunTime)
	if Phase == "1" then
		local Rikujokoro = KidoEffects.Rikujokoro:Clone()
		Rikujokoro.Parent = workspace.Effects[Character.Name]
		task.delay(StartUp + StunTime, function()
			if Rikujokoro then
				for i, v in ipairs(Rikujokoro:GetChildren()) do
					if v:IsA("BasePart") then
						TweenService:Create(v, TweenInfo.new(0.4), {Transparency = 1}):Play()
					end
				end
				Debris:AddItem(Rikujokoro, 0.4)
			end
		end)
		
		--[[for i = 1, 6 do
			local Rikujokoro = Rikujokoro["Rikujokoro" .. i]
			Rikujokoro.Anchored = false
			Rikujokoro.Weld.Part1 = ClosestPlayerFromMouse.HumanoidRootPart
			Rikujokoro.PointLight.Enabled = true
			TweenService:Create(Rikujokoro, TweenInfo.new(0.3), {Transparency = 0}):Play()
			
			local RikujokoroSound = KidoSounds.Rikujokoro:Clone()
			RikujokoroSound.Parent = Rikujokoro
			RikujokoroSound:Play()
			Debris:AddItem(RikujokoroSound, RikujokoroSound.TimeLength)
			
			task.wait(StartUp / 6)
		end]]
		
		local Offsets = {
			[1] = CFrame.new(0.000247955322, 4.16176414, 0, -1, 1.73472348e-18, 8.94069785e-07, 8.94070411e-07, 8.67361738e-19, 1, -1.73472265e-18, 1, 8.67363289e-19),
			[2] = CFrame.new(-0.480285645, 4.37000275, 0, -0.707106113, 1.73472348e-18, 0.707107425, 0.707107425, 8.67361738e-19, 0.707106113, -6.13315702e-19, 1, 1.83995264e-18),
			[3] = CFrame.new(0.415723801, 4.41443825, 0, 0.707107425, 1.73472348e-18, 0.707106113, 0.707106113, 8.67361738e-19, -0.707107425, 1.83995264e-18, 1, 6.13315702e-19),
			[4] = CFrame.new(-0.000247955322, 4.2343812, 0, 1, 1.73472348e-18, -8.94069785e-07, -8.94070411e-07, 8.67361738e-19, -1, 1.73472265e-18, 1, -8.67363289e-19),
			[5] = CFrame.new(-0.419931412, 4.39702797, 0, 0.707106113, 1.73472348e-18, -0.707107425, -0.707107425, 8.67361738e-19, -0.707106113, 6.13315702e-19, 1, -1.83995264e-18),
			[6] = CFrame.new(0.462617874, 4.35207176, 0, -0.707107425, 1.73472348e-18, -0.707106113, -0.707106113, 8.67361738e-19, 0.707107425, -1.83995264e-18, 1, -6.13315702e-19),
		}
		
		local IndicatorTime = 0.1
		
		for i = 1, 6 do
			local RikujokoroPart = Rikujokoro["Rikujokoro" .. i]
			local CurrentC0 = RikujokoroPart.Weld.C0
			RikujokoroPart.Anchored = false
			RikujokoroPart.Weld.Part1 = ClosestPlayerFromMouse.HumanoidRootPart
			RikujokoroPart.Weld.C0 = Offsets[i]
			RikujokoroPart.PointLight.Enabled = true
			TweenService:Create(RikujokoroPart, TweenInfo.new(0.3), {Transparency = 0}):Play()

			task.delay(StartUp - IndicatorTime, function()
				TweenService:Create(RikujokoroPart.Weld, TweenInfo.new(0.1), {C0 = CurrentC0}):Play()
			end)
		end
		
		local RikujokoroSound = KidoSounds.Rikujokoro:Clone()
		RikujokoroSound.Parent = ClosestPlayerFromMouse.HumanoidRootPart
		RikujokoroSound:Play()
		Debris:AddItem(RikujokoroSound, RikujokoroSound.TimeLength)
		
		task.delay(StartUp - IndicatorTime, function()
			local RikujokoroSound = KidoSounds.Rikujokoro:Clone()
			RikujokoroSound.Parent = ClosestPlayerFromMouse.HumanoidRootPart
			RikujokoroSound:Play()
			Debris:AddItem(RikujokoroSound, RikujokoroSound.TimeLength)
		end)
	elseif Phase == "Parried" then
		local Rikujokoro = workspace.Effects[Character.Name].Rikujokoro
		for i, v in ipairs(Rikujokoro:GetChildren()) do
			if v:IsA("BasePart") then
				v.PointLight.Enabled = false
				TweenService:Create(v, TweenInfo.new(0.4), {Transparency = 1}):Play()
			elseif v:IsA("Sound") then
				TweenService:Create(v, TweenInfo.new(0.4), {Volume = 0}):Play()
			end
			
		end
		Debris:AddItem(Rikujokoro, 0.4)
	end
end

function ClientSkills.TsuzuriRaiden(Character, Phase, Duration, Target, AnchorCFrame)
	if Phase == "1" then
		local LightningAura = KidoEffects.LightningAura:Clone()
		LightningAura.Anchored = false
		LightningAura.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LightningAura, 20)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.00137329102, 0.463508129, 1.14440918e-05, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = LightningAura
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = LightningAura
		
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			if not Character:FindFirstChild("HumanoidRootPart") or Character:GetAttribute("CurrentState") ~= "ClickState" then
				Connection:Disconnect()
				Connection = nil
				LightningAura:Destroy()
			end
		end)
	elseif Phase == "M1" then		
		local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
		if Weapon then
			for i, v in ipairs(Weapon:GetDescendants()) do
				if v:IsA("BasePart") and v.Name == "WeaponAura" then
					for _, Particle in ipairs(KidoEffects.TsuzuriRaidenM1:GetChildren()) do
						local LightningParticle = Particle:Clone()
						LightningParticle.Parent = v

						task.delay(Duration, function()
							if LightningParticle then
								LightningParticle.Enabled = false
								Debris:AddItem(LightningParticle, 1)
							end
						end)
					end
				end
			end
		end
		
		local TsuzuriRaidenLightningSound = KidoSounds.TsuzuriRaidenLightning:Clone()
		TsuzuriRaidenLightningSound.Parent = Character.HumanoidRootPart
		TsuzuriRaidenLightningSound:Play()
		Debris:AddItem(TsuzuriRaidenLightningSound, Duration)
		
		local TsuzuriRaidenM1Sound = KidoSounds.TsuzuriRaidenM1:Clone()
		TsuzuriRaidenM1Sound.PlayOnRemove = true
		TsuzuriRaidenM1Sound.Parent = Character.HumanoidRootPart
		TsuzuriRaidenM1Sound:Destroy()
		TsuzuriRaidenM1Sound = nil
	elseif Phase == "M2" then
		local TsuzuriRaidenAnchor = KidoEffects.TsuzuriRaidenM2Anchor:Clone()
		TsuzuriRaidenAnchor.CFrame = AnchorCFrame
		TsuzuriRaidenAnchor.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(TsuzuriRaidenAnchor, Duration)
		
		for i = 1, 2 do
			local TsuzuriRaidenBeam = KidoEffects.TsuzuriRaidenM2Beam["Beam" .. i]:Clone()
			TsuzuriRaidenBeam.Attachment0 = Target.HumanoidRootPart.RootAttachment
			TsuzuriRaidenBeam.Attachment1 = TsuzuriRaidenAnchor.Anchor
			TsuzuriRaidenBeam.Parent = TsuzuriRaidenAnchor
		end
		
		local TsuzuriRaidenChainLinkSound = KidoSounds.TsuzuriRaidenChainLinked:Clone()
		TsuzuriRaidenChainLinkSound.PlayOnRemove = true
		TsuzuriRaidenChainLinkSound.Parent = TsuzuriRaidenAnchor
		TsuzuriRaidenChainLinkSound:Destroy()
		TsuzuriRaidenChainLinkSound = nil
		
		local TsuzuriRaidenLightningSound = KidoSounds.TsuzuriRaidenLightning:Clone()
		TsuzuriRaidenLightningSound.Parent = TsuzuriRaidenAnchor
		TsuzuriRaidenLightningSound:Play()
		Debris:AddItem(TsuzuriRaidenLightningSound, Duration)
		
		task.delay(Duration - 0.5, function()
			local TsuzuriRaidenReleaseSound = KidoSounds.TsuzuriRaidenRelease:Clone()
			TsuzuriRaidenReleaseSound.PlayOnRemove = true
			TsuzuriRaidenReleaseSound.Parent = TsuzuriRaidenAnchor
			TsuzuriRaidenReleaseSound:Destroy()
			TsuzuriRaidenReleaseSound = nil
		end)
	elseif Phase == "M2Release" then		
		local TsuzuriRaidenM2Sound = KidoSounds.TsuzuriRaidenM2:Clone()
		TsuzuriRaidenM2Sound.PlayOnRemove = true
		TsuzuriRaidenM2Sound.Parent = Character.HumanoidRootPart
		TsuzuriRaidenM2Sound:Destroy()
		TsuzuriRaidenM2Sound = nil
	end
end

function ClientSkills.HeavenlyCannon(Character, Phase, Speed, MousePosition, ExplosionCenter, Radius)
	if Phase == "1" then
		local HeavenlyCannonCastSound = KidoSounds.HeavenlyCannonCast:Clone()
		HeavenlyCannonCastSound.Parent = Character.HumanoidRootPart
		HeavenlyCannonCastSound:Play()
		Debris:AddItem(HeavenlyCannonCastSound, HeavenlyCannonCastSound.TimeLength)
	elseif Phase == "2" then
		local HeavenlyCannon = KidoEffects["Heavenly Cannon"]:Clone()
		HeavenlyCannon:PivotTo(Character.HumanoidRootPart.CFrame)

		local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

		for i = 1, 10 do
			local Cannon = HeavenlyCannon["HeavenlyCannon" .. i]
			Cannon.WeldConstraint:Destroy()
			Cannon.CFrame = CFrame.new(Cannon.Position, MousePosition)
			Cannon.Transparency = 1
			
			local Highlight = Instance.new("Highlight")
			Highlight.OutlineColor = Color3.fromRGB(255, 179, 214)
			Highlight.FillTransparency = 1
			Highlight.FillColor = Color3.fromRGB(0, 0, 0)
			Highlight.Parent = Cannon
			
			Highlight.OutlineTransparency = 1
			TweenService:Create(Cannon, Info, {Transparency = 0}):Play()
			TweenService:Create(Highlight, Info, {OutlineTransparency = 0}):Play()

			ClientProjectile:ProjectileStraight(Character, Cannon, Speed)
			
			local HeavenlyCannonSpawn = KidoEffects.HeavenlyCannonSpawn:Clone()
			HeavenlyCannonSpawn.CFrame = Cannon.CFrame
			HeavenlyCannonSpawn.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(HeavenlyCannonSpawn, 1)
			for _, v in ipairs(HeavenlyCannonSpawn:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(2)
				end
			end
		end

		HeavenlyCannon.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HeavenlyCannon, 5)

		local HeavenlyCannonSpawnSound = KidoSounds.HeavenlyCannonSpawn:Clone()
		HeavenlyCannonSpawnSound.PlayOnRemove = true
		HeavenlyCannonSpawnSound.Parent = Character.HumanoidRootPart
		HeavenlyCannonSpawnSound:Destroy()
		HeavenlyCannonSpawnSound = nil
	elseif Phase == "3" then
		local HeavenlyCannon = workspace.Effects[Character.Name]:FindFirstChild("Heavenly Cannon")
		if HeavenlyCannon then
			local Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			for i, v in ipairs(HeavenlyCannon:GetChildren()) do
				v.Anchored = true
				TweenService:Create(v, Info, {Transparency = 1}):Play()
			end
			Debris:AddItem(HeavenlyCannon, 0.3)
		end

		local HeavenlyExplosion = KidoEffects.HeavenlyCannonExplosion:Clone()
		HeavenlyExplosion.CFrame = ExplosionCenter
		HeavenlyExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HeavenlyExplosion, 6)
		
		for i, v in ipairs(HeavenlyExplosion.PinkImpact:GetChildren()) do
			v:Emit(50)
		end
		for i, v in ipairs(HeavenlyExplosion.Cross:GetChildren()) do
			v:Emit(8)
		end
		task.delay(5, function()
			if HeavenlyExplosion:FindFirstChild("PinkExplosion") then
				for i, v in ipairs(HeavenlyExplosion.PinkExplosion:GetChildren()) do
					v.Enabled = false
				end
			end
		end)

		local HeavenlyCannonImpactSound = KidoSounds.HeavenlyCannonImpact:Clone()
		HeavenlyCannonImpactSound.PlayOnRemove = true
		HeavenlyCannonImpactSound.Parent = HeavenlyExplosion
		HeavenlyCannonImpactSound:Destroy()
		HeavenlyCannonImpactSound = nil
	end
end

function ClientSkills.Sokatsui(Character, Phase, RootCFrame)
	if Phase == "1" then
		local SokatsuiCharge = KidoEffects.SokatsuiCharge:Clone()
		SokatsuiCharge.Anchored = false
		SokatsuiCharge.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SokatsuiCharge, 2.5)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0, 2.86102295e-06, 1.47846985, 1, 0, 0, 0, 0, -1, 0, 1, 0)
		Weld.Part0 = SokatsuiCharge
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = SokatsuiCharge
		
		local SokatsuiCastSound = KidoSounds.SokatsuiCast:Clone()
		SokatsuiCastSound.PlayOnRemove = true
		SokatsuiCastSound.Parent = Character.HumanoidRootPart
		SokatsuiCastSound:Play()
		Debris:AddItem(SokatsuiCastSound, 1.39)
		task.delay(1.19, function()
			TweenService:Create(SokatsuiCastSound, TweenInfo.new(0.2), {Volume = 0}):Play()
			for i, v in ipairs(SokatsuiCharge:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "2" then
		local SokatsuiFloor = KidoEffects.SokatsuiFloor:Clone()
		SokatsuiFloor.CFrame = RootCFrame * CFrame.new(0, -2.5, -84.0788193, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		SokatsuiFloor.Transparency = 1
		SokatsuiFloor.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SokatsuiFloor, 1)
		
		local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
		TweenService:Create(SokatsuiFloor, Info, {Transparency = 0}):Play()
		
		local SokatsuiRelease = KidoEffects.SokatsuiRelease:Clone()
		SokatsuiRelease.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(-0.5, 0.5, -7) * CFrame.Angles(0, math.pi, 0)
		SokatsuiRelease.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SokatsuiRelease, 2)
		
		for i, v in ipairs(SokatsuiRelease.Attachment:GetChildren()) do
			v:Emit(50)
		end
		
		task.delay(0.5, function()
			--[[local Sokatsui = KidoEffects.Sokatsui:Clone()
			Sokatsui.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -90)
			Sokatsui.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Sokatsui, 2)

			for i, v in ipairs(Sokatsui:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(50)
				end
			end]]
			
			local Sokatsui = KidoEffects.SokatsuiRework:Clone()
			Sokatsui.CFrame = SokatsuiFloor.CFrame
			Sokatsui.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(Sokatsui, 4)
			
			for i, v in ipairs(Sokatsui:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.Name))
				end
			end
			
			local SokatsuiSound = KidoSounds.Sokatsui:Clone()
			SokatsuiSound.PlayOnRemove = true
			SokatsuiSound.Parent = SokatsuiFloor
			SokatsuiSound:Destroy()
			SokatsuiSound = nil
		end)
	end
end

function ClientSkills.WeakerIttoKaso(Character, Phase, RootCFrame)
	if Phase == "1" then
		local IttoKasoCharge = KidoEffects.IttoKasoCharge:Clone()
		IttoKasoCharge.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -4, 0)
		IttoKasoCharge.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(IttoKasoCharge, 3)
		task.delay(2, function()
			for i, v in ipairs(IttoKasoCharge:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") then
					v.Enabled = false
				end
			end
		end)
		
		local IttoKasoCastSound = KidoSounds.IttoKasoCast:Clone()
		IttoKasoCastSound.Parent = Character.HumanoidRootPart
		IttoKasoCastSound:Play()
		Debris:AddItem(IttoKasoCastSound, IttoKasoCastSound.TimeLength)
	elseif Phase == "2" then
		local WeakerIttoKaso = KidoEffects.WeakerIttoKaso:Clone()
		local IttoKasoSize = WeakerIttoKaso.Size
		WeakerIttoKaso.CFrame = RootCFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, math.pi/2, 0)
		WeakerIttoKaso.Size = Vector3.new(WeakerIttoKaso.Size.X, 0, WeakerIttoKaso.Size.Z)
		WeakerIttoKaso.Parent = workspace.Effects[Character.Name]
		
		local Info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(WeakerIttoKaso, Info, {Size = IttoKasoSize, CFrame = WeakerIttoKaso.CFrame * CFrame.new(0, IttoKasoSize.Y/2, 0)}):Play()
		
		WeakerIttoKaso.Smoke.ParticleEmitter:Emit(80)
		for i, v in ipairs(WeakerIttoKaso.Waves:GetChildren()) do
			v:Emit(5)
		end
		for i, v in ipairs(WeakerIttoKaso.Explosion:GetChildren()) do
			v:Emit(8)
		end
		
		local IttoKasoExplosionSound = KidoSounds.IttoKasoExplosion:Clone()
		IttoKasoExplosionSound.PlayOnRemove = true
		IttoKasoExplosionSound.Parent = Character.HumanoidRootPart
		IttoKasoExplosionSound:Destroy()
		IttoKasoExplosionSound = nil
	elseif Phase == "3" then
		local WeakerIttoKaso = workspace.Effects[Character.Name]:FindFirstChild("WeakerIttoKaso")
		if WeakerIttoKaso then
			local IttoKasoSize = WeakerIttoKaso.Size
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
			local RevertSize = Vector3.new(WeakerIttoKaso.Size.X, 0, WeakerIttoKaso.Size.Z)
			
			TweenService:Create(WeakerIttoKaso, Info, {Transparency = 1, Size = RevertSize, CFrame = WeakerIttoKaso.CFrame * CFrame.new(0, -IttoKasoSize.Y/2, 0)}):Play()
			for i, v in ipairs(WeakerIttoKaso:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") then
					v.Enabled = false
				end
			end
			
			Debris:AddItem(WeakerIttoKaso, 3)
		end
	end
end

function ClientSkills.WeakerIttoKasoAudio(Character)
	
end

function ClientSkills.Fushibi(Character, Phase, RootCFrame, Radius, TimeDelay, PositiveHits, Duration)
	if Phase == "1" then
		local FushibiSound = KidoSounds.Fushibi:Clone()
		FushibiSound.PlayOnRemove = true
		FushibiSound.Parent = Character.HumanoidRootPart
		FushibiSound:Destroy()
		FushibiSound = nil
		
		local FushibiWeb = KidoEffects.FushibiWeb:Clone()
		FushibiWeb.Size = Vector3.zero
		if Character:GetAttribute("VisoredActive") then
			FushibiWeb.Color = Color3.fromRGB(0, 0, 0)
		end
		FushibiWeb.CFrame = RootCFrame * CFrame.new(0, -2.9, 0) * CFrame.Angles(math.pi/2, 0, 0)
		FushibiWeb.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FushibiWeb, TimeDelay)

		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(FushibiWeb, Info, {Size = Vector3.new(Radius * 2, Radius * 2, 0.2)}):Play()

		task.delay(TimeDelay - 0.2, function()
			TweenService:Create(FushibiWeb, Info, {Size = Vector3.zero, Transparency = 1}):Play()
		end)
	elseif Phase == "2" then
		local FushibiExplosionFX = KidoEffects.FushibiExplosionFX:Clone()
		FushibiExplosionFX.CFrame = RootCFrame
		FushibiExplosionFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FushibiExplosionFX, 3.8)
		
		for i, v in ipairs(FushibiExplosionFX.Emit15:GetChildren()) do
			v:Emit(15)
		end
		
		local FushibiNetExplode = KidoSounds.FushibiNetExplode:Clone()
		FushibiNetExplode.PlayOnRemove = true
		FushibiNetExplode.Parent = FushibiExplosionFX
		FushibiNetExplode:Destroy()
		FushibiNetExplode = nil
		
		if PositiveHits and #PositiveHits > 0 then
			for i, v in ipairs(PositiveHits) do
				local FushibiDebuff = KidoEffects.FushibiDebuff:Clone()
				FushibiDebuff.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(FushibiDebuff, Duration)
				
				local Weld = Instance.new("Weld")
				Weld.C0 = CFrame.new(0.00048828125, -0.000483036041, 0.00048828125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				Weld.Part0 = FushibiDebuff
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = FushibiDebuff
				
				task.delay(Duration - 0.5, function()
					for i, v in ipairs(FushibiDebuff:GetDescendants()) do
						if v:IsA("Beam") then
							v.Enabled = false
						end
					end
				end)
			end
		end
	end
end

function ClientSkills.Danku(Character, Duration)
	local Offset = CFrame.new(0.202590942, -2.9554038, -6.37969971, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	
	local Danku = KidoEffects.Danku:Clone()
	Danku:PivotTo(Character.HumanoidRootPart.CFrame * Offset)
	Danku.Floor.Transparency = 1
	for i = 1, 2 do
		Danku.DankuBeam["A" .. i].Beam.Width0 = 0
		Danku.DankuBeam["A" .. i].Beam.Width1 = 0
	end
	
	Danku.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Danku, Duration + 0.4)
	
	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(Danku.Floor, Info, {Transparency = 0.25}):Play()
	TweenService:Create(Danku.DankuBeam.A1.Beam, Info, {Width0 = 50, Width1 = 50}):Play()
	TweenService:Create(Danku.DankuBeam.A2.Beam, Info, {Width0 = 50, Width1 = 50}):Play()
	
	local DankuSound = KidoSounds.Danku:Clone()
	DankuSound.PlayOnRemove = true
	DankuSound.Parent = Danku.PrimaryPart
	DankuSound:Destroy()
	DankuSound = nil
	
	task.delay(Duration, function()
		TweenService:Create(Danku.Floor, Info, {Transparency = 1}):Play()
		TweenService:Create(Danku.DankuBeam.A1.Beam, Info, {Width0 = 0, Width1 = 0}):Play()
		TweenService:Create(Danku.DankuBeam.A2.Beam, Info, {Width0 = 0, Width1 = 0}):Play()
		
		local DankuDisperseSound = KidoSounds.DankuDisperse:Clone()
		DankuDisperseSound.PlayOnRemove = true
		DankuDisperseSound.Parent = Danku.PrimaryPart
		DankuDisperseSound:Destroy()
		DankuDisperseSound = nil
	end)
end

function ClientSkills.Haien(Character, Phase, Speed, SpawnPoint, MousePosition, Duration)
	if Phase == "1" then
		local Haien = KidoEffects.HaienFireball:Clone()
		Haien.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Haien, 0.45)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.000274658203, 1.38585293, 0.000244140625, -1, 0, 8.74227766e-08, 0, 0.99999994, 0, -8.74227766e-08, 0, -1)
		Weld.Part0 = Haien
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = Haien
		
		local HaienSound = KidoSounds.HaienCharge:Clone()
		HaienSound.PlayOnRemove = true
		HaienSound.Parent = Character.HumanoidRootPart
		HaienSound:Destroy()
		HaienSound = nil
	elseif Phase == "2" then
		local Haien = KidoEffects.HaienFireball:Clone()
		Haien.CFrame = CFrame.new(SpawnPoint.Position, MousePosition)
		Haien.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Haien, 4)

		ClientProjectile:ProjectileStraight(Character, Haien, Speed)
		
		local HaienSound = KidoSounds.HaienRelease:Clone()
		HaienSound.PlayOnRemove = true
		HaienSound.Parent = Character.HumanoidRootPart
		HaienSound:Destroy()
		HaienSound = nil
	elseif Phase == "3" then
		local Haien = workspace.Effects[Character.Name]:FindFirstChild("HaienFireball")
		if Haien then
			Haien:Destroy()
			Haien = nil
		end
		
		local HaienTornado = KidoEffects.HaienFlameTornado:Clone()
		HaienTornado.CFrame = CFrame.new(SpawnPoint.Position) * CFrame.Angles(0, 0, -math.pi/2)
		HaienTornado.Anchored = true
		HaienTornado.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HaienTornado, Duration + 1.5)
		
		local HaienSound = KidoSounds.HaienTornadoForm:Clone()
		HaienSound.PlayOnRemove = true
		HaienSound.Parent = HaienTornado
		HaienSound:Destroy()
		HaienSound = nil
		
		local HaienLingerSound = KidoSounds.HaienTornadoForm:Clone()
		HaienLingerSound.Parent = HaienTornado
		HaienLingerSound:Play()
		Debris:AddItem(HaienLingerSound, Duration + 0.5)
		
		task.delay(Duration, function()
			for i, v in ipairs(HaienTornado:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			
			TweenService:Create(HaienLingerSound, TweenInfo.new(0.5), {Volume = 0}):Play()
		end)
	end
end

function ClientSkills.ShintenRaiho(Character, Phase, RootCFrame)
	if Phase == "1" then
		local ShintenRaihoChargeSound = KidoSounds.ShintenRaihoCharge:Clone()
		ShintenRaihoChargeSound.Parent = Character.HumanoidRootPart
		ShintenRaihoChargeSound:Play()
		Debris:AddItem(ShintenRaihoChargeSound, 1.5)
		
		task.delay(1, function()
			TweenService:Create(ShintenRaihoChargeSound, TweenInfo.new(0.5), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local BeamSize = Vector3.new(20.705, 19.524, 93.826)
		local CeroSize = Vector3.new(16.92, 16.865, 92.321)
		
		local ShintenRaiho = KidoEffects.ShintenRaiho:Clone()
		ShintenRaiho.ShintenRaihoRelease.CFrame = RootCFrame * CFrame.new(-1.79597473, 0.227583885, -50.8240356, 0.999997377, 0, 0, 0, 1, 0, 0, 0, 1)
		ShintenRaiho.PrimaryPart.CFrame = RootCFrame * CFrame.new(0, 0.8, -2.5) * CFrame.new(Vector3.new(0, 0, (-BeamSize.Z / 2) - 1))
		ShintenRaiho.Parent = workspace.Effects[Character.Name]
		
		for i, v in ipairs(ShintenRaiho:GetChildren()) do
			if v.Name ~= "ShintenRaihoRelease" then
				v.Size = Vector3.new(0, 0, 0)
			end
		end

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(ShintenRaiho.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(ShintenRaiho.cero, Info, {Size = CeroSize}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(ShintenRaiho.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(ShintenRaiho.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			ShintenRaiho.PrimaryPart.CFrame = ShintenRaiho.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = ShintenRaiho.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)
		
		local ShintenRaihoSound = KidoSounds.ShintenRaiho:Clone()
		ShintenRaihoSound.PlayOnRemove = true
		ShintenRaihoSound.Parent = Character.HumanoidRootPart
		ShintenRaihoSound:Destroy()
		ShintenRaihoSound = nil
		
		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(ShintenRaiho.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(ShintenRaiho.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			
			for i, v in ipairs(ShintenRaiho:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") then
					v.Enabled = false
				end
			end
			
			task.wait(0.4)
			
			ShintenRaiho:Destroy()
		end)
	end
end

function ClientSkills.Goryutenmetsu(Character, Phase, Position, Radius, PositiveHits, Duration)
	if Phase == "1" then
		local GoryuCharge = KidoEffects.GoryuCharge.GoryuCharge:Clone()
		GoryuCharge.Parent = Character.HumanoidRootPart
		Debris:AddItem(GoryuCharge, 3)
		
		task.delay(2, function()
			if GoryuCharge.Parent then
				for i, v in ipairs(GoryuCharge:GetChildren()) do
					v.Enabled = false
				end
			end
		end)
		
		local GoryuSound = KidoSounds.GoryutenmetsuCharge:Clone()
		GoryuSound.PlayOnRemove = true
		GoryuSound.Parent = Character.HumanoidRootPart
		GoryuSound:Destroy()
		GoryuSound = nil
		
		local GoryuRoar = KidoSounds.GoryutenmetsuRoar:Clone()
		GoryuRoar.PlayOnRemove = true
		GoryuRoar.Parent = Character.HumanoidRootPart
		GoryuRoar:Destroy()
		GoryuRoar = nil
	elseif Phase == "2" then
		local GoryuRelease = KidoEffects.GoryuCharge.GoryuRelease:Clone()
		GoryuRelease.Parent = Character.HumanoidRootPart
		Debris:AddItem(GoryuRelease, 0.45)
		
		for i, v in ipairs(GoryuRelease:GetChildren()) do
			v:Emit(15)
		end
		
		local GoryuSound = KidoSounds.GoryutenmetsuRelease:Clone()
		GoryuSound.PlayOnRemove = true
		GoryuSound.Parent = Character.HumanoidRootPart
		GoryuSound:Destroy()
		GoryuSound = nil
	elseif Phase == "3" then
		local GoryuExplosion = KidoEffects.GoryutenmetsuExplosion:Clone()
		GoryuExplosion.CFrame = CFrame.new(Position)
		GoryuExplosion.Anchored = true
		GoryuExplosion.Size = Vector3.zero
		GoryuExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GoryuExplosion, 0.3)
		
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(GoryuExplosion, Info, {Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2), Transparency = 1}):Play()
		
		local DebrisData = {
			Amount = math.random(5, 10),
			Collidable = true,
			VelocityMin = 40,
			VelocityMax = 60,
			PartSize = 3,
			PartMin = -1.5,
			PartMax = 1.5,
			Duration = 5,
			RandomMin = -Radius,
			RandomMax = Radius,
		}

		ImpactCrater:RandomDebris(Character, CFrame.new(Position), DebrisData)
		
		local GoryuImpact = KidoSounds.GoryutenmetsuImpact:Clone()
		GoryuImpact.PlayOnRemove = true
		GoryuImpact.Parent = GoryuExplosion
		GoryuImpact:Destroy()
		GoryuImpact = nil
	elseif Phase == "4" then
		if PositiveHits and #PositiveHits > 0 then
			for i, v in ipairs(PositiveHits) do
				local ReiatsuSealed = KidoEffects.ReiatsuSealed:Clone()
				ReiatsuSealed.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(ReiatsuSealed, Duration + 3)
				
				local Weld = Instance.new("Weld")
				Weld.C0 = CFrame.new(0, -3.3135407, 0, 1, -1.50995788e-07, -1.52858448e-07, -1.50995803e-07, -0.999999881, 2.30809854e-14, -1.52858448e-07, 0, -1)
				Weld.Part0 = ReiatsuSealed
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = ReiatsuSealed
				
				task.delay(Duration, function()
					for i, v in ipairs(ReiatsuSealed:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
				end)
			end
		end
	end
end

function ClientSkills.KuyoShibari(Character, Target, Duration, PositiveHits)
	if PositiveHits and #PositiveHits > 0 then
		local KuyoShibari = KidoEffects.KuyoShibariStunned:Clone()
		KuyoShibari.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(KuyoShibari, Duration + 1)

		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0, -0.000241994858, 0, 1, 0, -1.86264515e-09, 0, 0.999999881, 0, 1.86264515e-09, 0, 1)
		Weld.Part0 = KuyoShibari.PrimaryPart
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = KuyoShibari.PrimaryPart

		task.delay(Duration, function()
			for i, v in ipairs(KuyoShibari:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	end
	
	local KuyoShibariSound = KidoSounds.KuyoShibariStun:Clone()
	KuyoShibariSound.PlayOnRemove = true
	KuyoShibariSound.Parent = Target.HumanoidRootPart
	KuyoShibariSound:Destroy()
	KuyoShibariSound = nil
end

function ClientSkills.VisoredCero(Character, Phase, RootCFrame, CeroStats, ReleaseSpeed, Properties)
	if Phase == "1" then
		local VisoredCeroCharge = KidoEffects.VisoredCeroCharge.Enable:Clone()
		VisoredCeroCharge.Parent = Character["Left Arm"]
		Debris:AddItem(VisoredCeroCharge, 3)

		local ChargeSound = HollowSounds.CeroCharge:Clone()
		ChargeSound.Parent = Character.PrimaryPart
		ChargeSound:Play()
		Debris:AddItem(ChargeSound, 2.2)

		local DelayTime = 1.7
		if CeroStats then
			DelayTime -= (2 - ReleaseSpeed)
		end

		task.delay(DelayTime, function()
			TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
			VisoredCeroCharge.Particle.Enabled = false
		end)
	elseif Phase == "2" then	
		local Cero = KidoEffects.VisoredCero:Clone()

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil
		
		local VisoredCeroBlast = KidoEffects.VisoredCeroBlast:Clone()
		VisoredCeroBlast.Anchored = true
		VisoredCeroBlast.CFrame = RootCFrame * CFrame.new(9.15527344e-05, 0.844323635, -3.0793457, -1, 0, 8.74227766e-08, -1.14637683e-13, 1, -1.31130219e-06, -8.74227766e-08, -1.31130264e-06, -1)
		VisoredCeroBlast.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(VisoredCeroBlast, 1.1)
		
		for i, v in ipairs(VisoredCeroBlast.Emit50:GetChildren()) do
			v:Emit(50)
		end
		
		for i, v in ipairs(VisoredCeroBlast.Emit15:GetChildren()) do
			v:Emit(15)
		end
		
		local MultiplierIncrease = 0.6
		if CeroStats and CeroStats.Kido >= 40 then
			MultiplierIncrease = 0.45
		end
		local BeamSize = Vector3.new(17.264, 16.279, 138.582)
		local CeroSize = Vector3.new(14.107, 14.062, 137.108)
		if CeroStats then
			BeamSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
			CeroSize += Vector3.new(CeroStats.Kido / (Properties.Width * MultiplierIncrease), CeroStats.Kido / (Properties.Height * MultiplierIncrease), CeroStats.Kido * Properties.Range)
		end

		Cero.PrimaryPart.CFrame = RootCFrame * CFrame.new(0, 0.8, -2.5) * CFrame.new(Vector3.new(0, 0, (-BeamSize.Z / 2) - 1))
		Cero.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(Cero.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = Cero.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)
	end
end

--==================================================
--======================Speed=======================
--==================================================

function ClientSkills.FlashstepMastery1(Character)

end

function ClientSkills.FlashstepMastery2(Character)

end

function ClientSkills.PerfectFlashstep(Character)

end

function ClientSkills.Flashstep(Character)
	
end

function ClientSkills.FlashTension(Character)

end

function ClientSkills.FlashCut(Character, Range)
	local Time = 0.2
	local Offset = Range
	local SpawnPoint = (Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5) * CFrame.new(Vector3.new(0, 0, Offset)))
	
	local Info = TweenInfo.new(Time, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
	local DelayedInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	
	local DashEffects = SpeedEffects.DashEffects:Clone()
	DashEffects:PivotTo(SpawnPoint)
	DashEffects.Parent = workspace.Effects[Character.Name]
	DashEffects.PrimaryPart:Destroy()
	Debris:AddItem(DashEffects, 1)
	
	local RandomColor = {
		[1] = Color3.fromRGB(54, 54, 54);
		[2] = Color3.fromRGB(67, 67, 67);
		[3] = Color3.fromRGB(167, 167, 167);
	}
	
	local FlashCutSound = SpeedSounds["Flash Cut"]:Clone()
	FlashCutSound.PlayOnRemove = true
	FlashCutSound.Parent = Character.HumanoidRootPart
	FlashCutSound:Destroy()
	FlashCutSound = nil
	
	for i, v in ipairs(DashEffects:GetChildren()) do
		v.Color = RandomColor[math.random(1, 3)]
		local OriginalSize = Vector3.new(v.Size.X, v.Size.Y, 0)
		local OriginalPosition = (v.CFrame * CFrame.new(0, 0, -Offset - 4)).Position
		local NewSize = Vector3.new(v.Size.X, v.Size.Y, v.Size.Z + Offset)
		local NewPosition = (v.CFrame * CFrame.new(0, 0, -Offset/2)).Position
		TweenService:Create(v, Info, {Size = NewSize, Position = NewPosition, Transparency = 0}):Play()
		task.delay(Time - 0.1, function()
			TweenService:Create(v, DelayedInfo, {Position = (v.CFrame * CFrame.new(0, 0, -4).Position)}):Play()
			
			task.wait(0.275)
			
			TweenService:Create(v, Info, {Transparency = 1, Size = OriginalSize, Position = OriginalPosition}):Play()
		end)
	end
end

function ClientSkills.PhantomTrick(Character)

end

function ClientSkills.FlashFakeout(Character)

end

function ClientSkills.BloomingCut(Character, Phase)
	if Phase == "1" then
		local BloomingCutStartup = SpeedSounds["Blooming Cut Startup"]:Clone()
		BloomingCutStartup.PlayOnRemove = true
		BloomingCutStartup.Parent = Character.PrimaryPart
		BloomingCutStartup:Destroy()
		BloomingCutStartup = nil
	elseif Phase == "2" then
		local BloomingCutSound = SpeedSounds["Blooming Cut"]:Clone()
		BloomingCutSound.PlayOnRemove = true
		BloomingCutSound.Parent = Character.PrimaryPart
		BloomingCutSound:Destroy()
		BloomingCutSound = nil
	end
end

function ClientSkills.Shunko(Character, Duration)
	local ShunkoActivateSound = SpeedSounds.ShunkoActivate:Clone()
	ShunkoActivateSound.PlayOnRemove = true
	ShunkoActivateSound.Parent = Character.HumanoidRootPart
	ShunkoActivateSound:Destroy()
	ShunkoActivateSound = nil
end

function ClientSkills.EnhancedSteps(Character, Duration)
	for i, v in ipairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			local EnhancedStepsParticle = SpeedEffects.EnhancedSteps.EnhancedSteps:Clone()
			EnhancedStepsParticle.Parent = v
			Debris:AddItem(EnhancedStepsParticle, Duration)
			task.delay(Duration - 1, function()
				if EnhancedStepsParticle then
					EnhancedStepsParticle.Enabled = false
				end
			end)
		end
	end
	
	local EnhancedStepsActivateSound = SpeedSounds.EnhancedStepsActivate:Clone()
	EnhancedStepsActivateSound.PlayOnRemove = true
	EnhancedStepsActivateSound.Parent = Character.HumanoidRootPart
	EnhancedStepsActivateSound:Destroy()
	EnhancedStepsActivateSound = nil
end

function ClientSkills.MirrorTempo(Character, Target, Race)
	local SpeedAnimations = ReplicatedStorage.Assets.SkillAnimations.Speed
	
	local SpawnPoint = Target.HumanoidRootPart.CFrame
	local CloneAmount = 9
	local Radius = 15
	
	local Rotater = Instance.new("Part")
	Rotater.Transparency = 1
	Rotater.Anchored = true
	Rotater.CanCollide = false
	Rotater.CFrame = SpawnPoint
	Rotater.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Rotater, 3)
	
	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Rotater.CFrame *= CFrame.Angles(0, -DeltaTime/2, 0)
	end)
	
	local DisconnectConnection
	DisconnectConnection = Rotater.Destroying:Connect(function()
		Connection:Disconnect()
		Connection = nil
		DisconnectConnection:Disconnect()
		DisconnectConnection = nil
	end)
	
	local function FlashstepAudio(Entity, Race)
		local FlashstepSmoke = ReplicatedStorage.Assets.Effects.FlashstepSmoke:Clone()
		FlashstepSmoke.CFrame = Entity.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -3, 0))
		FlashstepSmoke.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FlashstepSmoke, 1)
		for i, v in ipairs(FlashstepSmoke:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(15)
			end
		end

		if HumanCheck[Race] then
			local ShunpoAudio = ReplicatedStorage.Assets.Sounds["Shunpo (Flash Step)"]:Clone()
			ShunpoAudio.PlayOnRemove = true
			ShunpoAudio.Parent = Entity.PrimaryPart
			ShunpoAudio:Destroy()
			ShunpoAudio = nil
		elseif HollowCheck[Race] then
			local SonidoAudio = ReplicatedStorage.Assets.Sounds.Sonido:Clone()
			SonidoAudio.PlayOnRemove = true
			SonidoAudio.Parent = Entity.PrimaryPart
			SonidoAudio:Destroy()
			SonidoAudio = nil
		end
	end
	
	for i = 1, CloneAmount do
		local Angle = i * ((math.pi * 2) / CloneAmount)
		local X, Z = GetXandZPosition(Angle, Radius)

		local Position = (SpawnPoint * CFrame.new(X, 0, Z)).Position
		local CircleCFrame = CFrame.new(Position, SpawnPoint.Position)
		local MirrorTempoClone = SharedFunctions:CreateClone(Character, CircleCFrame)
		MirrorTempoClone.HumanoidRootPart.Anchored = false
		MirrorTempoClone.Humanoid.WalkSpeed = MirrorTempoClone:GetAttribute("BaseWalkspeed")
		
		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = MirrorTempoClone.HumanoidRootPart
		Weld.Part1 = Rotater
		Weld.Parent = Rotater
		
		local Transparency = {}
		for i, v in ipairs(MirrorTempoClone:GetDescendants()) do
			if v:IsA("BasePart") then
				Transparency[v] = v.Transparency
				v.Transparency = 1
				v.CollisionGroup = "Carried"
			elseif v:IsA("Decal") then
				v.Transparency = 1
			end
		end
		
		task.delay(i / 10, function()
			for i, v in ipairs(MirrorTempoClone:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("Decal") then
					local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
					TweenService:Create(v, Info, {Transparency = Transparency[v]}):Play()
				end
			end
			Transparency = nil
			FlashstepAudio(MirrorTempoClone, Race)
			task.delay(2, function()
				FlashstepAudio(MirrorTempoClone, Race)
				MirrorTempoClone:Destroy()
			end)
		end)

		local MirrorTempo = MirrorTempoClone.Humanoid.Animator:LoadAnimation(SpeedAnimations.SkillMirrorTempo)
		MirrorTempo:Play()
	end
end

function ClientSkills.DroppingFang(Character, Phase, Race, SpawnCFrame)
	if Phase == "1" then
		local DroppingFangRise = SpeedEffects.DroppingFang.RiseSmoke:Clone()
		DroppingFangRise.Parent = Character.HumanoidRootPart
		Debris:AddItem(DroppingFangRise, 1)
		for i, v in ipairs(DroppingFangRise:GetChildren()) do
			v:Emit(20)
		end
		
		local DroppingFangInitialSound = SpeedSounds.DroppingFangInitial:Clone()
		DroppingFangInitialSound.Parent = Character.HumanoidRootPart
		DroppingFangInitialSound:Destroy()
		DroppingFangInitialSound = nil
		
		FlashstepClient.Flashstep(Character)
		FlashstepClient.FlashstepAudio(Character, Race)
		task.delay(0.4, function()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				FlashstepClient.StopFlashstep(Character)
				FlashstepClient.FlashstepAudio(Character, Race)
				
				local DroppingFangInitialSound = SpeedSounds.DroppingFangInitial:Clone()
				DroppingFangInitialSound.PlayOnRemove = true
				DroppingFangInitialSound.Parent = Character.HumanoidRootPart
				DroppingFangInitialSound:Destroy()
				DroppingFangInitialSound = nil

				local DroppingFangDive = SpeedEffects.DroppingFangDive:Clone()
				DroppingFangDive.Anchored = false
				DroppingFangDive.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(DroppingFangDive, 0.5)

				local Weld = Instance.new("Weld")
				Weld.C0 = CFrame.new(0, 0, 0, 1.00000024, -1.86264515e-09, 1.77634329e-14, -1.86264515e-09, 0.999999881, 9.88109334e-15, 1.77634329e-14, 9.88109334e-15, 0.99999249)
				Weld.Part0 = DroppingFangDive
				Weld.Part1 = Character.Torso
				Weld.Parent = DroppingFangDive
			end
		end)
	elseif Phase == "2" then
		local DroppingFangAirleap = SpeedEffects.DroppingFang:Clone()
		DroppingFangAirleap.CFrame = SpawnCFrame
		DroppingFangAirleap.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DroppingFangAirleap, 1)
		DroppingFangAirleap.AirLeap.Airleap:Emit(18)
		
		local DroppingFangDashSound = SpeedSounds.DroppingFangDash:Clone()
		DroppingFangDashSound.PlayOnRemove = true
		DroppingFangDashSound.Parent = DroppingFangAirleap
		DroppingFangDashSound:Destroy()
		DroppingFangDashSound = nil
	elseif Phase == "3" then
		local DroppingFangImpact = SpeedEffects.DroppingFang:Clone()
		DroppingFangImpact.CFrame = SpawnCFrame
		DroppingFangImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DroppingFangImpact, 1)
		for i, v in ipairs(DroppingFangImpact.DroppingFangImpact:GetChildren()) do
			v:Emit(1)
		end
		DroppingFangImpact.ImpactSmoke.ParticleEmitter:Emit(50)
		
		local DroppingFangImpactSound = SpeedSounds.DroppingFangImpact:Clone()
		DroppingFangImpactSound.PlayOnRemove = true
		DroppingFangImpactSound.Parent = DroppingFangImpact
		DroppingFangImpactSound:Destroy()
		DroppingFangImpactSound = nil
		
		local DroppingFangSlashSound = SpeedSounds.DroppingFangSlash:Clone()
		DroppingFangSlashSound.PlayOnRemove = true
		DroppingFangSlashSound.Parent = Character.HumanoidRootPart
		DroppingFangSlashSound:Destroy()
		DroppingFangSlashSound = nil
		
		local DebrisData = {
			Amount = math.random(5, 7),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 2,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Character.HumanoidRootPart.CFrame, DebrisData)
	end
end

function ClientSkills.WaterfallDance(Character, Phase, HitCounter)
	if Phase == "1" then
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.MaxForce = Vector3.new(160000, 160000, 160000)
		BodyPosition.P = 30000
		BodyPosition.Position = Character.HumanoidRootPart.Position + Vector3.new(0, 8, 0)
		BodyPosition.Parent = Character.Head
		Debris:AddItem(BodyPosition, 0.4)
		
		local WaterfallDanceSound = SpeedSounds.WaterfallDance:Clone()
		WaterfallDanceSound.PlayOnRemove = true
		WaterfallDanceSound.TimePosition = 0.2
		WaterfallDanceSound.Parent = Character.HumanoidRootPart
		WaterfallDanceSound:Destroy()
		WaterfallDanceSound = nil
		
		task.delay(0.23, function()
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				local HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
				HyperArmorHighlight.Parent = Character
				Debris:AddItem(HyperArmorHighlight, 1.85)
			end
		end)
	elseif Phase == "2" then
		local function RandomOrder(Amount, MaxAmount)
			local Array = {}
			local Order = {}
			for i = 1, MaxAmount do
				table.insert(Array, i)
			end
			for i = 1, Amount do
				local Number = Array[math.random(1, #Array)]
				table.remove(Array, table.find(Array, Number))
				table.insert(Order, Number)
			end
			return Order
		end

		local SlashOrder = RandomOrder(8, 13)

		local WaterfallDance = SpeedEffects.WaterfallDance:Clone()
		WaterfallDance.CFrame = Character.HumanoidRootPart.CFrame
		WaterfallDance.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(WaterfallDance, 1)

		if HitCounter == 5 then
			WaterfallDance.End.Crescents:Emit(11)
		end
		
		local WaterfallDanceSlashSound = SpeedSounds.WaterfallDanceSlash:Clone()
		WaterfallDanceSlashSound.PlayOnRemove = true
		WaterfallDanceSlashSound.Parent = Character.HumanoidRootPart
		WaterfallDanceSlashSound:Destroy()
		WaterfallDanceSlashSound = nil
		
		for i, v in ipairs(SlashOrder) do
			local Slash = WaterfallDance["Slash" .. v].Main
			Slash:Emit(10)
			task.wait(0.012)
		end
	end
end

function ClientSkills.SonidoBreak(Character, Phase)
	if Phase == "1" then
	elseif Phase == "2" then
		local SonidoBreak = SpeedEffects.SonidoBreak:Clone()
		SonidoBreak.Parent = workspace.Effects[Character.Name]
		SonidoBreak["Right Arm"].Part1 = Character["Right Arm"]
		Debris:AddItem(SonidoBreak, 1.7)
		
		task.delay(0.7, function()
			SonidoBreak.Trail.Enabled = false
		end)		
	end
end

function ClientSkills.GhostCleave(Character, Phase, RootCFrame)
	if Phase == "1" then
		local Clone = SharedFunctions:CreateClone(Character, RootCFrame, nil, "NoCollide")

		Clone.Head.CFrame = Character.Head.CFrame
		Clone.Torso.CFrame = Character.Torso.CFrame
		Clone["Right Leg"].CFrame = Character["Right Leg"].CFrame
		Clone["Right Arm"].CFrame = Character["Right Arm"].CFrame
		Clone["Left Leg"].CFrame = Character["Left Leg"].CFrame
		Clone["Left Arm"].CFrame = Character["Left Arm"].CFrame

		Debris:AddItem(Clone, 1)

		for i, v in pairs(Clone:GetDescendants()) do
			if v:IsA("SpecialMesh") then
				v.VertexColor = color3ToVector3(Color3.fromRGB(50, 50, 50))
			elseif v:IsA("BasePart") then
				v.Color = Color3.fromRGB(50, 50, 50)
			elseif v:IsA("BillboardGui") then
				v.Enabled = false
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end
		
		local GhostCleaveSlash = SpeedSounds.GhostCleaveSlash:Clone()
		GhostCleaveSlash.PlayOnRemove = true
		GhostCleaveSlash.Parent = Character.HumanoidRootPart
		GhostCleaveSlash:Destroy()
		GhostCleaveSlash = nil
		
		task.delay(0.5, function()
			for i, v in ipairs(Clone:GetDescendants()) do
				if v:IsA("BasePart") then
					TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
				end
			end
		end)
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.0279541016, -0.372328758, -3.69085693, 0.984657884, -0.173649386, 0.0171917081, 0.173623011, 0.98480773, 0.00302940607, -0.0174565613, 1.93329697e-06, 0.999847889)
		
		local GhostCleave = SpeedEffects.GhostCleave:Clone()
		GhostCleave.Anchored = true
		GhostCleave.CFrame = Character.HumanoidRootPart.CFrame * Offset
		GhostCleave.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GhostCleave, 1.4)
		
		for i, v in ipairs(GhostCleave:GetChildren()) do
			v:Emit(15)
		end
		
		local GhostCleavePhase = SpeedSounds.GhostCleavePhase:Clone()
		GhostCleavePhase.PlayOnRemove = true
		GhostCleavePhase.Parent = Character.HumanoidRootPart
		GhostCleavePhase:Destroy()
		GhostCleavePhase = nil
	elseif Phase == "3" then
		local Offset = CFrame.new(-1.22332764, 0.347875118, -0.111755371, -0.906162262, 0.42258057, 0.0171918795, -0.422593892, -0.906314313, 0.00302938558, 0.0168613996, -0.00452006795, 0.99984771)

		local GhostCleave = SpeedEffects.GhostCleave2:Clone()
		GhostCleave.Anchored = true
		GhostCleave.CFrame = Character.HumanoidRootPart.CFrame * Offset
		GhostCleave.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GhostCleave, 1.4)

		for i, v in ipairs(GhostCleave:GetChildren()) do
			v:Emit(8)
		end
	end
end

function ClientSkills.FlashFang(Character, Phase, SpawnPoint)
	if Phase == "1" then
		local Transparency = 0.9

		Character["Right Arm"].Transparency = Transparency
		
		local Transparencies = {}
		local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
		if Weapon then
			for i, v in ipairs(Weapon:GetDescendants()) do
				if v:IsA("BasePart") and v.Transparency ~= 1 then
					Transparencies[v] = v.Transparency
					v.Transparency = Transparency
				end
			end
		end
		
		local FlashFangSound = SpeedSounds.FlashFang:Clone()
		FlashFangSound.Parent = Character.HumanoidRootPart
		FlashFangSound:Play()
		Debris:AddItem(FlashFangSound, FlashFangSound.TimeLength)
		
		task.delay(0.9, function()
			TweenService:Create(FlashFangSound, TweenInfo.new(1), {Volume = 0}):Play()
			Character["Right Arm"].Transparency = 0			

			if Weapon then
				for i, v in ipairs(Weapon:GetDescendants()) do
					if v:IsA("BasePart") and v.Transparency ~= 1 then
						v.Transparency = Transparencies[v]
						Transparencies[v] = nil
					end
				end
			end
			Transparencies = nil
		end)
	elseif Phase == "2" then
		local Offset = CFrame.new(0.000427246094, -0.000189304352, -0.000183105469, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08)

		local FlashFang = SpeedEffects.FlashFang:Clone()
		FlashFang.CFrame = SpawnPoint * Offset
		FlashFang.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FlashFang, 1)

		for i, v in ipairs(FlashFang:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(2)
			end
		end
	end
end

function ClientSkills.StrataStrike(Character, Phase, Target)
	if Phase == "1" then
		local StrataStrikeSound = SpeedSounds.StrataStrikeWindup:Clone()
		StrataStrikeSound.PlayOnRemove = true
		StrataStrikeSound.Parent = Character.HumanoidRootPart
		StrataStrikeSound:Destroy()
		StrataStrikeSound = nil
	elseif Phase == "2" then
		local Offset = CFrame.new(0.000427246094, -0.000189304352, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		local StrataStrike = SpeedEffects.StrataStrike:Clone()
		StrataStrike.Anchored = true
		StrataStrike.CFrame = Target.HumanoidRootPart.CFrame * Offset
		StrataStrike.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(StrataStrike, 2.5)

		local StrataStrikeSound = SpeedSounds.StrataStrike:Clone()
		StrataStrikeSound.PlayOnRemove = true
		StrataStrikeSound.Parent = StrataStrike
		StrataStrikeSound:Destroy()
		StrataStrikeSound = nil

		for i, v in ipairs(StrataStrike:GetChildren()) do
			v:Emit(7)
		end
	end
end

function ClientSkills.SpecterStep(Character, Phase, Target, Rate, Flashes, FlashCFrame, Duration)
	if Phase == "0" then
		local function RandomNumber(Min, Max)
			local RNG = Random.new()
			return RNG:NextNumber(Min, Max)
		end
		
		local Distance = 1
		local TickRate = 0.03
		local Info = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)	
		
		local Color = Color3.fromRGB(255, 255, 255)
		local Duration = Target + (Rate * Flashes)
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			Duration -= DeltaTime

			if Duration <= 0 or not Character:FindFirstChild("HumanoidRootPart") or Character:GetAttribute("CurrentState") ~= "Skill" then
				Connection:Disconnect()
				Connection = nil
				return
			end

			if Accumulated > TickRate then
				Accumulated -= TickRate

				for i, v in ipairs(Character:GetChildren()) do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "Head" then
						local Shadow = v:Clone()
						Shadow.Color = Color
						Shadow.Material = Enum.Material.Neon
						Shadow.Transparency = 0.1
						Shadow.CFrame = v.CFrame
						Shadow.CanCollide = false
						Shadow.Anchored = true
						Shadow:ClearAllChildren()
						Shadow.Parent = workspace.Effects[Character.Name]
						Debris:AddItem(Shadow, 0.2)

						local ShadowCFrame = Shadow.CFrame * CFrame.new(RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance))
						TweenService:Create(Shadow, Info, {CFrame = ShadowCFrame, Transparency = 1}):Play()
					elseif v:IsA("Accessory") then
						if v:FindFirstChild("Handle") then
							local Handle = v.Handle:Clone()
							Handle.AccessoryWeld:Destroy()
							Handle.Anchored = true
							Handle.CanCollide = false
							Handle.Color = Color
							Handle.Material = Enum.Material.Neon
							Handle.Transparency = 0.1
							Handle.CFrame = v.Handle.CFrame

							local Mesh = Handle:FindFirstChildWhichIsA("SpecialMesh")
							if Mesh then
								Mesh.VertexColor = color3ToVector3(Handle.Color)
							end
							Handle.Parent = workspace.Effects[Character.Name]
							Debris:AddItem(Handle, 0.2)

							local ShadowCFrame = Handle.CFrame * CFrame.new(RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance), RandomNumber(-Distance, Distance))
							TweenService:Create(Handle, Info, {CFrame = ShadowCFrame, Transparency = 1}):Play()
						end
					end
				end
			end
		end)
	elseif Phase == "1" then
		local function Offset(SpawnCFrame)
			local RNG = Random.new()
			local Position = (SpawnCFrame * CFrame.new(RNG:NextInteger(-10, 10), 0, RNG:NextInteger(-10, 10))).Position
			return CFrame.new(Position, Target.HumanoidRootPart.Position)
		end
		
		local PreRenderCFrame = CFrame.new(5000, 5000, 5000)
		local Clone = SharedFunctions:CreateClone(Character, PreRenderCFrame, nil, "NoCollide", "NoAnchoredCollision")
		Clone.Name = Character.Name
		Clone.HumanoidRootPart.Anchored = true
		Debris:AddItem(Clone, Rate * Flashes + 0.35)
		
		FlashstepClient.Invisible(Character)
		
		for i = 1, Rate do
			local SpawnCFrame = Offset(Target.HumanoidRootPart.CFrame)
			local FlashOffset = 7
			if math.random(1, 2) == 2 then
				FlashOffset *= -1
			end
			local FlashingCFrame = CFrame.new(FlashOffset, 0, 0)
			
			local Clone = SharedFunctions:CreateClone(Clone, SpawnCFrame, nil, "NoCollide", "NoAnchoredCollision")
			Clone.HumanoidRootPart.Anchored = true
			Debris:AddItem(Clone, 0.35)
			
			FlashstepClient.Evaded(Character, Character:GetAttribute("EntityType"), SpawnCFrame)
			task.delay(0.35, function()
				FlashstepClient.Evaded(Character, Character:GetAttribute("EntityType"), SpawnCFrame * FlashingCFrame)
			end)
			
			local SpecterStepAnimation = Clone.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.SkillAnimations.Speed["SpecterStep" .. math.random(1, 3)])
			SpecterStepAnimation:Play()
			SpecterStepAnimation:AdjustSpeed(0)
			
			local FlashInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Clone.HumanoidRootPart, FlashInfo, {CFrame = SpawnCFrame * FlashingCFrame}):Play()
			
			task.delay(0.2, function()
				for i, v in ipairs(Clone:GetDescendants()) do
					if v:IsA("BasePart") then
						TweenService:Create(v, FlashInfo, {Transparency = 1}):Play()
					end
				end
			end)
			
			local FlashstepClone = ReplicatedStorage.Assets.Effects.FlashstepClone:Clone()
			FlashstepClone.Head.CFrame = Clone.Head.CFrame
			FlashstepClone.Torso.CFrame = Clone.Torso.CFrame
			FlashstepClone["Right Leg"].CFrame = Clone["Right Leg"].CFrame
			FlashstepClone["Right Arm"].CFrame = Clone["Right Arm"].CFrame
			FlashstepClone["Left Leg"].CFrame = Clone["Left Leg"].CFrame
			FlashstepClone["Left Arm"].CFrame = Clone["Left Arm"].CFrame
			FlashstepClone.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(FlashstepClone, 1)

			local Color = Color3.fromRGB(255, 255, 255)
			if Character:GetAttribute("EntityType") ~= "Quincy" then
				Color = Color3.fromRGB(0, 0, 0)
			end
			
			for i, v in ipairs(FlashstepClone:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Color = Color
				end
			end

			local function color3ToVector3(c3)
				return Vector3.new(c3.r, c3.g, c3.b)
			end

			for i, v in ipairs(Clone:GetChildren()) do
				if v:IsA("Accessory") then
					local Hair = v:Clone()
					local Weld = Hair.Handle:FindFirstChildWhichIsA("Weld")
					if Weld then
						Weld:Destroy()
						Weld= nil
					end
					Hair.Handle.Anchored = true
					Hair.Handle.CFrame = v.Handle.CFrame
					Hair.Handle.Color = Color
					Hair.Handle.Transparency = 0.15
					local Mesh = Hair.Handle:FindFirstChildWhichIsA("SpecialMesh") 
					if Mesh then
						Mesh.VertexColor = color3ToVector3(Hair.Handle.Color)
					end
					Hair.Parent = FlashstepClone
				end
			end

			local Info = TweenInfo.new(0.15, Enum.EasingStyle.Linear,Enum.EasingDirection.Out, 0, false, 0)
			task.delay(0.1, function()
				local function Visible(Model, Visiblity)
					for i, v in ipairs(Model:GetDescendants()) do
						if v:IsA("BasePart") then
							v.Transparency = Visiblity
						end
					end
				end

				for i = 1, 4 do
					if i % 2 == 0 then
						Visible(FlashstepClone, 0)
					else
						Visible(FlashstepClone, 1)
					end

					task.wait(0.07)
				end

				for _, v in ipairs(FlashstepClone:GetDescendants()) do
					if v:IsA("BasePart") then
						local TweenTransparency = TweenService:Create(v, Info, {Transparency = 1})
						TweenTransparency:Play()
					end
				end
			end)
			
			task.wait(Flashes)
		end
	elseif Phase == "2" then
		FlashstepClient.Visible(Character)
	elseif Phase == "3" then
		FlashstepClient.Evaded(Character, Character:GetAttribute("EntityType"), FlashCFrame)
	elseif Phase == "4" then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		workspace.CurrentCamera.CameraSubject = Target
		task.delay(Flashes * Rate, function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			workspace.CurrentCamera.CameraSubject = Character
		end)
	elseif Phase == "5" then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.CameraSubject = Character
	end
end

function ClientSkills.FastFang(Character, Phase, Speed, Duration, Target, Rate, Hits)
	if Phase == "1" then
		local CurrentSpeed = Speed
		local LookVector = Character.HumanoidRootPart.CFrame.LookVector
		
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Name = "DashForce"
		BodyVelocity.MaxForce = Vector3.new(60000, 0, 60000)
		BodyVelocity.P = 1250
		BodyVelocity.Velocity = LookVector * CurrentSpeed
		BodyVelocity.Parent = Character.HumanoidRootPart
		Debris:AddItem(BodyVelocity, Duration)
		
		task.delay(Duration - 0.15, function()
			local Lifetime = 0.15
			local Accumulated = 0
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Lifetime -= DeltaTime
				Accumulated += DeltaTime
				
				if Lifetime <= 0 then
					Connection:Disconnect()
					Connection = nil
					return
				end
				
				local TimeRange = (0.15 - 0)  
				local SpeedRange = (Speed - 0)  
				local Velocity = (((Lifetime - 0) * SpeedRange) / TimeRange) + 0
				
				if Velocity < 0 then
					Velocity = 0
				end
				
				BodyVelocity.Velocity = LookVector * Velocity
			end)
		end)
		
		local FastFangFx = SpeedEffects.FastFangInvis:Clone()
		FastFangFx.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FastFangFx, 0.85)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = FastFangFx
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = FastFangFx
		
		for i, v in ipairs(FastFangFx:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local FastFangTrail = SpeedEffects.FastFangTrail:Clone()
		FastFangTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FastFangTrail, 1.4)

		local Weld2 = Instance.new("Weld")
		Weld2.Part0 = FastFangTrail
		Weld2.Part1 = Character.HumanoidRootPart
		Weld2.Parent = FastFangTrail
		
		local Stunned
		local Connection
		Connection = Character:GetAttributeChangedSignal("CurrentState"):Connect(function()
			if Character:GetAttribute("CurrentState") == "TrueStunned" or Character:GetAttribute("CurrentState") == "PostureBroken" then
				if Connection then
					Connection:Disconnect()
					Connection = nil
				end
				Stunned = true
				FlashstepClient.Visible(Character)
				
				Weld2:Destroy()
				Weld2 = nil
				FastFangTrail.Anchored = true

				for i, v in ipairs(FastFangTrail:GetDescendants()) do
					if v:IsA("ParticleEmitter") or v:IsA("Trail") then
						v.Enabled = false
					end
				end
			end
		end)
		
		FlashstepClient.Invisible(Character)
		task.delay(0.4, function()
			if not Stunned then
				if Connection then
					Connection:Disconnect()
					Connection = nil
				end
				FlashstepClient.Visible(Character, 0.1)
				
				Weld2:Destroy()
				Weld2 = nil
				FastFangTrail.Anchored = true
				
				for i, v in ipairs(FastFangTrail:GetDescendants()) do
					if v:IsA("ParticleEmitter") or v:IsA("Trail") then
						v.Enabled = false
					end
				end
				
				local FastFangSound = SpeedSounds.FastFangDash:Clone()
				FastFangSound.PlayOnRemove = true
				FastFangSound.Parent = Character.PrimaryPart
				FastFangSound:Destroy()
				FastFangSound = nil
			end
		end)
		
		local FastFangSound = SpeedSounds.FastFangStartup:Clone()
		FastFangSound.PlayOnRemove = true
		FastFangSound.Parent = Character.PrimaryPart
		FastFangSound:Destroy()
		FastFangSound = nil
	elseif Phase == "2" then
		local function RandomAngle(SpawnCFrame)
			local RNG = Random.new()
			return SpawnCFrame * CFrame.Angles(RNG:NextNumber(-math.pi*2, math.pi*2), RNG:NextNumber(-math.pi*2, math.pi*2), RNG:NextNumber(-math.pi*2, math.pi*2))
		end
		local function RandomNumber(Min, Max)
			return Random.new():NextNumber(Min, Max)
		end
		
		for i = 1, Hits do
			local FastFang = SpeedEffects.FastFang:Clone()
			if Character:GetAttribute("VisoredActive") then
				FastFang.Color = Color3.fromRGB(0, 0, 0)
			end	
			if Character:GetAttribute("LetztStilActive") then
				FastFang.Color = Color3.fromRGB(234, 226, 132)
			end	
			local Size = FastFang.Size
			FastFang.CFrame = RandomAngle(Target.HumanoidRootPart.CFrame) * CFrame.new(3.64244556, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			
			local Pivot = FastFang.CFrame * CFrame.new(-3.64244556, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local Offset = Pivot:Inverse() * FastFang.CFrame
			
			FastFang.Size = Vector3.zero
			FastFang.Transparency = 1
			FastFang.CFrame = Pivot * Offset
			FastFang.Parent = workspace.Effects[Character.Name]
			
			local FadeOffset = 2
			TweenService:Create(FastFang, TweenInfo.new(0.15), {Size = Size, Transparency = 0, Position = (FastFang.CFrame * CFrame.new(RandomNumber(-FadeOffset, FadeOffset), RandomNumber(-FadeOffset, FadeOffset), RandomNumber(-FadeOffset, FadeOffset))).Position}):Play()
		
			local Lifetime = 0.5
			task.delay(Lifetime - 0.15, function()
				TweenService:Create(FastFang, TweenInfo.new(0.15), {Size = Vector3.zero, Transparency = 1}):Play()
			end)
			
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Lifetime -= DeltaTime

				if Lifetime <= 0 then
					Connection:Disconnect()
					Connection = nil
					FastFang:Destroy()
					FastFang = nil
					return
				end
				
				if Lifetime <= 0.5 - 15 then
					local TimeRange = (0.5 - 0)  
					local PivotRange = (Speed - 0)  
					local XOffset = (((DeltaTime - 0) * PivotRange) / TimeRange) + 0

					Pivot = FastFang.CFrame * CFrame.new(-XOffset, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
					Offset = Pivot:Inverse() * FastFang.CFrame
				end
				
				Pivot *= CFrame.Angles(0, 0, -0.5)
				FastFang.CFrame = Pivot * Offset
			end)
			
			task.wait(Rate)
		end
	end
end

function ClientSkills.FloatingStrikes(Character, Phase, Target, Strikes)
	if Phase == "1" then
		local FloatingStrikesSound = SpeedSounds.FloatingStrikesStartup:Clone()
		FloatingStrikesSound.PlayOnRemove = true
		FloatingStrikesSound.Parent = Character.PrimaryPart
		FloatingStrikesSound:Destroy()
		FloatingStrikesSound = nil
	elseif Phase == "2" then
		local Offsets = {
			[1] = {
				[1] = CFrame.new(-10, -10, 0, -0.707106769, -0.707106769, 8.8817842e-15, -0.707106769, 0.707106769, 0, 0, 0, -1);
				[2] = CFrame.new(0, -9.99996853, 10, -1.55431223e-15, -2.90878432e-14, -1, -0.707106769, 0.707106769, 1.75415136e-14, 0.707106769, 0.707106769, 0);
				[3] = CFrame.new(10, -10, 0, 0.707106769, 0.707106769, -8.8817842e-15, -0.707106769, 0.707106769, 0, 0, 0, 1);
			};
			[2] = {
				[1] = CFrame.new(9.99999905, 10.000001, 0, 0.707106769, -0.707106769, -8.8817842e-15, 0.707106769, 0.707106769, 0, 0, 0, 1);
				[2] = CFrame.new(2.98023224e-08, 9.99996853, -10.0000305, 1.22124533e-14, -1.24344979e-14, -1, 0.707106709, -0.707106709, -1.96507798e-14, -0.707106709, -0.707106709, -2.13162821e-14);
				[3] = CFrame.new(-10, 9.99999809, 0, -0.707106769, -0.707106769, -8.8817842e-15, 0.707106769, -0.707106769, 0, 0, 0, 1);
			};

		}

		for i = 1, 2 do
			local FastFang = SpeedEffects.FastFang:Clone()
			if Character:GetAttribute("VisoredActive") then
				FastFang.Color = Color3.fromRGB(0, 0, 0)
			end	
			if Character:GetAttribute("LetztStilActive") then
				FastFang.Color = Color3.fromRGB(234, 226, 132)
			end	
			local Size = FastFang.Size
			FastFang.CFrame = Target.HumanoidRootPart.CFrame * Offsets[i][Strikes]
			FastFang.Parent = workspace.Effects[Character.Name]

			local Direction = (Target.HumanoidRootPart.Position - FastFang.Position).Unit * 10

			TweenService:Create(FastFang, TweenInfo.new(0.1), {Position = Target.HumanoidRootPart.Position}):Play()
			task.delay(0.1, function()
				TweenService:Create(FastFang, TweenInfo.new(0.1), {Transparency = 1, Size = Vector3.zero, Position = FastFang.Position + Direction}):Play()
			end)

			local Duration = 0.2
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Duration -= DeltaTime

				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
					FastFang:Destroy()
					FastFang = nil
					return
				end

				FastFang.CFrame *= CFrame.Angles(0, 0, -0.5)
			end)
		end
	end	
end

--==================================================
--=====================Hakuda=======================
--==================================================

function ClientSkills.HakudaStyle(Character)

end

function ClientSkills.GrandEntrance(Character, Phase, RootCFrame)
	if Phase == "1" then
		local GrandEntranceInitialSound = HakudaSounds["Grand Entrance Initial"]:Clone()
		GrandEntranceInitialSound.PlayOnRemove = true
		GrandEntranceInitialSound.Parent = Character.PrimaryPart
		GrandEntranceInitialSound:Destroy()
		GrandEntranceInitialSound = nil
		
		local GrandEntrancePt1 = HakudaEffects["Grand Entrance Pt 1"].Attach2:Clone()
		GrandEntrancePt1.Parent = Character.HumanoidRootPart
		Debris:AddItem(GrandEntrancePt1, 1)
		GrandEntrancePt1["Black ring"]:Emit(6)
	elseif Phase == "2" then
		local GrandEntranceImpactSound = HakudaSounds["Grand Entrance Impact"]:Clone()
		GrandEntranceImpactSound.PlayOnRemove = true
		GrandEntranceImpactSound.Parent = Character.PrimaryPart
		GrandEntranceImpactSound:Destroy()
		GrandEntranceImpactSound = nil

		local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
		GSCritEffect.CFrame = Character.HumanoidRootPart.CFrame
		GSCritEffect.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
			v:Emit(50)
		end
		Debris:AddItem(GSCritEffect, 1.5)

		local GroundImpact = HakudaEffects["Ground Impact"]:Clone()
		GroundImpact.CFrame = RootCFrame
		GroundImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GroundImpact, 2)
		for i, v in ipairs(GroundImpact.Attachment:GetChildren()) do
			v:Emit(4)
		end

		local Origin = RootCFrame * CFrame.new(0, 3, 0)
		local CraterData = {
			Radius = 15,
			PartSize = 2,
			Duration = 3,
			DebrisData = {
				Amount = math.random(3, 5),
				Collidable = true,
				VelocityMin = 30,
				VelocityMax = 50,
			}
		}

		ImpactCrater:Crater(Character, Origin, CraterData)
	elseif Phase == "3" then
		local GrandEntranceInitialEffect = HakudaEffects["Grand Entrance FX"]:Clone()
		GrandEntranceInitialEffect.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
		GrandEntranceInitialEffect.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandEntranceInitialEffect, 1)
		for i, v in ipairs(GrandEntranceInitialEffect:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(6)
			end
		end
	elseif Phase == "4" then
		local Shadows = 5
		local Rate = 0.1
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated > Rate then
				Accumulated -= Rate
				Shadows -= 1
				
				if Shadows <= 0 then
					Connection:Disconnect()
					Connection = nil
				end
				
				local Clone = SharedFunctions:CreateClone(Character, Character.HumanoidRootPart.CFrame, nil, "NoCollide")

				Clone.Head.CFrame = Character.Head.CFrame
				Clone.Torso.CFrame = Character.Torso.CFrame
				Clone["Right Leg"].CFrame = Character["Right Leg"].CFrame
				Clone["Right Arm"].CFrame = Character["Right Arm"].CFrame
				Clone["Left Leg"].CFrame = Character["Left Leg"].CFrame
				Clone["Left Arm"].CFrame = Character["Left Arm"].CFrame

				Debris:AddItem(Clone, 1)

				for i, v in pairs(Clone:GetDescendants()) do
					if v:IsA("SpecialMesh") then
						v.TextureId = ""
						v.VertexColor = color3ToVector3(Color3.fromRGB(15, 15, 15))
					elseif v:IsA("BasePart") then
						v.Color = Color3.fromRGB(50, 50, 50)
					elseif v:IsA("BillboardGui") then
						v.Enabled = false
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
						v:Destroy()
					end
				end

				task.delay(0.5, function()
					for i, v in ipairs(Clone:GetDescendants()) do
						if v:IsA("BasePart") then
							TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
						end
					end
				end)
			end
		end)
		
		local GrandEntranceAir = HakudaEffects.GrandEntranceAir:Clone()
		GrandEntranceAir.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandEntranceAir, 1.1)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = GrandEntranceAir
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = GrandEntranceAir
		
		task.delay(0.7, function()
			for i, v in ipairs(GrandEntranceAir:GetChildren()) do
				if v:IsA("Beam") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
		
		local GrandEntranceAir = HakudaSounds.GrandEntranceAir:Clone()
		GrandEntranceAir.PlayOnRemove = true
		GrandEntranceAir.Parent = Character.HumanoidRootPart
		GrandEntranceAir:Destroy()
		GrandEntranceAir = nil
	elseif Phase == "5" then
		local GrandEntranceAir = HakudaEffects.GrandEntranceAir:Clone()
		GrandEntranceAir.Anchored = true
		GrandEntranceAir.CFrame = RootCFrame
		GrandEntranceAir.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandEntranceAir, 1.8)
		
		for i, v in ipairs(GrandEntranceAir:GetDescendants()) do
			if v:IsA("Beam") or v:IsA("Trail") then
				v.Enabled = false
			end
		end
		
		GrandEntranceAir.Emit95.Smoke:Emit(95)
	end
end

function ClientSkills.WhirlwindStep(Character, Phase)
	if Phase == "1" then
		local WhirlwindStepSound = HakudaSounds.WhirlwindStepStart:Clone()
		WhirlwindStepSound.PlayOnRemove = true
		WhirlwindStepSound.Parent = Character.PrimaryPart
		WhirlwindStepSound:Destroy()
		WhirlwindStepSound = nil
	elseif Phase == "2" then
		local WindstepWhirl = HakudaEffects["Windstep Whirl"].Attachment:Clone()
		WindstepWhirl.Parent = Character.HumanoidRootPart
		WindstepWhirl.Crescents.Enabled = true
		
		local WindstepTrail = HakudaEffects["Windstep Trail"]:Clone()
		WindstepTrail.Anchored = false
		WindstepTrail.Parent = workspace.Effects[Character.Name]
		WindstepTrail.Lines.Enabled = true
		WindstepTrail.Lines2.Enabled = true
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.294776917, 0.924176931, -2.93495941, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = WindstepTrail
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = WindstepTrail
		
		task.delay(0.73, function()
			WindstepWhirl.Crescents.Enabled = false
			WindstepTrail.Lines.Enabled = false
			WindstepTrail.Lines2.Enabled = false
			Debris:AddItem(WindstepTrail, 1)
			Debris:AddItem(WindstepWhirl, 1)
		end)
	end
end

function ClientSkills.AbsoluteDefense(Character)
	local AbsoluteDefenseSound = HakudaSounds["Absolute Defense"]:Clone()
	AbsoluteDefenseSound.Parent = Character.PrimaryPart
	AbsoluteDefenseSound:Play()
	Debris:AddItem(AbsoluteDefenseSound, AbsoluteDefenseSound.TimeLength)
	
	local AbsoluteDefenseEffect = HakudaEffects["Absolute Defense"].Attachment:Clone()
	AbsoluteDefenseEffect.Parent = Character.HumanoidRootPart
	Debris:AddItem(AbsoluteDefenseEffect, 1)
	for i, v in ipairs(AbsoluteDefenseEffect:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(1)
		end
	end
end

function ClientSkills.RisingShot(Character, Phase)
	if Phase == "1" then
		local RisingFX = HakudaEffects.RisingFX:Clone()
		RisingFX.CFrame = Character.HumanoidRootPart.CFrame
		RisingFX.Anchored = true
		RisingFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RisingFX, 1.1)
		
		for i, v in ipairs(RisingFX.Emit5:GetChildren()) do
			v:Emit(5)
		end
		
		local RisingFX2 = HakudaEffects.RisingFX:Clone()
		RisingFX2.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RisingFX2, 1.1)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = RisingFX2
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = RisingFX2
		
		for i, v in ipairs(RisingFX2.Emit1:GetChildren()) do
			v:Emit(1)
		end
		
		for i, v in ipairs(RisingFX2.Emit25:GetChildren()) do
			v:Emit(25)
		end
	elseif Phase == "2" then
		local RisingFX = HakudaEffects.RisingFX:Clone()
		RisingFX.Anchored = true
		RisingFX.CFrame = Character.HumanoidRootPart.CFrame
		RisingFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RisingFX, 0.3)

		for i, v in ipairs(RisingFX.Kick1:GetChildren()) do
			v:Emit(20)
		end
		
		local RisingShotSound = HakudaSounds["Rising Shot"]:Clone()
		RisingShotSound.PlayOnRemove = true
		RisingShotSound.Parent = Character.PrimaryPart
		RisingShotSound:Destroy()
		RisingShotSound = nil
	elseif Phase == "3" then
		local RisingFX = HakudaEffects.RisingFX:Clone()
		RisingFX.Anchored = true
		RisingFX.CFrame = Character.HumanoidRootPart.CFrame
		RisingFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RisingFX, 0.3)

		for i, v in ipairs(RisingFX.Kick2:GetChildren()) do
			v:Emit(20)
		end
		
		local RisingShotSound = HakudaSounds["Rising Shot"]:Clone()
		RisingShotSound.PlayOnRemove = true
		RisingShotSound.Parent = Character.PrimaryPart
		RisingShotSound:Destroy()
		RisingShotSound = nil
	end
end

function ClientSkills.DemonicEmbrace(Character)
	local DemonicEmbraceSound = HakudaSounds["Demonic Embrace"]:Clone()
	DemonicEmbraceSound.Parent = Character.PrimaryPart
	DemonicEmbraceSound:Play()
	Debris:AddItem(DemonicEmbraceSound, DemonicEmbraceSound.TimeLength)
	
	local DemonicEmbraceEffect = HakudaEffects["Demonic Embrace"]:Clone()
	DemonicEmbraceEffect.Anchored = false
	DemonicEmbraceEffect.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(DemonicEmbraceEffect, 1)
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = DemonicEmbraceEffect
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = DemonicEmbraceEffect
	
	for i, v in ipairs(DemonicEmbraceEffect:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(3)
		end
	end
end

function ClientSkills.CatchingDragon(Character, Phase, Target)
	if Phase == "1" then
		local FlyingDragonInitial = HakudaSounds["Catching Dragon Initial"]:Clone()
		FlyingDragonInitial.PlayOnRemove = true
		FlyingDragonInitial.Parent = Character.PrimaryPart
		FlyingDragonInitial:Destroy()
		FlyingDragonInitial = nil
		
		local CatchingDragonImpact = HakudaEffects["Catching Dragon Impact"]:Clone()
		CatchingDragonImpact.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		CatchingDragonImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CatchingDragonImpact, 1)
		for i, v in ipairs(CatchingDragonImpact:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(6)
			end
		end
	elseif Phase == "2" then
		local CatchingDragonRoarSound = HakudaSounds["Catching Dragon Roar"]:Clone()
		CatchingDragonRoarSound.Parent = Character.PrimaryPart
		CatchingDragonRoarSound:Play()
		Debris:AddItem(CatchingDragonRoarSound, 2)
	elseif Phase == "3" then
		local FlyingDragonImpactSound = HakudaSounds["Flying Dragon Impact"]:Clone()
		FlyingDragonImpactSound.PlayOnRemove = true
		FlyingDragonImpactSound.Parent = Target.PrimaryPart
		FlyingDragonImpactSound:Destroy()
		FlyingDragonImpactSound = nil
		
		local RP = RaycastParams.new()
		RP.FilterType = Enum.RaycastFilterType.Exclude
		RP.FilterDescendantsInstances = {workspace.Entities}
		
		local FloorCheck = workspace:Raycast(Target.HumanoidRootPart.Position, Vector3.new(0, -100, 0), RP)
		if FloorCheck then
			local FlyingDragonImpactEffect = HakudaEffects["Flying Dragon Impact Effect"]:Clone()
			FlyingDragonImpactEffect.CFrame = CFrame.new(FloorCheck.Position)
			FlyingDragonImpactEffect.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(FlyingDragonImpactEffect, 1)
			for i, v in ipairs(FlyingDragonImpactEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(1)
				end
			end

			local Origin = CFrame.new(FloorCheck.Position + Vector3.new(0, 3, 0))
			local CraterData = {
				Radius = 9,
				PartSize = 1.5,
				Duration = 3,
				DebrisData = {
					Amount = math.random(3, 5),
					Collidable = true,
					VelocityMin = 30,
					VelocityMax = 50,
				}
			}

			ImpactCrater:Crater(Character, Origin, CraterData)
		end
	elseif Phase == "4" then
		local CatchingDragonUpTrail = HakudaEffects["Catching Dragon Up Trail"]:Clone()
		CatchingDragonUpTrail.Anchored = false
		CatchingDragonUpTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CatchingDragonUpTrail, 1)

		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.0149888992, -0.0149459839, -1.72982883, 0, 0, -1, 1, 0, 0, 0, -1, 0)
		Weld.Part0 = CatchingDragonUpTrail
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = CatchingDragonUpTrail
	end
end

function ClientSkills.CatchingDragonClient(Character, Target, Duration)
	local Lighting = game:GetService("Lighting")
	TweenService:Create(Lighting, TweenInfo.new(Duration - 0.05), {ExposureCompensation = -10}):Play()
	task.delay(Duration, function()
		Lighting.ExposureCompensation = 0
	end)
	
	local CatchingDragonHighlight = Instance.new("Highlight")
	CatchingDragonHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	CatchingDragonHighlight.FillTransparency = 1
	CatchingDragonHighlight.FillColor = Color3.fromRGB(255, 255, 255)
	CatchingDragonHighlight.Parent = Character
	Debris:AddItem(CatchingDragonHighlight, Duration)
	
	local CatchingDragonHighlight2 = Instance.new("Highlight")
	CatchingDragonHighlight2.OutlineColor = Color3.fromRGB(255, 255, 255)
	CatchingDragonHighlight2.FillTransparency = 1
	CatchingDragonHighlight2.FillColor = Color3.fromRGB(255, 255, 255)
	CatchingDragonHighlight2.Parent = Target
	Debris:AddItem(CatchingDragonHighlight2, Duration)
	
	local DeathKanji = Players.LocalPlayer.PlayerGui.ScreenEffects.CatchingDragon:Clone()
	DeathKanji.ImageLabel.ImageTransparency = 1
	DeathKanji.Visible = true
	DeathKanji.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects
	Debris:AddItem(DeathKanji, 1.5)
	
	TweenService:Create(DeathKanji.UISizeConstraint, TweenInfo.new(1.5), {MaxSize = Vector2.new(750, 750)}):Play()
	TweenService:Create(DeathKanji.ImageLabel, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
	task.delay(0.2, function()
		TweenService:Create(DeathKanji.ImageLabel, TweenInfo.new(1.3), {ImageTransparency = 1}):Play()
	end)
end

function ClientSkills.ReiatsuPush(Character)
	local ReiatsuPush = HakudaEffects.ReiatsuPush:Clone()
	ReiatsuPush.Anchored = false
	ReiatsuPush.Parent = workspace.Effects[Character.Name]
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(-1.52587891e-05, 2.89999771, 3.05175781e-05, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	Weld.Part0 = ReiatsuPush
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = ReiatsuPush
	
	task.delay(0.23, function()
		local HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
		HyperArmorHighlight.Parent = Character
		Debris:AddItem(HyperArmorHighlight, 0.4)
		--0.63
	end)
	
	local ReiatsuPushInitialSound = HakudaSounds.ReiatsuPushInitial:Clone()
	ReiatsuPushInitialSound.Parent = Character.HumanoidRootPart
	ReiatsuPushInitialSound:Play()
	Debris:AddItem(ReiatsuPushInitialSound, 1)
	
	task.delay(0.63, function()
		TweenService:Create(ReiatsuPushInitialSound, TweenInfo.new(0.2), {Volume = 0}):Play()
		
		TweenService:Create(ReiatsuPush.PointLight, TweenInfo.new(1), {Brightness = 0}):Play()
		Debris:AddItem(ReiatsuPush, 1)
		
		local ReiatsuPushRelease = HakudaEffects.ReiatsuPushRelease:Clone()
		ReiatsuPushRelease.CFrame = Character.HumanoidRootPart.CFrame
		ReiatsuPushRelease.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(ReiatsuPushRelease:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(12)
			end
		end
		Debris:AddItem(ReiatsuPushRelease, 1)
		
		local ReiatsuPushReleaseSound = HakudaSounds.ReiatsuPushRelease:Clone()
		ReiatsuPushReleaseSound.PlayOnRemove = true
		ReiatsuPushReleaseSound.Parent = Character.HumanoidRootPart
		ReiatsuPushReleaseSound:Destroy()
		ReiatsuPushReleaseSound = nil
	end)
end

function ClientSkills.TripleStriker(Character, Phase)
	if Phase == "1" then
		local TripleStriker = HakudaEffects.TripleStriker.TripleStrike:Clone()
		TripleStriker.Parent = Character.HumanoidRootPart
		TripleStriker.Past:Emit(1)
		Debris:AddItem(TripleStriker, 1)		
	elseif Phase == "2" then
		local TripleStriker = HakudaEffects.TripleStriker.TripleStrike:Clone()
		TripleStriker.Parent = Character.HumanoidRootPart
		TripleStriker.Present:Emit(1)
		Debris:AddItem(TripleStriker, 1)	
	elseif Phase == "3" then
		local TripleStriker = HakudaEffects.TripleStriker.TripleStrike:Clone()
		TripleStriker.Parent = Character.HumanoidRootPart
		TripleStriker.Future:Emit(1)
		Debris:AddItem(TripleStriker, 1)
	elseif Phase == "Camera" then		
		local Camera = workspace.Camera
		local CinematicsFolder = ReplicatedStorage.Assets.SkillFrames.TripleStriker -- Frames folder
		
		local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
		Camera.CameraType = Enum.CameraType.Scriptable
		local Frame = 0
		local Connection
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			Frame += DeltaTime * 60
			local CameraFrame = CinematicsFolder:FindFirstChild(tonumber(math.ceil(Frame)))
			if CameraFrame then
				Character.Humanoid.AutoRotate = false
				Camera.CFrame = Character.HumanoidRootPart.CFrame * CameraFrame.Value
			else
				Connection:Disconnect()
				Connection = nil
				Character.Humanoid.AutoRotate = true
				Camera.CameraType = Enum.CameraType.Custom
				Camera.CFrame = CurrentCameraCFrame    
			end
		end)
	end
end

function ClientSkills.AnkleSplitter(Character, PositiveHits, Duration)
	for i, v in ipairs(PositiveHits) do
		local AnkleSplitter = HakudaEffects.AnkleSplitter:Clone()
		AnkleSplitter.Anchored = false
		AnkleSplitter.Bone1.Bone.Lifetime = NumberRange.new(Duration)
		AnkleSplitter.Bone2.Bone.Lifetime = NumberRange.new(Duration)
		AnkleSplitter.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AnkleSplitter, Duration)

		local Weld = Instance.new("Weld")
		Weld.Part0 = AnkleSplitter
		Weld.Part1 = v.HumanoidRootPart
		Weld.Parent = AnkleSplitter

		for i, v in ipairs(AnkleSplitter:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(1)
			end
		end
	end
end

function ClientSkills.Negation(Character, Counter, CounterOwner, CounterDuration, HitCounter)
	if Counter == "Counter" then
		local Negation = HakudaEffects.Negation:Clone()
		Negation.Anchored = false
		Negation.NegationPT1:Destroy()
		Negation.Parent = workspace.Effects[Character.Name]
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = Negation
		Weld.Part1 = CounterOwner.HumanoidRootPart
		Weld.Parent = Negation
		
		local NegationStanceSound = HakudaSounds.NegationStance:Clone()
		NegationStanceSound.Parent = CounterOwner.HumanoidRootPart
		NegationStanceSound:Play()
		Debris:AddItem(NegationStanceSound, CounterDuration + 0.2)
		
		task.delay(CounterDuration, function()
			for i, v in ipairs(Negation:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			Debris:AddItem(Negation, 1)
			
			TweenService:Create(NegationStanceSound, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Counter == "Countered" then
		local NegationHit = HakudaEffects.Negation.NegationPT1:Clone()
		NegationHit.Parent = CounterOwner.HumanoidRootPart
		Debris:AddItem(NegationHit, 1)
		
		for i, v in ipairs(NegationHit:GetChildren()) do
			v:Emit(1)
		end
		
		local NegationSuccessSound = HakudaSounds.NegationSuccess:Clone()
		NegationSuccessSound.PlayOnRemove = true
		NegationSuccessSound.Parent = CounterOwner.HumanoidRootPart
		NegationSuccessSound:Destroy()
		NegationSuccessSound = nil
		
		local NegationBall = HakudaEffects.NegationBall:Clone()
		NegationBall.Parent = workspace.Effects[CounterOwner.Name]
		Debris:AddItem(NegationBall, 0.53)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000164031982, 1.40622211, -0.000366210938, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = NegationBall
		Weld.Part1 = CounterOwner["Right Arm"]
		Weld.Parent = NegationBall
	elseif Counter == "NegationExplode" then
		local NegationExplosion = HakudaEffects.NegationExplosion:Clone()
		NegationExplosion.Anchored = true
		NegationExplosion.CFrame = Character.HumanoidRootPart.CFrame
		NegationExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(NegationExplosion, 1)
		
		for i, v in ipairs(NegationExplosion.Emit5:GetChildren()) do
			v:Emit(5)
		end
	elseif Counter == "Hit" then
		local BodyPart = {
			[1] = "Right Arm";
			[2] = "Left Arm";
			[3] = "Right Arm";
			[4] = "Left Leg";
			[5] = "Right Leg";
		}
		
		local NegationAirEffect = HakudaEffects.NegationAir[BodyPart[HitCounter]]:Clone()
		NegationAirEffect.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(NegationAirEffect, 1.1)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = NegationAirEffect
		Weld.Part1 = CounterOwner[BodyPart[HitCounter]]
		Weld.Parent = NegationAirEffect
		
		task.delay(0.3, function()
			for i, v in ipairs(NegationAirEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
	end
end

function ClientSkills.PantheraCombo(Character, HitCounter)
	if HitCounter == "FinalHit" then
		for i = 1, 2 do
			local PantheraClaw = HakudaEffects.PantheraClaw:Clone()
			PantheraClaw.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			if i % 2 == 0 then
				PantheraClaw.CFrame *= CFrame.Angles(0, 0, math.rad(33))
			else
				PantheraClaw.CFrame *= CFrame.Angles(0, 0, math.rad(-33))
			end
			PantheraClaw.Parent = workspace.Effects[Character.Name]	

			for i, v in ipairs(PantheraClaw:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(10)
				end
			end
			Debris:AddItem(PantheraClaw, 1)
		end
	else
		local PantheraClaw = HakudaEffects.PantheraClaw:Clone()
		PantheraClaw.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		if HitCounter % 2 == 0 then
			PantheraClaw.CFrame *= CFrame.Angles(0, 0, math.rad(33))
		else
			PantheraClaw.CFrame *= CFrame.Angles(0, 0, math.rad(-33))
		end
		PantheraClaw.Parent = workspace.Effects[Character.Name]	

		for i, v in ipairs(PantheraClaw:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end
		Debris:AddItem(PantheraClaw, 1)
	end
end

function ClientSkills.Pulse(Character, Phase, SpawnCFrame, Speed)
	if Phase == "1" then
		local PulseBall
		if Character:GetAttribute("VisoredActive") then
			PulseBall = HakudaEffects.VisoredPulseBall:Clone()
		else
			PulseBall = HakudaEffects.PulseBall:Clone()
		end
		PulseBall.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(PulseBall, 0.51)

		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.000164031982, 1.40622211, -0.000366210938, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = PulseBall
		Weld.Part1 = Character["Right Arm"]
		Weld.Parent = PulseBall
		
		local PulseStart = HakudaSounds.PulseStart:Clone()
		PulseStart.Parent = Character.HumanoidRootPart
		PulseStart:Play()
		Debris:AddItem(PulseStart, 2)
		task.delay(1.5, function()
			TweenService:Create(PulseStart, TweenInfo.new(0.5), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		if not Character:GetAttribute("VisoredActive") then
			local PulseBall = HakudaEffects.PulseBall:Clone()
			PulseBall.CFrame = SpawnCFrame
			PulseBall.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(PulseBall, 1)
		
			ClientProjectile:ProjectileStraight(Character, PulseBall, Speed)
		end
		
		local PulseRelease = HakudaSounds.PulseRelease:Clone()
		PulseRelease.PlayOnRemove = true
		PulseRelease.Parent = Character.HumanoidRootPart
		PulseRelease:Destroy()
		PulseRelease = nil
	elseif Phase == "3" then
		local PulseBall = workspace.Effects[Character.Name]:FindFirstChild("PulseBall")
		if PulseBall then
			PulseBall:Destroy()
		end
		
		local PulseExplosion
		if Character:GetAttribute("VisoredActive") then
			PulseExplosion = HakudaEffects.VisoredPulseExplosion:Clone()
		else
			PulseExplosion = HakudaEffects.PulseExplosion:Clone()
		end
		
		PulseExplosion.Anchored = true
		PulseExplosion.CFrame = SpawnCFrame
		PulseExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(PulseExplosion, 1)
		
		for i, v in ipairs(PulseExplosion:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(5)
			end
		end
	end
end

function ClientSkills.ToraReach(Character, Phase)
	local function Weld(Part0, Part1)
		local Weld = Instance.new("Weld")
		Weld.Part0 = Part0
		Weld.Part1 = Part1
		Weld.Parent = Part0
		return Weld
	end
	
	if Phase == "1" then
		local ToraRight = HakudaEffects.ToraReach["Right Leg"]:Clone()
		ToraRight.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraRight, 1.9)
		
		Weld(ToraRight, Character["Right Leg"])
		
		local ToraLeft = HakudaEffects.ToraReach["Left Leg"]:Clone()
		ToraLeft.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraLeft, 1.9)

		Weld(ToraLeft, Character["Left Leg"])
		
		task.delay(0.9, function()
			for i, v in ipairs(ToraRight:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
			for i, v in ipairs(ToraLeft:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
		
		local ToraReachSound = HakudaSounds.ToraReachStart:Clone()
		ToraReachSound.TimePosition = 0.4
		ToraReachSound.Parent = Character.HumanoidRootPart
		ToraReachSound:Play()
		Debris:AddItem(ToraReachSound, ToraReachSound.TimeLength)
	elseif Phase == "2" then
		local ToraRight = HakudaEffects.ToraReach["Right Leg"]:Clone()
		ToraRight.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraRight, 1.7)

		Weld(ToraRight, Character["Right Leg"])

		local ToraLeft = HakudaEffects.ToraReach["Left Leg"]:Clone()
		ToraLeft.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraLeft, 1.7)

		Weld(ToraLeft, Character["Left Leg"])

		task.delay(0.7, function()
			for i, v in ipairs(ToraRight:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
			for i, v in ipairs(ToraLeft:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "3" then
		local ToraLeap = HakudaEffects.ToraLeap:Clone()
		ToraLeap.Anchored = true
		ToraLeap.CFrame = Character.HumanoidRootPart.CFrame
		ToraLeap.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraLeap, 0.7)
		
		for i, v in ipairs(ToraLeap.Emit3:GetChildren()) do
			v:Emit(3)
		end
	end
end

function ClientSkills.Gehenna(Character, Phase, RootCFrame, Target)
	if Phase == "1" then
		local GehennaFX = HakudaEffects.GehennaFX:Clone()
		GehennaFX.CFrame = RootCFrame
		GehennaFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GehennaFX, 1.5)
		
		for i, v in ipairs(GehennaFX.Emit15:GetChildren()) do
			v:Emit(15)
		end
		for i, v in ipairs(GehennaFX.Emit30:GetChildren()) do
			v:Emit(30)
		end
		for i, v in ipairs(GehennaFX.Emit30a:GetChildren()) do
			v:Emit(30)
		end
		
		local GehennaPunch = HakudaSounds.GehennaPunch:Clone()
		GehennaPunch.PlayOnRemove = true
		GehennaPunch.Parent = Character.HumanoidRootPart
		GehennaPunch:Destroy()
		GehennaPunch = nil
	elseif Phase == "2" then
		local FlyingDragonImpactSound = HakudaSounds["Flying Dragon Impact"]:Clone()
		FlyingDragonImpactSound.PlayOnRemove = true
		FlyingDragonImpactSound.Parent = Target.PrimaryPart
		FlyingDragonImpactSound:Destroy()
		FlyingDragonImpactSound = nil

		local RP = RaycastParams.new()
		RP.FilterType = Enum.RaycastFilterType.Exclude
		RP.FilterDescendantsInstances = {workspace.Entities}

		local FloorCheck = workspace:Raycast(Target.HumanoidRootPart.Position, Vector3.new(0, -100, 0), RP)
		if FloorCheck then
			local FlyingDragonImpactEffect = HakudaEffects["Flying Dragon Impact Effect"]:Clone()
			FlyingDragonImpactEffect.CFrame = CFrame.new(FloorCheck.Position)
			FlyingDragonImpactEffect.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(FlyingDragonImpactEffect, 1)
			
			for i, v in ipairs(FlyingDragonImpactEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(1)
				end
			end

			local Origin = CFrame.new(FloorCheck.Position + Vector3.new(0, 3, 0))
			local CraterData = {
				Radius = 9,
				PartSize = 1.5,
				Duration = 3,
				DebrisData = {
					Amount = math.random(3, 5),
					Collidable = true,
					VelocityMin = 30,
					VelocityMax = 50,
				}
			}

			ImpactCrater:Crater(Character, Origin, CraterData)
		end
	elseif Phase == "3" then
		Character:SetAttribute("GehennaFX", true)
		
		local Shadows = 15
		local Rate = 0.1
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated > Rate then
				Accumulated -= Rate
				Shadows -= 1

				if Shadows <= 0 or not Character:FindFirstChild("HumanoidRootPart") or not Character:GetAttribute("GehennaFX") then
					Connection:Disconnect()
					Connection = nil
				end

				local Clone = SharedFunctions:CreateClone(Character, Character.HumanoidRootPart.CFrame, nil, "NoCollide")

				Clone.Head.CFrame = Character.Head.CFrame
				Clone.Torso.CFrame = Character.Torso.CFrame
				Clone["Right Leg"].CFrame = Character["Right Leg"].CFrame
				Clone["Right Arm"].CFrame = Character["Right Arm"].CFrame
				Clone["Left Leg"].CFrame = Character["Left Leg"].CFrame
				Clone["Left Arm"].CFrame = Character["Left Arm"].CFrame

				Debris:AddItem(Clone, 1)

				for i, v in pairs(Clone:GetDescendants()) do
					if v:IsA("SpecialMesh") then
						v.TextureId = ""
						v.VertexColor = color3ToVector3(Color3.fromRGB(15, 15, 15))
					elseif v:IsA("BasePart") then
						v.Color = Color3.fromRGB(50, 50, 50)
						v.CollisionGroup = "Carried"
					elseif v:IsA("BillboardGui") then
						v.Enabled = false
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
						v:Destroy()
					end
				end

				task.delay(0.5, function()
					for i, v in ipairs(Clone:GetDescendants()) do
						if v:IsA("BasePart") then
							TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
						end
					end
				end)
			end
		end)
	elseif Phase == "4" then
		Character:SetAttribute("GehennaFX", nil)
	elseif Phase == "5" then
		local GehennaKick = HakudaSounds.GehennaKick:Clone()
		GehennaKick.PlayOnRemove = true
		GehennaKick.Parent = Character.HumanoidRootPart
		GehennaKick:Destroy()
		GehennaKick = nil
	end
end

function ClientSkills.DeathFlair(Character, Phase, RootCFrame)
	if Phase == "1" then
		local function Weld(Part0, Part1)
			local Weld = Instance.new("Weld")
			Weld.Part0 = Part0
			Weld.Part1 = Part1
			Weld.Parent = Part0
			return Weld
		end
		
		local ToraRight = HakudaEffects.ToraReach["Right Leg"]:Clone()
		ToraRight.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraRight, 2.7)

		Weld(ToraRight, Character["Right Leg"])

		local ToraLeft = HakudaEffects.ToraReach["Left Leg"]:Clone()
		ToraLeft.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraLeft, 2.7)

		Weld(ToraLeft, Character["Left Leg"])

		task.delay(1.7, function()
			for i, v in ipairs(ToraRight:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
			for i, v in ipairs(ToraLeft:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "2" then
		local Clone = SharedFunctions:CreateClone(Character, Character.HumanoidRootPart.CFrame, nil, "NoCollide")

		Clone.Head.CFrame = Character.Head.CFrame
		Clone.Torso.CFrame = Character.Torso.CFrame
		Clone["Right Leg"].CFrame = Character["Right Leg"].CFrame
		Clone["Right Arm"].CFrame = Character["Right Arm"].CFrame
		Clone["Left Leg"].CFrame = Character["Left Leg"].CFrame
		Clone["Left Arm"].CFrame = Character["Left Arm"].CFrame

		Debris:AddItem(Clone, 0.8)

		for i, v in pairs(Clone:GetDescendants()) do
			if v:IsA("SpecialMesh") then
				v.VertexColor = color3ToVector3(Color3.fromRGB(15, 15, 15))
			elseif v:IsA("BasePart") then
				v.Color = Color3.fromRGB(50, 50, 50)
				v.CollisionGroup = "Carried"
			elseif v:IsA("BillboardGui") then
				v.Enabled = false
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end

		task.delay(0.4, function()
			for i, v in ipairs(Clone:GetDescendants()) do
				if v:IsA("BasePart") then
					TweenService:Create(v, TweenInfo.new(0.4), {Transparency = 1}):Play()
				end
			end
		end)
	elseif Phase == "3" then
		local DeathFlair = HakudaEffects.DeathFlair.Emit1:Clone()
		DeathFlair.Parent = Character.HumanoidRootPart
		Debris:AddItem(DeathFlair, 1)
		
		for i, v in ipairs(DeathFlair:GetChildren()) do
			v:Emit(1)
		end
		
		local DeathFlairStart = HakudaSounds.DeathFlairStart:Clone()
		DeathFlairStart.Parent = Character.HumanoidRootPart
		DeathFlairStart:Play()
		Debris:AddItem(DeathFlairStart, 1.4)
		task.delay(1, function()
			TweenService:Create(DeathFlairStart, TweenInfo.new(0.4), {Volume = 0}):Play()
		end)
	elseif Phase == "4" then
		local DeathFlair = HakudaEffects.DeathFlair:Clone()
		DeathFlair.Anchored = true
		DeathFlair.CFrame = RootCFrame
		DeathFlair.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(DeathFlair, 2)

		for i, v in ipairs(DeathFlair.Emit20:GetChildren()) do
			v:Emit(20)
		end
		for i, v in ipairs(DeathFlair.Emit30:GetChildren()) do
			v:Emit(30)
		end
		
		local DeathFlairStomp = HakudaSounds.DeathFlairStomp:Clone()
		DeathFlairStomp.PlayOnRemove = true
		DeathFlairStomp.Parent = Character.HumanoidRootPart
		DeathFlairStomp:Destroy()
		DeathFlairStomp = nil
	end
end

function ClientSkills.Shori(Character, Phase, Target)
	if Phase == "1" then
		local ShoriTeleport = HakudaEffects.ShoriTeleport:Clone()
		ShoriTeleport.CFrame = Character.HumanoidRootPart.CFrame
		ShoriTeleport.Anchored = true
		ShoriTeleport.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ShoriTeleport, 3)
		
		for i, v in ipairs(ShoriTeleport.Emit4:GetChildren()) do
			v:Emit(4)
		end
		
		local ShoriStep = HakudaSounds.ShoriStep:Clone()
		ShoriStep.PlayOnRemove = true
		ShoriStep.Parent = Character.HumanoidRootPart
		ShoriStep:Destroy()
		ShoriStep = nil
	elseif Phase == "2" then
		local ToraReachImpact = HakudaEffects.ToraImpact:Clone()
		ToraReachImpact.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(1, -2, 3)
		ToraReachImpact.Anchored = true
		ToraReachImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ToraReachImpact, 0.75)

		for i, v in ipairs(ToraReachImpact.Emit5:GetChildren()) do
			v:Emit(5)
		end

		local DebrisData = {
			Amount = math.random(3, 5),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 1.5,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Target.HumanoidRootPart.CFrame * CFrame.new(-1, 0, 5), DebrisData)
	elseif Phase == "3" then
		if Players:GetPlayerFromCharacter(Target) then
			local Shadows = 5
			local Rate = 0.1
			local Accumulated = 0
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				if Accumulated > Rate then
					Accumulated -= Rate
					Shadows -= 1

					if Shadows <= 0 then
						Connection:Disconnect()
						Connection = nil
					end

					local Clone = SharedFunctions:CreateClone(Target, Target.HumanoidRootPart.CFrame, nil, "NoCollide")
					Debris:AddItem(Clone, 1)
					Clone.Head.CFrame = Target.Head.CFrame
					Clone.Torso.CFrame = Target.Torso.CFrame
					Clone["Right Leg"].CFrame = Target["Right Leg"].CFrame
					Clone["Right Arm"].CFrame = Target["Right Arm"].CFrame
					Clone["Left Leg"].CFrame = Target["Left Leg"].CFrame
					Clone["Left Arm"].CFrame = Target["Left Arm"].CFrame

					for i, v in pairs(Clone:GetDescendants()) do
						if v:IsA("SpecialMesh") then
							v.TextureId = ""
							v.VertexColor = color3ToVector3(Color3.fromRGB(15, 15, 15))
						elseif v:IsA("BasePart") then
							v.Color = Color3.fromRGB(50, 50, 50)
						elseif v:IsA("BillboardGui") then
							v.Enabled = false
						elseif v:IsA("ParticleEmitter") then
							v.Enabled = false
						elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
							v:Destroy()
						end
					end

					task.delay(0.5, function()
						for i, v in ipairs(Clone:GetDescendants()) do
							if v:IsA("BasePart") then
								TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
							end
						end
					end)
				end
			end)
		end
	elseif Phase == "4" then
		local ShoriIndicator = HakudaEffects.ShoriIndicator.Emit5:Clone()
		ShoriIndicator.Parent = Character["Right Arm"]
		Debris:AddItem(ShoriIndicator, 0.75)
		
		for i, v in ipairs(ShoriIndicator:GetChildren()) do
			v:Emit(5)
		end
	end
end

function ClientSkills.SpineRend(Character, Phase, Target)
	if Phase == "1" then
		local SpineRend = HakudaEffects.SpineRend:Clone()
		SpineRend.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SpineRend, 2.38 + 0.5)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = SpineRend
		Weld.Part1 = Character["Right Arm"]
		Weld.Parent = SpineRend

		task.delay(2.38, function()
			for i, v in ipairs(SpineRend:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "2" then
		local SpineRendImpact = HakudaEffects.SpineRendImpact:Clone()
		SpineRendImpact.CFrame = CFrame.new(Target.Torso.Position)
		SpineRendImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(SpineRendImpact, 3)
		
		for i, v in ipairs(SpineRendImpact:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
	elseif Phase == "3" then
		local SpineRend = workspace.Effects[Character.Name]:FindFirstChild("SpineRend")
		if SpineRend then
			SpineRend:Destroy()
			SpineRend = nil
		end
	elseif Phase == "4" then
		local NegationImpact = HakudaEffects.NegationImpact:Clone()
		NegationImpact.Anchored = true
		NegationImpact.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Target.Torso.Position) * CFrame.Angles(0, math.pi, 0)
		NegationImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(NegationImpact, 0.8)

		for i, v in ipairs(NegationImpact.Emit5:GetChildren()) do
			v:Emit(5)
		end
	end
end

--==================================================
--=====================Special======================
--==================================================

function ClientSkills.Senkaimon(Character)

end

function ClientSkills.Garganta(Character)

end

function ClientSkills.SenkaimonBreak(Character, Time)
	local Player = Players.LocalPlayer
	local ScreenEffects = Player.PlayerGui:FindFirstChild("ScreenEffects")
	if ScreenEffects then
		local ItemFrames = {}
		for i, v in ipairs(ScreenEffects:GetChildren()) do
			if v.Name == "GateFrame" then
				table.insert(ItemFrames, v)
			end
		end
		for i, v in ipairs(ItemFrames) do
			local Position = v.Position
			TweenService:Create(v, TweenInfo.new(0.5), {Position = UDim2.new(Position.X.Scale, Position.X.Offset, Position.Y.Scale - 0.03, Position.Y.Offset)}):Play()
		end
		ItemFrames = nil

		local ItemFrame = Player.PlayerGui.ScreenEffects.ResetTimer:Clone()
		ItemFrame.Name = "GateFrame"
		ItemFrame.TextLabel.Text = Time .. " minutes until break is available."
		ItemFrame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ItemFrame.TextLabel.TextTransparency = 1
		ItemFrame.TextLabel.TextStrokeTransparency = 1
		ItemFrame.Visible = true
		ItemFrame.ZIndex = 6
		ItemFrame.Parent = Player.PlayerGui.ScreenEffects
		Debris:AddItem(ItemFrame, 2.5)	

		TweenService:Create(ItemFrame.TextLabel, TweenInfo.new(0.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
		task.delay(2, function()
			if ItemFrame and ItemFrame.Parent then
				TweenService:Create(ItemFrame.TextLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
		end)
	end
end

function ClientSkills.GargantaBreak(Character, Time)
	local Player = Players.LocalPlayer
	local ScreenEffects = Player.PlayerGui:FindFirstChild("ScreenEffects")
	if ScreenEffects then
		local ItemFrames = {}
		for i, v in ipairs(ScreenEffects:GetChildren()) do
			if v.Name == "GateFrame" then
				table.insert(ItemFrames, v)
			end
		end
		for i, v in ipairs(ItemFrames) do
			local Position = v.Position
			TweenService:Create(v, TweenInfo.new(0.5), {Position = UDim2.new(Position.X.Scale, Position.X.Offset, Position.Y.Scale - 0.03, Position.Y.Offset)}):Play()
		end
		ItemFrames = nil

		local ItemFrame = Player.PlayerGui.ScreenEffects.ResetTimer:Clone()
		ItemFrame.Name = "GateFrame"
		ItemFrame.TextLabel.Text = Time .. " minutes until break is available."
		ItemFrame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ItemFrame.TextLabel.TextTransparency = 1
		ItemFrame.TextLabel.TextStrokeTransparency = 1
		ItemFrame.Visible = true
		ItemFrame.ZIndex = 6
		ItemFrame.Parent = Player.PlayerGui.ScreenEffects
		Debris:AddItem(ItemFrame, 2.5)	

		TweenService:Create(ItemFrame.TextLabel, TweenInfo.new(0.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
		task.delay(2, function()
			if ItemFrame and ItemFrame.Parent then
				TweenService:Create(ItemFrame.TextLabel, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
		end)
	end
end

function ClientSkills.Kneel(Character, Duration)
	local Windup = 0.4
	local Info = TweenInfo.new(Windup / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

	for i = 1, 2 do
		local ColorCorrection = Instance.new("ColorCorrectionEffect")
		ColorCorrection.Contrast = 0
		ColorCorrection.Parent = Lighting
		TweenService:Create(ColorCorrection, Info, {Contrast = -1}):Play()
		Debris:AddItem(ColorCorrection, Duration + (Windup * 2) / 3)

		task.delay(Duration, function()
			TweenService:Create(ColorCorrection, Info, {Contrast = 0}):Play()
		end)
	end
	
	local ZaWater = ReplicatedStorage.Assets.Sounds["za water"]:Clone()
	ZaWater.PlayOnRemove = true
	ZaWater.Parent = workspace.Effects[Character.Name]
	ZaWater:Destroy()
	ZaWater = nil
end

function ClientSkills.Teleport(Character)
	
end

function ClientSkills.Command(Character)

end

function ClientSkills.EspadaCommand(Character)
	
end

function ClientSkills.SpiritualPressure(Character)
	local Effects = ReplicatedStorage.Assets.Effects
	local Sounds = ReplicatedStorage.Assets.Sounds
	
	local Duration = 9
	
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

	local SpiritualPressure = Sounds.SpiritualPressure:Clone()
	SpiritualPressure.Parent = workspace.Effects[Character.Name]
	SpiritualPressure:Play()
	Debris:AddItem(SpiritualPressure, Duration)

	local Heartbeat = Sounds.Heartbeat:Clone()
	Heartbeat.Parent = workspace.Effects[Character.Name]
	Heartbeat:Play()
	Debris:AddItem(Heartbeat, Duration)

	local function RandomNumber()
		local Min, Max = 0, 1
		local RNG = Random.new()
		return RNG:NextNumber(Min, Max)
	end
	
	local Time = Duration
	local Speed = 0.4
	local Rate = 0.03
	local Accumulated = 0
	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		
		if Time <= 0 then
			Connection:Disconnect()
			Connection = nil
		end
		
		if Accumulated > Rate then
			Accumulated -= Rate
			Time -= Rate

			if Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenEffects") then
				local SelectedNumber = math.random(1, 2)

				local SpiritualPressureLine = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
				local X = RandomNumber()
				SpiritualPressureLine.Position = UDim2.new(X, 0, -0.2, 0)
				SpiritualPressureLine.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
				Debris:AddItem(SpiritualPressureLine, Speed)
				TweenService:Create(SpiritualPressureLine, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, 1.2, 0)}):Play()

				local SpiritualPressureLine2 = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
				local X = RandomNumber()
				SpiritualPressureLine2.Position = UDim2.new(X, 0, 1.2, 0)
				SpiritualPressureLine2.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
				Debris:AddItem(SpiritualPressureLine2, Speed)
				TweenService:Create(SpiritualPressureLine2, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, -0.2, 0)}):Play()
			end
		end
	end)	

	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)

	camShake:Start()
	camShake:Shake(CameraShaker.Presets.SpiritualPressure)

	task.delay(Duration - 1, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)

	task.delay(Duration - 2, function()
		TweenService:Create(Heartbeat, TweenInfo.new(2), {Volume = 0}):Play()
		TweenService:Create(SpiritualPressure, TweenInfo.new(2), {Volume = 0}):Play()
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

function ClientSkills.SpiritualPressureMini(Character)
	local Effects = ReplicatedStorage.Assets.Effects
	local Sounds = ReplicatedStorage.Assets.Sounds

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

	local SpiritualPressure = Sounds.SpiritualPressure:Clone()
	SpiritualPressure.Parent = workspace.Effects[Character.Name]
	SpiritualPressure:Play()
	Debris:AddItem(SpiritualPressure, Duration)

	local Heartbeat = Sounds.Heartbeat:Clone()
	Heartbeat.Parent = workspace.Effects[Character.Name]
	Heartbeat:Play()
	Debris:AddItem(Heartbeat, Duration)

	local function RandomNumber()
		local Min, Max = 0, 1
		local RNG = Random.new()
		return RNG:NextNumber(Min, Max)
	end

	local Time = Duration - 1
	local Speed = 0.4
	local Rate = 0.03
	local Accumulated = 0
	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		
		if Time <= 0 then
			Connection:Disconnect()
			Connection = nil
		end
		
		if Accumulated > Rate then
			Accumulated -= Rate
			Time -= Rate

			if Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenEffects") then
				local SelectedNumber = math.random(1, 2)

				local SpiritualPressureLine = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
				local X = RandomNumber()
				SpiritualPressureLine.Position = UDim2.new(X, 0, -0.2, 0)
				SpiritualPressureLine.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
				Debris:AddItem(SpiritualPressureLine, Speed)
				TweenService:Create(SpiritualPressureLine, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, 1.2, 0)}):Play()

				local SpiritualPressureLine2 = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
				local X = RandomNumber()
				SpiritualPressureLine2.Position = UDim2.new(X, 0, 1.2, 0)
				SpiritualPressureLine2.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
				Debris:AddItem(SpiritualPressureLine2, Speed)
				TweenService:Create(SpiritualPressureLine2, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, -0.2, 0)}):Play()
			end
		end
	end)	

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
		TweenService:Create(SpiritualPressure, TweenInfo.new(2), {Volume = 0}):Play()
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

function ClientSkills.Kurohitsugi(Character, Phase, Target, Speed, PositiveHits, Duration)
	if Phase == "0" then
		local KurohitsugiStartup = SpecialEffects.KurohitsugiStartup:Clone()
		KurohitsugiStartup.Anchored = false
		KurohitsugiStartup.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(KurohitsugiStartup, 4)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.0237731934, 1.5, -0.0505371094, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = KurohitsugiStartup
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = KurohitsugiStartup
		
		if Target then
			for i, v in ipairs(KurohitsugiStartup.Emit1:GetChildren()) do
				v.Lifetime = NumberRange.new(7)
			end
		end
		
		KurohitsugiStartup.Emit1Flipbook.ParticleEmitter:Emit(1)
		for i, v in ipairs(KurohitsugiStartup.Emit1:GetChildren()) do
			v:Emit(1)
		end
		for i, v in ipairs(KurohitsugiStartup.Emit30:GetChildren()) do
			v:Emit(30)
		end
		
		local StartupAudio = SpecialSounds.KurohitsugiStartup:Clone()
		StartupAudio.PlayOnRemove = true
		StartupAudio.Parent = Character.HumanoidRootPart
		StartupAudio:Destroy()
		StartupAudio = nil
	elseif Phase == "1" then
		local Offset = CFrame.new(0.00396728516, 4.6836009, 0.514587402, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local Duration = Speed - 0.6
		
		local Kurohitsugi = SpecialEffects.KurohitsugiBig:Clone()
		Kurohitsugi:PivotTo(Target.HumanoidRootPart.CFrame * Offset)
		Kurohitsugi.Parent = workspace.Effects[Character.Name]
		
		local KurohitsugiHighlight = Instance.new("Highlight")
		KurohitsugiHighlight.OutlineColor = Color3.fromRGB(191, 0, 191)
		KurohitsugiHighlight.FillTransparency = 1
		KurohitsugiHighlight.FillColor = Color3.fromRGB(122, 0, 122)
		KurohitsugiHighlight.OutlineTransparency = 0
		KurohitsugiHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		KurohitsugiHighlight.Adornee = Kurohitsugi
		KurohitsugiHighlight.Parent = Kurohitsugi
		
		for i, v in ipairs(Kurohitsugi:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
		Debris:AddItem(Kurohitsugi, Duration + 2.5)
		
		local DissipateAudio = SpecialSounds.KurohitsugiDissipate:Clone()
		DissipateAudio.PlayOnRemove = true
		DissipateAudio.Volume = 6
		DissipateAudio.Parent = Target.HumanoidRootPart
		DissipateAudio:Destroy()
		DissipateAudio = nil
		
		local KuroPressure = SpecialEffects.KuroPressure:Clone()
		KuroPressure.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(-0.0670166016, -15.0089817, 1.26293945, 1, 0, 0, 0, 0, 1, 0, -1, 0)
		KuroPressure.Parent = Kurohitsugi
		
		local BuildSpeed = Duration / 24 --0.06
		local function Build(Model)
			for i = 1, #Model:GetChildren() do
				Model[tostring(i)].Transparency = 0
				task.wait(BuildSpeed)
			end
		end
		local function Desconstruct(Model)
			for i = #Model:GetChildren(), 1, -1 do
				Model[tostring(i)].Transparency = 1
				task.wait(BuildSpeed)
			end
		end
		local function Indicator(Model)
			for i, v in ipairs(Model:GetChildren()) do
				if v:IsA("BasePart") then
					v.Color = Color3.fromRGB(44, 22, 71)
					task.delay(0.1, function()
						v.Color = Color3.fromRGB(0, 0, 0)
					end)
				end
			end
		end

		Kurohitsugi.Bottom.Transparency = 0
		for _, v in ipairs(Kurohitsugi:GetChildren()) do
			if v:IsA("Model") and v.Name ~= "Swords" then
				coroutine.wrap(Build)(v)
			end
		end
		--[[task.delay(Duration + 0.3, function()
			for _, v in ipairs(Kurohitsugi:GetChildren()) do
				if v:IsA("Model") and v.Name ~= "Swords" then
					coroutine.wrap(Indicator)(v)
				end
			end
		end)]]
		task.delay(Duration, function()
			Kurohitsugi.Top.Transparency = 0

			for _, v in ipairs(Kurohitsugi.Swords:GetChildren()) do
				TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 0}):Play()
				task.delay(0.3, function()
					TweenService:Create(v, TweenInfo.new(0.2), {CFrame = v.CFrame * CFrame.new(0, 5, 0)}):Play()
					task.delay(0.19, function()
						TweenService:Create(v, TweenInfo.new(0.1), {CFrame = v.CFrame * CFrame.new(0, -15, 0)}):Play()
						
						
						task.wait(0.5)
						
						for i, v in ipairs(KuroPressure:GetChildren()) do
							v.Enabled = false
						end
						
						Kurohitsugi.Bottom.Transparency = 1
						Kurohitsugi.Top.Transparency = 1

						for _, v in ipairs(Kurohitsugi.Swords:GetChildren()) do
							if v:IsA("BasePart") then
								TweenService:Create(v, TweenInfo.new(0.1), {Transparency = 1}):Play()
							end
						end
						
						task.wait(0.1)
						
						for _, v in ipairs(Kurohitsugi:GetDescendants()) do
							if v:IsA("BasePart") then
								TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 1}):Play()
							end
						end
					end)
				end)
			end
		end)
	elseif Phase == "2" then
		local Offset = CFrame.new(0.00109863281, 3.13934183, 0.10144043, -0.99999994, 0, 0, 0, 1, 0, 0, 0, -1)
		local Duration = Speed - 0.6
		
		local Kurohitsugi = SpecialEffects.Kurohitsugi:Clone()
		Kurohitsugi:PivotTo(Target.HumanoidRootPart.CFrame * Offset)
		Kurohitsugi.Parent = workspace.Effects[Character.Name]
		
		local KurohitsugiHighlight = Instance.new("Highlight")
		KurohitsugiHighlight.OutlineColor = Color3.fromRGB(191, 0, 191)
		KurohitsugiHighlight.FillTransparency = 1
		KurohitsugiHighlight.FillColor = Color3.fromRGB(122, 0, 122)
		KurohitsugiHighlight.OutlineTransparency = 0
		KurohitsugiHighlight.Adornee = Kurohitsugi
		KurohitsugiHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		KurohitsugiHighlight.Parent = Kurohitsugi
		
		for i, v in ipairs(Kurohitsugi:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
		Debris:AddItem(Kurohitsugi, Duration + 2.5)
		
		local DissipateAudio = SpecialSounds.KurohitsugiDissipate:Clone()
		DissipateAudio.PlayOnRemove = true
		DissipateAudio.Parent = Target.HumanoidRootPart
		DissipateAudio:Destroy()
		DissipateAudio = nil
		
		local KuroPressure = SpecialEffects.KuroPressureSmall:Clone()
		KuroPressure.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0.0896606445, -8.59939289, 0.187408447, -0.99999994, 0, 0, 0, 0, 1, 0, 1, 0)
		KuroPressure.Parent = Kurohitsugi

		local BuildSpeed = Duration / 24 --0.06
		local function Build(Model)
			for i = 1, #Model:GetChildren() do
				Model[tostring(i)].Transparency = 0
				task.wait(BuildSpeed)
			end
		end
		local function Indicator(Model)
			for i, v in ipairs(Model:GetChildren()) do
				if v:IsA("BasePart") then
					v.Color = Color3.fromRGB(44, 22, 71)
					task.delay(0.1, function()
						v.Color = Color3.fromRGB(0, 0, 0)
					end)
				end
			end
		end
		
		Kurohitsugi.Bottom.Transparency = 0
		for _, v in ipairs(Kurohitsugi:GetChildren()) do
			if v:IsA("Model") and v.Name ~= "Swords" then
				coroutine.wrap(Build)(v)
			end
		end
		--[[task.delay(Duration + 0.3, function()
			for _, v in ipairs(Kurohitsugi:GetChildren()) do
				if v:IsA("Model") and v.Name ~= "Swords" then
					coroutine.wrap(Indicator)(v)
				end
			end
		end)]]
		task.delay(Duration, function()
			Kurohitsugi.Top.Transparency = 0
			
			for _, v in ipairs(Kurohitsugi.Swords:GetChildren()) do
				TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 0}):Play()
				task.delay(0.3, function()
					TweenService:Create(v, TweenInfo.new(0.2), {CFrame = v.CFrame * CFrame.new(0, 5, 0)}):Play()
					task.delay(0.19, function()
						TweenService:Create(v, TweenInfo.new(0.1), {CFrame = v.CFrame * CFrame.new(0, -15, 0)}):Play()
						
						task.wait(0.5)
						
						for i, v in ipairs(KuroPressure:GetChildren()) do
							v.Enabled = false
						end
						
						Kurohitsugi.Bottom.Transparency = 1
						Kurohitsugi.Top.Transparency = 1
						for _, v in ipairs(Kurohitsugi.Swords:GetChildren()) do
							if v:IsA("BasePart") then
								TweenService:Create(v, TweenInfo.new(0.1), {Transparency = 1}):Play()
							end
						end
						
						task.wait(0.1)
						
						for _, v in ipairs(Kurohitsugi:GetDescendants()) do
							if v:IsA("BasePart") then
								TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 1}):Play()
							end
						end
					end)
				end)
			end
		end)
	elseif Phase == "4" then
		local KurohitsugiAura = SpecialEffects.KurohitsugiAura:Clone()
		KurohitsugiAura.Anchored = false
		KurohitsugiAura.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(KurohitsugiAura, 20)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = KurohitsugiAura
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = KurohitsugiAura
	elseif Phase == "5" then
		local KurohitsugiAura = workspace.Effects[Character.Name]:FindFirstChild("KurohitsugiAura")
		if KurohitsugiAura then
			for i, v in ipairs(KurohitsugiAura:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			Debris:AddItem(KurohitsugiAura, 2)
		end
	elseif Phase == "6" then
		if PositiveHits and #PositiveHits > 0 then
			for i, v in ipairs(PositiveHits) do
				local ReiatsuSealed = KidoEffects.ReiatsuSealed:Clone()
				ReiatsuSealed.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(ReiatsuSealed, Duration + 3)

				local Weld = Instance.new("Weld")
				Weld.C0 = CFrame.new(0, -3.3135407, 0, 1, -1.50995788e-07, -1.52858448e-07, -1.50995803e-07, -0.999999881, 2.30809854e-14, -1.52858448e-07, 0, -1)
				Weld.Part0 = ReiatsuSealed
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = ReiatsuSealed

				task.delay(Duration, function()
					for i, v in ipairs(ReiatsuSealed:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
				end)
			end
		end
	end
end

function ClientSkills.EyepatchRemovalTheme(Character)
	local Eyepatch = SpecialEffects.KenpachiEyepatch:Clone()
	Eyepatch.Anchored = false
	Eyepatch.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(Eyepatch, 4)
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(-0.000457763672, -0.138972759, 1.52587891e-05, 1, 0, 0, 0, 0.999997139, 0, 0, 0, 1)
	Weld.Part0 = Eyepatch
	Weld.Part1 = Character.Head
	Weld.Parent = Eyepatch
	
	local EyepatchTheme = SpecialSounds.EyepatchTheme:Clone()
	EyepatchTheme.Parent = Character.HumanoidRootPart
	EyepatchTheme:Play()
	Debris:AddItem(EyepatchTheme, EyepatchTheme.TimeLength)
	
	task.delay(EyepatchTheme.TimeLength - 0.3, function()
		TweenService:Create(EyepatchTheme, TweenInfo.new(0.3), {Volume = 0}):Play()
	end)
end

function ClientSkills.EyepatchRemoval(Character, Duration)
	local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
	if Weapon then
		for i, v in ipairs(Weapon:GetDescendants()) do
			if v:IsA("BasePart") and v.Name == "WeaponAura" then
				for _, Particle in ipairs(SpecialEffects.EyepatchRemovalWeapon:GetChildren()) do
					local WeaponParticle = Particle:Clone()
					WeaponParticle.Parent = v
					Debris:AddItem(WeaponParticle, Duration)
				end
			end
		end
	end
	
	local KenpachiEyepatch = workspace.Effects[Character.Name]:FindFirstChild("KenpachiEyepatch")
	if KenpachiEyepatch then
		KenpachiEyepatch.Anchored = false
		KenpachiEyepatch.Weld:Destroy()
		
		local EyeWeld = Instance.new("Weld")
		EyeWeld.C0 = CFrame.new(0.383758545, 0.979400635, -0.19708252, 0.956080675, 0.293103576, 0, -0.293103576, 0.956080675, 0, 0, 0, 1)
		EyeWeld.Part0 = KenpachiEyepatch
		EyeWeld.Part1 = Character["Left Arm"]
		EyeWeld.Parent = KenpachiEyepatch
		
		task.delay(0.4, function()
			EyeWeld:Destroy()
			KenpachiEyepatch.CanCollide = true
		end)
	end
	
	local EyepatchEyes = SpecialEffects.EyepatchEyes:Clone()
	EyepatchEyes.Anchored = false
	EyepatchEyes.Parent = Character
	
	local YellowEyesWeld = Instance.new("Weld")
	YellowEyesWeld.Part0 = EyepatchEyes
	YellowEyesWeld.Part1 = Character.Head
	YellowEyesWeld.Parent = EyepatchEyes
	
	local EyepatchRemoval = SpecialEffects.EyepatchRemoval:Clone()
	EyepatchRemoval.Anchored = false
	EyepatchRemoval.Parent = Character
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(-0.0309143066, 2.86794281, 0.0616455078, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	Weld.Part0 = EyepatchRemoval
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = EyepatchRemoval
	
	local EyepatchRemoval2 = SpecialEffects.EyepatchRemoval2:Clone()
	EyepatchRemoval2.Anchored = false
	EyepatchRemoval2.Parent = Character
	
	local Weld2 = Instance.new("Weld")
	Weld2.Part0 = EyepatchRemoval2
	Weld2.Part1 = Character.HumanoidRootPart
	Weld2.Parent = EyepatchRemoval2
	
	local Disconnect
	local Time = Duration
	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Time -= DeltaTime

		if not Character or not Character:FindFirstChild("HumanoidRootPart") then
			Connection:Disconnect()
			Connection = nil
			return
		end

		if Time <= 0 then
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			
			Character:SetAttribute("EyepatchRemoved", nil)

			EyepatchEyes:Destroy()
			EyepatchRemoval:Destroy()
			EyepatchRemoval2:Destroy()
		end
	end)
end

function ClientSkills.Mashallah(Character, Duration)
	local MashallahExplosion = SpecialEffects.MashallahExplosion.Emit33:Clone()
	MashallahExplosion.Parent = Character.HumanoidRootPart
	Debris:AddItem(MashallahExplosion, 2)
	
	for i, v in ipairs(MashallahExplosion:GetChildren()) do
		v:Emit(33)
	end
	
	local MashallahActivateSound = SpecialSounds.MashallahActivate:Clone()
	MashallahActivateSound.PlayOnRemove = true
	MashallahActivateSound.Parent = Character.HumanoidRootPart
	MashallahActivateSound:Destroy()
	MashallahActivateSound = nil
	
	local Particles = {}
	
	local MashallahSound = SpecialSounds.Mashallah:Clone()
	MashallahSound.Parent = Character.HumanoidRootPart
	MashallahSound:Play()
	
	for i, v in ipairs(Character:GetChildren()) do
		for _, MashallahParticle in ipairs(SpecialEffects.Mashallah:GetChildren()) do
			local Particle = MashallahParticle:Clone()
			Particle.Parent = v
			table.insert(Particles, Particle)
		end
	end
	
	local Disconnect
	local Time = Duration
	local Connection
	Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Time -= DeltaTime

		if not Character or not Character:FindFirstChild("HumanoidRootPart") then
			Connection:Disconnect()
			Connection = nil
			return
		end

		if Time <= 0 then
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			
			MashallahSound:Stop()
			MashallahSound:Destroy()
			MashallahSound = nil
			
			for i, v in ipairs(Particles) do
				v:Destroy()
				v = nil
			end
			Particles = nil
		end
	end)
end

function ClientSkills.Voltage(Character, Phase, Target)
	if Phase == "1" then
		local VoltTrail = SpecialEffects.VoltageTrail:Clone()
		VoltTrail.Anchored = false
		VoltTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(VoltTrail, 20)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = VoltTrail
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = VoltTrail
		
		local VoltageStartup = SpecialSounds.VoltageStartup:Clone()
		VoltageStartup.PlayOnRemove = true
		VoltageStartup.Parent = Character.HumanoidRootPart
		VoltageStartup:Destroy()
		VoltageStartup = nil
	elseif Phase == "2" then
		local VoltageGrabImpact = SpecialEffects.VoltageGrabImpact:Clone()
		VoltageGrabImpact.Anchored = false
		VoltageGrabImpact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(VoltageGrabImpact, 1)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = VoltageGrabImpact
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = VoltageGrabImpact
		
		for i, v in ipairs(VoltageGrabImpact.Emit20:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			end
		end
		for i, v in ipairs(VoltageGrabImpact.Emit5:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(5)
			end
		end
		for i, v in ipairs(VoltageGrabImpact.Emit60:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(60)
			end
		end
		
		local VoltageSlam = SpecialSounds.VoltageSlam:Clone()
		VoltageSlam.PlayOnRemove = true
		VoltageSlam.Parent = Target.HumanoidRootPart
		VoltageSlam:Destroy()
		VoltageSlam = nil

		local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
		GSCritEffect.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
		GSCritEffect.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
			v:Emit(50)
		end
		Debris:AddItem(GSCritEffect, 1.5)

		local Origin = Target.PrimaryPart.CFrame
		local CraterData = {
			Radius = 6,
			PartSize = 1.5,
			Duration = 3,
			DebrisData = {
				Amount = math.random(3, 5),
				Collidable = true,
				VelocityMin = 30,
				VelocityMax = 50,
			}
		}

		ImpactCrater:Crater(Character, Origin, CraterData)
		
		for i = 1, 3 do
			local VoltageStack = SpecialEffects.VoltageStack.LightningStack
			for _, v in ipairs(Target:GetChildren()) do
				if v:IsA("BasePart") then
					local Particle = VoltageStack:Clone()
					Particle.Name = "VoltageStackEffect"
					Particle.Parent = v
				end
			end
		end
	elseif Phase == "3" then		
		local VoltageCurrent = SpecialSounds.VoltageCurrent:Clone()
		VoltageCurrent.PlayOnRemove = true
		VoltageCurrent.Parent = Character.HumanoidRootPart
		VoltageCurrent:Destroy()
		VoltageCurrent = nil
	elseif Phase == "4" then
		local VoltTrail = workspace.Effects[Character.Name]:FindFirstChild("VoltageTrail")
		if VoltTrail then
			VoltTrail.VoltTrail.Enabled = false
			Debris:AddItem(VoltTrail, 1)
		end
	end
end

function ClientSkills.AftershockCharge(Character, Phase)
	if Phase == "1" then
		local RightArmOffset = CFrame.new(0.032989502, 0.902121067, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)
		local LeftArmOffset = CFrame.new(-0.0339508057, 0.898052931, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)

		local LeftSphere = SpecialEffects.AftershockSpheres.LSphere:Clone()
		LeftSphere.Name = "AftershockCharge"
		LeftSphere.Anchored = false
		LeftSphere.CFrame = Character.HumanoidRootPart.CFrame * LeftArmOffset
		LeftSphere.Transparency = 1
		LeftSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 20)

		local Weld = Instance.new("Weld")
		Weld.C0 = LeftArmOffset
		Weld.Part0 = LeftSphere
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = LeftSphere

		local RightSphere = SpecialEffects.AftershockSpheres.RSphere:Clone()
		RightSphere.Name = "AftershockCharge"
		RightSphere.Anchored = false
		RightSphere.CFrame = Character.HumanoidRootPart.CFrame * RightArmOffset
		RightSphere.Transparency = 1
		RightSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 20)

		local Weld2 = Instance.new("Weld")
		Weld2.C0 = RightArmOffset
		Weld2.Part0 = RightSphere
		Weld2.Part1 = Character["Right Arm"]
		Weld2.Parent = RightSphere

		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(LeftSphere, Info, {Transparency = 0}):Play()
		TweenService:Create(RightSphere, Info, {Transparency = 0}):Play()
		
		local AftershockWindup = SpecialSounds.AftershockWindup:Clone()
		AftershockWindup.PlayOnRemove = true
		AftershockWindup.Parent = Character.HumanoidRootPart
		AftershockWindup:Destroy()
		AftershockWindup = nil

		local AftershockCharge = SpecialSounds.AftershockCharge:Clone()
		AftershockCharge.Name = "AftershockChargingSound"
		AftershockCharge.Parent = Character.HumanoidRootPart
		AftershockCharge:Play()
		Debris:AddItem(AftershockCharge, 20)
	elseif Phase == "2" then
		for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
			if v:IsA("BasePart") and v.Name == "AftershockCharge" then
				for _, Particle in ipairs(v.Attachment:GetChildren()) do
					Particle.Enabled = false
				end

				local Info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				TweenService:Create(v, Info, {Transparency = 1}):Play()
				Debris:AddItem(v, 1)
			end
		end
		
		local AftershockChargeSound = Character.HumanoidRootPart:FindFirstChild("AftershockChargingSound")
		if AftershockChargeSound then
			TweenService:Create(AftershockChargeSound, TweenInfo.new(0.2), {Volume = 0}):Play()
			Debris:AddItem(AftershockChargeSound, 0.2)
		end
	end
end

function ClientSkills.Aftershock(Character, Phase, Range)
	if Phase == "1" then
		local HyperArmorHighlight = ReplicatedStorage.Assets.Effects.HyperArmorHighlight:Clone()
		HyperArmorHighlight.Parent = Character
		Debris:AddItem(HyperArmorHighlight, 1.55)
		
		local RightArmOffset = CFrame.new(0.032989502, 0.902121067, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)
		local LeftArmOffset = CFrame.new(-0.0339508057, 0.898052931, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)
		
		local LeftSphere = SpecialEffects.AftershockSpheres.LSphere:Clone()
		LeftSphere.Anchored = false
		LeftSphere.CFrame = Character.HumanoidRootPart.CFrame * LeftArmOffset
		LeftSphere.Transparency = 1
		LeftSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 4)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = LeftArmOffset
		Weld.Part0 = LeftSphere
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = LeftSphere
		
		local RightSphere = SpecialEffects.AftershockSpheres.RSphere:Clone()
		RightSphere.Anchored = false
		RightSphere.CFrame = Character.HumanoidRootPart.CFrame * RightArmOffset
		RightSphere.Transparency = 1
		RightSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 4)
		
		local Weld2 = Instance.new("Weld")
		Weld2.C0 = RightArmOffset
		Weld2.Part0 = RightSphere
		Weld2.Part1 = Character["Right Arm"]
		Weld2.Parent = RightSphere
		
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(LeftSphere, Info, {Transparency = 0}):Play()
		TweenService:Create(RightSphere, Info, {Transparency = 0}):Play()
		
		task.delay(1, function()
			for i, v in ipairs(LeftSphere.Attachment:GetChildren()) do
				v.Enabled = false
			end
			for i, v in ipairs(RightSphere.Attachment:GetChildren()) do
				v.Enabled = false
			end
			
			local Info2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(LeftSphere, Info2, {Transparency = 1}):Play()
			TweenService:Create(RightSphere, Info2, {Transparency = 1}):Play()
		end)
		
		local AftershockWindup = SpecialSounds.AftershockWindup:Clone()
		AftershockWindup.PlayOnRemove = true
		AftershockWindup.Parent = Character.HumanoidRootPart
		AftershockWindup:Destroy()
		AftershockWindup = nil
		
		local AftershockCharge = SpecialSounds.AftershockCharge:Clone()
		AftershockCharge.Parent = Character.HumanoidRootPart
		AftershockCharge:Play()
		Debris:AddItem(AftershockCharge, 1.2)
		task.delay(1, function()
			TweenService:Create(AftershockCharge, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local RightOffset = CFrame.new(7.09069824, 0.356206417, -0.0108947754, -4.37113883e-08, 0, 1, -1.31130219e-06, 1, -5.73188415e-14, -1, -1.31130264e-06, -4.37113883e-08)
		local LeftOffset = CFrame.new(-7.09069824, 0.162072897, 0.0340270996, 0, 0, 1, -1.31130219e-06, 1, 0, -1, -1.31130264e-06, 0)
		
		local LeftAftershock = SpecialEffects.AftershockCrack.LCrack:Clone()
		LeftAftershock.CFrame = Character.HumanoidRootPart.CFrame * LeftOffset
		LeftAftershock.Transparency = 1
		LeftAftershock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftAftershock, 4)
		
		local RightAftershock = SpecialEffects.AftershockCrack.RCrack:Clone()
		RightAftershock.CFrame = Character.HumanoidRootPart.CFrame * RightOffset
		RightAftershock.Transparency = 1
		RightAftershock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(RightAftershock, 4)
		
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(LeftAftershock, Info, {Transparency = 0}):Play()
		TweenService:Create(RightAftershock, Info, {Transparency = 0}):Play()
		task.delay(3, function()
			TweenService:Create(LeftAftershock, TweenInfo.new(1), {Transparency = 1}):Play()
			TweenService:Create(RightAftershock, TweenInfo.new(1), {Transparency = 1}):Play()
		end)
		
		local CraterData = {
			CanCollide = true,
			Radius = Range,
			PartSize = 6,
			SizeMin = 0,
			SizeMax = 2,
			Duration = 7,
		}
		
		ImpactCrater:CircleCrater(Character, Character.HumanoidRootPart.CFrame, CraterData)
		
		local DebrisData = {
			Amount = math.random(15, 20),
			Collidable = true,
			VelocityMin = 70,
			VelocityMax = 100,
			PartSize = 3,
			PartMin = -1.5,
			PartMax = 1.5,
			Duration = 5,
			RandomMin = -Range,
			RandomMax = Range,
		}

		ImpactCrater:RandomDebris(Character, Character.HumanoidRootPart.CFrame, DebrisData)
		
		local AftershockWindup = SpecialSounds.AftershockWindup:Clone()
		AftershockWindup.PlayOnRemove = true
		AftershockWindup.Parent = Character.HumanoidRootPart
		AftershockWindup:Destroy()
		AftershockWindup = nil
		
		local AftershockShatter = SpecialSounds.AftershockShatter:Clone()
		AftershockShatter.PlayOnRemove = true
		AftershockShatter.Parent = LeftAftershock
		AftershockShatter:Destroy()
		AftershockShatter = nil
		
		local AftershockShatter2 = SpecialSounds.AftershockShatter:Clone()
		AftershockShatter2.PlayOnRemove = true
		AftershockShatter2.Parent = RightAftershock
		AftershockShatter2:Destroy()
		AftershockShatter2 = nil
	elseif Phase == "3" then
		local AftershockSmoke = SpecialEffects.AftershockSmoke:Clone()
		AftershockSmoke.CFrame = Range.HumanoidRootPart.CFrame
		AftershockSmoke.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AftershockSmoke, 5)
		
		for i, v in ipairs(AftershockSmoke.Emit100:GetChildren()) do
			v:Emit(100)
		end
	end
end

function ClientSkills.AftershockM2(Character, Phase, PositiveHits)
	if Phase == "1" then
		local RightArmOffset = CFrame.new(0.032989502, 0.902121067, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)
		local LeftArmOffset = CFrame.new(-0.0339508057, 0.898052931, -0.0145263672, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)

		local LeftSphere = SpecialEffects.AftershockSpheres.LSphere:Clone()
		LeftSphere.Anchored = false
		LeftSphere.CFrame = Character.HumanoidRootPart.CFrame * LeftArmOffset
		LeftSphere.Transparency = 1
		LeftSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 4)

		local Weld = Instance.new("Weld")
		Weld.C0 = LeftArmOffset
		Weld.Part0 = LeftSphere
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = LeftSphere

		local RightSphere = SpecialEffects.AftershockSpheres.RSphere:Clone()
		RightSphere.Anchored = false
		RightSphere.CFrame = Character.HumanoidRootPart.CFrame * RightArmOffset
		RightSphere.Transparency = 1
		RightSphere.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeftSphere, 4)

		local Weld2 = Instance.new("Weld")
		Weld2.C0 = RightArmOffset
		Weld2.Part0 = RightSphere
		Weld2.Part1 = Character["Right Arm"]
		Weld2.Parent = RightSphere

		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(LeftSphere, Info, {Transparency = 0}):Play()
		TweenService:Create(RightSphere, Info, {Transparency = 0}):Play()

		task.delay(1.5, function()
			for i, v in ipairs(LeftSphere.Attachment:GetChildren()) do
				v.Enabled = false
			end
			for i, v in ipairs(RightSphere.Attachment:GetChildren()) do
				v.Enabled = false
			end

			local Info2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(LeftSphere, Info2, {Transparency = 1}):Play()
			TweenService:Create(RightSphere, Info2, {Transparency = 1}):Play()
		end)
		
		local AftershockWindup = SpecialSounds.AftershockWindup:Clone()
		AftershockWindup.PlayOnRemove = true
		AftershockWindup.Parent = Character.HumanoidRootPart
		AftershockWindup:Destroy()
		AftershockWindup = nil
		
		local AftershockCharge = SpecialSounds.AftershockCharge:Clone()
		AftershockCharge.Parent = Character.HumanoidRootPart
		AftershockCharge:Play()
		Debris:AddItem(AftershockCharge, 1.2)
		task.delay(1.5, function()
			TweenService:Create(AftershockCharge, TweenInfo.new(0.2), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local Offset = CFrame.new(1.70843506, -3.01976132, 0.389434814, 0, -1, 0, 0, 0, 1, -1, 0, 0)
		
		local AftershockM2Crack = SpecialEffects.AftershockM2Crack:Clone()
		AftershockM2Crack.CFrame = PositiveHits * Offset
		AftershockM2Crack.Transparency = 1
		AftershockM2Crack.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AftershockM2Crack, 3.3)
		
		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(AftershockM2Crack, Info, {Transparency = 0}):Play()
		task.delay(3, function()
			TweenService:Create(AftershockM2Crack, TweenInfo.new(1), {Transparency = 1}):Play()
		end)		
		
		local AftershockFloor = SpecialEffects.AftershockFloor:Clone()
		AftershockFloor.PrimaryPart.CFrame = PositiveHits
		AftershockFloor.PrimaryPart.Anchored = true
		AftershockFloor.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AftershockFloor, 2)
		
		for i, v in ipairs(AftershockFloor.Slam1.Emit20:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			end
		end
		for i, v in ipairs(AftershockFloor.Slam1.Emit5:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(5)
			end
		end
		for i, v in ipairs(AftershockFloor.Slam1["2Emit20"]:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			end
		end
		for i = 1, 3 do
			for _, v in ipairs(AftershockFloor["Slam" .. i]:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(5)
				end
			end
		end
		
		local AftershockM2 = SpecialEffects.AftershockM2:Clone()
		AftershockM2.CFrame = PositiveHits
		AftershockM2.Anchored = true
		AftershockM2.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AftershockM2, 1.1)
		
		for i, v in ipairs(AftershockM2.Emit1:GetChildren()) do
			v:Emit(1)
		end
		for i, v in ipairs(AftershockM2.Emit100:GetChildren()) do
			v:Emit(100)
		end
		for i, v in ipairs(AftershockM2.Emit20:GetChildren()) do
			v:Emit(20)
		end
		for i, v in ipairs(AftershockM2.Emit8:GetChildren()) do
			v:Emit(8)
		end
		
		local AftershockWindup = SpecialSounds.AftershockWindup:Clone()
		AftershockWindup.PlayOnRemove = true
		AftershockWindup.Parent = Character.HumanoidRootPart
		AftershockWindup:Destroy()
		AftershockWindup = nil
		
		local AftershockShatter = SpecialSounds.AftershockShatter:Clone()
		AftershockShatter.PlayOnRemove = true
		AftershockShatter.Parent = Character.HumanoidRootPart
		AftershockShatter:Destroy()
		AftershockShatter = nil
	elseif Phase == "3" then	
		if PositiveHits and #PositiveHits > 0 then
			local Offset = CFrame.new(1.70843506, -3.01976132, 0.389434814, 0, -1, 0, 0, 0, 1, -1, 0, 0)
			
			for i, v in ipairs(PositiveHits) do
				local AftershockM2Crack = SpecialEffects.AftershockM2Crack:Clone()
				AftershockM2Crack.CFrame = v.HumanoidRootPart.CFrame * Offset
				AftershockM2Crack.Transparency = 1
				AftershockM2Crack.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(AftershockM2Crack, 3.3)
				
				local Info = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
				TweenService:Create(AftershockM2Crack, Info, {Transparency = 0}):Play()
				task.delay(3, function()
					TweenService:Create(AftershockM2Crack, TweenInfo.new(1), {Transparency = 1}):Play()
				end)		

				local AftershockM2 = SpecialEffects.AftershockM2:Clone()
				AftershockM2.CFrame = v.HumanoidRootPart.CFrame
				AftershockM2.Anchored = true
				AftershockM2.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(AftershockM2, 1.1)

				for i, v in ipairs(AftershockM2.Emit1:GetChildren()) do
					v:Emit(1)
				end
				for i, v in ipairs(AftershockM2.Emit100:GetChildren()) do
					v:Emit(100)
				end
				for i, v in ipairs(AftershockM2.Emit20:GetChildren()) do
					v:Emit(20)
				end
				for i, v in ipairs(AftershockM2.Emit8:GetChildren()) do
					v:Emit(8)
				end
			end
		end
	end
end

function ClientSkills.AftershockScreenShake(Character)
	local Camera = workspace.CurrentCamera
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
		Camera.CFrame = Camera.CFrame * shakeCFrame
	end)
	
	camShake:Start()
	camShake:Shake(CameraShaker.Presets.Aftershock)

	task.delay(1.25, function()
		camShake:Stop()
		Camera.CameraType = Enum.CameraType.Custom
	end)
end

function ClientSkills.GrandCross(Character, Phase, Target, FreezeDuration)
	if Phase == "1" then
		local GrandCrossDash = SpecialEffects.GrandCrossDash:Clone()
		GrandCrossDash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandCrossDash, 20)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(-0.00857543945, 0.396987438, -1.12677002, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = GrandCrossDash
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = GrandCrossDash
		
		local GrandCrossDash = SpecialSounds.GrandCrossDash:Clone()
		GrandCrossDash.Parent = Character.HumanoidRootPart
		GrandCrossDash.Looped = true
		GrandCrossDash:Play()
		
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.363098145, -2.89167976, -0.475708008, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local GrandCrossExplosion = SpecialEffects.GrandCrossNew.GrandCrossExplosion:Clone()
		GrandCrossExplosion.CFrame = Target.HumanoidRootPart.CFrame * Offset
		GrandCrossExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandCrossExplosion, 4)
		
		for i, v in ipairs(GrandCrossExplosion:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			elseif v:IsA("PointLight") then
				task.delay(2, function()
					TweenService:Create(v, TweenInfo.new(2), {Brightness = 0}):Play()
				end)
			end
		end
		
		local GrandCrossGrab = SpecialSounds.GrandCrossGrab:Clone()
		GrandCrossGrab.PlayOnRemove = true
		GrandCrossGrab.Parent = Character.HumanoidRootPart
		GrandCrossGrab:Destroy()
		GrandCrossGrab = nil
		
		local GrandCrossCreation = SpecialSounds.GrandCrossCreation:Clone()
		GrandCrossCreation.PlayOnRemove = true
		GrandCrossCreation.Parent = GrandCrossExplosion
		GrandCrossCreation:Destroy()
		GrandCrossCreation = nil
	elseif Phase == "3" then
		local GrandCrossDash = workspace.Effects[Character.Name]:FindFirstChild("GrandCrossDash")
		if GrandCrossDash then
			Debris:AddItem(GrandCrossDash, 1.25)
			for i, v in ipairs(GrandCrossDash:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end
		
		local GrandCrossDashAudio = Character.HumanoidRootPart:FindFirstChild("GrandCrossDash")
		if GrandCrossDashAudio then
			GrandCrossDashAudio:Stop()
			GrandCrossDashAudio:Destroy()
			GrandCrossDashAudio = nil
		end
	elseif Phase == "4" then
		if Target and #Target > 0 then
			for i, v in ipairs(Target) do
				local FreezeEffect = ReplicatedStorage.Assets.Effects.Shikais.Ice.FrozenEffect:Clone()
				FreezeEffect.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -0.4679, 0))
				FreezeEffect.Anchored = false
				FreezeEffect.Parent = workspace.Effects[Character.Name]
				FreezeEffect.Transparency = 1
				TweenService:Create(FreezeEffect, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
				Debris:AddItem(FreezeEffect, FreezeDuration)
				
				local Weld = Instance.new("WeldConstraint")
				Weld.Part0 = FreezeEffect
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = FreezeEffect
				
				local FreezeFormAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice.Freeze:Clone()
				FreezeFormAudio.PlayOnRemove = true
				FreezeFormAudio.Parent = v.HumanoidRootPart
				FreezeFormAudio:Destroy()
				FreezeFormAudio = nil
				
				task.delay(FreezeDuration, function()
					local ShatterEffects = ReplicatedStorage.Assets.Effects.Shikais.Ice.IceShatterEffect:Clone()
					ShatterEffects.CFrame = v.HumanoidRootPart.CFrame
					ShatterEffects.Parent = workspace.Effects[Character.Name]
					ShatterEffects.Specs:Emit(35)
					Debris:AddItem(ShatterEffects, 1)
					
					local UnfreezeAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice["Ice Shatter 1"]:Clone()
					UnfreezeAudio.PlayOnRemove = true
					UnfreezeAudio.Parent = v.HumanoidRootPart
					UnfreezeAudio:Destroy()
					UnfreezeAudio = nil
				end)
			end
		end
	elseif Phase == "5" then
		local GrandProjectile = SpecialEffects.GrandCrossNew.GrandProjectile:Clone()
		GrandProjectile.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0.000335693359, 26.9639587, -0.000213623047, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08)
		GrandProjectile.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandProjectile, 1.5 + 0.45)
		
		local GrandCrossSpawn = SpecialEffects.GrandCrossNew.GrandCrossSpawn:Clone()
		GrandCrossSpawn.Position = GrandProjectile.Position
		GrandCrossSpawn.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandCrossSpawn, 0.56)
		
		for i, v in ipairs(GrandCrossSpawn:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		TweenService:Create(GrandProjectile, TweenInfo.new(0.45), {CFrame = GrandProjectile.CFrame * CFrame.new(0, -26, 0)}):Play()
		
		task.delay(0.45, function()
			for i, v in ipairs(GrandProjectile:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)
	end
end

function ClientSkills.ZombieRecall(Character)
	local RecallSound = ReplicatedStorage.Assets.Effects.Giselle.Sounds.ZombieRecall:Clone()
	RecallSound.PlayOnRemove = true
	RecallSound.Parent = Character.HumanoidRootPart
	RecallSound:Destroy()
	RecallSound = nil
end

function ClientSkills.Grasp(Character, Phase, Target)
	if Phase == "1" then
	elseif Phase == "2" then
		local function RandomRadian()
			local Min = -90
			local Max = 90
			return math.rad(math.random(Min, Max))
		end
		
		local PartSize = 1.5
		
		local Offset = {
			[1] = CFrame.new(5, -3, 0);
			[2] = CFrame.new(-1.5, -3, 0)
		}
		
		local DebrisModel = Instance.new("Model")
		DebrisModel.Parent = workspace.Effects[Character.Name]
		
		local RP = RaycastParams.new()
		RP.FilterType = Enum.RaycastFilterType.Exclude
		RP.FilterDescendantsInstances = {workspace.Entities, DebrisModel}
		
		local Floor = workspace:Raycast(Target.HumanoidRootPart.Position, Vector3.new(0, -50, 0), RP)
		if Floor then
			local Material = Floor.Material
			local Color = Floor.Instance.Color
			local Transparency = Floor.Instance.Transparency
			
			local Duration = 1
			local SetRate = 0.02
			local Rate = 0
			local Accumulated = 0
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				Duration -= DeltaTime

				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
					Debris:AddItem(DebrisModel, 0.2)
				end

				if Accumulated > Rate then
					Rate = SetRate
					Accumulated -= Rate
					for i = 1, 2 do
						local Part = Instance.new("Part")
						Part.Anchored = true
						Part.CanCollide = false
						Part.Size = Vector3.zero
						Part.TopSurface = Enum.SurfaceType.Smooth
						Part.BottomSurface = Enum.SurfaceType.Smooth
						Part.CFrame = Target.HumanoidRootPart.CFrame * Offset[i] * CFrame.Angles(RandomRadian(), RandomRadian(), RandomRadian())

						local AccurateRay = workspace:Raycast(Part.Position + Vector3.new(0, 2, 0), Vector3.new(0, -50, 0), RP)
						if AccurateRay then
							Part.Material = AccurateRay.Material
							Part.Transparency = AccurateRay.Instance.Transparency
							Part.Color = AccurateRay.Instance.Color
						else
							Part.Material = Material
							Part.Transparency = Transparency
							Part.Color = Color
						end

						Part.Parent = DebrisModel

						local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

						TweenService:Create(Part, Info, {Size = Vector3.new(PartSize, PartSize, PartSize)}):Play()
						task.delay(2.5, function()
							TweenService:Create(Part, Info, {Size = Vector3.zero}):Play()
						end)
					end
					
					local DebrisData = {
						Amount = 1,
						Collidable = true,
						VelocityMin = 30,
						VelocityMax = 50,
						PartSize = 1.5,
						Duration = 2,
					}

					ImpactCrater:Debris(Character, Target.HumanoidRootPart.CFrame * CFrame.new(3, -3, 0), DebrisData)
				end
			end)
		end
	elseif Phase == "3" then
		local GreatswordSound = ReplicatedStorage.Assets.ShikaiSounds.GreatswordCrit:Clone()
		GreatswordSound.PlayOnRemove = true
		GreatswordSound.Parent = Target.HumanoidRootPart
		GreatswordSound:Destroy()
		GreatswordSound = nil

		local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
		GSCritEffect.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(3, 0, 4)
		GSCritEffect.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
			v:Emit(50)
		end
		Debris:AddItem(GSCritEffect, 1.5)
		
		local DebrisData = {
			Amount = math.random(3, 5),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 1.5,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Target.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0), DebrisData)
	end
end

function ClientSkills.Glory(Character, Phase, RootCFrame, Speed)
	if Phase == "1" then
		
	elseif Phase == "2" then
		local GloryRelease = SpecialSounds.GloryRelease:Clone()
		GloryRelease.PlayOnRemove = true
		GloryRelease.Parent = Character.HumanoidRootPart
		GloryRelease:Destroy()
		GloryRelease = nil
		
		local Duration = 4
		
		local GloryTornado = SpecialEffects.GloryTornado:Clone()
		GloryTornado.CFrame = RootCFrame
		GloryTornado.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GloryTornado, Duration)
		
		ClientProjectile:ProjectileStraight(Character, GloryTornado, Speed)
		
		local Duration = Duration
		local Rate = 0.02
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			if Accumulated > Rate then
				Accumulated -= Rate
				Duration -= Rate
				
				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
				end
				
				local DebrisData = {
					Amount = 1,
					Collidable = true,
					VelocityMin = 40,
					VelocityMax = 60,
					PartSize = 1.5,
					Duration = 3,
				}

				ImpactCrater:Debris(Character, GloryTornado.CFrame, DebrisData)
			end
		end)
		
		local GloryTornadoSound = SpecialSounds.GloryTornado:Clone()
		GloryTornadoSound.Looped = true
		GloryTornadoSound.Parent = GloryTornado
		GloryTornadoSound:Play()
		Debris:AddItem(GloryTornadoSound, Duration)
		
		local GlorySwirl = SpecialEffects.GlorySwirl:Clone()
		GlorySwirl.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GlorySwirl, 0.9)

		local Weld = Instance.new("Weld")
		Weld.Part0 = GlorySwirl
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = GlorySwirl

		for i, v in ipairs(GlorySwirl.Emit15:GetChildren()) do
			v:Emit(15)
		end
		for i, v in ipairs(GlorySwirl.Emit15a:GetChildren()) do
			v:Emit(15)
		end
		for i, v in ipairs(GlorySwirl.Emit25:GetChildren()) do
			v:Emit(25)
		end
	elseif Phase == "3" then
		local function CreateClone(ClonedCharacter)
			local Archivable = ClonedCharacter.Archivable
			ClonedCharacter.Archivable = true
			local Clone = ClonedCharacter:Clone()
			ClonedCharacter.Archivable = Archivable
			Clone.Name = ClonedCharacter.Name .. "_CloneFX"

			for i, v in ipairs(Clone:GetDescendants()) do
				if v:IsA("Script") or v:IsA("LocalScript") then
					v:Destroy()
				end
			end

			local FakeHead = workspace.Effects[ClonedCharacter.Name]:FindFirstChild(ClonedCharacter.Name .. "Head")
			if FakeHead then
				local CloneFakeHead = FakeHead:Clone()
				CloneFakeHead.Weld:Destroy()
				CloneFakeHead.Parent = Clone

				local Weld = Instance.new("Weld")
				Weld.Part0 = CloneFakeHead
				Weld.Part1 = Clone.Head
				Weld.Parent = CloneFakeHead
			end

			local BloatStates = {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Running,
				Enum.HumanoidStateType.RunningNoPhysics,
				Enum.HumanoidStateType.Climbing,
				Enum.HumanoidStateType.StrafingNoPhysics,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.GettingUp,
				Enum.HumanoidStateType.Jumping,
				Enum.HumanoidStateType.Landed,
				Enum.HumanoidStateType.Flying,
				Enum.HumanoidStateType.Freefall,
				Enum.HumanoidStateType.Seated,
				Enum.HumanoidStateType.PlatformStanding,
				Enum.HumanoidStateType.Dead,
				Enum.HumanoidStateType.Swimming,
				Enum.HumanoidStateType.Physics,
			}

			for i, v in ipairs(BloatStates) do
				Clone.Humanoid:SetStateEnabled(v, false)
			end
			Clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			
			return Clone
		end
		
		local Clone = CreateClone(Character)
		Clone.HumanoidRootPart.CFrame = RootCFrame * CFrame.Angles(0, math.pi, 0)
		Clone.HumanoidRootPart.Anchored = true
		
		for i, v in ipairs(Clone:GetDescendants()) do
			if v:IsA("BasePart") then
				if v.Transparency ~= 1 then
					v.Transparency = 0.5
				end
				v.CanCollide = false
			end
		end
		
		Clone.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Clone, 1.2)
		
		local Animation = ReplicatedStorage.Assets.SkillAnimations.Special.SkillGloryAir
		local GloryAirAnimation = Clone.Humanoid.Animator:LoadAnimation(Animation)
		GloryAirAnimation:Play()
		
		TweenService:Create(Clone.HumanoidRootPart, TweenInfo.new(1), {CFrame = Speed}):Play()
		
		local GloryTeleport = SpecialEffects.GloryTeleport:Clone()
		GloryTeleport.CFrame = Speed
		GloryTeleport.Anchored = true
		GloryTeleport.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GloryTeleport, 1)
		
		for i, v in ipairs(GloryTeleport.Emit3:GetChildren()) do
			v:Emit(3)
		end
		
		local GloryTeleport = SpecialSounds.GloryTeleport:Clone()
		GloryTeleport.PlayOnRemove = true
		GloryTeleport.Parent = Character.HumanoidRootPart
		GloryTeleport:Destroy()
		GloryTeleport = nil
	elseif Phase == "4" then
		
	end
end

function ClientSkills.GranReyCero(Character, Phase, Speed, MousePosition, SpawnPoint, Radius)
	if Phase == "1" then
		local GranReyCharge = SpecialEffects.GranReyChargeFX:Clone()
		GranReyCharge.EnableSmoke:Destroy()
		GranReyCharge.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GranReyCharge, 2.6)
		
		for i, v in ipairs(GranReyCharge:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				v.Enabled = true
			end
		end
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.0896072388, 1.26747596, 0.0146484375, 1, 0, 0, 0, 0.99999994, 0, 0, 0, 1)
		Weld.Part0 = GranReyCharge
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = GranReyCharge
		
		local GranReySmoke = SpecialEffects.GranReyChargeFX:Clone()
		GranReySmoke.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GranReySmoke, 2.6)
		
		for i, v in ipairs(GranReySmoke.EnableSmoke:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				v.Enabled = true
			end
		end
		
		local SmokeWeld = Instance.new("Weld")
		SmokeWeld.C0 = CFrame.new(-1.41039276, 0.990615129, 0.0146484375, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		SmokeWeld.Part0 = GranReySmoke
		SmokeWeld.Part1 = Character.HumanoidRootPart
		SmokeWeld.Parent = GranReySmoke
		
		local GranReyChargeSound = SpecialSounds.GranReyCharge:Clone()
		GranReyChargeSound.Parent = Character.HumanoidRootPart
		GranReyChargeSound:Play()
		Debris:AddItem(GranReyChargeSound, 2)
		
		local GranReyCutSound = SpecialSounds.GranReyCharge:Clone()
		GranReyCutSound.PlayOnRemove = true
		GranReyCutSound.Parent = Character.HumanoidRootPart
		GranReyCutSound:Destroy()
		GranReyCutSound = nil
		
		local GranReyCutFX = SpecialEffects.GranReyBloodDrop:Clone()
		GranReyCutFX.Anchored = true
		GranReyCutFX.CFrame = Character.HumanoidRootPart.CFrame
		GranReyCutFX.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GranReyCutFX, 0.5)
		
		for i, v in ipairs(GranReyCutFX.Emit4:GetChildren()) do
			v:Emit(4)
		end
		
		task.delay(1.6, function()
			for i, v in ipairs(GranReyCharge:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
					v.Enabled = false
				end
			end
			for i, v in ipairs(GranReySmoke:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
					v.Enabled = false
				end
			end
			TweenService:Create(GranReyChargeSound, TweenInfo.new(0.1), {Volume = 0}):Play()
		end)
	elseif Phase == "2" then
		local GranReyCero = SpecialEffects.GranReyChargeFX:Clone()
		GranReyCero.Name = "GranReyClientCero"
		GranReyCero.CFrame = CFrame.new(Character.HumanoidRootPart.Position, MousePosition)
		GranReyCero.EnableSmoke:Destroy()
		GranReyCero.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GranReyCero, 10)

		for i, v in ipairs(GranReyCero:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") then
				v.Enabled = true
			end
		end
		
		ClientProjectile:ProjectileStraight(Character, GranReyCero, Speed)
		
		local GranReyReleaseSound = SpecialSounds.GranReyRelease:Clone()
		GranReyReleaseSound.PlayOnRemove = true
		GranReyReleaseSound.Parent = Character.HumanoidRootPart
		GranReyReleaseSound:Destroy()
		GranReyReleaseSound = nil
	elseif Phase == "3" then
		local GranReyCero = workspace.Effects[Character.Name]:FindFirstChild("GranReyClientCero")
		if GranReyCero then
			GranReyCero:Destroy()
		end
		
		local GranReyExplosion = SpecialEffects.GranReyExplosion:Clone()
		GranReyExplosion.CFrame = SpawnPoint
		GranReyExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GranReyExplosion, 2.5)
		
		for i, v in ipairs(GranReyExplosion.Emit1:GetChildren()) do
			v:Emit(1)
		end
		
		local GranReyPreExplodeSound = SpecialSounds.GranReyPreExplode:Clone()
		GranReyPreExplodeSound.PlayOnRemove = true
		GranReyPreExplodeSound.Parent = GranReyExplosion
		GranReyPreExplodeSound:Destroy()
		GranReyPreExplodeSound = nil
		
		coroutine.wrap(function()
			for i = 1, 5 do
				local PreGranBallBlue = SpecialEffects.GranBallBlue:Clone()
				PreGranBallBlue.Material = Enum.Material.ForceField
				PreGranBallBlue.Transparency = 0
				PreGranBallBlue.CFrame = SpawnPoint
				PreGranBallBlue.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(PreGranBallBlue, 0.5)

				TweenService:Create(PreGranBallBlue, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.zero}):Play()
				
				task.wait(0.1)
			end
		end)()
		
		task.delay(1, function()
			for i, v in ipairs(GranReyExplosion.Emit20:GetChildren()) do
				v:Emit(20)
			end
			for i, v in ipairs(GranReyExplosion.Emit80:GetChildren()) do
				v:Emit(80)
			end
			
			local GranBall = SpecialEffects.GranBall:Clone()
			local GranBallSize = GranBall.Size
			GranBall.Size = Vector3.zero
			GranBall.CFrame = SpawnPoint
			GranBall.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(GranBall, 0.6)
			
			local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(GranBall, TweenInfo.new(0.4), {Size = GranBallSize}):Play()
			
			local CraterData = {
				CanCollide = true,
				Radius = Radius,
				PartSize = 3,
				SizeMin = 2,
				SizeMax = 4,
				Duration = 6,
				TweenTime = 0.3,
			}

			ImpactCrater:CircleCrater(Character, SpawnPoint, CraterData)

			local DebrisData = {
				Amount = math.random(15, 20),
				Collidable = true,
				VelocityMin = 70,
				VelocityMax = 100,
				PartSize = 3,
				PartMin = -1.5,
				PartMax = 1.5,
				Duration = 5,
				RandomMin = -Radius,
				RandomMax = Radius,
			}

			ImpactCrater:RandomDebris(Character, SpawnPoint, DebrisData)
			
			local GranReyExplodeSound = SpecialSounds.GranReyExplosion:Clone()
			GranReyExplodeSound.PlayOnRemove = true
			GranReyExplodeSound.Parent = GranBall
			GranReyExplodeSound:Destroy()
			GranReyExplodeSound = nil
			
			task.wait(0.2)
			
			TweenService:Create(GranBall, TweenInfo.new(0.4), {Transparency = 1}):Play()
			
			local Info2 = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			
			local GranBallBlue = SpecialEffects.GranBallBlue:Clone()
			local GranBallBlueSize = GranBallBlue.Size
			local GranBallBlueTransparency = GranBallBlue.Transparency
			GranBallBlue.Transparency = 1
			GranBallBlue.Size = Vector3.zero
			GranBallBlue.CFrame = SpawnPoint
			GranBallBlue.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(GranBallBlue, 1.2)
			
			TweenService:Create(GranBallBlue, Info2, {Size = GranBallSize}):Play()
			TweenService:Create(GranBallBlue, TweenInfo.new(0.25), {Transparency = GranBallBlueTransparency}):Play()
			
			task.wait(0.2)
			
			TweenService:Create(GranBallBlue, TweenInfo.new(0.6), {Transparency = 1}):Play()
			TweenService:Create(GranBallBlue, TweenInfo.new(0.6), {Size = GranBallSize + Vector3.new(50, 50, 50)}):Play()
		end)
	end
end

function ClientSkills.ReiatsuJavelin(Character, Phase, RootCFrame, Speed, Duration)
	if Phase == "1" then
		local ReiatsuJavelinSummon = SpecialSounds.ReiatsuJavelinSummon:Clone()
		ReiatsuJavelinSummon.PlayOnRemove = true
		ReiatsuJavelinSummon.Parent = Character.HumanoidRootPart
		ReiatsuJavelinSummon:Destroy()
		ReiatsuJavelinSummon = nil
	elseif Phase == "2" then
		local ReiatsuJavelin = SpecialEffects.ReiatsuJavelin:Clone()
		ReiatsuJavelin:PivotTo(RootCFrame * CFrame.Angles(0, 0, 0))
		ReiatsuJavelin.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ReiatsuJavelin, Duration)

		ClientProjectile:ProjectileFacing(Character, ReiatsuJavelin.PrimaryPart, RootCFrame.LookVector, Speed)
		
		local ReiatsuJavelinThrowSound = SpecialSounds.ReiatsuJavelinThrow:Clone()
		ReiatsuJavelinThrowSound.PlayOnRemove = true
		ReiatsuJavelinThrowSound.Parent = Character.HumanoidRootPart
		ReiatsuJavelinThrowSound:Destroy()
		ReiatsuJavelinThrowSound = nil
	elseif Phase == "3" then
		local ReiatsuExplosion = SpecialEffects.ReiatsuExplosion:Clone()
		ReiatsuExplosion.CFrame = CFrame.new(RootCFrame)
		ReiatsuExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ReiatsuExplosion, 2.5)
		
		for i, v in ipairs(ReiatsuExplosion.Emit20:GetChildren()) do
			v:Emit(20)
		end
		for i, v in ipairs(ReiatsuExplosion.Emit30:GetChildren()) do
			v:Emit(30)
		end
		for i, v in ipairs(ReiatsuExplosion.Emit3:GetChildren()) do
			v:Emit(3)
		end
		
		local ReiatsuJavelinExplosionSound = SpecialSounds.ReiatsuJavelinExplosion:Clone()
		ReiatsuJavelinExplosionSound.PlayOnRemove = true
		ReiatsuJavelinExplosionSound.Parent = ReiatsuExplosion
		ReiatsuJavelinExplosionSound:Destroy()
		ReiatsuJavelinExplosionSound = nil
	elseif Phase == "4" then
		local Offset = CFrame.new(0.000244140625, -2.55123878, 0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		local ReiatsuJavelimSlam = SpecialEffects.ReiatsuJavelinSlam:Clone()
		ReiatsuJavelimSlam.CFrame = Character.HumanoidRootPart.CFrame * Offset
		ReiatsuJavelimSlam.Anchored = true
		ReiatsuJavelimSlam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ReiatsuJavelimSlam, 1.2)
		
		ReiatsuJavelimSlam.spark.Enabled = true
		
		task.delay(0.7, function()
			ReiatsuJavelimSlam.spark.Enabled = false
		end)
		
		local BodyParts = {
			"Left Arm";
			"Right Arm";
		}
		
		for _, BodyPart in ipairs(BodyParts) do
			local ReiatsuJavelinArm = SpecialEffects.ReiatsuJavelinArm:Clone()
			ReiatsuJavelinArm.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(ReiatsuJavelinArm, 0.5)
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = ReiatsuJavelinArm
			Weld.Part1 = Character[BodyPart]
			Weld.Parent = ReiatsuJavelinArm

			for i, v in ipairs(ReiatsuJavelinArm.JavelinStartup1:GetChildren()) do
				v:Emit(1)
			end
			for i, v in ipairs(ReiatsuJavelinArm.JavelinStartup2:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(30)
				end
			end
		end
	elseif Phase == "5" then
		local Offset = CFrame.new(0.000244140625, -2.55123878, 0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		local ReiatsuJavelimSlam = SpecialEffects.ReiatsuJavelinSlam:Clone()
		ReiatsuJavelimSlam.CFrame = RootCFrame * Offset
		ReiatsuJavelimSlam.Anchored = true
		ReiatsuJavelimSlam.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ReiatsuJavelimSlam, 2.2)
		
		for i, v in ipairs(ReiatsuJavelimSlam.Emit100:GetChildren()) do
			v:Emit(100)
		end
		for i, v in ipairs(ReiatsuJavelimSlam.Emit15:GetChildren()) do
			v:Emit(15)
		end
		
		local ReiatsuJavelinSlamSound = SpecialSounds.ReiatsuJavelinGroundStab:Clone()
		ReiatsuJavelinSlamSound.PlayOnRemove = true
		ReiatsuJavelinSlamSound.Parent = Character.HumanoidRootPart
		ReiatsuJavelinSlamSound:Destroy()
		ReiatsuJavelinSlamSound = nil
		
		local ReiatsuJavelinShockwave = SpecialSounds.ReiatsuJavelinShockwave:Clone()
		ReiatsuJavelinShockwave.PlayOnRemove = true
		ReiatsuJavelinShockwave.Parent = Character.HumanoidRootPart
		ReiatsuJavelinShockwave:Destroy()
		ReiatsuJavelinShockwave = nil
	end
end

function ClientSkills.ReiatsuSiphon(Character, Phase, Target, Duration)
	if Phase == "1" then
		local ReiatsuSiphonSound = SpecialSounds.ReiatsuSiphon:Clone()
		ReiatsuSiphonSound.PlayOnRemove = true
		ReiatsuSiphonSound.Parent = Character.HumanoidRootPart
		ReiatsuSiphonSound:Destroy()
		ReiatsuSiphonSound = nil
	elseif Phase == "2" then
		local ReiatsuSiphon = SpecialEffects.ReiatsuSiphon:Clone()
		ReiatsuSiphon.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ReiatsuSiphon, Duration)
		
		for i, v in ipairs(ReiatsuSiphon:GetDescendants()) do
			if v:IsA("Beam") then
				v.Attachment1 = Character.HumanoidRootPart.RootAttachment 
			end
		end		
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = ReiatsuSiphon
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = ReiatsuSiphon
		
		local ReiatsuSiphonSound = SpecialSounds.ReiatsuSiphon:Clone()
		ReiatsuSiphonSound.Parent = Target.HumanoidRootPart
		ReiatsuSiphonSound:Play()
		Debris:AddItem(ReiatsuSiphonSound, Duration)
	end
end

function ClientSkills.DualDestruction(Character, Phase, HitFrameCounter, Target)
	if Phase == "1" then
		local GrabSound = SpecialSounds.DualDestructionGrab:Clone()
		GrabSound.PlayOnRemove = true
		GrabSound.Parent = Target.HumanoidRootPart
		GrabSound:Destroy()
		GrabSound = nil
	elseif Phase == "2" then
		if HitFrameCounter == 3 then
			local DualSlam = SpecialEffects.DualDestructionFx.DualSlam:Clone()
			DualSlam.Parent = Character.HumanoidRootPart
			Debris:AddItem(DualSlam, 0.9)
			
			for i, v in ipairs(DualSlam:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.name))
				end
			end
		else
			local DualStomp = SpecialEffects.DualDestructionFx.DualStomp:Clone()
			DualStomp.Parent = Character.HumanoidRootPart
			Debris:AddItem(DualStomp, 1)
			
			local DualStomp2 = SpecialEffects.DualDestructionFx.DualStomp2:Clone()
			DualStomp2.Parent = Character.HumanoidRootPart
			Debris:AddItem(DualStomp2, 2)
			
			for i, v in ipairs(DualStomp:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.name))
				end
			end
			for i, v in ipairs(DualStomp2:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(tonumber(v.name))
				end
			end
		end
		
		local Radiuses = {
			[1] = 7;
			[2] = 9;
			[3] = 11;
		}
		
		local Origin = Character.HumanoidRootPart.CFrame
		local CraterData = {
			Radius = Radiuses[HitFrameCounter],
			PartSize = 2,
			Duration = 3,
			DebrisData = {
				Amount = math.random(3, 5),
				Collidable = true,
				VelocityMin = 30,
				VelocityMax = 50,
			}
		}

		ImpactCrater:Crater(Character, Origin, CraterData)
		
		local StompSound = SpecialSounds.DualDestruction:Clone()
		StompSound.PlayOnRemove = true
		StompSound.Parent = Target.HumanoidRootPart
		StompSound:Destroy()
		StompSound = nil
	elseif Phase == "3" then
		local BodyPart = {"Left Arm", "Right Arm"}
		for i, v in ipairs(BodyPart) do
			local CeroStartup = SpecialEffects.DualDestructionStartup:Clone()
			CeroStartup.PrimaryPart.Anchored = false
			CeroStartup.Ball.Transparency = 1
			CeroStartup.Ball.Size = Vector3.zero
			CeroStartup.Center.Transparency = 1
			CeroStartup.Center.Size = Vector3.zero
			CeroStartup.Parent = Character[v]
			Debris:AddItem(CeroStartup, 3)

			local InitialInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(CeroStartup.Ball, InitialInfo, {Transparency = 0.75, Size = Vector3.new(1.5, 1.5, 1.5)}):Play()
			TweenService:Create(CeroStartup.Center, InitialInfo, {Transparency = 0, Size = Vector3.new(1.223, 1.223, 1.223)}):Play()

			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0, -4.76837158e-07, 1.85787964, 1, -7.22266691e-12, -2.64662264e-10, 2.48291887e-10, 3.08318648e-10, -0.999996483, 1.40438772e-11, 1, -3.08317732e-10)
			Weld.Part0 = CeroStartup.PrimaryPart
			Weld.Part1 = Character[v]
			Weld.Parent = CeroStartup.PrimaryPart

			local ChargeSound = HollowSounds.CeroCharge:Clone()
			ChargeSound.Parent = Character.PrimaryPart
			ChargeSound:Play()
			Debris:AddItem(ChargeSound, 2.2)

			local DelayTime = 0.41
			local BallLifeTime = DelayTime / 4.25

			task.delay(DelayTime, function()
				Weld:Destroy()
				CeroStartup.PrimaryPart.Anchored = true
				Debris:AddItem(CeroStartup, 0.5)

				local Info = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
				local Info2 = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true)
				for i = 1, 2 do
					local Ring = CeroStartup["Ring" .. i]
					Ring.Anchored = true
					Ring.WeldConstraint:Destroy()

					local Size = Ring.Size
					Ring.Size = Vector3.zero

					TweenService:Create(Ring, Info, {CFrame = Ring.CFrame * CFrame.new(0, -3, 0), Size = Size}):Play()
					TweenService:Create(Ring, Info2, {Transparency = 0.75}):Play()
				end

				TweenService:Create(CeroStartup.Ball, InitialInfo, {Transparency = 1}):Play()
				TweenService:Create(CeroStartup.Center, InitialInfo, {Transparency = 1}):Play()

				TweenService:Create(ChargeSound, TweenInfo.new(0.3), {Volume = 0}):Play()
				for i, v in ipairs(CeroStartup.Ball.Attachment:GetChildren()) do
					v.Enabled = false
				end
			end)
		end
	elseif Phase == "4" then
		local Offsets = {
			CeroRight = CFrame.new(0.0899658203, -5.35506153, -7.36981201, -0.955714285, -0.148941517, -0.253824353, 0.0403529033, 0.788010716, -0.614342451, 0.291514784, -0.597369015, -0.747103631);
			CeroLeft = CFrame.new(2.19644165, -5.56257153, -7.46557617, -0.974369824, 0.138493761, 0.177263945, 0, 0.788010955, -0.615661681, -0.224951193, -0.599881887, -0.767813861 );
		}
		
		local BeamSize = Vector3.new(3.624, 3.417, 16.42)
		local CeroSize = Vector3.new(2.961, 2.951, 16.157)
		
		for i, v in pairs(Offsets) do
			if SpecialEffects.DualDestruction[i] then
				local Cero = SpecialEffects.DualDestruction[i]:Clone()
				Cero:PivotTo(Character.HumanoidRootPart.CFrame * v * CFrame.new(0, 0, -BeamSize.Z / 2))
				Cero.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(Cero, 0.8)
				
				for i, v in ipairs(Cero:GetChildren()) do
					v.Size = Vector3.new(0, 0, 0)
				end
				
				local BeamPosition = (Cero.PrimaryPart.CFrame * CFrame.new(0, 0, BeamSize.Z / 2)).Position
				local CeroPosition = (Cero.PrimaryPart.CFrame * CFrame.new(0, 0, CeroSize.Z / 2)).Position

				local Info = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

				TweenService:Create(Cero.Beam, Info, {Size = BeamSize, Position = BeamPosition}):Play()
				TweenService:Create(Cero.cero, Info, {Size = CeroSize, Position = CeroPosition}):Play()
				task.delay(0.25, function()
					local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
					TweenService:Create(Cero.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
					TweenService:Create(Cero.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
				end)

				local Connection
				Connection = RunService.Heartbeat:Connect(function(DeltaTime)
					Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
				end)
				local DestroyConnection
				DestroyConnection = Cero.Destroying:Connect(function()
					Connection:Disconnect()
					Connection = nil
					DestroyConnection:Disconnect()
					DestroyConnection = nil
				end)

				task.delay(0.4, function()
					local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
					TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
					TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
				end)

				local CeroFireSound = HollowSounds.CeroFire:Clone()
				CeroFireSound.PlayOnRemove = true
				CeroFireSound.Parent = Character.PrimaryPart
				CeroFireSound:Destroy()
				CeroFireSound = nil
			end
		end
	end
end

function ClientSkills.GrandRequiem(Character, Phase, RootCFrame, PositiveHits, FreezeDuration)
	if Phase == "1" then
		FlashstepClient.Invisible(Character)
		
		local FlashstepClone = ReplicatedStorage.Assets.Effects.FlashstepClone:Clone()
		FlashstepClone.Head.CFrame = Character.Head.CFrame
		FlashstepClone.Torso.CFrame = Character.Torso.CFrame
		FlashstepClone["Right Leg"].CFrame = Character["Right Leg"].CFrame
		FlashstepClone["Right Arm"].CFrame = Character["Right Arm"].CFrame
		FlashstepClone["Left Leg"].CFrame = Character["Left Leg"].CFrame
		FlashstepClone["Left Arm"].CFrame = Character["Left Arm"].CFrame
		FlashstepClone.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(FlashstepClone, 1)

		for i, v in ipairs(Character:GetChildren()) do
			if v:IsA("Accessory") then
				local Hair = v:Clone()
				local Weld = Hair.Handle:FindFirstChildWhichIsA("Weld")
				if Weld then
					Weld:Destroy()
					Weld= nil
				end
				Hair.Handle.Anchored = true
				Hair.Handle.CFrame = v.Handle.CFrame
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					Hair.Handle.Color = Color3.fromRGB(99, 100, 167)
				else
					Hair.Handle.Color = Color3.fromRGB(139, 243, 255)
				end
				local Mesh = Hair.Handle:FindFirstChildWhichIsA("SpecialMesh") 
				if Mesh then
					Mesh.VertexColor = color3ToVector3(Hair.Handle.Color)
				end
				Hair.Parent = FlashstepClone
			end
		end
		for i, v in ipairs(FlashstepClone:GetDescendants()) do
			if v:IsA("BasePart") then
				if Character:GetAttribute("ZanpakutoState") >= 2 then
					v.Color = Color3.fromRGB(99, 100, 167)
				else
					v.Color = Color3.fromRGB(139, 243, 255)
				end
				v.Material = Enum.Material.Glass
				v.Transparency = 0.15
			end
		end
		
		local Info = TweenInfo.new(0.15, Enum.EasingStyle.Linear,Enum.EasingDirection.Out, 0, false, 0)
		
		local GrandRequiemSound = SpecialSounds.GrandRequiem:Clone()
		GrandRequiemSound.PlayOnRemove = true
		GrandRequiemSound.Parent = FlashstepClone.Torso
		GrandRequiemSound:Destroy()
		GrandRequiemSound = nil
		
		task.delay(0.85, function()
			for i, v in ipairs(FlashstepClone:GetDescendants()) do
				if v:IsA("BasePart") then
					local TweenTransparency = TweenService:Create(v, Info, {Transparency = 1})
					TweenTransparency:Play()
				end
			end
		end)
	elseif Phase == "2" then
		FlashstepClient.Visible(Character)
		
		local GrandRequiem = SpecialEffects.GrandRequiem:Clone()
		GrandRequiem.CFrame = RootCFrame
		GrandRequiem.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(GrandRequiem, 4)
		
		local Reappear = SpecialEffects.GrandRequiemAppear:Clone()
		Reappear.CFrame = Character.HumanoidRootPart.CFrame
		Reappear.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Reappear, 2)
		
		for i, v in ipairs(GrandRequiem:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.name))
			end
		end
		for i, v in ipairs(Reappear:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.name))
			end
		end
		
		local GrandRequiemExplode = SpecialSounds.GrandRequiemExplode:Clone()
		GrandRequiemExplode.PlayOnRemove = true
		GrandRequiemExplode.Parent = nil
		GrandRequiemExplode:Destroy()
		GrandRequiemExplode = nil
	elseif Phase == "3" then
		if PositiveHits and #PositiveHits > 0 then
			for i, v in ipairs(PositiveHits) do
				local FreezeEffect = ReplicatedStorage.Assets.Effects.Shikais.Ice.FrozenEffect:Clone()
				FreezeEffect.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -0.4679, 0))
				FreezeEffect.Anchored = false
				FreezeEffect.Parent = workspace.Effects[Character.Name]
				FreezeEffect.Transparency = 1
				TweenService:Create(FreezeEffect, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
				Debris:AddItem(FreezeEffect, FreezeDuration)

				local Weld = Instance.new("WeldConstraint")
				Weld.Part0 = FreezeEffect
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = FreezeEffect

				local FreezeFormAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice.Freeze:Clone()
				FreezeFormAudio.PlayOnRemove = true
				FreezeFormAudio.Parent = v.HumanoidRootPart
				FreezeFormAudio:Destroy()
				FreezeFormAudio = nil

				task.delay(FreezeDuration, function()
					local ShatterEffects = ReplicatedStorage.Assets.Effects.Shikais.Ice.IceShatterEffect:Clone()
					ShatterEffects.CFrame = v.HumanoidRootPart.CFrame
					ShatterEffects.Parent = workspace.Effects[Character.Name]
					ShatterEffects.Specs:Emit(35)
					Debris:AddItem(ShatterEffects, 1)

					local UnfreezeAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice["Ice Shatter 1"]:Clone()
					UnfreezeAudio.PlayOnRemove = true
					UnfreezeAudio.Parent = v.HumanoidRootPart
					UnfreezeAudio:Destroy()
					UnfreezeAudio = nil
				end)
			end
		end
	end
end

function ClientSkills.Mimic(Character)
	
end

function ClientSkills.MementoMori(Character, Phase, RootCFrame, PositiveHits, Duration)
	if Phase == "1" then
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.000396728516, -2.9391861, -0.000259399414, -4.37113883e-08, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-08)
		
		local MementoMori = SpecialEffects.MementoMoriRelease:Clone()
		MementoMori.CFrame = RootCFrame * Offset
		MementoMori.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(MementoMori, 3)
		
		for i, v in ipairs(MementoMori:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local MementoMoriStomp = SpecialEffects.MementoMoriStomp.Step:Clone()
		MementoMoriStomp.Parent = Character["Right Leg"]
		Debris:AddItem(MementoMoriStomp, 0.65)
		
		for i, v in ipairs(MementoMoriStomp:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local MementoMoriSound = SpecialSounds.MementoMoriRelease:Clone()
		MementoMoriSound.PlayOnRemove = true
		MementoMoriSound.Parent = Character.HumanoidRootPart
		MementoMoriSound:Destroy()
		MementoMoriSound = nil
	elseif Phase == "3" then
		if PositiveHits and #PositiveHits > 0 then
			for i, v in ipairs(PositiveHits) do
				local ReiDisable = SpecialEffects.MementoMoriReiDisable:Clone()
				ReiDisable.Parent = v.HumanoidRootPart
				Debris:AddItem(ReiDisable, Duration + 1.4)
				
				local Weld = Instance.new("Weld")
				Weld.Part0 = ReiDisable
				Weld.Part1 = v.HumanoidRootPart
				Weld.Parent = ReiDisable
				
				task.delay(Duration, function()
					for i, v in ipairs(ReiDisable:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
				end)
			end
		end
	elseif Phase == "4" then
		local MementoMoriBuff = SpecialEffects.MementoMoriBuff:Clone()
		MementoMoriBuff.Parent = Character.HumanoidRootPart
		Debris:AddItem(MementoMoriBuff, Duration + 0.7)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.00329589844, 1.06830978, -0.0158081055, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.Part0 = MementoMoriBuff
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = MementoMoriBuff
		
		task.delay(Duration, function()
			for i, v in ipairs(MementoMoriBuff:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "5" then
		local Effects = ReplicatedStorage.Assets.Effects
		local Sounds = ReplicatedStorage.Assets.Sounds

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

		local SpiritualPressure = Sounds.SpiritualPressure:Clone()
		SpiritualPressure.Parent = workspace.Effects[Character.Name]
		SpiritualPressure:Play()
		Debris:AddItem(SpiritualPressure, Duration)

		local Heartbeat = Sounds.Heartbeat:Clone()
		Heartbeat.Parent = workspace.Effects[Character.Name]
		Heartbeat:Play()
		Debris:AddItem(Heartbeat, Duration)

		local function RandomNumber()
			local Min, Max = 0, 1
			local RNG = Random.new()
			return RNG:NextNumber(Min, Max)
		end

		local Time = Duration
		local Speed = 0.4
		local Rate = 0.03
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			
			if Time <= 0 then
				Connection:Disconnect()
				Connection = nil
			end
			
			if Accumulated > Rate then
				Accumulated -= Rate
				Time -= Rate

				if Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenEffects") then
					local SelectedNumber = math.random(1, 2)

					local SpiritualPressureLine = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
					local X = RandomNumber()
					if SelectedNumber == 2 then
						SpiritualPressureLine.ImageColor3 = Color3.fromRGB(255, 0, 0)
					end
					SpiritualPressureLine.Position = UDim2.new(X, 0, -0.2, 0)
					SpiritualPressureLine.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
					Debris:AddItem(SpiritualPressureLine, Speed)
					TweenService:Create(SpiritualPressureLine, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, 1.2, 0)}):Play()

					local SpiritualPressureLine2 = ReplicatedStorage.Assets.UIs["SpiritualPressureLine" .. SelectedNumber]:Clone()
					local X = RandomNumber()
					if SelectedNumber == 2 then
						SpiritualPressureLine2.ImageColor3 = Color3.fromRGB(255, 0, 0)
					end
					SpiritualPressureLine2.Position = UDim2.new(X, 0, 1.2, 0)
					SpiritualPressureLine2.Parent = Players.LocalPlayer.PlayerGui.ScreenEffects.SpiritualPressure
					Debris:AddItem(SpiritualPressureLine2, Speed)
					TweenService:Create(SpiritualPressureLine2, TweenInfo.new(Speed), {Position = UDim2.new(X, 0, -0.2, 0)}):Play()
				end
			end
		end)	

		local Camera = workspace.CurrentCamera
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
			Camera.CFrame = Camera.CFrame * shakeCFrame
		end)

		camShake:Start()
		camShake:Shake(CameraShaker.Presets.SpiritualPressure)

		task.delay(Duration - 1, function()
			camShake:Stop()
			Camera.CameraType = Enum.CameraType.Custom
		end)

		task.delay(Duration - 2, function()
			TweenService:Create(Heartbeat, TweenInfo.new(2), {Volume = 0}):Play()
			TweenService:Create(SpiritualPressure, TweenInfo.new(2), {Volume = 0}):Play()
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
end

function ClientSkills.TrueGrasp(Character, Phase, Target, SpawnCFrame, Range)
	if Phase == "1" then
		local Duration = 1.3
		
		local function ApplyParticles(Object)
			for i, v in ipairs(SpecialEffects.TrueGraspLariatEnable:GetChildren()) do
				local Particle = v:Clone()
				Particle.Parent = Object
				Debris:AddItem(Particle, Duration + 1.2)
				
				task.delay(Duration, function()
					Particle.Enabled = false
				end)
			end
		end
		
		for i, v in ipairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				ApplyParticles(v)
			end
		end
		
		local LariatTrail = SpecialEffects.TrueGraspLariatTrail:Clone()
		LariatTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LariatTrail, Duration + 1.2)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = LariatTrail
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = LariatTrail
		
		local LariatRush = SpecialSounds.TrueGraspLariat:Clone()
		LariatRush.Parent = Character.HumanoidRootPart
		LariatRush:Play()
		Debris:AddItem(LariatRush, LariatRush.TimeLength)
		
		task.delay(Duration, function()
			Weld:Destroy()
			LariatTrail.Anchored = true
			for i, v in ipairs(LariatTrail:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	elseif Phase == "2" then
		local function RandomRadian()
			local Min = -90
			local Max = 90
			return math.rad(math.random(Min, Max))
		end

		local PartSize = 1.5

		local Offset = {
			[1] = CFrame.new(-5, -3, 0);
			[2] = CFrame.new(1.5, -3, 0)
		}

		local DebrisModel = Instance.new("Model")
		DebrisModel.Parent = workspace.Effects[Character.Name]

		local RP = RaycastParams.new()
		RP.FilterType = Enum.RaycastFilterType.Exclude
		RP.FilterDescendantsInstances = {workspace.Entities, DebrisModel}

		local Floor = workspace:Raycast(Target.HumanoidRootPart.Position, Vector3.new(0, -50, 0), RP)
		if Floor then
			local Material = Floor.Material
			local Color = Floor.Instance.Color
			local Transparency = Floor.Instance.Transparency

			local Duration = 1
			local SetRate = 0.02
			local Rate = 0
			local Accumulated = 0
			local Connection
			Connection = RunService.Heartbeat:Connect(function(DeltaTime)
				Accumulated += DeltaTime
				Duration -= DeltaTime

				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
					Debris:AddItem(DebrisModel, 0.2)
				end

				if Accumulated > Rate then
					Rate = SetRate
					Accumulated -= Rate
					for i = 1, 2 do
						local Part = Instance.new("Part")
						Part.Anchored = true
						Part.CanCollide = false
						Part.Size = Vector3.zero
						Part.TopSurface = Enum.SurfaceType.Smooth
						Part.BottomSurface = Enum.SurfaceType.Smooth
						Part.CFrame = Target.HumanoidRootPart.CFrame * Offset[i] * CFrame.Angles(RandomRadian(), RandomRadian(), RandomRadian())

						local AccurateRay = workspace:Raycast(Part.Position + Vector3.new(0, 2, 0), Vector3.new(0, -50, 0), RP)
						if AccurateRay then
							Part.Material = AccurateRay.Material
							Part.Transparency = AccurateRay.Instance.Transparency
							Part.Color = AccurateRay.Instance.Color
						else
							Part.Material = Material
							Part.Transparency = Transparency
							Part.Color = Color
						end

						Part.Parent = DebrisModel

						local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

						TweenService:Create(Part, Info, {Size = Vector3.new(PartSize, PartSize, PartSize)}):Play()
						task.delay(2.5, function()
							TweenService:Create(Part, Info, {Size = Vector3.zero}):Play()
						end)
					end

					local DebrisData = {
						Amount = 1,
						Collidable = true,
						VelocityMin = 30,
						VelocityMax = 50,
						PartSize = 1.5,
						Duration = 2,
					}

					ImpactCrater:Debris(Character, Target.HumanoidRootPart.CFrame * CFrame.new(3, -3, 0), DebrisData)
				end
			end)
		end
	elseif Phase == "3" then
		local CraterData = {
			CanCollide = true,
			Radius = Range,
			PartSize = 6,
			SizeMin = 0,
			SizeMax = 2,
			Duration = 7,
			TweenTime = 0.3,
		}

		ImpactCrater:CircleCrater(Character, SpawnCFrame, CraterData)

		local DebrisData = {
			Amount = math.random(15, 20),
			Collidable = true,
			VelocityMin = 70,
			VelocityMax = 100,
			PartSize = 3,
			PartMin = -1.5,
			PartMax = 1.5,
			Duration = 5,
			RandomMin = -Range,
			RandomMax = Range,
		}

		ImpactCrater:RandomDebris(Character, SpawnCFrame, DebrisData)
		
		local AudioBlock = Instance.new("Part")
		AudioBlock.CanCollide = false
		AudioBlock.Anchored = true
		AudioBlock.CFrame = SpawnCFrame
		AudioBlock.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(AudioBlock, 0.1)
		
		local ShockwaveSound = SpecialSounds.TrueGraspShockwave:Clone()
		ShockwaveSound.PlayOnRemove = true
		ShockwaveSound.Parent = AudioBlock
		ShockwaveSound:Destroy()
		ShockwaveSound = nil
	elseif Phase == "4" then
		local GreatswordSound = ReplicatedStorage.Assets.ShikaiSounds.GreatswordCrit:Clone()
		GreatswordSound.PlayOnRemove = true
		GreatswordSound.Parent = Target.HumanoidRootPart
		GreatswordSound:Destroy()
		GreatswordSound = nil

		local GSCritEffect = ReplicatedStorage.Assets.Effects["GS Crit Effect"]:Clone()
		GSCritEffect.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(-3, 0, 4)
		GSCritEffect.Parent = workspace.Effects[Character.Name]
		for i, v in ipairs(GSCritEffect.Attachment:GetDescendants()) do
			v:Emit(50)
		end
		Debris:AddItem(GSCritEffect, 1.5)

		local DebrisData = {
			Amount = math.random(3, 5),
			Collidable = true,
			VelocityMin = 30,
			VelocityMax = 50,
			PartSize = 1.5,
			Duration = 2,
		}

		ImpactCrater:Debris(Character, Target.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0), DebrisData)
	elseif Phase == "5" then
		local Shockwave = ReplicatedStorage.Assets.Effects.Shockwave:Clone()
		Shockwave.Size = Vector3.zero
		Shockwave.CFrame = Character.HumanoidRootPart.CFrame
		Shockwave.Transparency = 0.6
		Shockwave.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Shockwave, 2.5)

		local Info = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false)
		TweenService:Create(Shockwave, Info, {Size = Vector3.new(40, 1, 40)}):Play()
		task.delay(0.5, function()
			TweenService:Create(Shockwave, Info, {Transparency = 1}):Play()
		end)
		
		local TrueGraspSiu = SpecialSounds.TrueGraspSiu:Clone()
		TrueGraspSiu.Parent = Character.HumanoidRootPart
		TrueGraspSiu:Play()
		Debris:AddItem(TrueGraspSiu, TrueGraspSiu.TimeLength)
	end
end

function ClientSkills.FangReversal(Character, Counter, CounterOwner, CounterDuration, HighestStat)
	if Counter == "Counter" then
		local FangReversal = SpecialSounds.FangReversal:Clone()
		FangReversal.PlayOnRemove = true
		FangReversal.Parent = CounterOwner.PrimaryPart
		FangReversal:Destroy()
		FangReversal = nil
	elseif Counter == "Countered" then
		local Offset = CFrame.new(-0.975250244, -2.20600319, -8.04216003, -0.990269244, -6.04242086e-06, -0.13916485, 0.0406829119, 0.95630306, -0.289532989, 0.133085519, -0.292377234, -0.946997285)
		local BeamSize = Vector3.new(3.258, 3.186, 11.7)
		local CeroSize = Vector3.new(3.028, 3.024, 11.608)

		local CeroGrab = HollowEffects.CeroGrab:Clone()
		if HighestStat then
			CeroGrab.Beam.Color = CeroColors[HighestStat]
		end

		--CeroGrab.PrimaryPart.CFrame = Character["Left Arm"].CFrame * Offset * CFrame.new(0, 0, -BeamSize.Z / 2)
		CeroGrab.PrimaryPart.CFrame = CounterOwner.HumanoidRootPart.CFrame * Offset * CFrame.new(0, 0, -BeamSize.Z / 2)
		CeroGrab.Parent = workspace.Effects[CounterOwner.Name]

		for i, v in ipairs(CeroGrab:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local BeamPosition = (CeroGrab.PrimaryPart.CFrame * CFrame.new(0, 0, BeamSize.Z / 2)).Position
		local CeroPosition = (CeroGrab.PrimaryPart.CFrame * CFrame.new(0, 0, CeroSize.Z / 2)).Position

		local Info = TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(CeroGrab.Beam, Info, {Size = BeamSize, Position = BeamPosition}):Play()
		TweenService:Create(CeroGrab.cero, Info, {Size = CeroSize, Position = CeroPosition}):Play()
		task.delay(0.25, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(CeroGrab.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(CeroGrab.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			CeroGrab.PrimaryPart.CFrame = CeroGrab.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = CeroGrab.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(0.4, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(CeroGrab.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(CeroGrab.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			task.wait(0.4)
			CeroGrab:Destroy()
		end)

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = CounterOwner.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil
	elseif Counter == "Snap" then
		local FangReversal = SpecialSounds.FangReversalFinger:Clone()
		FangReversal.PlayOnRemove = true
		FangReversal.Parent = CounterOwner.PrimaryPart
		FangReversal:Destroy()
		FangReversal = nil
	end
end

function ClientSkills.CripplingStorm(Character, Phase, RootCFrame, Radius)
	if Phase == "1" then
		-- 0.7, 1.18
		local CripplingStormBolts = SpecialEffects.CripplingStormBolt:Clone()
		CripplingStormBolts.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CripplingStormBolts, 1.18 + 0.5)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(1.24924088, 1.58522034, 0.0260620117, 0, 0.99999994, 0, 0, 0, 1, 1, 0, 0)
		Weld.Part0 = CripplingStormBolts.CripplingBoltsR
		Weld.Part1 = Character["Right Arm"]
		Weld.Parent = CripplingStormBolts.CripplingBoltsR
		
		local Weld2 = Instance.new("Weld")
		Weld2.C0 = CFrame.new( 1.24924088, 1.58522034, -0.0381469727, 0, 0.99999994, 0, 0, 0, 1, 1, 0, 0)
		Weld2.Part0 = CripplingStormBolts.CripplingBoltsL
		Weld2.Part1 = Character["Left Arm"]
		Weld2.Parent = CripplingStormBolts.CripplingBoltsL
		
		local function DisableParticles(Object)
			for i, v in ipairs(Object:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") then
					v.Enabled = false
				end
			end
		end
		
		local CripplingStormSound = SpecialSounds.CripplingStormStart:Clone()
		CripplingStormSound.PlayOnRemove = true
		CripplingStormSound.Parent = Character.PrimaryPart
		CripplingStormSound:Destroy()
		CripplingStormSound = nil
		
		task.delay(0.7, function()
			DisableParticles(CripplingStormBolts.CripplingBoltsR)
		end)
		task.delay(1.18, function()
			DisableParticles(CripplingStormBolts.CripplingBoltsL)
		end)
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.0910644531, -2.99950027, -0.101348877, 0, 0, 1, 0, 1, 0, -1, 0, 0)
		
		local CripplingExplosion = SpecialEffects.CripplingStormExplosion:Clone()
		CripplingExplosion.CFrame = RootCFrame * Offset
		CripplingExplosion.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CripplingExplosion, 1)
		
		for i, v in ipairs(CripplingExplosion:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local function TeleportFx(Character, OldCFrame, Settings, CurrentCFrame)
			local function RandomOffset(Min, Max)
				local RNG = Random.new()
				return Vector3.new(RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max))
			end

			local function RandomNumber(Min, Max)
				local RNG = Random.new()
				return RNG:NextNumber(Min, Max)
			end

			local function CreateJoint(Joint, PreviousPart, EndPosition)
				local Offset = -PreviousPart.Size.Z / 2
				local PreviousCFrame = PreviousPart.CFrame * CFrame.new(0, 0, Offset)

				Joint.CFrame = CFrame.new(PreviousCFrame.Position, EndPosition) * CFrame.new(0, 0, -Joint.Size.Z/2)
				Joint.Parent = workspace.Effects[Character.Name]
				return Joint
			end

			local Duration = 0.45
			local Width = 0.3
			local Min = 2
			local Max = 7
			local SpawnPoint = CurrentCFrame or Character.HumanoidRootPart.CFrame

			if Settings then
				Width = Settings.Width
				Min = Settings.Min
				Max = Settings.Max
			end

			local Streaks = {}
			for i = 1, 20 do
				if i == 1 then
					Streaks[i] = ReplicatedStorage.Assets.Effects.Res.Storm.TeleportFx:Clone()
					Streaks[i].Size = Vector3.new(Width, Width, RandomNumber(Min, Max))
					Streaks[i].CFrame = CFrame.new(OldCFrame.Position, SpawnPoint.Position + RandomOffset(-10, 10)) * CFrame.new(0, 0, -Streaks[i].Size.Z/2)
					Streaks[i].Parent = workspace.Effects[Character.Name]
					Debris:AddItem(Streaks[i], Duration)
				else
					local PreviousStreak = Streaks[i - 1]

					local Magnitude = (PreviousStreak.Position - SpawnPoint.Position).Magnitude
					local Streak = ReplicatedStorage.Assets.Effects.Res.Storm.TeleportFx:Clone()
					Streak.Size = Vector3.new(Width, Width, RandomNumber(Min, Max))
					if Magnitude <= Streak.Size.Z then
						Streak.Size = Vector3.new(Width, Width, Magnitude)

						Streaks[i] = CreateJoint(Streak, PreviousStreak, SpawnPoint.Position)
						Debris:AddItem(Streaks[i], Duration)
						break
					else
						Streaks[i] = CreateJoint(Streak, PreviousStreak, SpawnPoint.Position + RandomOffset(-7, 7))
						Debris:AddItem(Streaks[i], Duration)
					end
				end
			end
			
			local function Flash(Part, Duration)
				local FadeTime = 0.15
				local Flashes = 4
				local FlashRate = (Duration - FadeTime) / Flashes

				for i = 1, Flashes do
					if i % 2 == 0 then
						Part.Transparency = 0.6
					else
						Part.Transparency = 0
					end
					task.wait(FlashRate)
				end

				TweenService:Create(Part, TweenInfo.new(FadeTime), {Transparency = 1, Size = Vector3.new(0, 0, Part.Size.Z)}):Play()
				
				FadeTime = nil
				Flashes = nil
				FlashRate = nil
			end
			
			task.delay(0.1, function()
				for _, v in ipairs(Streaks) do
					coroutine.wrap(Flash)(v, Duration - 0.1)
				end
			end)
		end
	
		local CripplingStormSound = SpecialSounds.CripplingStorm:Clone()
		CripplingStormSound.PlayOnRemove = true
		CripplingStormSound.Parent = Character.PrimaryPart
		CripplingStormSound:Destroy()
		CripplingStormSound = nil
		
		local function RandomNumber(Min, Max)
			return Random.new():NextNumber(Min, Max)
		end
		
		local Settings = {
			Width = 1;
			Min = 2;
			Max = 7;
		}
		
		for i = 1, math.random(6, 11) do
			local CurrentCFrame = RootCFrame * CFrame.new(RandomNumber(-Radius, Radius), 60, RandomNumber(-Radius, Radius))
			TeleportFx(Character, CurrentCFrame, Settings, CurrentCFrame * CFrame.new(0, -60, 0))
			task.delay(0.2, function()
				TeleportFx(Character, CurrentCFrame, Settings, CurrentCFrame * CFrame.new(0, -60, 0))
			end)
			
			task.wait(0.05)
		end
	end	
end

function ClientSkills.SplitSkies(Character, Phase, RootCFrame, CeroStats, Properties)
	if Phase == "1" then
		local CeroFloor = HollowEffects.CeroFloorIndicator:Clone()
		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		if HighestStat then
			CeroFloor.Color = CeroColors[HighestStat]
		end
		CeroFloor.Size = Vector3.new(Properties.Width * 2, 0.1, 0)
		CeroFloor.CFrame = RootCFrame * CFrame.new(0, -2.5, 0)
		CeroFloor.Transparency = 1
		CeroFloor.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroFloor, 0.95)

		TweenService:Create(CeroFloor, TweenInfo.new(0.6), {Transparency = 0, Size = Vector3.new(Properties.Width * 2, 0.1, Properties.Range), CFrame = CeroFloor.CFrame * CFrame.new(0, 0, -Properties.Range/2)}):Play()
		task.delay(0.65, function()
			TweenService:Create(CeroFloor, TweenInfo.new(0.3), {Transparency = 1}):Play()
		end)
		
		local SplitSkiesSound = SpecialEffects.SplitSkiesStart:Clone()
		SplitSkiesSound.PlayOnRemove = true
		SplitSkiesSound.Parent = Character.PrimaryPart
		SplitSkiesSound:Destroy()
		SplitSkiesSound = nil
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.649169922, -39.1250038, 0.398300171, -4.37113812e-08, 0.999999762, -4.37113812e-08, 0, -4.37113883e-08, -1, -1, -4.37113883e-08, 1.91068547e-15)
		
		local Cero = HollowEffects.Cero:Clone()

		local HighestStat
		if CeroStats then
			HighestStat = CeroStats.HighestStat
		end
		if HighestStat then
			Cero.Beam.Color = CeroColors[HighestStat]
		end

		local CeroFireSound = HollowSounds.CeroFire:Clone()
		CeroFireSound.PlayOnRemove = true
		CeroFireSound.Parent = Character.PrimaryPart
		CeroFireSound:Destroy()
		CeroFireSound = nil

		local BeamSize = Vector3.new(24.258, 25.186, 73.7)
		local CeroSize = Vector3.new(21.028, 22.024, 73.608)

		Cero.PrimaryPart.CFrame = RootCFrame * Offset --* CFrame.new(Vector3.new(0, 0, (-BeamSize.Z / 2) - 1))
		Cero.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Cero:GetChildren()) do
			v.Size = Vector3.new(0, 0, 0)
		end

		local Info = TweenInfo.new(0.55, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false)

		TweenService:Create(Cero.Beam, Info, {Size = BeamSize}):Play()
		TweenService:Create(Cero.cero, Info, {Size = CeroSize}):Play()
		task.delay(0.5, function()
			local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = BeamSize + Vector3.new(1, 1, 1)}):Play()
			TweenService:Create(Cero.cero, Info, {Size = CeroSize + Vector3.new(1, 1, 1)}):Play()
		end)

		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Cero.PrimaryPart.CFrame = Cero.PrimaryPart.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, 1)
		end)
		local DestroyConnection
		DestroyConnection = Cero.Destroying:Connect(function()
			Connection:Disconnect()
			Connection = nil
			DestroyConnection:Disconnect()
			DestroyConnection = nil
		end)

		task.delay(1.05, function()
			local Info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			TweenService:Create(Cero.Beam, Info, {Size = Vector3.new(0, 0, BeamSize.Z + 1), Transparency = 1}):Play()
			TweenService:Create(Cero.cero, Info, {Size = Vector3.new(0, 0, CeroSize.Z + 1), Transparency = 1}):Play()
			task.wait(0.4)
			Cero:Destroy()
		end)
	end
end

function ClientSkills.Divinity(Character, Phase, RootCFrame, Radius)
	if Phase == "1" then
		local DivinitySound = SpecialSounds.Divinity:Clone()
		DivinitySound.PlayOnRemove = true
		DivinitySound.Parent = Character.PrimaryPart
		DivinitySound:Destroy()
		DivinitySound = nil
	elseif Phase == "2" then
		local Offset = CFrame.new(-0.10534668, 15.1843605, -0.0129394531, -1, 0, 0, 0, 1, 0, 0, 0, -1)
		
		local Divinity = SpecialEffects.Divinity:Clone()
		Divinity.CFrame = RootCFrame * Offset
		Divinity.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Divinity, 0.75)
		
		for i, v in ipairs(Divinity:GetChildren()) do
			v:Emit(tonumber(v.Name))
		end
		
		local function RandomAngle()
			local Min, Max = -math.pi * 2, math.pi * 2
			local RNG = Random.new()
			return CFrame.Angles(RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max))
		end

		local function SpawnCFrame(SpawnLocation)
			local Min, Max = -4, 4
			local RNG = Random.new()
			return SpawnLocation * CFrame.new(RNG:NextNumber(Min, Max), RNG:NextNumber(-2, Max), RNG:NextNumber(Min, Max)) * RandomAngle()
		end

		local function RandomNumber(Min, Max)
			local RNG = Random.new()
			return RNG:NextNumber(Min, Max)
		end

		local function CreateJoint(Joint, PreviousPart)
			local Offset = -PreviousPart.Size.Z / 2
			local PreviousCFrame = PreviousPart.CFrame * CFrame.new(0, 0, Offset)

			Joint.CFrame = CFrame.new(PreviousCFrame.Position) * RandomAngle() * CFrame.new(0, 0, -Joint.Size.Z/2)
			Joint.Parent = workspace.Effects[Character.Name]
			return Joint
		end

		local function CreateStreak(RootCFrame)
			local Duration = 0.45
			local SpawnPoint = RootCFrame or Character.HumanoidRootPart.CFrame

			local Streaks = {}
			for i = 1, 5 do
				if i == 1 then
					Streaks[i] = ReplicatedStorage.Assets.Effects.Res.Storm.TeleportFx:Clone()
					Streaks[i].Color = Color3.fromRGB(196, 153, 255)
					Streaks[i].Size = Vector3.new(0.3, 0.3, RandomNumber(5, 11))
					Streaks[i].CFrame = SpawnCFrame(SpawnPoint)
					Streaks[i].Parent = workspace.Effects[Character.Name]
					Debris:AddItem(Streaks[i], Duration)
				else
					local Streak = ReplicatedStorage.Assets.Effects.Res.Storm.TeleportFx:Clone()
					Streak.Color = Color3.fromRGB(196, 153, 255)
					Streak.Size = Vector3.new(0.3, 0.3, RandomNumber(5, 11))

					Streaks[i] = CreateJoint(Streak, Streaks[i - 1])
					Debris:AddItem(Streaks[i], Duration)
				end
			end

			local StreakSound = ReplicatedStorage.Assets.ResSounds.Storm.LightningStreak:Clone()
			StreakSound.PlayOnRemove = true
			StreakSound.Parent = Character.HumanoidRootPart
			StreakSound:Destroy()
			StreakSound = nil

			local function Flash(Part, Duration)
				local FadeTime = 0.15
				local Flashes = 4
				local FlashRate = (Duration - FadeTime) / Flashes

				for i = 1, Flashes do
					if i % 2 == 0 then
						Part.Transparency = 0.6
					else
						Part.Transparency = 0
					end
					task.wait(FlashRate)
				end

				TweenService:Create(Part, TweenInfo.new(FadeTime), {Transparency = 1, Size = Vector3.new(0, 0, Part.Size.Z)}):Play()
			end

			task.delay(0.1, function()
				for _, v in ipairs(Streaks) do
					coroutine.wrap(Flash)(v, Duration - 0.1)
				end
			end)
		end

		for i = 1, 15 do
			local Amount = RandomNumber(2, 5)
			local StartingCFrame = RootCFrame * CFrame.new(RandomNumber(-Radius, Radius), RandomNumber(-2, Radius), RandomNumber(-Radius, Radius))

			task.spawn(function()
				for i = 1, Amount do
					CreateStreak(StartingCFrame)
					task.wait(RandomNumber(0.05, 0.15))
				end
			end)
			task.wait()
		end
	end
end

function ClientSkills.Scream(Character, Phase)
	local Scream = SpecialEffects.Scream:Clone()
	Scream.Parent = workspace.Effects[Character.Name]

	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(-0.217498779, -1.32499695, 0.115722656, 0, -1, 0, 0, 0, -1, 1, 0, 0)
	Weld.Part0 = Scream
	Weld.Part1 = Character.Head
	Weld.Parent = Scream

	task.delay(0.8, function()
		for i, v in ipairs(Scream:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
				v.LockedToPart = false
			end
		end
	end)

	local ScreamSound = SpecialSounds.Scream:Clone()
	ScreamSound.Parent = Character.PrimaryPart
	ScreamSound:Play()
	Debris:AddItem(ScreamSound, ScreamSound.TimeLength)
end

function ClientSkills.FrozenPoint(Character, Phase, RootCFrame, Target, FreezeDuration, Circle)
	if Phase == "1" then
		local Offset = CFrame.new(-0.101531982, -2.9298954, 0.0746307373, 1.00000322, 0, -2.98023224e-08, 0, 1, 0, 2.98023224e-08, 0, 1.00000322)
		local FrozenPoint = SpecialEffects.FrozenPointCircle:Clone()
		FrozenPoint.Name = Character.Name .. "FrozenPointCircle"
		FrozenPoint:PivotTo(RootCFrame * Offset)
		FrozenPoint.Parent = workspace.Effects[Character.Name]
	elseif Phase == "2" then
		if not Circle then
			for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
				if v.Name == Character.Name .. "FrozenPointCircle" then
					v:Destroy()
				end
			end
		end
		
		local FreezeEffect = ReplicatedStorage.Assets.Effects.Shikais.Ice.FrozenEffect:Clone()
		FreezeEffect.CFrame = RootCFrame * CFrame.new(0, -0.4679, 0)
		FreezeEffect.Anchored = true
		FreezeEffect.Parent = workspace.Effects[Character.Name]
		FreezeEffect.Transparency = 1
		TweenService:Create(FreezeEffect, TweenInfo.new(0.15), {Transparency = 0.6}):Play()

		task.delay(FreezeDuration, function()
			local ShatterEffects = ReplicatedStorage.Assets.Effects.Shikais.Ice.IceShatterEffect:Clone()
			ShatterEffects.CFrame = FreezeEffect.CFrame
			ShatterEffects.Parent = workspace.Effects[Character.Name]
			ShatterEffects.Specs:Emit(35)
			Debris:AddItem(ShatterEffects, 1)

			local UnfreezeAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice["Ice Shatter 1"]:Clone()
			UnfreezeAudio.PlayOnRemove = true
			UnfreezeAudio.Parent = FreezeEffect
			UnfreezeAudio:Destroy()
			UnfreezeAudio = nil
			
			FreezeEffect:Destroy()
			FreezeEffect = nil
		end)
	elseif Phase == "3" then
		local FreezeEffect = ReplicatedStorage.Assets.Effects.Shikais.Ice.FrozenEffect:Clone()
		FreezeEffect.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, -0.4679, 0))
		FreezeEffect.Anchored = false
		FreezeEffect.Parent = workspace.Effects[Character.Name]
		FreezeEffect.Transparency = 1
		TweenService:Create(FreezeEffect, TweenInfo.new(0.15), {Transparency = 0.6}):Play()
		Debris:AddItem(FreezeEffect, FreezeDuration)

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = FreezeEffect
		Weld.Part1 = Target.HumanoidRootPart
		Weld.Parent = FreezeEffect

		local FreezeFormAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice.Freeze:Clone()
		FreezeFormAudio.PlayOnRemove = true
		FreezeFormAudio.Parent = Target.HumanoidRootPart
		FreezeFormAudio:Destroy()
		FreezeFormAudio = nil

		task.delay(FreezeDuration, function()
			local ShatterEffects = ReplicatedStorage.Assets.Effects.Shikais.Ice.IceShatterEffect:Clone()
			ShatterEffects.CFrame = Target.HumanoidRootPart.CFrame
			ShatterEffects.Parent = workspace.Effects[Character.Name]
			ShatterEffects.Specs:Emit(35)
			Debris:AddItem(ShatterEffects, 1)

			local UnfreezeAudio = ReplicatedStorage.Assets.ShikaiSounds.Ice["Ice Shatter 1"]:Clone()
			UnfreezeAudio.PlayOnRemove = true
			UnfreezeAudio.Parent = Target.HumanoidRootPart
			UnfreezeAudio:Destroy()
			UnfreezeAudio = nil
		end)
	end
end

function ClientSkills.Impact(Character, Phase, RootCFrame)
	if Phase == "1" then
		
	elseif Phase == "2" then
		local Offset = CFrame.new(0.16998291, 1.38500404, 2.91351318, 1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, 1)
		
		local Impact = SpecialEffects.Impact1:Clone()
		Impact.CFrame = RootCFrame * Offset
		Impact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Impact, 1.2)
		
		for i, v in ipairs(Impact:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
	elseif Phase == "3" then
		local ImpactSweep = SpecialEffects.ImpactSweep:Clone()
		ImpactSweep.CFrame = RootCFrame
		ImpactSweep.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ImpactSweep, 0.5)
		
		for i, v in ipairs(ImpactSweep:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
	elseif Phase == "4" then
		local Offset = CFrame.new(0.424987793, 1.9125042, 2.91351318, 1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, 1)
		local Impact = SpecialEffects.Impact2:Clone()
		Impact.CFrame = RootCFrame * Offset
		Impact.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Impact, 1.2)

		for i, v in ipairs(Impact:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
	end
end

function ClientSkills.Cleave(Character, Phase, Target, Duration)
	if Phase == "1" then
		
	elseif Phase == "2" then
		local Cleave = SpecialEffects.Cleave.SukunaSlashes:Clone()
		Cleave.Parent = Target.HumanoidRootPart
		Debris:AddItem(Cleave, Duration + 0.25)
		
		task.delay(Duration, function()
			for i, v in ipairs(Cleave:GetChildren()) do
				v.Enabled = false
			end
		end)
	end
end

function ClientSkills.Ceroworks(Character, Phase, Duration, CeroStats)
	if Phase == "1" then
		
	elseif Phase == "2" then
		local Clone = SharedFunctions:CreateClone(Character, Character.HumanoidRootPart.CFrame, nil, "NoCollide", "NoAnchoredCollision")
		for i, v in ipairs(Clone:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				if v.Transparency ~= 1 then
					v.Transparency = 0.6
				end

				if v:IsA("BasePart") then
					v.Massless = true
				end
			end
		end
		Debris:AddItem(Clone, 3.08)
		
		local AudioDebounce
		local Accumulated = 0
		local Tick = tick()
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			
			if tick() - Tick >= 3.08 or not Clone.Parent then
				Connection:Disconnect()
				Connection = nil
				return
			end
			
			if Accumulated > 0.1 and not AudioDebounce then
				Accumulated -= 0.1
				
				local StarrkSwing = ReplicatedStorage.Assets.WeaponSounds.StarrkSwing:Clone()
				StarrkSwing.Volume = 3.2
				StarrkSwing.PlayOnRemove = true
				StarrkSwing.Parent = Character.HumanoidRootPart
				StarrkSwing:Destroy()
				StarrkSwing = nil
			end
			
			Clone.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
		end)
		

		local CeroworksShadowAnimation = ReplicatedStorage.Assets.SkillAnimations.Special.SkillCeroworksShadow
		local Animation = Clone.Humanoid.Animator:LoadAnimation(CeroworksShadowAnimation)
		Animation:Play()
		
		task.delay(2.9, function()
			for i, v in ipairs(Clone:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("Decal") then
					if v.Transparency ~= 1 then
						TweenService:Create(v, TweenInfo.new(0.18), {Transparency = 1}):Play()
					end
				end
			end
		end)
		
		local CeroworksFx = SpecialEffects.Ceroworks:Clone()
		if CeroStats and CeroStats.HighestStat then
			for i, v in ipairs(CeroworksFx:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CeroColors[CeroStats.HighestStat]),
						ColorSequenceKeypoint.new(1, CeroColors[CeroStats.HighestStat]),
					})
				end
			end
		end
		CeroworksFx.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(CeroworksFx, Duration + 1.2)		
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = CeroworksFx
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = CeroworksFx
		
		task.delay(Duration, function()
			AudioDebounce = true
			
			for i, v in ipairs(CeroworksFx:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)
	end
end

function ClientSkills.CeroKing(Character)
	Character.HumanoidRootPart.Anchored = true
	
	local Camera = workspace.Camera
	local CinematicsFolder = ReplicatedStorage.Assets.Cinematics.Cero_King.Frames -- Frames folder

	local CFrameOffset = Character.HumanoidRootPart.CFrame

	local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	local Frame = 0
	local CameraConnection
	CameraConnection = RunService.RenderStepped:Connect(function(DeltaTime)
		Frame += DeltaTime * 60
		local CameraFrame = CinematicsFolder:FindFirstChild(tonumber(math.ceil(Frame)))
		if CameraFrame then
			Camera.CFrame = CFrameOffset * CameraFrame.Value
		else
			CameraConnection:Disconnect()
			CameraConnection = nil
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CFrame = CurrentCameraCFrame
			Character.HumanoidRootPart.Anchored = false
		end
	end)

	local PlayerGui = Players.LocalPlayer.PlayerGui
	local CinematicBars = PlayerGui.ScreenEffects.CinematicBars
	local TopBarPosition = CinematicBars.TopBar.Position
	local BottomBarPosition = CinematicBars.BottomBar.Position

	CinematicBars.TopBar.Position = UDim2.new(0.5, 0, -0.1, 0)
	CinematicBars.BottomBar.Position = UDim2.new(0.5, 0, 1.1, 0)

	CinematicBars.Visible = true
	PlayerGui.DisplayUI.Enabled = false
	PlayerGui.Toolbar.Enabled = false

	local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
	TweenService:Create(CinematicBars.TopBar, Info, {Position = TopBarPosition}):Play()
	TweenService:Create(CinematicBars.BottomBar, Info, {Position = BottomBarPosition}):Play()

	task.delay(4.7, function()
		PlayerGui.DisplayUI.Enabled = true
		PlayerGui.Toolbar.Enabled = true

		TweenService:Create(CinematicBars.TopBar, Info, {Position = UDim2.new(0.5, 0, -0.1, 0)}):Play()
		TweenService:Create(CinematicBars.BottomBar, Info, {Position = UDim2.new(0.5, 0, 1.1, 0)}):Play()

		task.wait(0.2)

		CinematicBars.Visible = false
	end)
end

function ClientSkills.Cat(Character)
	local CatParticles = ReplicatedStorage.Assets.Effects.YoruichiCat
	
	for i, v in ipairs(CatParticles:GetChildren()) do
		local Particle = v:Clone()
		Particle.Parent = Character.HumanoidRootPart
		Debris:AddItem(Particle, 2)
		
		Particle:Emit(20)
	end
	
	local CatSound = ReplicatedStorage.Assets.Sounds.YoruichiTransform:Clone()
	CatSound.PlayOnRemove = true
	CatSound.Parent = Character.HumanoidRootPart
	CatSound:Destroy()
	CatSound = nil
end

--==================================================
--=====================Healing======================
--==================================================

function ClientSkills.MedicStart(Character, Target)
	local MedicSound = HealingSounds.Medic:Clone()
	MedicSound.Parent = Target.HumanoidRootPart
	MedicSound:Play()
	Debris:AddItem(MedicSound, MedicSound.TimeLength)
	
	local MedicEffect = HealingEffects.HealFX:Clone()
	MedicEffect.Anchored = false
	MedicEffect.Parent = workspace.Effects[Character.Name]
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(8.77380371e-05, 2.99953294, 0.00020980835, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Part0 = MedicEffect
	Weld.Part1 = Target.HumanoidRootPart
	Weld.Parent = MedicEffect
	
	MedicEffect.Specs.Enabled = true
	MedicEffect.Attachment.Particle.Enabled = true
	
	local HandHealFx = HealingEffects.HealHandFx.HandHeal:Clone()
	HandHealFx.Parent = Character["Left Arm"]
	HandHealFx.Lightning.Enabled = true

	local HandHealFx2 = HealingEffects.HealHandFx.HandHeal:Clone()
	HandHealFx2.Parent = Character["Right Arm"]
	HandHealFx2.Lightning.Enabled = true
end

function ClientSkills.MedicStop(Character)
	for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
		if v.Name == "HealFX" then
			v.Specs.Enabled = false
			v.Attachment.Particle.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
	for i, v in ipairs(Character["Right Arm"]:GetChildren()) do
		if v.Name == "HandHeal" then
			v.Lightning.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
	for i, v in ipairs(Character["Left Arm"]:GetChildren()) do
		if v.Name == "HandHeal" then
			v.Lightning.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
end

function ClientSkills.MedicAudio(Character, Target)
	local MedicSound = HealingSounds.Medic:Clone()
	MedicSound.Parent = Target.HumanoidRootPart
	MedicSound:Play()
	Debris:AddItem(MedicSound, MedicSound.TimeLength)
end

function ClientSkills.Medic2(Character)

end

function ClientSkills.Medic3(Character)

end

function ClientSkills.SelfHealStart(Character)
	local SelfHealSound = HealingSounds.SelfHeal:Clone()
	SelfHealSound.Parent = Character.HumanoidRootPart
	SelfHealSound:Play()
	Debris:AddItem(SelfHealSound, SelfHealSound.TimeLength)

	local SelfHealEffect = HealingEffects.HealFX:Clone()
	SelfHealEffect.Anchored = false
	SelfHealEffect.Parent = workspace.Effects[Character.Name]

	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(8.77380371e-05, 2.99953294, 0.00020980835, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	Weld.Part0 = SelfHealEffect
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = SelfHealEffect
	
	SelfHealEffect.Specs.Enabled = true
	SelfHealEffect.Attachment.Particle.Enabled = true
	
	local HandHealFx = HealingEffects.HealHandFx.HandHeal:Clone()
	HandHealFx.Parent = Character["Left Arm"]
	HandHealFx.Lightning.Enabled = true
end

function ClientSkills.SelfHealStop(Character)
	for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
		if v.Name == "HealFX" then
			v.Specs.Enabled = false
			v.Attachment.Particle.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
	for i, v in ipairs(Character["Left Arm"]:GetChildren()) do
		if v.Name == "HandHeal" then
			v.Lightning.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
end

function ClientSkills.SelfHealAudio(Character)
	local SelfHealSound = HealingSounds.SelfHeal:Clone()
	SelfHealSound.Parent = Character.HumanoidRootPart
	SelfHealSound:Play()
	Debris:AddItem(SelfHealSound, SelfHealSound.TimeLength)
end

function ClientSkills.SelfHeal2(Character)

end

function ClientSkills.SelfHeal3(Character)

end

function ClientSkills.Barrier(Character, Target)
	local BarrierSound = HealingSounds.Barrier:Clone()
	BarrierSound.Parent = Target.HumanoidRootPart
	BarrierSound:Play()
	Debris:AddItem(BarrierSound, BarrierSound.TimeLength)
	
	local BarrierEffect = HealingEffects.Barrier:Clone()
	BarrierEffect.Anchored = false
	BarrierEffect.Transparency = 1
	BarrierEffect.Parent = Target.HumanoidRootPart
	
	local Weld = Instance.new("Weld")
	Weld.C0 = CFrame.new(0.147186279, 0.550000429, -0.0577583313, 0.052335754, 3.00133252e-11, -0.99862957, 8.87626084e-11, 0.999999821, -2.54026834e-11, 0.99862957, 8.73114914e-11, 0.052335754)
	Weld.Part0 = BarrierEffect
	Weld.Part1 = Target.HumanoidRootPart
	Weld.Parent = BarrierEffect
	
	TweenService:Create(BarrierEffect, TweenInfo.new(0.3), {Transparency = 0}):Play()
	BarrierEffect.Specs.Enabled = true
	
	local CharacterDied
	local CharacterRemoving
	local Connection
	Connection = Target:GetAttributeChangedSignal("BarrierHits"):Connect(function()
		local BarrierHits = Target:GetAttribute("BarrierHits")
		if not BarrierHits or BarrierHits <= 0 then
			TweenService:Create(BarrierEffect, TweenInfo.new(0.3), {Transparency = 1}):Play()
			BarrierEffect.Specs.Enabled = false
			BarrierEffect.Shatter:Emit(5)
			BarrierEffect.Shatter2:Emit(5)
			Debris:AddItem(BarrierEffect, 1)
			Connection:Disconnect()
			Connection = nil
		end
		
		if CharacterRemoving then
			CharacterRemoving:Disconnect()
			CharacterRemoving = nil
		end
		if CharacterDied then
			CharacterDied:Disconnect()
			CharacterDied = nil
		end
	end)
	
	local Player = Players:GetPlayerFromCharacter(Target)
	if Player then
		CharacterRemoving = Player.CharacterRemoving:Connect(function()
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			if CharacterRemoving then
				CharacterRemoving:Disconnect()
				CharacterRemoving = nil
			end
		end)
	else
		CharacterDied = Target.Humanoid.Died:Connect(function()
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			if CharacterDied then
				CharacterDied:Disconnect()
				CharacterDied = nil
			end
		end)
	end
	
	local CharacterDestroying
	CharacterDestroying = Target.Destroying:Connect(function()
		if Connection then
			Connection:Disconnect()
			Connection = nil
		end
		CharacterDestroying:Disconnect()
		CharacterDestroying = nil
	end)
end

function ClientSkills.ReiatsuTransferStart(Character, Target)
	local ReiatsuTransferSound = HealingSounds.ReiatsuTransfer:Clone()
	ReiatsuTransferSound.Parent = Target.HumanoidRootPart
	ReiatsuTransferSound:Play()
	Debris:AddItem(ReiatsuTransferSound, ReiatsuTransferSound.TimeLength)
	
	local ReiatsuTransferEffect = HealingEffects.ReiatsuTransfer.ReiatsuHeal:Clone()
	ReiatsuTransferEffect.Parent = Character["Left Arm"]
	ReiatsuTransferEffect.Lightning.Enabled = true
	
	local ReiatsuTransferEffect2 = HealingEffects.ReiatsuTransfer.ReiatsuHeal:Clone()
	ReiatsuTransferEffect2.Parent = Character["Right Arm"]
	ReiatsuTransferEffect2.Lightning.Enabled = true
end

function ClientSkills.ReiatsuTransferStop(Character)
	for i, v in ipairs(Character["Right Arm"]:GetChildren()) do
		if v.Name == "ReiatsuHeal" then
			v.Lightning.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
	for i, v in ipairs(Character["Left Arm"]:GetChildren()) do
		if v.Name == "ReiatsuHeal" then
			v.Lightning.Enabled = false
			Debris:AddItem(v, 1)
		end
	end
end

function ClientSkills.ReiatsuTransferAudio(Character, Target)
	local ReiatsuTransferSound = HealingSounds.ReiatsuTransfer:Clone()
	ReiatsuTransferSound.Parent = Target.HumanoidRootPart
	ReiatsuTransferSound:Play()
	Debris:AddItem(ReiatsuTransferSound, ReiatsuTransferSound.TimeLength)
end

function ClientSkills.HealingCircle(Character, Origin)
	local HealingCircleActivateSound = HealingSounds.HealingCircleActivate:Clone()
	HealingCircleActivateSound.PlayOnRemove = true
	HealingCircleActivateSound.Parent = Character.HumanoidRootPart
	HealingCircleActivateSound:Destroy()
	HealingCircleActivateSound = nil
	
	local HealCircle = HealingEffects.HealingCircle:Clone()
	HealCircle:PivotTo(CFrame.new(Origin) * CFrame.new(0, -2.7, 0) * CFrame.Angles(0, 0, math.pi/2))
	HealCircle.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(HealCircle, 35)
	
	TweenService:Create(HealCircle.Circle, TweenInfo.new(0.5), {Transparency = 0.85}):Play()
	HealCircle.Circle.Specs.Enabled = true
	
	for i, v in ipairs(HealCircle:GetChildren()) do
		if v:IsA("Beam") then
			v.Enabled = true
		end
	end
end

function ClientSkills.HealingCircleStop(Character)
	local HealCircle = workspace.Effects[Character.Name]:FindFirstChild("HealingCircle")
	if HealCircle then
		HealCircle.Circle.Specs.Enabled = false
		TweenService:Create(HealCircle.Circle, TweenInfo.new(0.5), {Transparency = 1}):Play()
		Debris:AddItem(HealCircle, 0.5)
	end
end

function ClientSkills.SelflessHeart(Character, Target)
	local SelflessHeartSound = HealingSounds.SelflessHeart:Clone()
	SelflessHeartSound.Parent = Target.HumanoidRootPart
	SelflessHeartSound:Play()
	Debris:AddItem(SelflessHeartSound, SelflessHeartSound.TimeLength)
end

function ClientSkills.Revitalize(Character, Phase, Target)
	if Phase == "1" then
		local RevitalizeSound = HealingSounds.Revitalize:Clone()
		RevitalizeSound.PlayOnRemove = true
		RevitalizeSound.Parent = Target.HumanoidRootPart
		RevitalizeSound:Destroy()
		RevitalizeSound = nil
	elseif Phase == "2" then
		local Revitalize = HealingEffects.Revitalize.Attachment:Clone()
		Revitalize.Parent = Target.HumanoidRootPart
		Debris:AddItem(Revitalize, 1.5)

		for i, v in ipairs(Revitalize:GetChildren()) do
			v:Emit(5)
		end
	end
end

--[[function ClientSkills.PreservedReserves(Character)
	
end]]

function ClientSkills.BloodyCanvas(Character, Phase, Duration)
	if Phase == "1" then
		local Weapon = Character["Right Arm"]:FindFirstChildWhichIsA("Model")
		if Weapon then
			for i, v in ipairs(Weapon:GetDescendants()) do
				if v:IsA("BasePart") and v.Name == "WeaponAura" then
					for _, Particle in ipairs(HealingEffects.CanvasWeaponAura:GetChildren()) do
						local BloodParticle = Particle:Clone()
						BloodParticle.Parent = v
						Debris:AddItem(BloodParticle, 3)

						task.delay(2, function()
							if BloodParticle then
								BloodParticle.Enabled = false
							end
						end)
					end
				end
			end
		end

		local BloodyCanvasTrail = HealingEffects.BloodyCanvasTrail:Clone()
		BloodyCanvasTrail.Anchored = false
		BloodyCanvasTrail.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BloodyCanvasTrail, 1.3)

		local Weld = Instance.new("Weld")
		Weld.Part0 = BloodyCanvasTrail
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = BloodyCanvasTrail

		task.delay(1, function()
			BloodyCanvasTrail.CanvasTrail.Enabled = false
		end)
	elseif Phase == "2" then
		local BloodyCanvasSlash = HealingEffects.BloodyCanvasSlash:Clone()
		BloodyCanvasSlash.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.pi, 0)
		BloodyCanvasSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BloodyCanvasSlash, 1.5)
		
		for i, v in ipairs(BloodyCanvasSlash.Emit3:GetChildren()) do
			v:Emit(3)
		end
		for i, v in ipairs(BloodyCanvasSlash.Emit50:GetChildren()) do
			v:Emit(50)
		end
	elseif Phase == "3" then
		for i, v in ipairs(HealingEffects.BloodyCanvasBuff:GetChildren()) do
			local BuffedParticle = v:Clone()
			BuffedParticle.Parent = Character.HumanoidRootPart
			Debris:AddItem(BuffedParticle, Duration)
			task.delay(Duration - 1, function()
				BuffedParticle.Enabled = false
			end)
		end
	end
end

function ClientSkills.Encompass(Character, Phase, RootCFrame, Duration, Entity, Range)
	if Phase == "1" then
		local Offset = CFrame.new(-0.000289916992, -4.82575607, 0.000274658203, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		local Encompass = HealingEffects.Encompass:Clone()
		Encompass:PivotTo(RootCFrame * Offset)
		Encompass.Parent = workspace.Effects[Character.Name]

		for i, v in ipairs(Encompass:GetDescendants()) do
			if v:IsA("BasePart") then
				local Transparency = v.Transparency
				v.Transparency = 1
				TweenService:Create(v, TweenInfo.new(0.2), {Transparency = Transparency}):Play()
			end
		end
		
		local EncompassSound = HealingSounds.Encompass:Clone()
		EncompassSound.PlayOnRemove = true
		EncompassSound.Parent = Character.HumanoidRootPart
		EncompassSound:Destroy()
		EncompassSound = nil
		
		local Attached
		for i, v in ipairs(Encompass.Bubble.A0:GetChildren()) do
			v.Attachment1 = Character.HumanoidRootPart.RootAttachment
		end
		
		local SetDuration = Duration
		local Rate = 0.05
		local Accumulated = 0
		local Connection
		Connection = RunService.Heartbeat:Connect(function(DeltaTime)
			SetDuration -= DeltaTime
			Accumulated += DeltaTime
			
			if SetDuration <= 0 then
				Connection:Disconnect()
				Connection = nil
				
				Debris:AddItem(Encompass, 2)
				
				for i, v in ipairs(Encompass:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("BasePart") then
						TweenService:Create(v, TweenInfo.new(2), {Transparency = 1}):Play()
					end
				end
			end
			
			if Accumulated > Rate then
				Accumulated -= Rate
				
				local Magnitude = (Character.PrimaryPart.Position - RootCFrame.Position).Magnitude
				if Magnitude < Range * 2 then
					for i, v in ipairs(Encompass.Bubble.A0:GetChildren()) do
						if not v.Enabled then
							v.Enabled = true
						end
					end
				else
					for i, v in ipairs(Encompass.Bubble.A0:GetChildren()) do
						if v.Enabled then
							v.Enabled = false
						end
					end
				end
			end
		end)
	elseif Phase == "2" then
		local Direction = (Entity.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Unit
		local Position = (Character.HumanoidRootPart.CFrame + Direction * 3.5).Position
		
		local EncompassHit = HealingEffects.EncompassHit:Clone()
		EncompassHit.CFrame = CFrame.new(Position, Character.HumanoidRootPart.Position)
		EncompassHit.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(EncompassHit, 0.85)
		
		for i, v in ipairs(EncompassHit:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(tonumber(v.Name))
			end
		end
		
		local EncompassSound = HealingSounds.EncompassHit:Clone()
		EncompassSound.PlayOnRemove = true
		EncompassSound.Parent = EncompassHit
		EncompassSound:Destroy()
		EncompassSound = nil
	end	
end

function ClientSkills.Leap(Character, Phase, Target)
	if Phase == "1" then
		local LeapFx = HealingEffects.LeapFx:Clone()
		LeapFx.CFrame = Character.HumanoidRootPart.CFrame
		LeapFx.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(LeapFx, 1)
		
		for i, v in ipairs(LeapFx.Emit5:GetChildren()) do
			v:Emit(5)
		end
		
		local LeapSound = HealingSounds.Leap:Clone()
		LeapSound.Parent = LeapFx
		LeapSound:Play()
		Debris:AddItem(LeapSound, 3)
	elseif Phase == "2" then
		local Clone = SharedFunctions:CreateClone(Character, Character.HumanoidRootPart.CFrame, nil, "NoCollide")
		Clone.Head.CFrame = Character.Head.CFrame
		Clone.Torso.CFrame = Character.Torso.CFrame
		Clone["Right Leg"].CFrame = Character["Right Leg"].CFrame
		Clone["Right Arm"].CFrame = Character["Right Arm"].CFrame
		Clone["Left Leg"].CFrame = Character["Left Leg"].CFrame
		Clone["Left Arm"].CFrame = Character["Left Arm"].CFrame
		Debris:AddItem(Clone, 0.7)
		
		local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)
		local function RandomOffset(SpawnPoint)
			local Min, Max = 0, 3
			local RNG = Random.new()
			return SpawnPoint * CFrame.new(RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max), RNG:NextNumber(Min, Max))
		end
		
		for i, v in pairs(Clone:GetDescendants()) do
			if v:IsA("SpecialMesh") then
				v.TextureId = ""
				v.VertexColor = color3ToVector3(Color3.fromRGB(126, 222, 231))
			elseif v:IsA("BasePart") then
				v.Color = Color3.fromRGB(126, 222, 231)
				v.Material = Enum.Material.Neon
				v.Transparency = 0.4
				
				TweenService:Create(v, Info, {CFrame = RandomOffset(v.CFrame)}):Play()
			elseif v:IsA("BillboardGui") then
				v.Enabled = false
			elseif v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("Decal") or v:IsA("Script") or v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end
		
		FlashstepClient.Invisible(Character)
		
		task.delay(0.3, function()
			FlashstepClient.Visible(Character)
			
			for i, v in ipairs(Clone:GetDescendants()) do
				if v:IsA("BasePart") then
					if Character:FindFirstChild(v.Name) then
						TweenService:Create(v, TweenInfo.new(0.35), {CFrame = Character[v.Name].CFrame}):Play()
					else
						TweenService:Create(v, TweenInfo.new(0.35), {CFrame = Character.HumanoidRootPart.CFrame}):Play()
					end
					task.wait()
				end
			end
		end)
	end
end

function ClientSkills.Discord(Character, Phase, Target, Duration)
	if Phase == "1" then
		local Discord = HealingEffects.DiscordBall:Clone()
		Discord.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Discord, 0.6)
		
		local Weld = Instance.new("Weld")
		Weld.C0 = CFrame.new(0.0393676758, 1.49999976, 0.000274658203, 0, 0, -0.999999881, 0, 0.999999762, 0, 1, 0, 0)
		Weld.Part0 = Discord
		Weld.Part1 = Character["Left Arm"]
		Weld.Parent = Discord
		
		local DiscordSummonSound = HealingSounds.DiscordSummon:Clone()
		DiscordSummonSound.PlayOnRemove = true
		DiscordSummonSound.Parent = Character.HumanoidRootPart
		DiscordSummonSound:Destroy()
		DiscordSummonSound = nil
	elseif Phase == "2" then
		local DiscordFX = HealingEffects.DiscordFX.Attachment:Clone()
		DiscordFX.Parent = Target.HumanoidRootPart
		Debris:AddItem(DiscordFX, Duration + 1)
		
		local DiscordSound = HealingSounds.DiscordAttached:Clone()
		DiscordSound.PlayOnRemove = true
		DiscordSound.Parent = Target.HumanoidRootPart
		DiscordSound:Destroy()
		DiscordSound = nil
		
		task.delay(Duration, function()
			for i, v in ipairs(DiscordFX:GetChildren()) do
				v.Enabled = false
			end
		end)
	end
end

function ClientSkills.Amplifier(Character, Target, Duration, Buff)
	local Types = {
		Defense = function()
			local AmplifierEmit = HealingEffects.AmplifierSpeedEmit:Clone()
			AmplifierEmit.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(AmplifierEmit, 1)

			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0.0155029297, 0.908921719, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld.Part0 = AmplifierEmit
			Weld.Part1 = Target.HumanoidRootPart
			Weld.Parent = AmplifierEmit

			for i, v in ipairs(AmplifierEmit:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 254, 126));
						ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 254, 126))
					})
					v:Emit(25)
				end
			end
			
			local AmplifierFx = HealingEffects.AmplifierDefense:Clone()
			AmplifierFx.Parent = Target.HumanoidRootPart
			Debris:AddItem(AmplifierFx, Duration + 1)

			local Weld2 = Instance.new("Weld")
			Weld2.C0 = CFrame.new(-0.0325622559, 0.400943995, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld2.Part0 = AmplifierFx
			Weld2.Part1 = Target.HumanoidRootPart
			Weld2.Parent = AmplifierFx

			task.delay(Duration, function()
				for i, v in ipairs(AmplifierFx:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end)
		end,
		Damage = function()
			local AmplifierEmit = HealingEffects.AmplifierSpeedEmit:Clone()
			AmplifierEmit.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(AmplifierEmit, 1)

			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0.0155029297, 0.908921719, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld.Part0 = AmplifierEmit
			Weld.Part1 = Target.HumanoidRootPart
			Weld.Parent = AmplifierEmit

			for i, v in ipairs(AmplifierEmit:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0));
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})
					v:Emit(25)
				end
			end
			
			local AmplifierFx = HealingEffects.AmplifierDamage:Clone()
			AmplifierFx.Parent = Target.HumanoidRootPart
			Debris:AddItem(AmplifierFx, Duration + 1)

			local Weld2 = Instance.new("Weld")
			Weld2.C0 = CFrame.new(0.0328369141, 0.534736872, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld2.Part0 = AmplifierFx
			Weld2.Part1 = Target.HumanoidRootPart
			Weld2.Parent = AmplifierFx

			task.delay(Duration, function()
				for i, v in ipairs(AmplifierFx:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end)
		end,
		AttackSpeed = function()
			local AmplifierSpeed = HealingEffects.AmplifierSpeedEmit:Clone()
			AmplifierSpeed.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(AmplifierSpeed, 1)
			
			local Weld = Instance.new("Weld")
			Weld.C0 = CFrame.new(0.0155029297, 0.908921719, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld.Part0 = AmplifierSpeed
			Weld.Part1 = Target.HumanoidRootPart
			Weld.Parent = AmplifierSpeed
			
			for i, v in ipairs(AmplifierSpeed:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(25)
				end
			end
			
			local AmplifierFx = HealingEffects.AmplifierSpeed:Clone()
			AmplifierFx.Parent = Target.HumanoidRootPart
			Debris:AddItem(AmplifierFx, Duration + 1)
			
			local Weld2 = Instance.new("Weld")
			Weld2.C0 = CFrame.new(0.0155029297, 0.908921719, -0.000183105469, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			Weld2.Part0 = AmplifierFx
			Weld2.Part1 = Target.HumanoidRootPart
			Weld2.Parent = AmplifierFx
			
			task.delay(Duration, function()
				for i, v in ipairs(AmplifierFx:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end
			end)
		end,
	}
	
	local AmplifyShout = HealingEffects.AmplifyShout:Clone()
	AmplifyShout.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(AmplifyShout, 1)
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = AmplifyShout
	Weld.Part1 = Character.HumanoidRootPart
	Weld.Parent = AmplifyShout
	
	for i, v in ipairs(AmplifyShout:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(25)
		end
	end
	
	Types[Buff]()
	
	local AmplifiedSound = HealingSounds.Amplified:Clone()
	AmplifiedSound.PlayOnRemove = true
	AmplifiedSound.Parent = Target.HumanoidRootPart
	AmplifiedSound:Destroy()
	AmplifiedSound = nil
	
	local CheerSound = HealingSounds.AmplifierCheer:Clone()
	CheerSound.PlayOnRemove = true
	CheerSound.Parent = Character.HumanoidRootPart
	CheerSound:Destroy()
	CheerSound = nil
end

--==================================================
--=====================QUINCY=======================
--==================================================

function ClientSkills.BlutActivate(Character)
	local BlutActivateSound = KendoSounds.HierroActivate:Clone()
	BlutActivateSound.Parent = Character.PrimaryPart
	BlutActivateSound:Play()
	Debris:AddItem(BlutActivateSound, BlutActivateSound.TimeLength)
end

function ClientSkills.BlutDeactivate(Character)
	local BlutDeactivateSound = KendoSounds.HierroDeactivate:Clone()
	BlutDeactivateSound.Parent = Character.PrimaryPart
	BlutDeactivateSound:Play()
	Debris:AddItem(BlutDeactivateSound, BlutDeactivateSound.TimeLength)
end

function ClientSkills.BlutIndicator(Character, State)
	if State == "On" and Character:GetAttribute("BlutVene") then
		local Text = "Blut Vene: " .. SharedFunctions:RoundNumber(Character:GetAttribute("BlutVene"), 1)
		if Character:GetAttribute("BlutArterie") then
			Text = "Blut Arterie: " .. SharedFunctions:RoundNumber(Character:GetAttribute("BlutVene"), 1)
		end
		
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.TextLabel.Text = Text
		HierroFrame.Visible = true
	elseif State == "Off" then
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.Visible = false
	end
end

return ClientSkills
