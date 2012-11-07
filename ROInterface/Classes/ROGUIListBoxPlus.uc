//=============================================================================
// ROGUIListBoxPlus
//=============================================================================
// An enhanced version of the GUIListBox. This one supports setting a style
// for the scrollbar as well as for the misc elements in the list.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROGUIListBoxPlus extends GUIListBox;

var() string        ScrollZoneStyle;
var() string        ScrollGripStyle;
var() string        ScrollButtonsStyle;

var() eTextAlign    TextAlign;

// Set scroll bar style and text alignment
function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    local eFontScale tFontScale;

    super.InternalOnCreateComponent(NewComp, Sender);

    if (GUIVertScrollBar(NewComp) != None)
    {
        if (ScrollZoneStyle != "")
        {
            tFontScale = GUIVertScrollBar(NewComp).MyScrollZone.FontScale;
            GUIVertScrollBar(NewComp).MyScrollZone.StyleName = ScrollZoneStyle;
            GUIVertScrollBar(NewComp).MyScrollZone.Style = Controller.GetStyle(ScrollZoneStyle, tFontScale);
        }
        if (ScrollGripStyle != "")
        {
            tFontScale = GUIVertScrollBar(NewComp).MyGripButton.FontScale;
            GUIVertScrollBar(NewComp).MyGripButton.StyleName = ScrollGripStyle;
            GUIVertScrollBar(NewComp).MyGripButton.Style = Controller.GetStyle(ScrollGripStyle, tFontScale);
        }
        if (ScrollButtonsStyle != "")
        {
            tFontScale = GUIVertScrollBar(NewComp).MyDecreaseButton.FontScale;
            GUIVertScrollBar(NewComp).MyDecreaseButton.StyleName = ScrollButtonsStyle;
            GUIVertScrollBar(NewComp).MyDecreaseButton.Style = Controller.GetStyle(ScrollButtonsStyle, tFontScale);
            tFontScale = GUIVertScrollBar(NewComp).MyIncreaseButton.FontScale;
            GUIVertScrollBar(NewComp).MyIncreaseButton.StyleName = ScrollButtonsStyle;
            GUIVertScrollBar(NewComp).MyIncreaseButton.Style = Controller.GetStyle(ScrollButtonsStyle, tFontScale);
        }
    }
    else if (GUIList(NewComp) != none)
    {
        GUIList(NewComp).TextAlign = TextAlign;
    }
}

defaultproperties
{
     ScrollZoneStyle="ScrollZone"
     ScrollGripStyle="RoundScaledButton"
     ScrollButtonsStyle="ScrollZone"
     DefaultListClass="ROInterface.ROGUIListPlus"
     OnCreateComponent=ROGUIListBoxPlus.InternalOnCreateComponent
}
