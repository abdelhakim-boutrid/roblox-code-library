--[[
	  tue instantanément le joueur qui touche la part.
	   Parfait pour la lave, les piques, les zones mortelles d'un obby.
]]


local lava = script.Parent


local function onTouch(hit)
	
	local character = hit.Parent


	local humanoid = character:FindFirstChild("Humanoid")

	
	if humanoid then
	
		humanoid.Health = 0
	end
end

-- On connecte la fonction à l'événement Touched de la lave
lava.Touched:Connect(onTouch)
