//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFConsole extends ExtendedConsole;

var enum EKFSpeechMenuState
{
	KFSMS_Main,
	KFSMS_Support,
	KFSMS_Ack,
	KFSMS_Alerts,
	KFSMS_Directions,
	KFSMS_Insults,
} KFSMState, PreviousStateName;

var array<PlayerReplicationInfo> PRIs;	  // List of squad leaders on the player's team, cleared when speech menu is closed

var int savedSelectedObjective;

state SpeechMenuVisible
{
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		return false;
	}

	function class<KFVoicePack> GetKFVoiceClass()
	{
		local KFPlayerReplicationInfo rop;

		if ( ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.PlayerReplicationInfo == none )
		{
			return none;
		}

		rop = KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		return class<KFVoicePack>(rop.VoiceType);
	}

	//--------------------------------------------------------------------------
	// build voice command array.
	//--------------------------------------------------------------------------
	// Rebuild the array of options based on the state we are now in.
	function RebuildSMArray()
	{
		switch(KFSMState)
		{
			case KFSMS_Main:
				buildSMMainArray();
				break;

			case KFSMS_Support:
				buildSMSupportArray();
				break;

			case KFSMS_Ack:
				buildSMAcknowledgmentArray();
				break;

			case KFSMS_Alerts:
				buildSMAlertsArray();
				break;

			case KFSMS_Directions:
				buildSMDirectionsArray();
				break;

			case KFSMS_Insults:
				buildSMInsultsArray();
				break;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Main(Just Categories)
	//--------------------------------------------------------------------------
	function buildSMMainArray()
	{
		local int i;
		local KFPlayerReplicationInfo KFRepInfo;

		SMOffset = 0;
		SMArraySize = 0;

		KFRepInfo = KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		for (i = 1; i < 6; i++)
		{
			SMNameArray[SMArraySize] = SMStateName[i];
			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Support
	//--------------------------------------------------------------------------
	function buildSMSupportArray()
	{
		local int i;
		local class<KFVoicePack> KFVP;
		local KFGameReplicationInfo KFGameRep;
		local KFPlayerReplicationInfo KFPlayerRep;

		KFGameRep = KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		KFPlayerRep =  KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = KFSMS_Main;

		KFVP = GetKFVoiceClass();
		if(KFVP == None)
		{
			return;
		}

		for ( i = 0; i < KFVP.Default.NumSupports; i++ )
		{
			if ( KFVP.Default.SupportAbbrev[i] != "" )
			{
				SMNameArray[SMArraySize] = KFVP.Default.SupportAbbrev[i];
			}
			else
			{
				SMNameArray[SMArraySize] = KFVP.Default.SupportString[i];
			}

			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Acknowledgments
	//--------------------------------------------------------------------------
	function buildSMAcknowledgmentArray()
	{
		local int i;
		local class<KFVoicePack> KFVP;
		local KFGameReplicationInfo KFGameRep;
		local KFPlayerReplicationInfo KFPlayerRep;

		KFGameRep = KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		KFPlayerRep =  KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = KFSMS_Main;

		KFVP = GetKFVoiceClass();
		if(KFVP == None)
		{
			return;
		}

		for ( i = 0; i < KFVP.Default.NumAcknowledgments; i++ )
		{
			if ( KFVP.Default.AcknowledgmentAbbrev[i] != "" )
			{
				SMNameArray[SMArraySize] = KFVP.Default.AcknowledgmentAbbrev[i];
			}
			else
			{
				SMNameArray[SMArraySize] = KFVP.Default.AcknowledgmentString[i];
			}

			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Alerts
	//--------------------------------------------------------------------------
	function buildSMAlertsArray()
	{
		local int i;
		local class<KFVoicePack> KFVP;
		local KFGameReplicationInfo KFGameRep;
		local KFPlayerReplicationInfo KFPlayerRep;

		KFGameRep = KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		KFPlayerRep =  KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = KFSMS_Main;

		KFVP = GetKFVoiceClass();
		if(KFVP == None)
		{
			return;
		}

		for ( i = 0; i < KFVP.Default.NumAlerts; i++ )
		{
			if ( KFVP.Default.AlertAbbrev[i] != "" )
			{
				SMNameArray[SMArraySize] = KFVP.Default.AlertAbbrev[i];
			}
			else
			{
				SMNameArray[SMArraySize] = KFVP.Default.AlertString[i];
			}

			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Directions
	//--------------------------------------------------------------------------
	function buildSMDirectionsArray()
	{
		local int i;
		local class<KFVoicePack> KFVP;
		local KFGameReplicationInfo KFGameRep;
		local KFPlayerReplicationInfo KFPlayerRep;

		KFGameRep = KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		KFPlayerRep =  KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = KFSMS_Main;

		KFVP = GetKFVoiceClass();
		if(KFVP == None)
		{
			return;
		}

		for ( i = 0; i < KFVP.Default.NumDirections; i++ )
		{
			if ( KFVP.Default.DirectionAbbrev[i] != "" )
			{
				SMNameArray[SMArraySize] = KFVP.Default.DirectionAbbrev[i];
			}
			else
			{
				SMNameArray[SMArraySize] = KFVP.Default.DirectionString[i];
			}

			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	//--------------------------------------------------------------------------
	// Build voice command array for Insults
	//--------------------------------------------------------------------------
	function buildSMInsultsArray()
	{
		local int i;
		local class<KFVoicePack> KFVP;
		local KFGameReplicationInfo KFGameRep;
		local KFPlayerReplicationInfo KFPlayerRep;

		KFGameRep = KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		KFPlayerRep =  KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = KFSMS_Main;

		KFVP = GetKFVoiceClass();
		if(KFVP == None)
		{
			return;
		}

		for ( i = 0; i < KFVP.Default.NumInsults; i++ )
		{
			if ( KFVP.Default.InsultAbbrev[i] != "" )
			{
				SMNameArray[SMArraySize] = KFVP.Default.InsultAbbrev[i];
			}
			else
			{
				SMNameArray[SMArraySize] = KFVP.Default.InsultString[i];
			}

			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
	}

	function EnterKFState(EKFSpeechMenuState newState, optional bool bNoSound)
	{
		KFSMState = newState;
		RebuildSMArray();

		if ( !bNoSound )
		{
			PlayConsoleSound(SMAcceptSound);
		}
	}

	function LeaveState() // Go up a level
	{
		PlayConsoleSound(SMDenySound);

		if ( KFSMState == KFSMS_Main )
		{
			GotoState('');
		}
		else
		{
			EnterKFState(PreviousStateName, true);
		}
	}

	function HandleInput(int keyIn)
	{
		local int SelectIndex;
		local KFPlayerReplicationInfo KFRepInfo;
		local bool inVehicle;

		//local UnrealPlayer up;
		// GO BACK - previous state (might back out of menu);
		if ( keyIn == -1 )
		{
			LeaveState();
			HighlightRow = 0;
			return;
		}

		// TOP LEVEL - we just enter a new state
		if ( KFSMState == KFSMS_Main )
		{
			KFRepInfo = KFPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

			if( ViewportOwner.Actor.Pawn != none && ((ViewportOwner.Actor.Pawn.IsA('KFVehicle')) ||(ViewportOwner.Actor.Pawn.IsA('KFVehicleWeaponPawn'))) )
				inVehicle = true;
			else
				inVehicle = false;

			switch(keyIn)
			{
				case 1:
					SMType = 'SUPPORT';
					EnterKFState(KFSMS_Support);
					break;

				case 2:
					SMType = 'ACK';
					EnterKFState(KFSMS_Ack);
					break;

				case 3:
					SMType = 'ALERT';
					EnterKFState(KFSMS_Alerts);
					break;

				case 4:
					SMType = 'DIRECTION';
					EnterKFState(KFSMS_Directions);
					break;

				case 5:
					SMType = 'INSULT';
					EnterKFState(KFSMS_Insults);
					break;
			}

			return;
		}

		// Next page on the same level
		if ( keyIn == 0 )
		{
			// Check there is a next page!
			if ( SMArraySize - SMOffset > 9 && SMArraySize != 10 )
			{
				SMOffset += 9;
				return;
			}

			keyIn = 10;
		}

		// Previous page on the same level
		if ( keyIn == -2 )
		{
			SMOffset = Max(SMOffset - 9, 0);
			return;
		}

		// Otherwise - we have selected something!
		SelectIndex = SMOffset + keyIn - 1;
		if ( SelectIndex < 0 || SelectIndex >= SMArraySize ) // discard - out of range selections.
		{
			return;
		}

		ViewportOwner.Actor.Speech(SMType, SMIndexArray[selectIndex], "");
		PlayConsoleSound(SMAcceptSound);
		GotoState('');
	}

	function string NumberToString(int num)
	{
		local EInputKey key;

		if ( num < 0 || num > 9 )
		{
			return "";
		}

		if(bSpeechMenuUseLetters)
		{
			key = LetterKeys[num];
		}
		else
		{
			key = NumberKeys[num];
		}

		return ViewportOwner.Actor.ConsoleCommand("LOCALIZEDKEYNAME" @ string(int(key)));
	}

	function DrawNumbers(canvas Canvas, int NumNums, bool IncZero, bool sizing, out float XMax, out float YMax)
	{
		local int i;
		local float XPos, YPos;
		local float XL, YL;

		XPos = Canvas.ClipX * (SMOriginX+SMMargin);
		YPos = Canvas.ClipY * (SMOriginY+SMMargin);
		Canvas.SetDrawColor(128,255,128,255);

		for ( i = 0; i < NumNums; i++ )
		{
			Canvas.SetPos(XPos, YPos);
			if ( !sizing )
			{
				Canvas.DrawText(NumberToString(i+1)$"-", false);
			}
			else
			{
				Canvas.TextSize(NumberToString(i+1)$"-", XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}

		if ( IncZero )
		{
			Canvas.SetPos(XPos, YPos);

			if ( !sizing )
			{
				Canvas.DrawText(NumberToString(0)$"-", false);
			}

			// Hackish
			if ( SMArraySize != 10 )
			{
				XPos += SMTab;
				Canvas.SetPos(XPos, YPos);

				if ( !sizing )
				{
					Canvas.DrawText(SMMoreString, false);
				}
				else
				{
					Canvas.TextSize(SMMoreString, XL, YL);
					XMax = Max(XMax, XPos + XL);
					YMax = Max(YMax, YPos + YL);
				}
			}
		}
	}

	function DrawCurrentArray( canvas Canvas, bool sizing, out float XMax, out float YMax )
	{
		local int i, stopAt;
		local float XPos, YPos;
		local float XL, YL;

		XPos = (Canvas.ClipX * (SMOriginX+SMMargin)) + SMTab;
		YPos = Canvas.ClipY * (SMOriginY+SMMargin);
		Canvas.SetDrawColor(255,255,255,255);

		if ( SMArraySize == 10 )
		{
			stopAt = Min(SMOffset+10, SMArraySize);
		}
		else
		{
			stopAt = Min(SMOffset+9, SMArraySize);
		}

		for ( i = SMOffset; i < stopAt; i++ )
		{
			Canvas.SetPos(XPos, YPos);

			if ( !sizing )
			{
				Canvas.DrawText(SMNameArray[i], false);
			}
			else
			{
				Canvas.TextSize(SMNameArray[i], XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}
	}

	function int KeyToNumber(EInputKey InKey)
	{
		local int i;

		for ( i = 0; i < 10; i++ )
		{
			if ( bSpeechMenuUseLetters )
			{
				if ( InKey == LetterKeys[i] )
				{
					return i;
				}
			}
			else
			{
				if ( InKey == NumberKeys[i] )
				{
					return i;
				}
			}
		}

		return -1;
	}

	function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta)
	{
		local int input, NumNums;

		NumNums = Min(SMArraySize - SMOffset, 10);

		// while speech menu is up, dont let user use console. Debateable.
		//if( KeyIsBoundTo( Key, "ConsoleToggle" ) )
		//	return true;
		//if( KeyIsBoundTo( Key, "Type" ) )
		//	return true;

		if ( Action == IST_Press )
		{
			bIgnoreKeys = false;
		}

		if ( Action != IST_Press )
		{
			return false;
		}

		if ( Key == IK_Escape )
		{
			HandleInput(-1);
			return true;
		}

		// If 'letters' mode is on, convert input
		input = KeyToNumber(Key);
		if ( input != -1 )
		{
			HandleInput(input);
			return true;
		}

		// Keys below are only used if bSpeechMenuUseMouseWheel is true
		if ( !bSpeechMenuUseMouseWheel )
		{
			return false;
		}

		if ( Key == IK_MouseWheelUp )
		{
			// If moving up on the top row, and there is a previous page
			if ( HighlightRow == 0 && SMOffset > 0 )
			{
				HandleInput(-2);
				HighlightRow = 9;
			}
			else
			{
				HighlightRow = Max(HighlightRow - 1, 0);
			}

			return true;
		}
		else if ( Key == IK_MouseWheelDown )
		{
			// If moving down on the bottom row (the 'MORE' row), act as if we hit it, and move highlight to top.
			if ( HighlightRow == 9 && SMArraySize != 10 )
			{
				HandleInput(0);
				HighlightRow = 0;
			}
			else
			{
				HighlightRow = Min(HighlightRow + 1, NumNums - 1);
			}

			return true;
		}
		else if ( Key == IK_MiddleMouse )
		{
			input = HighlightRow + 1;
			if ( input == 10 )
			{
				input = 0;
			}

			HandleInput(input);
			HighlightRow = 0;

			return true;
		}

		return false;
	}

	function Font MyGetSmallFontFor(canvas Canvas)
	{
		local int i;

		for ( i = 1; i < 8; i++ )
		{
			if ( class'HudBase'.default.FontScreenWidthSmall[i] <= Canvas.ClipX )
			{
				return class'HudBase'.static.LoadFontStatic(i-1);
			}
		}

		return class'HudBase'.static.LoadFontStatic(7);
	}

	function PostRender(canvas Canvas)
	{
		local float XL, YL;
		local int SelLeft, i;
		local float XMax, YMax;

		Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.

		// Figure out max key name size
		XMax = 0;
		YMax = 0;
		for ( i = 0; i < 10; i++ )
		{
			Canvas.TextSize(NumberToString(i)$"- ", XL, YL);
			XMax = Max(XMax, XL);
			YMax = Max(YMax, YL);
		}

		SMLineSpace = YMax * 1.1;
		SMTab = XMax;

		SelLeft = SMArraySize - SMOffset;

		// First we figure out how big the bounding box needs to be
		XMax = 0;
		YMax = 0;
		DrawNumbers(canvas, Min(SelLeft, 9), SelLeft > 9, true, XMax, YMax);
		DrawCurrentArray(canvas, true, XMax, YMax);
		Canvas.TextSize(SMStateName[KFSMState], XL, YL);
		XMax = Max(XMax, Canvas.ClipX * (SMOriginX + SMMargin) + XL);
		YMax = Max(YMax, (Canvas.ClipY * SMOriginY) - (1.2 * SMLineSpace) + YL);
		// XMax, YMax now contain to maximum bottom-right corner we drew to.

		// Then draw the box
		XMax -= Canvas.ClipX * SMOriginX;
		YMax -= Canvas.ClipY * SMOriginY;
		Canvas.SetDrawColor(139,28,28,255);
		Canvas.SetPos(Canvas.ClipX * SMOriginX, Canvas.ClipY * SMOriginY);
		Canvas.DrawTileStretched(Texture'KF_InterfaceArt_tex.Menu.thin_border_SlightTransparent', XMax + (SMMargin*Canvas.ClipX), YMax + (SMMargin*Canvas.ClipY));

		// Draw highlight
		if ( bSpeechMenuUseMouseWheel )
		{
			Canvas.SetDrawColor(255,202,180,128);
			Canvas.SetPos( Canvas.ClipX*SMOriginX, Canvas.ClipY*(SMOriginY+SMMargin) + ((HighlightRow - 0.1)*SMLineSpace) );
			Canvas.DrawTileStretched(Texture'KF_InterfaceArt_tex.Menu.thin_border_SlightTransparent', XMax + (SMMargin*Canvas.ClipX), 1.1*SMLineSpace );
		}

		// Then actually draw the stuff
		DrawNumbers( canvas, Min(SelLeft, 9), SelLeft > 9, false, XMax, YMax);
		DrawCurrentArray( canvas, false, XMax, YMax);

		// Finally, draw a nice title bar.
		Canvas.SetDrawColor(139,28,28,255);
		Canvas.SetPos(Canvas.ClipX*SMOriginX, (Canvas.ClipY*SMOriginY) - (1.5*SMLineSpace));
		Canvas.DrawTileStretched(Texture'KF_InterfaceArt_tex.Menu.thin_border_SlightTransparent', XMax + (SMMargin*Canvas.ClipX), (1.5*SMLineSpace));

		Canvas.SetDrawColor(255,255,128,255);
		Canvas.SetPos(Canvas.ClipX*(SMOriginX+SMMargin), (Canvas.ClipY*SMOriginY) - (1.2*SMLineSpace));

		Canvas.DrawText(SMStateName[KFSMState]);
	}

	function BeginState()
	{
		bVisible = true;
		bIgnoreKeys = true;
		bCtrl = false;
		HighlightRow = 0;

		EnterKFState(KFSMS_Main, true);
		SMCallsign = "";

		PlayConsoleSound(SMOpenSound);
	}

	function EndState()
	{
		bVisible = false;
		bCtrl = false;

		PRIs.Length = 0;
	}

	// Close speech menu on level change
	event NotifyLevelChange()
	{
		Global.NotifyLevelChange();
		GotoState('');
	}
}

defaultproperties
{
     SMStateName(1)="Support"
     SMStateName(3)="Alerts"
     SMStateName(4)="Directions"
     SMStateName(5)="Insults"
     ServerInfoMenu="KFInterface.KFGUIServerInfo"
}
