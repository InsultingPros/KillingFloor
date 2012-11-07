class KFRules extends UT2K4Tab_RulesBase;

defaultproperties
{
     Begin Object Class=GUITabControl Name=RuleTabControl
         bFillSpace=True
         bDockPanels=True
         bDrawTabAbove=False
         TabHeight=0.040000
         OnCreateComponent=KFRules.InternalOnCreateComponent
         WinHeight=1.000000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=RuleTabControl.InternalOnActivate
     End Object
     c_Rules=GUITabControl'KFGui.KFRules.RuleTabControl'

     FontScale=FNS_Small
}
