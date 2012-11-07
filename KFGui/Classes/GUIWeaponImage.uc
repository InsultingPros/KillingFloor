class GUIWeaponImage extends GUIImage;

var float nFov;
var() editinline editconst noexport SpinnyWeap	InfoWeapon; // MUST be set to null when you leave the window
var vector offset;

/*
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);
	//Show us a spinning shotgun!
	if(InfoWeapon == None)
	    InfoWeapon = PlayerOwner().Spawn(class'XInterface.SpinnyWeap');
	InfoWeapon.bPlayCrouches = false;
	InfoWeapon.bPlayRandomAnims = false;
	InfoWeapon.SpinRate=0; //Oh, wait, don't.
	InfoWeapon.bHidden = true;
}

function ChangeToWeapon(GUIBuyable newWeapon)
{
	if(newWeapon == None)
	{
		InfoWeapon.bHidden = true;
		return;
	}
	if(newWeapon.showMesh != None)
	{
		InfoWeapon.SetDrawType(DT_Mesh);
		InfoWeapon.LinkMesh(newWeapon.showMesh);
	} else
	{
		InfoWeapon.SetDrawType(DT_StaticMesh);
		InfoWeapon.SetStaticMesh(newWeapon.myShowMesh);
	}
	offset = newWeapon.infoDrawOffset;
	//log("offset:"@offset,'KFMessage');
	InfoWeapon.SetDrawScale(newWeapon.infoDrawScale);
	InfoWeapon.SpinRate = newWeapon.infoSpinRate;  //Okay, you can if you want to.
	ResetWeaponRotation(newWeapon.infoDrawRotation);
}

function ResetWeaponRotation(rotator thing)
{
	local rotator temp;
  	if ( InfoWeapon != None )
  	{
  	    temp.Yaw = PlayerOwner().Rotation.Yaw + thing.Yaw;
  	    temp.Roll = PlayerOwner().Rotation.Roll + thing.Roll;
  	    temp.Pitch = PlayerOwner().Rotation.Pitch + thing.Pitch;
   		InfoWeapon.SetRotation(temp);
		InfoWeapon.bHidden = false;
	 }
}

function PostRenderBuyMenu(Canvas Canvas)
{
	local float oOrgX,oOrgY;
	local float oClipX,oClipY;
	local vector CamPos,X,Y,Z;
	local rotator CamRot;

  	oOrgX = Canvas.OrgX;
	oOrgY = Canvas.OrgY;
	oClipX = Canvas.ClipX;
	oClipY = Canvas.ClipY;

	Canvas.OrgX = ActualLeft();
	Canvas.OrgY = ActualTop();
	Canvas.ClipX = ActualWidth();
	Canvas.ClipY = ActualHeight();

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);


	InfoWeapon.SetLocation(CamPos + (X*offset.X)+(Y*offset.Y)+(Z*offset.Z));

   	canvas.DrawActorClipped(InfoWeapon, false,  ActualLeft(), ActualTop(), ActualWidth(), ActualHeight(), true, nFov);

	Canvas.OrgX = oOrgX;
	Canvas.OrgY = oOrgY;
   	Canvas.ClipX = oClipX;
	Canvas.ClipY = oClipY;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);
	if ( InfoWeapon != None )
		InfoWeapon.bHidden = true;
}

function Free()
{
	Super.Free();

	if ( InfoWeapon != None )
		InfoWeapon.Destroy();

	InfoWeapon = None;
}

*/

defaultproperties
{
}
