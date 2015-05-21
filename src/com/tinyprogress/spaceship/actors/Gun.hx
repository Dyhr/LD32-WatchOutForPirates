package com.tinyprogress.spaceship.actors;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Gun {
	public var x:Float;
	public var y:Float;
	public var fx:Float;
	public var fy:Float;
	public var type:String;

	public function new(x:Float, y:Float, fx:Float, fy:Float, type:String) {
		this.fy = fy;
		this.fx = fx;
		this.type = type;
		this.y = y;
		this.x = x;
	}
}