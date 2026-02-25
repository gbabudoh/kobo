import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  // PIN Controllers
  final List<TextEditingController> _createPinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _createPinFocusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _confirmPinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _confirmPinFocusNodes = List.generate(4, (_) => FocusNode());

  String _selectedCountry = 'Nigeria';
  final List<String> _countries = [
    'Nigeria', 'Ghana', 'South Africa', 'Liberia', 'Tanzania', 'Zambia', 'Namibia'
  ];

  // Step 2 Selection
  String? _selectedCategory;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': LucideIcons.utensils},
    {'name': 'Tailor', 'icon': LucideIcons.scissors},
    {'name': 'Hair', 'icon': LucideIcons.scissors}, // Lucide doesn't have a direct hair icon, scissors works or user generic
    {'name': 'Mechanic', 'icon': LucideIcons.wrench},
    {'name': 'Shop', 'icon': LucideIcons.shoppingBag},
    {'name': 'Other', 'icon': LucideIcons.moreHorizontal},
  ];

  // State for generated ID
  String? _generatedKoboId;
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    for (var c in _createPinControllers) {
      c.dispose();
    }
    for (var f in _createPinFocusNodes) {
      f.dispose();
    }
    for (var c in _confirmPinControllers) {
      c.dispose();
    }
    for (var f in _confirmPinFocusNodes) {
      f.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _createAccount() async {
    setState(() => _isCreatingAccount = true);

    // Simulate network/generation delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final randomId = (Random().nextInt(9000) + 1000).toString();
    final koboId = 'KOBO-$randomId';
    final pin = _createPinControllers.map((c) => c.text).join();

    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerName: _nameController.text.trim(),
      shopName: _businessNameController.text.trim(),
      phoneNumber: '', // Not collected in new flow
      state: '', // Not collected in new flow
      city: '', // Not collected in new flow
      businessType: _selectedCategory!,
      country: _selectedCountry,
      pin: pin,
      koboId: koboId,
      createdAt: DateTime.now(),
    );

    await StorageService.saveProfile(profile);

    if (context.mounted) {
      setState(() {
        _generatedKoboId = koboId;
        _isCreatingAccount = false;
        _currentPage = 2; // Move to Welcome screen
      });
      _pageController.jumpToPage(2);
    }
  }

  void _copyToClipboard() {
    if (_generatedKoboId != null) {
      Clipboard.setData(ClipboardData(text: _generatedKoboId!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kobo ID copied!", style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFF27ae60),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // --- Validation ---

  bool get _isPinCreatedComplete => _createPinControllers.every((c) => c.text.isNotEmpty);
  bool get _isPinConfirmComplete => _confirmPinControllers.every((c) => c.text.isNotEmpty);
  bool get _doPinsMatch {
    if (!_isPinCreatedComplete || !_isPinConfirmComplete) return false;
    final create = _createPinControllers.map((c) => c.text).join();
    final confirm = _confirmPinControllers.map((c) => c.text).join();
    return create == confirm;
  }

  bool get _isStep1Valid => 
    _nameController.text.isNotEmpty && 
    _doPinsMatch;

  bool get _isStep2Valid => _selectedCategory != null;

  // --- Widget Builders ---

  void _onPinChanged(int index, String value, List<FocusNode> nodes, List<TextEditingController> controllers) {
      if (value.isNotEmpty && index < 3) {
        nodes[index + 1].requestFocus();
      } else if (value.isEmpty && index > 0) {
        nodes[index - 1].requestFocus();
      }
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (_currentPage < 2) _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          bool isActive = index <= _currentPage;
          bool isCurrent = index == _currentPage;
          return AnimatedContainer(
            duration: 400.ms,
            height: 6,
            width: isCurrent ? 32 : 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF27ae60) : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScreenTitle("Let's get started", "Create your account to start selling."),
          
          const SizedBox(height: 32),

          // Country Dropdown
          _buildLabel("COUNTRY"),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, color: Color(0xFF94A3B8)),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCountry = val!),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Name
          _buildLabel("FIRST NAME / SURNAME"),
          _buildTextField(_nameController, "Enter your full name", LucideIcons.user),

          const SizedBox(height: 24),

          // Business Name
          _buildLabel("BUSINESS NAME (OPTIONAL)"),
          _buildTextField(_businessNameController, "e.g. My Shop", LucideIcons.store),

          const SizedBox(height: 32),

          Center(child: Text("Create Security PIN", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          // PIN Create
          _buildLabel("CREATE 4-DIGIT PIN"),
          _buildPinRow(_createPinControllers, _createPinFocusNodes),
          
          const SizedBox(height: 16),

          // PIN Confirm
          _buildLabel("CONFIRM PIN"),
          _buildPinRow(_confirmPinControllers, _confirmPinFocusNodes),

          const SizedBox(height: 48),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isStep1Valid ? _nextPage : null,
              style: _buttonStyle(isValid: _isStep1Valid),
              child: Text("CONTINUE", style: _buttonTextStyle(isValid: _isStep1Valid)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: _buildScreenTitle("What do you do?", "Select the category that best describes your business."),
        ),
        
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];
              return InkWell(
                onTap: () => setState(() => _selectedCategory = cat['name']),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF27ae60) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF27ae60) : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF27ae60).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'],
                        size: 32,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cat['name'],
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isStep2Valid && !_isCreatingAccount ? _createAccount : null,
              style: _buttonStyle(isValid: _isStep2Valid),
              child: _isCreatingAccount 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text("CREATE ACCOUNT", style: _buttonTextStyle(isValid: _isStep2Valid)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27ae60).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(LucideIcons.partyPopper, color: Color(0xFF27ae60), size: 48),
          ).animate().scale(curve: Curves.elasticOut),
          
          const SizedBox(height: 32),

          Text(
            "Your account is ready!",
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),

          Text(
            "Write this down or screenshot it.\nYou'll need it to log in.",
            style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF64748B), height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(
                  "YOUR KOBO ID",
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  _generatedKoboId ?? "ERROR",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(LucideIcons.copy, size: 16),
                    label: const Text("Copy ID"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF27ae60),
                      side: const BorderSide(color: Color(0xFF27ae60)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).scale(),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ENTER KOBO", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight, size: 20),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildScreenTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2)),
      ),
    );
  }

  Widget _buildPinRow(List<TextEditingController> controllers, List<FocusNode> nodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          height: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: nodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: true,
            obscuringCharacter: '●',
            onChanged: (val) => _onPinChanged(index, val, nodes, controllers),
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
             decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF27ae60), width: 2)),
              contentPadding: EdgeInsets.zero,
            ),
             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        );
      }),
    );
  }

  ButtonStyle _buttonStyle({required bool isValid}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isValid ? const Color(0xFF27ae60) : const Color(0xFFE2E8F0),
      foregroundColor: isValid ? Colors.white : const Color(0xFF94A3B8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      disabledBackgroundColor: const Color(0xFFE2E8F0),
      disabledForegroundColor: const Color(0xFF94A3B8),
    );
  }

  TextStyle _buttonTextStyle({required bool isValid}) {
    return GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isValid ? Colors.white : const Color(0xFF94A3B8),
      letterSpacing: 1.5,
    );
  }
}
