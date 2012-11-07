//=============================================================================
// ROObjective
//=============================================================================
// Defines an objective
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class ROObjective extends GameObjective
	placeable;

//#exec OBJ LOAD FILE=..\Textures\ROInterfaceArt.utx

//=============================================================================
// Variables
//=============================================================================

// Defines an objective state
enum EObjectiveState
{
	OBJ_Axis,
	OBJ_Allies,
	OBJ_Neutral,
};

var		EObjectiveState			ObjState;				// Manages the state of the objective
var()	EObjectiveState			InitialObjState;		// Mappers sets the original state of an objective here

var()	int						ObjNum;					// Number on objectives list
var()	bool					bRequired;				// Is this objective required for victory?
var()	localized	string		ObjName;				// Text stuff needed.  Make sure it's localized so it's translateable.
var()	localized	string		AttackerDescription;
var()	localized	string		DefenderDescription;

//var		bool					bObjActive;
//var()   bool                    bObjInitiallyActive;

var()	int						Radius;					// Radius to use if not using a volume
var()	name					VolumeTag;				// Tag of the volume to use if you want to use a volume
var		Volume					AttachedVolume;			// Stores the attached volume.

var()	name					AlliesEvent;
var()	name					AxisEvent;

var()	int						MapX;					// x position of objective on player map
var()	int						MapY;                   // y position of objective on player map

// Values for bot AI
var()	int						AxisObjectivePriority;	// How important this objective is to the Axis
var()	int						AlliesObjectivePriority;// How important this objective is to the Allies

// Used in ROObjTerritory -- put here so that it can be accessed from ROHud
var     byte            CompressedCapProgress;      // Used for replication
var		byte			CurrentCapTeam;				// Stores the current team that is capping

// Used in ROHud to calculate objective label offsets
var     FloatBox        LabelCoords;

// Used to tell ROHud not to display text under this objective
var()   bool                    bDoNotDisplayTitleOnSituationMap;
var()   bool                    bDoNotUseLabelShiftingOnSituationMap;

//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		ObjState;//, bObjActive;

	reliable if (bNetInitial && Role == ROLE_Authority)
		bRequired;

// Used in ROObjTerritory -- declared here so that CompressedCapProgress can be accessed from ROHud
	reliable if (bNetDirty && Role == ROLE_Authority)
		CompressedCapProgress, CurrentCapTeam;
}

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay - Handles setup
//-----------------------------------------------------------------------------

function PostBeginPlay()
{
	local 	ROGameReplicationInfo GRI;

	super.PostBeginPlay();

	// Find the volume to use if the mapper set one
	if (VolumeTag != '')
	{
		foreach AllActors(class'Volume', AttachedVolume, VolumeTag)
		{
			AttachedVolume.AssociatedActor = self;
			break;
		}
	}

	ObjState = InitialObjState;
//	bObjActive = bObjInitiallyActive;

	if (ROTeamGame(Level.Game) != None)
		ROTeamGame(Level.Game).Objectives[ObjNum] = self;

	GRI = ROGameReplicationInfo(Level.Game.GameReplicationInfo);

	if (GRI != None)
		GRI.Objectives[ObjNum] = self;
}

// Overridden to match our objective names
simulated function string GetHumanReadableName()
{
	if ( ObjName != "" )
		return ObjName;

	if ( Default.ObjName != "" )
		return Default.ObjName;

	return "";
}

//-----------------------------------------------------------------------------
// Determines if an objective passed in is better than this one. Overriden
// to support RO Objective functionality
//-----------------------------------------------------------------------------
function bool BetterObjectiveThan(GameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( !IsActive()  )
		return false;

	if ( Best == none )
		return true;

	if( DesiredTeamNum == AXIS_TEAM_INDEX && ROObjective(Best).AxisObjectivePriority > AxisObjectivePriority )
		return true;

	if( DesiredTeamNum == ALLIES_TEAM_INDEX && ROObjective(Best).AlliesObjectivePriority > AlliesObjectivePriority )
		return true;

	return false;
}

//---------------------------------------------------------------------------------
// Determines if an objective passed in is higher priority than this one. Overriden
// to support RO Objective functionality
//---------------------------------------------------------------------------------
function bool IsHigherPriority( GameObjective Test, int TestTeamNum)
{
	if( TestTeamNum == AXIS_TEAM_INDEX && ROObjective(Test).AxisObjectivePriority > AxisObjectivePriority )
		return true;
    else if( TestTeamNum == ALLIES_TEAM_INDEX && ROObjective(Test).AlliesObjectivePriority > AlliesObjectivePriority )
		return true;
	else
		return false;
}

//---------------------------------------------------------------------------------
// Determines if an objective passed in is equal priority to this one.
//---------------------------------------------------------------------------------
function bool IsEqualPriority( GameObjective Test, int TestTeamNum)
{
	if( TestTeamNum == AXIS_TEAM_INDEX && ROObjective(Test).AxisObjectivePriority == AxisObjectivePriority )
		return true;
    else if( TestTeamNum == ALLIES_TEAM_INDEX && ROObjective(Test).AlliesObjectivePriority == AlliesObjectivePriority )
		return true;
	else
		return false;
}

//------------------------------------------------------------------------------
// Returns true if the team of the bot passed in owns this objective
//------------------------------------------------------------------------------
function bool TeamOwns(Bot B)
{
	if ( B.Squad.Team.TeamIndex == AXIS_TEAM_INDEX && ObjState == OBJ_Axis)
	{
		return true;
	}
	else if( B.Squad.Team.TeamIndex == ALLIES_TEAM_INDEX && ObjState == OBJ_Allies)
	{
		return true;
	}
	return false;

}

//-----------------------------------------------------------------------------
// Lets the bots know what to do with this objective. Overriden
// to support RO Objective functionality
//-----------------------------------------------------------------------------
function bool TellBotHowToDisable(Bot B)
{
	if ( !IsActive() || TeamOwns(B))
	{
		return false;
	}

	if ( B.Pawn == None )
		return false;

	if ( B.Pawn.ReachedDestination(self) )
	{
		if ( B.Enemy != None )
		{
			if ( B.EnemyVisible() )
			{
            if(Vehicle(B.Pawn) != none)
				  B.GotoState('RangedAttack','Begin');
				else
				B.GotoState('ShieldSelf','Begin');
			}
			else
				B.DoStakeOut();
		}
		else
			B.GotoState('RestFormation','Pausing');
		return true;
	}

	return Super.TellBotHowToDisable(B);
}


//-----------------------------------------------------------------------------
// WithinArea - Function to identify Actors within the area, if any
//-----------------------------------------------------------------------------

function bool WithinArea(Actor A)
{
	if (AttachedVolume != None)
	{
		if (AttachedVolume.Encompasses(A))
			return true;
	}
	else if (VSize(A.Location - Location) < Radius)
	{
		return true;
	}

	return false;
}

//-----------------------------------------------------------------------------
// Reset - Goes back to the initial state
//-----------------------------------------------------------------------------

function Reset()
{
	super.Reset();

	ObjState = InitialObjState;
//	bObjActive = bObjInitiallyActive;
}

//-----------------------------------------------------------------------------
// Trigger - Allows some other Actor to complete this objective
//-----------------------------------------------------------------------------

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (/*!bObjActive*/ !bActive || ROTeamGame(Level.Game) == None || !ROTeamGame(Level.Game).IsInState('RoundInPlay'))
		return;

	if (ObjState == OBJ_Axis)
		ObjectiveCompleted(EventInstigator.PlayerReplicationInfo, ALLIES_TEAM_INDEX);
	else if (ObjState == OBJ_Allies)
		ObjectiveCompleted(EventInstigator.PlayerReplicationInfo, AXIS_TEAM_INDEX);
}

//-----------------------------------------------------------------------------
// ObjectiveCompleted - Called when this objective has been completed
//-----------------------------------------------------------------------------

function ObjectiveCompleted(PlayerReplicationInfo CompletePRI, int Team)
{
	if (Team == AXIS_TEAM_INDEX)
	{
		ObjState = OBJ_Axis;

		if (AxisEvent != '')
			TriggerEvent(AxisEvent, self, None);
	}
	else
	{
		ObjState = OBJ_Allies;

		if (AlliesEvent != '')
			TriggerEvent(AlliesEvent, self, None);
	}

    HandleCompletion(CompletePRI, Team);

	ROTeamGame(Level.Game).NotifyObjStateChanged();

	ROTeamGame(Level.Game).RemoveHelpRequestsForObj(ObjNum);

	// lets see if this tells the bots the objectives is done for
	UnrealMPGameInfo(Level.Game).FindNewObjectives(self);
}

//-----------------------------------------------------------------------------
// HandleCompletion - Anything special to do after the objective has been completed
// This function doesn't seem quite right, investigate - Ramm
//-----------------------------------------------------------------------------
function HandleCompletion(PlayerReplicationInfo CompletePRI, int Team)
{
	local Controller C;
	local ROPawn P;

	// Give players points for helping with the capture
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		P = ROPawn(C.Pawn);

		if (!C.bIsPlayer || P == None || C.PlayerReplicationInfo.Team == None || C.PlayerReplicationInfo.Team.TeamIndex != Team)
			continue;

		Level.Game.ScoreObjective(C.PlayerReplicationInfo, 10);
	}

	BroadcastLocalizedMessage(class'ROObjectiveMsg', Team + 2, None, None, self);
}

function bool isNeutral()
{
   return  (ObjState == OBJ_Neutral);
}

function bool isAxis()
{
   return   (ObjState == OBJ_Axis);
}

function bool isAllies()
{
   return (ObjState == OBJ_Allies);
}

// Called when bActive state changes
function NotifyStateChanged() {}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     InitialObjState=OBJ_Neutral
     bRequired=True
     objName="Unnamed"
     Radius=1024
     LabelCoords=(X1=-10000.000000,Y1=-10000.000000,X2=-10000.000000,Y2=-10000.000000)
     bReplicateObjective=True
     bStatic=False
     bAlwaysRelevant=True
     Texture=Texture'InterfaceArt_tex.OverheadMap.ROObjectiveIcon'
}
