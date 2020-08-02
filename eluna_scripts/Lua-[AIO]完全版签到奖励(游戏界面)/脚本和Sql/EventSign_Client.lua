
local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local EventSignHandlers = AIO.AddHandlers("EventSignStore", {})

local SignYear  = 2018          --签到的年份
local SignMonth = 12             --签到的月份
local SignNowDay= 14             --签到的起始日
local SignCount = 14            --需要连续签到的天数 -- 最大框架14天 注意: (起始日+设定的天数不能大于本月天数)

local So = "1"            --标识 表示已签到
local Sn = "0"            --标识 表示未签到
local Sp = ":"            --分割符

local Alls = string.rep(So..Sp, SignCount)

local DayButtons = {}
local DayStrings = {}

local SubSpFrame = {}
local SubSpStr = {}

local SubSuccessStr = {}

local ButtonLink = {}
local ButtonLinkStr = {}
local ButtonCountStr = {}

local StateList = {}

local MaxTabKey = 6 --当前最大6组

-- 第二维当前最大MaxTabKey组 需要增减的话自行修改数组 和 MaxTabKey
-- {0, 0}相当于不奖励 没有物品
-- 客户端和服务端此表一致
local SignItemData = {
	                {{35622, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第1天奖励
	                {{35623, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第2天奖励
	                {{35624, 3}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第3天奖励
	                {{35625, 4}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第4天奖励
	                {{35626, 5}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第5天奖励
					{{35627, 6}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第6天奖励
					{{11184, 7}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第7天奖励
					{{11185, 8}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第8天奖励
					{{11186, 9}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第9天奖励
					{{11188, 10}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第10天奖励
					{{10978, 11}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第11天奖励
					{{11084, 12}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第12天奖励
					{{11138, 13}, {0, 0}, {0, 0}, {19019, 1}, {0, 0}, {0, 0}},                                                --第13天奖励
					{{11139, 14}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},                                                --第14天奖励
					{{43118, 1}, {43122, 1}, {43124, 1}, {43127, 1}, {0, 0}, {0, 0}},                                     --连续达成14天奖励
}

local Clicks = 0
local _, MaxMonth, _, MaxYear = CalendarGetMaxDate()
local _, MinMonth, _, MinYear = CalendarGetMinDate()

function MeSetTexture(Button, File)
    local ButtonTexture = Button:CreateTexture("ButtonTexture")
    ButtonTexture:SetAllPoints(Button)
    ButtonTexture:SetTexture(File)
	Button:SetNormalTexture(ButtonTexture)
end

function IsInSign(d, n)
    for i=SignNowDay,n,1 do
        if (d == i) then
		    return true
		end
	end
	return false
end

function MeSetBackdrop(Button, BgFile, EdgeFile)
    Button:SetBackdrop(
                {
                    bgFile = BgFile,
					edgeFile = EdgeFile,
                    edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
end

function EventSignHandlers.ShowSignState(player, list, RepairItem, LinkRepairItem, RepairCount)
    StateList = list
	RepairText:SetText("提示: 签到免费领取奖励 补签需要 |T"..GetItemIcon(RepairItem)..":24|t "..LinkRepairItem.." X "..RepairCount.." 个")
	for i=1,SignCount + 1,1 do
	    if (i < SignCount + 1) then
	        if (tonumber(StateList[i]) == 1) then
		        SubSuccessStr[i]:SetText("|cFF00FF00已签|r")
		    else
			    SubSuccessStr[i]:SetText("|cFF999999未签|r")
			end
		else
		    if (tostring(table.concat(StateList)) == Alls) then
		        SubSuccessStr[i]:SetText("|cFF00FF00已经完成|r")
		    else
			    SubSuccessStr[i]:SetText("|cFF00FF00尚未完成|r")
			end
		end
	end
end

local EventSignFrame = CreateFrame("Frame", "EventSignFrame", UIParent)
EventSignFrame:SetSize(480, 560)
EventSignFrame:RegisterForDrag("LeftButton")
EventSignFrame:SetPoint("CENTER")
EventSignFrame:SetToplevel(true)
EventSignFrame:SetClampedToScreen(true)
EventSignFrame:SetMovable(true)
EventSignFrame:EnableMouse(true)
EventSignFrame:SetScript("OnDragStart", EventSignFrame.StartMoving)
EventSignFrame:SetScript("OnDragStop", EventSignFrame.StopMovingOrSizing)
EventSignFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

EventSignFrame:SetScript("OnHide", 
function(self)
	    self:StopMovingOrSizing()
        AIO.Handle("EventSignStore", "ShowMeSignState")
end)
	

tinsert(UISpecialFrames, "EventSignFrame")

EventSignFrame:Hide()

-- 初始框
local EventSignFrameMin = CreateFrame("Button", "EventSignFrameMin", UIParent)
EventSignFrameMin:SetSize(64, 64)
EventSignFrameMin:SetPoint("CENTER", 600, -280)
EventSignFrameMin:SetMovable(true)
EventSignFrameMin:EnableMouse(true)
EventSignFrameMin:RegisterForDrag("LeftButton")
EventSignFrameMin:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
EventSignFrameMin:SetBackdrop({bgFile = "Interface\\Icons\\Inv_Misc_Tournaments_banner_Nightelf"})
EventSignFrameMin:SetScript("OnDragStart", EventSignFrameMin.StartMoving)
EventSignFrameMin:SetScript("OnDragStop", EventSignFrameMin.StopMovingOrSizing)
EventSignFrameMin:SetScript("OnMouseUp", 
function(self)
    if (EventSignFrame:IsShown()) then
        EventSignFrame:Hide()
    else
        EventSignFrame:Show()
		SpFrame:Hide()
    end
end)

EventSignFrameMin:SetScript("OnEnter", 
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip.default = 1
        GameTooltip:SetText("|cFFFF0033签到奖励|r\n|cFFFFCC66按住拖动图标|r\n|cFF99FF33单击打开功能|r\n|cFF00CCFF再次单击关闭|r\n|cFF00CCFF按 Esc 键退出|r")
        GameTooltip:Show()
    end)

EventSignFrameMin:SetScript("OnLeave", 
    function(self)
        GameTooltip:Hide()
    end)

EventSignFrameMin:Show()

-- 关闭按钮
local EventSignFrameClose = CreateFrame("Button", "EventSignFrameClose", EventSignFrame, "UIPanelCloseButton")
EventSignFrameClose:SetPoint("TOPRIGHT", 15, 15)
EventSignFrameClose:EnableMouse(true)
EventSignFrameClose:SetSize(36, 36)

-- 标题模块
local EventSignTitle = CreateFrame("Frame", "EventSignTitle", EventSignFrame, nil)
EventSignTitle:SetSize(150, 30)
EventSignTitle:SetPoint("TOP", 0, 25)
EventSignTitle:EnableMouse(true)
EventSignTitle:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--标题模块文字描述
local EventSignTitleText = EventSignTitle:CreateFontString("EventSignTitleText")
EventSignTitleText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 18)
EventSignTitleText:SetPoint("CENTER", 0, 0)
EventSignTitleText:SetText("|cffFFC125签到奖励|r")

-- 下边文字
local SignTisText = EventSignFrame:CreateFontString("SignTisText")
SignTisText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 13)
SignTisText:SetPoint("CENTER", 0, -190)
SignTisText:SetVertexColor(255/255, 102/255, 0)
SignTisText:SetText("签到范围: |cFF00FF00"..SignYear.."|r年|cFFFFFF00"..SignMonth.."|r月|cFFFFFF00"..SignNowDay.."|r至|cFFFFFF00"..(SignNowDay + SignCount - 1).."|r日 共|cFFFFFF00"..SignCount.."|r天周期 点击日期签到/补签")

-- 补签文字
local RepairText = EventSignFrame:CreateFontString("RepairText")
RepairText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 13)
RepairText:SetPoint("CENTER", 0, -220)
RepairText:SetVertexColor(0, 255/255, 0)

-- 年份文字
local SignYearText = EventSignFrame:CreateFontString("SignYearText")
SignYearText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 18)
SignYearText:SetPoint("TOPLEFT", 108, -28)

-- 月份选项左
local EventSignMonthButtonLeft = CreateFrame("Button", "EventSignMonthButtonLeft", EventSignFrame)
EventSignMonthButtonLeft:SetSize(30, 30)
EventSignMonthButtonLeft:SetPoint("TOPLEFT", 200, -20)
EventSignMonthButtonLeft:EnableMouse(true)
EventSignMonthButtonLeft:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
EventSignMonthButtonLeft:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
EventSignMonthButtonLeft:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
EventSignMonthButtonLeft:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")

-- 月份选项右
local EventSignMonthButtonRight = CreateFrame("Button", "EventSignMonthButtonRight", EventSignFrame)
EventSignMonthButtonRight:SetSize(30, 30)
EventSignMonthButtonRight:SetPoint("TOPLEFT", 320, -20)
EventSignMonthButtonRight:EnableMouse(true)
EventSignMonthButtonRight:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
EventSignMonthButtonRight:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
EventSignMonthButtonRight:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
EventSignMonthButtonRight:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")

-- 中间月份
local EventSignMonthButtonCenter = CreateFrame("Button", "EventSignMonthButtonCenter", EventSignFrame)
EventSignMonthButtonCenter:SetSize(94, 28)
EventSignMonthButtonCenter:SetPoint("TOPLEFT", 228, -20)
EventSignMonthButtonCenter:EnableMouse(true)
EventSignMonthButtonCenter:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

-- 月份说明
local ButtonCenterStr  = EventSignMonthButtonCenter:CreateFontString("ButtonCenterStr")
ButtonCenterStr:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 15)
ButtonCenterStr:SetPoint("CENTER")

-- 星期1-7
local SignWeekday1 = CreateFrame("Button", "SignWeekday1", EventSignFrame)
local SignWeekday2 = CreateFrame("Button", "SignWeekday2", EventSignFrame)
local SignWeekday3 = CreateFrame("Button", "SignWeekday3", EventSignFrame)
local SignWeekday4 = CreateFrame("Button", "SignWeekday4", EventSignFrame)
local SignWeekday5 = CreateFrame("Button", "SignWeekday5", EventSignFrame)
local SignWeekday6 = CreateFrame("Button", "SignWeekday6", EventSignFrame)
local SignWeekday7 = CreateFrame("Button", "SignWeekday7", EventSignFrame)

local WeekdayStr1  = SignWeekday1:CreateFontString("WeekdayStr1")
local WeekdayStr2  = SignWeekday2:CreateFontString("WeekdayStr2")
local WeekdayStr3  = SignWeekday3:CreateFontString("WeekdayStr3")
local WeekdayStr4  = SignWeekday4:CreateFontString("WeekdayStr4")
local WeekdayStr5  = SignWeekday5:CreateFontString("WeekdayStr5")
local WeekdayStr6  = SignWeekday6:CreateFontString("WeekdayStr6")
local WeekdayStr7  = SignWeekday7:CreateFontString("WeekdayStr7")

for i=1,7,1 do
    _G["SignWeekday"..i]:SetSize(60, 30)
	_G["SignWeekday"..i]:SetPoint("TOPLEFT", (i - 1) * 60 + 30, -60)
	_G["SignWeekday"..i]:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
	_G["SignWeekday"..i]:SetHighlightTexture("Interface\\Buttons\\UI-QuickslotRed")
	
	_G["WeekdayStr"..i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 15)
	_G["WeekdayStr"..i]:SetPoint("CENTER")
end

for i=1,42,1 do
    DayButtons[i] = CreateFrame("Button", "DayButton"..i, EventSignFrame)
	--DayButtons[i]:SetID(i)
	DayButtons[i]:SetSize(60, 60)
	if (i < 8) then
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 1) * 60 + 30, -90)
	elseif (i > 7 and i < 15) then
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 7 - 1) * 60 + 30, -150)
	elseif (i > 14 and i < 22) then
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 14 - 1) * 60 + 30, -210)
    elseif (i > 21 and i < 29) then
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 21 - 1) * 60 + 30, -270)
	elseif (i > 28 and i < 36) then
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 28 - 1) * 60 + 30, -330)
    else
	    DayButtons[i]:SetPoint("TOPLEFT", (i - 35 - 1) * 60 + 30, -390)
	end
	
	MeSetBackdrop(DayButtons[i], "Interface\\DialogFrame\\UI-DialogBox-Background", "Interface\\Tooltips\\UI-Tooltip-Border")
	DayButtons[i]:SetHighlightTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	
	DayButtons[i]:SetScript("OnClick",
    function(self)
	    UpDateSignDay(i)
    end)
	
	DayButtons[i]:SetScript("OnEnter", 
    function(self)
	    for k=1,7,1 do
		    if ((i - k) % 7 == 0) then
				_G["SignWeekday"..k]:LockHighlight()
			end
		end
    end)

    DayButtons[i]:SetScript("OnLeave", 
    function(self)
	    for p=1,7,1 do
		    if ((i - p) % 7 == 0) then
		        _G["SignWeekday"..p]:UnlockHighlight()
			end
		end
    end)
	
	DayStrings[i] = DayButtons[i]:CreateFontString("DayString"..i)
	DayStrings[i]:SetPoint("CENTER")
	DayStrings[i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 24)
end

WeekdayStr1:SetText("|cFFFF9900周日|r")
WeekdayStr2:SetText("|cFFFF9900周一|r")
WeekdayStr3:SetText("|cFFFF9900周二|r")
WeekdayStr4:SetText("|cFFFF9900周三|r")
WeekdayStr5:SetText("|cFFFF9900周四|r")
WeekdayStr6:SetText("|cFFFF9900周五|r")
WeekdayStr7:SetText("|cFFFF9900周六|r")

----------------------------------------------------------------------------------------------------

-- 下边按钮
local SignButtonInfo = CreateFrame("Button", "SignButtonInfo", EventSignFrame, "UIPanelButtonTemplate")
SignButtonInfo:SetSize(100, 30)
SignButtonInfo:SetPoint("CENTER", 0, -250)
SignButtonInfo:EnableMouse(true)

-- 按钮文字
local StrSignButton = SignButtonInfo:CreateFontString("StrSignButton")
StrSignButton:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
SignButtonInfo:SetFontString(StrSignButton)
SignButtonInfo:SetText("查看签到奖励")

-- 奖励窗体
local SpFrame = CreateFrame("Frame", "SpFrame", UIParent)
SpFrame:SetSize(640, 640)
SpFrame:RegisterForDrag("LeftButton")
SpFrame:SetPoint("CENTER")
SpFrame:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
SpFrame:EnableMouse(true)
SpFrame:Hide()

-- 点击按钮
SignButtonInfo:SetScript("OnClick",
function(self)
	EventSignFrame:Hide()
    SpFrame:Show()
end)

-- 奖励窗体按钮
local SignButtonBack = CreateFrame("Button", "SignButtonBack", SpFrame, "UIPanelButtonTemplate")
SignButtonBack:SetSize(100, 30)
SignButtonBack:SetPoint("BOTTOM", 0, 4)
SignButtonBack:EnableMouse(true)

-- 奖励窗体按钮文字
local StrSignButtonIn = SignButtonBack:CreateFontString("StrSignButtonIn")
StrSignButtonIn:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
SignButtonBack:SetFontString(StrSignButtonIn)
SignButtonBack:SetText("返回签到界面")

-- 点击奖励窗体按钮
SignButtonBack:SetScript("OnClick",
function(self)
	EventSignFrame:Show()
    SpFrame:Hide()
end)

-- 奖励窗体关闭按钮
local SignButtonBackClose = CreateFrame("Button", "SignButtonBackClose", SpFrame, "UIPanelCloseButton")
SignButtonBackClose:SetPoint("TOPRIGHT", 15, 15)
SignButtonBackClose:EnableMouse(true)
SignButtonBackClose:SetSize(36, 36)

tinsert(UISpecialFrames, "SpFrame")

-- 奖励窗体标题模块
local SpFrameTitle = CreateFrame("Frame", "SpFrameTitle", SpFrame, nil)
SpFrameTitle:SetSize(150, 30)
SpFrameTitle:SetPoint("TOP", 0, 25)
SpFrameTitle:EnableMouse(true)
SpFrameTitle:SetBackdrop(
{
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

--奖励窗体标题模块文字描述
local SpFrameText = SpFrameTitle:CreateFontString("SpFrameText")
SpFrameText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 18)
SpFrameText:SetPoint("CENTER", 0, 0)
SpFrameText:SetText("|cffFFC125签到奖励|r")

for i=1,SignCount + 1,1 do
    SubSpFrame[i] = CreateFrame("Frame", "SubSpFrame"..i, SpFrame)
	SubSpFrame[i]:SetSize(600, 40)
	SubSpFrame[i]:SetPoint("TOP", SpFrame, 0, -(SubSpFrame[i]:GetHeight() * (i - 1) + 6))
	SubSpFrame[i]:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    SubSpFrame[i]:SetBackdropColor(0, 0, 0, 0)
	
	SubSpStr[i] = SubSpFrame[i]:CreateFontString("SubSpStr"..i)
	SubSpStr[i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 15)
    SubSpStr[i]:SetPoint("LEFT", SubSpFrame[i], 10, 0)
	SubSpStr[i]:SetText("|cFF00FF00"..(i + SignCount - 1).."日|r")
	if (i == SignCount + 1) then
	    SubSpStr[i]:SetText("|cFFFF00FF★连续"..SignCount.."天★|r")
	end
	
	SubSuccessStr[i] = SubSpFrame[i]:CreateFontString("SubSuccessStr"..i)
	SubSuccessStr[i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 15)
    SubSuccessStr[i]:SetPoint("Right", SubSpFrame[i], -20, 0)
end

-- 这部分有点乱 将就吧
for j=1,(SignCount + 1) * MaxTabKey,1 do
    ButtonLink[j] = CreateFrame("Button", "ButtonLink"..j, SpFrame, nil)
	ButtonLinkStr[j] = ButtonLink[j]:CreateFontString("ButtonLinkStr"..j)
	ButtonLink[j]:SetSize(40, 40)
	ButtonLink[j]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
	ButtonLink[j]:SetBackdrop( { bgFile = "Interface\\BUTTONS\\UI-EmptySlot", })
	ButtonLinkStr[j]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
	ButtonLinkStr[j]:SetAllPoints(ButtonLink[j])
	ButtonLink[j]:SetFontString(ButtonLinkStr[j])
	
	ButtonCountStr[j] = ButtonLink[j]:CreateFontString("ButtonCountStr"..j)
	ButtonCountStr[j]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12, "OUTLINE")
	ButtonCountStr[j]:SetPoint("CENTER", ButtonLink[j], 0, -8)
	
	ButtonLink[j]:SetText("")
	
    if (j < (MaxTabKey * 1 + 1)) then
	    if (SignItemData[1][j - MaxTabKey * 0][1] ~= 0) then
		    ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[1][j][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[1][j][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[1], 160 + (j - 1) * 40, 0)
	elseif (j > (MaxTabKey * 1) and j < (MaxTabKey * 2 + 1)) then
	    if (SignItemData[2][j - MaxTabKey * 1][1] ~= 0) then
		    ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[2][j - MaxTabKey * 1][1])..":40|t")
		    ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[2][j - MaxTabKey * 1][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[2], 160 + (j - 1 - MaxTabKey * 1) * 40, 0)
	elseif (j > (MaxTabKey * 2) and j < (MaxTabKey * 3 + 1)) then
	    if (SignItemData[3][j - MaxTabKey * 2][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[3][j - MaxTabKey * 2][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[3][j - MaxTabKey * 2][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[3], 160 + (j - 1 - MaxTabKey * 2) * 40, 0)
	elseif (j > (MaxTabKey * 3) and j < (MaxTabKey * 4 + 1)) then
	    if (SignItemData[4][j - MaxTabKey * 3][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[4][j - MaxTabKey * 3][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[4][j - MaxTabKey * 3][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[4], 160 + (j - 1 - MaxTabKey * 3) * 40, 0)
	elseif (j > (MaxTabKey * 4) and j < (MaxTabKey * 5 + 1)) then
	    if (SignItemData[5][j - MaxTabKey * 4][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[5][j - MaxTabKey * 4][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[5][j - MaxTabKey * 4][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[5], 160 + (j - 1 - MaxTabKey * 4) * 40, 0)
	elseif (j > (MaxTabKey * 5) and j < (MaxTabKey * 6 + 1)) then
	    if (SignItemData[6][j - MaxTabKey * 5][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[6][j - MaxTabKey * 5][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[6][j - MaxTabKey * 5][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[6], 160 + (j - 1 - MaxTabKey * 5) * 40, 0)
	elseif (j > (MaxTabKey * 6) and j < (MaxTabKey * 7 + 1)) then
	    if (SignItemData[7][j - MaxTabKey * 6][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[7][j - MaxTabKey * 6][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[7][j - MaxTabKey * 6][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[7], 160 + (j - 1 - MaxTabKey * 6) * 40, 0)
	elseif (j > (MaxTabKey * 7) and j < (MaxTabKey * 8 + 1)) then
	    if (SignItemData[8][j - MaxTabKey * 7][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[8][j - MaxTabKey * 7][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[8][j - MaxTabKey * 7][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[8], 160 + (j - 1 - MaxTabKey * 7) * 40, 0)
	elseif (j > (MaxTabKey * 8) and j < (MaxTabKey * 9 + 1)) then
	    if (SignItemData[9][j - MaxTabKey * 8][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[9][j - MaxTabKey * 8][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[9][j - MaxTabKey * 8][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[9], 160 + (j - 1 - MaxTabKey * 8) * 40, 0)
	elseif (j > (MaxTabKey * 9) and j < (MaxTabKey * 10 + 1)) then
	    if (SignItemData[10][j - MaxTabKey * 9][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[10][j - MaxTabKey * 9][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[10][j - MaxTabKey * 9][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[10], 160 + (j - 1 - MaxTabKey * 9) * 40, 0)
	elseif (j > (MaxTabKey * 10) and j < (MaxTabKey * 11 + 1)) then
	    if (SignItemData[11][j - MaxTabKey * 10][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[11][j - MaxTabKey * 10][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[11][j - MaxTabKey * 10][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[11], 160 + (j - 1 - MaxTabKey * 10) * 40, 0)
	elseif (j > (MaxTabKey * 11) and j < (MaxTabKey * 12 + 1)) then
	    if (SignItemData[12][j - MaxTabKey * 11][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[12][j - MaxTabKey * 11][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[12][j - MaxTabKey * 11][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[12], 160 + (j - 1 - MaxTabKey * 11) * 40, 0)
	elseif (j > (MaxTabKey * 12) and j < (MaxTabKey * 13 + 1)) then
	    if (SignItemData[13][j - MaxTabKey * 12][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[13][j - MaxTabKey * 12][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[13][j - MaxTabKey * 12][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[13], 160 + (j - 1 - MaxTabKey * 12) * 40, 0)
	elseif (j > (MaxTabKey * 13) and j < (MaxTabKey * 14 + 1)) then
	    if (SignItemData[14][j - MaxTabKey * 13][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[14][j - MaxTabKey * 13][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[14][j - MaxTabKey * 13][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[14], 160 + (j - 1 - MaxTabKey * 13) * 40, 0)
	elseif (j > (MaxTabKey * 14)) then
	    if (SignItemData[15][j - MaxTabKey * 14][1] ~= 0) then
			ButtonLink[j]:SetText("|T"..GetItemIcon(SignItemData[15][j - MaxTabKey * 14][1])..":40|t")
			ButtonCountStr[j]:SetText("|cFFFF6600"..SignItemData[15][j - MaxTabKey * 14][2].."|r")
		end
		ButtonLink[j]:SetPoint("LEFT", SubSpFrame[15], 160 + (j - 1 - MaxTabKey * 14) * 40, 0)
	end
	
	ButtonLink[j]:SetScript("OnEnter", 
    function(self)
	GameTooltip:SetOwner(ButtonLink[j], "ANCHOR_LEFT")
	if (j < (MaxTabKey * 1 + 1)) then
		GameTooltip:SetHyperlink("|Hitem:"..SignItemData[1][j - MaxTabKey * 0][1])
	elseif (j > (MaxTabKey * 1) and j < (MaxTabKey * 2 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[2][j - MaxTabKey * 1][1])
	elseif (j > (MaxTabKey * 2) and j < (MaxTabKey * 3 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[3][j - MaxTabKey * 2][1])
	elseif (j > (MaxTabKey * 3) and j < (MaxTabKey * 4 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[4][j - MaxTabKey * 3][1])
	elseif (j > (MaxTabKey * 4) and j < (MaxTabKey * 5 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[5][j - MaxTabKey * 4][1])
	elseif (j > (MaxTabKey * 5) and j < (MaxTabKey * 6 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[6][j - MaxTabKey * 5][1])
	elseif (j > (MaxTabKey * 6) and j < (MaxTabKey * 7 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[7][j - MaxTabKey * 6][1])
	elseif (j > (MaxTabKey * 7) and j < (MaxTabKey * 8 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[8][j - MaxTabKey * 7][1])
	elseif (j > (MaxTabKey * 8) and j < (MaxTabKey * 9 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[9][j - MaxTabKey * 8][1])
	elseif (j > (MaxTabKey * 9) and j < (MaxTabKey * 10 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[10][j - MaxTabKey * 9][1])
	elseif (j > (MaxTabKey * 10) and j < (MaxTabKey * 11 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[11][j - MaxTabKey * 10][1])
	elseif (j > (MaxTabKey * 11) and j < (MaxTabKey * 12 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[12][j - MaxTabKey * 11][1])
	elseif (j > (MaxTabKey * 12) and j < (MaxTabKey * 13 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[13][j - MaxTabKey * 12][1])
	elseif (j > (MaxTabKey * 13) and j < (MaxTabKey * 14 + 1)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[14][j - MaxTabKey * 13][1])
	elseif (j > (MaxTabKey * 14)) then
	    GameTooltip:SetHyperlink("|Hitem:"..SignItemData[15][j - MaxTabKey * 14][1])
	end
        GameTooltip:Show()
    end)
	
	ButtonLink[j]:SetScript("OnLeave", 
    function(self)
        GameTooltip:Hide()
    end)
end

----------------------------------------------------------------------------------------------------

EventSignFrame:SetScript("OnShow", 
function(self)
    Clicks = 0
	UpdateDayEvent(Clicks)
end)

EventSignMonthButtonLeft:SetScript("OnClick",
function(self)
	Clicks = Clicks - 1
	UpdateDayEvent(Clicks)
end)

EventSignMonthButtonRight:SetScript("OnClick",
function(self)
    Clicks = Clicks + 1
	UpdateDayEvent(Clicks)
end)

function UpdateDayEvent(NowClick)
    local PreMonth, PreYear, PreNumDays, PreFirstWeekday = CalendarGetMonth(NowClick - 1)
    local Month, Year, NumDays, FirstWeekday = CalendarGetMonth(NowClick)
	local NextMonth, NextYear, NextNumDays, NextFirstWeekday = CalendarGetMonth(NowClick + 1)
	
	local PreFirstDay = PreNumDays - (FirstWeekday - 1)
	local NextFirstDay = NumDays + FirstWeekday - 1
	local FirstDay = FirstWeekday - 1
	
	
    SignYearText:SetText("|cFF00FF00"..Year.."年|r")
	ButtonCenterStr:SetText("|cFFFFFF00"..Month.."月|r")
	
	if (NowClick < 0) then
	    if (EventSignMonthButtonLeft:IsEnabled() == 0) then
            EventSignMonthButtonLeft:Enable()
	    end
	elseif(NowClick > 0) then
	    if (EventSignMonthButtonRight:IsEnabled() == 0) then
            EventSignMonthButtonRight:Enable()
	    end
	else
	    EventSignMonthButtonLeft:Enable()
	    EventSignMonthButtonRight:Enable()
	end
	
	if (Year <= MinYear and Month == MinMonth) then
	    EventSignMonthButtonLeft:Disable()
	end
	
	if (Year >= MaxYear and Month == MaxMonth) then
	    EventSignMonthButtonRight:Disable()
	end
	
	for i=1,42,1 do
		DayStrings[i]:SetVertexColor(204/255, 204/255, 204/255)
		DayStrings[i]:SetAlpha(0.5)
		MeSetTexture(DayButtons[i], "Interface\\Icons\\Zzz_Tou")
		if (i < FirstWeekday) then
		    DayStrings[i]:SetText(tostring(i + PreFirstDay))
		elseif (i > NextFirstDay) then
		    DayStrings[i]:SetText(tostring(i - NextFirstDay))
		else
			DayStrings[i]:SetVertexColor(255/255, 255/255, 0)
			DayStrings[i]:SetAlpha(1)
			DayStrings[i]:SetText(tostring(i - FirstDay))
			if (tonumber(DayStrings[i]:GetText()) == tonumber(date("%d")) and NowClick == 0) then
			    MeSetBackdrop(DayButtons[i], "Interface\\Icons\\Zzz_NowDay", "Interface\\Tooltips\\UI-Tooltip-Border")
			else
			    MeSetBackdrop(DayButtons[i], "Interface\\DialogFrame\\UI-DialogBox-Background", "Interface\\Tooltips\\UI-Tooltip-Border")
			end
			
			local UiDay = tonumber(DayStrings[i]:GetText())
			if (Year == SignYear and tonumber(Month) == SignMonth and UiDay >= SignNowDay and UiDay < SignNowDay + SignCount) then
			    if (UiDay >= tonumber(date("%d"))) then
			        MeSetTexture(DayButtons[i], "Interface\\Icons\\Zzz_SignNow")
		        else
		            MeSetTexture(DayButtons[i], "Interface\\Icons\\Zzz_Repair")
				end
		    end
			
			if (NowClick == 0) then
			    for j=1,SignCount,1 do
			        if (tonumber(StateList[j]) == 1) then
				        MeSetTexture(DayButtons[j + SignNowDay + FirstWeekday - 1 - 1], "Interface\\RaidFrame\\ReadyCheck-Ready")
			        end
			    end
			end
		end
	end
end

function UpDateSignDay(Num)
    local UiDay = tonumber(DayStrings[Num]:GetText())
    local Month, Year, NumDays, FirstWeekday = CalendarGetMonth()
	if (Year == SignYear and tonumber(Month) == SignMonth and IsInSign(UiDay, NumDays) == true) then
		if (UiDay == tonumber(date("%d"))) then
		    AIO.Handle("EventSignStore", "UpDateSetMeSignState", Num - SignNowDay - FirstWeekday + 1 + 1, 1, Num)
		elseif (UiDay < tonumber(date("%d"))) then
		    AIO.Handle("EventSignStore", "UpDateSetMeSignState", Num - SignNowDay - FirstWeekday + 1 + 1, 0, Num)
		else
		    AIO.Handle("EventSignStore", "MeSignStateErr", "[签到]: 尚未到达签到日期时间")
		end
    else
	    AIO.Handle("EventSignStore", "MeSignStateErr", "[签到]: 不是指定的签到日期或范围")
	end
end

function EventSignHandlers.SetSignStateSuccess(player, n, p)
    MeSetTexture(DayButtons[n], "Interface\\RaidFrame\\ReadyCheck-Ready")
	SubSuccessStr[p]:SetText("|cFF00FF00已签|r")
end



