package com.tinyprogress.spaceship;

import nape.phys.Body;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Wormhole extends Sprite
{
	private var radius:Float;
	private var body:Body;

	public function new(radius:Float, color:Int) 
	{
		super();
		graphics.beginFill(color);
		graphics.drawCircle(0,0,radius);
		graphics.endFill();
	}	
}