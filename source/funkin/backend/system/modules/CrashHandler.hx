package funkin.backend.system.modules;

import funkin.backend.utils.NativeAPI;
import haxe.CallStack;
import openfl.Lib;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import lime.system.System as LimeSystem;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

final class CrashHandler {
	public static function init():Void {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onError);
		#elseif hl
		hl.Api.setErrorHandler(onError);
		#end
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void {
		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		var m:String = e.error;
		if (Std.isOfType(e.error, Error)) {
			var err:Error = cast e.error;
			m = '${err.message}';
		} else if (Std.isOfType(e.error, ErrorEvent)) {
			var err:ErrorEvent = cast e.error;
			m = '${err.text}';
		}
		var stack = haxe.CallStack.exceptionStack();
		var stackBuffer = new StringBuf();
		for(e in stack) {
			switch(e) {
				case CFunction: stackBuffer.add("Non-Haxe (C) Function\n");
				case Module(c): stackBuffer.add('Module ${c}\n');
				case FilePos(parent, file, line, col):
					switch(parent) {
						case Method(cla, func):
							stackBuffer.add('${Path.withoutExtension(file)}.$func() - line $line\n');
						case _:
							stackBuffer.add('${file} - line $line\n');
					}
				case LocalFunction(v):
					stackBuffer.add('Local Function ${v}\n');
				case Method(cl, m):
					stackBuffer.add('${cl} - ${m}\n');
			}
		}
		var stackLabel = stackBuffer.toString();
		#if sys
		try
		{
			if (!FileSystem.exists('crash'))
				FileSystem.createDirectory('crash');

			File.saveContent('crash/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', '$m\n$stackLabel');
		}
		catch (e:haxe.Exception)
			trace('Couldn\'t save error message. (${e.message})');
		#end

		e.preventDefault();
		e.stopPropagation();
		e.stopImmediatePropagation();

		NativeAPI.showMessageBox("Error!", '$m\n$stackLabel', MSG_ERROR);

		#if js
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		js.Browser.window.location.reload(true);
		#else
		LimeSystem.exit(1);
		#end
	}

	#if (cpp || hl)
	private static function onError(message:Dynamic):Void
	{
		throw Std.string(message);
	}
	#end
}