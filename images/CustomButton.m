//
//  CustomButton.m
//  Meeting Notes
//
//  Created by Pritam on 10/21/14.
//
//

#import "CustomButton.h"

@implementation CustomButton

-(void)awakeFromNib
{
    [super awakeFromNib];
  //  [self setAlphaValue:0.5];
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    [self setAlphaValue:0.6];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    [self setAlphaValue:1.0];
}
@end
