//
//  CVWrapper.m
//  WordbaseSolver
//
//  Created by Sheng Loong Su on 3/1/17.
//  Copyright © 2017 Su Sheng Loong. All rights reserved.
//
//http://bcdilumonline.blogspot.sg/2014/07/getting-started-with-opencv-in-ios.html
//https://jkbdev.wordpress.com/2015/09/22/getting-started-with-opencv-on-ios/

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

using namespace std;

@implementation OpenCVWrapper
+(UIImage *) convertImage:(UIImage *) image {
    cv::Mat originalMat = [self cvMatFromUIImage:image];
    cv::Mat grayMat;
    cv::cvtColor(originalMat, grayMat, CV_BGR2GRAY);
    cv::threshold(grayMat, grayMat, 1, 255, 0);
    
    vector<vector<cv::Point>> contours;
    vector<cv::Vec4i> hierarchy;
    
    cv::Mat contourMat = grayMat.clone();
    cv::findContours(contourMat, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    
    for (int i = 0; i < contours.size(); i++) {
        vector<cv::Point> cnt = contours[i];
        double area = cv::contourArea(cnt);
        if (area > 3000) {
            cv::Rect rect = cv::boundingRect(contours[i]);
            cv::bitwise_not(grayMat(rect), grayMat(rect));
        }
    }
    
//    cv::Mat element = cv::getStructuringElement(cv::MORPH_CROSS, cv::Size(5, 5), cv::Point(5, 5) );
//    cv::erode(grayMat, grayMat, element);
    
//    cv::bitwise_not(grayMat, grayMat);
    
    return [self UIImageFromCVMat:grayMat];
}
    
+(cv::Mat)cvMatFromUIImage:(UIImage*)image{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,     // Pointer to data
                                                    cols,           // Width of bitmap
                                                    rows,           // Height of bitmap
                                                    8,              // Bits per component
                                                    cvMat.step[0],  // Bytes per row
                                                    colorSpace,     // Color space
                                                    kCGImageAlphaNoneSkipLast
                                                    | kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}
    
+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGColorSpaceRef colorspace;
    
    if (cvMat.elemSize() == 1) {
        colorspace = CGColorSpaceCreateDeviceGray();
    }else{
        colorspace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Create CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols, cvMat.rows, 8, 8 * cvMat.elemSize(), cvMat.step[0], colorspace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    
    // get uiimage from cgimage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorspace);
    return finalImage;
}
@end
