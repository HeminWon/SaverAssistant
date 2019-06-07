//
//  DownloadManager.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa

/// Manager of asynchronous download `Operation` objects

final class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    
    fileprivate var operations = [Int: DownloadOperation]()
    
    /// Serial OperationQueue for downloads
    
    private let queue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "download"
        operationQueue.maxConcurrentOperationCount = 3
        return operationQueue
    }()
    
    /// Delegate-based `URLSession` for DownloadManager
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: (self as URLSessionDelegate), delegateQueue: nil)
    }()
    
    @discardableResult
    func queueDownload(_ url: URL) -> DownloadOperation {
        let operation = DownloadOperation(session: session, url: url)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        return operation
    }
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
        ) {
        operations[downloadTask.taskIdentifier]?.urlSession(session,
                                                            downloadTask: downloadTask,
                                                            didFinishDownloadingTo: location)
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
        ) {
        operations[downloadTask.taskIdentifier]?.urlSession(session,
                                                            downloadTask: downloadTask,
                                                            didWriteData: bytesWritten,
                                                            totalBytesWritten: totalBytesWritten,
                                                            totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let key = task.taskIdentifier
        operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
    
}

/// Asynchronous Operation subclass for downloading
final class DownloadOperation: AsynchronousOperation {
    let task: URLSessionTask
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

// MARK: NSURLSessionDownloadDelegate methods
//       Customized for our usage
extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let manager = FileManager.default
            var destinationURL = URL(fileURLWithPath: WebCache.cacheDirectory!)

            destinationURL.appendPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
            
            try? manager.removeItem(at: destinationURL)
            try manager.moveItem(at: location, to: destinationURL)
        } catch {
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
        ) {
        //let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        //print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: URLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer { finish() }
        
        if let error = error {
            return
        }
        
        // We need to untar the resources.tar
        if task.originalRequest!.url!.absoluteString.contains("resources.tar") {
            
            // Extract json
            let process: Process = Process()
            let cacheDirectory = WebCache.cacheDirectory!
            
            var cacheResourcesString = cacheDirectory
            cacheResourcesString.append(contentsOf: "/resources.tar")
            
            process.currentDirectoryPath = cacheDirectory
            process.launchPath = "/usr/bin/tar"
            process.arguments = ["-xvf", cacheResourcesString]
            
            process.launch()
            
            process.waitUntilExit()
        }
        
    }
}
