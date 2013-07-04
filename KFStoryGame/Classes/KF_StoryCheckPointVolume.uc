/*
	--------------------------------------------------------------
	KF_StoryCheckPointVolume
	--------------------------------------------------------------

	Volume used to control spawning of players in story maps.

	When active, only those player starts inside the bounds of the volume are considered
	valid spawn points.  Can also be configured to force the respawn of dead (out of lives) players.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_StoryCheckPointVolume extends  PhysicsVolume
	hidecategories(PhysicsVolume,Collision,Brush,Advanced,Force,Karma,Lighting,LightColor,Movement,Sound,Volume,Display,VolumeFog) ;


/* prints debug text */
var							bool						bDebugCheckpoint;

/* if true this checkpoint will begin play active */
var(StoryCheckPoint)		bool						bStartEnabled;

/* 	If true, touching (or triggering) this checkpoint will restart all dead players at one of the playerstarts inside the volume's bounds */
var(StoryCheckPoint)		bool						bRespawnPlayers;

/* If true, this scripted action will respawn bot players as well as humans . Only used if bRespawnPlayers is true*/
var(StoryCheckPoint)		bool						bIncludeBots;

/* true if CheckPointActivated() was called and this volume is the current spawn-checkpoint for players*/
var							bool						bIsActive;

/* if true, CheckPointActivated() will only be called when the entire team is inside the Volume */
var(StoryCheckPoint)		bool						bRequiresWholeTeam;

/* Only relevant if bRespawn players is true.  In addition to respawning dead players when Activated  this volume will also auto-respawn everyone when their whole team wipes out */
var(StoryCheckPoint)		bool						bRespawnOnWipe;

/* Event that triggers when a team that was wiped out is given a 'second chance' by this Volume. Only relevant if bRespawnOnWipe is true */
var(Events)					array<name>					SecondChanceEvents;

/* array of additional events this checkpoint can trigger for use in maps with complex trigger setups */
var(Events)					array<name>					ActivationEvents;

/* Delay before dead players are actually restarted after the Checkpoint activates */
var(StoryCheckPoint)		float						RespawnDelay;

/* %of Max Health a player spawns with when this checkpoint brings him back to life. */
var(StoryCheckPoint)		float						RespawnHealthModifier;

/* if true ,  'RespawnHealthModifier' becomes cumulative each time a player respawns at this checkpoint.  ie.  if a player dies twice with a value of 0.75,  his starting health would be 56*/
var(StoryCheckPoint)		bool						bCumulativeHealthModifier;

/* same as above, but used if the LD wants to reset only specific actors in the map */
var(Team_Restart)			array<actor>				CheckPointResetActors;

/* for cases where the LD wants to reset all actors in the map of a particular class *Except* some specific actors ..*/
var(Team_Restart)			array<actor>				ResetExcludeActors;


var                         name       					RestartFromObjective;

/* players who wipe out will respawn at this specific checkpoint, if assigned */
var(Team_Restart)			string						RestartFromCheckPoint;

/* Object reference to the CheckPoint who's name we specified above */
var							KF_StoryCheckPointVolume	ForcedRestartCheckPoint;

/* Removes all dropped / thrown weapon pickups from play when a team is restarted at this checkpoint */
var(Team_Restart)			bool						bRemoveDroppedWeapons;

/* true while the Respawn Timer is running but RespawnPlayers() has not yet been called */
var							bool						bPendingRespawn;

/* true while the team is wiped out completely and is waiting to be restarted from this checkpoint */
var							bool						bPendingFullRestart;

/* Spawned to control timing of Player respawns.  Necessary because volumes are Static & can't run their own timers */
var							RespawnTimer				RespawnDelayTimer;

/* Cached reference to the player who last activated this Checkpoint */
var							Controller					ActivatingPlayer;

/* Cached reference to the player who was last respawned by this Checkpoint */
var							Controller					LastRespawnedPlayer;

/* If true,  teleport stragglers to a playerstart inside this volume */
var(StoryCheckPoint)		bool						bTeleportStragglers;

/* Max distance a player can be from this volume before being consider a straggler */
var(StoryCheckPoint)		float						TeleportStragglerDist;

/* 	If true this checkpoint can only be set as the active checkpoint in the map a single time
	Should probably be set true by default as most story maps will probably have a linear progression.
*/

var(StoryCheckPoint)		bool						bShowActivationMsg;

var(StoryCheckPoint)		bool						bSingleActivationOnly;

/* FriendlyName */
var(StoryCheckPoint)		string						CheckPointName;

/* Cached reference to Story gameinfo to cut down on typecasting */
var							KFStoryGameInfo				StoryGI;

/* used to save the current state of Dialogue at the time a checkpoint is activated so that it can be returned to later if a team restarts */
struct SDialogueState
{
	var 					KF_DialogueSpot				DialogueActor;
	var						int							SavedIndex;
	var						array<byte>  				DialogueTriggerStates;
};

var 						array<SDialogueState>		SavedDialogue;


enum ECheckPointTriggerType
{
	CTT_Touch,
	CTT_Trigger,
};

/* do we want this checkpoint to become active when remotely triggered, or on player touch ? */
var	(StoryCheckPoint)		ECheckPointTriggerType		CheckPointTriggerType;

var array<PlayerStart> PSList;

function Reset()
{
	LastRespawnedPlayer = none;
	ActivatingPlayer = none;
	bPendingRespawn = false;
	bIsActive = false;
}


simulated function PostBeginPlay()
{
	local 	NavigationPoint N;
	local 	PlayerStart PS;
	local	KF_DialogueSpot  DlgSpot;

	if( Level.NetMode==NM_Client )
		return;

	/* No KFO Gametype, no Initialization */
	StoryGI = KFStoryGameInfo(Level.Game);
	if(StoryGI == none)
	{
        return;
	}

	For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		PS = PlayerStart(N);
		if( PS!=None  )
		{
			if(Encompasses(PS) )
			{
				PSList[PSList.Length] = PS;
			}
		}
	}

	if(RestartFromCheckPoint != "" &&
	RestartFromCheckPoint != CheckPointName &&
	StoryGI != none )
	{
		ForcedRestartCheckPoint = StoryGI.FindCheckPointNamed(RestartFromCheckPoint);
	}

	// cache all the DialogueSpots in the map -  we'll need this to store the states for each one
	foreach DynamicActors(class 'KF_DialogueSpot', DlgSpot)
	{
		SavedDialogue.length = SavedDialogue.length + 1;
		SavedDialogue[SavedDialogue.length-1].DialogueActor = DlgSpot;
		SavedDialogue[SavedDialogue.length-1].DialogueTriggerStates.length = DlgSpot.Dialogues.length ;
	}
}


/* Wrapper for checking if this volume can grant second chances to teams that wipe out during story gameplay */
function bool		CanGrantSecondChances()
{
	local bool Result;

	if(ForcedRestartCheckPoint != none)
	{
		Result = true;//ForcedRestartCheckPoint.IsActiveRespawnPoint();
	}
	else
	{
		Result = IsActiveRespawnPoint();
	}


	if(!Result)
	{
		if(ForcedRestartCheckPoint != none)
		{
			log("Forced Restart CheckPoint : "@ForcedRestartCheckPoint.CheckPointName@" for - "@CheckPointName@" is unable to Respawn players at the moment. It is probably inactive . ");
		}
		else
		{
			log("CheckPoint : "@CheckPointName@"is unable to Respawn players at the moment. It is probably inactive . ");
		}
	}
	return Result ;
}

function bool IsActiveRespawnPoint()
{
	return bIsActive && bRespawnPlayers && bRespawnOnWipe /*&& !bPendingRespawn*/;
}

/* Respawns all dead players in the game when they wipe out -  Returns true if successful */

function	bool	GrantASecondChance(out KF_StoryCheckPointVolume RespawnPoint)
{
	if(CanGrantSecondChances())
	{
		RespawnPoint = self;

		if(ForcedRestartCheckPoint != none)
		{
			RespawnPoint = ForcedRestartCheckPoint ;
		}

		bPendingFullRestart = true;
		RespawnPoint.Reset() ;
		RespawnPoint.Instigator = Instigator;

		return true;
	}

	return false;
}


function UpdateSpawnAvailability()
{
	local NavigationPoint			N;
	local PlayerStart				PS;
	local bool 						bEnableMe;

	if( PSList.Length>0 )
	{
		For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			PS = PlayerStart(N);
			if(PS != none)
			{
//				log("Updating spawn availability for "@self@" - "@PS@".bEnabled = "@bEnableMe);
				bEnableMe = bIsActive && PStartBelongsToThisVolume(PS);
				PS.bEnabled = bEnableMe ;
			}
		}
	}
	else
	{
		log("Warning -  No Playerstarts associated with "@self@": Respawns will fail.");
	}
}


function		bool	PStartBelongsToThisVolume( PlayerStart TestSpot)
{
	local int i;

	for( i = 0 ; i < PSList.length; i ++)
	{
		if(PSList[i] == TestSpot)
		{
			return true;
		}
	}

	return Encompasses(TestSpot);
}

/* CTT_Touch*/

simulated event PawnEnteredVolume(Pawn Other)
{
	if(CheckPointTriggerType == CTT_Touch &&
	(Other.Controller != none && Other.Controller.bIsPlayer)	/*&&	 Other.IsPlayerPawn()*/)	// <- IsPlayerPawn() returns true in Monster.uc ...derp
	{
		CheckPointActivated(Other,false,bShowActivationMsg);
	}
}

/* CTT_Trigger*/

function Trigger( actor Other, pawn EventInstigator )
{
	if(CheckPointTriggerType == CTT_Trigger/* && EventInstigator != none &&
	EventInstigator.IsPlayerPawn()*/)
	{
		CheckPointActivated(EventInstigator,false,bShowActivationMsg);
	}
}

function ResetPlayerCheckPointStats()
{
	local Controller C;
	local KFPlayerController_Story	PC;

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
		PC = KFPlayerController_Story(C);
		if(PC != none)
		{
			PC.NumCheckPointRespawns = 0 ;
		}
	}
}


function int GetNumPlayersInVolume()
{
	local int Num;
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if(C.bIsPlayer && C.Pawn != none)
		{
			if(Encompasses(C.Pawn))
			{
				Num ++ ;
			}
		}
	}

//	log("NUM PLAYERS IN VOLUME : "@Num);

	return Num;
}

/* Tracks the current state of game Objectives & Dialogue at the time this checkpoint was activated */
function SaveStoryState()
{
	local int i,idx;
	local KF_DialogueSpot 	Dlg;
	local bool bJumpingForward;
	local int NextEventIdx;
	local name NextSortedObj;
	local Controller C;
	local KFPlayerController_Story SPC;


	if(bPendingFullRestart)
	{
		return;
	}

	/* If the LD hasn't provided a forced Objective to restart from, use whatever was current at the time of activation */
	if(RestartFromObjective == '' )
	{
		if(StoryGI.CurrentObjective != none && StoryGI.CurrentObjective.bCheckPointable)
		{
			RestartFromObjective = StoryGI.CurrentObjective.ObjectiveName;
		}
		else
		{
			/* if there's no current objective - the next objective is probably bManualActivate , so we're at a gap between obj's.
			 In this case we can just use the LastObjective and jump one forward.    */

            NextSortedObj = StoryGI.SortedObjectives[ Min( StoryGI.CurrentObjectiveIdx + 1 ,StoryGI.SortedObjectives.length - 1 )  ].ObjectiveName ;
            log(" No current Objective .. Checkpoint will restart from Next sorted objective : "@NextSortedObj,'Story_Debug');
			RestartFromObjective = NextSortedObj;
			bJumpingForward = true;
		}

        for(i = 0 ; i < StoryGI.AllObjectives.length ; i ++)
        {
            if(StoryGI.AllObjectives[i].ObjectiveName == RestartFromObjective)
            {
                StoryGI.AllObjectives[i].SetCheckPoint(self);
            }
            else
            {
                StoryGI.AllObjectives[i].ClearCheckPoint();
            }
        }
	}

	for( i = 0 ; i < SavedDialogue.length ; i ++)
	{
		Dlg = SavedDialogue[i].DialogueActor ;
		if(Dlg != none)
		{
			NextEventIdx = Dlg.GetNextDlgRequiredEventIdx(Dlg.CurrentMsgIdx) ;
			if(bJumpingForward && NextEventIdx > 0)
			{
				SavedDialogue[i].SavedIndex = NextEventIdx;
			}
			else
			{
				SavedDialogue[i].SavedIndex = Dlg.CurrentMsgIdx ;
			}

			if(Dlg.bDebugDialogue)
			{
				log("----- DIALOGUE DEBUG ------   Saving Dialogue Index of : "@Dlg@" At  : "@SavedDialogue[i].SavedIndex, 'Story_Debug' );
			}

			for(idx = 0 ; idx < SavedDialogue[i].DialogueTriggerStates.length ; idx ++ )
			{
				SavedDialogue[i].DialogueTriggerStates[idx] = byte(Dlg.Dialogues[idx].bWasTriggered) ;
			}

		}
	}

    // store players current equipment and cash amounts so we can restore it all when they spawn from this checkpoint
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
        SPC = KFPlayerController_Story(C);
        if(SPC != none)
        {
            SPC.SaveLoadOut();
        }

        if(KF_StoryNPC(C.Pawn) != none)
        {
            KF_StoryNPC(C.Pawn).SaveHealthState();
        }
	}
}

function ModifyPlayer( pawn aPlayer)
{
    local float CheckPointHealthModifier;
    local KFPlayerController_Story SPC;

	SPC = KFPlayerController_Story(aPlayer.Controller);
	if(SPC == none)
	{
	   return;
	}

    if(bRespawnOnWipe)
    {
	   aPlayer.Health = SPC.SavedHealth;
	   aPlayer.ShieldStrength = SPC.SavedArmor;
	   SPC.PlayerReplicationInfo.Score = SPC.SavedCash;
    }

    if (RespawnHealthModifier != 1.f )
	{
        CheckPointHealthModifier = RespawnHealthModifier ;
		if(bCumulativeHealthModifier)
		{
			CheckpointHealthModifier = CheckPointHealthModifier ** SPC.NumCheckPointRespawns ;
		}

		aPlayer.Health =  Max(aPlayer.Health * CheckPointHealthModifier,1) ;
	}
}


function		int			GetSavedDialogueIndexFor(KF_DialogueSpot		DialogueSpot , out array<byte>	WasTriggeredArray)
{
	local int i;

	if(DialogueSpot == none)
	{
		return -1;
	}

	for( i = 0 ; i < SavedDialogue.length ; i ++)
	{
		if(SavedDialogue[i].DialogueActor != none &&
		SavedDialogue[i].DialogueActor == DialogueSpot)
		{
			WasTriggeredArray = SavedDialogue[i].DialogueTriggerStates ;
			return SavedDialogue[i].SavedIndex ;

		}
	}
}

/* 	Called when this volume has been set as the new active checkpoint zone in the map
	Enables encompassed playerstarts & disables all others.
*/

function CheckPointActivated( Pawn CheckPointInstigator, bool bForceActivate, optional bool bShowMessage)
{
	local KF_StoryCheckPointVolume	OldCheckpoint;
	local Controller C;

	/* Check for a human controlled pawn */
	if(CheckPointInstigator.Controller != none)
	{
		ActivatingPlayer = CheckPointInstigator.Controller;
		if(ActivatingPlayer != none && PlayerController(ActivatingPlayer) != none &&
		ActivatingPlayer.Pawn != none )
		{
			Instigator = ActivatingPlayer.Pawn ;
		}
	}

	if(!bForceActivate &&
	bRequiresWholeTeam &&
	GetNumPlayersInVolume() < StoryGI.GetTotalActivePlayers())
	{
		return;
	}

	if(!bIsActive || bForceActivate)
	{
        log("===============================================",'Story_Debug');
	    log("CheckPointActivated! - "@CheckPointName,'Story_Debug');

		bIsActive = true;

		if(!bPendingFullRestart)
		{
			TriggerActivationEvents();

			if(bRespawnOnWipe)
			{
                SaveStoryState();
            }
        }

		if(StoryGI != none)
		{
			OldCheckPoint = StoryGI.CurrentCheckPoint ;
			StoryGI.CurrentCheckPoint = self ;

            for ( C=Level.ControllerList; C!=None; C=C.NextController )
            {
                if(KFPlayerController_Story(C) != none)
                {
                    KFPlayerController_Story(C).CurrentCheckPoint = self;
                }
            }

			if(bShowMessage)
			{
				BroadcastLocalizedMessage( StoryGI.default.CheckPointMessageClass , 0, ActivatingPlayer.PlayerReplicationinfo, None, self );
			}
		}

		UpdateSpawnAvailability();
		ResetPlayerCheckpointStats();

		if( bRespawnPlayers )
		{
			DelayedRespawnDeadPlayers();
		}

		if( bTeleportstragglers)
		{
			TeleportLivingPlayers();
		}

		if(Instigator == none)
		{
			log("Warning - No human instigator found when Activating "@self@".  Some actors require a human instigator to trigger successfully . (Movers) ");
		}

		if(bDebugCheckPoint)
		{
			PrintDebugText(ActivatingPlayer.PlayerReplicationInfo.PlayerName@"activated"@CheckPointName);
		}
	}
}

/* Fire off a set of events when this checkpoint is activated */

function TriggerActivationEvents()
{
	local int i;

	TriggerEvent(Event,self, Instigator);

	for(i = 0 ; i < ActivationEvents.length ; i ++)
	{
		TriggerEvent(ActivationEvents[i],self,Instigator);
	}

}


function DelayedRespawnDeadPlayers()
{
	if(!bPendingRespawn)
	{
		bPendingRespawn = true;

		if ( RespawnDelayTimer == None )
		{
			RespawnDelayTimer = spawn(class'RespawnTimer', self);
			if(RespawnDelayTimer != none)
			{
				RespawnDelayTimer.TimerFrequency = RespawnDelay ;
			}
		}
		else
		{
			RespawnDelayTimer.Reset();
		}
	}
}

/* Called from ReSpawnTimer.Timer() -  notification that the timer expired
and it is now time to perform the actual respawn.*/

function RespawnTimerPop()
{
	RespawnDeadPlayers();

	/* if this is a full-team-restart, we need to reset certain actors in the map
	as well - Notify the gameinfo that this would be a good time to do that*/
	if(StoryGI != none && StoryGI.bPendingTeamRespawn)
	{
		StoryGI.bPendingTeamRespawn = false ;
		TriggerActivationEvents();
	}

}


/* Brings bOutLives players back from the dead. They will spawn at one of the player starts inside this volume's bounds */

function RespawnDeadPlayers()
{
	local Controller C;
	local KFPlayerController KFPC;
	local PlayerController PC;
	local KFPlayerReplicationInfo KFPRI;

	bPendingRespawn = false;

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.PlayerReplicationInfo != none )
		{
			/* I'm guessing we are still using Perks in Story mode ? ... will leave this in for now */
			KFPC = KFPlayerController(C);
			if ( KFPC != none )
			{
				KFPRI = KFPlayerReplicationInfo(C.PlayerReplicationinfo);
				if ( KFPRI != none )
				{
					KFPC.bChangedVeterancyThisWave = false;

					if ( KFPRI.ClientVeteranSkill != KFPC.SelectedVeterancy )
					{
						KFPC.SendSelectedVeterancyToServer();
					}
				}
			}

			if(C.PlayerReplicationInfo.bOnlySpectator ||
			!C.PlayerReplicationInfo.bOutOfLives ||
			(C.PlayerReplicationInfo.bBot && !bIncludeBots))
			{
				continue;
			}

			C.PlayerReplicationInfo.bOutOfLives = false;
			C.PlayerReplicationInfo.NumLives = 0;

            PC = PlayerController(C);
			if( PC != none )
			{
				PC.GotoState('PlayerWaiting');
				PC.SetViewTarget(C);
				PC.ClientSetBehindView(false);
				PC.bBehindView = False;
				//	PC.ClientSetViewTarget(C.Pawn);	 <-  that's all well and good but .. At this point 'C'  has no pawn ... Gonna move this down after RestartPlayer()
			}

			if(KFPlayerController_Story(C) != none)
			{
				KFPLayerController_Story(C).NumCheckPointRespawns ++ ;
			}

			LastRespawnedPlayer = C;

			// Make sure the dude we're respawning hast at least some cash.
		    C.PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash, int(C.PlayerReplicationInfo.Score));
			C.ServerReStartPlayer();

            if(PC != none && PC.Pawn != none)
			{
				PC.ClientSetViewTarget(PC.Pawn);
			}
		}
	}

	LastRespawnedPlayer = none;

	/* Full Checkpoint restart (everyone was wiped out) */
	if(bPendingFullRestart && StoryGI != none)
	{
		bPendingFullRestart = false;
		StoryGI.NotifyTeamRestarted();
	}
}

/* Teleports all living players in the map (outside of the volume) to a playerstart in this volume. */

function TeleportLivingPlayers()
{
	local NavigationPoint	TeleportSpot;
	local Controller		C;

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.PlayerReplicationInfo != none )
		{
			if(C.bIsPlayer &&
			!C.PlayerReplicationInfo.bOutOfLives &&
			!C.PlayerReplicationInfo.bOnlySpectator &&
			C.Pawn != none && C.Pawn.Health > 0 &&
			C.Pawn.PhysicsVolume != self )
			{
				if(VSize(C.Pawn.Location - Location) >= TeleportStragglerDist)
				{
					TeleportSpot = Level.Game.FindPlayerStart(C,C.GetTeamNum());
					if(TeleportSpot != none)
					{
						C.Pawn.SetLocation(TeleportSpot.Location);
					}
				}
			}
		}
	}
}

function	PrintDebugText( string Message)
{
	local Controller C;
	local PlayerController P;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		P = PlayerController(C);
		if( P != None )
		{
			P.TeamMessage(C.PlayerReplicationInfo, Message, 'CriticalEvent');
		}
	}
}

defaultproperties
{
     bRespawnPlayers=True
     bIncludeBots=True
     bRespawnOnWipe=True
     RespawnDelay=2.000000
     RespawnHealthModifier=1.000000
     bCumulativeHealthModifier=True
     bRemoveDroppedWeapons=True
     TeleportStragglerDist=2000.000000
     bShowActivationMsg=True
     bSingleActivationOnly=True
     CheckPointName="a checkpoint"
     bStatic=False
}
