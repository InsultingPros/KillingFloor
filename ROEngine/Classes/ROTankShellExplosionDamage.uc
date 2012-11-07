class ROTankShellExplosionDamage extends ROWeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
	// MergeTODO: Evaluate this, we really only need hit effects for the impact not the explosion right?

/*    HitEffects[0] = class'HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'HitFlame'; */
}

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
		//	PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 5);
	}
}

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.Strike'
     TankDamageModifier=0.050000
     APCDamageModifier=0.250000
     VehicleDamageModifier=0.500000
     TreadDamageModifier=0.250000
     DeathString="%o was killed by %k's tank shell shrapnel."
     FemaleSuicide="%o fired her shell prematurely."
     MaleSuicide="%o fired his shell prematurely."
     bArmorStops=False
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bExtraMomentumZ=True
     bFlaming=True
     GibModifier=4.000000
     DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
     DeathOverlayTime=999.000000
     GibPerterbation=0.150000
     KDamageImpulse=5000.000000
     KDeathVel=250.000000
     KDeathUpKick=50.000000
     VehicleMomentumScaling=1.300000
}
