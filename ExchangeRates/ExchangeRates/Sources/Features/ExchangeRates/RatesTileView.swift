//
//  RatesTileView.swift
//  ExchangeRates
//
//  Created by Suresh on 27/01/23.
//

import Foundation
import SwiftUI

struct RatesTileView: View {
    
    let enteredAmount, exchangeRate: Double?
    let currency: String
   
    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 4, content: {
                let currentRate = (enteredAmount ?? 0.0) * (exchangeRate ?? 0.0)
                Text("\(currentRate, specifier: "%.2f")")
                    .font(.footnote)
                Text(currency)
                    .font(.callout)
            })
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
            .backgroundStyle(.gray)
            
        }
        .backgroundStyle(.gray)
        
       
        
    }
}

