import UIKit

class melonCell: UITableViewCell {

    @IBOutlet weak var melonRank: UILabel!
    @IBOutlet weak var melonAlbumart: UIImageView!
    @IBOutlet weak var melonTitle: UILabel!
    @IBOutlet weak var melonArtist: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
