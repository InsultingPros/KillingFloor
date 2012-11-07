// Axe Fire //
class AxeFire extends KFMeleeFire;

var() array<name> FireAnims;

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);
        FireAnim = FireAnims[AnimToPlay];
    }

    Super.ModeDoFire();

}

defaultproperties
{
     FireAnims(0)="Fire"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     FireAnims(3)="Fire4"
     damageConst=125
     maxAdditionalDamage=50
     ProxySize=0.150000
     weaponRange=90.000000
     DamagedelayMin=0.600000
     DamagedelayMax=0.600000
     hitDamageClass=Class'KFMod.DamTypeAxe'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     FireRate=1.100000
     BotRefireRate=0.850000
}
