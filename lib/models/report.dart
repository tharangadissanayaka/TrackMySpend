import 'transaction.dart';

class Report {
  int reportId;
  DateTime startDate;
  DateTime endDate;
  double totalIncome;
  double totalExpense;
  double balance;

  // Relationship: Report summarizes many transactions
  List<Transaction> transactions = [];

  Report({
    required this.reportId,
    required this.startDate,
    required this.endDate,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
  });

  void generateReport() {
    totalIncome = transactions
        .where((t) => t.type == "income")
        .fold(0, (sum, t) => sum + t.amount);
    totalExpense = transactions
        .where((t) => t.type == "expense")
        .fold(0, (sum, t) => sum + t.amount);
    balance = totalIncome - totalExpense;
    print("Report $reportId generated.");
  }

  void viewReport() {
    print("Report $reportId from $startDate to $endDate");
    print("Income: $totalIncome, Expense: $totalExpense, Balance: $balance");
  }

  void exportReport() {
    print("Exporting report $reportId...");
  }

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }
}
