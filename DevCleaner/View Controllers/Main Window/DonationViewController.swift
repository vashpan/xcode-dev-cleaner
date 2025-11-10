//
//  DonationViewController.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 19.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  DevCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  DevCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with DevCleaner.  If not, see <http://www.gnu.org/licenses/>.

import Cocoa
import StoreKit

internal final class DonationViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet weak var xcodeCleanerBenefitsTextField: NSTextField!
    @IBOutlet weak var closeButton: NSButton!
    
    @IBOutlet weak var smallDonationButton: NSButton!
    @IBOutlet weak var mediumDonationButton: NSButton!
    @IBOutlet weak var bigDonationButton: NSButton!
    
    @IBOutlet weak var donationsInterfaceView: NSView!
    
    private var loadingView: LoadingView! = nil

    private var donationProducts: [DonationProduct] = []
    
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
        
        let partThree = NSAttributedString(string: " thanks to DevCleaner!",
                                           attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
        result.append(partThree)
        
        return result
    }

    private func productKindForTag(_ tag: Int) -> DonationProduct.Kind? {
        switch tag {
            case 1: return .smallCoffee
            case 2: return .bigCoffee
            case 3: return .lunch
            default: return nil
        }
    }
    
    private func productForProductKind(_ productKind: DonationProduct.Kind) -> DonationProduct? {
        return self.donationProducts.filter { $0.kind == productKind }.first
    }

    // MARK: Updating price & titles labels
    private func fittingPriceFontSize(for attributedString: NSAttributedString, initialFont: NSFont, buttonWidth: CGFloat) -> CGFloat {
        let attributedString = NSMutableAttributedString(attributedString: attributedString)
        var fontSize = initialFont.pointSize
        var stringSize = attributedString.size()
        
        while ceil(stringSize.width) >= (buttonWidth - 10) { // including some margins
            if fontSize <= 1.0 { // we can't go any further
                break
            }
    
            let newFontSize = fontSize - 1.5
            if let newFont = NSFont(descriptor: initialFont.fontDescriptor, size: newFontSize) {
                attributedString.addAttribute(.font, value: newFont, range: NSMakeRange(0, attributedString.length))
                
                fontSize = newFontSize
                stringSize = attributedString.size()
            } else {
                continue
            }
        }
        
        return fontSize
    }
    
    private func updateDonationButton(button: NSButton, price: String, info: String, priceFontSize: CGFloat, infoFontSize: CGFloat) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.allowsDefaultTighteningForTruncation = true
        style.lineBreakMode = .byWordWrapping
        
        let title = NSMutableAttributedString()
        
        // price part
        let pricePart = NSAttributedString(string: price + "\n",
                                           attributes: [.font : NSFont.boldSystemFont(ofSize: priceFontSize)])
        title.append(pricePart)
        
        // info part
        let infoPart = NSAttributedString(string: info,
                                          attributes: [.font : NSFont.systemFont(ofSize: infoFontSize)])
        title.append(infoPart)
        
        title.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, title.length))
        
        button.attributedTitle = title
    }
    
    private func updateDonationsButtons(for products: [DonationProduct], error: DonationsProductsFetchError?) {
        var priceFontSize: CGFloat = 25.0
        let infoFontSize: CGFloat = 13.0
        let buttonWidth: CGFloat = 100.0
        
        // calculate what size price font should have
        var priceFontSizes = [CGFloat]()
        for product in products {
            let priceFont = NSFont.boldSystemFont(ofSize: priceFontSize)
            let priceAttributedString = NSAttributedString(string: product.price + "\n",
                                               attributes: [.font : priceFont])
            let fittingPriceFontSize = self.fittingPriceFontSize(for: priceAttributedString, initialFont: priceFont, buttonWidth: buttonWidth)
            priceFontSizes.append(fittingPriceFontSize)
        }
        
        if let minPriceFontSize = priceFontSizes.min() {
            priceFontSize = minPriceFontSize
        }
        
        // update all the buttons
        if error == nil && products.count == DonationProduct.Kind.allKinds.count {
            for product in products {
                switch product.kind {
                    case .smallCoffee:
                        self.updateDonationButton(button: self.smallDonationButton,
                                                  price: product.price,
                                                  info: product.info,
                                                  priceFontSize: priceFontSize,
                                                  infoFontSize: infoFontSize)
                    case .bigCoffee:
                        self.updateDonationButton(button: self.mediumDonationButton,
                                                  price: product.price,
                                                  info: product.info,
                                                  priceFontSize: priceFontSize,
                                                  infoFontSize: infoFontSize)
                    case .lunch:
                        self.updateDonationButton(button: self.bigDonationButton,
                                                  price: product.price,
                                                  info: product.info,
                                                  priceFontSize: priceFontSize,
                                                  infoFontSize: infoFontSize)
                        
                }
            }
        } else { // it seems we have an error while loading donation products!
            let title: String = "Error while loading tips"
            let message: String
            
            if let error {
                switch error {
                    case .noProductsAvailable: message = "No tips available!"
                    case .invalidProducts(let products): message = "Invalid tip products: \(products)"
                        
                    case .storeError(let error): message = "AppStore error: \(error.localizedDescription)"
                }
            } else {
                message = "Unrecognized error!"
            }
            
            Alerts.warningAlert(title: title, message: message)
            
            self.dismiss(self)
        }
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
    public func donations(_ donations: Donations, donationProductsFetchFailedWithError error: DonationsProductsFetchError) {
        DispatchQueue.main.async {
            self.donationProducts = []
            
            // update UI
            self.updateDonationsButtons(for: [], error: error)
            
            self.stopLoading()
        }
    }
    
    public func donations(_ donations: Donations, didReceive products: [DonationProduct]) {
        DispatchQueue.main.async {
            self.donationProducts = products
            
            // update UI
            self.updateDonationsButtons(for: products, error: nil)
            
            self.stopLoading()
        }
    }
    
    public func transactionDidStart(for product: DonationProduct) {
        DispatchQueue.main.async {
            self.startLoading()
        }
    }
    
    public func transactionIsBeingProcessed(for product: DonationProduct) {
        DispatchQueue.main.async {
            self.startLoading()
        }
    }
    
    public func transactionDidFinish(for product: DonationProduct, error: Error?) {
        DispatchQueue.main.async {
            self.stopLoading()
            
            // hide donations interface
            self.donationsInterfaceView.isHidden = true
            
            // add a message view
            let messageView = MessageView(frame: self.view.frame)
            messageView.backgroundColor = .clear
            self.view.addSubview(messageView, positioned: .below, relativeTo: self.closeButton)
            
            // check for error or dismiss our donation sheet
            if error == nil {
                messageView.message = "🎉 Thank you for your donation!"
            } else {
                messageView.message = "😔 Donation failed! Try again later..."
            }
        }
    }
}
