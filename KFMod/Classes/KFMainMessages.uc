class KFMainMessages extends CriticalEventPlus
	abstract;

var(Message) localized string ShopBootMsg, HasWeaponMsg, NoCarryMoreMsg, ShopItBase;

static function string GetString(
	 optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	switch (Switch)
	{
		case 0:
			return Default.ShopBootMsg;
		case 1:
			return Default.HasWeaponMsg;
		case 2:
			return Default.NoCarryMoreMsg;
		case 3:
			return Default.ShopItBase;
	}

	return "";
}

defaultproperties
{
     ShopBootMsg="You can't stay in this shop after closing"
     HasWeaponMsg="You already have this weapon"
     NoCarryMoreMsg="You can not carry this weapon"
     ShopItBase="Press '%Use%' to TRADE"
     bIsConsoleMessage=False
     DrawColor=(B=10,G=10,R=255)
     StackMode=SM_Down
     PosY=0.800000
     FontSize=2
}
