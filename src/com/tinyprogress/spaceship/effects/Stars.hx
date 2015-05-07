package com.tinyprogress.spaceship.effects;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Stars extends Sprite
{
	private var arr:Array<Sprite>;
	private var bits:Array<Bitmap>;
	private var wid:Float;
	private var hei:Float;
	
	public function new() 
	{
		super();
		
		wid = 0;
		arr = [for (i in 0...2) {
			var sprite = new Sprite();
			//sprite.cacheAsBitmap = true;
			sprite;
		}];
		bits = [for (s in arr) {
			var data = new BitmapData(cast(s.width), cast(s.height), true, 0x00000000);
			data.draw(s);
			cast(addChild(new Bitmap(data, PixelSnapping.NEVER, true)));
		}];
	}
	
	public function update(x:Float, y:Float) {
		var changed = false;
		if (wid < stage.stageWidth*2) {
			var w = stage.stageWidth*2 - wid;
			
			if(hei != 0){
				for(i in 0...arr.length){
					arr[i].graphics.beginFill(0xAAAABB);
					for (j in 0...Math.floor(w / 12)) arr[i].graphics.drawCircle(wid + Math.random() * w, Math.random() * hei, i+1);
					arr[i].graphics.endFill();
				}
			}
			wid = stage.stageWidth*2;
			changed = true;
		}
		if (hei < stage.stageHeight*2) {
			var h = stage.stageHeight * 2 - hei;
			
			if(wid != 0){
				for(i in 0...arr.length){
					arr[i].graphics.beginFill(0xAAAABB);
					for (j in 0...Math.floor(h / 12)) arr[i].graphics.drawCircle(Math.random() * wid, hei + Math.random() * h, i+1);
					arr[i].graphics.endFill();
				}
			}
			hei = stage.stageHeight*2;
			changed = true;
		}
		if (changed) {
			for(i in 0...bits.length){
				var data = new BitmapData(stage.stageWidth*2, stage.stageHeight*2, true, 0x00000000);
				data.draw(arr[i]);
				bits[i].bitmapData = data;
			}
		}
		for (i in 0...bits.length) {
			bits[i].x = Math.floor(x/((bits.length-i)*32)) % stage.stageWidth - stage.stageWidth;
			bits[i].y = Math.floor(y/((bits.length-i)*32)) % stage.stageHeight;
		}
	}
}