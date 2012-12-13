//=============================================================================
// KrissMHealinglProjectile
//=============================================================================
// Healing projectile for the KrissM
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive
// Author - John "Ramm-Jaeger" Gibson
//=============================================================================
class KrissMHealingProjectile extends MP7MHealinglProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

    if ( Role == ROLE_Authority )
    {
    	Healed = KFHumanPawn(Other);

        if( Healed != none )
        {
            HitHealTarget(HitLocation, -vector(Rotation));
        }

        if( Instigator != none && Healed != none && Healed.Health > 0 &&
            Healed.Health <  Healed.HealthMax )
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
    				KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward, false, true);
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

                if( KrissMMedicGun(Instigator.Weapon) != none )
                {
                    KrissMMedicGun(Instigator.Weapon).ClientSuccessfulHeal(Healed.PlayerReplicationInfo.PlayerName);
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

defaultproperties
{
     HealBoostAmount=40
}
