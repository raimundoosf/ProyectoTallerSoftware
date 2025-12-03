import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_filter.dart';

class CompanySearchBar extends StatefulWidget {
  final CompanyFilter filter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback? onClearFilters;

  const CompanySearchBar({
    super.key,
    required this.filter,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.onClearFilters,
  });

  @override
  State<CompanySearchBar> createState() => _CompanySearchBarState();
}

class _CompanySearchBarState extends State<CompanySearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.filter.searchQuery);
  }

  @override
  void didUpdateWidget(CompanySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter.searchQuery != _controller.text) {
      _controller.text = widget.filter.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = widget.filter.hasActiveFilters;
    final filterCount = widget.filter.activeFilterCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar empresas...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón de filtros
          Stack(
            children: [
              IconButton.filled(
                onPressed: widget.onFilterTap,
                icon: const Icon(Icons.tune_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: hasFilters
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                  foregroundColor: hasFilters
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (filterCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      filterCount.toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
