
local AIO = AIO or require("AIO")

local EventSignHandlers = AIO.AddHandlers("EventSignStore", {})

local SignYear  = 2018          --签到的年份
local SignMonth = 12             --签到的月份
local SignNowDay= 14             --签到的起始日
local SignCount = 14            --需要连续签到的天数 -- 最大框架14天 注意: (起始日+设定的天数不能大于本月天数)

local RepairItem = 47241
local RepairCount = 5

local So = "1"            --标识 表示已签到
local Sn = "0"            --标识 表示未签到
local Sp = ":"            --分割符


-- 第二维当前最大MaxTabKey组 需要增减的话自行修改数组
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

--删除首尾空格
function StrTrim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--分割返回数组(待分割的字符, 分割符) 分割符不能正则表达 不支持%s之流
function StrSplit(str, reps)
    local StrList = {}
    string.gsub(str, '[^'..reps..']+', function(F) table.insert(StrList, F) end)
    return StrList
end

--登陆导入数据--没有数据则导入
function PlayerLogin(event, player)
	local guid = player:GetGUIDLow()
	local Q = CharDBQuery("SELECT guid, SignData FROM _PlayerSign WHERE guid="..guid..";")
    if (Q == nil) then
	    local All = string.rep(Sn..Sp, SignCount)--导入总天数的初始数据
        CharDBExecute("INSERT INTO _PlayerSign VALUES ("..guid..", '"..All.."');")
    end
end

RegisterPlayerEvent(3, PlayerLogin)

--查询显示签到数组--反馈回客户端显示
function EventSignHandlers.ShowMeSignState(player)
    local guid = player:GetGUIDLow()
    local Q = CharDBQuery("SELECT guid, SignData FROM _PlayerSign WHERE guid="..guid..";")
	if (Q) then
	    local list = StrSplit(Q:GetString(1), Sp)--返回的n个数据--数组--list[n]
		AIO.Handle(player, "EventSignStore", "ShowSignState", list, RepairItem, GetItemLink(RepairItem), RepairCount)
	end
end

--错误提示信息(玩家, 提示信息)
function EventSignHandlers.MeSignStateErr(player, err)
    player:SendBroadcastMessage(err)
end

--点击按钮签到交互(玩家, 第几天, 类型[补/签], 按钮序号)
function EventSignHandlers.UpDateSetMeSignState(player, p, flag, n)
    local guid = player:GetGUIDLow()
	local Q = CharDBQuery("SELECT guid, SignData FROM _PlayerSign WHERE guid="..guid..";")
	if (Q) then
	    local list = StrSplit(Q:GetString(1), Sp)--分割开得到每天的标示list[]
		for k,v in pairs (list) do
	        if (k == p) then
			    if (tostring(list[k]) == So) then player:SendBroadcastMessage("[签到]: 你已经签到过了") return end --签到过的直接返回
		        list[k] = So--更新指定的签到天数 为1表示已签到
		    end
			list[k] = list[k]..Sp--再用":"重新串联起来
	    end
		local SignData = table.concat(list)--得到一串字符 即将导入数据
	    if (flag == 1) then
	        player:SendBroadcastMessage("[签到]: 签到成功.奖励已发放")
			AIO.Handle(player, "EventSignStore", "SetSignStateSuccess", n, p)
            CharDBExecute("UPDATE _PlayerSign SET SignData='"..SignData.."' WHERE guid="..guid..";")
			for k,v in pairs (SignItemData[p]) do
			    if (v[1] ~= 0) then
			        player:AddItem(v[1],v[2])
				end
			end
        elseif (flag == 0) then
	        if (player:HasItem(RepairItem, RepairCount)) then
		        player:RemoveItem(RepairItem, RepairCount)
			    player:SendBroadcastMessage("[签到]: 补签成功.奖励已发放")
		        CharDBExecute("UPDATE _PlayerSign SET SignData='"..SignData.."' WHERE guid="..guid..";")
			    AIO.Handle(player, "EventSignStore", "SetSignStateSuccess", n, p)
				for k,v in pairs (SignItemData[p]) do
			        if (v[1] ~= 0) then
			            player:AddItem(v[1],v[2])
				    end
			    end
		    else
			    player:SendBroadcastMessage("[签到]: 补签不成功.需要 "..GetItemLink(RepairItem).." X "..(RepairCount).." 个")
		    end
	    end
		local Alls = string.rep(So..Sp, SignCount)
		if (StrTrim(SignData) == StrTrim(Alls)) then--判断是否达成14天
		    player:SendBroadcastMessage("[签到]: 恭喜你完成连续签到.奖励已发放")
		    for k,v in pairs (SignItemData[SignCount + 1]) do
			    if (v[1] ~= 0) then
			        player:AddItem(v[1],v[2])
				end
			end
		end
	end
end


