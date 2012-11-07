//=============================================================================
// ROMapVoteCountMultiColumnList
//=============================================================================
// Modified map vote list that doesn't display gametype
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROMapVoteCountMultiColumnList extends MapVoteCountMultiColumnList;

function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;

    if( VRI == none )
    	return;

    // Draw the selection border
    if( bSelected )
    {
        SelectedStyle.Draw(Canvas,MenuState, X, Y-2, W, H+2 );
        DrawStyle = SelectedStyle;
    }
    else
        DrawStyle = Style;

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.MapList[VRI.MapVoteCount[SortData[i].SortItem].MapIndex].MapName, FontScale );

    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(VRI.MapVoteCount[SortData[i].SortItem].VoteCount), FontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	local string ColumnData[5];

	//ColumnData[0] = left(Caps(VRI.GameConfig[VRI.MapVoteCount[i].GameConfigIndex].GameName),15);
	ColumnData[0] = left(Caps(VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName),20);
	ColumnData[1] = right("0000" $ VRI.MapVoteCount[i].VoteCount,4);

	return ColumnData[SortColumn] $ ColumnData[PrevSortColumn];
}

defaultproperties
{
     ColumnHeadings(0)="MapName"
     ColumnHeadings(1)="Votes"
     ColumnHeadings(2)="none"
     InitColumnPerc(0)=0.700000
     InitColumnPerc(1)=0.300000
     InitColumnPerc(2)=0.000000
     ColumnHeadingHints(0)="Map Name"
     ColumnHeadingHints(1)="Number of votes registered for this map."
     ColumnHeadingHints(2)="none"
     SortColumn=1
}
