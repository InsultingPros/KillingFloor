//=============================================================================
// ROArtilleryTrigger
//=============================================================================
// Place in the level to call in artillery strikes. Player's use this trigger
// To call in the strike.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================

class ROArtilleryTrigger extends Triggers;

//#exec OBJ LOAD FILE=..\sounds\Artillery.uax

//=============================================================================
// Variables
//=============================================================================

var() enum AT_ArtyTriggerable
{
	AT_Axis,
	AT_Allies,
	AT_Both,
} TeamCanUse;

var bool bAvailable; // The radio is available for a call
var bool bWaiting;   // Waiting to be reenabled

var Pawn SavedUser;
var SoundGroup GermanRequestSound;
var SoundGroup RussianRequestSound;
var SoundGroup GermanConfirmSound;
var SoundGroup RussianConfirmSound;
var SoundGroup GermanDenySound;
var SoundGroup RussianDenySound;

var() localized string Message;

//=============================================================================
// Functions
//=============================================================================

function bool SelfTriggered()
{
	return true;
}

function timer()
{
     if( !bWaiting )
     {
          if ( SavedUser != none && SavedUser.Controller != none)
          {
              ROPlayer(SavedUser.Controller).HitThis(self);
              bWaiting = true;
              SetTimer(10.0, false);
          }
          else
          {
              // Should never make it in here, but just in case lets reset everything. - Ramm
              bAvailable = true;
              bWaiting = false;
          }
     }
     else
     {
          bAvailable = true;
          bWaiting = false;
     }
}

function UsedBy( Pawn user )
{
	local ROPlayer ROP;
	local ROVolumeTest RVT;
	local ROPlayerReplicationInfo PRI;

    if (!bAvailable)
       return;

    SavedUser = none;

	if( user.Controller != none )
    	ROP = ROPlayer(user.Controller);

    // Bots can't call arty yet
    if( ROP == none )
    	return;

    PRI = ROPlayerReplicationInfo(ROP.PlayerReplicationInfo);

    // Don't let non-commanders call in arty
	if ( PRI == none || PRI.RoleInfo == none || !PRI.RoleInfo.bIsLeader )
	{
        return;
	}

/*    if ( user.GetTeamNum() == AXIS_TEAM_INDEX )
    {
         if ( ROGameReplicationInfo(Level.Game.GameReplicationInfo).AxisArtilleryCoords == vect(0,0,0))
         {
            ROPlayer(user.Controller).ReceiveLocalizedMessage(class'ROArtilleryMsg', 4);
            return;
         }
    }
    else if (user.GetTeamNum() == ALLIES_TEAM_INDEX )
    {
         if ( ROGameReplicationInfo(Level.Game.GameReplicationInfo).AlliedArtilleryCoords == vect(0,0,0))
         {
            ROPlayer(user.Controller).ReceiveLocalizedMessage(class'ROArtilleryMsg', 4);
            return;
         }
    }*/

    if ( ROP != none && ROP.SavedArtilleryCoords == vect(0,0,0))
    {
       ROP.ReceiveLocalizedMessage(class'ROArtilleryMsg', 4);
       return;
    }

    // Don't let the player call in an arty strike on a location that has become an active
    // NoArtyVolume after they marked the location.
    if ( ROP != none )
    {
        RVT = Spawn(class'ROVolumeTest',self,,ROP.SavedArtilleryCoords);

        if ((RVT != none && RVT.IsInNoArtyVolume()))
        {
            ROP.ReceiveLocalizedMessage(class'ROArtilleryMsg', 5);
            RVT.Destroy();
            return;
        }

        RVT.Destroy();
    }

    if ( ApprovePlayerTeam( user.GetTeamNum() ) )
    {
         SavedUser = user;
         bAvailable = false;

         if( SavedUser.Controller != none )
		 	ROP = ROPlayer(SavedUser.Controller);

         if( ROP != none )
	         ROPlayer(SavedUser.Controller).ReceiveLocalizedMessage(class'ROArtilleryMsg', 1);

	     if ( user.GetTeamNum() == AXIS_TEAM_INDEX )
         {
              user.PlaySound( GermanRequestSound, Slot_None, 3.0, false, 100,1.0,true);
              SetTimer(GetSoundDuration(GermanRequestSound), false);
         }
         else
         {
              user.PlaySound( RussianRequestSound,Slot_None, 3.0, false, 100,1.0,true );
              SetTimer(GetSoundDuration(RussianRequestSound), false);
         }
    }
}

function Touch( Actor Other )
{
	local ROPlayerReplicationInfo PRI;
	local Pawn P;

    P = Pawn(Other);

    if ( P != none )
    {
    	PRI = ROPlayerReplicationInfo(P.PlayerReplicationInfo);
    }

	if ( PRI != none && PRI.RoleInfo != none && PRI.RoleInfo.bIsLeader &&
		ApprovePlayerTeam( Pawn(Other).GetTeamNum() ) )
	{
	    // Send a string message to the toucher.
	    if( Message != "" )
		    Pawn(Other).ClientMessage( Message );

		if ( AIController(Pawn(Other).Controller) != None )
			UsedBy(Pawn(Other));
	}
}

// Check if a Team is valid
function bool ApprovePlayerTeam(byte Team)
{
	if ( TeamCanUse == AT_Both )
		return true;

    if ( TeamCanUse == AT_Axis && Team == AXIS_TEAM_INDEX )
    {
         //if ( ROGameReplicationInfo(Level.Game.GameReplicationInfo).AxisArtilleryCoords != vect(0,0,0))
         //{
            return true;
         //}
    }
    else if ( TeamCanUse == AT_Allies && Team == ALLIES_TEAM_INDEX )
    {
         //if ( ROGameReplicationInfo(Level.Game.GameReplicationInfo).AlliedArtilleryCoords != vect(0,0,0))
         //{
            return true;
         //}
    }

    return false;
}

function Reset()
{
    bAvailable=true;
    bWaiting=false;
}

defaultproperties
{
}
