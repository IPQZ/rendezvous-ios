//
//  AMTagView.h
//  AMTagListView
//
//  Created by Andrea Mazzini on 20/01/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//
#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

#define kDefaultInnerPadding	5
#define kDefaultHoleRadius		4
#define kDefaultTagLength		0
#define kDefaultTextPadding		25
#define kDefaultRadius			10
#define kDefaultTextColor		[UIColor whiteColor]
#define kDefaultFont			[UIFont systemFontOfSize:20]
#define kDefaultInnerTagColor	[UIColor colorWithWhite:1 alpha:0.0]

extern NSString * const AMTagViewNotification;

@interface AMTagView : UIView

@property (nonatomic, assign) float		radius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) float		tagLength UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) float		innerTagPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) float		holeRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) float		textPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont	*textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*tagColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor	*innerTagColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) bool isToggled;

- (void)setupWithText:(NSString*)text;
- (NSString*)tagText;

@end
