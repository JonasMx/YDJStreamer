# YDJStreamer

## Getting Started

### Installing with Cocoapods
```
pod 'YDJStreamer', :git => 'https://github.com/JonasMx/YDJStreamer.git', :tag => '1.0.0'
```

### Info.plist
Add the following lines to your Info.plist
```
<key>NSAppleMusicUsageDescription</key>
<string>Your description about why you need this capability</string>
```

## How to use

### Start the server
```
let server = YDJServer()
if server.start() {
   //Your server did start
}
```

### Asking permission
Before performing requests, you must ask permission to access the Media Library
```
import MediaPlayer

MPMediaLibrary.requestAuthorization { (status) in

}
```

### Get all songs 

To get the list of all your songs, make a request like:
```
HTTP/1.1 GET http://[::1]:8080/allsongs  
```

The server return a response like 
```
HTTP/1.1 404 OK         If the access is not allowed.
```
 
Or a JSON object if everything went well
```
{
   count:Int,
   songs:[
     {
        id:String,
        title:String,
        artist:String,
        albumArtist:String,
        albumTitle:String                
     }
   ]
}
```

### Start converting a song

To start converting and downloading a song, make a request like
```
HTTP/1.1 GET http://[::1]:8080/song/[songID]?player=[playerID] 
```

The server return a response like
```
HTTP/1.1 404 OK         If the songID is not specified or the access is not allowed 
HTTP/1.1 500 OK         If The playerID is not specified
```


### Cancel a song conversion
```
HTTP/1.1 DELETE http://[::1]:8080/song/[songID]?player=[playerID]
```

The server return a response like
```
HTTP/1.1 200 OK
HTTP/1.1 500 OK         If the playerID is not speficied
```











