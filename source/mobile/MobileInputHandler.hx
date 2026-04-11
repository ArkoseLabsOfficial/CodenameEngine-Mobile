package mobile;

import haxe.ds.Map;
import flixel.group.FlxSpriteGroup;

enum ButtonsStates
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
	JUST_RELEASED;
}

/**
 * A handler for MobileButton.
 * If you don't know what are you doing, do not touch here.
 * @author ArkoseLabs
 */
class MobileInputHandler extends FlxTypedSpriteGroup<MobileButton>
{
	/**
	 * A map to keep track of all the buttons using it's ID
	 */
	public var trackedButtons:Map<String, MobileButton> = new Map<String, MobileButton>();

	/**
	 * Singleton for the last used input handled.
	 */
	public static var instance:Null<MobileInputHandler> = null;

	public function new()
	{
		super();
		updateTrackedButtons();

		instance = this;
	}

	public function pressed(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), PRESSED);

	public function justPressed(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), JUST_PRESSED);

	public function released(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), RELEASED);

	public function justReleased(button:Dynamic):Bool
		return checkButtonsState((Std.isOfType(button, Array) ? button : [button]), JUST_RELEASED);

	public function checkButtonsState(Buttons:Array<String>, state:ButtonsStates = JUST_PRESSED):Bool
	{
		if (Buttons == null)
			return false;

		for (button in Buttons) {
			if (trackedButtons.exists(button)) {
				if (state == RELEASED && trackedButtons.get(button).released ||
				   state == JUST_RELEASED && trackedButtons.get(button).justReleased ||
				   state == PRESSED && trackedButtons.get(button).pressed ||
				   state == JUST_PRESSED && trackedButtons.get(button).justPressed)
				{
					return true;
				}
			}
		}

		return false;
	}


	public function updateTrackedButtons()
	{
		trackedButtons.clear();
		forEachExists(function(button:MobileButton)
		{
			if (button.IDs != null)
			{
				for (id in button.IDs)
				{
					if (!trackedButtons.exists(id))
						trackedButtons.set(id, button);
					else {
						var numberString:String = '';
						var number:Int = 0;
						while(trackedButtons.exists(id + numberString)) {
							numberString = (number != 0) ? '$number' : '';
							number++;
						}
						if (!trackedButtons.exists(id + numberString))
							trackedButtons.set(id + numberString, button);
					}
				}
			}
		});
	}
}