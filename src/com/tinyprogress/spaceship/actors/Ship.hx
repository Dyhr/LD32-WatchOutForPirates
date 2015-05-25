package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.system.Tagger;
import com.tinyprogress.spaceship.system.ShipBuilder;
import motion.Actuate;
import motion.easing.Expo;
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
	public var grapplers:Array<Grapple>;
	private var guns:Array<Gun>;
	public var attached(get, never):Array<Body>;
	private function get_attached() return [for (grapple in grapplers) if(grapple.weld != null) grapple.weld.body2];
	public var forward_force:Float;
	public var turn_force:Float;
	public var max_grapples:Int;
	public var death_force:Float;

	public function new(type:String) {
		super(BodyType.DYNAMIC);
		
		var builder = new ShipBuilder();
		var data = Yaml.parse(Assets.getText("data/ships.yaml"), Parser.options().useObjects());
		var ship_data = Reflect.field(data, type);
		if (ship_data == null) {
			throw new ArgumentError("Ship type not found: "+type);
		}
		forward_force = ship_data.force.forward;
		turn_force = ship_data.force.turn;
		max_grapples = ship_data.grapples;
		death_force = ship_data.death;
		
		var param = ship_data.param;
		var map = [for(field in Reflect.fields(param)) {
			field => Reflect.field(param, field);
		}];
		
		grapplers = new Array<Grapple>();
		guns = new Array<Gun>();
		var template = builder.convert(Assets.getText("data/"+ship_data.ship), guns, map);
		var verts:Array<Array<Vec2>> = builder.vertices(template, map);
		
		builder.solidify(body, template, map);
		builder.build(sprite, template, map);
		
		Tagger.set(this, "ship");
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
		
		if (body.crushFactor() > death_force) {
			if (tags.indexOf("enemy") >= 0) {
				Main.instance.numEnemies--;
			}
			dispose();
		}
	}
	
	public override function dispose() {
		for (grapple in grapplers) {
			grapple.dispose();
		}
		while (grapplers.length > 0) {
			grapplers.pop();
		}
		super.dispose();
	}
	
	public function release() {
		for (grapple in grapplers) {
			if (grapple.weld != null) grapple.weld.space = null;
			if (grapple.listener != null) grapple.listener.space = null;
			if (grapple.distance == null) {
				grapple.distance = new DistanceJoint(grapple.body, grapple.parente.body, Vec2.weak(), Vec2.weak(), 0, grapple.body.position.sub(grapple.parente.body.position,true).length);
				grapple.distance.space = body.space;
			}
			Actuate.tween(grapple.distance, 1, {jointMax:2}).ease(Expo.easeOut).onComplete(function(){
				grapple.dispose();
				grapplers.remove(grapple);
			},[]);
		}
	}
	
	public function shoot() {
		if (body.space == null) return;
		if (grapplers.length < max_grapples) {
			var grapple = new Grapple(this, new Vec2(80, 0));
			grapplers.push(grapple);
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
}