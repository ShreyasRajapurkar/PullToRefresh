//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Shreyas Rajapurkar on 03/12/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let pullToRefreshViewController = PullToRefreshViewController(viewModel: PullToRefreshViewModel())
        pullToRefreshViewController.modalPresentationStyle = .fullScreen
        present(pullToRefreshViewController, animated: true, completion: nil)
    }
}

