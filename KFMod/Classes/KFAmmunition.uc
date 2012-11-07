//=============================================================================
// KF Ammo.
//=============================================================================
class KFAmmunition extends Ammunition;

var	bool	bAcceptsAmmoPickups;
var	int		AmmoPickupAmount;

simulated function CheckOutOfAmmo()
{
    if( AmmoAmount<=0 && Pawn(Owner)!=None && Pawn(Owner).Weapon!=None )
        Pawn(Owner).Weapon.OutOfAmmo();
}

simulated function PostNetReceive()
{
    //log(self$"AmmoAmount = "$AmmoAmount);
	CheckOutOfAmmo();
}

function bool HandlePickupQuery( pickup Item )
{
	if ( class == item.InventoryType )
	{
		MaxAmmo = Default.MaxAmmo;

		if ( KFPawn(Owner) != none && KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo) != none &&
			 KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			MaxAmmo = float(MaxAmmo) * KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo).ClientVeteranSkill.Static.AddExtraAmmoFor(KFPlayerReplicationInfo(KFPawn(Owner).PlayerReplicationInfo), Class);
		}

		if ( AmmoAmount == MaxAmmo )
		{
			return true;
		}

		item.AnnouncePickup(Pawn(Owner));
		AddAmmo(Ammo(item).AmmoAmount);
        item.SetRespawn();

		return true;
	}

	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

defaultproperties
{
     bAcceptsAmmoPickups=True
     AmmoPickupAmount=40
     bNetNotify=True
}
