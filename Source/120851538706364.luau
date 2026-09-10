-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Global State
local Environment = getgenv()

if DriftLoaded then
    Environment.DriftLoaded = false
    task.wait(0.2)
end

Environment.DriftLoaded = true
Environment.SilentAim = false
Environment.WallCheck = false
Environment.TargetTracer = false
Environment.DrawFov = false
Environment.FovRadius = 150
Environment.Wallbang = false
Environment.AutoShoot = false
Environment.MasterEsp = false
Environment.EspBoxes = false
Environment.EspNames = false
Environment.EspDistances = false
Environment.EspHighlights = false
Environment.BoxColor = Color3.fromRGB(255, 255, 255)
Environment.NameColor = Color3.fromRGB(255, 255, 255)
Environment.DistanceColor = Color3.fromRGB(255, 255, 255)
Environment.ChamsFillColor = Color3.fromRGB(255, 0, 0)
Environment.ChamsOutlineColor = Color3.fromRGB(255, 255, 255)
Environment.FovColor = Color3.fromRGB(255, 255, 255)
Environment.TracerColor = Color3.fromRGB(255, 255, 255)

-- Shared Context
local Context = {
    UserInput = UserInputService,
    Workspace = Workspace,
    Camera = Camera,
    LocalPlayer = LocalPlayer,
    TargetNode = nil
}

local MaxDistance = 1000
local ActiveConnections = {}
local ActiveDrawings = {}

-- Connection & Drawing Helpers
local function SafeConnect(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(ActiveConnections, Connection)
    return Connection
end

local function TrackDrawing(DrawingObject)
    table.insert(ActiveDrawings, DrawingObject)
    return DrawingObject
end

-- FOV Circles
local FovOuter = TrackDrawing(Drawing.new("Circle"))
local FovMain = TrackDrawing(Drawing.new("Circle"))
local FovInner = TrackDrawing(Drawing.new("Circle"))

FovOuter.Thickness = 1
FovOuter.Color = Color3.new(0, 0, 0)
FovOuter.Filled = false

FovMain.Thickness = 1
FovMain.Filled = false

FovInner.Thickness = 1
FovInner.Color = Color3.new(0, 0, 0)
FovInner.Filled = false

-- Tracer Lines
local TracerLineOutline = TrackDrawing(Drawing.new("Line"))
TracerLineOutline.Thickness = 3
TracerLineOutline.Color = Color3.new(0, 0, 0)
TracerLineOutline.Visible = false

local TracerLine = TrackDrawing(Drawing.new("Line"))
TracerLine.Thickness = 1
TracerLine.Color = Color3.fromRGB(255, 255, 255)
TracerLine.Visible = false

Library.ShowToggleFrameInKeybinds = true

-- Window & Tabs
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Murder Duels",
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
    Main = Window:AddTab("Main", "house", "Main features"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings", "Customize the Interface"),
    Credits = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
}

Tabs.Main:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})

-- Combat Group
local CombatGroup = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Combat",
    IconName = "swords",
})

CombatGroup:AddDivider("Silent Aim")

CombatGroup:AddToggle("SilentAim", {
    Text = "Enabled",
    Default = false,
})

Toggles.SilentAim:OnChanged(function()
    Environment.SilentAim = Toggles.SilentAim.Value
end)

CombatGroup:AddToggle("WallCheck", {
    Text = "Wall Check",
    Default = false,
})

Toggles.WallCheck:OnChanged(function()
    Environment.WallCheck = Toggles.WallCheck.Value
end)

CombatGroup:AddToggle("TargetTracer", {
    Text = "Target Tracer",
    Default = false,
}):AddColorPicker("TracerColorPicker", {
    Default = TracerColor,
    Title = "Tracer Color",
    Callback = function(Value)
        Environment.TracerColor = Value
    end,
})

Toggles.TargetTracer:OnChanged(function()
    Environment.TargetTracer = Toggles.TargetTracer.Value
end)

CombatGroup:AddDivider()

CombatGroup:AddToggle("DrawFOV", {
    Text = "Draw FOV",
    Default = false,
}):AddColorPicker("FOVColorPicker", {
    Default = FovColor,
    Title = "FOV Color",
    Callback = function(Value)
        Environment.FovColor = Value
    end,
})

Toggles.DrawFOV:OnChanged(function()
    Environment.DrawFov = Toggles.DrawFOV.Value
end)

CombatGroup:AddSlider("FOVSize", {
    Text = "FOV Size",
    Default = 150,
    Min = 10,
    Max = 800,
    Rounding = 0,
    Compact = false,
})

Options.FOVSize:OnChanged(function()
    Environment.FovRadius = Options.FOVSize.Value
end)

CombatGroup:AddDivider("Misc")

CombatGroup:AddToggle("Wallbang", {
    Text = "Wallbang",
    Default = false,
})

Toggles.Wallbang:OnChanged(function()
    Environment.Wallbang = Toggles.Wallbang.Value
end)

CombatGroup:AddToggle("AutoShoot", {
    Text = "Auto Shoot",
    Default = false,
})

Toggles.AutoShoot:OnChanged(function()
    Environment.AutoShoot = Toggles.AutoShoot.Value
end)

-- Visuals Group
local VisualsGroup = Tabs.Main:AddGroupbox({
    Side = "Right",
    Name = "Visuals",
    IconName = "eye",
})

VisualsGroup:AddDivider("ESP")

VisualsGroup:AddToggle("MasterESP", {
    Text = "Enable",
    Default = false,
})

Toggles.MasterESP:OnChanged(function()
    Environment.MasterEsp = Toggles.MasterESP.Value
end)

VisualsGroup:AddDivider("Settings")

VisualsGroup:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = false,
}):AddColorPicker("BoxColorPicker", {
    Default = BoxColor,
    Title = "Box Color",
    Callback = function(Value)
        Environment.BoxColor = Value
    end,
})

Toggles.ESPBoxes:OnChanged(function()
    Environment.EspBoxes = Toggles.ESPBoxes.Value
end)

VisualsGroup:AddToggle("ESPNames", {
    Text = "Names",
    Default = false,
}):AddColorPicker("NameColorPicker", {
    Default = NameColor,
    Title = "Name Color",
    Callback = function(Value)
        Environment.NameColor = Value
    end,
})

Toggles.ESPNames:OnChanged(function()
    Environment.EspNames = Toggles.ESPNames.Value
end)

VisualsGroup:AddToggle("ESPDistances", {
    Text = "Distance",
    Default = false,
}):AddColorPicker("DistanceColorPicker", {
    Default = DistanceColor,
    Title = "Distance Color",
    Callback = function(Value)
        Environment.DistanceColor = Value
    end,
})

Toggles.ESPDistances:OnChanged(function()
    Environment.EspDistances = Toggles.ESPDistances.Value
end)

VisualsGroup:AddToggle("ESPHighlights", {
    Text = "Chams",
    Default = false,
}):AddColorPicker("ChamsFillPicker", {
    Default = ChamsFillColor,
    Title = "Chams Fill",
    Callback = function(Value)
        Environment.ChamsFillColor = Value
    end,
}):AddColorPicker("ChamsOutlinePicker", {
    Default = ChamsOutlineColor,
    Title = "Chams Outline",
    Callback = function(Value)
        Environment.ChamsOutlineColor = Value
    end,
})

Toggles.ESPHighlights:OnChanged(function()
    Environment.EspHighlights = Toggles.ESPHighlights.Value
end)

-- ESP Utilities
local function FindCharacterBounds(Character)
    local MinX, MinY = math.huge, math.huge
    local MaxX, MaxY = -math.huge, -math.huge
    local IsOnScreen = false

    for _, Part in Character:QueryDescendants("> BasePart") do
        local HalfSize = Part.Size / 2
        local PartCFrame = Part.CFrame

        local Vertices = {
            PartCFrame * Vector3.new(-HalfSize.X, -HalfSize.Y, -HalfSize.Z),
            PartCFrame * Vector3.new(HalfSize.X, -HalfSize.Y, -HalfSize.Z),
            PartCFrame * Vector3.new(-HalfSize.X, HalfSize.Y, -HalfSize.Z),
            PartCFrame * Vector3.new(HalfSize.X, HalfSize.Y, -HalfSize.Z),
            PartCFrame * Vector3.new(-HalfSize.X, -HalfSize.Y, HalfSize.Z),
            PartCFrame * Vector3.new(HalfSize.X, -HalfSize.Y, HalfSize.Z),
            PartCFrame * Vector3.new(-HalfSize.X, HalfSize.Y, HalfSize.Z),
            PartCFrame * Vector3.new(HalfSize.X, HalfSize.Y, HalfSize.Z)
        }

        for _, Vertex in Vertices do
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Vertex)
            if not OnScreen then
                continue
            end

            IsOnScreen = true
            if ScreenPosition.X < MinX then MinX = ScreenPosition.X end
            if ScreenPosition.X > MaxX then MaxX = ScreenPosition.X end
            if ScreenPosition.Y < MinY then MinY = ScreenPosition.Y end
            if ScreenPosition.Y > MaxY then MaxY = ScreenPosition.Y end
        end
    end

    return IsOnScreen, Vector2.new(MinX, MinY), Vector2.new(MaxX, MaxY)
end

local function ApplyHighlight(Player)
    if not Player.Character then
        return
    end

    local Highlight = Player.Character:FindFirstChild("GetReal")

    if MasterEsp and EspHighlights then
        if not Highlight then
            Highlight = Instance.new("Highlight")
            Highlight.Name = "GetReal"
            Highlight.Adornee = Player.Character
            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            Highlight.Parent = Player.Character
        end

        Highlight.FillColor = ChamsFillColor
        Highlight.OutlineColor = ChamsOutlineColor
    else
        if Highlight then
            Highlight:Destroy()
        end
    end
end

-- ESP Per-Player
local function CreateEsp(Player)
    if Player == LocalPlayer then
        return
    end

    local BoxOuter = TrackDrawing(Drawing.new("Square"))
    local BoxMain = TrackDrawing(Drawing.new("Square"))
    local BoxInner = TrackDrawing(Drawing.new("Square"))

    BoxOuter.Color = Color3.new(0, 0, 0)
    BoxOuter.Thickness = 1
    BoxOuter.Filled = false

    BoxMain.Thickness = 1
    BoxMain.Filled = false

    BoxInner.Color = Color3.new(0, 0, 0)
    BoxInner.Thickness = 1
    BoxInner.Filled = false

    local NameText = TrackDrawing(Drawing.new("Text"))
    NameText.Size = 13
    NameText.Center = true
    NameText.Outline = true

    local DistText = TrackDrawing(Drawing.new("Text"))
    DistText.Size = 13
    DistText.Center = true
    DistText.Outline = true

    local function ClearAllVisibility()
        BoxOuter.Visible = false
        BoxMain.Visible = false
        BoxInner.Visible = false
        NameText.Visible = false
        DistText.Visible = false
    end

    local Connection
    Connection = SafeConnect(RunService.RenderStepped, function()
        if not DriftLoaded then
            ClearAllVisibility()
            Connection:Disconnect()
            return
        end

        local Character = Player.Character
        local MyCharacter = LocalPlayer.Character

        if not Character or not Character:IsDescendantOf(Workspace) or not MyCharacter then
            ClearAllVisibility()
            if not Player:IsDescendantOf(Players) then
                BoxOuter:Remove()
                BoxMain:Remove()
                BoxInner:Remove()
                NameText:Remove()
                DistText:Remove()
                Connection:Disconnect()
            end
            return
        end

        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local MyRootPart = MyCharacter:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        ApplyHighlight(Player)

        if not RootPart or not MyRootPart or not Humanoid then
            ClearAllVisibility()
            return
        end

        if Humanoid.Health <= 0 or not MasterEsp then
            ClearAllVisibility()
            return
        end

        local Distance = (MyRootPart.Position - RootPart.Position).Magnitude

        if Distance > MaxDistance then
            ClearAllVisibility()
            return
        end

        local IsValid, TopLeft, BottomRight = FindCharacterBounds(Character)

        if not IsValid then
            ClearAllVisibility()
            return
        end

        local BoxWidth = BottomRight.X - TopLeft.X
        local BoxHeight = BottomRight.Y - TopLeft.Y

        if EspBoxes then
            BoxMain.Size = Vector2.new(BoxWidth, BoxHeight)
            BoxMain.Position = TopLeft
            BoxMain.Color = BoxColor
            BoxMain.Visible = true

            BoxOuter.Size = Vector2.new(BoxWidth + 2, BoxHeight + 2)
            BoxOuter.Position = TopLeft - Vector2.new(1, 1)
            BoxOuter.Visible = true

            BoxInner.Size = Vector2.new(BoxWidth - 2, BoxHeight - 2)
            BoxInner.Position = TopLeft + Vector2.new(1, 1)
            BoxInner.Visible = true
        else
            BoxMain.Visible = false
            BoxOuter.Visible = false
            BoxInner.Visible = false
        end

        local CurrentOffset = 2

        if EspNames then
            NameText.Text = Player.Name
            NameText.Color = NameColor
            NameText.Position = Vector2.new(TopLeft.X + (BoxWidth / 2), BottomRight.Y + CurrentOffset)
            NameText.Visible = true
            CurrentOffset = CurrentOffset + 14
        else
            NameText.Visible = false
        end

        if EspDistances then
            DistText.Text = math.round(Distance) .. " meters"
            DistText.Color = DistanceColor
            DistText.Position = Vector2.new(TopLeft.X + (BoxWidth / 2), BottomRight.Y + CurrentOffset)
            DistText.Visible = true
        else
            DistText.Visible = false
        end
    end)
end

-- ESP Initialization
for _, Player in Players:GetPlayers() do
    CreateEsp(Player)
end

SafeConnect(Players.PlayerAdded, CreateEsp)

-- Silent Aim Wall Visibility
local function IsTargetVisible(TargetPart, TargetCharacter)
    if Wallbang then
        return true
    end

    local CameraPosition = Context.Camera.CFrame.Position
    local RayDirection = TargetPart.Position - CameraPosition

    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParams.FilterDescendantsInstances = {Context.LocalPlayer.Character, TargetCharacter, Context.Camera}
    RaycastParams.IgnoreWater = true

    return Context.Workspace:Raycast(CameraPosition, RayDirection, RaycastParams) == nil
end

-- Main Render Loop
SafeConnect(RunService.RenderStepped, function()
    if not DriftLoaded then
        return
    end

    local CurrentMousePosition = Context.UserInput:GetMouseLocation()

    -- FOV Circle Rendering
    if DrawFov then
        FovMain.Radius = FovRadius
        FovMain.Position = CurrentMousePosition
        FovMain.Color = FovColor
        FovMain.Visible = true

        FovOuter.Radius = FovRadius + 1
        FovOuter.Position = CurrentMousePosition
        FovOuter.Visible = true

        FovInner.Radius = FovRadius - 1
        FovInner.Position = CurrentMousePosition
        FovInner.Visible = true
    else
        FovMain.Visible = false
        FovOuter.Visible = false
        FovInner.Visible = false
    end

    -- Silent Aim Target Selection
    if SilentAim then
        local TargetNode = nil
        local ShortestDistance = math.huge
        local CharacterFolder = Context.Workspace:FindFirstChild("Characters")
        local StructuralTargets = CharacterFolder and CharacterFolder:QueryDescendants("> Instance") or Context.Workspace:QueryDescendants("> Instance")
        local MyCharacter = Context.LocalPlayer.Character
        local MyRoot = MyCharacter and (MyCharacter:FindFirstChild("HumanoidRootPart") or MyCharacter:FindFirstChild("Head"))

        if not MyRoot then
            Context.TargetNode = nil
        else
            for _, Candidate in StructuralTargets do
                if not Candidate:IsA("Model") or Candidate == MyCharacter then
                    continue
                end

                local CandidateHumanoid = Candidate:FindFirstChildOfClass("Humanoid")
                if not CandidateHumanoid or CandidateHumanoid.Health <= 0 then
                    continue
                end

                local MySide = Context.LocalPlayer:GetAttribute("MatchSide")
                local EnemySide = Candidate:GetAttribute("MatchSide")

                if MySide and EnemySide and MySide == EnemySide then
                    if Candidate:GetAttribute("BotMatchBot") ~= true and Candidate:GetAttribute("Decoy") ~= true then
                        continue
                    end
                end

                local StructuralPart = Candidate:FindFirstChild("Head") or Candidate:FindFirstChild("HumanoidRootPart")
                if not StructuralPart then
                    continue
                end

                local ScreenPosition, OnScreen = Context.Camera:WorldToViewportPoint(StructuralPart.Position)
                local MouseDistance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - CurrentMousePosition).Magnitude

                if not (OnScreen or Wallbang) then
                    continue
                end

                if MouseDistance > FovRadius then
                    continue
                end

                local IsVisible = IsTargetVisible(StructuralPart, Candidate)
                if not WallCheck or IsVisible then
                    local WorldDistance = (StructuralPart.Position - MyRoot.Position).Magnitude
                    if WorldDistance < ShortestDistance then
                        ShortestDistance = WorldDistance
                        TargetNode = StructuralPart
                    end
                end
            end

            Context.TargetNode = TargetNode
        end
    else
        Context.TargetNode = nil
    end

    -- Target Tracer Rendering
    if TargetTracer and Context.TargetNode then
        local ScreenPosition, OnScreen = Context.Camera:WorldToViewportPoint(Context.TargetNode.Position)

        if not OnScreen then
            TracerLineOutline.Visible = false
            TracerLine.Visible = false
        else
            local OriginPosition
            if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
                OriginPosition = Vector2.new(Context.Camera.ViewportSize.X / 2, Context.Camera.ViewportSize.Y)
            else
                OriginPosition = CurrentMousePosition
            end

            local TargetScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)

            TracerLineOutline.From = OriginPosition
            TracerLineOutline.To = TargetScreenPosition
            TracerLineOutline.Visible = true

            TracerLine.From = OriginPosition
            TracerLine.To = TargetScreenPosition
            TracerLine.Color = TracerColor
            TracerLine.Visible = true
        end
    else
        TracerLineOutline.Visible = false
        TracerLine.Visible = false
    end
end)

-- Namecall Hook
local OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local IsValidCaller = not checkcaller()
    local Arguments = {...}

    if not (IsValidCaller and DriftLoaded and SilentAim and Context.TargetNode) then
        return OriginalNamecall(self, ...)
    end

    local DataPacket = Arguments[1]

    if type(DataPacket) ~= "table" then
        return OriginalNamecall(self, ...)
    end

    if Method == "FireServer" then
        if self.Name == "ThrowReplicate" then
            DataPacket.target = Context.TargetNode.Position
            return OriginalNamecall(self, unpack(Arguments))
        end

        if self.Name == "ShootReplicate" then
            DataPacket.hitInstance = Context.TargetNode
            DataPacket.hitPos = Context.TargetNode.Position
            DataPacket.to = Context.TargetNode.Position
            DataPacket.isCharacterHit = true

            if Wallbang then
                DataPacket.origin = Context.TargetNode.Position + Vector3.new(0, 1, 0)
            end

            if type(DataPacket.segments) == "table" and #DataPacket.segments > 0 then
                for _, Segment in DataPacket.segments do
                    Segment.hitInstance = Context.TargetNode
                    Segment.hitPos = Context.TargetNode.Position
                    Segment.isCharacterHit = true
                end
            end

            return OriginalNamecall(self, unpack(Arguments))
        end
    end

    if Method == "Fire" then
        if self.Name == "SpawnKnife" then
            DataPacket.target = Context.TargetNode.Position
            return OriginalNamecall(self, unpack(Arguments))
        end

        if self.Name == "SpawnBullet" then
            DataPacket.hitInstance = Context.TargetNode
            DataPacket.hitPos = Context.TargetNode.Position
            DataPacket.to = Context.TargetNode.Position
            DataPacket.isCharacterHit = true

            if Wallbang then
                DataPacket.origin = Context.TargetNode.Position + Vector3.new(0, 1, 0)
            end

            if type(DataPacket.segments) == "table" and #DataPacket.segments > 0 then
                for _, Segment in DataPacket.segments do
                    Segment.hitInstance = Context.TargetNode
                    Segment.hitPos = Context.TargetNode.Position
                    Segment.isCharacterHit = true
                end
            end

            return OriginalNamecall(self, unpack(Arguments))
        end
    end

    return OriginalNamecall(self, ...)
end)

-- Auto Shoot Loop
task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local GuiService = game:GetService("GuiService")

    while DriftLoaded and task.wait(0.05) do
        if not AutoShoot then
            continue
        end

        if not SilentAim then
            continue
        end

        if not Context.TargetNode then
            continue
        end

        if GuiService.MenuIsOpen then
            continue
        end

        if Context.UserInput.MouseBehavior == Enum.MouseBehavior.LockCenter then
            mouse1click()
        end
    end
end)

-- UI Settings Group
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
    Default = "RightShift",
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

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/murderduels")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- Unload Handler
Library:OnUnload(function()
    Environment.DriftLoaded = false

    for _, Connection in ActiveConnections do
        if Connection.Disconnect then
            Connection:Disconnect()
        end
    end

    for _, DrawingObject in ActiveDrawings do
        pcall(function()
            DrawingObject:Remove()
        end)
    end

    for _, Player in Players:GetPlayers() do
        if not Player.Character then
            continue
        end

        local Highlight = Player.Character:FindFirstChild("GetReal")
        if Highlight then
            Highlight:Destroy()
        end
    end
end)

-- Credits Tab
local ContributorsSource = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local TeamMembers, GameContributors = loadstring(ContributorsSource)()

local TeamGroup = Tabs.Credits:AddLeftGroupbox("Team", "wrench")

for Name, Role in TeamMembers do
    TeamGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Role)
end

local PlaceId = tostring(game.PlaceId)

if GameContributors[PlaceId] then
    local ContributorsGroup = Tabs.Credits:AddRightGroupbox("Contributors", "users")

    for Name, Contribution in GameContributors[PlaceId] do
        ContributorsGroup:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Contribution)
    end
end

-- Loaded Notification
task.wait(1)

Library:Notify({
	Title = "Drift",
	Description = "Loaded Successfully!",
	Time = 5,
})

setclipboard("dsc.gg/getdrift")

Library:Notify({
	Title = "Drift",
	Description = "Copied Discord Link",
	Time = 5,
})
