--[[
	 téléporte le joueur qui touche la part "source"
	       vers une autre part nommée "target".

	ce sript doit etre mis dans le fichier "scipt" de l'Objet "source"
]]

local source = script.Parent

local target = game.Workspace.target


source.Touched:Connect(function(hit)
	
	local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")

	
	if hrp then
		-- +5 en hauteur lors du Tp afin devité d'éviter les bug de Fusion avec la map
		hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
	end
end)
