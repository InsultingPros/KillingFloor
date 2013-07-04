/*
	--------------------------------------------------------------
	KeyPickup_Story
	--------------------------------------------------------------


	Author :  Alex Quick

	--------------------------------------------------------------
*/

class  KeyPickup_Story extends WeaponPickup;

/*
function inventory SpawnCopy( pawn Other )
{
	local inventory KeyInv;

	KeyInv = Super.SpawnCopy(Other);
	KeyInv.Tag = Tag;

	if( KFKeyInventory(KeyInv)!=None )
	{
		KFKeyInventory(KeyInv).MyPickup = self;
	}

	return Copy;
}*/

defaultproperties
{
     InventoryType=Class'KFMod.KFKeyInventory'
     PickupMessage="You found a key"
     PickupSound=Sound'PatchSounds.slide1-3'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KillingFloorLabStatics.KeyCard1'
     Physics=PHYS_Falling
     DrawScale=0.100000
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     CollisionRadius=20.000000
     CollisionHeight=5.000000
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
