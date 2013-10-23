//=============================================================================
// SealSquealProjectile
//=============================================================================
// Projectile class for the seal squeal harpoon bomb launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class SealSquealProjectile extends ROBallisticProjectile;

#exec OBJ LOAD FILE=WeaponSounds.uax
#exec OBJ LOAD FILE=ProjectileSounds.uax

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var() vector RotMag;            // how far to rot view
var() vector RotRate;           // how fast to rot view
var() float  RotTime;           // how much time to rot the instigator's view
var() vector OffsetMag;         // max view offset vertically
var() vector OffsetRate;        // how fast to offset view vertically
var() float  OffsetTime;        // how much time to offset view

var xEmitter Trail;
var vector Dir;

var()   sound               ExplosionSound;     // The sound of the rocket exploding

var     bool                bDisintegrated;     // This nade has been disintegrated by a siren scream.
var()   sound               DisintegrateSound;  // The sound of this projectile disintegrating
var     bool                bStuck;             // This rocket has stuck in something
var     class<DamageType>	ImpactDamageType;   // Damagetype of this rocket hitting something, but not exploding
var     int                 ImpactDamage;       // How much damage to do if this rocket impacts something without exploding

var         bool        bHasExploded;

var		string	StaticMeshRef;
var		string	ExplosionSoundRef;
var		string	DisintegrateSoundRef;

var     class<Emitter>      SmokeTrailEmitterClass;// Emitter class for the smoke trail/fuze sparks
var     Emitter             SmokeTrail;
var     class<Emitter>      ExplosionEmitterClass;// Emitter class for the explosion

var     sound   ImpactPawnSound;	// Sound made when projectile hits a pawn

var     float   ExplodeTimer;       // How long this bomb will wait to explode
var()	string	AmbientSoundRef;
var		string	ImpactSoundRef;
var		string	ImpactPawnSoundRef;
var     bool    bAttachedToHead;    // True if this projectile is stuck in a pawn's head

replication
{
	reliable if(Role == ROLE_Authority)
		bStuck;
}

static function PreloadAssets()
{
    default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
	default.DisintegrateSound = sound(DynamicLoadObject(default.DisintegrateSoundRef, class'Sound', true));
	default.ImpactSound = sound(DynamicLoadObject(default.ImpactSoundRef, class'Sound', true));
	default.ImpactPawnSound = sound(DynamicLoadObject(default.ImpactPawnSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.DisintegrateSound = none;
	default.ImpactSound = none;
	default.ImpactPawnSound = none;
	default.AmbientSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostNetReceive()
{
    if( bHidden && !bDisintegrated )
    {
        Disintegrate(Location, vect(0,0,1));
    }
}

function Timer()
{
    if( !bHidden )
    {
        Explode(Location, vect(0,0,1));
    }
    else
    {
        Destroy();
    }
}

function ShakeView()
{
    local Controller C;
    local PlayerController PC;
    local float Dist, Scale;

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        PC = PlayerController(C);
        if ( PC != None && PC.ViewTarget != None )
        {
            Dist = VSize(Location - PC.ViewTarget.Location);
            if ( Dist < DamageRadius * 2.0)
            {
                if (Dist < DamageRadius)
                    Scale = 1.0;
                else
                    Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
            }
        }
    }
}

simulated function HitWall(vector HitNormal, actor Wall)
{
    if( Instigator != none )
    {
        OrigLoc = Instigator.Location;
    }

	if(Level.NetMode != NM_DedicatedServer)
	{
			Spawn(class'ROBulletHitEffect',,, Location, rotator(-HitNormal));
	}

    Stick(Wall, Location);
}

// Make this blow up when the pawn its attached to dies
function HandleBasePawnDestroyed()
{
    if( !bHasExploded )
    {
        Explode(Location, vect(0,0,1));
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController  LocalPlayer;
    local KFMonster KFM;

    // Don't explode twice
    if(bHasExploded)
    {
        return;
    }

    bHasExploded = True;

    PlaySound(ExplosionSound,,2.0);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitterClass,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

	KFM = KFMonster(Base);

    if( KFM != none && Role == ROLE_Authority )
    {
        KFM.NumHarpoonsAttached--;

        if( KFM.NumHarpoonsAttached <= 0 )
        {
            KFM.bHarpoonStunned = false;
        }
    }

    BlowUp(HitLocation);
    Destroy();

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius) )
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
        if ( (PlayerController(C) != None) && (C != LocalPlayer)
            && (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius) )
            C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
}

// Make the projectile distintegrate, instead of explode
simulated function Disintegrate(vector HitLocation, vector HitNormal)
{
    local KFMonster KFM;

	bDisintegrated = true;
	bHidden = true;

	if( Role == ROLE_Authority )
	{
        SetTimer(0.1, false);
        NetUpdateTime = Level.TimeSeconds - 1;

    	KFM = KFMonster(Base);

        if( KFM != none && Role == ROLE_Authority )
        {
            KFM.NumHarpoonsAttached--;

            if( KFM.NumHarpoonsAttached <= 0 )
            {
                KFM.bHarpoonStunned = false;
            }
        }
	}

	PlaySound(DisintegrateSound,,2.0);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.SirenNadeDeflect',,, HitLocation, rotator(vect(0,0,1)));
	}
}

simulated function PostBeginPlay()
{

    BCInverse = 1 / BallisticCoefficient;

	if( Level.NetMode!=NM_DedicatedServer && (Level.NetMode!=NM_Client || Physics==PHYS_Projectile) )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			Trail = Spawn(class'NailGunTracer',self);
			Trail.Lifespan = Lifespan;
			SmokeTrail = Spawn(SmokeTrailEmitterClass,self);
		}
	}

    OrigLoc = Location;

    if( !bStuck )
    {
        Dir = vector(Rotation);
        Velocity = speed * Dir;
    }

    if (PhysicsVolume.bWaterVolume)
    {
        Velocity=0.6*Velocity;
    }
    super(Projectile).PostBeginPlay();

    SetTimer(ExplodeTimer, false);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    if( damageType == class'SirenScreamDamage')
    {
        Disintegrate(HitLocation, vect(0,0,1));
    }
    else
    {
        Explode(HitLocation, vect(0,0,1));
    }
}

simulated function Destroyed()
{
	if (Trail !=None)
	{
		Trail.mRegen = False;
	}

	if ( SmokeTrail != none )
	{
        SmokeTrail.Kill();
        SmokeTrail.SetPhysics(PHYS_None);
	}

	if( !bHasExploded && !bHidden )
		Explode(Location,vect(0,0,1));
	if( bHidden && !bDisintegrated )
        Disintegrate(Location,vect(0,0,1));

    Super.Destroyed();
}

// Stick this explosive to the wall or zed it hit
simulated function Stick(actor HitActor, vector HitLocation)
{
	local name NearestBone;
	local Pawn HitPawn;
	local float Dist;
	local vector HitDirection;
	local KFMonster KFM;

    HitDirection = Normal(Velocity);

    if( Velocity == vect(0,0,0) )
    {
        HitDirection = Vector(Rotation);
    }

    SetRotation(Rotator(HitDirection));

    bStuck=true;
    Velocity = vect(0,0,0);
    SetPhysics(PHYS_None);

	if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
        Pawn(HitActor.Base) != none )
    {
        HitPawn = Pawn(HitActor.Base);
    }
    else
    {
        HitPawn = Pawn(HitActor);
    }

	if (HitPawn != none)
	{
        NearestBone = HitPawn.GetClosestBone(HitLocation, HitDirection, Dist);
		HitPawn.AttachToBone(self,NearestBone);

		// Flag if we are stick in a pawn's head
        if( NearestBone ==  HitPawn.HeadBone )
		{
            bAttachedToHead = true;
		}

		KFM = KFMonster(HitPawn);

        if( KFM != none && Role == ROLE_Authority )
        {
            //KFMonster(HitPawn).SetZapped(99999999,Instigator,true);
            if( KFM.bHarpoonToBodyStuns || KFM.bHarpoonToHeadStuns && bAttachedToHead )
            {
                KFM.bHarpoonStunned = true;
            }

            KFM.NumHarpoonsAttached++;
        }

        // TODO: Improve the math here so its angle more closely matches the angle it stuck in at
		SetRelativeRotation(Rotator(HitDirection >> HitPawn.GetBoneRotation( NearestBone, 0 )));

	}
	else
    {
        SetBase(HitActor);
    }

	if( Trail!=None )
	{
		Trail.mRegen = False;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if( HitPawn != none )
		{
            PlaySound(ImpactPawnSound, SLOT_Misc );
        }
        else
        {
            PlaySound(ImpactSound, SLOT_Misc );
        }
	}

	// Make light radius smaller once it impacts
    LightRadius=2.0;
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dirs;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;


    if ( bHurtEntry )
        return;

    bHurtEntry = true;

    foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
        {
            dirs = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dirs));
            dirs = dirs/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            if ( Instigator == None || Instigator.Controller == None )
                Victims.SetDelayedDamageInstigatorController( InstigatorController );
            if ( Victims == LastTouched )
                LastTouched = None;

			P = Pawn(Victims);

			if( P != none )
			{
		        for (i = 0; i < CheckedPawns.Length; i++)
				{
		        	if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}

				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}

                KFMonsterVictim = KFMonster(Victims);

    			if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
    			{
                    KFMonsterVictim = none;
    			}

                KFP = KFPawn(Victims);

                if( KFMonsterVictim != none )
                {
                    // Double damage if attached to head
                    if( bAttachedToHead && KFMonsterVictim == Base )
                    {
                        damageScale *= 4.0;
                    }
                    else
                    {
                        damageScale *= KFMonsterVictim.GetExposureTo(HitLocation);
                    }
                }
                else if( KFP != none )
                {
                    // Double damage if attached to head
                    if( bAttachedToHead && KFP == Base )
                    {
                        damageScale *= 2.0;
                    }
                    else
                    {
                        damageScale *= KFP.GetExposureTo(HitLocation);
                    }
                }

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					//Victims = P;
					P = none;
				}
			}

            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
                (damageScale * Momentum * dirs),
                DamageType
            );
            if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
            {
                NumKilled++;
            }
        }
    }
    if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
        Victims = LastTouched;
        LastTouched = None;
        dirs = Victims.Location - HitLocation;
        dist = FMax(1,VSize(dirs));
        dirs = dirs/dist;
        damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
        if ( Instigator == None || Instigator.Controller == None )
            Victims.SetDelayedDamageInstigatorController(InstigatorController);
        Victims.TakeDamage
        (
            damageScale * DamageAmount,
            Instigator,
            Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
            (damageScale * Momentum * dirs),
            DamageType
        );
        if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
    }

	if( Role == ROLE_Authority )
    {
        if( NumKilled >= 4 )
        {
            KFGameType(Level.Game).DramaticEvent(0.05);
        }
        else if( NumKilled >= 2 )
        {
            KFGameType(Level.Game).DramaticEvent(0.03);
        }
    }

    bHurtEntry = false;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Don't let it hit this player, or blow up on another player
    if ( Other == none || Other == Instigator || Other.Base == Instigator || bStuck)
		return;

    // Don't collide with bullet whip attachments
    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    // Don't allow hits on poeple on the same team
    if( KFHumanPawn(Other) != none && Instigator != none
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

    // Use the instigator's location if it exists. This fixes issues with
    // the original location of the projectile being really far away from
    // the real Origloc due to it taking a couple of milliseconds to
    // replicate the location to the client and the first replicated location has
    // already moved quite a bit.
    if( Instigator != none )
    {
        OrigLoc = Instigator.Location;
    }

    Stick(Other, HitLocation);
}

simulated function Tick( float DeltaTime )
{
    if( !bStuck )
    {
        SetRotation(Rotator(Normal(Velocity)));
    }

    super.Tick(DeltaTime);
}

simulated function Landed( vector HitNormal )
{
    SetPhysics(PHYS_None);
}

defaultproperties
{
     ShakeRotMag=(X=600.000000,Y=600.000000,Z=600.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     ShakeOffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeOffsetTime=3.500000
     RotMag=(X=700.000000,Y=700.000000,Z=700.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=7.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ImpactDamageType=Class'KFMod.DamTypeRocketImpact'
     ImpactDamage=200
     StaticMeshRef="KF_IJC_Halloween_Weps2.Harpoon_Projectile"
     ExplosionSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Explode"
     DisintegrateSoundRef="Inf_Weapons.faust_explode_distant02"
     SmokeTrailEmitterClass=Class'KFMod.SealSquealFuseEmitter'
     ExplosionEmitterClass=Class'KFMod.SealSquealExplosionEmitter'
     ExplodeTimer=2.500000
     AmbientSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop"
     ImpactSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Hit_Wall"
     ImpactPawnSoundRef="KF_FY_SealSquealSND.WEP_Harpoon_Hit_Flesh"
     AmbientVolumeScale=2.000000
     bTrueBallistics=False
     Speed=3000.000000
     MaxSpeed=3000.000000
     Damage=350.000000
     DamageRadius=400.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'KFMod.DamTypeSealSquealExplosion'
     ExplosionDecal=Class'KFMod.KFScorchMark'
     LightType=LT_Steady
     LightHue=21
     LightSaturation=64
     LightBrightness=128.000000
     LightRadius=8.000000
     LightCone=16
     DrawType=DT_StaticMesh
     bDynamicLight=True
     bNetTemporary=False
     LifeSpan=10.000000
     bUnlit=False
     SoundVolume=255
     SoundRadius=250.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     bBlockHitPointTraces=False
     ForceRadius=300.000000
     ForceScale=10.000000
}
