//
//  QuickLookPreviewController.swift
//  DesignScape
//
//  Created by Y Nguyen on 4/15/24.
//

import SwiftUI
import QuickLook
import RealityKit
import ARKit
import MobileCoreServices

struct QuickLookPreviewController: UIViewControllerRepresentable {
    var url: URL // URLs of the files you want to preview

    func makeUIViewController(context: Context) -> QLPreviewController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        return previewController
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // No updates are required for the preview controller
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        
        var url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
            print("qlpreviewitem")
//            guard let fileURL = Bundle.main.url(forResource: "bisou-accent-chair", withExtension: "usdz") else {
//                fatalError("Unable to load file.usdz from main bundle")
//            }
//            return fileURL as QLPreviewItem
            
            return PreviewItem(url: url, contentType: "model/vnd.usdz+zip")
        }
    }
    
    class PreviewItem: NSObject, QLPreviewItem {
        let previewItemURL: URL?
        let previewItemTitle: String?
        let contentType: String?

        init(url: URL, contentType: String? = nil) {
            self.previewItemURL = url
            self.previewItemTitle = url.lastPathComponent
            self.contentType = contentType
        }
        
        func mimeType() -> String? {
        return contentType
        }
    }

}



