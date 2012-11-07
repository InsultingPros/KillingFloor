//=============================================================================
// NailGunProjectile
//=============================================================================
// Nail Gun projectile class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class NailGunProjectile extends ShotgunBullet;

var     String         ImpactSoundRefs[6];
var     String         StaticMeshRef;

var byte Bounces;
var bool bFinishedPenetrating;

var KFMonster MonsterHeadAttached;
var ProjectileBodyPart Giblet;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;

    reliable if (Role == ROLE_Authority)
        MonsterHeadAttached, bFinishedPenetrating;
}

static function PreloadAssets()
{
	//default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	default.ImpactSounds[0] = sound(DynamicLoadObject(default.ImpactSoundRefs[0], class'Sound', true));
    default.ImpactSounds[1] = sound(DynamicLoadObject(default.ImpactSoundRefs[1], class'Sound', true));
	default.ImpactSounds[2] = sound(DynamicLoadObject(default.ImpactSoundRefs[2], class'Sound', true));
    default.ImpactSounds[3] = sound(DynamicLoadObject(default.ImpactSoundRefs[3], class'Sound', true));
	default.ImpactSounds[4] = sound(DynamicLoadObject(default.ImpactSoundRefs[4], class'Sound', true));
    default.ImpactSounds[5] = sound(DynamicLoadObject(default.ImpactSoundRefs[5], class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ImpactSounds[0] = none;
	default.ImpactSounds[1] = none;
	default.ImpactSounds[2] = none;
	default.ImpactSounds[3] = none;
	default.ImpactSounds[4] = none;
	default.ImpactSounds[5] = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostBeginPlay()
{
	super(Projectile).PostBeginPlay();

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    SetTimer(0.4, false);

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {

            Trail = Spawn(class'NailGunTracer',self);
            Trail.Lifespan = Lifespan;
        }
    }
}

simulated function PostNetReceive()
{
    local Coords boneCoords;

    super.PostNetReceive();

    if( Giblet == none && MonsterHeadAttached != none )
    {
       boneCoords = MonsterHeadAttached.GetBoneCoords( 'head' );

       Giblet = Spawn( Class'ProjectileBodyPart',,, boneCoords.Origin, Rotator(boneCoords.XAxis) );
       Giblet.SetStaticMesh(MonsterHeadAttached.DetachedHeadClass.default.StaticMesh);
       Giblet.SetLocation(Location);
       Giblet.SetPhysics( PHYS_None );
       Giblet.SetBase(self);
       Giblet.Lifespan = Lifespan;
    }
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;
    local bool bWasDecapitated;
    local KFMonster KFM;

	if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces  )
		return;

	if( bFinishedPenetrating )
	{
	   return;
	}

    X = Vector(Rotation);

 	if( ROBulletWhipAttachment(Other) != none )
	{
        if(!Other.Base.bDeleteMe)
        {
	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

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
                    	HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,HitPoints);


                    // Hit detection debugging
    				//if( Level.NetMode == NM_Standalone)
    				//	HitPawn.DrawBoneLocation();
    	    	}
    		}
		}
	}
    else
    {
        if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
        {
            KFM = KFMonster(Other);

            if( KFM != none )
            {
                bWasDecapitated = KFM.bDecapitated;
            }

            Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

            if( Role == ROLE_Authority && Bounces > 0 && MonsterHeadAttached == none &&
                KFM != none && !bWasDecapitated && KFM.Health < 0 )
            {
                MonsterHeadAttached = KFM;

                if( Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone )
                {
                    PostNetReceive();
                }
                Bounces=0;
            }
        }
        else
        {
            KFM = KFMonster(Other.Base);

            if( KFM != none )
            {
                bWasDecapitated = KFM.bDecapitated;
            }

            Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

            if( Role == ROLE_Authority && Bounces > 0 && MonsterHeadAttached == none &&
                KFM != none && !bWasDecapitated && KFM.Health < 0 && KFM.IsHeadShot(HitLocation, X, 1.0))
            {
                MonsterHeadAttached = KFM;

                if( Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone )
                {
                    PostNetReceive();
                }
                Bounces=0;
            }
        }
    }

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
   		PenDamageReduction = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo),default.PenDamageReduction);
	}
	else
	{
   		PenDamageReduction = default.PenDamageReduction;
   	}

   	Damage *= PenDamageReduction; // Keep going, but lose effectiveness each time.

    // if we've struck through more than the max number of foes, destroy.
    if ( Damage / default.Damage <= PenDamageReduction / MaxPenetrations )
    {
        bFinishedPenetrating = true;
        Velocity = PhysicsVolume.Gravity;
        SetPhysics(PHYS_Falling);
        Bounces=0;
    }

    speed = VSize(Velocity);

    if( Speed < (default.Speed * 0.25) )
    {
        bFinishedPenetrating = true;
        Velocity = PhysicsVolume.Gravity;
        SetPhysics(PHYS_Falling);
        Bounces=0;
    }
}

simulated function Tick( float DeltaTime )
{
    if ( Level.NetMode != NM_DedicatedServer && Physics != PHYS_None )
    {
        SetRotation(Rotator(Normal(Velocity)));
    }
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    if ( !Wall.bStatic && !Wall.bWorldGeometry
		&& ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if ( Level.NetMode != NM_Client )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
            Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		}
        Destroy();
        return;
    }



    SetRotation(rotator(Normal(Velocity)));

    SetPhysics(PHYS_Falling);
	if (Bounces > 0)
    {
		if ( !Level.bDropDetail && (FRand() < 0.4) )
			Playsound(ImpactSounds[Rand(6)]);

        Velocity = 0.65 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;

    	if ( !Level.bDropDetail && (Level.NetMode != NM_DedicatedServer))
    	{
            Spawn(class'ROEffects.ROBulletHitMetalEffect',,,Location, rotator(hitnormal));
    	}

        return;
    }
    else
    {
    	if (ImpactEffect != None && (Level.NetMode != NM_DedicatedServer))
    	{
            Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
    	}
        SetPhysics(PHYS_None);
        LifeSpan = 5.0;
    }
	bBounce = false;
    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
        //Trail.mRegenRange[0] = 0.0;//trail.mRegenRange[0] * 0.6;
        //Trail.mRegenRange[1] = 0.0;//trail.mRegenRange[1] * 0.6;
    }
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    if (Volume.bWaterVolume)
    {
        if ( Trail != None )
            Trail.mRegen=False;
        Velocity *= 0.65;
    }
}

simulated function Landed( Vector HitNormal )
{
    SetPhysics(PHYS_None);
    LifeSpan = 5.0;
}

simulated function Destroyed()
{
    super.Destroyed();

    if( Giblet != none )
    {
        Giblet.Destroy();
        Giblet = none;
    }

    if( MonsterHeadAttached != none )
    {
        MonsterHeadAttached = none;
    }
}

defaultproperties
{
     ImpactSoundRefs(0)="ProjectileSounds.Bullets.Impact_Metal"
     ImpactSoundRefs(1)="ProjectileSounds.Bullets.Impact_Metal"
     ImpactSoundRefs(2)="ProjectileSounds.Bullets.Impact_Metal"
     ImpactSoundRefs(3)="ProjectileSounds.Bullets.Impact_Metal"
     ImpactSoundRefs(4)="ProjectileSounds.Bullets.Impact_Metal"
     ImpactSoundRefs(5)="ProjectileSounds.Bullets.Impact_Metal"
     StaticMeshRef="EffectsSM.Weapons.Vlad_9000_Nail"
     Bounces=2
     PenDamageReduction=0.750000
     MyDamageType=Class'KFMod.DamTypeNailGun'
     ExplosionDecal=Class'KFMod.NailGunDecal'
     bNetTemporary=False
     LifeSpan=10.000000
     bNetNotify=True
     bBounce=True
}
