import UIKit
import Firebase
import FirebaseFirestore
import Toast_Swift

class searchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var result: UILabel!
    var searchResult : [Song] = []
    var searchKeyword : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.tableFooterView = UIView()
        DispatchQueue.main.async {
            if self.searchKeyword.count < 1 {
                self.view.makeToast(emtpySearchKeywordWaing, duration: 2.0, position: .center)
            } else {
                self.searchAll(keyword: self.searchKeyword)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                if self.searchResult.count == 0  {
                    self.view.makeToast(noResultSearchWaring ,duration: 2.0, position: .center)
                }
            }
        }
    } 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTableView.reloadData()
        self.view.layoutIfNeeded()
        checkDataChanging(currentView: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewCellHeight = tableView.frame.width / 5
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = URL(string: searchResult[indexPath.row].url)
        var albumart = Data()
        do {
            albumart = try Data(contentsOf: url!)
            } catch {
                popupError(currentView: self)
            }
        let searchViewCell = searchTableView.dequeueReusableCell(withIdentifier: "searchViewCell", for: indexPath) as! searchViewCellTableViewCell
        searchResult = searchResult.sorted(by: {$0.rank < $1.rank})

        searchViewCell.fromLabel.text = searchResult[indexPath.row].from
        searchViewCell.rankLabel.text = "\(searchResult[indexPath.row].rank)위"
        searchViewCell.titleLabel.text = searchResult[indexPath.row].title
        searchViewCell.artistLabel.text = searchResult[indexPath.row].artist
        searchViewCell.searchAlbumart.image = UIImage(data: albumart)
        return searchViewCell
    }
    
    func search(collection : String, field : String, keyword : String) {
        let docRef = Firestore.firestore().collection("\(collection)")        
        docRef.whereField("\(field)", isEqualTo: ("\(keyword)"))
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        guard let title = document.data()["title"] as? String else {return}
                        guard let artist = document.data()["artist"] as? String else {return}
                        guard let url = document.data()["url"] as? String else {return}
                        guard let rank = document.data()["rank"] as? Int else {return}
                        guard let from = document.data()["from"] as? String else {return}
                        let song : Song = Song(title : title, artist : artist, url : url,
                            rank: rank, from : from)
                        self.searchResult.append(song)
                }
                    self.searchTableView.reloadData()
            }
        }
        
    }
    
    func searchAll(keyword : String) {
        search(collection: "songs", field: "title", keyword: "\(keyword)")
        search(collection: "songs", field: "artist", keyword: "\(keyword)")
    }

}
