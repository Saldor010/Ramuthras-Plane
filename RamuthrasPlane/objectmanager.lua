-- Object manager for Ramuthra's Plane
-- By Saldor010

local objectManager = {}

local tileDefault = {
	["name"] = "Default Tile",
	["description"] = "Default Description",
	["icon"] = {
		["text"] = "X",
		["bg"] = colors.red,
		["fg"] = colors.white,
	},
	["passable"] = true,
	["transparent"] = true,
	["perceptionRequirement"] = 0,
	["scripts"] = {},
}

local tileTypes = {
	[0] = {
		["name"] = "Cave Floor",
		["description"] = "A rough floor of slate",
		["icon"] = {
			["text"] = ",",
			["bg"] = colors.black,
			["fg"] = colors.lightGray,
		},
		["scripts"] = {
			["onload"] = function(tile,tx,ty,localArgs)
				local randT = {
					[1] = "'",
					[2] = ".",
					[3] = '"',
					[4] = ",",
				}
				local rand = math.random(1,4)
				local text = randT[rand]
				
				return {["object"] = {["icon"] = {["text"] = text,["bg"] = colors.black,["fg"] = colors.lightGray}}}
			end,
		},
	},
	[1] = {
		["name"] = "Cave Wall",
		["description"] = "A rough wall of slate",
		["icon"] = {
			["text"] = " ",
			["bg"] = colors.lightGray,
			["fg"] = colors.black,
		},
		["passable"] = false,
		["transparent"] = false,
		["scripts"] = {},
	},
	[2] = {
		["name"] = "Spawn",
		["description"] = "",
		["icon"] = {
			["text"] = "X",
			["bg"] = colors.red,
			["fg"] = colors.white,
		},
		["passable"] = true,
		["transparent"] = true,
		["perceptionRequirement"] = 99,
		["scripts"] = {
			["onload"] = function(tile,tx,ty,localArgs)
				for k,v in pairs(localArgs["players"]) do
					v.x = tx
					v.y = ty
				end
			end,
		},
	},
	[3] = {
		["name"] = "Wooden Sign",
		["description"] = "",
		["icon"] = {
			["text"] = "&",
			["bg"] = colors.brown,
			["fg"] = colors.white,
		},
		["passable"] = true,
		["transparent"] = true,
		["scripts"] = {
			["onload"] = function(tile,tx,ty,localArgs)
				local returnText = ""
				local returnData = {
					[0] = "Feast prepered!",
					[1] = "Hummans welkome!",
					[2] = "Your a verry special gest!",
				}
				
				if returnData[tile.metaData] then
					returnText = returnData[tile.metaData]
				end
				
				return {["object"] = {["description"] = returnText}}
			end,
		}
	},
}

local entityTypes = {

}

local newTileTypes = {}
for k,v in pairs(tileTypes) do
	newTileTypes[k] = {}
	for p,b in pairs(tileDefault) do
		newTileTypes[k][p] = b
	end
	for p,b in pairs(v) do
		newTileTypes[k][p] = b
	end
end

objectManager.loadTileTypes = function()
	return newTileTypes
end

objectManager.loadEntityTypes = function()
	return entityTypes
end

return objectManager