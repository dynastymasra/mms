import 'package:flutter/material.dart';

// ── Search field ──────────────────────────────────────────────────────────────

class SettingsSearchField extends StatelessWidget {
  const SettingsSearchField({
    super.key,
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.4)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 18),
                onPressed: controller.clear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ── Generic paginated data table ──────────────────────────────────────────────

class SettingsDataTable extends StatefulWidget {
  const SettingsDataTable({
    super.key,
    required this.headers,
    required this.flexes,
    required this.itemCount,
    required this.rowBuilder,
  });

  final List<String> headers;
  final List<int> flexes;
  final int itemCount;
  final List<Widget> Function(int i) rowBuilder;

  @override
  State<SettingsDataTable> createState() => _SettingsDataTableState();
}

class _SettingsDataTableState extends State<SettingsDataTable> {
  static const _pageSizeOptions = [5, 10, 25, 50];

  int _pageSize = 10;
  int _page = 0; // zero-based

  int get _totalPages =>
      (_pageSize == 0 || widget.itemCount == 0)
          ? 1
          : (widget.itemCount / _pageSize).ceil();

  @override
  void didUpdateWidget(SettingsDataTable old) {
    super.didUpdateWidget(old);
    // Reset to first page when data changes (e.g. after search/delete)
    if (old.itemCount != widget.itemCount) {
      final maxPage = (widget.itemCount / _pageSize).ceil() - 1;
      if (_page > maxPage) _page = maxPage.clamp(0, maxPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, widget.itemCount);
    final pageCount = end - start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Table card ──────────────────────────────────────────────────────
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.1),
                          colorScheme.primary.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: List.generate(
                        widget.headers.length,
                        (i) => Expanded(
                          flex: widget.flexes[i],
                          child: Text(
                            widget.headers[i].toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Data rows — scrollable within the page slice
                  Expanded(
                    child: ListView.separated(
                      itemCount: pageCount,
                      separatorBuilder: (context, i) => Divider(
                        height: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.06),
                      ),
                      itemBuilder: (_, i) {
                        final dataIndex = start + i;
                        final cells = widget.rowBuilder(dataIndex);
                        return Container(
                          decoration: BoxDecoration(
                            color: i.isEven
                                ? Colors.white
                                : colorScheme.primary.withValues(alpha: 0.02),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 13),
                          child: Row(
                            children: List.generate(
                              cells.length,
                              (ci) => Expanded(
                                  flex: widget.flexes[ci], child: cells[ci]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Pagination footer ───────────────────────────────────────────────
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Total count
              Text(
                'Total: ${widget.itemCount} item${widget.itemCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              // Rows per page
              Text(
                'View per page:',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              _PageSizeSelector(
                value: _pageSize,
                options: _pageSizeOptions,
                colorScheme: colorScheme,
                onChanged: (v) => setState(() {
                  _pageSize = v;
                  _page = 0;
                }),
              ),
              const SizedBox(width: 24),
              // Page info
              Text(
                widget.itemCount == 0
                    ? '0 of 0'
                    : '${start + 1}–$end of ${widget.itemCount}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              // Prev / Next
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: _page > 0,
                colorScheme: colorScheme,
                onTap: () => setState(() => _page--),
              ),
              const SizedBox(width: 4),
              _PageChips(
                currentPage: _page,
                totalPages: _totalPages,
                colorScheme: colorScheme,
                onPageTap: (p) => setState(() => _page = p),
              ),
              const SizedBox(width: 4),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: _page < _totalPages - 1,
                colorScheme: colorScheme,
                onTap: () => setState(() => _page++),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageSizeSelector extends StatelessWidget {
  const _PageSizeSelector({
    required this.value,
    required this.options,
    required this.colorScheme,
    required this.onChanged,
  });

  final int value;
  final List<int> options;
  final ColorScheme colorScheme;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text('$o')))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 22,
          color: enabled
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _PageChips extends StatelessWidget {
  const _PageChips({
    required this.currentPage,
    required this.totalPages,
    required this.colorScheme,
    required this.onPageTap,
  });

  final int currentPage;
  final int totalPages;
  final ColorScheme colorScheme;
  final ValueChanged<int> onPageTap;

  @override
  Widget build(BuildContext context) {
    // Show at most 5 page chips with ellipsis strategy
    final pages = _visiblePages(currentPage, totalPages);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pages.map((p) {
        if (p == -1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('…',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4))),
          );
        }
        final active = p == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: active ? null : () => onPageTap(p),
            borderRadius: BorderRadius.circular(6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: active
                    ? colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: active
                    ? null
                    : Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(
                  '${p + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Returns page indices to show; -1 means ellipsis
  List<int> _visiblePages(int current, int total) {
    if (total <= 7) return List.generate(total, (i) => i);
    final result = <int>[];
    if (current <= 3) {
      result.addAll([0, 1, 2, 3, 4, -1, total - 1]);
    } else if (current >= total - 4) {
      result.addAll(
          [0, -1, total - 5, total - 4, total - 3, total - 2, total - 1]);
    } else {
      result.addAll(
          [0, -1, current - 1, current, current + 1, -1, total - 1]);
    }
    return result;
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class SettingsEmptyState extends StatelessWidget {
  const SettingsEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 64, color: colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action icon button ────────────────────────────────────────────────────────

class SettingsActionIcon extends StatelessWidget {
  const SettingsActionIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
      tooltip: tooltip,
    );
  }
}

// ── Simple form dialog ────────────────────────────────────────────────────────

class SettingsFormField {
  const SettingsFormField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
}

class SettingsFormDialog extends StatelessWidget {
  const SettingsFormDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.formKey,
    required this.fields,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String title;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<SettingsFormField> fields;
  final VoidCallback onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 420,
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
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...fields.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: f.controller,
                        validator: f.validator,
                        decoration: InputDecoration(
                          labelText: f.label,
                          prefixIcon: Icon(f.icon,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                              size: 20),
                          filled: true,
                          fillColor:
                              colorScheme.onSurface.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: colorScheme.primary, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: colorScheme.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: colorScheme.error, width: 1.5),
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.2)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onSubmit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(submitLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Delete confirm dialog ─────────────────────────────────────────────────────

Future<bool?> showSettingsDeleteConfirm(
    BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (_) {
      final colorScheme = Theme.of(context).colorScheme;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: colorScheme.error, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delete "$name"?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.2)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
