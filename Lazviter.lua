--[[
Lazviter/Lazviter.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local addonName = "La-Z-Viter"

-- Locals
local L = setmetatable({}, {__index=function(t,i) return i end})
local defaults, defaultsPC, db, dbpc = {}, {}

-- Utility function
local function Print(...) print("|cFF33FF99" .. addonName .. "|r:", ...) end
local debugf = tekDebug and tekDebug:GetFrame("Lazviter")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

-- Addon declaration
Lazviter = CreateFrame("frame")
Lazviter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
Lazviter:RegisterEvent("ADDON_LOADED")

function Lazviter:ADDON_LOADED(event, addon)
	if addon:lower() ~= addonName:lower() then return end

	LazviterDB, LazviterDBPC = setmetatable(LazviterDB or {}, {__index = defaults}), setmetatable(LazviterDBPC or {}, {__index = defaultsPC})
	db, dbpc = LazviterDB, LazviterDBPC

	-- Do anything you need to do after addon has loaded

	LibStub("tekKonfig-AboutPanel").new(nil, "Lazviter") -- Make first arg nil if no parent config panel

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function Lazviter:PLAYER_LOGIN()
	self:RegisterEvent("PLAYER_LOGOUT")

	-- Do anything you need to do after the player has entered the world

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function Lazviter:PLAYER_LOGOUT()
	for i,v in pairs(defaults) do if db[i] == v then db[i] = nil end end
	for i,v in pairs(defaultsPC) do if dbpc[i] == v then dbpc[i] = nil end end

	-- Do anything you need to do as the player logs out
end

SLASH_LAZVITER1 = "/lazviter"
SLASH_LAZVITER2 = "/lin"
SlashCmdList.LAZVITER = function(msg)
	Lazviter:ShowInputFrame()
end

