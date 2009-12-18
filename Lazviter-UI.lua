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
scrollEdit:SetPoint("BOTTOMRIGHT", -65, 150)

local outputMessageFrame = CreateFrame("ScrollingMessageFrame", "LazviterOutputMessageFrame", panel)
outputMessageFrame:SetPoint("TOPLEFT", scrollEdit, "BOTTOMLEFT", 0, -3)
outputMessageFrame:SetPoint("BOTTOMRIGHT", -60, 82)
outputMessageFrame:SetMaxLines(250)
outputMessageFrame:SetFontObject(ChatFontSmall)
outputMessageFrame:SetJustifyH("LEFT")
outputMessageFrame:SetFading(false)
outputMessageFrame:SetInsertMode("BOTTOM")
local outputMessageFrameScrollbar = CreateFrame("Slider", nil, outputMessageFrame, "UIPanelScrollBarTemplate")
outputMessageFrameScrollbar:SetPoint("TOPLEFT", outputMessageFrame, "TOPRIGHT", 0, -16)
outputMessageFrameScrollbar:SetPoint("BOTTOMLEFT", outputMessageFrame, "BOTTOMRIGHT", 0, 16)
outputMessageFrameScrollbar:SetMinMaxValues(1,1)
local tmp = outputMessageFrame.AddMessage
outputMessageFrame.AddMessage = function(self, text, ...)
	local min, max = outputMessageFrameScrollbar:GetMinMaxValues()
	local numMessages = outputMessageFrame:GetNumMessages()
	if numMessages > max then max = numMessages end
	outputMessageFrameScrollbar:SetMinMaxValues(min, max)
	tmp(self, text, ...)
end
outputMessageFrameScrollbar:SetScript("OnValueChanged", function(self, value)
	outputMessageFrame:SetScrollOffset(value)
end)
outputMessageFrame:SetScript("OnMessageScrollChanged", function(self)
	outputMessageFrameScrollbar:SetValue( outputMessageFrame:GetCurrentScroll() )
end)

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
	local currentList = approved
	local attlist = { string.split("\n", text) }
	for i,v in ipairs(attlist) do
		if strtrim(v) ~= "" then
			local name = string.match(v, "%w+")
			if name and string.match(name, "^[Ss]tandby.*") or string.match(name, "^[Ww]aitlist.*") or string.match(name, "^[Ww]ait [Ll]ist.*") then
				currentList = standby
			else
				table.insert(currentList, name)
			end
		end
	end

	Lazviter:DoInvites(approved, standby)
end

local butt = LibStub("tekKonfig-Button").new(panel, "TOPRIGHT", -45, -43)
butt:SetText("Invite")
butt:SetScript("OnClick", Invite_OnClick)


function Lazviter:ShowInputFrame()
	ShowUIPanel(panel)
end

