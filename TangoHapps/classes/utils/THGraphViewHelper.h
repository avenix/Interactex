//
//  THGraphViewHelper.h
//  TangoHapps
//
//  Created by Juan Haladjian on 11/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

// Functions used to draw all content

#ifndef GRAPH_VIEW_HELPER
#define GRAPH_VIEW_HELPER

extern CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);

extern CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);

extern CGColorRef graphBackgroundColor();

extern CGColorRef graphLineColor();

extern CGColorRef graphXColor();

extern CGColorRef graphYColor();

extern CGColorRef graphZColor();

//must call strokeLinez afterwards
extern void DrawHorizontalLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat width);

extern void StrokeLines(CGContextRef context);

#endif