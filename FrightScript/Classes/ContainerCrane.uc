/*
	--------------------------------------------------------------
	Container Crane
	--------------------------------------------------------------

    An Animated Container Crane mesh whos animation is controlled by the
    the progress state of an Objective condition.

    Animation is played only on the client.

    Author :  Alex Quick

	--------------------------------------------------------------
*/

class ContainerCrane extends Actor
placeable;

// Tag of the condition which control's this Crane's animation.
var () const name AssociatedConditionTag;
// Object reference to the condition which controls this Crane's animation
var private KF_ObjectiveCondition AssociatedCondition;
// Name of the animation the Crane plays when its lowering / raising its winch.
var () const name WinchLoweringAnim;
// The Current frame the animation is playing (used for interpolation)
var float CurrentAnimFramePct;
// The last position in the animation expressed as a percent.
var float LastAnimFramePct;
// True if the animation is not playing in reverse.
var bool bPlayingForward;


// Struct representing a sound effect we should play at some time during the animation.

struct SAnimSoundEffect
{
    // reference to the actual sound in the package.
    var () sound  SoundToPlay;
    // The frame %age to start playing the sound at.  (i.e  In a 600 frame animation if you want to play at frame 300, this value should be 0.5 )
    var () float  StartFramePct;
    // the frame %age to stop playing the sound at.
    var () float  EndFramePct;
    // Is this a looping sound or not.  If not,  'EndFramePct' has no actual relevance.
    var () bool   bLooping;
    // Has this sound been played already?  Only has real relevance to non-looping sounds.
    var    bool   bPlayed;
};

var () array<SAnimSoundEffect>  AnimSounds;

var float ConditionCompletionPct;

replication
{
    unreliable if(Role == Role_Authority && bNetDirty)
        ConditionCompletionPct;
}


function PostbeginPlay()
{
    local KF_ObjectiveCondition Condition;

    foreach AllObjects(class 'KF_ObjectiveCondition', Condition)
    {
        if(Condition.Tag == AssociatedConditionTag)
        {
            AssociatedCondition = Condition;
            NetupdateFrequency = 1.f / Condition.ConditionRepInterval;   // Sync net update rates.
            break;
        }
    }
}

simulated function Tick(float DeltaTime)
{
    local bool bOldDirection;
    local int i;

    if(Role == Role_Authority && AssociatedCondition != none && AssociatedCondition.bActive)
    {
        ConditionCompletionPct = AssociatedCondition.GetCompletionPct();
    }

    LastAnimFramePct = CurrentAnimFramePct;
    CurrentAnimFramePct = Lerp(DeltaTime,CurrentAnimFramePct,ConditionCompletionPct);

    bOldDirection = bPlayingForward;
    bPlayingForward = CurrentAnimFramePct >= LastAnimFramePct;

    // Animation is reversing , reset sounds.
    if(Role == Role_Authority && bOldDirection != bPlayingForward)
    {
        for(i = 0 ; i < AnimSounds.length ; i ++)
        {
            AnimSounds[i].bPlayed = false;
        }
    }

    if(Level.NetMode != NM_DedicatedServer &&
    ConditionCompletionPct != CurrentAnimFramePct &&
    ConditionCompletionPct < 1.f)
    {
        SetAnimFramePct(CurrentAnimFramePct);
    }

    if(CurrentAnimFramePct > 0.f)
    {
        PlayAnimSounds(CurrentAnimFramePct);
    }
}

function PlayAnimSounds(float CurrentPct)
{
    local int i;
    local Sound AmbSoundToPlay;
    local bool bShouldPlaySound;
    local bool bReversing;

    if(Role < Role_Authority)
    {
        return;
    }

    for(i = 0 ; i < AnimSounds.length ; i ++)
    {
        if(AnimSounds[i].SoundToPlay != none)
        {
            bReversing = !bPlayingForward;

            // Play Looped sounds.  There can only be one of these at a time.
            if(AnimSounds[i].bLooping)
            {
                bShouldPlaySound = CurrentPct >= AnimSounds[i].StartFramePct && (AnimSounds[i].EndFramePct == 0.f || CurrentPct <= AnimSounds[i].EndFramePct) ;
                if(bShouldPlaySound)
                {
                    AnimSounds[i].bPlayed = true;
                    AmbSoundToPlay = AnimSounds[i].SoundToPlay;
                }
            }
            else  // Play one-off sounds.  These can overlap.
            {
                bShouldPlaySound = !AnimSounds[i].bPlayed && CurrentPct >= AnimSounds[i].StartFramePct ;
                if(bShouldPlaySound)
                {
                    AnimSounds[i].bPlayed = true;
                    PlaySound(AnimSounds[i].SoundToPlay,SLOT_None,((SoundVolume/255) * 2.0),true,SoundRadius,,!bFullVolume);
                }
            }
        }
    }

    if(AmbSoundToPlay != AmbientSound)
    {
        AmbientSound = AmbSoundToPlay;
    }
}


simulated function SetAnimFramePct( float NewPct)
{
	PlayAnim( WinchLoweringAnim, 1.0f,0.f);
    SetAnimFrame(NewPct,0);
}

defaultproperties
{
     WinchLoweringAnim="LowerCrane"
     DrawType=DT_Mesh
     bNoDelete=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'FrightYard_SKM.SKM_DockCrane'
     bFullVolume=True
     SoundVolume=255
     SoundRadius=2000.000000
}
