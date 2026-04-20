package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import mobile.MobilePad;
import mobile.Hitbox;
import mobile.JoyStick;
import flixel.FlxBasic;

/**
 * A simple mobile manager for who doesn't want to create these manually
 * if you're making big projects or have a experience to how controls work, create the controls yourself
 */
class MobileControlManager implements IFlxDestroyable {
	public var mobilePadCam:FlxCamera;
	public var mobilePad:FunkinMobilePad;
	public var joyStickCam:FlxCamera;
	public var joyStick:FunkinJoyStick;
	public var hitboxCam:FlxCamera;
	public var hitbox:FunkinHitbox;
	public var curState:Dynamic;

	public function new(target:Dynamic):Void
	{
		curState = target;
		//trace("MobileControlManager initialized.");
	}

	//for lua shit
	public function makeMobilePad(DPad:String, Action:String)
	{
		if (mobilePad != null) removeMobilePad();
		mobilePad = new FunkinMobilePad(DPad, Action);
		mobilePad.alpha = Options.controlsAlpha;
	}

	public function addMobilePad(DPad:String, Action:String)
	{
		makeMobilePad(DPad, Action);
		curState.add(mobilePad);
	}

	public function removeMobilePad():Void
	{
		if (mobilePad != null)
		{
			curState.remove(mobilePad);
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
		}

		if(mobilePadCam != null)
		{
			FlxG.cameras.remove(mobilePadCam);
			mobilePadCam = FlxDestroyUtil.destroy(mobilePadCam);
		}
	}

	public function addMobilePadCamera(defaultDrawTarget:Bool = false):Void
	{
		mobilePadCam = new FlxCamera();
		mobilePadCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobilePadCam, defaultDrawTarget);
		mobilePad.cameras = [mobilePadCam];
	}

	public function makeHitbox(?mode:String, ?hints:Bool)
	{
		if (hitbox != null) removeHitbox();
		hitbox = new FunkinHitbox(mode, hints);
		hitbox.alpha = Options.controlsAlpha;
	}

	public function addHitbox(?mode:String, ?hints:Bool)
	{
		makeHitbox(mode, hints);
		curState.add(hitbox);
	}

	public function removeHitbox():Void
	{
		if (hitbox != null)
		{
			curState.remove(hitbox);
			hitbox = FlxDestroyUtil.destroy(hitbox);
		}

		if(hitboxCam != null)
		{
			FlxG.cameras.remove(hitboxCam);
			hitboxCam = FlxDestroyUtil.destroy(hitboxCam);
		}
	}

	public function addHitboxCamera(defaultDrawTarget:Bool = false):Void
	{
		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, defaultDrawTarget);
		hitbox.cameras = [hitboxCam];
	}

	public function makeJoyStick(x:Float = 0, y:Float = 0, ?graphic:String, ?onMove:Float->Float->Float->String->Void, size:Float = 1):Void
	{
		if (joyStick != null) removeJoyStick();
		joyStick = new FunkinJoyStick(x, y, graphic, onMove);
		joyStick.scale.set(size, size);
	}

	public function addJoyStick(x:Float = 0, y:Float = 0, ?graphic:String, ?onMove:Float->Float->Float->String->Void, size:Float = 1):Void
	{
		makeJoyStick(x, y, graphic, onMove, size);
		curState.add(joyStick);
	}

	public function removeJoyStick():Void
	{
		if (joyStick != null)
		{
			curState.remove(joyStick);
			joyStick = FlxDestroyUtil.destroy(joyStick);
		}

		if(joyStickCam != null)
		{
			FlxG.cameras.remove(joyStickCam);
			joyStickCam = FlxDestroyUtil.destroy(joyStickCam);
		}
	}

	public function addJoyStickCamera(defaultDrawTarget:Bool = false):Void {
		joyStickCam = new FlxCamera();
		joyStickCam.bgColor.alpha = 0;
		FlxG.cameras.add(joyStickCam, defaultDrawTarget);
		joyStick.cameras = [joyStickCam];
	}

	public function destroy():Void {
		removeMobilePad();
		removeHitbox();
		removeJoyStick();
	}
}
