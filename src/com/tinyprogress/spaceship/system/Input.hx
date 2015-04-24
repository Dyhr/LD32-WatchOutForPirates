package com.tinyprogress.spaceship.system;

import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.events.KeyboardEvent;
import openfl.Vector;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Input 
{
	public static inline var KEYPRESS:String = "keypress";
	
	private static var dispatcher:IEventDispatcher;
	public static var keys(default, null):Vector<Int> = [ for (i in 0...1024) 0 ];

	public static function init(dispatcher:IEventDispatcher) {
		if (dispatcher != null) dispose();
		Input.dispatcher = dispatcher;
		
		dispatcher.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		dispatcher.addEventListener(KeyboardEvent.KEY_UP, keyUp);
	}
	public static function dispose() {
		if (dispatcher == null) return;
		dispatcher.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		dispatcher.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		dispatcher = null;
	}
	
	private static function keyUp(e:KeyboardEvent):Void 
	{
		keys[e.keyCode] = 0;
	}
	
	private static function keyDown(e:KeyboardEvent):Void 
	{
		if (keys[e.keyCode] == 0) 
			dispatcher.dispatchEvent(new KeyboardEvent(Input.KEYPRESS, true, true, 
			e.charCode, e.keyCode, e.keyLocation, e.ctrlKey, 
			e.altKey, e.shiftKey, e.controlKey, e.commandKey));
		keys[e.keyCode] = 1;
	}
}