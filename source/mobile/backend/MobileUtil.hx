package mobile.backend;

#if android
import android.os.Build.VERSION;
import android.os.Environment;
import android.Permissions;
import android.Settings;
#end

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/** * @Authors ArkoseLabs, MaysLastPlay, MarioMaster (MasterX-39), Dechis (dx7405)
* @version: 0.3.0
**/

class MobileUtil {
	public static var currentDirectory:String = null;
	private static var useAlternativePath:Bool = false;
	#if android
	public static var sdk:Int = VERSION.SDK_INT;
	#end

	/**
	 * Get the directory for the application. (External for Android Platform and Internal for iOS Platform.)
	 * Now with automatic fallback to Android/media path if permissions fail.
	 */
	public static function getDirectory():String {
		#if android
		var paths = [
			"/storage/emulated/0/.CodenameEngine/",
			"/storage/emulated/0/Android/media/com.yoshman29.codenameengine/"
		];

		if (sdk >= 30) return paths[0];

		return paths[1];
		#elseif ios
		return System.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	/**
	 * Requests Storage Permissions on Android Platform.
	 */
	public static function getPermissions():Void {
		#if android
		var path = MobileUtil.getDirectory();

		try {
			if (sdk >= 30) {
				if (!Environment.isExternalStorageManager()) {
					Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
				}
			} else {
				Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
			}

			if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		} catch (e:Dynamic) {
			if (!FileSystem.exists(path)) {
				try {
					FileSystem.createDirectory(path);
				} catch (e2:Dynamic) {
					NativeAPI.showMessageBox('Error', "Failed to access storage. Please check your settings and enable required permissions.");
				}
			}
		}
		#end
	}

	/**
	 * Saves a file to the external storage.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!') {
		var savesDir:String = Path.join([MobileUtil.getDirectory(), "saves"]);

		if (!FileSystem.exists(savesDir))
			FileSystem.createDirectory(savesDir);

		File.saveContent(savesDir + fileName + fileExt, fileData);
	}

		/**
	 * @param folders Optional list of specific folders (e.g. ["assets/data/"]). If null, copies all assets.
	 */
	public static function copyAssets(folders:Array<String> = null, onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		var rootTarget = getDirectory();
		try {
			var assetList:Array<String> = Assets.list();

			var toCopy = assetList.filter(function(assetKey) {
				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				if (!StringTools.startsWith(cleanPath, "assets/")) return false;
				if (folders == null) return true;

				for (f in folders) {
					if (StringTools.startsWith(cleanPath, f)) return true;
				}
				return false;
			});

			var total = toCopy.length;
			if (total == 0) {
				if (onComplete != null) onComplete();
				return;
			}

			for (i in 0...total) {
				var assetKey = toCopy[i];

				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				var fullPath = Path.join([rootTarget, cleanPath]);

				var directory = Path.directory(fullPath);
				if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);

				if (!FileSystem.exists(fullPath)) {
					var bytes:Bytes = null;

					try {
						bytes = Assets.getBytes(assetKey);
					} catch (e:Dynamic) {
						try {
							var text:String = Assets.getText(assetKey);
							if (text != null) {
								bytes = Bytes.ofString(text);
							}
						} catch (e2:Dynamic) {
							trace('Failed to read text fallback for $assetKey: $e2');
						}
					}

					if (bytes != null) {
						File.saveBytes(fullPath, bytes);
					} else {
						trace('Could not extract data for asset: $assetKey');
					}
				}

				if (onProgress != null) onProgress(cleanPath, i + 1, total);
			}

			if (onComplete != null) onComplete();
		} catch (e:Dynamic) {
			trace('Asset Copy Error: $e');
		}
		#end
	}
}