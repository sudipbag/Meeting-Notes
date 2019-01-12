//
//  LGTextView.m
//  Sticky Notes 1
//
//  Created by Judhajit2 on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LGTextView.h"

@implementation LGTextView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)changeColor:(id)sender{
    NSArray *arrViews = [[[self window] contentView] subviews];
    NSInteger noOfViews = [arrViews count];
    NSInteger i = 0;
    for(i = 0; i < noOfViews; i++)
    {
        NSView *view = [arrViews objectAtIndex:i];
        if(view == nil)
            continue;
        
        if([view isKindOfClass:[NSColorWell class]] && [(NSColorWell *)view isActive])
        {
            return;
        }
    }
    [super changeColor:sender];
}

@end
