import UIKit
import Firebase
import FirebaseFirestore

protocol SendSerchData {
    func sendData(data : String)
    }

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mainTableview: UITableView!
    let sections = ["Melon", "Bugs", "Genie"]
    var songs : [Song] = []
    var searchKeyword : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        DispatchQueue.main.async {
            if cehckNetworkConect() == true {
                self.fetchData()
            } else {
                DispatchQueue.main.async {
                    popupError(currentView: self)
                }
            }
            checkDataChanging(currentView: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainTableview.reloadData()
        self.view.layoutIfNeeded()
        checkDataChanging(currentView: self)
    }

    @IBAction func searchSong(_ sender: UIButton) {
        performSegue(withIdentifier: "search", sender: nil)
        
    }
        
    func textFieldShouldReturn(_ searchField : UITextField!)-> Bool {
        searchField.resignFirstResponder() //엔터키 터치시 텍스트 필드 비활성화
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let searchViewControoler = segue.destination as? searchViewController else { return}
        if let text = searchField.text {
            searchViewControoler.searchKeyword = text
        }
    }
    // url스트링을 기반으로 이미지 Data를 생성하는 함수, 각 사이트에 맞게 뿌려줘야 하므로 별도로 함수로 구현
    func makeImageUrl(url : String) -> Data  {
        var albumUrlData : Data = Data()
        do {
            let urlString = URL(string: url)
            let data = try Data(contentsOf: urlString!)
            albumUrlData = data
        }catch {
            popupError(currentView: self)
        }
        return albumUrlData
    }

    func fetchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("rank", isLessThan: 4).getDocuments() { (querySnapshot, err) in
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
                       if count == 9 {
                            break
                        }
                }
                self.mainTableview.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count/3
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewCellHeight = tableView.frame.width / 5
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let Maincell = mainTableview.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
        let melonTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Melon"}
        let bugsTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Bugs"}
        let genieTop3 : [Song] =
            songs.filter { (song) -> Bool in
                return song.from == "Genie"}

        if indexPath.section == 0 {
            Maincell.top3Title.text = melonTop3[indexPath.row].title
            Maincell.top3Artist.text = melonTop3[indexPath.row].artist
            Maincell.rankImage.image = UIImage(data: makeImageUrl(url: melonTop3[indexPath.row].url))
            Maincell.top3Rank.text = "\(melonTop3[indexPath.row].rank)"
        } else if indexPath.section == 1 {
            Maincell.top3Title.text = bugsTop3[indexPath.row].title
            Maincell.top3Artist.text = bugsTop3[indexPath.row].artist
            Maincell.rankImage.image = UIImage(data: makeImageUrl(url: bugsTop3[indexPath.row].url))
            Maincell.top3Rank.text = "\(bugsTop3[indexPath.row].rank)"
        } else if indexPath.section == 2 {
            Maincell.top3Title.text = genieTop3[indexPath.row].title
            Maincell.top3Artist.text = genieTop3[indexPath.row].artist
            Maincell.rankImage.image = UIImage(data: makeImageUrl(url: genieTop3[indexPath.row].url))
            Maincell.top3Rank.text = "\(genieTop3[indexPath.row].rank)"
        } else {
        
        }
        return Maincell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        let headerTitle = view as! UITableViewHeaderFooterView
        headerTitle.textLabel?.font = UIFont.systemFont(ofSize: 15)
    }
        
}
