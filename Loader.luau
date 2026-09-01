local URL = "https://raw.githubusercontent.com/cryp1t/Drift/refs/heads/main/Source/"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = tostring(game.PlaceId)

local Source = game:HttpGet(`{URL}{PlaceId}.luau`)
if Source == "404: Not Found" then
    setclipboard("https://dsc.gg/getdrift")
    LocalPlayer:Kick("Game not supported.\nCopied the discord to your clipboard!")
end

local Script = loadstring(Source)
Script()