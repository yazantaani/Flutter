import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ApiService _apiService;
  
  ProductCubit(this._apiService) : super(ProductInitial());

  Future<void> loadProducts({
    int limit = 30,
    int skip = 0,
    bool isRefresh = false,
  }) async {
    if (state is ProductLoading) return;
    
    try {      
      if (isRefresh) {
        emit(ProductLoading());
      } else if (state is ProductInitial) {
        emit(ProductLoading());
      }

      final response = await _apiService.getProducts(
        limit: limit,
        skip: skip,
      );

      if (isRefresh || state is ProductInitial) {
        emit(ProductLoaded(
          products: response.products,
          hasReachedMax: response.products.length < limit,
          total: response.total,
          currentPage: 0,
        ));
      } else if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        final updatedProducts = skip == 0 
            ? response.products 
            : [...currentState.products, ...response.products];
        
        emit(ProductLoaded(
          products: updatedProducts,
          hasReachedMax: response.products.length < limit,
          total: response.total,
          currentPage: (skip / limit).floor(),
        ));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts(isRefresh: true);
      return;
    }

    try {
      emit(ProductLoading());
      final response = await _apiService.searchProducts(query);
      
      emit(ProductLoaded(
        products: response.products,
        hasReachedMax: true,
        total: response.total,
        currentPage: 0,
        searchQuery: query,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> getProductsByCategory(String category) async {
    try {
      emit(ProductLoading());
      final response = await _apiService.getProductsByCategory(category);
      
      emit(ProductLoaded(
        products: response.products,
        hasReachedMax: true,
        total: response.total,
        currentPage: 0,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> getProduct(int productId) async {
    try {
      emit(ProductLoading());
      final product = await _apiService.getProduct(productId);
      
      emit(ProductSingleLoaded(product: product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> sortProducts(SortBy sortBy, SortOrder order) async {
    try {
      emit(ProductLoading());
      final response = await _apiService.getSortedProducts(
        sortBy: sortBy.value,
        order: order.value,
      );
      
      emit(ProductLoaded(
        products: response.products,
        hasReachedMax: true,
        total: response.total,
        currentPage: 0,
        sortBy: sortBy,
        sortOrder: order,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> filterProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? brand,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) async {
    try {
      emit(ProductLoading());
      final response = await _apiService.getFilteredProducts(
        category: category,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy?.value,
        order: sortOrder?.value,
      );
      
      emit(ProductLoaded(
        products: response.products,
        hasReachedMax: true,
        total: response.total,
        currentPage: 0,
        selectedCategory: category,
        searchQuery: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedBrand: brand,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> advancedSearch({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? tags,
    String? brand,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) async {
    try {
      emit(ProductLoading());
      final response = await _apiService.advancedSearch(
        query: query,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        tags: tags,
        brand: brand,
        sortBy: sortBy?.value,
        order: sortOrder?.value,
      );
      
      emit(ProductLoaded(
        products: response.products,
        hasReachedMax: true,
        total: response.total,
        currentPage: 0,
        selectedCategory: category,
        searchQuery: query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedBrand: brand,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts(isRefresh: true);
  }

  Future<void> loadMoreProducts() async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      if (!currentState.hasReachedMax) {
        final nextSkip = (currentState.currentPage + 1) * 30;
        await loadProducts(skip: nextSkip);
      }
    }
  }

  Future<void> clearFilters() async {
    await loadProducts(isRefresh: true);
  }

  void reset() {
    emit(ProductInitial());
  }

  Future<void> restoreProductList() async {
    if (state is ProductSingleLoaded || state is ProductInitial) {
      await loadProducts(isRefresh: true);
    }
  }
} 