// Blame me for doing "Team-Kill" attempt!
Class FakePlayerPawn extends Pawn
	NotPlaceable;

Auto state DoNothing
{
Ignores Trigger,Bump,HitWall,HeadVolumeChange,PhysicsVolumeChange,Falling,BreathTimer,Timer,TakeDamage,Died,TurnOff,PostRender2D;
}

defaultproperties
{
     bNoTeamBeacon=True
     Health=0
     DrawType=DT_None
     bHidden=True
     RemoteRole=ROLE_None
     bMovable=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bCollideWorld=False
}
