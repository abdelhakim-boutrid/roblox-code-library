--[[
	le bute de ce script est de reduire le temp avant de repawn lors de l'élimination dun joueur

  dans la plupart des jeux cest mieux un respawn rapide afin de garantir un gameplay dynamique
]]

local Players = game:GetService("Players")

-- ici on choisis le temp en seconde avant réaparition
Players.RespawnTime = 1
