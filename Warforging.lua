
local config = {
	Prefix = "WarforgingUI",
	Functions = {
        [1] = "OnWarforge",
	}
}


function HideWarforge()
    WarforgingUI:Hide()
    WarforgeReset(WarforgingUI.Main)
    WarforgeReset(WarforgingUI.Side[1])
    WarforgeReset(WarforgingUI.Side[2])
    WarforgeReset(WarforgingUI.Side[3])
end
function OnWarforge(char, table)
    OnItemUpdate(char, table)
    if(WarforgingUI.Side[1].Item ~= 0 or WarforgingUI.Side[2].Item ~= 0 or WarforgingUI.Side[3].Item ~= 0) then 
        PlaySoundFile("Sound\\Interface\\WarforgeSucceed.mp3", "SFX")
    end
    WarforgeReset(WarforgingUI.Side[1])
    WarforgeReset(WarforgingUI.Side[2])
    WarforgeReset(WarforgingUI.Side[3])
end

RegisterServerResponses(config)


WarforgingUI = CreateFrame("Frame", WarforgingUI, UIParent)

WarforgingUI:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
WarforgingUI:Show()
WarforgingUI:SetSize(700, 700)

WarforgingUI:SetBackdrop({
	bgFile = "Interface/FlatGossip",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
WarforgingUI:SetBackdropColor(0, 0, 0, 1)

WarforgingUI.Texture = WarforgingUI:CreateTexture("", "BACKGROUND");
WarforgingUI.Texture:SetPoint("CENTER", 0, 0);
WarforgingUI.Texture:SetSize(700, 700);
WarforgingUI.Texture:SetTexture("Interface/WarforgeFrame");

WarforgingUI.Activate = CreateFrame("Button", nil, WarforgingUI)
WarforgingUI.Activate:SetSize(200, 50)
WarforgingUI.Activate:SetPoint("BOTTOM", WarforgingUI, "BOTTOM", 0, 40)
WarforgingUI.Activate:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
WarforgingUI.Activate:SetText("WARFORGE")
WarforgingUI.Activate:SetNormalFontObject("GameFontNormalLarge")
WarforgingUI.Activate:SetHighlightFontObject("GameFontHighlightLarge")
WarforgingUI.Activate:SetPushedTextOffset(2,-2)

WarforgingUI.Main = CreateFrame("Button", nil, WarforgingUI);
WarforgingUI.Main:SetSize(150, 150);
WarforgingUI.Main:SetPoint("TOP", "WarforgingUI", "TOP", 0, -40);
WarforgingUI.Main:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
WarforgingUI.Main:SetBackdropColor(0, 0, 0, 1)
WarforgingUI.Main.Texture = WarforgingUI.Main:CreateTexture("", "BACKGROUND");

WarforgingUI.Main.Texture:SetPoint("CENTER", 0, 0);
WarforgingUI.Main.Texture:SetSize(150, 150);
WarforgingUI.Main:SetScript("OnClick", function (self, button, down)
    WarforgeReset(self)
end)
WarforgingUI.Main.Location = { Bag = -1, Slot = -1}
WarforgingUI.Side = {}

WarforgingUI.TextBackdrop = CreateFrame("Frame", nil, WarforgingUI);
WarforgingUI.TextBackdrop:SetSize(600, 150)
WarforgingUI.TextBackdrop:SetPoint("LEFT", WarforgingUI, "LEFT", 30, -150)
WarforgingUI.TextBackdrop:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
WarforgingUI.TextBackdrop:SetBackdropColor(0, 0, 0, 1)


WarforgingUI.Instructions = WarforgingUI.TextBackdrop:CreateFontString(nil, "OVERLAY", "GameTooltipText")
WarforgingUI.Instructions:SetPoint("TOPLEFT", WarforgingUI.TextBackdrop, "TOPLEFT", 30, 0)
WarforgingUI.Instructions:SetText([[INSTRUCTIONS:

Left Click an item in your inventory to select it for Warforging.

Right Click an item of the same name to sacrficie for the improvement.

Left Click a selected item in the Warforging UI to deselect it. 
]])
WarforgingUI.Instructions:SetTextColor(1, 1, 1, 1)
WarforgingUI.Instructions:SetSize(600, 150)
WarforgingUI.Instructions:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
WarforgingUI.Instructions:SetTextColor(1, 0.84, 0, 1)

function WarforgeReset(me)
    local UISide = me 

    UISide.Item = 0
    UISide:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",  
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    UISide:SetBackdropColor(0, 0, 0, 1)
        
    UISide.Texture:SetTexture("");
    UISide.Location = { Bag = -1, Slot = -1}
end

WarforgeReset(WarforgingUI.Main)

for i = 1, 3 do
    WarforgingUI.Side[i] = CreateFrame("Button", nil, WarforgingUI);
    local UISide = WarforgingUI.Side[i]
    UISide:SetSize(100, 100);
    UISide:SetPoint("CENTER", "WarforgingUI", "CENTER", -500 + i * 250, math.abs(100 * (2 - i)));
    
    UISide.Item = 0
    UISide:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",  
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    UISide:SetBackdropColor(0, 0, 0, 1)
    
    UISide.Texture = UISide:CreateTexture("", "BACKGROUND");
    UISide.Texture:SetPoint("CENTER", 0, 0);
    UISide.Texture:SetSize(100, 100);
    UISide.Texture:SetTexture("");

    UISide:SetScript("OnClick", function (self, button, down)
        WarforgeReset(self)
    end)
    UISide.Location = { Bag = -1, Slot = -1}
end


-- HoT magic
local origContainerFrameItemButton_OnClick = ContainerFrameItemButton_OnClick;
ContainerFrameItemButton_OnClick = function(...)
    local self, button = ...
    if(WarforgingUI:IsShown()) then
        if(button == "RightButton") then
            local bag, slot = self:GetParent():GetID(), self:GetID();
            local _, _, _, _, _, _, link = GetContainerItemInfo(bag, slot)
            if link then
                local itemId = select(3, strfind(link, "item:(%d+)"))
                for i = 1, 3 do
                    if WarforgingUI.Side[i].Item == 0 then
                        for j = 1, i do
                            if(WarforgingUI.Side[i].Item == WarforgingUI.Side[j].Item and WarforgingUI.Side[j].Item ~= 0 ) then
                                return
                            end
                        end
                        local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
                        WarforgingUI.Side[i].Item = itemId
                        WarforgingUI.Side[i].Location = { Bag = bag, Slot = slot }
                        if (texture) then
                            WarforgingUI.Side[i].Texture:SetTexture(texture);
                            WarforgingUI.Side[i]:SetBackdropColor(0, 0, 0, 0);
                        end
                        break
                    end
                end
            end
        elseif(button == "LeftButton") then
            local bag, slot = self:GetParent():GetID(), self:GetID();
            local _, _, _, _, _, _, link = GetContainerItemInfo(bag, slot)
            if link then
                local itemId = select(3, strfind(link, "item:(%d+)"))
                local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
                WarforgingUI.Main.Item = itemId
                WarforgingUI.Main.Location = { Bag = bag, Slot = slot }
                if (texture) then
                    WarforgingUI.Main.Texture:SetTexture(texture);
                    WarforgingUI.Main:SetBackdropColor(0, 0, 0, 0);
                end
            end
        end
        return
	end
	return origContainerFrameItemButton_OnClick(...)
end 


WarforgingUI.Close = CreateFrame("Button", nil, WarforgingUI)
WarforgingUI.Close:Show()
WarforgingUI.Close:SetPoint("TOPRIGHT", 0, 0)
WarforgingUI.Close:SetSize(24, 24)
WarforgingUI.Close:SetNormalFontObject("GameFontNormalSmall")
WarforgingUI.Close:SetHighlightFontObject("GameFontHighlightSmall")
WarforgingUI.Close:SetText("X")
WarforgingUI.Close:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
WarforgingUI.Close:SetBackdropColor(1, 0, 0, 1)
WarforgingUI.Close:SetFrameLevel(6)
WarforgingUI.Close:SetScript("OnClick", function (self, button, down)
    HideWarforge()
end)

WarforgingUI.Activate:SetScript("OnClick", function (self, button, down)
    SendClientRequest(config.Prefix, 1, {
        WarforgingUI.Main.Location.Bag,
        WarforgingUI.Main.Location.Slot,
        WarforgingUI.Side[1].Location.Bag,
        WarforgingUI.Side[1].Location.Slot,
        WarforgingUI.Side[2].Location.Bag,
        WarforgingUI.Side[2].Location.Slot,
        WarforgingUI.Side[3].Location.Bag,
        WarforgingUI.Side[3].Location.Slot,
    })
    
end)


OpenWarforgingUI = CreateFrame("Button", OpenWarforgingUI, UIParent)

OpenWarforgingUI:Show()
OpenWarforgingUI:SetPoint("RIGHT", -5, -200)
OpenWarforgingUI:SetSize(36, 36)
OpenWarforgingUI:SetNormalFontObject("GameFontNormalLarge")
OpenWarforgingUI:SetHighlightFontObject("GameFontHighlightLarge")
OpenWarforgingUI:SetText("W")
OpenWarforgingUI:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
OpenWarforgingUI:SetBackdropColor(1, 0, 0, 1)
OpenWarforgingUI:SetFrameLevel(6)
OpenWarforgingUI:SetScript("OnClick", function (self, button, down)
    if WarforgingUI:IsShown() then
        HideWarforge()
    else
        WarforgingUI:Show()
    end
end)
HideWarforge()