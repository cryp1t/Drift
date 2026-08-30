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
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local ALL_PACKS = {
	"Bronze", "Silver", "Gold", "Platinum", "Diamond",
	"Bonded", "Toxic", "Shadow", "Infernal", "Corrupted",
	"Cosmic", "Eclipse", "Hades", "Heaven", "Chaos",
	"Ordain", "Alpha", "Omega", "Genesis", "Abyssal",
}
local GAME_SETTINGS = {
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

local function getPlayerPlot()
	local spawn = LocalPlayer.RespawnLocation
	if spawn then
		return spawn.Parent
	end
	return nil
end

local function getPlotChildPosition(childName, yOffset)
	local plot = getPlayerPlot()
	if not plot then return nil end

	local child = plot:FindFirstChild(childName)
	if not child then return nil end

	yOffset = yOffset or 5

	if child:IsA("BasePart") then
		return child.CFrame + Vector3.new(0, yOffset, 0)
	end

	if child:IsA("Model") then
		local primary = child.PrimaryPart
		if primary then
			return primary.CFrame + Vector3.new(0, yOffset, 0)
		end

		for _, desc in ipairs(child:GetDescendants()) do
			if desc:IsA("BasePart") then
				return desc.CFrame + Vector3.new(0, yOffset, 0)
			end
		end
	end

	return nil
end

local function getModelCenterPosition(model, yOffset)
	yOffset = yOffset or 5

	if model:IsA("BasePart") then
		return model.CFrame + Vector3.new(0, yOffset, 0)
	end

	if model:IsA("Model") then
		local cf, size = model:GetBoundingBox()
		return cf + Vector3.new(0, (size.Y / 2) + yOffset, 0)
	end

	return nil
end

local function getEquipBestPosition()
	return getPlotChildPosition("EquipBestCards", 5)
end

local function getShopPosition()
	return getPlotChildPosition("GotoShop", 5)
end

local function getSpawnPosition()
	local spawn = LocalPlayer.RespawnLocation
	if spawn and spawn:IsA("BasePart") then
		return spawn.CFrame + Vector3.new(0, 3, 0)
	end
	return nil
end

local function getHumanoidRootPart()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(cf)
	local root = getHumanoidRootPart()
	if root then
		root.CFrame = cf
	end
end

local function getCurrentCFrame()
	local root = getHumanoidRootPart()
	if root then
		return root.CFrame
	end
	return nil
end

local function hasAnySelected(dropdownValue)
	if not dropdownValue or typeof(dropdownValue) ~= "table" then
		return false
	end
	for _, isActive in pairs(dropdownValue) do
		if isActive then
			return true
		end
	end
	return false
end





local function startFly()
	local root = getHumanoidRootPart()
	local hum  = getHumanoid()
	if not root or not hum then return end

	FlyActive = true
	hum.PlatformStand = true

	FlyBodyVelocity = Instance.new("BodyVelocity")
	FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	FlyBodyVelocity.Velocity = Vector3.zero
	FlyBodyVelocity.Parent   = root

	FlyBodyGyro = Instance.new("BodyGyro")
	FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	FlyBodyGyro.P         = 9e4
	FlyBodyGyro.CFrame    = root.CFrame
	FlyBodyGyro.Parent    = root
end

local function stopFly()
	FlyActive = false
	local hum = getHumanoid()
	if hum then
		hum.PlatformStand = false
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

local hasNotifiedNoPack = false

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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
Tabs.Main:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})
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
	Values = ALL_PACKS,
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
		local selected = Options.PackPicker and Options.PackPicker.Value
		if not hasAnySelected(selected) then
			if not hasNotifiedNoPack then
				hasNotifiedNoPack = true
				Library:Notify({
					Title = "Drift",
					Description = "Please select a pack!",
					Time = 4,
				})
			end
			Toggles.FastOpenSelected:SetValue(false)
		else
			hasNotifiedNoPack = false
		end
	else
		hasNotifiedNoPack = false
	end
end)




local TeleportsBox = Tabs.Main:AddRightGroupbox("Teleports", "map-pin")

TeleportsBox:AddButton({
	Text = "Plot",
	Func = function()
		local spawnCF = getSpawnPosition()
		if spawnCF then
			teleportTo(spawnCF)
		else
			Library:Notify({
				Title       = "Drift",
				Description = "Could not find your plot spawn location!",
				Time        = 3,
			})
		end
	end,
	DoubleClick = false,
	Tooltip     = "tp to your plot",
})

TeleportsBox:AddButton({
	Text = "Shops",
	Func = function()
		local shopCF = getShopPosition()
		if shopCF then
			teleportTo(shopCF)
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
		local selected = Options.PlotSelect and Options.PlotSelect.Value
		if not selected or selected == "" then
			Library:Notify({
				Title = "Drift",
				Description = "Please select a plot number first!",
				Time = 4,
			})
			return
		end

		local plotModel = PlotsFolder:FindFirstChild(tostring(selected))
		if not plotModel then
			Library:Notify({
				Title = "Drift",
				Description = "Plot \"" .. tostring(selected) .. "\" does not exist!",
				Time = 4,
			})
			return
		end

		local targetCF = getModelCenterPosition(plotModel, 5)
		if targetCF then
			teleportTo(targetCF)
			Library:Notify({
				Title = "Drift",
				Description = "Teleported to Plot " .. tostring(selected) .. "!",
				Time = 3,
			})
		else
			Library:Notify({
				Title = "Drift",
				Description = "Could not resolve position for Plot " .. tostring(selected) .. "!",
				Time = 4,
			})
		end
	end,
	DoubleClick = false,
	Tooltip = "tp to picked plot",
})

local GameSettingsBox = Tabs.Main:AddRightGroupbox("Game Settings", "sliders-horizontal")


local GameSettingStates = {}

for _, setting in ipairs(GAME_SETTINGS) do
	GameSettingStates[setting.key] = false

	GameSettingsBox:AddToggle(setting.idx, {
		Text = setting.name,
		Default = false,
		Tooltip = "toggle " .. setting.name:lower(),
	})

	Toggles[setting.idx]:OnChanged(function()
		local value = Toggles[setting.idx].Value
		if GameSettingStates[setting.key] ~= value then
			GameSettingStates[setting.key] = value
			pcall(UpdateSetting.FireServer, UpdateSetting, setting.key, value)
		end
	end)
end




task.spawn(function()
	while true do
		for _, setting in ipairs(GAME_SETTINGS) do
			if Toggles[setting.idx] then
				local currentValue = Toggles[setting.idx].Value
				if GameSettingStates[setting.key] ~= currentValue then
					GameSettingStates[setting.key] = currentValue
					pcall(UpdateSetting.FireServer, UpdateSetting, setting.key, currentValue)
				end
			end
		end
		task.wait(1)
		if Library.Unloaded then break end
	end
end)

local ModsBox = Tabs.Player:AddLeftGroupbox("Mods", "wrench")

ModsBox:AddToggle("WalkspeedToggle", {
	Text    = "Speed Hack",
	Default = false,
	Tooltip = "go fast",
})

ModsBox:AddSlider("WalkspeedSlider", {
	Text     = "Walk Speed",
	Default  = 16,
	Min      = 16,
	Max      = 500,
	Rounding = 0,
	Compact  = false,
	Visible  = false,
	Tooltip  = "speed",
})

Toggles.WalkspeedToggle:OnChanged(function()
	local enabled = Toggles.WalkspeedToggle.Value
	Options.WalkspeedSlider:SetVisible(enabled)

	local hum = getHumanoid()
	if hum then
		if enabled then
			hum.WalkSpeed = Options.WalkspeedSlider.Value
		else
			hum.WalkSpeed = DefaultWalkSpeed
		end
	end
end)

Options.WalkspeedSlider:OnChanged(function()
	if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
		local hum = getHumanoid()
		if hum then
			hum.WalkSpeed = Options.WalkspeedSlider.Value
		end
	end
end)





ModsBox:AddDivider()

ModsBox:AddToggle("FlyToggle", {
	Text    = "Fly",
	Default = false,
	Tooltip = "fly",
})

ModsBox:AddSlider("FlySpeedSlider", {
	Text     = "Fly Speed",
	Default  = 50,
	Min      = 10,
	Max      = 500,
	Rounding = 0,
	Compact  = false,
	Visible  = false,
	Tooltip  = "fly speed",
})

Toggles.FlyToggle:OnChanged(function()
	local enabled = Toggles.FlyToggle.Value
	Options.FlySpeedSlider:SetVisible(enabled)

	if enabled then
		FlySpeed = Options.FlySpeedSlider.Value
		startFly()
	else
		stopFly()
	end
end)

Options.FlySpeedSlider:OnChanged(function()
	if Toggles.FlyToggle and Toggles.FlyToggle.Value then
		FlySpeed = Options.FlySpeedSlider.Value
	end
end)





ModsBox:AddDivider()

ModsBox:AddToggle("InfiniteJumpToggle", {
	Text    = "Infinite Jump",
	Default = false,
	Tooltip = "jump forever",
})

Toggles.InfiniteJumpToggle:OnChanged(function()
	InfiniteJumpActive = Toggles.InfiniteJumpToggle.Value
end)





ModsBox:AddToggle("NoClipToggle", {
	Text    = "No Clip",
	Default = false,
	Tooltip = "walk thru walls",
})

Toggles.NoClipToggle:OnChanged(function()
	NoClipActive = Toggles.NoClipToggle.Value
end)




local VisualsBox = Tabs.Player:AddRightGroupbox("Visuals", "eye")

VisualsBox:AddToggle("FOVToggle", {
	Text    = "Field Of View",
	Default = false,
	Tooltip = "custom fov",
})

VisualsBox:AddSlider("FOVSlider", {
	Text     = "FOV",
	Default  = 70,
	Min      = 30,
	Max      = 120,
	Rounding = 0,
	Compact  = false,
	Visible  = false,
	Tooltip  = "fov amount",
})

Toggles.FOVToggle:OnChanged(function()
	local enabled = Toggles.FOVToggle.Value
	Options.FOVSlider:SetVisible(enabled)

	if enabled then
		Camera.FieldOfView = Options.FOVSlider.Value
	else
		Camera.FieldOfView = DefaultFOV
	end
end)

Options.FOVSlider:OnChanged(function()
	if Toggles.FOVToggle and Toggles.FOVToggle.Value then
		Camera.FieldOfView = Options.FOVSlider.Value
	end
end)




local MG = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MG:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MG:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Tooltip = "see binds",
	Callback = function(v)
		Library.KeybindFrame.Visible = v
	end,
})
MG:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Tooltip = "toggle mouse",
	Default = true,
	Callback = function(v)
		Library.ShowCustomCursor = v
	end,
})
MG:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Tooltip = "popup side",
	Text = "Notification Side",
	Callback = function(v)
		Library:SetNotifySide(v)
	end,
})
MG:AddDivider()
MG:AddButton({
	Text = "Unload",
	Func = function()
		Library:Unload()
	end,
	DoubleClick = true,
	Tooltip = "close hub",
})
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/SoccerCard")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()




task.spawn(function()
	while true do
		if Toggles.AutoCollectAll and Toggles.AutoCollectAll.Value then
			for slot = 1, 10 do
				pcall(CollectSlotRemote.FireServer, CollectSlotRemote, slot)
				task.wait(0.05)
			end
		elseif Toggles.AutoCollectSelected and Toggles.AutoCollectSelected.Value then
			local selected = Options.SlotPicker and Options.SlotPicker.Value
			if selected and typeof(selected) == "table" then
				for slotStr, isActive in pairs(selected) do
					if isActive then
						pcall(CollectSlotRemote.FireServer, CollectSlotRemote, tonumber(slotStr))
						task.wait(0.05)
					end
				end
			end
		end

		if Toggles.AutoCollectIndex and Toggles.AutoCollectIndex.Value then
			pcall(ClaimIndexGems.FireServer, ClaimIndexGems)
		end

		task.wait(0.1)
		if Library.Unloaded then break end
	end
end)




task.spawn(function()
	while true do
		if Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value then
			local targetCFrame = getEquipBestPosition()

			if targetCFrame then
				local originalCFrame = getCurrentCFrame()

				teleportTo(targetCFrame)
				task.wait(0.5)

				if Toggles.TPBack and Toggles.TPBack.Value and originalCFrame then
					teleportTo(originalCFrame)
				end
			end

			local threshold = Options.TPThreshold and Options.TPThreshold.Value or 30
			local waited = 0
			while waited < threshold do
				task.wait(0.5)
				waited += 0.5
				if Library.Unloaded then break end
				if not (Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value) then break end
			end
		else
			task.wait(0.25)
		end

		if Library.Unloaded then break end
	end
end)




task.spawn(function()
	while true do
		if Toggles.FastOpenSelected and Toggles.FastOpenSelected.Value then
			local selected = Options.PackPicker and Options.PackPicker.Value
			local delay    = Options.FireDelay and Options.FireDelay.Value or 0.1

			if selected and typeof(selected) == "table" then
				local firedAny = false
				for packName, isActive in pairs(selected) do
					if isActive then
						pcall(OpenPackRemote.FireServer, OpenPackRemote, packName)
						firedAny = true
						task.wait(delay)
					end
					if Library.Unloaded then break end
					if not (Toggles.FastOpenSelected and Toggles.FastOpenSelected.Value) then break end
				end

				if not firedAny then
					task.wait(0.25)
				end
			else
				task.wait(0.25)
			end
		else
			task.wait(0.25)
		end

		if Library.Unloaded then break end
	end
end)




task.spawn(function()
	RunService.RenderStepped:Connect(function()
		if Library.Unloaded then return end

		if FlyActive and FlyBodyVelocity and FlyBodyGyro then
			local root = getHumanoidRootPart()
			if not root then
				stopFly()
				if Toggles.FlyToggle then
					Toggles.FlyToggle:SetValue(false)
				end
				return
			end

			local camCF    = Camera.CFrame
			local moveDir  = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDir = moveDir + camCF.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDir = moveDir - camCF.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDir = moveDir - camCF.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDir = moveDir + camCF.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveDir = moveDir + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveDir = moveDir - Vector3.new(0, 1, 0)
			end

			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit
			end

			local speed = Options.FlySpeedSlider and Options.FlySpeedSlider.Value or FlySpeed
			FlyBodyVelocity.Velocity = moveDir * speed
			FlyBodyGyro.CFrame      = camCF
		end
	end)
end)




task.spawn(function()
	RunService.Stepped:Connect(function()
		if Library.Unloaded then return end

		if NoClipActive then
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end
	end)
end)




UserInputService.JumpRequest:Connect(function()
	if Library.Unloaded then return end

	if InfiniteJumpActive then
		local hum = getHumanoid()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)




task.spawn(function()
	while true do
		if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
			local hum = getHumanoid()
			if hum then
				hum.WalkSpeed = Options.WalkspeedSlider.Value
			end
		end

		if Toggles.FOVToggle and Toggles.FOVToggle.Value then
			Camera.FieldOfView = Options.FOVSlider.Value
		end

		task.wait(0.1)
		if Library.Unloaded then break end
	end
end)




LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end

	task.wait(0.5)

	if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
		hum.WalkSpeed = Options.WalkspeedSlider.Value
	end

	if Toggles.FlyToggle and Toggles.FlyToggle.Value then
		stopFly()
		task.wait(0.1)
		FlySpeed = Options.FlySpeedSlider and Options.FlySpeedSlider.Value or 50
		startFly()
	end
end)

Library:OnUnload(function()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = DefaultWalkSpeed
	end
	stopFly()
	Camera.FieldOfView = DefaultFOV
	NoClipActive       = false
	InfiniteJumpActive = false
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
