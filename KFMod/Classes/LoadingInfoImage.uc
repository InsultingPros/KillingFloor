class LoadingInfoImage extends DrawOpImage;

var string MapTitle,MapAuthor;

function Draw(Canvas Canvas)
{
	local int X,Y;
	local float XS,YS;

	XS = Canvas.ClipX/7*3;
	YS = Canvas.ClipY/7*3;
	X = Canvas.ClipX/2;
	X+=((X-XS)/2);
	Y = ((Canvas.ClipY/2-YS)/5*3);
	Canvas.SetPos(X,Y);
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawTile(Image,XS,YS,0,0,Image.MaterialUSize(),Image.MaterialVSize());
	if( MapTitle=="" || MapTitle~=Class'LevelInfo'.Default.Title ) Return;
	X+=4;
	Y+=3;
	Canvas.SetPos(X,Y);
	if( Canvas.ClipY>580 )
		Canvas.Font = Class'HUDKillingFloor'.Static.LoadFontStatic(3);
	else Canvas.Font = Class'HUDKillingFloor'.Static.LoadFontStatic(2);
	Canvas.DrawText(MapTitle);
	if( MapAuthor=="" || MapAuthor==Class'LevelInfo'.Default.Author )
		Return;
	X+=10;
	if( Canvas.ClipY>580 )
		Y+=22;
	else Y+=18;
	Canvas.SetPos(X,Y);
	Canvas.SetPos(X,Y);
	Canvas.DrawText("By"@MapAuthor);
}

defaultproperties
{
}
