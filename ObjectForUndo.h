

#import <Foundation/Foundation.h>

@interface ObjectForUndo : NSObject {
@private
    CGImageRef imageRef;
    CGRect imageRect;
}

@property (assign) CGImageRef imageRef;
@property (assign) CGRect imageRect;

@end
