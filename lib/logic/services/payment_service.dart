enum PaymentPurpose { directMachinePayment, walletLoad }

abstract class PaymentService {
  Future<void> makePayment(
    double amount, {
    PaymentPurpose purpose = PaymentPurpose.directMachinePayment,
  });
}
