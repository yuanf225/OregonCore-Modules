#include "Guild.h"
#include "Player.h"
#include "Map.h"
#include "mod_guildhouse.h"
#include "Language.h"

bool GuildHouse::SelectGuildHouse(Guild* guild, Player* player, Creature* creature)
{
    QueryResult* result = CharacterDatabase.PQuery("SELECT `id`, `guild` FROM guild_house WHERE `guild` = %u", player->GetGuildId());

    if (result)
    {
        ChatHandler(player->GetSession()).PSendSysMessage("你不能再购买公会领地了!");
        player->CLOSE_GOSSIP_MENU();
        return false;
    }

    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_MONEY_BAG, "GM岛", GOSSIP_SENDER_MAIN, 100, "购买GM岛公会领地", sWorld.GetModuleIntConfig("GuildHouse.Cost", 10000000), false);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, " ----- 未来会更多 ----", GOSSIP_SENDER_MAIN, 4);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
    return true;
}

bool GuildHouse::SellGuildHouse(Player* player, Guild* guild)
{

    QueryResult* result = CharacterDatabase.PQuery("SELECT id, `guild` FROM `guild_house` WHERE guild = %u", player->GetGuildId());

    if (!result)
    {
        ChatHandler(player->GetSession()).PSendSysMessage("您没有一个活跃的公会领地!");
        return false;
    }

    CharacterDatabase.PQuery("DELETE FROM `guild_house` WHERE guild = %u", player->GetGuildId());

    if (player->GetGuildId() != 1)
    {
        WorldDatabase.PQuery("DELETE FROM `creature` WHERE `map` = 1 AND phaseMask = %u", player->GetGuildId());
        WorldDatabase.PQuery("DELETE FROM `gameobject` WHERE `map` = 1 and phaseMask = %u", player->GetGuildId());
    }

    ChatHandler(player->GetSession()).PSendSysMessage("你已经成功地卖掉了你的公会领地");
    player->ModifyMoney(+(sWorld.GetModuleIntConfig("GuildHouse.Cost", 10000000) / 2));
    player->CLOSE_GOSSIP_MENU();
    return true;
}

bool GuildHouse::BuyGuildHouse(Player* player, Guild* guild, uint32 action)
{
    switch (action)
    {
    case 100:
        map = 1;
        posX = 16226.117f;
        posY = 16258.046f;
        posZ = 13.257628f;
        zoneId = 876;
        break;
    }

    CharacterDatabase.PQuery("INSERT INTO `guild_house` (guild, phase, map, positionX, positionY, positionZ, zoneId) VALUES (%u, %u, %u, %f, %f, %f, %u)", player->GetGuildId(), player->GetGuildId(), map, posX, posY, posZ, zoneId);
    player->ModifyMoney(-(sWorld.GetModuleIntConfig("GuildHouse.Cost", 10000000)));
    ChatHandler(player->GetSession()).PSendSysMessage("您已经成功地购买了一个公会领地");
    guild->BroadcastToGuild(player->GetSession(), "我们现在有了一个公会领地", LANG_UNIVERSAL);
    player->SaveGoldToDB(); // Save players gold just incase crash
    player->CLOSE_GOSSIP_MENU();
    return true;
}

void GuildHouse::TeleportToGuildHouse(Guild* guild, Player* player, Creature* creature)
{

    if (player->IsInCombat() || player->IsInFlight())
    {
        ChatHandler(player).PSendSysMessage("无法传送到公会领地");
        return;
    }

    QueryResult* result = CharacterDatabase.PQuery("SELECT `id`, `guild`, `phase`, `map`,`positionX`, `positionY`, `positionZ` FROM guild_house WHERE `guild` = %u", player->GetGuildId());

    if (!result)
    {
        ChatHandler(player->GetSession()).PSendSysMessage("你的公会不拥有公会领地");
        return;
    }

    Field* fields = result->Fetch();
    player->TeleportTo(fields[3].GetUInt32(), fields[4].GetFloat(), fields[5].GetFloat(), fields[6].GetFloat(), player->GetOrientation());
}

void GuildHouse::SpawnNPC(uint32 entry, Player* player, uint32 cost)
{
    QueryResult* result = CharacterDatabase.PQuery("SELECT `id`, `guild`, `phase`, `map`,`positionX`, `positionY`, `positionZ`, `zoneId` FROM guild_house WHERE `guild` = %u", player->GetGuildId());;

    if (!result)
        return;

    Field* fields = result->Fetch();

    //check we are the right zone before allowing to spawn
    if (player->GetZoneId() != fields[7].GetUInt32())
    {
        ChatHandler(player).PSendSysMessage("只能在你的公会领地创建NPC！");
        return;
    }

    if (player->FindNearestCreature(entry, VISIBILITY_RANGE))
    {
        ChatHandler(player).PSendSysMessage("该NPC已经存在！");
        return;
    }

    // Now make sure we are in the right phase
    if (fields[2].GetUInt32() != player->GetGuildId())
    {
        ChatHandler(player).PSendSysMessage("Incorrect Phasing to spawn creature");
        return;
    }

    Creature* creature = new Creature;
    if (!creature->Create(sObjectMgr.GenerateLowGuid(HIGHGUID_UNIT), player->GetMap(), player->GetPhaseMask(), entry, (uint32)0, player->GetPositionX(), player->GetPositionY(), player->GetPositionZ(), player->GetOrientation()))
    {
        delete creature;
        return;
    }

    creature->SaveToDB(player->GetMap()->GetId(), (1 << player->GetMap()->GetSpawnMode()), player->GetGuildId());

    uint32 db_guid = creature->GetDBTableGUIDLow();

    // To call _LoadGoods(); _LoadQuests(); CreateTrainerSpells();
    if (!creature->LoadCreatureFromDB(db_guid, player->GetMap()))
    {
        delete creature;
        return;
    }

    sObjectMgr.AddCreatureToGrid(db_guid, sObjectMgr.GetCreatureData(db_guid));
    player->ModifyMoney(-cost);
    player->SaveGoldToDB();
    player->CLOSE_GOSSIP_MENU();
}

void GuildHouse::SpawnObject(uint32 entry, Player* player, uint32 cost)
{
    QueryResult* result = CharacterDatabase.PQuery("SELECT `id`, `guild`, `phase`, `map`,`positionX`, `positionY`, `positionZ`, `zoneId` FROM guild_house WHERE `guild` = %u", player->GetGuildId());;

    if (!result)
        return;

    Field* fields = result->Fetch();

    //check we are the right zone before allowing to spawn
    if (player->GetZoneId() != fields[7].GetUInt32())
    {
        ChatHandler(player).PSendSysMessage("物品只能在你的公会领地创建！");
        return;
    }

    // Now make sure we are in the right phase
    if (fields[2].GetUInt32() != player->GetGuildId())
    {
        ChatHandler(player).PSendSysMessage("Incorrect Phasing to spawn creature");
        return;
    }

    if (player->FindNearestGameObject(entry, VISIBLE_RANGE) && entry != 24469)
    {
        ChatHandler(player->GetSession()).PSendSysMessage("您已经有了这个物品!");
        player->CLOSE_GOSSIP_MENU();
        return;
    }

    uint32 objectId = entry;
    if (!objectId)
        return;

    const GameObjectInfo* gInfo = sObjectMgr.GetGameObjectInfo(objectId);

    if (!gInfo)
        return;

    if (gInfo->displayId && !sGameObjectDisplayInfoStore.LookupEntry(gInfo->displayId))
        return;

    GameObject* object = new GameObject;
    uint32 guidLow = sObjectMgr.GenerateLowGuid(HIGHGUID_GAMEOBJECT);

    if (!object->Create(guidLow, gInfo->id, player->GetMap(), player->GetPhaseMask(), player->GetPositionX(), player->GetPositionY(), player->GetPositionZ(), player->GetOrientation(), 0.0f, 0.0f, 0.0f, 0.0f, 0, GO_STATE_READY))
    {
        delete object;
        return;
    }

    // fill the gameobject data and save to the db
    object->SaveToDB(player->GetMapId(), (1 << player->GetMap()->GetSpawnMode()), player->GetGuildId());
    // delete the old object and do a clean load from DB with a fresh new GameObject instance.
    // this is required to avoid weird behavior and memory leaks
    delete object;

    object = new GameObject;
    // this will generate a new guid if the object is in an instance
    if (!object->LoadGameObjectFromDB(guidLow, player->GetMap()))
    {
        delete object;
        return;
    }

    // TODO: is it really necessary to add both the real and DB table guid here ?
    sObjectMgr.AddGameobjectToGrid(guidLow, sObjectMgr.GetGOData(guidLow));
    player->ModifyMoney(-cost);
    player->SaveGoldToDB();
    player->CLOSE_GOSSIP_MENU();

}

void GuildHouse::DeleteCreature(Player* player)
{
    Creature* unit = player->GetSelectedUnit()->ToCreature();

    if (!unit)
        return;

    QueryResult* result = CharacterDatabase.PQuery("SELECT `id`, `guild`, `phase`, `map`,`positionX`, `positionY`, `positionZ`, `zoneId` FROM guild_house WHERE `guild` = %u", player->GetGuildId());;

    if (!result)
        return;

    Field* fields = result->Fetch();

    //check we are the right zone before allowing to spawn
    if (player->GetZoneId() != fields[7].GetUInt32())
    {
        ChatHandler(player).PSendSysMessage("你只能移除你的公会领地的NPC!");
        return;
    }

    // Delete creature
    unit->CombatStop();
    unit->DeleteFromDB();
    unit->AddObjectToRemoveList();
    ChatHandler(player).SendSysMessage(LANG_COMMAND_DELCREATMESSAGE);
}

bool GuildHouse::ShowGameObjectPortals(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    if (player->GetTeamId() == TEAM_ALLIANCE)
    {
        player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：暴风城", GOSSIP_SENDER_MAIN, 183325, "Add Stormwind Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500*GOLD), false);
         player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：铁炉堡", GOSSIP_SENDER_MAIN, 183322, "Add Ironforge Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
         player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：达纳苏斯", GOSSIP_SENDER_MAIN, 183317, "Add Darnassus Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
         player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：埃索达", GOSSIP_SENDER_MAIN, 183321, "Add Exodar Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
    }
    else
    {
        player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：奥格瑞玛", GOSSIP_SENDER_MAIN, 183323, "Add Orgrimmar Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
        player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：幽暗城", GOSSIP_SENDER_MAIN, 183327, "Add Undercity Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
        player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：雷霆崖", GOSSIP_SENDER_MAIN, 183326, "Add Thunderbuff Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
        player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TAXI, "传送：银月城", GOSSIP_SENDER_MAIN, 183324, "Add Silvermoon Portal?", sWorld.GetModuleIntConfig("GuildHouse.Portal", 500 * GOLD), false);
    }
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单！", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::ShowGameObjectMenu(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_TAXI, "传送", GOSSIP_SENDER_MAIN, 8);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_MONEY_BAG, "Guild Vault", GOSSIP_SENDER_MAIN, 187334, "Add a Guild Vault?", sWorld.GetModuleIntConfig("GuildHouse.GuildVault", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TALK, "邮箱", GOSSIP_SENDER_MAIN, 184137, "Add a mailbox?", sWorld.GetModuleIntConfig("GuildHouse.MailBox", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_INTERACT_1, "椅子", GOSSIP_SENDER_MAIN, 24469, "Add a Chair?", sWorld.GetModuleIntConfig("GuildHouse.Chair", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_INTERACT_1, "Anvil", GOSSIP_SENDER_MAIN, 38492, "Add a Anvil?", sWorld.GetModuleIntConfig("GuildHouse.ObjectMisc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_INTERACT_1, "锻铁炉", GOSSIP_SENDER_MAIN, 1685, "Add a Forge?", sWorld.GetModuleIntConfig("GuildHouse.ObjectMisc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_INTERACT_1, "炼金试验室", GOSSIP_SENDER_MAIN, 183848, "Add a Alchemy Lab?", sWorld.GetModuleIntConfig("GuildHouse.ObjectMisc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单！", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::ShowCreatureMainMenu(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_TRAINER, "职业训练师", GOSSIP_SENDER_MAIN, 9);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_TRAINER, "专业训练师", GOSSIP_SENDER_MAIN, 10);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "其他", GOSSIP_SENDER_MAIN, 11);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单！", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::ShowClassTrainers(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "德鲁伊", GOSSIP_SENDER_MAIN, 26324, "Spawn Druid Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "猎人", GOSSIP_SENDER_MAIN, 26325, "Spawn Hunter Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "法师", GOSSIP_SENDER_MAIN, 26326, "Spawn Mage Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "圣骑士", GOSSIP_SENDER_MAIN, 26327, "Spawn Paladin Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "牧师", GOSSIP_SENDER_MAIN, 26328, "Spawn Priest Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "盗贼", GOSSIP_SENDER_MAIN, 26329, "Spawn Rogue Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "萨满", GOSSIP_SENDER_MAIN, 26330, "Spawn Shaman Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "术士", GOSSIP_SENDER_MAIN, 26331, "Spawn Warlock Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "战士", GOSSIP_SENDER_MAIN, 26332, "Spawn Warrior Trainer?", sWorld.GetModuleIntConfig("GuildHouse.Trainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::ShowMainMenu(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_INTERACT_1, "游戏物品", GOSSIP_SENDER_MAIN, 3);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_INTERACT_1, "NPC", GOSSIP_SENDER_MAIN, 4);
    player->ADD_GOSSIP_ITEM(GOSSIP_ACTION_BATTLE, "移除NOC", GOSSIP_SENDER_MAIN, 5);
    player->ADD_GOSSIP_ITEM(GOSSIP_ACTION_BATTLE, "移除物品", GOSSIP_SENDER_MAIN, 7);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::ShowProfessionTrainer(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "草药训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 18776 : 18748, "Spawn Engineering Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "采矿训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 18779 : 18747, "Spawn Engineering Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "裁缝训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 18772 : 16583, "Spawn Skinning Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "锻造训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 16823 : 16583, "Spawn Blacksmithing Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "炼金训练师", GOSSIP_SENDER_MAIN, 19052, "Spawn Alchemy Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "附魔训练师", GOSSIP_SENDER_MAIN, 19540, "Spawn Enchanting Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "珠宝加工训练师", GOSSIP_SENDER_MAIN, 19539, "Spawn Jewelcrafting Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "皮革加工训练师", GOSSIP_SENDER_MAIN, 19187, "Spawn Leatherworking Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "剥皮训练师", GOSSIP_SENDER_MAIN, 19180, "Spawn Skinning Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "工程训练师", GOSSIP_SENDER_MAIN, 24868, "Spawn Engineering Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "烹饪训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 4210 : 4552, "Spawn Cooking Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "急救训练师", GOSSIP_SENDER_MAIN, 22477, "Spawn First Aid Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TRAINER, "钓鱼训练师", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 3607 : 3332, "Spawn Cooking Trainer?", sWorld.GetModuleIntConfig("GuildHouse.ProfTrainer", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());

    return true;
}

bool GuildHouse::ShowMiscMenu(Player* player, Item* item)
{
    player->PlayerTalkClass->ClearMenus();
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_CHAT, "旅馆老板", GOSSIP_SENDER_MAIN, 18907, "Spawn InnKeeper?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_MONEY_BAG, "银行家", GOSSIP_SENDER_MAIN, 21733, "Spawn Banker?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_TALK, "拍卖商", GOSSIP_SENDER_MAIN, player->GetTeamId() == TEAM_ALLIANCE ? 8670 : 15686, "Spawn Auctioneer?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "商人", GOSSIP_SENDER_MAIN, 19573, "Spawn Trade Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "炼金物品", GOSSIP_SENDER_MAIN, 11188, "Spawn Alchemy Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "裁缝物品", GOSSIP_SENDER_MAIN, 19213, "Spawn Tailoring Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "工程物品", GOSSIP_SENDER_MAIN, 19575, "Spawn Engineering Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "附魔物品", GOSSIP_SENDER_MAIN, 19537, "Spawn Enchanting Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "烹饪物品", GOSSIP_SENDER_MAIN, 19195, "Spawn Cooking Supplies?", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_VENDOR, "钓鱼物品", GOSSIP_SENDER_MAIN, 18911, "确定创建钓鱼物品吗？", sWorld.GetModuleIntConfig("GuildHouse.Misc", 500 * GOLD), false);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}

bool GuildHouse::OnListNearObjects(Player* player, Item* item)
{
    float distance =  10.0f;
    uint32 count = 0;

    QueryResult* result = WorldDatabase.PQuery("SELECT guid, id, position_x, position_y, position_z, map, "
        "(POW(position_x - '%f', 2) + POW(position_y - '%f', 2) + POW(position_z - '%f', 2)) AS order_ "
        "FROM gameobject WHERE phaseMask='%u' AND map='%u'  AND (POW(position_x - '%f', 2) + POW(position_y - '%f', 2) + POW(position_z - '%f', 2)) <= '%f' ORDER BY order_",
        player->GetPositionX(), player->GetPositionY(), player->GetPositionZ(), player->GetGuildId(),
        player->GetMapId(), player->GetPositionX(), player->GetPositionY(), player->GetPositionZ(), distance * distance);

    if (result)
    {
        do
        {
            Field* fields = result->Fetch();
            uint32 guid = fields[0].GetUInt32();
            uint32 entry = fields[1].GetUInt32();
            float x = fields[2].GetFloat();
            float y = fields[3].GetFloat();
            float z = fields[4].GetFloat();
            int mapid = fields[6].GetUInt16();

            GameObjectInfo const* gInfo = sObjectMgr.GetGameObjectInfo(entry);

            if (!gInfo)
                continue;

           ChatHandler(player).PSendSysMessage(LANG_GO_LIST_CHAT, guid, entry, guid, gInfo->name, x, y, z, mapid);

            ++count;
        } while (result->NextRow());
    }

    ChatHandler(player).PSendSysMessage(LANG_COMMAND_NEAROBJMESSAGE, distance, count);
    player->PlayerTalkClass->ClearMenus();
    player->ADD_GOSSIP_ITEM_EXTENDED(GOSSIP_ICON_CHAT, "移除游戏物品", GOSSIP_SENDER_MAIN, 7, "请输入GUID", 0, true);
    player->ADD_GOSSIP_ITEM(GOSSIP_ICON_CHAT, "主菜单", GOSSIP_SENDER_MAIN, 60000);
    player->SEND_GOSSIP_MENU(DEFAULT_GOSSIP_MESSAGE, item->GetGUID());
    return true;
}