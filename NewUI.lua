local myname, ns = ...
local addonName = GetAddOnMetadata(myname, "Title")

local mainFrame = nil -- forward declaration

local raidMembers = {
	[1] = { name="Quaiche", class="Druid", role="Tank" },
	[2] = { name="Dankish", class="Hunter", role="Ranged" },
	[3] = { name="Hydrogenbomb", class="Shaman", role="Ranged" },
	[4] = { name="Uethar", class="Paladin", role="Healer" },
	[5] = { name="Vayda", class="Priest", role="Healer" },
	[6] = { name="Airitus", class="Warrior", role="Tank" },
	[7] = { name="Deeoogee", class="Rogue", role="Melee" },
	[8] = { name="Horric", class="Mage", role="Ranged" },
	[9] = { name="Grundy", class="Warlock", role="Ranged" },
	[10] = { name="Peine", class="Death Knight", role="Melee" },
}

local pages = {}
local function setPage(index)
	assert(mainFrame ~= nil)
	for i = 1,#pages do
		if i == index then
			pages[i]:Show()
		else
			pages[i]:Hide()
		end
	end
	mainFrame.titleString:SetText(pages[index].title or "Unknown")
	PanelTemplates_SetTab(mainFrame, index)
end

local function GetUnitClassInfo(unitName)
	local class, classFilename = select(2,UnitClass(unitName))
	if class == nil then
		local numGuildMembers = GetNumGuildMembers()
		for i = 1,numGuildMembers do
			local name, _, _, level, _class, _, _, _, online, _, _classFileName = GetGuildRosterInfo(i)
			if name == unitName then
				class = _class
				classFilename = _classFileName
			end
		end
	end
	return class, classFilename
end

local function GetRole(name)
	local class, classFilename = GetUnitClassInfo(name)
	if classFilename == "ROGUE" then return "Melee" end
	if classFilename=="WARLOCK" or classFilename=="MAGE" or classFilename=="HUNTER" then return "Ranged" end
end

local function CreateManagePage(parent)
	local NUMROWS = 22
	local SCROLLSTEP = math.floor(NUMROWS/3)
	local scrollbox = CreateFrame("Frame", nil, parent)
	scrollbox:SetPoint("TOPLEFT", -14, -5)
	scrollbox:SetPoint("BOTTOMRIGHT", -5, 35)
	local scroll = LibStub("tekKonfig-Scroll").new(scrollbox, 0, SCROLLSTEP)

	local rows, lastbutt = {}
	local function OnMouseWheel(self, val) scroll:SetValue(scroll:GetValue() - val*SCROLLSTEP) end
	for i=1,NUMROWS do
		local butt = CreateFrame("Button", nil, parent)
		butt:SetWidth(318) butt:SetHeight(16)
		if lastbutt then butt:SetPoint("TOP", lastbutt, "BOTTOM") else butt:SetPoint("TOPLEFT", 0, 0) end

		local name = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		name:SetPoint("LEFT", 5, 0)
		butt.name = name

		local detail = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		detail:SetPoint("LEFT", 100, 0)
		butt.detail = detail

		local time = butt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		time:SetPoint("RIGHT", -25, 0)
		butt.time = time

		butt:EnableMouseWheel(true)
		butt:SetScript("OnMouseWheel", OnMouseWheel)
		butt:SetScript("OnClick", OnClick)
		butt:SetScript("OnLeave", function() GameTooltip:Hide() end)
		butt:SetScript("OnEnter", function(self)
			if self.note and self.note ~= " " then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:SetText(self.note)
			end
		end)

		table.insert(rows, butt)
		lastbutt = butt
	end

	local orig = scroll:GetScript("OnValueChanged")
	local function OnValueChanged(self, offset, ...)
		offset = math.floor(offset)

		local i = 0
		for _,v in ipairs(raidMembers) do
			i = i+1
			if (i-offset) > 0 and (i-offset) <= NUMROWS then
				local row = rows[i-offset]
				local class, classFilename = GetUnitClassInfo(v.name)
				local color = { r=1.0, g=1.0, b=1.0 }
				if class then
					color = RAID_CLASS_COLORS[classFilename]
				end

				row.name:SetText(v.name)
				row.name:SetTextColor(color.r, color.g, color.b)

				row.detail:SetText(v.class)
				row.detail:SetTextColor(color.r, color.g, color.b)

				row.time:SetText(v.role)
				row.time:SetTextColor(color.r, color.g, color.b)

				row:Show()
			end
		end

		if (i-offset) < NUMROWS then
			for j=(i-offset+1),NUMROWS do rows[j]:Hide() end
		end

		return orig(self, offset, ...)
	end
	scroll:SetScript("OnValueChanged", OnValueChanged)
	local firstshow = true
	parent:SetScript("OnShow", function(self)
		scroll:SetMinMaxValues(0, math.max(0, i))
		if firstshow then scroll:SetValue(0); firstshow = nil end
	end)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("TOP", scrollbox, "BOTTOM", 0, -5)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontSmall)
	editBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 5, 5)
	editBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -60, 5)
	editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
	editBox:SetHeight(24)

	local addButton = LibStub("tekKonfig-Button").new_small(parent, "BOTTOMRIGHT", -5, 5)
	addButton:SetText("Add")
	addButton:SetWidth(50)
	addButton:SetHeight(24)

	local addName = function()
		local name = editBox:GetText()
			local t = {
				name = name,
				class = GetUnitClassInfo(name) or "Unknown",
				role = GetRole(name) or "No role selected",
			}
			table.insert(raidMembers, t)
			OnValueChanged(scroll, 0)
			editBox:SetText("")
	end

	addButton:SetScript("OnClick", addName)
	editBox:SetScript("OnEnterPressed", addName)
end

local function createImportPage(parent)
	local instructionsText = parent:CreateFontString()
	instructionsText:SetFontObject(GameFontNormalSmall)
	instructionsText:SetJustifyH("LEFT")
	instructionsText:SetJustifyV("TOP")
	instructionsText:SetPoint("TOPLEFT", 5, -5)
	instructionsText:SetPoint("RIGHT", -5)
	instructionsText:SetHeight(100)
	instructionsText:SetText("To import a roster, paste it here, one name per line and click the Import button.\n\nLines that begin with # will be ignored, unless followed by the word \"Tanks\", \"Healers\", \"Melee\", \"Ranged\", or \"Standby\" in which case it will be used to set the role for the following names.\n\nNote: Your existing lineup will be replaced!")

	local scroll = CreateFrame("ScrollFrame", nil, parent)
	scroll:SetPoint("TOPLEFT", 5, -105)
	scroll:SetPoint("BOTTOMRIGHT", -5, 40)
	local HEIGHT = scroll:GetHeight()

	local textBox = CreateFrame("EditBox", nil, scroll)
	scroll:SetScrollChild(textBox)
	textBox:SetMultiLine(true)
	textBox:SetAutoFocus(false)
	textBox:SetFontObject(ChatFontSmall)
	textBox:SetPoint("TOP")
	textBox:SetPoint("LEFT")
	textBox:SetPoint("RIGHT")
	textBox:SetHeight(1000)
	textBox:SetScript("OnEscapePressed", textBox.ClearFocus)
	textBox:SetScript("OnShow", function(self) self:SetFocus() end)

	local LINEHEIGHT, maxoffset, offset = 12, 0, 0
	local function doscroll(v)
		offset = math.max(math.min(v, 0), maxoffset)
		scroll:SetVerticalScroll(-offset)
		textBox:SetPoint("TOP", 0, offset)
	end

	textBox:SetScript("OnCursorChanged", function(self, x, y, width, height)
		LINEHIGHT = height
		if offset < y then
			doscroll(y)
		elseif math.floor(offset-HEIGHT + height*2) > y then
			local v = y + HEIGHT - height*2
			maxoffset = math.min(maxoffset, v)
			doscroll(v)
		end
	end)

	scroll:UpdateScrollChildRect()
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self,val) doscroll(offset + val*LINEHEIGHT*3) end)

	local sep1 = parent:CreateTexture()
	sep1:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep1:SetPoint("BOTTOM", scroll, "TOP", 0, 8)
	sep1:SetPoint("LEFT", parent, "LEFT", 10)
	sep1:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep1:SetHeight(3)

	local sep2 = parent:CreateTexture()
	sep2:SetTexture(0.25, 0.25, 0.25, 1.0)
	sep2:SetPoint("TOP", scroll, "BOTTOM", 0, -8)
	sep2:SetPoint("LEFT", parent, "LEFT", 10)
	sep2:SetPoint("RIGHT", parent, "RIGHT", -10)
	sep2:SetHeight(3)


	local importButton = LibStub("tekKonfig-Button").new(parent, "BOTTOMRIGHT", -5, 5)
	importButton:SetText("Import")

end

local function createOptionsPage(parent)
	local text2 = parent:CreateFontString()
	text2:SetFontObject(GameFontNormal)
	text2:SetAllPoints()
	text2:SetText("Options")
end

local function CreateMainFrame()
	mainFrame = LibStub("tekPanel").new("RaidInviteManagerMainFrame", "Raid Invite Manager")
	mainFrame:SetAttribute("UIPanelLayout-pushable", 5)

	-- Page 1
	local page1 = CreateFrame("Frame", nil, mainFrame)
	page1.title = "Manage Raid"
	page1:SetPoint("TOPLEFT", 22, -75)
	page1:SetPoint("BOTTOMRIGHT", -42, 81)
	CreateManagePage(page1)
	table.insert(pages, page1)
	local tab1Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab1", mainFrame, "CharacterFrameTabButtonTemplate")
	tab1Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 12, 78)
	tab1Button:SetText("Manage")
	tab1Button:SetScript("OnClick", function() setPage(1) end)

	-- Page 2
	local page2 = CreateFrame("Frame", nil, mainFrame)
	page2.title = "Import Roster"
	page2:SetPoint("TOPLEFT", 22, -75)
	page2:SetPoint("BOTTOMRIGHT", -42, 81)
	createImportPage(page2)
	table.insert(pages, page2)
	local tab2Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab2", mainFrame, "CharacterFrameTabButtonTemplate")
	tab2Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 75, 78)
	tab2Button:SetText("Import")
	tab2Button:SetScript("OnClick", function() setPage(2) end)

	-- Page 3
	local page3 = CreateFrame("Frame", nil, mainFrame)
	page3.title = "Options"
	page3:SetPoint("TOPLEFT", 22, -75)
	page3:SetPoint("BOTTOMRIGHT", -42, 81)
	createOptionsPage(page3)
	table.insert(pages, page3)
	local tab3Button = CreateFrame("Button", "RaidInviteManagerMainFrameTab3", mainFrame, "CharacterFrameTabButtonTemplate")
	tab3Button:SetPoint("TOPLEFT", mainFrame, "BOTTOMLEFT", 133, 78)
	tab3Button:SetText("Options")
	tab3Button:SetScript("OnClick", function() setPage(3) end)

	-- Top Page title FontString
	mainFrame.titleString = mainFrame:CreateFontString()
	mainFrame.titleString:SetFontObject(GameFontNormal)
	mainFrame.titleString:SetPoint("TOP", 0, -40)
	mainFrame.titleString:SetText("Manage")

	-- Final setup
	mainFrame:SetScript("OnShow", function() setPage(1) end)
	PanelTemplates_SetNumTabs(mainFrame, #pages);
end

function ns.ShowNewUI()
	if not mainFrame then
		CreateMainFrame()
	end
	ShowUIPanel(mainFrame)
end

