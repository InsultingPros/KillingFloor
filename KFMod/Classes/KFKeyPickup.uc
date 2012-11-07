class KFKeyPickup extends Pickup;

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);
	Copy.Tag = Tag;
	if( KFKeyInventory(Copy)!=None )
		KFKeyInventory(Copy).MyPickup = self;
	return Copy;
}

State Sleeping
{
	ignores Touch;
Begin:
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
}

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
