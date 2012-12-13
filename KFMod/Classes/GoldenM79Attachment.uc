//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GoldenM79Attachment extends M79Attachment;

#exec OBJ LOAD FILE=KF_Weapons3rd_Gold_T.utx

var		array<string>	SkinRefs;

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
    local int i;

    Super.PreloadAssets(Spawned);

	for ( i = 0; i < default.SkinRefs.Length; i++ )
	{
		default.Skins[i] = Material(DynamicLoadObject(default.SkinRefs[i], class'Material'));
    	Spawned.Skins[i] = default.Skins[i];
	}
}

defaultproperties
{
     SkinRefs(0)="KF_Weapons3rd_Gold_T.Weapons.Gold_3rdP_M79_cmb"
}
