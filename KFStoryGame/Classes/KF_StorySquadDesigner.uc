/*
	--------------------------------------------------------------
	KF_StorySquadDesigner
	--------------------------------------------------------------

	This actor provides level designers with a method of settings up
	pre-defined squads of Monsters for story missions.  Squads can be
    referenced in either KF_StoryZombeVolumes or KF_StoryWaveDesigners.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StorySquadDesigner extends Info
dependson(KFStoryGameInfo)
hidecategories(Collision,Force,Karma,Lighting,LightColor,Sound,Events,Movement)
placeable;


var()  array<KFStoryGameInfo.SZEDSquadType>   Squads;
var  bool                                   bUseDefaultSquads;


/* In case we want to just use whatever is in the KF Gametype instead of having to set up custom monster squads */
function FillSquadsFromGameType()
{
    local int i,idx;
    local KFGameType KFGI;
    local string SquadString;
    local array<string> ZEDTypes;
    local string NewZEDType;
    local int SplitSize;
    local string LeftHalf;
    local int Squadidx;
    local bool bExistsAlready;

    KFGI = KFGameType(Level.Game);
    if(KFGI == none)
    {
       return;
    }

    SplitSize = 2;

    for(i = 0 ; i < KFGI.MonsterSquad.length ; i ++)
    {
        Squads.length = Squads.length + 1;
        Squads[Squads.length-1].Squad_Name = KFGI.MonsterSquad[i] ;
        SquadString = Squads[Squads.length-1].Squad_Name ;

        while(Len(SquadString) >= SplitSize)
        {
            NewZEDType =  Left(SquadString,SplitSize);
            ZEDTypes[ZEDTypes.length] = NewZEDType;
            Divide(SquadString,NewZEDType,LeftHalf,SquadString);
        }

        for(idx = 0 ; idx < ZEDTypes.length ; idx ++)
        {
            bExistsAlready = false;
            for(Squadidx = 0 ; SquadIdx < Squads[Squads.length-1].Squad_ZEDS.length ; SquadIdx ++)
            {
                if(string(Squads[Squads.length-1].Squad_ZEDs[SquadIdx].ZEDClass) == ZEDTypes[idx])
                {
                    bExistsAlready = true;
                    break;
                }
            }

            if(bExistsAlready)
            {
                continue;
            }
            else
            {
                Squads[Squads.length-1].Squad_ZEDs.length = Squads[Squads.length-1].Squad_ZEDs.length + 1;
                Squads[Squads.length-1].Squad_ZEDs[Squads[Squads.length-1].Squad_ZEDs.length -1].ZEDClass = GetAssociatedZEDClass(Right(ZEDTypes[idx],1)) ;
                Squads[Squads.length-1].Squad_ZEDs[Squads[Squads.length-1].Squad_ZEDs.length -1].NumToSpawn = int(Left(ZEDTypes[idx],1)) ;
            }
        }

        ZEDTypes.length = 0;
    }
}


/* Returns the class of the ZED associated with the supplied letter ...

a result of the delightfully overblown Monster Squad system from UT2k4s invasion gametype
where a Monster Class is a letter! and a Squad is a bunch of letters! And a Wave is a bunch of
bits that represent a bunch of binary which represents a bunch of letters which represent a bunch of Monsters! HERPdeDERPaHURRRRDURRRR !

*/
function  class<KFMonster> GetAssociatedZEDClass( string Letter)
{
    local KFGameType KFGI;
    local int i;
    local class<KFMonster> ZEDClassType;
    local string MonsterID;

    KFGI = KFGameType(Level.Game);
    if(KFGI == none)
    {
       return none;
    }

    for(i = 0 ; i < KFGI.MonsterCollection.default.StandardMonsterClasses.length ; i ++)
    {
        MonsterID = KFGI.MonsterCollection.default.StandardMonsterClasses[i].MID ;
        if(MonsterID  == Letter)
        {
            ZEDClassType = class<KFMonster>(DynamicLoadObject(KFGI.MonsterCollection.default.StandardMonsterClasses[i].MClassName, class'Class')) ;
         //   log(" The Monster class associated with the letter : "@Letter@"is : "@ZEDClassType.default.menuname,'Story_Debug');
            return ZEDClassType;
        }
    }
}

defaultproperties
{
     Texture=Texture'KFStoryGame_Tex.Editor.KF_StorySquads_Ico'
     DrawScale=0.500000
}
