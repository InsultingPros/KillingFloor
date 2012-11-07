//-----------------------------------------------------------
//   Used to changed the style of UT2K4 menu's to RO style Menus
//   Puma 5-15-2004
//-----------------------------------------------------------
class ROInterfaceUtil extends GUI;

var() material HeaderTop,HeaderBar,HeaderBase;		// Top, Bar and base

final simulated static function int SetROStyle(GUIController MyController, array<GUIComponent> Components)
{
	local int i;
    local string           myStyleName;
    local eFontScale tFontScale;

    // temp hax
    return Components.Length;

    if(MyController == None)
    {
        return -1;
    }

	for (i = 0; i < Components.Length; i++)
	{
	    if(Components[i] != None)
	    {
    		if (moComboBox(Components[i]) != None)
    		{
    	        tFontScale = moComboBox(Components[i]).MyComboBox.List.FontScale;
                myStyleName = "RO2ComboListBox";
                moComboBox(Components[i]).MyComboBox.List.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.List.Style = MyController.GetStyle(myStyleName,tFontScale);

                moComboBox(Components[i]).MyComboBox.List.SelectedStyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.List.SelectedStyle = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.Edit.FontScale;
                myStyleName = "EditBox";
                moComboBox(Components[i]).MyComboBox.Edit.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.Edit.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyShowListBtn.FontScale;
                myStyleName = "RORoundScaledButton";
                moComboBox(Components[i]).MyComboBox.MyShowListBtn.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyShowListBtn.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.FontScale;
                myStyleName = "RORoundScaledButton";
                moComboBox(Components[i]).MyComboBox.MyShowListBtn.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyShowListBtn.Style = MyController.GetStyle(myStyleName,tFontScale);


    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyScrollZone.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyGripButton.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyDecreaseButton.FontScale;
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                moComboBox(Components[i]).MyComboBox.MyListBox.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (moCheckBox(Components[i]) != None)
    		{
                myStyleName = "CheckBox";
                moCheckBox(Components[i]).MyCheckBox.StyleName = myStyleName;
                moCheckBox(Components[i]).MyCheckBox.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (moSlider(Components[i]) != None)
    		{
    	        tFontScale = moSlider(Components[i]).MySlider.FontScale;
                myStyleName = "SliderKnob";
                moSlider(Components[i]).MySlider.StyleName = myStyleName;
                moSlider(Components[i]).MySlider.Style = MyController.GetStyle(myStyleName,tFontScale);

                myStyleName = "ROSliderBar";
                moSlider(Components[i]).MySlider.BarStyleName = myStyleName;
                moSlider(Components[i]).MySlider.BarStyle = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (moButton(Components[i]) != None)
    		{
    	        tFontScale = moButton(Components[i]).MyButton.FontScale;
                myStyleName = "RO2ComboListBox";
                moButton(Components[i]).MyButton.StyleName = myStyleName;
                moButton(Components[i]).MyButton.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (moEditBox(Components[i]) != None)
    		{
    	        tFontScale = moEditBox(Components[i]).MyEditBox.FontScale;
                myStyleName = "EditBox";
                moEditBox(Components[i]).MyEditBox.StyleName = myStyleName;
                moEditBox(Components[i]).MyEditBox.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (moFloatEdit(Components[i]) != None)
    		{
    	        tFontScale = moFloatEdit(Components[i]).MyNumericEdit.MyEditBox.FontScale;
                myStyleName = "RO2ComboListBox";
                moFloatEdit(Components[i]).MyNumericEdit.MyEditBox.StyleName = myStyleName;
                moFloatEdit(Components[i]).MyNumericEdit.MyEditBox.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moFloatEdit(Components[i]).MyNumericEdit.MySpinner.FontScale;
                myStyleName = "SpinnerButton";
                moFloatEdit(Components[i]).MyNumericEdit.MySpinner.StyleName = myStyleName;
                moFloatEdit(Components[i]).MyNumericEdit.MySpinner.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (GUIButton(Components[i]) != None)
    		{
    	        tFontScale = GUIButton(Components[i]).FontScale;
                myStyleName = "ROSquareButton";
                GUIButton(Components[i]).StyleName = myStyleName;
                GUIButton(Components[i]).Style = MyController.GetStyle(myStyleName,GUIButton(Components[i]).FontScale);
            }
    		if (GUIHeader(Components[i]) != None)
    		{
    	        tFontScale = GUIHeader(Components[i]).FontScale;
                myStyleName = "TitleBar";
                GUIHeader(Components[i]).StyleName = myStyleName;
                GUIHeader(Components[i]).Style = MyController.GetStyle(myStyleName,GUIHeader(Components[i]).FontScale);
            }
    		if (moNumericEdit(Components[i]) != None)
    		{
    	        tFontScale = moNumericEdit(Components[i]).MyNumericEdit.MyEditBox.FontScale;
                myStyleName = "RO2ComboListBox";
                moNumericEdit(Components[i]).MyNumericEdit.MyEditBox.StyleName = myStyleName;
                moNumericEdit(Components[i]).MyNumericEdit.MyEditBox.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = moNumericEdit(Components[i]).MyNumericEdit.MySpinner.FontScale;
                myStyleName = "SpinnerButton";
                moNumericEdit(Components[i]).MyNumericEdit.MySpinner.StyleName = myStyleName;
                moNumericEdit(Components[i]).MyNumericEdit.MySpinner.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (GUIVertImageListBox(Components[i]) != None)
    		{
    	        tFontScale = GUIVertImageListBox(Components[i]).List.MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIVertImageListBox(Components[i]).List.MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIVertImageListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIVertImageListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.FontScale;
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUIVertImageListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (GUIMultiColumnListBox(Components[i]) != None)
    		{
    	        tFontScale = GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);

                tFontScale = GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.FontScale;
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIMultiColumnListBox(Components[i]).Header.FontScale;
                myStyleName = "ROSectionHeaderBar";
                GUIMultiColumnListBox(Components[i]).Header.BarStyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).Header.BarStyle = MyController.GetStyle(myStyleName,tFontScale);
                myStyleName = "ROSectionHeaderTop";
                GUIMultiColumnListBox(Components[i]).Header.StyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).Header.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIMultiColumnListBox(Components[i]).List.FontScale;
                myStyleName = "ROItemOutline";
                GUIMultiColumnListBox(Components[i]).List.OutLineStyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.OutLineStyle = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIMultiColumnListBox(Components[i]).List.FontScale;
                myStyleName = "ROListSelection";
                GUIMultiColumnListBox(Components[i]).List.SelectedStyleName = myStyleName;
                GUIMultiColumnListBox(Components[i]).List.SelectedStyle = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (GUIListHeader(Components[i]) != None)
    		{
    	        tFontScale = GUIListHeader(Components[i]).FontScale;
                myStyleName = "ROListSection";
                GUIListHeader(Components[i]).StyleName = myStyleName;
                GUIListHeader(Components[i]).Style = MyController.GetStyle(myStyleName,GUIListHeader(Components[i]).FontScale);

                GUIListHeader(Components[i]).LabelStyleName = myStyleName;
                GUIListHeader(Components[i]).MyLabel.Style = MyController.GetStyle(myStyleName,GUIListHeader(Components[i]).FontScale);
            }
    		if (GUITreeListBox(Components[i]) != None)
    		{
    	        tFontScale = GUITreeListBox(Components[i]).List.FontScale;
                myStyleName = "ROItemOutline";
                GUITreeListBox(Components[i]).List.OutLineStyleName = myStyleName;
                GUITreeListBox(Components[i]).List.OutLineStyle = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUITreeListBox(Components[i]).List.FontScale;
                myStyleName = "ROListSelection";
                GUITreeListBox(Components[i]).List.SelectedStyleName = myStyleName;
                GUITreeListBox(Components[i]).List.SelectedStyle = MyController.GetStyle(myStyleName,tFontScale);

                tFontScale = GUITreeListBox(Components[i]).MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUITreeListBox(Components[i]).MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUITreeListBox(Components[i]).MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);
           	    tFontScale = GUITreeListBox(Components[i]).MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                GUITreeListBox(Components[i]).MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUITreeListBox(Components[i]).MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUITreeListBox(Components[i]).MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUITreeListBox(Components[i]).MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUITreeListBox(Components[i]).MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUITreeListBox(Components[i]).MyScrollBar.MyDecreaseButton.FontScale;
                GUITreeListBox(Components[i]).MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUITreeListBox(Components[i]).MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
           }
    		if (GUIComboBox(Components[i]) != None)
    		{
    	        tFontScale = GUIComboBox(Components[i]).List.FontScale;
                myStyleName = "RO2ComboListBox";
                GUIComboBox(Components[i]).List.StyleName = myStyleName;
                GUIComboBox(Components[i]).List.Style = MyController.GetStyle(myStyleName,tFontScale);

                GUIComboBox(Components[i]).List.SelectedStyleName = myStyleName;
                GUIComboBox(Components[i]).List.SelectedStyle = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).Edit.FontScale;
                myStyleName = "EditBox";
                GUIComboBox(Components[i]).Edit.StyleName = myStyleName;
                GUIComboBox(Components[i]).Edit.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyShowListBtn.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIComboBox(Components[i]).MyShowListBtn.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyShowListBtn.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyListBox.MyScrollBar.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIComboBox(Components[i]).MyShowListBtn.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyShowListBtn.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);

    	        tFontScale = GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyDecreaseButton.FontScale;
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUIComboBox(Components[i]).MyListBox.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
            }
    		if (GUIScrollTextBox(Components[i]) != None)
    		{
                tFontScale = GUIScrollTextBox(Components[i]).MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUIScrollTextBox(Components[i]).MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUIScrollTextBox(Components[i]).MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);
           	    tFontScale = GUIScrollTextBox(Components[i]).MyScrollBar.MyGripButton.FontScale;
                myStyleName = "RORoundScaledButton";
                GUIScrollTextBox(Components[i]).MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUIScrollTextBox(Components[i]).MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUIScrollTextBox(Components[i]).MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUIScrollTextBox(Components[i]).MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUIScrollTextBox(Components[i]).MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUIScrollTextBox(Components[i]).MyScrollBar.MyDecreaseButton.FontScale;
                GUIScrollTextBox(Components[i]).MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUIScrollTextBox(Components[i]).MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
           }
    	   if (GUIScrollText(Components[i]) != None)
    	   {
                tFontScale = GUIScrollText(Components[i]).MyScrollBar.MyScrollZone.FontScale;
                myStyleName = "ROScrollZone";
                GUIScrollText(Components[i]).MyScrollBar.MyScrollZone.StyleName = myStyleName;
                GUIScrollText(Components[i]).MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);
           	    tFontScale = GUIScrollText(Components[i]).MyScrollBar.MyGripButton.FontScale;
                myStyleName = "ROScrollButtons";
                GUIScrollText(Components[i]).MyScrollBar.MyGripButton.StyleName = myStyleName;
                GUIScrollText(Components[i]).MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUIScrollText(Components[i]).MyScrollBar.MyIncreaseButton.FontScale;
                myStyleName = "ROScrollZone";
                GUIScrollText(Components[i]).MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
                GUIScrollText(Components[i]).MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
    	        tFontScale = GUIScrollText(Components[i]).MyScrollBar.MyDecreaseButton.FontScale;
                GUIScrollText(Components[i]).MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
                GUIScrollText(Components[i]).MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
           }
    	   if (GUISectionBackground(Components[i]) != None)
    	   {
                GUISectionBackground(Components[i]).HeaderTop = default.HeaderTop;
                GUISectionBackground(Components[i]).HeaderBar = default.HeaderBar;
                GUISectionBackground(Components[i]).HeaderBase = default.HeaderBase;
           }
       }
    }

    return  Components.Length;
}

final simulated static function int ReformatLists(GUIController MyController, GUIMultiColumnListBox MyListBox)
{
    local string           myStyleName;
    local                  eFontScale tFontScale;
    local int              myReturnValue;

    // hax
    return -1;

    myReturnValue = -1;
	if( (MyListBox != none) && (MyListBox.List != none))
	{
        myReturnValue = 1;
        tFontScale = MyListBox.List.MyScrollBar.MyScrollZone.FontScale;
        myStyleName = "ROScrollZone";
        MyListBox.List.MyScrollBar.MyScrollZone.StyleName = myStyleName;
        MyListBox.List.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.List.MyScrollBar.MyGripButton.FontScale;
        myStyleName = "RORoundScaledButton";
        MyListBox.List.MyScrollBar.MyGripButton.StyleName = myStyleName;
        MyListBox.List.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.List.MyScrollBar.MyIncreaseButton.FontScale;
        myStyleName = "ROScrollZone";
        MyListBox.List.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
        MyListBox.List.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.List.MyScrollBar.MyDecreaseButton.FontScale;
        MyListBox.List.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
        MyListBox.List.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.Header.FontScale;
        myStyleName = "ROSectionHeaderBar";
        MyListBox.Header.BarStyleName = myStyleName;
        MyListBox.Header.BarStyle = MyController.GetStyle(myStyleName,tFontScale);
        myStyleName = "ROSectionHeaderTop";
        MyListBox.Header.StyleName = myStyleName;
        MyListBox.Header.Style = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.List.FontScale;
        myStyleName = "ROItemOutline";
        MyListBox.List.OutLineStyleName = myStyleName;
        MyListBox.List.OutLineStyle = MyController.GetStyle(myStyleName,tFontScale);
        tFontScale = MyListBox.List.FontScale;
        myStyleName = "ROListSelection";
        MyListBox.List.SelectedStyleName = myStyleName;
        MyListBox.List.SelectedStyle = MyController.GetStyle(myStyleName,tFontScale);
    }
    return myReturnValue;
}

defaultproperties
{
     HeaderBase=Texture'InterfaceArt_tex.Menu.RODisplay'
}
