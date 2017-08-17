-- Object manager for Ramuthra's Plane
-- By Saldor010

local objectManager = {}

local factions = {
	["champions"] = {
		["name"] = "Champions",
		["allies"] = {},
		["enemies"] = {},
	},
	["monsters"] = {
		["name"] = "Monsters",
		["allies"] = {},
		["enemies"] = {},
	},
}

factions.champions.enemies = factions.monsters
factions.monsters.enemies = factions.champions

local entityBehavior = {}
entityBehavior.noticeEntity = function(self,entity)
	if entity.faction ~= self.faction then
		if self.faction.enemies == entity.faction then
			
		end
	end
end

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

local entityDefault = {
	["name"] = "Default Entity",
	["description"] = "Default Description",
	["icon"] = {
		["text"] = "X",
		["bg"] = colors.red,
		["fg"] = colors.white,
	},
	["health"] = {
		["current"] = 6,
		["max"] = 6,
	},
	["stamina"] = {
		["current"] = 3,
		["max"] = 3,
	},
	["attributes"] = {
		["strength"] = 0,
		["endurance"] = 0,
		["agility"] = 0,
		["perception"] = 0,
		["charisma"] = 0,
		["intelligence"] = 0,
	},
	["skills"] = {
		["twoHanded"] = 0,
		["heavyArmor"] = 0,
		["sneak"] = 0,
		["archery"] = 0,
		["destruction"] = 0,
		["alteration"] = 0,
		["restoration"] = 0,
		["lightArmor"] = 0,
		["handToHand"] = 0,
		["alchemy"] = 0,
		["oneHanded"] = 0,
		["speech"] = 0,
		["conjuration"] = 0,
		["block"] = 0,
		["lockPick"] = 0,
		-- Non player skills
		["bite"] = 0,
		["claw"] = 0,
	},
	["faction"] = nil,
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
			["onLoad"] = function(tile,tx,ty,localArgs)
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
			["onLoad"] = function(tile,tx,ty,localArgs)
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
			["onLoad"] = function(tile,tx,ty,localArgs)
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
	[4] = {
		["name"] = "Locked Gate",
		["description"] = "A tall, wooden gate criss crossed by steel bars",
		["icon"] = {
			["text"] = "=",
			["bg"] = colors.brown,
			["fg"] = colors.grey,
		},
		["passable"] = false,
		["transparent"] = false,
	},
	[5] = {
		["name"] = "Keyhole",
		["description"] = "Looks like you need the right key to unlock this gate.",
		["icon"] = {
			["text"] = "O",
			["bg"] = colors.brown,
			["fg"] = colors.grey,
		},
		["passable"] = false,
		["transparent"] = false,
	},
	[6] = {
		["name"] = "Pressure Pad",
		["description"] = "Standing on it, or placing an object on it, might cause a reaction.",
		["icon"] = {
			["text"] = "+",
			["bg"] = colors.darkGrey,
			["fg"] = colors.grey,
		},
		["passable"] = true,
		["transparent"] = true,
		["scripts"] = {},
		["activated"] = false,
	}
}

local entityTypes = {
	[0] = {
		["name"] = "Rat",
		["description"] = "Big, furry rat with blood red eyes",
		["icon"] = {
			["text"] = "R",
			["bg"] = colors.darkGrey,
			["fg"] = colors.red
		},
		["health"] = {
			["current"] = 6,
			["max"] = 6,
		},
		["stamina"] = {
			["current"] = 3,
			["max"] = 3,
		},
		["skills"] = {
			["bite"] = 10,
			["claw"] = 10,
		},
		["attributes"] = {
			["strength"] = 2,
			["endurance"] = 2,
			["agility"] = 2,
			["perception"] = 1,
			["charisma"] = 0,
			["intelligence"] = 0,
		},
		["faction"] = factions.monsters,
		["scripts"] = {
			["onLoad"] = function(object,tx,ty,localArgs)
				local returnData = {
					
				}
				
				if returnData[object.metaData] then
					for k,v in pairs(returnData[object.metaData]) do
						object[k] = v
					end
				end
			end,
			["onSeePlayer"] = function()
			
			end,
		}
	},
	[1] = {
		["name"] = "Key",
		["description"] = "Looks like it belongs to something..",
		["icon"] = {
			["text"] = "K",
			["bg"] = colors.black,
			["fg"] = colors.white,
		},
		["scripts"] = {
		}
	},
	[2] = {
		["name"] = "Rock",
		["description"] = "A large, somewhat circular grey rock.",
		["icon"] = {
			["text"] = "O",
			["bg"] = colors.black,
			["fg"] = colors.grey
		}
	}
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

tileTypes[6]["scripts"]["onUpdate"] = function(object,tileMap,entityMap,players)
	local returnData = {}
	returnData.tileMap = {}
	
	if (entityMap[object.x][object.y] and entityMap[object.x][object.y]["name"]) or (players["localPlayer"]["x"] == object.x and players["localPlayer"]["y"] == object.y)then
		for k,v in pairs(tileMap) do
			for p,b in pairs(v) do
				if (b.type == 4) and b.metaData == object.metaData then
					local returnTile = b
					returnTile["passable"] = true
					returnTile["transparent"] = true
					returnTile["icon"] = {
						["text"] = " ",
						["bg"] = colors.darkGrey,
						["fg"] = colors.brown,
					}
					returnTile["name"] = "Open Gate"
					returnTile["description"] = "A tall, wooden gate criss crossed by steel bars. It appears to be open."
					table.insert(returnData.tileMap,returnTile)
				end
			end
		end
	else
		for k,v in pairs(tileMap) do
			for p,b in pairs(v) do
				if (b.type == 4) and b.metaData == object.metaData then
					local returnTile = b
					returnTile["passable"] = false
					returnTile["transparent"] = false
					returnTile["icon"] = {
						["text"] = "=",
						["bg"] = colors.brown,
						["fg"] = colors.grey,
					}
					returnTile["name"] = "Locked Gate"
					returnTile["description"] = "A tall, wooden gate criss crossed by steel bars."
					table.insert(returnData.tileMap,returnTile)
				end
			end
		end
	end
	 
	 return returnData
end

entityTypes[1]["scripts"]["onDrop"] = function(object,newX,newY,newTile,tileMap)
	local returnData = {}
	returnData.tileMap = {}
	returnData.entityMap = {}
	if newTile.type == 5 and newTile.metaData == object.metaData then
		for k,v in pairs(tileMap) do
			for p,b in pairs(v)	do
				if (b.type == 4 or b.type == 5) and b.metaData == object.metaData then
					local returnTile = b
					returnTile["passable"] = true
					returnTile["transparent"] = true
					returnTile["icon"] = {
						["text"] = " ",
						["bg"] = colors.darkGrey,
						["fg"] = colors.brown,
					}
					returnTile["name"] = "Open Gate"
					returnTile["description"] = "A tall, wooden gate criss crossed by steel bars. It appears to be open."
					table.insert(returnData.tileMap,returnTile)
				end
			end
		end
		table.insert(returnData.entityMap,{["x"] = newX,["y"] = newY})
	end
	return returnData
end

objectManager.loadTileTypes = function()
	return newTileTypes
end

objectManager.loadEntityTypes = function()
	return entityTypes
end

objectManager.loadFactions = function()
	return factions
end

return objectManager