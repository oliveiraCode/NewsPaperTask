//
//  SubscriptionViewModel.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation

final class SubscriptionViewModel {
    enum LoadState {
        case idle
        case loading
        case success(Record)
        case failure(Error)
    }

    private let service: SubscriptionServiceType
    private let coreDataManager: CoreDataManager = .shared

    private(set) var loadState: LoadState = .idle {
        didSet {
            didUpdateState?(loadState)
        }
    }
    
    var didUpdateState: ((LoadState) -> Void)?

    init(service: SubscriptionServiceType) {
        self.service = service
    }
    
    func fetchSubscriptionData() {
        if let storedResponse = coreDataManager.fetchResponse() {
            service.fetchData { [weak self] result in
                switch result {
                case .success(let newResponse):
                    if newResponse.metadata.createdAt > storedResponse.metadata.createdAt {
                        // Data updated from API, save the new data locally
                        self?.coreDataManager.saveResponse(newResponse)
                        self?.loadState = .success(newResponse.record)
                    } else {
                        // Data not updated, use local values
                        self?.loadState = .success(storedResponse.record)
                    }
                case .failure:
                    // Failed to get data from API, use local values
                    self?.loadState = .success(storedResponse.record)
                }
            }
        } else {
            // There is no local values, fetch data from API
            service.fetchData { [weak self] result in
                switch result {
                case .success(let newResponse):
                    self?.coreDataManager.saveResponse(newResponse)
                    self?.loadState = .success(newResponse.record)
                case .failure(let error):
                    self?.loadState = .failure(error)
                }
            }
        }
    }
}
