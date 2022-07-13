

--Readability == win
local FirstTime = true;
local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;
 
local MIN_RUNE_ALPHA = 0

local iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood";
iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death";

local runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}

local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
runeMapping = {
	[1] = "BLOOD",
	[2] = "UNHOLY",
	[3] = "FROST",
	[4] = "DEATH",
}

local config = {
	Prefix = "RuneSync",
	Functions = {
		[1] = "OnCacheReceived",
		[2] = "OnRuneSyncReceived",
	}
}


local RuneSync = {
	cache = {},
	tempDev = 0
} 
function RuneSync.OnLogin() 
	SendClientRequest(config.Prefix, 1)
end

function OnCacheReceived(sender, argTable)
	RuneSync.cache = argTable[1]  
end
 
RegisterServerResponses(config)
 
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function() RuneSync.OnLogin() end)
   

function OnRuneSyncReceived(sender, argTable)  
	for i = 1, #argTable/2 do 
		RuneFrame.runes[i]:SetScript("OnUpdate", RuneButton_OnUpdate);  
		RuneFrame.runes[i].cd = argTable[i*2 - 1]
		RuneFrame.runes[i].scd = argTable[i*2] 
		RuneFrame.runes[i].el = 0
	end
	
	local change = false 

	for i = 1, #RuneFrame.runes - 1 do
		for i1 = 1, #RuneFrame.runes - 1 do 
			
			local cooldown1 = RuneFrame.runes[i1].cd
			local cooldown2 = RuneFrame.runes[i1 + 1].cd 
			if (cooldown1 > cooldown2) then 
				local temp = RuneFrame.runes[i1]
				RuneFrame.runes[i1] = RuneFrame.runes[i1 + 1];
				RuneFrame.runes[i1 + 1] = temp 
				change = true 
			end  
		end
	end
	for i = 1, #RuneFrame.runes - 1 do
		for i1 = 1, #RuneFrame.runes - 1 do  
			local cooldown1 = RuneFrame.runes[i1].cd
			local cooldown2 = RuneFrame.runes[i1 + 1].cd
			 
			if (cooldown1  > 0 and cooldown2 > 0 and cooldown1 > cooldown2) then
				local temp = RuneFrame.runes[i1]
				RuneFrame.runes[i1] = RuneFrame.runes[i1 + 1];
				RuneFrame.runes[i1 + 1] = temp 
				change = true
			end  
		end
	end
	
	if(change) then  
		for k, v in next, RuneFrame.runes do  
			if(k == 1) then
				RuneFrame.runes[k]:SetPoint("LEFT", "RuneFrame", "LEFT")
			else
				RuneFrame.runes[k]:SetPoint("LEFT", RuneFrame.runes[tonumber(k) - 1], "RIGHT", 3, 0) 
			end 
		end
	end 
end
 
local inte = 0

function RuneButton_OnLoad (self)
	RuneFrame_AddRune(RuneFrame, self);
	
	self.rune = _G[self:GetName().."Rune"];
	self.fill = _G[self:GetName().."Fill"];
	self.shine = _G[self:GetName().."ShineTexture"];
	RuneButton_Update(self);
	
end

function RuneButton_OnUpdate (self, elapsed)  
	local id = self:GetID()
	
	local start, duration = 1;
	self.el = self.el + elapsed * 1000

	start = self.scd
	duration = self.cd
  
	  
	-- CooldownFrame_SetTimer(cooldown, start, duration, displayCooldown);  
	local cooldown = (start - (duration - self.el))/start 
	self:SetAlpha(math.max(MIN_RUNE_ALPHA, cooldown * cooldown));   
	if ( duration == 0 or cooldown >= 0.99 ) then 
		self:SetAlpha(1);
		self:SetScript("OnUpdate", nil); 
		self.el = 0
		self.cd = 0
		self.scd = 0
		
		self.rune:SetTexture(iconTextures[2]);
		if(duration > 0) then
			RuneButton_ShineFadeIn(self.shine)
		end
	else
		self.rune:SetTexture(runeTextures[2]);
	end
end

function RuneButton_Update (self, rune, dontFlash)
	rune = rune or self:GetID();
	
	local runeType = RUNETYPE_UNHOLY;
	if ( (not dontFlash) and (runeType) and (runeType ~= self.rune.runeType)) then
		self.shine:SetVertexColor(unpack(runeColors[runeType]));
	end
	
	if (runeType) then
		self.rune:SetTexture(iconTextures[runeType]);
		-- self.fill:SetTexture(iconTextures[runeType]);
		self.rune:Show();
		-- self.fill:Show();
		self.rune.runeType = runeType;
		self.tooltipText = _G["COMBAT_TEXT_RUNE_"..runeMapping[runeType]];
	else
		self.rune:Hide();
		-- self.fill:Hide();
		self.tooltipText = nil;
	end 
end
 

function RuneFrame_OnLoad (self)
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");
	
	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
	end
	
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self:SetScript("OnEvent", RuneFrame_OnEvent);
	
	self.runes = {};
end

function RuneFrame_OnEvent (self, event, ...) 
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( FirstTime ) then
			RuneFrame_FixRunes(self);
			FirstTime = false;
		end
		for rune in next, self.runes do
			RuneButton_Update(self.runes[rune], rune, true);
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local rune, usable = ...;
		if ( rune and self.runes[rune] ) then 
			self.runes[rune].shine:SetVertexColor(1, 1, 1); 
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local rune = ...;
		if ( rune ) then
			RuneButton_Update(self.runes[rune], rune);
		end
	end
end

function RuneFrame_AddRune (runeFrame, rune)
	tinsert(runeFrame.runes, rune);
end

function RuneFrame_FixRunes	(runeFrame)	--We want to swap where frost and unholy appear'
	local temp;
	
	temp = runeFrame.runes[3];
	runeFrame.runes[3] = runeFrame.runes[5];
	runeFrame.runes[5] = temp;
	
	temp = runeFrame.runes[4];
	runeFrame.runes[4] = runeFrame.runes[6];
	runeFrame.runes[6] = temp;
	 
	for k, v in next, runeFrame.runes do 
		RuneFrame.runes[k].cd = 0
		RuneFrame.runes[k].scd = 0 
		RuneFrame.runes[k].el = 0
	end
end

function RuneButton_ShineFadeIn(self)
	if self.shining then
		return
	end
	local fadeInfo={
	mode = "IN",
	timeToFade = 0.5,
	finishedFunc = RuneButton_ShineFadeOut,
	finishedArg1 = self,
	}
	self.shining=true;
	UIFrameFade(self, fadeInfo);
end

function RuneButton_ShineFadeOut(self)
	self.shining=false;
	UIFrameFadeOut(self, 0.5);
end
