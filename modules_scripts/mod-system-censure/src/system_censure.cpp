#include "ScriptMgr.h"
#include "Chat.h"
#include <list>
#include <algorithm>
#include <cctype>
#include <string>

std::vector<std::string>chat;

class SystemCensure : public PlayerScript
{
public:
    SystemCensure() : PlayerScript("SystemCensure") {}

    void OnLogin(Player* p, bool firstLogin)
    {
        ChatHandler(p->GetSession()).PSendSysMessage("服务器已开启|cff4CFF00反广告系统|模块。");
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 lang, std::string& msg)
    {
        CheckMessage(player, msg, lang, NULL, NULL, NULL, NULL);
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 lang, std::string& msg, Player* receiver)
    {
        CheckMessage(player, msg, lang, receiver, NULL, NULL, NULL);
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 lang, std::string& msg, Group* group)
    {
        CheckMessage(player, msg, lang, NULL, group, NULL, NULL);
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 lang, std::string& msg, Guild* guild)
    {
        CheckMessage(player, msg, lang, NULL, NULL, guild, NULL);
    }

    void OnChat(Player* player, uint32 /*type*/, uint32 lang, std::string& msg, Channel* channel)
    {
        CheckMessage(player, msg, lang, NULL, NULL, NULL, channel);
    }

    void CheckMessage(Player* player, std::string& msg, uint32 lang, Player* /*receiver*/, Group* /*group*/, Guild* /*guild*/, Channel* channel)
    {
        //if account is game master let them say what ever they like just incase they need to send the website
       if (player->GetSession()->GetSecurity() >= 1)
            return;

        // transform to lowercase (for simpler checking)
        std::string lower = msg;
        std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
       
        // Now we converted to lower lets remove the spaces
        lower.erase(std::remove_if(lower.begin(), lower.end(), ::isspace), lower.end());
       
        for (int i = 0; i < chat.size(); ++i)
            if (lower.find(chat[i]) != std::string::npos)
            {
                msg = "OregonCore很棒！";
                ChatHandler(player->GetSession()).PSendSysMessage("链接/广告是不允许的！");
                return;
            }
    }
};

class LoadChatTable : public WorldScript
{
public:
    LoadChatTable() : WorldScript("load_system_censure") { }

    void OnLoadCustomDatabaseTable()
    {
        sLog.outString("正在加载聊天提示...");

        QueryResult* result = CharacterDatabase.PQuery("SELECT `id`,`text` FROM chat_censure");

        if (!result)
        {
            sLog.outErrorDb(">>  已加载0个聊天提示。 数据库表“ Chat_Censure”为空！");
            sLog.outString();
            return;
        }

        uint32 count = 0;
        uint32 oldMSTime = getMSTime();
        
        do
        {
            Field* field = result->Fetch();
            uint8 id = field[0].GetUInt8();
            chat.push_back(field[1].GetString());

            count++;

        } while (result->NextRow());

        sLog.outString(">> 已在 %u ms中加载 %u chat_censure", count, GetMSTimeDiffToNow(oldMSTime));
        sLog.outString("");
    }
};

class ChatCensureCommand : public CommandScript 
{
public:
    ChatCensureCommand() : CommandScript("ChatCensureCommand") { }

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> ChatCensureCommandTable =
        {
            { "Reload", SEC_ADMINISTRATOR, true, &HandleReloadCommand, "Realod the chat Censure table" },
            { "Add",    SEC_ADMINISTRATOR, false, &HandleAddCommand,    "禁止一句话。 添加时请使用引号。"},
            { "Delete", SEC_ADMINISTRATOR, false, &HandleDeleteCommand, "删除被禁止的单词。 删除时请使用引号"}
        };

        static std::vector<ChatCommand> commandTable =
        {
            { "ChatCensure", SEC_ADMINISTRATOR, false, nullptr, "", ChatCensureCommandTable }
        };

        return commandTable;
    }

    static bool HandleReloadCommand(ChatHandler* handler, char const* args)
    {
        Player* me = handler->GetSession()->GetPlayer();

        if (!me)
            return false;

        chat.clear();
        QueryResult* result = CharacterDatabase.PQuery("SELECT `id`,`text` FROM chat_censure");
        uint32 count = 0;
        uint32 oldMSTime = getMSTime();

        do
        {
            Field* field = result->Fetch();
            uint8 id = field[0].GetUInt8();
            chat.push_back(field[1].GetString());

            count++;

        } while (result->NextRow());

        ChatHandler(me->GetSession()).PSendSysMessage("已在 %u ms中重新加载 %u chat_censure", count, GetMSTimeDiffToNow(oldMSTime));
        return true;

    }

    static bool HandleAddCommand(ChatHandler* handler, char const* args)
    {
        Player* me = handler->GetSession()->GetPlayer();

        if (!me)
            return false;

        if (!args)
            return false;

        char* textExtracted = handler->extractQuotedArg((char*)args);

        if (!textExtracted)
            return false;

        std::string text = textExtracted;


        //让我们检查一下数据库，看看是否有重复的条目
       QueryResult* result = CharacterDatabase.PQuery("SELECT `text` FROM `chat_censure` WHERE `text` = '%s'", text.c_str());

        //lets check the Database to see if arguement already exist
        QueryResult* result = CharacterDatabase.PQuery("SELECT `text` FROM `chat_censure` WHERE `text` = '%s'", text.c_str());


        if (result)
        {
            ChatHandler(me->GetSession()).PSendSysMessage("重复输入文本: |cff4CFF00 %s|r", text.c_str());
        }
        else
        {
            CharacterDatabase.PQuery("INSERT INTO `chat_censure` (`text`) VALUES ('%s')", text.c_str());
            ChatHandler(me->GetSession()).PSendSysMessage("添加文字: |cff4CFF00 %s|r 到反广告系统", text.c_str());
        }
        return true;
    }

    static bool HandleDeleteCommand(ChatHandler* handler, char const* args)
    {
        Player* me = handler->GetSession()->GetPlayer();

        if (!me)
            return false;

        if (!args)
            return false;

        //we want argument to be in "" for spaces ect.
        char* textExtracted = handler->extractQuotedArg((char*)args);

        if (!textExtracted)
            return false;

        std::string text = textExtracted;

        QueryResult* result = CharacterDatabase.PQuery("SELECT `text` FROM `chat_censure` WHERE `text` = '%s'", text.c_str());

        if (!result)
        {
            ChatHandler(me->GetSession()).PSendSysMessage("在数据库中找不到文本：|cff4CFF00 %s|r", text.c_str());
        }
        else
        {
            CharacterDatabase.PQuery("DELETE FROM `chat_censure` WHERE `text` = '%s'", text.c_str());
            ChatHandler(me->GetSession()).PSendSysMessage("已删除文本 |cff4CFF00 %s|r 请重新加载表", text.c_str());
        }

        return true;
    }

}; 

void AddSC_SystemCensure()
{
    new ChatCensureCommand();
    new SystemCensure();
    new LoadChatTable();
}
