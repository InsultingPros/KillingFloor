class KF_Roulette_Screen extends Actor
placeable;

var         ScriptedTexture                                         ScriptedScreen;

var         Shader                                                  ShadedScreen;

var         Material                                                ScriptedScreenBack;

var         Font                                                    ScreenFont;

var         color                                                   BackColor;

/* Reference to the table this zone belongs to */
var         KF_Roulette_Wheel                                       OwningTable;

simulated function PostBeginPlay()
{
    InitMaterials();
}

simulated function InitMaterials()
{
	if( ScriptedScreen==None )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = Self;
	}

	if( ShadedScreen==None )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScriptedScreen;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		skins[0] = ShadedScreen;
	}
}

simulated function Tick(float DeltaTime)
{
    if(ScriptedScreen != none)
    {
	   ScriptedScreen.Revision++;
        if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local int SizeX,  SizeY;
    local string WinningNumber;
    local color WinningClr;
    local string ClrString;
    local int i;
    local float PosX,PosY;

	Tex.DrawTile(0,0,Tex.USize,Tex.VSize,0,0,256,256,Texture'KillingFloorWeapons.Welder.WelderScreen',BackColor);   // Draws the tile background

    PosX = Tex.USize/2 ;
    PosY = Tex.VSize/2 ;

    for(i = OwningTable.WinningNumbers.length-1 ; i >= 0; i --)
    {
        if(i == OwningTable.WinningNumbers.length-1)
        {
            WinningNumber = ">>>"$OwningTable.WinningNumbers[i]$"<<<";
        }
        else
        {
            WinningNumber = string(OwningTable.WinningNumbers[i]);
        }

        ClrString = Owningtable.GetPocketClr(OwningTable.WinningNumbers[i]);

        switch(ClrString)
        {
            case "Black" :  WinningClr = class 'Canvas'.static.MakeColor(0,0,0);       break;
            case "Red"   :  WinningClr = class 'Canvas'.static.MakeColor(255,50,50);   break;
            case "Green" :  WinningClr = class 'Canvas'.static.MakeColor(50,255,50);   break;
        }

        Tex.TextSize(WinningNumber,ScreenFont,SizeX,SizeY);
        Tex.DrawText(PosX - SizeX/2, PosY - SizeY/2,WinningNumber,ScreenFont,WinningClr);
        PosY -= (SizeY * 1.25);
    }
}

defaultproperties
{
     ScreenFont=Font'ROFonts.ROBtsrmVr24'
     BackColor=(B=128,G=128,R=128,A=255)
}
