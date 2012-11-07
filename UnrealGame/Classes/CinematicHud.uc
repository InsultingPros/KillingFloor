// ====================================================================
//  Class:  UnrealGame.CinematicHud
//  Parent: Engine.HUD
//
//  This is the hud used for Cinematic sequences
// ====================================================================

class CinematicHud extends HUD;

// #exec OBJ LOAD FILE=..\textures\Old2k4\ScopeOverlay.utx PACKAGE=ScopeOverlay

var float Delta;
var bool  bHideScope;
var float xOffsets[2];
var float xRates[2];
var float yOffsets[2];
var float yRates[2];
var bool  bInitialized;
var float Scale;

var string SubTitle;
var float SubTitleKillTime;



simulated event PostRender( canvas Canvas )
{
	local float xl,yl;
	Super.PostRender(Canvas);

    if ( Level.TimeSeconds > SubTitleKillTime )
    	SubTitle = "";

    if (SubTitle != "")
    {
    	Canvas.SetDrawColor(255,255,0,255);
		Canvas.Font = LoadFontStatic(6);

  		Canvas.StrLen(SubTitle,xl,yl);
        if (xl>=Canvas.ClipX)
        	xl = 0;
        else
        	xl = (Canvas.ClipX / 2) - (xl / 2);

//        Canvas.SetPos(XL,Canvas.ClipY*0.85);
        Canvas.SetPos(0, Canvas.ClipY*0.85);
        Canvas.bCenter = true;
        Canvas.DrawText(SubTitle,false);
    }

}

simulated function DrawHUD(canvas Canvas)
{
	// Setup Timing


	if (!bInitialized)
	{
		Initialize(Canvas);
	}


	Scale = Canvas.ClipX / 1024;

	Super.DrawHud(Canvas);

	// Draw any specific sequences here
}

simulated function Initialize(canvas Canvas)
{

	if (Scale == 0)
		return;

	xOffsets[0] = -123.0*Scale;
	xRates[0]   = 512.0*Scale;
	xOffsets[1] = Canvas.ClipY+1;
	xRates[1]   = 512.0*Scale;


	yOffsets[0] = (Canvas.ClipY / 2) - (64.0*Scale);
	yOffsets[1] = yOffsets[0];
	yRates[0]   = -200.0*Scale;
	yRates[1]   = +256.0*Scale;

	bInitialized = true;

}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional string CriticalString )
{
    SubTitle = Message.static.GetString(switch);
    SubTitleKillTime = Level.TimeSeconds + Message.static.GetLifeTime(switch);
}

defaultproperties
{
     bHideScope=True
     FontArrayNames(0)="ROFonts.ROBtsrmVr38"
     FontArrayNames(1)="ROFonts.ROBtsrmVr28"
     FontArrayNames(2)="ROFonts.ROBtsrmVr24"
     FontArrayNames(3)="ROFonts.ROBtsrmVr20"
     FontArrayNames(4)="ROFonts.ROBtsrmVr18"
     FontArrayNames(5)="ROFonts.ROBtsrmVr14"
     FontArrayNames(6)="ROFonts.ROBtsrmVr12"
     FontArrayNames(7)="ROFonts.ROBtsrmVr9"
     FontArrayNames(8)="ROFonts.ROBtsrmVr7"
}
