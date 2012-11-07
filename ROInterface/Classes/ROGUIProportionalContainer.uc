//-----------------------------------------------------------
// ROGUIProportionalContainer
// Class used to 'contain' other components.
// This class differs from ROGuiContainer in that it uses
// the contained control's scaling attributes.
// emh -- 11/12/2005
//-----------------------------------------------------------
class ROGUIProportionalContainer extends GUISectionBackground;

var(Debug) bool    bChangingPosValues;

struct ComponentPosValues
{
    var GUIComponent    component;
    var float           WinLeft, WinTop, WinWidth, WinHeight;
};

var()      array<ComponentPosValues>    AlignOriginalValues;

function bool ManageComponent(GUIComponent Component)
{
    local bool result;
    result = super.ManageComponent(Component);
    InternalPreDraw(none);  // This is used to position the controls before drawing them
                            // (else you see the controls full screen for a split second,
                            // which looks kinda odd)
    return result;
}

function bool InternalPreDraw(Canvas C)
{
    local int i;
	local float AL, AT, AW, AH, LPad, RPad, TPad, BPad;
	local ComponentPosValues values;

	if ( AlignStack.Length == 0 )
		return false;

    // for debug: let the user change the WinLeft, WinTop, etc values
    // when bChangingPosValues is set to true
	if (bChangingPosValues)
	{
	    AlignOriginalValues.Length = 0;
        return false;
	}

	AL = ActualLeft();
	AT = ActualTop();
	AW = ActualWidth();
	AH = ActualHeight();

	LPad = (LeftPadding   * AW) + ImageOffset[0];
	TPad = (TopPadding    * AH) + ImageOffset[1];
	RPad = (RightPadding  * AW) + ImageOffset[2];
	BPad = (BottomPadding * AH) + ImageOffset[3];

	if ( Style != none )
	{
		LPad += BorderOffsets[0];
		TPad += BorderOffsets[1];
		RPad += BorderOffsets[2];
		BPad += BorderOffsets[3];
	}

	AL += LPad;
	AT += TPad;
	AW -= LPad + RPad;
	AH -= TPad + BPad;

	//log("InternalPreDraw called!");
	//log("Actualleft = " $ AL);

    // ha, could this be any less efficient?
	for (i = 0; i < AlignStack.Length; i++)
	{
	    values = getAlignOriginalValues(AlignStack[i]);
	    AlignStack[i].WinLeft = RelativeLeft(values.WinLeft * AW + AL);
	    AlignStack[i].WinTop = RelativeTop(values.WinTop * AH + AT);
	    AlignStack[i].WinWidth = RelativeWidth(values.WinWidth * AW);
	    AlignStack[i].WinHeight = RelativeHeight(values.WinHeight * AH);
	}

	return false;
}

function ComponentPosValues getAlignOriginalValues(GUIComponent component)
{
    local ComponentPosValues values;
    local int i;

    // Search array to see if we can find the value in there
    for (i = 0; i < AlignOriginalValues.Length; i++)
        if (AlignOriginalValues[i].component == component)
            return AlignOriginalValues[i];

    // Component not found in array, add original values to stack and return that
    values.component = component;
    values.WinLeft = component.WinLeft;
    values.WinTop = component.WinTop;
    values.WinWidth = component.WinWidth;
    values.WinHeight = component.WinHeight;
    AlignOriginalValues[AlignOriginalValues.length] = values;

    return values;
}

defaultproperties
{
}
