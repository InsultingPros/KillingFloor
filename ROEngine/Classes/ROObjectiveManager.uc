//=============================================================================
// ROObjectiveManager
//=============================================================================
// Helper class for ROTeamgame. Allows flexible objective completion scenarios.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROObjectiveManager extends actor
	placeable;

//=============================================================================
// Variables
//=============================================================================

var()	array<int>	AxisRequiredObjectives;		// A list of the Axis objective numbers that must be complete to trigger manager
var()	array<int>	AlliesRequiredObjectives;   // A list of the Allies objective numbers that must be complete to trigger manager

enum EActivationStyle
{
	AS_Activate,
	AS_Deactivate,
};

var()   EActivationStyle ActivationStyle;       // Whether we want this manager to turn objectives on or off

var()	array<int>	AxisObjectivesToModify;		// A list of the Axis objective numbers to modify when the manager is triggered
var()	array<int>	AlliesObjectivesToModify;   // A list of the Allies objective numbers to modify when the manager is triggered

function PostBeginPlay()
{
	//if (ROTeamGame(Level.Game) != None)
	//	ROTeamGame(Level.Game).ObjectiveManagers[ROTeamGame(Level.Game).ObjectiveManagers.Length] = self;
}

// Handles setting the active state of objectives we want to modify
function ObjectiveStateChanged()
{
    local      ROTeamGame                  ROGame;
  	local int i, j;
	local bool bReqsMet;

    ROGame =  ROTeamGame(Level.Game);

    for (i = 0; i < ArrayCount(ROGame.Objectives); i++)
    {
		bReqsMet = true;


		for (j = 0; j < AxisRequiredObjectives.Length; j++)
		{
            if (ROGame.Objectives[AxisRequiredObjectives[j]].ObjState != OBJ_Axis)
			{
				bReqsMet = false;
				break;
			}
		}


		for (j = 0; j < AlliesRequiredObjectives.Length; j++)
		{
			if (ROGame.Objectives[AlliesRequiredObjectives[j]].ObjState != OBJ_Allies)
			{
				bReqsMet = false;
				break;
			}
		}


		if (bReqsMet)
		{
			for (j = 0; j < AxisObjectivesToModify.Length; j++)
			{
				if( ActivationStyle ==  AS_Activate )
                    ROGame.Objectives[AxisObjectivesToModify[j]].bActive = true; // bObjActive
                else
				    ROGame.Objectives[AxisObjectivesToModify[j]].bActive = false;    // bObjActive
				ROGame.Objectives[AxisObjectivesToModify[j]].NotifyStateChanged();

				ROGame.FindNewObjectives(ROGame.Objectives[AxisObjectivesToModify[j]]);
			}

			for (j = 0; j < AlliesObjectivesToModify.Length; j++)
			{
				if( ActivationStyle ==  AS_Activate )
                    ROGame.Objectives[AlliesObjectivesToModify[j]].bActive = true; // bObjActive
                else
				    ROGame.Objectives[AlliesObjectivesToModify[j]].bActive = false;  // bObjActive
				ROGame.Objectives[AlliesObjectivesToModify[j]].NotifyStateChanged();

				ROGame.FindNewObjectives(ROGame.Objectives[AlliesObjectivesToModify[j]]);
			}
		}
    }
}

defaultproperties
{
     bHidden=True
}
