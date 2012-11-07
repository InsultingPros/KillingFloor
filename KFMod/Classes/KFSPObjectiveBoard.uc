// This will be used by the story gametype.
// you can toggle the menu on and off and it will display your pending objectives.

class KFSPObjectiveBoard extends KFScoreBoard;

var localized string TitleString,NoObjString;
var KFSGameReplicationInfo SPRep;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SPRep = KFSGameReplicationInfo(Level.GRI);
}
simulated event UpdateScoreBoard(Canvas Canvas)
{
	if( Level.NetMode!=NM_StandAlone )
		Super.UpdateScoreBoard(Canvas);
	RenderObjectivedBoard(Canvas);
}
simulated event RenderObjectivedBoard(Canvas Canvas)
{
	local float XL,YL,Dummy;
	local string S;

	Canvas.Font = GetSmallerFontFor(Canvas,4);
	Canvas.TextSize(TitleString, XL, YL);
	Canvas.SetPos(Canvas.ClipX-XL-5,5);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.DrawText(TitleString,true);

	if( SPRep!=None && SPRep.KFPLevel!=None )
	{
		if( SPRep.CurrentObjectiveNum>=SPRep.KFPLevel.MissionObjectives.Length )
			S = NoObjString;
		else S = SPRep.KFPLevel.MissionObjectives[SPRep.CurrentObjectiveNum];
		Canvas.Font = GetSmallerFontFor(Canvas,3);
		Canvas.TextSize(S, XL, Dummy);
		Canvas.SetPos(Canvas.ClipX-XL-5,YL+7);
		Canvas.DrawText(S,true);
	}
}
simulated function SetGRI(GameReplicationInfo GRI)
{
	SPRep = KFSGameReplicationInfo(GRI);
}

defaultproperties
{
     titlestring="Current Objective:"
     NoObjString="No Objectives"
     HudClass=Class'KFMod.HUDKillingFloorSP'
}
