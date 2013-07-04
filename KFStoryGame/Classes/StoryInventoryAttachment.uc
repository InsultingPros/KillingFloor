/*
	--------------------------------------------------------------
	StoryInventoryAttachment
	--------------------------------------------------------------

    Third person actor which represents a KF_StoryInventoryItem while
    carried by a player.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class StoryInventoryAttachment extends InventoryAttachment;

var KF_StoryInventoryItem StoryOwner;


function InitFor(Inventory I)
{
	Instigator = I.Instigator;

	StoryOwner = KF_StoryInventoryItem(I);
	if(StoryOwner != none)
	{
        SetStaticMesh(StoryOwner.PickupSM);
        LinkMesh(StoryOwner.Mesh);
        AmbientGlow = StoryOwner.AmbientGlow;
        SetDrawScale3D(StoryOwner.DrawScale3D);
        SetDrawScale(StoryOwner.DrawScale);
        SetDrawType(StoryOwner.DrawType);

        // Lighting

        if(StoryOwner.StoryPickupBase != none)
        {
            LightType = StoryOwner.StoryPickupBase.LightType;
            LightBrightness = StoryOwner.StoryPickupBase.LightBrightness;
            LightRadius = StoryOwner.StoryPickupBase.LightRadius;
            LightHue = StoryOwner.StoryPickupBase.lighthue;
            bUseDynamicLights = StoryOwner.StoryPickupBase.bUseDynamicLights;
            LightSaturation = StoryOwner.StoryPickupBase.LightSaturation;
            bDynamicLight = StoryOwner.StoryPickupBase.bDynamicLight;

            bLightChanged = true;
        }
	}
}

defaultproperties
{
     DrawType=DT_StaticMesh
     bActorShadows=True
}
