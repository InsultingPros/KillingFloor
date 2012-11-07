Class KFPawnFootAdjuster extends Actor;

var KFPawn AdjustingPawn;
var Class<SPECIES_KFMaleHuman> SpecType;

Auto state Setup
{
	function InitBoneZ( bool bMax )
	{
		local Coords C;

		C = GetBoneCoords(SpecType.Default.FeetBones[0]);
		C.Origin.Z-=SpecType.Default.FootZHeightMod;
		if( bMax )
			AdjustingPawn.MaxZHeight = -C.Origin.Z;
		else
		{
			AdjustingPawn.MinZHeight = -C.Origin.Z;
			AdjustingPawn.MaxZHeight-=C.Origin.Z;
		}
	}
	function InitBoneRots()
	{
		local rotator R;

		switch( SpecType.Default.TorseRotType )
		{
		case BRot_Yaw:
			R.Yaw = SpecType.Default.MaxTorsoTurn;
			break;
		case BRot_Roll:
			R.Roll = SpecType.Default.MaxTorsoTurn;
			break;
		default:
			R.Pitch = SpecType.Default.MaxTorsoTurn;
		}
		SetBoneRotation(SpecType.Default.TorsoBones[0],R);
		R = rot(0,0,0);
		switch( SpecType.Default.KneeRotType )
		{
		case BRot_Yaw:
			R.Yaw = SpecType.Default.MaxKneeTurn;
			break;
		case BRot_Roll:
			R.Roll = SpecType.Default.MaxKneeTurn;
			break;
		default:
			R.Pitch = SpecType.Default.MaxKneeTurn;
		}
		SetBoneRotation(SpecType.Default.KneeBones[0],R);
	}
Begin:
	Sleep(0.01);
	TweenAnim(SpecType.Default.IdleAnimationName,0);
	Sleep(0.1);
	InitBoneZ(True);
	InitBoneRots();
	Sleep(0.1);
	InitBoneZ(False);
	AdjustingPawn.bHasFootAdjust = True;
	Destroy();
}

defaultproperties
{
     DrawType=DT_Mesh
     bHidden=True
     RemoteRole=ROLE_None
}
