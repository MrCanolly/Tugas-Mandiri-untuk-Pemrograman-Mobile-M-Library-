import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Load data from Supabase on startup
  await DataStore.loadFromSupabase();

  runApp(const MLibraryApp());
}

// Get Supabase client instance
final supabase = Supabase.instance.client;

class MLibraryApp extends StatelessWidget {
  const MLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M-Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB8860B),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB8860B),
          secondary: Color(0xFFDC143C),
          tertiary: Color(0xFF1E90FF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB8860B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen with Animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8860B),
              Color(0xFFDAA520),
              Color(0xFFDC143C),
              Color(0xFF1E90FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      size: 100,
                      color: Color(0xFFB8860B),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'M-Library',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(2, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Digital Library System',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data Models
class User {
  String id;
  String email;
  String password;
  String role; // 'manager', 'librarian', 'member'
  String name;
  String phone;
  bool isActive;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    required this.phone,
    this.isActive = true,
  });
}

class Book {
  String id;
  String title;
  String author;
  String category;
  String description;
  int stock;
  int totalCopies;
  String? pdfPath;
  String? pdfFileName;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.stock,
    required this.totalCopies,
    this.pdfPath,
    this.pdfFileName,
  });
}

class Loan {
  String id;
  String memberId;
  String bookId;
  DateTime loanDate;
  DateTime dueDate;
  DateTime? returnDate;
  String status; // 'pending', 'approved', 'active', 'returned', 'overdue'
  double fine;
  String? bookTitle;
  String? memberName;

  Loan({
    required this.id,
    required this.memberId,
    required this.bookId,
    required this.loanDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.fine = 0.0,
    this.bookTitle,
    this.memberName,
  });
}

// Data Store with Supabase Integration
class DataStore {
  // Local cache untuk performa (akan di-sync dengan Supabase)
  static List<User> users = [];
  static List<Book> books = [];
  static List<Loan> loans = [];
  
  static int maxLoanDays = 14;
  static double finePerDay = 5000.0;
  static int maxBooksPerMember = 3;
  
  static User? currentUser;
  
  // Supabase sync methods
  
  // Load all data from Supabase
  static Future<void> loadFromSupabase() async {
    try {
      // Load users
      final usersData = await supabase.from('users').select();
      users = usersData.map((data) => User(
        id: data['id'],
        email: data['email'],
        password: data['password'],
        role: data['role'],
        name: data['name'],
        phone: data['phone'],
        isActive: data['is_active'] ?? true,
      )).toList();
      
      // Load books
      final booksData = await supabase.from('books').select();
      books = booksData.map((data) => Book(
        id: data['id'],
        title: data['title'],
        author: data['author'],
        category: data['category'],
        description: data['description'] ?? '',
        stock: data['stock'],
        totalCopies: data['total_copies'],
        pdfPath: data['pdf_path'],
        pdfFileName: data['pdf_file_name'],
      )).toList();
      
      // Load loans
      final loansData = await supabase.from('loans').select();
      loans = loansData.map((data) => Loan(
        id: data['id'],
        memberId: data['member_id'],
        bookId: data['book_id'],
        loanDate: DateTime.parse(data['loan_date']),
        dueDate: DateTime.parse(data['due_date']),
        returnDate: data['return_date'] != null ? DateTime.parse(data['return_date']) : null,
        status: data['status'],
        fine: (data['fine'] ?? 0).toDouble(),
        bookTitle: data['book_title'],
        memberName: data['member_name'],
      )).toList();
      
      // Load settings
      final settingsData = await supabase.from('settings').select().single();
      maxLoanDays = settingsData['max_loan_days'];
      finePerDay = (settingsData['fine_per_day']).toDouble();
      maxBooksPerMember = settingsData['max_books_per_member'];
      
    } catch (e) {
      print('Error loading from Supabase: $e');
      // Load default data jika Supabase gagal
      _loadDefaultData();
    }
  }
  
  // Save user to Supabase
  static Future<void> saveUser(User user) async {
    try {
      await supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'password': user.password,
        'role': user.role,
        'name': user.name,
        'phone': user.phone,
        'is_active': user.isActive,
      });
      
      // Update local cache
      final index = users.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        users[index] = user;
      } else {
        users.add(user);
      }
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Gagal menyimpan user');
    }
  }
  
  // Save book to Supabase
  static Future<void> saveBook(Book book) async {
    try {
      await supabase.from('books').upsert({
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'category': book.category,
        'description': book.description,
        'stock': book.stock,
        'total_copies': book.totalCopies,
        'pdf_path': book.pdfPath,
        'pdf_file_name': book.pdfFileName,
      });
      
      // Update local cache
      final index = books.indexWhere((b) => b.id == book.id);
      if (index >= 0) {
        books[index] = book;
      } else {
        books.add(book);
      }
    } catch (e) {
      print('Error saving book: $e');
      throw Exception('Gagal menyimpan buku');
    }
  }
  
  // Save loan to Supabase
  static Future<void> saveLoan(Loan loan) async {
    try {
      await supabase.from('loans').upsert({
        'id': loan.id,
        'member_id': loan.memberId,
        'book_id': loan.bookId,
        'loan_date': loan.loanDate.toIso8601String(),
        'due_date': loan.dueDate.toIso8601String(),
        'return_date': loan.returnDate?.toIso8601String(),
        'status': loan.status,
        'fine': loan.fine,
        'book_title': loan.bookTitle,
        'member_name': loan.memberName,
      });
      
      // Update local cache
      final index = loans.indexWhere((l) => l.id == loan.id);
      if (index >= 0) {
        loans[index] = loan;
      } else {
        loans.add(loan);
      }
    } catch (e) {
      print('Error saving loan: $e');
      throw Exception('Gagal menyimpan peminjaman');
    }
  }
  
  // Delete user from Supabase
  static Future<void> deleteUser(String userId) async {
    try {
      await supabase.from('users').delete().eq('id', userId);
      users.removeWhere((u) => u.id == userId);
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Gagal menghapus user');
    }
  }
  
  // Delete book from Supabase
  static Future<void> deleteBook(String bookId) async {
    try {
      await supabase.from('books').delete().eq('id', bookId);
      books.removeWhere((b) => b.id == bookId);
    } catch (e) {
      print('Error deleting book: $e');
      throw Exception('Gagal menghapus buku');
    }
  }
  
  // Delete loan from Supabase
  static Future<void> deleteLoan(String loanId) async {
    try {
      await supabase.from('loans').delete().eq('id', loanId);
      loans.removeWhere((l) => l.id == loanId);
    } catch (e) {
      print('Error deleting loan: $e');
      throw Exception('Gagal menghapus peminjaman');
    }
  }
  
  // Update settings to Supabase
  static Future<void> saveSettings() async {
    try {
      await supabase.from('settings').update({
        'max_loan_days': maxLoanDays,
        'fine_per_day': finePerDay,
        'max_books_per_member': maxBooksPerMember,
      }).eq('id', 1);
    } catch (e) {
      print('Error saving settings: $e');
      throw Exception('Gagal menyimpan pengaturan');
    }
  }
  
  // Load default data (fallback)
  static void _loadDefaultData() {
    users = [
      User(
        id: 'U001',
        email: 'manager@mlibrary.com',
        password: 'manager123',
        role: 'manager',
        name: 'Manager Admin',
        phone: '081234567890',
      ),
      User(
        id: 'U002',
        email: 'librarian@mlibrary.com',
        password: 'librarian123',
        role: 'librarian',
        name: 'Librarian Staff',
        phone: '081234567891',
      ),
      User(
        id: 'U003',
        email: 'member@mlibrary.com',
        password: 'member123',
        role: 'member',
        name: 'Member User',
        phone: '081234567892',
      ),
    ];
    
    books = [
      Book(
        id: 'B001',
        title: 'Pemrograman Flutter',
        author: 'John Doe',
        category: 'Technology',
        description: 'Belajar Flutter dari dasar hingga mahir',
        stock: 5,
        totalCopies: 5,
      ),
      Book(
        id: 'B002',
        title: 'Database MySQL',
        author: 'Jane Smith',
        category: 'Technology',
        description: 'Panduan lengkap MySQL untuk pemula',
        stock: 3,
        totalCopies: 3,
      ),
      Book(
        id: 'B003',
        title: 'Design Patterns',
        author: 'Gang of Four',
        category: 'Software Engineering',
        description: 'Pola desain dalam pemrograman',
        stock: 2,
        totalCopies: 2,
      ),
    ];
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    User? user = DataStore.users.firstWhere(
      (u) => u.email == email && u.password == password && u.isActive,
      orElse: () => User(
        id: '',
        email: '',
        password: '',
        role: '',
        name: '',
        phone: '',
      ),
    );

    if (user.id.isNotEmpty) {
      DataStore.currentUser = user;
      Widget homePage;

      switch (user.role) {
        case 'manager':
          homePage = const ManagerDashboard();
          break;
        case 'librarian':
          homePage = const LibrarianDashboard();
          break;
        case 'member':
          homePage = const MemberDashboard();
          break;
        default:
          homePage = const LoginPage();
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => homePage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Email atau password salah!'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8860B),
              Color(0xFFDAA520),
              Color(0xFFDC143C),
              Color(0xFF1E90FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB8860B).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFDC143C), Color(0xFF1E90FF)],
                          ).createShader(bounds),
                          child: const Text(
                            'M-Library',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat Datang Kembali',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Color(0xFFB8860B)),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFB8860B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Color(0xFFB8860B)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB8860B)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFFB8860B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDC143C), Color(0xFFFF1744)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC143C).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const RegisterPage(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Daftar disini',
                                style: TextStyle(
                                  color: Color(0xFF1E90FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'member';
  bool _obscurePassword = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      bool emailExists =
          DataStore.users.any((u) => u.email == _emailController.text.trim());

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 12),
                Text('Email sudah terdaftar!'),
              ],
            ),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      User newUser = User(
        id: 'U${DateTime.now().millisecondsSinceEpoch}',
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        name: _nameController.text,
        phone: _phoneController.text,
      );

      try {
        // Save ke Supabase
        await DataStore.saveUser(newUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Registrasi berhasil! Silakan login.'),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Gagal registrasi: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8860B),
              Color(0xFFDAA520),
              Color(0xFFDC143C),
              Color(0xFF1E90FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFFB8860B)),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: Text(
                            'Daftar untuk memulai',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!value.contains('@')) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Nomor Telepon',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor telepon tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Color(0xFFB8860B)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB8860B)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFB8860B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Daftar Sebagai',
                              labelStyle: const TextStyle(color: Color(0xFFB8860B)),
                              prefixIcon: const Icon(Icons.group_outlined, color: Color(0xFFB8860B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'member',
                                child: Text('Member'),
                              ),
                              DropdownMenuItem(
                                value: 'librarian',
                                child: Text('Librarian'),
                              ),
                              DropdownMenuItem(
                                value: 'manager',
                                child: Text('Manager'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E90FF), Color(0xFF4169E1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E90FF).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'DAFTAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFB8860B)),
          prefixIcon: Icon(icon, color: const Color(0xFFB8860B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: validator,
      ),
    );
  }
}

// Member Dashboard
class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  _MemberDashboardState createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MemberBooksPage(),
    const MemberLoansPage(),
    const MemberProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Member Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFDC143C)),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                    content: const Text('Yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          DataStore.currentUser = null;
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const LoginPage(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC143C),
                        ),
                        child: const Text('Logout', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFDC143C),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_rounded),
              label: 'Peminjaman',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// Member Books Page
class MemberBooksPage extends StatefulWidget {
  const MemberBooksPage({super.key});

  @override
  _MemberBooksPageState createState() => _MemberBooksPageState();
}

class _MemberBooksPageState extends State<MemberBooksPage> {
  String _searchQuery = '';

  void _requestLoan(Book book) async {
    int activeLoans = DataStore.loans
        .where((l) =>
            l.memberId == DataStore.currentUser!.id &&
            (l.status == 'pending' ||
                l.status == 'approved' ||
                l.status == 'active'))
        .length;

    if (activeLoans >= DataStore.maxBooksPerMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Text('Maksimal ${DataStore.maxBooksPerMember} buku'),
            ],
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (book.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Buku tidak tersedia'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Loan newLoan = Loan(
      id: 'L${DateTime.now().millisecondsSinceEpoch}',
      memberId: DataStore.currentUser!.id,
      bookId: book.id,
      loanDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: DataStore.maxLoanDays)),
      status: 'pending',
      bookTitle: book.title,
      memberName: DataStore.currentUser!.name,
    );

    setState(() {
      DataStore.loans.add(newLoan);
    });

    try {
      await DataStore.saveLoan(newLoan);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan peminjaman: $e')),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Request berhasil! Menunggu persetujuan')),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Book> filteredBooks = DataStore.books
        .where((b) =>
            b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB8860B).withOpacity(0.1),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, atau kategori...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB8860B)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Buku tidak ditemukan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      Book book = filteredBooks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFFFF9E6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB8860B).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              book.pdfPath != null
                                  ? Icons.picture_as_pdf
                                  : Icons.menu_book,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(book.author, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(book.category, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: book.stock > 0
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: book.stock > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  'Stok: ${book.stock}',
                                  style: TextStyle(
                                    color: book.stock > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: book.stock > 0
                                    ? [const Color(0xFF1E90FF), const Color(0xFF4169E1)]
                                    : [Colors.grey, Colors.grey[400]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: book.stock > 0
                                  ? [
                                      BoxShadow(
                                        color:
                                            const Color(0xFF1E90FF).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  book.stock > 0 ? () => _requestLoan(book) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle_outline,
                                      size: 18, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pinjam',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB8860B),
                                            Color(0xFFDAA520)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.menu_book,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        book.title,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(
                                          'Penulis', book.author, Icons.person),
                                      _buildDetailRow('Kategori', book.category,
                                          Icons.category),
                                      _buildDetailRow('Deskripsi',
                                          book.description, Icons.description),
                                      _buildDetailRow(
                                          'Stok',
                                          '${book.stock} dari ${book.totalCopies}',
                                          Icons.inventory),
                                      if (book.pdfFileName != null) ...[
                                        const Divider(height: 24),
                                        Row(
                                          children: [
                                            const Icon(Icons.picture_as_pdf,
                                                color: Colors.red),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                book.pdfFileName!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFB8860B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PDF Viewer Page
class PdfViewerPage extends StatefulWidget {
  final String pdfPath;
  final String bookTitle;

  const PdfViewerPage({super.key, required this.pdfPath, required this.bookTitle});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int? totalPages;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
            ),
          ),
        ),
        actions: [
          if (totalPages != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currentPage + 1} / $totalPages',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: File(widget.pdfPath).existsSync()
          ? Stack(
              children: [
                PDFView(
                  filePath: widget.pdfPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onRender: (pages) {
                    setState(() {
                      totalPages = pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print('PDF Error: $error');
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                    print('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    // PDF controller created
                  },
                  onLinkHandler: (String? uri) {
                    print('goto uri: $uri');
                  },
                  onPageChanged: (int? page, int? total) {
                    setState(() {
                      currentPage = page ?? 0;
                    });
                  },
                ),
                if (errorMessage.isNotEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error membaca PDF',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isReady && errorMessage.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFB8860B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat e-book...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.file_download_off_rounded,
                        size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      'File PDF tidak ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'File mungkin telah dihapus atau dipindahkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isReady
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentPage > 0)
                  FloatingActionButton(
                    heroTag: 'prev',
                    onPressed: () {
                      // Navigate to previous page - handled by PDFView
                    },
                    backgroundColor: const Color(0xFFB8860B),
                    child: const Icon(Icons.arrow_upward_rounded),
                  ),
                const SizedBox(height: 16),
                if (totalPages != null && currentPage < totalPages! - 1)
                  FloatingActionButton(
                    heroTag: 'next',
                    onPressed: () {
                      // Navigate to next page - handled by PDFView
                    },
                    backgroundColor: const Color(0xFFB8860B),
                    child: const Icon(Icons.arrow_downward_rounded),
                  ),
              ],
            )
          : null,
    );
  }
}

// Member Loans Page
class MemberLoansPage extends StatefulWidget {
  const MemberLoansPage({super.key});

  @override
  _MemberLoansPageState createState() => _MemberLoansPageState();
}

class _MemberLoansPageState extends State<MemberLoansPage> {
  void _openPdfReader(Loan loan) {
    Book? book = DataStore.books.firstWhere((b) => b.id == loan.bookId);
    
    if (book.pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('E-book tidak tersedia untuk buku ini'),
            ],
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Check if loan is approved or active
    if (loan.status != 'approved' && loan.status != 'active' && loan.status != 'overdue') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 12),
              Text('Buku hanya bisa dibaca setelah disetujui'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          pdfPath: book.pdfPath!,
          bookTitle: book.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Loan> memberLoans = DataStore.loans
        .where((l) => l.memberId == DataStore.currentUser!.id)
        .toList();

    // Update overdue status
    for (var loan in memberLoans) {
      if (loan.status == 'active' &&
          DateTime.now().isAfter(loan.dueDate) &&
          loan.returnDate == null) {
        loan.status = 'overdue';
        int overdueDays = DateTime.now().difference(loan.dueDate).inDays;
        loan.fine = overdueDays * DataStore.finePerDay;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB8860B).withOpacity(0.1),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: memberLoans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_rounded,
                      size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada peminjaman',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pinjam buku dari katalog',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: memberLoans.length,
              itemBuilder: (context, index) {
                Loan loan = memberLoans[index];
                Book? book = DataStore.books.firstWhere((b) => b.id == loan.bookId);
                
                Color statusColor;
                IconData statusIcon;
                
                switch (loan.status) {
                  case 'pending':
                    statusColor = Colors.orange;
                    statusIcon = Icons.hourglass_empty_rounded;
                    break;
                  case 'approved':
                    statusColor = Colors.blue;
                    statusIcon = Icons.check_circle_rounded;
                    break;
                  case 'active':
                    statusColor = Colors.green;
                    statusIcon = Icons.bookmark_rounded;
                    break;
                  case 'overdue':
                    statusColor = Colors.red;
                    statusIcon = Icons.warning_rounded;
                    break;
                  case 'returned':
                    statusColor = Colors.grey;
                    statusIcon = Icons.done_all_rounded;
                    break;
                  default:
                    statusColor = Colors.black;
                    statusIcon = Icons.info_rounded;
                }

                bool canReadPdf = (loan.status == 'approved' || 
                                   loan.status == 'active' || 
                                   loan.status == 'overdue') && 
                                  book.pdfPath != null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFF9E6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFB8860B), Color(0xFFDAA520)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                book.pdfPath != null
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loan.bookTitle ?? 'Unknown Book',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(statusIcon, size: 16, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        loan.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildLoanInfoRow(
                          Icons.calendar_today_rounded,
                          'Tanggal Pinjam',
                          loan.loanDate.toString().split(' ')[0],
                        ),
                        const SizedBox(height: 8),
                        _buildLoanInfoRow(
                          Icons.event_rounded,
                          'Jatuh Tempo',
                          loan.dueDate.toString().split(' ')[0],
                        ),
                        if (loan.returnDate != null) ...[
                          const SizedBox(height: 8),
                          _buildLoanInfoRow(
                            Icons.done_rounded,
                            'Dikembalikan',
                            loan.returnDate.toString().split(' ')[0],
                          ),
                        ],
                        if (loan.fine > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_rounded, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Denda: Rp ${loan.fine.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (canReadPdf) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E90FF), Color(0xFF4169E1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E90FF).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _openPdfReader(loan),
                              icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                              label: const Text(
                                'BACA E-BOOK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoanInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// Member Profile Page
class MemberProfilePage extends StatelessWidget {
  const MemberProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = DataStore.currentUser;
    if (user == null) return Container();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child:           CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFB8860B),
            child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            user.role.toUpperCase(),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 32),
        Card(
          child: ListTile(
            leading: const Icon(Icons.email_rounded, color: Color(0xFF1E90FF)),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_rounded, color: Color(0xFF1E90FF)),
            title: const Text('Telepon'),
            subtitle: Text(user.phone),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.badge_rounded, color: Color(0xFF1E90FF)),
            title: const Text('ID Member'),
            subtitle: Text(user.id),
          ),
        ),
      ],
    );
  }
}

// Librarian Dashboard
class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({super.key});

  @override
  _LibrarianDashboardState createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LibrarianBooksPage(),
    const LibrarianLoansPage(),
    const LibrarianMembersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Librarian Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              DataStore.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFDC143C),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Peminjaman'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Member'),
        ],
      ),
    );
  }
}

// Librarian Books Page
class LibrarianBooksPage extends StatefulWidget {
  const LibrarianBooksPage({super.key});

  @override
  _LibrarianBooksPageState createState() => _LibrarianBooksPageState();
}

class _LibrarianBooksPageState extends State<LibrarianBooksPage> {
  String? _selectedPdfPath;
  Uint8List? _selectedPdfBytes;
  String? _selectedPdfFileName;

  Future<void> _pickPdfFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // IMPORTANT for Web
    );

    if (result != null) {
      final file = result.files.single;

      // Print file details for debugging
      print('Picked file: ${file}');
      
      setState(() {
        _selectedPdfFileName = file.name;

        if (kIsWeb) {
          // WEB: path is NULL, use bytes
          _selectedPdfBytes = file.bytes;
        } else {
          // MOBILE / DESKTOP
          _selectedPdfPath = file.path;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File PDF dipilih: ${file.name}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memilih file: $e')),
    );
  }
}

  void _addBook() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final stockController = TextEditingController();
    _selectedPdfPath = null;
    _selectedPdfFileName = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Buku Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Buku',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(
                    labelText: 'Penulis',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Upload E-Book (PDF)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickPdfFile();
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Pilih File PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_selectedPdfFileName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedPdfFileName!,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _selectedPdfPath = null;
                _selectedPdfFileName = null;
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    stockController.text.isNotEmpty) {
                  Book newBook = Book(
                    id: 'B${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    author: authorController.text,
                    category: categoryController.text,
                    description: descriptionController.text,
                    stock: int.parse(stockController.text),
                    totalCopies: int.parse(stockController.text),
                    pdfPath: _selectedPdfPath,
                    pdfFileName: _selectedPdfFileName,
                  );
                  setState(() {
                    DataStore.books.add(newBook);
                  });
                  try {
                    await DataStore.saveBook(newBook);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan buku: $e')),
                    );
                  }
                  _selectedPdfPath = null;
                  _selectedPdfFileName = null;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buku berhasil ditambahkan')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan stok harus diisi!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC143C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: DataStore.books.length,
        itemBuilder: (context, index) {
          Book book = DataStore.books[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFB8860B),
                child: Icon(
                  book.pdfPath != null ? Icons.picture_as_pdf : Icons.book,
                  color: Colors.white,
                ),
              ),
              title: Text(book.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${book.author} | Stok: ${book.stock}'),
                  if (book.pdfFileName != null)
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.pdfFileName!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF1E90FF)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBook(book),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(book.title),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penulis: ${book.author}'),
                        const SizedBox(height: 8),
                        Text('Kategori: ${book.category}'),
                        const SizedBox(height: 8),
                        Text('Deskripsi: ${book.description}'),
                        const SizedBox(height: 8),
                        Text('Stok: ${book.stock}/${book.totalCopies}'),
                        if (book.pdfFileName != null) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  book.pdfFileName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        backgroundColor: const Color(0xFFDC143C),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteBook(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Yakin ingin menghapus buku "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                DataStore.books.remove(book);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buku berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Librarian Loans Page
class LibrarianLoansPage extends StatefulWidget {
  const LibrarianLoansPage({super.key});

  @override
  _LibrarianLoansPageState createState() => _LibrarianLoansPageState();
}

class _LibrarianLoansPageState extends State<LibrarianLoansPage> {
  void _approveLoan(Loan loan) {
    setState(() {
      loan.status = 'approved';
      // Decrease book stock
      Book? book = DataStore.books.firstWhere((b) => b.id == loan.bookId);
      book.stock--;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peminjaman disetujui')),
    );
  }

  void _activateLoan(Loan loan) {
    setState(() {
      loan.status = 'active';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peminjaman diaktifkan')),
    );
  }

  void _returnBook(Loan loan) {
    setState(() {
      loan.returnDate = DateTime.now();
      loan.status = 'returned';

      // Calculate fine if overdue
      if (DateTime.now().isAfter(loan.dueDate)) {
        int overdueDays = DateTime.now().difference(loan.dueDate).inDays;
        loan.fine = overdueDays * DataStore.finePerDay;
      }

      // Increase book stock
      Book? book = DataStore.books.firstWhere((b) => b.id == loan.bookId);
      book.stock++;
    });

    if (loan.fine > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buku dikembalikan. Denda: Rp ${loan.fine.toStringAsFixed(0)}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buku berhasil dikembalikan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update overdue status
    for (var loan in DataStore.loans) {
      if (loan.status == 'active' &&
          DateTime.now().isAfter(loan.dueDate) &&
          loan.returnDate == null) {
        loan.status = 'overdue';
        int overdueDays = DateTime.now().difference(loan.dueDate).inDays;
        loan.fine = overdueDays * DataStore.finePerDay;
      }
    }

    List<Loan> pendingLoans =
        DataStore.loans.where((l) => l.status == 'pending').toList();
    List<Loan> activeLoans = DataStore.loans
        .where((l) => l.status == 'active' || l.status == 'overdue' || l.status == 'approved')
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFFDC143C),
            tabs: [
              Tab(text: 'Menunggu Persetujuan'),
              Tab(text: 'Aktif'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pending loans
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingLoans.length,
                  itemBuilder: (context, index) {
                    Loan loan = pendingLoans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.bookTitle ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Member: ${loan.memberName}'),
                            Text('Tanggal Request: ${loan.loanDate.toString().split(' ')[0]}'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _approveLoan(loan),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      DataStore.loans.remove(loan);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Tolak', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Active loans
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeLoans.length,
                  itemBuilder: (context, index) {
                    Loan loan = activeLoans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.bookTitle ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Member: ${loan.memberName}'),
                            Text('Tanggal Pinjam: ${loan.loanDate.toString().split(' ')[0]}'),
                            Text('Jatuh Tempo: ${loan.dueDate.toString().split(' ')[0]}'),
                            Text(
                              'Status: ${loan.status.toUpperCase()}',
                              style: TextStyle(
                                color: loan.status == 'overdue'
                                    ? Colors.red
                                    : loan.status == 'approved'
                                        ? Colors.blue
                                        : Colors.green,
                              ),
                            ),
                            if (loan.fine > 0)
                              Text(
                                'Denda: Rp ${loan.fine.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (loan.status == 'approved')
                                  ElevatedButton(
                                    onPressed: () => _activateLoan(loan),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E90FF),
                                    ),
                                    child: const Text('Aktifkan', style: TextStyle(color: Colors.white)),
                                  ),
                                if (loan.status == 'active' ||
                                    loan.status == 'overdue')
                                  ElevatedButton(
                                    onPressed: () => _returnBook(loan),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Kembalikan', style: TextStyle(color: Colors.white)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Librarian Members Page
class LibrarianMembersPage extends StatefulWidget {
  const LibrarianMembersPage({super.key});

  @override
  _LibrarianMembersPageState createState() => _LibrarianMembersPageState();
}

class _LibrarianMembersPageState extends State<LibrarianMembersPage> {
  @override
  Widget build(BuildContext context) {
    List<User> members = DataStore.users.where((u) => u.role == 'member').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        User member = members[index];
        int activeLoans = DataStore.loans
            .where((l) =>
                l.memberId == member.id &&
                (l.status == 'active' || l.status == 'overdue'))
            .length;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E90FF),
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${member.email}'),
                Text('Peminjaman Aktif: $activeLoans'),
              ],
            ),
            trailing: Switch(
              value: member.isActive,
              onChanged: (value) {
                setState(() {
                  member.isActive = value;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

// Manager Dashboard
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  _ManagerDashboardState createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ManagerHomePage(),
    const ManagerUsersPage(),
    const ManagerReportsPage(),
    const ManagerSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              DataStore.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFDC143C),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Manager Home Page
class ManagerHomePage extends StatelessWidget {
  const ManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    int totalBooks = DataStore.books.length;
    int totalMembers = DataStore.users.where((u) => u.role == 'member').length;
    int activeLoans = DataStore.loans
        .where((l) => l.status == 'active' || l.status == 'overdue')
        .length;
    int overdueLoans = DataStore.loans.where((l) => l.status == 'overdue').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Dashboard Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('Total Buku', totalBooks.toString(), Icons.menu_book_rounded,
                const Color(0xFFB8860B)),
            _buildStatCard('Total Member', totalMembers.toString(),
                Icons.people_rounded, const Color(0xFF1E90FF)),
            _buildStatCard('Peminjaman Aktif', activeLoans.toString(),
                Icons.library_books_rounded, Colors.green),
            _buildStatCard('Terlambat', overdueLoans.toString(),
                Icons.warning_rounded, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Manager Users Page
class ManagerUsersPage extends StatefulWidget {
  const ManagerUsersPage({super.key});

  @override
  _ManagerUsersPageState createState() => _ManagerUsersPageState();
}

class _ManagerUsersPageState extends State<ManagerUsersPage> {
  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                DataStore.users.remove(user);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFFDC143C),
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Librarians'),
              Tab(text: 'Managers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUserList('member'),
                _buildUserList('librarian'),
                _buildUserList('manager'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(String role) {
    List<User> users = DataStore.users.where((u) => u.role == role).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        User user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFB8860B),
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}'),
                Text('Phone: ${user.phone}'),
                Text(
                  'Status: ${user.isActive ? "Active" : "Inactive"}',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: user.isActive,
                  onChanged: (value) {
                    setState(() {
                      user.isActive = value;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Manager Reports Page
class ManagerReportsPage extends StatelessWidget {
  const ManagerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    int totalLoans = DataStore.loans.length;
    int completedLoans =
        DataStore.loans.where((l) => l.status == 'returned').length;
    int activeLoans =
        DataStore.loans.where((l) => l.status == 'active').length;
    int overdueLoans =
        DataStore.loans.where((l) => l.status == 'overdue').length;
    double totalFines =
        DataStore.loans.fold(0, (sum, loan) => sum + loan.fine);

    // Most borrowed books
    Map<String, int> bookBorrowCount = {};
    for (var loan in DataStore.loans) {
      bookBorrowCount[loan.bookId] =
          (bookBorrowCount[loan.bookId] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Laporan & Statistik',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Peminjaman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildStatRow('Total Peminjaman', totalLoans.toString()),
                _buildStatRow('Selesai', completedLoans.toString()),
                _buildStatRow('Aktif', activeLoans.toString()),
                _buildStatRow('Terlambat', overdueLoans.toString()),
                _buildStatRow(
                    'Total Denda', 'Rp ${totalFines.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buku Paling Populer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                ...bookBorrowCount.entries.take(5).map((entry) {
                  Book? book =
                      DataStore.books.firstWhere((b) => b.id == entry.key);
                  return ListTile(
                    title: Text(book.title),
                    trailing: Text('${entry.value}x dipinjam'),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Manager Settings Page
class ManagerSettingsPage extends StatefulWidget {
  const ManagerSettingsPage({super.key});

  @override
  _ManagerSettingsPageState createState() => _ManagerSettingsPageState();
}

class _ManagerSettingsPageState extends State<ManagerSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pengaturan Sistem',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Masa Peminjaman (hari)'),
            subtitle: Text('${DataStore.maxLoanDays} hari'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(
                  context,
                  'Masa Peminjaman',
                  DataStore.maxLoanDays.toString(),
                  (value) {
                    setState(() {
                      DataStore.maxLoanDays = int.parse(value);
                    });
                  },
                );
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Denda Per Hari'),
            subtitle: Text('Rp ${DataStore.finePerDay.toStringAsFixed(0)}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(
                  context,
                  'Denda Per Hari',
                  DataStore.finePerDay.toString(),
                  (value) {
                    setState(() {
                      DataStore.finePerDay = double.parse(value);
                    });
                  },
                );
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Maksimal Buku Per Member'),
            subtitle: Text('${DataStore.maxBooksPerMember} buku'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(
                  context,
                  'Maksimal Buku',
                  DataStore.maxBooksPerMember.toString(),
                  (value) {
                    setState(() {
                      DataStore.maxBooksPerMember = int.parse(value);
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue,
      Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan berhasil diubah')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}