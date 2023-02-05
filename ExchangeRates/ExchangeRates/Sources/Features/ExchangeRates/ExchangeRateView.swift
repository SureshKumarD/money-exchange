//
//  ContentView.swift
//  ExchangeRates
//
//  Created by Suresh on 24/01/23.
//

import SwiftUI

struct ExchangeRateView: View {
    
   
    @StateObject var viewModel = ExchangeRatesViewModel()
    var layout = [
        GridItem(.fixed(96), spacing: 8, alignment: .leading),
        GridItem(.fixed(96), spacing: 16, alignment: .center),
        GridItem(.fixed(96), spacing: 8, alignment: .trailing)
    ]
    var body: some View {
        NavigationView {
            List {
                Section {
                    
                    VStack(alignment: .center) {
                        TextField("Amount", value: $viewModel.enteredAmount, format: .currency(code: viewModel.baseCurrency))
                            .id(viewModel.baseCurrency)
                            .keyboardType(.decimalPad)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.0)
                                    .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1.0)))
                        Picker("", selection: $viewModel.baseCurrency) {
                            ForEach(viewModel.currencies, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.black)
                        
                    }
                
                    
                }
                Section {
                    LazyVGrid(columns: layout, alignment: .leading, spacing: 8, pinnedViews: [.sectionHeaders]) {
                        if viewModel.isLoading {
                            LoadingView(text: "fetching...")
                        } else {
                            if let rates = viewModel.exchange?.rates {
                                ForEach(Array(rates.keys.enumerated()), id:\.element) { _, key in
                                    
                                    RatesTileView(enteredAmount: viewModel.enteredAmount, exchangeRate: rates[key] ?? 0.0, currency: key)
                                        .frame(width: 96, height: 104, alignment: .leading)
                                    
                                }
                            }
                        }
                    }
                }
                
                Section {
                    if let error = viewModel.error {
                        HStack(alignment: .top, spacing: 8, content: {
                            if let errorMessage = error.message {
                                
                                Image(systemName: "exclamationmark.triangle")
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                                
                                
                                Text(errorMessage)
                                    .font(.callout)
                                
                            }
                        })
                        
                    }
                    
                }
            }
            .padding()
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Exchange Rates Today", displayMode: .inline)
            .onAppear(perform:
                        fetchExchangeRates)
            
        }
    }
    private func fetchExchangeRates() {
        viewModel.fetchExchangeRates(enteredAmount: 0, baseCurrency: "USD")
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeRateView()
    }
}
