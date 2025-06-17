import 'package:flutter/material.dart';
import 'package:quanlythuchi/giaodich.dart';
import 'package:quanlythuchi/dangnhap.dart';
import 'package:quanlythuchi/category_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:quanlythuchi/profile.dart';
import 'package:quanlythuchi/thongbao.dart';
import 'package:quanlythuchi/thongke.dart';

class Trangchu extends StatefulWidget {
  @override
  _TrangchuState createState() => _TrangchuState();
}

class _TrangchuState extends State<Trangchu> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> transactions = [];
  double tongSoTien = 0;
  double sotientieu = 0;
  String hoten = '';
  String email = '';
  @override
  void initState() {
    super.initState();
    _loadTransactionsFromFirebase();
  }

  Future<void> _loadTransactionsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('uid', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

    if (!mounted) return;
    setState(() {
      transactions =
          snapshot.docs
              .map((doc) {
                final data = doc.data();
                if (data['icon'] != null && data['color'] != null) {
                  return {
                    'title': data['category'],
                    'icon': IconData(data['icon'], fontFamily: 'MaterialIcons'),
                    'color': Color(data['color']),
                    'sotien': data['sotien'],
                    'mota': data['mota'],
                    'createdAt': data['createdAt'],
                  };
                }
                return null;
              })
              .where((category) => category != null)
              .toList()
              .cast<Map<String, dynamic>>();
      tongSoTien = 0;
      for (var t in transactions) {
        if (t['title'] == 'Nạp Tiền') {
          tongSoTien += t['sotien'];
        }
      }
      sotientieu = 0;
      for (var t in transactions) {
        if (t['title'] != 'Nạp Tiền') {
          sotientieu += t['sotien'];
        }
      }
    });
  }

  Future<void> _loadUserProfilenew() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (!mounted) return;
      final data = snapshot.data();

      if (data != null) {
        setState(() {
          hoten = data['name'] ?? '';
          email = data['email'] ?? '';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Thuchi()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StatisticsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thu chi"),
        backgroundColor: const Color.fromARGB(22, 234, 5, 97),

        // Icon bên trái (mở drawer + tải thông tin)
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                  _loadUserProfilenew();
                },
              ),
        ),

        // Icon bên phải (chuông thông báo)
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFFEA0561),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                hoten,
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPictureSize: const Size.square(50),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: Image.asset(
                    "assets/images/logo.jpg",
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFD90464),
              ), // Tùy chỉnh màu header
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Thông tin cá nhân',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DangNhap()),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.redAccent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Phạm Xuân Bách"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${NumberFormat("#,##0", "vi_VN").format(tongSoTien - sotientieu)}đ",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => InputDialog(),
                            ).then((_) => _loadTransactionsFromFirebase());
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Giao dịch gần đây"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final icon = transaction['icon'] as IconData;
                  final color = transaction['color'] as Color;
                  final title = transaction['title'] ?? '';
                  final mota = transaction['mota'] ?? '';
                  final sotien = transaction['sotien'] ?? 0;
                  final ngay = (transaction['createdAt'] as Timestamp).toDate();

                  final formattedDate = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(ngay);
                  return ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mota),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Text(
                      "${NumberFormat("#,##0", "vi_VN").format(sotien)}đ",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Thuchi()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang Chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: "Chi Tiêu",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Danh Mục"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Thống Kê",
          ),
        ],
      ),
    );
  }
}

class InputDialog extends StatefulWidget {
  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController moneyController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final IconData icon = Icons.attach_money;

  Future<void> saveTransaction() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('transactions').add({
          'uid': user.uid,
          'sotien': double.parse(moneyController.text),
          'mota': noteController.text,
          'category': 'Nạp Tiền',
          'icon': icon.codePoint,
          'color': Colors.green.value,
          'createdAt': Timestamp.now(),
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu giao dịch: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now());

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.teal),
          const SizedBox(width: 8),
          const Expanded(child: Text('Thêm chi tiêu: Nạp tiền')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🕓 $currentTime',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Hủy'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Lưu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            final money = moneyController.text.trim();
            final note = noteController.text.trim();

            if (money.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số tiền')),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nạp Tiền Thành Công')),
            );
            Navigator.of(context).pop();
            await saveTransaction();
          },
        ),
      ],
    );
  }
}
