import Foundation
import Combine

@MainActor
final class ClubBucksStore: ObservableObject {

    @Published var members: [Member] = [

        Member(
            displayName: "Jordan",
            avatar: "person.crop.circle.fill",
            clubLocation: "Main Club",
            balance: 125,
            transactions: [
                ClubTransaction(
                    amount: 20,
                    type: .award,
                    reason: "Helped clean the activity room",
                    date: Date().addingTimeInterval(-3600),
                    staffActor: "Ms. Taylor"
                ),

                ClubTransaction(
                    amount: 15,
                    type: .spend,
                    reason: "Club Store Snack",
                    date: Date().addingTimeInterval(-86400),
                    staffActor: "Mr. Jackson"
                ),

                ClubTransaction(
                    amount: 30,
                    type: .award,
                    reason: "Completed homework",
                    date: Date().addingTimeInterval(-172800),
                    staffActor: "Ms. Taylor"
                )
            ],
            savingsGoal: SavingsGoal(
                title: "Basketball",
                targetAmount: 200,
                currentAmount: 125
            )
        ),

        Member(
            displayName: "Alex",
            avatar: "person.crop.circle.fill",
            clubLocation: "Main Club",
            balance: 85,
            transactions: [
                ClubTransaction(
                    amount: 25,
                    type: .award,
                    reason: "Positive behavior",
                    staffActor: "Mr. Jackson"
                )
            ],
            savingsGoal: SavingsGoal(
                title: "Headphones",
                targetAmount: 150,
                currentAmount: 85
            )
        ),

        Member(
            displayName: "Maya",
            avatar: "person.crop.circle.fill",
            clubLocation: "Main Club",
            balance: 210,
            transactions: [
                ClubTransaction(
                    amount: 40,
                    type: .award,
                    reason: "Volunteer activity",
                    staffActor: "Ms. Taylor"
                )
            ],
            savingsGoal: SavingsGoal(
                title: "Art Set",
                targetAmount: 250,
                currentAmount: 210
            )
        )
    ]

    func member(with id: UUID) -> Member? {
        members.first { $0.id == id }
    }

    @discardableResult
    func recordTransaction(
        memberID: UUID,
        type: TransactionType,
        amount: Int,
        reason: String,
        staffActor: String
    ) -> Bool {

        guard amount > 0 else {
            return false
        }

        guard let index = members.firstIndex(where: {
            $0.id == memberID
        }) else {
            return false
        }

        let change = type == .award ? amount : -amount

        let newBalance =
            members[index].balance + change

        // Prevent negative balances
        guard newBalance >= 0 else {
            return false
        }

        members[index].balance = newBalance

        let transaction = ClubTransaction(
            amount: amount,
            type: type,
            reason: reason,
            staffActor: staffActor
        )

        members[index].transactions.insert(
            transaction,
            at: 0
        )

        return true
    }
}
