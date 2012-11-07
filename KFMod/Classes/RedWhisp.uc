//=============================================================================
// RedWhisp
//=============================================================================
// Effect used to show the path to the trader
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class RedWhisp extends TraderPathEffect;

defaultproperties
{
     mSizeRange(0)=25.000000
     mSizeRange(1)=30.000000
     mColorRange(0)=(B=40,G=40)
     mColorRange(1)=(B=40,G=40)
     mNumTileColumns=4
     mNumTileRows=4
     Skins(0)=Texture'ROEffects.SmokeAlphab_t'
     Style=STY_Additive
}
