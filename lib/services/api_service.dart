import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 30);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final http.Client _client;

  void initialize() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}',
          'Failed to load data: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network Error', e.toString());
    }
  }

  Future<ProductsResponse> getProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    final endpoint = '/products?limit=$limit&skip=$skip';
    final data = await _get(endpoint);
    return ProductsResponse.fromJson(data);
  }

  Future<Product> getProduct(int id) async {
    final endpoint = '/products/$id';
    final data = await _get(endpoint);
    return Product.fromJson(data);
  }

  Future<ProductsResponse> searchProducts(
    String query, {
    int limit = 30,
    int skip = 0,
  }) async {
    final endpoint = '/products/search?q=${Uri.encodeComponent(query)}&limit=$limit&skip=$skip';
    final data = await _get(endpoint);
    return ProductsResponse.fromJson(data);
  }

  Future<ProductsResponse> getProductsByCategory(
    String category, {
    int limit = 30,
    int skip = 0,
  }) async {
    final endpoint = '/products/category/$category?limit=$limit&skip=$skip';
    final data = await _get(endpoint);
    return ProductsResponse.fromJson(data);
  }

  Future<List<Category>> getCategories() async {
    try {
      final endpoint = '/products/categories';
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((json) => Category.fromJson(json)).toList();
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}',
          'Failed to load categories: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network Error', e.toString());
    }
  }

  Future<List<String>> getCategoryNames() async {
    try {
      final endpoint = '/products/category-list';
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).cast<String>();
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}',
          'Failed to load categories: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network Error', e.toString());
    }
  }

  Future<ProductsResponse> getSortedProducts({
    required String sortBy,
    required String order, 
    int limit = 30,
    int skip = 0,
  }) async {
    final endpoint = '/products?sortBy=$sortBy&order=$order&limit=$limit&skip=$skip';
    final data = await _get(endpoint);
    return ProductsResponse.fromJson(data);
  }

  Future<ProductsResponse> getFilteredProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? order,
    int limit = 30,
    int skip = 0,
  }) async {
    String endpoint = '/products';
    Map<String, String> params = {};

    if (category != null && category.isNotEmpty) {
      endpoint = '/products/category/$category';
    }

    if (search != null && search.isNotEmpty) {
      endpoint = '/products/search';
      params['q'] = search;
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      params['sortBy'] = sortBy;
    }

    if (order != null && order.isNotEmpty) {
      params['order'] = order;
    }

    params['limit'] = limit.toString();
    params['skip'] = skip.toString();

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final fullEndpoint = '$endpoint?$queryString';
    final data = await _get(fullEndpoint);
    final response = ProductsResponse.fromJson(data);

    if (minPrice != null || maxPrice != null) {
      final filteredProducts = response.products.where((product) {
        if (minPrice != null && product.price < minPrice) return false;
        if (maxPrice != null && product.price > maxPrice) return false;
        return true;
      }).toList();

      return ProductsResponse(
        products: filteredProducts,
        total: filteredProducts.length,
        skip: response.skip,
        limit: response.limit,
      );
    }

    return response;
  }

  Future<ProductsResponse> advancedSearch({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? tags,
    String? brand,
    String? sortBy,
    String? order,
    int limit = 30,
    int skip = 0,
  }) async {
    ProductsResponse response;
    
    if (query != null && query.isNotEmpty) {
      response = await searchProducts(query, limit: limit, skip: skip);
    } else if (category != null && category.isNotEmpty) {
      response = await getProductsByCategory(category, limit: limit, skip: skip);
    } else {
      response = await getProducts(limit: limit, skip: skip);
    }

    var filteredProducts = response.products;

    if (minPrice != null) {
      filteredProducts = filteredProducts.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      filteredProducts = filteredProducts.where((p) => p.price <= maxPrice).toList();
    }

    if (minRating != null) {
      filteredProducts = filteredProducts.where((p) => (p.rating ?? 0) >= minRating).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) => 
        p.tags != null && tags.any((tag) => p.tags!.contains(tag))
      ).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) => 
        p.brand != null && p.brand!.toLowerCase().contains(brand.toLowerCase())
      ).toList();
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      filteredProducts.sort((a, b) {
        int comparison = 0;
        
        switch (sortBy) {
          case 'price':
            comparison = a.price.compareTo(b.price);
            break;
          case 'rating':
            comparison = (a.rating ?? 0).compareTo(b.rating ?? 0);
            break;
          case 'title':
            comparison = a.title.compareTo(b.title);
            break;
          case 'category':
            comparison = a.category.compareTo(b.category);
            break;
          case 'brand':
            comparison = (a.brand ?? '').compareTo(b.brand ?? '');
            break;
          default:
            comparison = 0;
        }
        
        return order == 'desc' ? -comparison : comparison;
      });
    }

    return ProductsResponse(
      products: filteredProducts,
      total: filteredProducts.length,
      skip: skip,
      limit: limit,
    );
  }
}

class ApiException implements Exception {
  final String type;
  final String message;

  ApiException(this.type, this.message);

  @override
  String toString() => 'ApiException: $type - $message';
}


enum SortBy {
  price,
  rating,
  title,
  category,
  brand,
}

enum SortOrder {
  asc,
  desc,
}

extension SortByExtension on SortBy {
  String get value {
    switch (this) {
      case SortBy.price:
        return 'price';
      case SortBy.rating:
        return 'rating';
      case SortBy.title:
        return 'title';
      case SortBy.category:
        return 'category';
      case SortBy.brand:
        return 'brand';
    }
  }
}

extension SortOrderExtension on SortOrder {
  String get value {
    switch (this) {
      case SortOrder.asc:
        return 'asc';
      case SortOrder.desc:
        return 'desc';
    }
  }
} 