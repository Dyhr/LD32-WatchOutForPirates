package com.tinyprogress.spaceship.ui;

import motion.Actuate;
import openfl.display.DisplayObject;
import openfl.display.SimpleButton;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.system.System;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Start extends Sprite
{
	private var format:TextFormat = new TextFormat("Comfortaa", 32, 0xDDBB77, true,null,null,null,null,TextFormatAlign.CENTER);
	private var title:TextField;
	private var credits:TextField;
	
	private var buttons:Array<DisplayObject> = [];
	private var back:DisplayObject;

	public function new(main:Main) 
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
		
		credits = new TextField();
		format.size = 20;
		credits.embedFonts = true;
		credits.defaultTextFormat = format;
		credits.setTextFormat(format);
		credits.autoSize = TextFieldAutoSize.CENTER;
		credits.antiAliasType = AntiAliasType.ADVANCED;
		credits.mouseEnabled = false;
		credits.multiline = true;
		credits.text = "Made by:\nRasmus Dyhr Larsen";
		
		var butt = create("Play", 24);
		buttons.push(butt);
		bind(butt, function(e:MouseEvent) {
			main.start();
		});
		butt = create("Controls (Pending)", 24);
		buttons.push(butt);
		bind(butt, function(e:MouseEvent) {
			// TODO
		});
		butt = create("Credits", 24);
		buttons.push(butt);
		bind(butt, function(e:MouseEvent) {
			removeChild(title);
			for (button in buttons) removeChild(button);
			addChild(back);
			addChild(credits);
		});
		butt = create("Quit", 24);
		buttons.push(butt);
		bind(butt, function(e:MouseEvent) {
			System.exit(0);
		});
		
		back = create("Back", 24);
		bind(back, function(e:MouseEvent) {
			addChild(title);
			for (button in buttons) addChild(button);
			removeChild(back);
			removeChild(credits);
		});
		removeChild(back);
		
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
		textfield.height = size;
		
		var hit = new Sprite();
		hit.graphics.beginFill();
		hit.graphics.drawRect(0, 0, textfield.width, textfield.height);
		hit.graphics.endFill();
		
		var button = new SimpleButton(textfield, textfield, textfield, hit);
		addChild(button);
		return button;
	}
	private function bind(button:DisplayObject, click:Dynamic->Void) {
		button.addEventListener(MouseEvent.MOUSE_UP, click);
	}
	
	private function update(e:Event):Void 
	{
		title.x = - title.width / 2 + stage.stageWidth/2;
		title.y = stage.stageHeight / 4;
		credits.x = - credits.width / 2 + stage.stageWidth/2;
		credits.y = stage.stageHeight / 4;
		
		var pos = stage.stageHeight/4;
		for (button in buttons) {
			button.x = - button.width / 2 + stage.stageWidth / 2;
			button.y = stage.stageHeight / 4 + title.height + pos;
			pos += button.height + 6;
		}
		
		back.x = - back.width / 2 + stage.stageWidth/2;
		back.y = stage.stageHeight-(stage.stageHeight / 4+back.height);
	}
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		Actuate.stop(this);
	}
}