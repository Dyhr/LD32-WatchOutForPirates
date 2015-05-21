package com.tinyprogress.spaceship;

import com.tinyprogress.spaceship.actors.Asteroid;
import com.tinyprogress.spaceship.actors.Ship;
import com.tinyprogress.spaceship.actors.Wormhole;
import com.tinyprogress.spaceship.effects.Magnet;
import com.tinyprogress.spaceship.effects.Stars;
import com.tinyprogress.spaceship.system.Entity;
import com.tinyprogress.spaceship.system.Input;
import com.tinyprogress.spaceship.system.Tagger;
import com.tinyprogress.spaceship.ui.End;
import com.tinyprogress.spaceship.ui.TargetArrow;
import motion.Actuate;
import motion.easing.Quad;
import nape.geom.Vec2;
import nape.phys.MassMode;
import nape.space.Space;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
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
	static public var instance:Main;
	
	#if debug
	private var debug:Debug;
	#end
	public var space(default, null):Space;
	public var entities(default, null):Array<Entity>;
	public var canvas(default, null):Sprite;
	
	public var player:Ship;
	public var enemy_goal:Map<Ship,Wormhole>;
	public var treasure:Entity;
	public var goal:Wormhole;
	public var ready:Bool;
	public var numEnemies:Int;
	public var playing(default, set):String;
	private var music:SoundChannel;
	private function set_playing(file:String) {
		if (file == playing) return playing;
		var sound = Assets.getMusic("music/"+file);
		if (music != null) music.stop();
		music = sound.play(0.0, 100000);
		return file;
	}
	
	private var pre_time:Float;
	private var accum:Float;
	private var stars:Stars;

	public function new() 
	{
		super();
		instance = this;
		
		if (stage != null) {
            init(null);
        } else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
	}
	
	private function init(e:Event) {	
		space = new Space(Vec2.weak(0, 0));
		stars = cast(addChild(new Stars()));
		canvas = cast(addChild(new Sprite()));
		entities = [];
		Input.init(stage);
		
		space.worldAngularDrag = 0.0;
		space.worldLinearDrag = 0.0;
		
		numEnemies = 0;
		enemy_goal = new Map<Ship, Wormhole>();
		
		setup();
		accum = 0;
		pre_time = Lib.getTimer() / 1000;
		playing = "Orion 300XB.wav";
		
		stage.focus = stage;
		stage.addEventListener(Input.KEYPRESS, keyPress);
		stage.addEventListener(Event.ENTER_FRAME, update);
		#if debug
		debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
		debug.drawConstraints = true;
		debug.drawCollisionArbiters = true;
        canvas.addChild(debug.display);
		#end
	}
	
	private function setup() {
		ready = false;
		/*player = new Ship("player");
		Tagger.set(player, "player");
		
		player.sprite.scaleX = player.sprite.scaleY = 0;
		Actuate.tween(player.sprite, 0.5, { scaleX:1, scaleY:1 } ).delay(1.2);
		
		player.body.position.x = 1700;
		player.body.rotation = Math.PI;
		
		player.updates.push(function(entity:Entity, dt:Float) {
			if (!ready && player.attached.indexOf(treasure.body) >= 0) ready = true;
			
			player.move((Input.keys[Keyboard.D] - Input.keys[Keyboard.A]), (Input.keys[Keyboard.W] - Input.keys[Keyboard.S]));
			
			if (Input.keys[Keyboard.H] == 1 && player.grapplers.length > 1) {
				var bodies = [for (grapple in player.grapplers) if(grapple.weld != null) grapple.weld.body2];
				var center = Vec2.weak();
				for (body in bodies) center = center.add(body.position, true);
				center = center.mul(1 / bodies.length);
				
				for (body in bodies) {
					var dir = center.sub(body.position);
					if (dir.length == 0) continue;
					body.applyImpulse(dir.normalise().mul(30, true));
					
					var ent = Entity.bodies.get(body);
					if (Magnet.targets.indexOf(ent) < 0) {
						new Magnet(ent);
					}
				}
			} else {
				for (magnet in Tagger.get("magnet")) {
					magnet.dispose();
				}
			}
			
			var pull = (Input.keys[Keyboard.I] - Input.keys[Keyboard.K]) * 1.1;
			if (pull != 0) {
				for (grapple in player.grapplers) {
					if(grapple.distance != null)
						grapple.distance.jointMax = Math.max(grapple.distance.jointMax+pull,0);
				}
			}
			
			canvas.x = -player.body.position.x + stage.stageWidth / 2;
			canvas.y = -player.body.position.y + stage.stageHeight / 2;
		});
		
		for (i in 0...85) {
			var asteroid = new Asteroid(30+20*Math.random());
			asteroid.x = 2000 * Math.random();
			asteroid.y = -1000 + 2000 * Math.random();
		}
		
		treasure = new Asteroid(70);
		Tagger.set(treasure, "treasure");
		var m = treasure.body.mass;
		treasure.body.massMode = MassMode.FIXED;
		treasure.body.mass = m*6;
		var vertices = [for (i in 0...8) {
			var angle = (i+0.5) * ((Math.PI * 2) / 8);
			new Vec2(Math.cos(angle) * 30, Math.sin(angle) * 30);
		}];
		treasure.sprite.graphics.beginFill(0xDDAA11);
		treasure.sprite.graphics.moveTo(vertices[vertices.length - 1].x, vertices[vertices.length - 1].y);
		for (vertex in vertices) {
			treasure.sprite.graphics.lineTo(vertex.x, vertex.y);
		}
		treasure.sprite.graphics.endFill();
		
		goal = new Wormhole(100, 0x282888, Vec2.weak(2000, 0));
		Tagger.set(goal, "goal");
		goal.updates.push(updatewormhole);
		
		stage.addChild(new TargetArrow(0xDDAA11, player.body, treasure.body));
		stage.addChild(new TargetArrow(0x282888, player.body, goal.body));*/
		
		var intro = new End("WATCH OUT FOR PIRATES", false);
		stage.addChild(intro);
		intro.y = -stage.stageHeight;
		Actuate.tween(intro, 0.5, { y:stage.stageHeight/2 } ).ease(Quad.easeOut).onComplete(function(intro:End) {			
			Actuate.tween(intro, 1, { scaleX:0.9, scaleY:0.9 } ).ease(Quad.easeInOut).repeat(8).reflect().onComplete(function(intro:End) {				
				Actuate.tween(intro, 0.5, { y:-stage.stageHeight } ).ease(Quad.easeIn).onComplete(stage.removeChild, [intro]);
			}, [intro]);
		}, [intro]);
		
		#if debug
		trace("Game Started");
		#end
	}
	
	private function destroy():Void {
		stage.removeEventListener(Input.KEYPRESS, keyPress);
		stage.removeEventListener(Event.ENTER_FRAME, update);
		
		for (entity in entities) entity.dispose();
		
		space.clear();
		
		stage.removeChildren(1, stage.numChildren - 1);
		removeChildren(0, numChildren - 1);
	}
	private function reset() {
		destroy();
		init(null);
	}
	
	private function keyPress(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.R) reset();
		if (e.keyCode == Keyboard.L) player.release();
		if (e.keyCode == Keyboard.J) player.shoot();
		if (e.keyCode == Keyboard.M) {
			for (s in Tagger.get("enemy")) cast(s,Ship).release();
			for (s in Tagger.get("player")) cast(s,Ship).release();
		}
	}
	
	private function update(e:Event):Void {
		var cur_time:Float = Lib.getTimer() / 1000;
		var dt = cur_time - pre_time;
		pre_time = cur_time;
		accum += dt;
		
		var stage_center = new Vec2(stage.stageWidth / 2, stage.stageHeight / 2);
		
		while (accum >= 1 / stage.frameRate) {
			accum -= 1 / stage.frameRate;
			space.step(1 / stage.frameRate);
			for (entity in entities) {
				entity.update(1 / stage.frameRate);
				entity.sprite.visible = stage_center.add(Vec2.weak(-canvas.x, -canvas.y), true).sub(entity.body.position, true).length < stage.stageWidth;
			}
		}
		
		stars.update( -canvas.x, -canvas.y);
		
		#if debug
        debug.clear();
        debug.draw(space);
        debug.flush();
		#end
		
		// Everything below this line should be moved
		
		if (numEnemies < 3 && ready) {
			numEnemies += 5;
			Actuate.timer(10).onComplete(function() { Util.spawnWave(this, 4); }, []);
		}
	}
	
	public function updatewormhole(entity:Entity, dt:Float) {
		var hole = cast(entity, Wormhole);
		var reach = 200;
		var d = new Vec2(hole.x - treasure.x, hole.y - treasure.y);
		var distance = d.length - reach;
		if (d.length < reach) {
			treasure.body.applyImpulse(d.mul(2*((reach-d.length)/reach), true).sub(treasure.body.velocity.mul(0.6, true),true));
			if (d.length < 10) {
				hole.dispose();
				
				for (s in Tagger.get("enemy")) cast(s,Ship).release();
				for (s in Tagger.get("player")) cast(s,Ship).release();
				treasure.dispose();
				
				if (hole == goal) {
					stage.addChild(new End("GREAT PROFIT", true));
				} else {
					stage.addChild(new End("GREAT LOSS", true));
				}
				
				ready = false;
			}
		}
	}
}
