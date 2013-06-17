//=============================================================================
// PipeBombProjectile
//=============================================================================
class PipeBombProjectile extends Projectile;

//var float ExplodeTimer;
var bool bCanHitOwner, bHitWater;
var() float DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;
var float LastSparkTime;

var() vector RotMag;            // how far to rot view
var() vector RotRate;           // how fast to rot view
var() float  RotTime;           // how much time to rot the instigator's view
var() vector OffsetMag;         // max view offset vertically
var() vector OffsetRate;        // how fast to offset view vertically
var() float  OffsetTime;        // how much time to offset view
var() class<Projectile> ShrapnelClass;
var bool bHasExploded;
var     bool    bDisintegrated; // This nade has been disintegrated by a siren scream.
var()   sound   DisintegrateSound;// The sound of this projectile disintegrating
var()   sound   BeepSound;      // A beeping sound this projectile makes
var     bool    bEnemyDetected; // We've found an enemy
var     int     Countdown;      // Countdown to explosion after enemy detected
var()   float   DetectionRadius;// How far away to detect enemies
var     bool    bArmed;         // Landed on the ground and armed
var()   float   ArmingCountDown;// How long before arming after it lands on the ground
var() array<Sound> ExplodeSounds;
var     int     PlacedTeam;     // TeamIndex of the team that placed this projectile
var()   float   ThreatThreshhold;// How much of a threat to detect before we blow up

var     PipebombLight   BombLight;          // Flashing light
var()   vector          BombLightOffset;    // Offset for flashing light

var     bool            bTriggered; // This thing has exploded

var() 	array<string> 	ExplodeSoundRefs;
var		string			StaticMeshRef;

replication
{
	reliable if(Role == ROLE_Authority)
		bTriggered;
}

static function PreloadAssets()
{
	default.ExplodeSounds[0] = sound(DynamicLoadObject(default.ExplodeSoundRefs[0], class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplodeSounds[0] = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function Destroyed()
{
	if( !bHasExploded && !bHidden && bTriggered)
		Explode(Location,vect(0,0,1));
	if( bHidden && !bDisintegrated )
        Disintegrate(Location,vect(0,0,1));

    if( BombLight != none )
    {
        BombLight.Destroy();
    }

	Super.Destroyed();
}

// cut-n-paste to remove grenade smoke trail
simulated function PostBeginPlay()
{
    if ( Level.NetMode != NM_DedicatedServer)
    {
        BombLight = Spawn(class'PipebombLight',self);
        BombLight.SetBase(self);
    }

	if ( Role == ROLE_Authority )
	{
		Velocity = Speed * Vector(Rotation);
		RandSpin(25000);
		bCanHitOwner = false;
		if (Instigator.HeadVolume.bWaterVolume)
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;
		}
	}
}

simulated function PostNetReceive()
{
    if( bHidden && !bDisintegrated )
    {
        Disintegrate(Location, vect(0,0,1));
    }
    else if( bTriggered && !bHasExploded )
    {
        Explode(Location,vect(0,0,1));
    }
}

function Timer()
{
	local Pawn CheckPawn;
	local float ThreatLevel;

    if( !bHidden && !bTriggered )
    {
        if( ArmingCountDown >= 0 )
        {
            ArmingCountDown -= 0.1;
            if( ArmingCountDown <= 0 )
            {
                SetTimer(1.0,True);
            }
    	}
    	else
    	{
            // Check for enemies
            if( !bEnemyDetected )
            {
                bAlwaysRelevant=false;
                PlaySound(BeepSound,,0.5,,50.0);

            	foreach VisibleCollidingActors( class 'Pawn', CheckPawn, DetectionRadius, Location )
            	{
            		if( CheckPawn == Instigator || KFGameType(Level.Game).FriendlyFireScale > 0 &&
                        CheckPawn.PlayerReplicationInfo != none &&
                        CheckPawn.PlayerReplicationInfo.Team.TeamIndex == PlacedTeam )
                    {
                        // Make the thing beep if someone on our team is within the detection radius
                        // This gives them a chance to get out of the way
                        ThreatLevel += 0.001;
                    }
                    else
                    {
                        if( (CheckPawn != Instigator) && (CheckPawn.Role == ROLE_Authority) &&
                            CheckPawn.PlayerReplicationInfo == none || CheckPawn.PlayerReplicationInfo.Team.TeamIndex != PlacedTeam )
                		{
                            if( KFMonster(CheckPawn) != none )
                            {
                                ThreatLevel += KFMonster(CheckPawn).MotionDetectorThreat;
                                if( ThreatLevel >= ThreatThreshhold )
                                {
                                    bEnemyDetected=true;
                                    SetTimer(0.15,True);
                                }
                            }
                            else
                            {
                                bEnemyDetected=true;
                                SetTimer(0.15,True);
                            }
                		}
            		}

            	}

                if( ThreatLevel >= ThreatThreshhold )
                {
                    bEnemyDetected=true;
                    SetTimer(0.15,True);
                }
                else if( ThreatLevel > 0 )
                {
                    SetTimer(0.5,True);
                }
                else
                {
                    SetTimer(1.0,True);
                }
        	}
        	// Play some fast beeps and blow up
        	else
        	{
                bAlwaysRelevant=true;
                Countdown--;

                if( CountDown > 0 )
                {
                    PlaySound(BeepSound,SLOT_Misc,2.0,,150.0);
                }
                else
                {
                    Explode(Location, vector(Rotation));
                }
        	}
    	}
	}
	else
	{
        Destroy();
	}
}

simulated function Landed( vector HitNormal )
{
    SetTimer(1.0,True);
    HitWall( HitNormal, none );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{

    // Don't bounce off of bullet whiz cylinders
    if( Other.bBlockHitPointTraces )
    {
        return;
    }

	// more realistic interactions with karma objects.
	if (Other.IsA('NetKActor'))
		KAddImpulse(Velocity,HitLocation,);

	// Stop the grenade in its tracks if it hits an enemy.
	if ( !Other.bWorldGeometry && ((Other != Instigator && Other.Base != Instigator )|| bCanHitOwner) )
		Velocity = Vect(0,0,0);
}

// Overridden to tweak the handling of the impact sound
simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if ( Speed < 20 )
    {
        bBounce = False;
        PrePivot.Z = 3.5;
		SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
		SetTimer(0.1,True);
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

simulated function BlowUp(vector HitLocation)
{
	DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController  LocalPlayer;
	local Projectile P;
	local byte i;

	bHasExploded = True;
	BlowUp(HitLocation);

    bTriggered = true;

	if( Role == ROLE_Authority )
	{
	   SetTimer(0.1, false);
	   NetUpdateTime = Level.TimeSeconds - 1;
	}

	PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);

	// Shrapnel
	for( i=Rand(6); i<10; i++ )
	{
		P = Spawn(ShrapnelClass,,,,RotRand(True));
		if( P!=None )
			P.RemoteRole = ROLE_None;
	}
	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.KFNadeLExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}

	// Shake nearby players screens
	LocalPlayer = Level.GetLocalPlayerController();
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

	// Clear Explosive Detonation Flag
//	if ( KFPlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
//	{
//		KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements).OnGrenadeExploded();
//	}

    if( Role < ROLE_Authority )
    {
	   Destroy();
	}
}

// Make the projectile distintegrate, instead of explode
simulated function Disintegrate(vector HitLocation, vector HitNormal)
{
	bDisintegrated = true;
	bHidden = true;

	if( Role == ROLE_Authority )
	{
	   SetTimer(0.1, false);
	   NetUpdateTime = Level.TimeSeconds - 1;
	}

	PlaySound(DisintegrateSound,,2.0);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.SirenNadeDeflect',,, HitLocation, rotator(vect(0,0,1)));
	}
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
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
			if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
				Continue;
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if ( Instigator == None || Instigator.Controller == None )
			{
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			}

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
                    damageScale *= KFMonsterVictim.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
                }
                else if( KFP != none )
                {
				    damageScale *= KFP.GetExposureTo(Location + 15 * -Normal(PhysicsVolume.Gravity));
				    // Reduce damage to poeple so I can make the damage radius a bit bigger for killing zeds
				    damageScale *= 0.5;
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

			Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
			 * dir,(damageScale * Momentum * dir),DamageType);

			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
            {
                NumKilled++;
            }

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			{
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
			}
        }
	}

	if( Role == ROLE_Authority )
    {
    	if ( NumKilled >= 10 && Instigator != none && Instigator.PlayerReplicationInfo != none &&
			 KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
    	{
    		KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements).Killed10ZedsWithPipebomb();
    	}

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

// Shoot nades in mid-air
// Alex
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    if ( damageType == class'DamTypePipeBomb' ||
         ClassIsChildOf(damageType, class'DamTypeMelee') ||
         (Damage < 25 && damageType.IsA('SirenScreamDamage')) )
    {
        return;
    }

    // Don't let our own explosives blow this up!!!
    if ( InstigatedBy == none || InstigatedBy != none &&
         InstigatedBy.PlayerReplicationInfo != none &&
         InstigatedBy.PlayerReplicationInfo.Team != none &&
         InstigatedBy.PlayerReplicationInfo.Team.TeamIndex == PlacedTeam &&
         Class<KFWeaponDamageType>(damageType) != none &&
         (Class<KFWeaponDamageType>(damageType).default.bIsExplosive ||
         InstigatedBy != Instigator) )
    {
        return;
    }

     if ( damageType == class'SirenScreamDamage')
    {
        if ( Damage >= 5 )
        {
            Disintegrate(HitLocation, vect(0,0,1));
        }
    }
    else
    {
        Explode(HitLocation, vect(0,0,1));
    }
}

defaultproperties
{
     DampenFactor=0.250000
     DampenFactorParallel=0.400000
     RotMag=(X=600.000000,Y=600.000000,Z=600.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ShrapnelClass=Class'KFMod.PipeBombShrapnel'
     DisintegrateSound=Sound'Inf_Weapons.panzerfaust60.faust_explode_distant02'
     BeepSound=Sound'KF_FoundrySnd.1Shot.Keypad_beep01'
     CountDown=5
     DetectionRadius=150.000000
     ArmingCountDown=1.000000
     ThreatThreshhold=1.000000
     ExplodeSoundRefs(0)="Inf_Weapons.antitankmine_explode01"
     ExplodeSoundRefs(1)="Inf_Weapons.antitankmine_explode02"
     ExplodeSoundRefs(2)="Inf_Weapons.antitankmine_explode03"
     StaticMeshRef="KF_pickups2_Trip.Pipebomb_Pickup"
     Speed=50.000000
     MaxSpeed=50.000000
     TossZ=0.000000
     Damage=1500.000000
     DamageRadius=350.000000
     MomentumTransfer=100000.000000
     MyDamageType=Class'KFMod.DamTypePipeBomb'
     ImpactSound=SoundGroup'KF_GrenadeSnd.Nade_HitSurf'
     ExplosionDecal=Class'KFMod.KFScorchMark'
     DrawType=DT_StaticMesh
     bNetTemporary=False
     Physics=PHYS_Falling
     LifeSpan=0.000000
     bUnlit=False
     FluidSurfaceShootStrengthMod=3.000000
     TransientSoundVolume=200.000000
     CollisionRadius=8.000000
     CollisionHeight=3.000000
     bProjTarget=True
     bNetNotify=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
