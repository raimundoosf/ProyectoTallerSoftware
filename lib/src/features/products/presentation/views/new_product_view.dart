// This file intentionally suppresses the `use_build_context_synchronously` lint
// in a few dialog helper functions where we pass dialog-owned BuildContexts
// across awaits in a controlled way (the dialog's builder context `ctx` is
// used, not the State's `context`). See individual ignores around the calls.
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/new_product_viewmodel.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/core/ui/app_snackbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/src/core/config/certifications.dart';

class NewProductView extends StatefulWidget {
  const NewProductView({super.key, this.onCancel, this.onPublishSuccess});

  final VoidCallback? onCancel;
  final VoidCallback? onPublishSuccess;

  @override
  State<NewProductView> createState() => _NewProductViewState();
}

class _NewProductViewState extends State<NewProductView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // If company id is available, set brand link in the VM
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<NewProductViewModel>();
        vm.setBrandLink('/businesses/$userId');
        // load the company profile so we can display the company name
        try {
          context.read<CompanyProfileViewModel>().loadCompanyProfile(userId);
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewProductViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(vm.isEditing ? 'Editar Publicación' : 'Nueva Publicación'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                // Mostrar diálogo de confirmación si hay datos en el formulario
                final hasData =
                    vm.name.isNotEmpty ||
                    vm.description.isNotEmpty ||
                    vm.localImagePaths.isNotEmpty;

                if (hasData) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('¿Cancelar publicación?'),
                      content: const Text(
                        'Se perderán todos los datos ingresados.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Continuar editando'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;
                }

                // Limpiar el formulario antes de cancelar
                vm.resetForm();
                // Si hay un callback onCancel, usarlo (desde MainScaffold)
                if (widget.onCancel != null) {
                  widget.onCancel!();
                } else {
                  // Fallback: intentar navegar con GoRouter
                  if (context.mounted) context.go('/');
                }
              },
              tooltip: 'Cancelar',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tipo: Producto / Servicio (dropdown)
                  DropdownButtonFormField<String>(
                    initialValue: vm.isService ? 'Servicio' : 'Producto',
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Producto',
                        child: Text('Producto'),
                      ),
                      DropdownMenuItem(
                        value: 'Servicio',
                        child: Text('Servicio'),
                      ),
                    ],
                    onChanged: (v) {
                      vm.setIsService(v == 'Servicio');
                    },
                  ),
                  const SizedBox(height: 12),
                  if (vm.isService) ...[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Categoría del servicio',
                        errorText: vm.fieldErrors['serviceCategory'],
                      ),
                      onChanged: (v) => vm.serviceCategory = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Duración estimada (ej: 30 min) (opcional)',
                        errorText: vm.fieldErrors['serviceDuration'],
                      ),
                      onChanged: (v) => vm.serviceDuration = v,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      errorText: vm.fieldErrors['name'],
                    ),
                    onChanged: (v) => vm.name = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      errorText: vm.fieldErrors['description'],
                    ),
                    maxLines: 3,
                    onChanged: (v) => vm.description = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      prefixText: '\$',
                      suffixText: ' CLP',
                      errorText: vm.fieldErrors['price'],
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => vm.price = double.tryParse(v) ?? 0.0,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  Text(
                    'Marca (no editable)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Builder(
                    builder: (bctx) {
                      final cpvm = bctx.read<CompanyProfileViewModel>();
                      final name = cpvm.companyProfile?.companyName;
                      return Text(
                        name ?? vm.brandLink,
                        style: const TextStyle(color: Colors.blueGrey),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Certificaciones disponibles',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (bctx) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: availableCertifications.map((cert) {
                          final selected = bctx
                              .read<NewProductViewModel>()
                              .hasCertification(cert);
                          return ChoiceChip(
                            label: Text(cert),
                            selected: selected,
                            onSelected: (_) => bctx
                                .read<NewProductViewModel>()
                                .toggleCertification(cert),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Imágenes (mínimo 1, máximo 3)'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              // Show existing images (when editing)
                              ...vm.existingImageUrls.mapIndexed((i, url) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        showDialog<void>(
                                          context: context,
                                          builder: (dctx) => AlertDialog(
                                            title: const Text('Vista previa'),
                                            content: Image.network(url),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dctx).pop(),
                                                child: const Text('Cerrar'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        url,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.cloud,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              // Show newly picked images
                              ...vm.localImagePaths.mapIndexed((i, path) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (dctx) => AlertDialog(
                                                title: const Text(
                                                  'Vista previa',
                                                ),
                                                content: Image.file(File(path)),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dctx,
                                                        ).pop(false),
                                                    child: const Text('Cerrar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          dctx,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                        if (shouldDelete == true) {
                                          vm.removeLocalImageAt(i);
                                        }
                                      },
                                      child: Image.file(
                                        File(path),
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            vm.removeLocalImageAt(i),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if ((vm.localImagePaths.length + vm.existingImageUrls.length) < vm.maxImageCount)
                                TextButton.icon(
                                  onPressed: vm.isPicking ? null : vm.pickImage,
                                  icon: vm.isPicking
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add_a_photo),
                                  label: const Text('Agregar'),
                                ),
                            ],
                          ),
                          if (vm.fieldErrors['images'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                vm.fieldErrors['images'] ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text('Trazabilidad (marcar orígenes)'),
                      subtitle: Text(
                        '${vm.traceability.length} puntos añadidos',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _showAddTracePointDialog(context, vm);
                        },
                        child: const Text('Agregar punto'),
                      ),
                    ),
                  ),
                  if (vm.traceability.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: vm.traceability.mapIndexed((i, t) {
                          final mp = t['mediaPath'] as String?;
                          final description =
                              (t['description'] as String?) ?? '';
                          final lat =
                              (t['lat'] as double?) ??
                              (t['lat'] as num?)?.toDouble() ??
                              0.0;
                          final lon =
                              (t['lon'] as double?) ??
                              (t['lon'] as num?)?.toDouble() ??
                              0.0;
                          return Dismissible(
                            key: ValueKey(t.hashCode),
                            direction: DismissDirection.endToStart,
                            // background must be non-null when secondaryBackground is
                            // provided (Dismissible assertion). Provide a transparent
                            // background for the non-used direction.
                            background: Container(color: Colors.transparent),
                            secondaryBackground: Container(
                              color: Colors.red.shade600,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              vm.removeTracePointAt(i);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: mp != null && mp.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.file(
                                          File(mp),
                                          width: 72,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.map_outlined),
                                title: Text(
                                  description.isNotEmpty
                                      ? description
                                      : 'Sin descripción',
                                ),
                                subtitle: Text(
                                  'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.build_circle_outlined),
                      title: const Text('Reparación (locales)'),
                      subtitle: Text(
                        '${vm.repairLocations.length} locales añadidos',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _showAddRepairDialog(context, vm);
                        },
                        child: const Text('Agregar'),
                      ),
                    ),
                  ),
                  if (vm.repairLocations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: vm.repairLocations.mapIndexed((i, r) {
                          final address = (r['address'] as String?) ?? '';
                          final lat =
                              (r['lat'] as double?) ??
                              (r['lat'] as num?)?.toDouble() ??
                              0.0;
                          final lon =
                              (r['lon'] as double?) ??
                              (r['lon'] as num?)?.toDouble() ??
                              0.0;
                          return Dismissible(
                            key: ValueKey(r.hashCode),
                            direction: DismissDirection.endToStart,
                            background: Container(color: Colors.transparent),
                            secondaryBackground: Container(
                              color: Colors.red.shade600,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              vm.removeRepairLocationAt(i);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  address.isNotEmpty ? address : 'Sin nombre',
                                ),
                                subtitle: Text(
                                  'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            final userId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (userId == null) {
                              context.showAppSnackBar(
                                'Usuario no autenticado',
                                success: false,
                              );
                              return;
                            }
                            final router = GoRouter.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final successSnack = makeAppSnackBar(
                              context,
                              'Publicado con éxito',
                              success: true,
                            );
                            final errorMessage =
                                vm.error ?? 'Fallo al publicar';
                            final errorSnack = makeAppSnackBar(
                              context,
                              errorMessage,
                              success: false,
                            );

                            final success = await vm.publish(userId);
                            if (!mounted) return;
                            if (success) {
                              messenger.showSnackBar(successSnack);
                              // Si hay callback onPublishSuccess, usarlo (desde MainScaffold)
                              if (widget.onPublishSuccess != null) {
                                widget.onPublishSuccess!();
                              } else {
                                // Fallback: navegar con GoRouter
                                router.go('/company-profile');
                              }
                            } else {
                              messenger.showSnackBar(errorSnack);
                            }
                          },
                          child: Text(vm.isEditing ? 'Guardar Cambios' : 'Publicar'),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddTracePointDialog(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
    String name = '';
    XFile? media;
    LatLng? pickedLoc;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir punto de trazabilidad'),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final loc = await _showMapPicker(ctx, initial: pickedLoc);
                    if (loc != null) setState(() => pickedLoc = loc);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    pickedLoc == null
                        ? 'Seleccionar ubicación'
                        : 'Ubicación seleccionada',
                  ),
                ),
                const SizedBox(height: 8),
                // Wrap the attach button in a Consumer so it reacts to vm.isPicking
                Consumer<NewProductViewModel>(
                  builder: (cctx, model, child) {
                    return TextButton.icon(
                      onPressed: model.isPicking
                          ? null
                          : () async {
                              final picked = await model.pickImageFile();
                              if (picked != null) {
                                setState(() => media = picked);
                              }
                            },
                      icon: model.isPicking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.attachment),
                      label: const Text('Adjuntar imagen/video (opc.)'),
                    );
                  },
                ),
                if (media != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(File(media!.path), fit: BoxFit.cover),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final point = {
                'description': name,
                'lat': pickedLoc?.latitude ?? 0.0,
                'lon': pickedLoc?.longitude ?? 0.0,
                'mediaPath': media?.path,
              };
              vm.addTracePoint(point);
              Navigator.of(ctx).pop();
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRepairDialog(
    BuildContext context,
    NewProductViewModel vm,
  ) async {
    String address = '';
    LatLng? pickedLoc;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir local de reparación'),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre/Descripción',
                  ),
                  onChanged: (v) => address = v,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final loc = await _showMapPicker(ctx, initial: pickedLoc);
                    if (loc != null) setState(() => pickedLoc = loc);
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: Text(
                    pickedLoc == null
                        ? 'Seleccionar ubicación'
                        : 'Ubicación seleccionada',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              vm.addRepairLocation({
                'address': address,
                'lat': pickedLoc?.latitude ?? 0.0,
                'lon': pickedLoc?.longitude ?? 0.0,
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<LatLng?> _showMapPicker(BuildContext ctx, {LatLng? initial}) async {
    // Ask for location permission before showing the map. If granted,
    // enable the myLocation layer; otherwise continue without it.
    var status = await Permission.locationWhenInUse.status;
    bool hasLocation = status.isGranted;
    if (!hasLocation) {
      final req = await Permission.locationWhenInUse.request();
      hasLocation = req.isGranted;
      // If permanently denied, offer to open app settings.
      if (req.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: ctx,
          builder: (d) => AlertDialog(
            title: const Text('Permiso denegado'),
            content: const Text(
              'El permiso de ubicación fue denegado permanentemente. Para centrar el mapa en tu ubicación, abre la configuración y habilita el permiso.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(d).pop(false),
                child: const Text('Continuar sin ubicación'),
              ),
              TextButton(
                onPressed: () => Navigator.of(d).pop(true),
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
        );
        if (open == true) {
          await openAppSettings();
          return null;
        }
        // else continue without location permission
        hasLocation = false;
      }
    }

    // initial selected point
    LatLng selected = initial ?? const LatLng(0, 0);

    // If we have permission try to get the current device location to center the map
    if (hasLocation) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        selected = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        // ignore and proceed with initial
      }
    }

    // Show the map picker dialog
    return await showDialog<LatLng>(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Selecciona ubicación'),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: StatefulBuilder(
              builder: (c, setState) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: selected,
                      zoom: 12,
                    ),
                    myLocationEnabled: hasLocation,
                    onMapCreated: (controller) async {
                      if (hasLocation) {
                        try {
                          await controller.animateCamera(
                            CameraUpdate.newLatLngZoom(selected, 16),
                          );
                        } catch (_) {}
                      }
                    },
                    onTap: (latlng) {
                      setState(() => selected = latlng);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('picked'),
                        position: selected,
                      ),
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(selected),
              child: const Text('Seleccionar'),
            ),
          ],
        );
      },
    );
  }
}

// small helper extension to map with index
extension _IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
