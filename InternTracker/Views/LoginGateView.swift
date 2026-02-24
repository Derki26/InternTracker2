import SwiftUI

struct LoginGateView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var data: LocalDataStore

    @State private var username: String = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image("mdc_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, 10)

                Text("Internship Tracker")
                    .font(.title)
                    .bold()

                Text("Enter your username to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("MDC Staff email", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 8)

                Text("Example: drodri54@mdc.edu")
                    .font(.footnote)
                    .foregroundStyle(.secondary)


                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    error = sessionStore.login(username: username, data: data)
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)

                // Tip: usuarios disponibles en demo
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginGateView()
        .environmentObject(SessionStore())
        .environmentObject(LocalDataStore())
}
