//-----------------------------------------------------------
// Changed to never in game spawned object! Only an information holding object.
// - .:..:
//-----------------------------------------------------------
class DoorExplode extends Object
	Abstract;

var() float ShrapnelAreaHeight;
var() float ShrapnelAreaWidth;
var() float GibSpeed;
var() int NumPieces;
var() int NumGibClasses;
var() array< class<DoorGib> > DoorGibClasses;
var() class<emitter> DoorDustClass;
var() float SpreadFactor;
var() sound BoomSound;
var() StaticMesh CachedDoorStatic;
var() Float CachedDoorDrawScale;
var() vector CachedDoorDrawScale3D;

#exec OBJ LOAD FILE="..\Sounds\PatchSounds.uax"

simulated static function Boom( Actor Other, rotator SpawnRot )
{
	local int i;
	local vector DGVec, Perpendicular,X,Y,Z;

	Other.Spawn(Default.DoorDustClass,,,Other.Location+vect(0,0,1) * Default.ShrapnelAreaHeight * 0.5, Other.Rotation );

	Perpendicular = Normal(vector(Other.rotation) cross vect(0, 0, 1));
	GetAxes(Other.Rotation,X,Y,Z);

	for( i=0; i<Default.NumPieces; ++i )
	{
		DGVec = Other.Location+X*(Default.ShrapnelAreaWidth*FRand()-Default.ShrapnelAreaWidth/2)
		 +Y*(Default.ShrapnelAreaWidth*FRand()-Default.ShrapnelAreaWidth/2)
		 +Z*(Default.ShrapnelAreaHeight*FRand()-Default.ShrapnelAreaHeight/2);
		SpawnDoorGib(Other,DGVec,RotRand(True),0.2);
	}
	Other.PlaySound(Default.BoomSound, SLOT_None, 255, false, 600,,false);
}
simulated static function SpawnDoorGib( Actor Spawner, Vector SLoc, Rotator SRot, float GibPerterbation )
{
	local Actor aDoorGib;

	aDoorGib = Spawner.Spawn(Default.DoorGibClasses[Rand(Default.DoorGibClasses.Length)],,,SLoc,SRot);
	if( aDoorGib == none )
		return;
	aDoorGib.RemoteRole = ROLE_None;
	aDoorGib.SetStaticMesh(Spawner.StaticMesh);
	aDoorGib.SetDrawScale(Spawner.DrawScale);
	aDoorGib.SetDrawScale3D(Spawner.DrawScale3D);
	aDoorGib.Skins = Spawner.Skins;
	aDoorGib.Velocity = (vector(SRot)+ Default.SpreadFactor*Normal(SLoc-Spawner.Location) )*Default.GibSpeed;
}

defaultproperties
{
     GibSpeed=256.000000
     NumPieces=1
     NumGibClasses=1
     DoorGibClasses(0)=Class'KFMod.DoorGibMetalA'
     SpreadFactor=0.300000
     BoomSound=Sound'PatchSounds.MetalCrash'
}
