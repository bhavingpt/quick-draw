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

-(NSString *) openCVVersionString;
- (int) score: (UIImage *)inputOne to: (UIImage *) inputTwo;

@end
