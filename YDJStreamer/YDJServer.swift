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
    private var converters:[String:YDJConverter] = [:]
    
    public init() {
        server = GCDWebServer.init()

        setUpRoutes()
    }

    func setUpRoutes() {
        server.addHandler(forMethod: "GET", pathRegex: "/song/([0-9]+)", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            guard MPMediaLibrary.authorizationStatus() == .authorized else { return GCDWebServerResponse(statusCode: 404) }
            let songID = request.url.lastPathComponent
            
            let mediaPredicate = MPMediaPropertyPredicate(value: songID, forProperty: MPMediaItemPropertyPersistentID)
            let mediaQuery = MPMediaQuery.songs()
            mediaQuery.addFilterPredicate(mediaPredicate)
            
            guard let song = mediaQuery.items?.first else { return GCDWebServerResponse(statusCode: 404) }
            guard let converter = YDJConverter(mediaItem: song), let playerID = request.query?["player"] as? String else {
                return GCDWebServerResponse(statusCode: 500)
            }
            
            self.addConverterForPlayer(playerID, converter: converter)
            
            let response = GCDWebServerStreamedResponse(contentType: "raw", asyncStreamBlock: { (completion) in
                converter.didConvertData = { _, data in completion(data, nil) }
                converter.didFinishConversion = { converter in
                    completion(Data(), nil)
                    self.removeConverterOfPlayerWithID(playerID, converter.mediaID)
                }
            })
            
            converter.start()
            return response
        }

        server.addHandler(forMethod: "GET", path: "/allsongs", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            guard MPMediaLibrary.authorizationStatus() == .authorized else { return GCDWebServerDataResponse(statusCode: 404) }

            let response = YDJSongsResponse()

            guard let songs = MPMediaQuery.songs().items else { return GCDWebServerDataResponse(jsonObject: response.toJSON()) }

            response.songs.append(contentsOf: songs)
            return GCDWebServerDataResponse(jsonObject: response.toJSON())
        }
        
        server.addHandler(forMethod: "DELETE", pathRegex: "/player/([0-9]+)", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            let playerID = request.url.lastPathComponent
            if let converter = self.converterForPlayer(playerID) {
                converter.cancel()
            }
            
            return GCDWebServerResponse(statusCode: 200)
        }
    }
    
    private func removeConverterOfPlayerWithID(_ id:String, _ mediaID:UInt64) {
        if let index = converters.firstIndex(where: { (playerID, converter) -> Bool in return playerID == id && converter.mediaID == mediaID }) {
            converters.remove(at: index)
        }
    }
    
    private func addConverterForPlayer(_ playerID:String, converter:YDJConverter) {
        if let oldConverter = converterForPlayer(playerID) {
            oldConverter.cancel()
        }
        
        converters.updateValue(converter, forKey: playerID)
    }
    
    private func hasConverterForPlayer(_ id:String) -> Bool {
        return converterForPlayer(id) != nil
    }
    
    private func converterForPlayer(_ id:String) -> YDJConverter? {
        return converters.first(where: { (playerID, _) -> Bool in return playerID == id })?.value
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
