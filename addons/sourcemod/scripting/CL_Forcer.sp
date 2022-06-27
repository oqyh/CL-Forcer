#include <sourcemod>
#include <sdktools>
#include <multicolors>

int g_Type = 2;

ConVar g_cl_allowdownload;
ConVar g_cl_allowupload;
ConVar g_cl_downloadfilter;

public Plugin myinfo = 
{
	name = "[ANY] CL_Forcer", 
	author = "Gold_KingZ", 
	description = "Force Client To Download-Table", 
	version = "1.0.1", 
	url = "https://github.com/oqyh"
};

public void OnPluginStart(){
	LoadTranslations( "CL_Forcer.phrases" );
	
	new Handle:sm_force_method = CreateConVar("sm_force_method", "2", "Choose What To Do With Them || 1= Kick Them From The Server || 2= Send Them To Spec" );
	g_cl_allowdownload = CreateConVar("sm_cl_allowdownload", "1", "Only People With cl_allowdownload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_allowupload = CreateConVar("sm_cl_allowupload", "0", "Only People With cl_allowupload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_downloadfilter = CreateConVar("sm_cl_downloadfilter", "1", "Only People With cl_downloadfilter all Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
	AddCommandListener(ForceTeam, "jointeam");
	
	HookConVarChange(sm_force_method, OnFixTypeChanged); 
   	g_Type = GetConVarInt(sm_force_method);
	
	AutoExecConfig(true, "CL_Forcer");
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
				KickClient(client, "%t", "kick_cl_allowdownload");
			}
			
			else if(g_Type == 2)
			{
				ChangeClientTeam(client, 1);
				CPrintToChat(client, "%t", "chat_cl_allowdownload");
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
				KickClient(client, "%t", "kick_cl_allowupload");
			}
			
			else if(g_Type == 2)
			{
				ChangeClientTeam(client, 1);
				CPrintToChat(client, "%t", "chat_cl_allowupload");
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
	
	if ((strcmp(cvarValue,"none",false) == 0) && (GetUserFlagBits(client) & ADMFLAG_ROOT != ADMFLAG_ROOT))
	{
	if (GetConVarBool(g_cl_downloadfilter))
	{
		if(val == 0)
		{
			if(g_Type == 1)
			{
				KickClient(client, "%t", "kick_cl_downloadfilter");
			}
			
			else if(g_Type == 2)
			{
				ChangeClientTeam(client, 1);
				CPrintToChat(client, "%t", "chat_cl_downloadfilter");
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