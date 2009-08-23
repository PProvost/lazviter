

local lib, oldminor = LibStub:NewLibrary("tekPanel", 1)
if not lib then return end
oldminor = oldminor or 0


local function createtex(parent, layer, w, h, texture, ...)
	local tex = parent:CreateTexture(nil, layer)
	tex:SetWidth(w) tex:SetHeight(h)
	tex:SetTexture(texture)
	tex:SetPoint(...)
	return tex
end


function lib.new(name, titletext)
	local frame = CreateFrame("Frame", name, UIParent)
--~ 	frame:CreateTitleRegion()
	frame:SetToplevel(true)
	frame:SetFrameLevel(100) -- Force frame to a high level so it shows on top the first time it's displayed
	frame:SetWidth(384) frame:SetHeight(512)
	frame:SetPoint("TOPLEFT", 0, -104)
	frame:EnableMouse() -- To avoid click-thru

	frame:Hide()

	frame:SetAttribute("UIPanelLayout-defined", true)
	frame:SetAttribute("UIPanelLayout-enabled", true)
	frame:SetAttribute("UIPanelLayout-area", "left")
	frame:SetAttribute("UIPanelLayout-whileDead", true)
	table.insert(UISpecialFrames, name)

--~ 		<HitRectInsets>
--~ 			<AbsInset left="0" right="30" top="0" bottom="75"/>
--~ 		</HitRectInsets>

--~ 	local title = frame:GetTitleRegion()
--~ 	title:SetWidth(757) title:SetHeight(20)
--~ 	title:SetPoint("TOPLEFT", 75, -15)

	local portrait = createtex(frame, "ARTWORK", 60, 60, nil, "TOPLEFT", 7, -6)
	SetPortraitTexture(portrait, "player")
	frame:SetScript("OnEvent", function(self, event, unit) if unit == "player" then SetPortraitTexture(portrait, "player") end end)
	frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")

	local title = frame:CreateFontString(nil, "BACKGROUND")
	title:SetFontObject(GameFontHighlight)
	title:SetPoint("CENTER", 6, 232)
	title:SetText(titletext)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("CENTER", frame, "TOPRIGHT", -44, -25)
	close:SetScript("OnClick", function() HideUIPanel(frame) end)

	createtex(frame, "BACKGROUND", 256, 256, [[Interface\PaperDollInfoFrame\UI-Character-General-TopLeft]], "TOPLEFT", 2, -1)
	createtex(frame, "BACKGROUND", 128, 256, [[Interface\PaperDollInfoFrame\UI-Character-General-TopRight]], "TOPLEFT", 258, -1)
	createtex(frame, "BACKGROUND", 256, 256, [[Interface\PaperDollInfoFrame\UI-Character-General-BottomLeft]], "TOPLEFT", 2, -257)
	createtex(frame, "BACKGROUND", 128, 256, [[Interface\PaperDollInfoFrame\UI-Character-General-BottomRight]], "TOPLEFT", 258, -257)

	return frame
end
