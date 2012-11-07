//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFVoicePack extends xVoicePack;

var() SoundGroup SupportSound[20];
var() localized string SupportString[48];
var() localized string SupportAbbrev[48];
var() name SupportAnim[48];
var() int NumSupports;

var() SoundGroup AcknowledgmentSound[20];
var() localized string AcknowledgmentString[48];
var() localized string AcknowledgmentAbbrev[48];
var() name AcknowledgmentAnim[48];
var() int NumAcknowledgments;

var() SoundGroup AlertSound[20];
var() localized string AlertString[48];
var() localized string AlertAbbrev[48];
var() name AlertAnim[48];
var() int NumAlerts;

var() SoundGroup DirectionSound[20];
var() localized string DirectionString[48];
var() localized string DirectionAbbrev[48];
var() name DirectionAnim[48];
var() int NumDirections;

var() SoundGroup InsultSound[20];
var() localized string InsultString[48];
var() localized string InsultAbbrev[48];
var() name InsultAnim[48];
var() int NumInsults;

/*enum EKFAutoVoice
{
	KFAV_Welding,				// 0
	KFAV_Unwelding,
	KFAV_Reloading,
	KFAV_OutOfAmmo,
	KFAV_DropCash,
	KFAV_Healing,				// 5
	KFAV_Dying,
	KFAV_BloatPuking,
	KFAV_PatriarchInvisible,
	KFAV_PatriarchChainGun,
	KFAV_PatriarchRockets,		// 10
	KFAV_GrabbedByClot,
	KFAV_SpottedFleshpound,
	KFAV_SpottedGorefast,
	KFAV_SpottedScrake,
	KFAV_SpottedSiren,			// 15
	KFAV_SirenAfterScream,
	KFAV_StalkerUncloaks,
	KFAV_SpottedCrawler,
	KFAV_KilledStalkerMelee,
	KFAV_EnemyBurnedToDeath,	// 20
	KFAV_SwitchToDBShotgun,
	KFAV_SwitchToDualHandcannon,
	KFAV_SwitchToLAW,
	KFAV_SwitchToFireAxe
};*/

var() SoundGroup AutomaticSound[25];

/*enum EKFTraderVoice
{
	KFTV_RadioMoving,		// 0
	KFTV_RadioAlmostOpen,
	KFTV_RadioOpen,
	KFTV_RadioLastWave,
	KFTV_Radio30Seconds,
	KFTV_Radio10Seconds,	// 5
	KFTV_RadioClosed,
	KFTV_Welcome,
	KFTV_NotEnoughMoney,
	KFTV_TooHeavy,
	KFTV_30Seconds,			// 10
	KFTV_10Seconds
};*/

var() SoundGroup TraderSound[12];
var() localized string TraderString[12];
var bool bTraderMessage;
var	sound TraderRadioBeep;

var() byte ShoutVolume;
var() byte WhisperVolume;
var() float ShoutRadius;
var() float WhisperRadius;
var float unitWhisperDistance;
var float unitShoutDistance;

var name CurrentMessageType;

var bool bUseLocationalVoice;
var bool bIsFromDifferentTeam;
var Pawn PawnSender;
var vector SenderLoc;

static function PlayerSpeech(name Type, int Index, string Callsign, Actor PackOwner)
{
	local vector myLoc;

	if ( Controller(PackOwner).Pawn == none )
	{
		myLoc = PackOwner.Location;
	}
	else
	{
		myLoc = Controller(PackOwner).Pawn.Location;
	}

	Controller(PackOwner).SendVoiceMessage(Controller(PackOwner).PlayerReplicationInfo, none, Type, Index, 'GLOBAL', Controller(PackOwner).Pawn, myLoc);
}

function ClientInitializeLocational(PlayerReplicationInfo Sender,
						  PlayerReplicationInfo Recipient,
						  name MessageType, byte MessageIndex,
						  optional Pawn SoundSender, optional vector SenderLocation)
{
	PawnSender = SoundSender;
	SenderLoc = SenderLocation;
	ClientInitialize(Sender, Recipient, MessageType, MessageIndex);
}

function ClientInitialize(PlayerReplicationInfo Sender,
						  PlayerReplicationInfo Recipient,
						  name MessageType, byte MessageIndex)
{
	DelayedSender = Sender;
	DisplayString = 0;
	bDisplayPortrait = true;
	PortraitPRI = Sender;
	bDisplayNextMessage = bShowMessageText;
	CurrentMessageType = MessageType;

	if ( PlayerController(Owner).bNoVoiceMessages )
	{
		Destroy();
		return;
	}
	else if ( KFPlayerController(Owner).AudioMessageLevel > 0 )
	{
		if ( MessageType == 'AUTO' )
		{
			if ( MessageIndex >= 7 || KFPlayerController(Owner).AudioMessageLevel > 1 )
			{
				return;
			}
		}
		else if ( MessageType == 'TRADER' && KFPlayerController(Owner).AudioMessageLevel > 1 )
		{
			return;
		}
	}	

	SetTimer(0.6, false);

	SetMessageByType(MessageType, MessageIndex, Recipient);
}

function SetMessageByType( name MessageType,
						   int MessageIndex,
						   PlayerReplicationInfo Recipient)
{
	local Sound MessageSound;

	if ( MessageType == 'TRADER' )
	{
		bTraderMessage = true;
		SetClientTraderMessage(MessageIndex, Recipient, MessageSound);
	}
	else
	{
		bTraderMessage = false;
		bUseLocationalVoice = false;

		if ( MessageType == 'SUPPORT' )
		{
			SetClientSupportMessage(MessageIndex, Recipient, MessageSound);
		}
		else if ( MessageType == 'ACK' )
		{
			SetClientAcknowledgmentMessage(MessageIndex, Recipient, MessageSound);
		}
		else if ( MessageType == 'ALERT' )
		{
			SetClientAlertMessage(MessageIndex, Recipient, MessageSound);
		}
		else if ( MessageType == 'DIRECTION' )
		{
			SetClientDirectionMessage(MessageIndex, Recipient, MessageSound);
		}
		else if ( MessageType == 'INSULT' )
		{
			SetClientInsultMessage(MessageIndex, Recipient, MessageSound);
		}
		else if ( MessageType == 'AUTO' )
		{
			SetClientAutomaticMessage(MessageIndex, Recipient, MessageSound);
		}
	}

	Phrase[0] = MessageSound;
	PhraseString[0] = MessageString;
	DisplayMessage[0] = DisplayString;
}

static function byte GetMessageIndex(name PhraseName)
{
	log("Unknown message type used in GetMessageIndex call: " $ PhraseName);
	return 255;
}

function SetClientSupportMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = SupportSound[MessageIndex];
	MessageAnim = SupportAnim[MessageIndex];
	MessageString = SupportString[MessageIndex];
}

function SetClientAcknowledgmentMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AcknowledgmentSound[MessageIndex];
	MessageAnim = AcknowledgmentAnim[MessageIndex];
	MessageString = AcknowledgmentString[MessageIndex];
}

function SetClientAlertMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AlertSound[MessageIndex];
	MessageAnim = AlertAnim[MessageIndex];
	MessageString = AlertString[MessageIndex];
}

function SetClientDirectionMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = DirectionSound[MessageIndex];
	MessageAnim = DirectionAnim[MessageIndex];
	MessageString = DirectionString[MessageIndex];
}

function SetClientInsultMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = InsultSound[MessageIndex];
	MessageAnim = InsultAnim[MessageIndex];
	MessageString = InsultString[MessageIndex];
}

function SetClientAutomaticMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AutomaticSound[MessageIndex];
	MessageAnim = '';
	MessageString = "";

	bUseLocationalVoice = true;
	bDisplayPortrait = false;
}

function SetClientTraderMessage(int MessageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = TraderSound[MessageIndex];
	MessageAnim = '';
	MessageString = TraderString[MessageIndex];

	if ( MessageIndex > 6 )
	{
		bDisplayPortrait = false;
		bUseLocationalVoice = true;
	}
	else
	{
		bUseLocationalVoice = false;
		PlayerController(Owner).ViewTarget.DemoPlaySound(TraderRadioBeep, SLOT_Talk, 10.0, , , 1.1 / Level.TimeDilation);
	}
}

//-----------------------------------------------------------------------------
// overrider timer to play time from the voicepack to give it locational
// sound
//-----------------------------------------------------------------------------
function string getClientParsedMessage()
{
   return ClientParseMessageString(DelayedSender, PhraseString[PhraseNum]);
}

function Timer()
{
	local PlayerController PlayerOwner;
	local Actor soundPlayer;

	PlayerOwner = PlayerController(Owner);
	if ( bDisplayPortrait && PhraseNum == 0 )
	{
		if ( bTraderMessage )
		{
			HUDKillingFloor(PlayerController(Owner).myHUD).DisplayTraderPortrait();
		}
		else
		{
			PlayerController(Owner).myHUD.DisplayPortrait(PortraitPRI);
		}
	}

	if ( bTraderMessage )
	{
		if ( bUseLocationalVoice )
		{
			if ( PawnSender != none )
			{
				PawnSender.DemoPlaySound(Phrase[PhraseNum], SLOT_None, ShoutVolume, true, , 1.1 / Level.TimeDilation, false);
			}
		}
		else
		{
			if ( (PlayerOwner.ViewTarget != None) )
			{
				PlayerOwner.ViewTarget.DemoPlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume, true, , 1.1 / Level.TimeDilation, false);
			}
			else
			{
				PlayerOwner.DemoPlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume, true, , 1.1 / Level.TimeDilation, false);
			}
		}
	}
	else if ( Phrase[PhraseNum] != None &&
		 (Level.TimeSeconds - PlayerOwner.LastPlaySpeech > 2 || PhraseNum > 0) )
	{
		PlayerOwner.LastPlaySpeech = Level.TimeSeconds;

		if ( bUseLocationalVoice )
		{
			if ( PawnSender != none )
			{
				PawnSender.DemoPlaySound(Phrase[PhraseNum], SLOT_None,ShoutVolume,,,1.0,false);
			}
			else
			{
				soundPlayer = Spawn(Class'ROVoiceMessageEffect',,, SenderLoc);
				if (soundPlayer != none)
					soundPlayer.DemoPlaySound(Phrase[PhraseNum], SLOT_None,ShoutVolume,,,1.0,false);
				else
					warn("Unable to spawn ROVoiceMessageEffect at " $ SenderLoc $ "!");
			}
		}
		else
		{
			if ( (PlayerOwner.ViewTarget != None) )
			{
				PlayerOwner.ViewTarget.DemoPlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume,,,1.0,false);
			}
			else
			{
				PlayerOwner.DemoPlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume,,,1.0,false);
			}
		}

		if (MessageAnim != '')
		{
			UnrealPlayer(PlayerOwner).Taunt(MessageAnim);
		}

		if ( Phrase[PhraseNum+1] == None )
			Destroy();
		else
		{
			// I don't think we ever get here in RO, but log it just in case. We're
			// trying to cut down on sound packs that need to be loaded on the server
			if( GetSoundDuration(Phrase[PhraseNum]) == 0 )
			{
				log("ROVoicePack Setting the timer for a sound to zero");
			}
			SetTimer(FMax(0.1,GetSoundDuration(Phrase[PhraseNum])), false);
			PhraseNum++;
		}
	}
	else
		Destroy();

}

static function GetAllSupports(out array<string> CmdArray)
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.NumSupports; i++ )
	{
		if ( default.SupportAbbrev[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.SupportAbbrev[i];
		}
		else if ( default.SupportString[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.SupportString[i];
		}
		else
		{
			break;
		}
	}
}

static function GetAllAcknowledgments(out array<string> CmdArray)
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.NumAcknowledgments; i++ )
	{
		if ( default.AcknowledgmentAbbrev[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.AcknowledgmentAbbrev[i];
		}
		else if ( default.AcknowledgmentString[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.AcknowledgmentString[i];
		}
		else
		{
			break;
		}
	}
}

static function GetAllAlerts(out array<string> CmdArray)
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.NumAlerts; i++ )
	{
		if ( default.AlertAbbrev[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.AlertAbbrev[i];
		}
		else if ( default.AlertString[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.AlertString[i];
		}
		else
		{
			break;
		}
	}
}

static function GetAllDirections(out array<string> CmdArray)
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.NumDirections; i++ )
	{
		if ( default.DirectionAbbrev[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.DirectionAbbrev[i];
		}
		else if ( default.DirectionString[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.DirectionString[i];
		}
		else
		{
			break;
		}
	}
}

static function GetAllInsults(out array<string> CmdArray)
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.NumInsults; i++ )
	{
		if ( default.InsultAbbrev[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.InsultAbbrev[i];
		}
		else if ( default.InsultString[i] != "" )
		{
			CmdArray[CmdArray.Length] = default.InsultString[i];
		}
		else
		{
			break;
		}
	}
}

defaultproperties
{
     SupportSound(0)=SoundGroup'KF_MaleVoiceOne.SUPPORT.MEDIC'
     SupportSound(1)=SoundGroup'KF_MaleVoiceOne.SUPPORT.Help'
     SupportSound(2)=SoundGroup'KF_MaleVoiceOne.SUPPORT.Need_money'
     SupportSound(3)=SoundGroup'KF_MaleVoiceOne.SUPPORT.Drop_Weapon'
     SupportString(0)="Medic!"
     SupportString(1)="Help!"
     SupportString(2)="I need some money"
     SupportString(3)="Drop a weapon for me"
     SupportAbbrev(0)="Medic"
     SupportAbbrev(1)="Help"
     SupportAbbrev(2)="I need some money"
     SupportAbbrev(3)="Drop a weapon for me"
     numSupports=4
     AcknowledgmentSound(0)=SoundGroup'KF_MaleVoiceOne.Acknowledgements.Yes'
     AcknowledgmentSound(1)=SoundGroup'KF_MaleVoiceOne.Acknowledgements.No'
     AcknowledgmentSound(2)=SoundGroup'KF_MaleVoiceOne.Acknowledgements.Thanks'
     AcknowledgmentSound(3)=SoundGroup'KF_MaleVoiceOne.Acknowledgements.sorry'
     AcknowledgmentString(0)="Yes"
     AcknowledgmentString(1)="No"
     AcknowledgmentString(2)="Thanks!"
     AcknowledgmentString(3)="Sorry!"
     AcknowledgmentAbbrev(0)="Yes"
     AcknowledgmentAbbrev(1)="No"
     AcknowledgmentAbbrev(2)="Thanks"
     AcknowledgmentAbbrev(3)="Sorry"
     NumAcknowledgments=4
     AlertSound(0)=SoundGroup'KF_MaleVoiceOne.Alerts.Look_Out'
     AlertSound(1)=SoundGroup'KF_MaleVoiceOne.Alerts.Run'
     AlertSound(2)=SoundGroup'KF_MaleVoiceOne.Alerts.Wait_for_me'
     AlertSound(3)=SoundGroup'KF_MaleVoiceOne.Alerts.Weld_the_doors'
     AlertSound(4)=SoundGroup'KF_MaleVoiceOne.Alerts.Hole_up'
     AlertSound(5)=SoundGroup'KF_MaleVoiceOne.Alerts.Follow_me'
     AlertString(0)="Look out!"
     AlertString(1)="RUN!"
     AlertString(2)="Wait for me!"
     AlertString(3)="Weld the doors"
     AlertString(4)="Lets hole up here!"
     AlertString(5)="Follow me"
     AlertAbbrev(0)="Look out"
     AlertAbbrev(1)="Run"
     AlertAbbrev(2)="Wait for me"
     AlertAbbrev(3)="Weld the doors"
     AlertAbbrev(4)="Lets hole up here"
     AlertAbbrev(5)="Follow me"
     numAlerts=6
     DirectionSound(0)=SoundGroup'KF_MaleVoiceOne.Directions.Get_to_the_trader'
     DirectionSound(1)=SoundGroup'KF_MaleVoiceOne.Directions.Go_upstairs'
     DirectionSound(2)=SoundGroup'KF_MaleVoiceOne.Directions.Head_downstairs'
     DirectionSound(3)=SoundGroup'KF_MaleVoiceOne.Directions.Get_inside'
     DirectionSound(4)=SoundGroup'KF_MaleVoiceOne.Directions.Go_outside'
     DirectionString(0)="Get to the Trader"
     DirectionString(1)="Go Upstairs"
     DirectionString(2)="Head Downstairs"
     DirectionString(3)="Get Inside"
     DirectionString(4)="Go Outside"
     DirectionAbbrev(0)="Get to the Trader"
     DirectionAbbrev(1)="Go Upstairs"
     DirectionAbbrev(2)="Head Downstairs"
     DirectionAbbrev(3)="Get Inside"
     DirectionAbbrev(4)="Go Outside"
     NumDirections=5
     InsultSound(0)=SoundGroup'KF_MaleVoiceOne.INSULT.Insult_Specimens'
     InsultSound(1)=SoundGroup'KF_MaleVoiceOne.INSULT.Insult_players'
     InsultString(0)="Insult Specimens"
     InsultString(1)="Insult Players"
     InsultAbbrev(0)="Insult Specimens"
     InsultAbbrev(1)="Insult Players"
     NumInsults=2
     AutomaticSound(0)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Welding'
     AutomaticSound(1)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Unwelding'
     AutomaticSound(2)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Reloading'
     AutomaticSound(3)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Out_of_Ammo'
     AutomaticSound(4)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Drop_Cash'
     AutomaticSound(5)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Healing'
     AutomaticSound(6)=SoundGroup'KF_MaleVoiceOne.Automatic_Commands.Auto_Dying'
     AutomaticSound(7)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.BloatPuking'
     AutomaticSound(8)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.PatriarchInvisible'
     AutomaticSound(9)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.PatriarchChainGun'
     AutomaticSound(10)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.PatriarchRockets'
     AutomaticSound(11)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.GrabbedByClot'
     AutomaticSound(12)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SpottedFleshpound'
     AutomaticSound(13)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SpottedGorefast'
     AutomaticSound(14)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SpottedScrake'
     AutomaticSound(15)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SpottedSiren'
     AutomaticSound(16)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SirenAfterScream'
     AutomaticSound(17)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.StalkerUncloaks'
     AutomaticSound(18)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SpottedCrawler'
     AutomaticSound(19)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.KilledStalkerMelee'
     AutomaticSound(20)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.EnemyBurnedToDeath'
     AutomaticSound(21)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SwitchToDBShotgun'
     AutomaticSound(22)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SwitchToDualHandcannon'
     AutomaticSound(23)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SwitchToLAW'
     AutomaticSound(24)=SoundGroup'KF_MaleVoiceOne.Fun_Auto_Commands.SwitchToAxe'
     TraderSound(0)=SoundGroup'KF_Trader.Radio_Moving'
     TraderSound(1)=SoundGroup'KF_Trader.Radio_AlmostOpen'
     TraderSound(2)=SoundGroup'KF_Trader.Radio_ShopsOpen'
     TraderSound(3)=SoundGroup'KF_Trader.Radio_LastWave'
     TraderSound(4)=SoundGroup'KF_Trader.Radio_ThirtySeconds'
     TraderSound(5)=SoundGroup'KF_Trader.Radio_TenSeconds'
     TraderSound(6)=SoundGroup'KF_Trader.Radio_Closed'
     TraderSound(7)=SoundGroup'KF_Trader.Welcome'
     TraderSound(8)=SoundGroup'KF_Trader.TooExpensive'
     TraderSound(9)=SoundGroup'KF_Trader.TooHeavy'
     TraderSound(10)=SoundGroup'KF_Trader.ThirtySeconds'
     TraderSound(11)=SoundGroup'KF_Trader.TenSeconds'
     TraderString(0)="Watch the arrow - check where the shop is!"
     TraderString(1)="Make sure you are close to the shop when you finish them off"
     TraderString(2)="The shop is now open for business!"
     TraderString(3)="Shop's open, last chance to stock up before the Patriarch!"
     TraderString(4)="30 seconds before the shop shuts!"
     TraderString(5)="10 seconds left!"
     TraderString(6)="The shop is now CLOSED until you've cleared the next wave!"
     TraderString(7)="Welcome to the shop – sell what you've got, Buy Bigger Guns!"
     TraderString(8)="You can't afford that – pick something cheaper, or sell something first!"
     TraderString(9)="That is too heavy for you – pick something smaller, or sell something!"
     TraderString(10)="30 seconds before the shop shuts!"
     TraderString(11)="10 seconds left!"
     TraderRadioBeep=Sound'KF_Trader.Walkie_Beep'
     ShoutVolume=2
     WhisperVolume=1
     ShoutRadius=409.600006
     WhisperRadius=25.600000
     unitWhisperDistance=512.000000
     unitShoutDistance=4096.000000
}
