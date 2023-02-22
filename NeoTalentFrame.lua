local NTF_SIZE_X = 1200
local NTF_SIZE_Y = 600

local TOP_BAR_SIZE_Y = 16


local NTF_FRAME_LEVEL = 5

UIParentLoadAddOn("Blizzard_TalentUI");



local NeoTalentFrameUI = CreateFrame("Frame", NeoTalentFrameUI, UIParent)

NeoTalentFrameUI:SetPoint("CENTER", 0, 50)
NeoTalentFrameUI:Hide()
NeoTalentFrameUI:SetSize(NTF_SIZE_X, NTF_SIZE_Y)

NeoTalentFrameUI:SetBackdrop({
	bgFile = "Interface/Flat",  
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
NeoTalentFrameUI:SetBackdropColor(0, 0, 0, 1)
NeoTalentFrameUI:SetFrameLevel(NTF_FRAME_LEVEL)

NeoTalentFrameUI.BackgroundL = CreateFrame("Frame", nil, NeoTalentFrameUI)
NeoTalentFrameUI.BackgroundL:Show()
NeoTalentFrameUI.BackgroundL:SetPoint("TOPLEFT", 0, 0)
NeoTalentFrameUI.BackgroundL:SetSize(NTF_SIZE_Y, NTF_SIZE_Y)

NeoTalentFrameUI.BackgroundL:SetBackdrop({
	bgFile = "Interface/Talents/Night ElfBG",
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
NeoTalentFrameUI.BackgroundL:SetFrameLevel(NTF_FRAME_LEVEL + 1)

NeoTalentFrameUI.BackgroundR = CreateFrame("Frame", nil, NeoTalentFrameUI)
NeoTalentFrameUI.BackgroundR:Show()
NeoTalentFrameUI.BackgroundR:SetPoint("TOPLEFT", NTF_SIZE_Y, 0)
NeoTalentFrameUI.BackgroundR:SetSize(NTF_SIZE_Y, NTF_SIZE_Y)

NeoTalentFrameUI.BackgroundR:SetBackdrop({
	bgFile = "Interface/Talents/Night ElfBG",
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
NeoTalentFrameUI.BackgroundR:SetFrameLevel(NTF_FRAME_LEVEL + 1)


function ToggleNeoTalentFrame()
    if NeoTalentFrameUI:IsShown() then
        NeoTalentFrameUI:Hide()
    else
        NeoTalentFrameUI:Show()
    end
end



NeoTalentFrameUI.Specs = {}

function CreateSpecData(id, name)
    local specData = {
        Id = id,
        Name = name,
        BackgroundL = "Interface/Talents/"..name.."BGL",
        BackgroundR = "Interface/Talents/"..name.."BGR",
        Icon = "Interface/Talents/"..name.."Icon",
        Widget = 0
    }
    table.insert( NeoTalentFrameUI.Specs, specData) 
end



function CreateSpecBookmark(specIndex)
    local specData = NeoTalentFrameUI.Specs[specIndex]
    local Spec = CreateFrame("Button", nil, NeoTalentFrameUI)
    Spec:SetPoint("TOPLEFT", NeoTalentFrameUI, "TOPRIGHT", -12, 25 - specIndex* 75)
    
    Spec:SetSize(125, 50)
    Spec:SetText(specData.Name)
    Spec:SetNormalFontObject("GameFontNormalSmall")
    Spec:Lower()

    Spec:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    Spec:SetBackdropColor(.6, .4, .7, 1)
    Spec:SetScript("OnMouseDown", function (self, button, down)
		SelectSpec(specIndex)
    end)
    Spec:SetFrameLevel(NTF_FRAME_LEVEL - 2)
    
    local SpecIcon = CreateFrame("Button", nil, Spec)
    SpecIcon:SetPoint("TOPLEFT", Spec, "TOPRIGHT", -15, 0)
    SpecIcon:SetSize(50, 50)
    SpecIcon:SetBackdrop({
        bgFile = specData.Icon
    })
    NeoTalentFrameUI.Specs[specIndex].Widget = Spec
    SpecIcon:SetFrameLevel(NTF_FRAME_LEVEL - 1)
end

CreateSpecData(1, "Night Elf")
CreateSpecData(2, "Tauren")
CreateSpecData(3, "Human")
CreateSpecData(4, "Undead")
CreateSpecData(5, "Orc")
CreateSpecData(6, "Troll")
CreateSpecData(7, "Dwarf")

for i = 1, #NeoTalentFrameUI.Specs do
    CreateSpecBookmark(i)
end

local SelectedSpec = 0

function SelectSpec(specId)
    if SelectedSpec ~= 0 then
        local widg = NeoTalentFrameUI.Specs[SelectedSpec].Widget
        widg:SetPoint("TOPLEFT", NeoTalentFrameUI, "TOPRIGHT", -12, 25 - SelectedSpec* 75)
    end
    local Selected = NeoTalentFrameUI.Specs[specId]
    Selected.Widget:SetPoint("TOPLEFT", NeoTalentFrameUI, "TOPRIGHT",  -125 + 20, 25 - specId* 75)
    SelectedSpec = specId
    NeoTalentFrameUI.BackgroundL:SetBackdrop({
        bgFile = Selected.BackgroundL
    })
    NeoTalentFrameUI.BackgroundR:SetBackdrop({
        bgFile = Selected.BackgroundR
    })
end

SelectSpec(3)




local TopBar = CreateFrame("Button", nil, NeoTalentFrameUI)
TopBar:SetPoint("TOPLEFT", 0, 0)
TopBar:Show()
TopBar:SetSize(NTF_SIZE_X, TOP_BAR_SIZE_Y)
TopBar:SetText("Talents")
TopBar:SetNormalFontObject("GameFontNormalSmall")
TopBar:SetFrameLevel(NTF_FRAME_LEVEL + 2)

TopBar:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
TopBar:SetBackdropColor(.7, .7, .7, 1)

local PointsText = CreateFrame("Button", nil, NeoTalentFrameUI)
PointsText:SetPoint("TOPLEFT", TopBar, "BOTTOMLEFT", (NTF_SIZE_Y - TOP_BAR_SIZE_Y - 125)/2, 0)
PointsText:SetSize(125, 29)
PointsText:SetNormalFontObject("GameFontHighlightLarge")
PointsText:SetText("Talent Points: ")
PointsText:SetFrameLevel(NTF_FRAME_LEVEL + 2)
PointsText:Show()

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
TopBarClose:SetFrameLevel(NTF_FRAME_LEVEL + 3)
TopBarClose:SetScript("OnClick", function (self, button, down)
    talentFrame:Hide()
end)

function CreateTalentData(id, name, icon, description)
    local talentData = {
        Id = id,
        Name = name,
        Icon = icon,
        Description = description,
        Owned = false
    }
    return talentData
end
function CreateTalentButton(x, y)
    local talentButton = CreateFrame("Button", nil, NeoTalentFrameUI)
    talentButton:SetPoint("TOPLEFT", 24 + x * 456, -24 -y * 56)
    talentButton:SetNormalTexture("Interface\\Icons\\Ability_ThunderBolt.blp")
    talentButton:Show()
    talentButton:SetSize(48, 48)
    talentButton:RegisterForClicks("LeftButtonUp")
    talentButton:SetScript("OnClick", function (self, button, down)
    end)
    talentButton:SetFrameLevel(NTF_FRAME_LEVEL + 3)
    talentButton:SetScript("OnClick", function(self, event) 
        talentButton.Fade:Hide()
    end)


    talentButton.Background = CreateFrame("Frame", nil, talentButton)
    talentButton.Background:Show()
    talentButton.Background:SetPoint("TOPLEFT", talentButton, "TOPLEFT", -2, 2)
    talentButton.Background:SetSize(400, 52)

    talentButton.Background:SetBackdrop({
        bgFile = "Interface/Flat",  
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    talentButton.Background:SetFrameLevel(NTF_FRAME_LEVEL + 2)
    
    talentButton.Background:SetBackdropColor(0, 0, 0, 0.3)

    talentButton.Fade = CreateFrame("Frame", nil, talentButton)
    talentButton.Fade:Show()
    talentButton.Fade:SetPoint("TOPLEFT", talentButton, "TOPLEFT", 0, 2)
    talentButton.Fade:SetSize(400, 52)

    talentButton.Fade:SetBackdrop({
        bgFile = "Interface/Flat"       
    })
    talentButton.Fade:SetFrameLevel(NTF_FRAME_LEVEL + 4)
    
    talentButton.Fade:SetBackdropColor(.3, .3, .3, 0.4)

    talentButton.NameBox = talentButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    talentButton.NameBox:SetPoint("LEFT", talentButton, "RIGHT", 10, 0)
    talentButton.NameBox:SetText("")
    talentButton.NameBox:SetTextColor(1, 1, 1, 1)
    talentButton.NameBox:SetSize(300, 52)
    talentButton.NameBox:SetFont("Fonts\\FRIZQT__.TTF", 45, "OUTLINE")
    talentButton.NameBox:SetTextColor(1, 0.84, 0, 1)

    function OnEnterFrame(self, motion)
        GameTooltip:Show()
        GameTooltip:SetPoint("TOPRIGHT", talentButton, "BOTTOMLEFT", 0, 0)
        GameTooltip:SetOwner(talentButton, "ANCHOR_RIGHT");
        
            
        GameTooltip:SetFrameLevel(15)
        
        GameTooltip:SetHyperlink("spell:210030")
        
    end 
    function OnLeaveFrame(self, motion)
        GameTooltip:Hide()
    end 
    talentButton:SetScript("OnLeave", OnLeaveFrame)
    talentButton:SetScript("OnEnter", OnEnterFrame)
    return talentButton


end


function SetButtonData(button, data)
    button:SetNormalTexture(data.Icon)
    button.NameBox:SetText(data.Name)
    if data.Owned == true then
        button.Fade:Hide()
    else
        button.Fade:Show()
    end

end
for i = 1, 8 do
    SetButtonData(CreateTalentButton(0, i), CreateTalentData(5, "Stormbolt", "Interface/Icons/Ability_ThunderBolt", "Fires a powerful storm of Bolts"))
    CreateTalentButton(1, i)
end

