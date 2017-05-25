//
//  PhotosTool.h
//  AppDemo-sqz
//
//  Created by 清正 on 16/9/19.
//  Copyright © 2016年 HSG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PermissionTool.h"

@interface PhotosTool : NSObject


/**
 * 包含该张图片的所有属性(iOS8以下是ALAsset对象,以上是PHAsset对象)
 */
@property (nonatomic, strong)id asset;

/**
 * 略缩图
 */
@property (nonatomic, strong)UIImage *lowerImage;

/**
 * 作者:  sqz
 * 使用条件: 必须有获取照片的权限
 * 作用:  获取图库里的所有照片
 * 参数1(返回值): block 图片数组<PhotosTool>
 */
+ (void)visitPhotosLowerImage:(void (^)(NSMutableArray<PhotosTool *> *photos))block;
/**
 * 作者:  sqz
 * 作用:  根据Asset的对象获取原始照片
 * 参数1(返回值): block 原始照片
 */
- (void)getHighImageWithAsset:(void (^)(UIImage *higtImage))block;
/**
 * 作者:sqz
 * 作用: 删除相册中的照片
 * 参数1(返回值): block 成功:YES  否则NO:返回错误记过
 */
-(void)deletePhontsImage:(void (^)(BOOL success, NSError *error))block;
/**
 * 作者:sqz
 * 作用: 新建建相册
 * 参数1: 相册名称
 * 返回: 该相册对象
 */
+ (PHAssetCollection *)creactNewPhotosGroupWinthName:(NSString *)name;

/**
 * 作者:sqz
 * 作用: 保存图片到系统相册(只适用于iOS8及其以上)
 * 参数1: 图片
 * 参数2: 相册对象(nil:系统默认的相册)
 * 参数2(返回值): 成功/失败
 */
+ (void)saveImage:(UIImage *)image toCollection:(PHAssetCollection*)collection completionBlock:(void (^)(BOOL success, NSError *error))block;
@end
