//
//  AppDelegate.m
//  Meeting Notes
//
//  Created by Judhajit on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)showHelp:(id)sender{
    
    NSURL *url = nil;
    switch ([sender tag]) {
        case 0:
            
            url = [[NSURL alloc] initWithString:@"macappstore://itunes.apple.com/app/id461747161?mt=12"];//faceBook
            break;
        case 1:
            url = [[NSURL alloc] initWithString:@"http://www.ilifetouch.com/461747161.html"];
            break;
        default:
            url = [[NSURL alloc] initWithString:@"http://ilifetouch.com/"];
            break;
    }
    [[NSWorkspace sharedWorkspace] openURL:url];
}


-(void)setReadyDocument:(MyDocument*)myDoc
{
    document = myDoc;
}

- (MyDocument*)getDocument{
    return document;
}
-(void)ensureDocumentOpen
{
    if(document == nil)
    {
        [[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
        //[[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"My Document Type"];
        NSLog(@"Trying explicit document open");
        NSLog(@"Shared Document controller :: %@",[[NSDocumentController sharedDocumentController] description]);
        [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
    }
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSLog(@"Application finished launching");
    //NSAppleScript *start = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"activate application \"Meeting Notes\" "]]; 
    //[start executeAndReturnError:nil];
    //[start release];
    //[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
    
    [self performSelector:@selector(ensureDocumentOpen) withObject:nil afterDelay:2.0f];
    
}


@end
