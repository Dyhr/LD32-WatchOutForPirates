package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import motion.Actuate;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Wormhole extends Entity
{
	private var radius:Float;

	public function new(radius:Float, color:Int, pos:Vec2) 
	{
		super(BodyType.STATIC, pos);
		
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0,0,radius);
		sprite.graphics.endFill();
		
		sprite.scaleX = sprite.scaleY = 0;
		Actuate.tween(sprite, 0.5, { scaleX:1, scaleY:1 } ).delay(1);
	}	
}