//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ScytheFireB extends KFMeleeFire;

defaultproperties
{
     MeleeDamage=330
     ProxySize=0.150000
     weaponRange=105.000000
     DamagedelayMin=0.950000
     DamagedelayMax=0.950000
     hitDamageClass=Class'KFMod.DamTypeScythe'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.ScytheHitEffect'
     WideDamageMinHitAngle=0.600000
     bWaitForRelease=True
     FireAnim="PowerAttack"
     FireRate=1.500000
     BotRefireRate=0.850000
}
