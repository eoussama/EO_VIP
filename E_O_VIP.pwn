/*=======================================================================================================================================================
==========================================================================================================================================================



															`7MM"""YMM    .g8""8q.
															  MM    `7  .dP'    `YM.
															  MM   d    dM'      `MM
															  MMmmMM    MM        MM
															  MM   Y  , MM.      ,MP
															  MM     ,M `Mb.    ,dP'
															.JMMmmmmMMM   `"bmmd"'

										                          VIP SYSTEM
										                    by Oussama .aka. Compton


COPYRIGHT CLAIM:
**Note This is an ongoing project, thus uploading this on an other website it without my permission would not be tolerated.


============================================================================================================================================================
==========================================================================================================================================================*/
#include <a_samp>
#include <ZCMD>
#include <sscanf2>
#include <YSI\y_timers>

new DB:Database;

#define FILTERSCRIPT

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	new Query[450];
	if((Database = db_open("EO_VIP/Database.db")) == DB:0){
		printf("[ERROR]: Couldn't connect to the database");
		SendRconCommand("unloadfs E_O_VIP");
	}
	else{
		print("\n--------------------------------------");
		print(" [EO] VIP system by Oussama aka Compton");
		print(" Version 1.6");
		print(" Credits must be included");
		print("--------------------------------------\n");

		format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS `VIPS`(`ID` INTEGER PRIMARY KEY AUTOINCREMENT, `PlayerName` VARCHAR(25), `VIPLevel` INTEGER DEFAULT 0, `Gotten_Date` VARCHAR(12), `Remaining_Days` INTEGER NOT NULL, `Spawn_In_Base` INTEGER DEFAULT 0, `VIP_Weapon_Preset` INTEGER DEFAULT 0,Weapon_Melee_Slot INTEGER, Weapon_Pistol_Slot INTEGER, Weapon_Shotgun_Slot INTEGER, Weapon_SubMachine_Slot INTEGER, Weapon_Assault_Slot INTEGER, Weapon_Rifle_Slot INTEGER)");
		db_free_result(db_query(Database, Query));
	
	}
	return 1;
}

public OnFilterScriptExit()
{
	db_close(Database);
	return 1;
}

#else

#endif
//==========================================================================================================================
//==========================================================================================================================
//VIP enum
enum E_VIP_DATA {
	VIPLevel,
	VIPAcc[12],
	VIPGOT[12],
	VIPDate,
	VIPDay,
	VIPMonth,
	VIPYear,
	VIPPreset,
	WMS,
	WPS,
	WSS,
	WSSL,
	WAS,
	WRS,
	bool:IsVIPInLounge,
	bool:VIPLoggedIn,
	bool:GPAuth,
	bool:CNTUSE,
	VIPBSpawn,
	bool:VIPTAG,
	pindex,
	pmodelid,
	pboneid,
	Float:pfOffsetX,
	Float:pfOffsetY,
	Float:pfOffsetZ,
	Float:pfRotX,
	Float:pfRotY,
	Float:pfRotZ,
	Float:pfScaleX,
	Float:pfScaleY,
	Float:pfScaleZ
}
//DIALOG enum
enum {
	//CMD DIALOGS
	DIALOG_VIPCMD1,
	DIALOG_VIPCMD2,
	DIALOG_VIPCMD3,
	DIALOG_VIPCMD4,
	DIALOG_VIPHELP,
	DIALOG_VIPINFO,
	DIALOG_WEATHERID,
	//VIP BASE SPAWN DIALOGS
	DIALOG_VIPBS,
	DIALOG_VIPBSY,
	///vips
	DIALOG_AVIPS,
	//Skins
	DIALOG_VIPSKIN,
	//vip info
	DIALOG_ISVIP,
	//vip weapon presets
	DIALOG_VIP4WP,
	DIALOG_VIP4WPE,
	DIALOG_VIP4WPC,
	DIALOG_VIP4WPCE,
	DIALOG_VIP4WPCR,
	DIALOG_VIP4WP0,
	DIALOG_VIP4WP1,
	DIALOG_VIP4WP2,
	DIALOG_VIP4WP3,
	DIALOG_VIP4WP4,
	DIALOG_VIP4WP5,
	DIALOG_VIP4WPCED,
	DIALOG_VIP4WPCC
}

enum AttachmentEnum
{
    attachmodel,
    attachname[24]
}

//new
new VIPInfo[MAX_PLAYER_NAME][E_VIP_DATA];
new VIPRank[12];
new GATE1, GATE2;

//VIP Vehicles
new gVIPVehicles[38];

//Vip toys
new AttachmentObjects[][AttachmentEnum] = {
{18632, "FishingRod"},
{18633, "GTASAWrench1"},
{18634, "GTASACrowbar1"},
{18635, "GTASAHammer1"},
{18636, "PoliceCap1"},
{18637, "PoliceShield1"},
{18638, "HardHat1"},
{18639, "BlackHat1"},
{18640, "Hair1"},
{18975, "Hair2"},
{19136, "Hair4"},
{19274, "Hair5"},
{18641, "Flashlight1"},
{18642, "Taser1"},
{18643, "LaserPointer1"},
{19080, "LaserPointer2"},
{19081, "LaserPointer3"},
{19082, "LaserPointer4"},
{19083, "LaserPointer5"},
{19084, "LaserPointer6"},
{18644, "Screwdriver1"},
{18645, "MotorcycleHelmet1"},
{18865, "MobilePhone1"},
{18866, "MobilePhone2"},
{18867, "MobilePhone3"},
{18868, "MobilePhone4"},
{18869, "MobilePhone5"},
{18870, "MobilePhone6"},
{18871, "MobilePhone7"},
{18872, "MobilePhone8"},
{18873, "MobilePhone9"},
{18874, "MobilePhone10"},
{18875, "Pager1"},
{18890, "Rake1"},
{18891, "Bandana1"},
{18892, "Bandana2"},
{18893, "Bandana3"},
{18894, "Bandana4"},
{18895, "Bandana5"},
{18896, "Bandana6"},
{18897, "Bandana7"},
{18898, "Bandana8"},
{18899, "Bandana9"},
{18900, "Bandana10"},
{18901, "Bandana11"},
{18902, "Bandana12"},
{18903, "Bandana13"},
{18904, "Bandana14"},
{18905, "Bandana15"},
{18906, "Bandana16"},
{18907, "Bandana17"},
{18908, "Bandana18"},
{18909, "Bandana19"},
{18910, "Bandana20"},
{18911, "Mask1"},
{18912, "Mask2"},
{18913, "Mask3"},
{18914, "Mask4"},
{18915, "Mask5"},
{18916, "Mask6"},
{18917, "Mask7"},
{18918, "Mask8"},
{18919, "Mask9"},
{18920, "Mask10"},
{18921, "Beret1"},
{18922, "Beret2"},
{18923, "Beret3"},
{18924, "Beret4"},
{18925, "Beret5"},
{18926, "Hat1"},
{18927, "Hat2"},
{18928, "Hat3"},
{18929, "Hat4"},
{18930, "Hat5"},
{18931, "Hat6"},
{18932, "Hat7"},
{18933, "Hat8"},
{18934, "Hat9"},
{18935, "Hat10"},
{18936, "Helmet1"},
{18937, "Helmet2"},
{18938, "Helmet3"},
{18939, "CapBack1"},
{18940, "CapBack2"},
{18941, "CapBack3"},
{18942, "CapBack4"},
{18943, "CapBack5"},
{18944, "HatBoater1"},
{18945, "HatBoater2"},
{18946, "HatBoater3"},
{18947, "HatBowler1"},
{18948, "HatBowler2"},
{18949, "HatBowler3"},
{18950, "HatBowler4"},
{18951, "HatBowler5"},
{18952, "BoxingHelmet1"},
{18953, "CapKnit1"},
{18954, "CapKnit2"},
{18955, "CapOverEye1"},
{18956, "CapOverEye2"},
{18957, "CapOverEye3"},
{18958, "CapOverEye4"},
{18959, "CapOverEye5"},
{18960, "CapRimUp1"},
{18961, "CapTrucker1"},
{18962, "CowboyHat2"},
{18963, "CJElvisHead"},
{18964, "SkullyCap1"},
{18965, "SkullyCap2"},
{18966, "SkullyCap3"},
{18967, "HatMan1"},
{18968, "HatMan2"},
{18969, "HatMan3"},
{18970, "HatTiger1"},
{18971, "HatCool1"},
{18972, "HatCool2"},
{18973, "HatCool3"},
{18974, "MaskZorro1"},
{18976, "MotorcycleHelmet2"},
{18977, "MotorcycleHelmet3"},
{18978, "MotorcycleHelmet4"},
{18979, "MotorcycleHelmet5"},
{19006, "GlassesType1"},
{19007, "GlassesType2"},
{19008, "GlassesType3"},
{19009, "GlassesType4"},
{19010, "GlassesType5"},
{19011, "GlassesType6"},
{19012, "GlassesType7"},
{19013, "GlassesType8"},
{19014, "GlassesType9"},
{19015, "GlassesType10"},
{19016, "GlassesType11"},
{19017, "GlassesType12"},
{19018, "GlassesType13"},
{19019, "GlassesType14"},
{19020, "GlassesType15"},
{19021, "GlassesType16"},
{19022, "GlassesType17"},
{19023, "GlassesType18"},
{19024, "GlassesType19"},
{19025, "GlassesType20"},
{19026, "GlassesType21"},
{19027, "GlassesType22"},
{19028, "GlassesType23"},
{19029, "GlassesType24"},
{19030, "GlassesType25"},
{19031, "GlassesType26"},
{19032, "GlassesType27"},
{19033, "GlassesType28"},
{19034, "GlassesType29"},
{19035, "GlassesType30"},
{19036, "HockeyMask1"},
{19037, "HockeyMask2"},
{19038, "HockeyMask3"},
{19039, "WatchType1"},
{19040, "WatchType2"},
{19041, "WatchType3"},
{19042, "WatchType4"},
{19043, "WatchType5"},
{19044, "WatchType6"},
{19045, "WatchType7"},
{19046, "WatchType8"},
{19047, "WatchType9"},
{19048, "WatchType10"},
{19049, "WatchType11"},
{19050, "WatchType12"},
{19051, "WatchType13"},
{19052, "WatchType14"},
{19053, "WatchType15"},
{19085, "EyePatch1"},
{19086, "ChainsawDildo1"},
{19090, "PomPomBlue"},
{19091, "PomPomRed"},
{19092, "PomPomGreen"},
{19093, "HardHat2"},
{19094, "BurgerShotHat1"},
{19095, "CowboyHat1"},
{19096, "CowboyHat3"},
{19097, "CowboyHat4"},
{19098, "CowboyHat5"},
{19099, "PoliceCap2"},
{19100, "PoliceCap3"},
{19101, "ArmyHelmet1"},
{19102, "ArmyHelmet2"},
{19103, "ArmyHelmet3"},
{19104, "ArmyHelmet4"},
{19105, "ArmyHelmet5"},
{19106, "ArmyHelmet6"},
{19107, "ArmyHelmet7"},
{19108, "ArmyHelmet8"},
{19109, "ArmyHelmet9"},
{19110, "ArmyHelmet10"},
{19111, "ArmyHelmet11"},
{19112, "ArmyHelmet12"},
{19113, "SillyHelmet1"},
{19114, "SillyHelmet2"},
{19115, "SillyHelmet3"},
{19116, "PlainHelmet1"},
{19117, "PlainHelmet2"},
{19118, "PlainHelmet3"},
{19119, "PlainHelmet4"},
{19120, "PlainHelmet5"},
{19137, "CluckinBellHat1"},
{19138, "PoliceGlasses1"},
{19139, "PoliceGlasses2"},
{19140, "PoliceGlasses3"},
{19141, "SWATHelmet1"},
{19142, "SWATArmour1"},
{19160, "HardHat3"},
{19161, "PoliceHat1"},
{19162, "PoliceHat2"},
{19163, "GimpMask1"},
{19317, "bassguitar01"},
{19318, "flyingv01"},
{19319, "warlock01"},
{19330, "fire_hat01"},
{19331, "fire_hat02"},
{19346, "hotdog01"},
{19347, "badge01"},
{19348, "cane01"},
{19349, "monocle01"},
{19350, "moustache01"},
{19351, "moustache02"},
{19352, "tophat01"},
{19487, "tophat02"},
{19488, "HatBowler6"},
{19513, "whitephone"},
{19515, "GreySwatArm"},
{3044, "Cigar"},
{1210, "Briefcase"}
};

new AttachmentBones[][24] = {
{"Spine"},
{"Head"},
{"Left upper arm"},
{"Right upper arm"},
{"Left hand"},
{"Right hand"},
{"Left thigh"},
{"Right thigh"},
{"Left foot"},
{"Right foot"},
{"Right calf"},
{"Left calf"},
{"Left forearm"},
{"Right forearm"},
{"Left clavicle"},
{"Right clavicle"},
{"Neck"},
{"Jaw"}
};



//VIP Base GATES STATE
new bool:GATEO, bool:GATEC;
//toys defines
#define DIALOG_ATTACH_INDEX             13500
#define DIALOG_ATTACH_INDEX_SELECTION   DIALOG_ATTACH_INDEX+1
#define DIALOG_ATTACH_EDITREPLACE       DIALOG_ATTACH_INDEX+2
#define DIALOG_ATTACH_MODEL_SELECTION   DIALOG_ATTACH_INDEX+3
#define DIALOG_ATTACH_BONE_SELECTION    DIALOG_ATTACH_INDEX+4


    
//colors//
#define GREEN 0x33AA33AA
#define RED 0xAA3333AA
#define YELLOW 0xFFFF00AA
#define BLUE 0x3779BF
#define ORANGE 0xFF9900AA
#define YELEN 0x9ACD32AA

//Stock//
ErrorMessages(playerid, errorID)
{
	if(errorID == 1) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}You are not a VIP");
	if(errorID == 2) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}Player is not connected");
	if(errorID == 3) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}You need to be VIP level 2 or above to use this command");
	if(errorID == 4) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}You need to be VIP level 3 or above to use this command");
	if(errorID == 5) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}You need to be VIP level 4 to use this command");
	if(errorID == 6) return SendClientMessage(playerid,RED,"[EO_VIP]: {FFFFFF}You are not in a vehicle");
	return 1;
}

GetName(playerid) 
{
    new
        pName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
    return pName;
}


//VIP RANDOM MSG
new VIPTips[][] = {
	"[EO_VIP TIP]: {FFFF00}Use {FFFFFF}/vipcmds {FFFF00}to check some useful VIP Commands.",
	"[EO_VIP TIP]: {FFFF00}Check more information about your VIP Level via {FFFFFF}/vipahelp .",
	"[EO_VIP TIP]: {FFFF00}Check your VIP Level stats via {FFFFFF}/vipacc .",
	"[EO_VIP TIP]: {FFFF00}Use {FFFFFF}/vipbs {FFFF00}to enable/disable spawning in VIP Base."
};

//============================================================================================================================
//VIP Vehicles check
IsVIPVehicle(vehicleid) {

	for(new i, j = sizeof(gVIPVehicles); i < j; i++) {
		if(vehicleid == gVIPVehicles[i]) {
		return true;
  		}
    }
   	return false;
}
public OnGameModeInit()
{
    SetGameModeText("EO_VIP System by {FFFF00}E.Oussama");
	//VIP ADVERTISEMENT TIMER
	SetTimer("VIPAT", 18000000, true);// 30 mins
	//VIP TIPS TIMER
	SetTimer("VIPTMSG", 900000, true);// 15 mins

	SetGameModeText("EO VIP SYSTEM");
	// 3D labels 
	Create3DTextLabel("{FFFF00}VIP {FFFFFF}Base\n{FFFFFF}Press {FF00FF}N {FFFFFF}to open the gate", 0x008080FF, 3001.5039, -683.3127, 2.0232, 60, 0, 0);
 	Create3DTextLabel("{FFFF00}VIP {FFFFFF}Lounge\n{FFFFFF}Press {FF00FF}N {FFFFFF}to enter", 0x008080FF, 3024.9241, -692.5798, 3.3770, 60, 0, 1);

	//VIP Lounge Map
	CreateObject(8661, 3022.12695, -672.72382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3022.12695, -653.22382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3061.62695, -653.22382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3061.62695, -672.72382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3061.62695, -692.22382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3022.12695, -692.22382, 0.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3061.62695, -711.72382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3022.12695, -692.22382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8661, 3022.12695, -711.72382, 1.80860,   0.00000, 0.00000, 0.00000);
	CreateObject(8210, 3053.42676, -644.44202, 4.68320,   0.00000, 0.00000, 0.00000);
	CreateObject(8210, 3028.50269, -644.44202, 4.68320,   0.00000, 0.00000, 0.00000);
	CreateObject(8210, 3080.58472, -672.34198, 4.68320,   0.00000, 0.00000, 89.00000);
	CreateObject(8210, 3080.58472, -694.17200, 4.68320,   0.00000, 0.00000, 90.00000);
	CreateObject(8210, 3053.35278, -721.40399, 4.68320,   0.00000, 0.00000, 180.00000);
	CreateObject(8210, 3029.06470, -721.40399, 4.68320,   0.00000, 0.00000, 180.00000);
	CreateObject(3749, 3003.83130, -683.48969, 7.68770,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -656.29919, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -673.96320, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -665.13123, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -704.50720, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -721.43518, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(987, 3003.03687, -713.33917, 1.77550,   0.00000, 0.00000, 90.00000);
	CreateObject(18788, 2983.97705, -683.33478, 0.81030,   0.00000, 0.00000, 0.00000);
	CreateObject(18788, 2960.26514, -683.33478, 0.81030,   0.00000, 0.00000, 0.00000);
	CreateObject(16287, 3072.45190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000);
	CreateObject(16287, 3061.95190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000);
	CreateObject(16287, 3050.95190, -710.08112, 1.79360,   0.00000, 0.00000, 0.00000);
	CreateObject(10831, 3066.83032, -660.64362, 6.29510,   0.00000, 0.00000, -90.00000);
	CreateObject(18850, 3065.63550, -660.40881, 1.78560,   0.00000, 0.00000, 0.00000);
	CreateObject(13749, 3061.92041, -681.63129, 7.07810,   0.00000, 0.00000, -37.00000);
	CreateObject(3605, 3024.24756, -706.26788, 7.87870,   0.00000, 0.00000, 180.00000);
	CreateObject(8838, 3020.13696, -662.13177, 3.29460,   0.00000, 0.00000, 0.00000);
	CreateObject(8838, 3020.13696, -656.63177, 3.29460,   0.00000, 0.00000, 180.00000);
	CreateObject(52, 3025.04810, -693.57910, 2.65190,   0.00000, 0.00000, 0.00000);
	//VIP vehicles
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
    Attach3DTextLabelToVehicle(Create3DTextLabel("VIP {FFFFFF}Vehicle", YELLOW, 0.0, 0.0, -10.0, 15.0, 0, 1), gVIPVehicles[i], 0.0, 0.0, 1.5) && AddVehicleComponent(gVIPVehicles[i], 1010);

	//VIP GATE
    GATE1 = CreateObject(969, 3002.25830, -683.18237, 1.85340,   0.00000, 0.00000, 90.00000);
	GATE2 = CreateObject(969, 3002.25830, -691.98639, 1.85340,   0.00000, 0.00000, 90.00000);
	GATEO = false;
	GATEC = true;
	
	//printf msg
	printf("EO_VIP Lounge Loaded");
	printf("3D Labels sticked to all VIP Vehicles");
	
	return 1;
}

//VIP TIPS MSGS
forward VIPTMSG(playerid);
public VIPTMSG(playerid){
	new rand = random(sizeof(VIPTips));
	for(new i=0; i<MAX_PLAYERS; i++){
	    if(IsPlayerConnected(i) && i != INVALID_PLAYER_ID && VIPInfo[i][VIPLevel] > 0){
			SendClientMessageToAll(GREEN, VIPTips[rand]);
		}
	}
	return 1;
}

//VIP ADVERTISEMENT
forward VIPAT(playerid);
public VIPAT(playerid){
	for(new i=0; i<MAX_PLAYERS; i++){
		if(IsPlayerConnected(i) && i != INVALID_PLAYER_ID && VIPInfo[playerid][VIPLevel] == 0)
			SendClientMessageToAll(GREEN, "[EO_VIP]: {FFFFFF}Buy one of four different VIP Levels and gain countless awesome features");
	}
	return 1;
}
public OnPlayerConnect(playerid)
{
	new Query[75], DBResult:Result;
    SetGameModeText("[EO VIP]: {FF00CC}VIP System by {FFFF00}Oussama");
	VIPInfo[playerid][VIPLoggedIn] = false;

	format(Query, sizeof(Query), "SELECT * FROM `VIPS` WHERE `PlayerName` = '%s'",GetName(playerid));
	Result = db_query(Database, Query);
	if(db_num_rows(Result)){
		db_get_field_assoc(Result, "Gotten_Date", VIPInfo[playerid][VIPGOT], 12);
		VIPInfo[playerid][VIPLevel] = db_get_field_assoc_int(Result, "VIPLevel");
		VIPInfo[playerid][VIPDate] = db_get_field_assoc_int(Result, "Remaining_Days");
		VIPInfo[playerid][VIPBSpawn] = db_get_field_assoc_int(Result, "Spawn_In_Base");
		VIPInfo[playerid][VIPPreset] = db_get_field_assoc_int(Result, "VIP_Weapon_Preset");
		VIPInfo[playerid][WMS] = db_get_field_assoc_int(Result, "Weapon_Melee_Slot");
		VIPInfo[playerid][WPS] = db_get_field_assoc_int(Result, "Weapon_Pistol_Slot");
		VIPInfo[playerid][WSS] = db_get_field_assoc_int(Result, "Weapon_Shotgun_Slot");
		VIPInfo[playerid][WSSL] = db_get_field_assoc_int(Result, "Weapon_SubMachine_Slot");
		VIPInfo[playerid][WAS] = db_get_field_assoc_int(Result, "Weapon_Assault_Slot");
		VIPInfo[playerid][WRS] = db_get_field_assoc_int(Result, "Weapon_Rifle_Slot");
		db_free_result(Result);
		switch(VIPInfo[playerid][VIPLevel]){
			case 1: format(VIPInfo[playerid][VIPAcc], 12, "Silver");
			case 2: format(VIPInfo[playerid][VIPAcc], 12, "Gold");
			case 3: format(VIPInfo[playerid][VIPAcc], 12, "Diamond");
			case 4: format(VIPInfo[playerid][VIPAcc], 12, "Platinum");
		}
		VIPInfo[playerid][VIPLoggedIn] = true;
	}
	else
		db_free_result(Result);

	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	new Query[300];
	format(Query, sizeof(Query), "UPDATE `VIPS` SET `VIPLevel` = %d, `Remaining_Days` = %d, `Spawn_In_Base` = %d, `VIP_Weapon_Preset` = %d, `Weapon_Melee_Slot` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][VIPLevel],VIPInfo[playerid][VIPDate],VIPInfo[playerid][VIPBSpawn],VIPInfo[playerid][VIPPreset],VIPInfo[playerid][WMS],GetName(playerid));
	db_free_result(db_query(Database, Query));
	format(Query, sizeof(Query), "UPDATE `VIPS` SET `Weapon_Pistol_Slot` = %d, `Weapon_Shotgun_Slot` = %d, `Weapon_Assault_Slot` = %d, `Weapon_Rifle_Slot` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][WPS],VIPInfo[playerid][WSS],VIPInfo[playerid][WSSL],VIPInfo[playerid][WAS],VIPInfo[playerid][WRS],GetName(playerid));
	db_free_result(db_query(Database, Query));
	return 1;
}
public OnPlayerSpawn(playerid)
{
    new str[150], pname[MAX_PLAYER_NAME];
   	VIPInfo[playerid][GPAuth] = true;
   	GetPlayerName(playerid, pname, sizeof(pname));
   	if(VIPInfo[playerid][VIPLevel] > 0){
	    format(str, sizeof(str), "Welcome {FFFFFF}%s {FFFF00}, your VIP level is {FFFFFF}%i {FFFF00}|| account type: {FFFFFF}%s {FFFF00}|| Days left: {FFFFFF}%i",pname, VIPInfo[playerid][VIPLevel], VIPInfo[playerid][VIPAcc], VIPInfo[playerid][VIPDate]);
	    SendClientMessage(playerid, YELLOW, str);
	}
	if(VIPInfo[playerid][VIPLevel] > 0) {
    	VIPInfo[playerid][VIPLoggedIn] = true;
    	VIPInfo[playerid][IsVIPInLounge] = false;
    	SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Use {FFFFFF}/vipcmds {FFFF00}to display a useful collection of VIP commands, for information help use {FFFFFF}/viphelp");
	}
	if(VIPInfo[playerid][VIPBSpawn] == 1){
	    SetPlayerPos(playerid, 3049.6392,-668.2963,2.8086);
	    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have spawned at VIP Base, you can change this option via {FFFFFF}/vipbs");
	    return 1;
	}
	if(VIPInfo[playerid][VIPLevel] == 3){
	    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Your Armour has been set to 40%%");
	    SetPlayerArmour(playerid, 40);
	    return 1;
	}
	else if(VIPInfo[playerid][VIPLevel] == 4){
	    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Your Armour has been set to 90%%");
	    SetPlayerArmour(playerid, 90);
	    return 1;
	}
	return 1;
}
//================================================================================================
//===========================================|[COMMANDS]|=========================================
//================================================================================================
CMD:setvip(playerid, params[]) {
	if(IsPlayerAdmin(playerid)){
	    new
	        str[140],
	        Query[500],
	        pgiven[MAX_PLAYER_NAME],
	        aname[MAX_PLAYER_NAME],
	        vlevel,
	        pgID;
	        
	    if(sscanf(params, "ui", pgID, vlevel)) return SendClientMessage(playerid, BLUE, "[USAGE]: {FFFFFF}/setvip (playerid) (VIP level 0-4)") &&
	    SendClientMessage(playerid, BLUE, "[FUNCTION]: {FFFFFF}Will set the Account Type of the Specific Player {92979C}(0-NormalAcc,1-Silver,2-Gold,3-Platinum,4-Diamond)");
		GetPlayerName(playerid, aname, sizeof(aname));
		GetPlayerName(pgID, pgiven, sizeof(pgiven));
		if(!IsPlayerConnected(pgID) || pgID == INVALID_PLAYER_ID) return ErrorMessages(playerid, 2);
		if(vlevel > 4|| vlevel < 0) return SendClientMessage(playerid, BLUE, "INFO: {FFFFFF}Available VIP levels are (1-4)");
		if(vlevel == VIPInfo[pgID][VIPLevel]) return SendClientMessage(playerid,RED,"ERROR: Player is already has this VIP Level!");
		new day, month, year;
		new date[64];
		getdate(year, month, day);
		format(date, sizeof(date), "%s VIP status was set in: %02d %02d %02d",pgiven, day, month, year);
		printf("%s's VIP status was set in: %02d %02d %02d", pgiven, day, month, year);
        switch(vlevel){
			case 1: VIPRank = "Silver";
			case 2: VIPRank = "Gold";
			case 3: VIPRank = "Platinum";
			case 4: VIPRank = "Diamond";
		}
		if(vlevel > 0){
			format(str ,sizeof(str),"[EO_VIP]: {FFFF00}Administrator {FFFFFF}%s {FFFF00}has set your Account Type to: {FFFFFF}%s {FFFF00}|| VIP Level: {FFFFFF}%i", aname, VIPRank, vlevel);
			SendClientMessage(pgID, ORANGE, str);
			GameTextForPlayer(playerid, "VIP Status set!~n~~y~Congratulations", 3000, 6);
			format(str, sizeof(str), "[EO_VIP]: You have set %s VIP level to %i | account type: %s",pgiven, vlevel, VIPRank);
			SendClientMessage(playerid, GREEN, str);
			SendClientMessage(pgID, GREEN, "[EO_VIP]: Your VIP status is available for {FFFFFF}30 days");
			SendClientMessage(pgID, ORANGE, "[EO_VIP]: {FFFF00}Use {FFFFFF}/vipcmds {FFFF00}to display a useful collection of VIP commands, for information help use {FFFFFF}/viphelp");
			VIPInfo[playerid][VIPDay] = day;
			VIPInfo[playerid][VIPMonth] = month;
			VIPInfo[playerid][VIPYear] = year;
			VIPInfo[pgID][VIPLevel] = vlevel;
			VIPInfo[pgID][VIPAcc] = VIPRank;
			VIPInfo[playerid][VIPPreset] = 0;
		 	VIPInfo[playerid][VIPLoggedIn] = true;
			VIPInfo[pgID][VIPDate] = 31;
			format(VIPInfo[pgID][VIPGOT], 12, "%d/%d/%d",day,month,year);
			pVIPRT(playerid);
			format(Query, sizeof(Query), "INSERT INTO `VIPS`(`PlayerName`, `VIPLevel`, `Gotten_Date`, `Remaining_Days`) VALUES('%s', %d, '%s', %d)", GetName(pgID),VIPInfo[pgID][VIPLevel],VIPInfo[pgID][VIPGOT],VIPInfo[pgID][VIPDate]);
			db_free_result(db_query(Database, Query));
			printf("%s Has been set to VIP level %i by administrator %s || account type : %s", pgiven, vlevel, aname, VIPRank);
		}
		if(vlevel == 0){
			format(str, sizeof(str),"[EO_VIP]: {FFFFFF}Administrator {FFFF00}%s {FFFFFF}has removed your VIP status!", aname);
			SendClientMessage(pgID, GREEN, str);
			format(str, sizeof(str), "[EO_VIP]: {FFFFFF}You have removed {FFFF00}%s{FFFFFF}'s VIP status",pgiven, vlevel);
			SendClientMessage(playerid, GREEN, str);
            GameTextForPlayer(playerid, "VIP Status Removed", 3000, 6);
			VIPInfo[pgID][VIPLevel] = 0;
			VIPInfo[pgID][VIPDate] = 0;
			format(VIPInfo[pgID][VIPAcc], 12, "None");
			VIPInfo[playerid][VIPLoggedIn] = false;	
			format(Query, sizeof(Query), "DELETE FROM `VIPS` WHERE `PlayerName` = '%s'", GetName(pgID));
			db_free_result(db_query(Database, Query));
			stop pVIPRT(playerid);		
		}
	}
	else
	    SendClientMessage(playerid, RED, "[ERROR]: you are not authorized to use this command");
	return 1;
}
CMD:vipcount(playerid){
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, RED, "[EO VIP]: {FFFFFF}You are not authorized to use this!");
	new str[70],DBResult:Result,VIPCount;
	format(str, sizeof(str), "SELECT * FROM `VIPS`");
	Result = db_query(Database, str);
	for(new Qr; Qr<db_num_rows(Result);Qr++){
		VIPCount++;
		db_next_row(Result);
	}
	db_free_result(Result);
	format(str, sizeof(str), "[INFO]: {FFFFFF}There are {FFFF00}%d {FFFFFF}VIP Account registered", VIPCount);
	SendClientMessage(playerid, GREEN, str);

	return 1;
}
//=========//1 day play time check//===========================
ptask pVIPRT[86400000](playerid){
	if(VIPInfo[playerid][VIPLoggedIn] == true){
		new Query[300];
		if(VIPInfo[playerid][VIPDate] == 1){
			format(Query, sizeof(Query), "DELETE FROM `VIPS` WHERE `PlayerName` = '%s'", GetName(playerid));
			db_free_result(db_query(Database, Query));
			GameTextForPlayer(playerid, "VIP Status Expired", 3000, 6);
			SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}your VIP status has expired!");
			printf("%s VIP status has been expired!", GetName(playerid));
		}
		else{
			VIPInfo[playerid][VIPDate]--;
			format(Query, sizeof(Query), "UPDATE `VIPS` SET `VIPLevel` = %d, `Remaining_Days` = %d, `Spawn_In_Base` = %d, `VIP_Weapon_Preset` = %d `Weapon_Melee_Slot` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][VIPLevel],VIPInfo[playerid][VIPDate],VIPInfo[playerid][VIPBSpawn],VIPInfo[playerid][VIPPreset],VIPInfo[playerid][WMS],GetName(playerid));
			db_free_result(db_query(Database, Query));
			format(Query, sizeof(Query), "UPDATE `VIPS` SET `Weapon_Pistol_Slot` = %d,`Weapon_Shotgun_Slot` = %d,`Weapon_Assault_Slot` = %d,`Weapon_Rifle_Slot` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][WPS],VIPInfo[playerid][WSS],VIPInfo[playerid][WSSL],VIPInfo[playerid][WAS],VIPInfo[playerid][WRS],GetName(playerid));
			db_free_result(db_query(Database, Query));
			printf("[EO VIP]: %s has passed 1 day of his VIP time", GetName(playerid));
		}
	}
}
//======================================================
timer VIPGPPTimer[60000](pid){
	VIPInfo[pid][CNTUSE] = false;
}
//========================================================
CMD:kill(playerid, o[]) {
	SetPlayerHealth(playerid, 0);
	return 1;
}
//===========//VIP chat//========================================
CMD:vc(playerid, params[]) {

	if(VIPInfo[playerid][VIPLevel] > 0) {
		new msg[100], str[128], pname[MAX_PLAYER_NAME];
		GetPlayerName(playerid, pname,sizeof( pname));
		if(sscanf(params,"s",msg)) return SendClientMessage(playerid, BLUE,"[USAGE]: {FFFFFF}/vc (message)") && SendClientMessage(playerid,BLUE,"[FUNCTION]: {FFFFFF}Use the VIP Chat");
		format(str,sizeof(str),"[VIP CHAT]%s: {72AB88}%s", pname, msg);
		for(new i; i<MAX_PLAYERS; i++){
			if(IsPlayerConnected(i) && VIPInfo[i][VIPLevel] > 0)
 			  	SendClientMessage(i,GREEN,str);
		}
	}
	else
	    ErrorMessages(playerid, 1);
	return 1;
}

//============//VIPS LIST//=======================================
CMD:vips(playerid, params[]) {
	new
	    str[MAX_PLAYER_NAME+1050],
	    Count,
	    pname[MAX_PLAYER_NAME];
 	for(new i=0; i<MAX_PLAYERS; i++){
		if(IsPlayerConnected(i) && VIPInfo[i][VIPLevel] > 0) {
			GetPlayerName(i, pname, sizeof(pname));
   			Count++;
		}
 	}
	if(Count == 0) return SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}There are no VIPs online at the moment!");
	format(str, sizeof(str),"%s | VIP Level: {FFFF00}%i [%s]",pname, VIPInfo[playerid][VIPLevel], VIPInfo[playerid][VIPAcc]);
	ShowPlayerDialog(playerid, DIALOG_AVIPS, DIALOG_STYLE_MSGBOX, "Connected VIPs", str, "Got it!", "");
 	/*SendClientMessage(playerid, YELLOW,"=======================|Connected VIPs|=======================");
	SendClientMessage(playerid, ORANGE, str);
	SendClientMessage(playerid, YELLOW,"==============================================================");*/
	return 1;
}
//=====================//VIP COMMANDS//============================================
CMD:vipcmds(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(VIPInfo[playerid][VIPLevel] == 1) {
			SendClientMessage(playerid, ORANGE, "||================================|| VIP LEVEL 1 COMMANDS [SILVER] ||=================================||");
            SendClientMessage(playerid, YELLOW, "/vipcmds - Display VIP level commands || /vc (message) - Use VIP chat || /vips - List of online VIPs");
            SendClientMessage(playerid, YELEN, "/viphelp - Display usefull information about VIP level || /vipacc - Gives more info about your VIP Account");
            SendClientMessage(playerid, YELLOW, "/viptag - show off your VIP status to public || /flip - Flip your vehicle || /weatherids - check available weather IDs");
            SendClientMessage(playerid, YELEN, "/vipcw - Change the player's weather || /vipt - Changed the player's time || /vipbs - Spawn in base option");
            SendClientMessage(playerid, YELLOW, "/vipgc - Gives money to a player from a far range || /isvip - See someone's VIP Stats || /viptoys - Attach objects to player");
			SendClientMessage(playerid, ORANGE, "||===================================================================================================||");
			return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 2) {
   			SendClientMessage(playerid, ORANGE, "||============================|| VIP LEVEL 2 COMMANDS [GOLD] ||====================================||");
            SendClientMessage(playerid, YELLOW, "/vipcmds - Display VIP level commands || /vc (message) - Use VIP chat || /vips - List of online VIPs");
            SendClientMessage(playerid, YELEN, "/viphelp - Display usefull information about VIP level || /vipacc - Gives more info about your VIP Account");
            SendClientMessage(playerid, YELLOW, "/carc - Changes a vehicle color || /viptag - show off your VIP status to public || /vipgp - weapon pack");
            SendClientMessage(playerid, YELEN, "/vipnos - Add nitrous to a vehicle || /flip - Flip your vehicle || /weatherids - check available weather IDs");
            SendClientMessage(playerid, YELLOW, "/vipcw - Change the player's weather || /vipt - Changed the player's time || /vipbs - Spawn in base option");
            SendClientMessage(playerid, YELEN, "/vipgc - Gives money to a player from a far range || /isvip - See someone's VIP Stats || /viptoys - Attach objects to player");
			SendClientMessage(playerid, ORANGE, "||===================================================================================================||");
            return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 3) {
   			SendClientMessage(playerid, ORANGE, "||=====================|| VIP LEVEL 3 COMMANDS [PLATINUM ||===========================================||");
            SendClientMessage(playerid, YELLOW, "/vipcmds - Display VIP level commands || /vc (message) - Use VIP chat || /vips - List of online VIPs");
            SendClientMessage(playerid, YELEN, "/viphelp - Display usefull information about VIP level || /vipacc - Gives more info about your VIP Account");
            SendClientMessage(playerid, YELLOW, "/carc - Changes a vehicle color || /viptag - show off your VIP status to public || /vipgp - weapon pack");
            SendClientMessage(playerid, YELEN, "/vipnos - Add nitrous to a vehicle || /vipefix - fix your vehicle engine || /flip - Flip your vehicle ");
            SendClientMessage(playerid, YELLOW, "/weatherids - check available weather IDs || /vipcw - Change the player's weather || /vipt - Changed the player's time");
            SendClientMessage(playerid, YELEN, "/vipbs - Spawn in base option || /vipgc - Gives money to a player from a far range || /vipskin - select a new skin to use");
            SendClientMessage(playerid, YELLOW, "/isvip - See someone's VIP Stats || /viptoys - Attach objects to player");
			SendClientMessage(playerid, ORANGE, "||===================================================================================================||");
			return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 4) {
   			SendClientMessage(playerid, ORANGE, "||====================================|| VIP LEVEL 4 COMMANDS [DIAMOND] ||=============================||");
            SendClientMessage(playerid, YELLOW, "/vipcmds - Display VIP level commands || /vc (message) - Use VIP chat || /vips - List of online VIPs");
            SendClientMessage(playerid, YELEN, "/viphelp - Display usefull information about VIP level || /vipacc - Gives more info about your VIP Account");
            SendClientMessage(playerid, YELLOW, "/carc - Changes a vehicle color || /viptag - Show off your VIP status to public || /vipgp - weapon pack");
            SendClientMessage(playerid, YELEN, "/vipnos - Add nitrous to a vehicle || /vipefix - Fix your vehicle engine || /vipbfix - Fix your vehicle body");
            SendClientMessage(playerid, YELLOW, "/flip - Flip your vehicle || /vipbtp - Teleport to VIP base || /weatherids - check available weather IDs");
            SendClientMessage(playerid, YELEN, "/vipcw - Change the player's weather || /vipt - Changed the player's time || /vipbs - Spawn in base option");
            SendClientMessage(playerid, YELLOW, "/vipgc - Gives money to a player from a far range || /vipskin - select a new skin to use || /isvip - See someone's VIP Stats");
            SendClientMessage(playerid, YELEN, "/vipgpp - manage your customized gun pack preset to be able to spawn them via /vipgp || /viptoys - Attach objects to player");
			SendClientMessage(playerid, ORANGE, "||====================================================================================================||");
            return 1;
		}
		return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//==================//VIP HELP//===================================================
CMD:viphelp(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(VIPInfo[playerid][VIPLevel] == 1){
		    ShowPlayerDialog(playerid, DIALOG_VIPHELP, DIALOG_STYLE_MSGBOX, "SILVER VIP Help", "Features:\n\nYou can change up to 2 different weather types.","Got it!","");
		    return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 2){
		    ShowPlayerDialog(playerid, DIALOG_VIPHELP, DIALOG_STYLE_MSGBOX, "GOLD VIP Help", "Features:\n\n/vipgp Gives you 2 weapons.\n\nYou can change up to 3 different weather types.","Got it!","");
		    return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 3){
		    ShowPlayerDialog(playerid, DIALOG_VIPHELP, DIALOG_STYLE_MSGBOX, "PLATINUM VIP Help", "Features:\n\nSpawn with 40%% of Armour.\n\n/vipgp Gives you 3 weapons.\n\nYou can change up to 4 different weather types.\nYou choose between 5 skin via /vipskin.","Got it!","");
			return 1;
		}
		else if(VIPInfo[playerid][VIPLevel] == 4){
			if(VIPInfo[playerid][VIPPreset] == 0){
			    ShowPlayerDialog(playerid, DIALOG_VIPHELP, DIALOG_STYLE_MSGBOX, "DIAMOND VIP Help", "Features:\n\nSpawn with 90%% of Armour.\n\n/vipgp Gives you 4 weapons.\n\nYou can change up to 6 different weather types.\n\nYou choose between 10 skin via /vipskin.","Got it!","");
				return 1;
			}
			else{
	   			// something here
			}
		}
		return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//===================//Account info command//======================================
CMD:vipacc(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    new str[350], pname[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, pname, sizeof(pname));
	    if(VIPInfo[playerid][VIPBSpawn] == 1){
			format(str, sizeof(str), "Name: %s\n\n{FFFFFF}VIP Level: %i || VIP Account: %s\n\nRegistration Date: %i // %i // %i\n\nDays Left: %i\n\nSpawn in VIP Base: YES", pname, VIPInfo[playerid][VIPLevel], VIPInfo[playerid][VIPAcc], VIPInfo[playerid][VIPDay],VIPInfo[playerid][VIPMonth],VIPInfo[playerid][VIPYear], VIPInfo[playerid][VIPDate]);
			ShowPlayerDialog(playerid, DIALOG_VIPINFO, DIALOG_STYLE_MSGBOX, "VIP Account Info", str, "Got it!", "");
	 		return 1;
		}
		else{
		    format(str, sizeof(str), "Name: %s\n\n{FFFFFF}VIP Level: %i || VIP Account: %s\n\nRegistration Date: %i // %i // %i\n\nDays Left: %i\n\nSpawn in VIP Base: NO", pname, VIPInfo[playerid][VIPLevel], VIPInfo[playerid][VIPAcc], VIPInfo[playerid][VIPDay],VIPInfo[playerid][VIPMonth],VIPInfo[playerid][VIPYear], VIPInfo[playerid][VIPDate]);
			ShowPlayerDialog(playerid, DIALOG_VIPINFO, DIALOG_STYLE_MSGBOX, "VIP Account Info", str, "Got it!", "");
		}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//=================//car color//===================================================
CMD:carc(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 1) {
	        new
	            str[95],
	            color1,
	            color2;
	        if(sscanf(params, "ii", color1, color2)) return SendClientMessage(playerid, BLUE, "[USAGE]: {FFFFFF}/carc (color 1)(color 2)") && SendClientMessage(playerid, BLUE, "[FUNCTION]: {FFFFFF}Change a vehicle color");
	        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You need to be in a vehicle");
	        if(color1 > 255 || color1 < 0 || color2 > 255 || color2 < 0) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}Invalid Color ID (Available ID: 0 - 255)");
			if(VIPInfo[playerid][VIPLevel] == 2){
				if(GetPlayerMoney(playerid) < 1000) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford changing this vehicle's color");
			    GivePlayerMoney(playerid, -1000);
			    format(str, sizeof(str), "[EO_VIP]: {FFFF00}Vehicle color changed to ( %i , %i ), you've been charged with {FFFFFF}$1000", color1, color2);
				SendClientMessage(playerid, ORANGE, str);
				ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
			}
			else if(VIPInfo[playerid][VIPLevel] == 3){
			    if(GetPlayerMoney(playerid) < 600) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford changing this vehicle's color");
			    GivePlayerMoney(playerid, -600);
			    format(str, sizeof(str), "[EO_VIP]: {FFFF00}Vehicle color changed to ( %i , %i ), you've been charged with {FFFFFF}$600", color1, color2);
				SendClientMessage(playerid, ORANGE, str);
				ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
			}
			else if(VIPInfo[playerid][VIPLevel] == 4){
			    if(GetPlayerMoney(playerid) < 200) return SendClientMessage(playerid, RED, "[EO_VIP]: You can't afford changing this vehicle's color");
			    GivePlayerMoney(playerid, -200);
			    format(str, sizeof(str), "[EO_VIP]: {FFFF00}Vehicle color changed to ( %i , %i ), you've been charged with {FFFFFF}$200", color1, color2);
				SendClientMessage(playerid, ORANGE, str);
				ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
			}
	    }
	    else {
	        ErrorMessages(playerid, 3);
	    }
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//===================//VIP Vehicle tag//===========================================

CMD:viptag(playerid, params[]) {
	new str[MAX_PLAYER_NAME+21];
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    new Text3D:VIPVEHTAG = Create3DTextLabel( str, YELLOW, 0.0 ,0.0 ,0.0, 0, 0);
		if(VIPInfo[playerid][VIPTAG] == false){
		    format(str, sizeof(str), "VIP {FFFFFF}Level %i", VIPInfo[playerid][VIPLevel]);
			Attach3DTextLabelToPlayer(VIPVEHTAG, playerid, 0.0, 0.0, 2.0);
			SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}You have turned the VIP tag on");
			VIPInfo[playerid][VIPTAG] = true;
		}
		else if(VIPInfo[playerid][VIPTAG] == true){
		    Delete3DTextLabel(VIPVEHTAG);
		    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}You have turned the VIP tag off");
		    VIPInfo[playerid][VIPTAG] = false;
		}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//=======================//Gun Pack command//==========================================

CMD:vipgp(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][GPAuth] == true){
	        if(VIPInfo[playerid][VIPPreset] == 0){
			    switch(VIPInfo[playerid][VIPLevel]){
		  			case 1: return ErrorMessages(playerid, 3);
			        case 2:{
		                GivePlayerWeapon(playerid, 22, 50);
		                GivePlayerWeapon(playerid, 25, 30);
		                SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}VIP Weapon pack given");
		                SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have loaded the default preset of guns, you can create your customized one via {FFFFFF}/vipgpp");
		                VIPInfo[playerid][GPAuth] = false;
						SetTimer("VIPGP", 900000, false);
					}
			        case 3:{
						GivePlayerWeapon(playerid, 4, 1);
						GivePlayerWeapon(playerid, 24, 10);
						GivePlayerWeapon(playerid, 27, 50);
						SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}VIP Weapon pack given");
						SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have loaded the default preset of guns, you can create your customized one via {FFFFFF}/vipgpp");
						VIPInfo[playerid][GPAuth] = false;
						SetTimer("VIPGP", 900000, false);
					}
			        case 4:{
						GivePlayerWeapon(playerid, 9, 1);
						GivePlayerWeapon(playerid, 24, 25);
						GivePlayerWeapon(playerid, 26, 30);
						GivePlayerWeapon(playerid, 31, 100);
						SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}VIP Weapon pack given");
						SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have loaded the default preset of guns, you can create your customized one via {FFFFFF}/vipgpp");
						VIPInfo[playerid][GPAuth] = false;
						SetTimer("VIPGP", 900000, false);
			        }
			    }
			}
			else if(VIPInfo[playerid][VIPPreset] == 1){
				if(VIPInfo[playerid][CNTUSE] == false){
				    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have loaded customized preset of guns, you can manage it anytime via {FFFFFF}/vipgpp");
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WMS], 1);
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WPS], 25);
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WSS], 30);
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WSSL], 40);
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WAS], 100);
				    GivePlayerWeapon(playerid, VIPInfo[playerid][WRS], 15);
				    VIPInfo[playerid][CNTUSE] = true;
				    defer VIPGPPTimer(playerid);
				}
				else
					SendClientMessage(playerid, 0xFF0000, "[EO VIP]: {FFFFFF}Wait before spawning another gun pack");
			}
		}
		else
		    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You have just used that command, please wait for a 15 mins");
	}
	else
		ErrorMessages(playerid, 1);
	return 1;
}
//Gun pack timer
forward VIPGP(playerid);
public VIPGP(playerid){
	VIPInfo[playerid][GPAuth] = true;
	return 1;
}

//====================//VIP GIVE CASH//============================================
CMD:vipgc(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    new str[MAX_PLAYER_NAME+25], pname[MAX_PLAYER_NAME], idname[MAX_PLAYER_NAME], id, cash, cashcheck;
	    GetPlayerName(playerid, pname, sizeof(pname));
	    GetPlayerName(id, idname, sizeof(idname));
	    if(sscanf(params, "ii", id, cash)) return SendClientMessage(playerid, BLUE, "[USAGE]: {FFFFFF}/vipgc (playerid) (cash)") && SendClientMessage(playerid, BLUE, "[FUNCTION]: {FFFFFF}Give a player money from distance");
	    if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID) return ErrorMessages(playerid, 2);
	    cashcheck = GetPlayerMoney(playerid);
	    if(cash < 1) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}Required amount: {92979C}(1-1000000)");
	    if(cashcheck < cash) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You don't have that much money");
	    if(id == playerid) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't give yourself money!");
	    else{
		    GivePlayerMoney(id, cash);
		    GivePlayerMoney(playerid, -cash);
		    format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have given {FFFFFF}%s $%i", idname, cash);
		    SendClientMessage(playerid, ORANGE, str);
		    format(str, sizeof(str), "{FFFFFF}%s {FFFF00}has given you {FFFFFF}$%i", pname, cash);
		    SendClientMessage(id, ORANGE, str);
		    return 1;
	    }
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//==================//VIP NITROUS//================================================

CMD:vipnos(playerid){
	new VehID;
	VehID = GetPlayerVehicleID(playerid);
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 1){
			if(IsPlayerInAnyVehicle(playerid)){
			    switch(VIPInfo[playerid][VIPLevel]){
					case 2:{
					    if(GetPlayerMoney(playerid) >= 1000){
						    GivePlayerMoney(playerid, -1000);
				      		SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have added nitrous to this vehicle, you've been charged with {FFFFFF}$1000");
		    		    	AddVehicleComponent(VehID, 1010);
	    				    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);
				    		return 1;
						}
						else{
						    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford to buy this");
						}
					}
			        case 3:{
			            if(GetPlayerMoney(playerid) >= 600){
		  				    GivePlayerMoney(playerid, -600);
				            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have added nitrous to this vehicle, you've been charged with {FFFFFF}$600");
		    		    	AddVehicleComponent(VehID, 1010);
	    				    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);
				    		return 1;
						}
						else{
						    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford to buy this");
						}
					}
			        case 4:{
			            if(GetPlayerMoney(playerid) >= 150){
		  				    GivePlayerMoney(playerid, -150);
				            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have added nitrous to this vehicle, you've been charged with {FFFFFF}$150");
		    		    	AddVehicleComponent(VehID, 1010);
	    				    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);
				    		return 1;
						}
						else{
						    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford to buy this");
						}
					}
			    }
			}
			else{
				ErrorMessages(playerid, 6);
			}
		}
		else{
	        ErrorMessages(playerid, 3);
		}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP car engine fix//===============================================
CMD:vipefix(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 2) {
	        if(IsPlayerInAnyVehicle(playerid)){
		        new
					VehID = GetPlayerVehicleID(playerid),
					cashcheck = GetPlayerMoney(playerid);
		        switch(VIPInfo[playerid][VIPLevel]){
		            case 3:{
		            	if(cashcheck >= 600){
			                SetVehicleHealth(VehID, 1000);
			                GivePlayerMoney(playerid, -600);
			                SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}vehicle fixed, you've been charged with {FFFFFF}$600");
						}
						else{
						    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford that");
						}
		            }
		            case 4:{
		                if(cashcheck >= 150){
			                SetVehicleHealth(VehID, 1000);
			                GivePlayerMoney(playerid, -150);
			                SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}vehicle fixed, you've been charged with {FFFFFF}$150");
						}
						else{
						    SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford that");
						}
		            }
		        }
		        PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);
			}
			else{
			    ErrorMessages(playerid, 6);
			}
	    }
	    else {
     		ErrorMessages(playerid, 4);
	    }
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP body fix//===============================================
CMD:vipbfix(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
 		if(VIPInfo[playerid][VIPLevel] > 3) {
   			if(IsPlayerInAnyVehicle(playerid)){
      			new
					VehID = GetPlayerVehicleID(playerid),
					cashcheck = GetPlayerMoney(playerid);
  				if(cashcheck >= 600){
  				 	RepairVehicle(VehID);
  				 	GivePlayerMoney(playerid, -200);
 					SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}vehicle fixed, you've been charged with {FFFFFF}$200");
 					PlayerPlaySound(playerid, 1133, 0.0, 0.0, 10.0);
 					return 1;
				}
				else{
	    			SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You can't afford that");
				}
			}
			else{
    			ErrorMessages(playerid, 6);
			}
    	}
    	else {
    		ErrorMessages(playerid, 4);
    	}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//=================// flip a vehicle//=============================================

CMD:flip(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
 		if(IsPlayerInAnyVehicle(playerid))
	  	{
		    new currentveh;
		    new Float:angle;
		    currentveh = GetPlayerVehicleID(playerid);
		    GetVehicleZAngle(currentveh, angle);
		    SetVehicleZAngle(currentveh, angle);
		    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}Your vehicle has been flipped");
	     	return 1;
	  	}
	  	else
	  	{
	    	SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}You are not in any vehicle!");
	    	return 1;
	  	}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//===============// BASE TP//=============================
CMD:vipbtp(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(VIPInfo[playerid][VIPLevel] > 3) {
		    SetPlayerPos(playerid, 3049.6392,-668.2963,2.8086);
		    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}You have teleported to the VIP Base!");
	    }
    	else {
			ErrorMessages(playerid, 5);
	    }
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//weather changer//===============================================
CMD:vipcw(playerid, params[]) {
	new wid, str[65];
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(sscanf(params, "i", wid)) return SendClientMessage(playerid, BLUE ,"[USAGE]: {FFFFFF}vipcw (Weather ID)") && SendClientMessage(playerid, BLUE ,"[FUNCTION]: {FFFFFF}Change your weather");
		switch(VIPInfo[playerid][VIPLevel]){
  			case 1:{
				if(wid > 2 || wid < 1) return SendClientMessage(playerid, RED,"[EO_VIP]: {FFFFFF}Available Weather IDs are {92979C}(1-2)");
			 	else{
 	    			format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have set the weather ID to {FFFFFF}%i", wid);
					SendClientMessage(playerid, ORANGE,str);
					SetPlayerWeather(playerid, wid);
				}
			}
			case 2:{
				if(wid > 3 || wid < 1) return SendClientMessage(playerid, RED ,"[EO_VIP]: {FFFFFF}Available Weather IDs are {92979C}(1-3)");
			 	else{
 	    			format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have set the weather ID to {FFFFFF}%i", wid);
					SendClientMessage(playerid, ORANGE ,str);
					SetPlayerWeather(playerid, wid);
				}
			}
			case 3:{
				if(wid > 4 || wid < 1) return SendClientMessage(playerid, RED,"[EO_VIP]: {FFFFFF}Available Weather IDs are {92979C}(1-4)");
			 	else{
 	    			format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have set the weather ID to {FFFFFF}%i", wid);
					SendClientMessage(playerid, ORANGE,str);
					SetPlayerWeather(playerid, wid);
				}
			}
			case 4:{
				if(wid > 6 || wid < 1) return SendClientMessage(playerid, RED ,"[EO_VIP]: {FFFFFF}Available Weather IDs are {92979C}(1-6)");
			 	else{
 	    			format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have set the weather ID to {FFFFFF}%i", wid);
					SendClientMessage(playerid, ORANGE ,str);
					SetPlayerWeather(playerid, wid);
				}
			}
		}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//weather IDs commands dialog//===================================
CMD:weatherids(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] == 1) {
	        ShowPlayerDialog(playerid, DIALOG_WEATHERID, DIALOG_STYLE_MSGBOX, "Weather IDs", "{FFFF00}1- {FFFFFF}Sunny\n\n{FFFF00}2- {FFFFFF}Extra Sunny Smog", "Got it!", "");
			return 1;
	    }
	    else if(VIPInfo[playerid][VIPLevel] == 2) {
	        ShowPlayerDialog(playerid, DIALOG_WEATHERID, DIALOG_STYLE_MSGBOX, "Weather IDs", "{FFFF00}1- {FFFFFF}Sunny\n\n{FFFF00}2- {FFFFFF}Extra Sunny Smog\n\n{FFFF00}3- {FFFFFF}Sunny Smog", "Got it!", "");
			return 1;
	    }
	    else if(VIPInfo[playerid][VIPLevel] == 3) {
	        ShowPlayerDialog(playerid, DIALOG_WEATHERID, DIALOG_STYLE_MSGBOX, "Weather IDs", "{FFFF00}1- {FFFFFF}Sunny\n\n{FFFF00}2- {FFFFFF}Extra Sunny Smog\n\n{FFFF00}3- {FFFFFF}Sunny Smog\n\n{FFFF00}4- {FFFFFF}Cloudy", "Got it!", "");
			return 1;
	    }
	    else if(VIPInfo[playerid][VIPLevel] == 4) {
	        ShowPlayerDialog(playerid, DIALOG_WEATHERID, DIALOG_STYLE_MSGBOX, "Weather IDs", "{FFFF00}1- {FFFFFF}Sunny\n\n{FFFF00}2- {FFFFFF}Extra Sunny Smog\n\n{FFFF00}3- {FFFFFF}Sunny Smog\n\n{FFFF00}4- {FFFFFF}Cloudy\n\n{FFFF00}5- {FFFFFF}Summer Sun\n\n{FFFF00}6- {FFFFFF}Summer Extra Sunny", "Got it!", "");
			return 1;
	    }
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP SPAWN IN BASE//===============================================
CMD:vipbs(playerid){
    if(VIPInfo[playerid][VIPLevel] > 0){
    	if(VIPInfo[playerid][VIPBSpawn] == 0){
	        ShowPlayerDialog(playerid, DIALOG_VIPBS, DIALOG_STYLE_MSGBOX, "VIP Base Spawn Option", "Do you want to always spawn in VIP Base?\n\n{FFFFAA}You can change this this anytime with /vipbs", "Yes", "No");
		}
		else if(VIPInfo[playerid][VIPBSpawn] == 1){
		    ShowPlayerDialog(playerid, DIALOG_VIPBSY, DIALOG_STYLE_MSGBOX, "VIP Base Spawn Option", "Do you want to disable Spawning in VIP base option?\n\n{FFFFAA}You can change this this anytime with /vipbs", "Yes", "No");
		}
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}

//================//VIP Time set//===============================================
CMD:vipt(playerid, params[]){
	new H, M, str[50];
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(sscanf(params, "ii", H, M)) return SendClientMessage(playerid, BLUE, "[USAGE]: {FFFFFF}/vipt (Hours) (Minutes)") && SendClientMessage(playerid, BLUE, "[FUNCTION]: {FFFFFF}Change your Time");
	    if(H > 23 || H < 0 || M > 59 || M < 0) return SendClientMessage(playerid, RED, "[EO_VIP]: {FFFFFF}Hours(23-0) || Minutes(59-0)");
	    format(str, sizeof(str), "[EO_VIP]: {FFFF00}You have set the time to {FFFFFF}%02d:%02d", H, M);
	    SendClientMessage(playerid, ORANGE, str);
	    SetPlayerTime(playerid, H, M);
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}

//================//VIP LVL 3 CMDS//===============================================
CMD:vipskin(playerid) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 2) {
	        if(VIPInfo[playerid][VIPLevel] == 3){
				ShowPlayerDialog(playerid, DIALOG_VIPSKIN, DIALOG_STYLE_LIST, "VIP SKINS SELECTION [PLATINUM]",
				"Maccer\n\
				Andre\n\
				Rich Woman\n\
				CJ\n\
				Stunner\n",
				"Select", "Cancel");
			    return 1;
			}
			else if(VIPInfo[playerid][VIPLevel] == 4){
				ShowPlayerDialog(playerid, DIALOG_VIPSKIN, DIALOG_STYLE_LIST, "VIP SKINS SELECTION [DIAMOND]",
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
			    return 1;
			}
		}
	    else {
     		ErrorMessages(playerid, 4);
	    }
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//=======================//Is VIP//================================================
CMD:isvip(playerid, params[]){
    new str1[MAX_PLAYER_NAME],str[MAX_PLAYER_NAME+12], tid, tname[MAX_PLAYER_NAME];
	if(sscanf(params, "i", tid)) return SendClientMessage(playerid, BLUE, "[USAGE]: {FFFFFF}/isvip (playerid)") && SendClientMessage(playerid, BLUE, "[FUNCTION]: {FFFFFF}Shows a players VIP Status");
	else if(!IsPlayerConnected(tid) || tid == INVALID_PLAYER_ID) return ErrorMessages(playerid, 2);
	else{
		GetPlayerName(tid, tname, sizeof(tname));
		format(str, sizeof(str), "VIP Level:%i\n\nAccount Type: %s", VIPInfo[tid][VIPLevel], VIPInfo[tid][VIPAcc]);
		format(str1, sizeof(str1), "%s's VIP Stats", tname);
		ShowPlayerDialog(playerid, DIALOG_ISVIP, DIALOG_STYLE_MSGBOX, str1, str, "Got it!", "");
	}
	return 1;
}
//================//VIP LVL 4 WEAPONS PRESETS//===============================================
CMD:vipgpp(playerid){
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(VIPInfo[playerid][VIPLevel] > 3){
		    if(VIPInfo[playerid][VIPPreset] == 0){
		    	ShowPlayerDialog(playerid, DIALOG_VIP4WP, DIALOG_STYLE_MSGBOX, "VIP GunPack Preset Option", "Here you can make a new Gunpack set to spawn via {FFFFFF}/vipgp\n\n{FFFF00}You Don't have a GunPack Preset yet, do you want to create one?", "Yes", "No");
			}
			else if(VIPInfo[playerid][VIPPreset] == 1){
			    ShowPlayerDialog(playerid, DIALOG_VIP4WPE, DIALOG_STYLE_LIST, "VIP GunPack Preset Option",
				"Edit\n\
				Delete\n",
				"Select", "Cancel");
			}
		}
    	else {
			ErrorMessages(playerid, 5);
	    }
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP TOYS//===============================================
CMD:viptoys(playerid){
    if(VIPInfo[playerid][VIPLevel] > 0){
        new string[128];
        for(new x;x<MAX_PLAYER_ATTACHED_OBJECTS;x++)
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, x)) format(string, sizeof(string), "%s%d (Used)\n", string, x);
            else format(string, sizeof(string), "%s%d\n", string, x);
        }
        ShowPlayerDialog(playerid, DIALOG_ATTACH_INDEX_SELECTION, DIALOG_STYLE_LIST, \
        "{FFFF00}Toy Selection Panel", string, "Select", "Cancel");
        return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}


//================//VIP LVL 1 CMDS//===============================================
CMD:exp1(playerid, params[]){
    if(VIPInfo[playerid][VIPLevel] > 0){
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}

//================//VIP LVL 2 CMDS//===============================================
CMD:exp2(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 1) {
	    }
	    else {
	        ErrorMessages(playerid, 3);
	    }
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP LVL 3 CMDS//===============================================
CMD:exp3(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
	    if(VIPInfo[playerid][VIPLevel] > 2) {
	    
	    }
	    else {
     		ErrorMessages(playerid, 4);
	    }
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================//VIP LVL 4 CMDS//===============================================
CMD:exp4(playerid, params[]) {
	if(VIPInfo[playerid][VIPLevel] > 0) {
		if(VIPInfo[playerid][VIPLevel] > 3) {
	    }
    	else {
			ErrorMessages(playerid, 5);
	    }
	    return 1;
	}
	else {
	    ErrorMessages(playerid, 1);
	}
	return 1;
}
//================================================================================
public OnPlayerStateChange(playerid, newstate, oldstate)
{
    new VehID = GetPlayerVehicleID(playerid);
	if(newstate == PLAYER_STATE_DRIVER && IsVIPVehicle(VehID)) {
 		if(VIPInfo[playerid][VIPLevel] > 0){
	        SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Welcome to VIP Vehicle");
	        return 1;
    	}
    	else{
	        ErrorMessages(playerid, 1);
	        RemovePlayerFromVehicle(playerid);
		}

	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_NO){
	    if(VIPInfo[playerid][VIPLevel] > 0){
	        if(IsPlayerInRangeOfPoint(playerid, 5, 3002.21167, -683.31982, 1.99770)){
	            if(GATEC == true){
	          		GATEO = true;
		            GATEC = false;
		            MoveObject(GATE1, 3002.3396, -677.6714, 1.9951, 3.0);
		            MoveObject(GATE2, 3002.3396, -697.8354, 1.9951, 3.0);
		            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}VIP Base door is Opening");
		            PlayerPlaySound(playerid, 1100, 0.0, 0.0, 0.0);
		            SetTimer("GateCloseTimer", 6000, false);
		            return 1;
				}
				else if(GATEO == true){
  					GATEO = false;
		            GATEC = true;
		            MoveObject(GATE1, 3002.3396, -683.2094, 1.9951, 3.0);
		            MoveObject(GATE2, 3002.3396, -692.0134, 1.9951, 3.0);
		            PlayerPlaySound(playerid, 1100, 0.0, 0.0, 0.0);
		    		SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}VIP Base door is Closing");
				    return 1;
				}
	        }
	        else if(IsPlayerInRangeOfPoint(playerid, 2, 3024.9241, -692.5798, 3.3770)){
	            new str[MAX_PLAYER_NAME+34], pname[MAX_PLAYER_NAME];
	            GetPlayerName(playerid, pname, sizeof(pname));
	            format(str, sizeof(str), "[VIP Lounge]: {FFFF00}VIP {FFFFFF}%s{FFFF00} has entered The VIP Lounge", pname);
    			for(new i=0; i<MAX_PLAYERS; i++){
					if(IsPlayerConnected(i) && VIPInfo[i][VIPLevel] > 0 && VIPInfo[playerid][IsVIPInLounge] == true) {
    					SendClientMessage(playerid, ORANGE, str);
 				    }
				}
	            SetPlayerInterior(playerid, 3);
	            SetPlayerPos(playerid, 942.171997,-16.542755,1000.929687);
	            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}press {FFFFFF}N {FFFF00}to get outside");
	            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Welcome to the VIP Lounge");
	            VIPInfo[playerid][IsVIPInLounge] = true;
	            return 1;
	        }
	        else if(IsPlayerInRangeOfPoint(playerid, 2, 942.1549,-16.8236,1000.9297)){
                new str[MAX_PLAYER_NAME+34], pname[MAX_PLAYER_NAME];
	            GetPlayerName(playerid, pname, sizeof(pname));
	            format(str, sizeof(str), "[VIP Lounge]: {FFFF00}VIP {FFFFFF}%s {FFFF00}has left The VIP Lounge", pname);
	            SetPlayerInterior(playerid, 0);
	            SetPlayerPos(playerid, 3024.9241, -692.5798, 3.3770);
	            VIPInfo[playerid][IsVIPInLounge] = false;
				for(new i=0; i<MAX_PLAYERS; i++){
					if(IsPlayerConnected(i) && VIPInfo[i][VIPLevel] > 0 && VIPInfo[playerid][IsVIPInLounge] == true) {
    					SendClientMessage(playerid, GREEN, str);
					}
				}
	            return 1;
	        }
	    }
	    else{
	        ErrorMessages(playerid, 1);
	    }
	}
	return 1;
}
forward GateCloseTimer(playerid);
public GateCloseTimer(playerid){
	GATEO = false;
 	GATEC = true;
 	MoveObject(GATE1, 3002.3396, -683.2094, 1.9951, 3.0);
 	MoveObject(GATE2, 3002.3396, -692.0134, 1.9951, 3.0);
 	if(GetPlayerInterior(playerid) == 0){
 		PlayerPlaySound(playerid, 1100, 0.0, 0.0, 0.0);
 		return 1;
 	}
 	return 1;
}
public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new Query[300];
	switch(dialogid){
	    case DIALOG_VIPBS:{
	        if(response){
		        VIPInfo[playerid][VIPBSpawn] = 1;
		        SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You will be spawned at VIP Base from now on, you can change this option via {FFFFFF}/vipbs");
		        format(Query, sizeof(Query), "UPDATE `VIPS` SET `Spawn_In_Base` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][VIPBSpawn],GetName(playerid));
				db_free_result(db_query(Database, Query));
				return 1;
			}
		}
	    case DIALOG_VIPBSY:{
	    	if(response){
		        VIPInfo[playerid][VIPBSpawn] = 0;
		        SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have disabled VIP Base spawn option, you can change this option via {FFFFFF}/vipbs");
				format(Query, sizeof(Query), "UPDATE `VIPS` SET `Spawn_In_Base` = %d WHERE `PlayerName` = '%s'",VIPInfo[playerid][VIPBSpawn],GetName(playerid));
				db_free_result(db_query(Database, Query));
				return 1;
			}
		}
		case DIALOG_VIP4WP:{
		    if(response){
		        ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Cancel");
		        return 1;
		    }
		    else{
		        SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Gun Pack Preset Creation was canceled");
		    }
		}
		case DIALOG_VIP4WPCR:{
		    if(response){
  				VIPInfo[playerid][VIPPreset] = 0;
				format(Query, sizeof(Query), "UPDATE `VIPS` SET `VIP_Weapon_Preset` = 0, `Weapon_Melee_Slot` = 0, `Weapon_Pistol_Slot` = 0, `Weapon_Shotgun_Slot` = 0, `Weapon_Assault_Slot` = 0, `Weapon_Rifle_Slot` = 0 WHERE `PlayerName` = '%s'",GetName(playerid));
				db_free_result(db_query(Database, Query));
	            SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}Gun Pack Custom Preset is removed, you can re-create it anytime via {FFFFFF}/vipgpp");
			}
			else{
			    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}VIP gun pack preset removing is canceled");
			}
		}
		case DIALOG_ATTACH_INDEX_SELECTION:
        {
            if(response)
            {
                if(IsPlayerAttachedObjectSlotUsed(playerid, listitem))
                {
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_EDITREPLACE, DIALOG_STYLE_MSGBOX, \
                    "{FFFF00}Attachment Edit", "{FFFFFF}Do you want to edit/delete this slot?", "Edit", "Delete");
                }
                else
                {
                    new string[4000+1];
                    for(new x;x<sizeof(AttachmentObjects);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentObjects[x][attachname]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_MODEL_SELECTION, DIALOG_STYLE_LIST, \
                    "{FFFF00}Toy Selection", string, "Select", "Cancel");
                }
                SetPVarInt(playerid, "AttachmentIndexSel", listitem);
            }
            return 1;
        }
        case DIALOG_ATTACH_EDITREPLACE:
        {
            if(response) EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            else RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
            DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_MODEL_SELECTION:
        {
            if(response)
            {
                if(GetPVarInt(playerid, "AttachmentUsed") == 1) EditAttachedObject(playerid, listitem);
                else
                {
                    SetPVarInt(playerid, "AttachmentModelSel", AttachmentObjects[listitem][attachmodel]);
                    new string[256+1];
                    for(new x;x<sizeof(AttachmentBones);x++)
                    {
                        format(string, sizeof(string), "%s%s\n", string, AttachmentBones[x]);
                    }
                    ShowPlayerDialog(playerid, DIALOG_ATTACH_BONE_SELECTION, DIALOG_STYLE_LIST, \
                    "{FFFF00}Toy Edit - Bone Selection", string, "Select", "Cancel");
                }
            }
            else DeletePVar(playerid, "AttachmentIndexSel");
            return 1;
        }
        case DIALOG_ATTACH_BONE_SELECTION:
        {
            if(response)
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"), GetPVarInt(playerid, "AttachmentModelSel"), listitem+1);
                EditAttachedObject(playerid, GetPVarInt(playerid, "AttachmentIndexSel"));
                SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFF00}Use {FFFFFF}~k~~PED_SPRINT~{FFFF00} to look around.");
            }
            DeletePVar(playerid, "AttachmentIndexSel");
            DeletePVar(playerid, "AttachmentModelSel");
            return 1;
        }
	}
	if(dialogid == DIALOG_VIPSKIN){
  		if(response){
  			switch(listitem){
				case 0: SetPlayerSkin(playerid, 2) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Maccer ID:2)");
				case 1: SetPlayerSkin(playerid, 3) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Andre ID:3)");
				case 2: SetPlayerSkin(playerid, 12) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Rich Woman ID:12)");
				case 3: SetPlayerSkin(playerid, 0) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(CJ ID:0)");
				case 4: SetPlayerSkin(playerid, 45) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Stunner ID:45)");
				case 5: SetPlayerSkin(playerid, 86) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Ryder ID:86)");
				case 6: SetPlayerSkin(playerid, 120) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Triad Boss ID:120)");
				case 7: SetPlayerSkin(playerid, 149) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Bigsmoke ID:149)");
				case 8: SetPlayerSkin(playerid, 167) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Cluckin's bell worker ID:167)");
				case 9: SetPlayerSkin(playerid, 192) && SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFF00}You have set your skin to {92979C}(Michelle ID:192)");
			}
		}
	}
	else if(dialogid == DIALOG_VIP4WPC){
	    if(response){
 			switch(listitem){
		        case 0: ShowPlayerDialog(playerid, DIALOG_VIP4WP0, DIALOG_STYLE_LIST, "VIP GunPack - Melee slot",
						"Knife\n\
						Baseball bat\n\
						Shovel\n\
						Pool cue\n\
						Katana\n\
						Chainsaw", "Select", "");
		        case 1: ShowPlayerDialog(playerid, DIALOG_VIP4WP1, DIALOG_STYLE_LIST, "VIP GunPack - Pistol slot",
						"Pistol 9mm\n\
						Silenced 9mm\n\
						Desert eagle", "Select", "");
		        case 2: ShowPlayerDialog(playerid, DIALOG_VIP4WP2, DIALOG_STYLE_LIST, "VIP GunPack - Shotgun slot",
						"Shotgun\n\
						Swan-off Shotgun\n\
						Combat Shotgun", "Select", "");
		        case 3: ShowPlayerDialog(playerid, DIALOG_VIP4WP3, DIALOG_STYLE_LIST, "VIP GunPack - Sub-Machine slot",
						"Micro-UZI\n\
						MP5\n\
						Tec-9", "Select", "");
		        case 4: ShowPlayerDialog(playerid, DIALOG_VIP4WP4, DIALOG_STYLE_LIST, "VIP GunPack - Assault slot",
						"AK-47\n\
						M4", "Select", "");
				case 5: ShowPlayerDialog(playerid, DIALOG_VIP4WP5, DIALOG_STYLE_LIST, "VIP GunPack - Rifle slot",
						"Country Rifle\n\
						Sniper Rifle", "Select", "");
    		}
		}
		else
		    SendClientMessage(playerid, ORANGE, "[EO_VIP]: {FFFFFF}Gun Pack Preset successfully Created!");
	}
	else if(dialogid == DIALOG_VIP4WP0){//Melee weapons
	    if(response){
			switch(listitem){
  				case 0:{
	         		VIPInfo[playerid][WMS] = 4;
		          	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Knife selected");
				}
		        case 1:{
	       			VIPInfo[playerid][WMS] = 5;
		          	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Baseball bat selected");
		        }
		        case 2:{
	       			VIPInfo[playerid][WMS] = 6;
		          	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Shovel selected");
		        }
		        case 3:{
	       			VIPInfo[playerid][WMS] = 7;
		          	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Pool cue selected");
		        }
		        case 4:{
	 				VIPInfo[playerid][WMS] = 8;
		            SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Katana selected");
		        }
		        case 5:{
	 				VIPInfo[playerid][WMS] = 9;
		            SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Chainsaw selected");
		        }
            }
            VIPInfo[playerid][VIPPreset] = 1;
   			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WP1){//Pistol weapons
	    if(response){
  			switch(listitem){
		   		case 0:{
         			VIPInfo[playerid][WPS] = 22;
		            SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Pistol 9mm selected");
				}
			    case 1:{
		       		VIPInfo[playerid][WPS] = 23;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Silenced 9mm selected");
			    }
			    case 2:{
		       		VIPInfo[playerid][WPS] = 24;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Desert eagle selected");
       			}
			}
			VIPInfo[playerid][VIPPreset] = 1;
			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WP2){//Shotgun weapons
	    if(response){
	    	switch(listitem){
       			case 0:{
		         	VIPInfo[playerid][WSS] = 25;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Shotgun selected");
				}
     			case 1:{
		       		VIPInfo[playerid][WSS] = 26;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Swan-off Shotgun selected");
			    }
     			case 2:{
		       		VIPInfo[playerid][WSS] = 27;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Combat Shotgun selected");
	     		}
		    }
		    VIPInfo[playerid][VIPPreset] = 1;
   			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WP3){//Sub-Machines weapons
	    if(response){
	    	switch(listitem){
			    case 0:{
     				VIPInfo[playerid][WSSL] = 28;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Micro-UZI selected");
				}
    			case 1:{
		       		VIPInfo[playerid][WSSL] = 29;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}MP5 selected");
 				}
				case 2:{
 					VIPInfo[playerid][WSSL] = 32;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Tec-9 selected");
     			}
			}
	    	VIPInfo[playerid][VIPPreset] = 1;
			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WP4){//Assault weapons
	    if(response){
	    	switch(listitem){
      			case 0:{
       				VIPInfo[playerid][WAS] = 30;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}AK-47 selected");
				}
			    case 1:{
		       		VIPInfo[playerid][WAS] =31;
			        SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}M4 selected");
			    }
			}
			VIPInfo[playerid][VIPPreset] = 1;
			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WP5){//Rifle weapons
	    if(response){
			switch(listitem){
				case 0:{
	         		VIPInfo[playerid][WRS] = 330;
		           	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Country rifle selected");
				}
			 	case 1:{
			       	VIPInfo[playerid][WRS] =34;
	            	SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Sniper rifle selected");
	 			}
			}
			VIPInfo[playerid][VIPPreset] = 1;
			ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
		}
	}
	else if(dialogid == DIALOG_VIP4WPE){
	    if(response){
	        switch(listitem){
	            case 0: ShowPlayerDialog(playerid, DIALOG_VIP4WPC, DIALOG_STYLE_LIST, "VIP GunPack Preset Creation",
				"Melee\n\
				Pistols\n\
				Shotguns\n\
				Sub-Machines\n\
				Assault\n\
				Rifles"
				,"Select", "Done");
	            case 1: ShowPlayerDialog(playerid, DIALOG_VIP4WPCR, DIALOG_STYLE_MSGBOX, "VIP GunPack Preset Remove", "{FF0000}Do you want to delete your custom gun pack preset?\n\n{FFFF00}You can recreate it anytime again via {FFFFFF}/vipgpp", "Yes", "Cancel");
	        }
		}
 	}
	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    new str1[MAX_PLAYER_NAME],str[MAX_PLAYER_NAME+12], tid, tname[MAX_PLAYER_NAME];
	GetPlayerName(tid, tname, sizeof(tname));
	format(str, sizeof(str), "VIP Level:%i\n\nAccount Type: %s", VIPInfo[tid][VIPLevel], VIPInfo[tid][VIPAcc]);
	format(str1, sizeof(str1), "%s's VIP Stats", tname);
	ShowPlayerDialog(playerid, DIALOG_ISVIP, DIALOG_STYLE_MSGBOX, str1, str, "Got it!", "");
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid,Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,Float:fRotX, Float:fRotY, Float:fRotZ,Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
 	VIPInfo[playerid][pindex] = index;
	VIPInfo[playerid][pmodelid] = modelid;
	VIPInfo[playerid][pboneid] = boneid;
	VIPInfo[playerid][pfOffsetX] = fOffsetX;
	VIPInfo[playerid][pfOffsetY] = fOffsetY;
	VIPInfo[playerid][pfOffsetZ] = fOffsetZ;
	VIPInfo[playerid][pfRotX] = fRotX;
	VIPInfo[playerid][pfRotY] = fRotY;
	VIPInfo[playerid][pfRotZ] = fRotZ;
	VIPInfo[playerid][pfScaleX] = fScaleX;
	VIPInfo[playerid][pfScaleY] = fScaleY;
	VIPInfo[playerid][pfScaleZ] = fScaleZ;
    SetPlayerAttachedObject(playerid,index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);
    SendClientMessage(playerid, GREEN, "[EO_VIP]: {FFFFFF}Toys Attachment finished");

    return 1;
}

