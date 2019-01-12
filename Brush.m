//
//  Brush.m
//  Paint
//
//  Created by Andy Finnell on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Brush.h"
#import "Canvas.h"
#import <QuartzCore/QuartzCore.h>

/*@interface Brush (Private)
 
 - (NSPoint) canvasLocation:(NSEvent *)theEvent view:(NSView *)view;
 - (void) stampStart:(NSPoint)startPoint end:(NSPoint)endPoint inView:(NSView *)view onCanvas:(Canvas *)canvas;
 
 - (CGContextRef) createBitmapContext;
 - (void) disposeBitmapContext:(CGContextRef)bitmapContext;
 - (CGImageRef) createShapeImage;
 
 @end*/

@implementation Brush


-(void)awakeFromNib
{
    
}

-(BOOL)getEraseButtonState
{
    return mEraserIsPressed;
}

-(IBAction)LoadBrush:(id)sender
{
    mEraserIsPressed = FALSE;
    CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"burshThick"] floatValue];
    if(thick <=0)
        mRadius = 1.0f;
    else
        mRadius = thick;
    
    // Create the shape of the tip of the brush. Code currently assumes the bounding
    //	box of the shape is square (height == width)
    mShape = CGPathCreateMutable();
    CGPathAddEllipseInRect(mShape, nil, CGRectMake(0, 0, 2 * mRadius, 2 * mRadius));
    //CGPathAddRect(mShape, nil, CGRectMake(0, 0, 2 * mRadius, 2 * mRadius));
    
    // Create the color for the brush
    // CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    //NSColor *fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ];*/
    
    
    NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"drawColor"];
    //NSColor *fColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    
    //if (theData == nil)
    //fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ];
    
    NSColor *fColor = nil;
    if (theData != nil)
        fColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    else
        fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ];
    
    
    //NSLog(@"Data %@", [[NSUserDefaults standardUserDefaults] dataForKey:@"drawColor"]);
    NSLog(@"Data %@", theData);
    
    
    [drawColor setColor:fColor];
    [self setForeGroundColor:nil];
}
-(IBAction)setForeGroundColor:(id)sender
{
    mEraserIsPressed = FALSE;
    NSColor * fColor;
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if(mEraserIsPressed)
    {
        NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"drawColor"];
        
        if (theData != nil)
            fColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
        else
            fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ]; 
    }
    else
        fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ];  
    
    
    NSData *theData=[NSArchiver archivedDataWithRootObject:fColor];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"drawColor"];
    
    
    
    
    CGFloat components[4];
    [fColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
    NSLog(@"whythis  %f,%f,%f%f", components[0],components[1],components[2],components[3]);
    
    mColor= CGColorCreate (colorspace, components);
    CGColorSpaceRelease(colorspace);
    NSLog(@"first   %f,%f,%f%f", components[0],components[1],components[2],components[3]);   
    [self setBurshThickness:thickness];
    
    NSLog(@"Data1 %@", [[NSUserDefaults standardUserDefaults] dataForKey:@"drawColor"]);
}

-(IBAction)onEraser:(id)sender
{
    mEraserIsPressed = TRUE;
    NSColor * fColor;
    
    /*
     NSColor *fcolor=[drawColor color];
     
     NSString *strRGBColor =[NSString stringWithFormat:@"%f,%f,%f,1.0",[fcolor redComponent],[fcolor greenComponent],[fcolor blueComponent],[fcolor alphaComponent]];
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults setObject:strRGBColor forKey:@"drawColor"];
     [defaults synchronize];
     */
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"backColor"];
    
    if (theData != nil)
        fColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    else
        fColor= [[drawColor color]colorUsingColorSpaceName:NSDeviceRGBColorSpace ]; 
    
    
    CGFloat components[4];
    [fColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
    
    NSLog(@"whythis  %f,%f,%f%f", components[0],components[1],components[2],components[3]);
    mColor= CGColorCreate (colorspace, components);
    CGColorSpaceRelease(colorspace);  
    
    
    //mRadius = 3.0f;
    CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"burshThick"] floatValue];
    if(thick >0)
        mRadius = thick;
    mShape = CGPathCreateMutable();
    CGPathAddEllipseInRect(mShape, nil, CGRectMake(0, 0, 2 * mRadius, 2 * mRadius));
    
    NSLog(@"Line - %f",mRadius);
    
    
    NSLog(@"mEraserIsPressed Data %@", [[NSUserDefaults standardUserDefaults] dataForKey:@"backColor"]);
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isErased"];
}


-(IBAction)setBurshThickness:(id)sender
{
    CGFloat myfloat = [sender floatValue];   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f", myfloat] forKey:@"burshThick"];
    [defaults synchronize];
    
    CGFloat thick = [[[NSUserDefaults standardUserDefaults] stringForKey:@"burshThick"] floatValue];
    if(thick >0)
        mRadius = thick;
    mShape = CGPathCreateMutable();
    CGPathAddEllipseInRect(mShape, nil, CGRectMake(0, 0, 2 * mRadius, 2 * mRadius));
    
    NSLog(@"Line - %f",mRadius);
    
    [[[[drawColor superview] subviews] objectAtIndex:3] resetCursorRects];
    
}

- (void) dealloc
{
	// Clean up our shape and color
	CGPathRelease(mShape);
	CGColorRelease(mColor);
	
	[super dealloc];
}

- (void) mouseDown:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag
{
    //  NSLog(@"mouseDown");
    
    [pen setHidden:NO];
    [erase setHidden:NO];
    
    if(mEraserIsPressed == FALSE)
    {
        [pen setState:1];
        [erase setState:0];
    }
    else
    {
        [pen setState:0];
        [erase setState:1];  
    }
    
    [BtnClose setHidden:YES];
    [BtnSave setHidden:NO];
    [BtnClip setHidden:NO];
    [BtnClear setHidden:NO];
    
    [BscBtnClear setHidden:NO];
    [BscBtnClose setHidden:YES];
    [BscBtnAdv setTransparent:YES];
    [BscBtnSave setHidden:NO];
    
    
	// Translate the event point location into a canvas point
    NSPoint currentPoint;
    if(!bFlag)
        currentPoint = [self canvasLocation:theEvent view:view];
    else
        currentPoint = cPoint;
	// Initialize all the tracking information. This includes creating an image
	//	of the brush tip
    
    
    /*-------------*/
    
    CGRect boundingBox = CGPathGetBoundingBox(mShape);
	
	size_t width = CGRectGetWidth(boundingBox);
	size_t height = CGRectGetHeight(boundingBox);
	size_t bitsPerComponent = 8;
	size_t bytesPerRow = ((width * 4) + 0x0000000F) & ~0x0000000F; // 16 byte aligned is good
	size_t dataSize = bytesPerRow * height;
	void * data = calloc(1, dataSize);
	CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	
	CGContextRef bitmapContext = CGBitmapContextCreate(data, width, height, bitsPerComponent,
													   bytesPerRow, colorspace, 
													   kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorspace);
    
	// Clear the context to transparent, 'cause we'll be using transparency
	CGContextClearRect(bitmapContext, CGRectMake(0, 0, width, height));
	if ( !mHard )
		CGContextSetAlpha(bitmapContext, 0.5f);
	CGContextBeginTransparencyLayer(bitmapContext, nil);
	
	// I like a little color in my brushes
	CGContextSetFillColorWithColor(bitmapContext, mColor);
	//	opaque pixels.
	int innerRadius = (int)ceil(mSoftness * (0.5 - mRadius) + mRadius);
	int outerRadius = (int)ceil(mRadius);
	int i = 0;
	
	CGFloat alphaStep = 1.0f / (outerRadius - innerRadius + 1);
	
	CGContextSetAlpha(bitmapContext, alphaStep);
	
	for (i = outerRadius; i >= innerRadius; --i) {
		CGContextSaveGState(bitmapContext);
		
		// First, center the shape onto the context.
		CGContextTranslateCTM(bitmapContext, outerRadius - i, outerRadius - i);
        
		CGFloat scale = (2.0f * (float)i) / (2.0f * (float)outerRadius);
		CGContextScaleCTM(bitmapContext, scale, scale);
        
		CGContextAddPath(bitmapContext, mShape);
		CGContextEOFillPath(bitmapContext);
        
		CGContextRestoreGState(bitmapContext);
	}
	CGContextEndTransparencyLayer(bitmapContext);
	
	CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    
    void * data2 = CGBitmapContextGetData(bitmapContext);
	CGContextRelease(bitmapContext);
	free(data2);	
    /*==============*/
    
	//mMask = [self createShapeImage];
    mMask = image;
	mLastPoint = currentPoint;
	mLeftOverDistance = 0.0f;
	
	// Since this is a mouse down, we want to stamp the brush's image not matter
	//	what.
    [canvas stampMask:mMask at:currentPoint];
	
	// This isn't very efficient, but we need to tell the view to redraw. A better
	//	version would have the canvas itself to generate an invalidate for the view
	//	(since it knows exactly where the bits changed).
    
    //	[view setNeedsDisplay:YES];
    
    // Start : For dot drawing issue   
    currentPoint = cPoint;
	
	// Stamp the brush in a line, from the last mouse location to the current one
    
    NSPoint ptTemp = mLastPoint;
    mLastPoint = currentPoint;
	[self stampStart:mLastPoint end:currentPoint inView:view onCanvas:canvas];
	
	// Remember the current point, so that next time we know where to start
	//	the line
	mLastPoint = ptTemp;
    
    //end
}

- (void) mouseDragged:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag
{
    //  NSLog(@"mouseDragged");
    
	// Translate the event point location into a canvas point
    NSPoint currentPoint;
    if(!bFlag)
        currentPoint = [self canvasLocation:theEvent view:view];
    else
        currentPoint = cPoint;
	
	// Stamp the brush in a line, from the last mouse location to the current one
	[self stampStart:mLastPoint end:currentPoint inView:view onCanvas:canvas];
	
	// Remember the current point, so that next time we know where to start
	//	the line
	mLastPoint = currentPoint;
}

- (void) mouseUp:(NSEvent *)theEvent inView:(NSView *)view onCanvas:(Canvas *)canvas cPoint:(NSPoint)cPoint bFlag:(BOOL)bFlag
{
    //   NSLog(@"mouseUp");
	// Translate the event point location into a canvas point
    NSPoint currentPoint;
    if(!bFlag)
        currentPoint = [self canvasLocation:theEvent view:view];
    else
        currentPoint = cPoint;
	
	// Stamp the brush in a line, from the last mouse location to the current one
	[self stampStart:mLastPoint end:currentPoint inView:view onCanvas:canvas];
	
	// This is a mouse up, so we are done tracking. Use this opportunity to clean
	//	up all the tracking information, including the brush tip image.
	CGImageRelease(mMask);
	mMask = nil;
	mLastPoint = NSZeroPoint;
	mLeftOverDistance = 0.0f;
}


/*@end
 
 @implementation Brush (Private)
 */
- (NSPoint) canvasLocation:(NSEvent *)theEvent view:(NSView *)view
{
	// Currently we assume that the NSView here is a CanvasView, which means
	//	that the view is not scaled or offset. i.e. There is a one to one
	//	correlation between the view coordinates and the canvas coordinates.
	NSPoint eventLocation = [theEvent locationInWindow];
	return [view convertPoint:eventLocation fromView:nil];
}


- (void) stampStart:(NSPoint)startPoint end:(NSPoint)endPoint inView:(NSView *)view onCanvas:(Canvas *)canvas
{
	// We need to ask the canvas to draw a line using the brush. Keep track
	//	of the distance left over that we didn't draw this time (so we draw
	//	it next time).
	mLeftOverDistance = [canvas stampMask:mMask from:startPoint to:endPoint leftOverDistance:mLeftOverDistance];
	
	// This isn't very efficient, but we need to tell the view to redraw. A better
	//	version would have the canvas itself to generate an invalidate for the view
	//	(since it knows exactly where the bits changed).	
	[view setNeedsDisplay:YES];
}


@end
