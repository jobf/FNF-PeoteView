package;

import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;

@:publicFields
@:access(structures.PauseScreen)
@:access(structures.OptionsMenu)
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
	var optionsScreen:CustomDisplay;
	var fakeWindow:FakeWindow;

	// STATES
	var currentState:StateSelection;
	var mainMenu:MainMenu;
	var playField:PlayField;

	// OPTIONS MENU
	var optionsMenu(default, null):OptionsMenu;

	public function startSample(window:Window)
	{
		window.opacity = 0;

		current = this;

		SaveData.init();

		Sound.init();

		Controls.pressed = new Controls();
		Controls.released = new Controls();

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
			TextureSystem.createTexture("optionsMenuSheet", "assets/ui/optionsMenuSheet.png");
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			var stamp = haxe.Timer.stamp();
			trace("Creating displays...");

			bottomDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			middleDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			topDisplay = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			optionsScreen = new CustomDisplay(0, 0, window.width, window.height, 0x00000000);
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			peoteView.start();

			var stamp = haxe.Timer.stamp();
			trace("Adding displays...");

			peoteView.addDisplay(bottomDisplay);
			peoteView.addDisplay(middleDisplay);
			peoteView.addDisplay(topDisplay);
			peoteView.addDisplay(optionsScreen);
			trace('Done! Took ${(haxe.Timer.stamp() - stamp) * 1000}ms');

			conductor = new Conductor();

			OptionsMenu.init(optionsScreen);
			optionsMenu = new OptionsMenu();

			fakeWindow = new FakeWindow(peoteView);

			resize(peoteView.width, peoteView.height);

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

			window.opacity = 1;
		}, 100);
	}

	static public function switchState(newState:StateSelection) {
		var instance = Main.current;

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
		} catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);

		instance.currentState = newState;

		switch (newState) {
			case MAIN_MENU:
				instance.mainMenu = new MainMenu();
				instance.mainMenu.init(instance.topDisplay, instance.middleDisplay, instance.bottomDisplay);
			case FREEPLAY:
			case GAMEPLAY:
				instance.playField = new PlayField(Sys.args()[0]);
				instance.playField.init(instance.topDisplay, instance.middleDisplay, instance.bottomDisplay);
				instance.playField.downScroll = SaveData.state.preferences.downScroll;
			case AWARDS:
			case CREDITS:
			case NONE:
		}

		GC.run(10);
		GC.enable(false);

		var peoteView = Main.current.peoteView;

		Main.current.fakeWindow.reload(peoteView.width, peoteView.height);
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

			try {
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

					if (PauseScreen.pauseProg.isIn(PauseScreen.display)) {
						var pauseScreen = playField.pauseScreen;
						pauseScreen.update(newDeltaTime);
					}
				}

				if (optionsMenu.active) {
					optionsMenu.update(newDeltaTime);
				}
			} catch (_) trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()), _);

			timeStamp = stamp();
		}

		Tools.profileFrame();
	}

	private inline function popupOptionsMenu() {
		if (!optionsScreen.isIn(peoteView))
			peoteView.addDisplay(optionsScreen);
		fakeWindow.reload(peoteView.width, peoteView.height);
	}

	private inline function removeOptionsMenu() {
		if (optionsScreen.isIn(peoteView))
			peoteView.removeDisplay(optionsScreen);
		fakeWindow.reload(peoteView.width, peoteView.height);
	}

	function resize(w:Int, h:Int) {
		peoteView.resize(w, h);
		fakeWindow.reload(w, h);

		centerDisplayOnWindow(bottomDisplay, w, h);
		centerDisplayOnWindow(middleDisplay, w, h);
		centerDisplayOnWindow(topDisplay, w, h);
		centerDisplayOnWindow(optionsScreen, w, h);
	}

	function centerDisplayOnWindow(display:CustomDisplay, w:Int, h:Int) {
		var scale = (fakeWindow.visible ? (h - 30) : h) / INITIAL_HEIGHT;

		if (fakeWindow.visible) {
			display.x = 1;
			display.width = w - 2;
			display.y = 29;
			display.height = h - 30;
		} else {
			display.x = 0;
			display.width = w;
			display.y = 0;
			display.height = h;
		}
		display.scale = scale;
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

private enum abstract StateSelection(Int) {
	var NONE;
	var MAIN_MENU;
	var FREEPLAY;
	var GAMEPLAY;
	var AWARDS;
	var CREDITS;
}