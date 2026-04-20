package funkin.options.categories;

import flixel.input.keyboard.FlxKey;
import lime.system.System as LimeSystem;
import funkin.backend.assets.ModsFolder;

#if sys
import sys.FileSystem;
#end

class MobileOptions extends TreeMenuScreen
{
	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}
	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		if(Assets.exists(path)) daList = Assets.getText(path);
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function mergeAllTextsNamed(file:String)
	{
		var mergedList:Array<String> = [];
		var list:Array<String> = coolTextFile(file);
		for (value in list)
			if(!mergedList.contains(value) && value.length > 0)
				mergedList.push(value);
		return mergedList;
	}

	#if android
	final lastExternal:Bool = Options.useExternal;
	var externalOption:Checkbox;
	#end

	var HitboxTypes:Array<String>;
	public function new()
	{
		super('optionsTree.mobile-name', 'optionsTree.mobile-name', 'MobileOptions.', ['LEFT_FULL', 'A_B']);

		HitboxTypes = mergeAllTextsNamed("assets/mobile/Hitbox/HitboxModes/hitboxModeList.txt");
		#if MOD_SUPPORT
		final moddyFolder:String = (ModsFolder.currentModFolder != null
			&& ModsFolder.currentModFolder != "default") ? '${ModsFolder.modsPath}${ModsFolder.currentModFolder}/mobile/Hitbox/HitboxModes/hitboxModeList.txt' : '';
		if (Assets.exists(moddyFolder))
		{
			HitboxTypes = mergeAllTextsNamed(moddyFolder);
		}
		#end

		add(new NumOption(getNameID('extraButtons'), getDescID('extraButtons'), 0, 4, 1, 'extraButtons'));
		add(new ArrayOption(getNameID('hitboxType'), getDescID('hitboxType'), ["No Gradient", "No Gradient (Old)", "Gradient"],
			["No Gradient", "No Gradient (Old)", "Gradient"], 'hitboxType'));
		add(new ArrayOption(getNameID('hitboxMode'), getDescID('hitboxMode'), HitboxTypes, HitboxTypes, 'hitboxMode'));
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
		#if android
		add(externalOption = new Checkbox(getNameID('useExternal'), getNameID('useExternal'), "useExternal"));
		#end
	}

	override function close()
	{
		super.close();

		#if android
		if (lastExternal != externalOption.checked)
		{
			Options.save();
			CoolUtil.safeSaveFile(lime.system.System.applicationStorageDirectory + "external.txt", Std.string(externalOption.checked));
			persistentUpdate = false;
			funkin.backend.utils.NativeAPI.showMessageBox(TU.translate('MobileOptions.storageTypeChange-title'), TU.translate('MobileOptions.storageTypeChange-body'));
			Sys.exit(0);
		}
		#end
	}
}