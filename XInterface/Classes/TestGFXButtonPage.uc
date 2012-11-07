class TestGFXButtonPage extends TestPageBase;

// if _RO_
/*
// end if _RO_
#exec OBJ LOAD FILE=InterfaceContent.utx

var GUIGFXButton Btn;
var GUIComboBox ImgStyle, ImgAlign, ImgSelect;

function MyOnOpen()
{
	Btn = GUIGFXButton(Controls[1]);
	ImgStyle = GUIComboBox(Controls[3]);
	ImgAlign = GUIComboBox(Controls[5]);
	ImgSelect = GUIComboBox(Controls[7]);

	// Prepare the ComboBoxes
	ImgStyle.AddItem("Normal");
	ImgStyle.AddItem("Center");
	ImgStyle.AddItem("Stretched");
	ImgStyle.AddItem("Scaled");
	ImgStyle.AddItem("Bound");

	ImgAlign.AddItem("Blurry");
	ImgAlign.AddItem("Watched");
	ImgAlign.AddItem("Focused");
	ImgAlign.AddItem("Pressed");
	ImgAlign.AddItem("Disabled");

	// ifndef _RO_
	//ImgSelect.AddItem("PlayerPictures.cEgyptFemaleBA");
	ImgSelect.AddItem("InterfaceContent.Menu.bg07");
	// ifndef _RO_
	//ImgSelect.AddItem("PlayerPictures.Galactic");
	ImgSelect.AddItem("InterfaceContent.Menu.CO_Final");
	ImgSelect.AddItem("InterfaceContent.BorderBoxF_Pulse");

	// ifdef _RO_
	SetNewImage("Engine.BlackTexture");
	//else
	//SetNewImage("PlayerPictures.cEgyptFemaleBA");
}

function OnNewImgStyle(GUIComponent Sender)
{
local string NewImgStyle;

	NewImgStyle = ImgStyle.Get();
	if (NewImgStyle == "Normal")
		Btn.Position=ICP_Normal;
	else if (NewImgStyle == "Center")
		Btn.Position=ICP_Center;
	else if (NewImgStyle == "Stretched")
		Btn.Position=ICP_Stretched;
	else if (NewImgStyle == "Scaled")
		Btn.Position=ICP_Scaled;
	else if (NewImgStyle == "Bound")
		Btn.Position=ICP_Bound;
}

function OnNewImgAlign(GUIComponent Sender)
{
local string NewImgAlign;

	NewImgAlign = ImgAlign.Get();
	if (NewImgAlign == "Blurry")
		Btn.MenuState = MSAT_Blurry;
	else if (NewImgAlign == "Watched")
		Btn.MenuState = MSAT_Watched;
	else if (NewImgAlign == "Focused")
		Btn.MenuState = MSAT_Focused;
	else if (NewImgAlign == "Pressed")
		Btn.MenuState = MSAT_Pressed;
	else if (NewImgAlign == "Disabled")
		Btn.MenuState = MSAT_Disabled;
}

function OnNewImgSelect(GUIComponent Sender)
{
	SetNewImage(ImgSelect.Get());
}

function OnNewClientBound(GUIComponent Sender)
{
	Btn.bClientBound=GUICheckBoxButton(Sender).bChecked;
}

function SetNewImage(string ImageName)
{
	Btn.Graphic=DLOTexture(ImageName);
}

function Material DLOTexture(string TextureFullName)
{
	return Material(DynamicLoadObject(TextureFullName, class'Material'));
}

defaultproperties
{
	Begin Object Class=GUIImage Name=Backdrop
		Image=Material'InterfaceContent.Menu.pEmptySlot'
		WinTop=0.2
		WinLeft=0.1
		WinHeight=0.2
		WinWidth=0.2
		ImageStyle=ISTY_Bound
	End Object

	Begin Object Class=GUIGFXButton Name=TheButton
		WinTop=0.2
		WinLeft=0.1
		WinHeight=0.2
		WinWidth=0.2
	End Object

	Begin Object Class=GUILabel Name=lblImgStyle
		Caption="Image Style"
		WinTop=0.2
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.06
	End Object

	Begin Object Class=GUIComboBox Name=cboImgStyle
		WinTop=0.2
		WinLeft=0.75
		WinHeight=0.06
		WinWidth=0.2
		bReadOnly=true
		OnChange=OnNewImgStyle
	End Object

	Begin Object Class=GUILabel Name=lblImgAlign
		Caption="Menu State"
		WinTop=0.3
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.06
	End Object

	Begin Object Class=GUIComboBox Name=cboImgAlign
		WinTop=0.3
		WinLeft=0.75
		WinHeight=0.06
		WinWidth=0.2
		bReadOnly=true
		OnChange=OnNewImgAlign
	End Object

	Begin Object Class=GUILabel Name=lblImgSelect
		Caption="Select Image"
		WinTop=0.4
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.06
	End Object

	Begin Object Class=GUIComboBox Name=cboImgSelect
		WinTop=0.4
		WinLeft=0.75
		WinHeight=0.06
		WinWidth=0.2
		bReadOnly=true
		OnChange=OnNewImgSelect
	End Object

	Begin Object Class=GUILabel Name=lblClientBound
		Caption="Client Bound ?"
		WinTop=0.5
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.06
	End Object

	Begin Object Class=GUICheckBoxButton Name=cbbClientBound
		WinTop=0.5
		WinLeft=0.75
		WinHeight=0.06
		WinWidth=0.2
		OnChange=OnNewClientBound
	End Object

	Controls(0)=GUIImage'Backdrop'
	Controls(1)=GUIGFXButton'TheButton'
	Controls(2)=GUILabel'lblImgStyle'
	Controls(3)=GUIComboBox'cboImgStyle'
	Controls(4)=GUILabel'lblImgAlign'
	Controls(5)=GUIComboBox'cboImgAlign'
	Controls(6)=GUILabel'lblImgSelect'
	Controls(7)=GUIComboBox'cboImgSelect'
	Controls(8)=GUILabel'lblClientBound'
	Controls(9)=GUICheckBoxButton'cbbClientBound'

	OnOpen=MyOnOpen
}
// if _RO_
*/
// end if _RO_

defaultproperties
{
}
