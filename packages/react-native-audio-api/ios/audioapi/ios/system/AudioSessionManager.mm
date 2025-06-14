#import <audioapi/ios/system/AudioSessionManager.h>

@implementation AudioSessionManager

- (instancetype)init
{
  if (self = [super init]) {
    self.audioSession = [AVAudioSession sharedInstance];

    self.sessionCategory = AVAudioSessionCategoryPlayback;
    self.sessionMode = AVAudioSessionModeDefault;
    self.sessionOptions = 0;
    self.allowHapticsAndSystemSoundsDuringRecording = false;
    self.hasDirtySettings = true;
    self.isActive = false;
  }

  return self;
}

- (void)cleanup
{
  NSLog(@"[AudioSessionManager] cleanup");

  self.audioSession = nil;
}

- (NSNumber *)getDevicePreferredSampleRate
{
  return [NSNumber numberWithFloat:[self.audioSession sampleRate]];
}

- (void)setAudioSessionOptions:(NSString *)category
                          mode:(NSString *)mode
                       options:(NSArray *)options
                  allowHaptics:(BOOL)allowHaptics
{
  AVAudioSessionCategory sessionCategory = self.sessionCategory;
  AVAudioSessionMode sessionMode = self.sessionMode;
  AVAudioSessionCategoryOptions sessionOptions = 0;
  bool allowHapticsAndSystemSoundsDuringRecording = allowHaptics;

  if ([category isEqualToString:@"record"]) {
    sessionCategory = AVAudioSessionCategoryRecord;
  } else if ([category isEqualToString:@"ambient"]) {
    sessionCategory = AVAudioSessionCategoryAmbient;
  } else if ([category isEqualToString:@"playback"]) {
    sessionCategory = AVAudioSessionCategoryPlayback;
  } else if ([category isEqualToString:@"multiRoute"]) {
    sessionCategory = AVAudioSessionCategoryMultiRoute;
  } else if ([category isEqualToString:@"soloAmbient"]) {
    sessionCategory = AVAudioSessionCategorySoloAmbient;
  } else if ([category isEqualToString:@"playAndRecord"]) {
    sessionCategory = AVAudioSessionCategoryPlayAndRecord;
  }

  if ([mode isEqualToString:@"default"]) {
    sessionMode = AVAudioSessionModeDefault;
  } else if ([mode isEqualToString:@"gameChat"]) {
    sessionMode = AVAudioSessionModeGameChat;
  } else if ([mode isEqualToString:@"videoChat"]) {
    sessionMode = AVAudioSessionModeVideoChat;
  } else if ([mode isEqualToString:@"voiceChat"]) {
    sessionMode = AVAudioSessionModeVoiceChat;
  } else if ([mode isEqualToString:@"measurement"]) {
    sessionMode = AVAudioSessionModeMeasurement;
  } else if ([mode isEqualToString:@"voicePrompt"]) {
    sessionMode = AVAudioSessionModeVoicePrompt;
  } else if ([mode isEqualToString:@"spokenAudio"]) {
    sessionMode = AVAudioSessionModeSpokenAudio;
  } else if ([mode isEqualToString:@"moviePlayback"]) {
    sessionMode = AVAudioSessionModeMoviePlayback;
  } else if ([mode isEqualToString:@"videoRecording"]) {
    sessionMode = AVAudioSessionModeVideoRecording;
  }

  for (NSString *option in options) {
    if ([option isEqualToString:@"duckOthers"]) {
      sessionOptions |= AVAudioSessionCategoryOptionDuckOthers;
    }

    if ([option isEqualToString:@"allowAirPlay"]) {
      sessionOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
    }

    if ([option isEqualToString:@"mixWithOthers"]) {
      sessionOptions |= AVAudioSessionCategoryOptionMixWithOthers;
    }

    if ([option isEqualToString:@"allowBluetooth"]) {
      sessionOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
    }

    if ([option isEqualToString:@"defaultToSpeaker"]) {
      sessionOptions |= AVAudioSessionCategoryOptionDefaultToSpeaker;
    }

    if ([option isEqualToString:@"allowBluetoothA2DP"]) {
      sessionOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
    }

    if ([option isEqualToString:@"overrideMutedMicrophoneInterruption"]) {
      sessionOptions |= AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption;
    }

    if ([option isEqualToString:@"interruptSpokenAudioAndMixWithOthers"]) {
      sessionOptions |= AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers;
    }
  }

  if (self.sessionCategory != sessionCategory) {
    self.hasDirtySettings = true;
    self.sessionCategory = sessionCategory;
  }

  if (self.sessionMode != sessionMode) {
    self.hasDirtySettings = true;
    self.sessionMode = sessionMode;
  }

  if (self.sessionOptions != sessionOptions) {
    self.hasDirtySettings = true;
    self.sessionOptions = sessionOptions;
  }

  if (self.allowHapticsAndSystemSoundsDuringRecording != allowHapticsAndSystemSoundsDuringRecording) {
    self.hasDirtySettings = true;
    self.allowHapticsAndSystemSoundsDuringRecording = allowHapticsAndSystemSoundsDuringRecording;
  }

  if (self.isActive) {
    [self configureAudioSession];
  }
}

- (bool)setActive:(bool)active
{
  if (active == self.isActive) {
    return true;
  }

  if (active) {
    [self configureAudioSession];
  }

  NSError *error = nil;

  bool success = [self.audioSession setActive:active error:&error];

  if (success) {
    self.isActive = active;
  }

  if (error != nil) {
    NSLog(@"[AudioSessionManager] setting session as %@ failed", active ? @"ACTIVE" : @"INACTIVE");
  } else {
    NSLog(@"[AudioSessionManager] session is %@", active ? @"ACTIVE" : @"INACTIVE");
  }

  return success;
}

- (bool)configureAudioSession
{
  if (![self hasDirtySettings]) {
    return true;
  }

  NSLog(
      @"[AudioSessionManager] configureAudioSession, category: %@, mode: %@, options: %lu, allowHaptics: %@",
      self.sessionCategory,
      self.sessionMode,
      (unsigned long)self.sessionOptions,
      self.allowHapticsAndSystemSoundsDuringRecording ? @"YES" : @"NO");

  NSError *error = nil;

  [self.audioSession setCategory:self.sessionCategory mode:self.sessionMode options:self.sessionOptions error:&error];

  if (error != nil) {
    NSLog(@"Error while configuring audio session: %@", [error debugDescription]);
    return false;
  }

  if (@available(iOS 13.0, *)) {
    [self.audioSession setAllowHapticsAndSystemSoundsDuringRecording:self.allowHapticsAndSystemSoundsDuringRecording
                                                               error:&error];

    if (error != nil) {
      NSLog(@"Error while setting allowHapticsAndSystemSoundsDuringRecording: %@", [error debugDescription]);
    }
  }

  self.hasDirtySettings = false;
  return true;
}

- (void)requestRecordingPermissions:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  if (@available(iOS 17, *)) {
    [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
      if (granted) {
        resolve(@"Granted");
      } else {
        resolve(@"Denied");
      }
    }];
  } else {
    [self.audioSession requestRecordPermission:^(BOOL granted) {
      if (granted) {
        resolve(@"Granted");
      } else {
        resolve(@"Denied");
      }
    }];
  }
}

- (void)checkRecordingPermissions:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  if (@available(iOS 17, *)) {
    NSInteger res = [[AVAudioApplication sharedInstance] recordPermission];
    switch (res) {
      case AVAudioApplicationRecordPermissionUndetermined:
        resolve(@"Undetermined");
        break;
      case AVAudioApplicationRecordPermissionGranted:
        resolve(@"Granted");
        break;
      case AVAudioApplicationRecordPermissionDenied:
        resolve(@"Denied");
        break;
      default:
        resolve(@"Undetermined");
        break;
    }
  } else {
    NSInteger res = [self.audioSession recordPermission];
    switch (res) {
      case AVAudioSessionRecordPermissionUndetermined:
        resolve(@"Undetermined");
        break;
      case AVAudioSessionRecordPermissionGranted:
        resolve(@"Granted");
        break;
      case AVAudioSessionRecordPermissionDenied:
        resolve(@"Denied");
        break;
      default:
        resolve(@"Undetermined");
        break;
    }
  }
}

- (NSString *)checkRecordingPermissions
{
  if (@available(iOS 17, *)) {
    NSInteger res = [[AVAudioApplication sharedInstance] recordPermission];
    switch (res) {
      case AVAudioApplicationRecordPermissionUndetermined:
        return @"Undetermined";
      case AVAudioApplicationRecordPermissionGranted:
        return @"Granted";
      case AVAudioApplicationRecordPermissionDenied:
        return @"Denied";
      default:
        return @"Undetermined";
    }
  } else {
    NSInteger res = [self.audioSession recordPermission];
    switch (res) {
      case AVAudioSessionRecordPermissionUndetermined:
        return @"Undetermined";
      case AVAudioSessionRecordPermissionGranted:
        return @"Granted";
      case AVAudioSessionRecordPermissionDenied:
        return @"Denied";
      default:
        return @"Undetermined";
    }
  }
}

@end
