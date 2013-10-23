/*
	--------------------------------------------------------------
	KF_Roulette_Ball
	--------------------------------------------------------------

	Bounce Bounce.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_Roulette_Ball extends Actor
placeable;

/* Animation to play while this ball is rolling */
var name    RollAnim;

function StartRolling()
{
    bFixedRotationDir = true;
    bRotateToDesired = false;

    if(RollAnim != '')
    {
        PlayAnim(RollAnim,1.f,0.1f);
    }
}

function StopRolling()
{
    bFixedRotationDir = false;
    bRotateToDesired = true;
}

defaultproperties
{
     RollAnim="Ball_Roll"
     DrawType=DT_Mesh
     bNoDelete=True
     Physics=PHYS_Rotating
     Mesh=SkeletalMesh'Pier_anim.RTL_Ball'
     DrawScale=0.750000
     PrePivot=(Z=-5.000000)
     Skins(0)=Texture'Engine.DecoPaint'
     RotationRate=(Yaw=19000)
}
