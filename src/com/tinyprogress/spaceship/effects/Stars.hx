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
	private var wid:Float;
	private var hei:Float;
	
	public function new() 
	{
		super();
		
		wid = 0;
		arr = [for (i in 0...2) {
			var sprite = new Sprite();
			sprite.cacheAsBitmap = true;
			addChild(sprite);
			sprite;
		}];
	}
	
	public function update(x:Float, y:Float) {
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
		}
		for (i in 0...arr.length) {
			arr[i].x = Math.floor(x/((arr.length-i)*32)) % stage.stageWidth - stage.stageWidth;
			arr[i].y = Math.floor(y/((arr.length-i)*32)) % stage.stageHeight;
		}
	}
}