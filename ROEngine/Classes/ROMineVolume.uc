//=============================================================================
// ROMineVolume
//=============================================================================
// Mine field volume that can be used to protect spawns and to section
// of areas of the map you don't want poeple to enter
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROMineVolume extends Volume;

var()	float KillTime; 					// How long someone can be in the volume before being killed
var()	float WarnInterval;                 // How often to play the warning message
var()   localized string  WarningMessage;   // Localized warning message string

enum EMineKillStyle   						// Kill style
{
    KS_All,
	KS_Axis,
	KS_Allies,
};

var() EMineKillStyle MineKillStyle;
var	sound ExplosionSound;
var class<DamageType>	DamageType;
var int	Damage;
var	Info PainTimer;

var() 	bool			bUsesSpawnAreas;// Activated/Deactivated based on a spawn area associated with a tag

var 	bool			bActive;		// Whether this ammo resupply volume is active

function PostBeginPlay()
{
	Super.PostBeginPlay();

    if( !bUsesSpawnAreas )
    	Activate();
}


simulated event touch(Actor Other)
{
	local Pawn P;
	local int PawnTeam;

	if ( Other == None || !bActive)
		return;

	PawnTeam = -1;

	if ( Role == ROLE_Authority )
	{
        P = Pawn(Other);

		if ( P != None && P.PlayerReplicationInfo != none)
		{
			PawnTeam = P.PlayerReplicationInfo.Team.TeamIndex;

			if( MineKillStyle == KS_All || PawnTeam == AXIS_TEAM_INDEX && MineKillStyle == KS_Axis ||
				PawnTeam == ALLIES_TEAM_INDEX && MineKillStyle == KS_Allies )
			{
				if ( PainTimer == None )
					PainTimer = Spawn(class'VolumeTimer', self);

				if( ( Level.TimeSeconds - P.MineAreaWarnTime >= WarnInterval ) && P.Controller != none && PlayerController(P.Controller) != none )
				{
					PlayerController(P.Controller).ReceiveLocalizedMessage(class'ROMineFieldMsg',,,,self);
					P.MineAreaWarnTime = Level.TimeSeconds;
				}

                P.MineAreaEnterTime = Level.TimeSeconds;
				PainTimer.SetTimer(0.5,true);
			}
		}
	}
}


/*
TimerPop
damage touched actors if pain causing.
since PhysicsVolume is static, this function is actually called by a volumetimer
*/
function TimerPop(VolumeTimer T)
{
	local Pawn P;
	local bool bFound;
	local int PawnTeam;

    if(!bActive)
    {
		return;
    }

	if ( T == PainTimer )
	{
		foreach TouchingActors(class'Pawn', P)
			if ( !P.bDeleteMe && P.Health > 0 )
			{
 				PawnTeam = -1;

            	if( ROVehicle(P) != none )
            		PawnTeam = ROVehicle(P).GetTeamNum();
				else
					PawnTeam = P.PlayerReplicationInfo.Team.TeamIndex;

				if( MineKillStyle == KS_All || PawnTeam == AXIS_TEAM_INDEX && MineKillStyle == KS_Axis ||
					PawnTeam == ALLIES_TEAM_INDEX && MineKillStyle == KS_Allies )
				{
					if( ( Level.TimeSeconds - P.MineAreaWarnTime >= WarnInterval ) && P.Controller != none && PlayerController(P.Controller) != none )
					{
						PlayerController(P.Controller).ReceiveLocalizedMessage(class'ROMineFieldMsg',,,,self);
						P.MineAreaWarnTime = Level.TimeSeconds;
					}
					if( Level.TimeSeconds - P.MineAreaEnterTime >= KillTime )
					{
						P.TakeDamage(Damage, None, Location, vect(0,0,0), DamageType);

                        if (ExplosionSound != None)
							PlaySound(ExplosionSound,, 2.5 * TransientSoundVolume);

						Spawn(class'GrenadeExplosion',,, P.Location - (P.CollisionHeight * vect(0,0,1)));
					}
					bFound = true;
				}
			}

		if ( !bFound )
			PainTimer.Destroy();
	}
}

function Activate()
{
	bActive = True;
}

function Deactivate()
{
    bActive = False;
}

function Reset()
{
    if( !bUsesSpawnAreas )
    	Activate();
}

defaultproperties
{
     KillTime=2.000000
     WarnInterval=3.000000
     WarningMessage="Warning: you have entered a minefield!!!"
     DamageType=Class'ROEngine.ROMineDamType'
     Damage=1500
}
