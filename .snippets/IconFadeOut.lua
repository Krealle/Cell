-- 自定义图标指示器随时间减少变得透明
local END_ALPHA = 0.2

local function SetCooldown(frame, start, duration, debuffType, texture, count, refreshing)
    if duration == 0 then
        frame.cooldown:Hide()
        frame:SetScript("OnUpdate", nil)
    else
        if frame.showDuration then
            frame.cooldown:Hide()
            frame:SetScript("OnUpdate", function()
                local remain = duration-(GetTime()-start)
                if remain < 0 then remain = 0 end

                -- color
                if Cell.vars.iconDurationColors then
                    if remain < Cell.vars.iconDurationColors[3][4] then
                        frame.duration:SetTextColor(Cell.vars.iconDurationColors[3][1], Cell.vars.iconDurationColors[3][2], Cell.vars.iconDurationColors[3][3])
                    elseif remain < (Cell.vars.iconDurationColors[2][4] * duration) then
                        frame.duration:SetTextColor(Cell.vars.iconDurationColors[2][1], Cell.vars.iconDurationColors[2][2], Cell.vars.iconDurationColors[2][3])
                    else
                        frame.duration:SetTextColor(Cell.vars.iconDurationColors[1][1], Cell.vars.iconDurationColors[1][2], Cell.vars.iconDurationColors[1][3])
                    end
                else
                    frame.duration:SetTextColor(1, 1, 1)
                end

                -- format
                if remain > 60 then
                    remain = string.format("%dm", remain/60)
                else
                    if Cell.vars.iconDurationRoundUp then
                        remain = math.ceil(remain)
                    else
                        if remain < Cell.vars.iconDurationDecimal then
                            remain = string.format("%.1f", remain)
                        else
                            remain = string.format("%d", remain)
                        end
                    end
                end

                frame.duration:SetText(remain)

                -- modify buff alpha
                if not debuffType then
                    frame:SetAlpha((remain/duration)*(1-END_ALPHA)+END_ALPHA)
                end
            end)
        else
            -- modify buff alpha
            if not debuffType then
                frame.cooldown:SetScript("OnUpdate", function(self, elapsed)
                    self.elapsed = (self.elapsed or 0) + elapsed
                    if self.elapsed >= 0.1 then
                        self:SetValue(self:GetValue() + self.elapsed)
                        frame:SetAlpha((1-self:GetValue()/duration)*(1-END_ALPHA)+END_ALPHA)
                        self.elapsed = 0
                    end
                end)
            end

            -- init bar values
            frame.cooldown:SetMinMaxValues(0, duration)
            frame.cooldown:SetValue(GetTime()-start)
            frame.cooldown:Show()
        end
    end

    local r, g, b
    if debuffType then
        r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
        frame.spark:SetColorTexture(r, g, b, 1)
    else
        r, g, b = 0, 0, 0
        frame.spark:SetColorTexture(.5, .5, .5, 1)
    end

    frame:SetBackdropColor(r, g, b, 1)
    frame.icon:SetTexture(texture)
    frame.maskIcon:SetTexture(texture)
    frame.stack:SetText((count == 0 or count == 1) and "" or count)
    frame:Show()

    if refreshing then
        frame.ag:Play()
    end
end

hooksecurefunc(Cell.iFuncs, "CreateIndicator", function(self, parent, indicatorTable)
    if parent ~= CellIndicatorsPreviewButton then
        if indicatorTable["auraType"] == "buff" then
            local indicator = parent.indicators[indicatorTable["indicatorName"]]
            if indicatorTable["type"] == "icon" then
                indicator.SetCooldown = SetCooldown
            elseif indicatorTable["type"] == "icons" then
                for _, i in ipairs(indicator) do
                    i.SetCooldown = SetCooldown
                end
            end
        end
    end
end)