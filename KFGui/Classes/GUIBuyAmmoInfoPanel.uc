class GUIBuyAmmoInfoPanel extends GUIBuyInfoPanel;

var automated GUIWeaponImage i_weapBG;    //Picture of ammo!
var automated GUILabel l_name,l_clipcost,l_fillcost,l_clips;

function Display(GUIBuyable newWeapon)
{
/*	local BuyableAmmo b;
	b = BuyableAmmo(newWeapon);
	if(b == None)
	{
		l_name.Caption = "";
		l_clipcost.Caption="";
		l_fillcost.Caption="";
		l_clips.Caption="";
	} else
	{
		l_name.Caption = b.ItemName;
		l_clipcost.Caption = "Clip cost:"@(b.Cost);
		l_fillcost.Caption = "Full Ammo:"@(b.Cost*B.BuyMoreClips());
		l_clips.Caption = "Have:"@B.NumClips()@"clips";
	}
	i_weapBG.ChangeToWeapon(b);
*/
}

defaultproperties
{
}
