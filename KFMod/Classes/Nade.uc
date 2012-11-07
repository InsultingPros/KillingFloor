//=============================================================================
// Nade
//=============================================================================
class Nade extends Grenade;

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

var() array<Sound> ExplodeSounds;

var AvoidMarker Fear;

function PostNetBeginPlay()
{
	SetTimer(ExplodeTimer, false);
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

// Shoot nades in mid-air
// Alex
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if ( Monster(instigatedBy) != none || instigatedBy == Instigator )
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
}

// cut-n-paste to remove grenade smoke trail
simulated function PostBeginPlay()
{
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

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController  LocalPlayer;
	local Projectile P;
	local byte i;

	bHasExploded = True;
	BlowUp(HitLocation);

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
		Spawn(Class'KFmod.KFNadeExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}

	// Shake nearby players screens
	LocalPlayer = Level.GetLocalPlayerController();
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

	Destroy();
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

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.mRegen = false; // stop the emitter from regenerating
	if( !bHasExploded && !bHidden )
		Explode(Location,vect(0,0,1));
	if( bHidden && !bDisintegrated )
        Disintegrate(Location,vect(0,0,1));
	if ( Fear != None )
		Fear.Destroy();
	Super.Destroyed();
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
//    local vector Other2dLocation, TwoDLocation;
//    local float DistToOtherCenter;
//    local bool bHitIsCloseToCenter;

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

	// more realistic interactions with karma objects.
	if (Other.IsA('NetKActor'))
		KAddImpulse(Velocity,HitLocation,);

     // Failed attempt at making nades only stop if they are close to the center of the
     // collision. When I have more time, try and do a closest point along the ray test - Ramm
//    if ( !Other.bWorldGeometry && Other != Instigator )
//    {
//        Other2dLocation = Other.Location;
//        Other2dLocation.Z = 0;
//        TwoDLocation = Location;
//        TwoDLocation.Z = 0;
//        DistToOtherCenter = VSize(Other2dLocation - TwoDLocation);
//        bHitIsCloseToCenter = DistToOtherCenter < Other.CollisionRadius/2.0;
//        log("DistToOtherCenter = "$DistToOtherCenter$" Other.CollisionRadius/2.0 "$Other.CollisionRadius/2.0 );
//    }

	// Stop the grenade in its tracks if it hits an enemy.
	if ( !Other.bWorldGeometry && ((Other != Instigator && Other.Base != Instigator /*&& bHitIsCloseToCenter*/ )|| bCanHitOwner) )
		Velocity = Vect(0,0,0);
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
    	if ( NumKilled >= 8 && Instigator != none && Instigator.PlayerReplicationInfo != none &&
			 KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements) != none )
    	{
    		KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements).Killed8ZedsWithGrenade();
    	}

        if ( NumKilled >= 4 )
        {
            KFGameType(Level.Game).DramaticEvent(0.05);
        }
        else if ( NumKilled >= 2 )
        {
            KFGameType(Level.Game).DramaticEvent(0.03);
        }
    }

	bHurtEntry = false;
}

// Overridden to tweak the handling of the impact sound
simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }

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
        PrePivot.Z = -1.5;
			SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);

		if( Fear == none )
		{
		    Fear = Spawn(class'AvoidMarker');
    		Fear.SetCollisionSize(DamageRadius,DamageRadius);
    		Fear.StartleBots();
		}

        if ( Trail != None )
            Trail.mRegen = false; // stop the emitter from regenerating
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

defaultproperties
{
     RotMag=(X=600.000000,Y=600.000000,Z=600.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ShrapnelClass=Class'KFMod.KFShrapnel'
     DisintegrateSound=Sound'Inf_Weapons.panzerfaust60.faust_explode_distant02'
     ExplodeSounds(0)=SoundGroup'KF_GrenadeSnd.Nade_Explode_1'
     ExplodeSounds(1)=SoundGroup'KF_GrenadeSnd.Nade_Explode_2'
     ExplodeSounds(2)=SoundGroup'KF_GrenadeSnd.Nade_Explode_3'
     DampenFactor=0.250000
     DampenFactorParallel=0.400000
     Speed=160.000000
     MaxSpeed=850.000000
     Damage=300.000000
     DamageRadius=420.000000
     MomentumTransfer=100000.000000
     MyDamageType=Class'KFMod.DamTypeFrag'
     ImpactSound=SoundGroup'KF_GrenadeSnd.Nade_HitSurf'
     ExplosionDecal=Class'KFMod.KFScorchMark'
     StaticMesh=StaticMesh'KillingFloorStatics.FragProjectile'
     bNetTemporary=False
     DrawScale=0.400000
     AmbientGlow=0
     bUnlit=False
     TransientSoundVolume=200.000000
     bNetNotify=True
     bBlockHitPointTraces=False
}
