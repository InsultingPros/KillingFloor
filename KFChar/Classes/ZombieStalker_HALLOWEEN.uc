//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieStalker_HALLOWEEN extends ZombieStalker;


#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_HALLOWEEN_T.utx

simulated function Tick(float DeltaTime)
{
	Super(KFMonster).Tick(DeltaTime);
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

		if ( !bSpotted && !bCloaked && Skins[0] != Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB' )
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
            else if ( Skins[0] != Shader'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_Redneck_Invisible' )
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
		Skins[0] = Shader'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_Redneck_Invisible';
		Skins[1] = Shader'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_Redneck_Invisible';
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

		if ( Skins[0] != Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB' )
		{

			Skins[0] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
            Skins[1] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';

			if (PlayerShadow != none)
				PlayerShadow.bShadowActive = true;

			bAcceptsProjectors = true;

			SetOverlayMaterial(Material'KFX.FBDecloakShader', 0.25, true);
		}
	}
}

function RemoveHead()
{
	Super(KFMonster).RemoveHead();

	if (!bCrispified)
	{
		Skins[0] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
		Skins[1] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super(KFMonster).PlayDying(DamageType,HitLoc);

	if(bUnlit)
		bUnlit=!bUnlit;

    LocalKFHumanPawn = none;

	if (!bCrispified)
	{
		Skins[0] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
		Skins[1] = Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
	}
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Talk'
     MoanVolume=1.000000
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmStalker_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegStalker_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadStalker_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
     GruntVolume=0.250000
     MenuName="HALLOWEEN Stalker"
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Stalker_Halloween'
     Skins(0)=Shader'KF_Specimens_Trip_HALLOWEEN_T.Stalker.stalker_Redneck_invisible'
     Skins(1)=Shader'KF_Specimens_Trip_HALLOWEEN_T.Stalker.stalker_Redneck_invisible'
     TransientSoundVolume=0.600000
}
