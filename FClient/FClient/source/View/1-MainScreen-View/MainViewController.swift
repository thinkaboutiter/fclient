//
//  MainViewController.swift
//  FClient
//
//  Created by Boyan Yankov on W25 21/06/2016 Tue.
//  Copyright © 2016 Boyan Yankov. All rights reserved.
//

import UIKit
import SimpleLogger

// MARK: - MainViewController

class MainViewController: BaseViewController, MainViewModelConsumable {

    // MARK: Properties
    
    private(set) var viewModel: MainViewModel? {
        didSet {
            self.viewModel?.updateView(self)
        }
    }
    
    // MARK: Cascaded accessors
    
    func updateViewModel(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: Intitialization
    
    required init(withViewModel viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        Logger.logInfo().logMessage("\(self) \(#line) \(#function) » \(String(MainViewController.self)) deinitialized")
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set viewModel object
        self.viewModel = MainViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func configureUI() {
        self.title = self.viewModel?.title
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
