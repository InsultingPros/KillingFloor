// Zombie Monster for KF Invasion gametype
class ZombieSiren extends ZombieSirenBase;

//----------------------------------------------------------------------------
// NOTE: All Variables are declared in the base class to eliminate hitching
//----------------------------------------------------------------------------

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

simulated function bool AnimNeedsWait(name TestAnim)
{
    return false;
}

function bool FlipOver()
{
	Return False;
}
function DoorAttack(Actor A)
{
	if ( bShotAnim || Physics == PHYS_Swimming || bDecapitated || A==None )
		return;
	bShotAnim = true;
	SetAnimAction('Siren_Scream');
}
function RangedAttack(Actor A)
{
	local int LastFireTime;
	local float Dist;

	if ( bShotAnim )
		return;

    Dist = VSize(A.Location - Location);

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
	}
	else if ( Dist < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if( Dist <= ScreamRadius && !bDecapitated && !bZapped )
	{
		bShotAnim=true;
		SetAnimAction('Siren_Scream');
		// Only stop moving if we are close
		if( Dist < ScreamRadius * 0.25 )
		{
    		Controller.bPreparingMove = true;
    		Acceleration = vect(0,0,0);
        }
        else
        {
            Acceleration = AccelRate * Normal(A.Location - Location);
        }
	}
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='Siren_Scream' || AnimName=='Siren_Bite' || AnimName=='Siren_Bite2' )
	{
		AnimBlendParams(1, 1.0, 0.0,, SpineBone1);
		PlayAnim(AnimName,, 0.1, 1);
		return 1;
	}

	PlayAnim(AnimName,,0.1);
	Return 0;
}

// Scream Time
simulated function SpawnTwoShots()
{
    if( bZapped )
    {
        return;
    }

    DoShakeEffect();

	if( Level.NetMode!=NM_Client )
	{
		// Deal Actual Damage.
		if( Controller!=None && KFDoorMover(Controller.Target)!=None )
			Controller.Target.TakeDamage(ScreamDamage*0.6,Self,Location,vect(0,0,0),ScreamDamageType);
		else HurtRadius(ScreamDamage ,ScreamRadius, ScreamDamageType, ScreamForce, Location);
	}
}

// Shake nearby players screens
simulated function DoShakeEffect()
{
	local PlayerController PC;
	local float Dist, scale, BlurScale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < ScreamRadius )
			{
				scale = (ScreamRadius - Dist) / (ScreamRadius);
                scale *= ShakeEffectScalar;
                BlurScale = scale;

                // Reduce blur if there is something between us and the siren
                if( !FastTrace(PC.ViewTarget.Location,Location) )
                {
                    scale *= 0.25;
                    BlurScale = scale;
                }
                else
                {
                    scale = Lerp(scale,MinShakeEffectScale,1.0);
                }

                PC.SetAmbientShake(Level.TimeSeconds + ShakeFadeTime, ShakeTime, OffsetMag * Scale, OffsetRate, RotMag * Scale, RotRate);

                if( KFHumanPawn(PC.ViewTarget) != none )
                {
                    KFHumanPawn(PC.ViewTarget).AddBlur(ShakeTime, BlurScale * ScreamBlurScale);
                }

				// 10% chance of player saying something about our scream
				if ( Level != none && Level.Game != none && !KFGameType(Level.Game).bDidSirenScreamMessage && FRand() < 0.10 )
				{
					PC.Speech('AUTO', 16, "");
					KFGameType(Level.Game).bDidSirenScreamMessage = true;
				}
			}
		}
	}
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local float UsedDamageAmount;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		// Or Karma actors in this case. Self inflicted Death due to flying chairs is uncool for a zombie of your stature.
		if( (Victims != self) && !Victims.IsA('FluidSurfaceInfo') && !Victims.IsA('KFMonster') && !Victims.IsA('ExtendedZCollision') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if (!Victims.IsA('KFHumanPawn')) // If it aint human, don't pull the vortex crap on it.
				Momentum = 0;

			if (Victims.IsA('KFGlassMover'))   // Hack for shattering in interesting ways.
			{
				UsedDamageAmount = 100000; // Siren always shatters glass
			}
			else
			{
                UsedDamageAmount = DamageAmount;
			}

			Victims.TakeDamage(damageScale * UsedDamageAmount,Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);

            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(UsedDamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;
}

// When siren loses her head she's got nothin' Kill her.

function RemoveHead()
{
	Super.RemoveHead();
	if( FRand()<0.5 )
		KilledBy(LastDamagedBy);
	else
	{
		bAboutToDie = True;
		MeleeRange = -500;
		DeathTimer = Level.TimeSeconds+10*FRand();
	}
}

simulated function Tick( float Delta )
{
	Super.Tick(Delta);
	if( bAboutToDie && Level.TimeSeconds>DeathTimer )
	{
		if( Health>0 && Level.NetMode!=NM_Client )
			KilledBy(LastDamagedBy);
		bAboutToDie = False;
	}

	if( Role == ROLE_Authority )
	{
        if( bShotAnim )
        {
            SetGroundSpeed(GetOriginalGroundSpeed() * 0.65);

    		if( LookTarget!=None )
    		{
    		    Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
		}
		else
		{
            SetGroundSpeed(GetOriginalGroundSpeed());
		}
    }
}

function PlayDyingSound()
{
	if( !bAboutToDie )
		Super.PlayDyingSound();
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

        if ( !Level.bDropDetail && !class'GameInfo'.static.NoBlood() && !bSkeletized && !class'GameInfo'.static.UseLowGore())
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
                    break;

                case RightFArmBone:
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
                HitFX[SimHitFXTicker].bone != LeftFArmBone && HitFX[SimHitFXTicker].bone != RightFArmBone &&
                HitFX[SimHitFXTicker].bone != 'head' && Health <=0 )
            	HideBone(HitFX[SimHitFxTicker].bone);
        }
    }
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.siren_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.siren_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.siren_diffuse');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.siren_hair');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.siren_hair_fb');
}

defaultproperties
{
     EventClasses(0)="KFChar.ZombieSiren"
     EventClasses(1)="KFChar.ZombieSiren"
     EventClasses(2)="KFChar.ZombieSiren_HALLOWEEN"
     EventClasses(3)="KFChar.ZombieSiren_XMAS"
     DetachedLegClass=Class'KFChar.SeveredLegSiren'
     DetachedHeadClass=Class'KFChar.SeveredHeadSiren'
     ControllerClass=Class'KFChar.SirenZombieController'
}
