package com.tinyprogress.spaceship.effects;

import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.system.Tagger;
import motion.Actuate;
import motion.easing.Quad;
import nape.geom.Vec2;
import nape.phys.BodyType;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Magnet extends Entity
{
	public static var targets:Array<Entity> = new Array<Entity>();
	
	private var target:Entity;
	private var circles:Array<Sprite>;
	
	public function new(target:Entity) 
	{
		super(BodyType.STATIC, true, target.body.position, false);
		if (targets.indexOf(target) >= 0) {
			dispose();
			return;
		}
		targets.push(target);
		this.target = target;
		this.circles = [];
		Tagger.set(this, "magnet");
		
		updates.push(update_);
		
		var circle:Sprite = cast(sprite.addChild(new Sprite()));
		circles.push(circle);
		circle.graphics.beginFill(0xAAAAFF);
		circle.graphics.drawCircle(0,0,88);
		circle.graphics.drawCircle(0,0,80);
		circle.graphics.endFill();
		Actuate.tween(circle, 0.5, { scaleX:0, scaleY:0 } ).ease(Quad.easeIn).repeat(1000);
		Actuate.timer(0.25).onComplete(function() { 
			var circle:Sprite = cast(sprite.addChild(new Sprite()));
			circles.push(circle);
			circle.graphics.beginFill(0xAAAAFF);
			circle.graphics.drawCircle(0,0,88);
			circle.graphics.drawCircle(0,0,80);
			circle.graphics.endFill();
			Actuate.tween(circle, 0.5, { scaleX:0, scaleY:0 } ).ease(Quad.easeIn).repeat(1000);
		}, []);
	}
	override public function dispose() 
	{
		super.dispose();
		for(circle in circles) Actuate.stop(circle);
		targets.remove(target);
	}
	public function update_(entity:Entity, dt:Float) {
		sprite.x = target.body.position.x;
		sprite.y = target.body.position.y;
	}
}