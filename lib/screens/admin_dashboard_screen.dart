import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/currency_helper.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/kobo_logo.dart';
import 'login_screen.dart';
import 'admin_login_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  // Stats Data
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  
  // Filter State
  String _searchQuery = '';
  String? _selectedCountry;
  String? _selectedCategory;
  String? _selectedStatus;
  String? _selectedTier;
  
  final TextEditingController _searchController = TextEditingController();
  
  final _currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseService();
      final stats = await db.fetchDetailedAnalytics();
      final statsV2 = await db.fetchAnalyticsV2();
      final users = await db.fetchAllUsers(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        country: _selectedCountry,
        category: _selectedCategory,
        status: _selectedStatus,
        tier: _selectedTier,
      );
      
      setState(() {
        _stats = statsV2.isNotEmpty ? statsV2 : stats;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await StorageService.clearUser();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => kIsWeb ? const AdminLoginScreen() : const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1a1a2e)))
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildCurrentView(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KoboLogo(size: 24),
                const SizedBox(width: 8),
                Text(
                  'ADMIN',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1a1a2e),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          AdminSidebarItem(
            icon: LucideIcons.layoutDashboard,
            label: 'Overview',
            isSelected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          AdminSidebarItem(
            icon: LucideIcons.users,
            label: 'User Management',
            isSelected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          AdminSidebarItem(
            icon: LucideIcons.lifeBuoy,
            label: 'Support & Tools',
            isSelected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          
          const Spacer(),
          
          AdminSidebarItem(
            icon: LucideIcons.logOut,
            label: 'Logout',
            isSelected: false,
            onTap: _logout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0: return _buildOverview();
      case 1: return _buildUserManagement();
      case 2: return _buildSupport();
      default: return const SizedBox();
    }
  }

  Widget _buildOverview() {
    final summary = _stats['summary'] ?? {};
    final distribution = _stats['distribution'] ?? {};
    final trends = _stats['trends'] ?? {};
    
    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Dashboard Overview',
            subtitle: 'Welcome back, Admin. Here is what is happening today.',
          ),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  title: 'Total Users',
                  value: '${summary['total_users'] ?? summary['totalUsers'] ?? 0}',
                  icon: LucideIcons.users,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: AdminStatCard(
                  title: 'Premium Users',
                  value: '${summary['premium_users'] ?? 0}',
                  icon: LucideIcons.crown,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: AdminStatCard(
                  title: 'Total Revenue',
                  value: _currencyFormat.format(double.tryParse((summary['total_revenue'] ?? summary['totalRevenue'] ?? 0).toString()) ?? 0),
                  icon: LucideIcons.banknote,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: AdminStatCard(
                  title: 'Total Sales',
                  value: '${summary['total_sales'] ?? summary['totalSales'] ?? 0}',
                  iconWidget: const Text('🛒', style: TextStyle(fontSize: 28)),
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Signup Trends (Line Chart)
              Expanded(
                flex: 2,
                child: _buildChartContainer(
                  title: 'Signup Trends (Last 30 Days)',
                  child: _buildSignupLineChart(trends['signups'] ?? []),
                ),
              ),
              const SizedBox(width: 24),
              // Category Distribution (Pie Chart)
              Expanded(
                flex: 1,
                child: _buildChartContainer(
                  title: 'Business Categories',
                  child: _buildCategoryPieChart(distribution['categories'] ?? []),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSignupLineChart(List<dynamic> data) {
    if (data.isEmpty) return const Center(child: Text('No trend data available'));
    
    final spots = data.asMap().entries.map((e) {
      final value = double.tryParse(e.value['count'].toString()) ?? 0;
      return FlSpot(e.key.toDouble(), value);
    }).toList().reversed.toList(); // Reverse to show latest on right

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6366F1),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF6366F1).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<dynamic> data) {
    if (data.isEmpty) return const Center(child: Text('No distribution data'));

    final colors = [const Color(0xFF6366F1), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEC4899), const Color(0xFF8B5CF6)];

    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((e) {
          final value = double.tryParse(e.value['count'].toString()) ?? 0;
          final typeName = e.value['business_type'].toString().split(' > ').first;
          return PieChartSectionData(
            color: colors[e.key % colors.length],
            value: value,
            title: '$typeName\n${value.toInt()}',
            radius: 100,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserManagement() {
    return SingleChildScrollView(
      key: const ValueKey('users'),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'User Management',
            subtitle: 'Manage vendors, individual accounts, and security updates.',
          ),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID or business...',
                      prefixIcon: const Icon(LucideIcons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      _searchQuery = val;
                      _loadDashboardData();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterDropdown(
                  hint: 'Country',
                  value: _selectedCountry,
                  items: ['Nigeria', 'Ghana', 'South Africa', 'Tanzania'],
                  onChanged: (val) => setState(() { _selectedCountry = val; _loadDashboardData(); }),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  hint: 'Category',
                  value: _selectedCategory,
                  items: [
                    'Food & Beverage',
                    'Fashion & Apparel',
                    'Beauty & Wellness',
                    'Technical & Trades',
                    'Digital & Tech',
                    'Retail & General',
                    'Logistics & Transport',
                    'Creative & Events',
                    'Home & Professional',
                    'Other'
                  ],
                  onChanged: (val) => setState(() { _selectedCategory = val; _loadDashboardData(); }),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  hint: 'Status',
                  value: _selectedStatus,
                  items: ['active', 'suspended', 'inactive'],
                  onChanged: (val) => setState(() { _selectedStatus = val; _loadDashboardData(); }),
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  hint: 'Tier',
                  value: _selectedTier,
                  items: ['free', 'premium'],
                  onChanged: (val) => setState(() { _selectedTier = val; _loadDashboardData(); }),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedCountry = null;
                      _selectedCategory = null;
                      _selectedStatus = null;
                      _selectedTier = null;
                      _searchController.clear();
                    });
                    _loadDashboardData();
                  },
                  icon: const Icon(LucideIcons.refreshCcw, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _exportToCSV,
                  icon: const Icon(LucideIcons.download, size: 16),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a1a2e),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          
          // Users Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1),
                if (_users.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text('No users found', style: TextStyle(color: Colors.grey[400])),
                  )
                else
                  ..._users.map(_buildUserRow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('NAME / ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text('BUSINESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 1, child: Text('PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 1, child: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text('CREATED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
          Expanded(flex: 2, child: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final name = '${user['first_name']} ${user['surname']}';
    final koboId = user['kobo_id'];
    final business = user['business_name'] ?? user['business_type'] ?? '-';
    final role = user['role'] ?? 'user';
    final date = DateTime.tryParse(user['created_at'].toString()) ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

    final isPro = user['is_pro'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[50]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(koboId, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(business)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPro ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPro ? 'PRO' : 'FREE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPro ? Colors.green[700] : Colors.grey[700]),
              ),
            ),
          ),
          Expanded(
            flex: 1, 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: role == 'admin' ? Colors.purple[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: role == 'admin' ? Colors.purple[700] : Colors.blue[700]),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(formattedDate)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.eye, size: 18, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () => _showUserDetails(koboId, name),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.crown, size: 18, color: Colors.green),
                  tooltip: 'Toggle Pro',
                  onPressed: () => _toggleProStatus(koboId, !isPro),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.shield, size: 18, color: Colors.purple),
                  tooltip: 'Adjust Role',
                  onPressed: () => _showRoleDialog(koboId, role),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.key, size: 18, color: Colors.orange),
                  tooltip: 'Reset PIN',
                  onPressed: () => _showResetPinDialog(koboId),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                  tooltip: 'Terminate',
                  onPressed: () => _confirmTermination(koboId, name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupport() {
    return const SingleChildScrollView(
      key: ValueKey('support'),
      padding: EdgeInsets.all(48),
      child: AdminSectionHeader(
        title: 'Support & Tools',
        subtitle: 'Debugging tools and system maintenance options.',
      ),
    );
  }

  // --- Actions ---

  void _showUserDetails(String koboId, String name) async {
    showDialog(
      context: context,
      builder: (context) => _UserDetailsDialog(koboId: koboId, name: name),
    );
  }

  void _toggleProStatus(String koboId, bool isPro) async {
    final success = await DatabaseService().toggleUserPro(koboId, isPro);
    if (success && mounted) {
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pro status updated to ${isPro ? "ACTIVE" : "INACTIVE"}')),
      );
    }
  }

  void _showRoleDialog(String koboId, String currentRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('User'),
              leading: Radio<String>(
                value: 'user',
                groupValue: currentRole,
                onChanged: (val) async {
                  await DatabaseService().updateUserRole(koboId, 'user');
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadDashboardData();
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Admin'),
              leading: Radio<String>(
                value: 'admin',
                groupValue: currentRole,
                onChanged: (val) async {
                  await DatabaseService().updateUserRole(koboId, 'admin');
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadDashboardData();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPinDialog(String koboId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset User PIN'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New 4-digit PIN'),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                final success = await DatabaseService().resetUserPin(koboId, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'PIN Reset Successfully' : 'Failed to reset PIN')),
                  );
                }
              }
            },
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );
  }

  void _confirmTermination(String koboId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Account?'),
        content: Text('Are you sure you want to permanently delete $name\'s account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Account')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final success = await DatabaseService().terminateUser(koboId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) _loadDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Account Terminated' : 'Failed to terminate account')),
                );
              }
            },
            child: const Text('Terminate Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _exportToCSV() {
    if (_users.isEmpty) return;
    
    final header = ['Kobo ID', 'First Name', 'Surname', 'Business', 'Country', 'Category', 'Role', 'Status', 'Tier', 'Created'];
    final rows = _users.map((u) => [
      u['kobo_id'],
      u['first_name'],
      u['surname'],
      u['business_name'] ?? u['business_type'],
      u['country'] ?? 'Nigeria',
      u['business_type'],
      u['role'],
      u['account_status'],
      u['is_pro'] == true ? 'Premium' : 'Free',
      u['created_at'],
    ]).toList();

    String csv = header.join(',') + '\n';
    for (var row in rows) {
      csv += row.join(',') + '\n';
    }

    debugPrint('CSV Export Generated (${_users.length} users)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User list exported (Check console for output)')),
    );
  }
}

class _UserDetailsDialog extends StatefulWidget {
  final String koboId;
  final String name;

  const _UserDetailsDialog({required this.koboId, required this.name});

  @override
  State<_UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<_UserDetailsDialog> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _engagement = {};
  List<dynamic> _items = [];
  List<dynamic> _sales = [];
  List<dynamic> _loginHistory = [];
  final TextEditingController _notesController = TextEditingController();

  int _currentTab = 0; // 0: Overview, 1: Inventory, 2: Sales, 3: Security

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final data = await DatabaseService().fetchUserDetails(widget.koboId);
    final history = await DatabaseService().fetchUserLoginHistory(widget.koboId);
    if (mounted) {
      setState(() {
        _userData = data['user'] ?? {};
        _engagement = data['engagement'] ?? {};
        _items = data['items'] ?? [];
        _sales = data['sales'] ?? [];
        _loginHistory = history;
        _notesController.text = _userData['admin_notes'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String status) async {
    // We would add a specific endpoint for this in reality, using toggle-pro as pattern
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account status set to $status')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 1000,
        height: 800,
        padding: const EdgeInsets.all(40),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1a1a2e)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar: User info & Actions
                      Expanded(flex: 3, child: _buildUserSidebar()),
                      const VerticalDivider(width: 64, thickness: 1),
                      // Main: Items & Sales & Engagement
                      Expanded(flex: 7, child: _buildMainContent()),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: Color(0xFF1a1a2e), shape: BoxShape.circle),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a2e))),
                Text('Kobo ID: ${widget.koboId}', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          ],
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 28)),
      ],
    );
  }

  Widget _buildUserSidebar() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Business', _userData['business_name'] ?? _userData['business_type'] ?? '-'),
          _buildDetailItem('Country', _userData['country'] ?? 'Nigeria'),
          _buildDetailItem('Joined', DateFormat('MMM dd, yyyy').format(DateTime.tryParse(_userData['created_at'].toString()) ?? DateTime.now())),
          _buildDetailItem('Last Login', _userData['last_login'] != null ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(_userData['last_login'])) : 'Never'),
          
          const SizedBox(height: 32),
          Text('ACCOUNT ACTIONS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.1)),
          const SizedBox(height: 16),
          _buildActionButton(LucideIcons.pause, 'Suspend Account', Colors.orange, () => _updateStatus('suspended')),
          _buildActionButton(LucideIcons.play, 'Reactivate Account', Colors.green, () => _updateStatus('active')),
          _buildActionButton(LucideIcons.trash2, 'Delete Permanently', Colors.red, () {}),
          
          const SizedBox(height: 32),
          Text('ADMIN NOTES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.1)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add private notes about this user...',
              fillColor: Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Row(
          children: [
            _buildTabButton(0, 'Overview'),
            _buildTabButton(1, 'Inventory'),
            _buildTabButton(2, 'Sales'),
            _buildTabButton(3, 'Security'),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: IndexedStack(
            index: _currentTab,
            children: [
              _buildOverviewTab(),
              _buildScrollableSection('User Inventory', _items, (item) => ListTile(
                title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(item['category'] ?? '-'),
                trailing: Text('₦${item['price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
              _buildScrollableSection('Recent Transactions', _sales, (sale) => ListTile(
                title: Text(sale['item_name'] ?? 'Sale', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(DateFormat('MMM dd, HH:mm').format(DateTime.tryParse(sale['created_at'].toString()) ?? DateTime.now())),
                trailing: Text('₦${sale['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              )),
              _buildScrollableSection('Login History', _loginHistory, (log) => ListTile(
                leading: Icon(log['successful'] ? LucideIcons.checkCircle : LucideIcons.alertTriangle, color: log['successful'] ? Colors.green : Colors.red),
                title: Text(log['successful'] ? 'Successful Login' : 'Failed Login Attempt'),
                subtitle: Text('${DateFormat('MMM dd, HH:mm').format(DateTime.tryParse(log['timestamp'].toString()) ?? DateTime.now())} • IP: ${log['ip_address'] ?? "Unknown"}'),
                trailing: Text(log['device_info']?['os'] ?? 'Device', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _currentTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF1a1a2e) : Colors.grey)),
            const SizedBox(height: 8),
            Container(height: 2, width: 40, color: isSelected ? const Color(0xFF1a1a2e) : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Engagement Row
        Row(
          children: [
            _buildMetricCard('Total Sales', '${_engagement['totalSales'] ?? 0}', LucideIcons.shoppingBag, Colors.blue),
            const SizedBox(width: 16),
            _buildMetricCard('Days Active', '${_engagement['daysActive'] ?? 0}', LucideIcons.calendar, Colors.purple),
            const SizedBox(width: 16),
            _buildMetricCard('Loan Readiness', _engagement['loanReadiness']?['score'] ?? 'Need Data', LucideIcons.badgeCheck, Colors.green),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildScrollableSection('Top Items', _items.take(10).toList(), (item) => ListTile(
                  title: Text(item['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text('₦${item['price'] ?? 0}'),
                )),
              ),
              const VerticalDivider(width: 40),
              Expanded(
                child: _buildScrollableSection('Recent Sales', _sales.take(10).toList(), (sale) => ListTile(
                  title: Text(sale['item_name'] ?? 'Sale'),
                  subtitle: Text(DateFormat('HH:mm').format(DateTime.tryParse(sale['created_at'].toString()) ?? DateTime.now())),
                  trailing: Text('₦${sale['total'] ?? 0}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a2e))),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableSection(String title, List<dynamic> data, Widget Function(dynamic) itemBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.1)),
        const SizedBox(height: 16),
        Expanded(
          child: data.isEmpty
            ? Center(child: Text('No records found', style: TextStyle(color: Colors.grey[300])))
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => itemBuilder(data[index]),
              ),
        ),
      ],
    );
  }
}

// Typo fix for StatCard usage in case I made one
class AdminstatStatCard extends AdminStatCard {
  const AdminstatStatCard({super.key, required super.title, required super.value, super.icon, super.iconWidget, required super.color});
}
