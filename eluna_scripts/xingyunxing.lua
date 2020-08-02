--[[无敌幸运星]] --
print('>>Script: xingyunxing.lua loading...OK')
local TIME = 1 ---------------间隔时间(单位分钟)
local diffTime = os.time() ---不要改动
----如果物品是唯一的，将只发送1个
local RWitem = {200045, 200035} ---------正常奖励
local RWitemcount = 1 ----奖励数量上限
local RWitemlucy = {86913, 86914} ----超级奖励
local RWitemcountLucy = 1 --------奖励数量上限
local playerminlevel = 30 -----参与奖励的最低等级
local eamil = 0 ----老版本的端为1  新版本的为0
local onlieeamil = 0
----在线的发送邮件为0，在线的直接senditem为1
local sendonline = 1 --0,1 在线离线，0=只是离线，1只是在线
local function luckstar()
    local nowTime = os.time()
    if (nowTime - diffTime >= (TIME * 60)) then
        local text =
            CharDBQuery(
            "SELECT guid ,account , name,online FROM characters  AS u1  JOIN (SELECT ROUND(RAND() * ((SELECT MAX(guid) FROM `characters` where  `level`  >='" ..
                playerminlevel ..
                    "'  and online in (" ..
                        sendonline ..
                            "))-(SELECT MIN(guid) FROM characters where  `level`  >='" ..
                                playerminlevel ..
                                    "'  and  online in (" ..
                                        sendonline ..
                                            ") ))+(SELECT MIN(guid) FROM characters where  `level`  >='" ..
                                                playerminlevel ..
                                                    "'  and  online in (" ..
                                                        sendonline ..
                                                            ')) ) AS uid) AS u2 WHERE u1.guid >= u2.uid ORDER BY u1.guid LIMIT 1'
        )
        if (text) then
            local playidlistluck = math.random(1, 100)
            --
            local itemID = 0
            local Count = 0
            local playstaus = '|cFF00FA9A在线|r'
            if (text:GetString(3) == '0') then
                playstaus = '|cFF00FA9A离线|r'
            end
            if
                (playidlistluck == 88 or playidlistluck == 99 or playidlistluck == 77 or playidlistluck == 66 or
                    playidlistluck == 55 or
                    playidlistluck == 44 or
                    playidlistluck == 33 or
                    playidlistluck == 22 or
                    playidlistluck == 11)
             then
                itemID = RWitemlucy[math.random(1, #RWitemlucy)]
                Count = math.random(1, RWitemcountLucy)
                SendWorldMessage(
                    '|cffff0000[超级幸运星]|r本期幸运数字[:|CFF00FFFF' ..
                        playidlistluck ..
                            '|r]超级大奖出现！！！幸运' ..
                                playstaus ..
                                    '玩家【|CFF00FFFF' ..
                                        text:GetString(2) ..
                                            '|r】获得了物品' ..
                                                GetItemLink(itemID) ..
                                                    'X|CFF00FFFF' ..
                                                        Count ..
                                                            '|r个,恭喜恭喜！！！收到奖励的玩家小退再上即可在邮件查收！！！★★★下一次幸运星奖励将在|r|cffff0000(' ..
                                                                TIME .. '分钟)|r|cFFF08000后开始.请留意★★★|r'
                )
            else
                itemID = RWitem[math.random(1, #RWitem)]
                Count = math.random(1, RWitemcount)
                SendWorldMessage(
                    '|cffff0000[超级幸运星]|r本期幸运数字[:|CFF00FFFF' ..
                        playidlistluck ..
                            '|r]幸运' ..
                                playstaus ..
                                    '玩家【|CFF00FFFF' ..
                                        text:GetString(2) ..
                                            '|r】获得了物品' ..
                                                GetItemLink(itemID) ..
                                                    'X|CFF00FFFF' ..
                                                        Count ..
                                                            '|r个恭喜恭喜！！！收到奖励的玩家小退再上即可在邮件查收！！！★★★下一次幸运星奖励将在|r|cffff0000(' ..
                                                                TIME .. '分钟)|r|cFFF08000后开始.请留意★★★|r'
                )
            end
            local sendtime = os.date('%Y-%m-%d %H:%M:%S')
            diffTime = os.time()
            -- 	SendMail("无敌幸运星奖励","您的运气天下无敌！祝您玩的愉快！",text:GetString(0),0,61,0,itemID,itemID,Count)
            if (text:GetString(3) == '0' or (text:GetString(3) == '1' and onlieeamil == 0)) then
                if (eamil == 1) then
                    SendMail(
                        '无敌幸运星奖励',
                        '您的运气天下无敌！\r\n您在' .. sendtime .. '获得了奖励物品' .. GetItemLink(itemID) .. 'X' .. Count .. ',请您查收,祝您玩的愉快！',
                        text:GetString(0),
                        0,
                        61,
                        0,
                        itemID,
                        Count
                    )
                else
                    SendMail(
                        '无敌幸运星奖励',
                        '您的运气天下无敌！\r\n您在' .. sendtime .. '获得了奖励物品' .. GetItemLink(itemID) .. 'X' .. Count .. ',请您查收,祝您玩的愉快！',
                        text:GetString(0),
                        0,
                        61,
                        0,
                        0,
                        0,
                        itemID,
                        Count
                    )
                end
            else
                local player1 = GetPlayerByGUID(text:GetString(0))
                player1:AddItem(itemID, Count)
                player1:SendBroadcastMessage(
                    '您的运气天下无敌！\r\n您在' .. sendtime .. '获得了奖励物品' .. GetItemLink(itemID) .. 'X' .. Count .. ',请您查收,祝您玩的愉快！'
                )
                player1:SendAreaTriggerMessage(
                    '您的运气天下无敌！\r\n您在' .. sendtime .. '获得了奖励物品' .. GetItemLink(itemID) .. 'X' .. Count .. ',请您查收,祝您玩的愉快！'
                )
            end

        --SendMail('无敌幸运星奖励','您的运气天下无敌！祝您玩的愉快！',text:GetString(0),'',61,0,0,0,itemID,Count)
        --SendMail("无敌幸运星奖励","您的运气天下无敌！祝您玩的愉快！","371","0",61,1000,0,0,itemID,Count)
        end
    end
end

RegisterServerEvent(5, luckstar)
