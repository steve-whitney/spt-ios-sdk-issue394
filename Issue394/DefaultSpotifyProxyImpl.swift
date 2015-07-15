import Foundation

let INTEGRATION__SPOTIFY_CLIENT_ID = "REDACTED"
let INTEGRATION__SPOTIFY_CALLBACK_URL = "REDACTED"
let INTEGRATION__SPOTIFY_TOKEN_SWAP_SERVICE_URL = "REDACTED"
let INTEGRATION__SPOTIFY_TOKEN_REFRESH_SERVICE_URL = "REDACTED"
let SPOTIFY_CLIENT_ID = INTEGRATION__SPOTIFY_CLIENT_ID
let SPOTIFY_CALLBACK_URL = INTEGRATION__SPOTIFY_CALLBACK_URL
let SPOTIFY_TOKEN_SWAP_SERVICE_URL = INTEGRATION__SPOTIFY_TOKEN_SWAP_SERVICE_URL
let SPOTIFY_TOKEN_REFRESH_SERVICE_URL = INTEGRATION__SPOTIFY_TOKEN_REFRESH_SERVICE_URL
let SPOTIFY_SESSION_USER_DEFAULTS_KEY = "fazbot"

protocol ISpotifyProxy {
    var currentSession: SPTSession? { get }
    func loginViaUI() -> Void
    func sptPlaylistList_playlistsForUserWithSession(#callback: SPTRequestCallback) -> Void
    func sptPlaylistSnapshot_playlistWithURI(uri: NSURL, callback: SPTRequestCallback) -> Void
    func sptPlaylistList_createPlaylistWithName(name: String, callback: SPTPlaylistCreationCallback) -> Void
    func sptPlaylistSnapshot_addTrackToPlaylist(sptPlaylistSnapshot: SPTPlaylistSnapshot, track: SPTTrack, callback: SPTErrorableOperationCallback) -> Void
}

class DefaultSpotifyProxyImpl : NSObject, ISpotifyProxy, SPTAuthViewDelegate {

    let spotifyAuthenticator = SPTAuth.defaultInstance()
    let underneathViewController: UIViewController
    private var _currentSession: SPTSession?
    var currentSession: SPTSession? {
        get { return _currentSession }
    }

    init(underneathViewController: UIViewController) {
        self.underneathViewController = underneathViewController
        super.init()
        spotifyAuthenticator.clientID = SPOTIFY_CLIENT_ID
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistModifyPublicScope, SPTAuthUserReadPrivateScope]
        spotifyAuthenticator.redirectURL = NSURL(string: SPOTIFY_CALLBACK_URL)
        spotifyAuthenticator.tokenSwapURL = NSURL(string: SPOTIFY_TOKEN_SWAP_SERVICE_URL)
        spotifyAuthenticator.tokenRefreshURL = NSURL(string: SPOTIFY_TOKEN_REFRESH_SERVICE_URL)
        spotifyAuthenticator.sessionUserDefaultsKey = SPOTIFY_SESSION_USER_DEFAULTS_KEY
    }

    func loginViaUI() {
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        underneathViewController.presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }

    // SPTAuthViewDelegate protocol methods
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        assert((nil != session),"oops")
        let accessToken = session!.accessToken
        SPTUser.requestCurrentUserWithAccessToken(accessToken, callback: handleRequestCurrentUserWithAccessTokenCallback)
        self._currentSession = session!
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        assert(false,"*** SPOTIFY LOGIN CANCELLED")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        assert(false,"*** SPOTIFY AUTH FAILURE: error=\(error)")
    }

    private func handleRequestCurrentUserWithAccessTokenCallback(error: NSError!, object: AnyObject!) {
        assert((nil == error),"oops -- \(error)")
        NSLog("\(__FUNCTION__) - object ignored.")
    }

    func sptPlaylistList_playlistsForUserWithSession(#callback: SPTRequestCallback) -> Void {
        SPTPlaylistList.playlistsForUserWithSession(self.currentSession, callback: callback)
    }
    func sptPlaylistSnapshot_playlistWithURI(uri: NSURL, callback: SPTRequestCallback) -> Void {
        SPTPlaylistSnapshot.playlistWithURI(uri, session: self.currentSession, callback: callback)
    }
    func sptPlaylistList_createPlaylistWithName(name: String, callback: SPTPlaylistCreationCallback) -> Void {
        SPTPlaylistList.createPlaylistWithName(name, publicFlag:true, session:self.currentSession, callback: callback)
    }
    func sptPlaylistSnapshot_addTrackToPlaylist(sptPlaylistSnapshot: SPTPlaylistSnapshot, track: SPTTrack, callback: SPTErrorableOperationCallback) -> Void {
        var nsArrTracks: NSArray = NSArray(array:[track])
        sptPlaylistSnapshot.addTracksToPlaylist(nsArrTracks as [AnyObject], withSession:self.currentSession, callback: callback)
    }

}
