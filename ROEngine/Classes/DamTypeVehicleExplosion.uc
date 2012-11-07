class DamTypeVehicleExplosion extends ROWeaponDamageType
	abstract;

defaultproperties
{
     HUDIcon=Texture'InterfaceArt_tex.deathicons.artkill'
     DeathString="%k took out %o with a vehicle explosion."
     FemaleSuicide="%o was a little too close to the vehicle she blew up."
     MaleSuicide="%o was a little too close to the vehicle he blew up."
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bExtraMomentumZ=True
     bFlaming=True
     GibModifier=6.000000
     DeathOverlayMaterial=Combiner'Effects_Tex.GoreDecals.PlayerDeathOverlay'
     DeathOverlayTime=999.000000
     GibPerterbation=0.150000
     KDamageImpulse=3000.000000
     KDeathVel=150.000000
     KDeathUpKick=50.000000
     VehicleMomentumScaling=1.300000
}
