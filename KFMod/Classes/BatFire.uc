// Bat Fire //

class BatFire extends KFMeleeFire;

var() Name FireAnim2;

function PlayFiring()
{
	local name fa;

	if( FRand()<0.7 ) // Randomly swap animations.
	{
		fa = FireAnim2;
		FireAnim2 = FireAnim;
		FireAnim = fa;
	}
	Super.PlayFiring();
}

defaultproperties
{
     FireAnim2="Fire2"
     damageConst=45
     maxAdditionalDamage=25
     ProxySize=0.120000
     DamagedelayMin=0.500000
     DamagedelayMax=0.500000
     hitDamageClass=Class'KFMod.DamTypeBat'
     MeleeHitSounds(0)=Sound'KFPawnDamageSound.MeleeDamageSounds.bathitflesh'
     MeleeHitSounds(1)=Sound'KFPawnDamageSound.MeleeDamageSounds.bathitflesh2'
     MeleeHitSounds(2)=Sound'KFPawnDamageSound.MeleeDamageSounds.bathitflesh3'
     FireRate=0.710000
     BotRefireRate=0.710000
}
