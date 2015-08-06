//
//  ShareViewController.m
//  Share Extension
//
//  Created by Trevor Vieweg on 7/29/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "ShareViewController.h"
#import "DataSource.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[DataSource sharedInstance] insertNewObjectWithTitle:self.contentText bpm:nil key:nil  productionNotes:[url absoluteString]];
                    });
                }];
            } else {
                [[DataSource sharedInstance] insertNewObjectWithTitle:self.contentText bpm:nil key:nil productionNotes:nil];
            }
        }
    }
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
