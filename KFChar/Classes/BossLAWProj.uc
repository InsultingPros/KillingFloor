class BossLAWProj extends LAWProj;

//-----------------------------------------------------------------------------
// PostBeginPlay
//-----------------------------------------------------------------------------

simulated function PostBeginPlay()
{
	// Difficulty Scaling
	if (Level.Game != none)
	{
        //log(self$" Beginning ground speed "$default.GroundSpeed);

        // If you are playing by yourself, greatly reduce the rocket damage
        if( Level.Game.NumPlayers == 1 )
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                Damage = default.Damage * 0.25;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                Damage = default.Damage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 5.0 )
            {
                Damage = default.Damage * 1.15;
            }
            else // Hardest difficulty
            {
                Damage = default.Damage * 1.3;
            }
        }
        else
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                Damage = default.Damage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                Damage = default.Damage * 1.0;
            }
            else if( Level.Game.GameDifficulty < 5.0 )
            {
                Damage = default.Damage * 1.15;
            }
            else // Hardest difficulty
            {
                Damage = default.Damage * 1.3;
            }
        }
	}

    super.PostBeginPlay();
}

defaultproperties
{
     ArmDistSquared=0.000000
     Damage=200.000000
     MyDamageType=Class'KFMod.DamTypeFrag'
}
