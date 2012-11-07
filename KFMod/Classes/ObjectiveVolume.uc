// Blocks Humans, but not zombies from coming through.
// When triggered, it removes itself.

class ObjectiveVolume extends Volume;

var VolumeTimer CheckTimer;

function PostBeginPlay()
{
    // skip associatedactor setup..
    super(Brush).PostBeginPlay();

    if ( CheckTimer == None )
    {
        CheckTimer = Spawn(class'VolumeTimer', Self);
        if ( CheckTimer != None )
            CheckTimer.TimerFrequency = 2;
    }
}


function Destroyed()
{
    if ( CheckTimer != None )
    {
        CheckTimer.Destroy();
        CheckTimer = None;
    }

    super.Destroyed();
}

function TimerPop(VolumeTimer T)
{
    local KFHumanPawn          P;

    foreach TouchingActors(class'KFHumanPawn', P)
    {
        if ( PlayerController(P.Controller) != None )
        {
         PlayerController(P.Controller).ClientMessage("FORBIDDEN!");
        }
    }    
}

defaultproperties
{
}
