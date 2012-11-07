//=============================================================================
// Selected weapon info in the trader menu
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class GUIBuyWeaponInfoPanel extends GUIBuyDescInfoPanel;

var automated 	GUILabel		ItemName, WeightLabel;
var automated 	GUIImage 		ItemImage, ItemNameBG, WeightLabelBG;

var automated 	GUILabel 		ItemPower,ItemRange,ItemSpeed; //Weapon stats captions
var automated	GUIWeaponBar 	b_power,b_range,b_speed; //Weapon stats bars

var automated	localized 	String Weight;
var				class<Pickup> 	OldPickupClass;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent(MyController,MyOwner);
	
	b_power.SetValue(0);
	b_power.SetVisibility(false);
	b_speed.SetValue(0);
	b_speed.SetVisibility(false);
	b_range.SetValue(0);
	b_range.SetVisibility(false);
	
	ItemPower.SetVisibility(false);
	ItemRange.SetVisibility(false);
	ItemSpeed.SetVisibility(false);		
}

function Display(GUIBuyable NewBuyable)
{
	if ( NewBuyable == none || NewBuyable.bIsFirstAidKit || NewBuyable.bIsVest )
	{
		b_power.SetValue(0);
		b_power.SetVisibility(false);
		b_speed.SetValue(0);
		b_speed.SetVisibility(false);
		b_range.SetValue(0);
		b_range.SetVisibility(false);
		
		ItemPower.SetVisibility(false);
		ItemRange.SetVisibility(false);
		ItemSpeed.SetVisibility(false);

		WeightLabel.SetVisibility(false);
		WeightLabelBG.SetVisibility(false);
	} 
	else
	{
		b_power.SetValue(NewBuyable.ItemPower);
		b_speed.SetValue(NewBuyable.ItemSpeed);
		b_range.SetValue(NewBuyable.ItemRange);
		
		b_power.SetVisibility(true);
		b_speed.SetVisibility(true);
		b_range.SetVisibility(true);
		
		ItemPower.SetVisibility(true);
		ItemRange.SetVisibility(true);
		ItemSpeed.SetVisibility(true);
		
		WeightLabel.SetVisibility(true);
		WeightLabelBG.SetVisibility(true);		
	}
	
	if ( NewBuyable != none )
	{
		ItemName.Caption = NewBuyable.ItemName;
		ItemNameBG.bVisible = true;
		ItemImage.Image = NewBuyable.ItemImage;
		WeightLabel.Caption = Repl(Weight, "%i", int(NewBuyable.ItemWeight));		
		
		OldPickupClass = NewBuyable.ItemPickupClass;
	}
	else
	{
		ItemName.Caption = "";
		ItemNameBG.bVisible = false;
		ItemImage.Image = none;
		WeightLabel.Caption = "";	
	}
	
	Super.Display(NewBuyable);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=IName
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2LargeFont"
         WinTop=0.005236
         WinLeft=0.035800
         WinWidth=0.928366
         WinHeight=0.070000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     ItemName=GUILabel'KFGui.GUIBuyWeaponInfoPanel.IName'

     Begin Object Class=GUILabel Name=LWeight
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2LargeFont"
         WinTop=0.879874
         WinLeft=0.058031
         WinWidth=0.885273
         WinHeight=0.093913
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     WeightLabel=GUILabel'KFGui.GUIBuyWeaponInfoPanel.LWeight'

     Begin Object Class=GUIImage Name=IImage
         ImageStyle=ISTY_Justified
         WinTop=0.113025
         WinLeft=0.237005
         WinWidth=0.524539
         WinHeight=0.574359
         RenderWeight=2.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemImage=GUIImage'KFGui.GUIBuyWeaponInfoPanel.IImage'

     Begin Object Class=GUIImage Name=INameBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=-0.015493
         WinLeft=0.035800
         WinWidth=0.928366
         WinHeight=0.105446
     End Object
     ItemNameBG=GUIImage'KFGui.GUIBuyWeaponInfoPanel.INameBG'

     Begin Object Class=GUIImage Name=LWeightBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=0.873124
         WinLeft=0.112600
         WinWidth=0.765905
         WinHeight=0.108400
     End Object
     WeightLabelBG=GUIImage'KFGui.GUIBuyWeaponInfoPanel.LWeightBG'

     Begin Object Class=GUILabel Name=PowerCap
         Caption="Power:"
         TextColor=(B=158,G=176,R=175)
         FontScale=FNS_Large
         WinTop=0.588943
         WinLeft=0.131552
         WinWidth=0.739260
         WinHeight=0.070000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemPower=GUILabel'KFGui.GUIBuyWeaponInfoPanel.PowerCap'

     Begin Object Class=GUILabel Name=RangeCap
         Caption="Range:"
         TextColor=(B=158,G=176,R=175)
         FontScale=FNS_Large
         WinTop=0.688943
         WinLeft=0.131552
         WinWidth=0.739260
         WinHeight=0.070000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemRange=GUILabel'KFGui.GUIBuyWeaponInfoPanel.RangeCap'

     Begin Object Class=GUILabel Name=SpeedCap
         Caption="Speed:"
         TextColor=(B=158,G=176,R=175)
         FontScale=FNS_Large
         WinTop=0.788943
         WinLeft=0.131552
         WinWidth=0.739260
         WinHeight=0.070000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemSpeed=GUILabel'KFGui.GUIBuyWeaponInfoPanel.SpeedCap'

     Begin Object Class=GUIWeaponBar Name=PowerBar
         BorderSize=3.000000
         WinTop=0.598943
         WinLeft=0.366433
         WinWidth=0.471784
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     b_power=GUIWeaponBar'KFGui.GUIBuyWeaponInfoPanel.PowerBar'

     Begin Object Class=GUIWeaponBar Name=RangeBar
         Value=-5.000000
         BorderSize=3.000000
         WinTop=0.698943
         WinLeft=0.366433
         WinWidth=0.471784
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     b_range=GUIWeaponBar'KFGui.GUIBuyWeaponInfoPanel.RangeBar'

     Begin Object Class=GUIWeaponBar Name=SpeedBar
         BorderSize=3.000000
         WinTop=0.798943
         WinLeft=0.366433
         WinWidth=0.471784
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     b_speed=GUIWeaponBar'KFGui.GUIBuyWeaponInfoPanel.SpeedBar'

     Weight="Weight: %i blocks"
}
