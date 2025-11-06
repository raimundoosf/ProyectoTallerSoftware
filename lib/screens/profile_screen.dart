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
  bool _isLoading = false;
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
    setState(() => _isLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userProfile = UserProfile.fromMap(data);
        _nameController.text = _userProfile!.name;
        _interests = List<String>.from(_userProfile!.interests);
        _photoUrlController.text = _userProfile!.photoUrl ?? '';
        _location = _allRegions.contains(_userProfile!.location)
            ? _userProfile!.location
            : null;
      } else {
        _isEditing = true;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_photos')
        .child('${_currentUser!.uid}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      setState(() {
        _userProfile = updatedProfile;
        _isEditing = false;
        _profileImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el perfil.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInterestsDialog() {
    final tempInterests = List<String>.from(_interests);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona tus intereses'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _allInterests.map((interest) {
                    return CheckboxListTile(
                      title: Text(interest),
                      value: tempInterests.contains(interest),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            tempInterests.add(interest);
                          } else {
                            tempInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _interests = tempInterests);
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Perfil' : 'Mi Perfil'),
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isEditing = false;
                  _fetchUserData(); // Revert changes
                }),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
          ? _buildEditForm()
          : _buildProfileView(),
      floatingActionButton: !_isEditing
          ? FloatingActionButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildProfileView() {
    if (_userProfile == null) {
      return const Center(child: Text('Aún no has creado tu perfil.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _userProfile?.photoUrl != null &&
                      _userProfile!.photoUrl!.isNotEmpty
                  ? NetworkImage(_userProfile!.photoUrl!)
                  : null,
              child:
                  _userProfile?.photoUrl == null ||
                      _userProfile!.photoUrl!.isEmpty
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nombre'),
                  subtitle: Text(_userProfile!.name),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Ubicación'),
                  subtitle: Text(_userProfile!.location ?? 'No especificada'),
                ),
                ListTile(
                  leading: const Icon(Icons.interests_outlined),
                  title: const Text('Intereses'),
                  subtitle: Text(
                    _userProfile!.interests.isNotEmpty
                        ? _userProfile!.interests.join(', ')
                        : 'No especificados',
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_userProfile?.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(_userProfile!.photoUrl!)
                      : null,
                  child:
                      _profileImage == null &&
                          !(_userProfile?.photoUrl?.isNotEmpty ?? false)
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
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
            ),
            onChanged: (value) {
              if (value.isNotEmpty) setState(() => _profileImage = null);
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, ingresa tu nombre'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _location,
            onChanged: (newValue) => setState(() => _location = newValue),
            items: _allRegions
                .map(
                  (region) => DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showInterestsDialog,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Categorías de Interés',
                prefixIcon: Icon(Icons.interests_outlined),
              ),
              child: Text(
                _interests.isNotEmpty
                    ? _interests.join(', ')
                    : 'Seleccionar intereses',
              ),
            ),
          ),
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
}
