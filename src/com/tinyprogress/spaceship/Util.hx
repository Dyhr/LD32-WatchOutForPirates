package com.tinyprogress.spaceship;
import motion.Actuate;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Util
{
	public static inline function createEnemy(main:Main)
	{
		var enemy = new Ship("enemy_1", main);
		main.enemies.push(enemy);
		return enemy;
	}
	
	public static inline function createAsteroid(main:Main, radius:Float, random:Float = 0.2) {
		var vertices = new Array<Vec2>();
		
		for (i in 0...8) {
			var angle = i * ((Math.PI * 2) / 8);
			vertices.push(new Vec2(Math.cos(angle) * radius, Math.sin(angle) * radius));
		}
		
		var asteroid_body = buildBody(vertices, BodyType.DYNAMIC);
		asteroid_body.space = main.space;
		
		var asteroid = new Sprite();
		buildShape(vertices, 0x8844AA, asteroid);
		main.addChild(asteroid);
		asteroid.name = "Asteroid";
		
		asteroid.scaleX = asteroid.scaleY = 0;
		Actuate.tween(asteroid, 0.8, { scaleX:1, scaleY:1 } ).delay(Math.random()*0.5);
		
		main.follow.set(asteroid, asteroid_body);
		return asteroid_body;
	}
	
	public static inline function buildBody(vertices:Array<Vec2>, type:BodyType):Body {
		var body = new Body(type);
		var polygon = new Polygon(vertices);
		if(vertices.length > 0){
			var center = Vec2.weak();
			for (vertex in vertices) center = center.add(vertex, true);
			center = center.mul(1/vertices.length, true);
			polygon.localCOM = center;
		}
		body.shapes.add(polygon);
		return body;
	}
	public static inline function buildShape(vertices:Array<Vec2>, color:Int, sprite:Sprite) {
		var center = Vec2.weak();
		for (vertex in vertices) center = center.add(vertex, true);
		center = center.mul(1 / vertices.length);
		
		sprite.graphics.beginFill(color);
		sprite.graphics.moveTo(vertices[vertices.length - 1].x, vertices[vertices.length - 1].y);
		for (vertex in vertices) {
			sprite.graphics.lineTo(vertex.x, vertex.y);
		}
		sprite.graphics.endFill();
	}
	
	public static function spawnWave(main:Main, amount:Int) {
		var pos = new Vec2(Math.random()-0.5, Math.random()-0.5).normalise().mul(1000, true).add(main.treasure.position);
		
		var goal = new Wormhole(100, 0x282848);
		main.addChildAt(goal, 0);
		goal.x = pos.x; goal.y = pos.y;
		main.holes.push(goal);
		
		for (i in 0...amount) {
			var enemy = Util.createEnemy(main);
			var angle = Math.random() * Math.PI * 2;
			enemy.body.position.x = pos.x + Math.cos(angle) * 50 * 2;
			enemy.body.position.y = pos.y + Math.sin(angle) * 50 * 2;
			main.enemy_goal.set(enemy, goal);
		}
	}
	
	public static function release(body:Body, ships:Array<Ship>) 
	{
		for (ship in ships) {
			for (joint in ship.grapples) {
				if (joint.body1 == body || joint.body2 == body) {
					joint.space = null;
					ship.grapples.remove(joint);
					ship.sprite.parent.removeChild(ship.grapplers[joint]);
					ship.grapplers.remove(joint);
					if(ship.attached.indexOf(joint.body1)>=0)ship.attached.remove(joint.body1);
					if(ship.attached.indexOf(joint.body2)>=0)ship.attached.remove(joint.body2);
				}
			}
		}
	}
}