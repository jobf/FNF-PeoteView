package utils;

@:publicFields
@:forward
abstract DisplaysAndPrograms(Display)
{
    function new(x:Int, y:Int, w:Int, y:Int, c:Color, view:PeoteView, numPrograms=1) {
        this = new Display(x, y, w, h, c);

        for (i in 0...numPrograms)
        {
            var program = new Program();
            this.addProgram(program);
        }

        view.addDisplay(this);
    }
}