package com.tinyprogress.spaceship.system;

/**
 * ...
 * @author Rasmus Dyhr Larsen
 */
class Tagger
{
	private static var data:Map<String,Array<Entity>> = new Map<String,Array<Entity>>();
	public static inline function get(tag:String) {
		if (!data.exists(tag)) return null;
		return data.get(tag);
	}
	public static inline function set(entity:Entity, tag:String) {
		if (!data.exists(tag)) data.set(tag, new Array<Entity>());
		data.get(tag).push(entity);
		entity.tags.push(tag);
	}
	public static inline function unset(entity:Entity) {
		for (arr in data) arr.remove(entity);
		while (entity.tags.length > 0) entity.tags.pop();
	}
}