package elements;

/**
    Character path type.
**/
enum abstract CharacterPathType(cpp.UInt8) {
    var IMAGE;
    var INFO;
    var XML;
    var JSON;
    var NONE;
}