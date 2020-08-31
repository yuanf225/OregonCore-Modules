#include "ScriptMgr.h"
#include <time.h>

time_t t = time(NULL);
tm *now = localtime(&t);

class DoubleXpWeekend : public PlayerScript
{
public:
    DoubleXpWeekend() : PlayerScript("DoubleXpWeekend") {}

    bool Enabled = sWorld.GetModuleBoolConfig("XPWeekend.Enabled", true);
    uint32 xpAmount = sWorld.GetModuleIntConfig("XPWeekend.xpAmount", 2);

        void OnLogin(Player* player, bool firstLogin)
        {
            // 向玩家宣布周末双倍经验即将开启。
            if (!Enabled)
                return;

            if (now->tm_wday == 5 /*Friday*/ || now->tm_wday == 6 /*Satureday*/ || now->tm_wday == 0/*Sunday*/)
                ChatHandler(player->GetSession()).PSendSysMessage("现在是周末！您的XP率已设置为: %u", xpAmount);
            else
                ChatHandler(player->GetSession()).SendSysMessage("服务器已开启|cff4CFF00周末双倍经验|模块");
        }

        void OnGiveXP(Player* p, uint32& amount, Unit* victim) override
        {
            if (!Enabled)
                return;

            if (now->tm_wday == 5 /*Friday*/ || now->tm_wday == 6 /*Satureday*/ || now->tm_wday == 0/*Sunday*/ && now->tm_hour >= 0)
                amount *= xpAmount;
            else
                amount == amount;
        }
};

void AddDoubleXPScripts()
{
    new DoubleXpWeekend();
}