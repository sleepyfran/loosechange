import Foundation
import Combine

struct TransactionsService {
    var lunchMoneyApi: LunchMoneyApi
    
    init(token: String) {
        lunchMoneyApi = LunchMoneyApi(config: ApiConfig(accessToken: token))
    }
    
    func fetchMonthTransactions(
        for accounts: [Account]
    ) -> AnyPublisher<[Transaction], ApiError> {
        let categoriesPublisher = lunchMoneyApi
            .getCategories()
            .flatMap { $0.categories.publisher }
            .map { Category(id: $0.id, name: $0.name) }
            .collect()
                
        return lunchMoneyApi
            .getTransactions()
            .map {
                $0.transactions
                    .filter { transaction in
                        accounts.contains(where: { account in
                            transactionIsFromAcccount(account, transaction)
                        })
                    }
                    .publisher
            }
            .zip(categoriesPublisher)
            .flatMap { transactions, categories in
                transactions
                    .map { transaction -> Transaction in
                        let account = accounts.first(where: {
                            transactionIsFromAcccount($0, transaction)
                        })!
                        
                        let category = categories.first(where: {
                            $0.id == transaction.categoryId
                        })!
                        
                        return Transaction(
                            id: transaction.id,
                            date: date(from: transaction.date),
                            payee: transaction.payee,
                            formattedAmount: formatCurrency(
                                // Amounts come in negative when positive, so flip.
                                balance: flipAmount(transaction.amount),
                                currency: transaction.currency
                            ),
                            notes: transaction.notes ?? "",
                            account: account,
                            category: category
                        )
                    }
            }
            .collect()
            .map { $0.sorted(by: { t1, t2 in t1.date > t2.date }) }
            .eraseToAnyPublisher()
    }
}

func flipAmount(_ amount: String) -> String {
    if amount.hasPrefix("-") {
        return amount.replacingOccurrences(of: "-", with: "")
    } else {
        return "-\(amount)"
    }
}

func transactionIsFromAcccount(
    _ account: Account,
    _ transaction: Api.Transaction
) -> Bool {
    return
        account.id == transaction.assetId ||
        account.id == transaction.plaidAccountId
}
