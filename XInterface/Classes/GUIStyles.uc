// ====================================================================
//  Class:  UT2K4UI.GUIStyles
//
//  The GUIStyle is an object that is used to describe common visible
//  components of the interface.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIStyles extends GUI
	Abstract
    Native
	noteditinlinenew;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var(Style) const string              KeyName;            // This is the name of the style used for lookup

//  If the desired keyname is one of these, FontScale will be adjusted
//  For backwards compatibility - 0 - Smaller 1 - Larger
var(Style) const string             AlternateKeyName[2];

/* Each style contains 5 values for each font, per size
      Small  0 - 4
      Medium 5 - 9
      Large 10 - 14
*/
var(Style) noexport       string              FontNames[15];       // Holds the names of the 5 fonts to use
var(Style) noexport       GUIFont             Fonts[15];           // Holds the fonts for each state

var(Style) noexport       color               FontColors[5];      // This array holds 1 font color for each state
var(Style) noexport       color               FontBKColors[5];    // This holds the Background Colors for each state
var(Style) noexport       color               ImgColors[5];       // This array holds 1 image color for each state

var(Style) noexport       EMenuRenderStyle    RStyles[5];         // The render styles for each state
var(Style) noexport       Material            Images[5];          // This array holds 1 material for each state (Blurry, Watched, Focused, Pressed, Disabled)
var(Style) noexport       eImgStyle           ImgStyle[5];        // How should each image for each state be drawed
var(Style) noexport       float               ImgWidths[5];       // -1 if full image
var(Style) noexport       float               ImgHeights[5];      // -1 if full image
var(Style) noexport       int                 BorderOffsets[4];   // How thick is the border

var(style) noexport bool	bTemporary;		// This style should be cleaned up

// the OnDraw delegate Can be used to draw.  Return true to skip the default draw method

delegate bool OnDraw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height);
delegate bool OnDrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text, eFontScale FontScale);

native static final function Draw(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height);
native static final function DrawText(Canvas Canvas, eMenuState MenuState, float left, float top, float width, float height, eTextAlign Align, string Text, eFontScale FontScale);
native static final function TextSize(Canvas Canvas, eMenuState MenuState, string Text, out float XL, out float YL, eFontScale FontScale);

event Initialize()
{
    local int i;

    // Preset all the data if needed
    for ( i = 0; i < ArrayCount(FontNames) && i < ArrayCount(Fonts); i++)
    {
        if (FontNames[i] != "")
            Fonts[i] = Controller.GetMenuFont(FontNames[i]);
    }
}

defaultproperties
{
     FontNames(0)="UT2SmallFont"
     FontNames(1)="UT2SmallFont"
     FontNames(2)="UT2SmallFont"
     FontNames(3)="UT2SmallFont"
     FontNames(4)="UT2SmallFont"
     FontNames(5)="UT2MenuFont"
     FontNames(6)="UT2MenuFont"
     FontNames(7)="UT2MenuFont"
     FontNames(8)="UT2MenuFont"
     FontNames(9)="UT2MenuFont"
     FontNames(10)="UT2LargeFont"
     FontNames(11)="UT2LargeFont"
     FontNames(12)="UT2LargeFont"
     FontNames(13)="UT2LargeFont"
     FontNames(14)="UT2LargeFont"
     FontColors(0)=(B=225,G=225,R=225,A=255)
     FontColors(1)=(B=255,G=255,R=255,A=255)
     FontColors(2)=(B=225,G=225,R=225,A=255)
     FontColors(3)=(B=225,G=225,R=225,A=255)
     FontColors(4)=(B=125,G=125,R=125,A=255)
     FontBKColors(0)=(A=255)
     FontBKColors(1)=(A=255)
     FontBKColors(2)=(A=255)
     FontBKColors(3)=(A=255)
     FontBKColors(4)=(A=255)
     ImgColors(0)=(B=255,G=255,R=255,A=255)
     ImgColors(1)=(B=255,G=255,R=255,A=255)
     ImgColors(2)=(B=255,G=255,R=255,A=255)
     ImgColors(3)=(B=255,G=255,R=255,A=255)
     ImgColors(4)=(B=128,G=128,R=128,A=255)
     RStyles(0)=MSTY_Normal
     RStyles(1)=MSTY_Normal
     RStyles(2)=MSTY_Normal
     RStyles(3)=MSTY_Normal
     RStyles(4)=MSTY_Normal
     ImgStyle(0)=ISTY_Stretched
     ImgStyle(1)=ISTY_Stretched
     ImgStyle(2)=ISTY_Stretched
     ImgStyle(3)=ISTY_Stretched
     ImgStyle(4)=ISTY_Stretched
     ImgWidths(0)=-1.000000
     ImgWidths(1)=-1.000000
     ImgWidths(2)=-1.000000
     ImgWidths(3)=-1.000000
     ImgWidths(4)=-1.000000
     ImgHeights(0)=-1.000000
     ImgHeights(1)=-1.000000
     ImgHeights(2)=-1.000000
     ImgHeights(3)=-1.000000
     ImgHeights(4)=-1.000000
     BorderOffsets(0)=10
     BorderOffsets(1)=10
     BorderOffsets(2)=10
     BorderOffsets(3)=10
}
