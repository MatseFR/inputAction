package inputAction.controllers;
import inputAction.InputController;
import inputAction.controllers.KeyAction;
import openfl.display.DisplayObject;
import openfl.display.Stage;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import valedit.utils.ReverseIterator;

/**
 * ...
 * @author Matse
 */
class KeyboardController extends InputController
{
	public var root(get, set):DisplayObject;
	private var _root:DisplayObject;
	private function get_root():DisplayObject { return this._root; }
	private function set_root(value:DisplayObject):DisplayObject
	{
		if (this._root == value) return value;

		if (this._root != null && this._enabled)
		{
			this._root.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this._root.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		if (value != null && this._enabled)
		{
			if (Std.isOfType(value, Stage))
			{
				this._rootIsStage = true;
				this._stage = cast value;
			}
			else
			{
				this._rootIsStage = false;
				this._stage = null;
			}
			value.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			value.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		return this._root = value;
	}

	override function set_enabled(value:Bool):Bool
	{
		if (this._enabled == value) return value;
		if (value)
		{
			if (this._root != null)
			{
				this._root.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this._root.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
		}
		else
		{
			if (this._root != null)
			{
				this._root.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				this._root.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
		}
		return super.set_enabled(value);
	}

	private var _keyActions:Map<Int, Array<KeyAction>> = new Map<Int, Array<KeyAction>>();
	private var _rootIsStage:Bool;
	private var _stage:Stage;

	public function new(root:DisplayObject, id:String = "keyboard")
	{
		super(id);
		this.root = root;
	}

	override public function dispose():Void
	{
		if (this._root != null)
		{
			this._root.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this._root.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		this._keyActions.clear();
		this._keyActions = null;

		super.dispose();
	}

	public function addKeyAction(keyCode:Int, action:KeyAction):Void
	{
		if (!this._keyActions.exists(keyCode))
		{
			this._keyActions[keyCode] = new Array<KeyAction>();
		}
		this._keyActions[keyCode].push(action);
	}

	public function removeKeyAction(keyCode:Int, actionID:String):Void
	{
		var actions:Array<KeyAction> = this._keyActions[keyCode];
		if (actions == null) return;
		
		for (i in new ReverseIterator(actions.length - 1, 0))
		{
			if (actions[i].actionID == actionID)
			{
				actions.splice(i, 1);
			}
		}
		
		if (actions.length == 0) removeKeyActions(keyCode);
	}

	public function removeKeyActions(keyCode:Int):Void
	{
		this._keyActions.remove(keyCode);
	}

	public function setKeyActions(keyCode:Int, actions:Array<KeyAction>):Void
	{
		this._keyActions[keyCode] = actions;
	}

	private function onKeyDown(evt:KeyboardEvent):Void
	{
		if (this._rootIsStage)
		{
			if (this._stage.focus != null && ((Std.isOfType(this._stage.focus, TextField) && cast(this._stage.focus, TextField).type == TextFieldType.INPUT) #if starling || Std.isOfType(this._stage.focus, starling.text.TextField) #end )) // not sure the check for Starling TextField is needed
			{
				return;
			}
		}
		else if (this._root.stage != null)
		{
			if (this._root.stage.focus != null && ((Std.isOfType(this._root.stage.focus, TextField) && cast(this._root.stage.focus, TextField).type == TextFieldType.INPUT) #if starling || Std.isOfType(this._root.stage.focus, starling.text.TextField) #end )) // not sure the check for Starling TextField is needed
			{
				return;
			}
		}
		
		var actions:Array<KeyAction> = this._keyActions[evt.keyCode];
		if (actions == null) return;
		
		var isValidAction:Bool = false;
		for (action in actions)
		{
			if (action.isValidDown(evt))
			{
				actionBegin(action.toInputAction(this, this._defaultChannel));
				isValidAction = true;
			}
		}
		
		if (isValidAction)
		{
			evt.preventDefault(); // required to prevent the Brower from reacting to a shortcut
		}
	}

	private function onKeyUp(evt:KeyboardEvent):Void
	{
		if (this._rootIsStage)
		{
			if (this._stage.focus != null && ((Std.isOfType(this._stage.focus, TextField) && cast(this._stage.focus, TextField).type == TextFieldType.INPUT) #if starling || Std.isOfType(this._stage.focus, starling.text.TextField) #end )) // not sure the check for Starling TextField is needed
			{
				return;
			}
		}
		else if (this._root.stage != null)
		{
			if (this._root.stage.focus != null && ((Std.isOfType(this._root.stage.focus, TextField) && cast(this._root.stage.focus, TextField).type == TextFieldType.INPUT) #if starling || Std.isOfType(this._root.stage.focus, starling.text.TextField) #end )) // not sure the check for Starling TextField is needed
			{
				return;
			}
		}
		
		var actions:Array<KeyAction> = this._keyActions[evt.keyCode];
		if (actions == null) return;
		
		var isValidAction:Bool = false;
		for (action in actions)
		{
			if (action.isValidUp(evt))
			{
				actionEnd(action.toInputAction(this, this._defaultChannel));
				isValidAction = true;
			}
		}
		
		if (isValidAction)
		{
			evt.preventDefault(); // required to prevent the Brower from reacting to a shortcut
		}
	}

}