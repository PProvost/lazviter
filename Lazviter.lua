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

-- Utility functions
local function Print(...) print("|cFF33FF99" .. addonName .. "|r:", ...) end
local debugf = tekDebug and tekDebug:GetFrame("Lazviter")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

-- Addon declaration
Lazviter = CreateFrame("frame")
Lazviter:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
Lazviter:RegisterEvent("ADDON_LOADED")

function Lazviter:ADDON_LOADED(event, addon)
	if addon:lower() ~= addonName:lower() then return end
	LibStub("tekKonfig-AboutPanel").new(nil, "Lazviter") -- Make first arg nil if no parent config panel
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end

function Lazviter:DoInvites(approved, standby)
	self.approved = approved
	self.standby = standby
	self:ProcessApprovedList()
end

function Lazviter:ProcessApprovedList()
	local approved = self.approved

	local inRaid = (GetNumRaidMembers() > 0)
	for i = 1,#approved do
		if not inRaid and i == 4 then
			self:RegisterEvent("CHAT_MSG_SYSTEM")
			break
		else
			local name = table.remove(approved)
			if not UnitExists(name) then
				Print("Unit does not exist: " .. name)
			elseif not (UnitInRaid(name) or UnitInParty(name)) then
				InviteUnit(name)
			else
				Print("Unable to invite " .. name)
			end
		end
	end
end

function Lazviter:CHAT_MSG_SYSTEM(event, msg)
	local t1 = string.match(msg, "(%w+) joins the party.")
	local t3 = string.match(msg, "You have joined a raid group.")

	if t1 then
		ConvertToRaid()
	elseif t3 then
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:ProcessApprovedList()
	end
end

SLASH_LAZVITER1 = "/lazviter"
SLASH_LAZVITER2 = "/lin"
SlashCmdList.LAZVITER = function(msg)
	Lazviter:ShowInputFrame()
end

