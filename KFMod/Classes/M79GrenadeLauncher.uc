//=============================================================================
// M79 Grenade launcher Inventory class
//=============================================================================
class M79GrenadeLauncher extends KFWeapon;

var     float               ForceZoomOutTime;

//=============================================================================
// Functions
//=============================================================================

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function WeaponTick(float dt)
{
    super.WeaponTick(dt);

    if( ForceZoomOutTime > 0 )
    {
        if( bAimingRifle )
        {
    	    if( Level.TimeSeconds - ForceZoomOutTime > 0 )
    	    {
                ForceZoomOutTime = 0;

            	ZoomOut(false);

            	if( Role < ROLE_Authority)
        			ServerZoomOut(false);
    		}
		}
		else
		{
            ForceZoomOutTime = 0;
		}
	}
}

// Force the weapon out of iron sights shortly after firing so the textured
// scope gets the same disadvantage as the 3d scope
simulated function bool StartFire(int Mode)
{
    if( super.StartFire(Mode) )
    {
        ForceZoomOutTime = Level.TimeSeconds + 0.4;
        return true;
    }

    return false;
}

defaultproperties
{
     MagCapacity=1
     ReloadRate=0.010000
     Weight=4.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M79'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons2_Trip.M79_Trip"
     SkinRefs(0)="KF_Weapons2_Trip_T.Special.M79_cmb"
     SelectSoundRef="KF_M79Snd.M79_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.M79_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M79"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'KFMod.M79Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="A classic Vietnam era grenade launcher. Launches single high explosive grenades."
     DisplayFOV=65.000000
     Priority=55
     InventoryGroup=3
     GroupOffset=11
     PickupClass=Class'KFMod.M79Pickup'
     PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.M79Attachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="M79 Grenade Launcher"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
