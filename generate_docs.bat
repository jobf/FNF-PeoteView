@echo off
echo This also builds the game for you.
lime build windows -xml
haxelib run dox -o bin/api -i bin/windows/types.xml -in music -in elements -in utils -in system -in menus
cd ./bin/api
index.html
echo Done!