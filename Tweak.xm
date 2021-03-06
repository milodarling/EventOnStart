#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <Foundation/Foundation.h>

#define Dismiss [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/VibrateOnStart.bundle"] localizedStringForKey:@"DISMISS" value:@"" table:@"VibrateOnStart"]

#define Dismiss_iPad [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/VibrateOnStart.bundle"] localizedStringForKey:@"DISMISS" value:@"" table:@"VibrateOnStart-iPad"]

static NSString *welcomeMessage;
static BOOL enabled;
static BOOL vibration;
static BOOL flashlight;
static BOOL sound;
static BOOL welcome;
static NSURL *soundURL;

static void vibrate() {
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

static void turnOnFlashlight() {
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil) 
  {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
      [device lockForConfiguration:nil];

      [device setTorchMode:AVCaptureTorchModeOn];
      [device setFlashMode:AVCaptureFlashModeOn];

      [NSThread sleepForTimeInterval:0.7];
      
      [device setTorchMode:AVCaptureTorchModeOff];
      [device setFlashMode:AVCaptureFlashModeOff];

      [device unlockForConfiguration];
    }
  }
}

static void playSound() {
  AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
  audioPlayer.numberOfLoops = 0;
  audioPlayer.volume = 1.0;
  [audioPlayer play];
}
static void showWelcome() {
  NSString *dismissString = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? Dismiss_iPad : Dismiss;

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
  message:welcomeMessage
  delegate:nil
  cancelButtonTitle:dismissString
  otherButtonTitles:nil];
  [alert show];
  [alert release];
}


%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
  %orig;

  if (!enabled)
    return;

  if (vibration) {
    vibrate();
  }

  if (sound) {
    playSound();
  }

  if (welcome) {
    showWelcome();
  }

  if (flashlight) {
    turnOnFlashlight();
  }

}

%end

//this code is run before anything else
%ctor {
  @autoreleasepool {
    NSArray *sounds = @[
      @"Apex.caf",
      @"Beacon.caf",
      @"Bulletin.caf",
      @"By The Seaside.caf",
      @"Chimes.caf",
      @"Circuit.caf",
      @"Constellation.caf",
      @"Cosmic.caf",
      @"Crystals.caf",
      @"Hillside.caf",
      @"Illuminate.caf",
      @"Night Owl.caf",
      @"Opening.caf",
      @"Playtime.caf",
      @"Presto.caf",
      @"Radar.caf",
      @"Radiate.caf",
      @"Ripples.caf",
      @"Sencha.caf",
      @"Signal.caf",
      @"Silk.caf",
      @"Slow Rise.caf",
      @"Stargaze.caf",
      @"Summit.caf",
      @"Twinkle.caf",
      @"Uplift.caf",
      @"Waves.caf",
      @"Aurora.caf",
      @"Bamboo.caf",
      @"Chord.caf",
      @"Circles.caf",
      @"Complete.caf",
      @"Hello.caf",
      @"Input.caf",
      @"Keys.caf",
      @"Note.caf",
      @"Popcorn.caf",
      @"Pulse.caf",
      @"Synth.caf",
      @"Beep.caf",
      @"Mac.caf",
      @"Ubuntu.caf"
    ];

    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ziph0n.vibrateonstart.plist"];
    welcomeMessage = [prefs objectForKey:@"welcomeString"];
    enabled = [[prefs objectForKey:@"enabled"] boolValue];
    vibration = [[prefs objectForKey:@"vibration"] boolValue];
    flashlight = [[prefs objectForKey:@"flashlight"] boolValue];
    sound = [[prefs objectForKey:@"sound"] boolValue];
    welcome = [[prefs objectForKey:@"welcome"] boolValue];
    NSInteger index = [[prefs objectForKey:@"SoundList"] intValue];
    soundURL = [NSURL fileURLWithPath:[@"/Library/EventOnStart" stringByAppendingPathComponent:sounds[index]]];
  }
}
