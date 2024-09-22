@echo off
echo This also builds the game for you.
echo ONLY USE THIS IF YOU HAVE HAXE INSTALLED ON YOUR SYSTEM!
haxelib install dox
haxelib install hxargs
lime build windows -xml
haxelib run dox -o bin/api -i bin/windows/types.xml -in music -in elements -in utils -in system -in menus
cd ./bin/api
index.html
echo Done!