package com.tinyprogress.spaceship.system;

import com.tinyprogress.spaceship.actors.Ship;
import nape.callbacks.CbType;
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
	public static var cb:CbType = new CbType();
	public static var bodies:Map<Body,Entity> = new Map<Body,Entity>();
	
	public var parent(default, null):DisplayObjectContainer;
	public var space(default, null):Space;

	public var body(default, null):Body;
	public var sprite(default, null):Sprite;
	
	public var updates:Array<Entity->Float->Void> = [];
	public var tags:Array<String> = [];
	private var drag:Bool;
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	private function get_x() return body.position.x;
	private function get_y() return body.position.y;
	private function set_x(x) return body.position.x = x;
	private function set_y(y) return body.position.y = y;
	
	public function new(bodytype:BodyType, ?background:Bool = false, ?pos:Vec2 = null, ?drag:Bool = true) 
	{
		Main.instance.entities.push(this);
		this.parent = Main.instance.canvas;
		this.space = Main.instance.space;
		this.drag = drag;
		
		body = new Body(bodytype, pos);
		space.bodies.add(body);
		body.cbTypes.add(cb);
		bodies.set(body, this);
		if (!background) sprite = cast(parent.addChild(new Sprite()));
		else sprite = cast(parent.addChildAt(new Sprite(), 0));
	}
	public function dispose() {
		for (ent in Tagger.get("ship")) {
			var ship = cast(ent, Ship);
			for (grapple in ship.grapplers) {
				if(grapple.weld != null){
					if(grapple.weld.body1 == body || grapple.weld.body2 == body) {
						grapple.weld.space = null;
					}
				}
			}
		}
		
		Main.instance.entities.remove(this);
		body.cbTypes.remove(cb);
		space.bodies.remove(body);
		parent.removeChild(sprite);
		bodies.remove(body);
		Tagger.unset(this);
	}
	public function update(dt:Float) {
		if(drag){
			body.applyImpulse(body.velocity.mul(-0.01, true));
			body.applyAngularImpulse(body.angularVel * -4.1);
		}
		
		sprite.x = body.position.x;
		sprite.y = body.position.y;
		sprite.rotation = body.rotation * (180 / Math.PI);
		
		for (f in updates) f(this, dt);
	}
}