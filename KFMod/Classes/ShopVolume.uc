//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ShopVolume extends Volume;

var() string URL;
var() float EnabledProbability; // How big chance is it that I get selected to be open on wave start?
var() bool bAlwaysEnabled; // Should the trader always be open (even when its not my turn)?
var array<Teleporter> TelList;
var bool bTelsInit,bHasTeles,bInitTriggerActs,bCurrentlyOpen,bAlwaysClosed;
var array<Actor> TriggeringActors;
var NavigationPoint BotPoint;
var WeaponLocker MyTrader;

// this shop is only used in the Objective mode gametype.
var(Advanced) const bool  bObjectiveModeOnly;

function Touch( Actor Other )
{
	if( Pawn(Other)!=None && PlayerController(Pawn(Other).Controller)!=None && KFGameType(Level.Game)!=None && !KFGameType(Level.Game).bWaveInProgress )
	{
	    if( !bCurrentlyOpen )
        {
            BootPlayers();
            return;
        }

		MyTrader.SetOpen(true);
        if( KFPlayerController(Pawn(Other).Controller) !=None )
        {
            KFPlayerController(Pawn(Other).Controller).SetShowPathToTrader(false);
        	KFPlayerController(Pawn(Other).Controller).CheckForHint(52);
		}

		PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(Class'KFMainMessages',3);

		if ( KFPlayerController(Pawn(Other).Controller) != none && !KFPlayerController(Pawn(Other).Controller).bHasHeardTraderWelcomeMessage )
		{
			// Have Trader say Welcome to players
			if ( KFGameType(Level.Game).WaveCountDown >= 30 )
			{
				KFPlayerController(Pawn(Other).Controller).ClientLocationalVoiceMessage(Pawn(Other).PlayerReplicationInfo, none, 'TRADER', 7);
				KFPlayerController(Pawn(Other).Controller).bHasHeardTraderWelcomeMessage = true;
			}
		}
	}
	else if( Other.IsA('KF_StoryInventoryPickup') )
	{
	    if( !bCurrentlyOpen )
        {
            BootPlayers();
            return;
        }
	}
}
function UnTouch( Actor Other )
{
	if( Pawn(Other)!=None && PlayerController(Pawn(Other).Controller)!=None && KFGameType(Level.Game)!=None )
		MyTrader.SetOpen(false);
}
function UsedBy( Pawn user )
{
    // Set the pawn to an idle anim so he wont keep making footsteps
    User.SetAnimAction(User.IdleWeaponAnim);

	if( KFPlayerController(user.Controller)!=None && KFGameType(Level.Game)!=None && !KFGameType(Level.Game).bWaveInProgress )
		KFPlayerController(user.Controller).ShowBuyMenu(string(MyTrader.Tag),KFHumanPawn(user).MaxCarryWeight);
}

function InitTeleports()
{
    local NavigationPoint N,BestN;
	local int i;
	local float Dist,BDist;

	bTelsInit = True;
	For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		if( Teleporter(N)!=None && string(N.Tag)~=URL )
		{
			TelList.Length = i+1;
			TelList[i] = Teleporter(N);
			i++;
			bHasTeles = True;
		}
		Dist = VSize(N.Location-Location);
		if( Dist<2000 && (BestN==None || BDist>Dist) && FastTrace(N.Location,Location) )
		{
			BestN = N;
			BDist = Dist;
		}
	}
	BotPoint = BestN;
}

function bool BootPlayers()
{
	local KFHumanPawn Bootee;
	local int i,idx;
	local bool bResult;
	local int NumTouching,NumBooted;
	local array<Teleporter> UnusedSpots;
	local bool bBooted;

	if( !bTelsInit )
		InitTeleports();
	if( !bHasTeles )
		Return False; // Wtf?

    UnusedSpots = TelList;

//    log("******************************************************");

    /* TouchingActors iterator doesn't work here because the players leave the array when being teleported which
    means that the array length changes *while* being iterated and produces incorrect results.  As a solution we're gonna
    use the Touching array and back the index up after each successful port. */

	for ( idx = Touching.length-1 ; idx >= 0 ; idx -- )
	{
        Bootee = KFHumanPawn(Touching[idx]);
        if(Bootee == none)
        {
            if(Touching[idx].IsA('KF_StoryInventoryPickup'))
            {
                Touching[idx].SetLocation(TelList[Rand(TelList.length)].Location + (vect(0,0,1) * Touching[idx].CollisionHeight)) ;
                Touching[idx].SetPhysics(PHYS_Falling);
                Touching[idx].SetOwner(Touching[idx].Owner);    // to force NetDirty
            }

            continue ;
        }

//       log(self@"CONTROLLERLIST :: "@Bootee);

        NumTouching ++ ;

		if( PlayerController(Bootee.Controller)!=none )
		{
			PlayerController(Bootee.Controller).ReceiveLocalizedMessage(Class'KFMainMessages');
			PlayerController(Bootee.Controller).ClientCloseMenu(true, true);
		}

		// Teleport to a random teleporter in this local area, if more than one pick random.
		i = Rand(UnusedSpots.Length);

		if ( Bootee.IsA('Pawn') )
			Bootee.PlayTeleportEffect(false, true);

        bBooted = UnusedSpots[i].Accept( Bootee, self ) ;
		if(bBooted)
		{
            NumBooted ++;
            UnusedSpots.Remove(i,1);   // someone is being teleported here. We can't have the next guy spawning on top of him.
        }

//		log(" Successful Boot ? : "@bBooted);
	}

	bResult = NumBooted >= NumTouching;

	Return bResult;
}

function OpenShop()
{
	local Actor A;
	local int i,l;

	if( bCurrentlyOpen )
		return;
	bCurrentlyOpen = True;
	if( !bInitTriggerActs )
	{
		bInitTriggerActs = True;
		if( Event!='' )
		{
			foreach DynamicActors(Class'Actor',A,Event)
				TriggeringActors[TriggeringActors.Length] = A;
		}
	}
	l = TriggeringActors.Length;
	for( i=0; i<l; i++ )
		TriggeringActors[i].Trigger(Self,None);
}

function CloseShop()
{
	local int i,l;

	if( !bCurrentlyOpen )
		return;
	bCurrentlyOpen = False;
	l = TriggeringActors.Length;
	for( i=0; i<l; i++ )
		TriggeringActors[i].Trigger(Self,None);
}

function InitTriggerActors()
{
	local Actor A;

	if( !bInitTriggerActs )
	{
		bInitTriggerActs = True;
		if( Event!='' )
		{
			foreach DynamicActors(Class'Actor',A,Event)
				TriggeringActors[TriggeringActors.Length] = A;
		}
	}
}

defaultproperties
{
     EnabledProbability=1.000000
}
