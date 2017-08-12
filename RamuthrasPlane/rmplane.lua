-- Ramuthra's Plane
-- By Saldor010
local version = "0.1_0"
local cobalt = dofile("cobalt")
cobalt.ui = dofile("cobalt-ui/init.lua")

local tick = 0
local tickRate = 0.2

local players = {
	["localPlayer"] = {
		["x"] = 5,
		["y"] = 5,
		["icon"] = {
			["text"] = "@",
			["bg"] = nil,
			["fg"] = colors.white,
		},
		["attributes"] = {
			["strength"] = 6,
			["endurance"] = 6,
			["agility"] = 6,
			["perception"] = 5,
			["charisma"] = 5,
			["intelligence"] = 5,
		},
		["skills"] = {
			["twoHanded"] = 35,
			["heavyArmor"] = 35,
			["sneak"] = 5,
			["archery"] = 5,
			["destruction"] = 5,
			["alteration"] = 5,
			["restoration"] = 15,
			["lightArmor"] = 15,
			["handToHand"] = 15,
			["alchemy"] = 15,
			["oneHanded"] = 15,
			["speech"] = 15,
			["conjuration"] = 15,
			["block"] = 15,
			["lockPick"] = 15
		},
		["class"] = "Warrior", -- Merely a title, the actual class stats are reflected in the values above and below
		["favoredAttributes"] = {
			["strength"] = true,
			["endurance"] = true,
			["agility"] = true,
		},
		["favoredSkills"] = {
			["twoHanded"] = true,
			["heavyArmor"] = true,
		},
	}
}

local map = {
	["name"] = "",
	["xSize"] = 10,
	["ySize"] = 10,
	["tileMap"] = {},
	["entityMap"] = {},
}

local camera = {
	["x"] = 0,
	["y"] = 0,
	["xSize"] = 35,
	["ySize"] = 15,
}

local function findTile(x,y)
	local tile = false
	local entity = false
	if map["tileMap"][x] and map["tileMap"][x][y] then
		tile = map["tileMap"][x][y]
	end
	if map["entityMap"][x] and map["entityMap"][x][y] then
		entity = map["entityMap"][x][y]
	end
	return tile,entity
end

local tileTypes = {
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
			["onload"] = function(tile,tx,ty)
				for k,v in pairs(players) do
					v.x = tx
					v.y = ty
				end
			end,
		},
	}
}

local entityTypes = {

}

local function loadMap(file)
	map.tileMap = {}
	map.entityMap = {}
	if fs.exists(file) then
		local handle = fs.open(file,"r")
		local loadedMap = {["entityMap"]={},["tileMap"]={}}
		local ct = 0
		while true do
			local line = handle.readLine()
			if not line then break else 
				ct = ct + 1
				if ct == 1 then
					loadedMap.name = line
				elseif ct == 2 then
					loadedMap.xSize = tonumber(line)
					for i=1,tonumber(line) do
						loadedMap["entityMap"][i] = {}
						loadedMap["tileMap"][i] = {}
					end
				elseif ct == 3 then
					loadedMap.ySize = tonumber(line)
					for i=1,loadedMap.xSize do
						for j=1,tonumber(line) do
							loadedMap["entityMap"][i][j] = {}
							loadedMap["tileMap"][i][j] = {}
						end
					end
				else
					local tile = {}
					tile.x = tonumber("0x"..string.sub(line,1,2))
					tile.y = tonumber("0x"..string.sub(line,3,4))
					tile.type = tonumber("0x"..string.sub(line,5,7))
					local whereTo = tonumber("0x"..string.sub(line,8,8))
					if whereTo == 0 then
						if tileTypes[tile.type] then
							for k,v in pairs(tileTypes[tile.type]) do
								tile[k] = v
							end
						end
						loadedMap["tileMap"][tile.x][tile.y] = tile
					elseif whereTo == 1 then
						if entityTypes[tile.type] then
							for k,v in pairs(entityTypes[tile.type]) do
								tile[k] = v
							end
						end
						loadedMap["entityMap"][tile.x][tile.y] = tile
					else
						error("Malformed map file")
					end
				end
			end
		end
		map = loadedMap
		
		for i=1,map.xSize do
			for j=1,map.ySize do
				if map["tileMap"][i][j] then
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onload then
						map["tileMap"][i][j].scripts.onload(map["tileMap"][i][j],i,j)
					end
				end
			end
		end
		local player = players["localPlayer"]
		camera.x = player.x
		camera.y = player.y
		while camera.x+camera.xSize > map.xSize do camera.x = camera.x - 1 end
		while camera.y+camera.ySize > map.ySize do camera.y = camera.y - 1 end
	else
		error("No map exists")
	end
end

loadMap(fs.getDir(shell.getRunningProgram()).."/maps/level1.rpmap")

function cobalt.update( dt )
	tick = tick + dt
	if tick >= tickRate then
		tick = 0
		-- game update
		
	end
end

function cobalt.draw()
	for i=1,19 do
		cobalt.graphics.print(string.rep("/",51),1,i,colors.black,colors.gray)
	end
	for i=camera.x,camera.x+camera.xSize do
		for j=camera.y,camera.y+camera.ySize do
			if map["tileMap"][i] and map["tileMap"][i][j] and map["tileMap"][i][j]["icon"] then
				cobalt.graphics.print(map["tileMap"][i][j]["icon"]["text"],i-camera.x,j-camera.y,map["tileMap"][i][j]["icon"]["bg"],map["tileMap"][i][j]["icon"]["fg"])
			elseif map["tileMap"][i] and map["tileMap"][i][j] then
				cobalt.graphics.print(" ",i-camera.x,j-camera.y,colors.black,colors.black)
			end
		end
	end
	for k,v in pairs(players) do
		if v.x >= camera.x and v.x <= camera.x+camera.xSize then
			if v.y >= camera.y and v.y <= camera.y+camera.ySize then
				cobalt.graphics.print(v["icon"]["text"],v.x-camera.x,v.y-camera.y,v["icon"]["bg"],v["icon"]["fg"])
			end
		end
	end
end

function cobalt.mousepressed( x, y, button )

end

function cobalt.mousereleased( x, y, button )

end

local function moveCamera(player)
	local xCenter = camera.x+math.floor(camera.xSize/2)
	local yCenter = camera.y+math.floor(camera.ySize/2)
	
	if player.x - xCenter > 4 and camera.x < map.xSize-camera.xSize then
		camera.x = camera.x + 1
	elseif player.x - xCenter < -4 and camera.x > 0 then
		camera.x = camera.x - 1
	elseif player.y - yCenter > 4 and camera.y < map.ySize-camera.ySize then
		camera.y = camera.y + 1
	elseif player.y - yCenter < -4 and camera.y > 0 then
		camera.y = camera.y - 1
	end
end

function cobalt.keypressed( keycode, key )
	if key == "left" or key == "up" or key == "right" or key == "down" then
		local moveSuccess = false
		local player = players["localPlayer"]
		if key == "left" then
			if findTile(player.x-1,player.y) then
				local t,e = findTile(player.x-1,player.y)
				if (t.passable or t.type == nil) and e.type == nil then
					player.x = player.x - 1
					moveCamera(player)
					moveSuccess = true
				end
			end
		elseif key == "right" then
			if findTile(player.x+1,player.y) then
				local t,e = findTile(player.x+1,player.y)
				if (t.passable or t.type == nil) and e.type == nil then
					player.x = player.x + 1
					moveCamera(player)
					moveSuccess = true
				end
			end
		elseif key == "up" then
			if findTile(player.x,player.y-1) then
				local t,e = findTile(player.x,player.y-1)
				if (t.passable or t.type == nil) and e.type == nil then
					player.y = player.y - 1
					moveCamera(player)
					moveSuccess = true
				end
			end
		elseif key == "down" then
			if findTile(player.x,player.y+1) then
				local t,e = findTile(player.x,player.y+1)
				if (t.passable or t.type == nil) and e.type == nil then
					player.y = player.y + 1
					moveCamera(player)
					moveSuccess = true
				end
			end
		end
		
		if moveSuccess == true then
			tick = tickRate -- Force an update when we move
		end
	end
end

function cobalt.keyreleased( keycode, key )

end

function cobalt.textinput( t )

end

cobalt.initLoop()