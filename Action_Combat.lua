local keys = {
	"MOVEFORWARD", 
	"MOVEBACKWARD", 
	"STRAFELEFT", 
	"STRAFERIGHT",
	"TURNLEFT", 
	"TURNRIGHT",
	"SPRINT",
	"RPGCAM",
	"JUMP",
	"ACTIONBUTTON1",
	"ACTIONBUTTON2",
	"ACTIONBUTTON3",
	"ACTIONBUTTON4",
	"ACTIONBUTTON5",
	"ACTIONBUTTON6",
	"ACTIONBUTTON7",
	"ACTIONBUTTON8",
	"ACTIONBUTTON9", 
}
local keysHeld = {}

local lastBackForward = 0
local lastLeftRight = 0


local maxPitchAngle = -0.4
local minPitchAngle = 1
local angle = 0
local angleMoved = 0
local timeElapsed = 0
local speedPitchAngle = 15 

local keyEnables = {}
local keyEnablesUp = {}

local characterState = 1 -- 0=error 1=nothing, 2=sprinting, 3= rpgcam
local characterStates = { [1] = 1, [2] = 0, [3] = 0, [4] = 0,} -- will go from top to bottom finding true, if none are true it defaults to 0 as charState. [0] never changes.
local sprintCD = 0

local skipBind = false



local playerStats = CreateFrame("Frame")
playerStats.Weight = 0
playerStats:RegisterEvent("UNIT_STATS")
playerStats:RegisterEvent("UNIT_RESISTANCES")
playerStats:SetScript("OnEvent", function(self, event)
	self.Weight = UnitArmor("player") / (3 * UnitStat("player", 2))
end)

function ResetLeftRight()
	if(lastLeftRight == 1) then
		StrafeRightStop();
		StrafeRightStart();
	elseif(lastLeftRight == -1) then
		StrafeLeftStop();
		StrafeLeftStart();
	else
		StrafeLeftStop();
		StrafeRightStop();
	end
end
function ResetBackwardForward()
	if(keysHeld["MOVEFORWARD"] == true and lastBackForward == 1) then
		MoveForwardStop();
		MoveForwardStart();
	elseif(keysHeld["MOVEBACKWARD"] == true and lastBackForward == -1) then 
		MoveBackwardStop();
		MoveBackwardStart();
	else
		MoveForwardStop();
		MoveBackwardStop();
	end
end

local dashDuration = 0
local dashing = false
local sprinting = false
function SprintOn()
	if(sprintCD <= 0 and dashing == false) then
		sprinting = true
		 
		SetCVar("cameraYawMoveSpeed", tostring(max(5, 15 - playerStats.Weight)))
		keyEnables["MOVEBACKWARD"] = keyEnables["MOVEBACKWARD"] - 1
		keyEnables["STRAFELEFT"] = keyEnables["STRAFELEFT"] - 1
		keyEnables["STRAFERIGHT"] = keyEnables["STRAFERIGHT"] - 1
		maxPitchAngle = maxPitchAngle + 0.25
		minPitchAngle = minPitchAngle - 0.95
		speedPitchAngle = speedPitchAngle * 2
		if(keysHeld["STRAFELEFT"] == true) then
			StrafeLeftStop();
			RunBinding("STRAFELEFT", "up")
		end
		if(keysHeld["STRAFERIGHT"] == true) then
			StrafeRightStop();
			RunBinding("STRAFERIGHT	", "up")
		end
		SendChatMessage(".cast 100023")  
	end
end
function SprintOff()
	if(sprinting == true) then
		sprinting = false
		SetCVar("cameraYawMoveSpeed", "50")
		keyEnables["MOVEBACKWARD"] = keyEnables["MOVEBACKWARD"] + 1
		keyEnables["STRAFELEFT"] = keyEnables["STRAFELEFT"] + 1
		keyEnables["STRAFERIGHT"] = keyEnables["STRAFERIGHT"] + 1
		maxPitchAngle = maxPitchAngle - 0.25
		minPitchAngle = minPitchAngle + 0.95
		speedPitchAngle = speedPitchAngle / 2
		ResetLeftRight()
		sprintCD = 1
		CancelUnitBuff("player", "SuperSprint")
	end
end

local focused = false
function RPGFocusOn()
	TurnOrActionStopWrap()
	ClearOverrideBindings(UIParent)
	focused = true
end
function FocusOff()		
	TurnOrActionStartWrap() 
	SetOverrideBinding(UIParent, true, "BUTTON1", "NONE")
	SetOverrideBinding(UIParent, true, "BUTTON2", "NONE")
	focused = false
end
function RPGFocusOff()
	if (focused == true) then
		local frame = GetMouseFocus()   
		if(not frame or frame:GetName() == "WorldFrame") then 
			FocusOff()
		end
	end
end
local dashBackForward = 0
local dashLeftRight = 0
function DashOn()
	dashing = true
	SetCVar("cameraYawMoveSpeed", "15")
	dashDuration = 0.2 
	dashBackForward = lastBackForward
	dashLeftRight = lastLeftRight
	MoveForwardStop();
	MoveBackwardStop();
	keyEnablesUp["MOVEFORWARD"] = keyEnablesUp["MOVEFORWARD"] - 1
	keyEnablesUp["MOVEBACKWARD"] = keyEnablesUp["MOVEBACKWARD"] - 1
	keyEnablesUp["STRAFELEFT"] = keyEnablesUp["STRAFELEFT"] - 1
	keyEnablesUp["STRAFERIGHT"] = keyEnablesUp["STRAFERIGHT"] - 1
	keyEnables["MOVEFORWARD"] = keyEnables["MOVEFORWARD"] - 1
	keyEnables["MOVEBACKWARD"] = keyEnables["MOVEBACKWARD"] - 1
	keyEnables["STRAFELEFT"] = keyEnables["STRAFELEFT"] - 1
	keyEnables["STRAFERIGHT"] = keyEnables["STRAFERIGHT"] - 1
	-- while holding shift and pressing space you get the 200% speed boost for a short dur. it can go in any direction but keeps you in that direction. and gives i frames lmao.
	sprintCD = 1
	SendChatMessage(".cast 100024") 
end 
function DashOff()
	dashing = false
	SetCVar("cameraYawMoveSpeed", "50")
	dashDuration = 0
	keyEnablesUp["MOVEFORWARD"] = keyEnablesUp["MOVEFORWARD"] + 1
	keyEnablesUp["MOVEBACKWARD"] = keyEnablesUp["MOVEBACKWARD"] + 1
	keyEnablesUp["STRAFELEFT"] = keyEnablesUp["STRAFELEFT"] + 1
	keyEnablesUp["STRAFERIGHT"] = keyEnablesUp["STRAFERIGHT"] + 1
	keyEnables["MOVEFORWARD"] = keyEnables["MOVEFORWARD"] + 1
	keyEnables["MOVEBACKWARD"] = keyEnables["MOVEBACKWARD"] + 1
	keyEnables["STRAFELEFT"] = keyEnables["STRAFELEFT"] + 1
	keyEnables["STRAFERIGHT"] = keyEnables["STRAFERIGHT"] + 1 
	if(dashLeftRight == 1) then
		StrafeRightStop();
	elseif(dashLeftRight == -1) then
		StrafeLeftStop();
	end 
	if(dashBackForward == 1) then
		MoveForwardStop();
	elseif(dashBackForward == -1) then 
		MoveBackwardStop();
	end
	ResetLeftRight()
	ResetBackwardForward()  
	CancelUnitBuff("player", "Dash")
end
local stateEnter = {
	[1] = nil,
	[2] = SprintOn,
	[3] = RPGFocusOn,
	[4] = DashOn,
}
local stateExit = {
	[1] = nil,
	[2] = SprintOff,
	[3] = RPGFocusOff,
	[4] = DashOff,
}

function UpdateCharState()
	local oldState = characterState
	characterState = 1
	for i = 1, #characterStates do
		if(1 <= characterStates[i]) then
			characterState = i
		end
	end
	if(oldState ~= characterState) then
		if(stateExit[oldState]~= nil) then
			stateExit[oldState]()
		end
		if(stateEnter[characterState]~= nil) then
			stateEnter[characterState]()
		end
	end
	return characterState
end
function ModifyCharacterState(index, amount)
	characterStates[index] = characterStates[index] + amount
	UpdateCharState()
end


function ShiftPress()
	if(keysHeld["SPRINT"] == true and keysHeld["MOVEFORWARD"] == true) then 
		ModifyCharacterState(2, 1)
	end
end
function ShiftRelease()
	if(keysHeld["SPRINT"] == true or keysHeld["MOVEFORWARD"] == true) then 
		ModifyCharacterState(2, -1)
	end
end 
local jumped = 0
function SpacePress()
	if(characterStates[4] == 1) then
		skipBind = true
	elseif(keysHeld["SPRINT"] == false and characterStates[4] == 0 and lastLeftRight ~= 0 and lastBackForward == 0 and IsFalling() ~= 1) then
		ModifyCharacterState(4, 1)
		skipBind = true
	elseif(IsFalling() == 1) then
		if(lastBackForward == 1) then
			if(lastLeftRight == 1) then
				SendChatMessage(".cast 100021")
			elseif(lastLeftRight == -1) then
				SendChatMessage(".cast 100022")
			else
				SendChatMessage(".cast 100018")
			end  
			jumped = 1
		elseif(lastBackForward == -1) then
			if(lastLeftRight == 1) then
				SendChatMessage(".cast 100019")
			elseif(lastLeftRight == -1) then
				SendChatMessage(".cast 100020")
			else
				SendChatMessage(".cast 100011")
			end
		elseif(lastLeftRight == 1) then
			SendChatMessage(".cast 100017")
		elseif(lastLeftRight == -1) then
			SendChatMessage(".cast 100015")
		else
			SendChatMessage(".cast 100018")
		end 
	end
end


local gossiping = CreateFrame("Frame")
gossiping:RegisterEvent("GOSSIP_SHOW")
gossiping:RegisterEvent("GOSSIP_CLOSED")
gossiping:RegisterEvent("QUEST_DETAIL")
gossiping:RegisterEvent("QUEST_PROGRESS")
gossiping:RegisterEvent("QUEST_COMPLETE")
gossiping:RegisterEvent("QUEST_FINISHED")
gossiping:RegisterEvent("TRAINER_CLOSED")
gossiping:RegisterEvent("TRAINER_SHOW")
gossiping:RegisterEvent("LOOT_OPENED")
gossiping:RegisterEvent("LOOT_CLOSED")
gossiping:RegisterEvent("MERCHANT_SHOW")
gossiping:RegisterEvent("MERCHANT_CLOSED")
gossiping.openWindow = 0
gossiping.questStage = 0
gossiping.merchantSelection = 1
gossiping.gossip = false
gossiping.trainer = false
gossiping.merchant = false
gossiping.loot = false
gossiping.quest = false
gossiping.reward = -1
gossiping:SetScript("OnEvent", function(self, event)
	UpdateGossipFrame()
	if(event == "GOSSIP_SHOW") then
		if(self.gossip == false) then
			self.gossip = true
			self.openWindow = self.openWindow + 1
		end 
	elseif(event == "GOSSIP_CLOSED") then 
		if(self.gossip == true) then
			self.gossip = false
			self.openWindow = self.openWindow - 1
		end
	elseif(event == "QUEST_DETAIL") then
		if(self.quest == false) then
			self.openWindow = self.openWindow + 1 
			self.quest = true
			ModifyCharacterState(3, 1)
		end
		self.questStage = 1
	elseif(event == "QUEST_PROGRESS") then
		if(self.quest == false) then
			self.openWindow = self.openWindow + 1 
			self.quest = true
			ModifyCharacterState(3, 1)
		end
		self.questStage = 2
	elseif(event == "QUEST_COMPLETE") then
		if(self.quest == false) then
			self.openWindow = self.openWindow + 1 
			self.quest = true
			ModifyCharacterState(3, 1)
		end
		self.questStage = 3
		gossiping.reward = -1
	elseif(event == "QUEST_FINISHED") then
		if(self.quest == true) then
			self.openWindow = self.openWindow - 1
			self.quest = false
			ModifyCharacterState(3, -1)
		end 
		self.questStage = 0
	elseif(event == "TRAINER_CLOSED") then 
		if(self.trainer == true) then
			self.openWindow = self.openWindow - 1
			self.trainer = false
			ModifyCharacterState(3, -1)
		end
	elseif(event == "TRAINER_SHOW") then 
		if(self.trainer == false) then
			self.openWindow = self.openWindow + 1
			self.trainer = true
			ModifyCharacterState(3, 1)
		end
	elseif(event == "LOOT_OPENED") then 
		if(self.loot == false) then
			self.loot = true
			ModifyCharacterState(3, 1)
			self.openWindow = self.openWindow + 1 
		end
	elseif(event == "LOOT_CLOSED") then  
		if(self.loot == true) then
			self.loot = false
			ModifyCharacterState(3, -1)
			self.openWindow = self.openWindow - 1 
		end
	elseif(event == "MERCHANT_SHOW") then  
		if(self.merchant == false) then
			self.merchant = true
			ModifyCharacterState(3, 1)
			self.openWindow = self.openWindow + 1 
			self.merchantSelection = 1
		end 
	elseif(event == "MERCHANT_CLOSED") then  
		if(self.merchant == true) then
			self.merchant = false
			ModifyCharacterState(3, -1)
			self.openWindow = self.openWindow - 1
		end 
	end
end);
function EPress()
	if(gossiping.questStage == 1) then
		AcceptQuest()
	elseif(gossiping.questStage == 2) then
		CompleteQuest()
	elseif(gossiping.questStage == 3 and GetNumQuestChoices() == 0) then 
		GetQuestReward(nil)
	elseif(gossiping.trainer == true) then
		BuyTrainerService(GetTrainerSelectionIndex())
	elseif(gossiping.merchant == true) then
		BuyMerchantItem(gossiping.merchantSelection, 1)
	else
		ClearTarget()
		TargetNearest()
		if(CheckInteractDistance("target", 3) == 1) then
			InteractUnit("target")
	
		else
			ClearTarget()
		end
	end
end

local tabDur = -1
local tabDurConst = 0.2
local tabFocus = false
function TabPress() 
	skipBind = true
	if(gossiping.openWindow > 0) then 
		if(gossiping.trainer == true) then
			CloseTrainer()
		elseif(gossiping.questStage > 0) then
			CloseQuest()
		elseif(gossiping.merchant == true) then
			CloseMerchant()
		else
			CloseGossip()
		end
	else
		tabDur = 0
	end
end

function TabRelease()
	if(tabDur < tabDurConst) then
		RunBinding("TARGETNEARESTENEMY")
	end
	tabDur = -1
	if(tabFocus == true) then
		tabFocus = false
		ModifyCharacterState(3, -1)
	end
end 
function NUMPressDirect(num)
	local avQu = GetNumGossipAvailableQuests()
	local acQu = GetNumGossipActiveQuests()
	
	skipBind = true
	if(gossiping.openWindow > 0) then   
		if(gossiping.questStage == 3 and GetNumQuestChoices() > 0 and GetNumQuestChoices() >= num and num > 0) then 
			GetQuestReward(num) 
		elseif(num <= avQu) then
			SelectGossipAvailableQuest(num)
		elseif(num <= acQu + avQu) then
			SelectGossipActiveQuest(num - avQu)
		elseif(gossiping.openWindow > 0 and gossiping.questStage == 0) then
			SelectGossipOption((num - avQu) - acQu) 
			
		end
	else
		skipBind = false
	end
end
function NUMPress(number)
	local num = tonumber(string.sub(number, 13, 13))
	NUMPressDirect(num)
end
function UpdateButton()
	local butIn = (gossiping.merchantSelection % MERCHANT_ITEMS_PER_PAGE) 
	if(butIn == 0) then
		butIn = MERCHANT_ITEMS_PER_PAGE
	end 
	local itemButton = _G["MerchantItem"..butIn.."ItemButton"]; 
	MerchantItemButton_OnEnter(itemButton)
	GameTooltip:SetMerchantItem(gossiping.merchantSelection);
	GameTooltip_ShowCompareItem(GameTooltip);
	MerchantFrame.itemHover = gossiping.merchantSelection;
end
function MoveForwardPress()
	if(gossiping.trainer == true) then
		local trainerServiceCurr = GetTrainerSelectionIndex()
		if(trainerServiceCurr ~= nil and trainerServiceCurr < GetNumTrainerServices()) then 
			SelectTrainerService(trainerServiceCurr + 1)
		end
		skipBind = true
	elseif(gossiping.merchant == true) then
		if(gossiping.merchantSelection > 1) then
			gossiping.merchantSelection = gossiping.merchantSelection - 1 
			UpdateButton()
			if(gossiping.merchantSelection == MERCHANT_ITEMS_PER_PAGE) then 
				if(MerchantFrame.page ~= 1) then
					PlaySound("igMainMenuOptionCheckBoxOn");
					MerchantFrame.page = MerchantFrame.page - 1;
					MerchantFrame_Update();
				end
			end
		end
		skipBind = true
	end
end
function MoveBackwardPress()
	if(gossiping.trainer == true) then
		local trainerServiceCurr = GetTrainerSelectionIndex()
		if(trainerServiceCurr ~= nil and trainerServiceCurr > 1) then 
			SelectTrainerService(trainerServiceCurr - 1)
		end
		skipBind = true
	elseif(gossiping.merchant == true) then
		if(gossiping.merchantSelection < GetMerchantNumItems()) then
			gossiping.merchantSelection = gossiping.merchantSelection + 1 
			UpdateButton()
			if(gossiping.merchantSelection == MERCHANT_ITEMS_PER_PAGE + 1) then 
				if(MerchantFrame.page ~= ceil(GetMerchantNumItems() / MERCHANT_ITEMS_PER_PAGE)) then
					PlaySound("igMainMenuOptionCheckBoxOn");
					MerchantFrame.page = MerchantFrame.page + 1;
					MerchantFrame_Update();
				end
			end
		end
		skipBind = true
	end
end
function StrafeLeftPress()
	if(gossiping.merchant == true) then
		if(MerchantFrame.page ~= 1) then
			if(gossiping.merchantSelection % MERCHANT_ITEMS_PER_PAGE == 1) then
				PlaySound("igMainMenuOptionCheckBoxOn");
				MerchantFrame.page = MerchantFrame.page - 1;
				gossiping.merchantSelection = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + 10
				UpdateButton()
				MerchantFrame_Update();
			else
				gossiping.merchantSelection = (gossiping.merchantSelection - (gossiping.merchantSelection  % MERCHANT_ITEMS_PER_PAGE)) + 1 
				UpdateButton()
			end
		end
		skipBind = true
	end
end
function StrafeRightPress()
	if(gossiping.merchant == true) then 
		if(MerchantFrame.page ~= ceil(GetMerchantNumItems() / MERCHANT_ITEMS_PER_PAGE)) then
			if(gossiping.merchantSelection % MERCHANT_ITEMS_PER_PAGE == 0) then
				PlaySound("igMainMenuOptionCheckBoxOn");
				MerchantFrame.page = MerchantFrame.page + 1;
				gossiping.merchantSelection = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + 1
				UpdateButton()
				MerchantFrame_Update();
			else
				gossiping.merchantSelection = (gossiping.merchantSelection - (gossiping.merchantSelection  % MERCHANT_ITEMS_PER_PAGE)) + 10 
				if(gossiping.merchantSelection > GetMerchantNumItems()) then
					gossiping.merchantSelection =  gossiping.merchantSelection - (GetMerchantNumItems() % MERCHANT_ITEMS_PER_PAGE)
				end
				UpdateButton()
			end
		end
		skipBind = true
	end
end

local keyPress = {
	Before = {
		JUMP = SpacePress,
		ACTIONBUTTON1 = NUMPress,
		ACTIONBUTTON2 = NUMPress,
		ACTIONBUTTON3 = NUMPress,
		ACTIONBUTTON4 = NUMPress,
		ACTIONBUTTON5 = NUMPress,
		ACTIONBUTTON6 = NUMPress,
		ACTIONBUTTON7 = NUMPress,
		ACTIONBUTTON8 = NUMPress,
		ACTIONBUTTON9 = NUMPress, 
		MOVEFORWARD = MoveForwardPress,
		MOVEBACKWARD = MoveBackwardPress,
		STRAFELEFT = StrafeLeftPress,
		STRAFERIGHT = StrafeRightPress,
		TARGETNEARESTENEMY = TabPress,
	},
	After = { 
		SPRINT = ShiftPress,
		MOVEFORWARD = ShiftPress,
		EInteract = EPress,
	}
}
local keyRelease = {
	Before = {

	},
	After = {
		TARGETNEARESTENEMY = TabRelease,
		SPRINT = ShiftRelease,
		MOVEFORWARD = ShiftRelease
	}
}
function BeforeKeyPress(key, up)
	if(up == true and (keysHeld[key] == nil or keysHeld[key] == false)) then
		if(keyPress.Before[key] ~= nil) then
			keyPress.Before[key](key)
		end
	elseif(up == false and keysHeld[key] == true) then
		if(keyRelease.Before[key] ~= nil) then
			keyRelease.Before[key](key)
		end
	end
end
function OnKeyPress(key, up)
	if(up == true and (keysHeld[key] == nil or keysHeld[key] == false)) then 
		keysHeld[key] = true
		if(keyPress.After[key] ~= nil) then
			keyPress.After[key](key)
		end
	elseif(up == false and keysHeld[key] == true) then 
		keysHeld[key] = false
		if(keyRelease.After[key] ~= nil) then
			keyRelease.After[key](key)
		end
	end
end

local inputKey = CreateFrame("Frame");
inputKey:EnableKeyboard(true)
inputKey:SetScript("OnKeyDown", function(self, key)  
	local bind = GetBindingFromClick(key) 
	if(bind == "STRAFERIGHT") then
		bind = "EInteract"
	elseif(bind == "TURNLEFT") then
		bind = "STRAFELEFT"
	elseif(bind == "TURNRIGHT") then
		bind = "STRAFERIGHT"
	end  
	if(bind ~= nil) then
		BeforeKeyPress(bind, true)
		if(keyEnables[bind] == nil or keyEnables[bind] >= 0) then
			if(skipBind == true) then
				skipBind = false
			else
				RunBinding(bind)
			end
		end
		OnKeyPress(bind, true)
		if(bind == "MOVEFORWARD") then
			lastBackForward = 1
		elseif(bind == "MOVEBACKWARD") then
			lastBackForward = -1
		elseif(bind == "STRAFELEFT") then
			lastLeftRight = -1
		elseif(bind == "STRAFERIGHT") then
			lastLeftRight = 1
		end
	end
	if(key == "LSHIFT") then
		BeforeKeyPress("SPRINT", true)
		OnKeyPress("SPRINT", true)
	end 
end)
inputKey:SetScript("OnKeyUp", function(self, key)   
	local bind = GetBindingFromClick(key)
	 
	if(bind == "STRAFERIGHT") then
		bind = "EInteract"
	elseif(bind == "TURNLEFT") then
		bind = "STRAFELEFT"
	elseif(bind == "TURNRIGHT") then
		bind = "STRAFERIGHT"
	end

	if(bind ~= nil) then
		BeforeKeyPress(bind, false)
		if(keyEnablesUp[bind] == nil or keyEnablesUp[bind] >= 0) then
			if(skipBind == true) then
				skipBind = false
			else
				RunBinding(bind, "up")
			end
		end
		OnKeyPress(bind, false)
		if(bind == "MOVEFORWARD") then
			if(keysHeld["MOVEBACKWARD"] == true) then
				lastBackForward = -1
			else
				lastBackForward = 0
			end
		elseif(bind == "MOVEBACKWARD") then
			if(keysHeld["MOVEFORWARD"] == true) then
				lastBackForward = 1
			else
				lastBackForward = 0
			end
		elseif(bind == "STRAFELEFT") then
			if(keysHeld["STRAFERIGHT"] == true) then
				lastLeftRight = 1
			else
				lastLeftRight = 0
			end
		elseif(bind == "STRAFERIGHT") then
			if(keysHeld["STRAFELEFT"] == true) then
				lastLeftRight = -1
			else
				lastLeftRight = 0
			end
		end
	end
	if(key == "LSHIFT") then
		BeforeKeyPress("SPRINT", false)
		OnKeyPress("SPRINT", false)
	end 
end) 




local turnWrap = 0
function TurnOrActionStopWrap()
	turnWrap = 1
	TurnOrActionStop()
end
function TurnOrActionStartWrap()
	turnWrap = 0
	TurnOrActionStart()
end
 

local movingForward = false
hooksecurefunc( "MoveForwardStart", function()
	movingForward = true
end ); 
hooksecurefunc( "MoveForwardStop", function()
	movingForward = false
end ); 
local movingBackward = false
hooksecurefunc( "MoveBackwardStart", function()
	movingBackward = true
end ); 
hooksecurefunc( "MoveBackwardStop", function()
	movingBackward = false
end ); 
hooksecurefunc( "JumpOrAscendStart", function()
	jumped = 1 
end );  
hooksecurefunc( "InteractUnit", function()
	
end );  

local camDist = {
	BloodElf3 = 0.25, -- female
	BloodElf2 = 0.275, -- male
	Undead3 = 0.225, -- female
	Undead2 = 0.25, -- male
	Tauren3 = 0.6, -- female
	Tauren2 = 0.9, -- male
	Orc3 = 0.3, -- female
	Orc2 = 0.4, -- male
	Troll3 = 0.3, -- female
	Troll2 = 0.4, -- male
	Human3 = 0.3, -- female
	Human2 = 0.4, -- male
	NightElf3 = 0.3, -- female
	NightElf2 = 0.4, -- male
	Draenei3 = 0.4, -- female
	Draenei2 = 0.5, -- male
	Dwarf3 = 0.3, -- female
	Dwarf2 = 0.4, -- male
	Gnome3 = 0.2, -- female
	Gnome2 = 0.2, -- male
}
local attackHeld = 0
local defenseHeld = 0
local tick = CreateFrame("Frame")  

tick:HookScript("OnUpdate", function(self, elapsed)
	function Initialize()
		local sexRace = UnitRace("player"):gsub("%s+", "")..UnitSex("player")
		 
		MouselookStart() 
		SetCVar("cameraDistanceMaxFactor", camDist[sexRace]) 
		SetCVar("cameraPitchMoveSpeed", 0.001) 
		for i = 1, #keys do
			keysHeld[keys[i]] = false
			keyEnables[keys[i]] = 0
			keyEnablesUp[keys[i]] = 0
		end
		RunBinding("CAMERAZOOMOUT")
	end
	if(timeElapsed == 0) then
		Initialize()
		timeElapsed = timeElapsed + 1
	else
		if(keysHeld["SPRINT"] == true and IsShiftKeyDown() == nil) then	 
			BeforeKeyPress("SPRINT", false)
			OnKeyPress("SPRINT", false)
		end 
	end
	if(IsMouseButtonDown("LeftButton")and characterState ~= 3 and gossiping.openWindow == 0 and focused == false) then
		if(attackHeld == 0) then 
			SendChatMessage(".cast 100003")
			attackHeld = attackHeld + elapsed
		end  

	elseif(attackHeld > 0) then
		attackHeld = 0
	end
	if(IsMouseButtonDown("RightButton") and characterState ~= 3 and gossiping.openWindow == 0 and focused == false) then
		if(defenseHeld == 0) then 
			SendChatMessage(".cast 100006")
			defenseHeld = defenseHeld + elapsed
		end 
	elseif(defenseHeld > 0) then
		defenseHeld = 0
	end

	if(tabDur ~= -1 and tabDur < tabDurConst) then
		tabDur = tabDur + elapsed
		if(tabDur >= tabDurConst) then 
			ModifyCharacterState(3, 1)
			tabFocus = true
		end
	end

	local pitch = GetUnitPitch("player")
	if(angle ~= pitch) then 
		angle = pitch
		angleMoved = pitch
	end
	if(angleMoved < maxPitchAngle and turnWrap == 0) then
		MoveViewDownStart(speedPitchAngle/tonumber(GetCVar("cameraPitchMoveSpeed"))) -- moves down at 10 degrees/sec
		angleMoved = angleMoved + speedPitchAngle * elapsed * 0.01745329 -- radian to degree
	elseif(angleMoved > minPitchAngle and turnWrap == 0) then
		MoveViewDownStart(-1 * speedPitchAngle/tonumber(GetCVar("cameraPitchMoveSpeed"))) -- moves down at 10 degrees/sec
		angleMoved = angleMoved + -1 * speedPitchAngle * elapsed * 0.01745329 -- radian to degree
	else
		MoveViewDownStart(0)
	end

	if (characterState ~= 3) then
		if (focused == true) then 
			RPGFocusOff()
		end
		if(characterState == 2 and sprinting == false) then
			SprintOn()
		end
	end 
	if(sprintCD > 0) then
		sprintCD = sprintCD - elapsed
	end
	if(dashing == true) then
		dashDuration = dashDuration - elapsed
		if(dashDuration <= 0) then
			ModifyCharacterState(4, -1)
		end
	end  
	
	if(jumped == 1) then -- replace with something that runs on ascend to be more optimized.
		if(IsFalling() == nil) then
			if(lastBackForward == 1) then
				RunBinding("MOVEFORWARD", "up")
				RunBinding("MOVEFORWARD")
			end
			jumped = 0
		end
	end
	if(movingForward == true and keyPress["MOVEFORWARD"] == false) then
		MoveForwardStop()
	end
	if(movingBackward == true and keyPress["MOVEBACKWARD"] == false) then
		MoveBackwardStop()
	end
end)  

local insp = CreateFrame("Frame")
insp:RegisterEvent("UNIT_INVENTORY_CHANGED")

insp:SetScript("OnEvent", function(self, event) 
end)

