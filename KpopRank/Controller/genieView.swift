import UIKit
import Firebase
import FirebaseFirestore

class genieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var genieList: UITableView!
    var songs : [Song] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cehckNetworkConect() == true {
            fectchData()
            self.view.layoutIfNeeded()
        } else {
            DispatchQueue.main.async {
                popupError(currentView: self)
            }
        }
        checkDataChanging(currentView: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        genieList.reloadData()
        self.view.layoutIfNeeded()
        checkDataChanging(currentView: self)

    }
    
    func fectchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("from", isEqualTo: "Genie").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var count : Int = 0
                    for document in querySnapshot!.documents {
                        guard let title = document.data()["title"] as? String else {return}
                        guard let artist = document.data()["artist"] as? String else {return}
                        guard let url = document.data()["url"] as? String else {return}
                        guard let rank = document.data()["rank"] as? Int else {return}
                        guard let from = document.data()["from"] as? String else {return}
                        let song : Song = Song(title : title, artist : artist, url : url,
                            rank: rank, from : from)
                        self.songs.append(song)
                        count += 1
                        if count == 100 {
                            break
                        }
                }
                    self.genieList.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewCellHeight = tableView.frame.width / 5
        return tableViewCellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = URL(string: songs[indexPath.row].url)
        var albumart = Data()
        do {
            albumart = try Data(contentsOf: url!)
            } catch {
                popupError(currentView: self)
            }
        let cell = genieList.dequeueReusableCell(withIdentifier: "genieCell", for: indexPath) as! genieCell
        songs = songs.sorted(by: {$0.rank < $1.rank})
        cell.labelTitle.text = songs[indexPath.row].title
        cell.labelArtist.text = songs[indexPath.row].artist
        cell.labeIndex.text = "\(indexPath.row+1)"
        cell.genieAlbumart.image = UIImage(data: albumart)
        return cell

    }
}

