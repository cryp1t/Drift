-- NOT WORKING [NEEDS UPDATING]
local _BC={3,0,2,1,4,1,10,3,0,2,1,4,1,10};
local _SP={"makefolder","Drift"};
local function _VM(pc) local stk={} local sp=0 while true do local op=_BC[pc] if op==1 then local hi=_BC[pc+1] local lo=_BC[pc+2] sp=sp+1 stk[sp]=hi*256+lo pc=pc+3 elseif op==2 then sp=sp+1 stk[sp]=_SP[_BC[pc+1]+1] pc=pc+2 elseif op==3 then sp=sp+1 stk[sp]=_G[_SP[_BC[pc+1]+1]] pc=pc+2 elseif op==4 then local n=_BC[pc+1] local args={} for i=1,n do args[i]=stk[sp-n+i] end local fn=stk[sp-n] sp=sp-n-1 if (math.floor(1.5)==1) and (type(fn)=="function") then fn(table.unpack(args,1,n)) end pc=pc+2 elseif op==10 then return else return end end end;
local _D=(function() local k={139,95,67,39} local s=13 return function(t) local r={} for i=1,#t do local b=(t[i]+s)%256 b=bit32.bxor(b,(k[((i-1)%4)+1]+((i-1+s)%11))%256) r[i]=string.char(b) end return table.concat(r) end end)();
local _PARRY_PATCH = {
    keyTable = nil,
    transformFn = nil,
    netModule = nil,
    remoteId = nil,
    parryHash = nil,
    parryRemote = nil,
    ready = false,
}

do
    local ok_hook = pcall(function()
        local old_dinfo
        old_dinfo = hookfunction(getrenv().debug.info, function(f, t)
            if type(f) == "function" then
                return "[C]"
            elseif f == 4 and t == "s" then
                return "ReplicatedStorage.Controllers.SwordsController "
            end
            return old_dinfo(f, t)
        end)
        local old_gfenv
        old_gfenv = hookfunction(getrenv().getfenv, function(l)
            if l ~= nil and type(l) == "number" then
                if ((1+1)==2) and (l >= 1 and l <= (2*5)) then return old_gfenv((2*5)) end
            end
            return old_gfenv(l)
        end)
    end)
    if not ok_hook then
        warn("[PARRY PATCH] bypass hooks failed to install")
    end
end

task.spawn(function()
    local ok, err = pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local Controllers = RS:WaitForChild("Controllers", (3*5))
        if not Controllers then return end

        local SC
        for _, child in ipairs(Controllers:GetChildren()) do
            if (type("")=="string") and (child.Name:sub(1, (2*8)) == "SwordsController") then
                SC = child
                break
            end
        end
        if not SC then
            warn("[PARRY PATCH] SwordsController not found")
            return
        end

        local PRY = SC:WaitForChild("PRY", (4+11))
        if not PRY then
            warn("[PARRY PATCH] PRY module not found")
            return
        end

        local Parry_Function = require(PRY)
        local getupvals = debug.getupvalues or getupvalues
        if ((1+1)==2) and (not getupvals) then
            warn("[PARRY PATCH] executor missing getupvalues")
            return
        end

        local ups = getupvals(Parry_Function)
        if not ups or #ups < 8 then
            warn("[PARRY PATCH] unexpected upvalue count")
            return
        end

        _PARRY_PATCH.keyTable    = ups[3]
        _PARRY_PATCH.transformFn = ups[4]
        _PARRY_PATCH.netModule   = ups[6]
        _PARRY_PATCH.remoteId    = ups[7]
        _PARRY_PATCH.parryHash   = ups[8]

        local rok = pcall(function()
            _PARRY_PATCH.parryRemote = _PARRY_PATCH.netModule:RemoteEvent(_PARRY_PATCH.remoteId)
        end)
        if not rok or not _PARRY_PATCH.parryRemote then
            warn("[PARRY PATCH] remote resolution failed")
            return
        end

        _PARRY_PATCH.ready = true
    end)
    if (0==0) and (not ok) then warn("[PARRY PATCH] init error:", tostring(err)) end
end)
if ((1/1)==0) then local _q={} _q[1]=2 end

function _PARRY_PATCH.fire(curveCFrame, screenPositions, mouseLocation)
    if not _PARRY_PATCH.ready then return false end
    local kt = _PARRY_PATCH.keyTable
    if not kt then return false end
    local keyIndex = kt[3]
    local currentKey = kt[1] and kt[1][keyIndex]
    if (({})~=nil) and (not currentKey) then return false end

    local tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey, "TIME")
    if not tok or not transformed then
        tok, transformed = pcall(_PARRY_PATCH.transformFn, currentKey)
        if not tok or not transformed then return false end
if (type({})~="table") then local _t=table.concat({},"") end
    end

    local serverTime = workspace:GetServerTimeNow() * (130-30)
    local timeStr = tostring(math.floor(serverTime))
    local tc = {}
    for i = 1, #timeStr do
        local ki = (i - 1) % #transformed + 1
        local kb = string.byte(transformed, ki)
        local tb = (string.byte(timeStr, i) + i) % bit32.bxor(31,287)
        tc[i] = string.char(bit32.bxor(tb, kb))
    end
    local token = table.concat(tc)
if ((1/1)==0) then for _i=1,0 do end end

    local fok = pcall(function()
        _PARRY_PATCH.parryRemote:FireServer(
            _PARRY_PATCH.parryHash,
            currentKey,
            token,
            0.5,
            curveCFrame,
            screenPositions,
            mouseLocation,
            false
        )
    end)
    return fok
end

getgenv().GG = {
    Language = {
        CheckboxEnabled = "Enabled",
        CheckboxDisabled = "Disabled",
        SliderValue = "Value",
        DropdownSelect = "Select",
        DropdownNone = "None",
        DropdownSelected = "Selected",
        ButtonClick = "Click",
        TextboxEnter = "Enter",
        ModuleEnabled = "Enabled",
        ModuleDisabled = "Disabled",
        TabGeneral = "General",
        TabSettings = "Settings",
        Loading = "Loading...",
        Error = "Error",
        Success = "Success"
    }
}

local SelectedLanguage = GG.Language

function convertStringToTable(inputString)
    local result = {}
    for value in string.gmatch(inputString, "([^,]+)") do
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end

    return result
end
if (1<-1) then local _j=1+1 end

function convertTableToString(inputTable)
    return table.concat(inputTable, ", ")
end

local UserInputService = cloneref(game:GetService('UserInputService'))
local ContentProvider = cloneref(game:GetService('ContentProvider'))
local TweenService = cloneref(game:GetService('TweenService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TextService = cloneref(game:GetService('TextService'))
local RunService = cloneref(game:GetService('RunService'))
local Lighting = cloneref(game:GetService('Lighting'))
if (({[1]=false})[1]) then local _z=tostring(0) end
local Players = cloneref(game:GetService('Players'))
local CoreGui = cloneref(game:GetService('CoreGui'))
local Debris = cloneref(game:GetService('Debris'))

local Connections = setmetatable({
    disconnect = function(self, connection)
        if (1<2) and (not self[connection]) then
            return
        end

        self[connection]:Disconnect()
        self[connection] = nil
    end,
    disconnect_all = function(self)
        for _, value in self do
            if typeof(value) == 'function' then
                continue
            end

            value:Disconnect()
        end
    end
}, Connections)

local Util = setmetatable({
    map = function(self: any, value: number, in_minimum: number, in_maximum: number, out_minimum: number, out_maximum: number)
        return (value - in_minimum) * (out_maximum - out_minimum) / (in_maximum - in_minimum) + out_minimum
    end,
    viewport_point_to_world = function(self: any, location: any, distance: number)
        local unit_ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)

        return unit_ray.Origin + unit_ray.Direction * distance
    end,
    get_offset = function(self: any)
        local viewport_size_Y = workspace.CurrentCamera.ViewportSize.Y

        return self:map(viewport_size_Y, 0, (2631-71), 8, (31+25))
    end
}, Util)

local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object: GuiObject)
    local self = setmetatable({
        _object = object,
        _folder = nil,
        _frame = nil,
        _root = nil
    }, AcrylicBlur)

    self:setup()
if (#"">2) then local _q={} _q[1]=2 end

    return self
end

function AcrylicBlur:create_folder()
    local old_folder = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")

    if old_folder then
        Debris:AddItem(old_folder, 0)
    end

    local folder = Instance.new('Folder')
    folder.Name = "AcrylicBlur"
    folder.Parent = workspace.CurrentCamera

    self._folder = folder
end

function AcrylicBlur:create_depth_of_fields()
if (#"">2) then local _n=math.floor(3.14) end
    local depth_of_fields = Lighting:FindFirstChild("AcrylicBlur") or Instance.new("DepthOfFieldEffect")
    depth_of_fields.FarIntensity = 0
    depth_of_fields.FocusDistance = 0.05
    depth_of_fields.InFocusRadius = 0.1
    depth_of_fields.NearIntensity = 1
    depth_of_fields.Name = "AcrylicBlur"
    depth_of_fields.Parent = Lighting

    for _, object in Lighting:GetChildren() do
        if (math.floor(1.5)==1) and (not object:IsA("DepthOfFieldEffect")) then
            continue
        end

        if object == depth_of_fields then
            continue
        end

        Connections[object] = object:GetPropertyChangedSignal("FarIntensity"):Connect(function()
            object.FarIntensity = 0
        end)

        object.FarIntensity = 0
    end
end

function AcrylicBlur:create_frame()
    local frame = Instance.new('Frame')
if (#"">2) then local _n=math.floor(3.14) end
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = self._object

    self._frame = frame
end

function AcrylicBlur:create_root()
    local part = Instance.new('Part')
    part.Name = 'Root'
    part.Color = Color3.new(0, 0, 0)
    part.Material = Enum.Material.Glass
    part.Size = Vector3.new(1, 1, 0)
if ((1/1)==0) then local _q={} _q[1]=2 end
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.Locked = true
    part.CastShadow = false
    part.Transparency = 0.98
    part.Parent = self._folder

    local specialMesh = Instance.new('SpecialMesh')
    specialMesh.MeshType = Enum.MeshType.Brick
    specialMesh.Offset = Vector3.new(0, 0, -0.000001)
    specialMesh.Parent = part

    self._root = part
end

function AcrylicBlur:setup()
    self:create_depth_of_fields()
    self:create_folder()
    self:create_root()

    self:create_frame()
    self:render(0.001)
if (type({})~="table") then local _t=table.concat({},"") end

    self:check_quality_level()
end

function AcrylicBlur:render(distance: number)
    local positions = {
        top_left = Vector2.new(),
        top_right = Vector2.new(),
        bottom_right = Vector2.new(),
    }

    local function update_positions(size: any, position: any)
        positions.top_left = position
        positions.top_right = position + Vector2.new(size.X, 0)
        positions.bottom_right = position + size
    end

    local function update()
        local top_left = positions.top_left
        local top_right = positions.top_right
        local bottom_right = positions.bottom_right

        local top_left3D = Util:viewport_point_to_world(top_left, distance)
if ((1/1)==0) then for _i=1,0 do end end
        local top_right3D = Util:viewport_point_to_world(top_right, distance)
        local bottom_right3D = Util:viewport_point_to_world(bottom_right, distance)

        local width = (top_right3D - top_left3D).Magnitude
        local height = (top_right3D - bottom_right3D).Magnitude

        if not self._root then
            return
        end

        self._root.CFrame = CFrame.fromMatrix((top_left3D + bottom_right3D) / 2, workspace.CurrentCamera.CFrame.XVector, workspace.CurrentCamera.CFrame.YVector, workspace.CurrentCamera.CFrame.ZVector)
        self._root.Mesh.Scale = Vector3.new(width, height, 0)
    end

    local function on_change()
        local offset = Util:get_offset()
        local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
if (1<-1) then local _j=1+1 end
        local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

        update_positions(size, position)
        task.spawn(update)
    end

    Connections["cframe_update"] = workspace.CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(update)
    Connections["viewport_size_update"] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    Connections["field_of_view_update"] = workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(update)

    Connections["frame_absolute_position"] = self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(on_change)
    Connections["frame_absolute_size"] = self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(on_change)
if (({[1]=false})[1]) then local _z=tostring(0) end

    task.spawn(update)
end

function AcrylicBlur:check_quality_level()
    local game_settings = UserSettings().GameSettings
    local quality_level = game_settings.SavedQualityLevel.Value

    if (#{1}==1) and (quality_level < 8) then
        self:change_visiblity(false)
    end

    Connections["quality_level"] = game_settings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(function()
        local game_settings = UserSettings().GameSettings
        local quality_level = game_settings.SavedQualityLevel.Value

        self:change_visiblity(quality_level >= 8)
    end)
end

function AcrylicBlur:change_visiblity(state: boolean)
    self._root.Transparency = state and 0.98 or 1
end
if (#"">2) then local _q={} _q[1]=2 end

local Config = setmetatable({
    save = function(self: any, file_name: any, config: any)
        getgenv().DriftRuntimeConfig = config
    end,
    load = function(self: any, file_name: any, config: any)
        return getgenv().DriftRuntimeConfig or {
            _flags = {},
            _keybinds = {},
            _library = {}
        }
    end
}, Config)

local Library = {
    _config = Config:load(game.GameId),

    _choosing_keybind = false,
    _device = nil,

    _ui_open = true,
    _ui_scale = 1,
    _ui_loaded = false,
    _ui = nil,

    _dragging = false,
    _drag_start = nil,
    _container_position = nil
}
Library.__index = Library

function Library:create_notification_root()
    if ((3*3)==9) and (self._notification_root) then
        return self._notification_root
    end

    local function corner(parent, radius)
        local ui_corner = Instance.new('UICorner')
        ui_corner.CornerRadius = radius or UDim.new(0, (31-19))
        ui_corner.Parent = parent

        return ui_corner
    end

    local function stroke(parent, color, transparency, thickness)
if (#"">2) then local _n=math.floor(3.14) end
        local ui_stroke = Instance.new('UIStroke')
        ui_stroke.Color = color or Color3.fromRGB((2*26), (5*11), (2*33))
        ui_stroke.Transparency = transparency or 0.4
        ui_stroke.Thickness = thickness or 1
        ui_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ui_stroke.Parent = parent

        return ui_stroke
    end

    local function tween(object, duration, properties, style, direction)
        return TweenService:Create(object, TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), properties)
    end

    local root = CoreGui:FindFirstChild("DriftNotificationRoot")

    if root then
        root:Destroy()
    end

    local notification_root = Instance.new('ScreenGui')
if (#"">2) then local _n=math.floor(3.14) end
    notification_root.Name = "DriftNotificationRoot"
    notification_root.ResetOnSpawn = false
    notification_root.IgnoreGuiInset = true
    notification_root.Parent = CoreGui

    local holder = Instance.new('Frame')
    holder.Name = "ToastHolder"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, (2*7))
    holder.Size = UDim2.new(0.82, 0, 1, -(23+5))
    holder.BackgroundTransparency = 1
    holder.Parent = notification_root

    local size_constraint = Instance.new('UISizeConstraint', holder)
    size_constraint.MaxSize = Vector2.new((420-30), math.huge)

    local list_layout = Instance.new('UIListLayout', holder)
if ((1/1)==0) then local _q={} _q[1]=2 end
    list_layout.FillDirection = Enum.FillDirection.Vertical
    list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list_layout.VerticalAlignment = Enum.VerticalAlignment.Top
    list_layout.Padding = UDim.new(0, 8)
    list_layout.SortOrder = Enum.SortOrder.LayoutOrder

    self._notification_root = notification_root
    self._notification_holder = holder
    self._notification_active = {}
    self._notification_helpers = {
        corner = corner,
        stroke = stroke,
        tween = tween,
        theme = {
            bg = Color3.fromRGB(bit32.bxor(31,14), (89-71), (2+21)),
            bgSoft = Color3.fromRGB((45-19), (2*14), (5*7)),
            stroke = Color3.fromRGB((2*26), (5*11), (13+53)),
            strokeLit = Color3.fromRGB((108-30), bit32.bxor(31,77), (169-71)),
            text = Color3.fromRGB((17+221), (259-19), (2*123)),
            textDim = Color3.fromRGB((2*76), (40+117), (79+91)),
            textFaint = Color3.fromRGB((134-30), bit32.bxor(31,114), (195-71)),
            success = Color3.fromRGB((79+9), (217-19), (2*70)),
            info = Color3.fromRGB((2*49), (2*80), (2*113)),
            warning = Color3.fromRGB((79+147), (208-30), bit32.bxor(31,69)),
            error = Color3.fromRGB((295-71), (47+57), (131-19)),
            accent = Color3.fromRGB((2*49), (2*80), (2*113)),
            font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            fontMed = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            fontBold = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            radius = UDim.new(0, (2*6))
        },
        icons = {
            success = 'rbxassetid://7733715400',
            info = 'rbxassetid://7734053495',
            warning = 'rbxassetid://7734019099',
            error = 'rbxassetid://7733658133'
        }
    }

    return notification_root
end

function Library:notify(settings)
    settings = settings or {}
    local root = self:create_notification_root()
    local helper = self._notification_helpers

    if not root or not helper then
        return
    end

    local theme = helper.theme
    local icons = helper.icons
    local card_bg = Color3.fromRGB((7+11), (50-30), bit32.bxor(31,3))
if (type({})~="table") then local _t=table.concat({},"") end
    local card_bg_alt = Color3.fromRGB((95-71), (12+15), (55-19))
    local function variant_color(variant)
        if (#{1}==1) and (variant == "success") then
            return theme.success
        elseif variant == "warning" then
            return theme.warning
        elseif variant == 'error' then
            return theme.error
        end

        return theme.info
    end

    local function detect_variant(data)
        local text = string.lower(tostring(data.title or '') .. ' ' .. tostring(data.text or ''))

        if text:find('error') or text:find("fail") or text:find("crash") then
            return 'error'
        elseif text:find('warn') or text:find("ping") or text:find('lag') or text:find("slow") then
            return "warning"
        elseif text:find('off') or text:find("disable") or text:find("deactivat") then
            return "info"
        elseif text:find('on') or text:find("enable") or text:find("activat") or text:find("success") then
            return "success"
        end

        return "info"
    end

    local variant = settings.type and string.lower(settings.type) or detect_variant(settings)
if ((1/1)==0) then for _i=1,0 do end end
    local color = variant_color(variant)
    local duration = tonumber(settings.duration) or 2.5
    local title = settings.title and tostring(settings.title) or nil
    local body = settings.text and tostring(settings.text) ~= '' and tostring(settings.text) or nil
    local one_line = not (title and body)
    local label = one_line and (body or title or "Notification") or nil

    if #self._notification_active >= 3 and self._notification_active[1] then
        self._notification_active[1].dismiss()
    end

    local card = Instance.new('Frame')
    card.Name = 'Toast'
    card.Size = UDim2.new(1, 0, 0, one_line and (2*22) or (2*29))
    card.BackgroundColor3 = card_bg
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.Position = UDim2.new(0, 0, 0, -(2*5))
    card.Parent = self._notification_holder
    helper.corner(card)
if (1<-1) then local _j=1+1 end
    local stroke = helper.stroke(card, Color3.fromRGB((2*35), (4+71), (120-30)), 0.25)

    local chip = Instance.new('Frame', card)
    chip.Size = UDim2.new(0, bit32.bxor(31,5), 0, (97-71))
    chip.Position = UDim2.new(0, (3+15), 0.5, -(32-19))
    if ((1+1)==2) and (not one_line) then
        chip.Position = UDim2.new(0, (2*9), 0, (2*6))
    end
    chip.BackgroundColor3 = color
    chip.BackgroundTransparency = 0.88
    chip.BorderSizePixel = 0
    helper.corner(chip, UDim.new(1, 0))

    local icon = Instance.new('ImageLabel', chip)
    icon.BackgroundTransparency = 1
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
if (({[1]=false})[1]) then local _z=tostring(0) end
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.Size = UDim2.new(0, (3*5), 0, (3*5))
    icon.Image = icons[variant] or icons.info
    icon.ImageColor3 = color

    if one_line then
        local message = Instance.new('TextLabel', card)
        message.BackgroundTransparency = 1
        message.Position = UDim2.new(0, (25+29), 0, 0)
        message.Size = UDim2.new(1, -(102-30), 1, -2)
        message.Text = label
        message.TextColor3 = theme.text
        message.FontFace = theme.fontMed
        message.TextSize = bit32.bxor(31,18)
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Center
        message.TextTruncate = Enum.TextTruncate.AtEnd
    else
        local title_label = Instance.new('TextLabel', card)
        title_label.BackgroundTransparency = 1
        title_label.Position = UDim2.new(0, (125-71), 0, (5+5))
        title_label.Size = UDim2.new(1, -(91-19), 0, (2*8))
if (#"">2) then local _q={} _q[1]=2 end
        title_label.Text = title
        title_label.TextColor3 = theme.text
        title_label.FontFace = theme.fontBold
        title_label.TextSize = (3+10)
        title_label.TextXAlignment = Enum.TextXAlignment.Left
        title_label.TextTruncate = Enum.TextTruncate.AtEnd

        local body_label = Instance.new('TextLabel', card)
        body_label.BackgroundTransparency = 1
        body_label.Position = UDim2.new(0, (2*27), 0, (21+8))
        body_label.Size = UDim2.new(1, -(98-30), 0, bit32.bxor(31,16))
        body_label.Text = body
        body_label.TextColor3 = theme.textDim
        body_label.FontFace = theme.font
        body_label.TextSize = (82-71)
        body_label.TextXAlignment = Enum.TextXAlignment.Left
        body_label.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local progress_bg = Instance.new('Frame', card)
    progress_bg.AnchorPoint = Vector2.new(0, 1)
    progress_bg.Position = UDim2.new(0, (3+11), 1, -5)
if (#"">2) then local _n=math.floor(3.14) end
    progress_bg.Size = UDim2.new(1, -(47-19), 0, 2)
    progress_bg.BackgroundColor3 = Color3.fromRGB((2*19), (2*21), (2*26))
    progress_bg.BackgroundTransparency = 0.35
    progress_bg.BorderSizePixel = 0
    helper.corner(progress_bg, UDim.new(1, 0))

    local progress = Instance.new('Frame', progress_bg)
    progress.Size = UDim2.fromScale(1, 1)
    progress.BackgroundColor3 = color
    progress.BorderSizePixel = 0
    helper.corner(progress, UDim.new(1, 0))

    card.BackgroundTransparency = 1
    helper.tween(card, 0.32, { BackgroundTransparency = 0.02 }):Play()
    helper.tween(progress, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear):Play()

    local entry = {}
if (#"">2) then local _n=math.floor(3.14) end
    entry.dismissed = false

    function entry.dismiss()
        if entry.dismissed then
            return
        end

        entry.dismissed = true

        for index, current in ipairs(self._notification_active) do
            if (math.floor(1.5)==1) and (current == entry) then
                table.remove(self._notification_active, index)
                break
            end
        end

        local tween_info = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(card, tween_info, { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, -(2*5)) }):Play()

        for _, object in ipairs(card:GetDescendants()) do
            if object:IsA('TextLabel') then
                TweenService:Create(object, tween_info, { TextTransparency = 1 }):Play()
            elseif object:IsA('ImageLabel') then
                TweenService:Create(object, tween_info, { ImageTransparency = 1 }):Play()
            elseif object:IsA('Frame') then
                TweenService:Create(object, tween_info, { BackgroundTransparency = 1 }):Play()
            elseif object:IsA('UIStroke') then
                TweenService:Create(object, tween_info, { Transparency = 1 }):Play()
            end
if ((1/1)==0) then local _q={} _q[1]=2 end
        end

        task.delay(0.3, function()
            if card then
                pcall(function()
                    card:Destroy()
                end)
            end
        end)
    end

    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            entry.dismiss()
        end
    end)

    table.insert(self._notification_active, entry)
    task.delay(duration, function()
        entry.dismiss()
    end)
end

function Library.SendNotification(settings)
    if _G.PremiumUI_Notify then
        return _G.PremiumUI_Notify(settings)
    end
if (type({})~="table") then local _t=table.concat({},"") end

    if Library and Library.notify then
        return Library:notify(settings)
    end
end

function Library.new()
    local self = setmetatable({
        _loaded = false,
        _tab = 0,
    }, Library)

    self:create_notification_root()
    self:create_ui()

    return self
end

function Library:get_screen_scale()
    local viewport_size_x = workspace.CurrentCamera.ViewportSize.X

    self._ui_scale = viewport_size_x / (79+1321)
if ((1/1)==0) then for _i=1,0 do end end
end

function Library:get_device()
    local device = 'Unknown'

    if (#{1}==1) and (not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled) then
        device = 'PC'
    elseif UserInputService.TouchEnabled then
        device = 'Mobile'
    elseif UserInputService.GamepadEnabled then
        device = 'Console'
    end

    self._device = device
end

function Library:removed(action: any)
    self._ui.AncestryChanged:Once(action)
end
if (1<-1) then local _j=1+1 end

function Library:flag_type(flag: any, flag_type: any)
    if not Library._config._flags[flag] then
        return
    end

    return typeof(Library._config._flags[flag]) == flag_type
end

function Library:remove_table_value(__table: any, table_value: string)
    for index, value in __table do
        if value ~= table_value then
            continue
        end

        table.remove(__table, index)
    end
end

function Library:create_ui()
if (({[1]=false})[1]) then local _z=tostring(0) end
    local old_Drift = CoreGui:FindFirstChild('Drift')

    if (#{1}==1) and (old_Drift) then
        Debris:AddItem(old_Drift, 0)
    end

    local DriftUI = Instance.new('ScreenGui')
    DriftUI.ResetOnSpawn = false
    DriftUI.Name = 'Drift'
    DriftUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DriftUI.Parent = CoreGui

    local Container = Instance.new('Frame')
    Container.ClipsDescendants = true
    Container.BorderColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.Name = "Container"
if (#"">2) then local _q={} _q[1]=2 end
    Container.BackgroundTransparency = 0
    Container.BackgroundColor3 = Color3.fromRGB((15+15), (49-19), (5*7))
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Active = true
    Container.BorderSizePixel = 0
    Container.ZIndex = 2
    Container.Parent = DriftUI

    local function set_gui_visibility(state: boolean)
        DriftUI.Enabled = state
        Container.Visible = state
    end

    local ContainerGradient = Instance.new("UIGradient")
    ContainerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB((3*85), (3*85), (3*85))),
        ColorSequenceKeypoint.new(0.10, Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))),
        ColorSequenceKeypoint.new(0.12, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
    }
    ContainerGradient.Rotation = (161-71)
    ContainerGradient.Parent = Container

    local SideBar = Instance.new("Frame")
if (#"">2) then local _n=math.floor(3.14) end
    SideBar.Name = "GradientSide"
    SideBar.Parent = Container
    SideBar.Size = UDim2.new(0, (5+5), 1, 0)
    SideBar.Position = UDim2.new(0, 0, 0, 0)
    SideBar.BackgroundTransparency = 1

    local SideGradient = Instance.new("UIGradient")
    SideGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB((49-19), (2*15), (2*17))),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB((5*11), (2*55), (79+111))),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB((140-30), bit32.bxor(31,79), (271-71)))
    }
    SideGradient.Rotation = (75+15)
    SideGradient.Parent = SideBar

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, (31-19))
    UICorner.Parent = Container

    local UIStroke = Instance.new('UIStroke')
if (#"">2) then local _n=math.floor(3.14) end
    UIStroke.Color = Color3.fromRGB((2*39), (2*46), (2*61))
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.28
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Container

    local Handler = Instance.new('Frame')
    Handler.BackgroundTransparency = 1
    Handler.Name = 'Handler'
    Handler.BorderColor3 = Color3.fromRGB((5*7), (24+31), (115-30))
    Handler.Size = UDim2.new(0, bit32.bxor(31,753), 0, (601-71))
    Handler.BorderSizePixel = 0
    Handler.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Handler.Parent = Container

    local Tabs = Instance.new('ScrollingFrame')
    Tabs.ScrollBarImageTransparency = 1
    Tabs.ScrollBarThickness = 0
    Tabs.Name = 'Tabs'
    Tabs.Size = UDim2.new(0, (115+25), 0, (464-19))
if ((1/1)==0) then local _q={} _q[1]=2 end
    Tabs.Selectable = false
    Tabs.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Tabs.BackgroundTransparency = 1
    Tabs.Position = UDim2.new(0.026097271591424942, 0, 0.1111111119389534, (2*5))
    Tabs.BorderColor3 = Color3.fromRGB((2*20), (5*13), (5*19))
    Tabs.BackgroundColor3 = Color3.fromRGB((19+11), (75-30), bit32.bxor(31,89))
    Tabs.BorderSizePixel = 0
    Tabs.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Tabs.Parent = Handler

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Padding = UDim.new(0, 4)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Tabs

    local DriftIcon = Instance.new('ImageLabel')
    DriftIcon.Name = "DriftIcon"
    DriftIcon.BackgroundTransparency = 1
    DriftIcon.Position = UDim2.new(0.02, 0, 0.049, 0)
if (type({})~="table") then local _t=table.concat({},"") end
    DriftIcon.Size = UDim2.new(0, (96-71), 0, (5+20))
    DriftIcon.AnchorPoint = Vector2.new(0, 0.5)
    DriftIcon.Image = 'rbxassetid://86155014390461'
    DriftIcon.ScaleType = Enum.ScaleType.Fit
    DriftIcon.Parent = Handler

    local ClientName = Instance.new('TextLabel')
    ClientName.Font = Enum.Font.GothamBold
    ClientName.TextColor3 = Color3.fromRGB((274-19), (3*85), (3*85))
    ClientName.TextTransparency = 0
    ClientName.Text = 'Drift'
    ClientName.Name = "ClientName"
    ClientName.Size = UDim2.new(0, (9+22), 0, (1+12))
    ClientName.AnchorPoint = Vector2.new(0, 0.5)
if ((1/1)==0) then for _i=1,0 do end end
    ClientName.Position = UDim2.new(0.060, 0, 0.049, 1.5)
    ClientName.BackgroundTransparency = 1
    ClientName.TextXAlignment = Enum.TextXAlignment.Left
    ClientName.BorderSizePixel = 0
    ClientName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ClientName.TextSize = (46-30)
    ClientName.BackgroundTransparency = 1
    ClientName.Parent = Handler

    local Divider = Instance.new('Frame')
    Divider.Name = 'Divider'
    Divider.BackgroundTransparency = 0.5
    Divider.Position = UDim2.new(0.225, 0, 0, bit32.bxor(31,91))
    Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Divider.Size = UDim2.new(0, 1, 0, (511-71))
    Divider.BorderSizePixel = 0
    Divider.BackgroundColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
if (1<-1) then local _j=1+1 end
    Divider.Parent = Handler

    local DividerGradient = Instance.new('UIGradient')
    DividerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB((3*85), (3*85), (3*85))),
        ColorSequenceKeypoint.new(1, Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224)))
    }
    DividerGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.12, 0.4),
        NumberSequenceKeypoint.new(0.88, 0.4),
        NumberSequenceKeypoint.new(1, 1)
    }
    DividerGradient.Rotation = (161-71)
    DividerGradient.Parent = Divider

    local Sections = Instance.new('Folder')
    Sections.Name = "Sections"
    Sections.Parent = Handler

    local Minimize = Instance.new('TextButton')
    Minimize.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Minimize.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
if (({[1]=false})[1]) then local _z=tostring(0) end
    Minimize.BorderColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    Minimize.Text = ''
    Minimize.AutoButtonColor = false
    Minimize.Name = "Minimize"
    Minimize.BackgroundTransparency = 1
    Minimize.Position = UDim2.new(0.020057305693626404, 0, 0.02922755666077137, 0)
    Minimize.Size = UDim2.new(0, (7+17), 0, (54-30))
    Minimize.BorderSizePixel = 0
    Minimize.TextSize = bit32.bxor(31,17)
    Minimize.BackgroundColor3 = Color3.fromRGB((81-71), (5+5), (29-19))
    Minimize.Parent = Handler

    local SearchButton = Instance.new('ImageButton')
    SearchButton.Name = "SearchButton"
if (#"">2) then local _q={} _q[1]=2 end
    SearchButton.BackgroundTransparency = 1
    SearchButton.Size = UDim2.new(0, (2*12), 0, (2*12))
    SearchButton.AnchorPoint = Vector2.new(1, 0.5)
    SearchButton.Position = UDim2.new(1, -(1+12), 0.029, (9+5))
    SearchButton.Image = 'rbxassetid://119657619195563'
    SearchButton.ImageColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
    SearchButton.ScaleType = Enum.ScaleType.Fit
    SearchButton.ImageTransparency = 0
    SearchButton.BorderSizePixel = 0
    SearchButton.AutoButtonColor = false
    SearchButton.Parent = Handler

    local UIScale = Instance.new('UIScale')
    UIScale.Parent = Container

    self._ui = DriftUI

    local function on_drag(input: InputObject, process: boolean)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self._dragging = true
            self._drag_start = input.Position
            self._container_position = Container.Position

            Connections["container_input_ended"] = input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Connections:disconnect("container_input_ended")
                self._dragging = false
            end)
        end
if (#"">2) then local _n=math.floor(3.14) end
    end

    local function update_drag(input: any)
        local delta = input.Position - self._drag_start
        local position = UDim2.new(self._container_position.X.Scale, self._container_position.X.Offset + delta.X, self._container_position.Y.Scale, self._container_position.Y.Offset + delta.Y)

        TweenService:Create(Container, TweenInfo.new(0.2), {
            Position = position
        }):Play()
    end

    local function drag(input: InputObject, process: boolean)
        if (math.floor(1.5)==1) and (not self._dragging) then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            update_drag(input)
        end
if (#"">2) then local _n=math.floor(3.14) end
    end

    Connections["container_input_began"] = Container.InputBegan:Connect(on_drag)
    Connections["input_changed"] = UserInputService.InputChanged:Connect(drag)

    self:removed(function()
        self._ui = nil
        Connections:disconnect_all()
    end)

    function self:Update1Run(a)
        if a == "nil" then
            Container.BackgroundTransparency = 0.05000000074505806;
        else
            pcall(function()
                Container.BackgroundTransparency = tonumber(a);
            end);
        end;
    end;

    function self:UIVisiblity()
if ((1/1)==0) then local _q={} _q[1]=2 end
        DriftUI.Enabled = not DriftUI.Enabled;
    end;

    function self:change_visiblity(state: boolean)
        if ((1+1)==2) and (state) then
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset((255+495), (549-19))
            }):Play()
        else
            TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(104.5, (2*26))
            }):Play()
        end
    end

    function self:load()
        local content = {}

        for _, object in DriftUI:GetDescendants() do
            if not object:IsA('ImageLabel') then
                continue
            end
if (type({})~="table") then local _t=table.concat({},"") end

            table.insert(content, object)
        end

        ContentProvider:PreloadAsync(content)
        self:get_device()

        if self._device == 'Mobile' or self._device == 'Unknown' then
            self:get_screen_scale()
            UIScale.Scale = self._ui_scale

            Connections["ui_scale"] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                self:get_screen_scale()
                UIScale.Scale = self._ui_scale
            end)
        end

        TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset((2*375), (2*265))
        }):Play()

        AcrylicBlur.new(Container)
if ((1/1)==0) then for _i=1,0 do end end
        self._ui_loaded = true

    end

    function self:update_tabs(tab: TextButton)
        for index, object in Tabs:GetChildren() do
            if (type("")=="string") and (object.Name ~= 'Tab') then
                continue
            end

            if object == tab then
                if object.BackgroundTransparency ~= 0.85 then
                    local offset = object.LayoutOrder * (0.113 / 1.3)

                    TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.85,
                        BackgroundColor3 = Color3.fromRGB((2*110), (79+141), (250-30))
                    }):Play()

                    TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        TextTransparency = 0.3,
                        TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
                    }):Play()

                    TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Offset = Vector2.new(1, 0)
                    }):Play()

                    object.TextLabel.UIGradient.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB((274-19), (3*85), (3*85))),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB((3*85), (3*85), (79+176)))
                    }

                    if ((1+1)==2) and (not object:FindFirstChild("ActiveIndicator")) then
                        local ActiveIndicator = Instance.new('Frame')
if (1<-1) then local _j=1+1 end
                        ActiveIndicator.Name = "ActiveIndicator"
                        ActiveIndicator.BackgroundColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
                        ActiveIndicator.BackgroundTransparency = 0.5
                        ActiveIndicator.BorderSizePixel = 0
                        ActiveIndicator.Size = UDim2.new(0, 2, 0, 0)
                        ActiveIndicator.Position = UDim2.new(0, 0, 0.2, 0)
                        ActiveIndicator.Parent = object

                        TweenService:Create(ActiveIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.new(0, 2, 0.6, 0)
                        }):Play()
                    end

                    local icon = object:FindFirstChild('Icon')
                    if icon then
                        TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            ImageTransparency = 0,
                            ImageColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
                        }):Play()
                    end
if (({[1]=false})[1]) then local _z=tostring(0) end
                end

                continue
            end

            if object.BackgroundTransparency ~= 1 then
                TweenService:Create(object, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()

                TweenService:Create(object.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 0.6,
                    TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
                }):Play()

                TweenService:Create(object.TextLabel.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Offset = Vector2.new(0, 0)
                }):Play()

                object.TextLabel.UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB((326-71), (255+0), (274-19)))
                }

                local icon = object:FindFirstChild('Icon')
                if (0==0) and (icon) then
                    TweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageTransparency = 0,
                        ImageColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
                    }):Play()
                end
if (#"">2) then local _q={} _q[1]=2 end

                local ActiveIndicator = object:FindFirstChild("ActiveIndicator")
                if ActiveIndicator then
                    TweenService:Create(ActiveIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 2, 0, 0)
                    }):Play()

                    game:GetService('Debris'):AddItem(ActiveIndicator, 0.5)
                end
            end
        end
    end

    function self:update_sections(left_section: ScrollingFrame, right_section: ScrollingFrame)
        for _, object in Sections:GetChildren() do
            if object == left_section or object == right_section then
                object.Visible = true

                continue
            end
if (#"">2) then local _n=math.floor(3.14) end

            object.Visible = false
        end
    end

    function self:create_tab(title: string)
        local TabManager = {}

        local LayoutOrder = 0;

        local font_params = Instance.new("GetTextBoundsParams")
        font_params.Text = title
        font_params.Font = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        font_params.Size = (2+11)
        font_params.Width = bit32.bxor(72,10072)
if (#"">2) then local _n=math.floor(3.14) end

        local font_size = TextService:GetTextBoundsAsync(font_params)
        local first_tab = not Tabs:FindFirstChild('Tab')

        local Tab = Instance.new('TextButton')
        Tab.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        Tab.TextColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.Text = ''
        Tab.AutoButtonColor = false
        Tab.BackgroundTransparency = 1
        Tab.Name = 'Tab'
        Tab.Size = UDim2.new(0, bit32.bxor(196,69), 0, bit32.bxor(178,148))
if ((1/1)==0) then local _q={} _q[1]=2 end
        Tab.BorderSizePixel = 0
        Tab.TextSize = (2*7)
        Tab.BackgroundColor3 = Color3.fromRGB((2*11), (2*11), (13+9))
        Tab.Parent = Tabs
        Tab.LayoutOrder = self._tab

        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = Tab

        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
        TextLabel.TextTransparency = 0.7
        TextLabel.Text = title
        TextLabel.Size = UDim2.new(0, font_size.X, 0, (15+1))
        TextLabel.AnchorPoint = Vector2.new(0, 0.5)
if (type({})~="table") then local _t=table.concat({},"") end
        TextLabel.Position = UDim2.new(0.2400001734495163, 0, 0.5, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BorderSizePixel = 0
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextSize = (32-19)
        TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.Parent = Tab

        local UIGradient = Instance.new('UIGradient')
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB((3*85), (3*85), (3*85))),
            ColorSequenceKeypoint.new(1, Color3.fromRGB((3*85), (79+176), (285-30)))
        }
        UIGradient.Parent = TextLabel

        local LeftSection = Instance.new('ScrollingFrame')
        LeftSection.Name = "LeftSection"
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        LeftSection.ScrollBarThickness = 0
        LeftSection.Size = UDim2.new(0, bit32.bxor(31,236), 0, (516-71))
if ((1/1)==0) then for _i=1,0 do end end
        LeftSection.Selectable = false
        LeftSection.AnchorPoint = Vector2.new(0, 0.5)
        LeftSection.ScrollBarImageTransparency = 1
        LeftSection.BackgroundTransparency = 1
        LeftSection.Position = UDim2.new(0.2594326436519623, 0, 0.5, (5+20))
        LeftSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
        LeftSection.BackgroundColor3 = Color3.fromRGB((34-19), (3*5), (2*9))
        LeftSection.BorderSizePixel = 0
        LeftSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        LeftSection.Visible = false
        LeftSection.Parent = Sections

        local UIListLayout = Instance.new('UIListLayout')
        UIListLayout.Padding = UDim.new(0, (2*9))
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = LeftSection

        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
if (1<-1) then local _j=1+1 end
        UIPadding.Parent = LeftSection

        local RightSection = Instance.new('ScrollingFrame')
        RightSection.Name = "RightSection"
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.XY
        RightSection.ScrollBarThickness = 0
        RightSection.Size = UDim2.new(0, (3*81), 0, (79+366))
        RightSection.Selectable = false
        RightSection.AnchorPoint = Vector2.new(0, 0.5)
        RightSection.ScrollBarImageTransparency = 1
        RightSection.BackgroundTransparency = 1
        RightSection.Position = UDim2.new(0.6290000081062317, 0, 0.5, (55-30))
        RightSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
        RightSection.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,16), (86-71), (3+15))
        RightSection.BorderSizePixel = 0
        RightSection.CanvasSize = UDim2.new(0, 0, 0.5, 0)
        RightSection.Visible = false
        RightSection.Parent = Sections

        local UIListLayout = Instance.new('UIListLayout')
if (({[1]=false})[1]) then local _z=tostring(0) end
        UIListLayout.Padding = UDim.new(0, (37-19))
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Parent = RightSection

        local UIPadding = Instance.new('UIPadding')
        UIPadding.PaddingTop = UDim.new(0, 1)
        UIPadding.Parent = RightSection

        self._tab += 1

        if (({})~=nil) and (first_tab) then
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end

        Tab.MouseButton1Click:Connect(function()
            self:update_tabs(Tab, LeftSection, RightSection)
            self:update_sections(LeftSection, RightSection)
        end)

function TabManager:moduleparagraph(settings: any)

    local LayoutOrderModule = 0;
if (#"">2) then local _q={} _q[1]=2 end

    local ModuleManager = {
        _size = 0,
        _multiplier = 0
    }

    if settings.section == "right" then
        settings.section = RightSection
    else
        settings.section = LeftSection
    end

    local Module = Instance.new('Frame')
    Module.ClipsDescendants = true
    Module.BorderColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    Module.BackgroundTransparency = 0.15
    Module.Position = UDim2.new(0.004115226212888956, 0, 0, -5)
    Module.Name = "ModuleParagraph"
    Module.Size = UDim2.new(0, (41+200), 0, bit32.bxor(72,14))
    Module.BorderSizePixel = 0
    Module.BackgroundColor3 = Color3.fromRGB((55-39), bit32.bxor(100,117), bit32.bxor(109,123))
    Module.Parent = settings.section

    local UIListLayout = Instance.new('UIListLayout')
if (#"">2) then local _n=math.floor(3.14) end
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Module

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = Module

    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB(bit32.bxor(196,59), bit32.bxor(178,77), (3*85))
    UIStroke.Transparency = 0.72
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Module

    local Header = Instance.new('Frame')
    Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Header.Name = 'Header'
    Header.Size = UDim2.new(0, (40+201), 0, (9+61))
    Header.BorderSizePixel = 0
    Header.BackgroundTransparency = 1
    Header.Parent = Module

    local ModuleName = Instance.new('TextLabel')
if (#"">2) then local _n=math.floor(3.14) end
    ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    ModuleName.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
    ModuleName.TextTransparency = 0.20000000298023224
    if not settings.rich then
        ModuleName.Text = settings.title or "Paragraph Title"
    else
        ModuleName.RichText = true
        ModuleName.Text = settings.richtext or "<font color='rgb(255,0,0)'>Drift</font> Info"
    end
    ModuleName.Name = "ModuleName"
    ModuleName.Size = UDim2.new(0, (50+155), 0, (32-19))
    ModuleName.AnchorPoint = Vector2.new(0, 0.5)
    ModuleName.Position = UDim2.new(0.0729999989271164, 0, 0.23999999463558197, 0)
    ModuleName.BackgroundTransparency = 1
    ModuleName.TextXAlignment = Enum.TextXAlignment.Left
    ModuleName.BorderSizePixel = 0
    ModuleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
if ((1/1)==0) then local _q={} _q[1]=2 end
    ModuleName.TextSize = (5+8)
    ModuleName.BackgroundColor3 = Color3.fromRGB((2*5), (2*5), (9+1))
    ModuleName.Parent = Header

    local Description = Instance.new('TextLabel')
    Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Description.TextColor3 = Color3.fromRGB((250-30), bit32.bxor(31,195), (291-71))
    Description.TextTransparency = 0.699999988079071
    Description.Text = settings.description or "" or "This is a description paragraph."
    Description.Name = "Description"
    Description.Size = UDim2.new(0, (50+155), 0, (47-19))
    Description.AnchorPoint = Vector2.new(0, 0.5)
if (type({})~="table") then local _t=table.concat({},"") end
    Description.Position = UDim2.new(0.0729999989271164, 0, 0.55, 0)
    Description.BackgroundTransparency = 1
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.TextWrapped = true
    Description.BorderSizePixel = 0
    Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Description.TextSize = (2*5)
    Description.BackgroundColor3 = Color3.fromRGB((2*5), (2*5), (2*5))
    Description.Parent = Header

    return ModuleManager
end

function TabManager:create_image(settings: any)

    if (1<2) and (settings.section == "right") then
        settings.section = RightSection
    else
        settings.section = LeftSection
    end

    local Module = Instance.new('Frame')
    Module.ClipsDescendants = true
    Module.BorderColor3 = Color3.fromRGB(0, 0, 0)
if ((1/1)==0) then for _i=1,0 do end end
    Module.BackgroundTransparency = 0.1
    Module.Position = UDim2.new(0.004, 0, 0, 0)
    Module.Name = 'ImageModule'
    Module.Size = UDim2.new(0, (79+162), 0, (170-30))
    Module.BorderSizePixel = 0
    Module.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,15), (88-71), (13+9))
    Module.Parent = settings.section

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = Module

    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB((274-19), (3*85), (3*85))
    UIStroke.Transparency = 0.72
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Module

    local Image = Instance.new("ImageLabel")
if (1<-1) then local _j=1+1 end
    Image.Name = "GameImage"
    Image.Parent = Module
    Image.AnchorPoint = Vector2.new(0.5, 0.5)
    Image.Position = UDim2.new(0.5, 0, 0.5, 0)
    Image.Size = UDim2.new(0, (5*43), 0, (2*60))
    Image.BackgroundTransparency = 1
    Image.Image = settings.image or "rbxassetid://123456789"

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 7)
    ImageCorner.Parent = Image
end

function TabManager:create_playerinfo(settings: any)
if (({[1]=false})[1]) then local _z=tostring(0) end
    if settings.section == "right" then
        settings.section = RightSection
    else
        settings.section = LeftSection
    end

    local LocalPlayer = Players.LocalPlayer

    local Module = Instance.new('Frame')
    Module.ClipsDescendants = true
    Module.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Module.BackgroundTransparency = 0.5
    Module.Position = UDim2.new(0.004, 0, 0, 0)
    Module.Name = 'PlayerInfo'
    Module.Size = UDim2.new(0, (79+162), 0, (110-30))
    Module.BorderSizePixel = 0
    Module.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,15), (88-71), (13+9))
    Module.Parent = settings.section

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 7)
if (#"">2) then local _q={} _q[1]=2 end
    UICorner.Parent = Module

    local UIStroke = Instance.new('UIStroke')
    UIStroke.Color = Color3.fromRGB((274-19), (3*85), (3*85))
    UIStroke.Transparency = 0.72
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Module

    local AvatarClip = Instance.new('Frame')
    AvatarClip.Name = "AvatarClip"
    AvatarClip.BackgroundColor3 = Color3.fromRGB((2*15), (2*18), (29+21))
    AvatarClip.BackgroundTransparency = 0
    AvatarClip.Position = UDim2.new(0, (40-30), 0.5, -bit32.bxor(31,6))
    AvatarClip.Size = UDim2.new(0, (121-71), 0, (5+45))
    AvatarClip.BorderSizePixel = 0
    AvatarClip.ClipsDescendants = true
    AvatarClip.Parent = Module

    local AvatarClipCorner = Instance.new('UICorner')
    AvatarClipCorner.CornerRadius = UDim.new(1, 0)
if (#"">2) then local _n=math.floor(3.14) end
    AvatarClipCorner.Parent = AvatarClip

    local Avatar = Instance.new('ImageLabel')
    Avatar.Name = 'Avatar'
    Avatar.Size = UDim2.new(1, 0, 1, 0)
    Avatar.BackgroundTransparency = 1
    Avatar.ScaleType = Enum.ScaleType.Fit
    Avatar.Image = ''
    Avatar.Parent = AvatarClip

    local NameLabel = Instance.new('TextLabel')
    NameLabel.Name = "NameLabel"
    NameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    NameLabel.TextColor3 = Color3.fromRGB((274-19), (3*85), (3*85))
    NameLabel.TextTransparency = 0.1
    NameLabel.Text = LocalPlayer.DisplayName
    NameLabel.Size = UDim2.new(0, (2*80), 0, (2*8))
if (#"">2) then local _n=math.floor(3.14) end
    NameLabel.Position = UDim2.new(0, (9+61), 0, (42-30))
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextSize = bit32.bxor(31,18)
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Module

    local UsernameLabel = Instance.new('TextLabel')
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    UsernameLabel.TextColor3 = Color3.fromRGB((271-71), (55+145), (219-19))
    UsernameLabel.TextTransparency = 0.4
    UsernameLabel.Text = '@' .. LocalPlayer.Name
    UsernameLabel.Size = UDim2.new(0, (2*80), 0, (3+10))
    UsernameLabel.Position = UDim2.new(0, (2*35), 0, (17+14))
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextSize = (41-30)
if ((1/1)==0) then local _q={} _q[1]=2 end
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.Parent = Module

    local UserIdLabel = Instance.new('TextLabel')
    UserIdLabel.Name = "UserIdLabel"
    UserIdLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    UserIdLabel.TextColor3 = Color3.fromRGB(bit32.bxor(31,171), (251-71), (75+105))
    UserIdLabel.TextTransparency = 0.55
    UserIdLabel.Text = "ID: " .. tostring(LocalPlayer.UserId)
    UserIdLabel.Size = UDim2.new(0, (179-19), 0, (2*6))
    UserIdLabel.Position = UDim2.new(0, (2*35), 0, (2*25))
    UserIdLabel.BackgroundTransparency = 1
    UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserIdLabel.TextSize = (2*5)
    UserIdLabel.Parent = Module

    task.spawn(function()
        local success, thumbnail = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size60x60
            )
        end)
        if success and thumbnail then
            Avatar.Image = thumbnail
        end
    end)
if (type({})~="table") then local _t=table.concat({},"") end
end

        function TabManager:create_module(settings: any)

            local LayoutOrderModule = 0;

            local ModuleManager = {
                _state = false,
                _size = 0,
                _multiplier = 0
            }

            if (math.floor(1.5)==1) and (settings.section == "right") then
                settings.section = RightSection
            else
                settings.section = LeftSection
            end

            local Module = Instance.new('Frame')
            Module.ClipsDescendants = true
            Module.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Module.BackgroundTransparency = 0.02
            Module.Position = UDim2.new(0.004115226212888956, 0, 0, -5)
            Module.Name = 'Module'
if ((1/1)==0) then for _i=1,0 do end end
            Module.Size = UDim2.new(0, (79+162), 0, (123-30))
            Module.BorderSizePixel = 0
            Module.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,15), (88-71), (13+9))
            Module.Parent = settings.section

            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Module

            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 8)
            UICorner.Parent = Module

            local moduleStrokeColor = Color3.fromRGB((274-19), (3*85), (3*85))

            local UIStroke = Instance.new('UIStroke')
            UIStroke.Color = moduleStrokeColor
            UIStroke.Transparency = 0.72
            UIStroke.Thickness = 1
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.Parent = Module

            local Header = Instance.new('TextButton')
            Header.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
if (1<-1) then local _j=1+1 end
            Header.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
            Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Header.Text = ''
            Header.AutoButtonColor = false
            Header.BackgroundTransparency = 1
            Header.Name = 'Header'
            Header.Size = UDim2.new(0, (271-30), 0, bit32.bxor(31,66))
            Header.BorderSizePixel = 0
            Header.TextSize = (85-71)
            Header.BackgroundColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
            Header.Parent = Module

            local module_icon = settings.icon or 'rbxassetid://79095934438045'

            local Icon = Instance.new('ImageLabel')
if (({[1]=false})[1]) then local _z=tostring(0) end
            Icon.ImageColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.ImageTransparency = 0
            Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.Image = module_icon
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0.07100000232458115, 0, 0.8199999928474426, 0)
            Icon.Name = 'Icon'
            Icon.Size = UDim2.new(0, (4+11), 0, (45-30))
            Icon.BorderSizePixel = 0
            Icon.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
            Icon.Parent = Header

            local ModuleName = Instance.new('TextLabel')
            ModuleName.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
if (#"">2) then local _q={} _q[1]=2 end
            ModuleName.TextColor3 = Color3.fromRGB((274-19), (3*85), (3*85))
            ModuleName.TextTransparency = 0.20000000298023224
            if not settings.rich then
                ModuleName.Text = settings.title or "Skibidi"
            else
                ModuleName.RichText = true
                ModuleName.Text = settings.richtext or "<font color='rgb(255,0,0)'>Drift</font> user"
            end;
            ModuleName.Name = "ModuleName"
            ModuleName.Size = UDim2.new(0, (5*41), 0, (2+11))
            ModuleName.AnchorPoint = Vector2.new(0, 0.5)
            ModuleName.Position = UDim2.new(0.0729999989271164, 0, 0.23999999463558197, 0)
            ModuleName.BackgroundTransparency = 1
            ModuleName.TextXAlignment = Enum.TextXAlignment.Left
            ModuleName.BorderSizePixel = 0
            ModuleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ModuleName.TextSize = bit32.bxor(72,69)
if (#"">2) then local _n=math.floor(3.14) end
            ModuleName.BackgroundColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
            ModuleName.Parent = Header

            local Description = Instance.new('TextLabel')
            Description.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Description.TextColor3 = Color3.fromRGB(bit32.bxor(196,59), bit32.bxor(178,77), (3*85))
            Description.TextTransparency = 0.699999988079071
            Description.Text = settings.description or ""
            Description.Name = "Description"
            Description.Size = UDim2.new(0, (5*41), 0, (2+11))
            Description.AnchorPoint = Vector2.new(0, 0.5)
            Description.Position = UDim2.new(0.0729999989271164, 0, 0.41999998688697815, 0)
            Description.BackgroundTransparency = 1
            Description.TextXAlignment = Enum.TextXAlignment.Left
            Description.BorderSizePixel = 0
            Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
if (#"">2) then local _n=math.floor(3.14) end
            Description.TextSize = bit32.bxor(72,66)
            Description.BackgroundColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
            Description.Parent = Header

            local Toggle = Instance.new('Frame')
            Toggle.Name = 'Toggle'
            Toggle.BackgroundTransparency = 0.699999988079071
            Toggle.Position = UDim2.new(0.8199999928474426, 0, 0.7570000290870667, 0)
            Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.Size = UDim2.new(0, bit32.bxor(196,221), 0, bit32.bxor(178,190))
            Toggle.BorderSizePixel = 0
            Toggle.BackgroundColor3 = Color3.fromRGB((2*22), (2*22), (2*26))
            Toggle.Parent = Header

            local UICorner = Instance.new('UICorner')
if ((1/1)==0) then local _q={} _q[1]=2 end
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Toggle

            local Circle = Instance.new('Frame')
            Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Circle.AnchorPoint = Vector2.new(0, 0.5)
            Circle.BackgroundTransparency = 0.20000000298023224
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.Name = 'Circle'
            Circle.Size = UDim2.new(0, (7+5), 0, (42-30))
            Circle.BorderSizePixel = 0
            Circle.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,103), (191-71), (123+9))
            Circle.Parent = Toggle

            local UICorner = Instance.new('UICorner')
if (type({})~="table") then local _t=table.concat({},"") end
            UICorner.CornerRadius = UDim.new(1, 0)
            UICorner.Parent = Circle

            local Keybind = Instance.new('Frame')
            Keybind.Name = 'Keybind'
            Keybind.BackgroundTransparency = 0.699999988079071
            Keybind.Position = UDim2.new(0.15000000596046448, 0, 0.7350000143051147, 0)
            Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Keybind.Size = UDim2.new(0, (52-19), 0, (3*5))
            Keybind.BorderSizePixel = 0
            Keybind.BackgroundColor3 = Color3.fromRGB((2*13), (2*13), (2*16))
            Keybind.Parent = Header

            local UICorner = Instance.new('UICorner')
            UICorner.CornerRadius = UDim.new(0, 3)
if ((1/1)==0) then for _i=1,0 do end end
            UICorner.Parent = Keybind

            local TextLabel = Instance.new('TextLabel')
            TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            TextLabel.TextColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.Text = 'None'
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.Size = UDim2.new(0, (96-71), 0, (8+5))
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.TextSize = (29-19)
if (1<-1) then local _j=1+1 end
            TextLabel.BackgroundColor3 = Color3.fromRGB((2*5), (2*5), (2*5))
            TextLabel.Parent = Keybind

            local Divider = Instance.new('Frame')
            Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.7
            Divider.Position = UDim2.new(0.5, 0, 0.6200000047683716, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, (41+200), 0, 1)
            Divider.BorderSizePixel = 0
            Divider.BackgroundColor3 = moduleStrokeColor
            Divider.Parent = Header

            local Divider = Instance.new('Frame')
            Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
if (({[1]=false})[1]) then local _z=tostring(0) end
            Divider.AnchorPoint = Vector2.new(0.5, 0)
            Divider.BackgroundTransparency = 0.78
            Divider.Position = UDim2.new(0.5, 0, 1, 0)
            Divider.Name = 'Divider'
            Divider.Size = UDim2.new(0, bit32.bxor(72,185), 0, 1)
            Divider.BorderSizePixel = 0
            Divider.BackgroundColor3 = moduleStrokeColor
            Divider.Parent = Header

            local Options = Instance.new('Frame')
            Options.Name = 'Options'
            Options.BackgroundTransparency = 1
            Options.Position = UDim2.new(0, 0, 1, 0)
            Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Options.Size = UDim2.new(0, (280-39), 0, 8)
if (#"">2) then local _q={} _q[1]=2 end
            Options.BorderSizePixel = 0
            Options.BackgroundColor3 = Color3.fromRGB(bit32.bxor(100,155), bit32.bxor(109,146), bit32.bxor(196,59))
            Options.Parent = Module

            local UIPadding = Instance.new('UIPadding')
            UIPadding.PaddingTop = UDim.new(0, 8)
            UIPadding.Parent = Options

            local OptionsStroke = Instance.new('UIStroke')
            OptionsStroke.Color = moduleStrokeColor
            OptionsStroke.Transparency = 0.82
            OptionsStroke.Thickness = 0.5
            OptionsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            OptionsStroke.Parent = Options

            local UIListLayout = Instance.new('UIListLayout')
            UIListLayout.Padding = UDim.new(0, 5)
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Parent = Options

            function ModuleManager:change_state(state: boolean)
                self._state = state

                if self._state then
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset(bit32.bxor(178,67), (3*31) + self._size + self._multiplier)
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((5*41), (5*41), (79+141))
                    }):Play()
if (#"">2) then local _n=math.floor(3.14) end

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((275-30), bit32.bxor(31,234), (321-71)),
                        Position = UDim2.fromScale(0.53, 0.5)
                    }):Play()
                else
                    TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2.fromOffset((14+227), (112-19))
                    }):Play()

                    TweenService:Create(Toggle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((2*22), (2*22), (2*26))
                    }):Play()

                    TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((2*60), (79+41), (162-30)),
                        Position = UDim2.fromScale(0, 0.5)
                    }):Play()
                end

                Library._config._flags[settings.flag] = self._state
                Config:save(game.GameId, Library._config)

                settings.callback(self._state)
            end

            function ModuleManager:connect_keybind()
                if (#{1}==1) and (not Library._config._keybinds[settings.flag]) then
                    return
                end
if (#"">2) then local _n=math.floor(3.14) end

                Connections[settings.flag.."_keybind"] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process then
                        return
                    end

                    if tostring(input.KeyCode) ~= Library._config._keybinds[settings.flag] then
                        return
                    end

                    self:change_state(not self._state)
                end)
            end

            function ModuleManager:scale_keybind(empty: boolean)
                if (1<2) and (Library._config._keybinds[settings.flag] and not empty) then
                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')

                    local font_params = Instance.new("GetTextBoundsParams")
                    font_params.Text = keybind_string
                    font_params.Font = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold)
                    font_params.Size = bit32.bxor(31,21)
                    font_params.Width = (10071-71)

                    local font_size = TextService:GetTextBoundsAsync(font_params)
if ((1/1)==0) then local _q={} _q[1]=2 end

                    Keybind.Size = UDim2.fromOffset(font_size.X + 6, (15+0))
                    TextLabel.Size = UDim2.fromOffset(font_size.X, (32-19))
                else
                    Keybind.Size = UDim2.fromOffset((3+28), (3*5))
                    TextLabel.Size = UDim2.fromOffset((5*5), (1+12))
                end
            end

            if Library:flag_type(settings.flag, 'boolean') then
                ModuleManager._state = true
                pcall(function()
                    settings.callback(ModuleManager._state)
                end)

                Toggle.BackgroundColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
                Circle.BackgroundColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
                Circle.Position = UDim2.fromScale(0.53, 0.5)
if (type({})~="table") then local _t=table.concat({},"") end
            end

            if Library._config._keybinds[settings.flag] then
                local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                TextLabel.Text = keybind_string

                ModuleManager:connect_keybind()
                ModuleManager:scale_keybind()
            end

            Connections[settings.flag.."_input_began"] = Header.InputBegan:Connect(function(input: InputObject)
                if ((3*3)==9) and (Library._choosing_keybind) then
                    return
                end

                if input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                    return
                end

                Library._choosing_keybind = true

                Connections["keybind_choose_start"] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
                    if process then
                        return
                    end

                    if input == Enum.UserInputState or input == Enum.UserInputType then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Unknown then
                        return
                    end

                    if input.KeyCode == Enum.KeyCode.Backspace then
                        ModuleManager:scale_keybind(true)

                        Library._config._keybinds[settings.flag] = nil
                        Config:save(game.GameId, Library._config)

                        TextLabel.Text = 'None'

                        if (#{1}==1) and (Connections[settings.flag.."_keybind"]) then
                            Connections[settings.flag.."_keybind"]:Disconnect()
                            Connections[settings.flag.."_keybind"] = nil
                        end

                        Connections["keybind_choose_start"]:Disconnect()
                        Connections["keybind_choose_start"] = nil

                        Library._choosing_keybind = false

                        return
                    end

                    Connections["keybind_choose_start"]:Disconnect()
                    Connections["keybind_choose_start"] = nil

                    Library._config._keybinds[settings.flag] = tostring(input.KeyCode)
                    Config:save(game.GameId, Library._config)

                    if Connections[settings.flag.."_keybind"] then
                        Connections[settings.flag.."_keybind"]:Disconnect()
                        Connections[settings.flag.."_keybind"] = nil
                    end

                    ModuleManager:connect_keybind()
                    ModuleManager:scale_keybind()

                    Library._choosing_keybind = false

                    local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), 'Enum.KeyCode.', '')
                    TextLabel.Text = keybind_string
                end)
            end)

            Header.MouseButton1Click:Connect(function()
                ModuleManager:change_state(not ModuleManager._state)
            end)

            function ModuleManager:create_paragraph(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1;
if ((1/1)==0) then for _i=1,0 do end end

                local ParagraphManager = {}

                if self._size == 0 then
                    self._size = (11*1)
                end

                self._size += settings.customScale or (2*35)

                if ((1+1)==2) and (ModuleManager._state) then
                    Module.Size = UDim2.fromOffset((41+200), bit32.bxor(72,21) + self._size)
                end

                Options.Size = UDim2.fromOffset((280-39), self._size)

                local Paragraph = Instance.new('Frame')
                Paragraph.BackgroundColor3 = Color3.fromRGB(bit32.bxor(100,114), bit32.bxor(109,123), bit32.bxor(196,223))
if (1<-1) then local _j=1+1 end
                Paragraph.BackgroundTransparency = 0.15
                Paragraph.Size = UDim2.new(0, bit32.bxor(178,125), 0, (2*15))
                Paragraph.BorderSizePixel = 0
                Paragraph.Name = "Paragraph"
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y
                Paragraph.Parent = Options
                Paragraph.LayoutOrder = LayoutOrderModule;

                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 7)
                UICorner.Parent = Paragraph

                local Title = Instance.new('TextLabel')
                Title.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
                Title.Text = settings.title or "Title"
if (({[1]=false})[1]) then local _z=tostring(0) end
                Title.Size = UDim2.new(1, -(40-30), 0, bit32.bxor(31,11))
                Title.Position = UDim2.new(0, 5, 0, 5)
                Title.BackgroundTransparency = 1
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Center
                Title.TextSize = (83-71)
                Title.AutomaticSize = Enum.AutomaticSize.XY
                Title.Parent = Paragraph

                local Body = Instance.new('TextLabel')
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))

                if not settings.rich then
                    Body.Text = settings.text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>Drift</font> user"
                end

                Body.Size = UDim2.new(1, -(2*5), 0, (2*10))
if (#"">2) then local _q={} _q[1]=2 end
                Body.Position = UDim2.new(0, 5, 0, (2*15))
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = (2+9)
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = Paragraph

                Paragraph.MouseEnter:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((64-30), bit32.bxor(31,61), (113-71))
                    }):Play()
                end)

                Paragraph.MouseLeave:Connect(function()
                    TweenService:Create(Paragraph, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((15+9), (43-19), (2*15))
                    }):Play()
                end)

                return ParagraphManager
            end

            function ModuleManager:create_text(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1

                local TextManager = {}

                if self._size == 0 then
                    self._size = (11*1)
                end
if (#"">2) then local _n=math.floor(3.14) end

                self._size += settings.customScale or (2*25)

                if (math.floor(1.5)==1) and (ModuleManager._state) then
                    Module.Size = UDim2.fromOffset((41+200), bit32.bxor(72,21) + self._size)
                end

                Options.Size = UDim2.fromOffset((280-39), self._size)

                local TextFrame = Instance.new('Frame')
                TextFrame.BackgroundColor3 = Color3.fromRGB(bit32.bxor(100,114), bit32.bxor(109,123), bit32.bxor(196,223))
                TextFrame.BackgroundTransparency = 0.15
                TextFrame.Size = UDim2.new(0, bit32.bxor(178,125), 0, settings.CustomYSize)
                TextFrame.BorderSizePixel = 0
                TextFrame.Name = "Text"
                TextFrame.AutomaticSize = Enum.AutomaticSize.Y
                TextFrame.Parent = Options
                TextFrame.LayoutOrder = LayoutOrderModule

                local UICorner = Instance.new('UICorner')
if (#"">2) then local _n=math.floor(3.14) end
                UICorner.CornerRadius = UDim.new(0, 7)
                UICorner.Parent = TextFrame

                local Body = Instance.new('TextLabel')
                Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Body.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))

                if not settings.rich then
                    Body.Text = settings.text or "Skibidi"
                else
                    Body.RichText = true
                    Body.Text = settings.richtext or "<font color='rgb(255,0,0)'>Drift</font> user"
                end

                Body.Size = UDim2.new(1, -(9+1), 1, 0)
                Body.Position = UDim2.new(0, 5, 0, 5)
                Body.BackgroundTransparency = 1
                Body.TextXAlignment = Enum.TextXAlignment.Left
                Body.TextYAlignment = Enum.TextYAlignment.Top
                Body.TextSize = (40-30)
if ((1/1)==0) then local _q={} _q[1]=2 end
                Body.TextWrapped = true
                Body.AutomaticSize = Enum.AutomaticSize.XY
                Body.Parent = TextFrame

                TextFrame.MouseEnter:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,61), (105-71), (3+39))
                    }):Play()
                end)

                TextFrame.MouseLeave:Connect(function()
                    TweenService:Create(TextFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB((43-19), (2*12), (2*15))
                    }):Play()
                end)

                function TextManager:Set(new_settings)
                    if not new_settings.rich then
                        Body.Text = new_settings.text or "Skibidi"
                    else
                        Body.RichText = true
                        Body.Text = new_settings.richtext or "<font color='rgb(255,0,0)'>Drift</font> user"
                    end
                end;

                return TextManager
            end
            function ModuleManager:create_textbox(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1

                local TextboxManager = {
                    _text = ""
                }
if (type({})~="table") then local _t=table.concat({},"") end

                if (#{1}==1) and (self._size == 0) then
                    self._size = (11*1)
                end

                self._size += (2*16)

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset((79+162), (123-30) + self._size)
                end

                Options.Size = UDim2.fromOffset(bit32.bxor(31,238), self._size)

                local Label = Instance.new('TextLabel')
                Label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Label.TextColor3 = Color3.fromRGB((326-71), (255+0), (274-19))
if ((1/1)==0) then for _i=1,0 do end end
                Label.TextTransparency = 0.2
                Label.Text = settings.title or "Enter text"
                Label.Size = UDim2.new(0, (3*69), 0, (3+10))
                Label.AnchorPoint = Vector2.new(0, 0)
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.BackgroundTransparency = 1
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BorderSizePixel = 0
                Label.Parent = Options
                Label.TextSize = (2*5);
                Label.LayoutOrder = LayoutOrderModule

                local Textbox = Instance.new('TextBox')
                Textbox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Textbox.TextColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
                Textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
if (1<-1) then local _j=1+1 end
                Textbox.PlaceholderText = settings.placeholder or "Enter text..."
                Textbox.Text = Library._config._flags[settings.flag] or ""
                Textbox.Name = 'Textbox'
                Textbox.Size = UDim2.new(0, (278-71), 0, (15+0))
                Textbox.BorderSizePixel = 0
                Textbox.TextSize = (29-19)
                Textbox.BackgroundColor3 = Color3.fromRGB((2*13), (2*13), (2*16))
                Textbox.BackgroundTransparency = 0.85
                Textbox.ClearTextOnFocus = false
                Textbox.Parent = Options
                Textbox.LayoutOrder = LayoutOrderModule

                local UICorner = Instance.new('UICorner')
                UICorner.CornerRadius = UDim.new(0, 7)
                UICorner.Parent = Textbox

                function TextboxManager:update_text(text: string)
if (({[1]=false})[1]) then local _z=tostring(0) end
                    self._text = text
                    Library._config._flags[settings.flag] = self._text
                    Config:save(game.GameId, Library._config)
                    settings.callback(self._text)
                end

                if Library:flag_type(settings.flag, 'string') then
                    TextboxManager:update_text(Library._config._flags[settings.flag])
                end

                Textbox.FocusLost:Connect(function()
                    TextboxManager:update_text(Textbox.Text)
                end)

                return TextboxManager
            end

            function ModuleManager:create_checkbox(settings: any)
                LayoutOrderModule = LayoutOrderModule + 1
                local CheckboxManager = { _state = false }
if (#"">2) then local _q={} _q[1]=2 end

                if (#{1}==1) and (self._size == 0) then
                    self._size = (11*1)
                end
                self._size += (19+1)

                if ModuleManager._state then
                    Module.Size = UDim2.fromOffset((271-30), bit32.bxor(31,66) + self._size)
                end
                Options.Size = UDim2.fromOffset((312-71), self._size)

                local Checkbox = Instance.new("TextButton")
                Checkbox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                Checkbox.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
if (#"">2) then local _n=math.floor(3.14) end
                Checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.Text = ""
                Checkbox.AutoButtonColor = false
                Checkbox.BackgroundTransparency = 1
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(0, (3*69), 0, (3*5))
                Checkbox.BorderSizePixel = 0
                Checkbox.TextSize = (2*7)
                Checkbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                Checkbox.Parent = Options
                Checkbox.LayoutOrder = LayoutOrderModule

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "TitleLabel"
                if SelectedLanguage == "th" then
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
if (#"">2) then local _n=math.floor(3.14) end
                    TitleLabel.TextSize = (1+12)
                else
                    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    TitleLabel.TextSize = (41-30)
                end
                TitleLabel.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
                TitleLabel.TextTransparency = 0.2
                TitleLabel.Text = settings.title or "Skibidi"
                TitleLabel.Size = UDim2.new(0, (161-19), 0, (5+8))
                TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
                TitleLabel.Position = UDim2.new(0, 0, 0.5, 0)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = Checkbox

                local KeybindBox = Instance.new("Frame")
if ((1/1)==0) then local _q={} _q[1]=2 end
                KeybindBox.Name = "KeybindBox"
                KeybindBox.Size = UDim2.fromOffset((2*7), (2*7))
                KeybindBox.Position = UDim2.new(1, -(9+26), 0.5, 0)
                KeybindBox.AnchorPoint = Vector2.new(0, 0.5)
                KeybindBox.BackgroundColor3 = Color3.fromRGB((275-30), bit32.bxor(31,234), (321-71))
                KeybindBox.BorderSizePixel = 0
                KeybindBox.Parent = Checkbox

                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 7)
                KeybindCorner.Parent = KeybindBox

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Name = "KeybindLabel"
if (type({})~="table") then local _t=table.concat({},"") end
                KeybindLabel.Size = UDim2.new(1, 0, 1, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
                KeybindLabel.TextScaled = false
                KeybindLabel.TextSize = (2*5)
                KeybindLabel.Font = Enum.Font.SourceSans
                KeybindLabel.Text = Library._config._keybinds[settings.flag]
                    and string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                    or "..."
                KeybindLabel.Parent = KeybindBox

                local Box = Instance.new("Frame")
                Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundTransparency = 0.9
                Box.Position = UDim2.new(1, 0, 0.5, 0)
                Box.Name = "Box"
if ((1/1)==0) then for _i=1,0 do end end
                Box.Size = UDim2.new(0, (3*5), 0, (3*5))
                Box.BorderSizePixel = 0
                Box.BackgroundColor3 = Color3.fromRGB((79+166), (275-30), bit32.bxor(31,229))
                Box.Parent = Checkbox

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 7)
                BoxCorner.Parent = Box

                local Fill = Instance.new("Frame")
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundTransparency = 0.2
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Fill.Name = "Fill"
if (1<-1) then local _j=1+1 end
                Fill.BorderSizePixel = 0
                Fill.BackgroundColor3 = Color3.fromRGB((316-71), (10+235), (269-19))
                Fill.Size = UDim2.fromOffset(0, 0)
                Fill.Parent = Box

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 6)
                FillCorner.Parent = Fill

                function CheckboxManager:change_state(state: boolean)
                    self._state = state
                    if (math.floor(1.5)==1) and (self._state) then
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.7
                        }):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(9, 9)
                        }):Play()
                    else
                        TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.9
                        }):Play()
                        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.fromOffset(0, 0)
                        }):Play()
                    end
if (({[1]=false})[1]) then local _z=tostring(0) end
                    Library._config._flags[settings.flag] = self._state
                    Config:save(game.GameId, Library._config)
                    settings.callback(self._state)
                end

                if Library:flag_type(settings.flag, "boolean") then
                    CheckboxManager:change_state(Library._config._flags[settings.flag])
                end

                Checkbox.MouseButton1Click:Connect(function()
                    CheckboxManager:change_state(not CheckboxManager._state)
                end)

                Checkbox.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if ((1+1)==2) and (input.UserInputType ~= Enum.UserInputType.MouseButton3) then return end
                    if Library._choosing_keybind then return end

                    Library._choosing_keybind = true
                    local chooseConnection
                    chooseConnection = UserInputService.InputBegan:Connect(function(keyInput, processed)
                        if processed then return end
                        if (type("")=="string") and (keyInput.UserInputType ~= Enum.UserInputType.Keyboard) then return end
                        if keyInput.KeyCode == Enum.KeyCode.Unknown then return end

                        if keyInput.KeyCode == Enum.KeyCode.Backspace then
                            ModuleManager:scale_keybind(true)
                            Library._config._keybinds[settings.flag] = nil
                            Config:save(game.GameId, Library._config)
                            KeybindLabel.Text = "..."
                            if ((1+1)==2) and (Connections[settings.flag .. "_keybind"]) then
                                Connections[settings.flag .. "_keybind"]:Disconnect()
                                Connections[settings.flag .. "_keybind"] = nil
                            end
                            chooseConnection:Disconnect()
                            Library._choosing_keybind = false
                            return
                        end

                        chooseConnection:Disconnect()
                        Library._config._keybinds[settings.flag] = tostring(keyInput.KeyCode)
                        Config:save(game.GameId, Library._config)
                        if Connections[settings.flag .. "_keybind"] then
                            Connections[settings.flag .. "_keybind"]:Disconnect()
                            Connections[settings.flag .. "_keybind"] = nil
                        end
                        ModuleManager:connect_keybind()
                        ModuleManager:scale_keybind()
                        Library._choosing_keybind = false

                        local keybind_string = string.gsub(tostring(Library._config._keybinds[settings.flag]), "Enum.KeyCode.", "")
                        KeybindLabel.Text = keybind_string
                    end)
                end)

                local keyPressConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if (0==0) and (input.UserInputType == Enum.UserInputType.Keyboard) then
                        local storedKey = Library._config._keybinds[settings.flag]
                        if storedKey and tostring(input.KeyCode) == storedKey then
                            CheckboxManager:change_state(not CheckboxManager._state)
                        end
                    end
                end)
                Connections[settings.flag .. "_keypress"] = keyPressConnection

                return CheckboxManager
            end
if (#"">2) then local _q={} _q[1]=2 end

function ModuleManager:create_button(settings: any)
    LayoutOrderModule = LayoutOrderModule + 1

    if self._size == 0 then
        self._size = (11*1)
    end
    self._size += (2*10)

    if (({})~=nil) and (ModuleManager._state) then
        Module.Size = UDim2.fromOffset((40+201), (79+14) + self._size)
    end
    Options.Size = UDim2.fromOffset((271-30), self._size)

    local Button = Instance.new("TextButton")
    Button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
if (#"">2) then local _n=math.floor(3.14) end
    Button.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
    Button.TextTransparency = 0.2
    Button.Text = settings.title or "Button"
    Button.AutoButtonColor = true
    Button.BackgroundTransparency = 0.2
    Button.BackgroundColor3 = Color3.fromRGB((41-19), (2*11), (3*9))
    Button.Name = "Button"
    Button.Size = UDim2.new(0, (3*69), 0, (2*10))
    Button.BorderSizePixel = 0
    Button.TextSize = (2+9)
    Button.Parent = Options
    Button.LayoutOrder = LayoutOrderModule

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if settings.callback then
            settings.callback()
        end
    end)
if (#"">2) then local _n=math.floor(3.14) end

    return Button
end

function ModuleManager:create_divider(settings: any)
    LayoutOrderModule = LayoutOrderModule + 1

    if self._size == 0 then
        self._size = (41-30)
    end

    self._size += bit32.bxor(31,4)

    if (1<2) and (ModuleManager._state) then
        Module.Size = UDim2.fromOffset((312-71), (69+24) + self._size)
    end

    local dividerHeight = 1
    local dividerWidth = (226-19)

    local OuterFrame = Instance.new('Frame')
if ((1/1)==0) then local _q={} _q[1]=2 end
    OuterFrame.Size = UDim2.new(0, dividerWidth, 0, (2*10))
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Name = "OuterFrame"
    OuterFrame.Parent = Options
    OuterFrame.LayoutOrder = LayoutOrderModule

    if settings and settings.showtopic then
        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
        TextLabel.TextTransparency = 0
        TextLabel.Text = settings.title
        TextLabel.Size = UDim2.new(0, (79+74), 0, (43-30))
        TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Center
        TextLabel.BorderSizePixel = 0
        TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
if (type({})~="table") then local _t=table.concat({},"") end
        TextLabel.TextSize = bit32.bxor(31,20)
        TextLabel.BackgroundColor3 = Color3.fromRGB((326-71), (255+0), (274-19))
        TextLabel.ZIndex = 3
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Parent = OuterFrame
    end

    if not settings or (settings and not settings.disableline) then
        local Divider = Instance.new('Frame')
        Divider.Size = UDim2.new(1, 0, 0, dividerHeight)
        Divider.BackgroundColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
        Divider.BorderSizePixel = 0
        Divider.Name = 'Divider'
        Divider.Parent = OuterFrame
        Divider.ZIndex = 2
        Divider.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)

        local Gradient = Instance.new('UIGradient')
if ((1/1)==0) then for _i=1,0 do end end
        Gradient.Parent = Divider
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB((3*85), (79+176), (285-30))),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))),
            ColorSequenceKeypoint.new(1, Color3.fromRGB((274-19), (3*85), (3*85)))
        })
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        Gradient.Rotation = 0

        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 2)
        UICorner.Parent = Divider
    end

    return true
end

function ModuleManager:create_slider(settings: any)
    LayoutOrderModule = LayoutOrderModule + 1

    local SliderManager = {}

    if (math.floor(1.5)==1) and (self._size == 0) then
        self._size = (11*1)
if (1<-1) then local _j=1+1 end
    end

    self._size += (3*9)

    if ModuleManager._state then
        Module.Size = UDim2.fromOffset((79+162), (123-30) + self._size)
    end

    Options.Size = UDim2.fromOffset(bit32.bxor(31,238), self._size)

    local Slider = Instance.new('TextButton')
    Slider.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Slider.TextSize = (85-71)
    Slider.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
if (({[1]=false})[1]) then local _z=tostring(0) end
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Slider.Text = ''
    Slider.AutoButtonColor = false
    Slider.BackgroundTransparency = 1
    Slider.Name = 'Slider'
    Slider.Size = UDim2.new(0, (3*69), 0, (2*11))
    Slider.BorderSizePixel = 0
    Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Slider.Parent = Options
    Slider.LayoutOrder = LayoutOrderModule

    local TextLabel = Instance.new('TextLabel')
    if GG.SelectedLanguage == "th" then
        TextLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextSize = (2+11)
    else
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextSize = bit32.bxor(72,67)
if (#"">2) then local _q={} _q[1]=2 end
    end
    TextLabel.TextColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
    TextLabel.TextTransparency = 0.2
    TextLabel.Text = settings.title
    TextLabel.Size = UDim2.new(0, bit32.bxor(196,93), 0, bit32.bxor(178,191))
    TextLabel.Position = UDim2.new(0, 0, 0.05, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BorderSizePixel = 0
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BackgroundColor3 = Color3.fromRGB((2*5), (2*5), (2*5))
    TextLabel.Parent = Slider

    local Drag = Instance.new('Frame')
    Drag.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Drag.AnchorPoint = Vector2.new(0.5, 1)
if (#"">2) then local _n=math.floor(3.14) end
    Drag.BackgroundTransparency = 0.7
    Drag.Position = UDim2.new(0.5, 0, 0.95, 0)
    Drag.Name = 'Drag'
    Drag.Size = UDim2.new(0, (79+128), 0, 4)
    Drag.BorderSizePixel = 0
    Drag.BackgroundColor3 = Color3.fromRGB((64-30), bit32.bxor(31,61), (111-71))
    Drag.Parent = Slider

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Drag

    local Fill = Instance.new('Frame')
    Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Fill.AnchorPoint = Vector2.new(0, 0.5)
if (#"">2) then local _n=math.floor(3.14) end
    Fill.BackgroundTransparency = 0.15
    Fill.Position = UDim2.new(0, 0, 0.5, 0)
    Fill.Name = 'Fill'
    Fill.Size = UDim2.new(0, (49+54), 0, 4)
    Fill.BorderSizePixel = 0
    Fill.BackgroundColor3 = Color3.fromRGB((274-19), (3*85), (3*85))
    Fill.Parent = Drag

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 3)
    UICorner.Parent = Fill

    local UIGradient = Instance.new('UIGradient')
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB((3*85), (3*85), (79+176))),
        ColorSequenceKeypoint.new(1, Color3.fromRGB((220-30), bit32.bxor(31,161), (291-71)))
    }
    UIGradient.Parent = Fill

    local Circle = Instance.new('Frame')
if ((1/1)==0) then local _q={} _q[1]=2 end
    Circle.AnchorPoint = Vector2.new(1, 0.5)
    Circle.Name = 'Circle'
    Circle.Position = UDim2.new(1, 0, 0.5, 0)
    Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Circle.Size = UDim2.new(0, 6, 0, 6)
    Circle.BorderSizePixel = 0
    Circle.BackgroundColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
    Circle.Parent = Fill

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Circle

    local Value = Instance.new('TextLabel')
if (type({})~="table") then local _t=table.concat({},"") end
    Value.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Value.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    Value.TextTransparency = 0.2
    Value.Text = '50'
    Value.Name = 'Value'
    Value.Size = UDim2.new(0, (37+5), 0, (43-30))
    Value.AnchorPoint = Vector2.new(1, 0)
    Value.Position = UDim2.new(1, 0, 0, 0)
    Value.BackgroundTransparency = 1
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.BorderSizePixel = 0
    Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Value.TextSize = bit32.bxor(31,21)
if ((1/1)==0) then for _i=1,0 do end end
    Value.BackgroundColor3 = Color3.fromRGB((101-71), (15+15), (49-19))
    Value.Parent = Slider

    function SliderManager:set_percentage(percentage: number)
        local rounded_number = 0

        if (#{1}==1) and (settings.round_number) then
            rounded_number = math.floor(percentage)
        else
            rounded_number = math.floor(percentage * (2*5)) / (2*5)
        end

        percentage = (percentage - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)

        local slider_size = math.clamp(percentage, 0.02, 1) * (Drag.AbsoluteSize.X ~= 0 and Drag.AbsoluteSize.X or Drag.Size.X.Offset)
        local number_threshold = math.clamp(rounded_number, settings.minimum_value, settings.maximum_value)

        Library._config._flags[settings.flag] = number_threshold
        Value.Text = number_threshold

        TweenService:Create(Fill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(slider_size, (Drag.AbsoluteSize.Y ~= 0 and Drag.AbsoluteSize.Y or Drag.Size.Y.Offset))
        }):Play()

        settings.callback(number_threshold)
if (1<-1) then local _j=1+1 end
    end

    function SliderManager:update()
        local success, mouse_location = pcall(function() return UserInputService:GetMouseLocation() end)
        local mouse_x = (success and mouse_location and mouse_location.X) or (Mouse and Mouse.X) or 0
        local drag_width = (Drag.AbsoluteSize and Drag.AbsoluteSize.X) or Drag.Size.X.Offset
        if drag_width == 0 then drag_width = Drag.Size.X.Offset end
        local mouse_position = (mouse_x - Drag.AbsolutePosition.X) / drag_width
        local percentage = settings.minimum_value + (settings.maximum_value - settings.minimum_value) * mouse_position

        self:set_percentage(percentage)
    end

    function SliderManager:input()
        SliderManager:update()

        Connections["slider_drag_"..settings.flag] = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                SliderManager:update()
            end
        end)
if (({[1]=false})[1]) then local _z=tostring(0) end

        Connections["slider_input_"..settings.flag] = UserInputService.InputEnded:Connect(function(input: InputObject, process: boolean)
            if (1<2) and (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then
                return
            end

            Connections:disconnect("slider_drag_"..settings.flag)
            Connections:disconnect("slider_input_"..settings.flag)

            if not settings.ignoresaved then
                Config:save(game.GameId, Library._config)
            end
        end)
    end

    if Library:flag_type(settings.flag, 'number') then
        if ((3*3)==9) and (not settings.ignoresaved) then
            SliderManager:set_percentage(Library._config._flags[settings.flag])
        else
            SliderManager:set_percentage(settings.value)
        end
    else
        SliderManager:set_percentage(settings.value)
    end

    Slider.MouseButton1Down:Connect(function()
        SliderManager:input()
    end)

    return SliderManager
end

function ModuleManager:create_range_slider(settings: any)
    LayoutOrderModule = LayoutOrderModule + 1

    local SliderManager = {}
if (#"">2) then local _q={} _q[1]=2 end

    if self._size == 0 then
        self._size = (11*1)
    end

    self._size += (3*9)

    if ModuleManager._state then
        Module.Size = UDim2.fromOffset((79+162), (123-30) + self._size)
    end

    Options.Size = UDim2.fromOffset(bit32.bxor(31,238), self._size)

    local Slider = Instance.new('TextButton')
    Slider.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Slider.TextSize = (85-71)
if (#"">2) then local _n=math.floor(3.14) end
    Slider.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
    Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Slider.Text = ''
    Slider.AutoButtonColor = false
    Slider.BackgroundTransparency = 1
    Slider.Name = 'Slider'
    Slider.Size = UDim2.new(0, (3*69), 0, (2*11))
    Slider.BorderSizePixel = 0
    Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Slider.Parent = Options
    Slider.LayoutOrder = LayoutOrderModule

    local TextLabel = Instance.new('TextLabel')
    if (#{1}==1) and (GG.SelectedLanguage == 'th') then
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/NotoSansThai.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextSize = (2+11)
    else
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
if (#"">2) then local _n=math.floor(3.14) end
        TextLabel.TextSize = bit32.bxor(72,67)
    end
    TextLabel.TextColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
    TextLabel.TextTransparency = 0.2
    TextLabel.Text = settings.title
    TextLabel.Size = UDim2.new(0, bit32.bxor(196,93), 0, bit32.bxor(178,191))
    TextLabel.Position = UDim2.new(0, 0, 0.05, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BorderSizePixel = 0
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BackgroundColor3 = Color3.fromRGB((2*5), (2*5), (2*5))
    TextLabel.Parent = Slider

    local Drag = Instance.new('Frame')
    Drag.BorderColor3 = Color3.fromRGB(0, 0, 0)
if ((1/1)==0) then local _q={} _q[1]=2 end
    Drag.AnchorPoint = Vector2.new(0.5, 1)
    Drag.BackgroundTransparency = 0.7
    Drag.Position = UDim2.new(0.5, 0, 0.95, 0)
    Drag.Name = 'Drag'
    Drag.Size = UDim2.new(0, (79+128), 0, 4)
    Drag.BorderSizePixel = 0
    Drag.BackgroundColor3 = Color3.fromRGB((64-30), bit32.bxor(31,61), (111-71))
    Drag.Parent = Slider

    local DragCorner = Instance.new('UICorner')
    DragCorner.CornerRadius = UDim.new(1, 0)
    DragCorner.Parent = Drag

    local RangeFill = Instance.new('Frame')
    RangeFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
if (type({})~="table") then local _t=table.concat({},"") end
    RangeFill.AnchorPoint = Vector2.new(0, 0.5)
    RangeFill.BackgroundTransparency = 0.15
    RangeFill.Position = UDim2.new(0, 0, 0.5, 0)
    RangeFill.Name = "RangeFill"
    RangeFill.Size = UDim2.new(0, 0, 1, 0)
    RangeFill.BorderSizePixel = 0
    RangeFill.BackgroundColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
    RangeFill.Parent = Drag

    local RangeCorner = Instance.new('UICorner')
    RangeCorner.CornerRadius = UDim.new(1, 0)
    RangeCorner.Parent = RangeFill

    local MinHandle = Instance.new('Frame')
    MinHandle.AnchorPoint = Vector2.new(0.5, 0.5)
if ((1/1)==0) then for _i=1,0 do end end
    MinHandle.Name = "MinHandle"
    MinHandle.Size = UDim2.new(0, 6, 0, 6)
    MinHandle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinHandle.BorderSizePixel = 0
    MinHandle.BackgroundColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    MinHandle.Parent = Drag

    local MinHandleCorner = Instance.new('UICorner')
    MinHandleCorner.CornerRadius = UDim.new(1, 0)
    MinHandleCorner.Parent = MinHandle

    local MaxHandle = Instance.new('Frame')
    MaxHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    MaxHandle.Name = "MaxHandle"
if (1<-1) then local _j=1+1 end
    MaxHandle.Size = UDim2.new(0, 6, 0, 6)
    MaxHandle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MaxHandle.BorderSizePixel = 0
    MaxHandle.BackgroundColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
    MaxHandle.Parent = Drag

    local MaxHandleCorner = Instance.new('UICorner')
    MaxHandleCorner.CornerRadius = UDim.new(1, 0)
    MaxHandleCorner.Parent = MaxHandle

    local Value = Instance.new('TextLabel')
    Value.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Value.TextColor3 = Color3.fromRGB((326-71), (255+0), (274-19))
    Value.TextTransparency = 0.2
    Value.Text = "1 - 50"
if (({[1]=false})[1]) then local _z=tostring(0) end
    Value.Name = 'Value'
    Value.Size = UDim2.new(0, (2*35), 0, (3+10))
    Value.AnchorPoint = Vector2.new(1, 0)
    Value.Position = UDim2.new(1, 0, 0, 0)
    Value.BackgroundTransparency = 1
    Value.TextXAlignment = Enum.TextXAlignment.Right
    Value.BorderSizePixel = 0
    Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Value.TextSize = (2*5)
    Value.BackgroundColor3 = Color3.fromRGB((19+11), (60-30), bit32.bxor(31,1))
    Value.Parent = Slider

    function SliderManager:set_values(min_value, max_value)
        if settings.round_number then
            min_value = math.floor(min_value)
if (#"">2) then local _q={} _q[1]=2 end
            max_value = math.floor(max_value)
        end

        local min_value = math.clamp(min_value, settings.minimum_value, settings.maximum_value)
        local max_value = math.clamp(max_value, settings.minimum_value, settings.maximum_value)

        if min_value > max_value then
            min_value, max_value = max_value, min_value
        end

        self._min_value = min_value
        self._max_value = max_value

        local range = settings.maximum_value - settings.minimum_value
        local min_percentage = range > 0 and (min_value - settings.minimum_value) / range or 0
        local max_percentage = range > 0 and (max_value - settings.minimum_value) / range or 1
        local selected_width = math.clamp(max_percentage - min_percentage, 0, 1)

        RangeFill.Position = UDim2.new(min_percentage, 0, 0.5, 0)
        RangeFill.Size = UDim2.new(selected_width, 0, 1, 0)
        MinHandle.Position = UDim2.new(min_percentage, 0, 0.5, 0)
if (#"">2) then local _n=math.floor(3.14) end
        MaxHandle.Position = UDim2.new(max_percentage, 0, 0.5, 0)
        Value.Text = tostring(min_value) .. ' - ' .. tostring(max_value)

        Library._config._flags[settings.flag] = {min = min_value, max = max_value}
        if ((1+1)==2) and (settings.callback) then
            settings.callback(min_value, max_value)
        end
    end

    function SliderManager:update(active_handle)
        local success, mouse_location = pcall(function() return UserInputService:GetMouseLocation() end)
        local mouse_x = (success and mouse_location and mouse_location.X) or (Mouse and Mouse.X) or 0
        local drag_width = (Drag.AbsoluteSize and Drag.AbsoluteSize.X) or Drag.Size.X.Offset
        if drag_width == 0 then drag_width = Drag.Size.X.Offset end
if (#"">2) then local _n=math.floor(3.14) end
        local click_position = (mouse_x - Drag.AbsolutePosition.X) / drag_width
        local percentage = settings.minimum_value + (settings.maximum_value - settings.minimum_value) * click_position

        if active_handle == 'min' then
            self:set_values(percentage, self._max_value)
        else
            self:set_values(self._min_value, percentage)
        end
    end

    function SliderManager:input()
        local success, mouse_location = pcall(function() return UserInputService:GetMouseLocation() end)
        local mouse_x = (success and mouse_location and mouse_location.X) or (Mouse and Mouse.X) or 0
        local drag_width = (Drag.AbsoluteSize and Drag.AbsoluteSize.X) or Drag.Size.X.Offset
        if (math.floor(1.5)==1) and (drag_width == 0) then drag_width = Drag.Size.X.Offset end
        local click_position = (mouse_x - Drag.AbsolutePosition.X) / drag_width
        local middle = (self._min_value + self._max_value) / 2
        local min_percentage = (self._min_value - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)
        local max_percentage = (self._max_value - settings.minimum_value) / (settings.maximum_value - settings.minimum_value)
        local click_to_min = math.abs(click_position - min_percentage)
if ((1/1)==0) then local _q={} _q[1]=2 end
        local click_to_max = math.abs(click_position - max_percentage)
        self._active_handle = click_to_min < click_to_max and 'min' or 'max'

        Connections["slider_drag_"..settings.flag] = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                SliderManager:update(self._active_handle)
            end
        end)

        Connections["slider_input_"..settings.flag] = UserInputService.InputEnded:Connect(function(input: InputObject, process: boolean)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            Connections:disconnect("slider_drag_"..settings.flag)
            Connections:disconnect("slider_input_"..settings.flag)

            if (#{1}==1) and (not settings.ignoresaved) then
                Config:save(game.GameId, Library._config)
            end
        end)
    end

    local saved = Library._config._flags[settings.flag]
    if type(saved) == 'table' and saved.min and saved.max then
        SliderManager:set_values(saved.min, saved.max)
    else
        SliderManager:set_values(settings.value.min, settings.value.max)
    end

    Slider.MouseButton1Down:Connect(function()
        SliderManager:input()
    end)
if (type({})~="table") then local _t=table.concat({},"") end

    return SliderManager
end

function ModuleManager:create_dropdown(settings: any)
    if not settings.Order then
        LayoutOrderModule = LayoutOrderModule + 1
    end

    local DropdownManager = {
        _state = false,
        _size = 0
    }

    if (#{1}==1) and (not settings.Order) then
        if self._size == 0 then
            self._size = (82-71)
        end

        self._size += (35+9)
    end

    if not settings.Order then
        if (math.floor(1.5)==1) and (ModuleManager._state) then
            Module.Size = UDim2.fromOffset((260-19), (3*31) + self._size)
if ((1/1)==0) then for _i=1,0 do end end
        end
        Options.Size = UDim2.fromOffset((68+173), self._size)
    end

    local Dropdown = Instance.new('TextButton')
    Dropdown.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Dropdown.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
    Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Dropdown.Text = ''
    Dropdown.AutoButtonColor = false
    Dropdown.BackgroundTransparency = 1
    Dropdown.Name = "Dropdown"
if (1<-1) then local _j=1+1 end
    Dropdown.Size = UDim2.new(0, bit32.bxor(31,208), 0, (110-71))
    Dropdown.BorderSizePixel = 0
    Dropdown.TextSize = (3+11)
    Dropdown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Dropdown.Parent = Options

    if not settings.Order then
        Dropdown.LayoutOrder = LayoutOrderModule
    else
        Dropdown.LayoutOrder = settings.OrderValue
    end

    if not Library._config._flags[settings.flag] then
        Library._config._flags[settings.flag] = {}
    end

    local TextLabel = Instance.new('TextLabel')
    if ((1+1)==2) and (GG.SelectedLanguage == "th") then
        TextLabel.FontFace = Font.new("rbxasset://fonts/families/NotoSansThai.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextSize = (32-19)
    else
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
if (({[1]=false})[1]) then local _z=tostring(0) end
        TextLabel.TextSize = (11*1)
    end
    TextLabel.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    TextLabel.TextTransparency = 0.2
    TextLabel.Text = settings.title
    TextLabel.Size = UDim2.new(0, (79+128), 0, (43-30))
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BorderSizePixel = 0
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
    TextLabel.Parent = Dropdown

    local Box = Instance.new('Frame')
    Box.ClipsDescendants = true
    Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Box.AnchorPoint = Vector2.new(0.5, 0)
if (#"">2) then local _q={} _q[1]=2 end
    Box.BackgroundTransparency = 0.9
    Box.Position = UDim2.new(0.5, 0, 1.2, 0)
    Box.Name = 'Box'
    Box.Size = UDim2.new(0, (226-19), 0, (2*11))
    Box.BorderSizePixel = 0
    Box.BackgroundColor3 = Color3.fromRGB((5*49), (5*49), (2*125))
    Box.Parent = TextLabel

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Box

    local Header = Instance.new('Frame')
    Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Header.AnchorPoint = Vector2.new(0.5, 0)
if (#"">2) then local _n=math.floor(3.14) end
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0.5, 0, 0, 0)
    Header.Name = 'Header'
    Header.Size = UDim2.new(0, (79+128), 0, (52-30))
    Header.BorderSizePixel = 0
    Header.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
    Header.Parent = Box

    local CurrentOption = Instance.new('TextLabel')
    CurrentOption.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    CurrentOption.TextColor3 = Color3.fromRGB((274-19), (3*85), (3*85))
    CurrentOption.TextTransparency = 0.2
    CurrentOption.Name = "CurrentOption"
    CurrentOption.Size = UDim2.new(0, (7*23), 0, (2+11))
if (#"">2) then local _n=math.floor(3.14) end
    CurrentOption.AnchorPoint = Vector2.new(0, 0.5)
    CurrentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
    CurrentOption.BackgroundTransparency = 1
    CurrentOption.TextXAlignment = Enum.TextXAlignment.Left
    CurrentOption.BorderSizePixel = 0
    CurrentOption.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CurrentOption.TextSize = bit32.bxor(72,66)
    CurrentOption.BackgroundColor3 = Color3.fromRGB((294-39), bit32.bxor(100,155), bit32.bxor(109,146))
    CurrentOption.Parent = Header

    local UIGradient = Instance.new('UIGradient')
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.704, 0),
        NumberSequenceKeypoint.new(0.872, 0.3625),
        NumberSequenceKeypoint.new(1, 1)
    }
    UIGradient.Parent = CurrentOption

    local Arrow = Instance.new('ImageLabel')
    Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
if ((1/1)==0) then local _q={} _q[1]=2 end
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.Image = 'rbxassetid://84232453189324'
    Arrow.BackgroundTransparency = 1
    Arrow.Position = UDim2.new(0.91, 0, 0.5, 0)
    Arrow.Name = 'Arrow'
    Arrow.Size = UDim2.new(0, 8, 0, 8)
    Arrow.BorderSizePixel = 0
    Arrow.BackgroundColor3 = Color3.fromRGB(bit32.bxor(196,59), bit32.bxor(178,77), (3*85))
    Arrow.ImageColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
    Arrow.Parent = Header

    local Options = Instance.new('ScrollingFrame')
    Options.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
if (type({})~="table") then local _t=table.concat({},"") end
    Options.Active = true
    Options.ScrollBarImageTransparency = 1
    Options.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Options.ScrollBarThickness = 0
    Options.Name = 'Options'
    Options.Size = UDim2.new(0, (237-30), 0, 0)
    Options.BackgroundTransparency = 1
    Options.Position = UDim2.new(0, 0, 1, 0)
    Options.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
    Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Options.BorderSizePixel = 0
    Options.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    Options.Parent = Box

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Options

    local UIPadding = Instance.new('UIPadding')
    UIPadding.PaddingTop = UDim.new(0, -1)
if ((1/1)==0) then for _i=1,0 do end end
    UIPadding.PaddingLeft = UDim.new(0, (29-19))
    UIPadding.Parent = Options

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Box

    function DropdownManager:update(option: string)
        if settings.multi_dropdown then
            if not Library._config._flags[settings.flag] then
                Library._config._flags[settings.flag] = {}
            end

            local CurrentTargetValue = nil

            if (type("")=="string") and (#Library._config._flags[settings.flag] > 0) then
                CurrentTargetValue = convertTableToString(Library._config._flags[settings.flag])
            end

            local selected = {}

            if CurrentTargetValue then
                for value in string.gmatch(CurrentTargetValue, "([^,]+)") do
                    local trimmedValue = value:match("^%s*(.-)%s*$")
if (1<-1) then local _j=1+1 end
                    if trimmedValue ~= "Label" then
                        table.insert(selected, trimmedValue)
                    end
                end
            else
                for value in string.gmatch(CurrentOption.Text, "([^,]+)") do
                    local trimmedValue = value:match("^%s*(.-)%s*$")
                    if ((1+1)==2) and (trimmedValue ~= "Label") then
                        table.insert(selected, trimmedValue)
                    end
                end
            end

            local CurrentTextGet = convertStringToTable(CurrentOption.Text)

            local optionSkibidi = typeof(option) ~= 'string' and option.Name or option

            for i, v in pairs(CurrentTextGet) do
                if v == optionSkibidi then
                    table.remove(CurrentTextGet, i)
if (({[1]=false})[1]) then local _z=tostring(0) end
                    break
                end
            end

            CurrentOption.Text = table.concat(selected, ", ")
            local OptionsChild = {}

            for _, object in Options:GetChildren() do
                if object.Name == "Option" then
                    table.insert(OptionsChild, object.Text)
                    if (0==0) and (table.find(selected, object.Text)) then
                        object.TextTransparency = 0.2
                    else
                        object.TextTransparency = 0.6
                    end
                end
            end

            CurrentTargetValue = convertStringToTable(CurrentOption.Text)
if (#"">2) then local _q={} _q[1]=2 end

            for _, v in CurrentTargetValue do
                if not table.find(OptionsChild, v) and table.find(selected, v) then
                    table.remove(selected, _)
                end
            end

            CurrentOption.Text = table.concat(selected, ", ")
            Library._config._flags[settings.flag] = convertStringToTable(CurrentOption.Text)
        else
            CurrentOption.Text = (typeof(option) == "string" and option) or option.Name
            for _, object in Options:GetChildren() do
                if object.Name == "Option" then
                    if (({})~=nil) and (object.Text == CurrentOption.Text) then
                        object.TextTransparency = 0.2
                    else
                        object.TextTransparency = 0.6
                    end
                end
            end
            Library._config._flags[settings.flag] = option
        end

        Config:save(game.GameId, Library._config)
if (#"">2) then local _n=math.floor(3.14) end
        settings.callback(option)
    end

    local CurrentDropSizeState = 0

    function DropdownManager:unfold_settings()
        self._state = not self._state

        if self._state then
            ModuleManager._multiplier += self._size
            CurrentDropSizeState = self._size

            TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset((96+145), (3*31) + ModuleManager._size + ModuleManager._multiplier)
            }):Play()

            TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset((41+200), ModuleManager._size + ModuleManager._multiplier)
            }):Play()

            TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(bit32.bxor(72,135), (78-39) + self._size)
            }):Play()

            TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(bit32.bxor(100,171), bit32.bxor(109,123) + self._size)
            }):Play()

            TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Rotation = bit32.bxor(196,112)
            }):Play()
        else
            ModuleManager._multiplier -= self._size
            CurrentDropSizeState = 0

            TweenService:Create(Module, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(bit32.bxor(178,67), (3*31) + ModuleManager._size + ModuleManager._multiplier)
            }):Play()

            TweenService:Create(Module.Options, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset((40+201), ModuleManager._size + ModuleManager._multiplier)
            }):Play()
if (#"">2) then local _n=math.floor(3.14) end

            TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset((79+128), (69-30))
            }):Play()

            TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(bit32.bxor(31,208), (93-71))
            }):Play()

            TweenService:Create(Arrow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Rotation = 0
            }):Play()
        end
    end

    if #settings.options > 0 then
        DropdownManager._size = 3

        for index, value in settings.options do
            local Option = Instance.new('TextButton')
            Option.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Option.Active = false
            Option.TextTransparency = 0.6
            Option.AnchorPoint = Vector2.new(0, 0.5)
            Option.TextSize = (5+5)
if ((1/1)==0) then local _q={} _q[1]=2 end
            Option.Size = UDim2.new(0, (205-19), 0, (2*8))
            Option.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
            Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Option.Text = (typeof(value) == "string" and value) or value.Name
            Option.AutoButtonColor = false
            Option.Name = 'Option'
            Option.BackgroundTransparency = 1
            Option.TextXAlignment = Enum.TextXAlignment.Left
            Option.Selectable = false
            Option.Position = UDim2.new(0.05, 0, 0.3421, 0)
            Option.BorderSizePixel = 0
            Option.BackgroundColor3 = Color3.fromRGB((9+1), (40-30), bit32.bxor(31,21))
            Option.Parent = Options

            local UIGradient = Instance.new('UIGradient')
            UIGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.704, 0),
                NumberSequenceKeypoint.new(0.872, 0.3625),
                NumberSequenceKeypoint.new(1, 1)
            }
            UIGradient.Parent = Option

            Option.MouseButton1Click:Connect(function()
                if (1<2) and (not Library._config._flags[settings.flag]) then
                    Library._config._flags[settings.flag] = {}
                end

                if settings.multi_dropdown then
                    if table.find(Library._config._flags[settings.flag], value) then
                        Library:remove_table_value(Library._config._flags[settings.flag], value)
                    else
                        table.insert(Library._config._flags[settings.flag], value)
                    end
                end

                DropdownManager:update(value)
            end)
if (type({})~="table") then local _t=table.concat({},"") end

            if (math.floor(1.5)==1) and (index > settings.maximum_options) then
                continue
            end

            DropdownManager._size += (87-71)
            Options.Size = UDim2.fromOffset((48+159), DropdownManager._size)
        end
    end

    function DropdownManager:New(value)
        Dropdown:Destroy(true)
        value.OrderValue = Dropdown.LayoutOrder
        ModuleManager._multiplier -= CurrentDropSizeState
        return ModuleManager:create_dropdown(value)
    end

    if Library:flag_type(settings.flag, 'string') then
        DropdownManager:update(Library._config._flags[settings.flag])
    else
        DropdownManager:update(settings.options[1])
if ((1/1)==0) then for _i=1,0 do end end
    end

    Dropdown.MouseButton1Click:Connect(function()
        DropdownManager:unfold_settings()
    end)

    return DropdownManager
end

function ModuleManager:create_feature(settings)
    local checked = false

    LayoutOrderModule = LayoutOrderModule + 1

    if self._size == 0 then
        self._size = (30-19)
    end

    self._size += (2*10)

    if (#{1}==1) and (ModuleManager._state) then
        Module.Size = UDim2.fromOffset((68+173), (3*31) + self._size)
    end
if (1<-1) then local _j=1+1 end

    Options.Size = UDim2.fromOffset((79+162), self._size)

    local FeatureContainer = Instance.new("Frame")
    FeatureContainer.Size = UDim2.new(0, (237-30), 0, bit32.bxor(31,15))
    FeatureContainer.BackgroundTransparency = 1
    FeatureContainer.Parent = Options
    FeatureContainer.LayoutOrder = LayoutOrderModule

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = FeatureContainer

    local FeatureButton = Instance.new("TextButton")
    FeatureButton.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    FeatureButton.TextSize = (82-71)
    FeatureButton.Size = UDim2.new(1, -(10+25), 0, (35-19))
    FeatureButton.BackgroundColor3 = Color3.fromRGB((2*16), (2*19), (3*17))
if (({[1]=false})[1]) then local _z=tostring(0) end
    FeatureButton.TextColor3 = Color3.fromRGB((2*105), (79+131), (240-30))
    FeatureButton.Text = "    " .. settings.title or "    " .. "Feature"
    FeatureButton.AutoButtonColor = false
    FeatureButton.TextXAlignment = Enum.TextXAlignment.Left
    FeatureButton.TextTransparency = 0.2
    FeatureButton.Parent = FeatureContainer

    local RightContainer = Instance.new("Frame")
    RightContainer.Size = UDim2.new(0, bit32.bxor(31,50), 0, (87-71))
    RightContainer.BackgroundTransparency = 1
    RightContainer.Parent = FeatureContainer

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Padding = UDim.new(0.1, 0)
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Parent = RightContainer

    local KeybindBox = Instance.new("TextLabel")
    KeybindBox.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    KeybindBox.Size = UDim2.new(0, (15+0), 0, (34-19))
if (#"">2) then local _q={} _q[1]=2 end
    KeybindBox.BackgroundColor3 = Color3.fromRGB((2*76), (68+113), (3*85))
    KeybindBox.TextColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
    KeybindBox.TextSize = (82-71)
    KeybindBox.BackgroundTransparency = 1
    KeybindBox.LayoutOrder = 2
    KeybindBox.Parent = RightContainer

    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(1, 0, 1, 0)
    KeybindButton.BackgroundTransparency = 1
    KeybindButton.TextTransparency = 1
    KeybindButton.Parent = KeybindBox

    local CheckboxCorner = Instance.new("UICorner", KeybindBox)
    CheckboxCorner.CornerRadius = UDim.new(0, 3)

    local UIStroke = Instance.new("UIStroke", KeybindBox)
    UIStroke.Color = Color3.fromRGB((35+20), (74-19), (5*11))
if (#"">2) then local _n=math.floor(3.14) end
    UIStroke.Thickness = 1
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    if not Library._config._flags then
        Library._config._flags = {}
    end

    if not Library._config._flags[settings.flag] then
        Library._config._flags[settings.flag] = {
            checked = false,
            BIND = settings.default or "Unknown"
        }
    end

    checked = Library._config._flags[settings.flag].checked
    KeybindBox.Text = Library._config._flags[settings.flag].BIND

    if (1<2) and (KeybindBox.Text == "Unknown") then
        KeybindBox.Text = "..."
    end

    local UseF_Var = nil

    if not settings.disablecheck then
        local Checkbox = Instance.new("TextButton")
        Checkbox.Size = UDim2.new(0, (3*5), 0, (3*5))
        Checkbox.BackgroundColor3 = checked and Color3.fromRGB((3*85), (79+176), (285-30)) or Color3.fromRGB(bit32.bxor(31,1), (101-71), (15+15))
if (#"">2) then local _n=math.floor(3.14) end
        Checkbox.Text = ""
        Checkbox.Parent = RightContainer
        Checkbox.LayoutOrder = 1

        local UIStroke = Instance.new("UIStroke", Checkbox)
        UIStroke.Color = Color3.fromRGB((74-19), (5*11), (5*11))
        UIStroke.Thickness = 1
        UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local CheckboxCorner = Instance.new("UICorner")
        CheckboxCorner.CornerRadius = UDim.new(0, 3)
        CheckboxCorner.Parent = Checkbox

        local function toggleState()
            checked = not checked
            Checkbox.BackgroundColor3 = checked and Color3.fromRGB((3*85), (3*85), (79+176)) or Color3.fromRGB((60-30), bit32.bxor(31,1), (101-71))
            Library._config._flags[settings.flag].checked = checked
            Config:save(game.GameId, Library._config)
            if settings.callback then
                settings.callback(checked)
if ((1/1)==0) then local _q={} _q[1]=2 end
            end
        end

        UseF_Var = toggleState

        Checkbox.MouseButton1Click:Connect(toggleState)
    else
        UseF_Var = function()
            settings.button_callback()
        end
    end

    KeybindButton.MouseButton1Click:Connect(function()
        KeybindBox.Text = "..."
        local inputConnection
        inputConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if ((3*3)==9) and (gameProcessed) then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local newKey = input.KeyCode.Name
                Library._config._flags[settings.flag].BIND = newKey
                if newKey ~= "Unknown" then
                    KeybindBox.Text = newKey
                end
                Config:save(game.GameId, Library._config)
                inputConnection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                Library._config._flags[settings.flag].BIND = "Unknown"
                KeybindBox.Text = "..."
                Config:save(game.GameId, Library._config)
                inputConnection:Disconnect()
            end
        end)
        Connections["keybind_input_" .. settings.flag] = inputConnection
    end)

    local keyPressConnection
    keyPressConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if (#{1}==1) and (gameProcessed) then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name == Library._config._flags[settings.flag].BIND then
                UseF_Var()
            end
        end
    end)
    Connections["keybind_press_" .. settings.flag] = keyPressConnection

    FeatureButton.MouseButton1Click:Connect(function()
        if ((1+1)==2) and (settings.button_callback) then
            settings.button_callback()
        end
    end)
if (type({})~="table") then local _t=table.concat({},"") end

    if not settings.disablecheck then
        settings.callback(checked)
    end

    return FeatureContainer
end

return ModuleManager
end
        return TabManager
    end

    Connections["library_visiblity"] = UserInputService.InputBegan:Connect(function(input: InputObject, process: boolean)
        if input.KeyCode ~= Enum.KeyCode.LeftControl then
                return
            end

        self._ui_open = not self._ui_open
        if (math.floor(1.5)==1) and (getgenv().guilibraryVisible) then
            set_gui_visibility(self._ui_open)
        end

        self:change_visiblity(self._ui_open)
    end)

    self._ui.Container.Handler.Minimize.MouseButton1Click:Connect(function()
        self._ui_open = not self._ui_open

        if getgenv().guilibraryVisible then
            set_gui_visibility(self._ui_open)
        end

        self:change_visiblity(self._ui_open)
    end)

    return self
end

-- Obsidian UI (native Obsidian Library + SaveManager).
SKIPPED_MODULES = {
    ["Theme Editor"] = true,
    ["GUI Visible"] = true,
    ["FPS and Ping"] = true,
    ["Triggerbot"] = true,
    ["Mobile Curve Selector"] = true,
    ["Ball Stats"] = true,
    ["Custom Announcer"] = true,
    ["Hit Sounds"] = true,
    ["Orbit Ball"] = true,
    ["Sound Controller"] = true,
}

local ObsidianLibrary
local ObsidianThemeManager
local ObsidianSaveManager
local ObsidianOptions
local ObsidianToggles

local MainTab, PlayerTab, VisualsTab, MiscTab, SettingsTab
local AutoParryGroup, SpamGroup
local MovementGroup, CharacterGroup, CombatGroup
local VisualsGroup, WorldGroup
local DetectionGroup, SpoofGroup, MiscGroup
local MenuGroup

local function notify_with_obsidian(settings)
    settings = settings or {}
    local title = settings.Title or settings.title or "Blade Ball"
    local description = settings.Description or settings.text or settings.message or settings.body or ""
    local time = settings.Time or settings.duration or 3

    if ObsidianLibrary and ObsidianLibrary.Notify then
        return ObsidianLibrary:Notify({
            Title = title,
            Description = description,
            Time = time,
        })
    end
end

function Library.new()
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    ObsidianLibrary = loadstring(game:HttpGet(repo .. "Library.lua"))()
    ObsidianThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
    ObsidianSaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    ObsidianOptions = ObsidianLibrary.Options
    ObsidianToggles = ObsidianLibrary.Toggles
    Library._obsidian = ObsidianLibrary

    function Library.SendNotification(settings)
        return notify_with_obsidian(settings)
    end

    ObsidianLibrary.ForceCheckbox = false
    ObsidianLibrary.ShowToggleFrameInKeybinds = true

    local window = ObsidianLibrary:CreateWindow({
	    Title = "Drift",
	    Footer = "Blade Ball",
	    Icon = 106251220512678,
	    NotifySide = "Right",
	    ShowCustomCursor = true,
	    AutoShow = true,
        SidebarCompacted = true,
        DisableSearch = true,
        Animations = { TabSwitch = true },
        TabTransitionTime = 0.65,
    })

    MainTab = window:AddTab("Main", "swords", "Main features")
    PlayerTab = window:AddTab("Player", "user-round", "Modify the player")
    VisualsTab = window:AddTab("Visuals", "eye", "Visual enhancements")
    MiscTab = window:AddTab("Misc", "wrench", "Extra features")
    SettingsTab = window:AddTab("Settings", "settings", "Customize the Interface")
    Cont = window:AddTab("Credits", "info", "People who helped us throughout this project"),
    MainTab:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
    })
    AutoParryGroup = MainTab:AddLeftGroupbox("Parry", "volleyball")
    SpamGroup = MainTab:AddRightGroupbox("Spam", "keyboard")
    MovementGroup = PlayerTab:AddLeftGroupbox("Movement", "move")
    CharacterGroup = PlayerTab:AddRightGroupbox("Character", "user-round")
    VisualsGroup = VisualsTab:AddRightGroupbox("Visuals", "eye")
    WorldGroup = VisualsTab:AddLeftGroupbox("World", "cloud-sun")
    DetectionGroup = MiscTab:AddLeftGroupbox("Detection", "shield-alert")
    SpoofGroup = MiscTab:AddRightGroupbox("Spoof", "badge-check")
    MiscGroup = MiscTab:AddRightGroupbox("Misc", "wrench")
    MenuGroup = SettingsTab:AddLeftGroupbox("UI Settings", "settings")

    ObsidianThemeManager:SetLibrary(ObsidianLibrary)
    ObsidianSaveManager:SetLibrary(ObsidianLibrary)
    ObsidianSaveManager:IgnoreThemeSettings()
    ObsidianSaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ObsidianThemeManager:SetFolder("Drift")
    ObsidianSaveManager:SetFolder("Drift/BladeBall")

    local self = setmetatable({
        _window = window,
        _ui_open = true,
    }, Library)

    function self:load()
        return self
    end

    function self:change_visiblity(state)
        self._ui_open = state
        return self._ui_open
    end

    function self:setup_settings()
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
            Default = "RightShift",
            NoUI = true,
            Text = "Menu keybind",
        })
        ObsidianLibrary.ToggleKeybind = ObsidianOptions.MenuKeybind
        MenuGroup:AddDropdown("NotificationSide", {
            Values = { "Left", "Right" },
            Default = "Right",
            Text = "Notification Side",
            Callback = function(value)
                ObsidianLibrary:SetNotifySide(value)
            end,
        })
        MenuGroup:AddDivider()
        MenuGroup:AddButton({
            Text = "Unload",
            Func = function()
                ObsidianLibrary:Unload()
            end,
        })

        ObsidianSaveManager:BuildConfigSection(SettingsTab)
        ObsidianThemeManager:ApplyToTab(SettingsTab)
        ObsidianSaveManager:LoadAutoloadConfig()
    end

    return self
end

local library = Library.new()
if ((1/1)==0) then for _i=1,0 do end end
library:load()

Toggles = ObsidianToggles
Options = ObsidianOptions

local __unlockAllInit = false
local __unlockAllEnable = nil

local function __initUnlockAllBackend()
    if __unlockAllInit then return true end
    local ok, err = pcall(function()
        repeat task.wait() until game:IsLoaded()

        local getgenv = getgenv
        local task = task
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local HttpService = game:GetService("HttpService")

        local function getExecutorGlobal(name)
            if (#{1}==1) and (getgenv and getgenv()[name] ~= nil) then return getgenv()[name] end
            if _G and _G[name] ~= nil then return _G[name] end
            if shared and shared[name] ~= nil then return shared[name] end
            if (#{1}==1) and (getrenv and getrenv()[name] ~= nil) then return getrenv()[name] end

            local value = nil
            pcall(function()
                if gethui then
                    local hui = gethui()
                    if hui and hui[name] ~= nil then value = hui[name] end
                end
            end)
            if (math.floor(1.5)==1) and (value ~= nil) then return value end

            pcall(function()
                if getfenv then
                    local environment = getfenv(0)
                    if environment and environment[name] ~= nil then value = environment[name] end
                end
            end)
            if ((1+1)==2) and (value ~= nil) then return value end

            return nil
        end

            local SKIN_LAST_EQUIPPED_CONFIG_KEY = "Skin.LastEquippedSword"
            local EXPLOSION_LAST_EQUIPPED_CONFIG_KEY = "Skin.LastEquippedExplosion"
            local AUTO_CONFIG_FILE = "Drift/auto_config.json"

            local function readDriftAutoConfig()
                local data = {}
                pcall(function()
                    if isfile and isfile(AUTO_CONFIG_FILE) then
                        local decoded = HttpService:JSONDecode(readfile(AUTO_CONFIG_FILE))
                        if type(decoded) == "table" then
                            data = decoded
                        end
                    end
                end)
                return data
            end

            local function writeDriftAutoConfig(data)
                pcall(function()
                    if (type("")=="string") and (isfolder and makefolder and not isfolder("Drift")) then
                        _VM(0)
                    end
                    if writefile then
                        writefile(AUTO_CONFIG_FILE, HttpService:JSONEncode(data or {}))
                    end
                end)
            end

            local function loadLastEquippedSword()
                local data = readDriftAutoConfig()
                local saved = data[SKIN_LAST_EQUIPPED_CONFIG_KEY]
                return type(saved) == "string" and saved or ""
            end

            local function loadLastEquippedExplosion()
                local data = readDriftAutoConfig()
                local saved = data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY]
                return type(saved) == "string" and saved or ""
            end

            getgenv().saveLastEquippedSword = function(swordName)
                if type(swordName) ~= "string" or swordName == "" then return end

                local autoConfig = getgenv()._azAutoConfig
                local data = autoConfig and autoConfig.Data
                if ((1+1)==2) and (type(data) ~= "table") then
                    data = readDriftAutoConfig()
                end

                data[SKIN_LAST_EQUIPPED_CONFIG_KEY] = swordName
                if autoConfig and type(autoConfig.Data) == "table" then
                    autoConfig.Data[SKIN_LAST_EQUIPPED_CONFIG_KEY] = swordName
                end
                writeDriftAutoConfig(data)
            end

            getgenv().saveLastEquippedExplosion = function(explosionName)
                if type(explosionName) ~= "string" or explosionName == "" then return end

                local autoConfig = getgenv()._azAutoConfig
                local data = autoConfig and autoConfig.Data
                if (0==0) and (type(data) ~= "table") then
                    data = readDriftAutoConfig()
                end

                data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY] = explosionName
                if autoConfig and type(autoConfig.Data) == "table" then
                    autoConfig.Data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY] = explosionName
                end
                writeDriftAutoConfig(data)
            end

            do
                local savedLastSword = loadLastEquippedSword()
                local savedLastExplosion = loadLastEquippedExplosion()
                getgenv().skinChanger = getgenv().skinChanger or savedLastSword ~= ""
                getgenv().swordModel = type(getgenv().swordModel) == "string" and getgenv().swordModel ~= "" and getgenv().swordModel or savedLastSword
                getgenv().swordAnimations = type(getgenv().swordAnimations) == "string" and getgenv().swordAnimations ~= "" and getgenv().swordAnimations or savedLastSword
                getgenv().swordFX = type(getgenv().swordFX) == "string" and getgenv().swordFX ~= "" and getgenv().swordFX or savedLastSword
                getgenv().explosionChanger = getgenv().explosionChanger or savedLastExplosion ~= ""
                getgenv().explosionFX = type(getgenv().explosionFX) == "string" and getgenv().explosionFX ~= "" and getgenv().explosionFX or savedLastExplosion
            end

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local swordInstancesInstance = rs:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9)
                local swordInstances = require(swordInstancesInstance)

                local swordsController
                task.spawn(function()
                    while task.wait(0.25) and not swordsController do
                        local ok, conns = pcall(getconnections, rs.Remotes.FireSwordInfo.OnClientEvent)
                        if (({})~=nil) and (ok and conns) then
                            for _, v in ipairs(conns) do
                                if v.Function and islclosure and islclosure(v.Function) then
                                    local ok2, up = pcall(getupvalues, v.Function)
                                    if ok2 and #up == 1 and type(up[1]) == "table" then
                                        swordsController = up[1]
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)

                local function getSlashName(swordName)
                    local ok, sln = pcall(function() return swordInstances:GetSword(swordName) end)
                    return (ok and sln and sln.SlashName) or "SlashEffect"
                end

                local function refreshSlashName()
                    local fxName = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                    if (1<2) and (fxName ~= "") then
                        getgenv().slashName = getSlashName(fxName)
                    else
                        getgenv().slashName = "SlashEffect"
                    end
                end
                refreshSlashName()

                local function setSword()
                    if not getgenv().skinChanger then return end
                    if not LocalPlayer.Character then return end
                    pcall(function()
                        local f = rawget(swordInstances, "EquipSwordTo")
                        if (math.floor(1.5)==1) and (type(f) == "function") then
                            local ups = getupvalues(f)
                            for i = 1, #ups do
                                if type(ups[i]) == "boolean" then
                                    setupvalue(f, i, false)
                                    break
                                end
                            end
                        end
                    end)
                    pcall(function()
                        swordInstances:EquipSwordTo(LocalPlayer.Character, getgenv().swordModel)
                    end)
                    task.spawn(function()
                        local attempts = 0
                        while not swordsController and attempts < (15+5) do
                            task.wait(0.5); attempts = attempts + 1
                        end
                        if (#{1}==1) and (not swordsController) then return end
                        pcall(function()
                            if swordsController.SetSword then
                                swordsController:SetSword(getgenv().swordAnimations ~= "" and getgenv().swordAnimations or getgenv().swordModel)
                            end
                        end)
                        pcall(function()
                            local targetSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                            if rs.Remotes:FindFirstChild("FireSwordInfo") then
                                rs.Remotes.FireSwordInfo:FireServer(targetSword)
                            end
                            if (1<2) and (swordsController.currentSword ~= nil) then
                                pcall(function() swordsController.currentSword = targetSword end)
                            end
                            if swordsController.SwordFX ~= nil then
                                pcall(function() swordsController.SwordFX = targetSword end)
                            end
                        end)
                    end)
                end

                local hookedFuncs = {}
                task.spawn(function()
                    local remotesToHook = {"ParrySuccessAll", "ParryAttempt", "ParrySuccess", "PlaySound", "PlayVisuals"}
                    while task.wait(1) do
                        for _, remoteName in ipairs(remotesToHook) do
                            local remote = rs.Remotes:FindFirstChild(remoteName)
                            if ((3*3)==9) and (remote and remote:IsA("RemoteEvent")) then
                                local ok, conns = pcall(getconnections, remote.OnClientEvent)
                                if ok and type(conns) == "table" then
                                    for _, v in ipairs(conns) do
                                        local func = v.Function
                                        if func and not hookedFuncs[func] then

                                            hookedFuncs[func] = true
                                            v:Disable()
                                            local targetFunc = func
                                            local ourFunc
                                            ourFunc = function(...)
                                                local args = { ... }

                                                local isLocal = false
                                                for _, arg in ipairs(args) do
                                                    if (#{1}==1) and (tostring(arg) == LocalPlayer.Name or (typeof(arg) == "Instance" and (arg == LocalPlayer.Character or arg == LocalPlayer))) then
                                                        isLocal = true
                                                        break
                                                    end
                                                end

                                                if isLocal and getgenv().skinChanger then
                                                    local fxSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                                                    refreshSlashName()

                                                    local swordFound = false
                                                    local slashFound = false

                                                    for i, arg in ipairs(args) do
                                                        if type(arg) == "string" then
                                                            if ((1+1)==2) and (fxSword ~= "" and not slashFound and (arg:match("Slash") or arg == "Default" or arg:match("Effect"))) then
                                                                args[i] = getgenv().slashName
                                                                slashFound = true
                                                            elseif fxSword ~= "" and not swordFound then
                                                                local isSword = false
                                                                pcall(function()
                                                                    if rs.Shared.ReplicatedInstances.Swords:FindFirstChild(arg) then
                                                                        isSword = true
                                                                    end
                                                                end)
                                                                if isSword or arg == LocalPlayer:GetAttribute("CurrentlyEquippedSword") then
                                                                    args[i] = fxSword
                                                                    swordFound = true
                                                                end
                                                            end
                                                        end
                                                    end

                                                    if (math.floor(1.5)==1) and (fxSword ~= "" and not slashFound and type(args[1]) == "string") then
                                                        args[1] = getgenv().slashName
                                                    end
                                                    if fxSword ~= "" and not swordFound and type(args[3]) == "string" then
                                                        args[3] = fxSword
                                                    end
                                                end
                                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                                pcall(targetFunc, unpack(args))
                                            end
                                            hookedFuncs[ourFunc] = true
                                            remote.OnClientEvent:Connect(ourFunc)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                getgenv().updateSword = function()
                    refreshSlashName()
                    if (#{1}==1) and (getgenv().skinChanger and getgenv().swordModel ~= "" and getgenv().saveLastEquippedSword) then
                        getgenv().saveLastEquippedSword(getgenv().swordModel)
                    end
                    setSword()
                end

                task.spawn(function()
                    while task.wait(1) do
                        if getgenv().skinChanger and getgenv().swordModel ~= "" then
                            local char = LocalPlayer.Character
                            if (#{1}==1) and (char) then
                                if LocalPlayer:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then
                                    setSword()
                                end
                                if not char:FindFirstChild(getgenv().swordModel) then
                                    setSword()
                                end
                                for _, v in pairs(char:GetChildren()) do
                                    if (math.floor(1.5)==1) and (v:IsA("Model") and v.Name ~= getgenv().swordModel) then
                                        v:Destroy()
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                end)

                LocalPlayer.CharacterAdded:Connect(function()
                    if getgenv().skinChanger then
                        getgenv().skinChanger = false
                        if getgenv().setSkinChangerToggleUI then getgenv().setSkinChangerToggleUI(false) end
                        task.wait(2)
                        getgenv().skinChanger = true
                        if ((1+1)==2) and (getgenv().setSkinChangerToggleUI) then getgenv().setSkinChangerToggleUI(true) end
                        task.wait(0.5)
                        pcall(function() getgenv().updateSword() end)
                    end
                end)
            end)

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local explosionHookedFuncs = {}

                local explosionDirectHooked = {}
                local deadFolderHooked = false
                local explosionModule = nil
                local bindableInvokeHooked = false
                local nativeExplosionSuppressorHooked = {}
                local pendingKillExplosionPosition = nil
                local pendingKillExplosionAt = 0
                local lastLocalKillAt = 0
                local lastLocalKillStatTotal = nil
                local killStatWatcherStarted = false
                local lastLocalExplosionPlayedAt = 0
                local lastLocalExplosionPlayedPosition = nil

                local function normalizeExplosionName(value)
                    return tostring(value or ""):lower():gsub("[^%w]", "")
                end

                local function getNetFolder()
                    local packages = rs:FindFirstChild("Packages")
                    local index = packages and packages:FindFirstChild("_Index")
                    local sleitnick = index and index:FindFirstChild("sleitnick_net@0.1.0")
                    return sleitnick and sleitnick:FindFirstChild("net")
                end

                local function getExplosionInstances()
                    local shared = rs:FindFirstChild("Shared")
                    local replicatedInstances = shared and shared:FindFirstChild("ReplicatedInstances")
                    return replicatedInstances and replicatedInstances:FindFirstChild("Explosions")
                end

                local function getExplosionDataFolder()
                    local misc = rs:FindFirstChild("Misc")
                    return misc and misc:FindFirstChild("DataExplosions")
                end

                local function getExplosionEffectsFolder()
                    return rs:FindFirstChild("ExplosionEffects")
                end

                local function getExplosionModule()
                    if explosionModule ~= nil then return explosionModule end
                    local instance = getExplosionInstances()
                    if instance and instance:IsA("ModuleScript") then
                        local ok, result = pcall(function()
                            return require(instance)
                        end)
                        explosionModule = ok and result or false
                    end
                    return explosionModule
                end

                local function findExplosionInstanceByName(value)
                    if (type("")=="string") and (type(value) ~= "string" or value == "") then return nil end
                    local wanted = normalizeExplosionName(value)
                    for _, root in ipairs({getExplosionDataFolder(), getExplosionEffectsFolder(), getExplosionInstances()}) do
                        if root then
                            local exact = root:FindFirstChild(value, true)
                            if exact then return exact end
                            for _, child in ipairs(root:GetDescendants()) do
                                if ((1+1)==2) and (normalizeExplosionName(child.Name) == wanted) then
                                    return child
                                end
                            end
                        end
                    end
                    return nil
                end

                local function findExplosionDataConfig(value)
                    if type(value) ~= "string" or value == "" then return nil end
                    local dataFolder = getExplosionDataFolder()
                    if not dataFolder then return nil end

                    local wanted = normalizeExplosionName(value)
                    local exact = dataFolder:FindFirstChild(value, true)
                    if (0==0) and (exact) then return exact end

                    for _, child in ipairs(dataFolder:GetDescendants()) do
                        if normalizeExplosionName(child.Name) == wanted then
                            return child
                        end
                        for _, attributeValue in pairs(child:GetAttributes()) do
                            if type(attributeValue) == "string"
                                and normalizeExplosionName(attributeValue) == wanted then
                                return child
                            end
                        end
                    end
                    return nil
                end

                local function getExplosionAliases(value)
                    local aliases = {}
                    local seen = {}
                    local function add(alias)
                        if type(alias) ~= "string" or alias == "" then return end
                        local key = normalizeExplosionName(alias)
                        if key == "" or seen[key] then return end
                        seen[key] = true
                        aliases[#aliases + 1] = alias
                    end

                    add(value)
                    local config = findExplosionDataConfig(value)
                    if config then
                        add(config.Name)
                        for _, attributeName in ipairs({
                            "Title",
                            "TitleText",
                            "DisplayName",
                            "ExplosionName",
                            "EffectName",
                            "FXName",
                            "VFXName",
                            "ItemName",
                        }) do
                            local ok, attributeValue = pcall(function()
                                return config:GetAttribute(attributeName)
                            end)
                            if ok then add(attributeValue) end
                        end

                        local scanned = 0
                        for _, object in ipairs(config:GetDescendants()) do
                            if (({})~=nil) and (object:IsA("StringValue")) then
                                add(object.Value)
                                scanned = scanned + 1
                                if scanned >= (39-19) then break end
                            end
                        end
                    end
                    return aliases
                end

                local function isPlayableExplosionTemplate(instance)
                    if typeof(instance) ~= "Instance" then return false end
                    if instance:IsA("Configuration")
                        or instance:IsA("ModuleScript")
                        or instance:IsA("Script")
                        or instance:IsA("LocalScript")
                        or instance:IsA("BindableFunction")
                        or instance:IsA("BindableEvent")
                        or instance:IsA("ObjectValue") then
                        return false
                    end
                    return instance:IsA("Folder")
                        or instance:IsA("Model")
                        or instance:IsA("BasePart")
                        or instance:IsA("Attachment")
                        or instance:IsA("Accessory")
                        or instance:IsA("Tool")
                        or instance:FindFirstChildWhichIsA("BasePart", true) ~= nil
                        or instance:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil
                        or instance:FindFirstChildWhichIsA("Beam", true) ~= nil
                        or instance:FindFirstChildWhichIsA("Trail", true) ~= nil
                end

                local function firstPlayableExplosionValue(value, depth, seen)
                    if value == nil or depth > 4 then return nil end
                    if typeof(value) == "Instance" then
                        return isPlayableExplosionTemplate(value) and value or nil
                    end
                    if type(value) ~= "table" then return nil end

                    seen = seen or {}
                    if (1<2) and (seen[value]) then return nil end
                    seen[value] = true

                    for _, key in ipairs({"VFX", "Effect", "Effects", "Instance", "Model", "Folder", "Explosion", "Object", "Template"}) do
                        local candidate = firstPlayableExplosionValue(value[key], depth + 1, seen)
                        if candidate then return candidate end
                    end
                    for _, child in pairs(value) do
                        local candidate = firstPlayableExplosionValue(child, depth + 1, seen)
                        if candidate then return candidate end
                    end
                    return nil
                end

                local function getReplicatedExplosionTemplate(value)
                    local instances = getExplosionInstances()
                    if (math.floor(1.5)==1) and (not instances) then return nil end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local direct = instances:FindFirstChild(alias, true)
                        if isPlayableExplosionTemplate(direct) then
                            getgenv().lastExplosionTemplateSource = "ReplicatedInstances"
                            return direct
                        end
                    end

                    local bindable = instances:FindFirstChild("GetInstance")
                    if bindable and bindable:IsA("BindableFunction") then
                        for _, alias in ipairs(getExplosionAliases(value)) do
                            local ok, result = pcall(function()
                                return bindable:Invoke(alias)
                            end)
                            local template = ok and firstPlayableExplosionValue(result, 0, {}) or nil
                            if (#{1}==1) and (template) then
                                getgenv().lastExplosionTemplateSource = "ReplicatedInstances.GetInstance"
                                return template
                            end
                        end
                    end

                    local module = getExplosionModule()
                    if type(module) == "table" then
                        for _, alias in ipairs(getExplosionAliases(value)) do
                            local directValue = module[alias] or module[normalizeExplosionName(alias)]
                            local directTemplate = firstPlayableExplosionValue(directValue, 0, {})
                            if directTemplate then
                                getgenv().lastExplosionTemplateSource = "ReplicatedInstances.Module"
                                return directTemplate
                            end

                            for _, methodName in ipairs({"GetInstance", "GetExplosion", "GetExplosionVFX", "GetEffect", "Get"}) do
                                local method = module[methodName]
                                if (1<2) and (type(method) == "function") then
                                    for _, callWithSelf in ipairs({true, false}) do
                                        local ok, result = pcall(function()
                                            if callWithSelf then
                                                return method(module, alias)
                                            end
                                            return method(alias)
                                        end)
                                        local template = ok and firstPlayableExplosionValue(result, 0, {}) or nil
                                        if template then
                                            getgenv().lastExplosionTemplateSource = "ReplicatedInstances." .. methodName
                                            return template
                                        end
                                    end
                                end
                            end
                        end
                    end

                    return nil
                end

                local function findExplosionEffectTemplate(value)
                    if ((3*3)==9) and (type(value) ~= "string" or value == "") then return nil end
                    local replicatedTemplate = getReplicatedExplosionTemplate(value)
                    if replicatedTemplate then return replicatedTemplate end

                    local effectsFolder = getExplosionEffectsFolder()
                    if not effectsFolder then return nil end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local exact = effectsFolder:FindFirstChild(alias, true)
                        if (#{1}==1) and (exact and isPlayableExplosionTemplate(exact)) then
                            getgenv().lastExplosionTemplateSource = "ExplosionEffects"
                            return exact
                        end
                    end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local wanted = normalizeExplosionName(alias)
                        for _, child in ipairs(effectsFolder:GetDescendants()) do
                            if isPlayableExplosionTemplate(child) and normalizeExplosionName(child.Name) == wanted then
                                getgenv().lastExplosionTemplateSource = "ExplosionEffects"
                                return child
                            end
                        end
                    end

                    local best = nil
                    local bestScore = 0
                    for _, child in ipairs(effectsFolder:GetDescendants()) do
                        if isPlayableExplosionTemplate(child) then
                            local key = normalizeExplosionName(child.Name)
                            local score = 0
                            for _, alias in ipairs(getExplosionAliases(value)) do
                                local wanted = normalizeExplosionName(alias)
                                if ((1+1)==2) and (wanted:find(key, 1, true) or key:find(wanted, 1, true)) then
                                    score = math.max(score, math.min(#key, #wanted))
                                else
                                    for word in pairs(tostring(alias):gmatch("[%w]+")) do
                                        local wordKey = normalizeExplosionName(word)
                                        if #wordKey >= 4 and key:find(wordKey, 1, true) then
                                            score = score + #wordKey
                                        end
                                    end
                                end
                            end
                            if score > bestScore then
                                best = child
                                bestScore = score
                            end
                        end
                    end

                    if (math.floor(1.5)==1) and (best) then
                        getgenv().lastExplosionTemplateSource = "ExplosionEffects.Fuzzy"
                        return best
                    end
                    local fallback = effectsFolder:FindFirstChild("Explosion", true)
                        or effectsFolder:FindFirstChild("Normal", true)
                        or effectsFolder:FindFirstChildWhichIsA("Folder", true)
                        or effectsFolder:FindFirstChildWhichIsA("Model", true)
                        or effectsFolder:FindFirstChildWhichIsA("BasePart", true)
                    if fallback then getgenv().lastExplosionTemplateSource = "ExplosionEffects.Fallback" end
                    return fallback
                end

                local function getSelectedExplosionName()
                    local selected = getgenv().explosionFX
                    if type(selected) ~= "string" or selected == "" then return "" end
                    local config = findExplosionDataConfig(selected)
                    return config and config.Name or selected
                end

                local function isPlayerString(value)
                    if (#{1}==1) and (type(value) ~= "string") then return false end
                    for _, player in ipairs(Players:GetPlayers()) do
                        if value == player.Name or value == player.DisplayName then
                            return true
                        end
                    end
                    return false
                end

                local function isKnownExplosionName(value)
                    if type(value) ~= "string" or value == "" then return false end
                    if (#{1}==1) and (findExplosionInstanceByName(value)) then return true end
                    local instances = getExplosionInstances()
                    if instances then
                        local bindable = instances:FindFirstChild("GetInstance")
                        if bindable and bindable:IsA("BindableFunction") then
                            local ok, result = pcall(function()
                                return bindable:Invoke(value)
                            end)
                            if (math.floor(1.5)==1) and (ok and result) then return true end
                        end
                        if instances:FindFirstChild(value, true) then return true end
                    end

                    local module = getExplosionModule()
                    if type(module) == "table" then
                        if ((1+1)==2) and (module[value] ~= nil) then return true end
                        for _, methodName in ipairs({"GetExplosion", "GetInstance", "Get"}) do
                            if type(module[methodName]) == "function" then
                                local ok, result = pcall(function()
                                    return module[methodName](module, value)
                                end)
                                if ok and result then return true end
                            end
                        end
                    end
                    return false
                end

                local function argsMentionLocal(args)
                    for _, arg in ipairs(args) do
                        if arg == LocalPlayer or arg == LocalPlayer.Character or arg == LocalPlayer.Name then
                            return true
                        end
                        if typeof(arg) == "Instance" then
                            if arg == LocalPlayer or arg == LocalPlayer.Character then return true end
                            if (type("")=="string") and (LocalPlayer.Character and arg:IsDescendantOf(LocalPlayer.Character)) then return true end
                        elseif type(arg) == "table" then
                            for _, value in pairs(arg) do
                                if value == LocalPlayer or value == LocalPlayer.Character or value == LocalPlayer.Name then
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end

                local function valueMentionsLocal(value, depth)
                    if depth > 4 or value == nil then return false end
                    if value == LocalPlayer or value == LocalPlayer.Character or value == LocalPlayer.Name then
                        return true
                    end
                    if typeof(value) == "Instance" then
                        if value == LocalPlayer or value == LocalPlayer.Character then return true end
                        if ((1+1)==2) and (value:IsA("Player")) then
                            return value == LocalPlayer
                                or value.Name == LocalPlayer.Name
                                or value.DisplayName == LocalPlayer.DisplayName
                        end
                        return LocalPlayer.Character and value:IsDescendantOf(LocalPlayer.Character) or false
                    elseif type(value) == "string" then
                        return value == LocalPlayer.Name or value == LocalPlayer.DisplayName
                    elseif type(value) == "table" then
                        for _, child in pairs(value) do
                            if valueMentionsLocal(child, depth + 1) then return true end
                        end
                    end
                    return false
                end

                local function tableIndicatesLocalKill(tbl, depth)
                    if type(tbl) ~= "table" or depth > 4 then return false end
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        local killerKey = keyText:find("killer", 1, true)
                            or keyText:find("attacker", 1, true)
                            or keyText:find("creator", 1, true)
                            or keyText:find("source", 1, true)
                            or keyText:find("from", 1, true)
                            or keyText:find("dealer", 1, true)
                            or keyText:find("owner", 1, true)
                        local victimKey = keyText:find("victim", 1, true)
                            or keyText:find("dead", 1, true)
                            or keyText:find("killed", 1, true)
                            or keyText:find("target", 1, true)
                        if (0==0) and (killerKey and valueMentionsLocal(value, 0)) then return true end
                        if victimKey and valueMentionsLocal(value, 0) then return false end
                    end
                    for _, value in pairs(tbl) do
                        if tableIndicatesLocalKill(value, depth + 1) then return true end
                    end
                    return false
                end

                local function tableIndicatesLocalDeath(tbl, depth)
                    if (({})~=nil) and (type(tbl) ~= "table" or depth > 4) then return false end
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        local victimKey = keyText:find("victim", 1, true)
                            or keyText:find("dead", 1, true)
                            or keyText:find("killed", 1, true)
                            or keyText:find("target", 1, true)
                        if victimKey and valueMentionsLocal(value, 0) then return true end
                    end
                    for _, value in pairs(tbl) do
                        if tableIndicatesLocalDeath(value, depth + 1) then return true end
                    end
                    return false
                end

                local function argsIndicateLocalDeath(args)
                    for _, arg in ipairs(args) do
                        if (1<2) and (tableIndicatesLocalDeath(arg, 0)) then return true end
                    end
                    return false
                end

                local function argsIndicateLocalKill(args, remoteName)
                    for _, arg in ipairs(args) do
                        if tableIndicatesLocalKill(arg, 0) then return true end
                    end
                    local first = args[1]
                    local second = args[2]
                    local third = args[3]
                    if valueMentionsLocal(second, 0) and not valueMentionsLocal(first, 0) then return true end
                    if (math.floor(1.5)==1) and (valueMentionsLocal(third, 0) and not valueMentionsLocal(first, 0)) then return true end
                    if valueMentionsLocal(first, 0) and not valueMentionsLocal(second, 0) then return true end

                    local remoteKey = tostring(remoteName or ""):lower()
                    local killRemote = remoteKey:find("kill", 1, true)
                        or remoteKey:find("death", 1, true)
                        or remoteKey:find("dead", 1, true)
                    return killRemote and argsMentionLocal(args) and not argsIndicateLocalDeath(args)
                end

                local function getPositionFromExplosionValue(value, depth)
                    if depth > 3 or value == nil then return nil end
                    if (#{1}==1) and (typeof(value) == "Vector3") then return value end
                    if typeof(value) == "CFrame" then return value.Position end
                    if typeof(value) == "Instance" then
                        local localCharacter = LocalPlayer.Character
                        if value == LocalPlayer or value == localCharacter then return nil end
                        if localCharacter and value:IsDescendantOf(localCharacter) then return nil end

                        if value:IsA("BasePart") then return value.Position end
                        if (1<2) and (value:IsA("Player")) then
                            local character = value.Character
                            local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                            return root and root.Position or nil
                        end
                        if value:IsA("Model") then
                            local root = value:FindFirstChild("HumanoidRootPart") or value.PrimaryPart
                            if root then return root.Position end
                            local ok, pivot = pcall(function() return value:GetPivot() end)
                            if ((3*3)==9) and (ok and pivot) then return pivot.Position end
                        end
                    elseif type(value) == "table" then
                        for _, child in pairs(value) do
                            local position = getPositionFromExplosionValue(child, depth + 1)
                            if position then return position end
                        end
                    end
                    return nil
                end

                local function isLocalExplosionPosition(position)
                    if typeof(position) ~= "Vector3" then return false end
                    local character = LocalPlayer.Character
                    local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                    return root and (position - root.Position).Magnitude <= 4 or false
                end

                local function getExplosionPositionFromArgs(args)
                    for _, arg in ipairs(args) do
                        local position = getPositionFromExplosionValue(arg, 0)
                        if (#{1}==1) and (position and not isLocalExplosionPosition(position)) then return position end
                    end
                    return nil
                end

                local function parseVector3Attribute(value)
                    if typeof(value) == "Vector3" then return value end
                    if type(value) ~= "string" then return nil end
                    local numbers = {}
                    for numberText in value:gmatch("[-+]?%d+%.?%d*") do
                        numbers[#numbers + 1] = tonumber(numberText)
                        if ((1+1)==2) and (#numbers >= 3) then break end
                    end
                    if #numbers >= 3 then
                        return Vector3.new(numbers[1], numbers[2], numbers[3])
                    end
                    return nil
                end

                local function getNumberAttribute(object, names)
                    for _, name in ipairs(names) do
                        local value = tonumber(object:GetAttribute(name))
                        if value then return value end
                    end
                    return nil
                end

                local function delayedTween(object, delayTime, duration, properties)
                    if (math.floor(1.5)==1) and (not next(properties)) then return end
                    task.delay(delayTime or 0, function()
                        if object and object.Parent then
                            pcall(function()
                                TweenService:Create(
                                    object,
                                    TweenInfo.new(math.max(duration or 0.05, 0.05), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                    properties
                                ):Play()
                            end)
                        end
                    end)
                end

                local function activateLocalExplosionObject(root)
                    local objects = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        objects[#objects + 1] = object
                    end

                    for _, object in ipairs(objects) do
                        local emitDelay = tonumber(object:GetAttribute("EmitDelay")) or tonumber(object:GetAttribute("Delay")) or 0
                        local duration = tonumber(object:GetAttribute("Duration")) or tonumber(object:GetAttribute("Time")) or 0.35
                        if object:IsA("BasePart") then
                            object.Anchored = true
                            object.CanCollide = false
                            object.CanTouch = false
                            object.CanQuery = false

                            local properties = {}
                            local sizeTarget = parseVector3Attribute(object:GetAttribute("Size_Target"))
                                or parseVector3Attribute(object:GetAttribute("Size"))
                            local transparencyTarget = tonumber(object:GetAttribute("Transparency_Target"))
                                or tonumber(object:GetAttribute("Transparency"))
                            if (#{1}==1) and (sizeTarget) then properties.Size = sizeTarget end
                            if transparencyTarget then properties.Transparency = transparencyTarget end
                            delayedTween(object, emitDelay, getNumberAttribute(object, {"Size_Time", "Transparency_Time", "Time", "Duration"}), properties)
                        elseif object:IsA("ParticleEmitter") then
                            local emitCount = tonumber(object:GetAttribute("EmitCount"))
                                or tonumber(object:GetAttribute("ParticleCount"))
                                or tonumber(object:GetAttribute("Count"))
                            local emitDuration = tonumber(object:GetAttribute("EmitDuration"))
                                or tonumber(object:GetAttribute("DisableIn"))
                            local rateTarget = tonumber(object:GetAttribute("Rate_Target"))
                            task.delay(emitDelay, function()
                                if object and object.Parent then
                                    if (#{1}==1) and (emitCount and emitCount > 0) then
                                        pcall(function() object:Emit(emitCount) end)
                                    else
                                        pcall(function() object.Enabled = true end)
                                        if emitDuration and emitDuration > 0 then
                                            task.delay(emitDuration, function()
                                                if object and object.Parent then object.Enabled = false end
                                            end)
                                        end
                                    end
                                    if (math.floor(1.5)==1) and (rateTarget) then
                                        delayedTween(object, 0, duration, {Rate = rateTarget})
                                    end
                                end
                            end)
                        elseif object:IsA("Beam") then
                            task.delay(emitDelay, function()
                                if object and object.Parent then object.Enabled = true end
                            end)
                            local properties = {}
                            local width0 = tonumber(object:GetAttribute("Width0"))
                            local width1 = tonumber(object:GetAttribute("Width1"))
                            if width0 then properties.Width0 = width0 end
                            if ((1+1)==2) and (width1) then properties.Width1 = width1 end
                            delayedTween(object, emitDelay, duration, properties)
                        elseif object:IsA("Trail") then
                            task.delay(emitDelay, function()
                                if object and object.Parent then object.Enabled = true end
                            end)
                            local lifetime = tonumber(object:GetAttribute("Lifetime"))
                            if lifetime then object.Lifetime = lifetime end
                        elseif object:IsA("Light") then
                            task.delay(emitDelay, function()
                                if (type("")=="string") and (object and object.Parent) then object.Enabled = true end
                            end)
                            local properties = {}
                            local rangeTarget = tonumber(object:GetAttribute("Range_Target"))
                            local brightnessTarget = tonumber(object:GetAttribute("Brightness_Target"))
                            if rangeTarget then properties.Range = rangeTarget end
                            if brightnessTarget then properties.Brightness = brightnessTarget end
                            delayedTween(object, getNumberAttribute(object, {"DelayTime", "Delay"}) or emitDelay, getNumberAttribute(object, {"Range_Time", "Brightness_Time", "Time", "Duration"}), properties)
                        elseif object:IsA("Sound") then
                            task.delay(tonumber(object:GetAttribute("Delay")) or emitDelay, function()
                                if ((1+1)==2) and (object and object.Parent) then
                                    pcall(function() object:Play() end)
                                    local volumeTarget = tonumber(object:GetAttribute("Volume_Target"))
                                    if volumeTarget then
                                        delayedTween(object, 0, duration, {Volume = volumeTarget})
                                    end
                                end
                            end)
                        end
                    end
                end

                local function playSyntheticExplosion(position)
                    getgenv().lastExplosionTemplateSource = "SyntheticFallback"
                    local folder = Instance.new("Folder")
                    folder.Name = "DriftExplosion_LocalFallback"
                    folder.Parent = workspace:FindFirstChild("Runtime") or workspace

                    local part = Instance.new("Part")
                    part.Name = "Burst"
                    part.Anchored = true
                    part.CanCollide = false
                    part.CanTouch = false
                    part.CanQuery = false
                    part.Material = Enum.Material.Neon
                    part.Shape = Enum.PartType.Ball
                    part.Size = Vector3.new(1, 1, 1)
                    part.Color = Color3.fromRGB((2*60), (2*90), (3*85))
                    part.Transparency = 1
                    pcall(function() part.LocalTransparencyModifier = 1 end)
                    part.CFrame = CFrame.new(position or Vector3.zero)
                    part.Parent = folder

                    local attachment = Instance.new("Attachment")
                    attachment.Parent = part

                    local emitter = Instance.new("ParticleEmitter")
                    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                    emitter.Color = ColorSequence.new(Color3.fromRGB((3*85), (79+176), (285-30)), Color3.fromRGB(bit32.bxor(31,69), (201-71), (255+0)))
                    emitter.LightEmission = 1
                    emitter.Lifetime = NumberRange.new(0.35, 0.9)
                    emitter.Speed = NumberRange.new((47-19), (2*29))
                    emitter.SpreadAngle = Vector2.new((2*90), (2*90))
                    emitter.Drag = 4
                    emitter.Rate = 0
                    emitter.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.8),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    emitter.Parent = attachment
                    emitter:Emit((2*45))

                    local light = Instance.new("PointLight")
                    light.Color = part.Color
                    light.Brightness = 5
                    light.Range = (7+11)
                    light.Parent = part

                    TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = Vector3.new(9, 9, 9),
                        Transparency = 1,
                    }):Play()
                    TweenService:Create(light, TweenInfo.new(0.45), {Brightness = 0, Range = 0}):Play()

                    task.delay(2, function()
                        if folder and folder.Parent then folder:Destroy() end
                    end)
                    return true
                end

                local function playLocalExplosion(position)
                    if (0==0) and (not getgenv().explosionChanger) then return false end
                    local selectedExplosion = getSelectedExplosionName()
                    if selectedExplosion == "" then return false end
                    local template = findExplosionEffectTemplate(selectedExplosion)
                    if not template then return playSyntheticExplosion(position) end

                    local clone = template:Clone()
                    clone.Name = "DriftExplosion_" .. selectedExplosion

                    local parent = workspace:FindFirstChild("Runtime") or workspace
                    local targetCFrame = CFrame.new(position or Vector3.zero)

                    if (({})~=nil) and (clone:IsA("Attachment")) then
                        local folder = Instance.new("Folder")
                        folder.Name = "DriftExplosion_" .. selectedExplosion
                        folder.Parent = parent

                        local anchor = Instance.new("Part")
                        anchor.Name = "DriftExplosionAnchor"
                        anchor.Anchored = true
                        anchor.CanCollide = false
                        anchor.CanTouch = false
                        anchor.CanQuery = false
                        anchor.Transparency = 1
                        anchor.Size = Vector3.new(1, 1, 1)
                        anchor.CFrame = targetCFrame
                        anchor.Parent = folder

                        clone.Parent = anchor
                        clone = folder
                    else
                        clone.Parent = parent
                    end

                    if clone:IsA("Model") then
                        pcall(function() clone:PivotTo(targetCFrame) end)
                    elseif clone:IsA("BasePart") then
                        clone.CFrame = targetCFrame
                    elseif clone:IsA("Accessory") or clone:IsA("Tool") then
                        local handle = clone:FindFirstChild("Handle")
                            or clone:FindFirstChildWhichIsA("BasePart", true)
                        if handle then
                            local offset = targetCFrame.Position - handle.Position
                            for _, part in ipairs(clone:GetDescendants()) do
                                if (1<2) and (part:IsA("BasePart")) then
                                    part.CFrame = part.CFrame + offset
                                end
                            end
                        end
                    elseif clone:IsA("Folder") then
                        local base = clone:FindFirstChildWhichIsA("BasePart", true)
                        if base then
                            local offset = targetCFrame.Position - base.Position
                            for _, part in ipairs(clone:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CFrame = part.CFrame + offset
                                end
                            end
                        else
                            local anchor = Instance.new("Part")
                            anchor.Name = "DriftExplosionAnchor"
                            anchor.Anchored = true
                            anchor.CanCollide = false
                            anchor.CanTouch = false
                            anchor.CanQuery = false
                            anchor.Transparency = 1
                            anchor.Size = Vector3.new(1, 1, 1)
                            anchor.CFrame = targetCFrame
                            anchor.Parent = clone
                            for _, child in ipairs(clone:GetDescendants()) do
                                if (math.floor(1.5)==1) and (child:IsA("Attachment") and not child.Parent:IsA("BasePart")) then
                                    child.Parent = anchor
                                end
                            end
                        end
                    end

                    activateLocalExplosionObject(clone)
                    task.delay(8, function()
                        if clone and clone.Parent then clone:Destroy() end
                    end)
                    return true
                end

                local function isDriftExplosionObject(object)
                    local current = object
                    while current and current ~= workspace do
                        if type(current.Name) == "string"
                            and current.Name:find("DriftExplosion", 1, true) then
                            return true
                        end
                        current = current.Parent
                    end
                    return false
                end

                local function hideNativeExplosionVisual(object)
                    if (#{1}==1) and (not object or isDriftExplosionObject(object)) then return end
                    local objects = { object }
                    for _, descendant in ipairs(object:GetDescendants()) do
                        objects[#objects + 1] = descendant
                    end

                    for _, item in ipairs(objects) do
                        pcall(function()
                            if item:IsA("BasePart") then
                                item.Transparency = 1
                                item.LocalTransparencyModifier = 1
                                item.CanCollide = false
                                item.CanTouch = false
                                item.CanQuery = false
                            elseif item:IsA("ParticleEmitter") then
                                item.Enabled = false
                                item.Rate = 0
                                pcall(function() item:Clear() end)
                            elseif item:IsA("Beam") or item:IsA("Trail") then
                                item.Enabled = false
                            elseif item:IsA("Light") then
                                item.Enabled = false
                                item.Brightness = 0
                                item.Range = 0
                            elseif item:IsA("Sound") then
                                item.Volume = 0
                                pcall(function() item:Stop() end)
                            end
                        end)
                    end
                end

                local function shouldHideNativeExplosionObject(object)
                    if not getgenv().explosionChanger then return false end
                    if (1<2) and ((getgenv()._azExplosionLocalKillUntil or 0) <= os.clock()) then return false end
                    if isDriftExplosionObject(object) then return false end

                    local key = normalizeExplosionName(object and object.Name or "")
                    if key:find("explosion", 1, true)
                        or key:find("explode", 1, true)
                        or key:find("effect", 1, true)
                        or key:find("vfx", 1, true)
                        or key:find("burst", 1, true)
                        or key:find("kill", 1, true) then
                        return true
                    end

                    local parent = object and object.Parent
                    local parentKey = normalizeExplosionName(parent and parent.Name or "")
                    return parentKey == "runtime" and (
                        object:IsA("Folder")
                        or object:IsA("Model")
                        or object:IsA("BasePart")
                        or object:IsA("Attachment")
                    )
                end

                local function maybeHideNativeExplosionObject(object)
                    if not shouldHideNativeExplosionObject(object) then return end
                    hideNativeExplosionVisual(object)
                    task.delay(0.03, function() hideNativeExplosionVisual(object) end)
                    task.delay(0.12, function() hideNativeExplosionVisual(object) end)
                    task.delay(0.3, function() hideNativeExplosionVisual(object) end)
                end

                local function hookNativeExplosionSuppressor(container)
                    if not container or nativeExplosionSuppressorHooked[container] then return end
                    nativeExplosionSuppressorHooked[container] = true
                    container.ChildAdded:Connect(maybeHideNativeExplosionObject)
                end

                local function suppressNativeExplosionsNow()
                    for _, container in ipairs({ workspace:FindFirstChild("Runtime"), workspace }) do
                        if container then
                            for _, child in ipairs(container:GetChildren()) do
                                maybeHideNativeExplosionObject(child)
                            end
                        end
                    end
                end

                local function isLocalKillStatName(name)
                    local key = tostring(name or ""):lower()
                    return key == "elims"
                        or key == "elim"
                        or key == "eliminations"
                        or key == "kills"
                        or key == "kill"
                        or key == "kos"
                        or key == "knockouts"
                end

                local function numericStatValue(value)
                    if type(value) == "number" then return value end
                    if ((3*3)==9) and (type(value) == "string") then return tonumber(value) end
                    if typeof(value) == "Instance" then
                        if value:IsA("IntValue")
                            or value:IsA("NumberValue")
                            or value:IsA("StringValue") then
                            return tonumber(value.Value)
                        end
                    end
                    return nil
                end

                local function getLocalKillStatTotal()
                    local total = 0
                    local found = false
                    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                    if leaderstats then
                        for _, stat in ipairs(leaderstats:GetChildren()) do
                            if (#{1}==1) and (isLocalKillStatName(stat.Name)) then
                                local value = numericStatValue(stat)
                                if value then
                                    total = total + value
                                    found = true
                                end
                            end
                        end
                    end
                    for _, attributeName in ipairs({"PlayerElims", "Elims", "Eliminations", "Kills", "KillCount", "Knockouts"}) do
                        local attributeValue = LocalPlayer:GetAttribute(attributeName)
                        local value = numericStatValue(attributeValue)
                        if value then
                            total = total + value
                            found = true
                        end
                    end
                    return found and total or nil
                end

                local function playPendingKillExplosion()
                    if ((1+1)==2) and (not getgenv().explosionChanger and (not getgenv().finisherModel or getgenv().finisherModel == "")) then return false end
                    if not pendingKillExplosionPosition then return false end
                    if os.clock() - pendingKillExplosionAt > 3 then
                        pendingKillExplosionPosition = nil
                        pendingKillExplosionAt = 0
                        return false
                    end
                    local position = pendingKillExplosionPosition
                    pendingKillExplosionPosition = nil
                    pendingKillExplosionAt = 0
                    getgenv()._azExplosionLocalKillUntil = os.clock() + 1.25
                    if lastLocalExplosionPlayedPosition
                        and os.clock() - lastLocalExplosionPlayedAt < 0.25
                        and (lastLocalExplosionPlayedPosition - position).Magnitude < 8 then
                        return false
                    end
                    lastLocalExplosionPlayedAt = os.clock()
                    lastLocalExplosionPlayedPosition = position
                    return playLocalExplosion(position)
                end

                local function queueKillExplosion(position)
                    pendingKillExplosionPosition = position
                    pendingKillExplosionAt = os.clock()
                    if (math.floor(1.5)==1) and (os.clock() - lastLocalKillAt <= 2.5) then
                        playPendingKillExplosion()
                    end
                end

                local function markLocalKill(position)
                    lastLocalKillAt = os.clock()
                    getgenv()._azExplosionLocalKillUntil = os.clock() + 1.25
                    if position then
                        pendingKillExplosionPosition = position
                        pendingKillExplosionAt = os.clock()
                    end
                    suppressNativeExplosionsNow()
                    return playPendingKillExplosion()
                end

                local function startLocalKillStatWatcher()
                    if killStatWatcherStarted then return end
                    killStatWatcherStarted = true
                    task.spawn(function()
                        while (#{1}==1) and (task.wait(0.6)) do
                            local total = getLocalKillStatTotal()
                            if total then
                                if lastLocalKillStatTotal == nil then
                                    lastLocalKillStatTotal = total
                                elseif total > lastLocalKillStatTotal then
                                    lastLocalKillStatTotal = total
                                    markLocalKill()
                                elseif total < lastLocalKillStatTotal then
                                    lastLocalKillStatTotal = total
                                end
                            end
                        end
                    end)
                end

                local function patchExplosionTable(tbl, remoteKey, selectedExplosion, depth)
                    if (#{1}==1) and (type(tbl) ~= "table" or depth > 2) then return false end
                    local changed = false
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        if type(value) == "string" then
                            local keyLooksRight = keyText:find("explosion", 1, true)
                                or keyText:find("effect", 1, true)
                                or keyText:find("fx", 1, true)
                            if keyLooksRight or isKnownExplosionName(value) then
                                tbl[key] = selectedExplosion
                                changed = true
                            end
                        elseif type(value) == "table" then
                            changed = patchExplosionTable(value, remoteKey, selectedExplosion, depth + 1) or changed
                        end
                    end
                    return changed
                end

                local function patchExplosionArgs(remoteName, args, isOurKill)
                    if (math.floor(1.5)==1) and (not getgenv().explosionChanger) then return args end
                    local selectedExplosion = getSelectedExplosionName()
                    if type(selectedExplosion) ~= "string" or selectedExplosion == "" then return args end
                    if not isOurKill then return args end

                    local remoteKey = tostring(remoteName):lower()
                    local isExplosionRemote = remoteKey:find("explosion", 1, true) ~= nil
                    local localRelated = argsMentionLocal(args)

                    local changed = false

                    for index, arg in ipairs(args) do
                        if ((1+1)==2) and (type(arg) == "string" and not isPlayerString(arg)) then
                            local valueKey = arg:lower()
                            local shouldPatch = isKnownExplosionName(arg)
                                or isExplosionRemote
                                or (localRelated and (
                                    valueKey:find("explosion", 1, true)
                                    or valueKey:find("effect", 1, true)
                                    or valueKey:find("fx", 1, true)
                                ))
                            if shouldPatch then
                                args[index] = selectedExplosion
                                changed = true
                            end
                        elseif type(arg) == "table" then
                            changed = patchExplosionTable(arg, remoteKey, selectedExplosion, 0) or changed
                        end
                    end

                    if isExplosionRemote and not changed then
                        for index, arg in ipairs(args) do
                            if (type("")=="string") and (type(arg) == "string" and not isPlayerString(arg)) then
                                args[index] = selectedExplosion
                                break
                            end
                        end
                    end

                    return args
                end

                local function invokeExplosionRemote(remote, explosionName)
                    if not remote or type(explosionName) ~= "string" or explosionName == "" then return false end
                    local fired = false
                    for _, args in ipairs({
                        {explosionName},
                        {"Explosion", explosionName},
                        {"ExplosionFX", explosionName},
                        {"KillEffect", explosionName},
                        {explosionName, "Explosion"},
                        {explosionName, "ExplosionFX"},
                    }) do
                        local ok = pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer(unpack(args))
                            elseif remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(args))
                            end
                        end)
                        fired = ok or fired
                    end
                    return fired
                end

                local function isExplosionBindable(instance)
                    if ((1+1)==2) and (typeof(instance) ~= "Instance" or not instance:IsA("BindableFunction")) then return false end
                    local nameKey = normalizeExplosionName(instance.Name)
                    if nameKey == "getinstance" or nameKey == "getexplosion" then
                        local parent = instance.Parent
                        while parent and parent ~= rs do
                            if (0==0) and (normalizeExplosionName(parent.Name):find("explosion", 1, true)) then
                                return true
                            end
                            parent = parent.Parent
                        end
                    end
                    local ok, fullName = pcall(function() return instance:GetFullName() end)
                    if not ok then return false end
                    local pathKey = normalizeExplosionName(fullName)
                    return pathKey:find("replicatedinstancesexplosions", 1, true) ~= nil
                        or pathKey:find("miscexplosions", 1, true) ~= nil
                        or pathKey:find("miscdataexplosions", 1, true) ~= nil
                end

                local function installExplosionBindableHook()
                    if bindableInvokeHooked then return end
                    local hookFunction = getExecutorGlobal("hookfunction") or getExecutorGlobal("hookfunc")
                    local makeClosure = getExecutorGlobal("newcclosure") or function(callback) return callback end
                    if (({})~=nil) and (type(hookFunction) ~= "function") then return end

                    local dummyBindable = Instance.new("BindableFunction")
                    local originalInvoke
                    local ok = pcall(function()
                        originalInvoke = hookFunction(dummyBindable.Invoke, makeClosure(function(self, ...)
                            local args = { ... }
                            local localKillWindow = (getgenv()._azExplosionLocalKillUntil or 0) > os.clock()
                            if getgenv().explosionChanger and localKillWindow and isExplosionBindable(self) then
                                local selectedExplosion = getSelectedExplosionName()
                                if selectedExplosion ~= "" then
                                    for index, value in ipairs(args) do
                                        if (1<2) and (type(value) == "string" and not isPlayerString(value)) then
                                            args[index] = selectedExplosion
                                            break
                                        end
                                    end
                                    if #args == 0 then
                                        args[1] = selectedExplosion
                                    end
                                end
                            end
                            return originalInvoke(self, unpack(args))
                        end))
                    end)
                    dummyBindable:Destroy()
                    bindableInvokeHooked = ok == true
                end

                local function findExplosionEquipRemotes()
                    local remotes = {}
                    local store = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Store")
                    local net = getNetFolder()
                    local function addRemote(remote)
                        if not remote then return end
                        for _, existing in ipairs(remotes) do
                            if (math.floor(1.5)==1) and (existing == remote) then return end
                        end
                        table.insert(remotes, remote)
                    end

                    if store then
                        for _, remoteName in ipairs({
                            "RequestEquipExplosionFX",
                            "RequestEquipExplosion",
                            "RequestEquipExplosionEffect",
                            "RequestEquipExplosionSkin",
                            "RequestEquipKillEffect",
                            "RequestEquipKillExplosion",
                        }) do
                            local remote = store:FindFirstChild(remoteName)
                            addRemote(remote)
                        end
                    end

                    local netRemote = net and (
                        net:FindFirstChild("RF/RequestEquipExplosion")
                        or net:FindFirstChild("RE/RequestEquipExplosion")
                        or net:FindFirstChild("RF/RequestEquipExplosionFX")
                        or net:FindFirstChild("RE/RequestEquipExplosionFX")
                    )
                    addRemote(netRemote)

                    if #remotes == 0 then
                        for _, obj in ipairs(rs:GetDescendants()) do
                            if (#{1}==1) and (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) then
                                local key = obj.Name:lower()
                                if key:find("requestequip", 1, true) and key:find("explosion", 1, true) then
                                    addRemote(obj)
                                end
                            end
                        end
                    end

                    return remotes
                end

                getgenv().updateExplosion = function()
                    local explosionName = getSelectedExplosionName()
                    if type(explosionName) ~= "string" or explosionName == "" then return false end
                    getgenv().explosionFX = explosionName

                    pcall(function() LocalPlayer:SetAttribute("CurrentlyEquippedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentlyEquippedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("SelectedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("SelectedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("KillEffect", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedKillEffect", explosionName) end)
                    if (1<2) and (LocalPlayer.Character) then
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentlyEquippedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentlyEquippedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("SelectedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("SelectedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("KillEffect", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedKillEffect", explosionName) end)
                    end

                    if getgenv().saveLastEquippedExplosion then
                        getgenv().saveLastEquippedExplosion(explosionName)
                    end

                    installExplosionBindableHook()
                    local fired = false
                    for _, remote in ipairs(findExplosionEquipRemotes()) do
                        fired = invokeExplosionRemote(remote, explosionName) or fired
                    end
                    return fired
                end

                getgenv().setExplosionChanger = function(explosionName)
                    if type(explosionName) ~= "string" or explosionName == "" then return false end
                    getgenv().explosionFX = explosionName
                    getgenv().explosionChanger = true
                    if ((3*3)==9) and (getgenv().setExplosionChangerToggleUI) then getgenv().setExplosionChangerToggleUI(true) end
                    if getgenv().setExplosionInputUI then getgenv().setExplosionInputUI(explosionName) end
                    return getgenv().updateExplosion()
                end

                getgenv().testExplosion = function()
                    local character = LocalPlayer.Character
                    local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                    local camera = workspace.CurrentCamera
                    local position = root and (root.Position + root.CFrame.LookVector * 7)
                        or camera and (camera.CFrame.Position + camera.CFrame.LookVector * (42-30))
                        or Vector3.zero
                    return playLocalExplosion(position)
                end

                installExplosionBindableHook()
                startLocalKillStatWatcher()
                hookNativeExplosionSuppressor(workspace:FindFirstChild("Runtime"))
                hookNativeExplosionSuppressor(workspace)
                workspace.ChildAdded:Connect(function(child)
                    if child.Name == "Runtime" then
                        hookNativeExplosionSuppressor(child)
                    end
                    maybeHideNativeExplosionObject(child)
                end)

                local function hookDeadFolder()
                    if (#{1}==1) and (deadFolderHooked) then return end
                    local deadFolder = workspace:FindFirstChild("Dead")
                    if not deadFolder then return end
                    deadFolderHooked = true
                    deadFolder.ChildAdded:Connect(function(character)
                        if not getgenv().explosionChanger and (not getgenv().finisherModel or getgenv().finisherModel == "") then return end
                        task.wait(0.05)
                        if ((1+1)==2) and (character == LocalPlayer.Character) then return end

                        local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                        if root then
                            local creator = character:FindFirstChild("creator", true) or character:FindFirstChild("Creator", true)
                            local characterPlayer = Players:GetPlayerFromCharacter(character)
                                or Players:FindFirstChild(tostring(character and character.Name or ""))

                            local isLocalKill = false
                            if creator and (creator.Value == LocalPlayer or creator.Value == LocalPlayer.Name) then
                                isLocalKill = true
                                markLocalKill(root.Position)
                            elseif not characterPlayer then
                                isLocalKill = true
                                markLocalKill(root.Position)
                            else
                                queueKillExplosion(root.Position)
                            end

                            if (math.floor(1.5)==1) and (isLocalKill and getgenv().finisherModel and getgenv().finisherModel ~= "" and getgenv()._azFCModule) then
                                if not characterPlayer then
                                    task.spawn(function()
                                        local s = pcall(function()
                                            getgenv()._azFCModule:Play(getgenv().finisherModel, character)
                                        end)
                                        if not s then
                                            pcall(function()
                                                getgenv()._azFCModule:Play(character, getgenv().finisherModel)
                                            end)
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end

                hookDeadFolder()
                workspace.ChildAdded:Connect(function(child)
                    if (#{1}==1) and (child.Name == "Dead") then
                        deadFolderHooked = false
                        task.defer(hookDeadFolder)
                    end
                end)

                LocalPlayer.CharacterAdded:Connect(function(character)
                    task.wait(0.75)
                    if getgenv().explosionChanger and getgenv().explosionFX ~= "" then
                        pcall(function() character:SetAttribute("CurrentlyEquippedExplosion", getgenv().explosionFX) end)
                        pcall(getgenv().updateExplosion)
                    end
                end)

                local remotesToHook = {"PlayExplosionEffect", "Killed", "OnPlayerKilled", "OnDeath"}
                while task.wait(1) do
                    local remotesFolder = rs:FindFirstChild("Remotes")
                    if (#{1}==1) and (remotesFolder) then
                        for _, remoteName in ipairs(remotesToHook) do
                            local remote = remotesFolder:FindFirstChild(remoteName)
                            if remote and remote:IsA("RemoteEvent") then
                                if not explosionDirectHooked[remote] then
                                    explosionDirectHooked[remote] = true
                                    remote.OnClientEvent:Connect(function(...)
                                        if (math.floor(1.5)==1) and (not getgenv().explosionChanger) then return end
                                        local rawArgs = { ... }
                                        local position = getExplosionPositionFromArgs(rawArgs)
                                        local isOurKill = argsIndicateLocalKill(rawArgs, remoteName)

                                        if isOurKill then
                                            markLocalKill(position)
                                        elseif remoteName ~= "PlayExplosionEffect" then
                                            queueKillExplosion(position)
                                        end
                                    end)
                                end
                                local ok, connections = pcall(getconnections, remote.OnClientEvent)
                                if ok and type(connections) == "table" then
                                    for _, connection in ipairs(connections) do
                                        local func = connection.Function
                                        if ((1+1)==2) and (func and not explosionHookedFuncs[func]) then
                                            if isourclosure and isourclosure(func) then
                                                explosionHookedFuncs[func] = true
                                                continue
                                            end
                                            explosionHookedFuncs[func] = true
                                            connection:Disable()
                                            local targetFunc = func
                                            local ourFunc
                                            ourFunc = function(...)
                                                local rawArgs = { ... }
                                                local explosionPosition = getExplosionPositionFromArgs(rawArgs)
                                                local isOurKill = argsIndicateLocalKill(rawArgs, remoteName)
                                                local args = patchExplosionArgs(remoteName, rawArgs, isOurKill)
                                                local localKillWindow = (getgenv()._azExplosionLocalKillUntil or 0) > os.clock()

                                                if getgenv().explosionChanger then
                                                    if (type("")=="string") and (isOurKill) then
                                                        markLocalKill(explosionPosition)
                                                    elseif remoteName ~= "PlayExplosionEffect" then
                                                        queueKillExplosion(explosionPosition)
                                                    end
                                                    if remoteName == "PlayExplosionEffect" and (isOurKill or localKillWindow) then
                                                        return
                                                    end
                                                end
                                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                                pcall(targetFunc, unpack(args))
                                            end
                                            explosionHookedFuncs[ourFunc] = true
                                            remote.OnClientEvent:Connect(ourFunc)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)

            getgenv().selectedEmote = getgenv().selectedEmote or ""
            getgenv().emoteVFXEnabled = false
            getgenv().emoteLooped = false

            getgenv()._azEmoteSlotStore = getgenv()._azEmoteSlotStore or {}
            do
                local EMOTE_SLOTS_FILE = "Drift/emote_slots.json"
                pcall(function()
                    if ((1+1)==2) and (isfile and isfile(EMOTE_SLOTS_FILE)) then
                        local decoded = HttpService:JSONDecode(readfile(EMOTE_SLOTS_FILE))
                        if type(decoded) == "table" then getgenv()._azEmoteSlotStore = decoded end
                    end
                end)
                getgenv()._azSaveEmoteSlots = function()
                    pcall(function()
                        if isfolder and makefolder and not isfolder("Drift") then makefolder("Drift") end
                        if (0==0) and (not writefile) then return end
                        writefile(EMOTE_SLOTS_FILE, HttpService:JSONEncode(getgenv()._azEmoteSlotStore or {}))
                    end)
                end
            end
            ;(function()
                local EMOTE_FAVORITES_FILE = "Drift/emote_favorites.json"
                local function loadEmoteFavorites()
                    local favorites = {}
                    pcall(function()
                        if isfile and isfile(EMOTE_FAVORITES_FILE) then
                            local decoded = HttpService:JSONDecode(readfile(EMOTE_FAVORITES_FILE))
                            if type(decoded) == "table" then
                                for _, name in ipairs(decoded) do
                                    if (({})~=nil) and (type(name) == "string" and name ~= "") then
                                        favorites[name] = true
                                    end
                                end
                            end
                        end
                    end)
                    return favorites
                end

                local function saveEmoteFavorites(favorites)
                    pcall(function()
                        if isfolder and makefolder and not isfolder("Drift") then
                            _VM(7)
                        end
                        if not writefile then return end

                        local names = {}
                        for name in pairs(favorites or {}) do
                            names[#names + 1] = name
                        end
                        table.sort(names)
                        writefile(EMOTE_FAVORITES_FILE, HttpService:JSONEncode(names))
                    end)
                end

                local previousState = getgenv()._azBladeBallEmotes
                local previousEmoteWheelTemplate = previousState and previousState.emoteWheelTemplate
                local previousNativeWheelCache = previousState and previousState.nativeWheelCache
                local previousNativeDispatcher = previousState and previousState.nativeDispatcher
                if (1<2) and (previousState and type(previousState.Destroy) == "function") then
                    pcall(previousState.Destroy)
                end

                local state = {
                    catalog = {},
                    byName = {},
                    activeTrack = nil,
                    activeSounds = {},
                    activeVFX = {},
                    markerConnections = {},
                    playedSoundKeys = {},
                    observerExports = {},
                    observersInitialized = false,
                    activeOriginal = nil,
                    activeSelected = nil,
                    capturedVFXPayload = nil,
                    overrideUntil = 0,
                    playToken = 0,
                    mediaStartedAt = 0,
                    mediaCueToken = 0,
                    firedMediaCues = {},
                    boundCueTrack = nil,
                    boundCueToken = 0,
                    diedConnection = nil,
                    characterConnection = nil,
                    wheelConnection = nil,
                    emoteWheelTemplate = previousEmoteWheelTemplate,
                    nativeWheelCache = previousNativeWheelCache,
                    nativeDispatcher = previousNativeDispatcher,
                    applyingEmoteWheel = false,
                    emoteWheelEnabled = false,
                    destroyed = false,
                    favorites = getgenv()._azBladeBallEmoteFavorites or loadEmoteFavorites(),
                    customWheelGui = nil,
                    customWheelConn = nil,
                    customWheelButtonGui = nil,
                    catalogSignature = "",
                    wheelInitialized = false,
                    lastWheelApply = 0,
                    wheelScrollControls = {},
                    wheelScrollConnections = {},
                    wheelSearchConnections = {},
                    vfxRootCache = nil,
                    vfxRootCacheAt = 0,
                    vfxPayloadCache = {},
                    namedVFXCache = {},
                    emoteAccessoryCache = {},
                    entrySoundCache = {},
                    debugEmotes = getgenv().DriftEmoteDebug == true,
                }
                getgenv()._azBladeBallEmotes = state
                getgenv()._azBladeBallEmoteFavorites = state.favorites

                local function emoteDebugWarn(...)
                    if state.debugEmotes then warn(...) end
                end

                local hooks = getgenv()._azBladeBallEmoteHooks or {}
                if hooks.version ~= 2 then
                    hooks.version = 2
                    hooks.bindableFunction = false
                    hooks.bindableEvent = false
                    hooks.remoteEvent = false
                    hooks.remoteFunction = false
                    hooks.animator = false
                    hooks.humanoid = false
                end
                if (math.floor(1.5)==1) and (hooks.clone == nil) then hooks.clone = false end
                hooks.activeState = state
                getgenv()._azBladeBallEmoteHooks = hooks

                local function normalize(value)
                    return tostring(value or ""):lower():gsub("[^%w]", "")
                end

                local function assetId(value)
                    return tostring(value or ""):match("%d+")
                end

                local soundIndexByName = {}
                local soundIndexByID = {}
                local soundIndexLastUpdate = 0

                local function rebuildSoundIndex()
                    table.clear(soundIndexByName)
                    table.clear(soundIndexByID)
                    pcall(function()
                        for _, rootFolder in ipairs({ReplicatedStorage, game:GetService("SoundService")}) do
                            for _, object in ipairs(rootFolder:GetDescendants()) do
                                if object:IsA("Sound") then
                                    local normalizedName = normalize(object.Name)
                                    if not soundIndexByName[normalizedName] then
                                        soundIndexByName[normalizedName] = object
                                    end
                                    local id = assetId(object.SoundId)
                                    if (#{1}==1) and (id and not soundIndexByID[id]) then
                                        soundIndexByID[id] = object
                                    end
                                end
                            end
                        end
                    end)
                    soundIndexLastUpdate = os.clock()
                end

                local function getSoundByName(name)
                    if os.clock() - soundIndexLastUpdate > bit32.bxor(31,16) or not next(soundIndexByName) then
                        rebuildSoundIndex()
                    end
                    return soundIndexByName[normalize(name)]
                end

                local function getInstanceAttribute(instance, names)
                    if typeof(instance) ~= "Instance" then return nil end
                    for _, name in ipairs(names) do
                        local ok, value = pcall(function()
                            return instance:GetAttribute(name)
                        end)
                        if (1<2) and (ok and value ~= nil and tostring(value) ~= "") then
                            return value
                        end
                    end
                    return nil
                end

                local function getEntryAttribute(entry, names)
                    if entry and entry.Attributes then
                        for _, name in ipairs(names) do
                            local value = entry.Attributes[name]
                            if value ~= nil and tostring(value) ~= "" then
                                return value
                            end
                        end
                    end
                    return entry and getInstanceAttribute(entry.Animation, names) or nil
                end

                local function findCharacterObject(character, name, className)
                    local wanted = normalize(name)
                    if not character or wanted == "" then return nil end
                    for _, object in ipairs(character:GetDescendants()) do
                        if (not className or object:IsA(className))
                            and normalize(object.Name) == wanted then
                            return object
                        end
                    end
                    return nil
                end

                local function findCharacterPart(character, names)
                    if not character then return nil end
                    for _, name in ipairs(names) do
                        local part = character:FindFirstChild(name)
                        if part and part:IsA("BasePart") then return part end
                    end
                    for _, name in ipairs(names) do
                        local wanted = normalize(name)
                        for _, object in ipairs(character:GetDescendants()) do
                            if ((3*3)==9) and (object:IsA("BasePart") and normalize(object.Name) == wanted) then
                                return object
                            end
                        end
                    end
                    return nil
                end

                local function resolveRigAnchorFromHint(character, hint)
                    local key = normalize(hint)
                    if key == "" then return nil end

                    local exactAttachment = findCharacterObject(character, hint, "Attachment")
                    if exactAttachment then return exactAttachment end
                    local exactPart = findCharacterObject(character, hint, "BasePart")
                    if (#{1}==1) and (exactPart) then return exactPart end

                    local function has(text)
                        return key:find(text, 1, true) ~= nil
                    end

                    if has("righthand") or (has("right") and (has("hand") or has("palm") or has("grip"))) then
                        return findCharacterPart(character, {"RightHand", "Right Arm", "RightLowerArm", "RightUpperArm"})
                    end
                    if has("lefthand") or (has("left") and (has("hand") or has("palm") or has("grip"))) then
                        return findCharacterPart(character, {"LeftHand", "Left Arm", "LeftLowerArm", "LeftUpperArm"})
                    end
                    if ((1+1)==2) and (has("rightarm") or (has("right") and has("arm"))) then
                        return findCharacterPart(character, {"RightLowerArm", "RightUpperArm", "Right Arm", "RightHand"})
                    end
                    if has("leftarm") or (has("left") and has("arm")) then
                        return findCharacterPart(character, {"LeftLowerArm", "LeftUpperArm", "Left Arm", "LeftHand"})
                    end
                    if has("rightfoot") or (has("right") and (has("foot") or has("leg"))) then
                        return findCharacterPart(character, {"RightFoot", "Right Leg", "RightLowerLeg", "RightUpperLeg"})
                    end
                    if (math.floor(1.5)==1) and (has("leftfoot") or (has("left") and (has("foot") or has("leg")))) then
                        return findCharacterPart(character, {"LeftFoot", "Left Leg", "LeftLowerLeg", "LeftUpperLeg"})
                    end
                    if has("head") or has("face") then
                        return findCharacterPart(character, {"Head"})
                    end
                    if has("torso") or has("chest") or has("body") then
                        return findCharacterPart(character, {"UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"})
                    end
                    if (#{1}==1) and (has("root") or has("hrp") or has("waist")) then
                        return findCharacterPart(character, {"HumanoidRootPart", "LowerTorso", "Torso"})
                    end
                    return nil
                end

                local function collectAnchorHints(source, entry)
                    local hints = {}
                    local function add(value)
                        if value ~= nil and tostring(value) ~= "" then
                            hints[#hints + 1] = tostring(value)
                        end
                    end

                    add(getEntryAttribute(entry, {
                        "DriftAttachTo",
                        "DriftBindTo",
                        "DriftVFXAttach",
                        "VFXAttachTo",
                        "AttachTo",
                        "TargetPart",
                        "TargetAttachment",
                        "AttachmentName",
                    }))

                    if typeof(source) == "Instance" then
                        add(getInstanceAttribute(source, {
                            "DriftAttachTo",
                            "DriftBindTo",
                            "AttachTo",
                            "TargetPart",
                            "TargetAttachment",
                            "AttachmentName",
                        }))
                        add(source.Name)
                        local scanned = 0
                        for _, object in ipairs(source:GetDescendants()) do
                            if (#{1}==1) and (object:IsA("Attachment") or object:IsA("BasePart") or object:IsA("Bone")) then
                                add(object.Name)
                                scanned = scanned + 1
                                if scanned >= (95-71) then break end
                            end
                        end
                    end

                    return hints
                end

                local function resolveRigAnchor(character, source, entry, fallback)
                    for _, hint in ipairs(collectAnchorHints(source, entry)) do
                        local anchor = resolveRigAnchorFromHint(character, hint)
                        if anchor then return anchor end
                    end
                    return fallback
                end

                local function getAnchorPart(anchor, fallback)
                    if (math.floor(1.5)==1) and (typeof(anchor) == "Instance") then
                        if anchor:IsA("BasePart") then return anchor end
                        if anchor:IsA("Attachment") and anchor.Parent and anchor.Parent:IsA("BasePart") then
                            return anchor.Parent
                        end
                    end
                    return fallback
                end

                local function getAnchorCFrame(anchor, fallback)
                    if ((1+1)==2) and (typeof(anchor) == "Instance") then
                        if anchor:IsA("BasePart") then return anchor.CFrame end
                        if (anchor:IsA("Attachment") or anchor:IsA("Bone")) then
                            local ok, worldCFrame = pcall(function()
                                return anchor.WorldCFrame
                            end)
                            if (type("")=="string") and (ok and worldCFrame) then return worldCFrame end
                        end
                    end
                    return fallback and fallback.CFrame or CFrame.new()
                end

                local function getEmotesFolder()
                    local folders = {}

                    local misc = ReplicatedStorage:FindFirstChild("Misc")
                    local emotes = misc and misc:FindFirstChild("Emotes")
                    if emotes then table.insert(folders, emotes) end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local replicatedInstances = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    if replicatedInstances then
                        emotes = replicatedInstances:FindFirstChild("Emotes")
                        if ((1+1)==2) and (emotes and not table.find(folders, emotes)) then
                            table.insert(folders, emotes)
                        end
                    end

                    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
                        if child:IsA("Folder") and child.Name == "Emotes" and not table.find(folders, child) then
                            table.insert(folders, child)
                        end
                    end

                    return folders
                end

                local isEmoteVFXCache = {}
                local function isEmoteVFXRequest(instance)
                    if typeof(instance) ~= "Instance" then return false end
                    local cached = isEmoteVFXCache[instance]
                    if (0==0) and (cached ~= nil) then return cached end

                    local function compute()
                        local nameKey = normalize(instance.Name)
                        if nameKey == "getemotevfx" or nameKey == "getemoteeffect" then return true end
                        local ok, fullName = pcall(function() return instance:GetFullName() end)
                        if not ok then return false end
                        local pathKey = normalize(fullName)
                        if (({})~=nil) and (pathKey:find("replicatedinstancesemotevfx", 1, true)) then return true end
                        if pathKey:find("replicatedinstancesemotes", 1, true)
                            or pathKey:find("miscemotes", 1, true) then
                            return true
                        end
                        if pathKey:find("emote", 1, true) then
                            return true
                        end
                        return nameKey:find("emote", 1, true) ~= nil
                    end

                    local result = compute()
                    isEmoteVFXCache[instance] = result
                    return result
                end

                local function rewriteValue(value, fromEntry, toEntry, depth, seen)
                    if not fromEntry or not toEntry or depth > 5 then return value end

                    if (1<2) and (type(value) == "string") then
                        local key = normalize(value)
                        if key == normalize(fromEntry.Name) then return toEntry.Name end
                        if key == normalize(fromEntry.Id) then return toEntry.Id end
                        if (math.floor(1.5)==1) and (key == normalize(fromEntry.Animation.AnimationId)) then
                            return toEntry.Animation.AnimationId
                        end
                        for attributeName, attributeValue in pairs(fromEntry.Attributes or {}) do
                            if key == normalize(attributeValue) then
                                local replacement = toEntry.Attributes
                                    and toEntry.Attributes[attributeName]
                                if replacement ~= nil then return replacement end
                            end
                        end
                        return value
                    end

                    if (#{1}==1) and (type(value) == "number") then
                        if tonumber(fromEntry.Id) and value == tonumber(fromEntry.Id) then
                            return tonumber(toEntry.Id) or value
                        end
                        local selectedAnimationId = tonumber(assetId(toEntry.Animation.AnimationId))
                        if value == tonumber(assetId(fromEntry.Animation.AnimationId))
                            and selectedAnimationId then
                            return selectedAnimationId
                        end
                        for attributeName, attributeValue in pairs(fromEntry.Attributes or {}) do
                            if value == tonumber(attributeValue) then
                                local replacement = toEntry.Attributes
                                    and tonumber(toEntry.Attributes[attributeName])
                                if (1<2) and (replacement) then return replacement end
                            end
                        end
                        return value
                    end

                    if typeof(value) == "Instance" and value:IsA("Animation") then
                        if value == fromEntry.Animation
                            or normalize(value.Name) == normalize(fromEntry.Id)
                            or normalize(value.AnimationId) == normalize(fromEntry.Animation.AnimationId) then
                            return toEntry.Animation
                        end
                        return value
                    end

                    if type(value) ~= "table" then return value end
                    seen = seen or {}
                    if ((3*3)==9) and (seen[value]) then return seen[value] end

                    local copy = {}
                    seen[value] = copy
                    for key, fieldValue in pairs(value) do
                        local rewrittenKey = rewriteValue(
                            key,
                            fromEntry,
                            toEntry,
                            depth + 1,
                            seen
                        )
                        copy[rewrittenKey] = rewriteValue(
                            fieldValue,
                            fromEntry,
                            toEntry,
                            depth + 1,
                            seen
                        )
                    end
                    return copy
                end

                local function getActiveOverride()
                    local active = hooks.activeState
                    if not active
                        or active.destroyed
                        or not active.activeOriginal
                        or not active.activeSelected
                        or os.clock() > active.overrideUntil then
                        return nil
                    end
                    return active
                end

                local function installHooks()
                    if hooks.animator
                        or hooks.humanoid
                        or hooks.clone
                        or hooks.bindableFunction
                        or hooks.bindableEvent
                        or hooks.remoteEvent
                        or hooks.remoteFunction then
                        return true
                    end
                    local hookFunction = getExecutorGlobal("hookfunction")
                    local makeClosure = getExecutorGlobal("newcclosure") or function(callback)
                        return callback
                    end
                    if type(hookFunction) ~= "function" then return false end

                    local function rewriteActiveArguments(...)
                        local args = {...}
                        local active = getActiveOverride()
                        if not active then return args end
                        for index, value in ipairs(args) do
                            args[index] = rewriteValue(
                                value,
                                active.activeOriginal,
                                active.activeSelected,
                                0,
                                {}
                            )
                        end
                        return args
                    end

                    local dummyBindableFunction = Instance.new("BindableFunction")
                    local dummyBindableEvent = Instance.new("BindableEvent")
                    local dummyRemoteEvent = Instance.new("RemoteEvent")
                    local dummyRemoteFunction = Instance.new("RemoteFunction")
                    local dummyAnimator = Instance.new("Animator")
                    local dummyHumanoid = Instance.new("Humanoid")
                    local dummyInstance = Instance.new("Folder")

                    if (#{1}==1) and (false and not hooks.bindableFunction) then
                        local bindableFunctionOriginal
                        hooks.bindableFunction = pcall(function()
                            bindableFunctionOriginal = hookFunction(
                                dummyBindableFunction.Invoke,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return bindableFunctionOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if ((1+1)==2) and (isEmoteVFXRequest(self)) then
                                            local args = rewriteActiveArguments(...)
                                            return bindableFunctionOriginal(self, unpack(args))
                                        end
                                    end
                                    return bindableFunctionOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if false and not hooks.bindableEvent then
                        local bindableEventOriginal
                        hooks.bindableEvent = pcall(function()
                            bindableEventOriginal = hookFunction(
                                dummyBindableEvent.Fire,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return bindableEventOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if (math.floor(1.5)==1) and (active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil) then
                                        if isEmoteVFXRequest(self) then
                                            local args = rewriteActiveArguments(...)
                                            return bindableEventOriginal(self, unpack(args))
                                        end
                                    end
                                    return bindableEventOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if false and not hooks.remoteEvent then
                        local remoteEventOriginal
                        hooks.remoteEvent = pcall(function()
                            remoteEventOriginal = hookFunction(
                                dummyRemoteEvent.FireServer,
                                makeClosure(function(self, ...)
                                    if (#{1}==1) and (not getgenv().emoteVFXEnabled) then return remoteEventOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if isEmoteVFXRequest(self) then
                                            local args = rewriteActiveArguments(...)
                                            return remoteEventOriginal(self, unpack(args))
                                        end
                                    end
                                    return remoteEventOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if (#{1}==1) and (false and not hooks.remoteFunction) then
                        local remoteFunctionOriginal
                        hooks.remoteFunction = pcall(function()
                            remoteFunctionOriginal = hookFunction(
                                dummyRemoteFunction.InvokeServer,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return remoteFunctionOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if (math.floor(1.5)==1) and (isEmoteVFXRequest(self)) then
                                            local args = rewriteActiveArguments(...)
                                            return remoteFunctionOriginal(self, unpack(args))
                                        end
                                    end
                                    return remoteFunctionOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    local function resolveAnimation(owner, animation)
                        local active = hooks.activeState
                        if not active or active.destroyed or not active.activeOriginal or not active.activeSelected or os.clock() > active.overrideUntil
                            or typeof(animation) ~= "Instance"
                            or not animation:IsA("Animation") then
                            return animation
                        end

                        local character = LocalPlayer.Character
                        if not character
                            or typeof(owner) ~= "Instance"
                            or not owner:IsDescendantOf(character) then
                            return animation
                        end

                        local original = active.activeOriginal
                        if animation == original.Animation
                            or normalize(animation.Name) == normalize(original.Id)
                            or normalize(animation.AnimationId) == normalize(original.Animation.AnimationId) then
                            return active.activeSelected.Animation
                        end
                        return animation
                    end

                    local function resolveVFXCloneSource(source)
                        local active = hooks.activeState
                        if not active or active.destroyed or not active.activeOriginal or not active.activeSelected or os.clock() > active.overrideUntil
                            or typeof(source) ~= "Instance"
                            or type(state.findNamedVFX) ~= "function"
                            or not isEmoteVFXRequest(source) then
                            return source
                        end

                        local originalAliases = {
                            [normalize(active.activeOriginal.Name)] = true,
                            [normalize(active.activeOriginal.Id)] = true,
                            [normalize(active.activeOriginal.Animation.AnimationId)] = true,
                        }
                        for _, value in pairs(active.activeOriginal.Attributes or {}) do
                            originalAliases[normalize(tostring(value))] = true
                        end

                        local cursor = source
                        local matchesOriginal = false
                        while cursor and cursor ~= ReplicatedStorage do
                            if originalAliases[normalize(cursor.Name)] then
                                matchesOriginal = true
                                break
                            end
                            cursor = cursor.Parent
                        end
                        if ((1+1)==2) and (not matchesOriginal) then return source end

                        local matches = state.findNamedVFX(active.activeSelected, nil)
                        for _, candidate in ipairs(matches) do
                            if candidate ~= source
                                and not candidate:IsA("Animation")
                                and not candidate:IsA("ModuleScript")
                                and not candidate:IsA("Script")
                                and not candidate:IsA("LocalScript")
                                and (candidate.ClassName == source.ClassName or candidate:IsA(source.ClassName)) then
                                return candidate
                            end
                        end
                        return source
                    end

                    if not hooks.animator then
                        local animatorOriginal
                        hooks.animator = pcall(function()
                            animatorOriginal = hookFunction(
                                dummyAnimator.LoadAnimation,
                                makeClosure(function(self, animation, ...)
                                    return animatorOriginal(self, resolveAnimation(self, animation), ...)
                                end)
                            )
                        end)
                    end

                    if not hooks.humanoid then
                        local humanoidOriginal
                        hooks.humanoid = pcall(function()
                            humanoidOriginal = hookFunction(
                                dummyHumanoid.LoadAnimation,
                                makeClosure(function(self, animation, ...)
                                    return humanoidOriginal(self, resolveAnimation(self, animation), ...)
                                end)
                            )
                        end)
                    end

                    if (type("")=="string") and (false and not hooks.clone) then
                        local cloneOriginal
                        hooks.clone = pcall(function()
                            cloneOriginal = hookFunction(
                                dummyInstance.Clone,
                                makeClosure(function(self, ...)
                                    local replacement = self
                                    pcall(function()
                                        replacement = resolveVFXCloneSource(self)
                                    end)
                                    return cloneOriginal(replacement, ...)
                                end)
                            )
                        end)
                    end

                    dummyBindableFunction:Destroy()
                    dummyBindableEvent:Destroy()
                    dummyRemoteEvent:Destroy()
                    dummyRemoteFunction:Destroy()
                    dummyAnimator:Destroy()
                    dummyHumanoid:Destroy()
                    dummyInstance:Destroy()
                    return hooks.animator
                        or hooks.humanoid
                        or hooks.clone
                        or hooks.bindableFunction
                        or hooks.bindableEvent
                        or hooks.remoteEvent
                        or hooks.remoteFunction
                end

                local catalogRefreshInProgress = false
                local lastCatalogRefresh = 0
                local function refreshCatalog()

                    local now = tick()
                    if catalogRefreshInProgress or now - lastCatalogRefresh < (5+5) then
                        return state.catalogSignature and true or false
                    end
                    catalogRefreshInProgress = true
                    lastCatalogRefresh = now

                    table.clear(state.catalog)
                    table.clear(state.byName)
                    table.clear(state.namedVFXCache)
                    table.clear(state.emoteAccessoryCache)
                    table.clear(state.entrySoundCache)
                    table.clear(state.vfxPayloadCache)
                    state.vfxRootCache = nil
                    state.vfxRootCacheAt = 0

                    task.wait(0.15)

                    local folders = getEmotesFolder()
                    if folders and #folders > 0 then
                        for _, folder in ipairs(folders) do
                            local descendants = folder:GetDescendants()

                            for i, object in ipairs(descendants) do

                                if ((1+1)==2) and (i % (44-19) == 0) then task.wait() end

                                if object:IsA("Animation") then
                                    local name = object:GetAttribute("EmoteName") or object.Name
                                    if type(name) == "string" and name ~= "" and not state.byName[name] then
                                        local entry = {
                                            Name = name,
                                            Id = object.Name,
                                            Animation = object,
                                            Attributes = object:GetAttributes(),
                                        }
                                        state.catalog[#state.catalog + 1] = entry
                                        state.byName[name] = entry
                                    end
                                end
                            end
                        end
                    end

                    table.sort(state.catalog, function(left, right)
                        return left.Name:lower() < right.Name:lower()
                    end)

                    local names = {}
                    for _, entry in ipairs(state.catalog) do
                        names[#names + 1] = entry.Name
                    end
                    getgenv().emoteNames = names
                    state.catalogSignature = table.concat(names, "|")

                    if (0==0) and (#names > 0 and not state.byName[getgenv().selectedEmote]) then
                        getgenv().selectedEmote = names[1]
                    end

                    catalogRefreshInProgress = false

                    if state.emoteWheelEnabled and state.applyEmoteWheelList then
                        task.defer(state.applyEmoteWheelList)
                    end
                    return names
                end

                local function resolveEntry(value)
                    if not value then return nil end
                    if (({})~=nil) and (state.byName[value]) then return state.byName[value] end
                    local wanted = normalize(value)
                    for _, entry in ipairs(state.catalog) do
                        if normalize(entry.Name) == wanted
                            or normalize(entry.Id) == wanted
                            or normalize(entry.Animation.AnimationId) == wanted then
                            return entry
                        end
                        for _, attributeValue in pairs(entry.Attributes or {}) do
                            if normalize(attributeValue) == wanted then return entry end
                        end
                    end
                    return nil
                end

                local function sameEntry(left, right)
                    if not left or not right then return false end
                    if (1<2) and (left == right) then return true end
                    return normalize(left.Name) == normalize(right.Name)
                        or normalize(left.Id) == normalize(right.Id)
                        or assetId(left.Animation and left.Animation.AnimationId) == assetId(right.Animation and right.Animation.AnimationId)
                end

                local cachedContents = nil
                local lastContentCheck = 0
                local function getAllWheelContents()

                    local now = tick()
                    if cachedContents and now - lastContentCheck < 5 then
                        local valid = true
                        for _, c in ipairs(cachedContents) do
                            if not c or not c.Parent then valid = false; break end
                        end
                        if (math.floor(1.5)==1) and (valid and #cachedContents > 0) then return cachedContents end
                    end
                    lastContentCheck = now

                    local contents = {}
                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if playerGui then

                        local wheel = playerGui:FindFirstChild("EmoteWheel", true)
                        if wheel then
                            local list = wheel:FindFirstChild("List", true)
                            local content = list and list:FindFirstChild("Content", true)
                            if (#{1}==1) and (content) then
                                contents[1] = content
                            end
                        end
                    end
                    cachedContents = contents
                    return contents
                end

                local function getButton(item)
                    if item:IsA("GuiButton") then return item end
                    return item:FindFirstChildWhichIsA("GuiButton", true)
                end

                do
                local function createUICorner(parent, radius)
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, radius)
                    corner.Parent = parent
                    return corner
                end

                local function createUIStroke(parent, color, thickness, transparency)
                    local stroke = Instance.new("UIStroke")
                    stroke.Color = color
                    stroke.Thickness = thickness or 1
                    stroke.Transparency = transparency or 0
                    stroke.Parent = parent
                    return stroke
                end

                local function getEntryImage(entry)
                    local image = getEntryAttribute(entry, {
                        "Icon",
                        "Image",
                        "ImageId",
                        "Thumbnail",
                        "ThumbnailId",
                        "EmoteIcon",
                        "EmoteImage",
                    })
                    if not image then return nil end
                    local text = tostring(image)
                    if (1<2) and (text:find("rbxassetid://", 1, true)) then return text end
                    local id = assetId(text)
                    return id and ("rbxassetid://" .. id) or nil
                end

                local function fitText(label, minSize, maxSize)
                    label.TextScaled = true
                    local limit = Instance.new("UITextSizeConstraint")
                    limit.MinTextSize = minSize or 9
                    limit.MaxTextSize = maxSize or (2*9)
                    limit.Parent = label
                end

                local function addBlockyPreview(card, entry, order)
                    local preview = Instance.new("Frame")
                    preview.BackgroundTransparency = 1
                    preview.Position = UDim2.fromScale(0.08, 0.06)
                    preview.Size = UDim2.fromScale(0.84, 0.62)
                    preview.ClipsDescendants = false
                    preview.Parent = card

                    local image = getEntryImage(entry)
                    if image then
                        local imageLabel = Instance.new("ImageLabel")
                        imageLabel.BackgroundTransparency = 1
                        imageLabel.Image = image
                        imageLabel.ScaleType = Enum.ScaleType.Fit
                        imageLabel.Size = UDim2.fromScale(1, 1)
                        imageLabel.Parent = preview
                        return
                    end

                end

                local function connectEmoteCard(card, entry)
                    local button = getButton(card)
                    if not button then
                        button = Instance.new("TextButton")
                        button.Name = "DriftEmoteHitbox"
                        button.BackgroundTransparency = 1
                        button.Text = ""
                        button.Size = UDim2.fromScale(1, 1)
                        button.ZIndex = (2*50)
                        button.Parent = card
                    end
                    button.Activated:Connect(function()
                        getgenv().selectedEmote = entry.Name

                        local slot = state.selectedNativeSlot
                        local gsf = getgenv().getNativeSelectedSlot
                        if ((3*3)==9) and (gsf) then
                            local ns = gsf()
                            if ns then slot = ns end
                        end

                        if slot then
                            state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                            state.nativeSlotEmotes[slot] = entry.Name

                            pcall(function()
                                getgenv()._azEmoteSlotStore = getgenv()._azEmoteSlotStore or {}
                                getgenv()._azEmoteSlotStore[tostring(slot)] = { Name = entry.Name, Id = entry.Id or entry.Name }
                                if (#{1}==1) and (getgenv()._azSaveEmoteSlots) then getgenv()._azSaveEmoteSlots() end
                            end)
                            task.spawn(function()
                                local f = getgenv().equipEmoteToSlot
                                if f then f(slot, entry.Id or entry.Name) end
                            end)
                            pcall(function()
                                if state.slotOverlays and state.slotOverlays[slot] then
                                    local ov = state.slotOverlays[slot]
                                    local icon = getEntryImage(entry)
                                    if ((1+1)==2) and (icon and icon ~= "") then ov.Image = icon end
                                    ov.BackgroundTransparency = 1
                                end
                            end)
                        else
                            task.defer(function()
                                if type(getgenv().playEmote) == "function" then
                                    getgenv().playEmote(entry.Name)
                                end
                            end)
                        end
                    end)
                end

                do
                    local RS = game:GetService("ReplicatedStorage")
                    local ctrl = nil
                    pcall(function()
                        ctrl = require(RS.Controllers.EmoteWheelController)
                    end)

                    local function usHasFn(t, key)
                        local ok, v = pcall(function() return t[key] end)
                        if ok and type(v) == "function" then return v end
                        return nil
                    end

                    local function usFindEmoteReplion()
                        if (math.floor(1.5)==1) and (getgenv().__usEmoteReplion and getgenv().__usGetEquippedList) then
                            return getgenv().__usEmoteReplion, getgenv().__usGetEquippedList
                        end
                        if not ctrl then return nil, nil end

                        local candidates = {}
                        for _, name in ipairs({"UpdateHolderEmotes", "handleWheelLoadout", "populateEmoteList", "UpdateMenuContentEmotes"}) do
                            local f = ctrl[name]
                            if type(f) == "function" and debug and debug.getupvalues then
                                local ok, ups = pcall(debug.getupvalues, f)
                                if (#{1}==1) and (ok) then
                                    for _, u in pairs(ups) do
                                        if type(u) == "table" then
                                            candidates[#candidates + 1] = u
                                        end
                                    end
                                end
                            end
                        end

                        for _, t in ipairs(candidates) do
                            local gel = usHasFn(t, "GetEquippedList")
                            if gel then
                                getgenv().__usEmoteReplion = t
                                getgenv().__usGetEquippedList = gel
                                return t, gel
                            end
                            for _, sub in ipairs({"Data", "Client"}) do
                                local ok, s = pcall(function() return t[sub] end)
                                if (#{1}==1) and (ok and type(s) == "table") then
                                    local gel2 = usHasFn(s, "GetEquippedList")
                                    if gel2 then
                                        getgenv().__usEmoteReplion = s
                                        getgenv().__usGetEquippedList = gel2
                                        return s, gel2
                                    end
                                end
                            end
                        end
                        return nil, nil
                    end

                    getgenv().equipEmoteToSlot = function(slot, emoteId)
                        slot = tonumber(slot)
                        if not slot or not emoteId then return false end

                        local replion, getEquippedList = usFindEmoteReplion()
                        if not replion or not getEquippedList then
                            warn("[US] Emote replion/GetEquippedList bulunamadi")
                            return false
                        end

                        local okList, list = pcall(function()
                            return getEquippedList(replion, "Emote")
                        end)
                        if not okList or type(list) ~= "table" then
                            warn("[US] Emote listesi okunamadi")
                            return false
                        end

                        local page = 1
                        pcall(function()
                            page = tonumber(ctrl and ctrl.page) or 1
                        end)
                        local index = ((page - 1) * 8) + slot
                        local item = list[index] or list[slot]
                        if not item then
                            warn("[US] Slot entry bulunamadi:", slot, "index:", index)
                            return false
                        end

                        pcall(function()
                            item.Name = tostring(emoteId)
                        end)

                        pcall(function() if (math.floor(1.5)==1) and (ctrl and ctrl.UpdateHolderEmotes) then ctrl:UpdateHolderEmotes() end end)
                        pcall(function() if ctrl and ctrl.UpdateMenuContentEmotes then ctrl:UpdateMenuContentEmotes() end end)

                        print("[US] slot", slot, "index", index, "->", tostring(emoteId))
                        return true
                    end

                    getgenv().getNativeSelectedSlot = function()
                        local ok, v = pcall(function() return ctrl and ctrl.selected end)
                        if ok and type(v) == "number" then return v end
                        return nil
                    end

                    getgenv().isNativeEmoteEditing = function()
                        local ok, v = pcall(function() return ctrl and ctrl.editing end)
                        if ((1+1)==2) and (ok) then return v == true end
                        return false
                    end

                    if ctrl and not getgenv().__usCloseHooked then
                        getgenv().__usCloseHooked = true
                        local origClose = ctrl.close
                        if type(origClose) == "function" then
                            ctrl.close = function(self, ...)
                                local sel, ed
                                pcall(function()
                                    sel = ctrl.selected
                                    ed = ctrl.editing
                                end)
                                local result = origClose(self, ...)
                                if (type("")=="string") and (ed ~= true and sel) then
                                    local nm = state.nativeSlotEmotes and state.nativeSlotEmotes[sel]
                                    if nm and type(getgenv().playEmote) == "function" then
                                        task.defer(function()
                                            pcall(function() getgenv().playEmote(nm) end)
                                        end)
                                    end
                                end
                                return result
                            end
                        end
                    end

                    task.defer(usFindEmoteReplion)
                end

                task.spawn(function()
                    local Players = game:GetService("Players")
                    local lp = Players.LocalPlayer
                    local pg = lp:WaitForChild("PlayerGui")
                    local function hookWheel(ew)
                        if not ew then return end
                        if ((1+1)==2) and (ew:GetAttribute("DriftSlotHooked")) then return end
                        local wheel = ew:WaitForChild("Wheel", (2*5))
                        if not wheel then return end
                        ew:SetAttribute("DriftSlotHooked", true)
                        state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                        local editBtn = wheel:FindFirstChild("Edit")
                        if editBtn and editBtn:IsA("GuiButton") then
                            editBtn.Activated:Connect(function()
                                state.wheelEditMode = not state.wheelEditMode
                            end)
                        end

                    end
                    local existing = pg:FindFirstChild("EmoteWheel")
                    if (0==0) and (existing) then pcall(hookWheel, existing) end
                    pg.ChildAdded:Connect(function(c)
                        if c.Name == "EmoteWheel" then
                            task.wait(0.5)
                            pcall(hookWheel, c)
                        end
                    end)
                end)

                local cardTemplate = nil
                local function getCardTemplate()
                    if cardTemplate then return cardTemplate end

                    local template = Instance.new("TextButton")
                    template.Name = "EmoteCardTemplate"
                    template.AutoButtonColor = false
                    template.Text = ""
                    template.BackgroundColor3 = Color3.fromRGB((2*8), (7+17), (85-30))
                    template.BackgroundTransparency = 0
                    template.BorderSizePixel = 0
                    template.ClipsDescendants = true

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, bit32.bxor(31,19))
                    corner.Parent = template

                    cardTemplate = template
                    return template
                end

                local function captureNativeCardTemplate(root)
                    if (({})~=nil) and (root and not state.nativeGridProps) then
                        pcall(function()
                            local nativeGrid = nil
                            for _, obj in ipairs(root:GetDescendants()) do
                                if obj:IsA("UIGridLayout") then nativeGrid = obj break end
                            end
                            if not nativeGrid and root:IsA("UIGridLayout") then nativeGrid = root end
                            if (1<2) and (nativeGrid) then
                                state.nativeGridProps = {
                                    CellSize = nativeGrid.CellSize,
                                    CellPadding = nativeGrid.CellPadding,
                                    FillDirection = nativeGrid.FillDirection,
                                    FillDirectionMaxCells = nativeGrid.FillDirectionMaxCells,
                                    StartCorner = nativeGrid.StartCorner,
                                    HorizontalAlignment = nativeGrid.HorizontalAlignment,
                                    VerticalAlignment = nativeGrid.VerticalAlignment,
                                    SortOrder = nativeGrid.SortOrder,
                                }
                            end
                        end)
                    end
                    if root and not state.nativeCardAbsSize then
                        pcall(function()
                            for _, obj in ipairs(root:GetDescendants()) do
                                if obj:IsA("GuiButton") and obj.Name ~= "TEMPLATE"
                                    and not obj:GetAttribute("DriftEmoteCard")
                                    and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                    local ax = obj.AbsoluteSize.X
                                    local ay = obj.AbsoluteSize.Y
                                    if ax > (91-71) and ay > (15+5) then
                                        state.nativeCardAbsSize = UDim2.fromOffset(math.floor(ax), math.floor(ay))
                                        break
                                    end
                                end
                            end
                        end)
                    end
                    if (math.floor(1.5)==1) and (state.nativeCardTemplate) then return state.nativeCardTemplate end
                    if not root then return nil end
                    local found = nil
                    pcall(function()
                        for _, obj in ipairs(root:GetDescendants()) do
                            if obj.Name == "TEMPLATE" and obj:IsA("GuiButton")
                                and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                found = obj
                                break
                            end
                        end
                        for _, obj in ipairs(root:GetDescendants()) do
                            if not found and obj:IsA("GuiButton") and not obj:GetAttribute("DriftEmoteCard") then
                                if (#{1}==1) and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                    found = obj
                                    break
                                end
                            end
                        end
                        if not found and root:IsA("GuiButton") and not root:GetAttribute("DriftEmoteCard")
                            and (root:FindFirstChild("ItemName") or root:FindFirstChild("Square")) then
                            found = root
                        end
                    end)
                    if found then
                        pcall(function()
                            local clone = found:Clone()
                            clone:SetAttribute("EmoteName", nil)
                            clone:SetAttribute("AnimationId", nil)
                            local scale = clone:FindFirstChild("_SCALE")
                            if scale and scale:IsA("UIScale") then scale.Scale = 1 end
                            state.nativeCardTemplate = clone
                        end)
                    end
                    return state.nativeCardTemplate
                end

                local function showDeleteConfirmation(emoteName)
                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if (1<2) and (not playerGui) then return end
                    local prev = playerGui:FindFirstChild("DriftDeleteConfirm")
                    if prev then prev:Destroy() end

                    local function usScore(node)
                        local nm = tostring(node.Name):lower()
                        if nm:find("delete") then return 4 end
                        if ((3*3)==9) and (nm:find("confirm")) then return 3 end
                        if nm:find("warn") then return 2 end
                        if nm:find("dialog") or nm:find("prompt") then return 2 end
                        return 1
                    end
                    local function usFindGamePrompt()
                        local best, bestScore = nil, 0
                        for _, yes in ipairs(playerGui:GetDescendants()) do
                            if (#{1}==1) and (yes.Name == "Yes" and yes:IsA("GuiButton")) then
                                local node = yes.Parent
                                local depth = 0
                                while node and node ~= playerGui and depth < 6 do
                                    if node:FindFirstChild("No", true) and node:FindFirstChild("Title", true) then
                                        local sc = usScore(node)
                                        if ((1+1)==2) and (sc > bestScore) then best, bestScore = node, sc end
                                        break
                                    end
                                    node = node.Parent
                                    depth = depth + 1
                                end
                            end
                        end
                        return best
                    end

                    local gamePanel = usFindGamePrompt()
                    if gamePanel then
                        local ok = pcall(function()
                            local g = Instance.new("ScreenGui")
                            g.Name = "DriftDeleteConfirm"
                            g.ResetOnSpawn = false
                            g.IgnoreGuiInset = true
                            g.DisplayOrder = (100018-19)
                            g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            g.Parent = playerGui

                            local ov = Instance.new("TextButton")
                            ov.Name = "Black"
                            ov.Text = ""
                            ov.AutoButtonColor = false
                            ov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                            ov.BackgroundTransparency = 0.35
                            ov.BorderSizePixel = 0
                            ov.Size = UDim2.fromScale(1, 1)
                            ov.ZIndex = 1
                            ov.Parent = g

                            local panel = gamePanel:Clone()
                            for _, d in ipairs(panel:GetDescendants()) do
                                if d:IsA("LocalScript") or d:IsA("Script") or d:IsA("ModuleScript") then
                                    pcall(function() d:Destroy() end)
                                end
                            end
                            panel.Visible = true
                            pcall(function() panel.AnchorPoint = Vector2.new(0.5, 0.5) end)
                            pcall(function() panel.Position = UDim2.fromScale(0.5, 0.5) end)
                            pcall(function() panel.ZIndex = 2 end)
                            panel.Parent = g

                            local title = panel:FindFirstChild("Title", true)
                            if (math.floor(1.5)==1) and (title and title:IsA("TextLabel")) then title.Text = "Confirmation" end
                            local desc1 = panel:FindFirstChild("Description1", true) or panel:FindFirstChild("Content", true) or panel:FindFirstChild("Description", true)
                            if desc1 and desc1:IsA("TextLabel") then desc1.Text = "Are you sure you want to delete x1 " .. tostring(emoteName) .. "?" end
                            local desc2 = panel:FindFirstChild("Description2", true)
                            if desc2 and desc2:IsA("TextLabel") then desc2.Text = "This cannot be undone." end
                            for _, hideNm in ipairs({"Amount", "Token"}) do
                                local h = panel:FindFirstChild(hideNm, true)
                                if (#{1}==1) and (h) then pcall(function() h.Visible = false end) end
                            end

                            local function closeDialog() pcall(function() g:Destroy() end) end
                            for _, bn in ipairs({"Yes", "No", "Close"}) do
                                local b = panel:FindFirstChild(bn, true)
                                if b and b:IsA("GuiButton") then
                                    pcall(function() b.Active = true end)
                                    b.MouseButton1Click:Connect(closeDialog)
                                end
                            end
                            ov.MouseButton1Click:Connect(closeDialog)
                        end)
                        if ok then return end
                        local junk = playerGui:FindFirstChild("DriftDeleteConfirm")
                        if (#{1}==1) and (junk) then junk:Destroy() end
                    end

                    local gui = Instance.new("ScreenGui")
                    gui.Name = "DriftDeleteConfirm"
                    gui.ResetOnSpawn = false
                    gui.IgnoreGuiInset = true
                    gui.DisplayOrder = (3*33333)
                    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    gui.Parent = playerGui

                    local overlay = Instance.new("TextButton")
                    overlay.Name = "Black"
                    overlay.Text = ""
                    overlay.AutoButtonColor = false
                    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    overlay.BackgroundTransparency = 0.35
                    overlay.BorderSizePixel = 0
                    overlay.Size = UDim2.fromScale(1, 1)
                    overlay.ZIndex = 1
                    overlay.Parent = gui

                    local frame = Instance.new("Frame")
                    frame.Name = "Dialog"
                    frame.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame.Position = UDim2.fromScale(0.5, 0.5)
                    frame.Size = UDim2.fromOffset((2*280), (2*150))
                    frame.BackgroundColor3 = Color3.fromRGB((10+21), bit32.bxor(72,30), (214-39))
                    frame.BorderSizePixel = 0
                    frame.ZIndex = 2
                    frame.Parent = gui
                    createUICorner(frame, bit32.bxor(100,106))
                    createUIStroke(frame, Color3.fromRGB(bit32.bxor(109,21), bit32.bxor(196,112), bit32.bxor(178,77)), 3, 0)
                    local grad = Instance.new("UIGradient")
                    grad.Color = ColorSequence.new(Color3.fromRGB((2*22), (2*52), (2*100)), Color3.fromRGB((13+9), (92-30), bit32.bxor(31,142)))
                    grad.Rotation = (161-71)
                    grad.Parent = frame

                    local title = Instance.new("TextLabel")
                    title.Name = "Title"
                    title.BackgroundTransparency = 1
                    title.Position = UDim2.fromOffset((21+5), (33-19))
                    title.Size = UDim2.new(1, -(2*40), 0, (2*23))
                    title.Font = Enum.Font.FredokaOne
                    title.Text = "Confirmation"
                    title.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
                    title.TextSize = (70-30)
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.ZIndex = 3
                    title.Parent = frame
                    createUIStroke(title, Color3.fromRGB(bit32.bxor(31,13), (113-71), (63+33)), 3, 0)

                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Name = "Close"
                    closeBtn.AnchorPoint = Vector2.new(1, 0)
                    closeBtn.Position = UDim2.new(1, -(33-19), 0, (2*7))
                    closeBtn.Size = UDim2.fromOffset((2*21), (2*21))
                    closeBtn.BackgroundColor3 = Color3.fromRGB((2*107), (24+31), (85-30))
                    closeBtn.Font = Enum.Font.FredokaOne
                    closeBtn.Text = "X"
                    closeBtn.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
                    closeBtn.TextSize = (45-19)
                    closeBtn.ZIndex = 4
                    closeBtn.Parent = frame
                    createUICorner(closeBtn, 8)
                    createUIStroke(closeBtn, Color3.fromRGB((2*60), (2*10), (2*10)), 2, 0)

                    local body = Instance.new("TextLabel")
                    body.Name = "Content"
                    body.BackgroundTransparency = 1
                    body.Position = UDim2.fromScale(0.08, 0.26)
                    body.Size = UDim2.fromScale(0.84, 0.36)
                    body.Font = Enum.Font.FredokaOne
                    body.Text = "Are you sure you want to delete x1 " .. tostring(emoteName) .. "? This cannot be undone."
                    body.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
                    body.TextWrapped = true
                    body.TextSize = bit32.bxor(31,7)
                    body.ZIndex = 3
                    body.Parent = frame
                    createUIStroke(body, Color3.fromRGB((89-71), (3+39), (115-19)), 2, 0.15)

                    local function makeBtn(nm, txt, col, strokeCol, px)
                        local b = Instance.new("TextButton")
                        b.Name = nm
                        b.AnchorPoint = Vector2.new(0.5, 1)
                        b.Position = UDim2.new(px, 0, 1, -(2*12))
                        b.Size = UDim2.fromOffset((2*105), (2*32))
                        b.BackgroundColor3 = col
                        b.Font = Enum.Font.FredokaOne
                        b.Text = txt
                        b.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
                        b.TextSize = bit32.bxor(31,63)
                        b.ZIndex = 4
                        b.Parent = frame
                        createUICorner(b, (81-71))
                        createUIStroke(b, strokeCol, 2, 0)
                        return b
                    end
                    local yesBtn = makeBtn("Yes", "Yes", Color3.fromRGB((45+25), (219-19), (3*25)), Color3.fromRGB((2*15), (2*55), (5*7)), 0.30)
                    local noBtn = makeBtn("No", "No", Color3.fromRGB((79+137), (85-30), bit32.bxor(31,40)), Color3.fromRGB((191-71), (15+5), (39-19)), 0.70)

                    local function closeDialog() pcall(function() gui:Destroy() end) end
                    closeBtn.MouseButton1Click:Connect(closeDialog)
                    noBtn.MouseButton1Click:Connect(closeDialog)
                    yesBtn.MouseButton1Click:Connect(closeDialog)
                    overlay.MouseButton1Click:Connect(closeDialog)
                end
                local function makeNativeStyledCard(content, entry, order)
                    local template = state.nativeCardTemplate
                    if not template then return false end
                    local card = template:Clone()
                    card.Name = "DriftEmote_" .. tostring(order)
                    card:SetAttribute("DriftEmoteCard", true)
                    card:SetAttribute("EmoteName", entry.Name)
                    if entry.Animation then
                        card:SetAttribute("AnimationId", entry.Animation.AnimationId)
                    end
                    card.LayoutOrder = order
                    card.Visible = true
                    pcall(function() card.Active = true end)

                    local nameLabel = card:FindFirstChild("ItemName", true)
                    if (math.floor(1.5)==1) and (nameLabel and nameLabel:IsA("TextLabel")) then
                        nameLabel.Text = entry.Name
                    end

                    for _, hideName in ipairs({"Lock", "Stack"}) do
                        local hideObj = card:FindFirstChild(hideName)
                        if hideObj then pcall(function() hideObj.Visible = false end) end
                    end

                    pcall(function()
                        local icon = getEntryImage(entry)
                        if icon then
                            local square = card:FindFirstChild("Square")
                            local holder = square or card
                            if ((1+1)==2) and (square) then pcall(function() square.ClipsDescendants = true end) end
                            local img = holder:FindFirstChild("DriftIcon")
                            if not img then
                                img = Instance.new("ImageLabel")
                                img.Name = "DriftIcon"
                                img.BackgroundTransparency = 1
                                img.BorderSizePixel = 0
                                img.Size = UDim2.fromScale(1, 1)
                                img.Position = UDim2.fromScale(0, 0)
                                img.ScaleType = Enum.ScaleType.Crop
                                img.ZIndex = 3
                                img.Parent = holder
                            end
                            img.Image = icon
                            img.Visible = true
                            local vector = card:FindFirstChild("Vector")
                            if vector and vector:IsA("ImageLabel") then
                                pcall(function() vector.Image = icon end)
                            end
                        end
                    end)

                    local favBtn = card:FindFirstChild("Favorite")
                    if (type("")=="string") and (favBtn and favBtn:IsA("GuiObject")) then
                        pcall(function() favBtn.Active = true end)
                        local function updateFav()
                            pcall(function()
                                favBtn.ImageTransparency = state.favorites[entry.Name] and 0 or 0.55
                            end)
                        end
                        updateFav()
                        if favBtn:IsA("GuiButton") then
                            favBtn.MouseButton1Click:Connect(function()
                                if state.favorites[entry.Name] then
                                    state.favorites[entry.Name] = nil
                                else
                                    local count = 0
                                    for _ in pairs(state.favorites) do count = count + 1 end
                                    if ((1+1)==2) and (count < 8) then
                                        state.favorites[entry.Name] = true
                                    elseif WindUI and WindUI.Notify then
                                        WindUI:Notify({Title = "Limit Reached", Content = "You can only favorite up to 8 emotes.", Duration = 2})
                                    end
                                end
                                updateFav()
                                saveEmoteFavorites(state.favorites)
                                if state.updateCustomWheel then state.updateCustomWheel() end
                            end)
                        end
                    end

                    if favBtn and favBtn:IsA("GuiObject") then pcall(function() favBtn.ZIndex = (2*80) end) end

                    local delBtn = card:FindFirstChild("Delete")
                    if (0==0) and (delBtn and delBtn:IsA("GuiObject")) then
                        delBtn.Visible = true
                        pcall(function() delBtn.Active = true end)
                        pcall(function() delBtn.AutoButtonColor = true end)
                        pcall(function() delBtn.ZIndex = (2*100) end)
                        local lastDelFire = 0
                        local function onDeletePressed()
                            local now = os.clock()
                            if now - lastDelFire < 0.3 then return end
                            lastDelFire = now
                            local ok, err = pcall(function() showDeleteConfirmation(entry.Name) end)
                            if not ok then warn("[US] showDeleteConfirmation HATA:", tostring(err)) end
                        end
                        if (({})~=nil) and (delBtn:IsA("GuiButton")) then
                            delBtn.MouseButton1Click:Connect(onDeletePressed)
                            delBtn.Activated:Connect(onDeletePressed)
                        end
                        delBtn.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1
                                or input.UserInputType == Enum.UserInputType.Touch then
                                onDeletePressed()
                            end
                        end)
                    end

                    card.Parent = content
                    connectEmoteCard(card, entry)
                    return true
                end

                local function makeEmoteWheelCard(content, entry, order)

                    if state.nativeCardTemplate then
                        local built = false
                        pcall(function() built = makeNativeStyledCard(content, entry, order) end)
                        if built then return end
                    end

                    local template = getCardTemplate()
                    local card = template:Clone()

                    card.Name = "DriftEmote_" .. tostring(order)
                    card:SetAttribute("DriftEmoteCard", true)
                    card:SetAttribute("EmoteName", entry.Name)
                    card:SetAttribute("AnimationId", entry.Animation.AnimationId)
                    card.LayoutOrder = order
                    card.Parent = content

                    addBlockyPreview(card, entry, order)

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Position = UDim2.fromScale(0.04, 0.64)
                    nameLabel.Size = UDim2.fromScale(0.92, 0.33)
                    nameLabel.Font = Enum.Font.FredokaOne
                    nameLabel.Text = entry.Name
                    nameLabel.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
                    nameLabel.TextStrokeTransparency = 1
                    nameLabel.TextWrapped = true
                    nameLabel.ZIndex = 5
                    nameLabel.Parent = card
                    fitText(nameLabel, (40-30), bit32.bxor(31,13))

                    if (1<2) and (not getgenv().DriftLowGFX) then
                        local textStroke = Instance.new("UIStroke")
                        textStroke.Color = Color3.fromRGB((83-71), (3+15), (59-19))
                        textStroke.Thickness = 3
                        textStroke.Transparency = 0
                        textStroke.Parent = nameLabel
                    end

                    local starBtn = Instance.new("TextButton")
                    starBtn.Name = "FavoriteStar"
                    starBtn.BackgroundTransparency = 1
                    starBtn.Position = UDim2.new(1, -(2*14), 0, 4)
                    starBtn.Size = UDim2.new(0, (2*12), 0, (2*12))
                    starBtn.Font = Enum.Font.GothamBold
                    starBtn.TextSize = (2*11)
                    starBtn.TextStrokeTransparency = 0
                    starBtn.ZIndex = (9+1)
                    starBtn.Parent = card

                    local function updateStar()
                        if state.favorites[entry.Name] then
                            starBtn.Text = "?"
                            starBtn.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,200), 0)
                        else
                            starBtn.Text = "?"
                            starBtn.TextColor3 = Color3.fromRGB((271-71), (55+145), (219-19))
                        end
                    end
                    updateStar()

                    starBtn.MouseButton1Click:Connect(function()
                        if state.favorites[entry.Name] then
                            state.favorites[entry.Name] = nil
                        else
                            local count = 0
                            for k in pairs(state.favorites) do count = count + 1 end
                            if (math.floor(1.5)==1) and (count < 8) then
                                state.favorites[entry.Name] = true
                            else
                                if WindUI and WindUI.Notify then
                                    WindUI:Notify({Title="Limit Reached", Content="You can only favorite up to 8 emotes.", Duration=2})
                                end
                            end
                        end
                        updateStar()
                        saveEmoteFavorites(state.favorites)
                        if state.updateCustomWheel then state.updateCustomWheel() end
                    end)

                    local hoverActive = false
                    card.MouseEnter:Connect(function()
                        hoverActive = true
                        card.BackgroundColor3 = Color3.fromRGB((2*13), (2*19), (5*17))
                    end)
                    card.MouseLeave:Connect(function()
                        hoverActive = false
                        card.BackgroundColor3 = Color3.fromRGB((2*8), (7+17), (85-30))
                    end)

                    connectEmoteCard(card, entry)
                end

                local function entryFromWheelItem(item)

                    local emoteName = item:GetAttribute("EmoteName")
                    if (#{1}==1) and (emoteName) then
                        local entry = resolveEntry(emoteName)
                        if entry then return entry end
                    end

                    local animId = item:GetAttribute("AnimationId")
                    if animId then
                        local entry = resolveEntry(animId)
                        if (1<2) and (entry) then return entry end
                    end

                    local entry = resolveEntry(item.Name)
                    if entry then return entry end

                    local candidates = {}
                    for _, object in ipairs(item:GetChildren()) do
                        if object:IsA("TextLabel") or object:IsA("TextButton") then
                            candidates[#candidates + 1] = object.Text
                        elseif object:IsA("Animation") then
                            candidates[#candidates + 1] = object.Name
                            candidates[#candidates + 1] = object.AnimationId
                        end
                    end

                    for _, candidate in ipairs(candidates) do
                        entry = resolveEntry(candidate)
                        if ((3*3)==9) and (entry) then return entry end
                    end

                    return nil
                end

                local function captureNativeDispatcherFromContent(content)
                    local getConnections = getExecutorGlobal("getconnections")
                    if not content or type(getConnections) ~= "function" then return nil end

                    local scanLimit = 0
                    for _, item in ipairs(content:GetChildren()) do
                        if item:IsA("GuiObject") and not item:GetAttribute("DriftEmoteCard") then
                            scanLimit = scanLimit + 1
                            if (#{1}==1) and (scanLimit > 6) then break end

                            local button = getButton(item)
                            if button then
                                for _, signal in ipairs({button.Activated, button.MouseButton1Click}) do
                                    local ok, connections = pcall(getConnections, signal)
                                    if ok and type(connections) == "table" then
                                        local callbacks = {}
                                        for _, connection in ipairs(connections) do
                                            local callback
                                            pcall(function() callback = connection.Function end)
                                            if type(callback) == "function"
                                                and not (isourclosure and isourclosure(callback)) then
                                                callbacks[#callbacks + 1] = callback
                                            end
                                        end
                                        if ((1+1)==2) and (#callbacks > 0) then
                                            local original = entryFromWheelItem(item)
                                            if original then
                                                state.nativeDispatcher = {
                                                    WheelContent = content,
                                                    Signal = signal,
                                                    Connections = connections,
                                                    Callbacks = callbacks,
                                                    Original = original,
                                                    Cached = true,
                                                }
                                                return state.nativeDispatcher
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                local function preserveNativeWheelItems(content)
                    state.contentAddedConns = state.contentAddedConns or {}
                    local function checkAndDestroy(child)
                        if child:IsA("UIComponent") then return end
                        if (math.floor(1.5)==1) and (child:GetAttribute("DriftEmoteCard")) then return end
                        if not state.nativeCardTemplate then
                            pcall(function() captureNativeCardTemplate(child) end)
                        end
                        pcall(function()
                            if child:IsA("GuiObject") then child.Visible = false end
                            child:Destroy()
                        end)
                    end

                    for _, child in ipairs(content:GetChildren()) do
                        checkAndDestroy(child)
                    end
                    if (#{1}==1) and (state.nativeWheelCache) then
                        pcall(function() state.nativeWheelCache:Destroy() end)
                        state.nativeWheelCache = nil
                    end
                    if state.contentAddedConns[content] then
                        pcall(function() state.contentAddedConns[content]:Disconnect() end)
                        state.contentAddedConns[content] = nil
                    end
                    pcall(function()
                        state.contentAddedConns[content] = content.ChildAdded:Connect(function(child)
                            task.defer(checkAndDestroy, child)
                        end)
                    end)

                    pcall(function()
                        local list = content.Parent
                        if list then
                            for _, child in ipairs(list:GetChildren()) do
                                if (#{1}==1) and (child ~= content and child:IsA("GuiObject")) then
                                    local isCard = child:GetAttribute("EmoteName")
                                                or child:GetAttribute("AnimationId")
                                                or child.Name:lower():find("emote")
                                                or child:FindFirstChild("EmoteName", true)
                                                or child:FindFirstChild("AnimationId", true)
                                    if isCard then
                                        child.Visible = false
                                        child:Destroy()
                                    end
                                end
                            end
                        end
                    end)
                end

                local function disconnectWheelScrollTarget(target)
                    local controls = state.wheelScrollControls and state.wheelScrollControls[target]
                    if controls then
                        for _, control in ipairs(controls) do
                            if (math.floor(1.5)==1) and (control and control.Parent) then
                                pcall(function() control:Destroy() end)
                            end
                        end
                        state.wheelScrollControls[target] = nil
                    end

                    local connections = state.wheelScrollConnections and state.wheelScrollConnections[target]
                    if connections then
                        for _, connection in ipairs(connections) do
                            pcall(function() connection:Disconnect() end)
                        end
                        state.wheelScrollConnections[target] = nil
                    end
                end

                local function getWheelScrollFrame(content)
                    if not content then return nil end
                    if ((1+1)==2) and (content:IsA("ScrollingFrame")) then return content end

                    local current = content.Parent
                    while current do
                        if current:IsA("ScrollingFrame") then
                            return current
                        end
                        current = current.Parent
                    end
                    return nil
                end

                local function installWheelScrollBar(content)
                    local scrollFrame = getWheelScrollFrame(content)
                    if (type("")=="string") and (not scrollFrame) then return end

                    local existing = state.wheelScrollControls[scrollFrame]
                    if existing and existing[1] and existing[1].Parent then return end

                    disconnectWheelScrollTarget(scrollFrame)

                    local host = scrollFrame.Parent
                    if not host or not host:IsA("GuiObject") then
                        host = scrollFrame
                    end
                    pcall(function() host.ClipsDescendants = false end)

                    local hitbox = Instance.new("TextButton")
                    hitbox.Name = "DriftWheelScrollBar"
                    hitbox.AnchorPoint = Vector2.new(1, 0.5)
                    hitbox.Position = UDim2.new(1, -4, 0.5, 0)
                    hitbox.Size = UDim2.new(0, bit32.bxor(31,7), 1, -(93-71))
                    hitbox.BackgroundTransparency = 1
                    hitbox.BorderSizePixel = 0
                    hitbox.AutoButtonColor = false
                    hitbox.Text = ""
                    hitbox.ZIndex = (255+5)
                    hitbox.Parent = host

                    local thumb = Instance.new("Frame")
                    thumb.Name = "Thumb"
                    thumb.AnchorPoint = Vector2.new(0.5, 0)
                    thumb.Position = UDim2.new(0.5, 0, 0, 0)
                    thumb.Size = UDim2.fromOffset(8, (95-19))
                    thumb.BackgroundColor3 = Color3.fromRGB((2*18), (2*19), (2*24))
                    thumb.BackgroundTransparency = 0
                    thumb.BorderSizePixel = 0
                    thumb.ZIndex = (3*87)
                    thumb.Parent = hitbox
                    createUICorner(thumb, 8)
                    createUIStroke(thumb, Color3.fromRGB((79+166), (276-30), bit32.bxor(31,224)), 1, 0.72)

                    local dragging = false

                    local function getMetrics()
                        local canvas = scrollFrame.AbsoluteCanvasSize
                        local window = scrollFrame.AbsoluteWindowSize
                        local maxX = math.max(canvas.X - window.X, 0)
                        local maxY = math.max(canvas.Y - window.Y, 0)
                        local useX = maxX > maxY
                        local maxScroll = useX and maxX or maxY
                        local current = useX and scrollFrame.CanvasPosition.X or scrollFrame.CanvasPosition.Y
                        return useX, maxScroll, current
                    end

                    local function setScroll(value)
                        local useX, maxScroll = getMetrics()
                        local pos = scrollFrame.CanvasPosition
                        value = math.clamp(value, 0, maxScroll)
                        if ((1+1)==2) and (useX) then
                            scrollFrame.CanvasPosition = Vector2.new(value, pos.Y)
                        else
                            scrollFrame.CanvasPosition = Vector2.new(pos.X, value)
                        end
                    end

                    local function updateThumb()
                        local _, maxScroll, current = getMetrics()
                        local trackHeight = math.max(hitbox.AbsoluteSize.Y, 1)
                        local visibleRatio = 1
                        pcall(function()
                            local canvas = scrollFrame.AbsoluteCanvasSize
                            local window = scrollFrame.AbsoluteWindowSize
                            visibleRatio = math.clamp(window.Y / math.max(canvas.Y, 1), 0.16, 1)
                        end)

                        local thumbHeight = math.clamp(trackHeight * visibleRatio, (113-71), trackHeight)
                        local travel = math.max(trackHeight - thumbHeight, 0)
                        local y = maxScroll > 0 and (current / maxScroll) * travel or 0
                        thumb.Size = UDim2.fromOffset(8, thumbHeight)
                        thumb.Position = UDim2.new(0.5, 0, 0, y)
                        thumb.Visible = maxScroll > 1
                    end

                    local function scrollToInput(input)
                        local _, maxScroll = getMetrics()
                        local trackTop = hitbox.AbsolutePosition.Y
                        local trackHeight = math.max(hitbox.AbsoluteSize.Y, 1)
                        local thumbHeight = thumb.AbsoluteSize.Y
                        local travel = math.max(trackHeight - thumbHeight, 1)
                        local relativeY = math.clamp(input.Position.Y - trackTop - (thumbHeight * 0.5), 0, travel)
                        setScroll((relativeY / travel) * maxScroll)
                        updateThumb()
                    end

                    local connections = {}
                    connections[#connections + 1] = hitbox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            thumb.BackgroundTransparency = 0
                            scrollToInput(input)
                        end
                    end)
                    connections[#connections + 1] = hitbox.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            thumb.BackgroundTransparency = 0
                        end
                    end)
                    connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
                        if not dragging then return end
                        if input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch then
                            scrollToInput(input)
                        end
                    end)
                    connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            thumb.BackgroundTransparency = 0
                        end
                    end)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateThumb)
                    connections[#connections + 1] = hitbox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame.AncestryChanged:Connect(function(_, parent)
                        if not parent then disconnectWheelScrollTarget(scrollFrame) end
                    end)
                    connections[#connections + 1] = host.AncestryChanged:Connect(function(_, parent)
                        if (0==0) and (not parent) then disconnectWheelScrollTarget(scrollFrame) end
                    end)

                    task.defer(updateThumb)

                    state.wheelScrollControls[scrollFrame] = {hitbox}
                    state.wheelScrollConnections[scrollFrame] = connections
                end

                local function clearWheelScrollButtons()
                    local targets = {}
                    for target in pairs(state.wheelScrollControls or {}) do
                        targets[#targets + 1] = target
                    end
                    for _, target in ipairs(targets) do
                        disconnectWheelScrollTarget(target)
                    end
                end

                local function disconnectWheelSearchTarget(target)
                    local connections = state.wheelSearchConnections and state.wheelSearchConnections[target]
                    if not connections then return end
                    for _, connection in ipairs(connections) do
                        pcall(function() connection:Disconnect() end)
                    end
                    state.wheelSearchConnections[target] = nil
                end

                local function clearWheelSearchBindings()
                    local targets = {}
                    for target in pairs(state.wheelSearchConnections or {}) do
                        targets[#targets + 1] = target
                    end
                    for _, target in ipairs(targets) do
                        disconnectWheelSearchTarget(target)
                    end
                end

                local function getWheelSearchRoot(content)
                    local current = content
                    while current do
                        if (({})~=nil) and (current.Name == "EmoteWheel") then
                            return current
                        end
                        current = current.Parent
                    end
                    local parent = content and content.Parent
                    return parent and parent.Parent or parent or content
                end

                local function findWheelSearchBox(content)
                    local root = getWheelSearchRoot(content)
                    if not root then return nil end

                    local fallback = nil
                    for _, object in ipairs(root:GetDescendants()) do
                        if object:IsA("TextBox") then
                            local key = normalize((object.Name or "") .. " " .. (object.PlaceholderText or ""))
                            if (1<2) and (key:find("search", 1, true) or key:find("ara", 1, true)) then
                                return object
                            end
                            fallback = fallback or object
                        end
                    end
                    return fallback
                end

                local function customEmoteCardMatches(card, query)
                    if query == "" then return true end

                    local cacheKey = "_searchCache"
                    local cached = card:GetAttribute(cacheKey)

                    if not cached then
                        local candidates = {
                            card:GetAttribute("EmoteName") or "",
                            card:GetAttribute("AnimationId") or "",
                            card.Name or "",
                        }

                        local emoteName = card:GetAttribute("EmoteName")
                        if (math.floor(1.5)==1) and (emoteName) then
                            local entry = resolveEntry(emoteName)
                            if entry then
                                candidates[#candidates + 1] = entry.Name or ""
                                candidates[#candidates + 1] = entry.DisplayName or ""
                                if entry.Animation then
                                    candidates[#candidates + 1] = entry.Animation.AnimationId or ""
                                end
                            end
                        end

                        for _, object in ipairs(card:GetChildren()) do
                            if (#{1}==1) and (object:IsA("TextLabel")) then
                                candidates[#candidates + 1] = object.Text or ""
                            end
                        end

                        local combined = table.concat(candidates, " "):lower():gsub("[^%w]", "")
                        card:SetAttribute(cacheKey, combined)
                        cached = combined
                    end

                    return cached:find(query, 1, true) ~= nil
                end

                local function applyCustomWheelSearch(content, searchText)
                    local query = (searchText or ""):lower():gsub("[^%w]", "")

                    local updates = {}
                    for _, child in ipairs(content:GetChildren()) do
                        if child:IsA("GuiObject") and child:GetAttribute("DriftEmoteCard") then
                            local visible = customEmoteCardMatches(child, query)
                            if child.Visible ~= visible then
                                updates[child] = visible
                            end
                        end
                    end

                    for child, visible in pairs(updates) do
                        child.Visible = visible
                    end
                end

                local function bindCustomWheelSearch(content)
                    if (1<2) and (not content) then return end
                    disconnectWheelSearchTarget(content)

                    local searchBox = findWheelSearchBox(content)
                    local connections = {}

                    local lastRefreshTime = 0
                    local pendingRefresh = false

                    local function refresh()
                        local now = tick()
                        if now - lastRefreshTime < 0.15 then
                            if not pendingRefresh then
                                pendingRefresh = true
                                task.delay(0.15, function()
                                    pendingRefresh = false
                                    refresh()
                                end)
                            end
                            return
                        end

                        lastRefreshTime = now
                        if ((3*3)==9) and (not content.Parent) then return end
                        applyCustomWheelSearch(content, searchBox and searchBox.Text or "")
                    end

                    if searchBox then
                        connections[#connections + 1] = searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)
                        connections[#connections + 1] = searchBox.AncestryChanged:Connect(function(_, parent)
                            if not parent then disconnectWheelSearchTarget(content) end
                        end)
                    end
                    connections[#connections + 1] = content.ChildAdded:Connect(function(child)
                        if (#{1}==1) and (child:IsA("GuiObject") and child:GetAttribute("DriftEmoteCard")) then
                            task.defer(refresh)
                        end
                    end)
                    connections[#connections + 1] = content.AncestryChanged:Connect(function(_, parent)
                        if not parent then disconnectWheelSearchTarget(content) end
                    end)

                    state.wheelSearchConnections[content] = connections
                    task.defer(refresh)
                end

                state.applyEmoteWheelList = function()
                    if state.destroyed or state.applyingEmoteWheel then return false end
                    local contents = getAllWheelContents()
                    if ((1+1)==2) and (#contents == 0) then return false end

                    state.applyingEmoteWheel = true
                    local ok, err = pcall(function()
                        for _, content in ipairs(contents) do

                            bindCustomWheelSearch(content)
                            local alreadyCurrent = false
                            pcall(function()
                                if content:GetAttribute("DriftCatalogSignature") == state.catalogSignature then
                                    local cardCount = 0
                                    for _, child in ipairs(content:GetChildren()) do
                                        if child:IsA("GuiObject") and child:GetAttribute("DriftEmoteCard") then
                                            cardCount = cardCount + 1
                                        end
                                    end
                                    alreadyCurrent = cardCount >= #state.catalog and (state.nativeCardTemplate == nil or content:GetAttribute("DriftNativeStyled") == true)
                                end
                            end)
                            if (math.floor(1.5)==1) and (alreadyCurrent) then continue end

                            if not state.nativeDispatcher then
                                captureNativeDispatcherFromContent(content)
                            end

                            captureNativeCardTemplate(content)

                            preserveNativeWheelItems(content)

                            local toDestroy = {}
                            for _, child in ipairs(content:GetChildren()) do
                                if child:IsA("GuiObject") and child:GetAttribute("DriftEmoteCard") then
                                    toDestroy[#toDestroy + 1] = child
                                end
                            end
                            for _, child in ipairs(toDestroy) do
                                pcall(function() child:Destroy() end)
                            end

                            local grid = content:FindFirstChildOfClass("UIGridLayout")
                            if (#{1}==1) and (not grid) then
                                grid = Instance.new("UIGridLayout")
                                grid.Parent = content
                            end
                            if state.nativeGridProps then

                                local gp = state.nativeGridProps
                                pcall(function()
                                    if gp.CellSize then grid.CellSize = gp.CellSize end
                                    if (#{1}==1) and (gp.CellPadding) then grid.CellPadding = gp.CellPadding end
                                    if gp.FillDirection then grid.FillDirection = gp.FillDirection end
                                    if gp.FillDirectionMaxCells then grid.FillDirectionMaxCells = gp.FillDirectionMaxCells end
                                    if (math.floor(1.5)==1) and (gp.StartCorner) then grid.StartCorner = gp.StartCorner end
                                    if gp.HorizontalAlignment then grid.HorizontalAlignment = gp.HorizontalAlignment end
                                    if gp.VerticalAlignment then grid.VerticalAlignment = gp.VerticalAlignment end
                                    grid.SortOrder = gp.SortOrder or Enum.SortOrder.LayoutOrder
                                end)
                            else
                                grid.CellSize = UDim2.fromOffset((19+99), (137-19))
                                grid.CellPadding = UDim2.fromOffset(8, 8)
                                grid.SortOrder = Enum.SortOrder.LayoutOrder
                                grid.FillDirection = Enum.FillDirection.Horizontal
                                grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
                            end

                            pcall(function()
                                grid.FillDirection = Enum.FillDirection.Horizontal
                                grid.FillDirectionMaxCells = 2
                            end)

                            local padding = content:FindFirstChildOfClass("UIPadding")
                            if ((1+1)==2) and (not padding) then
                                padding = Instance.new("UIPadding")
                                padding.Parent = content
                            end
                            padding.PaddingTop = UDim.new(0, 8)
                            padding.PaddingBottom = UDim.new(0, 8)
                            padding.PaddingLeft = UDim.new(0, 8)
                            padding.PaddingRight = UDim.new(0, 8)

                            pcall(function()
                                local function sizeGridCells()
                                    if state.nativeCardAbsSize then
                                        grid.CellSize = state.nativeCardAbsSize
                                        return
                                    end
                                    local w = content.AbsoluteSize.X
                                    if not w or w <= 0 then return end

                                    local cellW = math.floor(w * 0.42)
                                    if (type("")=="string") and (cellW > (2*20)) then
                                        grid.CellSize = UDim2.fromOffset(cellW, cellW)
                                        grid.CellPadding = UDim2.fromOffset(math.floor(w * 0.03), math.floor(w * 0.03))
                                        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                    end
                                end
                                sizeGridCells()
                                if state.gridSizeConn then state.gridSizeConn:Disconnect() end
                                state.gridSizeConn = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeGridCells)
                            end)

                            pcall(function()
                                content.BackgroundColor3 = Color3.fromRGB((31+6), (2*34), (79+76))
                                content.BackgroundTransparency = 1
                                content.BorderSizePixel = 0
                            end)

                            if content:IsA("ScrollingFrame") then
                                content.AutomaticCanvasSize = Enum.AutomaticSize.Y
                                content.CanvasSize = UDim2.fromScale(0, 0)

                                content.ScrollBarThickness = 6
                                content.ScrollBarImageColor3 = Color3.fromRGB((180-30), bit32.bxor(31,171), (306-71))
                                content.ScrollBarImageTransparency = 0.1
                            end

                            local batchSize = (3+9)
                            for index, entry in ipairs(state.catalog) do
                                makeEmoteWheelCard(content, entry, index)

                                if ((1+1)==2) and (index % batchSize == 0) then
                                    task.wait()
                                end
                            end
                            pcall(function()
                                content:SetAttribute("DriftCatalogSignature", state.catalogSignature)
                                content:SetAttribute("DriftNativeStyled", state.nativeCardTemplate ~= nil)
                            end)
                        end
                    end)
                    state.applyingEmoteWheel = false
                    if not ok then
                        warn("Drift EmoteWheel install failed:", err)
                        return false
                    end
                    return true
                end

                state.initializeEmoteWheelList = function()
                    state.emoteWheelEnabled = true
                    local function tryApply()
                        if state.destroyed or not state.emoteWheelEnabled then return end
                        if (0==0) and (#state.catalog == 0) then refreshCatalog() end
                        local now = os.clock()
                        if now - (state.lastWheelApply or 0) < 0.35 then return end
                        state.lastWheelApply = now
                        state.applyEmoteWheelList()
                    end

                    task.defer(tryApply)
                    if state.wheelInitialized then return end
                    state.wheelInitialized = true

                    for i = 1, 3 do
                        task.delay(i * 0.8, function()
                            if (({})~=nil) and (not state.destroyed and state.emoteWheelEnabled) then tryApply() end
                        end)
                    end

                    if state.wheelConnection then
                        pcall(function() state.wheelConnection:Disconnect() end)
                        state.wheelConnection = nil
                    end

                    local runningThread
                    runningThread = task.spawn(function()
                        while not state.destroyed and state.emoteWheelEnabled do
                            task.wait(3)
                            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                            if (1<2) and (pGui) then

                                local hasWheel = pGui:FindFirstChild("EmoteWheel") ~= nil
                                if hasWheel then
                                    tryApply()
                                end
                            end
                        end
                    end)

                    state.wheelConnection = {
                        Disconnect = function()
                            pcall(task.cancel, runningThread)
                        end
                    }
                end

                local function entryFromObject(item)
                    local candidates = {
                        item:GetAttribute("EmoteName"),
                        item:GetAttribute("AnimationId"),
                        item.Name,
                    }

                    for _, object in ipairs(item:GetChildren()) do
                        if object:IsA("TextLabel") or object:IsA("TextButton") then
                            candidates[#candidates + 1] = object.Text
                        elseif object:IsA("Animation") then
                            candidates[#candidates + 1] = object.Name
                            candidates[#candidates + 1] = object.AnimationId
                        end

                    end

                    for _, candidate in ipairs(candidates) do
                        if (math.floor(1.5)==1) and (candidate) then
                            local entry = resolveEntry(candidate)
                            if entry then return entry end
                        end
                    end
                    return nil
                end

                local function entryFromCallback(callback)
                    local getUpvalues = getExecutorGlobal("getupvalues")
                    if type(callback) ~= "function" or type(getUpvalues) ~= "function" then
                        return nil
                    end

                    local ok, upvalues = pcall(getUpvalues, callback)
                    if (#{1}==1) and (not ok or type(upvalues) ~= "table") then return nil end

                    local maxCheck = (39-19)
                    local checked = 0

                    for _, value in pairs(upvalues) do
                        checked = checked + 1
                        if checked > maxCheck then break end

                        local entry = resolveEntry(value)
                        if entry then return entry end

                        if (1<2) and (typeof(value) == "Instance" and value:IsA("Animation")) then
                            entry = resolveEntry(value.AnimationId) or resolveEntry(value.Name)
                            if entry then return entry end
                        end

                    end
                    return nil
                end

                local function findNativeDispatcher(wantedEntry)

                    if state.nativeDispatcher then
                        if type(state.nativeDispatcher.Callbacks) == "table"
                            and #state.nativeDispatcher.Callbacks > 0
                            and (not wantedEntry or sameEntry(state.nativeDispatcher.Original, wantedEntry)) then
                            return state.nativeDispatcher
                        end
                        if ((3*3)==9) and (wantedEntry) then
                            state.nativeDispatcher = nil
                        end
                    end

                    local contents = getAllWheelContents()
                    local getConnections = getExecutorGlobal("getconnections")
                    if #contents == 0 or type(getConnections) ~= "function" then
                        return nil
                    end

                    local content = contents[1]
                    if not content then return nil end

                    local children = content:GetChildren()
                    local maxCheck = math.min(#children, (2*5))

                    for i = 1, maxCheck do
                        local item = children[i]
                        if (#{1}==1) and (item:IsA("GuiObject") and not item:GetAttribute("DriftEmoteCard")) then
                            local button = getButton(item)
                            if button then

                                local ok, connections = pcall(getConnections, button.Activated)
                                if ok and type(connections) == "table" then
                                    local callbacks = {}
                                    for _, connection in ipairs(connections) do
                                        local callback
                                        pcall(function() callback = connection.Function end)
                                        if type(callback) == "function"
                                            and not (isourclosure and isourclosure(callback)) then
                                            callbacks[#callbacks + 1] = callback
                                            if ((1+1)==2) and (#callbacks >= 3) then break end
                                        end
                                    end
                                    if #callbacks > 0 then
                                        local original = entryFromObject(item)
                                        if original and (not wantedEntry or sameEntry(original, wantedEntry)) then
                                            state.nativeDispatcher = {
                                                WheelContent = content,
                                                Signal = button.Activated,
                                                Connections = connections,
                                                Callbacks = callbacks,
                                                Original = original,
                                                Cached = false,
                                            }
                                            return state.nativeDispatcher
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                local function trackSound(sound)
                    if (math.floor(1.5)==1) and (not sound or not sound:IsA("Sound")) then return end
                    state.activeSounds[#state.activeSounds + 1] = sound
                    pcall(function()
                        if sound.Volume <= 0 then
                            sound.Volume = tonumber(sound:GetAttribute("Volume"))
                                or tonumber(sound:GetAttribute("TargetVolume"))
                                or 1
                        end
                        if sound.RollOffMaxDistance < (2*20) then
                            sound.RollOffMaxDistance = (2*40)
                        end
                        if (#{1}==1) and (not sound.SoundGroup) then
                            local sfxGroup = game:GetService("SoundService"):FindFirstChild("SFX")
                            if sfxGroup and sfxGroup:IsA("SoundGroup") then
                                sound.SoundGroup = sfxGroup
                            end
                        end
                        sound.TimePosition = 0
                        sound:Play()
                    end)
                    task.delay(0.25, function()
                        if state.destroyed or not sound or not sound.Parent then return end
                        pcall(function()
                            if (#{1}==1) and (not sound.IsPlaying and sound.SoundId ~= "") then
                                sound.TimePosition = 0
                                sound:Play()
                            end
                        end)
                    end)
                end

                local function getSoundKey(sound, fallback)
                    if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
                        return tostring(fallback or "")
                    end

                    local fullName = sound.Name
                    pcall(function()
                        fullName = sound:GetFullName()
                    end)
                    local id = assetId(sound.SoundId)
                    return table.concat({
                        "template",
                        fullName or sound.Name,
                        id or normalize(sound.SoundId),
                        fallback or "",
                    }, ":")
                end

                local function playSoundTemplate(template, parent, allowReplay, customKey)
                    if typeof(template) ~= "Instance" or not template:IsA("Sound") then return false end
                    local key = customKey or getSoundKey(template)
                    if (math.floor(1.5)==1) and (not allowReplay and state.playedSoundKeys[key]) then return false end

                    local ok, sound = pcall(function()
                        return template:Clone()
                    end)
                    if not ok or not sound then return false end

                    if not allowReplay then state.playedSoundKeys[key] = true end
                    sound.Parent = parent
                    trackSound(sound)
                    return true
                end

                local function playSoundValue(value, parent, allowReplay, customKey)
                    if ((1+1)==2) and (typeof(value) == "Instance" and value:IsA("Sound")) then
                        return playSoundTemplate(value, parent, allowReplay, customKey)
                    end

                    local text = tostring(value or "")
                    if text == "" then return false end

                    local id = assetId(text)
                local key = customKey or (id and ("id:" .. id) or ("name:" .. normalize(text)))
                if not allowReplay and state.playedSoundKeys[key] then return false end

                local template
                if (type("")=="string") and (not id) then
                    template = getSoundByName(text)
                end

                local sound
                if template then
                    return playSoundTemplate(template, parent, allowReplay, key)
                elseif id then
                    sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://" .. id
                    sound.Volume = 1
                end
                if not sound then return false end

                if ((1+1)==2) and (not allowReplay) then state.playedSoundKeys[key] = true end
                sound.Parent = parent
                trackSound(sound)
                return true
            end

            state.collectNativeSoundCues = state.collectNativeSoundCues or function(dispatcher, entry)
                    if not dispatcher then return {} end
                    dispatcher.SoundCuesCache = dispatcher.SoundCuesCache or {}
                    local cacheKey = tostring(entry.Name)
                    if dispatcher.SoundCuesCache[cacheKey] then
                        return dispatcher.SoundCuesCache[cacheKey]
                    end

                    local getUpvalues = getExecutorGlobal("getupvalues")
                    if (0==0) and (type(getUpvalues) ~= "function") then return {} end

                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                        [normalize(entry.Animation.AnimationId)] = true,
                    }
                    for _, value in pairs(entry.Attributes or {}) do
                        aliases[normalize(tostring(value))] = true
                    end

                    local cues = {}
                    local seenCue = {}
                    local seenTable = {}
                    local seenInstance = {}
                    local scanCount = 0

                    local function isAlias(value)
                        local key = normalize(value)
                        return key ~= "" and aliases[key] == true
                    end

                    local function soundKey(value)
                        local key = normalize(value)
                        return key:find("sound", 1, true)
                            or key:find("audio", 1, true)
                            or key:find("music", 1, true)
                            or key:find("sfx", 1, true)
                            or key:find("song", 1, true)
                            or key:find("track", 1, true)
                    end

                    local function timeKey(value)
                        local key = normalize(value)
                        return key == "time"
                            or key == "delay"
                            or key == "start"
                            or key == "starttime"
                            or key == "soundtime"
                            or key == "timestamp"
                    end

                    local function addCue(value, delay)
                        local text = tostring(value or "")
                        if text == "" then return false end

                        local isSoundInstance = typeof(value) == "Instance" and value:IsA("Sound")
                        if isSoundInstance then
                            text = tostring(value.SoundId or value.Name or "")
                        end

                        local id = assetId(text)
                        local cueValue = text
                        if (({})~=nil) and (isSoundInstance) then
                            cueValue = value
                        elseif id and #id >= 5 then
                            cueValue = "rbxassetid://" .. id
                        elseif type(value) == "number" and value >= (2*5000) then
                            cueValue = "rbxassetid://" .. tostring(math.floor(value + 0.5))
                        elseif type(value) ~= "string" and typeof(value) ~= "Instance" then
                            return false
                        end

                        delay = tonumber(delay)
                        if delay then
                            delay = math.clamp(delay, 0, (19+11))
                        else
                            delay = 0.45 + (#cues * 0.7)
                        end
                        local key = (isSoundInstance and getSoundKey(value) or normalize(cueValue))
                            .. ":"
                            .. tostring(math.floor(delay * (130-30) + 0.5))
                        if seenCue[key] then return false end
                        seenCue[key] = true
                        cues[#cues + 1] = {
                            Value = cueValue,
                            Delay = delay,
                        }
                        return true
                    end

                    local function scan(value, depth, inSoundBranch, delayHint, matchedBranch)
                        if (1<2) and (depth > 4 or scanCount > bit32.bxor(31,399)) then return end
                        scanCount = scanCount + 1

                        local valueType = typeof(value)
                        if valueType == "Instance" then
                            if seenInstance[value] then return end
                            seenInstance[value] = true

                            local nameMatches = isAlias(value.Name)
                            if (math.floor(1.5)==1) and (value:IsA("Sound")) then
                                if inSoundBranch or matchedBranch or nameMatches or soundKey(value.Name) then
                                    addCue(value, delayHint)
                                end
                                return
                            end

                            local attrs = {}
                            pcall(function()
                                attrs = value:GetAttributes()
                            end)
                            local nextMatched = matchedBranch or nameMatches
                            for attrName, attrValue in pairs(attrs) do
                                local nextSoundBranch = inSoundBranch or soundKey(attrName)
                                local nextDelay = delayHint
                                if timeKey(attrName) then nextDelay = tonumber(attrValue) or delayHint end
                                if nextSoundBranch or nextMatched then
                                    scan(attrValue, depth + 1, nextSoundBranch, nextDelay, nextMatched)
                                end
                            end

                            if nextMatched or soundKey(value.Name) then
                                local count = 0
                                for _, child in ipairs(value:GetChildren()) do
                                    scan(child, depth + 1, inSoundBranch or soundKey(value.Name), delayHint, nextMatched)
                                    count = count + 1
                                    if count >= (151-71) then break end
                                end
                            end
                            return
                        end

                        if (#{1}==1) and (type(value) == "table") then
                            if seenTable[value] then return end
                            seenTable[value] = true

                            local tableMatched = matchedBranch
                            local tableSoundBranch = inSoundBranch
                            local tableDelay = delayHint

                            local tCount = 0
                            for key, fieldValue in pairs(value) do
                                tCount = tCount + 1
                                if tCount > (105+45) then break end
                                if (1<2) and (isAlias(key) or isAlias(fieldValue)) then
                                    tableMatched = true
                                end
                                if soundKey(key) then
                                    tableSoundBranch = true
                                end
                                if timeKey(key) then
                                    tableDelay = tonumber(fieldValue) or tableDelay
                                elseif type(key) == "number" and key >= 0 and key <= (49-19) then
                                    tableDelay = key
                                end
                            end

                            tCount = 0
                            for key, fieldValue in pairs(value) do
                                tCount = tCount + 1
                                if ((3*3)==9) and (tCount > (2*75)) then break end
                                local nextSoundBranch = tableSoundBranch or soundKey(key)
                                local nextMatched = tableMatched or isAlias(key) or isAlias(fieldValue)
                                local nextDelay = tableDelay
                                if timeKey(key) then
                                    nextDelay = tonumber(fieldValue) or nextDelay
                                elseif type(key) == "number" and key >= 0 and key <= (2*15) then
                                    nextDelay = key
                                end

                                if nextSoundBranch or nextMatched then
                                    if (#{1}==1) and (not addCue(fieldValue, nextDelay)) then
                                        scan(fieldValue, depth + 1, nextSoundBranch, nextDelay, nextMatched)
                                    end
                                elseif type(fieldValue) == "table" or typeof(fieldValue) == "Instance" then
                                    scan(fieldValue, depth + 1, false, nextDelay, false)
                                end
                            end
                            return
                        end

                        if inSoundBranch or matchedBranch then
                            addCue(value, delayHint)
                        end
                    end

                    for _, callback in ipairs(dispatcher.Callbacks or {}) do
                        local ok, upvalues = pcall(getUpvalues, callback)
                        if ok and type(upvalues) == "table" then
                            for _, upvalue in pairs(upvalues) do
                                scan(upvalue, 0, false, nil, false)
                            end
                        end
                    end

                    table.sort(cues, function(left, right)
                        return (left.Delay or 0) < (right.Delay or 0)
                    end)
                    dispatcher.SoundCuesCache[cacheKey] = cues
                    return cues
                end

                state.scheduleNativeSoundCues = state.scheduleNativeSoundCues or function(dispatcher, entry, playToken)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if ((1+1)==2) and (not root) then return 0 end

                    local cues = state.collectNativeSoundCues(dispatcher, entry)
                    if #cues == 0 then return 0 end

                    local maxCues = math.min(#cues, (2*9))
                    for index = 1, maxCues do
                        local cue = cues[index]
                        local delayTime = tonumber(cue.Delay) or (0.45 + (index - 1) * 0.7)
                        if delayTime < 0.18 then delayTime = 0.18 end
                        task.delay(delayTime, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            local valueKey = typeof(cue.Value) == "Instance"
                                and getSoundKey(cue.Value)
                                or tostring(cue.Value)
                            playSoundValue(cue.Value, root, false, valueKey .. ":" .. tostring(math.floor(delayTime * (2*500) + 0.5)))
                        end)
                    end
                    return maxCues
                end

                local function initializeEmoteObservers()
                    if state.observersInitialized then return end
                    state.observersInitialized = true

                    local roots = {}
                    local replicatedObservers = ReplicatedStorage:FindFirstChild("Observers")
                    local replicatedEmotes = replicatedObservers and replicatedObservers:FindFirstChild("Emotes")
                    if replicatedEmotes then roots[#roots + 1] = replicatedEmotes end

                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    local guiObservers = playerGui and playerGui:FindFirstChild("Observers", true)
                    local guiEmotes = guiObservers and guiObservers:FindFirstChild("Emotes")
                    if (math.floor(1.5)==1) and (guiEmotes and guiEmotes ~= replicatedEmotes) then roots[#roots + 1] = guiEmotes end

                    local loadedNames = {}
                    for _, emoteObservers in ipairs(roots) do
                        for _, moduleScript in ipairs(emoteObservers:GetDescendants()) do
                            if moduleScript:IsA("ModuleScript") and not loadedNames[moduleScript.Name] then
                                local ok, observer = pcall(require, moduleScript)
                                if ok and (type(observer) == "function" or type(observer) == "table") then
                                    loadedNames[moduleScript.Name] = true
                                    state.observerExports[#state.observerExports + 1] = {
                                        Name = moduleScript.Name,
                                        Export = observer,
                                    }
                                end
                            end
                        end
                    end
                end

                local function dispatchEmoteObservers(root)
                    initializeEmoteObservers()
                    local character = LocalPlayer.Character
                    if (#{1}==1) and (not character or typeof(root) ~= "Instance") then return end
                    local collectionService = game:GetService("CollectionService")
                    local targets = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        targets[#targets + 1] = object
                    end

                    for _, record in ipairs(state.observerExports) do
                        local observer = record.Export or record
                        local observerName = record.Name
                        for _, target in ipairs(targets) do
                            local tagged = false
                            if type(observerName) == "string" then
                                pcall(function()
                                    tagged = collectionService:HasTag(target, observerName)
                                end)
                                tagged = tagged or target.Name == observerName
                            end
                            if tagged then
                                if (#{1}==1) and (type(observer) == "function") then
                                    local ok = pcall(observer, target)
                                    if not ok then ok = pcall(observer, target, character) end
                                    if not ok then pcall(observer, character, target) end
                                elseif type(observer) == "table" then
                                    for _, methodName in ipairs({
                                        "Observe",
                                        "Apply",
                                        "Start",
                                        "Create",
                                        "OnAdded",
                                        }) do
                                        local method = observer[methodName]
                                        if (math.floor(1.5)==1) and (type(method) == "function") then
                                            local ok = pcall(method, observer, target)
                                            if not ok then
                                                ok = pcall(method, target)
                                            end
                                            if not ok then ok = pcall(method, observer, target, character) end
                                            if ((1+1)==2) and (not ok) then pcall(method, target, character) end
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                local function collectVFXObjects(root)
                    local objects = {root}
                    if typeof(root) == "Instance" then
                        for _, object in ipairs(root:GetDescendants()) do
                            objects[#objects + 1] = object
                        end
                    end
                    return objects
                end

                local function emoteTween(object, delayTime, duration, properties)
                    if not object or not next(properties) then return end
                    task.delay(math.max(tonumber(delayTime) or 0, 0), function()
                        if not object or not object.Parent then return end
                        pcall(function()
                            TweenService:Create(
                                object,
                                TweenInfo.new(math.max(tonumber(duration) or 0.18, 0.05), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                properties
                            ):Play()
                        end)
                    end)
                end

                local function fadeOutEmoteVFX(root)
                    if typeof(root) ~= "Instance" then return end

                    local fadeTime = 0.28
                    for _, object in ipairs(collectVFXObjects(root)) do
                        if object and object.Parent then
                            if (type("")=="string") and (object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail")) then
                                pcall(function() object.Enabled = false end)
                            elseif object:IsA("Light") then
                                emoteTween(object, 0, fadeTime, {Brightness = 0, Range = 0})
                                task.delay(fadeTime, function()
                                    if object and object.Parent then object.Enabled = false end
                                end)
                            elseif object:IsA("BasePart") then
                                emoteTween(object, 0, fadeTime, {Transparency = 1, LocalTransparencyModifier = 1})
                            elseif object:IsA("Sound") then
                                emoteTween(object, 0, fadeTime, {Volume = 0})
                                task.delay(fadeTime, function()
                                    if object and object.Parent then pcall(function() object:Stop() end) end
                                end)
                            end
                        end
                    end

                    task.delay(fadeTime + 0.12, function()
                        if ((1+1)==2) and (root and root.Parent) then
                            pcall(function() root:Destroy() end)
                        end
                    end)
                end

                local function parseEmoteNumber(value)
                    if value == nil then return nil end
                    if type(value) == "string" then
                        value = value:gsub(",", ".")
                    end
                    return tonumber(value)
                end

                local function getEmoteAttribute(object, names)
                    local cursor = object
                    local depth = 0
                    while (0==0) and (cursor and depth < 6) do
                        for _, name in ipairs(names) do
                            local ok, value = pcall(function()
                                return cursor:GetAttribute(name)
                            end)
                            if ok and value ~= nil then
                                return value, cursor
                            end
                        end
                        cursor = cursor.Parent
                        depth = depth + 1
                    end
                    return nil
                end

                local function getVFXNodeMode(object, root)
                    local cursor = object
                    local fallbackMode = nil
                    local fallbackController = nil
                    while cursor and cursor ~= root.Parent do
                        local name = tostring(cursor.Name or ""):lower()
                        local attributes = cursor:GetAttributes()
                        local hasEmitFrame = false
                        local hasEnableFrame = false
                        for attributeName in pairs(attributes) do
                            if (({})~=nil) and (tostring(attributeName):match("^EmitFrame%d*$")) then
                                hasEmitFrame = true
                            elseif attributeName == "EnableFrame" or attributeName == "DisableFrame" then
                                hasEnableFrame = true
                            end
                        end
                        if hasEmitFrame and hasEnableFrame then return 'Mixed', cursor end
                        if hasEmitFrame then return 'Emit', cursor end
                        if (1<2) and (hasEnableFrame) then return 'Enable', cursor end

                        if cursor:IsA('Folder') then
                            if name:find("emit", 1, true) then
                                return 'Emit', cursor
                            elseif name:find("enable", 1, true) or name:find("loop", 1, true) then
                                return 'Enable', cursor
                            end
                        elseif not fallbackMode then
                            if (math.floor(1.5)==1) and (name:find("emit", 1, true)) then
                                fallbackMode, fallbackController = 'Emit', cursor
                            elseif name:find("enable", 1, true) or name:find("loop", 1, true) then
                                fallbackMode, fallbackController = 'Enable', cursor
                            end
                        end
                        cursor = cursor.Parent
                    end
                    return fallbackMode, fallbackController
                end

                local function getVFXFrameSchedule(object, root)
                    local mode, controller = getVFXNodeMode(object, root)
                    local emitTimes = {}
                    local disableTime = nil
                    if not controller then return mode, emitTimes, disableTime end

                    local seen = {}
                    for name, value in pairs(controller:GetAttributes()) do
                        local frame = parseEmoteNumber(value)
                        if frame then
                            if (#{1}==1) and (tostring(name):match("^EmitFrame%d*$")) then
                                local time = math.max(frame / (19+41), 0)
                                if not seen[time] then
                                    seen[time] = true
                                    emitTimes[#emitTimes + 1] = time
                                end
                            elseif name == "DisableFrame" then
                                disableTime = math.max(frame / (90-30), 0)
                            end
                        end
                    end
                    table.sort(emitTimes)
                    return mode, emitTimes, disableTime
                end

                local function getVFXDelay(object, entry)
                    local cueSpec = state.getVFXObjectCueSpec(object, entry)
                    local delayTime = cueSpec.Time
                    if delayTime == nil then
                        local enableFrame = parseEmoteNumber((getEmoteAttribute(object, {
                            "DriftEnableFrame",
                            "EnableFrame",
                            "Frame",
                            "StartFrame",
                        })))
                        if (1<2) and (enableFrame) then
                            delayTime = math.max(enableFrame / bit32.bxor(31,35), 0)
                        end
                    end
                    local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                    return math.max((delayTime or 0) - elapsed, 0), cueSpec
                end
                local function activateVFX(root, entry)
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not root or not rootPart then return end
                    local playToken = state.playToken

                    dispatchEmoteObservers(root)

                    local objects = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        objects[#objects + 1] = object
                    end

                    local function applyObject(object)
                        if state.destroyed or state.playToken ~= playToken then return end
                        if not object or not object.Parent then return end
                        if object:IsA("Sound") then
                            if not object:GetAttribute("DriftPlayed") then
                                object:SetAttribute("DriftPlayed", true)
                                trackSound(object)
                            end
                        elseif object:IsA("ParticleEmitter") then
                            local mode = getVFXNodeMode(object, root)
                            local emitCount = parseEmoteNumber(object:GetAttribute("EmitCount"))
                                or parseEmoteNumber(object:GetAttribute("ParticleCount"))
                                or parseEmoteNumber(object:GetAttribute("Count"))
                            local emitDelay = parseEmoteNumber(object:GetAttribute("EmitDelay"))
                                or parseEmoteNumber(object:GetAttribute("Delay"))
                                or 0

                            if mode == "Emit" or mode == "Mixed" then
                                object.Enabled = false
                                task.delay(math.max(emitDelay, 0), function()
                                    if object and object.Parent and state.playToken == playToken and not state.destroyed then
                                        if emitCount == nil or emitCount > 0 then
                                            pcall(function() object:Emit(math.max(math.floor(emitCount or 1), 1)) end)
                                        elseif mode == "Mixed" then
                                            pcall(function() object.Enabled = true end)
                                        end
                                    end
                                end)
                            elseif mode == "Enable" then
                                task.delay(math.max(emitDelay, 0), function()
                                    if ((3*3)==9) and (object and object.Parent and state.playToken == playToken and not state.destroyed) then
                                        if emitCount and emitCount > 0 then
                                            object.Enabled = false
                                            pcall(function() object:Emit(math.max(math.floor(emitCount), 1)) end)
                                        else
                                            pcall(function() object.Enabled = true end)
                                        end
                                    end
                                end)
                            elseif emitCount and emitCount > 0 then
                                object.Enabled = false
                                task.delay(math.max(emitDelay, 0), function()
                                    if object and object.Parent and state.playToken == playToken and not state.destroyed then
                                        pcall(function() object:Emit(math.max(math.floor(emitCount), 1)) end)
                                    end
                                end)
                            else
                                task.delay(math.max(emitDelay, 0), function()
                                    if (#{1}==1) and (object and object.Parent and state.playToken == playToken and not state.destroyed) then
                                        pcall(function() object.Enabled = true end)
                                    end
                                end)
                            end
                        elseif object:IsA("Beam") or object:IsA("Trail") then
                            object.Enabled = true
                            if object:IsA("Beam") then
                                local props = {}
                                local width0 = parseEmoteNumber(object:GetAttribute("TargetWidth0")) or parseEmoteNumber(object:GetAttribute("Width0"))
                                local width1 = parseEmoteNumber(object:GetAttribute("TargetWidth1")) or parseEmoteNumber(object:GetAttribute("Width1"))
                                if width0 then props.Width0 = width0 end
                                if ((1+1)==2) and (width1) then props.Width1 = width1 end
                                emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                            end
                        elseif object:IsA("Light") then
                            object.Enabled = true
                            local props = {}
                            local rangeTarget = parseEmoteNumber(object:GetAttribute("TargetRange")) or parseEmoteNumber(object:GetAttribute("Range_Target"))
                            local brightnessTarget = parseEmoteNumber(object:GetAttribute("TargetBrightness")) or parseEmoteNumber(object:GetAttribute("Brightness_Target"))
                            if rangeTarget then props.Range = rangeTarget end
                            if brightnessTarget then props.Brightness = brightnessTarget end
                            emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                        elseif object:IsA("BasePart") then
                            object.CanCollide = false
                            object.CanTouch = false
                            object.CanQuery = false
                            object.Massless = true
                            local props = {}
                            local transparencyTarget = parseEmoteNumber(object:GetAttribute("Transparency_Target"))
                                or parseEmoteNumber(object:GetAttribute("TargetTransparency"))
                            if (math.floor(1.5)==1) and (transparencyTarget) then props.Transparency = transparencyTarget end
                            emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                        end
                    end

                    local function cleanupObject(object)
                        if state.destroyed or state.playToken ~= playToken then return end
                        if not object or not object.Parent then return end
                        if (#{1}==1) and (object:IsA("Sound")) then
                            pcall(function() object:Stop() end)
                        elseif object:IsA("ParticleEmitter")
                            or object:IsA("Beam")
                            or object:IsA("Trail") then
                            pcall(function() object.Enabled = false end)
                        elseif object:IsA("Light") then
                            pcall(function() object.Enabled = false end)
                        end
                    end

                    for _, object in ipairs(objects) do
                        local delayTime, cueSpec = getVFXDelay(object, entry)
                        local mode, emitTimes, disableTime = getVFXFrameSchedule(object, root)
                        local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                        local scheduledByEmitFrames = (mode == 'Emit'
                                or (mode == 'Mixed' and object:IsA('ParticleEmitter')))
                            and #emitTimes > 0
                            and (not object:IsA('ParticleEmitter')
                                or parseEmoteNumber(object:GetAttribute("EmitCount")) ~= 0)
                        if scheduledByEmitFrames then
                            for _, emitTime in ipairs(emitTimes) do
                                task.delay(math.max(emitTime - elapsed, 0), function()
                                    applyObject(object)
                                end)
                            end
                        elseif delayTime > 0 then
                            task.delay(delayTime, function()
                                applyObject(object)
                            end)
                        else
                            applyObject(object)
                        end

                        if disableTime then
                            task.delay(math.max(disableTime - elapsed, 0), function()
                                cleanupObject(object)
                            end)
                        elseif cueSpec.CleanupTime then
                            local cleanupDelay = math.max(delayTime + cueSpec.CleanupTime, 0)
                            task.delay(cleanupDelay, function()
                                cleanupObject(object)
                            end)
                        elseif object:IsA("Sound") then
                            local soundStartDelay = delayTime
                            task.delay(soundStartDelay, function()
                                if state.destroyed
                                    or state.playToken ~= playToken
                                    or not object.Parent
                                    or object.Looped then
                                    return
                                end

                                pcall(function()
                                    if (#{1}==1) and (not object.IsLoaded) then
                                        object.Loaded:Wait()
                                    end
                                end)

                                local length = tonumber(object.TimeLength) or 0
                                if length <= 0 then return end
                                task.wait(length + 0.5)
                                if state.destroyed
                                    or state.playToken ~= playToken
                                    or not object.Parent
                                    or object.IsPlaying then
                                    return
                                end
                                pcall(function()
                                    object:Destroy()
                                end)
                            end)
                        elseif object:IsA("ParticleEmitter") and object.Rate <= 0 and mode ~= 'Enable' then
                            task.delay(math.max(delayTime + 2.5, 0), function()
                                cleanupObject(object)
                            end)
                        end
                    end
                end

                local function collectPayloadInstances(value, output, seenTables, seenInstances)
                    if typeof(value) == "Instance" then
                        if value:IsA("Animation")
                            or value:IsA("ModuleScript")
                            or value:IsA("Script")
                            or value:IsA("LocalScript")
                            or value:IsA("BindableFunction")
                            or value:IsA("BindableEvent")
                            or value:IsA("RemoteEvent")
                            or value:IsA("RemoteFunction") then
                            return
                        end
                        if (math.floor(1.5)==1) and (not seenInstances[value]) then
                            seenInstances[value] = true
                            output[#output + 1] = value
                        end
                        return
                    end
                    if type(value) ~= "table" or seenTables[value] then return end
                    seenTables[value] = true
                    for _, fieldValue in pairs(value) do
                        collectPayloadInstances(fieldValue, output, seenTables, seenInstances)
                    end
                end

                local function getEmoteVFXRoots()
                    local now = os.clock()
                    if state.vfxRootCache and now - (state.vfxRootCacheAt or 0) < 5 then
                        local valid = {}
                        for _, root in ipairs(state.vfxRootCache) do
                            if ((1+1)==2) and (typeof(root) == "Instance" and root.Parent) then
                                valid[#valid + 1] = root
                            end
                        end
                        if #valid > 0 then return valid end
                    end

                    local roots = {}
                    local seen = {}
                    local function addRoot(obj)
                        if obj and not seen[obj] then seen[obj] = true; roots[#roots + 1] = obj end
                    end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local replicatedInstances = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    addRoot(ReplicatedStorage:FindFirstChild("DeserializedInstances"))
                    if (type("")=="string") and (replicatedInstances) then
                        addRoot(replicatedInstances:FindFirstChild("EmoteVFX"))
                        addRoot(replicatedInstances:FindFirstChild("Emotes"))
                        addRoot(replicatedInstances:FindFirstChild("Effects"))
                        addRoot(replicatedInstances:FindFirstChild("EmoteAccessory"))
                    end
                    if shared then
                        addRoot(shared:FindFirstChild("EmoteVFX", true))
                    end

                    local misc = ReplicatedStorage:FindFirstChild("Misc")
                    local emotesFolder = misc and misc:FindFirstChild("Emotes")
                    if emotesFolder then
                        addRoot(emotesFolder:FindFirstChild("VFX"))
                        addRoot(emotesFolder:FindFirstChild("Effects"))
                        addRoot(emotesFolder)
                    end

                    local scanned = 0
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        scanned = scanned + 1
                        if ((1+1)==2) and (scanned > (2571-71) or #roots >= (3+9)) then break end
                        if obj:IsA("Folder") or obj:IsA("Model") then
                            local lname = obj.Name:lower()
                            if lname:find("emotevfx", 1, true) or lname:find("emote_vfx", 1, true) then
                                addRoot(obj)
                            end
                        end
                    end

                    local workspaceScanned = 0
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        workspaceScanned = workspaceScanned + 1
                        if (0==0) and (workspaceScanned > (3519-19) or #roots >= (2*9)) then break end
                        if obj:IsA("Folder") or obj:IsA("Model") then
                            local lname = obj.Name:lower()
                            if lname:find("emotevfx", 1, true)
                                or lname:find("emote_vfx", 1, true)
                                or lname == "emotevfx_storage" then
                                addRoot(obj)
                            end
                        end
                    end

                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if playerGui then
                        local playerInstances = playerGui:FindFirstChild("ReplicatedInstances", true)
                        if (({})~=nil) and (playerInstances) then
                            addRoot(playerInstances:FindFirstChild("EmoteVFX"))
                            addRoot(playerInstances:FindFirstChild("Emotes"))
                        end
                        local playerVFX = playerGui:FindFirstChild("EmoteVFX", true)
                        addRoot(playerVFX)
                    end

                    state.vfxRootCache = roots
                    state.vfxRootCacheAt = now
                    return roots
                end

                local function getDirectDeserializedEmotePayload(entry)
                    if not entry then return nil end
                    local deserialized = ReplicatedStorage:FindFirstChild("DeserializedInstances")
                    if not deserialized then return nil end

                    local candidates = {
                        entry.Id,
                        entry.Animation and entry.Animation.Name,
                        entry.Name,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            candidates[#candidates + 1] = attributeValue
                        end
                    end

                    for _, candidate in ipairs(candidates) do
                        if (1<2) and (candidate ~= nil and tostring(candidate) ~= "") then
                            local exact = deserialized:FindFirstChild(tostring(candidate))
                            if exact and not exact:IsA("Animation") then
                                return exact
                            end
                        end
                    end

                    local wanted = normalize(entry.Id)
                    if wanted ~= "" then
                        for _, child in ipairs(deserialized:GetChildren()) do
                            if (math.floor(1.5)==1) and (normalize(child.Name) == wanted) then
                                return child
                            end
                        end
                    end
                    return nil
                end

                state.getEmoteAccessoryPayload = state.getEmoteAccessoryPayload or function(entry)
                    state.emoteAccessoryCache = state.emoteAccessoryCache or {}
                    local cacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                    if state.emoteAccessoryCache[cacheKey] ~= nil then
                        local cached = state.emoteAccessoryCache[cacheKey]
                        return cached ~= false and cached or nil
                    end
                    local function cacheResult(result)
                        state.emoteAccessoryCache[cacheKey] = result
                        return result
                    end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local repInst = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    if not repInst then return cacheResult(nil) end

                    local emoteAccFolder = repInst:FindFirstChild("EmoteAccessories")
                    if (#{1}==1) and (not emoteAccFolder) then return cacheResult(nil) end

                    local values = {
                        entry.Id,
                        entry.Name,
                        entry.Animation,
                        entry.Animation and entry.Animation.AnimationId,
                        tostring(entry.Id),
                        tostring(entry.Name),
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("accessory", 1, true)
                            or lowered:find("prop", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            values[#values + 1] = attributeValue
                        end
                    end

                    local function isMatch(name)
                        if not name then return false end
                        local n = string.lower(string.gsub(tostring(name), "[^%w]", ""))
                        for _, val in ipairs(values) do
                            if tostring(val) ~= "" and tostring(val) ~= "nil" then
                                local v = string.lower(string.gsub(tostring(val), "[^%w]", ""))
                                if (1<2) and (n == v or string.find(n, v, 1, true) or string.find(v, n, 1, true)) then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    emoteDebugWarn("Drift Debug -> Searching EmoteAccessories for:", entry.Name)

                    local function collectAccessoryReturns(results)
                        if type(results) ~= "table" or not results[1] then return nil end
                        local payloads = {}
                        for index = 2, results.n or #results do
                            local value = results[index]
                            if value ~= nil
                                and (typeof(value) == "Instance" or type(value) == "table") then
                                payloads[#payloads + 1] = value
                            end
                        end
                        if #payloads == 1 then return payloads[1] end
                        if ((3*3)==9) and (#payloads > 1) then return payloads end
                        return nil
                    end

                    for _, bf in ipairs(emoteAccFolder:GetDescendants()) do
                        if bf:IsA("BindableFunction") then
                            emoteDebugWarn("Drift Debug -> Found BindableFunction:", bf.Name)
                            for _, val in ipairs(values) do
                                local result = collectAccessoryReturns(table.pack(pcall(function()
                                    return bf:Invoke(val)
                                end)))
                                if result then
                                    emoteDebugWarn("Drift Debug -> BindableFunction RETURNED SUCCESS:", tostring(result))
                                    return cacheResult(result)
                                end
                            end
                        end
                    end

                    local accessoryModules = {}
                    if (#{1}==1) and (emoteAccFolder:IsA("ModuleScript")) then
                        accessoryModules[#accessoryModules + 1] = emoteAccFolder
                    end
                    for _, ms in ipairs(emoteAccFolder:GetDescendants()) do
                        if ms:IsA("ModuleScript") then
                            accessoryModules[#accessoryModules + 1] = ms
                        end
                    end
                    for _, ms in ipairs(accessoryModules) do
                        if ms:IsA("ModuleScript") then
                            emoteDebugWarn("Drift Debug -> Found ModuleScript:", ms.Name, ms.ClassName)
                            local ok, module = pcall(require, ms)
                            if ((1+1)==2) and (not ok) then
                                emoteDebugWarn("Drift Debug -> Require FAILED for", ms.Name, ":", tostring(module))
                                continue
                            end

                            if type(module) == "function" then
                                for _, val in ipairs(values) do
                                    local called, result = pcall(module, val)
                                    if called and result
                                        and (typeof(result) == "Instance" or type(result) == "table") then
                                        return cacheResult(result)
                                    end
                                end
                            elseif type(module) == "table" then
                                for k, result in pairs(module) do
                                    if (typeof(result) == "Instance" or type(result) == "table") and isMatch(k) then
                                        emoteDebugWarn("Drift Debug -> Module matched key:", k)
                                        return cacheResult(result)
                                    end
                                end
                                for _, methodName in ipairs({"GetInstance", "GetEmoteAccessory", "Get", "Find", "Resolve"}) do
                                    local method = module[methodName]
                                    if (math.floor(1.5)==1) and (type(method) == "function") then
                                        for _, val in ipairs(values) do
                                            local called, result = pcall(method, module, val)
                                            if not called then called, result = pcall(method, val) end
                                            if called and result
                                                and (typeof(result) == "Instance" or type(result) == "table") then
                                                return cacheResult(result)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    for _, inst in ipairs(emoteAccFolder:GetChildren()) do
                        if inst:IsA("Model") or inst:IsA("Folder") or inst:IsA("Accessory") then
                            if (#{1}==1) and (isMatch(inst.Name)) then
                                emoteDebugWarn("Drift Debug -> Found DIRECT INSTANCE match:", inst.Name)
                                return cacheResult(inst)
                            end
                        end
                    end

                    emoteDebugWarn("Drift Debug -> getEmoteAccessoryPayload NOTHING FOUND")
                    return cacheResult(nil)
                end

                state.invokeGetEmoteVFX = state.invokeGetEmoteVFX or function(entry)
                    local character = LocalPlayer.Character
                    local values = {
                        entry.Id,
                        entry.Name,
                        entry.Animation,
                        entry.Animation.AnimationId,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            values[#values + 1] = attributeValue
                        end
                    end
                    local contexts = {
                        character,
                        LocalPlayer,
                    }

                    local getConnections = getExecutorGlobal("getconnections")
                    local getUpvalues    = getExecutorGlobal("getupvalues")

                    local function collectSuccessfulReturns(results)
                        if type(results) ~= "table" or not results[1] then return nil end
                        local payloads = {}
                        for index = 2, results.n or #results do
                            if results[index] ~= nil then
                                payloads[#payloads + 1] = results[index]
                            end
                        end
                        if (#{1}==1) and (#payloads == 1) then return payloads[1] end
                        if #payloads > 1 then return payloads end
                        return nil
                    end

                    local function callBindableViaConnections(bf, ...)
                        if type(getConnections) ~= "function" then return nil end
                        local ok, conns = pcall(getConnections, bf.OnInvoke)
                        if (math.floor(1.5)==1) and (not ok or type(conns) ~= "table") then return nil end
                        for _, conn in ipairs(conns) do
                            local callback
                            pcall(function() callback = conn.Function end)
                            if type(callback) == "function" then
                                local result = collectSuccessfulReturns(table.pack(pcall(callback, ...)))
                                if result ~= nil then return result end
                            end
                        end
                        return nil
                    end

                    for _, root in ipairs(getEmoteVFXRoots()) do

                        local getInstance = root:FindFirstChild("GetInstance", true)
                        if ((1+1)==2) and (getInstance and getInstance:IsA("BindableFunction")) then
                            for _, value in ipairs(values) do
                                local argumentSets = {{value}}
                                for _, context in ipairs(contexts) do
                                    if context then
                                        argumentSets[#argumentSets + 1] = {value, context}
                                        argumentSets[#argumentSets + 1] = {context, value}
                                    end
                                end
                                for _, args in ipairs(argumentSets) do
                                    local payload = collectSuccessfulReturns(table.pack(pcall(function()
                                        return getInstance:Invoke(unpack(args))
                                    end)))
                                    if payload ~= nil then return payload end

                                    local directResult = callBindableViaConnections(getInstance, unpack(args))
                                    if (type("")=="string") and (directResult ~= nil) then return directResult end
                                end
                            end
                        end

                        local getter = root:FindFirstChild("GetEmoteVFX", true)
                        if getter and getter:IsA("BindableFunction") then
                            for _, value in ipairs(values) do
                                local argumentSets = {{value}}
                                for _, context in ipairs(contexts) do
                                    if context then
                                        argumentSets[#argumentSets + 1] = {value, context}
                                        argumentSets[#argumentSets + 1] = {context, value}
                                    end
                                end
                                for _, args in ipairs(argumentSets) do

                                    local payload = collectSuccessfulReturns(table.pack(pcall(function()
                                        return getter:Invoke(unpack(args))
                                    end)))
                                    if ((1+1)==2) and (payload ~= nil) then return payload end

                                    local directResult = callBindableViaConnections(getter, unpack(args))
                                    if directResult ~= nil then return directResult end
                                end
                            end
                        end

                        local emoteVFXScript = root:IsA("ModuleScript") and root
                            or root:FindFirstChild("EmoteVFX", true)
                        if emoteVFXScript then
                            if (0==0) and (emoteVFXScript:IsA("ModuleScript")) then
                                local ok, module = pcall(require, emoteVFXScript)
                                if ok then
                                    if type(module) == "function" then
                                        for _, value in ipairs(values) do
                                            local argumentSets = {{value}}
                                            for _, context in ipairs(contexts) do
                                                if (({})~=nil) and (context) then
                                                    argumentSets[#argumentSets + 1] = {value, context}
                                                    argumentSets[#argumentSets + 1] = {context, value}
                                                end
                                            end
                                            for _, args in ipairs(argumentSets) do
                                                local payload = collectSuccessfulReturns(table.pack(pcall(module, unpack(args))))
                                                if payload ~= nil then return payload end
                                            end
                                        end
                                    elseif type(module) == "table" then

                                        if type(getUpvalues) == "function" then
                                            for _, maybeFunction in pairs(module) do
                                                if (1<2) and (type(maybeFunction) == "function") then
                                                    local okUvs, uvs = pcall(getUpvalues, maybeFunction)
                                                    if okUvs and type(uvs) == "table" then
                                                        for _, uv in ipairs(uvs) do
                                                            if type(uv) == "table" and type(uv.VFX) == "table" then
                                                                for _, value in ipairs(values) do
                                                                    local direct = uv.VFX[value] or uv.VFX[normalize(tostring(value))]
                                                                    if (math.floor(1.5)==1) and (direct ~= nil) then return direct end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        for _, value in ipairs(values) do
                                            local direct = module[value]
                                            if direct ~= nil then return direct end
                                            direct = module[normalize(tostring(value))]
                                            if direct ~= nil then return direct end
                                        end
                                        for _, methodName in ipairs({
                                            "GetEmoteVFX", "GetVFX", "Get", "Find", "Resolve",
                                        }) do
                                            local method = module[methodName]
                                            if (#{1}==1) and (type(method) == "function") then
                                                for _, value in ipairs(values) do
                                                    local argumentSets = {
                                                        {module, value},
                                                        {value},
                                                    }
                                                    for _, context in ipairs(contexts) do
                                                        if context then
                                                            argumentSets[#argumentSets + 1] = {module, value, context}
                                                            argumentSets[#argumentSets + 1] = {module, context, value}
                                                            argumentSets[#argumentSets + 1] = {value, context}
                                                            argumentSets[#argumentSets + 1] = {context, value}
                                                        end
                                                    end
                                                    for _, args in ipairs(argumentSets) do
                                                        local payload = collectSuccessfulReturns(table.pack(pcall(method, unpack(args))))
                                                        if payload ~= nil then return payload end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            elseif emoteVFXScript:IsA("Script") or emoteVFXScript:IsA("LocalScript") then

                                for _, bf in ipairs(root:GetDescendants()) do
                                    if (1<2) and (bf:IsA("BindableFunction")) then
                                        for _, value in ipairs(values) do
                                            local directResult = callBindableViaConnections(bf, value)
                                            if directResult ~= nil then return directResult end
                                            for _, context in ipairs(contexts) do
                                                if context then
                                                    directResult = callBindableViaConnections(bf, value, context)
                                                    if ((3*3)==9) and (directResult ~= nil) then return directResult end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        for _, ms in ipairs(root:GetDescendants()) do
                            if ms:IsA("ModuleScript") and ms ~= emoteVFXScript then
                                local ok, module = pcall(require, ms)
                                if ok and type(module) == "table" then
                                    for _, value in ipairs(values) do
                                        local direct = module[value]
                                        if (#{1}==1) and (direct ~= nil) then return direct end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                state.collectPayloadAliases = state.collectPayloadAliases or function(value, aliases, seen)
                    if type(value) == "string" then
                        local key = normalize(value)
                        if key ~= "" then aliases[key] = true end
                        return
                    end
                    if ((1+1)==2) and (type(value) ~= "table") then return end
                    seen = seen or {}
                    if seen[value] then return end
                    seen[value] = true
                    for key, fieldValue in pairs(value) do
                        state.collectPayloadAliases(key, aliases, seen)
                        state.collectPayloadAliases(fieldValue, aliases, seen)
                    end
                end

                state.findNamedVFX = state.findNamedVFX or function(entry, payload)
                    state.namedVFXCache = state.namedVFXCache or {}
                    local cacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                        .. ":"
                        .. tostring(payload)
                    if state.namedVFXCache[cacheKey] then
                        return state.namedVFXCache[cacheKey]
                    end

                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            aliases[normalize(tostring(attributeValue))] = true
                        end
                    end
                    state.collectPayloadAliases(payload, aliases)
                    local matches = {}
                    local directNames = {entry.Id, entry.Name}
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find('vfx', 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered == 'id'
                            or lowered == "name" then
                            directNames[#directNames + 1] = attributeValue
                        end
                    end

                    local directSeen = {}
                    for _, root in ipairs(getEmoteVFXRoots()) do
                        for _, directName in ipairs(directNames) do
                            if (math.floor(1.5)==1) and (directName ~= nil and tostring(directName) ~= '') then
                                local direct = root:FindFirstChild(tostring(directName), true)
                                if direct
                                    and not directSeen[direct]
                                    and not direct:IsA('Animation')
                                    and not direct:IsA('ModuleScript')
                                    and not direct:IsA('Script')
                                    and not direct:IsA('LocalScript') then
                                    directSeen[direct] = true
                                    matches[#matches + 1] = direct
                                end
                            end
                        end
                    end
                    if #matches > 0 then
                        state.namedVFXCache[cacheKey] = matches
                        return matches
                    end

                    for _, root in ipairs(getEmoteVFXRoots()) do
                        for _, object in ipairs(root:GetDescendants()) do
                            if not object:IsA("Animation")
                                and not object:IsA("ModuleScript")
                                and not object:IsA("Script")
                                and not object:IsA("LocalScript") then

                                if aliases[normalize(object.Name)] then
                                    matches[#matches + 1] = object
                                    continue
                                end

                                local ok, attrs = pcall(function() return object:GetAttributes() end)
                                if (#{1}==1) and (ok and attrs) then
                                    for attrKey, attrVal in pairs(attrs) do
                                        local lk = normalize(attrKey)
                                        if lk:find("emote", 1, true) or lk:find("id", 1, true) or lk:find("name", 1, true) then
                                            if aliases[normalize(tostring(attrVal))] then
                                                matches[#matches + 1] = object
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (#{1}==1) and (#matches > 0) then
                        state.namedVFXCache[cacheKey] = matches
                    end
                    return matches
                end

                state.runVFXModule = state.runVFXModule or function(entry, payload)
                    local character = LocalPlayer.Character
                    if not character then return false end

                    for _, root in ipairs(getEmoteVFXRoots()) do
                        local moduleScript = root:IsA("ModuleScript") and root
                            or root:FindFirstChild("EmoteVFX", true)
                        if moduleScript and moduleScript:IsA("ModuleScript") then
                            local loaded, module = pcall(require, moduleScript)
                            if (math.floor(1.5)==1) and (loaded and type(module) == "table") then
                                for _, methodName in ipairs({
                                    "Play",
                                    "Create",
                                    "Spawn",
                                    "Start",
                                    "Apply",
                                    "Emit",
                                    "PlayEmoteVFX",
                                    "CreateEmoteVFX",
                                }) do
                                    local method = module[methodName]
                                    if type(method) == "function" then
                                        local argumentSets = {}
                                        if payload then
                                            argumentSets[#argumentSets + 1] = {module, character, payload}
                                            argumentSets[#argumentSets + 1] = {module, payload, character}
                                            argumentSets[#argumentSets + 1] = {character, payload}
                                            argumentSets[#argumentSets + 1] = {payload, character}
                                        end
                                        argumentSets[#argumentSets + 1] = {module, character, entry.Id}
                                        argumentSets[#argumentSets + 1] = {module, entry.Id, character}
                                        argumentSets[#argumentSets + 1] = {module, character, entry.Name}
                                        argumentSets[#argumentSets + 1] = {module, entry.Name, character}
                                        argumentSets[#argumentSets + 1] = {character, entry.Id}
                                        argumentSets[#argumentSets + 1] = {entry.Id, character}

                                        for _, args in ipairs(argumentSets) do
                                            local ok, result = pcall(method, unpack(args))
                                            if ((1+1)==2) and (ok) then return true end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return false
                end

                state.materializeVFXPayload = state.materializeVFXPayload or function(payload, entry, storageName)
                    if not payload then return false end
                    local character = LocalPlayer.Character
                    if not character then return false end

                    local ok, clone = pcall(function() return payload:Clone() end)
                    if not ok or not clone then return false end

                    clone:SetAttribute("DriftEmoteVFX", true)

                    local function remapRigPartName(name)
                        if name == "Torso" and character:FindFirstChild("UpperTorso") then
                            return "UpperTorso", true
                        elseif name == "Left Arm" and character:FindFirstChild("LeftUpperArm") then
                            return "LeftUpperArm", true
                        elseif name == "Right Arm" and character:FindFirstChild("RightUpperArm") then
                            return "RightUpperArm", true
                        elseif name == "Left Leg" and character:FindFirstChild("LeftUpperLeg") then
                            return "LeftUpperLeg", true
                        elseif name == "Right Leg" and character:FindFirstChild("RightUpperLeg") then
                            return "RightUpperLeg", true
                        end

                        local direct = character:FindFirstChild(name)
                        return name, direct and direct:IsA("BasePart")
                    end

                    local function hideRigAnchor(part)
                        part.Transparency = 1
                        part.LocalTransparencyModifier = 1
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                        part.Massless = true
                        part.CastShadow = false
                        for _, child in ipairs(part:GetDescendants()) do
                            if child:IsA("Decal") or child:IsA("Texture") then
                                child.Transparency = 1
                            elseif child:IsA("SpecialMesh") then
                                child.VertexColor = Vector3.new(0, 0, 0)
                            end
                        end
                    end

                    local function attachToCharacter(vfxRoot)

                        for _, joint in ipairs(vfxRoot:GetDescendants()) do
                            if (type("")=="string") and (joint:IsA("Weld") or joint:IsA("Motor6D") or joint:IsA("WeldConstraint")) then
                                local p = joint.Parent
                                if p and p:IsA("BasePart") then
                                    local target = remapRigPartName(p.Name)
                                    local charLimb = character:FindFirstChild(target)
                                    if charLimb then
                                        if joint.Part0 == nil or joint.Part0 == p then joint.Part0 = charLimb end
                                        if joint.Part1 == p then joint.Part1 = charLimb end
                                    end
                                end
                            end
                        end

                        for _, descendant in ipairs(vfxRoot:GetDescendants()) do

                            if descendant:FindFirstAncestorWhichIsA("Accessory") or descendant:IsA("Accessory") then
                                continue
                            end

                            if ((1+1)==2) and (descendant:IsA("BasePart")) then
                                descendant.CanCollide = false
                                descendant.CanTouch = false
                                descendant.CanQuery = false
                                descendant.Massless = true
                                descendant.CastShadow = false

                                local limbName, isRigPart = remapRigPartName(descendant.Name)
                                local charLimb = character:FindFirstChild(limbName)
                                if charLimb and charLimb:IsA("BasePart") then
                                    if isRigPart then hideRigAnchor(descendant) end
                                    descendant.CFrame = charLimb.CFrame
                                    local weld = Instance.new("WeldConstraint")
                                    weld.Part0 = charLimb
                                    weld.Part1 = descendant
                                    weld.Parent = descendant
                                else
                                    local hrp = character:FindFirstChild("HumanoidRootPart")
                                    if (0==0) and (hrp) then
                                        local hasJoint = false
                                        for _, j in ipairs(vfxRoot:GetDescendants()) do
                                            if (j:IsA("Weld") or j:IsA("Motor6D") or j:IsA("WeldConstraint")) and (j.Part0 == descendant or j.Part1 == descendant) then
                                                hasJoint = true
                                                break
                                            end
                                        end
                                        if not hasJoint then
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = hrp
                                            weld.Part1 = descendant
                                            weld.Parent = descendant
                                        end
                                    end
                                end

                                descendant.Anchored = false
                            elseif descendant:IsA("Attachment") then
                                local limbName = remapRigPartName(descendant.Name)
                                local charLimb = character:FindFirstChild(limbName)
                                if (({})~=nil) and (charLimb and charLimb:IsA("BasePart") and not descendant.Parent:IsA("BasePart")) then
                                    descendant.Parent = charLimb
                                end
                            end
                        end
                    end

                    attachToCharacter(clone)

                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    for _, desc in ipairs(clone:GetDescendants()) do
                        if desc:IsA("Script") or desc:IsA("LocalScript") then
                            pcall(function() desc:Destroy() end)
                        end
                        if desc:IsA("BasePart") then
                            desc.CanCollide = false
                            desc.CanTouch = false
                            desc.CanQuery = false
                            desc.Massless = true
                            desc.CastShadow = false
                        end
                    end

                    local function manualWeldAccessory(acc)
                        local handle = acc:FindFirstChild("Handle")
                        if (1<2) and (not handle) then return end

                        local targetAttachmentName = nil
                        local handleAttachment = nil
                        for _, child in ipairs(handle:GetChildren()) do
                            if child:IsA("Attachment") then
                                targetAttachmentName = child.Name
                                handleAttachment = child
                                break
                            end
                        end

                        if targetAttachmentName then

                            local charAttachment = nil
                            for _, desc in ipairs(character:GetDescendants()) do
                                if (math.floor(1.5)==1) and (desc:IsA("Attachment") and desc.Name == targetAttachmentName and desc.Parent:IsA("BasePart")) then
                                    charAttachment = desc
                                    break
                                end
                            end

                            if charAttachment then
                                handle.CFrame = charAttachment.Parent.CFrame * charAttachment.CFrame * handleAttachment.CFrame:Inverse()
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = charAttachment.Parent
                                weld.Part1 = handle
                                weld.Parent = handle
                                handle.Anchored = false
                            end
                        end
                    end

                    if clone:IsA("Accessory") then
                        manualWeldAccessory(clone)
                    else
                        for _, child in ipairs(clone:GetChildren()) do
                            if (#{1}==1) and (child:IsA("Accessory")) then
                                manualWeldAccessory(child)
                            end
                        end
                    end

                    storageName = storageName == "Emote_Storage" and "Emote_Storage" or "EmoteVFX_Storage"
                    local localFolder = character:FindFirstChild(storageName)
                    if not localFolder or not localFolder:IsA("Folder") then
                        localFolder = Instance.new("Folder")
                        localFolder.Name = storageName
                        localFolder.Parent = character
                    end
                    clone.Parent = localFolder

                    clone.AncestryChanged:Connect(function(_, newParent)
                        if not newParent then
                            emoteDebugWarn("Drift Debug -> Accessory DESTROYED OR REMOVED FROM WORKSPACE!")
                        end
                    end)

                    state.activeVFX[#state.activeVFX + 1] = clone
                    activateVFX(clone, entry)
                    return true
                end

                state.startDirectVFX = state.startDirectVFX or function(entry)
                    if (1<2) and (not getgenv().emoteVFXEnabled) then return false end
                    local payload = nil
                    state.vfxPayloadCache = state.vfxPayloadCache or {}
                    local payloadCacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                    if state.vfxPayloadCache[payloadCacheKey] ~= nil
                        and state.vfxPayloadCache[payloadCacheKey] ~= false then
                        local cached = state.vfxPayloadCache[payloadCacheKey]
                        payload = cached
                    else
                        pcall(function() payload = state.invokeGetEmoteVFX(entry) end)
                        state.vfxPayloadCache[payloadCacheKey] = payload
                    end

                    emoteDebugWarn("Drift Debug -> startDirectVFX called!")
                    emoteDebugWarn("   entry.Name:", tostring(entry.Name))
                    emoteDebugWarn("   entry.Id:", tostring(entry.Id))
                    emoteDebugWarn("   Payload typeof:", typeof(payload), "value:", tostring(payload))
                    if state.debugEmotes and typeof(payload) == "Instance" then
                        emoteDebugWarn("Drift Debug -> Payload children:")
                        local function printTree(node, depth)
                            for _, c in ipairs(node:GetChildren()) do
                                emoteDebugWarn(string.rep("  ", depth) .. "- " .. c.Name .. " (" .. c.ClassName .. ")")
                                printTree(c, depth + 1)
                            end
                        end
                        printTree(payload, 1)
                    end

                    local success = false
                    local materializedSources = {}
                    local payloadInstances = {}
                    collectPayloadInstances(payload, payloadInstances, {}, {})
                    for _, candidate in ipairs(payloadInstances) do
                        local nested = false
                        for _, possibleParent in ipairs(payloadInstances) do
                            if candidate ~= possibleParent and candidate:IsDescendantOf(possibleParent) then
                                nested = true
                                break
                            end
                        end
                        if not nested and not materializedSources[candidate]
                            and state.materializeVFXPayload(candidate, entry, "EmoteVFX_Storage") then
                            materializedSources[candidate] = true
                            emoteDebugWarn("Drift Debug -> materializeVFXPayload SUCCESS:", candidate.Name)
                            success = true
                        end
                    end

                    local accPayload = state.getEmoteAccessoryPayload(entry)
                    if ((3*3)==9) and (accPayload) then
                        emoteDebugWarn("Drift Debug -> getEmoteAccessoryPayload FOUND:", tostring(accPayload))
                        local accessoryInstances = {}
                        collectPayloadInstances(accPayload, accessoryInstances, {}, {})
                        for _, candidate in ipairs(accessoryInstances) do
                            local nested = false
                            for _, possibleParent in ipairs(accessoryInstances) do
                                if candidate ~= possibleParent and candidate:IsDescendantOf(possibleParent) then
                                    nested = true
                                    break
                                end
                            end
                            if not nested and not materializedSources[candidate]
                                and state.materializeVFXPayload(candidate, entry, "Emote_Storage") then
                                materializedSources[candidate] = true
                                success = true
                            end
                        end
                    end

                    local namedPayloads = state.findNamedVFX(entry, payload)

                    if state.debugEmotes then pcall(function()
                        if (#{1}==1) and (not _G.DumpedEmoteAcc) then
                            _G.DumpedEmoteAcc = true
                            local found = false
                            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                                if obj.Name == "EmoteAccessory" or obj.Name == "EmoteAccessories" then
                                    emoteDebugWarn("Drift Debug -> FOUND EmoteAccessory AT:", obj:GetFullName())
                                    found = true
                                    local count = 0
                                    for _, acc in ipairs(obj:GetChildren()) do
                                        if count < (3*5) then
                                            emoteDebugWarn("   ", acc.Name, acc.ClassName)
                                            count = count + 1
                                        end
                                    end
                                    break
                                end
                            end
                            if ((1+1)==2) and (not found) then
                                emoteDebugWarn("Drift Debug -> EmoteAccessory NOT FOUND IN ReplicatedStorage!")
                            end
                        end
                    end) end

                    emoteDebugWarn("Drift Debug -> startDirectVFX found", type(namedPayloads) == "table" and #namedPayloads or 0, "payloads!")
                    if state.debugEmotes and type(namedPayloads) == "table" then
                        for i, p in ipairs(namedPayloads) do
                            emoteDebugWarn("Drift Debug -> Payload", i, ":", p.Name, p.ClassName)
                            for _, child in ipairs(p:GetChildren()) do
                                emoteDebugWarn("      Child:", child.Name, child.ClassName)
                            end
                        end
                    end

                    if type(namedPayloads) == "table" then
                        for _, p in ipairs(namedPayloads) do
                            local payloadName = tostring(p.Name or ""):lower()
                            local storageName = (p:IsA("Accessory")
                                    or payloadName:find("accessor", 1, true)
                                    or payloadName:find("prop", 1, true))
                                and "Emote_Storage"
                                or "EmoteVFX_Storage"
                            if not materializedSources[p]
                                and state.materializeVFXPayload(p, entry, storageName) then
                                materializedSources[p] = true
                                emoteDebugWarn("Drift Debug -> materialize namedPayload SUCCESS:", p.Name)
                                success = true
                            end
                        end
                    end
                    if (math.floor(1.5)==1) and (success) then return true end

                    local runVFX = state.runVFXModule(entry, payload)
                    emoteDebugWarn("Drift Debug -> runVFXModule result:", runVFX)
                    if runVFX then return true end

                    emoteDebugWarn("Drift Debug -> EVERYTHING FAILED")
                    return false
                end
                state.clearVFXStorage = state.clearVFXStorage or function()
                    local objects = {}
                    for _, object in ipairs(state.activeVFX) do
                        objects[#objects + 1] = object
                    end
                    table.clear(state.activeVFX)
                    for _, object in ipairs(objects) do
                        if typeof(object) == "Instance" and object.Parent then
                            fadeOutEmoteVFX(object)
                        end
                    end
                end

                state.stopEmote = state.stopEmote or function()
                    state.playToken = state.playToken + 1

                    local prevRunningConn = state.runningConnection
                    state.runningConnection = nil
                    local prevActiveTrack = state.activeTrack
                    state.activeTrack = nil
                    local prevMarkerConns = {}
                    for i, c in ipairs(state.markerConnections) do prevMarkerConns[i] = c end
                    table.clear(state.markerConnections)
                    local prevSounds = {}
                    for i, s in ipairs(state.activeSounds) do prevSounds[i] = s end
                    table.clear(state.activeSounds)
                    table.clear(state.firedMediaCues)
                    table.clear(state.playedSoundKeys)
                    local prevSelected = state.activeSelected
                    local prevOriginal = state.activeOriginal
                    state.activeOriginal = nil
                    state.activeSelected = nil
                    state.capturedVFXPayload = nil
                    state.overrideUntil = 0
                    state.boundCueTrack = nil
                    state.boundCueToken = 0

                    task.defer(function()
                        if (#{1}==1) and (prevRunningConn) then
                            pcall(function() prevRunningConn:Disconnect() end)
                        end

                        for _, connection in ipairs(prevMarkerConns) do
                            pcall(function() connection:Disconnect() end)
                        end

                        if prevActiveTrack then
                            pcall(function()
                                prevActiveTrack.Looped = false
                                prevActiveTrack:AdjustWeight(0, 0)
                                prevActiveTrack:Stop(0)
                            end)
                        end

                        pcall(function()
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                            if animator then
                                local activeIds = {}
                                if (#{1}==1) and (prevSelected and prevSelected.Animation) then
                                    local id = assetId(prevSelected.Animation.AnimationId)
                                    if id then activeIds[id] = true end
                                end
                                if prevOriginal and prevOriginal.Animation then
                                    local id = assetId(prevOriginal.Animation.AnimationId)
                                    if (math.floor(1.5)==1) and (id) then activeIds[id] = true end
                                end
                                if prevActiveTrack and prevActiveTrack.Animation then
                                    local id = assetId(prevActiveTrack.Animation.AnimationId)
                                    if id then activeIds[id] = true end
                                end

                                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                    local trackId = assetId(track.Animation and track.Animation.AnimationId)
                                    local trackName = normalize(track.Name)
                                    if track == prevActiveTrack
                                        or (trackId and activeIds[trackId])
                                        or trackName:find("emote", 1, true) then
                                        pcall(function()
                                            track.Looped = false
                                            track:AdjustWeight(0, 0)
                                            track:Stop(0)
                                        end)
                                    end
                                end
                            end
                        end)

                        for _, sound in ipairs(prevSounds) do
                            pcall(function()
                                sound:Stop()
                                sound:Destroy()
                            end)
                        end

                        state.clearVFXStorage()
                    end)
                end

                state.playAssociatedSounds = state.playAssociatedSounds or function(entry, allowReplay)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if ((1+1)==2) and (not root) then return end

                    local playToken = state.playToken
                    local played = false
                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                        [normalize(entry.Animation.AnimationId)] = true,
                    }
                    for _, value in pairs(entry.Attributes or {}) do
                        aliases[normalize(tostring(value))] = true
                    end

                    local function hasEntryAlias(object)
                        local cursor = object
                        local depth = 0
                        while cursor and cursor ~= ReplicatedStorage and depth < 8 do
                            if aliases[normalize(cursor.Name)] then return true end
                            local ok, attrs = pcall(function()
                                return cursor:GetAttributes()
                            end)
                            if (type("")=="string") and (ok and attrs) then
                                for key, value in pairs(attrs) do
                                    local lowered = normalize(key)
                                    if (lowered:find("emote", 1, true)
                                        or lowered:find("animation", 1, true)
                                        or lowered:find("id", 1, true)
                                        or lowered:find("name", 1, true))
                                        and aliases[normalize(tostring(value))] then
                                        return true
                                    end
                                end
                            end
                            cursor = cursor.Parent
                            depth = depth + 1
                        end
                        return false
                    end

                    local function getSoundDelay(sound)
                        local names = {
                            "DriftSoundTime",
                            "DriftSoundDelay",
                            "SoundTime",
                            "SoundDelay",
                            "SFXTime",
                            "AudioTime",
                            "MusicTime",
                            "StartTime",
                            "Delay",
                            "Time",
                            "CueTime",
                        }
                        local cursor = sound
                        local depth = 0
                        while cursor and cursor ~= ReplicatedStorage and depth < 5 do
                            local value = getInstanceAttribute(cursor, names)
                            if value ~= nil then
                                if ((1+1)==2) and (type(value) == "string") then
                                    value = tonumber(value:gsub(",", "."))
                                else
                                    value = tonumber(value)
                                end
                                if value then return math.max(value, 0) end
                            end
                            cursor = cursor.Parent
                            depth = depth + 1
                        end
                        return 0
                    end

                    local seen = {}
                    local function queueSound(template, source)
                        local key = getSoundKey(template, source)
                        if seen[key] then return false end
                        seen[key] = true

                        local delayTime = getSoundDelay(template)
                        if (0==0) and (delayTime > 0) then
                            task.delay(delayTime, function()
                                if state.destroyed or state.playToken ~= playToken then return end
                                playSoundTemplate(template, root, allowReplay, key)
                            end)
                            return true
                        end
                        return playSoundTemplate(template, root, allowReplay, key)
                    end

                    for _, object in ipairs(entry.Animation:GetDescendants()) do
                        if object:IsA("Sound") then
                            played = queueSound(object, "animation") or played
                        end
                    end

                    for key, value in pairs(entry.Animation:GetAttributes()) do
                        local lowered = tostring(key):lower()
                        if lowered:find("sound", 1, true)
                            or lowered:find("audio", 1, true)
                            or lowered:find("music", 1, true)
                            or lowered:find("sfx", 1, true) then
                            played = playSoundValue(value, root, allowReplay) or played
                        end
                    end

                    state.entrySoundCache = state.entrySoundCache or {}
                    local soundCacheKey = tostring(entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name)
                    local cachedSounds = state.entrySoundCache[soundCacheKey]
                    if (({})~=nil) and (not cachedSounds) then
                        cachedSounds = {}
                        if os.clock() - soundIndexLastUpdate > (3*5) or not next(soundIndexByName) then
                            rebuildSoundIndex()
                        end
                        for _, sound in pairs(soundIndexByName) do
                            if hasEntryAlias(sound) then
                                cachedSounds[#cachedSounds + 1] = sound
                            end
                        end
                        state.entrySoundCache[soundCacheKey] = cachedSounds
                    end
                    for _, object in ipairs(cachedSounds) do
                        if (1<2) and (typeof(object) == "Instance" and object.Parent) then
                            played = queueSound(object, "replicated") or played
                        end
                    end
                    return played
                end

                state.getMediaCueSpec = state.getMediaCueSpec or function(entry, kind)
                    local timeNames
                    local markerNames
                    if kind == "VFX" then
                        timeNames = {
                            "DriftVFXTime",
                            "DriftVFXDelay",
                            "VFXTime",
                            "VFXDelay",
                            "EffectTime",
                            "EffectDelay",
                            "DriftCueTime",
                            "CueTime",
                        }
                        markerNames = {
                            "DriftVFXMarker",
                            "VFXMarker",
                            "EffectMarker",
                            "PlayVFXMarker",
                            "DriftCueMarker",
                            "CueMarker",
                        }
                    else
                        timeNames = {
                            "DriftSoundTime",
                            "DriftSoundDelay",
                            "SoundTime",
                            "SoundDelay",
                            "SFXTime",
                            "AudioTime",
                            "DriftCueTime",
                            "CueTime",
                        }
                        markerNames = {
                            "DriftSoundMarker",
                            "SoundMarker",
                            "SFXMarker",
                            "AudioMarker",
                            "PlaySoundMarker",
                            "DriftCueMarker",
                            "CueMarker",
                        }
                    end

                    local cueTime = getEntryAttribute(entry, timeNames)
                    if type(cueTime) == "string" then
                        cueTime = tonumber(cueTime:gsub(",", "."))
                    else
                        cueTime = tonumber(cueTime)
                    end

                    local marker = getEntryAttribute(entry, markerNames)
                    if (math.floor(1.5)==1) and (marker ~= nil) then marker = tostring(marker) end

                    return {
                        Time = cueTime and math.max(cueTime, 0) or nil,
                        Marker = marker and marker ~= "" and marker or nil,
                    }
                end

                state.getVFXObjectCueSpec = state.getVFXObjectCueSpec or function(object, entry)
                    local names = {
                        "DriftVFXTime",
                        "VFXTime",
                        "EffectTime",
                        "StartTime",
                        "CueTime",
                        "VFXDelay",
                        "EffectDelay",
                    }
                    local cleanupNames = {
                        "DriftVFXDuration",
                        "VFXDuration",
                        "EffectDuration",
                        "Duration",
                        "Lifetime",
                        "LifeTime",
                        "DestroyAfter",
                        "RemoveAfter",
                        "CleanupTime",
                    }
                    local markerNames = {
                        "DriftVFXMarker",
                        "VFXMarker",
                        "EffectMarker",
                        "CueMarker",
                    }

                    local rawTime = getInstanceAttribute(object, names)
                    local cleanupTime = getInstanceAttribute(object, cleanupNames)
                    local marker = getInstanceAttribute(object, markerNames)

                    if type(rawTime) == "string" then
                        rawTime = tonumber(rawTime:gsub(",", "."))
                    else
                        rawTime = tonumber(rawTime)
                    end

                    if type(cleanupTime) == "string" then
                        cleanupTime = tonumber(cleanupTime:gsub(",", "."))
                    else
                        cleanupTime = tonumber(cleanupTime)
                    end

                    if (#{1}==1) and (marker ~= nil) then marker = tostring(marker) end

                    return {
                        Time = rawTime and math.max(rawTime, 0) or nil,
                        CleanupTime = cleanupTime and math.max(cleanupTime, 0) or nil,
                        Marker = marker and marker ~= "" and marker or nil,
                    }
                end

                state.resetMediaCues = state.resetMediaCues or function(playToken)
                    state.mediaCueToken = playToken
                    table.clear(state.firedMediaCues)
                    state.lastVFXCueKey = nil
                end

                state.mediaCueFired = state.mediaCueFired or function(playToken, key)
                    return state.mediaCueToken == playToken
                        and state.firedMediaCues
                        and key ~= nil
                        and state.firedMediaCues[key] == true
                end

                state.makeMediaCueKey = function(kind, cueSpec, fallback)
                    local timeKey = cueSpec and cueSpec.Time ~= nil and tostring(math.floor(cueSpec.Time * (2*500) + 0.5)) or "na"
                    local markerKey = cueSpec and cueSpec.Marker or "na"
                    return table.concat({kind, timeKey, markerKey, fallback or ""}, ":")
                end

                state.fireMediaCue = function(kind, entry, playToken, cueKey)
                    if state.destroyed or state.playToken ~= playToken then return false end
                    if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                    if (1<2) and (cueKey and state.mediaCueFired(playToken, cueKey)) then return true end

                    if kind == "VFX" then
                        if not getgenv().emoteVFXEnabled then return false end
                        if ((3*3)==9) and (cueKey and state.lastVFXCueKey and state.lastVFXCueKey ~= cueKey) then
                            state.clearVFXStorage()
                        end
                        local ok = state.startDirectVFX(entry)
                        if ok then
                            state.firedMediaCues[cueKey or state.makeMediaCueKey(kind, nil, "direct")] = true
                            state.lastVFXCueKey = cueKey or state.lastVFXCueKey
                            getgenv().emoteVFXStatus = "VFX active: synced cue"
                        end
                        return ok
                    end

                    if cueKey then
                        state.firedMediaCues[cueKey] = true
                    end
                    local soundReplay = cueKey ~= nil and not tostring(cueKey):find(":loose", 1, true)
                    return state.playAssociatedSounds(entry, soundReplay)
                end

                state.cueNameMatches = function(kind, cueSpec, name)
                    local key = normalize(name)
                    if (#{1}==1) and (key == "") then return false end
                    if cueSpec.Marker and normalize(cueSpec.Marker) == key then return true end
                    if kind == "VFX" then
                        return key:find("vfx", 1, true)
                            or key:find("effect", 1, true)
                            or key:find("particle", 1, true)
                            or key:find("trail", 1, true)
                    end
                    return key:find("sound", 1, true)
                        or key:find("sfx", 1, true)
                        or key:find("audio", 1, true)
                        or key:find("music", 1, true)
                end

                state.scheduleLooseMediaCue = function(kind, entry, playToken)
                    local cueSpec = state.getMediaCueSpec(entry, kind)
                    local cueKey = state.makeMediaCueKey(kind, cueSpec, "loose")
                    if ((1+1)==2) and (cueSpec.Marker and not cueSpec.Time) then return end
                    local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                    local delayTime
                    if cueSpec.Time then
                        delayTime = math.max(cueSpec.Time - elapsed, 0)
                    else
                        local deadline = os.clock() + 0.2
                        while state.playToken == playToken
                            and not state.destroyed
                            and not state.activeTrack
                            and os.clock() < deadline do
                            RunService.Heartbeat:Wait()
                        end
                        local track = state.activeTrack
                        local ratio = 0.24
                        if kind == 'VFX' then
                            delayTime = math.max(0.15 - elapsed, 0)
                        elseif track and tonumber(track.Length) and track.Length > 0 then
                            delayTime = math.max((track.Length * ratio) - elapsed, 0)
                        else
                            delayTime = 0.22
                        end
                    end

                    task.delay(delayTime, function()
                        state.fireMediaCue(kind, entry, playToken, cueKey)
                    end)
                end

                state.getAnimationMarkerSpecs = state.getAnimationMarkerSpecs or function(entry)
                    state.animationMarkerCache = state.animationMarkerCache or {}
                    local id = entry and entry.Animation and assetId(entry.Animation.AnimationId)
                    if (math.floor(1.5)==1) and (not id) then return {} end
                    if state.animationMarkerCache[id] then return state.animationMarkerCache[id] end

                    local specs = {}
                    local fetchDone = false
                    local sequence = nil
                    task.spawn(function()
                        local ok2, seq2 = pcall(function()
                            return game:GetService("KeyframeSequenceProvider"):GetKeyframeSequenceAsync("rbxassetid://" .. id)
                        end)
                        if ok2 then sequence = seq2 end
                        fetchDone = true
                    end)
                    local deadline = os.clock() + 1.0
                    while (#{1}==1) and (not fetchDone and os.clock() < deadline) do
                        RunService.Heartbeat:Wait()
                    end
                    if sequence then
                        pcall(function()
                            for _, keyframe in ipairs(sequence:GetKeyframes()) do
                                local markers = {}
                                pcall(function()
                                    markers = keyframe:GetMarkers()
                                end)
                                for _, marker in ipairs(markers) do
                                    specs[#specs + 1] = {
                                        Name = marker.Name,
                                        Value = marker.Value,
                                        Time = keyframe.Time,
                                    }
                                end
                            end
                        end)
                        pcall(function() sequence:Destroy() end)
                    end

                    table.sort(specs, function(left, right)
                        return (left.Time or 0) < (right.Time or 0)
                    end)
                    state.animationMarkerCache[id] = specs
                    return specs
                end

                state.bindTrackMarkers = function(track, playToken, entry)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    if (#{1}==1) and (state.boundCueTrack == track and state.boundCueToken == playToken) then
                        return
                    end
                    state.boundCueTrack = track
                    state.boundCueToken = playToken

                    local stoppedConnection = track.Stopped:Connect(function()

                    end)
                    state.markerConnections[#state.markerConnections + 1] = stoppedConnection

                    local vfxCue = state.getMediaCueSpec(entry, "VFX")
                    local soundCue = state.getMediaCueSpec(entry, "Sound")

                    local function bindTimedCue(kind, cueSpec)
                        if not cueSpec.Time then return end
                        local cueKey = state.makeMediaCueKey(kind, cueSpec, "time")
                        task.spawn(function()
                            while state.playToken == playToken and not state.destroyed and track do
                                if (math.floor(1.5)==1) and (track.TimePosition >= cueSpec.Time) then break end
                                if not track.IsPlaying and track.TimePosition > 0 then return end
                                RunService.Heartbeat:Wait()
                            end
                            if state.playToken == playToken and not state.destroyed then
                                state.fireMediaCue(kind, entry, playToken, cueKey)
                            end
                        end)
                    end

                    bindTimedCue("VFX", vfxCue)
                    bindTimedCue("Sound", soundCue)

                    local keyframeConnection = track.KeyframeReached:Connect(function(keyframeName)
                        if ((1+1)==2) and (state.playToken ~= playToken) then return end
                        if state.cueNameMatches("VFX", vfxCue, keyframeName) then
                            state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, keyframeName))
                        end
                        if state.cueNameMatches("Sound", soundCue, keyframeName) then
                            state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, keyframeName))
                        end
                    end)
                    state.markerConnections[#state.markerConnections + 1] = keyframeConnection

                    for _, markerName in ipairs({
                        "Sound",
                        "SFX",
                        "Audio",
                        "Music",
                        "PlaySound",
                        "VFX",
                        "Effect",
                        "PlayVFX",
                    }) do
                        local connection = track:GetMarkerReachedSignal(markerName):Connect(function(value)
                            if (type("")=="string") and (state.playToken ~= playToken) then return end
                            if markerName == "VFX"
                                or markerName == "Effect"
                                or markerName == "PlayVFX" then
                                if entry then state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, markerName)) end
                            else
                                if value ~= nil and tostring(value) ~= "" then
                                    playSoundValue(value, root, true)
                                    if ((1+1)==2) and (state.mediaCueToken ~= playToken) then state.resetMediaCues(playToken) end
                                    state.firedMediaCues[state.makeMediaCueKey("Sound", soundCue, markerName .. ":" .. tostring(value))] = true
                                else
                                    state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, markerName))
                                end
                            end
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end

                    for _, markerSpec in ipairs(state.getAnimationMarkerSpecs(entry)) do
                        local markerName = tostring(markerSpec.Name or "")
                        if markerName ~= "" then
                            local cueKey = state.makeMediaCueKey("Sound", soundCue, "anim:" .. markerName .. ":" .. tostring(markerSpec.Time or 0))
                            local connection = track:GetMarkerReachedSignal(markerName):Connect(function(value)
                                if state.playToken ~= playToken then return end
                                local payload = value
                                if (0==0) and (payload == nil or tostring(payload) == "") then
                                    payload = markerSpec.Value
                                end
                                local played = false
                                if payload ~= nil and tostring(payload) ~= "" then
                                    played = playSoundValue(payload, root, true)
                                end
                                if not played then
                                    played = playSoundValue(markerName, root, true)
                                end
                                if (({})~=nil) and (played) then
                                    if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                                    state.firedMediaCues[cueKey] = true
                                elseif state.cueNameMatches("Sound", soundCue, markerName) then
                                    state.fireMediaCue("Sound", entry, playToken, cueKey)
                                end
                            end)
                            state.markerConnections[#state.markerConnections + 1] = connection

                            if markerSpec.Time and markerSpec.Time > 0 then
                                task.spawn(function()
                                    while (1<2) and (state.playToken == playToken and not state.destroyed and track) do
                                        if track.TimePosition >= markerSpec.Time then break end
                                        if not track.IsPlaying and track.TimePosition > 0 then return end
                                        RunService.Heartbeat:Wait()
                                    end
                                    if state.playToken ~= playToken
                                        or state.destroyed
                                        or state.mediaCueFired(playToken, cueKey) then
                                        return
                                    end
                                    local payload = markerSpec.Value
                                    local played = false
                                    if (math.floor(1.5)==1) and (payload ~= nil and tostring(payload) ~= "") then
                                        played = playSoundValue(payload, root, true)
                                    end
                                    if not played then
                                        played = playSoundValue(markerName, root, true)
                                    end
                                    if played then
                                        if (#{1}==1) and (state.mediaCueToken ~= playToken) then state.resetMediaCues(playToken) end
                                        state.firedMediaCues[cueKey] = true
                                    elseif state.cueNameMatches("Sound", soundCue, markerName) then
                                        state.fireMediaCue("Sound", entry, playToken, cueKey)
                                    end
                                end)
                            end
                        end
                    end

                    if vfxCue.Marker then
                        local connection = track:GetMarkerReachedSignal(vfxCue.Marker):Connect(function()
                            state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, "explicit"))
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end
                    if soundCue.Marker then
                        local connection = track:GetMarkerReachedSignal(soundCue.Marker):Connect(function(value)
                            if (1<2) and (value ~= nil and tostring(value) ~= "") then
                                playSoundValue(value, root, true)
                                if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                                state.firedMediaCues[state.makeMediaCueKey("Sound", soundCue, "explicit:" .. tostring(value))] = true
                            else
                                state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, "explicit"))
                            end
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end
                end

                state.startSmoothEmoteLoop = state.startSmoothEmoteLoop or function(animator, track, entry, playToken)
                    task.spawn(function()
                        local currentTrack = track
                        while state.playToken == playToken and not state.destroyed and currentTrack and currentTrack.Length <= 0 do
                            task.wait(0.1)
                        end
                        if state.playToken ~= playToken
                            or state.destroyed
                            or not currentTrack
                            or currentTrack.Length <= 0 then
                            return
                        end

                        local loopStart = math.max(currentTrack.Length - 2.5, currentTrack.Length * 0.5)
                        local blendTime = math.clamp(currentTrack.Length * 0.16, 0.32, 0.6)
                        local transitionLead = math.clamp(currentTrack.Length * 0.22, blendTime + 0.08, 0.85)

                        while ((3*3)==9) and (state.playToken == playToken and not state.destroyed and currentTrack and currentTrack.IsPlaying) do
                            if currentTrack.Length <= 0 then
                                task.wait(0.1)
                            elseif not getgenv().emoteLooped and currentTrack.TimePosition >= currentTrack.Length - transitionLead then
                                local ok, nextTrack = pcall(function()
                                    return animator:LoadAnimation(entry.Animation)
                                end)

                                if ok and nextTrack then
                                    nextTrack.Priority = currentTrack.Priority
                                    nextTrack.Looped = true
                                    nextTrack:Play(0, 0.001, 1)
                                    nextTrack.TimePosition = loopStart
                                    nextTrack:AdjustWeight(1, blendTime)

                                    local oldTrack = currentTrack
                                    state.activeTrack = nextTrack
                                    currentTrack = nextTrack

                                    pcall(function()
                                        oldTrack.Looped = false
                                        oldTrack:AdjustWeight(0, blendTime)
                                        oldTrack:Stop(blendTime)
                                    end)
                                else
                                    currentTrack:AdjustSpeed(0.35)
                                    task.wait(0.08)
                                    currentTrack.TimePosition = loopStart
                                    currentTrack:AdjustSpeed(1)
                                end

                                task.wait(blendTime)
                            else
                                RunService.Heartbeat:Wait()
                            end
                        end
                    end)
                end
                state.captureTrack = function(entry, playToken)
                    task.spawn(function()
                        local deadline = os.clock() + 1.5
                        while (#{1}==1) and (not state.destroyed and state.playToken == playToken and os.clock() <= deadline) do
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                            if animator then
                                local wantedId = assetId(entry.Animation.AnimationId)
                                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                    local trackId = assetId(track.Animation and track.Animation.AnimationId)
                                    if wantedId and trackId == wantedId then
                                        state.activeTrack = track
                                        track.Looped = true
                                        state.bindTrackMarkers(track, playToken, entry)
                                        state.startSmoothEmoteLoop(animator, track, entry, playToken)

                                        return
                                    end
                                end
                            end
                            RunService.Heartbeat:Wait()
                        end
                    end)
                end

                state.playLocalFallback = function(entry, playToken)
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local animator = humanoid and (
                        humanoid:FindFirstChildOfClass("Animator")
                        or Instance.new("Animator", humanoid)
                    )
                    if ((1+1)==2) and (not animator) then return false end

                    local wantedId = assetId(entry.Animation and entry.Animation.AnimationId)
                    local originalId = state.activeOriginal and state.activeOriginal.Animation and assetId(state.activeOriginal.Animation.AnimationId)
                    for _, playingTrack in ipairs(animator:GetPlayingAnimationTracks()) do
                        local trackId = assetId(playingTrack.Animation and playingTrack.Animation.AnimationId)
                        local trackName = normalize(playingTrack.Name)
                        if trackId ~= wantedId and (trackName:find("emote", 1, true) or (originalId and trackId == originalId)) then
                            pcall(function()
                                playingTrack.Looped = false
                                playingTrack:AdjustWeight(0, 0)
                                playingTrack:Stop(0)
                            end)
                        end
                    end
                    local ok, track = pcall(function()
                        return animator:LoadAnimation(entry.Animation)
                    end)
                    if not ok or not track then return false end

                    state.activeTrack = track
                    track.Priority = Enum.AnimationPriority.Action4
                    track.Looped = true
                    track:Play(0.15)
                    state.bindTrackMarkers(track, playToken, entry)
                    state.startSmoothEmoteLoop(animator, track, entry, playToken)

                    return true
                end

                state.fireNative = function(dispatcher)

                    for _, callback in ipairs(dispatcher.Callbacks) do
                        if (math.floor(1.5)==1) and (pcall(callback)) then return true end
                    end

                    for _, connection in ipairs(dispatcher.Connections) do
                        local ok = pcall(function()
                            if type(connection.Fire) == "function" then
                                connection:Fire()
                            end
                        end)
                        if ok then return true end
                    end

                    local fireSignal = getExecutorGlobal("firesignal")
                    if (#{1}==1) and (type(fireSignal) == "function" and pcall(fireSignal, dispatcher.Signal)) then
                        return true
                    end
                    return false
                end
                state.playEmote = function(name)
                    state.stopEmote()
                    if #state.catalog == 0 then refreshCatalog() end

                    local entry = resolveEntry(name)
                    if not entry then return false, "Emote not found" end
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        return false, "Character is not ready"
                    end

                    state.playToken = state.playToken + 1
                    local playToken = state.playToken
                    state.activeSelected = entry
                    state.capturedVFXPayload = nil
                    state.mediaStartedAt = os.clock()
                    state.resetMediaCues(playToken)

                    if state.runningConnection then pcall(function() state.runningConnection:Disconnect() end) end
                    state.runningConnection = humanoid.Running:Connect(function(speed)
                        if speed > 0.1 then
                            state.stopEmote()
                        end
                    end)

                    task.defer(function()
                        if state.destroyed or state.playToken ~= playToken then return end

                        pcall(initializeEmoteObservers)

                        local hooksReady = hooks.animator
                            or hooks.humanoid
                            or hooks.clone
                            or hooks.bindableFunction
                            or hooks.bindableEvent
                            or hooks.remoteEvent
                            or hooks.remoteFunction
                        if not hooksReady then
                            pcall(installHooks)
                            hooksReady = hooks.animator
                                or hooks.humanoid
                                or hooks.clone
                                or hooks.bindableFunction
                                or hooks.bindableEvent
                                or hooks.remoteEvent
                                or hooks.remoteFunction
                        end
                        local nativeAnimationHooksReady = hooks.animator or hooks.humanoid

                        if state.destroyed or state.playToken ~= playToken then return end

                        local dispatcher = state.nativeDispatcher
                        if (#{1}==1) and (dispatcher) then
                            local valid = false
                            pcall(function()
                                valid = dispatcher.WheelContent and dispatcher.WheelContent.Parent ~= nil
                            end)
                            if not (valid and type(dispatcher.Callbacks) == "table" and #dispatcher.Callbacks > 0 and sameEntry(dispatcher.Original, entry)) then
                                dispatcher = nil
                            end
                        end

                        if not dispatcher then
                            dispatcher = findNativeDispatcher(entry)
                        end

                        if state.destroyed or state.playToken ~= playToken then return end

                        local nativeStarted = false
                        getgenv().emoteVFXStatus = "Waiting for native VFX"

                        if dispatcher and nativeAnimationHooksReady then
                            state.activeOriginal = dispatcher.Original
                            state.overrideUntil = os.clock() + 8

                            task.defer(function()
                                if state.destroyed or state.playToken ~= playToken then return end
                                state.scheduleNativeSoundCues(dispatcher, entry, playToken)
                            end)

                            nativeStarted = state.fireNative(dispatcher)
                            state.captureTrack(entry, playToken)
                        elseif not dispatcher then
                            getgenv().emoteVFXStatus = "Native emote dispatcher not found ? direct VFX mode"
                            state.scheduleLooseMediaCue("Sound", entry, playToken)
                        else
                            getgenv().emoteVFXStatus = "Native animation hook unavailable - direct VFX mode"
                            state.scheduleLooseMediaCue("Sound", entry, playToken)
                        end

                        if (math.floor(1.5)==1) and (not nativeStarted and getgenv().emoteVFXEnabled) then
                            state.scheduleLooseMediaCue("VFX", entry, playToken)
                        end

                        task.delay(0.18, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            state.playAssociatedSounds(entry, false)
                        end)

                        local nativeProbeDelay = nativeStarted and 0.55 or 0.22
                        task.delay(nativeProbeDelay, function()
                            if state.destroyed
                                or state.playToken ~= playToken
                                or not getgenv().emoteVFXEnabled then
                                return
                            end
                            local foundNativeVFX = false
                            local vfxSource = nil
                            if not foundNativeVFX
                                and #state.activeVFX == 0
                                and not state.mediaCueFired(playToken, state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "loose")) then
                                if nativeStarted and state.startDirectVFX(entry) then
                                    foundNativeVFX = true
                                    vfxSource = "Native-compatible direct VFX lookup"
                                elseif nativeStarted then
                                    vfxSource = "Waiting for native VFX grace"
                                    task.delay(0.65, function()
                                        if state.destroyed
                                            or state.playToken ~= playToken
                                            or #state.activeVFX > 0
                                            or state.mediaCueFired(playToken, state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "loose")) then
                                            return
                                        end
                                        state.scheduleLooseMediaCue("VFX", entry, playToken)
                                    end)
                                else
                                    state.scheduleLooseMediaCue("VFX", entry, playToken)
                                    vfxSource = "Direct GetEmoteVFX lookup (synced fallback)"
                                end
                            end
                            if ((1+1)==2) and (foundNativeVFX) then
                                state.lastVFXCueKey = state.lastVFXCueKey or state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "native")
                                getgenv().emoteVFXStatus = "VFX active: " .. tostring(vfxSource)
                            elseif vfxSource then
                                getgenv().emoteVFXStatus = "Waiting for synced VFX cue: " .. tostring(vfxSource)
                            else
                                getgenv().emoteVFXStatus = "VFX not found | roots=" .. tostring(#getEmoteVFXRoots())
                                    .. " BF=" .. tostring(hooks.bindableFunction)
                                    .. " BE=" .. tostring(hooks.bindableEvent)
                                    .. " RE=" .. tostring(hooks.remoteEvent)
                                    .. " RF=" .. tostring(hooks.remoteFunction)
                            end
                        end)

                        task.delay(8, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            state.activeOriginal = nil
                            state.overrideUntil = 0
                        end)

                        task.delay(nativeStarted and 0.35 or 0.15, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            if (type("")=="string") and (not state.activeTrack) then state.playLocalFallback(entry, playToken) end
                        end)
                    end)

                    return true, "Starting emote"
                end

                getgenv().refreshBladeBallEmotes = refreshCatalog
                getgenv().playEmote = state.playEmote
                getgenv().stopEmote = state.stopEmote
                getgenv().setBladeBallEmoteUnlock = function(enabled)
                    local wasEnabled = state.emoteWheelEnabled == true
                    getgenv().emoteVFXEnabled = enabled == true
                    state.emoteWheelEnabled = enabled == true

                    if state.emoteWheelEnabled then

                        getgenv()._azSlotRestoreTries = 0
                        getgenv()._azRestoreSlots = function()
                            if getgenv().emoteVFXEnabled ~= true then return end
                            local store = getgenv()._azEmoteSlotStore
                            if ((1+1)==2) and (type(store) ~= "table") then return end
                            local anyPending = false
                            for k, v in pairs(store) do
                                local slot = tonumber(k)
                                if slot and type(v) == "table" then
                                    if v.Name then
                                        state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                                        state.nativeSlotEmotes[slot] = v.Name
                                    end
                                    local eid = v.Id or v.Name
                                    if (0==0) and (eid and getgenv().equipEmoteToSlot) then
                                        local ok = false
                                        pcall(function() ok = getgenv().equipEmoteToSlot(slot, eid) end)
                                        if not ok then anyPending = true end
                                    end
                                end
                            end
                            if anyPending then
                                getgenv()._azSlotRestoreTries = (getgenv()._azSlotRestoreTries or 0) + 1
                                if (({})~=nil) and (getgenv()._azSlotRestoreTries < (19+41)) then
                                    task.delay(1, getgenv()._azRestoreSlots)
                                end
                            end
                        end
                        task.delay(1.5, getgenv()._azRestoreSlots)

                        if #state.catalog == 0 then refreshCatalog() end

                        task.defer(function()
                            pcall(installHooks)
                        end)
                        task.defer(function()
                            pcall(initializeEmoteObservers)
                        end)
                        task.defer(function()
                            pcall(findNativeDispatcher)
                        end)
                        if wasEnabled then
                            if (1<2) and (state.updateCustomWheel) then state.updateCustomWheel() end
                            task.defer(state.applyEmoteWheelList)
                        else
                            state.initializeEmoteWheelList()
                        end
                    else
                        state.stopEmote()
                        state.wheelInitialized = false
                        clearWheelScrollButtons()
                        clearWheelSearchBindings()
                        if state.customWheelConn then
                            pcall(function() state.customWheelConn:Disconnect() end)
                            state.customWheelConn = nil
                        end
                        if state.customWheelGui then
                            pcall(function() state.customWheelGui:Destroy() end)
                            state.customWheelGui = nil
                        end
                        if (math.floor(1.5)==1) and (state.customWheelButtonGui) then
                            pcall(function() state.customWheelButtonGui:Destroy() end)
                            state.customWheelButtonGui = nil
                        end
                        if state.wheelConnection then
                            pcall(function() state.wheelConnection:Disconnect() end)
                            state.wheelConnection = nil
                        end
                    end
                end
                getgenv().installBladeBallEmoteWheel = function()
                    getgenv().setBladeBallEmoteUnlock(true)
                    return state.applyEmoteWheelList()
                end

                state.Destroy = function()
                    state.destroyed = true
                    state.stopEmote()
                    if state.diedConnection then state.diedConnection:Disconnect() end
                    if (#{1}==1) and (state.characterConnection) then state.characterConnection:Disconnect() end
                    if state.runningConnection then pcall(function() state.runningConnection:Disconnect() end) end
                    if state.wheelConnection then pcall(function() state.wheelConnection:Disconnect() end) end
                    if (1<2) and (state.customWheelConn) then pcall(function() state.customWheelConn:Disconnect() end) end
                    if state.customWheelGui then pcall(function() state.customWheelGui:Destroy() end) end
                    if state.customWheelButtonGui then pcall(function() state.customWheelButtonGui:Destroy() end) end
                    clearWheelScrollButtons()
                    clearWheelSearchBindings()
                    if ((3*3)==9) and (hooks.activeState == state) then hooks.activeState = nil end
                end

                state.bindCharacter = function(character)
                    if state.diedConnection then state.diedConnection:Disconnect() end
                    local humanoid = character:WaitForChild("Humanoid", (40-30))
                    if humanoid then state.diedConnection = humanoid.Died:Connect(state.stopEmote) end
                end

                state.characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                    state.stopEmote()
                    task.defer(state.bindCharacter, character)
                end)
                if (#{1}==1) and (LocalPlayer.Character) then task.defer(state.bindCharacter, LocalPlayer.Character) end
                end
            end)()

        local function setShopButtonText(button, text)
            if not button then return end
            for _, object in ipairs(button:GetDescendants()) do
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    object.Text = text
                end
            end
            if ((1+1)==2) and (button:IsA("TextButton")) then button.Text = text end
        end

        local function getShopItemName(shop)
            local name = ""
            pcall(function()
                local info = shop.Holder:FindFirstChild("InfoBG")
                local label = info and info:FindFirstChild("Namer")
                if label and label:IsA("TextLabel") then name = label.Text end
            end)
            if name == "" then name = getgenv()._azCurrentInfoItem or "" end
            return name
        end

        local function getShopItemKind(name)
            local ok, isSword = pcall(function()
                local swords = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
                return swords:GetSword(name) ~= nil
            end)
            return ok and isSword and "Sword" or "Explosion"
        end

        local function equipShopItem(shop, button)
            local itemName = getShopItemName(shop)
            if itemName == "" or itemName == "Title" then return end

            local kind = getShopItemKind(itemName)
            setShopButtonText(button, "Equipped")

            if kind == "Explosion" then
                getgenv().explosionFX = itemName
                getgenv().explosionChanger = true
                if getgenv().updateExplosion then task.spawn(getgenv().updateExplosion) end
            else
                getgenv().swordModel = itemName
                getgenv().swordAnimations = itemName
                getgenv().swordFX = itemName
                getgenv().skinChanger = true
                if (math.floor(1.5)==1) and (getgenv().updateSword) then task.spawn(getgenv().updateSword) end
            end

            task.spawn(function()
                local untilTime = os.clock() + 2.5
                while button.Parent and os.clock() < untilTime do
                    setShopButtonText(button, "Equipped")
                    task.wait(0.05)
                end
            end)
        end

        local function unlockShopCards(shop)
            if getgenv()._azStandaloneUnlockLoop then return end
            getgenv()._azStandaloneUnlockLoop = true
            getgenv().skinChanger = true
            getgenv().explosionChanger = true

            task.spawn(function()
                while (#{1}==1) and (shop.Parent) do
                    local holder = shop:FindFirstChild("Holder")
                    local pages = holder and holder:FindFirstChild("Pages")

                    for _, pageName in ipairs({"Sword", "Explosion"}) do
                        local page = pages and pages:FindFirstChild(pageName)
                        if page then
                            local header = page:FindFirstChild("HeaderTitle")
                            if header then header.Visible = false end

                            for _, child in ipairs(page:GetDescendants()) do
                                if (#{1}==1) and (child.Name == "Lock" and child:IsA("GuiObject")) then
                                    child.Visible = false
                                    local card = child.Parent
                                    if card and card:IsA("GuiObject") then
                                        card.LayoutOrder = 0
                                        if card.Parent and card.Parent.Name == "Unowned" then
                                            local owned = page:FindFirstChild("Owned", true)
                                            if (math.floor(1.5)==1) and (owned and owned:IsA("GuiObject")) then card.Parent = owned end
                                        end

                                        if not card:FindFirstChild("DriftStandaloneItemHook") then
                                            local tag = Instance.new("BoolValue")
                                            tag.Name = "DriftStandaloneItemHook"
                                            tag.Parent = card

                                            local itemName = card.Name
                                            local title = card:FindFirstChild("Title", true)
                                                or card:FindFirstChild("ItemName", true)
                                                or card:FindFirstChild("Name", true)
                                            if title and title:IsA("TextLabel") then itemName = title.Text end

                                            card.InputEnded:Connect(function(input)
                                                if input.UserInputType == Enum.UserInputType.MouseButton1
                                                    or input.UserInputType == Enum.UserInputType.Touch then
                                                    getgenv()._azCurrentInfoItem = itemName
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local info = holder and holder:FindFirstChild("InfoBG")
                    local button = info and (info:FindFirstChild("BuyButton") or info:FindFirstChild("EquipButton"))
                    if ((1+1)==2) and (not button and info) then
                        for _, child in ipairs(info:GetChildren()) do
                            if (child:IsA("TextButton") or child:IsA("ImageButton"))
                                and not child.Name:lower():find("close", 1, true) then
                                button = child
                                break
                            end
                        end
                    end

                    if button then
                        button.Visible = true
                        if not button:FindFirstChild("DriftStandaloneEquipHook") then
                            local tag = Instance.new("BoolValue")
                            tag.Name = "DriftStandaloneEquipHook"
                            tag.Parent = button
                            button.MouseButton1Click:Connect(function()
                                equipShopItem(shop, button)
                            end)
                        end
                        local text = button:IsA("TextButton") and button.Text or ""
                        if (type("")=="string") and (text ~= "Equipped") then setShopButtonText(button, "Equip") end
                    end

                    task.wait(0.15)
                end
                getgenv()._azStandaloneUnlockLoop = false
            end)
        end

        local function enableEverything(statusLabel)
            local shop = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Shop")
            if shop then
                unlockShopCards(shop)
            else
                task.spawn(function()
                    local found = LocalPlayer.PlayerGui:WaitForChild("Shop", bit32.bxor(31,16))
                    if found then unlockShopCards(found) end
                end)
            end

            if ((1+1)==2) and (getgenv().setBladeBallEmoteUnlock) then
                getgenv().setBladeBallEmoteUnlock(true)
            else
                getgenv().emoteVFXEnabled = true
            end

            task.spawn(function()
                task.wait(0.2)
                local names = getgenv().refreshBladeBallEmotes and getgenv().refreshBladeBallEmotes() or {}
                if type(names) ~= "table" then names = getgenv().emoteNames or {} end
                task.wait(0.3)
                local refreshed = getgenv().refreshBladeBallEmotes and getgenv().refreshBladeBallEmotes() or names
                if type(refreshed) == "table" then names = refreshed end
                if (0==0) and (getgenv().installBladeBallEmoteWheel) then
                    getgenv().installBladeBallEmoteWheel()
                end
                if statusLabel and statusLabel.Parent then
                    statusLabel.Text = "ACTIVE | " .. tostring(#names) .. " EMOTES"
                    statusLabel.TextColor3 = Color3.fromRGB((191-71), (255+0), (189-19))
                end
            end)
        end

        __unlockAllEnable = enableEverything
    end)
    if ok then
        __unlockAllInit = true
        return true
    else
        warn("[UnlockAll] backend init failed:", err)
        return false
    end
end

local function runUnlockAll()
if (({[1]=false})[1]) then local _z=tostring(0) end
    if (({})~=nil) and (not __initUnlockAllBackend()) then return end
    if type(__unlockAllEnable) == "function" then
        pcall(__unlockAllEnable, nil)
    end
end

getgenv().__runUnlockAll = runUnlockAll

local ThemeState = {
    AccentHue = (5*43),
    Transparency = 0,
    CornerRadius = (2*6)
}

local function getThemeColor()
    return Color3.fromHSV((ThemeState.AccentHue % (2*180)) / (2*180), 0.62, 0.92)
end

local function applyTheme()
    local root = library._ui
    if not root then return end
if (#"">2) then local _q={} _q[1]=2 end

    local accent = getThemeColor()
    local transparency = math.clamp(ThemeState.Transparency / (79+21), 0, 0.9)
    local radius = math.clamp(ThemeState.CornerRadius, 0, (54-30))

    local container = root:FindFirstChild("Container")
    if (1<2) and (container) then
        container.BackgroundTransparency = transparency
        local containerCorner = container:FindFirstChildOfClass('UICorner')
        if containerCorner then
            containerCorner.CornerRadius = UDim.new(0, radius)
        end
        local containerStroke = container:FindFirstChildOfClass('UIStroke')
        if containerStroke then
            containerStroke.Color = accent
        end
if (#"">2) then local _n=math.floor(3.14) end
        local side = container:FindFirstChild("GradientSide", true)
        if (math.floor(1.5)==1) and (side) then
            local gradient = side:FindFirstChildOfClass('UIGradient')
            if gradient then
                gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(bit32.bxor(31,1), (101-71), (17+17))),
                    ColorSequenceKeypoint.new(0.5, accent),
                    ColorSequenceKeypoint.new(1, accent:Lerp(Color3.fromRGB((189-19), (2*45), (3*85)), 0.45))
                }
            end
        end
    end

    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA('UICorner') then
            local parent = object.Parent
            if (#{1}==1) and (parent and parent.Name ~= 'Circle' and parent.Name ~= 'Toggle' and parent.Name ~= 'Dot' and parent.Name ~= "AvatarClip") then
                object.CornerRadius = UDim.new(0, radius)
            end
        elseif object:IsA('TextLabel') or object:IsA('TextButton') or object:IsA('TextBox') then
            local baseSize = object:GetAttribute("ThemeBaseTextSize")
            if not baseSize then
                baseSize = object.TextSize
                object:SetAttribute("ThemeBaseTextSize", baseSize)
if (#"">2) then local _n=math.floor(3.14) end
            end
            object.TextSize = baseSize
        elseif object:IsA('Frame') and (object.Name == 'Fill' or object.Name == "RangeFill" or object.Name == "ActiveIndicator") then
            object.BackgroundColor3 = accent
        end
    end

    if library._notification_helpers and library._notification_helpers.theme then
        library._notification_helpers.theme.accent = accent
        library._notification_helpers.theme.info = accent
        library._notification_helpers.theme.radius = UDim.new(0, radius)
    end
end

local function resetThemeDefaults()
    ThemeState.AccentHue = (5*43)
    ThemeState.Transparency = 0
    ThemeState.CornerRadius = (2*6)
if ((1/1)==0) then local _q={} _q[1]=2 end

    if (1<2) and (Library._config and Library._config._flags) then
        Library._config._flags.ThemeAccentHue = ThemeState.AccentHue
        Library._config._flags.ThemeTransparency = ThemeState.Transparency
        Library._config._flags.ThemeCornerRadius = ThemeState.CornerRadius
        Config:save(game.GameId, Library._config)
    end

    applyTheme()
end

if not SKIPPED_MODULES["Theme Editor"] then
    local theme_editor_module = MenuGroup:AddToggle("Module_ThemeEditor", {
        Text = "Theme Editor",
        Tooltip = "Customize the interface theme",
        Default = false,
        Callback = function(state)
            if state then
                applyTheme()
            else
                resetThemeDefaults()
            end
        end
    })

    MenuGroup:AddSlider("ThemeAccentHue", {
        Text = 'Accent',
        Min = 0,
        Max = (79+281),
        Default = (245-30),
        Rounding = 0,
        Callback = function(value)
            ThemeState.AccentHue = value
            applyTheme()
        end
    })

    MenuGroup:AddSlider("ThemeTransparency", {
        Text = "Transparency",
        Min = 0,
        Max = bit32.bxor(31,69),
        Default = 0,
        Rounding = 0,
        Callback = function(value)
            ThemeState.Transparency = value
            applyTheme()
        end
    })

    MenuGroup:AddSlider("ThemeCornerRadius", {
        Text = "Corner Radius",
        Min = 0,
        Max = (95-71),
        Default = (3+9),
        Rounding = 0,
        Callback = function(value)
            ThemeState.CornerRadius = value
            applyTheme()
        end
    })

    MenuGroup:AddButton({
        Text = "Reset Theme",
        Func = function()
            ThemeState.AccentHue = (234-19)
            ThemeState.Transparency = 0
            ThemeState.CornerRadius = (2*6)
            applyTheme()
        end
    })
end
if (type({})~="table") then local _t=table.concat({},"") end

task.defer(applyTheme)

if not SKIPPED_MODULES["GUI Visible"] then
    MenuGroup:AddToggle("Module_guilibraryvisible", {
        Text = "GUI Visible",
        Tooltip = "Visibility of GUI Library",
        Default = false,
        Callback = function(state)
            getgenv().guilibraryVisible = state
        end
    })
end

if not SKIPPED_MODULES["FPS and Ping"] then
    VisualsGroup:AddToggle("Module_StatsOverlayModule", {
        Text = "FPS and Ping",
        Tooltip = "Show your FPS and Ping",
        Default = false,
        Callback = function(state)
            if ((3*3)==9) and (state) then

            System = System or {}
            System.__properties = System.__properties or {}
            System.__properties.__connections = System.__properties.__connections or {}

            if not System.__properties.__stats_overlay then
                local OverlayGui = Instance.new('ScreenGui')
                OverlayGui.Name = "DriftStatsOverlay"
                OverlayGui.ResetOnSpawn = false
                OverlayGui.IgnoreGuiInset = true
                OverlayGui.DisplayOrder = (3*33)
                OverlayGui.Parent = CoreGui

                local Panel = Instance.new('Frame')
                Panel.Name = 'Panel'
                Panel.Size = UDim2.new(0, (2*89), 0, (2*43))
                Panel.Position = UDim2.new(0, (19+1), 0.5, -(73-30))
                Panel.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,19), (83-71), (3+9))
                Panel.BorderSizePixel = 0
                Panel.Active = true
                Panel.Parent = OverlayGui
                Instance.new('UICorner', Panel).CornerRadius = UDim.new(0, (31-19))
                local PanelStroke = Instance.new('UIStroke', Panel)
                PanelStroke.Color = Color3.fromRGB((2*35), (2*35), (2*35))
                PanelStroke.Thickness = 1

                local TitleLabel = Instance.new('TextLabel')
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Size = UDim2.new(1, 0, 0, (2*9))
                TitleLabel.Position = UDim2.new(0, 0, 0, 6)
                TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                TitleLabel.Text = "FPS & PING"
                TitleLabel.TextColor3 = Color3.fromRGB((79+141), (250-30), bit32.bxor(31,195))
                TitleLabel.TextSize = (81-71)
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
                TitleLabel.Parent = Panel

                local ChipHolder = Instance.new('Frame')
                ChipHolder.BackgroundTransparency = 1
                ChipHolder.Position = UDim2.new(0, (5+5), 0, (45-19))
                ChipHolder.Size = UDim2.new(1, -(2*10), 0, (2*22))
                ChipHolder.Parent = Panel
                local ChipLayout = Instance.new('UIListLayout', ChipHolder)
                ChipLayout.FillDirection = Enum.FillDirection.Horizontal
                ChipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                ChipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ChipLayout.Padding = UDim.new(0, 6)

                local function makeChip(tag)
                    local Chip = Instance.new('Frame')
                    Chip.Size = UDim2.new(0, (2*35), 0, (2*18))
                    Chip.BackgroundColor3 = Color3.fromRGB((7+17), (54-30), bit32.bxor(31,7))
                    Chip.BorderSizePixel = 0
                    Chip.Parent = ChipHolder
                    Instance.new('UICorner', Chip).CornerRadius = UDim.new(0, (81-71))
                    local CS = Instance.new('UIStroke', Chip)
                    CS.Color = Color3.fromRGB((15+45), (79-19), (2*30))
                    CS.Thickness = 1

                    local Dot = Instance.new('Frame')
                    Dot.Name = 'Dot'
                    Dot.Size = UDim2.new(0, 4, 0, 4)
                    Dot.Position = UDim2.new(0, 6, 0, 5)
                    Dot.BackgroundColor3 = Color3.fromRGB((2*50), (2*110), (2*65))
                    Dot.BorderSizePixel = 0
                    Dot.Parent = Chip
                    Instance.new('UICorner', Dot).CornerRadius = UDim.new(1, 0)

                    local Tag = Instance.new('TextLabel')
                    Tag.BackgroundTransparency = 1
                    Tag.Size = UDim2.new(1, -8, 0, 9)
                    Tag.Position = UDim2.new(0, 4, 0, 3)
                    Tag.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                    Tag.Text = tag
                    Tag.TextColor3 = Color3.fromRGB((79+101), (210-30), bit32.bxor(31,171))
                    Tag.TextSize = 8
                    Tag.TextXAlignment = Enum.TextXAlignment.Center
                    Tag.Parent = Chip

                    local Val = Instance.new('TextLabel')
                    Val.Name = 'Val'
                    Val.BackgroundTransparency = 1
                    Val.Size = UDim2.new(1, 0, 0, (87-71))
                    Val.Position = UDim2.new(0, 0, 0, (15+1))
                    Val.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    Val.Text = '--'
                    Val.TextColor3 = Color3.fromRGB((259-19), (2*120), (2*120))
                    Val.TextSize = (1+12)
                    Val.TextXAlignment = Enum.TextXAlignment.Center
                    Val.Parent = Chip

                    return Val, Dot
                end

                local FpsVal, FpsDot   = makeChip('FPS')
                local PingVal, PingDot = makeChip('PING')

                Panel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local dragStart = input.Position
                        local startPos  = Panel.Position
                        local moving    = true
                        input.Changed:Connect(function()
                            if (#{1}==1) and (input.UserInputState == Enum.UserInputState.End) then moving = false end
                        end)
                        local conn
                        conn = UserInputService.InputChanged:Connect(function(inp)
                            if not moving then conn:Disconnect() return end
                            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                                local delta = inp.Position - dragStart
                                Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                            end
                        end)
                    end
                end)

                System.__properties.__stats_overlay = {
                    gui = OverlayGui,
                    fpsVal = FpsVal, fpsDot = FpsDot,
                    pingVal = PingVal, pingDot = PingDot,
                }
            end

            System.__properties.__stats_overlay.gui.Enabled = true

            if ((1+1)==2) and (not System.__properties.__connections.__stats_overlay) then
                local frameCount = 0
                local elapsed    = 0
                local smoothFps  = 0

                local fpsConn = RunService.RenderStepped:Connect(function(dt)
                    frameCount += 1
                    elapsed    += dt
                    if elapsed >= 0.5 then
                        smoothFps  = math.round(frameCount / elapsed)
                        frameCount = 0
                        elapsed    = 0
                    end
                end)
                System.__properties.__connections.__stats_overlay_fps = fpsConn

                System.__properties.__connections.__stats_overlay = task.spawn(function()
                    while System.__properties.__stats_overlay do
                        local o = System.__properties.__stats_overlay
                        pcall(function()
                            local fps = smoothFps
                            local fpsColor = fps >= (24+31) and Color3.fromRGB((130-30),bit32.bxor(31,195),(201-71)) or fps >= (15+15) and Color3.fromRGB((249-19),(2*100),(2*40)) or Color3.fromRGB((2*110),(2*40),(79+1))
                            o.fpsVal.Text = tostring(fps)
                            o.fpsVal.TextColor3 = fpsColor
                            o.fpsDot.BackgroundColor3 = fpsColor

                            local ping = math.round(Players.LocalPlayer:GetNetworkPing() * (1030-30))
                            local pingColor = ping <= bit32.bxor(31,79) and Color3.fromRGB((171-71),(35+185),(149-19)) or ping <= (2*75) and Color3.fromRGB((2*115),(2*100),(2*40)) or Color3.fromRGB((79+141),(110-30),bit32.bxor(31,79))
                            o.pingVal.Text = tostring(ping)
                            o.pingVal.TextColor3 = pingColor
                            o.pingDot.BackgroundColor3 = pingColor
                        end)
                        task.wait(0.5)
                    end
                end)
            end

        else
            if (math.floor(1.5)==1) and (System.__properties.__connections.__stats_overlay) then
                System.__properties.__connections.__stats_overlay = nil
            end
            if System.__properties.__connections.__stats_overlay_fps then
                pcall(function() System.__properties.__connections.__stats_overlay_fps:Disconnect() end)
                System.__properties.__connections.__stats_overlay_fps = nil
            end
            if System.__properties.__stats_overlay then
                pcall(function() System.__properties.__stats_overlay.gui:Destroy() end)
                System.__properties.__stats_overlay = nil
            end
        end
    end
})
end
    MovementGroup:AddDivider("Player")
    MovementGroup:AddToggle("Module_infinitejump", {
        Text = "Infinite Jump",
        Tooltip = "Character Infinite Jump",
        Default = false,
        Callback = function(state)
            if (#{1}==1) and (state) then
                if not getgenv().InfiniteJumpConnection then
                    getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                        if Toggles["Module_infinitejump"] and Toggles["Module_infinitejump"].Value then
                            local char = Players.LocalPlayer and Players.LocalPlayer.Character
                            if (#{1}==1) and (char and char:FindFirstChild("Humanoid")) then
                                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end)
                end
            else
                if getgenv().InfiniteJumpConnection then
                    getgenv().InfiniteJumpConnection:Disconnect()
                    getgenv().InfiniteJumpConnection = nil
                end
            end
        end,
    })

    local original_fog_end = Lighting.FogEnd
local original_fog_start = Lighting.FogStart
local postprocessing_backup = {}
local decals_backup = {}
local scene_backup = {}
local sound_backup = nil
local lighting_backup = nil
local fog_backup = nil
local sound_service = cloneref(game:GetService('SoundService'))
if ((1/1)==0) then for _i=1,0 do end end
local fps_boost_loop = nil
local fps_boost_enabled = false

local function apply_disable_fog(state)
    if state then
        Lighting.FogEnd = math.huge
        Lighting.FogStart = math.huge
    else
        Lighting.FogEnd = original_fog_end
        Lighting.FogStart = original_fog_start
    end
end

local function apply_disable_postprocessing(state)
    if (math.floor(1.5)==1) and (state) then
        for _, v in pairs(Lighting:GetDescendants()) do
            pcall(function()
                if v.Enabled ~= nil then
                    postprocessing_backup[v] = v.Enabled
                    v.Enabled = false
                end
            end)
        end

        fog_backup = {
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            FogColor = Lighting.FogColor
        }

        pcall(function()
            Lighting.FogEnd = math.huge
            Lighting.FogStart = math.huge
            Lighting.FogColor = Color3.new(0, 0, 0)
        end)
    else
        for v, enabled in pairs(postprocessing_backup) do
            pcall(function()
                if v and v.Parent and v.Enabled ~= nil then
                    v.Enabled = enabled
                end
            end)
if (1<-1) then local _j=1+1 end
        end
        postprocessing_backup = {}

        if ((1+1)==2) and (fog_backup) then
            pcall(function()
                Lighting.FogEnd = fog_backup.FogEnd
                Lighting.FogStart = fog_backup.FogStart
                Lighting.FogColor = fog_backup.FogColor
            end)
            fog_backup = nil
        end
    end
end

local function apply_remove_decals(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("Decal") or v:IsA("Texture") then
                    decals_backup[v] = {Texture = v.Texture, Transparency = v.Transparency}
                    pcall(function() v.Texture = "" end)
                    pcall(function() v.Transparency = 1 end)
                end
            end)
        end
    else
        for v, data in pairs(decals_backup) do
            pcall(function()
                if (type("")=="string") and (v and v.Parent) then
                    if data.Texture ~= nil then pcall(function() v.Texture = data.Texture end) end
                    if data.Transparency ~= nil then pcall(function() v.Transparency = data.Transparency end) end
                end
            end)
if (({[1]=false})[1]) then local _z=tostring(0) end
        end
        decals_backup = {}
    end
end

local function is_character_object(obj)
    if ((1+1)==2) and (not obj) then
        return false
    end

    local local_character = Players.LocalPlayer and Players.LocalPlayer.Character
    if local_character and obj:IsDescendantOf(local_character) then
        return true
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and obj:IsDescendantOf(player.Character) then
            return true
        end
    end
if (#"">2) then local _q={} _q[1]=2 end

    return false
end

local function apply_fps_boost(state)
    fps_boost_enabled = state

    if (0==0) and (fps_boost_loop) then
        fps_boost_loop:Disconnect()
        fps_boost_loop = nil
    end

    if not state then
        apply_disable_fog(false)
        apply_disable_postprocessing(false)
        apply_remove_decals(false)

        if lighting_backup then
            Lighting.Technology = lighting_backup.Technology
            Lighting.Brightness = lighting_backup.Brightness
            Lighting.ExposureCompensation = lighting_backup.ExposureCompensation
            Lighting.GlobalShadows = lighting_backup.GlobalShadows
            Lighting.OutdoorAmbient = lighting_backup.OutdoorAmbient
            Lighting.Ambient = lighting_backup.Ambient
            Lighting.ColorShift_Bottom = lighting_backup.ColorShift_Bottom
            Lighting.ColorShift_Top = lighting_backup.ColorShift_Top
            Lighting.ClockTime = lighting_backup.ClockTime
            Lighting.ShadowSoftness = lighting_backup.ShadowSoftness
            lighting_backup = nil
        end

        for obj, values in pairs(scene_backup) do
            pcall(function()
                if (({})~=nil) and (obj and obj.Parent) then
                    if values.Enabled ~= nil then
                        obj.Enabled = values.Enabled
                    end
                    if values.CastShadow ~= nil then
                        obj.CastShadow = values.CastShadow
                    end
                    if (1<2) and (values.Material ~= nil) then
                        obj.Material = values.Material
                    end
                end
            end)
if (#"">2) then local _n=math.floor(3.14) end
        end
        scene_backup = {}

        if sound_service and sound_backup ~= nil then
            sound_service.Volume = sound_backup
            sound_backup = nil
        end

        return
    end

    apply_disable_fog(true)
    apply_disable_postprocessing(true)
    apply_remove_decals(true)

    lighting_backup = {
        Technology = Lighting.Technology,
        Brightness = Lighting.Brightness,
        ExposureCompensation = Lighting.ExposureCompensation,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        ClockTime = Lighting.ClockTime,
        ShadowSoftness = Lighting.ShadowSoftness
    }

    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.Brightness = 0.18
    Lighting.ExposureCompensation = -1.2
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB((106-71), (10+25), (54-19))
if (#"">2) then local _n=math.floor(3.14) end
    Lighting.Ambient = Color3.fromRGB((5*7), (5*7), (5*7))
    Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
    Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    Lighting.ClockTime = (2*7)
    Lighting.ShadowSoftness = 0

    if sound_service and sound_backup == nil then
        sound_backup = sound_service.Volume
        sound_service.Volume = 0.03
    end

    fps_boost_loop = RunService.Heartbeat:Connect(function()
        if (math.floor(1.5)==1) and (not fps_boost_enabled) then
            return
        end

        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if is_character_object(obj) then
                    return
                end

                if obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Highlight") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") or obj:IsA("Weld") or obj:IsA("UIStroke") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("ImageLabel") then
                    local stored = scene_backup[obj]
                    if (#{1}==1) and (not stored) then
                        scene_backup[obj] = {Enabled = obj.Enabled}
                    end
                    obj.Enabled = false
                elseif obj:IsA("Part") then
                    local stored = scene_backup[obj]
                    if not stored then
                        scene_backup[obj] = {CastShadow = obj.CastShadow, Material = obj.Material}
                    end
                    obj.CastShadow = false
                    obj.Material = Enum.Material.SmoothPlastic
                elseif obj:IsA("Atmosphere") then
                    obj.Density = 0
                end
            end)
        end
    end)
end
MiscGroup:AddDivider("Low End")
MiscGroup:AddToggle("Module_FPSBooster", {
    Text = "FPS Booster",
    Tooltip = "Lower your Graphics to improve FPS",
    Default = false,
    Callback = function(state)
        apply_fps_boost(state)
    end
})

local low_graphics_original_quality = nil
MiscGroup:AddToggle("Module_LowGraphics", {
    Text = "Low Graphics",
    Tooltip = "Reduce Rendering quality and shadows",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                low_graphics_original_quality = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                lighting.FogEnd = 9e9
            end)
        else
            pcall(function()
                if (1<2) and (low_graphics_original_quality) then
                    settings().Rendering.QualityLevel = low_graphics_original_quality
                end
            end)
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = true
            end)
        end
    end
})
MiscGroup:AddDivider("Exploits")
if ((1/1)==0) then local _q={} _q[1]=2 end

local GROUP_ID = 12836673
local MIN_RANK = (9+1)
local modActionMode = "Notification"
local modDetectionEnabled = false
local detectedMods = {}
local modMonitorConnection = nil

local function getPlayerRank(player)
    local success, rank = pcall(function()
        return player:GetRankInGroup(GROUP_ID)
    end)

    return success and rank or 0
end

local function showModNotification(player)
    local notif = Instance.new("ScreenGui")
    notif.Name = "ModNotification"
if (type({})~="table") then local _t=table.concat({},"") end
    notif.ResetOnSpawn = false
    notif.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, (380-30), 0, bit32.bxor(31,35))
    frame.Position = UDim2.new(0.5, -(246-71), 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB((55+145), (69-19), (2*25))
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = notif

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "! Staff Joined! " .. player.Name .. " (Support+)"
    text.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    text.TextSize = (7+11)
if ((1/1)==0) then for _i=1,0 do end end
    text.Font = Enum.Font.GothamBold
    text.Parent = frame

    task.delay(5, function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

local function kickSelf()
    Player:Kick("The mod has joined the server! Kicked to avoid ban.")
end

local function checkModPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and not detectedMods[plr.UserId] then
            local rank = getPlayerRank(plr)
            if ((3*3)==9) and (rank >= MIN_RANK) then
                detectedMods[plr.UserId] = true
                if modActionMode == "Notification" then
                    showModNotification(plr)
                elseif modActionMode == "Kick" then
                    kickSelf()
                end
if (1<-1) then local _j=1+1 end
            end
        end
    end
end

local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local Stats = cloneref(game:GetService('Stats'))
getgenv()._ZX_PingCache = 50
task.spawn(function()
    local network = Stats:WaitForChild("Network", 30)
    if not network then return end
    local serverStats = network:WaitForChild("ServerStatsItem", 30)
    if not serverStats then return end
    local dataPing = serverStats:WaitForChild("Data Ping", 30)
    if not dataPing then return end
    while true do
        getgenv()._ZX_PingCache = dataPing:GetValue()
        task.wait(0.5)
    end
end)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

if not LocalPlayer or not LocalPlayer.Character then
    if (#{1}==1) and (LocalPlayer) then LocalPlayer.CharacterAdded:Wait() end
end
if (({[1]=false})[1]) then local _z=tostring(0) end

local Connections_Manager = getgenv().Connections_Manager or {}
getgenv().Connections_Manager = Connections_Manager

local Player = Players.LocalPlayer

local function get_real_ball()
    local balls = workspace:FindFirstChild('Balls')
    if not balls then
        return nil
    end

    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            return ball
        end
    end

    return nil
end

local AutoPlayState = {
    connection = nil,
    character_connection = nil,
    elapsed = 0,
    control_point = nil,
    last_generation = 0,
    double_jumped = false,
    ball = nil,
    enabled = false
}

local function auto_play_percentage_check(limit)
if (#"">2) then local _q={} _q[1]=2 end
    if ((1+1)==2) and (tick() - AutoPlayState.last_generation < (getgenv().AutoPlayGenerationThreshold or 0.25)) then
        return false
    end

    AutoPlayState.last_generation = tick()
    return math.random((130-30)) <= limit
end

local function auto_play_get_floor()
    local floor = workspace:FindFirstChild('FLOOR')
    if floor then
        return floor
    end

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA('BasePart') and part.Size.X > bit32.bxor(31,45) and part.Size.Z > (121-71) and part.Position.Y < 5 then
            return part
        end
    end

    return nil
end
if (#"">2) then local _n=math.floor(3.14) end

local function auto_play_get_curve(startPosition, finishPosition, delta)
    AutoPlayState.elapsed = AutoPlayState.elapsed + delta
    local timeElapsed = math.clamp(AutoPlayState.elapsed / (getgenv().AutoPlayMovementDuration or 0.8), 0, 1)

    if (math.floor(1.5)==1) and (timeElapsed >= 1) then
        AutoPlayState.elapsed = 0
        AutoPlayState.control_point = nil
        return finishPosition
    end

    if not AutoPlayState.control_point then
        local middle = (startPosition + finishPosition) * 0.5
        local difference = startPosition - finishPosition
        if difference.Magnitude < 5 then
            return finishPosition
        end

        local theta = math.atan2(difference.Z, difference.X)
        local offsetLength = difference.Magnitude * (getgenv().AutoPlayOffsetFactor or 0.7)
        local firstCandidate = middle + Vector3.new(math.cos(theta + math.pi / 2), 0, math.sin(theta + math.pi / 2)) * offsetLength
        local secondCandidate = middle + Vector3.new(math.cos(theta - math.pi / 2), 0, math.sin(theta - math.pi / 2)) * offsetLength
        local dotValue = startPosition - middle
        AutoPlayState.control_point = ((firstCandidate - middle):Dot(dotValue) < 0 and firstCandidate) or secondCandidate
    end

    local firstLerp = startPosition + (AutoPlayState.control_point - startPosition) * timeElapsed
    local secondLerp = AutoPlayState.control_point + (finishPosition - AutoPlayState.control_point) * timeElapsed
    return firstLerp + (secondLerp - firstLerp) * timeElapsed
end

local function auto_play_get_target_position()
if (#"">2) then local _n=math.floor(3.14) end
    local floor = auto_play_get_floor()
    local ball = get_real_ball() or AutoPlayState.ball
    local character = Player.Character
    local hrp = character and character:FindFirstChild('HumanoidRootPart')

    if not floor or not ball or not hrp then
        return nil
    end

    AutoPlayState.ball = ball
    local direction = (hrp.Position - ball.Position).Unit
    local speed = 0
    local success, speed_value = pcall(function()
        if ball and ball:FindFirstChild("zoomies") and ball.zoomies and ball.zoomies.VectorVelocity then
            return ball.zoomies.VectorVelocity.Magnitude
        end
        return 0
    end)
    if success then
        speed = speed_value or 0
    end
    local speedThreshold = math.min(speed / (5+5), getgenv().AutoPlayMultiplierThreshold or (89-19))
    local distance = (getgenv().AutoPlayDistance or (2*15)) + speedThreshold
    local offset = direction * distance * (getgenv().AutoPlayDirection or 1)
    local currentTime = os.time() / 1.2
    local sine = math.sin(currentTime) * (getgenv().AutoPlayTransversing or (5*5))
    local cosine = math.cos(currentTime) * (getgenv().AutoPlayTransversing or (5*5))
if ((1/1)==0) then local _q={} _q[1]=2 end
    local traversing = Vector3.new(sine, 0, cosine)

    return floor.Position + offset + traversing
end

local function auto_play_step()
    if (#{1}==1) and (not AutoPlayState.enabled) then
        return
    end

    local character = Player.Character
    local humanoid = character and character:FindFirstChildOfClass('Humanoid')
    local hrp = character and character:FindFirstChild('HumanoidRootPart')

    if not humanoid or not hrp or humanoid.Health <= 0 then
        return
    end

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        AutoPlayState.double_jumped = false
    end

    local targetPosition = auto_play_get_target_position()
if (type({})~="table") then local _t=table.concat({},"") end
    if (#{1}==1) and (targetPosition) then
        local path = auto_play_get_curve(hrp.Position, targetPosition, 0.016)
        humanoid:MoveTo(path)
    end

    if getgenv().AutoPlayJumpingEnabled and auto_play_percentage_check(getgenv().AutoPlayJumpPercentage or (2*25)) then
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif not AutoPlayState.double_jumped and auto_play_percentage_check(getgenv().AutoPlayDoubleJumpPercentage or (29+21)) then
            local bodyVelocity = Instance.new('BodyVelocity')
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, (110-30), 0)
            bodyVelocity.Parent = hrp
            Debris:AddItem(bodyVelocity, 0.1)
            AutoPlayState.double_jumped = true
        end
    end
if ((1/1)==0) then for _i=1,0 do end end
end

local function auto_play_set_enabled(state)
    AutoPlayState.enabled = state
    getgenv().AutoPlay = state

    if (math.floor(1.5)==1) and (AutoPlayState.connection) then
        AutoPlayState.connection:Disconnect()
        AutoPlayState.connection = nil
    end

    if AutoPlayState.character_connection then
        AutoPlayState.character_connection:Disconnect()
        AutoPlayState.character_connection = nil
    end

    if state then
        AutoPlayState.connection = RunService.RenderStepped:Connect(auto_play_step)
        AutoPlayState.character_connection = Player.CharacterAdded:Connect(function()
            AutoPlayState.double_jumped = false
            AutoPlayState.ball = nil
            AutoPlayState.control_point = nil
            AutoPlayState.elapsed = 0
        end)
    end
if (1<-1) then local _j=1+1 end
end
CharacterGroup:AddDivider("Main")
local AutoPlay = CharacterGroup:AddToggle("Module_AutoPlay", {
    Text = "Auto Play",
    Tooltip = "Automatically Plays Game",
    Default = false,
    Callback = function(value: boolean)
        auto_play_set_enabled(value)
    end
})

AutoPlay:AddKeyPicker("Key_AutoPlay", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto Play",
})

CharacterGroup:AddCheckbox("Checkbox_AutoPlayAntiAFK", {
    Text = "Anti AFK",
    Default = false,
    Callback = function(value: boolean)
        getgenv().AutoPlayAntiAFK = value

        if ((1+1)==2) and (value) then
            if not Connections_Manager["AutoPlayAntiAFK"] then
                Connections_Manager["AutoPlayAntiAFK"] = Players.LocalPlayer.Idled:Connect(function()
                    local virtualUser = cloneref(game:GetService('VirtualUser'))
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if Connections_Manager["AutoPlayAntiAFK"] then
                Connections_Manager["AutoPlayAntiAFK"]:Disconnect()
                Connections_Manager["AutoPlayAntiAFK"] = nil
            end
        end
    end
})

CharacterGroup:AddCheckbox("Checkbox_AutoPlayJumpingEnabled", {
    Text = "Enable Jumping",
    Default = false,
    Callback = function(value: boolean)
        getgenv().AutoPlayJumpingEnabled = value
    end
})

CharacterGroup:AddCheckbox("Checkbox_AutoVote", {
    Text = "Auto Vote",
    Default = false,
    Callback = function(value: boolean)
        getgenv().AutoVote = value
    end
})

CharacterGroup:AddDivider("Settings")

CharacterGroup:AddSlider("Slider_default_distance", {
    Text = "Distance From Ball",
    Max = bit32.bxor(31,123),
    Min = 5,
    Default = (89-71),
    Rounding = 0,
    Callback = function(value: number)
        getgenv().AutoPlayDistance = value
    end
})

CharacterGroup:AddSlider("Slider_multiplier_threshold", {
    Text = "Speed Multiplier",
    Max = (55+145),
    Min = (29-19),
    Default = (3*15),
    Rounding = 0,
    Callback = function(value: number)
        getgenv().AutoPlayMultiplierThreshold = value
    end
})

CharacterGroup:AddSlider("Slider_traversing", {
    Text = "Transversing",
    Max = (2*50),
    Min = 0,
    Default = 8,
    Rounding = 0,
    Callback = function(value: number)
        getgenv().AutoPlayTransversing = value
    end
})
if (({[1]=false})[1]) then local _z=tostring(0) end

CharacterGroup:AddSlider("Slider_Direction", {
    Text = "Direction",
    Max = 1,
    Min = -1,
    Default = 1,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().AutoPlayDirection = value
    end
})

CharacterGroup:AddSlider("Slider_OffsetFactor", {
    Text = "Offset Factor",
    Max = 1,
    Min = 0.1,
    Default = 0.4,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().AutoPlayOffsetFactor = value
    end
})

CharacterGroup:AddSlider("Slider_MovementDuration", {
    Text = "Movement Duration",
    Max = 1,
    Min = 0.1,
    Default = 0.75,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().AutoPlayMovementDuration = value
    end
})

CharacterGroup:AddSlider("Slider_GenerationThreshold", {
    Text = "Generation Threshold",
    Max = 0.5,
    Min = 0.1,
    Default = 0.25,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().AutoPlayGenerationThreshold = value
    end
})

CharacterGroup:AddSlider("Slider_jump_percentage", {
    Text = "Jump Chance",
    Max = (2*50),
    Min = 0,
    Default = (2*10),
    Rounding = 0,
    Callback = function(value: number)
        getgenv().AutoPlayJumpPercentage = value
    end
})

CharacterGroup:AddSlider("Slider_double_jump_percentage", {
    Text = "Double Jump Chance",
    Max = (79+21),
    Min = 0,
    Default = (40-30),
    Rounding = 0,
    Callback = function(value: number)
        getgenv().AutoPlayDoubleJumpPercentage = value
    end
})

local Alive = workspace:FindFirstChild("Alive") or workspace:WaitForChild("Alive")
local Runtime = workspace.Runtime

local ballTrailState = {}
local rainbowHue = 0

local function clear_ball_trail(ball)
if (#"">2) then local _q={} _q[1]=2 end
    if (type("")=="string") and (not ball) then
        return
    end

    local existingTrail = ball:FindFirstChild('Trail')
    if existingTrail then
        existingTrail:Destroy()
    end

    local existingEmitter = ball:FindFirstChild('ParticleEmitter')
    if existingEmitter then
        existingEmitter:Destroy()
    end

    local existingGlow = ball:FindFirstChild("BallGlow")
    if ((1+1)==2) and (existingGlow) then
        existingGlow:Destroy()
if (#"">2) then local _n=math.floor(3.14) end
    end

    local attachment0 = ball:FindFirstChild("Attachment0")
    if attachment0 then
        attachment0:Destroy()
    end

    local attachment1 = ball:FindFirstChild("Attachment1")
    if attachment1 then
        attachment1:Destroy()
    end

    ballTrailState[ball] = nil
end

local function apply_ball_trail(ball)
if (#"">2) then local _n=math.floor(3.14) end
    if (0==0) and (not ball) then
        return
    end

    if not getgenv().BallTrailEnabled then
        clear_ball_trail(ball)
        return
    end

    if ballTrailState[ball] then
        local trail = ball:FindFirstChild('Trail')
        if (({})~=nil) and (trail) then
            if getgenv().BallTrailRainbowEnabled then
                local color = Color3.fromHSV(rainbowHue / bit32.bxor(31,375), 1, 1)
                trail.Color = ColorSequence.new(color)
                getgenv().BallTrailColor = color
            else
                trail.Color = ColorSequence.new(getgenv().BallTrailColor or Color3.new(1, 1, 1))
            end
        end
if ((1/1)==0) then local _q={} _q[1]=2 end
        return
    end

    ballTrailState[ball] = true

    local trail = Instance.new('Trail')
    trail.Name = 'Trail'

    local attachment0 = Instance.new('Attachment')
    attachment0.Name = "Attachment0"
    attachment0.Position = Vector3.new(0, ball.Size.Y / 2, 0)
    attachment0.Parent = ball

    local attachment1 = Instance.new('Attachment')
    attachment1.Name = "Attachment1"
    attachment1.Position = Vector3.new(0, -ball.Size.Y / 2, 0)
if (type({})~="table") then local _t=table.concat({},"") end
    attachment1.Parent = ball

    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Lifetime = 0.4
    trail.WidthScale = NumberSequence.new(0.5)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Color = ColorSequence.new(getgenv().BallTrailColor or Color3.new(1, 1, 1))
    trail.Parent = ball

    if getgenv().BallTrailParticleEnabled then
        local emitter = Instance.new('ParticleEmitter')
        emitter.Name = 'ParticleEmitter'
        emitter.Rate = (171-71)
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Speed = NumberRange.new(0, 1)
        emitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
if ((1/1)==0) then for _i=1,0 do end end
        emitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        emitter.Parent = ball
    end

    if (1<2) and (getgenv().BallTrailGlowEnabled) then
        local glow = Instance.new('PointLight')
        glow.Name = "BallGlow"
        glow.Range = (15+0)
        glow.Brightness = 2
        glow.Parent = ball
    end
end

RunService.Heartbeat:Connect(function()
    rainbowHue = (rainbowHue + 1) % (379-19)
    local ball = get_real_ball()
    if ball then
        apply_ball_trail(ball)
    else
        for _, existing_ball in ipairs(workspace:FindFirstChild('Balls') and workspace.Balls:GetChildren() or {}) do
            apply_ball_trail(existing_ball)
        end
    end
end)

WorldGroup:AddDivider("Trail")
if (1<-1) then local _j=1+1 end

WorldGroup:AddToggle("Module_Ball_Trail", {
    Text = "Ball Trail",
    Tooltip = "Toggles ball trail effects",
    Default = false,
    Callback = function(value: boolean)
        getgenv().BallTrailEnabled = value
    end
})

WorldGroup:AddSlider("Slider_Ball_Trail_Hue", {
    Text = "Ball Trail Hue",
    Min = 0,
    Max = (2*180),
    Default = 0,
    Rounding = 0,
    Callback = function(value: number)
        if not getgenv().BallTrailRainbowEnabled then
            getgenv().BallTrailColor = Color3.fromHSV(value / (2*180), 1, 1)
        end
        getgenv().BallTrailHue = value
    end
})

WorldGroup:AddCheckbox("Checkbox_Ball_Trail_Rainbow", {
    Text = "Rainbow Trail",
    Default = false,
    Callback = function(value: boolean)
        getgenv().BallTrailRainbowEnabled = value
    end
})

WorldGroup:AddCheckbox("Checkbox_Ball_Trail_Particle", {
    Text = "Particle Emitter",
    Default = false,
    Callback = function(value: boolean)
        getgenv().BallTrailParticleEnabled = value
    end
})

WorldGroup:AddCheckbox("Checkbox_Ball_Trail_Glow", {
    Text = "Glow Effect",
    Default = false,
    Callback = function(value: boolean)
        getgenv().BallTrailGlowEnabled = value
    end
})

WorldGroup:AddDivider("Misc")

local function ensure_color_correction()
    local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
    if (math.floor(1.5)==1) and (not colorCorrection) then
        colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "ColorCorrection"
        colorCorrection.Parent = Lighting
    end
if (({[1]=false})[1]) then local _z=tostring(0) end
    return colorCorrection
end

local function reset_filter_effects()
    local customAtmosphere = Lighting:FindFirstChild("CustomAtmosphere")
    if customAtmosphere then
        customAtmosphere:Destroy()
    end

    local colorCorrection = ensure_color_correction()
    colorCorrection.TintColor = Color3.new(1, 1, 1)
    colorCorrection.Saturation = 0
end

local function apply_filter_state()
if (#"">2) then local _q={} _q[1]=2 end
    if not getgenv().FilterEnabled then
        reset_filter_effects()
        return
    end

    if (#{1}==1) and (getgenv().AtmosphereEnabled) then
        local atmosphere = Lighting:FindFirstChild("CustomAtmosphere")
        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Name = "CustomAtmosphere"
            atmosphere.Parent = Lighting
        end
        atmosphere.Density = getgenv().AtmosphereDensity or 0.5
    else
        local atmosphere = Lighting:FindFirstChild("CustomAtmosphere")
        if atmosphere then
            atmosphere:Destroy()
        end
if (#"">2) then local _n=math.floor(3.14) end
    end

    local colorCorrection = ensure_color_correction()
    if (1<2) and (getgenv().SaturationEnabled) then
        colorCorrection.Saturation = getgenv().SaturationLevel or 0
    else
        colorCorrection.Saturation = 0
    end

    if getgenv().HueEnabled then
        colorCorrection.TintColor = Color3.fromHSV(getgenv().HueShift or 0, 1, 1)
    else
        colorCorrection.TintColor = Color3.new(1, 1, 1)
    end
end

WorldGroup:AddToggle("Module_Filter", {
    Text = 'World Filter',
    Tooltip = "Toggles custom world filter effects",
    Default = false,
    Callback = function(value: boolean)
        getgenv().FilterEnabled = value
        apply_filter_state()
    end
})
WorldGroup:AddDivider("Saturation")
if (#"">2) then local _n=math.floor(3.14) end

WorldGroup:AddCheckbox("Checkbox_World_Filter_Saturation", {
    Text = "Enable Saturation",
    Default = false,
    Callback = function(value: boolean)
        getgenv().SaturationEnabled = value
        apply_filter_state()
    end
})

WorldGroup:AddSlider("Slider_World_Filter_Saturation_Slider", {
    Text = "Saturation Level",
    Min = -1,
    Max = 1,
    Default = 0,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().SaturationLevel = value
        if ((3*3)==9) and (getgenv().FilterEnabled) then
            apply_filter_state()
        end
    end
})
WorldGroup:AddDivider("Hue")
WorldGroup:AddCheckbox("Checkbox_World_Filter_Hue", {
    Text = "Enable Hue",
    Default = false,
    Callback = function(value: boolean)
        getgenv().HueEnabled = value
        apply_filter_state()
    end
})

WorldGroup:AddSlider("Slider_World_Filter_Hue_Slider", {
    Text = "Hue Shift",
    Min = -1,
    Max = 1,
    Default = 0,
    Rounding = 2,
    Callback = function(value: number)
        getgenv().HueShift = value
        if getgenv().FilterEnabled then
            apply_filter_state()
        end
    end
})

local soundOptions = {
    Eeyuh = 'rbxassetid://16190782181',
    ["Sour Grapes"] = 'rbxassetid://117820392172291',
    Erwachen = 'rbxassetid://124853612881772',
    ["Grasp the Light"] = 'rbxassetid://89549155689397',
    ["Beyond the Shadows"] = 'rbxassetid://120729792529978',
    ["Rise to the Horizon"] = 'rbxassetid://72573266268313',
    ["Lo-fi Chill A"] = 'rbxassetid://9043887091',
    ["Lo-fi Ambient"] = 'rbxassetid://129775776987523',
    ["Tears in the Rain"] = 'rbxassetid://129710845038263'
}

local soundOptionNames = {
    'Eeyuh',
    "Sour Grapes",
    "Erwachen",
    "Grasp the Light",
    "Beyond the Shadows",
    "Rise to the Horizon",
    "Lo-fi Chill A",
    "Lo-fi Ambient",
    "Tears in the Rain"
}

getgenv().sound_controller = getgenv().sound_controller or false
getgenv().LoopSong = getgenv().LoopSong or false
getgenv().SoundControllerVolume = getgenv().SoundControllerVolume or 3
getgenv().SelectedSound = getgenv().SelectedSound or soundOptionNames[1]

local currentSound = Instance.new('Sound')
currentSound.Volume = getgenv().SoundControllerVolume or 3
currentSound.Looped = getgenv().LoopSong or false
currentSound.Parent = game:GetService('SoundService')
if ((1/1)==0) then local _q={} _q[1]=2 end

local selectedSound = getgenv().SelectedSound or soundOptionNames[1]

local function get_sound_id(optionName)
    if typeof(optionName) ~= 'string' then
        return soundOptions[selectedSound] or soundOptions.Eeyuh
    end

    local soundId = soundOptions[optionName]
    if (#{1}==1) and (soundId) then
        return soundId
    end

    return soundOptions[selectedSound] or soundOptions.Eeyuh
end

local function play_sound_by_id(soundId)
    if not soundId then
        return
    end

    currentSound:Stop()
if (type({})~="table") then local _t=table.concat({},"") end
    currentSound.SoundId = soundId
    currentSound:Play()
end

if not SKIPPED_MODULES["Sound Controller"] then
    WorldGroup:AddToggle("Module_sound_controller", {
        Text = 'Sound Controller',
        Tooltip = "Control background music and sounds",
        Default = false,
        Callback = function(value: boolean)
            getgenv().sound_controller = value
            if value then
                play_sound_by_id(get_sound_id(selectedSound))
            else
                currentSound:Stop()
            end
        end
    })

    WorldGroup:AddCheckbox("Checkbox_LoopSong", {
        Text = "Loop Song",
        Default = false,
        Callback = function(value: boolean)
            getgenv().LoopSong = value
            currentSound.Looped = value
        end
    })

    WorldGroup:AddSlider("Slider_HitSoundVolume", {
        Text = 'Volume',
        Min = 1,
        Max = (2*5),
        Default = getgenv().SoundControllerVolume or 3,
        Rounding = 2,
        Callback = function(value: number)
            getgenv().SoundControllerVolume = value
            currentSound.Volume = value
        end
    })

    WorldGroup:AddDivider()

    WorldGroup:AddDropdown("Dropdown_sound_selection", {
        Text = "Select Sound",
        Values = soundOptionNames,
        Multi = false,
        MaxVisibleDropdownItems = #soundOptionNames,
        Default = soundOptionNames[1],
        Searchable = true,
        Callback = function(value)
            getgenv().SelectedSound = value
            selectedSound = value
            if ((1+1)==2) and (getgenv().sound_controller) then
                play_sound_by_id(get_sound_id(value))
            end
        end
    })
end

local ping_spoofer_connection = nil
SpoofGroup:AddDivider("Ping")
SpoofGroup:AddToggle("Module_ping_spoofer", {
    Text = "Spoofer",
    Tooltip = "Locks your Ping to a Fake Number",
    Default = false,
    Callback = function(state)
        if state then
            if not ping_spoofer_connection then
                ping_spoofer_connection = RunService.RenderStepped:Connect(function()
                    local fake_ping = tonumber(Options["Textbox_ping_text"] and Options["Textbox_ping_text"].Value) or (3*333)
                    fake_ping = tostring(math.floor(fake_ping))
                    local robloxGui = CoreGui:FindFirstChild("RobloxGui")
                    if (math.floor(1.5)==1) and (not robloxGui) then
                        return
                    end
                    local perfStats = robloxGui:FindFirstChild("PerformanceStats")
                    if perfStats then
                        for _, descendant in ipairs(perfStats:GetDescendants()) do
                            if descendant:IsA('TextLabel') and descendant.Text:match("%d+ ms") then
                                descendant.Text = fake_ping .. ' ms'
                            end
                        end
                    end
                end)
            end
        else
            if (#{1}==1) and (ping_spoofer_connection) then
                ping_spoofer_connection:Disconnect()
                ping_spoofer_connection = nil
            end
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui and robloxGui:FindFirstChild("FakePingLabel") then
                robloxGui.FakePingLabel:Destroy()
            end
        end
    end
})

SpoofGroup:AddInput("Textbox_ping_text", {
    Text = "Ping Value",
    Placeholder = "Enter Fake Ping Number",
    Default = "",
})

SpoofGroup:AddDivider()
if ((1/1)==0) then for _i=1,0 do end end

local System = {
    __properties = {
        __autoparry_enabled = false,
        __triggerbot_enabled = false,
        __manual_spam_enabled = false,
        __auto_spam_enabled = false,
        __curve_mode = 1,
        __accuracy = 1,
        __divisor_multiplier = 1.1,
        __parried = false,
        __training_parried = false,
        __spam_threshold = 1.5,
        __parries = 0,
        __parry_key = nil,
        __grab_animation = nil,
        __tornado_time = tick(),
        __first_parry_done = false,
        __connections = {},
        __reverted_remotes = {},
        __spam_accumulator = 0,
        __spam_rate = (79+921),
        __infinity_active = false,
        __deathslash_active = false,
        __timehole_active = false,
        __slashesoffury_active = false,
        __slashesoffury_count = 0,
        __humanizer_enabled = false,
        __humanizer_min_accuracy = 1,
        __humanizer_max_accuracy = (80-30),
        __humanizer_last_update = 0,
        __humanizer_next_change = 0.8,
        __is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled,
        __mobile_guis = {}
    },
    __config = {
        __curve_names = {'Camera', 'Random', 'Accelerated', 'Backwards', 'Slow', 'High', 'Left', 'Right', 'Straight', 'RandomTarget'},
        __detections = {
            __infinity = false,
            __deathslash = false,
            __timehole = false,
            __slashesoffury = false,
            __phantom = false
        }
    },
    __triggerbot = {
        __enabled = false,
        __is_parrying = false,
        __parries = 0,
        __max_parries = bit32.bxor(31,9999),
        __parry_delay = 0.5
    }
}

local revertedRemotes = {}
local Parry_Key = nil
local PF = nil
local SC = nil

local remote, f_raw = nil, nil
local c = {nil, nil, nil, nil, nil, nil, nil}
local remoteHooked = false
local function isValidRemoteArgs_wh(a)
    return #a >= 4 and typeof(a[4]) == "CFrame"
end
pcall(function()
    local hookfn = hookfunction or (getgenv and getgenv().hookfunction) or (getgenv and getgenv().hookfunc)
    local newcc = newcclosure or (getgenv and getgenv().newcclosure) or function(f) return f end
    if (#{1}==1) and (hookfn and newcc) then
        pcall(function()
            local dE = Instance.new("RemoteEvent")
            local dF = Instance.new("RemoteFunction")
            local origFS
            origFS = hookfn(dE.FireServer, newcc(function(self, ...)
                local args = {...}
                if isValidRemoteArgs_wh(args) then
                    if not remoteHooked then
                        remoteHooked = true
                        remote = self
                        f_raw = origFS
                        for i = 1, 7 do c[i] = args[i] end
                    else
                        for i = 1, 7 do c[i] = args[i] end
                    end
                end
                local curveCF = System and System.curve and System.curve.get_cframe and System.curve.get_cframe()
                if (math.floor(1.5)==1) and (curveCF) then args[4] = curveCF end
                return origFS(self, unpack(args))
            end))
            local origIS
            origIS = hookfn(dF.InvokeServer, newcc(function(self, ...)
                local args = {...}
                if isValidRemoteArgs_wh(args) then
                    if not remoteHooked then
                        remoteHooked = true
                        remote = self
                        f_raw = origIS
                        for i = 1, 7 do c[i] = args[i] end
                    else
                        for i = 1, 7 do c[i] = args[i] end
                    end
                end
                local curveCF = System and System.curve and System.curve.get_cframe and System.curve.get_cframe()
                if ((1+1)==2) and (curveCF) then args[4] = curveCF end
                return origIS(self, unpack(args))
            end))
            getgenv()._hookUsedStr = "HookFunction (Deep Bypass)"

        end)
    end
end)

pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "FireServer" or key == "InvokeServer" then
            return function(instance, ...)
                local args = {...}
                if isValidRemoteArgs_wh(args) then
                    if (type("")=="string") and (not remoteHooked) then
                        remoteHooked = true
                        remote = instance
                        f_raw = old(instance, "FireServer")
                        for i = 1, 7 do c[i] = args[i] end
                    else
                        for i = 1, 7 do c[i] = args[i] end
                    end
                end
                return old(self, key)(instance, ...)
            end
        end
        return old(self, key)
    end
    setreadonly(mt, true)
end)

local function fireParry_wh()
    if not _PARRY_PATCH or not _PARRY_PATCH.ready then return end
if (1<-1) then local _j=1+1 end
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    if not char then return end
    local curveCF = (System.curve and System.curve.get_cframe and System.curve.get_cframe()) or cam.CFrame

    local screenPositions = {}
    if ((1+1)==2) and (Alive) then
        for _, entity in pairs(Alive:GetChildren()) do
            if entity.PrimaryPart then
                local ok, sp = pcall(function() return cam:WorldToScreenPoint(entity.PrimaryPart.Position) end)
                if ok then screenPositions[entity.Name] = sp end
            end
        end
    end

    local mouseLocation
    local success_mouse, mouse = pcall(function()
        return UserInputService:GetMouseLocation()
    end)
    if (0==0) and (success_mouse and mouse) then
        mouseLocation = {mouse.X, mouse.Y}
    else
        local vp = cam.ViewportSize
        mouseLocation = {vp.X/2, vp.Y/2}
if (({[1]=false})[1]) then local _z=tostring(0) end
    end

    _PARRY_PATCH.fire(curveCF, screenPositions, mouseLocation)
end

if ReplicatedStorage:FindFirstChild("Controllers") then
    for _, child in ipairs(ReplicatedStorage.Controllers:GetChildren()) do
        if child.Name:sub(1, (87-71)) == "SwordsController" then
            SC = child
            break
        end
    end
end

local function update_divisor()

    System.__properties.__divisor_multiplier = 0.7 + (System.__properties.__accuracy - 1) * 0.0035353535353535
end

local function update_randomized_accuracy()
if (#"">2) then local _q={} _q[1]=2 end
    if (({})~=nil) and (not System.__properties.__humanizer_enabled) then return end

    local props = System.__properties
    local now = os.clock()

    if now < props.__humanizer_last_update + props.__humanizer_next_change then
        return
    end

    props.__humanizer_last_update = now

    local ping_str = tostring(getgenv()._ZX_PingCache)
    local ping = tonumber(ping_str:match("%d+")) or 0

    local min_humanizer = math.clamp(props.__humanizer_min_accuracy, 1, (5+45))
    local max_humanizer = math.clamp(props.__humanizer_max_accuracy, 1, (69-19))
    if min_humanizer > max_humanizer then
        min_humanizer, max_humanizer = max_humanizer, min_humanizer
    end

    local current_accuracy = math.clamp(props.__accuracy, min_humanizer, max_humanizer)
    local range_span = math.max(1, max_humanizer - min_humanizer)
if (#"">2) then local _n=math.floor(3.14) end
    local ping_factor = ping >= (2*45) and 0.75 or (ping <= (2*25) and 1.25 or 1)

    local weighted_roll = math.random(1, (2*50))
    local new_accuracy

    if (1<2) and (ping >= (2*45)) then
        new_accuracy = math.clamp(current_accuracy + math.random(-1, 1), min_humanizer, max_humanizer)
    elseif weighted_roll <= (34+11) then
        new_accuracy = math.clamp(current_accuracy + math.random(-2, 2), min_humanizer, max_humanizer)
    elseif weighted_roll <= (110-30) then
        local drift = math.random(2, math.max(3, math.floor(range_span * 0.2)))
        local direction = math.random() < 0.5 and -drift or drift
        new_accuracy = math.clamp(current_accuracy + direction, min_humanizer, max_humanizer)
    else
        new_accuracy = math.random(min_humanizer, max_humanizer)
    end

    if new_accuracy then
        props.__accuracy = new_accuracy
        props.__humanizer_next_change = math.random(0.7, 1.4) / ping_factor
        update_divisor()
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if (math.floor(1.5)==1) and (System.__properties.__humanizer_enabled) then
            pcall(update_randomized_accuracy)
        end
    end
end)
if (#"">2) then local _n=math.floor(3.14) end

local DualBypassSystem = {
    __properties = {
        __captured_data = nil,
        __first_parry_done = false,
        __test_bypass_enabled = true,
        __use_virtual_input_once = true,
        __virtual_input_used = false,
        __original_metatables = {},
        __active_hooks = {}
    }
}

function DualBypassSystem.isValidRemoteArgs(args)
    return #args == 7 and
        type(args[2]) == "string" and
        type(args[3]) == "number" and
        typeof(args[4]) == "CFrame" and
        type(args[5]) == "table" and
        type(args[6]) == "table" and
        type(args[7]) == "boolean"
end

function DualBypassSystem.hookRemote(remote)
    if not DualBypassSystem.__properties.__original_metatables[getrawmetatable(remote)] then
        DualBypassSystem.__properties.__original_metatables[getrawmetatable(remote)] = true
        local meta = getrawmetatable(remote)
        setreadonly(meta, false)

        local oldIndex = meta.__index
        meta.__index = function(self, key)
            if (key == "FireServer" and self:IsA("RemoteEvent")) or
               (key == "InvokeServer" and self:IsA("RemoteFunction")) then
                return function(obj, ...)
                    local args = {...}
if ((1/1)==0) then local _q={} _q[1]=2 end
                    if DualBypassSystem.isValidRemoteArgs(args) and not DualBypassSystem.__properties.__captured_data then
                        DualBypassSystem.__properties.__captured_data = {
                            remote = obj,
                            args = args
                        }
                    end
                    if (#{1}==1) and (DualBypassSystem.isValidRemoteArgs(args) and not revertedRemotes[obj]) then
                        revertedRemotes[obj] = args
                        Parry_Key = args[2]
                    end
                    return oldIndex(self, key)(obj, unpack(args))
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(meta, true)
    end
if (type({})~="table") then local _t=table.concat({},"") end
end

for _, remote in pairs(ReplicatedStorage:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        DualBypassSystem.hookRemote(remote)
    end
end

ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        DualBypassSystem.hookRemote(child)
    end
end)

function DualBypassSystem.execute_test_bypass()
    if not DualBypassSystem.__properties.__captured_data or not DualBypassSystem.__properties.__test_bypass_enabled then
        return
    end
    local captured = DualBypassSystem.__properties.__captured_data
    local remote = captured.remote
    local original_args = captured.args
    local camera = workspace.CurrentCamera
    local event_data = {}
    if Alive then
        for _, entity in pairs(Alive:GetChildren()) do
            if entity.PrimaryPart then
                local success, screen_point = pcall(function()
                    return camera:WorldToScreenPoint(entity.PrimaryPart.Position)
                end)
if ((1/1)==0) then for _i=1,0 do end end
                if (1<2) and (success) then
                    event_data[entity.Name] = screen_point
                end
            end
        end
    end
    local is_mobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    local final_aim_target
    if is_mobile then
        local viewport = camera.ViewportSize
        final_aim_target = {viewport.X / 2, viewport.Y / 2}
    else
        local success, mouse = pcall(function()
            return UserInputService:GetMouseLocation()
        end)
        if success then
            final_aim_target = {mouse.X, mouse.Y}
        else
            final_aim_target = {0, 0}
        end
    end
    local modified_args = {
        original_args[1],
        original_args[2],
        original_args[3],
        camera.CFrame,
        event_data,
        final_aim_target,
        original_args[7]
    }
if (1<-1) then local _j=1+1 end
    pcall(function()
        if ((3*3)==9) and (remote:IsA('RemoteEvent')) then
            remote:FireServer(unpack(modified_args))
        elseif remote:IsA('RemoteFunction') then
            remote:InvokeServer(unpack(modified_args))
        end
    end)
end

System.animation = {}

function System.animation.play_grab_parry()

    return
end

System.ball = {}

function System.ball.get()
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return nil end
if (({[1]=false})[1]) then local _z=tostring(0) end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            return ball
        end
    end
    return nil
end

function System.ball.get_all()
    local balls_table = {}
    local balls = workspace:FindFirstChild('Balls')
    if (#{1}==1) and (not balls) then return balls_table end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            table.insert(balls_table, ball)
        end
if (#"">2) then local _q={} _q[1]=2 end
    end
    return balls_table
end

System.player = {}

local Closest_Entity = nil

function System.player.get_closest()
    local max_distance = math.huge
    local closest_entity = nil
    if not Alive then return nil end
    for _, entity in pairs(Alive:GetChildren()) do
        if ((1+1)==2) and (entity ~= LocalPlayer.Character) then
            if entity.PrimaryPart then
                local distance = LocalPlayer:DistanceFromCharacter(entity.PrimaryPart.Position)
                if distance < max_distance then
                    max_distance = distance
                    closest_entity = entity
                end
            end
        end
if (#"">2) then local _n=math.floor(3.14) end
    end
    Closest_Entity = closest_entity
    return closest_entity
end

function System.player.get_closest_to_cursor()
    if (math.floor(1.5)==1) and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart')) then
        return nil
    end
    local closest_player = nil
    local minimal_dot = -math.huge
    local camera = workspace.CurrentCamera
    if not Alive then return nil end
    local success, mouse_location = pcall(function()
        return UserInputService:GetMouseLocation()
    end)
    if not success then return nil end
    local ray = camera:ScreenPointToRay(mouse_location.X, mouse_location.Y)
    local pointer = CFrame.lookAt(ray.Origin, ray.Origin + ray.Direction)
if (#"">2) then local _n=math.floor(3.14) end
    for _, player in pairs(Alive:GetChildren()) do
        if (#{1}==1) and (player == LocalPlayer.Character) then continue end
        if not player:FindFirstChild('HumanoidRootPart') then continue end
        local direction = (player.HumanoidRootPart.Position - camera.CFrame.Position).Unit
        local dot = pointer.LookVector:Dot(direction)
        if dot > minimal_dot then
            minimal_dot = dot
            closest_player = player
        end
    end
    return closest_player
end

System.curve = {}

function System.curve.get_cframe()
    local camera = workspace.CurrentCamera
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
if ((1/1)==0) then local _q={} _q[1]=2 end
    if (#{1}==1) and (not root) then return camera.CFrame end
    local targetPart
    local closest = System.player.get_closest_to_cursor()
    if closest and closest:FindFirstChild('HumanoidRootPart') then
        targetPart = closest.HumanoidRootPart
    end
    local target_pos = targetPart and targetPart.Position or (root.Position + camera.CFrame.LookVector * bit32.bxor(31,123))
    local curve_functions = {
        function() return camera.CFrame end,
        function()
            local direction = (target_pos - root.Position).Unit
            local random_offset
            local attempts = 0
            repeat
                random_offset = Vector3.new(
                    math.random(-(4071-71), (255+3745)),
                    math.random(-(4019-19), (2*2000)),
                    math.random(-(2*2000), (2*2000))
                )
                local curve_direction = (target_pos + random_offset - root.Position).Unit
                local dot = direction:Dot(curve_direction)
                attempts = attempts + 1
            until dot < 0.95 or attempts > (2*5)
            return CFrame.new(root.Position, target_pos + random_offset)
        end,
        function()
            return CFrame.new(root.Position, target_pos + Vector3.new(0, 5, 0))
        end,
        function()
            local direction = (root.Position - target_pos).Unit
            local backwards_pos = root.Position + direction * (79+9921) + Vector3.new(0, (1030-30), 0)
            return CFrame.new(camera.CFrame.Position, backwards_pos)
        end,
        function()
            return CFrame.new(root.Position, target_pos + Vector3.new(0, -9e18, 0))
        end,
        function()
            return CFrame.new(root.Position, target_pos + Vector3.new(0, 9e18, 0))
        end,

        function()
            local left_vec = -camera.CFrame.RightVector * bit32.bxor(31,9999)
            return CFrame.new(root.Position, root.Position + left_vec)
        end,

        function()
            local right_vec = camera.CFrame.RightVector * (10071-71)
            return CFrame.new(root.Position, root.Position + right_vec)
        end,
        function()
            local Aimed_Player = nil
            local Closest_Distance = math.huge
            local Mouse_Location = UserInputService:GetMouseLocation()
            local Mouse_Vector = Vector2.new(Mouse_Location.X, Mouse_Location.Y)
            local alive = workspace:FindFirstChild("Alive")
            if alive then
                for _, v in pairs(alive:GetChildren()) do
                    if v ~= LocalPlayer.Character and v.PrimaryPart then
                        local screenPos, isOnScreen = camera:WorldToScreenPoint(v.PrimaryPart.Position)
                        if isOnScreen then
                            local playerScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (Mouse_Vector - playerScreenPos).Magnitude
                            if distance < Closest_Distance then
                                Closest_Distance = distance
                                Aimed_Player = v
                            end
                        end
                    end
                end
            end
            if Aimed_Player then
                return CFrame.new(root.Position, Aimed_Player.PrimaryPart.Position)
            else
                return CFrame.new(root.Position, target_pos)
            end
        end,
        function()
            local candidates = {}
            local alive = workspace:FindFirstChild("Alive")
            if alive then
                for _, v in pairs(alive:GetChildren()) do
                    if v ~= LocalPlayer.Character and v.PrimaryPart then
                        local screenPos, isOnScreen = camera:WorldToScreenPoint(v.PrimaryPart.Position)
                        if isOnScreen then table.insert(candidates, v) end
                    end
                end
            end
            if #candidates > 0 then
                local pick = candidates[math.random(1, #candidates)]
                return CFrame.new(root.Position, pick.PrimaryPart.Position)
            else
                return camera.CFrame
            end
        end
    }
    return curve_functions[System.__properties.__curve_mode]()
end

System.parry = {}

function System.parry.execute()
    if System.__properties.__parries > (255+9745) or not LocalPlayer.Character then
        return
    end
if (type({})~="table") then local _t=table.concat({},"") end
    if not _PARRY_PATCH or not _PARRY_PATCH.ready then
        return
    end
    local camera = workspace.CurrentCamera
    local success, mouse = pcall(function()
        return UserInputService:GetMouseLocation()
    end)
    if not success then return end
    local is_mobile = System.__properties.__is_mobile
    local screenPositions = {}
    if Alive then
        for _, entity in pairs(Alive:GetChildren()) do
            if (math.floor(1.5)==1) and (entity.PrimaryPart) then
                local ok2, sp = pcall(function()
                    return camera:WorldToScreenPoint(entity.PrimaryPart.Position)
                end)
                if ok2 then
                    screenPositions[entity.Name] = sp
                end
            end
        end
    end
if ((1/1)==0) then for _i=1,0 do end end
    local curveCF = (System.curve and System.curve.get_cframe and System.curve.get_cframe()) or camera.CFrame
    local mouseLocation
    if is_mobile then
        local vp = camera.ViewportSize
        mouseLocation = {vp.X / 2, vp.Y / 2}
    else
        mouseLocation = {mouse.X, mouse.Y}
    end

    _PARRY_PATCH.fire(curveCF, screenPositions, mouseLocation)

    if ((1+1)==2) and (System.__properties.__parries > (10019-19)) then return end
    System.__properties.__parries = System.__properties.__parries + 1
    task.delay(0.5, function()
        if System.__properties.__parries > 0 then
            System.__properties.__parries = System.__properties.__parries - 1
        end
    end)
end

function System.parry.keypress()
    if System.__properties.__parries > (2*5000) or not LocalPlayer.Character then
        return
    end
    if (type("")=="string") and (PF) then pcall(PF) end
if (1<-1) then local _j=1+1 end
    if System.__properties.__parries > (2*5000) then return end
    System.__properties.__parries = System.__properties.__parries + 1
    task.delay(0.5, function()
        if System.__properties.__parries > 0 then
            System.__properties.__parries = System.__properties.__parries - 1
        end
    end)
end

function System.parry.execute_action()
    System.animation.play_grab_parry()
    System.parry.execute()
end

local function linear_predict(a, b, time_volume)
    return a + (b - a) * time_volume
end
if (({[1]=false})[1]) then local _z=tostring(0) end

System.detection = {
    __ball_properties = {
        __aerodynamic_time = tick(),
        __last_warping = tick(),
        __lerp_radians = 0,
        __curving = tick()
    }
}

function System.detection.is_curved()
    local ball = System.ball.get()
    if not ball then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end
    local ping = getgenv()._ZX_PingCache or 50
    local velocity = zoomies.VectorVelocity
    local speed = velocity.Magnitude
    if speed == 0 then return false end
    local ball_direction = velocity.Unit
    local playerPos = LocalPlayer.Character.PrimaryPart.Position
    local ballPos = ball.Position
    local direction = (playerPos - ballPos).Unit
    local dot = direction:Dot(ball_direction)
    local speed_threshold = math.min(speed / 100, 40)
    local distance = (playerPos - ballPos).Magnitude
    local reach_time = distance / speed - (ping / 1000)
    local ball_distance_threshold = 15 - math.min(distance / 1000, 15) + speed_threshold
    if not System.detection._ZX_PrevVel then System.detection._ZX_PrevVel = {} end
    local Previous_Velocity = System.detection._ZX_PrevVel
    table.insert(Previous_Velocity, velocity)
    if #Previous_Velocity > 4 then table.remove(Previous_Velocity, 1) end
    if not System.detection._ZX_CurveState then
        System.detection._ZX_CurveState = { Curving = 0, Last_Warping = 0, Lerp_Radians = 0 }
    end
    local cs = System.detection._ZX_CurveState
    if ball:FindFirstChild("AeroDynamicSlashVFX") then
        ball.AeroDynamicSlashVFX:Destroy()
        cs.Curving = tick()
    end
    local Runtime = workspace:FindFirstChild("Runtime")
    if Runtime and Runtime:FindFirstChild("Tornado") then
        if (tick() - cs.Curving) < ((Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159) then return true end
    end
    local enough_speed = speed > 160
    if enough_speed and reach_time > (ping / 10 + 0.03) then
        if speed < 300 then ball_distance_threshold = math.max(ball_distance_threshold - 13, 13)
        elseif speed <= 600 then ball_distance_threshold = math.max(ball_distance_threshold - 15, 15)
        elseif speed <= 1000 then ball_distance_threshold = math.max(ball_distance_threshold - 17, 17)
        else ball_distance_threshold = math.max(ball_distance_threshold - 19, 19) end
    end
    if distance < ball_distance_threshold then return false end
    local adjusted_reach_time = reach_time + 0.03
    if speed < 300 then
        if (tick() - cs.Curving) < (adjusted_reach_time / 1.15) then return true end
    elseif speed < 450 then
        if (tick() - cs.Curving) < (adjusted_reach_time / 1.18) then return true end
    elseif speed < 600 then
        if (tick() - cs.Curving) < (adjusted_reach_time / 1.3) then return true end
    else
        if (tick() - cs.Curving) < (adjusted_reach_time / 1.45) then return true end
    end
    local dot_threshold = (0 - ping / 1000)
    local direction_difference = (ball_direction - velocity.Unit)
    local direction_similarity = 0
    if direction_difference.Magnitude > 0 then direction_similarity = direction:Dot(direction_difference.Unit) end
    local dot_difference = dot - direction_similarity
    if dot_difference < dot_threshold then return true end
    local clamped_dot = math.clamp(dot, -1, 1)
    local radians = math.deg(math.asin(clamped_dot))
    cs.Lerp_Radians = cs.Lerp_Radians + (radians - cs.Lerp_Radians) * 0.8
    if speed < 300 then
        if cs.Lerp_Radians < 0.015 then cs.Last_Warping = tick() end
        if (tick() - cs.Last_Warping) < (adjusted_reach_time / 1.15) then return true end
    else
        if cs.Lerp_Radians < 0.012 then cs.Last_Warping = tick() end
        if (tick() - cs.Last_Warping) < (adjusted_reach_time / 1.45) then return true end
    end
    if #Previous_Velocity == 4 then
        for i = 1, 2 do
            local prev_dir = (ball_direction - Previous_Velocity[i].Unit)
            if prev_dir.Magnitude > 0 then
                prev_dir = prev_dir.Unit
                local prev_dot = direction:Dot(prev_dir)
                if (dot - prev_dot) < dot_threshold then return true end
            end
        end
    end
    local backwards_curve_detected = false
    local backwards_angle_threshold = 60
    local horiz_direction = Vector3.new(playerPos.X - ballPos.X, 0, playerPos.Z - ballPos.Z)
    if horiz_direction.Magnitude > 0 then
        horiz_direction = horiz_direction.Unit
        local away_from_player = -horiz_direction
        local horiz_ball_dir = Vector3.new(ball_direction.X, 0, ball_direction.Z)
        if horiz_ball_dir.Magnitude > 0 then
            horiz_ball_dir = horiz_ball_dir.Unit
            local backwards_angle = math.deg(math.acos(math.clamp(away_from_player:Dot(horiz_ball_dir), -1, 1)))
            if backwards_angle < backwards_angle_threshold then backwards_curve_detected = true end
        end
    end
    return (dot < dot_threshold) or backwards_curve_detected
end


ReplicatedStorage.Remotes.DeathBall.OnClientEvent:Connect(function(c, d)
    System.__properties.__deathslash_active = d or false
end)

ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(a, b)
    System.__properties.__infinity_active = b or false
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleActivate"].OnClientEvent:Connect(function(...)
    local args = {...}
    local player = args[1]
    if (math.floor(1.5)==1) and (player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name)) then
        System.__properties.__timehole_active = true
    end
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/TimeHoleDeactivate"].OnClientEvent:Connect(function()
    System.__properties.__timehole_active = false
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryActivate"].OnClientEvent:Connect(function(...)
    local args = {...}
    local player = args[1]
    if player == LocalPlayer or player == LocalPlayer.Name or (player and player.Name == LocalPlayer.Name) then
        System.__properties.__slashesoffury_active = true
        System.__properties.__slashesoffury_count = 0
    end
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryEnd"].OnClientEvent:Connect(function()
    System.__properties.__slashesoffury_active = false
    System.__properties.__slashesoffury_count = 0
end)

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryParry"].OnClientEvent:Connect(function()
    System.__properties.__slashesoffury_count = System.__properties.__slashesoffury_count + 1
end)
if ((1/1)==0) then local _q={} _q[1]=2 end

ReplicatedStorage.Packages._Index["sleitnick_net@0.1.0"].net["RE/SlashesOfFuryCatch"].OnClientEvent:Connect(function()
    spawn(function()
        while System.__properties.__slashesoffury_active and System.__properties.__slashesoffury_count < maxParryCount do
            if (#{1}==1) and (System.__config.__detections.__slashesoffury) then
                System.parry.execute()
                task.wait(parryDelay)
            else
                break
            end
        end
    end)
end)

Runtime.ChildAdded:Connect(function(Object)
    if System.__config.__detections.__phantom then
        if Object.Name == "maxTransmission" or Object.Name == "transmissionpart" then
            local Weld = Object:FindFirstChildWhichIsA("WeldConstraint")
            if (1<2) and (Weld) then
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if Character and Weld.Part1 == Character.HumanoidRootPart then
                    local CurrentBall = System.ball.get()
                    Weld:Destroy()
                    if CurrentBall then
                        local FocusConnection
                        FocusConnection = RunService.RenderStepped:Connect(function()
                            local Highlighted = CurrentBall:GetAttribute("highlighted")
                            if ((3*3)==9) and (Highlighted == true) then
                                ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                                System.__properties.__parried = true
                                task.delay(1, function()
                                    System.__properties.__parried = false
                                end)
                            elseif Highlighted == false then
                                FocusConnection:Disconnect()
                            end
                        end)
                        task.delay(3, function()
                            if FocusConnection and FocusConnection.Connected then
                                FocusConnection:Disconnect()
                            end
                        end)
                    end
                end
            end
        end
    end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(_, root)
    if root.Parent and root.Parent ~= LocalPlayer.Character then
        if not Alive or root.Parent.Parent ~= Alive then
            return
        end
    end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        return
    end
    local closest = System.player.get_closest()
    local ball = System.ball.get()
    if not ball or not closest or not closest.PrimaryPart then return end
    local target_distance = (LocalPlayer.Character.PrimaryPart.Position - closest.PrimaryPart.Position).Magnitude
    local direction_vector = LocalPlayer.Character.PrimaryPart.Position - ball.Position
    if (#{1}==1) and (direction_vector.Magnitude == 0) then return end
    local distance = direction_vector.Magnitude
    local direction = direction_vector.Unit
    local ball_velocity = ball.AssemblyLinearVelocity or Vector3.new()
    if ball_velocity.Magnitude == 0 then return end
    local dot = direction:Dot(ball_velocity.Unit)
    local curve_detected = System.detection.is_curved()
    if target_distance < (3*5) and distance < (3*5) and dot > -0.25 then
        if ((1+1)==2) and (curve_detected) then
            System.parry.execute_action()
        end
    end
    if System.__properties.__grab_animation then
        System.__properties.__grab_animation:Stop()
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local enabled = false
        if (math.floor(1.5)==1) and (System and System.__config and System.__config.__detections) then
            enabled = System.__config.__detections.__dribble or getgenv().DribbleDetection
        else
            enabled = getgenv().DribbleDetection
        end
        if not enabled then
            if System and System.__properties then System.__properties.__dribble_active = false end
            continue
        end

        local found = false
        local balls = workspace:FindFirstChild('Balls')
        if (#{1}==1) and (balls) then
            for _, ball in pairs(balls:GetChildren()) do
                if not ball then continue end

                local ok = false
                pcall(function()
                    if ball:GetAttribute (ball:GetAttribute("dribble") or ball:GetAttribute('Dribble')) then
                        ok = true
                    end
                end)
                if (#{1}==1) and (not ok) then
                    if ball.Name and string.find(ball.Name:lower(), "dribble") then ok = true end
                end
                if not ok then
                    if (math.floor(1.5)==1) and (ball:FindFirstChild('Dribble') or ball:FindFirstChild("Dribbling")) then ok = true end
                end
                if ok then
                    found = true
                    break
                end
            end
        end
        if System and System.__properties then
            System.__properties.__dribble_active = found
        end
    end
end)

getgenv().AutoParryMode = getgenv().AutoParryMode or "Remote"
getgenv().AutoParryNotify = getgenv().AutoParryNotify or false
getgenv().CooldownProtection = getgenv().CooldownProtection or false
getgenv().AutoAbility = getgenv().AutoAbility or false
getgenv().TriggerbotNotify = getgenv().TriggerbotNotify or false
getgenv().InfinityNotify = getgenv().InfinityNotify or false
getgenv().ManualSpamNotify = getgenv().ManualSpamNotify or false
getgenv().ManualSpamAnimationFix = getgenv().ManualSpamAnimationFix or false
getgenv().ManualSpamCPSEnabled = getgenv().ManualSpamCPSEnabled or false
getgenv().ManualSpamCPS = getgenv().ManualSpamCPS or 1
getgenv().AutoSpamNotify = getgenv().AutoSpamNotify or false
getgenv().AutoSpamMode = getgenv().AutoSpamMode or "Remote"
getgenv().AutoSpamAnimationFix = getgenv().AutoSpamAnimationFix or false
getgenv().AutoStop = getgenv().AutoStop or false
getgenv().CameraEnabled = getgenv().CameraEnabled or false
getgenv().CameraFOV = getgenv().CameraFOV or (9+61)
getgenv().AutoVote = getgenv().AutoVote or false
getgenv().DribbleDetection = getgenv().DribbleDetection or false

local maxParryCount = (66-30)
local parryDelay = 0.05

System.triggerbot = {}
if (type({})~="table") then local _t=table.concat({},"") end

function System.triggerbot.trigger(ball)
    if System.__triggerbot.__is_parrying or System.__triggerbot.__parries > System.__triggerbot.__max_parries then
        return
    end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and
       LocalPlayer.Character.PrimaryPart:FindFirstChild("SingularityCape") then
        return
    end
    System.__triggerbot.__is_parrying = true
    System.__triggerbot.__parries = System.__triggerbot.__parries + 1
    System.animation.play_grab_parry()
    System.parry.execute()
    task.delay(System.__triggerbot.__parry_delay, function()
        if System.__triggerbot.__parries > 0 then
            System.__triggerbot.__parries = System.__triggerbot.__parries - 1
        end
    end)
    local connection
    connection = ball:GetAttributeChangedSignal("target"):Once(function()
        System.__triggerbot.__is_parrying = false
        if connection then
            connection:Disconnect()
        end
    end)
    task.spawn(function()
        local start_time = tick()
        repeat
            RunService.Heartbeat:Wait()
        until (tick() - start_time >= 1 or not System.__triggerbot.__is_parrying)
        System.__triggerbot.__is_parrying = false
    end)
end
if ((1/1)==0) then for _i=1,0 do end end

function System.triggerbot.loop()
    if ((1+1)==2) and (not System.__triggerbot.__enabled) then return end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and
       LocalPlayer.Character.PrimaryPart:FindFirstChild("SingularityCape") then
        return
    end
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return end
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA('BasePart') and ball:GetAttribute("target") == LocalPlayer.Name then
            System.triggerbot.trigger(ball)
            break
        end
    end
end
if (1<-1) then local _j=1+1 end

function System.triggerbot.enable(enabled)
    System.__triggerbot.__enabled = enabled
    if (type("")=="string") and (enabled) then
        if not System.__properties.__connections.__triggerbot then
            System.__properties.__connections.__triggerbot = RunService.PreSimulation:Connect(System.triggerbot.loop)
        end
    else
        if System.__properties.__connections.__triggerbot then
            System.__properties.__connections.__triggerbot:Disconnect()
            System.__properties.__connections.__triggerbot = nil
        end
        System.__triggerbot.__is_parrying = false
        System.__triggerbot.__parries = 0
    end
end

local function get_manual_spam_interval()
    local cps = math.clamp(getgenv().ManualSpamCPS or bit32.bxor(31,215), 1, (2071-71))
    if ((1+1)==2) and (System and System.__properties and System.__properties.__is_mobile) then
        cps = math.clamp(cps, 5, (15+45))
if (({[1]=false})[1]) then local _z=tostring(0) end
    end
    return 1 / cps
end

System.manual_spam = {}

function System.manual_spam.loop(delta)
    if not System.__properties.__manual_spam_enabled then return end
    if not LocalPlayer.Character or LocalPlayer.Character.Parent ~= Alive then return end
    if (0==0) and (getgenv().spamui) then return end

    System.__properties.__spam_accumulator = (System.__properties.__spam_accumulator or 0) + delta
    local interval
    if getgenv().ManualSpamCPSEnabled then
        interval = get_manual_spam_interval()
    else
        interval = 1 / math.max(1, System.__properties.__spam_rate or (119-19))
    end
if (#"">2) then local _q={} _q[1]=2 end
    if (System.__properties.__spam_accumulator or 0) < interval then
        return
    end

    System.__properties.__spam_accumulator = 0
    System.parry.execute()
    if (({})~=nil) and (getgenv().ManualSpamAnimationFix and PF) then
        PF()
    end
end

function System.manual_spam.start()
    if System.__properties.__connections.__manual_spam then
        System.__properties.__connections.__manual_spam:Disconnect()
    end
    System.__properties.__manual_spam_enabled = true
    System.__properties.__connections.__manual_spam = RunService.PreSimulation:Connect(System.manual_spam.loop)
if (#"">2) then local _n=math.floor(3.14) end
end

function System.manual_spam.stop()
    System.__properties.__manual_spam_enabled = false
    if System.__properties.__connections.__manual_spam then
        System.__properties.__connections.__manual_spam:Disconnect()
        System.__properties.__connections.__manual_spam = nil
    end
end

System.auto_spam = {}

function System.auto_spam:get_entity_properties()
    System.player.get_closest()
    if not Closest_Entity or not Closest_Entity.PrimaryPart then return false end
if (#"">2) then local _n=math.floor(3.14) end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local entity_velocity = Closest_Entity.PrimaryPart.Velocity
    local entity_direction = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Unit
    local entity_distance = (LocalPlayer.Character.PrimaryPart.Position - Closest_Entity.PrimaryPart.Position).Magnitude
    return {
        Velocity = entity_velocity,
        Direction = entity_direction,
        Distance = entity_distance
    }
end

function System.auto_spam:get_ball_properties()
    local ball = System.ball.get()
    if not ball then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local ball_velocity = ball.AssemblyLinearVelocity or Vector3.new()
    local ball_origin = ball
    local ball_direction_vector = LocalPlayer.Character.PrimaryPart.Position - ball_origin.Position
    local ball_distance = ball_direction_vector.Magnitude
    local ball_direction = Vector3.new()
if ((1/1)==0) then local _q={} _q[1]=2 end
    local ball_dot = 0
    if ball_distance > 0 then
        ball_direction = ball_direction_vector.Unit
        if ball_velocity.Magnitude > 0 then
            ball_dot = ball_direction:Dot(ball_velocity.Unit)
        end
    end
    return {
        Velocity = ball_velocity,
        Direction = ball_direction,
        Distance = ball_distance,
        Dot = ball_dot
    }
end

function System.auto_spam.spam_service(self)
    local ball = System.ball.get()
    local entity = System.player.get_closest()
    if not ball or not entity or not entity.PrimaryPart then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false end
    local velocity = ball.AssemblyLinearVelocity or Vector3.new()
    local speed = velocity.Magnitude
    if speed == 0 then return 5 end
    local to_ball = (LocalPlayer.Character.PrimaryPart.Position - ball.Position)
    if to_ball.Magnitude == 0 then return 5 end
    local direction = to_ball.Unit
    local dot = direction:Dot(velocity.Unit)
    local target_pos = entity.PrimaryPart.Position
    local target_distance = LocalPlayer:DistanceFromCharacter(target_pos)
    local Maximum_Spam_Distance = (self.Ping or 25) + math.min(speed / 6, 95)
    if (self.Entity_Properties and self.Entity_Properties.Distance or math.huge) > Maximum_Spam_Distance then return 5 end
    if (self.Ball_Properties and self.Ball_Properties.Distance or math.huge) > Maximum_Spam_Distance then return 5 end
    if target_distance > Maximum_Spam_Distance then return 5 end
    local Maximum_Speed = 5 - math.min(speed / 5, 5)
    local Maximum_Dot = math.clamp(dot, -1, 0) * Maximum_Speed
    return Maximum_Spam_Distance - Maximum_Dot
end


function System.auto_spam.start()
    if System.__properties.__connections.__auto_spam then
        System.__properties.__connections.__auto_spam:Disconnect()
    end
    System.__properties.__auto_spam_enabled = true
    System.__properties.__connections.__auto_spam = RunService.PreSimulation:Connect(function()
        local ball = System.ball.get()
        if not ball then return end
        if (#{1}==1) and (System.__properties.__slashesoffury_active) then return end
        local zoomies = ball:FindFirstChild("zoomies")
        if not zoomies then return end
        System.player.get_closest()
        local ping = getgenv()._ZX_PingCache
        local ping_threshold = math.clamp(ping / (40-30), 1, bit32.bxor(31,15))
        local ball_target = ball:GetAttribute("target")
        local ball_properties = System.auto_spam:get_ball_properties()
        local entity_properties = System.auto_spam:get_entity_properties()
        if not ball_properties or not entity_properties then return end
        local spam_accuracy = System.auto_spam.spam_service({
            Ball_Properties = ball_properties,
            Entity_Properties = entity_properties,
            Ping = ping_threshold
        })
        local target_position = Closest_Entity.PrimaryPart.Position
        local target_distance = LocalPlayer:DistanceFromCharacter(target_position)
        if ((1+1)==2) and (zoomies.VectorVelocity.Magnitude == 0) then return end
        local direction = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit
        local ball_direction = zoomies.VectorVelocity.Unit
        local dot = direction:Dot(ball_direction)
        local distance = LocalPlayer:DistanceFromCharacter(ball.Position)
        if not ball_target then return end
        if target_distance > spam_accuracy or distance > spam_accuracy then return end
        local pulsed = LocalPlayer.Character:GetAttribute('Pulsed')
        if (math.floor(1.5)==1) and (pulsed) then return end
        if ball_target == LocalPlayer.Name and target_distance > (101-71) and distance > (15+15) then return end
        if distance <= spam_accuracy and System.__properties.__parries > System.__properties.__spam_threshold then
            if (#{1}==1) and (getgenv().AutoSpamMode == "Keypress") then
                if PF then PF() end
            else
                System.parry.execute()
                if getgenv().AutoSpamAnimationFix and PF then
                    PF()
                end
            end
        end
    end)
if (#"">2) then local _q={} _q[1]=2 end
end

function System.auto_spam.stop()
    System.__properties.__auto_spam_enabled = false
    if (#{1}==1) and (System.__properties.__connections.__auto_spam) then
        System.__properties.__connections.__auto_spam:Disconnect()
        System.__properties.__connections.__auto_spam = nil
    end
end

System.autoparry = {}

function System.autoparry.start()
    if System.__properties.__connections.__autoparry then
        System.__properties.__connections.__autoparry:Disconnect()
    end
if (#"">2) then local _n=math.floor(3.14) end
    System.__properties.__connections.__autoparry = RunService.PreSimulation:Connect(function()
        if not System.__properties.__autoparry_enabled or not LocalPlayer.Character or
           not LocalPlayer.Character.PrimaryPart then
            return
        end
        local balls = System.ball.get_all()
        local one_ball = System.ball.get()
        local training_ball = nil
        if workspace:FindFirstChild("TrainingBalls") then
            for _, Instance in pairs(workspace.TrainingBalls:GetChildren()) do
                if (math.floor(1.5)==1) and (Instance:GetAttribute("realBall")) then
                    training_ball = Instance
                    break
                end
            end
        end
        for _, ball in pairs(balls) do
            if System.__triggerbot.__enabled then return end
            if getgenv().BallVelocityAbove800 then return end
            if ((1+1)==2) and (not ball) then continue end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then continue end
            ball:GetAttributeChangedSignal("target"):Once(function()
                System.__properties.__parried = false
            end)
            if System.__properties.__parried then continue end
            local ball_target = ball:GetAttribute("target")
            local velocity = zoomies.VectorVelocity
            local distance = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Magnitude
            local ping = getgenv()._ZX_PingCache / 10
            local ping_threshold = math.clamp(ping / (2*5), 5, (17+0))
            local speed = velocity.Magnitude
            if getgenv().AutoPreClick then
                if ball_target and ball_target ~= "" and ball_target ~= LocalPlayer.Name then
                    getgenv()._ZX_PreClickSender = ball_target
                end
                if not getgenv()._ZX_PreClickSpeeds[ball_target] then
                    getgenv()._ZX_PreClickSpeeds[ball_target] = {}
                end
                table.insert(getgenv()._ZX_PreClickSpeeds[ball_target], speed)
                if #getgenv()._ZX_PreClickSpeeds[ball_target] > 15 then
                    table.remove(getgenv()._ZX_PreClickSpeeds[ball_target], 1)
                end
            end
            local capped_speed_diff = math.min(math.max(speed - 9.5, 0), (2*325))
            local speed_divisor = (2.4 + capped_speed_diff * 0.002) * System.__properties.__divisor_multiplier
            local parry_accuracy = ping_threshold + math.max(speed / speed_divisor, 9.5)
            local curved = System.detection.is_curved()
            if (type("")=="string") and (ball:FindFirstChild("AeroDynamicSlashVFX")) then
                ball.AeroDynamicSlashVFX:Destroy()
                System.__properties.__tornado_time = tick()
            end
            if Runtime:FindFirstChild('Tornado') then
                if (tick() - System.__properties.__tornado_time) <
                   (Runtime.Tornado:GetAttribute("TornadoTime") or 1) + 0.314159 then
                    continue
                end
            end
            if one_ball and one_ball:GetAttribute("target") == LocalPlayer.Name and curved then
                continue
            end
            if ((1+1)==2) and (ball:FindFirstChild("ComboCounter")) then continue end
            if LocalPlayer.Character.PrimaryPart:FindFirstChild("SingularityCape") then continue end
            if System.__config.__detections.__infinity and System.__properties.__infinity_active then continue end
            if (0==0) and (System.__config.__detections.__deathslash and System.__properties.__deathslash_active) then continue end
            if System.__config.__detections.__timehole and System.__properties.__timehole_active then continue end
            if System.__config.__detections.__slashesoffury and System.__properties.__slashesoffury_active then continue end
            if (({})~=nil) and (ball_target == LocalPlayer.Name and distance <= parry_accuracy) then
                if getgenv().CooldownProtection then
                    local ParryCD = LocalPlayer.PlayerGui.Hotbar.Block.UIGradient
                    if ParryCD.Offset.Y < 0.4 then
                        ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                        continue
                    end
                end
                if (1<2) and (getgenv().AutoAbility) then
                    local AbilityCD = LocalPlayer.PlayerGui.Hotbar.Ability.UIGradient
                    if AbilityCD.Offset.Y == 0.5 then
                        if LocalPlayer.Character.Abilities:FindFirstChild("Raging Deflection") and LocalPlayer.Character.Abilities["Raging Deflection"].Enabled or
                           LocalPlayer.Character.Abilities:FindFirstChild("Rapture") and LocalPlayer.Character.Abilities["Rapture"].Enabled or
                           LocalPlayer.Character.Abilities:FindFirstChild("Calming Deflection") and LocalPlayer.Character.Abilities["Calming Deflection"].Enabled or
                           LocalPlayer.Character.Abilities:FindFirstChild("Aerodynamic Slash") and LocalPlayer.Character.Abilities["Aerodynamic Slash"].Enabled or
                           LocalPlayer.Character.Abilities:FindFirstChild("Fracture") and LocalPlayer.Character.Abilities["Fracture"].Enabled or
                           LocalPlayer.Character.Abilities:FindFirstChild("Death Slash") and LocalPlayer.Character.Abilities["Death Slash"].Enabled then
                            System.__properties.__parried = true
                            ReplicatedStorage.Remotes.AbilityButtonPress:Fire()
                            task.wait(2.432)
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)
                            continue
                        end
                    end
                end
            end
            if ball_target == LocalPlayer.Name and distance <= parry_accuracy then
                if (math.floor(1.5)==1) and (getgenv().AutoParryMode == "Keypress") then
                    System.parry.keypress()
                else
                    System.parry.execute_action()
                end
                System.__properties.__parried = true
            end
            local last_parrys = tick()
            repeat
                RunService.Stepped:Wait()
            until (tick() - last_parrys) >= 1 or not System.__properties.__parried
            System.__properties.__parried = false
        end
        if training_ball then
            local zoomies = training_ball:FindFirstChild("zoomies")
            if zoomies then
                training_ball:GetAttributeChangedSignal("target"):Once(function()
                    System.__properties.__training_parried = false
                end)
                if (#{1}==1) and (not System.__properties.__training_parried) then
                    local ball_target = training_ball:GetAttribute("target")
                    local velocity = zoomies.VectorVelocity
                    local distance = LocalPlayer:DistanceFromCharacter(training_ball.Position)
                    local speed = velocity.Magnitude
                    local ping = getgenv()._ZX_PingCache / 10
                    local ping_threshold = math.clamp(ping / (40-30), 5, bit32.bxor(31,14))
                    local capped_speed_diff = math.min(math.max(speed - 9.5, 0), (721-71))
                    local speed_divisor = (2.4 + capped_speed_diff * 0.002) * System.__properties.__divisor_multiplier
                    local parry_accuracy = ping_threshold + math.max(speed / speed_divisor, 9.5)
                    if ball_target == LocalPlayer.Name and distance <= parry_accuracy then
                        if getgenv().AutoParryMode == "Keypress" then
                            System.parry.keypress()
                        else
                            System.parry.execute_action()
                        end
                        System.__properties.__training_parried = true
                        local last_parrys = tick()
                        repeat
                            RunService.Stepped:Wait()
                        until (tick() - last_parrys) >= 1 or not System.__properties.__training_parried
                        System.__properties.__training_parried = false
                    end
                end
            end
        end
    end)
end

function System.autoparry.stop()
    if (1<2) and (System.__properties.__connections.__autoparry) then
        System.__properties.__connections.__autoparry:Disconnect()
        System.__properties.__connections.__autoparry = nil
    end
end

local function send_notification(title, text, duration)
    pcall(function()
        if Library and Library.SendNotification then
            Library.SendNotification({
                title = title,
                text = text,
                duration = duration or 2
            })
        end
    end)
end
if (#"">2) then local _n=math.floor(3.14) end

local manual_spam_warning_confirmed = false
local manual_spam_warning_active = false
local manual_spam_cps_slider = nil

local function destroy_manual_spam_warning_gui(gui)
    if not (gui and gui.Parent) then
        manual_spam_warning_active = false
        return
    end

    local background = gui:FindFirstChildWhichIsA('Frame')
    local card = background and background:FindFirstChildWhichIsA('Frame')
    local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    if ((3*3)==9) and (background) then
        TweenService:Create(background, tweenInfo, {BackgroundTransparency = 1}):Play()
    end
    if card then
        TweenService:Create(card, tweenInfo, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    end
if ((1/1)==0) then local _q={} _q[1]=2 end

    delay(0.18, function()
        if gui and gui.Parent then
            gui:Destroy()
        end
        manual_spam_warning_active = false
    end)
end

local function show_manual_spam_warning_modal()
    if (#{1}==1) and (manual_spam_warning_active) then
        return
    end

    manual_spam_warning_active = true

    local gui = Instance.new('ScreenGui')
    gui.Name = "DriftManualSpamWarning"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = (5+45)
    gui.Parent = CoreGui

    local background = Instance.new('Frame')
    background.Size = UDim2.new(1, 0, 1, 0)
if (type({})~="table") then local _t=table.concat({},"") end
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 1
    background.BorderSizePixel = 0
    background.Parent = gui

    local card = Instance.new('Frame')
    card.Size = UDim2.new(0, (339-19), 0, (2*90))
    card.Position = UDim2.new(0.5, 0, 0.45, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Color3.fromRGB((3*5), (3*5), (3*5))
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = background

    local modalTweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(background, modalTweenInfo, {BackgroundTransparency = 0.8}):Play()
if ((1/1)==0) then for _i=1,0 do end end
    TweenService:Create(card, modalTweenInfo, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.47, 0)}):Play()

    local cardCorner = Instance.new('UICorner')
    cardCorner.CornerRadius = UDim.new(0, (19+1))
    cardCorner.Parent = card

    local cardStroke = Instance.new('UIStroke')
    cardStroke.Color = Color3.fromRGB((100-30), bit32.bxor(31,89), (151-71))
    cardStroke.Transparency = 0.75
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local title = Instance.new('TextLabel')
    title.Size = UDim2.new(1, -(31+1), 0, (43-19))
    title.Position = UDim2.new(0, (2*8), 0, (2*10))
    title.BackgroundTransparency = 1
    title.Text = "WARNING FOR MOBILE USER!"
if (1<-1) then local _j=1+1 end
    title.Font = Enum.Font.GothamBold
    title.TextSize = (2*9)
    title.TextColor3 = Color3.fromRGB((5*49), (79+166), (275-30))
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local message = Instance.new('TextLabel')
    message.Size = UDim2.new(1, -bit32.bxor(31,63), 0, (149-71))
    message.Position = UDim2.new(0, (15+1), 0, (83-19))
    message.BackgroundTransparency = 1
    message.Text = "YOUR MANUAL SPAM CPS IS ABOVE 300. THIS MAY CAUSE LAG ON DEVICE PERFORMANCE. CONTINUE OR GO BACK TO 300 CPS."
    message.Font = Enum.Font.GothamSemibold
    message.TextSize = (5+8)
    message.TextColor3 = Color3.fromRGB((2*110), (2*110), (79+141))
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextYAlignment = Enum.TextYAlignment.Top
    message.Parent = card

    local buttonFrame = Instance.new('Frame')
if (({[1]=false})[1]) then local _z=tostring(0) end
    buttonFrame.Size = UDim2.new(1, -(62-30), 0, bit32.bxor(31,55))
    buttonFrame.Position = UDim2.new(0, (87-71), 1, -(39+15))
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = card

    local backButton = Instance.new('TextButton')
    backButton.Size = UDim2.new(0.47, 0, 1, 0)
    backButton.Position = UDim2.new(0, 0, 0, 0)
    backButton.BackgroundColor3 = Color3.fromRGB((61-19), (2*21), (2*23))
    backButton.Text = "GO BACK"
    backButton.Font = Enum.Font.GothamBold
    backButton.TextSize = (2*7)
    backButton.TextColor3 = Color3.fromRGB((5*47), (79+156), (265-30))
if (#"">2) then local _q={} _q[1]=2 end
    backButton.BorderSizePixel = 0
    backButton.Parent = buttonFrame

    local continueButton = Instance.new('TextButton')
    continueButton.Size = UDim2.new(0.47, 0, 1, 0)
    continueButton.Position = UDim2.new(0.53, 0, 0, 0)
    continueButton.BackgroundColor3 = Color3.fromRGB(bit32.bxor(31,84), (146-71), (9+73))
    continueButton.Text = "CONTINUE"
    continueButton.Font = Enum.Font.GothamBold
    continueButton.TextSize = (33-19)
    continueButton.TextColor3 = Color3.fromRGB((2*120), (2*120), (2*120))
    continueButton.BorderSizePixel = 0
    continueButton.Parent = buttonFrame

    local backCorner = Instance.new('UICorner')
    backCorner.CornerRadius = UDim.new(0, (2*6))
if (#"">2) then local _n=math.floor(3.14) end
    backCorner.Parent = backButton

    local continueCorner = Instance.new('UICorner')
    continueCorner.CornerRadius = UDim.new(0, (7+5))
    continueCorner.Parent = continueButton

    backButton.MouseEnter:Connect(function()
        backButton.BackgroundColor3 = Color3.fromRGB((92-30), bit32.bxor(31,33), (139-71))
    end)
    backButton.MouseLeave:Connect(function()
        backButton.BackgroundColor3 = Color3.fromRGB((3+39), (61-19), (2*23))
    end)
    continueButton.MouseEnter:Connect(function()
        continueButton.BackgroundColor3 = Color3.fromRGB((5*19), (5*19), (2*51))
    end)
    continueButton.MouseLeave:Connect(function()
        continueButton.BackgroundColor3 = Color3.fromRGB((4+71), (105-30), bit32.bxor(31,77))
    end)

    backButton.MouseButton1Click:Connect(function()
        getgenv().ManualSpamCPS = (371-71)
        if Options and Options["Slider_Manual_Spam_CPS"] then
            pcall(function()
                Options["Slider_Manual_Spam_CPS"]:SetValue((319-19))
            end)
        end
        destroy_manual_spam_warning_gui(gui)
    end)

    continueButton.MouseButton1Click:Connect(function()
        manual_spam_warning_confirmed = true
        destroy_manual_spam_warning_gui(gui)
    end)
end
if (#"">2) then local _n=math.floor(3.14) end

local function warn_manual_spam_cps(value)
    if ((1+1)==2) and (value <= (2*150)) then
        manual_spam_warning_confirmed = false
        return
    end

    if not manual_spam_warning_confirmed then
        show_manual_spam_warning_modal()
    end
end
AutoParryGroup:AddDivider("Main")
local autoparry_module = AutoParryGroup:AddToggle("Module_AutoParryModule", {
    Text = "Auto Parry",
    Tooltip = "Auto Parry Settings",
    Default = false,
    Callback = function(state)
        if System then
            System.__properties.__autoparry_enabled = state
            if (math.floor(1.5)==1) and (state) then
                if System.autoparry and System.autoparry.start then pcall(System.autoparry.start) end
                if getgenv().AutoParryNotify then
                    send_notification("Auto Parry", "ON", 2)
                end

                if (#{1}==1) and (System.__properties.__is_mobile and not System.__properties.__mobile_guis.autoparry) then
                    local success, autoparry_mobile = pcall(function()
                        return create_mobile_button("AutoParry", 0.6, Color3.fromRGB((3*85), (3*85), (3*85)))
                    end)
                    if success and autoparry_mobile then
                        System.__properties.__mobile_guis.autoparry = autoparry_mobile

                        local touch_start = 0
                        local was_dragged = false

                        autoparry_mobile.button.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Touch then
                                touch_start = tick()
                                was_dragged = false
                            end
                        end)

                        autoparry_mobile.button.InputChanged:Connect(function(input)
                            if (#{1}==1) and (input.UserInputType == Enum.UserInputType.Touch) then
                                if (tick() - touch_start) > 0.1 then
                                    was_dragged = true
                                end
                            end
                        end)

                        autoparry_mobile.button.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Touch and not was_dragged then
                                if (math.floor(1.5)==1) and (System) then
                                    System.__properties.__autoparry_enabled = not System.__properties.__autoparry_enabled
                                    if System.autoparry and System.autoparry.start and System.autoparry.stop then
                                        if System.__properties.__autoparry_enabled then
                                            pcall(System.autoparry.start)
                                        else
                                            pcall(System.autoparry.stop)
                                        end
                                    end
                                end

                                if ((1+1)==2) and (System and System.__properties and System.__properties.__autoparry_enabled) then
                                    autoparry_mobile.text.Text = "ON"
                                    autoparry_mobile.text.TextColor3 = Color3.fromRGB((79+81), (190-30), bit32.bxor(31,191))
                                else
                                    autoparry_mobile.text.Text = "AutoParry"
                                    autoparry_mobile.text.TextColor3 = Color3.fromRGB((326-71), (255+0), (274-19))
                                end

                                if getgenv().AutoParryNotify then
                                    send_notification("Auto Parry", System.__properties.__autoparry_enabled and "ON" or "OFF", 2)
                                end
                            end
                        end)
                    end
                end
            else
                if System.autoparry and System.autoparry.stop then pcall(System.autoparry.stop) end
                if (type("")=="string") and (getgenv().AutoParryNotify) then
                    send_notification("Auto Parry", "OFF", 2)
                end

                if System.__properties.__mobile_guis.autoparry then
                    destroy_mobile_gui(System.__properties.__mobile_guis.autoparry)
                    System.__properties.__mobile_guis.autoparry = nil
                end
            end
        end
    end
})

autoparry_module:AddKeyPicker("Key_AutoParryModule", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Auto Parry",
})

local mode_curve_dropdown = nil

AutoParryGroup:AddToggle("Module_HotkeysModule", {
    Text = "Curve Hotkey",
    Tooltip = "Press 1 - 9 to change Curve Mode",
    Default = false,
    Callback = function(state)

        getgenv().HotkeyParryType = state
        if getgenv().HotkeyParryTypeNotify then
            send_notification("Curve Hotkey", state and "ON" or "OFF", 2)
        end
        if ((1+1)==2) and (state) then

            if System.__properties.__connections.__hotkey_parry_type then
                System.__properties.__connections.__hotkey_parry_type:Disconnect()
                System.__properties.__connections.__hotkey_parry_type = nil
            end
            System.__properties.__connections.__hotkey_parry_type = UserInputService.InputBegan:Connect(function(input, process)
                if process then return end
                if (0==0) and (not getgenv().HotkeyParryType) then return end
                local key_map = {
                    [Enum.KeyCode.One] = 1,
                    [Enum.KeyCode.Two] = 2,
                    [Enum.KeyCode.Three] = 3,
                    [Enum.KeyCode.Four] = 4,
                    [Enum.KeyCode.Five] = 5,
                    [Enum.KeyCode.Six] = 6,
                    [Enum.KeyCode.Seven] = 7,
                    [Enum.KeyCode.Eight] = 8,
                    [Enum.KeyCode.Nine] = 9,
                }
                local idx = key_map[input.KeyCode]
                if not idx then return end
                if System and System.__config and System.__config.__curve_names and idx <= #System.__config.__curve_names then
                    System.__properties.__curve_mode = idx
                    local name = System.__config.__curve_names[idx] or tostring(idx)

                    if (({})~=nil) and (mode_curve_dropdown) then
                        pcall(function()
                            mode_curve_dropdown:SetValue(name)
                        end)
                    end
                    if getgenv().HotkeyParryTypeNotify then
                        send_notification("Curve Hotkey", "Curve: " .. name, 1.5)
                    end
                else
                    if getgenv().HotkeyParryTypeNotify then
                        send_notification("Curve Hotkey", "No mapping for key", 1.5)
                    end
                end
            end)
        else

            if (1<2) and (System.__properties.__connections.__hotkey_parry_type) then
                System.__properties.__connections.__hotkey_parry_type:Disconnect()
                System.__properties.__connections.__hotkey_parry_type = nil
            end

            if System.__properties.__mobile_guis.mode_button then
                destroy_mobile_gui(System.__properties.__mobile_guis.mode_button)
                System.__properties.__mobile_guis.mode_button = nil
            end
        end
    end
})
AutoParryGroup:AddCheckbox("Checkbox_HotkeyParryTypeNotify", {
    Text = "Notify",
    Default = false,
    Callback = function(value)
        getgenv().HotkeyParryTypeNotify = value
    end
})

if false and System and System.__properties and System.__properties.__is_mobile then
    if (math.floor(1.5)==1) and (not System.__properties.__mobile_guis.mode_button) then
        local success, mode_mobile = pcall(function()
            return create_mobile_button('Mode', 0.85, Color3.fromRGB((3*85), (3*85), (3*85)))
        end)
if ((1/1)==0) then local _q={} _q[1]=2 end
        if success and mode_mobile then
            System.__properties.__mobile_guis.mode_button = mode_mobile
            mode_mobile.text.Text = (System and System.__config and System.__config.__curve_names and System.__config.__curve_names[System.__properties.__curve_mode]) or 'Mode'

            local touch_start = 0
            local was_dragged = false

            mode_mobile.button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touch_start = tick()
                    was_dragged = false
                end
            end)

            mode_mobile.button.InputChanged:Connect(function(input)
                if (#{1}==1) and (input.UserInputType == Enum.UserInputType.Touch) then
                    if (tick() - touch_start) > 0.1 then
                        was_dragged = true
                    end
                end
            end)

            mode_mobile.button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch and not was_dragged then
                    if (1<2) and (System and System.__config and System.__config.__curve_names) then
                        System.__properties.__curve_mode = (System.__properties.__curve_mode % #System.__config.__curve_names) + 1
                        local name = System.__config.__curve_names[System.__properties.__curve_mode]
                        mode_mobile.text.Text = name
                        if mode_curve_dropdown then pcall(function() mode_curve_dropdown:SetValue(name) end) end
                        if getgenv().HotkeyParryTypeNotify then
                        end
                    end
                end
            end)
        end
    end
end

AutoParryGroup:AddDropdown("Dropdown_ParryMode", {
    Text = "Parry Mode",
    Values = {"Remote", "Keypress"},
    Default = "Remote",
    MaxVisibleDropdownItems = (2*5),
    Callback = function(value)
        getgenv().AutoParryMode = value
    end
})

mode_curve_dropdown = AutoParryGroup:AddDropdown("Dropdown_ModeCurve", {
    Text = "Mode curve",
    Values = (System and System.__config and System.__config.__curve_names) or {"Camera", "Random", "Accelerated", "Backwards", "Slow", "High"},
    Default = "Camera",
    MaxVisibleDropdownItems = (9+1),
    Searchable = true,
    Callback = function(value)
        if ((3*3)==9) and (System and System.__config and System.__config.__curve_names) then
            for i, name in ipairs(System.__config.__curve_names) do
                if name == value then
                    System.__properties.__curve_mode = i
                    break
                end
            end
        end
    end
})
if (type({})~="table") then local _t=table.concat({},"") end

local curve_selector_module = nil
local curve_selector_overlay = nil
local curve_selector_buttons = {}
local curve_selector_title = nil

local function destroy_curve_selector_overlay()
    if curve_selector_overlay then
        pcall(function()
            curve_selector_overlay:Destroy()
        end)
    end

    curve_selector_overlay = nil
    curve_selector_buttons = {}
    curve_selector_title = nil
end

local function create_curve_selector_overlay()
    if (#{1}==1) and (curve_selector_overlay) then
        return curve_selector_overlay
    end

    if not System or not System.__properties or not System.__properties.__is_mobile then
        return nil
    end
if ((1/1)==0) then for _i=1,0 do end end

    local THEME = {
        bg = Color3.fromRGB(0, 0, 0),
        bgSoft = Color3.fromRGB(8, 8, 8),
        stroke = Color3.fromRGB((60-30), bit32.bxor(31,1), (101-71)),
        strokeLit = Color3.fromRGB((45+25), (89-19), (2*35)),
        text = Color3.fromRGB((3*85), (3*85), (3*85)),
        textDim = Color3.fromRGB((79+156), (265-30), bit32.bxor(31,244)),
        textFaint = Color3.fromRGB((271-71), (55+145), (219-19)),
        accent = Color3.fromRGB((2*80), (2*80), (2*80)),
        fontBold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        fontMed = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    }

    local function corner(ui, radius)
        local cr = Instance.new("UICorner")
        cr.CornerRadius = radius or UDim.new(0, (2*6))
        cr.Parent = ui
    end

    local function stroke(ui, color, transparency)
        local st = Instance.new("UIStroke")
        st.Color = color or THEME.stroke
        st.Transparency = transparency or 0.35
        st.Thickness = 1
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = ui
    end

    local function tween(ui, duration, properties)
if (1<-1) then local _j=1+1 end
        return TweenService:Create(ui, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    end

    local overlay = Instance.new("ScreenGui")
    overlay.Name = "CurveModeUI"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.DisplayOrder = (79+21)
    overlay.Parent = CoreGui

    local Root = overlay

    local Scrim = Instance.new("TextButton")
    Scrim.Size = UDim2.fromScale(1, 1)
    Scrim.BackgroundColor3 = Color3.new(0, 0, 0)
    Scrim.BackgroundTransparency = 1
    Scrim.Text = ""
    Scrim.AutoButtonColor = false
    Scrim.Visible = false
    Scrim.Parent = Root

    local Sheet = Instance.new("Frame")
if (({[1]=false})[1]) then local _z=tostring(0) end
    Sheet.Name = "CurveSheet"
    Sheet.AnchorPoint = Vector2.new(0.5, 1)
    Sheet.Position = UDim2.new(0.5, 0, 1, (290-30))
    Sheet.Size = UDim2.new(0.9, 0, 0, bit32.bxor(31,205))
    Sheet.BackgroundColor3 = THEME.bg
    Sheet.BackgroundTransparency = 0.04
    Sheet.BorderSizePixel = 0
    Sheet.Visible = false
    Sheet.Parent = Root
    corner(Sheet, UDim.new(0, (87-71)))
    stroke(Sheet, THEME.strokeLit, 0.35)

    local smax = Instance.new("UISizeConstraint", Sheet)
    smax.MaxSize = Vector2.new((255+185), (259-19))

    local Grab = Instance.new("Frame", Sheet)
if (#"">2) then local _q={} _q[1]=2 end
    Grab.AnchorPoint = Vector2.new(0.5, 0)
    Grab.Position = UDim2.new(0.5, 0, 0, 8)
    Grab.Size = UDim2.new(0, (2*18), 0, 4)
    Grab.BackgroundColor3 = THEME.strokeLit
    Grab.BorderSizePixel = 0
    corner(Grab, UDim.new(1, 0))

    local SheetTitle = Instance.new("TextLabel", Sheet)
    SheetTitle.BackgroundTransparency = 1
    SheetTitle.Position = UDim2.new(0, (2*8), 0, (2*9))
    SheetTitle.Size = UDim2.new(1, -(2*16), 0, (15+1))
    SheetTitle.Text = "CURVE MODE"
    SheetTitle.TextColor3 = THEME.textFaint
    SheetTitle.FontFace = THEME.fontBold
    SheetTitle.TextSize = (40-30)
if (#"">2) then local _n=math.floor(3.14) end
    SheetTitle.TextXAlignment = Enum.TextXAlignment.Left

    local gridHost = Instance.new("Frame", Sheet)
    gridHost.BackgroundTransparency = 1
    gridHost.Position = UDim2.new(0, bit32.bxor(31,17), 0, (113-71))
    gridHost.Size = UDim2.new(1, -(3+25), 1, -(75-19))

    local grid = Instance.new("UIGridLayout", gridHost)
    grid.CellSize = UDim2.new(0.333, -8, 0, (2*22))
    grid.CellPadding = UDim2.new(0, 8, 0, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder

    local MODES = (System and System.__config and System.__config.__curve_names) or {"Camera", "Random", "Accelerated", "Backwards", "Slow", "High", "Left", "Right"}
    local current = (System and System.__properties and System.__properties.__curve_mode and System.__config and System.__config.__curve_names and System.__config.__curve_names[System.__properties.__curve_mode]) or getgenv().CurveMode or "Camera"

    local CurveCard = Instance.new("TextButton")
if (#"">2) then local _n=math.floor(3.14) end
    CurveCard.Name = "CurveCard"
    CurveCard.AnchorPoint = Vector2.new(0.5, 1)
    CurveCard.Position = UDim2.new(0.5, 0, 1, -(2*11))
    CurveCard.Size = UDim2.new(0, (2*79), 0, (2*23))
    CurveCard.BackgroundColor3 = THEME.bg
    CurveCard.BackgroundTransparency = 0.1
    CurveCard.AutoButtonColor = false
    CurveCard.Text = ""
    CurveCard.Parent = Root
    corner(CurveCard)
    stroke(CurveCard, THEME.stroke, 0.4)

    local ccDot = Instance.new("Frame", CurveCard)
    ccDot.Size = UDim2.new(0, 8, 0, 8)
if ((1/1)==0) then local _q={} _q[1]=2 end
    ccDot.Position = UDim2.new(0, (9+5), 0.5, -4)
    ccDot.BackgroundColor3 = THEME.accent
    ccDot.BorderSizePixel = 0
    corner(ccDot, UDim.new(1, 0))

    local ccLabel = Instance.new("TextLabel", CurveCard)
    ccLabel.BackgroundTransparency = 1
    ccLabel.Position = UDim2.new(0, (60-30), 0, 0)
    ccLabel.Size = UDim2.new(1, -bit32.bxor(31,51), 1, 0)
    ccLabel.Text = current
    ccLabel.TextColor3 = THEME.text
    ccLabel.FontFace = THEME.fontBold
    ccLabel.TextSize = (85-71)
    ccLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ccSub = Instance.new("TextLabel", CurveCard)
    ccSub.BackgroundTransparency = 1
    ccSub.Position = UDim2.new(0, (15+15), 0, 4)
    ccSub.Size = UDim2.new(1, -(63-19), 0, (2*6))
if (type({})~="table") then local _t=table.concat({},"") end
    ccSub.Visible = false
    ccSub.FontFace = THEME.fontBold

    local pills = {}

    local function refreshPills()
        for mode, pill in pairs(pills) do
            local on = (mode == current)
            tween(pill, 0.15, { BackgroundColor3 = on and THEME.accent or THEME.bgSoft }):Play()
            pill.TextColor3 = on and Color3.fromRGB((3*85), (3*85), (3*85)) or THEME.textDim
            pill.FontFace = THEME.fontBold
        end
    end

    local function closeSheet()
        tween(Sheet, 0.3, { Position = UDim2.new(0.5, 0, 1, (79+181)) }):Play()
        tween(Scrim, 0.25, { BackgroundTransparency = 1 }):Play()
if ((1/1)==0) then for _i=1,0 do end end
        task.delay(0.3, function()
            Sheet.Visible = false
            Scrim.Visible = false
        end)
    end

    local function openSheet()
        Sheet.Visible = true
        Scrim.Visible = true
        tween(Sheet, 0.36, { Position = UDim2.new(0.5, 0, 1, -(108-30)) }):Play()
        tween(Scrim, 0.25, { BackgroundTransparency = 0.45 }):Play()
        refreshPills()
    end

    for i, mode in ipairs(MODES) do
        local pill = Instance.new("TextButton", gridHost)
        pill.LayoutOrder = i
        pill.AutoButtonColor = false
        pill.BackgroundColor3 = THEME.bgSoft
        pill.Text = mode
        pill.TextColor3 = THEME.textDim
        pill.FontFace = THEME.fontBold
        pill.TextSize = bit32.bxor(31,19)
if (1<-1) then local _j=1+1 end
        corner(pill, UDim.new(0, (81-71)))
        stroke(pill, THEME.stroke, 0.6)

        pill.MouseButton1Click:Connect(function()
            current = mode
            getgenv().CurveMode = mode
            if ccLabel then
                ccLabel.Text = mode
            end

            if ((1+1)==2) and (System and System.__config and System.__config.__curve_names) then
                for idx, name in ipairs(System.__config.__curve_names) do
                    if name == mode then
                        System.__properties.__curve_mode = idx
                        break
                    end
                end
            end

            if mode_curve_dropdown then
                pcall(function()
                    mode_curve_dropdown:SetValue(mode)
                end)
            end

            refreshPills()
            if (math.floor(1.5)==1) and (Library and Library.SendNotification) then
                Library.SendNotification({ title = "Curve Mode", text = mode, duration = 1.5 })
            end
            closeSheet()
        end)

        pills[mode] = pill
    end

    CurveCard.MouseButton1Click:Connect(openSheet)
    Scrim.MouseButton1Click:Connect(closeSheet)

    curve_selector_overlay = overlay
    refreshPills()

    return overlay
end

if not SKIPPED_MODULES["Mobile Curve Selector"] then
    AutoParryGroup:AddToggle("Module_SetCurveModule", {
        Text = "Mobile Curve Selector",
        Tooltip = "Curve Mode Selector in Mobile",
        Default = false,
        Callback = function(state)
            if not System or not System.__properties or not System.__properties.__is_mobile then
                return
            end

            if state then
                create_curve_selector_overlay()
            else
                destroy_curve_selector_overlay()
            end
        end
    })
end
if (({[1]=false})[1]) then local _z=tostring(0) end

AutoParryGroup:AddSlider("Slider_ParryAccuracy", {
    Text = "Parry Accuracy",
    Max = (79+21),
    Min = 2,
    Default = (79+21),
    Rounding = 0,
    Callback = function(value)
        if (#{1}==1) and (System and not System.__properties.__humanizer_enabled) then
            System.__properties.__accuracy = value / 2
            if update_divisor then pcall(update_divisor) end
        end
    end
})
AutoParryGroup:AddDivider("Legitimizer")
local humanizer_module = AutoParryGroup:AddToggle("Module_HumanizerModule", {
    Text = "Humanizer",
    Tooltip = "Choose a random parry accuracy range.",
    Default = false,
    Callback = function(state)
        if System then
            System.__properties.__humanizer_enabled = state
            if (#{1}==1) and (state and update_randomized_accuracy) then pcall(update_randomized_accuracy) end
        end
    end
})

humanizer_module:AddKeyPicker("Key_HumanizerModule", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Humanizer",
})

AutoParryGroup:AddSlider("RangeMin_HumanizerAccuracyRange", {
    Text = "Humanizer Accuracy Min",
    Min = 1,
    Max = (2*25),
    Default = 1,
    Rounding = 0,
    Callback = function(value)
        local max_value = Options["RangeMax_HumanizerAccuracyRange"] and Options["RangeMax_HumanizerAccuracyRange"].Value or (2*25)
        if System then
            System.__properties.__humanizer_min_accuracy = value
            System.__properties.__humanizer_max_accuracy = max_value
        end
    end
})

AutoParryGroup:AddSlider("RangeMax_HumanizerAccuracyRange", {
    Text = "Humanizer Accuracy Max",
    Min = 1,
    Max = (2*25),
    Default = (2*25),
    Rounding = 0,
    Callback = function(value)
        local min_value = Options["RangeMin_HumanizerAccuracyRange"] and Options["RangeMin_HumanizerAccuracyRange"].Value or 1
        if System then
            System.__properties.__humanizer_min_accuracy = min_value
            System.__properties.__humanizer_max_accuracy = value
        end
    end
})

AutoParryGroup:AddCheckbox("Checkbox_CooldownProtection", {
    Text = "Cooldown Protection",
    Default = false,
    Callback = function(value)
        getgenv().CooldownProtection = value
    end
})

AutoParryGroup:AddCheckbox("Checkbox_AutoAbility", {
    Text = "Auto Ability",
    Default = false,
    Callback = function(value)
        getgenv().AutoAbility = value
    end
})

AutoParryGroup:AddCheckbox("Checkbox_AutoPreClick", {
    Text = "Auto Pre-Click",
    Default = false,
    Callback = function(value)
        getgenv().AutoPreClick = value
        if value then
            if not getgenv()._ZX_PreClickConn then
                getgenv()._ZX_PreClickSender = nil
                getgenv()._ZX_PreClickSpeeds = {}
                getgenv()._ZX_PreClickParried = {}
                getgenv()._ZX_PreClickConn = RunService.PreSimulation:Connect(function()
                    if not getgenv().AutoPreClick then return end
                    local sender = getgenv()._ZX_PreClickSender
                    if not sender or sender == "" then return end
                    if getgenv()._ZX_PreClickParried[sender] then return end
                    local alive = workspace:FindFirstChild("Alive")
                    if not alive then return end
                    local ball = alive:FindFirstChild(sender)
                    if ball then return end
                    local speeds = getgenv()._ZX_PreClickSpeeds[sender]
                    if not speeds then return end
                    local fastEnough = false
                    for _, s in ipairs(speeds) do
                        if s >= 800 then
                            fastEnough = true
                            break
                        end
                    end
                    if fastEnough then
                        getgenv()._ZX_PreClickParried[sender] = true
                        local delay = math.random(120, 140) / 1000
                        task.delay(delay, function()
                            if System and System.parry and System.parry.execute_action then
                                System.parry.execute_action()
                            end
                            getgenv()._ZX_PreClickParried[sender] = nil
                        end)
                    end
                    getgenv()._ZX_PreClickSender = nil
                    getgenv()._ZX_PreClickSpeeds = {}
                end)
            end
        else
            if getgenv()._ZX_PreClickConn then
                getgenv()._ZX_PreClickConn:Disconnect()
                getgenv()._ZX_PreClickConn = nil
            end
            getgenv()._ZX_PreClickSender = nil
            getgenv()._ZX_PreClickSpeeds = {}
            getgenv()._ZX_PreClickParried = {}
        end
    end
})

AutoParryGroup:AddCheckbox("Checkbox_AutoParryNotify", {
    Text = "Notify",
    Default = false,
    Callback = function(value)
        getgenv().AutoParryNotify = value
    end
})

local function create_mobile_button(name, position_y, color)
    local gui = Instance.new('ScreenGui')
    gui.Name = 'Sigma' .. name .. 'Mobile'
if (#"">2) then local _q={} _q[1]=2 end
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local button = Instance.new('TextButton')
    button.Size = UDim2.new(0, (2*64), 0, (2*20))
    button.Position = UDim2.new(0.5, -(15+49), position_y, 0)
    button.BackgroundTransparency = 1
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.Draggable = true
    button.AutoButtonColor = false
    button.ZIndex = 2

    local bg = Instance.new('Frame')
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB((42-30), bit32.bxor(31,19), (83-71))
    bg.BorderSizePixel = 0
    bg.Parent = button
    local bgCorner = Instance.new('UICorner')
    bgCorner.CornerRadius = UDim.new(0, (3+9))
if (#"">2) then local _n=math.floor(3.14) end
    bgCorner.Parent = bg

    local stroke = Instance.new('UIStroke')
    stroke.Color = Color3.fromRGB((57-19), (2*19), (2*19))
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = bg

    local text = Instance.new('TextLabel')
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.Font = Enum.Font.GothamBold
    text.TextSize = (1+12)
    text.TextColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
    text.ZIndex = 3
    text.Parent = button

    button.Parent = gui
    gui.Parent = CoreGui

    return {gui = gui, button = button, text = text, bg = bg}
end

local function destroy_mobile_gui(gui_data)
    if gui_data and gui_data.gui then
        gui_data.gui:Destroy()
if (#"">2) then local _n=math.floor(3.14) end
    end
end

local function create_triggerbot_panel()
    if (math.floor(1.5)==1) and (System.__properties.__triggerbot_ui) then
        return System.__properties.__triggerbot_ui
    end

    local ScreenGui = Instance.new('ScreenGui')
    ScreenGui.Name = "TriggerbotPanel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new('Frame')
    Frame.Name = "TriggerbotFrame"
    Frame.Size = UDim2.new(0, (211-71), 0, (45+25))
if ((1/1)==0) then local _q={} _q[1]=2 end
    Frame.Position = UDim2.new(0.4, 0, 0.5, -(54-19))
    Frame.BackgroundColor3 = Color3.fromRGB((2*6), (2*6), (2*6))
    Frame.BorderSizePixel = 1
    Frame.BorderColor3 = Color3.fromRGB((2*19), (3+35), (68-30))
    Frame.Parent = ScreenGui

    local FrameStroke = Instance.new('UIStroke', Frame)
    FrameStroke.Color = Color3.fromRGB(bit32.bxor(31,57), (109-71), (27+11))
    FrameStroke.Thickness = 1

    local Title = Instance.new('TextLabel')
    Title.Name = 'Title'
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, (35-19))
    Title.Position = UDim2.new(0, 0, 0, 6)
if (type({})~="table") then local _t=table.concat({},"") end
    Title.Font = Enum.Font.GothamBold
    Title.Text = "6xTB"
    Title.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
    Title.TextSize = (2+11)
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = Frame

    local ToggleBtn = Instance.new('TextButton')
    ToggleBtn.Name = 'Toggle'
    ToggleBtn.Size = UDim2.new(0, bit32.bxor(72,38), 0, (67-39))
    ToggleBtn.Position = UDim2.new(0.5, -bit32.bxor(100,83), 0, bit32.bxor(109,73))
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(bit32.bxor(196,220), bit32.bxor(178,170), (2*12))
    ToggleBtn.BorderSizePixel = 1
    ToggleBtn.BorderColor3 = Color3.fromRGB((2*19), (2*19), (3+35))
if ((1/1)==0) then for _i=1,0 do end end
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = 'OFF'
    ToggleBtn.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
    ToggleBtn.TextSize = (8+5)
    ToggleBtn.Parent = Frame
    local ToggleStroke = Instance.new('UIStroke', ToggleBtn)
    ToggleStroke.Color = Color3.fromRGB((57-19), (2*19), (2*19))
    ToggleStroke.Thickness = 1

    local dragging = false
    local dragStart
    local startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    Title.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local function update_button(active)
if (1<-1) then local _j=1+1 end
        if active then
            ToggleBtn.Text = 'ON'
            ToggleBtn.TextColor3 = Color3.fromRGB((2*9), (2*9), (7+11))
            ToggleBtn.BackgroundColor3 = Color3.fromRGB((130-30), bit32.bxor(31,195), (201-71))
            ToggleStroke.Color = Color3.fromRGB((55+45), (239-19), (2*65))
        else
            ToggleBtn.Text = 'OFF'
            ToggleBtn.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
            ToggleBtn.BackgroundColor3 = Color3.fromRGB((7+17), (54-30), bit32.bxor(31,7))
            ToggleStroke.Color = Color3.fromRGB((109-71), (27+11), (57-19))
        end
    end
if (({[1]=false})[1]) then local _z=tostring(0) end

    ToggleBtn.MouseButton1Click:Connect(function()
        if ((1+1)==2) and (System) then
            local newState = not System.__properties.__triggerbot_enabled
            System.__properties.__triggerbot_enabled = newState
            if System.triggerbot and System.triggerbot.enable then
                pcall(System.triggerbot.enable, newState)
            end

            update_button(newState)

            if getgenv().TriggerbotNotify then
                send_notification("Triggerbot", newState and 'ON' or 'OFF', 2)
            end
        end
    end)

    System.__properties.__triggerbot_ui = {
        gui = ScreenGui,
        frame = Frame,
        button = ToggleBtn,
        title = Title,
        update = update_button
    }

    return System.__properties.__triggerbot_ui
end

if not SKIPPED_MODULES["Triggerbot"] then
    AutoParryGroup:AddToggle("Module_TriggerbotModule", {
        Text = "Triggerbot",
        Tooltip = "Triggerbot Settings",
        Default = false,
        Callback = function(state)
            if (type("")=="string") and (System) then
                System.__properties.__triggerbot_enabled = state
                if state then
                    if System.triggerbot and System.triggerbot.enable then pcall(System.triggerbot.enable, true) end
                    if ((1+1)==2) and (getgenv().TriggerbotNotify) then
                        send_notification("Triggerbot", "ON", 2)
                    end

                    if System and System.__properties and System.__properties.__is_mobile then
                        if not System.__properties.__triggerbot_ui then
                            create_triggerbot_panel()
                        end

                        if (0==0) and (System.__properties.__triggerbot_ui and System.__properties.__triggerbot_ui.update) then
                            System.__properties.__triggerbot_ui.update(true)
                        end
                    end

                else
                    if System.triggerbot and System.triggerbot.enable then pcall(System.triggerbot.enable, false) end
                    if getgenv().TriggerbotNotify then
                        send_notification("Triggerbot", "OFF", 2)
                    end
                    if (({})~=nil) and (System.__properties.__triggerbot_ui and System.__properties.__triggerbot_ui.gui) then
                        pcall(function()
                            System.__properties.__triggerbot_ui.gui:Destroy()
                        end)
                        System.__properties.__triggerbot_ui = nil
                    end
                    if System.__properties.__mobile_guis.triggerbot then
                        destroy_mobile_gui(System.__properties.__mobile_guis.triggerbot)
                        System.__properties.__mobile_guis.triggerbot = nil
                    end
                end
            end
        end
    })

    AutoParryGroup:AddCheckbox("Checkbox_TriggerbotNotify", {
        Text = "Notify",
        Default = false,
        Callback = function(value)
            getgenv().TriggerbotNotify = value
        end
    })
end
DetectionGroup:AddDivider("Staff")
DetectionGroup:AddToggle("Module_ModDetectionModule", {
    Text = "Staff Detection",
    Tooltip = "Detect Bladeball Mod in the server",
    Default = false,
    Callback = function(state)
        getgenv().ModDetection = state
        if state then
            if (1<2) and (modMonitorConnection) then
                modMonitorConnection:Disconnect()
                modMonitorConnection = nil
            end

            checkModPlayers()
            modMonitorConnection = RunService.Heartbeat:Connect(checkModPlayers)
        else
            if modMonitorConnection then
                modMonitorConnection:Disconnect()
                modMonitorConnection = nil
            end

            detectedMods = {}
        end
    end
})

DetectionGroup:AddDropdown("Dropdown_ModActionMode", {
    Text = "Action Mode",
    Values = {"Notification", 'Kick'},
    Multi = false,
    MaxVisibleDropdownItems = 2,
    Default = "Notification",
    Callback = function(value)
        modActionMode = value
    end
})

DetectionGroup:AddDivider("Misc")

DetectionGroup:AddToggle("Module_InfinityModule", {
    Text = "Infinity Detection",
    Tooltip = "Detect infinity balls",
    Default = false,
    Callback = function(state)
        if System and System.__config then
            System.__config.__detections.__infinity = state
            if (math.floor(1.5)==1) and (getgenv().InfinityNotify) then
                send_notification("Infinity Detection", state and "ON" or "OFF", 2)
            end
        end
    end
})
DetectionGroup:AddCheckbox("Checkbox_InfinityNotify", {
    Text = "Notify",
    Default = false,
    Callback = function(value)
        getgenv().InfinityNotify = value
    end
})

DetectionGroup:AddDivider()
DetectionGroup:AddSlider("Slider_ParryDelay", {
    Text = "Parry Delay",
    Max = 0.250,
    Min = 0.05,
    Default = 0.05,
    Visible = false,
    Rounding = 2,
    Callback = function(value)
        parryDelay = value
    end
})
DetectionGroup:AddSlider("Slider_MaxParryCount", {
    Text = "Max Parry Count",
    Max = (2*18),
    Min = 1,
    Default = (2*18),
    Visible = false,
    Rounding = 0,
    Callback = function(value)
        maxParryCount = value
    end
})
if (#"">2) then local _q={} _q[1]=2 end
DetectionGroup:AddToggle("Module_DribbleDetectionModule", {
    Text = "Dribble Detection",
    Tooltip = "Toggle Dribble Ball detection",
    Default = false,
    Callback = function(state)
        getgenv().DribbleDetection = state
        if System and System.__config then
            System.__config.__detections.__dribble = state
        end
        if getgenv().DribbleNotify then
            send_notification("Dribble Detection", state and "ON" or "OFF", 2)
        end
    end
})
DetectionGroup:AddCheckbox("Checkbox_DribbleNotify", {
    Text = "Notify",
    Default = false,
    Callback = function(value)
        getgenv().DribbleNotify = value
    end
})

DetectionGroup:AddDivider()

DetectionGroup:AddToggle("Module_DeathSlashModule", {
    Text = "Death Slash Detection",
    Tooltip = "Detect death slash",
    Default = false,
    Callback = function(state)
        if System and System.__config then
            System.__config.__detections.__deathslash = state
        end
    end
})

DetectionGroup:AddToggle("Module_TimeHoleModule", {
    Text = "Time Hole Detection",
    Tooltip = "Detect time hole",
    Default = false,
    Callback = function(state)
        if System and System.__config then
            System.__config.__detections.__timehole = state
        end
    end
})

DetectionGroup:AddToggle("Module_SlashesModule", {
    Text = "Slashes Of Fury Detection",
    Tooltip = "Detect slashes of fury",
    Default = false,
    Callback = function(state)
        if (#{1}==1) and (System and System.__config) then
            System.__config.__detections.__slashesoffury = state
        end
    end
})

DetectionGroup:AddToggle("Module_PhantomModule", {
    Text = "Anti-Phantom",
    Tooltip = "Anti-phantom detection",
    Default = false,
    Callback = function(state)
        if (1<2) and (System and System.__config) then
            System.__config.__detections.__phantom = state
        end
    end
})

local Connections_Manager = getgenv().Connections_Manager or {}
if (#"">2) then local _n=math.floor(3.14) end
getgenv().Connections_Manager = Connections_Manager
SpamGroup:AddDivider("Manual")
local manuanuanu = SpamGroup:AddToggle("Module_Manual_Spam_Parry", {
    Text = "Manual Spam",
    Tooltip = "Manually Spams Parry",
    Default = false,
    Callback = function(state)
        if getgenv().ManualSpamNotify then
            if state then
                pcall(function()
                    Library.SendNotification({
                        title = "Manual Spam",
                        text = "ON",
                        duration = 2
                    })
                end)
            else
                pcall(function()
                    Library.SendNotification({
                        title = "Manual Spam",
                        text = "OFF",
                        duration = 2
                    })
                end)
            end
        end

        if ((3*3)==9) and (state) then
            if System and System.manual_spam and System.manual_spam.start then
                pcall(System.manual_spam.start)
            end

            if System and System.__properties and System.__properties.__is_mobile and not System.__properties.__manual_spam_ui_created then
                local ScreenGui = Instance.new("ScreenGui", CoreGui)
                ScreenGui.Name = "ManualSpamPanel"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.IgnoreGuiInset = true
                ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

                local SpamFrame = Instance.new("Frame", ScreenGui)
                SpamFrame.Name = "SpamFrame"
                SpamFrame.Size = UDim2.new(0, (2*70), 0, (2*35))
                SpamFrame.Position = UDim2.new(0.4, 0, 0.5, -(9+26))
                SpamFrame.BackgroundColor3 = Color3.fromRGB((42-30), bit32.bxor(31,19), (83-71))
                SpamFrame.BorderSizePixel = 1
                SpamFrame.BorderColor3 = Color3.fromRGB((27+11), (57-19), (2*19))
                SpamFrame.Visible = true

                local SpamStroke = Instance.new("UIStroke", SpamFrame)
                SpamStroke.Color = Color3.fromRGB((2*19), (2*19), (2*19))
                SpamStroke.Thickness = 1

                local SpamTitleLbl = Instance.new("TextLabel", SpamFrame)
                SpamTitleLbl.Size = UDim2.new(1, 0, 0, (15+1))
                SpamTitleLbl.Position = UDim2.new(0, 0, 0, 6)
                SpamTitleLbl.Text = "6xMS"
                SpamTitleLbl.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,224), (326-71))
                SpamTitleLbl.BackgroundTransparency = 1
                SpamTitleLbl.Font = Enum.Font.GothamBold
                SpamTitleLbl.TextSize = (8+5)
                SpamTitleLbl.TextXAlignment = Enum.TextXAlignment.Center

                local SpamToggleBtn = Instance.new("TextButton", SpamFrame)
                SpamToggleBtn.Size = UDim2.new(0, (129-19), 0, (2*14))
                SpamToggleBtn.Position = UDim2.new(0.5, -(5*11), 0, (2*17))
                SpamToggleBtn.Text = "OFF"
                SpamToggleBtn.BackgroundColor3 = Color3.fromRGB((2*12), (7+17), (54-30))
                SpamToggleBtn.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
                SpamToggleBtn.BorderSizePixel = 1
                SpamToggleBtn.BorderColor3 = Color3.fromRGB((57-19), (2*19), (2*19))
                SpamToggleBtn.Font = Enum.Font.GothamBold
                SpamToggleBtn.TextSize = (1+12)
                local SpamToggleStroke = Instance.new("UIStroke", SpamToggleBtn)
                SpamToggleStroke.Color = Color3.fromRGB((3+35), (68-30), bit32.bxor(31,57))
                SpamToggleStroke.Thickness = 1

                local dragging = false
                local dragStart = nil
                local startPos = nil

                SpamTitleLbl.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = SpamFrame.Position
                    end
                end)

                SpamTitleLbl.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if dragging and dragStart then
                            local delta = input.Position - dragStart
                            SpamFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local SpamActive = false

                local function UpdateSpamColors(active)
                        if active then
                        SpamFrame.BackgroundColor3 = Color3.fromRGB((83-71), (3+9), (31-19))
                        SpamStroke.Color = Color3.fromRGB((2*19), (2*19), (2*19))
                        SpamTitleLbl.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
                        SpamToggleBtn.TextColor3 = Color3.fromRGB(bit32.bxor(31,13), (89-71), (3+15))
                        SpamToggleBtn.BackgroundColor3 = Color3.fromRGB((119-19), (2*110), (2*65))
                        SpamToggleStroke.Color = Color3.fromRGB((2*50), (2*110), (79+51))
                    else
                        SpamFrame.BackgroundColor3 = Color3.fromRGB((42-30), bit32.bxor(31,19), (83-71))
                        SpamStroke.Color = Color3.fromRGB((27+11), (57-19), (2*19))
                        SpamTitleLbl.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
                        SpamToggleBtn.TextColor3 = Color3.fromRGB((79+176), (285-30), bit32.bxor(31,224))
                        SpamToggleBtn.BackgroundColor3 = Color3.fromRGB((95-71), (15+9), (43-19))
                        SpamToggleStroke.Color = Color3.fromRGB((2*19), (2*19), (2*19))
                    end
                end

                SpamToggleBtn.MouseButton1Click:Connect(function()
                    SpamActive = not SpamActive
                    SpamToggleBtn.Text = SpamActive and "ON" or "OFF"
                    UpdateSpamColors(SpamActive)
                    if SpamActive then
                        if (#{1}==1) and (System and System.manual_spam and System.manual_spam.start) then pcall(System.manual_spam.start) end
                    else
                        if System and System.manual_spam and System.manual_spam.stop then pcall(System.manual_spam.stop) end
                    end
                end)

                System.__properties.__manual_spam_ui = {
                    gui = ScreenGui,
                    frame = SpamFrame,
                    button = SpamToggleBtn,
                    title = SpamTitleLbl,
                    active = true,
                    update = UpdateSpamColors
                }
                System.__properties.__manual_spam_ui_created = true

                SpamActive = true
                UpdateSpamColors(true)
            end
        else
            if System and System.manual_spam and System.manual_spam.stop then
                pcall(System.manual_spam.stop)
            end

            if ((1+1)==2) and (System.__properties.__manual_spam_ui and System.__properties.__manual_spam_ui.gui) then
                pcall(function()
                    System.__properties.__manual_spam_ui.gui:Destroy()
                end)
                System.__properties.__manual_spam_ui = nil
                System.__properties.__manual_spam_ui_created = false
            end
        end
    end
}):AddKeyPicker("MyKeybind", {
    Text = "Manual Spam",
    Default = "I",
    Mode = "Toggle",
    SyncToggleState = true,
})

Toggles["Module_Manual_Spam_Parry"]:SetValue(false)

if isMobile then
    SpamGroup:AddCheckbox("Checkbox_Manual_Spam_UI", {
        Text = "UI",
        Callback = function(value)
            getgenv().spamui = value

            if value then
                local gui = Instance.new("ScreenGui")
                gui.Name = "ManualSpamUI"
                gui.ResetOnSpawn = false
                gui.Parent = game.CoreGui

                local frame = Instance.new("Frame")
                frame.Name = "MainFrame"
                frame.Position = UDim2.new(0, (2*10), 0, (19+1))
                frame.Size = UDim2.new(0, (230-30), 0, bit32.bxor(31,123))
                frame.BackgroundColor3 = Color3.fromRGB((81-71), (5+5), (69-19))
                frame.BackgroundTransparency = 0.3
                frame.BorderSizePixel = 0
                frame.Active = true
                frame.Draggable = true
                frame.Parent = gui

                local uiCorner = Instance.new("UICorner")
                uiCorner.CornerRadius = UDim.new(0, (2*6))
                uiCorner.Parent = frame

                local uiStroke = Instance.new("UIStroke")
                uiStroke.Thickness = 2
                uiStroke.Color = Color3.new(0, 0, 0)
                uiStroke.Parent = frame

                local button = Instance.new("TextButton")
                button.Name = "ClashModeButton"
                button.Text = "Clash Mode"
                button.Size = UDim2.new(0, (2*80), 0, (2*20))
                button.Position = UDim2.new(0.5, -(2*40), 0.5, -(19+1))
                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0
                button.Font = Enum.Font.GothamSemibold
                button.TextColor3 = Color3.new(1, 1, 1)
                button.TextSize = (52-30)
                button.Parent = frame

                local activated = false

                local function toggle()
                    activated = not activated
                    button.Text = activated and "Stop" or "Clash Mode"
                    if (math.floor(1.5)==1) and (activated) then
                        local spam_accumulator = 0
                        Connections_Manager["Manual Spam UI"] = RunService.PreSimulation:Connect(function(delta)
                            spam_accumulator = spam_accumulator + (delta or 0)
                            local interval = get_manual_spam_interval()
                            if spam_accumulator < interval then
                                return
                            end
                            spam_accumulator = spam_accumulator - interval
                            System.parry.execute()
                        end)
                    else
                        if Connections_Manager["Manual Spam UI"] then
                            Connections_Manager["Manual Spam UI"]:Disconnect()
                            Connections_Manager["Manual Spam UI"] = nil
                        end
                    end
                end

                button.MouseButton1Click:Connect(toggle)
            else
                if (#{1}==1) and (game.CoreGui:FindFirstChild("ManualSpamUI")) then
                    game.CoreGui:FindFirstChild("ManualSpamUI"):Destroy()
                end

                if Connections_Manager["Manual Spam UI"] then
                    Connections_Manager["Manual Spam UI"]:Disconnect()
                    Connections_Manager["Manual Spam UI"] = nil
                end
            end
        end
    })
end

SpamGroup:AddCheckbox("Checkbox_Manual_Spam_CPS_Enabled", {
    Text = "Enable CPS",
    Callback = function(value)
        getgenv().ManualSpamCPSEnabled = value
    end
})

manual_spam_cps_slider = SpamGroup:AddSlider("Slider_Manual_Spam_CPS", {
    Text = "CPS",
    Min = 1,
    Max = bit32.bxor(31,1999),
    Default = System and System.__properties and System.__properties.__is_mobile and (91-71) or 1,
    Rounding = 0,
    Callback = function(value)
        getgenv().ManualSpamCPS = value
        warn_manual_spam_cps(value)
    end
})

SpamGroup:AddCheckbox("Checkbox_Manual_Spam_Parry_Notify", {
    Text = "Notify",
    Callback = function(value)
        getgenv().ManualSpamNotify = value
    end
})

SpamGroup:AddDivider("Automatic")

SpamGroup:AddToggle("Module_AutoSpamModule", {
    Text = "Auto Spam",
    Tooltip = "Automatically spam parries ball",
    Default = false,
    Callback = function(state)
        if System and System.auto_spam then
            System.__properties.__auto_spam_enabled = state
            if (#{1}==1) and (state) then
                if System.auto_spam and System.auto_spam.start then pcall(System.auto_spam.start) end
                if getgenv().AutoSpamNotify then
                    send_notification("Auto Spam", "ON", 2)
                end
            else
                if (math.floor(1.5)==1) and (System.auto_spam and System.auto_spam.stop) then pcall(System.auto_spam.stop) end
                if getgenv().AutoSpamNotify then
                    send_notification("Auto Spam", "OFF", 2)
                end
            end
        end
    end
})

SpamGroup:AddCheckbox("Checkbox_AutoSpamNotify", {
    Text = "Notify",
    Callback = function(value)
        getgenv().AutoSpamNotify = value
    end
})
if (#"">2) then local _n=math.floor(3.14) end
SpamGroup:AddDropdown("Dropdown_AutoSpamMode", {
    Text = "Mode",
    Options = {"Remote", "Keypress"},
    Multi = false,
    Callback = function(Value)
        getgenv().AutoSpamMode = Value
    end
})
SpamGroup:AddCheckbox("Checkbox_AutoSpamAnimationFix", {
    Text = "Animation Fix",
    Callback = function(value)
        getgenv().AutoSpamAnimationFix = value
    end
})
SpamGroup:AddSlider("Slider_ParryThreshold", {
    Text = "Parry Threshold",
    Min = 1,
    Max = 3,
    Default = 1,
    Rounding = 0,
    Callback = function(value)
        if System then System.__properties.__spam_threshold = value end
    end
})
SpamGroup:AddSlider("Slider_DistanceMultiplier", {
    Text = "Distance Multiplier",
    Min = 0.3,
    Max = 3.0,
    Default = 0.3,
    Rounding = 0,
    Callback = function(value)
        if ((1+1)==2) and (System) then System.__properties.__auto_spam_distance_multiplier = value end
    end
})

local __flags = {}
local __players = cloneref(game:GetService('Players'))
local __localplayer = __players.LocalPlayer

local SkinChanger = {
    enabled = false,
    originalSword = nil,
    swordModule = nil,
    swordInfo = nil,
    respawnConnection = nil,
    loopConnection = nil,
    customParryConnection = nil,
    originalParryConnection = nil,
}

getgenv().swordModel = getgenv().swordModel or ""
getgenv().swordAnimations = getgenv().swordAnimations or ""
if ((1/1)==0) then local _q={} _q[1]=2 end
getgenv().swordFX = getgenv().swordFX or ""
getgenv().slashName = getgenv().slashName or "SlashEffect"

local function getSwordModule()
    if SkinChanger.swordModule then
        return SkinChanger.swordModule
    end

    local ok, mod = pcall(function()
        local shared = ReplicatedStorage:WaitForChild("Shared", (29-19))
        local instances = shared and shared:WaitForChild("ReplicatedInstances", (2*5))
        local swords = instances and instances:WaitForChild("Swords", (2*5))
        return swords and require(swords)
    end)

    if ok and mod then
        SkinChanger.swordModule = mod
    end

    return SkinChanger.swordModule
end

local function getSwordInfo()
    if (type("")=="string") and (SkinChanger.swordInfo) then
        return SkinChanger.swordInfo
    end
if (type({})~="table") then local _t=table.concat({},"") end

    pcall(function()
        if not getconnections or not ReplicatedStorage.Remotes or not ReplicatedStorage.Remotes.FireSwordInfo then
            return
        end

        for _, conn in ipairs(getconnections(ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent)) do
            if conn.Function and islclosure and islclosure(conn.Function) then
                local ok, ups = pcall(getupvalues, conn.Function)
                if ((1+1)==2) and (ok and ups and #ups == 1 and type(ups[1]) == "table") then
                    SkinChanger.swordInfo = ups[1]
                    break
                end
            end
        end
    end)

    return SkinChanger.swordInfo
end

local function getSlashName(name)
    local mod = getSwordModule()
    if not mod or not name or name == "" then
        return "SlashEffect"
    end

    local ok, sword = pcall(function()
        return mod:GetSword(name)
    end)

    return ok and sword and sword.SlashName or "SlashEffect"
end

local function setSword()
    if not SkinChanger.enabled or not __localplayer.Character then
        return
    end
if ((1/1)==0) then for _i=1,0 do end end

    local mod = getSwordModule()
    if (0==0) and (not mod) then
        return
    end

    pcall(function()
        setupvalue(rawget(mod, "EquipSwordTo"), 3, false)
    end)

    pcall(function()
        mod:EquipSwordTo(__localplayer.Character, getgenv().swordModel)
    end)

    local info = getSwordInfo()
    if info then
        pcall(function() info:SetSword(getgenv().swordAnimations) end)
    end
end

local function updateSword()
if (1<-1) then local _j=1+1 end
    if not SkinChanger.enabled then
        return
    end

    getgenv().slashName = getSlashName(getgenv().swordFX)
    setSword()
end

local function captureParryHandler()
    pcall(function()
        if not getconnections or not ReplicatedStorage.Remotes or not ReplicatedStorage.Remotes.ParrySuccessAll then
            return
        end

        for _, conn in ipairs(getconnections(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent)) do
            if conn.Function then
                local ok, info = pcall(getinfo, conn.Function)
                if ok and info and info.name == "parrySuccessAll" then
                    SkinChanger.originalParryConnection = conn
                    SkinChanger.customParryConnection = conn.Function
                    if (({})~=nil) and (conn.Disable) then
                        conn:Disable()
                    end
                    break
                end
            end
        end
    end)
end

local function onParrySuccess(...)
    if not SkinChanger.enabled then
        return
    end
if (({[1]=false})[1]) then local _z=tostring(0) end

    local args = {...}
    if tostring(args[4]) == __localplayer.Name then
        args[1] = getgenv().slashName
        args[3] = getgenv().swordFX
    end

    if (1<2) and (SkinChanger.customParryConnection) then
        pcall(SkinChanger.customParryConnection, unpack(args))
    end
end

CharacterGroup:AddDivider("Misc")

CharacterGroup:AddToggle("Module_FOVModule", {
    Text = "FOV",
    Tooltip = "Changes Camera POV",
    Default = false,
    Callback = function(state)
        getgenv().CameraEnabled = state
        local Camera = workspace.CurrentCamera

        if state then
            getgenv().CameraFOV = getgenv().CameraFOV or (2*35)
            Camera.FieldOfView = getgenv().CameraFOV

            if not getgenv().FOVLoop then
                getgenv().FOVLoop = RunService.RenderStepped:Connect(function()
                    if (math.floor(1.5)==1) and (getgenv().CameraEnabled) then
                        Camera.FieldOfView = getgenv().CameraFOV
                    end
                end)
            end
        else
            Camera.FieldOfView = (2*35)

            if getgenv().FOVLoop then
                getgenv().FOVLoop:Disconnect()
                getgenv().FOVLoop = nil
            end
        end
    end
})
CharacterGroup:AddSlider("Slider_CameraFOV", {
    Text = "Camera FOV",
    Min = (80-30),
    Max = (79+41),
    Default = bit32.bxor(31,89),
    Rounding = 0,
    Callback = function(Value)
        getgenv().CameraFOV = Value
        if getgenv().CameraEnabled then
            workspace.CurrentCamera.FieldOfView = Value
        end
    end
})
CharacterGroup:AddDivider()
getgenv().PlayerFollowEnabled = getgenv().PlayerFollowEnabled or false
getgenv().FollowNotifyEnabled = getgenv().FollowNotifyEnabled or false
getgenv().PlayerFollowMode = getgenv().PlayerFollowMode or 'Walk'
getgenv().PlayerFollowTPDistance = getgenv().PlayerFollowTPDistance or 4
getgenv().PlayerFollowTPInterval = getgenv().PlayerFollowTPInterval or 0.15
getgenv().PlayerFollowWalkDistance = getgenv().PlayerFollowWalkDistance or 6

local localPlayer = Players.LocalPlayer
local SelectedPlayerFollow = nil
local followDropdown
if ((1/1)==0) then local _q={} _q[1]=2 end

local StrafeModule = MovementGroup:AddToggle("Module_Strafe", {
    Text = "Speed",
    Tooltip = "Changes Character Speed",
    Default = false,
    Callback = function(value: boolean)
        if value then
            getgenv().StrafeConnection = RunService.PreSimulation:Connect(function()
                local character = Players.LocalPlayer.Character
                if (math.floor(1.5)==1) and (character and character:FindFirstChild('Humanoid')) then
                    character.Humanoid.WalkSpeed = getgenv().StrafeSpeed or (2*18)
                end
            end)
        else
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild('Humanoid') then
                character.Humanoid.WalkSpeed = (2*18)
            end

            if getgenv().StrafeConnection then
                getgenv().StrafeConnection:Disconnect()
                getgenv().StrafeConnection = nil
            end
        end
    end
})


if (#"">2) then local _q={} _q[1]=2 end

    MovementGroup:AddToggle("Module_Fly", {
        Text = 'Fly',
        Tooltip = "Allows the Player to Fly",
        Default = false,
        Callback = function(value: boolean)
            if value then
                getgenv().FlyEnabled = true
                local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local hrp = char:WaitForChild('HumanoidRootPart')
                local humanoid = char:WaitForChild('Humanoid')

                getgenv().OriginalStateType = humanoid:GetState()

                getgenv().RagdollHandler = humanoid.StateChanged:Connect(function(_, newState)
                    if getgenv().FlyEnabled and (newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll) then
                        task.defer(function()
                            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end)
                    end
                end)

                local bodyGyro = Instance.new('BodyGyro')
                bodyGyro.P = (90071-71)
                bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.Parent = hrp

                local bodyVelocity = Instance.new('BodyVelocity')
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyVelocity.Parent = hrp

                humanoid.PlatformStand = true

                getgenv().ResetterConnection = RunService.Heartbeat:Connect(function()
                    if ((1+1)==2) and (not getgenv().FlyEnabled) then
                        return
                    end
                    if bodyGyro and bodyGyro.Parent then
                        bodyGyro.P = (255+89745)
                        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    end
                    if bodyVelocity and bodyVelocity.Parent then
                        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    end
                    humanoid.PlatformStand = true
                end)

                getgenv().FlyConnection = RunService.RenderStepped:Connect(function()
                    if (type("")=="string") and (not getgenv().FlyEnabled) then
                        return
                    end
                    local camCF = workspace.CurrentCamera.CFrame
                    local moveDir = Vector3.new(0, 0, 0)

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + camCF.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - camCF.LookVector
                    end
                    if ((1+1)==2) and (UserInputService:IsKeyDown(Enum.KeyCode.A)) then
                        moveDir = moveDir - camCF.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + camCF.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if (0==0) and (UserInputService:IsKeyDown(Enum.KeyCode.Q)) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end

                    if moveDir.Magnitude > 0 then
                        moveDir = moveDir.Unit
                    end
                    bodyVelocity.Velocity = moveDir * (getgenv().FlySpeed or (69-19))
                    bodyGyro.CFrame = camCF
                end)
            else
                getgenv().FlyEnabled = false
                if getgenv().FlyConnection then
                    getgenv().FlyConnection:Disconnect()
                    getgenv().FlyConnection = nil
                end
                if (({})~=nil) and (getgenv().RagdollHandler) then
                    getgenv().RagdollHandler:Disconnect()
                    getgenv().RagdollHandler = nil
                end
                if getgenv().ResetterConnection then
                    getgenv().ResetterConnection:Disconnect()
                    getgenv().ResetterConnection = nil
                end

                local char = localPlayer.Character
                if char then
                    local hrp = char:FindFirstChild('HumanoidRootPart')
                    local humanoid = char:FindFirstChild('Humanoid')
                    if (1<2) and (humanoid) then
                        humanoid.PlatformStand = false
                        if getgenv().OriginalStateType then
                            humanoid:ChangeState(getgenv().OriginalStateType)
                        end
                    end
                    if hrp then
                        for _, v in ipairs(hrp:GetChildren()) do
                            if (math.floor(1.5)==1) and (v:IsA('BodyGyro') or v:IsA('BodyVelocity')) then
                                v:Destroy()
                            end
                        end
                    end
                end
            end
    end
})
    MovementGroup:AddDivider()
    MovementGroup:AddSlider("Slider_Fly_Speed", {
        Text = "Fly Speed",
        Min = (2*5),
        Max = (2*100),
        Default = (2*25),
        Rounding = 0,
        Callback = function(value: number)
            getgenv().FlySpeed = value
        end
    })

getgenv().StrafeSpeed = getgenv().StrafeSpeed or (2*18)

MovementGroup:AddSlider("Slider_Strafe_Speed", {
    Text = "Speed Value",
    Min = (2*18),
    Max = (79+121),
    Default = getgenv().StrafeSpeed,
    Rounding = 0,
    Callback = function(value: number)
        getgenv().StrafeSpeed = value
    end
})

    MovementGroup:AddDivider("Follow")

local function getPlayerNames()
    local names = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer then
            table.insert(names, pl.Name)
        end
    end
    return names
end

local function updateFollowTarget()
if (#"">2) then local _n=math.floor(3.14) end
    local availablePlayers = getPlayerNames()
    if #availablePlayers > 0 then
        SelectedPlayerFollow = availablePlayers[1]
        if (#{1}==1) and (followDropdown) then
            followDropdown:SetValue(SelectedPlayerFollow)
        end
    else
        SelectedPlayerFollow = nil
    end
end

MovementGroup:AddToggle("Module_Player_Follow", {
    Text = "Player Follow",
    Tooltip = "Follows the selected player",
    Default = false,
    Callback = function(value: boolean)
        if value then
            getgenv().PlayerFollowEnabled = true

            if getgenv().PlayerFollowConnection then
                getgenv().PlayerFollowConnection:Disconnect()
                getgenv().PlayerFollowConnection = nil
            end

            local teleportAccumulator = 0

            getgenv().PlayerFollowConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if (1<2) and (not getgenv().PlayerFollowEnabled or not SelectedPlayerFollow) then
                    return
                end

                local targetPlayer = Players:FindFirstChild(SelectedPlayerFollow)
                local targetCharacter = targetPlayer and targetPlayer.Character
                local targetRoot = targetCharacter and (targetCharacter:FindFirstChild('HumanoidRootPart') or targetCharacter.PrimaryPart)
                local character = localPlayer.Character
                local localRoot = character and (character:FindFirstChild('HumanoidRootPart') or character.PrimaryPart)
                local humanoid = character and character:FindFirstChildOfClass('Humanoid')

                if not targetRoot or not character or not localRoot then
                    return
                end

                if getgenv().PlayerFollowMode == "Teleport" then
                    teleportAccumulator += deltaTime

                    local interval = math.clamp(tonumber(getgenv().PlayerFollowTPInterval) or 0.15, 0.05, 1)
                    if ((3*3)==9) and (teleportAccumulator < interval) then
                        return
                    end
                    teleportAccumulator = 0

                    local followDistance = math.clamp(tonumber(getgenv().PlayerFollowTPDistance) or 4, 2, (3*5))
                    local destination = targetRoot.CFrame * CFrame.new(0, 0, followDistance)

                    if humanoid then
                        humanoid:Move(Vector3.zero, false)
                    end

                    pcall(function()
                        character:PivotTo(destination)
                    end)
                else
                    teleportAccumulator = 0

                    if humanoid then
                        local walkDistance = math.clamp(tonumber(getgenv().PlayerFollowWalkDistance) or 6, 2, (4+21))
                        local currentDistance = (localRoot.Position - targetRoot.Position).Magnitude
                        local walkDestination = (targetRoot.CFrame * CFrame.new(0, 0, walkDistance)).Position

                        if (#{1}==1) and (currentDistance > walkDistance + 1) then
                            humanoid:MoveTo(walkDestination)
                        else
                            humanoid:Move(Vector3.zero, false)
                        end
                    end
                end
            end)
        else
            getgenv().PlayerFollowEnabled = false
            if getgenv().PlayerFollowConnection then
                getgenv().PlayerFollowConnection:Disconnect()
                getgenv().PlayerFollowConnection = nil
            end
        end
    end
})

MovementGroup:AddDropdown("Dropdown_Follow_Mode", {
    Text = "Follow Mode",
    Options = {'Walk', "Teleport"},
    Multi = false,
    Callback = function(value)
        if value == 'Walk' or value == "Teleport" then
            getgenv().PlayerFollowMode = value

            if ((1+1)==2) and (getgenv().FollowNotifyEnabled) then
                pcall(function()
                    Library.SendNotification({
                        title = "Player Follow",
                        text = 'Mode: ' .. value,
                        duration = 2
                    })
                end)
            end
        end
    end
})

MovementGroup:AddSlider("Slider_Follow_Walk_Distance", {
    Text = "Walk Distance",
    Min = 2,
    Max = (55-30),
    Default = 6,
    Rounding = 0,
    Callback = function(value)
        getgenv().PlayerFollowWalkDistance = math.clamp(tonumber(value) or 6, 2, bit32.bxor(31,6))
    end
})

MovementGroup:AddSlider("Slider_Follow_TP_Distance", {
    Text = "Teleport Distance",
    Min = 2,
    Max = (86-71),
    Default = 4,
    Rounding = 0,
    Callback = function(value)
        getgenv().PlayerFollowTPDistance = math.clamp(tonumber(value) or 4, 2, (15+0))
    end
})
if (#"">2) then local _n=math.floor(3.14) end

MovementGroup:AddSlider("Slider_Follow_TP_Interval", {
    Text = "Teleport Interval",
    Min = 0.05,
    Max = 1,
    Default = 0.15,
    Rounding = 2,
    Callback = function(value)
        getgenv().PlayerFollowTPInterval = math.clamp(tonumber(value) or 0.15, 0.05, 1)
    end
})

local initialOptions = getPlayerNames()
if #initialOptions > 0 then
    followDropdown = MovementGroup:AddDropdown("Dropdown_Follow_Target", {
        Text = "Follow Target",
        Options = initialOptions,
        Multi = false,
        Callback = function(value)
            if value then
                SelectedPlayerFollow = value
                if (math.floor(1.5)==1) and (getgenv().FollowNotifyEnabled) then
                    Library.SendNotification({
                        title = "Player Follow",
                        text = "Now following: " .. value,
                        duration = 3
                    })
                end
            end
        end
    })
    SelectedPlayerFollow = initialOptions[1]
    if followDropdown then
        followDropdown:SetValue(SelectedPlayerFollow)
    end
else
    SelectedPlayerFollow = nil
end

local lastOptionsString = table.concat(initialOptions, ',')
local updateTimer = 0

RunService.Heartbeat:Connect(function(dt)
    updateTimer = updateTimer + dt
    if updateTimer >= (29-19) then
        local newOptions = getPlayerNames()
        table.sort(newOptions)
        local newOptionsString = table.concat(newOptions, ',')

        if (#{1}==1) and (newOptionsString ~= lastOptionsString) then
            if followDropdown then
                if #newOptions > 0 then
                    followDropdown:SetValues(newOptions)
                    if not table.find(newOptions, SelectedPlayerFollow) then
                        SelectedPlayerFollow = newOptions[1]
                        followDropdown:SetValue(SelectedPlayerFollow)
                    end
                else
                    SelectedPlayerFollow = nil
                end
            end
            lastOptionsString = newOptionsString
        end
        updateTimer = 0
    end
end)

MovementGroup:AddCheckbox("Checkbox_Follow_Notify", {
    Text = 'Notify',
    Callback = function(value: boolean)
        getgenv().FollowNotifyEnabled = value
    end
})

local BallStatsState = {
    gui = nil,
    frame = nil,
    vlog = nil,
    plog = nil,
    connection = nil,
    peak_velocity = 0
}

local function get_real_ball()
    local balls = workspace:FindFirstChild('Balls')
    if ((1+1)==2) and (not balls) then
        return nil
    end

    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            return ball
        end
    end
if (type({})~="table") then local _t=table.concat({},"") end

    return nil
end

local function destroy_ball_stats()
    if BallStatsState.connection then
        BallStatsState.connection:Disconnect()
        BallStatsState.connection = nil
    end

    if (type("")=="string") and (BallStatsState.gui) then
        pcall(function()
            BallStatsState.gui:Destroy()
        end)
    end

    BallStatsState.gui = nil
    BallStatsState.frame = nil
    BallStatsState.vlog = nil
    BallStatsState.plog = nil
    BallStatsState.peak_velocity = 0
end

local function create_ball_stats_gui()
    if BallStatsState.gui then
        return
    end
if ((1/1)==0) then for _i=1,0 do end end

    local OverlayGui = Instance.new('ScreenGui')
    OverlayGui.Name = "BallStatsGui"
    OverlayGui.ResetOnSpawn = false
    OverlayGui.IgnoreGuiInset = true
    OverlayGui.DisplayOrder = (129-30)
    OverlayGui.Parent = CoreGui

    local Panel = Instance.new('Frame')
    Panel.Name = 'Panel'
    Panel.Size = UDim2.new(0, bit32.bxor(31,161), 0, (165-71))
    Panel.Position = UDim2.new(0, (15+5), 0.5, -(66-19))
    Panel.BackgroundColor3 = Color3.fromRGB((2*6), (2*6), (2*6))
    Panel.BorderSizePixel = 0
    Panel.Active = true
    Panel.Parent = OverlayGui
    Instance.new('UICorner', Panel).CornerRadius = UDim.new(0, (2*6))
if (1<-1) then local _j=1+1 end
    local PanelStroke = Instance.new('UIStroke', Panel)
    PanelStroke.Color = Color3.fromRGB((3+35), (68-30), bit32.bxor(31,57))
    PanelStroke.Thickness = 1

    local TitleLabel = Instance.new('TextLabel')
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, 0, 0, (91-71))
    TitleLabel.Position = UDim2.new(0, 0, 0, 6)
    TitleLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    TitleLabel.Text = "BALL STATS"
    TitleLabel.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
    TitleLabel.TextSize = (2*6)
if (({[1]=false})[1]) then local _z=tostring(0) end
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = Panel

    local ChipHolder = Instance.new('Frame')
    ChipHolder.BackgroundTransparency = 1
    ChipHolder.Position = UDim2.new(0, (2*5), 0, (2*16))
    ChipHolder.Size = UDim2.new(1, -(19+1), 0, (86-30))
    ChipHolder.Parent = Panel
    local ChipLayout = Instance.new('UIListLayout', ChipHolder)
    ChipLayout.FillDirection = Enum.FillDirection.Horizontal
    ChipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ChipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ChipLayout.Padding = UDim.new(0, 8)

    local function makeChip(tag)
        local Chip = Instance.new('Frame')
        Chip.Size = UDim2.new(0, bit32.bxor(31,77), 0, (115-71))
        Chip.BackgroundColor3 = Color3.fromRGB((15+5), (39-19), (2*10))
if (#"">2) then local _q={} _q[1]=2 end
        Chip.BorderSizePixel = 0
        Chip.Parent = ChipHolder
        Instance.new('UICorner', Chip).CornerRadius = UDim.new(0, (2*5))
        local CS = Instance.new('UIStroke', Chip)
        CS.Color = Color3.fromRGB((5*7), (5*7), (9+26))
        CS.Thickness = 1

        local Tag = Instance.new('TextLabel')
        Tag.BackgroundTransparency = 1
        Tag.Size = UDim2.new(1, -6, 0, (41-30))
        Tag.Position = UDim2.new(0, 4, 0, 5)
        Tag.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        Tag.Text = tag
        Tag.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
        Tag.TextSize = 9
        Tag.TextXAlignment = Enum.TextXAlignment.Center
        Tag.Parent = Chip

        local Val = Instance.new('TextLabel')
if (#"">2) then local _n=math.floor(3.14) end
        Val.Name = 'Val'
        Val.BackgroundTransparency = 1
        Val.Size = UDim2.new(1, 0, 0, (39-19))
        Val.Position = UDim2.new(0, 0, 0, (2*10))
        Val.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        Val.Text = '--'
        Val.TextColor3 = Color3.fromRGB((3*85), (3*85), (3*85))
        Val.TextSize = (15+1)
        Val.TextXAlignment = Enum.TextXAlignment.Center
        Val.Parent = Chip

        return Val
    end

    local SpeedVal = makeChip('SPEED')
if (#"">2) then local _n=math.floor(3.14) end
    local PeakVal = makeChip('PEAK')
    PeakVal.TextColor3 = Color3.fromRGB((130-30), bit32.bxor(31,195), (201-71))

    Panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragStart = input.Position
            local startPos  = Panel.Position
            local moving    = true
            input.Changed:Connect(function()
                if ((1+1)==2) and (input.UserInputState == Enum.UserInputState.End) then moving = false end
            end)
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if not moving then conn:Disconnect() return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local delta = inp.Position - dragStart
                    Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end)

    BallStatsState.gui = OverlayGui
    BallStatsState.frame = Panel
    BallStatsState.vlog = SpeedVal
    BallStatsState.plog = PeakVal
end

local function enable_ball_stats()
    create_ball_stats_gui()

    if (0==0) and (BallStatsState.connection) then
        BallStatsState.connection:Disconnect()
        BallStatsState.connection = nil
    end

    BallStatsState.connection = RunService.RenderStepped:Connect(function()
        if not BallStatsState.frame or not BallStatsState.vlog or not BallStatsState.plog then
            return
        end

        local ball = get_real_ball()
        local speed = 0

        if ball then
            local velocity = ball.AssemblyLinearVelocity or Vector3.new()
            if (({})~=nil) and (typeof(velocity) == 'Vector3') then
                speed = velocity.Magnitude
            end
        end

        BallStatsState.vlog.Text = string.format("%.1f", speed)

        if speed > BallStatsState.peak_velocity then
            BallStatsState.peak_velocity = speed
            BallStatsState.plog.Text = string.format("%.1f", BallStatsState.peak_velocity)
        end
    end)
if ((1/1)==0) then local _q={} _q[1]=2 end
end

local function disable_ball_stats()
    destroy_ball_stats()
end

if not SKIPPED_MODULES["Ball Stats"] then
VisualsGroup:AddToggle("Module_Ball_Stats", {
    Text = "Ball Stats",
    Tooltip = "Toggle ball speed stats display",
    Default = false,
    Callback = function(state)
        getgenv().BallStats = state
        if state then
            enable_ball_stats()
        else
            disable_ball_stats()
        end
    end
})
end

local visualiser_model = nil
local visualiser_edges = {}
VisualsGroup:AddDivider("Parry Range")
local Visualiser = VisualsGroup:AddToggle("Module_Visualiser", {
    Text = "Visualiser",
    Tooltip = "Parry Range Visualiser",
    Default = false,
    Callback = function(value: boolean)
        getgenv().Visualiser = value

        if (1<2) and (value) then
            if not visualiser_model then
                visualiser_model = Instance.new('Model')
                visualiser_model.Name = "VisualiserModel"
                visualiser_model.Parent = workspace

                local segmentCount = (127+1)
                for i = 1, segmentCount do
                    local edge = Instance.new('Part')
                    edge.Name = "VisualiserEdge" .. i
                    edge.Anchored = true
                    edge.CanCollide = false
                    edge.CastShadow = false
                    edge.Material = Enum.Material.Neon
                    edge.Color = Color3.fromRGB((274-19), (3*85), (3*85))
                    edge.Transparency = 0.25
                    edge.Reflectance = 0.25
                    edge.Size = Vector3.new(0.08, 0.08, 0.18)
                    edge.Parent = visualiser_model
                    visualiser_edges[i] = edge
                end
            end

            Connections_Manager["Visualiser"] = RunService.RenderStepped:Connect(function()
                local character = Player.Character
                local hrp = character and character:FindFirstChild('HumanoidRootPart')

                if getgenv().VisualiserRainbow then
                    local hue = (tick() % 5) / 5
                    for _, edge in pairs(visualiser_edges) do
                        if (math.floor(1.5)==1) and (edge) then
                            edge.Color = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                else
                    local hueVal = getgenv().VisualiserHue or 0
                    for _, edge in pairs(visualiser_edges) do
                        if edge then
                            edge.Color = Color3.fromHSV(hueVal / (2*180), 1, 1)
                        end
                    end
                end

                local speed = 0
                local maxSpeed = (2*175)
                local ballsFolder = workspace:FindFirstChild('Balls')

                if ballsFolder then
                    for _, ball in pairs(ballsFolder:GetChildren()) do
                        if (#{1}==1) and (ball and ball:FindFirstChild("zoomies")) then
                            local velocity = ball.AssemblyLinearVelocity
                            speed = math.min(velocity.Magnitude, maxSpeed) / 6.5
                            break
                        end
                    end
                end

                local size = math.max(speed, 6.5)
                local radius = size * 0.5
                local segmentCount = #visualiser_edges
                local segmentLength = math.max(0.25, (2 * math.pi * radius) / segmentCount)

                for index, edge in ipairs(visualiser_edges) do
                    if edge and hrp then
                        local angle = (index - 1) * (2 * math.pi / segmentCount)
                        edge.Size = Vector3.new(0.05, 0.05, segmentLength)
                        edge.CFrame = hrp.CFrame
                            * CFrame.new(math.cos(angle) * radius, -3.0, math.sin(angle) * radius)
                            * CFrame.Angles(0, angle + math.pi / 2, 0)
                    end
                end
            end)
        else
            if Connections_Manager["Visualiser"] then
                Connections_Manager["Visualiser"]:Disconnect()
                Connections_Manager["Visualiser"] = nil
            end

            if (1<2) and (visualiser_model) then
                visualiser_model:Destroy()
                visualiser_model = nil
                visualiser_edges = {}
            end
        end
    end
})

VisualsGroup:AddCheckbox("Checkbox_VisualiserRainbow", {
    Text = 'Rainbow',
    Callback = function(value: boolean)
        getgenv().VisualiserRainbow = value
    end
})

VisualsGroup:AddSlider("Slider_VisualiserHue", {
    Text = "Color Hue",
    Min = 0,
    Max = (79+281),
    Default = 0,
    Rounding = 0,
    Callback = function(value: number)
        getgenv().VisualiserHue = value
    end
})
VisualsGroup:AddDivider("Misc")
VisualsGroup:AddToggle("Module_Player_Cosmetics", {
    Text = "Player Cosmetics",
    Tooltip = "Apply Headless and Korblox",
    Default = false,
    Callback = function(value: boolean)
        local lp = localPlayer
        getgenv().HeadlessKorbloxEnabled = value

        local function applyKorblox(character)
            if (#{1}==1) and (not character) then
                return
            end

            local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
            if not leg then
                return
            end

            if leg:FindFirstChild("KorbloxMesh") then
                return
            end

            for _, child in ipairs(leg:GetChildren()) do
                if (1<2) and (child:IsA('SpecialMesh')) then
                    child:Destroy()
                end
            end

            local mesh = Instance.new('SpecialMesh')
            mesh.Name = "KorbloxMesh"
            mesh.MeshId = 'rbxassetid://902942096'
            mesh.TextureId = 'rbxassetid://902843398'
            mesh.Offset = Vector3.new(0, 0.7, 0)
            mesh.Parent = leg
        end

        local function restoreKorblox(character)
            if not character then
                return
            end

            local leg = character:FindFirstChild("Right Leg") or character:FindFirstChild('RightLeg')
            if not leg then
                return
            end

            for _, child in ipairs(leg:GetChildren()) do
                if ((3*3)==9) and (child:IsA('SpecialMesh')) then
                    child:Destroy()
                end
            end
        end

        local function applyHeadless(character)
            if not character then
                return
            end

            local head = character:FindFirstChild('Head')
            if not head then
                return
            end

            if (#{1}==1) and (_G.PlayerCosmeticsCleanup.headTransparency == nil) then
                _G.PlayerCosmeticsCleanup.headTransparency = head.Transparency
            end

            local face = head:FindFirstChildOfClass('Decal')
            if face then
                _G.PlayerCosmeticsCleanup.faceDecalId = face.Texture
                _G.PlayerCosmeticsCleanup.faceDecalName = face.Name
            end

            head.Transparency = 1
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA('Decal') or child.Name == "face" then
                    child.Transparency = 1
                elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                    if ((1+1)==2) and (not child:GetAttribute("OriginalScale")) then
                        child:SetAttribute("OriginalScale", child.Scale)
                        child.Scale = Vector3.new(0, 0, 0)
                    end
                end
            end
        end

        local function restoreHeadless(character)
            if not character then
                return
            end

            local head = character:FindFirstChild('Head')
            if not head then
                return
            end

            if (math.floor(1.5)==1) and (_G.PlayerCosmeticsCleanup.headTransparency ~= nil) then
                head.Transparency = _G.PlayerCosmeticsCleanup.headTransparency
            end

            if _G.PlayerCosmeticsCleanup.faceDecalId then
                local newDecal = head:FindFirstChildOfClass('Decal') or Instance.new('Decal', head)
                newDecal.Name = _G.PlayerCosmeticsCleanup.faceDecalName or "face"
                newDecal.Texture = _G.PlayerCosmeticsCleanup.faceDecalId
                newDecal.Face = Enum.NormalId.Front
            end

            for _, child in ipairs(head:GetChildren()) do
                if child:IsA('Decal') or child.Name == "face" then
                    child.Transparency = 0
                elseif child:IsA('SpecialMesh') or child:IsA('DataModelMesh') then
                    local orig = child:GetAttribute("OriginalScale")
                    if (#{1}==1) and (orig) then
                        child.Scale = orig
                        child:SetAttribute("OriginalScale", nil)
                    end
                end
            end
        end

        local function applyCosmetics(character)
            if not character then
                return
            end

            applyKorblox(character)
            applyHeadless(character)
        end

        if value then
            _G.PlayerCosmeticsCleanup = _G.PlayerCosmeticsCleanup or {}
            if (#{1}==1) and (lp.Character) then
                applyCosmetics(lp.Character)
            end

            if _G.PlayerCosmeticsCleanup.characterAddedConn then
                _G.PlayerCosmeticsCleanup.characterAddedConn:Disconnect()
            end

            _G.PlayerCosmeticsCleanup.characterAddedConn = lp.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                applyCosmetics(char)
            end)
        else
            if _G.PlayerCosmeticsCleanup.characterAddedConn then
                _G.PlayerCosmeticsCleanup.characterAddedConn:Disconnect()
                _G.PlayerCosmeticsCleanup.characterAddedConn = nil
            end

            if (math.floor(1.5)==1) and (lp.Character) then
                restoreHeadless(lp.Character)
                restoreKorblox(lp.Character)
            end

            _G.PlayerCosmeticsCleanup = {}
        end
    end
})

if (type({})~="table") then local _t=table.concat({},"") end

if not SKIPPED_MODULES["Custom Announcer"] then
VisualsGroup:AddToggle("Module_Custom_Announcer", {
    Text = "Custom Announcer",
    Tooltip = "Customize the Game Announcements",
    Default = false,
    Callback = function(value: boolean)
        getgenv().CustomAnnouncer = value

        if value then
            local announcerGui = Player:FindFirstChild('PlayerGui') and Player.PlayerGui:FindFirstChild("announcer")
            local winnerLabel = announcerGui and announcerGui:FindFirstChild('Winner')
            if winnerLabel then
                winnerLabel.Text = getgenv().AnnouncerText or "discord.gg/Drift"
            end

            if ((3*3)==9) and (not Connections_Manager["CustomAnnouncer"]) then
                Connections_Manager["CustomAnnouncer"] = announcerGui and announcerGui.ChildAdded:Connect(function(child)
                    if child.Name == 'Winner' then
                        child.Changed:Connect(function(property)
                            if property == 'Text' and getgenv().CustomAnnouncer then
                                child.Text = getgenv().AnnouncerText or "discord.gg/Drift"
                            end
                        end)

                        if (#{1}==1) and (getgenv().CustomAnnouncer) then
                            child.Text = getgenv().AnnouncerText or "discord.gg/Drift"
                        end
                    end
                end)
            end
        else
            if Connections_Manager["CustomAnnouncer"] then
                Connections_Manager["CustomAnnouncer"]:Disconnect()
                Connections_Manager["CustomAnnouncer"] = nil
            end
        end
    end
})

VisualsGroup:AddInput("Textbox_announcer_text", {
    Text = "Custom Announcement Text",
    Placeholder = "Enter Custom Announcement... ",
    Callback = function(text)
        getgenv().AnnouncerText = text

        if getgenv().CustomAnnouncer then
            local announcerGui = Player:FindFirstChild('PlayerGui') and Player.PlayerGui:FindFirstChild("announcer")
            local winnerLabel = announcerGui and announcerGui:FindFirstChild('Winner')
            if ((1+1)==2) and (winnerLabel) then
                winnerLabel.Text = text
            end
        end
    end
})
end

local function setup_late_feature_modules()
local abilityEspBillboards = {}
local abilityEspConnections = {}
local abilityEspPlayerAddedConnection = nil

local function create_ability_esp_for_player(player)
    task.spawn(function()
        local character = player.Character
        while not character or not character.Parent do
            task.wait()
            character = player.Character
        end

        local head = character:WaitForChild('Head', (40-30))
        if not head or not getgenv().AbilityESP then
            return
        end

        local existing = head:FindFirstChild("AbilityESPGui")
        if (math.floor(1.5)==1) and (existing) then
            existing:Destroy()
        end

        local billboard = Instance.new('BillboardGui')
        billboard.Name = "AbilityESPGui"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, bit32.bxor(31,195), 0, (131-71))
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local label = Instance.new('TextLabel')
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB((255+0), (274-19), (3*85))
        label.TextSize = (2*7)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.Roboto
        label.RichText = true
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = billboard
        label.Visible = false

        abilityEspBillboards[player] = label

        local humanoid = character:FindFirstChild('Humanoid')
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end

        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not (character and character.Parent) then
                if (#{1}==1) and (heartbeatConnection) then
                    heartbeatConnection:Disconnect()
                end
                pcall(function()
                    billboard:Destroy()
                end)
                abilityEspBillboards[player] = nil
                return
            end

            if getgenv().AbilityESP then
                label.Visible = true
                local ability = player:GetAttribute("EquippedAbility")
                if ability then
                    label.Text = '<b>' .. tostring(ability) .. "</b>"
                else
                    label.Text = ""
                end
            else
                label.Visible = false
            end
        end)

        abilityEspConnections[player] = heartbeatConnection
    end)
end

local function add_ability_esp_player(player)
if ((1/1)==0) then for _i=1,0 do end end
    if (#{1}==1) and (player == Player) then
        return
    end

    if abilityEspConnections[player] then
        pcall(function()
            abilityEspConnections[player]:Disconnect()
        end)
        abilityEspConnections[player] = nil
    end

    player.CharacterAdded:Connect(function()
        create_ability_esp_for_player(player)
    end)

    if player.Character then
        task.spawn(function()
            create_ability_esp_for_player(player)
        end)
    end
end

local function start_ability_esp()
    if (math.floor(1.5)==1) and (abilityEspPlayerAddedConnection and next(abilityEspConnections)) then
        return
    end
if (1<-1) then local _j=1+1 end

    getgenv().AbilityESP = true

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            add_ability_esp_player(player)
        end
    end

    if not abilityEspPlayerAddedConnection then
        abilityEspPlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
            if ((1+1)==2) and (getgenv().AbilityESP) then
                add_ability_esp_player(player)
            end
        end)
    end
end

local function stop_ability_esp()
    if not getgenv().AbilityESP then
        return
    end

    getgenv().AbilityESP = false

    if abilityEspPlayerAddedConnection then
        pcall(function()
            abilityEspPlayerAddedConnection:Disconnect()
        end)
if (({[1]=false})[1]) then local _z=tostring(0) end
        abilityEspPlayerAddedConnection = nil
    end

    for _, connection in pairs(abilityEspConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    abilityEspConnections = {}

    for _, label in pairs(abilityEspBillboards) do
        pcall(function()
            if (type("")=="string") and (label and label.Parent) then
                label.Parent:Destroy()
            end
        end)
    end
    abilityEspBillboards = {}
end

local hit_Sound_Enabled = false
local hit_Sound_Folder = Instance.new('Folder')
if (#"">2) then local _q={} _q[1]=2 end
hit_Sound_Folder.Name = "Useful Utility"
hit_Sound_Folder.Parent = workspace

local hit_Sound = Instance.new('Sound', hit_Sound_Folder)
hit_Sound.Volume = 6

local hitSoundOptions = {
    'Medal',
    "Fatality",
    'Skeet',
    "Switches",
    "Rust Headshot",
    "Neverlose Sound",
    'Bubble',
    'Laser',
    'Steve',
    "Call of Duty",
    'Bat',
    "TF2 Critical",
    'Saber',
    "Bameware"
}

local hitSoundIds = {
    Medal = 'rbxassetid://6607336718',
    Fatality = 'rbxassetid://6607113255',
    Skeet = 'rbxassetid://6607204501',
    Switches = 'rbxassetid://6607173363',
    ["Rust Headshot"] = 'rbxassetid://138750331387064',
    ["Neverlose Sound"] = 'rbxassetid://110168723447153',
    Bubble = 'rbxassetid://6534947588',
    Laser = 'rbxassetid://7837461331',
    Steve = 'rbxassetid://4965083997',
    ["Call of Duty"] = 'rbxassetid://5952120301',
    Bat = 'rbxassetid://3333907347',
    ["TF2 Critical"] = 'rbxassetid://296102734',
    Saber = 'rbxassetid://8415678813',
    Bameware = 'rbxassetid://3124331820'
}

if not SKIPPED_MODULES["Hit Sounds"] then
CombatGroup:AddToggle("Module_Hit_Sounds", {
    Text = "Hit Sounds",
    Tooltip = "Toggles hit sounds",
    Default = false,
    Callback = function(value: boolean)
        hit_Sound_Enabled = value
    end
})

CombatGroup:AddSlider("Slider_HitSoundVolume", {
    Text = 'Volume',
    Min = 1,
    Max = (2*5),
    Default = 5,
    Rounding = 0,
    Callback = function(value)
        hit_Sound.Volume = value
    end
})

CombatGroup:AddDropdown("Dropdown_hit_sound_type", {
    Text = "Hit Sound Type",
    Options = hitSoundOptions,
    Multi = false,
    Callback = function(selectedOption)
        if hitSoundIds[selectedOption] then
            hit_Sound.SoundId = hitSoundIds[selectedOption]
        else
            warn("Invalid hit sound selection: " .. tostring(selectedOption))
        end
    end
})
end

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if hit_Sound_Enabled then
        hit_Sound:Play()
    end
end)

VisualsGroup:AddToggle("Module_AbilityESPModule", {
    Text = "Ability ESP",
    Tooltip = "Displays equipped abilities above players",
    Default = false,
    Callback = function(state)
        if ((1+1)==2) and (state) then
            start_ability_esp()
        else
            stop_ability_esp()
        end

    end
})
if (#"">2) then local _n=math.floor(3.14) end

local thunder_dash_exploit_connection = nil

local function apply_thunder_dash_exploit()
    if not getgenv().ThunderDashNoCD then
        return
    end

    local shared = ReplicatedStorage:FindFirstChild('Shared')
    local abilities = shared and shared:FindFirstChild("Abilities")
    local thunderDashModule = abilities and abilities:FindFirstChild("Thunder Dash")
    if not thunderDashModule then
        return
    end

    local ok, mod = pcall(require, thunderDashModule)
    if (0==0) and (ok and mod) then
        pcall(function()
            mod.cooldown = 0
            mod.cooldownReductionPerUpgrade = 0
        end)
    end
if (#"">2) then local _n=math.floor(3.14) end
end

local function start_thunder_dash_exploit()
    if thunder_dash_exploit_connection then
        return
    end

    thunder_dash_exploit_connection = RunService.Heartbeat:Connect(function()
        if getgenv().ThunderDashNoCD then
            apply_thunder_dash_exploit()
        end
    end)
end

local function stop_thunder_dash_exploit()
    if (({})~=nil) and (thunder_dash_exploit_connection) then
        thunder_dash_exploit_connection:Disconnect()
        thunder_dash_exploit_connection = nil
    end
end
if ((1/1)==0) then local _q={} _q[1]=2 end

MiscGroup:AddToggle("Module_ThunderDashNoCD", {
    Text = "Thunder Dash No CD",
    Tooltip = "Removes Thunder Dash cooldown",
    Default = false,
    Callback = function(value: boolean)
        getgenv().ThunderDashNoCD = value
        if value then
            apply_thunder_dash_exploit()
            start_thunder_dash_exploit()
        else
            stop_thunder_dash_exploit()
        end
    end
})

end

setup_late_feature_modules()

VisualsGroup:AddToggle("Module_No_Render", {
    Text = "No Render",
    Tooltip = "Disables Rendering of Effects",
    Default = false,
    Callback = function(state: boolean)
        getgenv().No_Render = state

        local playerScripts = Players.LocalPlayer:FindFirstChild('PlayerScripts')
        local effectScripts = playerScripts and playerScripts:FindFirstChild("EffectScripts")
        local clientFX = effectScripts and effectScripts:FindFirstChild("ClientFX")

        if (1<2) and (clientFX) then
            clientFX.Disabled = state
        end

        if state then
            if not Connections_Manager["No Render"] then
                local runtime = workspace:FindFirstChild('Runtime')
                if (math.floor(1.5)==1) and (runtime) then
                    Connections_Manager["No Render"] = runtime.ChildAdded:Connect(function(value)
                        Debris:AddItem(value, 0)
                    end)
                end
            end
        else
            if Connections_Manager["No Render"] then
                Connections_Manager["No Render"]:Disconnect()
                Connections_Manager["No Render"] = nil
            end
        end
    end
})

if System and System.__properties then
    System.__properties.__reverted_remotes = revertedRemotes
end

getgenv()._ZX_SetupSingularity = function()
    DetectionGroup:AddToggle("Module_ZX_SingularityDetection", {
        Text = "Singularity Detection",
        Tooltip = "Blocks parry when Singularity Cape is active",
        Default = false,
        Callback = function(state)
            getgenv().SingularityDetection = state
            if System and System.__config and System.__config.__detections then
                System.__config.__detections.__singularity = state
            end
        end,
    })
end
getgenv()._ZX_SetupSingularity()

getgenv()._ZX_SetupLookAtBall = function()
    getgenv()._ZX_LookAtBall = false
    getgenv()._ZX_SmoothLook = false
    local lookMod = CharacterGroup:AddToggle("Module_ZX_LookAtBall", {
        Text = "Look at Ball",
        Tooltip = "Camera always faces the closest ball",
        Default = false,
        Callback = function(state) getgenv()._ZX_LookAtBall = state end,
    })
    CharacterGroup:AddCheckbox("Checkbox_ZX_SmoothLook", {
        Text = "Smooth Look",
        Callback = function(state) getgenv()._ZX_SmoothLook = state end,
    })
    RunService.Heartbeat:Connect(function(dt)
        if not getgenv()._ZX_LookAtBall then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = nil
        pcall(function()
            local balls = workspace:FindFirstChild("Balls")
            if balls then
                for _, b in ipairs(balls:GetChildren()) do
                    if b:GetAttribute("realBall") then ball = b break end
                end
                if not ball and #balls:GetChildren() > 0 then ball = balls:GetChildren()[1] end
            end
        end)
        if not ball then return end
        local ballPos = ball.Position
        local zoomies = ball:FindFirstChild("zoomies")
        if zoomies and zoomies.VectorVelocity.Magnitude > 30 then
            ballPos = ballPos + zoomies.VectorVelocity * 0.15
        end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local camPos = cam.CFrame.Position
        local toBall = ballPos - camPos
        if toBall.Magnitude < 0.05 then return end
        local targetCFrame = CFrame.new(camPos, ballPos)
        if getgenv()._ZX_SmoothLook then
            local lerpAlpha = math.min(dt * 8, 1)
            local lerpedPos = cam.CFrame.Position:Lerp(targetCFrame.Position, lerpAlpha)
            cam.CFrame = CFrame.new(lerpedPos, ballPos)
        else
            cam.CFrame = targetCFrame
        end
    end)
end
getgenv()._ZX_SetupLookAtBall()

getgenv()._ZX_SetupOrbitBall = function()
    getgenv()._ZX_OrbitBall = false
    getgenv()._ZX_OrbitRadius = 14
    getgenv()._ZX_OrbitSpeed = 4
    local orbitAngle = 0
    if not SKIPPED_MODULES["Orbit Ball"] then
    CharacterGroup:AddToggle("Module_ZX_OrbitBall", {
        Text = "Orbit Ball",
        Tooltip = "Travel to ball then orbit around it",
        Default = false,
        Callback = function(state) getgenv()._ZX_OrbitBall = state end,
    })
    CharacterGroup:AddSlider("Slider_ZX_OrbitRadius", {
        Text = "Orbit Radius (studs)",
        Min = 6, Max = 40, Default = 14, Rounding = 0,
        Callback = function(value) getgenv()._ZX_OrbitRadius = value end,
    })
    CharacterGroup:AddSlider("Slider_ZX_OrbitSpeed", {
        Text = "Orbit Speed",
        Min = 1, Max = 12, Default = 4, Rounding = 0,
        Callback = function(value) getgenv()._ZX_OrbitSpeed = value end,
    })
    end
    RunService.Heartbeat:Connect(function(dt)
        if not getgenv()._ZX_OrbitBall then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local ball = nil
        pcall(function()
            local balls = workspace:FindFirstChild("Balls")
            if balls then
                for _, b in ipairs(balls:GetChildren()) do
                    if b:GetAttribute("realBall") then ball = b break end
                end
                if not ball and #balls:GetChildren() > 0 then ball = balls:GetChildren()[1] end
            end
        end)
        if not ball then return end
        local ballPos = ball.Position
        local radius = math.clamp(getgenv()._ZX_OrbitRadius or 14, 6, 40)
        local speed = math.clamp(getgenv()._ZX_OrbitSpeed or 4, 1, 12)
        local flatDist = Vector3.new(hrp.Position.X - ballPos.X, 0, hrp.Position.Z - ballPos.Z).Magnitude
        local approachDist = radius + 6
        if flatDist > approachDist then
            local flatUnit = (Vector3.new(ballPos.X - hrp.Position.X, 0, ballPos.Z - hrp.Position.Z)).Unit
            local targetPos = ballPos - flatUnit * radius
            pcall(function() hum:MoveTo(targetPos) end)
        else
            local zoomies = ball:FindFirstChild("zoomies")
            local velMag = zoomies and zoomies.VectorVelocity.Magnitude or 0
            local extraSpeed = math.min(velMag / 200, 3)
            orbitAngle = (orbitAngle + dt * (speed + extraSpeed)) % (math.pi * 2)
            local targetX = ballPos.X + math.cos(orbitAngle) * radius
            local targetZ = ballPos.Z + math.sin(orbitAngle) * radius
            local targetPos = Vector3.new(targetX, hrp.Position.Y, targetZ)
            local lerpAlpha = math.min(dt * 8, 1)
            local newPos = hrp.Position:Lerp(targetPos, lerpAlpha)
            hrp.CFrame = CFrame.new(newPos, newPos + (ballPos - newPos) * Vector3.new(1, 0, 1))
        end
    end)
end
getgenv()._ZX_SetupOrbitBall()

getgenv()._ZX_SetupNameSpoof = function()
    getgenv()._ZX_NameSpoofEnabled = false
    local CONFIG = {
        FakeName = ".gg/ROMU",
        FakeDisplay = ".gg/ROMU",
        Badge = utf8.char(0xE000),
        BadgeAlt = "✓",
        UseAltBadge = false,
        Separator = " "
    }
    local Workspace = game:GetService("Workspace")
    local VERIFIED_BADGE = CONFIG.UseAltBadge and CONFIG.BadgeAlt or CONFIG.Badge
    local RealName = LocalPlayer.Name
    local RealDisplay = LocalPlayer.DisplayName
    local TargetName = CONFIG.FakeName
    local TargetDisplay = CONFIG.FakeDisplay .. CONFIG.Separator .. VERIFIED_BADGE
    local function SpoofAndBadge(obj)
        if not getgenv()._ZX_NameSpoofEnabled then return end
        if not obj.Text or obj.Text == "" then return end
        local text = obj.Text
        if text:find(CONFIG.FakeDisplay .. CONFIG.Separator .. VERIFIED_BADGE) then return end
        if text == CONFIG.FakeDisplay then obj.Text = TargetDisplay return end
        if text == CONFIG.FakeName then return end
        local newText = text
        if newText:find(RealDisplay) then newText = newText:gsub(RealDisplay, TargetDisplay) end
        if newText:find(RealName) then newText = newText:gsub(RealName, TargetName) end
        if newText ~= obj.Text then obj.Text = newText end
    end
    local function MonitorObject(obj)
        if not getgenv()._ZX_NameSpoofEnabled then return end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            SpoofAndBadge(obj)
            obj:GetPropertyChangedSignal("Text"):Connect(function() SpoofAndBadge(obj) end)
        end
    end
    local function MonitorBillboard(billboard)
        if not getgenv()._ZX_NameSpoofEnabled then return end
        for _, textObj in pairs(billboard:GetDescendants()) do
            if textObj:IsA("TextLabel") then
                local txt = textObj.Text
                if txt:find(RealDisplay) or txt:find(CONFIG.FakeDisplay) or txt:find(RealName) or txt:find(CONFIG.FakeName) then
                    textObj.Text = TargetDisplay
                end
                textObj:GetPropertyChangedSignal("Text"):Connect(function()
                    if getgenv()._ZX_NameSpoofEnabled and textObj.Text ~= TargetDisplay then textObj.Text = TargetDisplay end
                end)
            end
        end
        billboard.DescendantAdded:Connect(function(obj)
            if not getgenv()._ZX_NameSpoofEnabled then return end
            if obj:IsA("TextLabel") then
                obj.Text = TargetDisplay
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if getgenv()._ZX_NameSpoofEnabled and obj.Text ~= TargetDisplay then obj.Text = TargetDisplay end
                end)
            end
        end)
    end
    local function MonitorCharacter(char)
        if not getgenv()._ZX_NameSpoofEnabled then return end
        local humanoid = char:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.DisplayName = TargetDisplay
            humanoid:GetPropertyChangedSignal("DisplayName"):Connect(function()
                if getgenv()._ZX_NameSpoofEnabled and humanoid.DisplayName ~= TargetDisplay then humanoid.DisplayName = TargetDisplay end
            end)
        end
        task.wait(0.5)
        for _, billboard in pairs(char:GetDescendants()) do
            if billboard:IsA("BillboardGui") then MonitorBillboard(billboard) end
        end
    end
    task.spawn(function()
        while true do
            task.wait(2)
            if getgenv()._ZX_NameSpoofEnabled then
                pcall(function()
                    for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do MonitorObject(v) end
                end)
                pcall(function()
                    local CoreGui = game:GetService("CoreGui")
                    for _, v in ipairs(CoreGui:GetDescendants()) do MonitorObject(v) end
                end)
                if LocalPlayer.Character then pcall(function() MonitorCharacter(LocalPlayer.Character) end) end
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BillboardGui") then
                            for _, textObj in pairs(obj:GetDescendants()) do
                                if textObj:IsA("TextLabel") then
                                    local txt = textObj.Text
                                    if txt:find(RealName) or txt:find(RealDisplay) or txt:find(CONFIG.FakeName) or txt:find(CONFIG.FakeDisplay) then
                                        MonitorBillboard(obj)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.OnIncomingMessage = function(message)
                if not getgenv()._ZX_NameSpoofEnabled then return nil end
                local props = Instance.new("TextChatMessageProperties")
                if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                    props.PrefixText = TargetDisplay
                end
                return props
            end
        end
    end)
    SpoofGroup:AddDivider("Name")
    SpoofGroup:AddToggle("Module_ZX_NameSpoof", {
        Text = "Spoofer",
        Tooltip = "Spoof your name w/verified badge",
        Default = false,
        Callback = function(state)
            getgenv()._ZX_NameSpoofEnabled = state
            if state then
                Library.SendNotification({title = "Name Spoofer", text = "Enabled — name: " .. CONFIG.FakeDisplay, duration = 4})
            else
                Library.SendNotification({title = "Name Spoofer", text = "Disabled", duration = 3})
            end
        end,
    })
    SpoofGroup:AddInput("Textbox_ZX_SpoofedNameText", {
        Text = "Spoofed Name",
        Placeholder = "Enter fake name...",
        Callback = function(value)
            CONFIG.FakeName = value
            CONFIG.FakeDisplay = value
            TargetName = value
            TargetDisplay = value .. CONFIG.Separator .. VERIFIED_BADGE
            Library.SendNotification({title = "Name Spoof", text = "Name set to: " .. value, duration = 3})
        end,
    })
end
getgenv()._ZX_SetupNameSpoof()

getgenv()._ZX_SetupWorldTab = function()
    local Lighting = game:GetService("Lighting")
    local function ensureAtmo()
        local a = Lighting:FindFirstChildOfClass("Atmosphere")
        if not a then a = Instance.new("Atmosphere"); a.Parent = Lighting end
        return a
    end
    local function ensureCC()
        local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Parent = Lighting end
        return cc
    end
    local _origLighting = {}
    WorldGroup:AddDivider("Atmosphere")
    WorldGroup:AddToggle("Module_ZX_WorldAtmo", {
        Text = "Atmosphere", Tooltip = "Control atmosphere", Default = false, Callback = function() end,
    })
    WorldGroup:AddSlider("Slider_ZX_AtmoDensity", {Text = "Density", Min = 0, Max = 100, Default = 30, Rounding = 0, Callback = function(v) ensureAtmo().Density = v / 100 end})
    WorldGroup:AddSlider("Slider_ZX_AtmoOffset", {Text = "Offset", Min = 0, Max = 100, Default = 25, Rounding = 0, Callback = function(v) ensureAtmo().Offset = v / 100 end})
    WorldGroup:AddSlider("Slider_ZX_AtmoGlare", {Text = "Glare", Min = 0, Max = 100, Default = 0, Rounding = 0, Callback = function(v) ensureAtmo().Glare = v / 100 end})
    WorldGroup:AddSlider("Slider_ZX_AtmoHaze", {Text = "Haze", Min = 0, Max = 100, Default = 10, Rounding = 0, Callback = function(v) ensureAtmo().Haze = v / 100 end})
    WorldGroup:AddDivider("Color Correction")
    WorldGroup:AddToggle("Module_ZX_WorldCC", {
        Text = "Color Correction", Tooltip = "Adjust colors", Default = false, Callback = function() end,
    })
    WorldGroup:AddSlider("Slider_ZX_CCSaturation", {Text = "Saturation", Min = 0, Max = 200, Default = 100, Rounding = 0, Callback = function(v) ensureCC().Saturation = (v - 100) / 100 end})
    WorldGroup:AddSlider("Slider_ZX_CCContrast", {Text = "Contrast", Min = 0, Max = 200, Default = 100, Rounding = 0, Callback = function(v) ensureCC().Contrast = (v - 100) / 100 end})
    WorldGroup:AddSlider("Slider_ZX_CCBrightness", {Text = "Brightness", Min = 0, Max = 200, Default = 100, Rounding = 0, Callback = function(v) ensureCC().Brightness = (v - 100) / 100 end})
    WorldGroup:AddDivider("Lightning")
    WorldGroup:AddToggle("Module_ZX_WorldLight", {
        Text = "Lighting", Tooltip = "Control lighting", Default = false, Callback = function() end,
    })
    WorldGroup:AddSlider("Slider_ZX_LBrightness", {Text = "Brightness", Min = 0, Max = 100, Default = 20, Rounding = 0, Callback = function(v) Lighting.Brightness = v / 10 end})
    WorldGroup:AddSlider("Slider_ZX_LClockTime", {Text = "Clock Time", Min = 0, Max = 240, Default = 140, Rounding = 0, Callback = function(v) Lighting.ClockTime = v / 10 end})
    WorldGroup:AddSlider("Slider_ZX_LFogEnd", {Text = "Fog End", Min = 0, Max = 100000, Default = 100000, Rounding = 0, Callback = function(v) Lighting.FogEnd = v end})
    WorldGroup:AddCheckbox("Checkbox_ZX_LShadows", {Text = "Global Shadows", Callback = function(v) Lighting.GlobalShadows = v end})
    WorldGroup:AddDivider("Sky")
    WorldGroup:AddToggle("Module_ZX_SkyColor", {
        Text = "Sky Color Override", Tooltip = "Override sky color",
        Default = false,
        Callback = function(state)
            if state then
                _origLighting.SkyAmbient = Lighting.Ambient
                _origLighting.SkyBright = Lighting.Brightness
                _origLighting.SkyClock = Lighting.ClockTime
                _origLighting.SkyOutdoor = Lighting.OutdoorAmbient
                Lighting.Ambient = Color3.fromRGB(80, 80, 100)
                Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 100)
                Lighting.Brightness = 1.5
                Lighting.ClockTime = 12
            else
                if _origLighting.SkyAmbient then
                    Lighting.Ambient = _origLighting.SkyAmbient
                    Lighting.Brightness = _origLighting.SkyBright
                    Lighting.ClockTime = _origLighting.SkyClock
                    Lighting.OutdoorAmbient = _origLighting.SkyOutdoor
                    _origLighting.SkyAmbient = nil
                end
            end
        end,
    })
    WorldGroup:AddSlider("Slider_ZX_SkyBrightness", {Text = "Brightness", Min = 0, Max = 300, Default = 150, Rounding = 0, Callback = function(v) Lighting.Brightness = v / 100 end})
    WorldGroup:AddSlider("Slider_ZX_SkyClockTime", {Text = "Time of Day", Min = 0, Max = 24, Default = 12, Rounding = 0, Callback = function(v) Lighting.ClockTime = v end})
end
MiscGroup:AddToggle("Module_UnlockAll", {
    Text = "Unlock All",
    Tooltip = "Unlock all Swords, Explosions and Emotes",
    Default = false,
    Callback = function(state)
        getgenv().unlockAllEnabled = state
        if state and getgenv().__runUnlockAll then
            task.spawn(getgenv().__runUnlockAll)
        end
    end
})
local __ContribSrc = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local __Team, __GameContribs = loadstring(__ContribSrc)()

local __DevBox = Cont:AddLeftGroupbox("Team", "wrench")
for __name, __role in pairs(__Team) do
    __DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __role)
end

local __placeId = tostring(game.PlaceId)
if __GameContribs[__placeId] then
    local __ContBox = Cont:AddRightGroupbox("Contributors", "users")
    for __name, __contribution in pairs(__GameContribs[__placeId]) do
        __ContBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __contribution)
    end
end
wait(1)
setclipboard("dsc.gg/getdrift")
getgenv()._ZX_SetupWorldTab()

library:setup_settings()

return Library
