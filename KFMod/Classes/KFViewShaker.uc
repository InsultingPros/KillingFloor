//=============================================================================
// KFViewShaker:  extends ViewShaker with optional replication
//=============================================================================
class KFViewShaker extends ViewShaker;

var() bool   bReplicateShake;

simulated function Trigger( actor Other, pawn EventInstigator )
{
	local Controller		 C;
	local PlayerController   LocalPlayer, PC;
	local KFPlayerController KFPC;

	LocalPlayer = Level.GetLocalPlayerController();
	if( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < ShakeRadius) )
	{
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
	}

    if( bReplicateShake )
    {
    	for( C = Level.ControllerList; C != None; C = C.NextController )
    	{
            KFPC = KFPlayerController(C);
    		if( (KFPC != None) && (C != LocalPlayer) && (VSize(Location - KFPC.ViewTarget.Location) < ShakeRadius) )
    		{
    			KFPC.ClientShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    		}
    	}
    }
    else
    {
        for( C = Level.ControllerList; C != None; C = C.NextController )
        {
            PC = PlayerController(C);
    		if( (PC != None) && (C != LocalPlayer) && (VSize(Location - PC.ViewTarget.Location) < ShakeRadius) )
    		{
    			PC.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    		}
    	}
    }
}

defaultproperties
{
}
