//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieStalker_CIRCUS extends ZombieStalker;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_CIRCUS_T.utx

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if( Level.NetMode==NM_DedicatedServer )
		Return; // Servers aren't intrested in this info.

	if( Level.TimeSeconds > NextCheckTime && Health > 0 )
	{
		NextCheckTime = Level.TimeSeconds + 0.5;

        if( LocalKFHumanPawn != none && LocalKFHumanPawn.Health > 0 && LocalKFHumanPawn.ShowStalkers() &&
            VSizeSquared(Location - LocalKFHumanPawn.Location) < LocalKFHumanPawn.GetStalkerViewDistanceMulti() * 640000.0 ) // 640000 = 800 Units
        {
			bSpotted = True;
		}
		else
		{
			bSpotted = false;
		}

		if ( !bSpotted && !bCloaked && Skins[0] != Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB' )
		{
			UncloakStalker();
		}
		else if ( Level.TimeSeconds - LastUncloakTime > 1.2 )
		{
			// if we're uberbrite, turn down the light
			if( bSpotted && Skins[0] != Finalblend'KFX.StalkerGlow' )
			{
				bUnlit = false;
				CloakStalker();
			}
			else if ( Skins[0] != Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr' )
			{
				CloakStalker();
			}
		}
	}
}


simulated function CloakStalker()
{
	if ( bSpotted )
	{
		if( Level.NetMode == NM_DedicatedServer )
			return;

		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		Skins[2] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;
		return;
	}

	if ( !bDecapitated && !bCrispified ) // No head, no cloak, honey.  updated :  Being charred means no cloak either :D
	{
		Visibility = 1;
		bCloaked = true;

		if( Level.NetMode == NM_DedicatedServer )
			Return;

		Skins[0] = Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr';
		Skins[1] = Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr';

		// Invisible - no shadow
		if(PlayerShadow != none)
			PlayerShadow.bShadowActive = false;
		if(RealTimeShadow != none)
			RealTimeShadow.Destroy();

		// Remove/disallow projectors on invisible people
		Projectors.Remove(0, Projectors.Length);
		bAcceptsProjectors = false;
		SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
	}
}


simulated function UnCloakStalker()
{
	if( !bCrispified )
	{
		LastUncloakTime = Level.TimeSeconds;

		Visibility = default.Visibility;
		bCloaked = false;

		// 25% chance of our Enemy saying something about us being invisible
		if( Level.NetMode!=NM_Client && !KFGameType(Level.Game).bDidStalkerInvisibleMessage && FRand()<0.25 && Controller.Enemy!=none &&
		 PlayerController(Controller.Enemy.Controller)!=none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 17, "");
			KFGameType(Level.Game).bDidStalkerInvisibleMessage = true;
		}
		if( Level.NetMode == NM_DedicatedServer )
			Return;

		if ( Skins[0] != Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB' )
		{
			Skins[1] = FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb';
			Skins[0] = Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB';

			if (PlayerShadow != none)
				PlayerShadow.bShadowActive = true;

			bAcceptsProjectors = true;

			SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
		}
	}
}

function RemoveHead()
{
	Super.RemoveHead();

	if (!bCrispified)
	{
		Skins[1] = FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb';
		Skins[0] = Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB';
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType,HitLoc);

	if(bUnlit)
		bUnlit=!bUnlit;

    LocalKFHumanPawn = none;

	if (!bCrispified)
	{
		Skins[1] = FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb';
		Skins[0] = Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB';
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB');
	myLevel.AddPrecacheMaterial(FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb');
	myLevel.AddPrecacheMaterial(Material'KFX.FBDecloakShader');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.StalkerCloakOpacity_cmb');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.StalkerSkin');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmStalker_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegStalker_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadStalker_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
     MenuName="Circus Stalker"
     AmbientSound=Sound'KF_BaseStalker.Stalker_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.stalker_CIRCUS'
     Skins(0)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'
     Skins(1)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'
}
