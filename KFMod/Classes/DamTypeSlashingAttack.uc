//-----------------------------------------------------------
// Slashing Attacks
//-----------------------------------------------------------
class DamTypeSlashingAttack extends DamTypeZombieAttack;

defaultproperties
{
     HUDDamageTex=FinalBlend'KillingFloorHUD.SlashSplashNormalFB'
     HUDUberDamageTex=FinalBlend'KillingFloorHUD.SlashSplashUberFB'
     PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
     LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
     LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
}
