package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;

@:publicFields
class Main extends Application
{
	/**
	 * FNF's standard resolution is 720p.
	 * Resizing the window won't make the game look crispier
	 * unless you create a higher resolution version of your images.
	**/
	static inline var INITIAL_WIDTH = 1280;
	static inline var INITIAL_HEIGHT = 720;

	// Internal variable for checking if the game has booted up
	private var _started(default, null):Bool;

	override function onWindowCreate()
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	// ------------------------------------------------------------
	// --------------------- GAME STARTS HERE ---------------------
	// ------------------------------------------------------------

	// STARTING POINT
	static var current:Main;
	var peoteView:PeoteView;

	// MUSIC
	static var conductor:Conductor;

	// DISPLAYS
	var bottomDisplay:CustomDisplay;
	var middleDisplay:CustomDisplay;
	var topDisplay:CustomDisplay;

	// STATES
	var currentState:StateSelection;
	var mainMenu:MainMenu;
	var playField:PlayField;

	public function startSample(window:Window)
	{
		current = this;

		SaveData.init();

		Sound.init();

		UISprite.healthBarProperties = Tools.parseHealthBarConfig('assets/ui');
		UISprite.timeBarProperties = Tools.parseTimeBarConfig('assets/ui');
		Tools.parseNoteskinData('assets/notes');

		peoteView = new PeoteView(window);

		haxe.Timer.delay(function() {
			var stamp = haxe.Timer.stamp();
			trace("Preloading textures...");
			TextureSystem.createTexture("mainMenuBGTex", "assets/mainMenu/menuBG.png");
			TextureSystem.createTexture("mainMenuSheet", "assets/mainMenu/sheet.png");
			TextureSystem.createTexture("noteTex", "assets/notes/noteSheet.png");
			TextureSystem.createTexture("uiTex", "assets/ui/uiSheet.png");
			TextureSystem.createTexture("pauseScreenSheet", "assets/ui/pauseScreenSheet.png");
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			var stamp = haxe.Timer.stamp();
			trace("Creating displays...");

			bottomDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x666666FF);
			middleDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			topDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			peoteView.start();

			var stamp = haxe.Timer.stamp();
			trace("Adding displays...");

			peoteView.addDisplay(bottomDisplay);
			peoteView.addDisplay(middleDisplay);
			peoteView.addDisplay(topDisplay);
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			resize(peoteView.width, peoteView.height);

			conductor = new Conductor();

			switchState(MAIN_MENU);

			window.onResize.add(resize);
			window.onFullscreen.add(fullscreen);

			#if FV_DEBUG
			DeveloperStuff.init(window, this);
			#end

			if (RenderingMode.enabled) {
				RenderingMode.initRender(this);
			}

			_started = true;
		}, 100);
	}

	static public function switchState(newState:StateSelection) {
		var instance = Main.current;

		if (newState == instance.currentState) return;

		try {
			switch (instance.currentState) {
				case MAIN_MENU:
					instance.mainMenu.dispose();
					instance.mainMenu = null;
				case FREEPLAY:
				case GAMEPLAY:
					instance.playField.dispose();
					instance.playField = null;
				case AWARDS:
				case CREDITS:
				case NONE:
			}
		} catch (e) {}

		instance.currentState = newState;

		switch (newState) {
			case MAIN_MENU:
				instance.mainMenu = new MainMenu();
				instance.mainMenu.init(instance.middleDisplay, instance.bottomDisplay);
			case FREEPLAY:
			case GAMEPLAY:
				instance.playField = new PlayField(Sys.args()[0]);
				instance.playField.init(instance.topDisplay, instance.middleDisplay, instance.bottomDisplay);
				instance.playField.downScroll = SaveData.state.downScroll;
			case AWARDS:
			case CREDITS:
			case NONE:
		}

		GC.run(10);
		GC.enable(false);
	}

	var newDeltaTime:Float = 0;
	var timeStamp:Float = 0;

	override function update(deltaTime:Int) {
		Tools.profileFrame();

		if (_started) {
			var ts:Float = stamp();

			newDeltaTime = (ts - timeStamp) * 1000;

			if (RenderingMode.enabled) {
				newDeltaTime = 1000 / 60;
			}

			if (mainMenu != null && !mainMenu.disposed) {
				mainMenu.update(newDeltaTime);
			}

			if (playField != null && !playField.disposed) {
				if (!playField.paused) {
					playField.update(newDeltaTime);
	
					if (RenderingMode.enabled && !playField.songEnded) {
						RenderingMode.pipeFrame();
					}
				}

				if (PauseScreen.pauseProg.isIn(topDisplay)) {
					playField.pauseScreen.update(newDeltaTime);
				}
			}

			timeStamp = stamp();
		}

		Tools.profileFrame();
	}

	function resize(w:Int, h:Int) {
		var scale = h / INITIAL_HEIGHT;

		peoteView.resize(w, h);

		bottomDisplay.width = w;
		bottomDisplay.height = h;
		bottomDisplay.scale = scale;

		middleDisplay.width = w;
		middleDisplay.height = h;
		middleDisplay.scale = scale;

		topDisplay.width = w;
		topDisplay.height = h;
		topDisplay.scale = scale;
	}

	inline function fullscreen() {
		var display = Application.current.window.displayMode;
		resize(display.width, display.height);
	}

	inline function stamp() {
		return Timestamp.get();
	}

	// ------------------------------------------------------------
	// ---------------------- GAME ENDS HERE ----------------------
	// ------------------------------------------------------------
}

private enum abstract StateSelection(cpp.UInt8) {
	var NONE;
	var MAIN_MENU;
	var FREEPLAY;
	var GAMEPLAY;
	var AWARDS;
	var CREDITS;
}