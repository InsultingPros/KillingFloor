//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieBoss_CIRCUS extends ZombieBoss;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

simulated function CloakBoss()
{
	local Controller C;
	local int Index;

	if ( bSpotted )
	{
		Visibility = 120;

		if ( Level.NetMode==NM_DedicatedServer )
		{
			Return;
		}

		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		Skins[2] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;

		return;
	}

	Visibility = 1;
	bCloaked = true;

	if ( Level.NetMode!=NM_Client )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( C.bIsPlayer && C.Enemy==Self )
			{
				C.Enemy = None; // Make bots lose sight with me.
			}
		}
	}

	if( Level.NetMode==NM_DedicatedServer )
	{
		Return;
	}

	Skins[1] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
	Skins[0] = Shader'KF_Specimens_Trip_T.patriarch_invisible';

	// Invisible - no shadow
	if(PlayerShadow != none)
	{
		PlayerShadow.bShadowActive = false;
	}

	// Remove/disallow projectors on invisible people
	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;
	SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

	// Randomly send out a message about Patriarch going invisible(10% chance)
	if ( FRand() < 0.10 )
	{
		// Pick a random Player to say the message
		Index = Rand(Level.Game.NumPlayers);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( PlayerController(C) != none )
			{
				if ( Index == 0 )
				{
					PlayerController(C).Speech('AUTO', 8, "");
					break;
				}

				Index--;
			}
		}
	}
}

// Speech notifies called from the anims
function PatriarchKnockDown()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

// Taunt to use when doing the melee exploit radial attack
function PatriarchRadialTaunt()
{
    if( NumNinjas > 0 && NumNinjas > NumLumberJacks )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntNinja', SLOT_Misc, 2.0,true,500.0);
    }
    else if( NumLumberJacks > 0 && NumLumberJacks > NumNinjas )
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntLumberJack', SLOT_Misc, 2.0,true,500.0);
    }
    else
    {
        PlaySound(SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntRadial', SLOT_Misc, 2.0,true,500.0);
    }
}

state KnockDown // Knocked
{
	function bool ShouldChargeFromDamage()
	{
		return false;
	}

Begin:
	if ( Health > 0 )
	{
		Sleep(GetAnimDuration('KnockDown'));
		CloakBoss();
		PlaySound(sound'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_SaveMe', SLOT_Misc, 2.0,,500.0);

		if ( KFGameType(Level.Game).FinalSquadNum == SyringeCount )
		{
		   KFGameType(Level.Game).AddBossBuddySquad();
		}

		GotoState('Escaping');
	}
	else
	{
	   GotoState('');
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.Patriarch_Circus.Patriarch_Circus_CMB');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
 }

defaultproperties
{
     RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_FireRocket'
     MiniGunFireSound=Sound'KF_BasePatriarch.Attack.Kev_MG_GunfireLoop'
     MiniGunSpinSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineFireLoop'
     MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_HitPlayer_Impale'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_HitPlayer_Fist'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPatriarch_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegPatriarch_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Death'
     MenuName="Circus Patriarch"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.Patriarch_Circus'
     Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.Patriarch_Circus.Patriarch_Circus_CMB'
     Skins(1)=Combiner'KF_Specimens_Trip_T.gatling_cmb'
}
