
#import <Foundation/Foundation.h>

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface NSBubbleData : NSObject

@property (readonly, nonatomic, strong) NSDate          *date;
@property (readonly, nonatomic)         NSBubbleType    type;
@property (readonly, nonatomic, strong) UIView          *view;
@property (readonly, nonatomic)         UIEdgeInsets    insets;
@property (nonatomic, strong)           UIImage         *avatar;
@property (nonatomic, strong)           NSString        *sender;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithDictionary:(NSDictionary *)data type:(NSBubbleType)type;

@end
