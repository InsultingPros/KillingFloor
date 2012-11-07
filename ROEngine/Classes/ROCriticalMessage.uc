//=============================================================================
// ROCriticalMessage
// started by EMH_Mark3 on 10/26/2005
//
// Copyright (C) 2003 Jeffrey Nakai
//
// Used to display critical messages on the hud
//=============================================================================
class ROCriticalMessage extends ROStringMessage;

var bool bQuickFade;
var float quickFadeTime;     // if bQuickFade = true, then keep message on for lifetime
                             // and then fade in quickFadeTime seconds

var float TextAlpha;

var float timePerCharacter;

var int iconID;
var int altIconID;
var int errorIconID;

var Material iconTexture;

var float maxMessageWidth;    // Maximum width that a message can take on the screen before wrapping (0-1)

var int maxMessagesOnScreen;

static function RenderComplexMessageExtra(
    Canvas Canvas,
    out float XL,
    out float YL,
    out float YL_temp,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject,
    optional array<string> lines,
    optional int background_type
    )
{
    local color oldColor;
    local float totalXL;
    local float tileX, tileY, tileXL, tileYL, iconSize;
    local float textX, textY;
    local float myXL, myYL;
    local int i, iconID;

    oldColor = Canvas.DrawColor;
    iconSize = YL / lines.length;
    totalXL = XL + (iconSize * 1.4);

    tileX = Canvas.CurX;
    tileY = Canvas.CurY;
    tileXL = totalXL * (float(256) / (256 - 30));
    tileYL = YL * (float(64) / (64 - 20));
    textX = tileX + totalXL * (float(15) / (256 - 30));
    textY = tileY + YL * (float(10) / (64 - 20));

    Canvas.SetPos(tileX, tileY);
    Canvas.Style =  ERenderStyle.STY_Normal;
    Canvas.SetDrawColor(255, 255, 255, oldColor.A);
    if (oldColor.A != 0) // fix: for some reason, alpha of 0 is considered the same as alpha of 255 for images
    {
        // Draw background
//        Canvas.DrawTile(Texture'InterfaceArt_tex.HUD.CriticalMsgBackground',
//            tileXL, tileYL, 0, background_type * 64, 256, 64);

        // Draw icon
        if (lines.length == 1)
            Canvas.SetPos(textX, textY);
        else
            Canvas.SetPos(textX, textY + iconSize / 2);

        iconID = GetIconID(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

        Canvas.DrawTile(default.iconTexture, iconSize, iconSize, (iconID % 4) * 64, (iconID / 4) * 64, 64, 64);
    }

    // Draw all lines of text iteratively
    Canvas.DrawColor = oldColor;
    Canvas.DrawColor.A = float(Canvas.DrawColor.A) * default.TextAlpha;
    for (i = 0; i < lines.length; i++)
    {
        Canvas.SetPos(textX + totalXL - XL, textY);
   	    Canvas.DrawText(lines[i]);
   	    Canvas.TextSize(lines[i], myXL, myYL);
   	    textY += myYL;
   	}

    // To let ROHud how large a gap it should give between messages
    YL_temp = (tileYL + iconSize * 0.2) / Canvas.ClipY;
}

// Calculate how long message should be displayed based on number of characters in string
/*static function float GetLifeTime(int Switch)
{
    local string message;
    message = GetString(switch);
    return Min(Max(Len(message) * default.timePerCharacter, 3), default.LifeTime);
}*/

static function int getIconID(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
    return default.iconID;
}

defaultproperties
{
     bQuickFade=True
     quickFadeTime=1.000000
     TextAlpha=0.750000
     timePerCharacter=0.300000
     iconID=11
     altIconID=11
     errorIconID=11
     iconTexture=Texture'InterfaceArt_tex.HUD.criticalmessages_icons'
     maxMessageWidth=0.300000
     maxMessagesOnScreen=4
     bComplexString=True
     bIsSpecial=True
     bFadeMessage=True
     DrawColor=(B=0,G=0,R=0)
     DrawPivot=DP_UpperLeft
     StackMode=SM_Down
     PosX=0.020000
     PosY=0.020000
     FontSize=-2
}
