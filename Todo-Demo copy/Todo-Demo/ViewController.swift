//
//  ViewController.swift
//  Todo-Demo
//
//  Created by Himanshu on 21/02/19.
//  Copyright © 2019 qilo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var todoAdd: UITextField!
    @IBOutlet weak var addButton: UIButton!
  
    @IBOutlet weak var overdueLabel: UILabel!
    
    @IBOutlet weak var overdueTabel: UITableView!
    
    @IBOutlet weak var todayLabel: UILabel!
    
    @IBOutlet weak var todayTabel: UITableView!
    
    @IBOutlet weak var tomLabel: UILabel!
    
    @IBOutlet weak var tomTable: UITableView!
    
    //    var tableOverdue:UITableView = {
//        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width - 24, height: 0))
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.layer.masksToBounds = true
//        tableView.layer.shadowOpacity = 0.5
//        tableView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
//        tableView.layer.shadowColor = UIColor.gray.cgColor
//        tableView.separatorStyle = .none
//        return tableView
//    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        view.addSubview(tableOverdue)
        
//        tableOverdue.centerXAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: 3, multiplier: 4);        tableOverdue.rightAnchor.constraint(equalTo: UIView.rightAnchor).isActive = true
//        tableOverdue.topAnchor.constraint(equalTo: goalPickerViewBottomLine.bottomAnchor).isActive = true
//        tableOverdue.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    
    
    
    }


}

