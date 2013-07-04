/*
	--------------------------------------------------------------
	KeyPickup_Story
	--------------------------------------------------------------

	Custom ShopVolume for use in Story missions.

	Implements its own version of the LevelRules actor's 'ItemForSale'
	functionality, so that different story shops can be configured with
	their own unique item lists.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class	KFShopVolume_Story extends ShopVolume;

/* stuff this shop sells */
var	()	array<class<Pickup> >			SaleItems;

/* Text to display to players when they open the shop menu */
var ()	string							WelcomeText;

/* Title of shop - displayed in the UI's header */
var()	string							ShopName;

/* Toggles display of the 'perks' header in the trader UI */
var()	bool							bShowPerkHeader;



/* fix for accessed nones */
function Touch( Actor Other )
{
	if(MyTrader != none)
	{
		Super.Touch(Other);
	}
}

/* fix for accessed nones */
function UnTouch( Actor Other )
{
	if(MyTrader != none)
	{
		Super.UnTouch(Other);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	SetCollision(!bCollideActors);
}


function UsedBy( Pawn user )
{
	local KFPlayerController_Story  StoryUser;

	/* Grab a reference to this shop volume -  we'll use it in the Trader UI Pages */
	StoryUser =  KFPlayerController_Story(user.Controller);
	if(StoryUser != none)
	{
		StoryUser.CurrentShopVolume = self;
	}

	Super.UsedBy(User);
}

defaultproperties
{
     bShowPerkHeader=True
     bStatic=False
}
