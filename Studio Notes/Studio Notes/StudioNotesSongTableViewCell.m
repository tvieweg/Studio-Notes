//
//  StudioNotesSongTableViewCell.m
//  Studio Notes
//
//  Created by Trevor Vieweg on 8/3/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "StudioNotesSongTableViewCell.h"

@interface StudioNotesSongTableViewCell ()

@property (strong, nonatomic) UILabel *songTitle;

@end

@implementation StudioNotesSongTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:43/255.0 blue:54/255.0 alpha:1.0];
        self.textLabel.textColor = [UIColor whiteColor];
        
        //Note songTitle is not used anywhere in code currently. Custom table view class was to enable future build out at later point.
        self.songTitle = [[UILabel alloc] init];
        self.songTitle.textColor = [UIColor whiteColor]; 
        self.songTitle.frame = CGRectMake(48, 7, self.frame.size.width - 44, 44);
        self.songTitle.numberOfLines = 0;
        [self addSubview:self.songTitle];
    
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
