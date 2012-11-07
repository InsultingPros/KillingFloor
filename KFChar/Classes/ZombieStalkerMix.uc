// Zombie Monster for KF Invasion gametype
class ZombieStalkerMix extends ZombieStalker;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Stalker_Anim');
	Super.BeginPlay();
}
simulated function UnCloakStalker()
{
	if( !bCrispified )
	{
		LastUncloakTime = Level.TimeSeconds;

		Visibility = default.Visibility;
		bCloaked = false;

		if( Level.NetMode == NM_DedicatedServer )
			Return;

		if ( Skins[0] != Default.Skins[0] )
		{
			Skins = Default.Skins;

			if (PlayerShadow != none)
				PlayerShadow.bShadowActive = true;

			bAcceptsProjectors = true;

			SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);

			// 25% chance of our Enemy saying something about us being invisible
			if ( !KFGameType(Level.Game).bDidStalkerInvisibleMessage && FRand() < 0.25 && Controller.Enemy != none &&
				 PlayerController(Controller.Enemy.Controller) != none )
			{
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 17, "");
				KFGameType(Level.Game).bDidStalkerInvisibleMessage = true;
			}
		}
	}
}
function RemoveHead()
{
	Super(KFMonster).RemoveHead();

	if (!bCrispified)
		Skins = Default.Skins;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super(KFMonster).PlayDying(DamageType,HitLoc);

	if(bUnlit)
		bUnlit=!bUnlit;
	LocalKFHumanPawn = none;
	if (!bCrispified)
		Skins = Default.Skins;
}

defaultproperties
{
     KFRagdollName="Bloat_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Bloat_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.bloat_cmb'
}
