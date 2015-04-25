package com.tinyprogress.spaceship.system;

import com.tinyprogress.spaceship.system.ShipBuilder.Value;
import nape.geom.Vec2;
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
			polygon.color = poly.polygon.color;
			polygon.verts = new Array<Vertex>();
			var verts:Array<Dynamic> = poly.polygon.verts;
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
	
	public function build(sprite:Sprite, template:Array<Polygon>, values:Map<String,Float>) {
		for (polygon in template) {
			if (polygon.verts.length < 3) throw new Error("Malformed polygon");
			sprite.graphics.beginFill(polygon.color);
			var start = getvert(polygon.verts[polygon.verts.length - 1], values);
			sprite.graphics.moveTo(start.x, start.y);
			for (vertex in polygon.verts) {
				var v = getvert(vertex, values);
				sprite.graphics.lineTo(v.x, v.y);
			}
			sprite.graphics.endFill();
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
	public var verts:Array<Vertex>;
	public function new() { };
}