package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.system.ShipBuilder;
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
	public var grapplers:Map<Entity, Grapple>;
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
		var width:Float = ship_data.width;
		var widthnose:Float = ship_data.widthnose;
		var length:Float = ship_data.length;
		forward_force = ship_data.force.forward;
		turn_force = ship_data.force.turn;
		max_grapples = ship_data.grapples;
		death_force = ship_data.death;
		
		grapplers = new Map<Entity,Grapple>();
		var template = builder.convert(Assets.getText("data/player.yaml"));
		var map = ["length"=>length, "wid"=>width, "nwid"=>widthnose];
		var verts:Array<Array<Vec2>> = builder.vertices(template, map);
		
		builder.solidify(body, template, map);
		builder.build(sprite, template, map);
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
		release();
		super.dispose();
	}
	
	public function release() {
		if (body.space == null) return;
		for (grapple in grapplers) {
			grapple.dispose();
		}
	}
	
	public function shoot() {
		if (body.space == null) return;
		if (0 < max_grapples) {
			var grapple = new Grapple(this,new Vec2(60,0));
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