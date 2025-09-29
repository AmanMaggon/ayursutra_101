import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalDetailsFormWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PersonalDetailsFormWidget({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<PersonalDetailsFormWidget> createState() =>
      _PersonalDetailsFormWidgetState();
}

class _PersonalDetailsFormWidgetState extends State<PersonalDetailsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _selectedTitle = 'Mr.';
  DateTime? _selectedDate;
  String _selectedLanguage = 'en';

  static const List<String> _titles = ['Mr.', 'Ms.', 'Dr.', 'Mrs.'];
  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिंदी'},
    {'code': 'ml', 'name': 'മലയാളം'},
    {'code': 'bn', 'name': 'বাংলা'},
    {'code': 'mr', 'name': 'मराठी'},
    {'code': 'ta', 'name': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController.text = widget.formData['fullName'] ?? '';
    _emailController.text = widget.formData['email'] ?? '';
    _phoneController.text = widget.formData['phoneNumber'] ?? '';
    _emergencyNameController.text =
        widget.formData['emergencyContactName'] ?? '';
    _emergencyPhoneController.text =
        widget.formData['emergencyContactPhone'] ?? '';
    _cityController.text = widget.formData['city'] ?? '';
    _stateController.text = widget.formData['state'] ?? '';
    _selectedTitle = widget.formData['title'] ?? 'Mr.';
    _selectedLanguage = widget.formData['language'] ?? 'en';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Personal Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your basic information for account creation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Name Section
            _buildSectionHeader('Full Name'),
            Row(
              children: [
                // Title Dropdown
                Container(
                  width: 80,
                  child: DropdownButtonFormField<String>(
                    value: _selectedTitle,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                    items: _titles.map((title) {
                      return DropdownMenuItem(
                        value: title,
                        child: Text(title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTitle = value!;
                      });
                      _updateFormData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Full Name Field
                Expanded(
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your complete name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    onChanged: (_) => _updateFormData(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Information
            _buildSectionHeader('Contact Information'),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '+91 XXXXX XXXXX',
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your mobile number';
                }
                if (value!.length != 10) {
                  return 'Please enter a valid 10-digit mobile number';
                }
                return null;
              },
              onChanged: (_) => _updateFormData(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address (Optional)',
                hintText: 'your.email@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                }
                return null;
              },
              onChanged: (_) => _updateFormData(),
            ),
            const SizedBox(height: 24),

            // Date of Birth
            _buildSectionHeader('Date of Birth'),
            InkWell(
              onTap: _selectDateOfBirth,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select your date of birth',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _selectedDate != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location
            _buildSectionHeader('Location'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter your city',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _updateFormData(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      hintText: 'Enter your state',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _updateFormData(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language Preference
            _buildSectionHeader('Language Preference'),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Preferred Language',
                prefixIcon: Icon(Icons.language_outlined),
              ),
              items: _languages.map((language) {
                return DropdownMenuItem(
                  value: language['code'],
                  child: Text(language['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _updateFormData();
              },
            ),
            const SizedBox(height: 24),

            // Emergency Contact
            _buildSectionHeader('Emergency Contact'),
            TextFormField(
              controller: _emergencyNameController,
              decoration: InputDecoration(
                labelText: 'Emergency Contact Name',
                hintText: 'Name of emergency contact person',
                prefixIcon: Icon(Icons.contact_emergency_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => _updateFormData(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emergencyPhoneController,
              decoration: InputDecoration(
                labelText: 'Emergency Contact Phone',
                hintText: '+91 XXXXX XXXXX',
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) => _updateFormData(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateFormData();
    }
  }

  void _updateFormData() {
    widget.onDataChanged({
      'title': _selectedTitle,
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'dateOfBirth': _selectedDate,
      'city': _cityController.text,
      'state': _stateController.text,
      'language': _selectedLanguage,
      'emergencyContactName': _emergencyNameController.text,
      'emergencyContactPhone': _emergencyPhoneController.text,
    });
  }
}
