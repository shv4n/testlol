local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkManager = require(ReplicatedStorage.Modules.Shared.NetworkManager)
local SharedFunctions = require(ReplicatedStorage.Modules.Shared.SharedFunctions)
local Debris = require(ReplicatedStorage.Modules.Shared.Debris)

local BloodEffects = ReplicatedStorage.Assets.Effects.Shikais.Blood
local BloodSounds = ReplicatedStorage.Assets.ShikaiSounds.Blood

local function DisableParticles(Object)
	for i, v in ipairs(Object:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
end

local function Weld(Part0, Part1)
	local Weld = Instance.new("Weld")
	Weld.Part0 = Part0
	Weld.Part1 = Part1
	Weld.Parent = Part0
	return Weld
end

local ClientBloodShikai = {}

function ClientBloodShikai.BloodCross(Character, Phase)
	if Phase == "1" then
		if not Character["Right Arm"]:FindFirstChild("BloodCross") then
			local BloodCross = BloodEffects.BloodCross.BloodCross:Clone()
			BloodCross.Parent = Character["Right Arm"]
		end
	elseif Phase == "2" then
		for i, v in ipairs(Character["Right Arm"]:GetChildren()) do
			if v.Name == "BloodCross" and v:IsA("Attachment") then
				v:Destroy()
			end
		end
	end
end

function ClientBloodShikai.BloodMeter(Character)
	if Character:GetAttribute("BloodMeter") then
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.TextLabel.Text = "Blood: " .. SharedFunctions:RoundNumber(Character:GetAttribute("BloodMeter"), 1)
		if Character:GetAttribute("BloodMeter") > 0 then
			HierroFrame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			HierroFrame.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
		HierroFrame.Visible = true
	else
		local HierroFrame = Players.LocalPlayer.PlayerGui.DisplayUI.Collage.MainFrame.Hierro
		HierroFrame.Visible = false
	end
end

function ClientBloodShikai.Collapsed(Character, Target)
	local ParryCollapsed = BloodEffects.ParryCollapse:Clone()
	ParryCollapsed.CFrame = Target.HumanoidRootPart.CFrame
	ParryCollapsed.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(ParryCollapsed, 0.75)

	for i, v in ipairs(ParryCollapsed:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(tonumber(v.Name))
		end
	end
	
	for _, BodyPart in ipairs(Target:GetChildren()) do
		if BodyPart:IsA("BasePart") then
			for i, v in ipairs(BloodEffects.ParryCollapseBurst:GetChildren()) do
				local Particle = v:Clone()
				Particle.Parent = BodyPart
				Particle:Emit(tonumber(Particle.Name))
				Debris:AddItem(Particle, 0.7)
			end
		end
	end
	
	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {workspace.Entities, workspace.Effects}
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.IgnoreWater = true

	local TotalBloodTrails = 6

	local RNG = Random.new()
	for i = 1, TotalBloodTrails do
		local BloodTrail = BloodEffects.BloodBall:Clone()
		BloodTrail.Velocity = Vector3.new(Random.new():NextNumber(-25, 25), Random.new():NextNumber(0, 35), Random.new():NextNumber(-25, 25))
		BloodTrail.Position = Target.HumanoidRootPart.Position
		BloodTrail.Anchored = false
		BloodTrail.Trail.Enabled = true
		BloodTrail.Parent = workspace.Effects

		task.spawn(function()
			for i = 1, 30 do
				local RayCastResult = workspace:Raycast(BloodTrail.Position, BloodTrail.Velocity.Unit * 0.5, Params)
				if RayCastResult then
					BloodTrail:Destroy()
					BloodTrail = nil

					local Size = RNG:NextInteger(3.5, 6.5)
					local BloodSplatter = BloodEffects.BloodBall:Clone()
					BloodSplatter:ClearAllChildren()
					BloodSplatter.Anchored = true
					BloodSplatter.Size = Vector3.new(Size, Size, 0)
					BloodSplatter.CFrame = CFrame.lookAt(RayCastResult.Position, RayCastResult.Position + RayCastResult.Normal)
					BloodSplatter.Parent = workspace.Effects
					Debris:AddItem(BloodSplatter, 6)

					break
				end
				task.wait()
			end
			if BloodTrail then
				task.wait(3)
				BloodTrail:Destroy()
				BloodTrail = nil
			end
		end)
	end
end

function ClientBloodShikai.Exposed(Character, AttackOwner)
	local ExposedLifesteal = BloodEffects.ExposedLifesteal:Clone()
	ExposedLifesteal.CFrame = AttackOwner.HumanoidRootPart.CFrame
	ExposedLifesteal.Parent = workspace.Effects[Character.Name]
	Debris:AddItem(ExposedLifesteal, 0.6)
	
	for i, v in ipairs(ExposedLifesteal:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(tonumber(v.Name))
		end
	end
end

function ClientBloodShikai.BloodWeapon(Character)
	
end

function ClientBloodShikai.Hemorrhage(Character, Phase, PositiveHits, Duration)
	if Phase == "1" then
		local BloodSkate = BloodEffects.BloodSkate:Clone()
		BloodSkate.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BloodSkate, 1.6)
		
		Weld(BloodSkate.CenterSkate, Character.HumanoidRootPart)
		Weld(BloodSkate.LSkate, Character["Left Leg"])
		Weld(BloodSkate.RSkate, Character["Right Leg"])
		
		local HemorrhageDash = BloodSounds.HemorrhageDash:Clone()
		HemorrhageDash.Parent = Character.HumanoidRootPart
		HemorrhageDash:Play()
		Debris:AddItem(HemorrhageDash, HemorrhageDash.TimeLength)
		
		task.delay(0.6, function()
			DisableParticles(BloodSkate)
		end)
	elseif Phase == "2" then
		local HemorrhageSlash = BloodEffects.HemorrhageSlash:Clone()
		HemorrhageSlash.CFrame = Character.HumanoidRootPart.CFrame
		HemorrhageSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(HemorrhageSlash, 1.5)
		
		for i, v in ipairs(HemorrhageSlash:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
		
		local SlashSound = BloodSounds.HemorrhageSlash:Clone()
		SlashSound.PlayOnRemove = true
		SlashSound.Parent = Character.HumanoidRootPart
		SlashSound:Destroy()
		SlashSound = nil
	elseif Phase == "3" then
		if not PositiveHits or #PositiveHits <= 0 then
			return
		end
		
		if not Character["Left Arm"]:FindFirstChild("HemorrhageLink") then
			local BloodTether = BloodEffects.BloodTether.User:Clone()
			BloodTether.Name = "HemorrhageLink"
			BloodTether.Parent = Character["Left Arm"]
			Debris:AddItem(BloodTether, Duration)
		end
		
		for i, v in ipairs(PositiveHits) do
			if not workspace.Effects[Character.Name]:FindFirstChild(v.Name .. "BloodTether") then
				local BloodTether = BloodEffects.BloodTether.BloodTether:Clone()	
				BloodTether.Name = v.Name .. "BloodTether"
				BloodTether.Attachment0 = Character["Left Arm"].HemorrhageLink
				BloodTether.Attachment1 = v.HumanoidRootPart.RootAttachment
				BloodTether.Parent = workspace.Effects[Character.Name]
				Debris:AddItem(BloodTether, Duration)

				local ObjectCFrame = Character.HumanoidRootPart.CFrame:ToObjectSpace(v.HumanoidRootPart.CFrame)
				if ObjectCFrame.X > 0 then
					if v:FindFirstChild("Head") then
						local LeftSlash = BloodEffects.BloodNeck.LeftSlash:Clone()
						LeftSlash.Parent = v.Head
						Debris:AddItem(LeftSlash, 0.5)

						for i, v in ipairs(LeftSlash:GetDescendants()) do
							if v:IsA("ParticleEmitter") then
								local Amount = tonumber(v.Name)
								v:Emit(Amount)
							end
						end
					end
				else
					if v:FindFirstChild("Head") then
						local RightSlash = BloodEffects.BloodNeck.RightSlash:Clone()
						RightSlash.Parent = v.Head
						Debris:AddItem(RightSlash, 0.5)

						for i, v in ipairs(RightSlash:GetDescendants()) do
							if v:IsA("ParticleEmitter") then
								local Amount = tonumber(v.Name)
								v:Emit(Amount)
							end
						end
					end
				end
			end
		end
	elseif Phase == "4" then
		local HemorrhageLink = Character["Left Arm"]:FindFirstChild("HemorrhageLink")
		if HemorrhageLink then
			Debris:AddItem(HemorrhageLink, 0.56)
		end
		
		for i, v in ipairs(workspace.Effects[Character.Name]:GetChildren()) do
			if v.Name == "BloodTether" then
				Debris:AddItem(v, 0.56)
			end
		end
		
		local BloodPalm = BloodEffects.BloodPalm.BloodPalm:Clone()
		BloodPalm.Parent = Character["Left Arm"]
		Debris:AddItem(BloodPalm, 2)
		
		local HemorrhageTetherStartup = BloodSounds.HemorrhageTetherStartup:Clone()
		HemorrhageTetherStartup.PlayOnRemove = true
		HemorrhageTetherStartup.Parent = Character.HumanoidRootPart
		HemorrhageTetherStartup:Destroy()
		HemorrhageTetherStartup = nil
		
		task.delay(1.5, function()
			for i, v in ipairs(BloodPalm:GetDescendants()) do
				v.Enabled = false
			end
		end)
	elseif Phase == "5" then
		local HeartExplode = BloodEffects.HeartExplode.HeartExplode:Clone()
		HeartExplode.Parent = PositiveHits.HumanoidRootPart
		Debris:AddItem(HeartExplode, 0.35)

		for i, v in ipairs(HeartExplode:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
		
		local HemorrhageHeartCrush = BloodSounds.HemorrhageHeartCrush:Clone()
		HemorrhageHeartCrush.PlayOnRemove = true
		HemorrhageHeartCrush.Parent = PositiveHits.HumanoidRootPart
		HemorrhageHeartCrush:Destroy()
		HemorrhageHeartCrush = nil
		
		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {workspace.Entities, workspace.Effects}
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.IgnoreWater = true

		local TotalBloodTrails = 6

		local RNG = Random.new()
		for i = 1, TotalBloodTrails do
			local BloodTrail = BloodEffects.BloodBall:Clone()
			BloodTrail.Velocity = Vector3.new(Random.new():NextNumber(-25, 25), Random.new():NextNumber(0, 35), Random.new():NextNumber(-25, 25))
			BloodTrail.Position = PositiveHits.HumanoidRootPart.Position
			BloodTrail.Anchored = false
			BloodTrail.Trail.Enabled = true
			BloodTrail.Parent = workspace.Effects

			task.spawn(function()
				for i = 1, 30 do
					local RayCastResult = workspace:Raycast(BloodTrail.Position, BloodTrail.Velocity.Unit * 0.5, Params)
					if RayCastResult then
						BloodTrail:Destroy()
						BloodTrail = nil

						local Size = RNG:NextInteger(3.5, 6.5)
						local BloodSplatter = BloodEffects.BloodBall:Clone()
						BloodSplatter:ClearAllChildren()
						BloodSplatter.Anchored = true
						BloodSplatter.Size = Vector3.new(Size, Size, 0)
						BloodSplatter.CFrame = CFrame.lookAt(RayCastResult.Position, RayCastResult.Position + RayCastResult.Normal)
						BloodSplatter.Parent = workspace.Effects
						Debris:AddItem(BloodSplatter, 6)

						break
					end
					task.wait()
				end
				if BloodTrail then
					task.wait(3)
					BloodTrail:Destroy()
					BloodTrail = nil
				end
			end)
		end
	end
end

function ClientBloodShikai.BleedingWillow(Character, Phase)
	if Phase == "0" then
		local BleedingWillowStartup = BloodSounds.BleedingWillowStartup:Clone()
		BleedingWillowStartup.PlayOnRemove = true
		BleedingWillowStartup.Parent = Character.HumanoidRootPart
		BleedingWillowStartup:Destroy()
		BleedingWillowStartup = nil
	elseif Phase == "1" then
		local Offset = CFrame.new(1.64033508, 0.867439508, 0.00293922424, 0.76604408, 0, -0.642787933, 0, -1, 0, -0.642787933, 0, -0.76604408)
		
		local WillowSlash1 = BloodEffects.WillowEffects.WillowSlash1:Clone()
		WillowSlash1.CFrame = Character.HumanoidRootPart.CFrame * Offset
		WillowSlash1.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(WillowSlash1, 0.45)
		
		for i, v in ipairs(WillowSlash1:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
		
		local Vortex = BloodEffects.WillowEffects.WillowVortex:Clone()
		Vortex.CFrame = Character.HumanoidRootPart.CFrame
		Vortex.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Vortex, 1.5)
		
		for i, v in ipairs(Vortex:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
		
		local BleedingWillowVortex = BloodSounds.BleedingWillowVortex:Clone()
		BleedingWillowVortex.PlayOnRemove = true
		BleedingWillowVortex.Parent = Character.HumanoidRootPart
		BleedingWillowVortex:Destroy()
		BleedingWillowVortex = nil
		
		local BleedingWillowSlash = BloodSounds.BleedingWillowSlash:Clone()
		BleedingWillowSlash.PlayOnRemove = true
		BleedingWillowSlash.Parent = Character.HumanoidRootPart
		BleedingWillowSlash:Destroy()
		BleedingWillowSlash = nil
	elseif Phase == "2" then
		local Offset = CFrame.new(0.000473022461, 0.867439747, -1.01507378, 0.848048449, 0, 0.52991879, 0, 1, 0, -0.529918849, 0, 0.848048389)

		local WillowSlash2 = BloodEffects.WillowEffects.WillowSlash1:Clone()
		WillowSlash2.CFrame = Character.HumanoidRootPart.CFrame * Offset
		WillowSlash2.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(WillowSlash2, 0.45)

		for i, v in ipairs(WillowSlash2:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end	
		
		local BleedingWillowSlash = BloodSounds.BleedingWillowSlash:Clone()
		BleedingWillowSlash.PlayOnRemove = true
		BleedingWillowSlash.Parent = Character.HumanoidRootPart
		BleedingWillowSlash:Destroy()
		BleedingWillowSlash = nil
	elseif Phase == "3" then
		local Healed = BloodEffects.BloodHeal:Clone()
		Healed.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(Healed, 1.5)
		
		local Weld = Instance.new("Weld")
		Weld.Part0 = Healed
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = Healed

		for i, v in ipairs(Healed:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
 	end
end

function ClientBloodShikai.Exsanguinate(Character, Phase, Duration)
	if Phase == "1" then
		local DebrisDuration = Duration * 2
		
		local BloodSkate = BloodEffects.BloodSkate:Clone()
		BloodSkate.Name = "ExsanguinateSkate"
		BloodSkate.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(BloodSkate, DebrisDuration)

		Weld(BloodSkate.CenterSkate, Character.HumanoidRootPart)
		Weld(BloodSkate.LSkate, Character["Left Leg"])
		Weld(BloodSkate.RSkate, Character["Right Leg"])
		
		local SkateSound = BloodSounds.ExsanguinateSkate:Clone()
		SkateSound.Parent = BloodSkate.CenterSkate
		SkateSound:Play()
		Debris:AddItem(SkateSound, DebrisDuration)
		
		task.delay(Duration, function()
			DisableParticles(BloodSkate)
		end)
	elseif Phase == "2" then
		local ExsanguinateSkate = workspace.Effects[Character.Name]:FindFirstChild("ExsanguinateSkate")
		if ExsanguinateSkate then
			DisableParticles(ExsanguinateSkate)
			Debris:AddItem(ExsanguinateSkate, 1)
		end
	elseif Phase == "3" then
		local Offsets = {
			BloodSlash = CFrame.new(-0.000122070312, -0.650416136, 1.41931248, 0, 1, 0, 0, 0, 1, 1, 0, 0);
			SlashSplatter1 = CFrame.new(-0.000106811523, 0.849583864, -5.75370407, 1, 0, 0, 0, 1, 0, 0, 0, 1);
			SlashSplatter2 = CFrame.new(-0.000106811523, 5.45592403, -5.03956413, 1, 0, 0, 0, 0.882947683, -0.469471633, 0, 0.469471633, 0.882947683);
			SlashSplatter3 = CFrame.new(-0.000106811523, 7.68692112, -2.86233044, 1, 0, 0, 0, 0.453990459, -0.891006589, 0, 0.891006589, 0.453990459);
		}
		
		local ExsanguinateSlash = BloodEffects.ExsanSlash:Clone()
		for i, v in ipairs(ExsanguinateSlash:GetChildren()) do
			if Offsets[v.Name] then
				v.CFrame = Character.HumanoidRootPart.CFrame * Offsets[v.Name]
			end
		end
		ExsanguinateSlash.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(ExsanguinateSlash, 1.5)
		
		for i, v in ipairs(ExsanguinateSlash:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				local Amount = tonumber(v.Name)
				v:Emit(Amount)
			end
		end
		
		local SlashSound = BloodSounds.ExsanguinateSlash:Clone()
		SlashSound.PlayOnRemove = true
		SlashSound.Parent = Character.HumanoidRootPart
		SlashSound:Destroy()
		SlashSound = nil
	end
end

function ClientBloodShikai.BloodArt(Character, Phase)
	if Phase == "1" then
		local BloodArtPop = BloodEffects.BloodArtPop.BloodPop:Clone()
		BloodArtPop.Parent = Character["Left Arm"]
		Debris:AddItem(BloodArtPop, 0.7)
		
		for i, v in ipairs(BloodArtPop:GetChildren()) do
			v:Emit(tonumber(v.Name))
		end
	elseif Phase == "2" then
		if not Character["Right Arm"]:FindFirstChild("BloodArtIndicator") then
			local BloodArtIndicator = BloodEffects.BloodArtIndicator.BloodArtIndicator:Clone()
			BloodArtIndicator.Parent = Character["Right Arm"]
		end
		
		local BloodArtSound = BloodSounds.BloodArt:Clone()
		BloodArtSound.PlayOnRemove = true
		BloodArtSound.Parent = Character.HumanoidRootPart
		BloodArtSound:Destroy()
		BloodArtSound = nil
	elseif Phase == "3" then
		for i, v in ipairs(Character["Right Arm"]:GetChildren()) do
			if v.Name == "BloodArtIndicator" and v:IsA("Attachment") then
				v:Destroy()
			end
		end
		
		local BloodArtSound = BloodSounds.BloodArtDisable:Clone()
		BloodArtSound.PlayOnRemove = true
		BloodArtSound.Parent = Character.HumanoidRootPart
		BloodArtSound:Destroy()
		BloodArtSound = nil
	end
end

function ClientBloodShikai.YachiruSlash(Character, Phase, RunDuration, Rate, Radius)
	if Phase == "1" then
		local Angles = {
			[1] = CFrame.Angles(0, 0.5, 0);
			[2] = CFrame.Angles(0.5, 0, 0);
		}
		
		local Slashes = {}
		for i = 1, 2 do
			local YachiruSlash = BloodEffects.YachiruSlash:Clone()
			YachiruSlash.CFrame = Character.HumanoidRootPart.CFrame
			YachiruSlash.Parent = workspace.Effects[Character.Name]
			
			local Info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true)
			TweenService:Create(YachiruSlash, Info, {Size = YachiruSlash.Size + Vector3.new(4, 4, 4)}):Play()
			
			table.insert(Slashes, {
				Object = YachiruSlash;
				Angle = CFrame.Angles(0, 0, 0);
			})
		end
		
		local YachiruSlashesParticle = BloodEffects.YachiruSlashesParticle:Clone()
		YachiruSlashesParticle.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(YachiruSlashesParticle, RunDuration + 0.65)

		local Weld = Instance.new("Weld")
		Weld.Part0 = YachiruSlashesParticle
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = YachiruSlashesParticle
		
		local Duration = RunDuration
		local Connection
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			Duration -= DeltaTime
			
			if Duration <= 0 then
				Connection:Disconnect()
				Connection = nil
				for i, v in ipairs(Slashes) do
					v.Object:Destroy()
				end
				for i, v in ipairs(YachiruSlashesParticle:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.LockedToPart = false
						v.Enabled = false
					end
				end
				return
			end
			
			for i, v in ipairs(Slashes) do
				v.Angle *= Angles[i]
				v.Object.CFrame = CFrame.new(Character.HumanoidRootPart.Position) * v.Angle
			end
		end)
		
		local YachiruSlashSound = BloodSounds.YachiruSlashRun:Clone()
		YachiruSlashSound.Parent = Character.HumanoidRootPart
		YachiruSlashSound:Play()
		Debris:AddItem(YachiruSlashSound, YachiruSlashSound.TimeLength)
	elseif Phase == "2" then				
		local function RandomNumber(Min, Max)
			return Random.new():NextNumber(Min, Max)
		end
		
		local function SlashWave()
			local Lifetime = 0.15
			local Slashes = {}

			local YachiruSlashes = BloodEffects.YachiruSlashes:Clone()
			for i, v in ipairs(YachiruSlashes:GetChildren()) do
				v.Size = Vector3.zero
				v.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(RandomNumber(-math.pi*2, math.pi*2), RandomNumber(-math.pi*2, math.pi*2), RandomNumber(-math.pi*2, math.pi*2))
				table.insert(Slashes, v)
			end

			YachiruSlashes.Parent = workspace.Effects[Character.Name]
			Debris:AddItem(YachiruSlashes, Lifetime + 0.3)

			for i, v in ipairs(Slashes) do
				TweenService:Create(v, TweenInfo.new(0.2), {Size = Vector3.new(Radius * 2, Radius * 2, Radius * 2)}):Play()
			end

			local Duration = Lifetime + 0.3
			local Connection
			Connection = RunService.RenderStepped:Connect(function(DeltaTime)
				Duration -= DeltaTime

				if Duration <= 0 then
					Connection:Disconnect()
					Connection = nil
					Slashes = nil
					return
				end

				for i, v in ipairs(Slashes) do
					v.CFrame *= CFrame.Angles(0, 0.5, 0)
				end
			end)
			
			local YachiruSlashSound = BloodSounds.YachiruSlash:Clone()
			YachiruSlashSound.PlayOnRemove = true
			YachiruSlashSound.Parent = Character.HumanoidRootPart
			YachiruSlashSound:Destroy()
			YachiruSlashSound = nil

			task.delay(Lifetime, function()
				for i, v in ipairs(Slashes) do
					TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 1, Size = Vector3.new(Radius, Radius, Radius)}):Play()
				end
			end)
		end
		
		local YachiruSlashesParticle = BloodEffects.YachiruSlashesParticle:Clone()
		YachiruSlashesParticle.Parent = workspace.Effects[Character.Name]
		Debris:AddItem(YachiruSlashesParticle, RunDuration + 0.65)

		local Weld = Instance.new("Weld")
		Weld.Part0 = YachiruSlashesParticle
		Weld.Part1 = Character.HumanoidRootPart
		Weld.Parent = YachiruSlashesParticle
		
		local Duration = RunDuration
		local Rate = 0.2
		local Accumulated = 0
		local Connection
		Connection = RunService.RenderStepped:Connect(function(DeltaTime)
			Accumulated += DeltaTime
			Duration -= DeltaTime
			
			if Duration <= 0 then
				Connection:Disconnect()
				Connection = nil
				
				for i, v in ipairs(YachiruSlashesParticle:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.LockedToPart = false
						v.Enabled = false
					end
				end
				return
			end
			
			if Accumulated > Rate then
				Accumulated -= Rate
				SlashWave()
			end
		end)	
	end
end


return ClientBloodShikai
