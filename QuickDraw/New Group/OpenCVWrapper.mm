//
//  OpenCVWrapper.m
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/2/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

// Add any imports here:

#include <stdlib.h>
#include "math.h"

#import <opencv2/opencv.hpp>
#import <opencv2/features2d/features2d.hpp>
#import "OpenCVWrapper.h" // THIS MUST BE THE LAST IMPORT LINE

using namespace std;
using namespace cv;

@implementation OpenCVWrapper {
    Ptr <AKAZE> orb;
    FlannBasedMatcher matcher;
}

- (id) init {
    self = [super init];
    
    self->orb = AKAZE::create();
    self->matcher = FlannBasedMatcher(new cv::flann::LshIndexParams(5, 24, 2));

    return self;
}

-(NSString *) openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

- (UIImage *) test_dt: (UIImage *) input {
    Mat processed = [OpenCVWrapper threshold: [OpenCVWrapper convert: [OpenCVWrapper gray: input]]];
    Mat distances = processed.clone();
    distances = [OpenCVWrapper fix_distances: distances iteration: 0];
    
    return [OpenCVWrapper convert_back: distances];
}

- (int) score: (UIImage *) inputImg to: (UIImage *) targetImg {
    UIImage* processedInputImg = [self process: targetImg to: inputImg];
    
    Mat input = [OpenCVWrapper threshold: [OpenCVWrapper convert: [OpenCVWrapper gray: processedInputImg]]];
    Mat target = [OpenCVWrapper threshold: [OpenCVWrapper convert: [OpenCVWrapper gray: targetImg]]];
    
    int a = [OpenCVWrapper hausdorff: input to: target];
    int b = [OpenCVWrapper hausdorff: target to: input];

    printf("    scores were %d and %d\n", a, b);
    return MAX(a, b);
}

+ (int) hausdorff: (Mat) test to: (Mat) reference_img {
    
    Mat distances = reference_img.clone();
    distances = [OpenCVWrapper fix_distances: distances iteration: 0];
 
    int current_max = 0;
    
    for (int j = 0; j < test.cols; j++) {
        for (int i = 0; i < test.rows; i++) {
            if (test.at<uchar>(i, j) == 0) {
                int x = int((float(i) / test.rows) * distances.rows);
                int y = int((float(j) / test.cols) * distances.cols);
                
                current_max = MAX(current_max, distances.at<uchar>(x, y));
            }
        }
    }
    
    return current_max;
}

- (UIImage *) process: (UIImage *) target_img to: (UIImage *) input_img {
    
    // gray out, convert, and threshold both images
    Mat target = [OpenCVWrapper threshold: [OpenCVWrapper convert: [OpenCVWrapper gray: target_img]]];
    Mat input = [OpenCVWrapper threshold: [OpenCVWrapper convert: [OpenCVWrapper gray: input_img]]];

    input = [OpenCVWrapper shift: target to: input];
    input = [OpenCVWrapper scale: target to: input];
    
    return [OpenCVWrapper convert_back: input];
}

/* ------------------------------- Below here are top-level helper methods -------------------------------*/

+ (cv::Mat) shift: (cv::Mat) target to: (cv::Mat) input {
    int* target_center = [OpenCVWrapper get_center: target];
    int* input_center = [OpenCVWrapper get_center: input];

    float target_percent_x = (float(target_center[0]) / target.rows);
    float input_percent_x = (float(input_center[0]) / input.rows);

    float target_percent_y = (float(target_center[1]) / target.cols);
    float input_percent_y = (float(input_center[1]) / input.cols);
    
    int move_x = int((target_percent_x - input_percent_x) * input.rows);
    int move_y = int((target_percent_y - input_percent_y) * input.cols);
    
    Mat translated(input.size(), input.type());
    for (int j = 0; j < translated.cols; j++) {
        for (int i = 0; i < translated.rows; i++) {
            int new_x = i - move_x;
            int new_y = j - move_y;
            if (new_x >= 0 && new_x < input.rows && new_y >= 0 && new_y < input.cols) {
                translated.at<uchar>(i, j) = input.at<uchar>(new_x, new_y);
            } else {
                translated.at<uchar>(i, j) = 255;
            }
        }
    }
    
    return translated;
}

+ (cv::Mat) scale: (cv::Mat) target to: (cv::Mat) input {
    int* target_center = [OpenCVWrapper get_center: target];
    int* input_center = [OpenCVWrapper get_center: input];
    
    float avg_target_distance = [OpenCVWrapper get_distance: target with_center: target_center];
    float avg_input_distance = [OpenCVWrapper get_distance: input with_center: input_center];
    float target_diagonal = sqrt(target.rows * target.rows + target.cols * target.cols);
    float input_diagonal = sqrt(input.rows * input.rows + input.cols * input.cols);
    
    if (avg_input_distance == 0 || target_diagonal == 0) return input;
    float desired_input_distance = avg_target_distance * input_diagonal / target_diagonal;
    if (desired_input_distance == 0) return input;
    
    float scale_factor = desired_input_distance / avg_input_distance;
    
    Mat scaled(input.size(), input.type());
    for (int j = 0; j < input.cols; j++) {
        for (int i = 0; i < input.rows; i++) {
            int loc[] = {i, j};
            int* pos = [OpenCVWrapper get_pos: loc factor: scale_factor input_center: input_center];
            
            if (pos[0] >= 0 && pos[0] < input.rows && pos[1] >= 0 && pos[1] < input.cols) {
                scaled.at<uchar>(i, j) = input.at<uchar>(pos[0], pos[1]);
            } else {
                scaled.at<uchar>(i, j) = 255;
            }
        }
    }

    return scaled;
}

/* ------------------------------- Below here are mid-level helper methods -------------------------------*/

+ (int*) get_pos: (int*) loc factor: (float) factor input_center: (int*) input_center {
    int offset_x = loc[0] - input_center[0];
    float new_offset_x = offset_x / factor;
    
    int offset_y = loc[1] - input_center[1];
    float new_offset_y = offset_y / factor;
    
    int* answer = new int[2];
    answer[0] = input_center[0] + int(new_offset_x);
    answer[1] = input_center[1] + int(new_offset_y);
    return answer;
}

+ (float) get_distance: (Mat) matrix with_center: (int*) center {
    float total_distance = 0;
    int total_count = 0;
    
    for (int j = 0; j < matrix.cols; j++) {
        for (int i = 0; i < matrix.rows; i++) {
            if (matrix.at<uchar>(i, j) == 0) {
                total_count++;
                int x_offset = (center[0] - i);
                int y_offset = (center[1] - j);
                total_distance += sqrt(x_offset * x_offset + y_offset * y_offset);
            }
        }
    }
    
    if (total_count != 0) {
        total_distance /= total_count;
    }
    
    return total_distance;
}

+ (int *) get_center: (Mat) input {
    float total_x = 0;
    int count_x = 0;
    
    float total_y = 0;
    int count_y = 0;
    
    for (int j = 0; j < input.cols; j++) {
        for (int i = 0; i < input.rows; i++) {
            if (input.at<uchar>(i, j) == 0) {
                total_x += i;
                total_y += j;
                count_y++;
                count_x++;
            }
        }
    }
    
    if (count_x != 0) {
        total_x /= count_x;
    }
    
    if (count_y != 0) {
        total_y /= count_y;
    }
    
    int* answer = new int[2];
    answer[0] = int(total_x);
    answer[1] = int(total_y);
    return answer;
}

/* ------------------------------- Below here are bottom-level helper methods -------------------------------*/

+ (Mat) fix_distances: (Mat) distances iteration: (int) iteration {
    if (iteration == 50) {
        return distances;
    } else {
        Mat next = distances.clone();
        
        for (int j = 0; j < distances.cols; j++) {
            for (int i = 0; i < distances.rows; i++) {
                if (distances.at<uchar>(i, j) == iteration) {
                    // TODO the pixels around us may need to be updated
                    NSArray* points = [NSArray arrayWithObjects:
                                       [NSValue valueWithCGPoint:CGPointMake(i - 1, j)],
                                       [NSValue valueWithCGPoint:CGPointMake(i + 1, j)],
                                       [NSValue valueWithCGPoint:CGPointMake(i, j - 1)],
                                       [NSValue valueWithCGPoint:CGPointMake(i, j + 1)],
                                       nil];
                    
                    for (int i = 0; i < 4; i++) {
                        NSValue *val = [points objectAtIndex: i];
                        CGPoint p = [val CGPointValue];
                        
                        if (p.x >= 0 && p.x < distances.rows && p.y >= 0 && p.y < distances.cols) {
                            if (distances.at<uchar>(int(p.x), int(p.y)) > iteration + 1) {
                                next.at<uchar>(int(p.x), int(p.y)) = iteration + 1;
                            }
                        }
                    }
                }
            }
        }
        
        // we've updated the whole array
        return [OpenCVWrapper fix_distances: next iteration: iteration + 1];
    }
}

+ (int) bfs: (Mat) img atx: (int) x aty: (int) y iter: (int) depth set: (NSMutableSet*) set {
    if (depth > 10 || img.at<uchar>(x, y) == 0) {
        return depth;
    } else {
        NSMutableArray* next = [NSMutableArray new];
        NSMutableArray* next_vals = [NSMutableArray new];
        NSArray* points = [NSArray arrayWithObjects:
                           [NSValue valueWithCGPoint:CGPointMake(x - 1, y)],
                           [NSValue valueWithCGPoint:CGPointMake(x + 1, y)],
                           [NSValue valueWithCGPoint:CGPointMake(x, y - 1)],
                           [NSValue valueWithCGPoint:CGPointMake(x, y + 1)],
                           nil];
        
        for (int i = 0; i < 4; i++) {
            NSValue *val = [points objectAtIndex: i];
            CGPoint p = [val CGPointValue];
            
            if (p.x >= 0 && p.x < img.rows && p.y >= 0 && p.y < img.cols && ![set containsObject: val]) {
                [next addObject: val];
            }
        }
        
        for (int i = 0; i < [next count]; i++) {
            NSValue *val = [next objectAtIndex: i];
            CGPoint p = [val CGPointValue];
            
            NSMutableSet* new_set = [NSMutableSet setWithSet: set];
            [new_set addObject: val];
            
            int returned = [OpenCVWrapper bfs: img atx: int(p.x) aty: int(p.y) iter: depth + 1 set: new_set];
            NSNumber* wrap = [NSNumber numberWithInt: returned];
            [next_vals addObject: wrap];
        }
        
        int best_val = 20;
        for (int i = 0; i < [next_vals count]; i++) {
            NSNumber* wrap = [next_vals objectAtIndex: i];
            int this_val = int([wrap integerValue]);
            if (this_val < best_val) {
                best_val = this_val;
            }
        }
        
        return best_val;
    }
    
}

+ (Mat) threshold: (Mat) image {
    Mat output(image.size(), image.type());
    
    for (int j = 0; j < image.cols; j++) {
        for (int i = 0; i < image.rows; i++) {
            if (image.at<uchar>(i, j) < 230) {
                output.at<uchar>(i, j) = 0;
            } else {
                output.at<uchar>(i, j) = 255;
            }
        }
    }
    
    return output;
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

+ (UIImage*) fromCVMat:(const cv::Mat&)cvMat
{
    // (1) Construct the correct color space
    CGColorSpaceRef colorSpace;
    if ( cvMat.channels() == 1 ) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    // (2) Create image data reference
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, cvMat.data, (cvMat.elemSize() * cvMat.total()));
    
    // (3) Create CGImage from cv::Mat container
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols,
                                        cvMat.rows,
                                        8,
                                        8 * cvMat.elemSize(),
                                        cvMat.step[0],
                                        colorSpace,
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    // (4) Create UIImage from CGImage
    UIImage * finalImage = [UIImage imageWithCGImage:imageRef];
    
    // (5) Release the references
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CFRelease(data);
    CGColorSpaceRelease(colorSpace);
    
    // (6) Return the UIImage instance
    return finalImage;
}

+ (UIImage *) convert_back: (Mat) cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        // OpenCV defaults to either BGR or ABGR. In CoreGraphics land,
        // this means using the "32Little" byte order, and potentially
        // skipping the first pixel. These may need to be adjusted if the
        // input matrix uses a different pixel format.
        bitmapInfo = kCGBitmapByteOrder32Little | (
                                                   cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
                                                   );
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(
                                        cvMat.cols,                 //width
                                        cvMat.rows,                 //height
                                        8,                          //bits per component
                                        8 * cvMat.elemSize(),       //bits per pixel
                                        cvMat.step[0],              //bytesPerRow
                                        colorSpace,                 //colorspace
                                        bitmapInfo,                 // bitmap info
                                        provider,                   //CGDataProviderRef
                                        NULL,                       //decode
                                        false,                      //should interpolate
                                        kCGRenderingIntentDefault   //intent
                                        );
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

/* ------------------------------- Below here are failed similarity attempts -------------------------------*/


- (int) old_score: (UIImage *) inputOne to: (UIImage *) inputTwo {
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
        if (matches[i].size() >= 2) {
            if (matches[i][0].distance < matches[i][1].distance * 0.9) {
                goodMatches.push_back(matches[i][0]);
            }
        }
    }
    
    return ((int) goodMatches.size());
}


@end
