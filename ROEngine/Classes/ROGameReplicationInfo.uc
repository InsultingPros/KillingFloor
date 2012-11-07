//=============================================================================
// ROGameReplicationInfo
//=============================================================================
// Adds some RO stuff the client needs to know about
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROGameReplicationInfo extends GameReplicationInfo;

//=============================================================================
// Variables
//=============================================================================

// Roles
var	RORoleInfo		AxisRoles[10];			// Used to replicate assorted role information to the client
var	RORoleInfo		AlliesRoles[10];

// Objectives
var	ROObjective	Objectives[16];

// Rally point
struct SavedRallyPointInfo
{
	var vector RallyPointLocation;
	var PlayerReplicationInfo OfficerPRI;
};

var	SavedRallyPointInfo		AlliedRallyPoints[12];		// Rally points for the allied team
var	SavedRallyPointInfo		AxisRallyPoints[12];        // Rally points for the axis team

// Help requests
struct SavedHelpRequestInfo
{
	var byte objectiveID;
	var byte requestType;   // 0 = need help at obj, 1 = attack, 2 = defend,
                            // 3 = MG resupply, 4 = need help at coords, 255 = no assignment
	var PlayerReplicationInfo OfficerPRI;
};

var SavedHelpRequestInfo    AlliedHelpRequests[16];    // Help requests for allied team
var SavedHelpRequestInfo    AxisHelpRequests[16];      // Help requests for axis team
var vector                  AlliedHelpRequestsLocs[16];    // lame workaround for 255 bytes max array size
var vector                  AxisHelpRequestsLocs[16];

// Artillery
var	        ROArtilleryTrigger	AlliedRadios[10];       // An array of the allied radio stations
var	        ROArtilleryTrigger	AxisRadios[10];         // An array of the axis radio stations
var         vector              ArtyStrikeLocation[2];      // Location of current arty strike


// Not needed for now - Ramm
/*
struct SavedArtilleryInfo
{
	var vector ArtilleryLocation;
	var PlayerReplicationInfo OfficerPRI;
};

var		array<SavedArtilleryInfo>	ArtilleryLocations;
*/

/*struct ROPoke
{
	var vector PokeLocation;
	var float PokeDepth;
	var float PokeRadius;
	var TerrainInfo PokedTerrain;
};

var ROPoke SavedPoke[10]; */
//var int PokeIndex;

struct ResupplyVolumeInfo
{
	var vector 	ResupplyVolumeLocation;
	var int		Team;					//Team this volume resupplies
	var bool	bActive;				// Whether this ammo resupply volume is active
	var byte 	ResupplyType;			// Who the volume will resupply: 0 = players, 1 = vehicles, 2 = all
};

//ResupplyZones
var	ResupplyVolumeInfo		ResupplyAreas[10];

struct ATCannonInfo
{
	var vector 	ATCannonLocation;       // Location of the AT Cannon. Using the Z value to indicate active status (0 = inactive, 1 = active) since the Z value is never used by the overhead map - this saves on replication
	var byte	Team;					// Team controlling this AT Cannon
};

//At cannons to display
var	ATCannonInfo		ATCannons[14];

//Server side scoreboard settigns
var bool bShowServerIPOnScoreboard;// Toggles on/off displaying the IP of the current server on the scoreboard
var bool bShowTimeOnScoreboard;    // Toggles on/off displaying the current time on the scoreboard

var bool	                     bAllowNetDebug;           // Server allows the use of net debugging info

//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (bNetDirty && (Role == ROLE_Authority))
		AxisRoles, AlliesRoles, Objectives, AlliedRallyPoints, AxisRallyPoints, ResupplyAreas,
        AlliedHelpRequests, AxisHelpRequests, AlliedHelpRequestsLocs, AxisHelpRequestsLocs,
        ArtyStrikeLocation, ATCannons;

	reliable if (bNetInitial && (Role == ROLE_Authority))
		AlliedRadios, AxisRadios, bShowServerIPOnScoreboard, bShowTimeOnScoreboard, bAllowNetDebug;
}

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay - Sets the Timer to Level.TimeDilation rather than 1
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MessageOfTheDay = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(Level.TimeDilation, true);
}

//-----------------------------------------------------------------------------
// Timer - Played some games to make client time more accurate
//-----------------------------------------------------------------------------

simulated function Timer()
{
	if ( Level.NetMode == NM_Client )
	{
		if (ElapsedQuarterMinute != 0)
		{
			ElapsedTime = ElapsedQuarterMinute;
			ElapsedQuarterMinute = 0;
		}
		else
		{
			ElapsedTime++;
		}

		if ( RemainingMinute != 0 )
		{
			RemainingTime = RemainingMinute;
			RemainingMinute = 0;
		}

		if ( (RemainingTime > 0) && !bStopCountDown )
			RemainingTime--;
		SecondCount += Level.TimeDilation;

		if ( !bTeamSymbolsUpdated )
			TeamSymbolNotify();
	}
}

function int AddATCannon(vector NewLocation, byte NewTeam)
{
    local int i;

	for (i=0;i<ArrayCount(ATCannons);i++)
	{
		if( ATCannons[i].ATCannonLocation == vect(0,0,0) )
		{
		    NewLocation.Z = 0;
            ATCannons[i].ATCannonLocation = NewLocation;
            ATCannons[i].Team = NewTeam;
            //ATCannons[i].ATCannonLocation.Z = 0;
            return i;
            break;
		}
	}

	return -1;
}

function SetATCannonActiveStatus(int index, bool NewState)
{
    if( NewState )
    {
        ATCannons[index].ATCannonLocation.Z = 1;
    }
    else
    {
        ATCannons[index].ATCannonLocation.Z = 0;
    }
}

function SetATCannonTeamStatus(int index, byte NewTeam)
{
    ATCannons[index].Team = NewTeam;
}

function AddRallyPoint( PlayerReplicationInfo PRI, vector NewLoc, optional bool bRemoveFromList)
{
	local int i;
	local bool bFoundPRI;
	local SavedRallyPointInfo NewRallyPoint;

	// Team 0 = Axis
	if( PRI.Team.TeamIndex == AXIS_TEAM_INDEX )
	{
    	for (i=0;i<ArrayCount(AxisRallyPoints);i++)
    	{
    		if( AxisRallyPoints[i].OfficerPRI == PRI )
    		{
    		    if (bRemoveFromList)
    		    {
    		        AxisRallyPoints[i].RallyPointLocation = vect(0,0,0);
    		        AxisRallyPoints[i].OfficerPRI = none;
    		    }
    		    else
    		    {
    		        AxisRallyPoints[i].RallyPointLocation = NewLoc;
    		    }
    			bFoundPRI = true;
    			break;
    		}
    	}

    	if( !bFoundPRI && !bRemoveFromList)
    	{
    		NewRallyPoint.OfficerPRI = PRI;
    		NewRallyPoint.RallyPointLocation = NewLoc;

	    	for (i=0;i<ArrayCount(AxisRallyPoints);i++)
	    	{
	    		if( AxisRallyPoints[i].RallyPointLocation == vect(0,0,0) )
	    		{
	    			AxisRallyPoints[i] = NewRallyPoint;
	    			break;
	    		}
	    	}
    	}
    }
    else
    {
    	for (i=0;i<ArrayCount(AlliedRallyPoints);i++)
    	{
    		if( AlliedRallyPoints[i].OfficerPRI == PRI )
    		{
    			if (bRemoveFromList)
    		    {
    		        AlliedRallyPoints[i].RallyPointLocation = vect(0,0,0);
    		        AlliedRallyPoints[i].OfficerPRI = none;
    		    }
    		    else
    		    {
    		        AlliedRallyPoints[i].RallyPointLocation = NewLoc;
    		    }
    			bFoundPRI = true;
    			break;
    		}
    	}

    	if( !bFoundPRI && !bRemoveFromList )
    	{
    		NewRallyPoint.OfficerPRI = PRI;
    		NewRallyPoint.RallyPointLocation = NewLoc;

	    	for (i=0;i<ArrayCount(AlliedRallyPoints);i++)
	    	{
	    		if( AlliedRallyPoints[i].RallyPointLocation == vect(0,0,0) )
	    		{
	    			AlliedRallyPoints[i] = NewRallyPoint;
	    			break;
	    		}
	    	}
    	}
    }

   // log("AlliedRallyPoints.Length =  "$AlliedRallyPoints.Length$" AxisRallyPoints.Length = "$AxisRallyPoints.Length);

}

// call with requestType of -1 to clear a specific player's help request
function AddHelpRequest( PlayerReplicationInfo PRI, int objectiveID, int requestType, optional vector requestLocation)
{
	local int i;
	local bool bFoundPRI;
	local SavedHelpRequestInfo NewHelpRequest;

	// Team 0 = Axis
	if( PRI.Team.TeamIndex == AXIS_TEAM_INDEX )
	{
    	for (i=0;i<ArrayCount(AxisHelpRequests);i++)
    	{
    		if( AxisHelpRequests[i].OfficerPRI == PRI )
    		{
    		    AxisHelpRequests[i].objectiveID = objectiveID;
    			AxisHelpRequests[i].requestType = requestType;
    			AxisHelpRequestsLocs[i] = requestLocation;
    			if (requestType == -1)
    			{
    			    AxisHelpRequests[i].OfficerPRI = none;
    			    AxisHelpRequests[i].requestType = 255;
    			}
    			bFoundPRI = true;
    			break;
    		}
    	}

    	if( !bFoundPRI && requestType != -1)
    	{
    		NewHelpRequest.OfficerPRI = PRI;
    		NewHelpRequest.objectiveID = objectiveID;
    		NewHelpRequest.requestType = requestType;
	    	for (i=0; i<ArrayCount(AxisHelpRequests); i++)
	    	{
	    		if( AxisHelpRequests[i].requestType == 255 )
	    		{
	    			AxisHelpRequests[i] = NewHelpRequest;
	    			AxisHelpRequestsLocs[i] = requestLocation;
	    			break;
	    		}
	    	}
    	}
    }
    else if( PRI.Team.TeamIndex == ALLIES_TEAM_INDEX )
    {
    	for (i=0;i<ArrayCount(AlliedHelpRequests);i++)
    	{
    		if( AlliedHelpRequests[i].OfficerPRI == PRI )
    		{
    		    AlliedHelpRequests[i].objectiveID = objectiveID;
    			AlliedHelpRequests[i].requestType = requestType;
    			AlliedHelpRequestsLocs[i] = requestLocation;
    			if (requestType == -1)
    			{
    			    AlliedHelpRequests[i].OfficerPRI = none;
    			    AlliedHelpRequests[i].requestType = 255;
    			}
    			bFoundPRI = true;
    			break;
    		}
    	}

    	if( !bFoundPRI && requestType != -1)
    	{
    		NewHelpRequest.OfficerPRI = PRI;
    		NewHelpRequest.objectiveID = objectiveID;
    		NewHelpRequest.requestType = requestType;
	    	for (i=0;i<ArrayCount(AlliedHelpRequests);i++)
	    	{
	    		if( AlliedHelpRequests[i].requestType == 255 )
	    		{
	    			AlliedHelpRequests[i] = NewHelpRequest;
	    			AlliedHelpRequestsLocs[i] = requestLocation;
	    			break;
	    		}
	    	}
    	}
    }
}

function RemoveMGResupplyRequestFor(PlayerReplicationInfo PRI)
{
    local int i;

    // Search request array to see if there's an MG resupply request for this player
    if( PRI.Team.TeamIndex == AXIS_TEAM_INDEX )
    {
        for (i = 0; i < ArrayCount(AxisHelpRequests); i++)
            if (AxisHelpRequests[i].OfficerPRI == PRI)
                if (AxisHelpRequests[i].requestType == 2)
                {
                    AxisHelpRequests[i].OfficerPRI = none;
    			    AxisHelpRequests[i].requestType = 255;
    			    break;
                }
    }
    else if( PRI.Team.TeamIndex == ALLIES_TEAM_INDEX )
    {
        for (i = 0; i < ArrayCount(AlliedHelpRequests); i++)
            if (AlliedHelpRequests[i].OfficerPRI == PRI)
                if (AlliedHelpRequests[i].requestType == 2)
                {
                    AlliedHelpRequests[i].OfficerPRI = none;
    			    AlliedHelpRequests[i].requestType = 255;
    			    break;
                }
    }
}

// called when an objective is taken/defended
function RemoveHelpRequestsForObjective(int objID)
{
    local int i;
    for (i=0;i<ArrayCount(AlliedHelpRequests);i++)
    {
        if (AlliedHelpRequests[i].objectiveID == objID && AlliedHelpRequests[i].requestType != 255)
            AlliedHelpRequests[i].requestType = 255;
        if (AxisHelpRequests[i].objectiveID == objID && AxisHelpRequests[i].requestType != 255)
            AxisHelpRequests[i].requestType = 255;
    }
}

// Get the role index for a given role and team
simulated function int GetRoleIndex(RORoleInfo ROInf, int TeamNum)
{
   local int  count;

   if(TeamNum >= NEUTRAL_TEAM_INDEX)
      return -1;

   for(count = 0 ; count < ArrayCount(AxisRoles) ; count++)
   {
        switch(TeamNum)
        {
           case AXIS_TEAM_INDEX : // Axis
           if(AxisRoles[count] != none && AxisRoles[count] == ROInf)
           {
              return count;
           }
           break;
           case ALLIES_TEAM_INDEX : // Allies
           if(AlliesRoles[count] != none && AlliesRoles[count] == ROInf)
           {
              return count;
           }
           break;
        }
   }
   //not found
   return -1;
}

// Not needed for now - Ramm
/*
function AddArtyLocation( PlayerReplicationInfo PRI, vector NewLoc)
{
	local SavedArtilleryInfo SAI;

	SAI.OfficerPRI = PRI;
	SAI.ArtilleryLocation =  NewLoc;

	ArtilleryLocations[ArtilleryLocations.Length] = SAI;
} */

defaultproperties
{
}
