import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  UserProfile? _userProfile;

  final _nameController = TextEditingController();
  List<String> _interests = [];
  String? _location;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final _photoUrlController = TextEditingController();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  final List<String> _allInterests = [
    'Tecnología',
    'Hogar',
    'Moda',
    'Deportes',
    'Salud y Belleza',
    'Vehículos',
    'Inmuebles',
    'Servicios Profesionales',
    'Comida y Bebidas',
    'Viajes y Turismo',
    'Educación',
    'Entretenimiento',
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        // Handle legacy data structure
        if (data.containsKey('name')) {
          _userProfile = UserProfile.fromMap(data);
        } else {
          _userProfile = null;
        }

        if (_userProfile != null) {
          _nameController.text = _userProfile!.name;
          _interests = List<String>.from(_userProfile!.interests);
          _photoUrlController.text = _userProfile!.photoUrl ?? '';

          if (_userProfile!.location != null &&
              _allRegions.contains(_userProfile!.location)) {
            _location = _userProfile!.location;
          } else {
            _location = null;
          }
        } else {
          _isEditing = true;
        }
      });
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _photoUrlController.clear();
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    if (_currentUser == null) return '';
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('${_currentUser!.uid}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_currentUser == null) return;

    String? photoUrl = _userProfile?.photoUrl;
    if (_profileImage != null) {
      photoUrl = await _uploadImage(_profileImage!);
    } else if (_photoUrlController.text.isNotEmpty) {
      photoUrl = _photoUrlController.text;
    }

    final updatedProfile = UserProfile(
      name: _nameController.text,
      interests: _interests,
      location: _location,
      photoUrl: photoUrl,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      setState(() {
        _userProfile = updatedProfile;
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
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

  void _showInterestsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona tus intereses'),
          content: SingleChildScrollView(
            child: Column(
              children: _allInterests.map((interest) {
                return CheckboxListTile(
                  title: Text(interest),
                  value: _interests.contains(interest),
                  onChanged: (isSelected) {
                    setState(() {
                      if (isSelected == true) {
                        _interests.add(interest);
                      } else {
                        _interests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _isEditing ? _buildEditForm() : _buildProfileView(),
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    if (_userProfile == null) {
      return const Center(child: Text('Aún no has creado tu perfil.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_userProfile?.photoUrl != null &&
            _userProfile!.photoUrl!.isNotEmpty)
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_userProfile!.photoUrl!),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Nombre: ${_userProfile!.name}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Categorías de Interés: ${_userProfile!.interests.join(', ')}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Ubicación: ${_userProfile!.location ?? 'No especificada'}',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return ListView(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_userProfile?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(_userProfile!.photoUrl!)
                    : null,
                child:
                    _profileImage == null &&
                        !(_userProfile?.photoUrl?.isNotEmpty ?? false)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _photoUrlController,
          decoration: const InputDecoration(
            labelText: 'O ingresa la URL de la imagen',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _profileImage = null;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, ingresa tu nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showInterestsDialog,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Categorías de Interés',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _interests.isNotEmpty
                  ? _interests.join(', ')
                  : 'No hay intereses seleccionados',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _location,
          onChanged: (newValue) {
            setState(() {
              _location = newValue;
            });
          },
          items: _allRegions.map((region) {
            return DropdownMenuItem<String>(value: region, child: Text(region));
          }).toList(),
          decoration: const InputDecoration(
            labelText: 'Ubicación',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveProfile,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}
