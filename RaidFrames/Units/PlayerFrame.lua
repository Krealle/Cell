local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local unit = "player"

-- PlayerFrame
local playerFrame, anchorFrame, hoverFrame, config = B:CreateBaseUnitFrame(unit, "Player Frame")
Cell.frames.playerFrame = playerFrame
Cell.frames.playerFrameAnchor = anchorFrame

local playerButton = CreateFrame("Button", "CellPlayerButton", playerFrame, "CellUnitButtonTemplate")
playerButton:SetAttribute("unit", unit)
playerButton:SetPoint("TOPLEFT")
playerButton:Show()
Cell.unitButtons.player[unit] = playerButton

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdateMenu(which)
    B:UpdateUnitButtonMenu(which, unit, playerButton, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "PlayerFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(_, which)
    B:UpdateUnitButtonLayout(unit, which, playerButton, anchorFrame)
end
Cell:RegisterCallback("UpdateLayout", "PlayerFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(playerFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PlayerFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function PlayerFrame_UpdateVisibility(which)
    if not which or which == unit then
        if Cell.vars.currentLayoutTable[unit]["enabled"] then
            RegisterAttributeDriver(playerFrame, "state-visibility")
        else
            UnregisterAttributeDriver(playerFrame, "state-visibility")
            playerFrame:Hide()
        end
    end
end
Cell:RegisterCallback("UpdateVisibility", "PlayerFrame_UpdateVisibility", PlayerFrame_UpdateVisibility)