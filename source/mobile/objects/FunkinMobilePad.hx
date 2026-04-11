package mobile.objects;

import mobile.MobilePad;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class FunkinMobilePad extends MobilePad {
	public var curDPadMode(default, null):String = "NONE";
	public var curActionMode(default, null):String = "NONE";
	public function new(DPad:String = "NONE", Action:String = "NONE", buttonCreation:Bool = true) {
		super(DPad, Action, buttonCreation);
		curDPadMode = DPad;
		curActionMode = Action;
	}

	override public function createVirtualButton(x:Float, y:Float, framePath:String, ?scale:Float = 1.0, ?ColorS:Int = 0xFFFFFF, ?returned:String):MobileButton {
		var frames:FlxGraphic;
		var buttonLabelGraphicPath:String = "";
		#if MOD_SUPPORT
		final moddyFolder:String = (ModsFolder.currentModFolder != null
			&& ModsFolder.currentModFolder != "default") ? '${ModsFolder.modsPath}${ModsFolder.currentModFolder}/mobile' : '';
		#end

		final defaultPath:String = 'assets/mobile/MobilePad/Textures/$framePath.png';
		#if MOD_SUPPORT
		final moddyPath:String = '$moddyFolder/MobilePad/Textures/$framePath.png';
		if (FileSystem.exists(moddyPath))
			buttonLabelGraphicPath = moddyPath;
		else
		#end
			buttonLabelGraphicPath = defaultPath;

		if (FileSystem.exists(buttonLabelGraphicPath))
			frames = FlxGraphic.fromBitmapData(BitmapData.fromBytes(File.getBytes(buttonLabelGraphicPath)));
		else
			frames = FlxGraphic.fromBitmapData(Assets.getBitmapData(buttonLabelGraphicPath));

		var button = new MobileButton(x, y, returned);
		button.scale.set(scale, scale);
		button.frames = FlxTileFrames.fromGraphic(frames, FlxPoint.get(Std.int(frames.width / 2), frames.height));

		button.updateHitbox();
		button.updateLabelPosition();

		button.bounds.makeGraphic(Std.int(button.width - 50), Std.int(button.height - 50), FlxColor.TRANSPARENT);
		button.centerBounds();

		button.immovable = true;
		button.solid = button.moves = false;
		button.antialiasing = Options.antialiasing;
		button.tag = framePath.toUpperCase();

		if (ColorS != -1) button.color = ColorS;
		return button;
	}

	public function new(DPad:String, Action:String) {
		super(DPad, Action);
	}
}