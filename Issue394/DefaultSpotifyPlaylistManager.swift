import Foundation

protocol IPlaylistManager {
    func getRandomPlaylistName(#previousPlaylistNames: [String], callback: (String) -> ())
}

class DefaultSpotifyPlaylistManager : IPlaylistManager
{
    let spotifyProxy: ISpotifyProxy
    private(set) var playlistSnapshot: SPTPlaylistSnapshot?
    private(set) var randomPlaylistNameCallback: (String) -> Void
    private(set) var previousPlaylistNames = [String]()

    init(spotifyProxy: ISpotifyProxy) {
        self.spotifyProxy = spotifyProxy
        self.randomPlaylistNameCallback = {
            (input: String) -> () in
            NSLog("unimplemented (input: \(input)")
        }
    }

    func getRandomPlaylistName(#previousPlaylistNames: [String], callback: (String) -> ()) {
        self.randomPlaylistNameCallback = callback
        self.previousPlaylistNames = previousPlaylistNames
        recallPlaylistPaginationForRandomName()
    }

    private func recallPlaylistPaginationForRandomName() {
        let lambda = self.generateCallbackFor_playlistsForUserWithSession(__FUNCTION__, msg: "looking for playlist names")
        spotifyProxy.sptPlaylistList_playlistsForUserWithSession(callback: lambda)
    }

    private func generateCallbackFor_playlistsForUserWithSession(fn: String, msg: String) -> (NSError?, AnyObject?) -> Void {
        let _fn = fn
        let _msg = msg
        func rv(error: NSError?, object: AnyObject?) -> Void {
            assert((nil == error),"OOPS, got a non-nil error. Invalid test, since assuming perfect environment")
            assert((nil != object),"OOPS, got a nil object. Are you using spt-ios-sdk 'beta-10'?")
            let page = object as! SPTListPage
            let items = page.items
            for item in items {
                let playlist = item as! SPTPartialPlaylist
                let playlistUri = playlist.uri
                let pname = playlist.name
                if (false == contains(self.previousPlaylistNames, pname)) {
                    self.randomPlaylistNameCallback(pname)
                    return
                }
            }
            assert(false,"can't currently handle multiple pages and/or exhaustion from full previous-playlist-name-list.")
        }
        return rv
    }

}
