Summary
=======
This project demonstrates spt ios sdk issue #394 -- https://github.com/spotify/ios-sdk/issues/394

In summary: with spotify ios sdk `beta-10`, the ability to retrieve playlists using

     SPTPlaylistList.playlistsForUserWithSession

was broken.

Using this project to demonstrate issue
=======================================
1.  change `DefaultSpotifyProxyImpl.swift` to add your app and client-id.
1.  test with the `beta-10` `Spotify.framework`, which is the framework in this repo.
1.  change `Spotify.framework` to `beta-9`
1.  retest -- the issue goes away, you can use the app to list playlist items one-by-one.
