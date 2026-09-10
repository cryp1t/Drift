-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- References
local LocalPlayer = Players.LocalPlayer

-- Window & Tabs
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Ninja Legends",
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
	Main = Window:AddTab("Main", "swords", "Useful features to farm faster!"),
	Teleports = Window:AddTab("Teleports", "map", "Teleport to certain locations"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings", "Customize the User Interface"),
	Credits = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
}

Tabs.Main:UpdateWarningBox({
	Title = "Welcome",
	Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
	IsNormal = true,
	Visible = true,
	LockSize = true,
})

-- Farm Group
local FarmGroup = Tabs.Main:AddLeftGroupbox("Auto Farm", "boxes")
local BuyGroup = Tabs.Main:AddRightGroupbox("Auto Buy", "shopping-cart")
local PetGroup = Tabs.Main:AddLeftGroupbox("Pet Management", "dog")
local SellPetGroup = Tabs.Main:AddRightGroupbox("Pet Selling", "banknote")
local MiscGroup = Tabs.Main:AddRightGroupbox("Misc", "wrench")

-- Teleport Groups
local IslandGroup = Tabs.Teleports:AddLeftGroupbox("Islands", "map-pin")
local UtilityGroup = Tabs.Teleports:AddRightGroupbox("Utilities", "box")
local AreaGroup = Tabs.Teleports:AddLeftGroupbox("Training Areas", "crosshair")

-- Farm Toggles
FarmGroup:AddToggle("GK", { Text = "Auto-Good Karma", Tooltip = "Auto-farm good karma" })
FarmGroup:AddToggle("BK", { Text = "Auto-Bad Karma", Tooltip = "Auto-farm bad karma" })
FarmGroup:AddDivider()
FarmGroup:AddToggle("Swing", { Text = "Auto-Swing", Tooltip = "Auto-swing your weapon" })
FarmGroup:AddToggle("Sell", { Text = "Auto-Sell", Tooltip = "Auto-sell your ninjitsu" })
FarmGroup:AddToggle("FullSell", { Text = "Auto-Full Sell", Tooltip = "Automatically sell when your backpack is full" })
FarmGroup:AddToggle("Chi", { Text = "Auto-Chi", Tooltip = "Auto-collect Blue Chi Crates in Valley" })
FarmGroup:AddDivider()
FarmGroup:AddToggle("Boss", { Text = "Auto-Robot Boss", Tooltip = "Auto-farm Robot Boss" })
FarmGroup:AddToggle("EBoss", { Text = "Auto-Eternal Boss", Tooltip = "Auto-farm Eternal Boss" })
FarmGroup:AddToggle("ABoss", { Text = "Auto-Ancient Boss", Tooltip = "Auto-farm Ancient Magma Boss" })
FarmGroup:AddToggle("SBoss", { Text = "Auto-Santa Boss", Tooltip = "Auto-farm Samurai Santa" })
FarmGroup:AddToggle("AllBosses", { Text = "Auto-All Bosses", Tooltip = "Auto-farm all available bosses" })
FarmGroup:AddDivider()
FarmGroup:AddToggle("L", { Text = "Auto-Pet Levels", Tooltip = "Auto-level your pets by touching hoops" })

-- Buy Toggles
BuyGroup:AddToggle("Rank", { Text = "Auto-Rank", Tooltip = "Auto-buy ranks" })
BuyGroup:AddToggle("Sword", { Text = "Auto-Sword", Tooltip = "Auto-buy swords" })
BuyGroup:AddToggle("Belt", { Text = "Auto-Belt", Tooltip = "Auto-buy belts" })
BuyGroup:AddToggle("Skill", { Text = "Auto-Skills", Tooltip = "Auto-buy skills" })
BuyGroup:AddToggle("Shurikens", { Text = "Auto-Shurikens", Tooltip = "Auto-buy shurikens" })

-- Crystal Options
local CrystalNames = {}
for _, Crystal in Workspace.mapCrystalsFolder:QueryDescendants("> Instance") do
	table.insert(CrystalNames, Crystal.Name)
end

PetGroup:AddDropdown("Crystal", {
	Text = "Crystals",
	Values = CrystalNames,
	Default = CrystalNames[1],
	Tooltip = "Select which crystal to open",
})

-- Pet Toggles
PetGroup:AddToggle("TEgg", { Text = "Open Crystal", Tooltip = "Start opening the selected crystal" })
PetGroup:AddDivider()
PetGroup:AddToggle("Evolve", { Text = "Auto-Evolve", Tooltip = "Automatically evolve your pets" })
PetGroup:AddToggle("Eternalise", { Text = "Auto-Eternalise", Tooltip = "Automatically eternalise your pets" })
PetGroup:AddToggle("Immortalize", { Text = "Auto-Immortalize", Tooltip = "Automatically immortalize your pets" })
PetGroup:AddToggle("Legend", { Text = "Auto-Legend", Tooltip = "Automatically legendize your pets" })
PetGroup:AddToggle("Elemental", { Text = "Auto-Elementalize", Tooltip = "Automatically elementalize your pets" })

-- Sell Pet Toggles
SellPetGroup:AddToggle("SBasic", { Text = "Sell All Basic", Tooltip = "Sell all basic pets" })
SellPetGroup:AddToggle("SAdvanced", { Text = "Sell All Advanced", Tooltip = "Sell all advanced pets" })
SellPetGroup:AddToggle("SRare", { Text = "Sell All Rare", Tooltip = "Sell all rare pets" })
SellPetGroup:AddToggle("SEpic", { Text = "Sell All Epic", Tooltip = "Sell all epic pets" })
SellPetGroup:AddToggle("SUnique", { Text = "Sell All Unique", Tooltip = "Sell all unique pets" })
SellPetGroup:AddToggle("SOmega", { Text = "Sell All Omega", Tooltip = "Sell all omega pets" })
SellPetGroup:AddToggle("SElite", { Text = "Sell All Elite", Tooltip = "Sell all elite pets" })
SellPetGroup:AddToggle("SInfinity", { Text = "Sell All Infinity", Tooltip = "Sell all infinity pets" })
SellPetGroup:AddDivider()
SellPetGroup:AddToggle("S1", { Text = "Winter Wonder Kitty", Tooltip = "Sell specific pet" })
SellPetGroup:AddToggle("S2", { Text = "Winter Legends Polar Bear", Tooltip = "Sell specific pet" })
SellPetGroup:AddToggle("S3", { Text = "Christmas Sensei Reindeer", Tooltip = "Sell specific pet" })
SellPetGroup:AddToggle("S4", { Text = "Dark Blizzard Master Penguin", Tooltip = "Sell specific pet" })
SellPetGroup:AddToggle("S5", { Text = "Cybernetic Sleigh Rider", Tooltip = "Sell specific pet" })

-- Misc Toggles
MiscGroup:AddToggle("Fast", { Text = "Fast Shuriken", Tooltip = "Increase shuriken speed" })
MiscGroup:AddToggle("Slow", { Text = "Slow Shuriken", Tooltip = "Decrease shuriken speed" })
MiscGroup:AddToggle("Invis", { Text = "Invisibility", Tooltip = "Make yourself invisible" })
MiscGroup:AddDivider()

-- Misc Buttons
MiscGroup:AddButton({
	Text = "Collect All Chest",
	Func = function()
		local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
		local ChestNames = {
			"mythicalChest", "goldenChest", "enchantedChest", "magmaChest",
			"legendsChest", "eternalChest", "saharaChest", "thunderChest",
			"ancientChest", "midnightShadowChest", "groupRewardsCircle",
			"Daily Chest", "wonderChest",
		}

		for _, ChestName in ChestNames do
			if Workspace:FindFirstChild(ChestName) then
				Workspace[ChestName].circleInner.CFrame = HumanoidRootPart.CFrame
				task.wait(3.5)
			end
		end

		local ResetCFrame = Workspace.Part.CFrame
		local ResetChestNames = {
			"ancientChest", "midnightShadowChest", "thunderChest", "saharaChest",
			"eternalChest", "legendsChest", "magmaChest", "enchantedChest",
			"goldenChest", "mythicalChest", "groupRewardsCircle", "Daily Chest",
		}

		for _, ResetChestName in ResetChestNames do
			if Workspace:FindFirstChild(ResetChestName) then
				Workspace[ResetChestName].circleInner.CFrame = ResetCFrame
			end
		end
	end,
})

MiscGroup:AddButton({
	Text = "Collect Light Chest",
	Func = function()
		Workspace.lightKarmaChest.circleInner.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
		task.wait(5)
		Workspace.lightKarmaChest.circleInner.CFrame = Workspace.Part.CFrame
	end,
})

MiscGroup:AddButton({
	Text = "Collect Evil Chest",
	Func = function()
		Workspace.evilKarmaChest.circleInner.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
		task.wait(5)
		Workspace.evilKarmaChest.circleInner.CFrame = Workspace.Part.CFrame
	end,
})

MiscGroup:AddButton({
	Text = "Max Jumps",
	Func = function()
		task.spawn(function()
			while task.wait(0.0001) do
				LocalPlayer.multiJumpCount.Value = "50"
			end
		end)
	end,
})

MiscGroup:AddButton({
	Text = "Hide Name",
	Func = function()
		local PlayerName = LocalPlayer.Name
		Workspace[PlayerName].Head.nameGui:Destroy()
	end,
})

MiscGroup:AddLabel("Popups"):AddKeyPicker("pop", {
	Default = "None",
	SyncToggleState = false,
	Mode = "Toggle",
	Text = "Toggle Popups",
	Callback = function()
		LocalPlayer.PlayerGui.statEffectsGui.Enabled = not LocalPlayer.PlayerGui.statEffectsGui.Enabled
		LocalPlayer.PlayerGui.hoopGui.Enabled = not LocalPlayer.PlayerGui.hoopGui.Enabled
	end,
})

-- Island Teleports
local IslandNames = {}
for _, Island in Workspace.islandUnlockParts:QueryDescendants("> Instance") do
	table.insert(IslandNames, Island.Name)
end

IslandGroup:AddDropdown("IslandTP", {
	Text = "Teleports",
	Values = IslandNames,
	Default = IslandNames[1],
	Tooltip = "Select an island to teleport to",
	Callback = function(Value)
		if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.islandUnlockParts[Value].islandSignPart.CFrame
		end
	end,
})

IslandGroup:AddToggle("UnlockAll", {
	Text = "Unlock All",
	Tooltip = "Teleports to all islands one by one to unlock them",
	Default = false,
})

-- Utility Buttons
UtilityGroup:AddButton({
	Text = "Shop",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.shopAreaCircles["shopAreaCircle11"].circleInner.CFrame
	end,
})

UtilityGroup:AddButton({
	Text = "Skills Shop",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.skillAreaCircles["skillsAreaCircle11"].circleInner.CFrame
	end,
})

UtilityGroup:AddButton({
	Text = "Light Skills Shop",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.49514, 3.24800324, 0.0838552266)
	end,
})

UtilityGroup:AddButton({
	Text = "Dark Skills Shop",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.549767, 3.24800324, 58.087841)
	end,
})

UtilityGroup:AddButton({
	Text = "KOTH",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.kingOfTheHillPart.CFrame
	end,
})

-- Area Buttons
AreaGroup:AddButton({
	Text = "Mystical Waters (Good)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(347.74881, 8824.53809, 114.271019)
	end,
})

AreaGroup:AddButton({
	Text = "Sword of Legends (Good)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1834.15967, 38.704483, -141.375641)
	end,
})

AreaGroup:AddButton({
	Text = "Elemental Tornado (Good)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(299.758484, 30383.0957, -90.1542206)
	end,
})

AreaGroup:AddButton({
	Text = "Lava Pit (Bad)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.631485, 12952.5381, 271.14624)
	end,
})

AreaGroup:AddButton({
	Text = "Tornado (Bad)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(325.641174, 16872.0938, -9.9906435)
	end,
})

AreaGroup:AddButton({
	Text = "Swords Of Ancients (Bad)",
	Func = function()
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(648.365662, 38.704483, 2409.72266)
	end,
})

-- UI Settings Group
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "settings")

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
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

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

-- Auto Karma Farming
task.spawn(function()
	while task.wait(0.4) do
		if Toggles.GK.Value then
			loadstring(game:HttpGet("https://pastebin.com/raw/AaqHqPyw", true))()
		end
	end
end)

task.spawn(function()
	while task.wait(0.4) do
		if Toggles.BK.Value then
			loadstring(game:HttpGet("https://pastebin.com/raw/wEEB3nQt", true))()
		end
	end
end)

-- Auto Swing
task.spawn(function()
	while task.wait() do
		if not Toggles.Swing.Value then
			continue
		end

		if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
			LocalPlayer.ninjaEvent:FireServer("swingKatana")
		else
			for _, Tool in LocalPlayer.Backpack:QueryDescendants("> Tool") do
				if Tool:FindFirstChild("attackShurikenScript") then
					LocalPlayer.Character.Humanoid:EquipTool(Tool)
					task.wait()

					if Tool:FindFirstChild("attackKatanaScript") then
						LocalPlayer.Character.Humanoid:EquipTool(Tool)
					end
				end
			end
		end
	end
end)

-- Auto Sell
task.spawn(function()
	while task.wait(0.01) do
		if not Toggles.Sell.Value then
			continue
		end

		if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		Workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
		task.wait(0.1)
		Workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = Workspace.Part.CFrame
	end
end)

-- Auto Full Sell
task.spawn(function()
	while task.wait(0.01) do
		if not Toggles.FullSell.Value then
			continue
		end

		if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		if LocalPlayer.PlayerGui.gameGui.maxNinjitsuMenu.Visible ~= true then
			continue
		end

		Workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
		task.wait(0.05)
		Workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = Workspace.Part.CFrame
	end
end)

-- Auto Chi
task.spawn(function()
	while task.wait(0.1) do
		if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			continue
		end

		if not Toggles.Chi.Value then
			continue
		end

		for _, Coin in Workspace.spawnedCoins.Valley:QueryDescendants("> Instance") do
			if Coin.Name ~= "Blue Chi Crate" then
				continue
			end

			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Coin.Position)
			task.wait(0.16)
		end
	end
end)

-- Auto Pet Levels
task.spawn(function()
	while task.wait(0.1) do
		if not Toggles.L.Value then
			continue
		end

		for _, Hoop in Workspace.Hoops:QueryDescendants("MeshPart") do
			Hoop.touchPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
		end
	end
end)

-- Boss Farming
local function FarmBoss(ToggleName, BossName)
	task.spawn(function()
		while task.wait(0.1) do
			if not Toggles[ToggleName].Value then
				continue
			end

			local BossPart = Workspace.bossFolder:FindFirstChild(BossName)
				and Workspace.bossFolder[BossName]:FindFirstChild("HumanoidRootPart")

			if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				continue
			end

			if not BossPart then
				continue
			end

			LocalPlayer.Character.HumanoidRootPart.CFrame = BossPart.CFrame

			if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
				LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
			else
				for _, Tool in LocalPlayer.Backpack:QueryDescendants("> Tool") do
					if Tool:FindFirstChild("attackKatanaScript") then
						Tool.attackTime.Value = 0.2
						LocalPlayer.Character.Humanoid:EquipTool(Tool)
					end
				end
			end
		end
	end)
end

FarmBoss("Boss", "RobotBoss")
FarmBoss("EBoss", "EternalBoss")
FarmBoss("ABoss", "AncientMagmaBoss")
FarmBoss("SBoss", "Samurai Santa")

-- Auto All Bosses
task.spawn(function()
	while task.wait(0.1) do
		if not Toggles.AllBosses.Value then
			continue
		end

		local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			continue
		end

		local BossFolder = Workspace.bossFolder
		local Target = BossFolder:FindFirstChild("Samurai Santa")
			or BossFolder:FindFirstChild("AncientMagmaBoss")
			or BossFolder:FindFirstChild("EternalBoss")
			or BossFolder:FindFirstChild("RobotBoss")

		if not Target or not Target:FindFirstChild("HumanoidRootPart") then
			continue
		end

		RootPart.CFrame = Target.HumanoidRootPart.CFrame

		if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
			LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
		else
			for _, Tool in LocalPlayer.Backpack:QueryDescendants("> Tool") do
				if Tool:FindFirstChild("attackKatanaScript") then
					Tool.attackTime.Value = 0.2
					LocalPlayer.Character.Humanoid:EquipTool(Tool)
				end
			end
		end
	end
end)

-- Auto Purchasing
local function PurchaseTask(ToggleName, EventName)
	task.spawn(function()
		while task.wait(0.5) do
			if not Toggles[ToggleName].Value then
				continue
			end

			local BuyLocations = {
				"Ground", "Astral Island", "Space Island", "Tundra Island",
				"Eternal Island", "Sandstorm", "Thunderstorm",
				"Ancient Inferno Island", "Midnight Shadow Island",
				"Mythical Souls Island", "Winter Wonder Island",
			}

			for _, Location in BuyLocations do
				LocalPlayer.ninjaEvent:FireServer(EventName, Location)
			end
		end
	end)
end

PurchaseTask("Sword", "buyAllSwords")
PurchaseTask("Belt", "buyAllBelts")
PurchaseTask("Skill", "buyAllSkills")
PurchaseTask("Shurikens", "buyAllShurikens")

-- Auto Rank
task.spawn(function()
	while task.wait(0.5) do
		if not Toggles.Rank.Value then
			continue
		end

		local Ranks = ReplicatedStorage.Ranks.Ground:QueryDescendants("> Instance")

		for _, Rank in Ranks do
			LocalPlayer.ninjaEvent:FireServer("buyRank", Rank.Name)
		end
	end
end)

-- Auto Crystal Opening
task.spawn(function()
	while task.wait(0.01) do
		if not Toggles.TEgg.Value then
			continue
		end

		ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", Options.Crystal.Value)
	end
end)

-- Pet Upgrading
local function UpgradePets(ToggleName, EventName)
	task.spawn(function()
		while task.wait(3) do
			if not Toggles[ToggleName].Value then
				continue
			end

			for _, Pet in LocalPlayer.petsFolder:QueryDescendants("> Instance") do
				for _, SubPet in Pet:QueryDescendants("> Instance") do
					ReplicatedStorage.rEvents[EventName]:FireServer(EventName:gsub("Event", ""), SubPet.Name)
				end
			end
		end
	end)
end

UpgradePets("Evolve", "petEvolveEvent")
UpgradePets("Eternalise", "petEternalizeEvent")
UpgradePets("Immortalize", "petImmortalizeEvent")
UpgradePets("Legend", "petLegendEvent")
UpgradePets("Elemental", "petLegendEvent")

-- Pet Selling
local function SellPets(ToggleName, FolderName)
	task.spawn(function()
		while task.wait(1) do
			if not Toggles[ToggleName].Value then
				continue
			end

			for _, Pet in LocalPlayer.petsFolder[FolderName]:QueryDescendants("> Instance") do
				ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", Pet)
			end
		end
	end)
end

local SellFolderMap = {
	SBasic = "Basic",
	SAdvanced = "Advanced",
	SRare = "Rare",
	SEpic = "Epic",
	SUnique = "Unique",
	SOmega = "Omega",
	SElite = "Elite",
	SInfinity = "Infinity",
}

for ToggleName, FolderName in SellFolderMap do
	SellPets(ToggleName, FolderName)
end

-- Specific Pet Selling
local function SellSpecificPet(ToggleName, PetName)
	task.spawn(function()
		while task.wait(1) do
			if not Toggles[ToggleName].Value then
				continue
			end

			for _, Pet in LocalPlayer.petsFolder.Infinity:QueryDescendants("> Instance") do
				if Pet.Name == PetName then
					ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", Pet)
				end
			end
		end
	end)
end

SellSpecificPet("S1", "Winter Wonder Kitty")
SellSpecificPet("S2", "Winter Legends Polar Bear")
SellSpecificPet("S3", "Christmas Sensei Reindeer")
SellSpecificPet("S4", "Dark Blizzard Master Penguin")
SellSpecificPet("S5", "Cybernetic Sleigh Rider")

-- Auto Invisibility
task.spawn(function()
	while task.wait(0.001) do
		if not Toggles.Invis.Value then
			continue
		end

		LocalPlayer.ninjaEvent:FireServer("goInvisible")
	end
end)

-- Shuriken Speed
local function SetShurikenSpeed(ToggleName, Velocity)
	task.spawn(function()
		while task.wait(0.001) do
			if not Toggles[ToggleName].Value then
				continue
			end

			local Mouse = LocalPlayer:GetMouse()

			for _, Projectile in Workspace.shurikensFolder:QueryDescendants("> Instance") do
				if Projectile.Name ~= "Handle" then
					continue
				end

				if not Projectile:FindFirstChildOfClass("BodyVelocity") then
					continue
				end

				local BodyVelocity = Projectile:FindFirstChildOfClass("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				BodyVelocity.Velocity = Mouse.Hit.lookVector * Velocity
			end
		end
	end)
end

SetShurikenSpeed("Fast", 1000)
SetShurikenSpeed("Slow", 35)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Auto Unlock All
task.spawn(function()
	while task.wait(0.6) do
		if not Toggles.UnlockAll.Value then
			continue
		end

		for _, Island in Workspace.islandUnlockParts:QueryDescendants("> Instance") do
			if not Toggles.UnlockAll.Value then
				break
			end

			if not Island:FindFirstChild("islandSignPart") then
				continue
			end

			LocalPlayer.Character.HumanoidRootPart.CFrame = Island.islandSignPart.CFrame
			task.wait(0.5)
		end

		Toggles.UnlockAll:SetValue(false)
	end
end)

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/NinjaLegends")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

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
