//
//  Subscription.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation

struct Response: Codable {
    let id: String
    let record: Record
    let metadata: Metadata
}

struct Record: Codable {
    let headerLogoUrl: String
    let subscription: Subscription
    
    enum CodingKeys: String, CodingKey {
        case headerLogoUrl = "header_logo"
        case subscription
    }
}

struct Subscription: Codable {
    let offerPageStyle: String
    let coverImageUrl: String
    let subscribeTitle: String
    let subscribeSubtitle: String
    let offers: [Offer]
    let benefits: [String]
    let disclaimer: String
}

extension Subscription {

    private enum CodingKeys: String, CodingKey {
        case offerPageStyle = "offer_page_style"
        case coverImageUrl = "cover_image"
        case subscribeTitle = "subscribe_title"
        case subscribeSubtitle = "subscribe_subtitle"
        case offers
        case benefits
        case disclaimer
    }
    
    private enum OfferCodingKeys: CodingKey {
        case id0, id1
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offerPageStyle = try container.decode(String.self, forKey: .offerPageStyle)
        coverImageUrl = try container.decode(String.self, forKey: .coverImageUrl)
        subscribeTitle = try container.decode(String.self, forKey: .subscribeTitle)
        subscribeSubtitle = try container.decode(String.self, forKey: .subscribeSubtitle)
        benefits = try container.decode([String].self, forKey: .benefits)
        disclaimer = try container.decode(String.self, forKey: .disclaimer)
        
        // Decode the offers dictionary
        let offersContainer = try container.nestedContainer(keyedBy: OfferCodingKeys.self, forKey: .offers)
        var offersArray: [Offer] = []
        
        for key in offersContainer.allKeys {
            var offer = try offersContainer.decode(Offer.self, forKey: key)
            offer.id = key.stringValue
            offersArray.append(offer)
        }
        
        offers = offersArray
    }
}

struct Offer: Codable {
    var id: String
    let price: Double
    let information: String
}

extension Offer {
    
    enum CodingKeys: String, CodingKey {
        case price
        case information = "description"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.price = try container.decode(Double.self, forKey: .price)
        self.information = try container.decode(String.self, forKey: .information)
        self.id = ""
    }
}

struct Metadata: Codable {
    let name: String?
    let readCountRemaining: Int
    let timeToExpire: Int
    let createdAt: String
}
