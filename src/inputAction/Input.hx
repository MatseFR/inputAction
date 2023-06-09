package inputAction;
import inputAction.events.InputActionEvent;
import juggler.animation.IAnimatable;
import juggler.event.JugglerEvent;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import valeditor.utils.ReverseIterator;

/**
 * ...
 * @author Matse
 */
class Input extends EventDispatcher implements IAnimatable
{
	public var dispatchEvents(get, set):Bool;
	private var _dispatchEvents:Bool = true;
	private function get_dispatchEvents():Bool { return this._dispatchEvents; }
	private function set_dispatchEvents(value:Bool):Bool
	{
		return this._dispatchEvents = value;
	}
	
	public var enabled(get, set):Bool;
	private var _enabled:Bool = true;
	private function get_enabled():Bool { return this._enabled; }
	private function set_enabled(value:Bool):Bool
	{
		if (this._enabled == value) return value;
		
		for (controller in this._controllers)
		{
			controller.enabled = value;
		}
		
		return this._enabled = value;
	}
	
	private var _actions:Array<InputAction> = new Array<InputAction>();
	private var _controllers:Array<InputController> = new Array<InputController>();
	private var _controllersUpdate:Array<InputController> = new Array<InputController>();
	private var _idToController:Map<String, InputController> = new Map<String, InputController>();
	
	private var _actionsToRemove:Array<Int> = new Array<Int>();
	private var _reverseIterator:ReverseIterator = new ReverseIterator(0, 0);

	public function new() 
	{
		super();
	}
	
	public function dispose():Void
	{
		disposeControllers();
		JugglerEvent.dispatch(this, JugglerEvent.REMOVE_FROM_JUGGLER);
	}
	
	public function addController(controller:InputController, registerForUpdate:Bool = false):Void
	{
		if (this._controllers.indexOf(controller) != -1)
		{
			trace("Input.addController ::: controller already added");
			return;
		}
		if (this._idToController.exists(controller.id))
		{
			throw new Error("Input.addController ::: another controller already added with ID " + controller.id);
		}
		controller._input = this;
		this._controllers.push(controller);
		this._idToController[controller.id] = controller;
		if (registerForUpdate) this._controllersUpdate.push(controller);
	}
	
	public function controllerExists(id:String):Bool
	{
		return this._idToController.exists(id);
	}
	
	public function disposeControllers():Void
	{
		for (action in this._actions)
		{
			action.pool();
		}
		this._actions.resize(0);
		
		for (controller in this._controllers)
		{
			controller.dispose();
		}
		this._controllers.resize(0);
		this._idToController.clear();
		this._controllersUpdate.resize(0);
	}
	
	public function getController(id:String):InputController
	{
		return this._idToController[id];
	}
	
	public function removeController(controller:InputController):Void
	{
		if (this._controllers.indexOf(controller) == -1)
		{
			trace("Input.removeController ::: controller not added");
			return;
		}
		controller._input = null;
		this._controllers.remove(controller);
		this._idToController.remove(controller.id);
		var index:Int = this._controllersUpdate.indexOf(controller);
		if (index != -1) this._controllersUpdate.splice(index, 1);
	}
	
	public function stopActionsForController(controller:InputController, channel:Int = -1):Void
	{
		for (action in this._actions)
		{
			if (action._controller != controller) continue;
			
			if (channel > -1)
			{
				if (action.channel == channel) action._phase = InputPhase.ENDED;
			}
			else
			{
				action._phase = InputPhase.ENDED;
			}
		}
	}
	
	public function advanceTime(time:Float):Void
	{
		if (!this._enabled) return;
		
		for (controller in this._controllersUpdate)
		{
			controller.advanceTime(time);
		}
		
		var action:InputAction;
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			action = this._actions[i];
			action._time += time;
			action._frames ++;
			if (action._phase > InputPhase.END)
			{
				this._actionsToRemove.push(i);
			}
			else if (action._phase != InputPhase.ON)
			{
				action._phase ++;
			}
		}
		
		if (this._actionsToRemove.length != 0)
		{
			this._reverseIterator.reset(this._actionsToRemove.length - 1, 0);
			for (i in this._reverseIterator)
			{
				this._actions.splice(this._actionsToRemove[i], 1)[0].pool();
			}
			this._actionsToRemove.resize(0);
		}
	}
	
	public function addAction(action:InputAction):Void
	{
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			if (action.isSameAs(this._actions[i]))
			{
				action.copyFrom(this._actions[i]);
				this._actions[i].pool();
				this._actions[i] = action;
				return;
			}
		}
		
		this._actions[count] = action;
	}
	
	public function getAction(actionID:String, channel:Int = -1, controller:InputController = null, phase:Int = -1):InputAction
	{
		for (a in this._actions)
		{
			if (a._actionID == actionID && (channel == -1 || a._channel == channel) && (controller == null || a._controller == controller) && (phase == -1 || a._phase == phase))
			{
				return a;
			}
		}
		return null;
	}
	
	public function getActions(channel:Int = -1, controller:InputController = null, phase:Int = 1, ?actions:Array<InputAction>):Array<InputAction>
	{
		if (actions == null) actions = new Array<InputAction>();
		
		for (a in this._actions)
		{
			if ((channel == -1 || a._channel == channel) && (controller == null || a._controller == controller) && (phase == -1 || a._phase == phase))
			{
				actions.push(a);
			}
		}
		
		return actions;
	}
	
	public function getActionsSnapshot(actions:Array<InputAction> = null):Array<InputAction>
	{
		if (actions == null) actions = new Array<InputAction>();
		
		for (a in this._actions)
		{
			actions.push(a.clone());
		}
		
		return actions;
	}
	
	public function removeAction(action:InputAction):Void
	{
		this._actions.remove(action);
	}
	
	public function removeActionWithID(actionID:String, channel:Int = -1, controller:InputController = null, phase:Int = -1):Void
	{
		for (a in this._actions)
		{
			if (a._actionID == actionID && (channel == -1 || a._channel == channel) && (controller == null || a._controller == controller) && (phase == -1 || a._phase == phase))
			{
				this._actions.remove(a);
				a.pool();
				return;
			}
		}
	}
	
	public function removeActions(channel:Int = -1, controller:InputController = null, phase:Int = -1):Void
	{
		var a:InputAction;
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			a = this._actions[i];
			if ((channel == -1 || a._channel == channel) && (controller == null || a._controller == controller) && (phase == -1 || a ._phase == phase))
			{
				this._actionsToRemove.push(i);
			}
		}
		
		if (this._actionsToRemove.length != 0)
		{
			this._reverseIterator.reset(this._actionsToRemove.length - 1, 0);
			for (i in this._reverseIterator)
			{
				this._actions.splice(this._actionsToRemove[i], 1)[0].pool();
			}
			this._actionsToRemove.resize(0);
		}
	}
	
	public function resetActions():Void
	{
		for (action in this._actions)
		{
			action.pool();
		}
		this._actions.resize(0);
	}
	
	public function hasDone(actionID:String, channel:Int = -1):InputAction
	{
		for (action in this._actions)
		{
			if (action._actionID == actionID && (channel == -1 || action._channel == channel) && action._phase == InputPhase.END)
			{
				return action;
			}
		}
		return null;
	}
	
	public function isDoing(actionID:String, channel:Int = -1):InputAction
	{
		for (action in this._actions)
		{
			if (action._actionID == actionID && (channel == -1 || action._channel == channel) && action._frames > 1 && action.phase < InputPhase.END)
			{
				return action;
			}
		}
		return null;
	}
	
	public function justDid(actionID:String, channel:Int = -1):InputAction
	{
		for (action in this._actions)
		{
			if (action._actionID == actionID && (channel == -1 || action._channel == channel) && action._frames == 1)
			{
				return action;
			}
		}
		return null;
	}
	
	@:allow(inputAction)
	private function actionBegin(action:InputAction):Void
	{
		//for (a in this._actions)
		//{
			//if (a.isSameAs(action))
			//{
				//a._phase = InputPhase.BEGIN;
				//a._value = action._value;
				//a._message = action._message;
				//action.pool();
				//return;
			//}
		//}
		action._phase = InputPhase.BEGIN;
		
		if (this._dispatchEvents)
		{
			InputActionEvent.dispatch(this, InputActionEvent.ACTION_BEGIN, action);
		}
		
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			if (action.isSameAs(this._actions[i]))
			{
				action.copyFrom(this._actions[i]);
				this._actions[i].pool();
				this._actions[i] = action;
				return;
			}
		}
		
		//action._phase = InputPhase.BEGIN;
		this._actions[count] = action;
	}
	
	@:allow(inputAction)
	private function actionEnd(action:InputAction):Void
	{
		//for (a in this._actions)
		//{
			//if (a.isSameAs(action))
			//{
				//a._phase = InputPhase.END;
				//a._value = action._value;
				//a._message = action._message;
				//action.pool();
				//return;
			//}
		//}
		action._phase = InputPhase.END;
		
		if (this._dispatchEvents)
		{
			InputActionEvent.dispatch(this, InputActionEvent.ACTION_END, action);
		}
		
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			if (action.isSameAs(this._actions[i]))
			{
				action.copyFrom(this._actions[i]);
				this._actions[i].pool();
				this._actions[i] = action;
				return;
			}
		}
		
		action.pool();
	}
	
	@:allow(inputAction)
	private function actionChange(action:InputAction):Void
	{
		//for (a in this._actions)
		//{
			//if (a.isSameAs(action))
			//{
				//a._phase = InputPhase.ON;
				//a._value = action._value;
				//a._message = action._message;
				//action.pool();
				//return;
			//}
		//}
		
		if (this._dispatchEvents)
		{
			InputActionEvent.dispatch(this, InputActionEvent.ACTION_CHANGE, action);
		}
		
		var count:Int = this._actions.length;
		for (i in 0...count)
		{
			if (action.isSameAs(this._actions[i]))
			{
				action.copyFrom(this._actions[i]);
				action._phase = InputPhase.ON;
				this._actions[i].pool();
				this._actions[i] = action;
				return;
			}
		}
		
		action._phase = InputPhase.BEGIN;
		this._actions[count] = action;
	}
	
}