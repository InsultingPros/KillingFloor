//=============================================================================
// Kevlar Vest ... Don't leave home without it
//=============================================================================
class Vest extends SuperShieldPack
placeable;

var     byte    EquipmentCategoryID;
var 	int		ItemCost;

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage;
}

function RespawnEffect()
{
// Get rid of the Yellow puff. It's not welcome here.
}

defaultproperties
{
     EquipmentCategoryID=5
     ItemCost=300
     PickupMessage="You found a Kevlar Assault Vest"
     PickupSound=Sound'KF_InventorySnd.Vest_Pickup'
     StaticMesh=StaticMesh'KillingFloorStatics.Vest'
     Physics=PHYS_Falling
     DrawScale3D=(Z=0.400000)
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     TransientSoundVolume=150.000000
     CollisionRadius=30.000000
     CollisionHeight=5.000000
     RotationRate=(Yaw=0)
     DesiredRotation=(Yaw=0)
}
