/*=======================================================================================================================================================
==========================================================================================================================================================



															oooooooooooo   .oooooo.
															`888'     `8  d8P'  `Y8b
															 888         888      888
															 888oooo8    888      888
															 888    "    888      888
															 888       o `88b    d88'
															o888ooooood8  `Y8bood8P'

										                     VIP SYSTEM Filterscript
										                    by Oussama .aka. Compton

												NOTE: Please note that the credits are to be kept.

============================================================================================================================================================
==========================================================================================================================================================*/

#pragma compat 1

#define FILTERSCRIPT
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

//**Colors----------------------------------------------------------------------------------------------------------------------------------
#define VIPCOLOR_WHITE 		0xFFFFFFFF
#define VIPCOLOR_RED 		0xF22222AA
#define VIPCOLOR_BLUE 		0x1C80EBAA
#define VIPCOLOR_GREEN 		0x36C936AA
#define VIPCOLOR_YELLOW 	0xF7F70FAA
#define VIPCOLOR_ORANGE 	0xF09A1AAA

#define VIPCOL_WHITE 		"{FFFFFF}"
#define VIPCOL_RED 			"{F22222}"
#define VIPCOL_BLUE 		"{1C80EB}"
#define VIPCOL_GREEN 		"{36C936}"
#define VIPCOL_YELLOW 		"{F7F70F}"
#define VIPCOL_ORANGE 		"{F09A1A}"

//**Includes---------------------------------------------------------------------------------------------------------------------------------
#include <a_samp>					// by SA_MP team
#include <a_mysql>					// by BlueG					>	github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-2
#include <streamer>					// by incognito				>	github.com/samp-incognito/samp-streamer-plugin/releases/tag/v2.9.1
#include <sscanf2>					// by Y_Less				>	github.com/maddinat0r/sscanf/releases/tag/v2.8.2
#include <iZCMD>					// by Zeex and Yashas 		>	github.com/YashasSamaga/I-ZCMD
#include <YSI\y_timers>				// by Y_Less and Misiur		>	github.com/Misiur/YSI
#include <eovip>					// by Oussama

//**MySQL Connection------------------------------------------------------------------------------------------------------------------------
#define MySQL_HOST "127.0.0.1"
#define MySQL_USER "root"
#define MySQL_PASS ""
#define MySQL_DATABASE "eo_vipdb"

//**Global Variables------------------------------------------------------------------------------------------------------------------------
new
	MySQL:g_SQL,

	gPlayerBone[18][] = {
		"Spine",
		"Head",
		"Left upper arm",
		"Right upper arm",
		"Left hand",
		"Right hand",
		"Left thigh",
		"Right thigh",
		"Left foot",
		"Right foot",
		"Right calf",
		"Left calf",
		"Left forearm",
		"Right forearm",
		"Left clavicle",
		"Right clavicle",
		"Neck",
		"Jaw"
	},

	gVIPToys[22][] = {
		"Fishing Rod",
		"Wrench",
		"Hammer",
		"Hardhat",
		"Afro",
		"Phone",
		"Briefcase",
		"Red Glasses",
		"Orange Glasses",
		"Dark Glasses",
		"Yellow Glasses",
		"Green Glasses",
		"Bass Guitar",
		"Flying Guitar",
		"Clukin Bell Hat",
		"Burger Shot Hat",
		"Zoro Mask",
		"Biker Helmet",
		"Parrot",
		"Cowboy Hat",
		"Xmax Hat",
		"Watch"
	}
;

//**DIALOGs---------------------------------------------------------------------------------------------------------------------------------
#define DIALOG_MSG 					5000
#define DIALOG_VIPBASESPAWN 		5001
#define DIALOG_VIPSKINS 			5002
#define DIALOG_VIPGPPRESETCREATE	5003
#define DIALOG_VIPGPPRESETEDIT 		5004
#define DIALOG_TOYS 				5005
#define DIALOG_TOYSINDEX			5006
#define DIALOG_TOYSLIST				5007
#define DIALOG_PRESETGUNLIST		5008
#define DIALOG_GUNLISTMELEE			5009
#define DIALOG_GUNLISTPISTOL		5010
#define DIALOG_GUNLISTSHOTGUN		5011
#define DIALOG_GUNLISTSUBMACHINE	5012
#define DIALOG_GUNLISTASSAULT		5013
#define DIALOG_GUNLISTRIFLE			5014
#define DIALOG_VIPGPPRESETDELETE	5015
#define DIALOG_TOYSMANAGE			5016

//**Forwards--------------------------------------------------------------------------------------------------------------------------------
forward OnVIPAccountCheck(playerid);
forward OnVIPExpiredCheck(playerid);

//**Functions-------------------------------------------------------------------------------------------------------------------------------
GetPlayerNameEx(playerid) 
{
    new pName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
    return pName;
}

//VIP RANDOM MSG----------------------------------------------------------------------------------------------------------------------------
new VIPTips[][] = {
	"[EO_VIP TIP]: "VIPCOL_YELLOW"Use "VIPCOL_WHITE"/vipcmds "VIPCOL_WHITE"to check few useful VIP Commands.",
	"[EO_VIP TIP]: "VIPCOL_YELLOW"Stay updated with your VIP Level information via "VIPCOL_WHITE"/viphelp .",
	"[EO_VIP TIP]: "VIPCOL_YELLOW"Check your VIP Level stats via "VIPCOL_WHITE"/vipaccount .",
	"[EO_VIP TIP]: "VIPCOL_YELLOW"Use "VIPCOL_WHITE"/vipbs "VIPCOL_WHITE"to enable/disable spawning in VIP Base."
};

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	new MySQLOpt:sqlOption = mysql_init_options();
	g_SQL = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_PASS, MySQL_DATABASE);

	if(mysql_errno(g_SQL) == 0 && g_SQL)
	{

		printf("[MySQL]: Connection to \""#MySQL_DATABASE"\" was successful!");
		mysql_set_option(sqlOption, AUTO_RECONNECT, true);
		mysql_log(ALL);

		print("\n--------------------------------------");
		print(" [EO] VIP system by Oussama .a.k.a Compton");
		print(" Filterscript version: 2.0");
		print(" Credits must be included");
		print("--------------------------------------\n");

	 	CreateVIPBase();
		CreateVIPVehicles();
	}

	else
	{
		printf("[MySQL]: Connection to \""#MySQL_DATABASE"\" failed!");
		SendRconCommand("unloadfs EOVIP");
	}

	return 1;
}

public OnFilterScriptExit()
{
	printf("[MySQL]: Connection to \""#MySQL_DATABASE"\" was terminated!");
	SendRconCommand("unloadfs EOVIP");
	mysql_close(g_SQL);

	return 1;
}

#endif

public OnPlayerConnect(playerid)
{
	new _query[71];

    SendClientMessage(playerid, -1, "[EO VIP]: "VIPCOL_YELLOW"VIP System by Eoussama");

    ResetVIPData(playerid);
    mysql_format(g_SQL, _query, sizeof(_query), "SELECT * FROM `VIPs` WHERE `Username` = '%e';", GetPlayerNameEx(playerid));
    mysql_tquery(g_SQL, _query, "OnVIPAccountCheck", "d", playerid);

	return 1;
}

public OnVIPAccountCheck(playerid)
{
	if(cache_num_rows())
	{
		new vipLevel,  _query[188];

		cache_get_value_name_int(0, "ID", VIPInfo[playerid][e_VIPID]);
		cache_get_value_name_int(0, "VIPLevel", vipLevel);
		cache_get_value_name_int(0, "SpawnInBase", VIPInfo[playerid][e_VIPBaseSpawn]);
		cache_get_value_name_int(0, "WeaponPreset", VIPInfo[playerid][e_VIPGunPackPreset]);
		cache_get_value_name_int(0, "WeaponMeleeSlot", VIPInfo[playerid][e_VIPGPMelee]);
		cache_get_value_name_int(0, "WeaponPistolSlot", VIPInfo[playerid][e_VIPGPPistol]);
		cache_get_value_name_int(0, "WeaponShotgunSlot", VIPInfo[playerid][e_VIPGPShotgun]);
		cache_get_value_name_int(0, "WeaponSubMachineSlot", VIPInfo[playerid][e_VIPGPSubMachine]);
		cache_get_value_name_int(0, "WeaponAssaultSlot", VIPInfo[playerid][e_VIPGPAssault]);
		cache_get_value_name_int(0, "WeaponRifleSlot", VIPInfo[playerid][e_VIPGPRifle]);
		setVIPLevel(playerid, vipLevel);
		VIPInfo[playerid][e_VIPGunPackCoolDown] = 0;
		VIPInfo[playerid][e_VIPBaseTeleportCoolDown] = 0;
		VIPInfo[playerid][e_VIPSelectedBone] = -1;
		VIPInfo[playerid][e_VIPFirstSpawn] = true;

		mysql_format(g_SQL, _query, sizeof(_query), "SELECT TIMESTAMPDIFF(MINUTE, NOW(), DATE_ADD(`Timestamp`, INTERVAL 30*24*60 MINUTE)) AS `minsLeft` FROM `VIPs` WHERE `ID` = %d AND `VIPLevel` > 0 LIMIT 1;", getPlayerAccID(playerid));
    	mysql_tquery(g_SQL, _query, "OnVIPExpiredCheck", "d", playerid);
	}

	else
	{
		new _query[71];

		VIPInfo[playerid][e_VIPSelectedBone] = -1;
		mysql_format(g_SQL, _query, sizeof(_query), "INSERT INTO `VIPs` (`Username`) VALUES('%e');", GetPlayerNameEx(playerid));
		mysql_tquery(g_SQL, _query);
	}
}

public OnVIPExpiredCheck(playerid)
{
	if(cache_num_rows())
	{
		new _query[278], minsLeft;

		cache_get_value_name_int(0, "minsLeft", minsLeft);

		if(minsLeft <= 0)
		{
			mysql_format(g_SQL, _query, sizeof(_query), "UPDATE `VIPs` SET `VIPLevel` = 0, `SpawnInBase` = 0, `WeaponPreset` = 0, `WeaponMeleeSlot` = 0, `WeaponPistolSlot` = 0, `WeaponShotgunSlot` = 0, `WeaponSubMachineSlot` = 0, `WeaponAssaultSlot` = 0, `WeaponRifleSlot` = 0 WHERE `Username` = '%e' LIMIT 1;", GetPlayerNameEx(playerid));
    		mysql_tquery(g_SQL, _query);
    		SendClientMessage(playerid, VIPCOLOR_RED, "[EO_VIP] Your VIP status has expired!");
		}
	}
}

public OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(VIPInfo[playerid][e_VIPTagID]);
	SaveVIPData(playerid, g_SQL);
	ResetVIPData(playerid);

	return 1;
}

public OnPlayerSpawn(playerid)
{
    new str[128];

   	if(isPlayerVIP(playerid))
   	{
   		if(VIPInfo[playerid][e_VIPFirstSpawn])
   		{
		    format(str, sizeof(str), "Welcome "VIPCOL_WHITE"%s "VIPCOL_YELLOW", your VIP level is "VIPCOL_WHITE"%i "VIPCOL_YELLOW"|| account type: "VIPCOL_WHITE"%s", GetPlayerNameEx(playerid), getVIPLevel(playerid), getVIPName(playerid));
		    SendClientMessage(playerid, VIPCOLOR_YELLOW, str);
    		SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Use "VIPCOL_WHITE"/vipcmds "VIPCOL_YELLOW"to display a useful collection of VIP commands, for information help use "VIPCOL_WHITE"/viphelp");
			VIPInfo[playerid][e_VIPFirstSpawn] = false;
		}
	
		switch(getVIPLevel(playerid))
		{
			case EOVIP_VIPLEVEL_3:
			{
				SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Your Armour has been set to "VIPCOL_WHITE"40%%");
		    	SetPlayerArmour(playerid, 40);
			}

			case EOVIP_VIPLEVEL_4:
			{
				SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Your Armour has been set to "VIPCOL_WHITE"80%%");
		    	SetPlayerArmour(playerid, 80);
			}
		}
	}

	if(VIPInfo[playerid][e_VIPBaseSpawn])
	{
	    SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have spawned at VIP Base, you can change this option via "VIPCOL_WHITE"/vipbs");
	    TogglePlayerControllable(playerid, false);
	    SetPlayerPos(playerid, 3049.6392,-668.2963,2.8086);
		defer VIPBaseTeleportTimer(playerid);
	}
	
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    new vehID = GetPlayerVehicleID(playerid);

	if(newstate == PLAYER_STATE_DRIVER && isVIPVehicle(vehID))
	{
 		if(isPlayerVIP(playerid))
	        SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Welcome to the VIP Vehicle");

	    else
	    {
	    	RemovePlayerFromVehicle(playerid);
	    	SendClientMessage(playerid, VIPCOLOR_RED, "[EO_VIP]: You cannot drive a VIP vehicle!");
	    }
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_NO))
	{
		new Float:posX, Float:posY, Float:posZ, message[96];

		GetPlayerPos(playerid, posX, posY, posZ);

		if(IsPlayerInRangeOfPoint(playerid, 4, 3002.3396, -683.2094, 1.9951) && isPlayerVIP(playerid))
		{
			if(!isVIPGateOpened())
			{
				if(IsDynamicObjectMoving(VIPGate[e_Gate1]) || IsDynamicObjectMoving(VIPGate[e_Gate2])) return SendClientMessage(playerid, VIPCOLOR_RED, "[EO_VIP]: Wait for the gate to fully close!");
				
				ToggleVIPGates(true);
				SendClientMessage(playerid, VIPCOLOR_GREEN, "[EO_VIP]: VIP Base gate is opening!");
			}

			else
			{
				if(IsDynamicObjectMoving(VIPGate[e_Gate1]) || IsDynamicObjectMoving(VIPGate[e_Gate2])) return SendClientMessage(playerid, VIPCOLOR_RED, "[EO_VIP]: Wait for the gate to fully open!");
				
				ToggleVIPGates(false);
				SendClientMessage(playerid, VIPCOLOR_GREEN, "[EO_VIP]: VIP Base gate is closing!");
			}
		}

		else if(IsPlayerInRangeOfPoint(playerid, 2, 3024.9241, -692.5798, 3.3770))
		{
			if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You cannot enter the lounge while being in a vehicle!");
			if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot enter this lounge!");
            
            SetPlayerInterior(playerid, 3);
            SetPlayerPos(playerid, 942.171997, -16.542755, 1000.929687);
            VIPInfo[playerid][e_IsVIPInLounge] = true;
            SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Welcome to the VIP Lounge");
            SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"press "VIPCOL_WHITE"N "VIPCOL_YELLOW"to get outside");

            format(message, sizeof(message), "[VIP Lounge]: "VIPCOL_YELLOW"VIP "VIPCOL_WHITE"%s"VIPCOL_YELLOW" has entered The VIP Lounge", GetPlayerNameEx(playerid));
			foreach(new i : VIP)
			{
				if(isPlayerVIP(i) && isVIPInLoungue(playerid))
					SendClientMessageToVIPs(message, VIPCOLOR_ORANGE, playerid);
			}
        }

        else if(IsPlayerInRangeOfPoint(playerid, 2, 942.1549,-16.8236,1000.9297))
        {
            TogglePlayerControllable(playerid, false);
			SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: You have been temporarily frozen, please wait for the environment to load!");
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, 3024.9241, -692.5798, 3.3770);
			defer VIPBaseTeleportTimer(playerid);
            VIPInfo[playerid][e_IsVIPInLounge] = false;

            format(message, sizeof(message), "[VIP Lounge]: "VIPCOL_ORANGE"VIP "VIPCOL_WHITE"%s "VIPCOL_ORANGE"has left The VIP Lounge", GetPlayerNameEx(playerid));
			foreach(new i : VIP)
			{
				if(isPlayerVIP(i) && isVIPInLoungue(playerid))
					SendClientMessageToVIPs(message, VIPCOLOR_ORANGE, playerid);
			}
        }
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_VIPSKINS:
		{
			if(!response) return 0;

			switch(listitem)
			{
				case 0: SetPlayerSkin(playerid, 2), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Maccer");
				case 1: SetPlayerSkin(playerid, 3), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Andre");
				case 2: SetPlayerSkin(playerid, 12), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Rich Woman");
				case 3: SetPlayerSkin(playerid, 0), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"CJ");
				case 4: SetPlayerSkin(playerid, 45), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Stunter");
				case 5: SetPlayerSkin(playerid, 86), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Ryder");
				case 6: SetPlayerSkin(playerid, 120), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Triad Boss");
				case 7: SetPlayerSkin(playerid, 269), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Big Smoke");
				case 8: SetPlayerSkin(playerid, 167), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Cluckin' bell worker");
				case 9: SetPlayerSkin(playerid, 192), SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have changed your skin to "VIPCOL_WHITE"Michelle");
			}
		}

		case DIALOG_VIPBASESPAWN:
		{
			if(!response) return 0;

			if(!VIPInfo[playerid][e_VIPBaseSpawn])
			{
				VIPInfo[playerid][e_VIPBaseSpawn] = true;
				SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"Your spawn position was set to the VIP Base!");
			}

			else
			{
				VIPInfo[playerid][e_VIPBaseSpawn] = false;
				SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You will not spawn on the VIP Base the next time!");
			}
		}

		case DIALOG_VIPGPPRESETCREATE:
		{
			if(!response) return 0;

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_PRESETGUNLIST:
		{
			if(!response) return SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have canceled Gunpack preset creation!");

			switch(listitem)
			{
				case 0: ShowPlayerDialog(playerid, DIALOG_GUNLISTMELEE, DIALOG_STYLE_LIST, "Weapon List - Melee", "Knife\nBaseball Bat\nNightStick\nDildo\nGolf Club\nShovel\nKatana", "Select", "Cancel");
				case 1: ShowPlayerDialog(playerid, DIALOG_GUNLISTPISTOL, DIALOG_STYLE_LIST, "Weapon List - Pistol", "9mm Pistol\nSilenced Pistol\nDeagle", "Select", "Cancel");
				case 2: ShowPlayerDialog(playerid, DIALOG_GUNLISTSHOTGUN, DIALOG_STYLE_LIST, "Weapon List - Shotgun", "Shotgun\nCombat Shotgun\nSwan-off Shotgun", "Select", "Cancel");
				case 3: ShowPlayerDialog(playerid, DIALOG_GUNLISTSUBMACHINE, DIALOG_STYLE_LIST, "Weapon List - SubMachine", "MP5\nTec-9\nMicro UZI", "Select", "Cancel");
				case 4: ShowPlayerDialog(playerid, DIALOG_GUNLISTASSAULT, DIALOG_STYLE_LIST, "Weapon List - Assault", "M4\nAK-47", "Select", "Cancel");
				case 5: ShowPlayerDialog(playerid, DIALOG_GUNLISTRIFLE, DIALOG_STYLE_LIST, "Weapon List - Rifle", "Country Rifle\nSniper Rifle", "Select", "Cancel");
				case 6:
				{
					VIPInfo[playerid][e_VIPGunPackPreset] = true;
					SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have saved your Gunpack preset, next time you use /vipgunpack you will spawn your Gunpack preset!");
				}
			}
		}

		case DIALOG_GUNLISTMELEE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPMelee] = 4, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Knife\"");
				case 1: VIPInfo[playerid][e_VIPGPMelee] = 5, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Baseball Bat\"");
				case 2: VIPInfo[playerid][e_VIPGPMelee] = 3, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"NightStick\"");
				case 3: VIPInfo[playerid][e_VIPGPMelee] = 10, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Dildo\"");
				case 4: VIPInfo[playerid][e_VIPGPMelee] = 2, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Golf Club\"");
				case 5: VIPInfo[playerid][e_VIPGPMelee] = 6, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Shovel\"");
				case 6: VIPInfo[playerid][e_VIPGPMelee] = 8, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Katana\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_GUNLISTPISTOL:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPPistol] = 22, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"9mm Pistol\"");
				case 1: VIPInfo[playerid][e_VIPGPPistol] = 23, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Silenced Pistol\"");
				case 2: VIPInfo[playerid][e_VIPGPPistol] = 24, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Deagle\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_GUNLISTSHOTGUN:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPShotgun] = 25, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Shotgun\"");
				case 1: VIPInfo[playerid][e_VIPGPShotgun] = 27, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Combat Shotgun\"");
				case 2: VIPInfo[playerid][e_VIPGPShotgun] = 26, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Swan-off Shotgun\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_GUNLISTSUBMACHINE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPSubMachine] = 29, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"MP5\"");
				case 1: VIPInfo[playerid][e_VIPGPSubMachine] = 32, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Tec-9\"");
				case 2: VIPInfo[playerid][e_VIPGPSubMachine] = 28, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Micro UZI\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_GUNLISTASSAULT:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPAssault] = 31, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"M4\"");
				case 1: VIPInfo[playerid][e_VIPGPAssault] = 30, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"AK-47\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_GUNLISTRIFLE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel"); 
			
			switch(listitem)
			{
				case 0: VIPInfo[playerid][e_VIPGPRifle] = 33, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Country Rifle\"");
				case 1: VIPInfo[playerid][e_VIPGPRifle] = 34, SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have selected \"Sniper Rifle\"");
			}

			ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
		}

		case DIALOG_VIPGPPRESETEDIT:
		{
			if(!response) return 0;

			switch(listitem)
			{
				case 0: ShowPlayerDialog(playerid, DIALOG_PRESETGUNLIST, DIALOG_STYLE_LIST, "VIP Gunpack Preset - Weapon List", "Melee\nPistol\nShotgun\nSubMachine\nAssault\nRifle\nSave Gunpack Preset", "Select", "Cancel");
				case 1: ShowPlayerDialog(playerid, DIALOG_VIPGPPRESETDELETE, DIALOG_STYLE_MSGBOX, "VIP Gunpack Preset", "Are you sure you want to delete your Gunpack preset?\n"VIPCOL_YELLOW"you can create another one anytime via "VIPCOL_WHITE"/vipgppreset", "Yes", "No");
			}
		}

		case DIALOG_VIPGPPRESETDELETE:
		{
			if(!response) return 0;

			VIPInfo[playerid][e_VIPGunPackPreset] = false;
			VIPInfo[playerid][e_VIPGPMelee] = -1;
			VIPInfo[playerid][e_VIPGPPistol] = -1;
			VIPInfo[playerid][e_VIPGPShotgun] = -1;
			VIPInfo[playerid][e_VIPGPSubMachine] = -1;
			VIPInfo[playerid][e_VIPGPAssault] = -1;
			VIPInfo[playerid][e_VIPGPRifle] = -1;

			SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP]: You have deleted your Gunpack preset!");
		}

		case DIALOG_TOYS:
		{
			if(!response) return 0;

			VIPInfo[playerid][e_VIPToysIndex] = listitem;
			if(VIPInfo[playerid][e_VIPToysSlots][listitem])
			{
				SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Please chose an option!");
				ShowPlayerDialog(playerid, DIALOG_TOYSMANAGE, DIALOG_STYLE_LIST, "VIP Attachments - Management", "Edit Toy\nDelete Toy", "Select", "Cancel");
			}

			else
			{
				new _content[500];
				for(new i; i<sizeof(gPlayerBone); i++)
			    	format(_content, sizeof(_content), "%s%s\n" ,_content, gPlayerBone[i]);

			    SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Please select a bone to stick the toy at!");
			    ShowPlayerDialog(playerid, DIALOG_TOYSINDEX, DIALOG_STYLE_LIST, "VIP Attachments - Bone Selection", _content, "Select", "Cancel");
			}
		}

		case DIALOG_TOYSINDEX:
		{
			if(!response) return 0;

			new _VIPToys[300];

			SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Please select a toy to attach!");

			for(new i; i<sizeof(gVIPToys); i++)
				format(_VIPToys, sizeof(_VIPToys), "%s%s\n", _VIPToys, gVIPToys[i]);

			switch(listitem)
			{
				case 0: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 1;
				case 1: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 2;
				case 2: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 3;
				case 3: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 4;
				case 4: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 5;
				case 5: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 6;
				case 6: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 7;
				case 7: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 8;
				case 8: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 9;
				case 9: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 10;
				case 10: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 11;
				case 11: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 12;
				case 12: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 13;
				case 13: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 14;
				case 14: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 15;
				case 15: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 16;
				case 16: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 17;
				case 17: ShowPlayerDialog(playerid, DIALOG_TOYSLIST, DIALOG_STYLE_LIST, "VIP Toys - Toy selection", _VIPToys, "Select", "Cancel"), VIPInfo[playerid][e_VIPSelectedBone] = 18;
			}
		}

		case DIALOG_TOYSLIST:
		{
			if(!response) return 0;

			switch(listitem)
			{
				case 0: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18632, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 1: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18633, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 2: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18635, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 3: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18638, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 4: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19077, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 5: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18871, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 6: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 1210, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 7: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19026, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 8: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19007, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 9: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19138, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 10: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19028, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 11: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19029, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 12: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19317, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 13: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19318, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 14: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19137, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 15: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19094, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 16: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18974, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 17: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18977, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 18: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19078, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 19: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 18962, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 20: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19066, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
				case 21: SetPlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex], 19039, VIPInfo[playerid][e_VIPSelectedBone], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
			}

			SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Use the X,Y,Z axes to move/rotate/expand the toy!");
			EditAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex]);
		}

		case DIALOG_TOYSMANAGE:
		{
			if(!response) return 0;

			switch(listitem)
			{
				case 0: EditAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex]);
				case 1: RemovePlayerAttachedObject(playerid, VIPInfo[playerid][e_VIPToysIndex]);
			}
		}
	}

	return 0;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ ){

	if(response == EDIT_RESPONSE_FINAL)
	{
		SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Toy was successfully saved!");
		VIPInfo[playerid][e_VIPToysSlots][VIPInfo[playerid][e_VIPToysIndex]] = true;
		VIPInfo[playerid][e_VIPToysIndex] = -1;
		VIPInfo[playerid][e_VIPSelectedBone] = -1;
	}

	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(IsPlayerNPC(clickedplayerid) || clickedplayerid == INVALID_PLAYER_ID) return 0;

    new _header[55];
	format(_header, sizeof(_header), ""VIPCOL_BLUE"%s"VIPCOL_WHITE"'s VIP Info", GetPlayerNameEx(clickedplayerid));

    if(isPlayerVIP(clickedplayerid))
    {
    	new _content[155], setDate[11], Cache:results;

    	mysql_format(g_SQL, _content, sizeof(_content), "SELECT DATE(`Timestamp`) AS `setDate` FROM `VIPs` WHERE `ID` = %d LIMIT 1;", getPlayerAccID(clickedplayerid));
    	results = mysql_query(g_SQL, _content);
    	cache_get_value_name(0, "setDate", setDate, 11);
    	cache_delete(results);

		format(_content, sizeof(_content), "\
			"VIPCOL_WHITE"VIP Level: "VIPCOL_YELLOW"%d\n\
			"VIPCOL_WHITE"Account Type: "VIPCOL_YELLOW"%s\n\
			"VIPCOL_WHITE"VIP status set on: "VIPCOL_YELLOW"%s", getVIPLevel(clickedplayerid), getVIPName(clickedplayerid), setDate);

		ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, _header, _content, "Close", "");
	}

	else
		ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, _header, "This player is not a VIP!", "Close", "");

	return 1;
}

//**Commands---------------------------------------------------------------------------------------------------------------------------------

//VIP Admin Commands
CMD:vipstats(playerid)
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not authorized to use this command!");
	new content[500], totalPlayers, totalVIPs, levels[4], mostRecentVIP[MAX_PLAYER_NAME], Cache:results;

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `gCount` FROM `VIPs`;");
	cache_get_value_name_int(0, "gCount", totalPlayers);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `gvCount` FROM `VIPs` WHERE `VIPLevel` > 0;");
	cache_get_value_name_int(0, "gvCount", totalVIPs);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `totalVIPs` FROM `VIPs` WHERE `VIPLevel` = 1;");
	cache_get_value_name_int(0, "totalVIPs", levels[0]);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `totalVIPs` FROM `VIPs` WHERE `VIPLevel` = 2;");
	cache_get_value_name_int(0, "totalVIPs", levels[1]);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `totalVIPs` FROM `VIPs` WHERE `VIPLevel` = 3;");
	cache_get_value_name_int(0, "totalVIPs", levels[2]);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT COUNT(`ID`) AS `totalVIPs` FROM `VIPs` WHERE `VIPLevel` = 4;");
	cache_get_value_name_int(0, "totalVIPs", levels[3]);
	cache_delete(results);

	results = mysql_query(g_SQL, "SELECT `Username` FROM `VIPs` WHERE `VIPLevel` > 0 ORDER BY `Timestamp` DESC LIMIT 1;");
	cache_get_value_name(0, "Username", mostRecentVIP, MAX_PLAYER_NAME);
	cache_delete(results);

	format(content, sizeof(content), ""VIPCOL_WHITE"There are "VIPCOL_YELLOW"%d "VIPCOL_WHITE"player(s) out of "VIPCOL_YELLOW"%d "VIPCOL_WHITE"with active VIP status.\n\n\
		+ "EOVIP_VIPNAME_1" "VIPCOL_WHITE"VIPs: "VIPCOL_YELLOW"%d\n\
		"VIPCOL_WHITE"+ "EOVIP_VIPNAME_2" "VIPCOL_WHITE"VIPs: "VIPCOL_YELLOW"%d\n\
		"VIPCOL_WHITE"+ "EOVIP_VIPNAME_3" "VIPCOL_WHITE"VIPs: "VIPCOL_YELLOW"%d\n\
		"VIPCOL_WHITE"+ "EOVIP_VIPNAME_4" "VIPCOL_WHITE"VIPs: "VIPCOL_YELLOW"%d\n\n\
		"VIPCOL_WHITE"The most recent VIP: "VIPCOL_YELLOW"%s", totalVIPs, totalPlayers, levels[0], levels[1], levels[2], levels[3], mostRecentVIP);

	ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, ""VIPCOL_ORANGE"VIP statistics", content, "Close", "");

	return CMD_SUCCESS;
}

CMD:setvip(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not authorized to use this command!");
	new message[144], level, targetid;
	if(sscanf(params, "ud", targetid, level)) return SendClientMessage(playerid, VIPCOLOR_GREEN, "[USAGE]: /setvip [playerid] [level]") && SendClientMessage(playerid, VIPCOLOR_GREEN, "[FUNCTION]: Set someone's VIP status");
	if(level < EOVIP_VIPLEVEL_0 || level > EOVIP_VIPLEVEL_4) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have entered an invalid VIP level, Valid levels: [0-4]!");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: This player is not connected!");
	if(IsPlayerNPC(targetid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't set VIP status to an NPC!");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have entered an invalid player id!");
	if(level == getVIPLevel(targetid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: This player already has this VIP level set!");

	if(getVIPLevel(targetid) > level)
	{		
		format(message, sizeof(message), "[INFO]: Your VIP level has been reduced from "VIPCOL_WHITE"%d "VIPCOL_RED"to VIP level "VIPCOL_WHITE"%d!", getVIPLevel(targetid), level);
		SendClientMessage(targetid, VIPCOLOR_RED, message);
		GameTextForPlayer(playerid, "~r~VIP level reduced", 2000, 0);

		format(message, sizeof(message), "[INFO]: You have reduced %s's VIP level from "VIPCOL_WHITE"%d "VIPCOL_ORANGE"to VIP level "VIPCOL_WHITE"%d!", GetPlayerNameEx(targetid), getVIPLevel(targetid), level);
		SendClientMessage(playerid, VIPCOLOR_ORANGE, message);
	}

	else
	{
		format(message, sizeof(message), "[INFO]: You VIP level has been increased from "VIPCOL_WHITE"%d "VIPCOL_YELLOW"to VIP level "VIPCOL_WHITE"%d!", getVIPLevel(targetid), level);
		SendClientMessage(targetid, VIPCOLOR_YELLOW, message);
		GameTextForPlayer(playerid, "~g~VIP level increased~n~~y~Congratulations", 2000, 0);

		format(message, sizeof(message), "[INFO]: You have increased %s's VIP level from "VIPCOL_WHITE"%d "VIPCOL_ORANGE"to VIP level "VIPCOL_WHITE"%d!", GetPlayerNameEx(targetid), getVIPLevel(targetid), level);
		SendClientMessage(playerid, VIPCOLOR_ORANGE, message);
	}

	format(message, sizeof(message), "[INFO]: Administrator %s has set %s's VIP level to %d", GetPlayerNameEx(playerid), GetPlayerNameEx(targetid), level);
	SendClientMessageToAll(VIPCOLOR_ORANGE, message);
	setVIPLevel(targetid, level);

	mysql_format(g_SQL, message, sizeof(message), "UPDATE `VIPs` SET `VIPLevel` = %d, `Timestamp` = CURRENT_TIMESTAMP WHERE `ID` = %d;", level, getPlayerAccID(playerid));
	mysql_tquery(g_SQL, message);

	return CMD_SUCCESS;
}

//vip level 0 Commands
CMD:isvip(playerid, params[])
{
    new tid;
	if(sscanf(params, "u", tid)) return SendClientMessage(playerid, VIPCOLOR_GREEN, "[USAGE]: /isvip [playerid]") && SendClientMessage(playerid, VIPCOLOR_GREEN, "[FUNCTION]: Check if player is a VIP");
	if(!IsPlayerConnected(tid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: This player is not connected!");
	if(IsPlayerNPC(tid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't use this on an NPC!");
	if(tid == INVALID_PLAYER_ID) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have eneter an invalid player id!");

	OnPlayerClickPlayer(playerid, tid, 1);

	return CMD_SUCCESS;
}

CMD:vips(playerid)
{
	new _header[50], _content[3000], vipCount = Iter_Count(VIP);
	format(_header, sizeof(_header), ""VIPCOL_WHITE"VIPs Online ["VIPCOL_GREEN"%d"VIPCOL_WHITE"]", vipCount);

	if(!vipCount)
		ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, _header, ""VIPCOL_RED"There are no VIPs online!", "Close", "");

	else
	{
		foreach(new i : VIP)
			format(_content, sizeof(_content), "%s[%s : level %d] - %s\n", _content, getVIPName(i), getVIPLevel(i), GetPlayerNameEx(i));

		ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, _header, _content, "Close", "");
	}

	return CMD_SUCCESS;
}

//VIP Level 1 Commands
CMD:vipcmds(playerid)
{
	new _content[1500], _header[40];

	switch(getVIPLevel(playerid))
	{
		case EOVIP_VIPLEVEL_0:
		{
			strcat(_content, ""VIPCOL_ORANGE"/isvip - "VIPCOL_WHITE" View if player is a VIP\n");
			strcat(_content, ""VIPCOL_ORANGE"/vips - "VIPCOL_WHITE" View all online VIPs");

			strcpy(_header, "VIP Level 0 ["EOVIP_VIPNAME_0"] Commands", sizeof(_header));
		}

		case EOVIP_VIPLEVEL_1:
		{
			strcat(_content, ""VIPCOL_ORANGE"/isvip - "VIPCOL_WHITE" View if player is a VIP\n");
			strcat(_content, ""VIPCOL_ORANGE"/vips - "VIPCOL_WHITE" View all online VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vchat - "VIPCOL_WHITE" Chat with other VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipcmds - "VIPCOL_WHITE" View VIP commands\n");
			strcat(_content, ""VIPCOL_ORANGE"/viphelp - "VIPCOL_WHITE" View VIP help panel\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipaccount - "VIPCOL_WHITE" View you're VIP account information\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptag - "VIPCOL_WHITE" Toggle VIP tag on you\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptoys - "VIPCOL_WHITE" Manage VIP toys\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptime - "VIPCOL_WHITE" Change the time\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipweather - "VIPCOL_WHITE" Change the weather\n");
			strcat(_content, ""VIPCOL_ORANGE"/weatherids - "VIPCOL_WHITE" View weather IDs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbs - "VIPCOL_WHITE" Manage VIP bane spawn\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipvehflip - "VIPCOL_WHITE" Flip up your vehicle");

			strcpy(_header, "VIP Level 1 ["EOVIP_VIPNAME_1"] Commands", sizeof(_header));
		}

		case EOVIP_VIPLEVEL_2:
		{
			strcat(_content, ""VIPCOL_ORANGE"/isvip - "VIPCOL_WHITE" View if player is a VIP\n");
			strcat(_content, ""VIPCOL_ORANGE"/vips - "VIPCOL_WHITE" View all online VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vchat - "VIPCOL_WHITE" Chat with other VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipcmds - "VIPCOL_WHITE" View VIP commands\n");
			strcat(_content, ""VIPCOL_ORANGE"/viphelp - "VIPCOL_WHITE" View VIP help panel\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipaccount - "VIPCOL_WHITE" View you're VIP account information\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptag - "VIPCOL_WHITE" Toggle VIP tag on you\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipgunpack - "VIPCOL_WHITE" Spawn VIP gun pack\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptoys - "VIPCOL_WHITE" Manage VIP toys\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptime - "VIPCOL_WHITE" Change the time\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipweather - "VIPCOL_WHITE" Change the weather\n");
			strcat(_content, ""VIPCOL_ORANGE"/weatherids - "VIPCOL_WHITE" View weather IDs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbs - "VIPCOL_WHITE" Manage VIP bane spawn\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipvehflip - "VIPCOL_WHITE" Flip up your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/changevehcolor - "VIPCOL_WHITE" Change your vehicle's color\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipnos - "VIPCOL_WHITE" Add nitrous to your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipenginefix - "VIPCOL_WHITE" Fix your vehicle's engine\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbodyfix - "VIPCOL_WHITE" Fix your vehicle's body\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbasetp - "VIPCOL_WHITE" Teleport to the VIP base");

			strcpy(_header, "VIP Level 2 ["EOVIP_VIPNAME_2"] Commands", sizeof(_header));
		}

		case EOVIP_VIPLEVEL_3:
		{
			strcat(_content, ""VIPCOL_ORANGE"/isvip - "VIPCOL_WHITE" View if player is a VIP\n");
			strcat(_content, ""VIPCOL_ORANGE"/vips - "VIPCOL_WHITE" View all online VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vchat - "VIPCOL_WHITE" Chat with other VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipcmds - "VIPCOL_WHITE" View VIP commands\n");
			strcat(_content, ""VIPCOL_ORANGE"/viphelp - "VIPCOL_WHITE" View VIP help panel\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipaccount - "VIPCOL_WHITE" View you're VIP account information\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptag - "VIPCOL_WHITE" Toggle VIP tag on you\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipgunpack - "VIPCOL_WHITE" Spawn VIP gun pack\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptoys - "VIPCOL_WHITE" Manage VIP toys\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptime - "VIPCOL_WHITE" Change the time\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipweather - "VIPCOL_WHITE" Change the weather\n");
			strcat(_content, ""VIPCOL_ORANGE"/weatherids - "VIPCOL_WHITE" View weather IDs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbs - "VIPCOL_WHITE" Manage VIP bane spawn\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipvehflip - "VIPCOL_WHITE" Flip up your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/changevehcolor - "VIPCOL_WHITE" Change your vehicle's color\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipnos - "VIPCOL_WHITE" Add nitrous to your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipenginefix - "VIPCOL_WHITE" Fix your vehicle's engine\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbodyfix - "VIPCOL_WHITE" Fix your vehicle's body\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbasetp - "VIPCOL_WHITE" Teleport to the VIP base\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipgppreset - "VIPCOL_WHITE" Manage your gun pack preset\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipskin - "VIPCOL_WHITE" Change your skin");

			strcpy(_header, "VIP Level 3 ["EOVIP_VIPNAME_3"] Commands", sizeof(_header));
		}

		case EOVIP_VIPLEVEL_4:
		{
			strcat(_content, ""VIPCOL_ORANGE"/isvip - "VIPCOL_WHITE" View if player is a VIP\n");
			strcat(_content, ""VIPCOL_ORANGE"/vips - "VIPCOL_WHITE" View all online VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vchat - "VIPCOL_WHITE" Chat with other VIPs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipcmds - "VIPCOL_WHITE" View VIP commands\n");
			strcat(_content, ""VIPCOL_ORANGE"/viphelp - "VIPCOL_WHITE" View VIP help panel\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipaccount - "VIPCOL_WHITE" View you're VIP account information\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptag - "VIPCOL_WHITE" Toggle VIP tag on you\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipgunpack - "VIPCOL_WHITE" Spawn VIP gun pack\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptoys - "VIPCOL_WHITE" Manage VIP toys\n");
			strcat(_content, ""VIPCOL_ORANGE"/viptime - "VIPCOL_WHITE" Change the time\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipweather - "VIPCOL_WHITE" Change the weather\n");
			strcat(_content, ""VIPCOL_ORANGE"/weatherids - "VIPCOL_WHITE" View weather IDs\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbs - "VIPCOL_WHITE" Manage VIP bane spawn\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipvehflip - "VIPCOL_WHITE" Flip up your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/changevehcolor - "VIPCOL_WHITE" Change your vehicle's color\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipnos - "VIPCOL_WHITE" Add nitrous to your vehicle\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipenginefix - "VIPCOL_WHITE" Fix your vehicle's engine\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbodyfix - "VIPCOL_WHITE" Fix your vehicle's body\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipbasetp - "VIPCOL_WHITE" Teleport to the VIP base\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipgppreset - "VIPCOL_WHITE" Manage your gun pack preset\n");
			strcat(_content, ""VIPCOL_ORANGE"/vipskin - "VIPCOL_WHITE" Change your skin");

			strcpy(_header, "VIP Level 4 ["EOVIP_VIPNAME_4"] Commands", sizeof(_header));
		}
	}

	ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_LIST, _header, _content, "Close", "");
	
	return CMD_SUCCESS;
}

CMD:vchat(playerid, params[])
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(isnull(params)) return SendClientMessage(playerid, VIPCOLOR_GREEN, "[USAGE]: /vchat [message]") && SendClientMessage(playerid, VIPCOLOR_GREEN, "[FUNCTION]: Chat with other VIPs");
	if(strlen(params) > 85) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: Message given is too long!");
	new message[144];

	format(message, sizeof(message), "[VIP CHAT] %s: %s", GetPlayerNameEx(playerid), params);
	SendClientMessageToVIPs(message, VIPCOLOR_BLUE);

	return CMD_SUCCESS;
}

CMD:vipaccount(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	new _content[370], daysLeft, hoursLeft, minsLeft, acquired[11], Cache:result;

	mysql_format(g_SQL, _content, sizeof(_content), "SELECT DATE(`Timestamp`) AS `Acquired`, TIMESTAMPDIFF(DAY, NOW(), DATE_ADD(`Timestamp`, INTERVAL 30 DAY)) AS `daysLeft`, TIMESTAMPDIFF(HOUR, NOW(), DATE_ADD(`Timestamp`, INTERVAL 30*24 HOUR)) AS `hoursLeft`, TIMESTAMPDIFF(MINUTE, NOW(), DATE_ADD(`Timestamp`, INTERVAL 30*24*60 MINUTE)) AS `minLeft` FROM `VIPs` WHERE `Username` = '%e' LIMIT 1;", GetPlayerNameEx(playerid));
	result = mysql_query(g_SQL, _content);
	cache_get_value_name(0, "Acquired", acquired, sizeof(acquired));
	cache_get_value_name_int(0, "daysLeft", daysLeft);
	cache_get_value_name_int(0, "hoursLeft", hoursLeft);
	cache_get_value_name_int(0, "minLeft", minsLeft);
	cache_delete(result);

	format(_content, sizeof(_content), ""VIPCOL_WHITE"Username\t"VIPCOL_YELLOW"%s\n\
		"VIPCOL_WHITE"VIP Level\t"VIPCOL_YELLOW"%d\n\
		"VIPCOL_WHITE"Account Type\t"VIPCOL_YELLOW"%s\n\
		"VIPCOL_WHITE"VIP set on\t"VIPCOL_YELLOW"%s\n\
		"VIPCOL_WHITE"Time left\t"VIPCOL_YELLOW"%d\n\
		"VIPCOL_WHITE"Spawn in VIP Base\t"VIPCOL_YELLOW"%s",
		GetPlayerNameEx(playerid),
		getVIPLevel(playerid),
		getVIPName(playerid),
		acquired,
		(daysLeft > 1 ? daysLeft : hoursLeft > 1 ? hoursLeft : minsLeft),
		VIPInfo[playerid][e_VIPBaseSpawn] ? ("YES") : ("NO"));

	ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_TABLIST, "VIP information", _content, "Close", "");

	return CMD_SUCCESS;
}

CMD:viphelp(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
		
	switch(getVIPLevel(playerid))
	{
		case EOVIP_VIPLEVEL_1: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_LIST, "["EOVIP_VIPNAME_1"] VIP Help", "Features:\n\nYou can change up to 2 different weather types.", "Close","");
		case EOVIP_VIPLEVEL_2: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_LIST, "["EOVIP_VIPNAME_2"] VIP Help", "Features:\n\n/vipgunpack Gives you 2 weapons.\n\nYou can change up to 3 different weather types.","Close","");
		case EOVIP_VIPLEVEL_3: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_LIST, "["EOVIP_VIPNAME_3"] VIP Help", "Features:\n\nSpawn with 40%% of Armour.\n\n/vipgunpack Gives you 3 weapons.\n\nYou can change up to 4 different weather types.\n\nYou choose between 5 skin via /vipskin.","Close","");
		case EOVIP_VIPLEVEL_4: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_LIST, "["EOVIP_VIPNAME_4"] VIP Help", "Features:\n\nSpawn with 80%% of Armour.\n\n/vipgunpack Gives you 4 weapons.\n\nYou can change up to 6 different weather types.\n\nYou choose between 10 skin via /vipskin.","Close","");
	}

	return CMD_SUCCESS;
}

CMD:viptag(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");  
	
	if(!isPlayerVIPTagActive(playerid))
		TogglePlayerVIPTag(playerid, true);
	else
		TogglePlayerVIPTag(playerid, false);

	return CMD_SUCCESS;
}

CMD:viptoys(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
    new _content[350];
    
    for(new i; i<MAX_PLAYER_ATTACHED_OBJECTS; i++)
    	format(_content, sizeof(_content), "%sSlot %i"VIPCOL_WHITE"\t\t\t%s\n" ,_content, i+1, IsPlayerAttachedObjectSlotUsed(playerid, i) ? (""VIPCOL_RED"[USED]") : (""VIPCOL_GREEN"[EMPTY]"));
    
    SendClientMessage(playerid, VIPCOLOR_BLUE, "[EO_VIP] "VIPCOL_BLUE"Please select a slot to insert/manage toys in!");
    ShowPlayerDialog(playerid, DIALOG_TOYS, DIALOG_STYLE_LIST, "VIP Toys", _content, "Select", "Cancel");

	return CMD_SUCCESS;
}

CMD:viptime(playerid, params[])
{
	new _hour, _minute, str[70];
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(sscanf(params, "ii", _hour, _minute)) return SendClientMessage(playerid, VIPCOLOR_GREEN ,"[USAGE]: /viptime [Hour] [Minute]") && SendClientMessage(playerid, VIPCOLOR_GREEN ,"[FUNCTION]: Change your time");
	if(_hour > 23 || _hour < 0 || _minute > 59 || _minute < 0) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have entered an invalid hour/minute value!");
    
    SetPlayerTime(playerid, _hour, _minute);
    format(str, sizeof(str), "[EO_VIP]: You have set your time to "VIPCOL_WHITE"%02d"VIPCOL_ORANGE":"VIPCOL_WHITE"%02d", _hour, _minute);
    SendClientMessage(playerid, VIPCOLOR_ORANGE, str);

	return CMD_SUCCESS;
}

CMD:vipbs(playerid)
{
    if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
    	
    if(!VIPInfo[playerid][e_VIPBaseSpawn])
    	ShowPlayerDialog(playerid, DIALOG_VIPBASESPAWN, DIALOG_STYLE_MSGBOX, "VIP Base Spawn Option", "Do you want to always spawn in VIP Base?\n\nYou can change this this anytime with "VIPCOL_WHITE"/vipbs", "Yes", "No");

	else
		ShowPlayerDialog(playerid, DIALOG_VIPBASESPAWN, DIALOG_STYLE_MSGBOX, "VIP Base Spawn Option", "Do you want to disable Spawning in VIP base option?\n\nYou can change this this anytime with "VIPCOL_WHITE"/vipbs", "Yes", "No");

	return CMD_SUCCESS;
}

CMD:weatherids(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	
	switch(getVIPLevel(playerid))
	{
		case EOVIP_VIPLEVEL_1: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, "Weather IDs", ""VIPCOL_YELLOW"1- "VIPCOL_WHITE"Sunny\n\n"VIPCOL_YELLOW"2- "VIPCOL_WHITE"Extra Sunny Smog", "Close", "");
		case EOVIP_VIPLEVEL_2: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, "Weather IDs", ""VIPCOL_YELLOW"1- "VIPCOL_WHITE"Sunny\n\n"VIPCOL_YELLOW"2- "VIPCOL_WHITE"Extra Sunny Smog\n\n"VIPCOL_YELLOW"3- "VIPCOL_WHITE"Sunny Smog", "Close", "");
		case EOVIP_VIPLEVEL_3: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, "Weather IDs", ""VIPCOL_YELLOW"1- "VIPCOL_WHITE"Sunny\n\n"VIPCOL_YELLOW"2- "VIPCOL_WHITE"Extra Sunny Smog\n\n"VIPCOL_YELLOW"3- "VIPCOL_WHITE"Sunny Smog\n\n"VIPCOL_YELLOW"4- "VIPCOL_WHITE"Cloudy", "Close", "");
		case EOVIP_VIPLEVEL_4: ShowPlayerDialog(playerid, DIALOG_MSG, DIALOG_STYLE_MSGBOX, "Weather IDs", ""VIPCOL_YELLOW"1- "VIPCOL_WHITE"Sunny\n\n"VIPCOL_YELLOW"2- "VIPCOL_WHITE"Extra Sunny Smog\n\n"VIPCOL_YELLOW"3- "VIPCOL_WHITE"Sunny Smog\n\n"VIPCOL_YELLOW"4- "VIPCOL_WHITE"Cloudy\n\n"VIPCOL_YELLOW"5- "VIPCOL_WHITE"Summer Sun\n\n"VIPCOL_YELLOW"6- "VIPCOL_WHITE"Summer Extra Sunny", "Close", "");
	}

	return CMD_SUCCESS;
}

CMD:vipweather(playerid, params[])
{
	new wid, str[70];
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(sscanf(params, "i", wid)) return SendClientMessage(playerid, VIPCOLOR_GREEN ,"[USAGE]: /vipweather [Weather ID] - use /weatherids to view available weather IDs") && SendClientMessage(playerid, VIPCOLOR_GREEN ,"[FUNCTION]: Change your weather");

	switch(getVIPLevel(playerid))
	{
		case EOVIP_VIPLEVEL_1:
		{
			if(wid > 2 || wid < 1) return SendClientMessage(playerid, VIPCOLOR_RED,"[ERROR]: You have entered an invalid weather ID, available Weather IDs are {92979C}[1-2]");
    		format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"You have set the weather ID to "VIPCOL_WHITE"%i", wid);
			SendClientMessage(playerid, VIPCOLOR_ORANGE,str);
			SetPlayerWeather(playerid, wid);
		}

		case EOVIP_VIPLEVEL_2:
		{
			if(wid > 3 || wid < 1) return SendClientMessage(playerid, VIPCOLOR_RED ,"[ERROR]: You have entered an invalid weather ID, available Weather IDs are {92979C}[1-3]");
	    	format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"You have set the weather ID to "VIPCOL_WHITE"%i", wid);
			SendClientMessage(playerid, VIPCOLOR_ORANGE ,str);
			SetPlayerWeather(playerid, wid);
		}

		case EOVIP_VIPLEVEL_3:
		{
			if(wid > 4 || wid < 1) return SendClientMessage(playerid, VIPCOLOR_RED,"[ERROR]: You have entered an invalid weather ID, available Weather IDs are {92979C}[1-4]");
	    	format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"You have set the weather ID to "VIPCOL_WHITE"%i", wid);
			SendClientMessage(playerid, VIPCOLOR_ORANGE,str);
			SetPlayerWeather(playerid, wid);
		}

		case EOVIP_VIPLEVEL_4:
		{
			if(wid > 6 || wid < 1) return SendClientMessage(playerid, VIPCOLOR_RED ,"[ERROR]: You have entered an invalid weather ID, available Weather IDs are {92979C}[1-6]");
	    	format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"You have set the weather ID to "VIPCOL_WHITE"%i", wid);
			SendClientMessage(playerid, VIPCOLOR_ORANGE ,str);
			SetPlayerWeather(playerid, wid);

		}
	}

	return CMD_SUCCESS;
}

CMD:vipvehflip(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
 	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to be in a vehicle to use this command!");
    new currentveh = GetPlayerVehicleID(playerid), Float:_angle;

    GetVehicleZAngle(currentveh, _angle);
    SetVehicleZAngle(currentveh, _angle);
    SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: Your vehicle has been flipped!");

	return CMD_SUCCESS;
}

//VIP Level 2 Commands
CMD:vipgunpack(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
	if(gettime() - VIPInfo[playerid][e_VIPGunPackCoolDown] < 900) SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have just used that command, please wait for 15 minutes");
    
    if(!VIPInfo[playerid][e_VIPGunPackPreset])
    {
	    switch(getVIPLevel(playerid))
	    {
	        case EOVIP_VIPLEVEL_2:
	        {
	            GivePlayerWeapon(playerid, 22, 50);
	            GivePlayerWeapon(playerid, 25, 30);
			}

	        case EOVIP_VIPLEVEL_3:
	        {
				GivePlayerWeapon(playerid, 4, 1);
				GivePlayerWeapon(playerid, 24, 10);
				GivePlayerWeapon(playerid, 27, 50);
			}

	        case EOVIP_VIPLEVEL_4:
	        {
				GivePlayerWeapon(playerid, 9, 1);
				GivePlayerWeapon(playerid, 24, 25);
				GivePlayerWeapon(playerid, 26, 30);
				GivePlayerWeapon(playerid, 31, 100);
	        }
	    }

	    SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"VIP Weapon pack given");
		SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have loaded the default preset of guns, you can create your customized one via "VIPCOL_WHITE"/vipgppreset");
	}

	else
	{
	    SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have loaded customized preset of guns, you can manage it anytime via "VIPCOL_WHITE"/vipgppreset");
	    
	    if(VIPInfo[playerid][e_VIPGPMelee] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPMelee], 1);
	    if(VIPInfo[playerid][e_VIPGPPistol] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPPistol], 25);
	    if(VIPInfo[playerid][e_VIPGPShotgun] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPShotgun], 30);
	    if(VIPInfo[playerid][e_VIPGPSubMachine] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPSubMachine], 40);
	    if(VIPInfo[playerid][e_VIPGPAssault] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPAssault], 100);
	    if(VIPInfo[playerid][e_VIPGPRifle] != -1)
	    	GivePlayerWeapon(playerid, VIPInfo[playerid][e_VIPGPRifle], 15);
	}

	VIPInfo[playerid][e_VIPGunPackCoolDown] = gettime();
 
	return CMD_SUCCESS;
}

CMD:changevehcolor(playerid, params[])
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
    new str[128], color1, color2;
    if(sscanf(params, "ii", color1, color2)) return SendClientMessage(playerid, VIPCOLOR_GREEN, "[USAGE]: /changevehcolor [color 1] [color 2]") && SendClientMessage(playerid, VIPCOLOR_GREEN, "[FUNCTION]: Change a vehicle's color");
    if(color1 > 255 || color1 < 0 || color2 > 255 || color2 < 0) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You have entered an invalid Color ID!");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to be in a vehicle to use this command!");
	
    switch(getVIPLevel(playerid))
    {
    	case EOVIP_VIPLEVEL_2:
    	{
    		if(GetPlayerMoney(playerid) < EOVIP_CCOLOR_FEE_2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford changing this vehicle's color");
		    GivePlayerMoney(playerid, -EOVIP_CCOLOR_FEE_2);
		    format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"Vehicle color changed to ( "VIPCOL_YELLOW"%i "VIPCOL_WHITE", "VIPCOL_YELLOW"%i "VIPCOL_WHITE"), you've been charged with "VIPCOL_YELLOW"$"#EOVIP_CCOLOR_FEE_2"", color1, color2);
			SendClientMessage(playerid, VIPCOLOR_ORANGE, str);
			ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
    	}

    	case EOVIP_VIPLEVEL_3:
    	{
    		if(GetPlayerMoney(playerid) < EOVIP_CCOLOR_FEE_3) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford changing this vehicle's color");
		    GivePlayerMoney(playerid, -EOVIP_CCOLOR_FEE_3);
		    format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"Vehicle color changed to ( "VIPCOL_YELLOW"%i "VIPCOL_WHITE", "VIPCOL_YELLOW"%i "VIPCOL_WHITE"), you've been charged with "VIPCOL_YELLOW"$"#EOVIP_CCOLOR_FEE_3"", color1, color2);
			SendClientMessage(playerid, VIPCOLOR_ORANGE, str);
			ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
    	}

    	case EOVIP_VIPLEVEL_4:
    	{
    		if(GetPlayerMoney(playerid) < EOVIP_CCOLOR_FEE_4) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford changing this vehicle's color");
		    GivePlayerMoney(playerid, -EOVIP_CCOLOR_FEE_4);
		    format(str, sizeof(str), "[EO_VIP]: "VIPCOL_YELLOW"Vehicle color changed to ( "VIPCOL_YELLOW"%i "VIPCOL_WHITE", "VIPCOL_YELLOW"%i "VIPCOL_WHITE"), you've been charged with "VIPCOL_YELLOW"$"#EOVIP_CCOLOR_FEE_4"", color1, color2);
			SendClientMessage(playerid, VIPCOLOR_ORANGE, str);
			ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
    	}
    }

	return CMD_SUCCESS;
}

CMD:vipnos(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
    if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to be in a vehicle to use this command!");  
    
    switch(getVIPLevel(playerid))
    {
		case EOVIP_VIPLEVEL_2:
		{
		    if(GetPlayerMoney(playerid) < EOVIP_CNOS_FEE_2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford to buy this");
		    GivePlayerMoney(playerid, -EOVIP_CNOS_FEE_2);
      		SendClientMessage(playerid, VIPCOLOR_ORANGE, "[ERROR]: "VIPCOL_YELLOW"You have added nitrous to this vehicle, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CNOS_FEE_2"");
		}

        case EOVIP_VIPLEVEL_3:
        {
            if(GetPlayerMoney(playerid) < EOVIP_CNOS_FEE_3) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford to buy this");
			GivePlayerMoney(playerid, -EOVIP_CNOS_FEE_3);
	        SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have added nitrous to this vehicle, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CNOS_FEE_3"");
		}

        case EOVIP_VIPLEVEL_4:
        {
            if(GetPlayerMoney(playerid) < EOVIP_CNOS_FEE_4) return  SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford to buy this");
			GivePlayerMoney(playerid, -EOVIP_CNOS_FEE_4);
            SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"You have added nitrous to this vehicle, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CNOS_FEE_4"");
		}
    }

    AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);

	return CMD_SUCCESS;
}

CMD:vipenginefix(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
    if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to be in a vehicle to use this command!");  
    
    switch(getVIPLevel(playerid))
    {
		case EOVIP_VIPLEVEL_3:
		{
        	if(GetPlayerMoney(playerid) < EOVIP_CEFIX_FEE_3)
            GivePlayerMoney(playerid, -EOVIP_CEFIX_FEE_3);
            SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"vehicle fixed, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CEFIX_FEE_3"");
        }

        case EOVIP_VIPLEVEL_4:
        {
            if(GetPlayerMoney(playerid) < EOVIP_CEFIX_FEE_4)
            GivePlayerMoney(playerid, -EOVIP_CEFIX_FEE_4);
            SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"vehicle fixed, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CEFIX_FEE_4"");
        }
    }

    SetVehicleHealth(GetPlayerVehicleID(playerid), 1000);

	return CMD_SUCCESS;
}

CMD:vipbodyfix(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
    if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to be in a vehicle to use this command!");
    if(GetPlayerMoney(playerid) < EOVIP_CBFIX_FEE) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You can't afford this!");

    RepairVehicle(GetPlayerVehicleID(playerid));
 	GivePlayerMoney(playerid, -EOVIP_CBFIX_FEE);
	SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_YELLOW"vehicle fixed, you've been charged with "VIPCOL_WHITE"$"#EOVIP_CBFIX_FEE"");
	PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);

	return CMD_SUCCESS;
}

CMD:vipbasetp(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(getVIPLevel(playerid) < 2) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 2 or above to use this command!");
	if(gettime() - VIPInfo[playerid][e_VIPBaseTeleportCoolDown] < 600) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You cannot use this command now, wait for 10 minutes!");

	VIPInfo[playerid][e_VIPBaseTeleportCoolDown] = gettime();
	TogglePlayerControllable(playerid, false);
	SetPlayerPos(playerid, 3024.9241, -692.5798, 3.3770);
	GameTextForPlayer(playerid, "~y~VIP Base", 2000, 1);
	SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: You have teleported to the VIP base!");
	SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: You have been temporarily frozen, please wait for the environment to lead!");
	defer VIPBaseTeleportTimer(playerid);

	return CMD_SUCCESS;
}

//VIP Level 3 Commands
CMD:vipgppreset(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(getVIPLevel(playerid) < 3) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 3 or above to use this command!");
    
    if(!VIPInfo[playerid][e_VIPGunPackPreset])
    	ShowPlayerDialog(playerid, DIALOG_VIPGPPRESETCREATE, DIALOG_STYLE_MSGBOX, "VIP GunPack Preset Option", "Here you can make a new Gunpack set to spawn via "VIPCOL_WHITE"/vipgppreset\n\n"VIPCOL_YELLOW"You Don't have a GunPack Preset yet, do you want to create one?", "Yes", "No");
	
	else
	{
	    ShowPlayerDialog(playerid, DIALOG_VIPGPPRESETEDIT, DIALOG_STYLE_LIST, "VIP GunPack Preset Option",
		"Edit Gunpack Preset\n\
		Delete Gunpack Preset\n",
		"Select", "Cancel");
	}

	return CMD_SUCCESS;
}

CMD:vipskin(playerid)
{
	if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You are not a VIP, you cannot use this command!");
	if(getVIPLevel(playerid) < 3) return SendClientMessage(playerid, VIPCOLOR_RED, "[ERROR]: You need to have VIP level 3 or above to use this command!");
	
	switch(getVIPLevel(playerid))
	{
		case EOVIP_VIPLEVEL_3:
		{
			ShowPlayerDialog(playerid, DIALOG_VIPSKINS, DIALOG_STYLE_LIST, "VIP SKINS SELECTION "VIPCOL_YELLOW"["EOVIP_VIPNAME_3"]",
			"Maccer\n\
			Andre\n\
			Rich Woman\n\
			CJ\n\
			Stunner\n",
			"Select", "Cancel");
		}

		case EOVIP_VIPLEVEL_4:
		{
			ShowPlayerDialog(playerid, DIALOG_VIPSKINS, DIALOG_STYLE_LIST, "VIP SKINS SELECTION "VIPCOL_YELLOW"["EOVIP_VIPNAME_4"]",
			"Maccer\n\
			Andre\n\
			Rich Woman\n\
			CJ\n\
			Stunner\n\
			Ryder\n\
			Triad Boss\n\
			Big Smoke\n\
			Cluckin' bell worker\n\
			Michelle\n",
			"Select", "Cancel");
		}
	}

	return CMD_SUCCESS;
}

//VIP Level 4 Commands


//**Timers---------------------------------------------------------------------------------------------------------------------------------
timer VIPBaseTeleportTimer[2000](playerid)
{
	TogglePlayerControllable(playerid, true);
	SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: Thanks for your patience, you can now move!");
}

task VIPAdvertisementTimer[1800000]()
{
	foreach(new i : Player)
	{
		if(!isPlayerVIP(i))
			SendClientMessage(i, VIPCOLOR_GREEN, "[EO_VIP]: "VIPCOL_WHITE"Buy one of four different VIP Levels and gain countless awesome features!");
	}
}

//-VIP Messages
task VIPMessages[900000]()
{
	SendClientMessageToVIPs(VIPTips[random(sizeof(VIPTips))], -1);
}