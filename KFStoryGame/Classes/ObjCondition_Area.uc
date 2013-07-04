/*
	--------------------------------------------------------------
	Condition_Area
	--------------------------------------------------------------

    A Condition which is marked complete when a player either
    (A) leaves a volume  or  (B)  enters a volume
    Can also be configured to check ZoneInfo regions.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Area extends KF_ObjectiveCondition
editinlinenew;

var	()	private edfindable   Volume		AreaVolume;
var ()                       string      AreaZoneName;
var     private              Volume      InitialVolume;
var ()	float		         Duration;
var ()  bool		         bRequiresWholeTeam;
var    ZoneInfo              AssociatedZone;


enum EAreaConditionType
{
   Method_StayInArea,
   Method_EnterArea,
};

var ()class<Actor>              ProximityTriggerType;

var () name                     ProximityTag;

var ()EAreaConditionType        CompletionMethod;

var                 float       LastInAreaTime;

var                 float       LastOutOfAreaTime;

var                 bool        bTimingOut;

var                 int         NumInVolume;

/* Array of pawns which are currently activating this Area condition */
var array<Pawn>                 PawnInstigators;

function PostBeginPlay()
{
    local ZoneInfo Zone;

    Super.PostBeginPlay();
    if(AreaVolume != none)
    {
        InitialVolume = AreaVolume;
    }
    else if(AreaZoneName != "")
    {
        foreach AllObjects(class 'ZoneInfo', Zone)
        {
             if(Zone.LocationName == AreaZoneName)
             {
                AssociatedZone = Zone;
                break;
             }
        }
    }
}

/* Some conditions may have multiple instigators */
function bool   FindInstigator(Pawn TestInstigator)
{
    local int i;

    for(i = 0 ; i < PawnInstigators.length ; i ++)
    {
        if(PawnInstigators[i] == TestInstigator)
        {
            return true;
        }
    }

    return false;
}


function AdjustToDifficulty(float Difficulty)
{
    Duration /= FMax(Difficulty-2,1);
}

function Reset()
{
    Super.Reset();
    bTimingOut = false;
    LastInAreaTime = 0.f;
    LastOutOfAreaTime = 0.f;
}

function ClearActorReferences()
{
    Super.ClearActorReferences();
    AreaVolume = none;
}

function ConditionActivated(pawn ActivatingPlayer)
{
     Super.ConditionActivated(ActivatingPlayer);
     LastOutOfAreaTime = GetObjOwner().Level.TimeSeconds;
     Duration = FMax(Duration,0.1f);

     if(InitialVolume != none &&
     !InitialVolume.bPendingDelete)
     {
        AreaVolume = InitialVolume ;
     }
}

function ConditionTick(Float DeltaTime)
{
    local controller AController;
    local Actor ProximityActor;

    NumInVolume = 0;
    PawnInstigators.length = 0;

	if(AreaVolume != none || AreaZoneName != "" )
	{
        if(AreaVolume != none)
        {
            if(ClassIsChildOf(ProximityTriggerType,class 'Controller'))
            {
                for ( AController=GetObjOwner().Level.ControllerList; AController!=None; AController=AController.NextController )
                {
                    if(AController.Pawn != none &&
                    AController.Pawn.Health > 0 &&
                    AreaVolume.Encompasses(AController.Pawn))
                    {
                        if(ClassIsChildOf(AController.class,ProximityTriggerType))
                        {
                            PawnInstigators[PawnInstigators.length] = AController.Pawn;
				            NumInVolume ++ ;
                        }
                    }
                }
            }
            else
            {
                foreach AreaVolume.TouchingActors(class 'Actor', ProximityActor)
                {
                    if(ProximityActor.IsA(ProximityTriggerType.name) &&
                    !ProximityActor.bPendingDelete && (ProximityTag == '' ||
                    ProximityActor.Tag == ProximityTag))
                    {
                        NumInVolume ++ ;
                    }
                }
            }
        }
        else if(AreaZoneName != "")
        {
            for ( AController=GetObjOwner().Level.ControllerList; AController!=None; AController=AController.NextController )
            {
                if(AController.Pawn != none &&
                AController.Pawn.Health > 0 &&
                (ClassIsChildOf(AController.Pawn.Class,ProximityTriggerType) ||
                ClassIsChildOf(AController.Class,ProximityTriggerType)) &&
                (ProximityTag == '' || AController.Pawn.Tag == ProximityTag))
                {
                    if(AController.Pawn.Region.Zone.LocationName == AreaZoneName)
                    {
                        PawnInstigators[PawnInstigators.length] = AController.Pawn;
                        NumInVolume ++ ;
                    }
                }
            }
        }


  		if(NumInVolume == 0 ||
		(bRequiresWholeTeam && NumInVolume < GetObjOwner().StoryGI.GetTotalActivePlayers()))
		{
		    bTimingOut = true;
		    LastOutofAreaTime = GetObjOwner().Level.TimeSeconds;
        }
		else
		{
		    bTimingOut = false;
		    LastInAreaTime = GetObjOwner().Level.TimeSeconds;
		}
    }


    Super.ConditionTick(DeltaTime);
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
	if(CompletionMethod == Method_StayInArea)
	{
		return 	FClamp(((GetObjOwner().Level.TimeSeconds - LastInAreaTime) / Duration),0.f,1.f);
    }
    else
    {
		return 	FClamp(((GetObjOwner().Level.TimeSeconds - LastOutOfAreaTime) / Duration),0.f,1.f);
    }
}


function        string      GetDataString()
{
     local string DataString;

/*   if( (CompletionMethod == Method_StayInArea && bTimingOut) ||
     (CompletionMethod == Method_EnterArea && !bTimingOut) )
     {
        DataString = FormatTime(FMax(Duration - (GetObjOwner().Level.TimeSeconds - LastInAreaTime),0.f))  ;
     }
*/

     if(bRequiresWholeTeam)
     {
        DataString@="["$NumInVolume$"/"$GetObjOwner().StoryGI.GetTotalActivePlayers()$"]" ;
     }

     return DataString ;
}

function        string      GetHUDHint()
{
     local string HintString;

     return Super.GetHUDHint();


     if( (CompletionMethod == Method_StayInArea && bTimingOut) ||
     (CompletionMethod == Method_EnterArea && !bTimingOut) )
     {
        HintString = Super.GetHUDHint();
     }

     return HintString ;
}

function        vector       GetLocation(optional out Actor LocActor)
{
    if(ConditionIsActive())
    {
        if(AreaVolume != none)
        {
            LocActor = AreaVolume;
            return LocActor.Location;
        }
        else
        if(AreaZoneName != "" && AssociatedZone != none)
        {
            LocActor = AssociatedZone;
            return LocActor.Location;
        }

        return Super.GetLocation(LocActor);
    }
}

defaultproperties
{
     ProximityTriggerType=Class'Engine.PlayerController'
     CompletionMethod=Method_EnterArea
     HUD_World=(bIgnoreWorldLocHidden=True)
}
