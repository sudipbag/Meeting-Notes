//
//  AppDelegate.h
//  Meeting Notes
//
//  Created by Judhajit on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyDocument.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    MyDocument *document;
}

-(void)setReadyDocument:(MyDocument*)myDoc;
- (IBAction)showHelp:(id)sender;
- (MyDocument*)getDocument;
@end
