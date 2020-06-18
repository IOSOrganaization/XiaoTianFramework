//
//  UITableViewExpanded.m
//  qiqidu
//
//  Created by XiaoTian on 2018/12/11.
//  Copyright © 2018 XiaoTian. All rights reserved.
//

#import "UITableViewExpanded.h"

@implementation UITableViewExpanded

- (void)awakeFromNib{
    [super awakeFromNib];
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize{
    [self layoutIfNeeded];
    return self.contentSize;
}

- (void)reloadData{
    [super reloadData];
    [self invalidateIntrinsicContentSize];
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentSize"];
}
@end
