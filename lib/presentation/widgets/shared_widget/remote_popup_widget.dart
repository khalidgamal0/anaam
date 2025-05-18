import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemotePopupModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final int delaySeconds;
  final int autoCloseSeconds;
  final bool isActive;
  final DateTime startAt;
  final DateTime endAt;
  final int priority;
  final String deviceType;
  final DateTime createdAt;
  final DateTime updatedAt;

  RemotePopupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.delaySeconds,
    required this.autoCloseSeconds,
    required this.isActive,
    required this.startAt,
    required this.endAt,
    required this.priority,
    required this.deviceType,
    required this.createdAt,
    required this.updatedAt,
  });

  // هل يجب إغلاق النافذة المنبثقة تلقائيًا
  bool get shouldAutoClose => autoCloseSeconds > 0;

  factory RemotePopupModel.fromJson(Map<String, dynamic> json) {
    // التأكد من أن وقت الإغلاق التلقائي موجب (أو صفر للعرض بدون إغلاق تلقائي)
    int autoClose = 0;
    if (json['auto_close_seconds'] is int) {
      autoClose =
          json['auto_close_seconds'] > 0 ? json['auto_close_seconds'] : 0;
    }

    // التأكد من أن وقت التأخير موجب أو صفر
    int delay = 0;
    if (json['delay_seconds'] is int) {
      delay = json['delay_seconds'] >= 0 ? json['delay_seconds'] : 0;
    }

    return RemotePopupModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      link: json['link'],
      delaySeconds: delay,
      autoCloseSeconds: autoClose,
      isActive: json['is_active'] == 1,
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      priority: json['priority'],
      deviceType: json['device_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link': link,
      'delay_seconds': delaySeconds,
      'auto_close_seconds': autoCloseSeconds,
      'is_active': isActive ? 1 : 0,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'priority': priority,
      'device_type': deviceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RemotePopupManager {
  static const String popupApiUrl = 'https://ban3am.com/api/v2/popup';
  static const String cachePrefKey = 'remote_popups_cache';
  static const String lastFetchTimePrefKey = 'remote_popups_last_fetch';
  static const Duration updateInterval =
      Duration(minutes: 15); // تحديث كل 15 دقيقة

  static Timer? _autoCloseTimer;
  static Timer? _updateTimer;
  static List<RemotePopupModel> _cachedPopups = [];
  static int _currentPopupIndex = 0;
  static bool _isShowingPopup = false;
  static const int defaultAutoCloseTime = 10; // وقت افتراضي للإغلاق التلقائي

  // سجل النوافذ المنبثقة التي تم عرضها في الجلسة الحالية
  static final Set<int> _shownPopupsIds = {};

  // تهيئة المدير وبدء مؤقت التحديث
  static Future<void> init() async {
    // إلغاء المؤقتات القديمة إن وجدت
    _updateTimer?.cancel();
    _autoCloseTimer?.cancel();

    // إعادة تعيين سجل النوافذ المعروضة وحالة العرض
    _shownPopupsIds.clear();
    _currentPopupIndex = 0;
    _isShowingPopup = false;

    // قراءة البيانات المخزنة
    await _loadCachedData();

    // بدء مؤقت التحديث
    _updateTimer = Timer.periodic(updateInterval, (_) async {
      await _fetchAndCachePopups(forceUpdate: true);
    });

    // تحديث البيانات عند بدء التشغيل
    await _fetchAndCachePopups();
  }

  // إلغاء المؤقتات عند إغلاق التطبيق
  static void dispose() {
    _updateTimer?.cancel();
    _autoCloseTimer?.cancel();
    _shownPopupsIds.clear();
    _isShowingPopup = false;
  }

  // تحميل البيانات المخزنة
  static Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(cachePrefKey);

      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        if (data['data'] is List) {
          _cachedPopups = (data['data'] as List)
              .map((item) => RemotePopupModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      _cachedPopups = [];
    }
  }

  // جلب وتخزين النوافذ المنبثقة
  static Future<void> _fetchAndCachePopups({bool forceUpdate = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int lastFetchTime = prefs.getInt(lastFetchTimePrefKey) ?? 0;
      final int now = DateTime.now().millisecondsSinceEpoch;

      // التحقق مما إذا كان الوقت قد حان للتحديث
      if (!forceUpdate && now - lastFetchTime < updateInterval.inMilliseconds) {
        return;
      }

      final response = await http.get(Uri.parse(popupApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData['data'] is List) {
          // تحديث البيانات المخزنة
          await prefs.setString(cachePrefKey, response.body);
          await prefs.setInt(lastFetchTimePrefKey, now);

          // تحديث الذاكرة المؤقتة
          _cachedPopups = (responseData['data'] as List)
              .map((item) => RemotePopupModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      // في حالة حدوث خطأ، نعتمد على البيانات المخزنة
    }
  }

  // الحصول على النوافذ المنبثقة المتاحة التي لم يتم عرضها بعد
  static List<RemotePopupModel> _getAvailablePopupsNotShown() {
    final DateTime now = DateTime.now();

    // فلترة النوافذ المنبثقة النشطة والتي في نطاق التاريخ الصحيح ولم يتم عرضها بعد
    final availablePopups = _cachedPopups
        .where((popup) =>
            popup.isActive &&
            popup.startAt.isBefore(now) &&
            popup.endAt.isAfter(now) &&
            (popup.deviceType == 'both' || popup.deviceType == 'mobile') &&
            !_shownPopupsIds.contains(popup.id))
        .toList();

    // ترتيب النوافذ المنبثقة حسب الأولوية
    availablePopups.sort((a, b) => a.priority.compareTo(b.priority));

    return availablePopups;
  }

  // إظهار النوافذ المنبثقة إذا كانت متاحة
  static Future<void> showPopupIfAvailable(BuildContext context) async {
    // منع عرض عدة نوافذ في نفس الوقت
    if (!context.mounted || _isShowingPopup) return;

    // تحديث البيانات إذا لزم الأمر
    await _fetchAndCachePopups();

    // الحصول على النوافذ المنبثقة المتاحة التي لم يتم عرضها بعد
    final availablePopups = _getAvailablePopupsNotShown();

    // إذا لم تكن هناك نوافذ منبثقة متاحة، لا نفعل شيئًا
    if (availablePopups.isEmpty) return;

    // الحصول على النافذة المنبثقة الأولى (الأعلى أولوية)
    final popup = availablePopups.first;

    // تسجيل النافذة المنبثقة كمعروضة لمنع عرضها مرة أخرى
    _shownPopupsIds.add(popup.id);

    // تعيين حالة العرض
    _isShowingPopup = true;

    // تأخير إظهار النافذة المنبثقة حسب المدة المحددة
    Future.delayed(Duration(seconds: popup.delaySeconds), () {
      if (!context.mounted) {
        _isShowingPopup = false;
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.75),
        builder: (BuildContext dialogContext) {
          // إعداد مؤقت الإغلاق التلقائي
          _setupAutoCloseTimer(popup, dialogContext, context);

          return RemotePopupDialog(
            popup: popup,
            onClose: () {
              // إعادة تعيين حالة العرض
              _isShowingPopup = false;

              // عرض النافذة التالية بعد فترة قصيرة
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  showPopupIfAvailable(context);
                }
              });
            },
          );
        },
      ).then((_) {
        if (_autoCloseTimer != null && _autoCloseTimer!.isActive) {
          _autoCloseTimer!.cancel();
        }
        _isShowingPopup = false;
      });
    });
  }

  // إعداد مؤقت الإغلاق التلقائي
  static void _setupAutoCloseTimer(RemotePopupModel popup,
      BuildContext dialogContext, BuildContext parentContext) {
    // إلغاء أي مؤقت سابق
    _autoCloseTimer?.cancel();

    // تحديد وقت الإغلاق - إما من الـ API أو الوقت الافتراضي
    final int autoCloseTime =
        popup.shouldAutoClose ? popup.autoCloseSeconds : defaultAutoCloseTime;

    debugPrint(
        '⚡ سيتم إغلاق النافذة المنبثقة تلقائيًا بعد $autoCloseTime ثانية');

    // إنشاء مؤقت جديد
    _autoCloseTimer = Timer(Duration(seconds: autoCloseTime), () {
      debugPrint('⚡ انتهى وقت النافذة المنبثقة، جاري الإغلاق...');

      if (dialogContext.mounted) {
        try {
          Navigator.of(dialogContext, rootNavigator: true).pop();
          debugPrint('⚡ تم إغلاق النافذة المنبثقة بنجاح');

          // إعادة تعيين حالة العرض
          _isShowingPopup = false;

          // عرض النافذة التالية بعد فترة قصيرة
          Future.delayed(const Duration(milliseconds: 300), () {
            if (parentContext.mounted) {
              showPopupIfAvailable(parentContext);
            }
          });
        } catch (e) {
          debugPrint('⚡ خطأ عند إغلاق النافذة المنبثقة: $e');
          _isShowingPopup = false;
        }
      } else {
        debugPrint('⚡ سياق النافذة المنبثقة غير متاح');
        _isShowingPopup = false;
      }
    });
  }

  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('⚡ خطأ عند فتح الرابط: $e');
    }
  }

  // إعادة تعيين سجل النوافذ المعروضة للسماح بعرضها مرة أخرى
  static void resetShownPopups() {
    _shownPopupsIds.clear();
  }
}

class RemotePopupDialog extends StatefulWidget {
  final RemotePopupModel popup;
  final VoidCallback? onClose;

  const RemotePopupDialog({
    Key? key,
    required this.popup,
    this.onClose,
  }) : super(key: key);

  @override
  State<RemotePopupDialog> createState() => _RemotePopupDialogState();
}

class _RemotePopupDialogState extends State<RemotePopupDialog>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _closed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // تعيين الوقت المتبقي
    _remainingSeconds = widget.popup.shouldAutoClose
        ? widget.popup.autoCloseSeconds
        : RemotePopupManager.defaultAutoCloseTime;

    // إعداد الرسوم المتحركة
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // بدء الرسوم المتحركة
    _animationController.forward();

    // بدء المؤقت التنازلي
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _countdownTimer?.cancel();
            // محاولة إغلاق النافذة إذا انتهى العد التنازلي ولم تغلق بعد
            if (!_closed && mounted) {
              _closePopup();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _closePopup() {
    if (!_closed) {
      _closed = true;

      // الرسوم المتحركة للإغلاق
      _animationController.reverse().then((_) {
        Navigator.of(context).pop();
        widget.onClose?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 600;
    final double dialogWidth = isLargeScreen ? 450 : screenSize.width * 0.9;
    final double imageHeight = isLargeScreen ? 220 : 180;

    // تحديد ألوان الـ UI
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final Color backgroundColor = Colors.white;
    final Color buttonColor = primaryColor;

    return PopScope(
      // منع إغلاق النافذة المنبثقة بالضغط على زر الرجوع
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _closePopup();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5 * _opacityAnimation.value,
              sigmaY: 5 * _opacityAnimation.value,
            ),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 12,
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: dialogWidth,
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // صورة الرأس مع العداد
                          Stack(
                            children: [
                              // الصورة
                              Hero(
                                tag: 'popup_image_${widget.popup.id}',
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://ban3am.com/storage/${widget.popup.imageUrl}',
                                  width: double.infinity,
                                  height: imageHeight,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: imageHeight,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: imageHeight,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                              // طبقة التدرج في أعلى الصورة
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.3],
                                    ),
                                  ),
                                ),
                              ),

                              // طبقة التدرج في أسفل الصورة
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.4],
                                    ),
                                  ),
                                ),
                              ),

                              // زر الإغلاق في الزاوية العليا
                              Positioned(
                                left: 8,
                                top: 8,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _closePopup,
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            spreadRadius: 0,
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // عداد الإغلاق التلقائي
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // حلقة التقدم
                                      SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: CircularProgressIndicator(
                                          value: _remainingSeconds /
                                              (widget.popup.shouldAutoClose
                                                  ? widget
                                                      .popup.autoCloseSeconds
                                                  : RemotePopupManager
                                                      .defaultAutoCloseTime),
                                          strokeWidth: 3,
                                          color: accentColor,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      // رقم العد التنازلي
                                      Text(
                                        '$_remainingSeconds',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // عنوان النافذة المنبثقة (على الصورة مباشرة)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                left: 16,
                                child: Text(
                                  widget.popup.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),

                          // الوصف
                          Flexible(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 20, 24, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.popup.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black.withOpacity(0.8),
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // الأزرار
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: widget.popup.link.isNotEmpty
                                ? _buildMainActionButton(context, buttonColor)
                                : _buildCloseButton(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // بناء زر "معرفة المزيد"
  Widget _buildMainActionButton(BuildContext context, Color buttonColor) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          RemotePopupManager.openUrl(widget.popup.link);
          _closePopup();
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'معرفة المزيد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // بناء زر "إغلاق"
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _closePopup,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'إغلاق',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
