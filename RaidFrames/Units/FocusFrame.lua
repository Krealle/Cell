local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local unit = "focus"

local focusFrame, anchorFrame, hoverFrame, config, menu = B:CreateBaseUnitFrame(unit, "Focus Frame")
Cell.frames.focusFrame = focusFrame
Cell.frames.focusFrameAnchor = anchorFrame

local focusButton = CreateFrame("Button", "CellFocusButton", focusFrame, "CellUnitButtonTemplate")
focusButton:SetAttribute("unit", unit)
focusButton:SetPoint("TOPLEFT")
Cell.unitButtons.focus[unit] = focusButton

-- Make sure we update frame info when focus target changes
-- This is needed to prevent getting a delayed frame update
local targetListener = CreateFrame("FRAME", "CellFocusButtonTargetListener")
targetListener:SetScript("OnEvent", function() B.UpdateAll(focusButton) end)

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdateMenu(which)
    B:UpdateUnitFrameMenu(which, unit, focusFrame, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "FocusFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(_, which)
    B:UpdateUnitFrameLayout(unit, which, focusFrame, anchorFrame, focusButton, menu)
end
Cell:RegisterCallback("UpdateLayout", "FocusFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(focusFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "FocusFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function FocusFrame_UpdateVisibility(which)
    if not which or which == unit then
        if Cell.vars.currentLayoutTable[unit]["enabled"] then
            RegisterUnitWatch(focusButton)
            targetListener:RegisterEvent("PLAYER_FOCUS_CHANGED")
        else
            UnRegisterUnitWatch(focusButton)
            targetListener:UnRegisterEvent("PLAYER_FOCUS_CHANGED")
            focusFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "FocusFrame_UpdateVisibility", FocusFrame_UpdateVisibility)