--------------------------------------------
-- http://wow.gamepedia.com/UI_Scale
-- http://www.wowinterface.com/forums/showthread.php?t=31813
--------------------------------------------
local addonName, addon = ...
addon.pixelPerfectFuncs = {}
local P = addon.pixelPerfectFuncs

function P:GetResolution()
    -- return string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")
    return GetPhysicalScreenSize()
end

-- The UI P:Scale goes from 1 to 0.64.
-- At 768y we see pixel-per-pixel accurate representation of our texture,
-- and again at 1200y if at 0.64 scale.
function P:GetPixelPerfectScale()
    local hRes, vRes = P:GetResolution()
    if vRes then
        return 768/vRes
    else -- windowed mode before 8.0, or maybe something goes wrong?
        return 1
    end
end

-- scale perfect!
function P:PixelPerfectScale(frame)
    frame:SetScale(P:GetPixelPerfectScale())
end

-- position perfect!
function P:PixelPerfectPoint(frame)
    local left = frame:GetLeft()
    local top = frame:GetTop()

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(left + 0.5), math.floor(top + 0.5))
end

--------------------------------------------
-- PixelUtil
--------------------------------------------
-- local effectiveScale = 1
-- function P:SetRelativeScale(scale)
--     effectiveScale = scale
-- end

-- function P:GetEffectiveScale()
--     return effectiveScale
-- end

-- function P:SetEffectiveScale(frame)
--     frame:SetScale(effectiveScale)
-- end

-- function P:Scale(uiUnitSize)
--     if uiUnitSize == 0 then
--         return 0
--     end

--     local uiUnitFactor = PixelUtil.GetPixelToUIUnitFactor()
--     local numPixels = Round((uiUnitSize * effectiveScale) / uiUnitFactor)
--     if uiUnitSize < 0.0 then
--         if numPixels > -1 then
--             numPixels = -1
--         end
--     else
--         if numPixels < 1 then
--             numPixels = 1
--         end
--     end

--     return numPixels * uiUnitFactor / effectiveScale
-- end

--------------------------------------------
-- some are stolen from ElvUI
--------------------------------------------
-- local function GetUIParentScale()
--     local scale = UIParent:GetScale()
--     return scale - scale % 0.1 ^ 2
-- end

local mult = 1
function P:SetRelativeScale(scale)
    mult = 1 / scale
end

function P:GetEffectiveScale()
    return P:GetPixelPerfectScale() / mult
end

function P:SetEffectiveScale(frame)
    frame:SetScale(P:GetEffectiveScale())
end

--[[
local trunc = function(s) return s >= 0 and s-s%01 or s-s%-1 end
local round = function(s) return s >= 0 and s-s%-1 or s-s%01 end
function P:Scale(n)
    return (mult == 1 or n == 0) and n or ((mult < 1 and trunc(n/mult) or round(n/mult)) * mult)
end
]]
function P:Scale(n)
    if mult == 1 or n == 0 then
        return n
    else
        local x = mult > 1 and mult or -mult
        return n - n % (n < 0 and x or -x)
    end
end

function P:Size(frame, width, height)
    frame.width = width
    frame.height = height
    frame:SetSize(P:Scale(width), P:Scale(height))
end

function P:Width(frame, width)
    frame.width = width
    frame:SetWidth(P:Scale(width))
end

function P:Height(frame, height)
    frame.height = height
    frame:SetHeight(P:Scale(height))
end

function P:Point(frame, ...)
    if not frame.points then frame.points = {} end
    local point, anchorTo, anchorPoint, x, y

    local n = select("#", ...)
    if n == 1 then
        point = ...
    elseif n == 3 and type(select(2, ...)) == "number" then
        point, x, y = ...
    elseif n == 4 then
        point, anchorTo, x, y = ...
    else
        point, anchorTo, anchorPoint, x, y = ...
    end

    tinsert(frame.points, {point, anchorTo or frame:GetParent(), anchorPoint or point, x or 0, y or 0})
    local n = #frame.points
    frame:SetPoint(frame.points[n][1], frame.points[n][2], frame.points[n][3], P:Scale(frame.points[n][4]), P:Scale(frame.points[n][5]))
end

function P:ClearPoints(frame)
    frame:ClearAllPoints()
    if frame.points then wipe(frame.points) end
end

--------------------------------------------
-- scale changed
--------------------------------------------
function P:Resize(frame)
    if frame.width then
        frame:SetWidth(P:Scale(frame.width))
    end
    if frame.height then
        frame:SetHeight(P:Scale(frame.height))
    end
end

function P:Reborder(frame)
    if not frame.backdropInfo then return end

    local _r, _g, _b, _a = frame:GetBackdropColor()
    local r, g, b, a = frame:GetBackdropBorderColor()

    frame.backdropInfo.edgeSize = P:Scale(CELL_BORDER_SIZE or 1)
    frame:ApplyBackdrop()

    if _r then frame:SetBackdropColor(_r, _g, _b, _a) end
    if r then frame:SetBackdropBorderColor(r, g, b, a) end
end

function P:Repoint(frame)
    if not frame.points or #frame.points == 0 then return end
    frame:ClearAllPoints()
    for _, t in pairs(frame.points) do
        frame:SetPoint(t[1], t[2], t[3], P:Scale(t[4]), P:Scale(t[5]))
    end
end

-- local frames = {}
-- function P:SetPixelPerfect(frame)
--     tinsert(frames, frame)
-- end

-- function P:UpdatePixelPerfectFrames()
--     for _, f in pairs(frames) do
--         f:UpdatePixelPerfect()
--     end
-- end

--------------------------------------------
-- save & load position
--------------------------------------------
function P:SavePosition(frame, positionTable)
    wipe(positionTable)
    local left = math.floor(frame:GetLeft() + 0.5)
    local top = math.floor(frame:GetTop() + 0.5)
    positionTable[1], positionTable[2] = left, top
end

function P:LoadPosition(frame, positionTable)
    if type(positionTable) ~= "table" or #positionTable ~= 2 then return end

    P:ClearPoints(frame)
    P:Point(frame, "TOPLEFT", UIParent, "BOTTOMLEFT", positionTable[1], positionTable[2])
    return true
end