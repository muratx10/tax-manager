//
//  ExchangeRateService.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import Foundation

class ExchangeRateService {
    static let shared = ExchangeRateService()
    private init() {}
    
    private let nbgBaseURL = "https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies"
    private let session = URLSession(configuration: .default)
    
    func fetchRate(for currency: Currency, on date: Date) async throws -> Double {
        if currency == .gel {
            return 1.0
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let urlString = "\(nbgBaseURL)/ka/json/?date=\(dateString)"
        
        guard let url = URL(string: urlString) else {
            throw ExchangeRateError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExchangeRateError.networkError
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ExchangeRateError.networkError
            }
            
            let nbgResponse = try JSONDecoder().decode([NBGDayResponse].self, from: data)
            
            guard let dayResponse = nbgResponse.first,
                  let currencyData = dayResponse.currencies.first(where: { $0.code == currency.rawValue }) else {
                throw ExchangeRateError.currencyNotFound
            }
            
            return currencyData.rate
            
        } catch let error as ExchangeRateError {
            throw error
        } catch {
            throw ExchangeRateError.networkError
        }
    }
    
    func fetchLatestRates() async throws -> [Currency: Double] {
        let urlString = "\(nbgBaseURL)/ka/json"
        
        guard let url = URL(string: urlString) else {
            throw ExchangeRateError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ExchangeRateError.networkError
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ExchangeRateError.networkError
            }
            
            let nbgResponse = try JSONDecoder().decode([NBGDayResponse].self, from: data)
            
            var rates: [Currency: Double] = [.gel: 1.0]
            
            if let dayResponse = nbgResponse.first {
                for currencyData in dayResponse.currencies {
                    if let currency = Currency(rawValue: currencyData.code) {
                        rates[currency] = currencyData.rate
                    }
                }
            }
            
            return rates
            
        } catch let error as ExchangeRateError {
            throw error
        } catch {
            throw ExchangeRateError.networkError
        }
    }
}

enum ExchangeRateError: Error, LocalizedError {
    case invalidURL
    case networkError
    case currencyNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network error occurred"
        case .currencyNotFound:
            return "Currency not found in response"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

struct NBGDayResponse: Codable {
    let date: String
    let currencies: [NBGCurrency]
}

struct NBGCurrency: Codable {
    let code: String
    let rate: Double
    let quantity: Int
    let rateFormated: String
    let diffFormated: String
    let name: String
    let date: String
    let validFromDate: String
    
    private enum CodingKeys: String, CodingKey {
        case code
        case rate
        case quantity
        case rateFormated
        case diffFormated
        case name
        case date
        case validFromDate
    }
}