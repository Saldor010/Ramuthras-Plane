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
			["onLoad"] = function(tile,tx,ty,localArgs,map)
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
		["scripts"] = {
			--[[["onLoad"] = function(tile,tx,ty,localArgs,map)
				local randT = {
					[1] = "'",
					[2] = ".",
					[3] = '"',
					[4] = ",",
				}
				local rand = math.random(1,4)
				local text = randT[rand]
				
				return {["object"] = {["icon"] = {["text"] = text,["bg"] = colors.lightGray,["fg"] = colors.black}}}
			end,]]--
		},
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
			["onLoad"] = function(tile,tx,ty,localArgs,map)
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
			["onLoad"] = function(tile,tx,ty,localArgs,map)
				local returnText = ""
				local returnData = {
					[0] = "Congrats!",
					[1] = "You beat the game!",
					[2] = "Not that it's much of an achievement,",
					[3] = "considering the game only has 4 levels.",
					[4] = "Hopefully this will help show the potential",
					[5] = "for this game though, and what kind of",
					[6] = "levels can be made!",
					[7] = "P.S. please vote for me to win CCJam17 .u.",
					
					[8] = "Welcome to the first plane, use left click to pick things up. Solve the following puzzles!",
					[9] = "Congrats, you're almost done! Your job in each level is to reach the exit portal/ exit crystal. Good luck!"
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
		["scripts"] = {},
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
		["scripts"] = {},
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
	},
	[7] = {
		["name"] = "Lever Up",
		["description"] = "A wooden lever imbedded in stone. You might be able to toggle it.",
		["icon"] = {
			["text"] = "\\",
			["bg"] = colors.darkGrey,
			["fg"] = colors.brown,
		},
		["passable"] = false,
		["transparent"] = false,
		["scripts"] = {},
	},
	[8] = {
		["name"] = "Lever Down",
		["description"] = "A wooden lever imbedded in stone. You might be able to toggle it.",
		["icon"] = {
			["text"] = "/",
			["bg"] = colors.darkGrey,
			["fg"] = colors.brown,
		},
		["passable"] = false,
		["transparent"] = false,
		["scripts"] = {},
	},
	[9] = {
		["name"] = "Magical Wall",
		["description"] = "A barrier from floor to ceiling crisscrossed with fast, fiery bands that look painful to touch.",
		["icon"] = {
			["text"] = "#",
			["bg"] = colors.red,
			["fg"] = colors.orange,
		},
		["passable"] = false,
		["transparent"] = false,
		["scripts"] = {},
	},
	[10] = {
		["name"] = "B.Pressure Pad",
		["description"] = "It appears to be an ordinary pressure pad, except it looks like it's connected to a larger circuit.",
		["icon"] = {
			["text"] = "+",
			["bg"] = colors.darkGrey,
			["fg"] = colors.grey,
		},
		["passable"] = true,
		["transparent"] = true,
		["scripts"] = {},
		["activated"] = false,
		["connectedLogic"] = {},
		["signal"] = false,
	},
	[100] = {
		["name"] = "Exit Portal",
		["description"] = "Walk through this portal to finish the level!",
		["icon"] = {
			["text"] = "O",
			["bg"] = colors.green,
			["fg"] = colors.lime,
		},
		["passable"] = true,
		["transparent"] = true,
		["perceptionRequirement"] = 99,
		["scripts"] = {
			["onLoad"] = function(tile,tx,ty,localArgs,map)
				for k,v in pairs(localArgs["players"]) do
					v.x = tx
					v.y = ty
				end
			end,
		},
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

tileTypes[4]["scripts"]["onPlayerMove"] = function(object,tileMap,entityMap,players,playerThatMoved)
	local returnData = {}
	returnData["tileMap"] = {}
	
	if playerThatMoved.y+3 < object.y then
		local returnTile = object
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
	
	return returnData
end

tileTypes[5]["scripts"]["onPlayerMove"] = function(object,tileMap,entityMap,players,playerThatMoved)
	local returnData = {}
	returnData["tileMap"] = {}
	
	if playerThatMoved.y+3 < object.y then
		local returnTile = object
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
	
	return returnData
end

local function pressurePadLoad(object,tx,ty,localArgs,map)
	object["gates"] = {}
	object["magicalWalls"] = {}
	local tileMap = map.tileMap
	for k,v in pairs(tileMap) do
		for p,b in pairs(v) do
			if (b.type == 4) and b.metaData == object.metaData then
				table.insert(object["gates"],b)
			elseif (b.type == 9) and b.metaData == object.metaData then
				table.insert(object["magicalWalls"],b)
			end
			if object["name"] == "B.Pressure Pad" and b.metaData == object.metaData and b["connectedLogic"] then
				table.insert(object["connectedLogic"],b)
			end
		end
	end
end

tileTypes[6]["scripts"]["onLoad"] = function(object,tx,ty,localArgs,map)
	pressurePadLoad(object,tx,ty,localArgs,map)
end

tileTypes[10]["scripts"]["onLoad"] = function(object,tx,ty,localArgs,map)
	pressurePadLoad(object,tx,ty,localArgs,map)
end

local function pressurePadUpdate(object,map,players)
	local returnData = {}
	returnData.tileMap = {}
	local tileMap = map.tileMap
	local entityMap = map.entityMap
	
	local B = true
	if object["connectedLogic"] then
		for k,v in pairs(object["connectedLogic"]) do
			if (v["signal"] == false) or (v["signal"] == nil) then B = false break end
		end
	end
	
	if (entityMap[object.x][object.y] and entityMap[object.x][object.y]["name"]) or (players["localPlayer"]["x"] == object.x and players["localPlayer"]["y"] == object.y) then
		object["signal"] = true
		if B then
			--[[for k,v in pairs(tileMap) do
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
			end]]--
			for p,b in pairs(object["gates"]) do
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
			for p,b in pairs(object["magicalWalls"]) do
				local returnTile = b
				returnTile["passable"] = true
				returnTile["transparent"] = false
				local a = math.random(1,2)
				local bg = colors.pink
				local fg = colors.yellow
				if a == 1 then
					bg = colors.lime
					fg = colors.pink
				elseif a == 2 then
					bg = colors.blue
					fg = colors.pink
				end
				returnTile["icon"] = {
					["text"] = "*",
					["bg"] = bg,
					["fg"] = fg,
				}
				returnTile["name"] = "Magical Dust"
				returnTile["description"] = "Glittering dust covers the floor where the barrier once stood."
				table.insert(returnData.tileMap,returnTile)
			end
		end
	else
		object["signal"] = false
		--[[for k,v in pairs(tileMap) do
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
		end]]--
		for p,b in pairs(object["gates"]) do
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
		for p,b in pairs(object["magicalWalls"]) do
			local returnTile = b
			returnTile["passable"] = false
			returnTile["transparent"] = false
			returnTile["icon"] = {
				["text"] = "#",
				["bg"] = colors.red,
				["fg"] = colors.orange,
			}
			returnTile["name"] = "Magical Wall"
			returnTile["description"] = "A barrier from floor to ceiling crisscrossed with fast, fiery bands that look painful to touch."
			table.insert(returnData.tileMap,returnTile)
		end
	end
	 
	return returnData
end

tileTypes[6]["scripts"]["onUpdate"] = function(object,map,players)
	return pressurePadUpdate(object,map,players)
end

tileTypes[10]["scripts"]["onUpdate"] = function(object,map,players)
	return pressurePadUpdate(object,map,players)
end

tileTypes[7]["scripts"]["onMouseClick"] = function(object,tileMap,entityMap,players,button)
	
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

tileTypes[100]["scripts"]["onDraw"] = function(object,map,players)
	object["icon"]["text"] = string.char(math.random(20,120))
end

tileTypes[100]["scripts"]["onUpdate"] = function(object,map,players)
	local returnData = {}
	returnData.tileMap = {}
	local tileMap = map.tileMap
	local entityMap = map.entityMap
	
	if players["localPlayer"]["x"] == object.x and players["localPlayer"]["y"] == object.y then
		players["localPlayer"]["finishedLevel"] = true
	end
	
	return returnData
end

tileTypes[9]["scripts"]["onDraw"] = function(object,map,players)
	if object["name"] == "Magical Wall" then
		object["icon"]["text"] = string.char(math.random(20,120))
	end
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