//=============================================================================
// MAC Fire
//=============================================================================
class MAC10Fire extends KFHighROFFire;

// Overwritten to switch damage types for the firebug
function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
	local array<int> HitPoints;
	local KFPawn HitPawn;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);

	DamageType = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetMAC10DamageType(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));

	if ( Weapon.WeaponCentered() )
	{
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	}
	else
	{
		ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
		Weapon.EffectOffset.Z * Z);
	}

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if ( Other != None && Other != Instigator && Other.Base != Instigator )
	{
		WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

		if ( !Other.bWorldGeometry )
		{
			// Update hit effect except for pawns
			if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') &&
			     !Other.IsA('ExtendedZCollision') )
			{
				if( WeapAttach!=None )
				{
			        WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
			    }
			}

			HitPawn = KFPawn(Other);

			if ( HitPawn != none )
			{
				if ( !HitPawn.bDeleteMe )
				{
					HitPawn.ProcessLocationalDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType, HitPoints);
				}
			}
			else
			{
				Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType);
			}
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;

			if ( WeapAttach != None )
			{
				WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
}

defaultproperties
{
     FireEndSoundRef="KF_MAC10MPSnd.MAC10_Fire_Loop_End_M"
     FireEndStereoSoundRef="KF_MAC10MPSnd.MAC10_Fire_Loop_End_S"
     AmbientFireSoundRef="KF_MAC10MPSnd.MAC10_Fire_Loop"
     RecoilRate=0.050000
     maxVerticalRecoilAngle=150
     maxHorizontalRecoilAngle=100
     RecoilVelocityScale=1.500000
     ShellEjectClass=Class'ROEffects.KFShellEjectMac'
     ShellEjectBoneName="Mac11_Ejector"
     bRandomPitchFireSound=False
     FireSoundRef="KF_MAC10MPSnd.MAC10_Silenced_Fire"
     StereoFireSoundRef="KF_MAC10MPSnd.MAC10_Silenced_FireST"
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     DamageType=Class'KFMod.DamTypeMAC10MP'
     DamageMin=25
     DamageMax=35
     Momentum=6500.000000
     FireRate=0.052000
     AmmoClass=Class'KFMod.MAC10Ammo'
     ShakeRotMag=(X=35.000000,Y=35.000000,Z=200.000000)
     ShakeRotRate=(X=8000.000000,Y=8000.000000,Z=8000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.500000,Y=2.800000,Z=5.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=35.000000
     Spread=0.013000
     SpreadStyle=SS_Random
}
