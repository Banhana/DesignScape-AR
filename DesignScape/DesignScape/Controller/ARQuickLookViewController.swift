//
//  ARQuickLookViewController.swift
//  DesignScape
//
//  Created by Minh Huynh on 4/21/24.
//

import SwiftUI
import QuickLook
import ARKit

/// Struct representing a SwiftUI view that wraps an ARQuickLookViewController
struct ARQuickLookView: UIViewControllerRepresentable {
    let url: URL // URL of the file to preview
    var dismissalCompletion: ((Bool) -> Void) = {_ in } // Completion handler for dismissal

    /// Creates and returns a new ARQuickLookViewController with the specified URL and dismissal completion handler
    func makeUIViewController(context: Context) -> some UIViewController {
        return UINavigationController.init(rootViewController: ARQuickLookViewController(url: url, dismissalCompletion))
    }
    
    /// Updates the view controller (not used in this implementation)
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

/// View controller responsible for displaying Quick Look previews
class ARQuickLookViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    var url: URL // URL of the file to preview
    var dismissalCompletion: ((Bool) -> Void) = {_ in } // Completion handler for dismissal
    var didPresented = false // Flag to track if the preview controller has been presented
    
    /// Initializes the view controller with the specified URL and dismissal completion handler
    init(url: URL, _ dismissalCompletion: @escaping (Bool) -> Void) {
        self.url = url
        self.dismissalCompletion = dismissalCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Required initializer (not implemented)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Called when the view appears on the screen
    override func viewDidAppear(_ animated: Bool) {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        
        // Present QLPreview only once
        if !didPresented {
            present(previewController, animated: true, completion: {
                self.didPresented.toggle()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    /// Returns the number of items to preview (always 1 in this case)
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    /// Returns the preview item at the specified index (the file URL)
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return url as QLPreviewItem
    }
    
    /// Called when the preview controller is dismissed
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        // Call the completion handler with true indicating dismissal
        self.dismissalCompletion(true)
    }
}

