//=============================================================================
// GoldenM79Pickup
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class GoldenAK47Pickup extends AK47Pickup;

#exec OBJ LOAD FILE=KF_Weapons3rd_Gold_T.utx

defaultproperties
{
     Description="Take a classic AK. Gold plate every visible piece of metal. Engrave the wood for good measure. Serious blingski."
     ItemName="Golden AK47"
     ItemShortName="Golden AK47"
     InventoryType=Class'KFMod.GoldenAK47AssaultRifle'
     PickupMessage="You got the Golden AK47"
     Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_AK47_3rd'
}
