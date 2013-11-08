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

var	()	private edfindable   Volume		 AreaVolume;

var     const                Name        AreaVolumeName,InitialAreaVolumeName;

var ()                       string      AreaZoneName;

var     private              Volume      InitialVolume;

var ()	float		         Duration;

var ()  bool		         bRequiresWholeTeam;

var  private  ZoneInfo        AssociatedZone;    // Zones are NoDelete so having a reference in here should be O.K


enum EAreaConditionType
{
   Method_LeaveArea,
   Method_EnterArea,
};

var ()class<Actor>              ProximityTriggerType;

var () name                     ProximityTag;

var ()EAreaConditionType        CompletionMethod;

var ()              bool        bKeepProgress;

var                 float       LastInAreaTime;

var                 float       TimeInArea;

var                 float       TimeOutOfArea;

var                 float       LastOutOfAreaTime;

var                 bool        bTimingOut;

var                 int         NumInVolume;

var    private     array<name>  PawnInstigatorNames;

function PostBeginPlay(KF_StoryObjective MyOwner)
{
    local ZoneInfo Zone;

    Super.PostBeginPlay(MyOwner);

    if(AreaVolume != none)
    {
        SetTargetActor(InitialAreaVolumeName,AreaVolume);
        SetTargetActor(AreaVolumeName,AreaVolume);
        AreaVolume = none;
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

function array<Pawn> GetInstigatorList()
{
    local array<Pawn> PawnInstigators;
    local int i;

    for(i = 0 ; i < PawnInstigatorNames.length ; i ++)
    {
        PawnInstigators[PawnInstigators.length] = Pawn(GetTargetActor(PawnInstigatorNames[i])) ;
    }

    return PawnInstigators;
}

function AdjustToDifficulty(float Difficulty)
{
    Duration /= FMax(Difficulty-2,1);
}

function Reset()
{
    Super.Reset();

    bTimingOut = false;
    TimeInArea = 0.f;
    TimeOutOfArea = 0.f;
}

function ConditionActivated(pawn ActivatingPlayer)
{
    Super.ConditionActivated(ActivatingPlayer);

    Duration = FMax(Duration,0.1f);

    if(GetTargetActor(InitialAreaVolumeName) != none)
    {
        SetTargetActor(AreaVolumeName,GetTargetActor(InitialAreaVolumeName));
    }
}

function ConditionTick(Float DeltaTime)
{
    local controller AController;
    local Actor ProximityActor;
    local Volume MyAreaVolume;
    local int i;

    NumInVolume = 0;

    for(i = 0 ; i < PawnInstigatorNames.length ; i ++)
    {
        ReleaseTargetActor(PawnInstigatorNames[i]);
    }

    PawnInstigatorNames.length = 0;


    MyAreaVolume = Volume(GetTargetActor(AreaVolumeName));
	if(MyAreaVolume != none || AreaZoneName != "" )
	{
        if(MyAreaVolume != none)
        {
            if(ClassIsChildOf(ProximityTriggerType,class 'Controller'))
            {
                for ( AController=GetObjOwner().Level.ControllerList; AController!=None; AController=AController.NextController )
                {
                    if(AController.Pawn != none &&
                    AController.Pawn.Health > 0 &&
                    MyAreaVolume.Encompasses(AController.Pawn))
                    {
                        if(ClassIsChildOf(AController.class,ProximityTriggerType))
                        {
                            PawnInstigatorNames[PawnInstigatorNames.length] = AController.Pawn.name;
                            SetTargetActor(AController.Pawn.name,AController.Pawn);
				            NumInVolume ++ ;
                        }
                    }
                }
            }
            else
            {
                foreach MyAreaVolume.TouchingActors(class 'Actor', ProximityActor)
                {
                    if(ProximityActor.IsA(ProximityTriggerType.name) &&
                    !ProximityActor.bPendingDelete && (ProximityTag == '' ||
                    ProximityActor.Tag == ProximityTag))
                    {
                        if(ProximityActor.Instigator != none)
                        {
                            PawnInstigatorNames[PawnInstigatorNames.length] = ProximityActor.Instigator.name;
                            SetTargetActor(ProximityActor.Instigator.name,ProximityActor.Instigator);
                        }

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
                        PawnInstigatorNames[PawnInstigatorNames.length] = AController.Pawn.name;
                        SetTargetActor(AController.Pawn.name,AController.Pawn);
                        NumInVolume ++ ;
                    }
                }
            }
        }

  		if(NumInVolume == 0 ||
		(bRequiresWholeTeam && NumInVolume < GetObjOwner().StoryGI.GetTotalActivePlayers()))
		{
		    bTimingOut = true;

            if(bKeepProgress)
            {
                TimeInArea = FMax( TimeInArea - DeltaTime, 0 );
            }
            else
            {
                TimeInArea = 0.f;
            }

            TimeOutOfArea = FMin( TimeOutOfArea + DeltaTime, Duration );
        }
		else
		{
		    bTimingOut = false;

            TimeInArea = FMin( TimeInArea + DeltaTime, Duration );

            if(bKeepProgress)
            {
                TimeOutOfArea = FMax( TimeOutOfArea - DeltaTime, 0 );
            }
            else
            {
                TimeOutOfArea = 0.f;
            }
		}
    }

    Super.ConditionTick(DeltaTime);
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
	if(CompletionMethod == Method_LeaveArea)
	{
		return 	FClamp(TimeOutOfArea / Duration,0.f,1.f);
    }
    else
    {
		return 	FClamp(TimeInArea / Duration,0.f,1.f);
    }
}


function        string      GetDataString()
{
    local string DataString;
    local int NumActivePlayers;

    if(bRequiresWholeTeam )
    {
        NumActivePlayers = GetObjOwner().StoryGI.GetTotalActivePlayers() ;
        if(NumActivePlayers > 1)
        {
            DataString@="["$NumInVolume$"/"$NumActivePlayers$"]" ;
        }
    }

    return DataString ;
}

function        string      GetHUDHint()
{
     local string HintString;

     return Super.GetHUDHint();


     if( (CompletionMethod == Method_LeaveArea && bTimingOut) ||
     (CompletionMethod == Method_EnterArea && !bTimingOut) )
     {
        HintString = Super.GetHUDHint();
     }

     return HintString ;
}

function        vector       GetLocation(optional out Actor LocActor)
{
    local Actor WorldLocActor;
    local Vector WorldLocation;
    local Volume MyAreaVolume;

    if(ConditionIsActive())
    {
        MyAreaVolume = Volume(GetTargetActor(AreaVolumeName));

        WorldLocation = Super.GetLocation(WorldLocActor);
        if(WorldLocActor != none)
        {
            LocActor = WorldLocActor;
            return WorldLocation;
        }

        if(MyAreaVolume != none)
        {
            LocActor = MyAreaVolume;
            return LocActor.Location;
        }
        else
        if(AreaZoneName != "" && AssociatedZone != none)
        {
            LocActor = AssociatedZone;
            return LocActor.Location;
        }
    }
}

defaultproperties
{
     AreaVolumeName="AreaVolume"
     InitialAreaVolumeName="InitialAreaVolume"
     ProximityTriggerType=Class'Engine.PlayerController'
     CompletionMethod=Method_EnterArea
     HUD_World=(bIgnoreWorldLocHidden=True)
}
