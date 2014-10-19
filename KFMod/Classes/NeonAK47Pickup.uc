//=============================================================================
// NeonAK47Pickup
//=============================================================================
//
//=============================================================================
// Killing Floor Source
// Copyright (C) 2014 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class NeonAK47Pickup extends AK47Pickup;

#exec OBJ LOAD FILE=KF_Weapons_Neon_Trip_T.utx

defaultproperties
{
     Description="It's a neon AK47."
     ItemName="Neon AK47"
     ItemShortName="Neon AK47"
     InventoryType=Class'KFMod.NeonAK47AssaultRifle'
     PickupMessage="You got the Neon AK47"
     Skins(0)=Shader'KF_Weapons_Neon_Trip_T.3rdPerson.AK47_Neon_SHDR_3P'
}
