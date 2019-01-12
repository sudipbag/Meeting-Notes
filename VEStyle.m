//
//  VEStyle.m
//  Face for Facebook
//
//  Created by Samit on 9/19/14.
//
//

#import "VEStyle.h"

@implementation VEStyle
@synthesize bg;

- (void) awakeFromNib {
    if (&NSAppearanceNameVibrantDark!=0) {
        [self setAutoresizesSubviews:YES];
        
        NSAppearance *vibrantAppearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        
        if(self.isDark)
            vibrantAppearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        
        NSVisualEffectView *fxView = [[NSVisualEffectView alloc] initWithFrame:self.frame];
        fxView.appearance = vibrantAppearance;
        
        [fxView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:fxView];
        
        //[fxView release];
    }
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (&NSAppearanceNameVibrantDark!=0) {
        
    }
    else
    {
        if(self.bg != nil)
        {
            [self.bg set];
            NSRectFill([self bounds]);
        }
    }
    
    if(self.bg != nil)
    {
        [self.bg set];
        NSRectFill([self bounds]);
    }
}
@end
