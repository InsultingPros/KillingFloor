// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class STY_ListSelection extends GUIStyles;

event Initialize()
{
    local int i;

    super.Initialize();

    for (i=0;i<5;i++)
        Images[i]=Controller.DefaultPens[0];
}

defaultproperties
{
     KeyName="ListSelection"
     FontNames(10)="UT2HeaderFont"
     FontNames(11)="UT2HeaderFont"
     FontNames(12)="UT2HeaderFont"
     FontNames(13)="UT2HeaderFont"
     FontNames(14)="UT2HeaderFont"
     FontColors(0)=(B=128,G=64,R=64)
     FontColors(1)=(B=128,G=64,R=64)
     FontColors(2)=(B=128,G=64,R=64)
     FontColors(3)=(B=128,G=64,R=64)
     FontColors(4)=(B=128,G=64,R=64)
}
