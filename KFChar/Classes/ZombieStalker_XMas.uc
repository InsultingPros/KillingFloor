//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieStalker_XMas extends ZombieStalker;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax

simulated function Tick(float DeltaTime)
{
	super(ZombieStalkerBase).Tick(DeltaTime);

	if( Level.NetMode==NM_DedicatedServer )
		Return; // Servers aren't intrested in this info.

    if( bZapped )
    {
        // Make sure we check if we need to be cloaked as soon as the zap wears off
        NextCheckTime = Level.TimeSeconds;
    }
	else if( Level.TimeSeconds > NextCheckTime && Health > 0 )
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

		if ( !bSpotted && !bCloaked && Skins[0] != Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb' )
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
			else if ( Skins[0] != Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible' )
			{
				CloakStalker();
			}
		}
	}
}


simulated function CloakStalker()
{
    // No cloaking if zapped
    if( bZapped )
    {
        return;
    }

	if ( bSpotted )
	{
		if( Level.NetMode == NM_DedicatedServer )
			return;

		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;
		return;
	}

	if ( !bDecapitated && !bCrispified ) // No head, no cloak, honey.  updated :  Being charred means no cloak either :D
	{
		Visibility = 1;
		bCloaked = true;

		if( Level.NetMode == NM_DedicatedServer )
			Return;

		Skins[0] = Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible';
		Skins[1] = Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible';

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
    if( bZapped )
    {
        return;
    }

	if( !bCrispified )
	{
		LastUncloakTime = Level.TimeSeconds;

		Visibility = default.Visibility;
		bCloaked = false;

		// 25% chance of our Enemy saying something about us being invisible
		if ( Level.NetMode!=NM_Client && !KFGameType(Level.Game).bDidStalkerInvisibleMessage && FRand()<0.25 && Controller.Enemy!=none &&
		 	 PlayerController(Controller.Enemy.Controller)!=none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 17, "");
			KFGameType(Level.Game).bDidStalkerInvisibleMessage = true;
		}

		if ( Level.NetMode == NM_DedicatedServer )
		{
			Return;
		}

		if ( Skins[0] != Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb' )
		{
			Skins[1] = FinalBlend'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb';
			Skins[0] = Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb';

			if ( PlayerShadow != none )
			{
				PlayerShadow.bShadowActive = true;
			}

			bAcceptsProjectors = true;

			SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
		}
	}
}

// Set the zed to the zapped behavior
simulated function SetZappedBehavior()
{
    super(KFMonster).SetZappedBehavior();

	// Handle setting the zed to uncloaked so the zapped overlay works properly
    if( Level.Netmode != NM_DedicatedServer )
	{
		Skins[1] = FinalBlend'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb';
		Skins[0] = Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb';

		if (PlayerShadow != none)
			PlayerShadow.bShadowActive = true;

		bAcceptsProjectors = true;
		SetOverlayMaterial(Material'KFZED_FX_T.Energy.ZED_overlay_Hit_Shdr', 999, true);
	}
}

function RemoveHead()
{
	Super.RemoveHead();

	if ( !bCrispified )
	{
		Skins[1] = FinalBlend'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb';
		Skins[0] = Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb';
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType,HitLoc);

	if ( bUnlit )
	{
		bUnlit=!bUnlit;
	}

	LocalKFHumanPawn = none;

	if ( !bCrispified )
	{
		Skins[1] = FinalBlend'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb';
		Skins[0] = Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb';
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.stalkerclause_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.stalker_claus');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.stalkcerclause_ref_cmb');

	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_XMAS_T.stalker_invisible');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.StalkerCloakOpacity_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause_cloakrefract_cmb');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.StalkerSkin');

	//myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.StalkerCloakEnv_rot');
	//myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.stalker_opacity_osc');
	//myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmStalker_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegStalker_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadStalker_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
     MenuName="Christmas Stalker"
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.StalkerClause'
     Skins(0)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'
     Skins(1)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'
}
