//
//  AMTagView.m
//  AMTagListView
//
//  Created by Andrea Mazzini on 20/01/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "AMTagView.h"
#import "Colours.h"

NSString * const AMTagViewNotification = @"AMTagViewNotification";

@interface AMTagView ()

@property (nonatomic, strong) UILabel	*labelText;
@property (nonatomic, strong) UIButton	*button;

@end

@implementation AMTagView

@synthesize isToggled;

#pragma mark - NSObject

+ (void)initialize
{
    [[AMTagView appearance] setRadius:kDefaultRadius];
    [[AMTagView appearance] setTagLength:kDefaultTagLength];
    [[AMTagView appearance] setHoleRadius:kDefaultHoleRadius];
    [[AMTagView appearance] setInnerTagPadding:kDefaultInnerPadding];
    [[AMTagView appearance] setTextPadding:kDefaultTextPadding];
    [[AMTagView appearance] setTextFont:kDefaultFont];
    [[AMTagView appearance] setTextColor:kDefaultTextColor];
    [[AMTagView appearance] setTagColor:kTagColour];
    [[AMTagView appearance] setInnerTagColor:kDefaultInnerTagColor];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.labelText = [[UILabel alloc] init];
        self.button = [[UIButton alloc] init];
        self.labelText.textAlignment = NSTextAlignmentCenter;
        self.isToggled = false;
        _radius = [[AMTagView appearance] radius];
        _tagLength = [[AMTagView appearance] tagLength];
        _holeRadius = [[AMTagView appearance] holeRadius];
        _innerTagPadding = [[AMTagView appearance] innerTagPadding];
        _textPadding = [[AMTagView appearance] textPadding];
        _textFont = [[AMTagView appearance] textFont];
        _textColor = [[AMTagView appearance] textColor];
        _tagColor = [[AMTagView appearance] tagColor];
        _innerTagColor = [[AMTagView appearance] innerTagColor];
        [self addSubview:self.labelText];
        [self addSubview:self.button];
        [self.button addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.labelText.layer setCornerRadius:self.radius / 2];
    [self.labelText setFrame:(CGRect){
        (int)(self.tagLength + self.innerTagPadding + (self.tagLength ? self.radius / 2 : 0)),
        (int)(self.innerTagPadding),
        (int)(self.frame.size.width - self.innerTagPadding * 2 - self.tagLength - (self.tagLength ? self.radius / 2 : 0)),
        (int)(self.frame.size.height - self.innerTagPadding * 2)
    }];

    [self.button setFrame:self.labelText.frame];
    [self.labelText setTextColor:self.textColor];
    [self.labelText setFont:self.textFont];
}

- (void)drawRect:(CGRect)rect
{

    [self drawWithoutTagForRect:rect];
}

#pragma mark - Private Interface

- (void)actionButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[[NSNotification alloc] initWithName:AMTagViewNotification object:self userInfo:@{@"superview": self.superview}]];
}


- (void)drawWithoutTagForRect:(CGRect)rect
{
    UIBezierPath* backgroundPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.radius];
    [self.tagColor setFill];
    [backgroundPath fill];
    
    CGRect inset = CGRectInset(rect, self.innerTagPadding, self.innerTagPadding);
    UIBezierPath* insidePath = [UIBezierPath bezierPathWithRoundedRect:inset cornerRadius:self.radius / 2];
    [self.innerTagColor setFill];
    [insidePath fill];
}

#pragma mark - Public Interface

- (void)setTagColor:(UIColor *)tagColor
{
    _tagColor = tagColor;
    [self setNeedsDisplay];
}

- (void)setInnerTagColor:(UIColor *)innerTagColor
{
    _innerTagColor = innerTagColor;
    [self setNeedsDisplay];
}

- (void)setupWithText:(NSString*)text
{
    UIFont* font = self.textFont;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    float padding = self.textPadding;
    float tagLength = self.tagLength;
    
    size.width = (int)size.width + padding * 2 + tagLength;
    size.height = (int)size.height + padding;
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    
    [self.labelText setText:text];
}

- (NSString*)tagText
{
    return self.labelText.text;
}

@end
