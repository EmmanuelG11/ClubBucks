import SwiftUI

struct MemberTabView: View {

    let memberID: UUID
    let onLogout: () -> Void

    var body: some View {

        TabView {

            NavigationStack {
                MemberDashboardView(
                    memberID: memberID
                )
            }
            .tabItem {
                Label(
                    "Home",
                    systemImage: "house.fill"
                )
            }

            NavigationStack {
                TransactionHistoryView(
                    memberID: memberID
                )
            }
            .tabItem {
                Label(
                    "History",
                    systemImage: "clock.fill"
                )
            }

            NavigationStack {
                SavingsGoalView(
                    memberID: memberID
                )
            }
            .tabItem {
                Label(
                    "Goal",
                    systemImage: "target"
                )
            }

            NavigationStack {
                MemberProfileView(
                    memberID: memberID,
                    onLogout: onLogout
                )
            }
            .tabItem {
                Label(
                    "Profile",
                    systemImage: "person.fill"
                )
            }
        }
    }
}

// Member Dashboard

struct MemberDashboardView: View {

    @EnvironmentObject var store: ClubBucksStore

    let memberID: UUID

    var body: some View {

        ScrollView {

            if let member =
                store.member(with: memberID) {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    HStack {

                        Image(
                            systemName: member.avatar
                        )
                        .font(.system(size: 45))
                        .foregroundStyle(.blue)

                        VStack(
                            alignment: .leading
                        ) {

                            Text("Welcome back,")

                            Text(member.displayName)
                                .font(.title2)
                                .bold()
                        }

                        Spacer()
                    }

                    balanceCard(member)

                    if let goal =
                        member.savingsGoal {

                        goalCard(goal)
                    }

                    Text("Recent Activity")
                        .font(.title2)
                        .bold()

                    if member.transactions.isEmpty {

                        Text(
                            "No transactions yet."
                        )
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        ForEach(
                            Array(
                                member.transactions.prefix(3)
                            )
                        ) { transaction in

                            TransactionRow(
                                transaction:
                                    transaction
                            )

                            Divider()
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Club Bucks")
    }

    private func balanceCard(
        _ member: Member
    ) -> some View {

        VStack(spacing: 12) {

            Text("Your Balance")
                .font(.headline)

            Text("\(member.balance)")
                .font(.system(
                    size: 55,
                    weight: .bold
                ))

            Text("Club Bucks")
                .font(.title3)

        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            RoundedRectangle(
                cornerRadius: 22
            )
            .fill(.blue.gradient)
        )
    }

    private func goalCard(
        _ goal: SavingsGoal
    ) -> some View {

        let progress =
            Double(goal.currentAmount) /
            Double(goal.targetAmount)

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack {

                Image(
                    systemName: "target"
                )

                Text("Savings Goal")
                    .font(.headline)

                Spacer()
            }

            Text(goal.title)
                .font(.title3)
                .bold()

            ProgressView(
                value: min(progress, 1)
            )

            HStack {

                Text(
                    "\(goal.currentAmount) saved"
                )

                Spacer()

                Text(
                    "Goal: \(goal.targetAmount)"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Color.secondary.opacity(0.12)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
}

// Transaction Row

struct TransactionRow: View {

    let transaction: ClubTransaction

    var body: some View {

        HStack(spacing: 15) {

            Image(
                systemName:
                    transaction.type == .award
                    ? "arrow.down.circle.fill"
                    : "cart.circle.fill"
            )
            .font(.title)
            .foregroundStyle(
                transaction.type == .award
                ? .green
                : .orange
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(transaction.reason)
                    .font(.headline)

                Text(
                    transaction.date.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(
                transaction.type == .award
                ? "+\(transaction.amount)"
                : "-\(transaction.amount)"
            )
            .font(.headline)
            .foregroundStyle(
                transaction.type == .award
                ? .green
                : .red
            )
        }
        .padding(.vertical, 5)
    }
}

// Transaction History

struct TransactionHistoryView: View {

    @EnvironmentObject var store: ClubBucksStore

    let memberID: UUID

    var body: some View {

        Group {

            if let member =
                store.member(with: memberID) {

                if member.transactions.isEmpty {

                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "clock"
                    )

                } else {

                    List(
                        member.transactions
                    ) { transaction in

                        TransactionRow(
                            transaction:
                                transaction
                        )
                    }
                }
            }
        }
        .navigationTitle(
            "Transaction History"
        )
    }
}

// Savings Goal

struct SavingsGoalView: View {

    @EnvironmentObject var store: ClubBucksStore

    let memberID: UUID

    var body: some View {

        ScrollView {

            if let member =
                store.member(with: memberID) {

                VStack(spacing: 30) {

                    Image(systemName: "target")
                        .font(
                            .system(size: 80)
                        )
                        .foregroundStyle(.blue)

                    if let goal =
                        member.savingsGoal {

                        Text(goal.title)
                            .font(.largeTitle)
                            .bold()

                        let progress =
                            Double(
                                goal.currentAmount
                            )
                            /
                            Double(
                                goal.targetAmount
                            )

                        ProgressView(
                            value: min(
                                progress,
                                1
                            )
                        )
                        .scaleEffect(
                            x: 1,
                            y: 3
                        )
                        .padding()

                        Text(
                            "\(goal.currentAmount) / \(goal.targetAmount) Club Bucks"
                        )
                        .font(.title2)

                        Text(
                            "\(goal.targetAmount - goal.currentAmount) Bucks remaining"
                        )
                        .foregroundStyle(
                            .secondary
                        )

                    } else {

                        Text(
                            "You don't have a savings goal yet."
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Goal")
    }
}

// Member Profile

struct MemberProfileView: View {

    @EnvironmentObject var store: ClubBucksStore

    let memberID: UUID
    let onLogout: () -> Void

    var body: some View {

        if let member =
            store.member(with: memberID) {

            VStack(spacing: 25) {

                Image(
                    systemName: member.avatar
                )
                .font(.system(size: 100))
                .foregroundStyle(.blue)

                Text(member.displayName)
                    .font(.largeTitle)
                    .bold()

                Text(member.clubLocation)
                    .foregroundStyle(
                        .secondary
                    )

                HStack {

                    Text("Club Bucks")

                    Spacer()

                    Text(
                        "\(member.balance)"
                    )
                    .bold()
                }
                .padding()
                .background(
                    Color.secondary.opacity(
                        0.12
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 15
                    )
                )

                Spacer()

                Button(
                    "Sign Out",
                    role: .destructive
                ) {
                    onLogout()
                }
                .buttonStyle(.bordered)

            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}
