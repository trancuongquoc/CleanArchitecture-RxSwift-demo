//
//  InsuranceTableViewCell.swift
//
//  Created by Quoc Cuong on 27/02/2023.
//
import UIKit
class InsuranceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var insurerLbl: UILabel!
    @IBOutlet weak var seperator: UIView!
    
    var insurer: Insurer! {
        didSet{
            var insurerName = ""
            if insurer.insurerType == InsurerType.dhipaya {
                if Locale.preferredLanguage == "th" {
                    insurerName = Localization.dhipayaThai
                } else {
                    insurerName = insurer.insurerName + " \(Localization.insuranceText)"
                }
            } else {
                insurerName = insurer.insurerName
            }
            
            insurerLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let paragraphStyle = NSMutableParagraphStyle()
            
            insurerLbl.attributedText = NSMutableAttributedString(string: insurerName, attributes: [.kern: 0.2, .paragraphStyle: paragraphStyle])
            
            if insurer.insurerImg != "" {
                AppManager.shared.dataAdapter.loadAsyncFrom(url: insurer.insurerImg) { [weak self] (image) in
                    
                    if let image = image {
                        self?.logoImgView.image = image
                    } else {
                        self?.logoImgView.image = UIImage(named: "profile-doc")
                    }
                }
            } else {
                logoImgView.image = UIImage(named: "profile-doc")
            }
        }
    }
    
    var insurance: Insurance! {
        didSet{
            var insurerName = ""
            let name = insurance.name ?? ""
            if insurance.type == InsurerType.dhipaya.rawValue {
                insurerName = (Locale.preferredLanguage == "th") ? Localization.dhipayaThai : name + " \(Localization.insuranceText)"
            } else {
                insurerName = name
            }
            
            insurerLbl.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            let paragraphStyle = NSMutableParagraphStyle()
            
            insurerLbl.attributedText = NSMutableAttributedString(string: insurerName, attributes: [.kern: 0.2, .paragraphStyle: paragraphStyle])
            
            if let image = insurance.secondaryLogo, image != "" {
                AppManager.shared.dataAdapter.loadAsyncFrom(url: image) { [weak self] (image) in
                    if let image = image {
                        self?.logoImgView.image = image
                    } else {
                        self?.logoImgView.image = UIImage(named: "profile-doc")
                    }
                }
            } else {
                logoImgView.image = UIImage(named: "profile-doc")
            }
        }
    }
}
