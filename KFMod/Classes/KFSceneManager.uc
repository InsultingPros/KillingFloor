// Trying to make a less retarded version of the Network friendly SceneManager.

class KFSceneManager extends Info
    placeable;

//var()   bool    bHideHUD ;
var () bool bWideScreenOverlay;  // Cinematic overlay. ON, by default.
var() name  CameraTag;
var() name  EventSceneStarted;
var() name  EventSceneEnded;




var KFCinematicCamera  Camera;


function PostBeginPlay()
{
    super.PostBeginPlay();
    if ( CameraTag != '' )
        ForEach AllActors(class'KFCinematicCamera', Camera, CameraTag)
            break;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
    PlayScene();
}

function PlayScene()
{
    local Controller P;

    KFSPGameType(Level.Game).KFSceneStarted( None, Self );
    Camera.SetView( Self );
    TriggerEvent(EventSceneStarted, Self, None);



     for( P = Level.ControllerList ; P != None ; P = P.nextController )
            if( P.IsA('PlayerController')  )
            {
               //PlayerController(P).MyHud.bHideHUD = bHideHUD;
              if(KFPlayerReplicationInfo(PlayerController(P).PlayerReplicationInfo)!= none)
              {
               KFPlayerReplicationInfo(PlayerController(P).PlayerReplicationInfo).bViewingMatineeCinematic = true;
               KFPlayerReplicationInfo(PlayerController(P).PlayerReplicationInfo).bWideScreenOverlay = bWideScreenOverlay;
              }
               //PlayerController(P).UnPossess();
               //PlayerController(P).bFrozen = true;
              // PlayerController(P).GotoState('Spectating');
            }


}


event ShotEnded( KFCinematicCamera Cam )
{

    if ( Cam != None && Cam.NextCamera != None && Cam.NextCamera != Camera )    // safety check, avoid loops
    {
        if ( Cam.NextCamera.bActive )
        {
            // Set our next view
             Cam.NextCamera.SetView( Self );


         }
          else
            ShotEnded( Cam.NextCamera );    // Skip if not active (use triggers to activate/deactivate cameras)
    }
     else
        SceneEnded();

}

function SceneEnded()
{
    local Controller P;

    KFSPGameType(Level.Game).KFSceneEnded( None, Self );
    TriggerEvent(EventSceneEnded, Self, None);


    for( P = Level.ControllerList ; P != None ; P = P.nextController )
            if( P.IsA('PlayerController')  )
            {
               //PlayerController(P).MyHud.bHideHUD = bHideHUD;
              if(KFPlayerReplicationInfo(PlayerController(P).PlayerReplicationInfo)!= none)
               KFPlayerReplicationInfo(PlayerController(P).PlayerReplicationInfo).bViewingMatineeCinematic = false;
               Camera.SetView( Self , true );
            }

}

defaultproperties
{
     bWideScreenOverlay=True
     bNoDelete=True
     Texture=Texture'Engine.S_SceneManager'
}
