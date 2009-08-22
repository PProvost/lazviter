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
LibStub("AceTimer-3.0"):Embed(Lazviter)

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
	self:ScheduleTimer("DoActualInvites", 5)
end

function Lazviter:PARTY_MEMBERS_CHANGED()
	if GetNumPartyMembers() > 0 then
		ConvertToRaid()
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		self:ScheduleTimer("DoActualInvites", 2)
	end
end

function Lazviter:DoActualInvites()
	if not UnitInRaid("player") then
		local pNum = GetNumPartyMembers()
		if pNum == 0 then
			-- This means we have to first invite up to the party size (4), and
			-- then wait for someone to join before we convert to a party and
			-- invite the rest.
			self:RegisterEvent("PARTY_MEMBERS_CHANGED")
			for i = 1, 4 do
				local u = table.remove(self.approved)
				if u then InviteUnit(u) end
			end
			-- We've invited as many people as we can, now we need to wait
			-- for a raid group.
			return
		else
			ConvertToRaid()
			self:ScheduleTimer("DoActualInvites", 2)
			return
		end
	end
	-- Either we're in a raid, or we only want to invite enough people that
	-- we can fit in our group anyway.
	for i, v in ipairs(self.approved) do
		InviteUnit(v)
	end
	for k in pairs(self.approved) do
		self.approved[k] = nil
	end
end

SLASH_LAZVITER1 = "/lazviter"
SLASH_LAZVITER2 = "/lin"
SlashCmdList.LAZVITER = function(msg)
	Lazviter:ShowInputFrame()
end

