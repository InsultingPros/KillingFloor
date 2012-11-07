//=============================================================================
// Dualies Inventory class
//=============================================================================
class Dualies extends KFWeapon;

var name altFlashBoneName;
var name altTPAnim;
var Actor altThirdPersonActor;
var name altWeaponAttach;

/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
    super.ZoomIn(bAnimateTransition);

    if( bAnimateTransition )
    {
        if( bZoomOutInterrupted )
        {
            PlayAnim('GOTO_Iron',1.0,0.1);
        }
        else
        {
            PlayAnim('GOTO_Iron',1.0,0.1);
        }
    }
}

/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
    local float AnimLength, AnimSpeed;
    super.ZoomOut(false);

    if( bAnimateTransition )
    {
        AnimLength = GetAnimDuration('GOTO_Hip', 1.0);

        if( ZoomTime > 0 && AnimLength > 0 )
        {
            AnimSpeed = AnimLength/ZoomTime;
        }
        else
        {
            AnimSpeed = 1.0;
        }
        PlayAnim('GOTO_Hip',AnimSpeed,0.1);
    }
}


function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType==Class'Single' )
	{
		if( LastHasGunMsgTime<Level.TimeSeconds && PlayerController(Instigator.Controller)!=none )
		{
			LastHasGunMsgTime = Level.TimeSeconds+0.5;
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages',1);
		}
		return True;
	}
	Return Super.HandlePickupQuery(Item);
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;
	return (AIRating + 0.00092 * FMin(800 - VSize(B.Enemy.Location - Instigator.Location),650));
}

function byte BestMode()
{
    return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
    return -0.7;
}

function AttachToPawn(Pawn P)
{
	local name BoneName;

	Super.AttachToPawn(P);

	if(altThirdPersonActor == None)
	{
		altThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(altThirdPersonActor).InitFor(self);
	}
	else altThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
	BoneName = P.GetOffhandBoneFor(self);
	if(BoneName == '')
	{
		altThirdPersonActor.SetLocation(P.Location);
		altThirdPersonActor.SetBase(P);
	}
	else P.AttachToBone(altThirdPersonActor,BoneName);

	if(altThirdPersonActor != None)
		DualiesAttachment(altThirdPersonActor).bIsOffHand = true;
	if(altThirdPersonActor != None && ThirdPersonActor != None)
	{
		DualiesAttachment(altThirdPersonActor).brother = DualiesAttachment(ThirdPersonActor);
		DualiesAttachment(ThirdPersonActor).brother = DualiesAttachment(altThirdPersonActor);
		altThirdPersonActor.LinkMesh(DualiesAttachment(ThirdPersonActor).BrotherMesh);
	}
}

simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);
	if ( altThirdPersonActor != None )
	{
		altThirdPersonActor.Destroy();
		altThirdPersonActor = None;
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if( ThirdPersonActor!=None )
		ThirdPersonActor.Destroy();
	if( altThirdPersonActor!=None )
		altThirdPersonActor.Destroy();
}

//simulated function Vector GetTipLocation()
//{
//    local Coords C;
//    C = GetBoneCoords('tip');
//    return C.Origin;
//}

simulated function vector GetEffectStart()
{
    local Vector RightFlashLoc,LeftFlashLoc;

    RightFlashLoc = GetBoneCoords(default.FlashBoneName).Origin;
    LeftFlashLoc = GetBoneCoords(default.altFlashBoneName).Origin;

    // jjs - this function should actually never be called in third person views
    // any effect that needs a 3rdp weapon offset should figure it out itself

    // 1st person
    if (Instigator.IsFirstPerson())
    {
        if ( WeaponCentered() )
            return CenteredEffectStart();

        if( bAimingRifle )
        {
            if( KFFire(GetFireMode(0)).FireAimedAnim != 'FireLeft_Iron' )
            {
                return RightFlashLoc;
            }
            else // Off hand firing.  Moves tracer to the left.
            {
                return LeftFlashLoc;
            }
    	}
    	else
    	{
            if (GetFireMode(0).FireAnim != 'FireLeft')
            {
                return RightFlashLoc;
            }
            else // Off hand firing.  Moves tracer to the left.
            {
                return LeftFlashLoc;
            }
    	}
    }
    // 3rd person
    else
    {
        return (Instigator.Location +
            Instigator.EyeHeight*Vect(0,0,0.5) +
            Vector(Instigator.Rotation) * 40.0);
    }
}
function GiveTo( pawn Other, optional Pickup Pickup )
{
	local Inventory I;
	local int OldAmmo;
	local bool bNoPickup;

	MagAmmoRemaining = 0;
	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( Single(I)!=None )
		{
			if( WeaponPickup(Pickup)!= none )
			{
				WeaponPickup(Pickup).AmmoAmount[0]+=Weapon(I).AmmoAmount(0);
			}
			else
			{
				OldAmmo = Weapon(I).AmmoAmount(0);
				bNoPickup = true;
			}

			MagAmmoRemaining = Single(I).MagAmmoRemaining;

			I.Destroyed();
			I.Destroy();

			Break;
		}
	}
	if( KFWeaponPickup(Pickup)!=None && Pickup.bDropped )
		MagAmmoRemaining = Clamp(MagAmmoRemaining+KFWeaponPickup(Pickup).MagAmmoRemaining,0,MagCapacity);
	else MagAmmoRemaining = Clamp(MagAmmoRemaining+Class'Single'.Default.MagCapacity,0,MagCapacity);
	Super(Weapon).GiveTo(Other,Pickup);

	if ( bNoPickup )
	{
		AddAmmo(OldAmmo, 0);
		Clamp(Ammo[0].AmmoAmount, 0, MaxAmmo(0));
	}
}
function DropFrom(vector StartLocation)
{
	local int m;
	local Pickup Pickup;
	local Inventory I;
	local int AmmoThrown,OtherAmmo;

	if( !bCanThrow )
		return;

	AmmoThrown = AmmoAmount(0);
	ClientWeaponThrown();

	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m].bIsFiring)
			StopFire(m);
	}

	if ( Instigator != None )
		DetachFromPawn(Instigator);

	if( Instigator.Health>0 )
	{
		OtherAmmo = AmmoThrown/2;
		AmmoThrown-=OtherAmmo;
		I = Spawn(Class'Single');
		I.GiveTo(Instigator);
		Weapon(I).Ammo[0].AmmoAmount = OtherAmmo;
		Single(I).MagAmmoRemaining = MagAmmoRemaining/2;
		MagAmmoRemaining = Max(MagAmmoRemaining-Single(I).MagAmmoRemaining,0);
	}
	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity;
		WeaponPickup(Pickup).AmmoAmount[0] = AmmoThrown;
		if( KFWeaponPickup(Pickup)!=None )
			KFWeaponPickup(Pickup).MagAmmoRemaining = MagAmmoRemaining;
		if (Instigator.Health > 0)
			WeaponPickup(Pickup).bThrown = true;
	}

    Destroyed();
	Destroy();
}

simulated function bool PutDown()
{
	if ( Instigator.PendingWeapon.class == class'Single' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}

defaultproperties
{
     altFlashBoneName="Tip_Left"
     altTPAnim="DualiesAttackLeft"
     altWeaponAttach="Bone_weapon2"
     FirstPersonFlashlightOffset=(X=-15.000000,Z=5.000000)
     MagCapacity=30
     ReloadRate=3.500000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     FlashBoneName="Tip_Right"
     WeaponReloadAnim="Reload_Dual9mm"
     HudImage=Texture'KillingFloorHUD.WeaponSelect.dual_9mm_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.dual_9mm'
     Weight=4.000000
     bTorchEnabled=True
     bDualWeapon=True
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Dual_9mm'
     ZoomInRotation=(Pitch=0,Roll=0)
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'KFMod.DualiesFire'
     FireModeClass(1)=Class'KFMod.SingleALTFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KFPlayerSound.getweaponout'
     AIRating=0.440000
     CurrentRating=0.440000
     bShowChargingBar=True
     Description="A pair of custom 9mm pistols. What they lack in stopping power, they compensate for with a quick refire."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=65
     InventoryGroup=2
     GroupOffset=2
     PickupClass=Class'KFMod.DualiesPickup'
     PlayerViewOffset=(X=20.000000,Z=-7.000000)
     BobDamping=7.000000
     AttachmentClass=Class'KFMod.DualiesAttachment'
     IconCoords=(X1=229,Y1=258,X2=296,Y2=307)
     ItemName="Dual 9mms"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Dual9mm'
     DrawScale=0.900000
     Skins(0)=Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_cmb'
     TransientSoundVolume=1.000000
}
