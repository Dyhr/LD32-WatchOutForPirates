package com.tinyprogress.spaceship.system;

import com.tinyprogress.spaceship.system.ShipBuilder.Value;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.shape.Polygon;
import openfl.display.Sprite;
import openfl.errors.Error;
import yaml.Parser;
import yaml.Yaml;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class ShipBuilder
{
	public function new() 
	{
		
	}	
	
	public function convert(yaml:String) {
		var out = new Array<Polygon>();
		var data:Array<Dynamic> = Yaml.parse(yaml, Parser.options().useObjects());
		for (poly in data) {
			var polygon = new Polygon();
			polygon.color = poly.color;
			polygon.solid = poly.solid;
			polygon.verts = new Array<Vertex>();
			var verts:Array<Dynamic> = poly.verts;
			for (vert in verts) {
				var x:Value, y:Value;
				
				switch (Type.typeof(vert[0])) {
				case TInt | TFloat: x = Number(vert[0]);
				case TClass(String): x = Reference(vert[0]);
				default:
					throw new Error("Malformed yaml");
				}
				switch (Type.typeof(vert[1])) {
				case TInt | TFloat: y = Number(vert[1]);
				case TClass(String): y = Reference(vert[1]);
				default:
					throw new Error("Malformed yaml");
				}
				
				polygon.verts.push(new Vertex(x,y));
			}
			out.push(polygon);
		}
		return out;
	}
	
	public function vertices(template:Array<Polygon>, values:Map<String,Float>):Array<Array<Vec2>> {
		for (value in values.keys()) if (value.indexOf("_n") < 0 && !values.exists(value+"_n")) values.set(value+"_n", -values[value]);
		var out = new Array<Array<Vec2>>();
		for (polygon in template) {
			if (polygon.verts.length < 3) throw new Error("Malformed polygon");
			var p = new Array<Vec2>();
			for (vertex in polygon.verts) {
				p.push(getvert(vertex, values));
			}
			out.push(p);
		}
		var center = new Vec2();
		for (vertices in out) for(vertex in vertices) center = center.add(vertex, true);
		center = center.mul(1 / [for(a in out)for(b in a)0].length);
		for (vertices in out) for(vertex in vertices) vertex.set(vertex.sub(center, true));
		return out;
	}
	
	public function build(sprite:Sprite, template:Array<Polygon>, values:Map<String,Float>) {
		for (value in values.keys()) if (value.indexOf("_n") < 0 && !values.exists(value+"_n")) values.set(value+"_n", -values[value]);
		var polygons = vertices(template, values);
		for (i in 0...template.length) {
			var polygon = template[i];
			var verts = polygons[i];
			sprite.graphics.beginFill(polygon.color);
			var start = verts[verts.length - 1];
			sprite.graphics.moveTo(start.x, start.y);
			for (vertex in verts) {
				sprite.graphics.lineTo(vertex.x, vertex.y);
			}
			sprite.graphics.endFill();
		}
	}
	public function solidify(body:Body, template:Array<Polygon>, values:Map<String,Float>) {
		for (value in values.keys()) if (value.indexOf("_n") < 0 && !values.exists(value+"_n")) values.set(value+"_n", -values[value]);
		var polygons = vertices(template, values);
		for (i in 0...template.length) {
			var polygon = template[i];
			var verts = polygons[i];
			if (polygon.solid) body.shapes.add(new nape.shape.Polygon(verts));
		}
	}
	private function getvert(vert:Vertex, values:Map<String,Float>):Vec2 {
		return new Vec2(switch(vert.x){
			case Number(v): v;
			case Reference(s): values.get(s);
		}, switch(vert.y){
			case Number(v): v;
			case Reference(s): values.get(s);
		});
	}
}

enum Value {
	Number(value:Float);
	Reference(name:String);
}
class Vertex {
	public var x:Value;
	public var y:Value;
	public function new(x:Value, y:Value) { this.x = x; this.y = y; };
}
class Polygon {
	public var color:Int;
	public var solid:Bool;
	public var verts:Array<Vertex>;
	public function new() { };
}