package inputAction;
import inputAction.Input;
import inputAction.InputAction;
import juggler.animation.IAnimatable;

/**
 * ...
 * @author Matse
 */
abstract class InputController implements IAnimatable
{
	public var id(get, never):String;
	public var input(get, never):Input;
	public var defaultChannel(get, set):Int;
	public var enabled(get, set):Bool;
	
	private var _id:String;
	private function get_id():String { return this._id; }
	
	@:allow(inputAction.Input)
	private var _input:Input;
	private function get_input():Input { return this._input; }
	
	private var _defaultChannel:Int = 0;
	private function get_defaultChannel():Int { return this._defaultChannel; }
	private function set_defaultChannel(value:Int):Int
	{
		return this._defaultChannel = value;
	}
	
	private var _enabled:Bool = true;
	private function get_enabled():Bool { return this._enabled; }
	private function set_enabled(value:Bool):Bool
	{
		return this._enabled = value;
	}
	
	private var _action:InputAction;
	
	public function new(id:String) 
	{
		this._id = id;
	}
	
	public function dispose():Void
	{
		this._action = null;
	}
	
	public function toString():String
	{
		return this._id;
	}
	
	private function actionBegin(action:InputAction):Void
	{
		if (!this._enabled)
		{
			action.pool();
			return;
		}
		this._input.actionBegin(action);
	}
	
	private function actionEnd(action:InputAction):Void
	{
		if (!this._enabled) 
		{
			action.pool();
			return;
		}
		this._input.actionEnd(action);
	}
	
	private function actionChange(action:InputAction):Void
	{
		if (!this._enabled)
		{
			action.pool();
			return;
		}
		this._input.actionChange(action);
	}
	
	private function actionOnce(action:InputAction):Void
	{
		if (!this._enabled)
		{
			action.pool();
			return;
		}
		this._input.actionBegin(action);
		this._input.actionEnd(action.clone());
	}
	
	/** override if a controller needs update every frame */
	public function advanceTime(time:Float):Void
	{
		
	}
	
}