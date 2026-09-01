-- tung ate 67
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if getgenv().imRunning then
    getgenv().imRunning = false
    task.wait(0.2)
end
getgenv().imRunning = true
getgenv().SilentAim = false
getgenv().WallCheck = false
getgenv().TargetTracer = false
getgenv().DrawFOV = false
getgenv().FOV_RADIUS = 150
getgenv().Wallbang = false
getgenv().AutoShoot = false
getgenv().Master_ESP = false
getgenv().ESP_Boxes = false
getgenv().ESP_Names = false
getgenv().ESP_Distances = false
getgenv().ESP_Highlights = false
getgenv().BoxColor = Color3.fromRGB(255, 255, 255)
getgenv().NameColor = Color3.fromRGB(255, 255, 255)
getgenv().DistanceColor = Color3.fromRGB(255, 255, 255)
getgenv().ChamsFillColor = Color3.fromRGB(255, 0, 0)
getgenv().ChamsOutlineColor = Color3.fromRGB(255, 255, 255)
getgenv().FOVColor = Color3.fromRGB(255, 255, 255)
getgenv().TracerColor = Color3.fromRGB(255, 255, 255)

local t1 = {
    value4 = UserInputService,
    value5 = Workspace,
    value6 = Camera,
    value7 = LocalPlayer,
    value8 = nil
}

local MAX_DISTANCE = 1000
local activeConnections = {}
local activeDrawings = {}

local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(activeConnections, connection)
    return connection
end

local function TrackDrawing(obj)
    table.insert(activeDrawings, obj)
    return obj
end

local FOV_Outer = TrackDrawing(Drawing.new("Circle"))
local FOV_Main = TrackDrawing(Drawing.new("Circle"))
local FOV_Inner = TrackDrawing(Drawing.new("Circle"))

FOV_Outer.Thickness = 1
FOV_Outer.Color = Color3.new(0, 0, 0)
FOV_Outer.Filled = false

FOV_Main.Thickness = 1
FOV_Main.Filled = false

FOV_Inner.Thickness = 1
FOV_Inner.Color = Color3.new(0, 0, 0)
FOV_Inner.Filled = false

local TracerLineOutline = TrackDrawing(Drawing.new("Line"))
TracerLineOutline.Thickness = 3
TracerLineOutline.Color = Color3.new(0, 0, 0)
TracerLineOutline.Visible = false

local TracerLine = TrackDrawing(Drawing.new("Line"))
TracerLine.Thickness = 1
TracerLine.Color = Color3.fromRGB(255, 255, 255)
TracerLine.Visible = false

Library.ShowToggleFrameInKeybinds = true

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
    Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
}
Tabs.Main:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})
local CombatGroup = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Combat",
    IconName = "swords",
})

local VisualsGroup = Tabs.Main:AddGroupbox({
    Side = "Right",
    Name = "Visuals",
    IconName = "eye",
})
CombatGroup:AddDivider("Silent Aim")
CombatGroup:AddToggle("SilentAim", {
    Text = "Enabled",
    Default = false,
})

Toggles.SilentAim:OnChanged(function()
    getgenv().SilentAim = Toggles.SilentAim.Value
end)

CombatGroup:AddToggle("WallCheck", {
    Text = "Wall Check",
    Default = false,
})

Toggles.WallCheck:OnChanged(function()
    getgenv().WallCheck = Toggles.WallCheck.Value
end)

CombatGroup:AddToggle("TargetTracer", {
    Text = "Target Tracer",
    Default = false,
}):AddColorPicker("TracerColorPicker", {
    Default = getgenv().TracerColor,
    Title = "Tracer Color",
    Callback = function(Value)
        getgenv().TracerColor = Value
    end,
})

Toggles.TargetTracer:OnChanged(function()
    getgenv().TargetTracer = Toggles.TargetTracer.Value
end)
CombatGroup:AddDivider()
CombatGroup:AddToggle("DrawFOV", {
    Text = "Draw FOV",
    Default = false,
}):AddColorPicker("FOVColorPicker", {
    Default = getgenv().FOVColor,
    Title = "FOV Color",
    Callback = function(Value)
        getgenv().FOVColor = Value
    end,
})

Toggles.DrawFOV:OnChanged(function()
    getgenv().DrawFOV = Toggles.DrawFOV.Value
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
    getgenv().FOV_RADIUS = Options.FOVSize.Value
end)
CombatGroup:AddDivider("Misc")
CombatGroup:AddToggle("Wallbang", {
    Text = "Wallbang",
    Default = false,
})

Toggles.Wallbang:OnChanged(function()
    getgenv().Wallbang = Toggles.Wallbang.Value
end)

CombatGroup:AddToggle("AutoShoot", {
    Text = "Auto Shoot",
    Default = false,
})

Toggles.AutoShoot:OnChanged(function()
    getgenv().AutoShoot = Toggles.AutoShoot.Value
end)
VisualsGroup:AddDivider("ESP")
VisualsGroup:AddToggle("Master_ESP", {
    Text = "Enable",
    Default = false,
})

Toggles.Master_ESP:OnChanged(function()
    getgenv().Master_ESP = Toggles.Master_ESP.Value
end)
VisualsGroup:AddDivider("Settings")
VisualsGroup:AddToggle("ESP_Boxes", {
    Text = "Boxes",
    Default = false,
}):AddColorPicker("BoxColorPicker", {
    Default = getgenv().BoxColor,
    Title = "Box Color",
    Callback = function(Value)
        getgenv().BoxColor = Value
    end,
})

Toggles.ESP_Boxes:OnChanged(function()
    getgenv().ESP_Boxes = Toggles.ESP_Boxes.Value
end)

VisualsGroup:AddToggle("ESP_Names", {
    Text = "Names",
    Default = false,
}):AddColorPicker("NameColorPicker", {
    Default = getgenv().NameColor,
    Title = "Name Color",
    Callback = function(Value)
        getgenv().NameColor = Value
    end,
})

Toggles.ESP_Names:OnChanged(function()
    getgenv().ESP_Names = Toggles.ESP_Names.Value
end)

VisualsGroup:AddToggle("ESP_Distances", {
    Text = "Distance",
    Default = false,
}):AddColorPicker("DistanceColorPicker", {
    Default = getgenv().DistanceColor,
    Title = "Distance Color",
    Callback = function(Value)
        getgenv().DistanceColor = Value
    end,
})

Toggles.ESP_Distances:OnChanged(function()
    getgenv().ESP_Distances = Toggles.ESP_Distances.Value
end)

VisualsGroup:AddToggle("ESP_Highlights", {
    Text = "Chams",
    Default = false,
}):AddColorPicker("ChamsFillPicker", {
    Default = getgenv().ChamsFillColor,
    Title = "Chams Fill",
    Callback = function(Value)
        getgenv().ChamsFillColor = Value
    end,
}):AddColorPicker("ChamsOutlinePicker", {
    Default = getgenv().ChamsOutlineColor,
    Title = "Chams Outline",
    Callback = function(Value)
        getgenv().ChamsOutlineColor = Value
    end,
})

Toggles.ESP_Highlights:OnChanged(function()
    getgenv().ESP_Highlights = Toggles.ESP_Highlights.Value
end)

local function getCharacterBounds(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreenAny = false

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local cframe, size = part.CFrame, part.Size
            local halfSize = size / 2

            local vertices = {
                cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
                cframe * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
                cframe * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
                cframe * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
                cframe * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z)
            }

            for _, vertex in ipairs(vertices) do
                local screenPos, onScreen = Camera:WorldToViewportPoint(vertex)
                if onScreen then
                    onScreenAny = true
                    if screenPos.X < minX then minX = screenPos.X end
                    if screenPos.X > maxX then maxX = screenPos.X end
                    if screenPos.Y < minY then minY = screenPos.Y end
                    if screenPos.Y > maxY then maxY = screenPos.Y end
                end
            end
        end
    end
    return onScreenAny, Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local function applyHighlight(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("GetReal")
        if getgenv().Master_ESP and getgenv().ESP_Highlights then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "GetReal"
                highlight.Adornee = player.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = player.Character
            end
            highlight.FillColor = getgenv().ChamsFillColor
            highlight.OutlineColor = getgenv().ChamsOutlineColor
        else
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

local function createESP(player)
    if player == LocalPlayer then return end

    local boxOuter = TrackDrawing(Drawing.new("Square"))
    local boxMain = TrackDrawing(Drawing.new("Square"))
    local boxInner = TrackDrawing(Drawing.new("Square"))

    boxOuter.Color = Color3.new(0, 0, 0)
    boxOuter.Thickness = 1
    boxOuter.Filled = false

    boxMain.Thickness = 1
    boxMain.Filled = false

    boxInner.Color = Color3.new(0, 0, 0)
    boxInner.Thickness = 1
    boxInner.Filled = false

    local nameText = TrackDrawing(Drawing.new("Text"))
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true

    local distText = TrackDrawing(Drawing.new("Text"))
    distText.Size = 13
    distText.Center = true
    distText.Outline = true

    local function clearAllVisibility()
        boxOuter.Visible = false
        boxMain.Visible = false
        boxInner.Visible = false
        nameText.Visible = false
        distText.Visible = false
    end

    local connection
    connection = SafeConnect(RunService.RenderStepped, function()
        if not getgenv().imRunning then
            clearAllVisibility()
            connection:Disconnect()
            return
        end

        local character = player.Character
        local myCharacter = LocalPlayer.Character
        
        if not character or not character:IsDescendantOf(workspace) or not myCharacter then
            clearAllVisibility()
            if not player:IsDescendantOf(Players) then
                boxOuter:Remove()
                boxMain:Remove()
                boxInner:Remove()
                nameText:Remove()
                distText:Remove()
                connection:Disconnect()
            end
            return
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local myRootPart = myCharacter:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        applyHighlight(player)

        if rootPart and myRootPart and humanoid and humanoid.Health > 0 and getgenv().Master_ESP then
            local distance = (myRootPart.Position - rootPart.Position).Magnitude
            if distance > MAX_DISTANCE then
                clearAllVisibility()
                return
            end

            local isValid, topLeft, bottomRight = getCharacterBounds(character)
            if isValid then
                local boxWidth = bottomRight.X - topLeft.X
                local boxHeight = bottomRight.Y - topLeft.Y

                if getgenv().ESP_Boxes then
                    boxMain.Size = Vector2.new(boxWidth, boxHeight)
                    boxMain.Position = topLeft
                    boxMain.Color = getgenv().BoxColor
                    boxMain.Visible = true

                    boxOuter.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
                    boxOuter.Position = topLeft - Vector2.new(1, 1)
                    boxOuter.Visible = true

                    boxInner.Size = Vector2.new(boxWidth - 2, boxHeight - 2)
                    boxInner.Position = topLeft + Vector2.new(1, 1)
                    boxInner.Visible = true
                else
                    boxMain.Visible = false
                    boxOuter.Visible = false
                    boxInner.Visible = false
                end

                local currentOffset = 2

                if getgenv().ESP_Names then
                    nameText.Text = player.Name
                    nameText.Color = getgenv().NameColor
                    nameText.Position = Vector2.new(topLeft.X + (boxWidth / 2), bottomRight.Y + currentOffset)
                    nameText.Visible = true
                    currentOffset = currentOffset + 14
                else
                    nameText.Visible = false
                end

                if getgenv().ESP_Distances then
                    distText.Text = math.round(distance) .. " meters"
                    distText.Color = getgenv().DistanceColor
                    distText.Position = Vector2.new(topLeft.X + (boxWidth / 2), bottomRight.Y + currentOffset)
                    distText.Visible = true
                else
                    distText.Visible = false
                end
            else
                clearAllVisibility()
            end
        else
            clearAllVisibility()
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
SafeConnect(Players.PlayerAdded, createESP)

function t1.value10(p6, p7)
    if getgenv().Wallbang then
        return true 
    end
    local CFramePosition = t1.value6.CFrame.Position
    local v24 = p6.Position - CFramePosition
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {t1.value7.Character, p7, t1.value6}
    raycastParams.IgnoreWater = true
    return t1.value5:Raycast(CFramePosition, v24, raycastParams) == nil
end

SafeConnect(RunService.RenderStepped, function()
    if not getgenv().imRunning then return end

    local currentMousePos = t1.value4:GetMouseLocation()

    if getgenv().DrawFOV then
        FOV_Main.Radius = getgenv().FOV_RADIUS
        FOV_Main.Position = currentMousePos
        FOV_Main.Color = getgenv().FOVColor
        FOV_Main.Visible = true

        FOV_Outer.Radius = getgenv().FOV_RADIUS + 1
        FOV_Outer.Position = currentMousePos
        FOV_Outer.Visible = true

        FOV_Inner.Radius = getgenv().FOV_RADIUS - 1
        FOV_Inner.Position = currentMousePos
        FOV_Inner.Visible = true
    else
        FOV_Main.Visible = false
        FOV_Outer.Visible = false
        FOV_Inner.Visible = false
    end

    if getgenv().SilentAim then
        local targetNode = nil
        local shortestDistance = math.huge
        local characterFolder = t1.value5:FindFirstChild("Characters")
        local structuralTargets = characterFolder and characterFolder:GetChildren() or t1.value5:GetChildren()
        local myChar = t1.value7.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
        
        if myRoot then
            for _, v in ipairs(structuralTargets) do
                if v:IsA("Model") and v ~= myChar then
                    local Humanoid = v:FindFirstChildOfClass("Humanoid")
                    if Humanoid and Humanoid.Health > 0 then
                        local mySide = t1.value7:GetAttribute("MatchSide")
                        local enemySide = v:GetAttribute("MatchSide")
                        
                        if mySide and enemySide and mySide == enemySide then
                            if v:GetAttribute("BotMatchBot") ~= true and v:GetAttribute("Decoy") ~= true then
                                continue
                            end
                        end
                        
                        local structuralPart = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart")
                        if structuralPart then
                            local screenPos, onScreen = t1.value6:WorldToViewportPoint(structuralPart.Position)
                            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - currentMousePos).Magnitude
                            
                            if (onScreen or getgenv().Wallbang) and mouseDist <= getgenv().FOV_RADIUS then
                                local isVisible = t1.value10(structuralPart, v)
                                if not getgenv().WallCheck or isVisible then
                                    local worldDist = (structuralPart.Position - myRoot.Position).Magnitude
                                    if worldDist < shortestDistance then
                                        shortestDistance = worldDist
                                        targetNode = structuralPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        t1.value8 = targetNode 
    else
        t1.value8 = nil
    end

    if getgenv().TargetTracer and t1.value8 then
        local screenPos, onScreen = t1.value6:WorldToViewportPoint(t1.value8.Position)
        if onScreen then
            local originPos
            if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
                originPos = Vector2.new(t1.value6.ViewportSize.X / 2, t1.value6.ViewportSize.Y)
            else
                originPos = currentMousePos
            end
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)

            TracerLineOutline.From = originPos
            TracerLineOutline.To = targetPos
            TracerLineOutline.Visible = true

            TracerLine.From = originPos
            TracerLine.To = targetPos
            TracerLine.Color = getgenv().TracerColor
            TracerLine.Visible = true
        else
            TracerLineOutline.Visible = false
            TracerLine.Visible = false
        end
    else
        TracerLineOutline.Visible = false
        TracerLine.Visible = false
    end
end)

t1.value11 = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local validCaller = not checkcaller()
    local arguments = {...}

    if validCaller and getgenv().imRunning and getgenv().SilentAim and t1.value8 then
        local dataPacket = arguments[1]
        if type(dataPacket) == "table" then
            if method == "FireServer" then
                if self.Name == "ThrowReplicate" then
                    dataPacket.target = t1.value8.Position
                    return t1.value11(self, unpack(arguments))
                elseif self.Name == "ShootReplicate" then
                    dataPacket.hitInstance = t1.value8
                    dataPacket.hitPos = t1.value8.Position
                    dataPacket.to = t1.value8.Position
                    dataPacket.isCharacterHit = true
                    
                    if getgenv().Wallbang then
                        dataPacket.origin = t1.value8.Position + Vector3.new(0, 1, 0)
                    end
                    
                    if type(dataPacket.segments) == "table" and #dataPacket.segments > 0 then
                        for _, seg in ipairs(dataPacket.segments) do
                            seg.hitInstance = t1.value8
                            seg.hitPos = t1.value8.Position
                            seg.isCharacterHit = true
                        end
                    end
                    return t1.value11(self, unpack(arguments))
                end
            elseif method == "Fire" then
                if self.Name == "SpawnKnife" then
                    dataPacket.target = t1.value8.Position
                    return t1.value11(self, unpack(arguments))
                elseif self.Name == "SpawnBullet" then
                    dataPacket.hitInstance = t1.value8
                    dataPacket.hitPos = t1.value8.Position
                    dataPacket.to = t1.value8.Position
                    dataPacket.isCharacterHit = true
                    
                    if getgenv().Wallbang then
                        dataPacket.origin = t1.value8.Position + Vector3.new(0, 1, 0)
                    end
                    
                    if type(dataPacket.segments) == "table" and #dataPacket.segments > 0 then
                        for _, seg in ipairs(dataPacket.segments) do
                            seg.hitInstance = t1.value8
                            seg.hitPos = t1.value8.Position
                            seg.isCharacterHit = true
                        end
                    end
                    return t1.value11(self, unpack(arguments))
                end
            end
        end
    end
    return t1.value11(self, ...)
end)

task.spawn(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local GuiService = game:GetService("GuiService")
    
    while getgenv().imRunning and task.wait(0.05) do 
        if getgenv().AutoShoot and getgenv().SilentAim and t1.value8 and not GuiService.MenuIsOpen then
            if t1.value4.MouseBehavior == Enum.MouseBehavior.LockCenter then
                mouse1click()
            end
        end
    end
end)

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

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/murderduels")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    getgenv().imRunning = false
    
    for _, conn in ipairs(activeConnections) do
        if conn.Disconnect then
            conn:Disconnect()
        end
    end
    
    for _, drawing in ipairs(activeDrawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("GetReal")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end)
local DevBox = Tabs.Cont:AddLeftGroupbox("Main", "wrench")
DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">cryp11t</font>] Owner")
DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">ardin6</font>] Developer")
DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">zscriptx</font>] Developer")

local ManBox = Tabs.Cont:AddRightGroupbox("Contributors", "users")
ManBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">aytheman</font>] Server Manager")
ManBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">bv2c</font>] Server Manager")

wait(1)
Library:Notify({
	Title = "Drift",
	Description = "Loaded Succesfully!",
	Time = 5,
})
setclipboard("dsc.gg/getdrift")
Library:Notify({
	Title = "Drift",
	Description = "Copied Discord Link",
	Time = 5,
})
