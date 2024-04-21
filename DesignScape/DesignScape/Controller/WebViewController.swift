//
//  WebViewController.swift
//  DesignScape
//
//  Created by Y Nguyen on 4/20/24.
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {

    }
}
