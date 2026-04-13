import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bari_project/screens/login_screen.dart';
import 'package:bari_project/screens/my_deposits_screen.dart';
import 'package:bari_project/screens/add_deposit_screen.dart';
import 'package:bari_project/screens/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(onNavigate: _goToTab),
      const MyDepositsScreen(),
      AddDepositScreen(onDepositSuccess: () => _goToTab(1)),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
        selectedItemColor: const Color(0xFF185FA5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'My Deposits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: 'Add Deposit',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final void Function(int) onNavigate;
  const _HomeTab({required this.onNavigate});

  Future<void> _setGoal(BuildContext context, double currentGoal) async {
    final controller = TextEditingController(
      text: currentGoal > 0 ? currentGoal.toString() : '',
    );
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Project Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target amount (৳)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                await FirebaseFirestore.instance
                    .collection('settings')
                    .doc('goal')
                    .set({'amount': val});
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FC),
        foregroundColor: const Color(0xFF185FA5),
        elevation: 1,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          'Project Home Sweet Home',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF185FA5),
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .snapshots(),
            builder: (context, snap) {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final unread = (snap.data?.docs ?? []).where((doc) {
                final seen = List<String>.from(
                  (doc.data() as Map<String, dynamic>)['seenBy'] ?? [],
                );
                return !seen.contains(uid);
              }).length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (context, animation, secondaryAnimation) => const NotificationsScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('settings')
                .doc('goal')
                .snapshots(),
            builder: (context, snap) {
              final goal =
                  (snap.data?.data() as Map<String, dynamic>?)?['amount']
                      as double? ??
                  0.0;
              return IconButton(
                icon: const Icon(Icons.flag_rounded),
                tooltip: 'Set goal',
                onPressed: () => _setGoal(context, goal),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              // Clear saved email when logging out
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('saved_email');
              await prefs.setBool('remember_me', false);

              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      );
                    },
                  ),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnap) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('settings')
                .doc('goal')
                .snapshots(),
            builder: (context, goalSnap) {
              final goal =
                  (goalSnap.data?.data() as Map<String, dynamic>?)?['amount']
                      as double? ??
                  0.0;

              if (usersSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = usersSnap.data?.docs ?? [];
              final totalCollected = users.fold<double>(
                0,
                (total, doc) =>
                    total +
                    ((doc.data() as Map<String, dynamic>)['totalContributed']
                                as num? ??
                            0)
                        .toDouble(),
              );

              final progress = goal > 0
                  ? (totalCollected / goal).clamp(0.0, 1.0)
                  : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF185FA5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Collected',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '৳ ${_fmt(totalCollected)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (goal > 0) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}% of ৳ ${_fmt(goal)} goal',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Member Contributions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate(1),
                          child: const Text(
                            'My history',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF185FA5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (users.isEmpty)
                      const Center(
                        child: Text(
                          'No contributions yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.4,
                            ),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          final data = users[i].data() as Map<String, dynamic>;
                          final name = data['name'] as String? ?? 'Unknown';
                          final amount = (data['totalContributed'] as num? ?? 0)
                              .toDouble();
                          final isMe = users[i].id == currentUser?.uid;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFFE6F1FB)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMe
                                    ? const Color(0xFF185FA5)
                                    : const Color(0xFFE0E0E0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF185FA5),
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        name + (isMe ? ' (you)' : ''),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '৳ ${_fmt(amount)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF185FA5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _fmt(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
  }
}
