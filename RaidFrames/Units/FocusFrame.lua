local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local B = Cell.bFuncs
local A = Cell.animations
local P = Cell.pixelPerfectFuncs

local menu
local tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY

-- FocusFrame
local focusFrame = CreateFrame("Frame", "CellFocusFrame", Cell.frames.mainFrame, "SecureFrameTemplate")
Cell.frames.focusFrame = focusFrame

-- Anchor
local anchorFrame = CreateFrame("Frame", "CellFocusAnchorFrame", focusFrame)
Cell.frames.focusFrameAnchor = anchorFrame
PixelUtil.SetPoint(anchorFrame, "TOPLEFT", UIParent, "CENTER", 1, -1)
anchorFrame:SetMovable(true)
anchorFrame:SetClampedToScreen(true)

-- Hover
local hoverFrame = CreateFrame("Frame", nil, focusFrame, "BackdropTemplate")
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
    P:SavePosition(anchorFrame, Cell.vars.currentLayoutTable["focus"]["position"])
end)
config:HookScript("OnEnter", function()
    hoverFrame:GetScript("OnEnter")(hoverFrame)
    CellTooltip:SetOwner(config, "ANCHOR_NONE")
    CellTooltip:SetPoint(tooltipPoint, config, tooltipRelativePoint, tooltipX, tooltipY)
    CellTooltip:AddLine(L["Focus Frame"])
    CellTooltip:Show()
end)
config:HookScript("OnLeave", function()
    hoverFrame:GetScript("OnLeave")(hoverFrame)
    CellTooltip:Hide()
end)

local focusButton = CreateFrame("Button", "CellFocusButton", focusFrame, "CellUnitButtonTemplate")
focusButton:SetAttribute("unit", "focus")
focusButton:SetPoint("TOPLEFT")
focusButton:RegisterEvent("PLAYER_FOCUS_CHANGED")
focusButton:SetScript("OnEvent", function(self,event)
    -- Make sure we update target changes
      B.UpdateAll(self)
end)
focusButton:Show()
Cell.unitButtons.focus["focus"] = focusButton

menu = CreateFrame("Frame", "CellFocusFrameMenu", focusFrame, "BackdropTemplate,SecureHandlerAttributeTemplate,SecureHandlerShowHideTemplate")
menu:SetFrameStrata("TOOLTIP")
menu:SetClampedToScreen(true)
menu:Hide()

-------------------------------------------------
-- callbacks
-------------------------------------------------
local function UpdatePosition()
    local layout = Cell.vars.currentLayoutTable
    
    local anchor
    if layout["focus"]["sameArrangementAsMain"] then
        anchor = layout["main"]["anchor"]
    else
        anchor = layout["focus"]["anchor"]
    end

    focusButton:ClearAllPoints()
    -- NOTE: detach from focusPreviewAnchor
    P:LoadPosition(anchorFrame, layout["focus"]["position"])
    
    if CellDB["general"]["menuPosition"] == "top_bottom" then
        P:Size(anchorFrame, 20, 10)
        
        if anchor == "BOTTOMLEFT" then
            focusButton:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPLEFT", "BOTTOMLEFT", 0, -3
        elseif anchor == "BOTTOMRIGHT" then
            focusButton:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "BOTTOMRIGHT", 0, -3
        elseif anchor == "TOPLEFT" then
            focusButton:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "TOPLEFT", 0, 3
        elseif anchor == "TOPRIGHT" then
            focusButton:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -4)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "TOPRIGHT", 0, 3
        end
    else -- left_right
        P:Size(anchorFrame, 10, 20)

        if anchor == "BOTTOMLEFT" then
            focusButton:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMRIGHT", "BOTTOMLEFT", -3, 0
        elseif anchor == "BOTTOMRIGHT" then
            focusButton:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMLEFT", -4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "BOTTOMLEFT", "BOTTOMRIGHT", 3, 0
        elseif anchor == "TOPLEFT" then
            focusButton:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
            tooltipPoint, tooltipRelativePoint, tooltipX, tooltipY = "TOPRIGHT", "TOPLEFT", -3, 0
        elseif anchor == "TOPRIGHT" then
            focusButton:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -4, 0)
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
Cell:RegisterCallback("UpdateMenu", "FocusFrame_UpdateMenu", UpdateMenu)

local function UpdateLayout(layout, which)
    layout = Cell.vars.currentLayoutTable

    -- Size
    if not which or strfind(which, "size$") then
        local width, height
        if layout["focus"]["sameSizeAsMain"] then
            width, height = unpack(layout["main"]["size"])
        else
            width, height = unpack(layout["focus"]["size"])
        end

        P:Size(focusButton, width, height)
    end

    -- Anchor points
    if not which or strfind(which, "arrangement$") then
        local anchor, spacingX, spacingY
        if layout["focus"]["sameArrangementAsMain"] then
            anchor = layout["main"]["anchor"]
            spacingX = layout["main"]["spacingX"]
            spacingY = layout["main"]["spacingY"]
        else
            anchor = layout["focus"]["anchor"]
            spacingX = layout["focus"]["spacingX"]
            spacingY = layout["focus"]["spacingY"]
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

        focusButton:ClearAllPoints()

        focusButton:SetPoint(point, anchorFrame, anchorPoint, 0, unitSpacingY)

        UpdatePosition()
    end

    -- NOTE: SetOrientation BEFORE SetPowerSize
    if not which or which == "barOrientation" then
        B:SetOrientation(focusButton, layout["barOrientation"][1], layout["barOrientation"][2])
    end

    if not which or strfind(which, "power$") or which == "barOrientation" then
        if layout["focus"]["sameSizeAsMain"] then
            B:SetPowerSize(focusButton, layout["main"]["powerSize"])
        else
            B:SetPowerSize(focusButton, layout["focus"]["powerSize"])
        end
    end

    if not which or which == "focus" then
        if layout["focus"]["enabled"] then
            focusFrame:Show()
        else
            focusFrame:Hide()
            menu:Hide()
        end
    end

    -- load position
    if not P:LoadPosition(anchorFrame, layout["focus"]["position"]) then
        P:ClearPoints(anchorFrame)
        -- no position, use default
        anchorFrame:SetPoint("TOPLEFT", UIParent, "CENTER")
    end
end
Cell:RegisterCallback("UpdateLayout", "FocusFrame_UpdateLayout", UpdateLayout)

local function UpdatePixelPerfect()
    P:Resize(focusFrame)
    P:Resize(anchorFrame)
    config:UpdatePixelPerfect()
end
Cell:RegisterCallback("UpdatePixelPerfect", "FocusFrame_UpdatePixelPerfect", UpdatePixelPerfect)

local function FocusFrame_UpdateVisibility(which)
  if not which or which == "focus" then
      if Cell.vars.currentLayoutTable["focus"]["enabled"] then
          RegisterAttributeDriver(focusButton, "state-visibility", "[@focus,exists]show;hide")
      else
          UnregisterAttributeDriver(focusButton, "state-visibility")
          focusFrame:Hide()
      end
  end
end
Cell:RegisterCallback("UpdateVisibility", "FocusFrame_UpdateVisibility", FocusFrame_UpdateVisibility)