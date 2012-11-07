class KFTeleporter extends Teleporter
	placeable;

//var KFDataObject SPAmmo;
var string NextMap;


// Teleporter was touched by an actor.
simulated function PostTouch( actor Other )
{
//log("PostTouch called!!!");

	//create the dataobject
//    if(Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP")!=None){
//    log("LoadDataObject!!");
//    	SPAmmo = Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP");
//    }else{
//    	SPAmmo = Level.Game.CreateDataObject(class'KFDataObject', "SPAmmo", "KFSP");
    	//log("CreateKFDataObject!!");
//    }
    //Level.Game.SavePackage("KFSP");
    if( (Role == ROLE_Authority) && (Pawn(Other) != None)
            && Pawn(Other).IsHumanControlled() ){
            //lets persist the ammo data.
            //log("SaveAmmoData!!!");

            NextMap = Caps(Left(URL,6));
     		log(NextMap);
            //SPAmmo.SetMapName(Caps(string(Level.Outer.Name)));
//	    SPAmmo.SetPlayerAmmoCount(Pawn(Other));
//	    SPAmmo.SetMapName(NextMap);
//	    Level.Game.SavePackage("KFSP");
//	    Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);

    }


   super.PostTouch(Other);


}

simulated function bool Accept( Actor Incoming, Actor Source ){

	if(Pawn(Incoming).IsHumanControlled()){
		//create the dataobject
		/*log("iSHUMANCONTROLLER!!!!.");
		if(Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP")!=None){
		    	log("lOADkfdATA!!!");
			SPAmmo = Level.Game.LoadDataObject(class'KFDataObject', "SPAmmo", "KFSP");
		}else{
		    	SPAmmo = Level.Game.CreateDataObject(class'KFDataObject', "SPAmmo", "KFSP");
    			log("CREATKFDATA!!!.");
    		}

		SPAmmo.GetPlayerAmmoCount(Pawn(Incoming));
        	Level.Game.SavePackage("KFSP"); */
        }

	return super.Accept(Incoming,Source);
}

defaultproperties
{
}
