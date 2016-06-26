//
//  QuotesSelectionViewController.swift
//  FClient
//
//  Created by Boyan Yankov on W25 26/06/2016 Sun.
//  Copyright © 2016 boyankov@yahoo.com. All rights reserved.
//

import UIKit

class QuotesSelectionViewController: BaseViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var quotesSelectionTableView: UITableView!
    
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.quotesSelectionTableView.delegate = self
        self.quotesSelectionTableView.dataSource = self
        
        self.quotesSelectionTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: String(UITableViewCell.self))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UITableViewDataSource protocol

extension QuotesSelectionViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(String(UITableViewCell.self), forIndexPath: indexPath)
        
        cell.textLabel?.text = "Symbol \(indexPath.row)"
        
        return cell
    }
}

// MARK: - UITableViewDelegate protocol

extension QuotesSelectionViewController: UITableViewDelegate {
    
}
