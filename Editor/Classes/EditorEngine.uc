//=============================================================================
// EditorEngine: The UnrealEd subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class EditorEngine extends Engine
	native
	noexport
	transient;

#exec Texture Import File=Textures\Bad.pcx
#exec Texture Import File=Textures\BadHighlight.pcx
#exec Texture Import File=Textures\Bkgnd.pcx
#exec Texture Import File=Textures\BkgndHi.pcx
#exec Texture Import File=Textures\MaterialArrow.pcx MASKED=1
#exec Texture Import File=Textures\MaterialBackdrop.pcx

#exec NEW StaticMesh File="models\TexPropCube.Ase" Name="TexPropCube"
#exec NEW StaticMesh File="models\TexPropSphere.Ase" Name="TexPropSphere"

// Objects.
var const level       Level;
var const model       TempModel;
var const texture     CurrentTexture;
var const staticmesh  CurrentStaticMesh;
var const mesh		  CurrentMesh;
var const class       CurrentClass;
var const transbuffer Trans;
var const textbuffer  Results;
var const int         Pad[8];

// Textures.
var const texture Bad, Bkgnd, BkgndHi, BadHighlight, MaterialArrow, MaterialBackdrop;

// Used in UnrealEd for showing materials
var staticmesh	TexPropCube;
var staticmesh	TexPropSphere;

// Toggles.
var const bool bFastRebuild, bBootstrapping;

// Other variables.
var const config int AutoSaveIndex;
var const int AutoSaveCount, Mode, TerrainEditBrush, ClickFlags;
var const float MovementSpeed;
var const package PackageContext;
var const vector AddLocation;
var const plane AddPlane;

// Misc.
var const array<Object> Tools;
var const class BrowseClass;

// Grid.
var const int ConstraintsVtbl;
var(Grid) config bool GridEnabled;
var(Grid) config bool SnapVertices;
var(Grid) config float SnapDistance;
var(Grid) config vector GridSize;

// Rotation grid.
var(RotationGrid) config bool RotGridEnabled;
var(RotationGrid) config rotator RotGridSize;

// Advanced.
var(Advanced) config bool UseSizingBox;
var(Advanced) config bool UseAxisIndicator;
var(Advanced) config float FovAngleDegrees;
var(Advanced) config bool GodMode;
var(Advanced) config bool AutoSave;
var(Advanced) config byte AutosaveTimeMinutes;
var(Advanced) config string GameCommandLine;
var(Advanced) globalconfig array<string> EditPackages;
var(Advanced) globalconfig array<string> CutdownPackages;
var(Advanced) config bool AlwaysShowTerrain;
var(Advanced) config bool UseActorRotationGizmo;
var(Advanced) config bool LoadEntirePackageWhenSaving;
var(Advanced) config bool ShowIntWarnings; // gam

defaultproperties
{
     Bad=Texture'Editor.Bad'
     Bkgnd=Texture'Editor.Bkgnd'
     BkgndHi=Texture'Editor.BkgndHi'
     BadHighlight=Texture'Editor.BadHighlight'
     MaterialArrow=Texture'Editor.MaterialArrow'
     MaterialBackdrop=Texture'Editor.MaterialBackdrop'
     TexPropCube=StaticMesh'Editor.TexPropCube'
     TexPropSphere=StaticMesh'Editor.TexPropSphere'
     AutoSaveIndex=6
     GridEnabled=True
     SnapDistance=1.000000
     GridSize=(X=4.000000,Y=4.000000,Z=4.000000)
     RotGridEnabled=True
     RotGridSize=(Pitch=1024,Yaw=1024,Roll=1024)
     UseSizingBox=True
     UseAxisIndicator=True
     FovAngleDegrees=90.000000
     GodMode=True
     AutoSave=True
     AutosaveTimeMinutes=5
     GameCommandLine="-log"
     EditPackages(0)="Core"
     EditPackages(1)="Engine"
     EditPackages(2)="Fire"
     EditPackages(3)="Editor"
     EditPackages(4)="UnrealEd"
     EditPackages(5)="IpDrv"
     EditPackages(6)="UWeb"
     EditPackages(7)="GamePlay"
     EditPackages(8)="UnrealGame"
     EditPackages(9)="XGame"
     EditPackages(10)="XInterface"
     EditPackages(11)="XAdmin"
     EditPackages(12)="XWebAdmin"
     EditPackages(13)="GUI2K4"
     EditPackages(14)="xVoting"
     EditPackages(15)="UTV2004c"
     EditPackages(16)="UTV2004s"
     EditPackages(17)="ROEffects"
     EditPackages(18)="ROEngine"
     EditPackages(19)="ROInterface"
     EditPackages(20)="Old2k4"
     EditPackages(21)="KFMod"
     EditPackages(22)="KFChar"
     EditPackages(23)="KFGui"
     EditPackages(24)="GoodKarma"
     EditPackages(25)="KFMutators"
     EditPackages(26)="KFStoryGame"
     EditPackages(27)="KFStoryUI"
     EditPackages(28)="SideShowScript"
     EditPackages(29)="FrightScript"
     CutdownPackages(0)="Core"
     CutdownPackages(1)="Editor"
     CutdownPackages(2)="Engine"
     CutdownPackages(3)="Fire"
     CutdownPackages(4)="GamePlay"
     CutdownPackages(5)="GUI2K4"
     CutdownPackages(6)="IpDrv"
     CutdownPackages(7)="Onslaught"
     CutdownPackages(8)="UnrealEd"
     CutdownPackages(9)="UnrealGame"
     CutdownPackages(10)="UWeb"
     CutdownPackages(11)="XAdmin"
     CutdownPackages(12)="XEffects"
     CutdownPackages(13)="XInterface"
     CutdownPackages(14)="XPickups"
     CutdownPackages(15)="XWebAdmin"
     CutdownPackages(16)="XVoting"
     CacheSizeMegs=32
}
