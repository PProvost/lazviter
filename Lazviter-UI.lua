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
local panel = LibStub("tekPanel").new("Lazviter-Panel", "La-Z-Viter")
 
local scroll = CreateFrame("ScrollFrame", nil, panel)
scroll:SetPoint("TOPLEFT", 21, -73)
scroll:SetPoint("BOTTOMRIGHT", -10, 38)
local HEIGHT = scroll:GetHeight()
 
local editbox = CreateFrame("EditBox", nil, scroll)
scroll:SetScrollChild(editbox)
editbox:SetPoint("TOP")
editbox:SetPoint("LEFT")
editbox:SetPoint("RIGHT")
editbox:SetHeight(1000)
editbox:SetFontObject(GameFontHighlightSmall)
editbox:SetTextInsets(2,2,2,2)
editbox:SetMultiLine(true)
editbox:SetAutoFocus(false)
editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
editbox:SetScript("OnEditFocusLost", function(self) tekPadDB = self:GetText() end)
 
editbox:SetScript("OnShow", function(self)
	local text = tekPadDB or ""
	self:SetText(text)
	self:SetFocus()
end)
 
local function doscroll(v)
	offset = math.max(math.min(v, 0), maxoffset)
	scroll:SetVerticalScroll(-offset)
	editbox:SetPoint("TOP", 0, offset)
end
 
editbox:SetScript("OnCursorChanged", function(self, x, y, width, height)
	LINEHEIGHT = height
	if offset < y then
		doscroll(y)
	elseif math.floor(offset - HEIGHT + height*2) > y then
		local v = y + HEIGHT - height*2
		maxoffset = math.min(maxoffset, v)
		doscroll(v)
	end
end)
 
scroll:UpdateScrollChildRect()
scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel", function(self, val) doscroll(offset + val*LINEHEIGHT*3) end)
 
local Invite_OnClick
local butt = LibStub("tekKonfig-Button").new(panel, "BOTTOMRIGHT", -40, 65)
butt:SetText("Invite")
butt:SetScript("OnClick", Invite_OnClick)

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
	local text = editbox:GetText()

	local approved = {}
	local standby = {}
	local currentList = approved
	local attlist = { string.split("\n", text) }
	for i,v in ipairs(attlist) do
		if strtrim(v) ~= "" then
			local name = string.match(v, "%w+")
			if name and string.match(name, "^[Ss]tandby.*") or string.match(name, "^[Ww]aitlist.*") or string.match(name, "^[Ww]ait [Ll]ist.*") then
				currentList = standby
			elseif isFriend(name) or isGuildMember(name) then
				table.insert(currentList, name)
			end
		end
	end

	Lazviter:DoInvites(approved, standby)
end

function Lazviter:ShowInputFrame()
	ShowUIPanel(panel)
end

