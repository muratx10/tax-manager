import SwiftUI

struct ModuleSidebar: View {
    @ObservedObject var moduleManager: ModuleManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MODULES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

            ForEach(AppModule.allCases) { module in
                ModuleItem(
                    module: module,
                    isSelected: moduleManager.selectedModule == module,
                    action: {
                        moduleManager.selectModule(module)
                    }
                )
            }

            Spacer()
        }
        .frame(width: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct ModuleItem: View {
    let module: AppModule
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: module.icon)
                    .font(.system(size: 16))
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(module.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(module.description)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}
