package com.tinyprogress.spaceship;
import com.tinyprogress.spaceship.actors.Asteroid;
import com.tinyprogress.spaceship.actors.Ship;
import com.tinyprogress.spaceship.actors.Wormhole;
import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.system.Tagger;
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
		Tagger.set(enemy, "enemy");
		enemy.updates.push(function(entity:Entity, dt:Float) {
			var d = enemy.body.position.sub(main.treasure.body.position);
			var t = new Vec2(enemy.body.position.x - main.enemy_goal[enemy].x, enemy.body.position.y - main.enemy_goal[enemy].y);
			var angle = switch(enemy.attached.indexOf(main.treasure.body) < 0) {
			case true:
				enemy.body.rotation - Math.atan2(d.y, d.x);
			case false:
				enemy.body.rotation - Math.atan2(t.y, t.x);
			}
			while (angle < -Math.PI) angle += Math.PI * 2;
			while (angle >  Math.PI) angle -= Math.PI * 2;
			
			var on_track = Math.PI / 2 - Math.abs(angle) < Math.PI / 8;
			enemy.move(angle, on_track ? 1 : 0);
			if(on_track)
				enemy.body.applyAngularImpulse(enemy.body.angularVel * 10 * (Math.PI / 8 - Math.abs(angle)));
			if (enemy.attached.indexOf(main.treasure.body) < 0 && d.length < 200 && enemy.target() == main.treasure.body) {
				enemy.shoot();
			}
		});
		return enemy;
	}
	
	public static function spawnWave(main:Main, amount:Int) {
		var pos = new Vec2(Math.random()-0.5, Math.random()-0.5).normalise().mul(1000, true).add(main.treasure.body.position);
		
		var goal = new Wormhole(100, 0x282848, pos);
		Tagger.set(goal, "goal");
		goal.updates.push(main.updatewormhole);
		
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
		/*for (ship in ships) {
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
		}*/
	}
}