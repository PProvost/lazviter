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
	if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
end

function Lazviter:PLAYER_LOGIN()
	GuildRoster()
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

local function isFriend(name)
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then return true end
	end
end

local function isGuildMember(name)
	for i = 1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then return true end
	end
end

function Lazviter:DoInvites(approved, standby)
	self.approved = approved
	self.standby = standby

	Print("Beginning invites")
	self:ScheduleTimer("DoActualInvites", 2)
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
		if GetNumPartyMembers() == 0 then
			self:RegisterEvent("PARTY_MEMBERS_CHANGED")
			for i = 1, 4 do
				local u = table.remove(self.approved)
				if u then self:InviteUnit(u) end
			end
			return
		else
			ConvertToRaid()
			self:ScheduleTimer("DoActualInvites", 2)
			return
		end
	end
	for i, v in ipairs(self.approved) do self:InviteUnit(v) end
	for k in pairs(self.approved) do self.approved[k] = nil end

	for i,v in ipairs(self.standby) do Print(v.." on standby") end
end

local function isGuildMemberOnline(name)
   local count = GetNumGuildMembers(true)
   local nom, online
   for index = 1,count do
      nom, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      if name == nom and online == 1 then
         return 1
      end
   end
end

function Lazviter:InviteUnit(name)
	if UnitIsUnit(name, "player") then return end
	if isGuildMember(name) then
		if isGuildMemberOnline(name) then
			InviteUnit(name)
		else
			Print("Not online "..name)
		end
	else
		Print("Inviting "..name.." (non guild)")
		InviteUnit(name)
	end
end

SLASH_LAZVITER1 = "/lazviter"
SLASH_LAZVITER2 = "/lin"
SlashCmdList.LAZVITER = function(msg)
	Lazviter:ShowInputFrame()
end

