//=============================================================================
// Stun Grenade Inventory class
//=============================================================================
class StunNade extends KFWeapon;

function float GetAIRating()
{
	local Bot B;


	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
    return 0;
}

defaultproperties
{
     MagCapacity=1
     ReloadRate=1.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     FireModeClass(0)=Class'KFMod.StunNadeFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     Description="the Concussion grenade does very little damage to enemies, but will stun any foes in the explosion AOE for a brief period of time."
     DisplayFOV=70.000000
     Priority=40
     PickupClass=Class'KFMod.StunNadePickup'
     BobDamping=10.000000
     AttachmentClass=Class'KFMod.StunAttachment'
     IconCoords=(X1=458,Y1=82,X2=491,Y2=133)
     ItemName="Concussion Grenade"
     Mesh=SkeletalMesh'KFWeaponModels.Stun'
     TransientSoundVolume=1.000000
     TransientSoundRadius=700.000000
}
