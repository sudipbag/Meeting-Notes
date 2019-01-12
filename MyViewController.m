//
//  MyViewController.m
//  010-NSView
//
#import "MyViewController.h"
#import "Canvas.h"
#import "Brush.h"


#define PI 3.14159265358979323846



static inline double radians(double degrees) { return degrees * PI / 180; }


@implementation MyViewController (PrivateMethods)



- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
	// We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
	//LSSharedFileListItemRef item = 
    LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);		
	//if (item)
	//	CFRelease(item);
}
- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(NSString *)appPath {
	UInt32 seedValue;
	CFURLRef thePath;
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {		
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:appPath]) {
				LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
			}
			// Docs for LSSharedFileListItemResolve say we're responsible
			// for releasing the CFURLRef that is returned
			//CFRelease(thePath);
		}		
	}
	CFRelease(loginItemsArray);
}

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(NSString *)appPath {
	BOOL found = NO;  
    
	UInt32 seedValue;
	CFURLRef thePath;
	
	// We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
	// and pop it in an array so we can iterate through it to find our item.
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {    
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:appPath]) {
				found = YES;
				break;
			}
		}
		// Docs for LSSharedFileListItemResolve say we're responsible
		// for releasing the CFURLRef that is returned
		//CFRelease(thePath);
	}
	CFRelease(loginItemsArray);
	
	return found;
}
@end




@implementation MyViewController

- (id)initWithFrame:(NSRect)pNsrectFrameRect {
    
    
    //[self setAlphaValue:0.2];
    
	if ((self = [super initWithFrame:pNsrectFrameRect]) == nil) {
		return self;
	} // end if
    myMutaryOfBrushStrokes	= [[NSMutableArray alloc]init];
    //srand(time(NULL));
    return self;
    
}
- (IBAction)toggleLoginItem:(id)sender {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
	
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		if ([sender state] == NSOnState)
			[self enableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
		else
			[self disableLoginItemWithLoginItemsReference:loginItems ForPath:appPath];
	}
	//CFRelease(loginItems);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{

    [mWindow makeKeyAndOrderFront:nil];
    return NO;
}
- (IBAction)makeCenter:(id)sender
{
    [mWindow center];
}




//Paint

//NSRect frame;

-(IBAction)setEraserAndPenStatus:(id)sender
{
    if([sender tag] ==1)
    {
        [pen setState:1];
        [brush setForeGroundColor:nil];
        [erase setState:0];
        
        [canvas setPen:nil];
    }
    else if([sender tag]==0)
    {
        [brush onEraser:nil];  
        [pen setState:0];
        [erase setState:1];
        
        [canvas setErase:nil];
    }   
    [TouchUnActive setHidden:YES];
    
    [self resetCursorRects];
}

-(IBAction) onClear:(id)sender
{
    [canvas setSaveUndo];
    
    WinX2 = 1;
    WinX1 = 370;
    
    WinY2 = 1;
    WinY1 = 320;
    
    
    if([brush getEraseButtonState ]== YES)
    {
        [brush setForeGroundColor:nil]; 
    }
    [canvas setClear];
    [self setNeedsDisplay:YES];
    bflag = false;
    
    [TouchUnActive setHidden:YES];
    
    [pen setState:1];
    [brush setForeGroundColor:nil];
    [erase setState:0];
    
    [pen setHidden:YES];
    [brush setForeGroundColor:nil];
    [erase setHidden:YES];
    
    [canvas setPen:nil];
    
    //if(TouchOver)
    if(sender == nil)
    {
        [mPointer setHidden:YES];
        [mPointerLine setHidden:YES];
        [mToolBG setHidden:YES];
        CGAssociateMouseAndMouseCursorPosition(true);
        TouchOver = NO;
    }
    
    [self resetCursorRects];
    
    [canvas clearUndoRedoData];
}

-(IBAction)setBackgroundcolor:(id)sender
{
    /*
     [pen setHidden:YES];
     [brush setForeGroundColor:nil];
     [erase setHidden:YES];
     
     [canvas setPen:nil];
     */
    
    [TouchUnActive setHidden:YES];
    [canvas setBackgroundcolor];
    [self setNeedsDisplay:YES];
}


-(NSImage*)captureImage
{
    [self lockFocus];
    //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self unlockFocus];
    
    NSImage *image = [[NSImage alloc] initWithSize:[rep size]];
    [image addRepresentation:rep];
    
    NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
    //save as png but failed
    
    NSImage *img =[[NSImage alloc] initWithData:data];
    
    [rep release];
    [image release];
    
    return [img autorelease];
}

-(IBAction)onUndo:(id)sender
{
    [canvas drawRectWhenUndo];
}

-(IBAction)onRedo:(id)sender
{
    [canvas drawRectWhenRedo];
}




/*
 
 
 - (id)initWithFrame:(NSRect)frame {
 self = [super initWithFrame:frame];
 if (self) {
 frame  = frame;
 // Create both the canvas and the brush. Create the canvas
 //	the same size as our initial size. Note that the canvas will not
 //	resize along with us.
 //canvas = [[Canvas alloc] initWithSize:frame.size];
 //  [canvas  initWithSize:frame.size];
 // [canvas initWithSize:frame.size];
 //brush = [[Brush alloc] init];
 }
 return self;
 }
 
 
 -(void)awakeFromNib
 {
 [canvas  initWithSize:[self frame].size];
 [[self window] makeFirstResponder: self];
 [[self window] setAcceptsMouseMovedEvents: YES];
 if ([[self window] acceptsMouseMovedEvents]) {NSLog(@"window now acceptsMouseMovedEvents");}
 
 [self setAcceptsTouchEvents:YES];
 [self setWantsRestingTouches:YES];
 // if ([[self window] acceptsTouchEvents]) {NSLog(@"window now acceptsMouseMovedEvents");}
 }
 
 
 - (void) dealloc
 {
 // Clean up our canvas and brush, since we own them
 //[canvas release];
 //[brush release];
 
 [super dealloc];
 }
 
 
 */

- (void)setFrame:(NSRect)frameRect
{
    [canvas  initWithSize:[self frame].size];
    [super setFrame:frameRect];
    //[canvas  initWithSize:[self bounds].size];
} 
- (void)drawRect:(NSRect)rect {
	// Simply ask the canvas to draw into the current context, given the
	//	rectangle specified. A more sophisticated view might draw a border
	//	around the canvas, or a pasteboard in the case that the view was
	//	bigger than the canvas.
	NSGraphicsContext* context = [NSGraphicsContext currentContext];	
	[canvas drawRect:rect inContext:context];
    
	//[canvas initWithSize:[self frame].size];
    
}



/*
 -(IBAction) saveAsImage:(id)sender
 {
 NSArray *path = [self openSavePanel];
 
 if(!path){ 
 [self setNeedsDisplay:YES];
 NSLog(@"No path selected, return..."); 
 return; 
 }
 
 NSArray *extention = [NSArray arrayWithObjects: @".png",nil];
 
 
 NSString *strOutPath =[path objectAtIndex:0];     
 NSLog(@"%@",strOutPath); 
 
 NSString *strExtensiion = [[strOutPath lastPathComponent] pathExtension]; 
 if(strExtensiion == nil || [strExtensiion length] ==0)
 strOutPath =[NSString stringWithFormat:@"%@%@",strOutPath,[extention objectAtIndex:0]];
 
 [self lockFocus];
 //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
 NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
 [self unlockFocus];
 
 NSImage *image = [[[NSImage alloc] initWithSize:[rep size]] autorelease];
 [image addRepresentation:rep];
 
 NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
 //save as png but failed
 
 NSImage *img =[[NSImage alloc] initWithData:data];
 
 //resize image
 NSData *newData = [self resizeImage :img size:CGRectMake(0, 0, 40, 40)];
 [newData writeToFile: strOutPath atomically: YES];
 
 NSImage *imageData = [[NSImage alloc] initWithData:newData];
 NSData * representation = [imageData TIFFRepresentation];
 
 [imageData autorelease];
 [img autorelease];
 [rep autorelease];
 
 }
 
 - (NSData*) resizeImage :(NSImage *) imgToResize size :(CGRect) rect
 {
 CGFloat sourceWidth = imgToResize.size.width;
 CGFloat sourceHeight = imgToResize.size.height;
 
 float nPercent = 0;
 float nPercentW = 0;
 float nPercentH = 0;
 
 nPercentW = ((float)rect.size.width / (float)sourceWidth);
 nPercentH = ((float)rect.size.height / (float)sourceHeight);
 
 if (nPercentH < nPercentW)
 nPercent = nPercentH;
 else
 nPercent = nPercentW;
 
 int destWidth = (int)(sourceWidth * nPercent);
 int destHeight = (int)(sourceHeight * nPercent);
 [imgToResize lockFocus];
 NSBitmapImageRep *repa =(NSBitmapImageRep*)[imgToResize bestRepresentationForDevice:nil  ];
 [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
 [repa setSize:NSMakeSize(destWidth,destHeight)];
 [imgToResize unlockFocus];
 
 return [repa representationUsingType:NSPNGFileType properties:nil];
 }
 
 -(IBAction) clipBoardAction:(id)sender
 {
 if([checkforClipboard state]== YES)
 {
 [self lockFocus];
 //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
 NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
 [self unlockFocus];
 
 NSImage *image = [[[NSImage alloc] initWithSize:[rep size]] autorelease];
 [image addRepresentation:rep];
 
 NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
 //save as png but failed
 
 NSImage *img =[[NSImage alloc] initWithData:data];
 
 //resize image
 NSData *newData = [self resizeImage :img size:CGRectMake(0, 0, 40, 40) ];
 
 //  [newData writeToFile: strOutPath atomically: YES];
 
 //sleep(2);
 
 NSImage *imageData =[[NSImage alloc] initWithData:newData];
 NSData * representation = [imageData TIFFRepresentation];
 NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];   
 [pasteBoard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
 [pasteBoard setData:representation forType:NSTIFFPboardType];
 
 [imageData release];
 [img release];
 [rep release];
 }
 
 }
 */
- (BOOL) acceptsFirstResponder {
    return YES;
}




-(IBAction) setTouchActive:(id)sender
{
    [TouchUnActive setHidden:YES];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSLog(@"rightMouseDown");
}
- (void)beginGestureWithEvent:(NSEvent *)event
{
    
    
    
    NSLog(@"beginGestureWithEvent");
}


-(void)resetPositionsAndRangesForPoint_Org:(NSPoint)pos
{
    if(WinX1 > pos.x)
        WinX1 = pos.x;
    else if(WinX2 < pos.x)
        WinX2 = pos.x;
    
    if(WinY1 > pos.y)
        WinY1 = pos.y;
    else if(WinY2 < pos.y)
        WinY2 = pos.y;
}

-(void)resetPositionsAndRangesForPoint:(NSPoint)pos
{
    CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"burshThick"] floatValue];
    
    if(WinX1 > pos.x - thick)
        WinX1 = pos.x - thick;
    else if(WinX2 < pos.x + thick)
        WinX2 = pos.x + thick;
    
    if(WinY1 > pos.y - thick)
        WinY1 = pos.y - thick;
    else if(WinY2 < pos.y + thick)
        WinY2 = pos.y + thick;
}



-(void)preTouchBegin
{
    [canvas setSaveUndo];
    
    
    TouchOver = YES;
    //[self setEraserAndPenStatus];
    /*
     NSImage *image = [[NSImage imageNamed:@"blank.png"] copy];
     //NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
     NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,16)]  ;
     [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
     [cursor release];
     [image release];
     */
    [NSCursor setHiddenUntilMouseMoves:YES];
    [self resetCursorRects];
    
    [mPointer setHidden:NO];
    NSString *strImg = [pen state] == YES ? @"mac.png" : @"rectangle2.png";
    NSImage *img = [[NSImage imageNamed:strImg] copy];
    [mPointer setImage:img];
    [img release];
    
    /*
    CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"LineSlider"] floatValue];
    if(thick < 2)
        thick = 2;
    NSRect rectFrame = [mPointer frame];
    NSRect existingFrame = NSMakeRect(rectFrame.origin.x, rectFrame.origin.y, rectFrame.size.width, rectFrame.size.height);
    CGFloat ratio = [pen state] == YES ? 2.5f : 4.5f;
    rectFrame.size = NSMakeSize((thick * ratio), (thick * ratio ));
    rectFrame.origin.x = existingFrame.origin.x - (rectFrame.size.width - existingFrame.size.width)/2;
    rectFrame.origin.y = existingFrame.origin.y - (rectFrame.size.height - existingFrame.size.height)/2;
    [mPointer setFrame:rectFrame];
     */
    
    [mPointerLine setHidden:NO];
    [mPointerLine setNeedsDisplay:YES];
    [mToolBG setHidden:NO];
    
    //CGAssociateMouseAndMouseCursorPosition(false);   
    
}



- (void)touchesBeganWithEvent:(NSEvent *)pTheEvent;
{
    
    // CGAssociateMouseAndMouseCursorPosition(false);
    
    if(phaseBegan == YES)
        return;
    
    phaseBegan = YES;
    
    //[self preTouchBegin];
    
    CGAssociateMouseAndMouseCursorPosition(false);
    
    
    NSPoint pos = {0, 0};
    NSSet * touches= [pTheEvent touchesMatchingPhase:NSTouchPhaseBegan inView:self]  ;
    
    //  NSLog(@"%@",[touches description]);
    //   NSLog(@"%d",touches.count);
    
    
    if(touches.count == 1)
    {
        for(NSTouch *touch in touches)
        {
            NSPoint fraction = touch.normalizedPosition;
            NSSize whole = touch.deviceSize;
            // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
            // NSLog(@" touched size : %g %g", whole.width, whole.height);
            NSPoint wholeInches ={whole.width, whole.height};
            //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
            pos = wholeInches;
            pos.x *= fraction.x;
            pos.y *= fraction.y;
            
            
            //NSLog(@"touched moved %g %g %g %g", WinX1, WinX2, WinY1, WinY2);
        }
        
        [self preTouchBegin];
        
        
        [brush mouseDown:pTheEvent inView:self onCanvas:canvas cPoint:pos bFlag:YES];
        //NSLog(@" touched began......%g %g", pos.x, pos.y);
        
        //return;
        
        [self resetPositionsAndRangesForPoint:pos];
        
        pos.x -=16;
        pos.y += 32; 
        [mPointer setFrameOrigin:pos];
        // NSLog(@"touch began ");
    }
    else
    {
        //NSLog(@"touch began >1 ");
        CGAssociateMouseAndMouseCursorPosition(true);
        [NSCursor setHiddenUntilMouseMoves:NO];
        [TouchUnActive setHidden:NO];
        //[self onClear:nil];	       
    }
    [self setNeedsDisplay:YES];
}

-(void)touchesMovedWithEvent:(NSEvent *)event
{
    //   [[self window] setAcceptsMouseMovedEvents: NO];
    
    if(phaseBegan == NO)
        return;
    
    NSPoint pos = {0, 0};
    
    NSSet * touches= [event touchesMatchingPhase:NSTouchPhaseTouching inView:self]  ;
    if(touches.count == 1)
    {
        // NSLog(@"%@",[touches description]);
        for(NSTouch *touch in touches)
        {
            NSPoint fraction = touch.normalizedPosition;
            // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
            NSSize whole =touch.deviceSize;
            // NSLog(@" touched size : %g %g", whole.width, whole.height);
            
            NSPoint wholeInches ={whole.width, whole.height};
            //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
            pos = wholeInches;
            pos.x *= fraction.x;
            pos.y *= fraction.y;
            
            
            
            //  NSLog(@"touched moved %g %g %g %g", WinX1, WinX2, WinY1, WinY2);
            //  NSLog(@" touched moved......%g %g", pos.x, pos.y);
        }
        
        
        
        
        [brush mouseDragged:event inView:self onCanvas:canvas cPoint:pos bFlag:YES];
        // [self setNeedsDisplay:YES]; 
        
        //return;
        [self resetPositionsAndRangesForPoint:pos];
        
        // NSLog(@" touched moved......%g %g", pos.x, pos.y);
        pos.x -=16;
        pos.y += 30; 
        if([erase state] == YES)
        {
            pos.x +=16;
            pos.y += 15;
        }
        
         [mPointer setFrameOrigin:pos];
    }
    else
    {
        CGAssociateMouseAndMouseCursorPosition(true);
        [TouchUnActive setHidden:NO];
        //[self onClear:nil];
        //   NSLog(@"touch Move >1 ");
        return;
    }
}

-(IBAction) cursorHide:(id)sender
{
    /*
    NSImage *image = [[NSImage imageNamed:@"mac.png"] copy];
    //NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
    NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,16)]  ;
    [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
    [cursor release];
    [image release];
     */
    
    [self resetCursorRects];
}

-(void)resetCursorRects_Org{
    
    //[super resetCursorRects];
    NSImage *image = [[NSImage imageNamed:@"mac.png"] copy];
    //NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
    NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,16)]  ;
    [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
    [cursor release];
    [image release];
}

-(void)resetCursorRects
{
    [super resetCursorRects];
    NSImage *image ;
    
    
    [self discardCursorRects];
    
    if(TouchOver)
    {
        NSImage *image = [[NSImage imageNamed:@"blank.png"] copy];
        //NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
        NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,16)]  ;
        [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
        [cursor release];
        [image release];
        
        return;
    }
    if([erase state] == YES){
        //image = [[NSImage imageNamed:@"mac.png"] copy];
        //cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
        NSCursor *cursor;
        image = [NSImage imageNamed:@"rectangle.png"];
        [image setScalesWhenResized: YES];
        CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"LineSlider"] floatValue];
        if(thick < 2)
            thick = 2;
        [image setSize: NSMakeSize ((thick * 4.5), (thick * 4.5 ))];
        //cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(thick*1.2,-thick*4.0)]  ;
        cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(thick*1.2,thick*4.1)]  ;
        
        [self addCursorRect:[self bounds] cursor:cursor];
        [cursor release];
    }
    else if([pen state] == YES )
    {
        //image = [[NSImage imageNamed:@"mac.png"] copy];
        //cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
        NSCursor *cursor;
        image = [NSImage imageNamed:@"mac.png"];
        [image setScalesWhenResized: YES];
        CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"LineSlider"] floatValue];
        if(thick < 2)
            thick = 2;
        [image setSize: NSMakeSize ((thick * 4.5), (thick * 4.5 ))];
        //cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(thick*1.2,-thick*4.0)]  ;
        cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(thick*2.1,thick*2.3)]  ;
        
        [self addCursorRect:[self bounds] cursor:cursor];
        [cursor release];
    }
}



-(void)touchesCancelledWithEvent:(NSEvent *)pTheEvent
{
    // [self cancelTracking];
}

-(void)touchesEndedWithEvent:(NSEvent *)event
{
    phaseBegan = NO;
    CGAssociateMouseAndMouseCursorPosition(true);
    [mPointer setHidden:YES];
    
    NSPoint pos = {0, 0};
    
    NSSet * touches= [event touchesMatchingPhase:NSTouchPhaseEnded inView:self]  ;
    if(touches.count == 1)
    {
        // NSLog(@"%@",[touches description]);
        for(NSTouch *touch in touches)
        {
            NSPoint fraction = touch.normalizedPosition;
            // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
            NSSize whole =touch.deviceSize;
            // NSLog(@" touched size : %g %g", whole.width, whole.height);
            
            NSPoint wholeInches ={whole.width, whole.height};
            //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
            pos = wholeInches;
            pos.x *= fraction.x;
            pos.y *= fraction.y;
            
        }
        
        
        
        
        [brush mouseUp:event inView:self onCanvas:canvas cPoint:pos bFlag:YES];
        // [self setNeedsDisplay:YES]; 
        
        //return;
        [self resetPositionsAndRangesForPoint:pos];
        
        // NSLog(@" touched moved......%g %g", pos.x, pos.y);
        pos.x -=16;
        pos.y += 30;   
        
        // [mPointer setFrameOrigin:pos];
    }
    else
    {
        CGAssociateMouseAndMouseCursorPosition(true);
        [TouchUnActive setHidden:NO];
        return;
    }
    
    return;
    /*
     // 
     
     
     // [canvas setDoUndo];
     // Undo1 = 
     return;
     
     //[self setEraserAndPenStatus];
     [mPointer setHidden:YES];
     
     [mToolBG setHidden:YES];
     //return;
     NSPoint pos;
     NSSet * touches= [event touchesMatchingPhase:NSTouchPhaseEnded  inView:self]  ;
     if(touches.count == 1)
     {
     
     //CGAssociateMouseAndMouseCursorPosition(false);
     //return;
     
     NSLog(@"%@",[touches description]);
     for(NSTouch *touch in touches)
     {
     NSPoint fraction = touch.normalizedPosition;
     // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
     NSSize whole =touch.deviceSize;
     // NSLog(@" touched size : %g %g", whole.width, whole.height);
     
     NSPoint wholeInches ={whole.width, whole.height};
     //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
     pos = wholeInches;
     pos.x *= fraction.x;
     pos.y *= fraction.y;
     
     
     }
     
     [brush mouseUp:event inView:self onCanvas:canvas cPoint:pos bFlag:YES];	
     // [self setNeedsDisplay:YES];
     
     if(WinX1 > pos.x)
     WinX1 = pos.x;
     else if(WinX2 < pos.x)
     WinX2 = pos.x;
     
     if(WinY1 > pos.y)
     WinY1 = pos.y;
     else if(WinY2 < pos.y)
     WinY2 = pos.y;
     
     
     
     pos.x -=16;
     pos.y += 32;     
     [mPointer setFrameOrigin:pos];
     
     CGAssociateMouseAndMouseCursorPosition(true);
     }
     else
     {
     CGAssociateMouseAndMouseCursorPosition(true);
     [TouchUnActive setHidden:NO];
     //[self onClear:nil];
     return;
     }
     */
}


- (void)mouseDown:(NSEvent *)theEvent
{
    /*
     if(imgArrForUndo == nil)
     {
     imgArrForUndo = [[NSMutableArray alloc] init];
     }
     
     NSImage* img= [self captureImage];
     [imgArrForUndo addObject:img];
     */
    
    [canvas setSaveUndo];
    
    // [self setEraserAndPenStatus];
    
    
	// Simply pass the mouse event to the brush. Also give it the canvas to
	//	work on, and a reference to ourselves, so it can translate the mouse
	//	locations.
    
    if(!TouchOver)
    {
        /*
        NSImage *image = [[NSImage imageNamed:@"mac.png"] copy];
        //NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
        NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,16)]  ;
        [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
        [cursor release];
        [image release];
         */
        [self resetCursorRects];
        [mPointer setHidden:YES];
        [mPointerLine setHidden:YES];
        [mToolBG setHidden:YES];
        [brush mouseDown:theEvent inView:self onCanvas:canvas cPoint:NSMakePoint(-1, -1) bFlag:NO];
        
        
        NSPoint eventLocation = [theEvent locationInWindow];
        NSPoint pos = [self convertPoint:eventLocation fromView:nil];
        
        
        [self resetPositionsAndRangesForPoint:pos];
        
        // NSLog(@"touched moved %g %g %g %g", WinX1, WinX2, WinY1, WinY2);
    }
    
    //  [self drawRect:[self bounds]];
}


- (void)mouseMoved: (NSEvent *)theEvent {
    
    TouchOver = NO;
    if([mouseMove state] == YES){
        [brush setForeGroundColor:nil]; 
        if(!bflag)
        {
            [self mouseDown:theEvent];
            bflag =true;
        }
        //[self mouseDragged: theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    TouchOver = NO;
	// Simply pass the mouse event to the brush. Also give it the canvas to
	//	work on, and a reference to ourselves, so it can translate the mouse
	//	locations.	
    
    // [self setEraserAndPenStatus];
    [brush mouseDragged:theEvent inView:self onCanvas:canvas cPoint:NSMakePoint(-1, -1) bFlag:NO];
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint pos = [self convertPoint:eventLocation fromView:nil];
    if(pos.x < 0)
        pos.x = 0;
    if(pos.x > [self frame].size.width)
        pos.x = [self frame].size.width;
    if(pos.y < 0)
        pos.y = 0;
    if(pos.y > [self frame].size.height)
        pos.y = [self frame].size.height;
    
    
    [self resetPositionsAndRangesForPoint:pos];
    
    //NSLog(@"touched moved %g %g %g %g", WinX1, WinX2, WinY1, WinY2);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CGEventRef ourEvent = CGEventCreate(NULL);
    LastPoint = CGEventGetLocation(ourEvent);
    
    // [self setEraserAndPenStatus];
	// Simply pass the mouse event to the brush. Also give it the canvas to
	//	work on, and a reference to ourselves, so it can translate the mouse
	//	locations.	
	//[brush mouseUp:theEvent inView:self onCanvas:canvas  cPoint: NSMakePoint(-1, -1) bFlag:NO];
    CFRelease(ourEvent);
}
//Paint End


/*
 tell application "System Preferences"
 activate
 set current pane to pane "com.apple.preference.trackpad"
 end tell
 delay 1
 tell application "System Events"
 tell process "System Preferences"
 tell window "Trackpad"
 if value of checkbox "Ignore accidental trackpad input" of group 1 is 1 then
 click checkbox "Ignore accidental trackpad input" of group 1
 end if
 if value of checkbox "Ignore trackpad when mouse is present" of group 1 is 1 then
 click checkbox "Ignore trackpad when mouse is present" of group 1
 end if
 click checkbox "Ignore accidental trackpad input" of group 1
 click checkbox "Ignore trackpad when mouse is present" of group 1
 end tell
 end tell
 end tell
 tell application "System Preferences"
 quit
 end tell
 */

// Attempt animate close
NSRect frameOrg;

-(IBAction)onPostCloseSign
{
    [[NSApplication sharedApplication] hide:nil];
    [self resetMouse];
    [mWindow orderOut:nil];
    [mWindow setFrame:frameOrg display:NO];
}

-(IBAction) CloseSignIt_New:(id)sender
{
    frameOrg = [mWindow frame];
    NSArray *arr = [NSApp windows];
    NSRect rect = [[arr lastObject] frame];
    [[mWindow animator] setFrame:rect display:YES];
    [self performSelector:@selector(onPostCloseSign) withObject:nil afterDelay:1.0f];
}
// End Attempt animate close


-(IBAction) onToolBar:(id)sender{
    [self setAcceptsTouchEvents:normal];    
}
-(IBAction) CloseSignIt:(id)sender
{
    [[NSApplication sharedApplication] hide:nil];
    [self resetMouse];
    //[mWindow setFrame:NSMakeRect([mWindow frame].origin.x, [mWindow frame].origin.y, 0, 0) display:YES animate:YES];
    
    // [mWindow close];
    
    [mWindow orderOut:nil];
    //[mWindow setFrame:NSMakeRect([mWindow frame].origin.x, [mWindow frame].origin.y, 600, 400) display:YES];
}
-(IBAction) OpenSignIt:(id)sender
{
    //[canvas setBackupBeforeResize];
    
    if([sender tag] == 1)
    {
        [AdvBtn setHidden:NO];
        [AdvTool setHidden:NO];
        [BscBtn setHidden:YES];
        [BscTool setHidden:YES];
        
        [mBG setImage:[NSImage imageNamed:@"BG.png"]];
        NSRect winFrame = [mWindow frame];
        winFrame.size.width = 600;
        
        [mWindow setFrame:winFrame display:YES animate:YES];
        [mWindow makeKeyAndOrderFront:self];
        
        [[self window] makeFirstResponder: self];
        [[self window] setAcceptsMouseMovedEvents: YES];
        
        [TouchUnActive setHidden:YES];
        [mWindow orderFront:self];
        NSAppleScript *start = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"activate application \"Signature\" "]]; 
        [start executeAndReturnError:nil];
        [start release];
    }
    else
    {
        [AdvBtn setHidden:YES];
        [AdvTool setHidden:YES];
        
        [BscBtn setHidden:NO];
        [BscTool setHidden:NO];
        
        [mBG setImage:[NSImage imageNamed:@"BGMini.png"]];
        
        NSRect winFrame = [mWindow frame];
        winFrame.size.width = 370;
        
        [mWindow setFrame:winFrame display:YES animate:YES];
        [mWindow makeKeyAndOrderFront:self];
        
        [[self window] makeFirstResponder: self];
        [[self window] setAcceptsMouseMovedEvents: YES];
        
        [TouchUnActive setHidden:YES];
        [mWindow orderFront:self];
        NSAppleScript *start = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"activate application \"Signature\" "]]; 
        
        [start executeAndReturnError:nil];
        [start release];
    }
    
    [self setMouseCenter];
    
    
    [self setAcceptsTouchEvents:YES];
    // [self setWantsRestingTouches:YES];
    
    [mStatusHelp orderOut:nil];
    phaseBegan = NO;
    [mBGImg setHidden:NO];
    
    //[canvas drawRectAfterResize];
    
}
- (void)setMouseCenter {
    /** SetMousePlace*/
    
    CGEventRef ourEvent = CGEventCreate(NULL);
    LastPoint = CGEventGetLocation(ourEvent);
    NSLog(@"Location? x= %f, y = %f", (float)LastPoint.x, (float)LastPoint.y);
    
    [mPointer setHidden:YES];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CGPoint pt;
    pt.x = mWindow.frame.origin.x+200;
    pt.y = mWindow.frame.origin.y-220;
    CGPostMouseEvent( pt, 1, 1, 0 );
    CGPostMouseEvent( pt, 1, 1, 0 );
    [pool release];
    /** SetMousePlace End*/
    
    [NSCursor setHiddenUntilMouseMoves:YES];
    //[NSCursor hide];
    CFRelease(ourEvent);
}

- (void)resetMouse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CGPoint pt;
    pt.x = (float)LastPoint.x;
    pt.y = (float)LastPoint.y;
    CGPostMouseEvent( pt, 1, 1, 0 );
    CGPostMouseEvent( pt, 1, 1, 0 );
    [pool release];
}

- (void)magnifyWithEvent:(NSEvent *)event {
    NSLog(@"Magnification value is %f", [event magnification]);
}

- (void)rotateWithEvent:(NSEvent *)event {
    NSLog(@"Rotation in degree is %f", [event rotation]);
}


-(void)openAdvancedPaintwithSize:(CGSize)size
{
    [canvas clearUndoRedoData];
    
    [AdvBtn setHidden:NO];
    [AdvTool setHidden:NO];
    [BscBtn setHidden:YES];
    [BscTool setHidden:YES];
    
    [mBG setImage:[NSImage imageNamed:@"BG.png"]];
    NSRect winFrame = [mWindow frame];
    //winFrame.size.width = size.width - 22;
    //winFrame.size.height = size.height + 22;
    
    //[mWindow setFrame:winFrame display:YES animate:YES];
    //[mWindow makeKeyAndOrderFront:self];
    
    [mWindow setFrame:winFrame display:NO animate:NO];
    
    [[self window] makeFirstResponder: self];
    [[self window] setAcceptsMouseMovedEvents: YES];
    
    [TouchUnActive setHidden:YES];
    /*
    [mWindow orderFront:self];
    NSAppleScript *start = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"activate application \"ToolbarSample\" "]]; 
    [start executeAndReturnError:nil];
    [start release];
     */
    
    
    [self setMouseCenter];
    
    
    [self setAcceptsTouchEvents:YES];
    [self setWantsRestingTouches:YES];
    
    [canvas  initWithSize:[self frame].size];

    phaseBegan = NO;
    [mBGImg setHidden:NO];
    
    [pen setState:1];
    [self resetCursorRects];
}


- (void)awakeFromNib
{
    
    [[self window] makeFirstResponder: self];
    [[self window] setAcceptsMouseMovedEvents: YES];
    if ([[self window] acceptsMouseMovedEvents]) {NSLog(@"window now acceptsMouseMovedEvents");}
    
    
    [TouchUnActive setHidden:YES];
    [AdvBtn setHidden:YES];
    [AdvTool setHidden:YES];
    
    [BscBtn setHidden:NO];
    [BscTool setHidden:NO];
    
    [mBG setImage:[NSImage imageNamed:@"BGMini.png"]];
    NSRect winFrame = [mWindow frame];
    winFrame.size.width = 600;
    //winFrame.size.height = 370;
    [mWindow setFrame:winFrame display:YES];
    
    
    phaseBegan = NO;
    phaseEnded = YES;
    
    WinX2 = 1;
    WinX1 = 600;
    
    WinY2 = 1;
    WinY1 = 320;
    
    
    bflag = false;
    [canvas  initWithSize:[self frame].size];
    
    
    [mWindow center];
    
        
    [self setAcceptsTouchEvents:YES];
    //[self setWantsRestingTouches:YES];
    
    
    isClear = YES;
    isTrans = 0;
    //mWindow.backgroundColor = [NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:0.0];
    //mWindow.backgroundColor = [NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:0.0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //last version = 4
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"DBVersion"] intValue] != 4)
	{
		//[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
		
        [defaults setObject:@"0.0:0.0:0.0:1.0" forKey:@"LineColor"];  
        // [defaults setObject:@"0.0,0.0,0.0,1.0" forKey:@"drawColor"];  
        
        [defaults setObject:@"255.0:255.0:255.0:1.0" forKey:@"BGColor"];
        [defaults setObject:@"1" forKey:@"LineSlider"];
        [defaults setObject:@"2" forKey:@"ExportSlider"];
        
        [defaults setObject:@"0" forKey:@"isErased"];
        [defaults setObject:@"0" forKey:@"HideWhenDone"];
        [defaults setObject:@"1" forKey:@"ExpTranparent"];
        [defaults setObject:@"4" forKey:@"DBVersion"];
        [defaults synchronize];
        
        [mStatusHelp makeKeyAndOrderFront:nil];
	}
    
    // NSLog(@"LineSlider =   %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"LineSlider"]);
    
    
    // NSString *AKey = [NSString stringWithFormat:@"Sign it            %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"Key"]];
    
    // [myMenuStatus1 setTitle:AKey];
    [thickness setFloatValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"LineSlider"] floatValue]];
    
    [ExportSlider setFloatValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"ExportSlider"] floatValue]];
    
    [BtnHideWhenDone setState:[[[NSUserDefaults standardUserDefaults] stringForKey:@"HideWhenDone"] intValue]];
    
    [BtnExpTranparent setState:[[[NSUserDefaults standardUserDefaults] stringForKey:@"ExpTranparent"] intValue]];
    
    // [self composeInterface];
    
    [brush LoadBrush:nil];
    
    //[self OpenSignIt:nil];
}

-(IBAction) setHideWhenDone:(id)sender
{
    NSInteger myInteger = [sender state];   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", myInteger] forKey:@"HideWhenDone"];
    [defaults synchronize];    
}
-(IBAction) setExpTranparent:(id)sender
{
    NSInteger myInteger = [sender state];   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", myInteger] forKey:@"ExpTranparent"];
    [defaults synchronize];    
}

-(IBAction)setExpSlider:(id)sender
{
    NSInteger myInteger = [sender floatValue];   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d", myInteger] forKey:@"ExportSlider"];
    [defaults synchronize];
    
    NSLog(@"Line - %d", [[[NSUserDefaults standardUserDefaults] stringForKey:@"ExportSlider"] intValue]);
}
- (IBAction)setLine:(id)sender{
    [TouchUnActive setHidden:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //CGFloat alpha = [sender floatValue];
    [defaults setObject:[NSString stringWithFormat:@"%f", [sender floatValue]] forKey:@"LineSlider"];
    [defaults synchronize];
    [self setNeedsDisplay:YES];
    
    [brush setBurshThickness:sender]; 
    
    [self resetCursorRects];
}
/*
 - (void)windowDidResize: (NSNotification *)aNotification
 {
 [self composeInterface];
 // [mWindow setFrame:NSMakeRect([mWindowBtn frame].origin.x, [mWindowBtn frame].origin.y, 500, 300) display:YES];
 }
 */
- (void)windowDidMove: (NSNotification *)aNotification
{
    // [self composeInterface];
    /*
     if(isMini == YES)
     [mWindow setFrameOrigin:NSMakePoint([mWindowBtn frame].origin.x+150, [mWindowBtn frame].origin.y+150)];
     else
     [mWindowBtn setFrameOrigin:NSMakePoint([mWindow frame].origin.x, [mWindow frame].origin.y)];
     */
}

- (void)composeInterface
{
    // compose our UI out of views
    NSView *themeFrame = [[mWindow contentView] superview];
    NSRect c = [themeFrame frame];  // c for "container"
    NSRect aV = [accessoryView frame];      // aV for "accessory view"
    NSRect newFrame = NSMakeRect(
                                 c.size.width - aV.size.width,   // x position
                                 c.size.height - aV.size.height, // y position
                                 aV.size.width,  // width
                                 aV.size.height);        // height
    [accessoryView setFrame:newFrame];
    [themeFrame addSubview:accessoryView];
}


/*
 -(void)resetCursorRects{
 
 [super resetCursorRects];
 //NSCursor *cursor =[self ringCursorWithDiameter:10 ];
 NSImage *image = [NSImage imageNamed:@"mac.png"];
 NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16,-16)]  ;
 // NSCursor *cursor =[self customArrowCursor ];
 [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
 }
 
 -(void)touchesBeganWithEvent:(NSEvent *)pTheEvent
 {
 
 CGAssociateMouseAndMouseCursorPosition(false);
 
 
 NSPoint pos;
 NSSet * touches= [pTheEvent touchesMatchingPhase:NSTouchPhaseBegan inView:self]  ;
 
 if(touches.count >1)
 {
 [myMutaryOfBrushStrokes removeAllObjects];
 [myMutaryOfPoints removeAllObjects];
 [self setNeedsDisplay:YES];	       
 return;
 }
 for(NSTouch *touch in touches)
 {
 NSPoint fraction = touch.normalizedPosition;
 NSSize whole =touch.deviceSize;
 // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
 NSLog(@" touched size : %g %g", whole.width, whole.height);
 NSPoint wholeInches ={whole.width, whole.height};
 //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
 pos =wholeInches;
 pos.x *= fraction.x;
 pos.y *= fraction.y;
 NSLog(@"begin moved %g %g", pos.x, pos.y);
 }
 
 
 
 myMutaryOfPoints	= [[NSMutableArray alloc]init];
 [myMutaryOfBrushStrokes addObject:myMutaryOfPoints];
 
 //NSPoint tvarMousePointInWindow	= [pTheEvent locationInWindow];
 //NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:pos];
 
 
 // NSImage *image = [NSImage imageNamed:@"mac.png"];
 // NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot: NSMakePoint(16, -16)]  ;
 // [self addCursorRect:[self bounds] cursor:cursor];//[NSCursor crosshairCursor]
 
 [myMutaryOfPoints addObject:tvarMyPointObj];
 
 //  CGSetLocalEventsSuppressionInterval(0);
 // pos.x += [mWindow frame].origin.x;
 // pos.y += [mWindow frame].origin.y;
 // CGWarpMouseCursorPosition(pos);
 
 
 pos.x -=16;
 pos.y += 32;   
 
 [mPointer setFrameOrigin:pos];
 }
 
 -(void)touchesMovedWithEvent:(NSEvent *)pTheEvent
 {
 
 [[self window] setAcceptsMouseMovedEvents: NO];
 
 
 //  [brush mouseDragged:event inView:self onCanvas:canvas];
 
 NSPoint pos;
 NSSet * touches= [pTheEvent touchesMatchingPhase:NSTouchPhaseTouching inView:self]  ;
 if(touches.count >1)
 {
 [myMutaryOfBrushStrokes removeAllObjects];
 [myMutaryOfPoints removeAllObjects];
 [self setNeedsDisplay:YES];	        
 return;
 }
 for(NSTouch *touch in touches)
 {
 NSPoint fraction = touch.normalizedPosition;
 // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
 NSSize whole =touch.deviceSize;
 // NSLog(@" touched size : %g %g", whole.width, whole.height);
 
 NSPoint wholeInches ={whole.width, whole.height};
 //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
 pos = wholeInches;
 pos.x *= fraction.x;
 pos.y *= fraction.y;
 NSLog(@" touched moved......%g %g", pos.x, pos.y);
 }
 
 
 // NSPoint tvarMousePointInWindow	= [pTheEvent locationInWindow];
 //NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:pos];
 
 [myMutaryOfPoints addObject:tvarMyPointObj];	
 
 [self setNeedsDisplay:YES]; 
 
 //CGSetLocalEventsSuppressionInterval(0);
 
 NSLog(@" touched moved......%g %g", pos.x, pos.y);
 pos.x -=16;
 pos.y += 32;   
 
 
 [mPointer setFrameOrigin:pos];
 }
 
 -(void)touchesCancelledWithEvent:(NSEvent *)pTheEvent
 {
 
 [self cancelTracking]; 
 }
 
 -(void)touchesEndedWithEvent:(NSEvent *)pTheEvent
 {
 CGAssociateMouseAndMouseCursorPosition(true);
 
 //return;
 NSPoint pos;
 NSSet * touches= [pTheEvent touchesMatchingPhase:NSTouchPhaseEnded  inView:self]  ;
 if(touches.count >1)
 {
 [myMutaryOfBrushStrokes removeAllObjects];
 [myMutaryOfPoints removeAllObjects];
 [self setNeedsDisplay:YES];	
 return;
 }
 for(NSTouch *touch in touches)
 {
 NSPoint fraction = touch.normalizedPosition;
 // NSLog(@" Normalize size : %g %g", fraction.x, fraction.y);
 NSSize whole =touch.deviceSize;
 // NSLog(@" touched size : %g %g", whole.width, whole.height);
 
 NSPoint wholeInches ={whole.width, whole.height};
 //NSPoint wholeInches ={whole.width /72.0, whole.height /72.0};
 pos = wholeInches;
 pos.x *= fraction.x;
 pos.y *= fraction.y;
 NSLog(@"end......%g %g", pos.x, pos.y);
 }
 
 
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:pos];
 
 [myMutaryOfPoints addObject:tvarMyPointObj];	
 
 [self setNeedsDisplay:YES];
 
 
 // CGSetLocalEventsSuppressionInterval(0);
 // pos.x += [mWindow frame].origin.x;
 // pos.y += [mWindow frame].origin.y;
 // CGWarpMouseCursorPosition(pos);
 pos.x -=16;
 pos.y += 32;   
 
 [mPointer setFrameOrigin:pos];
 }
 */

-(IBAction) setTheme:(id)sender
{
    [TouchUnActive setHidden:YES];
    /*
     switch ([sender tag]) {
     case 0:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 1:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 250.0  green:170.0 blue:23.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 2:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 207.0  green:74.0 blue:34.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 3:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 126.0  green:189.0 blue:61.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 4:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 1.0  green:144.0 blue:182.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 5:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 25.0  green:114.0 blue:192.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 6:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 18.0  green:148.0 blue:19.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 7:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 233.0  green:149.0 blue:3.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 8:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 207.0  green:82.0 blue:122.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 9:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 254.0  green:26.0 blue:0.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 10:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 139.0  green:2.0 blue:33.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     case 11:
     [drawColorWell setColor:[NSColor colorWithCalibratedRed: 25.0  green:78.0 blue:110.0 alpha:1.0]];
     [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
     break;
     }
     */
    NSArray *arrSetting;
    
    switch ([sender tag]) {
        case 0:
            
            //   NSLog(@"%f:%f:%f:%f", red,green,blue,alpha);
            
            
            arrSetting = [[[NSUserDefaults standardUserDefaults] stringForKey:@"LineColor"] componentsSeparatedByString:@":"];
            
            //   NSMutableArray *arrGroupColorSets = [[NSMutableArray alloc] init];
            
            CGFloat red = [[arrSetting objectAtIndex:0] floatValue];
            CGFloat green = [[arrSetting objectAtIndex:1] floatValue];
            CGFloat blue = [[arrSetting objectAtIndex:2] floatValue];
            CGFloat alpha = [[arrSetting objectAtIndex:3] floatValue];
            [drawColorWell setColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
            
            arrSetting = [[[NSUserDefaults standardUserDefaults] stringForKey:@"BGColor"] componentsSeparatedByString:@":"];
            
            //arrGroupColorSets = [[NSMutableArray alloc] init];
            
            red = [[arrSetting objectAtIndex:0] floatValue];
            green = [[arrSetting objectAtIndex:1] floatValue];
            blue = [[arrSetting objectAtIndex:2] floatValue];
            alpha = [[arrSetting objectAtIndex:3] floatValue];
            
			
            [drawColorBG setColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
            
			break;
		case 1:
			[drawColorWell setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
		case 2:
			[drawColorWell setColor:[NSColor blueColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 3:
			[drawColorWell setColor:[NSColor brownColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 4:
			[drawColorWell setColor:[NSColor cyanColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
			break;
        case 5:
			[drawColorWell setColor:[NSColor greenColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
			break;
        case 6:
			[drawColorWell setColor:[NSColor magentaColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 7:
			[drawColorWell setColor:[NSColor orangeColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 8:
			[drawColorWell setColor:[NSColor purpleColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 9:
			[drawColorWell setColor:[NSColor redColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
        case 10:
			[drawColorWell setColor:[NSColor yellowColor]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
			break;
        case 11:
            [drawColorWell setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			[drawColorBG setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
			break;
        case 12:
			//[drawColorWell setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:0.5]];
            [drawColorWell setColor:[NSColor colorWithCalibratedRed: 0.4  green:0.4 blue:0.4 alpha:1.0]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
			break;
        default:
			[drawColorWell setColor:[NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:1.0]];
            [drawColorBG setColor:[NSColor colorWithCalibratedRed: 255.0  green:255.0 blue:255.0 alpha:1.0]];
			break;
	}
    
    NSColor  *color = [drawColorWell color];
    CGFloat red = [color redComponent];
    CGFloat green = [color greenComponent];
    CGFloat blue = [color blueComponent];
    CGFloat alpha = [color alphaComponent];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f:%f:%f:%f", red, green, blue, alpha] forKey:@"LineColor"];
    
    NSColor  *color1 = [drawColorBG color];
    CGFloat red1 = 0.0;
    CGFloat green1 = 0.0;
    CGFloat blue1 = 0.0;
    CGFloat alpha1 = 1.0;
    
    red1 = [color1 redComponent];
    green1 = [color1 greenComponent];
    blue1 = [color1 blueComponent];
    alpha1 = [color1 alphaComponent];
    
    [defaults setObject:[NSString stringWithFormat:@"%f:%f:%f:%f", red1, green1, blue1, alpha1] forKey:@"BGColor"];
    [defaults synchronize];
    
    
    [TxtBG setTextColor:[drawColorWell color]];
    [TxtColor setTextColor:[drawColorWell color]];
    TextBG.backgroundColor = [drawColorBG color];
    
    [TextBG setBackgroundColor:[drawColorBG color]];
    
    [brush setForeGroundColor:nil]; 
    [canvas setBackgroundcolor];
    [self setNeedsDisplay:YES];
    
    
    //  [Brush setForeGroundColor:nil];
}

-(IBAction) setData:(id)sender {
    
    [TxtBG setTextColor:[drawColorWell color]];
    [TxtColor setTextColor:[drawColorWell color]];
    TextBG.backgroundColor = [drawColorBG color];
    
    NSColor  *color = [drawColorWell color];
    CGFloat red = [color redComponent];
    CGFloat green = [color greenComponent];
    CGFloat blue = [color blueComponent];
    CGFloat alpha = [color alphaComponent];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f:%f:%f:%f", red, green, blue, alpha] forKey:@"LineColor"];
    
    NSColor  *color1 = [drawColorBG color];
    CGFloat red1 = 0.0;
    CGFloat green1 = 0.0;
    CGFloat blue1 = 0.0;
    CGFloat alpha1 = 1.0;
    
    red1 = [color1 redComponent];
    green1 = [color1 greenComponent];
    blue1 = [color1 blueComponent];
    alpha1 = [color1 alphaComponent];
    
    [defaults setObject:[NSString stringWithFormat:@"%f:%f:%f:%f", red1, green1, blue1, alpha1] forKey:@"BGColor"];
    [defaults synchronize];
    
    [self setNeedsDisplay:YES]; 
}
/*
 -(void)mouseDown:(NSEvent *)pTheEvent {
 
 myMutaryOfPoints	= [[NSMutableArray alloc]init];
 [myMutaryOfBrushStrokes addObject:myMutaryOfPoints];
 
 NSPoint tvarMousePointInWindow	= [pTheEvent locationInWindow];
 NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
 
 [myMutaryOfPoints addObject:tvarMyPointObj];		
 
 } 
 // end mouseDown
 
 -(void)mouseDragged:(NSEvent *)pTheEvent {
 
 NSPoint tvarMousePointInWindow	= [pTheEvent locationInWindow];
 NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
 
 [myMutaryOfPoints addObject:tvarMyPointObj];	
 
 [self setNeedsDisplay:YES]; 
 
 } // end mouseDragged
 
 -(void)mouseUp:(NSEvent *)pTheEvent {
 
 NSPoint tvarMousePointInWindow	= [pTheEvent locationInWindow];
 NSPoint tvarMousePointInView	= [self convertPoint:tvarMousePointInWindow fromView:nil];
 MyPoint * tvarMyPointObj		= [[MyPoint alloc]initWithNSPoint:tvarMousePointInView];
 
 [myMutaryOfPoints addObject:tvarMyPointObj];	
 
 [self setNeedsDisplay:YES];
 
 } // end mouseUp
 */

- (CGFloat)randVar;
{
	return  0.5;//( (float)(rand() % 10000 ) / 10000.0);
} // end randVar


-(void) windowWillClose:(NSNotification *)notification
{
    [NSApp stopModalWithCode:0];
}

/*
 - (void)drawRect:(NSRect)pNSRect {
 // colour the background white
 // [[NSColor whiteColor] set];	
 //[[drawColorBG color] set];	
 if(isTrans == 1)
 {
 NSColor  *color1 = [drawColorBG color];
 
 float red1 = [color1 redComponent];
 float green1 = [color1 greenComponent];
 float blue1 = [color1 blueComponent];
 //float alpha1 = [color1 alphaComponent];
 [[NSColor colorWithCalibratedRed: red1  green:green1 blue:blue1 alpha:1.0] set];
 
 //
 }
 else if(isTrans == 2)
 {
 [[NSColor colorWithCalibratedRed:0.0  green:0.0 blue:0.0 alpha:0.0] set];
 }
 else
 {
 NSColor  *color1 = [drawColorBG color];
 
 float red1 = [color1 redComponent];
 float green1 = [color1 greenComponent];
 float blue1 = [color1 blueComponent];
 [[NSColor colorWithCalibratedRed: red1  green:green1 blue:blue1 alpha:0.85] set];
 }
 
 // this is Cocoa
 
 NSRectFill( pNSRect );
 //   BOOL oldShouldAntialias;
 
 if ([myMutaryOfBrushStrokes count] == 0) {
 return;
 } // end if
 
 // This is Quartz	
 NSGraphicsContext	*	tvarNSGraphicsContext	= [NSGraphicsContext currentContext];
 //oldShouldAntialias = [tvarNSGraphicsContext shouldAntialias];
 //[tvarNSGraphicsContext setShouldAntialias:YES];
 
 
 CGContextRef tvarCGContextRef = (CGContextRef) [tvarNSGraphicsContext graphicsPort];
 CGContextSetAllowsAntialiasing(tvarCGContextRef, YES);
 CGContextSetShouldAntialias(tvarCGContextRef, YES);
 
 
 
 CGContextSetLineCap(tvarCGContextRef, kCGLineCapRound);
 CGContextSetLineJoin(tvarCGContextRef, kCGLineJoinRound);
 
 CGContextSetInterpolationQuality(tvarCGContextRef, kCGInterpolationHigh); 
 
 CGContextSetFlatness(tvarCGContextRef, 0.3);
 
 
 CGContextSetInterpolationQuality(tvarCGContextRef, 1.0);
 NSUInteger tvarIntNumberOfStrokes	= [myMutaryOfBrushStrokes count];
 
 
 NSColor  *color = [drawColorWell color];
 
 float red = [color redComponent];
 float green = [color greenComponent];
 float blue = [color blueComponent];
 float alpha = [color alphaComponent];
 
 //CGContextAddArc(tvarCGContextRef, 55, 210, 36, radians(25), radians(65), 0);
 
 MyPoint * tvarCurPointObj;
 
 
 NSUInteger i;
 for (i = 0; i < tvarIntNumberOfStrokes; i++) {
 
 CGContextSetRGBStrokeColor(tvarCGContextRef,red,green,blue,alpha);
 CGContextSetLineWidth(tvarCGContextRef, ( [thickness floatValue ] * 20.0) );//(1.0 + (0.5 * 10.0)
 
 myMutaryOfPoints	= [myMutaryOfBrushStrokes objectAtIndex:i];
 
 NSUInteger tvarIntNumberOfPoints	= [myMutaryOfPoints count];				// always >= 2
 MyPoint * tvarLastPointObj			= [myMutaryOfPoints objectAtIndex:0];
 CGContextBeginPath(tvarCGContextRef);
 CGContextMoveToPoint(tvarCGContextRef,[tvarLastPointObj x],[tvarLastPointObj y]);
 
 NSUInteger j;
 for (j = 1; j < tvarIntNumberOfPoints; j++) {  // note the index starts at 1
 tvarCurPointObj			= [myMutaryOfPoints objectAtIndex:j];
 
 
 CGContextAddLineToPoint(tvarCGContextRef,[tvarCurPointObj x],[tvarCurPointObj y]);	
 
 
 //NSLog(@"%f", [tvarCurPointObj x]);
 //CGContextMoveToPoint(tvarCGContextRef, [tvarCurPointObj x], [tvarCurPointObj y]);
 
 } // end for
 
 CGContextStrokePath(tvarCGContextRef);
 } // end for
 
 // [self contextEraseLine:tvarCGContextRef from:CGPointMake ([tvarCurPointObj x],[tvarCurPointObj y]) to:CGPointMake ([tvarCurPointObj x]+1,[tvarCurPointObj y]+1) withThickness:( [thickness floatValue ] * 20.0)];
 
 // CGContextClosePath(tvarCGContextRef);
 
 isClear = NO;
 
 } // end drawRect
 
 - (void) contextEraseLine:(CGContextRef) ctx from:(CGPoint)startPoint to:(CGPoint) endPoint withThickness:(int)thickness {
 int x, cx, deltax, xstep,
 y, cy, deltay, ystep,
 error, st, dupe;
 
 int x0, y0, x1, y1;
 
 x0 = startPoint.x;
 y0 = startPoint.y;
 x1 = endPoint.x;
 y1 = endPoint.y;
 
 // find largest delta for pixel steps
 st = (abs(y1 - y0) > abs(x1 - x0));
 
 // if deltay > deltax then swap x,y
 if (st) {
 (x0 ^= y0); (y0 ^= x0); (x0 ^= y0); // swap(x0, y0);
 (x1 ^= y1); (y1 ^= x1); (x1 ^= y1); // swap(x1, y1);
 }
 
 deltax = abs(x1 - x0);
 deltay = abs(y1 - y0);
 error  = (deltax / 2);
 y = y0;
 
 if (x0 > x1) { xstep = -1; }
 else         { xstep =  1; }
 
 if (y0 > y1) { ystep = -1; }
 else         { ystep =  1; }
 
 for ((x = x0); (x != (x1 + xstep)); (x += xstep))
 {
 (cx = x); (cy = y); // copy of x, copy of y
 
 // if x,y swapped above, swap them back now
 if (st) { (cx ^= cy); (cy ^= cx); (cx ^= cy); }
 
 (dupe = 0); // initialize no dupe
 
 if(!dupe) { // if not a dupe, write it out
 //NSLog(@"(%2d, %2d)", cx, cy);
 
 CGContextClearRect(ctx, CGRectMake(cx, cy, thickness, thickness));
 
 }
 
 (error -= deltay); // converge toward end of line
 
 if (error < 0) { // not done yet
 (y += ystep);
 (error += deltax);
 }
 }
 }
 
 
 -(IBAction) clear:(id)sender
 {  
 if(isClear == YES)
 {
 [mWindow orderOut:self];
 }
 
 [myMutaryOfBrushStrokes removeAllObjects];
 [myMutaryOfPoints removeAllObjects];
 [self setNeedsDisplay:YES];	
 isClear = YES;
 }
 */
/*
 -(NSArray *)openSavePanel
 { 
 NSOpenPanel *panel;
 
 panel = [NSSavePanel savePanel];        
 [panel setFloatingPanel:YES];
 [panel setCanChooseDirectories:YES];
 [panel setCanChooseFiles:YES];
 int i = [panel runModalForTypes:nil];
 if(i == NSOKButton){
 return [panel filenames];
 }
 return nil;
 }
 */

static NSArray *openSavePanel()
{ 
    //NSOpenPanel *panel;
    NSSavePanel *panel;
    
    panel = [NSSavePanel savePanel];   
    [panel setFloatingPanel:YES];
    //[panel setCanChooseDirectories:YES];
    //[panel setCanChooseFiles:YES];
	//int i = [panel runModalForTypes:nil];
    NSInteger i = [panel runModal];
	if(i == NSOKButton){
		return [NSArray arrayWithObjects:[[panel URL] path],nil];
    }
    return nil;
}  
-(IBAction) setChlipHide:(id)sender
{
    [ChlipBoardSaved setHidden:YES];
    CGAssociateMouseAndMouseCursorPosition(true);
}



NSColor *existingColor;
-(IBAction) ClipBoardAction_Org:(id)sender
{
    [TouchUnActive setHidden:YES];
    
    [mPointerLine setHidden:YES];
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    [self lockFocus];
    //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self unlockFocus];
    
    NSImage *image = [[NSImage alloc] initWithSize:[rep size]];
    [image addRepresentation:rep];
    
    NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
    //save as png but failed
    
    NSImage *img =[[NSImage alloc] initWithData:data];
    
    //for tracpad saving image using crop
    NSImage *target ;  
    //if(TouchOver)
    //{
    //target = [[NSImage alloc]initWithSize:NSMakeSize((WinX2-WinX1)+10,(WinY2-WinY1)+10)];
    NSSize size = NSMakeSize((WinX2-WinX1)+20,(WinY2-WinY1)+20);
    if(size.width < 20)
        size.width = 20;
    if(size.height < 20)
        size.height = 20;
    target = [[NSImage alloc]initWithSize:size];
    
    if([target size].width <= 0 && [target size].height <= 0)
    {
        [rep release];
        [image release];
        [img release];
        [target release];
        [pool release];
        return;
    }
    
    [target lockFocus];
    
    // [img drawInRect:NSMakeRect(0,0,368,312) fromRect:NSMakeRect(0, 0, [img size].width-225, [img size].height )   operation:NSCompositeCopy   fraction:1.0];
    
    // NSLog(@"touched moved x1=%g x2=%g y1=%g y2=%g w=%g h=%g", WinX1, WinX2, WinY1, WinY2,WinX2-WinX1,WinY2-WinY1);
    
    //[img drawInRect:NSMakeRect(0,0,(WinX2-WinX1)+10,(WinY2-WinY1)+10) fromRect:NSMakeRect(WinX1-5, WinY1-5, (WinX2-WinX1)+10, (WinY2-WinY1)+10)   operation:NSCompositeCopy   fraction:1.0];
    
    [img drawInRect:NSMakeRect(0,0,(WinX2-WinX1)+20,(WinY2-WinY1)+20) fromRect:NSMakeRect(WinX1-5, WinY1-5, (WinX2-WinX1)+20, (WinY2-WinY1)+20)   operation:NSCompositeCopy   fraction:1.0];
    
    [target unlockFocus];
    
    //create a NSBitmapImageRep
    NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[target TIFFRepresentation]];
    //add the NSBitmapImage to the representation list of the target
    [target addRepresentation:bmpImageRep];
    
    //get the data from the representation
    //NSData *data1 = [bmpImageRep representationUsingType: NSPNGFileType  properties: nil];
    
    //end crop   
    
    [img release];
    NSImage *img1 =[[NSImage alloc] initWithData:[bmpImageRep representationUsingType: NSPNGFileType  properties: nil]];
    //  }
    
    
    
    //resize image
    NSData *newData = [self resizeImage :img1 size:[self savingFrameSize]];
    
    //  [newData writeToFile: strOutPath atomically: YES];
    
    //sleep(2);
    //NSTIFFPboardType
    
    NSImage *imageData =[[NSImage alloc] initWithData:newData];
    NSData * representation = [imageData TIFFRepresentation];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];   
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
    [pasteBoard setData:representation forType:NSTIFFPboardType];
    
    [imageData release];
    [img1 release];
    [rep release];
    [image release];
    [target release];
    [bmpImageRep release];
    
    
    // NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Event\" \n set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\")  \n keystroke tab using command down  \n repeat while (cur_app is frontmost)  \n delay 0.2  \n keystroke \"v\" using (command down)  \n end repeat \n end tell"];
    
    // NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" \n set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\") \n keystroke tab using command down \n  repeat while (cur_app is frontmost)  \n delay 0.2  \n keystroke \"v\" using (command down)  \n end repeat \n end tell"];
    
    // NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" \n keystroke tab using command down \n set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\") \n keystroke tab using command down  \n  repeat while (cur_app is frontmost)  \n delay 0.2   \n end repeat \n end tell"];
    
    //NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  \n keystroke tab using command down  \n keystroke tab using command down  \n  set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\") \n keystroke tab using command down  \n  repeat while (cur_app is frontmost) \n delay 0.2  \n keystroke \"v\" using (command down) \n  end repeat \n end tell"];
    
    //   NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  \n keystroke tab using command down \n  set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\")  \n delay 0.2  \n keystroke \"v\" using (command down) \n end tell"];
    
    //NSAppleScript *start = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"  \n keystroke tab using command down  \n keystroke tab using command down  \n  set cur_app to first process whose frontmost is true  \n set x to (name of cur_app is \"System Events\")  delay 0.2  \n keystroke \"v\" using (command down) \n end tell"]; 
    // [start executeAndReturnError:nil];
    
    
    // NSDictionary *errorDict;
    
    [mBGImg setHidden:NO];
    
    NSAppleScript *start1 = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set frontApp to name of application processes whose frontmost is true"];
    
	NSAppleEventDescriptor *count = [start1 executeAndReturnError:nil];
    
    NSString * PasteDoc = [count description];
    NSLog(@"NSAppleEventDescriptor  %@", PasteDoc);
    
    
    if(PasteDoc != NULL)
    {
        NSArray *iArr = [PasteDoc componentsSeparatedByString:@"'(\""];
        
        NSLog(@"City Name - %@",[iArr objectAtIndex:1]);
        
        NSArray *iArr1 = [[iArr objectAtIndex:1] componentsSeparatedByString:@"\")"];
        
        
        NSLog(@"City Name - %@",[iArr1 objectAtIndex:0]);
        
        //NSString *AString = [NSString stringWithFormat:@"tell application \"%@\" delay 0.2 \n keystroke \"v\" using (command down) \n end tell", [iArr1 objectAtIndex:0]];
        
        //activate application "TextEdit"
        //tell application "System Events"
        // keystroke "v" using {command down}
        //end tell
        NSString *AString = [NSString stringWithFormat:@"activate application \"%@\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell", [iArr1 objectAtIndex:0]];
        
        //delay 0.2 
        
        NSAppleScript *start = [[NSAppleScript alloc] initWithSource:AString]; 
        
        [start executeAndReturnError:nil];
        [start release];
    }
    
    [start1 release];
    
    //delay 0.2   \n
    
    //   / return;
    isTrans = 0;
    [self setNeedsDisplay:YES];
    [pool release];
    
    /*
    [ChlipBoardSaved setHidden:NO];
    [self performSelector:@selector(setChlipHide:) withObject:nil afterDelay:4];
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"HideWhenDone"] intValue] == 1)
    {
        [ChlipBoardSaved setHidden:YES];
        CGAssociateMouseAndMouseCursorPosition(true);
        [self CloseSignIt:nil];
    }
     */
    
    if(existingColor != nil)
    {
        mWindow.backgroundColor = existingColor;
        existingColor = nil;
    }
    [self onClear:nil];
    
}


-(IBAction) ClipBoardAction:(id)sender
{
    [TouchUnActive setHidden:YES];
    
    [mPointerLine setHidden:YES];
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
   
    //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
    NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];//[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:rep];
//     [self lockFocus];
//    [self unlockFocus];
    
    NSImage *image = [[NSImage alloc] initWithSize:[rep size]];
    [image addRepresentation:rep];
    
    NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
    //save as png but failed
    
    NSImage *img =[[NSImage alloc] initWithData:data];
    
    //for tracpad saving image using crop
    NSImage *target ;  
    //if(TouchOver)
    //{
    //target = [[NSImage alloc]initWithSize:NSMakeSize((WinX2-WinX1)+10,(WinY2-WinY1)+10)];
    NSSize size = NSMakeSize((WinX2-WinX1)+20,(WinY2-WinY1)+20);
    if(size.width < 20)
        size.width = 20;
    if(size.height < 20)
        size.height = 20;
    target = [[NSImage alloc]initWithSize:size];
    
    if([target size].width <= 0 && [target size].height <= 0)
    {
        //[rep release];
        [image release];
        [img release];
        [target release];
        [pool release];
        return;
    }
    
    [target lockFocus];
    
    // [img drawInRect:NSMakeRect(0,0,368,312) fromRect:NSMakeRect(0, 0, [img size].width-225, [img size].height )   operation:NSCompositeCopy   fraction:1.0];
    
    // NSLog(@"touched moved x1=%g x2=%g y1=%g y2=%g w=%g h=%g", WinX1, WinX2, WinY1, WinY2,WinX2-WinX1,WinY2-WinY1);
    
    //[img drawInRect:NSMakeRect(0,0,(WinX2-WinX1)+10,(WinY2-WinY1)+10) fromRect:NSMakeRect(WinX1-5, WinY1-5, (WinX2-WinX1)+10, (WinY2-WinY1)+10)   operation:NSCompositeCopy   fraction:1.0];
    
    [img drawInRect:NSMakeRect(0,0,(WinX2-WinX1)+20,(WinY2-WinY1)+20) fromRect:NSMakeRect(WinX1-5, WinY1-5, (WinX2-WinX1)+20, (WinY2-WinY1)+20)   operation:NSCompositeCopy   fraction:1.0];
    
    [target unlockFocus];
    
    //create a NSBitmapImageRep
    NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[target TIFFRepresentation]];
    //add the NSBitmapImage to the representation list of the target
    [target addRepresentation:bmpImageRep];
    
    //get the data from the representation
    //NSData *data1 = [bmpImageRep representationUsingType: NSPNGFileType  properties: nil];
    
    //end crop   
    
    [img release];
    NSImage *img1 =[[NSImage alloc] initWithData:[bmpImageRep representationUsingType: NSPNGFileType  properties: nil]];
    //  }
    
    //resize image
    NSData *newData = [self resizeImage :img1 size:[self savingFrameSize]];

    //NSTIFFPboardType
    
    NSImage *imageData =[[NSImage alloc] initWithData:newData];
    NSData * representation = [imageData TIFFRepresentation];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];// dataForType:NSPNGFileType];   
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil] owner:nil];
    [pasteBoard setData:representation forType:NSTIFFPboardType];
    
    [imageData release];
    [img1 release];
    //[rep release];
    [image release];
    [target release];
    [bmpImageRep release];
    
    
    
    
    [mBGImg setHidden:NO];
    //10.14 applescript not allow to paste
//    NSString *AString = @"activate application \"Meeting Notes\" \n tell application \"System Events\" \n keystroke \"v\" using (command down) \n end tell";
//    NSAppleScript *start = [[NSAppleScript alloc] initWithSource:AString];
//
//    [start executeAndReturnError:nil];
//    [start release];
    
    //delay 0.2   \n
    
    //   / return;
    isTrans = 0;
    [self setNeedsDisplay:YES];
    [pool release];
    //for 10.14 by sudip
    [_txtView paste:pasteBoard];
    [_txtView display];
    
    //end
    if(existingColor != nil)
    {
        mWindow.backgroundColor = existingColor;
        existingColor = nil;
    }
    [self onClear:nil];
    
}



-(IBAction) setUndo:(id)sender
{
    //[canvas setDoUndo];
    
    
    //\
    
    //   [Undo1 ];
    
    //[NSImage imageNamed:@"Help.png"];
}
-(IBAction) ClipBoard:(id)sender
{
    existingColor = mWindow.backgroundColor;
    mWindow.backgroundColor = [NSColor colorWithCalibratedRed: 0.0  green:0.0 blue:0.0 alpha:0.0];
    //if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ExpTranparent"] intValue] == 1)
        [mBGImg setHidden:YES];
    
    [TouchUnActive setHidden:YES];
    [mPointerLine setHidden:YES];
    isTrans = 1;
    [self setNeedsDisplay:YES]; 
    [self performSelector:@selector(ClipBoardAction:) withObject:nil afterDelay:0.0f];
    
    
    //   Delay(0, 2);
    //Sleep(1000);
    // sleep(12);
    //  NSArray *path = openSavePanel();
}

-(CGRect)savingFrameSize
{
    return CGRectMake(0,0,WinX2-WinX1,WinY2-WinY1);
    
    NSInteger silderValue = [[[NSUserDefaults standardUserDefaults] stringForKey:@"ExportSlider"] intValue];
    
    CGFloat width=WinX2-WinX1;
    CGFloat height=WinY2-WinY1;
    switch(silderValue)
    {
        case 1:
            width = width * 0.25;
            height = height *0.25;
            break;
        case 2:
            width = width * 0.50;
            height = height *0.50;
            break;
        case 3:
            //width = width;
            // height = height;
            break;
        case 4:
            width = width * 1.5;
            height = height * 1.5;
            break;
        case 5:
            width = width *2;
            height = height *2;
            break;
            
    }
    //NSLog(@"%f,%f", width,height);
    return CGRectMake(0,0,width,height);
}

-(IBAction) Save:(id)sender
{
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"ExpTranparent"] intValue] == 1)
        [mBGImg setHidden:YES];
    
    [TouchUnActive setHidden:YES];
    
    [self setNeedsDisplay:YES]; 
    NSArray *path = openSavePanel();
    
    if(!path){ 
        [mBGImg setHidden:NO];
        [mPointer setHidden:NO];
        //[mPointerLine setHidden:NO];
        [mToolBG setHidden:NO];
        isTrans = 0;
        [self setNeedsDisplay:YES];
        NSLog(@"No path selected, return..."); 
        return; 
    }
    
    //[mBGImg setHidden:YES];
    
    NSArray *extention = [NSArray arrayWithObjects: @".png",@".pdf",@".bmp",@".jpg",nil];
    
    
    NSString *strOutPath =[path objectAtIndex:0];     
    NSLog(@"%@",strOutPath); 
    
    NSString *strExtensiion = [[strOutPath lastPathComponent] pathExtension]; 
    if(strExtensiion == nil || [strExtensiion length] ==0)
    {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        strOutPath =[NSString stringWithFormat:@"%@-%@%@",strOutPath,strDate,[extention objectAtIndex:0]];
    }
    [self lockFocus];
    //rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self unlockFocus];
    
    NSImage *image = [[[NSImage alloc] initWithSize:[rep size]] autorelease];
    [image addRepresentation:rep];
    
    NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
    //save as png but failed
    
    NSImage *img =[[NSImage alloc] initWithData:data];
    //for tracpad saving image using crop
    NSImage *target ; 
    //if(TouchOver)
    //{
    target = [[NSImage alloc]initWithSize:NSMakeSize((WinX2-WinX1)+10,(WinY2-WinY1)+10)];
    
    [target lockFocus];
    
    // [img drawInRect:NSMakeRect(0,0,368,312) fromRect:NSMakeRect(0, 0, [img size].width-225, [img size].height )   operation:NSCompositeCopy   fraction:1.0];
    
    NSLog(@"touched moved x1=%g x2=%g y1=%g y2=%g w=%g h=%g", WinX1, WinX2, WinY1, WinY2,WinX2-WinX1,WinY2-WinY1);
    
    [img drawInRect:NSMakeRect(0,0,(WinX2-WinX1)+10,(WinY2-WinY1)+10) fromRect:NSMakeRect(WinX1-5, WinY1-5, (WinX2-WinX1)+10, (WinY2-WinY1)+10)   operation:NSCompositeCopy   fraction:1.0];
    
    
    
    [target unlockFocus];
    
    //create a NSBitmapImageRep
    NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[target TIFFRepresentation]];
    
    [bmpImageRep setOpaque:NO];
    [bmpImageRep setAlpha:YES];
    
    
    
    //add the NSBitmapImage to the representation list of the target
    [target addRepresentation:bmpImageRep];
    
    //get the data from the representation
    NSData *data1 = [bmpImageRep representationUsingType: NSPNGFileType  properties: nil];
    
    //end crop   
    
    
    
    NSImage *img1 = [[NSImage alloc] initWithData:data1];
    
    //  }
    //  [img drawInRect:NSMakeRect(0.0,0.0,_bounds.size.width,_bounds.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 - 0.0];
    
    
    //resize image
    //NSData *newData = [self resizeImage:img size:NSMakeRect(0, 0, 230, 97)];
    NSData *newData = [self resizeImage:img1 size:[self savingFrameSize ]];
    
    //NSData *newData =  [img representationUsingType:NSPNGFileType properties:nil];
    [newData writeToFile: strOutPath atomically: YES];
    
    [target release];
    [bmpImageRep release];
    // [data1 autorelease];
    [img1 release];
    [img release];
    [rep release];
    
    isTrans = 0;
    [self setNeedsDisplay:YES]; 
    
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"HideWhenDone"] intValue] == 1)
        [self CloseSignIt:nil];
    
    CGAssociateMouseAndMouseCursorPosition(true);
    [mBGImg setHidden:NO];
}


- (NSData*) resizeImage :(NSImage *) imgToResize size :(CGRect) rect
{
    //CGFloat sourceWidth = imgToResize.size.width;
    // CGFloat sourceHeight = imgToResize.size.height;
    
    CGFloat sourceWidth = [(NSBitmapImageRep*)[[imgToResize representations] objectAtIndex:0] pixelsWide];
    CGFloat sourceHeight = [(NSBitmapImageRep*)[[imgToResize representations] objectAtIndex:0] pixelsHigh];
    
    
    float nPercent = 0;
    float nPercentW = 0;
    float nPercentH = 0;
    
    nPercentW = ((float)rect.size.width / (float)sourceWidth);
    nPercentH = ((float)rect.size.height / (float)sourceHeight);
    
    if (nPercentH < nPercentW)
        nPercent = nPercentH;
    else
        nPercent = nPercentW;
    
    int destWidth = (int)(sourceWidth * nPercent);
    int destHeight = (int)(sourceHeight * nPercent);
    
    NSBitmapImageRep *repa =(NSBitmapImageRep*)[[imgToResize representations] objectAtIndex:0];
    
    [imgToResize lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [repa setSize:NSMakeSize(destWidth,destHeight)];
    
    [imgToResize unlockFocus];
    
    
    return [repa representationUsingType:NSPNGFileType properties:nil];
}

- (IBAction)GoLive:(id)sender
{
	NSURL *url = [[ NSURL alloc ] initWithString:@"http://www.ilifetouch.com"]; 
	[[NSWorkspace sharedWorkspace] openURL:url];
    [url release];
}
@end


