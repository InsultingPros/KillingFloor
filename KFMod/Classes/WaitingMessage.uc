class WaitingMessage extends TimerMessage;

var localized name WarningMessage[2];
var localized string WaveInboundMessage;
var localized string SurvivedMessage;
var localized string FinalWaveInboundMessage;
var localized string WeldedShutMessage;
var localized string ZEDTimeActiveMessage;
var localized string DoorMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
	{
		return default.WaveInboundMessage;
	}
	else if( Switch == 2 )
	{
		return default.SurvivedMessage;
	}
	else if ( Switch == 3 )
	{
		return default.FinalWaveInboundMessage;
	}
	else if ( Switch == 4 )
	{
		return default.WeldedShutMessage;
	}
	else if ( Switch == 5 )
	{
		return default.ZEDTimeActiveMessage;
	}
	else if ( Switch == 6 )
	{
		return default.DoorMessage;
	}
}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
	if ( switch == 1 ||  switch == 2 || switch == 3  )
	{
		return 4;
	}

	if ( Switch == 4 || switch == 5 )
	{
		return 2;
	}

	if ( switch == 6 )
	{
		return 0;
	}

	return default.FontSize;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;

	switch( Switch )
	{
		case 1:
		case 3:
			OutPosY = 0.45;
			break;
		case 2:
		    OutPosY = 0.4;
		    break;
		case 4:
			OutPosY = 0.7;
		case 5:
			OutPosY = 0.7;
		case 6:
			OutPosY = 0.8;
			break;
	}
}

static function float GetLifeTime(int Switch)
{
	switch( switch )
	{
		case 1:
		case 3:
			return 1;
		case 2:
		    return 3;
		case 4:
			return 4;
		case 5:
			return 1.5;
		case 6:
			return 5;
	}
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	super(CriticalEventPlus).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( Switch == 1 )
	   	P.QueueAnnouncement(default.WarningMessage[Rand(2)], 1, AP_InstantOrQueueSwitch, 1);
}

static function RenderComplexMessage(
	Canvas Canvas,
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int i;
	local float TempY;

	i = InStr(MessageString, "|");

	TempY = Canvas.CurY;

	Canvas.FontScaleX = Canvas.ClipX / 1024.0;
	Canvas.FontScaleY = Canvas.FontScaleX;

	if ( i < 0 )
	{
		Canvas.TextSize(MessageString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(MessageString, false);
	}
	else
	{
		Canvas.TextSize(Left(MessageString, i), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(Left(MessageString, i), false);

		Canvas.TextSize(Mid(MessageString, i + 1), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY + YL);
		Canvas.DrawTextClipped(Mid(MessageString, i + 1), false);
	}

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

defaultproperties
{
     WarningMessage(0)="HereTheyCome5"
     WarningMessage(1)="HereTheyCome2"
     WaveInboundMessage="NEXT WAVE INBOUND!"
     SurvivedMessage="WAVE COMPLETED!|GET TO THE TRADER!"
     FinalWaveInboundMessage="FINAL WAVE INBOUND"
     WeldedShutMessage="This door is welded shut.|Use the Welder's alt-fire to unweld."
     ZEDTimeActiveMessage="ZED TIME ACTIVATED!"
     DoorMessage="Press '%Use%' to open/close the door.|Use the Welder to seal closed doors."
     bComplexString=True
     DrawColor=(G=0)
     FontSize=5
}
