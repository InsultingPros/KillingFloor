/*
	--------------------------------------------------------------
	KFLevelRules_Story
	--------------------------------------------------------------

	Extended LevelRules info for use in 'Story' style missions .
	Can modify player starting equipment, health, cash , etc.
	Also stores a list of Objectives the player must complete to
	be victorious.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KFLevelRules_Story extends KFLevelRules
hidecategories(Sound,Events) ;

#exec OBJ LOAD FILE=KFStoryGame_Tex.utx

/* array of Objectives, arranged by LD in the order he wants them completed */
var(Rules_Objectives)     	array<name>					 StoryObjectives;

/* should the first objective in the StoryObjectives array activate as soon as the match begins ? */
var(Rules_Objectives)       bool                         bAutoStartObjectives;

/* Amount of dosh to start players out with in story mode */
var(Rules_Cash)			    int							 StartingCashSum;

/* A modifier for the amount of cash players receive from killing zombies.  ie. at 0.f they will not receive anything */
var(Rules_Cash)			    float						 CashReward_ZEDKills_Modifier;

/* A modifier for the amount of cash players lose when they die */
var(Rules_Cash)			    float						 CashPenalty_Death_Modifier;

/* absolute maximum number of zombies we can have in this story map at one time */
var(Rules_Monsters)			int						     MaxEnemiesAtOnce;

/* should the game kill off ZEDs which haven't been seen by players for a while?  */
var(Rules_Monsters)         bool                         bAutoKillStragglers;

/* Auto Kill threshold if bAutoKilLStragglers is true */
var(Rules_MonsterS)         int                          MaxStragglers;

/* should bots be allowed to spawn ? */
var(Rules_Bots)				bool						 bAllowBots;

/* Textures to display on the HUD when the match is over */
var(Rules_HUD) 				Material 					 VictoryMaterial,DefeatMaterial;

/* If a team is restarted after dying during a story mission these are the actor types we need to reset*/
var(Rules_CheckPoints)	    array<class>		         CheckpointResetClasses ;

/* If true the weapon / item pickups in the map will be randomly spawned based on difficulty - like in a normal KF match */
var(Rules_Equipment)        bool                         bRandomizeWeaponPickups;

// Amount of starting HP for all players
var(Rules_Equipment)        int                          PlayerStartHealth;

// Amount of starting armor for all players.
var(Rules_Equipment)        int                          PlayerStartArmor;

// Defines starting equipment for players
var(Rules_Equipment)        array< Class<Inventory> >    RequiredPlayerEquipment;

/* if true, allow high level players to spawn with their 'default' gear */
var(Rules_Equipment)		bool						 bAllowPerkStartingWeaps;

// Enable / Disable Cash display on HUD .
var(Rules_HUD)              bool                         bShowCash;

var(Rules_HUD)              name                         HUDStyle;


function ModifyPlayer( Pawn Other )
{
	if( PlayerStartHealth>0 )
		Other.Health = PlayerStartHealth;
	if( PlayerStartArmor>0 )
		Other.ShieldStrength = PlayerStartArmor;
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
     bAutoStartObjectives=True
     StartingCashSum=250
     CashReward_ZEDKills_Modifier=1.000000
     CashPenalty_Death_Modifier=1.000000
     MaxEnemiesAtOnce=32
     bAutoKillStragglers=True
     MaxStragglers=5
     VictoryMaterial=Combiner'KFMapEndTextures.VictoryCombiner'
     DefeatMaterial=Combiner'KFMapEndTextures.DefeatCombiner'
     CheckpointResetClasses(0)=Class'KFMod.ZombieVolume'
     CheckpointResetClasses(1)=Class'Gameplay.ScriptedSequence'
     CheckpointResetClasses(2)=Class'Engine.Pickup'
     CheckpointResetClasses(3)=Class'Engine.Pawn'
     CheckpointResetClasses(4)=Class'Engine.Triggers'
     CheckpointResetClasses(5)=Class'Gameplay.TriggerLight'
     CheckpointResetClasses(6)=Class'Engine.BlockingVolume'
     CheckpointResetClasses(7)=Class'Engine.Decoration'
     CheckpointResetClasses(8)=Class'KFStoryGame.KF_StoryWaveDesigner'
     CheckpointResetClasses(9)=Class'KFStoryGame.StaticMeshActor_Hideable'
     CheckpointResetClasses(10)=Class'KFStoryGame.KF_StoryWaveDesigner'
     bRandomizeWeaponPickups=True
     RequiredPlayerEquipment(0)=Class'KFMod.Single'
     RequiredPlayerEquipment(1)=Class'KFMod.Syringe'
     RequiredPlayerEquipment(2)=Class'KFMod.Welder'
     RequiredPlayerEquipment(3)=Class'KFMod.Frag'
     RequiredPlayerEquipment(4)=Class'KFMod.knife'
     bAllowPerkStartingWeaps=True
     bShowCash=True
     Texture=Texture'KFStoryGame_Tex.Editor.KFRules_Ico'
}
