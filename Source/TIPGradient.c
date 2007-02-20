/*
 *  TIPGradient.c
 *  TIPBox
 *
 *  Created by Nur Monson on 10/31/06.
 *  Copyright 2006 theidiotproject. All rights reserved.
 *
 */

#include "TIPGradient.h"

#pragma mark gradient types

typedef struct _TIPGradientElement
{
	float red, green, blue, alpha;
	float position;
	
	struct _TIPGradientElement *nextElement;
} TIPGradientElement;

struct TIPGradient
{
	TIPGradientElement *elementList;
	TIPGradientBlendingMode blendingMode;
	CGFunctionRef gradientFunction;
	
	unsigned int retainCount;
};

#pragma mark gradient prototypes

//C Fuctions for color blending
void TIPGradientLinearEvaluation   (void *info, const float *in, float *out);
void TIPGradientChromaticEvaluation(void *info, const float *in, float *out);
void TIPGradientInverseChromaticEvaluation(void *info, const float *in, float *out);
void TIPGradientTransformRGB_HSV(float *components);
void TIPGradientTransformHSV_RGB(float *components);
void TIPGradientResolveHSV(float *color1, float *color2);

void TIPGradientAddElement( TIPMutableGradientRef aGradient, TIPGradientElement *newElement );
void TIPGradientFindEndpointsForRotation( CGRect rect, float degrees, CGPoint *startPoint, CGPoint *endPoint);

#pragma mark gradient functions

TIPGradientRef TIPGradientCreate( void )
{
	TIPMutableGradientRef aGradient = malloc( sizeof(struct TIPGradient) );
	
	aGradient->elementList = NULL;
	aGradient->gradientFunction = NULL;
	aGradient->retainCount = 1;
	//aGradient->blendingMode = TIPLinearBlendingMode;
	TIPGradientSetBlendingMode( aGradient, TIPLinearBlendingMode );
	
	return (TIPGradientRef)aGradient;
}

TIPGradientRef TIPGradientAquaCreate( void )
{
	TIPMutableGradientRef aqua = TIPMutableGradientCreate();
	
	TIPGradientAddRGBColorStop(aqua,0.0f,0.95f,0.95f,0.95f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.83f,0.83f,0.83f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.95f,0.95f,0.95f,1.0f);
	TIPGradientAddRGBColorStop(aqua,1.0f,0.92f,0.92f,0.92f,1.0f);
	
	return (TIPGradientRef)aqua;
}

TIPGradientRef TIPGradientAquaSelectedCreate( void )
{
	TIPMutableGradientRef aqua = TIPMutableGradientCreate();
	
	TIPGradientAddRGBColorStop(aqua,0.0f,0.58f,0.86f,0.98f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.42f,0.68f,0.90f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.64f,0.80f,0.94f,1.0f);
	TIPGradientAddRGBColorStop(aqua,1.0f,0.56f,0.70f,0.90f,1.0f);
	
	return (TIPGradientRef)aqua;	
}

TIPGradientRef TIPGradientAquaPressedCreate( void )
{
	TIPMutableGradientRef aqua = TIPMutableGradientCreate();
	
	TIPGradientAddRGBColorStop(aqua,0.0f,0.80f,0.80f,0.80f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.64f,0.64f,0.64f,1.0f);
	TIPGradientAddRGBColorStop(aqua,11.5f/23.0f, 0.80f,0.80f,0.80f,1.0f);
	TIPGradientAddRGBColorStop(aqua,1.0f,0.77f,0.77f,0.77f,1.0f);
	
	return (TIPGradientRef)aqua;	
}

TIPGradientRef TIPGradientBlackShineCreate( void )
{
	TIPMutableGradientRef blackShine = TIPMutableGradientCreate();
	
	TIPGradientAddRGBColorStop(blackShine,0.0f,0.0f,0.0f,0.0f,1.0f);
	TIPGradientAddRGBColorStop(blackShine,1.0f, 0.0f,0.0f,0.0f,0.3f);
	
	return (TIPGradientRef)blackShine;
}	

TIPMutableGradientRef TIPMutableGradientCreate( void )
{
	return (TIPMutableGradientRef)TIPGradientCreate();
}

void TIPGradientRetain( TIPGradientRef aGradient )
{
	((TIPMutableGradientRef)aGradient)->retainCount++;
}

void TIPGradientRelease( TIPGradientRef aGradient )
{
	((TIPMutableGradientRef)aGradient)->retainCount--;
	if( !aGradient->retainCount ) {
		
		TIPGradientElement *elementToRemove;
		TIPGradientElement *element = aGradient->elementList;
		while( element ) {
			elementToRemove = element;
			element = element->nextElement;
			free( elementToRemove );
		}
		free( (TIPMutableGradientRef)aGradient );
		
	}
}

void TIPGradientSetBlendingMode( TIPMutableGradientRef aGradient, TIPGradientBlendingMode blendingMode )
{
	aGradient->blendingMode = blendingMode;
	
	void *evaluationFunction = NULL;
	switch( aGradient->blendingMode ) {
		case TIPLinearBlendingMode:
			evaluationFunction = &TIPGradientLinearEvaluation;
			break;
		case TIPChromaticBlendingMode:
			evaluationFunction = &TIPGradientChromaticEvaluation;
			break;
		case TIPInverseChromaticBlendingMode:
			evaluationFunction = &TIPGradientInverseChromaticEvaluation;
			break;
		default:
			evaluationFunction = &TIPGradientLinearEvaluation;
			break;
	}
	
	if( aGradient->gradientFunction != NULL )
		CGFunctionRelease(aGradient->gradientFunction);
	
	CGFunctionCallbacks evaluationCallbackInfo = {0, evaluationFunction, NULL};
	
	static const float input_value_range[2] = {0.0f, 1.0f}; // range for the evaluator input
	static const float output_value_ranges[8] = {0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f}; // ranges for the evaluator output
	
	aGradient->gradientFunction = CGFunctionCreate(&(aGradient->elementList),
												   1, input_value_range,
												   4, output_value_ranges,
												   &evaluationCallbackInfo);
}

void TIPGradientAddRGBColorStop( TIPMutableGradientRef aGradient, float position, float red, float green, float blue, float alpha)
{
	TIPGradientElement newElement;
	
	newElement.position = position;
	newElement.red = red;
	newElement.green = green;
	newElement.blue = blue;
	newElement.alpha = alpha;
	
	TIPGradientAddElement(aGradient,&newElement);
}

#pragma mark private gradient functions

void TIPGradientAddElement( TIPMutableGradientRef aGradient, TIPGradientElement *newElement )
{
	if( aGradient->elementList == NULL || newElement->position < aGradient->elementList->position) {
		
		TIPGradientElement *tempElement = aGradient->elementList;
		aGradient->elementList = malloc(sizeof(TIPGradientElement));
		*(aGradient->elementList) = *newElement;
		aGradient->elementList->nextElement = tempElement;
		
	} else {
		TIPGradientElement *currentElement = aGradient->elementList;
		while( currentElement->nextElement != NULL && !((currentElement->position <= newElement->position) && (newElement->position < currentElement->nextElement->position)) )
			currentElement = currentElement->nextElement;
		
		TIPGradientElement *tempElement = currentElement->nextElement;
		currentElement->nextElement = malloc(sizeof(TIPGradientElement));
		*(currentElement->nextElement) = *newElement;
		currentElement->nextElement->nextElement = tempElement;
	}
}

TIPGradientElement* TIPGradientElementAtIndex( TIPMutableGradientRef aGradient, unsigned int anIndex )
{
	unsigned int currentIndex = 0;
	TIPGradientElement *currentElement = aGradient->elementList;
	
	while( currentElement != NULL ) {
		if( currentIndex == anIndex )
			return currentElement;
		
		currentIndex++;
		currentElement = currentElement->nextElement;
	}
	
	return NULL;
}

void TIPGradientRemoveElementAtIndex( TIPMutableGradientRef aGradient, unsigned int anIndex )
{
	TIPGradientElement removedElement;
	
	if( aGradient->elementList == NULL )
		return;
	
	if( anIndex == 0 ) {
		TIPGradientElement *tempElement = aGradient->elementList;
		aGradient->elementList = aGradient->elementList->nextElement;
		removedElement = *tempElement;
		free(tempElement);
		
		return;
	}
	
	unsigned int currentIndex = 1;
	TIPGradientElement *currentElement = aGradient->elementList;
	while( currentElement->nextElement != NULL ) {
		
		if( currentIndex == anIndex ) {
			TIPGradientElement *tempElement = currentElement->nextElement;
			currentElement->nextElement = currentElement->nextElement->nextElement;
			removedElement = *tempElement;
			free( tempElement );
			
			return;
		}
		currentIndex++;
		currentElement = currentElement->nextElement;
	}
	
}

#pragma mark gradient drawing functions

// angle in degrees
void TIPGradientFindEndpointsForRotation( CGRect rect, float angle, CGPoint *startPoint, CGPoint *endPoint)
{
	if(angle == 0) {
		*startPoint = CGPointMake(rect.origin.x, rect.origin.y);	//right of rect
		*endPoint   = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);	//left  of rect
  	} else if(angle == 90) {
		*startPoint = CGPointMake(rect.origin.x, rect.origin.y);	//bottom of rect
		*endPoint   = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);	//top    of rect
  	} else {
		float x,y;
		float sina, cosa, tana;
		
		float length;
		float deltax,
			deltay;
		
		float rangle = angle * pi/180;	//convert the angle to radians
		
		if(fabsf(tan(rangle))<=1)	//for range [-45,45], [135,225]
		{
			x = rect.size.width;
			y = rect.size.height;
			
			sina = sin(rangle);
			cosa = cos(rangle);
			tana = tan(rangle);
			
			length = x/fabsf(cosa)+(y-x*fabsf(tana))*fabsf(sina);
			
			deltax = length*cosa/2;
			deltay = length*sina/2;
		}
		else						//for range [45,135], [225,315]
		{
			x = rect.size.height;
			y = rect.size.width;
			
			sina = sin(rangle - 90*pi/180);
			cosa = cos(rangle - 90*pi/180);
			tana = tan(rangle - 90*pi/180);
			
			length = x/fabsf(cosa)+(y-x*fabsf(tana))*fabsf(sina);
			
			deltax =-length*sina/2;
			deltay = length*cosa/2;
		}
		
		*startPoint = CGPointMake( (rect.origin.x+rect.size.width/2.0f)-deltax, (rect.origin.y+rect.size.height/2.0f)-deltay);
		*endPoint   = CGPointMake( (rect.origin.x+rect.size.width/2.0f)+deltax, (rect.origin.y+rect.size.height/2.0f)+deltay);
	}
}

void TIPGradientAxialFillPath( CGContextRef theContext, TIPGradientRef theGradient, CGPathRef thePath, float angle)
{
	CGRect boundingRect = CGPathGetBoundingBox(thePath);
	CGPoint startPoint;
	CGPoint endPoint;
	
	TIPGradientFindEndpointsForRotation(boundingRect,angle,&startPoint,&endPoint);
	
	// CoreGraphics Calls
	CGContextSaveGState(theContext);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGShadingRef myCGShading = CGShadingCreateAxial(colorSpace,startPoint,endPoint,theGradient->gradientFunction,FALSE,FALSE);
		
		CGContextAddPath(theContext,thePath);
		CGContextClip(theContext);
		CGContextDrawShading(theContext,myCGShading);
		
		CGShadingRelease(myCGShading);
		CGColorSpaceRelease(colorSpace);
	CGContextRestoreGState(theContext);
}

void TIPGradientAxialFillRect( CGContextRef theContext, TIPGradientRef theGradient, CGRect theRect, float angle)
{
	CGPoint startPoint;
	CGPoint endPoint;
	
	TIPGradientFindEndpointsForRotation(theRect,angle,&startPoint,&endPoint);
	
	// CoreGraphics Calls
	CGContextSaveGState(theContext);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGShadingRef myCGShading = CGShadingCreateAxial(colorSpace,startPoint,endPoint,theGradient->gradientFunction,FALSE,FALSE);
		
		CGContextClipToRect(theContext,theRect);
		CGContextDrawShading(theContext,myCGShading);
		
		CGShadingRelease(myCGShading);
		CGColorSpaceRelease(colorSpace);
	CGContextRestoreGState(theContext);
}

void TIPGradientRadialFillRect( CGContextRef theContext, TIPGradientRef theGradient, CGRect theRect, CGPoint center, float radius)
{
	CGPoint startPoint = center;
	CGPoint endPoint = center;
	float startRadius = 1.0f;
	float endRadius = radius;
	
	// CoreGraphics Calls
	CGContextSaveGState(theContext);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		CGShadingRef myCGShading = CGShadingCreateRadial(colorSpace,startPoint,startRadius,endPoint,endRadius,theGradient->gradientFunction,FALSE,FALSE);
		
		CGContextClipToRect(theContext,theRect);
		CGContextDrawShading(theContext,myCGShading);
		
		CGShadingRelease(myCGShading);
		CGColorSpaceRelease(colorSpace);
	CGContextRestoreGState(theContext);	
}

#pragma mark Core Graphics
//////////////////////////////////////Blending Functions/////////////////////////////////////
void TIPGradientLinearEvaluation (void *info, const float *in, float *out)
{
	float position = *in;
	
	if(*(TIPGradientElement **)info == NULL)	//if elementList is empty return clear color
	{
		out[0] = out[1] = out[2] = out[3] = 1;
		return;
	}
	
	//This grabs the first two colors in the sequence
	TIPGradientElement *color1 = *(TIPGradientElement **)info;
	TIPGradientElement *color2 = color1->nextElement;
	
	//make sure first color and second color are on other sides of position
	while(color2 != nil && color2->position < position)
  	{
		color1 = color2;
		color2 = color1->nextElement;
  	}
	//if we don't have another color then make next color the same color
	if(color2 == nil)
    {
		color2 = color1;
    }
	
	//----------FailSafe settings----------
	//color1->red   = 1; color2->red   = 0;
	//color1->green = 1; color2->green = 0;
	//color1->blue  = 1; color2->blue  = 0;
	//color1->alpha = 1; color2->alpha = 1;
	//color1->position = .5;
	//color2->position = .5;
	//-------------------------------------
	
	if(position <= color1->position)			//Make all below color color1's position equal to color1
  	{
		out[0] = color1->red; 
		out[1] = color1->green;
		out[2] = color1->blue;
		out[3] = color1->alpha;
  	}
	else if (position >= color2->position)	//Make all above color color2's position equal to color2
  	{
		out[0] = color2->red; 
		out[1] = color2->green;
		out[2] = color2->blue;
		out[3] = color2->alpha;
  	}
	else										//Interpolate color at postions between color1 and color1
  	{
		//adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position 
		position = (position-color1->position)/(color2->position - color1->position);
		
		out[0] = (color2->red   - color1->red  )*position + color1->red; 
		out[1] = (color2->green - color1->green)*position + color1->green;
		out[2] = (color2->blue  - color1->blue )*position + color1->blue;
		out[3] = (color2->alpha - color1->alpha)*position + color1->alpha;
  	}
}




//Chromatic Evaluation - 
//	This blends colors by their Hue, Saturation, and Value(Brightness) right now I just 
//	transform the RGB values stored in the CTGradientElements to HSB, in the future I may
//	streamline it to avoid transforming in and out of HSB colorspace *for later*
//
//	For the chromatic blend we shift the hue of color1 to meet the hue of color2. To do
//	this we will add to the hue's angle (if we subtract we'll be doing the inverse
//	chromatic...scroll down more for that). All we need to do is keep adding to the hue
//  until we wrap around the colorwheel and get to color2.
void TIPGradientChromaticEvaluation(void *info, const float *in, float *out)
{
	float position = *in;
	
	if(*(TIPGradientElement **)info == NULL)	//if elementList is empty return clear color
	{
		out[0] = out[1] = out[2] = out[3] = 1;
		return;
	}
	
	//This grabs the first two colors in the sequence
	TIPGradientElement *color1 = *(TIPGradientElement **)info;
	TIPGradientElement *color2 = color1->nextElement;
	
	float c1[4];
	float c2[4];
    
	//make sure first color and second color are on other sides of position
	while(color2 != nil && color2->position < position)
  	{
		color1 = color2;
		color2 = color1->nextElement;
  	}
	//if we don't have another color then make next color the same color
	if(color2 == nil)
    {
		color2 = color1;
    }
	
	
	c1[0] = color1->red; 
	c1[1] = color1->green;
	c1[2] = color1->blue;
	c1[3] = color1->alpha;
	
	c2[0] = color2->red; 
	c2[1] = color2->green;
	c2[2] = color2->blue;
	c2[3] = color2->alpha;
	
	TIPGradientTransformRGB_HSV(c1);
	TIPGradientTransformRGB_HSV(c2);
	TIPGradientResolveHSV(c1,c2);
	
	if(c1[0] > c2[0]) //if color1's hue is higher than color2's hue then 
		c2[0] += 360;	//	we need to move c2 one revolution around the wheel
	
	
	if(position <= color1->position)			//Make all below color color1's position equal to color1
  	{
		out[0] = c1[0]; 
		out[1] = c1[1];
		out[2] = c1[2];
		out[3] = c1[3];
  	}
	else if (position >= color2->position)	//Make all above color color2's position equal to color2
  	{
		out[0] = c2[0]; 
		out[1] = c2[1];
		out[2] = c2[2];
		out[3] = c2[3];
  	}
	else										//Interpolate color at postions between color1 and color1
  	{
		//adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position 
		position = (position-color1->position)/(color2->position - color1->position);
		
		out[0] = (c2[0] - c1[0])*position + c1[0]; 
		out[1] = (c2[1] - c1[1])*position + c1[1];
		out[2] = (c2[2] - c1[2])*position + c1[2];
		out[3] = (c2[3] - c1[3])*position + c1[3];
  	}
    
	TIPGradientTransformHSV_RGB(out);
	
	//if(position > -1 && out[0] == out[1] && out[1] == out[2]  && out[0]==0)
	//printf("%.4f: %.4f,%.4f,%.4f\n",position,out[0],out[1],out[2]);
	//printf("%.4f: %.4f,%.4f,%.4f\n",position,color1->red,color1->green,color1->blue);
}



//Inverse Chromatic Evaluation - 
//	Inverse Chromatic is about the same story as Chromatic Blend, but here the Hue
//	is strictly decreasing, that is we need to get from color1 to color2 by decreasing
//	the 'angle' (i.e. 90º -> 180º would be done by subtracting 270º and getting -180º...
//	which is equivalent to 180º mod 360º
void TIPGradientInverseChromaticEvaluation(void *info, const float *in, float *out)
{
    float position = *in;
	
	if(*(TIPGradientElement **)info == NULL)	//if elementList is empty return clear color
	{
		out[0] = out[1] = out[2] = out[3] = 1;
		return;
	}
	
	//This grabs the first two colors in the sequence
	TIPGradientElement *color1 = *(TIPGradientElement **)info;
	TIPGradientElement *color2 = color1->nextElement;
	
	float c1[4];
	float c2[4];
	
	//make sure first color and second color are on other sides of position
	while(color2 != nil && color2->position < position)
  	{
		color1 = color2;
		color2 = color1->nextElement;
  	}
	//if we don't have another color then make next color the same color
	if(color2 == nil)
    {
		color2 = color1;
    }
	
	c1[0] = color1->red; 
	c1[1] = color1->green;
	c1[2] = color1->blue;
	c1[3] = color1->alpha;
	
	c2[0] = color2->red; 
	c2[1] = color2->green;
	c2[2] = color2->blue;
	c2[3] = color2->alpha;
	
	TIPGradientTransformRGB_HSV(c1);
	TIPGradientTransformRGB_HSV(c2);
	TIPGradientResolveHSV(c1,c2);
	
	if(c1[0] < c2[0]) //if color1's hue is higher than color2's hue then 
		c1[0] += 360;	//	we need to move c2 one revolution back on the wheel
	
	
	if(position <= color1->position)			//Make all below color color1's position equal to color1
  	{
		out[0] = c1[0]; 
		out[1] = c1[1];
		out[2] = c1[2];
		out[3] = c1[3];
  	}
	else if (position >= color2->position)	//Make all above color color2's position equal to color2
  	{
		out[0] = c2[0]; 
		out[1] = c2[1];
		out[2] = c2[2];
		out[3] = c2[3];
  	}
	else										//Interpolate color at postions between color1 and color1
  	{
		//adjust position so that it goes from 0 to 1 in the range from color 1 & 2's position 
		position = (position-color1->position)/(color2->position - color1->position);
		
		out[0] = (c2[0] - c1[0])*position + c1[0]; 
		out[1] = (c2[1] - c1[1])*position + c1[1];
		out[2] = (c2[2] - c1[2])*position + c1[2];
		out[3] = (c2[3] - c1[3])*position + c1[3];
  	}
    
	TIPGradientTransformHSV_RGB(out);
}










void TIPGradientTransformRGB_HSV(float *components) //H,S,B -> R,G,B
{
	float H = 0.0f;
	float S = 0.0f;
	float V = 0.0f;
	float R = components[0],
		G = components[1],
		B = components[2];
	
	float MAX = R > G ? (R > B ? R : B) : (G > B ? G : B),
		MIN = R < G ? (R < B ? R : B) : (G < B ? G : B);
	
	if(MAX == MIN)
		H = NAN;
	else if(MAX == R)
		if(G >= B)
			H = 60*(G-B)/(MAX-MIN)+0;
		else
			H = 60*(G-B)/(MAX-MIN)+360;
	else if(MAX == G)
		H = 60*(B-R)/(MAX-MIN)+120;
	else if(MAX == B)
		H = 60*(R-G)/(MAX-MIN)+240;
	
	S = MAX == 0 ? 0 : 1 - MIN/MAX;
	V = MAX;
	
	components[0] = H;
	components[1] = S;
	components[2] = V;
}

void TIPGradientTransformHSV_RGB(float *components) //H,S,B -> R,G,B
{
	float R = 0.0f;
	float G = 0.0f;
	float B = 0.0f;
	float H = fmodf(components[0],359),	//map to [0,360)
		S = components[1],
		V = components[2];
	
	int   Hi = (int)floorf(H/60.) % 6;
	float f  = H/60-Hi,
		p  = V*(1-S),
		q  = V*(1-f*S),
		t  = V*(1-(1-f)*S);
	
	switch (Hi)
	{
		case 0:	R=V;G=t;B=p;	break;
		case 1:	R=q;G=V;B=p;	break;
		case 2:	R=p;G=V;B=t;	break;
		case 3:	R=p;G=q;B=V;	break;
		case 4:	R=t;G=p;B=V;	break;
		case 5:	R=V;G=p;B=q;	break;
	}
	
	components[0] = R;
	components[1] = G;
	components[2] = B;
	}

void TIPGradientResolveHSV(float *color1, float *color2)	//H value may be undefined (i.e. graycale color)
{											//	we want to fill it with a sensible value
	if(isnan(color1[0]) && isnan(color2[0]))
		color1[0] = color2[0] = 0;
	else if(isnan(color1[0]))
		color1[0] = color2[0];
	else if(isnan(color2[0]))
		color2[0] = color1[0];
}
