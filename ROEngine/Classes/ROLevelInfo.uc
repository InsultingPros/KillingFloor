//=============================================================================
// ROLevelInfo
//=============================================================================
// Lets mappers set level properties for RO
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROLevelInfo extends Info
	placeable;

//=============================================================================
// Variables
//=============================================================================

enum ESide
{
	SIDE_None,
	SIDE_Axis,
	SIDE_Allies,
};

enum ENation
{
	NATION_Germany,
	NATION_SovietUnion,
};

enum ERotationOffset
{
	OFFSET_Zero,
	OFFSET_90,
	OFFSET_180,
	OFFSET_270,
};

enum EArtyStrikePattern
{
	STR_Tight,
	STR_Normal,
	STR_Loose,
};

enum EArtyBatterySize
{
	BAT_4_to_6,
	BAT_8_to_12,
	BAT_15,
};

enum EArtySalvoAmount
{
	SALVO_2_to_3,
	SALVO_4_to_6,
	SALVO_6_to_8,
};

enum EArtyStrikeInterval
{
	INT_Short_30s,
	INT_Med_45s,
	INT_Long_1m,
	INT_VLong_3m,
};

enum EArtyStrikeDelay
{
	DELAY_Short_15s,
	DELAY_Med_30s,
	DELAY_Long_1m,
	DELAY_VLong_2m,
};

struct SideData
{
	var()	ENation			   Nation;
	var()	localized string   UnitName;
	var()	Material			UnitInsignia;
	var()	int				SpawnLimit;
	var()	int				ReinforcementInterval;
	var()	int				ArtilleryStrikeLimit;      // Number of strikes available for this team
	var()	EArtyStrikePattern	ArtilleryStrikePattern;	  // How dispersed the shots will be
	var()	EArtyBatterySize	ArtilleryBatterySize;	  // How many shots there will be with each strike
	var()	EArtySalvoAmount	ArtillerySalvoAmount;	  // How many salvos there will be per strike
	var()   	EArtyStrikeInterval	ArtilleryStrikeInterval;   // Interval between Artillery Strikes
	var()   	EArtyStrikeDelay    ArtilleryStrikeDelay;      // Time in seconds to wait until strike begins after calling it in
	//var()	editinline	RORoleInfo	Roles[10];
};

var()	int					NumObjectiveWin;		// Number of completed objectives required for victory (0 = all required)
var()	int					RoundDuration;			// Length of a round in minutes
var()	ESide				DefendingSide;			// Used to enable attacker/defender gameplay
var()	bool					bUseSpawnAreas;		// Used to turn on the moving spawn functionality
var()	Material				MapImage;			// Used for the objectives screen
var()	name					EndCamTag;			// Used to specify an end camera location
var()	name					StartCamTag;		// Used to specify an end camera location
var()	array<name>			EntryCamTags;			// Specify the tags of cameras to be looped through by entering players
var()	SideData				Axis;				// All properties for both sides are set here
var()	SideData				Allies;
var()	int					TempFahrenheit;
var()   	bool					bDebugOverhead;     	// whether or not to display overhead map debugging icons
var()   	ERotationOffset		OverheadOffset;     	// The offset that the real map is relative to the overhead map
var()	float					RallyPointInterval;      // How often commanders can change rally points, limit to prevent spam

// Satchel Limits
var()	int					AxisSatchelsPerSapper;	// Number of satchels an axis sapper starts with
var()	int					AlliedSatchelsPerSapper;	// Number of satchels an Allied sapper starts with

var() localized string        AxisUnitDescription;
var() localized string        AlliesUnitDescription;

var()	float				VehicleBotRoleBalance; // Percentage of bots that will try and get a vehicle role

// For limiting the amount of certain vehicles
struct LimitedVehicle
{
	var()	class<ROVehicle>   VehicleClass;
	var()	int                VehicleLimit;
	var   	int                VehicleTotal;
};

var()	array<LimitedVehicle>  LimitedVehicles;

var()	bool			       bUseVehicleTotalLimits;		// Use the vehicle type limits to prevent more than a certain amount of a vehicle class from being spawned in a map at one time

// SET TO false BEFORE RELEASE
var		const bool			bRODebugMode;			// flag for whether debug commands can be run

singular static function bool RODebugMode() { return default.bRODebugMode; }


//-----------------------------------------------------------------------------
// Getters for the Artillery System
//-----------------------------------------------------------------------------

function SideData GetSideDataByTeam( int Team )
{
	if (Team == 0)
	{
		return Axis;
	}
	else
	{
		return Allies;
	}
}

function int GetBatterySize( int Team )
{
   	local int BatterySize;

	switch(GetSideDataByTeam(Team).ArtilleryBatterySize)
	{
	case BAT_4_to_6:
		BatterySize = Rand(3) + 4;
		break;
	case BAT_8_to_12:
		BatterySize = Rand(5) + 8;
		break;
	case BAT_15:
		BatterySize = Rand(3) + 16;
		break;
	default:
		BatterySize = Rand(3) + 4;
	}

	return BatterySize;
}

function int GetSalvoAmount( int Team )
{
   	local int SalvoAmount;

	switch(GetSideDataByTeam(Team).ArtillerySalvoAmount)
	{
	case SALVO_2_to_3:
		SalvoAmount = Rand(2) + 2;
		break;
	case SALVO_4_to_6:
		SalvoAmount = Rand(3) + 4;
		break;
	case SALVO_6_to_8:
		SalvoAmount = Rand(3) + 6;
		break;
	default:
		SalvoAmount = Rand(3) + 4;
	}

	return SalvoAmount;
}

function int GetSpreadAmount( int Team )
{
   	local int SpreadAmount;

   	switch(GetSideDataByTeam(Team).ArtilleryStrikePattern)
	{
	case STR_Tight:
		SpreadAmount = 400;
		break;
	case STR_Normal:
		SpreadAmount = 1000;
		break;
	case STR_Loose:
		SpreadAmount = 2000;
		break;
	default:
		SpreadAmount = 1000;
	}

	return SpreadAmount;
}

function int GetStrikeInterval( int Team )
{
   	local int StrikeInterval;

   	switch(GetSideDataByTeam(Team).ArtilleryStrikeInterval)
	{
	case INT_Short_30s:
		StrikeInterval = 30;
		break;
	case INT_Med_45s:
		StrikeInterval = 45;
		break;
	case INT_Long_1m:
		StrikeInterval = 60;
		break;
	case INT_VLong_3m:
		StrikeInterval = 150;//180; nerfed a bit
		break;
	default:
		StrikeInterval = 30;
	}

	return StrikeInterval;
}

function int GetStrikeDelay( int Team )
{
   	local int StrikeDelay;

   	switch(GetSideDataByTeam(Team).ArtilleryStrikeDelay)
	{
	case DELAY_Short_15s:
		StrikeDelay = 15;
		break;
	case DELAY_Med_30s:
		StrikeDelay = 30;
		break;
	case DELAY_Long_1m:
		StrikeDelay = 60;
		break;
	case DELAY_VLong_2m:
		StrikeDelay = 120;
		break;
	default:
		StrikeDelay = 15;
	}

	return StrikeDelay;
}

// When a vehicle is spawned, this is called to remove it from the totals
function HandleSpawnedVehicle( class <ROVehicle> CheckClass )
{
    local int i;

	for (i = 0; i < LimitedVehicles.Length; i++)
	{
        if (LimitedVehicles[i].VehicleClass == CheckClass)
		{
            LimitedVehicles[i].VehicleTotal += 1;
           	//log("Adding a vehicle, total = "$LimitedVehicles[i].VehicleTotal);
            break;
		}
	}


}

// When a vehicle is destroyed, this is called to remove it from the totals
function HandleDestroyedVehicle( class <ROVehicle> CheckClass )
{
    local int i;

	for (i = 0; i < LimitedVehicles.Length; i++)
	{
        if (LimitedVehicles[i].VehicleClass == CheckClass)
		{
            LimitedVehicles[i].VehicleTotal -= 1;
            //log("Destroying a vehicle, total = "$LimitedVehicles[i].VehicleTotal);
            break;
		}
	}
}

// Returns true if we are over the limit for this vehicle
function bool OverVehicleLimit( class <ROVehicle> CheckClass )
{
    local int i;

	for (i = 0; i < LimitedVehicles.Length; i++)
	{
        if (LimitedVehicles[i].VehicleClass == CheckClass)
		{
            if( LimitedVehicles[i].VehicleTotal >= LimitedVehicles[i].VehicleLimit )
            {
                return true;
            }
            break;
		}
	}

    return false;
}

// Not sure if this is needed, maybe remove
// Reset the vehicle totals to zero
function ResetVehicleLimits()
{
    local int i;

	for (i = 0; i < LimitedVehicles.Length; i++)
	{
        LimitedVehicles[i].VehicleTotal = 0;
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RoundDuration=10
     Axis=(UnitName="Axis",SpawnLimit=150,ReinforcementInterval=30,ArtilleryStrikeLimit=3,ArtilleryStrikePattern=STR_Normal,ArtillerySalvoAmount=SALVO_4_to_6)
     Allies=(Nation=NATION_SovietUnion,UnitName="Allies",SpawnLimit=150,ReinforcementInterval=30,ArtilleryStrikeLimit=3,ArtilleryStrikePattern=STR_Normal,ArtillerySalvoAmount=SALVO_4_to_6)
     TempFahrenheit=65
     RallyPointInterval=5.000000
     AxisSatchelsPerSapper=1
     AlliedSatchelsPerSapper=1
     AxisUnitDescription="Set the Axis unit description for this map here."
     AlliesUnitDescription="Set the Allies unit description for this map here."
     VehicleBotRoleBalance=0.700000
     bNoDelete=True
     bDirectional=True
}
