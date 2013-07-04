//=============================================================================
// SPShotgunAltFire
//=============================================================================
// Steampunk Shotgun Alt fire class.
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPShotgunAltFire extends KFShotgunFire;

var()	InterpCurve     AppliedMomentumCurve;             // How much momentum to apply to a zed based on how much mass it has
var     float           WideDamageMinHitAngle;            // The angle to do sweeping strikes in front of the player. If zero do no strikes
var     float           PushRange;                        // The range to push zeds away when firing

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

    // No ammo so just always fire
	return true;
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local Pawn Victims;
	local vector dir, lookdir;
	local float DiffAngle, VictimDist;
	local float AppliedMomentum;
	local vector Momentum;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() && !KFWeap.bAimingRifle )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

	if( WideDamageMinHitAngle > 0 )
	{
		foreach Weapon.VisibleCollidingActors( class 'Pawn', Victims, (PushRange * 2), StartTrace )
		{
            if( Victims.Health <= 0 )
            {
                continue;
            }

        	if( Victims != Instigator )
			{
                // Don't push team mates or scripted characters (like the Ringmaster)
                if( Victims.GetTeamNum() == Instigator.GetTeamNum()
                    || Victims.IsA('KF_StoryNPC') )
                {
                    continue;
                }


				VictimDist = VSizeSquared(Instigator.Location - Victims.Location);

                //log("VictimDist = "$VictimDist$" PushRange = "$(PushRange*PushRange));

                if( VictimDist > (((PushRange * 1.1) * (PushRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)) )
                {
                    continue;
                }

	  			lookdir = Normal(Vector(Instigator.GetViewRotation()));
				dir = Normal(Victims.Location - Instigator.Location);

	           	DiffAngle = lookdir dot dir;

	           	dir = Normal((Victims.Location + Victims.EyePosition()) - Instigator.Location);

	           	if( DiffAngle > WideDamageMinHitAngle )
	           	{
                    AppliedMomentum = InterpCurveEval(AppliedMomentumCurve,Victims.Mass);

                    HandleAchievement( Victims );

	           		//log("Shot would hit "$Victims$" DiffAngle = "$DiffAngle);
	           		Momentum = (dir * AppliedMomentum)/Victims.Mass;
                    Victims.AddVelocity( Momentum );
                    if( KFMonster(Victims) != none )
                    {
                        KFMonster(Victims).BreakGrapple();
                    }
	           	}
//	           	else
//	           	{
//                    log("Shot would miss "$Victims$" DiffAngle = "$DiffAngle);
//	           	}
			}
		}
	}

	if (Instigator != none )
	{
		// Really boost the momentum for low grav. Weapon only gets momentum on low grav
        if( Instigator.Physics == PHYS_Falling
            && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
        {
            Instigator.AddVelocity((KickMomentum * 10.0) >> Instigator.GetViewRotation());
        }
	}
}

function HandleAchievement( Pawn Victim )
{
	local KFSteamStatsAndAchievements KFSteamStats;

	if ( Victim.IsA( 'ZombieScrake' ) )
	{
		if (PlayerController( Instigator.Controller ) != none )
		{
         	KFSteamStats = KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements);
			if ( KFSteamStats != none )
			{
             	KFSteamStats.CheckAndSetAchievementComplete( KFSteamStats.KFACHIEVEMENT_PushScrakeSPJ );
			}
		}
	}

}


// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
    	if( Weapon.GetFireMode(1).bIsFiring )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( Rand( 2 ) == 1 )
             	NewRecoilRotation.Yaw *= -1;

            if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
            {
                AdjustedVelocity = Weapon.Owner.Velocity;
                // Ignore Z velocity in low grav so we don't get massive recoil
                AdjustedVelocity.Z = 0;
                AdjustedSpeed = VSize(AdjustedVelocity);
                //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

                // Reduce the falling recoil in low grav
                NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
        	    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
    	    }
    	    else
    	    {
                //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
        	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
        	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
    	    }

    	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation *= Rec;

 		    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
    	}
 	}
}

defaultproperties
{
     AppliedMomentumCurve=(Points=((OutVal=10000.000000),(InVal=350.000000,OutVal=175000.000000),(InVal=600.000000,OutVal=250000.000000)))
     WideDamageMinHitAngle=0.600000
     PushRange=150.000000
     KickMomentum=(X=-35.000000,Z=5.000000)
     maxVerticalRecoilAngle=3200
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     FireSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Secondary_Fire_M"
     StereoFireSoundRef="KF_SP_ZEDThrowerSnd.KFO_Shotgun_Secondary_Fire_S"
     NoAmmoSoundRef="KF_AA12Snd.AA12_DryFire"
     ProjPerFire=0
     bModeExclusive=False
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireRate=1.200000
     AmmoPerFire=0
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=250.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=6.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     ProjectileClass=None
     BotRefireRate=1.750000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSPShotgunAlt'
     aimerror=1.000000
     Spread=0.000000
}
