
/**
 * This code was generated by [react-native-codegen](https://www.npmjs.com/package/react-native-codegen).
 *
 * Do not edit this file as changes may cause incorrect behavior and will be lost
 * once the code is regenerated.
 *
 * @generated by codegen project: GenerateModuleJavaSpec.js
 *
 * @nolint
 */

 package com.swmansion.audioapi;

 import com.facebook.proguard.annotations.DoNotStrip;
 import com.facebook.react.bridge.Promise;
 import com.facebook.react.bridge.ReactApplicationContext;
 import com.facebook.react.bridge.ReactContextBaseJavaModule;
 import com.facebook.react.bridge.ReactMethod;
 import com.facebook.react.bridge.ReadableArray;
 import com.facebook.react.bridge.ReadableMap;
 import com.facebook.react.turbomodule.core.interfaces.TurboModule;
 import javax.annotation.Nonnull;

 public abstract class NativeAudioAPIModuleSpec extends ReactContextBaseJavaModule implements TurboModule {
   public static final String NAME = "AudioAPIModule";

   public NativeAudioAPIModuleSpec(ReactApplicationContext reactContext) {
     super(reactContext);
   }

   @Override
   public @Nonnull String getName() {
     return NAME;
   }

   @ReactMethod(isBlockingSynchronousMethod = true)
   @DoNotStrip
   public abstract boolean install();

   @ReactMethod(isBlockingSynchronousMethod = true)
   @DoNotStrip
   public abstract double getDevicePreferredSampleRate();

   @ReactMethod
   @DoNotStrip
   public abstract void setAudioSessionActivity(boolean enabled, Promise promise);

   @ReactMethod
   @DoNotStrip
   public abstract void setAudioSessionOptions(String category, String mode, ReadableArray options, boolean allowHaptics);

   @ReactMethod
   @DoNotStrip
   public abstract void setLockScreenInfo(ReadableMap info);

   @ReactMethod
   @DoNotStrip
   public abstract void resetLockScreenInfo();

   @ReactMethod
   @DoNotStrip
   public abstract void enableRemoteCommand(String name, boolean enabled);

   @ReactMethod
   @DoNotStrip
   public abstract void observeAudioInterruptions(boolean enabled);

   @ReactMethod
   @DoNotStrip
   public abstract void observeVolumeChanges(boolean enabled);

   @ReactMethod
   @DoNotStrip
   public abstract void requestRecordingPermissions(Promise promise);

   @ReactMethod
   @DoNotStrip
   public abstract void checkRecordingPermissions(Promise promise);
 }
