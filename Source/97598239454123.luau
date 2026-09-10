-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Networking = require(SharedModules:WaitForChild("Networking"))

-- Constants
local SingleHarvestSeeds = {
	Carrot = true, Tulip = true, Bamboo = true, Mushroom = true,
}
local Seeds = {
	"Carrot","Strawberry","Blueberry","Tomato","Pumpkin","Apple",
	"Bamboo","Coconut","Cactus","Mango","Cherry","Sunflower",
	"Acorn","Beanstalk","Poison Apple","Venus Fly Trap","Thorn Rose",
	"Pomegranate","Lotus","Romanesco","Baby Cactus","Glow Mushroom",
	"Ghost Pepper","Poison Ivy","Horned Melon","Corn","Pinetree",
	"Banana","Tulip","Dragon Fruit","Dragon's Breath","Moon Bloom",
	"Green Bean","Venom Spitter","Hypnobloom","Briar Rose"
}
local Eggs = {
	"Common Egg","Uncommon Egg","Rare Egg","Legendary Egg","Mythical Egg","Bug Egg"
}

-- Configuration
local State = {
	AutoCollect = false,
	AutoSell = false,
	AutoPlant = false,
	AutoWater = false,
	AutoBuySeed = false,
	AutoBuyEgg = false,
	AutoStealSell = false,
	AutoTame = false,
	AntiAfk = true,
	SelectedSeed = "Carrot",
	SelectedEgg = "Common Egg",
	BuyDelay = 1,
	PetName = "",
	CollectInterval = 0.5,
	StealPerSession = 30,
}

-- Garden Utilities
local function IsNight()
	local NightValue = ReplicatedStorage:FindFirstChild("Night")
	if not NightValue then
		return false
	end
	return NightValue.Value == true
end

local function GetMyGarden()
	local Gardens = Workspace:FindFirstChild("Gardens")
	if not Gardens then
		return nil
	end

	local PlotId = LocalPlayer:GetAttribute("PlotId")
	if PlotId then
		local GardenPlot = Gardens:FindFirstChild("Plot" .. tostring(PlotId))
		if GardenPlot then
			return GardenPlot
		end
	end

	for _, Garden in Gardens:QueryDescendants("> Instance") do
		if tonumber(Garden:GetAttribute("OwnerUserId")) == LocalPlayer.UserId then
			return Garden
		end
	end

	for _, Garden in Gardens:QueryDescendants("> Instance") do
		local OwnerValue = Garden:FindFirstChild("Owner", true)
		if OwnerValue then
			if OwnerValue:IsA("ObjectValue") and OwnerValue.Value == LocalPlayer then
				return Garden
			end
			if OwnerValue:IsA("StringValue") and OwnerValue.Value == LocalPlayer.Name then
				return Garden
			end
		end
		if Garden:GetAttribute("Owner") == LocalPlayer.Name then
			return Garden
		end
	end

	return nil
end

local function GetAllGardens()
	local Gardens = Workspace:FindFirstChild("Gardens")
	if not Gardens then
		return {}
	end
	return Gardens:QueryDescendants("> Instance")
end

local function GetMyGardenSpawnPoint()
	local Garden = GetMyGarden()
	if not Garden then
		return nil
	end

	local SpawnPoint = Garden:FindFirstChild("SpawnPoint")
	if SpawnPoint and SpawnPoint:IsA("BasePart") then
		return SpawnPoint
	end

	local ZonePart = Garden:FindFirstChild("GardenZonePart", true)
	if ZonePart and ZonePart:IsA("BasePart") then
		return ZonePart
	end

	local TotalArea = Garden:FindFirstChild("GardenTotalArea", true)
	if TotalArea and TotalArea:IsA("BasePart") then
		return TotalArea
	end

	return Garden:FindFirstChildWhichIsA("BasePart")
end

-- Character Utilities
local function GetRoot()
	local Character = LocalPlayer.Character
	if not Character then
		return nil
	end
	return Character:FindFirstChild("HumanoidRootPart")
end

local function GetModelPosition(Model)
	if not Model then
		return nil
	end

	if Model:IsA("BasePart") then
		return Model.Position
	end

	if Model:IsA("Model") then
		local PrimaryPart = Model.PrimaryPart
		if PrimaryPart then
			return PrimaryPart.Position
		end

		local DidSucceed, PivotValue = pcall(Model.GetPivot, Model)
		if DidSucceed and PivotValue then
			return PivotValue.Position
		end

		local AnyPart = Model:FindFirstChildWhichIsA("BasePart")
		if AnyPart then
			return AnyPart.Position
		end
	end

	return nil
end

-- Fruit & Plant Utilities
local function IsRipe(Model)
	if not Model then
		return false
	end

	local Age = Model:GetAttribute("Age")
	local MaxAge = Model:GetAttribute("MaxAge")
	if typeof(Age) == "number" and typeof(MaxAge) == "number" then
		return MaxAge <= Age
	end

	if Model:FindFirstChild("HarvestPrompt", true) or Model:FindFirstChild("StealPrompt", true) then
		return true
	end

	return true
end

local function GetFruitEntries(Garden)
	local Entries = {}
	if not Garden then
		return Entries
	end

	local Plants = Garden:FindFirstChild("Plants")
	if not Plants then
		return Entries
	end

	local MyUserId = LocalPlayer.UserId
	for _, Plant in Plants:QueryDescendants("> Model") do
		local PlantId = Plant:GetAttribute("PlantId")
		local OwnerUserId = tonumber(Plant:GetAttribute("UserId"))
		if typeof(PlantId) ~= "string" or not OwnerUserId then
			continue
		end

		local SeedName = Plant:GetAttribute("SeedName")
		local FruitsFolder = Plant:FindFirstChild("Fruits")
		local IsSingleHarvest = SingleHarvestSeeds[SeedName] == true or FruitsFolder == nil

		if IsSingleHarvest then
			if IsRipe(Plant) then
				table.insert(Entries, {
					ownerUserId = OwnerUserId,
					plantId = PlantId,
					fruitId = "",
					model = Plant,
					ripe = true,
					isMine = OwnerUserId == MyUserId,
					seedName = SeedName,
				})
			end
		else
			for _, Fruit in FruitsFolder:QueryDescendants("> Model") do
			local FruitId = Fruit:GetAttribute("FruitId")
				if typeof(FruitId) == "string" and IsRipe(Fruit) then
					table.insert(Entries, {
						ownerUserId = OwnerUserId,
						plantId = PlantId,
						fruitId = FruitId,
						model = Fruit,
						ripe = true,
						isMine = OwnerUserId == MyUserId,
						seedName = SeedName,
					})
				end
			end
		end
	end

	return Entries
end

local function GetPlants(Garden)
	local List = {}
	if not Garden then
		return List
	end

	local Plants = Garden:FindFirstChild("Plants")
	if Plants then
		for _, Plant in Plants:QueryDescendants("> Model") do
			table.insert(List, Plant)
		end
	end

	return List
end

-- Tool & Seed Utilities
local function FindToolWithAttribute(AttributeName, AttributeValue)
	local Containers = {LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}

	for _, Container in Containers do
		if Container then
			for _, Tool in Container:QueryDescendants("> Tool") do
				local Value = Tool:GetAttribute(AttributeName)
					if Value and (AttributeValue == nil or Value == AttributeValue) then
						return Tool
					end
				end
			end
		end
	end

	return nil
end

-- Fire Rate Tracking
local LastFireTime = {}

-- Garden Collection
local function CollectGarden(Garden)
	if not Garden then
		return
	end

	local Now = os.clock()
	local FiredCount = 0

	for _, Entry in GetFruitEntries(Garden) do
		if not Entry.isMine or not Entry.ripe then
			continue
		end

		local Key = "c_" .. Entry.plantId .. "_" .. Entry.fruitId
		local LastTime = LastFireTime[Key] or 0
		if Now - LastTime < 2 then
			continue
		end

		LastFireTime[Key] = Now
		pcall(function() Networking.Garden.CollectFruit:Fire(Entry.plantId, Entry.fruitId) end)
		FiredCount = FiredCount + 1

		if FiredCount >= 5 then
			task.wait(0.5)
			FiredCount = 0
		else
			task.wait(0.1)
		end
	end
end

local function SellAll()
	pcall(function() Networking.NPCS.SellAll:Fire() end)
end

local function BuySeed(Name)
	pcall(function() Networking.SeedShop.PurchaseSeed:Fire(Name) end)
end

local function BuyEgg(Name)
	pcall(function() Networking.Egg.OpenEgg:Fire(Name) end)
end

-- Planting Utilities
local function GetPlantAreasInGarden(Garden)
	if not Garden then
		return {}
	end

	local Areas = {}
	for _, Part in CollectionService:GetTagged("PlantArea") do
		if Part:IsDescendantOf(Garden) and Part:IsA("BasePart") then
			table.insert(Areas, Part)
		end
	end

	if #Areas == 0 then
		for _, Child in Garden:QueryDescendants("BasePart") do
			if Child.Name:lower():find("plantarea") then
				table.insert(Areas, Child)
			end
		end
	end

	return Areas
end

local function IsPositionOccupied(Garden, Position, Radius)
	Radius = Radius or 1.5

	for _, Plant in GetPlants(Garden) do
		local BasePart = Plant.PrimaryPart or Plant:FindFirstChildWhichIsA("BasePart")
		if BasePart then
			local Offset = Vector2.new(Position.X - BasePart.Position.X, Position.Z - BasePart.Position.Z)
			if Offset.Magnitude < Radius then
				return true
			end
		end
	end

	return false
end

local function GetAvailableSeeds()
	local SeedsFound = {}
	local Containers = {LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}

	for _, Container in Containers do
		if Container then
			for _, Tool in Container:QueryDescendants("> Tool") do
				local SeedName = Tool:GetAttribute("SeedTool")
					if SeedName and not SeedsFound[SeedName] then
						SeedsFound[SeedName] = true
					end
				end
			end
		end
	end

	local List = {}
	for SeedName in SeedsFound do
		table.insert(List, SeedName)
	end
	return List
end

local function ResolvePlantSeed()
	local AvailableSeeds = GetAvailableSeeds()
	if #AvailableSeeds == 0 then
		return nil
	end

	for _, SeedName in AvailableSeeds do
		if SeedName == State.SelectedSeed then
			return SeedName
		end
	end

	return AvailableSeeds[1]
end

local function PlantSeed(Name)
	if not Name or Name == "" then
		return
	end

	local Garden = GetMyGarden()
	if not Garden then
		return
	end

	local PlotReference = Garden:FindFirstChild("PlotSizeReference")
	if not PlotReference or not PlotReference:IsA("BasePart") then
		PlotReference = Garden:FindFirstChild("GardenTotalArea", true)
		if not PlotReference or not PlotReference:IsA("BasePart") then
			return
		end
	end

	local PlantAreas = GetPlantAreasInGarden(Garden)
	if #PlantAreas == 0 then
		PlantAreas = { PlotReference }
	end

	local PlantedCount = 0
	local GridStep = 2.5

	for _, Area in PlantAreas do
		local MarginX = math.min(Area.Size.X * 0.15, 4)
		local MarginZ = math.min(Area.Size.Z * 0.15, 4)
		local HalfX = Area.Size.X / 2 - MarginX
		local HalfZ = Area.Size.Z / 2 - MarginZ

		if HalfX < 0 or HalfZ < 0 then
			HalfX = math.max(Area.Size.X / 4, 1)
			HalfZ = math.max(Area.Size.Z / 4, 1)
		end

		for XOffset = -HalfX, HalfX, GridStep do
			for ZOffset = -HalfZ, HalfZ, GridStep do
				local WorldPosition = Area.CFrame:PointToWorldSpace(Vector3.new(XOffset, Area.Size.Y / 2 + 0.2, ZOffset))
				if not IsPositionOccupied(Garden, WorldPosition, 1.8) then
					pcall(function()
						Networking.Plant.PlantSeed:Fire(WorldPosition, Name, PlotReference)
					end)
					PlantedCount = PlantedCount + 1
					task.wait(0.2)
					if PlantedCount >= 10 then
						return
					end
				end
			end
		end
	end
end

-- Watering
local function WaterAll()
	local Garden = GetMyGarden()
	if not Garden then
		return
	end

	local Tool = FindToolWithAttribute("WateringCan")
	if not Tool then
		local Character = LocalPlayer.Character
		if Character then
			Tool = Character:FindFirstChildOfClass("Tool")
		end
		if not Tool then
			local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			if Backpack then
				Tool = Backpack:FindFirstChildOfClass("Tool")
			end
		end
	end

	if not Tool then
		return
	end

	local WateringCanName = Tool:GetAttribute("WateringCan") or "Watering Can"
	local Areas = GetPlantAreasInGarden(Garden)
	if #Areas == 0 then
		Areas = GetPlants(Garden)
	end

	for _, Target in Areas do
		local BasePart = Target:IsA("BasePart") and Target or (Target.PrimaryPart or Target:FindFirstChildWhichIsA("BasePart"))
		if BasePart then
			pcall(function()
				Networking.WateringCan.UseWateringCan:Fire(BasePart.Position - Vector3.new(0, 0.3, 0), WateringCanName, Tool)
			end)
			task.wait(0.15)
		end
	end
end

-- Steal System
local function IsOwnerHome(OwnerUserId)
	local Player = Players:GetPlayerByUserId(OwnerUserId)
	if not Player then
		return false
	end
	return Player:GetAttribute("IsInOwnGarden") == true
		or Player:GetAttribute("InSafeZone") == true
end

local function GetFruitValue(Fruit)
	local SizeMultiplier = Fruit:GetAttribute("SizeMulti") or 1
	local Mutation = Fruit:GetAttribute("Mutation")
	local CorePartName = Fruit:GetAttribute("CorePartName")
	local BaseValue = CorePartName and 100 or 10
	local Multiplier = Mutation and 5 or 1
	return BaseValue * (SizeMultiplier ^ 3) * Multiplier
end

local function FindStealPrompt(Model)
	if not Model then
		return nil
	end

	local Prompt = Model:FindFirstChild("StealPrompt", true)
	if Prompt and Prompt:IsA("ProximityPrompt") then
		return Prompt
	end

	return nil
end

local function WaitForStealPrompt(Model, Timeout)
	Timeout = Timeout or 1.5
	local StartTime = os.clock()

	while os.clock() - StartTime < Timeout do
		local Prompt = FindStealPrompt(Model)
		if Prompt then
			return Prompt
		end
		task.wait(0.1)
	end

	return FindStealPrompt(Model)
end

local function FindBestStealTarget()
	local BestTarget, BestValue = nil, -1
	local Now = os.clock()

	for _, Garden in GetAllGardens() do
		local OwnerUserId = tonumber(Garden:GetAttribute("OwnerUserId"))
		if not OwnerUserId or OwnerUserId == LocalPlayer.UserId then
			continue
		end

		for _, Entry in GetFruitEntries(Garden) do
			if Entry.isMine or not Entry.ripe or IsOwnerHome(Entry.ownerUserId) then
				continue
			end

			local Key = "s_" .. Entry.ownerUserId .. "_" .. Entry.plantId .. "_" .. Entry.fruitId
			if (Now - (LastFireTime[Key] or 0)) < 10 then
				continue
			end

			local FruitValue = GetFruitValue(Entry.model)
			if FruitValue > BestValue then
				BestValue = FruitValue
				BestTarget = Entry
				BestTarget.Key = Key
			end
		end
	end

	return BestTarget
end

local IsStealingBusy = false

local function StealAndSell()
	if IsStealingBusy then
		return
	end
	if not IsNight() then
		return
	end

	local Root = GetRoot()
	if not Root then
		return
	end

	local MySpawn = GetMyGardenSpawnPoint()
	if not MySpawn then
		return
	end

	IsStealingBusy = true
	local StartPosition = Root.CFrame
	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local OriginalWalkSpeed = Humanoid and Humanoid.WalkSpeed
	local OriginalJumpPower = Humanoid and Humanoid.JumpPower

	local StolenCount, FailStreak = 0, 0
	local DidSucceed, ErrorMessage = pcall(function()
		while State.AutoStealSell and IsNight() and StolenCount < State.StealPerSession and FailStreak < 5 do
			local Target = FindBestStealTarget()
			if not Target then
				break
			end

			LastFireTime[Target.Key] = os.clock()

			local Position = GetModelPosition(Target.model)
			if not Position then
				FailStreak = FailStreak + 1
				task.wait(1)
				continue
			end

			local ClearStartTime = os.clock()
			while LocalPlayer:GetAttribute("IsStealingFruit") == true
				and os.clock() - ClearStartTime < 3 do
				task.wait(0.2)
			end

			Root.CFrame = CFrame.new(Position + Vector3.new(0, 3, 0))
			task.wait(0.5)

			local Prompt = WaitForStealPrompt(Target.model, 2)
			local HoldDuration = 0
			if Prompt then
				HoldDuration = Prompt.HoldDuration or 0
			end

			if HoldDuration == 0 then
				pcall(function() Networking.Steal.BeginSteal:Fire(Target.ownerUserId, Target.plantId, Target.fruitId) end)
				task.wait(0.1)
				pcall(function() Networking.Steal.CompleteSteal:Fire() end)
			else
				pcall(function() Networking.Steal.BeginSteal:Fire(Target.ownerUserId, Target.plantId, Target.fruitId) end)
				task.wait(HoldDuration + 0.2)
				pcall(function() Networking.Steal.CompleteSteal:Fire() end)
			end

			task.wait(0.5)

			if LocalPlayer:GetAttribute("CarryingStolenFruit") == true then
				Root.CFrame = MySpawn.CFrame * CFrame.new(0, 3, 0)
				task.wait(0.5)

				local WaitStartTime = os.clock()
				while State.AutoStealSell
					and LocalPlayer:GetAttribute("CarryingStolenFruit") == true
					and os.clock() - WaitStartTime < 5 do
					task.wait(0.2)
				end

				task.wait(1.5)

				if LocalPlayer:GetAttribute("CarryingStolenFruit") ~= true then
					StolenCount = StolenCount + 1
					FailStreak = 0
				else
					FailStreak = FailStreak + 1
				end
			else
				FailStreak = FailStreak + 1
			end

			task.wait(1)
		end
	end)

	if Humanoid then
		pcall(function() Humanoid.WalkSpeed = OriginalWalkSpeed or 16 end)
		pcall(function() Humanoid.JumpPower = OriginalJumpPower or 50 end)
	end

	pcall(function() Root.CFrame = StartPosition end)
	IsStealingBusy = false
end

local function DeliverStolenFruit()
	local Root = GetRoot()
	local SpawnPoint = GetMyGardenSpawnPoint()
	if Root and SpawnPoint then
		Root.CFrame = SpawnPoint.CFrame * CFrame.new(0, 3, 0)
	end
end

-- Pet Utilities
local function GetWildPetRefParts()
	local List = {}
	local Map = Workspace:FindFirstChild("Map")
	if Map then
		local ReferenceFolder = Map:FindFirstChild("WildPetRef")
		if ReferenceFolder and ReferenceFolder:IsA("Folder") then
			for _, Child in ReferenceFolder:QueryDescendants("> BasePart") do
				if Child:GetAttribute("Price") ~= nil then
					table.insert(List, Child)
				end
			end
		end
	end

	for _, Object in CollectionService:GetTagged("WildPet") do
		if Object:IsA("Instance") then
			table.insert(List, Object)
		end
	end

	for _, Object in CollectionService:GetTagged("WildPetTamable") do
		if Object:IsA("Instance") then
			table.insert(List, Object)
		end
	end

	return List
end

local function AutoTame()
	local Root = GetRoot()
	if not Root then
		return
	end

	local Now = os.clock()

	for _, Object in GetWildPetRefParts() do
		local Position = GetModelPosition(Object)
		if Position and (Position - Root.Position).Magnitude <= 14 then
			local Key = "t_" .. Object.Name
			if (Now - (LastFireTime[Key] or 0)) >= 3 then
				LastFireTime[Key] = Now
				pcall(function() Networking.Pets.WildPetTame:Fire(Object) end)
			end
		end
	end
end

-- Garden Actions
local function GrowAll()
	pcall(function() Networking.Garden.GrowAllStarting:Fire() end)
end

local function ExpandGarden()
	pcall(function() Networking.Actions.ExpandGarden:Fire() end)
end

local function GetEquippedPetIds()
	local DidSucceed, Response = pcall(function() return Networking.Pets.GetEquippedPets:Fire() end)
	if not DidSucceed or type(Response) ~= "table" then
		return {}
	end

	local PetIds = {}
	for _, Pet in Response do
		local PetId = type(Pet) == "table" and Pet.Id or Pet
		if typeof(PetId) == "string" then
			table.insert(PetIds, PetId)
		end
	end

	return PetIds
end

-- Teleport Utilities
local function TeleportTo(Part)
	local Root = GetRoot()
	if not Root or not Part then
		return
	end
	Root.CFrame = Part.CFrame * CFrame.new(0, 3, -2)
end

-- Server Utilities
local function ServerHop()
	pcall(function() Networking.AntiAfk.RequestHop:Fire() end)

	local DidSucceed, Response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
	end)

	if not DidSucceed or not Response or not Response.data then
		return
	end

	local ValidServers = {}
	for _, ServerData in Response.data do
		if ServerData.playing < ServerData.maxPlayers and ServerData.id ~= game.JobId then
			table.insert(ValidServers, ServerData)
		end
	end

	if #ValidServers > 0 then
		TeleportService:TeleportToPlaceInstance(game.PlaceId, ValidServers[math.random(1, #ValidServers)].id, LocalPlayer)
	end
end

local function RejoinServer()
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)
end

-- Background Loops
LocalPlayer.Idled:Connect(function()
	if State.AntiAfk then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(math.max(State.CollectInterval, 0.5))
		if State.AutoCollect then
			pcall(CollectGarden, GetMyGarden())
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if State.AutoSell then
			task.spawn(function() pcall(SellAll) end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(2)
		if State.AutoTame then
			pcall(AutoTame)
		end
		if State.AutoWater then
			pcall(WaterAll)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		if State.AutoStealSell and not IsStealingBusy then
			task.spawn(function() pcall(StealAndSell) end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(math.max(State.BuyDelay, 1))
		if State.AutoBuySeed then
			pcall(BuySeed, State.SelectedSeed)
		end
		task.wait(0.2)
		if State.AutoBuyEgg then
			pcall(BuyEgg, State.SelectedEgg)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if State.AutoPlant then
			local Seed = ResolvePlantSeed()
			if Seed then
				pcall(PlantSeed, Seed)
			end
		end
	end
end)

-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

-- Window & Tabs
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Grow A Garden 2",
	Icon = 106251220512678,
	NotifySide = "Right",
	ShowCustomCursor = true,
	AutoShow = true,
	SidebarCompacted = true,
	DisableSearch = true,
	Animations = { TabSwitch = true },
	TabTransitionTime = 0.65,
})

local Tabs = {
	Main = Window:AddTab("Main", "house", "List of main features"),
	Misc = Window:AddTab("Misc", "box", "Miscellaneous features"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings", "Customize the Interface"),
	Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project"),
}

Tabs.Main:UpdateWarningBox({
	Title = "Welcome",
	Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
	IsNormal = true,
	Visible = true,
	LockSize = true,
})

-- Main Tab - Automation
local FarmAuto = Tabs.Main:AddLeftGroupbox("Automation", "repeat")

FarmAuto:AddToggle("AutoCollect", {
	Text = "Auto Collect",
	Default = false,
	Tooltip = "Automatically picks up fruits from your garden",
	Callback = function(Value) State.AutoCollect = Value end,
})

FarmAuto:AddToggle("AutoSell", {
	Text = "Auto Sell",
	Default = false,
	Tooltip = "Automatically sells your harvested fruit",
	Callback = function(Value) State.AutoSell = Value end,
})

FarmAuto:AddToggle("AutoPlant", {
	Text = "Auto Plant",
	Default = false,
	Tooltip = "Automatically plants the selected seed",
	Callback = function(Value) State.AutoPlant = Value end,
})

FarmAuto:AddToggle("AutoWater", {
	Text = "Auto Water",
	Default = false,
	Tooltip = "Automatically waters all plants",
	Callback = function(Value) State.AutoWater = Value end,
})

FarmAuto:AddDivider()

FarmAuto:AddSlider("CollectInterval", {
	Text = "Collect Interval",
	Default = 0.5,
	Min = 0.5,
	Max = 5,
	Rounding = 1,
	Suffix = "(s)",
	Tooltip = "Delay between collection",
	Callback = function(Value) State.CollectInterval = Value end,
})

-- Main Tab - Actions
local FarmActions = Tabs.Main:AddLeftGroupbox("Actions", "play")

FarmActions:AddButton({
	Text = "Collect All",
	Tooltip = "Collect all fruits",
	Func = function()
		task.spawn(function() CollectGarden(GetMyGarden()) end)
	end,
})

FarmActions:AddButton({
	Text = "Sell All",
	Tooltip = "Sells all harvested fruits",
	Func = function()
		task.spawn(function() SellAll() end)
	end,
})

FarmActions:AddButton({
	Text = "Plant Selected Seed",
	Tooltip = "Plants your selected seed",
	Func = function()
		task.spawn(function()
			local Seed = ResolvePlantSeed()
			if Seed then
				PlantSeed(Seed)
			end
		end)
	end,
})

FarmActions:AddButton({
	Text = "Water All Plants",
	Tooltip = "Waters every plant in your garden once",
	Func = function()
		task.spawn(function() WaterAll() end)
	end,
})

FarmActions:AddButton({
	Text = "Grow All Starter Plants",
	Tooltip = "Growth on all starting plants",
	Func = function()
		GrowAll()
	end,
})

FarmActions:AddButton({
	Text = "Expand Garden",
	Tooltip = "Purchases garden expansion",
	Func = function()
		ExpandGarden()
	end,
})

-- Main Tab - Shop
local ShopGroup = Tabs.Main:AddRightGroupbox("Shop", "shopping-cart")

ShopGroup:AddDivider("Seeds")

ShopGroup:AddToggle("AutoBuySeed", {
	Text = "Auto Buy Seeds",
	Default = false,
	Tooltip = "Purchases the selected seed from the shop",
	Callback = function(Value) State.AutoBuySeed = Value end,
})

ShopGroup:AddDropdown("SelectedSeed", {
	Values = Seeds,
	Default = "Carrot",
	Text = "Seed Type",
	Tooltip = "Choose your seed",
	Searchable = true,
	Callback = function(Value) State.SelectedSeed = Value end,
})

ShopGroup:AddButton({
	Text = "Buy Selected Seed",
	Tooltip = "Buys the selected seed once",
	Func = function()
		BuySeed(State.SelectedSeed)
	end,
})

ShopGroup:AddDivider("Eggs")

ShopGroup:AddToggle("AutoBuyEgg", {
	Text = "Auto Open Eggs",
	Default = false,
	Tooltip = "Continuously opens the selected egg",
	Callback = function(Value) State.AutoBuyEgg = Value end,
})

ShopGroup:AddDropdown("SelectedEgg", {
	Values = Eggs,
	Default = "Common Egg",
	Text = "Egg Type",
	Tooltip = "Choose egg",
	Callback = function(Value) State.SelectedEgg = Value end,
})

ShopGroup:AddButton({
	Text = "Open Selected Egg Once",
	Tooltip = "Opens the selected egg once",
	Func = function()
		BuyEgg(State.SelectedEgg)
	end,
})

ShopGroup:AddDivider("Settings")

ShopGroup:AddSlider("BuyDelay", {
	Text = "Open Delay",
	Default = 1,
	Min = 1,
	Max = 10,
	Rounding = 1,
	Suffix = "s",
	Tooltip = "Delay between auto buy or egg open",
	Callback = function(Value) State.BuyDelay = Value end,
})

-- Main Tab - Steal
local StealGroup = Tabs.Main:AddRightGroupbox("Steal", "moon")

StealGroup:AddDivider("Automation")

StealGroup:AddToggle("AutoStealSell", {
	Text = "Auto Steal & Sell",
	Default = false,
	Tooltip = "Steals fruit from other players' gardens (night time only)",
	Callback = function(Value) State.AutoStealSell = Value end,
})

StealGroup:AddSlider("StealPerSession", {
	Text = "Steals Per Session",
	Default = 30,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Tooltip = "Maximum number of fruits to steal before stopping",
	Callback = function(Value) State.StealPerSession = Value end,
})

StealGroup:AddDivider("Actions")

StealGroup:AddButton({
	Text = "Deliver Stolen Fruit",
	Tooltip = "Teleports you back to your garden after stealing",
	Func = function()
		DeliverStolenFruit()
	end,
})

StealGroup:AddButton({
	Text = "Steal Once",
	Tooltip = "Steals fruit once",
	Func = function()
		task.spawn(function() pcall(StealAndSell) end)
	end,
})

-- Main Tab - Teleport
local TeleportGroup = Tabs.Main:AddLeftGroupbox("Teleport", "map-pin")

TeleportGroup:AddButton({
	Text = "Garden",
	Tooltip = "Teleports you to your garden",
	Func = function()
		local SpawnPoint = GetMyGardenSpawnPoint()
		if SpawnPoint then
			TeleportTo(SpawnPoint)
		end
	end,
})

-- Misc Tab - Pets
local PetGroup = Tabs.Misc:AddLeftGroupbox("Pets", "heart")

PetGroup:AddInput("PetNameInput", {
	Default = "",
	Text = "Pet Name",
	Placeholder = "e.g. Raccoon, Unicorn...",
	Tooltip = "Enter the name of the pet",
	Callback = function(Value) State.PetName = Value end,
})

PetGroup:AddButton({
	Text = "Equip Pet",
	Tooltip = "Equips the pet",
	Func = function()
		if State.PetName and State.PetName ~= "" then
			pcall(function() Networking.Pets.RequestEquipByName:Fire(State.PetName) end)
		end
	end,
})

PetGroup:AddButton({
	Text = "Unequip Pet",
	Tooltip = "Unequips the pet",
	Func = function()
		if State.PetName and State.PetName ~= "" then
			pcall(function() Networking.Pets.RequestUnequipByName:Fire(State.PetName) end)
		end
	end,
})

PetGroup:AddButton({
	Text = "Unequip All Pets",
	Tooltip = "Unequips every currently equipped pet",
	Func = function()
		task.spawn(function()
			for _, PetId in GetEquippedPetIds() do
				pcall(function() Networking.Pets.RequestUnequipByName:Fire(PetId) end)
				task.wait(0.3)
			end
		end)
	end,
})

PetGroup:AddButton({
	Text = "Buy Pet Slot",
	Tooltip = "Purchases pet slot",
	Func = function()
		pcall(function() Networking.Pets.RequestPurchasePetSlot:Fire() end)
	end,
})

PetGroup:AddDivider()

PetGroup:AddToggle("AutoTame", {
	Text = "Auto Tame Nearby",
	Default = false,
	Tooltip = "Automatically tames wild pets nearby",
	Callback = function(Value) State.AutoTame = Value end,
})

PetGroup:AddButton({
	Text = "Snap Pets to You",
	Tooltip = "Teleports your pets to you",
	Func = function()
		local Root = GetRoot()
		if Root then
			pcall(function() Networking.Pets.SnapPets:Fire(Root.Position) end)
		end
	end,
})

-- Misc Tab - Server
local ServerGroup = Tabs.Misc:AddRightGroupbox("Server", "globe")

ServerGroup:AddToggle("AntiAfk", {
	Text = "Anti AFK",
	Default = true,
	Tooltip = "Prevents you from being kicked",
	Callback = function(Value) State.AntiAfk = Value end,
})

ServerGroup:AddButton({
	Text = "Server Hop",
	Tooltip = "Joins a different server",
	Func = function()
		task.spawn(function() ServerHop() end)
	end,
})

ServerGroup:AddButton({
	Text = "Rejoin Server",
	Tooltip = "Rejoins the current server",
	Func = function()
		task.spawn(function() RejoinServer() end)
	end,
})

ServerGroup:AddDivider()

ServerGroup:AddButton({
	Text = "Copy Job ID",
	Tooltip = "Copies the current server's Job Id",
	Func = function()
		if setclipboard then
			setclipboard(game.JobId)
		end
	end,
})

ServerGroup:AddButton({
	Text = "Copy Place ID",
	Tooltip = "Copies the game's Place ID",
	Func = function()
		if setclipboard then
			setclipboard(tostring(game.PlaceId))
		end
	end,
})

-- UI Settings Tab
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = Library.ShowCustomCursor,
	Tooltip = "Toggles the custom UI cursor on or off",
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Tooltip = "Which side of the screen notifications appear on",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Tooltip = "Adjusts the overall UI scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})

MenuGroup:AddButton({
	Text = "Unload",
	Tooltip = "Unload the script",
	Func = function()
		Library:Unload()
	end,
})

-- Credits Tab
local ContributorsSource = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local TeamMembers, GameContributors = loadstring(ContributorsSource)()

local TeamGroup = Tabs.Cont:AddLeftGroupbox("Team", "wrench")
for Name, Role in TeamMembers do
	TeamGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Role)
end

local PlaceId = tostring(game.PlaceId)
if GameContributors[PlaceId] then
	local ContributorsGroup = Tabs.Cont:AddRightGroupbox("Contributors", "users")
	for Name, Contribution in GameContributors[PlaceId] do
		ContributorsGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Contribution)
	end
end

-- Initialization
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/GrowAGarden2")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify({
	Title = "Drift",
	Description = "Loaded successfully",
	Time = 5,
})

setclipboard("dsc.gg/getdrift")

Library:Notify({
	Title = "Drift",
	Description = "Copied Discord Link",
	Time = 5,
})
