package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.Util;
import motion.Actuate;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import openfl.display.DisplayObjectContainer;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Asteroid extends Entity
{

	public function new(radius:Float, random:Float = 0.2) 
	{
		super(BodyType.DYNAMIC);
		
		var vertices:Array<Vec2> = [for (i in 0...8) {
			var angle = i * ((Math.PI * 2) / 8);
			new Vec2(Math.cos(angle) * radius, Math.sin(angle) * radius);
		}];
		var polygon = new Polygon(vertices);
		body.shapes.add(polygon);
		
		sprite.graphics.beginFill(0x8844AA);
		sprite.graphics.moveTo(vertices[vertices.length - 1].x, vertices[vertices.length - 1].y);
		for (vertex in vertices) {
			sprite.graphics.lineTo(vertex.x, vertex.y);
		}
		sprite.graphics.endFill();
		sprite.name = "Asteroid";
		
		sprite.scaleX = sprite.scaleY = 0;
		Actuate.tween(sprite, 0.8, { scaleX:1, scaleY:1 } ).delay(Math.random()*0.5);
	}	
}