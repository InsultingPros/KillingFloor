//=============================================================================
// RODrawOpShadowedText
//=============================================================================
// Special DrawOpText class that draws text with a shadow.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class RODrawOpShadowedText extends DrawOpText;

var color shadowColor;
var int shadowXOffset;
var int shadowYOffset;

function Draw(Canvas Canvas)
{
	local Font Fnt;
	local int i, pass;
	local float X, Y, XL, YL, TextHeight, StrHeight, StrWidth;
	local array<string> Lines;
	local int xoffset, yoffset;
	local color SavedColor;

	super(DrawOpBase).Draw(Canvas);
	if (FontName != "")
	{
		Fnt = GetFont(FontName, Canvas.SizeX);
		if (Fnt != None)
			Canvas.Font = Fnt;
	}

	Canvas.FontScaleX = 0.9;
	Canvas.FontScaleY = 0.9;

	X = Lft * Canvas.SizeX;
	XL = Width * Canvas.SizeX;
	YL = Height * Canvas.SizeY;

	Canvas.StrLen(Text, StrWidth, StrHeight);
	if (bWrapText) Canvas.WrapStringToArray(Text, Lines, XL, "|");
		else Lines[0] = Text;
	TextHeight = StrHeight * Lines.length;

    for (pass = 0; pass < 2; pass++)
    {
        if (pass == 0) // shadow pass
        {
            SavedColor = Canvas.DrawColor;
            Canvas.DrawColor = shadowColor;
            xoffset = shadowXOffset;
            yoffset = shadowYOffset;
        }
        else // normal pass
        {
            xoffset = 0;
            yoffset = 0;
            Canvas.DrawColor = SavedColor;
        }

       	Y = Top * Canvas.SizeY;

    	switch ( VertAlign )
    	{
    		case 1: // Center
    			Y = Y + (YL - TextHeight) / 2;
    			break;

    		case 2: // Bottom
    			Y = Y + YL - TextHeight;
    			break;
    	}

    	for ( i = 0; i < Lines.Length; i++ )
    	{
    		Canvas.StrLen(Lines[i], StrWidth, StrHeight);
    		switch ( Justification )
    		{
    			case 0: // left
    				Canvas.SetPos(X + xoffset, Y + yoffset);
    				break;

    			case 1: // center
    				Canvas.SetPos(X + (XL - StrWidth) / 2 + xoffset, Y + yoffset);
    				break;

    			case 2: // right
    				Canvas.SetPos(X + XL - StrWidth + xoffset, Y + yoffset);
    				break;
    		}

    		Canvas.DrawText(Lines[i]);
    		Y += StrHeight;
    	}
    }
}

defaultproperties
{
     ShadowColor=(A=255)
     shadowXOffset=1
     shadowYOffset=1
}
