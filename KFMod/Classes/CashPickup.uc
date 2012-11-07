class CashPickup extends Pickup;

var () int CashAmount;
var bool bDroppedCash;  // if true, its been dropped. dont randomize the amount
var float TossTimer;
var Controller DroppedBy;

function GiveCashTo( Pawn Other )
{
	// You all love the mental-mad typecasting XD
	if( !bDroppedCash )
	{
		CashAmount = (rand(0.5 * default.CashAmount) + default.CashAmount) * (KFGameReplicationInfo(Level.GRI).GameDiff  * 0.5) ;
	}
	else if ( Other.PlayerReplicationInfo != none && DroppedBy.PlayerReplicationInfo != none &&
			  ((DroppedBy.PlayerReplicationInfo.Score + float(CashAmount)) / Other.PlayerReplicationInfo.Score) >= 0.50 &&
			  PlayerController(DroppedBy) != none && KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements) != none )
	{
		if ( Other.PlayerReplicationInfo != DroppedBy.PlayerReplicationInfo )
		{
			KFSteamStatsAndAchievements(PlayerController(DroppedBy).SteamStatsAndAchievements).AddDonatedCash(CashAmount);
		}
	}

	if( Other.Controller!=None && Other.Controller.PlayerReplicationInfo!=none )
	{
		Other.Controller.PlayerReplicationInfo.Score += CashAmount;
	}
	AnnouncePickup(Other);
	SetRespawn();
}

//=============================================================================
// Pickup state: this inventory item is sitting on the ground.
auto state Pickup
{
	// When touched by an actor.
	function Touch( actor Other )
	{
		// If touched by a player pawn, let him pick this up.
		if ( ValidTouch(Other) )
		{
			GiveCashTo(Pawn(Other));
		}
	}
}
state FallingPickup
{
	function Touch( actor Other )
	{
		if( ValidTouch(Other) )
			GiveCashTo(Pawn(Other));
	}
}
State FadeOut
{
	function Touch( actor Other )
	{
		if( ValidTouch(Other) )
			GiveCashTo(Pawn(Other));
	}
}

function AnnouncePickup( Pawn Receiver )
{
	Receiver.MakeNoise(0.2);
	if( Receiver.Controller!=None )
	{
		if( PlayerController(Receiver.Controller)!=None )
			PlayerController(Receiver.Controller).ReceiveLocalizedMessage(MessageClass,CashAmount,,,Class);
		else if ( Receiver.Controller.MoveTarget==Self )
		{
			if ( MyMarker!=None )
			{
				Receiver.Controller.MoveTarget = MyMarker;
				Receiver.Anchor = MyMarker;
				Receiver.Controller.MoveTimer = 0.5;
			}
			else Receiver.Controller.MoveTimer = -1.0;
		}
	}
	PlaySound( PickupSound,SLOT_Interact );
}
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return "Found ("$Switch$") Pounds.";
}

defaultproperties
{
     CashAmount=40
     RespawnTime=60.000000
     PickupMessage="You found a wad of cash"
     PickupSound=SoundGroup'KF_InventorySnd.Cash_Pickup'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'22Patch.BankNote'
     Physics=PHYS_Falling
     DrawScale=0.400000
     AmbientGlow=40
     UV2Texture=FadeColor'PatchTex.Common.PickupOverlay'
     TransientSoundVolume=150.000000
     CollisionRadius=20.000000
     CollisionHeight=5.000000
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
