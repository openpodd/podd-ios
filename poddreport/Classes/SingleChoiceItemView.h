//
//  SingleChoiceItemView.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChoiceItemViewDelegate <NSObject>
- (void)choiceItemDidSelectItem:(id _Nonnull)item;
@end

@interface SingleChoiceItemView : UIView
@property (copy, nonatomic, nullable) NSString *title;
@property (copy, nonatomic, nonnull) NSString *item;
@property (assign, nonatomic, getter=isSelected) BOOL selected;
@property (unsafe_unretained, nullable) id<ChoiceItemViewDelegate> delegate;
+ (instancetype _Nonnull)newChoiceForItem:(NSString * _Nonnull)item title:(NSString * _Nullable)titleString delegate:(id<ChoiceItemViewDelegate> _Nonnull)delegate;
@end
