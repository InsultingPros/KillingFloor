//====================================================================
// Killing Floor Main Page Class
// ====================================================================
class KFMainPage extends UT2K4MainPage;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
    Super.InitComponent(MyC, MyO);

    c_Tabs.MyFooter = t_Footer;
    t_Header.DockedTabs = c_Tabs;
}

function InternalOnChange(GUIComponent Sender);

function HandleParameters(string Param1, string Param2)
{
    if ( Param1 != "" )
    {
        if ( c_Tabs != none )
            c_Tabs.ActivateTabByName(Param1, True);
    }
}

function bool GetRestoreParams( out string Param1, out string Param2 )
{
    if ( c_Tabs != None && c_Tabs.ActiveTab != None )
    {
        Param1 = c_Tabs.ActiveTab.Caption;
        return True;
    }

    return False;
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=PageTabs
         bDockPanels=True
         TabHeight=0.040000
         BackgroundStyleName="TabBackground"
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.040000
         RenderWeight=0.490000
         TabOrder=3
         bAcceptsInput=True
         OnActivate=PageTabs.InternalOnActivate
         OnChange=KFMainPage.InternalOnChange
     End Object
     c_Tabs=GUITabControl'KFGui.KFMainPage.PageTabs'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'2K4Menus.BkRenders.Bgndtile'
         ImageStyle=ISTY_PartialScaled
         X1=0
         Y1=0
         X2=4
         Y2=768
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFMainPage.PageBackground'

     Begin Object Class=GUIImage Name=BkChar
         Image=Texture'2K4Menus.MainMenu.Char01'
         ImageStyle=ISTY_Scaled
         X1=0
         Y1=0
         X2=1024
         Y2=768
         WinHeight=1.000000
         RenderWeight=0.020000
     End Object
     i_bkChar=GUIImage'KFGui.KFMainPage.BkChar'

     Begin Object Class=BackgroundImage Name=PageScanLine
         Image=Texture'2K4Menus.BkRenders.Scanlines'
         ImageColor=(A=32)
         ImageStyle=ISTY_Tiled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=32
         Y2=32
         RenderWeight=0.030000
     End Object
     i_bkScan=BackgroundImage'KFGui.KFMainPage.PageScanLine'

}
