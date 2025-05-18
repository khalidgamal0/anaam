import 'package:flutter/material.dart';
import 'remote_popup_widget.dart';

class PopupExampleScreen extends StatefulWidget {
  const PopupExampleScreen({Key? key}) : super(key: key);

  @override
  State<PopupExampleScreen> createState() => _PopupExampleScreenState();
}

class _PopupExampleScreenState extends State<PopupExampleScreen> {
  @override
  void initState() {
    super.initState();
    // تهيئة مدير النوافذ المنبثقة
    RemotePopupManager.init();

    // استدعاء النافذة المنبثقة بعد بناء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RemotePopupManager.showPopupIfAvailable(context);
    });
  }

  @override
  void dispose() {
    // إلغاء المؤقتات عند إغلاق الشاشة
    RemotePopupManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مثال النافذة المنبثقة'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'اضغط على الزر لعرض النوافذ المنبثقة المتاحة',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // استدعاء النافذة المنبثقة عند الضغط على الزر
                RemotePopupManager.showPopupIfAvailable(context);
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('عرض النوافذ المنبثقة'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'سيتم عرض النوافذ المنبثقة المتاحة واحدة تلو الأخرى حسب الأولوية',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
