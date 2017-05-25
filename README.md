# ToolPackage
开发中 为了方便处理权限问题 利用block分装的一个权限申请工具类
使用方法:
在 plist 文件中增加对应的键值对
 <key>NSRemindersUsageDescription</key>
 <string>为了更好的体验,请允许访问备忘录</string>
 <key>NSCalendarsUsageDescription</key>
 <string>为了更好的体验,请允许访问日历</string>
 <key>NSContactsUsageDescription</key>
 <string>为了更好的体验,请允许访问您的联系人</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>为了更好的体验,请允许使用时获取位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>为了更好的体验,请允许app后台获取位置</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>为了更好的体验,请允许访问您的麦克风</string>
 <key>NSCameraUsageDescription</key>
 <string>为了更好的体验,请允许访问您的相机</string>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>为了更好的体验,请允许访问您的相册</string>

// 相册
[PermissionTool getPhotosPermission:^(NSInteger authStatus) {
   NSLog(@"相册:%ld",authStatus);
  if (authStatus ==1) {
    NSLog(@"可以访问");
  } else {
    NSLog(@"无权访问");
  }
}];
// 相机
[PermissionTool getCamerasPermission:^(NSInteger authStatus) {
  NSLog(@"相相机:%ld",authStatus);
  if (authStatus ==1) {
    NSLog(@"可以访问");
  } else {
    NSLog(@"无权访问");
  }
}];
// 麦克风
[PermissionTool getMicrophonePermission:^(NSInteger authStatus) {
  NSLog(@"麦克风:%ld",authStatus);
  if (authStatus ==1) {
     NSLog(@"可以访问");
  } else {
     NSLog(@"无权访问");
  }
}];
等等 (详见代码)
