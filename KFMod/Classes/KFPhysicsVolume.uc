//=============================================================================
// KFPhysicsVolume
// AI Pawns within this volume will have their JumpZ values scaled based on
// the volume's gravity.
//=============================================================================
class KFPhysicsVolume extends PhysicsVolume;

var() float JumpZManualOverride;		// Set the AI Pawn JumpZ to this value and do not scale by gravity. 0 = No override
var() bool bScaleAIJumpZOnEntry;        // Scale the AI Pawn JumpZ by this volume's Z gravity when entered.
var() bool bRestoreAIJumpZOnExit;		// Restore the AI Pawn default JumpZ when the volume is exited.
var() float JumpZScaleFactor;			// Optionally tweak the JumpZ gravity scaled value (1.0 = no change)
var() bool bLogDebugInfo;			    // Logs entry and exit events and JumpZ values.
var() float MaxJumpZInVolumeScale;		// No AI will be allowed to have a JumpZ scaled higher than this value.
var() bool bScaleJumpZByMass;           // If true, will scale JumpZ by mass.
var() float AdditionalJumpZBloat;		// If this is a bloat, this value will be added to what was the final JumpZ adjustment

// Optionally scale the AI Pawn's JumpZ value based on this volume's gravity.
simulated event PawnEnteredVolume( Pawn Other )
{
	super.PawnEnteredVolume( Other );
	if( KFMonster( Other ) != none )
	{
		if( bScaleAIJumpZOnEntry )
		{
			if( bLogDebugInfo )
			{
				log( self$" --- "$Other$" entered volume, adjusting original JumpZ: "$Other.JumpZ$" original mass "$Other.Mass );
			}
			if( JumpZManualOverride > 0 )
			{
				// Optionally force the JumpZ to a specific value
				Other.JumpZ = JumpZManualOverride;			
			}
			else if( Other.JumpZ == Other.default.JumpZ )
			{
				if( bScaleJumpZByMass && ( Other.Mass > Other.default.JumpZ ) )
				{
					Other.JumpZ *= Max( MaxJumpZInVolumeScale, ( Other.Mass / Other.JumpZ ) );
				}
				else 
				{
					// Scale the JumpZ based on gravity and apply optional scale to refine it.
					Other.JumpZ *= ( sqrt( Gravity.Z / Default.Gravity.Z ) * JumpZScaleFactor );
				}
				if( AdditionalJumpZBloat > 0 )
				{
					if( Other.IsA( 'ZombieBloat' ) )
					{
						Other.JumpZ += AdditionalJumpZBloat;
					}
				}				
			}			
		}
	}
}

// Optionally restore the AI Pawn's JumpZ when it exits the volume (assumes the AI Pawn's default.JumpZ is the value to use)
simulated event PawnLeavingVolume( Pawn Other )
{
	super.PawnLeavingVolume( Other );
	if( KFMonster( Other ) != none )
	{
		if( bRestoreAIJumpZOnExit )
		{
			// Restore the Pawn's default JumpZ value.
			Other.JumpZ = Other.default.JumpZ;		
		}
	}
}

defaultproperties
{
     bScaleAIJumpZOnEntry=True
     JumpZScaleFactor=1.000000
     MaxJumpZInVolumeScale=1.500000
}
