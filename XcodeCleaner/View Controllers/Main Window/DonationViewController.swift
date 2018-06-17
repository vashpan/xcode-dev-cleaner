//
//  DonationViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 19.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  XcodeCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  XcodeCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with XcodeCleaner.  If not, see <http://www.gnu.org/licenses/>.

import Cocoa
import StoreKit

internal final class DonationViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet weak var xcodeCleanerBenefitsTextField: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    
    @IBOutlet weak var lunchPriceLabel: NSTextField!
    @IBOutlet weak var lunchInfoLabel: NSTextField!
    
    @IBOutlet weak var bigCoffeePriceLabel: NSTextField!
    @IBOutlet weak var bigCoffeeInfoLabel: NSTextField!
    
    @IBOutlet weak var smallCoffeePriceLabel: NSTextField!
    @IBOutlet weak var smallCoffeeInfoLabel: NSTextField!
    
    private var loadingView: LoadingView! = nil

    private var donationProducts: [Donations.Product] = []
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update benefits label
        self.xcodeCleanerBenefitsTextField.attributedStringValue = self.benefitsAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
        
        // update donation products
        Donations.shared.delegate = self
        Donations.shared.fetchProductsInfo()
        
        // start loading
        self.loadingView = LoadingView(frame: self.view.frame)
        self.view.addSubview(self.loadingView, positioned: .below, relativeTo: self.closeButton)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
    }
    
    // MARK: Helpers
    private func benefitsAttributedString(totalBytesCleaned: Int64) -> NSAttributedString {
        let totalBytesString = ByteCountFormatter.string(fromByteCount: totalBytesCleaned, countStyle: .file)
        
        let fontSize: CGFloat = 13.0
        let result = NSMutableAttributedString()
        
        let partOne = NSAttributedString(string: "You saved total of ",
                                           attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
        result.append(partOne)
        
        let partTwo = NSAttributedString(string: "\(totalBytesString)",
                                            attributes: [.font : NSFont.boldSystemFont(ofSize: fontSize)])
        result.append(partTwo)
        
        let partThree = NSAttributedString(string: " thanks to XcodeCleaner!",
                                           attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
        result.append(partThree)
        
        return result
    }

    private func productKindForTag(_ tag: Int) -> Donations.Product.Kind? {
        switch tag {
            case 1: return .smallCoffee
            case 2: return .bigCoffee
            case 3: return .lunch
            default: return nil
        }
    }
    
    private func productForProductKind(_ productKind: Donations.Product.Kind) -> Donations.Product? {
        return self.donationProducts.filter { $0.kind == productKind }.first
    }

    // MARK: Actions
    @IBAction func buyProduct(_ sender: NSButton) {
        guard let productKind = self.productKindForTag(sender.tag) else {
            log.warning("SupportViewController: Product kind for given sender tag not found: \(sender.tag)")
            return
        }
        
        guard let product = self.productForProductKind(productKind) else {
            log.warning("SupportViewController: Product of given kind not found: \(productKind)")
            return
        }
        
        // TODO: Call real 'buy' method: 'Donations.shared.buy(product: product)'
        log.info("SupportViewController: Will buy product: \(product.identifier)")
    }
}

extension DonationViewController: DonationsDelegate {
    public func donations(_ donations: Donations, didReceive products: [Donations.Product]) {
        DispatchQueue.main.async {
            self.loadingView.removeFromSuperview()
        
            self.donationProducts = products
            
            // update UI
            for product in self.donationProducts {
                switch product.kind {
                    case .smallCoffee:
                        self.smallCoffeePriceLabel.stringValue = product.price
                        self.smallCoffeeInfoLabel.stringValue = product.info
                    case .bigCoffee:
                        self.bigCoffeePriceLabel.stringValue = product.price
                        self.bigCoffeeInfoLabel.stringValue = product.info
                    case .lunch:
                        self.lunchPriceLabel.stringValue = product.price
                        self.lunchInfoLabel.stringValue = product.info

                }
            }
        }
    }
    
    public func transactionDidStart(for product: Donations.Product) {
        
    }
    
    public func transactionIsBeingProcessed(for product: Donations.Product) {
        
    }
    
    public func transactionDidFinish(for product: Donations.Product, error: Error?) {
        
    }
}

