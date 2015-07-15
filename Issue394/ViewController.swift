import UIKit

class ViewController: UIViewController {

    var sptProx: ISpotifyProxy!
    var playlistMgr: IPlaylistManager!
    private(set) var previousPlaylistNames = [String]()

    @IBAction func loginDidTouchDown(sender: AnyObject) {
        NSLog("\(__FUNCTION__) invoked.")
        sptProx.loginViaUI()
    }
    func loggingRandomPlaylistNameCallback(playlistName: String) -> Void {
        NSLog("got playlist name = \(playlistName)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sptProx = DefaultSpotifyProxyImpl(underneathViewController: self as UIViewController)
        playlistMgr = DefaultSpotifyPlaylistManager(spotifyProxy: sptProx)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var randomPlaylistButton: UIButton!
    
    @IBAction func randomPlaylistButtonDidTouchDown(sender: AnyObject) {
        playlistMgr.getRandomPlaylistName(previousPlaylistNames: self.previousPlaylistNames, callback: {
            (input: String) -> () in
            self.previousPlaylistNames.append(input)
            self.randomPlaylistNameLabel.text = input
        })
    }

    @IBOutlet weak var randomPlaylistNameLabel: UILabel!

}

