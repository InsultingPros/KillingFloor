// By : Alex.
// Support for non Survival based gameplay.

class KFSPLevelInfo extends LevelGameRules;

var () int PlayerStartHealth; // Amount of starting HP for all players
var () int PlayerStartArmor; // Amount of starting armor for all players.
var () bool bUseVisionOverlay;  // Enable / disable Zone-Modulated HUD colors .
var () bool bHUDShowCash; // Enable / Disable Cash display on HUD .
var () array< Class<Inventory> > RequiredPlayerEquipment;  // Defines starting equipment for players

var () Array<String> MissionObjectives;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( KFSGameReplicationInfo(Level.GRI)!=None )
		KFSGameReplicationInfo(Level.GRI).KFPLevel = Self;
}
simulated function SetGRI(GameReplicationInfo GRI)
{
	if( KFSGameReplicationInfo(GRI)!=None )
		KFSGameReplicationInfo(GRI).KFPLevel = Self;
}

function ModifyPlayer( Pawn Other )
{
	if( PlayerStartHealth>0 )
		Other.Health = PlayerStartHealth;
	if( PlayerStartArmor>0 )
		Other.AddShieldStrength(PlayerStartArmor);
}
function AddGameInv( Pawn Other )
{
	local int i;
	local Inventory Inv;

	For( i=0; i<RequiredPlayerEquipment.Length; i++ )
	{
		if( RequiredPlayerEquipment[i]==None )
			Continue;
		if( Other.FindInventoryType(RequiredPlayerEquipment[i])==None )
		{
			Inv = Spawn(RequiredPlayerEquipment[i]);
			if( Inv != None )
			{
				Inv.GiveTo(Other);
				if ( Inv != None )
					Inv.PickupFunction(Other);
			}
		}
	}
}

defaultproperties
{
     bUseVisionOverlay=True
     bNoDelete=True
}
