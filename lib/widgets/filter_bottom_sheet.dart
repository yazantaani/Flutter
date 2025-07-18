import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final SortBy currentSortBy;
  final SortOrder currentSortOrder;
  final Function(String?, SortBy, SortOrder) onApplyFilter;
  final VoidCallback onClearFilter;

  const FilterBottomSheet({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onApplyFilter,
    required this.onClearFilter,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  SortBy _selectedSortBy = SortBy.title;
  SortOrder _selectedSortOrder = SortOrder.asc;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedSortBy = widget.currentSortBy;
    _selectedSortOrder = widget.currentSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  CheckboxListTile(
                    title: const Text('All Categories'),
                    value: _selectedCategory == null,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedCategory = value == true ? null : _selectedCategory;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ...widget.categories.map((category) => CheckboxListTile(
                    title: Text(category.replaceAll('-', ' ').toUpperCase()),
                    value: _selectedCategory == category,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedCategory = value == true ? category : null;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...SortBy.values.map((sortBy) => RadioListTile<SortBy>(
                    title: Text(_getSortByDisplayName(sortBy)),
                    value: sortBy,
                    groupValue: _selectedSortBy,
                    onChanged: (SortBy? value) {
                      setState(() {
                        _selectedSortBy = value ?? SortBy.title;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Sort Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  RadioListTile<SortOrder>(
                    title: const Text('Ascending'),
                    value: SortOrder.asc,
                    groupValue: _selectedSortOrder,
                    onChanged: (SortOrder? value) {
                      setState(() {
                        _selectedSortOrder = value ?? SortOrder.asc;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<SortOrder>(
                    title: const Text('Descending'),
                    value: SortOrder.desc,
                    groupValue: _selectedSortOrder,
                    onChanged: (SortOrder? value) {
                      setState(() {
                        _selectedSortOrder = value ?? SortOrder.desc;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onClearFilter();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApplyFilter(
                              _selectedCategory,
                              _selectedSortBy,
                              _selectedSortOrder,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSortByDisplayName(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.title:
        return 'Name';
      case SortBy.price:
        return 'Price';
      case SortBy.rating:
        return 'Rating';
      case SortBy.category:
        return 'Category';
      case SortBy.brand:
        return 'Brand';
    }
  }
} 