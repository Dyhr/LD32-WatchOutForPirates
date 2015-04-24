package com.tinyprogress.spaceship.system;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.space.Space;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Entity
{
	public var parent(default, null):DisplayObjectContainer;
	public var space(default, null):Space;

	public var body(default, null):Body;
	public var sprite(default, null):Sprite;
	
	public var updates:Array<Entity->Float->Void> = [];
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	private function get_x() return body.position.x;
	private function get_y() return body.position.y;
	private function set_x(x) return body.position.x = x;
	private function set_y(y) return body.position.y = y;
	
	public function new(bodytype:BodyType, ?pos:Vec2 = null) 
	{
		Main.instance.entities.push(this);
		this.parent = Main.instance;
		this.space = Main.instance.space;
		
		body = new Body(bodytype, pos);
		space.bodies.add(body);
		sprite = cast(parent.addChild(new Sprite()));
	}
	public function dispose() {
		Main.instance.entities.remove(this);
		space.bodies.remove(body);
		parent.removeChild(sprite);
	}
	public function update(dt:Float) {
		body.applyImpulse(body.velocity.mul(-0.01, true));
		body.applyAngularImpulse(body.angularVel * -4.1);
		
		sprite.x = body.position.x;
		sprite.y = body.position.y;
		sprite.rotation = body.rotation * (180 / Math.PI);
		
		for (f in updates) f(this, dt);
	}
}