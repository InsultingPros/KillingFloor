//=============================================================================
// DamTypeFlareProjectileImpact
//=============================================================================
// Damage type for the flare gun projectile impacting something
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeFlareProjectileImpact extends KFProjectileWeaponDamageType;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';
	if( VictimHealth <= 0 )
		HitEffects[1] = class'KFHitFlame';
	else if ( FRand() < 0.8 )
		HitEffects[1] = class'KFHitFlame';
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
}

defaultproperties
{
     HeadShotDamageMult=1.500000
     WeaponClass=Class'KFMod.FlareRevolver'
     DeathString="%k killed %o (Flare Revolver)."
     FemaleSuicide="%o blew up."
     MaleSuicide="%o blew up."
     bRagdollBullet=True
     bBulletHit=True
     DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
     DeathOverlayTime=999.000000
     KDamageImpulse=6000.000000
     KDeathVel=250.000000
     KDeathUpKick=75.000000
     HumanObliterationThreshhold=200
}
