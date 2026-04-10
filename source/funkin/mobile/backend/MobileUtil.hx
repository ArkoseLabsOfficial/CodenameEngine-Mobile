package funkin.mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

/** 
* @Authors MaysLastPlay, ArkoseLabs, MarioMaster (MasterX-39), Dechis (dx7405)
* @version: 0.4.0
**/
typedef CustomStorageModeData = { modes:Array<ModeData> }
typedef ModeData = { Name:String, Folder:String }
class MobileUtil
{
	#if sys
	public static inline function getStorageDirectory():String
		return #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	#if android
	public static inline function getCustomStoragePath():String
		return AndroidContext.getExternalFilesDir() + '/storageModes.json';
	public static inline function getStorageTypePath():String
		return AndroidContext.getExternalFilesDir() + '/storagetype.txt';

	public static function getCustomStorageDirectories(?doNotSeperate:Bool):Array<String>
	{
		var curJsonFile:String = getCustomStoragePath();
		var ArrayReturn:Array<String> = [];

		if (FileSystem.exists(curJsonFile))
		{
			try {
				var rawJson:String = File.getContent(curJsonFile);
				var parsedData:CustomStorageModeData = haxe.Json.parse(rawJson);

				if (parsedData.modes != null) {
					for (mode in parsedData.modes) {
						if (mode.Name == null || mode.Folder == null) continue;

						if (doNotSeperate)
							// Keeping the "Name|Folder" format, so initDirectory() doesn't break
							ArrayReturn.push(mode.Name + "|" + mode.Folder);
						else
							ArrayReturn.push(mode.Name);
					}
				}
			} catch (e:haxe.Exception) {
				trace("Error parsing storage JSON: " + e.message);
			}
		}
		return ArrayReturn;
	}

	// always force path due to haxe
	public static var currentDirectory:String;
	public static function initDirectory():String {
		var daPath:String = '';
		if (!FileSystem.exists(getStorageTypePath()))
			File.saveContent(getStorageTypePath(), "EXTERNAL_OBB");

		var curStorageType:String = File.getContent(getStorageTypePath());

		/* Put this there because I don't want to override original paths, also brokes the normal storage system */
		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				var dat = line.split("|");
				daPath = dat[1];
			}
		}

		/* Hardcoded Storage Types, these types cannot be changed by Custom Type */
		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
			case 'EXTERNAL_OBB':
				daPath = AndroidContext.getObbDir();
			case 'EXTERNAL_MEDIA':
				daPath = AndroidEnvironment.getExternalStorageDirectory() + '/Android/media/' + lime.app.Application.current.meta.get('packageName');
			case 'EXTERNAL_DATA':
				daPath = AndroidContext.getExternalFilesDir();
			default: //technically not needed but here for safety -ArkoseLabs
				if (daPath == null || daPath == '') daPath = AndroidEnvironment.getExternalStorageDirectory() + '/.' + lime.app.Application.current.meta.get('file');
		}
		daPath = Path.addTrailingSlash(daPath);
		currentDirectory = daPath;

		try
		{
			if (!FileSystem.exists(MobileUtil.getStorageDirectory()))
				FileSystem.createDirectory(MobileUtil.getStorageDirectory());
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert("Looks like you doesn't have directory named\n" + MobileUtil.getStorageDirectory() +
			"\nBut maybe this couldn't be right, android loves to give errors like this\nPress OK & let's see what happens\nCurrent Error You Got:\n" + e, "Warning!");
			//lime.system.System.exit(1);
		}

		return daPath;
	}

	/**
	 * Requests Storage Permissions on Android Platform.
	 */
	public static function getPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}

	public static var lastGettedPermission:Int;
	public static function chmodPermission(fullPath:String) {
		var process = new Process('stat -c %a ${fullPath}');
		var stringOutput:String = process.stdout.readAll().toString();
		process.close();
		lastGettedPermission = Std.parseInt(stringOutput);
	}

	public static function chmod(permissions:Int, fullPath:String) {
		var process = new Process('chmod -R ${permissions} ${fullPath}');

		var exitCode = process.exitCode();
		if (exitCode == 0)
			trace('Success: Permissions for the ${fullPath} file have been set to (${permissions})');
		else
		{
			var errorOutput = process.stderr.readAll().toString();
			trace('ERROR: Request to change permissions for the (${fullPath}) file failed. Exit Code: ${exitCode}, Error: ${errorOutput}');
		}
		process.close();
	}
	#end

	public static function getDirectory():String
	{
		#if android
		return currentDirectory;
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	/**
	 * Saves a file to the external storage.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!', ?alert:Bool = true):Void
	{
		final folder:String = #if android MobileUtil.getDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				Application.current.window.alert('${fileName} has been saved.', "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				Application.current.window.alert('${fileName} couldn\'t be saved.\n${e.message}', "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#end

	public static function copySpesificFileFromAssets(filePathInAssets:String, copyTo:String, ?changeable:Bool)
	{
		try {
			if (Assets.exists(filePathInAssets)) {
				var fileData:Bytes = Assets.getBytes(filePathInAssets);
				if (fileData != null) {
					if (FileSystem.exists(copyTo) && changeable) {
						var existingFileData:Bytes = File.getBytes(filePathInAssets);
						if (existingFileData != fileData && existingFileData != null)
							File.saveBytes(copyTo, fileData);
					}
					else if (!FileSystem.exists(copyTo))
						File.saveBytes(copyTo, fileData);

					trace('Copied: $filePathInAssets -> $copyTo');
				} else {
					var textData = Assets.getText(filePathInAssets);
					if (textData != null) {
						if (FileSystem.exists(copyTo) && changeable) {
							var existingTxtData = File.getContent(filePathInAssets);
							if (existingTxtData != textData && existingTxtData != null)
								File.saveContent(copyTo, textData);
						}
						else if (!FileSystem.exists(copyTo))
							File.saveContent(copyTo, textData);
						trace('Copied (text): $filePathInAssets -> $copyTo');
					}
				}
			}
		} catch (e:Dynamic) {
			trace('Error copying file $filePathInAssets: $e');
		}
	}

	/**
	 * Copies recursively the assets folder from the APK to external directory
	 * @param sourcePath Path to the assets folder inside APK (usually "assets/")
	 * @param targetPath Destination path (optional, uses Sys.getCwd() + "assets/" if not specified)
	 */
	public static function copyAssetsFromAPK(sourcePath:String = "assets/", targetPath:String = null):Void {
		#if mobile
		if (targetPath == null)
			targetPath = Sys.getCwd() + "assets/";

		try {
			if (!FileSystem.exists(targetPath))
				FileSystem.createDirectory(targetPath);

			copyAssetsRecursively(sourcePath, targetPath);

			trace('Assets successfully copied to: $targetPath');
		} catch (e:Dynamic) {
			trace('Error copying assets: $e');
			Application.current.window.alert('Error!','Error copying game files. Check storage permissions or re-open the game to see what happens.');
		}
		#end
	}

	/**
	 * Helper function to copy assets recursively
	 */
	private static function copyAssetsRecursively(sourcePath:String, targetPath:String):Void {
		#if mobile
		try {
			var cleanSourcePath = sourcePath;
			if (StringTools.endsWith(cleanSourcePath, "/"))
				cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);

			var assetList:Array<String> = Assets.list();

			for (assetPath in assetList) {
				if (StringTools.startsWith(assetPath, cleanSourcePath)) {
					var relativePath = assetPath;

					if (StringTools.startsWith(relativePath, "assets/"))
						relativePath = relativePath.substring(7);

					if (relativePath == "") continue;

					var fullTargetPath = targetPath + relativePath;

					var targetDir = haxe.io.Path.directory(fullTargetPath);
					if (targetDir != "" && !FileSystem.exists(targetDir))
						createDirectoryRecursive(targetDir);

					try {
						if (Assets.exists(assetPath)) {
							var fileData:Bytes = Assets.getBytes(assetPath);
							if (fileData != null) {
								File.saveBytes(fullTargetPath, fileData);
								trace('Copied: $assetPath -> $fullTargetPath');
							} else {
								var textData = Assets.getText(assetPath);
								if (textData != null) {
									File.saveContent(fullTargetPath, textData);
									trace('Copied (text): $assetPath -> $fullTargetPath');
								}
							}
						}
					} catch (e:Dynamic) {
						trace('Error copying file $assetPath: $e');
					}
				}
			}
		} catch (e:Dynamic) {
			trace('Error in recursive copy: $e');
			throw e;
		}
		#end
	}

	/**
	 * Creates directories recursively
	 */
	private static function createDirectoryRecursive(path:String):Void {
		#if mobile
		if (FileSystem.exists(path)) return;

		var pathParts = path.split("/");
		var currentPath = "";

		for (part in pathParts) {
			if (part == "") continue;
			currentPath += "/" + part;

			if (!FileSystem.exists(currentPath)) {
				try {
					FileSystem.createDirectory(currentPath);
				} catch (e:Dynamic) {
					trace('Error creating directory $currentPath: $e');
				}
			}
		}
		#end
	}

	/**
	 * Copies assets with progress (advanced version)
	 * @param sourcePath Path to assets folder inside APK
	 * @param targetPath Destination path
	 * @param onProgress Optional callback for progress (current file, current count, total files)
	 * @param onComplete Optional callback when finished
	 */
	public static function copyAssetsWithProgress(sourcePath:String = "assets/", targetPath:String = null, 
													onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		if (targetPath == null) {
			targetPath = Sys.getCwd() + "assets/";
		}

		try {
			if (!FileSystem.exists(targetPath)) {
				FileSystem.createDirectory(targetPath);
			}

			var totalFiles = countAssetsFiles(sourcePath);
			var currentFile = 0;

			trace('Starting copy of $totalFiles files...');

			var cleanSourcePath = sourcePath;
			if (StringTools.endsWith(cleanSourcePath, "/")) {
				cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);
			}

			var assetList:Array<String> = Assets.list();

			for (assetPath in assetList) {
				if (StringTools.startsWith(assetPath, cleanSourcePath)) {
					var relativePath = assetPath;

					if (StringTools.startsWith(relativePath, "assets/")) {
						relativePath = relativePath.substring(7);
					}

					if (relativePath == "") continue;

					var fullTargetPath = targetPath + relativePath;

					var targetDir = haxe.io.Path.directory(fullTargetPath);
					if (targetDir != "" && !FileSystem.exists(targetDir)) {
						createDirectoryRecursive(targetDir);
					}

					try {
						if (Assets.exists(assetPath)) {
							var fileData:Bytes = Assets.getBytes(assetPath);
							if (fileData != null) {
								File.saveBytes(fullTargetPath, fileData);
							} else {
								var textData = Assets.getText(assetPath);
								if (textData != null) {
									File.saveContent(fullTargetPath, textData);
								}
							}

							currentFile++;

							if (onProgress != null) {
								onProgress(relativePath, currentFile, totalFiles);
							}

							trace('[$currentFile/$totalFiles] Copied: $relativePath');
						}

					} catch (e:Dynamic) {
						trace('Error copying $assetPath: $e');
					}
				}
			}
			trace('Copy completed! $currentFile files copied.');
			if (onComplete != null) {
				onComplete();
			}
		} catch (e:Dynamic) {
			trace('Error copying assets: $e');
			Application.current.window.alert('Error', 'Error copying game files. Check storage permissions or re-open the game to see what happens.');
		}
		#end
	}

	/**
	 * Counts total number of asset files for progress
	 */
	inline private static function countAssetsFiles(sourcePath:String):Int {
		#if mobile
		var count = 0;
		var cleanSourcePath = sourcePath;
		if (StringTools.endsWith(cleanSourcePath, "/"))
			cleanSourcePath = cleanSourcePath.substring(0, cleanSourcePath.length - 1);
		var assetList:Array<String> = Assets.list();

		for (assetPath in assetList) {
			if (StringTools.startsWith(assetPath, cleanSourcePath)) {
				var relativePath = assetPath;

				if (StringTools.startsWith(relativePath, "assets/"))
					relativePath = relativePath.substring(7);

				if (relativePath != "")
					count++;
			}
		}

		return count;
		#else
		return 0;
		#end
	}

	/**
	 * Checks if assets have already been copied
	 */
	inline public static function areAssetsCopied(sourcePath:String = "assets/", targetPath:String = null):Bool {
		#if mobile
		if (targetPath == null)
			targetPath = Sys.getCwd() + "assets/";

		if (!FileSystem.exists(targetPath))
			return false;

		var sourceCount = countAssetsFiles(sourcePath);
		var targetCount = countFilesInDirectory(targetPath);

		return sourceCount > 0 && sourceCount == targetCount;
		#else
		return false;
		#end
	}

	/**
	 * Counts files in a directory recursively
	 */
	inline private static function countFilesInDirectory(path:String):Int {
		#if mobile
		if (!FileSystem.exists(path)) return 0;

		var count = 0;
		var items = FileSystem.readDirectory(path);

		for (item in items) {
			var fullPath = path + "/" + item;
			if (FileSystem.isDirectory(fullPath))
				count += countFilesInDirectory(fullPath);
			else
				count++;
		}

		return count;
		#else
		return 0;
		#end
	}
}