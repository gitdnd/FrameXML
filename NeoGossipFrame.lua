local NGF_SIZE_X = 446
local NGF_SIZE_Y = 446

local TOP_BAR_SIZE_Y = 16

local NGF_FRAME_LEVEL = 6

local PortraitsList = {
    LadySylvanasWindrunner = "Sylvanas",
    Sharlindra = "UndeadF001",
    Varimathras = "Varimathras",
}






















local gossipFrame = getglobal("GossipFrame")

NeoGossipFrameUI = CreateFrame("Frame", NeoGossipFrameUI, UIParent)

NeoGossipFrameUI:SetPoint("RIGHT", UIParent, "CENTER", 0, 50)
NeoGossipFrameUI:Hide()
NeoGossipFrameUI:SetSize(NGF_SIZE_X, NGF_SIZE_Y)

NeoGossipFrameUI:SetBackdrop({
	bgFile = "Interface/FlatGossip",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
NeoGossipFrameUI:SetBackdropColor(0, 0, 0, 1)
NeoGossipFrameUI:SetFrameLevel(NGF_FRAME_LEVEL)

NeoGossipFrameUI.Background = CreateFrame("Frame", nil, NeoGossipFrameUI)
NeoGossipFrameUI.Background:Show()
NeoGossipFrameUI.Background:SetPoint("TOPLEFT", 0, 0)
NeoGossipFrameUI.Background:SetSize(NGF_SIZE_X, NGF_SIZE_Y)

NeoGossipFrameUI.Background:SetBackdrop({
	bgFile = "Interface/FlatGossip",
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
NeoGossipFrameUI.Background:SetFrameLevel(NGF_FRAME_LEVEL + 1)

NeoGossipFrameUI.Options = {}

local OptionsPool = {}

function GetPooledOption()
    local ret = table.remove(OptionsPool)
    if not ret then
        ret = CreateFrame("Button", nil, NeoGossipFrameUI)
        ret:Show()
        ret:SetSize(NGF_SIZE_X, TOP_BAR_SIZE_Y)
        ret:SetNormalFontObject("GameFontNormalSmall")
        ret:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        })
        ret:SetBackdropColor(0.3, 0.3, 0.3, 1)
        ret:SetFrameLevel(NGF_FRAME_LEVEL + 3)
        
    else
        ret:Show()
        ret:SetText("")
    end
    table.insert( NeoGossipFrameUI.Options, ret)
    return ret

end
function RemovePooledOptions()
    for i = 1, #NeoGossipFrameUI.Options do
        local add = table.remove( NeoGossipFrameUI.Options)
        add:Hide()
        table.insert( OptionsPool, add)
    end
    
end

local TopBar = CreateFrame("Frame", nil, NeoGossipFrameUI)
local TextBox = NeoGossipFrameUI.Background:CreateFontString(nil, "OVERLAY", "GameTooltipText")
TextBox:SetPoint("TOPLEFT", TopBar, "BOTTOMLEFT", TOP_BAR_SIZE_Y, -TOP_BAR_SIZE_Y)
TextBox:SetText("")
TextBox:SetTextColor(0, 0, 0, 1)
TextBox:SetSize(NGF_SIZE_X - TOP_BAR_SIZE_Y * 2, NGF_SIZE_Y - TOP_BAR_SIZE_Y * 2)
TextBox:SetJustifyV("TOP")


TopBar:SetPoint("TOPLEFT", 0, 0)
TopBar:Show()
TopBar:SetSize(NGF_SIZE_X, TOP_BAR_SIZE_Y)
TopBar:SetFrameLevel(NGF_FRAME_LEVEL + 2)

local TopBarTextBox = TopBar:CreateFontString(nil, "OVERLAY", "GameTooltipText")
TopBarTextBox:SetPoint("TOP", 0, -1.5)
TopBarTextBox:SetText("")
TextBox:SetJustifyV("TOP")

TopBar:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
TopBar:SetBackdropColor(.7, .7, .7, 1)


local TopBarClose = CreateFrame("Button", nil, TopBar)
TopBarClose:Show()
TopBarClose:SetPoint("TOPRIGHT", 0, 0)
TopBarClose:SetSize(TOP_BAR_SIZE_Y, TOP_BAR_SIZE_Y)
TopBarClose:SetNormalFontObject("GameFontNormalSmall")
TopBarClose:SetHighlightFontObject("GameFontHighlightSmall")
TopBarClose:SetText("X")
TopBarClose:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
TopBarClose:SetBackdropColor(1, 0, 0, 1)
TopBarClose:SetFrameLevel(NGF_FRAME_LEVEL + 3)
TopBarClose:SetScript("OnClick", function (self, button, down)
    gossipFrame:Hide()
end)



local Portrait = CreateFrame("Frame", nil, NeoGossipFrameUI)
Portrait:SetPoint("TOPLEFT", NeoGossipFrameUI, "TOPRIGHT", -2, 0)
Portrait:SetFrameLevel(5)
Portrait:SetSize(446, 446)


function UpdateGossipFrame()
    
    RemovePooledOptions()
    if gossipFrame:IsVisible() then
        NeoGossipFrameUI:Show()
        local name = GetUnitName("target", 0)
        TopBarTextBox:SetText(name)
        TextBox:SetText(GetGossipText())
        name = name:gsub("%s+", "")
        local portrait = PortraitsList[name]
        if portrait ~= nil then
            Portrait:SetBackdrop({
                bgFile = "Interface/CharacterBox/"..portrait,
                edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            Portrait:Show()
        else
            Portrait:Hide()
        end
        local optionsCurrent = 0
        local padding = 0
        function BreakQuestsDownAv(...)
            local ret = {}
            local i = 0
            local name, level, isTrivial, isDaily, isRepeatable = 0
            repeat
                name, level, isTrivial, isDaily, isRepeatable = select(i*5 + 1, ...)
                if name ~= nil then
                    table.insert( ret, i + 1, name )
                    i = i + 1
                end
            until name == nil
            
            return ret
        end
        function BreakQuestsDownAc(...)
            local ret = {}
            local i = 0
            local name, level, isTrivial, isDaily, isRepeatable = 0
            repeat
                name, level, isTrivial, isDaily = select(i*4 + 1, ...)
                if name ~= nil then
                    table.insert( ret, i + 1, name )
                    i = i + 1
                end
            until name == nil
            
            return ret
        end
        local optionsAvQuests = BreakQuestsDownAv(GetGossipAvailableQuests())
        for i = 1, #optionsAvQuests do
            optionsCurrent = optionsCurrent + 1
            local GossipOption = GetPooledOption()
            if optionsCurrent > 9 then
                GossipOption:SetText(optionsAvQuests[i])
            else
                GossipOption:SetText(optionsCurrent..") "..optionsAvQuests[i])
            end
            local width = GossipOption:GetTextWidth()
            width = width / (NGF_SIZE_X * 0.8) 
            width = math.floor(width)
            padding = padding + width
            GossipOption:SetPoint("TOPLEFT", NeoGossipFrameUI, "BOTTOMLEFT", 0, TOP_BAR_SIZE_Y * ( padding + optionsCurrent + 1))

            local opCurr = optionsCurrent
            GossipOption:SetScript("OnClick", function (self, button, down)
                NUMPressDirect(opCurr)
            end)
        end
        local optionsAcQuests = BreakQuestsDownAc(GetGossipActiveQuests())
        for i = 1, #optionsAcQuests do
            optionsCurrent = optionsCurrent + 1
            local GossipOption = GetPooledOption()
            if optionsCurrent > 9 then
                GossipOption:SetText(optionsAcQuests[i])
            else
                GossipOption:SetText(optionsCurrent..") "..optionsAcQuests[i])
            end
            local width = GossipOption:GetTextWidth()
            width = width / (NGF_SIZE_X * 0.8) 
            width = math.floor(width)
            padding = padding + width
            GossipOption:SetPoint("TOPLEFT", NeoGossipFrameUI, "BOTTOMLEFT", 0, TOP_BAR_SIZE_Y * ( padding + optionsCurrent + 1))

            local opCurr = optionsCurrent
            GossipOption:SetScript("OnClick", function (self, button, down)
                NUMPressDirect(opCurr)
            end)
        end
        local options = {GetGossipOptions()}
        for i = 1, #options/2 do
            optionsCurrent = optionsCurrent + 1
            local GossipOption = GetPooledOption()
            if optionsCurrent > 9 then
                GossipOption:SetText(options[i*2 - 1])
            else
                GossipOption:SetText(optionsCurrent..") "..options[i*2 - 1])
            end
            local width = GossipOption:GetTextWidth()
            width = width / (NGF_SIZE_X * 0.8) 
            width = math.floor(width)
            padding = padding + width
            GossipOption:SetSize(NGF_SIZE_X, TOP_BAR_SIZE_Y * (width + 1))
            if width > 0 then
                repeat
                    local newText = GossipOption:GetText():sub(1,70 * width)
                    local target = string.byte(" ")
                    for idx = (width - 1) * 70 + 55, #newText do
                        if newText:byte(idx) == target then
                            print("Target found at:", idx)
                            GossipOption:SetText(GossipOption:GetText():sub(1,idx).."|n"..GossipOption:GetText():sub(idx + 1))
                            break
                        end
                    end
                    width = width - 1
                until width <= 0
            end
            GossipOption:SetPoint("TOPLEFT", NeoGossipFrameUI, "BOTTOMLEFT", 0, TOP_BAR_SIZE_Y * (padding + optionsCurrent + 1))
            local opCurr = optionsCurrent
            GossipOption:SetScript("OnClick", function (self, button, down)
                NUMPressDirect(opCurr)
            end)
        end
    else
        NeoGossipFrameUI:Hide()
    end
end

if gossipFrame ~= nil then
    gossipFrame:SetAlpha(0)
    gossipFrame:SetSize(0, 0)
    gossipFrame:HookScript("OnShow", function(self)
        UpdateGossipFrame()
    end)
    gossipFrame:HookScript("OnHide", function(self)
        UpdateGossipFrame()
        
    end)
    gossipFrame.Show = nil
end


    