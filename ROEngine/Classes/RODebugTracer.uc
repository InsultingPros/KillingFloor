// =================================================================================== *
// RODebugTracer
// Author: Ramm
// =================================================================================== *
//	A small tracer to aid in debugging.
// =================================================================================== */

class RODebugTracer extends actor;

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DebugObjects.Arrows.debugarrow1'
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
