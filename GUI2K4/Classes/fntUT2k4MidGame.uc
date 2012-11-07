class fntUT2k4MidGame extends GUIFont;

var int FontScreenWidth[7];

static function Font GetMidGameFont(int xRes)
{
	local int i;
	for(i=0; i<7; i++)
	{
		if ( default.FontScreenWidth[i] <= XRes )
			return LoadFontStatic(i);
	}

	return LoadFontStatic(6);
}

// Same as
event Font GetFont(int XRes)
{
	return GetMidGameFont(xRes);
}

defaultproperties
{
     FontScreenWidth(0)=2048
     FontScreenWidth(1)=1600
     FontScreenWidth(2)=1280
     FontScreenWidth(3)=1024
     FontScreenWidth(4)=800
     FontScreenWidth(5)=640
     FontScreenWidth(6)=600
     KeyName="UT2MidGameFont"
     FontArrayNames(0)="ROFonts.ROBtsrmVr18"
     FontArrayNames(1)="ROFonts.ROBtsrmVr14"
     FontArrayNames(2)="ROFonts.ROBtsrmVr12"
     FontArrayNames(3)="ROFonts.ROBtsrmVr12"
     FontArrayNames(4)="ROFonts.ROBtsrmVr9"
     FontArrayNames(5)="ROFonts.ROBtsrmVr9"
     FontArrayNames(6)="ROFonts.ROBtsrmVr7"
}
