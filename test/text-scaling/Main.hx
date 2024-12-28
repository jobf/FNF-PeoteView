
import peote.view.*;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import elements.Text;

@:publicFields
class Main extends Application
{

	override function onPreloadComplete() {	
		var peoteView = new PeoteView(window);
		
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);

		
		var x:Float = 0;
		var y:Float = 0;

		var text = new Text(Std.int(x), Std.int(y));
		
		var program = new Program(text.buffer);
		program.blendEnabled = true;
		display.addProgram(program);
		
		text.text = 'testing....';

		var frameCount:Float = 0;
		onUpdate.add(deltaTime -> {
			
			frameCount += 1.0;

			var sin = (Math.sin(frameCount / 200)  + 1) / 2;
			trace(sin);

			text.scale = (sin * 200);
		});

	}
}