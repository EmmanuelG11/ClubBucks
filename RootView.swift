import SwiftUI

enum AppMode: Equatable {
    case member(UUID)
    case staff
}

struct RootView: View {

    @EnvironmentObject var store: ClubBucksStore

    @State private var mode: AppMode?

    var body: some View {

        switch mode {

        case .member(let memberID):

            MemberTabView(
                memberID: memberID,
                onLogout: {
                    mode = nil
                }
            )

        case .staff:

            StaffHomeView {
                mode = nil
            }

        case nil:

            LoginSelectionView(
                memberLogin: {

                    if let firstMember =
                        store.members.first {

                        mode = .member(firstMember.id)
                    }
                },

                staffLogin: {
                    mode = .staff
                }
            )
        }
    }
}

struct LoginSelectionView: View {

    let memberLogin: () -> Void
    let staffLogin: () -> Void

    @State private var showingStaffPIN = false

    var body: some View {

        NavigationStack {

            VStack(spacing: 30) {

                Spacer()

                Image("ClubBucksLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 26,
                            style: .continuous
                        )
                    )

                VStack(spacing: 8) {

                    Text("ClubBucks")
                        .font(.largeTitle)
                        .bold()

                    Text("Earn. Save. Spend Smart.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    memberLogin()
                } label: {

                    Label(
                        "Member Login",
                        systemImage: "person.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    showingStaffPIN = true
                } label: {

                    Label(
                        "Staff Login",
                        systemImage: "person.badge.key.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Spacer()
                    .frame(height: 30)
            }
            .padding()
            .sheet(isPresented: $showingStaffPIN) {
                StaffPINView {
                    staffLogin()
                }
            }
        }
    }
}

struct StaffPINView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var pin = ""
    @State private var errorMessage: String?

    let onAuthenticated: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Staff PIN", text: $pin)
                        .keyboardType(.numberPad)
                        .textContentType(.password)
                } header: {
                    Text("Authorization Required")
                } footer: {
                    Text("Enter the staff PIN to access staff tools.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Continue") {
                        authenticate()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(pin.isEmpty)
                }
            }
            .navigationTitle("Staff Login")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func authenticate() {
        guard pin == "1903" else {
            pin = ""
            errorMessage = "Incorrect PIN. Please try again."
            return
        }

        dismiss()
        onAuthenticated()
    }
}
