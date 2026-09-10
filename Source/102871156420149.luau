-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Global State
local Environment = getgenv and getgenv() or shared
if Environment.LostFrontDrawingESP and type(Environment.LostFrontDrawingESP.Unload) == "function" then
    pcall(Environment.LostFrontDrawingESP.Unload)
end
if not Drawing or type(Drawing.new) ~= "function" then
    error("Drawing library is not supported by this executor")
end

-- UI Libraries
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

-- Controller
local Controller = {
    Unloaded = false,
    TeamRegistryFound = false,
    LocalTeam = "unknown",
    SilentTarget = nil,
    SilentTargetKind = nil,
    FastCastHookInstalled = false,
    FastCastCalls = 0,
    SilentRedirects = 0,
    LastSilentTarget = "",
    Connections = {},
    PlayerEntries = {},
    DroneEntries = {},
    Settings = {
        SilentAimEnabled = false,
        SilentAimTeamCheck = false,
        SilentAimVisibilityCheck = false,
        SilentAimPrediction = false,
        SilentAimHitChance = 100,
        SilentAimTargetType = "Players and Drones",
        SilentAimTargetPart = "Head",
        SilentAimMaxDistance = 5000,
        SilentAimFOV = 150,
        SilentAimShowFOV = false,
        SilentAimFOVColor = Color3.fromRGB(255, 255, 255),
        SilentAimFOVThickness = 1,
        SilentAimFOVOpacity = 0.8,
        PlayerEnabled = false,
        PlayerBoxes = false,
        PlayerNames = false,
        PlayerDistance = false,
        PlayerTracers = false,
        ShowTeammates = false,
        PlayerMaxDistance = 5000,
        EnemyColor = Color3.fromRGB(255, 0, 0),
        TeammateColor = Color3.fromRGB(0, 100, 255),
        DroneEnabled = false,
        DroneBoxes = false,
        DroneNames = false,
        DroneTeams = false,
        DroneDistance = false,
        DroneTracers = false,
        DroneRearArrows = false,
        DroneTeamCheck = false,
        ShowOwnDrone = false,
        DroneMaxDistance = 5000,
        FriendlyDroneColor = Color3.fromRGB(0, 100, 255),
        EnemyDroneColor = Color3.fromRGB(255, 0, 0),
        UnknownDroneColor = Color3.fromRGB(255, 210, 70),
        RearArrowRadius = 70,
        RearArrowSize = 11,
        BoxThickness = 1,
        TextSize = 13,
        Opacity = 1
    }
}
Environment.LostFrontDrawingESP = Controller

-- Connection Helpers
local function AddConnection(Connection)
    table.insert(Controller.Connections, Connection)
    return Connection
end

-- Drawing Helpers
local function CreateDrawing(Kind, Properties)
    local Object = Drawing.new(Kind)
    for Property, Value in Properties do
        Object[Property] = Value
    end
    return Object
end

local function RemoveDrawing(Object)
    if not Object then
        return
    end
    pcall(function()
        Object.Visible = false
    end)
    pcall(function()
        if Object.Remove then
            Object:Remove()
        else
            Object:Destroy()
        end
    end)
end

-- FOV Circle
local SilentFOVCircle = CreateDrawing("Circle", {
    Visible = false,
    Filled = false,
    Color = Controller.Settings.SilentAimFOVColor,
    NumSides = 72,
    Radius = Controller.Settings.SilentAimFOV,
    Thickness = Controller.Settings.SilentAimFOVThickness,
    Transparency = Controller.Settings.SilentAimFOVOpacity,
    ZIndex = 5
})
Controller.SilentFOVCircle = SilentFOVCircle

-- Visual Helpers
local function CreateVisual(IncludeRearArrow)
    local Font = Drawing.Fonts and (Drawing.Fonts.Plex or Drawing.Fonts.UI) or 2
    local Visual = {
        Outline = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Color = Color3.new(0, 0, 0),
            Thickness = 3,
            Transparency = 1,
            ZIndex = 1
        }),
        Box = CreateDrawing("Square", {
            Visible = false,
            Filled = false,
            Color = Color3.new(1, 1, 1),
            Thickness = 1,
            Transparency = 1,
            ZIndex = 2
        }),
        Text = CreateDrawing("Text", {
            Visible = false,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Color = Color3.new(1, 1, 1),
            Size = 13,
            Font = Font,
            Transparency = 1,
            ZIndex = 3
        }),
        Tracer = CreateDrawing("Line", {
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Thickness = 1,
            Transparency = 1,
            ZIndex = 2
        })
    }
    if IncludeRearArrow then
        Visual.ArrowTop = CreateDrawing("Line", {
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Thickness = 2,
            Transparency = 1,
            ZIndex = 4
        })
        Visual.ArrowBottom = CreateDrawing("Line", {
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Thickness = 2,
            Transparency = 1,
            ZIndex = 4
        })
    end
    return Visual
end

local function HideVisual(Visual)
    Visual.Outline.Visible = false
    Visual.Box.Visible = false
    Visual.Text.Visible = false
    Visual.Tracer.Visible = false
    if Visual.ArrowTop then
        Visual.ArrowTop.Visible = false
        Visual.ArrowBottom.Visible = false
    end
end

local function RemoveVisual(Visual)
    RemoveDrawing(Visual.Outline)
    RemoveDrawing(Visual.Box)
    RemoveDrawing(Visual.Text)
    RemoveDrawing(Visual.Tracer)
    RemoveDrawing(Visual.ArrowTop)
    RemoveDrawing(Visual.ArrowBottom)
end

-- Anchor & Bounds
local function GetAnchor(Model)
    if not Model or not Model:IsA("Model") then
        return nil
    end
    return Model.PrimaryPart
        or Model:FindFirstChild("HumanoidRootPart")
        or Model:FindFirstChild("Head")
        or Model:FindFirstChildWhichIsA("BasePart", true)
end

local function GetBounds(Model, Camera)
    local Success, BoxCFrame, BoxSize = pcall(Model.GetBoundingBox, Model)
    if not Success or BoxSize.Magnitude <= 0 then
        return nil
    end
    local MinX = math.huge
    local MinY = math.huge
    local MaxX = -math.huge
    local MaxY = -math.huge
    for X = -1, 1, 2 do
        for Y = -1, 1, 2 do
            for Z = -1, 1, 2 do
                local WorldPoint = BoxCFrame:PointToWorldSpace(Vector3.new(
                    BoxSize.X * X * 0.5,
                    BoxSize.Y * Y * 0.5,
                    BoxSize.Z * Z * 0.5
                ))
                local ScreenPoint = Camera:WorldToViewportPoint(WorldPoint)
                if ScreenPoint.Z <= 0 then
                    return nil
                end
                MinX = math.min(MinX, ScreenPoint.X)
                MinY = math.min(MinY, ScreenPoint.Y)
                MaxX = math.max(MaxX, ScreenPoint.X)
                MaxY = math.max(MaxY, ScreenPoint.Y)
            end
        end
    end
    local Viewport = Camera.ViewportSize
    if MaxX < 0 or MaxY < 0 or MinX > Viewport.X or MinY > Viewport.Y then
        return nil
    end
    MinX = math.clamp(MinX, 0, Viewport.X)
    MinY = math.clamp(MinY, 0, Viewport.Y)
    MaxX = math.clamp(MaxX, 0, Viewport.X)
    MaxY = math.clamp(MaxY, 0, Viewport.Y)
    local Width = MaxX - MinX
    local Height = MaxY - MinY
    if Width < 2 or Height < 2 then
        return nil
    end
    return Vector2.new(MinX, MinY), Vector2.new(Width, Height)
end

local function GetDistanceOrigin(Camera)
    local Character = LocalPlayer.Character
    local Anchor = GetAnchor(Character)
    return Anchor and Anchor.Position or Camera.CFrame.Position
end

-- Team Detection
local TeamRegistry
local LastTeamRegistrySearch = 0
local function GetTeamRegistry()
    if TeamRegistry and type(TeamRegistry.players) == "table" then
        return TeamRegistry
    end
    if os.clock() - LastTeamRegistrySearch < 2 then
        return nil
    end
    LastTeamRegistrySearch = os.clock()
    if type(filtergc) ~= "function" then
        return nil
    end
    local Success, Registry = pcall(filtergc, "table", {
        Keys = { "isFriendly", "getclient", "getEnemyTeam", "getPlayer", "players" }
    }, true)
    if not Success or type(Registry) ~= "table" or type(Registry.players) ~= "table" then
        return nil
    end
    TeamRegistry = Registry
    Controller.TeamRegistryFound = true
    local ClientData = Registry.players[LocalPlayer]
    Controller.LocalTeam = ClientData and ClientData.team or "unknown"
    return Registry
end

local function GetPlayerTeamState(Player)
    if not Player then
        return nil, "unknown"
    end
    local Registry = GetTeamRegistry()
    if Registry then
        local ClientData = Registry.players[LocalPlayer]
        local PlayerData = Registry.players[Player]
        if ClientData and PlayerData and ClientData.team and PlayerData.team then
            return ClientData.team == PlayerData.team, tostring(PlayerData.team)
        end
    end
    if Player == LocalPlayer then
        return true, "ally"
    end
    if LocalPlayer.Team and Player.Team then
        return LocalPlayer.Team == Player.Team, Player.Team.Name
    end
    local LocalCharacter = LocalPlayer.Character
    local Character = Player.Character
    if not LocalCharacter or not Character then
        return nil, "unknown"
    end
    local LocalContainer = LocalCharacter.Parent
    local TargetContainer = Character.Parent
    if not LocalContainer or not TargetContainer or LocalContainer == Workspace or TargetContainer == Workspace then
        return nil, "unknown"
    end
    local Friendly = LocalContainer == TargetContainer
    return Friendly, Friendly and "ally" or "enemy"
end

local function IsTeammate(Player)
    local Friendly = GetPlayerTeamState(Player)
    return Friendly == true
end

-- Silent Aim Helpers
local SilentAimRandom = Random.new()
local LastSilentTargetUpdate = 0
local ProjectileModule
local CalculateDirectionTarget
local OriginalCalculateDirection
local HookedCalculateDirection
local function GetSilentTargetPart(Player, Randomize)
    local Character = Player and Player.Character
    if not Character then
        return nil
    end
    local Selected = Controller.Settings.SilentAimTargetPart
    local Names
    if Selected == "Random" then
        if Randomize then
            Names = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso" }
            for Index = #Names, 2, -1 do
                local Other = SilentAimRandom:NextInteger(1, Index)
                Names[Index], Names[Other] = Names[Other], Names[Index]
            end
        else
            Names = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso" }
        end
    else
        Names = { Selected, "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
    end
    for _, Name in Names do
        local Part = Character:FindFirstChild(Name)
        if Part and Part:IsA("BasePart") then
            return Part
        end
    end
    return GetAnchor(Character)
end

local function GetSilentDronePart(Model)
    if not Model or not Model:IsA("Model") then
        return nil
    end
    local Hitbox = Model:FindFirstChild("hitbox")
    if Hitbox and Hitbox:IsA("BasePart") then
        return Hitbox
    end
    local AimPoint = Model:FindFirstChild("AimPoint")
    if AimPoint and AimPoint:IsA("BasePart") then
        return AimPoint
    end
    return GetAnchor(Model)
end

local function IsSilentTargetVisible(Container, Part, Camera)
    if not Controller.Settings.SilentAimVisibilityCheck then
        return true
    end
    if not Container or not Part or not Camera then
        return false
    end
    local Exclusions = { Camera }
    if LocalPlayer.Character then
        table.insert(Exclusions, LocalPlayer.Character)
    end
    local Ignore = Workspace:FindFirstChild("ignore")
    if Ignore then
        table.insert(Exclusions, Ignore)
    end
    local Parameters = RaycastParams.new()
    Parameters.FilterType = Enum.RaycastFilterType.Exclude
    Parameters.FilterDescendantsInstances = Exclusions
    Parameters.IgnoreWater = true
    local Origin = Camera.CFrame.Position
    local Result = Workspace:Raycast(Origin, Part.Position - Origin, Parameters)
    return Result == nil or Result.Instance:IsDescendantOf(Container)
end

local function IsSilentPlayerEligible(Player, Part, Camera)
    if not Player or Player == LocalPlayer or not Part then
        return false
    end
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if not Character
        or not Character:IsDescendantOf(Workspace)
        or Humanoid and Humanoid.Health <= 0
        or Controller.Settings.SilentAimTeamCheck and IsTeammate(Player) then
        return false
    end
    local Distance = (Part.Position - Camera.CFrame.Position).Magnitude
    return Distance <= Controller.Settings.SilentAimMaxDistance
        and IsSilentTargetVisible(Character, Part, Camera)
end

local function IsSilentDroneEligible(Model, Part, Camera)
    if not Model or not Model:IsA("Model") or not Part or not Model:IsDescendantOf(Workspace) then
        return false
    end
    local OwnerName = Model:GetAttribute("player")
    local Throttle = Model:GetAttribute("throttle")
    if type(OwnerName) ~= "string" or OwnerName == "" or Throttle == nil then
        return false
    end
    local OwnerPlayer = Players:FindFirstChild(OwnerName)
    if OwnerPlayer == LocalPlayer then
        return false
    end
    if Controller.Settings.SilentAimTeamCheck and OwnerPlayer and IsTeammate(OwnerPlayer) then
        return false
    end
    local Distance = (Part.Position - Camera.CFrame.Position).Magnitude
    return Distance <= Controller.Settings.SilentAimMaxDistance
        and IsSilentTargetVisible(Model, Part, Camera)
end

local function UpdateSilentAimTarget(Camera)
    local Settings = Controller.Settings
    local Center = Camera.ViewportSize * 0.5
    SilentFOVCircle.Position = Center
    SilentFOVCircle.Radius = Settings.SilentAimFOV
    SilentFOVCircle.Thickness = Settings.SilentAimFOVThickness
    SilentFOVCircle.Transparency = Settings.SilentAimFOVOpacity
    SilentFOVCircle.Color = Settings.SilentAimFOVColor
    SilentFOVCircle.Visible = Settings.SilentAimEnabled and Settings.SilentAimShowFOV
    if not Settings.SilentAimEnabled then
        Controller.SilentTarget = nil
        Controller.SilentTargetKind = nil
        return
    end
    local Now = os.clock()
    if Now - LastSilentTargetUpdate < 0.05 then
        return
    end
    LastSilentTargetUpdate = Now
    local BestTarget
    local BestKind
    local BestScreenDistance = Settings.SilentAimFOV
    local TargetType = Settings.SilentAimTargetType
    if TargetType ~= "Drones" then
        for _, Player in Players:GetPlayers() do
            if Player ~= LocalPlayer then
                local Part = GetSilentTargetPart(Player, false)
                if Part then
                    local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen and ScreenPoint.Z > 0 then
                        local ScreenDistance = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - Center).Magnitude
                        if ScreenDistance <= BestScreenDistance and IsSilentPlayerEligible(Player, Part, Camera) then
                            BestScreenDistance = ScreenDistance
                            BestTarget = Player
                            BestKind = "Player"
                        end
                    end
                end
            end
        end
    end
    if TargetType ~= "Players" then
        for Model in Controller.DroneEntries do
            local Part = GetSilentDronePart(Model)
            if Part then
                local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen and ScreenPoint.Z > 0 then
                    local ScreenDistance = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - Center).Magnitude
                    if ScreenDistance <= BestScreenDistance and IsSilentDroneEligible(Model, Part, Camera) then
                        BestScreenDistance = ScreenDistance
                        BestTarget = Model
                        BestKind = "Drone"
                    end
                end
            end
        end
end
    Controller.SilentTarget = BestTarget
    Controller.SilentTargetKind = BestKind
end

-- Silent Aim Point Calculation
local function GetSilentAimPoint(Origin, Speed, Acceleration)
    local Settings = Controller.Settings
    local Target = Controller.SilentTarget
    local TargetKind = Controller.SilentTargetKind
    local Camera = Workspace.CurrentCamera
    local Part
    local VelocityPart
    local Eligible = false
    if TargetKind == "Drone" then
        Part = GetSilentDronePart(Target)
        VelocityPart = Target and (Target.PrimaryPart or Part)
        Eligible = Camera and IsSilentDroneEligible(Target, Part, Camera) or false
    elseif TargetKind == "Player" then
        Part = GetSilentTargetPart(Target, true)
        VelocityPart = Part
        Eligible = Camera and IsSilentPlayerEligible(Target, Part, Camera) or false
    end
    if not Eligible then
        return nil
    end
    if Settings.SilentAimHitChance < 100
        and SilentAimRandom:NextNumber(0, 100) > Settings.SilentAimHitChance then
        return nil
    end
    local AimPoint = Part.Position
    if Settings.SilentAimPrediction then
        local ProjectileSpeed = type(Speed) == "number" and math.abs(Speed) or 0
        if ProjectileSpeed > 0 then
            local TravelTime = (AimPoint - Origin).Magnitude / ProjectileSpeed
            AimPoint = AimPoint + VelocityPart.AssemblyLinearVelocity * TravelTime
    if typeof(Acceleration) == "Vector3" then
                AimPoint = AimPoint - Acceleration * TravelTime * TravelTime * 0.5
            end
        end
    end
    return AimPoint
end

local function GetSilentTargetLabel()
    local Target = Controller.SilentTarget
    if Controller.SilentTargetKind == "Drone" and Target then
        return "Drone: " .. tostring(Target:GetAttribute("player") or "unknown")
    end
    if Controller.SilentTargetKind == "Player" and Target then
        return Target.Name
    end
    return ""
end

-- Silent Aim Hook
local function InstallSilentAimHook()
    if Controller.FastCastHookInstalled then
        return true
    end
    if type(filtergc) ~= "function" then
        return false
    end
    local Success, Projectile = pcall(filtergc, "table", {
        Keys = { "object", "raycast", "calculateDirection", "makeSpread", "init", "providers", "new" }
    }, true)
    if not Success
        or type(Projectile) ~= "table"
        or type(Projectile.calculateDirection) ~= "function" then
        return false
    end
    if type(hookfunction) ~= "function" then
        return false
    end
    ProjectileModule = Projectile
    CalculateDirectionTarget = Projectile.calculateDirection
    local CalculateDirectionReplacement = function(Origin, CameraCFrame, ...)
        local Result = OriginalCalculateDirection(Origin, CameraCFrame, ...)
        Controller.FastCastCalls = Controller.FastCastCalls + 1
        local Settings = Controller.Settings
        if not Controller.Unloaded
            and Settings.SilentAimEnabled
            and typeof(Origin) == "Vector3"
            and typeof(CameraCFrame) == "CFrame"
            and type(Result) == "table" then
            local Camera = Workspace.CurrentCamera
            local LocalAnchor = GetAnchor(LocalPlayer.Character)
            local IsNearCamera = Camera and (Origin - Camera.CFrame.Position).Magnitude <= 25
            local IsNearCharacter = LocalAnchor and (Origin - LocalAnchor.Position).Magnitude <= 30
            if IsNearCamera or IsNearCharacter then
                local Speed
                if typeof(Result.castDirection) == "Vector3" then
                    Speed = Result.castDirection.Magnitude
                end
                if type(Speed) ~= "number" or Speed <= 0 then
                    Speed = 1000
                end
                local Acceleration = Vector3.new(0, -Workspace.Gravity / 8, 0)
                local AimSuccess, AimPoint = pcall(GetSilentAimPoint, Origin, Speed, Acceleration)
                if AimSuccess and AimPoint then
                    local MuzzleDifference = AimPoint - Origin
                    local CameraDifference = AimPoint - CameraCFrame.Position
                    if MuzzleDifference.Magnitude > 0 and CameraDifference.Magnitude > 0 then
                        local CastMagnitude = typeof(Result.castDirection) == "Vector3"
                            and Result.castDirection.Magnitude
                            or Speed
                        Result.position = AimPoint
                        Result.direction = MuzzleDifference.Unit
                        Result.rayDirection = CameraDifference.Unit
                        Result.castDirection = Result.rayDirection * CastMagnitude
                        Controller.SilentRedirects = Controller.SilentRedirects + 1
                        Controller.LastSilentTarget = GetSilentTargetLabel()
                    end
                end
            end
        end
        return Result
    end
    HookedCalculateDirection = type(newcclosure) == "function"
        and newcclosure(CalculateDirectionReplacement)
        or CalculateDirectionReplacement
    local DirectionHookSuccess, OriginalDirection = pcall(
        hookfunction,
        CalculateDirectionTarget,
        HookedCalculateDirection
    )
    if not DirectionHookSuccess or type(OriginalDirection) ~= "function" then
        ProjectileModule = nil
        CalculateDirectionTarget = nil
        HookedCalculateDirection = nil
    return false
    end
    OriginalCalculateDirection = OriginalDirection
    Controller.FastCastHookInstalled = true
    return true
end

-- ESP Rendering
local function RenderRearArrow(Visual, Anchor, Color, Camera)
    if not Visual.ArrowTop then
        return
    end
    local Settings = Controller.Settings
    local Relative = Camera.CFrame:PointToObjectSpace(Anchor.Position)
    if not Settings.DroneRearArrows or Relative.Z <= 0 then
        Visual.ArrowTop.Visible = false
        Visual.ArrowBottom.Visible = false
        return
    end
    local Direction = Vector2.new(Relative.X, -Relative.Y)
    if Direction.Magnitude < 0.001 then
        Direction = Vector2.new(1, 0)
    else
        Direction = Direction.Unit
    end
    local Perpendicular = Vector2.new(-Direction.Y, Direction.X)
    local Center = Camera.ViewportSize * 0.5
    local ArrowCenter = Center + Direction * Settings.RearArrowRadius
    local Tip = ArrowCenter + Direction * Settings.RearArrowSize
    local Back = ArrowCenter - Direction * Settings.RearArrowSize * 0.65
    local Wing = Settings.RearArrowSize * 0.8
    local Upper = Back + Perpendicular * Wing
    local Lower = Back - Perpendicular * Wing
    local Thickness = math.max(2, Settings.BoxThickness)
    Visual.ArrowTop.From = Upper
    Visual.ArrowTop.To = Tip
    Visual.ArrowTop.Color = Color
    Visual.ArrowTop.Thickness = Thickness
    Visual.ArrowTop.Transparency = Settings.Opacity
    Visual.ArrowTop.Visible = true
    Visual.ArrowBottom.From = Lower
    Visual.ArrowBottom.To = Tip
    Visual.ArrowBottom.Color = Color
    Visual.ArrowBottom.Thickness = Thickness
    Visual.ArrowBottom.Transparency = Settings.Opacity
    Visual.ArrowBottom.Visible = true
end

local function RenderVisual(Visual, Model, Label, Color, ShowBox, ShowText, ShowTracer, Camera)
    local Position, Size = GetBounds(Model, Camera)
    if not Position then
        HideVisual(Visual)
        return
    end
    local Settings = Controller.Settings
    local Transparency = Settings.Opacity
    Visual.Outline.Position = Position
    Visual.Outline.Size = Size
    Visual.Outline.Thickness = Settings.BoxThickness + 2
    Visual.Outline.Transparency = Transparency
    Visual.Outline.Visible = ShowBox
    Visual.Box.Position = Position
    Visual.Box.Size = Size
    Visual.Box.Color = Color
    Visual.Box.Thickness = Settings.BoxThickness
    Visual.Box.Transparency = Transparency
    Visual.Box.Visible = ShowBox
    Visual.Text.Text = Label
    Visual.Text.Position = Vector2.new(Position.X + Size.X * 0.5, math.max(0, Position.Y - Settings.TextSize - 3))
    Visual.Text.Color = Color
    Visual.Text.Size = Settings.TextSize
    Visual.Text.Transparency = Transparency
    Visual.Text.Visible = ShowText and Label ~= ""
    Visual.Tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y - 2)
    Visual.Tracer.To = Vector2.new(Position.X + Size.X * 0.5, Position.Y + Size.Y)
    Visual.Tracer.Color = Color
    Visual.Tracer.Thickness = Settings.BoxThickness
    Visual.Tracer.Transparency = Transparency
    Visual.Tracer.Visible = ShowTracer
end

local function GetPlayerVisual(Player)
    local Visual = Controller.PlayerEntries[Player]
    if not Visual then
        Visual = CreateVisual(false)
        Controller.PlayerEntries[Player] = Visual
    end
    return Visual
end

local function RemovePlayer(Player)
    local Visual = Controller.PlayerEntries[Player]
    if Visual then
        RemoveVisual(Visual)
        Controller.PlayerEntries[Player] = nil
    end
end

-- Drone Management
local function LooksLikeDrone(Model)
    if not Model or not Model:IsA("Model") then
        return false
    end
    local Owner = Model:GetAttribute("player")
    local Throttle = Model:GetAttribute("throttle")
    if type(Owner) ~= "string" or Owner == "" or Throttle == nil then
        return false
    end
    local Propellers = Model:FindFirstChild("propellers")
    local PrimaryPart = Model.PrimaryPart
    local RootAttachment = PrimaryPart and PrimaryPart:FindFirstChild("RootAttachment")
    return Propellers ~= nil or RootAttachment ~= nil
end

local function RegisterDrone(Model)
    if Controller.DroneEntries[Model] or not LooksLikeDrone(Model) then
        return
    end
    Controller.DroneEntries[Model] = CreateVisual(true)
end

local function RemoveDrone(Model)
    local Visual = Controller.DroneEntries[Model]
    if Visual then
        RemoveVisual(Visual)
        Controller.DroneEntries[Model] = nil
    end
end

local function DiscoverDrones()
    local Candidates
    local Success, Result = pcall(function()
    return Workspace:QueryDescendants("Model[$player], Model[$throttle], Model:has(#propellers)")
    end)
    if Success and type(Result) == "table" then
        Candidates = Result
    else
        Candidates = {}
        for _, Descendant in Workspace:QueryDescendants("Model") do
            table.insert(Candidates, Descendant)
        end
    end
    for _, Candidate in Candidates do
        RegisterDrone(Candidate)
    end
end

-- ESP Update
local function UpdatePlayers(Camera, Origin)
    local Settings = Controller.Settings
    local Present = {}
    for _, Player in Players:GetPlayers() do
        if Player ~= LocalPlayer then
            Present[Player] = true
            local Visual = GetPlayerVisual(Player)
            local Character = Player.Character
            local Anchor = GetAnchor(Character)
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local Teammate = IsTeammate(Player)
            if not Settings.PlayerEnabled
                or not Character
                or not Character:IsDescendantOf(Workspace)
                or not Anchor
                or Humanoid and Humanoid.Health <= 0
                or Teammate and not Settings.ShowTeammates then
                HideVisual(Visual)
            else
                local Distance = (Anchor.Position - Origin).Magnitude
                if Distance > Settings.PlayerMaxDistance then
                    HideVisual(Visual)
                else
                    local Pieces = {}
                    if Settings.PlayerNames then
                        table.insert(Pieces, Player.DisplayName ~= Player.Name and Player.DisplayName .. " (@" .. Player.Name .. ")" or Player.Name)
                    end
                    if Settings.PlayerDistance then
                        table.insert(Pieces, string.format("[%ds]", math.floor(Distance + 0.5)))
                    end
                    local Color = Teammate and Settings.TeammateColor or Settings.EnemyColor
                    RenderVisual(
                        Visual,
                        Character,
                        table.concat(Pieces, " "),
                        Color,
                        Settings.PlayerBoxes,
                        Settings.PlayerNames or Settings.PlayerDistance,
                        Settings.PlayerTracers,
                        Camera
                    )
                end
            end
        end
    end
    for Player in Controller.PlayerEntries do
        if not Present[Player] then
            RemovePlayer(Player)
        end
    end
end

local function UpdateDrones(Camera, Origin)
    local Settings = Controller.Settings
    for Model, Visual in Controller.DroneEntries do
        if not Model.Parent or not Model:IsDescendantOf(Workspace) or not LooksLikeDrone(Model) then
            RemoveDrone(Model)
        else
            local Anchor = GetAnchor(Model)
            local OwnerName = Model:GetAttribute("player")
            if not Settings.DroneEnabled or not Anchor or OwnerName == LocalPlayer.Name and not Settings.ShowOwnDrone then
                HideVisual(Visual)
            else
                local Distance = (Anchor.Position - Origin).Magnitude
                if Distance > Settings.DroneMaxDistance then
                    HideVisual(Visual)
                else
                    local OwnerPlayer = Players:FindFirstChild(OwnerName)
                    local Friendly, TeamName = GetPlayerTeamState(OwnerPlayer)
                    local IsOwnDrone = OwnerName == LocalPlayer.Name
                    local Color
                    if Friendly == true then
                        Color = Settings.FriendlyDroneColor
                    elseif Friendly == false then
                        Color = Settings.EnemyDroneColor
                    else
                        Color = Settings.UnknownDroneColor
                    end
                    if Settings.DroneTeamCheck and Friendly == true and not IsOwnDrone then
                        HideVisual(Visual)
                    else
                        local Pieces = {}
                        if Settings.DroneNames then
                            table.insert(Pieces, "Drone: " .. OwnerName)
                        end
                        if Settings.DroneTeams then
                            table.insert(Pieces, "[" .. string.upper(TeamName) .. "]")
                        end
                        if Settings.DroneDistance then
                            table.insert(Pieces, string.format("[%ds]", math.floor(Distance + 0.5)))
                        end
                        RenderVisual(
                            Visual,
                            Model,
                            table.concat(Pieces, " "),
                            Color,
                            Settings.DroneBoxes,
                            Settings.DroneNames or Settings.DroneTeams or Settings.DroneDistance,
                            Settings.DroneTracers,
                            Camera
                        )
                        RenderRearArrow(Visual, Anchor, Color, Camera)
                    end
                end
            end
        end
    end
end

-- Install Hook
InstallSilentAimHook()

-- Cleanup
local function Cleanup()
    if Controller.Unloaded then
        return
    end
    Controller.Unloaded = true
    Controller.SilentTarget = nil
    Controller.SilentTargetKind = nil
    SilentFOVCircle.Visible = false
    for _, Connection in Controller.Connections do
        pcall(function()
            Connection:Disconnect()
        end)
    end
    table.clear(Controller.Connections)
    for Player, Visual in Controller.PlayerEntries do
        RemoveVisual(Visual)
        Controller.PlayerEntries[Player] = nil
    end
    for Model, Visual in Controller.DroneEntries do
        RemoveVisual(Visual)
        Controller.DroneEntries[Model] = nil
    end
    RemoveDrawing(SilentFOVCircle)
    if CalculateDirectionTarget then
        if type(restorefunction) == "function" then
            pcall(restorefunction, CalculateDirectionTarget)
        elseif type(hookfunction) == "function" and OriginalCalculateDirection then
            pcall(hookfunction, CalculateDirectionTarget, OriginalCalculateDirection)
        end
    end
    Controller.FastCastHookInstalled = false
    if Environment.LostFrontDrawingESP == Controller then
        Environment.LostFrontDrawingESP = nil
    end
end
Controller.Unload = function()
    if Controller.Unloaded then
        return
    end
    if Library and not Library.Unloaded then
        Library:Unload()
    else
        Cleanup()
    end
end

-- UI Setup
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
local GameTitle = "The Lost Front"
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "The Lost Front",
	Icon = 106251220512678,
	NotifySide = "Right",
	ShowCustomCursor = true,
	AutoShow = true,
    SidebarCompacted = true,
    DisableSearch = true,
    Animations = { TabSwitch = true },
    TabTransitionTime = 0.65,
})
Window:ChangeTitle(GameTitle)
local Tabs = {
    Main = Window:AddTab("Main", "house", "Main features"),
    Settings = Window:AddTab("UI Settings", "settings", ""),
    Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
}
Tabs.Main:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})

-- Silent Aim UI
local SilentGroup = Tabs.Main:AddLeftGroupbox("Silent Aim", "crosshair")
SilentGroup:AddToggle("SilentAimEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(Value)
        Controller.Settings.SilentAimEnabled = Value
        if not Value then
            Controller.SilentTarget = nil
            Controller.SilentTargetKind = nil
        end
    end
})
SilentGroup:AddToggle("SilentAimTeamCheck", {
    Text = "Team check",
    Default = false,
    Callback = function(Value)
        Controller.Settings.SilentAimTeamCheck = Value
    end
})
SilentGroup:AddToggle("SilentAimVisibilityCheck", {
    Text = "Visibility check",
    Default = false,
    Callback = function(Value)
        Controller.Settings.SilentAimVisibilityCheck = Value
    end
})
SilentGroup:AddToggle("SilentAimPrediction", {
    Text = "Prediction",
    Default = false,
    Callback = function(Value)
        Controller.Settings.SilentAimPrediction = Value
    end
})
SilentGroup:AddSlider("SilentAimHitChance", {
    Text = "Hit chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(Value)
        Controller.Settings.SilentAimHitChance = Value
    end
})
SilentGroup:AddDivider()
SilentGroup:AddDropdown("SilentAimTargetType", {
    Values = { "Players and Drones", "Players", "Drones" },
    Default = "Players and Drones",
    Multi = false,
    Text = "Target type",
    Callback = function(Value)
        Controller.Settings.SilentAimTargetType = Value
        Controller.SilentTarget = nil
        Controller.SilentTargetKind = nil
    end
})
SilentGroup:AddDropdown("SilentAimTargetPart", {
    Values = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "Random" },
    Default = "Head",
    Multi = false,
    Text = "Hit Part",
    Callback = function(Value)
        Controller.Settings.SilentAimTargetPart = Value
    end
})
SilentGroup:AddSlider("SilentAimMaxDistance", {
    Text = "Max distance",
    Default = 5000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.SilentAimMaxDistance = Value
    end
})
SilentGroup:AddDivider()
SilentGroup:AddToggle("SilentAimShowFOV", {
    Text = "Enable FOV",
    Default = false,
    Callback = function(Value)
        Controller.Settings.SilentAimShowFOV = Value
    end
})
SilentGroup:AddSlider("SilentAimFOV", {
    Text = "FOV Size",
    Default = 150,
    Min = 20,
    Max = 500,
    Rounding = 0,
    Suffix = " px",
    Callback = function(Value)
        Controller.Settings.SilentAimFOV = Value
    end
})
SilentGroup:AddSlider("SilentAimFOVThickness", {
    Text = "FOV thickness",
    Default = 1,
    Min = 1,
    Max = 4,
    Rounding = 0,
    Visible = false,
    Callback = function(Value)
        Controller.Settings.SilentAimFOVThickness = Value
    end
})
SilentGroup:AddSlider("SilentAimFOVOpacity", {
    Text = "FOV opacity",
    Default = 80,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.SilentAimFOVOpacity = Value / 100
    end
})

-- Visuals UI
local VisualsGroup = Tabs.Main:AddRightGroupbox("Visuals", "eye")
VisualsGroup:AddToggle("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Callback = function(Value)
        Controller.Settings.PlayerEnabled = Value
    end
})
VisualsGroup:AddToggle("PlayerBoxes", {
    Text = "Boxes",
    Default = false,
    Callback = function(Value)
        Controller.Settings.PlayerBoxes = Value
    end
})
VisualsGroup:AddToggle("PlayerNames", {
    Text = "Names",
    Default = false,
    Callback = function(Value)
        Controller.Settings.PlayerNames = Value
    end
})
VisualsGroup:AddToggle("PlayerDistance", {
    Text = "Distance",
    Default = false,
    Callback = function(Value)
        Controller.Settings.PlayerDistance = Value
    end
})
VisualsGroup:AddToggle("ShowTeammates", {
    Text = "Show teammates",
    Default = false,
    Callback = function(Value)
        Controller.Settings.ShowTeammates = Value
    end
})
VisualsGroup:AddToggle("PlayerTracers", {
    Text = "Tracers",
    Default = false,
    Visible = false,
    Callback = function(Value)
        Controller.Settings.PlayerTracers = Value
    end
})
VisualsGroup:AddSlider("PlayerMaxDistance", {
    Text = "Max distance",
    Default = 5000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.PlayerMaxDistance = Value
    end
})
VisualsGroup:AddDivider()
VisualsGroup:AddToggle("DroneESP", {
    Text = "Drone ESP",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneEnabled = Value
    end
})
VisualsGroup:AddToggle("DroneBoxes", {
    Text = "Boxes",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneBoxes = Value
    end
})
VisualsGroup:AddToggle("DroneNames", {
    Text = "Owner names",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneNames = Value
    end
})
VisualsGroup:AddToggle("DroneTeams", {
    Text = "Team labels",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneTeams = Value
    end
})
VisualsGroup:AddToggle("DroneDistance", {
    Text = "Distance",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneDistance = Value
    end
})
VisualsGroup:AddToggle("DroneRearArrows", {
    Text = "Rear drone arrows",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneRearArrows = Value
    end
})
VisualsGroup:AddToggle("DroneTeamCheck", {
    Text = "Team check",
    Default = false,
    Callback = function(Value)
        Controller.Settings.DroneTeamCheck = Value
    end
})
VisualsGroup:AddToggle("ShowOwnDrone", {
    Text = "Show own drone",
    Default = false,
    Callback = function(Value)
        Controller.Settings.ShowOwnDrone = Value
    end
})
VisualsGroup:AddToggle("DroneTracers", {
    Text = "Tracers",
    Default = false,
    Visible = false,
    Callback = function(Value)
        Controller.Settings.DroneTracers = Value
    end
})
VisualsGroup:AddSlider("DroneMaxDistance", {
    Text = "Max distance",
    Default = 5000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.DroneMaxDistance = Value
    end
})
local RescanButton = VisualsGroup:AddButton({
    Text = "Rescan drones",
    Func = DiscoverDrones
})
if RescanButton then
    RescanButton.Visible = false
end
VisualsGroup:AddDivider()
VisualsGroup:AddLabel("Enemy color"):AddColorPicker("EnemyColor", {
    Default = Controller.Settings.EnemyColor,
    Title = "Enemy color",
    Callback = function(Value)
        Controller.Settings.EnemyColor = Value
    end
})
VisualsGroup:AddLabel("Teammate color"):AddColorPicker("TeammateColor", {
    Default = Controller.Settings.TeammateColor,
    Title = "Teammate color",
    Callback = function(Value)
        Controller.Settings.TeammateColor = Value
    end
})
VisualsGroup:AddLabel("Friendly drone color"):AddColorPicker("FriendlyDroneColor", {
    Default = Controller.Settings.FriendlyDroneColor,
    Title = "Friendly drone color",
    Callback = function(Value)
        Controller.Settings.FriendlyDroneColor = Value
    end
})
VisualsGroup:AddLabel("Enemy drone color"):AddColorPicker("EnemyDroneColor", {
    Default = Controller.Settings.EnemyDroneColor,
    Title = "Enemy drone color",
    Callback = function(Value)
        Controller.Settings.EnemyDroneColor = Value
    end
})
VisualsGroup:AddLabel("Unknown drone color"):AddColorPicker("UnknownDroneColor", {
    Default = Controller.Settings.UnknownDroneColor,
    Title = "Unknown drone color",
    Callback = function(Value)
        Controller.Settings.UnknownDroneColor = Value
    end
})
VisualsGroup:AddSlider("BoxThickness", {
    Text = "Box thickness",
    Default = 1,
    Min = 1,
    Max = 4,
    Rounding = 0,
    Visible = false,
    Callback = function(Value)
        Controller.Settings.BoxThickness = Value
    end
})
VisualsGroup:AddSlider("TextSize", {
    Text = "Text size",
    Default = 13,
    Min = 10,
    Max = 24,
    Rounding = 0,
    Visible = false,
    Callback = function(Value)
        Controller.Settings.TextSize = Value
    end
})
VisualsGroup:AddSlider("Opacity", {
    Text = "Opacity",
    Default = 100,
    Min = 20,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.Opacity = Value / 100
    end
})
VisualsGroup:AddSlider("RearArrowRadius", {
    Text = "Rear arrow radius",
    Default = 70,
    Min = 30,
    Max = 180,
    Rounding = 0,
    Suffix = " px",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.RearArrowRadius = Value
    end
})
VisualsGroup:AddSlider("RearArrowSize", {
    Text = "Rear arrow size",
    Default = 11,
    Min = 6,
    Max = 24,
    Rounding = 0,
    Suffix = " px",
    Visible = false,
    Callback = function(Value)
        Controller.Settings.RearArrowSize = Value
    end
})

-- Menu UI
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddDropdown("DPIScale", {
    Values = { "50%", "75%", "100%", "125%", "150%" },
    Default = Library.IsMobile and "75%" or "100%",
    Text = "DPI scale",
    Callback = function(Value)
        Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
    end
})
MenuGroup:AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})
MenuGroup:AddLabel("The built-in mobile menu button is enabled.", true)
MenuGroup:AddButton({
    Text = "Unload",
    Func = Controller.Unload
})
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(Cleanup)

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("LostFrontESP")
SaveManager:SetFolder("LostFrontESP")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- Connections
AddConnection(Players.PlayerRemoving:Connect(RemovePlayer))
AddConnection(Workspace.DescendantAdded:Connect(function(Descendant)
    if Descendant:IsA("Model") then
        task.delay(0.35, function()
            if not Controller.Unloaded then
                RegisterDrone(Descendant)
            end
        end)
    end
end))
AddConnection(RunService.RenderStepped:Connect(function()
    if Controller.Unloaded then
        return
    end
local Camera = Workspace.CurrentCamera
    if not Camera then
        return
    end
    UpdateSilentAimTarget(Camera)
    local Origin = GetDistanceOrigin(Camera)
    UpdatePlayers(Camera, Origin)
    UpdateDrones(Camera, Origin)
end))

-- Drone Discovery Loop
task.spawn(function()
    while not Controller.Unloaded do
        DiscoverDrones()
        task.wait(1.5)
    end
end)

-- Credits
SaveManager:LoadAutoloadConfig()
local ContributorsSource = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local TeamMembers, GameContributors = loadstring(ContributorsSource)()
local DeveloperBox = Tabs.Cont:AddLeftGroupbox("Team", "wrench")
for Name, Role in TeamMembers do
    DeveloperBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Role)
end
local PlaceId = tostring(game.PlaceId)
if GameContributors[PlaceId] then
    local ContributorsBox = Tabs.Cont:AddRightGroupbox("Contributors", "users")
    for Name, Contribution in GameContributors[PlaceId] do
        ContributorsBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. Name .. "</font>] " .. Contribution)
    end
end

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
