//
//  Success.swift
//  PullToRefresh
//
//  Created by Shreyas Rajapurkar on 04/12/22.
//

import Foundation

struct SuccessOrFailure: Codable {
    let success: Bool
    init(success: Bool) {
        self.success = success
    }
}
