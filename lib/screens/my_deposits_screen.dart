import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDepositsScreen extends StatelessWidget {
  const MyDepositsScreen({super.key});

  Future<void> _deleteDeposit(BuildContext context, DocumentSnapshot doc) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Deposit?'),
        content: const Text(
            'Are you sure you want to delete this deposit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final db = FirebaseFirestore.instance;
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['amount'] as num).toDouble();
              final userName = data['userName'] as String?
                  ?? FirebaseAuth.instance.currentUser?.email?.split('@')[0]
                  ?? 'User';
              final userRef = db.collection('users').doc(uid);

              await db.runTransaction((tx) async {
                final userDoc = await tx.get(userRef);
                final current =
                    (userDoc.data()?['totalContributed'] as num? ?? 0)
                        .toDouble();
                tx.update(userRef, {'totalContributed': current - amount});
                tx.delete(doc.reference);
              });

              // Send notification about deposit deletion
              await db.collection('notifications').add({
                'message': '$userName deleted a deposit of ৳ ${amount.toStringAsFixed(0)}',
                'userName': userName,
                'amount': amount,
                'type': 'deletion',
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deposit deleted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editDeposit(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final amountCtrl = TextEditingController(
      text: (data['amount'] as num).toString(),
    );
    DateTime selectedDate = (data['date'] as Timestamp).toDate();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Deposit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (৳)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F7FA),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF5F7FA),
                  ),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final newAmount = double.tryParse(amountCtrl.text.trim());
                  if (newAmount == null || newAmount <= 0) return;

                  final db = FirebaseFirestore.instance;
                  final oldAmount = (data['amount'] as num).toDouble();
                  final diff = newAmount - oldAmount;
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final userRef = db.collection('users').doc(uid);

                  await db.runTransaction((tx) async {
                    final userDoc = await tx.get(userRef);
                    final current =
                        (userDoc.data()?['totalContributed'] as num? ?? 0)
                            .toDouble();
                    tx.update(userRef, {'totalContributed': current + diff});
                    tx.update(doc.reference, {
                      'amount': newAmount,
                      'date': Timestamp.fromDate(selectedDate),
                      'editedAt': FieldValue.serverTimestamp(),
                    });
                  });

                  // Send notification about deposit change
                  await db.collection('notifications').add({
                    'message':
                        '${data['userName']} updated a deposit to ৳ ${newAmount.toStringAsFixed(0)}',
                    'userName': data['userName'],
                    'amount': newAmount,
                    'type': 'edit',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
        title: const Text('My Deposits'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No deposits yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap "Add Deposit" to get started.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sort by date descending in Dart
          final sortedDocs = [...docs]
            ..sort((a, b) {
              final aDate =
                  (a.data() as Map<String, dynamic>)['date'] as Timestamp;
              final bDate =
                  (b.data() as Map<String, dynamic>)['date'] as Timestamp;
              return bDate.compareTo(aDate);
            });

          // Summary calculations use original docs
          final total = docs.fold<double>(
            0,
            (sum, d) =>
                sum +
                ((d.data() as Map<String, dynamic>)['amount'] as num)
                    .toDouble(),
          );

          final thisMonth = DateTime.now();
          final monthTotal = docs
              .where((d) {
                final date =
                    ((d.data() as Map<String, dynamic>)['date'] as Timestamp)
                        .toDate();
                return date.month == thisMonth.month &&
                    date.year == thisMonth.year;
              })
              .fold<double>(
                0,
                (sum, d) =>
                    sum +
                    ((d.data() as Map<String, dynamic>)['amount'] as num)
                        .toDouble(),
              );

          final largest = docs
              .map(
                (d) => ((d.data() as Map<String, dynamic>)['amount'] as num)
                    .toDouble(),
              )
              .reduce((a, b) => a > b ? a : b);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF185FA5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Total Contribution',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '৳ ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${docs.length} deposit${docs.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SummaryCard(
                            label: 'This month',
                            value: '৳ ${monthTotal.toStringAsFixed(0)}',
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFF3B6D11),
                            bgColor: const Color(0xFFEAF3DE),
                          ),
                          const SizedBox(width: 10),
                          _SummaryCard(
                            label: 'Largest',
                            value: '৳ ${largest.toStringAsFixed(0)}',
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFF534AB7),
                            bgColor: const Color(0xFFEEEDFE),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Deposit History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final data = sortedDocs[i].data() as Map<String, dynamic>;
                    final amount = (data['amount'] as num).toDouble();
                    final date = (data['date'] as Timestamp).toDate();
                    final note = data['note'] as String? ?? '';
                    final isEdited = data['editedAt'] != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F1FB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFF185FA5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '৳ ${amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF185FA5),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${date.day}/${date.month}/${date.year}'
                                  '${note.isNotEmpty ? ' · $note' : ''}'
                                  '${isEdited ? ' · edited' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () =>
                                _editDeposit(context, sortedDocs[i]),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () =>
                                _deleteDeposit(context, sortedDocs[i]),
                          ),
                        ],
                      ),
                    );
                  }, childCount: sortedDocs.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
