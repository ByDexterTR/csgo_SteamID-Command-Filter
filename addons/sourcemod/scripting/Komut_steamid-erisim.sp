#include <sourcemod>
#include <console>
#include <adt_array>
#include <sdktools>
#include <regex>

Handle Arr_SteamIDs = null, RegEx_SteamID = null;

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Komut SteamID Erişim", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadConfig();
}

public void OnMapEnd()
{
	LoadConfig();
}

public void LoadConfig()
{
	char Str_RegExpCompileError[256];
	RegexError Num_RegExpError;
	char RegEx_SteamIDPattern[256];
	RegEx_SteamIDPattern = "^(STEAM_\\d:\\d:\\d+)$";
	RegEx_SteamID = CompileRegex(RegEx_SteamIDPattern, 0, Str_RegExpCompileError, sizeof(Str_RegExpCompileError), Num_RegExpError);
	if (RegEx_SteamID == null)
	{
		SetFailState("Error: %d - Derlenemedi! %s", Num_RegExpError, Str_RegExpCompileError);
	}
	Handle File_SteamIDList = OpenFile("addons/sourcemod/configs/dexter/steamids.txt", "rt");
	if (File_SteamIDList == null)
	{
		SetFailState("%s dosyası bulunamadı.", "steamids.txt");
	}
	Arr_SteamIDs = CreateArray(256);
	char Str_SteamID[256];
	while (!IsEndOfFile(File_SteamIDList) && ReadFileLine(File_SteamIDList, Str_SteamID, sizeof(Str_SteamID)))
	{
		StripQuotes(Str_SteamID);
		ReplaceString(Str_SteamID, sizeof(Str_SteamID), "\r", "");
		ReplaceString(Str_SteamID, sizeof(Str_SteamID), "\n", "");
		RegexError Num_ErrCode;
		if (MatchRegex(RegEx_SteamID, Str_SteamID, Num_ErrCode) != -1)
		{
			GetRegexSubString(RegEx_SteamID, 0, Str_SteamID, sizeof(Str_SteamID));
			PushArrayString(Arr_SteamIDs, Str_SteamID);
		}
		else
		{
			SetFailState("Bilinmeyen SteamID: %s (%d) !", Str_SteamID, Num_ErrCode);
		}
	}
	delete File_SteamIDList;
	
	KeyValues Kv = new KeyValues("ByDexter");
	char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "configs/dexter/access-command_steamid.ini");
	if (!FileToKeyValues(Kv, sBuffer))SetFailState("%s dosyası bulunamadı.", sBuffer);
	
	if (Kv.GotoFirstSubKey())
	{
		do
		{
			if (Kv.GetSectionName(sBuffer, sizeof(sBuffer)))
			{
				AddCommandListener(Control_CommandX, sBuffer);
			}
		}
		while (Kv.GotoNextKey());
	}
	delete Kv;
}

public Action Control_CommandX(int client, const char[] command, int args)
{
	char Str_ClientSteamID[32];
	GetClientAuthId(client, AuthId_Steam2, Str_ClientSteamID, sizeof(Str_ClientSteamID));
	int Num_PlayerFound = FindStringInArray(Arr_SteamIDs, Str_ClientSteamID);
	if (Num_PlayerFound >= 0)
	{
		return Plugin_Continue;
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok");
		return Plugin_Stop;
	}
} 