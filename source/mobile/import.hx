#if !macro
import funkin.options.Options;
import mobile.objects.FunkinHitbox;
import mobile.objects.FunkinMobilePad;
import funkin.backend.assets.ModsFolder;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

#if android
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.widget.Toast as AndroidToast;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
#end

#end