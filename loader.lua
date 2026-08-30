local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId
local Games = {
    [112490729816320] = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/source/spinasoccercard.lua", -- Spin a Soccer Card
    [3956818381] = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/source/ninja-legends.lua", -- Ninja Legends
    [107095834793267] = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/source/oilempire.lua", -- Oil Empire
    [97598239454123] = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/source/growagarden2.lua", -- Grow a Garden 2
    [13772394625] = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/source/bladeball.lua", -- Blade Ball
}
local scriptUrl = Games[placeId]
if scriptUrl then
    loadstring(game:HttpGet(scriptUrl))()
else
    setclipboard("dsc.gg/getdrift")
    player:Kick("Game not supported.\nDiscord copied to clipboard!")
end
