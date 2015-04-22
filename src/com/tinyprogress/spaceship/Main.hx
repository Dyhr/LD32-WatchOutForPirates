package com.tinyprogress.spaceship;

import motion.Actuate;
import motion.easing.Quad;
import nape.constraint.DistanceJoint;
import nape.geom.Ray;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.MassMode;
import nape.shape.Polygon;
import nape.space.Space;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#if debug
import nape.util.ShapeDebug;
import nape.util.Debug;
#end

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */

class Main extends Sprite 
{
	static public inline var KEYPRESS:String = "keypress";
	
	#if debug
	private var debug:Debug;
	#end
	public var space:Space;
	public var keys:Array<Int>;
	public var follow:Map<Sprite,Body>;
	public var player:Ship;
	public var enemies:Array<Ship>;
	public var enemy_goal:Map<Ship,Wormhole>;
	public var ships:Array<Ship>;
	public var holes:Array<Wormhole>;
	public var treasure:Body;
	public var goal:Wormhole;
	public var treasure_sprite:Sprite;
	public var ready:Bool;
	public var numEnemies:Int;

	public function new() 
	{
		super();
		
		if (stage != null) {
            init(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
	}
	
	private function init(e:Event) {
		#if debug
		debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
		debug.drawConstraints = true;
		debug.drawCollisionArbiters = true;
        addChild(debug.display);
		#end	
		space = new Space(Vec2.weak(0, 0));
		keys = [ for (i in 0...1024) 0 ];
		enemies = [];
		ships = [];
		holes = [];
		numEnemies = 0;
		follow = new Map<Sprite, Body>();
		enemy_goal = new Map<Ship, Wormhole>();
		
		setup();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		stage.addEventListener(Main.KEYPRESS, keyPress);
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function setup() {
		player = new Ship("player", this);
		player.sprite.scaleX = player.sprite.scaleY = 0;
		Actuate.tween(player.sprite, 0.5, { scaleX:1, scaleY:1 } ).delay(2.5);
		
		treasure = Util.createAsteroid(this, 60);
		var m = treasure.mass;
		treasure.massMode = MassMode.FIXED;
		treasure.mass = m*6;
		var vertices = [for (i in 0...8) {
			var angle = (i+0.5) * ((Math.PI * 2) / 8);
			new Vec2(Math.cos(angle) * 30, Math.sin(angle) * 30);
		}];
		treasure_sprite = [for(k in follow.keys()) if(follow[k]==treasure) k][0];
		Util.buildShape(vertices, 0xDDAA11, treasure_sprite);
		treasure.position.x = stage.stageWidth / 2;
		treasure.position.y = stage.stageHeight / 2;
		
		for (i in 0...65) {
			var asteroid = Util.createAsteroid(this,30+20*Math.random());
			asteroid.position.x = 2000 * Math.random();
			asteroid.position.y = -1000+2000 * Math.random();
		}
		
		player.body.position.x = 1700;
		player.body.rotation = Math.PI;
		
		goal = new Wormhole(100, 0x282888);
		goal.scaleX = goal.scaleY = 0;
		var goal_b = new Body(BodyType.STATIC, Vec2.weak(2000, 0));
		addChildAt(goal, 0);
		goal.x = 2000;
		holes.push(goal);
		Actuate.tween(goal, 0.5, { scaleX:1, scaleY:1 } ).delay(2);
		
		stage.addChild(new TargetArrow(0xDDAA11, player.body, treasure));
		stage.addChild(new TargetArrow(0x282888, player.body, goal_b));
		
		var intro = new End("WATCH OUT FOR PIRATES", false);
		stage.addChild(intro);
		intro.y = -stage.stageHeight;
		Actuate.tween(intro, 0.5, { y:stage.stageHeight/2 } ).ease(Quad.easeOut).onComplete(function(intro:End) {			
			Actuate.tween(intro, 1, { scaleX:0.9, scaleY:0.9 } ).ease(Quad.easeInOut).repeat(12).reflect().onComplete(function(intro:End) {				
				Actuate.tween(intro, 0.5, { y:-stage.stageHeight } ).ease(Quad.easeIn).onComplete(stage.removeChild, [intro]);
			}, [intro]);
		}, [intro]);
	}
	
	private function destroy():Void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		stage.removeEventListener(Main.KEYPRESS, keyPress);
		stage.removeEventListener(Event.ENTER_FRAME, update);
		
		space.clear();
		
		stage.removeChildren(1, stage.numChildren - 1);
		removeChildren(0, numChildren - 1);
	}
	private function reset() {
		destroy();
		init(null);
	}
	
	private function keyUp(e:KeyboardEvent):Void 
	{
		keys[e.keyCode] = 0;
	}
	
	private function keyDown(e:KeyboardEvent):Void 
	{
		if (keys[e.keyCode] == 0) 
			dispatchEvent(new KeyboardEvent(Main.KEYPRESS, true, true, 
			e.charCode, e.keyCode, e.keyLocation, e.ctrlKey, 
			e.altKey, e.shiftKey, e.controlKey, e.commandKey));
		keys[e.keyCode] = 1;
	}
	
	private function keyPress(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.R) reset();
		if (e.keyCode == Keyboard.L) player.release();
		if (e.keyCode == Keyboard.J) player.shoot();
	}
	
	private function update(e:Event):Void 
	{
		var stage_center = new Vec2(stage.stageWidth / 2, stage.stageHeight / 2);
        space.step(1 / stage.frameRate);
		
		for (ship in ships) {
			ship.update(1 / stage.frameRate, this);
		}
		
		for (key in follow.keys()) {
			var sprite = key;
			var body = follow[key];
			follow[key].applyImpulse(follow[key].velocity.mul(-0.01, true));
			follow[key].applyAngularImpulse(follow[key].angularVel * -4.1);
			
			key.visible = body.position.sub(stage_center.sub(Vec2.weak(x,y),true),true).length < stage.stageWidth;
			if(key.visible){
				key.x = follow[key].position.x;
				key.y = follow[key].position.y;
				key.rotation = follow[key].rotation * (180 / Math.PI);
			} else { 
				if(sprite.name == "Asteroid")
					body.velocity.set(Vec2.weak());
			}
		}
		
		for (enemy in enemies) {
			var d = new Vec2(enemy.body.position.x - treasure.position.x, enemy.body.position.y - treasure.position.y);
			var t = new Vec2(enemy.body.position.x - enemy_goal[enemy].x, enemy.body.position.y - enemy_goal[enemy].y);
			var angle = switch(enemy.attached.indexOf(treasure) < 0) {
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
			if (enemy.attached.indexOf(treasure) < 0 && d.length < 200 && enemy.target() == treasure) {
				enemy.shoot();
			}
		}
		
		if (numEnemies < 3 && ready) {
			numEnemies += 5;
			Actuate.timer(10).onComplete(function() { Util.spawnWave(this, 4); }, []);
		}
		
		for (hole in holes) {
			var reach = 200;
			var d = new Vec2(hole.x - treasure.position.x, hole.y - treasure.position.y);
			var distance = d.length - reach;
			if (d.length < reach) {
				treasure.applyImpulse(d.mul(2*((reach-d.length)/reach), true).sub(treasure.velocity.mul(0.6, true),true));
				if (d.length < 10) {
					removeChild(hole);
					holes.remove(hole);
					
					for (s in ships) s.release();
					treasure.space = null;
					follow.remove(treasure_sprite);
					removeChild(treasure_sprite);
					
					if (hole == goal) {
						stage.addChild(new End("GREAT PROFIT", true));
					} else {
						stage.addChild(new End("GREAT LOSS", true));
					}
					
					ready = false;
				}
			}
		}
		
		if (player.body.space != null) {
			if (!ready && player.attached.indexOf(treasure) >= 0) ready = true;
			
			player.move((keys[Keyboard.D] - keys[Keyboard.A]), (keys[Keyboard.W] - keys[Keyboard.S]));
			
			if (keys[Keyboard.H] == 1 && player.grapples.length > 1) {
				var bodies = [for (grapple in player.grapples) grapple.body2];
				var center = Vec2.weak();
				for (body in bodies) center = center.add(body.position, true);
				center = center.mul(1 / bodies.length);
				
				for (body in bodies) {
					var dir = center.sub(body.position);
					if (dir.length == 0) continue;
					body.applyImpulse(dir.normalise().mul(30, true));
				}
			}
			
			var pull = (keys[Keyboard.I] - keys[Keyboard.K]) * 1.1;
			if (pull != 0) {
				for (c in player.grapples) {
					c.jointMax = Math.max(c.jointMax+pull,0);
				}
			}
			
			x = -player.body.position.x + stage.stageWidth / 2;
			y = -player.body.position.y + stage.stageHeight / 2;
		}
		
		#if debug
        debug.clear();
        debug.draw(space);
        debug.flush();
		#end
	}
}
