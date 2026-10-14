
import 'package:flutter/material.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/edit_transaction_screen.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

const Color primaryColor = Color(0xFF4B55D4);
const Color darkColor = Color(0xFF192342);
const Color backgroundColor = Color(0xFFF6F7FC);

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// MÀN HÌNH CHÀO MỪNG
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 4),
            const WalletIllustration(),
            const SizedBox(height: 20),
            const Text(
              'Expense Manager',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Color(0xFF858DA8),
              ),
            ),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseHomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// HÌNH MINH HỌA VÍ TIỀN
class WalletIllustration extends StatelessWidget {
  const WalletIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            left: 29,
            child: Container(
              width: 47,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF65D27C),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 23,
            child: Container(
              width: 48,
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xFF36C96B),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            top: 29,
            left: 10,
            child: Container(
              width: 88,
              height: 49,
              decoration: BoxDecoration(
                color: const Color(0xFF4D65E9),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 10,
            child: Container(
              width: 36,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF3833B4),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MÀN HÌNH QUẢN LÝ CHI TIÊU
class ExpenseHomeScreen extends StatefulWidget {
  const ExpenseHomeScreen({super.key});

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();

    if (!mounted) return;

    setState(() {
      transactions
        ..clear()
        ..addAll(data.map((item) {
          final isExpense = item['isExpense'] == 1;
          final category = item['category'] as String;

          return {
            ...item,
            'amount': isExpense
                ? -(item['amount'] as num).toInt()
                : (item['amount'] as num).toInt(),
            'date': item['date'].toString().substring(0, 10),
            'icon': getCategoryIcon(category),
            'color': getCategoryColor(category),
          };
        }));
    });
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Di chuyển':
        return Icons.directions_bus;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Lương':
      case 'Tiền làm thêm':
        return Icons.account_balance_wallet;
      default:
        return Icons.receipt_long;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFFA726);
      case 'Di chuyển':
        return const Color(0xFF42A5F5);
      case 'Mua sắm':
        return const Color(0xFFAB70D6);
      case 'Lương':
      case 'Tiền làm thêm':
        return const Color(0xFF66BB6A);
      default:
        return primaryColor;
    }
  }

  final List<Map<String, dynamic>> transactions = [];


  int get totalIncome {
    return transactions.fold<int>(
      0,
          (sum, item) =>
      sum + ((item['amount'] as int) > 0 ? item['amount'] as int : 0),
    );
  }

  int get totalExpense {
    return transactions.fold<int>(
      0,
          (sum, item) =>
      sum + ((item['amount'] as int) < 0 ? -(item['amount'] as int) : 0),
    );
  }

  int get balance => totalIncome - totalExpense;

  String formatMoney(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-' : ''}${buffer.toString()} đ';
  }


  Future<void> showAddTransactionDialog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );


    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm giao dịch thành công!'),
        ),
      );
    }
  }

  Future<void> showEditTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(
          transaction: transaction,
        ),
      ),
    );

    if (result == true && mounted) {
      await loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật giao dịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Expense Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn chưa có thông báo mới.'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: darkColor,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          buildHomeTab(),
          buildStatisticsTab(),
          buildTransactionsTab(),
          buildProfileTab(),
        ],
      ),
      floatingActionButton: selectedTab == 0 || selectedTab == 2
          ? FloatingActionButton(
        onPressed: showAddTransactionDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4B55D4), Color(0xFF6976F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tổng số dư',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                formatMoney(balance),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '↓  Thu nhập: ${formatMoney(totalIncome)}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                '↑  Chi tiêu: ${formatMoney(totalExpense)}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => selectedTab = 2),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions.take(4).map(buildTransactionCard),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as int;
    final color = transaction['color'] as Color;

    return InkWell(
        onTap: () => showEditTransaction(transaction),
        borderRadius: BorderRadius.circular(15),
        child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction['icon'] as IconData, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  transaction['date'] as String,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${amount >= 0 ? '+' : '-'}${formatMoney(amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: amount >= 0
                  ? const Color(0xFF2EAA66)
                  : const Color(0xFFE05252),
            ),
          ),
        ],
      ),
        ),
    );
  }
  Widget buildStatisticsTab() {
    final total = totalIncome + totalExpense;
    final incomePercent = total == 0 ? 0.0 : totalIncome / total;
    final expensePercent = total == 0 ? 0.0 : totalExpense / total;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Thống kê thu chi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 20),
        buildSummaryCard(
          'Tổng thu nhập',
          formatMoney(totalIncome),
          Icons.trending_up,
          const Color(0xFF2EAA66),
        ),
        buildSummaryCard(
          'Tổng chi tiêu',
          formatMoney(totalExpense),
          Icons.trending_down,
          const Color(0xFFE05252),
        ),
        buildSummaryCard(
          'Số dư hiện tại',
          formatMoney(balance),
          Icons.account_balance_wallet,
          primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'Tỷ lệ thu chi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: incomePercent,
          minHeight: 12,
          backgroundColor: const Color(0xFFFFD9D9),
          color: const Color(0xFF2EAA66),
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 10),
        Text('Thu nhập: ${(incomePercent * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 8),
        Text('Chi tiêu: ${(expensePercent * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget buildSummaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Tất cả giao dịch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),
        const SizedBox(height: 20),
        if (transactions.isEmpty)
          const Center(child: Text('Chưa có giao dịch nào.')),
        ...transactions.map(buildTransactionCard),
        const SizedBox(height: 70),
      ],
    );
  }

  Widget buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE6E8FF),
          child: Icon(Icons.person, size: 48, color: primaryColor),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Người dùng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
        ),
        const SizedBox(height: 28),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Thông tin cá nhân'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng đang được phát triển.')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Cài đặt'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng đang được phát triển.')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Về ứng dụng'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Expense Manager',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Ứng dụng quản lý chi tiêu cá nhân.',
            );
          },
        ),
      ],
    );
  }
}
