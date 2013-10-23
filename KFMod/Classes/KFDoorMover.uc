// This is a special Door mover which can be "sealed" if in a closed state.
// By: Alex
// Fixed by .:..:
class KFDoorMover extends Mover;

#exec OBJ LOAD FILE="..\StaticMeshes\PatchStatics.usx"
#exec OBJ LOAD FILE=KF_EnvAmbientSnd2.uax


var bool bSealed;
var float WeldStrength;
var float MaxWeld;
var float Health;  // How much life does the door have when Unwelded?
var() bool bNoSeal;
var() bool bElevOuterDoorTop, bElevOuterDoorBottom;
var() bool bStartSealed;  // Just like it sounds.
var() float StartSealedWeldPrc; // Start welded percent.
var() bool bSmallArmsDamage; // If true, this door will take damage from non explosive weapons
//var () int DamageThreshold; // The amount of damage this door can take before it actually....takes damage :P
var() bool bKeyLocked; // Is the door locked to a specific key item?
var() edfindable NavigationPoint DoorPathNode;
var() bool bDisallowWeld; // no welding..
var() bool bBlockDamagingOfWeld; // No using other weapons to unweld

var KFUseTrigger MyTrigger;

var vector WeldIconLocation;

var() sound MetalBreakSound,WoodBreakSound;

var float LastZombieHitSoundTime;   // The last time we played a zombie hit sound for this door.
var sound ZombieHitSound;           // THe sound that will be used when a zombie hits this door
var() sound MetalZombieHitSound;    // The metal hit sound that will be used when a zombie hits this door

var() class<Emitter>    WoodDoorExplodeEffectClass;
var() class<Emitter>    MetalDoorExplodeEffectClass;

var () float ZombieDamageReductionFactor; // Multiply the base damage the door takes by this amount (less than one, or it will take MORE dmg)
var bool bZedHittingDoor; // when true, our welder is ALOT less effective at sealing the door shut. This will help
						   // resolve a noted issue where a small team is able to keep a door up against a hoard of zombies - indefinitely.

var float LastZombieDamageTime; // when was the last time we took damage from a zed? (used to resolve bZedHittingDoor in the timer func)
var float PathUdpTimer;
var int InitExtraCost;

var bool bDoorIsDead;

var () bool bZombiesIgnore;  // if true, zombies ignore this door, when its welded.
var bool bShouldBeOpen;

var byte DesiredOpenToKey;

// If true, this door does not block actors when in an open state.
var (Collision) const bool bNoBlockWhileOpen;

var private bool bInitialCollideActors, bInitialBlockActors;

replication
{
	reliable if( ROLE==ROLE_AUTHORITY )
		WeldStrength, MaxWeld, bDoorIsDead, WeldIconLocation;
}

function PostBeginPlay()
{
	local KFUseTrigger KFUTit;
	local NavigationPoint N;
	local int i;
	local float D;
	local vector HL,HN;

    bInitialCollideActors = bCollideActors;
    bInitialBlockActors = bBlockActors;

	if( DoorPathNode==None ) // Attempt to find one passing through this doorway.
	{
		For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			D = VSize(N.Location-Location);
			if( D<800 )
			{
				For( i=0; i<N.PathList.Length; i++ )
				{
					if( N.PathList[i].End==None )
						Continue; // Should happen.. but what the heck...
					if( TraceThisActor(HL,HN,N.PathList[i].End.Location,N.Location) )
						Continue; // This path isnt passing through this doorway..
					if( D<VSize(N.PathList[i].End.Location-Location) )
						DoorPathNode = N;
					else DoorPathNode = N.PathList[i].End; // Pick the node closer to door.
					Break;
				}
				if( DoorPathNode!=None )
					Break;
			}
		}
	}
	if( DoorPathNode!=None )
	{
		InitExtraCost = DoorPathNode.ExtraCost;
		PathUdpTimer = Level.TimeSeconds+FRand(); // Randomize this to improve preformace.
	}
	else Disable('Tick');

	foreach DynamicActors(class'KFUseTrigger', KFUTit)
	{
		if( KFUTit.Event==Tag )
		{
			if(MyTrigger!=none)
				Warn("Multiple triggers found!");
			MyTrigger = KFUTit;
			KFUTit.AddDoor(Self);
			MaxWeld = MyTrigger.MaxWeldStrength;
			Health = MaxWeld;
			WeldIconLocation = MyTrigger.Location;
		}
	}

	// Establish hit Sounds based on material
	if (SurfaceType == EST_Metal)
	{
        ZombieHitSound = MetalZombieHitSound;
	}

	if( bStartSealed )
	{
		bSealed = true;
		MyTrigger.WeldStrength = 0;
		MyTrigger.AddWeld(MaxWeld*(StartSealedWeldPrc/100.f),False,None);
	}
	super.PostBeginPlay();
}
simulated function PostNetBeginPlay()
{
	bDoorIsDead = false; // Make sure client spawns no FX for this here yet.
	bNetNotify = true;
	Super.PostNetBeginPlay();
}
function PlayZombieHitSound()
{
	LastZombieHitSoundTime = Level.TimeSeconds;
	PlaySound(ZombieHitSound,SLOT_None, 2.0, false,200,,true); //, SoundPitch / 64.0);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( bHidden || instigatedBy==None || MyTrigger==None )
		Return; // Or else we see a lot of warnings on log.
	if (bNoSeal)
	{
		if ( bDamageTriggered && (Damage >= DamageThreshold) )
		{
			if ( (AIController(instigatedBy.Controller) != None)
			 && (instigatedBy.Controller.Focus == self) )
				instigatedBy.Controller.StopFiring();
			Trigger(self, instigatedBy);
			if ( (AIController(instigatedBy.Controller) != None) && (instigatedBy.Controller.Target == self) )
				instigatedBy.Controller.StopFiring();

			if (bTriggerOnceOnly)
				bDamageTriggered = false;
		}
	}
	if (!instigatedBy.IsA('KFMonster') && damageType != class'DamTypeWelder' && damageType != class'DamTypeUnWeld')
	{
		if(!bSmallArmsDamage && damageType != class'DamTypeFrag' || Damage < DamageThreshold )
			return;
	}

	// Hack for damage reduction with zombies : Alex
	if ( instigatedBy.IsA('KFMonster') && instigatedBy!=none )
	{
		Damage = Max(5,Damage*ZombieDamageReductionFactor); // do at LEAST 5 damage per hit.
		LastZombieDamageTime = Level.TimeSeconds;
		bZedHittingDoor = true;
		// Only play the sound if the door is welded!!!. This prevents hearing
		// damage sounds for doors when sirens scream, bloats puke, etc that aren't welded
		if (bSealed && (Level.TimeSeconds - LastZombieHitSoundTime) >= 0.5)
			PlayZombieHitSound();
	}
	//Unsealed damage-dealing.
	if( !bSealed && damageType!=class'DamTypeWelder' )
	{
		Damage *= 0.5;
		Health -= Damage;

		if( Health<=0 )
			GoBang(instigatedBy,hitlocation,momentum,damageType);
	}

	if ( bClosed && damageType == class 'DamTypeWelder'  && !bDisallowWeld)
	{
		bSealed = true;
		MyTrigger.AddWeld(damage,bZedHittingDoor,instigatedBy);
	}
	else if(bSealed)
	{
		if( damageType==class'DamTypeUnWeld' )
  	MyTrigger.UnWeld(damage,bZedHittingDoor,instigatedBy);
  else if ( !bBlockDamagingOfWeld )
			MyTrigger.DamageWeld(damage,instigatedBy,hitlocation,momentum,damageType);
	}
}
function Bump( Actor Other )
{
	Super.Bump(Other);

	if( (bSealed || bClosed) && KFMonster(Other)!=None ) // Notify zombie to break this door.
	{
        KFMonsterController(KFMonster(Other).Controller).BreakUpDoor(Self, false);
	}
	else if( (bSealed || bClosed) && ExtendedZCollision(Other)!=None && Other.Base != none && KFMonster(Other.Base) != none )
	{
        KFMonsterController(KFMonster(Other.Base).Controller).BreakUpDoor(Self, false);
	}
	else if( bSealed && bStartSealed && Pawn(Other)!=None && KFInvasionBot(Pawn(Other).Controller)!=None )
	{
		KFInvasionBot(Pawn(Other).Controller).SealUpDoor(Self);
	}
}
function SetWeldStrength(float NewStrength)
{
	WeldStrength = NewStrength;
	if(WeldStrength>0)
		bSealed = true;
	else
	{
		bSealed = false;
		if (UV2Texture != none)
			UV2Texture = none;
	}
}

simulated function GoBang(pawn instigatedBy, vector hitlocation,Vector momentum, class<DamageType> damageType)
{
	if( Level.NetMode==NM_Client )
		return;

	SetCollision(false,false,false);

	bHidden = true;
	bDoorIsDead = true;
	NetUpdateTime = Level.TimeSeconds - 1;
	if( Level.NetMode==NM_DedicatedServer )
		Return;

	if (SurfaceType == EST_Metal)
	{
		if( (Level.TimeSeconds-LastRenderTime)<5 )
			Spawn(MetalDoorExplodeEffectClass,,, Location, rotator(vect(0,0,1)));
		PlaySound(MetalBreakSound, SLOT_None, 2.0, false, 5000,,false);
	}
	else
	{
		if( (Level.TimeSeconds-LastRenderTime)<5 )
			Spawn(WoodDoorExplodeEffectClass,,, Location, rotator(vect(0,0,1)));
		PlaySound(WoodBreakSound, SLOT_None, 2.0, false, 5000,,false);
	}
}

simulated event PostNetReceive()
{
	if( bDoorIsDead )
	{
		if (SurfaceType == EST_Metal)
		{
			if( (Level.TimeSeconds-LastRenderTime)<5 )
				Spawn(MetalDoorExplodeEffectClass,,, Location, rotator(vect(0,0,1)));
			PlaySound(MetalBreakSound, SLOT_None, 2.0, false, 5000,,false);
		}
    		else
		{
			if( (Level.TimeSeconds-LastRenderTime)<5 )
				Spawn(WoodDoorExplodeEffectClass,,, Location, rotator(vect(0,0,1)));
			PlaySound(WoodBreakSound, SLOT_None, 2.0, false, 5000,,false);
		}
		bDoorIsDead = false;
	}
}
simulated function Timer()
{
	Super.Timer();
	if(Level.TimeSeconds - LastZombieDamageTime > 1.0) // reset our bool if it's not taking anymore dmg after one second.
		bZedHittingDoor = false;
}
function Tick( float Delta )
{
	if( DoorPathNode!=None && PathUdpTimer<Level.TimeSeconds )
	{
		PathUdpTimer = Level.TimeSeconds+0.5;
		DoorPathNode.ExtraCost = InitExtraCost;
		if( bSealed )
		{
			if(MyTrigger != none)
				DoorPathNode.ExtraCost+=500+MyTrigger.WeldStrength*6;
		}
	}
}

function RespawnDoor()
{
	if( bDoorIsDead )
	{
		bHidden = false;
		SetCollision(true, true, true);
		bDoorIsDead = false;
		Reset();
		if( bShouldBeOpen )
		{
			if( KeyNum!=(NumKeys-1) )
				InterpolateTo(NumKeys-1,0.001);
		}
		else if( KeyNum!=0 )
			InterpolateTo(0,0.001);
		if( bStartSealed )
		{
			bSealed = true;
			MyTrigger.WeldStrength = 0;
			MyTrigger.AddWeld(MaxWeld*(StartSealedWeldPrc/100.f),False,None);
		}
	}
	Health = MaxWeld;
}

function MakeGroupStop()
{
	MakeGroupReturn();
}
function DoOpen()
{
	if(bNoBlockWhileOpen)
    {
    	// Remove collision from doors when we open them
        SetCollision(false,bInitialBlockActors);
    }

	if( bSealed || bHidden )
	{
		bShouldBeOpen = True;
		Return;
	}
	Super.DoOpen();
}
function DoClose()
{
	if(bNoBlockWhileOpen)
    {
    	// Add collision to doors when we close them
        SetCollision(bInitialCollideActors,bInitialBlockActors);
    }

	if( bSealed || bHidden )
	{
		bShouldBeOpen = False;
		Return;
	}
	Super.DoClose();
}
function DoOpenToKey( byte KeyNums )
{
	if( bSealed || bHidden )
	{
		bShouldBeOpen = True;
		Return;
	}
	bOpening = true;
	bDelaying = false;
	InterpolateTo( KeyNums, MoveTime );
	MakeNoise(1.0);
	PlaySound( OpeningSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, Self, Instigator);
	if ( Follower != None )
		Follower.DoOpen();

}
function DoCloseToFirst()
{
	if( bSealed || bHidden )
	{
		bShouldBeOpen = False;
		Return;
	}
	bOpening = false;
	bDelaying = false;
	InterpolateTo( 0, MoveTime );
	MakeNoise(1.0);
	PlaySound( ClosingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	UntriggerEvent(Event, self, Instigator);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(ClosingEvent,Self,Instigator);
	if ( Follower != None )
		Follower.DoClose();
}
function FinishedOpening()
{
	if( bSealed || bHidden )
		FinishNotify();
	else Super.FinishedOpening();
}
function FinishedClosing()
{
	if( bSealed || bHidden )
		FinishNotify();
	else Super.FinishedClosing();
}
function OpenDoorToKey( pawn EventInstigator, byte KeyNums )
{
	Trigger(self,EventInstigator);
}

state() TriggerToggle
{
	function OpenDoorToKey( pawn EventInstigator, byte KeyNums )
	{
		SavedTrigger = None;
		Instigator = EventInstigator;
		DesiredOpenToKey = KeyNums;
		if( KeyNum==0 )
			GotoState(,'OpenToKey');
		else GotoState(,'CloseToFirst');
	}
OpenToKey:
	bClosed = false;
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpenToKey(DesiredOpenToKey);
	FinishInterpolation();
	FinishedOpening();
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	Stop;
CloseToFirst:
	DoCloseToFirst();
	FinishInterpolation();
	FinishedClosing();
	SetResetStatus( false );
}

defaultproperties
{
     StartSealedWeldPrc=50.000000
     MetalBreakSound=SoundGroup'KF_EnvAmbientSnd2.DoorBreak.Door_Break_Metal'
     WoodBreakSound=SoundGroup'KF_EnvAmbientSnd2.DoorBreak.Door_Break_Wood'
     ZombieHitSound=SoundGroup'KF_EnemyGlobalSnd.Zomb_HitDoor_Wood'
     MetalZombieHitSound=SoundGroup'KF_EnemyGlobalSnd.Zomb_HitDoor_Metal'
     WoodDoorExplodeEffectClass=Class'KFMod.KFDoorExplodeWood'
     MetalDoorExplodeEffectClass=Class'KFMod.KFDoorExplodeMetal'
     ZombieDamageReductionFactor=0.850000
     MoverEncroachType=ME_IgnoreWhenEncroach
     StayOpenTime=5.000000
     DamageThreshold=50.000000
     InitialState="TriggerToggle"
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBlockKarma=True
     bPathColliding=False
}
