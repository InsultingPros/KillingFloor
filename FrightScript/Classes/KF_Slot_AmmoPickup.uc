class KF_Slot_AmmoPickup extends KFAmmoPickup;

var() byte AmmoMultiplier;	// Multiply the amount of ammo received by this number

// Overridden so KF_Slot_AmmoPickup is never added to the AmmoPickups array
event PostBeginPlay(){}

auto state Pickup
{
	// Overridden so we do not try and access AmmoPickups
	function Touch(Actor Other)
	{
		local Inventory CurInv;
		local bool bPickedUp;
		local int AmmoPickupAmount;
		local Boomstick DBShotty;
		local bool bResuppliedBoomstick;
		local float VeterancyMod;

		if ( Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none &&
			 FastTrace(Other.Location, Location) )
		{
			for ( CurInv = Other.Inventory; CurInv != none; CurInv = CurInv.Inventory )
			{
				if( Boomstick(CurInv) != none )
				{
				    DBShotty = Boomstick(CurInv);
				}

                if ( KFAmmunition(CurInv) != none && KFAmmunition(CurInv).bAcceptsAmmoPickups )
				{
					if ( KFAmmunition(CurInv).AmmoPickupAmount > 1 )
					{
						if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
						{
							if ( KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill != none )
							{
								VeterancyMod = KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoPickupMod(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo), KFAmmunition(CurInv));
								AmmoPickupAmount = float(KFAmmunition(CurInv).AmmoPickupAmount) * VeterancyMod * AmmoMultiplier;
							}
							else
							{
								AmmoPickupAmount = KFAmmunition(CurInv).AmmoPickupAmount * AmmoMultiplier;
							}

							KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount);
							if( DBShotgunAmmo(CurInv) != none )
							{
                                bResuppliedBoomstick = true;
							}
							bPickedUp = true;
						}
					}
					else if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
					{
						bPickedUp = true;

						if ( FRand() <= (1.0 / Level.Game.GameDifficulty) )
						{
							AmmoPickupAmount = KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount * AmmoMultiplier;
							KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, AmmoPickupAmount);
						}
					}
				}
			}

			if ( bPickedUp )
			{
                if( bResuppliedBoomstick && DBShotty != none )
                {
                    DBShotty.AmmoPickedUp();
                }

                AnnouncePickup(Pawn(Other));
                if(RespawnTime > 0)
                {
				    GotoState('Sleeping', 'Begin');
                }
                else
                {
                    Destroy();
                }
			}
		}
	}
}

defaultproperties
{
     AmmoMultiplier=1
     RespawnTime=0.000000
}
