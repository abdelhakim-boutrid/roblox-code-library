local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- On récupère un DataStore nommé "PlayerData_v1".
local playerStore = DataStoreService:GetDataStore("PlayerData_v1")


local AUTOSAVE_INTERVAL = 60          -- secondes entre chaque sauvegarde auto
local MAX_RETRIES = 3                 -- nombre de tentatives en cas d'échec
local RETRY_DELAY = 2                 -- secondes d'attente entre deux tentatives

-- Valeurs par défaut pour un tout nouveau joueur.
local DEFAULT_DATA = {
	Coins = 0,
	Level = 1,
	Rebirths = 0,
}

-- Table qui garde en mémoire les leaderstats de chaque joueur connecté.
local sessionData = {}


local function getKey(player)
	return "Player_" .. player.UserId
end

local function loadData(player)
	local key = getKey(player)
	local data = nil
	local success = false
	local attempts = 0
	repeat
		attempts += 1
		local ok, result = pcall(function()
			return playerStore:GetAsync(key)
		end)
		if ok then
			success = true
			data = result
		else
			warn(("[DataStore] Échec chargement %s (essai %d) : %s")
				:format(player.Name, attempts, tostring(result)))
			task.wait(RETRY_DELAY)
		end
	until success or attempts >= MAX_RETRIES

	if not success then
		warn(("[DataStore] Chargement définitivement échoué pour %s"):format(player.Name))
		player:Kick("Erreur de chargement des données. Reconnecte-toi dans un instant.")
		return nil
	end

	if data == nil then
		data = {}
		for statName, value in pairs(DEFAULT_DATA) do
			data[statName] = value
		end
	end

	for statName, value in pairs(DEFAULT_DATA) do
		if data[statName] == nil then
			data[statName] = value
		end
	end

	return data
end

local function saveData(player)
	local leaderstats = sessionData[player]
	if not leaderstats then
		return false
	end

	local key = getKey(player)
	local dataToSave = {
		Coins = leaderstats.Coins.Value,
		Level = leaderstats.Level.Value,
		Rebirths = leaderstats.Rebirths.Value,
	}

	local success = false
	local attempts = 0
	repeat
		attempts += 1
		local ok, err = pcall(function()
			playerStore:UpdateAsync(key, function(oldData)
				return dataToSave
			end)
		end)
		if ok then
			success = true
		else
			warn(("[DataStore] Échec sauvegarde %s (essai %d) : %s")
				:format(player.Name, attempts, tostring(err)))
			task.wait(RETRY_DELAY)
		end
	until success or attempts >= MAX_RETRIES

	if success then
		print(("[DataStore] Sauvegarde réussie pour %s"):format(player.Name))
	else
		warn(("[DataStore] Sauvegarde définitivement échouée pour %s"):format(player.Name))
	end

	return success
end


-- ARRIVÉE D'UN JOUEUR
local function onPlayerAdded(player)
	local data = loadData(player)
	if data == nil then
		return
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins
	coins.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = data.Level
	level.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths
	rebirths.Parent = leaderstats

	sessionData[player] = leaderstats
end


-- DÉPART D'UN JOUEUR

local function onPlayerRemoving(player)
	saveData(player)
	sessionData[player] = nil
end


-- CONNEXIONS DES EVENEMENTS

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end


-- SAUVEGARDE AUTOMATIQUE (toutes les 60s)
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for player in pairs(sessionData) do
			task.spawn(saveData, player)
		end
	end
end)


-- FERMETURE DU SERVEUR
game:BindToClose(function()
	if RunService:IsStudio() then
		return
	end
	for player in pairs(sessionData) do
		task.spawn(saveData, player)
	end
	task.wait(3)
end)
