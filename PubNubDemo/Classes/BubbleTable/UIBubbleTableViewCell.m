
#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView        *customView;
@property (nonatomic, retain) UIImageView   *bubbleImage;
@property (nonatomic, retain) UIImageView   *avatarImage;
@property (nonatomic, retain) UILabel       *dateText;
@property (nonatomic, retain) UILabel       *senderText;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView  = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar  = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize dateText    = _dateText;
@synthesize senderText  = _senderText;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView  = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    self.dateText    = nil;
    self.senderText  = nil;
    
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
        [self.dateText removeFromSuperview];
        [self.senderText removeFromSuperview];
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
#else
        self.avatarImage = [[UIImageView alloc] init];
        self.dateText    = [[UILabel alloc] init];
        self.senderText  = [[UILabel alloc] init];
#endif
//        self.avatarImage.layer.cornerRadius = 9.0;
//        self.avatarImage.layer.masksToBounds = YES;
//        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
//        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        //CGFloat avatarY = 0.0f;
        
//        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
//        [self addSubview:self.avatarImage];
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
        
        self.dateText.frame = CGRectMake(avatarX + 5, 15, 50, 50);
        [self addSubview:self.dateText];
        
        NSCalendar          *calendar = [NSCalendar currentCalendar];
        NSDateComponents    *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.data.date];
        NSString            *dateString = [NSString stringWithFormat:@"%02ld:%02ld", [components hour], [components minute]];
        
        self.dateText.text = dateString;
        self.dateText.font = [UIFont systemFontOfSize:12];
        
        self.senderText.frame = CGRectMake(avatarX + 5, 0, 50, 50);
        [self addSubview:self.senderText];
        self.senderText.text = self.data.sender;
        self.senderText.font = [UIFont systemFontOfSize:12];
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }
    
    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

- (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    UIFont *font = [UIFont systemFontOfSize:12];
    
    UIGraphicsBeginImageContext(image.size);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor blackColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
