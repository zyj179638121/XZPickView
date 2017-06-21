//
//  ViewController.m
//  XZPickView
//
//  Created by 赵永杰 on 17/3/24.
//  Copyright © 2017年 zhaoyongjie. All rights reserved.
//

#import "ViewController.h"
#import "XZPickView.h"

#define kScreenBounds [UIScreen mainScreen].bounds

@interface ViewController ()<XZPickViewDelegate, XZPickViewDataSource>

@property (nonatomic,strong) XZPickView * pickView;


@property (nonatomic,copy) NSDictionary * dateDic;
@property (nonatomic,copy) NSString * weekStr;
@property (nonatomic,copy) NSString * timeStr;
@property (nonatomic, strong) NSDate *selectDate;
@property (nonatomic, assign) NSInteger currentSelectDay;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)showPickView:(UIButton *)sender {

    NSLog(@"%s",__func__);
    self.dateDic = [self LHGetStartTime];
    self.weekStr = self.dateDic[@"week"][0];
    NSDate *date  = [[self.dateDic[@"time"] objectAtIndex:0] objectAtIndex:0];
    self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    [self.pickView reloadData];
    //[self.userNumPickView selectRow:0 inComponent:0 animated:NO];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    [self.pickView show];
}


-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{

        NSInteger left = [pickerView selectedRowInComponent:0];
        NSInteger right = [pickerView selectedRowInComponent:1];
        self.selectDate = [[self.dateDic[@"time"] objectAtIndex:left] objectAtIndex:right];
    
    NSLog(@"select date = %@",[self XZGetTimeStringWithDate:self.selectDate dateFormatStr:@"yyyy-MM-dd HH:mm:ss"]);
}

-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    //时间
    if (component == 0) {
        return [self.dateDic[@"week"] count];
    }else{
        NSInteger whichWeek = [pickerView selectedRowInComponent:0];
        return [[self.dateDic[@"time"] objectAtIndex:whichWeek] count];
    }
}

-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if(component == 0){
        self.currentSelectDay = [pickerView selectedRowInComponent:0];
        [pickerView pickReloadComponent:1];
        self.weekStr = self.dateDic[@"week"][row];
        NSArray *arr = [[self.dateDic objectForKey:@"time"] objectAtIndex:self.currentSelectDay];
        NSDate *date = [arr objectAtIndex:[pickerView selectedRowInComponent:1]];
        self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    }else{
        NSInteger whichWeek = [pickerView selectedRowInComponent:0];
        NSDate *date = [[self.dateDic[@"time"] objectAtIndex:whichWeek] objectAtIndex:row];
        self.timeStr = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
    }
    
}

-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if(component == 0){
        return self.dateDic[@"week"][row];
    }else{
        NSArray *arr = [[self.dateDic objectForKey:@"time"] objectAtIndex:self.currentSelectDay];
        NSDate *date = [arr objectAtIndex:row];
        NSString *str = [self XZGetTimeStringWithDate:date dateFormatStr:@"HH:mm"];
        return str;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return 2;
}

#pragma mark - 

- (NSString *)XZGetTimeStringWithDate:(NSDate *)date dateFormatStr:(NSString *)dateFormatStr {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = dateFormatStr;
    return [format stringFromDate:date];
}

- (NSDictionary *)LHGetStartTime {
    // 获取当前date
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDictionary *weekDict = @{@"2" : @"周一", @"3" : @"周二", @"4" : @"周三", @"5" : @"周四", @"6" : @"周五", @"7" : @"周六", @"1" : @"周日"};
    // 日期格式
    NSDateFormatter *fullFormatter = [[NSDateFormatter alloc] init];
    fullFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    // 获取当前几时(晚上23点要把今天的时间做处理)
    NSInteger currentHour = [calendar component:NSCalendarUnitHour fromDate:date];
    // 存放周几和时间的数组
    NSMutableArray *weekStrArr = [NSMutableArray array];
    NSMutableArray *detailTimeArr = [NSMutableArray array];
    // 设置合适的时间
    for (int i = 0; i < 3; i++) {
        NSDate *new = [calendar dateByAddingUnit:NSCalendarUnitDay value:i toDate:date options:NSCalendarMatchStrictly];
        NSInteger week = [calendar component:NSCalendarUnitWeekday fromDate:new];
        // 周几
        NSString *weekStr = weekDict[[NSString stringWithFormat:@"%ld",week]];
        NSString *todayOrOther = @"";
        if (i == 0) {
            todayOrOther = @"今天";
        }else if (i == 1) {
            todayOrOther = @"明天";
        }else if (i == 2){
            todayOrOther = @"后天";
        }
        // 今天周几 明天周几 后天周几
        NSString *resultWeekStr = [NSString stringWithFormat:@"%@ %@",todayOrOther,weekStr];
        [weekStrArr addObject:resultWeekStr];
        
        NSInteger year = [calendar component:NSCalendarUnitYear fromDate:new];
        NSInteger month = [calendar component:NSCalendarUnitMonth fromDate:new];
        NSInteger day = [calendar component:NSCalendarUnitDay fromDate:new];
        
        // 把符合条件的时间筛选出来
        NSMutableArray *smallArr = [NSMutableArray array];
        for (int hour = 0; hour < 24; hour++) {
            for (int min = 0; min < 60; min ++) {
                if (min % 15 == 0) {
                    NSString *tempDateStr = [NSString stringWithFormat:@"%ld-%ld-%ld %d:%d",year,month,day,hour,min];

                    NSDate *tempDate = [fullFormatter dateFromString:tempDateStr];
                    // 今天 之后的时间段
                    if (i == 0) {
                        if ([calendar compareDate:tempDate toDate:date toUnitGranularity:NSCalendarUnitHour] == 1) {
                            [smallArr addObject:tempDate];
                        }
                    }else{
                        [smallArr addObject:tempDate];
                    }
                }
            }
        }
        [detailTimeArr addObject:smallArr];
    }
    // 晚上23点把今天对应的周几和今天的时间空数组去掉
    if (currentHour == 23) {
        [weekStrArr removeObjectAtIndex:0];
        [detailTimeArr removeObjectAtIndex:0];
    }
    NSDictionary *resultDic = @{@"week" : weekStrArr , @"time" : detailTimeArr};
    return resultDic;
}

#pragma mark - getter methods

-(XZPickView *)pickView{
    if(!_pickView){
        _pickView = [[XZPickView alloc]initWithFrame:kScreenBounds title:@"请选择"];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}


@end
