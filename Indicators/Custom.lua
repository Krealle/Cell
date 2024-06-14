local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs

-------------------------------------------------
-- custom indicators
-------------------------------------------------
local enabledIndicators = {}
local customIndicators = {
    ["buff"] = {},
    ["debuff"] = {},
}

local enabledUnitIndicators = {
    ["Player"] = {},
    ["Target"] = {},
    ["Focus"] = {}
}
local customUnitIndicators = {
    ["Player"] = {
        ["buff"] = {},
        ["debuff"] = {},
    },
    ["Target"] = {
        ["buff"] = {},
        ["debuff"] = {},
    },
    ["Focus"] = {
        ["buff"] = {},
        ["debuff"] = {},
    }
}

Cell.snippetVars.enabledIndicators = enabledIndicators
Cell.snippetVars.customIndicators = customIndicators

--! init enabledIndicators & customIndicators
local function UpdateTablesForIndicator(indicatorTable, layout)
    local indicatorName = indicatorTable["indicatorName"]
    local auraType = indicatorTable["auraType"]

    -- keep custom indicators in table
    if indicatorTable["enabled"] then 
        if layout then
            enabledUnitIndicators[layout][indicatorName] = true
        else
            enabledIndicators[indicatorName] = true 
        end    
    end

    local indicator
    if layout then
        indicator = customUnitIndicators[layout][auraType]
    else
        indicator = customIndicators[auraType]
    end

    -- NOTE: icons is different from other custom indicators, more like the Debuffs indicator
    if indicatorTable["type"] == "icons" then
        indicator[indicatorName] = {
            ["auras"] = F:ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["isIcons"] = true,
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    elseif indicatorTable["type"] == "blocks" then
        indicator[indicatorName] = {
            ["auras"] = F:ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["isBlocks"] = true,
            ["found"] = {},
            ["num"] = indicatorTable["num"],
        }
    else
        indicator[indicatorName] = {
            ["auras"] = F:ConvertSpellTable(indicatorTable["auras"], indicatorTable["trackByName"]), -- auras to match
            ["top"] = {}, -- top aura details
            ["topOrder"] = {}, -- top aura order
        }
    end

    if auraType == "buff" then
        indicator[indicatorName]["castBy"] = indicatorTable["castBy"]
        indicator[indicatorName]["_auras"] = F:Copy(indicatorTable["auras"]) --* save ids
        indicator[indicatorName]["trackByName"] = indicatorTable["trackByName"]
    end
end

function I.CreateIndicator(parent, indicatorTable, noTableUpdate)
    local indicatorName = indicatorTable["indicatorName"]
    local indicator
    if indicatorTable["type"] == "icon" then
        indicator = I.CreateAura_BarIcon(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "text" then
        indicator = I.CreateAura_Text(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "bar" then
        indicator = I.CreateAura_Bar(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "rect" then
        indicator = I.CreateAura_Rect(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "icons" then
        indicator = I.CreateAura_Icons(parent:GetName()..indicatorName, parent.widgets.overlayFrame, 10)
    elseif indicatorTable["type"] == "color" then
        indicator = I.CreateAura_Color(parent:GetName()..indicatorName, parent)
    elseif indicatorTable["type"] == "texture" then
        indicator = I.CreateAura_Texture(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "glow" then
        indicator = I.CreateAura_Glow(parent:GetName()..indicatorName, parent)
    elseif indicatorTable["type"] == "overlay" then
        indicator = I.CreateAura_Overlay(parent:GetName()..indicatorName, parent)
    elseif indicatorTable["type"] == "block" then
        indicator = I.CreateAura_Block(parent:GetName()..indicatorName, parent.widgets.overlayFrame)
    elseif indicatorTable["type"] == "blocks" then
        indicator = I.CreateAura_Blocks(parent:GetName()..indicatorName, parent.widgets.overlayFrame, 10)
    end
    parent.indicators[indicatorName] = indicator

    if not noTableUpdate then
        local layout = parent._layout or nil
        UpdateTablesForIndicator(indicatorTable, layout)
    end

    return indicator
end

function I.RemoveIndicator(parent, indicatorName, auraType)
    local indicator = parent.indicators[indicatorName]
    indicator:ClearAllPoints()
    indicator:Hide()
    indicator:SetParent(nil)
    parent.indicators[indicatorName] = nil

    local layout = parent._layout or nil
    if layout then
        enabledUnitIndicators[layout][indicatorName] = nil
        customUnitIndicators[layout][auraType][indicatorName] = nil
    else
        enabledIndicators[indicatorName] = nil
        customIndicators[auraType][indicatorName] = nil
    end
end

-- used for switching to a new layout
function I.RemoveAllCustomIndicators(parent)
    -- if parent ~= CellIndicatorsPreviewButton then
    --     wipe(enabledIndicators)
    --     wipe(customIndicators["buff"])
    --     wipe(customIndicators["debuff"])
    -- end

    for indicatorName, indicator in pairs(parent.indicators) do
        if string.find(indicatorName, "^indicator") then
            indicator:ClearAllPoints()
            indicator:Hide()
            indicator:SetParent(nil)
            parent.indicators[indicatorName] = nil
        end
    end
end

function I.ResetCustomIndicatorTables(isUnitReset)
    -- clear
    if not isUnitReset then
        wipe(enabledIndicators)
        wipe(customIndicators["buff"])
        wipe(customIndicators["debuff"])

        -- update customs
        for i = Cell.defaults.builtIns + 1, #Cell.vars.currentLayoutTable.indicators do
            UpdateTablesForIndicator(Cell.vars.currentLayoutTable.indicators[i])
        end
    else
        for layout, layoutTable in pairs(customUnitIndicators) do
            wipe(enabledUnitIndicators[layout])
            wipe(layoutTable["buff"])
            wipe(layoutTable["debuff"])

            -- update customs
            local layoutTable = CellDB["layouts"][layout]
            for i = Cell.defaults.builtIns + 1, #layoutTable.indicators do
                UpdateTablesForIndicator(layoutTable.indicators[i], layout)
            end
        end
    end    
end

local function UpdateCustomUnitIndicators(layout, indicatorName, setting, value, value2)
    if layout and layout ~= "Player" and layout ~= "Target" and layout ~= "Focus" then return end

    if not indicatorName or not string.find(indicatorName, "^indicator") then return end

    if not layout then return F:Debug("UpdateCustomUnitIndicators: no layout", indicatorName, setting, value, value2) end

    if setting == "enabled" then
        if value then
            enabledUnitIndicators[layout][indicatorName] = true
        else
            enabledUnitIndicators[layout][indicatorName] = nil
        end
    elseif setting == "auras" then
        customUnitIndicators[layout][value][indicatorName]["_auras"] = F:Copy(value2) --* save ids
        customUnitIndicators[layout][value][indicatorName]["auras"] = F:ConvertSpellTable(value2, customUnitIndicators[layout][value][indicatorName]["trackByName"])
    elseif setting == "checkbutton" then
        if customUnitIndicators[layout]["buff"][indicatorName] then
            customUnitIndicators[layout]["buff"][indicatorName][value] = value2
            if value == "trackByName" then
                customUnitIndicators[layout]["buff"][indicatorName]["auras"] = F:ConvertSpellTable(customUnitIndicators[layout]["buff"][indicatorName]["_auras"], value2)
            end
        elseif customUnitIndicators[layout]["debuff"][indicatorName] then
            customUnitIndicators[layout]["debuff"][indicatorName][value] = value2
        end
    else -- num, castBy
        if customUnitIndicators[layout]["buff"][indicatorName] then
            customUnitIndicators[layout]["buff"][indicatorName][setting] = value
        elseif customUnitIndicators[layout]["debuff"][indicatorName] then
            customUnitIndicators[layout]["debuff"][indicatorName][setting] = value
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomUnitIndicators", UpdateCustomUnitIndicators)

local function UpdateCustomIndicators(layout, indicatorName, setting, value, value2)
    if layout and layout ~= Cell.vars.currentLayout then return end

    if not indicatorName or not string.find(indicatorName, "^indicator") then return end

    if setting == "enabled" then
        if value then
            enabledIndicators[indicatorName] = true
        else
            enabledIndicators[indicatorName] = nil
        end
    elseif setting == "auras" then
        customIndicators[value][indicatorName]["_auras"] = F:Copy(value2) --* save ids
        customIndicators[value][indicatorName]["auras"] = F:ConvertSpellTable(value2, customIndicators[value][indicatorName]["trackByName"])
    elseif setting == "checkbutton" then
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName][value] = value2
            if value == "trackByName" then
                customIndicators["buff"][indicatorName]["auras"] = F:ConvertSpellTable(customIndicators["buff"][indicatorName]["_auras"], value2)
            end
        elseif customIndicators["debuff"][indicatorName] then
            customIndicators["debuff"][indicatorName][value] = value2
        end
    else -- num, castBy
        if customIndicators["buff"][indicatorName] then
            customIndicators["buff"][indicatorName][setting] = value
        elseif customIndicators["debuff"][indicatorName] then
            customIndicators["debuff"][indicatorName][setting] = value
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "UpdateCustomIndicators", UpdateCustomIndicators)

-------------------------------------------------
-- reset
-------------------------------------------------
function I.ResetCustomIndicators(unitButton, auraType)
    local unit = unitButton.states.displayedUnit

    local layout = unitButton._layout or nil
    local auraIndicators, enabled
    if layout then 
        auraIndicators = customUnitIndicators[layout][auraType]
        enabled = enabledUnitIndicators[layout]
    else
        auraIndicators = customIndicators[auraType]
        enabled = enabledIndicators
    end

    for indicatorName, indicatorTable in pairs(auraIndicators) do
        if enabled[indicatorName] and unitButton.indicators[indicatorName] then
            unitButton.indicators[indicatorName]:Hide(true)
            if indicatorTable["isIcons"] or indicatorTable["isBlocks"] then
                if not indicatorTable["found"][unit] then
                    indicatorTable["found"][unit] = {}
                else
                    wipe(indicatorTable["found"][unit])
                end
            else
                indicatorTable["topOrder"][unit] = 999
                if not indicatorTable["top"][unit] then
                    indicatorTable["top"][unit] = {}
                else
                    wipe(indicatorTable["top"][unit])
                end
            end
        end
    end
end

-------------------------------------------------
-- update
-------------------------------------------------
local function Update(indicator, indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
    if indicatorTable["isIcons"] or indicatorTable["isBlocks"] then
        tinsert(indicatorTable["found"][unit], {indicatorTable["auras"][spell], start, duration, debuffType, icon, count, refreshing})
    else
        if indicatorTable["auras"][spell] < indicatorTable["topOrder"][unit] then
            indicatorTable["topOrder"][unit] = indicatorTable["auras"][spell]
            indicatorTable["top"][unit]["start"] = start
            indicatorTable["top"][unit]["duration"] = duration
            indicatorTable["top"][unit]["debuffType"] = debuffType
            indicatorTable["top"][unit]["texture"] = icon
            indicatorTable["top"][unit]["count"] = count
            indicatorTable["top"][unit]["refreshing"] = refreshing
        end
    end
end

function I.UpdateCustomIndicators(unitButton, auraInfo, refreshing)
    local unit = unitButton.states.displayedUnit

    local auraType = auraInfo.isHelpful and "buff" or "debuff"
    local icon = auraInfo.icon
    local debuffType = auraInfo.isHarmful and (auraInfo.dispelName or "")
    local count = auraInfo.applications
    local duration = auraInfo.duration
    local start = (auraInfo.expirationTime or 0) - auraInfo.duration
    local spellId = auraInfo.spellId
    local spellName = auraInfo.name
    local castByMe = auraInfo.sourceUnit == "player" or auraInfo.sourceUnit == "pet"

    -- check Bleed
    if auraInfo.isHarmful then
        debuffType = I.CheckDebuffType(debuffType, spellId)
    end

    local layout = unitButton._layout or nil
    local auraIndicators, enabled
    if layout then 
        auraIndicators = customUnitIndicators[layout][auraType]
        enabled = enabledUnitIndicators[layout]
    else
        auraIndicators = customIndicators[auraType]
        enabled = enabledIndicators
    end

    for indicatorName, indicatorTable in pairs(auraIndicators) do
        if indicatorName and enabled[indicatorName] and unitButton.indicators[indicatorName] then
            local spell  --* trackByName
            if indicatorTable["trackByName"] then
                spell = spellName
            else
                spell = spellId
            end

            if indicatorTable["auras"][spell] or (indicatorTable["auras"][0] and duration ~= 0) then -- is in indicator spell list
                if auraType == "buff" then
                    -- check caster
                    if (indicatorTable["castBy"] == "me" and castByMe) or (indicatorTable["castBy"] == "others" and not castByMe) or (indicatorTable["castBy"] == "anyone") then
                        Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                    end
                else -- debuff
                    Update(unitButton.indicators[indicatorName], indicatorTable, unit, spell, start, duration, debuffType, icon, count, refreshing)
                end
            end
        end
    end
end

-------------------------------------------------
-- show
-------------------------------------------------
local sort = table.sort
local function comparator(a, b)
    return a[1] < b[1]
end

function I.ShowCustomIndicators(unitButton, auraType)
    local unit = unitButton.states.displayedUnit

    local layout = unitButton._layout or nil
    local auraIndicators, enabled
    if layout then 
        auraIndicators = customUnitIndicators[layout][auraType]
        enabled = enabledUnitIndicators[layout]
    else
        auraIndicators = customIndicators[auraType]
        enabled = enabledIndicators
    end

    for indicatorName, indicatorTable in pairs(auraIndicators) do
        if indicatorName and enabled[indicatorName] then
            local indicator = unitButton.indicators[indicatorName]
            if indicatorTable["isIcons"] or indicatorTable["isBlocks"] then
                local t = indicatorTable["found"][unit]
                sort(t, comparator)
                for i = 1, indicatorTable["num"] do
                    if not t[i] then break end
                    indicator[i]:SetCooldown(t[i][2], t[i][3], t[i][4], t[i][5], t[i][6], t[i][7])
                    indicator:Show()
                end
                indicator:UpdateSize(#t)
            else
                if indicatorTable["top"][unit]["start"] then
                    indicator:SetCooldown(
                        indicatorTable["top"][unit]["start"],
                        indicatorTable["top"][unit]["duration"],
                        indicatorTable["top"][unit]["debuffType"],
                        indicatorTable["top"][unit]["texture"],
                        indicatorTable["top"][unit]["count"],
                        indicatorTable["top"][unit]["refreshing"])
                end
            end
        end
    end
end