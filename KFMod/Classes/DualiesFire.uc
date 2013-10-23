//=============================================================================
// Dualies Fire
//=============================================================================
class DualiesFire extends KFFire;

var() Emitter Flash2Emitter;

var()           Emitter         ShellEject2Emitter;          // The shell eject emitter
var()           name            ShellEject2BoneName;         // name of the shell eject bone

var name FireAnim2, FireAimedAnim2;
var name fa;
//var bool bFlashLeft;

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
        return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(FlashEmitter, KFWeapon(Weapon).default.FlashBoneName);
    }
    if ( (FlashEmitterClass != None) && ((Flash2Emitter == None) || Flash2Emitter.bDeleteMe) )
    {
        Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(Flash2Emitter, Dualies(Weapon).default.altFlashBoneName);
    }

    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }

    if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
    {
        ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }

    if ( (ShellEjectClass != None) && ((ShellEject2Emitter == None) || ShellEject2Emitter.bDeleteMe) )
    {
        ShellEject2Emitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEject2Emitter, ShellEject2BoneName);
    }
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (ShellEject2Emitter != None)
        ShellEject2Emitter.Destroy();

    if (Flash2Emitter != None)
        Flash2Emitter.Destroy();
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);

    if (ShellEject2Emitter != None )
    {
        Canvas.DrawActor( ShellEject2Emitter, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    if (Flash2Emitter == none || FlashEmitter == none)
        return;

    if( KFWeap.bAimingRifle )
    {
        if( FireAimedAnim == 'FireLeft_Iron' )
        {
            Flash2Emitter.Trigger(Weapon, Instigator);
            if (ShellEjectEmitter != None)
            {
                ShellEjectEmitter.Trigger(Weapon, Instigator);
            }
           // bFlashLeft = true;
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);
            if (ShellEject2Emitter != None)
            {
                ShellEject2Emitter.Trigger(Weapon, Instigator);
            }
          // bFlashLeft = false;
        }
	}
	else
	{
        if(FireAnim == 'FireLeft')
        {
            Flash2Emitter.Trigger(Weapon, Instigator);
            if (ShellEjectEmitter != None)
            {
                ShellEjectEmitter.Trigger(Weapon, Instigator);
            }
           // bFlashLeft = true;
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);
            if (ShellEject2Emitter != None)
            {
                ShellEject2Emitter.Trigger(Weapon, Instigator);
            }
          // bFlashLeft = false;
        }
	}
}

event ModeDoFire()
{
	local name bn;

	bn = Dualies(Weapon).altFlashBoneName;
	Dualies(Weapon).altFlashBoneName = Dualies(Weapon).FlashBoneName;
	Dualies(Weapon).FlashBoneName = bn;

	Super.ModeDoFire();

    if( KFWeap.bAimingRifle )
    {
    	fa = FireAimedAnim2;
    	FireAimedAnim2 = FireAimedAnim;
    	FireAimedAnim = fa;
	}
	else
	{
    	fa = FireAnim2;
    	FireAnim2 = FireAnim;
    	FireAnim = fa;
	}
	InitEffects();
}

function StartBerserk()
{
	DamageMin = default.DamageMin * 1.33;
	DamageMax = default.DamageMax * 1.33;
}

function StopBerserk()
{
	DamageMin = default.DamageMin;
	DamageMax = default.DamageMax;
}

function StartSuperBerserk()
{
	FireRate = default.FireRate * 1.5/Level.GRI.WeaponBerserk;
	FireAnimRate = default.FireAnimRate * 0.667 * Level.GRI.WeaponBerserk;
	DamageMin = default.DamageMin * 1.5;
	DamageMax = default.DamageMax * 1.5;
	// KFTODO: Not sure how to replace this
	//if (AssaultRifle(Weapon) != None && AssaultRifle(Weapon).bDualMode)
	//	FireRate *= 0.55;
}

defaultproperties
{
     ShellEject2BoneName="Shell_eject_right"
     FireAnim2="FireLeft"
     FireAimedAnim2="FireLeft_Iron"
     FireAimedAnim="FireRight_Iron"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=450
     maxHorizontalRecoilAngle=50
     ShellEjectClass=Class'ROEffects.KFShellEject9mm'
     ShellEjectBoneName="Shell_eject_left"
     StereoFireSoundRef="KF_9MMSnd.9mm_FireST"
     DamageType=Class'KFMod.DamTypeDualies'
     DamageMin=25
     DamageMax=35
     Momentum=10500.000000
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireAnim="FireRight"
     FireLoopAnim=
     FireEndAnim=
     TweenTime=0.025000
     FireSound=SoundGroup'KF_9MMSnd.9mm_Fire'
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.100000
     AmmoClass=Class'KFMod.SingleAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
     aimerror=30.000000
     Spread=0.015000
     SpreadStyle=SS_Random
}
