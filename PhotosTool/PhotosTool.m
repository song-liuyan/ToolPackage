//
//  PhotosTool.m
//  AppDemo-sqz
//
//  Created by 清正 on 16/9/19.
//  Copyright © 2016年 HSG. All rights reserved.
//

#import "PhotosTool.h"

@implementation PhotosTool

+ (void)visitPhotosLowerImage:(void (^)(NSMutableArray<PhotosTool *> *photos))block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//    PHAssetCollectionSubtypeAlbumSyncedAlbum 视屏
    PHAssetCollection *cameraRoll =[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    if (!cameraRoll) {
        block(nil);
        return;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    //设置为异步还是同步，默认是异步
    options.synchronous = NO;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
    //创建缓存管理器
    PHCachingImageManager *caching = [[PHCachingImageManager alloc] init];
    NSMutableArray *lowerImage =[NSMutableArray array];
    __block NSInteger count =0;
    for (PHAsset *asset in assets) {
        if (asset.mediaType ==PHAssetMediaTypeImage) {
            //获取低质量图片
            [caching requestImageForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result) {
                    //添加缩略图
                    PhotosTool *tool =[[PhotosTool alloc]init];
                    tool.asset =asset;
                    tool.lowerImage =result;
                    [lowerImage addObject:tool];
                } else {
                    block(lowerImage);
                }
                if (count ==assets.count-1) {
                    block(lowerImage);
                }
                count ++;
            }];
        } else {
            count ++;
        }
    }
#else
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *lowerImages =[NSMutableArray array];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group && stop) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *sstop) {
                if (result) {
                    NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto]) {
                        
                        CGImageRef ref = [result thumbnail];
                        UIImage *img = [UIImage imageWithCGImage:ref];
                        PhotosTool *tool =[[PhotosTool alloc]init];
                        tool.asset =result;
                        tool.lowerImage =img;
                        [lowerImages addObject:tool];
                    }
                } else {
                    block(lowerImages);
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"获取图片失败:%@", error);
        block(nil);
    }];
#endif
}
//获取高清图片
- (void)getHighImageWithAsset:(void (^)(UIImage *higtImage))block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    PHAsset *asset =nil;
    if (!self.asset) {
        block(nil);
        return;
    } else {
        asset =self.asset;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    //必须同步,否则有些照片获取不到.
    options.synchronous = YES;
    PHCachingImageManager *caching = [[PHCachingImageManager alloc] init];
    //图片的原始尺寸
    CGSize sizeOne = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    [caching requestImageForAsset:asset targetSize:sizeOne contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([NSStringFromCGSize(result.size) isEqualToString:NSStringFromCGSize(sizeOne)]) {
            block(result);
        }
    }];
#else
    ALAsset *asset =nil;
    if (!self.asset) {
        block(nil);
        return;
    } else {
        asset =self.asset;
    }
    ALAssetRepresentation *representation =[asset defaultRepresentation];
    //获取高清图片
    CGImageRef ref = [representation fullResolutionImage];
    UIImage *img = [UIImage imageWithCGImage:ref];
    block(img);
#endif
}
//删除该张照片
-(void)deletePhontsImage:(void (^)(BOOL success, NSError *error))block {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    PHAsset *asset =nil;
    if (!self.asset) {
        return;
    }  else {
        asset =self.asset;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(success, error);
            if (error) {
                NSLog(@"删除照片错误:%@", error);
            }
        });        
    }];
#else
    ALAsset *asset =nil;
    if (!self.asset) {
        return;
    } else {
        asset =self.asset;
    }
    [asset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            block(NO, error);
            NSLog(@"删除错误:%@", error);
        } else {
            block(YES, error);
        }
    }];
#endif
}

+ (PHAssetCollection *)creactNewPhotosGroupWinthName:(NSString *)name {
    NSString *title = name;
    // 获得所有的自定义相册
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

+ (void)saveImage:(UIImage *)image toCollection:(PHAssetCollection*)collection completionBlock:(void(^)(BOOL success, NSError * error))block {
    if (!image || ![image isKindOfClass:[UIImage class]]) {
        block(NO, [NSError errorWithDomain:@"图片格式不正确" code:0 userInfo:nil]);
        return;
    }
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request =[PHAssetCreationRequest creationRequestForAssetFromImage:image];
        // 2. 先保存图片到"相机胶卷",拿到标识符
        assetId = request.placeholderForCreatedAsset.localIdentifier;
//        request.location =[[CLLocation alloc]initWithLatitude:30.000 longitude:14.000];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            NSLog(@"保存到默认相册失败:%@", error);
            block(success, error);
            return;
        }
        //如果没指定相册对象,就不再处理
        if (!collection) {
            block(success, error);
            return;
        }
        // 3. 将“相机胶卷”中的图片添加到新的相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            if (asset) {
                // 添加图片到相册中
                [request addAssets:@[asset]];
            }
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            block(success, error);
            if (error) {
                NSLog(@"保存到指定相册失败:%@", error);
            }
        }];
    }];
}

@end
