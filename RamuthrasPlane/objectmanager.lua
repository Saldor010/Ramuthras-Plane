-- Object manager for Ramuthra's Plane
-- By Saldor010

local objectManager = {}

local tileTypes = {
	[0] = {
		["name"] = "Cave Floor",
		["description"] = "A rough floor of slate",
		["icon"] = {
			["text"] = " ",
			["bg"] = colors.black,
			["fg"] = colors.grey,
		},
		["passable"] = true,
		["perceptionRequirement"] = 0,
		["scripts"] = {
			["onload"] = function(tile,tx,ty,localArgs)
				local randT = {
					[1] = "'",
					[2] = ".",
					[3] = '"',
					[4] = ",",
				}
				local rand = math.random(1,4)
				print(rand)
				local text = randT[rand]
				tile.icon["text"] = text
				
				return {["tile"] = {["icon"] = tile.icon}}
			end,
		},
	},
	[1] = {
		["name"] = "Cave Wall",
		["description"] = "A rough wall of slate",
		["icon"] = {
			["text"] = " ",
			["bg"] = colors.gray,
			["fg"] = colors.black,
		},
		["passable"] = false,
		["perceptionRequirement"] = 0,
		["scripts"] = {},
	},
	[2] = {
		["name"] = "Spawn",
		["description"] = "",
		["icon"] = {
			["text"] = " ",
			["bg"] = colors.black,
			["fg"] = colors.black,
		},
		["passable"] = true,
		["perceptionRequirement"] = 99,
		["scripts"] = {
			["onload"] = function(tile,tx,ty,localArgs)
				for k,v in pairs(localArgs["players"]) do
					v.x = tx
					v.y = ty
				end
			end,
		},
	}
}

local entityTypes = {

}

objectManager.loadTileTypes = function()
	return tileTypes
end

objectManager.loadEntityTypes = function()
	return entityTypes
end

return objectManager