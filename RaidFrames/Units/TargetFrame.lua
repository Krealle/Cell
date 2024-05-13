local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local unit = "target"

-- TargetFrame
local targetFrame, anchorFrame, hoverFrame, config, menu = B:CreateBaseUnitFrame(unit, "Target Frame")
Cell.frames.targetFrame = targetFrame
Cell.frames.targetFrameAnchor = anchorFrame

local targetButton = CreateFrame("Button", "CellTargetButton", targetFrame, "CellUnitButtonTemplate")
targetButton:SetAttribute("unit", unit)
targetButton:SetPoint("TOPLEFT")
targetButton:RegisterEvent("PLAYER_TARGET_CHANGED")
targetButton:SetScript("OnEvent", function(self, event)
    -- Make sure we update target changes
      B.UpdateAll(self)
end)
targetButton:Show()
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
            RegisterAttributeDriver(targetButton, "state-visibility", "[@target,exists]show;hide")
        else
            UnregisterAttributeDriver(targetButton, "state-visibility")
            targetFrame:Hide()
        end
    end
  end
  Cell:RegisterCallback("UpdateVisibility", "TargetFrame_UpdateVisibility", TargetFrame_UpdateVisibility)