//=============================================================================
// ROBulletHitEffect
//=============================================================================
// Base hit effect class for bullets
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
// $Id: ROBulletHitEffect.uc,v 1.8 2004/02/24 02:11:11 bwright Exp $:
//=============================================================================

class ROBulletHitEffect extends ROHitEffect;

#exec OBJ LOAD FILE=..\Sounds\ProjectileSounds.uax

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HitEffects(0)=(HitDecal=Class'ROEffects.BulletHoleDirt',HitEffect=Class'ROEffects.ROBulletHitRockEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Dirt')
     HitEffects(1)=(HitDecal=Class'ROEffects.BulletHoleConcrete',HitEffect=Class'ROEffects.ROBulletHitRockEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Asphalt')
     HitEffects(2)=(HitDecal=Class'ROEffects.BulletHoleDirt',HitEffect=Class'ROEffects.ROBulletHitDirtEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Dirt')
     HitEffects(3)=(HitDecal=Class'ROEffects.BulletHoleMetal',HitEffect=Class'ROEffects.ROBulletHitMetalEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Metal')
     HitEffects(4)=(HitDecal=Class'ROEffects.BulletHoleWood',HitEffect=Class'ROEffects.ROBulletHitWoodEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Wood')
     HitEffects(5)=(HitDecal=Class'ROEffects.BulletHoleDirt',HitEffect=Class'ROEffects.ROBulletHitGrassEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Grass')
     HitEffects(6)=(HitDecal=Class'ROEffects.BulletHoleFlesh',HitEffect=Class'ROEffects.ROBulletHitFleshEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Mud')
     HitEffects(7)=(HitDecal=Class'ROEffects.BulletHoleIce',HitEffect=Class'ROEffects.ROBulletHitIceEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Glass')
     HitEffects(8)=(HitDecal=Class'ROEffects.BulletHoleSnow',HitEffect=Class'ROEffects.ROBulletHitSnowEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Snow')
     HitEffects(9)=(HitEffect=Class'ROEffects.ROBulletHitWaterEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Snow')
     HitEffects(10)=(HitDecal=Class'ROEffects.BulletHoleIce',HitEffect=Class'ROEffects.ROBreakingGlass',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Glass')
     HitEffects(11)=(HitDecal=Class'ROEffects.BulletHoleConcrete',HitEffect=Class'ROEffects.ROBulletHitGravelEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Gravel')
     HitEffects(12)=(HitDecal=Class'ROEffects.BulletHoleConcrete',HitEffect=Class'ROEffects.ROBulletHitConcreteEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Asphalt')
     HitEffects(13)=(HitDecal=Class'ROEffects.BulletHoleWood',HitEffect=Class'ROEffects.ROBulletHitWoodEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Wood')
     HitEffects(14)=(HitDecal=Class'ROEffects.BulletHoleSnow',HitEffect=Class'ROEffects.ROBulletHitMudEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Mud')
     HitEffects(15)=(HitDecal=Class'ROEffects.BulletHoleMetalArmor',HitEffect=Class'ROEffects.ROBulletHitMetalArmorEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Metal')
     HitEffects(16)=(HitDecal=Class'ROEffects.BulletHoleConcrete',HitEffect=Class'ROEffects.ROBulletHitPaperEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Wood')
     HitEffects(17)=(HitDecal=Class'ROEffects.BulletHoleCloth',HitEffect=Class'ROEffects.ROBulletHitClothEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Dirt')
     HitEffects(18)=(HitDecal=Class'ROEffects.BulletHoleMetal',HitEffect=Class'ROEffects.ROBulletHitRubberEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Dirt')
     HitEffects(19)=(HitDecal=Class'ROEffects.BulletHoleDirt',HitEffect=Class'ROEffects.ROBulletHitMudEffect',HitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Mud')
}
