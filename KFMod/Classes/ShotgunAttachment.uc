class ShotgunAttachment extends KFWeaponAttachment;

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
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdKar'
     mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'
     MovementAnims(0)="JogF_Shotgun"
     MovementAnims(1)="JogB_Shotgun"
     MovementAnims(2)="JogL_Shotgun"
     MovementAnims(3)="JogR_Shotgun"
     TurnLeftAnim="TurnL_Shotgun"
     TurnRightAnim="TurnR_Shotgun"
     CrouchAnims(0)="CHwalkF_Shotgun"
     CrouchAnims(1)="CHwalkB_Shotgun"
     CrouchAnims(2)="CHwalkL_Shotgun"
     CrouchAnims(3)="CHwalkR_Shotgun"
     WalkAnims(0)="WalkF_Shotgun"
     WalkAnims(1)="WalkB_Shotgun"
     WalkAnims(2)="WalkL_Shotgun"
     WalkAnims(3)="WalkR_Shotgun"
     CrouchTurnRightAnim="CH_TurnR_Shotgun"
     CrouchTurnLeftAnim="CH_TurnL_Shotgun"
     IdleCrouchAnim="CHIdle_Shotgun"
     IdleWeaponAnim="Idle_Shotgun"
     IdleRestAnim="Idle_Shotgun"
     IdleChatAnim="Idle_Shotgun"
     IdleHeavyAnim="Idle_Shotgun"
     IdleRifleAnim="Idle_Shotgun"
     FireAnims(0)="Fire_Shotgun"
     FireAnims(1)="Fire_Shotgun"
     FireAnims(2)="Fire_Shotgun"
     FireAnims(3)="Fire_Shotgun"
     FireAltAnims(0)="Fire_Shotgun"
     FireAltAnims(1)="Fire_Shotgun"
     FireAltAnims(2)="Fire_Shotgun"
     FireAltAnims(3)="Fire_Shotgun"
     FireCrouchAnims(0)="CHFire_Shotgun"
     FireCrouchAnims(1)="CHFire_Shotgun"
     FireCrouchAnims(2)="CHFire_Shotgun"
     FireCrouchAnims(3)="CHFire_Shotgun"
     FireCrouchAltAnims(0)="CHFire_Shotgun"
     FireCrouchAltAnims(1)="CHFire_Shotgun"
     FireCrouchAltAnims(2)="CHFire_Shotgun"
     FireCrouchAltAnims(3)="CHFire_Shotgun"
     HitAnims(0)="HitF_Shotgun"
     HitAnims(1)="HitB_Shotgun"
     HitAnims(2)="HitL_Shotgun"
     HitAnims(3)="HitR_Shotgun"
     PostFireBlendStandAnim="Blend_Shotgun"
     PostFireBlendCrouchAnim="CHBlend_Shotgun"
     Mesh=SkeletalMesh'KF_Weapons3rd_Trip.Shotgun_3rd'
}
