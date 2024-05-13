local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local unit = "player"

-- PlayerFrame
local playerFrame, anchorFrame, hoverFrame, config, menu = B:CreateBaseUnitFrame(unit, "Player Frame")
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
    B:UpdateUnitFrameMenu(which, unit, playerFrame, anchorFrame, config)
end
Cell:RegisterCallback("UpdateMenu", "PlayerFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(_, which)
    B:UpdateUnitFrameLayout(unit, which, playerFrame, anchorFrame, playerButton, menu)
end
Cell:RegisterCallback("UpdateLayout", "PlayerFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(playerFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PlayerFrame_UpdatePixelPerfect", UpdatePixelPerfect)