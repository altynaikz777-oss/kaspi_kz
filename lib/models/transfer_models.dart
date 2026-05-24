class TransferDraft {
  const TransferDraft({
    required this.amount,
    required this.recipientUid,
    required this.recipientName,
    required this.phone,
    required this.senderBalance,
    this.message = '',
  });

  final int amount;
  final String recipientUid;
  final String recipientName;
  final String phone;
  final String message;
  final double senderBalance;

  int get commission => 0;
  int get totalDebit => amount + commission;
}
