local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
Library.ShowToggleFrameInKeybinds = true
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
	Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project"),
}

Tabs.Main:UpdateWarningBox({
    Title = "Welcome",
    Text = "Hello! Thanks for choosing Drift, Your #1 choice for a keyless experience!",
    IsNormal = true,
    Visible = true,
    LockSize = true,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local function TeleportTo(part)
	local Character = LocalPlayer.Character
	if not Character then return false end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then return false end

	if part and part:IsA("BasePart") then
		HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
		return true
	end
	return false
end

local function GetPlayerPlot()
	local plotAttr = LocalPlayer:GetAttribute("Plot")
	if not plotAttr then return nil, nil end

	local playerPlot = workspace.Plots:FindFirstChild(plotAttr) or workspace.Plots:FindFirstChild("Plot" .. tostring(plotAttr))
	return playerPlot, plotAttr
end

local flyThread = nil
local flying = false
local noclipConnection = nil
local infiniteJumpConnection = nil
local originalWalkspeed = 16
local originalJumpPower = 50
local AutomationsGroupBox = Tabs.Main:AddLeftGroupbox("Automations", "repeat")
local autoCollectGroupRewardsConnection = nil

AutomationsGroupBox:AddToggle("AutoCollectGroupRewards", {
	Text = "Auto Collect Group Rewards",
	Tooltip = "Automatically collects group rewards repeatedly",
	Default = false,

	Callback = function(Value)
		if Value then
			autoCollectGroupRewardsConnection = RunService.Heartbeat:Connect(function()
				if Toggles.AutoCollectGroupRewards and Toggles.AutoCollectGroupRewards.Value then
					pcall(function()
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("MarketPlaceService"):WaitForChild("RE"):WaitForChild("ClaimReward"):FireServer()
					end)
				end
			end)
		else
			if autoCollectGroupRewardsConnection then
				autoCollectGroupRewardsConnection:Disconnect()
				autoCollectGroupRewardsConnection = nil
			end
		end
	end,
})

local autoSellConnection = nil
AutomationsGroupBox:AddToggle("AutoSellFuel", {
	Text = "Auto Sell Fuel",
	Tooltip = "Automatically sells fuel repeatedly",
	Default = false,

	Callback = function(Value)
		if Value then
			autoSellConnection = RunService.Heartbeat:Connect(function()
				if Toggles.AutoSellFuel and Toggles.AutoSellFuel.Value then
					pcall(function()
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BaseService"):WaitForChild("RE"):WaitForChild("SellGas"):FireServer()
					end)
				end
			end)
		else
			if autoSellConnection then
				autoSellConnection:Disconnect()
				autoSellConnection = nil
			end
		end
	end,
})

local autoCollectThread = nil

AutomationsGroupBox:AddToggle("AutoCollectFuel", {
	Text = "Auto Collect Fuel",
	Tooltip = "Automatically collects fuel from your buildings by spamming firetouchinterest",
	Default = false,

	Callback = function(Value)
		if Value then
			autoCollectThread = task.spawn(function()
				while Toggles.AutoCollectFuel and Toggles.AutoCollectFuel.Value do
					pcall(function()
						local Character = LocalPlayer.Character
						if not Character then return end

						local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
						if not HumanoidRootPart then return end

						local plotAttr = LocalPlayer:GetAttribute("Plot")
						if not plotAttr then return end

						local playerPlot = workspace.Plots:FindFirstChild(plotAttr) or workspace.Plots:FindFirstChild("Plot" .. tostring(plotAttr))
						if not playerPlot then return end

						local buildings = playerPlot:FindFirstChild("Buildings")
						if not buildings then return end

						local PlaceArea = playerPlot:FindFirstChild("PlaceArea")
						local descendants = buildings:GetDescendants()
						for _, value in pairs(descendants) do
							if not (Toggles.AutoCollectFuel and Toggles.AutoCollectFuel.Value) then break end
							pcall(function()
								firetouchinterest(HumanoidRootPart, value, 0)
							end)
							pcall(function()
								firetouchinterest(HumanoidRootPart, value, 1)
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

					wait()
				end
			end)
		else
			if autoCollectThread then
				task.cancel(autoCollectThread)
				autoCollectThread = nil
			end
		end
	end,
})
AutomationsGroupBox:AddDivider()
AutomationsGroupBox:AddButton({
	Text = "Pick Up All",
	Tooltip = "Picks up all buildings from your plot (double click to confirm)",
	Func = function()
		task.spawn(function()
			local plotAttr = LocalPlayer:GetAttribute("Plot")
			if not plotAttr then
				Library:Notify({
					Title = "Error",
					Description = "Could not find your plot attribute!",
					Time = 3,
				})
				return
			end

			local playerPlot = workspace.Plots:FindFirstChild(plotAttr) or workspace.Plots:FindFirstChild("Plot" .. tostring(plotAttr))
			if not playerPlot then
				Library:Notify({
					Title = "Error",
					Description = "Could not find your plot!",
					Time = 3,
				})
				return
			end

			local buildings = playerPlot:FindFirstChild("Buildings")
			if not buildings then
				Library:Notify({
					Title = "Error",
					Description = "No buildings folder found!",
					Time = 3,
				})
				return
			end

			local totalPickedUp = 0
			local maxAttempts = 100

			for attempt = 1, maxAttempts do
				local currentBuildings = {}
				for _, building in pairs(buildings:GetChildren()) do
					if building:IsA("Model") then
						table.insert(currentBuildings, building.Name)
					end
				end

				if #currentBuildings == 0 then
					break
				end

				for _, buildingName in pairs(currentBuildings) do
					pcall(function()
						local args = {
							buildingName,
							"PickUp"
						}
						ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BaseService"):WaitForChild("RE"):WaitForChild("DeleteBuilding"):FireServer(unpack(args))
						totalPickedUp = totalPickedUp + 1
					end)
					wait(0.15)
				end

				wait(0.5)

				local remaining = 0
				for _, building in pairs(buildings:GetChildren()) do
					if building:IsA("Model") then
						remaining = remaining + 1
					end
				end

				if remaining == 0 then
					break
				end
			end

			local finalRemaining = 0
			for _, building in pairs(buildings:GetChildren()) do
				if building:IsA("Model") then
					finalRemaining = finalRemaining + 1
				end
			end

			if finalRemaining == 0 then
				Library:Notify({
					Title = "Pick Up All",
					Description = "Successfully picked up all buildings! (" .. totalPickedUp .. " requests sent)",
					Time = 4,
				})
			else
				Library:Notify({
					Title = "Pick Up All",
					Description = finalRemaining .. " buildings still remaining. (" .. totalPickedUp .. " requests sent)",
					Time = 4,
				})
			end
		end)
	end,
	DoubleClick = true,
})

local TeleportsGroupBox = Tabs.Main:AddLeftGroupbox("Teleports", "map-pin")

TeleportsGroupBox:AddButton({
	Text = "Base",
	Tooltip = "Teleport to your base",
	Func = function()
		pcall(function()
			local playerPlot = GetPlayerPlot()
			if not playerPlot then
				Library:Notify({ Title = "Error", Description = "Could not find your plot!", Time = 3 })
				return
			end
			local tpPart = playerPlot:FindFirstChild("TpHere")
			if tpPart then
				if TeleportTo(tpPart) then
					Library:Notify({ Title = "Teleport", Description = "Teleported to your base!", Time = 2 })
				end
			end
		end)
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Drill Shop",
	Tooltip = "Teleport to the Drill Shop",
	Func = function()
		pcall(function()
			local part = workspace.Stores["Drill Shop"].Main.Primary
			if TeleportTo(part) then
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
			local part = workspace.Stores["Refinery Shop"].Main.Primary
			if TeleportTo(part) then
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
			local part = workspace.Stores["Totem Shop"].Main.Primary
			if TeleportTo(part) then
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
			local part = workspace:GetChildren()[13]:GetChildren()[2].Main.Primary
			if TeleportTo(part) then
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
			local part = workspace.Stores.Sell.Main.Primary
			if TeleportTo(part) then
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
		local num = Value:match("%d+")
		if num then return "Plot " .. num end
		return Value
	end,
})

TeleportsGroupBox:AddButton({
	Text = "Teleport To Selected",
	Tooltip = "Teleport to the selected plot",
	Func = function()
		local selectedPlot = Options.SelectPlotDropdown.Value
		if not selectedPlot or selectedPlot == "" then
			Library:Notify({ Title = "Error", Description = "Please select a plot first!", Time = 3 })
			return
		end

		pcall(function()
			local targetPlot = workspace.Plots:FindFirstChild(selectedPlot)
			if targetPlot then
				local tpPart = targetPlot:FindFirstChild("TpHere")
				if tpPart then
					if TeleportTo(tpPart) then
						local displayName = selectedPlot:match("%d+")
						Library:Notify({ Title = "Teleport", Description = "Teleported to Plot " .. (displayName or selectedPlot) .. "!", Time = 2 })
					end
				end
			else
				Library:Notify({ Title = "Error", Description = "Could not find " .. selectedPlot .. "!", Time = 3 })
			end
		end)
	end,
})

local ShopGroupBox = Tabs.Main:AddRightGroupbox("Shop", "shopping-cart")

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

local purchaseDrillThread = nil

ShopGroupBox:AddToggle("PurchaseDrill", {
	Text = "Purchase Drill",
	Tooltip = "Purchase selected drills the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			purchaseDrillThread = task.spawn(function()
				local selectedDrills = Options.DrillShopDropdown.Value
				local purchaseAmount = Options.DrillPurchaseAmount.Value or 1

				for drillName, isSelected in pairs(selectedDrills) do
					if isSelected then
						for i = 1, purchaseAmount do
							pcall(function()
								local args = { "DrillShop", drillName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
							wait(0.1)
						end
					end
				end

				Toggles.PurchaseDrill:SetValue(false)
			end)
		else
			if purchaseDrillThread then
				task.cancel(purchaseDrillThread)
				purchaseDrillThread = nil
			end
		end
	end,
})

local spamDrillConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseDrill", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected drills",
	Default = false,

	Callback = function(Value)
		if Options.DrillPurchaseAmount then
			Options.DrillPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			spamDrillConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseDrill and Toggles.SpamPurchaseDrill.Value then
					local selectedDrills = Options.DrillShopDropdown.Value
					for drillName, isSelected in pairs(selectedDrills) do
						if isSelected then
							pcall(function()
								local args = { "DrillShop", drillName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
						end
					end
				end
			end)
		else
			if spamDrillConnection then
				spamDrillConnection:Disconnect()
				spamDrillConnection = nil
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

local purchaseRefineryThread = nil

ShopGroupBox:AddToggle("PurchaseRefinery", {
	Text = "Purchase Refinery",
	Tooltip = "Purchase selected refineries the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			purchaseRefineryThread = task.spawn(function()
				local selectedRefineries = Options.RefineryShopDropdown.Value
				local purchaseAmount = Options.RefineryPurchaseAmount.Value or 1

				for refineryName, isSelected in pairs(selectedRefineries) do
					if isSelected then
						for i = 1, purchaseAmount do
							pcall(function()
								local args = { "RefineryShop", refineryName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
							wait(0.1)
						end
					end
				end

				Toggles.PurchaseRefinery:SetValue(false)
			end)
		else
			if purchaseRefineryThread then
				task.cancel(purchaseRefineryThread)
				purchaseRefineryThread = nil
			end
		end
	end,
})

local spamRefineryConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseRefinery", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected refineries",
	Default = false,

	Callback = function(Value)
		if Options.RefineryPurchaseAmount then
			Options.RefineryPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			spamRefineryConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseRefinery and Toggles.SpamPurchaseRefinery.Value then
					local selectedRefineries = Options.RefineryShopDropdown.Value
					for refineryName, isSelected in pairs(selectedRefineries) do
						if isSelected then
							pcall(function()
								local args = { "RefineryShop", refineryName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
						end
					end
				end
			end)
		else
			if spamRefineryConnection then
				spamRefineryConnection:Disconnect()
				spamRefineryConnection = nil
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

local purchaseTotemThread = nil

ShopGroupBox:AddToggle("PurchaseTotem", {
	Text = "Purchase Totem",
	Tooltip = "Purchase selected totems the specified amount of times",
	Default = false,

	Callback = function(Value)
		if Value then
			purchaseTotemThread = task.spawn(function()
				local selectedTotems = Options.TotemShopDropdown.Value
				local purchaseAmount = Options.TotemPurchaseAmount.Value or 1

				for totemName, isSelected in pairs(selectedTotems) do
					if isSelected then
						for i = 1, purchaseAmount do
							pcall(function()
								local args = { "TotemShop", totemName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
							wait(0.1)
						end
					end
				end

				Toggles.PurchaseTotem:SetValue(false)
			end)
		else
			if purchaseTotemThread then
				task.cancel(purchaseTotemThread)
				purchaseTotemThread = nil
			end
		end
	end,
})

local spamTotemConnection = nil

ShopGroupBox:AddToggle("SpamPurchaseTotem", {
	Text = "Spam Purchase",
	Tooltip = "Continuously spam purchase selected totems",
	Default = false,

	Callback = function(Value)
		if Options.TotemPurchaseAmount then
			Options.TotemPurchaseAmount:SetVisible(not Value)
		end

		if Value then
			spamTotemConnection = RunService.Heartbeat:Connect(function()
				if Toggles.SpamPurchaseTotem and Toggles.SpamPurchaseTotem.Value then
					local selectedTotems = Options.TotemShopDropdown.Value
					for totemName, isSelected in pairs(selectedTotems) do
						if isSelected then
							pcall(function()
								local args = { "TotemShop", totemName }
								ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("StoresService"):WaitForChild("RE"):WaitForChild("Purchase"):FireServer(unpack(args))
							end)
						end
					end
				end
			end)
		else
			if spamTotemConnection then
				spamTotemConnection:Disconnect()
				spamTotemConnection = nil
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
		if not Character then return end
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then return end

		if Value then
			originalWalkspeed = Humanoid.WalkSpeed
			Humanoid.WalkSpeed = Options.SpeedValue and Options.SpeedValue.Value or 16
		else
			Humanoid.WalkSpeed = originalWalkspeed
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

		flying = Value

		if Value then
			flyThread = task.spawn(function()
				local Camera = workspace.CurrentCamera

				while flying do
					local Character = LocalPlayer.Character
					if not Character then
						wait()
						continue
					end

					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if not HumanoidRootPart or not Humanoid then
						wait()
						continue
					end

					HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

					local speed = Options.FlySpeed and Options.FlySpeed.Value or 50
					local moveDirection = Vector3.new(0, 0, 0)

					local lookVector = Camera.CFrame.LookVector
					local rightVector = Camera.CFrame.RightVector

					if UserInputService:IsKeyDown(Enum.KeyCode.W) then
						moveDirection = moveDirection + lookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then
						moveDirection = moveDirection - lookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then
						moveDirection = moveDirection - rightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then
						moveDirection = moveDirection + rightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
						moveDirection = moveDirection + Vector3.new(0, 1, 0)
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						moveDirection = moveDirection - Vector3.new(0, 1, 0)
					end

					if moveDirection.Magnitude > 0 then
						moveDirection = moveDirection.Unit
					end

					HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (moveDirection * speed * (1 / 60))

					RunService.Heartbeat:Wait()
				end
			end)
		else
			flying = false
			if flyThread then
				task.cancel(flyThread)
				flyThread = nil
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
		if not Character then return end
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then return end

		if Value then
			originalJumpPower = Humanoid.JumpPower
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower = Options.PowerValue and Options.PowerValue.Value or 50
		else
			Humanoid.JumpPower = originalJumpPower
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
			infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
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
			if infiniteJumpConnection then
				infiniteJumpConnection:Disconnect()
				infiniteJumpConnection = nil
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
			noclipConnection = RunService.Stepped:Connect(function()
				if Toggles.NoClip and Toggles.NoClip.Value then
					local Character = LocalPlayer.Character
					if Character then
						for _, part in pairs(Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
					end
				end
			end)
		else
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end
			local Character = LocalPlayer.Character
			if Character then
				for _, part in pairs(Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
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
		if autoCollectGroupRewardsConnection then autoCollectGroupRewardsConnection:Disconnect() end
		if autoSellConnection then autoSellConnection:Disconnect() end
		if autoCollectThread then task.cancel(autoCollectThread) end
		if purchaseDrillThread then task.cancel(purchaseDrillThread) end
		if purchaseRefineryThread then task.cancel(purchaseRefineryThread) end
		if purchaseTotemThread then task.cancel(purchaseTotemThread) end
		if spamDrillConnection then spamDrillConnection:Disconnect() end
		if spamRefineryConnection then spamRefineryConnection:Disconnect() end
		if spamTotemConnection then spamTotemConnection:Disconnect() end
		if flyThread then flying = false; task.cancel(flyThread) end
		if noclipConnection then noclipConnection:Disconnect() end
		if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
		Library:Unload()
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	if autoCollectGroupRewardsConnection then autoCollectGroupRewardsConnection:Disconnect() end
	if autoSellConnection then autoSellConnection:Disconnect() end
	if autoCollectThread then task.cancel(autoCollectThread) end
	if purchaseDrillThread then task.cancel(purchaseDrillThread) end
	if purchaseRefineryThread then task.cancel(purchaseRefineryThread) end
	if purchaseTotemThread then task.cancel(purchaseTotemThread) end
	if spamDrillConnection then spamDrillConnection:Disconnect() end
	if spamRefineryConnection then spamRefineryConnection:Disconnect() end
	if spamTotemConnection then spamTotemConnection:Disconnect() end
	flying = false
	if flyThread then task.cancel(flyThread) end
	if noclipConnection then noclipConnection:Disconnect() end
	if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end

	pcall(function()
		local Character = LocalPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.WalkSpeed = originalWalkspeed
				Humanoid.JumpPower = originalJumpPower
			end
			for _, part in pairs(Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end)

	print("Script Unloaded!")
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Drift")
SaveManager:SetFolder("Drift/OilEmpire")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()



local __ContribSrc = game:HttpGet("https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Contributors.luau")
local __ContribFunc = loadstring(__ContribSrc)
local __Team, __GameContribs = __ContribFunc()

local __DevBox = Tabs.Cont:AddLeftGroupbox("Team", "wrench")
for __name, __role in pairs(__Team) do
    __DevBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __role)
end
local __placeId = tostring(game.PlaceId)
if __GameContribs[__placeId] then
    local __ContBox = Tabs.Cont:AddRightGroupbox("Contributors", "users")
    for __name, __contribution in pairs(__GameContribs[__placeId]) do
        __ContBox:AddLabel("[<font color=\"rgb(255, 255, 100)\">" .. __name .. "</font>] " .. __contribution)
    end
end

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
