//=============================================================================
// Display a note on screen.
//=============================================================================
class KFSPNoteMessage extends UseTrigger;

var() localized string NoteText;
var() material NoteTexture;
var() Font NoteTextFont;
var() color NoteTextColor;
var() bool bEnabled,bTextCentered;
var() float NoteTexSize;
var() FloatBox TextCoords;
var bool bHasTriggered;

function UsedBy( Pawn user )
{
	if( bEnabled && PlayerController(user.Controller)!=None )
	{
		PlayerController(user.Controller).ReceiveLocalizedMessage(Class'KFNoteMsg',,,,Self);
		if( !bHasTriggered )
		{
			bHasTriggered = True;
			TriggerEvent(Event,Self,User);
		}
	}
}

function Touch( Actor Other )
{
	if ( bEnabled && Pawn(Other)!=None )
	{
	    // Send a string message to the toucher.
	    if( Message != "" )
		    Pawn(Other).ClientMessage( Message );
	}
}
function Untouch( Actor Other )
{
	if ( bEnabled && Pawn(Other)!=None && PlayerController(Pawn(Other).Controller)!=None )
		PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(Class'KFNoteMsg',1);
}
function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;

	bEnabled = !bEnabled;
	ForEach TouchingActors(Class'Pawn',P)
	{
		if( bEnabled )
			Touch(P);
		else Untouch(P);
	}
}
simulated function RenderNote( Canvas C )
{
	local float XS,YS,ClX;
	local int i;
	local string S;

	C.Style = ERenderStyle.STY_Alpha;
	if( NoteTexture!=None )
	{
		XS = NoteTexture.MaterialUSize();
		YS = NoteTexture.MaterialVSize();
	}
	else
	{
		XS = 256;
		YS = 512;
	}
	XS*=(NoteTexSize*FClamp(C.ClipX/640.f,0.5,2));
	YS*=(NoteTexSize*FClamp(C.ClipX/640.f,0.5,2));
	C.OrgX = FMax(C.ClipX/20.f,C.ClipX/5*3-XS);
	C.OrgY = FMax(C.ClipY/20.f,C.ClipY/2-YS/2);
	C.CurX = 0;
	C.CurY = 0;
	ClX = C.ClipX;
	C.ClipX = XS;
	if( NoteTexture!=None )
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 255;
		C.DrawTile(NoteTexture,XS,YS,0,0,NoteTexture.MaterialUSize(),NoteTexture.MaterialVSize());
	}
	if( NoteText!="" )
	{
		C.OrgX+=(XS*TextCoords.X1);
		C.ClipX = (XS*(TextCoords.X2-TextCoords.X1));
		C.CurX = 0;
		C.CurY = (YS*TextCoords.Y1);
		C.Font = NoteTextFont;
		C.DrawColor = NoteTextColor;
		S = NoteText;
		i = InStr(S,"/");
		C.bCenter = bTextCentered;
		while( True )
		{
			if( i==-1 )
			{
				C.DrawText(S,False);
				Break;
			}
			C.DrawText(Left(S,i),False);
			C.CurX = 0;
			S = Mid(S,i+1);
			i = InStr(S,"/");
		}
	}
	C.bCenter = False;
	C.OrgX = 0;
	C.OrgY = 0;
	C.ClipX = ClX;
}

defaultproperties
{
     NoteText="This is default note text"
     NoteTextFont=Font'Engine.DefaultFont'
     NoteTextColor=(B=255,G=255,R=255,A=255)
     bEnabled=True
     TextCoords=(X1=0.100000,Y1=0.100000,X2=0.900000,Y2=1.000000)
     bNoDelete=True
}
