local function GetDistanceSqr(p1, p2)
	if not p1 then return MathHuge end
	p2 = p2 or myHero
	local dx = p1.x - p2.x
	local dz = (p1.z or p1.y) - (p2.z or p2.y)
	return dx*dx + dz*dz
end

local function GetDistance(p1, p2)
	p2 = p2 or myHero
	return MathSqrt(GetDistanceSqr(p1, p2))
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	for i = 1, GameHeroCount() do
		local unit = GameHero(i)
		if unit.isAlly and not unit.isMe then
			TableInsert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

local function GetEnemyCount(range, pos)
	local EnemiesAroundUnit = 0
    for i, enemy in ipairs(GetEnemyHeroes()) do
        if enemy and not enemy.dead and IsValid(enemy) then
            if GetDistance(enemy.pos, pos.pos) < range then
                EnemiesAroundUnit = EnemiesAroundUnit + 1
            end
        end
    end
    return EnemiesAroundUnit
end

local function GetAllyCount(range, pos)
	local count = 0
	for i, hero in pairs(GetAllyHeroes()) do
	local Range = range * range
		if hero and GetDistanceSqr(pos.pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end

local function GetMinionCount(range, pos)
    local pos = pos.pos
	local count = 0
	for i = 1,GameMinionCount() do
	local hero = GameMinion(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and hero.dead == false and GetDistanceSqr(pos, hero.pos) < Range then
		count = count + 1
		end
	end
	return count
end





class "Gangplank"

function Gangplank:__init()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

	--//// E-Prediction Data ////--
	EspellData = {speed = MathHuge, range = 1000, delay = 0.25, radius = 325, collision = {nil}, type = "circular"}

	--//// R-Prediction Data ////--
	RspellData = {speed = MathHuge, range = MathHuge, delay = 0.25, radius = 600, collision = {nil}, type = "circular"}

	BarrelCount = 0
	Barrel = { }
	Tick = nil

end

function Gangplank:LoadMenu()                     	
									 -- MainMenu --
	self.Menu = MenuElement({type = MENU, id = "PussySeries".. myHero.charName, name = "Gangplank"})
	self.Menu:MenuElement({name = " ", drop = {"Version 0.01"}})
	
	
									  -- Combo --
	self.Menu:MenuElement({type = MENU, id = "ComboSet", name = "Combo Settings"})
	self.Menu.ComboSet:MenuElement({id = "UseQ", name = "Use [Q] in Combo", value = true})
	self.Menu.ComboSet:MenuElement({id = "UseE", name = "Use [E] in Combo", value = true})
	
			
	
									  -- Harass --
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})		
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use [Q] in Harass", value = true})		
	self.Menu.Harass:MenuElement({id = "UseE", name = "Use [E] in Harass", value = true})
	self.Menu.Harass:MenuElement({id = "UseQ2", name = "Use [Q] Lasthit Minions", value = true})
	self.Menu.Harass:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	
								  -- Lane/JungleClear --
	self.Menu:MenuElement({type = MENU, id = "ClearSet", name = "Clear Settings"})

	--LaneClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "Clear", name = "Clear Mode"})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ", name = "Use [Q]", value = true})
	self.Menu.ClearSet.Clear:MenuElement({id = "UseQ2", name = "Use [Q] only for Lasthit", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "UseE", name = "Use [E]", value = true})	
	self.Menu.ClearSet.Clear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100, identifier = "%"})
	
	--JungleClear Menu
	self.Menu.ClearSet:MenuElement({type = MENU, id = "JClear", name = "JungleClear Mode"})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ", name = "Use [Q]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "UseQ2", name = "Use [Q] only for Lasthit", value = true})	
	self.Menu.ClearSet.JClear:MenuElement({id = "UseE", name = "Use [E]", value = true})
	self.Menu.ClearSet.JClear:MenuElement({id = "Mana", name = "Min Mana", value = 40, min = 0, max = 100})	


	                                 -- KillSteal --
	self.Menu:MenuElement({type = MENU, id = "ks", name = "KillSteal Settings"})
	self.Menu.ks:MenuElement({id = "UseQ", name = "Use [Q] KillSteal", value = true})	
	self.Menu.ks:MenuElement({id = "UseR", name = "Use [R] KillSteal (Single Target Check)", value = false})
			

										-- Misc --
    self.Menu:MenuElement({type = MENU, id = "MiscSet", name = "Misc Settings"})	
			
	--Prediction
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Pred", name = "Prediction Mode"})
	self.Menu.MiscSet.Pred:MenuElement({name = " ", drop = {"After change Prediction Typ press 2xF6"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "Change", name = "Change Prediction Typ", value = 2, drop = {"Premium Prediction", "GGPrediction"}})	
	self.Menu.MiscSet.Pred:MenuElement({id = "PredE", name = "Hitchance[E]", value = 1, drop = {"Normal", "High", "Immobile"}})
	self.Menu.MiscSet.Pred:MenuElement({id = "PredR", name = "Hitchance[R]", value = 1, drop = {"Normal", "High", "Immobile"}})	

	--Auto Barrel Explode 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "AutoQ", name = "Auto Barrel Explode"})
	self.Menu.MiscSet.AutoQ:MenuElement({id = "Enable", name = "Auto [Q] Barrel", value = true})
	
	--Auto W 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "AutoW", name = "Auto W"})
	self.Menu.MiscSet.AutoW:MenuElement({id = "Enable1", name = "Auto [W] if Immobile", value = true})
	self.Menu.MiscSet.AutoW:MenuElement({id = "Enable2", name = "Auto [W] if HP low", value = true})
	self.Menu.MiscSet.AutoW:MenuElement({id = "HP", name = "If HP lower than -->", value = 30, min = 0, max = 100, identifier = "%"})

	--Auto R 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "AutoR", name = "Auto R"})
	self.Menu.MiscSet.AutoR:MenuElement({id = "Enable", name = "Auto [R] if Enemies >= x", value = true})
	self.Menu.MiscSet.AutoR:MenuElement({id = "Count", name = "Minimum Enemies -->", value = 3, min = 1, max = 5})	
 
	--Drawing 
	self.Menu.MiscSet:MenuElement({type = MENU, id = "Drawing", name = "Drawings Mode"})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawQ", name = "Draw [Q] Range", value = false})
	self.Menu.MiscSet.Drawing:MenuElement({id = "DrawE", name = "Draw [E] Range", value = false})
		
end

function Gangplank:Tick()
if IsLoaded and not PredLoaded then
	DelayAction(function()
		if self.Menu.MiscSet.Pred.Change:Value() == 1 then
			require('PremiumPrediction')
		else
			require('GGPrediction')
		end
	end, 0.1)
	PredLoaded = true
end		   

if MyHeroNotReady() then return end
self:AddBarrel()

local target = GetTarget(2000)

local Mode = GetMode()
	if Mode == "Combo" then
		if target and IsValid(target) and GetEnemyCount(1000, target) == 1 and self.Menu.ComboSet.UseQ:Value() and self.Menu.ComboSet.UseE:Value() then
			self:ComboE(target)
			self:CastQ(target)
			if not self.Menu.MiscSet.AutoQ.Enable:Value() then
				self:AutoBarrel()
			end
		elseif target and IsValid(target) and GetEnemyCount(1000, target) >= 2 and self.Menu.ComboSet.UseQ:Value() and self.Menu.ComboSet.UseE:Value() then
			self:ComboE(target)
			if not self.Menu.MiscSet.AutoQ.Enable:Value() then
				self:AutoBarrel()
			end
		end	
	
	elseif Mode == "Harass" then
		if target and IsValid(target) then
			if self.Menu.Harass.UseQ2:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
				self:UseQFarm()
			end
			if self.Menu.Harass.UseQ:Value() and myHero.mana/myHero.maxMana >= self.Menu.Harass.Mana:Value() / 100 then
				self:CastQ(target)
			end
			if self.Menu.Harass.UseE:Value() then
				self:ComboE(target)
				if not self.Menu.MiscSet.AutoQ.Enable:Value() then
					self:AutoBarrel()
				end
			end
		end
		
	elseif Mode == "Clear" then
		self:LaneClear()
		self:JungleClear()
	end

	if self.Menu.MiscSet.AutoQ.Enable:Value() then
		self:AutoBarrel()
	end
	if Ready(_R) and self.Menu.MiscSet.AutoR.Enable:Value() then
		self:AutoRR()
	end
	if Ready(_W) then
		if self.Menu.MiscSet.AutoW.Enable1:Value()
			--self:UseWImmo()
		end
		if self.Menu.MiscSet.AutoW.Enable2:Value()
			--self:UseW()
		end		
	end	

	self:AutoKS()
end

function Gangplank:Draw()
	if myHero.dead then return end
	
	if self.Menu.MiscSet.Drawing.DrawQ:Value() and Ready(_Q) then
		Draw.Circle(myHero, 625, 1, Draw.Color(255, 225, 255, 10))
	end                                                 
	if self.Menu.MiscSet.Drawing.DrawE:Value() and Ready(_E) then
		Draw.Circle(myHero, 1000, 1, Draw.Color(225, 225, 0, 10))
	end
end	

function Gangplank:LaneClear()
	if self.Menu.ClearSet.Clear.UseQ:Value() then
		if self.Menu.ClearSet.Clear.UseQ2:Value() then
			self:UseQFarm()
		else
			self:UseQFarm2()
		end	
	end
	if self.Menu.ClearSet.Clear.UseE:Value() then
		self:MinionE()
	end
end

function Gangplank:JungleClear()
	if self.Menu.ClearSet.JClear.UseQ:Value() then
		if self.Menu.ClearSet.JClear.UseQ2:Value() then
			self:UseQFarm()
		else
			self:UseQFarm2()
		end	
	end
	if self.Menu.ClearSet.JClear.UseE:Value() then
		self:MinionE()
	end
end

function Gangplank:ComboE(unit)
	local estack = myHero:GetSpellData(_E).ammo
	local barrel = CanQBarrel()
	if Ready(_Q) and Ready(_E) and BarrelCount >= 1 then
		
		if barrel ~= nil then
			if myHero.pos:DistanceTo(unit.pos) < 1300 and unit.pos:DistanceTo(barrel.pos) <= 780 then
				self:CastEAOE(unit, barrel)
			end 

		elseif barrel == nil and Ready(_Q) and Ready(_E) then
			local Near = Vector(myHero.pos) + (Vector(unit.pos) - Vector(myHero.pos)):Normalized() * 150 
			local Far = Vector(myHero.pos) + (Vector(unit.pos) - Vector(myHero.pos)):Normalized() * 350	
		
			if GetDistance(unit.pos, myHero.pos) <= 650 and GetDistance(Near, myHero.pos) <= 650 then
				Control.CastSpell(HK_E, Near)
			elseif GetDistance(unit.pos, myHero.pos) >= 650 and GetDistance(unit.pos, myHero.pos) <= 1250 and GetDistance(Far, myHero.pos) <= 1250 then
				Control.CastSpell(HK_E, Far)
			end
		end	
	end
end

function Gangplank:AutoBarrel()
	local barrel = CanQBarrel()
	if barrel ~= nil then
		local BarrelAndEnemy = 	function() 
			for i, z in pairs(Barrel) do 
				if barrel ~= z and GetEnemyCount(370, z) >= 1 and barrel.pos:DistanceTo(z) < 700 then  
					return z 
				end 
			end 
		end
		
		local Check = BarrelAndEnemy()
		if Ready(_Q) and Check ~= nil and barrel ~= nil and barrel.pos:DistanceTo(myHero.pos) < 625 and GetEnemyCount(370, Check) >= 1 then
			Control.CastSpell(HK_Q, barrel)
		end
		if Ready(_Q) and barrel ~= nil and GetEnemyCount(370, barrel) >= 1 and barrel.pos:DistanceTo(myHero.pos) < 625 then
			Control.CastSpell(HK_Q, barrel)
		end
	end
end

function CanQBarrel()
	local delay = 	function() 
						if GetLevel(myHero) >= 13 then 
							return .5 
						elseif GetLevel(myHero) >= 7 and GetLevel(myHero) < 13 then 
							return 1 
						elseif GetLevel(myHero) < 7 then 
							return 2 
						end 
					end
					
	local time = 	function(unit) 
						return unit.pos:DistanceTo(myHero.pos) / 1700 + 0.25 
					end 
	
	local mod = 	function(unit) 
						return GetCurrentHP(unit) * delay() * 1000 
					end
					
	local barrelf = function() 
						for i, object in pairs(Barrel) do 
							if object ~= nil and Tick ~= nil and (GetTickCount() - Tick + time(object) * 1000 > mod(object) or object.health == 1) then 
								return object 
							end 
						end 
					end
	
	local barrel = barrelf()
	if barrel ~= nil then
		return barrel
	end
end

function Gangplank:CastQ(unit)
	local barrel = CanQBarrel()
	if myHero:GetSpellData(_E).ammo == 0 and unit.pos:DistanceTo(myHero.pos) < 625 and Ready(_Q) and (not barrel or barrel and GetDistance(barrel.pos, unit.pos) > 1200) then
		Control.CastSpell(HK_Q, unit)
	end
end

function Gangplank:MinionE()
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 1000 and (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and IsValid(minion) then
			local barrel = CanQBarrel()
			if barrel ~= nil then
				local BarrelAndEnemy = 	function() 
											for i, z in pairs(Barrel) do 
												if barrel ~= z and z ~= nil and barrel.pos:DistanceTo(z) < 700 then 
													return z 
												end 
											end 
										end
				local Check = BarrelAndEnemy()
				if Ready(_Q) and Check ~= nil and barrel ~= nil and barrel.pos:DistanceTo(myHero.pos) < 625 then
					Control.CastSpell(HK_Q, barrel)
				end
				if Ready(_Q) and barrel ~= nil and barrel.pos:DistanceTo(myHero.pos) < 625 then
					Control.CastSpell(HK_Q, barrel)
				end
			end
			
			if barrel == nil and BarrelCount <= 1 and Ready(_E) then
				if minion.team == TEAM_ENEMY then
					if GetMinionCount(370, minion) > 3 then
						Control.CastSpell(HK_E, minion.pos)
					end
				else
					if minion.team == TEAM_JUNGLE then
						Control.CastSpell(HK_E, minion.pos)
					end
				end	
			end
		end
	end
end

function Gangplank:UseQFarm()
	for i = 1, GameMinionCount() do
		local minion = GameMinion(i)
		if myHero.pos:DistanceTo(minion.pos) <= 625 and (minion.team == TEAM_JUNGLE or minion.team == TEAM_ENEMY) and IsValid(minion) then
			local HP = minion.health
			local Dmg = getdmg("Q", minion, myHero)
			if Ready(_Q) and HP < Dmg then
				Control.CastSpell(HK_Q, minion)
			end
		end
	end
end

function Gangplank:AutoKS()
	for i, target in pairs(GetEnemyHeroes()) do
		
		if target and Ready(_R) and self.Menu.ks.UseR:Value() and IsValid(target) then 
			local RDmg = getdmg("R", target, myHero)			
			if RDmg > target.health then
				self:CastRAOE(target, 1)
			end	
		end
			
		if target and Ready(_Q) and self.Menu.ks.UseQ:Value() and myHero.pos:DistanceTo(minion.pos) <= 625 and IsValid(target) then
			local QDmg = getdmg("Q", target, myHero)
			if QDmg > target.health then
				Control.CastSpell(HK_Q, target)
			end	
		end
	end	
end

function Gangplank:AutoRR()
	for i, target in pairs(GetEnemyHeroes()) do

		if target and IsValid(target) and GetAllyCount(750, target) > 0 then
			self:CastRAOE(target, self.Menu.MiscSet.AutoR.Count:Value())
		end
	end	
end

function Gangplank:UseW()

end

function Gangplank:UseWImmo()

end

function Gangplank:AddBarrel()
	local currSpell = myHero.activeSpell
	if currSpell and currSpell.valid and currSpell.name == "GangplankE" then
		DelayAction(function()
			for i = 0, Game.ObjectCount() do
				local object = Game.Object(i)	
				if object and myHero.pos:DistanceTo(object.pos) < 2000 and object.name == "Barrel" then
					BarrelCount = BarrelCount + 1
					TableInsert(Barrel, object)
					self:RemoveBarrel()
					if BarrelCount == 1 then
						Tick = GetTickCount()
					end
				end
			end
		end,0.5)	
	end	
end

function Gangplank:RemoveBarrel()
	for i = 0, Game.ObjectCount() do
		local object = Game.Object(i)	
		if object and object.name == "Gangplank_Base_E_AoE_Green.troy" then
			BarrelCount = BarrelCount - 1
			TableRemove(Barrel, 1)
			Tick = nil
		end	
	end
end

function Gangplank:CastEAOE(unit, unit2)	
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, EspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredE:Value(), pred.HitChance) then
			if pred.HitCount >= 1 and unit2.pos:DistanceTo(pred.CastPos) < 700 then
				Control.CastSpell(HK_E, pred.CastPos)
			end	
		end
	else						-- GG-AOE-Prediction --
		local EPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 325, Range = 1000, Speed = MathHuge, Collision = false})
		local minhitchance = self.Menu.MiscSet.Pred.PredE:Value()+1
		local aoeresult = EPrediction:GetAOEPrediction(myHero)
		local bestaoe = nil
		local bestcount = 0
		local bestdistance = 1000
	   
		for i = 1, #aoeresult do
			local aoe = aoeresult[i]
			if aoe.HitChance >= minhitchance and aoe.TimeToHit <= 0.3 and aoe.Count >= 1 then
				if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
					bestdistance = aoe.Distance
					bestcount = aoe.Count
					bestaoe = aoe
				end
			end
		end
		
		if bestaoe and unit2.pos:DistanceTo(bestaoe.CastPosition) < 700 then
			Control.CastSpell(HK_E, bestaoe.CastPosition)			 
		end
	end	
end	

function Gangplank:CastRAOE(unit, count)	
	if self.Menu.MiscSet.Pred.Change:Value() == 1 then
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, RspellData)
		if pred.CastPos and ConvertToHitChance(self.Menu.MiscSet.Pred.PredR:Value(), pred.HitChance) then
			if pred.HitCount >= count then
				Control.CastSpell(HK_R, pred.CastPos)
			end	
		end
	else						-- GG-AOE-Prediction --
		local RPrediction = GGPrediction:SpellPrediction({Type = GGPrediction.SPELLTYPE_CIRCLE, Delay = 0.25, Radius = 600, Range = MathHuge, Speed = MathHuge, Collision = false})
		local minhitchance = self.Menu.MiscSet.Pred.PredR:Value()+1
		local aoeresult = RPrediction:GetAOEPrediction(myHero)
		local bestaoe = nil
		local bestcount = 0
		local bestdistance = 1000
	   
		for i = 1, #aoeresult do
			local aoe = aoeresult[i]
			if aoe.HitChance >= minhitchance and aoe.TimeToHit <= 0.3 and aoe.Count >= count then
				if aoe.Count > bestcount or (aoe.Count == bestcount and aoe.Distance < bestdistance) then
					bestdistance = aoe.Distance
					bestcount = aoe.Count
					bestaoe = aoe
				end
			end
		end
		
		if bestaoe then
			Control.CastSpell(HK_R, bestaoe.CastPosition)			 
		end
	end	
end