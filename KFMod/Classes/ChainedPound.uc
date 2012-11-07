class ChainedPound extends Decoration;

#exec OBJ LOAD FILE=KFCharacters.utx

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var bool bWasNeedled; // Has he been needled already?
var byte NetAnimUdp;

//#exec OBJ LOAD FILE=KFCharactersB.ukx

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		NetAnimUdp;
}

simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	LoopAnim('Idle');
	if( !Class'UnrealPawn'.Default.bPlayerShadows )
		Return;
	PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
	PlayerShadow.ShadowActor = self;
	PlayerShadow.bBlobShadow = Class'UnrealPawn'.Default.bBlobShadow;
	PlayerShadow.LightDirection = Normal(vect(1,1,3));
	PlayerShadow.LightDistance = 320;
	PlayerShadow.MaxTraceDistance = 350;
	PlayerShadow.InitShadow();
	PlayerShadow.bShadowActive = true;
}

// Triggered / Secondary Anim
function Trigger( actor Other, pawn EventInstigator )
{
	if (!bWasNeedled)
	{
		if( Level.NetMode!=NM_DedicatedServer )
			PlayAnim('Needled',,0.1); //Breakout
		bWasNeedled = true;
		NetAnimUdp = 1;
	}
	else
	{
		if( Level.NetMode!=NM_DedicatedServer )
			PlayAnim('Breakout',,0.1);
		NetAnimUdp++;
		if( NetAnimUdp>250 )
			NetAnimUdp = 2;
	}
}
function OpenEyes()
{
	Skins[0] = Texture 'KFCharacters.PoundSkin';
}

simulated function PostNetBeginPlay()
{
	NetAnimUdp = 0;
	bNetNotify = True;
}
simulated function PostNetReceive()
{
	if( NetAnimUdp!=0 )
	{
		if( NetAnimUdp==1 )
			PlayAnim('Needled',,0.1);
		else PlayAnim('Breakout',,0.1);
		NetAnimUdp = 0;
	}
}

defaultproperties
{
     DrawType=DT_StaticMesh
     bStatic=False
     bNoDelete=True
     bStasis=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'KFCharactersB.LabPound'
     bMovable=False
     bCanBeDamaged=False
     bShouldBaseAtStartup=False
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
}
