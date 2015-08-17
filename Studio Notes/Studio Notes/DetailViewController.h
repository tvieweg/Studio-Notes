//
//  DetailViewController.h
//  Studio Notes
//
//  Created by Trevor Vieweg on 7/23/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

- (IBAction)audioRecord:(id)sender;
- (IBAction)audioPlay:(id)sender;
- (IBAction)audioStop:(id)sender;

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView *audioProgress;
@property (weak, nonatomic) IBOutlet UIImageView *recordingImage;

@end

