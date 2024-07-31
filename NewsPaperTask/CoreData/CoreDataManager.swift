//
//  CoreDataManager.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsPaperTask")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    // MARK: - Save
    
    func saveResponse(_ response: Response) {
        let context = self.context
        let responseEntity = ResponseEntity(context: context)
        responseEntity.id = response.id
        
        let recordEntity = RecordEntity(context: context)
        recordEntity.headerLogoUrl = response.record.headerLogoUrl
        
        let subscriptionEntity = SubscriptionEntity(context: context)
        subscriptionEntity.offerPageStyle = response.record.subscription.offerPageStyle
        subscriptionEntity.coverImageUrl = response.record.subscription.coverImageUrl
        subscriptionEntity.subscribeTitle = response.record.subscription.subscribeTitle
        subscriptionEntity.subscribeSubtitle = response.record.subscription.subscribeSubtitle
        subscriptionEntity.benefits = response.record.subscription.benefits as NSObject
        subscriptionEntity.disclaimer = response.record.subscription.disclaimer
        
        let offerEntities = response.record.subscription.offers.map { offer -> OfferEntity in
            let offerEntity = OfferEntity(context: context)
            offerEntity.id = offer.id
            offerEntity.price = offer.price
            offerEntity.information = offer.information
            return offerEntity
        }
        subscriptionEntity.offers = Set(offerEntities) as NSSet
        
        recordEntity.subscription = subscriptionEntity
        responseEntity.record = recordEntity
        
        saveContext()
    }
    
    // MARK: - Update
    
    func updateResponse(withId id: String, newData: Response) {
        let context = self.context
        let fetchRequest: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let responseEntity = results.first {
                // Atualize o responseEntity com newData
                if let recordEntity = responseEntity.record {
                    recordEntity.headerLogoUrl = newData.record.headerLogoUrl

                    if let subscriptionEntity = recordEntity.subscription {
                        subscriptionEntity.offerPageStyle = newData.record.subscription.offerPageStyle
                        subscriptionEntity.coverImageUrl = newData.record.subscription.coverImageUrl
                        subscriptionEntity.subscribeTitle = newData.record.subscription.subscribeTitle
                        subscriptionEntity.subscribeSubtitle = newData.record.subscription.subscribeSubtitle
                        subscriptionEntity.benefits = newData.record.subscription.benefits as NSObject
                        subscriptionEntity.disclaimer = newData.record.subscription.disclaimer

                        let newOfferEntities = newData.record.subscription.offers.map { offer -> OfferEntity in
                            let offerEntity = OfferEntity(context: context)
                            offerEntity.id = offer.id
                            offerEntity.price = offer.price
                            offerEntity.information = offer.information
                            return offerEntity
                        }
                        
                        if let existingOffers = subscriptionEntity.offers {
                            for offerEntity in existingOffers {
                                context.delete(offerEntity as! NSManagedObject)
                            }
                        }
                        
                        subscriptionEntity.offers = Set(newOfferEntities) as NSSet
                    }
                }
                saveContext()
            }
        } catch {
            print("Failed to update response: \(error)")
        }
    }
    
    // MARK: - Fetch
        
    func fetchResponse() -> Response? {
        let context = self.context
        let fetchRequest: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let responseEntity = results.first {
                let recordEntity = responseEntity.record
                let subscriptionEntity = recordEntity?.subscription
                
                let offerEntities = subscriptionEntity?.offers as? Set<OfferEntity> ?? []
                let offers = offerEntities.map { offerEntity -> Offer in
                    Offer(
                        id: offerEntity.id ?? "",
                        price: offerEntity.price,
                        information: offerEntity.information ?? ""
                    )
                }
                
                let response = Response(
                    id: responseEntity.id ?? "",
                    record: Record(
                        headerLogoUrl: recordEntity?.headerLogoUrl ?? "",
                        subscription: Subscription(
                            offerPageStyle: subscriptionEntity?.offerPageStyle ?? "",
                            coverImageUrl: subscriptionEntity?.coverImageUrl ?? "",
                            subscribeTitle: subscriptionEntity?.subscribeTitle ?? "",
                            subscribeSubtitle: subscriptionEntity?.subscribeSubtitle ?? "",
                            offers: offers,
                            benefits: subscriptionEntity?.benefits as? [String] ?? [],
                            disclaimer: subscriptionEntity?.disclaimer ?? ""
                        )
                    ),
                    metadata: Metadata(
                        name: responseEntity.metadata?.name ?? "",
                        readCountRemaining: Int(responseEntity.metadata?.readCountRemaining ?? 0),
                        timeToExpire: Int(responseEntity.metadata?.timeToExpire ?? 0),
                        createdAt: responseEntity.metadata?.createdAt ?? ""
                    )
                )
                return response
            }
        } catch {
            print("Failed to fetch saved response: \(error)")
        }
        return nil
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save response: \(error)")
        }
    }
}
