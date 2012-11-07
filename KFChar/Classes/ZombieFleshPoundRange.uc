// Zombie Monster for KF Invasion gametype
class ZombieFleshPoundRange extends ZombieFleshPound;

var float NextMinigunTime;
var byte MGFireCounter;
var vector TraceHitPos;
var Emitter mTracer,mMuzzleFlash;
var bool bHadAdjRot;

replication
{
	reliable if( Role==ROLE_Authority )
		TraceHitPos;
}

function RangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
		MGFireCounter = Rand(20);
		FireMGShot();
		GoToState('Minigunning');
	}
	else if( VSize(A.Location - Location)<=1200 && NextMinigunTime<Level.TimeSeconds && !bDecapitated )
	{
		if( FRand()<0.25 )
		{
			NextMinigunTime = Level.TimeSeconds+FRand()*10;
			Return;
		}
		NextMinigunTime = Level.TimeSeconds+10+FRand()*60;
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		Acceleration = vect(0,0,0);
		MGFireCounter = Rand(20);
		FireMGShot();
		GoToState('Minigunning');
	}
}
simulated function AnimEnd( int Channel )
{
	if( Channel==1 && Level.NetMode!=NM_DedicatedServer && bHadAdjRot )
	{
		bHadAdjRot = False;
		SetBoneDirection(LeftFArmBone, Rotation,, 0, 0);
	}
	if( Channel==1 && Level.NetMode!=NM_Client )
		bShotAnim = false;
	Super.AnimEnd(Channel);
}
simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='TurnLeft' )
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,10.f, 0.1, 1);
		Return 1;
	}
	Return Super.DoAnimAction(AnimName);
}
State Minigunning
{
Ignores StartCharging,PlayTakeHit;

	function RangedAttack(Actor A)
	{
		Controller.Target = A;
		Controller.Focus = A;
	}
	function EndState()
	{
		TraceHitPos = vect(0,0,0);
		GroundSpeed = Default.GroundSpeed;
	}
	function BeginState()
	{
		GroundSpeed = 90;
	}
	function AnimEnd( int Channel )
	{
		if( Channel!=1 )
			Return;
		MGFireCounter++;
		if( Controller.Enemy!=None && Controller.Target==Controller.Enemy )
		{
			if( Controller.LineOfSightTo(Controller.Enemy) )
			{
				Controller.Focus = Controller.Enemy;
				Controller.FocalPoint = Controller.Enemy.Location;
			}
			else
			{
				Controller.Focus = None;
				Acceleration = vect(0,0,0);
				if( !Controller.IsInState('WaitForAnim') )
					Controller.GoToState('WaitForAnim');
			}
			Controller.Target = Controller.Enemy;
		}
		else
		{
			Controller.Focus = Controller.Target;
			Acceleration = vect(0,0,0);
			if( !Controller.IsInState('WaitForAnim') )
				Controller.GoToState('WaitForAnim');
		}
		FireMGShot();
		bShotAnim = true;
		DoAnimAction('TurnLeft');
		bWaitForAnim = true;
		if( MGFireCounter>=70 || Controller.Target==None )
			GoToState('');
	}
Begin:
	While( True )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.15);
	}
}
function FireMGShot()
{
	local vector Start,End,HL,HN,Dir;
	local rotator R;
	local Actor A;

	Start = GetBoneCoords('CHR_L_Blade3').Origin;
	if( Controller.Focus!=None )
		R = rotator(Controller.Focus.Location-Start);
	else R = rotator(Controller.FocalPoint-Start);
	Dir = Normal(vector(R)+VRand()*0.04);
	End = Start+Dir*10000;
	// Have to turn of hit point collision so trace doesn't hit the Human Pawn's bullet whiz cylinder
	bBlockHitPointTraces = false;
	A = Trace(HL,HN,End,Start,True);
	bBlockHitPointTraces = true;
	if( A==None )
		Return;
	TraceHitPos = HL;
	if( Level.NetMode!=NM_DedicatedServer )
		AddTraceHitFX(HL);
	if( A!=Level )
		A.TakeDamage(1+Rand(3),Self,HL,Dir*100,Class'DamageType');
}
simulated function AddTraceHitFX( vector HitPos )
{
	local vector Start,SpawnVel,SpawnDir;
	local float hitDist;
	local KFHitEffect H;
	local rotator FireDir;

	if( Level.NetMode==NM_Client )
		DoAnimAction('TurnLeft');
	Start = GetBoneCoords('CHR_L_Blade3').Origin;
	if( mTracer==None )
		mTracer = Spawn(Class'NewTracer',,,Start);
	else mTracer.SetLocation(Start);
	FireDir = rotator(HitPos-Start);
	if( mMuzzleFlash==None )
		mMuzzleFlash = Spawn(Class'MuzzleFlash3rdMP',,,Start,FireDir);
	else
	{
		mMuzzleFlash.SetRotation(FireDir);
		mMuzzleFlash.SetLocation(Start);
	}
	mMuzzleFlash.Trigger(Self,Self);
	hitDist = VSize(HitPos - Start) - 50.f;
	SetBoneDirection(LeftFArmBone, FireDir,, 1.0, 1);
	bHadAdjRot = True;
	PlaySound(Sound'Bullpup_Fire');
	if( hitDist>10 )
	{
		SpawnDir = Normal(HitPos - Start);
		SpawnVel = SpawnDir * 10000.f;
		mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
		mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;
		mTracer.Emitters[0].LifetimeRange.Min = hitDist / 10000.f;
		mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;
		mTracer.SpawnParticle(1);
	}
	Instigator = Self;
	H = Spawn(Class'KFHitEffect',,,HitPos);
	if( H!=None )
		H.RemoteRole = ROLE_None;
}
function SpawnTwoShots();

simulated function PostNetReceive()
{
	if( TraceHitPos!=vect(0,0,0) )
	{
		AddTraceHitFX(TraceHitPos);
		TraceHitPos = vect(0,0,0);
	}
	else Super.PostNetReceive();
}
simulated function Destroyed()
{
	if( mTracer!=None )
		mTracer.Destroy();
	if( mMuzzleFlash!=None )
		mMuzzleFlash.Destroy();
	Super.Destroyed();
}
simulated function DeviceGoRed();
simulated function DeviceGoNormal();

defaultproperties
{
     ZombieFlag=1
     MeleeDamage=16
     damageForce=150000
     ScoringValue=12
     HealthMax=1600.000000
     Health=1600
     MenuName="Flesh Pound Chaingunner"
}
