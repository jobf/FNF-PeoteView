
import peote.view.*;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;
import lime.ui.KeyCode;
import elements.Text;
import system.*;

@:publicFields
class Main extends Application
{

	override function onPreloadComplete() {	
		var peoteView = new PeoteView(window);

		TextureSystem.createTexture("vcrTex", "assets/fonts/vcrAtlas.png");
		
		var display = new Display(0, 0, window.width, window.height);
		peoteView.addDisplay(display);
		
		var x:Float = 0;
		var y:Float = 0;

		var text = new Text(Std.int(x), Std.int(y));
		
		var program = new Program(text.buffer);
		program.blendEnabled = true;
		display.addProgram(program);

		TextureSystem.setTexture(program, 'vcrTex', 'vcrTex');
		
		text.text = 'testing....';

		var frameCount:Float = 0;
		onUpdate.add(deltaTime -> {
			
			frameCount += 1.0;

			text.scale += 0.01;
		});

	}
}