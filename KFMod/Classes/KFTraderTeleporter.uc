// This will kick you out of the Trader's room when the Wave is in progress (and assuming you were naughty, and didn't just leave)

class KFTraderTeleporter extends Teleporter;

var	localized string	CantStayInShopAfterClose;

function Trigger( actor Other, pawn EventInstigator )
{
    local KFHumanPawn A;
    Log("Trigger Call");
   // Log("Am I enabled? : "$bEnabled);

    //bEnabled = !bEnabled;
    if ( bEnabled ) //teleport any pawns already in my radius
        ForEach TouchingActors(class'KFHumanPawn', A)
            PostTouch(A);
}

// Let's add a Bitchy message to let the player know that hanging around after closing is a no-no

simulated function PostTouch( actor Other )
{
    local Teleporter D,Dest[16];
    local int i;



 if (KFGameReplicationInfo(Level.Game.GameReplicationInfo).bWaveInProgress)
 {
    //Log("REMOVING SHOP HOG!");

    PlayerController(Pawn(Other).Controller).ClientMessage(CantStayInShopAfterClose, 'KFCriticalEvent');
    PlayerController(Pawn(Other).Controller).ClientCloseMenu(true, true);

    if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
    {
        // Teleport to a level on the net.
        if( (Role == ROLE_Authority) && (Pawn(Other) != None)
            && Pawn(Other).IsHumanControlled() )
            Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);
    }
    else
    {
        // Teleport to a random teleporter in this local level, if more than one pick random.

        foreach AllActors( class 'Teleporter', D )
            if( string(D.tag)~=URL && D!=Self )
            {
                Dest[i] = D;
                i++;
                if ( i > arraycount(Dest) )
                    break;
            }

        i = rand(i);
        if( Dest[i] != None )
        {
            // Teleport the actor into the other teleporter.
            if ( Other.IsA('Pawn') )
                Other.PlayTeleportEffect(false, true);
            Dest[i].Accept( Other, self );
            if ( Pawn(Other) != None )
                TriggerEvent(Event, self, Pawn(Other));
        }
    }
  }
}

defaultproperties
{
     CantStayInShopAfterClose="You cannot stay in the shop after closing"
}
