--[[ Double XP weekend script for ELUNA

Written by Nix
Discord: Nix#4045
Website: http://novuscore.org
Github: https://github.com/NixAJ

Edited By Talamortis
Discord: Speedfangz#6864
Github: https://github.com/talamortis
]]


local function OnGivenXP(event, player, amount, victim)
	local day = os.date("*t").wday
    if day == 6 or day == 7 or day == 1 then
        amount = amount * 2
    end
	
	return amount
end

local function OnLogin(event, player)

	local day = os.date("*t").wday
    if day == 6 or day == 7 or day == 1 then
		player:SendBroadcastMessage("|cffff0000[公告]|r 今天是周末!XP是两倍 |cFFADFF2F开启|r! ")
	end
		
end

RegisterPlayerEvent(12, OnGivenXP)
RegisterPlayerEvent(3, OnLogin)