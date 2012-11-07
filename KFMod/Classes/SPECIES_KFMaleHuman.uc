class SPECIES_KFMaleHuman extends KFSpeciesType
	abstract;

enum EBoneRotType
{
	BRot_Yaw,
	BRot_Roll,
	BRot_Pitch
};
var() name FeetBones[2],TorsoBones[2],KneeBones[2],IdleAnimationName;
var() EBoneRotType TorseRotType,KneeRotType;
var() int MaxTorsoTurn,MaxKneeTurn;
var() float FootZHeightMod;

var string AgentWilkesTeamSkinNames[2];
var string CorporalLewisTeamSkinNames[2];
var string DJScullyTeamSkinNames[2];
var string DrGaryGloverTeamSkinNames[2];
var string FoundryWorkerAldridgeTeamSkinNames[2];
var string LieutenantMastersonTeamSkinNames[2];
var string PoliceConstableBriarTeamSkinNames[2];
var string PoliceSergeantDavinTeamSkinNames[2];
var string PrivateSchniederTeamSkinNames[2];
var string SergeantPowersTeamSkinNames[2];

var class <SeveredAppendage>	DetachedArmClass;		// class of detached arm to spawn for this species
var class <SeveredAppendage>	DetachedLegClass;		// class of detached arm to spawn for this species

var bool bRandomizedVoice;

static function string GetVoiceType( bool bIsFemale, LevelInfo Level )
{
	return default.MaleVoice;
}

static function LoadResources(xUtil.PlayerRecord rec, LevelInfo Level, PlayerReplicationInfo PRI, int TeamNum)
{
	local string VoiceType, SkelName;
	local Material NewBodySkin, NewFaceSkin;
	local class<VoicePack> VoiceClass;
	local mesh customskel;

	if ( (Level.NetMode != NM_DedicatedServer) && class'DeathMatch'.default.bForceDefaultCharacter )
		return;

    DynamicLoadObject(rec.MeshName,class'Mesh');

	if ( (Level.NetMode != NM_DedicatedServer) && (rec.Skeleton != "") )
		customskel = mesh(DynamicLoadObject(rec.Skeleton,class'Mesh'));

	SkelName = Default.MaleSkeleton;
	DynamicLoadObject(Default.MaleSoundGroup, class'Class');

	if ( Level.NetMode == NM_DedicatedServer )
	{
		if ( rec.VoiceClassName != "" )
		{
			VoiceClass = class<VoicePack>(DynamicLoadObject(rec.VoiceClassName, class'Class'));
		}
		else
		{
			VoiceClass = class<VoicePack>(DynamicLoadObject(default.MaleVoice, class'Class'));
		}

		if ( PRI != None )
			PRI.VoiceType = VoiceClass;

		return;
	}

	if ( rec.Sex ~= "Female" )
	{
		if ( rec.VoiceClassName != "" )
		{
			VoiceType = rec.VoiceClassName;
			VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}

		if ( VoiceClass == None )
		{
			VoiceType = default.FemaleVoice;
			class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}
	}
	else
	{
		if ( bool(Level.ConsoleCommand("get ini:Engine.Engine.AudioDevice LowQualitySound")) )
		{
			VoiceType = Level.DefaultMalePlayerVoice;
			VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}
		else if ( rec.VoiceClassName != "" )
		{
			VoiceType = rec.VoiceClassName;
			VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}

		if ( VoiceClass == None )
		{
			VoiceType = default.MaleVoice;
			class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}
	}

	if ( (CustomSkel == None) && (SkelName != "") )
		DynamicLoadObject(SkelName,class'Mesh');

	NewFaceSkin = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));

	if ( TeamNum == 255 && Level.GRI != none && Level.GRI.bForceTeamSkins )
		TeamNum = Default.DMTeam;

	if ( (TeamNum == 0 || TeamNum == 1) && (Level.GRI == none || !Level.GRI.bNoTeamSkins) )
	{
		if ( rec.DefaultName == "Sergeant_Powers" )
		{
			NewBodySkin = Material(DynamicLoadObject(default.SergeantPowersTeamSkinNames[TeamNum], class'Material',true));
		}

		if ( NewBodySkin == None )
		{
			log("TeamSkin not found "$NewBodySkin);
			NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
		}
	}
	else
		NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));

	Level.AddPrecacheMaterial(NewBodySkin);
	Level.AddPrecacheMaterial(NewFaceSkin);
	Level.AddPrecacheMaterial(rec.Portrait);
}

// Modified this function so we could use pawns instead of xpawns
static function bool Setup(Pawn P, xUtil.PlayerRecord rec)
{
	local mesh NewMesh, customskel;
	local string VoiceType, SkelName;
	local class<VoicePack> VoiceClass;
	local int TeamNum, i,j;
	local XPawn XP;

	// Cast the pawn to an XPawn
	XP = XPawn(P);

	if ( XP == none )
	{
		log("SpeciesType setup error.");
		return false;
	}

	if ( XP.bAlreadySetup )
	{
		// make sure correct teamskin
		if ( XP.Level.NetMode == NM_Client )
		{
			if ( (XP.PlayerReplicationInfo != None) && (XP.PlayerReplicationInfo.Team != None) )
				TeamNum = XP.PlayerReplicationInfo.Team.TeamIndex;
			else if ( (XP.DrivenVehicle != None) && (XP.DrivenVehicle.PlayerReplicationInfo != None) && (XP.DrivenVehicle.PlayerReplicationInfo.Team != None) )
				TeamNum = XP.DrivenVehicle.PlayerReplicationInfo.Team.TeamIndex;
			if ( XP.TeamSkin == TeamNum )
				return true;

			SetTeamSkin(XP,rec,TeamNum);
		}
		return true;
	}
    NewMesh = Mesh(DynamicLoadObject(rec.MeshName,class'Mesh'));
    if ( NewMesh == None )
    {
		log("Failed to load player mesh "$rec.MeshName);
		return false;
	}

	XP.bAlreadySetup = true;
	XP.LinkMesh(NewMesh);
	XP.AssignInitialPose();

	XP.bIsFemale = ( rec.Sex ~= "Female" );
	if ( XP.PlayerReplicationInfo != None )
		XP.PlayerReplicationInfo.bIsFemale = XP.bIsFemale;
	if ( (XP.Level.NetMode != NM_DedicatedServer) && (rec.Skeleton != "") )
		customskel = mesh(DynamicLoadObject(rec.Skeleton,class'Mesh'));

	if ( XP.bIsFemale )
	{
		SkelName = Default.FemaleSkeleton;
		if ( XP.Level.bLowSoundDetail )
			XP.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject("XGame.xJuggFemaleSoundGroup", class'Class'));
		else
			XP.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject(Default.FemaleSoundGroup, class'Class'));
	}
	else
	{
		SkelName = Default.MaleSkeleton;
		if ( XP.Level.bLowSoundDetail )
			XP.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject("XGame.xJuggMaleSoundGroup", class'Class'));
		else
			XP.SoundGroupClass = class<xPawnSoundGroup>(DynamicLoadObject(Default.MaleSoundGroup, class'Class'));
	}

	if ( XP.Level.NetMode != NM_DedicatedServer )
	{
		if ( CustomSkel != None )
			XP.SkeletonMesh = CustomSkel;
		else if ( SkelName != "" )
			XP.SkeletonMesh = mesh(DynamicLoadObject(SkelName,class'Mesh'));

		TeamNum = 255;
		if ( (XP.PlayerReplicationInfo != None) && (XP.PlayerReplicationInfo.Team != None) )
			TeamNum = XP.PlayerReplicationInfo.Team.TeamIndex;
		else if ( (XP.DrivenVehicle != None) && (XP.DrivenVehicle.PlayerReplicationInfo != None) && (XP.DrivenVehicle.PlayerReplicationInfo.Team != None) )
			TeamNum = XP.DrivenVehicle.PlayerReplicationInfo.Team.TeamIndex;
		else if ( (XP.Level.GRI != None) && XP.Level.GRI.bForceTeamSkins )
			TeamNum = Default.DMTeam;

		SetTeamSkin(XP,rec,TeamNum);

		if ( rec.UseSpecular && (XP.Level.DetailMode!=DM_Low) )
		{
			// ifndef _RO_
			//XP.HighDetailOverlay = Material'UT2004Weapons.WeaponShader';
			// Xan hack
			if ( Rec.BodySkinName ~= "UT2004PlayerSkins.XanMk3V2_Body" )
				XP.Skins[2] = Material(DynamicLoadObject("UT2004PlayerSkins.XanMk3V2_abdomen", class'Material'));
		}
	}

	if ( rec.VoiceClassName != "" )
	{
		VoiceType = rec.VoiceClassName;
	}
	else
	{
		VoiceType = default.MaleVoice;
	}

	VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType, class'Class'));

	if ( XP.PlayerReplicationInfo != None )
		XP.PlayerReplicationInfo.VoiceType = VoiceClass;

	XP.VoiceClass = class<TeamVoicePack>(VoiceClass);
	XP.VoiceType = VoiceType;

	// add unique taunts
	for ( i=0; i<16; i++ )
	{
		if ( Default.TauntAnims[i] != '' )
		{
			j = XP.TauntAnims.Length;
			XP.TauntAnims[j] = Default.TauntAnims[i];
			XP.TauntAnimNames[j] = Default.TauntAnimNames[i];
			if ( j == 15 )
				break;
		}
	}

	return true;
}

static function SetTeamSkin(xPawn P, xUtil.PlayerRecord rec, int TeamNum)
{
	local Material NewBodySkin, NewFaceSkin;

	NewFaceSkin = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));
	P.TeamSkin = TeamNum;
	P.bClearWeaponOffsets = rec.ZeroWeaponOffsets;

	if ( (TeamNum == 0 || TeamNum == 1) && ((P.Level.GRI == None) || !P.Level.GRI.bNoTeamSkins) )
	{
		if ( rec.DefaultName == "Sergeant_Powers" )
		{
			NewBodySkin = Material(DynamicLoadObject(default.SergeantPowersTeamSkinNames[TeamNum], class'Material',true));
		}

		if ( NewBodySkin == None )
		{
			log("TeamSkin not found "$rec.DefaultName);
			NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
		}

		P.Skins[0] = NewBodySkin;
	}
	else
		P.Skins[0] = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));

	P.Skins[1] = NewFaceSkin;
}

defaultproperties
{
     FeetBones(0)="Bip01 L Foot"
     FeetBones(1)="Bip01 R Foot"
     TorsoBones(0)="Bip01 L Calf"
     TorsoBones(1)="Bip01 R Calf"
     KneeBones(0)="Bip01 L Thigh"
     KneeBones(1)="Bip01 R Thigh"
     IdleAnimationName="Idle_Rest"
     MaxTorsoTurn=-20000
     MaxKneeTurn=22000
     FootZHeightMod=-1.000000
     DetachedArmClass=Class'KFMod.SeveredArmSoldier'
     DetachedLegClass=Class'KFMod.SeveredLegSoldier'
     MaleVoice="KFMod.KFVoicePack"
     FemaleVoice="KFMod.KFVoicePack"
     MaleRagSkelName="British_Soldier1"
     FemaleRagSkelName="Female2"
     FemaleSkeleton="HumanFemaleA.Skeleton_Female"
     MaleSkeleton="HumanMaleA.SkeletonMale"
     MaleSoundGroup="KFmod.KFMaleSoundGroup"
     FemaleSoundGroup="KFmod.KFMaleSoundGroup"
}
