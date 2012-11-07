class CrossbowArrow extends Projectile;

#exec OBJ LOAD FILE=KF_InventorySnd.uax

var xEmitter Trail;
var() class<DamageType> DamageTypeHeadShot;
var sound Arrow_hitwall[3];
var sound Arrow_rico[2];
var sound Arrow_hitarmor;
var sound Arrow_hitflesh;

var() float HeadShotDamageMult;

var Actor ImpactActor;
var Pawn IgnoreImpactPawn;

var()	string	AmbientSoundRef;
var		string	MeshRef;
var		string	Arrow_hitwallRef[3];
var		string	Arrow_ricoRef[2];
var		string	Arrow_hitarmorRef;
var		string	Arrow_hitfleshRef;

replication
{
	reliable if(Role == ROLE_Authority)
		bTriggered;
}

replication
{
	reliable if ( Role==ROLE_Authority && bNetInitial )
		ImpactActor;
}

static function PreloadAssets()
{
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	default.Arrow_hitwall[0] = sound(DynamicLoadObject(default.Arrow_hitwallRef[0], class'Sound', true));
	default.Arrow_hitwall[1] = sound(DynamicLoadObject(default.Arrow_hitwallRef[1], class'Sound', true));
	default.Arrow_hitwall[2] = sound(DynamicLoadObject(default.Arrow_hitwallRef[2], class'Sound', true));

	default.Arrow_rico[0] = sound(DynamicLoadObject(default.Arrow_ricoRef[0], class'Sound', true));
	default.Arrow_rico[1] = sound(DynamicLoadObject(default.Arrow_ricoRef[1], class'Sound', true));

	default.Arrow_hitarmor = sound(DynamicLoadObject(default.Arrow_hitarmorRef, class'Sound', true));
	default.Arrow_hitflesh = sound(DynamicLoadObject(default.Arrow_hitfleshRef, class'Sound', true));

	UpdateDefaultMesh(Mesh(DynamicLoadObject(default.MeshRef, class'Mesh', true)));
}

static function bool UnloadAssets()
{
	default.AmbientSound = none;
	default.Arrow_hitwall[0] = none;
	default.Arrow_hitwall[1] = none;
	default.Arrow_hitwall[2] = none;
	default.Arrow_rico[0] = none;
	default.Arrow_rico[1] = none;
	default.Arrow_hitarmor = none;
	default.Arrow_hitflesh = none;

	UpdateDefaultMesh(none);

	return true;
}

simulated function PostNetBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer && (Level.NetMode!=NM_Client || Physics==PHYS_Projectile) )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			Trail = Spawn(class'KFArrowTracer',self);
			Trail.Lifespan = Lifespan;
		}
	}
	else if( Level.NetMode==NM_Client )
	{
		if( ImpactActor!=None )
			SetBase(ImpactActor);
		GoToState('OnWall');
	}
}
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Speed * Vector(Rotation);
	if( PhysicsVolume.bWaterVolume )
		Velocity*=0.65;
}

simulated state OnWall
{
Ignores HitWall;

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		local Inventory inv;

		if( Pawn(Other)!=None && Pawn(Other).Inventory!=None )
		{
			for( inv=Pawn(Other).Inventory; inv!=None; inv=inv.Inventory )
			{
				if( Crossbow(Inv)!=None && Weapon(inv).AmmoAmount(0)<Weapon(inv).MaxAmmo(0) )
				{
					KFweapon(Inv).AddAmmo(1,0) ;
					PlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup', SLOT_Pain,2*TransientSoundVolume,,400);
					if( PlayerController(Instigator.Controller)!=none )
					{
                        PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'KFmod.ProjectilePickupMessage',0);
					}
					Destroy();
				}
			}
		}
	}
	simulated function Tick( float Delta )
	{
		if( Base==None )
		{
			if( Level.NetMode==NM_Client )
				bHidden = True;
			else Destroy();
		}
	}
	simulated function BeginState()
	{
		bCollideWorld = False;
		if( Level.NetMode!=NM_DedicatedServer )
			AmbientSound = None;
		if( Trail!=None )
			Trail.mRegen = False;
		SetCollisionSize(25,25);
	}
}

simulated function Explode(vector HitLocation, vector HitNormal);

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local vector X,End,HL,HN;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;
	local bool	bHitWhipAttachment;

	if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces || Other==IgnoreImpactPawn ||
        (IgnoreImpactPawn != none && Other.Base == IgnoreImpactPawn) )
		return;

	X =  Vector(Rotation);

 	if( ROBulletWhipAttachment(Other) != none )
	{

    	bHitWhipAttachment=true;

        if(!Other.Base.bDeleteMe)
        {
	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (65535 * X), HitPoints, HitLocation,, 1);

			if( Other == none || HitPoints.Length == 0 )
				return;

			HitPawn = KFPawn(Other);

            if (Role == ROLE_Authority)
            {
    	    	if ( HitPawn != none )
    	    	{
     				// Hit detection debugging
    				/*log("Bullet hit "$HitPawn.PlayerReplicationInfo.PlayerName);
    				HitPawn.HitStart = HitLocation;
    				HitPawn.HitEnd = HitLocation + (65535 * X);*/

                    if( !HitPawn.bDeleteMe )
                    	HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * X, MyDamageType,HitPoints);

        			Damage/=1.25;
        			Velocity*=0.85;

                    IgnoreImpactPawn = HitPawn;

            		if( Level.NetMode!=NM_Client )
            			PlayhitNoise(Pawn(Other)!=none && Pawn(Other).ShieldStrength>0);

                    // Hit detection debugging
    				/*if( Level.NetMode == NM_Standalone)
    					HitPawn.DrawBoneLocation();*/

    				 return;
    	    	}
    		}
		}
		else
		{
			return;
		}
	}

	if( Level.NetMode!=NM_Client )
		PlayhitNoise(Pawn(Other)!=none && Pawn(Other).ShieldStrength>0);

	if( Physics==PHYS_Projectile && Pawn(Other)!=None && Vehicle(Other)==None )
	{
		IgnoreImpactPawn = Pawn(Other);
		if( IgnoreImpactPawn.IsHeadShot(HitLocation, X, 1.0) )
			Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
		Damage/=1.25;
		Velocity*=0.85;
		Return;
	}
	else if( ExtendedZCollision(Other)!=None && Pawn(Other.Owner)!=None )
	{
		if( Other.Owner==IgnoreImpactPawn )
			Return;
		IgnoreImpactPawn = Pawn(Other.Owner);
		if ( IgnoreImpactPawn.IsHeadShot(HitLocation, X, 1.0))
			Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
		Damage/=1.25;
		Velocity*=0.85;
		Return;
	}
	if( Level.NetMode!=NM_DedicatedServer && SkeletalMesh(Other.Mesh)!=None && Other.DrawType==DT_Mesh && Pawn(Other)!=None )
	{ // Attach victim to the wall behind if it dies.
		End = Other.Location+X*600;
		if( Other.Trace(HL,HN,End,Other.Location,False)!=None )
			Spawn(Class'BodyAttacher',Other,,HitLocation).AttachEndPoint = HL-HN;
	}
	Stick(Other,HitLocation);
	if( Level.NetMode!=NM_Client )
	{
		if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
			Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
	}
}
function PlayhitNoise( bool bArmored )
{
	if( bArmored )
		PlaySound(Arrow_hitarmor);   // implies hit a target with shield/armor
	else PlaySound(Arrow_hitflesh);
}
simulated function HitWall( vector HitNormal, actor Wall )
{
	speed = VSize(Velocity);

	if ( Role==ROLE_Authority && Wall!=none )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController(InstigatorController);
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	PlaySound(Arrow_hitwall[Rand(3)],,2.5*TransientSoundVolume);
	if(Level.NetMode != NM_DedicatedServer)
	{
			Spawn(class'ROBulletHitEffect',,, Location, rotator(-HitNormal));
	}
	if( Instigator!=None && Level.NetMode!=NM_Client )
		MakeNoise(0.3);
	Stick(Wall, Location+HitNormal);
}
simulated function Landed(vector HitNormal)
{
	HitWall(HitNormal, None);
}
simulated function Stick(actor HitActor, vector HitLocation)
{
	local name NearestBone;
	local float dist;

	SetPhysics(PHYS_None);

	if (pawn(HitActor) != none)
	{
		NearestBone = GetClosestBone(HitLocation, HitLocation, dist , 'CHR_Spine2' , 15 );
		HitActor.AttachToBone(self,NearestBone);
	}
	else SetBase(HitActor);

	ImpactActor = HitActor;

	if (Base==None)
		Destroy();
	else GoToState('OnWall');
}
simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
	if( Volume.bWaterVolume && !PhysicsVolume.bWaterVolume )
	{
		if ( Trail != None )
			Trail.mRegen=False;
		Velocity*=0.65;
	}
}
simulated function Destroyed()
{
	if (Trail !=None)
		Trail.mRegen = False;
	Super.Destroyed();
}

defaultproperties
{
     DamageTypeHeadShot=Class'KFMod.DamTypeCrossbowHeadShot'
     HeadShotDamageMult=4.000000
     AmbientSoundRef="PatchSounds.ArrowZip"
     MeshRef="KFWeaponModels.XbowBolt"
     Arrow_hitwallRef(0)="KFWeaponSound.bullethitflesh2"
     Arrow_hitwallRef(1)="KFWeaponSound.bullethitflesh3"
     Arrow_hitwallRef(2)="KFWeaponSound.bullethitflesh4"
     Arrow_ricoRef(0)="KFWeaponSound.bullethitmetal"
     Arrow_ricoRef(1)="KFWeaponSound.bullethitmetal3"
     Arrow_hitarmorRef="KFWeaponSound.bullethitflesh4"
     Arrow_hitfleshRef="KFWeaponSound.bullethitflesh4"
     Speed=15000.000000
     MaxSpeed=20000.000000
     Damage=300.000000
     MomentumTransfer=150000.000000
     MyDamageType=Class'KFMod.DamTypeCrossbow'
     ExplosionDecal=Class'KFMod.ShotgunDecal'
     CullDistance=3000.000000
     bNetTemporary=False
     LifeSpan=10.000000
     DrawScale=15.000000
     AmbientGlow=30
     Style=STY_Alpha
     bUnlit=False
     bFullVolume=True
}
