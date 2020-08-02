--// DO NOT EDIT BELOW THINGS, UNLESS YOU KNOW WHAT YOU ARE DOING!! //--
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MyHandlers = AIO.AddHandlers("BlackMarket", {})

local GoodsTable = {}
local goodsFrametable = {}

local bmMainFrame = CreateFrame("Frame", "bmMainFrame", UIParent)
bmMainFrame:SetSize(1024, 660)
bmMainFrame:SetMovable(true)
bmMainFrame:EnableMouse(true)
bmMainFrame:RegisterForDrag("LeftButton")
bmMainFrame:SetPoint("CENTER")
bmMainFrame:SetBackdrop(
{
    bgFile = "Interface/CharacterFrame/UI-Party-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
bmMainFrame:SetBackdropColor(0,0,1,0.75);
bmMainFrame:SetScript("OnDragStart", bmMainFrame.StartMoving)
bmMainFrame:SetScript("OnHide", bmMainFrame.StopMovingOrSizing)
bmMainFrame:SetScript("OnDragStop", bmMainFrame.StopMovingOrSizing)
bmMainFrame:Hide()

local bmMainFrameCloseButton = CreateFrame("Button", "bmMainFrameCloseButton", bmMainFrame, "UIPanelCloseButton")
bmMainFrameCloseButton:SetPoint("TOPRIGHT", -5, -5)
bmMainFrameCloseButton:EnableMouse(true)
bmMainFrameCloseButton:SetSize(27, 27)

local bmMainFrameTitle = CreateFrame("Frame", "bmMainFrameTitle", bmMainFrame)
bmMainFrameTitle:SetPoint("TOP", 0, 8)
bmMainFrameTitle:SetSize(128, 32)
bmMainFrameTitle:SetBackdrop(
{
    bgFile = "Interface/CharacterFrame/UI-Party-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
bmMainFrameTitle:SetBackdropColor(0,0,1,0.75);
local bmMainFrameTitleString = bmMainFrameTitle:CreateFontString("bmMainFrameTitleString")
bmMainFrameTitleString:SetFont("Fonts\\FRIZQT_.TTF", 16, "OUTLINE")
bmMainFrameTitleString:SetSize(128, 32)
bmMainFrameTitleString:SetPoint("CENTER")
bmMainFrameTitleString:SetText("")
bmMainFrameTitleString:SetText("|cffe6cc80黑市商店|r")

function MyHandlers.GetBlackMarketGoods(player, goods)
	GoodsTable = {}
	GoodsTable = goods
end

function MyHandlers.ShowBlackMarketUI(player)
	if bmMainFrame:IsShown() then
		bmMainFrame:Hide()
	end
    bmMainFrame:Show()
	CreateGoodsFrames()
end

function SendMessageToServer(Index)
	AIO.Handle("BlackMarket", "BuyGoods", Index)
end

for i=1,21,1 do
	table.insert(goodsFrametable, i, {"goodsIconFrame"..i, "goodsPrice"..i, "goodsBuyButton"..i})
	goodsFrametable[i][1] = CreateFrame("frame", goodsFrametable[i][1], bmMainFrame)
	goodsFrametable[i][2] = goodsFrametable[i][1]:CreateFontString(goodsFrametable[i][2])
	goodsFrametable[i][1]:SetSize(64, 64)
	goodsFrametable[i][1]:EnableMouse(true)
	goodsFrametable[i][2]:SetFont("Fonts\\FRIZQT_.TTF", 11, "OUTLINE")
	goodsFrametable[i][2]:SetSize(96, 32)
	goodsFrametable[i][2]:SetPoint("BOTTOM",0, -32)
	
	goodsFrametable[i][3] = CreateFrame("Button", goodsFrametable[i][3], goodsFrametable[i][1], nil)
	goodsBuyButtonText = goodsFrametable[i][3]:CreateFontString(goodsFrametable[i][3])

	goodsFrametable[i][3]:SetSize(60, 40)
	goodsFrametable[i][3]:SetPoint("BOTTOM", 0, -72)
	goodsFrametable[i][3]:EnableMouse(true)
	goodsFrametable[i][3]:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
	goodsFrametable[i][3]:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
	goodsFrametable[i][3]:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
	goodsFrametable[i][3]:SetDisabledTexture("Interface/BUTTONS/UI-DialogBox-Button-Disabled")
	goodsBuyButtonText:SetFont("Fonts\\FRIZQT_.TTF", 12, "OUTLINE")
	goodsBuyButtonText:SetShadowOffset(1, -1)
	goodsBuyButtonText:SetPoint("CENTER", goodsFrametable[i][3], "CENTER", 0, 6);
	goodsFrametable[i][3]:SetFontString(goodsBuyButtonText)
	goodsFrametable[i][3]:SetText("购买")
	
	goodsFrametable[i][1]:Hide()
	
	if i < 8 then
		goodsFrametable[i][1]:SetPoint("TOPLEFT",48+(64+80)*(i-1), -72)
	elseif i >= 8 and i < 15 then
		goodsFrametable[i][1]:SetPoint("TOPLEFT",48+(64+80)*(i-8), -264)
	else		
		goodsFrametable[i][1]:SetPoint("TOPLEFT",48+(64+80)*(i-15), -456)
	end
end

function CreateGoodsFrames()
	for i=1,21,1 do
		goodsFrametable[i][1]:Hide()
	end
	for i=1,#GoodsTable,1 do
		goodsFrametable[i][1]:SetBackdrop(
		{
			bgFile = GetItemIcon(GoodsTable[i][1])
		})
		goodsFrametable[i][1]:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_CURSOR", -20, -20) GameTooltip:SetHyperlink("item:"..GoodsTable[i][1]) GameTooltip:Show() end)
		goodsFrametable[i][1]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		goodsFrametable[i][1]:Show()
		
		goodsFrametable[i][2]:SetText("售价\n"..GoodsTable[i][2])
		goodsFrametable[i][3]:SetScript("OnMouseUp", function() SendMessageToServer(i) end)
	end
end