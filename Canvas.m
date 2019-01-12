//
//  Canvas.m
//  Paint
//
//  Created by Andy Finnell on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Canvas.h"

#import "ObjectForUndo.h"

@implementation Canvas

//NSSize lsize ;

NSMutableArray *arrUndo;
NSMutableArray *arrRedo;

ObjectForUndo *backupBeforeResize;


- (id) initWithSize:(NSSize)size
{
    mEraserIsPressed = NO;
	//self = [super init];
	
	if ( self ) {
		// Create a bitmap context for the canvas. To keep things simple
        
        //lsize =size;
		//	we're going to use a 32-bit ARGB format.
		size_t width = size.width;
		size_t height = size.height;
		size_t bitsPerComponent = 8;
		//size_t bytesPerRow = ((width * 4) + 0x0000000F) & ~0x0000000F; // 16-byte aligned is good
		//size_t dataSize = bytesPerRow * height;
        // size_t bitsPerComponent = 8;
        size_t bytesPerPixel    = 4;
        size_t bytesPerRow      = (width * bitsPerComponent * bytesPerPixel + 7) / 8;
        size_t dataSize         = bytesPerRow * height;
        void* data = calloc(1, dataSize);
		CGColorSpaceRef colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        if(mBitmapContext != nil)
        {
            CGContextRelease(mBitmapContext);
            mBitmapContext = nil;
        }
		
		mBitmapContext = CGBitmapContextCreate(data, width, height, bitsPerComponent,
                                               bytesPerRow, colorspace, 
                                               kCGImageAlphaPremultipliedFirst);
        
		CGColorSpaceRelease(colorspace);
		
		// Paint on a white background so the user has something to start with.
		//CGContextSaveGState(mBitmapContext);
		
        //	CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext),CGBitmapContextGetHeight(mBitmapContext));
        
        
        /*
         
         
         NSString *strBColor = [[NSUserDefaults standardUserDefaults] stringForKey:@"backColor"] ;
         NSColor *bColor;
         if(strBColor != nil && [strBColor length]>0)
         {
         NSArray *arrStr = [strBColor componentsSeparatedByString:@","];
         CGFloat red =[[arrStr objectAtIndex:0] floatValue];
         CGFloat green =[[arrStr objectAtIndex:1] floatValue];
         CGFloat blue =[[arrStr objectAtIndex:2] floatValue];
         CGFloat alpha =1.0;
         bColor =[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
         NSLog(@" bg color from session :%@",[NSString stringWithFormat:@"%f,%f,%f,%f",[bColor redComponent],[bColor greenComponent],[bColor blueComponent],[bColor alphaComponent]]);
         }
         else
         bColor =[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]; 
         */
        
        
        NSColor *bColor;
        
        NSData *theData = [[NSUserDefaults standardUserDefaults] dataForKey:@"backColor"];
        
        if (theData != nil)
            bColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
        else
            bColor =[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]; 
        
        [drawColorBG setColor:bColor];
        
        // CGContextSetFillColorWithColor(mBitmapContext,CGColorCreateGenericRGB([bColor redComponent],[bColor greenComponent],[bColor blueComponent], 1.0));
        
        // CGContextFillRect(mBitmapContext, fillRect);
		//CGContextRestoreGState(mBitmapContext);
        
        [mBGImg setBackgroundColor:bColor];
	}
	return self;
}


-(void)resetGraphicsContext:(NSGraphicsContext*)context
{
    if(context == nil)
        return;
    if(mBitmapContext != nil)
    {
        CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
        CGContextClearRect(mBitmapContext, fillRect);
        CGContextRelease(mBitmapContext);
        mBitmapContext = nil;
    }
    mBitmapContext = [context graphicsPort];
    CGContextSaveGState(mBitmapContext);
}



-(IBAction)setBackgroundcolor
{
    //CGContextSaveGState(mBitmapContext);
    
    NSColor  *color = [drawColorBG color];
    
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"backColor"];
    
    
    
    //CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
    
    [mBGImg setBackgroundColor:color];
    
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isErased"];
    
    //CGContextSetFillColorWithColor(mBitmapContext,CGColorCreateGenericRGB([color redComponent],[color greenComponent],[color blueComponent], 1.0));
    //CGContextFillRect(mBitmapContext, fillRect);
    // CGContextRestoreGState(mBitmapContext);
    
    /*
     [pen setHidden:YES];
     [erase setHidden:YES];
     
     [BtnClose setHidden:NO];
     [BtnSave setHidden:YES];
     [BtnClip setHidden:YES];
     [BtnClear setHidden:YES];
     
     [BscBtnClear setHidden:YES];
     [BscBtnClose setHidden:NO];
     [BscBtnAdv setTransparent:NO];
     [BscBtnSave setHidden:YES];
     */
    
    mEraserIsPressed = NO;
}


-(void)setForUndo
{
    CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
    
    CGRect imageRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), 
								  CGBitmapContextGetHeight(mBitmapContext));
    
    if(arrUndo == nil)
    {
        arrUndo = [[NSMutableArray alloc] init];
    }
    
    ObjectForUndo *objUndo = [[[ObjectForUndo alloc] init] autorelease];
    objUndo.imageRef = imageRef;
    objUndo.imageRect = imageRect;
    
    [arrUndo addObject:objUndo];
}


-(void)setForRedo
{
    CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
    
    CGRect imageRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), 
								  CGBitmapContextGetHeight(mBitmapContext));
    
    if(arrRedo == nil)
    {
        arrRedo = [[NSMutableArray alloc] init];
    }
    
    ObjectForUndo *objUndo = [[[ObjectForUndo alloc] init] autorelease];
    objUndo.imageRef = imageRef;
    objUndo.imageRect = imageRect;
    
    [arrRedo addObject:objUndo];
}

-(void)setBackupBeforeResize
{
    CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
    
    CGRect imageRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), 
								  CGBitmapContextGetHeight(mBitmapContext));
    
    
    backupBeforeResize = [[[ObjectForUndo alloc] init] autorelease];
    backupBeforeResize.imageRef = imageRef;
    backupBeforeResize.imageRect = imageRect;
}

-(void)drawRectAfterResize
{
    if(backupBeforeResize == nil)
        return;
    
    CGImageRef imageRef = backupBeforeResize.imageRef;
	
	// Grab the destination context
	CGContextRef contextRef = mBitmapContext;
	//CGContextSaveGState(contextRef);
    
	// Composite on the image at the bottom left of the context
    
    
    CGRect imageRect = backupBeforeResize.imageRect;
    
    CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
    CGContextClearRect(mBitmapContext, fillRect);
    
	CGContextDrawImage(contextRef, imageRect, imageRef);
	
	CGImageRelease(imageRef);
    
    [[mBGImg superview] setNeedsDisplay:YES];
    
    backupBeforeResize = nil;
}



-(void)drawRectWhenUndo
{
    if(arrUndo == nil || [arrUndo count] <= 0)
        return;
    
    [self setForRedo];
    
    ObjectForUndo *obj = [arrUndo lastObject];
    
    CGImageRef imageRef = obj.imageRef;
	
	// Grab the destination context
	CGContextRef contextRef = mBitmapContext;
	//CGContextSaveGState(contextRef);
    
	// Composite on the image at the bottom left of the context
    
    
    CGRect imageRect = obj.imageRect;
    
    CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
    CGContextClearRect(mBitmapContext, fillRect);
    
	CGContextDrawImage(contextRef, imageRect, imageRef);
	
	CGImageRelease(imageRef);
    
    [arrUndo removeLastObject];
    
    [[mBGImg superview] setNeedsDisplay:YES];
}

-(void)drawRectWhenRedo
{
    if(arrRedo == nil || [arrRedo count] <= 0)
        return;
    
    [self setForUndo];
    
    ObjectForUndo *obj = [arrRedo lastObject];
    
    CGImageRef imageRef = obj.imageRef;
	
	// Grab the destination context
	CGContextRef contextRef = mBitmapContext;
	//CGContextSaveGState(contextRef);
    
	// Composite on the image at the bottom left of the context
    
    
    CGRect imageRect = obj.imageRect;
    
    CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
    CGContextClearRect(mBitmapContext, fillRect);
    
	CGContextDrawImage(contextRef, imageRect, imageRef);
	
	CGImageRelease(imageRef);
    
    [arrRedo removeLastObject];
    
    [[mBGImg superview] setNeedsDisplay:YES];
}


-(void)setSaveUndo
{
    [self setForUndo];
}



-(IBAction)setClear
{
    // CGContextSaveGState(mBitmapContext);
    
    NSColor  *color = [drawColorBG color];
    
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"backColor"];
    
    [mBGImg setBackgroundColor:color];
    
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isErased"];
    
    //CGContextSetFillColorWithColor(mBitmapContext,CGColorCreateGenericRGB([color redComponent],[color greenComponent],[color blueComponent], 0.0));
    //// CGContextFillRect(mBitmapContext, fillRect);
    // CGContextRestoreGState(mBitmapContext);
    
    CGRect fillRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), CGBitmapContextGetHeight(mBitmapContext));
    
    CGContextClearRect(mBitmapContext, fillRect);
    
    [pen setHidden:YES];
    [erase setHidden:YES];
    
    [BtnClose setHidden:NO];
    [BtnSave setHidden:YES];
    [BtnClip setHidden:YES];
    [BtnClear setHidden:YES];
    
    [BscBtnClear setHidden:YES];
    [BscBtnClose setHidden:NO];
    [BscBtnAdv setTransparent:NO];
    [BscBtnSave setHidden:YES];
}

- (void) dealloc
{
	// Free up our bitmap context
	void* data = CGBitmapContextGetData(mBitmapContext);
	CGContextRelease(mBitmapContext);
	free(data);
	
	[super dealloc];
}

- (void)drawRect
{
    
    
}

- (void)drawRect:(NSRect)rect inContext:(NSGraphicsContext*)context
{
    
    //NSLog(@"drawRect");
    // Here we simply want to render our bitmap context into the view's
	//	context. It's going to be a straight forward bit blit. First,
	//	create an image from our bitmap context.
	CGImageRef imageRef = CGBitmapContextCreateImage(mBitmapContext);
	
	// Grab the destination context
	CGContextRef contextRef = [context graphicsPort];
	//CGContextSaveGState(contextRef);
    
	// Composite on the image at the bottom left of the context
	CGRect imageRect = CGRectMake(0, 0, CGBitmapContextGetWidth(mBitmapContext), 
								  CGBitmapContextGetHeight(mBitmapContext));
	CGContextDrawImage(contextRef, imageRect, imageRef);
	
	CGImageRelease(imageRef);
}

- (CGFloat)stampMask:(CGImageRef)mask from:(NSPoint)startPoint to:(NSPoint)endPoint leftOverDistance:(CGFloat)leftOverDistance
{
	// Set the spacing between the stamps. By trail and error, I've 
	//	determined that 1/10 of the brush width (currently hard coded to 20)
	//	is a good interval.
	CGFloat spacing = CGImageGetWidth(mask) * 0.1;
	
	// Anything less that half a pixel is overkill and could hurt performance.
	if ( spacing < 0.5 )
		spacing = 0.5;
	
	// Determine the delta of the x and y. This will determine the slope
	//	of the line we want to draw.
	CGFloat deltaX = endPoint.x - startPoint.x;
	CGFloat deltaY = endPoint.y - startPoint.y;
	
	// Normalize the delta vector we just computed, and that becomes our step increment
	//	for drawing our line, since the distance of a normalized vector is always 1
	CGFloat distance = sqrt( deltaX * deltaX + deltaY * deltaY );
	CGFloat stepX = 0.0;
	CGFloat stepY = 0.0;
	if ( distance > 0.0 ) {
		CGFloat invertDistance = 1.0 / distance;
		stepX = deltaX * invertDistance;
		stepY = deltaY * invertDistance;
	}
	
	CGFloat offsetX = 0.0;
	CGFloat offsetY = 0.0;
	
	// We're careful to only stamp at the specified interval, so its possible
	//	that we have the last part of the previous line left to draw. Be sure
	//	to add that into the total distance we have to draw.
	CGFloat totalDistance = leftOverDistance + distance;
	
	// While we still have distance to cover, stamp
	while ( totalDistance >= spacing ) {
		// Increment where we put the stamp
		if ( leftOverDistance > 0 ) {
			// If we're making up distance we didn't cover the last
			//	time we drew a line, take that into account when calculating
			//	the offset. leftOverDistance is always < spacing.
			offsetX += stepX * (spacing - leftOverDistance);
			offsetY += stepY * (spacing - leftOverDistance);
			
			leftOverDistance -= spacing;
		} else {
			// The normal case. The offset increment is the normalized vector
			//	times the spacing
			offsetX += stepX * spacing;
			offsetY += stepY * spacing;
		}
		
		// Calculate where to put the current stamp at.
		NSPoint stampAt = NSMakePoint(startPoint.x + offsetX, startPoint.y + offsetY);
		
		// Ka-chunk! Draw the image at the current location
		[self stampMask:mask at: stampAt];
		
		// Remove the distance we just covered
		totalDistance -= spacing;
	}
	
	// Return the distance that we didn't get to cover when drawing the line.
	//	It is going to be less than spacing.
	return totalDistance;	
}


-(IBAction) setErase:(id)sender
{
    mEraserIsPressed = YES;
    //
}
-(IBAction) setPen:(id)sender{
    //
    mEraserIsPressed = NO;
}

- (void)stampMask:(CGImageRef)mask at:(NSPoint)point
{
    
    // Now that it's properly lined up, draw the image
    
    
    if(!mEraserIsPressed)
    {
        CGContextSaveGState(mBitmapContext);
        
        // So we can position the image correct, compute where the bottom left
        //	of the image should go, and modify the CTM so that 0, 0 is there.
        CGPoint bottomLeft = CGPointMake( point.x - CGImageGetWidth(mask) * 0.5,
                                         point.y - CGImageGetHeight(mask) * 0.5 );
        CGContextTranslateCTM(mBitmapContext, bottomLeft.x, bottomLeft.y);
        
        
        //NSLog(@"aaa");
        CGRect maskRect = CGRectMake(0, 0, CGImageGetWidth(mask), CGImageGetHeight(mask));
        CGContextDrawImage(mBitmapContext, maskRect, mask);
        CGContextRestoreGState(mBitmapContext);
    }
    else
    {
        // NSLog(@"bbb");
        CGRect maskRect = CGRectMake(point.x, point.y, CGImageGetWidth(mask), CGImageGetHeight(mask));
        CGContextClearRect(mBitmapContext, maskRect);
    }
    
    
    // NSLog(@"aaa");
    //CGRect maskRect = CGRectMake(0, 0, CGImageGetWidth(mask), CGImageGetHeight(mask));
    // CGContextDrawImage(mBitmapContext, maskRect, mask);
    // CGContextRestoreGState(mBitmapContext);
}


-(void)clearUndoRedoData
{
    if(arrUndo != nil && [arrUndo count] > 0)
    {
        NSInteger noOfUndo = [arrUndo count];
        NSInteger i = 0;
        for(i = 0 ; i < noOfUndo ; i++)
        {
            ObjectForUndo *objUndo = [arrUndo objectAtIndex:i];
            if(objUndo == nil)
                continue;
            
            CGImageRelease(objUndo.imageRef);
        }
        
        [arrUndo removeAllObjects];
    }
    
    if(arrRedo != nil && [arrRedo count] > 0)
    {
        NSInteger noOfUndo = [arrRedo count];
        NSInteger i = 0;
        for(i = 0 ; i < noOfUndo ; i++)
        {
            ObjectForUndo *objRedo = [arrRedo objectAtIndex:i];
            if(objRedo == nil)
                continue;
            
            CGImageRelease(objRedo.imageRef);
        }
        
        [arrRedo removeAllObjects];
    }
    
    if(backupBeforeResize != nil)
    {
        CGImageRelease(backupBeforeResize.imageRef);
        backupBeforeResize = nil;
    }
}


@end

