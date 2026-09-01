local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastefy.app/hOgTtQmZ/raw"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

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
    Cont = Window:AddTab("Credits", "info", "People who helped us throughout this project!"),
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
local FarmGroup = Tabs.Main:AddLeftGroupbox("Auto Farm", "boxes")
local BuyGroup = Tabs.Main:AddRightGroupbox("Auto Buy", "shopping-cart")
local PetGroup = Tabs.Main:AddLeftGroupbox("Pet Management", "dog")
local SellPetGroup = Tabs.Main:AddRightGroupbox("Pet Selling", "banknote")
local MiscGroup = Tabs.Main:AddRightGroupbox("Misc", "wrench")
local IslandGroup = Tabs.Teleports:AddLeftGroupbox("Islands", "map-pin")
local UtilityGroup = Tabs.Teleports:AddRightGroupbox("Utilities", "box")
local AreaGroup = Tabs.Teleports:AddLeftGroupbox("Training Areas", "crosshair")
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
BuyGroup:AddToggle("Rank", { Text = "Auto-Rank", Tooltip = "Auto-buy ranks" })
BuyGroup:AddToggle("Sword", { Text = "Auto-Sword", Tooltip = "Auto-buy swords" })
BuyGroup:AddToggle("Belt", { Text = "Auto-Belt", Tooltip = "Auto-buy belts" })
BuyGroup:AddToggle("Skill", { Text = "Auto-Skills", Tooltip = "Auto-buy skills" })
BuyGroup:AddToggle("Shurikens", { Text = "Auto-Shurikens", Tooltip = "Auto-buy shurikens" })
local Crystals = {}
for i,v in next, game.workspace.mapCrystalsFolder:GetChildren() do 
    if v then table.insert(Crystals, v.Name) end
end
PetGroup:AddDropdown("Crystal", {
    Text = "Crystals",
    Values = Crystals,
    Default = Crystals[1],
    Tooltip = "Select which crystal to open"
})
PetGroup:AddToggle("TEgg", { Text = "Open Crystal", Tooltip = "Start opening the selected crystal" })
PetGroup:AddDivider()
PetGroup:AddToggle("Evolve", { Text = "Auto-Evolve", Tooltip = "Automatically evolve your pets" })
PetGroup:AddToggle("Eternalise", { Text = "Auto-Eternalise", Tooltip = "Automatically eternalise your pets" })
PetGroup:AddToggle("Immortalize", { Text = "Auto-Immortalize", Tooltip = "Automatically immortalize your pets" })
PetGroup:AddToggle("Legend", { Text = "Auto-Legend", Tooltip = "Automatically legendize your pets" })
PetGroup:AddToggle("Elemental", { Text = "Auto-Elementalize", Tooltip = "Automatically elementalize your pets" })
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
MiscGroup:AddToggle("Fast", { Text = "Fast Shuriken", Tooltip = "Increase shuriken speed" })
MiscGroup:AddToggle("Slow", { Text = "Slow Shuriken", Tooltip = "Decrease shuriken speed" })
MiscGroup:AddToggle("Invis", { Text = "Invisibility", Tooltip = "Make yourself invisible" })
MiscGroup:AddDivider()
MiscGroup:AddButton({
    Text = "Collect All Chest",
    Func = function()
        local h = game.Players.LocalPlayer.Character.HumanoidRootPart
        local chests = {"mythicalChest", "goldenChest", "enchantedChest", "magmaChest", "legendsChest", "eternalChest", "saharaChest", "thunderChest", "ancientChest", "midnightShadowChest", "groupRewardsCircle", "Daily Chest", "wonderChest"}
        for _, cName in ipairs(chests) do
            if workspace:FindFirstChild(cName) then
                workspace[cName].circleInner.CFrame = h.CFrame
                wait(3.5)
            end
        end
        local p = workspace.Part.CFrame
        local reset = {"ancientChest", "midnightShadowChest", "thunderChest", "saharaChest", "eternalChest", "legendsChest", "magmaChest", "enchantedChest", "goldenChest", "mythicalChest", "groupRewardsCircle", "Daily Chest"}
        for _, rName in ipairs(reset) do if workspace:FindFirstChild(rName) then workspace[rName].circleInner.CFrame = p end end
    end
})
MiscGroup:AddButton({ Text = "Collect Light Chest", Func = function() workspace.lightKarmaChest.circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame; wait(5); workspace.lightKarmaChest.circleInner.CFrame = workspace.Part.CFrame end })
MiscGroup:AddButton({ Text = "Collect Evil Chest", Func = function() workspace.evilKarmaChest.circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame; wait(5); workspace.evilKarmaChest.circleInner.CFrame = workspace.Part.CFrame end })
MiscGroup:AddButton({ Text = "Max Jumps", Func = function() task.spawn(function() while task.wait(.0001) do game.Players.LocalPlayer.multiJumpCount.Value = "50" end end) end })
MiscGroup:AddButton({ Text = "Hide Name", Func = function() local n = game.Players.LocalPlayer.Name; workspace[n].Head.nameGui:Destroy() end })
MiscGroup:AddLabel("Popups"):AddKeyPicker("pop", { Default = "None", SyncToggleState = false, Mode = "Toggle", Text = "Toggle Popups", Callback = function() game.Players.LocalPlayer.PlayerGui.statEffectsGui.Enabled = not game.Players.LocalPlayer.PlayerGui.statEffectsGui.Enabled; game.Players.LocalPlayer.PlayerGui.hoopGui.Enabled = not game.Players.LocalPlayer.PlayerGui.hoopGui.Enabled end })
local Islands = {}
for i,v in next, game.workspace.islandUnlockParts:GetChildren() do 
    if v then table.insert(Islands, v.Name) end
end
IslandGroup:AddDropdown("IslandTP", {
    Text = "Teleports",
    Values = Islands,
    Default = Islands[1],
    Tooltip = "Select an island to teleport to",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.islandUnlockParts[Value].islandSignPart.CFrame
        end
    end
})
IslandGroup:AddToggle("UnlockAll", {
    Text = "Unlock All",
    Tooltip = "Teleports to all islands one by one to unlock them",
    Default = false
})
UtilityGroup:AddButton({ Text = "Shop", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").shopAreaCircles["shopAreaCircle11"].circleInner.CFrame end })
UtilityGroup:AddButton({ Text = "Skills Shop", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").skillAreaCircles["skillsAreaCircle11"].circleInner.CFrame end })
UtilityGroup:AddButton({ Text = "Light Skills Shop", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.49514, 3.24800324, 0.0838552266) end })
UtilityGroup:AddButton({ Text = "Dark Skills Shop", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.549767, 3.24800324, 58.087841) end })
UtilityGroup:AddButton({ Text = "KOTH", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").kingOfTheHillPart.CFrame end })

AreaGroup:AddButton({ Text = "Mystical Waters (Good)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(347.74881, 8824.53809, 114.271019) end })
AreaGroup:AddButton({ Text = "Sword of Legends (Good)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1834.15967, 38.704483, -141.375641) end })
AreaGroup:AddButton({ Text = "Elemental Tornado (Good)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(299.758484, 30383.0957, -90.1542206) end })
AreaGroup:AddButton({ Text = "Lava Pit (Bad)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-116.631485, 12952.5381, 271.14624) end })
AreaGroup:AddButton({ Text = "Tornado (Bad)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(325.641174, 16872.0938, -9.9906435) end })
AreaGroup:AddButton({ Text = "Swords Of Ancients (Bad)", Func = function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(648.365662, 38.704483, 2409.72266) end })
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "settings")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Tooltip = "toggle mouse",
	Default = true,
	Callback = function(v)
		Library.ShowCustomCursor = v
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Tooltip = "popup side",
	Text = "Notification Side",
	Callback = function(v)
		Library:SetNotifySide(v)
	end,
})
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(v) Library.KeybindFrame.Visible = v end })
MenuGroup:AddDivider()
MenuGroup:AddButton("Unload", function() Library:Unload() end)
Library.ToggleKeybind = Library.Options.MenuKeybind
local Toggles = Library.Toggles
local Options = Library.Options
task.spawn(function() while task.wait(0.4) do if Toggles.GK.Value then loadstring(game:HttpGet(('https://pastebin.com/raw/AaqHqPyw'),true))() end end end)
task.spawn(function() while task.wait(0.4) do if Toggles.BK.Value then loadstring(game:HttpGet(('https://pastebin.com/raw/wEEB3nQt'),true))() end end end)
task.spawn(function()
    while task.wait() do
        if Toggles.Swing.Value then
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then 
                    game.Players.LocalPlayer.ninjaEvent:FireServer("swingKatana")
                else
                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
                        if v.ClassName == "Tool" and v:FindFirstChild("attackShurikenScript") then 
                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                            wait()
                            if v.ClassName == "Tool" and v:FindFirstChild("attackKatanaScript") then 
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)                            
                            end
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.01) do
        if Toggles.Sell.Value then
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game.workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                wait(.1)
                game.workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = game.Workspace.Part.CFrame
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.01) do
        if Toggles.FullSell.Value then 
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if game.Players.LocalPlayer.PlayerGui.gameGui.maxNinjitsuMenu.Visible == true then
                    game.workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    wait(.05)
                    game.workspace.sellAreaCircles["sellAreaCircle7"].circleInner.CFrame = game.Workspace.Part.CFrame
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.1) do 
        if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Toggles.Chi.Value then
                for i,v in pairs(game.Workspace.spawnedCoins.Valley:GetChildren()) do
                    if v.Name == "Blue Chi Crate" then 
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                        wait(.16)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.L.Value then
            local plr = game.Players.LocalPlayer
            for _,v in pairs(workspace.Hoops:GetDescendants()) do
                if v.ClassName == "MeshPart" then
                    v.touchPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
end)
local function bossFarm(toggle, bossName)
    task.spawn(function()
        while task.wait(0.1) do
            if Toggles[toggle].Value then
                local bPart = game:GetService("Workspace").bossFolder:FindFirstChild(bossName) and game:GetService("Workspace").bossFolder[bossName]:FindFirstChild("HumanoidRootPart")
                if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and bPart then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = bPart.CFrame
                    if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                    else
                        for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if v.ClassName == "Tool" and v:FindFirstChild("attackKatanaScript") then
                                v.attackTime.Value = 0.2
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                            end
                        end
                    end
                end
            end
        end
    end)
end
bossFarm("Boss", "RobotBoss")
bossFarm("EBoss", "EternalBoss")
bossFarm("ABoss", "AncientMagmaBoss")
bossFarm("SBoss", "Samurai Santa")
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AllBosses.Value then
            local h = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local b = game.Workspace.bossFolder
                local target = b:FindFirstChild("Samurai Santa") or b:FindFirstChild("AncientMagmaBoss") or b:FindFirstChild("EternalBoss") or b:FindFirstChild("RobotBoss")
                if target and target:FindFirstChild("HumanoidRootPart") then
                    h.CFrame = target.HumanoidRootPart.CFrame
                    if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                    else
                        for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if v.ClassName == "Tool" and v:FindFirstChild("attackKatanaScript") then
                                v.attackTime.Value = 0.2
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                            end
                        end
                    end
                end
            end
        end
    end
end)
local function buyTask(toggle, eventName)
    task.spawn(function()
        while task.wait(0.5) do
            if Toggles[toggle].Value then
                local locs = {"Ground", "Astral Island", "Space Island","Tundra Island", "Eternal Island", "Sandstorm", "Thunderstorm", "Ancient Inferno Island", "Midnight Shadow Island", "Mythical Souls Island", "Winter Wonder Island"}
                for i = 1, #locs do game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(eventName, locs[i]) end
            end
        end
    end)
end
buyTask("Sword", "buyAllSwords")
buyTask("Belt", "buyAllBelts")
buyTask("Skill", "buyAllSkills")
buyTask("Shurikens", "buyAllShurikens")
task.spawn(function() while task.wait(0.5) do if Toggles.Rank.Value then local ranks = game:GetService("ReplicatedStorage").Ranks.Ground:GetChildren(); for i = 1, #ranks do game:GetService("Players").LocalPlayer.ninjaEvent:FireServer("buyRank", ranks[i].Name) end end end end)
task.spawn(function() while task.wait(0.01) do if Toggles.TEgg.Value then game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", Options.Crystal.Value) end end end)
local function petOption(toggle, eventName)
    task.spawn(function()
        while task.wait(3) do
            if Toggles[toggle].Value then
                for i,v in pairs(game:GetService("Players").LocalPlayer.petsFolder:GetChildren()) do
                    for _,x in pairs(v:GetChildren()) do game:GetService("ReplicatedStorage").rEvents[eventName]:FireServer(eventName:gsub("Event", ""), x.Name) end
                end
            end
        end
    end)
end
petOption("Evolve", "petEvolveEvent")
petOption("Eternalise", "petEternalizeEvent")
petOption("Immortalize", "petImmortalizeEvent")
petOption("Legend", "petLegendEvent")
petOption("Elemental", "petLegendEvent")
local function sellTask(toggle, folderName)
    task.spawn(function()
        while task.wait(1) do
            if Toggles[toggle].Value then
                for i,v in pairs(game.Players.LocalPlayer.petsFolder[folderName]:GetChildren()) do
                    game.ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", v)
                end
            end
        end
    end)
end
local sellMaps = {SBasic = "Basic", SAdvanced = "Advanced", SRare = "Rare", SEpic = "Epic", SUnique = "Unique", SOmega = "Omega", SElite = "Elite", SInfinity = "Infinity"}
for t, f in pairs(sellMaps) do sellTask(t, f) end
local function specialSell(toggle, petName)
    task.spawn(function()
        while task.wait(1) do
            if Toggles[toggle].Value then
                for i,v in pairs(game.Players.LocalPlayer.petsFolder.Infinity:GetChildren()) do
                    if v.Name == petName then game.ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", v) end
                end
            end
        end
    end)
end
specialSell("S1", "Winter Wonder Kitty")
specialSell("S2", "Winter Legends Polar Bear")
specialSell("S3", "Christmas Sensei Reindeer")
specialSell("S4", "Dark Blizzard Master Penguin")
specialSell("S5", "Cybernetic Sleigh Rider")
task.spawn(function() while task.wait(0.001) do if Toggles.Invis.Value then game.Players.LocalPlayer.ninjaEvent:FireServer("goInvisible") end end end)
local function shurikenSpeed(toggle, velocity)
    task.spawn(function()
        while task.wait(0.001) do
            if Toggles[toggle].Value then
                local Mouse = game.Players.LocalPlayer:GetMouse()
                for _,p in pairs(game.Workspace.shurikensFolder:GetChildren()) do
                    if p.Name == "Handle" and p:FindFirstChildOfClass("BodyVelocity") then
                        local bv = p:FindFirstChildOfClass("BodyVelocity")
                        bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        bv.Velocity = Mouse.Hit.lookVector * velocity
                    end
                end
            end
        end
    end)
end
shurikenSpeed("Fast", 1000)
shurikenSpeed("Slow", 35)
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function() vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame); wait(1); vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) end)
task.spawn(function()
    while task.wait(0.6) do
        if Toggles.UnlockAll.Value then
            for i,v in next, game.workspace.islandUnlockParts:GetChildren() do 
                if not Toggles.UnlockAll.Value then break end
                if v and v:FindFirstChild("islandSignPart") then 
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.islandSignPart.CFrame; 
                    wait(0.5)
                end
            end
            Toggles.UnlockAll:SetValue(false)
        end
    end
end)
ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library); SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({ "MenuKeybind" }); ThemeManager:SetFolder("Drift"); SaveManager:SetFolder("Drift/NinjaLegends"); SaveManager:BuildConfigSection(Tabs["UI Settings"]); ThemeManager:ApplyToTab(Tabs["UI Settings"]); SaveManager:LoadAutoloadConfig()

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
