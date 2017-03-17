//
//  FindFilterTableViewController.swift
//  MyCity311
//
//  Created by Krutika Mac Mini on 12/23/16.
//  Copyright © 2016 Kahuna Systems. All rights reserved.
//

import UIKit
import MFSideMenu

@objc protocol FindFilterTableViewControllerDelegate: class {
    @objc optional func filtersTableViewController(selectedFilters: [FilterObject])
}

class FindFilterTableViewController: UITableViewController {
    var filterArray: [FilterObject]!
    var selectedFiltersArray: [FilterObject]!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var barButtonItem1: UIBarButtonItem!
    @IBOutlet weak var selectAll: UIBarButtonItem!
    @IBOutlet weak var unselectAll: UIBarButtonItem!
    weak var delegate: FindFilterTableViewControllerDelegate?
    @IBOutlet weak var navTitleLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if (selectedFiltersArray == nil) {
            selectedFiltersArray = [FilterObject]()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)

        self.navigationController?.toolbar.setBackgroundImage(UIImage(named: "header_bg.png"), forToolbarPosition: .bottom, barMetrics: .default)
        self.navigationController?.toolbar.tintColor = UIColor.white
        self.navigationController?.toolbar.barTintColor = UIColor.darkGray


        self.navTitleLabel.text = "filtersNavTitle".localized

        let button1 = barButtonItem!.customView as! UIButton
        button1.setTitle("CancelButtonLabel".localized, for: .normal)

        let button2 = barButtonItem1!.customView as! UIButton
        button2.setTitle("doneBtnTitle".localized, for: .normal)

        self.selectAll.title = "selectAllButtonTitle".localized

        self.unselectAll.title = "unselectAllButtonTitle".localized

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let frameworkBundleId = "org.cocoapods.FindViewControl"
        let bundle = Bundle(identifier: frameworkBundleId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

            let nib = bundle?.loadNibNamed("FilterCell", owner: self, options: nil)
            if nib!.count > 0 {
                cell = nib![0] as? UITableViewCell
            }
        }

        let titleLabel: UILabel = cell!.viewWithTag(1) as! UILabel
        let iconImage: UIImageView = cell!.viewWithTag(2) as! UIImageView
        let filterType: FilterObject = self.filterArray[indexPath.row]
        titleLabel.text = filterType.filterValue

        if selectedFiltersArray.contains(filterType) {
            iconImage.image = UIImage(named: "tick.png", in: bundle, compatibleWith: nil)
        }
            else {
            iconImage.image = UIImage(named: "untick.png", in: bundle, compatibleWith: nil)
        }

        cell?.selectionStyle = UITableViewCellSelectionStyle.none

        return cell!

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let frameworkBundleId = "org.cocoapods.FindViewControl"
        let bundle = Bundle(identifier: frameworkBundleId)
        let filterType: FilterObject = self.filterArray[indexPath.row]

        let cell: UITableViewCell = tableView.cellForRow(at: indexPath as IndexPath)!
        let iconImage: UIImageView = cell.viewWithTag(2) as! UIImageView

        if selectedFiltersArray.contains(filterType) {
            iconImage.image = UIImage(named: "untick.png", in: bundle, compatibleWith: nil)
            if let index = selectedFiltersArray.index(of: filterType) {
                selectedFiltersArray.remove(at: index)
            }

        }
            else {
            iconImage.image = UIImage(named: "tick.png", in: bundle, compatibleWith: nil)
            selectedFiltersArray.append(filterType)
        }
    }


    @IBAction func selectAllClicked() {
        selectedFiltersArray.removeAll()
        selectedFiltersArray = [FilterObject]()
        selectedFiltersArray.append(contentsOf: self.filterArray)
        self.tableView.reloadData()

    }

    @IBAction func unselectAllClicked() {
        selectedFiltersArray.removeAll()
        self.tableView.reloadData()

    }

    @IBAction func done_button_clicked() {
        self.menuContainerViewController.toggleRightSideMenuCompletion({

            DispatchQueue.main.async {
                self.delegate?.filtersTableViewController!(selectedFilters: self.selectedFiltersArray)
            }

        })
    }

    @IBAction func cancel_button_clicked() {
        self.menuContainerViewController.toggleRightSideMenuCompletion(nil)
    }


}
