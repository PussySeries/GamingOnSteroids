local PredLoaded = false
local heroes = false 
local IsLoaded = false
local TEAM_ALLY = myHero.team
local TEAM_ENEMY = 300 - myHero.team
local TEAM_JUNGLE = 300
local GameTimer = Game.Timer
local GameHeroCount = Game.HeroCount
local GameHero = Game.Hero
local GameMinionCount = Game.MinionCount
local GameMinion = Game.Minion
local GameTurretCount = Game.TurretCount
local GameTurret = Game.Turret
local GameIsChatOpen = Game.IsChatOpen
local sqrt = math.sqrt
local MathSqrt = math.sqrt
local MathHuge = math.huge
local TableInsert = table.insert
local TableRemove = table.remove
_G.LATENCY = 0.05

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, GameHeroCount() do
        local unit = GameHero(i)
        if unit.isEnemy then
            TableInsert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

local function CheckLoadedEnemyies()
	local count = 0
	for i, unit in ipairs(GetEnemyHeroes()) do
        if unit and unit.isEnemy then
		count = count + 1
		end
	end
	return count
end
		
local function ConvertToHitChance(menuValue, hitChance)
    return menuValue == 1 and _G.PremiumPrediction.HitChance.High(hitChance)
    or menuValue == 2 and _G.PremiumPrediction.HitChance.VeryHigh(hitChance)
    or _G.PremiumPrediction.HitChance.Immobile(hitChance)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end

local function Ready(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

local function GetMode()   
    if _G.SDK then
        return 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and "Combo"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] and "Harass"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] and "Clear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] and "Clear"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] and "LastHit"
        or 
		_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] and "Flee"
		or nil
    
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetMode()
	end
	return nil	
end

local function GetTarget(range) 	
	if _G.SDK then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
		end
	elseif _G.PremiumOrbwalker then
		return _G.PremiumOrbwalker:GetTarget(range)
	end	
end

local function IsRecalling(unit)
	for i = 1, 63 do
	local buff = unit:GetBuff(i) 
		if buff.count > 0 and buff.name == "recall" and Game.Timer() < buff.expireTime then
			return true
		end
	end 
	return false
end 
	
local function MyHeroNotReady()
    return myHero.dead or GameIsChatOpen() or (_G.JustEvade and _G.JustEvade:Evading()) or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or IsRecalling(myHero)
end

--[[
local currSpell = myHero.activeSpell
if currSpell and currSpell.valid and myHero.isChanneling then
print ("Width:  "..myHero.activeSpell.width)
print ("Speed:  "..myHero.activeSpell.speed)
print ("Delay:  "..myHero.activeSpell.castFrame)
print ("range:  "..myHero.activeSpell.range)
end
]]

Callback.Add("Tick", function() 
	if heroes == false then 
		local EnemyCount = CheckLoadedEnemyies()		
		if EnemyCount < 1 then
			GetEnemyHeroes()
		else
			heroes = true
		end
	else	
		if not IsLoaded then
			_G[myHero.charName]()
			IsLoaded = true
		end	
	end	
end)

local DrawTime = false
Callback.Add("Draw", function() 	
	if heroes == false then
		Draw.Text(myHero.charName.." is searching Enemies !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 255, 0, 0))
	else
		if not DrawTime then
			Draw.Text(myHero.charName.." is Ready !!", 24, myHero.pos2D.x - 50, myHero.pos2D.y + 195, Draw.Color(255, 0, 255, 0))
			DelayAction(function()
			DrawTime = true
			end, 4.0)
		end	
	end
end)
