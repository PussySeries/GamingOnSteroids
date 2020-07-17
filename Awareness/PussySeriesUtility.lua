-- [ AutoUpdate ]
do
    -- Version from 05.07.2020 --
    local Version = 0.07
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "PussySeriesUtility.lua",
            Url = "https://raw.githubusercontent.com/PussySeries/GamingOnSteroids/master/Awareness/PussySeriesUtility.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "PussySeriesUtility.version",
            Url = "https://raw.githubusercontent.com/PussySeries/GamingOnSteroids/master/Awareness/PussySeriesUtility.version"
        }
    }
    
    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New PussySeries-Utility Version ( 2xF6 )")
        else
            print("PussySeries-Utility loaded")
        end
    
    end
    
    AutoUpdate()

end

local FOWGank = Sprite("PussySprites\\Tracker\\FOWGank.png")
local HPGank = Sprite("PussySprites\\Tracker\\HP.png")
local GankGUI = Sprite("PussySprites\\Tracker\\GankGUI.png")
local GankHP = Sprite("PussySprites\\Tracker\\GankHP.png")
local GankMANA = Sprite("PussySprites\\Tracker\\GankMANA.png")
local ultOFF = Sprite("PussySprites\\Tracker\\ultOFF.png")
local ultON = Sprite("PussySprites\\Tracker\\ultON.png")
local Shadow = Sprite("PussySprites\\Tracker\\Shadow.png")
local nrGUI = Sprite("PussySprites\\Tracker\\nrGUI.png")
local recallGUI = Sprite("PussySprites\\Tracker\\recallGUI.png")

local gankTOP = Sprite("PussySprites\\Tracker\\gankTOP.png")
local gankMID = Sprite("PussySprites\\Tracker\\gankMID.png")
local gankBOT = Sprite("PussySprites\\Tracker\\gankBOT.png")
local gankShadow = Sprite("PussySprites\\Tracker\\gankShadow.png")

local recallMini = Sprite("PussySprites\\Tracker\\recallMini.png",0.5)
local recallMiniC = Sprite("PussySprites\\Tracker\\recallMini.png",0.5)
local miniRed = Sprite("PussySprites\\Tracker\\miniRed.png",0.5)
local miniRedC = Sprite("PussySprites\\Tracker\\miniRed.png",0.5)

local bigRed = Sprite("PussySprites\\Tracker\\miniRed.png")

local champSprite = {}
local champSpriteSmall = {}
local champSpriteMini = {}
local champSpriteMiniC = {}

local midX = Game.Resolution().x/2
local midY = Game.Resolution().y/2

local wards = {}

-------------------------

local minionEXP = {
 ["SRU_OrderMinionSuper"]	= 97,
 ["SRU_OrderMinionSiege"] 	= 93,
 ["SRU_OrderMinionMelee"] 	= 60.45,
 ["SRU_OrderMinionRanged"] 	= 29.76,
 --------------------------------------------
 ["SRU_ChaosMinionSuper"]	= 97,
 ["SRU_ChaosMinionSiege"] 	= 93,
 ["SRU_ChaosMinionMelee"] 	= 60.45,
 ["SRU_ChaosMinionRanged"] 	= 29.76,
}

local expT = {
 ["SRU_OrderMinionSiege"] 	= {[92] = 1, [60] = 2, [40] = 3, [30] = 4, [24] = 5} ,
 ["SRU_OrderMinionMelee"] 	= {[58] = 1, [38] = 2, [25] = 3, [19] = 4, [15] = 5} ,
 ["SRU_OrderMinionRanged"] 	= {[29] = 1, [19] = 2, [13] = 3, [9] = 4, [8] = 5} ,
}

local expMulti = {
 [1] = 1, [2] = 0.652, [3] = 0.4346, [4] = 0.326, [5] = 0.2608, [6] = 0.1337
}
 
local enemies = {}
local Summon = {}
local lpairs = pairs
local mfloor = math.floor 
local TableInsert = table.insert
local TableRemove = table.remove
local mathmin = math.min
local mathceil = math.ceil

local res = Game.Resolution()
local width = res.x

local on_rip_tick = 0
local before_rip_tick = 50000
local ripMinions = {}
local t = {}

local oldExp = {}
local newExp = {}
local eT = {}

local invChamp = {}
local iCanSeeYou = {}
local isRecalling = {}
local OnGainVision = {}

local aBasePos
local eBasePos

local mapID = Game.mapID;
local camps = {}
local TEAM_BLUE = 100;
local TEAM_RED = 200;
local add = 0

local LastWardScan = 0
local GameWardCount = Game.WardCount
local GameWard = Game.Ward
local GameCampCount = Game.CampCount
local GameCamp = Game.Camp
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local DrawRect = Draw.Rect
local DrawCircle = Draw.Circle
local DrawColor = Draw.Color
local DrawText = Draw.Text

local WardColors = {SightWard = DrawColor(255,0,255,0), VisionWard = DrawColor(0xFF,0xAA,0,0xAA), Trinket = DrawColor(0xFF,0xAA,0xAA,0), Farsight = DrawColor(0xFF,00,0xBF,0xFF)}

local mapPos = {
["BOT"] = {Vector(7832,49.4456,1252), Vector(10396,50.1820,1464), Vector(12650,51.5588,2466), Vector(13598,52.5385,4840), Vector(13580,52.3063,7024) },
["MID"] = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0) },
["TOP"] = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0), Vector(0,0,0) },
["BASE"] = {Vector(0,0,0), Vector(0,0,0) }
}

local function IsMoving(unit)
    return unit.pos.x - mfloor(unit.pos.x) ~= 0
end	

local function EnemiesAround(pos, range)
	local x = 0
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero and not hero.dead and hero.isEnemy and hero.pos:DistanceTo(pos) < range and hero.visible then
			x = x + 1
		end
	end
	return x
end

local function EnemiesInvisible(pos, range)
	local x = {}
	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero and hero.valid and hero.isEnemy and hero.pos:DistanceTo(pos) < range and not hero.visible then
			TableInsert(x, hero)
		end
	end
	return x
end

local function IntegerToMinSec(i)
	local m, s = mfloor(i/60), (i%60)
	return (m < 10 and 0 or "")..m..":"..(s < 10 and 0 or "")..s
end


local function InitSprites()
	local _URL = "PussySprites/summons/"
	local _SIZE = 0.35
	
	Summon["SummonerBarrier"] = Sprite(_URL.."Barrier.png", _SIZE)
	Summon["SummonerMana"] = Sprite(_URL.."Clarity.png", _SIZE)
	Summon["SummonerBoost"] = Sprite(_URL.."Barrier.png", _SIZE)
	Summon["SummonerExhaust"] = Sprite(_URL.."Exhaust.png", _SIZE)
	Summon["SummonerFlash"] = Sprite(_URL.."Flash.png", _SIZE)
	Summon["SummonerHaste"] = Sprite(_URL.."Ghost.png", _SIZE)
	Summon["SummonerHeal"] = Sprite(_URL.."Heal.png", _SIZE)
	Summon["SummonerDot"] = Sprite(_URL.."Ignite.png", _SIZE)
	Summon["SummonerSnowball"] = Sprite(_URL.."Mark.png", _SIZE)
	Summon["SummonerSmite"] = Sprite(_URL.."Smite.png", _SIZE)
	Summon["S5_SummonerSmitePlayerGanker"] = Sprite(_URL.."Chilling_Smite.png", _SIZE)
	Summon["S5_SummonerSmiteDuel"] = Sprite(_URL.."Challenging_Smite.png", _SIZE)
	Summon["SummonerTeleport"] = Sprite(_URL.."Teleport.png", _SIZE)
end





class "PussyUtility"

function PussyUtility:__init()
	Callback.Add("Load", function() self:OnLoad() end)
    self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:OnDraw() end)
end

function PussyUtility:LoadMenu()
    self.Menu = MenuElement({type = MENU, id = "PUtility", name = "PussySeries Utility"})
	self.Menu:MenuElement({name = " ", drop = {"Devloped by Pussykate & SeriesDev"}})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.07"}})

	-- Movenment Tracker --	
	self.Menu:MenuElement({id = "circle", name = "Movement Circle", type = MENU })	
		self.Menu.circle:MenuElement({id = "draw", name = "Draw Circle", value = true})
		self.Menu.circle:MenuElement({id = "drawWP", name = "Draw last waypoint", value = true})	
		self.Menu.circle:MenuElement({id = "screen", name = "On Screen", value = true})
		self.Menu.circle:MenuElement({id = "minimap", name = "On Minimap", value = true})
		
	-- Gank Alert --	
    self.Menu:MenuElement({id = "alert", name = "Gank Alert", type = MENU})
		self.Menu.alert:MenuElement({id = "range", name = "Detection Range", value = 2500, min = 1500, max = 4000, step = 10})
		self.Menu.alert:MenuElement({id = "drawGank", name = "Gank Alert", value = true})
		self.Menu.alert:MenuElement({id = "drawGankFOW", name = "FOW Gank Alert", value = true})
	
	-- Recall Tracker --	
	self.Menu:MenuElement({id = "recall", name = "Recall Tracker", type = MENU })	
		self.Menu.recall:MenuElement({id = "drawRecall", name = "Predict Recall Position", value = true })
	
	-- CD Tracker --
	self.Menu:MenuElement({id = "CD", name = "Cooldown Tracker", type = MENU })	 
		self.Menu.CD:MenuElement({id = "use", name = "Show Enemy Spell/Summoner CD", value = true})
		self.Menu.CD:MenuElement({id = "x", name = "Champion Pos: [X]", value = -75, min = -150, max = 150, step = 1})
		self.Menu.CD:MenuElement({id = "y", name = "Champion Pos: [Y]", value = 10, min = -300, max = 150, step = 1})		
	
	-- Jungle Camp Tracker --
	self.Menu:MenuElement({id = "JGLMenu", name = "Jungle Timer", type = MENU })
		self.Menu.JGLMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.JGLMenu:MenuElement({id = "OnScreen", name = "On Screen", type = MENU})
			self.Menu.JGLMenu.OnScreen:MenuElement({id = "Enabled", name = "Enabled", value = true})
			self.Menu.JGLMenu.OnScreen:MenuElement({id = "FontSize", name = "Text Size", value = 22, min = 10, max = 60})
		self.Menu.JGLMenu:MenuElement({id = "OnMinimap", name = "On Minimap", type = MENU})
			self.Menu.JGLMenu.OnMinimap:MenuElement({id = "Enabled", name = "Enabled", value = true})
			self.Menu.JGLMenu.OnMinimap:MenuElement({id = "FontSize", name = "Text Size", value = 10, min = 2, max = 36})
	
	-- Tower Tracker --
	self.Menu:MenuElement({id = "tower", name = "Tower Tracker", type = MENU })
		self.Menu.tower:MenuElement({id = "Tower", name = "Draw Enemy Tower Range", value = false})
		self.Menu.tower:MenuElement({id = "TowerTrans", name = "Tower Range Transparency", value = 80, min = 0, max = 255})							
	
	-- Ward Tracker --
	self.Menu:MenuElement({id = "Warding", name = "Enemy Ward Tracker", type = MENU })
		self.Menu.Warding:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.Warding:MenuElement({id = "EnabledScan", name = "Scan For Wards", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "VisionWard", name = "Control Ward"})
			self.Menu.Warding.VisionWard:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
			self.Menu.Warding.VisionWard:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "Trinket", name = "Warding Totem"})
			self.Menu.Warding.Trinket:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
			self.Menu.Warding.Trinket:MenuElement({id = "TimerDisplay", name = "Show Ward Timer", value = true})
			self.Menu.Warding.Trinket:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
		self.Menu.Warding:MenuElement({type = MENU, id = "Farsight", name = "Farsight Alteration"})
			self.Menu.Warding.Farsight:MenuElement({id = "ScreenDisplay", name = "Show On Screen", value = true})
			self.Menu.Warding.Farsight:MenuElement({id = "VisionDisplay", name = "Show Ward Vision", value = true})
	
	-- Level Spells --
	self.Menu:MenuElement({id = "lvl", name = "Auto Level Spells", type = MENU })		
		self.Menu.lvl:MenuElement({id = "on".. myHero.charName, name = "Enabled", value = true})
		self.Menu.lvl:MenuElement({id = "LvL".. myHero.charName, name = "Auto level start -->", value = 2, min = 1, max = 6, step = 1})
		self.Menu.lvl:MenuElement({id = myHero.charName, name = "Skill Order", value = 1, drop = {"QWE", "WEQ", "EQW", "EWQ", "WQE", "QEW"}})
end		

function PussyUtility:OnDraw()	
	self:DrawJungle()
	self:DrawMovement()
	self:Recall()
	self:DrawGank()
	self:DrawCD()
	self:DrawWard()
end

function PussyUtility:Tick()
	for i = 1, GameHeroCount() do
	local hero = GameHero(i)
		
		--OnGainVision --
		if invChamp[hero.networkID] ~= nil and invChamp[hero.networkID].status == false and hero.visible and not hero.dead then
			if myHero.pos:DistanceTo(hero.pos) <= self.Menu.alert.range:Value() + 100 and GetTickCount()-invChamp[hero.networkID].lastTick > 5000 then
				OnGainVision[hero.networkID].status = true
				OnGainVision[hero.networkID].tick = GetTickCount()
			end
			newExp[hero.networkID] = hero.levelData.exp
			oldExp[hero.networkID] = hero.levelData.exp
		end
		if hero and not hero.dead and hero.isEnemy and hero.visible then
			invChamp[hero.networkID].status = hero.visible
			isRecalling[hero.networkID].spendTime = 0
			newExp[hero.networkID] = hero.levelData.exp
			local hehTicker = GetTickCount()
			if (before_rip_tick + 10000) < hehTicker then
				oldExp[hero.networkID] = hero.levelData.exp
			before_rip_tick = hehTicker
			end
		end
		
		--OnLoseVision --
		if invChamp[hero.networkID] ~= nil and invChamp[hero.networkID].status == true and not hero.visible and not hero.dead then
			invChamp[hero.networkID].lastTick = GetTickCount()
			invChamp[hero.networkID].lastWP = hero.posTo
			invChamp[hero.networkID].lastPos = hero.pos
			invChamp[hero.networkID].status = false
		end
	end
	
	self:AutoLevel()
	self:TowerTracker()
	self:ScanWards()
	self:CheckJungleCamps()	
	
	function OnProcessRecall(unit,recall)
	if isRecalling[unit.networkID] == nil then return end
		if recall.isFinish == false and recall.isStart == true and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil then
			isRecalling[unit.networkID].status = true
			isRecalling[unit.networkID].tick = GetTickCount()
			isRecalling[unit.networkID].proc = recall
		elseif recall.isFinish == true and recall.isStart == false and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil then
			isRecalling[unit.networkID].status = false
			isRecalling[unit.networkID].proc = recall
			isRecalling[unit.networkID].spendTime = 0
		elseif recall.isFinish == false and recall.isStart == false and unit.type == "AIHeroClient" and isRecalling[unit.networkID] ~= nil and isRecalling[unit.networkID].status == true then
			isRecalling[unit.networkID].status = false
			isRecalling[unit.networkID].proc = recall
			if not unit.visible then
				isRecalling[unit.networkID].spendTime = isRecalling[unit.networkID].spendTime + recall.passedTime
			end
		else
			if isRecalling[unit.networkID] ~= nil and isRecalling[unit.networkID].status == false then
				isRecalling[unit.networkID].status = true
				isRecalling[unit.networkID].tick = GetTickCount()
				isRecalling[unit.networkID].proc = recall
			end
		end
		if recall.isFinish == true and recall.isStart == false and unit.type == "AIHeroClient" and invChamp[unit.networkID] ~= nil then
			invChamp[unit.networkID].lastPos = eBasePos
			invChamp[unit.networkID].lastTick = GetTickCount()
		end
	end	
end
	
function PussyUtility:AutoLevel()
	local levelUP = false
	if self.Menu.lvl["on".. myHero.charName]:Value() and not levelUP then
		local actualLevel = myHero.levelData.lvl
		local levelPoints = myHero.levelData.lvlPts

		if actualLevel == 18 and levelPoints == 0 then return end

		if levelPoints > 0 and actualLevel >= self.Menu.lvl["LvL".. myHero.charName]:Value() then
			local mode = self.Menu.lvl[myHero.charName]:Value()
			if mode == 1 then
				skillingOrder = {'Q','W','E','Q','Q','R','Q','W','Q','W','R','W','W','E','E','R','E','E'}
			elseif mode == 2 then
				skillingOrder = {'W','E','Q','W','W','R','W','E','W','E','R','E','E','Q','Q','R','Q','Q'}
			elseif mode == 3 then
				skillingOrder = {'E','Q','W','E','E','R','E','Q','E','Q','R','Q','Q','W','W','R','W','W'}
			elseif mode == 4 then
				skillingOrder = {'E','W','Q','E','E','R','E','W','E','W','R','W','W','Q','Q','R','Q','Q'}
			elseif mode == 5 then
				skillingOrder = {'W','Q','E','W','W','R','W','Q','W','Q','R','Q','Q','E','E','R','E','E'}
			elseif mode == 6 then
				skillingOrder = {'Q','E','W','Q','Q','R','Q','E','Q','E','R','E','E','W','W','R','W','W'}				
			end	

			local QL, WL, EL, RL = 0, 0, 0, myHero.charName == "Karma" and 1 or 0

			for i = 1, actualLevel do
				if skillingOrder[i] == "Q" then 		
					QL = QL + 1
				elseif skillingOrder[i] == "W" then		
					WL = WL + 1
				elseif skillingOrder[i] == "E" then 	
					EL = EL + 1
				elseif skillingOrder[i] == "R" then		
					RL = RL + 1
				end
			end

			local diffR = myHero:GetSpellData(_R).level - RL < 0
			local lowest = 99
			local spell
			local lowHK_Q = myHero:GetSpellData(_Q).level - QL
			local lowHK_W = myHero:GetSpellData(_W).level - WL
			local lowHK_E = myHero:GetSpellData(_E).level - EL

			if lowHK_Q < lowest then
				lowest = lowHK_Q
				spell = HK_Q
			end

			if lowHK_W < lowest then
				lowest = lowHK_W
				spell = HK_W
			end

			if lowHK_E < lowest then
				lowest = lowHK_E
				spell = HK_E
			end

			if diffR then
				spell = HK_R
			end

			if spell then
				levelUP = true

				DelayAction(function()
					Control.KeyDown(HK_LUS)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					Control.KeyUp(HK_LUS)

					DelayAction(function()
						levelUP = false
					end, .25)
				end, 0.7)
			end
		end
	end
end	

function PussyUtility:TowerTracker() 	  
	if self.Menu.tower.Tower:Value() then	
		for i = 1, GameTurretCount() do
			local turret = GameTurret(i)
			if turret.isEnemy and not turret.dead then
				if turret.pos:DistanceTo(myHero.pos) < 1750 then
					DrawCircle(turret.pos, turret.boundingRadius + 750, 3, DrawColor(self.Menu.tower.TowerTrans:Value(),255,0,0))
				end
			end		
		end		
	end
end

function PussyUtility:CheckJungleCamps() 	
	local currentTicks = GetTickCount();
	for i = 1, GameCampCount() do
		local camp = GameCamp(i);
		if mapID == SUMMONERS_RIFT then
			if camp.isCampUp then
				if not camps[camp.chnd] then
					if camp.name == 'monsterCamp_1' then
						camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Blue", camp.isCampUp, DrawColor(255,0,180,255)}
					elseif camp.name == 'monsterCamp_2' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Wolves", camp.isCampUp, DrawColor(255,220,220,220)}
					elseif camp.name == 'monsterCamp_3' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Raptors", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_4' then
						camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Red", camp.isCampUp, DrawColor(255,255,100,100)}
					elseif camp.name == 'monsterCamp_5' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Krugs", camp.isCampUp, DrawColor(255,160,160,160)}
					elseif camp.name == 'monsterCamp_6' then
						camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_BLUE, "Dragon", camp.isCampUp, DrawColor(255,255,170,50)}
					elseif camp.name == 'monsterCamp_7' then
						camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_RED, "Blue", camp.isCampUp, DrawColor(255,0,180,255)}
					elseif camp.name == 'monsterCamp_8' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Wolves", camp.isCampUp, DrawColor(255,220,220,220)}
					elseif camp.name == 'monsterCamp_9' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Raptors", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_10' then
						camps[camp.chnd] = {currentTicks, 300000, camp, TEAM_RED, "Red", camp.isCampUp, DrawColor(255,255,100,100)}
					elseif camp.name == 'monsterCamp_11' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Krugs", camp.isCampUp, DrawColor(255,160,160,160)}
					elseif camp.name == 'monsterCamp_12' then
						camps[camp.chnd] = {currentTicks, 360000, camp, TEAM_RED, "Baron", camp.isCampUp, DrawColor(255,180,50,250)}
					elseif camp.name == 'monsterCamp_13' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_BLUE, "Gromp", camp.isCampUp, DrawColor(255,240,240,0)}
					elseif camp.name == 'monsterCamp_14' then
						camps[camp.chnd] = {currentTicks, 120000, camp, TEAM_RED, "Gromp", camp.isCampUp, DrawColor(255,240,240,0)}
					elseif camp.name == 'monsterCamp_15' then
						camps[camp.chnd] = {currentTicks, 150000, camp, TEAM_BLUE, "Scuttler", camp.isCampUp, DrawColor(255,255,170,50)} 
					elseif camp.name == 'monsterCamp_16' then
						camps[camp.chnd] = {currentTicks, 150000, camp, TEAM_RED, "Scuttler", camp.isCampUp, DrawColor(255,255,170,50)} 

					end
				else -- the camp has been allocated once
					camps[camp.chnd][1] = currentTicks;
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			else --else the camp is not LIVE (up)
				if camps[camp.chnd] then
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			end
		elseif mapID == TWISTED_TREELINE then
			if camp.isCampUp then
				if not camps[camp.chnd] then
					if camp.name == 'monsterCamp_1' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Wraiths", camp.isCampUp, DrawColor(255,255,100,100)}
					elseif camp.name == 'monsterCamp_2' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Golems", camp.isCampUp, DrawColor(255,0,180,255)}
					elseif camp.name == 'monsterCamp_3' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_BLUE, "Wolves", camp.isCampUp, DrawColor(255,220,220,220)}
					elseif camp.name == 'monsterCamp_4' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Wraiths", camp.isCampUp, DrawColor(255,255,100,100)}
					elseif camp.name == 'monsterCamp_5' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Golems", camp.isCampUp, DrawColor(255,0,180,255)}
					elseif camp.name == 'monsterCamp_6' then
						camps[camp.chnd] = {currentTicks, 75000, camp, TEAM_RED, "Wolves", camp.isCampUp, DrawColor(255,220,220,220)}
					elseif camp.name == 'monsterCamp_7' then
						camps[camp.chnd] = {currentTicks, 90000, camp, TEAM_BLUE, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_8' then
						camps[camp.chnd] = {currentTicks, 360000, camp, TEAM_RED, "Vilemaw", camp.isCampUp, DrawColor(255,180,50,250)}
					end
				else -- the camp has been allocated once
					camps[camp.chnd][1] = currentTicks;
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			else --else the camp is not LIVE (up)
				if camps[camp.chnd] then
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			end
		elseif mapID == HOWLING_ABYSS then
			if camp.isCampUp then
				if not camps[camp.chnd] then
					if camp.name == 'monsterCamp_1' then
						camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_2' then
						camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_BLUE, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_3' then
						camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
					elseif camp.name == 'monsterCamp_4' then
						camps[camp.chnd] = {currentTicks, 60000, camp, TEAM_RED, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
					end
				else -- the camp has been allocated once
					camps[camp.chnd][1] = currentTicks;
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			else --else the camp is not LIVE (up)
				if camps[camp.chnd] then
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			end
		elseif mapID == CRYSTAL_SCAR then --definetly not dominion and others
			if camp.isCampUp then
				if not camps[camp.chnd] then
					camps[camp.chnd] = {currentTicks, 31000, camp, TEAM_RED, "Health", camp.isCampUp, DrawColor(255,50,255,50)}
				else -- the camp has been allocated once
					camps[camp.chnd][1] = currentTicks;
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			else --else the camp is not LIVE (up)
				if camps[camp.chnd] then
					camps[camp.chnd][6] = camp.isCampUp;
					camps[camp.chnd][3] = camp;
				end
			end
		end
	end	
end

function PussyUtility:DrawJungle()
	if self.Menu.JGLMenu.Enabled:Value() then 
		local currentTicks = GetTickCount();
		for num, camp in lpairs(camps) do
			if camp[6] == true then

			else
				local timepassed = mathmin(currentTicks - camp[1],camp[2])
				local timeleft = mathceil((camp[2] - timepassed) / 1000);
				if self.Menu.JGLMenu.OnScreen.Enabled:Value() then
					DrawText(IntegerToMinSec(timeleft),self.Menu.JGLMenu.OnScreen.FontSize:Value(),camp[3].pos2D.x,camp[3].pos2D.y,camp[7]);
				end
				if self.Menu.JGLMenu.OnMinimap.Enabled:Value() then
					DrawText(IntegerToMinSec(timeleft),self.Menu.JGLMenu.OnMinimap.FontSize:Value(),camp[3].posMM.x-8,camp[3].posMM.y-8,camp[7]);
				end
			end
		end
	end
end	

function PussyUtility:DrawMovement()
	-- CIRCLE
	if (self.Menu.circle.screen:Value() or self.Menu.circle.minimap:Value()) then
		for i,v in lpairs(invChamp) do
			if v.status == false and not v.champ.dead then
				local recallTime = 0
				if isRecalling[v.champ.networkID].status == true then
					recallTime = GetTickCount()-isRecalling[v.champ.networkID].tick
				end
				local timer = (GetTickCount() - v.lastTick - isRecalling[v.champ.networkID].spendTime - recallTime)/1000
				local vec = v.lastPos + (Vector(v.lastPos,myHero.pos)/v.lastPos:DistanceTo(myHero.pos))*v.champ.ms*timer
				if v.champ.ms*timer < 10000 and v.champ.ms*timer > 0 and vec:DistanceTo(v.lastPos) < myHero.pos:DistanceTo(v.lastPos) + 2000 then
					if self.Menu.circle.screen:Value() then
						local d2 = v.lastPos:ToScreen()
						if d2.onScreen then
							bigRed:Draw(d2.x - 25, d2.y - 25)
							champSpriteSmall[v.champ.charName]:Draw(d2.x - 25, d2.y - 25)
						end
						if self.Menu.circle.drawWP:Value() then
							if v.lastPos ~= eBasePos and v.champ.pos:DistanceTo(eBasePos) > 250 then
								local d2_to = v.champ.posTo:ToScreen()
								if d2_to.onScreen or d2.onScreen then
									Draw.Line(d2,d2_to,2 ,DrawColor(255,255,28,28))
								end
								if v.lastPos ~= eBasePos and d2_to.onScreen then
									champSpriteMiniC[v.champ.charName]:Draw(d2_to.x - 12.5, d2_to.y - 12.5)
									miniRedC:Draw(d2_to.x - 12.5, d2_to.y - 12.5)
								end
							end
						end
						if self.Menu.circle.draw:Value() then
							DrawCircle(v.lastPos,v.champ.ms*timer,DrawColor(180,225,0,30))
							DrawRect(vec:To2D().x - 6,vec:To2D().y-3,8*string.len(v.champ.charName),20,DrawColor(200,25,25,25))
							DrawText(v.champ.charName, 14,vec:To2D())
						end
					end
				end
				if v.champ.ms*timer < 10000 and v.champ.ms*timer > 0 then
					if self.Menu.circle.minimap:Value() then
						champSpriteMini[v.champ.charName]:SetColor(DrawColor(240,158,158,158))
						if v.lastPos ~= eBasePos then
							champSpriteMini[v.champ.charName]:Draw(v.champ.posMM.x - 12.5,v.champ.posMM.y - 12)
							miniRed:Draw(v.champ.posMM.x - 12,v.champ.posMM.y - 12)
							if isRecalling[v.champ.networkID].status == true then
								-- Draw.CircleMinimap(v.lastPos,900, 2,DrawColor(255,225,0,10))
								local r = 25/isRecalling[v.champ.networkID].proc.totalTime * (isRecalling[v.champ.networkID].proc.totalTime - (GetTickCount()-isRecalling[v.champ.networkID].tick))
								local recallCut = {x = 0, y = 25, w = 25, h = r }
								recallMini:Draw(recallCut,v.champ.posMM.x - 12,v.champ.posMM.y - 12 + 25)
							end
						end
						if self.Menu.circle.draw:Value() and v.champ.ms*timer > 720 then
							Draw.CircleMinimap(v.lastPos,v.champ.ms*timer, 1,DrawColor(180,225,0,30))
						end
					end
				end
			end
		end
	end
end	

function PussyUtility:Recall()
	if self.Menu.recall.drawRecall:Value() then
		for i,v in lpairs(invChamp) do
			if v.status == false and not v.champ.dead then
				if isRecalling[v.champ.networkID].status == true then
					local recall = isRecalling[v.champ.networkID]
					local spend_to_recall = recall.tick - v.lastTick - 500
					if spend_to_recall < 2000 then
						local recallPos = v.lastPos + (Vector(v.lastPos,v.champ.posTo)/v.lastPos:DistanceTo(v.champ.posTo))*(v.champ.ms*spend_to_recall/1000)
						if recallPos:DistanceTo(v.lastPos) < spend_to_recall*v.champ.ms then
							local d2 = recallPos:ToScreen()
							local b4_d2 = v.lastPos:ToScreen()
							if d2.onScreen or b4_d2.onScreen then
								Draw.Line(d2,b4_d2,4 ,DrawColor(255,0,128,255))
								champSpriteMini[v.champ.charName]:SetColor(DrawColor(255,255,255,255))
								champSpriteMini[v.champ.charName]:Draw(d2.x - 12.5,d2.y - 12.5)
								local r = 25/isRecalling[v.champ.networkID].proc.totalTime * (isRecalling[v.champ.networkID].proc.totalTime - (GetTickCount()-isRecalling[v.champ.networkID].tick))
								local recallCut = {x = 0, y = 25, w = 25, h = r }
								recallMiniC:Draw(recallCut,d2.x - 12.5,d2.y - 12.5 + 25)
							end
						end
					end
				end
			end
		end
	end
end

function PussyUtility:CleanWards()
	for i = 1, #wards do
		local ward = wards[i]
		local life = 0
		if ward and ward.expire then
			life = ward.expire - Game.Timer()
		end
		if life <= 0 or ward.object == nil or ward.object.health <= 0 then
			TableRemove(wards, i)
			--print("Removed")
		end
	end
end	

function PussyUtility:ScanWards()
	if self.Menu.Warding.EnabledScan:Value() then
		self:CleanWards()
		if Game.Timer() - self.LastWardScan > 0.9 then
			--print("Scanning")
			for i = 1, GameWardCount() do
				local ward = GameWard(i)
				local NewWard = true
				for i = 1, #wards do
					--print(wards[i].networkID)
					if wards[i].networkID == ward.networkID then
						NewWard = false
					end
				end
				if NewWard then 
					local wardExpire
					if ward.valid and ward.isEnemy then
						for i = 1, ward.buffCount do
							local buff = ward:GetBuff(i);
							if (buff.count > 0) and (buff.expireTime > buff.startTime) then 
								wardExpire = buff.expireTime
							end
						end
						local wardType = ward.maxHealth == 4 and "VisionWard" or ward.maxHealth == 3 and (ward.maxMana == 150 and "SightWard" or "Trinket") or ward.maxHealth == 1 and "Farsight" or "WTFISTHISWARD"
						if wardExpire then
							TableInsert(wards, 1, {object = ward, expire = wardExpire, type = wardType, networkID = ward.networkID})
						end 
					end
				end
			end
			self.LastWardScan = Game.Timer()
		end
	end	
end

function PussyUtility:DrawWard()
	if self.Menu.Warding.Enabled:Value() then
		for i = 1, #wards do
			local wardSlot = wards[i]
			local ward = wardSlot.object
			local type = wardSlot.type
			local life = wardSlot.expire - Game.Timer()
			if ward.pos2D.onScreen then
				if self.Menu.Warding[type].ScreenDisplay:Value() then
					DrawCircle(ward.pos,70,3,WardColors[type]);
				end
				if self.Menu.Warding["Farsight"].VisionDisplay:Value() and ward.charName == "BlueTrinket" then
					DrawCircle(ward.pos,500,3,WardColors[type]);
				end	
				if self.Menu.Warding["VisionWard"].VisionDisplay:Value() and ward.charName == "JammerDevice" then
					DrawCircle(ward.pos,900,3,WardColors[type]);
				end	
				if self.Menu.Warding["Trinket"].VisionDisplay:Value() and ward.charName == "YellowTrinket" then
					DrawCircle(ward.pos,900,3,WardColors[type]);
				end			

				if self.Menu.Warding[type].TimerDisplay and self.Menu.Warding[type].TimerDisplay:Value() then
					DrawText(IntegerToMinSec(mathceil(life)),16,ward.pos2D.x,ward.pos2D.y-14,WardColors[type]);
				end
			end
		end
	end	
end	

function PussyUtility:DrawGank()
	if self.Menu.alert.drawGank:Value() and not myHero.dead then 
		local drawIT = false
		local nDraws = -1
		for i,v in lpairs(invChamp) do
		
			if GetTickCount() - OnGainVision[v.champ.networkID].tick > 4000 and OnGainVision[v.champ.networkID].status == true then
				OnGainVision[v.champ.networkID].status = false
			end
			-- if OnGainVision[v.champ.networkID].status == true and GetTickCount() - OnGainVision[v.champ.networkID].tick <= 4000 and GetTickCount()-v.lastTick > 5000 and not v.champ.dead then
			if OnGainVision[v.champ.networkID].status == true and not v.champ.dead then
				if v.champ.pos:DistanceTo(myHero.pos) < self.Menu.alert.range:Value() then
					iCanSeeYou[v.champ.networkID].draw = true
					if GetTickCount() - OnGainVision[v.champ.networkID].tick > 3500 then
						OnGainVision[v.champ.networkID].status = false
						iCanSeeYou[v.champ.networkID].draw = false
					end
					drawIT = true
					nDraws = nDraws + 1
					iCanSeeYou[v.champ.networkID].number = nDraws
				end
			end
		end
		
		if drawIT == true then
			gankMID:Draw(midX - 152, midY/3)
			for i,v in lpairs(iCanSeeYou) do
				if v.draw == true then
					gankShadow:Draw(midX - 25 - (50*nDraws/2) + 50*v.number ,midY/3 +1)
					champSpriteSmall[v.champ.charName]:Draw(midX - 25 - (50*nDraws/2) + 50*v.number ,midY/3 +1) -- need some work!!
				end
			end
			gankTOP:Draw(midX - 152, midY/3 - 14)
			gankBOT:Draw(midX - 152, midY/3 + 45)
		end
	end

	if self.Menu.alert.drawGankFOW:Value() then
		for i,v in lpairs(eT) do
			if v.fow > 0 and v.champ.pos2D.onScreen and v.champ.pos:DistanceTo(myHero.pos) < 2500 and v.fow >= EnemiesAround(myHero.pos,2500) and v.champ.visible then
				DrawRect( v.champ.pos2D.x + 30,v.champ.pos2D.y+4, 22, 14, DrawColor(180,1,1,1))
				DrawText("+"..v.fow, 10 , v.champ.pos2D.x + 36,v.champ.pos2D.y+6, DrawColor(250,225,0,30))
				FOWGank:Draw(v.champ.pos2D.x - 36,v.champ.pos2D.y)
				for n,e in lpairs(EnemiesInvisible(v.champ.pos, 1600)) do
					DrawText(e.charName, 10 , v.champ.pos2D.x - 30,v.champ.pos2D.y + 20*n, DrawColor(250,225,0,30))
				end
			end
			if v.fow < EnemiesAround(myHero.pos,2000) and v.champ.visible and v.fow > 0 then
				v.fow = 0
			end
		end
	end
end

function PussyUtility:DrawCD()
	if self.Menu.CD.use:Value() then
		for i = 1, GameHeroCount() do
			local hero = GameHero(i)
			if hero and hero.team ~= myHero.team then	
				local x = width - 101
				local y = 70
				
				-- Offsets Y --
				local offsetY = self.Menu.CD.y:Value()
				local offsetT = offsetY+1
				
				-- Offsets X --
				local offsetQ = self.Menu.CD.x:Value()
				local offsetW = offsetQ + 25
				local offsetE = offsetW + 25
				local offsetR = offsetE + 25
				
				local offsetS = offsetR + 27
				local offsetF = offsetS+ 25
				
				local offsetText = 12
				
				local wight = 24
				local hight = 17
				
				local barPos = hero.pos2D
				local t_wight = 0
							
				local spellQ = hero:GetSpellData(_Q).currentCd
				local spellW = hero:GetSpellData(_W).currentCd
				local spellE = hero:GetSpellData(_E).currentCd
				local spellR = hero:GetSpellData(_R).currentCd
					
				if hero.pos2D.onScreen then
					if hero.visible and hero.dead == false then 					
						DrawRect(barPos.x+offsetQ-2, barPos.y+offsetY-2, 125, 22, DrawColor(200,0,0,0)) -- BackgroundColor
					
						-- Spells --
						if hero:GetSpellData(_Q).level ~= 0 then
							t_wight =Draw.FontRect(mfloor(spellQ),14).x
							if spellQ ~= 0 then
								DrawRect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
								DrawText(mfloor(spellQ), 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
							else
								DrawRect(barPos.x+offsetQ,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
								DrawText("Q", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2),barPos.y+offsetT, DrawColor(200,255,255,255)) 
							end
						else
							t_wight =Draw.FontRect("~",14).x
							DrawRect(barPos.x+offsetQ, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
							DrawText("~", 14, (barPos.x+offsetQ+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						end	
						
						if hero:GetSpellData(_W).level ~= 0 then
							t_wight =Draw.FontRect(mfloor(spellW),14).x
							if spellW ~= 0 then
								DrawRect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
								DrawText(mfloor(spellW), 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
							else
								DrawRect(barPos.x+offsetW,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
								DrawText("W", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255)) 
							end
						else
							t_wight =Draw.FontRect("~",14).x
							DrawRect(barPos.x+offsetW, barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
							DrawText("~", 14, (barPos.x+offsetW+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						end
						
						if hero:GetSpellData(_E).level ~= 0 then
							t_wight =Draw.FontRect(mfloor(spellE),14).x
							if spellE ~= 0 then
								DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
								DrawText(mfloor(spellE), 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
							else
								DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
								DrawText("E", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255)) 
							end
						else
							t_wight =Draw.FontRect("~",14).x
							DrawRect(barPos.x+offsetE,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
							DrawText("~", 14, (barPos.x+offsetE+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						end	
						
						if hero:GetSpellData(_R).level ~= 0 then
							t_wight =Draw.FontRect(mfloor(spellR),14).x
							if spellR ~= 0 then
								DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0))
								DrawText(mfloor(spellR), 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
							else
								DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,0, 153, 35)) 
								DrawText("R", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
							end
						else
							t_wight =Draw.FontRect("~",14).x
							DrawRect(barPos.x+offsetR,  barPos.y+offsetY, wight,hight, DrawColor(200,190,0,0)) 
							DrawText("~", 14, (barPos.x+offsetR+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						end
					
					 -- Summoners --
						local spellOneCd = hero:GetSpellData(SUMMONER_1).currentCd
						if spellOneCd ~= 0 then
							Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
							DrawRect(barPos.x+offsetS-3,  barPos.y+offsetY-3, wight+3,hight+6, DrawColor(150,0,0,0))
							t_wight =Draw.FontRect(mfloor(spellOneCd),14).x
							DrawText(mfloor(spellOneCd), 14, (barPos.x+offsetS+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							Summon[hero:GetSpellData(SUMMONER_1).name]:Draw(barPos.x+offsetS, barPos.y+offsetY-2)
						end
						
						local spellTwoCd = hero:GetSpellData(SUMMONER_2).currentCd
						if spellTwoCd ~= 0 then
							Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
							DrawRect(barPos.x+offsetF-3,  barPos.y+offsetY-3, wight+3,hight+6, DrawColor(150,0,0,0)) 
							t_wight =Draw.FontRect(mfloor(spellTwoCd),14).x
							DrawText(mfloor(spellTwoCd), 14, (barPos.x+offsetF+offsetText)-(t_wight/2), barPos.y+offsetT, DrawColor(200,255,255,255))
						else
							Summon[hero:GetSpellData(SUMMONER_2).name]:Draw(barPos.x+offsetF, barPos.y+offsetY-2)
						end						
					end	
				end
			end
		end
	end	
end

function PussyUtility:OnLoad()	
	if myHero.team == 100 then
		aBasePos = Vector(415,182,415)
		eBasePos = Vector(14302,172,14387.8)
	else
		aBasePos = Vector(14302,172,14387.8)
		eBasePos = Vector(415,182,415)
	end

	DelayAction(function()
		for i = 1, GameHeroCount() do
			local hero = GameHero(i)
			if hero and hero.isEnemy and eT[hero.networkID] == nil then	
				add = add + 1
				champSprite[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1.2)
				champSpriteSmall[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1)
				champSpriteMini[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
				champSpriteMiniC[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
				invChamp[hero.networkID] = {champ = hero, lastTick = GetTickCount(), lastWP = Vector(0,0,0), lastPos = hero.pos or eBasePos, where = "will be added.", status = hero.visible, n = add}
				iCanSeeYou[hero.networkID] = {tick = 0, champ = hero, number = add, draw = false}
				isRecalling[hero.networkID] = {status = false, tick = 0, proc = nil, spendTime = 0}
				OnGainVision[hero.networkID] = {status = not hero.visible, tick = 0}
				oldExp[hero.networkID] = 0
				newExp[hero.networkID] = 0
				TableInsert(enemies, hero)
				eT[hero.networkID] = {champ = hero, fow = 0, saw = 0,}
			end
		end
	end,30)

	for i = 1, GameHeroCount() do
		local hero = GameHero(i)
		if hero and hero.isEnemy then
			add = add + 1
			champSprite[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1.2)
			champSpriteSmall[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", 1)
			champSpriteMini[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
			champSpriteMiniC[hero.charName] = Sprite("PussySprites\\Champions\\"..hero.charName..".png", .5)
			invChamp[hero.networkID] = {champ = hero, lastTick = GetTickCount(), lastWP = Vector(0,0,0), lastPos = hero.pos or eBasePos, where = "will be added.", status = hero.visible, n = add}
			iCanSeeYou[hero.networkID] = {tick = 0, champ = hero, number = add, draw = false}																	
			isRecalling[hero.networkID] = {status = false, tick = 0, proc = nil, spendTime = 0}
			OnGainVision[hero.networkID] = {status = not hero.visible, tick = 0}
			oldExp[hero.networkID] = 0
			newExp[hero.networkID] = 0
			TableInsert(enemies, hero)
			eT[hero.networkID] = {champ = hero, fow = 0, saw = 0,}

		end
	end
	InitSprites()
end	

PussyUtility()
