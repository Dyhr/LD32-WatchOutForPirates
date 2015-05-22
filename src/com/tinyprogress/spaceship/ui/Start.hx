package com.tinyprogress.spaceship.ui;

import motion.Actuate;
import openfl.display.Sprite;
import openfl.events.Event;
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
	
	private var buttons:Array<TextField> = [];

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
		
		format.size = 24;
		var butt = new TextField();
		butt.embedFonts = true;
		butt.defaultTextFormat = format;
		butt.setTextFormat(format);
		butt.autoSize = TextFieldAutoSize.LEFT;
		butt.antiAliasType = AntiAliasType.ADVANCED;
		butt.mouseEnabled = false;
		butt.text = "Play";
		addChild(butt);
		buttons.push(butt);
		
		butt = new TextField();
		butt.embedFonts = true;
		butt.defaultTextFormat = format;
		butt.setTextFormat(format);
		butt.autoSize = TextFieldAutoSize.LEFT;
		butt.antiAliasType = AntiAliasType.ADVANCED;
		butt.mouseEnabled = false;
		butt.text = "Credits";
		addChild(butt);
		buttons.push(butt);
		
		butt = new TextField();
		butt.embedFonts = true;
		butt.defaultTextFormat = format;
		butt.setTextFormat(format);
		butt.autoSize = TextFieldAutoSize.LEFT;
		butt.antiAliasType = AntiAliasType.ADVANCED;
		butt.mouseEnabled = false;
		butt.text = "Quit";
		addChild(butt);
		buttons.push(butt);
		
		addEventListener(Event.ENTER_FRAME, update);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy);
	}
	
	private function update(e:Event):Void 
	{
		title.x = - title.width / 2 + stage.stageWidth/2;
		title.y = stage.stageHeight / 4;
		
		var pos = stage.stageHeight/4;
		for (button in buttons) {
			button.x = - button.width / 2 + stage.stageWidth / 2;
			button.y = stage.stageHeight / 4 + title.height + pos;
			pos += button.height + 6;
		}
	}
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		Actuate.stop(this);
	}
}