package elements.actor;

/**
	Character path type.
**/
enum abstract CharacterPathType(cpp.UInt8) {
	var IMAGE;
	var XML;
	var JSON;
	var DATA;
	var NONE;
}