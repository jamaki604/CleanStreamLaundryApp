class LoyaltyCard {
  static double balance = 0.0;

  static void addMoney(double amount) {
    balance += amount;
  }

  static void subtractMoney(double amount) {
    if (balance >= amount) {
      balance -= amount;
    }
  }
}