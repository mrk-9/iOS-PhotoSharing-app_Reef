//
//  RootViewController.h
//  pictureProcess
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <UIKit/UIKit.h>

@interface ImageUtil : NSObject 

+ (UIImage *)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*)f;


@end
