/*
	--------------------------------------------------------------
	StoryObjectiveBase
	--------------------------------------------------------------

    Base Class for Objective Actors in Killing Floor.

    This class mostly exists as an interface for Native functions.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class StoryObjectiveBase extends Actor
native
notplaceable;

/* Human readable Name.  */
var(Objective_Settings)	        const		name	ObjectiveName;

/* Reference to the action that is executed when this Objective is successfully completed */
var(Objective_Actions)          export editinlineuse BaseObjectiveAction     SuccessAction;

/* Reference to the action that is executed when this Objective is failed */
var(Objective_Actions)          export editinlineuse BaseObjectiveAction     FailureAction;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

/* Represents a connection between two actors in the editor.
Used to visualize Objective progression */

struct native SEditorConnection
{
    var Actor   ConnectionTarget;        // The Actor the connection ends at.
    var Actor   ConnectionSource;        // The Actor the connection begins with.
    var name    ConnectionName;          // Name of the connection, if relevant.  (events , etc.)
    var color   ConnectionClr;           // Colour of the line being drawn
    var byte    ConnectionType;          // 0 = event , 1 == action
};

var const array<SEditorConnection>        EditorConnections;

/* Called in native - Only used in the editor viewport for hooking up Objective lines
NOTE !!!! DO NOT CALL THIS EVENT FROM SCRIPT. Bad things could happen. */
event bool DrawConnectionsTo(actor PotentialTarget, array<StoryObjectiveBase> ObjList, out array<SEditorConnection> Connections){}

defaultproperties
{
}
