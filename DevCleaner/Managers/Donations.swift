//
//  Donations.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 17.06.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import StoreKit

// MARK: Donations Delegate
public protocol DonationsDelegate: class {
    func donations(_ donations: Donations, didReceive products: [Donations.Product])
    
    func transactionDidStart(for product: Donations.Product)
    func transactionIsBeingProcessed(for product: Donations.Product)
    func transactionDidFinish(for product: Donations.Product, error: Error?)
}

// MARK: - Donations Manager
public final class Donations: NSObject {
    // MARK: Types
    public struct Product {
        public enum Kind: String {
            case smallCoffee = "SMALL_COFFEE"
            case bigCoffee = "BIG_COFFEE"
            case lunch = "LUNCH"
            
            public static var allKinds: [Kind] {
                return [.smallCoffee, .bigCoffee, .lunch]
            }
        }
        
        public let kind: Kind
        public let skProduct: SKProduct
        
        public let price: String
        public let info: String
        
        public var identifier: String {
            return self.kind.rawValue
        }
        
        public init?(product: SKProduct) {
            guard let kind = Kind(rawValue: product.productIdentifier) else {
                return nil
            }
            
            self.kind = kind
            self.skProduct = product
            
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.locale = product.priceLocale
            
            self.price = nf.string(from: self.skProduct.price) ?? ""
            self.info = self.skProduct.localizedTitle
        }
    }
    
    // MARK: Properties
    private var productsRequest: SKProductsRequest? = nil
    private var iapProducts: [Product] = []
    
    public weak var delegate: DonationsDelegate? = nil
    
    public static let shared = Donations()
    
    // MARK: Initialization
    private override init() {
        super.init()
    }
    
    // MARK: Transaction observation
    public func startObservingTransactionsQueue() {
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: Purchasing donations
    public func fetchProductsInfo() {
        let donationProductsIds = Product.Kind.allKinds.map { $0.rawValue }
        
        self.productsRequest = SKProductsRequest(productIdentifiers: Set(donationProductsIds))
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    public func buy(product: Product) {
        let payment = SKMutablePayment(product: product.skProduct)
        payment.quantity = 1
        
        SKPaymentQueue.default().add(payment)
        
        self.delegate?.transactionDidStart(for: product)
    }
}

extension Donations: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.iapProducts = response.products.compactMap { Product(product: $0) }
        
        self.delegate?.donations(self, didReceive: self.iapProducts)
    }
}

extension Donations: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            // get our product related to transaction
            guard let transactionProduct = self.iapProducts.filter( { $0.identifier == transaction.payment.productIdentifier } ).first else {
                log.warning("Donations: Updated transaction thats product have unknown identifier or not yet fetched: \(transaction.payment.productIdentifier)")
                
                // we can safely finish such transaction since we don't deliver any special stuff
                queue.finishTransaction(transaction)
                
                continue
            }
            
            switch transaction.transactionState {
                case .purchasing, .deferred:
                    self.delegate?.transactionIsBeingProcessed(for: transactionProduct)
                case .purchased, .failed:
                    self.delegate?.transactionDidFinish(for: transactionProduct, error: transaction.error)
                    queue.finishTransaction(transaction)
                case .restored:
                    // we don't support restored purchases here, so no delegate
                    queue.finishTransaction(transaction)
                @unknown default:
                    // in case of any future cases, just finish transaction which seems sensible
                    queue.finishTransaction(transaction)
            }
        }
    }
}
