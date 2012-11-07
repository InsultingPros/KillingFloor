// for the Purposes of Gibbing and various nasty shit.
class ZombieMeleeDamage extends DamTypeZombieAttack;

defaultproperties
{
     DeathString="%o was eaten by %k."
     FemaleSuicide="%o ate herself."
     MaleSuicide="%o ate himself."
     PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
     LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
     LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
}
