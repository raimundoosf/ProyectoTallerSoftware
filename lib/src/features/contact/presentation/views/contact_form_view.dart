import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/src/features/contact/presentation/viewmodels/contact_viewmodel.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';

class ContactFormView extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String? productId;
  final String? productName;

  const ContactFormView({
    super.key,
    required this.companyId,
    required this.companyName,
    this.productId,
    this.productName,
  });

  @override
  State<ContactFormView> createState() => _ContactFormViewState();
}

class _ContactFormViewState extends State<ContactFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _messageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ContactViewModel>();
      vm.resetForm();

      // Pre-llenar el asunto si hay un producto asociado
      if (widget.productName != null) {
        final defaultSubject = 'Consulta sobre: ${widget.productName}';
        vm.setSubject(defaultSubject);
        _subjectController.text = defaultSubject;
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final vm = context.read<ContactViewModel>();

    // Validar el formulario
    if (!vm.validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Por favor completa todos los campos requeridos'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Obtener el email de la empresa
    final companyVm = context.read<CompanyProfileViewModel>();
    final companyEmail = companyVm.companyProfile?.email;

    if (companyEmail == null || companyEmail.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'La empresa no tiene un correo electrónico registrado',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Construir el cuerpo del email
    final subject = Uri.encodeComponent(vm.subject);
    String body = vm.message;

    // Agregar información de contexto al mensaje
    if (widget.productName != null) {
      body = 'Producto: ${widget.productName}\n\n$body';
    }
    body = '$body\n\n---\nEmpresa: ${widget.companyName}';

    final encodedBody = Uri.encodeComponent(body);

    // Crear el URI de mailto
    final emailUri = Uri.parse(
      'mailto:$companyEmail?subject=$subject&body=$encodedBody',
    );

    try {
      // Intentar abrir el cliente de correo con mode: LaunchMode.externalApplication
      bool launched = false;
      try {
        launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        // Si falla con externalApplication, intentar sin especificar mode
        launched = await launchUrl(emailUri);
      }

      if (launched) {
        if (!context.mounted) return;
        // Cerrar la vista después de abrir el cliente de correo
        Navigator.of(context).pop();
      } else {
        // Si no se puede abrir, mostrar diálogo con opciones
        if (!context.mounted) return;
        _showEmailOptionsDialog(context, companyEmail, vm.subject, body);
      }
    } catch (e) {
      if (!context.mounted) return;
      // Mostrar diálogo con opciones alternativas
      _showEmailOptionsDialog(context, companyEmail, vm.subject, body);
    }
  }

  void _showEmailOptionsDialog(
    BuildContext context,
    String companyEmail,
    String subject,
    String body,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactar Empresa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se pudo abrir el cliente de correo automáticamente.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text('Puedes contactar a la empresa mediante:'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    companyEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Copia esta información para tu correo:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asunto: $subject',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text('Mensaje:\n$body', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contactar Empresa'), elevation: 0),
      body: Consumer<ContactViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información de la empresa
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contactando a:',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      widget.companyName,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (widget.productName != null) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: theme.colorScheme.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sobre:',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        widget.productName!,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Asunto
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Asunto',
                      hintText: 'Escribe el asunto de tu consulta',
                      prefixIcon: const Icon(Icons.subject),
                      errorText: vm.fieldErrors['subject'],
                      helperText: 'Mínimo 5 caracteres',
                    ),
                    onChanged: (v) => vm.setSubject(v),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // Mensaje
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Mensaje',
                      hintText: 'Escribe tu consulta o mensaje',
                      prefixIcon: const Icon(Icons.message),
                      errorText: vm.fieldErrors['message'],
                      helperText: 'Mínimo 20 caracteres',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) => vm.setMessage(v),
                    maxLines: 8,
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 24),

                  // Info adicional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Se abrirá tu aplicación de correo (Mail, Gmail, Outlook) con el mensaje pre-llenado para enviar a la empresa.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón enviar
                  FilledButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () => _handleSubmit(context),
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      vm.isLoading ? 'Enviando...' : 'Enviar Mensaje',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
