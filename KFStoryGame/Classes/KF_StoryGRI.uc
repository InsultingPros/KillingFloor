/*
	--------------------------------------------------------------
	KF_StoryGRI
	--------------------------------------------------------------

	Custom GamereplicationInfo class for use in Story mode

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_StoryGRI extends KFGameReplicationinfo;


var			private  KF_StoryObjective				CurrentObjective;

var         private  Material                       VictorySplashMaterial;

var         private  Material                       DefeatSplashMaterial;

var         private  KF_HUDStyleManager             HUDStyleManager;

var         private  KF_StoryObjective              DebugTargetObj;

replication
{
	reliable if(Role == ROLE_Authority && bNetDirty)
		CurrentObjective,DebugTargetObj;

	reliable if( Role == ROLE_Authority && bNetInitial)
        HUDStyleManager,VictorySplashMaterial,DefeatSplashMaterial;
}

/* accessor for retrieving the current Objective set in the gameinfo */

simulated	function KF_StoryObjective		GetCurrentObjective()
{
	return CurrentObjective;
}

simulated	function KF_StoryObjective		GetDebugTargetObjective()
{
	return DebugTargetObj;
}

simulated	function KF_HUDStyleManager		GetHUDStyleManager()
{
	return HUDStyleManager;
}

simulated function Material    GetVictorySplashMaterial()
{
    return VictorySplashMaterial;
}

simulated function Material     GetDefeatSplashMaterial()
{
    return DefeatSplashMaterial;
}

function SetHUDStyleManager(KF_HUDStyleManager NewManager)
{
    HUDStyleManager = NewManager;
}

function SetDefeatMaterial(Material NewMat)
{
    DefeatSplashMaterial = NewMat;
}

function SetVictoryMaterial( Material NewMat)
{
    VictorySplashMaterial = NewMat;
}
function SetCurrentObjective(KF_StoryObjective NewObjective)
{
	CurrentObjective = NewObjective;
}
function SetDebugTargetObj(KF_StoryObjective NewDebugTarget)
{
    DebugTargetObj = NewDebugTarget;
}

defaultproperties
{
}
