//
//  DFBarrageView.m
//  BulletScreenDemo
//
//  Created by 丁志伟 on 2020/4/14.
//  Copyright © 2020 丁志伟. All rights reserved.
//

#import "DFBarrageView.h"
#import "DFBarrageModel.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DFBarrageView ()

{
    CGFloat _minTime; // 最小运行时间
}

/// 数据源
@property (nonatomic, strong) NSMutableArray *dataMutableArray;
/// 重用池
@property (nonatomic, strong) NSMutableArray *resuedMutableArray;

@end

@implementation DFBarrageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configInterface];
    }
    return self;
}

- (void)configInterface {
    self.dataMutableArray = [NSMutableArray array];
    self.resuedMutableArray = [NSMutableArray array];
    
    _minTime = 1.0;
    
    UIView *view = [self createUI];
    [self.resuedMutableArray addObject:view];
    
    [self checkStartAnimation];
    
}

- (void)checkStartAnimation {
    if (_dataMutableArray.count > 0) {
        if (_resuedMutableArray.count > 0) {
            UIView *view = [_resuedMutableArray firstObject];
            [_resuedMutableArray removeObjectAtIndex:0];
            
            [self startAnimatingWithView:view];
        } else {
            UIView *view = [self createUI];
            [self startAnimatingWithView:view];
        }
    }
    
    // 调用自身方法，构成一个无限循环，不停的轮询检查是否有弹幕数据
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_minTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakself) strongself = weakself;
        [strongself checkStartAnimation];
    });
}

- (void)startAnimatingWithView:(UIView *)view {
    // 取出第一条数据
    DFBarrageModel *model = [_dataMutableArray firstObject];
    
    // 计算昵称的长度
    NSString *nameStr = [NSString stringWithFormat:@"%@:",model.name];
    CGSize nameSize = [nameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 14) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    
    // 计算消息的长度
    CGSize msgSize = [model.message boundingRectWithSize:CGSizeMake(MAXFLOAT, 14) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;

    UIImageView *avatarImgV;
    UILabel *nameLab;
    UILabel *msgLab;
    
    for (UIView *subview in view.subviews) {
        switch (subview.tag) {
            case 1000:
                avatarImgV = (UIImageView *)subview;
                avatarImgV.image = [UIImage imageNamed:model.avatar];
                break;
            case 1001:
                nameLab = (UILabel *)subview;
                nameLab.text = nameStr;
                
                CGRect nameRect = nameLab.frame;
                nameRect.size.width = nameSize.width;
                nameLab.frame = nameRect;
                break;
            case 1002:
                msgLab = (UILabel *)subview;
                msgLab.text = model.message;
                
                CGRect msgRect = msgLab.frame;
                msgRect.origin.x = CGRectGetMaxX(nameLab.frame) + 5;
                msgRect.size.width = msgSize.width;
                msgLab.frame = msgRect;
                break;
            default:
                break;
        }
    }
    
    // 重新设置弹幕view的总体宽度
    CGFloat totalWidth = CGRectGetWidth(avatarImgV.frame) + 4 + CGRectGetWidth(nameLab.frame) + CGRectGetWidth(msgLab.frame) + 5;
    view.frame = CGRectMake(SCREEN_WIDTH, 0, totalWidth, CGRectGetHeight(self.frame));
    
    // 固定速度：v = 100 （可根据自己需要调整）
    // s = 屏幕宽度 + 弹幕宽度   v = s / t;
    CGFloat duration = (SCREEN_WIDTH + view.frame.size.width)/100;
    
    // 最小运行时间 = 弹幕完全进入屏幕的时间 + 间距的时间
    _minTime = (view.frame.size.width + 30)/100;
    
    // 最后做动画的view
    _lastBarrageView = view;
    
    // 弹幕view开始动画
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        // 运行至左侧屏幕外
        CGRect frame = view.frame;
        view.frame = CGRectMake(-frame.size.width, 0, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        // 动画结束重新回到右侧初始位置
        view.frame = CGRectMake(SCREEN_WIDTH, 0, 0, CGRectGetHeight(self.frame));
        // 加入重用池
        [self.resuedMutableArray addObject:view];
    }];
    
    // 移除当前弹幕数据
    [self.dataMutableArray removeObject:model];
}

- (UIView *)createUI {
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, 0, CGRectGetHeight(self.frame))];
    bgView.backgroundColor = [UIColor redColor];
    bgView.userInteractionEnabled = NO; // 不改为NO，不会触发- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    UIImageView *avatarImgView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, CGRectGetHeight(self.frame) - 4, CGRectGetHeight(self.frame) - 4)];
    avatarImgView.backgroundColor = [UIColor purpleColor];
    avatarImgView.layer.cornerRadius = avatarImgView.frame.size.width/2;
    avatarImgView.layer.masksToBounds = YES;
    avatarImgView.tag = 1000;
    [bgView addSubview:avatarImgView];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(avatarImgView.frame) + 2, 0, 0, 20)];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.tag = 1001;
    [bgView addSubview:nameLabel];
    
    UILabel *msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + 5, 0, 0, 20)];
    msgLabel.font = [UIFont systemFontOfSize:14];
    msgLabel.tag = 1002;

    [bgView addSubview:msgLabel];
    
    [self addSubview:bgView];
    
    return bgView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = touches.anyObject;//获取触摸对象
    CGPoint point = [touch  locationInView:self];
    NSArray *subViews = self.subviews;
    for(UIView *subView in subViews){
        CALayer *layer = subView.layer.presentationLayer; //显示层
        if(CGRectContainsPoint(layer.frame, point)){ //触摸点在显示层中，返回label
            for (UIView *view in subView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    if (label.tag == 1002) {
                        NSLog(@"label.text = %@",label.text);
                    }
                }
            }

        }
    }
}

- (void)sendBarrageMsg:(DFBarrageModel *)barrageModel {
    [self.dataMutableArray addObject:barrageModel];
}
@end
