import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';
  String _phone = '+91 9876543210';
  String _profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';
  List<String> _addresses = [
    'Home - 123, Block A, Sector 62, Noida',
    'Work - 456, Tech Park, Sector 63, Noida'
  ];
  
  // List of past orders (static for now)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD12345',
      'date': '12 Jun 2023',
      'restaurant': 'Paradise Biryani',
      'items': ['Veg Biryani x1', 'Butter Naan x2'],
      'amount': 349.0,
      'status': 'Delivered',
    },
    {
      'id': 'ORD12344',
      'date': '10 Jun 2023',
      'restaurant': 'Punjabi Tadka',
      'items': ['Paneer Butter Masala x1', 'Roti x3'],
      'amount': 399.0,
      'status': 'Delivered',
    },
    {
      'id': 'ORD12343',
      'date': '5 Jun 2023',
      'restaurant': 'Pizza Hub',
      'items': ['Margherita Pizza x1', 'Pepsi x1'],
      'amount': 299.0,
      'status': 'Delivered',
    },
  ];
  
  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImageUrl => _profileImageUrl;
  List<String> get addresses => _addresses;
  List<Map<String, dynamic>> get orders => _orders;
  
  // Setters with notifyListeners
  set name(String value) {
    _name = value;
    notifyListeners();
  }
  
  set email(String value) {
    _email = value;
    notifyListeners();
  }
  
  set phone(String value) {
    _phone = value;
    notifyListeners();
  }
  
  set profileImageUrl(String value) {
    _profileImageUrl = value;
    notifyListeners();
  }
  
  // Add a new address
  void addAddress(String address) {
    _addresses.add(address);
    notifyListeners();
  }
  
  // Remove an address
  void removeAddress(int index) {
    if (index >= 0 && index < _addresses.length) {
      _addresses.removeAt(index);
      notifyListeners();
    }
  }
  
  // Update an address
  void updateAddress(int index, String newAddress) {
    if (index >= 0 && index < _addresses.length) {
      _addresses[index] = newAddress;
      notifyListeners();
    }
  }
} 