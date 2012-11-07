//=============================================================================
// Dual44Magnum
//=============================================================================
// Dual 44 Magnum Pistols Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Dual44Magnum extends Dualies;

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType==Class'Magnum44Pistol' )
	{
		if( LastHasGunMsgTime < Level.TimeSeconds && PlayerController(Instigator.Controller) != none )
		{
			LastHasGunMsgTime = Level.TimeSeconds + 0.5;
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 1);
		}

		return True;
	}

	return Super.HandlePickupQuery(Item);
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
		Dual44MagnumAttachment(altThirdPersonActor).bIsOffHand = true;
	if(altThirdPersonActor != None && ThirdPersonActor != None)
	{
		Dual44MagnumAttachment(altThirdPersonActor).brother = Dual44MagnumAttachment(ThirdPersonActor);
		Dual44MagnumAttachment(ThirdPersonActor).brother = Dual44MagnumAttachment(altThirdPersonActor);
		altThirdPersonActor.LinkMesh(Dual44MagnumAttachment(ThirdPersonActor).BrotherMesh);
	}
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
	local Inventory I;
	local int OldAmmo;
	local bool bNoPickup;

	MagAmmoRemaining = 0;

	For( I = Other.Inventory; I != None; I =I.Inventory )
	{
		if ( Magnum44Pistol(I) != none )
		{
			if( WeaponPickup(Pickup)!= none )
			{
				WeaponPickup(Pickup).AmmoAmount[0] += Weapon(I).AmmoAmount(0);
			}
			else
			{
				OldAmmo = Weapon(I).AmmoAmount(0);
				bNoPickup = true;
			}

			MagAmmoRemaining = Magnum44Pistol(I).MagAmmoRemaining;

			I.Destroyed();
			I.Destroy();

			Break;
		}
	}

	if ( KFWeaponPickup(Pickup) != None && Pickup.bDropped )
	{
		MagAmmoRemaining = Clamp(MagAmmoRemaining + KFWeaponPickup(Pickup).MagAmmoRemaining, 0, MagCapacity);
	}
	else
	{
		MagAmmoRemaining = Clamp(MagAmmoRemaining + Class'Magnum44Pistol'.Default.MagCapacity, 0, MagCapacity);
	}

	Super(Weapon).GiveTo(Other, Pickup);

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
	local int AmmoThrown, OtherAmmo;

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

	if( Instigator.Health > 0 )
	{
		OtherAmmo = AmmoThrown / 2;
		AmmoThrown -= OtherAmmo;
		I = Spawn(Class'Magnum44Pistol');
		I.GiveTo(Instigator);
		Weapon(I).Ammo[0].AmmoAmount = OtherAmmo;
		Magnum44Pistol(I).MagAmmoRemaining = MagAmmoRemaining / 2;
		MagAmmoRemaining = Max(MagAmmoRemaining-Magnum44Pistol(I).MagAmmoRemaining,0);
	}

	Pickup = Spawn(Class'Magnum44Pickup',,, StartLocation);

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
	if ( Instigator.PendingWeapon.class == class'Magnum44Pistol' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}

defaultproperties
{
     MagCapacity=12
     ReloadRate=4.466700
     WeaponReloadAnim="Reload_DualRevolver"
     HudImage=None
     SelectedHudImage=None
     bTorchEnabled=False
     StandardDisplayFOV=60.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_DualRevolver'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_DualRevolver.DualRevolver_Trip"
     SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.Revolver_cmb"
     SelectSoundRef="KF_RevolverSnd.WEP_Revolver_Foley_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.DualRevolver_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.DualRevolver"
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.Dual44MagnumFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     SelectSound=None
     AIRating=0.450000
     CurrentRating=0.450000
     Description="Dual 44 Magnum Pistols. Make my day!"
     DisplayFOV=60.000000
     Priority=120
     GroupOffset=6
     PickupClass=Class'KFMod.Dual44MagnumPickup'
     PlayerViewOffset=(X=25.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.Dual44MagnumAttachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="Dual 44 Magnums"
     Mesh=None
     DrawScale=1.000000
     Skins(0)=None
}
