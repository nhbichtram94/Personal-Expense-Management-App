import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime selectedDate = DateTime.now();
  String filterType = 'Tháng';
  bool isBalanceVisible = true;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> categories = [];
  List<Transaction> listBieuDo = [];
  final formatter = NumberFormat('#,###', 'vi_VN');
  DateTime _selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadCategoriesFromFirebase();
    _loadTransactionsFromFirebase();
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('uid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .get();
    if (!mounted) return;
    setState(() {
      transactions =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'title': data['category'] ?? 'Chưa rõ',
              'icon': IconData(
                data['icon'] ?? 0xe14c,
                fontFamily: 'MaterialIcons',
              ),
              'color': Color(data['color'] ?? 0xFF9E9E9E),
              'sotien': '${formatter.format(data['sotien'])}',
              'createdAt':
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }).toList();
    });
  }

  Future<void> _loadCategoriesFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .where('uid', isEqualTo: user.uid)
            .limit(2)
            .get();
    if (!mounted) return;
    setState(() {
      categories =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'],
              'budget': data['budget'],
              'spent': '${formatter.format(data['spent'])}',
              'color': Color(data['color']),
              'icon': data['icon'],
            };
          }).toList();
    });
  }

  Future<void> _loadTransactionsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('uid', isEqualTo: user.uid)
            .get();
    if (!mounted) return;
    setState(() {
      listBieuDo =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Transaction.fromMap(data);
          }).toList();
    });
  }

  void _toggleBalanceVisibility() {
    setState(() {
      isBalanceVisible = !isBalanceVisible;
    });
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _selectedDate = picked;
      });
    }
  }

  String _formatDate() {
    return DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  Widget _buildToggleButton(String label, bool selected) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.blue : Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
    ),
  );
  Widget _buildSpendingItem(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildTransactionItem(Map<String, dynamic> txn) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Icon(txn['icon'], color: txn['color'], size: 30),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(txn['title'], style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              DateFormat('dd/MM/yyyy').format(txn['createdAt']),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Spacer(),
        Text(
          '${txn['sotien']} đ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thống Kê',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Báo cáo chi tiêu",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            BieuDoNgayWidget(
              transactions: listBieuDo,
              selectedDate: _selectedDate,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Thời gian: ${_formatDate()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: Icon(Icons.calendar_month_outlined),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Nhóm chi nhiều nhất",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...categories.map((cat) {
              return _buildSpendingItem(
                cat['name'],
                "${cat['spent'].toString()} đ",
                IconData(cat['icon'], fontFamily: 'MaterialIcons'),
                cat['color'],
              );
            }).toList(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Giao dịch gần đây",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ...transactions.map(_buildTransactionItem).toList(),
          ],
        ),
      ),
    );
  }
}

class Transaction {
  final double sotien;
  final DateTime createdAt;
  final Color color;

  Transaction({
    required this.sotien,
    required this.createdAt,
    required this.color,
  });

  factory Transaction.fromMap(Map<String, dynamic> data) {
    return Transaction(
      sotien: (data['sotien'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      color: Color(data['color']),
    );
  }
}

class BieuDoNgayWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final DateTime selectedDate;

  BieuDoNgayWidget({required this.transactions, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final sameDayTransactions =
        transactions.where((tx) {
          return tx.createdAt.year == selectedDate.year &&
              tx.createdAt.month == selectedDate.month &&
              tx.createdAt.day == selectedDate.day;
        }).toList();

    if (sameDayTransactions.isEmpty) {
      return Center(child: Text('Không có giao dịch trong ngày này.'));
    }

    final maxY =
        sameDayTransactions
            .map((tx) => tx.sotien)
            .reduce((a, b) => a > b ? a : b) +
        20;

    return Container(
      height: 300,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (double value) {
                int index = value.toInt();
                if (index >= sameDayTransactions.length) return '';
                final tx = sameDayTransactions[index];
                return "${tx.createdAt.hour}:${tx.createdAt.minute}";
              },
              margin: 12,
              reservedSize: 30,
            ),
            leftTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              margin: 12,
              reservedSize: 40,
            ),
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(sameDayTransactions.length, (index) {
            final tx = sameDayTransactions[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  y: tx.sotien,
                  colors: [tx.color],
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
