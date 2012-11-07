class KFEULA extends LargeWindow;

const NUM_EULA_LINES = 86;

var localized string EULA_Text[NUM_EULA_LINES];

var automated GUIScrollTextBox lb_EULA;

var automated GUIButton b_Accept, b_Quit;

var bool bAgreedToEULA;

function bool InternalOnCanClose(optional bool bCanceled)
{
    return bAgreedToEULA;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local string temp;
    local int i;

	Super.InitComponent(MyController,MyOwner);

    temp = "";
    for (i = 0; i < NUM_EULA_LINES; i++)
        temp $= EULA_Text[i];

	lb_EULA.SetContent(temp);
	b_ExitButton.OnClick = QuitClicked;
}

function bool AcceptClicked(GUIComponent Sender)
{
    local GUIPage page;

    page = Controller.FindMenuByClass(Class'KFMainMenu');
    if (KFMainMenu(page) == none)
        warn("Unable to find KFMainMenu in menu stack! EULA cannot be marked as accepted.");
    else
    {
        KFMainMenu(page).AcceptedEULA = true;
        KFMainMenu(page).SaveConfig();
    }

    bAgreedToEULA = true;
	Controller.RemoveMenu(self);
    return true;
}

function bool QuitClicked(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("exit");
    return true;
}

function bool NotifyLevelChange()
{
	LevelChanged();
	return false;
}

function bool InternalOnKeyEvent(out byte Key,out byte State,float delta)
{
	if(Key == 0x1B && State == 1)	// Escape pressed
	{
		QuitClicked(none);
		return true;
	}
	else
		return false;
}

defaultproperties
{
     EULA_Text(0)="Killing Floor EULA [END USER LICENSE AGREEMENT]|"
     EULA_Text(1)="|"
     EULA_Text(2)="      Tripwire Interactive would like to thank you for getting Killing Floor.   We hope you enjoy the experience.  But before you get started, we need to make some matters clear.   When you paid for Killing Floor you did not actually buy the game.  What you bought was a license to use the software that comprises the game and its related materials.  And that license is subject to the terms of this EULA.  This EULA is a binding contract between you and Tripwire Interactive and its licensors, licensees and suppliers.  |"
     EULA_Text(3)="|"
     EULA_Text(4)="      We know you want to get the game installed and start playing it.  But, please take the time to read through this agreement first because BY INSTALLING KILLING FLOOR YOU ARE ACKNOWLEDGING THAT YOU HAVE READ THIS EULA, AGREE TO ITS TERMS AND AGREE TO BE BOUND BY THEM.  IF YOU DO NOT AGREE TO THESE TERMS, PROMPTLY DISCONTINUE THE INSTALLATION PROCESS AND CEASE ANY AND ALL USE OF THIS SOFTWARE.|"
     EULA_Text(5)="|"
     EULA_Text(6)="1.    Limited Use License|"
     EULA_Text(7)="|"
     EULA_Text(8)="      Killing Floor software and any files that are provided with it by digital distribution or on tangible media, including the KF Editor, as well as any printed materials, patches or updates, (collectively referred to as 'KF') contains copyrighted material, trade secrets and other proprietary material of Tripwire Interactive and  its licensors, licensees and suppliers.   KF is licensed to you for your use.  This license is a non exclusive limited license to install and use KF for yourself, including use over the internet or on a LAN.  Your continuing license to use KF is conditioned on your compliance with this EULA.  If you violate any of the terms of this EULA, all of your rights to use KF will immediately end, without any further notification from Tripwire Interactive or anyone else.  Once your license is terminated, you will be obliged to immediately uninstall KF and all of its components.|"
     EULA_Text(9)="|"
     EULA_Text(10)="2.    Permitted User Modifications and New Creations|"
     EULA_Text(11)="|"
     EULA_Text(12)="      The Killing Floor Editor ('KFEd') comes with KF.  You can use KFEd to make mods or create new content to be played in KF.  You agree that you will not distribute or share the KFEd because it is not shareware.  You agree that any new creations or materials that you make for KF, with or without the KFEd, (collectively referred to as 'Mods') are subject to the following restrictions:|"
     EULA_Text(13)="|"
     EULA_Text(14)="    - Your Mods must only work with the full, registered copy of KF, not independently or with any other software.|"
     EULA_Text(15)="      |"
     EULA_Text(16)="    - Your Mods must not contain modifications to any executable file(s).|"
     EULA_Text(17)="|"
     EULA_Text(18)="    - Your Mods must not contain any libelous, defamatory, or other illegal material, material that is scandalous or invades the rights of privacy or publicity of any third party, nor may your Mods contain, or be used in conjunction with, any trademarks, copyright protected work, or other recognizable property of third parties without their written authority, nor may your Mods be used by you, or anyone else, for any commercial exploitation including, but not limited to in-game advertising, other advertising or marketing for any company, product or service.|"
     EULA_Text(19)="|"
     EULA_Text(20)="    - While we encourage folks to make Mods, Mods will not be supported by Tripwire Interactive and its licensors, licensees or suppliers, and if distributed pursuant to this license your Mods must include a statement to that effect.|"
     EULA_Text(21)="|"
     EULA_Text(22)="    - Your Mods must be distributed for free, period.  Neither you, nor any other person or party, may sell them to anyone, commercially exploit them in any way, or charge anyone for receiving or using them without prior written consent from Tripwire Interactive.  You may exchange them at no charge among other end users and distribute them to others over the Internet, on magazine cover disks, or otherwise for free.|"
     EULA_Text(23)="|"
     EULA_Text(24)="    - The prohibitions and restrictions in this section apply to anyone in possession of KF or any Mods.|"
     EULA_Text(25)="|"
     EULA_Text(26)="      Tripwire Interactive wholeheartedly supports the Modding of KF.  But we need to retain all of our ownership rights in KF and any works derived from KF.  That's just the way it is.  So, go make some more cool stuff.  But remember that you do not gain any ownership whatsoever in any KF content nor can you use any KF content outside the scope of the rights granted here.   |"
     EULA_Text(27)="|"
     EULA_Text(28)="3.    Commercial Exploitation|"
     EULA_Text(29)="|"
     EULA_Text(30)="      You may not use KF, or any Mods created for or from KF or using the KFEd or any other tools provided with this KF, for any commercial purposes without the prior written consent of Tripwire Interactive or its authorized licensees including, but not limited to, the following rules: 1. If you are the proprietor of an Internet cafe or gaming room, you may operate the KF in a 'pay for play' environment provided that all computers each have validly licensed KF installed, such KF having been properly purchased through one of our licensees.  2. You may not, without"
     EULA_Text(31)=" prior written consent from Tripwire Interactive, operate the KF in any gaming contest where (a) the cash value of all winnings and prizes paid throughout the entire competition is equal to or greater than US$10,000.00 or (b) the name of the event, or any individual contest therein, incorporates or approximates the name of a company, product or commercial service or (c) any company has provided, whether donated or as sponsorship any prizes, products or services worth with a fair market value of over US$20,000.00. |"
     EULA_Text(32)="|"
     EULA_Text(33)="4.    Restrictions on Use|"
     EULA_Text(34)="|"
     EULA_Text(35)="      Just to make sure you understand what you can and can not do with KF, here is a list of restrictions to your use of KF under this EULA:|"
     EULA_Text(36)="|"
     EULA_Text(37)="    - You may not decompile, modify, reverse engineer, publicly display, prepare derivative works based on KF (except as permitted in Section 2, above), disassemble or otherwise reproduce KF.|"
     EULA_Text(38)="|"
     EULA_Text(39)="    - Except as set forth herein, you may not rent, sell, lease, barter, sublicense or distribute KF.  ||"
     EULA_Text(40)="    - You may not delete the copyright notices or any other proprietary legends on the original copy of KF.  |"
     EULA_Text(41)="|"
     EULA_Text(42)="    - You may not offer KF on a pay per play basis or otherwise commercially exploit KF or use KF for any commercial purpose except as described in this agreement.  |"
     EULA_Text(43)="|"
     EULA_Text(44)="    - You may not electronically transmit KF from one computer to another or over a network except as described in this agreement.  |"
     EULA_Text(45)="|"
     EULA_Text(46)="5.    Export Controls|"
     EULA_Text(47)="|"
     EULA_Text(48)="      You may not ship or export KF to any country other than where you bought it, in violation of the U.S. Export Administration Act (or any other law governing such matters) and you will not utilize and will not authorize anyone to utilize KF in violation of any applicable law.  KF may not be downloaded or otherwise exported into (or to a national or resident of) any country to which the U.S. has embargoed goods or to anyone or into any country who/which are prohibited by applicable law, from receiving it.|"
     EULA_Text(49)="|"
     EULA_Text(50)="6.    Cheats and Cheating|"
     EULA_Text(51)="|"
     EULA_Text(52)="      KF was made for gamers by gamers.  We hate cheaters and will not tolerate anyone cheating in KF or any KF Mods.  It's as simple as that.  If you are cheating in any way, including any attempt by you, either directly or indirectly, to circumvent or bypass any element of the KF or any KF servers to gain any advantage in multiplayer play of the KF or any KF Mods, you are in breach of this EULA.  It is a breach of this EULA for you, whether directly or indirectly, to create, develop, copy, reproduce, distribute, or use any software program or any modification to KF or any KF Mods ('Cheats') that enable a player to gain an advantage or otherwise exploit another player when playing against other players on a local area network, any other network, or on the Internet."
     EULA_Text(53)="  Hacking into the executable of KF or any KF Mods or any other use of the KF or any KF Mods in connection with the creation, development, or use of any such unauthorized Cheats is prohibited under this EULA. Cheats include, but are not limited to, programs that allow players to see through walls or other level geometry (software or hardware 'wall hacks'); programs that let players change their rate of speed outside the allowable limits of KF ('speed hacks'); programs that crash any other players, PC clients, or network servers; 'aimbots' that automatically target other players or that automatically simulate any other player input to gain an advantage over other players; or any other program or modification that functions in a similar capacity or allows any prohibited conduct.|"
     EULA_Text(54)="|"
     EULA_Text(55)="      if we find you are a Cheater, we will revoke your CD key, ban you from the KF servers and tell your mom!  Your license will automatically terminate, without notice, and you will have no right to play KF or any KF Mods against other players or make any other use of KF.  End of story.  |"
     EULA_Text(56)="|"
     EULA_Text(57)="7.    Copyright.  |"
     EULA_Text(58)="|"
     EULA_Text(59)="      KF and all copyrights, trademarks and all other conceivable intellectual property rights related to the KF are owned by Tripwire Interactive or its licensors, licensees or suppliers and are protected by United States copyrights laws, international treaty provisions, and all applicable laws, such as the Lanham Act.  KF must be treated like any other copyrighted material, as required by 17 U.S.C. Sec.101 et seq. and other applicable law.  Please do not make unauthorized copies.  KF was created through the efforts of many people who earn their livelihood from its lawful use.  Please don't make copies for others who have not paid for the right to use it.  To report copyright violations to the Software Publishers Association, call 1 800 388 PIR8 or write:  Software Publishers Association, 1101 Connecticut Ave., Suite 901, Washington, D.C. 20036.|"
     EULA_Text(60)="|"
     EULA_Text(61)="8.    Massive Technology|"
     EULA_Text(62)="      This game incorporates technology of Massive Incorporated ("
     EULA_Text(63)="|"
     EULA_Text(64)="      For additional details regarding Massive’s in-game advertising practices, please see Massive's In-Game Advertising privacy statement at http://go.microsoft.com/fwlink/?LinkId=122085&clcid=0x409. The trademarks and copyrighted material contained in all in-game advertising are the property of the respective owners. Portions of this product are © 2009 Massive Incorporated. All rights reserved.|"
     EULA_Text(65)="9.    Disclaimer of Warranty|"
     EULA_Text(66)="|"
     EULA_Text(67)="      You are aware and agree that use of KF and the media on which it is recorded, if any, is at your sole risk.  KF is provided 'AS IS.'  TRIPWIRE INTERACTIVE EXPRESSLY DISCLAIMS ALL OTHER WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. WE DO NOT WARRANT THAT THE FUNCTIONS CONTAINED IN THE SOFTWARE WILL MEET YOUR REQUIREMENTS. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY US OR ANY OF OUR AUTHORIZED REPRESENTATIVES SHALL CREATE A WARRANTY OR IN ANY WAY INCREASE THE SCOPE OF THIS WARRANTY. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO THE ABOVE EXCLUSIONS MAY NOT APPLY TO YOU.|"
     EULA_Text(68)="|"
     EULA_Text(69)="10.     Limitation of Liability|"
     EULA_Text(70)="|"
     EULA_Text(71)="      UNDER NO CIRCUMSTANCES, INCLUDING WILLFUL ACTS OR NEGLIGENCE, SHALL TRIPWIRE INTERACTIVE OR ANY OF ITS OFFICERS, EMPLOYEES, DIRECTORS, AGENTS, LICENSORS, LICENSEES, SUBLICENSEE, SUPPLIERS  OR ASSIGNS BE LIABLE FOR ANY INCIDENTAL, SPECIAL OR CONSEQUENTIAL DAMAGES THAT RESULT FROM THE USE OF OR INABILITY TO USE KF OR ITS RELATED DOCUMENTATION, EVEN IF SUCH PARTIES HAVE BEEN ADVISED OF THE POSSIBILITY OF THOSE DAMAGES.  THERE WILL BE NO LIABILITY FOR ANY PERSONAL INJURY, EVEN SELF INFLICTED INJURY, OR FOR ANY INTENTIONAL TORT COMMITTED BY YOU OR ANY OTHER PERSON WHO PLAYS OR OBSERVES SOMEONE ELSE PLAYING KF.  SOME JURISDICTIONS do NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OR CONSEQUENTIAL DAMAGES SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU. In no event shall our total liability to you for all damages, losses, and causes of action (whether in contract, tort or otherwise) exceed the amount paid by you for KF.|"
     EULA_Text(72)="|"
     EULA_Text(73)="11.    Controlling Law and Severability.  |"
     EULA_Text(74)="|"
     EULA_Text(75)="      This license is governed by and construed in accordance with the laws of the State of Georgia, USA.  Exclusive venue for all litigation shall be in Fulton County, Georgia.  If any provision of this EULA is determined to be unenforceable by a court or other tribunal of competent jurisdiction, such provision will be enforced to the maximum extent permissible and the remaining portions of this EULA will remain in full force and effect.|"
     EULA_Text(76)="|"
     EULA_Text(77)="12.    Complete Agreement.  |"
     EULA_Text(78)="|"
     EULA_Text(79)="      This EULA constitutes the entire agreement between the parties with respect to the use of KF, KFEd, Mods and other related materials and software.  Tripwire Interactive reserves the right to modify the terms of this EULA from time to time and will post notice of material changes somewhere within www.tripwireinteractive.com.|"
     EULA_Text(80)="|"
     EULA_Text(81)="13.    Acceptance of Terms|"
     EULA_Text(82)="|"
     EULA_Text(83)="      By selecting the 'I Agree' choice during the installation and by installing KF, you agree to all the terms specified in this EULA.  That's right, all of them.  Now get on with the installation and enjoy KF... We hope you enjoy it as much as we enjoyed making it.|"
     EULA_Text(84)="|"
     EULA_Text(85)="GL & HF!"
     Begin Object Class=GUIScrollTextBox Name=EULABox
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=EULABox.InternalOnCreateComponent
         WinTop=0.255000
         WinLeft=0.230000
         WinWidth=0.540000
         WinHeight=0.480000
         TabOrder=2
     End Object
     lb_EULA=GUIScrollTextBox'KFGui.KFEULA.EULABox'

     Begin Object Class=GUIButton Name=ButtonAccept
         Caption="I ACCEPT"
         Hint="Click this button if you accept the terms of the End User License Agreement."
         WinTop=0.741666
         WinLeft=0.262500
         WinWidth=0.200000
         WinHeight=0.036482
         TabOrder=3
         OnClick=KFEULA.AcceptClicked
         OnKeyEvent=ButtonAccept.InternalOnKeyEvent
     End Object
     b_Accept=GUIButton'KFGui.KFEULA.ButtonAccept'

     Begin Object Class=GUIButton Name=ButtonQuit
         Caption="I DO NOT ACCEPT"
         Hint="Click this button if you do not accept the terms of the End User License Agreement."
         WinTop=0.741666
         WinLeft=0.537500
         WinWidth=0.200000
         WinHeight=0.036482
         TabOrder=4
         OnClick=KFEULA.QuitClicked
         OnKeyEvent=ButtonQuit.InternalOnKeyEvent
     End Object
     b_Quit=GUIButton'KFGui.KFEULA.ButtonQuit'

     WindowName="End User License Agreement"
     OnKeyEvent=KFEULA.InternalOnKeyEvent
}
