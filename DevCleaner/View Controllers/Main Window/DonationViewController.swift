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
    
    @IBOutlet weak var donationsInterfaceView: NSView!
    
    private var loadingView: LoadingView! = nil

    private var donationProducts: [Donations.Product] = []
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make loading view
        self.loadingView = LoadingView(frame: self.view.frame)
        self.startLoading()
        
        // update benefits label
        self.xcodeCleanerBenefitsTextField.attributedStringValue = self.benefitsAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
        
        // update donation products
        Donations.shared.delegate = self
        Donations.shared.fetchProductsInfo()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
    }
    
    // MARK: Loading
    private func startLoading() {
        if self.loadingView.superview == nil {
            self.donationsInterfaceView.isHidden = true
            self.view.addSubview(self.loadingView)
        }
    }
    
    private func stopLoading() {
        self.donationsInterfaceView.isHidden = false
        self.loadingView.removeFromSuperview()
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
        
        Donations.shared.buy(product: product)
    }
}

extension DonationViewController: DonationsDelegate {
    public func donations(_ donations: Donations, didReceive products: [Donations.Product]) {
        DispatchQueue.main.async {
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
            
            self.stopLoading()
        }
    }
    
    public func transactionDidStart(for product: Donations.Product) {
        DispatchQueue.main.async {
            self.startLoading()
        }
    }
    
    public func transactionIsBeingProcessed(for product: Donations.Product) {
        DispatchQueue.main.async {
            self.startLoading()
        }
    }
    
    public func transactionDidFinish(for product: Donations.Product, error: Error?) {
        DispatchQueue.main.async {
            self.stopLoading()
            
            // hide donations interface
            self.donationsInterfaceView.isHidden = true
            
            // add a message view
            let messageView = MessageView(frame: self.view.frame)
            messageView.backgroundColor = .clear
            self.view.addSubview(messageView)
            
            // check for error or dismiss our donation sheet
            if error == nil {
                messageView.message = "🎉 Thank you for your donation!"
            } else {
                messageView.message = "😔 Donation failed! Try again later..."
            }
        }
    }
}
