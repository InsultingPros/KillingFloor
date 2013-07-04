//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ObjCondition_WaveCounter extends ObjCondition_Counter
hidecategories(ObjCondition_Counter);

var      KF_StoryWaveDesigner   WaveDesigner;

var      int                    LastWaveIdx;

/* Tag of the WaveDesigner tied to this wave counter */
var()    name                   DesignerTag;

var()    bool                   bUseCurrentWave;

var()    int                    AssociatedWaveIndex;

var()    int                    AssociatedCycleIndex;

var()    bool                   bSumOfAllCycles;

var      int                    NumStragglers;

function ConditionActivated(pawn ActivatingPlayer)
{
    NumCounted = 0;
    Super.ConditionActivated(ActivatingPlayer);
    foreach GetObjOwner().AllActors(class 'KF_StoryWaveDesigner' , WaveDesigner,DesignerTag)
    {
        break;
    }
}

function ConditionDeActivated()
{
    super.ConditionDeActivated();
    // let's actually let the objective control this stuff manually ...
//  WaveDesigner.Waves[GetAssociatedWaveIndex()].WaveController.AbortWave();
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
    if(WaveDesigner == none)
    {
//        log("WARNING - no Wave Designer associated with : "@name,'Story_Debug');
        return 0.f;
    }

    if(WaveDesigner.Waves[GetAssociatedWaveIndex()].WaveController.bActive)
    {
        if(bSumOfAllCycles)
        {
            NumToCount      =  WaveDesigner.Waves[GetAssociatedWaveIndex()].WaveController.GetMaxMonsters();
        }
        else
        {
            NumToCount      =  WaveDesigner.Waves[GetAssociatedWaveIndex()].WaveController.GetCycleMaxZEDs(AssociatedCycleIndex)   ;
        }
    }
    else
    {
        NumToCount = WaveDesigner.Waves[GetAssociatedWaveIndex()].WaveController.NumStragglers;

        NumCounted = NumToCount - GetObjOwner().StoryGI.NumMonsters;
    }

    /* NO ZEDS .  Complete automatically */
    if(NumToCount <= 0)
    {
        return 1.f;
    }

    return Super.GetCompletionPct();
}

function    int  GetAssociatedWaveIndex()
{
    local int WaveIdx;

    if(bUseCurrentWave)
    {
        WaveIdx = WaveDesigner.CurrentWaveIdx ;
    }
    else
    {
        WaveIdx = AssociatedWaveIndex;
    }

    return WaveIdx;
}

/* We need to ensure that the counter is reset between waves */
function ConditionTick(float DeltaTime)
{
    local int NewWaveIdx;

    Super.ConditionTick(DeltaTime);
    if(WaveDesigner != none)
    {
        NewWaveIdx = GetAssociatedWaveIndex();

        if(NewWaveIdx != LastWaveIdx)
        {
           OnWaveChange();
        }

        LastWaveIdx = NewWaveIdx;
    }
}

function OnWaveChange()
{
     NumCounted = 0;
}

function Trigger( actor Other, pawn EventInstigator)
{
    Super.Trigger(Other,EventInstigator);
//  log("You have killed : "@NumCounted@"ZEDS out of : "@NumToCount,'Story_Debug');
}

/* Difficulty scaling for enemies is handled in the Wave Controller, so don't do it twice. */
function float GetTotalDifficultyModifier()
{
    return 1.f;
}

defaultproperties
{
     bUseCurrentWave=True
     bSumOfAllCycles=True
}
