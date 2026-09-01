-- grow a garden 2 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Networking = require(SharedModules:WaitForChild("Networking"))
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
local function isNight()
	local nightVal = ReplicatedStorage:FindFirstChild("Night")
	return nightVal and nightVal.Value == true
end
local function getMyGarden()
	local gardens = Workspace:FindFirstChild("Gardens")
	if not gardens then return nil end
	local plotId = LocalPlayer:GetAttribute("PlotId")
	if plotId then
		local g = gardens:FindFirstChild("Plot" .. tostring(plotId))
		if g then return g end
	end
	for _, g in ipairs(gardens:GetChildren()) do
		if tonumber(g:GetAttribute("OwnerUserId")) == LocalPlayer.UserId then
			return g
		end
	end
	for _, g in ipairs(gardens:GetChildren()) do
		local ov = g:FindFirstChild("Owner", true)
		if ov then
			if ov:IsA("ObjectValue") and ov.Value == LocalPlayer then return g end
			if ov:IsA("StringValue") and ov.Value == LocalPlayer.Name then return g end
		end
		if g:GetAttribute("Owner") == LocalPlayer.Name then return g end
	end
	return nil
end

local function getAllGardens()
	local g = Workspace:FindFirstChild("Gardens")
	return g and g:GetChildren() or {}
end

local function getMyGardenSpawnPoint()
	local g = getMyGarden()
	if not g then return nil end
	local sp = g:FindFirstChild("SpawnPoint")
	if sp and sp:IsA("BasePart") then return sp end
	local zone = g:FindFirstChild("GardenZonePart", true)
	if zone and zone:IsA("BasePart") then return zone end
	local total = g:FindFirstChild("GardenTotalArea", true)
	if total and total:IsA("BasePart") then return total end
	return g:FindFirstChildWhichIsA("BasePart")
end

local function getRoot()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function getModelPos(model)
	if not model then return nil end
	if model:IsA("BasePart") then return model.Position end
	if model:IsA("Model") then
		local pp = model.PrimaryPart
		if pp then return pp.Position end
		local ok, pv = pcall(model.GetPivot, model)
		if ok and pv then return pv.Position end
		local anyPart = model:FindFirstChildWhichIsA("BasePart")
		if anyPart then return anyPart.Position end
	end
	return nil
end

local function isRipe(model)
	if not model then return false end
	local age = model:GetAttribute("Age")
	local maxAge = model:GetAttribute("MaxAge")
	if typeof(age) == "number" and typeof(maxAge) == "number" then
		return maxAge <= age
	end
	if model:FindFirstChild("HarvestPrompt", true) or model:FindFirstChild("StealPrompt", true) then
		return true
	end
	return true
end

local function getFruitEntries(garden)
	local entries = {}
	if not garden then return entries end
	local plants = garden:FindFirstChild("Plants")
	if not plants then return entries end
	local myUserId = LocalPlayer.UserId
	for _, plant in ipairs(plants:GetChildren()) do
		if plant:IsA("Model") then
			local plantId = plant:GetAttribute("PlantId")
			local ownerUserId = tonumber(plant:GetAttribute("UserId"))
			if typeof(plantId) == "string" and ownerUserId then
				local seedName = plant:GetAttribute("SeedName")
				local fruitsFolder = plant:FindFirstChild("Fruits")
				local isSingle = SingleHarvestSeeds[seedName] == true or fruitsFolder == nil
				if isSingle then
					if isRipe(plant) then
						table.insert(entries, {
							ownerUserId = ownerUserId,
							plantId = plantId,
							fruitId = "",
							model = plant,
							ripe = true,
							isMine = ownerUserId == myUserId,
							seedName = seedName,
						})
					end
				else
					for _, fruit in ipairs(fruitsFolder:GetChildren()) do
						if fruit:IsA("Model") then
							local fid = fruit:GetAttribute("FruitId")
							if typeof(fid) == "string" and isRipe(fruit) then
								table.insert(entries, {
									ownerUserId = ownerUserId,
									plantId = plantId,
									fruitId = fid,
									model = fruit,
									ripe = true,
									isMine = ownerUserId == myUserId,
									seedName = seedName,
								})
							end
						end
					end
				end
			end
		end
	end
	return entries
end

local function getPlants(garden)
	local list = {}
	if not garden then return list end
	local plants = garden:FindFirstChild("Plants")
	if plants then
		for _, p in ipairs(plants:GetChildren()) do
			if p:IsA("Model") then table.insert(list, p) end
		end
	end
	return list
end

local function findToolWithAttribute(attrName, attrValue)
	local function search(container)
		if not container then return nil end
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") then
				local val = tool:GetAttribute(attrName)
				if val and (attrValue == nil or val == attrValue) then
					return tool
				end
			end
		end
		return nil
	end
	local char = LocalPlayer.Character
	local result = search(char)
	if result then return result end
	return search(LocalPlayer:FindFirstChildOfClass("Backpack"))
end
local lastFire = {}


local function collectGarden(garden)
	if not garden then return end
	local now = os.clock()
	local fired = 0
	for _, e in ipairs(getFruitEntries(garden)) do
		if e.isMine and e.ripe then
			local key = "c_" .. e.plantId .. "_" .. e.fruitId
			local last = lastFire[key] or 0
			if now - last >= 2 then
				lastFire[key] = now
				pcall(function() Networking.Garden.CollectFruit:Fire(e.plantId, e.fruitId) end)
				fired = fired + 1
				if fired >= 5 then
					task.wait(0.5)
					fired = 0
				else
					task.wait(0.1)
				end
			end
		end
	end
end
local function sellAll()
	pcall(function() Networking.NPCS.SellAll:Fire() end)
end

local function buySeed(name)
	pcall(function() Networking.SeedShop.PurchaseSeed:Fire(name) end)
end

local function buyEgg(name)
	pcall(function() Networking.Egg.OpenEgg:Fire(name) end)
end

local function getPlantAreasInGarden(garden)
	if not garden then return {} end
	local areas = {}
	for _, part in CollectionService:GetTagged("PlantArea") do
		if part:IsDescendantOf(garden) and part:IsA("BasePart") then
			table.insert(areas, part)
		end
	end
	if #areas == 0 then
		for _, child in ipairs(garden:GetDescendants()) do
			if child:IsA("BasePart") and child.Name:lower():find("plantarea") then
				table.insert(areas, child)
			end
		end
	end
	return areas
end

local function isPositionOccupied(garden, pos, radius)
	radius = radius or 1.5
	for _, plant in ipairs(getPlants(garden)) do
		local base = plant.PrimaryPart or plant:FindFirstChildWhichIsA("BasePart")
		if base then
			local vec = Vector2.new(pos.X - base.Position.X, pos.Z - base.Position.Z)
			if vec.Magnitude < radius then
				return true
			end
		end
	end
	return false
end

local function getAvailableSeeds()
	local seedsFound = {}
	local function scan(container)
		if not container then return end
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") then
				local seedName = tool:GetAttribute("SeedTool")
				if seedName and not seedsFound[seedName] then
					seedsFound[seedName] = true
				end
			end
		end
	end
	scan(LocalPlayer.Character)
	scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
	local list = {}
	for k in pairs(seedsFound) do table.insert(list, k) end
	return list
end

local function resolvePlantSeed()
	local avail = getAvailableSeeds()
	if #avail == 0 then return nil end
	for _, name in ipairs(avail) do
		if name == State.SelectedSeed then return name end
	end
	return avail[1]
end

local function plantSeed(name)
	if not name or name == "" then return end
	local garden = getMyGarden()
	if not garden then return end
	local plotRef = garden:FindFirstChild("PlotSizeReference")
	if not plotRef or not plotRef:IsA("BasePart") then
		plotRef = garden:FindFirstChild("GardenTotalArea", true)
		if not plotRef or not plotRef:IsA("BasePart") then
			return
		end
	end
	local plantAreas = getPlantAreasInGarden(garden)
	if #plantAreas == 0 then
		plantAreas = { plotRef }
	end
	local planted = 0
	local gridStep = 2.5
	for _, area in ipairs(plantAreas) do
		local marginX = math.min(area.Size.X * 0.15, 4)
		local marginZ = math.min(area.Size.Z * 0.15, 4)
		local halfX = area.Size.X / 2 - marginX
		local halfZ = area.Size.Z / 2 - marginZ
		if halfX < 0 or halfZ < 0 then
			halfX = math.max(area.Size.X / 4, 1)
			halfZ = math.max(area.Size.Z / 4, 1)
		end
		for xOff = -halfX, halfX, gridStep do
			for zOff = -halfZ, halfZ, gridStep do
				local worldPos = area.CFrame:PointToWorldSpace(Vector3.new(xOff, area.Size.Y / 2 + 0.2, zOff))
				if not isPositionOccupied(garden, worldPos, 1.8) then
					pcall(function()
						Networking.Plant.PlantSeed:Fire(worldPos, name, plotRef)
					end)
					planted = planted + 1
					task.wait(0.2)
					if planted >= 10 then return end
				end
			end
		end
	end
end

local function waterAll()
	local garden = getMyGarden()
	if not garden then return end
	local tool = findToolWithAttribute("WateringCan")
	if not tool then
		local char = LocalPlayer.Character
		if char then tool = char:FindFirstChildOfClass("Tool") end
		if not tool then
			local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			if backpack then tool = backpack:FindFirstChildOfClass("Tool") end
		end
	end
	if not tool then return end
	local wateringCanName = tool:GetAttribute("WateringCan") or "Watering Can"
	local areas = getPlantAreasInGarden(garden)
	if #areas == 0 then
		areas = getPlants(garden)
	end
	for _, item in ipairs(areas) do
		local base = item:IsA("BasePart") and item or (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart"))
		if base then
			pcall(function()
				Networking.WateringCan.UseWateringCan:Fire(base.Position - Vector3.new(0, 0.3, 0), wateringCanName, tool)
			end)
			task.wait(0.15)
		end
	end
end

local function isOwnerHome(ownerUserId)
	local player = Players:GetPlayerByUserId(ownerUserId)
	if not player then return false end
	return player:GetAttribute("IsInOwnGarden") == true
		or player:GetAttribute("InSafeZone") == true
end

local function getFruitValue(fruit)
	local size = fruit:GetAttribute("SizeMulti") or 1
	local mut = fruit:GetAttribute("Mutation")
	local core = fruit:GetAttribute("CorePartName")
	local base = core and 100 or 10
	local mult = mut and 5 or 1
	return base * (size ^ 3) * mult
end

local function findStealPrompt(model)
	if not model then return nil end
	local prompt = model:FindFirstChild("StealPrompt", true)
	if prompt and prompt:IsA("ProximityPrompt") then return prompt end
	return nil
end

local function waitForStealPrompt(model, timeout)
	timeout = timeout or 1.5
	local t0 = os.clock()
	while os.clock() - t0 < timeout do
		local prompt = findStealPrompt(model)
		if prompt then return prompt end
		task.wait(0.1)
	end
	return findStealPrompt(model)
end

local function findBestStealTarget()
	local best, bestVal = nil, -1
	local now = os.clock()
	for _, garden in ipairs(getAllGardens()) do
		local ownerUid = tonumber(garden:GetAttribute("OwnerUserId"))
		if ownerUid and ownerUid ~= LocalPlayer.UserId then
			for _, e in ipairs(getFruitEntries(garden)) do
				if not e.isMine and e.ripe and not isOwnerHome(e.ownerUserId) then
					local key = "s_" .. e.ownerUserId .. "_" .. e.plantId .. "_" .. e.fruitId
					if (now - (lastFire[key] or 0)) >= 10 then
						local v = getFruitValue(e.model)
						if v > bestVal then
							bestVal = v
							best = e
							best._key = key
						end
					end
				end
			end
		end
	end
	return best
end

local stealBusy = false
local function stealAndSell()
	if stealBusy then return end
	if not isNight() then return end
	local root = getRoot()
	if not root then return end
	local mySpawn = getMyGardenSpawnPoint()
	if not mySpawn then return end

	stealBusy = true
	local startPos = root.CFrame
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local startWS = hum and hum.WalkSpeed
	local startJP = hum and hum.JumpPower

	local stolen, failStreak = 0, 0
	local success, err = pcall(function()
		while State.AutoStealSell and isNight() and stolen < State.StealPerSession and failStreak < 5 do
			local target = findBestStealTarget()
			if not target then break end

			lastFire[target._key] = os.clock()

			local pos = getModelPos(target.model)
			if pos then
				local clearStart = os.clock()
				while LocalPlayer:GetAttribute("IsStealingFruit") == true
					and os.clock() - clearStart < 3 do
					task.wait(0.2)
				end

				root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
				task.wait(0.5)

				local prompt = waitForStealPrompt(target.model, 2)
				local holdDuration = 0
				if prompt then
					holdDuration = prompt.HoldDuration or 0
				end

				if holdDuration == 0 then
					pcall(function() Networking.Steal.BeginSteal:Fire(target.ownerUserId, target.plantId, target.fruitId) end)
					task.wait(0.1)
					pcall(function() Networking.Steal.CompleteSteal:Fire() end)
				else
					pcall(function() Networking.Steal.BeginSteal:Fire(target.ownerUserId, target.plantId, target.fruitId) end)
					task.wait(holdDuration + 0.2)
					pcall(function() Networking.Steal.CompleteSteal:Fire() end)
				end
				task.wait(0.5)

				if LocalPlayer:GetAttribute("CarryingStolenFruit") == true then
					root.CFrame = mySpawn.CFrame * CFrame.new(0, 3, 0)
					task.wait(0.5)
					local t0 = os.clock()
					while State.AutoStealSell
						and LocalPlayer:GetAttribute("CarryingStolenFruit") == true
						and os.clock() - t0 < 5 do
						task.wait(0.2)
					end
					task.wait(1.5)
					if LocalPlayer:GetAttribute("CarryingStolenFruit") ~= true then
						stolen = stolen + 1
						failStreak = 0
					else
						failStreak = failStreak + 1
					end
				else
					failStreak = failStreak + 1
				end
			else
				failStreak = failStreak + 1
			end

			task.wait(1)
		end
	end)

	if hum then
		pcall(function() hum.WalkSpeed = startWS or 16 end)
		pcall(function() hum.JumpPower = startJP or 50 end)
	end
	pcall(function() root.CFrame = startPos end)
	stealBusy = false
end

local function deliverStolenFruit()
	local root = getRoot()
	local spawnPt = getMyGardenSpawnPoint()
	if root and spawnPt then
		root.CFrame = spawnPt.CFrame * CFrame.new(0, 3, 0)
	end
end

local function getWildPetRefParts()
	local list = {}
	local map = Workspace:FindFirstChild("Map")
	if map then
		local ref = map:FindFirstChild("WildPetRef")
		if ref and ref:IsA("Folder") then
			for _, c in ipairs(ref:GetChildren()) do
				if c:IsA("BasePart") and c:GetAttribute("Price") ~= nil then
					table.insert(list, c)
				end
			end
		end
	end
	for _, obj in CollectionService:GetTagged("WildPet") do
		if obj:IsA("Instance") then table.insert(list, obj) end
	end
	for _, obj in CollectionService:GetTagged("WildPetTamable") do
		if obj:IsA("Instance") then table.insert(list, obj) end
	end
	return list
end

local function autoTame()
	local root = getRoot()
	if not root then return end
	local now = os.clock()
	for _, obj in ipairs(getWildPetRefParts()) do
		local pos = getModelPos(obj)
		if pos and (pos - root.Position).Magnitude <= 14 then
			local key = "t_" .. obj.Name
			if (now - (lastFire[key] or 0)) >= 3 then
				lastFire[key] = now
				pcall(function() Networking.Pets.WildPetTame:Fire(obj) end)
			end
		end
	end
end

local function growAll()
	pcall(function() Networking.Garden.GrowAllStarting:Fire() end)
end

local function expandGarden()
	pcall(function() Networking.Actions.ExpandGarden:Fire() end)
end

local function getEquippedPetIds()
	local ok, res = pcall(function() return Networking.Pets.GetEquippedPets:Fire() end)
	if not ok or type(res) ~= "table" then return {} end
	local ids = {}
	for _, pet in ipairs(res) do
		local id = type(pet) == "table" and pet.Id or pet
		if typeof(id) == "string" then
			table.insert(ids, id)
		end
	end
	return ids
end

local function teleportTo(part)
	local root = getRoot()
	if not root or not part then return end
	root.CFrame = part.CFrame * CFrame.new(0, 3, -2)
end

local function serverHop()
	pcall(function() Networking.AntiAfk.RequestHop:Fire() end)
	local ok, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
	end)
	if ok and response and response.data then
		local candidates = {}
		for _, server in ipairs(response.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				table.insert(candidates, server)
			end
		end
		if #candidates > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[math.random(1, #candidates)].id, LocalPlayer)
		end
	end
end

local function rejoinServer()
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)
end

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
			pcall(collectGarden, getMyGarden())
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if State.AutoSell then
			task.spawn(function() pcall(sellAll) end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(2)
		if State.AutoTame then pcall(autoTame) end
		if State.AutoWater then pcall(waterAll) end
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		if State.AutoStealSell and not stealBusy then
			task.spawn(function() pcall(stealAndSell) end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(math.max(State.BuyDelay, 1))
		if State.AutoBuySeed then pcall(buySeed, State.SelectedSeed) end
		task.wait(0.2)
		if State.AutoBuyEgg then pcall(buyEgg, State.SelectedEgg) end
	end
end)

task.spawn(function()
	while true do
		task.wait(3)
		if State.AutoPlant then
			local seed = resolvePlantSeed()
			if seed then pcall(plantSeed, seed) end
		end
	end
end)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

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
local FarmAuto = Tabs.Main:AddLeftGroupbox("Automation", "repeat")

FarmAuto:AddToggle("AutoCollect", {
	Text = "Auto Collect",
	Default = false,
	Tooltip = "Automatically picks up fruits from your garden",
	Callback = function(v) State.AutoCollect = v end,
})

FarmAuto:AddToggle("AutoSell", {
	Text = "Auto Sell",
	Default = false,
	Tooltip = "Automatically sells your harvested fruit",
	Callback = function(v) State.AutoSell = v end,
})

FarmAuto:AddToggle("AutoPlant", {
	Text = "Auto Plant",
	Default = false,
	Tooltip = "Automatically plants the selected seed",
	Callback = function(v) State.AutoPlant = v end,
})

FarmAuto:AddToggle("AutoWater", {
	Text = "Auto Water",
	Default = false,
	Tooltip = "Automatically waters all plants",
	Callback = function(v) State.AutoWater = v end,
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
	Callback = function(v) State.CollectInterval = v end,
})

local FarmActions = Tabs.Main:AddLeftGroupbox("Actions", "play")

FarmActions:AddButton({
	Text = "Collect All",
	Tooltip = "Collect all fruits",
	Func = function()
		task.spawn(function() collectGarden(getMyGarden()) end)
	end,
})

FarmActions:AddButton({
	Text = "Sell All",
	Tooltip = "Sells all harvested fruits",
	Func = function()
		task.spawn(function() sellAll() end)
	end,
})

FarmActions:AddButton({
	Text = "Plant Selected Seed",
	Tooltip = "Plants your selected seed",
	Func = function()
		task.spawn(function()
			local seed = resolvePlantSeed()
			if seed then plantSeed(seed) end
		end)
	end,
})

FarmActions:AddButton({
	Text = "Water All Plants",
	Tooltip = "Waters every plant in your garden once",
	Func = function()
		task.spawn(function() waterAll() end)
	end,
})

FarmActions:AddButton({
	Text = "Grow All Starter Plants",
	Tooltip = "Growth on all starting plants",
	Func = function() growAll() end,
})

FarmActions:AddButton({
	Text = "Expand Garden",
	Tooltip = "Purchases garden expansion",
	Func = function() expandGarden() end,
})

local ShopGroup = Tabs.Main:AddRightGroupbox("Shop", "shopping-cart")

ShopGroup:AddDivider("Seeds")

ShopGroup:AddToggle("AutoBuySeed", {
	Text = "Auto Buy Seeds",
	Default = false,
	Tooltip = "Purchases the selected seed from the shop",
	Callback = function(v) State.AutoBuySeed = v end,
})

ShopGroup:AddDropdown("SelectedSeed", {
	Values = Seeds,
	Default = "Carrot",
	Text = "Seed Type",
	Tooltip = "Choose your seed",
	Searchable = true,
	Callback = function(v) State.SelectedSeed = v end,
})

ShopGroup:AddButton({
	Text = "Buy Selected Seed",
	Tooltip = "Buys the selected seed once",
	Func = function() buySeed(State.SelectedSeed) end,
})

ShopGroup:AddDivider("Eggs")

ShopGroup:AddToggle("AutoBuyEgg", {
	Text = "Auto Open Eggs",
	Default = false,
	Tooltip = "Continuously opens the selected egg",
	Callback = function(v) State.AutoBuyEgg = v end,
})

ShopGroup:AddDropdown("SelectedEgg", {
	Values = Eggs,
	Default = "Common Egg",
	Text = "Egg Type",
	Tooltip = "Choose egg",
	Callback = function(v) State.SelectedEgg = v end,
})

ShopGroup:AddButton({
	Text = "Open Selected Egg Once",
	Tooltip = "Opens the selected egg once",
	Func = function() buyEgg(State.SelectedEgg) end,
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
	Callback = function(v) State.BuyDelay = v end,
})

local StealGroup = Tabs.Main:AddRightGroupbox("Steal", "moon")

StealGroup:AddDivider("Automation")

StealGroup:AddToggle("AutoStealSell", {
	Text = "Auto Steal & Sell",
	Default = false,
	Tooltip = "Steals fruit from other players' gardens (night time only)",
	Callback = function(v) State.AutoStealSell = v end,
})

StealGroup:AddSlider("StealPerSession", {
	Text = "Steals Per Session",
	Default = 30,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Tooltip = "Maximum number of fruits to steal before stopping",
	Callback = function(v) State.StealPerSession = v end,
})

StealGroup:AddDivider("Actions")

StealGroup:AddButton({
	Text = "Deliver Stolen Fruit",
	Tooltip = "Teleports you back to your garden after stealing",
	Func = function() deliverStolenFruit() end,
})

StealGroup:AddButton({
	Text = "Steal Once",
	Tooltip = "Steals fruit once",
	Func = function()
		task.spawn(function() pcall(stealAndSell) end)
	end,
})

local TeleportGroup = Tabs.Main:AddLeftGroupbox("Teleport", "map-pin")
TeleportGroup:AddButton({
	Text = "Garden",
	Tooltip = "Teleports you to your garden",
	Func = function()
		local sp = getMyGardenSpawnPoint()
		if sp then teleportTo(sp) end
	end,
})


local PetGroup = Tabs.Misc:AddLeftGroupbox("Pets", "heart")

PetGroup:AddInput("PetNameInput", {
	Default = "",
	Text = "Pet Name",
	Placeholder = "e.g. Raccoon, Unicorn...",
	Tooltip = "Enter the name of the pet",
	Callback = function(v) State.PetName = v end,
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
			for _, id in ipairs(getEquippedPetIds()) do
				pcall(function() Networking.Pets.RequestUnequipByName:Fire(id) end)
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
	Callback = function(v) State.AutoTame = v end,
})

PetGroup:AddButton({
	Text = "Snap Pets to You",
	Tooltip = "Teleports your pets to you",
	Func = function()
		local root = getRoot()
		if root then
			pcall(function() Networking.Pets.SnapPets:Fire(root.Position) end)
		end
	end,
})

local ServerGroup = Tabs.Misc:AddRightGroupbox("Server", "globe")
ServerGroup:AddToggle("AntiAfk", {
	Text = "Anti AFK",
	Default = true,
	Tooltip = "Prevents you from being kicked",
	Callback = function(v) State.AntiAfk = v end,
})

ServerGroup:AddButton({
	Text = "Server Hop",
	Tooltip = "Joins a different server",
	Func = function()
		task.spawn(function() serverHop() end)
	end,
})

ServerGroup:AddButton({
	Text = "Rejoin Server",
	Tooltip = "Rejoins the current server",
	Func = function()
		task.spawn(function() rejoinServer() end)
	end,
})

ServerGroup:AddDivider()

ServerGroup:AddButton({
	Text = "Copy Job ID",
	Tooltip = "Copies the current server's Job Id",
	Func = function()
		if setclipboard then setclipboard(game.JobId) end
	end,
})

ServerGroup:AddButton({
	Text = "Copy Place ID",
	Tooltip = "Copies the game's Place ID",
	Func = function()
		if setclipboard then setclipboard(tostring(game.PlaceId)) end
	end,
})


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
local __ContribSrc = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local __Team, __GameContribs = loadstring(__ContribSrc)()

local __DevBox = Tabs.Cont:AddLeftGroupbox("Team", "wrench")
for __name, __role in pairs(__Team) do
    __DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __role)
end

local __placeId = tostring(game.PlaceId)
if __GameContribs[__placeId] then
    local __ContBox = Tabs.Cont:AddRightGroupbox("Contributors", "users")
    for __name, __contribution in pairs(__GameContribs[__placeId]) do
        __ContBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __contribution)
    end
end

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
