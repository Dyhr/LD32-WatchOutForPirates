package com.tinyprogress.spaceship;
import com.tinyprogress.spaceship.actors.Asteroid;
import com.tinyprogress.spaceship.actors.Ship;
import com.tinyprogress.spaceship.actors.Wormhole;
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
		var enemy = new Ship("enemy_1");
		main.enemies.push(enemy);
		return enemy;
	}
	
	public static function spawnWave(main:Main, amount:Int) {
		var pos = new Vec2(Math.random()-0.5, Math.random()-0.5).normalise().mul(1000, true).add(main.treasure.body.position);
		
		var goal = new Wormhole(100, 0x282848, pos);
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