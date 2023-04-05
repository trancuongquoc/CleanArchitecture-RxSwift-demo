//
//  InsuranceChoicesView.swift
//
//  Created by Quoc Cuong on 27/02/2023.
//

import UIKit

protocol InsuranceChoicesViewDelegate: AnyObject {
    func insuranceChoicesViewDidRecognizeTapAtLocation()
}

@IBDesignable
final class InsuranceChoicesView: BaseXibView {
    weak var delegate: InsuranceChoicesViewDelegate?
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var programmeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib(nibName: "InsuranceTableViewCell", bundle: nil), forCellReuseIdentifier: "InsuranceTableViewCell")
        setupViews()
    }
    
    func setupViews() {
        let paragraphStyle = NSMutableParagraphStyle()
        headingLabel.textColor = .primaryTextColor
        headingLabel.attributedText = NSMutableAttributedString(string: "MEMBERSHIP_DETAILS".localized, attributes: [.paragraphStyle: paragraphStyle, .font: AppFont.primaryFontRegular20])
        
        notesLabel.textColor = .primaryTextColor
        notesLabel.attributedText = NSMutableAttributedString(string: "MEMBERSHIP_DETAILS_DESC".localized, attributes: [.paragraphStyle: paragraphStyle, .font: AppFont.primaryFontRegular14])
        
        locationLabel.textColor = .primaryTextColor
        locationLabel.attributedText = NSMutableAttributedString(string: "LOCATION".localized, attributes: [.paragraphStyle: paragraphStyle, .font: AppFont.primaryFontRegular16])
        
        programmeLbl.textColor = UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1)
        programmeLbl.attributedText = NSMutableAttributedString(string: "MEMBERSHIP_PROGRAMME".localized, attributes: [.paragraphStyle: paragraphStyle, .font: AppFont.primaryFontRegular16])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapLocation(_:)))
        locationContainer.addGestureRecognizer(tap)
        
        locationNameLbl.textColor = .primaryTextColor
    }
    
    @objc
    func handleTapLocation(_ sender: UITapGestureRecognizer) {
        delegate?.insuranceChoicesViewDidRecognizeTapAtLocation()
    }
}
