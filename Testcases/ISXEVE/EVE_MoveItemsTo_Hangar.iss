#define TESTCASE 1

#include Scripts/EVEBot/Support/TestAPI.iss

/*
 * 	Test moving all items from ship cargo to station hangar
 *
 *	Revision $Id$
 *
 *	Tests:
 *		EVE:MoveItemsTo (Hangar dest)
 *		MyShip:GetCargo
 *
 *	Requirements:
 *		You: In station
 *		Cargo: In ship cargo
 */
 
function main()
{
	variable index:item MyCargo
	variable iterator CargoIterator
	variable index:int64 IDList

	echo "Version: $ISXEVE.Version}"

	MyShip:Open
	EVE:Execute[OpenHangarFloor]
	Wait 100

	MyShip:GetCargo[MyCargo]
	echo "Ship Cargo contains ${MyCargo.Used} Items"

	MyCargo:GetIterator[CargoIterator]
	if ${CargoIterator:First(exists)}
	do
	{
		echo "Adding ID: ${CargoIterator.Value} ${CargoIterator.Value.ID}"
		IDList:Insert[${CargoIterator.Value.ID}]
	}
	while ${CargoIterator:Next(exists)}

	;IDList:Clear
	;IDList:Insert[${MyCargo[1].ID}]
	echo "Have ${IDList.Used} Items to move to station hangar"

	EVE:MoveItemsTo[IDList, Hangar]
}