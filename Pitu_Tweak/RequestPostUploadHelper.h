//
//  RequestPostUploadHelper.h
//  Pitu_Tweak
//
//  Created by zj-dt0094 on 16/3/7.
//
//

#ifndef RequestPostUploadHelper_h
#define RequestPostUploadHelper_h

//
//  RequestPostUploadHelper.h
//  demodes
//
//  Created by 张浩 on 13-5-8.
//  Copyright (c) 2013年 张浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RequestPostUploadHelper : NSObject

/**
 *POST 提交 并可以上传图片目前只支持单张
 */
+ (NSData *)postRequestWithURL: (NSString *)url  // IN
                      postParems: (NSMutableDictionary *)postParems // IN 提交参数据集合
                     picFilePath: (NSString *)picFilePath  // IN 上传图片路径
                     picFileName: (NSString *)picFileName;  // IN 上传图片名称

/**
 * 修发图片大小
 */
+ (UIImage *) imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize) newSize;
/**
 * 保存图片
 */
+ (NSString *)saveImage:(UIImage *)tempImage WithPath:(NSString *)filePath WithName:(NSString *)imageName;
/**
 * 生成GUID
 */
+ (NSString *)generateUuidString;



@end



#endif /* RequestPostUploadHelper_h */
