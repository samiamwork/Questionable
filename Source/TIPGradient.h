/*
 *  TIPGradient.h
 *  TIPBox
 *
 *  Created by Nur Monson on 10/31/06.
 *  Copyright 2006 theidiotproject. All rights reserved.
 *
 */
#ifndef __TIPGradient_h__
#define __TIPGradient_h__

#include <Carbon/Carbon.h>
//#include <QuartzCore/QuartzCore.h>

// gradient functions
typedef struct TIPGradient *TIPMutableGradientRef;
typedef const struct TIPGradient *TIPGradientRef;

typedef enum _TIPGradientBlendingMode
{
	TIPLinearBlendingMode,
	TIPChromaticBlendingMode,
	TIPInverseChromaticBlendingMode
} TIPGradientBlendingMode;

TIPGradientRef TIPGradientCreate( void );
TIPMutableGradientRef TIPMutableGradientCreate( void );
void TIPGradientRetain( TIPGradientRef aGradient );
void TIPGradientRelease( TIPGradientRef aGradient );
void TIPGradientSetBlendingMode( TIPMutableGradientRef aGradient, TIPGradientBlendingMode blendingMode );
void TIPGradientAddRGBColorStop( TIPMutableGradientRef aGradient, float position, float red, float green, float blue, float alpha);

void TIPGradientAxialFillPath( CGContextRef theContext, TIPGradientRef theGradient, CGPathRef thePath, float angle);
void TIPGradientAxialFillRect( CGContextRef theContext, TIPGradientRef theGradient, CGRect theRect, float angle);
void TIPGradientRadialFillRect( CGContextRef theContext, TIPGradientRef theGradient, CGRect theRect, CGPoint center, float radius);

//untility functions
TIPGradientRef TIPGradientAquaCreate( void );
TIPGradientRef TIPGradientAquaSelectedCreate( void );
TIPGradientRef TIPGradientAquaPressedCreate( void );

TIPGradientRef TIPGradientBlackShineCreate( void );

#endif
