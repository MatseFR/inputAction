package inputAction.controllers;
import inputAction.InputAction;
import inputAction.InputController;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author Matse
 */
class KeyAction 
{
	public var actionID:String;
	
	public var keyLocation:Int;
	
	public var ignoreAlt:Bool = false;
	public var ignoreCtrl:Bool = false;
	public var ignoreShift:Bool = false;
	
	public var requireAlt:Bool;
	public var requireCtrl:Bool;
	public var requireShift:Bool;
	
	public var frameRepeatDelay:Int;
	public var frameRepeatFirstDelay:Int;
	public var timeRepeatDelay:Float;
	public var timeRepeatFirstDelay:Float;
	public var useFrameRepeatDelay:Bool = false;
	public var useTimeRepeatDelay:Bool = false;
	
	/**
	   
	   @param	actionID
	   @param	requireAlt
	   @param	requireCtrl
	   @param	requireShift
	   @param	frameRepeatDelay
	   @param	timeRepeatDelay
	   @param	keyLocation
	**/
	public function new(actionID:String, requireAlt:Bool = false, requireCtrl:Bool = false, requireShift:Bool = false,
						frameRepeatFirstDelay:Int = 0, frameRepeatDelay:Int = 0, timeRepeatFirstDelay:Float = 0,
						timeRepeatDelay:Float = 0, keyLocation:Int = -1) 
	{
		this.actionID = actionID;
		this.requireAlt = requireAlt;
		this.requireCtrl = requireCtrl;
		this.requireShift = requireShift;
		this.frameRepeatFirstDelay = frameRepeatFirstDelay;
		this.frameRepeatDelay = frameRepeatDelay;
		if (this.frameRepeatFirstDelay != 0 || this.frameRepeatDelay != 0)
		{
			this.useFrameRepeatDelay = true;
		}
		this.timeRepeatFirstDelay = timeRepeatFirstDelay;
		this.timeRepeatDelay = timeRepeatDelay;
		if (this.timeRepeatFirstDelay != 0 || this.timeRepeatDelay != 0)
		{
			this.useTimeRepeatDelay = true;
		}
		this.keyLocation = keyLocation;
	}
	
	public function isValidDown(evt:KeyboardEvent):Bool
	{
		if (keyLocation != -1 && evt.keyLocation != keyLocation)
		{
			return false;
		}
		
		if (requireAlt)
		{
			if (!evt.altKey) return false;
		}
		else if (!ignoreAlt && evt.altKey)
		{
			return false;
		}
		
		if (requireCtrl)
		{
			if (!evt.ctrlKey) return false;
		}
		else if (!ignoreCtrl && evt.ctrlKey)
		{
			return false;
		}
		
		if (requireShift)
		{
			if (!evt.shiftKey) return false;
		}
		else if (!ignoreShift && evt.shiftKey)
		{
			return false;
		}
		
		return true;
	}
	
	public function isValidUp(evt:KeyboardEvent):Bool
	{
		return true;
	}
	
	public function toInputAction(controller:InputController, channel:Int):InputAction
	{
		var action:InputAction = InputAction.fromPool(this.actionID, controller, channel);
		if (this.useFrameRepeatDelay)
		{
			action._useFrameRepeatDelay = true;
			action._frameRepeatFirstDelay = this.frameRepeatFirstDelay;
			action._frameRepeatDelay = this.frameRepeatDelay;
		}
		if (this.useTimeRepeatDelay)
		{
			action._useTimeRepeatDelay = true;
			action._timeRepeatFirstDelay = this.timeRepeatFirstDelay;
			action._timeRepeatDelay = this.timeRepeatDelay;
		}
		return action;
	}
	
}