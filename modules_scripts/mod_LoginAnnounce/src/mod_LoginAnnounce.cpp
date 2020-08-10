#include "ScriptMgr.h"
#include "Configuration/Config.h"
#include "Player.h"
#include "World.h"
#include "Chat.h"

class modLoginAnnounce : public PlayerScript
{
public:
    modLoginAnnounce() : PlayerScript("LoginAnnounce") { }

    void OnLogin(Player* player, bool firstLogin) override
    {

        if (!sWorld.GetModuleBoolConfig("LoginAnnounce.Enable", true))
            return;

        std::ostringstream ss;

        if (player->GetTeam() == ALLIANCE)
        {
            ss << "|cff3DAEFF[ 登录公告 ]|cffFFD800 : 玩家|cff4CFF00 " << player->GetName() << " |cffFFD800已上线，TA来自|cff0026FF 联盟";
            sWorld.SendServerMessage(SERVER_MSG_STRING, ss.str().c_str());
        }
        else
        {
            ss << "|cff3DAEFF[ 登录公告 ]|cffFFD800 : 玩家|cff4CFF00 " << player->GetName() << " |cffFFD800已上线，TA来自|cffFF0000 部落";
            sWorld.SendServerMessage(SERVER_MSG_STRING, ss.str().c_str());
        }
    }
};

void Addmod_LoginAnnounceScripts()
{
    new modLoginAnnounce();
}