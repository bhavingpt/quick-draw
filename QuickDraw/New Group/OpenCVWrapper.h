//
//  OpenCVWrapper.h
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/2/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

// methods for use

- (NSString *) openCVVersionString;
- (int) score: (UIImage *) inputImg to: (UIImage *) targetImg;

// methods for debugging

- (int) hausdorff_wrap: (UIImage *) test to: (UIImage *) reference_img;
- (UIImage *) process: (UIImage *) target_img to: (UIImage *) input_img;


@end
