package mint;

import mint.Control;
import mint.Label;

import mint.types.Types;
import mint.core.Signal;
import mint.core.Macros.*;


/** Options for constructing a Button */
typedef ButtonOptions = {
	> ControlOptions,
    //> LabelOptions, // TODO (DK) doesn't make much sense to me to inherit from this?

	var label : LabelOptions;

	@:optional var onclick: MouseSignal;
} //ButtonOptions


/**
    A simple button with a label
    Additional Signals: none

	(DK) changes:
		-capture focus on mouseDown
			-button still has focus when we move outside while pressed
			-at least thats how it works on windows
		-release focus on mouseUp
		-checking for ishovered + isfocused before dispatching onclick

		that results in:
		- old: press outside button, move inside button, release button => onclick event ... bug? (at least imo)
		- old: press inside, move outside, move inside, release button => no onclick event

		- new: press outside button, move inside button, release button => no onclick event
		- new: press inside, move outside, move inside, release button => onclick event
*/

@:allow(mint.render.Renderer)
class Button extends Control {

        /** The label the button displays */
    public var label : Label;

    var options: ButtonOptions;

    public function new( _options:ButtonOptions ) {

        options = _options;

        def(options.name, 'button');
        def(options.mouse_input, true);

        super(options);

        def(options.label.align, TextAlign.center);
        def(options.label.align_vertical, TextAlign.center);
        def(options.label.text_size, 14);

        label = new Label({
            parent : this,
            x: 0, y:0, w: w, h: h,
            text: options.label.text,
            text_size: options.label.text_size,
            name: name + '.label',
            options: options.label,
            mouse_input: false,
            internal_visible: options.visible
        });

        renderer = rendering.get( Button, this );

// (DK) removed code
        //if(options.onclick != null) onmouseup.listen(options.onclick);
// (DK) /removed code

// (DK) added code
		onmousedown.listen(this_onMouseDownHandler);
		onmouseup.listen(this_onMouseUpHandler);
// (DK) /added code

        oncreate.emit();
    } //new

// (DK) added code
	function this_onMouseDownHandler( e, c ) {
		focus();
	}

	function this_onMouseUpHandler( e, c ) {
		if (ishovered && isfocused) {
			if (options.onclick != null) {
				options.onclick(e, c);
			}
		}

		unfocus();
	}
// (DK) /added code

} //Button
