// Chainsaw Zombie Monster for KF Invasion gametype
// He's not quite as speedy as the other Zombies, But his attacks are TRULY damaging.
class ZombieScrake extends ZombieScrakeBase;

#exec OBJ LOAD FILE=PlayerSounds.uax

//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------

simulated function PostNetBeginPlay()
{
	EnableChannelNotify ( 1,1);
	AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
	super.PostNetBeginPlay();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SpawnExhaustEmitter();
}
// Make the scrakes's ambient scale higher, since there are just a few, and thier chainsaw need to be heard from a distance
simulated function CalcAmbientRelevancyScale()
{
        // Make the zed only relevant by thier ambient sound out to a range of 30 meters
    	CustomAmbientRelevancyScale = 1500/(100 * SoundRadius);
}

simulated function PostNetReceive()
{
	if (bCharging)
		MovementAnims[0]='ChargeF';
	else if( !(bCrispified && bBurnified) )
        MovementAnims[0]=default.MovementAnims[0];
}

// This zed has been taken control of. Boost its health and speed
function SetMindControlled(bool bNewMindControlled)
{
    if( bNewMindControlled )
    {
        NumZCDHits++;

        // if we hit him a couple of times, make him rage!
        if( NumZCDHits > 1 )
        {
            if( !IsInState('RunningToMarker') )
            {
                GotoState('RunningToMarker');
            }
            else
            {
                NumZCDHits = 1;
                if( IsInState('RunningToMarker') )
                {
                    GotoState('');
                }
            }
        }
        else
        {
            if( IsInState('RunningToMarker') )
            {
                GotoState('');
            }
        }

        if( bNewMindControlled != bZedUnderControl )
        {
            SetGroundSpeed(OriginalGroundSpeed * 1.25);
    		Health *= 1.25;
    		HealthMax *= 1.25;
		}
    }
    else
    {
        NumZCDHits=0;
    }

    bZedUnderControl = bNewMindControlled;
}

// Handle the zed being commanded to move to a new location
function GivenNewMarker()
{
    if( bCharging && NumZCDHits > 1  )
    {
        GotoState('RunningToMarker');
    }
    else
    {
        GotoState('');
    }
}

simulated function SetBurningBehavior()
{
    // If we're burning stop charging
    if( Role == Role_Authority && IsInState('RunningState') )
			{
        super.SetBurningBehavior();
        GotoState('');
			}

    super.SetBurningBehavior();
}

simulated function SpawnExhaustEmitter()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( ExhaustEffectClass != none )
		{
			ExhaustEffect = Spawn(ExhaustEffectClass, self);

			if ( ExhaustEffect != none )
			{
				AttachToBone(ExhaustEffect, 'Chainsaw_lod1');
				ExhaustEffect.SetRelativeLocation(vect(0, -20, 0));
			}
		}
	}
}

simulated function UpdateExhaustEmitter()
{
	local byte Throttle;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( ExhaustEffect != none )
		{
			if ( bShotAnim )
			{
				Throttle = 3;
			}
			else
			{
				Throttle = 0;
			}
		}
		else
		{
			if ( !bNoExhaustRespawn )
			{
				SpawnExhaustEmitter();
			}
		}
	}
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	UpdateExhaustEmitter();
}

function RangedAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	else if ( CanAttack(A) )
	{
		bShotAnim = true;
		SetAnimAction(MeleeAnims[Rand(2)]);
		CurrentDamType = ZombieDamType[0];
		//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		GoToState('SawingLoop');
	}

	if( !bShotAnim && !bDecapitated )
	{
		if ( Level.Game.GameDifficulty < 5.0 )
		{
			if ( float(Health)/HealthMax < 0.5 )
				GoToState('RunningState');
		}
		else
		{
			if ( float(Health)/HealthMax < 0.75 ) // Changed Rage Point from 0.5 to 0.75 in Balance Round 1(applied to only Suicidal and HoE in Round 7)
				GoToState('RunningState');
		}
	}
}

state RunningState
{
    // Set the zed to the zapped behavior
    simulated function SetZappedBehavior()
    {
        Global.SetZappedBehavior();
        GoToState('');
    }

	// Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
		if( bZapped )
        {
            GoToState('');
        }
        else
        {
    		SetGroundSpeed(OriginalGroundSpeed * 3.5);
    		bCharging = true;
    		if( Level.NetMode!=NM_DedicatedServer )
    			PostNetReceive();

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

	function EndState()
	{
		if( !bZapped )
		{
            SetGroundSpeed(GetOriginalGroundSpeed());
        }
		bCharging = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
	}

	function RemoveHead()
	{
		GoToState('');
		Global.RemoveHead();
	}

    function RangedAttack(Actor A)
    {
    	if ( bShotAnim || Physics == PHYS_Swimming)
    		return;
    	else if ( CanAttack(A) )
    	{
    		bShotAnim = true;
    		SetAnimAction(MeleeAnims[Rand(2)]);
    		CurrentDamType = ZombieDamType[0];
    		GoToState('SawingLoop');
    	}
    }
}

// State where the zed is charging to a marked location.
// Not sure if we need this since its just like RageCharging,
// but keeping it here for now in case we need to implement some
// custom behavior for this state
state RunningToMarker extends RunningState
{
}


State SawingLoop
{
	// Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

    function bool CanGetOutOfWay()
    {
        return false;
    }

	function BeginState()
	{
        local float ChargeChance, RagingChargeChance;

        // Decide what chance the scrake has of charging during an attack
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.25;
            RagingChargeChance = 0.5;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.5;
            RagingChargeChance = 0.70;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            ChargeChance = 0.65;
            RagingChargeChance = 0.85;
        }
        else // Hardest difficulty
        {
            ChargeChance = 0.95;
            RagingChargeChance = 1.0;
        }

        // Randomly have the scrake charge during an attack so it will be less predictable
        if( (Health/HealthMax < 0.5 && FRand() <= RagingChargeChance ) || FRand() <= ChargeChance )
		{
            SetGroundSpeed(OriginalGroundSpeed * AttackChargeRate);
    		bCharging = true;
    		if( Level.NetMode!=NM_DedicatedServer )
    			PostNetReceive();

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

	function RangedAttack(Actor A)
	{
		if ( bShotAnim )
			return;
		else if ( CanAttack(A) )
		{
			Acceleration = vect(0,0,0);
			bShotAnim = true;
			MeleeDamage = default.MeleeDamage*0.6;
			SetAnimAction('SawImpaleLoop');
			CurrentDamType = ZombieDamType[0];
			if( AmbientSound != SawAttackLoopSound )
			{
                AmbientSound=SawAttackLoopSound;
			}
		}
		else GoToState('');
	}
	function AnimEnd( int Channel )
	{
		Super.AnimEnd(Channel);
		if( Controller!=None && Controller.Enemy!=None )
			RangedAttack(Controller.Enemy); // Keep on attacking if possible.
	}

	function Tick( float Delta )
	{
        // Keep the scrake moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
    	{
    		if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }

		global.Tick(Delta);
	}

	function EndState()
	{
		AmbientSound=default.AmbientSound;
		MeleeDamage= default.MeleeDamage;

		SetGroundSpeed(GetOriginalGroundSpeed());
		bCharging = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
	}
}

// Added in Balance Round 1 to reduce the headshot damage taken from Crossbows
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local bool bIsHeadShot;

	bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

	if ( Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && (class<DamTypeCrossbow>(damageType) != none || class<DamTypeCrossbowHeadShot>(damageType) != none) )
	{
		Damage *= 0.5; // Was 0.5 in Balance Round 1, then 0.6 in Round 2, back to 0.5 in Round 3
	}

	Super.takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType, HitIndex);

	// Added in Balance Round 3 to make the Scrake "Rage" more reliably when his health gets low(limited to Suicidal and HoE in Round 7)
	if ( Level.Game.GameDifficulty >= 5.0 && !IsInState('SawingLoop') && !IsInState('RunningState') && float(Health) / HealthMax < 0.75 )
		RangedAttack(InstigatedBy);
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	local int StunChance;

	StunChance = rand(5);

	if( Level.TimeSeconds - LastPainAnim < MinTimeBetweenPainAnims )
		return;

	if( (Level.Game.GameDifficulty < 5.0 || StunsRemaining != 0) && (Damage>=150 || (DamageType.name=='DamTypeStunNade' && StunChance>3) || (DamageType.name=='DamTypeCrossbowHeadshot' && Damage>=200)) )
		PlayDirectionalHit(HitLocation);

	LastPainAnim = Level.TimeSeconds;

	if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
		return;

	LastPainSound = Level.TimeSeconds;
	PlaySound(HitSound[0], SLOT_Pain,1.25,,400);
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='SawZombieAttack1' || AnimName=='SawZombieAttack2' )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim(AnimName,, 0.1, 1);
		Return 1;
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

    if( AnimNeedsWait(NewAction) )
    {
        bWaitForAnim = true;
    }

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;
		ResetAnimActTime = Level.TimeSeconds+0.3;
	}
}

// The animation is full body and should set the bWaitForAnim flag
simulated function bool AnimNeedsWait(name TestAnim)
{
    if( TestAnim == 'SawImpaleLoop' || TestAnim == 'DoorBash' )
    {
        return true;
    }

    return false;
}

function PlayDyingSound()
{
	if( Level.NetMode!=NM_Client )
	{
    	if ( bGibbed )
    	{
            // Do nothing for now
    		PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.0,true,525);
    		return;
    	}

        if( bDecapitated )
        {

            PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
    	}
    	else
    	{
            PlaySound(DeathSound[0], SLOT_Pain,1.30,true,525);
    	}

    	PlaySound(ChainSawOffSound, SLOT_Misc, 2.0,,525.0);
	}
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    AmbientSound = none;

	if ( ExhaustEffect != none )
	{
		ExhaustEffect.Destroy();
    	ExhaustEffect = none;
    	bNoExhaustRespawn = true;
    }

    super.Died( Killer, damageType, HitLocation );
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
	                    SpawnSeveredGiblet( DetachedArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
                		KFSpawnGiblet( class 'KFMod.KFGibBrain',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;
                		KFSpawnGiblet( class 'KFMod.KFGibBrainb',boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, 250 ) ;;
	                    bLeftArmGibbed=true;
                    }
                    break;

                case RightFArmBone:
                	if( !bRightArmGibbed )
					{
	                    SpawnSeveredGiblet( DetachedSpecialArmClass, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir, GibPerterbation, GetBoneRotation(HitFX[SimHitFxTicker].bone) );
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

// Maybe spawn some chunks when the player gets obliterated
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
    if ( ExhaustEffect != none )
    {
		ExhaustEffect.Destroy();
    	ExhaustEffect = none;
    	bNoExhaustRespawn = true;
    }

    super.SpawnGibs(HitRotation,ChunkPerterbation);
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.scrake_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.scrake_diff');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.scrake_spec');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.scrake_saw_panner');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.scrake_FB');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.Chainsaw_blade_diff');
}

defaultproperties
{
     EventClasses(0)="KFChar.ZombieScrake"
     EventClasses(1)="KFChar.ZombieScrake"
     EventClasses(2)="KFChar.ZombieScrake_HALLOWEEN"
     EventClasses(3)="KFChar.ZombieScrake_XMAS"
     DetachedArmClass=Class'KFChar.SeveredArmScrake'
     DetachedLegClass=Class'KFChar.SeveredLegScrake'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw'
     ControllerClass=Class'KFChar.SawZombieController'
}
