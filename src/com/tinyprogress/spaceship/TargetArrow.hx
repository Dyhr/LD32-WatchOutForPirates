package com.tinyprogress.spaceship;

import nape.geom.Vec2;
import nape.phys.Body;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class TargetArrow extends Sprite
{
	private var target:Body;
	private var player:Body;

	public function new(color:Int, player:Body, target:Body) 
	{
		super();
		this.player = player;
		this.target = target;
		addEventListener(Event.ENTER_FRAME, update);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy);
		
		graphics.beginFill(color);
		graphics.moveTo(10, 0);
		graphics.lineTo(0, 15);
		graphics.lineTo(0, -15);
		graphics.lineTo(10, 0);
		graphics.endFill();
	}	
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		removeEventListener(Event.ENTER_FRAME, update);
	}
	
	private function update(e:Event):Void 
	{
		var d = target.position.sub(player.position);
		visible = d.length > stage.stageHeight / 3;
		if (d.length < stage.stageHeight / 3) return;
		var n = d.copy().normalise();
		
		var p = Vec2.weak(stage.stageWidth / 2, stage.stageHeight / 2).add(n.mul(stage.stageHeight / 5, true));
		x = p.x; y = p.y;
		rotation = Math.atan2(d.y, d.x) * (180/Math.PI);
	}
}