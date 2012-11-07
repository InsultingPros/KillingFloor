class GUIShowable extends Object;

var Mesh showMesh;              //Mesh to show in Info
var StaticMesh myShowMesh;      //Actual staticmesh to show in info
var int cost;                   //Cost to buy
var float weight;                 //Heaviness
var class<GUIPanel> InfoPanel;  //Panel to show Info in- should actually be KFInfoPanel
var class<Inventory> relatedInventory; //For inventory sellables,
									   //the associated class.

var rotator infoDrawRotation;          //Rotation in the Info panel
var vector infoDrawOffset;             //Offset in the info panel
var float infoDrawScale;               //Generally, size
var int infoSpinRate;                  //rate our weapon spins at.  0 by default.
                                        //alex, change the damn default.

var string ItemName;            //Sale name of object
var string Description;         //Flavor text, etc.

var int PurchasedQuantity;      //Have we bought one of these?
var int OwnedQuantity;          //Amount player already has

var float GameDifficulty;




enum eLibCat
{
	Lib_Story,
	Lib_Enemy,
	Lib_Equipment,
};



//We might want different panel types for different
//categories.
function class<GUIPanel> GetPanelType(eLibCat category)
{
	return InfoPanel;
}



function bool CanButtonMe(PlayerController pc,bool buying)
{
	if(buying)
		return CanBuyMe(pc);
	else
		return CanSellMe(pc);
}

function bool CanBuyMe(PlayerController pc)
{
	if(KFPlayerController(pc) == None || KFHumanPawn(pc.Pawn) == None)
	{
	  Log ("PC == none or PC.pawn == none");
          return false;
        }

	return true;
}

function bool CanSellMe(PlayerController pc)
{
	if(KFPlayerController(pc) == None || KFHumanPawn(pc.Pawn) == None)
		return false;
	return true;
}

function string GetBuyCaption(eLibCat index)
{
	Return "";
}

function ProcessComplete(PlayerController pc)
{


	if(PurchasedQuantity > 0)
	{
		GiveMe(pc);
		return;
	} else if(PurchasedQuantity < 0)
	{
		TakeMe(pc);
		return;
	}
}

//Hand it over to the player (once he hits complete)
function GiveMe(PlayerController pc)
{
}

//The slink giveth, the slink taketh away
function TakeMe(PlayerController pc)
{
}

//Consider ourselves bought
function BuyMe(out int score, out float oweight, pawn servUpdatePawn)
{
	score -= cost;
	oweight += weight;
	PurchasedQuantity++;

//	(KFPawn(servUpdatePawn)).setCreds(score) ;
}

//Consider ourselves sold
function SellMe(out int score, out float oweight, pawn servUpdatePawn)
{
      if (PlayerController(servUpdatePawn.Controller).GameReplicationInfo != none)
     {
        GameDifficulty = KFGameReplicationInfo(PlayerController(servUpdatePawn.Controller).GameReplicationInfo).GameDiff;
       // Log(KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).GameDiff);
     }

        
        
        if(PurchasedQuantity > 0)
		score += cost;
	else
		score += (cost / GameDifficulty);
	oweight -= weight;
	PurchasedQuantity--;
	



   //   (KFPawn(servUpdatePawn)).setCreds(score) ;

}

//Subclasses should return true if the buyable
//should show up under the index'th list for pawn p.
//This implementation just returns whether or not the pawn
//already has an item of class relatedInventory.

// ParentMenu parameter is a kludge so ammo can find out if any stuff
// has been bought and sold in the main buy menu. It is a relatively
// well contained kludge however, so I won't panic
function bool ShowMe(Pawn p, eLibCat index, GUILibraryMenu ParentMenu)
{
	//cost *= 10;
        return true;
}

//returns the combined weight of all owned items of type
function float InitOwnedQuantity(Pawn p)
{
	local Inventory inv;
	local int quant;

	//log("INITOWNEDQUANTITY",'KFMessage');

	if(p == None)
		return 0;
	for(inv = p.Inventory;inv != None;inv = inv.Inventory)
	{
		if(inv.IsA(relatedInventory.Name))
		{
			quant++;
		}
	}
	OwnedQuantity=quant;
	return weight*OwnedQuantity;
}

function bool HasMe(Pawn p)
{
	return (OwnedQuantity+PurchasedQuantity>0);
}

defaultproperties
{
     myShowMesh=StaticMesh'KillingFloorStatics.DeagleAmmo'
     InfoPanel=Class'XInterface.GUIPanel'
     infoDrawRotation=(Pitch=-5461,Yaw=-16384,Roll=32768)
     infoDrawOffset=(X=100.000000,Y=-20.000000,Z=-10.000000)
     infoDrawScale=0.700000
     infoSpinRate=20000
     ItemName="Buyable Object"
     Description="This object appears to be for sale."
}
