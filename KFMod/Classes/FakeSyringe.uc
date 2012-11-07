//=============================================================================
// Fake Syringe Inventory class. This is a hack for taking vids, because the
// color correction borks up if you aren't rendering a first person weapon.
//=============================================================================
class FakeSyringe extends Syringe;

defaultproperties
{
     HudImage=Texture'KillingFloorHUD.HUD.Hud_Shield'
     SelectedHudImage=Texture'KillingFloorHUD.HUD.Hud_Weight'
     bKFNeverThrow=False
     GroupOffset=3
     PlayerViewOffset=(X=-500.000000)
}
