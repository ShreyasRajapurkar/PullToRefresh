//
//  PullToRefreshViewModel.swift
//  PullToRefresh
//
//  Created by Shreyas Rajapurkar on 04/12/22.
//

import Foundation

class PullToRefreshViewModel {
    let circleDiameter = 80.0
    let refreshContainerDiameter = 90.0
    let cardLabelCornerRadius = 20.0
    let refreshContainerBorderWidth = 10.0
    let cardLabelPadding = 20.0
    
    func hitSuccessAPI(completion: @escaping () -> Void) {
        let successResource = SuccessResource()
        NetworkingClient.performRequest(resource: successResource) { (result: Result<SuccessOrFailure, Error>) in
            completion()
        }
    }
    
    func hitFailureAPI(completion: @escaping () -> Void) {
        let failureResource = FailureResource()
        NetworkingClient.performRequest(resource: failureResource) { (result: Result<SuccessOrFailure, Error>) in
            completion()
        }
    }
}
