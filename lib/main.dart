import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyBiodataApp());
}

class MyBiodataApp extends StatelessWidget {
  const MyBiodataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Biodata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF2F7F6),
      ),
      home: const BiodataPage(),
    );
  }
}

class BiodataPage extends StatefulWidget {
  const BiodataPage({super.key});

  @override
  State<BiodataPage> createState() => _BiodataPageState();
}

class _BiodataPageState extends State<BiodataPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Profile
  final _fullName = TextEditingController();
  final _nickname = TextEditingController();
  final _birthdate = TextEditingController();
  final _age = TextEditingController();
  String? _gender;
  bool _genderError = false;
  String _civilStatus = 'Single';

  // Contact
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();

  // Education
  final _elementary = TextEditingController();
  final _highSchool = TextEditingController();
  final _college = TextEditingController();

  // About me
  final _skills = TextEditingController();
  final _hobbies = TextEditingController();
  final _motto = TextEditingController();

  List<TextEditingController> get _all => [
        _fullName, _nickname, _birthdate, _age, _phone, _email, _address,
        _elementary, _highSchool, _college, _skills, _hobbies, _motto,
      ];

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _genderError = _gender == null);
    if (!formOk || _gender == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('my_biodata').add({
        'fullName': _fullName.text.trim(),
        'nickname': _nickname.text.trim(),
        'birthdate': _birthdate.text.trim(),
        'age': int.tryParse(_age.text.trim()) ?? 0,
        'gender': _gender,
        'civilStatus': _civilStatus,
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'address': _address.text.trim(),
        'education': {
          'elementary': _elementary.text.trim(),
          'highSchool': _highSchool.text.trim(),
          'college': _college.text.trim(),
        },
        'skills': _skills.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'hobbies': _hobbies.text.trim(),
        'motto': _motto.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Saved!'),
          content: const Text('Your biodata is now stored in Firebase.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _clearAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearAll() {
    for (final c in _all) {
      c.clear();
    }
    _formKey.currentState?.reset();
    setState(() {
      _gender = null;
      _genderError = false;
      _civilStatus = 'Single';
    });
  }

  // ---------- UI helpers ----------

  Widget _card(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD5E5E2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    bool required = true,
    TextInputType? type,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FBFA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00796B), Color(0xFF26A69A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Biodata',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fill in your details below',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Profile
                _card('Profile', [
                  _input(_fullName, 'Full Name'),
                  _input(_nickname, 'Nickname', required: false),
                  _input(_birthdate, 'Birthdate'),
                  _input(
                    _age,
                    'Age',
                    type: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) {
                        return 'Numbers only';
                      }
                      return null;
                    },
                  ),
                  const Text('Gender'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Male', 'Female', 'Other']
                        .map(
                          (g) => ChoiceChip(
                            label: Text(g),
                            selected: _gender == g,
                            showCheckmark: false,
                            onSelected: (_) => setState(() {
                              _gender = g;
                              _genderError = false;
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  if (_genderError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Please select a gender',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _civilStatus,
                    decoration: InputDecoration(
                      labelText: 'Civil Status',
                      filled: true,
                      fillColor: const Color(0xFFF8FBFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['Single', 'Married', 'Widowed', 'Separated']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _civilStatus = v!),
                  ),
                ]),

                // Contact
                _card('Contact Details', [
                  _input(_phone, 'Phone Number', type: TextInputType.phone),
                  _input(
                    _email,
                    'Email',
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _input(_address, 'Home Address', maxLines: 2),
                ]),

                // Education
                _card('Education', [
                  _input(_elementary, 'Elementary', required: false),
                  _input(_highSchool, 'High School', required: false),
                  _input(_college, 'College / Course'),
                ]),

                // About me
                _card('About Me', [
                  _input(_skills, 'Skills'),
                  _input(_hobbies, 'Hobbies', required: false),
                  _input(_motto, 'Motto in Life', required: false, maxLines: 2),
                ]),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _clearAll,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_saving ? 'Saving...' : 'Submit Biodata'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}