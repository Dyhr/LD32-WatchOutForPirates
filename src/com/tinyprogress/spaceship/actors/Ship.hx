package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import nape.constraint.DistanceJoint;
import nape.geom.Ray;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.errors.ArgumentError;
import yaml.Parser;
import yaml.util.ObjectMap.AnyObjectMap;
import yaml.Yaml;


/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Ship extends Entity
{
	public var grapples:Array<DistanceJoint>;
	public var grapplers:Map<DistanceJoint,Grapple>;
	public var attached:Array<Body>;
	public var forward_force:Float;
	public var turn_force:Float;
	public var max_grapples:Int;
	public var death_force:Float;

	public function new(type:String) {
		super(BodyType.DYNAMIC);
		
		var data = Yaml.parse(Assets.getText("data/ships.yaml"), Parser.options().useObjects());
		var ship_data = Reflect.field(data, type);
		if (ship_data == null) {
			throw new ArgumentError("Ship type not found: "+type);
		}
		var color = (ship_data.main_color.r << 16) | (ship_data.main_color.g << 8) | (ship_data.main_color.b << 0);
		var width:Float = ship_data.width;
		var length:Float = ship_data.length;
		forward_force = ship_data.force.forward;
		turn_force = ship_data.force.turn;
		max_grapples = ship_data.grapples;
		death_force = ship_data.death;
		
		grapples = [];
		grapplers = new Map<DistanceJoint,Grapple>();
		attached = [];
		var verts:Array<Vec2> = [
			new Vec2(length, 0),
			new Vec2(0, width),
			new Vec2(0, -width),
		];
		
		var polygon = new Polygon(verts);
		if(verts.length > 0){
			/*var center = Vec2.weak();
			for (vertex in verts) center = center.add(vertex, true);
			center = center.mul(1/verts.length, true);
			polygon.localCOM = center;*/
		}
		body.shapes.add(polygon);
		
		sprite.graphics.beginFill(color);
		sprite.graphics.moveTo(verts[verts.length - 1].x, verts[verts.length - 1].y);
		for (vertex in verts) {
			sprite.graphics.lineTo(vertex.x, vertex.y);
		}
		sprite.graphics.endFill();
		
		Main.instance.ships.push(this);
	}
	
	public function move(x:Float, y:Float) {
		if (body.space == null) return;
		x *= turn_force;
		y *= forward_force;
		
		if (y != 0) {
			var dir = Vec2.weak(Math.cos(body.rotation), Math.sin(body.rotation)).mul(y);
			body.applyImpulse(dir);
		}
		
		if (x != 0) {
			body.applyAngularImpulse(x);
		}
	}
	
	public override function update(dt:Float) {
		super.update(dt);
		
		for (g in grapplers) g.update();
		if (body.crushFactor() > death_force) {
			if (Main.instance.enemies.indexOf(this) >= 0) {
				Main.instance.enemies.remove(this);
				Main.instance.numEnemies--;
			}
			Util.release(body,Main.instance.ships);
			release();
			dispose();
			Main.instance.ships.remove(this);
		}
	}
	
	public function release() {
		if (body.space == null) return;
		while (grapples.length > 0) {
			var c = grapples.pop();
			c.space = null;	
			sprite.parent.removeChild(grapplers[c]);
			grapplers.remove(c);
			attached.pop();
		}
	}
	
	public function shoot() {
		if (body.space == null) return;
		if(grapples.length < max_grapples){
			var dir = new Vec2(Math.cos(body.rotation), Math.sin(body.rotation));
			var ray = new Ray(body.position.add(dir, true), dir);
			var hit = body.space.rayCast(ray);
			if (hit != null) {
				grapple(hit.shape.body, body, ray.at(hit.distance));
				attached.push(hit.shape.body);
				hit.dispose();
			}
		}
	}
	
	public function target():Body {
		if (body.space == null) return null;
		var dir = new Vec2(Math.cos(body.rotation), Math.sin(body.rotation));
		var ray = new Ray(body.position.add(dir, true), dir);
		var hit = body.space.rayCast(ray);
		if (hit != null) {
			var t = hit.shape.body;
			hit.dispose();
			return t;
		}
		return null;
	}
	
	private function grapple(grappler:Body, graplee:Body, point:Vec2) {
		if (body.space == null) return;
		if (grappler == graplee) return;
		var constraint = new DistanceJoint(graplee, grappler, Vec2.weak(0, 0), grappler.worldPointToLocal(point, true), 0, Vec2.distance(graplee.position, point));
		constraint.space = body.space;
		var grappl = new Grapple(graplee, grappler, new Vec2(0, 0), grappler.worldPointToLocal(point)); 
		sprite.parent.addChild(grappl);
		grapples.push(constraint);
		grapplers.set(constraint, grappl);
	}
}