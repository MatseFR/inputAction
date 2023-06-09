package inputAction;

/**
 * ...
 * @author Matse
 */
class InputAction 
{
	private static var _POOL:Array<InputAction> = new Array<InputAction>();
	
	public static function clearPool():Void
	{
		_POOL.resize(0);
	}
	
	public static function fromPool(actionID:String, controller:InputController, channel:Int = 0, value:Float = 0, message:String = null):InputAction
	{
		if (_POOL.length != 0)
		{
			return _POOL.pop().setTo(actionID, controller, channel, value, message);
		}
		return new InputAction(actionID, controller, channel, value, message);
	}
	
	public var actionID(get, never):String;
	public var channel(get, never):Int;
	public var controller(get, never):InputController;
	public var frameRepeatDelay(get, never):Int;
	public var frameRepeatFirstDelay(get, never):Int;
	public var frames(get, never):Int;
	public var message(get, never):String;
	public var phase(get, never):Int;
	/** milliseconds */
	public var time(get, never):Float;
	/** milliseconds */
	public var timeRepeatDelay(get, never):Float;
	public var timeRepeatFirstDelay(get, never):Float;
	public var useFrameRepeatDelay(get, never):Bool;
	public var useTimeRepeatDelay(get, never):Bool;
	public var value(get, never):Float;
	
	@:allow(inputAction)
	private var _actionID:String;
	private function get_actionID():String { return this._actionID; }
	
	@:allow(inputAction)
	private var _channel:Int;
	private function get_channel():Int { return this._channel; }
	
	@:allow(inputAction)
	private var _controller:InputController;
	private function get_controller():InputController { return this._controller; }
	
	@:allow(inputAction)
	private var _frameRepeatDelay:Int = 0;
	private function get_frameRepeatDelay():Int { return this._frameRepeatDelay; }
	
	@:allow(inputAction)
	private var _frameRepeatFirstDelay:Int = 0;
	private function get_frameRepeatFirstDelay():Int { return this._frameRepeatFirstDelay; }
	
	@:allow(inputAction)
	private var _frames:Int = 0;
	private function get_frames():Int { return this._frames; }
	
	@:allow(inputAction)
	private var _message:String;
	private function get_message():String { return this._message; }
	
	@:allow(inputAction)
	private var _phase:Int;
	private function get_phase():Int { return this._phase; }
	
	@:allow(inputAction)
	private var _time:Float = 0;
	private function get_time():Float { return this._time; }
	
	@:allow(inputAction)
	private var _timeRepeatDelay:Float = 0;
	private function get_timeRepeatDelay():Float { return this._timeRepeatDelay; }
	
	@:allow(inputAction)
	private var _timeRepeatFirstDelay:Float = 0;
	private function get_timeRepeatFirstDelay():Float { return this._timeRepeatFirstDelay; }
	
	@:allow(inputAction)
	private var _useFrameRepeatDelay:Bool = false;
	private function get_useFrameRepeatDelay():Bool { return this._useFrameRepeatDelay; }
	
	@:allow(inputAction)
	private var _useTimeRepeatDelay:Bool = false;
	private function get_useTimeRepeatDelay():Bool { return this._useTimeRepeatDelay; }
	
	@:allow(inputAction)
	private var _value:Float;
	private function get_value():Float { return this._value; }
	
	private var _isFirstRepeat:Bool = true;
	private var _frameRepeatDelayStamp:Int = 0;
	private var _timeRepeatDelayStamp:Float = 0;
	
	private var _frameDiff:Int;
	private var _timeDiff:Float;

	public function new(actionID:String, controller:InputController, channel:Int = 0, value:Float = 0, message:String = null) 
	{
		this._actionID = actionID;
		this._controller = controller;
		this._channel = channel;
		this._value = value;
		this._message = message;
	}
	
	public function canRepeat():Bool
	{
		if (this._useFrameRepeatDelay)
		{
			if (this._isFirstRepeat)
			{
				this._frameDiff = this._frames - this._frameRepeatDelayStamp - this._frameRepeatFirstDelay;
			}
			else
			{
				this._frameDiff = this._frames - this._frameRepeatDelayStamp - this._frameRepeatDelay;
			}
			if (this._frameDiff < 0)
			{
				return false;
			}
		}
		
		if (this._useTimeRepeatDelay)
		{
			if (this._isFirstRepeat)
			{
				this._timeDiff = this._time - this._timeRepeatDelayStamp - this._timeRepeatFirstDelay;
			}
			else
			{
				this._timeDiff = this._time - this._timeRepeatDelayStamp - this._timeRepeatDelay;
			}
			if (this._timeDiff < 0)
			{
				return false;
			}
		}
		
		if (this._useFrameRepeatDelay)
		{
			this._frameRepeatDelayStamp = this._frames - this._frameDiff;
		}
		
		if (this._useTimeRepeatDelay)
		{
			this._timeRepeatDelayStamp = this._time - this._timeDiff;
		}
		
		this._isFirstRepeat = false;
		
		return true;
	}
	
	public function clone():InputAction
	{
		var action:InputAction = fromPool(this._actionID, this._controller, this._channel, this._value, this._message);
		action._phase = this._phase;
		action._frames = this._frames;
		action._time = this._time;
		if (this._useFrameRepeatDelay)
		{
			action._isFirstRepeat = this._isFirstRepeat;
			action._useFrameRepeatDelay = true;
			action._frameRepeatFirstDelay = this._frameRepeatFirstDelay;
			action._frameRepeatDelay = this._frameRepeatDelay;
			action._frameRepeatDelayStamp = this._frameRepeatDelayStamp;
		}
		if (this._useTimeRepeatDelay)
		{
			action._isFirstRepeat = this._isFirstRepeat;
			action._useTimeRepeatDelay = true;
			action._timeRepeatFirstDelay = this._timeRepeatFirstDelay;
			action._timeRepeatDelay = this._timeRepeatDelay;
			action._timeRepeatDelayStamp = this._timeRepeatDelayStamp;
		}
		return action;
	}
	
	public function copyFrom(action:InputAction):Void
	{
		this._frames = action._frames;
		this._time = action._time;
		this._useFrameRepeatDelay = action._useFrameRepeatDelay;
		if (this._useFrameRepeatDelay)
		{
			this._isFirstRepeat = action._isFirstRepeat;
			this._frameRepeatFirstDelay = action._frameRepeatFirstDelay;
			this._frameRepeatDelay = action._frameRepeatDelay;
			this._frameRepeatDelayStamp = action._frameRepeatDelayStamp;
		}
		
		this._useTimeRepeatDelay = action._useTimeRepeatDelay;
		if (this._useTimeRepeatDelay)
		{
			this._isFirstRepeat = action._isFirstRepeat;
			this._timeRepeatFirstDelay = action._timeRepeatFirstDelay;
			this._timeRepeatDelay = action._timeRepeatDelay;
			this._timeRepeatDelayStamp = action._timeRepeatDelayStamp;
		}
	}
	
	public function isSameAs(action:InputAction):Bool
	{
		return this._actionID == action._actionID && this._controller == action._controller && this._channel == action._channel;
	}
	
	public function pool():Void
	{
		this._controller = null;
		this._frames = 0;
		this._frameRepeatDelay = 0;
		this._frameRepeatFirstDelay = 0;
		this._frameRepeatDelayStamp = 0;
		this._isFirstRepeat = true;
		this._time = 0;
		this._timeRepeatDelay = 0;
		this._timeRepeatFirstDelay = 0;
		this._timeRepeatDelayStamp = 0;
		_POOL.push(this);
	}
	
	public function toString():String
	{
		return "<InputAction> " + this._actionID + " | channel: " + this._channel + " | value: " + this._value 
			+ " | phase: " + this._phase + " | controller: " + this._controller + " | time: " + this._time;
	}
	
	private function setTo(actionID:String, controller:InputController, channel:Int = 0, value:Float = 0, message:String = null):InputAction
	{
		this._actionID = actionID;
		this._controller = controller;
		this._channel = channel;
		this._value = value;
		this._message = message;
		return this;
	}
	
}