/*=======================================================================================================================================================
==========================================================================================================================================================



															oooooooooooo   .oooooo.
															`888'     `8  d8P'  `Y8b
															 888         888      888
															 888oooo8    888      888
															 888    "    888      888
															 888       o `88b    d88'
															o888ooooood8  `Y8bood8P'

										                       VIP SYSTEM Include
										                    by Oussama .aka. Compton

												NOTE: Please note that the credits are to be kept.


> Natives

------------------[Player]------------------

native setVIPLevel(playerid, vlevel);

native getVIPLevel(playerid);

native bool:isPlayerVIP(playerid);

native getVIPName(playerid);

native getPlayerAccID(playerid);

native bool:isPlayerVIPTagActive(playerid);

native bool:isVIPInLoungue(playerid);

native TogglePlayerVIPTag(playerid, bool:param);

native SendClientMessageToVIPs(const message[], color, exceptions[] = 0, minLvl = EOVIP_VIPLEVEL_1, maxLvl = EOVIP_VIPLEVEL_4);

native ResetVIPData(playerid);

native SaveVIPData(playerid, MySQL:handle);

-------------------[Base]-------------------

native CreateVIPBase();

native ToggleVIPGates(bool:action);

native bool:isVIPGateOpened();

----------------[Vehicles]------------------

native CreateVIPVehicles();

native bool:isVIPVehicle(vehicleid);

-----------------[Other]--------------------

native PlaySoundForAll(soundid, Float:posX, Float:posY, Float:posZ);

native StopSoundForAll();

native bool:isException(playerid, exceptions[]);

============================================================================================================================================================
==========================================================================================================================================================*/

//**Definitions------------------------------------------------------------------------------------------------------------------------------
#define EOVIP_VIPLEVEL_0 			0
#define EOVIP_VIPLEVEL_1 			1
#define EOVIP_VIPLEVEL_2			2
#define EOVIP_VIPLEVEL_3			3
#define EOVIP_VIPLEVEL_4			4

#define EOVIP_VIPNAME_0				"None"
#define EOVIP_VIPNAME_1				"Silver"
#define EOVIP_VIPNAME_2				"Gold"
#define EOVIP_VIPNAME_3				"Platinum"
#define EOVIP_VIPNAME_4				"Diamond"

//**Variables--------------------------------------------------------------------------------------------------------------------------------
new gVIPVehicles[38];

//**Enums------------------------------------------------------------------------------------------------------------------------------------
enum E_VIP_DATA 
{
	e_VIPID,
	e_VIPLevel,
	e_VIPGunPackCoolDown,
	e_VIPBaseTeleportCoolDown,
	e_VIPGPMelee,
	e_VIPGPPistol,
	e_VIPGPShotgun,
	e_VIPGPSubMachine,
	e_VIPGPAssault,
	e_VIPGPRifle,
	e_VIPToysIndex[10],
	e_VIPSelectedBone,
	bool:e_VIPToysSlots[10],
	bool:e_IsVIPInLounge,
	bool:e_VIPBaseSpawn,
	bool:e_VIPTag,
	bool:e_VIPGunPackPreset,
	bool:e_VIPFirstSpawn,
	Text3D:e_VIPTagID
};

enum E_VIP_GATE 
{
	e_Gate1,
	e_Gate2,
	bool:e_IsGateOpened,
	bool:e_IsPublic
};

new
	VIPInfo[MAX_PLAYERS][E_VIP_DATA],
	VIPGate[E_VIP_GATE],
	Iterator:VIP<MAX_PLAYERS>
;

//**Functions--------------------------------------------------------------------------------------------------------------------------------
setVIPLevel(playerid, vLevel)
{
	if(vLevel >= EOVIP_VIPLEVEL_0 && vLevel <= EOVIP_VIPLEVEL_4)
	{
		if(vLevel && !Iter_Contains(VIP, playerid))
			Iter_Add(VIP, playerid);
		else
			Iter_Remove(VIP, playerid);

		VIPInfo[playerid][e_VIPLevel] = vLevel;
	}
}

getVIPLevel(playerid) return VIPInfo[playerid][e_VIPLevel];


getVIPName(playerid)
{
	new vName[9];

	switch(VIPInfo[playerid][e_VIPLevel])
	{
		case EOVIP_VIPLEVEL_0: { strcpy(vName, EOVIP_VIPNAME_0, 9); }
		case EOVIP_VIPLEVEL_1: { strcpy(vName, EOVIP_VIPNAME_1, 9); }
		case EOVIP_VIPLEVEL_2: { strcpy(vName, EOVIP_VIPNAME_2, 9); }
		case EOVIP_VIPLEVEL_3: { strcpy(vName, EOVIP_VIPNAME_3, 9); }
		case EOVIP_VIPLEVEL_4: { strcpy(vName, EOVIP_VIPNAME_4, 9); }
	}

	return vName;
}

bool:isPlayerVIP(playerid) return VIPInfo[playerid][e_VIPLevel] ? true : false;

getPlayerAccID(playerid) return VIPInfo[playerid][e_VIPID];

bool:isPlayerVIPTagActive(playerid) return VIPInfo[playerid][e_VIPTag];

TogglePlayerVIPTag(playerid, bool:param)
{
	new strTag[22];

	if(param)
	{
		format(strTag, sizeof(strTag), "VIP "VIPCOL_WHITE"Level %i", getVIPLevel(playerid));
		VIPInfo[playerid][e_VIPTagID] = CreateDynamic3DTextLabel(strTag, VIPCOLOR_ORANGE, 0.0, 0.0, 0.0, 10, playerid, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10);
		SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_WHITE"You have turned the VIP tag ON");
	}

	else
	{
		DestroyDynamic3DTextLabel(VIPInfo[playerid][e_VIPTagID]);
		SendClientMessage(playerid, VIPCOLOR_ORANGE, "[EO_VIP]: "VIPCOL_WHITE"You have turned the VIP tag OFF");
	}

	VIPInfo[playerid][e_VIPTag] = param;
}

bool:isVIPInLoungue(playerid) return VIPInfo[playerid][e_IsVIPInLounge];

ResetVIPData(playerid)
{
	new clearedData[E_VIP_DATA];
	VIPInfo[playerid] = clearedData;
}

SaveVIPData(playerid, MySQL:handle)
{
	new _query[350];

	mysql_format(handle, _query, sizeof(_query), "UPDATE `VIPs` SET \
		`VIPLevel` = %d, \
		`SpawnInBase` = %d, \
		`WeaponPreset` = %d, \
		`WeaponMeleeSlot` = %d, \
		`WeaponPistolSlot` = %d, \
		`WeaponShotgunSlot` = %d, \
		`WeaponSubMachineSlot` = %d, \
		`WeaponAssaultSlot` = %d, \
		`WeaponRifleSlot` = %d WHERE `Username` = '%e'", 
		getVIPLevel(playerid),
		VIPInfo[playerid][e_VIPBaseSpawn],
		VIPInfo[playerid][e_VIPGunPackPreset],
		VIPInfo[playerid][e_VIPGPMelee],
		VIPInfo[playerid][e_VIPGPPistol],
		VIPInfo[playerid][e_VIPGPShotgun],
		VIPInfo[playerid][e_VIPGPSubMachine],
		VIPInfo[playerid][e_VIPGPAssault],
		VIPInfo[playerid][e_VIPGPRifle],
		GetPlayerNameEx(playerid));

	mysql_tquery(handle, _query);
}

bool:isVIPVehicle(vehicleid)
{
	for(new i, j = sizeof(gVIPVehicles); i < j; i++)
	{
		if(vehicleid == gVIPVehicles[i])
			return true;
    }

   	return false;
}

ToggleVIPGates(bool:action)
{
	switch(action)
	{
		case true:
		{
		    MoveDynamicObject(VIPGate[e_Gate1], 3002.3396, -677.6714, 1.9951, 3.0);
		    MoveDynamicObject(VIPGate[e_Gate2], 3002.3396, -697.8354, 1.9951, 3.0);
		    PlaySoundForAll(1100, 3002.3396, -677.6714, 1.9951);
		    VIPGate[e_IsGateOpened] = true;
		    defer StopSoundTimer();
		}

		case false:
		{
			MoveDynamicObject(VIPGate[e_Gate1], 3002.3396, -683.2094, 1.9951, 3.0);
		    MoveDynamicObject(VIPGate[e_Gate2], 3002.3396, -692.0134, 1.9951, 3.0);
		    PlaySoundForAll(1100, 3002.3396, -683.2094, 1.9951);
		    VIPGate[e_IsGateOpened] = false;
		    defer StopSoundTimer();
		}
	}

	defer VIPGateAutoCloseTimer();
}

bool:isVIPGateOpened() return VIPGate[e_IsGateOpened];

bool:isException(playerid, exceptions[])
{
	for(new i = 0, j = strlen(exceptions); i<j; i++)
	{
		if(exceptions[i] == playerid)
			return true;
	}

	return false;
}

SendClientMessageToVIPs(const message[], color, exceptions[] = 0, minLvl = EOVIP_VIPLEVEL_1, maxLvl = EOVIP_VIPLEVEL_4)
{
	if(!strlen(exceptions))
	{
		foreach(new i : VIP)
		{
			if(VIPInfo[i][e_VIPLevel] >= minLvl && VIPInfo[i][e_VIPLevel] <= maxLvl)
				SendClientMessage(i, color, message);
		}
	}

	else
	{
		foreach(new i : VIP)
		{
			if(VIPInfo[i][e_VIPLevel] >= minLvl && VIPInfo[i][e_VIPLevel] <= maxLvl && !isException(i, exceptions))
					SendClientMessage(i, color, message);
		}
	}
}

CreateVIPVehicles()
{
	gVIPVehicles[0] = CreateVehicle(411, 3023.3174, -663.6208, 2.4356, 0.0000, 6, 6, 100);
	gVIPVehicles[1] = CreateVehicle(411, 3030.1333, -663.6208, 2.4356, 0.0000, 6, 6, 100);
	gVIPVehicles[2] = CreateVehicle(411, 3009.9695, -663.6208, 2.4356, 0.0000, 6, 6, 100);
	gVIPVehicles[3] = CreateVehicle(522, 3069.4780, -714.9214, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[4] = CreateVehicle(522, 3069.4780, -711.7974, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[5] = CreateVehicle(522, 3069.4780, -708.3894, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[6] = CreateVehicle(522, 3075.7261, -707.9634, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[7] = CreateVehicle(522, 3073.8801, -707.9634, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[8] = CreateVehicle(522, 3073.8801, -711.3714, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[9] = CreateVehicle(522, 3075.7261, -711.3714, 2.2332, 0.0000, 6, 6, 100);
	gVIPVehicles[10] = CreateVehicle(451, 3030.6123, -656.5804, 2.3751, 180.0000, 6, 6, 100);
	gVIPVehicles[11] = CreateVehicle(451, 3037.0022, -656.5804, 2.3751, 180.0000, 6, 6, 100);
	gVIPVehicles[12] = CreateVehicle(451, 3024.0803, -656.5804, 2.3751, 180.0000, 6, 6, 100);
 	gVIPVehicles[13] = CreateVehicle(487, 3065.8286, -654.2310, 15.1676, 90.0000, 6, 6, 100);
	gVIPVehicles[14] = CreateVehicle(487, 3065.8286, -667.4370, 15.1676, -90.0000, 6, 6, 100);
 	gVIPVehicles[15] = CreateVehicle(470, 3009.4387, -655.6624, 2.5133, 180.0000, 6, 6, 100);
	gVIPVehicles[16] = CreateVehicle(470, 3016.6807, -655.6624, 2.5133, 180.0000, 6, 6, 100);
	gVIPVehicles[17] = CreateVehicle(444, 3071.3596, -651.0118, 2.9290, 180.0000, 6, 6, 100);
	gVIPVehicles[18] = CreateVehicle(444, 3066.1057, -651.0118, 2.9290, 180.0000, 6, 6, 100);
	gVIPVehicles[19] = CreateVehicle(444, 3061.2776, -651.0118, 2.9290, 180.0000, 6, 6, 100);
	gVIPVehicles[20] = CreateVehicle(444, 3061.2776, -669.8978, 2.9290, 0.0000, 6, 6, 100);
	gVIPVehicles[21] = CreateVehicle(444, 3066.5315, -669.8978, 2.9290, 0.0000, 6, 6, 100);
	gVIPVehicles[22] = CreateVehicle(463, 3075.6326, -704.8986, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[23] = CreateVehicle(463, 3073.7866, -704.8986, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[24] = CreateVehicle(539, 3064.4543, -714.8845, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[25] = CreateVehicle(539, 3059.6262, -714.8845, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[26] = CreateVehicle(539, 3059.6262, -710.1985, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[27] = CreateVehicle(539, 3059.6262, -705.7965, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[28] = CreateVehicle(539, 3064.3123, -705.7965, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[29] = CreateVehicle(539, 3064.3123, -710.1985, 2.2331, 0.0000, 6, 6, 100);
	gVIPVehicles[30] = CreateVehicle(556, 3077.7942, -679.0674, 2.6504, 0.0000, 6, 6, 100);
 	gVIPVehicles[31] = CreateVehicle(556, 3072.3982, -679.0674, 2.6504, 0.0000, 6, 6, 100);
	gVIPVehicles[32] = CreateVehicle(556, 3066.2922, -679.0674, 2.6504, 0.0000, 6, 6, 100);
 	gVIPVehicles[33] = CreateVehicle(481, 3027.9504, -692.3883, 2.2612, 0.0000, 6, 6, 100);
 	gVIPVehicles[34] = CreateVehicle(481, 3028.8025, -692.3883, 2.2612, 0.0000, 6, 6, 100);
 	gVIPVehicles[35] = CreateVehicle(481, 3029.6545, -693.8083, 2.2612, 0.0000, 6, 6, 100);
	gVIPVehicles[36] = CreateVehicle(481, 3030.7905, -693.8083, 2.2612, 0.0000, 6, 6, 100);
	gVIPVehicles[37] = CreateVehicle(481, 3031.9265, -693.8083, 2.2612, 0.0000, 6, 6, 100);

	for(new i = 0; i < sizeof(gVIPVehicles); i++)
	{
    	Attach3DTextLabelToVehicle(Create3DTextLabel("VIP "VIPCOL_WHITE"Vehicle", VIPCOLOR_YELLOW, 0.0, 0.0, -10.0, 15.0, 0, 1), gVIPVehicles[i], 0.0, 0.0, 1.5);
    	AddVehicleComponent(gVIPVehicles[i], 1010);
    }
}

CreateVIPBase()
{
	//Objects
	CreateDynamicObject(8661, 3022.12695, -672.72382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3022.12695, -653.22382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3061.62695, -653.22382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3061.62695, -672.72382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3061.62695, -692.22382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3022.12695, -692.22382, 0.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3061.62695, -711.72382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3022.12695, -692.22382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8661, 3022.12695, -711.72382, 1.80860,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3053.42676, -644.44202, 4.68320,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3028.50269, -644.44202, 4.68320,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3080.58472, -672.34198, 4.68320,   0.00000, 0.00000, 89.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3080.58472, -694.17200, 4.68320,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3053.35278, -721.40399, 4.68320,   0.00000, 0.00000, 180.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8210, 3029.06470, -721.40399, 4.68320,   0.00000, 0.00000, 180.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(3749, 3003.83130, -683.48969, 7.68770,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -656.29919, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -673.96320, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -665.13123, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -704.50720, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -721.43518, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(987, 3003.03687, -713.33917, 1.77550,   0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(18788, 2983.97705, -683.33478, 0.81030,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(18788, 2960.26514, -683.33478, 0.81030,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(16287, 3072.45190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(16287, 3061.95190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(16287, 3050.95190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(10831, 3066.83032, -660.64362, 6.29510,   0.00000, 0.00000, -90.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(18850, 3065.63550, -660.40881, 1.78560,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(13749, 3061.92041, -681.63129, 7.07810,   0.00000, 0.00000, -37.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(3605, 3024.24756, -706.26788, 7.87870,   0.00000, 0.00000, 180.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8838, 3020.13696, -662.13177, 3.29460,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(8838, 3020.13696, -656.63177, 3.29460,   0.00000, 0.00000, 180.00000, -1, -1, -1, 500, 500);
	CreateDynamicObject(52, 3025.04810, -693.57910, 2.65190,   0.00000, 0.00000, 0.00000, -1, -1, -1, 500, 500);
	
	//3D Text Labels
 	CreateDynamic3DTextLabel("VIP {FFFF00}Base\nPress {FF00FF}N {FFFFFF}to open the gate", VIPCOLOR_YELLOW, 3001.5039, -683.3127, 2.0232, 20, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 20);
 	CreateDynamic3DTextLabel("VIP {FFFFFF}Lounge\nPress {FF00FF}N {FFFFFF}to enter", VIPCOLOR_YELLOW, 3024.9241, -692.5798, 3.3770, 20, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 20);

 	//Base Gate
	VIPGate[e_Gate1] = CreateDynamicObject(969, 3002.25830, -683.18237, 1.85340, 0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	VIPGate[e_Gate2] = CreateDynamicObject(969, 3002.25830, -691.98639, 1.85340, 0.00000, 0.00000, 90.00000, -1, -1, -1, 500, 500);
	ToggleVIPGates(false);
}

PlaySoundForAll(soundid, Float:posX, Float:posY, Float:posZ)
{
	foreach(new i : Player)
		PlayerPlaySound(i, soundid, posX, posY, posZ);
}

StopSoundForAll()
{
	foreach(new i : Player)
		PlayerPlaySound(i, 0, 3002.3396, -683.2094, 1.9951);
}

//**Timers--------------------------------------------------------------------------------------------------------------------------------
timer VIPGateAutoCloseTimer[6000]()
{
	MoveDynamicObject(VIPGate[e_Gate1], 3002.3396, -683.2094, 1.9951, 3.0);
	MoveDynamicObject(VIPGate[e_Gate2], 3002.3396, -692.0134, 1.9951, 3.0);
	PlaySoundForAll(1100, 3002.3396, -683.2094, 1.9951);
	VIPGate[e_IsGateOpened] = false;
	defer StopSoundTimer();
}

timer StopSoundTimer[2000]()
{
	StopSoundForAll();
}