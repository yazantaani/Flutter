part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;
  final int total;
  final int currentPage;
  final String? searchQuery;
  final String? selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedBrand;
  final SortBy? sortBy;
  final SortOrder? sortOrder;

  const ProductLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.total,
    required this.currentPage,
    this.searchQuery,
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
    this.selectedBrand,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [
        products,
        hasReachedMax,
        total,
        currentPage,
        searchQuery,
        selectedCategory,
        minPrice,
        maxPrice,
        selectedBrand,
        sortBy,
        sortOrder,
      ];

  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    int? total,
    int? currentPage,
    String? searchQuery,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    String? selectedBrand,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ProductSingleLoaded extends ProductState {
  final Product product;

  const ProductSingleLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
} 