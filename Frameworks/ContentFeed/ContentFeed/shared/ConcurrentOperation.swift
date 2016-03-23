//
//  ConcurrentOperation.swift
//
//  This class is the parent class of concurrent operations. A concurrent operation typically
//  include an async task. In this case the state of the operation should be managed manually.
//  Otherwise the operation is considered finished before the callback of the async task.
//
//  A subclass would typically override the start() function to implement the async task. An
//  example of the async task is NSURLSessionTask. In the callback of the asyc task, set the
//  finished to true.
//
//  The main benefit of using this class is to be able to support cancellation and contain work
//  in a unit (unit of work).
//
//  Reference:1) https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSOperation_class/ see
//               Subclassing Notes section, especially for concurrency operation.
//            2) https://github.com/travisjeffery/TRVSURLSessionOperation
//            3) https://github.com/WeltN24/Carlos/blob/master/Carlos/ConcurrentOperation.swift
//
//  Copyright © 2015 athenahealth. All rights reserved.
//

import Foundation

class ConcurrentOperation: NSOperation {
    
    private var _ready: Bool
    private var _executing: Bool
    private var _finished: Bool
    private var _cancelled: Bool
    
    override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override var cancelled: Bool {
        get { return _cancelled }
        set {
            willChangeValueForKey("isCancelled")
            _cancelled = newValue
            didChangeValueForKey("isCancelled")
        }
    }
    
    
    override var concurrent: Bool {
        get { return true }
    }
    
    override init() {
        _ready = true
        _executing = true
        _finished = false
        _cancelled = false
        super.init()
    }
    
    override func cancel() {
        self.cancelled = true
        super.cancel()
    }
    
    override func start() {
        if cancelled {
            self.finished = true
            self.executing = false
            return
        }
        
        self.finished = false
        self.executing = true
    }
}
