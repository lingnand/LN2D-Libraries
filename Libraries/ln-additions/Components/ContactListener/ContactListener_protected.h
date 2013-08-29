#import "ContactListener.h"

@interface ContactListener ()
@property(nonatomic, strong) NSMutableDictionary *contactCallBacks;
- (NSMutableDictionary *)writableContactCallBacks;
@end
