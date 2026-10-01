import SwiftUI

struct StaffHomeView: View {

    @EnvironmentObject var store: ClubBucksStore

    @State private var searchText = ""

    let onLogout: () -> Void

    var filteredMembers: [Member] {

        if searchText.isEmpty {
            return store.members
        }

        return store.members.filter {

            $0.displayName.localizedCaseInsensitiveContains(
                searchText
            )
        }
    }

    var body: some View {

        NavigationStack {

            List(filteredMembers) { member in

                NavigationLink {

                    StaffMemberDetailView(
                        memberID: member.id
                    )

                } label: {

                    HStack {

                        Image(
                            systemName:
                                member.avatar
                        )
                        .font(.title)
                        .foregroundStyle(
                            .blue
                        )

                        VStack(
                            alignment: .leading
                        ) {

                            Text(
                                member.displayName
                            )
                            .font(.headline)

                            Text(
                                member.clubLocation
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        Spacer()

                        Text(
                            "\(member.balance)"
                        )
                        .bold()

                        Text("Bucks")
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                    }
                    .padding(
                        .vertical,
                        5
                    )
                }
            }
            .navigationTitle(
                "Members"
            )
            .searchable(
                text: $searchText,
                prompt: "Search members"
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {

                    Button(
                        "Sign Out"
                    ) {
                        onLogout()
                    }
                }
            }
        }
    }
}

// Staff Memeber Details

struct StaffMemberDetailView: View {

    @EnvironmentObject var store: ClubBucksStore

    let memberID: UUID

    @State private var transactionType:
        TransactionType?

    var body: some View {

        ScrollView {

            if let member =
                store.member(with: memberID) {

                VStack(
                    alignment: .leading,
                    spacing: 25
                ) {

                    HStack {

                        Image(
                            systemName:
                                member.avatar
                        )
                        .font(
                            .system(size: 55)
                        )
                        .foregroundStyle(.blue)

                        VStack(
                            alignment: .leading
                        ) {

                            Text(
                                member.displayName
                            )
                            .font(.title)
                            .bold()

                            Text(
                                member.clubLocation
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }

                    VStack(spacing: 8) {

                        Text("Balance")
                            .foregroundStyle(
                                .secondary
                            )

                        Text(
                            "\(member.balance)"
                        )
                        .font(
                            .system(
                                size: 50,
                                weight: .bold
                            )
                        )

                        Text("Club Bucks")

                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding()
                    .background(
                        Color.blue.opacity(
                            0.12
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )

                    HStack {

                        Button {

                            transactionType =
                                .award

                        } label: {

                            Label(
                                "Award",
                                systemImage:
                                    "plus.circle.fill"
                            )
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                        }
                        .buttonStyle(
                            .borderedProminent
                        )

                        Button {

                            transactionType =
                                .spend

                        } label: {

                            Label(
                                "Deduct",
                                systemImage:
                                    "minus.circle.fill"
                            )
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                        }
                        .buttonStyle(
                            .bordered
                        )
                    }

                    Text("Transaction History")
                        .font(.title2)
                        .bold()

                    ForEach(
                        member.transactions
                    ) { transaction in

                        TransactionRow(
                            transaction:
                                transaction
                        )

                        Divider()
                    }
                }
                .padding()
            }
        }
        .navigationTitle(
            "Member"
        )
        .sheet(
            item: $transactionType
        ) { type in

            StaffTransactionSheet(
                memberID: memberID,
                type: type
            )
        }
    }
}

// Staff Transaction Form

struct StaffTransactionSheet: View {

    @EnvironmentObject var store:
        ClubBucksStore

    @Environment(\.dismiss)
    private var dismiss

    let memberID: UUID
    let type: TransactionType

    @State private var amountText = ""
    @State private var reason = ""

    @State private var errorMessage:
        String?

    var body: some View {

        NavigationStack {

            Form {

                if let member =
                    store.member(
                        with: memberID
                    ) {

                    Section("Member") {

                        HStack {

                            Text(
                                member.displayName
                            )

                            Spacer()

                            Text(
                                "\(member.balance) Bucks"
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                    }
                }

                Section(
                    type == .award
                    ? "Award Club Bucks"
                    : "Deduct Club Bucks"
                ) {

                    TextField(
                        "Amount",
                        text: $amountText
                    )
                    .keyboardType(
                        .numberPad
                    )

                    TextField(
                        "Reason",
                        text: $reason,
                        axis: .vertical
                    )
                    .lineLimit(3)
                }

                if let errorMessage {

                    Section {

                        Text(errorMessage)
                            .foregroundStyle(
                                .red
                            )
                    }
                }

                Section {

                    Button {

                        submitTransaction()

                    } label: {

                        Text(
                            type == .award
                            ? "Confirm Award"
                            : "Confirm Deduction"
                        )
                        .frame(
                            maxWidth:
                                .infinity
                        )
                    }
                }
            }
            .navigationTitle(
                type.rawValue
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitTransaction() {

        guard let amount =
                Int(amountText),
              amount > 0 else {

            errorMessage =
                "Enter a valid amount."

            return
        }

        guard !reason
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty else {

            errorMessage =
                "Enter a transaction reason."

            return
        }

        let success =
            store.recordTransaction(
                memberID: memberID,
                type: type,
                amount: amount,
                reason: reason,
                staffActor: "Staff Demo"
            )

        if success {

            dismiss()

        } else {

            errorMessage =
                "Transaction could not be completed. Check the member's balance."
        }
    }
}
