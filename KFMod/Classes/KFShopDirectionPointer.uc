class KFShopDirectionPointer extends Effects
	Transient;

#exec OBJ LOAD FILE=..\Textures\Engine.utx
//#exec OBJ LOAD FILE=..\StaticMeshes\EffectsSM.usx
#exec OBJ LOAD FILE=..\StaticMeshes\DebugObjects.usx

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DebugObjects.Arrows.debugarrow1'
     bHidden=True
     bStasis=True
     DrawScale=0.250000
}
