local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

if getgenv().DriftActiveSession then
    pcall(getgenv().DriftActiveSession)
end

local sessionActive = true
local eventLinks = {}
local managedObjects = {}

local remoteHub = ReplicatedStorage:WaitForChild("Events", 10)

local function hookEvent(signal, fn)
    local c = signal:Connect(fn)
    table.insert(eventLinks, c)
    return c
end

local function trackObject(obj)
    table.insert(managedObjects, obj)
    return obj
end

getgenv().DriftCfg = getgenv().DriftCfg or {
    autoCast = false,
    castFrequency = 1.0,
    castIntensity = 100,
    barLock = true,
    slamBot = true,
    chargeBot = true,
    quickCatch = true,
    skillBot = false,
    activeSkill = "One-Strike Heaven Gate",

    smartBait = false,
    smartRod = false,
    smartOrb = false,
    preset1Rod = "Wooden Rod",
    preset1Bait = "Basic Bait",
    preset2Rod = "Wooden Rod",
    preset2Bait = "Basic Bait",

    liquidate = false,
    liquidateTimer = 30,
    shieldFish = false,
    shieldTarget = "Colossal Tigerfish",
    resourceMode = false,

    rhythmBot = false,
    bossGrind = false,
    secretBossGrind = false,
    activeBoss = "Enzo",

    spiritScan = false,
    spiritPray = false,
    hopSpirit = false,
    hopMaoshan = false,
    hopTaoist = false,

    ticketGrind = false,
    ticketTier = "Easy",
    dailyGrab = false,
    dailyPause = 0.5,

    baitForge = false,
    forgeTarget = "Nameless Bait",
    forgeQuantity = 1,
    baitRestock = false,
    restockTarget = "Ancestral Bait",
    restockQuantity = 5,
    restockFloor = 10,
    restockPause = 1.0,

    bannerPull = false,
    bannerChoice = "Taiji Banner",
    pullBatch = 1,

    speedHack = false,
    speedAmount = 16,
    flightMode = false,
    flightVelocity = 50,
    moonJump = false,
    waterWalk = false,
    phaseThrough = false,

    markerSpirit = false,
    markerRod = false,
    markerBoat = false,
    markerMaoshan = false,
    markerTaoist = false,
    markerBoss = false,
    markerPlayers = false,
    hookRing = true,
    clearFog = false,
    maxBright = false,
    lowGfx = false,
    stripUi = false,

    idleGuard = true,
    reconnect = false,
}

local cfg = getgenv().DriftCfg

if hookmetamethod and newcclosure then
    local mgRemote = remoteHub and remoteHub:FindFirstChild("FishingMinigame")
    local originalCall
    originalCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (self == mgRemote or (typeof(self) == "Instance" and self.Name == "FishingMinigame")) and method == "FireServer" and not checkcaller() then
            if sessionActive and cfg and cfg.barLock then
                local params = {...}
                local action = tostring(params[1])
                if action == "Out of bar" or action == "Out of bar (overpull)" or action:find("Out of bar") then
                    return originalCall(self, "In bar", unpack(params, 2))
                end
            end
        end
        return originalCall(self, ...)
    end))
end

local storageDir = "Drift/HeavyweightFishing"

local function ensureStorage()
    if makefolder then
        pcall(function()
            if not isfolder("Drift") then makefolder("Drift") end
            if not isfolder(storageDir) then makefolder(storageDir) end
        end)
    end
end

local function persistConfig(label)
    ensureStorage()
    local filepath = storageDir .. "/" .. (label or "default") .. ".json"
    local payload = {}
    for k, v in pairs(cfg) do
        if typeof(v) == "EnumItem" then
            payload[k] = {__enum = tostring(v)}
        else
            payload[k] = v
        end
    end
    local success, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
    if success and writefile then
        pcall(function() writefile(filepath, encoded) end)
        return true
    end
    return false
end

local function restoreConfig(label)
    local filepath = storageDir .. "/" .. (label or "default") .. ".json"
    if readfile then
        local success, raw = pcall(function() return readfile(filepath) end)
        if success and raw and #raw > 0 then
            local parseOk, parsed = pcall(function() return HttpService:JSONDecode(raw) end)
            if parseOk and type(parsed) == "table" then
                for k, v in pairs(parsed) do
                    if type(v) == "table" and v.__enum then
                        local enumGroup, enumVal = v.__enum:match("Enum%.(%w+)%.(%w+)")
                        if enumGroup and enumVal and Enum[enumGroup] and Enum[enumGroup][enumVal] then
                            cfg[k] = Enum[enumGroup][enumVal]
                        end
                    elseif cfg[k] ~= nil then
                        cfg[k] = v
                    end
                end
                return true
            end
        end
    end
    return false
end

pcall(restoreConfig, "default")

local rodCatalog = {
    {label = "Wooden Rod", cost = 0, str = 8, fortune = 1},
    {label = "Bamboo Rod", cost = 100, str = 11, fortune = 5},
    {label = "Iron Hook Rod", cost = 500, str = 13, fortune = 10},
    {label = "Steel Rod", cost = 1000, str = 17, fortune = 11},
    {label = "Enchanted Steel Rod", cost = 2000, str = 19, fortune = 12},
    {label = "Alloy Rod", cost = 5000, str = 22, fortune = 5},
    {label = "Emerald Rod", cost = 10000, str = 25, fortune = 10},
    {label = "Bloodfire Rod", cost = 20000, str = 27, fortune = 10},
    {label = "Shadow Rod", cost = 60000, str = 29, fortune = 22},
    {label = "Triple Steel Rod", cost = 100000, str = 32, fortune = 20},
    {label = "Golden Rod", cost = 200000, str = 35, fortune = 22},
    {label = "Grandmaster Steel Rod", cost = 250000, str = 37, fortune = 10},
    {label = "Grandmaster Golden Rod", cost = 1000000, str = 45, fortune = 30},
    {label = "Steel Spine Rod", cost = 1500000, str = 48, fortune = 20},
    {label = "Inferno Rod", cost = 1500000, str = 48, fortune = 18},
    {label = "Golden Spine Rod", cost = 2000000, str = 51, fortune = 21},
    {label = "Platinum Spine Rod", cost = 3000000, str = 54, fortune = 25},
    {label = "Diamond Spine Rod", cost = 4000000, str = 56, fortune = 25},
    {label = "Gravisteel Rod", cost = 5000000, str = 58, fortune = 15},
    {label = "Auric Gravity Rod", cost = 6000000, str = 60, fortune = 10},
    {label = "Inferno Gravity Rod", cost = 7000000, str = 62, fortune = 20},
    {label = "Cryo Gravity Rod", cost = 8000000, str = 65, fortune = 36},
    {label = "Thunder Thorn Rod", cost = 10000000, str = 67, fortune = 30},
    {label = "Starlight Rod", cost = 60000000, str = 83, fortune = 15},
}

local rodLabels = {}
for _, r in ipairs(rodCatalog) do table.insert(rodLabels, r.label) end
local baitOptions = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait", "Nameless Bait"}

local forgeMaterials = {
    ["Mountain Fish"] = true, ["Catfish"] = true, ["Crimson Catfish"] = true,
    ["Scarlet Fish"] = true, ["Elder Scarlet Fish"] = true, ["Octoparasitic Fish"] = true,
    ["Tiger Mirefish"] = true, ["Mirage Lanternfish"] = true, ["Golden Guardian Fish"] = true,
    ["Frost Kingfish"] = true, ["Frost Queenfish"] = true, ["Rainbow Dragonfish"] = true,
    ["Sanguine Fish"] = true,
}

local islandWaypoints = {
    {label = "Beginning Isle", coords = Vector3.new(-200.7, 11.1, 35.9)},
    {label = "Bamboo Isle", coords = Vector3.new(-1223.0, 7.3, -24.1)},
    {label = "Fallout Isle", coords = Vector3.new(65.5, 8.8, 1181.3)},
    {label = "Sovereign Isle", coords = Vector3.new(-1276.4, 8.8, 1239.7)},
    {label = "Perch Isle", coords = Vector3.new(-62.0, 11.9, -1321.4)},
    {label = "Frost Isle", coords = Vector3.new(-1366.0, 11.9, -1495.4)},
    {label = "Coconut Isle", coords = Vector3.new(1493.6, 9.1, -1430.6)},
    {label = "Amber Isle", coords = Vector3.new(1259.4, 9.1, 1401.5)},
    {label = "Battlefield Isle", coords = Vector3.new(1393.5, 11.3, 169.6)},
    {label = "Mistpeak Isle", coords = Vector3.new(2660.2, 8.8, -86.7)},
}

local arenaWaypoints = {
    {label = "Octoparasite Buoy", coords = Vector3.new(1608.2, 5.0, -218.3)},
    {label = "Underground Fisher", coords = Vector3.new(112.5, -330.0, -30.8)},
    {label = "Enzo Arena", coords = Vector3.new(-115.3, 9.2, 1349.5)},
}

local dealerWaypoints = {
    {label = "Beginning Dealer", coords = Vector3.new(-151.4, 8.7, -49.9)},
    {label = "Bamboo Dealer", coords = Vector3.new(-1236.8, 7.3, -174.1)},
    {label = "Fallout Dealer", coords = Vector3.new(138.4, 9.0, 1179.7)},
    {label = "Sovereign Dealer", coords = Vector3.new(-1262.6, 8.2, 1202.2)},
    {label = "Perch Dealer", coords = Vector3.new(-9.5, 9.2, -1330.0)},
    {label = "Frost Dealer", coords = Vector3.new(-1400.4, 9.2, -1490.6)},
    {label = "Coconut Dealer", coords = Vector3.new(1446.0, 9.3, -1408.0)},
    {label = "Amber Dealer", coords = Vector3.new(1292.7, 8.2, 1497.4)},
}

local hiddenRodWaypoints = {
    {label = "Anchorbound Rod", coords = Vector3.new(-1208.5, 56.3, 1646.2)},
    {label = "Blazeshark Rod", coords = Vector3.new(-8.4, 53.9, 6.7)},
    {label = "Kraken Rod", coords = Vector3.new(1543.8, 73.4, 1490.9)},
    {label = "Ascendant Bamboo Rod", coords = Vector3.new(-1360.6, 140.6, 31.0)},
    {label = "Lifebloom Rod", coords = Vector3.new(-114.9, 74.9, -1533.2)},
    {label = "Demonic Rod", coords = Vector3.new(1181.9, 82.9, -1243.8)},
}

local function getRoot()
    local ch = lp.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function warpTo(pos)
    local r = getRoot()
    if r then
        r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

local function activatePrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.05)
            prompt:InputHoldEnd()
        end)
    end
end

local function jumpServer()
    pcall(function()
        local pid = game.PlaceId
        local endpoint = "https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?sortOrder=Desc&limit=100"
        local body = HttpService:JSONDecode(game:HttpGet(endpoint))
        if body and body.data then
            for _, srv in ipairs(body.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(pid, srv.id, lp)
                    return
                end
            end
        end
    end)
end

local function equipPreset(rodName, baitName, presetLabel)
    local accountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(lp.UserId)
    if accountData then
        local rodSlot = accountData.FishingRodInventory:FindFirstChild(rodName)
        local owned = rodSlot and rodSlot:FindFirstChild("Owned") and rodSlot.Owned.Value == true
        if owned then
            if remoteHub:FindFirstChild("EquipFishingRod") then remoteHub.EquipFishingRod:InvokeServer(rodName) end
            Library:Notify({Title = "Drift", Description = "Equipped rod: " .. rodName, Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "You do not own " .. rodName, Time = 3})
        end
        local baitSlot = accountData.Bait:FindFirstChild(baitName)
        if baitSlot and baitSlot.Value > 0 then
            if remoteHub:FindFirstChild("EquipBait") then remoteHub.EquipBait:InvokeServer(baitName) end
            Library:Notify({Title = "Drift", Description = "Equipped bait: " .. baitName, Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "No " .. baitName .. " in inventory", Time = 3})
        end
    end
end

Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Heavyweight Fishing",
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
    Fishing = Window:AddTab("Fishing", "fish", "Fish farming features"),
    Equipment = Window:AddTab("Equipment", "backpack", "Change your equipment"),
    World = Window:AddTab("World", "globe", "Other farming features"),
    Visuals = Window:AddTab("Visuals", "eye", "Visual features"),
    Movement = Window:AddTab("Misc", "wrench", "Extra features"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings", "Customize the Interface"),
}
Tabs.Fishing:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})
local CoreBox = Tabs.Fishing:AddGroupbox({
    Side = "Left",
    Name = "Reel",
    IconName = "zap",
})

CoreBox:AddToggle("autoCast", {
    Text = "Auto Cast",
    Default = cfg.autoCast,
    Tooltip = "Casts rod automatically",
})

Toggles.autoCast:OnChanged(function()
    cfg.autoCast = Toggles.autoCast.Value
end)

CoreBox:AddSlider("castFrequency", {
    Text = "Cast Delay",
    Default = cfg.castFrequency,
    Min = 0.5,
    Max = 5.0,
    Rounding = 2,
    Suffix = "s",
})

Options.castFrequency:OnChanged(function()
    cfg.castFrequency = Options.castFrequency.Value
end)

CoreBox:AddToggle("barLock", {
    Text = "Anchor Bar",
    Default = cfg.barLock,
    Tooltip = "Locks minigame bar center",
})

Toggles.barLock:OnChanged(function()
    cfg.barLock = Toggles.barLock.Value
end)

CoreBox:AddToggle("skillBot", {
    Text = "Auto Skills",
    Default = cfg.skillBot,
    Tooltip = "Uses skills while reeling",
})

Toggles.skillBot:OnChanged(function()
    cfg.skillBot = Toggles.skillBot.Value
end)

CoreBox:AddToggle("slamBot", {
    Text = "Auto Slam",
    Default = cfg.slamBot,
    Tooltip = "Clicks slam on prompt",
})

Toggles.slamBot:OnChanged(function()
    cfg.slamBot = Toggles.slamBot.Value
end)

CoreBox:AddToggle("chargeBot", {
    Text = "Auto Charge",
    Default = cfg.chargeBot,
    Tooltip = "Charges durability automatically",
})

Toggles.chargeBot:OnChanged(function()
    cfg.chargeBot = Toggles.chargeBot.Value
end)

local EconomyBox = Tabs.Fishing:AddGroupbox({
    Side = "Right",
    Name = "Economy",
    IconName = "coins",
})

EconomyBox:AddToggle("liquidate", {
    Text = "Auto Sell Fish",
    Default = cfg.liquidate,
    Tooltip = "Sells fish periodically",
})

Toggles.liquidate:OnChanged(function()
    cfg.liquidate = Toggles.liquidate.Value
end)

EconomyBox:AddSlider("liquidateTimer", {
    Text = "Sell Interval",
    Default = cfg.liquidateTimer,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Suffix = "s",
})

Options.liquidateTimer:OnChanged(function()
    cfg.liquidateTimer = Options.liquidateTimer.Value
end)

EconomyBox:AddButton({
    Text = "Sell Now",
    Func = function()
        local r = getRoot()
        if r then
            r.CFrame = CFrame.new(-203.5, 7.3, 107.1)
            task.wait(0.3)
            if remoteHub and remoteHub:FindFirstChild("SellFish") then
                remoteHub.SellFish:FireServer("All")
                Library:Notify({Title = "Drift", Description = "Sold all fish to Nana", Time = 3})
            end
        end
    end,
    Tooltip = "Teleports and sells everything",
})

EconomyBox:AddDivider()

EconomyBox:AddToggle("shieldFish", {
    Text = "Protect Fish",
    Default = cfg.shieldFish,
    Tooltip = "Favourites chosen fish type",
})

Toggles.shieldFish:OnChanged(function()
    cfg.shieldFish = Toggles.shieldFish.Value
end)

local protectedFishList = {"Colossal Tigerfish", "Heavenpiercer Turtle", "Golden Guardian Fish", "Crimson Electric Eel", "Frost Kingfish", "Ascended Perch", "Primordial Kunfish Overlord", "Warbringer Shark", "Mountain Fish", "Tiger Mirefish", "Mirage Lanternfish", "Octoparasitic Fish"}

EconomyBox:AddDropdown("shieldTarget", {
    Values = protectedFishList,
    Default = cfg.shieldTarget,
    Text = "Protected Fish",
    Tooltip = "Fish to favourite",
})

Options.shieldTarget:OnChanged(function()
    cfg.shieldTarget = Options.shieldTarget.Value
end)

EconomyBox:AddToggle("resourceMode", {
    Text = "Material Farming",
    Default = cfg.resourceMode,
    Tooltip = "Protects crafting materials",
})

Toggles.resourceMode:OnChanged(function()
    cfg.resourceMode = Toggles.resourceMode.Value
end)

local SmartEquipBox = Tabs.Equipment:AddGroupbox({
    Side = "Left",
    Name = "Smart Equip",
    IconName = "sparkles",
})

SmartEquipBox:AddToggle("smartBait", {
    Text = "Best Bait",
    Default = cfg.smartBait,
    Tooltip = "Equips highest luck bait",
})

Toggles.smartBait:OnChanged(function()
    cfg.smartBait = Toggles.smartBait.Value
end)

SmartEquipBox:AddToggle("smartRod", {
    Text = "Best Rod",
    Default = cfg.smartRod,
    Tooltip = "Equips strongest owned rod",
})

Toggles.smartRod:OnChanged(function()
    cfg.smartRod = Toggles.smartRod.Value
end)

SmartEquipBox:AddToggle("smartOrb", {
    Text = "Best Orb",
    Default = cfg.smartOrb,
    Tooltip = "Equips top essence orb",
})

Toggles.smartOrb:OnChanged(function()
    cfg.smartOrb = Toggles.smartOrb.Value
end)

local PresetBox = Tabs.Equipment:AddGroupbox({
    Side = "Right",
    Name = "Loadout Presets",
    IconName = "layers",
})

PresetBox:AddDropdown("preset1Rod", {
    Values = rodLabels,
    Default = cfg.preset1Rod,
    Text = "Preset 1 Rod",
})

Options.preset1Rod:OnChanged(function()
    cfg.preset1Rod = Options.preset1Rod.Value
end)

PresetBox:AddDropdown("preset1Bait", {
    Values = baitOptions,
    Default = cfg.preset1Bait,
    Text = "Preset 1 Bait",
})

Options.preset1Bait:OnChanged(function()
    cfg.preset1Bait = Options.preset1Bait.Value
end)

PresetBox:AddButton({
    Text = "Equip Preset 1",
    Func = function()
        equipPreset(cfg.preset1Rod, cfg.preset1Bait, "1")
    end,
})

PresetBox:AddDivider()

PresetBox:AddDropdown("preset2Rod", {
    Values = rodLabels,
    Default = cfg.preset2Rod,
    Text = "Preset 2 Rod",
})

Options.preset2Rod:OnChanged(function()
    cfg.preset2Rod = Options.preset2Rod.Value
end)

PresetBox:AddDropdown("preset2Bait", {
    Values = baitOptions,
    Default = cfg.preset2Bait,
    Text = "Preset 2 Bait",
})

Options.preset2Bait:OnChanged(function()
    cfg.preset2Bait = Options.preset2Bait.Value
end)

PresetBox:AddButton({
    Text = "Equip Preset 2",
    Func = function()
        equipPreset(cfg.preset2Rod, cfg.preset2Bait, "2")
    end,
})

local BossBox = Tabs.Fishing:AddGroupbox({
    Side = "Left",
    Name = "Bosses",
    IconName = "skull",
})

BossBox:AddToggle("rhythmBot", {
    Text = "Octo Rhythm Bot",
    Default = cfg.rhythmBot,
    Tooltip = "Perfect rhythm timing",
})

Toggles.rhythmBot:OnChanged(function()
    cfg.rhythmBot = Toggles.rhythmBot.Value
end)

BossBox:AddToggle("bossGrind", {
    Text = "Auto Farm Enzo",
    Default = cfg.bossGrind,
    Tooltip = "Summons and defeats Enzo",
})

Toggles.bossGrind:OnChanged(function()
    cfg.bossGrind = Toggles.bossGrind.Value
end)

BossBox:AddToggle("secretBossGrind", {
    Text = "Auto Secret Boss",
    Default = cfg.secretBossGrind,
    Tooltip = "Crafts bait, summons, kills",
})

Toggles.secretBossGrind:OnChanged(function()
    cfg.secretBossGrind = Toggles.secretBossGrind.Value
end)

BossBox:AddDivider()

BossBox:AddButton({
    Text = "Teleport to Octoparasite",
    Func = function()
        if warpTo(Vector3.new(1608.2, 5.0, -218.3)) then
            Library:Notify({Title = "Drift", Description = "Arrived at ocean boss buoy", Time = 3})
        end
    end,
})

BossBox:AddButton({
    Text = "Teleport to Enzo",
    Func = function()
        if warpTo(Vector3.new(-115.3, 9.2, 1349.5)) then
            Library:Notify({Title = "Drift", Description = "Arrived at Enzo arena", Time = 3})
        end
    end,
})

BossBox:AddButton({
    Text = "Teleport to Fisher Realm",
    Func = function()
        if warpTo(Vector3.new(112.5, -330.0, -30.8)) then
            Library:Notify({Title = "Drift", Description = "Arrived at underground realm", Time = 3})
        end
    end,
})

local SpiritBox = Tabs.Fishing:AddGroupbox({
    Side = "Right",
    Name = "God Spirits",
    IconName = "sun",
})

SpiritBox:AddButton({
    Text = "Check Spirit Status",
    Func = function()
        local accountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(lp.UserId)
        if accountData and accountData:FindFirstChild("GodSpirit") then
            local y = accountData.GodSpirit:FindFirstChild("Yellow") and accountData.GodSpirit.Yellow.Value or false
            local b = accountData.GodSpirit:FindFirstChild("Blue") and accountData.GodSpirit.Blue.Value or false
            local g = accountData.GodSpirit:FindFirstChild("Green") and accountData.GodSpirit.Green.Value or false
            local msg = string.format("Yellow: %s | Blue: %s | Green: %s", y and "Active" or "Off", b and "Active" or "Off", g and "Active" or "Off")
            Library:Notify({Title = "Drift", Description = msg, Time = 5})
        else
            Library:Notify({Title = "Drift", Description = "Could not read spirit data", Time = 3})
        end
    end,
    Tooltip = "Shows blessing status",
})

SpiritBox:AddToggle("spiritPray", {
    Text = "Auto Pray",
    Default = cfg.spiritPray,
    Tooltip = "Prays at altar nearby",
})

Toggles.spiritPray:OnChanged(function()
    cfg.spiritPray = Toggles.spiritPray.Value
end)

SpiritBox:AddButton({
    Text = "Teleport to Altar",
    Func = function()
        local spirit = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
        if spirit then
            local r = getRoot()
            if r then
                r.CFrame = spirit:GetPivot() + Vector3.new(0, 3, 5)
                Library:Notify({Title = "Drift", Description = "Arrived at spirit altar", Time = 3})
            end
        else
            if warpTo(Vector3.new(1245.7, 19.3, -133.4)) then
                Library:Notify({Title = "Drift", Description = "Warped to shrine location", Time = 3})
            end
        end
    end,
})

SpiritBox:AddButton({
    Text = "Pray Now",
    Func = function()
        local sp = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
        if sp then
            local triggered = false
            for _, d in ipairs(sp:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    activatePrompt(d)
                    triggered = true
                end
            end
            Library:Notify({Title = "Drift", Description = triggered and "Prayed at altar" or "No prompt found", Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "Spirit not spawned here", Time = 3})
        end
    end,
})

SpiritBox:AddDivider()

SpiritBox:AddToggle("hopSpirit", {
    Text = "Hop for Spirit",
    Default = cfg.hopSpirit,
    Tooltip = "Hops until spirit found",
})

Toggles.hopSpirit:OnChanged(function()
    cfg.hopSpirit = Toggles.hopSpirit.Value
end)

SpiritBox:AddToggle("hopMaoshan", {
    Text = "Hop for Maoshan",
    Default = cfg.hopMaoshan,
    Tooltip = "Hops until Maoshan found",
})

Toggles.hopMaoshan:OnChanged(function()
    cfg.hopMaoshan = Toggles.hopMaoshan.Value
end)

SpiritBox:AddToggle("hopTaoist", {
    Text = "Hop for Taoist",
    Default = cfg.hopTaoist,
    Tooltip = "Hops until Taoist found",
})

Toggles.hopTaoist:OnChanged(function()
    cfg.hopTaoist = Toggles.hopTaoist.Value
end)

SpiritBox:AddButton({
    Text = "Server Hop Now",
    Func = function()
        Library:Notify({Title = "Drift", Description = "Searching for a server...", Time = 3})
        jumpServer()
    end,
})

local QuestBox = Tabs.World:AddGroupbox({
    Side = "Left",
    Name = "Quests & Rewards",
    IconName = "scroll",
})

QuestBox:AddToggle("ticketGrind", {
    Text = "Auto Ticket Quest",
    Default = cfg.ticketGrind,
    Tooltip = "Accepts and submits quests",
})

Toggles.ticketGrind:OnChanged(function()
    cfg.ticketGrind = Toggles.ticketGrind.Value
end)

QuestBox:AddDropdown("ticketTier", {
    Values = {"Easy", "Hard"},
    Default = cfg.ticketTier,
    Text = "Difficulty",
})

Options.ticketTier:OnChanged(function()
    cfg.ticketTier = Options.ticketTier.Value
end)

QuestBox:AddButton({
    Text = "Submit Easy Quest",
    Func = function()
        if remoteHub and remoteHub:FindFirstChild("ClaimQuest") then
            remoteHub.ClaimQuest:FireServer("Ticket", "Easy")
            Library:Notify({Title = "Drift", Description = "Submitted easy ticket quest", Time = 3})
        end
    end,
})

QuestBox:AddButton({
    Text = "Submit Hard Quest",
    Func = function()
        if remoteHub and remoteHub:FindFirstChild("ClaimQuest") then
            remoteHub.ClaimQuest:FireServer("Ticket", "Hard")
            Library:Notify({Title = "Drift", Description = "Submitted hard ticket quest", Time = 3})
        end
    end,
})

QuestBox:AddDivider()

QuestBox:AddButton({
    Text = "Collect Daily Quests",
    Func = function()
        if remoteHub and remoteHub:FindFirstChild("ClaimQuest") then
            for i = 1, 4 do remoteHub.ClaimQuest:FireServer("Daily", i) end
            Library:Notify({Title = "Drift", Description = "Collected available dailies", Time = 3})
        end
    end,
    Tooltip = "Grabs all daily quests",
})

QuestBox:AddButton({
    Text = "Claim Days 1-7",
    Func = function()
        task.spawn(function()
            if remoteHub and remoteHub:FindFirstChild("DailyReward") then
                for day = 1, 7 do
                    remoteHub.DailyReward:FireServer(day)
                    task.wait(cfg.dailyPause)
                end
                Library:Notify({Title = "Drift", Description = "Claimed all 7 daily rewards", Time = 3})
            end
        end)
    end,
    Tooltip = "Batch claims all rewards",
})

QuestBox:AddButton({
    Text = "Redeem All Codes",
    Func = function()
        local codes = {"33MVisits", "32MVisits", "31MVisits", "30MVisits", "Taiji", "49KLikes", "48KLikes", "47KLikes", "46KLikes", "13KActives", "HWF", "RELEASE"}
        if remoteHub and remoteHub:FindFirstChild("RedeemCode") then
            for _, c in ipairs(codes) do
                remoteHub.RedeemCode:FireServer(c)
                task.wait(0.2)
            end
            Library:Notify({Title = "Drift", Description = "Redeemed all known codes", Time = 3})
        end
    end,
    Tooltip = "Redeems all promo codes",
})

local ShopBox = Tabs.World:AddGroupbox({
    Side = "Right",
    Name = "Shop & Crafting",
    IconName = "shopping-cart",
})

ShopBox:AddDropdown("forgeTarget", {
    Values = {"Nameless Bait", "Frost Bait", "Rainbow Bait"},
    Default = cfg.forgeTarget,
    Text = "Craft Target",
})

Options.forgeTarget:OnChanged(function()
    cfg.forgeTarget = Options.forgeTarget.Value
end)

ShopBox:AddSlider("forgeQuantity", {
    Text = "Craft Amount",
    Default = cfg.forgeQuantity,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

Options.forgeQuantity:OnChanged(function()
    cfg.forgeQuantity = Options.forgeQuantity.Value
end)

ShopBox:AddToggle("baitForge", {
    Text = "Auto Craft Bait",
    Default = cfg.baitForge,
    Tooltip = "Crafts when ingredients exist",
})

Toggles.baitForge:OnChanged(function()
    cfg.baitForge = Toggles.baitForge.Value
end)

ShopBox:AddDivider()

ShopBox:AddDropdown("restockTarget", {
    Values = {"Ancestral Bait", "Elite Bait", "Corrupted Essence Bait", "Crude Mash Bait", "Basic Bait"},
    Default = cfg.restockTarget,
    Text = "Buy Target",
})

Options.restockTarget:OnChanged(function()
    cfg.restockTarget = Options.restockTarget.Value
end)

ShopBox:AddSlider("restockQuantity", {
    Text = "Buy Amount",
    Default = cfg.restockQuantity,
    Min = 1,
    Max = 50,
    Rounding = 0,
})

Options.restockQuantity:OnChanged(function()
    cfg.restockQuantity = Options.restockQuantity.Value
end)

ShopBox:AddSlider("restockFloor", {
    Text = "Stock Threshold",
    Default = cfg.restockFloor,
    Min = 5,
    Max = 50,
    Rounding = 0,
})

Options.restockFloor:OnChanged(function()
    cfg.restockFloor = Options.restockFloor.Value
end)

ShopBox:AddToggle("baitRestock", {
    Text = "Auto Buy Bait",
    Default = cfg.baitRestock,
    Tooltip = "Restocks when inventory low",
})

Toggles.baitRestock:OnChanged(function()
    cfg.baitRestock = Toggles.baitRestock.Value
end)

ShopBox:AddDivider()

ShopBox:AddDropdown("bannerChoice", {
    Values = {"Taiji Banner", "Egoless Banner"},
    Default = cfg.bannerChoice,
    Text = "Gacha Banner",
})

Options.bannerChoice:OnChanged(function()
    cfg.bannerChoice = Options.bannerChoice.Value
end)

ShopBox:AddSlider("pullBatch", {
    Text = "Pulls Per Action",
    Default = cfg.pullBatch,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

Options.pullBatch:OnChanged(function()
    cfg.pullBatch = Options.pullBatch.Value
end)

ShopBox:AddToggle("bannerPull", {
    Text = "Auto Gacha",
    Default = cfg.bannerPull,
    Tooltip = "Pulls from selected banner",
})

Toggles.bannerPull:OnChanged(function()
    cfg.bannerPull = Toggles.bannerPull.Value
end)

local TeleportLeftBox = Tabs.World:AddGroupbox({
    Side = "Left",
    Name = "Island Teleports",
    IconName = "map-pin",
})

for _, isl in ipairs(islandWaypoints) do
    TeleportLeftBox:AddButton({
        Text = isl.label,
        Func = function()
            if warpTo(isl.coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. isl.label, Time = 3})
            end
        end,
    })
end

local TeleportRightBox = Tabs.World:AddGroupbox({
    Side = "Right",
    Name = "Special Locations",
    IconName = "compass",
})

TeleportRightBox:AddLabel("Boss Arenas")

for _, ar in ipairs(arenaWaypoints) do
    TeleportRightBox:AddButton({
        Text = ar.label,
        Func = function()
            if warpTo(ar.coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. ar.label, Time = 3})
            end
        end,
    })
end

TeleportRightBox:AddDivider()
TeleportRightBox:AddLabel("Secret Rods")

for _, sr in ipairs(hiddenRodWaypoints) do
    TeleportRightBox:AddButton({
        Text = sr.label,
        Func = function()
            if warpTo(sr.coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. sr.label, Time = 3})
            end
        end,
    })
end

TeleportRightBox:AddDivider()

TeleportRightBox:AddButton({
    Text = "Random Player",
    Func = function()
        local pool = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(pool, p)
            end
        end
        if #pool == 0 then
            Library:Notify({Title = "Drift", Description = "No other players found", Time = 3})
            return
        end
        local pick = pool[math.random(1, #pool)]
        local r = getRoot()
        if r and pick.Character and pick.Character:FindFirstChild("HumanoidRootPart") then
            r.CFrame = pick.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
            Library:Notify({Title = "Drift", Description = "Teleported to " .. pick.DisplayName, Time = 3})
        end
    end,
    Tooltip = "Warps to random player",
})

local MarkerBox = Tabs.Visuals:AddGroupbox({
    Side = "Left",
    Name = "ESP",
    IconName = "eye",
})

MarkerBox:AddToggle("markerSpirit", {
    Text = "God Spirit",
    Default = cfg.markerSpirit,
    Tooltip = "Highlights active spirits",
})

Toggles.markerSpirit:OnChanged(function()
    cfg.markerSpirit = Toggles.markerSpirit.Value
end)

MarkerBox:AddToggle("markerRod", {
    Text = "Secret Rods",
    Default = cfg.markerRod,
    Tooltip = "Marks secret rod spawns",
})

Toggles.markerRod:OnChanged(function()
    cfg.markerRod = Toggles.markerRod.Value
end)

MarkerBox:AddToggle("markerBoat", {
    Text = "Boats",
    Default = cfg.markerBoat,
    Tooltip = "Highlights nearby boats",
})

Toggles.markerBoat:OnChanged(function()
    cfg.markerBoat = Toggles.markerBoat.Value
end)

MarkerBox:AddToggle("markerMaoshan", {
    Text = "Maoshan",
    Default = cfg.markerMaoshan,
    Tooltip = "Marks Maoshan NPC",
})

Toggles.markerMaoshan:OnChanged(function()
    cfg.markerMaoshan = Toggles.markerMaoshan.Value
end)

MarkerBox:AddToggle("markerTaoist", {
    Text = "Taoist",
    Default = cfg.markerTaoist,
    Tooltip = "Marks Taoist NPC",
})

Toggles.markerTaoist:OnChanged(function()
    cfg.markerTaoist = Toggles.markerTaoist.Value
end)

MarkerBox:AddToggle("markerBoss", {
    Text = "Bosses",
    Default = cfg.markerBoss,
    Tooltip = "Highlights active bosses",
})

Toggles.markerBoss:OnChanged(function()
    cfg.markerBoss = Toggles.markerBoss.Value
end)

MarkerBox:AddToggle("markerPlayers", {
    Text = "Players",
    Default = cfg.markerPlayers,
    Tooltip = "Shows player markers",
})

Toggles.markerPlayers:OnChanged(function()
    cfg.markerPlayers = Toggles.markerPlayers.Value
end)

MarkerBox:AddToggle("hookRing", {
    Text = "Fish Target Ring",
    Default = cfg.hookRing,
    Tooltip = "Red ring on hooked fish",
})

Toggles.hookRing:OnChanged(function()
    cfg.hookRing = Toggles.hookRing.Value
end)

local RenderBox = Tabs.Visuals:AddGroupbox({
    Side = "Right",
    Name = "Rendering",
    IconName = "monitor",
})

RenderBox:AddToggle("clearFog", {
    Text = "No Fog",
    Default = cfg.clearFog,
    Tooltip = "Removes all fog effects",
})

Toggles.clearFog:OnChanged(function()
    cfg.clearFog = Toggles.clearFog.Value
    if cfg.clearFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then atmo.Density = 0; atmo.Haze = 0; atmo.Glare = 0 end
        for _, d in ipairs(cam:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d.Enabled = false end
        end
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then atmo.Density = 0.3; atmo.Haze = 0.5 end
    end
end)

RenderBox:AddToggle("maxBright", {
    Text = "Fullbright",
    Default = cfg.maxBright,
    Tooltip = "Maximum ambient lighting",
})

Toggles.maxBright:OnChanged(function()
    cfg.maxBright = Toggles.maxBright.Value
    if not cfg.maxBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end
end)

RenderBox:AddToggle("lowGfx", {
    Text = "Performance Mode",
    Default = cfg.lowGfx,
    Tooltip = "Disables shadows and effects",
})

Toggles.lowGfx:OnChanged(function()
    cfg.lowGfx = Toggles.lowGfx.Value
    Lighting.GlobalShadows = not cfg.lowGfx
end)

RenderBox:AddToggle("stripUi", {
    Text = "Hide Game UI",
    Default = cfg.stripUi,
    Tooltip = "Hides default game interface",
})

Toggles.stripUi:OnChanged(function()
    cfg.stripUi = Toggles.stripUi.Value
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        if pg:FindFirstChild("MainGui") then pg.MainGui.Enabled = not cfg.stripUi end
        if pg:FindFirstChild("Fisher_GUI") then pg.Fisher_GUI.Enabled = not cfg.stripUi end
    end
end)

RenderBox:AddDivider()

RenderBox:AddButton({
    Text = "Unlock All Index",
    Func = function()
        local revealed = 0
        local accountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(lp.UserId)
        if accountData and accountData:FindFirstChild("Index") then
            for _, b in ipairs(accountData.Index:GetChildren()) do
                if b:IsA("BoolValue") then b.Value = true end
            end
        end
        local pg = lp:FindFirstChild("PlayerGui")
        if pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Menu") and pg.MainGui.Menu:FindFirstChild("Index") then
            local indexList = pg.MainGui.Menu.Index:FindFirstChild("IndexFrame") and pg.MainGui.Menu.Index.IndexFrame:FindFirstChild("Indexlist")
            if indexList then
                for _, f in ipairs(indexList:GetChildren()) do
                    if f:IsA("Frame") then
                        revealed = revealed + 1
                        local btn = f:FindFirstChild("Button")
                        if btn then
                            local title = btn:FindFirstChild("Title")
                            if title and title:IsA("TextLabel") then title.Text = f.Name end
                            local detail = btn:FindFirstChild("Detail")
                            if detail then
                                detail.Visible = true
                                for _, img in ipairs(detail:GetDescendants()) do
                                    if img:IsA("ImageLabel") then img.ImageColor3 = Color3.new(1, 1, 1) end
                                end
                            end
                        end
                    end
                end
            end
        end
        Library:Notify({Title = "Drift", Description = string.format("Revealed %d fish in index", revealed > 0 and revealed or 109), Time = 4})
    end,
    Tooltip = "Shows all fish entries",
})

local MoveBox = Tabs.Movement:AddGroupbox({
    Side = "Left",
    Name = "Movement",
    IconName = "footprints",
})

MoveBox:AddToggle("speedHack", {
    Text = "Speed Boost",
    Default = cfg.speedHack,
    Tooltip = "Increases walk speed",
})

Toggles.speedHack:OnChanged(function()
    cfg.speedHack = Toggles.speedHack.Value
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = cfg.speedHack and cfg.speedAmount or 16 end
end)

MoveBox:AddSlider("speedAmount", {
    Text = "Speed Value",
    Default = cfg.speedAmount,
    Min = 16,
    Max = 120,
    Rounding = 0,
})

Options.speedAmount:OnChanged(function()
    cfg.speedAmount = Options.speedAmount.Value
    if cfg.speedHack then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = cfg.speedAmount end
    end
end)

MoveBox:AddToggle("flightMode", {
    Text = "Fly",
    Default = cfg.flightMode,
    Tooltip = "Free flight with WASD",
})

Toggles.flightMode:OnChanged(function()
    cfg.flightMode = Toggles.flightMode.Value
end)

MoveBox:AddSlider("flightVelocity", {
    Text = "Fly Speed",
    Default = cfg.flightVelocity,
    Min = 20,
    Max = 150,
    Rounding = 0,
})

Options.flightVelocity:OnChanged(function()
    cfg.flightVelocity = Options.flightVelocity.Value
end)

MoveBox:AddToggle("moonJump", {
    Text = "Infinite Jump",
    Default = cfg.moonJump,
    Tooltip = "Jump infinitely mid-air",
})

Toggles.moonJump:OnChanged(function()
    cfg.moonJump = Toggles.moonJump.Value
end)

MoveBox:AddToggle("waterWalk", {
    Text = "Walk on Water",
    Default = cfg.waterWalk,
    Tooltip = "Stand on ocean surface",
})

Toggles.waterWalk:OnChanged(function()
    cfg.waterWalk = Toggles.waterWalk.Value
end)

MoveBox:AddToggle("phaseThrough", {
    Text = "Noclip",
    Default = cfg.phaseThrough,
    Tooltip = "Walk through solid walls",
})

Toggles.phaseThrough:OnChanged(function()
    cfg.phaseThrough = Toggles.phaseThrough.Value
end)

local StabilityBox = Tabs.Movement:AddGroupbox({
    Side = "Right",
    Name = "Extra",
    IconName = "shield",
})

StabilityBox:AddToggle("idleGuard", {
    Text = "Anti-AFK",
    Default = cfg.idleGuard,
    Tooltip = "Prevents idle disconnect",
})

Toggles.idleGuard:OnChanged(function()
    cfg.idleGuard = Toggles.idleGuard.Value
end)

StabilityBox:AddToggle("reconnect", {
    Text = "Auto Rejoin",
    Default = cfg.reconnect,
    Tooltip = "Reconnects after kick",
})

Toggles.reconnect:OnChanged(function()
    cfg.reconnect = Toggles.reconnect.Value
end)

StabilityBox:AddDivider()

StabilityBox:AddButton({
    Text = "Save Config",
    Func = function()
        if persistConfig() then
            Library:Notify({Title = "Drift", Description = "Configuration saved successfully", Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "Failed to save configuration", Time = 3})
        end
    end,
    Tooltip = "Saves all current settings",
})

StabilityBox:AddButton({
    Text = "Load Config",
    Func = function()
        if restoreConfig() then
            Library:Notify({Title = "Drift", Description = "Configuration loaded successfully", Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "No saved configuration found", Time = 3})
        end
    end,
    Tooltip = "Loads saved settings",
})

local MenuGroup = Tabs["UI Settings"]:AddGroupbox({
    Side = "Left",
    Name = "Menu",
    IconName = "wrench",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = Library.ShowCustomCursor,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"},
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightControl",
    NoUI = true,
    Text = "Menu keybind",
})

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
    DoubleClick = true,
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/heavyweight-fishing")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

local seaFloor = trackObject(Instance.new("Part"))
seaFloor.Name = "DriftSeaFloor"
seaFloor.Size = Vector3.new(60, 2, 60)
seaFloor.Anchored = true
seaFloor.CanCollide = false
seaFloor.Transparency = 1
seaFloor.Parent = Workspace

local espBin = trackObject(Instance.new("Folder"))
espBin.Name = "DriftESP"
espBin.Parent = Workspace

local ringBase = trackObject(Instance.new("Part"))
ringBase.Name = "DriftRingBase"
ringBase.Size = Vector3.new(0.5, 0.5, 0.5)
ringBase.Transparency = 1
ringBase.CanCollide = false
ringBase.Anchored = true
ringBase.Parent = Workspace

local ringVisual = Instance.new("CylinderHandleAdornment")
ringVisual.Name = "DriftRing"
ringVisual.Adornee = ringBase
ringVisual.AlwaysOnTop = true
ringVisual.ZIndex = 5
ringVisual.Radius = 4.5
ringVisual.InnerRadius = 4.35
ringVisual.Height = 0.05
ringVisual.Color3 = Color3.fromRGB(255, 50, 50)
ringVisual.Transparency = 0.1
ringVisual.CFrame = CFrame.Angles(math.rad(90), 0, 0)
ringVisual.Visible = false
ringVisual.Parent = ringBase

local trackedMarkers = {}

local function attachMarker(inst, tag, category, tint)
    if not inst or trackedMarkers[inst] then return end
    local anchor = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart")
    if not anchor then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Marker_" .. tag
    billboard.Size = UDim2.new(0, 200, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = anchor
    billboard.Parent = espBin

    local txt = Instance.new("TextLabel", billboard)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.Text = tag
    txt.TextColor3 = tint or Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.TextSize = 12

    trackedMarkers[inst] = {gui = billboard, text = txt, anchor = anchor, category = category, tag = tag}
end

local function detachMarker(inst)
    local data = trackedMarkers[inst]
    if data then
        if data.gui and data.gui.Parent then data.gui:Destroy() end
        trackedMarkers[inst] = nil
    end
end

local castClock = 0
local sellClock = 0
local skillClock = 0
local gachaClock = 0
local restockClock = 0
local questClock = 0
local prayClock = 0
local equipClock = 0
local progressClock = 0
local shieldClock = 0

hookEvent(RunService.Heartbeat, function()
    if not sessionActive then return end
    pcall(function()
        local ch = lp.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local now = tick()
        local pg = lp:FindFirstChild("PlayerGui")
        local accountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(lp.UserId)

        if cfg.speedHack then
            hum.WalkSpeed = cfg.speedAmount
        end

        if cfg.waterWalk then
            seaFloor.CFrame = CFrame.new(root.Position.X, 0, root.Position.Z)
            seaFloor.CanCollide = (root.Position.Y >= -1)
        else
            seaFloor.CanCollide = false
        end

        if cfg.phaseThrough then
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        local hooked = ch:GetAttribute("Fishing") == true
        local inMinigame = ch:GetAttribute("Minigame") == true or (pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing") and pg.MainGui.Fishing.Visible)
        local onCooldown = ch:GetAttribute("CDForTheNextThrow") == true
        local swimming = ch:GetAttribute("Swimming") == true

        if inMinigame then
            local fPanel = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
            if fPanel and fPanel.Visible then
                if cfg.barLock then
                    local barFrame = fPanel:FindFirstChild("BarFrame")
                    if barFrame and barFrame:FindFirstChild("Bar") then
                        barFrame.Bar:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                        barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end

                if cfg.slamBot and fPanel:FindFirstChild("PerfectButton") and fPanel.PerfectButton.Visible then
                    if remoteHub:FindFirstChild("Slam") then remoteHub.Slam:FireServer() end
                end

                if cfg.chargeBot and fPanel:FindFirstChild("Charge") and fPanel.Charge.Visible then
                    if remoteHub:FindFirstChild("Charge") then remoteHub.Charge:FireServer() end
                end

                if cfg.barLock and (now - progressClock >= 0.08) then
                    if remoteHub and remoteHub:FindFirstChild("UpdateFishProgression") then
                        remoteHub.UpdateFishProgression:FireServer()
                    end
                    progressClock = now
                end

                if cfg.skillBot and (now - skillClock >= 0.15) then
                    for _, key in ipairs({"Z", "X", "C", "V"}) do
                        if remoteHub:FindFirstChild("UseSkill") then remoteHub.UseSkill:FireServer(key) end
                        if remoteHub:FindFirstChild("TriggerMinigameSkill") then remoteHub.TriggerMinigameSkill:FireServer(key) end
                    end
                    skillClock = now
                end
            end
        elseif hooked then
            castClock = now
        else
            if cfg.autoCast and not onCooldown and not swimming and (now - castClock >= cfg.castFrequency) then
                local canFish = true
                if accountData and accountData:FindFirstChild("InventoryLimit") then
                    local invCount = 0
                    if accountData:FindFirstChild("Inventory") then invCount = invCount + #accountData.Inventory:GetChildren() end
                    if accountData:FindFirstChild("Hotbar") then
                        for _, item in ipairs(accountData.Hotbar:GetChildren()) do
                            if item:FindFirstChild("Quantity") then invCount = invCount + item.Quantity.Value else invCount = invCount + 1 end
                        end
                    end
                    if invCount >= accountData.InventoryLimit.Value then
                        canFish = false
                        if cfg.liquidate and (now - sellClock >= 5.0) and remoteHub:FindFirstChild("SellFish") then
                            if (cfg.resourceMode or cfg.shieldFish) and accountData:FindFirstChild("Inventory") then
                                for _, item in ipairs(accountData.Inventory:GetChildren()) do
                                    local iName = item.Name
                                    local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                                    if not isFav and ((cfg.resourceMode and forgeMaterials[iName]) or (cfg.shieldFish and iName == cfg.shieldTarget)) then
                                        if remoteHub:FindFirstChild("FavoriteItem") then remoteHub.FavoriteItem:FireServer(item) end
                                    end
                                end
                            end
                            remoteHub.SellFish:FireServer("All")
                            sellClock = now
                        end
                    end
                end

                if cfg.liquidate and (now - sellClock >= cfg.liquidateTimer) and remoteHub:FindFirstChild("SellFish") then
                    if (cfg.resourceMode or cfg.shieldFish) and accountData and accountData:FindFirstChild("Inventory") then
                        for _, item in ipairs(accountData.Inventory:GetChildren()) do
                            local iName = item.Name
                            local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                            if not isFav and ((cfg.resourceMode and forgeMaterials[iName]) or (cfg.shieldFish and iName == cfg.shieldTarget)) then
                                if remoteHub:FindFirstChild("FavoriteItem") then remoteHub.FavoriteItem:FireServer(item) end
                            end
                        end
                    end
                    remoteHub.SellFish:FireServer("All")
                    sellClock = now
                end

                if (cfg.resourceMode or cfg.shieldFish) and (now - shieldClock >= 1.5) and accountData and accountData:FindFirstChild("Inventory") then
                    shieldClock = now
                    for _, item in ipairs(accountData.Inventory:GetChildren()) do
                        local iName = item.Name
                        local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                        if not isFav then
                            local protect = false
                            if cfg.resourceMode and forgeMaterials[iName] then protect = true end
                            if cfg.shieldFish and iName == cfg.shieldTarget then protect = true end
                            if protect and remoteHub:FindFirstChild("FavoriteItem") then
                                remoteHub.FavoriteItem:FireServer(item)
                            end
                        end
                    end
                end

                if canFish and remoteHub and remoteHub:FindFirstChild("Fishing") then
                    remoteHub.Fishing:FireServer(root.CFrame)
                    castClock = now
                end
            end
        end

        if (now - equipClock >= 5.0) and accountData then
            equipClock = now
            if cfg.smartBait and accountData:FindFirstChild("Bait") and accountData:FindFirstChild("EquippedBait") and remoteHub:FindFirstChild("EquipBait") then
                local topBait = nil
                local topLuck = -1
                local baitLookup = {
                    ["Ancestral Bait"] = 50, ["Elite Bait"] = 30,
                    ["Corrupted Essence Bait"] = 18, ["Crude Mash Bait"] = 8, ["Basic Bait"] = 3,
                }
                for bName, bLuck in pairs(baitLookup) do
                    local slot = accountData.Bait:FindFirstChild(bName)
                    if slot and slot.Value > 0 and bLuck > topLuck then
                        topLuck = bLuck
                        topBait = bName
                    end
                end
                if topBait and accountData.EquippedBait.Value ~= topBait then
                    remoteHub.EquipBait:InvokeServer(topBait)
                end
            end

            if cfg.smartRod and accountData:FindFirstChild("FishingRodInventory") and accountData:FindFirstChild("FishingRod") and remoteHub:FindFirstChild("EquipFishingRod") then
                local topRod = nil
                local topStr = -1
                for _, r in ipairs(rodCatalog) do
                    local rSlot = accountData.FishingRodInventory:FindFirstChild(r.label)
                    local owned = rSlot and rSlot:FindFirstChild("Owned") and rSlot.Owned.Value == true
                    if owned and r.str > topStr then
                        topStr = r.str
                        topRod = r.label
                    end
                end
                if topRod and accountData.FishingRod.Value ~= topRod then
                    remoteHub.EquipFishingRod:InvokeServer(topRod)
                end
            end

            if cfg.smartOrb and accountData:FindFirstChild("Orb") and remoteHub:FindFirstChild("EquipOrb") then
                local orbs = accountData.Orb:GetChildren()
                if #orbs > 0 then remoteHub.EquipOrb:InvokeServer(orbs[#orbs].Name) end
            end
        end

        if cfg.liquidate and (now - sellClock >= cfg.liquidateTimer) then
            if remoteHub and remoteHub:FindFirstChild("SellFish") then
                remoteHub.SellFish:FireServer("All")
                sellClock = now
            end
        end

        if cfg.spiritPray and (now - prayClock >= 3.0) then
            if Workspace:FindFirstChild("NPC") then
                local sp = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
                if sp then
                    for _, d in ipairs(sp:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            activatePrompt(d)
                            prayClock = now
                        end
                    end
                end
            end
        end

        if cfg.ticketGrind and (now - questClock >= 2.0) then
            if remoteHub and remoteHub:FindFirstChild("ClaimQuest") then
                remoteHub.ClaimQuest:FireServer("Ticket", cfg.ticketTier)
                questClock = now
            end
        end

        if cfg.dailyGrab and (now - castClock >= 2.0) then
            if remoteHub and remoteHub:FindFirstChild("DailyReward") then
                for day = 1, 7 do remoteHub.DailyReward:FireServer(day) end
            end
        end

        if cfg.bannerPull and (now - gachaClock >= 1.5) then
            if remoteHub and remoteHub:FindFirstChild("Gacha") then
                remoteHub.Gacha:FireServer(cfg.bannerChoice, cfg.pullBatch)
                gachaClock = now
            end
        end

        if cfg.baitForge and (now - castClock >= 2.0) then
            if remoteHub and remoteHub:FindFirstChild("CraftBait") then
                remoteHub.CraftBait:FireServer(cfg.forgeTarget, cfg.forgeQuantity)
            end
        end

        if cfg.baitRestock and (now - restockClock >= cfg.restockPause) then
            if remoteHub and remoteHub:FindFirstChild("BuyBait") then
                remoteHub.BuyBait:FireServer(cfg.restockTarget, cfg.restockQuantity)
                restockClock = now
            end
        end

        if cfg.rhythmBot then
            if remoteHub and remoteHub:FindFirstChild("RhythmHit") then
                remoteHub.RhythmHit:FireServer(true, 100)
            end
        end
    end)
end)

local velocityBody, gyroBody = nil, nil

hookEvent(RunService.RenderStepped, function()
    if not sessionActive then return end
    local ch = lp.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if cfg.flightMode then
        if not velocityBody then
            velocityBody = trackObject(Instance.new("BodyVelocity"))
            velocityBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            velocityBody.Parent = root

            gyroBody = trackObject(Instance.new("BodyGyro"))
            gyroBody.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            gyroBody.Parent = root
        end

        local camCF = cam.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        gyroBody.CFrame = camCF
        velocityBody.Velocity = dir.Magnitude > 0 and dir.Unit * cfg.flightVelocity or Vector3.zero
    else
        if velocityBody then velocityBody:Destroy(); velocityBody = nil end
        if gyroBody then gyroBody:Destroy(); gyroBody = nil end
    end
end)

hookEvent(RunService.RenderStepped, function()
    if not sessionActive then return end
    pcall(function()
        if cfg.barLock then
            local pg = lp:FindFirstChild("PlayerGui")
            if pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing") and pg.MainGui.Fishing.Visible then
                local fPanel = pg.MainGui.Fishing
                local barFrame = fPanel:FindFirstChild("BarFrame")
                if barFrame and barFrame:FindFirstChild("Bar") then
                    barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                end
                local bossBar = fPanel:FindFirstChild("BossFightBar")
                if bossBar and bossBar.Visible and bossBar:FindFirstChild("Bar") and bossBar:FindFirstChild("Hitbox") then
                    bossBar.Bar.Position = bossBar.Hitbox.Position
                end
                local hpPlayer = fPanel:FindFirstChild("HPPlayer")
                if hpPlayer and hpPlayer:FindFirstChild("ProgressionBar") then
                    local pBar = hpPlayer.ProgressionBar
                    if pBar:FindFirstChild("Bar") then pBar.Bar.Size = UDim2.new(1, 0, 1, 0) end
                end
                if fPanel:FindFirstChild("PerfectButton") and fPanel.PerfectButton.Visible then
                    if remoteHub and remoteHub:FindFirstChild("Slam") then remoteHub.Slam:FireServer("Perfect") end
                end
                if fPanel:FindFirstChild("Charge") and fPanel.Charge.Visible then
                    if remoteHub and remoteHub:FindFirstChild("Charge") then remoteHub.Charge:FireServer(100) end
                end
                local cutscene = pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Cutscene")
                if cutscene and cutscene:FindFirstChild("Hurt") then
                    cutscene.Hurt.ImageTransparency = 1
                end
                local impactCS = pg:FindFirstChild("Impact") and pg.Impact:FindFirstChild("Cutscene")
                if impactCS and impactCS:FindFirstChild("Hurt") then
                    impactCS.Hurt.ImageTransparency = 1
                end
            end
        end
    end)
end)

if remoteHub and remoteHub:FindFirstChild("Slam") then
    hookEvent(remoteHub.Slam.OnClientEvent, function(ev)
        if sessionActive and cfg.barLock and typeof(ev) == "Instance" then
            pcall(function() ev:FireServer("Perfect") end)
        end
    end)
end

if remoteHub and remoteHub:FindFirstChild("Charge") then
    hookEvent(remoteHub.Charge.OnClientEvent, function(ev)
        if sessionActive and cfg.barLock and typeof(ev) == "Instance" then
            pcall(function() ev:FireServer(100) end)
        end
    end)
end

hookEvent(UserInputService.JumpRequest, function()
    if cfg.moonJump and sessionActive then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

pcall(function()
    lp.Idled:Connect(function()
        if cfg.idleGuard and sessionActive then
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end
        end
    end)
end)

hookEvent(RunService.RenderStepped, function()
    if not sessionActive then return end

    if cfg.maxBright then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    end

    if cfg.clearFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo and (atmo.Density > 0 or atmo.Haze > 0) then
            atmo.Density = 0; atmo.Haze = 0; atmo.Glare = 0
        end
        for _, d in ipairs(cam:GetDescendants()) do
            if d:IsA("ParticleEmitter") and d.Enabled then d.Enabled = false end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then attachMarker(p.Character, p.DisplayName, "markerPlayers", Color3.fromRGB(255, 255, 255)) end
        end
    end

    if Workspace:FindFirstChild("SecretRod") then
        for _, r in ipairs(Workspace.SecretRod:GetChildren()) do
            attachMarker(r, r.Name, "markerRod", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("NPC") then
        local sp = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
        if sp then attachMarker(sp, "God Spirit", "markerSpirit", Color3.fromRGB(255, 255, 255)) end
    end

    if Workspace:FindFirstChild("Boat") then
        for _, b in ipairs(Workspace.Boat:GetChildren()) do
            attachMarker(b, b.Name, "markerBoat", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("BossSetUp") then
        for _, b in ipairs(Workspace.BossSetUp:GetChildren()) do
            attachMarker(b, b.Name, "markerBoss", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("NPC") then
        for _, n in ipairs(Workspace.NPC:GetChildren()) do
            if n.Name:find("Taoist") or n.Name:find("Grand Angler") then
                attachMarker(n, n.Name, "markerTaoist", Color3.fromRGB(255, 255, 255))
            elseif n.Name:find("Maoshan") then
                attachMarker(n, n.Name, "markerMaoshan", Color3.fromRGB(255, 255, 255))
            end
        end
    end

    local camPos = cam.CFrame.Position
    for inst, data in pairs(trackedMarkers) do
        if not inst.Parent or not data.anchor.Parent then
            detachMarker(inst)
        else
            local enabled = cfg[data.category]
            data.gui.Enabled = enabled and true or false
            if enabled then
                local dist = math.floor((camPos - data.anchor.Position).Magnitude)
                data.text.Text = data.tag .. " [" .. dist .. "m]"
            end
        end
    end

    if cfg.hookRing then
        local fishPos = nil
        local ch = lp.Character
        if ch then
            for _, d in ipairs(ch:GetDescendants()) do
                if (d:IsA("Beam") or d:IsA("RopeConstraint") or d:IsA("SpringConstraint")) and d.Attachment1 then
                    fishPos = d.Attachment1.WorldPosition
                    break
                end
            end
        end
        if not fishPos and Workspace:FindFirstChild("Fishes") then
            local uid = tostring(lp.UserId)
            for _, f in ipairs(Workspace.Fishes:GetChildren()) do
                if f:FindFirstChild(uid .. "_PlayerHealth") then
                    if f:FindFirstChild("Model") and f.Model:IsA("Model") then
                        fishPos = f.Model:GetPivot().Position
                    elseif f:FindFirstChild("Buoy") and f.Buoy:IsA("BasePart") then
                        fishPos = f.Buoy.Position
                    end
                    break
                end
            end
        end

        local pg = lp:FindFirstChild("PlayerGui")
        local isHooked = ch and (ch:GetAttribute("Fishing") == true or ch:GetAttribute("Minigame") == true)
        local fPanel = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
        if (isHooked or (fPanel and fPanel.Visible)) and fishPos then
            ringBase.Position = fishPos
            ringVisual.Visible = true
        else
            ringVisual.Visible = false
        end
    else
        if ringVisual.Visible then ringVisual.Visible = false end
    end
end)

local function shutdownDrift()
    sessionActive = false
    for _, conn in ipairs(eventLinks) do pcall(function() conn:Disconnect() end) end
    table.clear(eventLinks)

    for _, inst in ipairs(managedObjects) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    table.clear(managedObjects)

    pcall(function()
        local leftover = Workspace:FindFirstChild("DriftESP")
        if leftover then leftover:Destroy() end
    end)

    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end)

    if getgenv then getgenv().DriftActiveSession = nil end
end

getgenv().DriftActiveSession = shutdownDrift

Library:OnUnload(function()
    shutdownDrift()
end)

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

local __ContribSrc = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local __Team, __GameContribs = loadstring(__ContribSrc)()

local __DevBox = Tabs["UI Settings"]:AddLeftGroupbox("Team", "wrench")
for __name, __role in pairs(__Team) do
    __DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __role)
end

local __placeId = tostring(game.PlaceId)
if __GameContribs[__placeId] then
    local __ContBox = Tabs["UI Settings"]:AddRightGroupbox("Contributors", "users")
    for __name, __contribution in pairs(__GameContribs[__placeId]) do
        __ContBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __contribution)
    end
end