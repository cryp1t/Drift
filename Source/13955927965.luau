-- References
local FilterGC = filtergc
local GetRawMetatable = getrawmetatable
local HookMetamethod = hookmetamethod
local HookFunction = hookfunction
local NewCClosure = newcclosure
local GetNamecallMethod = getnamecallmethod
local SetNamecallMethod = setnamecallmethod
local IsExecutorClosure = isexecutorclosure
local GetGenv = getgenv

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Modules = ReplicatedStorage:FindFirstChild("Modules")
local LocalData = require(Modules:FindFirstChild("LocalData", true))
local RefreshCharacter = FilterGC("function", {
    Name = "Refresh",
}, true)

local Accessories
local DataChangeRequest = ReplicatedStorage:FindFirstChild("Remotes")
    and ReplicatedStorage.Remotes:FindFirstChild("Requests")
    and ReplicatedStorage.Remotes.Requests:FindFirstChild("DataChangeRequest")

LocalPlayer:AddTag("ANTICHEAT_IMMUNE")

-- Helpers
local GetDataSlot = function(Slot)
    return LocalData.DataSlot.CharacterInfo[Slot]
end

local GetFolder = function(Name)
    if not Accessories then
        return
    end

    return Accessories:FindFirstChild(Name)
end

local GetItemNames = function(Folder, IncludeNone)
    local Names = {}

    if Folder then
        for _, Item in Folder:GetChildren() do
            table.insert(Names, Item.Name)
        end
    end

    if IncludeNone then
        table.insert(Names, 1, "None")
    end

    return Names
end

local SetDropdownValues = function(Dropdown, Values)
    if not Dropdown then
        return
    end

    Dropdown:SetValues(Values)
end

local ToItemLabel = function(Value)
    if Value == "" or Value == nil then
        return "None"
    end

    return Value
end

local FromItemLabel = function(Value)
    if Value == "None" then
        return ""
    end

    return Value
end

-- UI Setup
local Contributors, Team = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
Contributors = loadstring(Contributors)
Team, Contributors = Contributors()

local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main"
local ThemeManager = loadstring(game:HttpGet(`{Repository}/addons/ThemeManager.lua`))()
local SaveManager = loadstring(game:HttpGet(`{Repository}/addons/SaveManager.lua`))()
local Library = loadstring(game:HttpGet(`{Repository}/Library.lua`))()

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Drift")
ThemeManager:SetDefaultTheme({
    FontColor = "ffffff",
    MainColor = "0e0e0e",
    AccentColor = "888888",
    OutlineColor = "1e1e1e",
    BackgroundColor = "0a0a0a",
})

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("Drift/Blood Zone")
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:LoadAutoloadConfig()

local Window = Library:CreateWindow({
    AutoShow = true,
    Title = "Drift",
    Icon = 106251220512678,
    SidebarCompacted = false,
    TabTransitionTime = 0.65,
    Animations = { TabSwitch = true },
    Footer = "Blood Zone | discord.gg/X4XKv5p2Gj",
})

local Tabs = {
    Main = Window:AddTab("Main", "crosshair"),
    SkinChanger = Window:AddTab("Skin Changer", "shirt"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Settings = Window:AddTab("Settings", "settings"),
}

local Groups = {
    SilentAim = Tabs.Main:AddLeftGroupbox("Silent Aim", "crosshair"),
    AutoShoot = Tabs.Main:AddRightGroupbox("Auto Shoot", "target"),
    Mods = Tabs.Main:AddRightGroupbox("Mods", "hammer"),
    Lighting = Tabs.Visuals:AddRightGroupbox("Lighting", "sun"),
    LightingEffects = Tabs.Visuals:AddRightGroupbox("Lighting Effects", "star"),
    ESP = Tabs.Visuals:AddLeftGroupbox("Player ESP", "eye"),
    Chams = Tabs.Visuals:AddLeftGroupbox("Chams", "sparkles"),
    WeaponSkins = Tabs.SkinChanger:AddLeftGroupbox("Skin Changer", "shirt"),
    HeadCosmetics = Tabs.SkinChanger:AddLeftGroupbox("Head Cosmetics", "shirt"),
    Apparel = Tabs.SkinChanger:AddLeftGroupbox("Apparel", "shirt"),
    BackAccessories = Tabs.SkinChanger:AddLeftGroupbox("Back Accessories", "backpack"),
    Spoofers = Tabs.SkinChanger:AddRightGroupbox("Spoofers", "user"),
}

local CreditsGroup = Tabs.Settings:AddLeftGroupbox("Team", "wrench")

for Name, Role in Team do
    CreditsGroup:AddLabel(`[<font color="rgb(255, 255, 100)">{Name}</font>] {Role}`)
end

Contributors = Contributors[game.PlaceId]

if Contributors then
    CreditsGroup:AddLabel("")
    CreditsGroup:AddLabel("Contributors")

    for Name, Contribution in Contributors do
        CreditsGroup:AddLabel(`[<font color="rgb(100, 250, 250)">{Name}</font>] {Contribution}`)
    end
end

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager.Library.Options.FontFace:SetValue("BuilderSans")

-- Character Changer
local CharUtility = require(Modules:FindFirstChild("CharUtility", true))

local Faces = {}
local HeadItems = {}
local BackItems = {}
local ShirtItems = {}
local PantsItems = {}

local HeadSlots = { "Head", "Head2", "Head3" }
local ItemDropdowns = {}

local GetCurrentFace = function()
    return GetDataSlot("Face")
end

local ApplyFace = function(Head, FaceName)
    local FaceFolder = GetFolder("Face")
    local TargetFace = FaceFolder and FaceFolder:FindFirstChild(FaceName)

    if not Head or not TargetFace then
        return
    end

    local Found = false

    for _, Existing in Head:GetChildren() do
        if Existing:IsA("Decal") then
            if Existing.Texture == TargetFace.Texture then
                Found = true
            else
                Existing:Destroy()
            end
        end
    end

    if not Found then
        TargetFace:Clone().Parent = Head
    end
end

local ApplyAccessory = function(Character, Folder, Slot, ItemName)
    if not Character or not Folder then
        return
    end

    for _, Existing in Character:GetChildren() do
        if Existing:IsA("Accessory") and Existing:GetAttribute("DriftFake") == Slot then
            Existing:Destroy()
        end
    end

    if type(ItemName) ~= "string" or ItemName == "" then
        return
    end

    local Item = Folder:FindFirstChild(ItemName)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Item or not Humanoid then
        return
    end

    for _, Existing in Character:GetChildren() do
        if Existing:IsA("Accessory") and Existing.Name == ItemName then
            return
        end
    end

    local Clone = Item:Clone()
    Clone:SetAttribute("DriftFake", Slot)
    Clone.Parent = Character

    CharUtility.WeldAccessories(Character, Clone)
end

local ApplyApparel = function(Character, Kind, ItemName)
    if not Character then
        return
    end

    for _, Existing in Character:GetChildren() do
        if Existing:GetAttribute("DriftFake") == Kind then
            Existing:Destroy()
        end
    end

    if type(ItemName) ~= "string" or ItemName == "" then
        return
    end

    local Folder = GetFolder(Kind == "Shirt" and "Shirt" or "Pants")

    if not Folder then
        return
    end

    local Item = Folder:FindFirstChild(ItemName)

    if not Item then
        return
    end

    for _, Existing in Character:GetChildren() do
        if Existing.ClassName == Item.ClassName and Existing.Name == ItemName then
            return
        end
    end

    local Clone = Item:Clone()
    Clone:SetAttribute("DriftFake", Kind)
    Clone.Parent = Character
end

local ApplyCosmetics = function(Character)
    if not Character or not Character.Parent then
        return
    end

    local Head = Character:FindFirstChild("Head")
    local HeadFolder = GetFolder("Head")
    local BackFolder = GetFolder("Back")

    if Head and HeadFolder then
        ApplyFace(Head, GetCurrentFace())
    end

    for _, Slot in HeadSlots do
        ApplyAccessory(Character, HeadFolder, Slot, GetDataSlot(Slot))
    end

    ApplyAccessory(Character, BackFolder, "Back", GetDataSlot("Back"))
    ApplyApparel(Character, "Shirt", GetDataSlot("Shirt"))
    ApplyApparel(Character, "Pants", GetDataSlot("Pants"))
end

local RefreshItemLists = function()
    if not Accessories then
        return
    end

    Faces = GetItemNames(GetFolder("Face"))
    HeadItems = GetItemNames(GetFolder("Head"), true)
    BackItems = GetItemNames(GetFolder("Back"), true)
    ShirtItems = GetItemNames(GetFolder("Shirt"), true)
    PantsItems = GetItemNames(GetFolder("Pants"), true)

    SetDropdownValues(ItemDropdowns.Face, Faces)

    for _, Slot in HeadSlots do
        SetDropdownValues(ItemDropdowns[Slot], HeadItems)
    end

    SetDropdownValues(ItemDropdowns.Back, BackItems)

    for _, Kind in { "Shirt", "Pants" } do
        SetDropdownValues(ItemDropdowns[Kind], Kind == "Shirt" and ShirtItems or PantsItems)
    end
end

RefreshItemLists()

local UpdateAppearance = function()
    RefreshItemLists()
    ApplyCosmetics(LocalPlayer.Character)

    local FaceDropdown = ItemDropdowns.Face

    if FaceDropdown then
        local FaceName = GetCurrentFace()

        if FaceDropdown.Value ~= FaceName then
            FaceDropdown:SetValue(FaceName)
        end
    end

    for _, Slot in HeadSlots do
        local Dropdown = ItemDropdowns[Slot]

        if Dropdown then
            local Current = ToItemLabel(GetDataSlot(Slot))

            if Dropdown.Value ~= Current then
                Dropdown:SetValue(Current)
            end
        end
    end

    local BackDropdown = ItemDropdowns.Back

    if BackDropdown then
        local Current = ToItemLabel(GetDataSlot("Back"))

        if BackDropdown.Value ~= Current then
            BackDropdown:SetValue(Current)
        end
    end

    for _, Kind in { "Shirt", "Pants" } do
        local Dropdown = ItemDropdowns[Kind]

        if Dropdown then
            local Current = ToItemLabel(GetDataSlot(Kind))

            if Dropdown.Value ~= Current then
                Dropdown:SetValue(Current)
            end
        end
    end
end

ItemDropdowns.Face = Groups.HeadCosmetics:AddDropdown("FakeFace", {
    Values = Faces,
    Default = GetCurrentFace(),

    Text = "Faces",

    Callback = function(Value)
        if typeof(Value) ~= "string" then
            return
        end

        LocalData.DataSlot.CharacterInfo.Face = Value
        UpdateAppearance()
        RefreshCharacter()
    end,
})

for _, Slot in HeadSlots do
    ItemDropdowns[Slot] = Groups.HeadCosmetics:AddDropdown("Fake" .. Slot, {
        Values = HeadItems,
        Default = ToItemLabel(GetDataSlot(Slot)),

        Text = Slot,

        Callback = function(Value)
            if typeof(Value) ~= "string" then
                return
            end

            LocalData.DataSlot.CharacterInfo[Slot] = FromItemLabel(Value)
            UpdateAppearance()
            RefreshCharacter()
        end,
    })
end

for _, Kind in { "Shirt", "Pants" } do
    ItemDropdowns[Kind] = Groups.Apparel:AddDropdown("Fake" .. Kind, {
        Values = Kind == "Shirt" and ShirtItems or PantsItems,
        Default = ToItemLabel(GetDataSlot(Kind)),

        Text = Kind,

        Callback = function(Value)
            if typeof(Value) ~= "string" then
                return
            end

            LocalData.DataSlot.CharacterInfo[Kind] = FromItemLabel(Value)
            UpdateAppearance()
            RefreshCharacter()
        end,
    })
end

ItemDropdowns.Back = Groups.BackAccessories:AddDropdown("FakeBack", {
    Values = BackItems,
    Default = ToItemLabel(GetDataSlot("Back")),

    Text = "Back",

    Callback = function(Value)
        if typeof(Value) ~= "string" then
            return
        end

        LocalData.DataSlot.CharacterInfo.Back = FromItemLabel(Value)
        UpdateAppearance()
        RefreshCharacter()
    end,
})

-- Weapon Skins
local SkinModule = require(Modules:FindFirstChild("Data", true):FindFirstChild("SkinData"))
local ItemSkinsFolder = ReplicatedStorage:FindFirstChild("ItemSkins")

local SkinNames = { "None" }

if SkinModule.all then
    local Sorted = {}

    for Name in SkinModule.all do
        table.insert(Sorted, Name)
    end

    table.sort(Sorted)

    for _, Name in Sorted do
        table.insert(SkinNames, Name)
    end
end

local SkinChangerSettings = {
    Equipped = {},
}

local OriginalSkinProperties = {}

local GetPartKey = function(Part)
    return Part:GetFullName()
end

local CacheOriginalProperties = function(Part)
    local Key = GetPartKey(Part)

    if OriginalSkinProperties[Key] then
        return
    end

    OriginalSkinProperties[Key] = {
        Material = Part.Material,
        Color = Part.Color,
        Reflectance = Part.Reflectance,
        Transparency = Part.Transparency,
        TextureID = Part:IsA("MeshPart") and Part.TextureID or "",
    }
end

local RestoreOriginalProperties = function(Part)
    local Key = GetPartKey(Part)
    local Original = OriginalSkinProperties[Key]

    if not Original then
        return
    end

    Part.Material = Original.Material
    Part.Color = Original.Color
    Part.Reflectance = Original.Reflectance
    Part.Transparency = Original.Transparency

    if Part:IsA("MeshPart") then
        Part.TextureID = Original.TextureID
    end
end

local StripSkinFromPart = function(Part)
    for _, Child in Part:GetChildren() do
        if Child:HasTag("SkinInstance") then
            Child:Destroy()
        end
    end

    RestoreOriginalProperties(Part)
    Part:SetAttribute("SkinSpeed", nil)
    Part:RemoveTag("SkinLoaded")
end

local RemoveToolSkin = function(Tool)
    if not Tool or not Tool:IsA("Tool") then
        return
    end

    for _, Part in Tool:GetDescendants() do
        if Part:IsA("BasePart") and Part:HasTag("SkinLoaded") then
            StripSkinFromPart(Part)
        end
    end
end

local ApplyToolSkin = function(Tool, SkinName)
    if not Tool or not Tool:IsA("Tool") then
        return
    end

    if type(SkinName) ~= "string" or SkinName == "" or SkinName == "None" then
        RemoveToolSkin(Tool)
        return
    end

    local SkinFolder = ItemSkinsFolder and ItemSkinsFolder:FindFirstChild(SkinName, true)

    if not SkinFolder then
        return
    end

    for _, Part in Tool:GetDescendants() do
        if not Part:IsA("BasePart") then
            continue
        end

        CacheOriginalProperties(Part)

        for _, SkinPart in SkinFolder:GetChildren() do
            if not Part:HasTag(SkinPart.Name) then
                continue
            end

            for _, Existing in Part:GetChildren() do
                if Existing:HasTag("SkinInstance") then
                    Existing:Destroy()
                end
            end

            Part.Material = SkinPart.Material
            Part.Color = SkinPart.Color
            Part.Reflectance = SkinPart.Reflectance
            Part.Transparency = SkinPart.Transparency
            Part:SetAttribute("SkinSpeed", SkinPart:GetAttribute("SkinSpeed"))
            Part:AddTag("SkinLoaded")

            if Part:IsA("MeshPart") then
                Part.TextureID = ""
            end

            for _, Child in SkinPart:GetChildren() do
                local Clone = Child:Clone()
                Clone.Parent = Part
                Clone:AddTag("SkinInstance")
            end
        end
    end
end

local GetToolCategory = function(ToolName)
    local Loadout = LocalData.DataSlot.Loadout

    if not Loadout then
        return
    end

    for _, Category in { "Primary", "Secondary", "Melee" } do
        if tostring(Loadout[Category]) == ToolName then
            return Category
        end
    end
end

local ForEachTool = function(Action)
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer.Backpack

    if Character then
        for _, Tool in Character:QueryDescendants(">Tool") do
            Action(Tool)
        end
    end

    if Backpack then
        for _, Tool in Character:QueryDescendants(">Tool") do
            Action(Tool)
        end
    end
end

local ApplyEquippedToolSkins = function()
    ForEachTool(function(Tool)
        local Category = GetToolCategory(Tool.Name)

        if Category and SkinChangerSettings.Equipped[Category] then
            ApplyToolSkin(Tool, SkinChangerSettings.Equipped[Category])
        end
    end)
end

local EquipSkin = function(Category, SkinName)
    SkinChangerSettings.Equipped[Category] = SkinName
    LocalData.Data.SkinData.EquippedSkins[Category] = SkinName

    ForEachTool(function(Tool)
        local ToolCategory = GetToolCategory(Tool.Name)

        if ToolCategory == Category then
            ApplyToolSkin(Tool, SkinName)
        end
    end)
end

for _, Category in { "Primary", "Secondary", "Melee" } do
    local Equipped = LocalData.Data.SkinData.EquippedSkins[Category] or "None"

    Groups.WeaponSkins:AddDropdown("Skin" .. Category, {
        Values = SkinNames,
        Default = Equipped == "Default" and "None" or Equipped,
        Text = Category .. " Weapon",

        Callback = function(Value)
            if typeof(Value) ~= "string" then
                return
            end

            EquipSkin(Category, Value)
        end,
    })
end

ApplyEquippedToolSkins()

LocalPlayer.CharacterAdded:Connect(function(Character)
    ApplyEquippedToolSkins()

    Character.ChildAdded:Connect(function(Child)
        if Child:IsA("Tool") then
            ApplyEquippedToolSkins()
        end
    end)
end)

LocalPlayer.Backpack.ChildAdded:Connect(function(Child)
    if Child:IsA("Tool") then
        ApplyEquippedToolSkins()
    end
end)

-- Silent Aim
local SilentAimSettings = {
    Enabled = false,
    Method = "Raycast",
    HitChance = 100,
    HeadshotChance = 0,
    HitPart = "Head",
    EmulateSpread = false,
    OriginMethod = "Camera",

    VisibleCheck = false,

    FOV = 150,
    FOVCircle = false,
    FOVCircleColor = Color3.fromRGB(255, 255, 255),

    Snaplines = false,
    SnaplineColor = Color3.fromRGB(255, 255, 255),

    Manipulation = false,
    Origin = Vector3.new(0, 5, 0),
}

local AutoShootSettings = {
    Enabled = false,
    Method = "Game Function",
    Delay = 100,
    Variation = 0,
    ShootThroughWindows = false,
}

local HitParts = { "Head", "Torso", "HumanoidRootPart", "Random", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
local RandomHitParts = { "Head", "Torso", "HumanoidRootPart", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }
local SilentAimRandom = Random.new()

local ClientFolder = Modules:FindFirstChild("Client", true)
local GameFolder = ClientFolder and ClientFolder:FindFirstChild("Game")
local WeaponClient = GameFolder and require(GameFolder:FindFirstChild("WeaponClient"))

local GetEquippedGun = function()
    if not WeaponClient or not WeaponClient.LoadedWeapons then
        return
    end

    for _, Weapon in WeaponClient.LoadedWeapons do
        if type(Weapon) ~= "table" then
            continue
        end

        if not (Weapon.Settings and Weapon.Settings.WeaponType == "Gun") then
            continue
        end

        local IsEquipped = Weapon.Equipped

        if not IsEquipped and Weapon.Tool then
            IsEquipped = Weapon.Tool.Parent == LocalPlayer.Character
        end

        if IsEquipped then
            return Weapon
        end
    end
end

local Util = require(Modules:FindFirstChild("Utility", true):FindFirstChild("Util"))
local RandomizeUnit = Util.RandomizeUnit

local GetMouseLocation = UserInputService.GetMouseLocation

local GetWorldPosition = function(Instance)
    if Instance:IsA("BasePart") then
        return Instance.Position
    end

    if Instance:IsA("Attachment") then
        return Instance.WorldPosition
    end
end

local GetMuzzle = function(Weapon)
    if not Weapon then
        return
    end

    local Tip = Weapon.Tip

    if Tip then
        local Position = GetWorldPosition(Tip)

        if Position then
            return Position
        end
    end

    local Base

    if typeof(Weapon.GetBase) == "function" then
        Base = Weapon:GetBase()
    end

    if Base and Base.Tip then
        return GetWorldPosition(Base.Tip)
    end
end

local GetHitPart = function()
    local PartName = SilentAimSettings.HitPart

    if PartName == "Random" then
        PartName = RandomHitParts[SilentAimRandom:NextInteger(1, #RandomHitParts)]
    end

    if PartName ~= "Head" and SilentAimSettings.HeadshotChance > 0 and SilentAimRandom:NextNumber(0, 100) <= SilentAimSettings.HeadshotChance then
        PartName = "Head"
    end

    return PartName
end

local IsWindowPart = function(Instance)
    local Current = Instance

    while Current do
        if Current:IsA("BasePart") and (Current.Material == Enum.Material.Glass or Current.Transparency > 0.5) then
            return true
        end

        if string.find(string.lower(Current.Name), "window") then
            return true
        end

        Current = Current.Parent
    end

    return false
end

local VisibilityParams = RaycastParams.new()
local VisibilityFilter = { LocalPlayer.Character }

VisibilityParams.FilterType = Enum.RaycastFilterType.Exclude
VisibilityParams.FilterDescendantsInstances = VisibilityFilter

local IsVisible = function(Origin, TargetPart, Character)
    VisibilityFilter[1] = LocalPlayer.Character

    local Direction = (TargetPart.Position - Origin).Unit
    local Distance = 1000
    local Start = Origin

    for _ = 1, 32 do
        local Result = workspace:Raycast(Start, Direction * Distance, VisibilityParams)

        if not Result then
            return true
        end

        local Current = Result.Instance

        while Current do
            if Current == TargetPart or Current:IsDescendantOf(Character) then
                return true
            end

            Current = Current.Parent
        end

        if not (AutoShootSettings.ShootThroughWindows and IsWindowPart(Result.Instance)) then
            return false
        end

        local Remaining = Distance - (Result.Position - Start).Magnitude
        Start = Result.Position + Direction * 0.05
        Distance = Remaining
    end

    return false
end

local Target = function(MousePosition)
    if SilentAimSettings.HitChance < 100 and SilentAimRandom:NextNumber(0, 100) > SilentAimSettings.HitChance then
        return
    end

    local PartName = GetHitPart()
    local ClosestDistance = SilentAimSettings.FOV
    local Closest
    local Origin = Camera.CFrame.Position
    local MouseLocation = MousePosition or GetMouseLocation(UserInputService)

    for _, Player in Players:GetPlayers() do
        local TheirCharacter = Player.Character

        if Player == LocalPlayer or not TheirCharacter or TheirCharacter:GetAttribute("Immune") == true then
            continue
        end

        local TargetPart = TheirCharacter:FindFirstChild(PartName)
        local Humanoid = TheirCharacter:FindFirstChild("Humanoid")

        if not TargetPart or not Humanoid or Humanoid.Health <= 0 then
            continue
        end

        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)

        if not OnScreen then
            continue
        end

        if SilentAimSettings.VisibleCheck and not IsVisible(Origin, TargetPart, TheirCharacter) then
            continue
        end

        local Coordinates = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        local Distance = (Coordinates - MouseLocation).Magnitude

        if Distance < ClosestDistance then
            ClosestDistance = Distance
            Closest = TargetPart
        end
    end

    return Closest
end

local GetTargetAimPoint = function(TargetPart)
    return TargetPart.Position
end

local ApplyAimSpread = function(AimPoint, Start)
    local Unit = (AimPoint - Start).Unit

    if SilentAimSettings.EmulateSpread and RandomizeUnit then
        local Weapon = GetEquippedGun()

        if Weapon and Weapon.Settings and (Weapon.Settings.Spread or 0) > 0 then
            local Factor = 0.5

            if Weapon.Aiming and (Weapon.Settings.NumberOfShots or 1) < 2 then
                Factor = 0.25
            end

            Unit = RandomizeUnit(Unit, Weapon.Settings.Spread * Factor)
        end
    end

    return Unit * 5000
end

local Cursor = Modules:FindFirstChild("Cursor", true)
local CursorModule = Cursor and require(Cursor)
local OriginalGetHit

OriginalGetHit = HookFunction(CursorModule.GetHit, function(Self, ...)
    if SilentAimSettings.Enabled and SilentAimSettings.Method == "Mouse (Legit)" then
        local TargetPart = Target()

        if TargetPart then
            return GetTargetAimPoint(TargetPart)
        end
    end

    return OriginalGetHit(Self, ...)
end)

Groups.SilentAim:AddToggle("SilentAimEnabled", {
    Text = "Enabled",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.Enabled = Value
    end,
})

Groups.SilentAim:AddToggle("VisibleCheck", {
    Text = "Visible Check",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.VisibleCheck = Value
    end,
})

Groups.SilentAim:AddDropdown("SilentAimMethod", {
    Values = { "Raycast", "Mouse (Legit)" },
    Default = SilentAimSettings.Method,

    Text = "Silent Aim Method",

    Callback = function(Value)
        SilentAimSettings.Method = Value
    end,
})

Groups.SilentAim:AddDropdown("HitPart", {
    Values = HitParts,
    Default = SilentAimSettings.HitPart,

    Text = "Hit Part",

    Callback = function(Value)
        SilentAimSettings.HitPart = Value
    end,
})

Groups.SilentAim:AddDropdown("AimOriginMethod", {
    Values = { "Camera", "Shootable" },
    Default = SilentAimSettings.OriginMethod,

    Text = "Origin Method",

    Callback = function(Value)
        SilentAimSettings.OriginMethod = Value
    end,
})

Groups.SilentAim:AddSlider("HitChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " %",

    Callback = function(Value)
        SilentAimSettings.HitChance = Value
    end,
})

Groups.SilentAim:AddSlider("HeadshotChance", {
    Text = "Headshot Chance",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " %",

    Callback = function(Value)
        SilentAimSettings.HeadshotChance = Value
    end,
})

Groups.SilentAim:AddToggle("EmulateSpread", {
    Text = "Emulate Spread",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.EmulateSpread = Value
    end,
})

Groups.SilentAim:AddDivider()

Groups.SilentAim:AddToggle("FOVCircle", {
    Text = "FOV Circle",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.FOVCircle = Value
    end,
}):AddColorPicker("FOVCircleColor", {
    Default = SilentAimSettings.FOVCircleColor,
    Title = "FOV Circle Color",

    Callback = function(Value)
        SilentAimSettings.FOVCircleColor = Value
    end,
})

Groups.SilentAim:AddToggle("Snaplines", {
    Text = "Snaplines",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.Snaplines = Value
    end,
}):AddColorPicker("SnaplineColor", {
    Default = SilentAimSettings.SnaplineColor,
    Title = "Snapline Color",

    Callback = function(Value)
        SilentAimSettings.SnaplineColor = Value
    end,
})

Groups.SilentAim:AddSlider("FOV", {
    Text = "FOV",
    Default = 150,
    Rounding = 0,

    Min = 0,
    Max = 500,
    Suffix = " px",

    Callback = function(Value)
        SilentAimSettings.FOV = Value
    end,
})

Groups.SilentAim:AddDivider()

Groups.SilentAim:AddToggle("Manipulation", {
    Text = "Manipulation",
    Default = false,

    Callback = function(Value)
        SilentAimSettings.Manipulation = Value
    end,
})

Groups.SilentAim:AddSlider("ManipOriginX", {
    Text = "Origin X",
    Default = 0,
    Rounding = 1,

    Min = 0,
    Max = 20,

    Callback = function(Value)
        local Origin = SilentAimSettings.Origin
        SilentAimSettings.Origin = Vector3.new(Value, Origin.Y, Origin.Z)
    end,
})

Groups.SilentAim:AddSlider("ManipOriginY", {
    Text = "Origin Y",
    Default = 5,
    Rounding = 1,

    Min = 0,
    Max = 20,

    Callback = function(Value)
        local Origin = SilentAimSettings.Origin
        SilentAimSettings.Origin = Vector3.new(Origin.X, Value, Origin.Z)
    end,
})

Groups.SilentAim:AddSlider("ManipOriginZ", {
    Text = "Origin Z",
    Default = 0,
    Rounding = 1,

    Min = 0,
    Max = 20,

    Callback = function(Value)
        local Origin = SilentAimSettings.Origin
        SilentAimSettings.Origin = Vector3.new(Origin.X, Origin.Y, Value)
    end,
})

-- Auto Shoot
local Environment = GetGenv()
local HasMousePress = type(Environment.mouse1press) == "function"
local HasMouseClick = type(Environment.mouse1click) == "function"
local HasMouseRelease = type(Environment.mouse1release) == "function"

local AutoShootMethods = { "Game Function", "VIM" }

if HasMousePress or (HasMouseClick and HasMouseRelease) then
    AutoShootMethods[#AutoShootMethods + 1] = "Input Library"
end

local VirtualInput = Instance.new("VirtualInputManager")

local AutoShootRandom = Random.new()
local AutoShootNextFire

local AutoShootCalculateDelay = function()
    return (AutoShootSettings.Delay + AutoShootRandom:NextInteger(-AutoShootSettings.Variation, AutoShootSettings.Variation)) / 1000
end

local FireWeapon = function(Method)
    if Method == "Game Function" then
        local Weapon = GetEquippedGun()

        if Weapon then
            Weapon.FireGun(Weapon)
        end

        return
    end

    if Method == "VIM" then
        local MousePosition = GetMouseLocation(UserInputService)
        local ClickGui = LocalPlayer.PlayerGui

        VirtualInput:SendMouseButtonEvent(MousePosition.X, MousePosition.Y, 0, true, ClickGui, 1)
        VirtualInput:SendMouseButtonEvent(MousePosition.X, MousePosition.Y, 0, false, ClickGui, 1)

        return
    end

    if HasMousePress then
        Environment.mouse1press()
    elseif HasMouseClick then
        Environment.mouse1click()
    end

    if HasMouseRelease then
        Environment.mouse1release()
    end
end

Groups.AutoShoot:AddToggle("AutoShootEnabled", {
    Text = "Enabled",
    Default = false,

    Callback = function(Value)
        AutoShootSettings.Enabled = Value
        AutoShootNextFire = nil
    end,
})

Groups.AutoShoot:AddToggle("ShootThroughWindows", {
    Text = "Shoot Through Windows",
    Default = false,

    Callback = function(Value)
        AutoShootSettings.ShootThroughWindows = Value
    end,
})

Groups.AutoShoot:AddDropdown("AutoShootMethod", {
    Values = AutoShootMethods,
    Default = AutoShootSettings.Method,

    Text = "Shoot Method",

    Callback = function(Value)
        AutoShootSettings.Method = Value
    end,
})

Groups.AutoShoot:AddSlider("AutoShootDelay", {
    Text = "Shoot Delay",
    Default = 100,
    Rounding = 0,

    Min = 0,
    Max = 1000,
    Suffix = " ms",

    Callback = function(Value)
        AutoShootSettings.Delay = Value
    end,
})

Groups.AutoShoot:AddSlider("AutoShootDelayVariation", {
    Text = "Delay Variation",
    Default = 0,
    Rounding = 0,

    Min = 0,
    Max = 100,
    Suffix = " ms",

    Callback = function(Value)
        AutoShootSettings.Variation = Value
    end,
})

-- Mods
local ModsSettings = {
    NoSpread = false,
    NoRecoil = false,
    InstantReload = false,
    NoJumpCooldown = false,
    KillOnCarry = false,
    CarryKillDelay = 0.5,
}

local LocalCharacter = GameFolder and require(GameFolder:FindFirstChild("LocalCharacter"))
local OriginalMovementUpdate = LocalCharacter and LocalCharacter.MovementUpdate or nil
local NoSpreadActive = false
local MovementModsActive = false

local ApplyNoSpread = function()
    if not RandomizeUnit or NoSpreadActive then
        return
    end

    Util.RandomizeUnit = function(Unit)
        return Unit
    end

    NoSpreadActive = true
end

local UnapplyNoSpread = function()
    if not RandomizeUnit or not NoSpreadActive then
        return
    end

    Util.RandomizeUnit = RandomizeUnit
    NoSpreadActive = false
end

local ApplyMovementMods = function()
    if not OriginalMovementUpdate or MovementModsActive then
        return
    end

    LocalCharacter.MovementUpdate = function(Self, DeltaTime)
        OriginalMovementUpdate(Self, DeltaTime)

        local Humanoid = Self.Character and Self.Character:FindFirstChild("Humanoid")

        if not Humanoid then
            return
        end

        if ModsSettings.NoJumpCooldown then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
    end

    MovementModsActive = true
end

local UnapplyMovementMods = function()
    if not OriginalMovementUpdate or not MovementModsActive then
        return
    end

    LocalCharacter.MovementUpdate = OriginalMovementUpdate
    MovementModsActive = false
end

local ApplyWeaponMods = function()
    if not WeaponClient or not WeaponClient.LoadedWeapons then
        return
    end

    for _, Weapon in WeaponClient.LoadedWeapons do
        if type(Weapon) ~= "table" then
            continue
        end

        if not (Weapon.Settings and Weapon.Settings.WeaponType == "Gun") then
            continue
        end

        if ModsSettings.NoRecoil then
            Weapon.DoRecoil = function()
            end
        else
            Weapon.DoRecoil = nil
        end

        if ModsSettings.InstantReload then
            Weapon.Reload = function(Self)
                if not Self.Reloading then
                    Self.ReloadGun:FireServer(true)
                    Self.Reloading = true
                    Self.CurrentAmmo = Self.Settings.MaxAmmo
                    Self:ReloadDone()
                end
            end
        else
            Weapon.Reload = nil
        end
    end
end

task.spawn(function()
    while true do
        if ModsSettings.NoSpread then
            ApplyNoSpread()
        else
            UnapplyNoSpread()
        end

        if ModsSettings.NoJumpCooldown then
            ApplyMovementMods()
        else
            UnapplyMovementMods()
        end

        ApplyWeaponMods()

        task.wait(0.5)
    end
end)

Groups.Mods:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false,

    Callback = function(Value)
        ModsSettings.NoSpread = Value
    end,
})

Groups.Mods:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false,

    Callback = function(Value)
        ModsSettings.NoRecoil = Value
    end,
})

Groups.Mods:AddToggle("InstantReload", {
    Text = "Instant Reload",
    Default = false,

    Callback = function(Value)
        ModsSettings.InstantReload = Value
    end,
})

Groups.Mods:AddToggle("NoJumpCooldown", {
    Text = "No Jump Cooldown",
    Default = false,

    Callback = function(Value)
        ModsSettings.NoJumpCooldown = Value
    end,
})

Groups.Mods:AddDivider()

local CarryWatcherActive = false
local CarryWatchConnection

local StopKillOnCarry = function()
    CarryWatcherActive = false

    if CarryWatchConnection then
        CarryWatchConnection:Disconnect()
        CarryWatchConnection = nil
    end
end

local StartKillOnCarry = function()
    StopKillOnCarry()
    CarryWatcherActive = true

    local WatchCharacter = function(Character)
        if not (CarryWatcherActive and Character) then
            return
        end

        Character:GetAttributeChangedSignal("Carried"):Connect(function()
            if not Character:GetAttribute("Carried") then
                return
            end

            local DelaySeconds = ModsSettings.CarryKillDelay

            task.delay(DelaySeconds, function()
                if not (CarryWatcherActive and Character and Character:GetAttribute("Carried")) then
                    return
                end

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if Humanoid and Humanoid.Health > 0 then
                    Humanoid.Health = 0
                end
            end)
        end)
    end

    WatchCharacter(LocalPlayer.Character)
    CarryWatchConnection = LocalPlayer.CharacterAdded:Connect(WatchCharacter)
end

Groups.Mods:AddDivider()

Groups.Mods:AddToggle("KillOnCarry", {
    Text = "Auto Kill on Pickup",
    Default = false,

    Callback = function(Value)
        ModsSettings.KillOnCarry = Value

        if Value then
            StartKillOnCarry()
        else
            StopKillOnCarry()
        end
    end,
})

Groups.Mods:AddSlider("CarryKillDelay", {
    Text = "Kill Delay",
    Default = 0.5,
    Min = 0,
    Max = 5,
    Rounding = 2,

    Callback = function(Value)
        ModsSettings.CarryKillDelay = Value
    end,
})

-- Visuals
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = SilentAimSettings.FOV
FOVCircle.Thickness = 1
FOVCircle.NumSides = 120
FOVCircle.Visible = false
FOVCircle.ZIndex = 1

local Snapline = Drawing.new("Line")
Snapline.Color = SilentAimSettings.SnaplineColor
Snapline.Thickness = 1
Snapline.Visible = false
Snapline.ZIndex = 1

-- Lighting
local LightingSettings = {
    FullBright = false,
    Brightness = Lighting.Brightness,
    AmbientColor = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    AmbientIntensity = 1,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    ColorShiftTop = Lighting.ColorShift_Top,
    ColorShiftBottom = Lighting.ColorShift_Bottom,
    FogEnabled = Lighting.FogEnd < 100000,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
}

local Floor = math.floor
local Clamp = math.clamp

local ScaleColor = function(Color, Intensity)
    return Color3.fromRGB(
        Clamp(Floor(Color.R * 255 * Intensity), 0, 255),
        Clamp(Floor(Color.G * 255 * Intensity), 0, 255),
        Clamp(Floor(Color.B * 255 * Intensity), 0, 255)
    )
end

local ApplyLighting = function()
    if LightingSettings.FullBright then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
    else
        Lighting.Brightness = LightingSettings.Brightness
        Lighting.Ambient = ScaleColor(LightingSettings.AmbientColor, LightingSettings.AmbientIntensity)
        Lighting.OutdoorAmbient = ScaleColor(LightingSettings.OutdoorAmbient, LightingSettings.AmbientIntensity)
        Lighting.GlobalShadows = LightingSettings.GlobalShadows
        Lighting.ClockTime = LightingSettings.ClockTime
        Lighting.ColorShift_Top = LightingSettings.ColorShiftTop
        Lighting.ColorShift_Bottom = LightingSettings.ColorShiftBottom
    end

    if LightingSettings.FogEnabled then
        Lighting.FogStart = LightingSettings.FogStart
        Lighting.FogEnd = LightingSettings.FogEnd
        Lighting.FogColor = LightingSettings.FogColor
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    end
end

local LightingEffectClassMap = {
    SunRays = "SunRaysEffect",
    Bloom = "BloomEffect",
    ColorCorrection = "ColorCorrectionEffect",
    Blur = "BlurEffect",
}

local GetLightingEffectClass = function(ClassName)
    return LightingEffectClassMap[ClassName] or ClassName
end

local ExistingEffects = {
    SunRays = Lighting:FindFirstChildOfClass(GetLightingEffectClass("SunRays")),
    Bloom = Lighting:FindFirstChildOfClass(GetLightingEffectClass("Bloom")),
    ColorCorrection = Lighting:FindFirstChildOfClass(GetLightingEffectClass("ColorCorrection")),
    Blur = Lighting:FindFirstChildOfClass(GetLightingEffectClass("Blur")),
}

local EnableLightingEffect = function(ClassName, Value)
    local EffectClass = GetLightingEffectClass(ClassName)
    local Effect = Lighting:FindFirstChildOfClass(EffectClass)

    if not Effect then
        Effect = Instance.new(EffectClass)
        Effect.Name = EffectClass
        Effect.Parent = Lighting
    end

    Effect.Enabled = Value
end

local SetLightingEffect = function(ClassName, Property, Value)
    local Effect = Lighting:FindFirstChildOfClass(GetLightingEffectClass(ClassName))

    if Effect then
        Effect[Property] = Value
    end
end

Groups.Lighting:AddToggle("FullBright", {
    Text = "Fullbright",
    Default = false,

    Callback = function(Value)
        LightingSettings.FullBright = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddToggle("GlobalShadows", {
    Text = "Shadows",
    Default = LightingSettings.GlobalShadows,

    Callback = function(Value)
        LightingSettings.GlobalShadows = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddToggle("FogEnabled", {
    Text = "Fog",
    Default = LightingSettings.FogEnabled,

    Callback = function(Value)
        LightingSettings.FogEnabled = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddDivider()

Groups.Lighting:AddSlider("LightingBrightness", {
    Text = "Brightness",
    Default = LightingSettings.Brightness,
    Min = 0,
    Max = 10,
    Rounding = 1,

    Callback = function(Value)
        LightingSettings.Brightness = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddSlider("AmbientIntensity", {
    Text = "Ambient Intensity",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,

    Callback = function(Value)
        LightingSettings.AmbientIntensity = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddLabel("Ambient"):AddColorPicker("LightingAmbientColor", {
    Default = LightingSettings.AmbientColor,
    Title = "Ambient Color",

    Callback = function(Value)
        LightingSettings.AmbientColor = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddLabel("Outdoor Ambient"):AddColorPicker("LightingOutdoorAmbientColor", {
    Default = LightingSettings.OutdoorAmbient,
    Title = "Outdoor Ambient Color",

    Callback = function(Value)
        LightingSettings.OutdoorAmbient = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddLabel("Color Shift Top"):AddColorPicker("LightingColorShiftTop", {
    Default = LightingSettings.ColorShiftTop,
    Title = "Color Shift Top",

    Callback = function(Value)
        LightingSettings.ColorShiftTop = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddLabel("Color Shift Bottom"):AddColorPicker("LightingColorShiftBottom", {
    Default = LightingSettings.ColorShiftBottom,
    Title = "Color Shift Bottom",

    Callback = function(Value)
        LightingSettings.ColorShiftBottom = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddSlider("LightingClockTime", {
    Text = "Time Of Day",
    Default = LightingSettings.ClockTime,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Suffix = " h",

    Callback = function(Value)
        LightingSettings.ClockTime = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddDivider()

Groups.Lighting:AddSlider("FogStart", {
    Text = "Fog Start",
    Default = LightingSettings.FogStart,
    Min = 0,
    Max = 500,
    Rounding = 0,

    Callback = function(Value)
        LightingSettings.FogStart = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddSlider("FogEnd", {
    Text = "Fog End",
    Default = LightingSettings.FogEnd,
    Min = 0,
    Max = 10000,
    Rounding = 0,

    Callback = function(Value)
        LightingSettings.FogEnd = Value
        ApplyLighting()
    end,
})

Groups.Lighting:AddLabel("Fog"):AddColorPicker("LightingFogColor", {
    Default = LightingSettings.FogColor,
    Title = "Fog Color",

    Callback = function(Value)
        LightingSettings.FogColor = Value
        ApplyLighting()
    end,
})

local LightingEffectsConfig = {
    {
        Key = "SunRays",
        Text = "Sun Rays",
        Defaults = ExistingEffects.SunRays,
        Sliders = {
            { Name = "SunRaysIntensity", Property = "Intensity", Text = "Intensity", Min = 0, Max = 1, Rounding = 2, Default = 1 },
            { Name = "SunRaysSpread", Property = "Spread", Text = "Spread", Min = 0, Max = 1, Rounding = 2, Default = 1 },
        },
    },
    {
        Key = "Bloom",
        Text = "Bloom",
        Defaults = ExistingEffects.Bloom,
        Sliders = {
            { Name = "BloomIntensity", Property = "Intensity", Text = "Intensity", Min = 0, Max = 1, Rounding = 2, Default = 1 },
            { Name = "BloomSize", Property = "Size", Text = "Size", Min = 0, Max = 1, Rounding = 2, Default = 1 },
            { Name = "BloomThreshold", Property = "Threshold", Text = "Threshold", Min = 0, Max = 1, Rounding = 2, Default = 1 },
        },
    },
    {
        Key = "ColorCorrection",
        Text = "Color Correction",
        Defaults = ExistingEffects.ColorCorrection,
        Sliders = {
            { Name = "ColorCorrectionBrightness", Property = "Brightness", Text = "Brightness", Min = -1, Max = 1, Rounding = 2, Default = 0 },
            { Name = "ColorCorrectionContrast", Property = "Contrast", Text = "Contrast", Min = -1, Max = 1, Rounding = 2, Default = 0 },
            { Name = "ColorCorrectionSaturation", Property = "Saturation", Text = "Saturation", Min = -1, Max = 1, Rounding = 2, Default = 0 },
        },
        Tint = {
            Name = "ColorCorrectionTint",
            Title = "Tint Color",
        },
    },
    {
        Key = "Blur",
        Text = "Blur",
        Defaults = ExistingEffects.Blur,
        Sliders = {
            { Name = "BlurSize", Property = "Size", Text = "Size", Min = 0, Max = 24, Rounding = 0, Default = 0 },
        },
    },
}

for _, Effect in LightingEffectsConfig do
    local Defaults = Effect.Defaults

    Groups.LightingEffects:AddToggle(Effect.Key .. "Enabled", {
        Text = Effect.Text,
        Default = Defaults and Defaults.Enabled or false,

        Callback = function(Value)
            EnableLightingEffect(Effect.Key, Value)
        end,
    })

    for _, Slider in Effect.Sliders do
        Groups.LightingEffects:AddSlider(Slider.Name, {
            Text = Slider.Text,
            Default = Defaults and Defaults[Slider.Property] or Slider.Default,
            Min = Slider.Min,
            Max = Slider.Max,
            Rounding = Slider.Rounding,

            Callback = function(Value)
                SetLightingEffect(Effect.Key, Slider.Property, Value)
            end,
        })
    end

    if Effect.Tint then
        Groups.LightingEffects:AddLabel("Tint"):AddColorPicker(Effect.Tint.Name, {
            Default = Defaults and Defaults.TintColor or Color3.fromRGB(255, 255, 255),
            Title = Effect.Tint.Title,

            Callback = function(Value)
                SetLightingEffect(Effect.Key, "TintColor", Value)
            end,
        })
    end

    Groups.LightingEffects:AddDivider()
end

-- ESP
local ESPSettings = {
    Enabled = false,
    IgnoreImmune = true,
    BoundingBoxes = true,
    Boxes = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    Healthbars = true,
    HealthText = false,
    Tracers = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    Names = true,
    Distances = true,
    Weapons = true,
    TextColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 0,
    FontSize = 13,
    Rainbow = false,
    RainbowSpeed = 1,
}

Groups.ESP:AddToggle("ESPEnabled", {
    Text = "Enabled",
    Default = false,

    Callback = function(Value)
        ESPSettings.Enabled = Value
    end,
})

Groups.ESP:AddToggle("ESPIgnoreImmune", {
    Text = "Ignore Immune",
    Default = true,

    Callback = function(Value)
        ESPSettings.IgnoreImmune = Value
    end,
})

Groups.ESP:AddToggle("ESPBoundingBoxes", {
    Text = "Bounding Boxes",
    Default = true,

    Callback = function(Value)
        ESPSettings.BoundingBoxes = Value
    end,
})

Groups.ESP:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = true,

    Callback = function(Value)
        ESPSettings.Boxes = Value
    end,
})

Groups.ESP:AddToggle("ESPHealthbars", {
    Text = "Healthbars",
    Default = true,

    Callback = function(Value)
        ESPSettings.Healthbars = Value
    end,
})

Groups.ESP:AddToggle("ESPHealthText", {
    Text = "HP Text",
    Default = false,

    Callback = function(Value)
        ESPSettings.HealthText = Value
    end,
})

Groups.ESP:AddToggle("ESPTracers", {
    Text = "Tracers",
    Default = false,

    Callback = function(Value)
        ESPSettings.Tracers = Value
    end,
})

Groups.ESP:AddToggle("ESPNames", {
    Text = "Names",
    Default = true,

    Callback = function(Value)
        ESPSettings.Names = Value
    end,
})

Groups.ESP:AddToggle("ESPDistances", {
    Text = "Distances",
    Default = true,

    Callback = function(Value)
        ESPSettings.Distances = Value
    end,
})

Groups.ESP:AddToggle("ESPWeapons", {
    Text = "Weapons",
    Default = true,

    Callback = function(Value)
        ESPSettings.Weapons = Value
    end,
})

Groups.ESP:AddToggle("ESPRainbow", {
    Text = "Rainbow",
    Default = false,

    Callback = function(Value)
        ESPSettings.Rainbow = Value
    end,
})

Groups.ESP:AddDivider()

Groups.ESP:AddLabel("Box"):AddColorPicker("ESPBoxColor", {
    Default = ESPSettings.BoxColor,
    Title = "Box Color",

    Callback = function(Value)
        ESPSettings.BoxColor = Value
    end,
})

Groups.ESP:AddLabel("Tracer"):AddColorPicker("ESPTracerColor", {
    Default = ESPSettings.TracerColor,
    Title = "Tracer Color",

    Callback = function(Value)
        ESPSettings.TracerColor = Value
    end,
})

Groups.ESP:AddLabel("Text"):AddColorPicker("ESPTextColor", {
    Default = ESPSettings.TextColor,
    Title = "Text Color",

    Callback = function(Value)
        ESPSettings.TextColor = Value
    end,
})

Groups.ESP:AddDivider()

Groups.ESP:AddSlider("ESPMaxDistance", {
    Text = "Max Distance",
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Suffix = " m",

    Callback = function(Value)
        ESPSettings.MaxDistance = Value
    end,
})

Groups.ESP:AddSlider("ESPFontSize", {
    Text = "Font Size",
    Default = 13,
    Min = 10,
    Max = 20,
    Rounding = 0,

    Callback = function(Value)
        ESPSettings.FontSize = Value
    end,
})

Groups.ESP:AddSlider("ESPRainbowSpeed", {
    Text = "Rainbow Speed",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,

    Callback = function(Value)
        ESPSettings.RainbowSpeed = Value
    end,
})

local ESPObjects = {}
local PlayersList = {}

for _, ExistingPlayer in Players:GetPlayers() do
    PlayersList[#PlayersList + 1] = ExistingPlayer
end

Players.PlayerAdded:Connect(function(Player)
    PlayersList[#PlayersList + 1] = Player
end)

local GetESPObjects = function(PlayerName)
    local Objects = ESPObjects[PlayerName]

    if Objects then
        return Objects
    end

    local Square = Drawing.new("Square")
    Square.Thickness = 1
    Square.Visible = false

    local BarBackground = Drawing.new("Square")
    BarBackground.Filled = true
    BarBackground.Thickness = 0
    BarBackground.Color = Color3.fromRGB(0, 0, 0)
    BarBackground.Visible = false

    local BarFill = Drawing.new("Square")
    BarFill.Filled = true
    BarFill.Thickness = 0
    BarFill.Visible = false

    local BarOutline = Drawing.new("Square")
    BarOutline.Thickness = 1
    BarOutline.Color = Color3.fromRGB(0, 0, 0)
    BarOutline.Visible = false

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    Tracer.Visible = false

    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true
    Name.Visible = false

    local HealthText = Drawing.new("Text")
    HealthText.Size = 13
    HealthText.Center = true
    HealthText.Outline = true
    HealthText.Visible = false

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Outline = true
    Distance.Visible = false

    local Weapon = Drawing.new("Text")
    Weapon.Size = 13
    Weapon.Center = true
    Weapon.Outline = true
    Weapon.Visible = false

    Objects = {
        Square = Square,
        BarBackground = BarBackground,
        BarFill = BarFill,
        BarOutline = BarOutline,
        Tracer = Tracer,
        Name = Name,
        HealthText = HealthText,
        Distance = Distance,
        Weapon = Weapon,
    }

    ESPObjects[PlayerName] = Objects

    return Objects
end

local HideESP = function(PlayerName)
    local Objects = ESPObjects[PlayerName]

    if not Objects then
        return
    end

    Objects.Square.Visible = false
    Objects.BarBackground.Visible = false
    Objects.BarFill.Visible = false
    Objects.BarOutline.Visible = false
    Objects.Tracer.Visible = false
    Objects.Name.Visible = false
    Objects.HealthText.Visible = false
    Objects.Distance.Visible = false
    Objects.Weapon.Visible = false
end

local BoxPartNames = {
    ["Head"] = true,
    ["Torso"] = true,
    ["Right Arm"] = true,
    ["Left Arm"] = true,
    ["Right Leg"] = true,
    ["Left Leg"] = true,
}

local BuildBoxCorners = function(Character, Root)
    local RootCF = Root.CFrame
    local MinX, MaxX = math.huge, -math.huge
    local MinY, MaxY = math.huge, -math.huge
    local MinZ, MaxZ = math.huge, -math.huge

    local Enclose = function(Part)
        local Position = RootCF:PointToObjectSpace(Part.CFrame.Position)
        local HalfX = Part.Size.X * 0.5
        local HalfY = Part.Size.Y * 0.5
        local HalfZ = Part.Size.Z * 0.5

        MinX = math.min(MinX, Position.X - HalfX)
        MaxX = math.max(MaxX, Position.X + HalfX)
        MinY = math.min(MinY, Position.Y - HalfY)
        MaxY = math.max(MaxY, Position.Y + HalfY)
        MinZ = math.min(MinZ, Position.Z - HalfZ)
        MaxZ = math.max(MaxZ, Position.Z + HalfZ)
    end

    for _, Part in Character:GetDescendants() do
        if Part:IsA("Accessory") then
            local Handle = Part:FindFirstChild("Handle")

            if Handle and Handle:IsA("BasePart") then
                Enclose(Handle)
            end
        elseif BoxPartNames[Part.Name] and Part:IsA("BasePart") then
            Enclose(Part)
        end
    end

    if MinX > MaxX or MinY > MaxY or MinZ > MaxZ then
        return
    end

    local Minimum = Vector3.new(MinX, MinY, MinZ)
    local Maximum = Vector3.new(MaxX, MaxY, MaxZ)

    return {
        Minimum,
        Vector3.new(Maximum.X, Minimum.Y, Minimum.Z),
        Vector3.new(Minimum.X, Maximum.Y, Minimum.Z),
        Vector3.new(Maximum.X, Maximum.Y, Minimum.Z),
        Vector3.new(Minimum.X, Minimum.Y, Maximum.Z),
        Vector3.new(Maximum.X, Minimum.Y, Maximum.Z),
        Vector3.new(Minimum.X, Maximum.Y, Maximum.Z),
        Maximum,
    }
end

local GetScreenBox = function(Root, Corners)
    if not Root or not Corners then
        return
    end

    local RootCF = Root.CFrame
    local MinX, MaxX = math.huge, -math.huge
    local MinY, MaxY = math.huge, -math.huge

    for _, Corner in Corners do
        local Screen, Visible = Camera:WorldToViewportPoint(RootCF:PointToWorldSpace(Corner))

        if not Visible or Screen.Z <= 0 then
            return
        end

        MinX = math.min(MinX, Screen.X)
        MaxX = math.max(MaxX, Screen.X)
        MinY = math.min(MinY, Screen.Y)
        MaxY = math.max(MaxY, Screen.Y)
    end

    return Vector2.new(MinX, MinY), MaxX - MinX, MaxY - MinY
end

-- Chams
local ChamsSettings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 0.5,
    Style = "AlwaysOnTop",
    SizeScale = 1,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTransparency = 0,
    OutlineSize = 0.25,
}

local ChamStyleNames = { "AlwaysOnTop", "XRay", "Default" }
local ChamShadings = {
    AlwaysOnTop = Enum.AdornShading.AlwaysOnTop,
    XRay = Enum.AdornShading.XRay,
    Default = Enum.AdornShading.Default,
}

local ChamFolder = Instance.new("Folder")
ChamFolder.Name = ""
ChamFolder.Parent = workspace

local ChamState = {}

local RemoveChamsForPlayer = function(PlayerName)
    local State = ChamState[PlayerName]

    if not State then
        return
    end

    for _, Pair in State.Adornments do
        Pair.Fill:Destroy()
        Pair.Outline:Destroy()
    end

    ChamState[PlayerName] = nil
end

local RemoveAllChams = function()
    for PlayerName in ChamState do
        RemoveChamsForPlayer(PlayerName)
    end
end

local ApplyChamsToCharacter = function(Character, FillColor)
    local PlayerName = Character.Name
    local State = ChamState[PlayerName]

    if State and State.Character == Character then
        for _, Pair in State.Adornments do
            Pair.Fill.Shading = ChamShadings[ChamsSettings.Style]
            Pair.Fill.Color3 = FillColor
            Pair.Fill.Transparency = ChamsSettings.Transparency
            Pair.Outline.Shading = ChamShadings[ChamsSettings.Style]
            Pair.Outline.Color3 = ChamsSettings.OutlineColor
            Pair.Outline.Transparency = ChamsSettings.OutlineTransparency
        end

        return
    end

    if State then
        RemoveChamsForPlayer(PlayerName)
    end

    local Adornments = {}

    for _, Part in Character:GetChildren() do
        if not Part:IsA("BasePart") then
            continue
        end

        local Scale = ChamsSettings.SizeScale
        local PartSize = Part.Size
        local FillSize = Vector3.new(PartSize.X * Scale, PartSize.Y * Scale, PartSize.Z * Scale)

        local Fill = Instance.new("BoxHandleAdornment")
        Fill.Name = "ChamFill"
        Fill.Adornee = Part
        Fill.Shading = ChamShadings[ChamsSettings.Style]
        Fill.ZIndex = 1
        Fill.Size = FillSize
        Fill.Color3 = FillColor
        Fill.Transparency = ChamsSettings.Transparency
        Fill.Parent = ChamFolder

        local Outline = Instance.new("BoxHandleAdornment")
        Outline.Name = "ChamOutline"
        Outline.Adornee = Part
        Outline.Shading = ChamShadings[ChamsSettings.Style]
        Outline.ZIndex = 0
        Outline.Size = Vector3.new(FillSize.X + ChamsSettings.OutlineSize, FillSize.Y + ChamsSettings.OutlineSize, FillSize.Z + ChamsSettings.OutlineSize)
        Outline.Color3 = ChamsSettings.OutlineColor
        Outline.Transparency = ChamsSettings.OutlineTransparency
        Outline.Parent = ChamFolder

        Adornments[#Adornments + 1] = { Fill = Fill, Outline = Outline }
    end

    ChamState[PlayerName] = {
        Character = Character,
        Adornments = Adornments,
    }
end

Groups.Chams:AddToggle("ChamsEnabled", {
    Text = "Enabled",
    Default = false,

    Callback = function(Value)
        ChamsSettings.Enabled = Value

        if Value then
            return
        end

        RemoveAllChams()
    end,
})

Groups.Chams:AddDivider()

Groups.Chams:AddLabel("Fill"):AddColorPicker("ChamsColor", {
    Default = ChamsSettings.Color,
    Title = "Fill Color",

    Callback = function(Value)
        ChamsSettings.Color = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddSlider("ChamsTransparency", {
    Text = "Fill Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,

    Callback = function(Value)
        ChamsSettings.Transparency = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddSlider("ChamsSizeScale", {
    Text = "Size Scale",
    Default = 1,
    Min = 0.5,
    Max = 2,
    Rounding = 1,

    Callback = function(Value)
        ChamsSettings.SizeScale = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddDropdown("ChamsStyle", {
    Values = ChamStyleNames,
    Default = ChamsSettings.Style,

    Text = "Render Mode",

    Callback = function(Value)
        ChamsSettings.Style = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddDivider()

Groups.Chams:AddLabel("Outline"):AddColorPicker("ChamsOutlineColor", {
    Default = ChamsSettings.OutlineColor,
    Title = "Outline Color",

    Callback = function(Value)
        ChamsSettings.OutlineColor = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddSlider("ChamsOutlineTransparency", {
    Text = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,

    Callback = function(Value)
        ChamsSettings.OutlineTransparency = Value
        RemoveAllChams()
    end,
})

Groups.Chams:AddSlider("ChamsOutlineSize", {
    Text = "Outline Size",
    Default = 0.25,
    Min = 0.1,
    Max = 1,
    Rounding = 2,

    Callback = function(Value)
        ChamsSettings.OutlineSize = Value
        RemoveAllChams()
    end,
})

Players.PlayerRemoving:Connect(function(Player)
    RemoveChamsForPlayer(Player.Name)

    for Index, ExistingPlayer in PlayersList do
        if ExistingPlayer == Player then
            table.remove(PlayersList, Index)
            break
        end
    end

    local Objects = ESPObjects[Player.Name]

    if not Objects then
        return
    end

    for _, DrawingObject in Objects do
        DrawingObject:Remove()
    end

    ESPObjects[Player.Name] = nil
end)

-- Spoofers
Groups.Spoofers:AddLabel(`<font color="rgb(255, 170, 60)">Warning: These spoofers are an experimental feature and do not fully work. Client-side only, others may still see your real name and stats.</font>`, true)
Groups.Spoofers:AddDivider()

local SpoofSettings = {
    NameEnabled = false,
    Name = "",
    StatsEnabled = false,
    Kills = 0,
    Deaths = 0,
    Level = 0,
    XP = 0,
    Time = 0,
}

local RealPlayerName = LocalPlayer.Name
local RealPlayerDisplayName = LocalPlayer.DisplayName

local SpoofKillFeedName = function(Killer, Victim)
    if SpoofSettings.NameEnabled and #SpoofSettings.Name > 0 then
        if Killer == RealPlayerName then
            Killer = SpoofSettings.Name
        end

        if Victim == RealPlayerName then
            Victim = SpoofSettings.Name
        end
    end

    return Killer, Victim
end

local SpoofStringName = function(Value)
    if not SpoofSettings.NameEnabled or #SpoofSettings.Name == 0 or type(Value) ~= "string" then
        return Value
    end

    local PatternPattern = "([%^%$%(%)%%%.%[%]%*%+%-%?])"

    Value = string.gsub(Value, string.gsub(RealPlayerName, PatternPattern, "%%%1"), SpoofSettings.Name)
    Value = string.gsub(Value, string.gsub(RealPlayerDisplayName, PatternPattern, "%%%1"), SpoofSettings.Name)

    return Value
end

local HUDFolder = ClientFolder and ClientFolder:FindFirstChild("HUD", true)
local GameUiFolder = HUDFolder and HUDFolder:FindFirstChild("GameUi", true)
local KillFeedModule = GameUiFolder and require(GameUiFolder:FindFirstChild("KillFeed"))
local NotificationsModule = GameUiFolder and require(GameUiFolder:FindFirstChild("Notifications"))

local OriginalNewFrame
local OriginalNewKillBanner
local OriginalNewKilledbyFrame
local OriginalChatMessage

OriginalNewFrame = HookFunction(KillFeedModule.NewFrame, function(Killer, Victim, Kind, Weapon)
    Killer, Victim = SpoofKillFeedName(Killer, Victim)
    return OriginalNewFrame(Killer, Victim, Kind, Weapon)
end)

OriginalNewKillBanner = HookFunction(KillFeedModule.NewKillBanner, function(Username, Kind, Streak, Distance, BloodBux, Tag)
    if SpoofSettings.NameEnabled and #SpoofSettings.Name > 0 and Username == RealPlayerName then
        Username = SpoofSettings.Name
    end

    return OriginalNewKillBanner(Username, Kind, Streak, Distance, BloodBux, Tag)
end)

OriginalNewKilledbyFrame = HookFunction(KillFeedModule.NewKilledbyFrame, function(KillerName, KillerDisplay, WeaponName, Distance)
    if SpoofSettings.NameEnabled and #SpoofSettings.Name > 0 then
        if KillerName == RealPlayerName then
            KillerName = SpoofSettings.Name
        end

        if KillerDisplay == RealPlayerName or KillerDisplay == RealPlayerDisplayName then
            KillerDisplay = SpoofSettings.Name
        end
    end

    return OriginalNewKilledbyFrame(KillerName, KillerDisplay, WeaponName, Distance)
end)

OriginalChatMessage = HookFunction(NotificationsModule.ChatMessage, function(Message, Color, Type)
    return OriginalChatMessage(SpoofStringName(Message), Color, Type)
end)

local UtilityFolder = Modules:FindFirstChild("Utility", true)
local PlayerUtil = UtilityFolder and require(UtilityFolder:FindFirstChild("PlayerUtil"))
local OriginalGetNameFromUserId

OriginalGetNameFromUserId = HookFunction(PlayerUtil.GetNameFromUserId, function(UserId)
    if SpoofSettings.NameEnabled and #SpoofSettings.Name > 0 and UserId == LocalPlayer.UserId then
        return SpoofSettings.Name
    end

    return OriginalGetNameFromUserId(UserId)
end)

local FormatStatNumber = function(Value)
    local Number = tostring(math.floor(Value))
    local Formatted = Number:reverse():gsub("(%d%d%d)", "%1,"):reverse()

    while Formatted:sub(1, 1) == "," do
        Formatted = Formatted:sub(2)
    end

    return Formatted
end

local FormatTime = function(Format)
    local Time = SpoofSettings.Time

    if Format == "Basic" then
        return `{math.floor(Time / 60)}h {math.floor(Time % 60)}m`
    end

    if Format == "Days" then
        return `{math.floor(Time / 1440)}d {math.floor((Time % 1440) / 60)}h {Time % 60}m`
    end

    if Format == "Comma" then
        return `{math.floor(Time / 60)}h, {Time % 60}m`
    end

    return string.format("%02d:%02d", math.floor(Time / 60), Time % 60)
end

local ApplySpoofedStats = function()
    if not SpoofSettings.StatsEnabled then
        return
    end

    local PlayerStats = LocalData.DataSlot.PlayerStats

    if PlayerStats then
        PlayerStats.Kills = SpoofSettings.Kills
        PlayerStats.Deaths = SpoofSettings.Deaths
        PlayerStats.Level = SpoofSettings.Level
        PlayerStats.XP = SpoofSettings.XP
        PlayerStats.Time = SpoofSettings.Time
    end

    local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")

    if Leaderstats then
        for _, Stat in Leaderstats:GetChildren() do
            if Stat:IsA("IntValue") then
                if string.find(Stat.Name, "Kills") then
                    Stat.Value = SpoofSettings.Kills
                elseif string.find(Stat.Name, "Deaths") then
                    Stat.Value = SpoofSettings.Deaths
                end
            elseif Stat:IsA("StringValue") and string.find(Stat.Name, "Time") then
                Stat.Value = FormatTime("Basic")
            end
        end
    end
end

local PatchKillsDeathsRow = function(Label)
    local StatValue = Label.Name == "Kills" and SpoofSettings.Kills or SpoofSettings.Deaths
    local ValueFirst, Rest = Label.Text:match("^(%d[%d,]*)%s+(%S.+)$")

    if ValueFirst then
        local NewText = FormatStatNumber(StatValue) .. " " .. Rest

        if NewText ~= Label.Text then
            Label.Text = NewText
        end

        return
    end

    local Prefix = Label.Text:match("^(.-)%d")

    if Prefix then
        local NewText = Prefix .. FormatStatNumber(StatValue)

        if NewText ~= Label.Text then
            Label.Text = NewText
        end
    end
end

local PatchTimeRow = function(Label)
    local Prefix = Label.Text:match("^(.-)%d")

    if not Prefix then
        return
    end

    local Rest = Label.Text:sub(#Prefix + 1)

    if Rest:match("^%d+d %d+h %d+m$") then
        local NewText = Prefix .. FormatTime("Days")

        if NewText ~= Label.Text then
            Label.Text = NewText
        end
    elseif Rest:match("^%d+h, %d+m$") then
        local NewText = Prefix .. FormatTime("Comma")

        if NewText ~= Label.Text then
            Label.Text = NewText
        end
    end
end

local PatchPlaytimeRow = function(Label)
    local NewText

    if Label.Text:find("Playtime: ", 1, true) == 1 then
        NewText = "Playtime: " .. FormatTime("Short")
    else
        NewText = math.floor(SpoofSettings.Time / 60 * 100) / 100 .. " hours"
    end

    if NewText ~= Label.Text then
        Label.Text = NewText
    end
end

local PatchLevelRow = function(Label)
    local Prefix = Label.Text:match("^(.-)Level: ")

    if Prefix then
        local NewText = Prefix .. FormatStatNumber(SpoofSettings.Level)

        if NewText ~= Label.Text then
            Label.Text = NewText
        end
    end
end

local PatchStatRowLabel = function(Label)
    local Name = Label.Name
    local Text = Label.Text

    if Name == "Kills" or Name == "Deaths" then
        PatchKillsDeathsRow(Label)
    elseif Name == "Time" then
        PatchTimeRow(Label)
    elseif Name == "Playtime" then
        PatchPlaytimeRow(Label)
    elseif Name == "Level" and string.find(Text, "â­", 1, true) then
        PatchLevelRow(Label)
    end
end



local PatchStatsSubtree = function(Root)
    if not Root then
        return
    end

    for _, Label in Root:GetDescendants() do
        if Label:IsA("TextLabel") then
            PatchStatRowLabel(Label)
        end
    end
end

local PatchLoadingScreenLabels = function()
    for _, Label in LocalPlayer.PlayerGui:GetDescendants() do
        if not Label:IsA("TextLabel") then
            continue
        end

        local Text = Label.Text

        if type(Text) ~= "string" then
            continue
        end

        local Prefix

        local Start = Text:find("Total Kills: ", 1, true)

        if Start then
            Prefix = Text:sub(1, Start - 1)

            if Prefix then
                local NewText = Prefix .. FormatStatNumber(SpoofSettings.Kills)

                if NewText ~= Text then
                    Label.Text = NewText
                end
            end
        else
            Start = Text:find("Total Deaths: ", 1, true)

            if Start then
                Prefix = Text:sub(1, Start - 1)

                if Prefix then
                    local NewText = Prefix .. FormatStatNumber(SpoofSettings.Deaths)

                    if NewText ~= Text then
                        Label.Text = NewText
                    end
                end
            else
                Start = Text:find("Best Killstreak: ", 1, true)

                if Start then
                    Prefix = Text:sub(1, Start - 1)

                    if Prefix then
                        local NewText = Prefix .. FormatStatNumber(SpoofSettings.Kills)

                        if NewText ~= Text then
                            Label.Text = NewText
                        end
                    end
                else
                    Start = Text:find("Time: ", 1, true)

                    if Start then
                        Prefix = Text:sub(1, Start - 1)

                        if Prefix then
                            local NewText = Prefix .. FormatTime("Basic")

                            if NewText ~= Text then
                                Label.Text = NewText
                            end
                        end
                    end
                end
            end
        end
    end
end

local PatchStatsGui = function()
    if not SpoofSettings.StatsEnabled then
        return
    end

    PatchStatsSubtree(LocalPlayer.PlayerGui:FindFirstChild("StatsFolder", true))

    local Sidescreen = LocalPlayer.PlayerGui:FindFirstChild("Sidescreen", true)
    PatchStatsSubtree(Sidescreen and Sidescreen:FindFirstChild("Holder", true))
    PatchStatsSubtree(Sidescreen and Sidescreen:FindFirstChild("Main", true))
    PatchLoadingScreenLabels()
end

local ApplyGuiNameSpoof = function()
    if not (SpoofSettings.NameEnabled and #SpoofSettings.Name > 0) then
        return
    end

    if RealPlayerName == SpoofSettings.Name and RealPlayerDisplayName == SpoofSettings.Name then
        return
    end

    local SafeReplacement = string.gsub(SpoofSettings.Name, "%%", "%%%%")
    local PatternPattern = "([%^%$%(%)%%%.%[%]%*%+%-%?])"

    local PatchGui = function(Gui)
        if not Gui:IsA("TextLabel") and not Gui:IsA("TextButton") and not Gui:IsA("TextBox") then
            return
        end

        local Text = Gui.Text

        if type(Text) ~= "string" then
            return
        end

        local NewText = Text
        local Found = false

        if RealPlayerName ~= SpoofSettings.Name and string.find(NewText, RealPlayerName, 1, true) then
            NewText = string.gsub(NewText, string.gsub(RealPlayerName, PatternPattern, "%%%1"), SafeReplacement)
            Found = true
        end

        if RealPlayerDisplayName ~= SpoofSettings.Name and RealPlayerDisplayName ~= RealPlayerName and string.find(NewText, RealPlayerDisplayName, 1, true) then
            NewText = string.gsub(NewText, string.gsub(RealPlayerDisplayName, PatternPattern, "%%%1"), SafeReplacement)
            Found = true
        end

        if Found then
            Gui.Text = NewText
        end
    end

    for _, Gui in LocalPlayer.PlayerGui:GetDescendants() do
        PatchGui(Gui)
    end

    local Character = LocalPlayer.Character

    if Character then
        for _, Gui in Character:GetDescendants() do
            PatchGui(Gui)
        end
    end
end

Groups.Spoofers:AddToggle("NameSpoofEnabled", {
    Text = "Name Spoofer",
    Default = false,

    Callback = function(Value)
        SpoofSettings.NameEnabled = Value
        ApplyGuiNameSpoof()
    end,
})

Groups.Spoofers:AddInput("NameSpoofValue", {
    Text = "Spoofed Name",
    Placeholder = "Fake name...",

    Callback = function(Value)
        SpoofSettings.Name = Value
    end,
})

Groups.Spoofers:AddDivider()

Groups.Spoofers:AddToggle("StatsSpoofEnabled", {
    Text = "Stats Spoofer",
    Default = false,

    Callback = function(Value)
        SpoofSettings.StatsEnabled = Value
        ApplySpoofedStats()
        PatchStatsGui()
    end,
})

Groups.Spoofers:AddSlider("StatsKills", {
    Text = "Kills",
    Default = 0,
    Min = 0,
    Max = 99999,
    Rounding = 0,

    Callback = function(Value)
        SpoofSettings.Kills = Value
        ApplySpoofedStats()
    end,
})

Groups.Spoofers:AddSlider("StatsDeaths", {
    Text = "Deaths",
    Default = 0,
    Min = 0,
    Max = 99999,
    Rounding = 0,

    Callback = function(Value)
        SpoofSettings.Deaths = Value
        ApplySpoofedStats()
    end,
})

Groups.Spoofers:AddSlider("StatsLevel", {
    Text = "Level",
    Default = 0,
    Min = 0,
    Max = 999,
    Rounding = 0,

    Callback = function(Value)
        SpoofSettings.Level = Value
        ApplySpoofedStats()
    end,
})

Groups.Spoofers:AddSlider("StatsXP", {
    Text = "XP",
    Default = 0,
    Min = 0,
    Max = 1000000,
    Rounding = 0,

    Callback = function(Value)
        SpoofSettings.XP = Value
        ApplySpoofedStats()
    end,
})

Groups.Spoofers:AddSlider("StatsTime", {
    Text = "Playtime (hours)",
    Default = 0,
    Min = 0,
    Max = 9999,
    Rounding = 0,

    Callback = function(Value)
        SpoofSettings.Time = Value * 60
        ApplySpoofedStats()
    end,
})

LocalPlayer.CharacterAdded:Connect(function()
    ApplyGuiNameSpoof()
end)

LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child)
    if Child.Name == "MenuScreens" or Child.Name == "BaseGui" then
        PatchStatsGui()
        ApplyGuiNameSpoof()
    end
end)

LocalPlayer.ChildAdded:Connect(function(Child)
    if Child.Name == "leaderstats" then
        ApplySpoofedStats()
    end
end)

ApplyGuiNameSpoof()

-- Metamethod Hooks
local OldNamecall
local SpoofNameIndex

OldNamecall = HookMetamethod(game, "__namecall", NewCClosure(function(Self, ...)
    local Method = GetNamecallMethod()
    local Caller = debug.info(3, "f")

    if not Caller or IsExecutorClosure(Caller) then
        SetNamecallMethod(Method)
        return OldNamecall(Self, ...)
    end

    local CallerName = debug.info(3, "n")

    if Self == DataChangeRequest and Method == "InvokeServer" then
        local DataType = ...

        if DataType == "EquipCharacterAsset" or DataType == "EquipOutfit" or DataType == "RandomizeCharacter" or DataType == "ClearCharacter" then
            SetNamecallMethod(Method)
            local Results = table.pack(OldNamecall(Self, ...))

            task.defer(UpdateAppearance)

            return table.unpack(Results, 1, Results.n)
        end
    end

    local Origin, Direction, Params = ...

    if SilentAimSettings.Method == "Raycast" and CallerName == "ProcessShot" and Self == workspace and Method == "Raycast" and typeof(Origin) == "Vector3" and typeof(Direction) == "Vector3" and typeof(Params) == "RaycastParams" then
        local TargetPart = Target()

        if TargetPart then
            local AimPoint = GetTargetAimPoint(TargetPart)

            if SilentAimSettings.Manipulation then
                Origin = AimPoint + SilentAimSettings.Origin
            end

            if SilentAimSettings.Enabled then
                if SilentAimSettings.OriginMethod == "Shootable" then
                    local TargetCharacter = TargetPart.Parent

                    while TargetCharacter and not TargetCharacter:IsA("Model") do
                        TargetCharacter = TargetCharacter.Parent
                    end

                    local Muzzle = GetMuzzle(GetEquippedGun())
                    local CanHit = Muzzle and TargetCharacter and IsVisible(Muzzle, TargetPart, TargetCharacter)

                    if not CanHit then
                        SetNamecallMethod(Method)
                        return OldNamecall(Self, ...)
                    end

                    Origin = Muzzle
                end

                Direction = ApplyAimSpread(AimPoint, Origin)
            end

            if SilentAimSettings.Manipulation then
                Direction = ApplyAimSpread(AimPoint, Origin)
            end

            SetNamecallMethod("Raycast")
            return OldNamecall(Self, Origin, Direction, Params)
        end
    end

    SetNamecallMethod(Method)
    return OldNamecall(Self, ...)
end))

local PlayerMetatable = GetRawMetatable(LocalPlayer)

if PlayerMetatable and typeof(PlayerMetatable.__index) == "function" then
    SpoofNameIndex = HookMetamethod(LocalPlayer, "__index", NewCClosure(function(Self, Key)
        if Self == LocalPlayer and (Key == "Name" or Key == "DisplayName") and SpoofSettings.NameEnabled and #SpoofSettings.Name > 0 then
            return SpoofSettings.Name
        end

        return SpoofNameIndex(Self, Key)
    end))
end

-- Render Loop
local FromRGB = Color3.fromRGB
local FromHSV = Color3.fromHSV
local NewVector2 = Vector2.new
local NewVector3 = Vector3.new

RunService.PreRender:Connect(function()
    local MouseLocation = GetMouseLocation(UserInputService)

    if SilentAimSettings.FOVCircle then
        FOVCircle.Position = MouseLocation
        FOVCircle.Radius = SilentAimSettings.FOV
        FOVCircle.Color = SilentAimSettings.FOVCircleColor
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    local SelectedTarget

    if (AutoShootSettings.Enabled and SilentAimSettings.Enabled) or SilentAimSettings.Snaplines then
        SelectedTarget = Target(MouseLocation)
    end

    if AutoShootSettings.Enabled and SilentAimSettings.Enabled then
        local Now = os.clock()

        if not SelectedTarget then
            AutoShootNextFire = nil
        elseif not AutoShootNextFire then
            AutoShootNextFire = Now + AutoShootCalculateDelay()
        elseif Now >= AutoShootNextFire then
            FireWeapon(AutoShootSettings.Method)
            AutoShootNextFire = Now + AutoShootCalculateDelay()
        end
    else
        AutoShootNextFire = nil
    end

    if SilentAimSettings.Snaplines then
        if SelectedTarget then
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(SelectedTarget.Position)

            if OnScreen then
                Snapline.Color = SilentAimSettings.SnaplineColor
                Snapline.From = NewVector2(MouseLocation.X, MouseLocation.Y)
                Snapline.To = NewVector2(ScreenPosition.X, ScreenPosition.Y)
                Snapline.Visible = true
            else
                Snapline.Visible = false
            end
        else
            Snapline.Visible = false
        end
    end

    local ESPActive = ESPSettings.Enabled
    local ChamsOn = ChamsSettings.Enabled

    if not ESPActive then
        for PlayerName in ESPObjects do
            HideESP(PlayerName)
        end
    end

    local EffectiveBoxColor = ESPSettings.BoxColor
    local EffectiveTracerColor = ESPSettings.TracerColor
    local EffectiveFillColor = ChamsSettings.Color

    if ESPSettings.Rainbow and (ESPActive or ChamsOn) then
        local Rainbow = FromHSV((os.clock() * ESPSettings.RainbowSpeed) % 1, 1, 1)

        EffectiveBoxColor = Rainbow
        EffectiveTracerColor = Rainbow
        EffectiveFillColor = Rainbow
    end

    local CameraPosition = Camera.CFrame.Position
    local FontSize = ESPSettings.FontSize
    local MaxDistance = ESPSettings.MaxDistance
    local RainbowOn = ESPSettings.Rainbow
    local BoundingBoxesOn = ESPSettings.BoundingBoxes
    local IgnoreImmune = ESPSettings.IgnoreImmune
    local ViewportSize = Camera.ViewportSize

    for _, Player in PlayersList do
        if Player == LocalPlayer then
            continue
        end

        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if not Character or not Humanoid or Humanoid.Health <= 0 or (IgnoreImmune and Character:GetAttribute("Immune") == true) then
            if ChamsOn then
                RemoveChamsForPlayer(Player.Name)
            end

            HideESP(Player.Name)
            continue
        end

        if ChamsOn then
            local State = ChamState[Player.Name]
            local NeedsUpdate = RainbowOn or not State or State.Character ~= Character

            if NeedsUpdate then
                ApplyChamsToCharacter(Character, EffectiveFillColor)
            end
        end

        if not ESPActive then
            continue
        end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        local Head = Character:FindFirstChild("Head")

        if not Root or not Head then
            HideESP(Player.Name)
            continue
        end

        local Range = (Root.Position - CameraPosition).Magnitude

        if MaxDistance > 0 and Range > MaxDistance then
            HideESP(Player.Name)
            continue
        end

        local BoxPosition
        local ScreenWidth
        local ScreenHeight
        local CenterX
        local CenterY

        if BoundingBoxesOn then
            local Top, Width, Height = GetScreenBox(Root, BuildBoxCorners(Character, Root))

            if Top then
                BoxPosition = Top
                ScreenWidth = Width
                ScreenHeight = Height
            end
        end

        if not BoxPosition then
            local TopScreen, TopVisible = Camera:WorldToViewportPoint(Head.Position + NewVector3(0, 0.7, 0))
            local BottomScreen, BottomVisible = Camera:WorldToViewportPoint(Root.Position - NewVector3(0, 2.4, 0))

            if not TopVisible or not BottomVisible or TopScreen.Z <= 0 or BottomScreen.Z <= 0 then
                HideESP(Player.Name)
                continue
            end

            ScreenHeight = math.abs(BottomScreen.Y - TopScreen.Y)
            ScreenWidth = ScreenHeight * 0.55
            CenterY = (TopScreen.Y + BottomScreen.Y) / 2
            CenterX = (TopScreen.X + BottomScreen.X) / 2
            BoxPosition = NewVector2(CenterX - ScreenWidth / 2, CenterY - ScreenHeight / 2)
        else
            CenterX = BoxPosition.X + ScreenWidth / 2
            CenterY = BoxPosition.Y + ScreenHeight / 2
        end

        local Objects = GetESPObjects(Player.Name)

        if ESPSettings.Boxes then
            Objects.Square.Color = EffectiveBoxColor
            Objects.Square.Position = BoxPosition
            Objects.Square.Size = NewVector2(ScreenWidth, ScreenHeight)
            Objects.Square.Visible = true
        else
            Objects.Square.Visible = false
        end

        if ESPSettings.Healthbars then
            local BarX = BoxPosition.X - 5
            local HealthFraction = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)

            Objects.BarBackground.Position = NewVector2(BarX, BoxPosition.Y)
            Objects.BarBackground.Size = NewVector2(2, ScreenHeight)
            Objects.BarBackground.Visible = true

            Objects.BarFill.Color = FromRGB(
                math.floor(255 * (1 - HealthFraction)),
                math.floor(255 * HealthFraction),
                0
            )
            Objects.BarFill.Position = NewVector2(BarX, BoxPosition.Y + ScreenHeight * (1 - HealthFraction))
            Objects.BarFill.Size = NewVector2(2, math.max(1, ScreenHeight * HealthFraction))
            Objects.BarFill.Visible = true

            Objects.BarOutline.Position = NewVector2(BarX - 1, BoxPosition.Y - 1)
            Objects.BarOutline.Size = NewVector2(4, ScreenHeight + 2)
            Objects.BarOutline.Visible = true
        else
            Objects.BarBackground.Visible = false
            Objects.BarFill.Visible = false
            Objects.BarOutline.Visible = false
        end

        if ESPSettings.HealthText then
            Objects.HealthText.Color = ESPSettings.TextColor
            Objects.HealthText.Text = string.format("%.1f", Humanoid.Health)
            Objects.HealthText.Size = FontSize
            Objects.HealthText.Center = false
            Objects.HealthText.Position = NewVector2(BoxPosition.X - 11, BoxPosition.Y + ScreenHeight / 2)
            Objects.HealthText.Visible = true
        else
            Objects.HealthText.Center = true
            Objects.HealthText.Visible = false
        end

        if ESPSettings.Tracers then
            Objects.Tracer.Color = EffectiveTracerColor
            Objects.Tracer.From = NewVector2(CenterX, BoxPosition.Y + ScreenHeight)
            Objects.Tracer.To = NewVector2(ViewportSize.X / 2, ViewportSize.Y)
            Objects.Tracer.Visible = true
        else
            Objects.Tracer.Visible = false
        end

        if ESPSettings.Names then
            Objects.Name.Color = ESPSettings.TextColor
            Objects.Name.Text = Player.Name
            Objects.Name.Size = FontSize
            Objects.Name.Position = NewVector2(CenterX, BoxPosition.Y - 16)
            Objects.Name.Visible = true
        else
            Objects.Name.Visible = false
        end

        if ESPSettings.Distances then
            Objects.Distance.Color = ESPSettings.TextColor
            Objects.Distance.Text = `{math.floor(Range)}m`
            Objects.Distance.Size = FontSize
            Objects.Distance.Position = NewVector2(CenterX, BoxPosition.Y + ScreenHeight + 3)
            Objects.Distance.Visible = true
        else
            Objects.Distance.Visible = false
        end

        if ESPSettings.Weapons then
            local CurrentTool = Character:FindFirstChildOfClass("Tool")

            if not CurrentTool then
                local Backpack = Player.Backpack

                if Backpack then
                    CurrentTool = Backpack:FindFirstChildOfClass("Tool")
                end
            end

            if CurrentTool then
                Objects.Weapon.Color = ESPSettings.TextColor
                Objects.Weapon.Text = CurrentTool.Name
                Objects.Weapon.Size = FontSize
                Objects.Weapon.Position = NewVector2(CenterX, BoxPosition.Y + ScreenHeight + 19)
                Objects.Weapon.Visible = true
            else
                Objects.Weapon.Visible = false
            end
        else
            Objects.Weapon.Visible = false
        end
    end
end)

-- Watchers
local PendingSync = false

local RequestUpdate = function()
    if PendingSync then
        return
    end

    PendingSync = true

    task.defer(function()
        PendingSync = false
        UpdateAppearance()
    end)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid", 10)

    if Humanoid then
        task.wait(0.1)
        ApplyCosmetics(Character)
    end
end)

local FolderNames = { "Face", "Head", "Back", "Shirt", "Pants" }
local ItemRootName = "ACCESORYITEMS"

local WatchAccessoryFolder = function(Folder)
    for _, FolderName in FolderNames do
        local SubFolder = Folder:FindFirstChild(FolderName)

        if SubFolder then
            SubFolder.ChildAdded:Connect(RequestUpdate)
        else
            Folder.ChildAdded:Connect(function(Child)
                if Child.Name == FolderName then
                    Child.ChildAdded:Connect(RequestUpdate)
                    RequestUpdate()
                end
            end)
        end
    end
end

local WatchItemRoot = function()
    local ItemRoot = ReplicatedStorage:FindFirstChild(ItemRootName)

    if ItemRoot then
        Accessories = ItemRoot
        WatchAccessoryFolder(ItemRoot)
        RequestUpdate()
    end
end

ReplicatedStorage.ChildAdded:Connect(function(Child)
    if Child.Name == ItemRootName then
        WatchItemRoot()
    end
end)

WatchItemRoot()
