-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()

-- Services
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global State
local Environment = getgenv()

if DriftActiveSession then
    pcall(DriftActiveSession)
end

local IsSessionActive = true
local EventLinks = {}
local ManagedObjects = {}
local RemoteHub = ReplicatedStorage:WaitForChild("Events", 10)

local function HookEvent(Signal, Handler)
    local Connection = Signal:Connect(Handler)
    table.insert(EventLinks, Connection)
    return Connection
end

local function TrackObject(Object)
    table.insert(ManagedObjects, Object)
    return Object
end

-- Configuration
local DefaultConfiguration = {
    AutoCast = false,
    CastFrequency = 1.0,
    CastIntensity = 100,
    BarLock = true,
    SlamBot = true,
    ChargeBot = true,
    QuickCatch = true,
    SkillBot = false,
    ActiveSkill = "One-Strike Heaven Gate",

    SmartBait = false,
    SmartRod = false,
    SmartOrb = false,
    Preset1Rod = "Wooden Rod",
    Preset1Bait = "Basic Bait",
    Preset2Rod = "Wooden Rod",
    Preset2Bait = "Basic Bait",

    Liquidate = false,
    LiquidateTimer = 30,
    ShieldFish = false,
    ShieldTarget = "Colossal Tigerfish",
    ResourceMode = false,

    RhythmBot = false,
    BossGrind = false,
    SecretBossGrind = false,
    ActiveBoss = "Enzo",

    SpiritScan = false,
    SpiritPray = false,
    HopSpirit = false,
    HopMaoshan = false,
    HopTaoist = false,

    TicketGrind = false,
    TicketTier = "Easy",
    DailyGrab = false,
    DailyPause = 0.5,

    BaitForge = false,
    ForgeTarget = "Nameless Bait",
    ForgeQuantity = 1,
    BaitRestock = false,
    RestockTarget = "Ancestral Bait",
    RestockQuantity = 5,
    RestockFloor = 10,
    RestockPause = 1.0,

    BannerPull = false,
    BannerChoice = "Taiji Banner",
    PullBatch = 1,

    SpeedHack = false,
    SpeedAmount = 16,
    FlightMode = false,
    FlightVelocity = 50,
    MoonJump = false,
    WaterWalk = false,
    PhaseThrough = false,

    MarkerSpirit = false,
    MarkerRod = false,
    MarkerBoat = false,
    MarkerMaoshan = false,
    MarkerTaoist = false,
    MarkerBoss = false,
    MarkerPlayers = false,
    HookRing = true,
    ClearFog = false,
    MaxBright = false,
    LowGfx = false,
    StripUi = false,

    IdleGuard = true,
    Reconnect = false,
}

Environment.DriftCfg = Environment.DriftCfg or DefaultConfiguration
local Configuration = DriftCfg

if hookmetamethod and newcclosure then
    local MinigameRemote = RemoteHub and RemoteHub:FindFirstChild("FishingMinigame")
    local originalCall
    originalCall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local Method = getnamecallmethod()
        if (Self == MinigameRemote or (typeof(Self) == "Instance" and Self.Name == "FishingMinigame")) and Method == "FireServer" and not checkcaller() then
            if IsSessionActive and Configuration and Configuration.BarLock then
                local Args = {...}
                local Action = tostring(Args[1])
                if Action == "Out of bar" or Action == "Out of bar (overpull)" or Action:find("Out of bar") then
                    return originalCall(Self, "In bar", unpack(Args, 2))
                end
            end
        end
        return originalCall(Self, ...)
    end))
end

-- Storage
local StorageDirectory = "Drift/HeavyweightFishing"

local function EnsureStorage()
    if makefolder then
        pcall(function()
            if not isfolder("Drift") then
                makefolder("Drift")
            end
            if not isfolder(StorageDirectory) then
                makefolder(StorageDirectory)
            end
        end)
    end
end

local function PersistConfig(Label)
    EnsureStorage()
    local Filepath = StorageDirectory .. "/" .. (Label or "default") .. ".json"
    local Payload = {}
    for Key, Value in Configuration do
        if typeof(Value) == "EnumItem" then
            Payload[Key] = {__Enum = tostring(Value)}
        else
            Payload[Key] = Value
        end
    end
    local Success, Encoded = pcall(function()
        return HttpService:JSONEncode(Payload)
    end)
    if Success and writefile then
        pcall(function()
            writefile(Filepath, Encoded)
        end)
        return true
    end
    return false
end

local function RestoreConfig(Label)
    local Filepath = StorageDirectory .. "/" .. (Label or "default") .. ".json"
    if readfile then
        local Success, Raw = pcall(function()
            return readfile(Filepath)
        end)
        if Success and Raw and #Raw > 0 then
            local ParseOk, Parsed = pcall(function()
                return HttpService:JSONDecode(Raw)
            end)
            if ParseOk and type(Parsed) == "table" then
                for Key, Value in Parsed do
                    if type(Value) == "table" and Value.__Enum then
                        local EnumGroup, EnumValue = Value.__Enum:match("Enum%.(%w+)%.(%w+)")
                        if EnumGroup and EnumValue and Enum[EnumGroup] and Enum[EnumGroup][EnumValue] then
                            Configuration[Key] = Enum[EnumGroup][EnumValue]
                        end
                    elseif Configuration[Key] ~= nil then
                        Configuration[Key] = Value
                    end
                end
                return true
            end
        end
    end
    return false
end

pcall(RestoreConfig, "default")

-- Rod Catalog
local RodCatalog = {
    {Label = "Wooden Rod", Cost = 0, Strength = 8, Fortune = 1},
    {Label = "Bamboo Rod", Cost = 100, Strength = 11, Fortune = 5},
    {Label = "Iron Hook Rod", Cost = 500, Strength = 13, Fortune = 10},
    {Label = "Steel Rod", Cost = 1000, Strength = 17, Fortune = 11},
    {Label = "Enchanted Steel Rod", Cost = 2000, Strength = 19, Fortune = 12},
    {Label = "Alloy Rod", Cost = 5000, Strength = 22, Fortune = 5},
    {Label = "Emerald Rod", Cost = 10000, Strength = 25, Fortune = 10},
    {Label = "Bloodfire Rod", Cost = 20000, Strength = 27, Fortune = 10},
    {Label = "Shadow Rod", Cost = 60000, Strength = 29, Fortune = 22},
    {Label = "Triple Steel Rod", Cost = 100000, Strength = 32, Fortune = 20},
    {Label = "Golden Rod", Cost = 200000, Strength = 35, Fortune = 22},
    {Label = "Grandmaster Steel Rod", Cost = 250000, Strength = 37, Fortune = 10},
    {Label = "Grandmaster Golden Rod", Cost = 1000000, Strength = 45, Fortune = 30},
    {Label = "Steel Spine Rod", Cost = 1500000, Strength = 48, Fortune = 20},
    {Label = "Inferno Rod", Cost = 1500000, Strength = 48, Fortune = 18},
    {Label = "Golden Spine Rod", Cost = 2000000, Strength = 51, Fortune = 21},
    {Label = "Platinum Spine Rod", Cost = 3000000, Strength = 54, Fortune = 25},
    {Label = "Diamond Spine Rod", Cost = 4000000, Strength = 56, Fortune = 25},
    {Label = "Gravisteel Rod", Cost = 5000000, Strength = 58, Fortune = 15},
    {Label = "Auric Gravity Rod", Cost = 6000000, Strength = 60, Fortune = 10},
    {Label = "Inferno Gravity Rod", Cost = 7000000, Strength = 62, Fortune = 20},
    {Label = "Cryo Gravity Rod", Cost = 8000000, Strength = 65, Fortune = 36},
    {Label = "Thunder Thorn Rod", Cost = 10000000, Strength = 67, Fortune = 30},
    {Label = "Starlight Rod", Cost = 60000000, Strength = 83, Fortune = 15},
}

local RodLabels = {}
for _, Rod in RodCatalog do
    table.insert(RodLabels, Rod.Label)
end
local BaitOptions = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait", "Nameless Bait"}

local ForgeMaterials = {
    ["Mountain Fish"] = true, ["Catfish"] = true, ["Crimson Catfish"] = true,
    ["Scarlet Fish"] = true, ["Elder Scarlet Fish"] = true, ["Octoparasitic Fish"] = true,
    ["Tiger Mirefish"] = true, ["Mirage Lanternfish"] = true, ["Golden Guardian Fish"] = true,
    ["Frost Kingfish"] = true, ["Frost Queenfish"] = true, ["Rainbow Dragonfish"] = true,
    ["Sanguine Fish"] = true,
}

-- Waypoints
local IslandWaypoints = {
    {Label = "Beginning Isle", Coords = Vector3.new(-200.7, 11.1, 35.9)},
    {Label = "Bamboo Isle", Coords = Vector3.new(-1223.0, 7.3, -24.1)},
    {Label = "Fallout Isle", Coords = Vector3.new(65.5, 8.8, 1181.3)},
    {Label = "Sovereign Isle", Coords = Vector3.new(-1276.4, 8.8, 1239.7)},
    {Label = "Perch Isle", Coords = Vector3.new(-62.0, 11.9, -1321.4)},
    {Label = "Frost Isle", Coords = Vector3.new(-1366.0, 11.9, -1495.4)},
    {Label = "Coconut Isle", Coords = Vector3.new(1493.6, 9.1, -1430.6)},
    {Label = "Amber Isle", Coords = Vector3.new(1259.4, 9.1, 1401.5)},
    {Label = "Battlefield Isle", Coords = Vector3.new(1393.5, 11.3, 169.6)},
    {Label = "Mistpeak Isle", Coords = Vector3.new(2660.2, 8.8, -86.7)},
}

local ArenaWaypoints = {
    {Label = "Octoparasite Buoy", Coords = Vector3.new(1608.2, 5.0, -218.3)},
    {Label = "Underground Fisher", Coords = Vector3.new(112.5, -330.0, -30.8)},
    {Label = "Enzo Arena", Coords = Vector3.new(-115.3, 9.2, 1349.5)},
}

local DealerWaypoints = {
    {Label = "Beginning Dealer", Coords = Vector3.new(-151.4, 8.7, -49.9)},
    {Label = "Bamboo Dealer", Coords = Vector3.new(-1236.8, 7.3, -174.1)},
    {Label = "Fallout Dealer", Coords = Vector3.new(138.4, 9.0, 1179.7)},
    {Label = "Sovereign Dealer", Coords = Vector3.new(-1262.6, 8.2, 1202.2)},
    {Label = "Perch Dealer", Coords = Vector3.new(-9.5, 9.2, -1330.0)},
    {Label = "Frost Dealer", Coords = Vector3.new(-1400.4, 9.2, -1490.6)},
    {Label = "Coconut Dealer", Coords = Vector3.new(1446.0, 9.3, -1408.0)},
    {Label = "Amber Dealer", Coords = Vector3.new(1292.7, 8.2, 1497.4)},
}

local HiddenRodWaypoints = {
    {Label = "Anchorbound Rod", Coords = Vector3.new(-1208.5, 56.3, 1646.2)},
    {Label = "Blazeshark Rod", Coords = Vector3.new(-8.4, 53.9, 6.7)},
    {Label = "Kraken Rod", Coords = Vector3.new(1543.8, 73.4, 1490.9)},
    {Label = "Ascendant Bamboo Rod", Coords = Vector3.new(-1360.6, 140.6, 31.0)},
    {Label = "Lifebloom Rod", Coords = Vector3.new(-114.9, 74.9, -1533.2)},
    {Label = "Demonic Rod", Coords = Vector3.new(1181.9, 82.9, -1243.8)},
}

-- Helper Functions
local function GetRoot()
    local Character = LocalPlayer.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function WarpTo(Position)
    local Root = GetRoot()
    if Root then
        Root.CFrame = CFrame.new(Position + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

local function ActivatePrompt(Prompt)
    if fireproximityprompt then
        fireproximityprompt(Prompt)
    else
        pcall(function()
            Prompt:InputHoldBegin()
            task.wait(Prompt.HoldDuration + 0.05)
            Prompt:InputHoldEnd()
        end)
    end
end

local function ServerHop()
    pcall(function()
        local PlaceId = game.PlaceId
        local Endpoint = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local Body = HttpService:JSONDecode(game:HttpGet(Endpoint))
        if Body and Body.data then
            for _, Server in Body.data do
                if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, LocalPlayer)
                    return
                end
            end
        end
    end)
end

local function EquipPreset(RodName, BaitName, PresetLabel)
    local AccountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if not AccountData then
        return
    end
    local RodSlot = AccountData.FishingRodInventory:FindFirstChild(RodName)
    local Owned = RodSlot and RodSlot:FindFirstChild("Owned") and RodSlot.Owned.Value == true
    if Owned then
        if RemoteHub:FindFirstChild("EquipFishingRod") then
            RemoteHub.EquipFishingRod:InvokeServer(RodName)
        end
        Library:Notify({Title = "Drift", Description = "Equipped rod: " .. RodName, Time = 3})
    else
        Library:Notify({Title = "Drift", Description = "You do not own " .. RodName, Time = 3})
    end
    local BaitSlot = AccountData.Bait:FindFirstChild(BaitName)
    if BaitSlot and BaitSlot.Value > 0 then
        if RemoteHub:FindFirstChild("EquipBait") then
            RemoteHub.EquipBait:InvokeServer(BaitName)
        end
        Library:Notify({Title = "Drift", Description = "Equipped bait: " .. BaitName, Time = 3})
    else
        Library:Notify({Title = "Drift", Description = "No " .. BaitName .. " in inventory", Time = 3})
    end
end

Library.ShowToggleFrameInKeybinds = true

-- Window & Tabs
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

-- Fishing
local CoreBox = Tabs.Fishing:AddGroupbox({
    Side = "Left",
    Name = "Reel",
    IconName = "zap",
})

CoreBox:AddToggle("AutoCast", {
    Text = "Auto Cast",
    Default = Configuration.AutoCast,
    Tooltip = "Casts rod automatically",
})

Toggles.AutoCast:OnChanged(function()
    Configuration.AutoCast = Toggles.AutoCast.Value
end)

CoreBox:AddSlider("CastFrequency", {
    Text = "Cast Delay",
    Default = Configuration.CastFrequency,
    Min = 0.5,
    Max = 5.0,
    Rounding = 2,
    Suffix = "s",
})

Options.CastFrequency:OnChanged(function()
    Configuration.CastFrequency = Options.CastFrequency.Value
end)

CoreBox:AddToggle("BarLock", {
    Text = "Anchor Bar",
    Default = Configuration.BarLock,
    Tooltip = "Locks minigame bar center",
})

Toggles.BarLock:OnChanged(function()
    Configuration.BarLock = Toggles.BarLock.Value
end)

CoreBox:AddToggle("SkillBot", {
    Text = "Auto Skills",
    Default = Configuration.SkillBot,
    Tooltip = "Uses skills while reeling",
})

Toggles.SkillBot:OnChanged(function()
    Configuration.SkillBot = Toggles.SkillBot.Value
end)

CoreBox:AddToggle("SlamBot", {
    Text = "Auto Slam",
    Default = Configuration.SlamBot,
    Tooltip = "Clicks slam on prompt",
})

Toggles.SlamBot:OnChanged(function()
    Configuration.SlamBot = Toggles.SlamBot.Value
end)

CoreBox:AddToggle("ChargeBot", {
    Text = "Auto Charge",
    Default = Configuration.ChargeBot,
    Tooltip = "Charges durability automatically",
})

Toggles.ChargeBot:OnChanged(function()
    Configuration.ChargeBot = Toggles.ChargeBot.Value
end)

local EconomyBox = Tabs.Fishing:AddGroupbox({
    Side = "Right",
    Name = "Economy",
    IconName = "coins",
})

EconomyBox:AddToggle("Liquidate", {
    Text = "Auto Sell Fish",
    Default = Configuration.Liquidate,
    Tooltip = "Sells fish periodically",
})

Toggles.Liquidate:OnChanged(function()
    Configuration.Liquidate = Toggles.Liquidate.Value
end)

EconomyBox:AddSlider("LiquidateTimer", {
    Text = "Sell Interval",
    Default = Configuration.LiquidateTimer,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Suffix = "s",
})

Options.LiquidateTimer:OnChanged(function()
    Configuration.LiquidateTimer = Options.LiquidateTimer.Value
end)

EconomyBox:AddButton({
    Text = "Sell Now",
    Func = function()
        local Root = GetRoot()
        if Root then
            Root.CFrame = CFrame.new(-203.5, 7.3, 107.1)
            task.wait(0.3)
            if RemoteHub and RemoteHub:FindFirstChild("SellFish") then
                RemoteHub.SellFish:FireServer("All")
                Library:Notify({Title = "Drift", Description = "Sold all fish to Nana", Time = 3})
            end
        end
    end,
    Tooltip = "Teleports and sells everything",
})

EconomyBox:AddDivider()

EconomyBox:AddToggle("ShieldFish", {
    Text = "Protect Fish",
    Default = Configuration.ShieldFish,
    Tooltip = "Favourites chosen fish type",
})

Toggles.ShieldFish:OnChanged(function()
    Configuration.ShieldFish = Toggles.ShieldFish.Value
end)

local ProtectedFishList = {"Colossal Tigerfish", "Heavenpiercer Turtle", "Golden Guardian Fish", "Crimson Electric Eel", "Frost Kingfish", "Ascended Perch", "Primordial Kunfish Overlord", "Warbringer Shark", "Mountain Fish", "Tiger Mirefish", "Mirage Lanternfish", "Octoparasitic Fish"}

EconomyBox:AddDropdown("ShieldTarget", {
    Values = ProtectedFishList,
    Default = Configuration.ShieldTarget,
    Text = "Protected Fish",
    Tooltip = "Fish to favourite",
})

Options.ShieldTarget:OnChanged(function()
    Configuration.ShieldTarget = Options.ShieldTarget.Value
end)

EconomyBox:AddToggle("ResourceMode", {
    Text = "Material Farming",
    Default = Configuration.ResourceMode,
    Tooltip = "Protects crafting materials",
})

Toggles.ResourceMode:OnChanged(function()
    Configuration.ResourceMode = Toggles.ResourceMode.Value
end)

-- Equipment
local SmartEquipBox = Tabs.Equipment:AddGroupbox({
    Side = "Left",
    Name = "Smart Equip",
    IconName = "sparkles",
})

SmartEquipBox:AddToggle("SmartBait", {
    Text = "Best Bait",
    Default = Configuration.SmartBait,
    Tooltip = "Equips highest luck bait",
})

Toggles.SmartBait:OnChanged(function()
    Configuration.SmartBait = Toggles.SmartBait.Value
end)

SmartEquipBox:AddToggle("SmartRod", {
    Text = "Best Rod",
    Default = Configuration.SmartRod,
    Tooltip = "Equips strongest owned rod",
})

Toggles.SmartRod:OnChanged(function()
    Configuration.SmartRod = Toggles.SmartRod.Value
end)

SmartEquipBox:AddToggle("SmartOrb", {
    Text = "Best Orb",
    Default = Configuration.SmartOrb,
    Tooltip = "Equips top essence orb",
})

Toggles.SmartOrb:OnChanged(function()
    Configuration.SmartOrb = Toggles.SmartOrb.Value
end)

local PresetBox = Tabs.Equipment:AddGroupbox({
    Side = "Right",
    Name = "Loadout Presets",
    IconName = "layers",
})

PresetBox:AddDropdown("Preset1Rod", {
    Values = RodLabels,
    Default = Configuration.Preset1Rod,
    Text = "Preset 1 Rod",
})

Options.Preset1Rod:OnChanged(function()
    Configuration.Preset1Rod = Options.Preset1Rod.Value
end)

PresetBox:AddDropdown("Preset1Bait", {
    Values = BaitOptions,
    Default = Configuration.Preset1Bait,
    Text = "Preset 1 Bait",
})

Options.Preset1Bait:OnChanged(function()
    Configuration.Preset1Bait = Options.Preset1Bait.Value
end)

PresetBox:AddButton({
    Text = "Equip Preset 1",
    Func = function()
        EquipPreset(Configuration.Preset1Rod, Configuration.Preset1Bait, "1")
    end,
})

PresetBox:AddDivider()

PresetBox:AddDropdown("Preset2Rod", {
    Values = RodLabels,
    Default = Configuration.Preset2Rod,
    Text = "Preset 2 Rod",
})

Options.Preset2Rod:OnChanged(function()
    Configuration.Preset2Rod = Options.Preset2Rod.Value
end)

PresetBox:AddDropdown("Preset2Bait", {
    Values = BaitOptions,
    Default = Configuration.Preset2Bait,
    Text = "Preset 2 Bait",
})

Options.Preset2Bait:OnChanged(function()
    Configuration.Preset2Bait = Options.Preset2Bait.Value
end)

PresetBox:AddButton({
    Text = "Equip Preset 2",
    Func = function()
        EquipPreset(Configuration.Preset2Rod, Configuration.Preset2Bait, "2")
    end,
})

-- Bosses
local BossBox = Tabs.Fishing:AddGroupbox({
    Side = "Left",
    Name = "Bosses",
    IconName = "skull",
})

BossBox:AddToggle("RhythmBot", {
    Text = "Octo Rhythm Bot",
    Default = Configuration.RhythmBot,
    Tooltip = "Perfect rhythm timing",
})

Toggles.RhythmBot:OnChanged(function()
    Configuration.RhythmBot = Toggles.RhythmBot.Value
end)

BossBox:AddToggle("BossGrind", {
    Text = "Auto Farm Enzo",
    Default = Configuration.BossGrind,
    Tooltip = "Summons and defeats Enzo",
})

Toggles.BossGrind:OnChanged(function()
    Configuration.BossGrind = Toggles.BossGrind.Value
end)

BossBox:AddToggle("SecretBossGrind", {
    Text = "Auto Secret Boss",
    Default = Configuration.SecretBossGrind,
    Tooltip = "Crafts bait, summons, kills",
})

Toggles.SecretBossGrind:OnChanged(function()
    Configuration.SecretBossGrind = Toggles.SecretBossGrind.Value
end)

BossBox:AddDivider()

BossBox:AddButton({
    Text = "Teleport to Octoparasite",
    Func = function()
        if WarpTo(Vector3.new(1608.2, 5.0, -218.3)) then
            Library:Notify({Title = "Drift", Description = "Arrived at ocean boss buoy", Time = 3})
        end
    end,
})

BossBox:AddButton({
    Text = "Teleport to Enzo",
    Func = function()
        if WarpTo(Vector3.new(-115.3, 9.2, 1349.5)) then
            Library:Notify({Title = "Drift", Description = "Arrived at Enzo arena", Time = 3})
        end
    end,
})

BossBox:AddButton({
    Text = "Teleport to Fisher Realm",
    Func = function()
        if WarpTo(Vector3.new(112.5, -330.0, -30.8)) then
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
        local AccountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if AccountData and AccountData:FindFirstChild("GodSpirit") then
            local IsYellow = AccountData.GodSpirit:FindFirstChild("Yellow") and AccountData.GodSpirit.Yellow.Value or false
            local IsBlue = AccountData.GodSpirit:FindFirstChild("Blue") and AccountData.GodSpirit.Blue.Value or false
            local IsGreen = AccountData.GodSpirit:FindFirstChild("Green") and AccountData.GodSpirit.Green.Value or false
            local Message = string.format("Yellow: %s | Blue: %s | Green: %s", IsYellow and "Active" or "Off", IsBlue and "Active" or "Off", IsGreen and "Active" or "Off")
            Library:Notify({Title = "Drift", Description = Message, Time = 5})
        else
            Library:Notify({Title = "Drift", Description = "Could not read spirit data", Time = 3})
        end
    end,
    Tooltip = "Shows blessing status",
})

SpiritBox:AddToggle("SpiritPray", {
    Text = "Auto Pray",
    Default = Configuration.SpiritPray,
    Tooltip = "Prays at altar nearby",
})

Toggles.SpiritPray:OnChanged(function()
    Configuration.SpiritPray = Toggles.SpiritPray.Value
end)

SpiritBox:AddButton({
    Text = "Teleport to Altar",
    Func = function()
        local Spirit = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
        if Spirit then
            local Root = GetRoot()
            if Root then
                Root.CFrame = Spirit:GetPivot() + Vector3.new(0, 3, 5)
                Library:Notify({Title = "Drift", Description = "Arrived at spirit altar", Time = 3})
            end
        else
            if WarpTo(Vector3.new(1245.7, 19.3, -133.4)) then
                Library:Notify({Title = "Drift", Description = "Warped to shrine location", Time = 3})
            end
        end
    end,
})

SpiritBox:AddButton({
    Text = "Pray Now",
    Func = function()
        local Spirit = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
        if Spirit then
            local WasTriggered = false
            for _, Descendant in Spirit:QueryDescendants("ProximityPrompt") do
                ActivatePrompt(Descendant)
                WasTriggered = true
            end
            if WasTriggered then
                Library:Notify({Title = "Drift", Description = "Prayed at altar", Time = 3})
            else
                Library:Notify({Title = "Drift", Description = "No prompt found", Time = 3})
            end
        else
            Library:Notify({Title = "Drift", Description = "Spirit not spawned here", Time = 3})
        end
    end,
})

SpiritBox:AddDivider()

SpiritBox:AddToggle("HopSpirit", {
    Text = "Hop for Spirit",
    Default = Configuration.HopSpirit,
    Tooltip = "Hops until spirit found",
})

Toggles.HopSpirit:OnChanged(function()
    Configuration.HopSpirit = Toggles.HopSpirit.Value
end)

SpiritBox:AddToggle("HopMaoshan", {
    Text = "Hop for Maoshan",
    Default = Configuration.HopMaoshan,
    Tooltip = "Hops until Maoshan found",
})

Toggles.HopMaoshan:OnChanged(function()
    Configuration.HopMaoshan = Toggles.HopMaoshan.Value
end)

SpiritBox:AddToggle("HopTaoist", {
    Text = "Hop for Taoist",
    Default = Configuration.HopTaoist,
    Tooltip = "Hops until Taoist found",
})

Toggles.HopTaoist:OnChanged(function()
    Configuration.HopTaoist = Toggles.HopTaoist.Value
end)

SpiritBox:AddButton({
    Text = "Server Hop Now",
    Func = function()
        Library:Notify({Title = "Drift", Description = "Searching for a server...", Time = 3})
        ServerHop()
    end,
})

-- World
local QuestBox = Tabs.World:AddGroupbox({
    Side = "Left",
    Name = "Quests & Rewards",
    IconName = "scroll",
})

QuestBox:AddToggle("TicketGrind", {
    Text = "Auto Ticket Quest",
    Default = Configuration.TicketGrind,
    Tooltip = "Accepts and submits quests",
})

Toggles.TicketGrind:OnChanged(function()
    Configuration.TicketGrind = Toggles.TicketGrind.Value
end)

QuestBox:AddDropdown("TicketTier", {
    Values = {"Easy", "Hard"},
    Default = Configuration.TicketTier,
    Text = "Difficulty",
})

Options.TicketTier:OnChanged(function()
    Configuration.TicketTier = Options.TicketTier.Value
end)

QuestBox:AddButton({
    Text = "Submit Easy Quest",
    Func = function()
        if RemoteHub and RemoteHub:FindFirstChild("ClaimQuest") then
            RemoteHub.ClaimQuest:FireServer("Ticket", "Easy")
            Library:Notify({Title = "Drift", Description = "Submitted easy ticket quest", Time = 3})
        end
    end,
})

QuestBox:AddButton({
    Text = "Submit Hard Quest",
    Func = function()
        if RemoteHub and RemoteHub:FindFirstChild("ClaimQuest") then
            RemoteHub.ClaimQuest:FireServer("Ticket", "Hard")
            Library:Notify({Title = "Drift", Description = "Submitted hard ticket quest", Time = 3})
        end
    end,
})

QuestBox:AddDivider()

QuestBox:AddButton({
    Text = "Collect Daily Quests",
    Func = function()
        if RemoteHub and RemoteHub:FindFirstChild("ClaimQuest") then
            for Index = 1, 4 do
                RemoteHub.ClaimQuest:FireServer("Daily", Index)
            end
            Library:Notify({Title = "Drift", Description = "Collected available dailies", Time = 3})
        end
    end,
    Tooltip = "Grabs all daily quests",
})

QuestBox:AddButton({
    Text = "Claim Days 1-7",
    Func = function()
        task.spawn(function()
            if RemoteHub and RemoteHub:FindFirstChild("DailyReward") then
                for Day = 1, 7 do
                    RemoteHub.DailyReward:FireServer(Day)
                    task.wait(Configuration.DailyPause)
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
        local Codes = {"33MVisits", "32MVisits", "31MVisits", "30MVisits", "Taiji", "49KLikes", "48KLikes", "47KLikes", "46KLikes", "13KActives", "HWF", "RELEASE"}
        if RemoteHub and RemoteHub:FindFirstChild("RedeemCode") then
            for _, Code in Codes do
                RemoteHub.RedeemCode:FireServer(Code)
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

ShopBox:AddDropdown("ForgeTarget", {
    Values = {"Nameless Bait", "Frost Bait", "Rainbow Bait"},
    Default = Configuration.ForgeTarget,
    Text = "Craft Target",
})

Options.ForgeTarget:OnChanged(function()
    Configuration.ForgeTarget = Options.ForgeTarget.Value
end)

ShopBox:AddSlider("ForgeQuantity", {
    Text = "Craft Amount",
    Default = Configuration.ForgeQuantity,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

Options.ForgeQuantity:OnChanged(function()
    Configuration.ForgeQuantity = Options.ForgeQuantity.Value
end)

ShopBox:AddToggle("BaitForge", {
    Text = "Auto Craft Bait",
    Default = Configuration.BaitForge,
    Tooltip = "Crafts when ingredients exist",
})

Toggles.BaitForge:OnChanged(function()
    Configuration.BaitForge = Toggles.BaitForge.Value
end)

ShopBox:AddDivider()

ShopBox:AddDropdown("RestockTarget", {
    Values = {"Ancestral Bait", "Elite Bait", "Corrupted Essence Bait", "Crude Mash Bait", "Basic Bait"},
    Default = Configuration.RestockTarget,
    Text = "Buy Target",
})

Options.RestockTarget:OnChanged(function()
    Configuration.RestockTarget = Options.RestockTarget.Value
end)

ShopBox:AddSlider("RestockQuantity", {
    Text = "Buy Amount",
    Default = Configuration.RestockQuantity,
    Min = 1,
    Max = 50,
    Rounding = 0,
})

Options.RestockQuantity:OnChanged(function()
    Configuration.RestockQuantity = Options.RestockQuantity.Value
end)

ShopBox:AddSlider("RestockFloor", {
    Text = "Stock Threshold",
    Default = Configuration.RestockFloor,
    Min = 5,
    Max = 50,
    Rounding = 0,
})

Options.RestockFloor:OnChanged(function()
    Configuration.RestockFloor = Options.RestockFloor.Value
end)

ShopBox:AddToggle("BaitRestock", {
    Text = "Auto Buy Bait",
    Default = Configuration.BaitRestock,
    Tooltip = "Restocks when inventory low",
})

Toggles.BaitRestock:OnChanged(function()
    Configuration.BaitRestock = Toggles.BaitRestock.Value
end)

ShopBox:AddDivider()

ShopBox:AddDropdown("BannerChoice", {
    Values = {"Taiji Banner", "Egoless Banner"},
    Default = Configuration.BannerChoice,
    Text = "Gacha Banner",
})

Options.BannerChoice:OnChanged(function()
    Configuration.BannerChoice = Options.BannerChoice.Value
end)

ShopBox:AddSlider("PullBatch", {
    Text = "Pulls Per Action",
    Default = Configuration.PullBatch,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

Options.PullBatch:OnChanged(function()
    Configuration.PullBatch = Options.PullBatch.Value
end)

ShopBox:AddToggle("BannerPull", {
    Text = "Auto Gacha",
    Default = Configuration.BannerPull,
    Tooltip = "Pulls from selected banner",
})

Toggles.BannerPull:OnChanged(function()
    Configuration.BannerPull = Toggles.BannerPull.Value
end)

local TeleportLeftBox = Tabs.World:AddGroupbox({
    Side = "Left",
    Name = "Island Teleports",
    IconName = "map-pin",
})

for _, Island in IslandWaypoints do
    TeleportLeftBox:AddButton({
        Text = Island.Label,
        Func = function()
            if WarpTo(Island.Coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. Island.Label, Time = 3})
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

for _, Arena in ArenaWaypoints do
    TeleportRightBox:AddButton({
        Text = Arena.Label,
        Func = function()
            if WarpTo(Arena.Coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. Arena.Label, Time = 3})
            end
        end,
    })
end

TeleportRightBox:AddDivider()
TeleportRightBox:AddLabel("Secret Rods")

for _, Rod in HiddenRodWaypoints do
    TeleportRightBox:AddButton({
        Text = Rod.Label,
        Func = function()
            if WarpTo(Rod.Coords) then
                Library:Notify({Title = "Drift", Description = "Arrived at " .. Rod.Label, Time = 3})
            end
        end,
    })
end

TeleportRightBox:AddDivider()

TeleportRightBox:AddButton({
    Text = "Random Player",
    Func = function()
        local Pool = {}
        for _, Player in Players:GetPlayers() do
            if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(Pool, Player)
            end
        end
        if #Pool == 0 then
            Library:Notify({Title = "Drift", Description = "No other players found", Time = 3})
            return
        end
        local Pick = Pool[math.random(1, #Pool)]
        local Root = GetRoot()
        if Root and Pick.Character and Pick.Character:FindFirstChild("HumanoidRootPart") then
            Root.CFrame = Pick.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
            Library:Notify({Title = "Drift", Description = "Teleported to " .. Pick.DisplayName, Time = 3})
        end
    end,
    Tooltip = "Warps to random player",
})

-- Visuals
local MarkerBox = Tabs.Visuals:AddGroupbox({
    Side = "Left",
    Name = "ESP",
    IconName = "eye",
})

MarkerBox:AddToggle("MarkerSpirit", {
    Text = "God Spirit",
    Default = Configuration.MarkerSpirit,
    Tooltip = "Highlights active spirits",
})

Toggles.MarkerSpirit:OnChanged(function()
    Configuration.MarkerSpirit = Toggles.MarkerSpirit.Value
end)

MarkerBox:AddToggle("MarkerRod", {
    Text = "Secret Rods",
    Default = Configuration.MarkerRod,
    Tooltip = "Marks secret rod spawns",
})

Toggles.MarkerRod:OnChanged(function()
    Configuration.MarkerRod = Toggles.MarkerRod.Value
end)

MarkerBox:AddToggle("MarkerBoat", {
    Text = "Boats",
    Default = Configuration.MarkerBoat,
    Tooltip = "Highlights nearby boats",
})

Toggles.MarkerBoat:OnChanged(function()
    Configuration.MarkerBoat = Toggles.MarkerBoat.Value
end)

MarkerBox:AddToggle("MarkerMaoshan", {
    Text = "Maoshan",
    Default = Configuration.MarkerMaoshan,
    Tooltip = "Marks Maoshan NPC",
})

Toggles.MarkerMaoshan:OnChanged(function()
    Configuration.MarkerMaoshan = Toggles.MarkerMaoshan.Value
end)

MarkerBox:AddToggle("MarkerTaoist", {
    Text = "Taoist",
    Default = Configuration.MarkerTaoist,
    Tooltip = "Marks Taoist NPC",
})

Toggles.MarkerTaoist:OnChanged(function()
    Configuration.MarkerTaoist = Toggles.MarkerTaoist.Value
end)

MarkerBox:AddToggle("MarkerBoss", {
    Text = "Bosses",
    Default = Configuration.MarkerBoss,
    Tooltip = "Highlights active bosses",
})

Toggles.MarkerBoss:OnChanged(function()
    Configuration.MarkerBoss = Toggles.MarkerBoss.Value
end)

MarkerBox:AddToggle("MarkerPlayers", {
    Text = "Players",
    Default = Configuration.MarkerPlayers,
    Tooltip = "Shows player markers",
})

Toggles.MarkerPlayers:OnChanged(function()
    Configuration.MarkerPlayers = Toggles.MarkerPlayers.Value
end)

MarkerBox:AddToggle("HookRing", {
    Text = "Fish Target Ring",
    Default = Configuration.HookRing,
    Tooltip = "Red ring on hooked fish",
})

Toggles.HookRing:OnChanged(function()
    Configuration.HookRing = Toggles.HookRing.Value
end)

local RenderBox = Tabs.Visuals:AddGroupbox({
    Side = "Right",
    Name = "Rendering",
    IconName = "monitor",
})

RenderBox:AddToggle("ClearFog", {
    Text = "No Fog",
    Default = Configuration.ClearFog,
    Tooltip = "Removes all fog effects",
})

Toggles.ClearFog:OnChanged(function()
    Configuration.ClearFog = Toggles.ClearFog.Value
    if Configuration.ClearFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local Atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if Atmosphere then
            Atmosphere.Density = 0
            Atmosphere.Haze = 0
            Atmosphere.Glare = 0
        end
        for _, Descendant in Camera:QueryDescendants("ParticleEmitter") do
            Descendant.Enabled = false
        end
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        local Atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if Atmosphere then
            Atmosphere.Density = 0.3
            Atmosphere.Haze = 0.5
        end
    end
end)

RenderBox:AddToggle("MaxBright", {
    Text = "Fullbright",
    Default = Configuration.MaxBright,
    Tooltip = "Maximum ambient lighting",
})

Toggles.MaxBright:OnChanged(function()
    Configuration.MaxBright = Toggles.MaxBright.Value
    if not Configuration.MaxBright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end
end)

RenderBox:AddToggle("LowGfx", {
    Text = "Performance Mode",
    Default = Configuration.LowGfx,
    Tooltip = "Disables shadows and effects",
})

Toggles.LowGfx:OnChanged(function()
    Configuration.LowGfx = Toggles.LowGfx.Value
    Lighting.GlobalShadows = not Configuration.LowGfx
end)

RenderBox:AddToggle("StripUi", {
    Text = "Hide Game UI",
    Default = Configuration.StripUi,
    Tooltip = "Hides default game interface",
})

Toggles.StripUi:OnChanged(function()
    Configuration.StripUi = Toggles.StripUi.Value
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if PlayerGui then
        if PlayerGui:FindFirstChild("MainGui") then
            PlayerGui.MainGui.Enabled = not Configuration.StripUi
        end
        if PlayerGui:FindFirstChild("Fisher_GUI") then
            PlayerGui.Fisher_GUI.Enabled = not Configuration.StripUi
        end
    end
end)

RenderBox:AddDivider()

RenderBox:AddButton({
    Text = "Unlock All Index",
    Func = function()
        local Revealed = 0
        local AccountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if AccountData and AccountData:FindFirstChild("Index") then
            for _, Value in AccountData.Index:QueryDescendants("> BoolValue") do
                Value.Value = true
            end
        end
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui and PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Menu") and PlayerGui.MainGui.Menu:FindFirstChild("Index") then
            local IndexList = PlayerGui.MainGui.Menu.Index:FindFirstChild("IndexFrame") and PlayerGui.MainGui.Menu.Index.IndexFrame:FindFirstChild("Indexlist")
            if IndexList then
                for _, IndexFrame in IndexList:QueryDescendants("> Frame") do
                    Revealed = Revealed + 1
                    local EntryButton = IndexFrame:FindFirstChild("Button")
                    if EntryButton then
                        local NameLabel = EntryButton:FindFirstChild("Title")
                        if NameLabel and NameLabel:IsA("TextLabel") then
                            NameLabel.Text = IndexFrame.Name
                        end
                        local DetailLabel = EntryButton:FindFirstChild("Detail")
                        if DetailLabel then
                            DetailLabel.Visible = true
                            for _, ImageLabel in DetailLabel:QueryDescendants("ImageLabel") do
                                ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
                            end
                        end
                    end
                end
            end
        end
        Library:Notify({Title = "Drift", Description = string.format("Revealed %d fish in index", Revealed > 0 and Revealed or 109), Time = 4})
    end,
    Tooltip = "Shows all fish entries",
})

-- Movement
local MoveBox = Tabs.Movement:AddGroupbox({
    Side = "Left",
    Name = "Movement",
    IconName = "footprints",
})

MoveBox:AddToggle("SpeedHack", {
    Text = "Speed Boost",
    Default = Configuration.SpeedHack,
    Tooltip = "Increases walk speed",
})

Toggles.SpeedHack:OnChanged(function()
    Configuration.SpeedHack = Toggles.SpeedHack.Value
    local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        if Configuration.SpeedHack then
            Humanoid.WalkSpeed = Configuration.SpeedAmount
        else
            Humanoid.WalkSpeed = 16
        end
    end
end)

MoveBox:AddSlider("SpeedAmount", {
    Text = "Speed Value",
    Default = Configuration.SpeedAmount,
    Min = 16,
    Max = 120,
    Rounding = 0,
})

Options.SpeedAmount:OnChanged(function()
    Configuration.SpeedAmount = Options.SpeedAmount.Value
    if Configuration.SpeedHack then
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = Configuration.SpeedAmount
        end
    end
end)

MoveBox:AddToggle("FlightMode", {
    Text = "Fly",
    Default = Configuration.FlightMode,
    Tooltip = "Free flight with WASD",
})

Toggles.FlightMode:OnChanged(function()
    Configuration.FlightMode = Toggles.FlightMode.Value
end)

MoveBox:AddSlider("FlightVelocity", {
    Text = "Fly Speed",
    Default = Configuration.FlightVelocity,
    Min = 20,
    Max = 150,
    Rounding = 0,
})

Options.FlightVelocity:OnChanged(function()
    Configuration.FlightVelocity = Options.FlightVelocity.Value
end)

MoveBox:AddToggle("MoonJump", {
    Text = "Infinite Jump",
    Default = Configuration.MoonJump,
    Tooltip = "Jump infinitely mid-air",
})

Toggles.MoonJump:OnChanged(function()
    Configuration.MoonJump = Toggles.MoonJump.Value
end)

MoveBox:AddToggle("WaterWalk", {
    Text = "Walk on Water",
    Default = Configuration.WaterWalk,
    Tooltip = "Stand on ocean surface",
})

Toggles.WaterWalk:OnChanged(function()
    Configuration.WaterWalk = Toggles.WaterWalk.Value
end)

MoveBox:AddToggle("PhaseThrough", {
    Text = "Noclip",
    Default = Configuration.PhaseThrough,
    Tooltip = "Walk through solid walls",
})

Toggles.PhaseThrough:OnChanged(function()
    Configuration.PhaseThrough = Toggles.PhaseThrough.Value
end)

local StabilityBox = Tabs.Movement:AddGroupbox({
    Side = "Right",
    Name = "Extra",
    IconName = "shield",
})

StabilityBox:AddToggle("IdleGuard", {
    Text = "Anti-AFK",
    Default = Configuration.IdleGuard,
    Tooltip = "Prevents idle disconnect",
})

Toggles.IdleGuard:OnChanged(function()
    Configuration.IdleGuard = Toggles.IdleGuard.Value
end)

StabilityBox:AddToggle("Reconnect", {
    Text = "Auto Rejoin",
    Default = Configuration.Reconnect,
    Tooltip = "Reconnects after kick",
})

Toggles.Reconnect:OnChanged(function()
    Configuration.Reconnect = Toggles.Reconnect.Value
end)

StabilityBox:AddDivider()

StabilityBox:AddButton({
    Text = "Save Config",
    Func = function()
        if PersistConfig() then
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
        if RestoreConfig() then
            Library:Notify({Title = "Drift", Description = "Configuration loaded successfully", Time = 3})
        else
            Library:Notify({Title = "Drift", Description = "No saved configuration found", Time = 3})
        end
    end,
    Tooltip = "Loads saved settings",
})

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddGroupbox({
    Side = "Left",
    Name = "Menu",
    IconName = "wrench",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
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

-- ESP System
local SeaFloor = TrackObject(Instance.new("Part"))
SeaFloor.Name = "DriftSeaFloor"
SeaFloor.Size = Vector3.new(60, 2, 60)
SeaFloor.Anchored = true
SeaFloor.CanCollide = false
SeaFloor.Transparency = 1
SeaFloor.Parent = Workspace

local EspBin = TrackObject(Instance.new("Folder"))
EspBin.Name = "DriftESP"
EspBin.Parent = Workspace

local RingBase = TrackObject(Instance.new("Part"))
RingBase.Name = "DriftRingBase"
RingBase.Size = Vector3.new(0.5, 0.5, 0.5)
RingBase.Transparency = 1
RingBase.CanCollide = false
RingBase.Anchored = true
RingBase.Parent = Workspace

local RingVisual = Instance.new("CylinderHandleAdornment")
RingVisual.Name = "DriftRing"
RingVisual.Adornee = RingBase
RingVisual.AlwaysOnTop = true
RingVisual.ZIndex = 5
RingVisual.Radius = 4.5
RingVisual.InnerRadius = 4.35
RingVisual.Height = 0.05
RingVisual.Color3 = Color3.fromRGB(255, 50, 50)
RingVisual.Transparency = 0.1
RingVisual.CFrame = CFrame.Angles(math.rad(90), 0, 0)
RingVisual.Visible = false
RingVisual.Parent = RingBase

local TrackedMarkers = {}

local function AttachMarker(MarkerTarget, Tag, Category, Tint)
    if not MarkerTarget or TrackedMarkers[MarkerTarget] then
        return
    end
    local Anchor = MarkerTarget:IsA("BasePart") and MarkerTarget or MarkerTarget:FindFirstChildWhichIsA("BasePart")
    if not Anchor then
        return
    end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "Marker_" .. Tag
    Billboard.Size = UDim2.new(0, 200, 0, 20)
    Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = Anchor
    Billboard.Parent = EspBin

    local Text = Instance.new("TextLabel", Billboard)
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.GothamBold
    Text.Text = Tag
    Text.TextColor3 = Tint or Color3.fromRGB(255, 255, 255)
    Text.TextStrokeTransparency = 0
    Text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Text.TextSize = 12

    TrackedMarkers[MarkerTarget] = {Gui = Billboard, Text = Text, Anchor = Anchor, Category = Category, Tag = Tag}
end

local function DetachMarker(MarkerTarget)
    local MarkerData = TrackedMarkers[MarkerTarget]
    if not MarkerData then
        return
    end
    if MarkerData.Gui and MarkerData.Gui.Parent then
        MarkerData.Gui:Destroy()
    end
    TrackedMarkers[MarkerTarget] = nil
end

-- Background Loops
local CastClock = 0
local SellClock = 0
local SkillClock = 0
local GachaClock = 0
local RestockClock = 0
local QuestClock = 0
local PrayClock = 0
local EquipClock = 0
local ProgressClock = 0
local ShieldClock = 0

HookEvent(RunService.Heartbeat, function()
    if not IsSessionActive then
        return
    end
    pcall(function()
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if not Root or not Humanoid then
            return
        end
        local Now = tick()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local AccountData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)

        if Configuration.SpeedHack then
            Humanoid.WalkSpeed = Configuration.SpeedAmount
        end

        if Configuration.WaterWalk then
            SeaFloor.CFrame = CFrame.new(Root.Position.X, 0, Root.Position.Z)
            SeaFloor.CanCollide = (Root.Position.Y >= -1)
        else
            SeaFloor.CanCollide = false
        end

        if Configuration.PhaseThrough then
            for _, Part in Character:QueryDescendants("BasePart") do
                if Part.CanCollide then
                    Part.CanCollide = false
                end
            end
        end

        local IsHooked = Character:GetAttribute("Fishing") == true
        local IsInMinigame = Character:GetAttribute("Minigame") == true or (PlayerGui and PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Fishing") and PlayerGui.MainGui.Fishing.Visible)
        local IsOnCooldown = Character:GetAttribute("CDForTheNextThrow") == true
        local IsSwimming = Character:GetAttribute("Swimming") == true

        if IsInMinigame then
            local FishingPanel = PlayerGui and PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Fishing")
            if FishingPanel and FishingPanel.Visible then
                if Configuration.BarLock then
                    local BarFrame = FishingPanel:FindFirstChild("BarFrame")
                    if BarFrame and BarFrame:FindFirstChild("Bar") then
                        BarFrame.Bar:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                        BarFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end

                if Configuration.SlamBot and FishingPanel:FindFirstChild("PerfectButton") and FishingPanel.PerfectButton.Visible then
                    if RemoteHub:FindFirstChild("Slam") then
                        RemoteHub.Slam:FireServer()
                    end
                end

                if Configuration.ChargeBot and FishingPanel:FindFirstChild("Charge") and FishingPanel.Charge.Visible then
                    if RemoteHub:FindFirstChild("Charge") then
                        RemoteHub.Charge:FireServer()
                    end
                end

                if Configuration.BarLock and (Now - ProgressClock >= 0.08) then
                    if RemoteHub and RemoteHub:FindFirstChild("UpdateFishProgression") then
                        RemoteHub.UpdateFishProgression:FireServer()
                    end
                    ProgressClock = Now
                end

                if Configuration.SkillBot and (Now - SkillClock >= 0.15) then
                    for _, Key in {"Z", "X", "C", "V"} do
                        if RemoteHub:FindFirstChild("UseSkill") then
                            RemoteHub.UseSkill:FireServer(Key)
                        end
                        if RemoteHub:FindFirstChild("TriggerMinigameSkill") then
                            RemoteHub.TriggerMinigameSkill:FireServer(Key)
                        end
                    end
                    SkillClock = Now
                end
            end
        elseif IsHooked then
            CastClock = Now
        else
            if Configuration.AutoCast and not IsOnCooldown and not IsSwimming and (Now - CastClock >= Configuration.CastFrequency) then
                local CanFish = true
                if AccountData and AccountData:FindFirstChild("InventoryLimit") then
                    local InventoryCount = 0
                    if AccountData:FindFirstChild("Inventory") then
                        InventoryCount = InventoryCount + #AccountData.Inventory:QueryDescendants("> Instance")
                    end
                    if AccountData:FindFirstChild("Hotbar") then
                        for _, Item in AccountData.Hotbar:QueryDescendants("> Instance") do
                            if Item:FindFirstChild("Quantity") then
                                InventoryCount = InventoryCount + Item.Quantity.Value
                            else
                                InventoryCount = InventoryCount + 1
                            end
                        end
                    end
                    if InventoryCount >= AccountData.InventoryLimit.Value then
                        CanFish = false
                        if Configuration.Liquidate and (Now - SellClock >= 5.0) and RemoteHub:FindFirstChild("SellFish") then
                            if (Configuration.ResourceMode or Configuration.ShieldFish) and AccountData:FindFirstChild("Inventory") then
                                for _, Item in AccountData.Inventory:QueryDescendants("> Instance") do
                                    local ItemName = Item.Name
                                    local IsFavorite = Item:FindFirstChild("Favorite") and Item.Favorite.Value == true
                                    if not IsFavorite and ((Configuration.ResourceMode and ForgeMaterials[ItemName]) or (Configuration.ShieldFish and ItemName == Configuration.ShieldTarget)) then
                                        if RemoteHub:FindFirstChild("FavoriteItem") then
                                            RemoteHub.FavoriteItem:FireServer(Item)
                                        end
                                    end
                                end
                            end
                            RemoteHub.SellFish:FireServer("All")
                            SellClock = Now
                        end
                    end
                end

                if Configuration.Liquidate and (Now - SellClock >= Configuration.LiquidateTimer) and RemoteHub:FindFirstChild("SellFish") then
                    if (Configuration.ResourceMode or Configuration.ShieldFish) and AccountData and AccountData:FindFirstChild("Inventory") then
                        for _, Item in AccountData.Inventory:QueryDescendants("> Instance") do
                            local ItemName = Item.Name
                            local IsFavorite = Item:FindFirstChild("Favorite") and Item.Favorite.Value == true
                            if not IsFavorite and ((Configuration.ResourceMode and ForgeMaterials[ItemName]) or (Configuration.ShieldFish and ItemName == Configuration.ShieldTarget)) then
                                if RemoteHub:FindFirstChild("FavoriteItem") then
                                    RemoteHub.FavoriteItem:FireServer(Item)
                                end
                            end
                        end
                    end
                    RemoteHub.SellFish:FireServer("All")
                    SellClock = Now
                end

                if (Configuration.ResourceMode or Configuration.ShieldFish) and (Now - ShieldClock >= 1.5) and AccountData and AccountData:FindFirstChild("Inventory") then
                    ShieldClock = Now
                    for _, Item in AccountData.Inventory:QueryDescendants("> Instance") do
                        local ItemName = Item.Name
                        local IsFavorite = Item:FindFirstChild("Favorite") and Item.Favorite.Value == true
                        if not IsFavorite then
                            local ShouldProtect = false
                            if Configuration.ResourceMode and ForgeMaterials[ItemName] then
                                ShouldProtect = true
                            end
                            if Configuration.ShieldFish and ItemName == Configuration.ShieldTarget then
                                ShouldProtect = true
                            end
                            if ShouldProtect and RemoteHub:FindFirstChild("FavoriteItem") then
                                RemoteHub.FavoriteItem:FireServer(Item)
                            end
                        end
                    end
                end

                if CanFish and RemoteHub and RemoteHub:FindFirstChild("Fishing") then
                    RemoteHub.Fishing:FireServer(Root.CFrame)
                    CastClock = Now
                end
            end
        end

        if (Now - EquipClock >= 5.0) and AccountData then
            EquipClock = Now
            if Configuration.SmartBait and AccountData:FindFirstChild("Bait") and AccountData:FindFirstChild("EquippedBait") and RemoteHub:FindFirstChild("EquipBait") then
                local TopBait = nil
                local TopLuck = -1
                local BaitLookup = {
                    ["Ancestral Bait"] = 50, ["Elite Bait"] = 30,
                    ["Corrupted Essence Bait"] = 18, ["Crude Mash Bait"] = 8, ["Basic Bait"] = 3,
                }
                for BaitName, BaitLuck in BaitLookup do
                    local BaitSlot = AccountData.Bait:FindFirstChild(BaitName)
                    if BaitSlot and BaitSlot.Value > 0 and BaitLuck > TopLuck then
                        TopLuck = BaitLuck
                        TopBait = BaitName
                    end
                end
                if TopBait and AccountData.EquippedBait.Value ~= TopBait then
                    RemoteHub.EquipBait:InvokeServer(TopBait)
                end
            end

            if Configuration.SmartRod and AccountData:FindFirstChild("FishingRodInventory") and AccountData:FindFirstChild("FishingRod") and RemoteHub:FindFirstChild("EquipFishingRod") then
                local TopRod = nil
                local TopStrength = -1
                for _, Rod in RodCatalog do
                    local RodSlot = AccountData.FishingRodInventory:FindFirstChild(Rod.Label)
                    local Owned = RodSlot and RodSlot:FindFirstChild("Owned") and RodSlot.Owned.Value == true
                    if Owned and Rod.Strength > TopStrength then
                        TopStrength = Rod.Strength
                        TopRod = Rod.Label
                    end
                end
                if TopRod and AccountData.FishingRod.Value ~= TopRod then
                    RemoteHub.EquipFishingRod:InvokeServer(TopRod)
                end
            end

            if Configuration.SmartOrb and AccountData:FindFirstChild("Orb") and RemoteHub:FindFirstChild("EquipOrb") then
                local Orbs = AccountData.Orb:QueryDescendants("> Instance")
                if #Orbs > 0 then
                    RemoteHub.EquipOrb:InvokeServer(Orbs[#Orbs].Name)
                end
            end
        end

        if Configuration.Liquidate and (Now - SellClock >= Configuration.LiquidateTimer) then
            if RemoteHub and RemoteHub:FindFirstChild("SellFish") then
                RemoteHub.SellFish:FireServer("All")
                SellClock = Now
            end
        end

        if Configuration.SpiritPray and (Now - PrayClock >= 3.0) then
            if Workspace:FindFirstChild("NPC") then
                local Spirit = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
                if Spirit then
                    for _, Descendant in Spirit:QueryDescendants("ProximityPrompt") do
                        ActivatePrompt(Descendant)
                        PrayClock = Now
                    end
                end
            end
        end

        if Configuration.TicketGrind and (Now - QuestClock >= 2.0) then
            if RemoteHub and RemoteHub:FindFirstChild("ClaimQuest") then
                RemoteHub.ClaimQuest:FireServer("Ticket", Configuration.TicketTier)
                QuestClock = Now
            end
        end

        if Configuration.DailyGrab and (Now - CastClock >= 2.0) then
            if RemoteHub and RemoteHub:FindFirstChild("DailyReward") then
                for Day = 1, 7 do
                    RemoteHub.DailyReward:FireServer(Day)
                end
            end
        end

        if Configuration.BannerPull and (Now - GachaClock >= 1.5) then
            if RemoteHub and RemoteHub:FindFirstChild("Gacha") then
                RemoteHub.Gacha:FireServer(Configuration.BannerChoice, Configuration.PullBatch)
                GachaClock = Now
            end
        end

        if Configuration.BaitForge and (Now - CastClock >= 2.0) then
            if RemoteHub and RemoteHub:FindFirstChild("CraftBait") then
                RemoteHub.CraftBait:FireServer(Configuration.ForgeTarget, Configuration.ForgeQuantity)
            end
        end

        if Configuration.BaitRestock and (Now - RestockClock >= Configuration.RestockPause) then
            if RemoteHub and RemoteHub:FindFirstChild("BuyBait") then
                RemoteHub.BuyBait:FireServer(Configuration.RestockTarget, Configuration.RestockQuantity)
                RestockClock = Now
            end
        end

        if Configuration.RhythmBot then
            if RemoteHub and RemoteHub:FindFirstChild("RhythmHit") then
                RemoteHub.RhythmHit:FireServer(true, 100)
            end
        end
    end)
end)

-- Flight Loop
local VelocityBody, GyroBody = nil, nil

HookEvent(RunService.RenderStepped, function()
    if not IsSessionActive then
        return
    end
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then
        return
    end

    if Configuration.FlightMode then
        if not VelocityBody then
            VelocityBody = TrackObject(Instance.new("BodyVelocity"))
            VelocityBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            VelocityBody.Parent = Root

            GyroBody = TrackObject(Instance.new("BodyGyro"))
            GyroBody.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            GyroBody.Parent = Root
        end

        local CameraCFrame = Camera.CFrame
        local Direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            Direction = Direction + CameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Direction = Direction - CameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            Direction = Direction + CameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Direction = Direction - CameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Direction = Direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            Direction = Direction - Vector3.new(0, 1, 0)
        end

        GyroBody.CFrame = CameraCFrame
        VelocityBody.Velocity = Direction.Magnitude > 0 and Direction.Unit * Configuration.FlightVelocity or Vector3.zero
    else
        if VelocityBody then
            VelocityBody:Destroy()
            VelocityBody = nil
        end
        if GyroBody then
            GyroBody:Destroy()
            GyroBody = nil
        end
    end
end)

-- Bar Lock Loop
HookEvent(RunService.RenderStepped, function()
    if not IsSessionActive then
        return
    end
    pcall(function()
        if Configuration.BarLock then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui and PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Fishing") and PlayerGui.MainGui.Fishing.Visible then
                local FishingPanel = PlayerGui.MainGui.Fishing
                local BarFrame = FishingPanel:FindFirstChild("BarFrame")
                if BarFrame and BarFrame:FindFirstChild("Bar") then
                    BarFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                end
                local BossBar = FishingPanel:FindFirstChild("BossFightBar")
                if BossBar and BossBar.Visible and BossBar:FindFirstChild("Bar") and BossBar:FindFirstChild("Hitbox") then
                    BossBar.Bar.Position = BossBar.Hitbox.Position
                end
                local HPPlayer = FishingPanel:FindFirstChild("HPPlayer")
                if HPPlayer and HPPlayer:FindFirstChild("ProgressionBar") then
                    local ProgressionBar = HPPlayer.ProgressionBar
                    if ProgressionBar:FindFirstChild("Bar") then
                        ProgressionBar.Bar.Size = UDim2.new(1, 0, 1, 0)
                    end
                end
                if FishingPanel:FindFirstChild("PerfectButton") and FishingPanel.PerfectButton.Visible then
                    if RemoteHub and RemoteHub:FindFirstChild("Slam") then
                        RemoteHub.Slam:FireServer("Perfect")
                    end
                end
                if FishingPanel:FindFirstChild("Charge") and FishingPanel.Charge.Visible then
                    if RemoteHub and RemoteHub:FindFirstChild("Charge") then
                        RemoteHub.Charge:FireServer(100)
                    end
                end
                local Cutscene = PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Cutscene")
                if Cutscene and Cutscene:FindFirstChild("Hurt") then
                    Cutscene.Hurt.ImageTransparency = 1
                end
                local ImpactCutscene = PlayerGui:FindFirstChild("Impact") and PlayerGui.Impact:FindFirstChild("Cutscene")
                if ImpactCutscene and ImpactCutscene:FindFirstChild("Hurt") then
                    ImpactCutscene.Hurt.ImageTransparency = 1
                end
            end
        end
    end)
end)

if RemoteHub and RemoteHub:FindFirstChild("Slam") then
    HookEvent(RemoteHub.Slam.OnClientEvent, function(Event)
        if IsSessionActive and Configuration.BarLock and typeof(Event) == "Instance" then
            pcall(function()
                Event:FireServer("Perfect")
            end)
        end
    end)
end

if RemoteHub and RemoteHub:FindFirstChild("Charge") then
    HookEvent(RemoteHub.Charge.OnClientEvent, function(Event)
        if IsSessionActive and Configuration.BarLock and typeof(Event) == "Instance" then
            pcall(function()
                Event:FireServer(100)
            end)
        end
    end)
end

HookEvent(UserInputService.JumpRequest, function()
    if Configuration.MoonJump and IsSessionActive then
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Configuration.IdleGuard and IsSessionActive then
            local VirtualUser = game:GetService("VirtualUser")
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end
    end)
end)

-- Visual Loop
HookEvent(RunService.RenderStepped, function()
    if not IsSessionActive then
        return
    end

    if Configuration.MaxBright then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    end

    if Configuration.ClearFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local Atmosphere = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if Atmosphere and (Atmosphere.Density > 0 or Atmosphere.Haze > 0) then
            Atmosphere.Density = 0
            Atmosphere.Haze = 0
            Atmosphere.Glare = 0
        end
        for _, Descendant in Camera:QueryDescendants("ParticleEmitter") do
            if Descendant.Enabled then
                Descendant.Enabled = false
            end
        end
    end

    for _, Player in Players:GetPlayers() do
        if Player ~= LocalPlayer and Player.Character then
            local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if RootPart then
                AttachMarker(Player.Character, Player.DisplayName, "MarkerPlayers", Color3.fromRGB(255, 255, 255))
            end
        end
    end

    if Workspace:FindFirstChild("SecretRod") then
        for _, Rod in Workspace.SecretRod:QueryDescendants("> Instance") do
            AttachMarker(Rod, Rod.Name, "MarkerRod", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("NPC") then
        local Spirit = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
        if Spirit then
            AttachMarker(Spirit, "God Spirit", "MarkerSpirit", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("Boat") then
        for _, Boat in Workspace.Boat:QueryDescendants("> Instance") do
            AttachMarker(Boat, Boat.Name, "MarkerBoat", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("BossSetUp") then
        for _, Boss in Workspace.BossSetUp:QueryDescendants("> Instance") do
            AttachMarker(Boss, Boss.Name, "MarkerBoss", Color3.fromRGB(255, 255, 255))
        end
    end

    if Workspace:FindFirstChild("NPC") then
        for _, NPC in Workspace.NPC:QueryDescendants("> Instance") do
            if NPC.Name:find("Taoist") or NPC.Name:find("Grand Angler") then
                AttachMarker(NPC, NPC.Name, "MarkerTaoist", Color3.fromRGB(255, 255, 255))
            elseif NPC.Name:find("Maoshan") then
                AttachMarker(NPC, NPC.Name, "MarkerMaoshan", Color3.fromRGB(255, 255, 255))
            end
        end
    end

    local CameraPosition = Camera.CFrame.Position
    for MarkerTarget, MarkerData in TrackedMarkers do
        if not MarkerTarget.Parent or not MarkerData.Anchor.Parent then
            DetachMarker(MarkerTarget)
        else
            local Enabled = Configuration[MarkerData.Category]
            MarkerData.Gui.Enabled = Enabled and true or false
            if Enabled then
                local Distance = math.floor((CameraPosition - MarkerData.Anchor.Position).Magnitude)
                MarkerData.Text.Text = MarkerData.Tag .. " [" .. Distance .. "m]"
            end
        end
    end

    if Configuration.HookRing then
        local FishPosition = nil
        local Character = LocalPlayer.Character
        if Character then
            for _, Descendant in Character:QueryDescendants("Beam, RopeConstraint, SpringConstraint") do
                if Descendant.Attachment1 then
                    FishPosition = Descendant.Attachment1.WorldPosition
                    break
                end
            end
        end
        if not FishPosition and Workspace:FindFirstChild("Fishes") then
            local UserId = tostring(LocalPlayer.UserId)
            for _, Fish in Workspace.Fishes:QueryDescendants("> Instance") do
                if Fish:FindFirstChild(UserId .. "_PlayerHealth") then
                    if Fish:FindFirstChild("Model") and Fish.Model:IsA("Model") then
                        FishPosition = Fish.Model:GetPivot().Position
                    elseif Fish:FindFirstChild("Buoy") and Fish.Buoy:IsA("BasePart") then
                        FishPosition = Fish.Buoy.Position
                    end
                    break
                end
            end
        end

        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local IsHooked = Character and (Character:GetAttribute("Fishing") == true or Character:GetAttribute("Minigame") == true)
        local FishingPanel = PlayerGui and PlayerGui:FindFirstChild("MainGui") and PlayerGui.MainGui:FindFirstChild("Fishing")
        if (IsHooked or (FishingPanel and FishingPanel.Visible)) and FishPosition then
            RingBase.Position = FishPosition
            RingVisual.Visible = true
        else
            RingVisual.Visible = false
        end
    else
        if RingVisual.Visible then
            RingVisual.Visible = false
        end
    end
end)

-- Cleanup
local function ShutdownDrift()
    IsSessionActive = false
    for _, Connection in EventLinks do
        pcall(function()
            Connection:Disconnect()
        end)
    end
    table.clear(EventLinks)

    for _, TrackedObject in ManagedObjects do
        pcall(function()
            if TrackedObject and TrackedObject.Parent then
                TrackedObject:Destroy()
            end
        end)
    end
    table.clear(ManagedObjects)

    pcall(function()
        local Leftover = Workspace:FindFirstChild("DriftESP")
        if Leftover then
            Leftover:Destroy()
        end
    end)

    pcall(function()
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = 16
        end
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end)

    if getgenv then
        Environment.DriftActiveSession = nil
    end
end

Environment.DriftActiveSession = ShutdownDrift

Library:OnUnload(function()
    ShutdownDrift()
end)

-- Loaded Notification
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

-- Credits
local ContributorsSource = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local TeamMembers, GameContributors = loadstring(ContributorsSource)()

local TeamGroup = Tabs["UI Settings"]:AddLeftGroupbox("Team", "wrench")
for MemberName, MemberRole in TeamMembers do
    TeamGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. MemberName .. "</font>] " .. MemberRole)
end

local PlaceId = tostring(game.PlaceId)
if GameContributors[PlaceId] then
    local ContributorsGroup = Tabs["UI Settings"]:AddRightGroupbox("Contributors", "users")
    for MemberName, Contribution in GameContributors[PlaceId] do
        ContributorsGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. MemberName .. "</font>] " .. Contribution)
    end
end