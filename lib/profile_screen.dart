import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String _name = '';
  List<String> _interests = [];
  String? _location;

  final _nameController = TextEditingController();

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
        _name = data['name'] ?? '';

        // Handle legacy string interests and new list interests
        final interestsData = data['interests'];
        if (interestsData is String) {
          _interests = interestsData
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (interestsData is List) {
          _interests = List<String>.from(interestsData);
        } else {
          _interests = [];
        }

        final String? currentLocation = data['location'];
        if (currentLocation != null && _allRegions.contains(currentLocation)) {
          _location = currentLocation;
        } else {
          _location = null; // Set to null if not in the list
        }

        _nameController.text = _name;
      });
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'name': _nameController.text,
            'interests': _interests,
            'location': _location,
          }, SetOptions(merge: true));

      setState(() {
        _name = _nameController.text;
        _isEditing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo guardar el perfil. Por favor, intenta de nuevo.')));
    }
  }

  void _showInterestsDialog() {
    final tempSelectedInterests = List<String>.from(_interests);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona tus intereses'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _allInterests.map((interest) {
                    return CheckboxListTile(
                      title: Text(interest),
                      value: tempSelectedInterests.contains(interest),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedInterests.add(interest);
                          } else {
                            tempSelectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _interests = tempSelectedInterests;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
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
        title: const Text('Mi Perfil'),
        actions: [
          if (!_isEditing)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nombre: $_name', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          'Categorías de Interés: ${_interests.join(', ')}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          'Ubicación: ${_location ?? 'No especificada'}',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Categorías de Interés'),
            subtitle: Text(
              _interests.isEmpty ? 'No seleccionadas' : _interests.join(', '),
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: _showInterestsDialog,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _location,
            hint: const Text('Selecciona tu ubicación'),
            isExpanded: true,
            items: _allRegions.map((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _location = newValue;
              });
            },
            validator: (value) => value == null ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Guardar Cambios'),
              ),
              TextButton(
                onPressed: () async {
                  await _fetchUserData(); // Re-fetch to discard changes
                  setState(() {
                    _isEditing = false;
                  });
                },
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
