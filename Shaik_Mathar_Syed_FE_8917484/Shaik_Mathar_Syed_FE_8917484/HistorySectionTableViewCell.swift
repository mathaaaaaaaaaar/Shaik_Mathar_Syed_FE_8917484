//
//  HistorySectionTableViewCell.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit

class HistorySectionTableViewCell: UITableViewCell {


    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
