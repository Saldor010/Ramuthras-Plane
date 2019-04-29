-- Ramuthra's Plane
-- By Saldor010
local cobalt = dofile("cobalt")
cobalt.ui = dofile("cobalt-ui/init.lua")

local musicInstance = {}
local soundInstance = {}

local args = {...}
local application = "rmplane"
if args[1] then 
	application = "mapmaker"
end

local tick = 0
local tickRate = 0.2
local totalTicks = 0

local lastMouse = {}
lastMouse.x = 0
lastMouse.y = 0
lastMouse.cx = 0
lastMouse.cy = 0

local levels = {
	[1] = "level1.rpmap",
	[2] = "level2.rpmap",
}
local currentLevel = nil

cobalt.state = "intro"
if application == "mapmaker" then
	cobalt.state = "game"
end

local introColor = colors.blue
local introColor2 = colors.white

local currentIntroStory = 1
local introStory = {
	[1] = {
		["text"] = "It was a quiet, peaceful morning when the world changed forever. There were crowds bustling in the market place, farmers tilling their fields, and evil creatures lurking far below the ground away from the good people above. All of the sudden, the sky turned from a pale blue to a dark, demonic red. Thunder cracked in the distance, and the earth shook with the might of a thousand horses. Children began to cry as their mothers hurried them away to safety. Then, the dark presence revealed himself:",
		["color"] = colors.yellow,
		["foreColour"] = colors.black,
	},
	[2] = {
		["text"] = "Ramuthra, a demon of unparalleled power, tearing asunder the fabric of this plane of existence itself as he landed heavily onto the city square. He surrounded himself with an undecipherable black cloud, that seemed to have neither an ending nor a beginning as to where it existed. The only thing visible within the cloud, were his glowing red eyes, of which he had six. He set fire to the city just by gazing upon it.",
		["color"] = colors.orange,
		["foreColour"] = colors.black,
	},
	[3] = {
		["text"] = "Then, as quickly as the chaos had started, it ceased. All noise was removed, all fires put out. The people tried to scream, but found that their voice was missing. The earth stopped shaking, though the cracks in the earth remained. The only being that made noise, was Ramuthra, as he spoke from within the dark cloud.",
		["color"] = colors.gray,
		["foreColour"] = colors.white,
	},
	[4] = {
		["text"] = [["Ahh, this pleases me. But it is not fair, you can do nothing to avoid my wrath." As he spoke these words, a misty blue portal emerged from the charred surface of what was left of the city square. "I present a challenge to you, mortals. This portal will lead you to my plane of existence, containing three crystals that I would like collected. Your people have 24 hours of this planet's time to retrieve the crystals. If you return in time, I will leave this plane and never return. If you do not return in time, I will destroy this plane and everyone inhabiting it."]],
		["color"] = colors.red,
		["foreColour"] = colors.white,
	},
	[5] = {
		["text"] = [[Ramuthra then went silent, and receded deep within his cloud of evil, his eyes submerging themselves within it. Although he removed the spell restricting the noise of the people, no one spoke. The only noise in the city was the soft crying of infants, being held tight by their mothers. Slowly, very slowly, a man stepped forward and approached the shimmering blue portal. Soon, other men followed, realizing the alternative.]],
		["color"] = colors.green,
		["foreColour"] = colors.white,
	},
	[6] = {
		["text"] = [[You were one of these men. As you stepped through the portal, you felt the sensation of being drenched in cold water, then an overwhelming suffocation. Your eyes bulged, your limbs stiffened, then with a sudden rush, you remembered how to breathe. Your lungs filled with crisp, cold air, then exhaled. As you opened your eyes and looked around you saw a door up ahead, and took your first step in RAMUTHRA'S PLANE.]],
		["color"] = colors.blue,
		["foreColour"] = colors.white,
	},
}

local wD,hT = term.getSize()
local introGUI = {}
introGUI.Panel = cobalt.ui.new({x=1,y=1,w=wD,h=hT,backColour=colors.black,state="intro"})
introGUI.SkipIntro = introGUI.Panel:add("button",{w=16,h=1,y=hT-1,wrap="center",text="Skip Intro",foreColour=colors.black,backColour=introColor,state="intro"})
introGUI.Continue = introGUI.Panel:add("button",{w=16,h=1,y=hT-3,wrap="center",text="Continue",foreColour=colors.black,backColour=introColor,state="intro"})
introGUI.SideBarLeft = introGUI.Panel:add("text",{w=2,h=hT,y=0,x=0,text=string.rep("@@ ",200),backColour=colors.black,foreColour=introColor,state="intro"})
introGUI.SideBarRight = introGUI.Panel:add("text",{w=2,h=hT,y=0,x=wD-2,text=string.rep("@@ ",200),backColour=colors.black,foreColour=introColor,state="intro"})
introGUI.Story = introGUI.Panel:add("text",{w=wD-4,h=hT-2,y=2,x=3,text=" ",backColour=colors.black,foreColour=introColor,state="intro"})

introGUI.SkipIntro.onclick = function()
	cobalt.state = "paused"
end

introGUI.Continue.onclick = function()
	introGUI.Story.text = " "
	introGUI.Story.unformatted = " "
	currentIntroStory = currentIntroStory + 1
	if introStory[currentIntroStory] then else
		currentIntroStory = 1
		cobalt.state = "paused"
	end
end

local function refreshIntroGUI()
	introGUI.SkipIntro.backColour = introColor
	introGUI.Continue.backColour = introColor
	introGUI.SkipIntro.foreColour = introColor2
	introGUI.Continue.foreColour = introColor2
	introGUI.SideBarLeft.foreColour = introColor
	introGUI.SideBarRight.foreColour = introColor
	introGUI.Story.foreColour = introColor
end

local rmplane = {}
rmplane.GUI = {}
rmplane.GUI.inspectPanel = cobalt.ui.new({x=37,y=2,w=14,h=12,backColour=colors.black,state="game"})
rmplane.GUI.inspectPanel.nameLabel = rmplane.GUI.inspectPanel:add("text",{x=1,y=1,h=1,w=14,text="",foreColour=colors.white,backColour=colors.black,state="game"})
rmplane.GUI.inspectPanel.descriptionLabel = rmplane.GUI.inspectPanel:add("text",{x=1,y=3,h=4,w=14,text="",foreColour=colors.white,backColour=colors.black,state="game"})

rmplane.GUI.playerPanel = cobalt.ui.new({x=3,y=17,w=30,h=2,backColour = colors.black,state="game"})
rmplane.GUI.playerPanel.carryingText = rmplane.GUI.playerPanel:add("text",{x=1,y=1,h=1,w=30,text="",foreColour=colors.orange,backColour=colors.black,state="game"})

local mapmaker = {}
mapmaker.GUI = {}

mapmaker.GUI.IDType = "tile"
mapmaker.GUI.IDPanel = cobalt.ui.new({x=37,y=2,w=12,h=5,backColour = nil,state="game"})
mapmaker.GUI.IDField = mapmaker.GUI.IDPanel:add("input",{w=12,h=1,y=1,placeholder="Tile ID",state="game"})
mapmaker.GUI.IDTileButton = mapmaker.GUI.IDPanel:add("button",{w=12,h=1,y=2,text="Tile",state="game"})
mapmaker.GUI.IDEntityButton = mapmaker.GUI.IDPanel:add("button",{w=12,h=1,y=3,text="Entity",state="game",state="game"})
mapmaker.GUI.IDMetaDataField = mapmaker.GUI.IDPanel:add("input",{w=12,h=1,y=4,placeholder="Metadata",state="game"})
mapmaker.GUI.IDDeleteButton = mapmaker.GUI.IDPanel:add("button",{w=12,h=1,y=5,text="DELETE",backColour=colors.red,state="game"})

mapmaker.GUI.IDTileButton.onclick = function()
	mapmaker.GUI.IDType = "tile"
	mapmaker.GUI.IDField.placeholder = "Tile ID"
end

mapmaker.GUI.IDEntityButton.onclick = function()
	mapmaker.GUI.IDType = "entity"
	mapmaker.GUI.IDField.placeholder = "Entity ID"
end

mapmaker.GUI.IDDeleteButton.onclick = function()
	mapmaker.GUI.IDType = "delete"
	mapmaker.GUI.IDField.placeholder = "..."
end

mapmaker.GUI.saveButtonPanel = cobalt.ui.new({x=1,y=19,w=6,h=1,state="game"})
mapmaker.GUI.saveButton = mapmaker.GUI.saveButtonPanel:add("button",{text="Save",w=6,h=1,state="game"})

--mapmaker.GUI.savePrompt = cobalt.ui.new({x="25%",y="25%",w="50%",h="50%",backColour = colors.cyan})
--mapmaker.GUI.savePromptText = mapmaker.GUI.savePrompt:add("text",{x="25%",y="25%",w="50%",h="25%"})

--mapmaker.GUI.paintSelection = cobalt.ui.new({w=10,h=15,backColour=nil,foreColour=nil})

mapmaker.paint = {}
mapmaker.paint.Selection = nil

mapmaker.GUI.inspectPanel = cobalt.ui.new({x=37,y=8,w=12,h=3,backColour=colors.black,state="game"})
mapmaker.GUI.inspectPanelName = mapmaker.GUI.inspectPanel:add("text",{x=1,y=1,w=12,h=2,text="",foreColour=colors.white,state="game"})
mapmaker.GUI.inspectPanelMetaData = mapmaker.GUI.inspectPanel:add("text",{x=1,y=3,w=12,h=1,text="",foreColour=colors.white,state="game"})

local mainMenuColor = colors.red

local mainMenuGUI = {}
mainMenuGUI.Panel = cobalt.ui.new({x=1,y=1,w=wD,h=hT,backColour = colors.black,state="paused"})
mainMenuGUI.ExitGameButton = mainMenuGUI.Panel:add("button",{w=16,h=1,y=15,wrap="center",text="Exit Game",backColour=mainMenuColor,state="paused"})
mainMenuGUI.ResumeGameButton = mainMenuGUI.Panel:add("button",{w=16,h=1,y=13,wrap="center",text="Resume Game",backColour=colors.gray,state="paused",enabled=false})
mainMenuGUI.PlayIntroButton = mainMenuGUI.Panel:add("button",{w=16,h=1,y=11,wrap="center",text="Replay Intro",backColour=mainMenuColor,state="paused",enabled=true})
mainMenuGUI.NewGameButton = mainMenuGUI.Panel:add("button",{w=16,h=1,y=9,wrap="center",text="New Game",backColour=mainMenuColor,state="paused"})
mainMenuGUI.Title = mainMenuGUI.Panel:add("text",{w=wD,h=4,y=2,x=1,wrap="center",text="R A M U T H R A ' S",backColour=colors.black,foreColour=mainMenuColor,state="paused"})
mainMenuGUI.Title2 = mainMenuGUI.Panel:add("text",{w=wD,h=4,y=4,x=1,wrap="center",text="P L A N E",backColour=colors.black,foreColour=cobalt.g.lighten(mainMenuColor),state="paused"})

mainMenuGUI.ExitGameButton.onclick = function()
	cobalt.exit()
end

mainMenuGUI.ResumeGameButton.onclick = function()
	cobalt.state = "game"
end

mainMenuGUI.PlayIntroButton.onclick = function()
	introGUI.Story.text = " "
	introGUI.Story.unformatted = " "
	currentIntroStory = 1
	cobalt.state = "intro"
end

local players = {}

local levelGUI = {}
levelGUI.Panel = cobalt.ui.new({x=1,y=1,w=wD,h=hT,backColour = colors.black,state="levels"})
for i=1,3 do
	for j=1,3 do
		local C = colors.red
		if j == 2 then C = colors.green elseif j == 3 then C = colors.blue end
		--[[local a = ((j-1)*3)+i
		if a > players["localPlayer"]["farthestLevelUnlocked"] then
			C = cobalt.g.darken(C)
		end]]--
		levelGUI[i.."/"..j] = levelGUI.Panel:add("button",{w=4,h=2,y=-1+(j*4),x=10+(i*7),text=j.."-"..i,backColour=C,state="levels"})
	end
end
levelGUI.BackButton = levelGUI.Panel:add("button",{w=20,h=1,y=17,wrap="center",text="Back to Main Menu",backColour=mainMenuColor,state="levels"})

levelGUI.BackButton.onclick = function()
	cobalt.state = "paused"
end

mainMenuGUI.NewGameButton.onclick = function()
	cobalt.state = "levels"
	for i=1,3 do
		for j=1,3 do
			local C = colors.red
			if j == 2 then C = colors.green elseif j == 3 then C = colors.blue end
			local a = ((j-1)*3)+i
			if a > players["localPlayer"]["farthestLevelUnlocked"] then
				C = colors.gray
				levelGUI[i.."/"..j]["enabled"] = false
			elseif levels[a] then
				levelGUI[i.."/"..j]["enabled"] = true
			else
				C = colors.lightGray
				levelGUI[i.."/"..j]["enabled"] = false
			end
			--error(levelGUI[i.."/"..j])
			levelGUI[i.."/"..j]["backColour"] = C
		end
	end
end

if application ~= "mapmaker" then
	for k,v in pairs(mapmaker.GUI) do
		if v.x then v.x = -100 end
		if v.y then v.y = -100 end
	end
end

if application ~= "rmplane" then
	for k,v in pairs(rmplane.GUI) do
		if v.x then v.x = -100 end
		if v.y then v.y = -100 end
	end
end

players = {
	["localPlayer"] = {
		["farthestLevelUnlocked"] = 1,
		["finishedLevel"] = false,
		["x"] = 5,
		["y"] = 5,
		["ghost"] = false,
		["frozen"] = false,
		["movedThisTick"] = false,
		["icon"] = {
			["text"] = "@",
			["bg"] = nil,
			["fg"] = colors.white,
		},
		["carrying"] = nil,
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
	["binds"] = {},
}

local camera = {
	["x"] = 0,
	["y"] = 0,
	["xSize"] = 35,
	["ySize"] = 15,
}

local lastTick = os.time()

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

local objectManager = dofile(fs.getDir(shell.getRunningProgram()).."/objectmanager.lua")
tileTypes = objectManager.loadTileTypes()
entityTypes = objectManager.loadEntityTypes()
factions = objectManager.loadFactions()

for k,v in pairs(players) do
	v.faction = factions.champions
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
					local ct = 0
					local function recursion(a,b)
						ct = ct + 1
						--print(ct)
						for k,v in pairs(a) do
							if ct > 400 then
								--print(k)
								--sleep(0.1)
							end
							--sleep()
							if type(v) == "table" then
								b[k] = {}
								recursion(v,b[k])
							else
								b[k] = v
							end
						end
					end
					if whereTo == 0 then
						if tileTypes[tile.type] then
							recursion(tileTypes[tile.type],tile)
							--[[for k,v in pairs(tileTypes[tile.type]) do
								tile[k] = v
							end]]--
						end
						loadedMap["tileMap"][tile.x][tile.y] = tile
					elseif whereTo == 1 then
						if entityTypes[tile.type] then
							recursion(entityTypes[tile.type],tile)
							--[[for k,v in pairs(entityTypes[tile.type]) do
								tile[k] = v
							end]]--
						end
						loadedMap["entityMap"][tile.x][tile.y] = tile
					else
						error("Malformed map file")
					end
				end
			end
		end
		handle.close()
		map = loadedMap
		map["scriptBinds"] = {
			["onPlayerMove"] = {},
			["onUpdate"] = {},
			["onDraw"] = {},
		}
		
		for i=1,map.xSize do
			for j=1,map.ySize do
				if map["tileMap"][i][j] then
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onLoad then
						local localArgs = map["tileMap"][i][j].scripts.onLoad(map["tileMap"][i][j],i,j,{
							["players"] = players,
						},map)
						
						if localArgs and localArgs["object"] then
							for k,v in pairs(localArgs["object"]) do
								map["tileMap"][i][j][k] = v
							end
						end
					end
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onPlayerMove then
						table.insert(map["scriptBinds"]["onPlayerMove"],map["tileMap"][i][j])
					end
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onUpdate then
						table.insert(map["scriptBinds"]["onUpdate"],map["tileMap"][i][j])
					end
					if map["tileMap"][i][j].scripts and map["tileMap"][i][j].scripts.onDraw then
						table.insert(map["scriptBinds"]["onDraw"],map["tileMap"][i][j])
					end
				end
				if map["entityMap"][i][j] then
					if map["entityMap"][i][j].scripts and map["entityMap"][i][j].scripts.onLoad then
						local localArgs = map["entityMap"][i][j].scripts.onLoad(map["entityMap"][i][j],i,j,{
							["players"] = players,
						},map)
						
						if localArgs and localArgs["object"] then
							for k,v in pairs(localArgs["object"]) do
								map["entityMap"][i][j][k] = v
							end
						end
					end
					if map["entityMap"][i][j].scripts and map["entityMap"][i][j].scripts.onPlayerMove then
						table.insert(map["scriptBinds"]["onPlayerMove"],map["entityMap"][i][j])
					end
					if map["entityMap"][i][j].scripts and map["entityMap"][i][j].scripts.onUpdate then
						table.insert(map["scriptBinds"]["onUpdate"],map["entityMap"][i][j])
					end
					if map["entityMap"][i][j].scripts and map["entityMap"][i][j].scripts.onDraw then
						table.insert(map["scriptBinds"]["onDraw"],map["entityMap"][i][j])
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
		error("No such map "..file.." exists")
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

function loadLevel(level)
	if fs.getDir(shell.getRunningProgram()).."/maps/"..levels[level] then
		currentLevel = level
		loadMap(fs.getDir(shell.getRunningProgram()).."/maps/"..levels[level])
		cobalt.state = "game"
		if level >= 7 then mainMenuColor = colors.blue elseif level >= 4 then mainMenuColor = colors.green else mainMenuColor = colors.red end
		mainMenuGUI.ResumeGameButton.backColour = mainMenuColor
		mainMenuGUI.ResumeGameButton.enabled = true
		players["localPlayer"]["finishedLevel"] = false
		players["localPlayer"]["icon"]["text"] = "@"
		players["localPlayer"]["frozen"] = false
		--[[for k,v in pairs(map["entityMap"]) do
			for p,b in pairs(v) do
				if b["name"] == "Spawn" then
					players["localPlayer"]["x"] = k
					players["localPlayer"]["y"] = p
				end
			end
		end]]--
		rmplane.GUI.playerPanel.carryingText.text = ""
	else
		error("Level does not exist! "..level..", "..levels[level])
	end
end

for i=1,3 do
	for j=1,3 do
		levelGUI[i.."/"..j].onclick = function()
			loadLevel(((j-1)*3)+i)
		end
	end
end

local workingPath = nil
if application == "mapmaker" then
	local a = nil
	if fs.exists(fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]) then
		a = fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]
	elseif fs.exists(fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap") then
		a = fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap"
	end
	if a == nil then
		print(fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap")
		local handle = fs.open(fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap","w")
		handle.writeLine(args[1])
		handle.writeLine(255)
		handle.writeLine(255)
		handle.close()
		workingPath = fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap"
		loadMap(fs.getDir(shell.getRunningProgram()).."/maps/"..args[1]..".rpmap")
	else
		workingPath = a
		loadMap(a)
	end
end

mapmaker.GUI.saveButton.onclick = function()
	saveMap(workingPath,args[1],255,255)
end

--loadMap(fs.getDir(shell.getRunningProgram()).."/maps/level1.rpmap")

local function determineVisibility(object1,object2)
	return true
	--[[local x1,y1 = object1.x,object1.y
	local x2,y2 = object2.x,object2.y
	
	return bresenham.los(x1,y1,x2,y2,function(x,y)
		if map.tileMap[x][y]["transparent"] == nil or map.tileMap[x][y]["transparent"] == true then
			return true
		else
			return false
		end]]--
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

local function distanceOK(x1,y1,x2,y2)
	if math.abs(x1-x2) <= 1 and math.abs(y1-y2) <= 1 then
		return true
	else
		return false
	end
end

local currentFPS = 0
function cobalt.update( dt )
	if dt == 0 then dt = 0.01 end
	currentFPS = 1/dt
	tick = tick + dt
	if map and tick >= tickRate then
		tick = 0
		totalTicks = totalTicks + 1
		-- game update
		--[[for k,v in pairs(map.tileMap) do
			for p,b in pairs(v) do
				if b.scripts and b.scripts.onUpdate then
					b.scripts.onUpdate(b,map.tileMap,map.entityMap,players)
				end
			end
		end
		
		for k,v in pairs(map.entityMap) do
			for p,b in pairs(v) do
				if b.scripts and b.scripts.onUpdate then
					b.scripts.onUpdate(b,map.tileMap,map.entityMap,players)
				end
				
				if b.scripts and b.scripts.onSeePlayer and determineVisibility(b,players["localPlayer"]) then
					b.scripts.onSeePlayer()
				end
			end
		end]]--
		--error(#map.scriptBinds.onUpdate)
		for k,v in pairs(map["entityMap"]) do
			for p,b in pairs(v) do
				--[[if b["movedThisTick"] and b["icon"] then
					b["icon"]["text"] = "X"
				elseif b["icon"] then
					b["icon"]["text"] = "O"
				end]]--
				--[[if b["icon"] then
					b["icon"]["text"] = string.char(math.random(20,120))
				end]]--
				b["movedThisTick"] = false
			end
		end
		players["localPlayer"]["movedThisTick"] = false
		
		if map.scriptBinds and map.scriptBinds.onUpdate then
			for k,v in pairs(map.scriptBinds.onUpdate) do
				if v and v.scripts and v.scripts.onUpdate then
					v.scripts.onUpdate(v,map,players)
				end
			end
		end
		
		if players["localPlayer"]["finishedLevel"] == true then
			if players["localPlayer"]["farthestLevelUnlocked"] == currentLevel then
				players["localPlayer"]["farthestLevelUnlocked"] = players["localPlayer"]["farthestLevelUnlocked"] + 1
				if players["localPlayer"]["farthestLevelUnlocked"] > 9 then players["localPlayer"]["farthestLevelUnlocked"] = 9 end
			end
			players["localPlayer"]["icon"]["text"] = ""
			players["localPlayer"]["frozen"] = true
			rmplane.GUI.playerPanel.carryingText.text = "Level complete! Press ENTER to continue or CTRL to leave."
		else
			if players["localPlayer"]["carrying"] then
				rmplane.GUI.playerPanel.carryingText.text = "You're carrying a "..players["localPlayer"]["carrying"]["name"]
				players["localPlayer"]["icon"]["fg"] = colors.orange
			else
				rmplane.GUI.playerPanel.carryingText.text = ""
				if players["localPlayer"]["ghost"] then
					players["localPlayer"]["icon"]["fg"] = colors.purple
				else
					players["localPlayer"]["icon"]["fg"] = colors.white
				end
			end
		end
	end
	
	--[[if musicInstance.playing then
		context:update(0.2)
	else
		musicInstance = context:addInstance(musicTracks.RamuthraLoop,1,true,true)
	end]]
	
	cobalt.ui.update(dt)
end

function cobalt.draw()
	--local epoch = os.time("utc")
	if cobalt.state == "game" then
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
				--cobalt.graphics.print("X - "..v.x,3,1,nil,colors.white)
				--cobalt.graphics.print("Y - "..v.y,3,2,nil,colors.white)
			end
		end
		
		if application == "mapmaker" then
			cobalt.graphics.print("Camera X - "..camera.x,3,17,nil,colors.white)
			cobalt.graphics.print("Camera Y - "..camera.y,3,18,nil,colors.white)
			cobalt.graphics.print("Mouse X - "..lastMouse.x+lastMouse.cx,20,17,nil,colors.white)
			cobalt.graphics.print("Mouse Y - "..lastMouse.y+lastMouse.cy,20,18,nil,colors.white)
		end
		
		if map.scriptBinds and map.scriptBinds.onDraw then
			for k,v in pairs(map.scriptBinds.onDraw) do
				if v and v.scripts and v.scripts.onDraw then
					v.scripts.onDraw(v,map,players)
				end
			end
		end
		
		cobalt.graphics.print("CTRL to pause",38,18,nil,colors.white)
	elseif cobalt.state == "paused" then
	
	elseif cobalt.state == "intro" then
		--[[local ct = 0
		for k,v in pairs(introGUI.Story.text) do
			ct = ct + 1
			term.setCursorPos(2,2+ct)
			term.write(tostring(k)..", "..tostring(v))--,2,2+ct,nil,colors.white)
		end]]--
		--sleep(2)
		--error(introGUI.Story.unformatted)
		introColor = introStory[currentIntroStory]["color"]
		introColor2 = introStory[currentIntroStory]["foreColour"]
		refreshIntroGUI()
		introGUI.Story.text = introGUI.Story.unformatted..string.sub(introStory[currentIntroStory]["text"],#introGUI.Story.unformatted,#introGUI.Story.unformatted+1)
	end
	
	local currentTick = os.time()
	--cobalt.graphics.print(math.floor(1/((currentTick*0.833*60) - (lastTick*0.833*60))).." FPS",2,2,nil,colors.white)
	cobalt.graphics.print(currentFPS.." FPS",2,2,nil,colors.white)
	lastTick = currentTick
	
	cobalt.ui.draw()
	--error(os.time("utc") - epoch)
end

function cobalt.mousepressed( x, y, button )
	lastMouse.x = x
	lastMouse.y = y
	lastMouse.cx = camera.x
	lastMouse.cy = camera.y
	
	if application == "mapmaker" then
		if x > 0 and x <= camera.xSize and y > 0 and y <= camera.ySize then
			if button == 2 then
				if map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
					mapmaker.GUI.inspectPanelName.text = map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name
					mapmaker.GUI.inspectPanelMetaData.text = tostring(map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].metaData) or "0"
				elseif map.tileMap[lastMouse.x+lastMouse.cx] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
					mapmaker.GUI.inspectPanelName.text = map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name
					mapmaker.GUI.inspectPanelMetaData.text = tostring(map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].metaData) or "0"
				end
			elseif button == 1 then
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
							for k,v in pairs(entityTypes[tonumber(mapmaker.GUI.IDField.text)]) do
								object[k] = v
							end
							object.x = lastMouse.x+lastMouse.cx
							object.y = lastMouse.y+lastMouse.cy
							object.type = tonumber(mapmaker.GUI.IDField.text) or 0
							object.metaData = tonumber(mapmaker.GUI.IDMetaDataField.text) or 0
						end
					end
				elseif mapmaker.GUI.IDType == "delete" then
					if map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
						map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] = {}
					elseif map.tileMap[lastMouse.x+lastMouse.cx] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
						map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] = {}
					end
				end
			end
		end
	elseif application == "rmplane" then
		if x > 0 and x <= camera.xSize and y > 0 and y <= camera.ySize then
			if map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
				if button == 2 then
					local object = map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
					rmplane.GUI.inspectPanel.nameLabel.text = object.name
					rmplane.GUI.inspectPanel.descriptionLabel.text = object.description
				elseif button == 1 then
					if not players["localPlayer"]["carrying"] and distanceOK(players["localPlayer"]["x"],players["localPlayer"]["y"],lastMouse.x+lastMouse.cx,lastMouse.y+lastMouse.cy) and map.tileMap[players["localPlayer"]["x"]][players["localPlayer"]["y"]]["itemPlaceable"] then
						players["localPlayer"]["carrying"] = {}
						for k,v in pairs(map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]) do
							players["localPlayer"]["carrying"][k] = v
						end
						map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] = {}
					end
				end
			elseif map.entityMap[lastMouse.x+lastMouse.cx] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name == nil and button == 1 and distanceOK(players["localPlayer"]["x"],players["localPlayer"]["y"],lastMouse.x+lastMouse.cx,lastMouse.y+lastMouse.cy) and players["localPlayer"]["carrying"] and map["tileMap"][lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]["itemPlaceable"] == true then
				for k,v in pairs(players["localPlayer"]["carrying"]) do
					map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy][k] = v
				end
				players["localPlayer"]["carrying"] = nil
				
				if map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]["scripts"] and map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]["scripts"]["onDrop"] then
					local returnData = map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]["scripts"]["onDrop"](map.entityMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy],lastMouse.x+lastMouse.cx,lastMouse.y+lastMouse.cy,map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy],map["tileMap"])
					if returnData["tileMap"] then
						for k,v in pairs(returnData["tileMap"]) do
							map.tileMap[v.x][v.y] = v
						end
					end
					if returnData["entityMap"] then
						for k,v in pairs(returnData["entityMap"]) do
							map.entityMap[v.x][v.y] = v
						end
					end
				end
			elseif map.tileMap[lastMouse.x+lastMouse.cx] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy] and map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy].name then
				if button == 2 then
					local object = map.tileMap[lastMouse.x+lastMouse.cx][lastMouse.y+lastMouse.cy]
					rmplane.GUI.inspectPanel.nameLabel.text = object.name
					rmplane.GUI.inspectPanel.descriptionLabel.text = object.description
				end
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

players["localPlayer"]["move"] = function(self,dX,dY)
	self["x"] = self["x"] + dX
	self["y"] = self["y"] + dY
	moveCamera(player,dX,dY)
end

local function loopObjectsForMoveScript(plr) -- Yup, great function name
	--local epoch = os.time("utc")
	--[[for k,v in pairs(map.tileMap) do
		for p,b in pairs(v) do
			if b.scripts and b.scripts.onPlayerMove then
				local returnData = b.scripts.onPlayerMove(b,map.tileMap,map.entityMap,players,plr)
				if returnData["tileMap"] then
					for k,v in pairs(returnData["tileMap"]) do
						map.tileMap[v.x][v.y] = v
					end
				end
				if returnData["entityMap"] then
					for k,v in pairs(returnData["entityMap"]) do
						map.entityMap[v.x][v.y] = v
					end
				end
			end
		end
	end
	
	for k,v in pairs(map.entityMap) do
		for p,b in pairs(v) do
			if b.scripts and b.scripts.onPlayerMove then
				local returnData = b.scripts.onPlayerMove(b,map.tileMap,map.entityMap,players,plr)
				if returnData["tileMap"] then
					for k,v in pairs(returnData["tileMap"]) do
						map.tileMap[v.x][v.y] = v
					end
				end
				if returnData["entityMap"] then
					for k,v in pairs(returnData["entityMap"]) do
						map.entityMap[v.x][v.y] = v
					end
				end
			end
		end
	end]]--
	for k,v in pairs(map.scriptBinds.onPlayerMove) do
		local returnData = v.scripts.onPlayerMove(v,map.tileMap,map.entityMap,players,plr)
		if returnData["tileMap"] then
			for k,v in pairs(returnData["tileMap"]) do
				map.tileMap[v.x][v.y] = v
			end
		end
		if returnData["entityMap"] then
			for k,v in pairs(returnData["entityMap"]) do
				map.entityMap[v.x][v.y] = v
			end
		end
	end
	--error(os.time("utc") - epoch)
end

function cobalt.keypressed( keycode, key )
	--local epoch = os.time("utc")
	if (key == "left" or key == "up" or key == "right" or key == "down" or key == "a" or key == "w" or key == "d" or key == "s") and cobalt.state == "game" then
		local moveSuccess = false
		local player = players["localPlayer"]
		
		if application == "rmplane" then
			cobalt.update(0)
			local a = 0
			local b = 0
			if key == "left" or key == "a" then
				a = -1
			elseif key == "right" or key == "d" then
				a = 1
			elseif key == "up" or key == "w" then
				b = -1
			elseif key == "down" or key == "s" then
				b = 1
			end
			if findTile(player.x+a,player.y+b) and player.frozen == false then
				local t,e = findTile(player.x+a,player.y+b)
				if ((t.passable or t.type == nil) and e.type == nil) or player.ghost then
					--[[player.x = player.x + a
					player.y = player.y + b
					moveCamera(player,a,b)]]--
					player:move(a,b)
					moveSuccess = true
					loopObjectsForMoveScript(players["localPlayer"])
				end
			end
		else -- MAP MAKER
			if (key == "left" or key == "a") and camera.x > 0 then
				camera.x = camera.x - 1
			elseif (key == "right" or key == "d") and camera.x+camera.xSize < map.xSize then
				camera.x = camera.x + 1
			elseif (key == "up" or key == "w") and camera.y > 0 then
				camera.y = camera.y - 1
			elseif (key == "down" or key == "s") and camera.y+camera.ySize < map.ySize then
				camera.y = camera.y + 1
			end
		end
		
		if moveSuccess == true then
			tick = tickRate -- Force an update when we move
		end
	end
	if (cobalt.state == "paused" or cobalt.state == "game") and currentLevel then
		if key == "leftCtrl" or key == "rightCtrl" then
			if cobalt.state == "game" then cobalt.state = "paused" else cobalt.state = "game" end
		end
	end
	if cobalt.state == "game" and key == "q" then
		players["localPlayer"]["ghost"] = not players["localPlayer"]["ghost"]
		if players["localPlayer"]["ghost"] then
			players["localPlayer"]["icon"]["fg"] = colors.purple
		else
			players["localPlayer"]["icon"]["fg"] = colors.white
		end
	end
	if cobalt.state == "game" and application == "rmplane" and key == "enter" then
		if levels[currentLevel+1] then
			loadLevel(currentLevel+1)
		end
	end
	if key == "z" then
		players["localPlayer"]["farthestLevelUnlocked"] = 9
	end
	cobalt.ui.keypressed(keycode,key)
	--error(os.time("utc"))-- - epoch)
end

function cobalt.keyreleased( keycode, key )
	cobalt.ui.keyreleased(keycode,key)
end

function cobalt.textinput( t )
	cobalt.ui.textinput(t)
end

cobalt.initLoop()