package com.tinyprogress.spaceship.actors;

import com.tinyprogress.spaceship.system.Entity;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.constraint.DistanceJoint;
import nape.constraint.WeldJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import openfl.display.Sprite;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Grapple extends Entity
{
	public var offset2:Vec2;
	public var offset1:Vec2;
	public var body2:Body;
	public var body1:Body;
	
	private var joint:DistanceJoint;
	private var head:Sprite;
	private var tail:Sprite;

	private var grappleCollitionType:CbType = new CbType();
	private var listener:InteractionListener;
	
	public function new(parent:Entity, offset:Vec2) 
	{
		super(BodyType.DYNAMIC, false, parent.body.position.add(parent.body.localVectorToWorld(offset, true), true), false);
		
		body.shapes.add(new Circle(4));
		sprite.graphics.lineStyle(2, 0xFFFFFFFF);
		sprite.graphics.drawCircle(0, 0, 4);
		
		var dir = new Vec2(Math.cos(parent.body.rotation), Math.sin(parent.body.rotation));
		body.applyImpulse(dir.normalise().mul(20));
		
		listener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, grappleCollitionType, Entity.cb, hit);
		listener.space = body.space;
		body.cbTypes.add(grappleCollitionType);
		
		/*var dir = new Vec2(Math.cos(body.rotation), Math.sin(body.rotation));
		var ray = new Ray(body.position.add(dir, true), dir);
		var hit = parent.body.space.rayCast(ray);
		if (hit != null) {
			if (hit.shape.body == parent.body) dispose();
			var point = ray.at(hit.distance);
			joint = new DistanceJoint(hit.shape.body, parent.body, offset, parent.body.worldPointToLocal(point, true), 0, Vec2.distance(hit.shape.body.position, point));
			joint.space = parent.body.space;
			
			hit.dispose();
		} else {
			dispose();
		}*/
		/*this.offset2 = offset2;
		this.offset1 = offset1;
		this.body2 = body2;
		this.body1 = body1;*/
		
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
	}
	
	private function hit(e:InteractionCallback):Void 
	{
		listener.space = null;
		var joint = new WeldJoint(e.int1.castBody, e.int2.castBody, Vec2.weak(0, 0), e.int2.castBody.worldPointToLocal(e.int1.castBody.position, true));
		joint.space = body.space;
	}
	
	public override function dispose():Void 
	{
		super.dispose();
		if(head != null)head.parent.removeChild(head);
		if(tail != null)tail.parent.removeChild(tail);
		if(joint != null)joint.space = null;
	}
	
	public override function update(dt:Float) {
		super.update(dt);
		
		if (head.parent == null) sprite.parent.addChild(head);
		if (tail.parent == null) sprite.parent.addChild(tail);
		
		/*var p1 = body1.localPointToWorld(offset1);
		var p2 = body2.localPointToWorld(offset2);
		
		head.x = p2.x;
		head.y = p2.y;
		tail.x = p1.x;
		tail.y = p1.y;
		tail.scaleX = Vec2.distance(p1, p2) / 100;
		tail.rotation = Math.atan2(p2.y - p1.y, p2.x - p1.x) * (180 / Math.PI);*/
	}
}