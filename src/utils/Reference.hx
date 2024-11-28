package utils;

import cpp.Pointer;

/**
    Small reference class from a pointer.
**/
@:publicFields
@:unreflective
@:generic
abstract Reference<T>(Pointer<T>) {
    inline function new(reference:T) this = Pointer.addressOf(reference);
    inline function setRef(value:T) this.ref = value;
    inline function getRef() return this.ref;
}