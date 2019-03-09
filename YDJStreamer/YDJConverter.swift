//
//  YDJConverter.swift
//  YDJStreamer
//
//  Created by Jonas Mahiques on 2019-03-08.
//  Copyright © 2019 Jonas Mahiques. All rights reserved.
//

import Foundation
import MediaPlayer

class YDJConverter {
    static let settings:[String:Int] = [ AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                         AVLinearPCMIsBigEndianKey: 0,
                                         AVLinearPCMIsFloatKey: 0,
                                         AVLinearPCMBitDepthKey: 16,
                                         AVLinearPCMIsNonInterleaved: 0]
    
    var didConvertData:((YDJConverter, Data) -> Void)?
    var didFinishConvertion:((YDJConverter) -> Void)?
    
    private let media:MPMediaItem
    private var assetReader:AVAssetReader
    private var trackOutput:AVAssetReaderTrackOutput
    
    private var task:DispatchWorkItem?
    
    var mediaID:UInt64 { get { return media.persistentID }}
    
    init?(mediaItem:MPMediaItem) {
        guard let url = mediaItem.assetURL else { return nil }
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: AVMediaType.audio).first else { return nil }
        
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: YDJConverter.settings)
        media = mediaItem
        
        assetReader.add(trackOutput)
    }
    
    func start() {
        assetReader.startReading()
        task = DispatchWorkItem {
            while self.assetReader.status == AVAssetReader.Status.reading
            {
                if let sampleBufferRef = self.trackOutput.copyNextSampleBuffer()
                {
                    if let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef)
                    {
                        let bufferLength = CMBlockBufferGetDataLength(blockBufferRef)
                        if let data = NSMutableData(length: bufferLength) {
                            CMBlockBufferCopyDataBytes(blockBufferRef, atOffset:0, dataLength: bufferLength, destination: data.mutableBytes)
                            self.didConvertData?(self, data as Data)
                        }
                        
                        CMSampleBufferInvalidate(sampleBufferRef)
                    }
                }
            }
            
            self.didFinishConvertion?(self)
        }
                
        DispatchQueue(label: UUID.init().uuidString).async(execute: task!)
    }
    
    func cancel() {
        assetReader.cancelReading()
        task?.cancel()
    }
}
