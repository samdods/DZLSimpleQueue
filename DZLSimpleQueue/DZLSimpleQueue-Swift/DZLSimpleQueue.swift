//
//  DZLSimpleQueue.swift
//  DZLSimpleQueue
//
//  Created by Sam Dods on 26/07/2014.
//  Copyright (c) 2014 Dodzilla. All rights reserved.
//

import Foundation


func == (lhs: DZLSimpleQueueOperation, rhs: DZLSimpleQueueOperation) -> Bool
{
  return lhs.uuid == rhs.uuid
}


protocol DZLSimpleQueueOperationProtocol
{
  func cancel()
  var completionHandler: (() -> ())? { get set }
}


protocol DZLSimpleQueueOperationDelegate
{
  func operationDidComplete(operation: DZLSimpleQueueOperation, finished: Bool)
}


class DZLSimpleQueueOperation: DZLSimpleQueueOperationProtocol, Equatable
{
  var delegate: DZLSimpleQueueOperationDelegate
  var dispatchSource: dispatch_source_t
  var queue: dispatch_queue_t
  var uuid: NSUUID
  var completionHandler: (() -> ())?
  
  init(delegate: DZLSimpleQueueOperationDelegate, block: () -> ())
  {
    self.delegate = delegate
    self.uuid = NSUUID()
    self.queue = dispatch_queue_create("operation internal queue", DISPATCH_QUEUE_SERIAL)
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
    dispatch_source_set_timer(self.dispatchSource, DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC)
    dispatch_source_set_event_handler(self.dispatchSource) { [unowned self] in
      block();
      self.completionHandler?()
      self.delegate.operationDidComplete(self, finished: true)
    };
  }
  
  func start()
  {
    dispatch_resume(self.dispatchSource)
  }
  
  func cancel()
  {
    dispatch_source_cancel(self.dispatchSource)
    self.delegate.operationDidComplete(self, finished: false)
  }

}


class DZLSimpleQueue: DZLSimpleQueueOperationDelegate
{
  let underlyingDispatchQueue = dispatch_queue_create("DZLSimpleQueue", DISPATCH_QUEUE_SERIAL);
  var maxConcurrentOperationCount : CLong
  var semaphore : dispatch_semaphore_t
  var operations : Array<DZLSimpleQueueOperation>
  var numberOfOperations : UInt {
    get {
      return self.operations.count.asUnsigned()
    }
  }

  init(maxCount: CLong)
  {
    self.maxConcurrentOperationCount = maxCount
    self.semaphore = dispatch_semaphore_create(maxCount as CLong)
    self.operations = Array<DZLSimpleQueueOperation>()
  }
  
  
  deinit
  {
    while (self.numberOfOperations > 0) {
      dispatch_semaphore_signal(self.semaphore)
    }
  }
    
    
  func addBlock(block: () -> ()) -> DZLSimpleQueueOperationProtocol
  {
    var operation: DZLSimpleQueueOperation = DZLSimpleQueueOperation(delegate:self, block)
    
    dispatch_async(underlyingDispatchQueue) { [unowned self] in
      dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
      operation.start()
    }
    
    self.operations.append(operation)
    
    return operation;
  }
    
    
  func operationDidComplete(operation: DZLSimpleQueueOperation, finished: Bool)
  {
    dispatch_semaphore_signal(self.semaphore)
    self.operations = self.operations.filter( {$0 != operation} )
  }
  
}
