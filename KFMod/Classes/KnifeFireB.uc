// Knife Stab //
class KnifeFireB extends KFMeleeFire;

defaultproperties
{
     damageConst=35
     maxAdditionalDamage=20
     DamagedelayMin=0.600000
     DamagedelayMax=0.600000
     hitDamageClass=Class'KFMod.DamTypeKnife'
     MeleeHitSounds(0)=SoundGroup'KF_KnifeSnd.Knife_HitFlesh'
     HitEffectClass=Class'KFMod.KnifeHitEffect'
     FireAnim="Stab"
     FireRate=1.100000
     BotRefireRate=1.100000
}
