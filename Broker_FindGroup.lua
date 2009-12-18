-- Broker_FindGroup by yess, yessica@fantasymail.de
local ldb = LibStub:GetLibrary("LibDataBroker-1.1",true)
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_FindGroup")
local dataobj
local path = "Interface\\AddOns\\Broker_FindGroup\\media\\"

local function Debug(...)
	 --@debug@
	local s = "Broker_FindGroup Debug:"
	for i=1,select("#", ...) do
		local x = select(i, ...)
		s = strjoin(" ",s,tostring(x))
	end
	DEFAULT_CHAT_FRAME:AddMessage(s)
	--@end-debug@
end

local function GetTimeString(seconds)
	if seconds then
		local min = (seconds / 60)
		local sec = mod(seconds, 60)
		--[[
		if( sec < 10) then
				-- add zero 
			return string.format("%i:0%i", min, sec)
		end
		return string.format("%i:%i", min, sec)
		--]]
		return seconds > 0 and (sec < 10 and string.format("%i:%0i", min, sec) or string.format("%i:%i", min, sec)) or "-"
	end
end

local function Onclick(self, button, ...) 
	if button == "RightButton" then
		-- teleport
		if ( IsInLFGDungeon() ) then
				LFGTeleport(true)
		elseif ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
				LFGTeleport(false)
		--[[
		else -- or join/leave
			local mode, submode = GetLFGMode();
			if not mode then
				LFDQueueFrameFindGroupButton:GetScript("OnClick")(self, button, ...)
			elseif mode == "queued" or mode == "listed" then
				LeaveLFG()
			end
		--]]
		end		
	else
		LFDMicroButton:GetScript("OnClick")(self, button, ...) 	
	end
end

dataobj = ldb:NewDataObject("Broker_FindGroup", {
	type = "data source",
	icon = path.."lfg.tga",
	label = "FindGroup",
	text  = "",
	OnClick = Onclick
})

local function UpdateText()
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait = GetLFGQueueStats();
	if (hasData) then
		local dpshas = 3 - dpsNeeds 
		local text=""
		local green = "|cff00ff00"
		local red = "|cffdd3a00"
		local tankColor = green
		local damageColor = green
		local healerColor = green
		if tankNeeds > 0 then
			tankColor = red
		end
		if healerNeeds > 0  then
			healerColor = red
		end
		if dpsNeeds > 0 then
			damageColor = red
		end
		if instanceType == 261 then
			instanceName = "Normal"
		elseif instanceType == 262 then
			instanceName = "Heroic"
		else
			--instanceName = "Custom"
		end
		dataobj.text = string.format("%s: %s%s|r/%s%s|r/%s%s %i|r",instanceName, tankColor,L["Tank"], healerColor,L["Healer"], damageColor,L["DPS"], dpshas)
		--dataobj.OnEnter = MiniMapLFGFrame_OnEnter
	else
		local mode, submode = GetLFGMode();
		if mode == "lfgparty" then
			dataobj.text = L["In Party"]
		elseif mode == "queued" then
			dataobj.text = L["Assembling group..."]
		else
			dataobj.text = L["Find Group"]
		end
	end
end

function dataobj:OnEnter()
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait = GetLFGQueueStats();
	local mode, submode = GetLFGMode();
	local tooltip = GameTooltip 
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	--dataobj.OnTooltipShow(GameTooltip)

	if mode == "lfgparty" then 
		if ( IsInLFGDungeon() ) then
			tooltip:AddLine(L["Right click to teleport out."])
		elseif ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
			tooltip:AddLine(L["Right click to teleport in."])
		end
	elseif (mode == "queued" or mode == "listed") and instanceName then
		tooltip:AddLine(L["Queued for: "]..instanceName )
		tooltip:AddLine(" " )
		tooltip:AddDoubleLine("My wait time",GetTimeString(myWait),1,1,1)
		tooltip:AddLine(" " )
		--yTooltip:AddDoubleLine("Left", "Right", 1,0,0, 0,0,1);
		tooltip:AddLine("Wait time as:" )
		tooltip:AddDoubleLine(L["DPS"],GetTimeString(damageWait),1,1,1)
		tooltip:AddDoubleLine(L["Healer"],GetTimeString(healerWait),1,1,1)
		tooltip:AddDoubleLine(L["Tank"],GetTimeString(tankWait),1,1,1)
		tooltip:AddLine(" " )
		tooltip:AddDoubleLine("Average wait time:",GetTimeString(averageWait),1,1,1)
	else
		tooltip:AddLine(L["Click to open the dungeon finder."])
	end
	
	
	
	
	--@debug@
	tooltip:AddLine(" " )
	tooltip:AddLine("Debug:")
	tooltip:AddDoubleLine("instanceType",instanceType)
	tooltip:AddDoubleLine("LFDQueueFrame.type",LFDQueueFrame.type)
	--UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
	tooltip:AddDoubleLine("GetLFGMode() mode", mode)
	tooltip:AddDoubleLine("GetLFGMode() submode", submode)
	--@end-debug@
	tooltip:Show()
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end

local function OnEvent(self, event, ...)
	--DEFAULT_CHAT_FRAME:AddMessage(event)
	--Debug("OnEvent", event)
	UpdateText()
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
frame:RegisterEvent("LFG_PROPOSAL_UPDATE");
frame:RegisterEvent("LFG_PROPOSAL_SHOW");
frame:RegisterEvent("LFG_PROPOSAL_FAILED");
frame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
frame:RegisterEvent("LFG_UPDATE");
frame:RegisterEvent("LFG_ROLE_CHECK_SHOW");
frame:RegisterEvent("LFG_ROLE_CHECK_HIDE");
frame:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
frame:RegisterEvent("LFG_ROLE_UPDATE");
frame:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
--frame:RegisterAllEvents()
UpdateText()