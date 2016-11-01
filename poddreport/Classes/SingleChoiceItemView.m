//
//  SingleChoiceItemView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "SingleChoiceItemView.h"

@interface SingleChoiceItemView ()
@property (weak, nonatomic, nullable) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic, nullable) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic, nullable) IBOutlet UIButton *selectButton;
@end

@implementation SingleChoiceItemView

+ (instancetype _Nonnull)newChoiceForItem:(NSString * _Nonnull)item title:(NSString * _Nullable)titleString delegate:(id<ChoiceItemViewDelegate> _Nonnull)delegate {

    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:[NSBundle mainBundle]];
    SingleChoiceItemView *view = [nib instantiateWithOwner:self options:nil][0];
    view.item = item;
    view.title = titleString;
    view.delegate = delegate;
    return view;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.titleLabel.text = [self.title stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    [self.titleLabel setHighlighted:self.isSelected];
    [self.iconImageView setHighlighted:self.isSelected];
}

- (IBAction)didSelectItem:(id)sender {
    
    [self.delegate choiceItemDidSelectItem:self.item];
}

@end
