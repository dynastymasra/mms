import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';
import '../viewmodel/user_management_viewmodel.dart';
import 'settings/item_type_tab.dart';
import 'settings/settings_widgets.dart';
import 'user_form_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              const Color(0xFFF0F7F0),
              Colors.white,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.85),
                    const Color(0xFF2E7D32),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Colors.white.withValues(alpha: 0.55),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.people_rounded, size: 18),
                          text: 'Users',
                          iconMargin: EdgeInsets.only(bottom: 2),
                        ),
                        Tab(
                          icon: Icon(Icons.tune_rounded, size: 18),
                          text: 'Settings',
                          iconMargin: EdgeInsets.only(bottom: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _UsersTab(),
                  _SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Users tab ─────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final UserManagementViewModel _vm = UserManagementViewModel();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(() { if (mounted) setState(() {}); });
    _searchCtrl.addListener(() => _vm.search(_searchCtrl.text));
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAddDialog() async {
    final result =
        await showDialog<({String name, UserRole role, String pin})>(
      context: context,
      builder: (_) => const UserFormDialog(),
    );
    if (result != null) {
      _vm.addUser(name: result.name, role: result.role, pin: result.pin);
    }
  }

  Future<void> _openEditDialog(UserModel user) async {
    final result =
        await showDialog<({String name, UserRole role, String pin})>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );
    if (result != null) {
      _vm.updateUser(
          user.copyWith(name: result.name, role: result.role, pin: result.pin));
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirmed =
        await showSettingsDeleteConfirm(context, user.name);
    if (confirmed == true) _vm.removeUser(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildToolbar(colorScheme),
          const SizedBox(height: 24),
          Expanded(child: _buildUserTable(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: SettingsSearchField(
              controller: _searchCtrl, hint: 'Search user...'),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: 'Add User',
          child: FilledButton(
            onPressed: _openAddDialog,
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Icon(Icons.person_add_rounded, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTable(ColorScheme colorScheme) {
    final users = _vm.users;
    if (users.isEmpty) {
      return const SettingsEmptyState(
          icon: Icons.person_search_rounded, message: 'No users found');
    }

    return SettingsDataTable(
      headers: const ['#', '', 'Name', 'Role', 'PIN', ''],
      flexes: const [1, 1, 3, 2, 2, 1],
      itemCount: users.length,
      rowBuilder: (i) {
        final user = users[i];
        return [
          Text(
            '${i + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              user.displayInitials,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          _RoleBadge(role: user.role, colorScheme: colorScheme),
          Text(
            '••••••',
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 4,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsActionIcon(
                icon: Icons.edit_rounded,
                color: colorScheme.primary,
                tooltip: 'Edit',
                onTap: () => _openEditDialog(user),
              ),
              SettingsActionIcon(
                icon: Icons.delete_rounded,
                color: colorScheme.error,
                tooltip: 'Delete',
                onTap: () => _confirmDelete(user),
              ),
            ],
          ),
        ];
      },
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.colorScheme});

  final UserRole role;
  final ColorScheme colorScheme;

  Color get _color {
    switch (role) {
      case UserRole.admin:     return colorScheme.primary;
      case UserRole.inventory: return const Color(0xFFF57F17);
      case UserRole.ziswaf:    return const Color(0xFF6A1B9A);
    }
  }

  IconData get _icon {
    switch (role) {
      case UserRole.admin:     return Icons.admin_panel_settings_rounded;
      case UserRole.inventory: return Icons.inventory_2_rounded;
      case UserRole.ziswaf:    return Icons.volunteer_activism_rounded;
    }
  }

  String get _label {
    switch (role) {
      case UserRole.admin:     return 'Admin';
      case UserRole.inventory: return 'Inventory';
      case UserRole.ziswaf:    return 'ZISWAF';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tab ──────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: ItemTypeTab(),
    );
  }
}
