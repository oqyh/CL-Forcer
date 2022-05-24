ConVar g_cl_allowdownload;
ConVar g_cl_allowupload;
ConVar g_cl_downloadfilter;

public Plugin myinfo = 
{
	name = "[ANY] CL_Forcer", 
	author = "Gold_KingZ", 
	description = "Force Client To Download-Table", 
	version = "1.0.0", 
	url = "https://github.com/oqyh"
};

public void OnPluginStart()
{
	LoadTranslations( "CL_Forcer.phrases" );
	
	g_cl_allowdownload = CreateConVar("sm_cl_allowdownload", "1", "Only People With cl_allowdownload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_allowupload = CreateConVar("sm_cl_allowupload", "1", "Only People With cl_allowupload 1 Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	g_cl_downloadfilter = CreateConVar("sm_cl_downloadfilter", "1", "Only People With cl_downloadfilter all Enter The Server || 1= Yes || 0= No", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "CL_Forcer");

}

public OnClientPutInServer(client) 
{ 
    QueryClientConVar(client, "cl_allowdownload", GetClientDl, client);
	QueryClientConVar(client, "cl_allowupload", GetClientUp, client);
	QueryClientConVar(client, "cl_downloadfilter", GetClientFilter, client);
} 

public GetClientDl(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[]) 
{ 
	if (GetConVarBool(g_cl_allowdownload))
	{
		if(strcmp(cvarValue, "1")) KickClient(client, "%t", "kick_cl_allowdownload");
	}
}

public GetClientUp(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[]) 
{ 
	if (GetConVarBool(g_cl_allowupload))
	{
		if(strcmp(cvarValue, "1")) KickClient(client, "%t", "kick_cl_allowupload");
	}
}

public GetClientFilter(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[]) 
{ 
	if (GetConVarBool(g_cl_downloadfilter))
	{
		if(strcmp(cvarValue, "all")) KickClient(client, "%t", "kick_cl_downloadfilter");
	}
}