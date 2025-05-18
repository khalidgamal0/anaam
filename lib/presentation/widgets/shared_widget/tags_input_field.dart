import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TagsInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(List<String>)? onTagsChanged;

  const TagsInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onTagsChanged,
  }) : super(key: key);

  @override
  State<TagsInputField> createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends State<TagsInputField> {
  List<String> _tags = [];
  TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      _tags = widget.controller.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        widget.controller.text = _tags.join(',');
      });
      _inputController.clear(); // مسح محتوى حقل الإدخال
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _inputController, // استخدام controller منفصل للإدخال
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_inputController.text.isNotEmpty) {
                  _addTag(_inputController.text.trim());
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addTag(value.trim());
            }
          },
        ),
        if (_tags.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                      widget.controller.text = _tags.join(',');
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
