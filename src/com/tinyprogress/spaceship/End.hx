package com.tinyprogress.spaceship;

import motion.Actuate;
import motion.easing.Quad;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class End extends Sprite
{
	private var text:String;
	private var field1:TextField;
	private var field2:TextField;
	private var field3:TextField;

	public function new(text:String, end:Bool) 
	{
		super();
		this.text = text;
		
		var format1 = new TextFormat("Comfortaa", 45, 0xDDBB77, true);
		format1.align = TextFormatAlign.CENTER;
		var format2 = new TextFormat("Comfortaa", 22, 0xDDBB77, true);
		format2.align = TextFormatAlign.CENTER;
		
		field1 = new TextField();
		field1.embedFonts = true;
		field1.defaultTextFormat = format1;
		field1.setTextFormat(format1);
		field1.autoSize = TextFieldAutoSize.LEFT;
		field1.antiAliasType = AntiAliasType.ADVANCED;
		field1.mouseEnabled = false;
		field1.sharpness = 400;
		addChild(field1);
		field1.text = text;
		
		field2 = new TextField();
		field2.embedFonts = true;
		field2.defaultTextFormat = format2;
		field2.setTextFormat(format2);
		field2.autoSize = TextFieldAutoSize.LEFT;
		field2.antiAliasType = AntiAliasType.ADVANCED;
		field2.mouseEnabled = false;
		field2.sharpness = 400;
		addChild(field2);
		field2.text = end?"[R]EPLAY?":"MOVE 'WASD' - GRAPPLE 'J' - RELEASE 'L'";
		
		field3 = new TextField();
		field3.embedFonts = true;
		field3.defaultTextFormat = format2;
		field3.setTextFormat(format2);
		field3.autoSize = TextFieldAutoSize.LEFT;
		field3.antiAliasType = AntiAliasType.ADVANCED;
		field3.mouseEnabled = false;
		field3.sharpness = 400;
		addChild(field3);
		field3.text = end?"":"MAGNETIZE 'H' - REEL IN 'K' OUT 'I'";
		
		addEventListener(Event.ADDED_TO_STAGE, init);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy);
	}
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		Actuate.stop(this);
	}
	
	private function init(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		//field1.width = field2.width = field3.width = stage.stageWidth;
		field1.x = - field1.width / 2;
		field1.y = - field1.height;
		field2.x = - field2.width / 2;
		field2.y = - field2.height / 2 + field1.height/2;
		field3.x = - field3.width / 2;
		field3.y = - field3.height / 2 + field1.height;
		x = stage.stageWidth / 2 ;
		y = stage.stageHeight / 2;
		
		//Actuate.tween(this, 1.2, { scaleX:0.86, scaleY:0.86 } ).ease(Quad.easeInOut).repeat(100000).reflect();
	}
}