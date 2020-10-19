#include "AnticheatMgr.h"
#include "Object.h"
#include "AccountMgr.h"
#include "AnticheatData.h"

int64 resetTime = 0;
int32 UpdateMovement = 0;
int64 lastIterationPlayer = sWorld.GetUptime() + 30;//TODO: change 30 secs static to a configurable option
class AnticheatPlayerScript : public PlayerScript
{
public:
	AnticheatPlayerScript()
		: PlayerScript("AnticheatPlayerScript")
	{
	}

	void OnLogout(Player* player) override
	{
		sAnticheatMgr->HandlePlayerLogout(player);
	}

	void OnLogin(Player* player, bool /*FirstTime*/) override
	{
		sAnticheatMgr->HandlePlayerLogin(player);
		if(sWorld.GetModuleBoolConfig("Anticheat.LoginMessage", true))
			ChatHandler(player->GetSession()).PSendSysMessage("此服务器正在运行|cff4CFF00防作弊|模块。");
	}
};

class AnticheatMovementHandlerScript : public MovementHandlerScript
{
	public:
	AnticheatMovementHandlerScript()
		: MovementHandlerScript("AnticheatMovementHandlerScript")
	{
	}
	void OnPlayerMove(Player* player, MovementInfo mi, uint32 opcode) override
	{
		sAnticheatMgr->StartHackDetection(player, mi, opcode); 
	}
};
void startAnticheatScripts()
{
	new AnticheatPlayerScript();
	new AnticheatMovementHandlerScript();
}
