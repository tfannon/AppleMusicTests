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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nowPlaying: UILabel!


    @IBAction func addTrack(_ sender: AnyObject) {
        guard let track = applePlayer.nowPlayingItem else {
            show2(message: "No item in media player")
            return
        }
        guard let artist = getValidArtist(track: track) else {
            show2(message: "No valid artist")
            return
        }
        guard let title = track.title else {
            show2(message: "No valid track")
            return
        }
            
        ITunesApi.find(media: Media.Music)
            .by(artist: artist, song: title)
            .limit(limit: 1)
            .request { json, error in
                print (json)
                //guard?
                if let id = json?["results"][0]["trackId"].stringValue {
                    self.mediaLibrary.addItem(withProductID: id) { result in
                        guard let item = result.0[0] as? MPMediaItem else {
                            self.show2(message: "Item not added")
                            return
                        }
                        let message = self.getTrackInfo(track: item)
                        self.show2(message: "Added: " + message)
                    }
                }
        }
    }
    
    func show2(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { result in }
        alert.addAction(okAction)
        DispatchQueue.main.sync {
            self.present(alert, animated: true)
        }
    }


    
    
    @IBAction func queryPlaylists(_ sender: AnyObject) {
        let query = MPMediaQuery.playlists()
        guard let result = query.collections else {return}
        textView.text = ""
        for playlist in result {
            let name = playlist.value(forProperty: MPMediaPlaylistPropertyName)
            //let author = playlist.value(forProperty: MPMediaPlaylistPropertyAuthorDisplayName)
            let strPlaylist = textView.text!.appending("\(name!): \(playlist.count) songs\n")
            self.textView.text = strPlaylist
            
            for y in playlist.items {
                let songInfo = "  " + getTrackInfo(track: y, showAlbum: false, showAlbumArtist: false) + " " + String(y.playCount) + "\n"
                let strPlaylist = textView.text!.appending(songInfo)
                self.textView.text = strPlaylist
            }
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
            let msg = getTrackInfo(track: track)
            print (msg)
            nowPlaying.text = msg
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
    
    func getTrackInfo(track: MPMediaItem, showAlbum: Bool = false, showAlbumArtist: Bool = false) -> String {
        var trackInfo: String = ""
        if (showAlbumArtist) {
            if track.albumArtist != nil {
                trackInfo += track.albumArtist!
            }
            trackInfo += " : "
        }
        if track.artist != nil {
            trackInfo += "\(track.artist!)"
        }
        trackInfo += " : "
        if (showAlbum) {
            if track.albumTitle != nil {
                trackInfo += "\(track.albumTitle!)"
            }
            trackInfo += " : "
        }
        if track.title != nil {
            trackInfo += "\(track.title!)"
        }
        return trackInfo
    }
    
    func getValidArtist(track: MPMediaItem) -> String? {
        if track.artist != nil {
            return track.artist!
        }
        if track.albumArtist != nil {
            return track.albumArtist!
        }
        return nil
    }



}

