package funkin.options.categories;

import flixel.input.keyboard.FlxKey;
import lime.system.System as LimeSystem;

class MobileOptions extends TreeMenuScreen
{
	public function new()
	{
		super('optionsTree.mobile-name', 'optionsTree.mobile-name', 'MobileOptions.', ['LEFT_FULL', 'A_B']);

		add(new NumOption(getNameID('extraButtons'), getDescID('extraButtons'), 0, 4, 1, 'extraButtons'));
		add(new ArrayOption(getNameID('hitboxType'), getDescID('hitboxType'), ["No Gradient", "No Gradient (Old)", "Gradient"],
			["No Gradient", "No Gradient (Old)", "Gradient"], 'hitboxType'));
		add(new ArrayOption(getNameID('hitboxMode'), getDescID('hitboxMode'), ["Normal (New)"], ["Normal (New)"], 'hitboxMode'));
		add(new Checkbox(getNameID('hitboxPos'), getDescID('hitboxPos'), "hitboxPos"));
		add(new NumOption(getNameID('controlsAlpha'), getDescID('controlsAlpha'), 0.0, 1.0, 0.1, "controlsAlpha", (alpha:Float) ->
		{
			MusicBeatState.instance.mobileManager.mobilePad.alpha = alpha;
			if (funkin.backend.system.Controls.instance.mobileC)
			{
				FlxG.sound.volumeUpKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.muteKeys = [];
			}
			else
			{
				FlxG.sound.volumeUpKeys = [FlxKey.PLUS, FlxKey.NUMPADPLUS];
				FlxG.sound.volumeDownKeys = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
			}
		}));
	}

	override function close()
	{
		super.close();
	}
}