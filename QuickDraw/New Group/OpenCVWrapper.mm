//
//  OpenCVWrapper.m
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/2/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

// Add any imports here:

#include <stdlib.h>

#import <opencv2/opencv.hpp>
#import <opencv2/features2d/features2d.hpp>
#import "OpenCVWrapper.h" // THIS MUST BE THE LAST IMPORT LINE

using namespace std;
using namespace cv;

@implementation OpenCVWrapper {
    Ptr <ORB> orb;
    FlannBasedMatcher matcher;
}

- (id) init {
    self = [super init];
    
    self->orb = ORB::create();
    self->matcher = FlannBasedMatcher(new cv::flann::LshIndexParams(5, 24, 2));

    return self;
}

-(NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

- (int) score: (UIImage *) inputOne to: (UIImage *) inputTwo {
    UIImage* inputGray = [OpenCVWrapper gray: inputOne];
    UIImage* testGray = [OpenCVWrapper gray: inputTwo];
    
    Mat input = [OpenCVWrapper convert: inputGray];
    Mat test = [OpenCVWrapper convert:testGray];
    
    vector<KeyPoint> keyInput, keyTest;
    Mat desInput, desTest;
    
    self->orb->detectAndCompute(input, cv::Mat(), keyInput, desInput);
    self->orb->detectAndCompute(test, cv::Mat(), keyTest, desTest);
    
    vector<DMatch> goodMatches;
    vector<vector<DMatch>> matches;
    
    self->matcher.knnMatch(desInput, desTest, matches, 2);
    // Second neighbor ratio test.
    for (unsigned int i = 0; i < matches.size(); ++i) {
        if (matches[i][0].distance < matches[i][1].distance * 0.75)
            goodMatches.push_back(matches[i][0]);
    }
    
    return ((int) goodMatches.size());
}

+ (UIImage *) gray: (UIImage *)image {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil,image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly );
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithMask(imageRef, mask)];
    CGImageRelease(imageRef);
    CGImageRelease(mask);
    
    // Return the new grayscale image
    return newImage;
}

+ (cv::Mat) convert: (UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    
    // check whether the UIImage is greyscale already
    if (numberOfComponents == 1){
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,             // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo);              // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

@end
