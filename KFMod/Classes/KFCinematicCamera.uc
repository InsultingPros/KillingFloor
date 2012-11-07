class KFCinematicCamera extends Actor
    placeable;


var()   float               ShotLength;             // length of shot in seconds...
var()   name                EventViewingCamera;     // Event triggered when camera is active
var()   name                NextCameraTag;
var     KFCinematicCamera  NextCamera;
var()   bool                bInitiallyActive;
var     bool                bActive;

var     KFSceneManager    ASCSM;

var()  string        Subtitle[5];

function PostBeginPlay()
{
    super.PostBeginPlay();

    bActive = bInitiallyActive;

    if ( NextCameraTag != '' )
        ForEach AllActors(class'KFCinematicCamera', NextCamera, NextCameraTag)
            break;

    if ( ShotLength == 0 )  // safety check
        ShotLength = 2;
}

/* Specific version, when viewing an objective for end of round cam (and attackers didn't win)*/
function ViewFixedObjective( PlayerController PC, GameObjective GO )
{
    PC.ClientSetFixedCamera( true );
    PC.ClientSetViewTarget( Self );
    PC.SetViewTarget( Self );
}


/* Scene Manager sets the view on this camera */
function SetView( KFSceneManager SM , optional bool bCinematicEnded)
{
    local Controller        C, NextC;
    local PlayerController  PC;
    local int i;

    // ServerSetSubtitles();


    C = Level.ControllerList;
    while ( C != None  )
    {
        NextC = C.NextController;
        if ( C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator )
        {
            PC = PlayerController(C);
            if ( PC != None )
            {
                if (!bCinematicEnded)
                {
                 PC.ClientSetFixedCamera( true );
                 PC.ClientSetViewTarget( Self );
                 PC.SetViewTarget( Self );
                 
                 // Can't control our pawn during Cinematic
                 PC.GotoState('BaseSpectating');

                // Set our next subtitles
                 
                  for(i=0; i<5; ++i)
                  {
                   KFPlayerReplicationInfo(PC.PlayerReplicationInfo).SubTitle[i] = Subtitle[i];
                  }

                }
                else
                {
                 // Re-attach the controller to the pawn
                 PC.ClientSetViewTarget(PC.pawn);
                 PC.SetViewTarget(PC.pawn);
                 PC.GotoState('PlayerWalking');
                }

            }
        }
        C = NextC;
    }

    if (!bCinematicEnded)
    {
     TriggerEvent(EventViewingCamera, Self, None);

     if ( SM != None )
     {
        SetTimer( ShotLength, false );
        ASCSM = SM;
     }
    }
}

   /*

function ServerSetSubtitles()
{
  local int i;  

  if (Subtitle.length > 0)
   {
      for(i=0; i<subtitle.length; ++i)
      {
         KFGameReplicationInfo(Level.Game.GameReplicationInfo).Subtitle[i] = subtitle[i];
         log("Camera set GameInfo Subtitle to"$KFGameReplicationInfo(Level.Game.GameReplicationInfo).Subtitle[i]);

          if ( KFGameReplicationInfo(Level.Game.GameReplicationInfo).Subtitle.length == subtitle.length)
           subtitle.length = 0;

       }

    }
    
}
*/


function Timer()
{
    ASCSM.ShotEnded( Self );
}

function Trigger( Actor Other, Pawn EventInstigator )
{
    bActive = !bActive;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
    super.Reset();
    bActive = bInitiallyActive;
}

defaultproperties
{
     ShotLength=2.000000
     bInitiallyActive=True
     bHidden=True
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine.Proj_Icon'
}
