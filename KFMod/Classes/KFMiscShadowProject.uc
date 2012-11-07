Class KFMiscShadowProject extends ShadowProjector;

var bool bDoUpdate;
var Actor OwnerProj;

function Tick(float DeltaTime)
{
	DetachProjector(true);
	if( bDoUpdate )
	{
		if( ShadowTexture.Invalid )
			Destroy();
		else
		{
			SetRotation(Rotator(-LightDirection));
			ShadowTexture.Dirty = true;
			AttachProjector();
			bDoUpdate = false;
		}
	}
}
function UpdateShadow();

defaultproperties
{
}
