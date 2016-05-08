//
//  ViewController.swift
//  SLRefreshDemo
//
//  Created by WangZHW on 16/5/8.
//  Copyright © 2016年 RobuSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    weak var refresh: RefreshHeaderView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.layoutIfNeeded()
        tableView.dataSource = self
        refresh = RefreshHeaderView(scrollView: self.tableView, haveNav: true)
        refresh.refreshClosure = {
            self.endRefresh(3)
        }
        refresh.starRefreshing()
    }
    
    func endRefresh(time: Double) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()){ _ in
            self.refresh.endRefreshing()
        }
    }
    

    @IBOutlet weak var tableView: UITableView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil  {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = "数据－－－>\(indexPath.row)"
        return cell!
    }
}


