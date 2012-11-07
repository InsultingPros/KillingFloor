//=============================================================================
// ROVehicleSayMessage
//=============================================================================
// Message class for Vehicle Say messages
// new class - MrMethane 01/10/2005
//=============================================================================

class ROVehicleSayMessage extends ROStringMessage;

//=============================================================================
// Variables
//=============================================================================

var	Color			VehicleMessageColor;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// RenderComplexMessage
//-----------------------------------------------------------------------------

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
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;


    LocationName = RelatedPRI_1.GetLocationName();

    Canvas.SetDrawColor(default.VehicleMessageColor.R,default.VehicleMessageColor.G,default.VehicleMessageColor.B,default.VehicleMessageColor.A);

	Canvas.DrawText(RelatedPRI_1.PlayerName$" ", false);
	Canvas.SetPos(Canvas.CurX, Canvas.CurY - YL);

	if (LocationName != "")
		Canvas.DrawText("("$LocationName$"):", false);
	else
		Canvas.DrawText(": ", false);

	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.SetDrawColor(255,255,255,255); //DrawColor = default.DrawColor;
	Canvas.DrawText( MessageString, False );
}

//-----------------------------------------------------------------------------
// AssembleString
//-----------------------------------------------------------------------------

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional String MessageString
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return "";

    LocationName = RelatedPRI_1.GetLocationName();

	if ( LocationName == "" )
		return RelatedPRI_1.PlayerName@":"@MessageString;
	else
		return RelatedPRI_1.PlayerName$" ("$LocationName$"): "$MessageString;
}

//-----------------------------------------------------------------------------
// GetConsoleColor
//-----------------------------------------------------------------------------

static function Color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
	if ( (RelatedPRI_1 == None) || (RelatedPRI_1.Team == None) )
		return default.DrawColor;

    return default.VehicleMessageColor;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     VehicleMessageColor=(G=110,A=255)
     bComplexString=True
     bBeep=True
}
