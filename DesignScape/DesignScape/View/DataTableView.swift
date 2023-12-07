//
//  List.swift
//  DesignScape
//
//  Created by Y Nguyen on 12/5/23.
//

import Foundation
import SwiftUI

/// List view of data
struct DataTableView: View {
    var items: [Item]

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }
}


