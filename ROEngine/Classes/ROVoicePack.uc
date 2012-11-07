//------------------------------------------------------------------------------
// $Id: ROVoicePack.uc,v 1.12 2004/05/17 06:03:02 antarian Exp $
//------------------------------------------------------------------------------
class ROVoicePack extends xVoicePack;

var() SoundGroup SupportSound[20];
var() localized string SupportString[48];
var() localized string SupportAbbrev[48];
var() localized string SupportStringAxis[48];
var() localized string SupportAbbrevAxis[48];
var() name SupportAnim[48];
var() int numSupports;

var() SoundGroup EnemySound[20];
var() localized string EnemyString[48];
var() localized string EnemyAbbrev[48];
var() localized string EnemyStringAxis[48];
var() localized string EnemyAbbrevAxis[48];
var() name EnemyAnim[48];
var() int numEnemies;

var() SoundGroup AlertSound[20];
var() localized string AlertString[48];
var() localized string AlertAbbrev[48];
var() name AlertAnim[48];
var() int numAlerts;

var() name AttackAnim;
var() name DefendAnim;
var() int numAttacks;

var() SoundGroup VehicleDirectionSound[20];
var() localized string VehicleDirectionString[48];
var() localized string VehicleDirectionAbbrev[48];
var() name VehicleDirectionAnim[48];
var() int numVehicleDirections;

var() SoundGroup VehicleAlertSound[20];
var() localized string VehicleAlertString[48];
var() localized string VehicleAlertAbbrev[48];
var() name VehicleAlertAnim[48];
var() int numVehicleAlerts;

var() SoundGroup ExtraSound[20];
var() localized string ExtraString[48];
var() localized string ExtraAbbrev[48];
var() name ExtraAnim[48];
var() int numExtras;

var() byte ShoutVolume;
var() byte WhisperVolume;
var() float ShoutRadius;
var() float WhisperRadius;
var float unitWhisperDistance;
var float unitShoutDistance;

var name CurrentMessageType;

//var ROSoundGroup CommandSound[20];
var() int numCommands;

//#exec OBJ LOAD FILE=ROVoiceSounds.uax

//var() Sound AckSound[32]; // acknowledgement sounds
//var() localized string AckString[32];

var bool bUseAxisStrings;

var bool bUseLocationalVoice;
var bool bIsFromDifferentTeam;
var Pawn pawnSender;
var vector senderLoc;

static function PlayerSpeech( name Type, int Index, string Callsign, Actor PackOwner )
{
    xPlayerSpeech(Type, Index, none, PackOwner);
}

static function xPlayerSpeech(name Type, int Index, PlayerReplicationInfo SquadLeader, Actor PackOwner)
{
    local name broadcasttype;
    local vector myLoc;
	//Log("ROVoicePack::PlayerSpeech() Type = "$Type$" Index = "$Index);
	if (Type == 'TAUNT')
	    broadcasttype = 'GLOBAL';
	else
	    broadcasttype = 'TEAM';
    if (Controller(PackOwner).Pawn == none)
        myLoc = PackOwner.Location;
    else
        myLoc = Controller(PackOwner).Pawn.Location;

    Controller(PackOwner).SendVoiceMessage( Controller(PackOwner).PlayerReplicationInfo, SquadLeader, Type, Index, broadcasttype, Controller(PackOwner).Pawn, myLoc);
}

function BotInitialize(PlayerReplicationInfo Sender,
                       PlayerReplicationInfo Recipient,
                       name messagetype,
                       byte messageIndex)
{
	DelayedSender = Sender;
	DisplayString = 0;
	bDisplayNextMessage = bShowMessageText;
	if ( messagetype == 'ACK' )
		SetTimer(2.65, false);
	else
		SetTimer(0.65, false);
	CurrentMessageType=messagetype;
    SetMessageByType(messagetype,messageIndex ,Recipient);
}

function ClientInitializeLocational(PlayerReplicationInfo Sender,
                          PlayerReplicationInfo Recipient,
                          name messagetype, byte messageIndex,
                          optional Pawn soundSender, optional vector senderLocation)
{
    pawnSender = soundSender;
    senderLoc = senderLocation;
    ClientInitialize(Sender, Recipient, messagetype, messageIndex);
}

function ClientInitialize(PlayerReplicationInfo Sender,
                          PlayerReplicationInfo Recipient,
                          name messagetype, byte messageIndex)
{
    //log("ClientInitialize called: messagetype = " $ messagetype $ ", messageIndex = " $ messageIndex);

    DelayedSender = Sender;
	DisplayString = 0;
	bDisplayPortrait = false;
	bDisplayNextMessage = bShowMessageText;
    CurrentMessageType = messagetype;

	if(PlayerController(Owner).bNoVoiceMessages	)
	{
		Destroy();
		return;
	}

    if ( Sender.bBot )
	{
		BotInitialize(Sender, Recipient, messagetype, messageIndex);
		return;
	}

	SetTimer(0.6, false);

	SetMessageByType(messagetype,messageIndex ,Recipient);

}

/*static function string getMessagePhraseFor(name messagetype, int messageID)
{
   if ( messagetype == 'SHOUT' )
      return default.ShoutString[messageID];
   else if( messagetype == 'ACK' )
      return default.AckString[messageID];
   else if(  messagetype == 'ORDER' )
      return default.OrderString[messageID];
} */


function SetMessageByType( name messagetype,
                           int messageIndex,
                           PlayerReplicationInfo Recipient)
{
    local Sound MessageSound;

    if ( messagetype == 'SUPPORT' )
		SetClientSupportMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'ACK' )
		SetClientAckMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'ENEMY' )
		SetClientEnemyMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'ALERT' )
		SetClientAlertMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'VEH_ORDERS' )
		SetClientVehicleDirectionMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'VEH_ALERTS' )
		SetClientVehicleAlertMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'ORDER' )
		SetClientOrderMessage(messageIndex, Recipient, MessageSound);

	else if ( messagetype == 'TAUNT' )
		SetClientExtraMessage(messageIndex, Recipient, MessageSound);

	else if( messagetype == 'ATTACK')
		SetClientAttackMessage(messageIndex, Recipient, MessageSound);

	else if( messagetype == 'DEFEND')
		SetClientDefendMessage(messageIndex, Recipient, MessageSound);

	else if( messagetype == 'VEH_GOTO')
		SetClientGotoMessage(messageIndex, Recipient, MessageSound);

	else if( messagetype == 'HELPAT')
		SetClientHelpAtMessage(messageIndex, Recipient, MessageSound);

	else if( messagetype == 'UNDERATTACK')
		SetClientUnderAttackAtMessage(messageIndex, Recipient, MessageSound);

	// Friendly fire message
	else if ( messagetype == 'FRIENDLYFIRE' )
		SetClientFFireMessage(Rand(NumFFires), Recipient, MessageSound);

	// Bot messages
	else if ( messagetype == 'Other' && messageIndex < 10)
	    SetClientSupportMessage(messageIndex, Recipient, MessageSound);
	else if ( messagetype == 'Other' && messageIndex < 20)
	    SetClientAckMessage(messageIndex - 10, Recipient, MessageSound);
	else if ( messagetype == 'Other' && messageIndex < 30)
	    SetClientEnemyMessage(messageIndex - 20, Recipient, MessageSound);
    else if ( messagetype == 'Other' && messageIndex < 40)
	    SetClientAlertMessage(messageIndex - 30, Recipient, MessageSound);


	Phrase[0] = MessageSound;
	PhraseString[0] = MessageString;
	DisplayMessage[0] = DisplayString;


}

static function byte GetMessageIndex(name PhraseName)
{
	local float r;
	r = FRand();

	if ( PhraseName == 'INJURED' )
    	return 0;
	else if ( PhraseName == 'NEEDBACKUP' )
	    return 0;
	else if ( PhraseName == 'GOTYOURBACK' )
		return 31;
	else if ( PhraseName == 'MANDOWN' )
		return 0;
	else if ( PhraseName == 'INPOSITION' )
		return 10;
	else if ( PhraseName == 'ONMYWAY' )
		return 10;
	else
        log("Unknown message type used in GetMessageIndex call: " $ PhraseName);
}

function SetClientSupportMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = SupportSound[messageIndex];
	MessageAnim = SupportAnim[messageIndex];

    if (bUseAxisStrings && SupportStringAxis[messageIndex] != "")
        MessageString = SupportStringAxis[messageIndex];
    else
        MessageString = SupportString[messageIndex];
}

function SetClientEnemyMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = EnemySound[messageIndex];
	MessageAnim = EnemyAnim[messageIndex];

    if (bUseAxisStrings && EnemyStringAxis[messageIndex] != "")
        MessageString = EnemyStringAxis[messageIndex];
    else
        MessageString = EnemyString[messageIndex];
}


function SetClientOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = OrderSound[messageIndex];
	MessageString = OrderString[messageIndex];
    MessageAnim = OrderAnim[messageIndex];
}

//=========================================================================================
// SetClientVehicleMessage -
//=========================================================================================
function SetClientVehicleDirectionMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
    MessageSound = VehicleDirectionSound[messageIndex];
	MessageString = VehicleDirectionString[messageIndex];
    MessageAnim = VehicleDirectionAnim[messageIndex];
}

function SetClientVehicleAlertMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = VehicleAlertSound[messageIndex];
	MessageString = VehicleAlertString[messageIndex];
    MessageAnim = VehicleAlertAnim[messageIndex];
}

function SetClientDefendMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
    local ROGameReplicationInfo ROGameRep;
    local ROPlayer rop;
    rop = ROPlayer(Owner);
    if(rop != none)
       ROGameRep = ROGameReplicationInfo(rop.GameReplicationInfo);

    MessageSound = OrderSound[1];
	MessageString = OrderString[1]@ROGameRep.Objectives[messageIndex].ObjName;
    MessageAnim = DefendAnim;
}

function SetClientHelpAtMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
    local ROGameReplicationInfo ROGameRep;
    local ROPlayer rop;
    rop = ROPlayer(Owner);
    if(rop != none)
       ROGameRep = ROGameReplicationInfo(rop.GameReplicationInfo);

    MessageSound = SupportSound[1];
	MessageString = SupportString[1]@ROGameRep.Objectives[messageIndex].ObjName;
    MessageAnim = DefendAnim;
}

function SetClientUnderAttackAtMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
    local ROGameReplicationInfo ROGameRep;
    local ROPlayer rop;
    rop = ROPlayer(Owner);
    if(rop != none)
       ROGameRep = ROGameReplicationInfo(rop.GameReplicationInfo);

    MessageSound = AlertSound[8];
	MessageString = AlertString[8]@ROGameRep.Objectives[messageIndex].ObjName;
    MessageAnim = DefendAnim;
}

function SetClientGotoMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
    local ROGameReplicationInfo ROGameRep;
    local ROPlayer rop;
    rop = ROPlayer(Owner);
    if(rop != none)
       ROGameRep = ROGameReplicationInfo(rop.GameReplicationInfo);

    MessageSound = VehicleDirectionSound[0];
	MessageString = vehicleDirectionString[0]@ROGameRep.Objectives[messageIndex].ObjName;
    MessageAnim = '';
}


function SetClientAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AckSound[messageIndex];
	MessageString = AckString[messageIndex];
    MessageAnim = AckAnim[messageIndex];
}

function SetClientExtraMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = ExtraSound[messageIndex];
	MessageString = ExtraString[messageIndex];
    MessageAnim = ExtraAnim[messageIndex];
}

function SetClientAlertMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AlertSound[messageIndex];
	MessageString = AlertString[messageIndex];
    MessageAnim = AlertAnim[messageIndex];
}

function SetClientAttackMessage(int messageIndex,
                                 PlayerReplicationInfo Recipient,
                                 out Sound MessageSound)
{
    local ROGameReplicationInfo ROGameRep;
    local ROPlayer rop;
    rop = ROPlayer(Owner);
    if(rop != none)
       ROGameRep = ROGameReplicationInfo(rop.GameReplicationInfo);
    //log("ROVoicePack::SetClientAttackMessag(), messageIndex  = "$messageIndex);
    //going to assume that the Objective array never get's altered in game.
    //
    MessageSound = OrderSound[0];
	MessageString = OrderString[0]@ROGameRep.Objectives[messageIndex].ObjName;

    MessageAnim = AttackAnim;

}

/*function SetAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = AckSound[messageIndex];
	MessageString = AckString[messageIndex];
    MessageAnim = AckAnim[messageIndex];
}*/

function SetClientFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	//MessageSound = FFireSound[messageIndex];
	MessageSound = AlertSound[7];
	//MessageString = FFireString[messageIndex];
	MessageString = AlertString[7];
    MessageAnim = FFireAnim[messageIndex];
}

function SetFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	//MessageSound = FFireSound[messageIndex];
	MessageSound = AlertSound[7];
	//MessageString = FFireString[messageIndex];
	MessageString = AlertString[7];
    MessageAnim = FFireAnim[messageIndex];
}

// Taunts from Players
function SetClientTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{

	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
}

// Taunts from Bots
function SetTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
}
//-----------------------------------------------------------------------------
// overrider timer to play time from the voicepack to give it locational
// sound
//-----------------------------------------------------------------------------
function string getClientParsedMessage()
{
   return  ClientParseMessageString(DelayedSender, PhraseString[PhraseNum]);
}

function Timer()
{
	local PlayerController PlayerOwner;
	local Actor soundPlayer;

	PlayerOwner = PlayerController(Owner);
	if ( bDisplayPortrait && (PhraseNum == 0) && !(bIsFromDifferentTeam && bUseAxisStrings) )
		PlayerController(Owner).myHUD.DisplayPortrait(PortraitPRI);

	/*if ( (bDisplayNextMessage || (DisplayMessage[PhraseNum] != 0)) && DelayedSender.bBot)
	{
		   Mesg = ClientParseMessageString(DelayedSender, PhraseString[PhraseNum]);
		   PlayerOwner.TeamMessage(DelayedSender,Mesg,'TEAMSAY');
	}*/

	if ( (Phrase[PhraseNum] != None) &&
         ((Level.TimeSeconds - PlayerOwner.LastPlaySpeech > 2) ||
         (PhraseNum > 0))  )
	{
		PlayerOwner.LastPlaySpeech = Level.TimeSeconds;

        if (bUseLocationalVoice)
        {
            if (pawnSender != none)
                pawnSender.PlaySound(Phrase[PhraseNum], SLOT_None,ShoutVolume,,,1.0,false);
            else
            {
                soundPlayer = Spawn(Class'ROVoiceMessageEffect',,, senderLoc);
                if (soundPlayer != none)
                    soundPlayer.PlaySound(Phrase[PhraseNum], SLOT_None,ShoutVolume,,,1.0,false);
                else
                    warn("Unable to spawn ROVoiceMessageEffect at " $ senderLoc $ "!");
            }
        }
        else
        {
		    if ( (PlayerOwner.ViewTarget != None) )
		    {
			    PlayerOwner.ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume,,,1.0,false);
		    }
		    else
		    {
			    PlayerOwner.PlaySound(Phrase[PhraseNum], SLOT_Interface,ShoutVolume,,,1.0,false);
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

static function bool isValidDistanceForMessageType(name messageType, float distance)
{
    if(messageType == 'WHISPER' && distance > default.unitWhisperDistance )
    {
        return false;
    }
    else if(messageType == 'ORDER' && distance > default.unitShoutDistance)
        return false;

    return true;
}

static function GetAllSupports( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numSupports; i++ )
	{
		if ( default.SupportAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.SupportAbbrev[i];

		else if ( default.SupportString[i] != "" )
			CmdArray[CmdArray.Length] = default.SupportString[i];

		else break;
	}
}

static function GetAllAcknowledges( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numAcks; i++ )
	{
		if ( default.AckAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.AckAbbrev[i];

		else if ( default.AckString[i] != "" )
			CmdArray[CmdArray.Length] = default.AckString[i];

		else break;
	}
}

static function GetAllEnemies( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numEnemies; i++ )
	{
		if ( default.EnemyAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.EnemyAbbrev[i];

		else if ( default.EnemyString[i] != "" )
			CmdArray[CmdArray.Length] = default.EnemyString[i];

		else break;
	}
}

static function GetAllAlerts( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numAlerts; i++ )
	{
		if ( default.AlertAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.AlertAbbrev[i];

		else if ( default.AlertString[i] != "" )
			CmdArray[CmdArray.Length] = default.AlertString[i];

		else break;
	}
}

static function GetAllVehicleDirections( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numVehicleDirections; i++ )
	{
		if ( default.VehicleDirectionAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.VehicleDirectionAbbrev[i];

		else if ( default.VehicleDirectionString[i] != "" )
			CmdArray[CmdArray.Length] = default.VehicleDirectionString[i];

		else break;
	}
}

static function GetAllVehicleAlerts( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numVehicleAlerts; i++ )
	{
		if ( default.VehicleAlertAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.VehicleAlertAbbrev[i];

		else if ( default.VehicleAlertString[i] != "" )
			CmdArray[CmdArray.Length] = default.VehicleAlertString[i];

		else break;
	}
}

static function GetAllOrders( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < MAXORDER; i++ )
	{
		if ( default.OrderAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.OrderAbbrev[i];

		else if ( default.OrderString[i] != "" )
			CmdArray[CmdArray.Length] = default.OrderString[i];

		else break;
	}
}

static function GetAllExtras( out array<string> CmdArray )
{
	local int i;

	CmdArray.Length = 0;
	for ( i = 0; i < default.numExtras; i++ )
	{
		if ( default.ExtraAbbrev[i] != "" )
			CmdArray[CmdArray.Length] = default.ExtraAbbrev[i];

		else if ( default.ExtraString[i] != "" )
			CmdArray[CmdArray.Length] = default.ExtraString[i];

		else break;
	}
}

defaultproperties
{
     SupportString(0)="We need help!"
     SupportString(1)="Need help at"
     SupportString(2)="I need ammo!"
     SupportString(3)="Get a sniper over here!"
     SupportString(4)="We need MG support!"
     SupportString(5)="We need an AT Rifle!"
     SupportString(6)="Someone blow this!"
     SupportString(7)="We need a tank!"
     SupportString(8)="Give us artillery!"
     SupportString(9)="I need transport!"
     SupportAbbrev(0)="Help needed"
     SupportAbbrev(1)="Help needed at..."
     SupportAbbrev(2)="Ammo needed"
     SupportAbbrev(3)="Request sniper"
     SupportAbbrev(4)="MG support needed"
     SupportAbbrev(5)="Need an AT Rifle"
     SupportAbbrev(6)="Request demolition"
     SupportAbbrev(7)="Request tank"
     SupportAbbrev(8)="Request artillery"
     SupportAbbrev(9)="Request transport"
     SupportStringAxis(5)="We need a Panzerfaust!"
     SupportAbbrevAxis(5)="Need a Panzerfaust"
     numSupports=10
     EnemyString(0)="Infantry spotted!"
     EnemyString(1)="MG position!"
     EnemyString(2)="Sniper!"
     EnemyString(3)="Sapper!"
     EnemyString(4)="Anti-tank soldiers!"
     EnemyString(5)="Small vehicle!"
     EnemyString(6)="Tank! Tank!"
     EnemyString(7)="Heavy tank!"
     EnemyString(8)="Artillery!"
     EnemyAbbrev(0)="Infantry spotted"
     EnemyAbbrev(1)="MG position"
     EnemyAbbrev(2)="Sniper"
     EnemyAbbrev(3)="Sapper"
     EnemyAbbrev(4)="Anti-tank soldiers"
     EnemyAbbrev(5)="Small vehicle"
     EnemyAbbrev(6)="Tank"
     EnemyAbbrev(7)="Heavy tank"
     EnemyAbbrev(8)="Artillery"
     EnemyStringAxis(3)="Pionier!"
     EnemyStringAxis(6)="Achtung, panzer!"
     EnemyAbbrevAxis(3)="Pioner"
     EnemyAbbrevAxis(6)="Panzer"
     numEnemies=9
     AlertString(0)="Grenade!"
     AlertString(1)="Go go go!"
     AlertString(2)="Take cover!"
     AlertString(3)="Stop!"
     AlertString(4)="Follow me!"
     AlertString(5)="Satchel planted!"
     AlertString(6)="Covering fire!"
     AlertString(7)="Friendly fire!"
     AlertString(8)="Under attack at"
     AlertString(9)="Retreat!"
     AlertAbbrev(0)="Grenade"
     AlertAbbrev(1)="Go go go"
     AlertAbbrev(2)="Take cover"
     AlertAbbrev(3)="Stop"
     AlertAbbrev(4)="Follow me"
     AlertAbbrev(5)="Satchel planted"
     AlertAbbrev(6)="Covering fire"
     AlertAbbrev(7)="Friendly fire"
     AlertAbbrev(8)="Under attack at objective"
     AlertAbbrev(9)="Retreat"
     numAlerts=10
     VehicleDirectionString(0)="Go to"
     VehicleDirectionString(1)="Move forward"
     VehicleDirectionString(2)="Stop"
     VehicleDirectionString(3)="Move back"
     VehicleDirectionString(4)="Go left"
     VehicleDirectionString(5)="Go right"
     VehicleDirectionString(6)="Forward 5 metres!"
     VehicleDirectionString(7)="Back 5 metres!"
     VehicleDirectionString(8)="Turn left a little!"
     VehicleDirectionString(9)="Turn right a little!"
     VehicleDirectionAbbrev(0)="Go to..."
     VehicleDirectionAbbrev(1)="Move forward"
     VehicleDirectionAbbrev(2)="Stop"
     VehicleDirectionAbbrev(3)="Move back"
     VehicleDirectionAbbrev(4)="Go left"
     VehicleDirectionAbbrev(5)="Go right"
     VehicleDirectionAbbrev(6)="Forward 5 metres"
     VehicleDirectionAbbrev(7)="Back 5 metres"
     VehicleDirectionAbbrev(8)="Turn left a little"
     VehicleDirectionAbbrev(9)="Turn right a little"
     numVehicleDirections=10
     VehicleAlertString(0)="Enemy in front!"
     VehicleAlertString(1)="Enemy left flank!"
     VehicleAlertString(2)="Enemy right flank!"
     VehicleAlertString(3)="Enemy behind us!"
     VehicleAlertString(4)="Enemy infantry close!"
     VehicleAlertString(5)="Yes, sir!"
     VehicleAlertString(6)="No, no!"
     VehicleAlertString(7)="We're burning!"
     VehicleAlertString(8)="Get out!"
     VehicleAlertString(9)="Loaded."
     VehicleAlertAbbrev(0)="Enemy in front"
     VehicleAlertAbbrev(1)="Enemy left flank"
     VehicleAlertAbbrev(2)="Enemy right flank"
     VehicleAlertAbbrev(3)="Enemy behind us"
     VehicleAlertAbbrev(4)="Enemy infantry close"
     VehicleAlertAbbrev(5)="Acknowledged"
     VehicleAlertAbbrev(6)="Negative"
     VehicleAlertAbbrev(7)="We're burning"
     VehicleAlertAbbrev(8)="Get out"
     VehicleAlertAbbrev(9)="Loaded"
     numVehicleAlerts=10
     ExtraString(0)="I will kill you!"
     ExtraString(1)="No retreat!"
     ExtraString(2)="*insult*"
     ExtraAbbrev(0)="I will kill you"
     ExtraAbbrev(1)="No retreat"
     ExtraAbbrev(2)="Insult"
     numExtras=3
     ShoutVolume=2
     WhisperVolume=1
     ShoutRadius=409.600006
     WhisperRadius=25.600000
     unitWhisperDistance=512.000000
     unitShoutDistance=4096.000000
     numCommands=8
     AckString(0)="Yes sir!"
     AckString(1)="No, no!"
     AckString(2)="Thanks"
     AckString(3)="Sorry"
     AckAbbrev(0)="Yes Sir"
     AckAbbrev(1)="Negative"
     AckAbbrev(2)="Thanks"
     AckAbbrev(3)="Apologize"
     numTaunts=0
     OrderString(0)="Attack"
     OrderString(1)="Defend"
     OrderString(2)="Hold this position!"
     OrderString(3)="Follow me!"
     OrderString(4)="Attack at will!"
     OrderString(5)="Retreat!"
     OrderString(6)="Fire at will!"
     OrderString(7)="Cease fire!"
     OrderAbbrev(0)="Attack..."
     OrderAbbrev(1)="Defend..."
     OrderAbbrev(2)="Hold Position"
     OrderAbbrev(3)="Follow Me"
     OrderAbbrev(4)="Move out"
     OrderAbbrev(5)="Retreat"
     OrderAbbrev(6)="Engage"
     OrderAbbrev(7)="Cease Fire"
}
