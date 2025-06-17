import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> transactions = [];
  final formatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirebase();
  }
  Future<void> _loadCategoriesFromFirebase() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('categories')
      .where('uid', isEqualTo: user.uid)
      .get();

  if (!mounted) return;

  setState(() {
    categories = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'],
        'budget': data['budget'],
        'spent': data['spent'],
        'color': Color(data['color']),
        'icon': data['icon'],
      };
    }).toList();
  });
}


  Future<void> _themDanhMuc(
    String name,
    int budget,
    Color color,
    IconData icon,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('categories').add({
      'uid': user.uid,
      'name': name,
      'budget': budget,
      'spent': 0,
      'color': color.value,
      'icon': icon.codePoint,
    });

    _loadCategoriesFromFirebase();
  }

  Future<void> _xoaDanhMuc(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(id)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa danh mục thành công')));
      _loadCategoriesFromFirebase();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
    }
  }

  void _addCategory() {
    TextEditingController nameController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    Color selectedColor = Colors.grey;
    IconData selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setStateDialog) => AlertDialog(
                  title: const Text('Thêm danh mục'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tên danh mục',
                          ),
                        ),
                        TextField(
                          controller: budgetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Ngân sách (VND)',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Chọn màu:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children:
                              [
                                Colors.orange,
                                Colors.blue,
                                Colors.green,
                                Colors.purple,
                              ].map((color) {
                                return GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedColor == color
                                                ? Colors.black
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Chọn icon:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Wrap(
                          spacing: 10,
                          children:
                              [
                                Icons.shopping_cart,
                                Icons.restaurant,
                                Icons.party_mode,
                                Icons.directions_bus,
                                Icons.home,
                                Icons.school,
                                Icons.flight,
                                Icons.sports_soccer,
                              ].map((iconData) {
                                return GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      selectedIcon = iconData;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedIcon == iconData
                                              ? Colors.deepPurple
                                              : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconData,
                                      color:
                                          selectedIcon == iconData
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final budget =
                            int.tryParse(budgetController.text.trim()) ?? 0;
                        if (name.isNotEmpty) {
                          _themDanhMuc(
                            name,
                            budget,
                            selectedColor,
                            selectedIcon,
                          );
                          Navigator.of(ctx).pop();
                          _loadCategoriesFromFirebase();
                        }
                      },
                      child: const Text('Thêm'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục thu/chi'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (ctx, index) {
          final category = categories[index];
          final double spentPercent =
              category['budget'] > 0
                  ? category['spent'] / category['budget']
                  : 0.0;

          final bool isOverBudget = spentPercent >= 1.0;
          final bool isNearBudget = spentPercent >= 0.8;

          return TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            tween: ColorTween(
              begin: category['color'],
              end:
                  isOverBudget
                      ? Colors.red.shade700
                      : isNearBudget
                      ? category['color'].withOpacity(0.6)
                      : category['color'],
            ),
            builder: (context, animatedColor, child) {
              return Card(
                color: animatedColor,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading:
                      category['icon'] != null
                          ? Icon(
                            IconData(
                              category['icon']!,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: Colors.white,
                          )
                          : null,
                  title: Text(
                    category['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngân sách: ${formatter.format(category['budget'])} VND',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Đã sử dụng: ${formatter.format(category['spent'])} VND',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: spentPercent.clamp(0.0, 1.0),
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? Colors.red : Colors.orangeAccent,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _xoaDanhMuc(category['id']);
                      _loadCategoriesFromFirebase();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
