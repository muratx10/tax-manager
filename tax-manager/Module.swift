import SwiftUI

enum AppModule: String, CaseIterable, Identifiable {
    case finance = "Finance"
    case debts = "Debts & Loans"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .finance:
            return "chart.bar.fill"
        case .debts:
            return "creditcard.fill"
        }
    }

    var description: String {
        switch self {
        case .finance:
            return "Income, taxes & exchange rates"
        case .debts:
            return "Track debts and loans"
        }
    }
}

class ModuleManager: ObservableObject {
    @Published var selectedModule: AppModule

    init() {
        if let savedModule = UserDefaults.standard.string(forKey: "selectedModule"),
           let module = AppModule(rawValue: savedModule) {
            self.selectedModule = module
        } else {
            self.selectedModule = .finance
        }
    }

    func selectModule(_ module: AppModule) {
        selectedModule = module
        UserDefaults.standard.set(module.rawValue, forKey: "selectedModule")
    }
}
