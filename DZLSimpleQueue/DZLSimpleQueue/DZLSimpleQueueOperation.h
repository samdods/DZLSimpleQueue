//
//  DZLSimpleQueueOperation.h
//  Times
//
//  Created by Sam Dods on 25/07/2014.
//  Copyright (c) 2014 The App Business. All rights reserved.
//

#import "DZLSimpleQueue.h"

@class DZLSimpleQueueOperation;

@protocol DZLSimpleQueueOperationDelegate <NSObject>

- (void)operation:(DZLSimpleQueueOperation *)operation didComplete:(BOOL)wasCancelled;

@end

@interface DZLSimpleQueueOperation : NSObject <DZLSimpleQueueOperation>

+ (instancetype)operationWithBlock:(void(^)(void))block;

//+ (instancetype)operationWithTarget:(id)target selector:(SEL)sel object:(id)arg;

@property (nonatomic, weak) id<DZLSimpleQueueOperationDelegate> delegate;

- (void)start;

@end
