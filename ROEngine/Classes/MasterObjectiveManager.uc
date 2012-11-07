// MasterObjectiveManager
//=============================================================================
// Helper class for ROTeamgame. Allows flexible objective completion scenarios.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2005 John "Ramm-Jaeger" Gibson
//=============================================================================

class MasterObjectiveManager extends actor
	hidecategories(Object,Movement,Collision,Lighting,LightColor,Karma,Force,Events,Display,Advanced,Sound)
	placeable;

//=============================================================================
// Variables
//=============================================================================

enum EActivationStyle
{
	AS_Activate,
	AS_Deactivate,
};

struct ObjectiveManager
{
	var()	array<int>	AxisRequiredObjectives;		// A list of the Axis objective numbers that must be complete to trigger manager
	var()	array<int>	AlliesRequiredObjectives;   // A list of the Allies objective numbers that must be complete to trigger manager

	var()   EActivationStyle ActivationStyle;       // Whether we want this manager to turn objectives on or off

	var()	array<int>	AxisObjectivesToModify;		// A list of the Axis objective numbers to modify when the manager is triggered
	var()	array<int>	AlliesObjectivesToModify;   // A list of the Allies objective numbers to modify when the manager is triggered
};

var()		array<ObjectiveManager>	ObjectiveManagers;

function PostBeginPlay()
{
	if (ROTeamGame(Level.Game) != None)
		ROTeamGame(Level.Game).ObjectiveManager = self;
}

function ObjectiveStateChanged()
{
    local int i,j,k;
    local ROTeamGame ROGame;
  	//local int i, j;
	local bool bReqsMet;

    ROGame =  ROTeamGame(Level.Game);


	for (i = 0; i < ObjectiveManagers.Length; i++)
	{
	     // ObjectiveManagers[i].ObjectiveStateChanged();

		// Handles setting the active state of objectives we want to modify



		    for (k = 0; k < ArrayCount(ROGame.Objectives); k++)
		    {
				bReqsMet = true;


				for (j = 0; j < ObjectiveManagers[i].AxisRequiredObjectives.Length; j++)
				{
		            if (ROGame.Objectives[ObjectiveManagers[i].AxisRequiredObjectives[j]].ObjState != OBJ_Axis)
					{
						bReqsMet = false;
						break;
					}
				}


				for (j = 0; j < ObjectiveManagers[i].AlliesRequiredObjectives.Length; j++)
				{
					if (ROGame.Objectives[ObjectiveManagers[i].AlliesRequiredObjectives[j]].ObjState != OBJ_Allies)
					{
						bReqsMet = false;
						break;
					}
				}


				if (bReqsMet)
				{
					for (j = 0; j < ObjectiveManagers[i].AxisObjectivesToModify.Length; j++)
					{
						if( ObjectiveManagers[i].ActivationStyle ==  AS_Activate )
		                    ROGame.Objectives[ObjectiveManagers[i].AxisObjectivesToModify[j]].bActive = true; // bObjActive
		                else
						    ROGame.Objectives[ObjectiveManagers[i].AxisObjectivesToModify[j]].bActive = false;    // bObjActive

						ROGame.FindNewObjectives(ROGame.Objectives[ObjectiveManagers[i].AxisObjectivesToModify[j]]);
						ROGame.Objectives[ObjectiveManagers[i].AxisObjectivesToModify[j]].NotifyStateChanged();
					}

					for (j = 0; j < ObjectiveManagers[i].AlliesObjectivesToModify.Length; j++)
					{
						if( ObjectiveManagers[i].ActivationStyle ==  AS_Activate )
		                    ROGame.Objectives[ObjectiveManagers[i].AlliesObjectivesToModify[j]].bActive = true; // bObjActive
		                else
						    ROGame.Objectives[ObjectiveManagers[i].AlliesObjectivesToModify[j]].bActive = false;  // bObjActive

						ROGame.FindNewObjectives(ROGame.Objectives[ObjectiveManagers[i].AlliesObjectivesToModify[j]]);
						ROGame.Objectives[ObjectiveManagers[i].AlliesObjectivesToModify[j]].NotifyStateChanged();
					}
				}
		    }


	}
}

defaultproperties
{
     bHidden=True
}
