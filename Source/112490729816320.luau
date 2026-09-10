-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CollectSlotRemote = Remotes:WaitForChild("CollectSlot")
local OpenPackRemote = Remotes:WaitForChild("OpenPack")
local ClaimIndexGems = Remotes:WaitForChild("ClaimAllIndexGems")
local UpdateSetting = Remotes:WaitForChild("UpdateSetting")
local PlotsFolder = Workspace:WaitForChild("Plots")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

-- Constants
local AllPacks = {
	"Bronze", "Silver", "Gold", "Platinum", "Diamond",
	"Bonded", "Toxic", "Shadow", "Infernal", "Corrupted",
	"Cosmic", "Eclipse", "Hades", "Heaven", "Chaos",
	"Ordain", "Alpha", "Omega", "Genesis", "Abyssal",
}
local GameSettings = {
	{ key = "lowDetailMode", name = "Low Detail Mode", idx = "SettingLowDetail" },
	{ key = "music", name = "Music", idx = "SettingMusic" },
	{ key = "cameraShake", name = "Camera Shake", idx = "SettingCameraShake" },
	{ key = "cardAnimations", name = "Card Animations", idx = "SettingCardAnimations" },
	{ key = "haptics", name = "Vibration", idx = "SettingHaptics" },
	{ key = "gifting", name = "Gifting", idx = "SettingGifting" },
	{ key = "tips", name = "Tips", idx = "SettingTips" },
}
local DefaultWalkSpeed = 16
local DefaultFOV = 70
local FlyActive = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local NoClipActive = false
local InfiniteJumpActive = false
local HasNotifiedNoPack = false

-- Utility Functions
local function GetPlayerPlot()
	local Spawn = LocalPlayer.RespawnLocation
	if Spawn then
		return Spawn.Parent
	end
	return nil
end

local function GetPlotChildPosition(ChildName, YOffset)
	local Plot = GetPlayerPlot()
	if not Plot then
		return nil
	end

	local Child = Plot:FindFirstChild(ChildName)
	if not Child then
		return nil
	end

	YOffset = YOffset or 5

	if Child:IsA("BasePart") then
		return Child.CFrame + Vector3.new(0, YOffset, 0)
	end

	if Child:IsA("Model") then
		local Primary = Child.PrimaryPart
		if Primary then
			return Primary.CFrame + Vector3.new(0, YOffset, 0)
		end

		for _, Descendant in Child:QueryDescendants("BasePart") do
			return Descendant.CFrame + Vector3.new(0, YOffset, 0)
		end
	end

	return nil
end

local function GetModelCenterPosition(Model, YOffset)
	YOffset = YOffset or 5

	if Model:IsA("BasePart") then
		return Model.CFrame + Vector3.new(0, YOffset, 0)
	end

	if Model:IsA("Model") then
		local BoundingBoxCFrame, BoundingBoxSize = Model:GetBoundingBox()
		return BoundingBoxCFrame + Vector3.new(0, (BoundingBoxSize.Y / 2) + YOffset, 0)
	end

	return nil
end

local function GetEquipBestPosition()
	return GetPlotChildPosition("EquipBestCards", 5)
end

local function GetShopPosition()
	return GetPlotChildPosition("GotoShop", 5)
end

local function GetSpawnPosition()
	local Spawn = LocalPlayer.RespawnLocation
	if Spawn and Spawn:IsA("BasePart") then
		return Spawn.CFrame + Vector3.new(0, 3, 0)
	end
	return nil
end

local function GetHumanoidRootPart()
	local Character = LocalPlayer.Character
	if not Character then
		return nil
	end
	return Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
	local Character = LocalPlayer.Character
	if not Character then
		return nil
	end
	return Character:FindFirstChildOfClass("Humanoid")
end

local function TeleportTo(TargetCFrame)
	local Root = GetHumanoidRootPart()
	if Root then
		Root.CFrame = TargetCFrame
	end
end

local function GetCurrentCFrame()
	local Root = GetHumanoidRootPart()
	if Root then
		return Root.CFrame
	end
	return nil
end

local function HasAnySelected(DropdownValue)
	if not DropdownValue or typeof(DropdownValue) ~= "table" then
		return false
	end
	for _, IsActive in DropdownValue do
		if IsActive then
			return true
		end
	end
	return false
end

local function StartFlight()
	local Root = GetHumanoidRootPart()
	local Humanoid = GetHumanoid()
	if not Root or not Humanoid then
		return
	end

	FlyActive = true
	Humanoid.PlatformStand = true

	FlyBodyVelocity = Instance.new("BodyVelocity")
	FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	FlyBodyVelocity.Velocity = Vector3.zero
	FlyBodyVelocity.Parent = Root

	FlyBodyGyro = Instance.new("BodyGyro")
	FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	FlyBodyGyro.P = 9e4
	FlyBodyGyro.CFrame = Root.CFrame
	FlyBodyGyro.Parent = Root
end

local function StopFlight()
	FlyActive = false
	local Humanoid = GetHumanoid()
	if Humanoid then
		Humanoid.PlatformStand = false
	end

	if FlyBodyVelocity then
		FlyBodyVelocity:Destroy()
		FlyBodyVelocity = nil
	end
	if FlyBodyGyro then
		FlyBodyGyro:Destroy()
		FlyBodyGyro = nil
	end
end

-- UI Window & Tabs
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Spin A Soccer Card",
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
	Main = Window:AddTab("Main", "house", "Useful features to farm faster!"),
	Player = Window:AddTab("Player", "user", "Player Modifications"),
	["UI Settings"] = Window:AddTab("Settings", "settings", "Customize the User Interface"),
	Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
}

Tabs.Main:UpdateWarningBox({
	Title = "Welcome",
	Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
	IsNormal = true,
	Visible = true,
	LockSize = true,
})

-- Automations Group
local AutomationsBox = Tabs.Main:AddLeftGroupbox("Automations", "repeat")
AutomationsBox:AddDivider("Main")

AutomationsBox:AddToggle("AutoCollectAll", {
	Text = "Auto Collect Money",
	Default = false,
	Tooltip = "collects your cash",
})

AutomationsBox:AddToggle("AutoCollectIndex", {
	Text = "Auto Collect Index",
	Default = false,
	Tooltip = "collects index gems",
})

AutomationsBox:AddDivider()

AutomationsBox:AddToggle("AutoCollectSelected", {
	Text = "Auto Collect Selected",
	Default = false,
	Tooltip = "collects picked slots",
})

AutomationsBox:AddDropdown("SlotPicker", {
	Values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
	Default = 1,
	Multi = true,
	Text = "Select Slots",
	Tooltip = "pick slots",
})

AutomationsBox:AddToggle("AutoEquipBest", {
	Text = "Auto Equip Best",
	Default = false,
	Visible = false,
	Tooltip = "equips best cards",
})

AutomationsBox:AddToggle("TPBack", {
	Text = "TP Back",
	Default = false,
	Visible = false,
	Tooltip = "tps back after pad",
})

AutomationsBox:AddSlider("TPThreshold", {
	Text = "TP Threshold",
	Default = 30,
	Min = 10,
	Max = 60,
	Visible = false,
	Rounding = 0,
	Suffix = "s",
	Compact = false,
	Tooltip = "how often to tp",
})

AutomationsBox:AddDivider("Opening")

AutomationsBox:AddToggle("FastOpenSelected", {
	Text = "Fast Open Selected",
	Default = false,
	Tooltip = "spams open packs",
})

AutomationsBox:AddDropdown("PackPicker", {
	Values = AllPacks,
	Multi = true,
	Text = "Select Pack",
	Tooltip = "pick packs",
})

AutomationsBox:AddSlider("FireDelay", {
	Text = "Fire Delay",
	Default = 0.1,
	Min = 0.1,
	Max = 3,
	Rounding = 1,
	Suffix = "s",
	Compact = false,
	Tooltip = "wait between opens",
})

Toggles.FastOpenSelected:OnChanged(function()
	if Toggles.FastOpenSelected.Value then
		local Selected = Options.PackPicker and Options.PackPicker.Value
		if not HasAnySelected(Selected) then
			if not HasNotifiedNoPack then
				HasNotifiedNoPack = true
				Library:Notify({
					Title = "Drift",
					Description = "Please select a pack!",
					Time = 4,
				})
			end
			Toggles.FastOpenSelected:SetValue(false)
		else
			HasNotifiedNoPack = false
		end
	else
		HasNotifiedNoPack = false
	end
end)

-- Teleports Group
local TeleportsBox = Tabs.Main:AddRightGroupbox("Teleports", "map-pin")

TeleportsBox:AddButton({
	Text = "Plot",
	Func = function()
		local SpawnCFrame = GetSpawnPosition()
		if SpawnCFrame then
			TeleportTo(SpawnCFrame)
		else
			Library:Notify({
				Title = "Drift",
				Description = "Could not find your plot spawn location!",
				Time = 3,
			})
		end
	end,
	DoubleClick = false,
	Tooltip = "tp to your plot",
})

TeleportsBox:AddButton({
	Text = "Shops",
	Func = function()
		local ShopCFrame = GetShopPosition()
		if ShopCFrame then
			TeleportTo(ShopCFrame)
			task.wait(0.3)
		else
			Library:Notify({
				Title = "Drift",
				Description = "Could not find the shop on your plot!",
				Time = 3,
			})
		end
	end,
	DoubleClick = false,
	Tooltip = "tp to shop",
})

TeleportsBox:AddDivider()
TeleportsBox:AddDropdown("PlotSelect", {
	Values = { "1", "2", "3", "4", "5", "6", "7", "8" },
	Multi = false,
	Text = "Select Plot",
	Tooltip = "pick plot",
})
TeleportsBox:AddButton({
	Text = "Teleport To Plot",
	Func = function()
		local Selected = Options.PlotSelect and Options.PlotSelect.Value
		if not Selected or Selected == "" then
			Library:Notify({
				Title = "Drift",
				Description = "Please select a plot number first!",
				Time = 4,
			})
			return
		end

		local PlotModel = PlotsFolder:FindFirstChild(tostring(Selected))
		if not PlotModel then
			Library:Notify({
				Title = "Drift",
				Description = "Plot \"" .. tostring(Selected) .. "\" does not exist!",
				Time = 4,
			})
			return
		end

		local TargetCFrame = GetModelCenterPosition(PlotModel, 5)
		if TargetCFrame then
			TeleportTo(TargetCFrame)
			Library:Notify({
				Title = "Drift",
				Description = "Teleported to Plot " .. tostring(Selected) .. "!",
				Time = 3,
			})
		else
			Library:Notify({
				Title = "Drift",
				Description = "Could not resolve position for Plot " .. tostring(Selected) .. "!",
				Time = 4,
			})
		end
	end,
	DoubleClick = false,
	Tooltip = "tp to picked plot",
})

-- Game Settings Group
local GameSettingsBox = Tabs.Main:AddRightGroupbox("Game Settings", "sliders-horizontal")
local GameSettingStates = {}

for _, Setting in GameSettings do
	GameSettingStates[Setting.key] = false

	GameSettingsBox:AddToggle(Setting.idx, {
		Text = Setting.name,
		Default = false,
		Tooltip = "toggle " .. Setting.name:lower(),
	})

	Toggles[Setting.idx]:OnChanged(function()
		local Value = Toggles[Setting.idx].Value
		if GameSettingStates[Setting.key] ~= Value then
			GameSettingStates[Setting.key] = Value
			pcall(UpdateSetting.FireServer, UpdateSetting, Setting.key, Value)
		end
	end)
end

-- Player Mods Group
local ModsBox = Tabs.Player:AddLeftGroupbox("Mods", "wrench")

ModsBox:AddToggle("WalkspeedToggle", {
	Text = "Speed Hack",
	Default = false,
	Tooltip = "go fast",
})

ModsBox:AddSlider("WalkspeedSlider", {
	Text = "Walk Speed",
	Default = 16,
	Min = 16,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Visible = false,
	Tooltip = "speed",
})

Toggles.WalkspeedToggle:OnChanged(function()
	local IsEnabled = Toggles.WalkspeedToggle.Value
	Options.WalkspeedSlider:SetVisible(IsEnabled)

	local Humanoid = GetHumanoid()
	if not Humanoid then
		return
	end

	if IsEnabled then
		Humanoid.WalkSpeed = Options.WalkspeedSlider.Value
	else
		Humanoid.WalkSpeed = DefaultWalkSpeed
	end
end)

Options.WalkspeedSlider:OnChanged(function()
	if not Toggles.WalkspeedToggle or not Toggles.WalkspeedToggle.Value then
		return
	end
	local Humanoid = GetHumanoid()
	if Humanoid then
		Humanoid.WalkSpeed = Options.WalkspeedSlider.Value
	end
end)

ModsBox:AddDivider()

ModsBox:AddToggle("FlyToggle", {
	Text = "Fly",
	Default = false,
	Tooltip = "fly",
})

ModsBox:AddSlider("FlySpeedSlider", {
	Text = "Fly Speed",
	Default = 50,
	Min = 10,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Visible = false,
	Tooltip = "fly speed",
})

Toggles.FlyToggle:OnChanged(function()
	local IsEnabled = Toggles.FlyToggle.Value
	Options.FlySpeedSlider:SetVisible(IsEnabled)

	if IsEnabled then
		FlySpeed = Options.FlySpeedSlider.Value
		StartFlight()
	else
		StopFlight()
	end
end)

Options.FlySpeedSlider:OnChanged(function()
	if not Toggles.FlyToggle or not Toggles.FlyToggle.Value then
		return
	end
	FlySpeed = Options.FlySpeedSlider.Value
end)

ModsBox:AddDivider()

ModsBox:AddToggle("InfiniteJumpToggle", {
	Text = "Infinite Jump",
	Default = false,
	Tooltip = "jump forever",
})

Toggles.InfiniteJumpToggle:OnChanged(function()
	InfiniteJumpActive = Toggles.InfiniteJumpToggle.Value
end)

ModsBox:AddToggle("NoClipToggle", {
	Text = "No Clip",
	Default = false,
	Tooltip = "walk thru walls",
})

Toggles.NoClipToggle:OnChanged(function()
	NoClipActive = Toggles.NoClipToggle.Value
end)

-- Visuals Group
local VisualsBox = Tabs.Player:AddRightGroupbox("Visuals", "eye")

VisualsBox:AddToggle("FOVToggle", {
	Text = "Field Of View",
	Default = false,
	Tooltip = "custom fov",
})

VisualsBox:AddSlider("FOVSlider", {
	Text = "FOV",
	Default = 70,
	Min = 30,
	Max = 120,
	Rounding = 0,
	Compact = false,
	Visible = false,
	Tooltip = "fov amount",
})

Toggles.FOVToggle:OnChanged(function()
	local IsEnabled = Toggles.FOVToggle.Value
	Options.FOVSlider:SetVisible(IsEnabled)

	if IsEnabled then
		Camera.FieldOfView = Options.FOVSlider.Value
	else
		Camera.FieldOfView = DefaultFOV
	end
end)

Options.FOVSlider:OnChanged(function()
	if not Toggles.FOVToggle or not Toggles.FOVToggle.Value then
		return
	end
	Camera.FieldOfView = Options.FOVSlider.Value
end)

-- UI Settings Group
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Tooltip = "see binds",
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Tooltip = "toggle mouse",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Tooltip = "popup side",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddButton({
	Text = "Unload",
	Func = function()
		Library:Unload()
	end,
	DoubleClick = true,
	Tooltip = "close hub",
})
Library.ToggleKeybind = Options.MenuKeybind

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/SoccerCard")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- Background Loops
task.spawn(function()
	while true do
		for _, Setting in GameSettings do
			if Toggles[Setting.idx] then
				local CurrentValue = Toggles[Setting.idx].Value
				if GameSettingStates[Setting.key] ~= CurrentValue then
					GameSettingStates[Setting.key] = CurrentValue
					pcall(UpdateSetting.FireServer, UpdateSetting, Setting.key, CurrentValue)
				end
			end
		end
		task.wait(1)
		if Library.Unloaded then
			break
		end
	end
end)

task.spawn(function()
	while true do
		if Toggles.AutoCollectAll and Toggles.AutoCollectAll.Value then
			for Slot = 1, 10 do
				pcall(CollectSlotRemote.FireServer, CollectSlotRemote, Slot)
				task.wait(0.05)
			end
		elseif Toggles.AutoCollectSelected and Toggles.AutoCollectSelected.Value then
			local Selected = Options.SlotPicker and Options.SlotPicker.Value
			if Selected and typeof(Selected) == "table" then
				for SlotKey, IsActive in Selected do
					if IsActive then
						pcall(CollectSlotRemote.FireServer, CollectSlotRemote, tonumber(SlotKey))
						task.wait(0.05)
					end
				end
			end
		end

		if Toggles.AutoCollectIndex and Toggles.AutoCollectIndex.Value then
			pcall(ClaimIndexGems.FireServer, ClaimIndexGems)
		end

		task.wait(0.1)
		if Library.Unloaded then
			break
		end
	end
end)

task.spawn(function()
	while true do
		if Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value then
			local TargetCFrame = GetEquipBestPosition()

			if TargetCFrame then
				local OriginalCFrame = GetCurrentCFrame()

				TeleportTo(TargetCFrame)
				task.wait(0.5)

				if Toggles.TPBack and Toggles.TPBack.Value and OriginalCFrame then
					TeleportTo(OriginalCFrame)
				end
			end

			local Threshold = Options.TPThreshold and Options.TPThreshold.Value or 30
			local Waited = 0
			while Waited < Threshold do
				task.wait(0.5)
				Waited += 0.5
				if Library.Unloaded then
			break
		end
				if not (Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value) then
			break
		end
			end
		else
			task.wait(0.25)
		end

		if Library.Unloaded then
			break
		end
	end
end)

task.spawn(function()
	while true do
		if Toggles.FastOpenSelected and Toggles.FastOpenSelected.Value then
			local Selected = Options.PackPicker and Options.PackPicker.Value
			local Delay = Options.FireDelay and Options.FireDelay.Value or 0.1

			if Selected and typeof(Selected) == "table" then
				local FiredAny = false
				for PackName, IsActive in Selected do
					if IsActive then
						pcall(OpenPackRemote.FireServer, OpenPackRemote, PackName)
						FiredAny = true
						task.wait(Delay)
					end
					if Library.Unloaded then
			break
		end
					if not (Toggles.FastOpenSelected and Toggles.FastOpenSelected.Value) then
				break
			end
				end

				if not FiredAny then
					task.wait(0.25)
				end
			else
				task.wait(0.25)
			end
		else
			task.wait(0.25)
		end

		if Library.Unloaded then
			break
		end
	end
end)

task.spawn(function()
	RunService.RenderStepped:Connect(function()
		if Library.Unloaded then
				return
			end

		if FlyActive and FlyBodyVelocity and FlyBodyGyro then
			local Root = GetHumanoidRootPart()
			if not Root then
				StopFlight()
				if Toggles.FlyToggle then
					Toggles.FlyToggle:SetValue(false)
				end
				return
			end

			local CameraCFrame = Camera.CFrame
			local MoveDirection = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				MoveDirection = MoveDirection + CameraCFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				MoveDirection = MoveDirection - CameraCFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				MoveDirection = MoveDirection - CameraCFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				MoveDirection = MoveDirection + CameraCFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
			end

			if MoveDirection.Magnitude > 0 then
				MoveDirection = MoveDirection.Unit
			end

			local Speed = Options.FlySpeedSlider and Options.FlySpeedSlider.Value or FlySpeed
			FlyBodyVelocity.Velocity = MoveDirection * Speed
			FlyBodyGyro.CFrame = CameraCFrame
		end
	end)
end)

task.spawn(function()
	RunService.Stepped:Connect(function()
		if Library.Unloaded then
				return
			end

		if not NoClipActive then
			return
		end

		local Character = LocalPlayer.Character
		if Character then
			for _, Part in Character:QueryDescendants("BasePart") do
				Part.CanCollide = false
			end
		end
	end)
end)

task.spawn(function()
	while true do
		if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
			local Humanoid = GetHumanoid()
			if Humanoid then
				Humanoid.WalkSpeed = Options.WalkspeedSlider.Value
			end
		end

		if Toggles.FOVToggle and Toggles.FOVToggle.Value then
			Camera.FieldOfView = Options.FOVSlider.Value
		end

		task.wait(0.1)
		if Library.Unloaded then
			break
		end
	end
end)

-- Event Handlers
UserInputService.JumpRequest:Connect(function()
	if Library.Unloaded then
				return
			end

	if not InfiniteJumpActive then
		return
	end

	local Humanoid = GetHumanoid()
	if Humanoid then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(Character)
	local Humanoid = Character:WaitForChild("Humanoid", 10)
	if not Humanoid then
		return
	end

	task.wait(0.5)

	if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
		Humanoid.WalkSpeed = Options.WalkspeedSlider.Value
	end

	if Toggles.FlyToggle and Toggles.FlyToggle.Value then
		StopFlight()
		task.wait(0.1)
		FlySpeed = Options.FlySpeedSlider and Options.FlySpeedSlider.Value or 50
		StartFlight()
	end
end)

-- Unload Handler
Library:OnUnload(function()
	local Humanoid = GetHumanoid()
	if Humanoid then
		Humanoid.WalkSpeed = DefaultWalkSpeed
	end
	StopFlight()
	Camera.FieldOfView = DefaultFOV
	NoClipActive = false
	InfiniteJumpActive = false
end)

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

-- Loaded Notification
task.wait(1)
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
