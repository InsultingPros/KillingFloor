class Pickup_TransmitterSwitch extends Pickup_TransmitterPart;

#exec OBJ LOAD FILE=FrightYard2_T.utx

defaultproperties
{
     CarriedMaterial=Texture'FrightYard_T.Transmitter_Icon_64'
     GroundMaterial=ColorModifier'FrightYard_T.RemotePickupGroundIco_cm'
     InventoryType=Class'FrightScript.Inv_TransmitterSwitch'
     StaticMesh=StaticMesh'FrightYard2_SM.FY_Transmitter_Collapsed'
}
