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
focusButton:HookScript("OnEvent", function(self,event) 
    -- This is a lil hack to get around the OnUpdate throttle
    -- This frame should always be fully refreshed when focus changes
    if event == "PLAYER_FOCUS_CHANGED" then focusButton:Hide() end
end)
Cell.unitButtons.focus[unit] = focusButton

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
        else
            UnregisterUnitWatch(focusButton)
            focusFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "FocusFrame_UpdateVisibility", FocusFrame_UpdateVisibility)