import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../blocs/product/product_cubit.dart';
import '../blocs/cart/cart_cubit.dart';
import '../blocs/auth/auth_cubit.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/cart_icon_widget.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  SortBy _currentSortBy = SortBy.title;
  SortOrder _currentSortOrder = SortOrder.asc;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts(isRefresh: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().restoreProductList();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<ProductCubit>().restoreProductList();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ProductCubit>().loadMoreProducts();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService().getCategoryNames();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        currentSortBy: _currentSortBy,
        currentSortOrder: _currentSortOrder,
        onApplyFilter: (category, sortBy, sortOrder) {
          setState(() {
            _selectedCategory = category;
            _currentSortBy = sortBy;
            _currentSortOrder = sortOrder;
          });
          
          if (category != null) {
            context.read<ProductCubit>().getProductsByCategory(category);
          } else {
            context.read<ProductCubit>().sortProducts(sortBy, sortOrder);
          }
        },
        onClearFilter: () {
          setState(() {
            _selectedCategory = null;
            _currentSortBy = SortBy.title;
            _currentSortOrder = SortOrder.asc;
          });
          context.read<ProductCubit>().clearFilters();
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<ProductCubit>().clearFilters();
    } else {
      context.read<ProductCubit>().searchProducts(query);
    }
  }

  void _addToCart(Product product) {
    context.read<CartCubit>().addToCart(product);
    Fluttertoast.showToast(
      msg: "${product.title} added to cart",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final isGuest = authState.user?.isGuest ?? false;

          return _buildProductList();
        },
      ),
    );
  }

  Widget _buildProductList() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final isGuest = authState.user?.isGuest ?? false;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isGuest)
                  Text(
                    'Guest Mode',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedCategory != null ? Colors.blue : Colors.black54,
            ),
            onPressed: _showFilterBottomSheet,
          ),
          const CartIconWidget(),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final isGuest = authState.user?.isGuest ?? false;

              if (isGuest) {
                return TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              } else {
                return PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black54,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthCubit>().signOut();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Search products...',
            ),
          ),
          
          if (_categories.isNotEmpty)
            Container(
              height: 60,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: const Text(
                          'All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: _selectedCategory == null,
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[700],
                        backgroundColor: Colors.grey[100],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                          context.read<ProductCubit>().loadProducts(isRefresh: true);
                        },
                      ),
                    );
                  }
                  
                  final category = _categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(
                        category.replaceAll('-', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: _selectedCategory == category,
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[700],
                      backgroundColor: Colors.grey[100],
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        
                        if (selected) {
                          context.read<ProductCubit>().getProductsByCategory(category);
                        } else {
                          context.read<ProductCubit>().clearFilters();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          
          Expanded(
            child: BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductInitial || state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductCubit>().refreshProducts();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ProductCubit>().refreshProducts();
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  productId: product.id,
                                ),
                              ),
                            );
                          },
                          onAddToCart: () => _addToCart(product),
                        );
                      },
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
} 