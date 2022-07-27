#include <sourcemod>
#include <sdktools>
#include <multicolors>

int g_Type = 2;

ConVar g_cl_allowdownload;
ConVar g_cl_allowupload;
ConVar g_cl_downloadfilter;
ConVar g_cl_ignorelinux;

bool g_bLateLoad;
bool g_bShouldCheck[OS_Total];

Handle g_Forward_OnParseOS;

char g_sCvarCheck[OS_Total][32];

OperatingSystem g_ClientOS[MAXPLAYERS + 1] = { OS_Unknown, ... };
OperatingSystem gOSType;

enum OperatingSystem {
	OS_Unknown = -1,
	OS_Windows = 0,
	OS_Linux = 1,
	OS_Mac = 2,
	OS_Total = 3
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLateLoad = late;
	g_Forward_OnParseOS = CreateGlobalForward("OnParseOS", ET_Ignore, Param_Cell, Param_Cell);
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = "[ANY] CL_Forcer", 
	author = "Gold_KingZ", 
	description = "Force Client To Download-Table", 
	version = "1.0.2", 
	url = "https://github.com/oqyh"
};

public void OnPluginStart(){
	LoadTranslations( "CL_Forcer.phrases" );
	
	new Handle:sm_force_method = CreateConVar("sm_force_method", "1", "Choose What To Do With Them || 1= Kick Them From The Server || 2= Send Them To Spec" );
	g_cl_allowdownload = CreateConVar("sm_cl_allowdownload", "1", "Only People With cl_allowdownload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_allowupload = CreateConVar("sm_cl_allowupload", "0", "Only People With cl_allowupload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_downloadfilter = CreateConVar("sm_cl_downloadfilter", "1", "Only People With cl_downloadfilter all Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_ignorelinux = CreateConVar("sm_cl_ignorelinux", "0", "Let Linux bypass all CL_Forcer || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
	
	Handle hConfig = LoadGameConfigFile("detect_os.games");
	
	if (hConfig == null)
		SetFailState("Failed to find gamedata file: detect_os.games.txt");
	
	AddCommandListener(ForceTeam, "jointeam");
	
	HookConVarChange(sm_force_method, OnFixTypeChanged); 
   	g_Type = GetConVarInt(sm_force_method);
	
	if (g_bLateLoad)
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i))
				OnClientPutInServer(i);
	
	AutoExecConfig(true, "CL_Forcer");
}

public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client))
		return;
	
	int serial = GetClientSerial(client);
	
	if (g_bShouldCheck[OS_Windows])
		QueryClientConVar(client, g_sCvarCheck[OS_Windows], OnCvarCheck, serial);
	
	if (g_bShouldCheck[OS_Linux])
		QueryClientConVar(client, g_sCvarCheck[OS_Linux], OnCvarCheck, serial);
	
	if (g_bShouldCheck[OS_Mac])
		QueryClientConVar(client, g_sCvarCheck[OS_Mac], OnCvarCheck, serial);
}

public void OnClientDisconnect_Post(int client)
{
	g_ClientOS[client] = OS_Unknown;
}

public void OnCvarCheck(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any serial)
{
	if (result == ConVarQuery_NotFound || GetClientFromSerial(serial) != client || !IsClientInGame(client))
		return;
	
	if (StrEqual(cvarName, g_sCvarCheck[OS_Windows]))
		g_ClientOS[client] = OS_Windows;
	else if (StrEqual(cvarName, g_sCvarCheck[OS_Linux]))
		g_ClientOS[client] = OS_Linux;
	else if (StrEqual(cvarName, g_sCvarCheck[OS_Mac]))
		g_ClientOS[client] = OS_Mac;
	
	Call_StartForward(g_Forward_OnParseOS);
	Call_PushCell(client);
	Call_PushCell(g_ClientOS[client]);
	Call_Finish();
}

public OnFixTypeChanged(Handle:convar, const String:oldValue[], const String:newValue[]) 
{ 
	g_Type = GetConVarInt(convar);
}

public void CheckCvar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value){
	if(GetClientTeam(client) == 0)
		return;
	char clientname[MAX_NAME_LENGTH];
    	GetClientName(client, clientname, MAX_NAME_LENGTH);
	
	int val = StringToInt(cvarValue);
	

	if (GetConVarBool(g_cl_allowdownload))
	{
		if(val == 0)
		{
			if(g_Type == 1)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						KickClient(client, "%t", "kick_cl_allowdownload");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					KickClient(client, "%t", "kick_cl_allowdownload");
				}
			}
			
			else if(g_Type == 2)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						ChangeClientTeam(client, 1);
						CPrintToChat(client, "%t", "chat_cl_allowdownload");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					ChangeClientTeam(client, 1);
					CPrintToChat(client, "%t", "chat_cl_allowdownload");
				}
			}	
		}
	}
	}
public void CheckCvar1(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value){
	if(GetClientTeam(client) == 0)
		return;
	char clientname[MAX_NAME_LENGTH];
    	GetClientName(client, clientname, MAX_NAME_LENGTH);
	
	int val = StringToInt(cvarValue);
	
	if (GetConVarBool(g_cl_allowupload))
	{
		if(val == 0)
		{
			if(g_Type == 1)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						KickClient(client, "%t", "kick_cl_allowupload");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					KickClient(client, "%t", "kick_cl_allowupload");
				}
			}
			
			else if(g_Type == 2)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						ChangeClientTeam(client, 1);
						CPrintToChat(client, "%t", "chat_cl_allowupload");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					ChangeClientTeam(client, 1);
					CPrintToChat(client, "%t", "chat_cl_allowupload");
				}
			}
		}
	}
	}

public void CheckCvar2(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value){
	if(GetClientTeam(client) == 0)
		return;
	char clientname[MAX_NAME_LENGTH];
    	GetClientName(client, clientname, MAX_NAME_LENGTH);
	
	int val = StringToInt(cvarValue);
	
	if(strcmp(cvarValue,"none",false) == 0)
	{
	if (GetConVarBool(g_cl_downloadfilter))
	{
		if(val == 0)
		{
			if(g_Type == 1)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						KickClient(client, "%t", "kick_cl_downloadfilter");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					KickClient(client, "%t", "kick_cl_downloadfilter");
				}
			}
			
			else if(g_Type == 2)
			{
				if(GetConVarBool(g_cl_ignorelinux))
				{
					if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
					{
						ChangeClientTeam(client, 1);
						CPrintToChat(client, "%t", "chat_cl_downloadfilter");
					}else if(gOSType == OS_Linux)
					{
					 return;
					}
				}
				else
				{
					ChangeClientTeam(client, 1);
					CPrintToChat(client, "%t", "chat_cl_downloadfilter");
				}
			}
		}
	}
	}
	}
	
void ProcessLagComp(int client){
	QueryClientConVar(client, "cl_allowdownload", CheckCvar);
	QueryClientConVar(client, "cl_allowupload", CheckCvar1);
	QueryClientConVar(client, "cl_downloadfilter", CheckCvar2);
}

public Action ForceTeam(int client, const char[] command, int args){
	ProcessLagComp(client);
	
	return Plugin_Continue; 
}