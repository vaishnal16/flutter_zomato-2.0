import 'package:flutter/foundation.dart';
import 'food_item.dart';

class CartItem {
  final FoodItem item;
  int quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });

  double get total => item.price * quantity;
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  // Get the cart items
  List<CartItem> get items => _items;
  
  // Get the total number of items in the cart
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  // Get the total price of all items in the cart
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.total);
  
  // Get the delivery fee (static for now)
  double get deliveryFee => 39.0;
  
  // Get the taxes (static for now)
  double get taxes => totalPrice * 0.05; // 5% tax
  
  // Get the discount (static for now)
  double get discount => totalPrice > 300 ? 100.0 : 0.0;
  
  // Get the grand total
  double get grandTotal => totalPrice + deliveryFee + taxes - discount;
  
  // Check if the cart has the item
  bool hasItem(String id) {
    return _items.any((item) => item.item.id == id);
  }
  
  // Get the quantity of an item
  int getQuantity(String id) {
    final index = _items.indexWhere((item) => item.item.id == id);
    return index >= 0 ? _items[index].quantity : 0;
  }
  
  // Add an item to the cart
  void addItem(FoodItem item) {
    final index = _items.indexWhere((cartItem) => cartItem.item.id == item.id);
    
    if (index >= 0) {
      // Item already exists, increase quantity
      _items[index].quantity++;
    } else {
      // New item, add to cart
      _items.add(CartItem(item: item));
    }
    
    notifyListeners();
  }
  
  // Update item quantity
  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.item.id == id);
    
    if (index >= 0) {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        _items.removeAt(index);
      } else {
        // Update quantity
        _items[index].quantity = quantity;
      }
      
      notifyListeners();
    }
  }
  
  // Increment item quantity
  void incrementQuantity(String id) {
    final index = _items.indexWhere((item) => item.item.id == id);
    
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }
  
  // Decrement item quantity
  void decrementQuantity(String id) {
    final index = _items.indexWhere((item) => item.item.id == id);
    
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        // Remove item if quantity becomes 0
        _items.removeAt(index);
      }
      
      notifyListeners();
    }
  }
  
  // Remove an item from the cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.item.id == id);
    notifyListeners();
  }
  
  // Clear the cart
  void clear() {
    _items.clear();
    notifyListeners();
  }
} 