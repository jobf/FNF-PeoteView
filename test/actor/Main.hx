
import elements.CustomDisplay;
import structures.PlayField;
import elements.actor.sparrow.Actor;
import peote.view.*;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import system.*;
import music.Conductor;

@:publicFields
class Main extends Application
{

	override function onPreloadComplete() {	
		var peoteView = new PeoteView(window);
		
		var display = new CustomDisplay(0, 0, window.width, window.height,0x666666FF);
		peoteView.addDisplay(display);
		
		var x:Float = 0;
		var y:Float = 0;

		// Actor.init_direct(display);
		// Actor.loadTexturesOf(["bf"]);
		var actor = new Actor(display, "bf", 625, 250, 24);
		actor.playAnimation("idle");
	}

	static inline var INITIAL_WIDTH = 1280;
	static inline var INITIAL_HEIGHT = 720;
	// MUSIC
	static var conductor : Conductor;

	static var current : Main;

	static public function switchState(newState:StateSelection){}
	var playField : PlayField;
	var peoteView : PeoteView;

	var topDisplay:CustomDisplay;
}

private enum abstract StateSelection(cpp.UInt8)
{
	var NONE;
	var MAIN_MENU;
	var FREEPLAY;
	var GAMEPLAY;
	var AWARDS;
	var CREDITS;
}