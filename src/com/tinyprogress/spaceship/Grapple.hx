package com.tinyprogress.spaceship;

import nape.geom.Vec2;
import nape.phys.Body;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Grapple extends Sprite
{
	public var offset2:Vec2;
	public var offset1:Vec2;
	public var body2:Body;
	public var body1:Body;
	
	private var head:Sprite;
	private var tail:Sprite;

	public function new(body1:Body, body2:Body, offset1:Vec2, offset2:Vec2) 
	{
		super();
		this.offset2 = offset2;
		this.offset1 = offset1;
		this.body2 = body2;
		this.body1 = body1;
		
		head = new Sprite();
		head.graphics.beginFill(0x445444);
		head.graphics.drawCircle(0, 0, 4);
		head.graphics.endFill();
		tail = new Sprite();
		tail.graphics.beginFill(0x405840);
		tail.graphics.moveTo(0, 1);
		tail.graphics.lineTo(100, 1);
		tail.graphics.lineTo(100, -1);
		tail.graphics.lineTo(0, -1);
		tail.graphics.lineTo(0, 1);
		tail.graphics.endFill();
		
		addEventListener(Event.REMOVED_FROM_STAGE, destroy);
	}
	
	private function destroy(e:Event):Void 
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
		head.parent.removeChild(head);
		tail.parent.removeChild(tail);
	}
	
	public function update() {
		
		if (head.parent == null) parent.addChild(head);
		if (tail.parent == null) parent.addChild(tail);
		
		var p1 = body1.localPointToWorld(offset1);
		var p2 = body2.localPointToWorld(offset2);
		
		head.x = p2.x;
		head.y = p2.y;
		tail.x = p1.x;
		tail.y = p1.y;
		tail.scaleX = Vec2.distance(p1, p2) / 100;
		tail.rotation = Math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / Math.PI);
	}
}