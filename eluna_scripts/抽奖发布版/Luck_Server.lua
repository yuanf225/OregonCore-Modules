
local AIO = AIO or require("AIO")

local Me = require("MyFunction")

local LuckHandlers = AIO.AddHandlers("LuckDrawUI", {})

local ItemId = 49426   --每次抽奖所需物品
local ItemCc = 5       --每次抽奖所需数量 十连抽自动计算

local Max = 16       --请勿更改(UI最大数量)
local Tm  = 100      --图标跳动的频率(毫秒)

local IsTen = {}   --抽奖标示
local Ten = {}     --剩余

--SSS为高档
--SS为中档
--S为低档
--物品变量(对应服务端).改动需跟客户端一致.复制即可--ID和数量--数量必须大于等于1--物品必须存在数据库
local ShopData = {
                    {35622, 11},     --ss
                    {35623, 12},     --s
                    {35624, 13},     --ss
                    {35625, 14},     --s
                    {35626, 15},     --ss
					{35627, 16},     --sss
                    {43118, 17},     --s
                    {43120, 18},     --ss
                    {43122, 19},     --s
                    {43124, 20},     --ss
                    {43127, 21},     --s
                    {32840, 22},     --ss
					{32844, 23},     --s
					{32845, 24},     --sss
					{32846, 25},     --ss
					{32847, 26},     --s
};

function LuckHandlers.ShowItemLink(player)
	AIO.Handle(player, "LuckDrawUI", "ShowUseItemLink", ItemId, ItemCc, GetItemLink(ItemId))
end

function LuckHandlers.SelectItem(player, F)
    if (F == 0) then
	    if (player:HasItem(ItemId, ItemCc)) then
		    AIO.Handle(player, "LuckDrawUI", "StartLuck", F)
		    LuckHandlers.StartWork(player, F)
		else
		    player:SendBroadcastMessage("抽奖需要 "..GetItemLink(ItemId).." X "..(ItemCc).."")
		end
	else
	    if (player:HasItem(ItemId, ItemCc * 10)) then
		     AIO.Handle(player, "LuckDrawUI", "StartLuck", F)
		    LuckHandlers.StartWork(player, F)
		else
		    player:SendBroadcastMessage("抽奖需要 "..GetItemLink(ItemId).." X "..(ItemCc * 10).."")
		end
	end
end

--开启
function LuckHandlers.StartWork(player, flag)
    IsTen[player:GetGUIDLow()] = flag
	Ten[player:GetGUIDLow()] = 0
	if (flag == 0) then
        player:RemoveItem(ItemId, ItemCc)
        player:SendBroadcastMessage("|cFF33CC33你失去了|r "..GetItemLink(ItemId).." |cFF33CC33x "..ItemCc.." 个|r")
	else
        player:RemoveItem(ItemId, ItemCc * 10)
        player:SendBroadcastMessage("|cFF33CC33你失去了|r "..GetItemLink(ItemId).." |cFF33CC33x "..(ItemCc * 10).." 个|r")
	end

	UpdateBmp1(event, _, _, player)
end

function UpdateBmp1(event, _, _, player)
    AIO.Handle(player, "LuckDrawUI", "StartUpdateTx")
    local tg1 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg1)
    player:RegisterEvent(UpdateBmp2, Tm, 1)
end

function UpdateBmp2(event, _, _, player)
    local tg2 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg2)
    player:RegisterEvent(UpdateBmp3, Tm, 1)
end

function UpdateBmp3(event, _, _, player)
    local tg3 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg3)
    player:RegisterEvent(UpdateBmp4, Tm, 1)
end

function UpdateBmp4(event, _, _, player)
    local tg4 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg4)
    player:RegisterEvent(UpdateBmp5, Tm, 1)
end

function UpdateBmp5(event, _, _, player)
    local tg5 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg5)
    player:RegisterEvent(UpdateBmp6, Tm, 1)
end

function UpdateBmp6(event, _, _, player)
    local tg6 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg6)
    player:RegisterEvent(UpdateBmp7, Tm, 1)
end

function UpdateBmp7(event, _, _, player)
    local tg7 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg7)
    player:RegisterEvent(UpdateBmp8, Tm, 1)
end

function UpdateBmp8(event, _, _, player)
    local tg8 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg8)
    player:RegisterEvent(UpdateBmp9, Tm, 1)
end

function UpdateBmp9(event, _, _, player)
    local tg9 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg9)
    player:RegisterEvent(UpdateBmp10, Tm, 1)
end

function UpdateBmp10(event, _, _, player)
    local tg10 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg10)
    player:RegisterEvent(UpdateBmp11, Tm, 1)
end

function UpdateBmp11(event, _, _, player)
    local tg11 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg11)
    player:RegisterEvent(UpdateBmp12, Tm, 1)
end

function UpdateBmp12(event, _, _, player)
    local tg12 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg12)
    player:RegisterEvent(UpdateBmp13, Tm, 1)
end

function UpdateBmp13(event, _, _, player)
    local tg13 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg13)
    player:RegisterEvent(UpdateBmp14, Tm, 1)
end

function UpdateBmp14(event, _, _, player)
    local tg14 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg14)
    player:RegisterEvent(UpdateBmp15, Tm, 1)
end

function UpdateBmp15(event, _, _, player)
    local tg15 = math.random(1, Max)
    AIO.Handle(player, "LuckDrawUI", "StartCenter", tg15)
    player:RegisterEvent(UpdateBmp16, Tm, 1)
end

function UpdateBmp16(event, _, _, player)--关键性代码--请不要自行更改--除非你知道自己在做什么
    local R = 1
    local M = math.random(1, 10000)
    if (player:IsGM()) then--GM作弊
        M = 10000
    end
    if (M > 0 and M <= 9000) then--s
    	local s = {2, 4, 7, 9, 11, 13, 16} --低档次的奖池
        R = s[math.random(1, 7)]--随机其中一个给予奖励
    end
    if (M > 9000 and M < 9999) then --ss
    	local ss = {1, 3, 5, 8, 10, 12, 15}--(中档次)的奖池
        R = ss[math.random(1, 7)]--随机其中一个给予奖励
    end
    if (M == 10000) then--sss
    	local sss = {6, 14}--(高档次)的奖池
        R = sss[math.random(1, 2)]--随机其中一个给予奖励
    end
	
	AIO.Handle(player, "LuckDrawUI", "StartCenter", R)
	
	if (IsTen[player:GetGUIDLow()] == 1) then
	    Ten[player:GetGUIDLow()] = Ten[player:GetGUIDLow()] + 1
	    player:RegisterEvent(UpdateBmp1, Tm * 3, 1)--停顿间隔*3毫秒
		AIO.Handle(player, "LuckDrawUI", "ShowButtonState", R, 1, 10 - Ten[player:GetGUIDLow()])
		if (Ten[player:GetGUIDLow()] >= 10) then
		    Ten[player:GetGUIDLow()] = 0
		    player:RemoveEvents()
		end
	else
	    AIO.Handle(player, "LuckDrawUI", "ShowButtonState", R, 0, 1)
	    player:RemoveEvents()
	end
	
    player:AddItem(ShopData[R][1],ShopData[R][2])
	
	local MSG = "[幸运抽奖公告]: 恭喜玩家 "..Me.SetHyperlink(player).." 抽到 "..GetItemLink(ShopData[R][1]).." X "..ShopData[R][2]..""
    SendWorldMessage(MSG)
	
	local ScrollMsg = "|cFF00FFCC"..os.date("%H:%M:%S").."|r |cFFFFFF00玩家|r "..Me.SetLink(player).." |cFFFFFF00抽到|r "..GetItemLink(ShopData[R][1]).." |cFFFFFF00X|r |cFFFFFF00"..ShopData[R][2].."|r"
	local players = GetPlayersInWorld()
	if(players) then
        for k, player in ipairs(players) do
            AIO.Handle(player, "LuckDrawUI", "UpdateScrollMsg", ScrollMsg)
        end
    end
end
