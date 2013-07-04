//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LobbyMenu_Story extends LobbyMenu;

defaultproperties
{
     Begin Object Class=GUIImage Name=DummyBG
     End Object
     WaveBG=GUIImage'KFStoryUI.LobbyMenu_Story.DummyBG'

     Begin Object Class=GUILabel Name=DummyWaveText
     End Object
     WaveLabel=GUILabel'KFStoryUI.LobbyMenu_Story.DummyWaveText'

     Begin Object Class=LobbyFooter_Story Name=StoryLobbyFooter
         RenderWeight=0.300000
         TabOrder=8
         bBoundToParent=False
         bScaleToParent=False
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=LobbyFooter_Story'KFStoryUI.LobbyMenu_Story.StoryLobbyFooter'

}
