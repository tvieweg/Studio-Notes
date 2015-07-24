//
//  DetailViewController.m
//  Studio Notes
//
//  Created by Trevor Vieweg on 7/23/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *bpmTextField;
@property (weak, nonatomic) IBOutlet UITextField *songKeyTextField;
@property (weak, nonatomic) IBOutlet UITextView *lyricTextView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.titleTextField.text = [_detailItem valueForKey:@"title"];
        self.noteTextView.text = [_detailItem valueForKey:@"productionNotes"];
        self.bpmTextField.text = [_detailItem valueForKey:@"bpm"];
        self.songKeyTextField.text = [_detailItem valueForKey:@"key"];
        self.lyricTextView.text = [_detailItem valueForKey:@"lyrics"]; 
        

        if ([self.noteTextView.text isEqualToString:@""]) {
            self.noteTextView.text = @"Add production notes here";
            self.noteTextView.textColor = [UIColor lightGrayColor]; //optional

        }
        
        if ([self.lyricTextView.text isEqualToString:@""]) {
            self.lyricTextView.text = @"Add lyrics here";
            self.lyricTextView.textColor = [UIColor lightGrayColor]; //optional
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self configureView];
    self.noteTextView.delegate = self;
    self.lyricTextView.delegate = self; 

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //Save notes and return to previous sheet.
    
    [self.detailItem setValue:self.titleTextField.text forKey:@"title"];
    [self.detailItem setValue:self.noteTextView.text forKey:@"productionNotes"];
    [self.detailItem setValue:self.bpmTextField.text forKey:@"bpm"];
    [self.detailItem setValue:self.songKeyTextField.text forKey:@"key"];
    [self.detailItem setValue:self.lyricTextView.text forKey:@"lyrics"];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];

}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.noteTextView) {
        if ([textView.text isEqualToString:@"Add production notes here"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
        [textView becomeFirstResponder];
    } else {
        if ([textView.text isEqualToString:@"Add lyrics here"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
        [textView becomeFirstResponder];
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.noteTextView) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Add production notes here";
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
        [textView resignFirstResponder];
    } else {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Add lyrics here";
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
        [textView resignFirstResponder];
    }
    
}

@end
