//
//  PullToRefreshViewController.swift
//  PullToRefresh
//
//  Created by Shreyas Rajapurkar on 03/12/22.
//

import Foundation
import UIKit

class PullToRefreshViewController: UIViewController {
    
    let pullToRefreshView = UIView()
    let refreshContainerView = UIView()
    let viewModel: PullToRefreshViewModel
    let cardLabel = UILabel()
    var refreshViewYConstraint: NSLayoutConstraint?
    var initialPosition: CGFloat?
    
    init(viewModel: PullToRefreshViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        view.addSubview(refreshContainerView)
        view.addSubview(cardLabel)
        view.addSubview(pullToRefreshView)
    }
    
    private func setupViewLayout() {
        // Pull to refresh view
        pullToRefreshView.backgroundColor = UIColor.black
        pullToRefreshView.layer.cornerRadius = viewModel.circleDiameter / 2
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePull))
        pullToRefreshView.addGestureRecognizer(panGestureRecognizer)
        
        // Refresh container view
        refreshContainerView.layer.cornerRadius = viewModel.refreshContainerDiameter / 2
        refreshContainerView.layer.borderColor = UIColor.white.cgColor
        refreshContainerView.layer.borderWidth = viewModel.refreshContainerBorderWidth
        
        // Card view
        cardLabel.backgroundColor = UIColor.white
        cardLabel.layer.cornerRadius = viewModel.cardLabelCornerRadius
        cardLabel.textAlignment = .center
        cardLabel.clipsToBounds = true
    }
    
    private func setupConstraints() {
        pullToRefreshView.translatesAutoresizingMaskIntoConstraints = false
        refreshContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardLabel.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()

        let refreshViewYConstraint = pullToRefreshView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        self.refreshViewYConstraint = refreshViewYConstraint
        constraints.append(pullToRefreshView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(refreshViewYConstraint)
        constraints.append(pullToRefreshView.heightAnchor.constraint(equalToConstant: viewModel.circleDiameter))
        constraints.append(pullToRefreshView.widthAnchor.constraint(equalToConstant: viewModel.circleDiameter))
        
        constraints.append(refreshContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20))
        constraints.append(refreshContainerView.heightAnchor.constraint(equalToConstant: viewModel.refreshContainerDiameter))
        constraints.append(refreshContainerView.widthAnchor.constraint(equalToConstant: viewModel.refreshContainerDiameter))
        constraints.append(refreshContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor))

        constraints.append(cardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewModel.cardLabelPadding))
        constraints.append(cardLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: viewModel.cardLabelPadding))
        constraints.append(cardLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewModel.cardLabelPadding))
        constraints.append(cardLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5))
        
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewLayout()
        view.backgroundColor = UIColor.darkGray
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialPosition == nil {
            initialPosition = pullToRefreshView.center.y
        }
    }
    
    @objc
    func handlePull(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            if isInOrCloseToContainer() {
                handleSuccess()
            } else {
                snapToInitialPosition()
                handleFailure()
            }

            return
        }

        let translation = gesture.translation(in: view)
        let newYPosition = translation.y + (initialPosition ?? 0)

        /**
         Return early if the new position is above the starting point or below the refresh container's bottom
         */
        if newYPosition > refreshContainerView.center.y || newYPosition < view.center.y {
            return
        }

        refreshViewYConstraint?.constant = translation.y
    }

    /**
     Checks if the pull to refresh view is inside (or close enough) to the container view so as to trigger a success response
     */
    private func isInOrCloseToContainer() -> Bool {
        let actualOffset = abs(pullToRefreshView.frame.origin.y - refreshContainerView.frame.origin.y)
        let acceptableOffset = 10.0
        if (0...acceptableOffset).contains(actualOffset) {
            return true
        }

        return false
    }

    private func handleSuccess() {
        snapToFinalPosition()
        animateBorder()
        viewModel.hitSuccessAPI { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.cardLabel.text = "SUCCESS"
            strongSelf.pullToRefreshView.isHidden = true
            strongSelf.refreshContainerView.isHidden = true
        }
    }
    
    private func handleFailure() {
        pullToRefreshView.isUserInteractionEnabled = false
        viewModel.hitFailureAPI { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let alertController = UIAlertController(title: "Failure", message: "Please try again", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            strongSelf.present(alertController, animated: true, completion: nil)
            strongSelf.pullToRefreshView.isUserInteractionEnabled = true
        }
    }

    /**
     Snap the pull refresh view to final position if the user is close to it (allows the user for some error)
     */
    private func snapToFinalPosition() {
        if let initialPosition = initialPosition {
            refreshViewYConstraint?.constant = refreshContainerView.center.y - initialPosition
        }
    }
    
    private func snapToInitialPosition() {
        refreshViewYConstraint?.constant = 0
    }

    private func animateBorder() {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.blue.cgColor
        animation.toValue = UIColor.green.cgColor
        animation.duration = 1.0
        animation.repeatCount = .infinity
        refreshContainerView.layer.add(animation, forKey: "borderColor")
    }
}
