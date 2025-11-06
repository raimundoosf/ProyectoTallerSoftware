import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/company_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  CompanyProfile? _companyProfile;

  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  File? _logoImage;
  final ImagePicker _picker = ImagePicker();
  List<String> _certifications = [];
  final _certificationController = TextEditingController();
  final _logoUrlController = TextEditingController();

  String? _selectedIndustry;
  String? _selectedLocation;

  final List<String> _allIndustries = [
    'Tecnología',
    'Salud',
    'Educación',
    'Finanzas',
    'Retail',
    'Otra',
  ];
  final List<String> _allRegions = [
    'Arica y Parinacota',
    'Tarapacá',
    'Antofagasta',
    'Atacama',
    'Coquimbo',
    'Valparaíso',
    'Metropolitana de Santiago',
    'O\'Higgins',
    'Maule',
    'Ñuble',
    'Biobío',
    'La Araucanía',
    'Los Ríos',
    'Los Lagos',
    'Aysén',
    'Magallanes y de la Antártica Chilena',
  ];

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('companyProfile')) {
        final data = userDoc.data()!['companyProfile'];
        _companyProfile = CompanyProfile.fromMap(data);
        _updateControllersFromProfile();
      } else {
        setState(() {
          _isEditing = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el perfil: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateControllersFromProfile() {
    if (_companyProfile == null) return;
    _companyNameController.text = _companyProfile!.companyName;
    _selectedIndustry = _allIndustries.contains(_companyProfile!.industry)
        ? _companyProfile!.industry
        : null;
    _selectedLocation = _allRegions.contains(_companyProfile!.companyLocation)
        ? _companyProfile!.companyLocation
        : null;
    _companyDescriptionController.text = _companyProfile!.companyDescription;
    _websiteController.text = _companyProfile!.website;
    _logoUrlController.text = _companyProfile!.logoUrl;
    _certifications = List<String>.from(_companyProfile!.certifications);
  }

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
        _logoUrlController.clear();
      });
    }
  }

  Future<String> _uploadLogo(File image) async {
    if (_currentUser == null) return '';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('company_logos')
        .child('${_currentUser!.uid}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String logoUrl = _companyProfile?.logoUrl ?? '';
      if (_logoImage != null) {
        logoUrl = await _uploadLogo(_logoImage!);
      } else if (_logoUrlController.text.isNotEmpty) {
        logoUrl = _logoUrlController.text;
      }

      final newProfile = CompanyProfile(
        companyName: _companyNameController.text,
        industry: _selectedIndustry ?? '',
        companyLocation: _selectedLocation ?? '',
        companyDescription: _companyDescriptionController.text,
        website: _websiteController.text,
        logoUrl: logoUrl,
        certifications: _certifications,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'companyProfile': newProfile.toMap()}, SetOptions(merge: true));

      setState(() {
        _companyProfile = newProfile;
        _isEditing = false;
        _logoImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil de empresa actualizado con éxito'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el perfil.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Perfil de Empresa' : 'Perfil de Empresa',
        ),
        leading: _isEditing && _companyProfile != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isEditing = false;
                  _updateControllersFromProfile(); // Revert changes
                }),
              )
            : null,
      ),
      body: _isLoading && !_isEditing
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
          ? _buildEditForm()
          : _buildProfileView(),
      floatingActionButton: !_isEditing && _companyProfile != null
          ? FloatingActionButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildProfileView() {
    if (_companyProfile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aún no has creado tu perfil de empresa.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _isEditing = true),
                child: const Text('Crear Perfil de Empresa'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _companyProfile!.logoUrl.isNotEmpty
                  ? NetworkImage(_companyProfile!.logoUrl)
                  : null,
              child: _companyProfile!.logoUrl.isEmpty
                  ? const Icon(Icons.business, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _companyProfile!.companyName,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  Icons.business_center_outlined,
                  'Industria',
                  _companyProfile!.industry,
                ),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  'Ubicación',
                  _companyProfile!.companyLocation,
                ),
                _buildInfoTile(
                  Icons.link_outlined,
                  'Sitio Web',
                  _companyProfile!.website,
                ),
                _buildInfoTile(
                  Icons.description_outlined,
                  'Descripción',
                  _companyProfile!.companyDescription,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_companyProfile!.certifications.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: const Text('Certificaciones'),
                subtitle: Text(_companyProfile!.certifications.join('\n')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle != null && subtitle.isNotEmpty ? subtitle : 'No especificado',
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _logoImage != null
                      ? FileImage(_logoImage!)
                      : (_companyProfile?.logoUrl.isNotEmpty ?? false)
                      ? NetworkImage(_companyProfile!.logoUrl)
                      : null,
                  child:
                      _logoImage == null &&
                          !(_companyProfile?.logoUrl.isNotEmpty ?? false)
                      ? const Icon(Icons.business, size: 60)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickLogo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _logoUrlController,
            decoration: const InputDecoration(
              labelText: 'O ingresa la URL del logo',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) setState(() => _logoImage = null);
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Empresa',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            decoration: const InputDecoration(
              labelText: 'Industria',
              prefixIcon: Icon(Icons.business_center_outlined),
            ),
            items: _allIndustries
                .map(
                  (String industry) => DropdownMenuItem<String>(
                    value: industry,
                    child: Text(industry),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) =>
                setState(() => _selectedIndustry = newValue),
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedLocation,
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: _allRegions
                .map(
                  (String region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) =>
                setState(() => _selectedLocation = newValue),
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.description_outlined),
            ),
            maxLines: 3,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Sitio Web',
              prefixIcon: Icon(Icons.link_outlined),
            ),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value!.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                return 'Ingrese una URL válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildCertificationsManager(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsManager() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.verified_outlined),
              title: Text('Certificaciones'),
            ),
            ..._certifications.map(
              (cert) => ListTile(
                title: Text(cert),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _certifications.remove(cert)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _certificationController,
                      decoration: const InputDecoration(
                        labelText: 'Añadir certificación',
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _certifications.add(value);
                            _certificationController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      if (_certificationController.text.isNotEmpty) {
                        setState(() {
                          _certifications.add(_certificationController.text);
                          _certificationController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
