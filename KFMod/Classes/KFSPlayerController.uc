class KFSPlayerController extends xPlayer;

const MAX_BUYITEMS=200;
const BUYLIST_CATS=7;

var string BuyListHeaders[BUYLIST_CATS];
var int BuyListItemCount;
var string BuyListItemNames[MAX_BUYITEMS];


replication
{

   reliable if( Role < ROLE_Authority )
        KFSwitchToBestWeapon;
}

function KFSwitchToBestWeapon()
{
  KFClientSwitchToBestWeapon();
}


function KFClientSwitchToBestWeapon()
{
  nextWeapon();
}

function ShowBuyMenu(string wlTag,float maxweight)
{
	StopForceFeedback();  // jdf - no way to pause feedback

	// Open menu

	ClientOpenMenu("KFGUI.GUIBuyMenu",,wlTag,string(maxweight));
}



State Dead{

 function BeginState(){
   Super.BeginState();
   bBehindView=False;
 }

}



 function PawnDied(Pawn P)
 {
    local int i;

        for (i = 0; i < CameraEffects.Length; i++){
            	RemoveCameraEffect(CameraEffects[i]);
    	}

     Super.PawnDied(P);
 }




exec function DeleteSavePoint()
{
//local KFDataObject SPAmmo;
	//ConsoleCommand("SAY SaveGame deleted");

	 /*
	 if(Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP")!=None){

		if(Caps(string(Level.Outer.Name))=="KFS-Intro"){

			Level.Game.DeletePackage("KFSP");
			//just set the savepoint to the begining of the SP campaign
			 //SPAmmo.SetMapName("KFS-01");
			 //SPAmmo.SetPlayerAmmoCount(Pawn);
			//Level.Game.SavePackage("KFSP");
			ClientMessage("Current save point deleted.");
			ClientMessage("Please restart Single Player for the change to take effect (Retry button).");

			}else{
			ClientMessage("You can only delete the SP save point at the start of the campaign (KFS-01).");
			ClientMessage("Please go to the Main Menu and select Single Player first.");

			}

	}
	*/

	/*if(Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP")!=None){
	    log("LoadDataObject!!");
	    	SPAmmo = Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP");
	    }else{
	    	SPAmmo = Level.Game.CreateDataObject(class'KFDataObject', "SPAmmo", "KFSP");
	    	//log("CreateKFDataObject!!");
    }*/




}

exec function LoadSavePoint(){
	//local KFDataObject SPAmmo;

		//log(string(Level.Outer.Name));

		//Super(xPawn).PostBeginPlay();
		//log(Left(string(Level.Outer.Name),3));
	//if(Left(Caps(string(Level.Outer.Name)),3)=="KFS"){
	//	if(Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP")!=None){

	//		SPAmmo = Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP");

	//	}else{
	//		SPAmmo = Level.Game.CreateDataObject(class'KFDataObject', "SPAmmo", "KFSP");
	//		SPAmmo.SetMapName(Caps(string(Level.Outer.Name)));
	//		log("set map name");
	//	}
	//}

	//Controller.ConsoleCommand("OPEN KFS-01?Game=KFmod.KFSPGameType");
	//***Temp fix. Get rid of hardcoding!!!
	//if(string(SPAmmo.MapName)!= "KFS-01"){
	//log("hey:");
	//log(SPammo.MapName);
//		ConsoleCommand("OPEN "$SPammo.MapName$"?Game=KFmod.KFSPGameType");

	//}else{
	    //else we must restarting from the beginning map so delete the package.
	    //
	   // Controller.ConsoleCommand("OPEN KFS-01?Game=KFmod.KFSPGameType");


       //}



	//ConsoleCommand("?load=1");

}

defaultproperties
{
     CheatClass=Class'KFMod.KFCheatManager'
     MidGameMenuClass="KFGUI.KFDisconnectPage"
}
