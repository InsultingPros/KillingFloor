class SpeciesType extends Object
	abstract
	native;

// if _RO_
//#EXEC OBJ LOAD FILE=UT2004Weapons.utx

var string	MaleVoice;
var string	FemaleVoice;
// if _RO_
//var string	GibGroup;
var string	MaleRagSkelName;
var string	FemaleRagSkelName;
var string	FemaleSkeleton;
var string	MaleSkeleton;
var string	MaleSoundGroup;
var string	FemaleSoundGroup;
var string  PawnClassName;
var localized string SpeciesName;	// human readable name, for menus
var int RaceNum;
var int DMTeam;		// team color used in DM

var name TauntAnims[16];
var localized string TauntAnimNames[16];

var float AirControl, GroundSpeed, WaterSpeed, JumpZ, ReceivedDamageScaling, DamageScaling, AccelRate, WalkingPct,CrouchedPct,DodgeSpeedFactor, DodgeSpeedZ;

static function string GetVoiceType( bool bIsFemale, LevelInfo Level )
{
	if ( bIsFemale )
	{
		if ( Level.bLowSoundDetail )
			return "XGame.JuggFemaleVoice";
		else
			return Default.FemaleVoice;
	}

	if ( Level.bLowSoundDetail )
		return "XGame.JuggMaleVoice";
	else
		return Default.MaleVoice;
}

static function LoadResources( xUtil.PlayerRecord rec, LevelInfo Level, PlayerReplicationInfo PRI, int TeamNum )
{
	local string BodySkinName, VoiceType, SkelName, FaceSkinName;
	local Material NewBodySkin, NewFaceSkin, TeamFaceSkin;
	local class<VoicePack> VoiceClass;
	// if _RO_
	//local class<xPawnGibGroup> GibGroupClass;
	local mesh customskel;

	if ( (Level.NetMode != NM_DedicatedServer) && class'DeathMatch'.default.bForceDefaultCharacter )
		return;
    DynamicLoadObject(rec.MeshName,class'Mesh');

	if ( (Level.NetMode != NM_DedicatedServer) && (rec.Skeleton != "") )
		customskel = mesh(DynamicLoadObject(rec.Skeleton,class'Mesh'));

	if ( rec.Sex ~= "Female" )
	{
		SkelName = Default.FemaleSkeleton;
		if ( Level.bLowSoundDetail )
			DynamicLoadObject("XGame.xJuggFemaleSoundGroup", class'Class');
		else
			DynamicLoadObject(Default.FemaleSoundGroup, class'Class');
	}
	else
	{
		SkelName = Default.MaleSkeleton;
		if ( Level.bLowSoundDetail )
			DynamicLoadObject("XGame.xJuggMaleSoundGroup", class'Class');
		else
			DynamicLoadObject(Default.MaleSoundGroup, class'Class');
	}
	if ( Level.NetMode == NM_DedicatedServer )
	{
		if ( rec.Sex ~= "Female" )
			VoiceClass = class<VoicePack>(DynamicLoadObject("XGame.JuggFemaleVoice",class'Class'));
		else
			VoiceClass = class<VoicePack>(DynamicLoadObject("XGame.JuggMaleVoice",class'Class'));
		if ( PRI != None )
			PRI.VoiceType = VoiceClass;
		return;
	}

	if ( !Level.bLowSoundDetail && (rec.VoiceClassName != "") )
	{
		VoiceType = rec.VoiceClassName;
		VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	}
	if ( VoiceClass == None )
	{
		VoiceType = GetVoiceType(rec.Sex ~= "Female", Level);
		class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	}

	if ( (CustomSkel == None) && (SkelName != "") )
		DynamicLoadObject(SkelName,class'Mesh');

	NewFaceSkin = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));

	if ( (TeamNum == 255) && (Level.GRI != None) && Level.GRI.bForceTeamSkins )
		TeamNum = Default.DMTeam;
	if ( (TeamNum != 255) && ((Level.GRI == None) || !Level.GRI.bNoTeamSkins) )
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

			// allow team head skins with new skins
			if ( rec.TeamFace )
			{
				FaceSkinName = rec.FaceSkinName$"_"$TeamNum;
				TeamFaceSkin = Material(DynamicLoadObject(FaceSkinName, class'Material'));
				if ( TeamFaceSkin != None )
					NewFaceSkin = TeamFaceSkin;
			}
		}
		if ( NewBodySkin == None )
		{
			log("TeamSkin not found "$NewBodySkin);
			NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
		}
	}
	else
		NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));

	// Xan hack
	if ( Rec.BodySkinName ~= "UT2004PlayerSkins.XanMk3V2_Body" )
		DynamicLoadObject("UT2004PlayerSkins.XanMk3V2_abdomen", class'Material');

	Level.AddPrecacheMaterial(NewBodySkin);
	Level.AddPrecacheMaterial(NewFaceSkin);
	Level.AddPrecacheMaterial(rec.Portrait);
	// if _RO_
	//GibGroupClass = class<xPawnGibGroup>(DynamicLoadObject(Default.GibGroup, class'Class'));
	//GibGroupClass.static.PrecacheContent(Level);
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
	if(InStr(MeshName, "Female") >= 0)
		return Default.FemaleRagSkelName;

	return Default.MaleRagSkelName;
}

static function SetTeamSkin(xPawn P, xUtil.PlayerRecord rec, int TeamNum)
{
	local string BodySkinName, FaceSkinName;
	local Material NewBodySkin, TeamFaceSkin, NewFaceSkin;

	NewFaceSkin = Material(DynamicLoadObject(rec.FaceSkinName, class'Material'));
	P.TeamSkin = TeamNum;
	P.bClearWeaponOffsets = rec.ZeroWeaponOffsets;

	// Temp commented out - Ramm
	/*if ( TeamNum == 0 )
		P.Texture = Texture'RedMarker_t';
	else
		P.Texture = Texture'BlueMarker_t';*/

	if ( (TeamNum != 255) && ((P.Level.GRI == None) || !P.Level.GRI.bNoTeamSkins) )
	{
		if ( class'DMMutator'.Default.bBrightSkins && (Left(rec.BodySkinName,12) ~= "PlayerSkins.") )
		{
			BodySkinName = "Bright"$rec.BodySkinName$"_"$TeamNum$"B";
			NewBodySkin = Material(DynamicLoadObject(BodySkinName, class'Material',true));
			if ( NewBodySkin != None )
				P.AmbientGlow = 0.5 * P.Default.AmbientGlow;
		}
		if ( NewBodySkin == None )
		{
			BodySkinName = rec.BodySkinName$"_"$TeamNum;
			NewBodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));

			// allow team head skins with new skins
			if ( rec.TeamFace )
			{
				FaceSkinName = rec.FaceSkinName$"_"$TeamNum;
				TeamFaceSkin = Material(DynamicLoadObject(FaceSkinName, class'Material'));
				if ( TeamFaceSkin != None )
					NewFaceSkin = TeamFaceSkin;
			}
		}
		if ( NewBodySkin == None )
		{
			log("TeamSkin not found "$NewBodySkin$" for "$P.Mesh);
			NewBodySkin = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));
		}
		P.Skins[0] = NewBodySkin;
	}
	else
		P.Skins[0] = Material(DynamicLoadObject(rec.BodySkinName, class'Material'));

	P.Skins[1] = NewFaceSkin;
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
	// if _RO_
	//XP.GibGroupClass = class<xPawnGibGroup>(DynamicLoadObject(Default.GibGroup, class'Class'));

	if ( XP.Level.NetMode == NM_DedicatedServer )
	{
		if ( rec.Sex ~= "Female" )
			VoiceType = "XGame.JuggFemaleVoice";
		else
			VoiceType = "XGame.JuggMaleVoice";
		VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		XP.VoiceType = VoiceType;
		if ( XP.PlayerReplicationInfo != None )
			XP.PlayerReplicationInfo.VoiceType = VoiceClass;
		XP.VoiceClass = class<TeamVoicePack>(VoiceClass);
	}
	else
	{
		if ( !XP.Level.bLowSoundDetail )
		{
			if ( (XP.PlayerReplicationInfo != None) && (XP.PlayerReplicationInfo.VoiceTypeName != "") )
				VoiceType = XP.PlayerReplicationInfo.VoiceTypeName;
			else
				VoiceType = rec.VoiceClassName;
			if ( VoiceType != "" )
				VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}
		if ( VoiceClass == None )
		{
			VoiceType = GetVoiceType(XP.bIsFemale, XP.Level);
			VoiceClass = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
		}
		XP.VoiceType = VoiceType;
		if ( XP.PlayerReplicationInfo != None )
			XP.PlayerReplicationInfo.VoiceType = VoiceClass;
		XP.VoiceClass = class<TeamVoicePack>(VoiceClass);
	}

	// add unique taunts
	for ( i=0; i<16; i++ )
		if ( Default.TauntAnims[i] != '' )
		{
			j = XP.TauntAnims.Length;
			XP.TauntAnims[j] = Default.TauntAnims[i];
			XP.TauntAnimNames[j] = Default.TauntAnimNames[i];
			if ( j == 15 )
				break;
		}
	return true;
}

static function int GetOffsetForSequence(name Sequence)
{
	local int i;

	for ( i=0; i<16; i++ )
	{
		if ( Default.TauntAnims[i] == '' )
			return -1;
		if ( Default.TauntAnims[i] == Sequence )
			return i;
	}

	return -1;
}

defaultproperties
{
     PawnClassName="xGame.xPawn"
     SpeciesName="Human"
     TauntAnims(0)="gesture_point"
     TauntAnims(1)="gesture_beckon"
     TauntAnims(2)="gesture_halt"
     TauntAnims(3)="gesture_cheer"
     TauntAnims(4)="PThrust"
     TauntAnims(5)="AssSmack"
     TauntAnims(6)="ThroatCut"
     TauntAnims(7)="Specific_1"
     TauntAnims(8)="Gesture_Taunt01"
     TauntAnims(9)="Idle_Character01"
     TauntAnimNames(0)="Point"
     TauntAnimNames(1)="Beckon"
     TauntAnimNames(2)="Halt"
     TauntAnimNames(3)="Cheer"
     TauntAnimNames(4)="Pelvic Thrust"
     TauntAnimNames(5)="Ass Smack"
     TauntAnimNames(6)="Throat Cut"
     TauntAnimNames(7)="Unique"
     TauntAnimNames(8)="Team Taunt"
     TauntAnimNames(9)="Team Idle"
     AirControl=1.000000
     GroundSpeed=1.000000
     WaterSpeed=1.000000
     JumpZ=1.000000
     ReceivedDamageScaling=1.000000
     DamageScaling=1.000000
     AccelRate=1.000000
     WalkingPct=1.000000
     CrouchedPct=1.000000
     DodgeSpeedFactor=1.000000
     DodgeSpeedZ=1.000000
}
