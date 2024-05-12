local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local menu
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY

-- PlayerFrame
local playerFrame = CreateFrame("Frame", "CellPlayerFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.playerFrame = playerFrame

-- Anchor
local anchorFrame = CreateFrame("Frame", "CellPlayerAnchorFrame", playerFrame)
Cell.frames.playerFrameAnchor = anchorFrame
PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

-- Hover
local hoverFrame = CreateFrame("Frame", nil, playerFrame, "BackdropTemplate")
hoverFrame:SetPoint("TOP", anchorFrame, 0, 1)
hoverFrame:SetPoint("BOTTOM", anchorFrame, 0, -1)
hoverFrame:SetPoint("LEFT", anchorFrame, -1, 0)
hoverFrame:SetPoint("RIGHT", anchorFrame, 1, 0)

A:ApplyFadeInOutToMenu(anchorFrame, hoverFrame)

local config = Cell:CreateButton(anchorFrame, nil, "accent", {20, 10}, false, true, nil, nil, "SecureHandlerAttributeTemplate,SecureHandlerClickTemplate")
config:SetFrameStrata("MEDIUM")
config:SetAllPoints(anchorFrame)
config:RegisterForDrag("LeftButton")
config:SetScript("OnDragStart", function()
    anchorFrame:StartMoving()
    anchorFrame:SetUserPlaced(false)
end)
config:SetScript("OnDragStop", function()
    anchorFrame:StopMovingOrSizing()
    P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable["player"]["position"])
end)
config:HookScript("OnEnter", function()
    hoverFrame:GetScript("OnEnter")(hoverFrame)
    CellTooltip:SetOwner(config, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)
    CellTooltip:AddLine(L["Player Frame"])
    CellTooltip:Show()
end)
config:HookScript("OnLeave", function()
    hoverFrame:GetScript("OnLeave")(hoverFrame)
    CellTooltip:Hide()
end)

local playerButton = CreateFrame("Button", "CellPlayerButton", playerFrame, "CellUnitButtonTemplate")
playerButton:SetAttribute("unit", "player")
playerButton:SetPoint("TOPLEFT")
playerButton:Show()
Cell.unitButtons.player["player"] = playerButton

menu = CreateFrame("Frame", "CellPlayerFrameMenu", playerFrame, "BackdropTemplate,SecureHandlerAttributeTemplate,SecureHandlerShowHideTemplate")
menu:SetFrameStrata("TOOLTIP")
menu:SetClampedToScreen(true)
menu:Hide()

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdatePosition()
    local layout = Cell.vars.currentLayoutTable
    
    local anchor
    if layout["player"]["sameArrangementAsMain"] then
        anchor = layout["main"]["anchor"]
    else
        anchor = layout["player"]["anchor"]
    end

    playerButton:ClearAllPoints()
    -- NOTE: detach from playerPreviewAnchor
    P:LoadPosition(anchorFrame, layout["player"]["position"])
    
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        
        if anchor == "BOTTOMLEFT" then
            playerButton:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "BOTTOMLEFT", 0, -3
        elseif anchor == "BOTTOMRIGHT" then
            playerButton:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "BOTTOMRIGHT", 0, -3
        elseif anchor == "TOPLEFT" then
            playerButton:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "TOPLEFT", 0, 3
        elseif anchor == "TOPRIGHT" then
            playerButton:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "TOPRIGHT", 0, 3
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            playerButton:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0
        elseif anchor == "BOTTOMRIGHT" then
            playerButton:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0
        elseif anchor == "TOPLEFT" then
            playerButton:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "TOPLEFT", -3, 0
        elseif anchor == "TOPRIGHT" then
            playerButton:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "TOPRIGHT", 3, 0
        end
    end
end

local function UpdateMenu(which)
    if not which or which == "lock" then
        if CellDB["general"]["locked"] then
            config:RegisterForDrag()
        else
            config:RegisterForDrag("LeftButton")
        end
    end

    if not which or which == "fadeOut" then
        if CellDB["general"]["fadeOut"] then
            anchorFrame.fadeOut:Play()
        else
            anchorFrame.fadeIn:Play()
        end
    end

    if which == "position" then
        UpdatePosition()
    end
end
Cell:RegisterCallback("UpdateMenu", "PlayerFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable

    -- Size
    if not which or strfind(which, "size$") then
        local width, height
        if layout["player"]["sameSizeAsMain"] then
            width, height = unpack(layout["main"]["size"])
        else
            width, height = unpack(layout["player"]["size"])
        end

        P:Size(playerButton, width, height)
    end

    -- Anchor points
    if not which or strfind(which, "arrangement$") then
        local anchor, spacingX, spacingY
        if layout["player"]["sameArrangementAsMain"] then
            anchor = layout["main"]["anchor"]
            spacingX = layout["main"]["spacingX"]
            spacingY = layout["main"]["spacingY"]
        else
            anchor = layout["player"]["anchor"]
            spacingX = layout["player"]["spacingX"]
            spacingY = layout["player"]["spacingY"]
        end

        -- anchors
        local point, anchorPoint, groupPoint, unitSpacingX, unitSpacingY
        local menuAnchorPoint, menuX, menuY
        
        if anchor == "BOTTOMLEFT" then
            point, anchorPoint = "BOTTOMLEFT", "TOPLEFT"
            groupPoint = "BOTTOMRIGHT"
            unitSpacingX = spacingX
            unitSpacingY = spacingY
            menuAnchorPoint = "BOTTOMRIGHT"
            menuX, menuY = 4, 0
        elseif anchor == "BOTTOMRIGHT" then
            point, anchorPoint = "BOTTOMRIGHT", "TOPRIGHT"
            groupPoint = "BOTTOMLEFT"
            unitSpacingX = -spacingX
            unitSpacingY = spacingY
            menuAnchorPoint = "BOTTOMLEFT"
            menuX, menuY = -4, 0
        elseif anchor == "TOPLEFT" then
            point, anchorPoint = "TOPLEFT", "BOTTOMLEFT"
            groupPoint = "TOPRIGHT"
            unitSpacingX = spacingX
            unitSpacingY = -spacingY
            menuAnchorPoint = "TOPRIGHT"
            menuX, menuY = 4, 0
        elseif anchor == "TOPRIGHT" then
            point, anchorPoint = "TOPRIGHT", "BOTTOMRIGHT"
            groupPoint = "TOPLEFT"
            unitSpacingX = -spacingX
            unitSpacingY = -spacingY
            menuAnchorPoint = "TOPLEFT"
            menuX, menuY = -4, 0
        end
        
        menu:SetAttribute("point", point)
        menu:SetAttribute("anchorPoint", menuAnchorPoint)
        menu:SetAttribute("xOffset", menuX)
        menu:SetAttribute("yOffset", menuY)
        menu:Hide()

        playerButton:ClearAllPoints()

        playerButton:SetPoint(point, anchorFrame, anchorPoint, 0, unitSpacingY)

        UpdatePosition()
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        B:SetOrientation(playerButton, layout["barOrientation"][1], layout["barOrientation"][2])
    end

    if not which or strfind(which, "power$") or which == "barOrientation" then
        if layout["player"]["sameSizeAsMain"] then
            B:SetPowerSize(playerButton, layout["main"]["powerSize"])
        else
            B:SetPowerSize(playerButton, layout["player"]["powerSize"])
        end
    end

    if not which or which == "player" then
        if layout["player"]["enabled"] then
            playerFrame:Show()
        else
            playerFrame:Hide()
            menu:Hide()
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout["player"]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end
Cell:RegisterCallback("UpdateLayout", "PlayerFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(playerFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "PlayerFrame_UpdatePixelPerfect", UpdatePixelPerfect)