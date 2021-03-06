//
//  DetailViewController.m
//  Studio Notes
//
//  Created by Trevor Vieweg on 7/23/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "DetailViewController.h"
#import "DataSource.h"

@interface DetailViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *bpmTextField;
@property (weak, nonatomic) IBOutlet UITextField *songKeyTextField;
@property (strong, nonatomic) UITextView *noteTextView;

@property (assign, nonatomic) BOOL isRecording;
@property (assign, nonatomic) BOOL viewMovedUp;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

#pragma mark - View methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self configureView];
    self.noteTextView.delegate = self;
    self.noteTextView.dataDetectorTypes = UIDataDetectorTypeAll;

}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.titleTextField.text = [_detailItem valueForKey:@"title"];
        self.noteTextView.text = [_detailItem valueForKey:@"productionNotes"];
        self.bpmTextField.text = [_detailItem valueForKey:@"bpm"];
        self.songKeyTextField.text = [_detailItem valueForKey:@"key"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[_detailItem valueForKey:@"audioData"] error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
        [self toggleRecordingIcon];
        
        if ([self.noteTextView.text isEqualToString:@""]) {
            self.noteTextView.text = @"Add notes/lyrics here";
            self.noteTextView.textColor = [UIColor lightGrayColor]; //optional
            
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Audio Recording Setup
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.m4a"]];
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatAppleLossless],AVFormatIDKey,
                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    
    self.audioRecorder = [[AVAudioRecorder alloc]
                          initWithURL:audioFileURL
                          settings:audioSettings
                          error:nil];
    
    UIColor *placeholderTextColor = [UIColor colorWithRed:88/255.0 green:110/255.0 blue:117/255.0 alpha:1.0];
    
    NSAttributedString *bpmPlaceholder = [[NSAttributedString alloc] initWithString:@"BPM" attributes:@{ NSForegroundColorAttributeName : placeholderTextColor}];
    self.bpmTextField.attributedPlaceholder = bpmPlaceholder;
    
    NSAttributedString *keyPlaceholder = [[NSAttributedString alloc] initWithString:@"Key" attributes:@{ NSForegroundColorAttributeName : placeholderTextColor}];
    self.songKeyTextField.attributedPlaceholder = keyPlaceholder;
    
    // Listen for will show/hide notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(didPressShareButton)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    //noteTextView setup
    self.noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 280, self.view.frame.size.width, self.view.frame.size.height - 280 - 15)];
    self.noteTextView.backgroundColor = [UIColor colorWithRed:0/255.0 green:43/255.0 blue:54/255.0 alpha:1.0];
    self.noteTextView.textColor = [UIColor whiteColor];
    //Add tap gesture recognizer to toggle noteTextView data type recognition and editability.
    UITapGestureRecognizer *noteTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(noteTextRecognizerTapped:)];
    noteTapRecognizer.delegate = self;
    [self.noteTextView addGestureRecognizer:noteTapRecognizer];
    [self.view addSubview:self.noteTextView];
    
    //Add tap recognizer to screen to dismiss keyboard.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidFire)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //Save notes and return to previous sheet.
    [self.detailItem setValue:self.titleTextField.text forKey:@"title"];
    [self.detailItem setValue:self.noteTextView.text forKey:@"productionNotes"];
    [self.detailItem setValue:self.bpmTextField.text forKey:@"bpm"];
    [self.detailItem setValue:self.songKeyTextField.text forKey:@"key"];
    
    [[DataSource sharedInstance] saveContext];
}

#pragma mark - Keyboard methods

- (void)keyboardWillShow:(NSNotification *)notification {
    // move the toolbar frame up as keyboard animates into view
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    if ([self.noteTextView isFirstResponder] && CGRectGetMaxY(self.noteTextView.frame) > self.view.frame.size.height - keyboardFrame.size.height) {
        self.viewMovedUp = YES;
        [self moveToolBarUp:self.viewMovedUp forKeyboardNotification:notification];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // move the toolbar frame down as keyboard animates into view
    if (self.viewMovedUp == YES) {
        self.viewMovedUp = NO;
        [self moveToolBarUp:self.viewMovedUp forKeyboardNotification:notification];
    }
}

#pragma mark - Tap Gesture Recognizer Methods

- (void) noteTextRecognizerTapped:(UITapGestureRecognizer *)recognizer {
    self.noteTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.noteTextView.editable = YES;
    [self.noteTextView becomeFirstResponder];
}

- (void) tapDidFire {
    [self.view endEditing:YES];
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.noteTextView) {
        if ([textView.text isEqualToString:@"Add production notes here"]) {
            textView.text = @"";
        }
        [textView becomeFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.editable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeAll;

    if (textView == self.noteTextView) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Add production notes here";
        }
        [textView resignFirstResponder];
    }
}

#pragma mark - Keyboard Animation

- (void)moveToolBarUp:(BOOL)up forKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = CGRectMake(self.noteTextView.frame.origin.x, self.noteTextView.frame.origin.y, self.noteTextView.frame.size.width,self.noteTextView.frame.size.height + (keyboardFrame.size.height*(up ? -1 : 1)));
        
    [self.noteTextView setFrame:newFrame];
    
    [UIView commitAnimations];
}

#pragma mark - Sharing

- (void) didPressShareButton {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    [itemsToShare addObject:self.titleTextField.text];
    
    if (self.bpmTextField.text.length > 0) {
        [itemsToShare addObject:self.bpmTextField.text];
    }
    
    if (self.songKeyTextField.text.length > 0) {
        [itemsToShare addObject:self.songKeyTextField.text];
    }
    
    if (![self.noteTextView.text isEqualToString:@"Add notes/lyrics here"]) {
        [itemsToShare addObject:self.noteTextView.text];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - Audio recording

- (void)toggleRecordingIcon {
    if (self.isRecording) {
        self.recordingImage.hidden = NO;
    } else {
        self.recordingImage.hidden = YES;
    }
}

- (IBAction)audioRecord:(id)sender {
    [self.timer invalidate];
    [self.audioProgress setHidden:YES];
    
    self.isRecording = YES;
    [self toggleRecordingIcon];
    
    [self.audioRecorder record];
}

- (IBAction)audioStop:(id)sender
{
    [self.audioPlayer stop];
    [self.audioRecorder stop];
    
    self.isRecording = NO;
    [self toggleRecordingIcon];
    
    NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.m4a"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:nil];
    
    //Save it to core data here
    NSData *audioData = [NSData dataWithContentsOfURL:audioFileURL];
    [self.detailItem setValue:audioData forKey:@"audioData"];

}

- (IBAction)audioPlay:(id)sender {
    [self.audioPlayer play];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                selector:@selector(updateProgress)
                                                userInfo:nil
                                                 repeats:YES];
    [self.audioProgress setHidden:NO];
}

- (void)updateProgress {
    float timeLeft = self.audioPlayer.currentTime/self.audioPlayer.duration;
    
    // update the UIProgress
    self.audioProgress.progress= timeLeft;
}

@end
