import 'package:flutter/material.dart';
import 'user_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  
  String _selectedBloodType = UserStore.instance.bloodType.isEmpty ? 'O+' : UserStore.instance.bloodType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserStore.instance.name);
    _phoneController = TextEditingController(text: UserStore.instance.phone);
    _dobController = TextEditingController(text: UserStore.instance.dateOfBirth);
    _weightController = TextEditingController(text: UserStore.instance.weight.toString());
    _ageController = TextEditingController(text: UserStore.instance.age.toString());
    _allergiesController = TextEditingController(text: UserStore.instance.allergies);
    _conditionsController = TextEditingController(text: UserStore.instance.chronicConditions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      UserStore.instance.name = _nameController.text.trim();
      UserStore.instance.phone = _phoneController.text.trim();
      UserStore.instance.dateOfBirth = _dobController.text.trim();
      UserStore.instance.weight = double.tryParse(_weightController.text) ?? UserStore.instance.weight;
      UserStore.instance.age = int.tryParse(_ageController.text) ?? UserStore.instance.age;
      UserStore.instance.bloodType = _selectedBloodType;
      UserStore.instance.allergies = _allergiesController.text.trim();
      UserStore.instance.chronicConditions = _conditionsController.text.trim();
      
      await UserStore.instance.saveToRemote();
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile', 
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0796DE),
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Center(child: SizedBox(width: 20, height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Basic Info'),
              _buildField('Full Name', _nameController, Icons.person_outline),
              _buildField('Phone Number', _phoneController, Icons.phone_outlined, 
                keyboardType: TextInputType.phone),
              _buildField('Date of Birth', _dobController, Icons.cake_outlined),
              
              const SizedBox(height: 24),
              _buildSectionLabel('Health Stats'),
              Row(children: [
                Expanded(child: _buildField('Age', _ageController, Icons.calendar_today_outlined, 
                  keyboardType: TextInputType.number)),
                const SizedBox(width: 15),
                Expanded(child: _buildField('Weight (kg)', _weightController, Icons.monitor_weight_outlined, 
                  keyboardType: TextInputType.number)),
              ]),
              
              const SizedBox(height: 10),
              const Text('Blood Type', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF919191))),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBloodType,
                    isExpanded: true,
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _selectedBloodType = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionLabel('Medical Context'),
              _buildField('Allergies', _allergiesController, Icons.warning_amber_outlined, maxLines: 2),
              _buildField('Chronic Conditions', _conditionsController, Icons.medical_services_outlined, maxLines: 2),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0796DE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0796DE), size: 20),
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
