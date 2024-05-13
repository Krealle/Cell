local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local unit = "target"

local targetFrame, anchorFrame, hoverFrame, config, menu = B:CreateBaseUnitFrame(unit, "Target Frame")
Cell.frames.targetFrame = targetFrame
Cell.frames.targetFrameAnchor = anchorFrame

local targetButton = CreateFrame("Button", "CellTargetButton", targetFrame, "CellUnitButtonTemplate")
targetButton:SetAttribute("unit", unit)
targetButton:SetPoint("TOPLEFT")
targetButton:HookScript("OnEvent", function(self,event) 
    -- This is a lil hack to get around the OnUpdate throttle
    -- This frame should always be fully refreshed when focus changes
    if event == "PLAYER_TARGET_CHANGED" then targetButton:Hide() end
end)
Cell.unitButtons.target[unit] = targetButton

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdateMenu(which)
    B:UpdateUnitFrameMenu(which, unit, targetFrame, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "TargetFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(_, which)
    B:UpdateUnitFrameLayout(unit, which, targetFrame, anchorFrame, targetButton, menu)
end
Cell:RegisterCallback("UpdateLayout", "TargetFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(targetFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "TargetFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function TargetFrame_UpdateVisibility(which)
    if not which or which == unit then
        if Cell.vars.currentLayoutTable[unit]["enabled"] then
            RegisterUnitWatch(targetButton)
        else
            UnregisterUnitWatch(targetButton)
            targetFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "TargetFrame_UpdateVisibility", TargetFrame_UpdateVisibility)