class DualiesAttachment extends KFWeaponAttachment;

var bool bIsOffHand,bMyFlashTurn;
var bool bBeamEnabled;
var DualiesAttachment brother;
var () Mesh BrotherMesh;

var Actor TacShine;

var  Effects TacShineCorona;

simulated function DoFlashEmitter()
{
	if(bIsOffHand)
		return;
	if(bMyFlashTurn)
		ActuallyFlash();
	else if(brother != None)
		brother.ActuallyFlash();
	bMyFlashTurn = !bMyFlashTurn;
}

simulated function ActuallyFlash()
{
    Super.DoFlashEmitter();
}

simulated function Destroyed()
{
	if ( TacShineCorona != None )
		TacShineCorona.Destroy();
	if ( TacShine != None )
		TacShine.Destroy();
	Super.Destroyed();
}

// Overriden to support having two weapon attachments firing and playing anims
simulated event ThirdPersonEffects()
{
	local PlayerController PC;

    // Prevents tracers from spawning if player is using the flashlight function of the 9mm
	if( FiringMode==1 )
		return;

	if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
		return;

	// new Trace FX - Ramm
	if (FiringMode == 0)
	{
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
			PC = Level.GetLocalPlayerController();
			if ( ((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000) )
			{

					Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
					CheckForSplash();
			}
		}
	}

  	if ( FlashCount>0 )
	{
		if( KFPawn(Instigator)!=None )
		{
        	// We don't really have alt fire, but use the alt fire anims as the left hand firing anims
            if( bMyFlashTurn )
        	{
        		KFPawn(Instigator).StartFiringX(false,bRapidFire);
        	}
        	else
            {
                KFPawn(Instigator).StartFiringX(true,bRapidFire);
            }
		}

		if( bDoFiringEffects )
		{
    		PC = Level.GetLocalPlayerController();

    		if ( (Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC) )
    			return;

    		WeaponLight();
    		DoFlashEmitter();
    		SpawnTracer();

            if( !bIsOffHand )
            {
        		if( !bMyFlashTurn )
        		{
                    ThirdPersonShellEject();
        		}
        		else if( brother != None)
        		{
                    brother.ThirdPersonShellEject();
		        }
    		}
		}
	}
	else
	{
		GotoState('');
		if( KFPawn(Instigator)!=None )
			KFPawn(Instigator).StopFiring();
	}
}

simulated function ThirdPersonShellEject()
{
    if ( (mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
	{
		mShellCaseEmitter = Spawn(mShellCaseEmitterClass);
		if ( mShellCaseEmitter != None )
		    AttachToBone(mShellCaseEmitter, 'ShellPort');
	}
	if (mShellCaseEmitter != None)
		mShellCaseEmitter.mStartParticles++;
}

simulated function vector GetTracerStart()
{
    local Pawn p;

    p = Pawn(Owner);

    if ( (p != None) && p.IsFirstPerson() && p.Weapon != None )
    {
        return p.Weapon.GetEffectStart();
    }

    // 3rd person
    if ( mMuzFlash3rd != None && bMyFlashTurn)
        return mMuzFlash3rd.Location;
    else
	if ( brother != none && brother.mMuzFlash3rd != None && !bMyFlashTurn)
		return  brother.mMuzFlash3rd.Location;
	//   return Location;
}

simulated function UpdateTacBeam( float Dist )
{
	local vector Sc;
	local DualiesAttachment DA;

	if( Mesh==BrotherMesh )
	{
		if( bBeamEnabled )
		{
			if (TacShine!=none )
				TacShine.bHidden = True;
			if (TacShineCorona!=none )
				TacShineCorona.bHidden = True;
			bBeamEnabled = False;
		}
		if( brother==None )
		{
			ForEach DynamicActors(Class'DualiesAttachment',DA)
			{
				if( DA!=Self && DA.Instigator==Instigator && DA.Mesh!=BrotherMesh )
				{
					brother = DA;
					Break;
				}
			}
		}
		if( brother!=None )
			brother.UpdateTacBeam(Dist);
		Return;
	}
	if( !bBeamEnabled )
	{
		if (TacShine == none )
		{
			TacShine = Spawn(Class'Dualies'.Default.TacShineClass,Owner,,,);
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
	local DualiesAttachment DA;

	if( Mesh==BrotherMesh )
	{
		if( brother==None )
		{
			ForEach DynamicActors(Class'DualiesAttachment',DA)
			{
				if( DA!=Self && DA.Instigator==Instigator && DA.Mesh!=BrotherMesh )
				{
					brother = DA;
					Break;
				}
			}
		}
		if( brother!=None )
			brother.TacBeamGone();
		Return;
	}
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
     bMyFlashTurn=True
     BrotherMesh=SkeletalMesh'KF_Weapons3rd_Trip.Dual9mm_3rd'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdPistol'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     MovementAnims(0)="JogF_Dual9mm"
     MovementAnims(1)="JogB_Dual9mm"
     MovementAnims(2)="JogL_Dual9mm"
     MovementAnims(3)="JogR_Dual9mm"
     TurnLeftAnim="TurnL_Dual9mm"
     TurnRightAnim="TurnR_Dual9mm"
     CrouchAnims(0)="CHwalkF_Dual9mm"
     CrouchAnims(1)="CHwalkB_Dual9mm"
     CrouchAnims(2)="CHwalkL_Dual9mm"
     CrouchAnims(3)="CHwalkR_Dual9mm"
     WalkAnims(0)="WalkF_Dual9mm"
     WalkAnims(1)="WalkB_Dual9mm"
     WalkAnims(2)="WalkL_Dual9mm"
     WalkAnims(3)="WalkR_Dual9mm"
     CrouchTurnRightAnim="CH_TurnR_Dual9mm"
     CrouchTurnLeftAnim="CH_TurnL_Dual9mm"
     IdleCrouchAnim="CHIdle_Dual9mm"
     IdleWeaponAnim="Idle_Dual9mm"
     IdleRestAnim="Idle_Dual9mm"
     IdleChatAnim="Idle_Dual9mm"
     IdleHeavyAnim="Idle_Dual9mm"
     IdleRifleAnim="Idle_Dual9mm"
     FireAnims(0)="DualiesAttackRight"
     FireAnims(1)="DualiesAttackRight"
     FireAnims(2)="DualiesAttackRight"
     FireAnims(3)="DualiesAttackRight"
     FireAltAnims(0)="DualiesAttackLeft"
     FireAltAnims(1)="DualiesAttackLeft"
     FireAltAnims(2)="DualiesAttackLeft"
     FireAltAnims(3)="DualiesAttackLeft"
     FireCrouchAnims(0)="CHDualiesAttackRight"
     FireCrouchAnims(1)="CHDualiesAttackRight"
     FireCrouchAnims(2)="CHDualiesAttackRight"
     FireCrouchAnims(3)="CHDualiesAttackRight"
     FireCrouchAltAnims(0)="CHDualiesAttackLeft"
     FireCrouchAltAnims(1)="CHDualiesAttackLeft"
     FireCrouchAltAnims(2)="CHDualiesAttackLeft"
     FireCrouchAltAnims(3)="CHDualiesAttackLeft"
     HitAnims(0)="HitF_Dual9mmm"
     HitAnims(1)="HitB_Dual9mm"
     HitAnims(2)="HitL_Dual9mm"
     HitAnims(3)="HitR_Dual9mm"
     PostFireBlendStandAnim="Blend_Dual9mm"
     PostFireBlendCrouchAnim="CHBlend_Dual9mm"
     Mesh=SkeletalMesh'KF_Weapons3rd_Trip.Single9mm_3rd'
}
