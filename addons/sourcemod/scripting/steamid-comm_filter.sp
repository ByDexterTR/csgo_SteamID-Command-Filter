#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

char path[256];

public Plugin myinfo = 
{
	name = "", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	BuildPath(Path_SM, path, 256, "data/steamid-comm_filter.ini");
}

public void OnMapStart()
{
	LoadConfigs();
}

void LoadConfigs()
{
	char sBuffer[64];
	KeyValues Kv = new KeyValues("ByDexter");
	Kv.ImportFromFile(path);
	if (Kv.GotoFirstSubKey())
	{
		do
		{
			if (Kv.GetSectionName(sBuffer, 64))
			{
				AddCommandListener(FilterCommand, sBuffer);
			}
		}
		while (Kv.GotoNextKey());
	}
	delete Kv;
}

public Action FilterCommand(int client, const char[] command, int argc)
{
	KeyValues Kv = new KeyValues("ByDexter");
	Kv.ImportFromFile(path);
	Kv.JumpToKey(command, false);
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, 32);
	int c = Kv.GetNum(steamid, 0);
	delete Kv;
	if (c != 1)
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok.");
		return Plugin_Stop;
	}
	return Plugin_Continue;
} 