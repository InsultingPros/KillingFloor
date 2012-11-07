//By: Alex (AND PROUD OF IT. THIS TOOK ALL DAY)  >:(
// ONLY TO LATER COMMENT IT ALL OUT IN FAVOR OF DOING THINGS FROM THE LOBBY CLASS :-/
class KFLobbyTitleLabel extends GUILabel;

//var() localized String   MapName;
//var localized string      SkillLevel[8];
//var String SkillString;

/*
function SetCaption( string NewCaption )
{
    Caption = GetMapName(Caption);
}


function String GetMapName(string TitleName)
{
 local class <KFScoreBoard> KFScoreBoardType;
 local KFScoreBoard A;

if (PlayerOwner().Level.Game!=None)
{
 //if (SkillString == "" && PlayerOwner().Level.Game.ScoreBoardType != "")
 if (PlayerOwner().Level.Game.ScoreBoardType != "")
 {
  KFScoreBoardType = class<KFScoreBoard>(DynamicLoadObject(PlayerOwner().Level.Game.ScoreBoardType, class'Class'));
  A = PlayerOwner().Spawn(KFScoreBoardType);
 // SkillString = A.SkillLevel[Clamp(KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).BaseDifficulty,0,7)];

 }

 if (KFGameReplicationInfo(PlayerOwner().GameReplicationInfo) != none)
 {

  //  return SkillText@KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).GameName$" on "$PlayerOwner().Level.Title;
  return A.SkillLevel[Clamp(KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).BaseDifficulty,0,7)]@KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).GameName$" on "$PlayerOwner().Level.Title;
  A.Destroy();
  }
   else
    return "Killing Floor";
}
}

*/

defaultproperties
{
}
