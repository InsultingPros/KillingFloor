//=============================================================================
// ROSPECIES_Human
//=============================================================================
// SpeciesType for RO
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROSPECIES_Human extends SpeciesType
	abstract;

static function LoadResources( xUtil.PlayerRecord rec, LevelInfo Level, PlayerReplicationInfo PRI, int TeamNum )
{
	local string /*BodySkinName,*/ VoiceType, SkelName;
	local Material NewBodySkin, NewFaceSkin;
	local class<VoicePack> VoiceClass;
	local xPlayerReplicationInfo xPRI;
	local mesh customskel;

	//if ( class'DeathMatch'.default.bForceDefaultCharacter )
	//	return;

    DynamicLoadObject(rec.MeshName,class'Mesh');

	if ( rec.Skeleton != "" )
		customskel = mesh(DynamicLoadObject(rec.Skeleton,class'Mesh'));

	/*if ( rec.Sex ~= "Female" )
	{
		SkelName = Default.FemaleSkeleton;
		//if ( Level.bLowSoundDetail )
		//	DynamicLoadObject("XGame.xJuggFemaleSoundGroup", class'Class');
		//else
			DynamicLoadObject(Default.FemaleSoundGroup, class'Class');
	}
	else
	{*/
		SkelName = Default.MaleSkeleton;
		//if ( Level.bLowSoundDetail )
		//	DynamicLoadObject("XGame.xJuggMaleSoundGroup", class'Class');
		//else
			DynamicLoadObject(Default.MaleSoundGroup, class'Class');
	//}

	if ( !Level.bLowSoundDetail && (rec.VoiceClassName != "") )
	{
		VoiceType = rec.VoiceClassName;
		VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	}
	if ( VoiceClass == None )
	{
		/*if ( rec.Sex ~= "Female" )
		{
			if ( Level.bLowSoundDetail )
				VoiceType = "XGame.JuggFemaleVoice";
			else
				VoiceType = Default.FemaleVoice;
		}
		else
		{*/
			//if ( Level.bLowSoundDetail )
			//	VoiceType = "XGame.JuggMaleVoice";
			//else
				VoiceType = Default.MaleVoice;
		//}
		class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		if ( Level.NetMode == NM_DedicatedServer )
			return;

		if ( (CustomSkel == None) && (SkelName != "") )
			DynamicLoadObject(SkelName,class'Mesh');

		xPRI = xPlayerReplicationInfo(PRI);

		/*if ( (TeamNum != 255) && ((xPRI == None) || !xPRI.bNoTeamSkins) )
		{
			if ( class'DMMutator'.Default.bBrightSkins && (Left(rec.BodySkinName,12) ~= "PlayerSkins.") )
			{
				BodySkinName = "Bright"$rec.BodySkinName$"_"$TeamNum$"B";
				NewBodySkin = Material(DynamicLoadObject(BodySkinName, class'Material',true));
			}
			if ( NewBodySkin == None )
			{
				BodySkinName = rec.BodySkinName$"_"$TeamNum;
				NewBodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
			}
			if ( NewBodySkin == None )
			{
				log("TeamSkin not found "$NewBodySkin);
				NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
			}
		}
		else*/
			NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));

		NewFaceSkin = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));
		Level.AddPrecacheMaterial(NewBodySkin);
		Level.AddPrecacheMaterial(NewFaceSkin);
		Level.AddPrecacheMaterial(rec.Portrait);

		// Precache the Pawn's content
		class'ROPawn'.static.StaticPrecache(Level);
	}
}

static function int ModifyReceivedDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	return Damage * Default.ReceivedDamageScaling;
}

static function int ModifyImpartedDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	return Damage * Default.DamageScaling;
}

static function ModifyPawn(Pawn P)
{
	P.AirControl = P.Default.AirControl * Default.AirControl;
	P.GroundSpeed = P.Default.GroundSpeed * Default.GroundSpeed;
	P.WaterSpeed = P.Default.WaterSpeed * Default.WaterSpeed;
	P.JumpZ = P.Default.JumpZ * Default.JumpZ;
	P.AccelRate = P.Default.AccelRate * Default.AccelRate;
	P.WalkingPct = P.Default.WalkingPct * Default.WalkingPct;
	P.CrouchedPct = P.Default.CrouchedPct * Default.CrouchedPct;
	P.DodgeSpeedFactor = P.Default.DodgeSpeedFactor * Default.DodgeSpeedFactor;
	P.DodgeSpeedZ = P.Default.DodgeSpeedZ * Default.DodgeSpeedZ;
}

static function string GetRagSkelName(string MeshName)
{
	//if(InStr(MeshName, "Female") >= 0)
	//	return Default.FemaleRagSkelName;
	//else if(InStr(MeshName, "Male") >= 0)
		return Default.MaleRagSkelName;
	//return "";
}

static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	local mesh NewMesh, customskel;
	local string SkelName;
	local class<VoicePack> VoiceClass;
	local ROPawn ROP;

	// Cast the pawn to an ROPawn
	ROP = ROPawn(P);

	if ( ROP == none )
	{
		log("ROSPECIES_Human setup error.");
		return false;
	}

    NewMesh = Mesh(DynamicLoadObject(rec.MeshName,class'Mesh'));
    if ( NewMesh == None )
		return false;

	ROP.LinkMesh(NewMesh);
	ROP.AssignInitialPose();

	ROP.bIsFemale = false; //( rec.Sex ~= "Female" );
	ROP.PlayerReplicationInfo.bIsFemale = ROP.bIsFemale;
	if ( rec.Skeleton != "" )
		customskel = mesh(DynamicLoadObject(rec.Skeleton,class'Mesh'));

	if ( ROP.bIsFemale )
	{
		SkelName = Default.FemaleSkeleton;
		//if ( P.Level.bLowSoundDetail )
		//	P.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject("XGame.xJuggFemaleSoundGroup", class'Class'));
		//else
			ROP.SoundGroupClass = class<ROPawnSoundGroup>(DynamicLoadObject(Default.FemaleSoundGroup, class'Class'));
	}
	else
	{
		SkelName = Default.MaleSkeleton;
		//if ( P.Level.bLowSoundDetail )
		//	P.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject("XGame.xJuggMaleSoundGroup", class'Class'));
		//else
			ROP.SoundGroupClass = class<ROPawnSoundGroup>(DynamicLoadObject(Default.MaleSoundGroup, class'Class'));
	}

	ROP.Skins[0] = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
	ROP.Skins[1] = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));

	// MergeTODO: This is probably where the voice menu problem not appearing happens
	if (ROPlayerReplicationInfo(P.PlayerReplicationInfo).RoleInfo != None)
	{
		ROP.VoiceType = ROPlayerReplicationInfo(P.PlayerReplicationInfo).RoleInfo.default.VoiceType;
		VoiceClass = class<VoicePack>(DynamicLoadObject(ROP.VoiceType,class'Class'));
		ROP.PlayerReplicationInfo.VoiceType = VoiceClass;
		ROP.VoiceClass = class<TeamVoicePack>(VoiceClass);
	}
	return true;
}

defaultproperties
{
     MaleVoice="ROGame.ROGerman1Voice"
     FemaleVoice="ROGame.ROGerman1Voice"
     MaleRagSkelName="German_tunic"
     FemaleRagSkelName="German_tunic"
     MaleSoundGroup="ROEngine.ROPawnSoundGroup"
     FemaleSoundGroup="ROEngine.ROPawnSoundGroup"
     PawnClassName="ROEngine.ROPawn"
     RaceNum=2
}
