local _, Cell = ...
local L = Cell.L
local F = Cell.funcs

local indicatorsTab = Cell:CreateFrame("CellOptionsFrame_IndicatorsTab", Cell.frames.optionsFrame, nil, nil, true)
Cell.frames.indicatorsTab = indicatorsTab
indicatorsTab:SetAllPoints(Cell.frames.optionsFrame)

local loaded, currentLayout, currentLayoutTable

local function CreateIndicator(name)

end

local function Incators_OnUpdate()

end

local function UpdateIndicators()

end

-------------------------------------------------
-- preview
-------------------------------------------------
local previewText = Cell:CreateSeparator(L["Preview"], indicatorsTab, 255)
previewText:SetPoint("TOPLEFT", 137, -5)
previewText:SetJustifyH("LEFT")

local previewButton = CreateFrame("Button", "IndicatorPreviewButton", indicatorsTab, "CellUnitButtonTemplate")
-- previewButton:SetPoint("TOPLEFT", indicatorsTab, 137, -32)
previewButton:SetPoint("CENTER", indicatorsTab, "TOPLEFT", 265, -70)
previewButton:UnregisterAllEvents()
previewButton:SetScript("OnEnter", nil)
previewButton:SetScript("OnLeave", nil)
previewButton:SetScript("OnShow", nil)
previewButton:SetScript("OnHide", nil)
previewButton:SetScript("OnUpdate", nil)
F:CreateDebuffs(previewButton)
F:CreateExternalCooldowns(previewButton)
previewButton:Show()

local function UpdatePreviewButton()
    if not previewButton.loaded then
        previewButton.loaded = true
        
        previewButton.widget.healthBar:SetStatusBarColor(F:GetClassColor(Cell.vars.playerClass))
        local r, g, b = F:GetPowerColor("player")
        previewButton.widget.powerBar:SetStatusBarColor(r, g, b)
        
        local name = UnitName("player")
        previewButton.widget.nameText:SetText(name)

        previewButton:SetScript("OnSizeChanged", function(self)
            F:SetTextLimitWidth(self.widget.nameText, name, 0.75)
        end)
    end

    previewButton:SetSize(unpack(Cell.vars.currentLayoutTable["size"]))
    previewButton.widget.healthBar:SetStatusBarTexture(Cell.vars.texture)
    previewButton.widget.powerBar:SetStatusBarTexture(Cell.vars.texture)
end

-- init preview button indicator animation
local function InitIndicator(indicatorName)
    local indicator = previewButton.indicators[indicatorName]
    if indicator.init == true then return end

    if indicatorName == "aggroBar" then
        indicator:SetStatusBarColor(1, 0, 0)
        indicator.value = 0
        indicator:SetScript("OnUpdate", function(self, elapsed)
            if self.value >= 100 then
                self.value = 0
            else
                self.value = self.value + 1
            end
            self:SetValue(self.value)
        end)

    elseif indicatorName == "debuffs" then
        local types = {"", "Curse", "Disease", "Magic", "Poison"}
        local icons = {132155, 136139, 136128, 136071, 136182}
        local stacks = {7, 10, 0, 0, 2}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 7, types[i], icons[i], stacks[i])
                indicator[i].cooldown.value = 0
                indicator[i].cooldown:SetScript("OnUpdate", function(self, elapsed)
                    if self.value >= 7 then
                        self.value = 0
                    else
                        self.value = self.value + elapsed
                    end
                    self:SetValue(self.value)
                end)
            end)
            -- indicator[i]:SetScript("OnHide", function()
            --     indicator[i].cooldown:Hide()
            --     indicator[i].cooldown:SetScript("OnValueChanged", nil)
            -- end)
            -- indicator[i]:SetScript("OnShow", function()
            --     indicator[i]:SetCooldown(GetTime(), 10, types[i], "Interface\\Icons\\INV_Misc_QuestionMark")
            --     indicator[i].cooldown:SetScript("OnCooldownDone", function()
            --         indicator[i].cooldown:SetCooldownDuration(10)
            --         -- indicator[i]:SetCooldown(0,0,types[i], "Interface\\Icons\\INV_Misc_QuestionMark")
            --     end)
            -- end)
            -- indicator[i]:SetScript("OnHide", function()
            --     indicator[i].cooldown:Hide()
            --     indicator[i].cooldown:SetScript("OnCooldownDone", nil)
            -- end)
        end
    elseif indicatorName == "externalCooldowns" then
        local icons = {135936, 572025, 135966, 627485, 237542}
        for i = 1, 5 do
            indicator[i]:SetScript("OnShow", function()
                indicator[i]:SetCooldown(GetTime(), 7, nil, icons[i], 0)
                indicator[i].cooldown.value = 0
                indicator[i].cooldown:SetScript("OnUpdate", function(self, elapsed)
                    if self.value >= 7 then
                        self.value = 0
                    else
                        self.value = self.value + elapsed
                    end
                    self:SetValue(self.value)
                end)
            end)
        end
    end
    indicator.init = true
end

local function UpdateIndicators(indicatorName, setting, value)
	if not indicatorName then -- init
		for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
            local indicator = previewButton.indicators[t["indicatorName"]]
            if indicator then -- TODO: remove
                if t["enabled"] then
                    indicator:Show()
                    InitIndicator(t["indicatorName"])
                end

                -- update position
                indicator:ClearAllPoints()
                indicator:SetPoint(t["position"][1], previewButton, t["position"][2], t["position"][3], t["position"][4])
                -- update size
                indicator:SetSize(unpack(t["size"]))
                -- update debuffs num
                for i, frame in ipairs(indicator) do
                    if i <= t["num"] then
                        frame:Show()
                    else
                        frame:Hide()
                    end
                end
                -- update font
                if t["font"] then
                    indicator:SetFont(unpack(t["font"]))
                end
            end
		end
	else
        local indicator = previewButton.indicators[indicatorName]
		-- changed in IndicatorsTab
		if setting == "enabled" then
            if value then
                indicator:Show()
                InitIndicator(indicatorName)
            else
                indicator:Hide()
            end
		elseif setting == "position" then
			indicator:ClearAllPoints()
			indicator:SetPoint(value[1], previewButton, value[2], value[3], value[4])
		elseif setting == "size" then
            indicator:SetSize(unpack(value))
        elseif setting == "num" then
            for i, frame in ipairs(indicator) do
                if i <= value then
                    frame:Show()
                else
                    frame:Hide()
                end
            end
        elseif setting == "font" then
            indicator:SetFont(unpack(value))
        end
	end
end
Cell:RegisterCallback("UpdateIndicators", "PreviewButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- current layout
-------------------------------------------------
local currentLayoutText = indicatorsTab:CreateFontString(nil, "OVERLAY", "CELL_FONT_WIDGET_TITLE")
currentLayoutText:SetJustifyH("LEFT")
currentLayoutText:SetPoint("LEFT", previewText, "RIGHT", 5, 0)

local function UpdateCurrentLayoutText()
    currentLayoutText:SetText("|cFF777777"..L["Current Layout"]..": "..currentLayout)
end

-------------------------------------------------
-- indicator list
-------------------------------------------------
local listText = Cell:CreateSeparator(L["Indicators"], indicatorsTab, 122)
listText:SetPoint("TOPLEFT", 5, -5)
listText:SetJustifyH("LEFT")

local listFrame = Cell:CreateFrame("IndicatorsTab_ListFrame", indicatorsTab)
listFrame:SetPoint("TOPLEFT", 5, -32)
listFrame:SetPoint("BOTTOMRIGHT", indicatorsTab, "BOTTOMLEFT", 127, 7)
listFrame:Show()

Cell:CreateScrollFrame(listFrame)
listFrame.scrollFrame:SetScrollStep(19)

local listButtons = {}

-------------------------------------------------
-- indicator settings
-------------------------------------------------
local settingsText = Cell:CreateSeparator(L["Indicator Settings"], indicatorsTab, 255)
settingsText:SetPoint("TOPLEFT", 137, -129)
settingsText:SetJustifyH("LEFT")

-------------------------------------------------
-- settings frame
-------------------------------------------------
local settingsFrame = Cell:CreateFrame("IndicatorsTab_SettingsFrame", indicatorsTab, 10, 10, true)
settingsFrame:SetPoint("TOPLEFT", settingsText, "BOTTOMLEFT", 0, -10)
settingsFrame:SetPoint("BOTTOMRIGHT", indicatorsTab, -5, 7)
settingsFrame:Show()

Cell:CreateScrollFrame(settingsFrame)
settingsFrame.scrollFrame:SetScrollStep(35)

local indicatorSettings = {
    ["aggroBar"] = {"enabled", "position", "size"},
    ["externalCooldowns"] = {"enabled", "position", "size", "num"},
    ["defensiveCooldowns"] = {"enabled", "position", "size", "num"},
    ["tankActiveMitigation"] = {"enabled", "position", "size"},
    ["debuffs"] = {"enabled", "position", "size-square", "num", "font"},
    ["centralDebuff"] = {"enabled", "position", "size-square", "font"},
}

local function ShowIndicatorSettings(id)
    settingsFrame.scrollFrame:ResetScroll()
    settingsFrame.scrollFrame:ResetHeight()

    local indicatorName = currentLayoutTable["indicators"][id]["indicatorName"]
    local widgets = Cell:CreateIndicatorSettings(settingsFrame.scrollFrame.content, indicatorSettings[indicatorName])
    
    local last
    for i, w in pairs(widgets) do
        if last then
            w:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -7)
        else
            w:SetPoint("TOPLEFT")
        end
        w:SetPoint("RIGHT")
        last = w

        -- "enabled", "position", "size", "num", "font"
        local currentSetting = indicatorSettings[indicatorName][i]
        if currentSetting == "size-square" then currentSetting = "size" end

        -- echo
        w:SetDBValue(currentLayoutTable["indicators"][id][currentSetting])

        -- update func
        w:SetFunc(function(value)
            -- texplore(value)
            Cell.vars.currentLayoutTable["indicators"][id][currentSetting] = value
            Cell:Fire("UpdateIndicators", indicatorName, currentSetting, value)
            -- show enabled/disabled status
            if type(value) == "boolean" then
                if value then
                    listButtons[id]:SetTextColor(1, 1, 1, 1)
                else
                    listButtons[id]:SetTextColor(.466, .466, .466, 1)
                end
            end
        end)
    end
end

local function LoadIndicatorList()
    F:Debug("LoadIndicatorList: "..currentLayout)
    listFrame.scrollFrame:Reset()
    wipe(listButtons)

    local last
    for i, t in pairs(currentLayoutTable["indicators"]) do
        local b = Cell:CreateButton(listFrame.scrollFrame.content, t["name"], "transparent-class", {20, 20})
        tinsert(listButtons, b)
        b.id = i

        -- show enabled/disabled status
        if t["enabled"] then
            b:SetTextColor(1, 1, 1, 1)
        else
            b:SetTextColor(.466, .466, .466, 1)
        end

        b:SetPoint("RIGHT")
        if last then
            b:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 1)
        else
            b:SetPoint("TOPLEFT")
        end
        last = b
    end

    Cell:CreateButtonGroup(ShowIndicatorSettings, listButtons)
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function ShowTab(tab)
    if tab == "indicators" then
        indicatorsTab:Show()
        UpdatePreviewButton()
        
        if currentLayout == Cell.vars.currentLayout then return end
        currentLayout = Cell.vars.currentLayout
        currentLayoutTable = Cell.vars.currentLayoutTable

        UpdateCurrentLayoutText()
        LoadIndicatorList()
        -- texplore(previewButton)
    else
        indicatorsTab:Hide()
    end
end
Cell:RegisterCallback("ShowOptionsTab", "IndicatorsTab_ShowTab", ShowTab)