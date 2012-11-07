//=====================================================
// ROCreditsPage
// Last change: 05.19.2004 by Puma
//
// Used for displaying the ROCredits
// Copyright 2003 by Red Orchestra
//=====================================================

class ROCreditsPage extends LargeWindow;

const NUM_CREDITS_LINES = 331;

var automated GUIButton b_Close;

var automated GUIScrollTextBox lb_credits;

var localized string credits_lines[NUM_CREDITS_LINES];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string text;
	local int i;

    super.InitComponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    for (i = 0; i < NUM_CREDITS_LINES; i++)
        text $= credits_lines[i] $ "|";

    lb_credits.SetContent(text);
}

function bool InternalOnClick(GUIComponent Sender)
{
	//if (Sender==Controls[1])
	if(Sender == b_close)
	{
		Controller.CloseMenu();
	}
	return true;
}

function bool ButtonClick(GUIComponent Sender)
{
	if ( Sender == b_close )
		Controller.CloseMenu();

	return true;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.900000
         WinLeft=0.400000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=ROCreditsPage.InternalOnClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     b_Close=GUIButton'ROInterface.ROCreditsPage.CloseButton'

     Begin Object Class=GUIScrollTextBox Name=CreditsText
         bNoTeletype=True
         OnCreateComponent=CreditsText.InternalOnCreateComponent
         WinTop=0.080000
         WinLeft=0.070000
         WinWidth=0.860000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_credits=GUIScrollTextBox'ROInterface.ROCreditsPage.CreditsText'

     credits_lines(0)="CREDITS"
     credits_lines(1)="For Tripwire Interactive LLC"
     credits_lines(3)="Tripwire Interactive"
     credits_lines(4)="President"
     credits_lines(5)="John Gibson"
     credits_lines(6)="Vice President"
     credits_lines(7)="Alan Wilson"
     credits_lines(9)="Game Design"
     credits_lines(10)="Ingmar Spit - Lead Designer & Lead Level Designer"
     credits_lines(11)="John Gibson - Lead Programmer & Producer"
     credits_lines(12)="Alan Wilson - Historian, Lead Researcher & PR"
     credits_lines(13)="William T Munk II - Art Director & Lead Animator"
     credits_lines(14)="David Hensley - Senior Artist"
     credits_lines(16)="Programming"
     credits_lines(17)="John Gibson"
     credits_lines(18)="Mathieu Mallet"
     credits_lines(19)="Justin Harvey "
     credits_lines(20)="Dayle Flowers"
     credits_lines(21)="Stephen Cooney"
     credits_lines(23)="Level Design"
     credits_lines(24)="Ingmar Spit"
     credits_lines(25)="Bruce Rennie"
     credits_lines(26)="Cass Cousins "
     credits_lines(27)="Colin Murphy "
     credits_lines(28)="Jim Mcleish "
     credits_lines(29)="Kenneth Reising "
     credits_lines(30)="Rich Black"
     credits_lines(31)="Robert Chudalla"
     credits_lines(32)="Andrew Boulton"
     credits_lines(34)="Art"
     credits_lines(35)="William T Munk II"
     credits_lines(36)="David Hensley"
     credits_lines(38)="Graphic Design"
     credits_lines(39)="Christopher Choi"
     credits_lines(41)="Interface Design"
     credits_lines(42)="Christopher Choi"
     credits_lines(43)="William T Munk II"
     credits_lines(46)=" "
     credits_lines(47)="3D Artists"
     credits_lines(48)="William T Munk II"
     credits_lines(49)="David Hensley"
     credits_lines(50)="Ben Knapp - Lead Environmental Artist"
     credits_lines(51)="Wayne Williams"
     credits_lines(52)="Nikolas Sumnall"
     credits_lines(53)="Rob Dion"
     credits_lines(54)="Elie Hang"
     credits_lines(55)="Martin Behrend"
     credits_lines(56)="Anthony Barreras"
     credits_lines(57)="Matt Coutras "
     credits_lines(58)="Roy Thompson"
     credits_lines(59)="Ingmar Spit"
     credits_lines(60)="with"
     credits_lines(61)="Jonathan Shaw"
     credits_lines(62)="Dave Bryce"
     credits_lines(63)="Serguei Kalentchouk"
     credits_lines(64)="Eitan Kadouri"
     credits_lines(65)="Jason Lavoie"
     credits_lines(66)="Noah Calab"
     credits_lines(67)="Max Bagdasarov"
     credits_lines(68)="Joe LaCroix"
     credits_lines(69)="Dean Barrowcliff"
     credits_lines(70)="Joel Heethaar"
     credits_lines(72)="Texture Artists"
     credits_lines(73)="George Baker - Character Artist"
     credits_lines(74)="Martin Behrend - Vehicle Artist"
     credits_lines(75)="Ben Knapp"
     credits_lines(76)="Elie Hang"
     credits_lines(77)="Leland Scali"
     credits_lines(78)="Rob Dion"
     credits_lines(79)="David Hensley"
     credits_lines(80)="Ingmar Spit"
     credits_lines(81)="with"
     credits_lines(82)="Noah Calab"
     credits_lines(83)="Anthony Barreras"
     credits_lines(84)="Zach Shertz"
     credits_lines(86)="Animation"
     credits_lines(87)="William T Munk II "
     credits_lines(88)="Nikolas Sumnall"
     credits_lines(89)="Justin Knapich"
     credits_lines(90)="Andy Hood"
     credits_lines(92)="FX Artists"
     credits_lines(93)="David Hensley"
     credits_lines(94)="Martin Behrend"
     credits_lines(97)=" "
     credits_lines(98)="Sound Design"
     credits_lines(99)="Andreas Almström - Lead Sound Artist "
     credits_lines(100)="Jens Nilsson"
     credits_lines(102)="Music"
     credits_lines(103)="Matthew Burns "
     credits_lines(105)="Voice Acting"
     credits_lines(106)="Michael Kammerhofer"
     credits_lines(107)="Alexander Mugrauer"
     credits_lines(108)="Dimitri Kondelchuk"
     credits_lines(109)="Evgeny Novikov"
     credits_lines(110)="Micha Safonov"
     credits_lines(111)="Evgenij Safonov"
     credits_lines(113)="Legal"
     credits_lines(114)="Tom Buscaglia - 'The Game Attorney'"
     credits_lines(116)="Historian and PR"
     credits_lines(117)="Alan Wilson"
     credits_lines(119)="PR Assistance"
     credits_lines(120)="Martin Brindley, MCC International"
     credits_lines(121)="Jared Creasy"
     credits_lines(122)="Gemma Rees, MCC International"
     credits_lines(124)="Research Materials and Sources"
     credits_lines(125)="Alexei Michailovich Vassilevsky - Russian State Library and Archives"
     credits_lines(126)="David Michael Honner - 'Guns vs Armor'"
     credits_lines(127)="Mike Kendall - 'AFV Interiors' magazine"
     credits_lines(129)="The Archive and Reference Library at the Tank Museum, Bovington:"
     credits_lines(130)="David Fletcher"
     credits_lines(131)="Janice Tait"
     credits_lines(133)="The Tank Museum, Bovington"
     credits_lines(135)="Föreningen P5 ['The P5 Association' of Sweden]"
     credits_lines(137)="Research"
     credits_lines(138)="Alan Wilson"
     credits_lines(139)="Ingmar Spit"
     credits_lines(141)="IT Director"
     credits_lines(142)="Christian Schneider"
     credits_lines(144)="Lead Tester"
     credits_lines(145)="Jay Mattingly"
     credits_lines(148)=" "
     credits_lines(149)="Testers"
     credits_lines(150)="Angus Meudell"
     credits_lines(151)="Anthony Easton"
     credits_lines(152)="Anthony Wysoskey"
     credits_lines(153)="Archie Young"
     credits_lines(154)="Ben Hewitt"
     credits_lines(155)="Bill Evans"
     credits_lines(156)="Björn Svedberg"
     credits_lines(157)="Chris Hill"
     credits_lines(158)="Chris van Raadshooven"
     credits_lines(159)="Daniel Levin"
     credits_lines(160)="Eric Chambers"
     credits_lines(161)="Gregory Ecker"
     credits_lines(162)="Jeremy Walker "
     credits_lines(163)="Julien Maurel"
     credits_lines(164)="Justin Coquillon"
     credits_lines(165)="Kenny A.J Campbell"
     credits_lines(166)="Larry Shaw"
     credits_lines(167)="Luke Coco"
     credits_lines(168)="Mark Jansen"
     credits_lines(169)="Mark Rossmore"
     credits_lines(170)="Matt Henry"
     credits_lines(171)="Michael Levin"
     credits_lines(172)="Mikkel Sigismund"
     credits_lines(173)="Paul Styrczula"
     credits_lines(174)="Randy Buccafusca"
     credits_lines(175)="Scott Campbell"
     credits_lines(176)="Steven Weller"
     credits_lines(177)="Todd Fuchs"
     credits_lines(178)="Trevor Moore"
     credits_lines(179)="Wyatt Moadus"
     credits_lines(181)="With"
     credits_lines(182)="Chris Moore"
     credits_lines(183)="Chris Murray"
     credits_lines(184)="Daniel Moadus"
     credits_lines(185)="Megan Bacchus"
     credits_lines(186)="Paul Jolley"
     credits_lines(187)="Peter Paul Nijenhuis"
     credits_lines(188)="Ryan Plas"
     credits_lines(189)="Tiana Bragg"
     credits_lines(193)=" "
     credits_lines(194)="Special Thanks"
     credits_lines(195)="William Munk I"
     credits_lines(196)="Paulette Munsell"
     credits_lines(197)="Jim Munsell"
     credits_lines(198)="Jessica Gibson"
     credits_lines(199)="Astrid Spit-Steur"
     credits_lines(200)="Moira Wilson"
     credits_lines(201)="Tom O'Kelly"
     credits_lines(202)="Nick Sales"
     credits_lines(203)="Evyn Shuley"
     credits_lines(204)="Jared Creasy"
     credits_lines(205)="Jay Mattingly "
     credits_lines(206)="Justin Coquillon "
     credits_lines(207)="Tobbe Åhlen"
     credits_lines(208)="Julie Miller"
     credits_lines(209)="Christopher Phillips"
     credits_lines(210)="Juliegh DeCarlo"
     credits_lines(211)="Mayang's Free Textures"
     credits_lines(212)="Detonation Films"
     credits_lines(213)="Col David M Glantz"
     credits_lines(214)="George Nipe Jr"
     credits_lines(215)="Dan Nyberg"
     credits_lines(216)="Katarina Nilsson"
     credits_lines(217)="The Swedish Armed Forces"
     credits_lines(218)="James Fitzpatrick"
     credits_lines(219)="Ryan Johnquest"
     credits_lines(221)="And a special thanks also goes to all the family and friends who have helped us out. Without their support, encouragement and understanding either Red Orchestra would never have been built, or there would be a few of us divorced!"
     credits_lines(224)=" "
     credits_lines(225)="For Valve"
     credits_lines(227)="And a huge thanks to everyone at Valve who helped us. There are more individuals at Valve who worked on the Steam integration and the PR than even we know, so we won't list them all. Without Valve's vision in setting up Steam - and signing Red Orchestra - this game might well be a very different proposition."
     credits_lines(229)="Our heartfelt thanks from all at Tripwire Interactive."
     credits_lines(232)="For Epic, Nvidia, Atari and the sponsors of the MSU"
     credits_lines(234)="Just as with Valve, we can't pass by without thanking all those who made the MSU contest a possibility. This includes Nvidia, as the 'named' sponsor, plus all those who supported the contest. Of course, Epic deserve thanks both as sponsors and for their assistance following on from the contest - as well as for producing the Unreal Engine that has made all this possible. We also owe Nvidia a debt of gratitude for their assistance at GDC and E3 during 2005. Once again - thanks from all at Tripwire Interactive."
     credits_lines(237)=" "
     credits_lines(238)="For Destineer"
     credits_lines(241)="CEO: Paul Rinde"
     credits_lines(242)="President: Peter Tamte"
     credits_lines(244)="Vice President of Sales: Scott Addyman"
     credits_lines(245)="Director, Licensing & Acquisitions & Senior Producer: Roger Arias"
     credits_lines(246)="Director of Operations: Al Schilling"
     credits_lines(247)="Marketing Manager: Cindy Swanson"
     credits_lines(248)="Public Relations: Steve Charbonneau"
     credits_lines(249)="Graphic Design: David Stengel"
     credits_lines(250)="Jack Wilcox"
     credits_lines(251)="Terry Stoeger"
     credits_lines(252)="Quality Assurance: Jim Wroblewski"
     credits_lines(253)="Greg Stutsman"
     credits_lines(254)="Paul Murphy"
     credits_lines(255)="James Robrahn"
     credits_lines(256)="Bob Strenger"
     credits_lines(258)="Technical Support Manager: Greg Grimes"
     credits_lines(260)="Aphabetas.com and the Marsoc Testers:"
     credits_lines(262)="Mike 'HiSpeed' Speelman "
     credits_lines(263)="Devin 'Theopolis' Kass"
     credits_lines(264)="Jason 'Jay' Clark"
     credits_lines(265)="Mark 'Johnnie Flash' Kupfer"
     credits_lines(266)="Milo 'Neko' Grika"
     credits_lines(267)="Erick 'AlphaBetasRocks!' Frich"
     credits_lines(268)="Dwight 'AlphaBetas.com' Ludvigson"
     credits_lines(269)="Mike 'YellowLesPaul' Torok"
     credits_lines(270)="Bill 'Ghost' Holmberg"
     credits_lines(271)="Mitchell 'Knuckles' Holmberg"
     credits_lines(272)="Nick 'Rowan' Holmberg"
     credits_lines(273)="Joseph 'Fish' Lang"
     credits_lines(274)="Roy 'KillZone' McLaughlin"
     credits_lines(275)="Doug 'Greywolf' Hickerson"
     credits_lines(276)="Paul 'Tulf' Aguilar"
     credits_lines(277)="Leon 'Rico' Materic"
     credits_lines(278)="Jerry 'Buzz' Forsha"
     credits_lines(279)="Dave 'Dave' Roth"
     credits_lines(280)="Andy 'Col. Kurtz' Binks"
     credits_lines(281)="Steven 'Nutter' Binks"
     credits_lines(282)="David 'David' Chea"
     credits_lines(283)="Luis 'Cpl. Candy' Baretto"
     credits_lines(284)="Manuel 'Rage' Rottele"
     credits_lines(285)="Thomas 'Gearson' Marschall"
     credits_lines(286)="Lloyd 'Killspree' Wood"
     credits_lines(287)="Bill 'Popeye' Shauf"
     credits_lines(288)="Will 'Will42' Smallwood"
     credits_lines(289)="Alfredo 'Guacachile' Narvaez"
     credits_lines(290)="Joseph 'Rickster' Johnson"
     credits_lines(291)="Michael 'Beechnut' Russell"
     credits_lines(292)="Joe 'Raiste' Stevens"
     credits_lines(295)="And finally..."
     credits_lines(297)="There is one other group of people that deserve recognition for all this. That is the large group of people who contributed to the creation of the original Red Orchestra mod. Many of those have gone on to their own jobs in the games industry or are still involved in leading positions in the modding scene. Others have simply dropped out of the whole scene. While we may have lost track of some over the last couple of years, to borrow a famous phrase from Russian: 'no-one is forgotten; nothing is forgotten'. Here we'll list all those not mentioned elsewhere, as our way of wishing everyone the very best of luck - and the hope that you'll go on using those skills!"
     credits_lines(299)="Adam Hatch"
     credits_lines(300)="Albert van Rennes"
     credits_lines(301)="Ankalar"
     credits_lines(302)="Bobby Stein"
     credits_lines(303)="Chad Barnsdale"
     credits_lines(304)="Dan Grafstrom"
     credits_lines(305)="Dana Rink"
     credits_lines(306)="Dicer"
     credits_lines(307)="Erik Christensen"
     credits_lines(308)="Howard Cheung"
     credits_lines(309)="Jason Mohr"
     credits_lines(310)="Jay Nakai"
     credits_lines(311)="Jeremy Blum"
     credits_lines(312)="Justin Lee"
     credits_lines(313)="LimiT"
     credits_lines(314)="Matt Hallock"
     credits_lines(315)="Matthew Stock"
     credits_lines(316)="Phobos"
     credits_lines(317)="Richard Jessup"
     credits_lines(318)="Ripa"
     credits_lines(319)="Ronald Chow"
     credits_lines(320)="Steven"
     credits_lines(321)="The-Jackal"
     credits_lines(322)="Tim Crowley"
     credits_lines(323)="Tntsnipe"
     credits_lines(324)="TommyD"
     credits_lines(325)="Zach Shertz"
     credits_lines(327)=" "
     credits_lines(328)="Additional Sounds"
     credits_lines(329)="The Freesound Project"
     WindowName="Credits"
     bRequire640x480=False
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.800000
}
