//
//  ViewController.swift
//  AppleMusicTests
//
//  Created by Thomas Fannon on 8/7/16.
//  Copyright © 2016 Stingray Dev. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer


class ViewController: UIViewController {

    @IBAction func addTrack(_ sender: AnyObject) {
    }
    
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var nowPlaying: UILabel!
    
    
    @IBAction func queryPlaylists(_ sender: AnyObject) {
        let query = MPMediaQuery.playlists()
        guard let result = query.collections else {return}
        textView.text = ""
        for playlist in result {
            let name = playlist.value(forProperty: MPMediaPlaylistPropertyName)
            //let author = playlist.value(forProperty: MPMediaPlaylistPropertyAuthorDisplayName)
            let strPlaylist = textView.text!.appending("\(name!): \(playlist.count) songs\n")
            self.textView.text = strPlaylist
            // for y in playlist.items {
            //    let str2 = y.artist != nil ? y.artist : ""
            // print ("\(y.albumArtist != nil ? y.albumArtist! : "") " +
            // printArtist(albumArtist: y.albumArtist, artist: y.artist) +
            // "\(y.albumTitle != nil ? y.albumTitle! : "") - " +
            // "\(y.title != nil ? y.title! : "")" +
            // "  Plays: \(y.playCount)")
            // }
            //
            //                    artist: \(y.artist)  album: \(y.albumTitle) track: \(y.title)  cloud: \(y.isCloudItem)  plays: \(y.playCount)  rating: \(y.rating)  date:\(y.releaseDate)") != nil)
        }
    }
    
    var applePlayer: MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    var mediaLibrary: MPMediaLibrary = MPMediaLibrary.default()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.songChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object:nil)
        
        songChanged()
        applePlayer.beginGeneratingPlaybackNotifications()
    }
    
    func songChanged() {
        if let track = applePlayer.nowPlayingItem {
            nowPlaying.text = getTrackInfo(track: track)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func play(trackId: String) {
        //let trackID = "302053341" // use 302053341 in USA, 255991760 in UK
        let controller = MPMusicPlayerController.systemMusicPlayer()
        controller.setQueueWithStoreIDs([trackId])
        controller.play()
        if let item = controller.nowPlayingItem {
            print ("\(item.albumArtist)")
        }
    }
    
    func add(trackId: String) {
        let lib = MPMediaLibrary()
        lib.addItem(withProductID: trackId) { result in
            let item = result.0
            print (item)
        }
    }
    
    func getTrackInfo(track: MPMediaItem) -> String {
        var trackInfo: String = ""
        if track.albumArtist != nil {
            trackInfo += track.albumArtist!
        }
        trackInfo += " : "
        if track.artist != nil {
            trackInfo += "\(track.artist!)"
        }
        trackInfo += " : "
        if track.albumTitle != nil {
            trackInfo += "\(track.albumTitle!)"
        }
        trackInfo += " : "
        if track.title != nil {
            trackInfo += "\(track.title!)"
        }
        return trackInfo
    }



}

