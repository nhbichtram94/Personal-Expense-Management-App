import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends State<NotificationPage> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> transactions = [];
  DateTime? yesterday;
  double chitieu = 0;
  double thunhap = 0;
  double dachi = 0;
  double hanmuc = 0;
  final formatter = NumberFormat('#,###', 'vi_VN');
  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirebase();
    _loadTransactionsFromFirebase();
    final now = DateTime.now();
    yesterday = DateTime(now.year, now.month, now.day);
  }

  List<Map<String, String>> noticategories = [];
  List<Map<String, String>> notitransactions = [];
  bool flag = false;
  final List<Map<String, String>> notifications = [
    {
      "title": "Tổng kết ngày hôm qua",
      "content": "Bạn đã chi 230.000đ và thu 100.000đ hôm qua.",
      "time": "08:00 hôm nay",
    },
    {
      "title": "⚠️ Gần hết hạn mức chi tiêu",
      "content": "Danh mục Ăn uống đã chi 950.000đ/1.000.000đ.",
      "time": "Hôm qua, 20:05",
    },
    {
      "title": "✅ Đã thêm thu nhập",
      "content": "Bạn đã thêm 3.000.000đ vào ví.",
      "time": "2 ngày trước",
    },
  ];
  Future<void> _loadCategoriesFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('categories')
            .where('uid', isEqualTo: user.uid)
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
              'spent': data['spent'],
              'color': Color(data['color']),
              'icon': data['icon'],
            };
          }).toList();
      for (var t in categories) {
        if (t['spent'] / t['budget'] >= 0.8) {
          noticategories.add({
            'name': t['name'],
            'budget': t['budget'].toString(),
            'spent': t['spent'].toString(),
            'title': 'Gần hết hạn mức chi tiêu!',
            'thongbao':
                'Danh mục ${t['name']} đã chi tiêu ${formatter.format(t['spent'])}đ / ${formatter.format(t['budget'])}đ',
          });
        }
      }
    });
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
      for (var t in transactions) {
        final Timestamp ts = t['createdAt'];
        final DateTime date = ts.toDate();
        if (t['title'] == 'Nạp Tiền' &&
            date.year == yesterday!.year &&
            date.month == yesterday!.month &&
            date.day == yesterday!.day) {
          thunhap += t['sotien'];
          flag = true;
        }
      }
      for (var t in transactions) {
        final Timestamp ts = t['createdAt'];
        final DateTime date = ts.toDate();
        if (t['title'] != 'Nạp Tiền' &&
            date.year == yesterday!.year &&
            date.month == yesterday!.month &&
            date.day == yesterday!.day) {
          chitieu += t['sotien'];
          flag = true;
        }
      }
      if (flag) {
        noticategories.add({
          'title': 'Tổng kết ngày hôm qua',
          'thongbao': 'Bạn đã chi tiêu ${formatter.format(chitieu)}đ và thu nhập ${formatter.format(thunhap)}đ',
          'time': '$yesterday',
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông Báo')),
      body: ListView.builder(
        itemCount: noticategories.length,
        itemBuilder: (context, index) {
          final noti = noticategories[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.redAccent,
              ),
              title: Text(
                noti["title"] ?? "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(noti["thongbao"] ?? ""),
                  SizedBox(height: 4),
                  Text(
                    noti["time"] ?? "",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      
    );
  }
}
