import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.user});

  /// null = add mode, non-null = edit mode
  final UserModel? user;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _pinCtrl;
  late UserRole _role;
  bool _pinVisible = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _pinCtrl = TextEditingController(text: widget.user?.pin ?? '');
    _role = widget.user?.role ?? UserRole.inventory;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:     return Icons.admin_panel_settings_rounded;
      case UserRole.inventory: return Icons.inventory_2_rounded;
      case UserRole.ziswaf:    return Icons.volunteer_activism_rounded;
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:     return 'Admin';
      case UserRole.inventory: return 'Inventory';
      case UserRole.ziswaf:    return 'ZISWAF';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      name: _nameCtrl.text.trim(),
      role: _role,
      pin: _pinCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                const SizedBox(height: 28),
                _buildNameField(colorScheme),
                const SizedBox(height: 16),
                _buildRoleSelector(colorScheme),
                const SizedBox(height: 16),
                _buildPinField(colorScheme),
                const SizedBox(height: 28),
                _buildActions(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          _isEdit ? 'Edit User' : 'Add New User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildNameField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        colorScheme,
        label: 'Full Name',
        icon: Icons.person_outline_rounded,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Name is required';
        if (v.trim().length < 3) return 'Name must be at least 3 characters';
        return null;
      },
    );
  }

  Widget _buildRoleSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UserRole.values.map((role) {
            final selected = _role == role;
            return GestureDetector(
              onTap: () => setState(() => _role = role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _roleIcon(role),
                      size: 18,
                      color: selected ? Colors.white : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _roleLabel(role),
                      style: TextStyle(
                        color: selected ? Colors.white : colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPinField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _pinCtrl,
      obscureText: !_pinVisible,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: _inputDecoration(
        colorScheme,
        label: 'PIN (6 digits)',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        counterText: '',
        suffixIcon: IconButton(
          icon: Icon(
            _pinVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
          onPressed: () => setState(() => _pinVisible = !_pinVisible),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'PIN is required';
        if (v.trim().length != 6) return 'PIN must be exactly 6 digits';
        if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) return 'PIN must be digits only';
        return null;
      },
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_isEdit ? 'Save Changes' : 'Add User'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme colorScheme, {
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon:
          Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
      filled: true,
      fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    );
  }
}
