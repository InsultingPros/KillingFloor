//=============================================================================
// SeveredHead
//=============================================================================
// Detached head gib class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class SeveredHead extends SeveredAppendage;

defaultproperties
{
     HitSound=SoundGroup'KF_EnemyGlobalSnd.Gibs_Small'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'EffectsSM.PlayerGibbs.Ger_Tunic_Arm'
     CollisionRadius=6.000000
     CollisionHeight=4.000000
}
