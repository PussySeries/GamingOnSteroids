--///////////////////////////////////////////////////////////--
--///////////////////////AIO LOADER//////////////////////////--
--///////////////////////////////////////////////////////////--


if _G.MainLoad then
	return 
end

local osclock			= os.clock;
local open               = io.open
local concat             = table.concat
local rep                = string.rep 
local format             = string.format

local AUTO_PATH			= 	COMMON_PATH
local dotlua			= 	".lua" 
local coreName			=	"PussySeriesCore.lua"
local charName			= 	myHero.charName

local function readAll(file)
	local f = assert(open(file, "r"))
	local content = f:read("*all")
	f:close()
	return content
end

local function AutoUpdate()
	local CHAMP_PATH			= AUTO_PATH
	local SCRIPT_URL			= "https://raw.githubusercontent.com/PussySeries/GamingOnSteroids/master/Champions/PussySeriesAio/"
	local AUTO_URL				= "https://raw.githubusercontent.com/PussySeries/GamingOnSteroids/master/Champions/PussySeriesAio/"
	local CHAMP_URL				= "https://raw.githubusercontent.com/PussySeries/GamingOnSteroids/master/Champions/PussySeriesAio/Champions/"
	local oldVersion			= "currentVersion.lua"
	local newVersion			= "newVersion.lua"
	--
	local function serializeTable(val, name, depth) 
		skipnewlines = false
		depth = depth or 0
		local res = rep(" ", depth)
		if name then res = res .. name .. " = " end
		if type(val) == "table" then
			res = res .. "{" .. "\n"
			for k, v in pairs(val) do
				res =  res .. serializeTable(v, k, depth + 4) .. "," .. "\n" 
			end
			res = res .. rep(" ", depth) .. "}"
		elseif type(val) == "number" then
			res = res .. tostring(val)
		elseif type(val) == "string" then
			res = res .. format("%q", val)
		end    
		return res
	end
	local function DownloadFile(from, to, filename)
		local startTime = osclock()
		DownloadFileAsync(from..filename, to..filename, function() end)		
		repeat until osclock() - startTime > 5 or FileExist(to..filename)
	end	
	
	local function GetVersionControl()
		if not FileExist(AUTO_PATH..oldVersion) then 
			DownloadFile(AUTO_URL, AUTO_PATH, oldVersion) 
		end
		DownloadFile(AUTO_URL, AUTO_PATH, newVersion)
	end
			
	local function CheckSupported()
		local Data = dofile(AUTO_PATH..newVersion)

		return Data.Champions[charName]
	end
	
	local function UpdateVersionControl(t)    
		local str = serializeTable(t, "Data") .. "\n\nreturn Data"    
		local f = assert(open(AUTO_PATH..oldVersion, "w"))
		f:write(str)
		f:close()
	end
	
	local function LoadLibs()
		
		require "DamageLib"

		if not FileExist(COMMON_PATH .. "PremiumPrediction.lua") then
			DownloadFileAsync("https://raw.githubusercontent.com/Ark223/GoS-Scripts/master/PremiumPrediction.lua", COMMON_PATH .. "PremiumPrediction.lua", function() end)
			print("PremiumPred. installed Press 2x F6")
			return
		end

		if not FileExist(COMMON_PATH .. "GGPrediction.lua") then
			DownloadFileAsync("https://raw.githubusercontent.com/gamsteron/GG/master/GGPrediction.lua", COMMON_PATH .. "GGPrediction.lua", function() end)
			print("GGPrediction installed Press 2x F6")
			return
		end
	end	
	
	local function InitializeScript()         
        local function writeModule(content)            
            local f = assert(open(AUTO_PATH.."dynamicScript.lua", content and "a" or "w"))
            if content then
                f:write(content)
            end
            f:close()        
        end
        --        
        writeModule()
		
		
		
		--Write the core module			
		writeModule(readAll(COMMON_PATH..coreName))
		writeModule(readAll(COMMON_PATH..charName..dotlua))
		
				
		--Load the active module
		dofile(COMMON_PATH.."dynamicScript"..dotlua)
		
    end	    
	
	local function CheckUpdate()
		local currentData, latestData = dofile(AUTO_PATH..oldVersion), dofile(AUTO_PATH..newVersion)
		if currentData.Loader.Version < latestData.Loader.Version then
			print ("Pls Press 2x F6")
			DownloadFile(SCRIPT_URL, SCRIPT_PATH, "PussySeriesAio.lua")        
			currentData.Loader.Version = latestData.Loader.Version
		end
		
		for k,v in pairs(latestData.Champions) do
			if not FileExist(CHAMP_PATH..k..dotlua) or not currentData.Champions[k] or currentData.Champions[k].Version < v.Version then
				print("Downloading Champion Script: " .. k)
				DownloadFile(CHAMP_URL, CHAMP_PATH, k..dotlua)
				if not currentData.Champions[k] then
					currentData.Champions[k] = v
				else
					currentData.Champions[k].Version = v.Version
				end
			end
		end
		
		if currentData.Core.Version < latestData.Core.Version or not FileExist(AUTO_PATH.."PussySeriesCore.lua") then
			DownloadFile(AUTO_URL, AUTO_PATH, "PussySeriesCore.lua")        
			currentData.Core.Version = latestData.Core.Version
		end
		
		UpdateVersionControl(currentData)
		
	end	
	
	local function LoadScript()
		if CheckSupported() then
			InitializeScript()
			LoadLibs()
		else
			print("PussySeries: Champion not supported: ".. myHero.charName)
		end
	end
	
	GetVersionControl()
	CheckUpdate()
	LoadScript()	
end		

function OnLoad()
	_G.MainLoad = true
	AutoUpdate()	
end
