//
//  ViewController.m
//  BulletScreenDemo
//
//  Created by 丁志伟 on 2020/4/14.
//  Copyright © 2020 丁志伟. All rights reserved.
//

#import "ViewController.h"
#import "DFBarrageView.h"
#import "DFBarrageModel.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

// 第一个弹幕轨道
@property (nonatomic, strong) DFBarrageView *barrageViewOne;
// 第二个弹幕轨道
@property (nonatomic, strong) DFBarrageView *barrageViewTwo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _barrageViewOne = [[DFBarrageView alloc]initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 20)];
    [self.view addSubview:_barrageViewOne];
    
    _barrageViewTwo = [[DFBarrageView alloc]initWithFrame:CGRectMake(0, 240, SCREEN_WIDTH, 20)];
    [self.view addSubview:_barrageViewTwo];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 400, SCREEN_WIDTH, 100);
    [button setTitle:@"开始弹幕" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startBarrage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

- (void)startBarrage {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendMsg) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)sendMsg {
    DFBarrageModel *model = [[DFBarrageModel alloc]init];
    model.avatar = @[@"001",@"002",@"003",@"004",@"005",@"006",@"007",@"008",@"009",@"0010"][arc4random()%10];
    model.name = @[@"林志颖",@"王力宏",@"吴克群",@"林俊杰",@"吴京",@"赵文卓",@"刘德华",@"吴樾",@"释小龙",@"沈腾",@"沙溢",@"杨洋"][arc4random()%12];
    model.message = @[@"白夜行",@"人性的弱点",@"好吗，好的",@"摆渡人",@"挪威的森林",@"容华过后，不过一场，山河永寂。",@"燃尽的风华，为谁化作了彼岸花",@"终于为那一身江南烟雨覆了天下",@"将军令",@"Always Online",@"一眼万年"][arc4random()%11];
    //计算当前做动画的弹幕UI的位置
    CGFloat onePositon = _barrageViewOne.lastBarrageView.layer.presentationLayer.frame.size.width + _barrageViewOne.lastBarrageView.layer.presentationLayer.frame.origin.x;
    //计算当前做动画的弹幕UI的位置
    CGFloat twoPositon = _barrageViewTwo.lastBarrageView.layer.presentationLayer.frame.size.width + _barrageViewTwo.lastBarrageView.layer.presentationLayer.frame.origin.x;

    if ( onePositon < twoPositon ) {
        [_barrageViewOne sendBarrageMsg:model];
    }else{
        [_barrageViewTwo sendBarrageMsg:model];
    }
}


@end
