//
//  DZLSimpleQueue.h
//  Times
//
//  Created by Sam Dods on 25/07/2014.
//  Copyright (c) 2014 The App Business. All rights reserved.
//

@protocol DZLSimpleQueueOperation <NSObject>

- (void)cancel;

@end

@interface DZLSimpleQueue : NSObject

@property (nonatomic, assign, readonly) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, assign, readonly) NSUInteger numberOfOperations;

+ (instancetype)simpleQueueWithMaxConcurrentOperationCount:(NSUInteger)maxCount;

- (id<DZLSimpleQueueOperation>)addBlockToQueue:(void(^)(void))block;

@end
