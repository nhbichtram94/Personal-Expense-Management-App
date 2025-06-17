import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanlythuchi/trangchu.dart';

class Thuchi extends StatefulWidget {
  const Thuchi({super.key});

  @override
  State<Thuchi> createState() => _ThuchiState();
}

class _ThuchiState extends State<Thuchi> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirebase();//tải danh mục người dùng từ Firestore
  }
Future<void> _loadCategoriesFromFirebase() async { // truy vấn danh mục người dùng
  User? user = FirebaseAuth.instance.currentUser; // lấy user đang đăng nhập
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('categories')
      .where('uid', isEqualTo: user.uid) 
      .get();//lấy danh mục user hiện tại

  if (!mounted) return; //Kiểm tra widget còn tồn tại trước khi gọi setState

  setState(() {
     // cập nhật danh sách categories để hiển thị lại giao diện
    categories = snapshot.docs
        .map((doc) {// duyệt từng document
          final data = doc.data();
          if (data['icon'] != null && data['color'] != null) { // lọc bỏ dữ liệu null
            return {
              'title': data['name'],
              'icon': IconData(data['icon'], fontFamily: 'MaterialIcons'),
              'color': Color(data['color']),
            };
          }
          return null;
        })
        .where((category) => category != null)
        .toList()
        .cast<Map<String, dynamic>>(); // ép kiểu danh sách
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thu Chi'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh mục hôm nay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  categories.isEmpty
                      ? const Center(
                        child: Text(
                          'Chưa có danh mục, hãy thêm ở mục danh mục!',
                        ),
                      )
                      : Wrap( //sắp xếp dạng lưới
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            categories.map((cat) {
                              return CategoryCard(
                                title: cat['title'],
                                icon: cat['icon'],
                                color: cat['color'],
                              );
                            }).toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  }); // widget đại diện cho từng danh mục thu chi (an uống, ...)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { // khi nhấn vào danh mục
        showDialog(
          context: context,
          builder: (_) => InputDialog(title: title, icon: icon, color: color), // mở input khi người dùng chọn một danh mục
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class InputDialog extends StatefulWidget { // hộp nhập giao dịch, nhận thông tin danh mục từ categoryCard
  final String title;
  final IconData icon;
  final Color color;

  const InputDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController moneyController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  Future<void> saveTransaction() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('transactions').add({ // dữ liệu được lưu vào collection transactions
          'uid': user.uid,
          'sotien': double.parse(moneyController.text),
          'mota': noteController.text,
          'category': widget.title,
          'icon': widget.icon.codePoint,
          'color': widget.color.value,
          'createdAt': DateTime.now(),
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu giao dịch: $e')));
      }
    }
  }

  Future<void> updateCategorySpent({ // công thêm chi tiêu vào danh mục
    required String categoryName,
    required double amount,
  }) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .where('name', isEqualTo: categoryName)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final currentSpent = doc['spent'] ?? 0;
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(doc.id)
          .update({'spent': currentSpent + amount});
    } else {
      throw Exception("Không tìm thấy danh mục để cập nhật.");
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
          Expanded(child: Text('Thêm chi tiêu: ${widget.title}')),
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
            TextField(                // nhập số tiền và ghi chú
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
          onPressed: () { // nút LƯU
            final money = moneyController.text.trim();
            final note = noteController.text.trim();

            if (money.isEmpty) { // kiểm tra trống
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập số tiền')),
              );
              return;
            }

            saveTransaction();
            // Thông báo lưu thành công
            updateCategorySpent( // cập nhật tổng chi tiêu danh mục
              categoryName: widget.title,
              amount: double.parse(money),
            );
            showDialog( // sau khi lưu thành công
              context: context,
              builder:
                  (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('✅ Thành công'),
                    content: Text(
                      'Đã lưu chi tiêu "${widget.title}" với số tiền $money VNĐ',
                    ),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Trangchu(),// chuyển về trang chủ
                              ),
                            ),
                      ),
                    ],
                  ),
            );
          },
        ),
      ],
    );
  }
}
