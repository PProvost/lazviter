--[[
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

if not Lazviter then return end

local LINEHEIGHT, maxoffset, offset = 12, 0, 0
local panel = LibStub("tekPanel").new("LazviterPanel", "La-Z-Viter")
panel:SetAttribute("UIPanelLayout-pushable", 5)
 
local scrollEdit = LibStub("QScrollingEditBox"):New("LazviterPanelEditBox", panel)
scrollEdit:SetPoint("TOPLEFT", 22, -76)
scrollEdit:SetPoint("BOTTOMRIGHT", -65, 81)

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

local function Invite_OnClick()
	local text = scrollEdit:GetText()

	local approved = {}
	local standby = {}
	local unknown = {}
	local currentList = approved
	local attlist = { string.split("\n", text) }
	for i,v in ipairs(attlist) do
		if strtrim(v) ~= "" then
			local name = string.match(v, "%w+")
			if name and string.match(name, "^[Ss]tandby.*") or string.match(name, "^[Ww]aitlist.*") or string.match(name, "^[Ww]ait [Ll]ist.*") then
				currentList = standby
			elseif isFriend(name) or isGuildMember(name) then
				table.insert(currentList, name)
			else
				table.insert(unknown, name)
			end
		end
	end

	Lazviter:DoInvites(approved, standby, unknown)
end

local butt = LibStub("tekKonfig-Button").new(panel, "TOPRIGHT", -45, -43)
butt:SetText("Invite")
butt:SetScript("OnClick", Invite_OnClick)


function Lazviter:ShowInputFrame()
	ShowUIPanel(panel)
end

