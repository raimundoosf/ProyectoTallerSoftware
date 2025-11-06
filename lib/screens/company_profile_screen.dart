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

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists && userDoc.data()!.containsKey('companyProfile')) {
      final data = userDoc.data()!['companyProfile'];
      setState(() {
        _companyProfile = CompanyProfile.fromMap(data);
        _companyNameController.text = _companyProfile!.companyName;
        _selectedIndustry = _allIndustries.contains(_companyProfile!.industry)
            ? _companyProfile!.industry
            : null;
        _selectedLocation =
            _allRegions.contains(_companyProfile!.companyLocation)
            ? _companyProfile!.companyLocation
            : null;
        _companyDescriptionController.text =
            _companyProfile!.companyDescription;
        _websiteController.text = _companyProfile!.website;
        _logoUrlController.text = _companyProfile!.logoUrl;
        _certifications = List<String>.from(_companyProfile!.certifications);
      });
    } else {
      setState(() {
        _isEditing = true;
      });
    }
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
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('company_logos')
          .child('${_currentUser!.uid}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      // Handle errors
      return '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_currentUser == null) return;

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

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'companyProfile': newProfile.toMap()}, SetOptions(merge: true));

      setState(() {
        _companyProfile = newProfile;
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil de empresa actualizado con éxito'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar el perfil. Por favor, intenta de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Empresa'),
        actions: [
          if (!_isEditing && _companyProfile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _currentUser == null
          ? const Center(child: Text('No has iniciado sesión.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing ? _buildEditForm() : _buildProfileView(),
            ),
    );
  }

  Widget _buildProfileView() {
    if (_companyProfile == null) {
      return const Center(
        child: Text('Aún no has creado tu perfil de empresa.'),
      );
    }
    return ListView(
      children: [
        if (_companyProfile!.logoUrl.isNotEmpty)
          Image.network(_companyProfile!.logoUrl, height: 150),
        _buildInfoTile('Nombre de la Empresa', _companyProfile!.companyName),
        _buildInfoTile('Industria', _companyProfile!.industry),
        _buildInfoTile('Ubicación', _companyProfile!.companyLocation),
        _buildInfoTile('Descripción', _companyProfile!.companyDescription),
        _buildInfoTile('Sitio Web', _companyProfile!.website),
        const SizedBox(height: 10),
        const Text(
          'Certificaciones:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ..._companyProfile!.certifications
            .map((cert) => Text('- $cert'))
            .toList(),
      ],
    );
  }

  Widget _buildInfoTile(String title, String? subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle ?? 'No especificado'),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          GestureDetector(
            onTap: _pickLogo,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _logoImage != null
                  ? FileImage(_logoImage!)
                  : (_companyProfile?.logoUrl.isNotEmpty ?? false)
                  ? NetworkImage(_companyProfile!.logoUrl)
                  : null,
              child:
                  _logoImage == null &&
                      !(_companyProfile?.logoUrl.isNotEmpty ?? false)
                  ? const Icon(Icons.camera_alt, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _logoUrlController,
            decoration: const InputDecoration(
              labelText: 'O ingresa la URL del logo',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _logoImage = null;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Empresa',
            ),
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          ),
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            hint: const Text('Industria'),
            items: _allIndustries.map((String industry) {
              return DropdownMenuItem<String>(
                value: industry,
                child: Text(industry),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedIndustry = newValue;
              });
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            hint: const Text('Ubicación'),
            items: _allRegions.map((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          TextFormField(
            controller: _companyDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción de la Empresa',
            ),
            maxLines: 3,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          ),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Sitio Web'),
            validator: (value) {
              if (value!.isNotEmpty && !Uri.parse(value).isAbsolute) {
                return 'Ingrese una URL válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildCertificationsManager(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Guardar'),
              ),
              if (_companyProfile != null)
                TextButton(
                  onPressed: () {
                    _fetchCompanyData();
                    setState(() => _isEditing = false);
                  },
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certificaciones',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._certifications
            .map(
              (cert) => ListTile(
                title: Text(cert),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _certifications.remove(cert);
                    });
                  },
                ),
              ),
            )
            .toList(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _certificationController,
                decoration: const InputDecoration(
                  labelText: 'Añadir certificación',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
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
      ],
    );
  }
}
