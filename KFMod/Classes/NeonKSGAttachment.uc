//=============================================================================
// NeonKrissMAttachment
//=============================================================================
// Neon Kriss medic gun third person attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2014 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class NeonKSGAttachment extends KSGAttachment;

//#exec OBJ LOAD FILE=KF_Weapons3rd_Gold_T.utx

var		array<string>	SkinRefs;

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
    local int i;

    Super.PreloadAssets(Spawned);

	for ( i = 0; i < default.SkinRefs.Length; i++ )
	{
		default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));

    	if ( Spawned != none )
    	{
        	Spawned.Skins[i] = default.Skins[i];
    	}
	}
}

defaultproperties
{
     SkinRefs(0)="KF_Weapons_Neon_Trip_T.3rdPerson.KSG_Neon_SHDR_3P"
}
