//
//  MapDemoViewController.m
//  MapDemo
//
//  Created by marujun on 13-4-11.
//  Copyright (c) 2013年 马汝军. All rights reserved.
//

#import "MapDemoViewController.h"

//使用IOS的私有类MKLocationManager来计算，这种方法只在iOS5以前的系统上可以使用
@interface MKLocationManager
+ (id)sharedLocationManager;      // 创建并获取MKLocationManager实例
- (BOOL)chinaShiftEnabled;        // 判断IOS系统是否支持计算偏移
- (CLLocation*)_applyChinaLocationShift:(CLLocation*)arg;   // 传入原始位置，计算偏移后的位置
@end

@implementation MapDemoViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation]; // 开始定位
    }
    
}

// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    wgsText.text = [NSString stringWithFormat:@"%f , %f", latitude, longitude];
    
    //用高德地图api校正获取的gps 数据
    MARGCSearchOption* searchOption = [[MARGCSearchOption alloc]init];//初始化SearchOption
    searchOption.config = @"RGC"; //这个是默认的，函数声明的头文件有注释
    searchOption.coors = [NSString stringWithFormat:@"%f,%f;",longitude,latitude];//这个可以同时查几组经纬度值，中间用分号隔开，参数location 是用CLLocationManager获取的经纬度值
    
    NSString *Apikey=@"7c9bca72cfb64b33e868feaa57f9b9c2" ;
    MASearch *search=[[MASearch alloc]initWithSearchKey:Apikey Delegate:self];
    search.delegate=self;//设置代理
    [search gpsOffsetSearchWithOption:searchOption]; //传入searchoption开始查找校正后的经纬度
    
    //使用IOS的私有类MKLocationManager来计算,这种方法只在iOS5以前的系统上可以使用。
    if ([[MKLocationManager sharedLocationManager] chinaShiftEnabled]) {
        newLocation = [[MKLocationManager sharedLocationManager] _applyChinaLocationShift:newLocation];
        CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
        NSLog(@"newLocation -->>%@",newLocation);
        if (newLocation == nil) {  // 很重要，计算location好像是要联网的，软件刚启动时前几次计算会返回nil。
            return;
        }        
        privateModule.text = [NSString stringWithFormat:@"%f , %f", newCoordinate.latitude, newCoordinate.longitude];
    }else{
        privateModule.text = @"请确认是否是 IOS5 以前的系统！";
    }
}

// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    wgsText.text = [error localizedDescription];
    gaodeText.text = @"";
    privateModule.text = @"";
}

-(void) gpsOffsetSearch:(MARGCSearchOption *)gpsOffSearchOption Result:(MARGCSearchResult *)result
{
//    NSLog(@"gpsOffsetSearch result-->>>%@",result.rgcItemArray);
    MARGCItem* rgcInfo = [result.rgcItemArray objectAtIndex:0];  //返回的结果result是一个array来的，因为可以同时查找很多组经纬度值，不过我上面代码我只写了一组，所以只取第一个object就行了
    float longitude = [rgcInfo.x floatValue];        //取出经度值
    float latitude = [rgcInfo.y floatValue];  //取出纬度值
    gaodeText.text = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
}

-(void)search:(id)searchOption Error:(NSString*)errCode{
    //search失败时的code
    /*
     000000  操作成功 \n
     000001  无查询结果 \n
     000002  调用服务发生异常 \n
     010001  非法坐标格式 \n
     010002  字符集编码错误 \n
     010003  Apikey为空 \n
     020000  产品未授权 \n
     020001  Apikey不正确 \n
     020002  Api账号不存在 \n
     020003  没有服务访问权限 \n
     040001  查询服务连接异常 \n
     040002  查询服务返回格式解析异常 \n
     050001  当前请求数据格式不支持 \n
     */
     NSLog(@"search Error-->>>%@",errCode);
}

- (void)viewDidUnload {
    privateModule = nil;
    gaodeText = nil;
    wgsText = nil;
    self.locationManager = nil;
}

@end
