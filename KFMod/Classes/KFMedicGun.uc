//=============================================================================
// MedicGun
//=============================================================================
// Medic Gun Class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class KFMedicGun extends KFWeapon;

var ()      int         HealBoostAmount;// How much we heal a player by default with the heal dart

var localized   string  SuccessfulHealMessage;

var         int         HealAmmoCharge; // Current healing charger
var         float       RegenTimer;     // Tracks regeneration
Const MaxAmmoCount=500;                 // Maximum healing charge count
var ()      float       AmmoRegenRate;  // How quickly the healing charge regenerates

replication
{
    // Things the server should send to the client.
    reliable if( Role==ROLE_Authority )
        HealAmmoCharge;

 	reliable if( Role == ROLE_Authority )
		ClientSuccessfulHeal;
}

// The server lets the client know they successfully healed someone
simulated function ClientSuccessfulHeal(String HealedName)
{
    if( PlayerController(Instigator.Controller) != none )
    {
        PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage$HealedName, 'CriticalEvent');
    }
}

// Return a float value representing the current healing charge amount
simulated function float ChargeBar()
{
	return FClamp(float(HealAmmoCharge)/float(MaxAmmoCount),0,1);
}

simulated function Tick(float dt)
{
	if ( Level.NetMode!=NM_Client && HealAmmoCharge < MaxAmmoCount && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + AmmoRegenRate;

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			HealAmmoCharge += 10 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetSyringeChargeRate(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
		}
		else
		{
			HealAmmoCharge += 10;
		}
		if ( HealAmmoCharge > MaxAmmoCount )
		{
			HealAmmoCharge = MaxAmmoCount;
		}
	}
}

defaultproperties
{
}
