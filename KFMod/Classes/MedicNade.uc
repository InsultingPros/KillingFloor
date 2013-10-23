//=============================================================================
// MedicNade
//=============================================================================
// Medic grenade that heals friends and hurts enemies
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive
// Author - John "Ramm-Jaeger" Gibson
//=============================================================================
class MedicNade extends Nade;

#exec OBJ LOAD FILE=KF_GrenadeSnd.uax
#exec OBJ LOAD FILE=Inf_WeaponsTwo.uax
#exec OBJ LOAD FILE=KF_LAWSnd.uax

var()   int     HealBoostAmount;// How much we heal a player by default with the medic nade

var     int     TotalHeals;     // The total number of times this nade has healed (or hurt enemies)
var()   int     MaxHeals;       // The total number of times this nade will heal (or hurt enemies) until its done healing
var     float   NextHealTime;   // The next time that this nade will heal friendlies or hurt enemies
var()   float   HealInterval;   // How often to do healing

var()   sound   ExplosionSound; // The sound of the rocket exploding

var localized   string  SuccessfulHealMessage;

var 	int		MaxNumberOfPlayers;

var     bool    bNeedToPlayEffects; // Whether or not effects have been played yet

replication
{
    reliable if (Role==ROLE_Authority)
        bNeedToPlayEffects;
}

simulated function PostNetReceive()
{
    super.PostNetReceive();
    if( !bHasExploded && bNeedToPlayEffects )
    {
        bNeedToPlayEffects = false;
        Explode(Location, vect(0,0,1));
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;
	BlowUp(HitLocation);

	PlaySound(ExplosionSound,,TransientSoundVolume);

	if( Role == ROLE_Authority )
	{
        bNeedToPlayEffects = true;
        AmbientSound=Sound'Inf_WeaponsTwo.smoke_loop';
	}

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.KFNadeHealing',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

function Timer()
{
    if( !bHidden )
    {
        if( !bHasExploded )
        {
            Explode(Location, vect(0,0,1));
        }
    }
    else if( bDisintegrated )
    {
        AmbientSound=none;
        Destroy();
    }
}

simulated function BlowUp(vector HitLocation)
{
	HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

function HealOrHurt(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local actor Victims;
	local float damageScale;
	local vector dir;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	// Healing
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local float HealSum; // for modifying based on perks
	local int PlayersHealed;

	if ( bHurtEntry )
		return;

    NextHealTime = Level.TimeSeconds + HealInterval;

	bHurtEntry = true;

	if( Fear != none )
	{
		Fear.StartleBots();
	}

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
		{
			if( (Instigator==None || Instigator.Health<=0) && KFPawn(Victims)!=None )
				Continue;

			damageScale = 1.0;

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
			else
			{
                continue;
			}

            if( KFP == none )
            {
    			//log(Level.TimeSeconds@"Hurting "$Victims$" for "$(damageScale * DamageAmount)$" damage");

    			if( Pawn(Victims) != none && Pawn(Victims).Health > 0 )
    			{
                    Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius)
        			 * dir,(damageScale * Momentum * dir),DamageType);

        			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
                    {
                        NumKilled++;
                    }
                }
			}
			else
			{
                if( Instigator != none && KFP.Health > 0 && KFP.Health < KFP.HealthMax )
                {
	                if ( KFP.bCanBeHealed )
					{
						PlayersHealed += 1;
	            		MedicReward = HealBoostAmount;

	            		PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

	            		if ( PRI != none && PRI.ClientVeteranSkill != none )
	            		{
	            			MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
	            		}

	                    HealSum = MedicReward;

	            		if ( (KFP.Health + KFP.healthToGive + MedicReward) > KFP.HealthMax )
	            		{
	                        MedicReward = KFP.HealthMax - (KFP.Health + KFP.healthToGive);
	            			if ( MedicReward < 0 )
	            			{
	            				MedicReward = 0;
	            			}
	            		}

	                    //log(Level.TimeSeconds@"Healing "$KFP$" for "$HealSum$" base healamount "$HealBoostAmount$" health");
	                    KFP.GiveHealth(HealSum, KFP.HealthMax);

	             		if ( PRI != None )
	            		{
	            			if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
	            			{
	            				KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward, false, true);
	            			}

	                        // Give the medic reward money as a percentage of how much of the person's health they healed
	            			MedicReward = int((FMin(float(MedicReward),KFP.HealthMax)/KFP.HealthMax) * 60);

	            			PRI.ReceiveRewardForHealing( MedicReward, KFP );

	            			if ( KFHumanPawn(Instigator) != none )
	            			{
	            				KFHumanPawn(Instigator).AlphaAmount = 255;
	            			}

	                        if( PlayerController(Instigator.Controller) != none )
	                        {
	                            PlayerController(Instigator.Controller).ClientMessage(SuccessfulHealMessage$KFP.GetPlayerName(), 'CriticalEvent');
	                        }
	            		}
            		}
                }
			}

			KFP = none;
        }

		if (PlayersHealed >= MaxNumberOfPlayers)
		{
			if (PRI != none)
			{
        		KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).HealedTeamWithMedicGrenade();
			}
		}
	}

	bHurtEntry = false;
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
	}
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
        Timer();
        SetTimer(0.0,False);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);

		if( Fear == none )
		{
		    //(jc) Changed to use MedicNade-specific grenade that's overridden to not make the ringmaster fear it
		    Fear = Spawn(class'AvoidMarker_MedicNade');
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

function Tick( float DeltaTime )
{
    if( Role < ROLE_Authority )
    {
        return;
    }

//	if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
//	{
//        DrawDebugSphere( Location, DamageRadius, 12, 255, 0, 0);
//    }

    if( TotalHeals < MaxHeals && NextHealTime > 0 &&  NextHealTime < Level.TimeSeconds )
    {
        TotalHeals += 1;

        HealOrHurt(Damage,DamageRadius, MyDamageType, MomentumTransfer, Location);

        if( TotalHeals >= MaxHeals )
        {
            AmbientSound=none;
        }
    }
}

defaultproperties
{
     HealBoostAmount=10
     MaxHeals=8
     HealInterval=1.000000
     ExplosionSound=SoundGroup'KF_GrenadeSnd.NadeBase.MedicNade_Explode'
     SuccessfulHealMessage="You healed "
     MaxNumberOfPlayers=6
     Damage=50.000000
     DamageRadius=175.000000
     MyDamageType=Class'KFMod.DamTypeMedicNade'
     ExplosionDecal=Class'KFMod.MedicNadeDecal'
     StaticMesh=StaticMesh'KF_pickups5_Trip.nades.MedicNade_Pickup'
     DrawScale=1.000000
     SoundVolume=150
     SoundRadius=100.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=200.000000
}
