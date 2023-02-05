//
//  LoadingView.swift
//  ExchangeRates
//
//  Created by Suresh on 26/01/23.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    let text: String?
    
    var body: some View {
        VStack {
            HStack {
                if let text = text {
                    ProgressView(text)
                        
                } else {
                    ProgressView()
                }
            }
        }
        .frame(width: 300, height: 150, alignment:
                Alignment(horizontal: HorizontalAlignment.center, vertical: VerticalAlignment.center))
    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(text: nil)
    }
}
