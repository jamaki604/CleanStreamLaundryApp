import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/loyalty_card.dart';

void main() {
  group("LoyaltyCard Payment Tests", () {
    setUp(() {
      LoyaltyCard.reset();
    });

    test("Initial balance is zero", () {
      expect(LoyaltyCard.balance, 0.0);
    });

    test("Add money increases balance", () {
      LoyaltyCard.addMoney(10.0);
      expect(LoyaltyCard.balance, 10.0);
    });

    test("Subtract money decreases balance", () {
      LoyaltyCard.addMoney(10.0);
      LoyaltyCard.subtractMoney(4.0);
      expect(LoyaltyCard.balance, 6.0);
    });

    test("Subtracting more than balance does not go negative", () {
      LoyaltyCard.addMoney(5.0);
      LoyaltyCard.subtractMoney(10.0);
      expect(LoyaltyCard.balance, 5.0); // unchanged
    });

    test("Multiple transactions update balance correctly", () {
      LoyaltyCard.addMoney(20.0);
      LoyaltyCard.subtractMoney(5.0);
      LoyaltyCard.addMoney(15.0);
      LoyaltyCard.subtractMoney(10.0);
      expect(LoyaltyCard.balance, 20.0);
    });
  });
}