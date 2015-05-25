package com.tinyprogress.spaceship.ui;

import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Start extends Sprite
{
	private var format:TextFormat = new TextFormat("Comfortaa", 32, 0xDDBB77, true);
	private var title:TextField;
	
	private var buttons:Array<DisplayObject> = [];

	public function new() 
	{
		super();
		
		title = new TextField();
		title.embedFonts = true;
		title.defaultTextFormat = format;
		title.setTextFormat(format);
		title.autoSize = TextFieldAutoSize.LEFT;
		title.antiAliasType = AntiAliasType.ADVANCED;
		title.mouseEnabled = false;
		title.text = "Watch Out for Pirates";
		addChild(title);
		
		var butt = create("Play", 24);
		butt = create("Credits", 24);
		butt = create("Quit", 24);
		bind(butt, function(e:MouseEvent) {
			trace("Wuite");
		});
		
		addEventListener(Event.ENTER_FRAME, update);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy);
	}
	
	private function create(text:String, size:Int):DisplayObject {
		format.size = size;
		var textfield = new TextField();
		textfield.embedFonts = true;
		textfield.defaultTextFormat = format;
		textfield.setTextFormat(format);
		textfield.autoSize = TextFieldAutoSize.LEFT;
		textfield.antiAliasType = AntiAliasType.ADVANCED;
		textfield.mouseEnabled = false;
		textfield.multiline = false;
		textfield.text = text;
		
		var hit = new Sprite();
		hit.graphics.beginFill();
		hit.graphics.drawRect(0, 0, textfield.width, textfield.height);
		hit.graphics.endFill();
		
		var button = new SimpleButton(textfield, textfield, textfield, hit);
		addChild(button);
		buttons.push(button);
		return button;
	}
	private function bind(button:DisplayObject, click:Dynamic->Void) {
		button.addEventListener(MouseEvent.MOUSE_UP, click);
	}
	
	private function update(e:Event):Void 
	{
		title.x = - title.width / 2 + stage.stageWidth/2;
		title.y = stage.stageHeight / 4;
		
		var pos = stage.stageHeight/4;
		for (button in buttons) {
			button.x = - button.width / 2 + stage.stageWidth / 2;
			button.y = stage.stageHeight / 4 + title.height + pos;
			pos += button.height/4 + 6;
		}
	}
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		Actuate.stop(this);
	}
}