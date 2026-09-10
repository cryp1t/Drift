-- UI Setup
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

Library.ShowToggleFrameInKeybinds = true

-- Window & Tabs
local Window = Library:CreateWindow({
	Title = "Drift",
	Footer = "Oil Empire",
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
	Main = Window:AddTab("Main", "house", "Useful features to farm faster"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings", "Customize the Interface"),
	Credits = Window:AddTab("Credits", "info", "People who helped us throughout this project"),
}

Tabs.Main:UpdateWarningBox({
	Title = "Welcome",
	Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
	IsNormal = true,
	Visible = true,
	LockSize = true,
})

-- Helper Functions
local function TeleportTo(Part)
	local Character = LocalPlayer.Character
	if not Character then
		return false
	end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		return false
	end

	if Part and Part:IsA("BasePart") then
		HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 3, 0)
		return true
	end

	return false
end

local function GetPlayerPlot()
	local PlotAttribute = LocalPlayer:GetAttribute("Plot")
	if not PlotAttribute then
		return nil, nil
	end

	local PlayerPlot = workspace.Plots:FindFirstChild(PlotAttribute) or workspace.Plots:FindFirstChild("Plot" .. tostring(PlotAttribute))
	return PlayerPlot, PlotAttribute
end

-- State Variables
local FlyThread = nil
local IsFlying = false
local NoClipConnection = nil
local InfiniteJumpConnection = nil
local OriginalWalkSpeed = 16
local OriginalJumpPower = 50

-- Automations Group
local AutomationsGroupBox = Tabs.Main:AddLeftGroupbox("Automations", "repeat")
local AutoCollectGroupRewardsConnection = nil

AutomationsGroupBox:AddToggle("AutoCollectGroupRewards", {
	Text = "Auto Collect Group Rewards",
	Tooltip = "Automatically collects group rewards repeatedly",
	Default = false,

	Callback = function(Value)
		if Value then
			AutoCollectGroupRewardsConnection = RunService.Heartbeat:Connect(function()
				if Toggles.AutoCollectGroupRewards and Toggles.AutoCollectGroupRewards.Value then
					pcall(function()
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MarketPlaceService"):WaitForChild("RE"):WaitForChild("ClaimReward"):FireServer()
					end)
				end
			end)
		else
			if AutoCollectGroupRewardsConnection then
				AutoCollectGroupRewardsConnection:Disconnect()
				AutoCollectGroupRewardsConnection = nil
			end
		end
	end,
})

local AutoSellConnection = nil

AutomationsGroupBox:AddToggle("AutoSellFuel", {
	Text = "Auto Sell Fuel",
	Tooltip = "Automatically sells fuel repeatedly",
	Default = false,

	Callback = function(Value)
		if Value then
			AutoSellConnection = RunService.Heartbeat:Connect(function()
				if Toggles.AutoSellFuel and Toggles.AutoSellFuel.Value then
					pcall(function()
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BaseService"):WaitForChild("RE"):WaitForChild("SellGas"):FireServer()
					end)
				end
			end)
		else
			if AutoSellConnection then
				AutoSellConnection:Disconnect()
				AutoSellConnection = nil
			end
		end
	end,
})

local AutoCollectThread = nil

AutomationsGroupBox:AddToggle("AutoCollectFuel", {
	Text = "Auto Collect Fuel",
	Tooltip = "Automatically collects fuel from your buildings by spamming firetouchinterest",
	Default = false,

	Callback = function(Value)
		if Value then
			AutoCollectThread = task.spawn(function()
				while Toggles.AutoCollectFuel and Toggles.AutoCollectFuel.Value do
					pcall(function()
						local Character = LocalPlayer.Character
						if not Character then
							return
						end

						local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
						if not HumanoidRootPart then
							return
						end

						local PlotAttribute = LocalPlayer:GetAttribute("Plot")
						if not PlotAttribute then
							return
						end

						local PlayerPlot = workspace.Plots:FindFirstChild(PlotAttribute) or workspace.Plots:FindFirstChild("Plot" .. tostring(PlotAttribute))
						if not PlayerPlot then
							return
						end

						local Buildings = PlayerPlot:FindFirstChild("Buildings")
						if not Buildings then
							return
						end

						local PlaceArea = PlayerPlot:FindFirstChild("PlaceArea")
						for _, Descendant in Buildings:QueryDescendants("Instance") do
							if not (Toggles.AutoCollectFuel and Toggles.AutoCollectFuel.Value) then
								break
							end
							pcall(function()
								firetouchinterest(HumanoidRootPart, Descendant, 0)
							end)
							pcall(function()
								firetouchinterest(HumanoidRootPart, Descendant, 1)
							end)
						end
						if PlaceArea then
							pcall(function()
								firetouchinterest(HumanoidRootPart, PlaceArea, 0)
							end)
							pcall(function()
								firetouchinterest(HumanoidRootPart, PlaceArea, 1)
							end)
						end
					end)

					task.wait()
				end
			end)
		else
			if AutoCollectThread then
				task.cancel(AutoCollectThread)
				AutoCollectThread = nil
			end
		end
	end,
})

-- Pick Up All
AutomationsGroupBox:AddDivider()
AutomationsGroupBox:AddButton({
	Text = "Pick Up All",
	Tooltip = "Picks up all buildings from your plot (double click to confirm)",
	Func = function()
		task.spawn(function()
			local PlotAttribute = LocalPlayer:GetAttribute("Plot")
			if not PlotAttribute then
				Library:Notify({
					Title = "Error",
					Description = "Could not find your plot attribute!",
					Time = 3,
				})
				return
			end

			local PlayerPlot = workspace.Plots:FindFirstChild(PlotAttribute) or workspace.Plots:FindFirstChild("Plot" .. tostring(PlotAttribute))
			if not PlayerPlot then
				Library:Notify({
					Title = "Error",
					Description = "Could not find your plot!",
					Time = 3,
				})
				return
			end

			local Buildings = PlayerPlot:FindFirstChild("Buildings")
			if not Buildings then
				Library:Notify({
					Title = "Error",
					Description = "No buildings folder found!",
					Time = 3,
				})
				return
			end

			local TotalPickedUp = 0
			local MaxAttempts = 100

			for Attempt = 1, MaxAttempts do
				local CurrentBuildings = {}
				for _, Building in Buildings:QueryDescendants("> Model") do
					table.insert(CurrentBuildings, Building.Name)
				end

				if #CurrentBuildings == 0 then
					break
				end

				for _, BuildingName in CurrentBuildings do
					pcall(function()
						local Arguments = {
							BuildingName,
							"PickUp"
						}
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BaseService"):WaitForChild("RE"):WaitForChild("DeleteBuilding"):FireServer(unpack(Arguments))
						TotalPickedUp = TotalPickedUp + 1
					end)
					task.wait(0.15)
				end

				task.wait(0.5)

				local Remaining = 0
				for _, Building in Buildings:QueryDescendants("> Model") do
					Remaining = Remaining + 1
				end

				if Remaining == 0 then
					break
				end
			end

			local FinalRemaining = 0
			for _, Building in Buildings:QueryDescendants("> Model") do
				FinalRemaining = FinalRemaining + 1
			end

			if FinalRemaining == 0 then
				Library:Notify({
					Title = "Pick Up All",
					Description = "Successfully picked up all buildings! (" .. TotalPickedUp .. " requests sent)",
					Time = 4,
				})
			else
				Library:Notify({
					Title = "Pick Up All",
					Description = FinalRemaining .. " buildings still remaining. (" .. TotalPickedUp .. " requests sent)",
					Time = 4,
				})
			end
		end)
	end,
	DoubleClick = true,
})

-- Teleports Group
local TeleportsGroupBox = Tabs.Main:AddLeftGroupbox("Teleports", "map-pin")

TeleportsGroupBox:AddButton({
	Text = "Base",
	Tooltip = "Teleport to your base",
	Func = function()
		pcall(function()
			local PlayerPlot = GetPlayerPlot()
			if not PlayerPlot then
				Library:Notify({ Title = "Error", Description = "Could not find your plot!", Time = 3 })
				return
			end

			local TpPart = PlayerPlot:FindFirstChild("TpHere")
			if not TpPart then
				return
			end

			if TeleportTo(TpPart) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to your base!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Drill Shop",
	Tooltip = "Teleport to the Drill Shop",
	Func = function()
		pcall(function()
			local Part = workspace.Stores["Drill Shop"].Main.Primary
			if TeleportTo(Part) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to Drill Shop!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Refinery Shop",
	Tooltip = "Teleport to the Refinery Shop",
	Func = function()
		pcall(function()
			local Part = workspace.Stores["Refinery Shop"].Main.Primary
			if TeleportTo(Part) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to Refinery Shop!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Totem Shop",
	Tooltip = "Teleport to the Totem Shop",
	Func = function()
		pcall(function()
			local Part = workspace.Stores["Totem Shop"].Main.Primary
			if TeleportTo(Part) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to Totem Shop!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Decoration Shop",
	Tooltip = "Teleport to the Decoration Shop",
	Func = function()
		pcall(function()
			local Part = workspace:GetChildren()[13]:GetChildren()[2].Main.Primary
			if TeleportTo(Part) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to Decoration Shop!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Gasoline Sell",
	Tooltip = "Teleport to the Gasoline Sell area",
	Func = function()
		pcall(function()
			local Part = workspace.Stores.Sell.Main.Primary
			if TeleportTo(Part) then
				Library:Notify({ Title = "Teleport", Description = "Teleported to Gasoline Sell!", Time = 2 })
			end
		end)
	end,
})

TeleportsGroupBox:AddDivider()

TeleportsGroupBox:AddDropdown("SelectPlotDropdown", {
	Values = { "Plot1", "Plot2", "Plot3", "Plot4", "Plot5", "Plot6" },
	Default = nil,
	Multi = false,
	Text = "Select Plot",
	Tooltip = "Select a plot to teleport to",
	FormatDisplayValue = function(Value)
		local Number = Value:match("%d+")
		if Number then
			return "Plot " .. Number
		end
		return Value
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Teleport To Selected",
	Tooltip = "Teleport to the selected plot",
	Func = function()
		local SelectedPlot = Options.SelectPlotDropdown.Value
		if not SelectedPlot or SelectedPlot == "" then
			Library:Notify({ Title = "Error", Description = "Please select a plot first!", Time = 3 })
			return
		end

		pcall(function()
			local TargetPlot = workspace.Plots:FindFirstChild(SelectedPlot)
			if not TargetPlot then
				Library:Notify({ Title = "Error", Description = "Could not find " .. SelectedPlot .. "!", Time = 3 })
				return
			end

			local TpPart = TargetPlot:FindFirstChild("TpHere")
			if not TpPart then
				return
			end

			if TeleportTo(TpPart) then
				local DisplayName = SelectedPlot:match("%d+")
				Library:Notify({ Title = "Teleport", Description = "Teleported to Plot " .. (DisplayName or SelectedPlot) .. "!", Time = 2 })
			end
		end)
	end,
})

-- Shop Group
local ShopGroupBox = Tabs.Main:AddRightGroupbox("Shop", "shopping-cart")

-- Drill Shop
local DrillOptions = {
	"Basic Drill", "Strong Drill", "Enhanced Drill", "Speed Drill",
	"Reinforced Drill", "Industrial Drill", "Double Industrial Drill",
	"Turbo Drill", "Mega Drill", "Mega Emerald Drill", "Hell Drill",
	"Plasma Drill", "Huge Long Drill", "Mega Plasma Drill", "Multi Drill",
	"Lava Drill", "Ice Plasma Drill", "Crystal Drill", "Diamond Drill"
}

ShopGroupBox:AddDropdown("DrillShopDropdown", {
	Values = DrillOptions,
	Default = 1,
	Multi = true,
	Text = "Drill Shop",
	Tooltip = "Select drills to purchase",
	Searchable = true,
})

local PurchaseDrillThread = nil

ShopGroupBox:AddToggle("PurchaseDrill", {
	Text = "Purchase Drill",
	Tooltip = "Purchase selected drills the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			PurchaseDrillThread = task.spawn(function()
				local SelectedDrills = Options.DrillShopDropdown.Value
				local PurchaseAmount = Options.DrillPurchaseAmount.Value or 1

				for DrillName, IsSelected in SelectedDrills do
					if IsSelected then
						for Index = 1, PurchaseAmount do
							pcall(function()
								local Arguments = { "DrillShop", DrillName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
							task.wait(0.1)
						end
					end
				end

				Toggles.PurchaseDrill:SetValue(false)
			end)
		else
			if PurchaseDrillThread then
				task.cancel(PurchaseDrillThread)
				PurchaseDrillThread = nil
			end
		end
	end,
})

local SpamDrillConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseDrill", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected drills",
	Default = false,

	Callback = function(Value)
		if Options.DrillPurchaseAmount then
			Options.DrillPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			SpamDrillConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseDrill and Toggles.SpamPurchaseDrill.Value then
					local SelectedDrills = Options.DrillShopDropdown.Value
					for DrillName, IsSelected in SelectedDrills do
						if IsSelected then
							pcall(function()
								local Arguments = { "DrillShop", DrillName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
						end
					end
				end
			end)
		else
			if SpamDrillConnection then
				SpamDrillConnection:Disconnect()
				SpamDrillConnection = nil
			end
		end
	end,
})

ShopGroupBox:AddSlider("DrillPurchaseAmount", {
	Text = "Purchase Amount",
	Tooltip = "How many times to fire the purchase remote",
	Default = 1,
	Min = 1,
	Max = 5,
	Rounding = 0,
	Compact = false,
})

-- Refinery Shop
ShopGroupBox:AddDivider("Refinery")

local RefineryOptions = {
	"Basic Refinery", "Enhanced Refinery", "Reinforced Refinery",
	"Advanced Refinery", "Plasma Refinery", "Industrial Refinery",
	"Energy Refinery", "Mega Refinery", "Quantum Refinery",
	"Ice Refinery", "Hell Refinery", "Mega Quantum Refinery",
	"Mega Energy Refinery", "Lava Refinery", "Crystal Refinery",
	"Diamond Refinery"
}

ShopGroupBox:AddDropdown("RefineryShopDropdown", {
	Values = RefineryOptions,
	Default = 1,
	Multi = true,
	Text = "Refinery Shop",
	Tooltip = "Select refineries to purchase",
	Searchable = true,
})

local PurchaseRefineryThread = nil

ShopGroupBox:AddToggle("PurchaseRefinery", {
	Text = "Purchase Refinery",
	Tooltip = "Purchase selected refineries the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			PurchaseRefineryThread = task.spawn(function()
				local SelectedRefineries = Options.RefineryShopDropdown.Value
				local PurchaseAmount = Options.RefineryPurchaseAmount.Value or 1

				for RefineryName, IsSelected in SelectedRefineries do
					if IsSelected then
						for Index = 1, PurchaseAmount do
							pcall(function()
								local Arguments = { "RefineryShop", RefineryName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
							task.wait(0.1)
						end
					end
				end

				Toggles.PurchaseRefinery:SetValue(false)
			end)
		else
			if PurchaseRefineryThread then
				task.cancel(PurchaseRefineryThread)
				PurchaseRefineryThread = nil
			end
		end
	end,
})

local SpamRefineryConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseRefinery", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected refineries",
	Default = false,

	Callback = function(Value)
		if Options.RefineryPurchaseAmount then
			Options.RefineryPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			SpamRefineryConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseRefinery and Toggles.SpamPurchaseRefinery.Value then
					local SelectedRefineries = Options.RefineryShopDropdown.Value
					for RefineryName, IsSelected in SelectedRefineries do
						if IsSelected then
							pcall(function()
								local Arguments = { "RefineryShop", RefineryName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
						end
					end
				end
			end)
		else
			if SpamRefineryConnection then
				SpamRefineryConnection:Disconnect()
				SpamRefineryConnection = nil
			end
		end
	end,
})

ShopGroupBox:AddSlider("RefineryPurchaseAmount", {
	Text = "Purchase Amount",
	Tooltip = "How many times to fire the purchase remote",
	Default = 1,
	Min = 1,
	Max = 5,
	Rounding = 0,
	Compact = false,
})

-- Totem Shop
ShopGroupBox:AddDivider("Totems")

local TotemOptions = {
	"Wooden Cash Totem", "Stone Cash Totem", "Copper Cash Totem",
	"Golden Cash Totem", "Diamond Cash Totem", "Ruby Cash Totem"
}

ShopGroupBox:AddDropdown("TotemShopDropdown", {
	Values = TotemOptions,
	Default = 1,
	Multi = true,
	Text = "Totem Shop",
	Tooltip = "Select totems to purchase",
	Searchable = true,
})

local PurchaseTotemThread = nil

ShopGroupBox:AddToggle("PurchaseTotem", {
	Text = "Purchase Totem",
	Tooltip = "Purchase selected totems the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			PurchaseTotemThread = task.spawn(function()
				local SelectedTotems = Options.TotemShopDropdown.Value
				local PurchaseAmount = Options.TotemPurchaseAmount.Value or 1

				for TotemName, IsSelected in SelectedTotems do
					if IsSelected then
						for Index = 1, PurchaseAmount do
							pcall(function()
								local Arguments = { "TotemShop", TotemName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
							task.wait(0.1)
						end
					end
				end

				Toggles.PurchaseTotem:SetValue(false)
			end)
		else
			if PurchaseTotemThread then
				task.cancel(PurchaseTotemThread)
				PurchaseTotemThread = nil
			end
		end
	end,
})

local SpamTotemConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseTotem", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected totems",
	Default = false,

	Callback = function(Value)
		if Options.TotemPurchaseAmount then
			Options.TotemPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			SpamTotemConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseTotem and Toggles.SpamPurchaseTotem.Value then
					local SelectedTotems = Options.TotemShopDropdown.Value
					for TotemName, IsSelected in SelectedTotems do
						if IsSelected then
							pcall(function()
								local Arguments = { "TotemShop", TotemName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(Arguments))
							end)
						end
					end
				end
			end)
		else
			if SpamTotemConnection then
				SpamTotemConnection:Disconnect()
				SpamTotemConnection = nil
			end
		end
	end,
})

ShopGroupBox:AddSlider("TotemPurchaseAmount", {
	Text = "Purchase Amount",
	Tooltip = "How many times to fire the purchase remote",
	Default = 1,
	Min = 1,
	Max = 5,
	Rounding = 0,
	Compact = false,
})

-- Player Group
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player", "user")

AutomationsGroupBox = nil

PlayerGroupBox:AddToggle("WalkspeedToggle", {
	Text = "Walkspeed",
	Tooltip = "Change your walkspeed",
	Default = false,

	Callback = function(Value)
		if Options.SpeedValue then
			Options.SpeedValue:SetVisible(Value)
		end

		local Character = LocalPlayer.Character
		if not Character then
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		if Value then
			OriginalWalkSpeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = Options.SpeedValue and Options.SpeedValue.Value or 16
		else
			Humanoid.WalkSpeed = OriginalWalkSpeed
		end
	end,
})

PlayerGroupBox:AddSlider("SpeedValue", {
	Text = "Speed Value",
	Tooltip = "Set your walkspeed value",
	Default = 16,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Visible = false,

	Callback = function(Value)
		if Toggles.WalkspeedToggle and Toggles.WalkspeedToggle.Value then
			local Character = LocalPlayer.Character
			if Character then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid.WalkSpeed = Value
				end
			end
		end
	end,
})

PlayerGroupBox:AddToggle("FlyToggle", {
	Text = "Fly",
	Tooltip = "CFrame fly",
	Default = false,

	Callback = function(Value)
		if Options.FlySpeed then
			Options.FlySpeed:SetVisible(Value)
		end

		IsFlying = Value

		if Value then
			FlyThread = task.spawn(function()
				local Camera = workspace.CurrentCamera

				while IsFlying do
					local Character = LocalPlayer.Character
					if not Character then
						task.wait()
						continue
					end

					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if not HumanoidRootPart or not Humanoid then
						task.wait()
						continue
					end

					HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

					local Speed = Options.FlySpeed and Options.FlySpeed.Value or 50
					local MoveDirection = Vector3.new(0, 0, 0)

					local LookVector = Camera.CFrame.LookVector
					local RightVector = Camera.CFrame.RightVector

					if UserInputService:IsKeyDown(Enum.KeyCode.W) then
						MoveDirection = MoveDirection + LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then
						MoveDirection = MoveDirection - LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then
						MoveDirection = MoveDirection - RightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then
						MoveDirection = MoveDirection + RightVector
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

					HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (MoveDirection * Speed * (1 / 60))

					RunService.Heartbeat:Wait()
				end
			end)
		else
			IsFlying = false
			if FlyThread then
				task.cancel(FlyThread)
				FlyThread = nil
			end
		end
	end,
})

PlayerGroupBox:AddSlider("FlySpeed", {
	Text = "Fly Speed",
	Tooltip = "Set your fly speed",
	Default = 50,
	Min = 1,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Visible = false,
})

PlayerGroupBox:AddToggle("JumpPowerToggle", {
	Text = "Jump Power",
	Tooltip = "Change your jump power",
	Default = false,

	Callback = function(Value)
		if Options.PowerValue then
			Options.PowerValue:SetVisible(Value)
		end

		local Character = LocalPlayer.Character
		if not Character then
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		if Value then
			OriginalJumpPower = Humanoid.JumpPower
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower = Options.PowerValue and Options.PowerValue.Value or 50
		else
			Humanoid.JumpPower = OriginalJumpPower
		end
	end,
})

PlayerGroupBox:AddSlider("PowerValue", {
	Text = "Power Value",
	Tooltip = "Set your jump power value",
	Default = 50,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Visible = false,

	Callback = function(Value)
		if Toggles.JumpPowerToggle and Toggles.JumpPowerToggle.Value then
			local Character = LocalPlayer.Character
			if Character then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid.UseJumpPower = true
					Humanoid.JumpPower = Value
				end
			end
		end
	end,
})

PlayerGroupBox:AddDivider()

PlayerGroupBox:AddToggle("InfiniteJump", {
	Text = "Infinite Jump",
	Tooltip = "Jump infinitely even in mid-air",
	Default = false,

	Callback = function(Value)
		if Value then
			InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
				if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
					local Character = LocalPlayer.Character
					if Character then
						local Humanoid = Character:FindFirstChildOfClass("Humanoid")
						if Humanoid then
							Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end
			end)
		else
			if InfiniteJumpConnection then
				InfiniteJumpConnection:Disconnect()
				InfiniteJumpConnection = nil
			end
		end
	end,
})

PlayerGroupBox:AddToggle("NoClip", {
	Text = "No Clip",
	Tooltip = "Walk through walls and objects",
	Default = false,

	Callback = function(Value)
		if Value then
			NoClipConnection = RunService.Stepped:Connect(function()
				if Toggles.NoClip and Toggles.NoClip.Value then
					local Character = LocalPlayer.Character
					if Character then
						for _, Part in Character:QueryDescendants("BasePart") do
							Part.CanCollide = false
						end
					end
				end
			end)
		else
			if NoClipConnection then
				NoClipConnection:Disconnect()
				NoClipConnection = nil
			end

			local Character = LocalPlayer.Character
			if Character then
				for _, Part in Character:QueryDescendants("BasePart") do
					Part.CanCollide = true
				end
			end
		end
	end,
})

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
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
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDivider()

MenuGroup:AddButton({
	Text = "Unload",
	Func = function()
		if AutoCollectGroupRewardsConnection then
			AutoCollectGroupRewardsConnection:Disconnect()
		end

		if AutoSellConnection then
			AutoSellConnection:Disconnect()
		end

		if AutoCollectThread then
			task.cancel(AutoCollectThread)
		end

		if PurchaseDrillThread then
			task.cancel(PurchaseDrillThread)
		end

		if PurchaseRefineryThread then
			task.cancel(PurchaseRefineryThread)
		end

		if PurchaseTotemThread then
			task.cancel(PurchaseTotemThread)
		end

		if SpamDrillConnection then
			SpamDrillConnection:Disconnect()
		end

		if SpamRefineryConnection then
			SpamRefineryConnection:Disconnect()
		end

		if SpamTotemConnection then
			SpamTotemConnection:Disconnect()
		end

		if FlyThread then
			IsFlying = false
			task.cancel(FlyThread)
		end

		if NoClipConnection then
			NoClipConnection:Disconnect()
		end

		if InfiniteJumpConnection then
			InfiniteJumpConnection:Disconnect()
		end

		Library:Unload()
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

-- Unload Handler
Library:OnUnload(function()
	if AutoCollectGroupRewardsConnection then
		AutoCollectGroupRewardsConnection:Disconnect()
	end

	if AutoSellConnection then
		AutoSellConnection:Disconnect()
	end

	if AutoCollectThread then
		task.cancel(AutoCollectThread)
	end

	if PurchaseDrillThread then
		task.cancel(PurchaseDrillThread)
	end

	if PurchaseRefineryThread then
		task.cancel(PurchaseRefineryThread)
	end

	if PurchaseTotemThread then
		task.cancel(PurchaseTotemThread)
	end

	if SpamDrillConnection then
		SpamDrillConnection:Disconnect()
	end

	if SpamRefineryConnection then
		SpamRefineryConnection:Disconnect()
	end

	if SpamTotemConnection then
		SpamTotemConnection:Disconnect()
	end

	IsFlying = false

	if FlyThread then
		task.cancel(FlyThread)
	end

	if NoClipConnection then
		NoClipConnection:Disconnect()
	end

	if InfiniteJumpConnection then
		InfiniteJumpConnection:Disconnect()
	end

	pcall(function()
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed = OriginalWalkSpeed
				Humanoid.JumpPower = OriginalJumpPower
			end

			for _, Part in Character:QueryDescendants("BasePart") do
				Part.CanCollide = true
			end
		end
	end)

	print("Script Unloaded!")
end)

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/OilEmpire")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- Credits
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
	Description = "Loaded Succesfully!",
	Time = 5,
})

setclipboard("dsc.gg/getdrift")

Library:Notify({
	Title = "Drift",
	Description = "Copied Discord Link",
	Time = 5,
})