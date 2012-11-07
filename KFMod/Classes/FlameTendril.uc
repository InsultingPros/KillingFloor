//=============================================================================
// Flame
//=============================================================================
class FlameTendril extends ShotgunBullet;

var bool 	bRing, bHitWater, bWaterStart;
var Effects Corona;
var Emitter FlameTrail;
var byte 	TimerRunCount;

simulated function PostBeginPlay()
{
	SetTimer(0.2, true);

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(class'FlameThrowerFlameB',self);
			Trail = Spawn(class'FlameThrowerFlame',self);
		}
	}

	Velocity.z += TossZ;
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ( (Instigator != None) && (PC == Instigator.Controller) )
		{
			return;
		}

		if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
		{
			bDynamicLight = false;
			LightType = LT_None;
		}
	}
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	if ( Role == ROLE_Authority )
	{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	}

	if ( KFHumanPawn(Instigator) != none )
	{
		if ( EffectIsRelevant(Location,false) )
		{
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
			Spawn(class'FuelFlame',self,,Location);
		}
	}

	SetCollisionSize(0.0, 0.0);
	Destroy();
}

simulated function Destroyed()
{
	if ( Trail != none )
	{
		Trail.mRegen=False;
		Trail.SetPhysics(PHYS_None);
	}

	if ( FlameTrail != none )
	{
		FlameTrail.Kill();
		FlameTrail.SetPhysics(PHYS_None);
	}

	Super.Destroyed();
}

function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Other == none || Other == Instigator || Other.Base == Instigator  )
		return;

	// Don't spawn an explosion if low gore is on
	if ( Other != Instigator && class'GameInfo'.static.UseLowGore() && Other.IsA('KFMonster') )
	{
		if ( Role == ROLE_Authority )
		{
			HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
		}

		if ( KFHumanPawn(Instigator) != none )
		{
			if ( EffectIsRelevant(Location,false) )
			{
				Spawn(ExplosionDecal,self,,Location, Rotator(-Location));
			}
		}

		SetCollisionSize(0.0, 0.0);
		Destroy();
	}

	else if ( Other != Instigator && !Other.IsA('FlameTendril') && !Other.IsA('FuelFlame') && !Other.IsA('PhysicsVolume') )
	{
		Explode(self.Location,self.Location);
	}
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
			{
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			}

			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

			if ( DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0 )
			{
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			}

			HurtWall = Wall;
		}

		MakeNoise(1.0);
	}

	Explode(Location + ExploWallOut * HitNormal, HitNormal);

	HurtWall = None;
}

simulated function Timer()
{
	Velocity =  Default.Speed * Normal(Velocity);

	if ( Trail != none )
	{
		Trail.mSizeRange[0] *= 1.8;
		Trail.mSizeRange[1] *= 1.8;
	}

	if ( FlameTrail != none )
	{
		FlameTrail.SetDrawScale(FlameTrail.DrawScale * 1.5);
	}

	TimerRunCount++;
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		if ( TimerRunCount >= 2 + KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ExtraRange(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo)) )
		{
			Explode(Location,VRand());
		}
	}
	else if ( TimerRunCount >= 2 )
	{
		Explode(Location,VRand());
	}
}

defaultproperties
{
     MaxPenetrations=3
     PenDamageReduction=0.000000
     HeadShotDamageMult=1.000000
     Speed=2300.000000
     MaxSpeed=2400.000000
     TossZ=200.000000
     Damage=12.000000
     DamageRadius=150.000000
     MomentumTransfer=0.000000
     MyDamageType=Class'KFMod.DamTypeBurned'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark'
     DrawType=DT_None
     StaticMesh=None
     Physics=PHYS_Falling
     LifeSpan=5.000000
     DrawScale=5.000000
     Style=STY_None
     bBlockHitPointTraces=False
}
