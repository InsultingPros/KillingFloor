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

function Touch( Actor Other )
{
	if( Pawn(Other)!=None && PlayerController(Pawn(Other).Controller)!=None && KFGameType(Level.Game)!=None && !KFGameType(Level.Game).bWaveInProgress )
	{
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
	local int i;
	local bool bResult;

	if( !bTelsInit )
		InitTeleports();
	if( !bHasTeles )
		Return False; // Wtf?

	foreach TouchingActors(class'KFHumanPawn', Bootee)
	{
		if( PlayerController(Bootee.Controller)!=none )
		{
			PlayerController(Bootee.Controller).ReceiveLocalizedMessage(Class'KFMainMessages');
			PlayerController(Bootee.Controller).ClientCloseMenu(true, true);
		}

		// Teleport to a random teleporter in this local area, if more than one pick random.
		i = Rand(TelList.Length);
		if ( Bootee.IsA('Pawn') )
			Bootee.PlayTeleportEffect(false, true);
		TelList[i].Accept( Bootee, self );
		bResult = True;
	}
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
