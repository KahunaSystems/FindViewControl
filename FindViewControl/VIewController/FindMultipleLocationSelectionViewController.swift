//
//  FindMultipleLocationSelectionViewController.swift
//  MyCity311
//
//  Created by Kahuna Jenkins on 8/2/16.
//  Copyright © 2016 Kahuna Systems. All rights reserved.
//

import UIKit

protocol FindMultipleLocationViewControllerDelegate: class {
    func locationSelectedFromMultipleLocation(selectedLocationAddress: FindResult)
}

class FindMultipleLocationSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    var locationArray = NSArray()
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var didYouMeanLabel: UILabel!
    weak var delegate: FindMultipleLocationViewControllerDelegate?

    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.setBottomShadowToView(headerView: self.headerView)
        self.customView.layer.masksToBounds = true
        self.customView.layer.cornerRadius = 3.0
        self.didYouMeanLabel.text = "multipleLocHeaderText".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLocaArray(locArray: NSArray) {
        self.locationArray = locArray
        self.locationTableView.reloadData()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationArray.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = self.locationTableView.dequeueReusableCell(withIdentifier: "addressCell")
        let frameworkBundleId = "com.kahuna.FindViewControl"
        let bundle = Bundle(identifier: frameworkBundleId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "addressCell")

            let nib = bundle?.loadNibNamed("MultipleAddressCell", owner: self, options: nil)
            if nib!.count > 0 {
                cell = nib![0] as? UITableViewCell
            }
        }

        cell?.contentView.backgroundColor = UIColor.white
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let dataDict = self.locationArray[indexPath.row] as! FindResult
        print(dataDict.formattedAddress)
        let locLbl = cell?.viewWithTag(1001) as? UILabel
        locLbl?.font = UIFont(name: "AvenirNext-Regular", size: 15.0)
        locLbl?.text = dataDict.formattedAddress
        return cell!
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataDict = self.locationArray[indexPath.row] as! FindResult
        self.dismiss(animated: true, completion: {

            if self.delegate != nil
            {
                self.delegate?.locationSelectedFromMultipleLocation(selectedLocationAddress: dataDict)
            }
        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataDict = self.locationArray[indexPath.row] as! FindResult
        let message = dataDict.formattedAddress
        let constraint = CGSize(width: tableView.frame.size.width - 16, height: 20000.0)
        let height = self.heightForView(text: message!, font: UIFont(name: "AvenirNext-Regular", size: 15.0)!, width: constraint.width)
        return max(height + 20, 40);
    }


    @IBAction func closeBtnAction(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }


    func setBottomShadowToView(headerView: UIView) {

        let layer = headerView.layer
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor(red: 198 / 255, green: 198 / 255, blue: 198 / 255, alpha: 1.0).cgColor
        layer.shadowRadius = 2.5
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }

    //MARK:- Calculate Height According to String
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {

        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }


}
