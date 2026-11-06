import 'package:flutter/material.dart';
import '../models/app_user.dart'; 
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final Function(String updatedName) onSave;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con el nombre actual del usuario
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Llamamos a la función de guardado y regresamos a la pantalla anterior
      widget.onSave(_nameController.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandHeader(),
                const SizedBox(height: 16),
                const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Actualiza tu información personal habilitada',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                const SizedBox(height: 24),
                
                // Campo de Nombre editable
                const Text(
                  'Nombre completo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu nombre',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.orange),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un nombre válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botón de Guardar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}