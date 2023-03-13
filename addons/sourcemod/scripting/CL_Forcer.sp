#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <multicolors>

#define PLUGIN_VERSION	"1.0.3"

ConVar h_enable_plugin;
ConVar h_mode_checker;
ConVar f_timer_checker;
ConVar g_cl_allowdownload;
ConVar g_cl_allowupload;
ConVar g_cl_downloadfilter;
ConVar sm_force_method;
ConVar g_cl_ignorelinux;
ConVar f_timer_messages;

bool g_bLateLoad;
bool bh_enable_plugin = false;

bool bg_cl_allowdownload = false;
bool bg_cl_allowupload = false;
bool bg_cl_downloadfilter = false;
bool bg_cl_ignorelinux = false;
bool g_bShouldCheck[OS_Total];

bool ChangedValue1[MAXPLAYERS + 1];
bool ChangedValue3[MAXPLAYERS + 1];
bool ChangedValue4[MAXPLAYERS + 1];
bool ChangedValue5[MAXPLAYERS + 1];
bool bmessages[MAXPLAYERS + 1];
bool bmessages3[MAXPLAYERS + 1];
bool bmessages4[MAXPLAYERS + 1];
bool bmessages5[MAXPLAYERS + 1];
bool timerchecker[MAXPLAYERS + 1];
bool timerchecker3[MAXPLAYERS + 1];
bool timerchecker4[MAXPLAYERS + 1];
bool timerchecker5[MAXPLAYERS + 1];

Handle g_Forward_OnParseOS;
Handle g_bTimer[MAXPLAYERS + 1];
Handle g_bTimer2[MAXPLAYERS + 1];
Handle g_bTimer3[MAXPLAYERS + 1];
Handle g_bTimer4[MAXPLAYERS + 1];
Handle g_bTimer5[MAXPLAYERS + 1];

float  bf_timer_checker = 0.0;
float bf_timer_messages = 0.0;

int bsm_force_method = 0;
int bh_mode_checker = 0;

char g_sCvarCheck[OS_Total][32];

OperatingSystem g_ClientOS[MAXPLAYERS + 1] = { OS_Unknown, ... };
OperatingSystem gOSType;

enum OperatingSystem {
	OS_Unknown = -1,
	OS_Windows = 0,
	OS_Linux = 1,
	OS_Mac = 2,
	OS_Total = 3
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bLateLoad = late;
	g_Forward_OnParseOS = CreateGlobalForward("OnParseOS", ET_Ignore, Param_Cell, Param_Cell);
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[ANY] CL_Forcer", 
	author = "Gold KingZ", 
	description = "Force Client To Download-Table With Reconnect", 
	version = PLUGIN_VERSION,
	url = "https://github.com/oqyh"
}

public void OnPluginStart()
{
	LoadTranslations( "CL_Forcer.phrases" );
	
	CreateConVar("sm_force_version", PLUGIN_VERSION, "[ANY] CL_Forcer Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	h_enable_plugin =  CreateConVar("sm_force_enable", "1", "Enable CL_Forcer Plugin\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	h_mode_checker =  CreateConVar("sm_force_mode", "2", "How Would You Like To Check Players  \n2= By Timer\n1= By Change/Join Team");
	
	f_timer_checker = CreateConVar("sm_force_timer", "0.30", "If [ sm_force_mode 2 ] How Much Time (in sec)");
	
	g_cl_allowdownload = CreateConVar("sm_cl_allowdownload", "1", "Only People With cl_allowdownload 1 Enter The Server\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	g_cl_allowupload = CreateConVar("sm_cl_allowupload", "0", "Only People With cl_allowupload 1 Enter The Server\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	g_cl_downloadfilter = CreateConVar("sm_cl_downloadfilter", "0", "Only People With cl_downloadfilter all Enter The Server\n1= Yes\n0= No", _, true, 0.0, true, 1.0);
	
	sm_force_method = CreateConVar("sm_force_method", "1", "Choose What Type Of Punishment\n1= Kick Them From The Server With Message\n2= Send Them To Spec With Message", _, true, 1.0, true, 2.0);
	
	f_timer_messages = CreateConVar("sm_force_timer_message", "10.0", "If [ sm_force_method 2 ] How Much Time (in sec) Send Him Messages");

	g_cl_ignorelinux = CreateConVar("sm_force_ignorelinux", "0", "Let Linux Users Bypass All CL_Forcer (To Avoid Crashes For Linux Users)\n1= Yes\n0= No", _, true, 0.0, true, 1.0);

	AddCommandListener(ForceTeam, "jointeam");
	AddCommandListener(ForceTeam, "changeteam");
	
	HookConVarChange(h_enable_plugin, OnSettingsChanged);
	HookConVarChange(h_mode_checker, OnSettingsChanged);
	HookConVarChange(f_timer_checker, OnSettingsChanged);
	HookConVarChange(g_cl_allowdownload, OnSettingsChanged);
	HookConVarChange(g_cl_allowupload, OnSettingsChanged);
	HookConVarChange(g_cl_downloadfilter, OnSettingsChanged);
	HookConVarChange(sm_force_method, OnSettingsChanged);
	HookConVarChange(g_cl_ignorelinux, OnSettingsChanged);
	HookConVarChange(f_timer_messages, OnSettingsChanged);
	
	if (g_bLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
	
	AutoExecConfig(true, "CL_Forcer");
}

public void OnConfigsExecuted()
{
	bh_enable_plugin = GetConVarBool(h_enable_plugin);
	bh_mode_checker = GetConVarInt(h_mode_checker);
	bf_timer_checker = GetConVarFloat(f_timer_checker);
	bg_cl_allowdownload = GetConVarBool(g_cl_allowdownload);
	bg_cl_allowupload = GetConVarBool(g_cl_allowupload);
	bg_cl_downloadfilter = GetConVarBool(g_cl_downloadfilter);
	bsm_force_method = GetConVarInt(sm_force_method);
	bg_cl_ignorelinux = GetConVarBool(g_cl_ignorelinux);
	bf_timer_messages = GetConVarFloat(f_timer_messages);
}

public int OnSettingsChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == h_enable_plugin)
	{
		bh_enable_plugin = h_enable_plugin.BoolValue;
	}
	
	if(convar == h_mode_checker)
	{
		bh_mode_checker = h_mode_checker.IntValue;
	}
	
	if(convar == f_timer_checker)
	{
		bf_timer_checker = f_timer_checker.FloatValue;
	}
	
	if(convar == g_cl_allowdownload)
	{
		bg_cl_allowdownload = g_cl_allowdownload.BoolValue;
	}
	
	if(convar == g_cl_allowupload)
	{
		bg_cl_allowupload = g_cl_allowupload.BoolValue;
	}
	
	if(convar == g_cl_downloadfilter)
	{
		bg_cl_downloadfilter = g_cl_downloadfilter.BoolValue;
	}
	
	if(convar == sm_force_method)
	{
		bsm_force_method = sm_force_method.IntValue;
	}
	
	if(convar == g_cl_ignorelinux)
	{
		bg_cl_ignorelinux = g_cl_ignorelinux.BoolValue;
	}
	
	if(convar == f_timer_messages)
	{
		bf_timer_messages = f_timer_messages.FloatValue;
	}
	
	return 0;
}

public void OnClientPutInServer(int client)
{
	if (!bh_enable_plugin || IsFakeClient(client))
		return;
	
	int serial = GetClientSerial(client);
	int userid = GetClientUserId(client);
	
	if (g_bShouldCheck[OS_Windows])
		QueryClientConVar(client, g_sCvarCheck[OS_Windows], OnCvarCheck, serial);
	
	if (g_bShouldCheck[OS_Linux])
		QueryClientConVar(client, g_sCvarCheck[OS_Linux], OnCvarCheck, serial);
	
	if (g_bShouldCheck[OS_Mac])
		QueryClientConVar(client, g_sCvarCheck[OS_Mac], OnCvarCheck, serial);
		
	if(bh_mode_checker == 2)
	{
		CreateTimer(bf_timer_checker, Timer_ConnectPost, userid, TIMER_REPEAT);
	}
}
public void OnClientDisconnect(int client)
{
	ChangedValue1[client] = false;
	ChangedValue3[client] = false;
	ChangedValue4[client] = false;
	ChangedValue5[client] = false;

	bmessages[client] = false;
	bmessages3[client] = false;
	bmessages4[client] = false;
	bmessages5[client] = false;

	timerchecker[client] = false;
	timerchecker3[client] = false;
	timerchecker4[client] = false;
	timerchecker5[client] = false;
	
	if (g_bTimer[client] != INVALID_HANDLE )
	{
		g_bTimer[client] = INVALID_HANDLE;
	}
	
	if (g_bTimer2[client] != INVALID_HANDLE )
	{
		g_bTimer2[client] = INVALID_HANDLE;
	}
	
	if (g_bTimer3[client] != INVALID_HANDLE )
	{
		g_bTimer3[client] = INVALID_HANDLE;
	}
	
	if (g_bTimer4[client] != INVALID_HANDLE )
	{
		g_bTimer4[client] = INVALID_HANDLE;
	}
	
	if (g_bTimer5[client] != INVALID_HANDLE )
	{
		g_bTimer5[client] = INVALID_HANDLE;
	}
}

public void OnClientDisconnect_Post(int client)
{
	g_ClientOS[client] = OS_Unknown;
}

public void OnCvarCheck(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any serial)
{
	if (!bh_enable_plugin || result == ConVarQuery_NotFound || GetClientFromSerial(serial) != client || !IsClientInGame(client))
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

public Action Timer_ConnectPost(Handle timer, int userid)
{
	if(!bh_enable_plugin || bh_mode_checker != 2)
		return Plugin_Continue;
		
	int client = GetClientOfUserId(userid);
	
	if(!IsValidClient(client))
		return Plugin_Continue;
	
	QueryClientConVar(client, "cl_allowupload", OnQueryUpload, userid);
	QueryClientConVar(client, "cl_allowdownload", OnQueryDownload, userid);
	QueryClientConVar(client, "cl_downloadfilter", OnQueryFilter, userid);
	
	return Plugin_Continue;
}

public int OnQueryFilter(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int userid)
{
	if(!bh_enable_plugin || !bg_cl_downloadfilter || !IsValidClient(client) || GetClientOfUserId(userid)!=client || !IsClientInGame(client))
	return 0;
	
	if(IsValidClient(client))
	{
		if(bg_cl_downloadfilter)
		{
			if(strcmp(cvarValue,"none",false) == 0)
			{
				if(bsm_force_method == 1)
				{
					if(bg_cl_ignorelinux)
					{
						if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
						{
							KickClient(client, " %t", "kick_cl_downloadfilter");
						}else if(gOSType == OS_Linux)
						{
							return 0;
						}
					}else
					{
						KickClient(client, " %t", "kick_cl_downloadfilter");
					}
				}else if(bsm_force_method == 2)
				{
					if(bg_cl_ignorelinux)
					{
						if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
						{
							ChangedValue4[client] = true;
							blockteam(client);
							
							if(bmessages4[client] == false)
							{
								g_bTimer4[client] = CreateTimer(1.0, Time_Disable4, client);
								bmessages4[client] = true;
							}
						}else if(gOSType == OS_Linux)
						{
							return 0;
						}
					}else
					{
						ChangedValue4[client] = true;
						blockteam(client);
						
						if(bmessages4[client] == false)
						{
							g_bTimer4[client] = CreateTimer(1.0, Time_Disable4, client);
							bmessages4[client] = true;
						}
					}
					
				}
			}else if(strcmp(cvarValue,"nosounds",false) == 0)
			{
				if(bsm_force_method == 1)
				{
					if(bg_cl_ignorelinux)
					{
						if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
						{
							KickClient(client, " %t", "kick_cl_downloadfilter");
						}else if(gOSType == OS_Linux)
						{
							return 0;
						}
					}else
					{
						KickClient(client, " %t", "kick_cl_downloadfilter");
					}
				}else if(bsm_force_method == 2)
				{
					if(bg_cl_ignorelinux)
					{
						if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
						{
							ChangedValue5[client] = true;
							blockteam(client);
							//bmessages[client] = true;
							
							if(bmessages5[client] == false)
							{
								g_bTimer5[client] = CreateTimer(1.0, Time_Disable5, client);
								bmessages5[client] = true;
							}
						}else if(gOSType == OS_Linux)
						{
							return 0;
						}
					}else
					{
						ChangedValue5[client] = true;
						blockteam(client);
						//bmessages[client] = true;
						
						if(bmessages5[client] == false)
						{
							g_bTimer5[client] = CreateTimer(1.0, Time_Disable5, client);
							bmessages5[client] = true;
						}
					}
					
				}
			}else if(strcmp(cvarValue,"all",false) == 0)
			{
				if (ChangedValue4[client] == true || ChangedValue5[client] == true)
				{
					timerchecker4[client] = false;
					timerchecker5[client] = false;
					bmessages4[client] = false;
					bmessages5[client] = false;
					if (g_bTimer4[client] != INVALID_HANDLE || g_bTimer5[client] != INVALID_HANDLE)
					{
						delete g_bTimer4[client];
						delete g_bTimer5[client];
						if(timerchecker[client] == false && timerchecker3[client] == false && timerchecker4[client] == false && timerchecker5[client] == false)
						{
							CPrintToChat(client, " %t", "chat_after_done");
							g_bTimer2[client] = CreateTimer(5.0, Time_Disable2, client);
						}
					}
				}
			}
		}
	}
	return 0;
}

public int OnQueryUpload(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int userid)
{
	if(!bh_enable_plugin || !bg_cl_allowupload || !IsValidClient(client) || GetClientOfUserId(userid)!=client || !IsClientInGame(client))
	return 0;
	
	if(IsValidClient(client))
	{
		if(bg_cl_allowupload)
		{
			if(StrEqual(cvarName, "cl_allowupload"))
			{
				int val = StringToInt(cvarValue);
				
				if(val == 0)
				{
					if(bsm_force_method == 1)
					{
						if(bg_cl_ignorelinux)
						{
							if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
							{
								KickClient(client, " %t", "kick_cl_allowupload");
							}else if(gOSType == OS_Linux)
							{
								return 0;
							}
						}else
						{
							KickClient(client, " %t", "kick_cl_allowupload");
						}
					}else if(bsm_force_method == 2)
					{
						if(bg_cl_ignorelinux)
						{
							if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
							{
								ChangedValue3[client] = true;
								blockteam(client);
								
								if(bmessages3[client] == false)
								{
									g_bTimer3[client] = CreateTimer(1.0, Time_Disable3, client);
									bmessages3[client] = true;
								}
							}else if(gOSType == OS_Linux)
							{
								return 0;
							}
						}else
						{
							ChangedValue3[client] = true;
							blockteam(client);
							
							if(bmessages3[client] == false)
							{
								g_bTimer3[client] = CreateTimer(1.0, Time_Disable3, client);
								bmessages3[client] = true;
							}
						}
						
					}
				}else if(val == 1)
				{
					if (ChangedValue3[client] == true)
					{
						timerchecker3[client] = false;
						bmessages3[client] = false;
						if (g_bTimer3[client] != INVALID_HANDLE)
						{
							delete g_bTimer3[client];
							if(timerchecker[client] == false && timerchecker3[client] == false && timerchecker4[client] == false && timerchecker5[client] == false)
							{
								CPrintToChat(client, " %t", "chat_after_done");
								g_bTimer2[client] = CreateTimer(5.0, Time_Disable2, client);
							}
						}
					}
					
				}
			}
		}
	}
	return 0;
}

public int OnQueryDownload(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, int userid)
{
	if(!bh_enable_plugin || !bg_cl_allowdownload || !IsValidClient(client) || GetClientOfUserId(userid)!=client || !IsClientInGame(client))
	return 0;
	
	if(IsValidClient(client))
	{
		if(bg_cl_allowdownload)
		{
			if(StrEqual(cvarName, "cl_allowdownload"))
			{
				int val = StringToInt(cvarValue);
				
				if(val == 0)
				{
					if(bsm_force_method == 1)
					{
						if(bg_cl_ignorelinux)
						{
							if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
							{
								KickClient(client, " %t", "kick_cl_allowdownload");
							}else if(gOSType == OS_Linux)
							{
								return 0;
							}
						}else
						{
							KickClient(client, " %t", "kick_cl_allowdownload");
						}
					}else if(bsm_force_method == 2)
					{
						if(bg_cl_ignorelinux)
						{
							if(gOSType == OS_Unknown || gOSType == OS_Windows || gOSType == OS_Mac)
							{
								ChangedValue1[client] = true;
								blockteam(client);
								
								if(bmessages[client] == false)
								{
									g_bTimer[client] = CreateTimer(1.0, Time_Disable, client);
									bmessages[client] = true;
								}
							}else if(gOSType == OS_Linux)
							{
								return 0;
							}
						}else
						{
							ChangedValue1[client] = true;
							blockteam(client);
							
							if(bmessages[client] == false)
							{
								g_bTimer[client] = CreateTimer(1.0, Time_Disable, client);
								bmessages[client] = true;
							}
						}
						
					}
				}else if(val == 1)
				{
					if (ChangedValue1[client] == true)
					{
						timerchecker[client] = false;
						bmessages[client] = false;
						if (g_bTimer[client] != INVALID_HANDLE)
						{
							delete g_bTimer[client];
							if(timerchecker[client] == false && timerchecker3[client] == false && timerchecker4[client] == false && timerchecker5[client] == false)
							{
								CPrintToChat(client, " %t", "chat_after_done");
								g_bTimer2[client] = CreateTimer(5.0, Time_Disable2, client);
							}
						}
					}
					
				}
			}
		}
	}
	return 0;
}

public Action Time_Disable5(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		timerchecker5[client] = true;
		CPrintToChat(client, " %t", "chat_cl_downloadfilter");
		g_bTimer5[client] = CreateTimer(bf_timer_messages, Time_Disable5, client);
	}
	return Plugin_Continue;
}

public Action Time_Disable4(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		timerchecker4[client] = true;
		CPrintToChat(client, " %t", "chat_cl_downloadfilter");
		g_bTimer4[client] = CreateTimer(bf_timer_messages, Time_Disable4, client);
	}
	return Plugin_Continue;
}

public Action Time_Disable3(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		timerchecker3[client] = true;
		CPrintToChat(client, " %t", "chat_cl_allowupload");
		g_bTimer3[client] = CreateTimer(bf_timer_messages, Time_Disable3, client);
	}
	return Plugin_Continue;
}

public Action Time_Disable(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		timerchecker[client] = true;
		CPrintToChat(client, " %t", "chat_cl_allowdownload");
		g_bTimer[client] = CreateTimer(bf_timer_messages, Time_Disable, client);
	}
	return Plugin_Continue;
}

public Action Time_Disable2(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		bmessages[client] = false;
		bmessages3[client] = false;
		bmessages4[client] = false;
		bmessages5[client] = false;
		ChangedValue1[client] = false;
		ChangedValue3[client] = false;
		ChangedValue4[client] = false;
		ChangedValue5[client] = false;
		ClientCommand(client, "disconnect;retry");
	}
	return Plugin_Continue;
}

void blockteam( int client)
{
	if(!bh_enable_plugin || !IsValidClient(client) || timerchecker[client] == false && timerchecker3[client] == false && timerchecker4[client] == false && timerchecker5[client] == false)return;
	
	if(IsValidClient(client))
	{
		ChangeClientTeam(client, 1);
	}
}

void CheckQuery(int userid)
{
	int client = GetClientOfUserId(userid);
	
	if(!IsValidClient(client))
	return;
	
	QueryClientConVar(client, "cl_allowupload", OnQueryUpload, userid);
	QueryClientConVar(client, "cl_allowdownload", OnQueryDownload, userid);
	QueryClientConVar(client, "cl_downloadfilter", OnQueryFilter, userid);
}

public Action ForceTeam(int client, const char[] command, int args)
{
	if(!bh_enable_plugin || bh_mode_checker != 1)
	return Plugin_Continue;
	
	int userid = GetClientUserId(client);
	
	CheckQuery(userid);
	
	return Plugin_Continue; 
}

static bool IsValidClient( int client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client)) 
        return false; 
     
    return true; 
}