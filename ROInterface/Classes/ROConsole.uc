//------------------------------------------------------------------------------
// $Id: ROConsole.uc,v 1.5 2004/02/10 05:14:48 bwright Exp $
// @description : Added support for RO voice command system.
// This implementation allows players with leader role to have access
// to an orders voice menu, other do not.
//------------------------------------------------------------------------------

class ROConsole extends ExtendedConsole;

var enum EROSpeechMenuState
{
    ROSMS_Main,
	ROSMS_Support,
	ROSMS_Ack,
	ROSMS_Enemy,
	ROSMS_Alert,
	ROSMS_Vehicle_Orders,
	ROSMS_Vehicle_Alerts,
	ROSMS_Commanders,
	ROSMS_Extras,

	// Sub menus
	ROSMS_Attack,
	ROSMS_Defend,
	ROSMS_Vehicle_Goto,
	ROSMS_HelpAt,
	ROSMS_UnderAttackAt,
	ROSMS_SelectSquad
} ROSMState, PreviousStateName;

var localized string    AllPlayersSquad, OwnSquad, SquadSuffix;
var array<PlayerReplicationInfo> PRIs;      // List of squad leaders on the player's team, cleared when speech menu is closed

var int savedSelectedObjective;


state SpeechMenuVisible
{
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		return false;
	}

	function class<ROVoicePack> GetROVoiceClass()
	{
	    local ROPlayerReplicationInfo rop;
		if(ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.PlayerReplicationInfo == None)
			return None;
        rop = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);
		return class<ROVoicePack>(rop.VoiceType);
	}
    //--------------------------------------------------------------------------
    // build voice command array.
    //--------------------------------------------------------------------------
	// Rebuild the array of options based on the state we are now in.
	function RebuildSMArray()
	{
        switch(ROSMState)
        {
          case ROSMS_Main           : buildSMMainArray(); break;
          case ROSMS_Support        : buildSMSupportArray(); break;
          case ROSMS_Ack            : buildAckArray(); break;
          case ROSMS_Enemy          : buildSMEnemyArray(); break;
          case ROSMS_Alert          : buildSMAlertArray(); break;
          case ROSMS_Vehicle_Orders : buildSMVehicleDirectionArray(); break;
          case ROSMS_Vehicle_Alerts : buildSMVehicleAlertArray(); break;
          case ROSMS_Commanders     : buildSMOrderArray(); break;
          case ROSMS_Extras         : buildSMExtraArray(); break;

          // Submenus
          case ROSMS_Attack         : buildSMAttackArray(); break;
          case ROSMS_Defend         : buildSMDefendArray(); break;
          case ROSMS_Vehicle_Goto   : buildSMGotoArray(); break;
          case ROSMS_HelpAt         : buildSMHelpAtArray(); break;
          case ROSMS_UnderAttackAt  : buildSMUnderAttackAtArray(); break;
          case ROSMS_SelectSquad    : buildSMSelectSquadArray(); break;
        }
	}

	function buildSMSupportArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;
        local ROGameReplicationInfo ROGameRep;
        local ROPlayerReplicationInfo ROPlayerRep;

        ROGameRep = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
        ROPlayerRep =  ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numSupports; i++)
        {
            switch(ROPlayerRep.RoleInfo.Side)
            {
                case SIDE_Allies:
                    if (ROvp.Default.SupportAbbrev[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.SupportAbbrev[i];
                    else
        	            SMNameArray[SMArraySize] = ROvp.Default.SupportString[i];
       	            break;

   	            case SIDE_Axis:
                    if (ROvp.Default.SupportAbbrevAxis[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.SupportAbbrevAxis[i];
                    else if (ROvp.Default.SupportAbbrev[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.SupportAbbrev[i];
                    else if (ROvp.Default.SupportStringAxis[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.SupportStringAxis[i];
                    else
                        SMNameArray[SMArraySize] = ROvp.Default.SupportString[i];
       	            break;
            }

           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }

    function buildSMEnemyArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;
        local ROGameReplicationInfo ROGameRep;
        local ROPlayerReplicationInfo ROPlayerRep;

        ROGameRep = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
        ROPlayerRep =  ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numEnemies; i++)
        {
            switch(ROPlayerRep.RoleInfo.Side)
            {
                case SIDE_Allies:
                    if (ROvp.Default.EnemyAbbrev[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.EnemyAbbrev[i];
                    else
        	            SMNameArray[SMArraySize] = ROvp.Default.EnemyString[i];
       	            break;

   	            case SIDE_Axis:
                    if (ROvp.Default.EnemyAbbrevAxis[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.EnemyAbbrevAxis[i];
                    else if (ROvp.Default.EnemyAbbrev[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.EnemyAbbrev[i];
                    else if (ROvp.Default.EnemyStringAxis[i] != "")
                        SMNameArray[SMArraySize] = ROvp.Default.EnemyStringAxis[i];
                    else
                        SMNameArray[SMArraySize] = ROvp.Default.EnemyString[i];
       	            break;
            }

           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }


    //--------------------------------------------------------------------------
    // build voice command array for attack voices
    //--------------------------------------------------------------------------
    function buildSMAttackArray()
    { //query all objectives that can be attacked
       local ROGameReplicationInfo ROGameRep;
       local ROPlayerReplicationInfo ROPlayerRep;
       local int i;

       ROGameRep = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
       ROPlayerRep =  ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);
       SMArraySize = 0;
	   PreviousStateName = ROSMS_Commanders;

       //TODO: find out if the number of objectives can be hardcoded (16)
       for(i=0; i< 16; i++)
		{
		    if(ROGameRep.Objectives[i] != none)
		    {
                switch(ROPlayerRep.RoleInfo.Side)
                {
                   case SIDE_Axis:
                       if((ROGameRep.Objectives[i].ObjState == OBJ_Allies ||
                           ROGameRep.Objectives[i].ObjState == OBJ_Neutral) &&
                           ROGameRep.Objectives[i].bActive)
                       {
                          SMNameArray[SMArraySize] = ROGameRep.Objectives[i].ObjName;
                          SMIndexArray[SMArraySize] = ROGameRep.Objectives[i].ObjNum;
                          SMArraySize++;
                       }
                       break;

                   case SIDE_Allies:
                       if((ROGameRep.Objectives[i].ObjState == OBJ_Axis ||
                           ROGameRep.Objectives[i].ObjState == OBJ_Neutral) &&
                           ROGameRep.Objectives[i].bActive)
                       {
                          SMNameArray[SMArraySize] = ROGameRep.Objectives[i].ObjName;
                          SMIndexArray[SMArraySize] = ROGameRep.Objectives[i].ObjNum;
                          SMArraySize++;
                       }

                       break;
                }
			}
		}
    }

    //--------------------------------------------------------------------------
    // build voice command array for defend voices
    //--------------------------------------------------------------------------
    function buildSMDefendArray()
    {
       local ROGameReplicationInfo ROGameRep;
       local ROPlayerReplicationInfo ROPlayerRep;
       local int i;
       ROGameRep = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
       ROPlayerRep =  ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);
       SMArraySize = 0;
	   PreviousStateName = ROSMS_Commanders;

       //TODO: find out if the number of objectives can be hardcoded (16)
       for(i=0; i< 16; i++)
       {
		    if(ROGameRep.Objectives[i] != none)
		    {
                switch(ROPlayerRep.RoleInfo.Side)
                {
                   case SIDE_Axis:
                       if(ROGameRep.Objectives[i].ObjState == OBJ_Axis )
                       {
                          SMNameArray[SMArraySize] = ROGameRep.Objectives[i].ObjName;
                          SMIndexArray[SMArraySize] = ROGameRep.Objectives[i].ObjNum;
                          SMArraySize++;
                       }
                       break;

                   case SIDE_Allies:
                       if(ROGameRep.Objectives[i].ObjState == OBJ_Allies )
                       {
                          SMNameArray[SMArraySize] = ROGameRep.Objectives[i].ObjName;
                          SMIndexArray[SMArraySize] = ROGameRep.Objectives[i].ObjNum;
                          SMArraySize++;
                       }

                       break;
                }
			}
		}

    }

    function buildSMGotoArray()
    {
       local ROGameReplicationInfo ROGameRep;
       local int i;
       ROGameRep = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
       SMArraySize = 0;
       PreviousStateName = ROSMS_Vehicle_Orders;

       //TODO: find out if the number of objectives can be hardcoded (16)
       for(i=0; i< 16; i++)
       {
		    if(ROGameRep.Objectives[i] != none)
		    {
                SMNameArray[SMArraySize] = ROGameRep.Objectives[i].ObjName;
                SMIndexArray[SMArraySize] = ROGameRep.Objectives[i].ObjNum;
                SMArraySize++;
			}
		}
    }

    function buildSMHelpAtArray()
    {
       buildSMGotoArray();
       PreviousStateName = ROSMS_Support;
    }

    function buildSMUnderAttackAtArray()
    {
       buildSMGotoArray();
       PreviousStateName = ROSMS_Alert;
    }

    //--------------------------------------------------------------------------
    // build voice command array for main voices
    //--------------------------------------------------------------------------
    function buildSMMainArray()
    {
        local int i;
        local bool bSkipCurrent;
		local ROPlayerReplicationInfo RORepInfo;

		SMOffset=0;
        SMArraySize = 0;

        RORepInfo = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

        for (i = 1; i < 9; i++)
        {
            bSkipCurrent = false;

            // Only show vehicle commands if we're in a vehicle
            if (i == 5 || i == 6)
            {
                if ( ViewportOwner.Actor.Pawn == none || (!(ViewportOwner.Actor.Pawn.IsA('ROVehicle')) && !(ViewportOwner.Actor.Pawn.IsA('ROVehicleWeaponPawn'))) )
                    bSkipCurrent = true;
            }

            // Only show orders menu if we're a commander or if this is a practice session
            if (i == 7)
            {
                if ( !((RORepInfo != none && RORepInfo.RoleInfo.bIsLeader) || ViewportOwner.Actor.Level.NetMode == NM_Standalone) )
                    bSkipCurrent = true;
            }

            if (!bSkipCurrent)
            {
                SMNameArray[SMArraySize] = SMStateName[i];
			    SMIndexArray[SMArraySize] = i;
			    SMArraySize++;
            }
        }
    }

    //--------------------------------------------------------------------------
    // build voice command array for order voices
    //--------------------------------------------------------------------------
    function buildSMOrderArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		local ROPlayerReplicationInfo RORepInfo;

		SMArraySize = 0;
		SMOffset=0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        RORepInfo = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

	    if((RORepInfo != none && RORepInfo.RoleInfo.bIsLeader) || ViewportOwner.Actor.Level.NetMode == NM_Standalone)
	    {
			for(i=0; i< ROvp.Default.numCommands; i++)
			{
				if(ROvp.Default.OrderAbbrev[i] != "")
				   SMNameArray[SMArraySize] = ROvp.Default.OrderAbbrev[i];
				else
				   SMNameArray[SMArraySize] = ROvp.Default.OrderString[i];
				SMIndexArray[SMArraySize] = i;
				SMArraySize++;
			}
		}
    }

    //--------------------------------------------------------------------------
    // build voice command array for Acknoledge voices
    //--------------------------------------------------------------------------
    function buildAckArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numAcks; i++)
        {
           if (ROvp.Default.AckAbbrev[i] != "")
              SMNameArray[SMArraySize] = ROvp.Default.AckAbbrev[i];
           else
        	  SMNameArray[SMArraySize] = ROvp.Default.AckString[i];
           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }

    function buildSMExtraArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numExtras; i++)
        {
           if (ROvp.Default.ExtraAbbrev[i] != "")
              SMNameArray[SMArraySize] = ROvp.Default.ExtraAbbrev[i];
           else
        	  SMNameArray[SMArraySize] = ROvp.Default.ExtraString[i];
           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }

    function buildSMAlertArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numAlerts; i++)
        {
           if (ROvp.Default.AlertAbbrev[i] != "")
              SMNameArray[SMArraySize] = ROvp.Default.AlertAbbrev[i];
           else
        	  SMNameArray[SMArraySize] = ROvp.Default.AlertString[i];
           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }

    //--------------------------------------------------------------------------
    // build voice command array for shout voices
    //--------------------------------------------------------------------------
    /*function buildSMShoutArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

		for(i=0; i< ROvp.Default.numShouts; i++)
		{
		    SMNameArray[SMArraySize] = ROvp.Default.ShoutString[i];
			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}
    }*/
    //--------------------------------------------------------------------------
    // build voice command array for whisper voices
    //--------------------------------------------------------------------------

    /*function buildSMWhisperArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

        for(i=0; i< ROvp.Default.numWhispers; i++)
        {
           SMNameArray[SMArraySize] = ROvp.Default.WhisperString[i];
           SMIndexArray[SMArraySize] = i;
           SMArraySize++;
        }
    }*/

    //--------------------------------------------------------------------------
    // build voice command array for Vehicle voices -MrMethane new function 01/12/2005
    //--------------------------------------------------------------------------
    function buildSMVehicleDirectionArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

		for(i=0; i< ROvp.Default.numVehicleDirections; i++)
		{
		    SMNameArray[SMArraySize] = ROvp.Default.VehicleDirectionString[i];
			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}

    }

    function buildSMVehicleAlertArray()
    {
        local int i;
		local class<ROVoicePack> ROvp ;

		SMArraySize = 0;
		PreviousStateName = ROSMS_Main;

		ROvp = GetROVoiceClass();
		if(ROvp == None)
			return;

		for(i=0; i< ROvp.Default.numVehicleAlerts; i++)
		{
		    SMNameArray[SMArraySize] = ROvp.Default.VehicleAlertString[i];
			SMIndexArray[SMArraySize] = i;
			SMArraySize++;
		}

    }

    function buildSMSelectSquadArray()
    {
        local int i, j, team;
        local bool bAlreadyExists;
        local ROPlayerReplicationInfo PRI, B_PRI;
        local array<SquadAI> squads;
        local ROGameReplicationInfo GRI;

        SMArraySize = 0;
        squads.Length = 0;
        PRIs.Length = 0;

        // Add 'everyone' item
        SMNameArray[SMArraySize] = AllPlayersSquad;
		SMIndexArray[SMArraySize] = -1;
        SMArraySize++;

		// Get player's team #
	    PRI = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);
	    GRI = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
	    if (PRI == none || PRI.Team == none || GRI == none)
	        return;
	    team = PRI.Team.TeamIndex;


		// Iterate through bot list, finding out which squads are from this team and
		// adding the to the menu (if they wern't already)
		for (j = 0; j < GRI.PRIArray.length; j++)
		{
            B_PRI = ROPlayerReplicationInfo(GRI.PRIArray[j]);
            if (B_PRI != none && B_PRI.Squad != none)
            {
                if (B_PRI.Team != none && B_PRI.Squad.LeaderPRI != none)
                {
                    if (B_PRI.Team.TeamIndex == team)
                    {
                        // Check if this bot's squad already exists in the list
                        bAlreadyExists = false;
                        for (i = 0; i < squads.Length; i++)
                           if (B_PRI.Squad == squads[i])
                               bAlreadyExists = true;

                        if (!bAlreadyExists)
                        {
                            // Add squad to squad list
                            squads[squads.Length] = B_PRI.Squad;

                            // Save squad leader PRI
                            PRIs[PRIs.Length] = B_PRI.Squad.LeaderPRI;

                            // Add squad to menu
                            if (B_PRI.Squad.LeaderPRI == PRI)
                            {
                                // Here we do some switcheroo to place our own squad in position #2
                                SMNameArray[SMArraySize] = SMNameArray[1];
                                SMIndexArray[SMArraySize] = SMIndexArray[1];

                                SMNameArray[1] = OwnSquad;
                                SMIndexArray[1] = PRIs.Length - 1;
	                            SMArraySize++;
                            }
                            else
                            {
                                SMNameArray[SMArraySize] = B_PRI.Squad.LeaderPRI.PlayerName $ SquadSuffix;
	                            SMIndexArray[SMArraySize] = PRIs.Length - 1;
	                            SMArraySize++;
	                        }
                        }
                    }
                }
	        }
		}

		// Clear squads list
		squads.Length = 0;
    }

    //--------------------------------------------------------------------------
    //
    //--------------------------------------------------------------------------
	function EnterROState(EROSpeechMenuState newState, optional bool bNoSound)
	{
		ROSMState = newState;
		RebuildSMArray();
        //log("ROConsole::EnterROState = "$ROSMState);
		if(!bNoSound)
			PlayConsoleSound(SMAcceptSound);
	}
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
	function LeaveState() // Go up a level
	{
		PlayConsoleSound(SMDenySound);

		if(ROSMState == ROSMS_Main)
		{
			GotoState('');
		}
		else
			EnterROState(PreviousStateName, true);
	}

	function HandleInput(int keyIn)
	{
		local int selectIndex;
		local ROPlayerReplicationInfo RORepInfo;
		local bool inVehicle;

		//local UnrealPlayer up;
		// GO BACK - previous state (might back out of menu);
		if(keyIn == -1)
		{
			LeaveState();
			HighlightRow = 0;
			return;
		}

		// TOP LEVEL - we just enter a new state
		if(ROSMState == ROSMS_Main)
		{
		    RORepInfo = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);

            if( ViewportOwner.Actor.Pawn != none && ((ViewportOwner.Actor.Pawn.IsA('ROVehicle')) ||(ViewportOwner.Actor.Pawn.IsA('ROVehicleWeaponPawn'))) )
                inVehicle = true;
            else
                inVehicle = false;

            //only leaders are able to issue orders
		    if((RORepInfo != none && RORepInfo.RoleInfo.bIsLeader) || ViewportOwner.Actor.Level.NetMode == NM_Standalone)
		    {
    			 // don't show vehicle commands if not in vehicle
		       if(inVehicle)
		       {
                  switch(keyIn)
                  {
    			      case 1: SMType = 'SUPPORT'; EnterROState(ROSMS_Support); break;
    			      case 2: SMType = 'ACK'; EnterROState(ROSMS_Ack); break;
    			      case 3: SMType = 'ENEMY'; EnterROState(ROSMS_Enemy); break;
    			      case 4: SMType = 'ALERT'; EnterROState(ROSMS_Alert); break;
    			      case 5: SMType = 'VEH_ORDERS'; EnterROState(ROSMS_Vehicle_Orders); break;
    			      case 6: SMType = 'VEH_ALERTS'; EnterROState(ROSMS_Vehicle_Alerts); break;
    			      case 7: SMType = 'ORDER'; EnterROState(ROSMS_Commanders); break;
    			      case 8: SMType = 'TAUNT'; EnterROState(ROSMS_Extras); break;
                  }
               }
               else
		       {
                  switch(keyIn)
                  {
    			      case 1: SMType = 'SUPPORT'; EnterROState(ROSMS_Support); break;
    			      case 2: SMType = 'ACK'; EnterROState(ROSMS_Ack); break;
    			      case 3: SMType = 'ENEMY'; EnterROState(ROSMS_Enemy); break;
    			      case 4: SMType = 'ALERT'; EnterROState(ROSMS_Alert); break;
    			      case 5: SMType = 'ORDER'; EnterROState(ROSMS_Commanders); break;
    			      case 6: SMType = 'TAUNT'; EnterROState(ROSMS_Extras); break;
    			  }
               }
           	}
		    else
		    {
               //non-leaders, no orders

               if(inVehicle)
               {
		          switch(keyIn)
			      {
    			      case 1: SMType = 'SUPPORT'; EnterROState(ROSMS_Support); break;
    			      case 2: SMType = 'ACK'; EnterROState(ROSMS_Ack); break;
    			      case 3: SMType = 'ENEMY'; EnterROState(ROSMS_Enemy); break;
    			      case 4: SMType = 'ALERT'; EnterROState(ROSMS_Alert); break;
      			      case 5: SMType = 'VEH_ORDERS'; EnterROState(ROSMS_Vehicle_Orders); break;
    			      case 6: SMType = 'VEH_ALERTS'; EnterROState(ROSMS_Vehicle_Alerts); break;
    			      case 7: SMType = 'TAUNT'; EnterROState(ROSMS_Extras); break;
                  }
                }
    			else
    			{
    			   switch(keyIn)
    			   {
    			       case 1: SMType = 'SUPPORT'; EnterROState(ROSMS_Support); break;
    			       case 2: SMType = 'ACK'; EnterROState(ROSMS_Ack); break;
    			       case 3: SMType = 'ENEMY'; EnterROState(ROSMS_Enemy); break;
    			       case 4: SMType = 'ALERT'; EnterROState(ROSMS_Alert); break;
    			       case 5: SMType = 'TAUNT'; EnterROState(ROSMS_Extras); break;
  			       }
		       }
		    }

			return;
		}
		else if (ROSMState == ROSMS_Commanders)
		{
            switch(keyIn)
			{
    			case 1: SMType = 'ATTACK'; EnterROState(ROSMS_Attack);
                        //log("going to attack state");
                        return;
    			case 2: SMType = 'DEFEND'; EnterROState(ROSMS_Defend);
						return;
		    }
		    if(keyIn < 3) //send messages for other orders
		       return;
		}
		else if (ROSMState == ROSMS_Vehicle_Orders && keyIn == 1)
		{
		    SMType = 'VEH_GOTO'; EnterROState(ROSMS_Vehicle_Goto);
	        return;
		}
		else if (ROSMState == ROSMS_Support && keyIn == 2)
		{
		    SMType = 'HELPAT'; EnterROState(ROSMS_HelpAt);
	        return;
		}
		else if (ROSMState == ROSMS_Alert && keyIn == 9)
		{
		    SMType = 'UNDERATTACK'; EnterROState(ROSMS_UnderAttackAt);
	        return;
		}

		// Next page on the same level
		if(keyIn == 0 )
		{
			// Check there is a next page!
			if(SMArraySize - SMOffset > 9 && SMArraySize != 10)
			{
				SMOffset += 9;
            	return;
            }
            keyIn = 10;
		}

		// Previous page on the same level
		if(keyIn == -2)
		{
			SMOffset = Max(SMOffset - 9, 0);
			return;
		}

		// Otherwise - we have selected something!
		selectIndex = SMOffset + keyIn - 1;
		if(selectIndex < 0 || selectIndex >= SMArraySize) // discard - out of range selections.
			return;

		// Check if we need to open a new menu to select order target squad
		if (ROSMState == ROSMS_Attack || ROSMState == ROSMS_Defend ||
	        //ROSMState == ROSMS_Vehicle_Goto || ROSMState == ROSMS_HelpAt || ROSMState == ROSMS_UnderAttackAt ||
            ROSMState == ROSMS_Commanders)
		{
		    if (bCheckIfOwnerTeamHasBots())
		    {
    		    // Save selected objective
    		    savedSelectedObjective = SMIndexArray[selectIndex];

    		    // Generate menu with list of bots
    		    EnterROState(ROSMS_SelectSquad);
    		    return;
    		}
		}

        if (ROSMState == ROSMS_SelectSquad)
		{
		    // If this were the squad select menu, we want to have special code to
		    // handle speech generation (to select proper objective and target
		    // squad)
            if (SMIndexArray[selectIndex] != -1)
                ViewportOwner.Actor.xSpeech(SMType, savedSelectedObjective, PRIs[SMIndexArray[selectIndex]]);
            else
                ViewportOwner.Actor.xSpeech(SMType, savedSelectedObjective, none);
		}
		else
        	ViewportOwner.Actor.Speech(SMType, SMIndexArray[selectIndex], "");

        PlayConsoleSound(SMAcceptSound);
		GotoState('');
	}

	function bool bCheckIfOwnerTeamHasBots()
	{
	    local int team, i;
	    local ROPlayerReplicationInfo PRI;
	    local ROGameReplicationInfo GRI;

	    PRI = ROPlayerReplicationInfo(ViewportOwner.Actor.PlayerReplicationInfo);
	    GRI = ROGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
	    if (PRI == none || PRI.Team == none || GRI == none)
	        return false;

	    team = PRI.Team.TeamIndex;

	    for (i = 0; i < GRI.PRIArray.length; i++)
	    {
	        if (GRI.PRIArray[i] != none && GRI.PRIArray[i].bBot)
	            if (GRI.PRIArray[i].Team != none)
	               if (GRI.PRIArray[i].Team.TeamIndex == team)
	                   return true;
	    }

	    return false;
	}

	//////////////////////////////////////////////

	function string NumberToString(int num)
	{
		local EInputKey key;
		local string s;

		if(num < 0 || num > 9)
			return "";

		if(bSpeechMenuUseLetters)
			key = LetterKeys[num];
		else
			key = NumberKeys[num];

		s = ViewportOwner.Actor.ConsoleCommand( "LOCALIZEDKEYNAME"@string(int(key)) );
		return s;
	}

	function DrawNumbers( canvas Canvas, int NumNums, bool IncZero, bool sizing, out float XMax, out float YMax )
	{
		local int i;
		local float XPos, YPos;
		local float XL, YL;

		XPos = Canvas.ClipX * (SMOriginX+SMMargin);
		YPos = Canvas.ClipY * (SMOriginY+SMMargin);
		Canvas.SetDrawColor(128,255,128,255);

		for(i=0; i<NumNums; i++)
		{
			Canvas.SetPos(XPos, YPos);
			if(!sizing)
				Canvas.DrawText(NumberToString(i+1)$"-", false);
			else
			{
				Canvas.TextSize(NumberToString(i+1)$"-", XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}

		if(IncZero)
		{
			Canvas.SetPos(XPos, YPos);

			if(!sizing)
				Canvas.DrawText(NumberToString(0)$"-", false);

            // Hackish
            if (SMArraySize != 10)
            {
			    XPos += SMTab;
			    Canvas.SetPos(XPos, YPos);

			    if(!sizing)
				    Canvas.DrawText(SMMoreString, false);
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

        if (SMArraySize == 10)
            stopAt = Min(SMOffset+10, SMArraySize);
        else
		    stopAt = Min(SMOffset+9, SMArraySize);
		for(i=SMOffset; i<stopAt; i++)
		{
			Canvas.SetPos(XPos, YPos);
			if(!sizing)
				Canvas.DrawText(SMNameArray[i], false);
			else
			{
				Canvas.TextSize(SMNameArray[i], XL, YL);
				XMax = Max(XMax, XPos + XL);
				YMax = Max(YMax, YPos + YL);
			}

			YPos += SMLineSpace;
		}
	}

	//////////////////////////////////////////////

	function int KeyToNumber(EInputKey InKey)
	{
		local int i;

		for(i=0; i<10; i++)
		{
			if(bSpeechMenuUseLetters)
			{
				if(InKey == LetterKeys[i])
					return i;
			}
			else
			{
				if(InKey == NumberKeys[i])
					return i;
			}
		}

		return -1;
	}

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local int input, NumNums;

		NumNums = Min(SMArraySize - SMOffset, 10);

		// while speech menu is up, dont let user use console. Debateable.
		//if( KeyIsBoundTo( Key, "ConsoleToggle" ) )
		//	return true;
		//if( KeyIsBoundTo( Key, "Type" ) )
		//	return true;

		if (Action == IST_Press)
			bIgnoreKeys=false;

		if( Action != IST_Press )
			return false;

		if( Key==IK_Escape)
		{
			HandleInput(-1);
			return true ;
		}

		// If 'letters' mode is on, convert input
		input = KeyToNumber(Key);
		if(input != -1)
		{
			HandleInput(input);
			return true;
		}

		// Keys below are only used if bSpeechMenuUseMouseWheel is true
		if(!bSpeechMenuUseMouseWheel)
			return false;

		if( Key==IK_MouseWheelUp )
		{
			// If moving up on the top row, and there is a previous page
			if(HighlightRow == 0 && SMOffset > 0)
			{
				HandleInput(-2);
				HighlightRow=9;
			}
			else
			{
				HighlightRow = Max(HighlightRow - 1, 0);
			}

			return true;
		}
		else if( Key==IK_MouseWheelDown )
		{
			// If moving down on the bottom row (the 'MORE' row), act as if we hit it, and move highlight to top.
			if(HighlightRow == 9 && SMArraySize != 10)
			{
				HandleInput(0);
				HighlightRow=0;
			}
			else
			{
				HighlightRow = Min(HighlightRow + 1, NumNums - 1);
			}

			return true;
		}
		else if( Key==IK_MiddleMouse )
		{

			input = HighlightRow + 1;
			if(input == 10)
				input = 0;

			HandleInput(input);
			HighlightRow=0;
			return true;
		}

		return false;
	}

	function Font MyGetSmallFontFor(canvas Canvas)
	{
		local int i;
		for(i=1; i<8; i++)
		{
			if ( class'HudBase'.default.FontScreenWidthSmall[i] <= Canvas.ClipX )
				return class'HudBase'.static.LoadFontStatic(i-1);
		}
		return class'HudBase'.static.LoadFontStatic(7);
	}

	function PostRender( canvas Canvas )
	{
		local float XL, YL;
		local int SelLeft, i;
		local float XMax, YMax;

		Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.

		// Figure out max key name size
		XMax = 0;
		YMax = 0;
		for(i=0; i<10; i++)
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
		DrawNumbers( canvas, Min(SelLeft, 9), SelLeft > 9, true, XMax, YMax);
		DrawCurrentArray( canvas, true, XMax, YMax);
		Canvas.TextSize(SMStateName[ROSMState], XL, YL);
		XMax = Max(XMax, Canvas.ClipX*(SMOriginX+SMMargin) + XL);
		YMax = Max(YMax, (Canvas.ClipY*SMOriginY) - (1.2*SMLineSpace) + YL);
		// XMax, YMax now contain to maximum bottom-right corner we drew to.

		// Then draw the box
		XMax -= Canvas.ClipX * SMOriginX;
		YMax -= Canvas.ClipY * SMOriginY;
		Canvas.SetDrawColor(139,28,28,255);
		Canvas.SetPos(Canvas.ClipX * SMOriginX, Canvas.ClipY * SMOriginY);
		//Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), YMax + (SMMargin*Canvas.ClipY));
		Canvas.DrawTileStretched(Texture'InterfaceArt_tex.Menu.RODisplay', XMax + (SMMargin*Canvas.ClipX), YMax + (SMMargin*Canvas.ClipY));

		// Draw highlight
		if(bSpeechMenuUseMouseWheel)
		{
			Canvas.SetDrawColor(255,202,180,128);
			Canvas.SetPos( Canvas.ClipX*SMOriginX, Canvas.ClipY*(SMOriginY+SMMargin) + ((HighlightRow - 0.1)*SMLineSpace) );
			//Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), 1.1*SMLineSpace );
			Canvas.DrawTileStretched(Texture'InterfaceArt_tex.Menu.RODisplay', XMax + (SMMargin*Canvas.ClipX), 1.1*SMLineSpace );
		}

		// Then actually draw the stuff
		DrawNumbers( canvas, Min(SelLeft, 9), SelLeft > 9, false, XMax, YMax);
		DrawCurrentArray( canvas, false, XMax, YMax);

		// Finally, draw a nice title bar.
		Canvas.SetDrawColor(139,28,28,255);
		Canvas.SetPos(Canvas.ClipX*SMOriginX, (Canvas.ClipY*SMOriginY) - (1.5*SMLineSpace));
		//Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', XMax + (SMMargin*Canvas.ClipX), (1.5*SMLineSpace));
		Canvas.DrawTileStretched(Texture'InterfaceArt_tex.Menu.RODisplay', XMax + (SMMargin*Canvas.ClipX), (1.5*SMLineSpace));

		Canvas.SetDrawColor(255,255,128,255);
		Canvas.SetPos(Canvas.ClipX*(SMOriginX+SMMargin), (Canvas.ClipY*SMOriginY) - (1.2*SMLineSpace));

        Canvas.DrawText(SMStateName[ROSMState]);
	}

    function BeginState()
	{
        bVisible = true;
		bIgnoreKeys = true;
		bCtrl = false;
		HighlightRow=0;

		EnterROState(ROSMS_Main, true);
		SMCallsign="";

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

//==================================================
// Extension to open console for Vehicle Say command
//===================================================
exec function VehicleTalk()
{
	TypedStr="VehicleSay ";
	TypedStrPos=11;
    TypingOpen();
}

/*
// Test0r! used to make a bot from opposite team say something
exec function TestVoice()
{
		local PlayerController PC;
		local PlayerReplicationInfo PI, PI2;
		local Controller C;

		if (ViewportOwner != none)
			PC = ViewportOwner.Actor;

	    log("Found viewpower owner.");
	    PI = PC.PlayerReplicationInfo;

	    for (C = PC.Level.ControllerList; C != none; C = C.nextController)
	    {
	       log("Found controller...");
	       if (AIController(C) != none)
	       {
	           log("found bot!");
	           log("Checking replication info...");
	           PI2 = C.PlayerReplicationInfo;
	           if (PI.Team.TeamIndex != PI2.Team.TeamIndex)
	           {
	               log("bot is on different team!");
	               log("sending message...");
	               //SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
	               C.SendVoiceMessage(PI2, PI, 'ALERT', 3, 'TEAM', C.Pawn, C.Pawn.Location);
	               break;
	           }
	       }
	    }
}

exec function TestVoice2()
{
		local PlayerController PC;
		local PlayerReplicationInfo PI, PI2;
		local Controller C;

		if (ViewportOwner != none)
			PC = ViewportOwner.Actor;

	    log("Found viewpower owner.");
	    PI = PC.PlayerReplicationInfo;

	    for (C = PC.Level.ControllerList; C != none; C = C.nextController)
	    {
	       log("Found controller...");
	       if (AIController(C) != none)
	       {
	           log("found bot!");
	           log("Checking replication info...");
	           PI2 = C.PlayerReplicationInfo;
	           if (PI.Team.TeamIndex == PI2.Team.TeamIndex)
	           {
	               log("bot is on same team!");
	               log("sending message...");
	               //SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
	               C.SendVoiceMessage(PI2, PI, 'ALERT', 4, 'TEAM', C.Pawn, C.Pawn.Location);
	               break;
	           }
	       }
	    }
}
*/

defaultproperties
{
     AllPlayersSquad="All teammates"
     OwnSquad="My Squad"
     SquadSuffix="'s Squad"
     SMStateName(1)="Support"
     SMStateName(3)="Enemy Spotted"
     SMStateName(4)="Alert"
     SMStateName(5)="Vehicle Commands"
     SMStateName(6)="Vehicle Alerts"
     SMStateName(7)="Commands"
     SMStateName(8)="Taunts"
     SMStateName(9)="Attack..."
     SMStateName(10)="Defend..."
     SMStateName(11)="Go to..."
     SMStateName(12)="Request Help At..."
     SMStateName(13)="Under Attack At..."
     SMStateName(14)="Select order recipient..."
     SMOpenSound=Sound'ROMenuSounds.Generic.msfxEdit'
     SMAcceptSound=Sound'ROMenuSounds.Generic.msfxMouseClick'
     SMDenySound=Sound'ROMenuSounds.MainMenu.CharFade'
     ServerInfoMenu="ROInterface.ROGUIServerInfo"
}
