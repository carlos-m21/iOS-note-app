import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //FETCH PRODUCTS
    var request: SKProductsRequest!
    var noteCountMaanger: NoteCountManager?
    @Published var purchaseError: String?
    @Published var myProducts = [SKProduct]()
    @Published var restoreProductsCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var success: Bool = false
    @Published var failed: Bool = false

    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response")
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                print(fetchedProduct)
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
        isLoading = false
        success = false
        failed = true
        purchaseError = error.localizedDescription
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("request did finish")
        isLoading = false
        success = true
        failed = false
        purchaseError = nil
    }
    //HANDLE TRANSACTIONS
    @Published var transactionState: SKPaymentTransactionState?
    
    func purchaseProduct(product: SKProduct, noteManager: NoteCountManager?) {
        self.noteCountMaanger = noteManager
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            isLoading = true
            success = false
            failed = false
            purchaseError = nil
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
            isLoading = false
            success = false
            failed = true
            purchaseError = "User can't make payment."
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                if let noteManager = self.noteCountMaanger {
                    noteManager.setPurchased(true)
                }
                transactionState = .purchased
            case .restored:
                restoreProductsCount += 1
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                if let noteManager = self.noteCountMaanger {
                    noteManager.setPurchased(true)
                }
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
                purchaseError = transaction.error?.localizedDescription
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        restoreProductsCount = 0
        isLoading = true
        success = false
        failed = false
        purchaseError = nil
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        queue.remove(self)
        isLoading = false
        if restoreProductsCount != 0 {
            transactionState = .restored
            if let noteManager = self.noteCountMaanger {
                noteManager.setPurchased(true)
            }
            success = true
            failed = false
            purchaseError = nil
        } else {
            print("No restored products")
            failed = true
            purchaseError = "Restoring purchased products failed"
            success = false
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        transactionState = .failed
        purchaseError = error.localizedDescription
        print(error.localizedDescription)
        isLoading = false
        success = false
        failed = true
        if let noteManager = self.noteCountMaanger {
            noteManager.setPurchased(false)
        }
    }
}
