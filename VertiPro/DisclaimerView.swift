import SwiftUI

struct DisclaimerView: View {
    @Binding var hasAcceptedDisclaimer: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Disclaimer")
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("This app is not intended to replace any doctor consultation. It is strongly advised that you consult with your doctor before performing any exercise")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                UserDefaults.standard.set(true, forKey: "hasAcceptedDisclaimer")
                hasAcceptedDisclaimer = true
            } label: {
                Text("Accept")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : .white)
    }
}

#Preview {
    DisclaimerView(hasAcceptedDisclaimer: .constant(false))
} 