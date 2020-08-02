print(">>Script: Black Market Loaded (By Leo) ...")

local AIO = AIO or require("AIO")
local MyHandlers = AIO.AddHandlers("BlackMarket", {})

--// Configs
local TokenID = 49426 --// 货币ID default - 寒冰纹章
local Interval = 10 --// 黑市开启时间间隔 单位：分
local goodsNumMin = 6 --// 黑市登记商品数量的下限，不能小于1且不能大于goodsNumMax
local goodsNumMax = 18 --// 黑市登记商品数量的上限，不能大于21且不能小于goodsNumMin

--// DO NOT EDIT BELOW THINGS, UNLESS YOU KNOW WHAT YOU ARE DOING!! //--
local MarketGoods = {}
local goodsloaded = false
local ForceMaxNum = 21
local goodsNum = 0

local function RandomGoodNum()
	goodsNum = math.random(goodsNumMin, goodsNumMax)	
	if goodsNum > ForceMaxNum then		
		goodsNum = ForceMaxNum
	end
	return goodsNum
end

local function SendTableToClient(msg, player)
    local goods = MarketGoods
    return msg:Add("BlackMarket", "GetBlackMarketGoods", goods)
end
AIO.AddOnInit(SendTableToClient)

local function SelectMarketGoods()
	for i=1,goodsNum,1 do
		local query = WorldDBQuery("SELECT goods, price FROM blackmarket ORDER BY RAND() LIMIT 1")
		if(query) then
			table.insert(MarketGoods, i, {query:GetUInt32(0), query:GetUInt32(1)})
		end
	end
	if #MarketGoods == goodsNum then
		goodsloaded = true
	end
end

local function ActivateBlackMarket()
	MarketGoods = {}
	goodsloaded = false
	RandomGoodNum()
	SelectMarketGoods()
    if goodsloaded == false then return end
    local players = GetPlayersInWorld()
    if(players) then
        for k, player in ipairs(players) do
            player:GossipComplete()
			player:GossipClearMenu()
			player:GossipMenuAddItem(30, "黑市", 0, 2333, false, "新货上架！！\n是否要查看黑市？")
			player:GossipSendMenu(100, player, 2333)
        end
    end
    CreateLuaEvent(ActivateBlackMarket, Interval*60*1000, 1)
end

function GossipOnSelect(event, player)
	SendTableToClient(AIO.Msg(), player):Send(player)
	AIO.Handle(player, "BlackMarket", "ShowBlackMarketUI")
end

function MyHandlers.BuyGoods(player, Index)
    if (player:IsInCombat()) then
        player:SendBroadcastMessage("提示：战斗中无法执行。")
	else
		SendConfirmMessage(event, player, Index)
    end
end

function SendConfirmMessage(event, player, Index)
    player:GossipComplete()
	player:GossipClearMenu()
	player:GossipMenuAddItem(30, "确认信息", Index, 2334, false, "确定要购买 "..GetItemLink(MarketGoods[Index][1], 4).." ？")
	player:GossipSendMenu(100, player, 2334)
end

local function BuyGoodsGossipOnSelect(event, player, object, sender, intid, code, menu_id)
	local itemid = MarketGoods[sender][1]
	local price = MarketGoods[sender][2]
	local name = GetItemLink(MarketGoods[sender][1], 4)
	if player:HasItem(TokenID, price) == false then
        player:SendBroadcastMessage("货币不足，购买失败！")
		return
	else
		player:RemoveItem(TokenID, price)
        player:SendBroadcastMessage("成功购得"..name.."，请注意查看邮件！")
		SendMail("黑市商品", "尊敬的"..player:GetName().."，这是您从黑市购买的"..name.."，感谢您的惠顾！", player:GetGUIDLow(), 0, 41, 0, 0, 0, itemid, 1)
	end
end

local function ActivateBlackMarketEvent(event, player, command)
    if(command == "bm") then
        ActivateBlackMarket()
        return false
    end
end
RegisterPlayerEvent(42, ActivateBlackMarketEvent)
RegisterPlayerGossipEvent(2333, 2, GossipOnSelect)
RegisterPlayerGossipEvent(2334, 2, BuyGoodsGossipOnSelect)