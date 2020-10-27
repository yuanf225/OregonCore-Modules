/* ScriptData
+SDName: Titles Giver NPC
+SD%Complete: 100
+SDComment: By Evrial
+SDCategory: NPC
+EndScriptData */

#include "ScriptPCH.h"
#include <cstring>
#include "Config.h"
#include "World.h"
#include "Chat.h"
#include "SystemConfig.h"

class npc_titles : public CreatureScript
{
public:
    npc_titles() : CreatureScript("npc_titles") {}

bool OnGossipHello(Player* pPlayer, Creature* pCreature)
{
    if (sWorld.GetModuleBoolConfig("Npc_Titles.Enable", true))
    {
    pPlayer->ADD_GOSSIP_ITEM( 0, "Gladiator's Title", GOSSIP_SENDER_MAIN, 1000);
    pPlayer->ADD_GOSSIP_ITEM( 0, "Merciless Gladiator's Title", GOSSIP_SENDER_MAIN, 2000);
    pPlayer->ADD_GOSSIP_ITEM( 0, "Vengeful Gladiator's Title", GOSSIP_SENDER_MAIN, 3000);

    pPlayer->SEND_GOSSIP_MENU(pPlayer->GetGossipTextId(pCreature), pCreature->GetGUID());
    return true;
    }
}

void SendDefaultMenu(Player* pPlayer, Creature* pCreature, uint32 uiAction)
{
    // 在战斗中不允许。
    if (pPlayer->IsInCombat())
    {
      pPlayer->CLOSE_GOSSIP_MENU();
      pCreature->MonsterSay("你在战斗中!", LANG_UNIVERSAL, NULL);
      return;
    }

    // 程序菜单选择
    switch(uiAction)
    { 
        case 1000:
            // 角斗士的称号
            if(pPlayer->GetMoney() >= (sWorld.GetModuleIntConfig("Npc_Titles.Cost", 10) * 10000) && (pPlayer->GetMaxPersonalArenaRatingRequirement() >= sWorld.GetModuleIntConfig("Npc_Titles.Glad.Rating", 0) 
                && pPlayer->HasItemCount(sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemID", 0), sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemCount", 0), true) 
                && pPlayer->GetHonorPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.Glad.Honor", 0) 
                && pPlayer->GetArenaPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.Glad.Ap", 0)))
            {
                uint32 idg;
                idg = 42;
                CharTitlesEntry const* title = sCharTitlesStore.LookupEntry(idg);
                pPlayer->CLOSE_GOSSIP_MENU();
                pPlayer->ModifyMoney((-1)*sWorld.GetModuleIntConfig("CONFIG_TITLER_G_GOLD", 0) * 10000);
                pPlayer->DestroyItemCount(sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemID", 0),sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemCount", 0), true);
                pPlayer->ModifyHonorPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.Glad.Honor", 0));
                pPlayer->ModifyArenaPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.Glad.Ap", 0));
                pPlayer->SetTitle(title);
                pCreature->MonsterWhisper("您获得了新的称号，请重新登录。", pPlayer->GetGUID());
            }
            else
            {
                pPlayer->CLOSE_GOSSIP_MENU();
                pCreature->MonsterWhisper("你做不到!", pPlayer->GetGUID());
            }
            break;
        case 2000:
            // Merciless Gladiator's Title
            if(pPlayer->GetMoney() >= (sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Gold", 10) * 10000) && (pPlayer->GetMaxPersonalArenaRatingRequirement() >= sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Rating", 0) 
                && pPlayer->GetItemCount(sWorld.GetModuleIntConfig("Npc_Titles.MGlad.ItemID", 0)) >= sWorld.GetModuleIntConfig("Npc_Titles.MGlad.ItemCount", 0) 
                && pPlayer->GetHonorPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Honor", 0) 
                && pPlayer->GetArenaPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Ap", 0)))
            {
                uint32 idmg;
                idmg = 62;
                CharTitlesEntry const* title = sCharTitlesStore.LookupEntry(idmg);
                pPlayer->CLOSE_GOSSIP_MENU();
                pPlayer->ModifyMoney((-1)*sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Gold", 10) * 10000);
                pPlayer->DestroyItemCount(sWorld.GetModuleIntConfig("Npc_Titles.MGlad.ItemID", 0),sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemCount", 0), true);
                pPlayer->ModifyHonorPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Honor", 0));
                pPlayer->ModifyArenaPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.MGlad.Ap", 0));
                pPlayer->SetTitle(title);
                pCreature->MonsterWhisper("Here are your Merciless Gladuator's Title. Relogin please.", pPlayer->GetGUID());
            }
            else
            {
                pPlayer->CLOSE_GOSSIP_MENU();
                pCreature->MonsterWhisper("You can not do it!", pPlayer->GetGUID());
            }
            break;
        case 3000:
            // Vengeful Gladiator's Title
            if(pPlayer->GetMoney() >= (sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Gold", 10) * 10000) && (pPlayer->GetMaxPersonalArenaRatingRequirement() >= sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Rating", 0) 
                && pPlayer->GetItemCount(sWorld.GetModuleIntConfig("Npc_Titles.VGlad.ItemID", 0)) >= sWorld.GetModuleIntConfig("Npc_Titles.VGlad.ItemCount", 0) 
                && pPlayer->GetHonorPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Honor", 0) 
                && pPlayer->GetArenaPoints() >= sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Ap", 0)))
            {
                uint32 idvg;
                idvg = 71;
                CharTitlesEntry const* title = sCharTitlesStore.LookupEntry(idvg);
                pPlayer->CLOSE_GOSSIP_MENU();
                pPlayer->ModifyMoney((-1)*sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Gold", 10) * 10000);
                pPlayer->DestroyItemCount(sWorld.GetModuleIntConfig("Npc_Titles.VGlad.ItemID", 0),sWorld.GetModuleIntConfig("Npc_Titles.Glad.ItemCount", 0), true);
                pPlayer->ModifyHonorPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Honor", 0));
                pPlayer->ModifyArenaPoints((-1)*sWorld.GetModuleIntConfig("Npc_Titles.VGlad.Ap", 0));
                pPlayer->SetTitle(title);
                pCreature->MonsterWhisper("Here are your Vengeful Gladuator's Title. Relogin please.", pPlayer->GetGUID());
            }
            else
            {
                pPlayer->CLOSE_GOSSIP_MENU();
                pCreature->MonsterWhisper("You can not do it!", pPlayer->GetGUID());
            }
            break;
    }
}

bool OnGossipSelect(Player* pPlayer, Creature* pCreature, uint32 uiSender, uint32 uiAction)
{
    // 显示菜单
    if (uiSender == GOSSIP_SENDER_MAIN)
        SendDefaultMenu(pPlayer, pCreature, uiAction);
    return true;
}
};

class npc_titles_Announce : public PlayerScript
{
public:

    npc_titles_Announce() : PlayerScript("npc_titles_Announce") {}

    void OnLogin(Player* player, bool firstlogin)
    {
        // Announce Module
        if (sWorld.GetModuleBoolConfig("Npc_Titles.Enable", true) && sWorld.GetModuleBoolConfig("Npc_Titles.Announce", true))
        {
            ChatHandler(player->GetSession()).SendSysMessage("服务器已开启|cff4CFF00称号大师|模块。");
        }
    }
};

void AddSC_npc_titles()
{
    new npc_titles();
    new npc_titles_Announce();
}
