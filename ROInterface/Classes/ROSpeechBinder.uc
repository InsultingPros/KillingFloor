//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROSpeechBinder extends SpeechBinder;

var()	Texture				mytexture;

var class<ROVoicePack> ROVoiceClass;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    Super.InitComponent(InController, InOwner);

    class'ROInterfaceUtil'.static.SetROStyle(InController, Controls);

    sb_Main.HeaderTop=mytexture;
    sb_Main.HeaderBar=mytexture;
    sb_Main.HeaderBase=mytexture;

    /*myStyleName = "ROTitleBar";
    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = InController.GetStyle(myStyleName,t_WindowTitle.FontScale);

    myStyleName = "ROListSelection";
    SectionStyleName = myStyleName;
    SectionStyle = InController.GetStyle(myStyleName,li_Binds.FontScale);*/
}

function bool SystemMenuPreDraw(canvas Canvas)
{
	b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + (t_WindowTitle.ActualWidth()-35), t_WindowTitle.ActualTop()+10, 24, 24, true);
	return true;
}

function LoadCommands()
{
	local int i;
	local array<string> VoiceCommands;

	Super.LoadCommands();

	ResetVoiceClass();
	if ( ROVoiceClass == None )
		return;

    //////////////////////////////// SUPPORT /////////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[1], True);

	ROVoiceClass.static.GetAllSupports( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech SUPPORT" @ i, VoiceCommands[i], False );

   	//////////////////////////////// ACKNOWLEDGEMENTS /////////////////////////////////////////////
    // CreateAliasMapping("", class'ExtendedConsole'.default.SMStateName[2], True );
	CreateAliasMapping("", class'ROConsole'.default.SMStateName[2], true );

	ROVoiceClass.static.GetAllAcknowledges( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech ACK" @ i, VoiceCommands[i], false );

	//////////////////////////////// ENEMY /////////////////////////////////////////////
    CreateAliasMapping("", class'ROConsole'.default.SMStateName[3], true );

	ROVoiceClass.static.GetAllEnemies( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech ENEMY" @ i, VoiceCommands[i], False );

	//////////////////////////////// ALERT /////////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[4], True);

	ROVoiceClass.static.GetAllAlerts( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech ALERT" @ i, VoiceCommands[i], false );

	//////////////////////////////// VEH_ORDERS /////////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[5], True);

	ROVoiceClass.static.GetAllVehicleDirections( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech VEH_ORDERS" @ i, VoiceCommands[i], false );


	//////////////////////////////// VEH_ALERTS /////////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[6], True);

	ROVoiceClass.static.GetAllVehicleAlerts( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech VEH_ALERTS" @ i, VoiceCommands[i], False );

    /////////////////////////////////////// COMMANDS ///////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[7], True);

	ROVoiceClass.static.GetAllOrders( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech COMMANDS" @ i, VoiceCommands[i], false );

    /////////////////////////////////////// EXTRAS ///////////////////////////////////////////
	CreateAliasMapping( "", class'ROConsole'.default.SMStateName[8], True);

	ROVoiceClass.static.GetAllExtras( VoiceCommands );
	for ( i = 0; i < VoiceCommands.Length; i++ )
		CreateAliasMapping( "speech EXTRAS" @ i, VoiceCommands[i], false );

}

function ResetVoiceClass()
{
	local PlayerController PC;
	local string CharString;
	local xUtil.PlayerRecord Rec;

	PC = PlayerOwner();
	ROVoiceClass = None;

	if ( VoiceType != "" )
		ROVoiceClass = class<ROVoicePack>(DynamicLoadObject(VoiceType,class'Class',true));

	if ( ROVoiceClass == None && PC.PlayerReplicationInfo != None )
	{
		if ( PC.PlayerReplicationInfo.VoiceType != None && class<ROVoicePack>(PC.PlayerReplicationInfo.VoiceType) != None )
			ROVoiceClass = class<ROVoicePack>(PC.PlayerReplicationInfo.VoiceType);
		else if ( PC.PlayerReplicationInfo.VoiceTypeName != "" )
			ROVoiceClass = class<ROVoicePack>(DynamicLoadObject(PC.PlayerReplicationInfo.VoiceTypeName,class'Class'));
	}

	if ( ROVoiceClass == None )
	{
		VoiceType = PC.GetURLOption("Voice");
		if ( VoiceType == "" )
		{
			CharString = PC.GetURLOption("Character");
			if ( CharString != "" )
			{
				Rec = class'xUtil'.static.FindPlayerRecord(CharString);
				if ( Rec.VoiceClassName != "" )
					VoiceType = Rec.VoiceClassName;

				else if ( Rec.Species != None )
					VoiceType = Rec.Species.static.GetVoiceType(Rec.Sex ~= "Female", PC.Level);
			}
		}


		if ( VoiceType != "" )
			ROVoiceClass = class<ROVoicePack>(DynamicLoadObject(VoiceType, class'Class'));
	}

	VoiceType = "";
}

defaultproperties
{
     MyTexture=Texture'InterfaceArt_tex.Menu.button_normal'
     Begin Object Class=GUIImage Name=BindBk
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         ImageStyle=ISTY_Stretched
         WinTop=0.057552
         WinLeft=0.031397
         WinWidth=0.937207
         WinHeight=0.808281
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_bk=GUIImage'ROInterface.ROSpeechBinder.BindBk'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     i_FrameBG=FloatingImage'ROInterface.ROSpeechBinder.FloatingFrameBackground'

}
