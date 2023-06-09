package inputAction.events;

import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class InputActionEvent extends Event 
{
	public static inline var ACTION_BEGIN:EventType<InputActionEvent> = "actionBegin";
	public static inline var ACTION_CHANGE:EventType<InputActionEvent> = "actionChange";
	public static inline var ACTION_END:EventType<InputActionEvent> = "actionEnd";
	
	#if !flash
	private static var _POOL:Array<InputActionEvent> = new Array<InputActionEvent>();
	
	private static function fromPool(type:String, action:InputAction, bubbles:Bool, cancelable:Bool):InputActionEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, action, bubbles, cancelable);
		return new InputActionEvent(type, action, bubbles, cancelable);
	}
	#end
	
	public static function dispatch(dispatcher:IEventDispatcher, type:String, action:InputAction, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new InputActionEvent(type, action, bubbles, cancelable));
		#else
		var event:InputActionEvent = fromPool(type, action, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var action(default, null):InputAction;

	public function new(type:String, action:InputAction, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.action = action;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new InputActionEvent(this.type, this.action, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.action, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.action = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, action:InputAction, bubbles:Bool = false, cancelable:Bool = false):InputActionEvent
	{
		this.type = type;
		this.action = action;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}