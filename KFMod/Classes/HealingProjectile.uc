//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HealingProjectile extends ROBallisticProjectile;

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

var PanzerfaustTrail SmokeTrail;
var vector Dir;
var bool bRing,bHitWater,bWaterStart;

var()   sound   ExplosionSound; // The sound of the rocket exploding

var () int HealBoostAmount;

var     bool                bHitHealTarget;             // Hit a target we can heal.
var     bool                bHasExploded;
var     vector              HealLocation;
var     rotator             HealRotation;

// Physics
var() 		float 		StraightFlightTime;          // How long the projectile and flies straight
var 		float 		TotalFlightTime;             // How long the rocket has been in flight
var 		bool 		bOutOfPropellant;            // Projectile is out of propellant
// Physics debugging
var 		vector 		OuttaPropLocation;

var		string	StaticMeshRef;
var		string	ExplosionSoundRef;
var		string	AmbientSoundRef;
var		string	DisintegrateSoundRef;

replication
{
	reliable if(Role == ROLE_Authority)
		HealLocation, HealRotation;
}

static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.AmbientSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostNetReceive()
{
    if( bHidden && !bHitHealTarget )
    {
        if( HealLocation != vect(0,0,0) )
        {
            log("PostNetReceive calling HitHealTarget for location of "$HealLocation);
            HitHealTarget(HealLocation,vector(HealRotation));
        }
        else
        {
            log("PostNetReceive calling HitHealTarget for self location of "$HealLocation);
            HitHealTarget(Location,-vector(Rotation));
        }
    }
}

simulated function Tick( float DeltaTime )
{
    SetRotation(Rotator(Normal(Velocity)));

    if( !bOutOfPropellant )
    {
        if ( TotalFlightTime <= StraightFlightTime )
        {
            TotalFlightTime += DeltaTime;
        }
        else
        {
            OuttaPropLocation = Location;
            bOutOfPropellant = true;
        }
    }

    if(  bOutOfPropellant && bTrueBallistics )
    {
         //log(" Projectile flew "$(VSize(OrigLoc - OuttaPropLocation)/50.0)$" meters before running out of juice");
         bTrueBallistics = false;
    }
}

// Do a healing effect/sound instead of standard "explode"
simulated function HitHealTarget(vector HitLocation, vector HitNormal)
{
	bHitHealTarget = true;
	bHidden = true;
	SetPhysics(PHYS_None);

    HealLocation = HitLocation;
    HealRotation = rotator(HitNormal);

	if( Role == ROLE_Authority )
	{
	   SetTimer(0.1, false);
	   NetUpdateTime = Level.TimeSeconds - 1;
	}

	PlaySound(ExplosionSound,,2.0);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.HealingFX',,, HitLocation, rotator(HitNormal));
	}
}

function Timer()
{
    Destroy();
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
    super(Projectile).HitWall(HitNormal,Wall);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    bHasExploded = True;

    // Don't do the regular effect if we healed someone
    if( bHitHealTarget )
    {
        return;
    }

    SetPhysics(PHYS_None);

    if(Level.NetMode != NM_DedicatedServer)
	{
		Spawn(class'ROBulletHitEffect',,, Location, rotator(-HitNormal));
	}

    BlowUp(HitLocation);
    Destroy();
}

simulated function PostBeginPlay()
{
    OrigLoc = Location;

    Dir = vector(Rotation);
    Velocity = speed * Dir;
    if (PhysicsVolume.bWaterVolume)
    {
        bHitWater = True;
        Velocity=0.6*Velocity;
    }
    Super.PostBeginPlay();
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    Explode(HitLocation, vect(0,0,0));
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
	{
		SmokeTrail.HandleOwnerDestroyed();
	}

	if( !bHasExploded && !bHidden )
		Explode(Location,vect(0,0,1));
	if( bHidden && !bHitHealTarget )
	{
        if( HealLocation != vect(0,0,0) )
        {
            HitHealTarget(HealLocation,vector(HealRotation));
        }
        else
        {
            HitHealTarget(Location,-vector(Rotation));
        }
    }

    Super.Destroyed();
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    return;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

    if( Role == ROLE_Authority )
    {
    	Healed = KFHumanPawn(Other);

        if( Healed != none )
        {
            HitHealTarget(HitLocation, -vector(Rotation));
        }

        if( Instigator != none && Healed != none && Healed.Health > 0 &&
            Healed.Health <  Healed.HealthMax && Healed.bCanBeHealed )
        {
    		MedicReward = HealBoostAmount;

    		PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

    		if ( PRI != none && PRI.ClientVeteranSkill != none )
    		{
    			MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
    		}

            HealSum = MedicReward;

    		if ( (Healed.Health + Healed.healthToGive + MedicReward) > Healed.HealthMax )
    		{
                MedicReward = Healed.HealthMax - (Healed.Health + Healed.healthToGive);
    			if ( MedicReward < 0 )
    			{
    				MedicReward = 0;
    			}
    		}

            Healed.GiveHealth(HealSum, Healed.HealthMax);

     		if ( PRI != None )
    		{
    			if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
    			{
	    			AddDamagedHealStats( MedicReward );
    			}

                // Give the medic reward money as a percentage of how much of the person's health they healed
    			MedicReward = int((FMin(float(MedicReward),Healed.HealthMax)/Healed.HealthMax) * 60); // Increased to 80 in Balance Round 6, reduced to 60 in Round 7

    			PRI.ReceiveRewardForHealing( MedicReward, Healed );

    			if ( KFHumanPawn(Instigator) != none )
    			{
    				KFHumanPawn(Instigator).AlphaAmount = 255;
    			}

                if( KFMedicGun(Instigator.Weapon) != none )
                {
                    KFMedicGun(Instigator.Weapon).ClientSuccessfulHeal(Healed.GetPlayerName());
                }
    		}
        }
    }
    else if( KFHumanPawn(Other) != none )
    {
    	bHidden = true;
    	SetPhysics(PHYS_None);
    	return;
    }

	Explode(HitLocation,-vector(Rotation));
}

function AddDamagedHealStats( int MedicReward ){}

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
     HealBoostAmount=20
     StraightFlightTime=0.100000
     StaticMeshRef="KF_pickups2_Trip.MP7_Dart"
     ExplosionSoundRef="KF_MP7Snd.MP7_DartImpact"
     AmbientSoundRef="KF_MP7Snd.MP7_DartFlyLoop"
     AmbientVolumeScale=2.000000
     Speed=10000.000000
     MaxSpeed=12500.000000
     Damage=650.000000
     DamageRadius=200.000000
     MomentumTransfer=125000.000000
     ExplosionDecal=Class'KFMod.ShotgunDecal'
     LightHue=25
     LightSaturation=100
     LightBrightness=250.000000
     LightRadius=10.000000
     DrawType=DT_StaticMesh
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     LifeSpan=10.000000
     bUnlit=False
     SoundVolume=128
     SoundRadius=250.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     bBlockHitPointTraces=False
     ForceRadius=300.000000
     ForceScale=10.000000
}
