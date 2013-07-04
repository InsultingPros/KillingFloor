/*
	--------------------------------------------------------------
	KF_HUDStyleManager
	--------------------------------------------------------------

    Placeable actor able to store multiple skin presets for the
    players HUD.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_HUDStyleManager extends  Info
dependson(KFStoryGameInfo)
placeable;



struct SConditionStyle
{
    var() KFStoryGameInfo.SConditionHintInfoWorld             Style_ObjCondition_World;
    var() KFStoryGameInfo.SConditionHintInfoHUD               Style_ObjCondition_Screen;
    var() Color                                               Condition_Clr;
};

struct SObjectiveStyle
{
    var() KFStoryGameInfo.SObjectiveHeaderInfo                Header;
    var() KFStoryGameInfo.SObjectiveBackgroundInfo            Background;
    var() KFStoryGameInfo.SVect2D                             Position;
    var() SConditionStyle                                     Conditions;
    var() bool                                                bOverride;
};


struct SMainHUDStyle
{
    var() Material     Ammo_Background;
    var() bool                                                bOverride;
};

struct SDialogueStyle
{
    var() KFStoryGameInfo.SDialogueDisplayInfo                Dialogue_Box;
    var() bool                                                bOverride;
};

struct SStylePreset
{
    var() name                                                StyleName;
    var() SDialogueStyle                                      Dialogue;
    var() SObjectiveStyle                                     Objectives;
    var() SMainHUDStyle                                       MainHUD;
};


var()      SStylePreset                                       StylePreset;

defaultproperties
{
     bNoDelete=True
}
