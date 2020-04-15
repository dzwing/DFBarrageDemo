//
//  DFBarrageView.h
//  BulletScreenDemo
//
//  Created by 丁志伟 on 2020/4/14.
//  Copyright © 2020 丁志伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DFBarrageModel;
@interface DFBarrageView : UIView

/// 记录当前最后一个弹幕view，以此判断下一个弹幕显示在哪个弹幕轨道上
@property (nonatomic, strong) UIView *lastBarrageView;

/// 发送弹幕
/// @param barrageModel 弹幕数据模型
- (void)sendBarrageMsg:(DFBarrageModel *)barrageModel;

@end

NS_ASSUME_NONNULL_END
