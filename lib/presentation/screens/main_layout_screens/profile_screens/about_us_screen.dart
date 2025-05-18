import 'package:an3am/data/models/about_us_response.dart';
import 'package:an3am/data/models/contact_us_request.dart';
import 'package:an3am/data/models/contact_us_response.dart';
import 'package:an3am/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json.decode and json.encode

// TODO: Consider moving API URLs to a dedicated constants file
const String _aboutUsApiUrl = 'https://ban3am.com/api/v2/about-us';
const String _contactUsApiUrl = 'https://ban3am.com/api/v2/about-us/contact';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late Future<AboutUsResponse> _aboutUsFuture;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmittingContactForm = false;

  @override
  void initState() {
    super.initState();
    _aboutUsFuture = _fetchAboutUsData();
  }

  Future<AboutUsResponse> _fetchAboutUsData() async {
    try {
      final response = await http.get(Uri.parse(_aboutUsApiUrl));
      if (response.statusCode == 200) {
        // Make sure to decode with utf8 to handle Arabic characters correctly
        return AboutUsResponse.fromString(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load about us data (${response.statusCode})');
      }
    } catch (e) {
      // In a real app, you might want to log this error or show a user-friendly message
      throw Exception('Failed to load about us data: \$e');
    }
  }

  Future<void> _submitContactForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmittingContactForm = true;
      });

      final request = ContactUsRequest(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        notes: _notesController.text,
      );

      try {
        final response = await http.post(
          Uri.parse(_contactUsApiUrl),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: request.toJsonString(),
        );

        if (mounted) { // Check if the widget is still in the tree
          final contactResponse = ContactUsResponse.fromString(utf8.decode(response.bodyBytes));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(contactResponse.message),
              backgroundColor: contactResponse.success ? Colors.green : Colors.red,
            ),
          );
          if (contactResponse.success) {
            _formKey.currentState?.reset();
            _nameController.clear();
            _emailController.clear();
            _phoneController.clear();
            _notesController.clear();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleKeys.contact_form_error_message.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmittingContactForm = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.about_us.tr()),
        elevation: 0.5, // Subtle shadow
      ),
      body: FutureBuilder<AboutUsResponse>(
        future: _aboutUsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: \${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final aboutUsData = snapshot.data!;
            final currentLocale = context.locale.languageCode;

            String getLocalized(LocalizedText? localized, {String fallback = ''}) {
              if (localized == null) return fallback;
              return (currentLocale == 'ar' ? localized.ar : localized.en) ??
                  localized.ar ??
                  localized.en ??
                  fallback;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0), // Increased padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                children: [
                  // Company Info Section
                  Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(bottom: 24.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getLocalized(aboutUsData.company.title, fallback: LocaleKeys.about_us.tr()),
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getLocalized(aboutUsData.company.description),
                            style: textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expressions Section (Mission, Vision, Why us)
                  ...aboutUsData.expressions.map((expression) {
                    String title = '';
                    IconData? iconData;

                    if (expression.title.ar == "مهمتنا") {
                      title = LocaleKeys.our_mission.tr();
                      iconData = Icons.track_changes; // Example icon
                    } else if (expression.title.ar == "رؤيتنا") {
                      title = LocaleKeys.our_vision.tr();
                      iconData = Icons.visibility; // Example icon
                    } else if (expression.title.ar == "لماذا انعام؟") {
                      title = LocaleKeys.why_choose_us.tr();
                      iconData = Icons.question_answer_outlined; // Example icon
                    }
                    if (title.isEmpty) title = getLocalized(expression.title);

                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (iconData != null)
                                  Icon(iconData, color: colorScheme.secondary, size: 28),
                                if (iconData != null) const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              getLocalized(expression.description),
                              style: textTheme.bodyMedium?.copyWith(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // Contact Us Form Section
                  Text(
                    LocaleKeys.contact_us_title.tr(),
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextFormField(
                          controller: _nameController,
                          label: LocaleKeys.name_field_label.tr(),
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.field_is_required.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _emailController,
                          label: LocaleKeys.email_field_label.tr(),
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.field_is_required.tr();
                            }
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                              return LocaleKeys.invalid_email_format.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _phoneController,
                          label: LocaleKeys.phone_field_label.tr(),
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.field_is_required.tr();
                            }
                            // Basic phone validation (you might want a more robust one)
                            if (value.length < 7) {
                               return "رقم هاتف قصير جدا"; // TODO: Localize
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _notesController,
                          label: LocaleKeys.notes_field_label.tr(),
                          icon: Icons.notes_outlined,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return LocaleKeys.field_is_required.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _isSubmittingContactForm
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submitContactForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  textStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                ),
                                child: Text(LocaleKeys.send_button.tr()),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(LocaleKeys.loading_data.tr(), style: textTheme.titleMedium),
              )
            ); 
          }
        },
      ),
    );
  }

  // Helper method to build styled TextFormFields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: validator,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
    );
  }
}
