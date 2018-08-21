#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define REQUIRE_EXTENSIONS
#include <clientprefs>
#define REQUIRE_EXTENSIONS

#define REQUIRE_PLUGIN
#include <LMCCore>
#include <LMCL4D2CDeathHandler>
#include <LMCL4D2SetTransmit>
#undef REQUIRE_PLUGIN

#pragma newdecls required


#define PLUGIN_NAME "LMC_L4D2_Menu_Choosing"
#define PLUGIN_VERSION "1.0"

//change me to whatever flag you want
#define COMMAND_ACCESS ADMFLAG_CHAT

#define HUMAN_MODEL_PATH_SIZE 11
#define SPECIAL_MODEL_PATH_SIZE 8
#define UNCOMMON_MODEL_PATH_SIZE 6
#define COMMON_MODEL_PATH_SIZE 34


enum ZOMBIECLASS
{
	ZOMBIECLASS_SMOKER = 1,
	ZOMBIECLASS_BOOMER,
	ZOMBIECLASS_HUNTER,
	ZOMBIECLASS_SPITTER,
	ZOMBIECLASS_JOCKEY,
	ZOMBIECLASS_CHARGER,
	ZOMBIECLASS_UNKNOWN,
	ZOMBIECLASS_TANK,
}

enum LMCModelSectionType
{
	LMCModelSectionType_Human = 0,
	LMCModelSectionType_Special,
	LMCModelSectionType_UnCommon,
	LMCModelSectionType_Common
};

static const char sHumanPaths[HUMAN_MODEL_PATH_SIZE][] =
{
	"models/survivors/survivor_gambler.mdl",
	"models/survivors/survivor_producer.mdl",
	"models/survivors/survivor_coach.mdl",
	"models/survivors/survivor_mechanic.mdl",
	"models/survivors/survivor_namvet.mdl",
	"models/survivors/survivor_teenangst.mdl",
	"models/survivors/survivor_teenangst_light.mdl",
	"models/survivors/survivor_biker.mdl",
	"models/survivors/survivor_biker_light.mdl",
	"models/survivors/survivor_manager.mdl",
	"models/npcs/rescue_pilot_01.mdl"
};

enum LMCHumanModelType
{
	LMCHumanModelType_Nick = 0,
	LMCHumanModelType_Rochelle,
	LMCHumanModelType_Coach,
	LMCHumanModelType_Ellis,
	LMCHumanModelType_Bill,
	LMCHumanModelType_Zoey,
	LMCHumanModelType_ZoeyLight,
	LMCHumanModelType_Francis,
	LMCHumanModelType_FrancisLight,
	LMCHumanModelType_Louis,
	LMCHumanModelType_Pilot
};

static const char sSpecialPaths[SPECIAL_MODEL_PATH_SIZE][] =
{
	"models/infected/witch.mdl",
	"models/infected/witch_bride.mdl",
	"models/infected/boomer.mdl",
	"models/infected/boomette.mdl",
	"models/infected/hunter.mdl",
	"models/infected/smoker.mdl",
	"models/infected/hulk.mdl",
	"models/infected/hulk_dlc3.mdl"
};

enum LMCSpecialModelType
{
	LMCSpecialModelType_Witch = 0,
	LMCSpecialModelType_WitchBride,
	LMCSpecialModelType_Boomer,
	LMCSpecialModelType_Boomette,
	LMCSpecialModelType_Hunter,
	LMCSpecialModelType_Smoker,
	LMCSpecialModelType_Tank,
	LMCSpecialModelType_TankDLC3
};

static const char sUnCommonPaths[UNCOMMON_MODEL_PATH_SIZE][] =
{
	"models/infected/common_male_riot.mdl",
	"models/infected/common_male_mud.mdl",
	"models/infected/common_male_ceda.mdl",
	"models/infected/common_male_clown.mdl",
	"models/infected/common_male_jimmy.mdl",
	"models/infected/common_male_fallen_survivor.mdl"
};

enum LMCUnCommonModelType
{
	LMCUnCommonModelType_RiotCop = 0,
	LMCUnCommonModelType_MudMan,
	LMCUnCommonModelType_Ceda,
	LMCUnCommonModelType_Clown,
	LMCUnCommonModelType_Jimmy,
	LMCUnCommonModelType_Fallen
};

static const char sCommonPaths[COMMON_MODEL_PATH_SIZE][] =
{
	"models/infected/common_male_tshirt_cargos.mdl",
	"models/infected/common_male_tankTop_jeans.mdl",
	"models/infected/common_male_dressShirt_jeans.mdl",
	"models/infected/common_female_tankTop_jeans.mdl",
	"models/infected/common_female_tshirt_skirt.mdl",
	"models/infected/common_male_roadcrew.mdl",
	"models/infected/common_male_tankTop_overalls.mdl",
	"models/infected/common_male_tankTop_jeans_rain.mdl",
	"models/infected/common_female_tankTop_jeans_rain.mdl",
	"models/infected/common_male_roadcrew_rain.mdl",
	"models/infected/common_male_tshirt_cargos_swamp.mdl",
	"models/infected/common_male_tankTop_overalls_swamp.mdl",
	"models/infected/common_female_tshirt_skirt_swamp.mdl",
	"models/infected/common_male_formal.mdl",
	"models/infected/common_female_formal.mdl",
	"models/infected/common_military_male01.mdl",
	"models/infected/common_police_male01.mdl",
	"models/infected/common_male_baggagehandler_01.mdl",
	"models/infected/common_tsaagent_male01.mdl",
	"models/infected/common_shadertest.mdl",
	"models/infected/common_female_nurse01.mdl",
	"models/infected/common_surgeon_male01.mdl",
	"models/infected/common_worker_male01.mdl",
	"models/infected/common_morph_test.mdl",
	"models/infected/common_male_biker.mdl",
	"models/infected/common_female01.mdl",
	"models/infected/common_male01.mdl",
	"models/infected/common_male_suit.mdl",
	"models/infected/common_patient_male01_l4d2.mdl",
	"models/infected/common_male_polo_jeans.mdl",
	"models/infected/common_female_rural01.mdl",
	"models/infected/common_male_rural01.mdl",
	"models/infected/common_male_pilot.mdl",
	"models/infected/common_test.mdl"
};

#define CvarIndexes 6
static const char sSharedCvarNames[CvarIndexes][] =
{
	"lmc_allowtank",
	"lmc_allowhunter",
	"lmc_allowsmoker",
	"lmc_allowboomer",
	"lmc_allowSurvivors",
	"lmc_allow_tank_model_use"
};

static const char sJoinSound[] = {"ui/menu_countdown.wav"};

static Handle hCvar_ArrayIndex[CvarIndexes] = {INVALID_HANDLE, ...};

static bool g_bAllowTank = false;
static bool g_bAllowHunter = true;
static bool g_bAllowSmoker = true;
static bool g_bAllowBoomer = true;
static bool g_bAllowSurvivors = true;
static bool g_bTankModel = false;

static Handle hCookie_LmcCookie = INVALID_HANDLE;

static Handle hCvar_AnnounceDelay = INVALID_HANDLE;
static Handle hCvar_AnnounceMode = INVALID_HANDLE;
static Handle hCvar_AdminOnlyModel = INVALID_HANDLE;
static float g_fAnnounceDelay = 15.0;
static int g_iAnnounceMode = 1;
static bool g_bAdminOnly = false;

static int iSavedModel[MAXPLAYERS+1] = {0, ...};
static bool bAutoApplyMsg[MAXPLAYERS+1];
static bool bAutoBlockedMsg[MAXPLAYERS+1][9];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Lux",
	description = "Allows humans to choose LMC model with cookiesaving",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};

public void OnPluginStart()
{
	CreateConVar("lmc_sharedcvars_version", PLUGIN_VERSION, "LMC_SharedCvars_Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	hCvar_AdminOnlyModel = CreateConVar("lmc_adminonly", "0", "Allow admins to only change models? (1 = true) NOTE: this will disable announcement to player who join.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_AnnounceDelay = CreateConVar("lmc_announcedelay", "15.0", "Delay On which a message is displayed for !lmc command", FCVAR_NOTIFY, true, 1.0, true, 360.0);
	hCvar_AnnounceMode = CreateConVar("lmc_announcemode", "1", "Display Mode for !lmc command (0 = off, 1 = Print to chat, 2 = Center text, 3 = Director Hint)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	HookConVarChange(hCvar_AdminOnlyModel, eConvarChanged);
	HookConVarChange(hCvar_AnnounceDelay, eConvarChanged);
	HookConVarChange(hCvar_AnnounceMode, eConvarChanged);
	AutoExecConfig(true, "LMC_Menu_Choosing");
	CvarsChanged();
	
	hCookie_LmcCookie = RegClientCookie("lmc_cookie", "", CookieAccess_Protected);
	RegConsoleCmd("sm_lmc", ShowMenu, "Brings up a menu to select a client's model");
	
	HookEvent("player_spawn", ePlayerSpawn);
}

public void eConvarChanged(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	CvarsChanged();
}

void CvarsChanged()
{
	if(hCvar_ArrayIndex[0] != INVALID_HANDLE)
		g_bAllowTank = GetConVarInt(hCvar_ArrayIndex[0]) > 0;
	if(hCvar_ArrayIndex[1] != INVALID_HANDLE)
		g_bAllowHunter = GetConVarInt(hCvar_ArrayIndex[1]) > 0;
	if(hCvar_ArrayIndex[2] != INVALID_HANDLE)
		g_bAllowSmoker = GetConVarInt(hCvar_ArrayIndex[2]) > 0;
	if(hCvar_ArrayIndex[3] != INVALID_HANDLE)
		g_bAllowBoomer = GetConVarInt(hCvar_ArrayIndex[3]) > 0;
	if(hCvar_ArrayIndex[4] != INVALID_HANDLE)
		g_bAllowSurvivors = GetConVarInt(hCvar_ArrayIndex[4]) > 0;
	if(hCvar_ArrayIndex[5] != INVALID_HANDLE)
		g_bTankModel = GetConVarInt(hCvar_ArrayIndex[5]) > 0;
	
	g_bAdminOnly = GetConVarInt(hCvar_AdminOnlyModel) > 0;
	g_fAnnounceDelay = GetConVarFloat(hCvar_AnnounceDelay);
	g_iAnnounceMode = GetConVarInt(hCvar_AnnounceMode);
}

void HookCvars()
{
	for(int i = 0; i < CvarIndexes; i++)
	{
		if(hCvar_ArrayIndex[i] != INVALID_HANDLE)
			continue;
		
		if((hCvar_ArrayIndex[i] = FindConVar(sSharedCvarNames[i])) == INVALID_HANDLE)
		{
			PrintToServer("[LMC]Unable to find shared cvar \"%s\" using fallback value plugin:(%s)", sSharedCvarNames[i], PLUGIN_NAME);
			continue;
		}
		HookConVarChange(hCvar_ArrayIndex[i], eConvarChanged);
	}
}

public void OnMapStart()
{
	int i;
	for(i = 0; i < HUMAN_MODEL_PATH_SIZE; i++)
		PrecacheModel(sHumanPaths[i], true);
	
	for(i = 0; i < SPECIAL_MODEL_PATH_SIZE; i++)
		PrecacheModel(sSpecialPaths[i], true);
	
	for(i = 0; i < UNCOMMON_MODEL_PATH_SIZE; i++)
		PrecacheModel(sUnCommonPaths[i], true);
	
	for(i = 0; i < COMMON_MODEL_PATH_SIZE; i++)
		PrecacheModel(sCommonPaths[i], true);
	
	PrecacheSound(sJoinSound, true);
	
	HookCvars();
	CvarsChanged();
}


public void ePlayerSpawn(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	if(!IsClientInGame(iClient) || IsFakeClient(iClient) || !IsPlayerAlive(iClient))
		return;
		
	LMC_ResetRenderMode(iClient);
	
	if(g_bAdminOnly && !CheckCommandAccess(iClient, "", COMMAND_ACCESS, true))
			return;
	
	switch(GetClientTeam(iClient))
	{
		case 3:
		{
			switch(GetEntProp(iClient, Prop_Send, "m_zombieClass"))//1.4
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
						return;
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
						return;
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
						return;
				}
				case ZOMBIECLASS_CHARGER, ZOMBIECLASS_JOCKEY, ZOMBIECLASS_SPITTER, ZOMBIECLASS_UNKNOWN:
				{
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
						return;
				}
				default:
				{
					return;
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
				return;
		}
		default:
		{
			return;
		}
	}
	
		
	if(iSavedModel[iClient] < 2)
		return;
		
	RequestFrame(NextFrame, GetClientUserId(iClient));
}

public void NextFrame(int iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if(iClient < 1 || !IsClientInGame(iClient))
		return;
	
	ModelIndex(iClient, iSavedModel[iClient], false);
}



/*borrowed some code from csm*/
public Action ShowMenu(int iClient, int iArgs)
{
	if(iClient == 0)
	{
		ReplyToCommand(iClient, "[LMC] Menu is in-game only.");
		return Plugin_Continue;
	}
	if(g_bAdminOnly && !CheckCommandAccess(iClient, "", COMMAND_ACCESS, true))
	{
		ReplyToCommand(iClient, "\x04[LMC] \x03Model Changer is only available to admins.");
		return Plugin_Continue;
	}
	if(!IsPlayerAlive(iClient) && bAutoBlockedMsg[iClient][8])
	{
		ReplyToCommand(iClient, "\x04[LMC] \x03Pick a Model to be Applied NextSpawn");
		bAutoBlockedMsg[iClient][8] = false;
	}
	Handle hMenu = CreateMenu(CharMenu);
	SetMenuTitle(hMenu, "Choose a Model");//1.4
	
	AddMenuItem(hMenu, "1", "Normal Models");
	AddMenuItem(hMenu, "2", "Random Common");
	AddMenuItem(hMenu, "3", "Witch");
	AddMenuItem(hMenu, "4", "Witch Bride");
	AddMenuItem(hMenu, "5", "Boomer");
	AddMenuItem(hMenu, "6", "Boomette");
	AddMenuItem(hMenu, "7", "Hunter");
	AddMenuItem(hMenu, "8", "Smoker");
	AddMenuItem(hMenu, "9", "Riot Cop");
	AddMenuItem(hMenu, "10", "MudMan");
	AddMenuItem(hMenu, "11", "Chopper Pilot");
	AddMenuItem(hMenu, "12", "CEDA");
	AddMenuItem(hMenu, "13", "Clown");
	AddMenuItem(hMenu, "14", "Jimmy Gibs");
	AddMenuItem(hMenu, "15", "Fallen Survivor");
	AddMenuItem(hMenu, "16", "Nick");
	AddMenuItem(hMenu, "17", "Rochelle");
	AddMenuItem(hMenu, "18", "Coach");
	AddMenuItem(hMenu, "19", "Ellis");
	AddMenuItem(hMenu, "20", "Bill");
	AddMenuItem(hMenu, "21", "Zoey");
	AddMenuItem(hMenu, "22", "Francis");
	AddMenuItem(hMenu, "23", "Louis");
	
	if(g_bTankModel)
	{
		AddMenuItem(hMenu, "24", "Tank");
		AddMenuItem(hMenu, "25", "Tank DLC");
	}
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, iClient, 15);
	return Plugin_Continue;
}

public int CharMenu(Handle hMenu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[4];
			GetMenuItem(hMenu, param2, sItem, sizeof(sItem));
			ModelIndex(param1, StringToInt(sItem), true);
			ShowMenu(param1, 0);
		}
		case MenuAction_Cancel:
		{
			
		}
		case MenuAction_End:
		{
			CloseHandle(hMenu);
		}
	}
}

void ModelIndex(int iClient, int iCaseNum, bool bUsingMenu=false)
{
	if(AreClientCookiesCached(iClient) && bUsingMenu)
	{
		char sCookie[3];
		IntToString(iCaseNum, sCookie, sizeof(sCookie));
		SetClientCookie(iClient, hCookie_LmcCookie, sCookie);
	}
	iSavedModel[iClient] = iCaseNum;
	
	if(!IsPlayerAlive(iClient))
		return;
	
	switch(GetClientTeam(iClient))
	{
		case 3:
		{
			switch(GetEntProp(iClient, Prop_Send, "m_zombieClass"))
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][0])
							return;
						
						PrintToChat(iClient, "\x04[LMC] \x03Server Has Disabled Models for \x04Smoker");
						bAutoBlockedMsg[iClient][0] = false;
						return;
					}
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][1])
							return;
						
						PrintToChat(iClient, "\x04[LMC] \x03Server Has Disabled Models for \x04Boomer");
						bAutoBlockedMsg[iClient][1] = false;
						return;
					}
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][2])
							return;
						
						PrintToChat(iClient, "\x04[LMC] \x03Server Has Disabled Models for \x04Hunter");
						bAutoBlockedMsg[iClient][2] = false;
						return;
					}
				}
				case ZOMBIECLASS_SPITTER:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[iClient][3])
						return;
					
					PrintToChat(iClient, "\x04[LMC] \x03Models Don't Work for \x04Spitter");
					bAutoBlockedMsg[iClient][3] = false;
					return;
				}
				case ZOMBIECLASS_JOCKEY:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[iClient][4])
						return;
					
					PrintToChat(iClient, "\x04[LMC] \x03Models Don't Work for \x04Jockey");
					bAutoBlockedMsg[iClient][4] = false;
					return;
				}
				case ZOMBIECLASS_CHARGER:
				{
					if(IsFakeClient(iClient))
						return;
					
					if(!bUsingMenu && !bAutoBlockedMsg[iClient][5])
						return;
					
					PrintToChat(iClient, "\x04[LMC] \x03Models Don't Work for \x04Charger");
					bAutoBlockedMsg[iClient][5] = false;
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][6])
							return;
						
						PrintToChat(iClient, "\x04[LMC] \x03Server Has Disabled Models for \x04Tank");
						bAutoBlockedMsg[iClient][6] = false;
						return;
					}
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
			{
				if(!bUsingMenu && !bAutoBlockedMsg[iClient][7])
					return;
				
				PrintToChat(iClient, "\x04[LMC] \x03Server Has Disabled Models for \x04Survivors");
				bAutoBlockedMsg[iClient][7] = false;
				return;
			}
		}
	}
	
	//model selection	
	switch(iCaseNum)
	{
		case 1: 
		{
			ResetDefaultModel(iClient);
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Models will be default");
			bAutoApplyMsg[iClient] = false;
			return;
		}
		case 2:
		{
			static int iChoice = 0;//+1 each time any player picks a common infected
			if(!CheckForSameModel(iClient, LMCModelSectionType_Common, iChoice))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sCommonPaths[iChoice]));
			
			if(++iChoice >= COMMON_MODEL_PATH_SIZE)
				iChoice = 0;
				
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Common Infected");
			bAutoApplyMsg[iClient] = false;
		}
		case 3: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Witch)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Witch]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Witch");
			bAutoApplyMsg[iClient] = false;
		}
		case 4: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_WitchBride)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_WitchBride]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Witch Bride");
			bAutoApplyMsg[iClient] = false;
		}
		case 5: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Boomer)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Boomer]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Boomer");
			bAutoApplyMsg[iClient] = false;
		}
		case 6: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Boomette)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Boomette]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Boomette");
			bAutoApplyMsg[iClient] = false;
		}
		case 7: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Hunter)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Hunter]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Hunter");
			bAutoApplyMsg[iClient] = false;
		}
		case 8: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Smoker)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Smoker]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Smoker");
			bAutoApplyMsg[iClient] = false;
		}
		case 9: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_RiotCop)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_RiotCop]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04RiotCop");
			bAutoApplyMsg[iClient] = false;
		}
		case 10: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_MudMan)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_MudMan]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04MudMen");
			bAutoApplyMsg[iClient] = false;
		}
		case 11: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Pilot)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Pilot]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Chopper Pilot");
			bAutoApplyMsg[iClient] = false;
		}
		case 12: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Ceda)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Ceda]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04CEDA Suit");
			bAutoApplyMsg[iClient] = false;
		}
		case 13: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Clown)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Clown]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Clown");
			bAutoApplyMsg[iClient] = false;
		}
		case 14: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Jimmy)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Jimmy]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Jimmy Gibs");
			bAutoApplyMsg[iClient] = false;
		}
		case 15: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Fallen)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Fallen]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Fallen Survivor");
			bAutoApplyMsg[iClient] = false;
		}

		case 16: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Nick)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Nick]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Nick");
			bAutoApplyMsg[iClient] = false;
		}
		case 17: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Rochelle)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Rochelle]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Rochelle");
			bAutoApplyMsg[iClient] = false;
		}
		case 18: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Coach)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Coach]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Coach");
			bAutoApplyMsg[iClient] = false;
		}
		case 19: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Ellis)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Ellis]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Ellis");
			bAutoApplyMsg[iClient] = false;
		}
		case 20: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Bill)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Bill]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Bill");
			bAutoApplyMsg[iClient] = false;
		}
		case 21: 
		{
			if(GetRandomInt(1, 100) >= 50)
			{
				if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Zoey)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Zoey]));
			}
			else
			{
				if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_ZoeyLight)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_ZoeyLight]));
			}
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Zoey");
			bAutoApplyMsg[iClient] = false;
		}
		case 22: 
		{
			if(GetRandomInt(1, 100) >= 50)
			{
				if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Francis)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Francis]));
			}
			else
			{
				if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_FrancisLight)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_FrancisLight]));
			}
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Francis");
			bAutoApplyMsg[iClient] = false;
		}
		case 23: 
		{
			if(!CheckForSameModel(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Louis)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Louis]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Louis");
			bAutoApplyMsg[iClient] = false;
		}
		case 24:
		{
			if(!g_bTankModel)
				return;
			
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Tank)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Tank]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Tank");
			bAutoApplyMsg[iClient] = false;
		}
		case 25:
		{
			if(!g_bTankModel)
				return;
			
			if(!CheckForSameModel(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_TankDLC3)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_TankDLC3]));
			
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			
			PrintToChat(iClient, "\x04[LMC] \x03Model is \x04Tank DLC");
			bAutoApplyMsg[iClient] = false;
		}
	}
	bAutoApplyMsg[iClient] = false;
}

public void OnClientPostAdminCheck(int iClient)
{
	if(IsFakeClient(iClient))
		return;
	
	if(g_iAnnounceMode != 0 && !g_bAdminOnly)
		CreateTimer(g_fAnnounceDelay, iClientInfo, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
}

public Action iClientInfo(Handle hTimer, any iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient))
		return Plugin_Stop;
	
	switch(g_iAnnounceMode)
	{
		case 1:
		{
			PrintToChat(iClient, "\x04[LMC] \x03To Change Model use chat Command \x04!lmc\x03");
			EmitSoundToClient(iClient, sJoinSound, SOUND_FROM_PLAYER, SNDCHAN_STATIC);
		}
		case 2: PrintHintText(iClient, "[LMC] To Change Model use chat Command !lmc");
		case 3:
		{
			int iEntity = CreateEntityByName("env_instructor_hint");
			
			char sValues[64];
			
			FormatEx(sValues, sizeof(sValues), "hint%d", iClient);
			DispatchKeyValue(iClient, "targetname", sValues);
			DispatchKeyValue(iEntity, "hint_target", sValues);
			
			Format(sValues, sizeof(sValues), "10");
			DispatchKeyValue(iEntity, "hint_timeout", sValues);
			DispatchKeyValue(iEntity, "hint_range", "100");
			DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_tip");
			DispatchKeyValue(iEntity, "hint_caption", "[LMC] To Change Model use chat Command !lmc");
			Format(sValues, sizeof(sValues), "%i %i %i", GetRandomInt(1, 255), GetRandomInt(100, 255), GetRandomInt(1, 255));
			DispatchKeyValue(iEntity, "hint_color", sValues);
			DispatchSpawn(iEntity);
			AcceptEntityInput(iEntity, "ShowHint", iClient);
			
			SetVariantString("OnUser1 !self:Kill::6:1");
			AcceptEntityInput(iEntity, "AddOutput");
			AcceptEntityInput(iEntity, "FireUser1");
		}
	}
	return Plugin_Stop;
}

bool CheckForSameModel(int iClient, LMCModelSectionType iModelSectionType, int iModelIndex)
{
	char sCurrentModel[PLATFORM_MAX_PATH];
	GetClientModel(iClient, sCurrentModel, sizeof(sCurrentModel));
	
	switch(iModelSectionType)
	{
		case LMCModelSectionType_Human:
		{
			if(!StrEqual(sCurrentModel, sHumanPaths[iModelIndex], false))
				return false;
			
			ResetDefaultModel(iClient);
			return true;
		}
		case LMCModelSectionType_Special:
		{
			if(!StrEqual(sCurrentModel, sSpecialPaths[iModelIndex], false))
				return false;
			
			ResetDefaultModel(iClient);
			return true;
		}
		case LMCModelSectionType_UnCommon:
		{
			if(!StrEqual(sCurrentModel, sUnCommonPaths[iModelIndex], false))
				return false;
			
			ResetDefaultModel(iClient);
			return true;
		}
		case LMCModelSectionType_Common:
		{
			if(!StrEqual(sCurrentModel, sCommonPaths[iModelIndex], false))
				return false;
			
			ResetDefaultModel(iClient);
			return true;
		}
	}
	ResetDefaultModel(iClient);
	return true;
	
}

void ResetDefaultModel(int iClient)
{
	int iOverlayModel = LMC_GetClientOverlayModel(iClient);
	if(iOverlayModel > -1)
		AcceptEntityInput(iOverlayModel, "kill");
	
	LMC_ResetRenderMode(iClient);
}

public void OnClientDisconnect(int iClient)
{
	//1.3
	if(AreClientCookiesCached(iClient))
	{
		char sCookie[3];
		IntToString(iSavedModel[iClient], sCookie, sizeof(sCookie));
		SetClientCookie(iClient, hCookie_LmcCookie, sCookie);
	}
	bAutoApplyMsg[iClient] = true;//1.4
	for(int i = 0; i < sizeof(bAutoBlockedMsg[]); i++)//1.4
		bAutoBlockedMsg[iClient][i] = true;
	
	iSavedModel[iClient] = 0;
}

public void OnClientCookiesCached(int iClient)
{	
	char sCookie[3];
	GetClientCookie(iClient, hCookie_LmcCookie, sCookie, sizeof(sCookie));
	if(StrEqual(sCookie, "\0", false))
		return;
	
	iSavedModel[iClient] = StringToInt(sCookie);
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
	
	if(g_bAdminOnly && !CheckCommandAccess(iClient, "", COMMAND_ACCESS, true))
			return;
	
	ModelIndex(iClient, iSavedModel[iClient], false);
}

public void LMC_OnClientModelApplied(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach)
{
	if(bBaseReattach)//if true because orignal overlay model has been killed
		LMC_L4D2_SetTransmit(iClient, iEntity);
}
