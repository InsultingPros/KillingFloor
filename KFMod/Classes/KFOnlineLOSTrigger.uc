class KFOnlineLOSTrigger extends LineOfSightTrigger;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( bEnabled && Level.NetMode!=NM_StandAlone )
		SetTimer(0.1+FRand()*0.1,True);
}
function Timer()
{
	local Actor A;
	local Controller C;
	local vector Start,Check;
	local rotator Dir;

	if( SeenActor==None )
		A = Self;
	else A = SeenActor;
	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && PlayerController(C)!=None && C.Pawn!=None )
		{
			Start = PlayerController(C).CalcViewLocation;
			Dir = PlayerController(C).CalcViewRotation;
			Check = A.Location-Start;
			if( VSize(Check)<MaxViewDist && (vector(Dir) Dot Normal(Check))>=RequiredViewDir && FastTrace(A.Location,Start) )
			{
				TriggerEvent(Event,Self,C.Pawn);
            		bTriggered = true;
				SetTimer(0,False);
				Return;
			}
		}
	}
}
function Trigger( actor Other, Pawn EventInstigator )
{
	bEnabled = true;
	if( Level.NetMode!=NM_StandAlone )
		SetTimer(0.1+FRand()*0.1,True);
}

defaultproperties
{
}
