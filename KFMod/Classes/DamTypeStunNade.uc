//Concussion Grenade DamageType

class DamTypeStunNade extends WeaponDamageType;

defaultproperties
{
     WeaponClass=Class'KFMod.StunNade'
     DeathString="%o filled %k's body with shrapnel."
     FemaleSuicide="%o grenaded her dumb self."
     MaleSuicide="%o grenaded his dumb self."
     bDetonatesGoop=True
     bKUseOwnDeathVel=True
     bDelayedDamage=True
     bThrowRagdoll=True
     DamageThreshold=1
     DamageOverlayTime=4.000000
     DeathOverlayTime=3.000000
     KDeathVel=150.000000
     KDeathUpKick=150.000000
}
