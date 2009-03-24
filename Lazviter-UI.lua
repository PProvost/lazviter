--[[
Lazviter/Lazviter-UI.lua

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

local panel = LibStub("qPanelLib"):CreateMainPanel("LazviterPanel", "La-Z-Viter")

local lineHeight, maxoffset, offset = 12, 0, 0

local scroll = panel:CreateChildPanel("ScrollFrame") -- CreateFrame("ScrollFrame", nil, panel)
local scrollHeight = scroll:GetHeight()
local editbox = CreateFrame("EditBox", nil, scroll)
scroll:SetScrollChild(editbox)
editbox:SetPoint("TOP")
editbox:SetPoint("LEFT")
editbox:SetPoint("RIGHT")
editbox:SetHeight(1000)
editbox:SetFontObject(GameFontHighlight)
editbox:SetTextInsets(2,2,2,2)
editbox:SetMultiLine(true)
editbox:SetAutoFocus(false)
editbox:SetScript("OnEscapePressed", editbox.ClearFocus)
-- editbox:SetScript("OnEditFocusLost", function(self) LazviterDB = self:GetText() end)

editbox:SetScript("OnShow", function(self)
	local text = ""
	self:SetText(text)
	self:SetFocus()
end)

local function doscroll(v)
	offset = math.max(math.min(v, 0), maxoffset)
	scroll:SetVerticalScroll(-offset)
	editbox:SetPoint("TOP", 0, offset)
end

editbox:SetScript("OnCursorChanged", function(self, x, y, width, height)
	lineHeight = height
	if offset < y then
		doscroll(y)
	elseif math.floor(offset - scrollHeight + height*2) > y then
		local v = y + scrollHeight - height*2
		maxoffset = math.min(maxoffset, v)
		doscroll(v)
	end
end)

scroll:UpdateScrollChildRect()
scroll:EnableMouseWheel(true)
scroll:SetScript("OnMouseWheel", function(self, val) doscroll(offset + val*lineHeight*3) end)

local butt = LibStub("qPanelLib"):CreateStandardButton(panel, "Invite")
butt:SetHeight(18)
butt:SetPoint("BOTTOMRIGHT", -40, 65)
butt:SetScript("OnClick", function() 
	local text = editbox:GetText()
	local attlist = { string.split("\n", text) }
	print("------------------------------------------------")
	for i,v in ipairs(attlist) do
		if strtrim(v) ~= "" and not (UnitInRaid(v) or UnitInParty(v)) then
			print("Inviting " .. v)
			InviteUnit(v)
		end
	end
	print("------------------------------------------------")
end)

function Lazviter:ShowInputFrame()
	ShowUIPanel(panel)
end

