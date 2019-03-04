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
```

```
MPMediaLibrary.requestAuthorization { (status) in

}
```

### Get all songs 

Visit http://[::1]:8080/allsongs to get the list of all your songs, it returns a JSON Object. It returns Error 404 if the access is not allowed.

```
{
   count:Int
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

### Start playing a song

Visit http://[::1]:8080/song/[id] to start downloading a song sepcified by [id] in wav format. It returns Error 404 if the access is not allowed. 











