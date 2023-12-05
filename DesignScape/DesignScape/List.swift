//
//  List.swift
//  DesignScape
//
//  Created by Y Nguyen on 12/5/23.
//

import Foundation
import SwiftUI

struct DataTableView: View {
    @ObservedObject var viewModel = ItemViewModel()

    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
            // Add other views to display additional properties
        }
        .onAppear {
            viewModel.fetchDataFromFirebase()
//            viewModel.addSampleItem()
        }
    }
}
