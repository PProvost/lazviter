--[[
qPanelLib.lua

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


-- Credits: Tekkub for tekPanelAuction and all his other work

local lib, oldminor = LibStub:NewLibrary("qPanelLib", 0)
if not lib then return end -- no upgrade needed

-- Helper functions
local function createChildPanel(mainPanel, type, name, inheritFrame)
	local frame = CreateFrame(type or "Frame", name, mainPanel, inheritFrame)
	frame:SetPoint("TOPLEFT", 21, -73)
	frame:SetPoint("BOTTOMRIGHT", -10, 90)
	table.insert(mainPanel.subPanels, frame)
	return frame
end

function createTexture(parent, layer, w, h, tex, ...)
	local result = parent:CreateTexture(nil, layer)
	result:SetWidth(w); result:SetHeight(h)
	result:SetPoint(...)
	if tex then result:SetTexture(tex) end
	return result
end

-- Main entry point
function lib:CreateMainPanel(name, title, isDoubleWide)
	local height = isDoubleWide and 447 or 512
	local width = isDoubleWide and 832 or 384

	-- Initial basic frame creation
	local frame = CreateFrame("Frame", name, UIParent)
	frame:CreateTitleRegion()
	frame:SetToplevel(true)
	frame:SetFrameLevel(100) -- Force frame to a high level so it shows on top the first time it's displayed
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame:SetPoint("TOPLEFT", 0, -104)
	frame:EnableMouse() -- To avoid click-thru
	frame:SetClampedToScreen(true)
	frame:SetClampRectInsets(0, 0, 0, 50)
	frame:Hide()

	-- Make it act like a normal left sliding frame, etc.
	frame:SetAttribute("UIPanelLayout-defined", true)
	frame:SetAttribute("UIPanelLayout-enabled", true)
	frame:SetAttribute("UIPanelLayout-area", "doublewide")
	frame:SetAttribute("UIPanelLayout-whileDead", true)
	table.insert(UISpecialFrames, name)

	-- Configure title region
	local titleRegion = frame:GetTitleRegion()
	titleRegion:SetWidth(width-75)
	titleRegion:SetHeight(20)
	titleRegion:SetPoint("TOPLEFT", 75, -15)

	-- top left portrait code
	local portrait = createTexture(frame, "OVERLAY", 57, 57, nil, "TOPLEFT", 9, -7)
	SetPortraitTexture(portrait, "player")
	frame:SetScript("OnEvent", function(self, event, unit) if unit == "player" then SetPortraitTexture(portrait, "player") end end)
	frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")

	-- Set the title text
	local titleString = frame:CreateFontString(nil, "OVERLAY")
	titleString:SetFontObject(GameFontNormal)
	titleString:SetPoint("TOP", 0, -18)
	titleString:SetText(title)

	-- Close button
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", isDoubleWide and 3 or -30, -8)
	close:SetScript("OnClick", function() HideUIPanel(frame) end)

	-- Edge textures
	if isDoubleWide then
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft", "TOPLEFT", 0, 0)
		createTexture(frame, "ARTWORK", 320, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Top", "TOPLEFT", 256, 0)
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopRight", "TOPLEFT", frame.top, "TOPRIGHT")
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft", "TOPLEFT", 0, -256)
		createTexture(frame, "ARTWORK", 320, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot", "TOPLEFT", 256, -256)
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight", "TOPLEFT", frame.bottom, "TOPRIGHT")
	else
		--[[
		local bottom = createTexture(frame, "ARTWORK", 192, 256, "Interface\\MerchantFrame\\UI-Merchant-BotLeft", "BOTTOMRIGHT", -47, 0)
		bottom:SetTexCoord(0.25, 1, 0, 1)
		]]
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\MerchantFrame\\UI-Merchant-TopLeft", "TOPLEFT", 0, 0)
		createTexture(frame, "ARTWORK", 256, 256, "Interface\\MerchantFrame\\UI-Merchant-BotLeft", "BOTTOMLEFT", 0, 0)
		createTexture(frame, "ARTWORK", 128, 256, "Interface\\MerchantFrame\\UI-Merchant-TopRight", "TOPRIGHT", 0, 0)
		createTexture(frame, "ARTWORK", 128, 256, "Interface\\MerchantFrame\\UI-Merchant-BotRight", "BOTTOMRIGHT", 0, 0)
	end

	-- Setup some local storage
	frame.subPanels = {}

	-- Glue in functions to the main panel
	frame.CreateChildPanel = createChildPanel

	return frame
end

function lib:CreateStandardButton(parent, text, w, h)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(w or 80) button:SetHeight(h or 22)

	button:SetHighlightFontObject(GameFontHighlightSmall)
	button:SetNormalFontObject(GameFontNormalSmall)

	button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	button:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	button:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	button:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	button:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	button:GetHighlightTexture():SetBlendMode("ADD")

	button:SetText(text)

	return button
end

