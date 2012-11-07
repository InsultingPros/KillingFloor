class SingleAttachment extends KFWeaponAttachment;

var Actor TacShine;
var  Effects TacShineCorona;
var bool bBeamEnabled;

// Prevents tracers from spawning if player is using the flashlight function of the 9mm
simulated event ThirdPersonEffects()
{
	if( FiringMode==1 )
		return;
	Super.ThirdPersonEffects();
}

simulated function Destroyed()
{
	if ( TacShineCorona != None )
		TacShineCorona.Destroy();
	if ( TacShine != None )
		TacShine.Destroy();
	Super.Destroyed();
}

simulated function UpdateTacBeam( float Dist )
{
	local vector Sc;

	if( !bBeamEnabled )
	{
		if (TacShine == none )
		{
			TacShine = Spawn(Class'Single'.Default.TacShineClass,Owner,,,);
			AttachToBone(TacShine,'FlashLight');
			TacShine.RemoteRole = ROLE_None;
		}
		else TacShine.bHidden = False;
		if (TacShineCorona == none )
		{
			TacShineCorona = Spawn(class 'KFTacLightCorona',Owner,,,);
			AttachToBone(TacShineCorona,'FlashLight');
			TacShineCorona.RemoteRole = ROLE_None;
		}
		TacShineCorona.bHidden = False;
		bBeamEnabled = True;
	}
	Sc = TacShine.DrawScale3D;
	Sc.Y = FClamp(Dist/90.f,0.02,1.f);
	if( TacShine.DrawScale3D!=Sc )
		TacShine.SetDrawScale3D(Sc);
}

simulated function TacBeamGone()
{
	if( bBeamEnabled )
	{
		if (TacShine!=none )
			TacShine.bHidden = True;
		if (TacShineCorona!=none )
			TacShineCorona.bHidden = True;
		bBeamEnabled = False;
	}
}

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdPistol'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     MovementAnims(0)="JogF_Single9mm"
     MovementAnims(1)="JogB_Single9mm"
     MovementAnims(2)="JogL_Single9mm"
     MovementAnims(3)="JogR_Single9mm"
     TurnLeftAnim="TurnL_Single9mm"
     TurnRightAnim="TurnR_Single9mm"
     CrouchAnims(0)="CHwalkF_Single9mm"
     CrouchAnims(1)="CHwalkB_Single9mm"
     CrouchAnims(2)="CHwalkL_Single9mm"
     CrouchAnims(3)="CHwalkR_Single9mm"
     CrouchTurnRightAnim="CH_TurnR_Single9mm"
     CrouchTurnLeftAnim="CH_TurnL_Single9mm"
     IdleCrouchAnim="CHIdle_Single9mm"
     IdleWeaponAnim="Idle_Single9mm"
     IdleRestAnim="Idle_Single9mm"
     IdleChatAnim="Idle_Single9mm"
     IdleHeavyAnim="Idle_Single9mm"
     IdleRifleAnim="Idle_Single9mm"
     FireAnims(0)="Fire_Single9mm"
     FireAnims(1)="Fire_Single9mm"
     FireAnims(2)="Fire_Single9mm"
     FireAnims(3)="Fire_Single9mm"
     FireAltAnims(0)="Fire_Single9mm"
     FireAltAnims(1)="Fire_Single9mm"
     FireAltAnims(2)="Fire_Single9mm"
     FireAltAnims(3)="Fire_Single9mm"
     FireCrouchAnims(0)="CHFire_Single9mm"
     FireCrouchAnims(1)="CHFire_Single9mm"
     FireCrouchAnims(2)="CHFire_Single9mm"
     FireCrouchAnims(3)="CHFire_Single9mm"
     FireCrouchAltAnims(0)="CHFire_Single9mm"
     FireCrouchAltAnims(1)="CHFire_Single9mm"
     FireCrouchAltAnims(2)="CHFire_Single9mm"
     FireCrouchAltAnims(3)="CHFire_Single9mm"
     HitAnims(0)="HitF_Single9mm"
     HitAnims(1)="HitB_Single9mm"
     HitAnims(2)="HitL_Single9mm"
     HitAnims(3)="HitR_Single9mm"
     PostFireBlendStandAnim="Blend_Single9mm"
     PostFireBlendCrouchAnim="CHBlend_Single9mm"
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     LightType=LT_Pulse
     LightRadius=0.000000
     CullDistance=5000.000000
     Mesh=SkeletalMesh'KF_Weapons3rd_Trip.Single9mm_3rd'
}
