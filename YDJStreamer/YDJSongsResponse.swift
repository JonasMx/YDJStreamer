//
//  SongsResponse.swift
//  YDJStreamer
//
//  Created by Jonas Mahiques on 2019-03-04.
//  Copyright © 2019 Jonas Mahiques. All rights reserved.
//

import Foundation
import MediaPlayer

class YDJSongsResponse {
    var songs:[MPMediaItem] = []
    
    func toJSON() -> [String:Any] {
        var songsJSON:[[String:Any]] = []
        
        for song in songs {
            songsJSON.append([
                "id": song.persistentID,
                "title": song.title ?? "Unknown Title",
                "albumTitle": song.albumTitle ?? "Unknown Album",
                "artist": song.artist ?? "Unknown Artist",
                "albumArtist": song.albumArtist ?? "Unknow Album Artist",
                ])
        }
        
        return [
            "count": songsJSON.count,
            "songs": songsJSON
        ]
    }
}
