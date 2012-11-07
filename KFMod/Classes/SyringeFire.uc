class SyringeFire extends SyringeAltFire;

var				float	LastHealAttempt;
var				float	HealAttemptDelay;
var 			float 	LastHealMessageTime;
var 			float 	HealMessageDelay;
var localized   string  NoHealTargetMessage;
var             KFHumanPawn    CachedHealee;

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (CachedHealee != None)
        CachedHealee = none;
}

function AttemptHeal()
{
	local KFHumanPawn Healtarget;

    CachedHealee = none;

    if( AllowFire() && CanFindHealee() )
    {
        super.ModeDoFire();
        Syringe(Weapon).ClientSuccessfulHeal(CachedHealee.PlayerReplicationInfo.PlayerName);
    }
    else
    {
        // Give the messages if we missed our heal, can't find a target, etc
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			if ( LastHealAttempt + HealAttemptDelay < Level.TimeSeconds)
			{
				PlayerController(Instigator.controller).ClientMessage(NoHealTargetMessage, 'CriticalEvent');
				LastHealAttempt = Level.TimeSeconds;
			}

			if ( Level.TimeSeconds - LastHealMessageTime > HealMessageDelay )
			{
				// if there's a Player within 2 meters who needs healing, say that we're trying to heal them
				foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', Healtarget, 100)
				{
					if ( Healtarget != Instigator && Healtarget.Health < Healtarget.HealthMax )
					{
						PlayerController(Instigator.Controller).Speech('AUTO', 5, "");
						LastHealMessageTime = Level.TimeSeconds;

						break;
					}
				}
			}
		}
    }
}

// do the animations, etc
simulated function SuccessfulHeal()
{
    if( Weapon.Role < Role_Authority )
    {
        super.ModeDoFire();
    }
}

Function Timer()
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	Healed = CachedHealee;
	CachedHealee = none;

	if ( Healed != none && Healed.Health > 0 && Healed != Instigator )
	{
        Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);

		MedicReward = Syringe(Weapon).HealBoostAmount;

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			MedicReward *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetHealPotency(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
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

		// Tell them we're healing them
		PlayerController(Instigator.Controller).Speech('AUTO', 5, "");
		LastHealMessageTime = Level.TimeSeconds;

		PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
		if ( PRI != None )
		{
			if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward);
			}

            // Give the medic reward money as a percentage of how much of the person's health they healed
			MedicReward = int((FMin(float(MedicReward),Healed.HealthMax)/Healed.HealthMax) * 60); // Increased to 80 in Balance Round 6, reduced to 60 in Round 7

			PRI.Score += MedicReward;
			PRI.ThreeSecondScore += MedicReward;
			PRI.Team.Score += MedicReward;

			if ( KFHumanPawn(Instigator) != none )
			{
				KFHumanPawn(Instigator).AlphaAmount = 255;
			}
		}
	}
}

function KFHumanPawn GetHealee()
{
	local KFHumanPawn KFHP, BestKFHP;
	local vector Dir;
	local float TempDot, BestDot;

	Dir = vector(Instigator.GetViewRotation());

	foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', KFHP, 80.0)
	{
		if ( KFHP.Health < 100 && KFHP.Health > 0 )
		{
			TempDot = Dir dot (KFHP.Location - Instigator.Location);
			if ( TempDot > 0.7 && TempDot > BestDot )
			{
				BestKFHP = KFHP;
				BestDot = TempDot;
			}
		}
	}

	return BestKFHP;
}

function bool AllowFire()
{
	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

// Can we find someone to heal
function bool CanFindHealee()
{
	local KFHumanPawn Healtarget;

	Healtarget = GetHealee();
	CachedHealee = Healtarget;

	// Can't use syringe if we can't find a target
	if ( Healtarget == none )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(53);
		}

		return false;
	}

	// Can't use syringe if our target is already being healed to full health.
	if ( (Healtarget.Health == Healtarget.Healthmax) || ((Healtarget.healthToGive + Healtarget.Health) >= Healtarget.Healthmax) )
	{
		return false;
	}

    return true;
}

event ModeDoFire()
{
	// Try and heal on the server
    if( Weapon.Instigator.IsLocallyControlled() )
	{
       Syringe(Weapon).ServerAttemptHeal();
	}
}

defaultproperties
{
     HealAttemptDelay=0.500000
     HealMessageDelay=10.000000
     NoHealTargetMessage="You must be near another player to heal them!"
     InjectDelay=0.360000
     bWaitForRelease=True
     FireAnim="Fire"
     FireRate=2.800000
     AmmoPerFire=250
}
