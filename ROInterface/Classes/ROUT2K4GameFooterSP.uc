//==============================================================================
//  Created on: 12/14/2003
//  This footer goes on Instant Action & Host Multiplayer pages
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class ROUT2K4GameFooterSP extends ButtonFooter;

var automated GUIButton b_Primary, b_Back;
var() localized string PrimaryCaption, PrimaryHint;

var UT2K4GamePageBase Owner;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	Owner = UT2K4GamePageBase(MenuOwner);
	b_Primary.OnClick = Owner.InternalOnClick;
	//b_Secondary.OnClick = Owner.InternalOnClick;
	b_Back.OnClick = Owner.InternalOnClick;
}

function SetupButtons( optional string bPerButtonSizes )
{
	b_Primary.Caption = PrimaryCaption;
	b_Primary.SetHint( PrimaryHint );

	//b_Secondary.Caption = SecondaryCaption;
	//b_Secondary.SetHint( SecondaryHint );

	Super.SetupButtons(bPerButtonSizes);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=GamePrimaryButton
         StyleName="FooterButton"
         WinTop=0.085678
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.036482
         TabOrder=0
         bBoundToParent=True
         OnKeyEvent=GamePrimaryButton.InternalOnKeyEvent
     End Object
     b_Primary=GUIButton'ROInterface.ROUT2K4GameFooterSP.GamePrimaryButton'

     Begin Object Class=GUIButton Name=GameBackButton
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to Previous Menu"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         TabOrder=2
         bBoundToParent=True
         OnKeyEvent=GameBackButton.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'ROInterface.ROUT2K4GameFooterSP.GameBackButton'

}
