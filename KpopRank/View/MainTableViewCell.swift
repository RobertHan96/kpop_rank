import UIKit

class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var top3Title: UILabel!
    @IBOutlet weak var top3Artist: UILabel!
    @IBOutlet weak var top3Rank: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
