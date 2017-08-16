-- Ramuthra's Plane
-- By Saldor010
local version = "0.2_0"
local cobalt = dofile("cobalt")
cobalt.ui = dofile("cobalt-ui/init.lua")

local args = {...}
local application = args[1] or "rmplane"

local tick = 0
local tickRate = 0.2

local lastMouse = {}
lastMouse.x = 0
lastMouse.y = 0
lastMouse.cx = 0
lastMouse.cy = 0

local bresenham = dofile(shell.resolve(".").."/bresenham.lua")
local aStar = dofile(shell.resolve(".").."/astar.lua")

local rmplaneGUI = {}
rmplaneGUI.inspectPanel = cobalt.ui.new({x=37,y=2,w=14,h=12,backColour=colors.black})
rmplaneGUI.inspectPanel.nameLabel = rmplaneGUI.inspectPanel:add("text",{x=1,y=1,h=1,w=14,text="",foreColour=colors.white,backColour=colors.black})
rmplaneGUI.inspectPanel.descriptionLabel = rmplaneGUI.inspectPanel:add("text",{x=1,y=3,h=4,w=14,text="",foreColour=colors.white,backColour=colors.black})

local mapmaker = {}
mapmaker.GUI = {}

mapmaker.GUI.IDType = "tile"
mapmaker.GUI.IDPanel = cobalt.ui.new({x=37,y=2,w=12,h=4,backColour = nil})
mapmaker.GUI.IDField = mapmaker.GUI.IDPanel:add("input",{w=12,h=1,y=1,placeholder="Tile ID"})
mapmaker.GUI.IDTileButton = mapmaker.GUI.IDPanel:add("button",{w=12,h=1,y=2,text="Tile"})
mapmaker.GUI.IDEntityButton = mapmaker.GUI.IDPanel:add("button",{w=12,h=1,y=3,text="Entity"})
mapmaker.GUI.IDMetaDataField = mapmaker.GUI.IDPanel:add("input",{w=12,h=1,y=4,placeholder="Metadata"})

mapmaker.GUI.IDTileButton.onclick = function()
	mapmaker.GUI.IDType = "tile"
	mapmaker.GUI.IDField.placeholder = "Tile ID"
end

mapmaker.GUI.IDEntityButton.onclick = function()
	mapmaker.GUI.IDType = "entity"
	mapmaker.GUI.IDField.placeholder = "Entity ID"
end

mapmaker.GUI.saveButtonPanel = cobalt.ui.new({x=1,y=19,w=6,h=1})
mapmaker.GUI.saveButton = mapmaker.GUI.saveButtonPanel:add("button",{text="Save",w=6,h=1})

--mapmaker.GUI.savePrompt = cobalt.ui.new({x="25%",y="25%",w="50%",h="50%",backColour = colors.cyan})
--mapmaker.GUI.savePromptText = mapmaker.GUI.savePrompt:add("text",{x="25%",y="25%",w="50%",h="25%"})

--mapmaker.GUI.paintSelection = cobalt.ui.new({w=10,h=15,backColour=nil,foreColour=nil})

mapmaker.paint = {}
mapmaker.paint.Selection = nil

if application ~= "mapmaker" then
	for k,v in pairs(mapmaker.GUI) do
		if v.x then v.x = -100 end
		if v.y then v.y = -100 end
	end
end

if application ~= "rmplane" then
	for k,v in pairs(rmplaneGUI) do
		if v.x then v.x = -100 end
		if v.y then v.y = -100 end
	end
end

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
	["tileMapMemory"] = {},
	["entityMap"] = {},
	["entityMapMemory"] = {},
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

local objectManager = dofile(shell.resolve(".").."/objectmanager.lua")
tileTypes = objectManager.loadTileTypes()
entityTypes = objectManager.loadEntityTypes()
factions = objectManager.loadFactions()

for k,v in pairs(players) do
	v.faction = factions.champions
end

if application == "mapmaker" then
	
end

local function loadMap(file)
	map.tileMap = {}
	map.entityMap = {}
	if fs.exists(file) then
		local handle = fs.open(file,"r")
		local loadedMap = {["entityMap"]={},["tileMap"]={},["entityMapMemory"] = {},["tileMapMemory"] = {}}
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
						loadedMap["entityMapMemory"][i] = {}
						loadedMap["tileMapMemory"][i] = {}
					end
				elseif ct == 3 then
					loadedMap.ySize = tonumber(line)
					for i=1,loadedMap.xSize do
						for j=1,tonumber(line) do
							loadedMap["entityMap"][i][j] = {}
							loadedMap["tileMap"][i][j] = {}
							loadedMap["entityMapMemory"][i] = {}
							loadedMap["tileMapMemory"][i] = {}
						end
					end
				else
					local tile = {}
					tile.x = tonumber("0x"..string.sub(line,1,2))
					tile.y = tonumber("0x"..string.sub(line,3,4))
					tile.type = tonumber("0x"..string.sub(line,5,7))
					tile.metaData = tonumber("0x"..string.sub(line,8,9))
					local whereTo = tonumber("0x"..string.sub(line,10,10))
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
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onLoad then
						local localArgs = map["tileMap"][i][j].scripts.onLoad(map["tileMap"][i][j],i,j,{
							["players"] = players,
						})
						
						if localArgs and localArgs["object"] then
							for k,v in pairs(localArgs["object"]) do
								map["tileMap"][i][j][k] = v
							end
						end
					end
				end
				if map["entityMap"][i][j] then
					if map["entityMap"][i][j].scripts and map["entityMap"][i][j].scripts.onLoad then
						local localArgs = map["entityMap"][i][j].scripts.onLoad(map["entityMap"][i][j],i,j,{
							["players"] = players,
						})
						
						if localArgs and localArgs["object"] then
							for k,v in pairs(localArgs["object"]) do
								map["entityMap"][i][j][k] = v
							end
						end
					end
				end
			end
		end
		
		local player = players["localPlayer"]
		camera.x = player.x-math.floor(camera.xSize/2)
		camera.y = player.y-math.floor(camera.ySize/2)
		--while camera.x+camera.xSize > map.xSize do camera.x = camera.x - 1 end
		--while camera.y+camera.ySize > map.ySize do camera.y = camera.y - 1 end
		--while camera.x < 0 do camera.x = camera.x + 1 end
		--while camera.y < 0 do camera.y = camera.y + 1 end
	else
		error("No map exists")
	end
end

local function saveMap(filePath,name,mapX,mapY)
	--if fs.exists(filePath) then return false else
		local handle = fs.open(filePath,"w")
		handle.writeLine(name)
		handle.writeLine(mapX)
		handle.writeLine(mapY)
		for k,v in pairs(map.tileMap) do
			for p,b in pairs(v) do
				if b and b.type then
					local hX = string.format("%x",tostring(k)) -- convert the decimal to hex
					local hY = string.format("%x",tostring(p))
					local hType = string.format("%x",tostring(b.type))
					local hMetaData = string.format("%x",tostring(b.metaData))
					
					while string.len(hX) < 2 do hX = "0"..hX end
					while string.len(hY) < 2 do hY = "0"..hY end
					while string.len(hType) < 3 do hType = "0"..hType end
					while string.len(hMetaData) < 2 do hMetaData = "0"..hMetaData end
					
					handle.writeLine(hX..hY..hType..hMetaData..0)
				end
			end
		end
		for k,v in pairs(map.entityMap) do
			for p,b in pairs(v) do
				if b and b.type then
					local hX = string.format("%x",tostring(k)) -- convert the decimal to hex
					local hY = string.format("%x",tostring(p))
					local hType = string.format("%x",tostring(b.type))
					local hMetaData = string.format("%x",tostring(b.metaData))
					
					while string.len(hX) < 2 do hX = "0"..hX end
					while string.len(hY) < 2 do hY = "0"..hY end
					while string.len(hType) < 3 do hType = "0"..hType end
					while string.len(hMetaData) < 2 do hMetaData = "0"..hMetaData end
					
					handle.writeLine(hX..hY..hType..hMetaData..1)
				end
			end
		end
		
		handle.close()
		return true
	--end
end

mapmaker.GUI.saveButton.onclick = function()
	saveMap(fs.getDir(shell.getRunningProgram()).."/maps/savedmap.rpmap","testmap",255,255)
end

loadMap(fs.getDir(shell.getRunningProgram()).."/maps/level1.rpmap")

local function determineVisibility(object1,object2)
	local x1,y1 = object1.x,object1.y
	local x2,y2 = object2.x,object2.y
	
	return bresenham.los(x1,y1,x2,y2,function(x,y)
		if map.tileMap[x][y]["transparent"] == nil or map.tileMap[x][y]["transparent"] == true then
			return true
		else
			return false
		end
	end)
	--[[local a,b,c,A,B,C = 0,0,0,0,0,0
	a = math.abs(object1.x - object2.x)
	b = math.abs(object1.y - object2.y)
	c = math.sqrt((a*a)+(b*b))
	
	A = math.deg(math.asin(a/c))
	B = math.deg(math.asin(b/c))
	C = 90
	
	local lowestX = object1.x
	local lowestY = object1.y
	if object1.x > object2.x then lowestX = object2.x end
	if object1.y > object2.y then lowestY = object2.y end
	
	if a > b then
		for i=a,1,-0.25 do
			local x = a/i
			local y = b/i
			x = math.floor(x + lowestX)
			y = math.floor(y + lowestY)
			
			if map.tileMap[x] and map.tileMap[x][y]  then
				if map.tileMap[x][y].transparent == false then
					return false
				end
			end
			if map.entityMap[x] and map.entityMap[x][y] then
				if map.entityMap[x][y].transparent == false then
					return false
				end
			end
		end
	else
		for i=b,1,-0.25 do
			local x = a/i
			local y = b/i
			x = math.floor(x + lowestX)
			y = math.floor(y + lowestY)
			
			if map.tileMap[x] and map.tileMap[x][y] then
				if map.tileMap[x][y].transparent == false then
					return false
				end
			end
			if map.entityMap[x] and map.entityMap[x][y] then
				if map.tileMap[x][y].transparent == false then
					return false
				end
			end
		end
	end
	
	return true]]--
end

function cobalt.update( dt )
	tick = tick + dt
	if tick >= tickRate then
		tick = 0
		-- game update
		
		for k,v in pairs(map.entityMap) do
			for p,b in pairs(v) do
				if b.scripts and b.scripts.onSeePlayer and determineVisibility(b,players["localPlayer"]) then
					b.scripts.onSeePlayer()
				end
			end
		end
	end
	
	cobalt.ui.update(dt)
end

function cobalt.draw()
	for i=1,19 do
		cobalt.graphics.print(string.rep("/",51),1,i,colors.black,colors.gray)
	end
	for i=camera.x,camera.x+camera.xSize do
		for j=camera.y,camera.y+camera.ySize do
			if map["tileMap"][i] and map["tileMap"][i][j] and map["tileMap"][i][j]["icon"] then
				if not map["tileMap"][i][j].x then map["tileMap"][i][j].x = i end
				if not map["tileMap"][i][j].y then map["tileMap"][i][j].y = j end
				if determineVisibility(players.localPlayer,map["tileMap"][i][j]) or application == "mapmaker" then
					cobalt.graphics.print(map["tileMap"][i][j]["icon"]["text"],i-camera.x,j-camera.y,map["tileMap"][i][j]["icon"]["bg"],map["tileMap"][i][j]["icon"]["fg"])
					
					map["tileMapMemory"][i][j] = {}
					map["tileMapMemory"][i][j].icon = {} 
					map["tileMapMemory"][i][j].icon.text = map["tileMap"][i][j].icon.text
					map["tileMapMemory"][i][j].icon.fg = map["tileMap"][i][j].icon.fg
					map["tileMapMemory"][i][j].icon.bg = map["tileMap"][i][j].icon.bg
				elseif map["tileMapMemory"][i][j] then
					cobalt.graphics.print(map["tileMapMemory"][i][j]["icon"]["text"],i-camera.x,j-camera.y,cobalt.graphics.darken(map["tileMapMemory"][i][j]["icon"]["bg"]),cobalt.graphics.darken(map["tileMapMemory"][i][j]["icon"]["fg"]))
				else
					cobalt.graphics.print("*",i-camera.x,j-camera.y,colors.black,colors.grey)
				end
			elseif map["tileMap"][i] and map["tileMap"][i][j] then
				if not map["tileMap"][i][j].x then map["tileMap"][i][j].x = i end
				if not map["tileMap"][i][j].y then map["tileMap"][i][j].y = j end
				if determineVisibility(players.localPlayer,map["tileMap"][i][j]) or application == "mapmaker" then
					cobalt.graphics.print(" ",i-camera.x,j-camera.y,colors.black,colors.black)
				elseif map["tileMapMemory"][i][j] then
					cobalt.graphics.print(" ",i-camera.x,j-camera.y,colors.black,colors.black)
				else
					cobalt.graphics.print("*",i-camera.x,j-camera.y,colors.black,colors.grey)
				end
			end
			
			if map["entityMap"][i] and map["entityMap"][i][j] and map["entityMap"][i][j]["icon"] then
				if not map["entityMap"][i][j].x then map["entityMap"][i][j].x = i end
				if not map["entityMap"][i][j].y then map["entityMap"][i][j].y = j end
				if determineVisibility(players.localPlayer,map["entityMap"][i][j]) or application == "mapmaker" then
					cobalt.graphics.print(map["entityMap"][i][j]["icon"]["text"],i-camera.x,j-camera.y,map["entityMap"][i][j]["icon"]["bg"],map["entityMap"][i][j]["icon"]["fg"])
					
					map["entityMapMemory"][i][j] = {}
					map["entityMapMemory"][i][j].icon = {} 
					map["entityMapMemory"][i][j].icon.text = map["entityMap"][i][j].icon.text
					map["entityMapMemory"][i][j].icon.fg = map["entityMap"][i][j].icon.fg
					map["entityMapMemory"][i][j].icon.bg = map["entityMap"][i][j].icon.bg
				elseif map["entityMapMemory"][i][j] then
					cobalt.graphics.print(map["entityMapMemory"][i][j]["icon"]["text"],i-camera.x,j-camera.y,cobalt.graphics.darken(map["entityMapMemory"][i][j]["icon"]["bg"]),cobalt.graphics.darken(map["entityMapMemory"][i][j]["icon"]["fg"]))
				else
					cobalt.graphics.print("*",i-camera.x,j-camera.y,colors.black,colors.grey)
				end
			end
		end
	end
	
	if application == "rmplane" then
		for k,v in pairs(players) do
			if v.x >= camera.x and v.x <= camera.x+camera.xSize then
				if v.y >= camera.y and v.y <= camera.y+camera.ySize then
					cobalt.graphics.print(v["icon"]["text"],v.x-camera.x,v.y-camera.y,v["icon"]["bg"],v["icon"]["fg"])
				end
			end
		end
	end
	
	if application == "mapmaker" then
		cobalt.graphics.print("Camera X - "..camera.x,3,17,nil,colors.white)
		cobalt.graphics.print("Camera Y - "..camera.y,3,18,nil,colors.white)
		cobalt.graphics.print("Mouse X - "..lastMouse.x+lastMouse.cx,20,17,nil,colors.white)
		cobalt.graphics.print("Mouse Y - "..lastMouse.y+lastMouse.cy,20,18,nil,colors.white)
	end
	
	cobalt.ui.draw()
end

function cobalt.mousepressed( x, y, button )
	lastMouse.x = x
	lastMouse.y = y
	lastMouse.cx = camera.x
	lastMouse.cy = camera.y
	
	if application == "mapmaker" then
		if x > 0 and x <= camera.xSize and y > 0 and y <= camera.ySize then
			if mapmaker.GUI.IDType == "tile" then
				if tileTypes[tonumber(mapmaker.GUI.IDField.text)] then
					if map.tileMap[lastMouse.x+lastMouse.cx] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] then
						local object = map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
						for k,v in pairs(tileTypes[tonumber(mapmaker.GUI.IDField.text)]) do
							object[k] = v
						end
						object.x = lastMouse.x+lastMouse.cx
						object.y = lastMouse.y+lastMouse.cy
						object.type = tonumber(mapmaker.GUI.IDField.text) or 0
						object.metaData = tonumber(mapmaker.GUI.IDMetaDataField.text) or 0
					end
				end
			elseif mapmaker.GUI.IDType == "entity" then
				if entityTypes[tonumber(mapmaker.GUI.IDField.text)] then
					if map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] then
						local object = map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
						for k,v in pairs(tileTypes[tonumber(mapmaker.GUI.IDField.text)]) do
							object[k] = v
						end
						object.x = lastMouse.x+lastMouse.cx
						object.y = lastMouse.y+lastMouse.cy
						object.type = tonumber(mapmaker.GUI.IDField.text) or 0
						object.metaData = tonumber(mapmaker.GUI.IDMetaDataField.text) or 0
					end
				end
			end
		end
	end
	
	if application == "rmplane" then
		if x > 0 and x <= camera.xSize and y > 0 and y <= camera.ySize then
			if map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
				local object = map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
				rmplaneGUI.inspectPanel.nameLabel.text = object.name
				rmplaneGUI.inspectPanel.descriptionLabel.text = object.description
			elseif map.tileMap[lastMouse.x+lastMouse.cx] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
				local object = map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
				rmplaneGUI.inspectPanel.nameLabel.text = object.name
				rmplaneGUI.inspectPanel.descriptionLabel.text = object.description
			end
		end
	end
	
	cobalt.ui.mousepressed(x,y,button)
end

function cobalt.mousereleased( x, y, button )
	cobalt.ui.mousereleased(x,y,button)
end

local function moveCamera(player,tx,ty)
	local xCenter = camera.x+math.floor(camera.xSize/2)
	local yCenter = camera.y+math.floor(camera.ySize/2)
	
	--[[if player.x - xCenter > 4 and camera.x < map.xSize-camera.xSize then
		camera.x = camera.x + 1
	elseif player.x - xCenter < -4 and camera.x > 0 then
		camera.x = camera.x - 1
	elseif player.y - yCenter > 4 and camera.y < map.ySize-camera.ySize then
		camera.y = camera.y + 1
	elseif player.y - yCenter < -4 and camera.y > 0 then
		camera.y = camera.y - 1
	end]]--
	
	--[[if math.abs(tx) > 0 and (player.x <= math.ceil(camera.xSize/2) or player.x >= map.xSize-camera.xSize) then --and (player.x <= math.floor(camera.xSize/2) or player.x <= math.floor(camera.ySize/2)) then
		return false
	elseif math.abs(ty) > 0 and (player.y <= math.ceil(camera.ySize/2) or player.y >= map.ySize-camera.ySize) then --and (player.x >= map.xSize-camera.xSize or player.y >= map.ySize-camera.ySize) then
		return false
	end]]--
	
	camera.x = camera.x + tx
	camera.y = camera.y + ty
end

function cobalt.keypressed( keycode, key )
	if key == "left" or key == "up" or key == "right" or key == "down" then
		local moveSuccess = false
		local player = players["localPlayer"]
		
		if application == "rmplane" then
			if key == "left" then
				if findTile(player.x-1,player.y) then
					local t,e = findTile(player.x-1,player.y)
					if (t.passable or t.type == nil) and e.type == nil then
						player.x = player.x - 1
						moveCamera(player,-1,0)
						moveSuccess = true
					end
				end
			elseif key == "right" then
				if findTile(player.x+1,player.y) then
					local t,e = findTile(player.x+1,player.y)
					if (t.passable or t.type == nil) and e.type == nil then
						player.x = player.x + 1
						moveCamera(player,1,0)
						moveSuccess = true
					end
				end
			elseif key == "up" then
				if findTile(player.x,player.y-1) then
					local t,e = findTile(player.x,player.y-1)
					if (t.passable or t.type == nil) and e.type == nil then
						player.y = player.y - 1
						moveCamera(player,0,-1)
						moveSuccess = true
					end
				end
			elseif key == "down" then
				if findTile(player.x,player.y+1) then
					local t,e = findTile(player.x,player.y+1)
					if (t.passable or t.type == nil) and e.type == nil then
						player.y = player.y + 1
						moveCamera(player,0,1)
						moveSuccess = true
					end
				end
			end
		else -- MAP MAKER
			if key == "left" and camera.x > 0 then
				camera.x = camera.x - 1
			elseif key == "right" and camera.x+camera.xSize < map.xSize then
				camera.x = camera.x + 1
			elseif key == "up" and camera.y > 0 then
				camera.y = camera.y - 1
			elseif key == "down" and camera.y+camera.ySize < map.ySize then
				camera.y = camera.y + 1
			end
		end
		
		if moveSuccess == true then
			tick = tickRate -- Force an update when we move
		end
	end
	cobalt.ui.keypressed(keycode,key)
end

function cobalt.keyreleased( keycode, key )
	cobalt.ui.keyreleased(keycode,key)
end

function cobalt.textinput( t )
	cobalt.ui.textinput(t)
end

cobalt.initLoop()