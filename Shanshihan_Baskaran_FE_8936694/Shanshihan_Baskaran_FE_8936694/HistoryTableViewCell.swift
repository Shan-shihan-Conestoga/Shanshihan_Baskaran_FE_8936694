//
//  HistoryTableViewCell.swift
//  Shanshihan_Baskaran_FE_8936694
//
//  Created by user233228 on 12/11/23.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var newsAuthorLabel: UILabel!
    @IBOutlet weak var newsSourceLabel: UILabel!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var fromScreenLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
