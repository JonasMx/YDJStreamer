//
//  YDJServer.swift
//  YDJStreamer
//
//  Created by Jonas Mahiques on 2019-03-03.
//  Copyright © 2019 Jonas Mahiques. All rights reserved.
//

import Foundation
import MediaPlayer
import GCDWebServer

open class YDJServer {
    private let server:GCDWebServer
    private let convertedFileName:String = "music"
    
    public init() {
        server = GCDWebServer.init()
        
        setUpRoutes()
    }
    
    func setUpRoutes() {
        server.addHandler(forMethod: "GET", pathRegex: "/song/([0-9]+)", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            guard MPMediaLibrary.authorizationStatus() == .authorized else { return GCDWebServerDataResponse(statusCode: 404) }
            
            let songID = request.url.lastPathComponent
            
            let mediaPredicate = MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID)
            let mediaQuery = MPMediaQuery.songs()
            mediaQuery.addFilterPredicate(mediaPredicate)
            
            guard let song = mediaQuery.items?.first,
                let url = song.assetURL else { return GCDWebServerDataResponse(statusCode: 404) }
            
            
            var converterOptions = YDJConverter.Options()
            converterOptions.format = "wav"
            converterOptions.bitDepth = 16
            
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(self.convertedFileName+"."+converterOptions.format!)
                
                let converter = YDJConverter(inputURL: url, outputURL: fileURL, options: converterOptions)
                converter.start()
                return GCDWebServerFileResponse(file: fileURL.path)
            } else {
                return GCDWebServerDataResponse(statusCode: 500)
            }
        }
        
        
        
        server.addHandler(forMethod: "GET", path: "/allsongs", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            guard MPMediaLibrary.authorizationStatus() == .authorized else { return GCDWebServerDataResponse(statusCode: 404) }
            
            let response = YDJSongsResponse()
            
            guard let songs = MPMediaQuery.songs().items else { return GCDWebServerDataResponse(jsonObject: response.toJSON()) }
            
            response.songs.append(contentsOf: songs)
            return GCDWebServerDataResponse(jsonObject: response.toJSON())
        }
    }
    
    public func start() -> Bool {
        return start(with: 8080)
    }
    
    public func start(with port:UInt) -> Bool {
        return server.start(withPort: port, bonjourName: nil)
    }
    
    public func stop() {
        server.stop()
    }
}
