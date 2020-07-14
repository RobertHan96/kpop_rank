import UIKit
import Firebase
import FirebaseFirestore

class MelonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var melonList: UITableView!
    var songs :[Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if cehckNetworkConect() == true {
            fetchData()
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
        melonList.reloadData()
        self.view.layoutIfNeeded()
        checkDataChanging(currentView: self)

    }

    func fetchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("from", isEqualTo: "Melon").getDocuments() { (querySnapshot, err) in
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
                    self.melonList.reloadData()
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
        let melonCell = melonList.dequeueReusableCell(withIdentifier: "melonCell", for: indexPath) as! melonCell
        songs = songs.sorted(by: {$0.rank < $1.rank})
        melonCell.melonTitle.text = songs[indexPath.row].title
        melonCell.melonArtist.text = songs[indexPath.row].artist
        melonCell.melonRank.text = "\(indexPath.row+1)"
        melonCell.melonAlbumart.image = UIImage(data: albumart)
        
        return melonCell
    }
}

