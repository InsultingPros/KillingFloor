//=============================================================================
// DualMK23
//=============================================================================
// Dual MK23 Pistol Inventory Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class DualMK23Pistol extends Dualies;

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType==Class'MK23Pistol' )
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
		DualMK23Attachment(altThirdPersonActor).bIsOffHand = true;
	if(altThirdPersonActor != None && ThirdPersonActor != None)
	{
		DualMK23Attachment(altThirdPersonActor).brother = DualMK23Attachment(ThirdPersonActor);
		DualMK23Attachment(ThirdPersonActor).brother = DualMK23Attachment(altThirdPersonActor);
		altThirdPersonActor.LinkMesh(DualMK23Attachment(ThirdPersonActor).BrotherMesh);
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
		if ( MK23Pistol(I) != none )
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

			MagAmmoRemaining = MK23Pistol(I).MagAmmoRemaining;

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
		MagAmmoRemaining = Clamp(MagAmmoRemaining + Class'MK23Pistol'.Default.MagCapacity, 0, MagCapacity);
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
		I = Spawn(Class'MK23Pistol');
		I.GiveTo(Instigator);
		Weapon(I).Ammo[0].AmmoAmount = OtherAmmo;
		MK23Pistol(I).MagAmmoRemaining = MagAmmoRemaining / 2;
		MagAmmoRemaining = Max(MagAmmoRemaining-MK23Pistol(I).MagAmmoRemaining,0);
	}

	Pickup = Spawn(Class'MK23Pickup',,, StartLocation);

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
	if ( Instigator.PendingWeapon.class == class'MK23Pistol' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}

defaultproperties
{
     MagCapacity=24
     ReloadRate=4.466700
     HudImage=None
     SelectedHudImage=None
     bTorchEnabled=False
     StandardDisplayFOV=60.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Dual_MK23'
     bIsTier2Weapon=True
     MeshRef="KF_Wep_Dual_MK23.Dual_MK23"
     SkinRefs(0)="KF_Weapons5_Trip_T.Weapons.MK23_SHDR"
     SelectSoundRef="KF_MK23Snd.MK23_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Dual_MK23_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Dual_MK23"
     ZoomedDisplayFOV=50.000000
     FireModeClass(0)=Class'KFMod.DualMK23Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     SelectSound=None
     AIRating=0.450000
     CurrentRating=0.450000
     Description="Dual MK23 match grade pistols. Dual 45's is double the fun."
     DisplayFOV=60.000000
     Priority=90
     GroupOffset=8
     PickupClass=Class'KFMod.DualMK23Pickup'
     PlayerViewOffset=(X=25.000000)
     BobDamping=3.800000
     AttachmentClass=Class'KFMod.DualMK23Attachment'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="Dual MK23s"
     Mesh=None
     DrawScale=1.000000
     Skins(0)=None
}
