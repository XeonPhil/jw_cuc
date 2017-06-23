//
//  JWLoginTextField.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/5/3.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWLoginTextField.h"

@implementation JWLoginTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIColor *white = [UIColor whiteColor];
        UIView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"JWLoginTextField"
                                                         owner:self
                                                       options:nil] objectAtIndex:0];
        self.backgroundColor = [UIColor clearColor];
        xibView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        xibView.layer.cornerRadius = 25.0;
        xibView.layer.masksToBounds = YES;
        xibView.layer.borderColor = [white CGColor];
        xibView.layer.borderWidth = 1.0;
        UIImageView *img = [xibView viewWithTag:1];
        UITextField *txt = [xibView viewWithTag:2];
        _textField = txt;
        txt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"..." attributes:@{NSForegroundColorAttributeName: white}];
        _imageView = img;
        _imageView.contentMode = UIViewContentModeCenter;
        xibView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: xibView];
    }
    return self;
}
@end
