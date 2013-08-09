/*
	--------------------------------------------------------------
	 KF_RingMasterNPC
	--------------------------------------------------------------

    A helpeless old man.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_RingMasterNPC extends KF_StoryNPC_Spawnable;

/* Achievement Specific Variable */
var int 		TimesHit;              // Increments each time the ring master is hit
var int			MaxTimesHit;			// Number of hits it takes to fail a ringmaster achievement
var bool		bFailedAchievement;    // The ring master will never get this achievement... he failed...

/* Anim to play when this NPC is scared / taking damage */
var name        CowerAnim;

/* Anim to play when this NPC is seated on the ground & inactive */
var name        IdleSeatedAnim;

/* Anim to play when this NPC is idle and standing */
var name        IdleStandingAnim;

/* Anim to play when this NPC is idle and standing but is very hurt */
var name        IdleStandingInjuredAnim;

/* Anim to play when this NPC gets up off the ground */
var name        StandUpAnim;

/* If true, play standup anim */
var bool        bFirstActivation;

var float       LastCowerTime;

/* An array of sounds specifically for bleeding */
var() Array<Sound>     BleedingSounds;

var float               MinTimeBetweenBleedSounds;
var float               LastBleedSoundTime;

var float LastBleedOutTime, BleedOutInterval;

replication
{
    reliable if (Role == Role_Authority)
        bFirstActivation;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    log("*** SPAWNED RINGMASTER *** "@self);

    // Scale bleed out by difficulty if you want to
    if ( Role == ROLE_Authority && Level.Game != none )
    {
        // Set difficulty based values
        if ( Level.Game.GameDifficulty >= 7.0 ) // Hell on Earth
        {
            BleedOutInterval *= 0.5;
        }
        else if ( Level.Game.GameDifficulty >= 5.0 ) // Suicidal
        {
            BleedOutInterval *= 0.5;
        }
        else if ( Level.Game.GameDifficulty >= 4.0 ) // Hard
        {
            BleedOutInterval *= 0.5;
        }
        else if ( Level.Game.GameDifficulty >= 2.0 ) // Normal
        {
            BleedOutInterval *= 0.75;
        }
        else //if ( GameDifficulty == 1.0 ) // Beginner
        {
            BleedOutInterval *= 1.0;
        }

    	// Playercount Scaling. Make the guy bleed slower if there are fewer player
        if( Level.Game.NumPlayers == 1 )
        {
            BleedOutInterval *= 1.5;
        }
        else if( Level.Game.NumPlayers <= 3 )
        {
            BleedOutInterval *= 1.25;
        }
    }
}

function Reset()
{
    Super.Reset();
    bFirstActivation = false;
}

simulated function Tick(float DeltaTime)
{
//    log(self@" Active ? ::: "@bActive);

    if(bActive && Level.TimeSeconds - LastBleedOutTime > BleedOutInterval)
    {
        LastBleedOutTime = Level.TimeSeconds;
        TakeDamage(5,self,Location + Vect(0,0,1)*CollisionHeight,vect(0,0,0),class 'DamTypeBleedOut');
    }

    Super.Tick(DeltaTime);

    /* Update his idle state to reflect his injuries , etc. */
    IdleRestAnim = GetIdleAnim();
    IdleWeaponAnim = IdleRestAnim;
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	// Do not play the ringmasters pain sound from bleeding damage
	if ( class<DamTypeBleedOut>( damageType ) == none )
	{
	 	Super.PlayTakeHit( HitLocation, Damage, DamageType );
	 	return;
 	}

 	if( Level.TimeSeconds - LastBleedSoundTime < MinTimeBetweenBleedSounds )
            return;

     LastBleedSoundTime = Level.TimeSeconds;
 	// the ringmaster will play his specific bleeding sound
	PlaySound( BleedingSounds[ Rand ( BleedingSounds.Length ) ],,1.75 );
}

simulated function AddHealth()
{
    local int tempHeal ;
    if((level.TimeSeconds - lastHealTime) >= 0.1)
    {
        //log("AddHealth HealthToGive = "$HealthToGive$" Health = "$Health);

        if(Health < HealthMax)
        {
            tempHeal = int(20 * (level.TimeSeconds - lastHealTime)) ;
            if(tempHeal>0)
                lastHealTime = level.TimeSeconds ;

            //log("AddHealth adding "$tempHeal$" health");

            Health = Min(Health+tempHeal, HealthMax);
            HealthToGive -= tempHeal ;
        }
        else
        {
            lastHealTime = level.timeSeconds ;
            // if we are all healed, there's gonna be no more healing
            HealthToGive = 0 ;
            log("AddHealth all healed Health = "$Health);
        }
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIdx )
{
    // Reduce damage for zombie attacks
    if( (class<DamTypeZombieAttack>(damageType) != none || class<DamTypeBurned>(damageType) != none
        || class<DamTypeLawRocketImpact>(damageType) != none) && Damage >= 4 )
    {
        Damage *= 0.25;
    }

    // Cancel out the 5 we are going to lose when TakeDamage is called in the super
    // This is done so that healing works better for the Ringmaster, as his constant
    // bleedout is making healing not work well
    if( damageType == class'DamTypeBleedOut' && healthToGive > 0 )
    {
        healthtoGive+=5;
    }

    //log("Taking "$Damage$" damage of type "$damageType);

	// pushing the Ringmaster off his path can be problematic, so zero the momentum
 	super.TakeDamage( Damage, instigatedBy, hitlocation, vect(0,0,0), damageType, HitIdx );

	if ( InstigatedBy != none && !InstigatedBy.IsHumanControlled() )
	{
		CheckObjectiveAchievements( damageType );
	}
}

function CheckObjectiveAchievements( class<DamageType> damageType )
{
	local KFSteamStatsAndAchievements KFSteamStats;
	local Controller C;
	local KFGameReplicationInfo KFGRI;

	if ( class<DamTypeBleedOut>( damageType ) == none )
	{
     	TimesHit += 1;
		if ( TimesHit >= MaxTimesHit && !bFailedAchievement )
		{
			bFailedAchievement = true;

			KFGRI = KFGameReplicationInfo( Level.GRI );
			if( KFGRI != none )
			{
			    KFGRI.bObjectiveAchievementFailed = true;
			}
		}
	}
}

function OnObjectiveChanged(name OldObjectiveName, name NewObjectiveName)
{
	if ( NewObjectiveName == 'DefendRingMaster' )
	{
		TimesHit = 0;
		bFailedAchievement = false;
	}
}

/* Wrapper for retrieving the type of idle animation the Ringmaster should play at the moment */
simulated function  name GetIdleAnim()
{
    if(!bActive && !bFirstActivation)
    {
        return IdleSeatedAnim;
    }

    return IdleStandingInjuredAnim;
}

simulated event SetAnimAction(name NewAction)
{
	if (!bWaitForAnim)
	{
		AnimAction = NewAction;
        if ( AnimAction == StandUpAnim )
        {
            bWaitForAnim = true;
            AnimBlendParams(0, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(AnimAction,1.f, 0.0, 1);
        }
        else if(NewAction == CowerAnim  )
        {
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(AnimAction,1.f, 0.0, 1);
        }
    }

	super.SetAnimAction(NewAction);
}

simulated Function PostNetBeginPlay()
{
	local PlayerController LocalPlayer;
	local HUD_Storymode MyStoryHUD;
	local int i;

	super.PostNetBeginPlay();

	/* MEGA HACK!!!!!!!! *================================================*/

	LocalPlayer = Level.GetLocalPlayerController();
	if(LocalPlayer != none)
	{
    	MyStoryHUD = HUD_StoryMode(LocalPlayer.myHUD) ;
    	if(MyStoryHUD != none)
    	{
			for( i = 0; i < MyStoryHUD.ConditionHints.length; i++)
			{
				if(MyStoryHUD.ConditionHints[i].ConditionLoc == none &&
				MyStoryHUD.ConditionHints[i].PendingLocActorTag != '')
				{
					MyStoryHUD.ConditionHints[i].ConditionLoc = self;
					MyStoryHUD.ConditionHints[i].PendingLocActorTag = '' ;
				}
			}
    	}
	}
}

/* Only do the arm flailing animation if a ZED is attacking */
simulated function PlayDirectionalHit(Vector HitLoc)
{
    if(LasthitBy != none &&
    LastHitBy.IsA('KFMonsterController') &&
    Level.TimeSeconds - LastCowerTime >= GetAnimDuration(CowerAnim,1.f))
    {
        LastCowerTime = Level.TimeSeconds;
        SetAnimAction(CowerAnim);
    }
}

function SetActive(bool On)
{
    Super.SetActive(On);
    if(bActive && !bFirstActivation)
    {
        bFirstActivation = true;
    }
}

event Bump( actor Other )
{
	local vector PushVelocity;

	if ( Velocity != vect(0,0,0) )
	{
		// cheap and dirty encroachment
		if ( Other.Physics == PHYS_Walking && KFHumanPawn(Other) != None )
		{
			//log( self$" BUMPED "$Other );

			if( normal(Velocity) dot normal(Other.Location - Location) >= 0.7 )
			{
				PushVelocity = Normal( Other.Location - Location ) * 150;
				PushVelocity.Z = 50;
				Pawn( Other ).AddVelocity( PushVelocity );
			}
		}
	}
}

// copied from Pawn.uc, but we don't want the ringmaster to freeze on match end
function TurnOff()
{
	//SetCollision(true,false);
	AmbientSound = None;
 	bNoWeaponFiring = true;
    //Velocity = vect(0,0,0);
    //SetPhysics(PHYS_None);
    //bPhysicsAnimUpdate = false;
    bIsIdle = true;
    bWaitForAnim = false;
    StopAnimating();
    //bIgnoreForces = true;
}

defaultproperties
{
     MaxTimesHit=15
     CowerAnim="Freaking_out"
     IdleSeatedAnim="Heal_Sitting"
     IdleStandingAnim="Idle_Talk"
     IdleStandingInjuredAnim="Idle_VeryWounded"
     StandUpAnim="Heal_Getup"
     BleedingSounds(0)=Sound'SummerBoardwalkDialogue.Ringmaster.DE_260_1'
     BleedingSounds(1)=Sound'SummerBoardwalkDialogue.Ringmaster.DE_270_Grunt_02'
     BleedingSounds(2)=Sound'SummerBoardwalkDialogue.Ringmaster.DE_270_Grunt_03'
     BleedingSounds(3)=Sound'SummerBoardwalkDialogue.Ringmaster.DE_270_Knee_01'
     BleedingSounds(4)=Sound'SummerBoardwalkDialogue.Ringmaster.DE_280_4'
     MinTimeBetweenBleedSounds=5.000000
     BleedOutInterval=1.000000
     NPCName="Ringmaster Lockhart"
     bStartActive=False
     BaseAIThreatRating=0.010000
     bDropInventoryOnDeath=False
     FriendlyFireDamageScale=0.000000
     bShowHealthBar=True
     NPCHealth=250.000000
     StartingHealthPct=0.500000
     HealedEvent="RingMasterHealed"
     HitAnims(0)="Freaking_out"
     HitAnims(1)="Freaking_out"
     HitAnims(2)="Freaking_out"
     HitAnims(3)="Freaking_out"
     MinTimeBetweenPainSounds=1.000000
     bNoDefaultInventory=True
     bCanPickupInventory=False
     AIScriptTag="RingMasterAI"
     GroundSpeed=98.000000
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkB"
     MovementAnims(2)="WalkL"
     MovementAnims(3)="WalkR"
     IdleChatAnim="Idle_Talk"
     Mesh=SkeletalMesh'KF_Ringmaster_Trip.Ringmaster'
}
