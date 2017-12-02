//
//  OpenCVWrapper.m
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/2/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

// Add any imports here:

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h" // THIS MUST BE THE LAST IMPORT LINE

@implementation OpenCVWrapper

-(NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end
