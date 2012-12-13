// Zombie Monster for KF Invasion gametype
class ZombieBoss extends ZombieBossBase;

#exec OBJ LOAD FILE=KFPatch2.utx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx
#exec OBJ LOAD FILE=KF_tx_trip_t.utx

//----------------------------------------------------------------------------
// NOTE: Most Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------

var BossHPNeedle CurrentNeedle;

// Last time we checked if a player was melee exploiting us
var float LastMeleeExploitCheckTime;
// Used to track what type of melee exploiters you have
var int NumLumberJacks;
var int NumNinjas;

// Make the Boss's ambient scale higher, since there is only 1, doesn't matter if he's relevant almost all the time
simulated function CalcAmbientRelevancyScale()
{
        // Make the zed only relevant by thier ambient sound out to a range of 100 meters
    	CustomAmbientRelevancyScale = 5000/(100 * SoundRadius);
}

function vector ComputeTrajectoryByTime( vector StartPosition, vector EndPosition, float fTimeEnd  )
{
	local vector NewVelocity;
	
	NewVelocity = Super.ComputeTrajectoryByTime( StartPosition, EndPosition, fTimeEnd );
	
	if( PhysicsVolume.IsA( 'KFPhysicsVolume' ) && StartPosition.Z < EndPosition.Z )
	{
		if( PhysicsVolume.Gravity.Z < class'PhysicsVolume'.default.Gravity.Z )
		{
			// Just checking mass to be extra-cautious.
			if( Mass > 900 )
			{
				// Extra velocity boost to counter oversized mass weighing the boss down.
				NewVelocity.Z += 90;
			}
		}
	}	
	return NewVelocity;
}

function ZombieMoan()
{
	if( !bShotAnim ) // Do not moan while taunting
		Super.ZombieMoan();
}

// Speech notifies called from the anims
function PatriarchKnockDown()
{
    PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
    PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
    PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
    PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
    PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

// Taunt to use when doing the melee exploit radial attack
function PatriarchRadialTaunt()
{
    if( NumNinjas > 0 && NumNinjas > NumLumberJacks )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_TauntNinja', SLOT_Misc, 2.0,true,500.0);
    }
    else if( NumLumberJacks > 0 && NumLumberJacks > NumNinjas )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_TauntLumberJack', SLOT_Misc, 2.0,true,500.0);
    }
    else
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_TauntRadial', SLOT_Misc, 2.0,true,500.0);
    }
}

// Don't do this for the Patriarch
simulated function SetBurningBehavior(){}
simulated function UnSetBurningBehavior(){}
function bool CanGetOutOfWay()
{
    return false;
}

simulated function Tick(float DeltaTime)
{
	local KFHumanPawn HP;

	Super.Tick(DeltaTime);

	// Process the pipe bomb time damage scale, reducing the scale over time so
	// it goes back up to 100% damage over a few seconds
    if( Role == ROLE_Authority )
	{
	   PipeBombDamageScale -= DeltaTime * 0.33;

	   if( PipeBombDamageScale < 0 )
	   {
	       PipeBombDamageScale = 0;
	   }
	}

	if( Level.NetMode==NM_DedicatedServer )
		Return; // Servers aren't intrested in this info.

	bSpecialCalcView = bIsBossView;
    if( bZapped )
    {
        // Make sure we check if we need to be cloaked as soon as the zap wears off
        LastCheckTimes = Level.TimeSeconds;
    }
	else if( bCloaked && Level.TimeSeconds>LastCheckTimes )
	{
		LastCheckTimes = Level.TimeSeconds+0.8;
		ForEach VisibleCollidingActors(Class'KFHumanPawn',HP,1000,Location)
		{
			if( HP.Health <= 0 || !HP.ShowStalkers() )
				continue;

			// If he's a commando, we've been spotted.
			if( !bSpotted )
			{
				bSpotted = True;
				CloakBoss();
			}
			Return;
		}
		// if we're uberbrite, turn down the light
		if( bSpotted )
		{
			bSpotted = False;
			bUnlit = false;
			CloakBoss();
		}
	}
}
simulated function CloakBoss()
{
	local Controller C;
	local int Index;

    // No cloaking if zapped
    if( bZapped )
    {
        return;
    }

	if( bSpotted )
	{
		Visibility = 120;
		if( Level.NetMode==NM_DedicatedServer )
			Return;
		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;
		return;
	}

	Visibility = 1;
	bCloaked = true;
	if( Level.NetMode!=NM_Client )
	{
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.bIsPlayer && C.Enemy==Self )
				C.Enemy = None; // Make bots lose sight with me.
		}
	}
	if( Level.NetMode==NM_DedicatedServer )
		Return;

	Skins[0] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
	Skins[1] = Shader'KF_Specimens_Trip_T.patriarch_invisible';

	// Invisible - no shadow
	if(PlayerShadow != none)
		PlayerShadow.bShadowActive = false;

	// Remove/disallow projectors on invisible people
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;
    SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

	// Randomly send out a message about Patriarch going invisible(10% chance)
	if ( FRand() < 0.10 )
	{
		// Pick a random Player to say the message
		Index = Rand(Level.Game.NumPlayers);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( PlayerController(C) != none )
			{
				if ( Index == 0 )
				{
					PlayerController(C).Speech('AUTO', 8, "");
					break;
				}

				Index--;
			}
		}
	}
}

simulated function UnCloakBoss()
{
    if( bZapped )
    {
        return;
    }

	Visibility = default.Visibility;
	bCloaked = false;
	bSpotted = False;
	bUnlit = False;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	Skins = Default.Skins;

	if (PlayerShadow != none)
		PlayerShadow.bShadowActive = true;

	bAcceptsProjectors = true;
    SetOverlayMaterial( none, 0.0, true );
}

// Set the zed to the zapped behavior
simulated function SetZappedBehavior()
{
    super.SetZappedBehavior();

	// Handle setting the zed to uncloaked so the zapped overlay works properly
    if( Level.Netmode != NM_DedicatedServer )
	{
        bUnlit = false;
    	Skins = Default.Skins;

    	if (PlayerShadow != none)
    		PlayerShadow.bShadowActive = true;

    	bAcceptsProjectors = true;
		SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', 999, true);
	}
}

// Turn off the zapped behavior
simulated function UnSetZappedBehavior()
{
    super.UnSetZappedBehavior();

	// Handle getting the zed back cloaked if need be
    if( Level.Netmode != NM_DedicatedServer )
	{
        LastCheckTimes = Level.TimeSeconds;
        SetOverlayMaterial(None, 0.0f, true);
	}
}

// Overridden because we need to handle the overlays differently for zombies that can cloak
function SetZapped(float ZapAmount, Pawn Instigator)
{
    LastZapTime = Level.TimeSeconds;

    if( bZapped )
    {
        TotalZap = ZapThreshold;
        RemainingZap = ZapDuration;
    }
    else
    {
        TotalZap += ZapAmount;

        if( TotalZap >= ZapThreshold )
        {
            RemainingZap = ZapDuration;
              bZapped = true;
        }
    }
    ZappedBy = Instigator;
}

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if( Role < ROLE_Authority )
    {
        return;
    }

	// Difficulty Scaling
	if (Level.Game != none)
	{
        //log(self$" Beginning ground speed "$default.GroundSpeed);

        // If you are playing by yourself,  reduce the MG damage
        if( Level.Game.NumPlayers == 1 )
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                MGDamage = default.MGDamage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                MGDamage = default.MGDamage * 0.75;
            }
            else if( Level.Game.GameDifficulty < 5.0 )
            {
                MGDamage = default.MGDamage * 1.15;
            }
            else // Hardest difficulty
            {
                MGDamage = default.MGDamage * 1.3;
            }
        }
        else
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                MGDamage = default.MGDamage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                MGDamage = default.MGDamage * 1.0;
            }
            else if( Level.Game.GameDifficulty < 5.0 )
            {
                MGDamage = default.MGDamage * 1.15;
            }
            else // Hardest difficulty
            {
                MGDamage = default.MGDamage * 1.3;
            }
        }
	}

	HealingLevels[0] = Health/1.25; // Around 5600 HP
	HealingLevels[1] = Health/2.f; // Around 3500 HP
	HealingLevels[2] = Health/3.2; // Around 2187 HP
//	log("Health = "$Health);
//	log("HealingLevels[0] = "$HealingLevels[0]);
//	log("HealingLevels[1] = "$HealingLevels[1]);
//	log("HealingLevels[2] = "$HealingLevels[2]);

	HealingAmount = Health/4; // 1750 HP
//	log("HealingAmount = "$HealingAmount);
}

function bool MakeGrandEntry()
{
	bShotAnim = true;
	Acceleration = vect(0,0,0);
	SetAnimAction('Entrance');
	HandleWaitForAnim('Entrance');
	GotoState('MakingEntrance');

	return True;
}

// State of playing the initial entrance anim
state MakingEntrance
{
    Ignores RangedAttack;

	function Tick( float Delta )
	{
        Acceleration = vect(0,0,0);

        global.Tick(Delta);
	}

Begin:
    Sleep(GetAnimDuration('Entrance'));
    GotoState('InitialSneak');
}

// State of doing a radial damaging attack that we do when poeple are trying to melee exploit
state RadialAttack
{
    Ignores RangedAttack;

    function bool ShouldChargeFromDamage()
    {
        return false;
    }

	function Tick( float Delta )
	{
        Acceleration = vect(0,0,0);

        //DrawDebugSphere( Location, 150, 12, 0, 255, 0);

        global.Tick(Delta);
	}

    function ClawDamageTarget()
    {
    	local vector PushDir;
    	local float UsedMeleeDamage;
    	local bool bDamagedSomeone, bDamagedThisHit;
    	local KFHumanPawn P;
    	local Actor OldTarget;
    	local float RadialDamageBase;

    	MeleeRange = 150;

    	if(Controller!=none && Controller.Target!=none)
    		PushDir = (damageForce * Normal(Controller.Target.Location - Location));
    	else
    		PushDir = damageForce * vector(Rotation);


		OldTarget = Controller.Target;

        CurrentDamtype = ZombieDamType[0];

		// Damage all players within a radius
        foreach DynamicActors(class'KFHumanPawn', P)
		{
            if ( VSize(P.Location - Location) < MeleeRange)
			{
				Controller.Target = P;

                // This attack cuts through shields, so crank up the damage if they have a lot of shields
                if( P.ShieldStrength >= 50 )
				{
				    RadialDamageBase = 240;
			    }
			    else
			    {
                    RadialDamageBase = 120;
			    }

                // Randomize the damage a bit so everyone gets really hurt, but only some poeple die
                UsedMeleeDamage = (RadialDamageBase - (RadialDamageBase * 0.55)) + (RadialDamageBase * (FRand() * 0.45));
                //log("UsedMeleeDamage = "$UsedMeleeDamage);

				bDamagedThisHit =  MeleeDamageTarget(UsedMeleeDamage, damageForce * Normal(P.Location - Location));
				if( !bDamagedSomeone && bDamagedThisHit )
				{
				    bDamagedSomeone = true;
				}
				MeleeRange = 150;
			}
		}

		Controller.Target = OldTarget;

    	MeleeRange = Default.MeleeRange;


    	if ( bDamagedSomeone )
    	{
    		// Maybe cause zedtime when the patriarch does his radial attack
            KFGameType(Level.Game).DramaticEvent(0.3);
            PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);
    	}
    }

	function EndState()
	{
        NumLumberJacks = 0;
        NumNinjas = 0;
	}

Begin:
	// Don't let the zed move and play the radial attack
    bShotAnim = true;
	Acceleration = vect(0,0,0);
	SetAnimAction('RadialAttack');
	KFMonsterController(Controller).bUseFreezeHack = True;
	HandleWaitForAnim('RadialAttack');
    Sleep(GetAnimDuration('RadialAttack'));
    // TODO: this sleep is here to allow for playing the taunt sound. Take it out when the animation is extended with the taunt - Ramm
	//Sleep(2.5);
    GotoState('');
}

simulated function Destroyed()
{
	if( mTracer!=None )
		mTracer.Destroy();
	if( mMuzzleFlash!=None )
		mMuzzleFlash.Destroy();
	Super.Destroyed();
}

simulated Function PostNetBeginPlay()
{
	EnableChannelNotify ( 1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	super.PostNetBeginPlay();
	TraceHitPos = vect(0,0,0);
	bNetNotify = True;
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
		return;

	if( Damage>=150 || (DamageType.name=='DamTypeStunNade' && rand(5)>3) || (DamageType.name=='DamTypeCrossbowHeadshot' && Damage>=200) )
		PlayDirectionalHit(HitLocation);

	LastPainAnim = Level.TimeSeconds;

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,2*TransientSoundVolume,,400);
}

function bool OnlyEnemyAround( Pawn Other )
{
	local Controller C;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.bIsPlayer && C.Pawn!=None && C.Pawn!=Other && ((VSize(C.Pawn.Location-Location)<1500 && FastTrace(C.Pawn.Location,Location))
		 || (VSize(C.Pawn.Location-Other.Location)<1000 && FastTrace(C.Pawn.Location,Other.Location))) )
			Return False;
	}
	Return True;
}

function bool IsCloseEnuf( Actor A )
{
	local vector V;

	if( A==None )
		Return False;
	V = A.Location-Location;
	if( Abs(V.Z)>(CollisionHeight+A.CollisionHeight) )
		Return False;
	V.Z = 0;
	Return (VSize(V)<(CollisionRadius+A.CollisionRadius+25));
}

function RangedAttack(Actor A)
{
	local float D;
	local bool bOnlyE;
    local bool bDesireChainGun;

    // Randomly make him want to chaingun more
    if( Controller.LineOfSightTo(A) && FRand() < 0.15 && LastChainGunTime<Level.TimeSeconds )
    {
        bDesireChainGun = true;
    }

	if ( bShotAnim )
		return;
	D = VSize(A.Location-Location);
	bOnlyE = (Pawn(A)!=None && OnlyEnemyAround(Pawn(A)));
	if ( IsCloseEnuf(A) )
	{
		bShotAnim = true;
		if( Health>1500 && Pawn(A)!=None && FRand() < 0.5 )
		{
			SetAnimAction('MeleeImpale');
		}
		else
		{
			SetAnimAction('MeleeClaw');
			//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		}
	}
	else if( Level.TimeSeconds - LastSneakedTime > 20.0 )
	{
		if( FRand() < 0.3 )
		{
		    // Wait another 20 to try this again
			LastSneakedTime = Level.TimeSeconds;//+FRand()*120;
			Return;
		}
		SetAnimAction('transition');
		GoToState('SneakAround');
	}
	else if( bChargingPlayer && (bOnlyE || D<200) )
		Return;
	else if( !bDesireChainGun && !bChargingPlayer && (D<300 || (D<700 && bOnlyE)) &&
        (Level.TimeSeconds - LastChargeTime > (5.0 + 5.0 * FRand())) )  // Don't charge again for a few seconds
	{
		SetAnimAction('transition');
		GoToState('Charging');
	}
	else if( LastMissileTime<Level.TimeSeconds && D > 500 )
	{
		if( !Controller.LineOfSightTo(A) || FRand() > 0.75 )
		{
			LastMissileTime = Level.TimeSeconds+FRand() * 5;
			Return;
		}

		LastMissileTime = Level.TimeSeconds + 10 + FRand() * 15;

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('PreFireMissile');

		HandleWaitForAnim('PreFireMissile');

		GoToState('FireMissile');
	}
	else if ( !bWaitForAnim && !bShotAnim && LastChainGunTime<Level.TimeSeconds )
	{
		if ( !Controller.LineOfSightTo(A) || FRand()> 0.85 )
		{
			LastChainGunTime = Level.TimeSeconds+FRand()*4;
			Return;
		}

		LastChainGunTime = Level.TimeSeconds + 5 + FRand() * 10;

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('PreFireMG');

		HandleWaitForAnim('PreFireMG');
		MGFireCounter =  Rand(60) + 35;

		GoToState('FireChaingun');
	}
}

event Bump(actor Other)
{
	Super(Monster).Bump(Other);
	if( Other==none )
		return;

	if( Other.IsA('NetKActor') && Physics != PHYS_Falling && !bShotAnim && Abs(Other.Location.Z-Location.Z)<(CollisionHeight+Other.CollisionHeight) )
	{ // Kill the annoying deco brat.
		Controller.Target = Other;
		Controller.Focus = Other;
		bShotAnim = true;
		Acceleration = (Other.Location-Location);
		SetAnimAction('MeleeClaw');
		//PlaySound(sound'Claw2s', SLOT_None);  KFTODO: Replace this
		HandleWaitForAnim('MeleeClaw');
	}
}

simulated function AddTraceHitFX( vector HitPos )
{
	local vector Start,SpawnVel,SpawnDir;
	local float hitDist;

	Start = GetBoneCoords('tip').Origin;
	if( mTracer==None )
		mTracer = Spawn(Class'KFMod.KFNewTracer',,,Start);
	else mTracer.SetLocation(Start);
	if( mMuzzleFlash==None )
	{
		// KFTODO: Replace this
        mMuzzleFlash = Spawn(Class'MuzzleFlash3rdMG');
		AttachToBone(mMuzzleFlash, 'tip');
	}
	else mMuzzleFlash.SpawnParticle(1);
	hitDist = VSize(HitPos - Start) - 50.f;

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

	if( HitPos != vect(0,0,0) )
	{
        Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(Normal(HitPos - Start)));
    }
}

simulated function AnimEnd( int Channel )
{
	local name  Sequence;
	local float Frame, Rate;

	if( Level.NetMode==NM_Client && bMinigunning )
	{
        GetAnimParams( Channel, Sequence, Frame, Rate );

        if( Sequence != 'PreFireMG' && Sequence != 'FireMG' )
        {
            Super.AnimEnd(Channel);
            return;
        }

		PlayAnim('FireMG');
		bWaitForAnim = true;
		bShotAnim = true;
		IdleTime = Level.TimeSeconds;
	}
	else Super.AnimEnd(Channel);
}

state FireChaingun
{
	function RangedAttack(Actor A)
	{
		Controller.Target = A;
		Controller.Focus = A;
	}

    // Chaingun mode handles this itself
    function bool ShouldChargeFromDamage()
    {
        return false;
    }

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
    {
    	local float EnemyDistSq, DamagerDistSq;

        global.TakeDamage(Damage,instigatedBy,hitlocation,vect(0,0,0),damageType);

        // if someone close up is shooting us, just charge them
        if( InstigatedBy != none )
        {
            DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);

            if( (ChargeDamage > 200 && DamagerDistSq < (500 * 500)) || DamagerDistSq < (100 * 100) )
            {
                SetAnimAction('transition');
        		//log("Frak this shizz, Charging!!!!");
        		GoToState('Charging');
        		return;
    		}
        }

        if( Controller.Enemy != none && InstigatedBy != none && InstigatedBy != Controller.Enemy )
        {
            EnemyDistSq = VSizeSquared(Location - Controller.Enemy.Location);
            DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);
        }

        if( InstigatedBy != none && (DamagerDistSq < EnemyDistSq || Controller.Enemy == none) )
        {
            MonsterController(Controller).ChangeEnemy(InstigatedBy,Controller.CanSee(InstigatedBy));
            Controller.Target = InstigatedBy;
		    Controller.Focus = InstigatedBy;

            if( DamagerDistSq < (500 * 500) )
            {
        		SetAnimAction('transition');
        		GoToState('Charging');
    		}
        }
    }

	function EndState()
	{
        TraceHitPos = vect(0,0,0);
		bMinigunning = False;

        AmbientSound = default.AmbientSound;
        SoundVolume=default.SoundVolume;
        SoundRadius=default.SoundRadius;
        MGFireCounter=0;

        LastChainGunTime = Level.TimeSeconds + 5 + (FRand()*10);
	}

	function BeginState()
	{
        bFireAtWill = False;
		Acceleration = vect(0,0,0);
		MGLostSightTimeout = 0.0;
		bMinigunning = True;
	}

	function AnimEnd( int Channel )
	{
		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}
		else
		{
			if ( Controller.Enemy != none )
			{
				if ( Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('tip').Origin,Controller.Enemy.Location))
				{
					MGLostSightTimeout = 0.0;
                    Controller.Focus = Controller.Enemy;
					Controller.FocalPoint = Controller.Enemy.Location;
				}
				else
                {
                    MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
                    Controller.Focus = None;
                }

				Controller.Target = Controller.Enemy;
			}
			else
			{
                MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
                Controller.Focus = None;
			}

			if( !bFireAtWill )
			{
                MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
			}
			else if ( FRand() < 0.03 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
			{
				// Randomly send out a message about Patriarch shooting chain gun(3% chance)
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
			}

			bFireAtWill = True;
			bShotAnim = true;
			Acceleration = vect(0,0,0);

			SetAnimAction('FireMG');
			bWaitForAnim = true;
		}
	}

	function FireMGShot()
	{
		local vector Start,End,HL,HN,Dir;
		local rotator R;
		local Actor A;

		MGFireCounter--;

        if( AmbientSound != MiniGunFireSound )
        {
            SoundVolume=255;
            SoundRadius=400;
            AmbientSound = MiniGunFireSound;
        }

		Start = GetBoneCoords('tip').Origin;
		if( Controller.Focus!=None )
			R = rotator(Controller.Focus.Location-Start);
		else R = rotator(Controller.FocalPoint-Start);
		if( NeedToTurnFor(R) )
			R = Rotation;
		// KFTODO: Maybe scale this accuracy by his skill or the game difficulty
		Dir = Normal(vector(R)+VRand()*0.06); //*0.04
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
		{
        	A.TakeDamage(MGDamage+Rand(3),Self,HL,Dir*500,Class'DamageType');
		}
	}

	function bool NeedToTurnFor( rotator targ )
	{
		local int YawErr;

		targ.Yaw = DesiredRotation.Yaw & 65535;
		YawErr = (targ.Yaw - (Rotation.Yaw & 65535)) & 65535;
		return !((YawErr < 2000) || (YawErr > 64535));
	}

Begin:
	While( True )
	{
		Acceleration = vect(0,0,0);

        if( MGLostSightTimeout > 0 && Level.TimeSeconds > MGLostSightTimeout )
        {
            bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
        }

		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}

		// Give some randomness to the patriarch's firing
		if( Level.TimeSeconds > MGFireDuration )
		{
            if( AmbientSound != MiniGunSpinSound )
            {
                SoundVolume=185;
                SoundRadius=200;
                AmbientSound = MiniGunSpinSound;
            }
            Sleep(0.5 + FRand() * 0.75);
            MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
		}
		else
		{
            if( bFireAtWill )
    			FireMGShot();
    		Sleep(0.05);
		}
	}
}

state FireMissile
{
Ignores RangedAttack;

    function bool ShouldChargeFromDamage()
    {
        return false;
    }

	function BeginState()
	{
        Acceleration = vect(0,0,0);
	}

	function AnimEnd( int Channel )
	{
		local vector Start;
		local Rotator R;

		Start = GetBoneCoords('tip').Origin;

		if ( !SavedFireProperties.bInitialized )
		{
			SavedFireProperties.AmmoClass = MyAmmo.Class;
			SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
			SavedFireProperties.WarnTargetPct = 0.15;
			SavedFireProperties.MaxRange = 10000;
			SavedFireProperties.bTossed = False;
			SavedFireProperties.bTrySplash = False;
			SavedFireProperties.bLeadTarget = True;
			SavedFireProperties.bInstantHit = True;
			SavedFireProperties.bInitialized = true;
		}

		R = AdjustAim(SavedFireProperties,Start,100);
		PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
		Spawn(Class'BossLAWProj',,,Start,R);

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('FireEndMissile');
		HandleWaitForAnim('FireEndMissile');

		// Randomly send out a message about Patriarch shooting a rocket(5% chance)
		if ( FRand() < 0.05 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
		}

		GoToState('');
	}
Begin:
	while ( true )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.1);
	}
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	if( Controller.Target!=None && Controller.Target.IsA('NetKActor') )
		pushdir = Normal(Controller.Target.Location-Location)*100000; // Fly bitch!

	// Used to set MeleeRange = Default.MeleeRange; in Balance Round 1, fixed in Balance Round 2

	return Super.MeleeDamageTarget(hitdamage, pushdir);
}

state Charging
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

    function bool ShouldChargeFromDamage()
    {
        return false;
    }

	function BeginState()
	{
        bChargingPlayer = True;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		// How many charge attacks we can do randomly 1-3
		NumChargeAttacks = Rand(2) + 1;
	}

	function EndState()
	{
        SetGroundSpeed(GetOriginalGroundSpeed());
		bChargingPlayer = False;
		ChargeDamage = 0;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		LastChargeTime = Level.TimeSeconds;
	}

	function Tick( float Delta )
	{

        if( NumChargeAttacks <= 0 )
        {
            GoToState('');
        }

        // Keep the flesh pound moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim)
    	{
    		if( bChargingPlayer )
    		{
                bChargingPlayer = false;
        		if( Level.NetMode!=NM_DedicatedServer )
        			PostNetReceive();
    		}
            SetGroundSpeed(OriginalGroundSpeed * 1.25);
            if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }
        else
        {
    		if( !bChargingPlayer )
    		{
                bChargingPlayer = true;
        		if( Level.NetMode!=NM_DedicatedServer )
        			PostNetReceive();
    		}

            // Zapping slows him down, but doesn't stop him
            if( bZapped )
            {
                SetGroundSpeed(OriginalGroundSpeed * 1.5);
            }
            else
            {
                SetGroundSpeed(OriginalGroundSpeed * 2.5);
            }
        }


		Global.Tick(Delta);
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal;

        NumChargeAttacks--;

		RetVal = Global.MeleeDamageTarget(hitdamage, pushdir*1.5);
		if( RetVal )
			GoToState('');
		return RetVal;
	}

	function RangedAttack(Actor A)
	{
        if( VSize(A.Location-Location)>700 && Level.TimeSeconds - LastForceChargeTime > 3.0 )
			GoToState('');
		Global.RangedAttack(A);
	}
Begin:
	Sleep(6);
	GoToState('');
}

function BeginHealing()
{
	MonsterController(Controller).WhatToDoNext(55);
}


state Healing // Healing
{
    function bool ShouldChargeFromDamage()
    {
        return false;
    }

Begin:
	Sleep(GetAnimDuration('Heal'));
	GoToState('');
}

state KnockDown // Knocked
{
    function bool ShouldChargeFromDamage()
    {
        return false;
    }

Begin:
    if( Health > 0 )
    {
    	Sleep(GetAnimDuration('KnockDown'));
    	CloakBoss();
    	PlaySound(sound'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe', SLOT_Misc, 2.0,,500.0);
    	if( KFGameType(Level.Game).FinalSquadNum == SyringeCount )
        {
    	   KFGameType(Level.Game).AddBossBuddySquad();
    	}
        GotoState('Escaping');
	}
	else
	{
	   GotoState('');
	}
}

State Escaping extends Charging // Got hurt and running away...
{
	function BeginHealing()
	{
		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('Heal');
		HandleWaitForAnim('Heal');

		GoToState('Healing');
	}

	function RangedAttack(Actor A)
	{
		if ( bShotAnim )
			return;
		else if ( IsCloseEnuf(A) )
		{
			if( bCloaked )
				UnCloakBoss();
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			Acceleration = (A.Location-Location);
			SetAnimAction('MeleeClaw');
			//PlaySound(sound'Claw2s', SLOT_None); Claw2s
		}
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		return Global.MeleeDamageTarget(hitdamage, pushdir*1.5);
	}

	function Tick( float Delta )
	{

        // Keep the flesh pound moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim)
    	{
    		if( bChargingPlayer )
    		{
                bChargingPlayer = false;
        		if( Level.NetMode!=NM_DedicatedServer )
        			PostNetReceive();
    		}
            SetGroundSpeed(GetOriginalGroundSpeed());
        }
        else
        {
    		if( !bChargingPlayer )
    		{
                bChargingPlayer = true;
        		if( Level.NetMode!=NM_DedicatedServer )
        			PostNetReceive();
    		}

            // Zapping slows him down, but doesn't stop him
            if( bZapped )
            {
                SetGroundSpeed(OriginalGroundSpeed * 1.5);
            }
            else
            {
                SetGroundSpeed(OriginalGroundSpeed * 2.5);
            }
        }


		Global.Tick(Delta);
	}

	function EndState()
	{
        SetGroundSpeed(GetOriginalGroundSpeed());
		bChargingPlayer = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
		if( bCloaked )
			UnCloakBoss();
	}

Begin:
	While( true )
	{
		Sleep(0.5);
		if( !bCloaked && !bShotAnim )
			CloakBoss();
		if( !Controller.IsInState('SyrRetreat') && !Controller.IsInState('WaitForAnim'))
			Controller.GoToState('SyrRetreat');
	}
}

State SneakAround extends Escaping // Attempt to sneak around.
{
	function BeginHealing()
	{
		MonsterController(Controller).WhatToDoNext(56);
		GoToState('');
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal;

		RetVal = super.MeleeDamageTarget(hitdamage, pushdir);

		GoToState('');
		return RetVal;
	}

	function BeginState()
	{
	    super.BeginState();
        SneakStartTime = Level.TimeSeconds;
	}

	function EndState()
	{
		super.EndState();
		LastSneakedTime = Level.TimeSeconds;
	}


Begin:
	CloakBoss();
	While( true )
	{
		Sleep(0.5);

		if( Level.TimeSeconds - SneakStartTime > 10.0 )
		{
            GoToState('');
		}

		if( !bCloaked && !bShotAnim )
			CloakBoss();
		if( !Controller.IsInState('ZombieHunt') && !Controller.IsInState('WaitForAnim') )
		{
        	Controller.GoToState('ZombieHunt');
        }
	}
}

State InitialSneak extends SneakAround // Sneak attack the players straight off the bat.
{
Begin:
	CloakBoss();
	While( true )
	{
		Sleep(0.5);
		SneakCount++;

        // Added sneakcount hack to try and fix the endless loop crash. Try and track down what was causing this later - Ramm
		if( SneakCount > 1000 || (Controller != none && BossZombieController(Controller).bAlreadyFoundEnemy) )
		{
            GoToState('');
		}

		if( !bCloaked && !bShotAnim )
			CloakBoss();
		if( !Controller.IsInState('InitialHunting') && !Controller.IsInState('WaitForAnim') )
		{
        	Controller.GoToState('InitialHunting');
        }
	}
}

simulated function DropNeedle()
{
	if( CurrentNeedle!=None )
	{
		DetachFromBone(CurrentNeedle);
		CurrentNeedle.SetLocation(GetBoneCoords('Rpalm_MedAttachment').Origin);
		CurrentNeedle.DroppedNow();
		CurrentNeedle = None;
	}
}
simulated function NotifySyringeA()
{
    //log("Heal Part 1");

	if( Level.NetMode!=NM_Client )
	{
		if( SyringeCount<3 )
			SyringeCount++;
		if( Level.NetMode!=NM_DedicatedServer )
			 PostNetReceive();
	}
	if( Level.NetMode!=NM_DedicatedServer )
	{
		DropNeedle();
		CurrentNeedle = Spawn(Class'BossHPNeedle');
		AttachToBone(CurrentNeedle,'Rpalm_MedAttachment');
	}
}
function NotifySyringeB()
{
    //log("Heal Part 2");
	if( Level.NetMode != NM_Client )
	{
		Health += HealingAmount;
		bHealed = true;
	}
}
simulated function NotifySyringeC()
{
    //log("Heal Part 3");
	if( Level.NetMode!=NM_DedicatedServer && CurrentNeedle!=None )
	{
		CurrentNeedle.Velocity = vect(-45,300,-90) >> Rotation;
		DropNeedle();
	}
}

simulated function PostNetReceive()
{
	if( bClientMiniGunning != bMinigunning )
	{
        bClientMiniGunning = bMinigunning;
        // Hack so Patriarch won't go out of MG Firing to play his idle anim online
        if( bMinigunning )
        {
        	IdleHeavyAnim='FireMG';
        	IdleRifleAnim='FireMG';
        	IdleCrouchAnim='FireMG';
        	IdleWeaponAnim='FireMG';
        	IdleRestAnim='FireMG';
        }
        else
        {
        	IdleHeavyAnim='BossIdle';
        	IdleRifleAnim='BossIdle';
        	IdleCrouchAnim='BossIdle';
        	IdleWeaponAnim='BossIdle';
        	IdleRestAnim='BossIdle';
        }
	}

	if( bClientCharg!=bChargingPlayer )
	{
		bClientCharg = bChargingPlayer;
		if (bChargingPlayer)
		{
			MovementAnims[0] = ChargingAnim;
			MovementAnims[1] = ChargingAnim;
			MovementAnims[2] = ChargingAnim;
			MovementAnims[3] = ChargingAnim;
		}
		else if( !bChargingPlayer )
		{
			MovementAnims[0] = default.MovementAnims[0];
			MovementAnims[1] = default.MovementAnims[1];
			MovementAnims[2] = default.MovementAnims[2];
			MovementAnims[3] = default.MovementAnims[3];
		}
	}
	else if( ClientSyrCount!=SyringeCount )
	{
		ClientSyrCount = SyringeCount;
		Switch( SyringeCount )
		{
			Case 1:
				SetBoneScale(3,0,'Syrange1');
				Break;
			Case 2:
				SetBoneScale(3,0,'Syrange1');
				SetBoneScale(4,0,'Syrange2');
				Break;
			Case 3:
				SetBoneScale(3,0,'Syrange1');
				SetBoneScale(4,0,'Syrange2');
				SetBoneScale(5,0,'Syrange3');
				Break;
			Default: // WTF? reset...?
				SetBoneScale(3,1,'Syrange1');
				SetBoneScale(4,1,'Syrange2');
				SetBoneScale(5,1,'Syrange3');
				Break;
		}
	}
	else if( TraceHitPos!=vect(0,0,0) )
	{
		AddTraceHitFX(TraceHitPos);
		TraceHitPos = vect(0,0,0);
	}
	else if( bClientCloaked!=bCloaked )
	{
		bClientCloaked = bCloaked;
		bCloaked = !bCloaked;
		if( bCloaked )
			UnCloakBoss();
		else CloakBoss();
		bCloaked = bClientCloaked;
	}
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='MeleeImpale' || AnimName=='MeleeClaw' || AnimName=='transition' /*|| AnimName=='FireMG'*/  )
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,, 0.1, 1);
		Return 1;
	}
	else if( AnimName=='RadialAttack' )
	{
		// Get rid of blending, this is a full body anim
        AnimBlendParams(1, 0.0);
    	PlayAnim(AnimName,,0.1);
    	return 0;
	}

	Return Super.DoAnimAction(AnimName);
}


simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;

	if( NewAction=='' )
		Return;
	if(NewAction == 'Claw')
	{
		meleeAnimIndex = Rand(3);
		NewAction = meleeAnims[meleeAnimIndex];
		CurrentDamtype = ZombieDamType[meleeAnimIndex];
	}

	ExpectingChannel = DoAnimAction(NewAction);

    if( Controller != none )
    {
	   BossZombieController(Controller).AnimWaitChannel = ExpectingChannel;
	}

    if( AnimNeedsWait(NewAction) )
    {
        bWaitForAnim = true;
    }
    else
    {
        bWaitForAnim = false;
    }

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;

        ResetAnimActTime = Level.TimeSeconds+0.3;
	}
}

// Hand sending the controller to the WaitForAnim state
simulated function HandleWaitForAnim( name NewAnim )
{
    local float RageAnimDur;

    Controller.GoToState('WaitForAnim');
	RageAnimDur = GetAnimDuration(NewAnim);

    BossZombieController(Controller).SetWaitForAnimTimout(RageAnimDur,NewAnim);
}

// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( /*TestAnim == 'MeleeImpale' || TestAnim =='MeleeClaw' || TestAnim =='transition' ||*/ TestAnim == 'FireMG' ||
        TestAnim == 'PreFireMG' || TestAnim == 'PreFireMissile' || TestAnim == 'FireEndMG'|| TestAnim == 'FireEndMissile' ||
        TestAnim == 'Heal' || TestAnim == 'KnockDown' || TestAnim == 'Entrance' || TestAnim == 'VictoryLaugh' || TestAnim == 'RadialAttack' )
    {
        return true;
    }

    return false;
}

simulated function HandleBumpGlass()
{
}


function bool FlipOver()
{
	Return False;
}

// Return true if we want to charge from taking too much damage
function bool ShouldChargeFromDamage()
{
    // If we don;t want to heal, charge whoever damaged us!!!
    if( (SyringeCount==0 && Health<HealingLevels[0]) || (SyringeCount==1 && Health<HealingLevels[1]) || (SyringeCount==2 && Health<HealingLevels[2]) )
    {
        return false;
    }
    else if( !bChargingPlayer && Level.TimeSeconds - LastForceChargeTime > (5.0 + 5.0 * FRand()) )
    {
        return true;
    }

    return false;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local float DamagerDistSq;
	local float UsedPipeBombDamScale;
	local KFHumanPawn P;
	local int NumPlayersSurrounding;
	local bool bDidRadialAttack;

    //log(GetStateName()$" Took damage. Health="$Health$" Damage = "$Damage$" HealingLevels "$HealingLevels[SyringeCount]);

    // Check for melee exploiters trying to surround the patriarch
    if( Level.TimeSeconds - LastMeleeExploitCheckTime > 1.0 && (class<DamTypeMelee>(damageType) != none
        || class<KFProjectileWeaponDamageType>(damageType) != none) )
    {
        LastMeleeExploitCheckTime = Level.TimeSeconds;
        NumLumberJacks = 0;
        NumNinjas = 0;

		foreach DynamicActors(class'KFHumanPawn', P)
		{
            // look for guys attacking us within 3 meters
            if ( VSize(P.Location - Location) < 150 )
			{
				NumPlayersSurrounding++;

                if( P != none && P.Weapon != none )
                {
                    if( Axe(P.Weapon) != none || Chainsaw(P.Weapon) != none )
                    {
                        NumLumberJacks++;
                    }
                    else if( Katana(P.Weapon) != none )
                    {
                        NumNinjas++;
                    }
                }

				if( !bDidRadialAttack && NumPlayersSurrounding >= 3 )
				{
                    bDidRadialAttack = true;
                    GotoState('RadialAttack');
                    break;
                }
			}
		}
    }

    if ( class<DamTypeCrossbow>(damageType) == none && class<DamTypeCrossbowHeadShot>(damageType) == none )
    {
    	bOnlyDamagedByCrossbow = false;
    }

    // Scale damage from the pipebomb down a bit if lots of pipe bomb damage happens
    // at around the same times. Prevent players from putting all thier pipe bombs
    // in one place and owning the patriarch in one blow.
	if ( class<DamTypePipeBomb>(damageType) != none )
	{
	   UsedPipeBombDamScale = FMax(0,(1.0 - PipeBombDamageScale));

	   PipeBombDamageScale += 0.075;

	   if( PipeBombDamageScale > 1.0 )
	   {
	       PipeBombDamageScale = 1.0;
	   }

	   Damage *= UsedPipeBombDamScale;
	}

    Super.TakeDamage(Damage,instigatedBy,hitlocation,Momentum,damageType);

    if( Level.TimeSeconds - LastDamageTime > 10 )
    {
        ChargeDamage = 0;
    }
    else
    {
        LastDamageTime = Level.TimeSeconds;
        ChargeDamage += Damage;
    }

    if( ShouldChargeFromDamage() && ChargeDamage > 200 )
    {
        // If someone close up is shooting us, just charge them
        if( InstigatedBy != none )
        {
            DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);

            if( DamagerDistSq < (700 * 700) )
            {
                SetAnimAction('transition');
        		ChargeDamage=0;
        		LastForceChargeTime = Level.TimeSeconds;
        		GoToState('Charging');
        		return;
    		}
        }
    }

	if( Health<=0 || SyringeCount==3 || IsInState('Escaping') || IsInState('KnockDown') || IsInState('RadialAttack') || bDidRadialAttack/*|| bShotAnim*/ )
		Return;

	if( (SyringeCount==0 && Health<HealingLevels[0]) || (SyringeCount==1 && Health<HealingLevels[1]) || (SyringeCount==2 && Health<HealingLevels[2]) )
	{
	    //log(GetStateName()$" Took damage and want to heal!!! Health="$Health$" HealingLevels "$HealingLevels[SyringeCount]);

    	bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('KnockDown');
		HandleWaitForAnim('KnockDown');
		KFMonsterController(Controller).bUseFreezeHack = True;
		GoToState('KnockDown');
	}
}

function DoorAttack(Actor A)
{
	if ( bShotAnim )
		return;
	else if ( A!=None )
	{
		Controller.Target = A;
		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('PreFireMissile');
		HandleWaitForAnim('PreFireMissile');
		GoToState('FireMissile');
	}
}
function RemoveHead();
function PlayDirectionalHit(Vector HitLoc);
function bool SameSpeciesAs(Pawn P)
{
	return False;
}

// Creapy endgame camera when the evil wins.
function bool SetBossLaught()
{
	local Controller C;

	GoToState('');
	bShotAnim = true;
	Acceleration = vect(0,0,0);
	SetAnimAction('VictoryLaugh');
	HandleWaitForAnim('VictoryLaugh');
	bIsBossView = True;
	bSpecialCalcView = True;
	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( PlayerController(C)!=None )
		{
			PlayerController(C).SetViewTarget(Self);
			PlayerController(C).ClientSetViewTarget(Self);
			PlayerController(C).ClientSetBehindView(True);
		}
	}
	Return True;
}
simulated function bool SpectatorSpecialCalcView(PlayerController Viewer, out Actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	Viewer.bBehindView = True;
	ViewActor = Self;
	CameraRotation.Yaw = Rotation.Yaw-32768;
	CameraRotation.Pitch = 0;
	CameraRotation.Roll = Rotation.Roll;
	CameraLocation = Location + (vect(80,0,80) >> Rotation);
	Return True;
}

// Overridden to do a cool slomo death view of the patriarch dying
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Controller C;

    super.Died(Killer,damageType,HitLocation);

    KFGameType(Level.Game).DoBossDeath();

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( PlayerController(C)!=None )
		{
			PlayerController(C).SetViewTarget(Self);
			PlayerController(C).ClientSetViewTarget(Self);
			PlayerController(C).bBehindView = true;
			PlayerController(C).ClientSetBehindView(True);
		}
	}
}

function ClawDamageTarget()
{
	local vector PushDir;
	local name Anim;
	local float frame,rate;
	local float UsedMeleeDamage;
	local bool bDamagedSomeone;
	local KFHumanPawn P;
	local Actor OldTarget;

	if( MeleeDamage > 1 )
	{
		UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
	}
	else
	{
		UsedMeleeDamage = MeleeDamage;
	}

	GetAnimParams(1, Anim,frame,rate);

	if( Anim == 'MeleeImpale' )
	{
		MeleeRange = ImpaleMeleeDamageRange;
	}
	else
	{
		MeleeRange = ClawMeleeDamageRange;
	}

	if(Controller!=none && Controller.Target!=none)
		PushDir = (damageForce * Normal(Controller.Target.Location - Location));
	else
		PushDir = damageForce * vector(Rotation);

// Begin Balance Round 1(damages everyone in Round 2 and added seperate code path for MeleeImpale in Round 3)
	if( Anim == 'MeleeImpale' )
	{
		bDamagedSomeone = MeleeDamageTarget(UsedMeleeDamage, PushDir);
	}
	else
	{
		OldTarget = Controller.Target;

		foreach DynamicActors(class'KFHumanPawn', P)
		{
			if ( (P.Location - Location) dot PushDir > 0.0 ) // Added dot Product check in Balance Round 3
			{
				Controller.Target = P;
				bDamagedSomeone = bDamagedSomeone || MeleeDamageTarget(UsedMeleeDamage, damageForce * Normal(P.Location - Location)); // Always pushing players away added in Balance Round 3
			}
		}

		Controller.Target = OldTarget;
	}

	MeleeRange = Default.MeleeRange;
// End Balance Round 1, 2, and 3

	if ( bDamagedSomeone )
	{
		if( Anim == 'MeleeImpale' )
		{
			PlaySound(MeleeImpaleHitSound, SLOT_Interact, 2.0);
		}
		else
		{
			PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);
		}
	}
}

simulated function ProcessHitFX()
{
    local Coords boneCoords;
	local class<xEmitter> HitEffects[4];
	local int i,j;
    local float GibPerterbation;

    if( (Level.NetMode == NM_DedicatedServer) || bSkeletized || (Mesh == SkeletonMesh))
    {
		SimHitFxTicker = HitFxTicker;
        return;
    }

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
		j++;
		if ( j > 30 )
		{
			SimHitFxTicker = HitFxTicker;
			return;
		}

        if( (HitFX[SimHitFxTicker].damtype == None) || (Level.bDropDetail && (Level.TimeSeconds - LastRenderTime > 3) && !IsHumanControlled()) )
            continue;

		//log("Processing effects for damtype "$HitFX[SimHitFxTicker].damtype);

		if( HitFX[SimHitFxTicker].bone == 'obliterate' && !class'GameInfo'.static.UseLowGore())
		{
			SpawnGibs( HitFX[SimHitFxTicker].rotDir, 1);
			bGibbed = true;
			Destroy();
			return;
		}

        boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

        if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore() )
        {
            //AttachEmitterEffect( BleedingEmitterClass, HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

			HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

			if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
			{
				for( i = 0; i < ArrayCount(HitEffects); i++ )
				{
					if( HitEffects[i] == None )
						continue;

					  AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
				}
			}
		}
        if ( class'GameInfo'.static.UseLowGore() )
			HitFX[SimHitFxTicker].bSever = false;

        if( HitFX[SimHitFxTicker].bSever )
        {
            GibPerterbation = HitFX[SimHitFxTicker].damtype.default.GibPerterbation;

            switch( HitFX[SimHitFxTicker].bone )
            {
                case 'obliterate':
                    break;

                case LeftThighBone:
                	if( !bLeftLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bLeftLegGibbed=true;
                    }
                    break;

                case RightThighBone:
                	if( !bRightLegGibbed )
					{
	                    SpawnSeveredGiblet( DetachedLegClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightLegGibbed=true;
                    }
                    break;

                case LeftFArmBone:
                	if( !bLeftArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedSpecialArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;;
	                    bLeftArmGibbed=true;
                    }
                    break;

                case RightFArmBone:
                	if( !bRightArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
	                    bRightArmGibbed=true;
                    }
                    break;

                case 'head':
                    if( !bHeadGibbed )
                    {
                        if ( HitFX[SimHitFxTicker].damtype == class'DamTypeDecapitation' )
                        {
                            DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false);
                        }
						else if( HitFX[SimHitFxTicker].damtype == class'DamTypeProjectileDecap' )
						{
							DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, false, true);
						}
                        else if( HitFX[SimHitFxTicker].damtype == class'DamTypeMeleeDecapitation' )
                        {
                            DecapFX( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, true);
                        }

                      	bHeadGibbed=true;
                  	}
                    break;
            }


			if( HitFX[SimHitFXTicker].bone != 'Spine' && HitFX[SimHitFXTicker].bone != FireRootBone &&
                HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
            	HideBone(HitFX[SimHitFxTicker].bone);
        }
    }
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
/*
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.patriarch_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.patriarch_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.patriarch_D');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Diff');
    myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Spec');
    */
 }

defaultproperties
{
     EventClasses(0)="KFChar.ZombieBoss"
     EventClasses(1)="KFChar.ZombieBoss"
     EventClasses(2)="KFChar.ZombieBoss_HALLOWEEN"
     EventClasses(3)="KFChar.ZombieBoss_XMAS"
     DetachedArmClass=Class'KFChar.SeveredArmPatriarch'
     DetachedLegClass=Class'KFChar.SeveredLegPatriarch'
     DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch'
     DetachedSpecialArmClass=Class'KFChar.SeveredRocketArmPatriarch'
     ControllerClass=Class'KFChar.BossZombieController'
}
