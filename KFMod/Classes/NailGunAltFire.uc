//=============================================================================
// Flashlight
//=============================================================================
class NailGunALTFire extends KFFire;

var name FireAnim2;

simulated function ModeDoFire()
{
	if (Weapon != none && KFPlayerController(pawn(Weapon.Owner).Controller) != none )
	{
		KFPlayerController(pawn(Weapon.Owner).Controller).ToggleTorch();
		KFWeapon(Weapon).AdjustLightGraphic();
	}
	Super.ModeDoFire();
}

function DoTrace(Vector Start, Rotator Dir)
{

}

// Sends a value to the 9mm attachment telling whether the light is being used.
function bool LightFiring()
{
	return bIsFiring;
}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading || KFPawn(Instigator).SecondaryItem!=none || KFPawn(Instigator).bThrowingNade )
		return false;
	if(Level.TimeSeconds - LastClickTime > FireRate)
		return true;
}

defaultproperties
{
     bFiringDoesntAffectMovement=True
     RecoilRate=0.150000
     bDoClientRagdollShotFX=False
     FireSoundRef="KF_NailShotgun.Vlad9000_Light_On"
     DamageType=Class'KFMod.DamTypeDualies'
     Momentum=0.000000
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireAnim="LightOn"
     FireForce="AssaultRifleFire"
     AmmoClass=Class'KFMod.FlashlightAmmo'
     BotRefireRate=0.500000
     aimerror=0.000000
}
