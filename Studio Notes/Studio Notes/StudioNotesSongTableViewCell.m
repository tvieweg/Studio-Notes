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

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        self.songTitle = [[UILabel alloc] init];
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
