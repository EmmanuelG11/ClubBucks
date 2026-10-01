import Foundation

enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case award = "Award"
    case spend = "Spend"

    var id: String {
        rawValue
    }
}

struct ClubTransaction: Identifiable, Hashable {

    let id: UUID
    let amount: Int
    let type: TransactionType
    let reason: String
    let date: Date
    let staffActor: String

    init(
        id: UUID = UUID(),
        amount: Int,
        type: TransactionType,
        reason: String,
        date: Date = Date(),
        staffActor: String
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.reason = reason
        self.date = date
        self.staffActor = staffActor
    }

    var signedAmount: Int {
        type == .award ? amount : -amount
    }
}

struct SavingsGoal: Hashable {
    var title: String
    var targetAmount: Int
    var currentAmount: Int
}

struct Member: Identifiable, Hashable {

    let id: UUID
    var displayName: String
    var avatar: String
    var clubLocation: String
    var balance: Int

    var transactions: [ClubTransaction]
    var savingsGoal: SavingsGoal?

    init(
        id: UUID = UUID(),
        displayName: String,
        avatar: String,
        clubLocation: String,
        balance: Int,
        transactions: [ClubTransaction] = [],
        savingsGoal: SavingsGoal? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.avatar = avatar
        self.clubLocation = clubLocation
        self.balance = balance
        self.transactions = transactions
        self.savingsGoal = savingsGoal
    }
}
