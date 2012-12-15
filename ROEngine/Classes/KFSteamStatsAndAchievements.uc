//=============================================================================
// KFSteamStatsAndAchievements
//=============================================================================
// Interface between Steam Stats/Achievements and Killing Floor
//=============================================================================
// Killing Floor
// Copyright (C) 2003-2012 Tripwire Interactive LLC
// Created by Dayle Flowers
//=============================================================================

class KFSteamStatsAndAchievements extends SteamStatsAndAchievementsBase
	native;

//=============================================================================
// Stats
//=============================================================================
const KFSTAT_DamageHealed					= 0;
const KFSTAT_WeldingPoints					= 1;
const KFSTAT_ShotgunDamage					= 2;
const KFSTAT_HeadshotKills					= 3;
const KFSTAT_StalkerKills					= 4;
const KFSTAT_BullpupDamage					= 5;
const KFSTAT_MeleeDamage					= 6;
const KFSTAT_FlameThrowerDamage				= 7;
const KFSTAT_SelfHeals						= 8;
const KFSTAT_SoleSurvivorWaves				= 9;
const KFSTAT_CashDonated					= 10;
const KFSTAT_FeedingKills					= 11;
const KFSTAT_BurningCrossbowKills			= 12;
const KFSTAT_GibbedFleshpounds				= 13;
const KFSTAT_StalkersKilledWithExplosives	= 14;
const KFSTAT_GibbedEnemies					= 15;
const KFSTAT_SirensKilledWithExplosives		= 16;
const KFSTAT_BloatKills						= 17;
const KFSTAT_TotalZedTime					= 18;
const KFSTAT_SirenKills						= 19;
const KFSTAT_Kills							= 20;
const KFSTAT_ExplosivesDamage				= 21;
const KFSTAT_DemolitionsPipebombKills		= 22;
const KFSTAT_EnemiesGibbedWithM79			= 23;
const KFSTAT_EnemiesKilledWithSCAR			= 24;
const KFSTAT_TeammatesHealedWithMP7			= 25;
const KFSTAT_FleshpoundsKilledWithAA12		= 26;
const KFSTAT_CrawlersKilledInMidair			= 27;
const KFSTAT_Mac10BurnDamage				= 28;
const KFSTAT_DroppedTier3Weapons			= 29;
const KFSTAT_HalloweenKills					= 30;
const KFSTAT_HalloweenScrakeKills			= 31;
const KFSTAT_XMasHusksKilledWithHuskCannon	= 32;
const KFSTAT_XMasPointsHealedWithMP5		= 33;
const KFSTAT_EnemiesKilledWithFNFal			= 41;
const KFSTAT_EnemiesKilledWithBullpup		= 42;
const KFSTAT_EnemiesKilledWithTrenchOnHillbilly			= 43;
const KFSTAT_EnemiesKilledDuringHillbilly	= 44;
const KFSTAT_HillbillyAchievementsCompleted	= 45;
const KFSTAT_Stat46	= 46; //this is the stat used to determine what event we're on
const KFSTAT_FleshPoundsKilledWithAxe	    = 47;
const KFSTAT_ZedsKilledWhileAirborne     	= 48;
const KFSTAT_ZEDSKilledWhileZapped      	= 49;
const KFSTAT_OwnedWeaponDLC					= 200;
//These values end up going through a byte at some point.  Don't make the values too big.
//Yes this is here because it's happened before.

// Perk Stats
var	const SteamStatInt	DamageHealedStat;
var	int					SavedDamageHealedStat;
var	const SteamStatInt	WeldingPointsStat;
var	int					SavedWeldingPointsStat;
var	const SteamStatInt	ShotgunDamageStat;
var	int					SavedShotgunDamageStat;
var	const SteamStatInt	HeadshotKillsStat;
var	int					SavedHeadshotKillsStat;
var	const SteamStatInt	StalkerKillsStat;
var	int					SavedStalkerKillsStat;
var	const SteamStatInt	BullpupDamageStat;
var	int					SavedBullpupDamageStat;
var	const SteamStatInt	MeleeDamageStat;
var	int					SavedMeleeDamageStat;
var	const SteamStatInt	FlameThrowerDamageStat;
var	int					SavedFlameThrowerDamageStat;
var	const SteamStatInt	ExplosivesDamageStat;
var	int					SavedExplosivesDamageStat;

// Single Wave Stats
var	const SteamStatInt	FireAxeKills;
var	const SteamStatInt	ChainsawKills;
var	const SteamStatInt	MedicKnifeKills;
var	const SteamStatInt	StalkerBackstabKills;
var	const SteamStatInt	CrawlerBullpupKills;
var	const SteamStatInt	BloatKills;
var	const SteamStatInt	MeleeKills;
var const SteamStatInt	LARClotKills;
var	const SteamStatInt	ClotFireKills;
var	const SteamStatInt	GorefastBackstabKills;
var	const SteamStatInt	BloatBullpupKills;
var	const SteamStatInt	ClotKills;
var bool				bBloatKilledWithKSG;
var bool				bBossKilledWithKSG;
var bool				bClotKilledWithKSG;
var bool				bCrawlerKilledWithKSG;
var bool				bFleshPoundKilledWithKSG;
var bool				bGoreFastKilledWithKSG;
var bool				bHuskKilledWithKSG;
var bool				bScrakeKilledWithKSG;
var bool				bSirenKilledWithKSG;
var bool				bStalkerKilledWithKSG;

// One Off Counting Stats
var	const SteamStatInt	HuntingShotgunKills;
var	const SteamStatInt	M99Kills;
var	const SteamStatInt	LaserSightedEBRHeadshots;
var	const SteamStatInt	LARStalkerKills;
var	const SteamStatInt	DroppedTier2Weapons;
var	const SteamStatInt	HalloweenSpecimensKilledWithoutReloading;
var	const SteamStatInt	M4SingleClipXMasKills;
var	const SteamStatInt	BenelliSingleClipXMasKills;
var	const SteamStatInt	RevolverSingleClipXMasKills;
var	bool				bClaymoredScrake;
var	bool				bClaymoredFleshpound;
var	const SteamStatInt	XMas20MinuteClotKills;
var	const SteamStatInt	XMas20MinuteStalkerKills;
var	const SteamStatInt	XMas20MinuteCrawlerKills;
var	const SteamStatInt	XMas20MinuteSirenKills;
var	const SteamStatInt	XMas20MinuteBloatKills;
var	const SteamStatInt	MK23SingleClipKills;

// Misc Stats
var	const SteamStatInt		SelfHealsStat;
var	int						SavedSelfHealsStat;
var	const SteamStatInt		SoleSurvivorWavesStat;
var	int						SavedSoleSurvivorWavesStat;
var	const SteamStatInt		CashDonatedStat;
var	int						SavedCashDonatedStat;
var	const SteamStatInt		FeedingKillsStat;
var	int						SavedFeedingKillsStat;
var	const SteamStatInt		BurningCrossbowKillsStat;
var	int						SavedBurningCrossbowKillsStat;
var	const SteamStatInt		GibbedFleshpoundsStat;
var	int						SavedGibbedFleshpoundsStat;
var	const SteamStatInt		StalkersKilledWithExplosivesStat;
var	int						SavedStalkersKilledWithExplosivesStat;
var	const SteamStatInt		GibbedEnemiesStat;
var	int						SavedGibbedEnemiesStat;
var	const SteamStatInt		SirensKilledWithExplosivesStat;
var	int						SavedSirensKilledWithExplosivesStat;
var	const SteamStatInt		BloatKillsStat;
var	int						SavedBloatKillsStat;
var	const SteamStatFloat	TotalZedTimeStat;
var	float					SavedTotalZedTimeStat;
var	const SteamStatInt		SirenKillsStat;
var	int						SavedSirenKillsStat;
var	const SteamStatInt		KillsStat;
var	int						SavedKillsStat;
var	const SteamStatInt		DemolitionsPipebombKillsStat;
var	int						SavedDemolitionsPipebombKillsStat;
var	const SteamStatInt		EnemiesGibbedWithM79;
var	int						SavedEnemiesGibbedWithM79;
var	const SteamStatInt		EnemiesKilledWithSCAR;
var	int						SavedEnemiesKilledWithSCAR;
var	const SteamStatInt		TeammatesHealedWithMP7;
var	int						SavedTeammatesHealedWithMP7;
var	const SteamStatInt		FleshpoundsKilledWithAA12;
var	int						SavedFleshpoundsKilledWithAA12;
var	const SteamStatInt		CrawlersKilledInMidair;
var	int						SavedCrawlersKilledInMidair;
var	const SteamStatInt		Mac10BurnDamage;
var	int						SavedMac10BurnDamage;
var	const SteamStatInt		DroppedTier3Weapons;
var	int						SavedDroppedTier3Weapons;
var	const SteamStatInt		HalloweenKills;
var	int						SavedHalloweenKills;
var	const SteamStatInt		HalloweenScrakeKills;
var	int						SavedHalloweenScrakeKills;
var	const SteamStatInt		XMasHusksKilledWithHuskCannon;
var	int						SavedXMasHusksKilledWithHuskCannon;
var	const SteamStatInt		XMasPointsHealedWithMP5;
var	int						SavedXMasPointsHealedWithMP5;
var	const SteamStatInt		EnemiesKilledWithBullpup;
var	int						SavedEnemiesKilledWithBullpup;
var	const SteamStatInt		EnemiesKilledWithFNFal;
var	int						SavedEnemiesKilledWithFNFal;

// Hillbilly Variables
var	const SteamStatInt		ZedSetFireWithTrenchOnHillbilly;
var	int						SavedZedSetFireWithTrenchOnHillbilly;
var	const SteamStatInt		ZedKilledDuringHillbilly;
var	int						SavedZedKilledDuringHillbilly;
var const SteamStatInt		HillbillyAchievementsCompleted;
var	int						SavedHillbillyAchievementsCompleted;

var const SteamStatInt		Stat46;

var	const SteamStatInt		FleshPoundsKilledWithAxe;
var	int						SavedFleshPoundsKilledWithAxe;
var	const SteamStatInt		ZedsKilledWhileAirborne;
var	int						SavedZedsKilledWhileAirborne;
var	const SteamStatInt		ZEDSKilledWhileZapped;
var	int						SavedZEDSKilledWhileZapped;

var int						EnemiesKilledWithMKB42NoReload;
var int						StalkersKilledWithNail;
var int						HillbillyCrawlerKills;
var int						HillbillysKilledIn10Secs;
var	float 					HillbillySKilledIn10SecsTime;
var int						HillbillyGorefastsOnFire;
var int						HuskAndZedOneShotTotalKills;
var int						HuskAndZedOneShotZedKills;

var const SteamStatInt		OwnedWeaponDLC;

var int						NullValue;

var bool                    CanGetAxe;
var int                     ZEDpiecesObtained;

//=============================================================================
// Achievements
//=============================================================================
const KFACHIEVEMENT_WinWestLondonNormal					= 0;
const KFACHIEVEMENT_WinManorNormal						= 1;
const KFACHIEVEMENT_WinFarmNormal						= 2;
const KFACHIEVEMENT_WinOfficesNormal					= 3;
const KFACHIEVEMENT_WinBioticsLabNormal					= 4;
const KFACHIEVEMENT_WinAllMapsNormal					= 5;
const KFACHIEVEMENT_WinWestLondonHard					= 6;
const KFACHIEVEMENT_WinManorHard						= 7;
const KFACHIEVEMENT_WinFarmHard							= 8;
const KFACHIEVEMENT_WinOfficesHard						= 9;
const KFACHIEVEMENT_WinBioticsLabHard					= 10;
const KFACHIEVEMENT_WinAllMapsHard						= 11;
const KFACHIEVEMENT_WinWestLondonSuicidal				= 12;
const KFACHIEVEMENT_WinManorSuicidal					= 13;
const KFACHIEVEMENT_WinFarmSuicidal						= 14;
const KFACHIEVEMENT_WinOfficesSuicidal					= 15;
const KFACHIEVEMENT_WinBioticsLabSuicidal				= 16;
const KFACHIEVEMENT_WinAllMapsSuicidal					= 17;
const KFACHIEVEMENT_KillXEnemies						= 18;
const KFACHIEVEMENT_KillXEnemies2						= 19;
const KFACHIEVEMENT_KillXEnemies3						= 20;
const KFACHIEVEMENT_KillXBloats							= 21;
const KFACHIEVEMENT_KillXSirens							= 22;
const KFACHIEVEMENT_KillXStalkersWithExplosives			= 23;
const KFACHIEVEMENT_KillXEnemiesWithFireAxe				= 24;	// Single Wave
const KFACHIEVEMENT_KillXScrakesWithChainsaw			= 25;	// Single Wave
const KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow		= 26;
const KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses		= 27;
const KFACHIEVEMENT_KillXEnemiesWithGrenade				= 28;
const KFACHIEVEMENT_Kill4EnemiesWithHuntingShotgunShot	= 29;
const KFACHIEVEMENT_KillEnemyUsingBloatAcid				= 30;
const KFACHIEVEMENT_KillFleshpoundWithMelee				= 31;
const KFACHIEVEMENT_MedicKillXEnemiesWithKnife			= 32;	// Single Wave
const KFACHIEVEMENT_TurnXEnemiesIntoGiblets				= 33;
const KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets			= 34;
const KFACHIEVEMENT_HealSelfXTimes						= 35;
const KFACHIEVEMENT_OnlySurvivorXWaves					= 36;
const KFACHIEVEMENT_DonateXCashToTeammates				= 37;
const KFACHIEVEMENT_AcquireXMinutesOfZedTime			= 38;
const KFACHIEVEMENT_MaxOutAllPerks						= 39;
const KFACHIEVEMENT_KillPatriarchBeforeHeHeals			= 40;
const KFACHIEVEMENT_KillPatriarchWithLAW				= 41;
const KFACHIEVEMENT_DefeatPatriarchOnSuicidal			= 42;
const KFACHIEVEMENT_WinFoundryNormal					= 43;
const KFACHIEVEMENT_WinFoundryHard						= 44;
const KFACHIEVEMENT_WinFoundrySuicidal					= 45;
const KFACHIEVEMENT_WinAsylumNormal						= 46;
const KFACHIEVEMENT_WinAsylumHard						= 47;
const KFACHIEVEMENT_WinAsylumSuicidal					= 48;
const KFACHIEVEMENT_WinWyreNormal						= 49;
const KFACHIEVEMENT_WinWyreHard							= 50;
const KFACHIEVEMENT_WinWyreSuicidal						= 51;
const KFACHIEVEMENT_WinAll3SummerMapsNormal				= 52;
const KFACHIEVEMENT_WinAll3SummerMapsHard				= 53;
const KFACHIEVEMENT_WinAll3SummerMapsSuicidal			= 54;
const KFACHIEVEMENT_Kill1000EnemiesWithPipebomb			= 55;
const KFACHIEVEMENT_KillHuskWithFlamethrower			= 56;
const KFACHIEVEMENT_KillPatriarchOnlyCrossbows			= 57;
const KFACHIEVEMENT_Gib500ZedsWithM79					= 58;
const KFACHIEVEMENT_LaserSightedEBRHeadshots25InARow	= 59;
const KFACHIEVEMENT_Kill1000ZedsWithSCAR				= 60;
const KFACHIEVEMENT_Heal200TeammatesWithMP7				= 61;
const KFACHIEVEMENT_Kill100FleshpoundsWithAA12			= 62;
const KFACHIEVEMENT_Kill20CrawlersKilledInAir			= 63;
const KFACHIEVEMENT_Obliterate10ZedsWithPipebomb		= 64;
const KFACHIEVEMENT_WinWestLondonHell					= 65;
const KFACHIEVEMENT_WinManorHell						= 66;
const KFACHIEVEMENT_WinFarmHell							= 67;
const KFACHIEVEMENT_WinOfficesHell						= 68;
const KFACHIEVEMENT_WinBioticsLabHell					= 69;
const KFACHIEVEMENT_WinFoundryHell						= 70;
const KFACHIEVEMENT_WinAsylumHell						= 71;
const KFACHIEVEMENT_WinWyreHell							= 72;
const KFACHIEVEMENT_WinBiohazardNormal					= 73;
const KFACHIEVEMENT_WinBiohazardHard					= 74;
const KFACHIEVEMENT_WinBiohazardSuicidal				= 75;
const KFACHIEVEMENT_WinBiohazardHell					= 76;
const KFACHIEVEMENT_WinCrashNormal						= 77;
const KFACHIEVEMENT_WinCrashHard						= 78;
const KFACHIEVEMENT_WinCrashSuicidal					= 79;
const KFACHIEVEMENT_WinCrashHell						= 80;
const KFACHIEVEMENT_WinDepartedNormal					= 81;
const KFACHIEVEMENT_WinDepartedHard						= 82;
const KFACHIEVEMENT_WinDepartedSuicidal					= 83;
const KFACHIEVEMENT_WinDepartedHell						= 84;
const KFACHIEVEMENT_WinFilthsCrossNormal				= 85;
const KFACHIEVEMENT_WinFilthsCrossHard					= 86;
const KFACHIEVEMENT_WinFilthsCrossSuicidal				= 87;
const KFACHIEVEMENT_WinFilthsCrossHell					= 88;
const KFACHIEVEMENT_WinHospitalHorrorsNormal			= 89;
const KFACHIEVEMENT_WinHospitalHorrorsHard				= 90;
const KFACHIEVEMENT_WinHospitalHorrorsSuicidal			= 91;
const KFACHIEVEMENT_WinHospitalHorrorsHell				= 92;
const KFACHIEVEMENT_WinIcebreakerNormal					= 93;
const KFACHIEVEMENT_WinIcebreakerHard					= 94;
const KFACHIEVEMENT_WinIcebreakerSuicidal				= 95;
const KFACHIEVEMENT_WinIcebreakerHell					= 96;
const KFACHIEVEMENT_WinMountainPassNormal				= 97;
const KFACHIEVEMENT_WinMountainPassHard					= 98;
const KFACHIEVEMENT_WinMountainPassSuicidal				= 99;
const KFACHIEVEMENT_WinMountainPassHell					= 100;
const KFACHIEVEMENT_WinSuburbiaNormal					= 101;
const KFACHIEVEMENT_WinSuburbiaHard						= 102;
const KFACHIEVEMENT_WinSuburbiaSuicidal					= 103;
const KFACHIEVEMENT_WinSuburbiaHell						= 104;
const KFACHIEVEMENT_WinWaterworksNormal					= 105;
const KFACHIEVEMENT_WinWaterworksHard					= 106;
const KFACHIEVEMENT_WinWaterworksSuicidal				= 107;
const KFACHIEVEMENT_WinWaterworksHell					= 108;
const KFACHIEVEMENT_CompleteNewAchievementsNormal		= 109;
const KFACHIEVEMENT_CompleteNewAchievementsHard			= 110;
const KFACHIEVEMENT_CompleteNewAchievementsSuicidal		= 111;
const KFACHIEVEMENT_CompleteNewAchievementsHell			= 112;
const KFACHIEVEMENT_Get1000BurnDamageWithMac10			= 113;
const KFACHIEVEMENT_WinSantasEvilLairNormal				= 114;
const KFACHIEVEMENT_WinSantasEvilLairHard				= 115;
const KFACHIEVEMENT_WinSantasEvilLairSuicidal			= 116;
const KFACHIEVEMENT_WinSantasEvilLairHell				= 117;
const KFACHIEVEMENT_KillChristmasPatriarch				= 118;
const KFACHIEVEMENT_KnifeChristmasFleshpound			= 119;
const KFACHIEVEMENT_MeleeKill2ChristmasGorefastFromBack	= 120;
const KFACHIEVEMENT_KillChristmasScrakeWithFire			= 121;
const KFACHIEVEMENT_Kill3ChristmasBloatsWithBullpup		= 122;
const KFACHIEVEMENT_Kill20ChristmasClots				= 123;
const KFACHIEVEMENT_KillChristmasCrawlerWithXBow		= 124;
const KFACHIEVEMENT_KillChristmasSirenWithLawImpact		= 125;
const KFACHIEVEMENT_Kill3ChristmasStalkersWithLAR		= 126;
const KFACHIEVEMENT_KillChristmasHuskWithPistol			= 127;
const KFACHIEVEMENT_MeleeKill3ChristmasZedsInOneSlomo	= 128;
const KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas	= 129;
const KFACHIEVEMENT_ChristmasVomitLive10Seconds			= 130;
const KFACHIEVEMENT_Unlock10ofChristmasAchievements		= 131;
const KFACHIEVEMENT_PotatoPurchased						= 132;
const KFACHIEVEMENT_WinApertureNormal					= 133;
const KFACHIEVEMENT_WinApertureHard						= 134;
const KFACHIEVEMENT_WinApertureSuicidal					= 135;
const KFACHIEVEMENT_WinApertureHellOnEarth				= 136;
const KFACHIEVEMENT_GoldenPotato						= 137;
const KFACHIEVEMENT_WinSideshowNormal					= 138;
const KFACHIEVEMENT_WinSideshowHard						= 139;
const KFACHIEVEMENT_WinSideshowSuicidal					= 140;
const KFACHIEVEMENT_WinSideshowHell						= 141;
const KFACHIEVEMENT_KillSideshowPatriarch				= 142;
const KFACHIEVEMENT_KillSideshowGorefastWithMelee		= 143;
const KFACHIEVEMENT_Kill2SideshowStalkerWithBackstab	= 144;
const KFACHIEVEMENT_Kill5SideshowCrawlersWithBullpup	= 145;
const KFACHIEVEMENT_Kill5SideshowBloats					= 146;
const KFACHIEVEMENT_KillSideshowScrakeWithCrossbow		= 147;
const KFACHIEVEMENT_KillSideshowHuskWithLAW				= 148;
const KFACHIEVEMENT_Kill3SideshowClotsWithLAR			= 149;
const KFACHIEVEMENT_KillSideshowFleshpoundWithPistol	= 150;
const KFACHIEVEMENT_Drop5Tier2WeaponsOneWaveSideshow	= 151;
const KFACHIEVEMENT_SurviveSideshowSirenScreamPlus10Sec	= 152;
const KFACHIEVEMENT_MeleeKill4SideshowZedsInOneSlomo	= 153;
const KFACHIEVEMENT_Kill10SideshowClotsWithFireWeapon	= 154;
const KFACHIEVEMENT_Unlock10ofSideshowAchievements		= 155;
const KFACHIEVEMENT_KillHalloweenPatriarchInBedlam		= 156;
const KFACHIEVEMENT_DecapBurningHalloweenZedInBedlam	= 157;
const KFACHIEVEMENT_Kill250HalloweenZedsInBedlam		= 158;
const KFACHIEVEMENT_WinBedlamHardHalloween				= 159;
const KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam		= 160;
const KFACHIEVEMENT_Kill5HalloweenZedsWithoutReload		= 161;
const KFACHIEVEMENT_Unlock6ofHalloweenAchievements		= 162;
const KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon		= 163;
const KFACHIEVEMENT_KillXMasPatriarchWithClaymoreDecap	= 164;
const KFACHIEVEMENT_Kill1XMasZedWithFullM4Clip			= 165;
const KFACHIEVEMENT_KillXMasScrakeWithDirectM203Nade	= 166;
const KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas		= 167;
const KFACHIEVEMENT_Kill12XMasZedsWith1BenelliClip		= 168;
const KFACHIEVEMENT_KillXMasZedWithEveryRevolverShot	= 169;
const KFACHIEVEMENT_HoldAll3DualiesDuringXMas			= 170;
const KFACHIEVEMENT_WinIceCaveNormal					= 171;
const KFACHIEVEMENT_WinIceCaveHard						= 172;
const KFACHIEVEMENT_WinIceCaveSuicidal					= 173;
const KFACHIEVEMENT_WinIceCaveHell						= 174;
const KFACHIEVEMENT_KillSelectXMasZedsOnSingleMap		= 175;
const KFACHIEVEMENT_Kill12ClotsWithOneMagWithMK23		= 176;
const KFACHIEVEMENT_KillZedThatHurtPlayerWithM7A3       = 177;
const KFACHIEVEMENT_KillOneOfEachZedsWithKSG            = 178;
const KFACHIEVEMENT_KillZedWithSA80AndFNFal             = 179;
const KFACHIEVEMENT_Kill2ScrakesOneBulletWithBarret	    = 180;
const KFACHIEVEMENT_WinHellrideNormal					= 181;
const KFACHIEVEMENT_WinHellrideHard						= 182;
const KFACHIEVEMENT_WinHellrideSuicidal					= 183;
const KFACHIEVEMENT_WinHellrideHell						= 184;

// Hillbilly Achievements
const KFACHIEVEMENT_Kill6ZedWithoutReloadingMKB42		= 185;
const KFACHIEVEMENT_Kill4StalkersNailgun				= 186;
const KFACHIEVEMENT_HealAllPlayersWith1MedicNade		= 187;
const KFACHIEVEMENT_Set200ZedOnFireOnHillbilly			= 188;
const KFACHIEVEMENT_WinHillbillyNormal					= 189;
const KFACHIEVEMENT_WinHillbillyHard					= 190;
const KFACHIEVEMENT_WinHillbillySuicidal				= 191;
const KFACHIEVEMENT_WinHillbillyHell					= 192;
const KFACHIEVEMENT_Complete7ReaperAchievements			= 193;
const KFACHIEVEMENT_Destroy25GnomesInHillbilly			= 194;
const KFACHIEVEMENT_Kill1000HillbillyZeds				= 195;
const KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB 	= 196;
const KFACHIEVEMENT_Kill1Hillbilly1HuskAndZedIn1Shot	= 197;
const KFACHIEVEMENT_Kill5HillbillyZedsIn10SecsSythOrAxe	= 198;
const KFACHIEVEMENT_Set3HillbillyGorefastsOnFire		= 199;

const KFACHIEVEMENT_HaveMyAxe					        = 200;
const KFACHIEVEMENT_OneSmallStepForMan			     	= 201;
const KFACHIEVEMENT_ButItsAllRed			    	    = 202;
const KFACHIEVEMENT_GameOverMan					        = 203;
const KFACHIEVEMENT_WinMoonbaseNormal					= 204;
const KFACHIEVEMENT_WinMoonbaseHard			     		= 205;
const KFACHIEVEMENT_WinMoonbaseSuicidal			    	= 206;
const KFACHIEVEMENT_WinMoonbaseHell					    = 207;

const KFACHIEVEMENT_CanGetAxe   					    = 208;//this is a dummy achievement

struct native export KFAchievement
{
	var	string	SteamName;
	var	string	DisplayName;
	var	string	Description;
	var	byte	bCompleted;

	var	byte	bShowProgress;
	var	int		ProgressNumerator;
	var	int		ProgressDenominator;

	var	texture	Icon;
	var	texture	LockedIcon;
};

var	array<KFAchievement>	Achievements;

//=============================================================================
// Perks
//=============================================================================
// Levels Available for Perks: (0=Medic, 1=Support, 2=Sharpshooter, 3=Commando, 4=Berserker, 5=Firebug, 6=Demolitions)
var	const native byte	PerkLevel[7];

// Debug only variables
var	globalconfig bool	bOverridePerkLevels;
var	globalconfig int	MedicPerkLevel;
var	globalconfig int	SupportPerkLevel;
var	globalconfig int	SharpshooterPerkLevel;
var	globalconfig int	CommandoPerkLevel;
var	globalconfig int	BerserkerPerkLevel;
var	globalconfig int	FirebugPerkLevel;
var	globalconfig int	DemolitionsPerkLevel;

simulated native final function GetEventCommand();

simulated native final function InitializePerks();
simulated native final function CheckMedicPerks(bool bShowNotification);
simulated native final function CheckSupportPerks(bool bShowNotification);
simulated native final function CheckSharpshooterPerks(bool bShowNotification);
simulated native final function CheckCommandoPerks(bool bShowNotification);
simulated native final function CheckBerserkerPerks(bool bShowNotification);
simulated native final function CheckFirebugPerks(bool bShowNotification);
simulated native final function CheckDemolitionsPerks(bool bShowNotification);

simulated native final function	int		PerkHighestLevelAvailable(int Type);

simulated native final function float	GetPerkProgress(int Type);
simulated native final function			GetMedicProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetSupportProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetSharpshooterProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetCommandoProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetBerserkerProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetFirebugProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);
simulated native final function			GetDemolitionsProgressDetails(int Index, out int CurrentValue, out int RequiredValue, out float Progress);

replication
{
	reliable if ( bFlushStatsToClient && Role == ROLE_Authority )
		DamageHealedStat, WeldingPointsStat, ShotgunDamageStat, HeadshotKillsStat,
		StalkerKillsStat, BullpupDamageStat, MeleeDamageStat, FlameThrowerDamageStat,
		SelfHealsStat, SoleSurvivorWavesStat, CashDonatedStat, FeedingKillsStat,
		BurningCrossbowKillsStat, GibbedFleshpoundsStat, StalkersKilledWithExplosivesStat,
		GibbedEnemiesStat, BloatKillsStat, TotalZedTimeStat, SirenKillsStat, KillsStat,
		ExplosivesDamageStat, DemolitionsPipebombKillsStat, EnemiesKilledWithSCAR,
		TeammatesHealedWithMP7, FleshpoundsKilledWithAA12, CrawlersKilledInMidair,
		Mac10BurnDamage, DroppedTier3Weapons, HalloweenKills, HalloweenScrakeKills,
		XMasHusksKilledWithHuskCannon, XMasPointsHealedWithMP5,
		EnemiesKilledWithFNFal, EnemiesKilledWithBullpup, ZedSetFireWithTrenchOnHillbilly,
		ZedKilledDuringHillbilly, HillbillyAchievementsCompleted, FleshPoundsKilledWithAxe,
        ZedsKilledWhileAirborne, ZEDSKilledWhileZapped;
}

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

final event bool IsDebugMode()
{
	return class'ROEngine.ROLevelInfo'.static.RODebugMode();
}

// Used to only send the Stats/Achievements that have changed to Steam
simulated event PostNetReceive()
{
	local bool bFlushStatsToDatabase;

	if ( bDebugStats )
		log("STEAMSTATS: PostNetReceive called");

	if ( DamageHealedStat.Value != SavedDamageHealedStat )
	{
		CheckMedicPerks(true);

		FlushStatToSteamInt(DamageHealedStat, SteamNameStat[KFSTAT_DamageHealed]);

		SavedDamageHealedStat = DamageHealedStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( WeldingPointsStat.Value != SavedWeldingPointsStat )
	{
		CheckSupportPerks(true);

		FlushStatToSteamInt(WeldingPointsStat, SteamNameStat[KFSTAT_WeldingPoints]);

		SavedWeldingPointsStat = WeldingPointsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ShotgunDamageStat.Value != SavedShotgunDamageStat )
	{
		CheckSupportPerks(true);

		FlushStatToSteamInt(ShotgunDamageStat, SteamNameStat[KFSTAT_ShotgunDamage]);

		SavedShotgunDamageStat = ShotgunDamageStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( HeadshotKillsStat.Value != SavedHeadshotKillsStat )
	{
		CheckSharpshooterPerks(true);

		FlushStatToSteamInt(HeadshotKillsStat, SteamNameStat[KFSTAT_HeadshotKills]);

		SavedHeadshotKillsStat = HeadshotKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( StalkerKillsStat.Value != SavedStalkerKillsStat )
	{
		CheckCommandoPerks(true);

		FlushStatToSteamInt(StalkerKillsStat, SteamNameStat[KFSTAT_StalkerKills]);

		SavedStalkerKillsStat = StalkerKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( BullpupDamageStat.Value != SavedBullpupDamageStat )
	{
		CheckCommandoPerks(true);

		FlushStatToSteamInt(BullpupDamageStat, SteamNameStat[KFSTAT_BullpupDamage]);

		SavedBullpupDamageStat = BullpupDamageStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( MeleeDamageStat.Value != SavedMeleeDamageStat )
	{
		CheckBerserkerPerks(true);

		FlushStatToSteamInt(MeleeDamageStat, SteamNameStat[KFSTAT_MeleeDamage]);

		SavedMeleeDamageStat = MeleeDamageStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( FlameThrowerDamageStat.Value != SavedFlameThrowerDamageStat )
	{
		CheckFirebugPerks(true);

		FlushStatToSteamInt(FlameThrowerDamageStat, SteamNameStat[KFSTAT_FlameThrowerDamage]);

		SavedFlameThrowerDamageStat = FlameThrowerDamageStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ExplosivesDamageStat.Value != SavedExplosivesDamageStat )
	{
		CheckDemolitionsPerks(true);

		FlushStatToSteamInt(ExplosivesDamageStat, SteamNameStat[KFSTAT_ExplosivesDamage]);

		SavedExplosivesDamageStat = ExplosivesDamageStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( SelfHealsStat.Value != SavedSelfHealsStat )
	{
		FlushStatToSteamInt(SelfHealsStat, SteamNameStat[KFSTAT_SelfHeals]);

		SavedSelfHealsStat = SelfHealsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( SoleSurvivorWavesStat.Value != SavedSoleSurvivorWavesStat )
	{
		FlushStatToSteamInt(SoleSurvivorWavesStat, SteamNameStat[KFSTAT_SoleSurvivorWaves]);

		SavedSoleSurvivorWavesStat = SoleSurvivorWavesStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( CashDonatedStat.Value != SavedCashDonatedStat )
	{
		FlushStatToSteamInt(CashDonatedStat, SteamNameStat[KFSTAT_CashDonated]);

		SavedCashDonatedStat = CashDonatedStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( FeedingKillsStat.Value != SavedFeedingKillsStat )
	{
		FlushStatToSteamInt(FeedingKillsStat, SteamNameStat[KFSTAT_FeedingKills]);

		SavedFeedingKillsStat = FeedingKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( BurningCrossbowKillsStat.Value != SavedBurningCrossbowKillsStat )
	{
		FlushStatToSteamInt(BurningCrossbowKillsStat, SteamNameStat[KFSTAT_BurningCrossbowKills]);

		SavedBurningCrossbowKillsStat = BurningCrossbowKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( GibbedFleshpoundsStat.Value != SavedGibbedFleshpoundsStat )
	{
		FlushStatToSteamInt(GibbedFleshpoundsStat, SteamNameStat[KFSTAT_GibbedFleshpounds]);

		SavedGibbedFleshpoundsStat = GibbedFleshpoundsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( StalkersKilledWithExplosivesStat.Value != SavedStalkersKilledWithExplosivesStat )
	{
		FlushStatToSteamInt(StalkersKilledWithExplosivesStat, SteamNameStat[KFSTAT_StalkersKilledWithExplosives]);

		SavedStalkersKilledWithExplosivesStat = StalkersKilledWithExplosivesStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( GibbedEnemiesStat.Value != SavedGibbedEnemiesStat )
	{
		FlushStatToSteamInt(GibbedEnemiesStat, SteamNameStat[KFSTAT_GibbedEnemies]);

		SavedGibbedEnemiesStat = GibbedEnemiesStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( SirensKilledWithExplosivesStat.Value != SavedSirensKilledWithExplosivesStat )
	{
		FlushStatToSteamInt(SirensKilledWithExplosivesStat, SteamNameStat[KFSTAT_SirensKilledWithExplosives]);

		SavedSirensKilledWithExplosivesStat = SirensKilledWithExplosivesStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( BloatKillsStat.Value != SavedBloatKillsStat )
	{
		FlushStatToSteamInt(BloatKillsStat, SteamNameStat[KFSTAT_BloatKills]);

		SavedBloatKillsStat = BloatKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( TotalZedTimeStat.Value != SavedTotalZedTimeStat )
	{
		FlushStatToSteamFloat(TotalZedTimeStat, SteamNameStat[KFSTAT_TotalZedTime]);

		SavedTotalZedTimeStat = TotalZedTimeStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( SirenKillsStat.Value != SavedSirenKillsStat )
	{
		FlushStatToSteamInt(SirenKillsStat, SteamNameStat[KFSTAT_SirenKills]);

		SavedSirenKillsStat = SirenKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( KillsStat.Value != SavedKillsStat )
	{
		FlushStatToSteamInt(KillsStat, SteamNameStat[KFSTAT_Kills]);

		SavedKillsStat = KillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( DemolitionsPipebombKillsStat.Value != SavedDemolitionsPipebombKillsStat )
	{
		FlushStatToSteamInt(DemolitionsPipebombKillsStat, SteamNameStat[KFSTAT_DemolitionsPipebombKills]);

		SavedDemolitionsPipebombKillsStat = DemolitionsPipebombKillsStat.Value;
		bFlushStatsToDatabase = true;
	}

	if ( EnemiesGibbedWithM79.Value != SavedEnemiesGibbedWithM79 )
	{
		FlushStatToSteamInt(EnemiesGibbedWithM79, SteamNameStat[KFSTAT_EnemiesGibbedWithM79]);

		SavedEnemiesGibbedWithM79 = EnemiesGibbedWithM79.Value;
		bFlushStatsToDatabase = true;
	}

	if ( EnemiesKilledWithSCAR.Value != SavedEnemiesKilledWithSCAR )
	{
		FlushStatToSteamInt(EnemiesKilledWithSCAR, SteamNameStat[KFSTAT_EnemiesKilledWithSCAR]);

		SavedEnemiesKilledWithSCAR = EnemiesKilledWithSCAR.Value;
		bFlushStatsToDatabase = true;
	}

	if ( TeammatesHealedWithMP7.Value != SavedTeammatesHealedWithMP7 )
	{
		FlushStatToSteamInt(TeammatesHealedWithMP7, SteamNameStat[KFSTAT_TeammatesHealedWithMP7]);

		SavedTeammatesHealedWithMP7 = TeammatesHealedWithMP7.Value;
		bFlushStatsToDatabase = true;
	}

	if ( FleshpoundsKilledWithAA12.Value != SavedFleshpoundsKilledWithAA12 )
	{
		FlushStatToSteamInt(FleshpoundsKilledWithAA12, SteamNameStat[KFSTAT_FleshpoundsKilledWithAA12]);

		SavedFleshpoundsKilledWithAA12 = FleshpoundsKilledWithAA12.Value;
		bFlushStatsToDatabase = true;
	}

	if ( CrawlersKilledInMidair.Value != SavedCrawlersKilledInMidair )
	{
		FlushStatToSteamInt(CrawlersKilledInMidair, SteamNameStat[KFSTAT_CrawlersKilledInMidair]);

		SavedCrawlersKilledInMidair = CrawlersKilledInMidair.Value;
		bFlushStatsToDatabase = true;
	}

	if ( Mac10BurnDamage.Value != SavedMac10BurnDamage )
	{
		FlushStatToSteamInt(Mac10BurnDamage, SteamNameStat[KFSTAT_Mac10BurnDamage]);

		SavedMac10BurnDamage = Mac10BurnDamage.Value;
		bFlushStatsToDatabase = true;
	}

	if ( DroppedTier3Weapons.Value != SavedDroppedTier3Weapons )
	{
		FlushStatToSteamInt(DroppedTier3Weapons, SteamNameStat[KFSTAT_DroppedTier3Weapons]);

		SavedDroppedTier3Weapons = DroppedTier3Weapons.Value;
		bFlushStatsToDatabase = true;
	}

	if ( HalloweenKills.Value != SavedHalloweenKills )
	{
		FlushStatToSteamInt(HalloweenKills, SteamNameStat[KFSTAT_HalloweenKills]);

		SavedHalloweenKills = HalloweenKills.Value;
		bFlushStatsToDatabase = true;
	}

	if ( HalloweenScrakeKills.Value != SavedHalloweenScrakeKills )
	{
		FlushStatToSteamInt(HalloweenScrakeKills, SteamNameStat[KFSTAT_HalloweenScrakeKills]);

		SavedHalloweenScrakeKills = HalloweenScrakeKills.Value;
		bFlushStatsToDatabase = true;
	}

	if ( XMasHusksKilledWithHuskCannon.Value != SavedXMasHusksKilledWithHuskCannon )
	{
		FlushStatToSteamInt(XMasHusksKilledWithHuskCannon, SteamNameStat[KFSTAT_XMasHusksKilledWithHuskCannon]);

		SavedXMasHusksKilledWithHuskCannon = XMasHusksKilledWithHuskCannon.Value;
		bFlushStatsToDatabase = true;
	}

	if ( XMasPointsHealedWithMP5.Value != SavedXMasPointsHealedWithMP5 )
	{
		FlushStatToSteamInt(XMasPointsHealedWithMP5, SteamNameStat[KFSTAT_XMasPointsHealedWithMP5]);

		SavedXMasPointsHealedWithMP5 = XMasPointsHealedWithMP5.Value;
		bFlushStatsToDatabase = true;
	}

    if ( EnemiesKilledWithBullpup.Value != SavedEnemiesKilledWithBullpup )
	{
		FlushStatToSteamInt(EnemiesKilledWithBullpup , SteamNameStat[KFSTAT_EnemiesKilledWithBullpup]);

		SavedEnemiesKilledWithBullpup  = EnemiesKilledWithBullpup.Value;
		bFlushStatsToDatabase = true;
	}

	if ( EnemiesKilledWithFNFal.Value != SavedEnemiesKilledWithFNFal )
	{
		FlushStatToSteamInt(EnemiesKilledWithFNFal , SteamNameStat[KFSTAT_EnemiesKilledWithFNFal]);

		SavedEnemiesKilledWithFNFal  = EnemiesKilledWithFNFal.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ZedSetFireWithTrenchOnHillbilly.Value != SavedZedSetFireWithTrenchOnHillbilly )
	{
		FlushStatToSteamInt(ZedSetFireWithTrenchOnHillbilly, SteamNameStat[KFSTAT_EnemiesKilledWithTrenchOnHillbilly]);

		SavedZedSetFireWithTrenchOnHillbilly = ZedSetFireWithTrenchOnHillbilly.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ZedKilledDuringHillbilly.Value != SavedZedKilledDuringHillbilly )
	{
		FlushStatToSteamInt(ZedKilledDuringHillbilly, SteamNameStat[KFSTAT_EnemiesKilledDuringHillbilly]);

		SavedZedKilledDuringHillbilly = ZedKilledDuringHillbilly.Value;
		bFlushStatsToDatabase = true;
	}

	if ( HillbillyAchievementsCompleted.Value != SavedHillbillyAchievementsCompleted )
	{
		FlushStatToSteamInt(HillbillyAchievementsCompleted, SteamNameStat[KFSTAT_HillbillyAchievementsCompleted]);

		SavedHillbillyAchievementsCompleted = HillbillyAchievementsCompleted.Value;
		bFlushStatsToDatabase = true;
	}

	if ( FleshPoundsKilledWithAxe.Value != SavedFleshPoundsKilledWithAxe )
	{
		FlushStatToSteamInt(FleshPoundsKilledWithAxe, SteamNameStat[KFSTAT_FleshPoundsKilledWithAxe]);

		SavedFleshPoundsKilledWithAxe = FleshPoundsKilledWithAxe.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ZedsKilledWhileAirborne.Value != SavedZedsKilledWhileAirborne )
	{
		FlushStatToSteamInt(ZedsKilledWhileAirborne, SteamNameStat[KFSTAT_ZedsKilledWhileAirborne]);

		SavedZedsKilledWhileAirborne = ZedsKilledWhileAirborne.Value;
		bFlushStatsToDatabase = true;
	}

	if ( ZEDSKilledWhileZapped.Value != SavedZEDSKilledWhileZapped )
	{
		FlushStatToSteamInt(ZEDSKilledWhileZapped, SteamNameStat[KFSTAT_ZEDSKilledWhileZapped]);

		SavedZEDSKilledWhileZapped = ZEDSKilledWhileZapped.Value;
		bFlushStatsToDatabase = true;
	}


	if ( bFlushStatsToDatabase )
	{
		FlushStatsToSteamDatabase();
	}
}

// Event Callback for each GetStatsAndAchievements call
// NETWORK: Client only
simulated event OnStatsAndAchievementsReady()
{
	local int i;

	GetStatInt(DamageHealedStat, SteamNameStat[KFSTAT_DamageHealed]);
	SavedDamageHealedStat = DamageHealedStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_DamageHealed, DamageHealedStat.Value);

	GetStatInt(WeldingPointsStat, SteamNameStat[KFSTAT_WeldingPoints]);
	SavedWeldingPointsStat = WeldingPointsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_WeldingPoints, WeldingPointsStat.Value);

	GetStatInt(ShotgunDamageStat, SteamNameStat[KFSTAT_ShotgunDamage]);
	SavedShotgunDamageStat = ShotgunDamageStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_ShotgunDamage, ShotgunDamageStat.Value);

	GetStatInt(HeadshotKillsStat, SteamNameStat[KFSTAT_HeadshotKills]);
	SavedHeadshotKillsStat = HeadshotKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_HeadshotKills, HeadshotKillsStat.Value);

	GetStatInt(StalkerKillsStat, SteamNameStat[KFSTAT_StalkerKills]);
	SavedStalkerKillsStat = StalkerKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_StalkerKills, StalkerKillsStat.Value);

	GetStatInt(BullpupDamageStat, SteamNameStat[KFSTAT_BullpupDamage]);
	SavedBullpupDamageStat = BullpupDamageStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_BullpupDamage, BullpupDamageStat.Value);

	GetStatInt(MeleeDamageStat, SteamNameStat[KFSTAT_MeleeDamage]);
	SavedMeleeDamageStat = MeleeDamageStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_MeleeDamage, MeleeDamageStat.Value);

	GetStatInt(FlameThrowerDamageStat, SteamNameStat[KFSTAT_FlameThrowerDamage]);
	SavedFlameThrowerDamageStat = FlameThrowerDamageStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_FlameThrowerDamage, FlameThrowerDamageStat.Value);

	GetStatInt(ExplosivesDamageStat, SteamNameStat[KFSTAT_ExplosivesDamage]);
	SavedExplosivesDamageStat = ExplosivesDamageStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_ExplosivesDamage, ExplosivesDamageStat.Value);

	GetStatInt(SelfHealsStat, SteamNameStat[KFSTAT_SelfHeals]);
	SavedSelfHealsStat = SelfHealsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_SelfHeals, SelfHealsStat.Value);

	GetStatInt(SoleSurvivorWavesStat, SteamNameStat[KFSTAT_SoleSurvivorWaves]);
	SavedSoleSurvivorWavesStat = SoleSurvivorWavesStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_SoleSurvivorWaves, SoleSurvivorWavesStat.Value);

	GetStatInt(CashDonatedStat, SteamNameStat[KFSTAT_CashDonated]);
	SavedCashDonatedStat = CashDonatedStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_CashDonated, CashDonatedStat.Value);

	GetStatInt(FeedingKillsStat, SteamNameStat[KFSTAT_FeedingKills]);
	SavedFeedingKillsStat = FeedingKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_FeedingKills, FeedingKillsStat.Value);

	GetStatInt(BurningCrossbowKillsStat, SteamNameStat[KFSTAT_BurningCrossbowKills]);
	SavedBurningCrossbowKillsStat = BurningCrossbowKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_BurningCrossbowKills, BurningCrossbowKillsStat.Value);

	GetStatInt(GibbedFleshpoundsStat, SteamNameStat[KFSTAT_GibbedFleshpounds]);
	SavedGibbedFleshpoundsStat = GibbedFleshpoundsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_GibbedFleshpounds, GibbedFleshpoundsStat.Value);

	GetStatInt(StalkersKilledWithExplosivesStat, SteamNameStat[KFSTAT_StalkersKilledWithExplosives]);
	SavedStalkersKilledWithExplosivesStat = StalkersKilledWithExplosivesStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_StalkersKilledWithExplosives, StalkersKilledWithExplosivesStat.Value);

	GetStatInt(GibbedEnemiesStat, SteamNameStat[KFSTAT_GibbedEnemies]);
	SavedGibbedEnemiesStat = GibbedEnemiesStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_GibbedEnemies, GibbedEnemiesStat.Value);

	GetStatInt(SirensKilledWithExplosivesStat, SteamNameStat[KFSTAT_SirensKilledWithExplosives]);
	SavedSirensKilledWithExplosivesStat = SirensKilledWithExplosivesStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_SirensKilledWithExplosives, SirensKilledWithExplosivesStat.Value);

	GetStatInt(BloatKillsStat, SteamNameStat[KFSTAT_BloatKills]);
	SavedBloatKillsStat = BloatKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_BloatKills, BloatKillsStat.Value);

	GetStatFloat(TotalZedTimeStat, SteamNameStat[KFSTAT_TotalZedTime]);
	SavedTotalZedTimeStat = TotalZedTimeStat.Value;
	PCOwner.ServerInitializeSteamStatFloat(KFSTAT_TotalZedTime, TotalZedTimeStat.Value);

	GetStatInt(SirenKillsStat, SteamNameStat[KFSTAT_SirenKills]);
	SavedSirenKillsStat = SirenKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_SirenKills, SirenKillsStat.Value);

	GetStatInt(KillsStat, SteamNameStat[KFSTAT_Kills]);
	SavedKillsStat = KillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_Kills, KillsStat.Value);

	GetStatInt(DemolitionsPipebombKillsStat, SteamNameStat[KFSTAT_DemolitionsPipebombKills]);
	SavedDemolitionsPipebombKillsStat = DemolitionsPipebombKillsStat.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_DemolitionsPipebombKills, DemolitionsPipebombKillsStat.Value);

	GetStatInt(EnemiesGibbedWithM79, SteamNameStat[KFSTAT_EnemiesGibbedWithM79]);
	SavedEnemiesGibbedWithM79 = EnemiesGibbedWithM79.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesGibbedWithM79, EnemiesGibbedWithM79.Value);

	GetStatInt(EnemiesKilledWithSCAR, SteamNameStat[KFSTAT_EnemiesKilledWithSCAR]);
	SavedEnemiesKilledWithSCAR = EnemiesKilledWithSCAR.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesKilledWithSCAR, EnemiesKilledWithSCAR.Value);

	GetStatInt(TeammatesHealedWithMP7, SteamNameStat[KFSTAT_TeammatesHealedWithMP7]);
	SavedTeammatesHealedWithMP7 = TeammatesHealedWithMP7.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_TeammatesHealedWithMP7, TeammatesHealedWithMP7.Value);

	GetStatInt(FleshpoundsKilledWithAA12, SteamNameStat[KFSTAT_FleshpoundsKilledWithAA12]);
	SavedFleshpoundsKilledWithAA12 = FleshpoundsKilledWithAA12.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_FleshpoundsKilledWithAA12, FleshpoundsKilledWithAA12.Value);

	GetStatInt(CrawlersKilledInMidair, SteamNameStat[KFSTAT_CrawlersKilledInMidair]);
	SavedCrawlersKilledInMidair = CrawlersKilledInMidair.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_CrawlersKilledInMidair, CrawlersKilledInMidair.Value);

	GetStatInt(Mac10BurnDamage, SteamNameStat[KFSTAT_Mac10BurnDamage]);
	SavedMac10BurnDamage = Mac10BurnDamage.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_Mac10BurnDamage, Mac10BurnDamage.Value);

	GetStatInt(DroppedTier3Weapons, SteamNameStat[KFSTAT_DroppedTier3Weapons]);
	SavedDroppedTier3Weapons = DroppedTier3Weapons.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_DroppedTier3Weapons, DroppedTier3Weapons.Value);

	GetStatInt(HalloweenKills, SteamNameStat[KFSTAT_HalloweenKills]);
	SavedHalloweenKills = HalloweenKills.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_HalloweenKills, HalloweenKills.Value);

	GetStatInt(HalloweenScrakeKills, SteamNameStat[KFSTAT_HalloweenScrakeKills]);
	SavedHalloweenScrakeKills = HalloweenScrakeKills.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_HalloweenScrakeKills, HalloweenScrakeKills.Value);

	GetStatInt(XMasHusksKilledWithHuskCannon, SteamNameStat[KFSTAT_XMasHusksKilledWithHuskCannon]);
	SavedXMasHusksKilledWithHuskCannon = XMasHusksKilledWithHuskCannon.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_XMasHusksKilledWithHuskCannon, XMasHusksKilledWithHuskCannon.Value);

	GetStatInt(XMasPointsHealedWithMP5, SteamNameStat[KFSTAT_XMasPointsHealedWithMP5]);
	SavedXMasPointsHealedWithMP5 = XMasPointsHealedWithMP5.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_XMasPointsHealedWithMP5, XMasPointsHealedWithMP5.Value);

	GetStatInt(EnemiesKilledWithFNFal, SteamNameStat[KFSTAT_EnemiesKilledWithFNFal]);
	SavedEnemiesKilledWithFNFal = EnemiesKilledWithFNFal.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesKilledWithFNFal, EnemiesKilledWithFNFal.Value);

	GetStatInt(EnemiesKilledWithBullpup, SteamNameStat[KFSTAT_EnemiesKilledWithBullpup]);
	SavedEnemiesKilledWithBullpup = EnemiesKilledWithBullpup.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesKilledWithBullpup, EnemiesKilledWithBullpup.Value);

	GetStatInt(ZedSetFireWithTrenchOnHillbilly, SteamNameStat[KFSTAT_EnemiesKilledWithTrenchOnHillbilly]);
	SavedZedSetFireWithTrenchOnHillbilly = ZedSetFireWithTrenchOnHillbilly.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesKilledWithTrenchOnHillbilly, ZedSetFireWithTrenchOnHillbilly.Value);

	GetStatInt(ZedKilledDuringHillbilly, SteamNameStat[KFSTAT_EnemiesKilledDuringHillbilly]);
	SavedZedKilledDuringHillbilly = ZedKilledDuringHillbilly.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_EnemiesKilledDuringHillbilly, ZedKilledDuringHillbilly.Value);

	GetStatInt(HillbillyAchievementsCompleted, SteamNameStat[KFSTAT_HillbillyAchievementsCompleted]);
	SavedHillbillyAchievementsCompleted = HillbillyAchievementsCompleted.Value;
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_HillbillyAchievementsCompleted, HillbillyAchievementsCompleted.Value);

	GetStatInt(Stat46, SteamNameStat[KFSTAT_Stat46]);
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_Stat46, Stat46.Value);
	GetEventCommand();

	GetStatInt(FleshPoundsKilledWithAxe, SteamNameStat[KFSTAT_FleshPoundsKilledWithAxe]);
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_FleshPoundsKilledWithAxe, FleshPoundsKilledWithAxe.Value);

	GetStatInt(ZedsKilledWhileAirborne, SteamNameStat[KFSTAT_ZedsKilledWhileAirborne]);
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_ZedsKilledWhileAirborne, ZedsKilledWhileAirborne.Value);

	GetStatInt(ZEDSKilledWhileZapped, SteamNameStat[KFSTAT_ZEDSKilledWhileZapped]);
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_ZEDSKilledWhileZapped, ZEDSKilledWhileZapped.Value);


	EnemiesKilledWithMKB42NoReload = 0;
	StalkersKilledWithNail = 0;
	HillbillyCrawlerKills = 0;
	HillbillysKilledIn10Secs = 0;
	HillbillySKilledIn10SecsTime = 0;
	HillbillyGorefastsOnFire = 0;
	HuskAndZedOneShotTotalKills = 0;
	HuskAndZedOneShotZedKills = 0;

	InitStatInt(OwnedWeaponDLC, GetOwnedWeaponDLC());
	PCOwner.ServerInitializeSteamStatInt(KFSTAT_OwnedWeaponDLC, OwnedWeaponDLC.Value);

	// Check which Perks are available on Client
	InitializePerks();
	CheckMedicPerks(false);
	CheckSupportPerks(false);
	CheckSharpshooterPerks(false);
	CheckCommandoPerks(false);
	CheckBerserkerPerks(false);
	CheckFirebugPerks(false);
	CheckDemolitionsPerks(false);

	//Achievements[i].bCompleted = byte(GetAchievementCompleted(Achievements[i].SteamName));

    //use these functions to call out to the server to make sure the servers know if the achievements
    //have been gotten or not
    GetAchievementCompleted(Achievements[131].SteamName);
    GetAchievementCompleted(Achievements[155].SteamName);
    GetAchievementCompleted(Achievements[162].SteamName);
    GetAchievementCompleted(Achievements[193].SteamName);
    GetAchievementCompleted(Achievements[202].SteamName);
    GetAchievementCompleted(Achievements[208].SteamName);

	for ( i = 0; i < Achievements.Length; i++ )
	{
		Achievements[i].bCompleted = byte(GetAchievementCompleted(Achievements[i].SteamName));
		GetAchievementDescription(Achievements[i].SteamName, Achievements[i].DisplayName, Achievements[i].Description);
	}

	CheckHillbillyAchievementsCompleted();

	UpdateAchievementProgress();

	super.OnStatsAndAchievementsReady();
}

// Called on Server to initialize Stats from Client replication, because Servers can't access Steam Stats directly
function InitializeSteamStatInt(int Index, int Value)
{
	//local string MapName;
	if ( bDebugStats )
		log("STEAMSTATS: InitializeSteamStatInt called - Index="$Index @ "Value="$Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	switch ( Index )
	{
		case KFSTAT_DamageHealed:
			InitStatInt(DamageHealedStat, Value);
			break;

		case KFSTAT_WeldingPoints:
			InitStatInt(WeldingPointsStat, Value);
			break;

		case KFSTAT_ShotgunDamage:
			InitStatInt(ShotgunDamageStat, Value);
			break;

		case KFSTAT_HeadshotKills:
			InitStatInt(HeadshotKillsStat, Value);
			break;

		case KFSTAT_StalkerKills:
			InitStatInt(StalkerKillsStat, Value);
			break;

		case KFSTAT_BullpupDamage:
			InitStatInt(BullpupDamageStat, Value);
			break;

		case KFSTAT_MeleeDamage:
			InitStatInt(MeleeDamageStat, Value);
			break;

		case KFSTAT_FlameThrowerDamage:
			InitStatInt(FlameThrowerDamageStat, Value);
			break;

		case KFSTAT_ExplosivesDamage:
			InitStatInt(ExplosivesDamageStat, Value);
			break;

		case KFSTAT_SelfHeals:
			InitStatInt(SelfHealsStat, Value);
			break;

		case KFSTAT_SoleSurvivorWaves:
			InitStatInt(SoleSurvivorWavesStat, Value);
			break;

		case KFSTAT_CashDonated:
			InitStatInt(CashDonatedStat, Value);
			break;

		case KFSTAT_FeedingKills:
			InitStatInt(FeedingKillsStat, Value);
			break;

		case KFSTAT_BurningCrossbowKills:
			InitStatInt(BurningCrossbowKillsStat, Value);
			break;

		case KFSTAT_GibbedFleshpounds:
			InitStatInt(GibbedFleshpoundsStat, Value);
			break;

		case KFSTAT_StalkersKilledWithExplosives:
			InitStatInt(StalkersKilledWithExplosivesStat, Value);
			break;

		case KFSTAT_GibbedEnemies:
			InitStatInt(GibbedEnemiesStat, Value);
			break;

		case KFSTAT_SirensKilledWithExplosives:
			InitStatInt(SirensKilledWithExplosivesStat, Value);
			break;

		case KFSTAT_BloatKills:
			InitStatInt(BloatKillsStat, Value);
			break;

		case KFSTAT_TotalZedTime:
			InitStatFloat(TotalZedTimeStat, Value);
			break;

		case KFSTAT_SirenKills:
			InitStatInt(SirenKillsStat, Value);
			break;

		case KFSTAT_Kills:
			InitStatInt(KillsStat, Value);
			break;

		case KFSTAT_DemolitionsPipebombKills:
			InitStatInt(DemolitionsPipebombKillsStat, Value);
			break;

		case KFSTAT_EnemiesGibbedWithM79:
			InitStatInt(EnemiesGibbedWithM79, Value);
			break;

		case KFSTAT_EnemiesKilledWithSCAR:
			InitStatInt(EnemiesKilledWithSCAR, Value);
			break;

		case KFSTAT_TeammatesHealedWithMP7:
			InitStatInt(TeammatesHealedWithMP7, Value);
			break;

		case KFSTAT_FleshpoundsKilledWithAA12:
			InitStatInt(FleshpoundsKilledWithAA12, Value);
			break;

		case KFSTAT_CrawlersKilledInMidair:
			InitStatInt(CrawlersKilledInMidair, Value);
			break;

		case KFSTAT_Mac10BurnDamage:
			InitStatInt(Mac10BurnDamage, Value);
			break;

		case KFSTAT_DroppedTier3Weapons:
			InitStatInt(DroppedTier3Weapons, Value);
			break;

		case KFSTAT_HalloweenKills:
			InitStatInt(HalloweenKills, Value);
			break;

		case KFSTAT_HalloweenScrakeKills:
			InitStatInt(HalloweenScrakeKills, Value);
			break;

		case KFSTAT_XMasHusksKilledWithHuskCannon:
			InitStatInt(XMasHusksKilledWithHuskCannon, Value);
			break;

		case KFSTAT_XMasPointsHealedWithMP5:
			InitStatInt(XMasPointsHealedWithMP5, Value);
			break;

		case KFSTAT_EnemiesKilledWithFNFal:
			InitStatInt(EnemiesKilledWithFNFal, Value);
			break;

		case KFSTAT_EnemiesKilledWithBullpup:
			InitStatInt(EnemiesKilledWithBullpup, Value);
			break;

		case KFSTAT_EnemiesKilledWithTrenchOnHillbilly:
			InitStatInt(ZedSetFireWithTrenchOnHillbilly, Value);
			break;

		case KFSTAT_EnemiesKilledDuringHillbilly:
			InitStatInt(ZedKilledDuringHillbilly, Value);
			break;

		case KFSTAT_HillbillyAchievementsCompleted:
			InitStatInt(HillbillyAchievementsCompleted, Value);
			break;

		case KFSTAT_Stat46:
			InitStatInt(Stat46, Value);
			break;

		case KFSTAT_FleshPoundsKilledWithAxe:
			InitStatInt(FleshPoundsKilledWithAxe, Value);
			break;

		case KFSTAT_ZedsKilledWhileAirborne:
			InitStatInt(ZedsKilledWhileAirborne, Value);
			break;

		case KFSTAT_ZEDSKilledWhileZapped:
			InitStatInt(ZEDSKilledWhileZapped, Value);
			break;

		case KFSTAT_OwnedWeaponDLC:
			InitStatInt(OwnedWeaponDLC, Value);
			break;
	}

	// Tag changed so the function Trigger would respond to the event of the same name
   	Tag = 'GnomeSoulsCompleted';
}

simulated function bool PlayerOwnsWeaponDLC(int AppID)
{
	return OwnsWeaponDLC(AppID, OwnedWeaponDLC);
}

function string GetWeaponDLCPackName(int AppID)
{
	switch ( AppID )
	{
		case 12560:
			return "Make Shift Weapon DLC Pack";

		case 1255:
			return "Other Weapon DLC Pack";

		case 1257:
			return "Poopinator Weapon DLC Pack";

		case 210934:
		     return "IJC Weapon Pack";
	}

	return "";
}

// Sets the specified Steam Achievement as completed; also, flushes all Stats and Achievements to the client
simulated function SetSteamAchievementCompleted(int Index)
{
	if ( bDebugStats )
		log("STEAMSTATS: SetSteamAchievementCompleted called - Name="$Achievements[Index].SteamName @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	FlushStatsToClient();
	SetLocalAchievementCompleted(Index);
	SetAchievementCompleted(Achievements[Index].SteamName);
}

// Called from multiple locations on Client and Server to set Achievement booleans for later use
simulated event SetLocalAchievementCompleted(int Index)
{
	if ( bDebugStats )
		log("STEAMSTATS: SetLocalAchievementCompleted called - Name="$Achievements[Index].SteamName @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	Achievements[Index].bCompleted = 1;
	//PCOwner.myHUD.ShowPopupNotification(5.0, 3, Achievements[Index].SteamName, Achievements[Index].Icon);
	//Level.Game.Broadcast(PCOwner, "Achievement Unlocked:" @ Achievements[Index].SteamName);
}

function ServerSteamStatsAndAchievementsInitialized()
{
	// Check which Perks are available on Server
	InitializePerks();
	CheckMedicPerks(false);
	CheckSupportPerks(false);
	CheckSharpshooterPerks(false);
	CheckCommandoPerks(false);
	CheckBerserkerPerks(false);
	CheckFirebugPerks(false);
	CheckDemolitionsPerks(false);

   	if ( Achievements[KFACHIEVEMENT_WinAllMapsNormal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinWestLondonNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinManorNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinBioticsLabNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFarmNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinOfficesNormal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsNormal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinAllMapsHard].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinWestLondonHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinManorHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinBioticsLabHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFarmHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinOfficesHard].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsHard);
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinAllMapsSuicidal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinWestLondonSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinManorSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinBioticsLabSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFarmSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinOfficesSuicidal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsSuicidal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinAll3SummerMapsNormal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinFoundryNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinAsylumNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWyreNormal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsNormal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinAll3SummerMapsHard].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinFoundryHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinAsylumHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWyreHard].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsHard);
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinAll3SummerMapsSuicidal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinFoundrySuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinAsylumSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWyreSuicidal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsSuicidal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_CompleteNewAchievementsNormal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinBiohazardNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinCrashNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinDepartedNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFilthsCrossNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinHospitalHorrorsNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinIcebreakerNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinMountainPassNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinSuburbiaNormal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWaterworksNormal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsNormal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_CompleteNewAchievementsHard].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinBiohazardHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinCrashHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinDepartedHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFilthsCrossHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinHospitalHorrorsHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinIcebreakerHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinMountainPassHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinSuburbiaHard].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWaterworksHard].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsHard);
		}
	}

	if ( Achievements[KFACHIEVEMENT_CompleteNewAchievementsSuicidal].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinBiohazardSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinCrashSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinDepartedSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFilthsCrossSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinHospitalHorrorsSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinIcebreakerSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinMountainPassSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinSuburbiaSuicidal].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWaterworksSuicidal].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsSuicidal);
		}
	}

	if ( Achievements[KFACHIEVEMENT_CompleteNewAchievementsHell].bCompleted == 0 )
	{
		if ( Achievements[KFACHIEVEMENT_WinWestLondonHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinManorHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinBioticsLabHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFarmHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinOfficesHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFoundryHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinAsylumHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWyreHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinBiohazardHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinCrashHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinDepartedHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinFilthsCrossHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinHospitalHorrorsHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinIcebreakerHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinMountainPassHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinSuburbiaHell].bCompleted == 1 &&
			 Achievements[KFACHIEVEMENT_WinWaterworksHell].bCompleted == 1 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsHell);
		}
	}

	CheckChristmasAchievementsCompleted();
	CheckSideshowAchievementsCompleted();
	CheckHillbillyAchievementsCompleted();
	CheckHalloweenAchievementsCompleted();

	super.ServerSteamStatsAndAchievementsInitialized();
}

// Called when the owner of this Stats Actor dies(used to reset "in one life" stats)
function PlayerDied()
{
	if ( bDebugStats )
		log("STEAMSTATS: PlayerDied resetting 'in one life' Stats - Player="$PCOwner.PlayerReplicationInfo.PlayerName);
}

function MatchEnded()
{
	if ( bDebugStats )
		log("STEAMSTATS: MatchEnded - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	// Reset any "per life" Stats
	PlayerDied();

	if ( !bFlushStatsToClient )
	{
		FlushStatsToClient();
	}
}

simulated function UpdateAchievementProgress()
{
	local int i, NormalMapsCompleted, HardMapsCompleted, SuicidalMapsCompleted, PerksMaxed;
	local int NormalSummerMapsCompleted, HardSummerMapsCompleted, SuicidalSummerMapsCompleted;
	local int ChristmasAchievementsCompleted, SideshowAchievementsCompleted, HalloweenAchievementsCompleted;
	//local int HillbillyAchievementsCompleted;

	for ( i = KFACHIEVEMENT_WinWestLondonNormal; i <= KFACHIEVEMENT_WinBioticsLabNormal; i++ )
	{
		if ( Achievements[i].bCompleted == 1 )
		{
			NormalMapsCompleted++;
		}
	}

	for ( i = KFACHIEVEMENT_WinWestLondonHard; i <= KFACHIEVEMENT_WinBioticsLabHard; i++ )
	{
		if ( Achievements[i].bCompleted == 1 )
		{
			HardMapsCompleted++;
		}
	}

	for ( i = KFACHIEVEMENT_WinWestLondonSuicidal; i <= KFACHIEVEMENT_WinBioticsLabSuicidal; i++ )
	{
		if ( Achievements[i].bCompleted == 1 )
		{
			SuicidalMapsCompleted++;
		}
	}

	if ( Achievements[KFACHIEVEMENT_WinFoundryNormal].bCompleted == 1 )
		NormalSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinAsylumNormal].bCompleted == 1 )
		NormalSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinWyreNormal].bCompleted == 1 )
		NormalSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinFoundryHard].bCompleted == 1 )
		HardSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinAsylumHard].bCompleted == 1 )
		HardSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinWyreHard].bCompleted == 1 )
		HardSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinFoundrySuicidal].bCompleted == 1 )
		SuicidalSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinAsylumSuicidal].bCompleted == 1 )
		SuicidalSummerMapsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinWyreSuicidal].bCompleted == 1 )
		SuicidalSummerMapsCompleted++;

	for ( i = 0; i < 7; i++ )
	{
		if ( PerkHighestLevelAvailable(i) >= 5 )
		{
			PerksMaxed++;
		}
	}

	if ( Achievements[KFACHIEVEMENT_KillChristmasPatriarch].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KnifeChristmasFleshpound].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill2ChristmasGorefastFromBack].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasScrakeWithFire].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3ChristmasBloatsWithBullpup].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill20ChristmasClots].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasCrawlerWithXBow].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasSirenWithLawImpact].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3ChristmasStalkersWithLAR].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasHuskWithPistol].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill3ChristmasZedsInOneSlomo].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_ChristmasVomitLive10Seconds].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinSantasEvilLairNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairHell].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveHell].bCompleted == 1 )
	{
		ChristmasAchievementsCompleted = Min(10, ChristmasAchievementsCompleted) + 1;
	}
	else
	{
		ChristmasAchievementsCompleted = Min(10, ChristmasAchievementsCompleted);
	}

	if ( Achievements[KFACHIEVEMENT_KillSideshowPatriarch].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowGorefastWithMelee].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill2SideshowStalkerWithBackstab].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowCrawlersWithBullpup].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowBloats].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowScrakeWithCrossbow].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowHuskWithLAW].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3SideshowClotsWithLAR].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowFleshpoundWithPistol].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Drop5Tier2WeaponsOneWaveSideshow].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_SurviveSideshowSirenScreamPlus10Sec].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill4SideshowZedsInOneSlomo].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill10SideshowClotsWithFireWeapon].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinSideshowNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowHell].bCompleted == 1 )
	{
		SideshowAchievementsCompleted = Min(10, SideshowAchievementsCompleted) + 1;
	}
	else
	{
		SideshowAchievementsCompleted = Min(10, SideshowAchievementsCompleted);
	}

	if ( Achievements[KFACHIEVEMENT_KillHalloweenPatriarchInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_DecapBurningHalloweenZedInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinBedlamHardHalloween].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5HalloweenZedsWithoutReload].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	Achievements[KFACHIEVEMENT_WinAllMapsNormal].ProgressNumerator = NormalMapsCompleted;
	Achievements[KFACHIEVEMENT_WinAllMapsHard].ProgressNumerator = HardMapsCompleted;
	Achievements[KFACHIEVEMENT_WinAllMapsSuicidal].ProgressNumerator = SuicidalMapsCompleted;
	Achievements[KFACHIEVEMENT_KillXEnemies].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXEnemies].ProgressDenominator, KillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXEnemies2].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXEnemies2].ProgressDenominator, KillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXEnemies3].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXEnemies3].ProgressDenominator, KillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXBloats].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXBloats].ProgressDenominator, BloatKillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXSirens].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXSirens].ProgressDenominator, SirenKillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXStalkersWithExplosives].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXStalkersWithExplosives].ProgressDenominator, StalkersKilledWithExplosivesStat.Value);
	Achievements[KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow].ProgressDenominator, BurningCrossbowKillsStat.Value);
	Achievements[KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses].ProgressDenominator, FeedingKillsStat.Value);
	Achievements[KFACHIEVEMENT_TurnXEnemiesIntoGiblets].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_TurnXEnemiesIntoGiblets].ProgressDenominator, GibbedEnemiesStat.Value);
	Achievements[KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets].ProgressDenominator, GibbedFleshpoundsStat.Value);
	Achievements[KFACHIEVEMENT_HealSelfXTimes].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_HealSelfXTimes].ProgressDenominator, SelfHealsStat.Value);
	Achievements[KFACHIEVEMENT_OnlySurvivorXWaves].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_OnlySurvivorXWaves].ProgressDenominator, SoleSurvivorWavesStat.Value);
	Achievements[KFACHIEVEMENT_DonateXCashToTeammates].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_DonateXCashToTeammates].ProgressDenominator, CashDonatedStat.Value);
	Achievements[KFACHIEVEMENT_AcquireXMinutesOfZedTime].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_AcquireXMinutesOfZedTime].ProgressDenominator, int(TotalZedTimeStat.Value / 60.0));
	Achievements[KFACHIEVEMENT_MaxOutAllPerks].ProgressNumerator = PerksMaxed;
	Achievements[KFACHIEVEMENT_WinAll3SummerMapsNormal].ProgressNumerator = NormalSummerMapsCompleted;
	Achievements[KFACHIEVEMENT_WinAll3SummerMapsHard].ProgressNumerator = HardSummerMapsCompleted;
	Achievements[KFACHIEVEMENT_WinAll3SummerMapsSuicidal].ProgressNumerator = SuicidalSummerMapsCompleted;
	Achievements[KFACHIEVEMENT_Kill1000EnemiesWithPipebomb].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill1000EnemiesWithPipebomb].ProgressDenominator, DemolitionsPipebombKillsStat.Value);
	Achievements[KFACHIEVEMENT_Gib500ZedsWithM79].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Gib500ZedsWithM79].ProgressDenominator, EnemiesGibbedWithM79.Value);
	Achievements[KFACHIEVEMENT_Kill1000ZedsWithSCAR].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill1000ZedsWithSCAR].ProgressDenominator, EnemiesKilledWithSCAR.Value);
	Achievements[KFACHIEVEMENT_Heal200TeammatesWithMP7].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Heal200TeammatesWithMP7].ProgressDenominator, TeammatesHealedWithMP7.Value);
	Achievements[KFACHIEVEMENT_Kill100FleshpoundsWithAA12].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill100FleshpoundsWithAA12].ProgressDenominator, FleshpoundsKilledWithAA12.Value);
	Achievements[KFACHIEVEMENT_Kill20CrawlersKilledInAir].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill20CrawlersKilledInAir].ProgressDenominator, CrawlersKilledInMidair.Value);
	Achievements[KFACHIEVEMENT_Get1000BurnDamageWithMac10].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Get1000BurnDamageWithMac10].ProgressDenominator, Mac10BurnDamage.Value);
	Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].ProgressDenominator, DroppedTier3Weapons.Value);
	Achievements[KFACHIEVEMENT_Unlock10ofChristmasAchievements].ProgressNumerator = ChristmasAchievementsCompleted;
	Achievements[KFACHIEVEMENT_Unlock10ofSideshowAchievements].ProgressNumerator = SideshowAchievementsCompleted;
	Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].ProgressDenominator, HalloweenKills.Value);
	Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].ProgressDenominator, HalloweenScrakeKills.Value);
	Achievements[KFACHIEVEMENT_Unlock6ofHalloweenAchievements].ProgressNumerator = HalloweenAchievementsCompleted;
	Achievements[KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon].ProgressDenominator, XMasHusksKilledWithHuskCannon.Value);
	Achievements[KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas].ProgressDenominator, XMasPointsHealedWithMP5.Value);

	// Hillbilly Acievement Progress
	Achievements[KFACHIEVEMENT_Kill4StalkersNailgun].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill4StalkersNailgun].ProgressDenominator, StalkersKilledWithNail);
	Achievements[KFACHIEVEMENT_Set200ZedOnFireOnHillbilly].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Set200ZedOnFireOnHillbilly].ProgressDenominator, SavedZedSetFireWithTrenchOnHillbilly);
	Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].ProgressDenominator, SavedHillbillyAchievementsCompleted);
	Achievements[KFACHIEVEMENT_Kill1000HillbillyZeds].ProgressNumerator =  Min(Achievements[KFACHIEVEMENT_Kill1000HillbillyZeds].ProgressDenominator, SavedZedKilledDuringHillbilly);
	Achievements[KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB].ProgressDenominator, HillbillyCrawlerKills);

	Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].ProgressDenominator, SavedHillbillyAchievementsCompleted);
	Achievements[KFACHIEVEMENT_Kill1000HillbillyZeds].ProgressNumerator =  Min(Achievements[KFACHIEVEMENT_Kill1000HillbillyZeds].ProgressDenominator, SavedZedKilledDuringHillbilly);
	Achievements[KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB].ProgressDenominator, HillbillyCrawlerKills);

	Achievements[KFACHIEVEMENT_HaveMyAxe].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_HaveMyAxe].ProgressDenominator, FleshPoundsKilledWithAxe.Value);
	Achievements[KFACHIEVEMENT_OneSmallStepForMan].ProgressNumerator =  Min(Achievements[KFACHIEVEMENT_OneSmallStepForMan].ProgressDenominator, ZedsKilledWhileAirborne.Value);
	Achievements[KFACHIEVEMENT_GameOverMan].ProgressNumerator = Min(Achievements[KFACHIEVEMENT_GameOverMan].ProgressDenominator, ZEDSKilledWhileZapped.Value);
}

simulated function int GetAchievementCompletedCount()
{
	local int i, Count;

	Count = 0;

	for ( i = 0; i < Achievements.Length; i++ )
	{
		if ( Achievements[i].bCompleted == 1 )
		{
			Count++;
		}
	}

	return Count;
}

// Server callback from native when new Perk unlocked
event OnPerkAvailable()
{
	local int i;

	if ( bInitialized )
	{
		FlushStatsToClient();
	}

	if ( KFPC(PCOwner) != none )
	{
		KFPC(PCOwner).bChangedVeterancyThisWave = false;
		KFPC(PCOwner).SendSelectedVeterancyToServer();
		KFPC(PCOwner).bChangedVeterancyThisWave = false;
	}

	for ( i = 0; i < 7; i++ )
	{
		if ( PerkHighestLevelAvailable(i) < 5 )
		{
			break;
		}

		if ( i == 6 && Achievements[KFACHIEVEMENT_MaxOutAllPerks].bCompleted == 0 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_MaxOutAllPerks);
		}
	}
}

// Client callback to show pop up notification
simulated event NotifyPerkAvailable(int Type, int Level)
{
	if ( KFPC(PCOwner) != none )
	{
		KFPC(PCOwner).NotifyPerkAvailable(Type, Level);
	}
}

simulated function int GetPerkProgressDetailsCount(int Type)
{
	switch ( Type )
	{
		case 0: // Medic
			return 1;
		case 1: // Support
			return 2;
		case 2: // Sharpshooter
			return 1;
		case 3: // Commando
			return 2;
		case 4: // Berserker
			return 1;
		case 5: // Firebug
			return 1;
		case 6: // Demolitions
			return 1;
	}
}

simulated function GetPerkProgressDetails(int Type, int Index, out int CurrentValue, out int RequiredValue, out float Progress)
{
	switch ( Type )
	{
		case 0: // Medic
			GetMedicProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 1: // Support
			GetSupportProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 2: // Sharpshooter
			GetSharpshooterProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 3: // Commando
			GetCommandoProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 4: // Berserker
			GetBerserkerProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 5: // Firebug
			GetFirebugProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;

		case 6: // Demolitions
			GetDemolitionsProgressDetails(Index, CurrentValue, RequiredValue, Progress);
			break;
	}
}

function AddDamageHealed(int Amount, optional bool bMP7MHeal, optional bool bMP5MHeal)
{
	SetStatInt(DamageHealedStat, DamageHealedStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding DamageHealed - NewValue="$DamageHealedStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckMedicPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));

	if ( bMP7MHeal )
	{
		SetStatInt(TeammatesHealedWithMP7, TeammatesHealedWithMP7.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding MP7M DamageHealed - NewValue="$TeammatesHealedWithMP7.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Heal200TeammatesWithMP7].bCompleted == 0 && TeammatesHealedWithMP7.Value >= Achievements[KFACHIEVEMENT_Heal200TeammatesWithMP7].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Heal200TeammatesWithMP7);
		}
	}

	if ( bMP5MHeal )
	{
		SetStatInt(XMasPointsHealedWithMP5, XMasPointsHealedWithMP5.Value + Amount);

		if ( bDebugStats )
			log("STEAMSTATS: Adding MP5M DamageHealed - NewValue="$XMasPointsHealedWithMP5.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas].bCompleted == 0 && XMasPointsHealedWithMP5.Value >= Achievements[KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Heal3000PointsWithMP5DuringXMas);
		}
	}
}

function AddWeldingPoints(int Amount)
{
	SetStatInt(WeldingPointsStat, WeldingPointsStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding WeldingPoints - NewValue="$WeldingPointsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckSupportPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddShotgunDamage(int Amount)
{
	SetStatInt(ShotgunDamageStat, ShotgunDamageStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Shotgun Damage - NewValue="$ShotgunDamageStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckSupportPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddHeadshotKill(bool bLaserSightedEBRHeadshot)
{
	SetStatInt(HeadshotKillsStat, HeadshotKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Headshot Kill - NewValue="$HeadshotKillsStat.Value @ "bLaserM14="$bLaserSightedEBRHeadshot @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckSharpshooterPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));

	if ( Achievements[KFACHIEVEMENT_LaserSightedEBRHeadshots25InARow].bCompleted == 0 )
	{
		if ( bLaserSightedEBRHeadshot )
		{
			SetStatInt(LaserSightedEBRHeadshots, LaserSightedEBRHeadshots.Value + 1);

			if ( bDebugStats )
				log("STEAMSTATS: Adding Laser Sighted EBRM14 Headshot Kill - NewValue="$LaserSightedEBRHeadshots.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

			if ( LaserSightedEBRHeadshots.Value >= 25 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_LaserSightedEBRHeadshots25InARow);
			}
		}
		else
		{
			SetStatInt(LaserSightedEBRHeadshots, 0);
		}
	}
}

function AddStalkerKill()
{
	SetStatInt(StalkerKillsStat, StalkerKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Stalker Kill - NewValue="$StalkerKillsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckCommandoPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddBullpupDamage(int Amount)
{
	SetStatInt(BullpupDamageStat, BullpupDamageStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Bullpup Damage - NewValue="$BullpupDamageStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckCommandoPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddMeleeDamage(int Amount)
{
	SetStatInt(MeleeDamageStat, MeleeDamageStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding MeleeDamage - NewValue="$MeleeDamageStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckBerserkerPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddFlameThrowerDamage(int Amount)
{
	SetStatInt(FlameThrowerDamageStat, FlameThrowerDamageStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding FlameThrowerDamage - NewValue="$FlameThrowerDamageStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckFirebugPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function AddExplosivesDamage(int Amount)
{
	SetStatInt(ExplosivesDamageStat, ExplosivesDamageStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding ExplosivesDamage - NewValue="$ExplosivesDamageStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	CheckDemolitionsPerks(Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()));
}

function WonGame(string MapName, float Difficulty, bool bLong)
{
	if ( bDebugStats )
		log("STEAMSTATS: Won Long Game - MapName="$MapName @ "Difficulty="$Difficulty @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( bLong )
	{
		if ( MapName ~= "KF-WestLondon" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinWestLondonNormal);
		}
		else if ( MapName ~= "KF-Manor" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinManorNormal);
		}
		else if ( MapName ~= "KF-BioticsLab" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinBioticsLabNormal);
		}
		else if ( MapName ~= "KF-Farm" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinFarmNormal);
		}
		else if ( MapName ~= "KF-Offices" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinOfficesNormal);
		}
		else if ( MapName ~= "KF-Foundry" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinFoundryNormal);
		}
		else if ( MapName ~= "KF-Bedlam" )
		{
            if ( Difficulty == 4.0 )
			{
				if ( Achievements[KFACHIEVEMENT_WinBedlamHardHalloween].bCompleted == 0 )
				{
					SetSteamAchievementCompleted(KFACHIEVEMENT_WinBedlamHardHalloween);
					CheckHalloweenAchievementsCompleted();
				}
			}
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinAsylumNormal);
		}
		else if ( MapName ~= "KF-Wyre" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinWyreNormal);
		}
		else if ( MapName ~= "KF-Biohazard" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinBiohazardNormal);
		}
		else if ( MapName ~= "KF-Crash" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinCrashNormal);
		}
		else if ( MapName ~= "KF-Departed" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinDepartedNormal);
		}
		else if ( MapName ~= "KF-FilthsCross" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinFilthsCrossNormal);
		}
		else if ( MapName ~= "KF-Hospitalhorrors" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinHospitalHorrorsNormal);
		}
		else if ( MapName ~= "KF-Icebreaker" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinIcebreakerNormal);
		}
		else if ( MapName ~= "KF-MountainPass" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinMountainPassNormal);
		}
		else if ( MapName ~= "KF-Suburbia" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinSuburbiaNormal);
		}
		else if ( MapName ~= "KF-Waterworks" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinWaterworksNormal);
		}
		else if ( MapName ~= "KF-Aperture" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinApertureNormal);
		}
		else if ( MapName ~= "KF-AbusementPark" )
		{
			CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinSideshowNormal);
		}

		if ( Difficulty == 2.0 && Achievements[KFACHIEVEMENT_WinAllMapsNormal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinWestLondonNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinManorNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinBioticsLabNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFarmNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinOfficesNormal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsNormal);
			}
		}

		if ( Difficulty == 4.0 && Achievements[KFACHIEVEMENT_WinAllMapsHard].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinWestLondonHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinManorHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinBioticsLabHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFarmHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinOfficesHard].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsHard);
			}
		}

		if ( Difficulty == 5.0 && Achievements[KFACHIEVEMENT_WinAllMapsSuicidal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinWestLondonSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinManorSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinBioticsLabSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFarmSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinOfficesSuicidal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAllMapsSuicidal);
			}
		}

		if ( Difficulty == 2.0 && Achievements[KFACHIEVEMENT_WinAll3SummerMapsNormal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinFoundryNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinAsylumNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWyreNormal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsNormal);
			}
		}

		if ( Difficulty == 4.0 && Achievements[KFACHIEVEMENT_WinAll3SummerMapsHard].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinFoundryHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinAsylumHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWyreHard].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsHard);
			}
		}

		if ( Difficulty == 5.0 && Achievements[KFACHIEVEMENT_WinAll3SummerMapsSuicidal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinFoundrySuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinAsylumSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWyreSuicidal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_WinAll3SummerMapsSuicidal);
			}
		}

		if ( Difficulty == 2.0 && Achievements[KFACHIEVEMENT_CompleteNewAchievementsNormal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinBiohazardNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinCrashNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinDepartedNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFilthsCrossNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinHospitalHorrorsNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinIcebreakerNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinMountainPassNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinSuburbiaNormal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWaterworksNormal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsNormal);
			}
		}

		if ( Difficulty == 4.0 && Achievements[KFACHIEVEMENT_CompleteNewAchievementsHard].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinBiohazardHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinCrashHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinDepartedHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFilthsCrossHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinHospitalHorrorsHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinIcebreakerHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinMountainPassHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinSuburbiaHard].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWaterworksHard].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsHard);
			}
		}

		if ( Difficulty == 5.0 && Achievements[KFACHIEVEMENT_CompleteNewAchievementsSuicidal].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinBiohazardSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinCrashSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinDepartedSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFilthsCrossSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinHospitalHorrorsSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinIcebreakerSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinMountainPassSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinSuburbiaSuicidal].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWaterworksSuicidal].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsSuicidal);
			}
		}

		if ( Difficulty == 7.0 && Achievements[KFACHIEVEMENT_CompleteNewAchievementsHell].bCompleted == 0 )
		{
			if ( Achievements[KFACHIEVEMENT_WinWestLondonHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinManorHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinBioticsLabHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFarmHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinOfficesHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFoundryHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinAsylumHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWyreHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinBiohazardHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinCrashHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinDepartedHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinFilthsCrossHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinHospitalHorrorsHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinIcebreakerHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinMountainPassHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinSuburbiaHell].bCompleted == 1 &&
				 Achievements[KFACHIEVEMENT_WinWaterworksHell].bCompleted == 1 )
			{
				SetSteamAchievementCompleted(KFACHIEVEMENT_CompleteNewAchievementsHell);
			}
		}
	}

	if ( MapName ~= "KF-IceCave" )
	{
		CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinIceCaveNormal);
		CheckChristmasAchievementsCompleted();
	}
	else if ( MapName ~= "KF-EvilSantasLair" )
	{
		CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinSantasEvilLairNormal);
		CheckChristmasAchievementsCompleted();
	}
	else if ( MapName ~= "KF-Hellride" )
	{
		CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinHellrideNormal);
	}
	else if ( MapName ~= "KF-HillbillyHorror" )
	{
		CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinHillbillyNormal);
		CheckHillbillyAchievementsCompleted();
	}
	else if ( MapName ~= "KF-Moonbase" )
	{
		CheckEndGameAchievements(Difficulty, KFACHIEVEMENT_WinMoonBaseNormal);
	}
}

/* Checks what difficulty you completed the game on and sets the appropriate achievement to true */
function CheckEndGameAchievements(float Difficulty, int MapNormalDifficulty)
{
	if ( Difficulty == 2.0 && Achievements[MapNormalDifficulty].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(MapNormalDifficulty);
	}
	else if ( Difficulty == 4.0 && Achievements[MapNormalDifficulty + 1].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(MapNormalDifficulty + 1);
	}
	else if ( Difficulty == 5.0 && Achievements[MapNormalDifficulty + 2].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(MapNormalDifficulty + 2);
	}
	else if ( Difficulty == 7.0 && Achievements[MapNormalDifficulty + 3].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(MapNormalDifficulty + 3);
	}
}

function WaveEnded()
{
	if ( bDebugStats )
		log("STEAMSTATS: WaveEnded resetting 'Single Wave' Stats - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	InitStatInt(FireAxeKills, 0);
	InitStatInt(ChainsawKills, 0);
	InitStatInt(MedicKnifeKills, 0);
	InitStatInt(GorefastBackstabKills, 0);
	InitStatInt(BloatBullpupKills, 0);
	InitStatInt(ClotKills, 0);
	InitStatInt(StalkerBackstabKills, 0);
	InitStatInt(CrawlerBullpupKills, 0);
	InitStatInt(LARClotKills, 0);
}

function ZedTimeChainEnded()
{
	if ( bDebugStats )
		log("STEAMSTATS: ZedTimeChainEnded resetting Stats - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	InitStatInt(MeleeKills, 0);
}

function AddKill(bool bLaserSightedEBRM14Headshotted, bool bMeleeKill, bool bZEDTimeActive, bool bM4Kill, bool bBenelliKill, bool bRevolverKill, bool bMK23Kill, bool bFNFalKill, bool bBullpupKill, string MapName)
{
	SetStatInt(KillsStat, KillsStat.Value + 1);
	SetStatInt(HalloweenSpecimensKilledWithoutReloading, HalloweenSpecimensKilledWithoutReloading.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Kill - NewKills="$KillsStat.Value @ "bLaserM14="$bLaserSightedEBRM14Headshotted @ "Melee="$bMeleeKill @ "M4="$bM4Kill @ "ZedTime="$bZEDTimeActive @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXEnemies].bCompleted == 0 && KillsStat.Value >= Achievements[KFACHIEVEMENT_KillXEnemies].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemies);
	}

	if ( Achievements[KFACHIEVEMENT_KillXEnemies2].bCompleted == 0 && KillsStat.Value >= Achievements[KFACHIEVEMENT_KillXEnemies2].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemies2);
	}

	if ( Achievements[KFACHIEVEMENT_KillXEnemies3].bCompleted == 0 && KillsStat.Value >= Achievements[KFACHIEVEMENT_KillXEnemies3].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemies3);
	}

	if ( !bLaserSightedEBRM14Headshotted )
	{
		SetStatInt(LaserSightedEBRHeadshots, 0);

		if ( bDebugStats )
			log("STEAMSTATS: Reseting Laser Sighted EBRM14 Headshot Kills - NewKills="$LaserSightedEBRHeadshots.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bZEDTimeActive && bMeleeKill )
	{
		SetStatInt(MeleeKills, MeleeKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Melee Kill - NewValue="$MeleeKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_MeleeKill4SideshowZedsInOneSlomo].bCompleted == 0 && MeleeKills.Value >= 4 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_MeleeKill4SideshowZedsInOneSlomo);
			CheckSideshowAchievementsCompleted();
		}

		if ( Achievements[KFACHIEVEMENT_MeleeKill3ChristmasZedsInOneSlomo].bCompleted == 0 && MeleeKills.Value >= 3 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_MeleeKill3ChristmasZedsInOneSlomo);
			CheckChristmasAchievementsCompleted();
		}
	}

	if ( bM4Kill )
	{
		SetStatInt(M4SingleClipXMasKills, M4SingleClipXMasKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding M4 Single Clip Kill - NewKills="$M4SingleClipXMasKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bBenelliKill )
	{
		SetStatInt(BenelliSingleClipXMasKills, BenelliSingleClipXMasKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Benelli Single Clip Kill - NewKills="$BenelliSingleClipXMasKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bRevolverKill )
	{
		SetStatInt(RevolverSingleClipXMasKills, RevolverSingleClipXMasKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Revolver Single Clip Kill - NewKills="$RevolverSingleClipXMasKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bMK23Kill )
	{
		SetStatInt(MK23SingleClipKills, MK23SingleClipKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding MK23 Single Clip Kill - NewKills="$MK23SingleClipKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bFNFalKill )
	{
		SetStatInt(EnemiesKilledWithFNFal, EnemiesKilledWithFNFal.Value + 1);
		CheckBritishSuperiority();

		if ( bDebugStats )
			log("STEAMSTATS: Adding FNFal Kill - NewKills="$EnemiesKilledWithFNFal.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( bBullpupKill )
	{
		SetStatInt(EnemiesKilledWithBullpup, EnemiesKilledWithBullpup.Value + 1);
		CheckBritishSuperiority();

		if ( bDebugStats )
			log("STEAMSTATS: Adding Bullpup Kill - NewKills="$EnemiesKilledWithBullpup.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}

	if ( Achievements[KFACHIEVEMENT_Kill5HalloweenZedsWithoutReload].bCompleted == 0 && HalloweenSpecimensKilledWithoutReloading.Value >= 5 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill5HalloweenZedsWithoutReload);
		CheckHalloweenAchievementsCompleted();
	}

	if ( MapName ~= "KF-Bedlam" )
	{
		SetStatInt(HalloweenKills, HalloweenKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Halloween Kill - NewKills="$HalloweenKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].bCompleted == 0 && HalloweenKills.Value >= Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Kill250HalloweenZedsInBedlam);
			CheckHalloweenAchievementsCompleted();
		}
	}
}

function AddClotKill()
{
	SetStatInt(ClotKills, ClotKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Clot Kill - NewValue="$ClotKills.Value @ "XMasValue="$XMas20MinuteClotKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill20ChristmasClots].bCompleted == 0 && ClotKills.Value >= 20 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill20ChristmasClots);
		CheckChristmasAchievementsCompleted();
	}

	SetStatInt(XMas20MinuteClotKills, XMas20MinuteClotKills.Value + 1);
	Check20MinuteAchievement();
}

function AddBloatKill(bool bWithBullpup)
{
	SetStatInt(BloatKillsStat, BloatKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Bloat Kill - NewValue="$BloatKillsStat.Value @ "XMasValue="$XMas20MinuteBloatKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXBloats].bCompleted == 0 && BloatKillsStat.Value >= Achievements[KFACHIEVEMENT_KillXBloats].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXBloats);
	}

	if ( bWithBullpup )
	{
		SetStatInt(BloatBullpupKills, BloatBullpupKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Bloat Bullpup Kill - NewValue="$BloatBullpupKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Kill3ChristmasBloatsWithBullpup].bCompleted == 0 && BloatBullpupKills.Value >= 3 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Kill3ChristmasBloatsWithBullpup);
			CheckChristmasAchievementsCompleted();
		}
	}

	SetStatInt(XMas20MinuteBloatKills, XMas20MinuteBloatKills.Value + 1);
	Check20MinuteAchievement();
	SetStatInt(BloatKills, BloatKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Sideshow Bloat Kill - NewValue="$BloatKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowBloats].bCompleted == 0 && BloatKills.Value >= 5 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill5SideshowBloats);
		CheckSideshowAchievementsCompleted();
	}
}

function AddSirenKill(bool bLawRocketImpact)
{
	SetStatInt(SirenKillsStat, SirenKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Siren Kill - NewValue="$SirenKillsStat.Value @ "XMasValue="$XMas20MinuteSirenKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXSirens].bCompleted == 0 && SirenKillsStat.Value >= Achievements[KFACHIEVEMENT_KillXSirens].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXSirens);
	}

	if ( bLawRocketImpact && Achievements[KFACHIEVEMENT_KillChristmasSirenWithLawImpact].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillChristmasSirenWithLawImpact);
		CheckChristmasAchievementsCompleted();
	}

	SetStatInt(XMas20MinuteSirenKills, XMas20MinuteSirenKills.Value + 1);
	Check20MinuteAchievement();
}

function AddDemolitionsPipebombKill()
{
	SetStatInt(DemolitionsPipebombKillsStat, DemolitionsPipebombKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Demolitions Pipebomb Kill - NewValue="$DemolitionsPipebombKillsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill1000EnemiesWithPipebomb].bCompleted == 0 && DemolitionsPipebombKillsStat.Value >= Achievements[KFACHIEVEMENT_Kill1000EnemiesWithPipebomb].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill1000EnemiesWithPipebomb);
	}
}

function AddStalkerKillWithExplosives()
{
	SetStatInt(StalkersKilledWithExplosivesStat, StalkersKilledWithExplosivesStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Stalker Explosives Kill - NewValue="$StalkersKilledWithExplosivesStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXStalkersWithExplosives].bCompleted == 0 && StalkersKilledWithExplosivesStat.Value >= Achievements[KFACHIEVEMENT_KillXStalkersWithExplosives].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXStalkersWithExplosives);
	}
}

function AddFireAxeKill()
{
	SetStatInt(FireAxeKills, FireAxeKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Fire Axe Kill - NewValue="$FireAxeKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXEnemiesWithFireAxe].bCompleted == 0 && FireAxeKills.Value >= 15 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemiesWithFireAxe);
	}
}

function AddChainsawScrakeKill()
{
	SetStatInt(ChainsawKills, ChainsawKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Chainsaw Scrake Kill - NewValue="$ChainsawKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXScrakesWithChainsaw].bCompleted == 0 && ChainsawKills.Value >= 2 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXScrakesWithChainsaw);
	}
}

function AddBurningCrossbowKill()
{
	SetStatInt(BurningCrossbowKillsStat, BurningCrossbowKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Burning Crossbow Kill - NewValue="$BurningCrossbowKillsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow].bCompleted == 0 && BurningCrossbowKillsStat.Value >= Achievements[KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXBurningEnemiesWithCrossbow);
	}
}

function AddFeedingKill()
{
	SetStatInt(FeedingKillsStat, FeedingKillsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Feeding Kill - NewValue="$FeedingKillsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses].bCompleted == 0 && FeedingKillsStat.Value >= Achievements[KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemiesFeedingOnCorpses);
	}
}

function OnShotHuntingShotgun()
{
	if ( bDebugStats )
		log("STEAMSTATS: Resetting Hunting Shotgun Kills");

	InitStatInt(HuntingShotgunKills, 0);
}

function OnShotM99()
{
	if ( bDebugStats )
		log("STEAMSTATS: Resetting M99 Kills");

	OneShotBuzzOrM99();
	InitStatInt(M99Kills, 0);
}

function AddHuntingShotgunKill()
{
	SetStatInt(HuntingShotgunKills, HuntingShotgunKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Hunting Shotgun Kill - NewValue="$HuntingShotgunKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill4EnemiesWithHuntingShotgunShot].bCompleted == 0 && HuntingShotgunKills.Value >= 4 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill4EnemiesWithHuntingShotgunShot);
	}
}

function KilledEnemyWithBloatAcid()
{
	if ( bDebugStats )
		log("STEAMSTATS: KilledEnemyWithBloatAcid - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillEnemyUsingBloatAcid].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillEnemyUsingBloatAcid);
	}
}

function KilledFleshpound(bool bWithMeleeAttack, bool bWithAA12, bool bWithKnife, bool bWithClaymore)
{
    log(bWithClaymore);
	if ( bWithMeleeAttack )
	{
		if ( bDebugStats )
			log("STEAMSTATS: KilledFleshpoundWithMeleeAttack - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_KillFleshpoundWithMelee].bCompleted == 0 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_KillFleshpoundWithMelee);
		}
	}

	if ( bWithKnife )
	{
		if ( bDebugStats )
			log("STEAMSTATS: KilledFleshpoundWithKnife - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_KnifeChristmasFleshpound].bCompleted == 0 )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_KnifeChristmasFleshpound);
			CheckChristmasAchievementsCompleted();
		}
	}

	if ( bWithAA12 )
	{
		SetStatInt(FleshpoundsKilledWithAA12, FleshpoundsKilledWithAA12.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Fleshpound Killed With AA12 - NewValue="$FleshpoundsKilledWithAA12.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Kill100FleshpoundsWithAA12].bCompleted == 0 && FleshpoundsKilledWithAA12.Value >= Achievements[KFACHIEVEMENT_Kill100FleshpoundsWithAA12].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Kill100FleshpoundsWithAA12);
		}
	}

	bClaymoredFleshpound = bClaymoredFleshpound || bWithClaymore;
}

function AddMedicKnifeKill()
{
	SetStatInt(MedicKnifeKills, MedicKnifeKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Medic Knife Kill - NewValue="$MedicKnifeKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_MedicKillXEnemiesWithKnife].bCompleted == 0 && MedicKnifeKills.Value >= 8 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_MedicKillXEnemiesWithKnife);
	}
}

function AddGibKill(bool bWithM79)
{
	SetStatInt(GibbedEnemiesStat, GibbedEnemiesStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Gib Kill - NewValue="$GibbedEnemiesStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_TurnXEnemiesIntoGiblets].bCompleted == 0 && GibbedEnemiesStat.Value >= Achievements[KFACHIEVEMENT_TurnXEnemiesIntoGiblets].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_TurnXEnemiesIntoGiblets);
	}

	if ( bWithM79 )
	{
		SetStatInt(EnemiesGibbedWithM79, EnemiesGibbedWithM79.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Gibbed with M79 Kill - NewValue="$EnemiesGibbedWithM79.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Gib500ZedsWithM79].bCompleted == 0 && EnemiesGibbedWithM79.Value >= Achievements[KFACHIEVEMENT_Gib500ZedsWithM79].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Gib500ZedsWithM79);
		}
	}
}

function AddFleshpoundGibKill()
{
	SetStatInt(GibbedFleshpoundsStat, GibbedFleshpoundsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Gibbed Fleshpound - NewValue="$GibbedFleshpoundsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets].bCompleted == 0 && GibbedFleshpoundsStat.Value >= Achievements[KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_TurnXFleshpoundsIntoGiblets);
	}
}

function AddSelfHeal()
{
	SetStatInt(SelfHealsStat, SelfHealsStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Self Heal - NewValue="$SelfHealsStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_HealSelfXTimes].bCompleted == 0 && SelfHealsStat.Value >= Achievements[KFACHIEVEMENT_HealSelfXTimes].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_HealSelfXTimes);
	}
}

function AddOnlySurvivorOfWave()
{
	SetStatInt(SoleSurvivorWavesStat, SoleSurvivorWavesStat.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Only Survivor - NewValue="$SoleSurvivorWavesStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_OnlySurvivorXWaves].bCompleted == 0 && SoleSurvivorWavesStat.Value >= Achievements[KFACHIEVEMENT_OnlySurvivorXWaves].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_OnlySurvivorXWaves);
	}
}

function AddDonatedCash(int Amount)
{
	SetStatInt(CashDonatedStat, CashDonatedStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Donated Cash - NewValue="$CashDonatedStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_DonateXCashToTeammates].bCompleted == 0 && CashDonatedStat.Value >= Achievements[KFACHIEVEMENT_DonateXCashToTeammates].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_DonateXCashToTeammates);
	}
}

function AddZedTime(float Amount)
{
	SetStatFloat(TotalZedTimeStat, TotalZedTimeStat.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Zed Time - NewValue="$TotalZedTimeStat.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_AcquireXMinutesOfZedTime].bCompleted == 0 && TotalZedTimeStat.Value >= 60.0 * Achievements[KFACHIEVEMENT_AcquireXMinutesOfZedTime].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_AcquireXMinutesOfZedTime);
	}
}

function KilledPatriarch(bool bPatriarchHealed, bool bKilledWithLAW, bool bSuicidalDifficulty, bool bOnlyUsedCrossbows, bool bClaymore, string MapName)
{
	if ( bDebugStats )
		log("STEAMSTATS: KilledPatriarch - bPatriarchHealed="$bPatriarchHealed @ "bKilledWithLAW="$bKilledWithLAW @ "bSuicidalDifficulty="$bSuicidalDifficulty @ "bOnlyUsedCrossbows="$bOnlyUsedCrossbows @ "bClaymore="$bClaymore @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( !bPatriarchHealed && Achievements[KFACHIEVEMENT_KillPatriarchBeforeHeHeals].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillPatriarchBeforeHeHeals);
	}

	if ( bKilledWithLAW && Achievements[KFACHIEVEMENT_KillPatriarchWithLAW].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillPatriarchWithLAW);
	}

	if ( bSuicidalDifficulty && Achievements[KFACHIEVEMENT_DefeatPatriarchOnSuicidal].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_DefeatPatriarchOnSuicidal);
	}

	if ( bOnlyUsedCrossbows && Achievements[KFACHIEVEMENT_KillPatriarchOnlyCrossbows].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillPatriarchOnlyCrossbows);
	}

	if ( bClaymore && bClaymoredScrake && bClaymoredFleshpound && Achievements[KFACHIEVEMENT_KillXMasPatriarchWithClaymoreDecap].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXMasPatriarchWithClaymoreDecap);
	}

	if ( Achievements[KFACHIEVEMENT_KillChristmasPatriarch].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillChristmasPatriarch);
		CheckChristmasAchievementsCompleted();
	}

	if ( Achievements[KFACHIEVEMENT_KillSideshowPatriarch].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSideshowPatriarch);
		CheckSideshowAchievementsCompleted();
	}

	if ( Achievements[KFACHIEVEMENT_KillHalloweenPatriarchInBedlam].bCompleted == 0 && MapName ~= "KF-Bedlam" )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillHalloweenPatriarchInBedlam);
		CheckHalloweenAchievementsCompleted();
	}
}

function KilledHusk(bool bDamagedFriendly)
{
	if ( bDebugStats )
		log("STEAMSTATS: Killed Husk - bDamagedFriendly="$bDamagedFriendly @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( !bDamagedFriendly && Achievements[KFACHIEVEMENT_KillHuskWithFlamethrower].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillHuskWithFlamethrower);
	}
}

function AddSCARKill()
{
	SetStatInt(EnemiesKilledWithSCAR, EnemiesKilledWithSCAR.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding SCAR Kill - NewValue="$EnemiesKilledWithSCAR.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill1000ZedsWithSCAR].bCompleted == 0 && EnemiesKilledWithSCAR.Value >= Achievements[KFACHIEVEMENT_Kill1000ZedsWithSCAR].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill1000ZedsWithSCAR);
	}
}

function AddCrawlerKilledInMidair()
{
	SetStatInt(CrawlersKilledInMidair, CrawlersKilledInMidair.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Crawler Killed in Midair - NewValue="$CrawlersKilledInMidair.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill20CrawlersKilledInAir].bCompleted == 0 && CrawlersKilledInMidair.Value >= Achievements[KFACHIEVEMENT_Kill20CrawlersKilledInAir].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill20CrawlersKilledInAir);
	}
}

function Killed8ZedsWithGrenade()
{
	if ( Achievements[KFACHIEVEMENT_KillXEnemiesWithGrenade].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXEnemiesWithGrenade);
	}
}

function Killed10ZedsWithPipebomb()
{
	if ( Achievements[KFACHIEVEMENT_Obliterate10ZedsWithPipebomb].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Obliterate10ZedsWithPipebomb);
	}
}

function AddMac10BurnDamage(int Amount)
{
	SetStatInt(Mac10BurnDamage, Mac10BurnDamage.Value + Amount);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Mac10 Burn Damage - NewValue="$Mac10BurnDamage.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Get1000BurnDamageWithMac10].bCompleted == 0 && Mac10BurnDamage.Value >= Achievements[KFACHIEVEMENT_Get1000BurnDamageWithMac10].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Get1000BurnDamageWithMac10);
	}
}

function AddGorefastBackstab()
{
	SetStatInt(GorefastBackstabKills, GorefastBackstabKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Gorefast Backstab Kill - NewValue="$GorefastBackstabKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_MeleeKill2ChristmasGorefastFromBack].bCompleted == 0 && GorefastBackstabKills.Value >= 2 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_MeleeKill2ChristmasGorefastFromBack);
		CheckChristmasAchievementsCompleted();
	}
}

function ScrakeKilledByFire()
{
	if ( bDebugStats )
		log("STEAMSTATS: Killed Scrake with Fire - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillChristmasScrakeWithFire].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillChristmasScrakeWithFire);
		CheckChristmasAchievementsCompleted();
	}
}

function KilledCrawlerWithCrossbow()
{
	if ( bDebugStats )
		log("STEAMSTATS: Killed Crawler with Crossbow - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillChristmasCrawlerWithXBow].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillChristmasCrawlerWithXBow);
		CheckChristmasAchievementsCompleted();
	}
}

function OnLARReloaded()
{
	InitStatInt(LARStalkerKills, 0);
}

function AddStalkerKillWithLAR()
{
	SetStatInt(LARStalkerKills, LARStalkerKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Stalker LAR Kill - NewValue="$LARStalkerKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill3ChristmasStalkersWithLAR].bCompleted == 0 && LARStalkerKills.Value >= 3 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill3ChristmasStalkersWithLAR);
		CheckChristmasAchievementsCompleted();
	}
}

function KilledHuskWithPistol()
{
	if ( Achievements[KFACHIEVEMENT_KillChristmasHuskWithPistol].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillChristmasHuskWithPistol);
		CheckChristmasAchievementsCompleted();
	}
}

function AddDroppedTier3Weapon()
{
	SetStatInt(DroppedTier3Weapons, DroppedTier3Weapons.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Dropped Tier3 Weapon - NewValue="$DroppedTier3Weapons.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].bCompleted == 0 && DroppedTier3Weapons.Value >= Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas);
		CheckChristmasAchievementsCompleted();
	}
}

function Survived10SecondsAfterVomit()
{
	if ( Achievements[KFACHIEVEMENT_ChristmasVomitLive10Seconds].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_ChristmasVomitLive10Seconds);
		CheckChristmasAchievementsCompleted();
	}
}

function CheckChristmasAchievementsCompleted()
{
	local int ChristmasAchievementsCompleted;
	local bool bBeatChristmasMap;

	if ( Achievements[KFACHIEVEMENT_KillChristmasPatriarch].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KnifeChristmasFleshpound].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill2ChristmasGorefastFromBack].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasScrakeWithFire].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3ChristmasBloatsWithBullpup].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill20ChristmasClots].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasCrawlerWithXBow].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasSirenWithLawImpact].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3ChristmasStalkersWithLAR].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillChristmasHuskWithPistol].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill3ChristmasZedsInOneSlomo].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Drop3Tier3WeaponsForOthersChristmas].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_ChristmasVomitLive10Seconds].bCompleted == 1 )
		ChristmasAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinSantasEvilLairNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSantasEvilLairHell].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinIceCaveHell].bCompleted == 1 ||
         Achievements[KFACHIEVEMENT_WinMoonbaseNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinMoonbaseHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinMoonbaseSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinMoonbaseHell].bCompleted == 1)
	{
		bBeatChristmasMap = true;
	}

	if ( ChristmasAchievementsCompleted >= 10 && bBeatChristmasMap && Achievements[KFACHIEVEMENT_Unlock10ofChristmasAchievements].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Unlock10ofChristmasAchievements);
	}
}

function KilledXMasHuskWithHuskCannon()
{
	SetStatInt(XMasHusksKilledWithHuskCannon, XMasHusksKilledWithHuskCannon.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding XMas Husk Killed w/Husk Cannon - NewValue="$XMasHusksKilledWithHuskCannon.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon].bCompleted == 0 && XMasHusksKilledWithHuskCannon.Value >= Achievements[KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill15XMasHusksWithHuskCannon);
	}
}

function OnM4Reloaded(bool bClipEmptied)
{
	if ( bDebugStats )
		log("STEAMSTATS: M4 Reloaded - Kills="$M4SingleClipXMasKills.Value @ "bClipEmptied="$bClipEmptied @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( bClipEmptied && Achievements[KFACHIEVEMENT_Kill1XMasZedWithFullM4Clip].bCompleted == 0 && M4SingleClipXMasKills.Value == 1 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill1XMasZedWithFullM4Clip);
	}

	SetStatInt(M4SingleClipXMasKills, 0);
}

function AddM203NadeScrakeKill()
{
	if ( bDebugStats )
		log("STEAMSTATS: AddM203NadeScrakeKill");

	if ( Achievements[KFACHIEVEMENT_KillXMasScrakeWithDirectM203Nade].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXMasScrakeWithDirectM203Nade);
	}
}

function OnBenelliReloaded()
{
	if ( bDebugStats )
		log("STEAMSTATS: Benelli Reloaded - Kills="$BenelliSingleClipXMasKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill12XMasZedsWith1BenelliClip].bCompleted == 0 && BenelliSingleClipXMasKills.Value >= 12 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill12XMasZedsWith1BenelliClip);
	}

	SetStatInt(BenelliSingleClipXMasKills, 0);
}

function OnRevolverReloaded()
{
	if ( bDebugStats )
		log("STEAMSTATS: Revolver Reloaded - Kills="$RevolverSingleClipXMasKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillXMasZedWithEveryRevolverShot].bCompleted == 0 && RevolverSingleClipXMasKills.Value >= 6 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillXMasZedWithEveryRevolverShot);
	}

	SetStatInt(RevolverSingleClipXMasKills, 0);
}

function OnDualsAddedToInventory(bool bHasDual9mms, bool bHasDualHCs, bool bHasDualRevolvers)
{
	if ( bDebugStats )
		log("STEAMSTATS: OnDualsAddedToInventory - bHasDual9mms="$bHasDual9mms @ "bHasDualHCs="$bHasDual9mms @ "bHasDualRevolvers="$bHasDualRevolvers @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_HoldAll3DualiesDuringXMas].bCompleted == 0 && bHasDual9mms && bHasDualHCs && bHasDualRevolvers )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_HoldAll3DualiesDuringXMas);
	}
}

function AddXMasStalkerKill()
{
	SetStatInt(XMas20MinuteStalkerKills, XMas20MinuteStalkerKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: AddXMasStalkerKill - Kills="$XMas20MinuteStalkerKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	Check20MinuteAchievement();
}

function AddXMasCrawlerKill()
{
	SetStatInt(XMas20MinuteCrawlerKills, XMas20MinuteCrawlerKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: AddXMasCrawlerKill - Kills="$XMas20MinuteCrawlerKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	Check20MinuteAchievement();
}

function Check20MinuteAchievement()
{
	if ( bDebugStats )
		log("STEAMSTATS: Check20MinuteAchievement");

	if ( Achievements[KFACHIEVEMENT_KillSelectXMasZedsOnSingleMap].bCompleted == 0 && XMas20MinuteClotKills.Value >= 15 && XMas20MinuteStalkerKills.Value >= 5 &&
		 XMas20MinuteCrawlerKills.Value >= 5 && XMas20MinuteSirenKills.Value >= 1 && XMas20MinuteBloatKills.Value >= 1 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSelectXMasZedsOnSingleMap);
	}
}

function AddXMasClaymoreScrakeKill()
{
	bClaymoredScrake = true;
}

function OnMK23Reloaded()
{
	if ( bDebugStats )
		log("STEAMSTATS: MK23 Reloaded - Kills="$MK23SingleClipKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill12ClotsWithOneMagWithMK23].bCompleted == 0 && MK23SingleClipKills.Value >= 12 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill12ClotsWithOneMagWithMK23);
	}

	SetStatInt(MK23SingleClipKills, 0);
}

function OnKilledZedInjuredPlayerWithM7A3()
{
	if ( Achievements[KFACHIEVEMENT_KillZedThatHurtPlayerWithM7A3].bCompleted == 0  )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillZedThatHurtPlayerWithM7A3);
	}
}

function AddM99Kill()
{
	SetStatInt(M99Kills, M99Kills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding M99 Scrake Kill - NewValue="$M99Kills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill2ScrakesOneBulletWithBarret].bCompleted == 0 && M99Kills.Value >= 2 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill2ScrakesOneBulletWithBarret);
	}
}

function CheckBritishSuperiority()
{
	if ( bDebugStats )
		log("STEAMSTATS: CheckBritishSuperiority");

	if ( Achievements[KFACHIEVEMENT_KillZedWithSA80AndFNFal].bCompleted == 0 && EnemiesKilledWithFNFal.Value >= 1 && EnemiesKilledWithBullpup.Value >= 1 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillZedWithSA80AndFNFal);
	}
}

function AddCrawlerKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed crawler with KSG");

	bCrawlerKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddBloatKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed bloat with KSG");

	bBloatKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddSirenKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed siren with KSG");

	bSirenKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddStalkerKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed stalker with KSG");

	bStalkerKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddHuskKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed husk with KSG");

	bHuskKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddScrakeKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed scrake with KSG");

	bScrakeKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddFleshPoundKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed fleshpound with KSG");

	bFleshPoundKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddBossKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed patriarch with KSG");

	bBossKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddClotKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed clot with KSG");

	bClotKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function AddGoreFastKillWithKSG()
{
	if ( bDebugStats )
		log("STEAMSTATS:" @ "Player =" @ PCOwner.PlayerReplicationInfo.PlayerName @ "killed gorefast with KSG");

	bGoreFastKilledWithKSG = true;
	CheckForFuglyAchievement();
}

function CheckForFuglyAchievement()
{
	if ( bCrawlerKilledWithKSG && bBloatKilledWithKSG && bSirenKilledWithKSG &&
		 bStalkerKilledWithKSG && bHuskKilledWithKSG && bScrakeKilledWithKSG &&
		 bFleshPoundKilledWithKSG && bBossKilledWithKSG && bClotKilledWithKSG &&
		 bGoreFastKilledWithKSG )
	{
		if ( Achievements[KFACHIEVEMENT_KillOneOfEachZedsWithKSG].bCompleted == 0  )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_KillOneOfEachZedsWithKSG);
		}
	}
}

function KilledCrawlerWithBullpup()
{
	SetStatInt(CrawlerBullpupKills, CrawlerBullpupKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Crawler Bullpup Kill - NewValue="$CrawlerBullpupKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowCrawlersWithBullpup].bCompleted == 0 && CrawlerBullpupKills.Value >= 5 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill5SideshowCrawlersWithBullpup);
		CheckSideshowAchievementsCompleted();
	}
}

function KilledScrakeWithCrossbow()
{
	if ( bDebugStats )
		log("STEAMSTATS: Killed Scrake with Crossbow - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillSideshowScrakeWithCrossbow].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSideshowScrakeWithCrossbow);
		CheckSideshowAchievementsCompleted();
	}
}

function AddDroppedTier2Weapon()
{
	SetStatInt(DroppedTier2Weapons, DroppedTier2Weapons.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Dropped Tier2 Weapon - NewValue="$DroppedTier2Weapons.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Drop5Tier2WeaponsOneWaveSideshow].bCompleted == 0 && DroppedTier2Weapons.Value >= 5 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Drop5Tier2WeaponsOneWaveSideshow);
		CheckSideshowAchievementsCompleted();
	}
}

function CheckSideshowAchievementsCompleted()
{
	local int SideshowAchievementsCompleted;
	local bool bBeatSideshowMap;

	if ( Achievements[KFACHIEVEMENT_KillSideshowPatriarch].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowGorefastWithMelee].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill2SideshowStalkerWithBackstab].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowCrawlersWithBullpup].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5SideshowBloats].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowScrakeWithCrossbow].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowHuskWithLAW].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill3SideshowClotsWithLAR].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_KillSideshowFleshpoundWithPistol].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Drop5Tier2WeaponsOneWaveSideshow].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_SurviveSideshowSirenScreamPlus10Sec].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_MeleeKill4SideshowZedsInOneSlomo].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill10SideshowClotsWithFireWeapon].bCompleted == 1 )
		SideshowAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinSideshowNormal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowHard].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowSuicidal].bCompleted == 1 ||
		 Achievements[KFACHIEVEMENT_WinSideshowHell].bCompleted == 1 )
	{
		bBeatSideshowMap = true;
	}

	if ( bDebugStats )
		log("STEAMSTATS: CheckSideshowAchievementsCompleted" @ SideshowAchievementsCompleted @ bBeatSideshowMap @ Achievements[KFACHIEVEMENT_Unlock10ofSideshowAchievements].bCompleted);

	if ( SideshowAchievementsCompleted >= 10 && bBeatSideshowMap && Achievements[KFACHIEVEMENT_Unlock10ofSideshowAchievements].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Unlock10ofSideshowAchievements);
	}
}

function MeleedGorefast()
{
	if ( bDebugStats )
		log("STEAMSTATS: KilledGorefastWithMelee - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillSideshowGorefastWithMelee].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSideshowGorefastWithMelee);
		CheckSideshowAchievementsCompleted();
	}
}

function AddStalkerBackstab()
{
	SetStatInt(StalkerBackstabKills, StalkerBackstabKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Stalker Backstab Kill - NewValue="$StalkerBackstabKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill2SideshowStalkerWithBackstab].bCompleted == 0 && StalkerBackstabKills.Value >= 2 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill2SideshowStalkerWithBackstab);
		CheckSideshowAchievementsCompleted();
	}
}

function KilledHuskWithLAW()
{
	if ( bDebugStats )
		log("STEAMSTATS: KilledHuskWithLAW - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillSideshowHuskWithLAW].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSideshowHuskWithLAW);
		CheckSideshowAchievementsCompleted();
	}
}

function AddClotKillWithLAR()
{
	SetStatInt(LARClotKills, LARClotKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Adding Clot LAR Kill - NewValue="$LARClotKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_Kill3SideshowClotsWithLAR].bCompleted == 0 && LARClotKills.Value >= 3 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill3SideshowClotsWithLAR);
		CheckSideshowAchievementsCompleted();
	}
}

function KilledFleshpoundWithPistol()
{
	if ( bDebugStats )
		log("STEAMSTATS: KilledFleshpoundWithPistol - Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( Achievements[KFACHIEVEMENT_KillSideshowFleshpoundWithPistol].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_KillSideshowFleshpoundWithPistol);
		CheckSideshowAchievementsCompleted();
	}
}

function Survived10SecondsAfterScream()
{
	if ( Achievements[KFACHIEVEMENT_SurviveSideshowSirenScreamPlus10Sec].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_SurviveSideshowSirenScreamPlus10Sec);
		CheckSideshowAchievementsCompleted();
	}
}

function ClotKilledByFire()
{
	SetStatInt(ClotFireKills, ClotFireKills.Value + 1);

	if ( bDebugStats )
		log("STEAMSTATS: Killed Clot with Fire - Player="$PCOwner.PlayerReplicationInfo.PlayerName @ "Value="$ClotFireKills.Value);

	if ( Achievements[KFACHIEVEMENT_Kill10SideshowClotsWithFireWeapon].bCompleted == 0 && ClotFireKills.Value >= 10 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Kill10SideshowClotsWithFireWeapon);
		CheckSideshowAchievementsCompleted();
	}
}

// Hillbilly Achievements
function CheckHillbillyAchievementsCompleted()
{
	local int FirstHillbillyAchievement, LastHillbillyAchievement;
	local int FirstHillbillyMapAchievement, LastHillbillyMapAchievement;
	local int TotalHillbillyAchievementsCompleted;
	local int ProgressDenominator, i;

	FirstHillbillyMapAchievement = KFACHIEVEMENT_WinHillbillyNormal;
	LastHillbillyMapAchievement = KFACHIEVEMENT_WinHillbillyHell;

	// Completed at least one hillbilly horror map
	for (i = FirstHillbillyMapAchievement; i <= LastHillbillyMapAchievement; i++)
	{
    	if ( Achievements[i].bCompleted == 1 )
		{
			TotalHillbillyAchievementsCompleted++;
			break;
		}
	}

	FirstHillbillyAchievement = KFACHIEVEMENT_Destroy25GnomesInHillbilly;
	LastHillbillyAchievement = KFACHIEVEMENT_Set3HillbillyGorefastsOnFire;

	// Completed the 6 character unlock achievements
	for (i = FirstHillbillyAchievement; i <= LastHillbillyAchievement; i++)
	{
    	if ( Achievements[i].bCompleted == 1 )
			TotalHillbillyAchievementsCompleted++;
	}

	SetStatInt(HillbillyAchievementsCompleted, TotalHillbillyAchievementsCompleted);

	ProgressDenominator = Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].ProgressDenominator;

	if ( TotalHillbillyAchievementsCompleted >= ProgressDenominator && Achievements[KFACHIEVEMENT_Complete7ReaperAchievements].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Complete7ReaperAchievements);
	}
}

/** Pass in the achievement ID and add a case for it to increment the score and check if it's complete */
function AddKillPoints(int AchievementID)
{
	switch(AchievementID)
	{
    	case KFACHIEVEMENT_Kill6ZedWithoutReloadingMKB42:
			CheckAchievementPoints(AchievementID, "Adding MKB42 Kill", EnemiesKilledWithMKB42NoReload);
			break;
		case KFACHIEVEMENT_Kill4StalkersNailgun:
			CheckAchievementPoints(AchievementID, "Adding Stalker kill with nail", StalkersKilledWithNail);
			break;
		case KFACHIEVEMENT_Set200ZedOnFireOnHillbilly:
			SetStatInt(ZedSetFireWithTrenchOnHillbilly, ZedSetFireWithTrenchOnHillbilly.Value + 1);
			CheckAchievementPoints(AchievementID, "Adding hillbilly on fire", NullValue, ZedSetFireWithTrenchOnHillbilly);
			break;
		case KFACHIEVEMENT_Kill1000HillbillyZeds:
			SetStatInt(ZedKilledDuringHillbilly, ZedKilledDuringHillbilly.Value + 1);
			CheckAchievementPoints(AchievementID, "Adding hillbilly zeds", NullValue, ZedKilledDuringHillbilly);
			break;
		case KFACHIEVEMENT_Kill15HillbillyCrawlersThomOrMKB:
			CheckAchievementPoints(AchievementID, "Adding killbilly crawler with Thom or MKB", HillbillyCrawlerKills);
			break;
		case KFACHIEVEMENT_Kill1Hillbilly1HuskAndZedIn1Shot:
			CheckAchievementPoints(AchievementID, "Adding M99 or Saw Husk and Other zed Kill", HuskAndZedOneShotTotalKills);
			break;
		case KFACHIEVEMENT_Kill5HillbillyZedsIn10SecsSythOrAxe:
			KillHillbillyZedsIn10Seconds();
			CheckAchievementPoints(AchievementID, "Adding Hillbilly scythe/axe kill", HillbillysKilledIn10Secs);
			break;
		case KFACHIEVEMENT_Set3HillbillyGorefastsOnFire:
			CheckAchievementPoints(AchievementID, "Adding Hillbilly Gorefast on Fire", HillbillyGorefastsOnFire);
			break;

		case KFACHIEVEMENT_HaveMyAxe:
			CheckAchievementPoints(AchievementID, "Adding Fleshpound killed in back by Axe", HuskAndZedOneShotTotalKills);
			break;
		case KFACHIEVEMENT_OneSmallStepForMan:
			KillHillbillyZedsIn10Seconds();
			CheckAchievementPoints(AchievementID, "Adding Hillbilly scythe/axe kill", HillbillysKilledIn10Secs);
			break;
		case KFACHIEVEMENT_GameOverMan:
			CheckAchievementPoints(AchievementID, "Adding Hillbilly Gorefast on Fire", HillbillyGorefastsOnFire);
			break;

	}
}

/** Increment and the achievements counter and check if it's complete, pass in the "Null Value" for counter if you are using a steam stat int */
function CheckAchievementPoints(int AchievementID, string DebugMessage, out int Counter, optional SteamStatInt Stat)
{
	local int ProgressDenominator;
	local int LocalCounter;

	if (!bUsedCheats)
	{
		if (Counter != -1)
		{
			Counter += 1;
			LocalCounter = Counter;
		}
		else
		{
			LocalCounter = Stat.Value;
		}
	}

	if ( bDebugStats )
		log("STEAMSTATS: "@ DebugMessage @"- NewValue="$LocalCounter @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	ProgressDenominator = Achievements[AchievementID].ProgressDenominator;
	if ( Achievements[AchievementID].bCompleted == 0 && LocalCounter >= ProgressDenominator)
	{
     	SetSteamAchievementCompleted(AchievementID);
		CheckHillbillyAchievementsCompleted();
	}
}

function ResetMKB42Kill()
{
	if ( bDebugStats )
		log("STEAMSTATS: Resetting MKB without reloading Kills");

	EnemiesKilledWithMKB42NoReload = 0;
}

function OneShotBuzzOrM99()
{
	if ( bDebugStats )
		log("STEAMSTATS: Resetting one shot M99 and buzz kills");
	HuskAndZedOneShotZedKills = 0;
	HuskAndZedOneShotTotalKills = 0;
}

function HealedTeamWithMedicGrenade()
{
	if ( Achievements[KFACHIEVEMENT_HealAllPlayersWith1MedicNade].bCompleted == 0 && !bUsedCheats)
	{
     	SetSteamAchievementCompleted(KFACHIEVEMENT_HealAllPlayersWith1MedicNade);
		CheckHillbillyAchievementsCompleted();
	}
}

function KillHillbillyZedsIn10Seconds()
{
	if (HillbillySKilledIn10SecsTime <= 0.0 || Level.TimeSeconds - HillbillySKilledIn10SecsTime > 10)
	{

		HillbillysKilledIn10Secs = 0;
		HillbillySKilledIn10SecsTime = Level.TimeSeconds;
		if ( bDebugStats )
			log("STEAMSTATS: RESETTING scythe / axe zed kills - NewValue="$HillbillysKilledIn10Secs @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
	}
}


function AddHuskAndZedOneShotKill(bool HuskKill, bool ZedKill)
{
	local int ProgressDenominator;

	if (!bUsedCheats)
	{
		if (ZedKill)
		{
			if (HuskAndZedOneShotZedKills == 0)
			{
		   		HuskAndZedOneShotZedKills = 1;
				HuskAndZedOneShotTotalKills += 1;
			}
		}
		else if (HuskKill)
		{
			HuskAndZedOneShotTotalKills += 1;
		}
	}

	ProgressDenominator = Achievements[KFACHIEVEMENT_Kill1Hillbilly1HuskAndZedIn1Shot].ProgressDenominator;
	if ( Achievements[KFACHIEVEMENT_Kill1Hillbilly1HuskAndZedIn1Shot].bCompleted == 0 && HuskAndZedOneShotTotalKills >= ProgressDenominator)
	{
     	SetSteamAchievementCompleted(KFACHIEVEMENT_Kill1Hillbilly1HuskAndZedIn1Shot);
		CheckHillbillyAchievementsCompleted();
	}
}

// Activated when all 25 gnomes have been killed, event is interpreted through "Tag"
function Trigger(actor Other, pawn EventInstigator )
{
    log("----------");
    log(Other);
    log("trigger");
    if( Other.IsA( 'KF_GnomeSmashable' ) )
    {
	    if ( Achievements[KFACHIEVEMENT_Destroy25GnomesInHillbilly].bCompleted == 0 && !bUsedCheats)
	    {
		    SetSteamAchievementCompleted(KFACHIEVEMENT_Destroy25GnomesInHillbilly);
		    CheckHillbillyAchievementsCompleted();
	    }
    }

}

function OnWeaponReloaded()
{
	SetStatInt(HalloweenSpecimensKilledWithoutReloading, 0);

	if ( bDebugStats )
		log("STEAMSTATS: Weapon Reloaded - NewValue="$HalloweenSpecimensKilledWithoutReloading.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);
}

function AddBurningDecapKill(string MapName)
{
	if ( bDebugStats )
		log("STEAMSTATS: Burning Decap - MapName="$MapName @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

	if ( MapName ~= "KF-Bedlam" )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_DecapBurningHalloweenZedInBedlam);
		CheckHalloweenAchievementsCompleted();
	}
}

function AddScrakeKill(string MapName)
{
	if ( MapName ~= "KF-Bedlam" )
	{
		SetStatInt(HalloweenScrakeKills, HalloweenScrakeKills.Value + 1);

		if ( bDebugStats )
			log("STEAMSTATS: Adding Halloween ScrakeKill - NewKills="$HalloweenScrakeKills.Value @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

		if ( Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].bCompleted == 0 && HalloweenScrakeKills.Value >= Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].ProgressDenominator )
		{
			SetSteamAchievementCompleted(KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam);
			CheckHalloweenAchievementsCompleted();
		}
	}
}

//this is for the dwarf axe
function AddFleshpoundAxeKill()
{
    SetStatInt(FleshPoundsKilledWithAxe, FleshPoundsKilledWithAxe.Value + 1);
	if ( Achievements[KFACHIEVEMENT_HaveMyAxe].bCompleted == 0 && FleshPoundsKilledWithAxe.Value >= Achievements[KFACHIEVEMENT_HaveMyAxe].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_HaveMyAxe);
    }
}

function AddAirborneZedKill()
{
    SetStatInt(ZedsKilledWhileAirborne, ZedsKilledWhileAirborne.Value + 1);
	if ( Achievements[KFACHIEVEMENT_OneSmallStepForMan].bCompleted == 0 && ZedsKilledWhileAirborne.Value >= Achievements[KFACHIEVEMENT_OneSmallStepForMan].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_OneSmallStepForMan);
    }
}

function AddZedKilledWhileZapped()
{
    SetStatInt(ZEDSKilledWhileZapped, ZEDSKilledWhileZapped.Value + 1);
	if ( Achievements[KFACHIEVEMENT_GameOverMan].bCompleted == 0 && ZEDSKilledWhileZapped.Value >= Achievements[KFACHIEVEMENT_GameOverMan].ProgressDenominator )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_GameOverMan);
    }
}

function CheckHalloweenAchievementsCompleted()
{
	local int HalloweenAchievementsCompleted;

	if ( Achievements[KFACHIEVEMENT_KillHalloweenPatriarchInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_DecapBurningHalloweenZedInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill250HalloweenZedsInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_WinBedlamHardHalloween].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill25HalloweenScrakesInBedlam].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( Achievements[KFACHIEVEMENT_Kill5HalloweenZedsWithoutReload].bCompleted == 1 )
		HalloweenAchievementsCompleted++;

	if ( bDebugStats )
		log("STEAMSTATS: CheckHalloweenAchievementsCompleted" @ HalloweenAchievementsCompleted @ Achievements[KFACHIEVEMENT_Unlock6ofHalloweenAchievements].bCompleted);

	if ( HalloweenAchievementsCompleted >= 6 && Achievements[KFACHIEVEMENT_Unlock6ofHalloweenAchievements].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_Unlock6ofHalloweenAchievements);
	}
}

simulated function OnAchievementReport( bool HasAchievement, string Achievement, int gameID, string steamIDIn)
{
    //NotAWarhammer
    log("webapi!!!!!!!!!!!!", 'DevNet');
    log(HasAchievement, 'DevNet');
    log(Achievement, 'DevNet');
    log(gameID, 'DevNet');
    log(steamIDIn, 'DevNet');
    if( HasAchievement && Achievement == "NotAWarhammer" && gameID == 213650 )
    {
        log("webapi correct achievement", 'DevNet');
        if( Achievements[KFACHIEVEMENT_CanGetAxe].bCompleted != 1 )
        {
            log("webapi unlocking achievement", 'DevNet');
            CanGetAxe = true;
            //we could set the achievement here in a normal fashion but right now it's a
            //fake achievement
            SetSteamAchievementCompleted(KFACHIEVEMENT_CanGetAxe);
            if ( PCOwner.Role < ROLE_Authority )
            {
				KFPC(PCOwner).ServerSetCanGetAxe();
            }
        }
    }
}

function SetCanGetAxe()
{
	if( Achievements[KFACHIEVEMENT_CanGetAxe].bCompleted == 0 )
	{
		SetSteamAchievementCompleted(KFACHIEVEMENT_CanGetAxe);
	}
}

function ZEDPieceGrabbed()
{
    ZEDpiecesObtained++;
    if(ZEDpiecesObtained > 15)
    {
        SetSteamAchievementCompleted(KFACHIEVEMENT_ButItsAllRed);
    }
}

defaultproperties
{
     NullValue=-1
     Achievements(0)=(SteamName="WinWestLondonNormal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_0',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(1)=(SteamName="WinManorNormal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_1',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(2)=(SteamName="WinFarmNormal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_2',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(3)=(SteamName="WinOfficesNormal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_3',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(4)=(SteamName="WinBioticsLabNormal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_4',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(5)=(SteamName="WinAllMapsNormal",bShowProgress=1,ProgressDenominator=5,Icon=Texture'KillingFloorHUD.Achievements.Achievement_5',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(6)=(SteamName="WinWestLondonHard",Icon=Texture'KillingFloorHUD.Achievements.Achievement_6',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(7)=(SteamName="WinManorHard",Icon=Texture'KillingFloorHUD.Achievements.Achievement_7',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(8)=(SteamName="WinFarmHard",Icon=Texture'KillingFloorHUD.Achievements.Achievement_8',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(9)=(SteamName="WinOfficesHard",Icon=Texture'KillingFloorHUD.Achievements.Achievement_9',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(10)=(SteamName="WinBioticsLabHard",Icon=Texture'KillingFloorHUD.Achievements.Achievement_10',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(11)=(SteamName="WinAllMapsHard",bShowProgress=1,ProgressDenominator=5,Icon=Texture'KillingFloorHUD.Achievements.Achievement_11',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(12)=(SteamName="WinWestLondonSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_12',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(13)=(SteamName="WinManorSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_13',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(14)=(SteamName="WinFarmSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_14',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(15)=(SteamName="WinOfficesSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_15',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(16)=(SteamName="WinBioticsLabSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_16',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(17)=(SteamName="WinAllMapsSuicidal",bShowProgress=1,ProgressDenominator=5,Icon=Texture'KillingFloorHUD.Achievements.Achievement_17',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(18)=(SteamName="KillXEnemies",bShowProgress=1,ProgressDenominator=100,Icon=Texture'KillingFloorHUD.Achievements.Achievement_18',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(19)=(SteamName="KillXEnemies2",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloorHUD.Achievements.Achievement_19',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(20)=(SteamName="KillXEnemies3",bShowProgress=1,ProgressDenominator=10000,Icon=Texture'KillingFloorHUD.Achievements.Achievement_20',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(21)=(SteamName="KillXBloats",bShowProgress=1,ProgressDenominator=200,Icon=Texture'KillingFloorHUD.Achievements.Achievement_21',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(22)=(SteamName="KillXSirens",bShowProgress=1,ProgressDenominator=100,Icon=Texture'KillingFloorHUD.Achievements.Achievement_22',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(23)=(SteamName="KillXStalkersWithExplosives",bShowProgress=1,ProgressDenominator=20,Icon=Texture'KillingFloorHUD.Achievements.Achievement_23',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(24)=(SteamName="KillXEnemiesWithFireAxe",Icon=Texture'KillingFloorHUD.Achievements.Achievement_24',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(25)=(SteamName="KillXScrakesWithChainsaw",Icon=Texture'KillingFloorHUD.Achievements.Achievement_25',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(26)=(SteamName="KillXBurningEnemiesWithCrossbow",bShowProgress=1,ProgressDenominator=25,Icon=Texture'KillingFloorHUD.Achievements.Achievement_26',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(27)=(SteamName="KillXEnemiesFeedingOnCorpses",bShowProgress=1,ProgressDenominator=10,Icon=Texture'KillingFloorHUD.Achievements.Achievement_27',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(28)=(SteamName="KillXEnemiesWithGrenade",Icon=Texture'KillingFloorHUD.Achievements.Achievement_28',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(29)=(SteamName="Kill4EnemiesWithHuntingShotgunShot",Icon=Texture'KillingFloorHUD.Achievements.Achievement_29',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(30)=(SteamName="KillEnemyUsingBloatAcid",Icon=Texture'KillingFloorHUD.Achievements.Achievement_30',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(31)=(SteamName="KillFleshpoundWithMelee",Icon=Texture'KillingFloorHUD.Achievements.Achievement_31',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(32)=(SteamName="MedicKillXEnemiesWithKnife",Icon=Texture'KillingFloorHUD.Achievements.Achievement_32',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(33)=(SteamName="TurnXEnemiesIntoGiblets",bShowProgress=1,ProgressDenominator=500,Icon=Texture'KillingFloorHUD.Achievements.Achievement_33',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(34)=(SteamName="TurnXFleshpoundsIntoGiblets",bShowProgress=1,ProgressDenominator=5,Icon=Texture'KillingFloorHUD.Achievements.Achievement_34',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(35)=(SteamName="HealSelfXTimes",bShowProgress=1,ProgressDenominator=100,Icon=Texture'KillingFloorHUD.Achievements.Achievement_35',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(36)=(SteamName="OnlySurvivorXWaves",bShowProgress=1,ProgressDenominator=10,Icon=Texture'KillingFloorHUD.Achievements.Achievement_36',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(37)=(SteamName="DonateXCashToTeammates",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloorHUD.Achievements.Achievement_37',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(38)=(SteamName="AcquireXMinutesOfZedTime",bShowProgress=1,ProgressDenominator=5,Icon=Texture'KillingFloorHUD.Achievements.Achievement_38',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(39)=(SteamName="MaxOutAllPerks",bShowProgress=1,ProgressDenominator=7,Icon=Texture'KillingFloorHUD.Achievements.Achievement_39',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(40)=(SteamName="KillPatriarchBeforeHeHeals",Icon=Texture'KillingFloorHUD.Achievements.Achievement_40',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(41)=(SteamName="KillPatriarchWithLAW",Icon=Texture'KillingFloorHUD.Achievements.Achievement_41',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(42)=(SteamName="DefeatPatriarchOnSuicidal",Icon=Texture'KillingFloorHUD.Achievements.Achievement_42',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(43)=(SteamName="WinFoundryNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_44',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(44)=(SteamName="WinFoundryHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_45',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(45)=(SteamName="WinFoundrySuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_46',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(46)=(SteamName="WinAsylumNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_47',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(47)=(SteamName="WinAsylumHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_48',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(48)=(SteamName="WinAsylumSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_49',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(49)=(SteamName="WinWyreNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_50',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(50)=(SteamName="WinWyreHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_51',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(51)=(SteamName="WinWyreSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_52',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(52)=(SteamName="WinAll3SummerMapsNormal",bShowProgress=1,ProgressDenominator=3,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_53',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(53)=(SteamName="WinAll3SummerMapsHard",bShowProgress=1,ProgressDenominator=3,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_54',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(54)=(SteamName="WinAll3SummerMapsSuicidal",bShowProgress=1,ProgressDenominator=3,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_55',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(55)=(SteamName="Kill1000EnemiesWithPipebomb",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_56',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(56)=(SteamName="KillHuskWithFlamethrower",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_57',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(57)=(SteamName="KillPatriarchOnlyCrossbows",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_58',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(58)=(SteamName="Gib500ZedsWithM79",bShowProgress=1,ProgressDenominator=500,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_59',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(59)=(SteamName="LaserSightedEBRHeadshots25InARow",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_60',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(60)=(SteamName="Kill1000ZedsWithSCAR",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_62',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(61)=(SteamName="Heal200TeammatesWithMP7",bShowProgress=1,ProgressDenominator=200,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_63',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(62)=(SteamName="Kill100FleshpoundsWithAA12",bShowProgress=1,ProgressDenominator=100,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_64',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(63)=(SteamName="Kill20CrawlersKilledInAir",bShowProgress=1,ProgressDenominator=20,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_65',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(64)=(SteamName="Obliterate10ZedsWithPipebomb",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_61',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(65)=(SteamName="WinWestLondonHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_65',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(66)=(SteamName="WinManorHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_66',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(67)=(SteamName="WinFarmHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_67',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(68)=(SteamName="WinOfficesHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_68',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(69)=(SteamName="WinBioticsLabHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_69',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(70)=(SteamName="WinFoundryHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_70',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(71)=(SteamName="WinAsylumHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_71',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(72)=(SteamName="WinWyreHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_72',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(73)=(SteamName="WinBiohazardNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_73',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(74)=(SteamName="WinBiohazardHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_74',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(75)=(SteamName="WinBiohazardSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_75',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(76)=(SteamName="WinBiohazardHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_76',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(77)=(SteamName="WinCrashNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_77',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(78)=(SteamName="WinCrashHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_78',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(79)=(SteamName="WinCrashSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_79',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(80)=(SteamName="WinCrashHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_80',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(81)=(SteamName="WinDepartedNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_81',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(82)=(SteamName="WinDepartedHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_82',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(83)=(SteamName="WinDepartedSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_83',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(84)=(SteamName="WinDepartedHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_84',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(85)=(SteamName="WinFilthsCrossNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_85',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(86)=(SteamName="WinFilthsCrossHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_86',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(87)=(SteamName="WinFilthsCrossSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_87',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(88)=(SteamName="WinFilthsCrossHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_88',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(89)=(SteamName="WinHospitalHorrorsNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_89',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(90)=(SteamName="WinHospitalHorrorsHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_90',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(91)=(SteamName="WinHospitalHorrorsSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_91',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(92)=(SteamName="WinHospitalHorrorsHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_92',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(93)=(SteamName="WinIcebreakerNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_93',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(94)=(SteamName="WinIcebreakerHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_94',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(95)=(SteamName="WinIcebreakerSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_95',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(96)=(SteamName="WinIcebreakerHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_96',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(97)=(SteamName="WinMountainPassNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_97',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(98)=(SteamName="WinMountainPassHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_98',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(99)=(SteamName="WinMountainPassSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_99',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(100)=(SteamName="WinMountainPassHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_100',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(101)=(SteamName="WinSuburbiaNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_101',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(102)=(SteamName="WinSuburbiaHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_102',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(103)=(SteamName="WinSuburbiaSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_103',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(104)=(SteamName="WinSuburbiaHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_104',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(105)=(SteamName="WinWaterworksNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_105',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(106)=(SteamName="WinWaterworksHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_106',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(107)=(SteamName="WinWaterworksSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_107',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(108)=(SteamName="WinWaterworksHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_108',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(109)=(SteamName="CompleteNewAchievementsNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_109',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(110)=(SteamName="CompleteNewAchievementsHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_110',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(111)=(SteamName="CompleteNewAchievementsSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_111',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(112)=(SteamName="CompleteNewAchievementsHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_112',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(113)=(SteamName="Get1000BurnDamageWithMac10",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_113',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(114)=(SteamName="WinSantasEvilLairNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_114',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(115)=(SteamName="WinSantasEvilLairHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_115',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(116)=(SteamName="WinSantasEvilLairSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_116',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(117)=(SteamName="WinSantasEvilLairHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_117',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(118)=(SteamName="KillChristmasPatriarch",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_118',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(119)=(SteamName="KnifeChristmasFleshpound",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_119',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(120)=(SteamName="MeleeKill2ChristmasGorefastFromBack",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_120',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(121)=(SteamName="KillChristmasScrakeWithFire",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_121',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(122)=(SteamName="Kill3ChristmasBloatsWithBullpup",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_122',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(123)=(SteamName="Kill20ChristmasClots",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_123',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(124)=(SteamName="KillChristmasCrawlerWithXBow",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_124',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(125)=(SteamName="KillChristmasSirenWithLawImpact",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_125',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(126)=(SteamName="Kill3ChristmasStalkersWithLAR",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_126',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(127)=(SteamName="KillChristmasHuskWithPistol",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_127',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(128)=(SteamName="MeleeKill3ChristmasZedsInOneSlomo",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_128',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(129)=(SteamName="Drop3Tier3WeaponsForOthersChristmas",bShowProgress=1,ProgressDenominator=3,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_129',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(130)=(SteamName="ChristmasVomitLive10Seconds",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_130',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(131)=(SteamName="Unlock10ofChristmasAchievements",bShowProgress=1,ProgressDenominator=11,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_131',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(132)=(SteamName="Achievement132",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_132',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(133)=(SteamName="Achievement133",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_133',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(134)=(SteamName="Achievement134",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_134',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(135)=(SteamName="Achievement135",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_135',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(136)=(SteamName="Achievement136",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_136',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(137)=(SteamName="Achievement137",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_137',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(138)=(SteamName="WinSideshowNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_138',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(139)=(SteamName="WinSideshowHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_139',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(140)=(SteamName="WinSideshowSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_140',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(141)=(SteamName="WinSideshowHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_141',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(142)=(SteamName="KillSideshowPatriarch",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_142',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(143)=(SteamName="KillSideshowGorefastWithMelee",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_143',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(144)=(SteamName="Kill2SideshowStalkerWithBackstab",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_144',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(145)=(SteamName="Kill5SideshowCrawlersWithBullpup",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_145',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(146)=(SteamName="Kill5SideshowBloats",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_146',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(147)=(SteamName="KillSideshowScrakeWithCrossbow",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_147',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(148)=(SteamName="KillSideshowHuskWithLAW",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_148',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(149)=(SteamName="Kill3SideshowClotsWithLAR",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_149',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(150)=(SteamName="KillSideshowFleshpoundWithPistol",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_150',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(151)=(SteamName="Drop5Tier2WeaponsOneWaveSideshow",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_151',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(152)=(SteamName="SurviveSideshowSirenScreamPlus10Sec",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_152',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(153)=(SteamName="MeleeKill4SideshowZedsInOneSlomo",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_153',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(154)=(SteamName="Kill10SideshowClotsWithFireWeapon",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_154',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(155)=(SteamName="Unlock10ofSideshowAchievements",bShowProgress=1,ProgressDenominator=11,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_155',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(156)=(SteamName="KillHalloweenPatriarchInBedlam",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_156',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(157)=(SteamName="DecapBurningHalloweenZedInBedlam",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_157',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(158)=(SteamName="Kill250HalloweenZedsInBedlam",bShowProgress=1,ProgressDenominator=250,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_158',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(159)=(SteamName="WinBedlamHardHalloween",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_159',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(160)=(SteamName="Kill25HalloweenScrakesInBedlam",bShowProgress=1,ProgressDenominator=25,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_160',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(161)=(SteamName="Kill5HalloweenZedsWithoutReload",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_161',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(162)=(SteamName="Unlock6ofHalloweenAchievements",bShowProgress=1,ProgressDenominator=6,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_162',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(163)=(SteamName="Kill15XMasHusksWithHuskCannon",bShowProgress=1,ProgressDenominator=15,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_163',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(164)=(SteamName="KillXMasPatriarchWithClaymoreDecap",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_164',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(165)=(SteamName="Kill1XMasZedWithFullM4Clip",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_165',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(166)=(SteamName="KillXMasScrakeWithDirectM203Nade",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_166',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(167)=(SteamName="Heal3000PointsWithMP5DuringXMas",bShowProgress=1,ProgressDenominator=3000,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_167',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(168)=(SteamName="Kill12XMasZedsWith1BenelliClip",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_168',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(169)=(SteamName="KillXMasZedWithEveryRevolverShot",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_169',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(170)=(SteamName="HoldAll3DualiesDuringXMas",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_170',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(171)=(SteamName="WinIceCaveNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_171',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(172)=(SteamName="WinIceCaveHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_172',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(173)=(SteamName="WinIceCaveSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_173',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(174)=(SteamName="WinIceCaveHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_174',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(175)=(SteamName="KillSelectXMasZedsOnSingleMap",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_175',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(176)=(SteamName="Kill12ClotsWithOneMagWithMK23",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_176',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(177)=(SteamName="KillZedThatHurtPlayerWithM7A3",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_177',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(178)=(SteamName="KillOneOfEachZedsWithKSG",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_178',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(179)=(SteamName="KillZedWithSA80AndFNFal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_179',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(180)=(SteamName="Kill2ScrakesOneBulletWithBarret",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_180',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(181)=(SteamName="WinHellrideNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_181',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(182)=(SteamName="WinHellrideHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_182',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(183)=(SteamName="WinHellrideSuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_183',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(184)=(SteamName="WinHellrideHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_184',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(185)=(SteamName="Kill6ZedWithoutReloadingMKB42",ProgressDenominator=6,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_185',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(186)=(SteamName="Kill4StalkersNailgun",ProgressDenominator=4,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_186',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(187)=(SteamName="HealAllPlayersWith1MedicNade",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_187',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(188)=(SteamName="Set200ZedOnFireInHillbilly",bShowProgress=1,ProgressDenominator=200,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_188',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(189)=(SteamName="WinHillbillyNormal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_189',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(190)=(SteamName="WinHillbillyHard",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_190',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(191)=(SteamName="WinHillbillySuicidal",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_191',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(192)=(SteamName="WinHillbillyHell",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_192',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(193)=(SteamName="Complete6ReaperAchievements",bShowProgress=1,ProgressDenominator=7,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_193',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(194)=(SteamName="Destroy25GnomesInHillbilly",ProgressDenominator=25,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_194',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(195)=(SteamName="Kill1000HillbillyZeds",bShowProgress=1,ProgressDenominator=1000,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_195',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(196)=(SteamName="Kill15HillbillyCrawlersThomOrMKB",ProgressDenominator=15,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_196',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(197)=(SteamName="Kill1Hillbilly1HuskAndZedIn1Shot",ProgressDenominator=2,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_197',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(198)=(SteamName="Kill5HillbillyZedsIn10SecsSythOrAxe",ProgressDenominator=5,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_198',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(199)=(SteamName="Set3HillbillyGorefastsOnFire",ProgressDenominator=3,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_199',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(200)=(SteamName="HaveMyAxe",bShowProgress=1,ProgressDenominator=30,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_200',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(201)=(SteamName="OneSmallStepForMan",bShowProgress=1,ProgressDenominator=500,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_201',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(202)=(SteamName="ButItsAllRed",bShowProgress=1,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_202',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(203)=(SteamName="GameOverMan",bShowProgress=1,ProgressDenominator=20,Icon=Texture'KillingFloor2HUD.Achievements.Achievement_203',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(204)=(SteamName="HereIsToUs",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_204',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(205)=(SteamName="AttemptingReentry",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_205',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(206)=(SteamName="AmusingDeath",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_206',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(207)=(SteamName="AGiantStepBackForHumanity",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_207',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     Achievements(208)=(SteamName="DwarfAxe",Icon=Texture'KillingFloor2HUD.Achievements.Achievement_208',LockedIcon=Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock')
     SteamNameStat(0)="DamageHealed"
     SteamNameStat(1)="WeldingPoints"
     SteamNameStat(2)="ShotgunDamage"
     SteamNameStat(3)="HeadshotKills"
     SteamNameStat(4)="StalkerKills"
     SteamNameStat(5)="BullpupDamage"
     SteamNameStat(6)="MeleeDamage"
     SteamNameStat(7)="FlameThrowerDamage"
     SteamNameStat(8)="SelfHeals"
     SteamNameStat(9)="SoleSurvivorWaves"
     SteamNameStat(10)="CashDonated"
     SteamNameStat(11)="FeedingKills"
     SteamNameStat(12)="BurningCrossbowKills"
     SteamNameStat(13)="GibbedFleshpounds"
     SteamNameStat(14)="StalkersKilledWithExplosives"
     SteamNameStat(15)="GibbedEnemies"
     SteamNameStat(16)="SirensKilledWithExplosives"
     SteamNameStat(17)="BloatKills"
     SteamNameStat(18)="TotalZedTime"
     SteamNameStat(19)="SirenKills"
     SteamNameStat(20)="Kills"
     SteamNameStat(21)="ExplosivesDamage"
     SteamNameStat(22)="DemolitionsPipebombKills"
     SteamNameStat(23)="EnemiesGibbedWithM79"
     SteamNameStat(24)="EnemiesKilledWithSCAR"
     SteamNameStat(25)="TeammatesHealedWithMP7"
     SteamNameStat(26)="FleshpoundsKilledWithAA12"
     SteamNameStat(27)="CrawlersKilledInMidair"
     SteamNameStat(28)="Mac10BurnDamage"
     SteamNameStat(29)="DroppedTier3Weapons"
     SteamNameStat(30)="HalloweenKills"
     SteamNameStat(31)="HalloweenScrakeKills"
     SteamNameStat(32)="XMasHusksKilledWithHuskCannon"
     SteamNameStat(33)="XMasPointsHealedWithMP5"
     SteamNameStat(41)="EnemiesKilledWithFNFal"
     SteamNameStat(42)="EnemiesKilledWithBullpup"
     SteamNameStat(43)="ZedSetFireWithTrenchOnHillbilly"
     SteamNameStat(44)="ZedKilledDuringHillbilly"
     SteamNameStat(45)="HillbillyAchievementsCompleted"
     SteamNameStat(46)="Stat46"
     SteamNameStat(47)="FleshPoundsKilledWithAxe"
     SteamNameStat(48)="ZedsKilledWhileAirborne"
     SteamNameStat(49)="ZedsKilledWhileZapped"
     SteamNameAchievement(0)="WinWestLondonNormal"
     SteamNameAchievement(1)="WinManorNormal"
     SteamNameAchievement(2)="WinFarmNormal"
     SteamNameAchievement(3)="WinOfficesNormal"
     SteamNameAchievement(4)="WinBioticsLabNormal"
     SteamNameAchievement(5)="WinAllMapsNormal"
     SteamNameAchievement(6)="WinWestLondonHard"
     SteamNameAchievement(7)="WinManorHard"
     SteamNameAchievement(8)="WinFarmHard"
     SteamNameAchievement(9)="WinOfficesHard"
     SteamNameAchievement(10)="WinBioticsLabHard"
     SteamNameAchievement(11)="WinAllMapsHard"
     SteamNameAchievement(12)="WinWestLondonSuicidal"
     SteamNameAchievement(13)="WinManorSuicidal"
     SteamNameAchievement(14)="WinFarmSuicidal"
     SteamNameAchievement(15)="WinOfficesSuicidal"
     SteamNameAchievement(16)="WinBioticsLabSuicidal"
     SteamNameAchievement(17)="WinAllMapsSuicidal"
     SteamNameAchievement(18)="KillXEnemies"
     SteamNameAchievement(19)="KillXEnemies2"
     SteamNameAchievement(20)="KillXEnemies3"
     SteamNameAchievement(21)="KillXBloats"
     SteamNameAchievement(22)="KillXSirens"
     SteamNameAchievement(23)="KillXStalkersWithExplosives"
     SteamNameAchievement(24)="KillXEnemiesWithFireAxe"
     SteamNameAchievement(25)="KillXScrakesWithChainsaw"
     SteamNameAchievement(26)="KillXBurningEnemiesWithCrossbow"
     SteamNameAchievement(27)="KillXEnemiesFeedingOnCorpses"
     SteamNameAchievement(28)="KillXEnemiesWithGrenade"
     SteamNameAchievement(29)="Kill4EnemiesWithHuntingShotgunShot"
     SteamNameAchievement(30)="KillEnemyUsingBloatAcid"
     SteamNameAchievement(31)="KillFleshpoundWithMelee"
     SteamNameAchievement(32)="MedicKillXEnemiesWithKnife"
     SteamNameAchievement(33)="TurnXEnemiesIntoGiblets"
     SteamNameAchievement(34)="TurnXFleshpoundsIntoGiblets"
     SteamNameAchievement(35)="HealSelfXTimes"
     SteamNameAchievement(36)="OnlySurvivorXWaves"
     SteamNameAchievement(37)="DonateXCashToTeammates"
     SteamNameAchievement(38)="AcquireXMinutesOfZedTime"
     SteamNameAchievement(39)="MaxOutAllPerks"
     SteamNameAchievement(40)="KillPatriarchBeforeHeHeals"
     SteamNameAchievement(41)="KillPatriarchWithLAW"
     SteamNameAchievement(42)="DefeatPatriarchOnSuicidal"
     SteamNameAchievement(43)="WinFoundryNormal"
     SteamNameAchievement(44)="WinFoundryHard"
     SteamNameAchievement(45)="WinFoundrySuicidal"
     SteamNameAchievement(46)="WinAsylumNormal"
     SteamNameAchievement(47)="WinAsylumHard"
     SteamNameAchievement(48)="WinAsylumSuicidal"
     SteamNameAchievement(49)="WinWyreNormal"
     SteamNameAchievement(50)="WinWyreHard"
     SteamNameAchievement(51)="WinWyreSuicidal"
     SteamNameAchievement(52)="WinAll3SummerMapsNormal"
     SteamNameAchievement(53)="WinAll3SummerMapsHard"
     SteamNameAchievement(54)="WinAll3SummerMapsSuicidal"
     SteamNameAchievement(55)="Kill1000EnemiesWithPipebomb"
     SteamNameAchievement(56)="KillHuskWithFlamethrower"
     SteamNameAchievement(57)="KillPatriarchOnlyCrossbows"
     SteamNameAchievement(58)="Gib500ZedsWithM79"
     SteamNameAchievement(59)="LaserSightedEBRHeadshots25InARow"
     SteamNameAchievement(60)="Kill1000ZedsWithSCAR"
     SteamNameAchievement(61)="Heal200TeammatesWithMP7"
     SteamNameAchievement(62)="Kill100FleshpoundsWithAA12"
     SteamNameAchievement(63)="Kill20CrawlersKilledInAir"
     SteamNameAchievement(64)="Obliterate10ZedsWithPipebomb"
     SteamNameAchievement(65)="WinWestLondonHell"
     SteamNameAchievement(66)="WinManorHell"
     SteamNameAchievement(67)="WinFarmHell"
     SteamNameAchievement(68)="WinOfficesHell"
     SteamNameAchievement(69)="WinBioticsLabHell"
     SteamNameAchievement(70)="WinFoundryHell"
     SteamNameAchievement(71)="WinAsylumHell"
     SteamNameAchievement(72)="WinWyreHell"
     SteamNameAchievement(73)="WinBiohazardNormal"
     SteamNameAchievement(74)="WinBiohazardHard"
     SteamNameAchievement(75)="WinBiohazardSuicidal"
     SteamNameAchievement(76)="WinBiohazardHell"
     SteamNameAchievement(77)="WinCrashNormal"
     SteamNameAchievement(78)="WinCrashHard"
     SteamNameAchievement(79)="WinCrashSuicidal"
     SteamNameAchievement(80)="WinCrashHell"
     SteamNameAchievement(81)="WinDepartedNormal"
     SteamNameAchievement(82)="WinDepartedHard"
     SteamNameAchievement(83)="WinDepartedSuicidal"
     SteamNameAchievement(84)="WinDepartedHell"
     SteamNameAchievement(85)="WinFilthsCrossNormal"
     SteamNameAchievement(86)="WinFilthsCrossHard"
     SteamNameAchievement(87)="WinFilthsCrossSuicidal"
     SteamNameAchievement(88)="WinFilthsCrossHell"
     SteamNameAchievement(89)="WinHospitalHorrorsNormal"
     SteamNameAchievement(90)="WinHospitalHorrorsHard"
     SteamNameAchievement(91)="WinHospitalHorrorsSuicidal"
     SteamNameAchievement(92)="WinHospitalHorrorsHell"
     SteamNameAchievement(93)="WinIcebreakerNormal"
     SteamNameAchievement(94)="WinIcebreakerHard"
     SteamNameAchievement(95)="WinIcebreakerSuicidal"
     SteamNameAchievement(96)="WinIcebreakerHell"
     SteamNameAchievement(97)="WinMountainPassNormal"
     SteamNameAchievement(98)="WinMountainPassHard"
     SteamNameAchievement(99)="WinMountainPassSuicidal"
     SteamNameAchievement(100)="WinMountainPassHell"
     SteamNameAchievement(101)="WinSuburbiaNormal"
     SteamNameAchievement(102)="WinSuburbiaHard"
     SteamNameAchievement(103)="WinSuburbiaSuicidal"
     SteamNameAchievement(104)="WinSuburbiaHell"
     SteamNameAchievement(105)="WinWaterworksNormal"
     SteamNameAchievement(106)="WinWaterworksHard"
     SteamNameAchievement(107)="WinWaterworksSuicidal"
     SteamNameAchievement(108)="WinWaterworksHell"
     SteamNameAchievement(109)="CompleteNewAchievementsNormal"
     SteamNameAchievement(110)="CompleteNewAchievementsHard"
     SteamNameAchievement(111)="CompleteNewAchievementsSuicidal"
     SteamNameAchievement(112)="CompleteNewAchievementsHell"
     SteamNameAchievement(113)="Get1000BurnDamageWithMac10"
     SteamNameAchievement(114)="WinSantasEvilLairNormal"
     SteamNameAchievement(115)="WinSantasEvilLairHard"
     SteamNameAchievement(116)="WinSantasEvilLairSuicidal"
     SteamNameAchievement(117)="WinSantasEvilLairHell"
     SteamNameAchievement(118)="KillChristmasPatriarch"
     SteamNameAchievement(119)="KnifeChristmasFleshpound"
     SteamNameAchievement(120)="MeleeKill2ChristmasGorefastFromBack"
     SteamNameAchievement(121)="KillChristmasScrakeWithFire"
     SteamNameAchievement(122)="Kill3ChristmasBloatsWithBullpup"
     SteamNameAchievement(123)="Kill20ChristmasClots"
     SteamNameAchievement(124)="KillChristmasCrawlerWithXBow"
     SteamNameAchievement(125)="KillChristmasSirenWithLawImpact"
     SteamNameAchievement(126)="Kill3ChristmasStalkersWithLAR"
     SteamNameAchievement(127)="KillChristmasHuskWithPistol"
     SteamNameAchievement(128)="MeleeKill3ChristmasZedsInOneSlomo"
     SteamNameAchievement(129)="Drop3Tier3WeaponsForOthersChristmas"
     SteamNameAchievement(130)="ChristmasVomitLive10Seconds"
     SteamNameAchievement(131)="Unlock10ofChristmasAchievements"
     SteamNameAchievement(132)="Achievement132"
     SteamNameAchievement(133)="Achievement133"
     SteamNameAchievement(134)="Achievement134"
     SteamNameAchievement(135)="Achievement135"
     SteamNameAchievement(136)="Achievement136"
     SteamNameAchievement(137)="Achievement137"
     SteamNameAchievement(138)="WinSideshowNormal"
     SteamNameAchievement(139)="WinSideshowHard"
     SteamNameAchievement(140)="WinSideshowSuicidal"
     SteamNameAchievement(141)="WinSideshowHell"
     SteamNameAchievement(142)="KillSideshowPatriarch"
     SteamNameAchievement(143)="KillSideshowGorefastWithMelee"
     SteamNameAchievement(144)="Kill2SideshowStalkerWithBackstab"
     SteamNameAchievement(145)="Kill5SideshowCrawlersWithBullpup"
     SteamNameAchievement(146)="Kill5SideshowBloats"
     SteamNameAchievement(147)="KillSideshowScrakeWithCrossbow"
     SteamNameAchievement(148)="KillSideshowHuskWithLAW"
     SteamNameAchievement(149)="Kill3SideshowClotsWithLAR"
     SteamNameAchievement(150)="KillSideshowFleshpoundWithPistol"
     SteamNameAchievement(151)="Drop5Tier2WeaponsOneWaveSideshow"
     SteamNameAchievement(152)="SurviveSideshowSirenScreamPlus10Sec"
     SteamNameAchievement(153)="MeleeKill4SideshowZedsInOneSlomo"
     SteamNameAchievement(154)="Kill10SideshowClotsWithFireWeapon"
     SteamNameAchievement(155)="Unlock10ofSideshowAchievements"
     SteamNameAchievement(156)="KillHalloweenPatriarchInBedlam"
     SteamNameAchievement(157)="DecapBurningHalloweenZedInBedlam"
     SteamNameAchievement(158)="Kill250HalloweenZedsInBedlam"
     SteamNameAchievement(159)="WinBedlamHardHalloween"
     SteamNameAchievement(160)="Kill25HalloweenScrakesInBedlam"
     SteamNameAchievement(161)="Kill5HalloweenZedsWithoutReload"
     SteamNameAchievement(162)="Unlock6ofHalloweenAchievements"
     SteamNameAchievement(163)="Kill15XMasHusksWithHuskCannon"
     SteamNameAchievement(164)="KillXMasPatriarchWithClaymoreDecap"
     SteamNameAchievement(165)="Kill1XMasZedWithFullM4Clip"
     SteamNameAchievement(166)="KillXMasScrakeWithDirectM203Nade"
     SteamNameAchievement(167)="Heal3000PointsWithMP5DuringXMas"
     SteamNameAchievement(168)="Kill12XMasZedsWith1BenelliClip"
     SteamNameAchievement(169)="KillXMasZedWithEveryRevolverShot"
     SteamNameAchievement(170)="HoldAll3DualiesDuringXMas"
     SteamNameAchievement(171)="WinIceCaveNormal"
     SteamNameAchievement(172)="WinIceCaveHard"
     SteamNameAchievement(173)="WinIceCaveSuicidal"
     SteamNameAchievement(174)="WinIceCaveHell"
     SteamNameAchievement(175)="KillSelectXMasZedsOnSingleMap"
     SteamNameAchievement(176)="Kill12ClotsWithOneMagWithMK23"
     SteamNameAchievement(177)="KillZedThatHurtPlayerWithM7A3"
     SteamNameAchievement(178)="KillOneOfEachZedsWithKSG"
     SteamNameAchievement(179)="KillZedWithSA80AndFNFal"
     SteamNameAchievement(180)="Kill2ScrakesOneBulletWithBarret "
     SteamNameAchievement(181)="WinHellrideNormal"
     SteamNameAchievement(182)="WinHellrideHard"
     SteamNameAchievement(183)="WinHellrideSuicidal"
     SteamNameAchievement(184)="WinHellrideHell"
     SteamNameAchievement(185)="Kill6ZedWithoutReloadingMKB42"
     SteamNameAchievement(186)="Kill4StalkersNailgun"
     SteamNameAchievement(187)="HealAllPlayersWith1MedicNade"
     SteamNameAchievement(188)="Set200ZedOnFireInHillbilly"
     SteamNameAchievement(189)="WinHillbillyNormal"
     SteamNameAchievement(190)="WinHillbillyHard"
     SteamNameAchievement(191)="WinHillbillySuicidal"
     SteamNameAchievement(192)="WinHillbillyHell"
     SteamNameAchievement(193)="Complete6ReaperAchievements"
     SteamNameAchievement(194)="Destroy25GnomesInHillbilly"
     SteamNameAchievement(195)="Kill1000HillbillyZeds"
     SteamNameAchievement(196)="Kill15HillbillyCrawlersThomOrMKB"
     SteamNameAchievement(197)="Kill1Hillbilly1HuskAndZedIn1Shot"
     SteamNameAchievement(198)="Kill5HillbillyZedsIn10SecsSythOrAxe"
     SteamNameAchievement(199)="Set3HillbillyGorefastsOnFire"
     SteamNameAchievement(200)="HaveMyAxe"
     SteamNameAchievement(201)="OneSmallStepForMan"
     SteamNameAchievement(202)="ButItsAllRed"
     SteamNameAchievement(203)="GameOverMan"
     SteamNameAchievement(204)="HereIsToUs"
     SteamNameAchievement(205)="AttemptingReentry"
     SteamNameAchievement(206)="AmusingDeath"
     SteamNameAchievement(207)="AGiantStepBackForHumanity"
     SteamNameAchievement(208)="DwarfAxe"
}
