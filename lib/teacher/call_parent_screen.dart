
import 'package:flutter/material.dart';

import '../auth/auth_storage.dart';
import '../models/call_parent_model.dart';
import '../models/class_model.dart';
import '../models/section_model.dart';
import '../models/student_model.dart';
import '../services/call_parent_service.dart';
import '../services/student_service.dart';

class CallParentScreen extends StatefulWidget {
  const CallParentScreen({super.key});

  @override
  State<CallParentScreen> createState() => _CallParentScreenState();
}

class _CallParentScreenState extends State<CallParentScreen> {
  CallParentService? _service;
  StudentService? _studentService;

  List<ClassModel> _classes = [];
  List<SectionModel> _sections = [];
  List<CallParentModel> _students = [];
  List<CallParentModel> _filteredStudents = [];

  Map<int, Map<String, String>> _parentContacts = {};

  ClassModel? _selectedClass;
  SectionModel? _selectedSection;

  final TextEditingController _searchController =
      TextEditingController();

  bool _loading = true;
  bool _loadingSections = false;
  bool _loadingStudents = false;

  String? _error;

  static const Color _primary = Color(0xFF2457C5);
  static const Color _background = Color(0xFFF5F7FC);
  static const Color _textDark = Color(0xFF18243A);
  static const Color _textMuted = Color(0xFF778198);
  static const Color _green = Color(0xFF16A36A);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    _initialize();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found. Please log in again.');
      }

      final service = CallParentService(token: token);
      final studentService = StudentService(token);

      final results = await Future.wait([
        service.getClasses(),
        service.getParentContacts(),
      ]);

      if (!mounted) return;

      setState(() {
        _service = service;
        _studentService = studentService;
        _classes = results[0] as List<ClassModel>;
        _parentContacts =
            results[1] as Map<int, Map<String, String>>;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // CLASS SELECTION: LOAD ALL STUDENTS IN THE CLASS
  // ============================================================

  Future<void> _onClassChanged(ClassModel? value) async {
    if (value == null || _studentService == null || _service == null) {
      return;
    }

    setState(() {
      _selectedClass = value;
      _selectedSection = null;
      _sections = [];
      _students = [];
      _filteredStudents = [];
      _loadingSections = true;
      _loadingStudents = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service!.getSections(value.id),
        _studentService!.getStudentsByClassId(value.id),
      ]);

      if (!mounted) return;

      final sections = results[0] as List<SectionModel>;
      final studentModels = results[1] as List<StudentModel>;

      final students = studentModels.map(_toCallParentModel).toList();

      setState(() {
        _sections = sections;
        _students = students;
        _loadingSections = false;
        _loadingStudents = false;
      });

      _applySearch();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSections = false;
        _loadingStudents = false;
        _error = 'Unable to load class students: $e';
      });
    }
  }

  // ============================================================
  // SECTION SELECTION: FILTER THE CLASS STUDENTS
  // ============================================================

  void _onSectionChanged(SectionModel? value) {
    setState(() {
      _selectedSection = value;
    });

    // No section selected means all sections.
    _applySearch();
  }

  // ============================================================
  // MAP STUDENT MODEL TO CALL PARENT MODEL
  // ============================================================

  CallParentModel _toCallParentModel(StudentModel student) {
    final contact = _parentContacts[student.parentId];

    final parentPhone = _firstNonEmpty([
      contact?['contactPhone'],
      contact?['phone'],
      contact?['phoneNumber'],
    ]);

    final parentName = _firstNonEmpty([
      contact?['parentName'],
      contact?['fatherName'],
      contact?['motherName'],
      contact?['guardianName'],
      student.parentName,
    ]);

    return CallParentModel(
      studentId: student.id,
      studentName: student.name,
      admissionNo: student.admissionNo,
      parentId: student.parentId,
      parentName: parentName,
      parentPhone: parentPhone,
      classId: student.classId,
      className: student.className,
      sectionId: student.sectionId,
      sectionName: student.sectionName,
    );
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  // ============================================================
  // SEARCH AND SECTION FILTER
  // ============================================================

  void _applySearch() {
    if (!mounted) return;

    final query = _searchController.text.trim().toLowerCase();

    final filtered = _students.where((student) {
      final matchesQuery = query.isEmpty ||
          student.studentName.toLowerCase().contains(query) ||
          student.parentName.toLowerCase().contains(query) ||
          (student.parentPhone ?? '').toLowerCase().contains(query) ||
          (student.admissionNo ?? '').toLowerCase().contains(query);

      final matchesSection = _selectedSection == null ||
          student.sectionId == _selectedSection!.id;

      return matchesQuery && matchesSection;
    }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  // ============================================================
  // CALL PARENT
  // ============================================================

  Future<void> _callParent(CallParentModel student) async {
    final phone = student.parentPhone?.trim() ?? '';

    if (phone.isEmpty || !student.canCallParent) {
      _showMessage('Parent phone number is not available.');
      return;
    }

    try {
      await _service!.callParent(phone);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to open phone dialer.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call Parents',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Student contact directory',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFDCE7FF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _primary),
            )
          : _error != null && _service == null
              ? _buildInitialError()
              : _buildContent(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _initialize();

    if (!mounted) return;

    final selectedClass = _selectedClass;

    if (selectedClass != null) {
      await _onClassChanged(selectedClass);
    }
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHero(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              _buildSelectionCard(),
              const SizedBox(height: 12),
              if (_error != null) _buildInlineError(),
              if (_loadingStudents || _loadingSections)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              if (_selectedClass != null && !_loadingStudents) ...[
                _buildStudentSummary(),
                const SizedBox(height: 12),
                _buildSearchBox(),
                const SizedBox(height: 12),
                _buildStudentList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO HEADER
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.contact_phone_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Quick and easy access to parent contacts.',
                  style: TextStyle(
                    color: Color(0xFFDCE7FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLASS AND SECTION DROPDOWNS
  // ============================================================

  Widget _buildSelectionCard() {
    return Container(
      transform: Matrix4.translationValues(0, -8, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263B65).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: _primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Filter students',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel('CLASS'),
          const SizedBox(height: 7),
          DropdownButtonFormField<ClassModel>(
            value: _selectedClass,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: 'Choose a class',
              icon: Icons.school_outlined,
            ),
            items: _classes.map((item) {
              return DropdownMenuItem<ClassModel>(
                value: item,
                child: Text(item.name),
              );
            }).toList(),
            onChanged: _loadingStudents ? null : _onClassChanged,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _fieldLabel('SECTION'),
              const Spacer(),
              const Text(
                'OPTIONAL',
                style: TextStyle(
                  fontSize: 10,
                  color: _textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<SectionModel>(
            value: _selectedSection,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: _selectedClass == null
                  ? 'Select a class first'
                  : 'All sections',
              icon: Icons.groups_2_outlined,
            ),
            items: [
              const DropdownMenuItem<SectionModel>(
                value: null,
                child: Text('All sections'),
              ),
              ..._sections.map((item) {
                return DropdownMenuItem<SectionModel>(
                  value: item,
                  child: Text(item.name),
                );
              }),
            ],
            onChanged: _selectedClass == null ||
                    _loadingSections ||
                    _sections.isEmpty
                ? null
                : _onSectionChanged,
          ),
          if (_selectedClass != null) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: _textMuted,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'All sections are shown by default.',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary, size: 21),
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primary,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
        color: _textMuted,
      ),
    );
  }

  // ============================================================
  // STUDENT SUMMARY
  // ============================================================

  Widget _buildStudentSummary() {
    final withPhone = _filteredStudents.where((student) {
      return (student.parentPhone ?? '').trim().isNotEmpty &&
          student.canCallParent;
    }).length;

    return Row(
      children: [
        const Expanded(
          child: Text(
            'Parent directory',
            style: TextStyle(
              color: _textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _countChip(
          Icons.people_alt_outlined,
          '${_filteredStudents.length} students',
          _primary,
        ),
        const SizedBox(width: 6),
        _countChip(
          Icons.call_outlined,
          '$withPhone callable',
          _green,
        ),
      ],
    );
  }

  Widget _countChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBox() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search student, parent or phone...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _textMuted,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT CARDS
  // ============================================================

  Widget _buildStudentList() {
    if (_filteredStudents.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 35,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: Color(0xFFADB7CA),
            ),
            const SizedBox(height: 12),
            Text(
              _students.isEmpty
                  ? 'No students found for this class'
                  : 'No matching students found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Try another class, section or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredStudents.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];

        final parentName = student.parentName.trim().isEmpty
            ? 'Parent name unavailable'
            : student.parentName;

        final phone = student.parentPhone?.trim() ?? '';
        final hasPhone = phone.isNotEmpty && student.canCallParent;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFEBEFF6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF263B65).withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor(index),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  student.studentName.isEmpty
                      ? '?'
                      : student.studentName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Parent: $parentName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          hasPhone
                              ? Icons.phone_rounded
                              : Icons.phone_disabled_rounded,
                          size: 13,
                          color: hasPhone ? _green : _textMuted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            hasPhone ? phone : 'Phone unavailable',
                            style: TextStyle(
                              color: hasPhone ? _green : _textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (student.admissionNo?.isNotEmpty == true) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Admission No: ${student.admissionNo}',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (student.sectionName!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Section: ${student.sectionName}',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: hasPhone
                    ? _green.withValues(alpha: 0.11)
                    : const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _callParent(student),
                  child: SizedBox(
                    width: 43,
                    height: 43,
                    child: Icon(
                      Icons.call_rounded,
                      color: hasPhone ? _green : _textMuted,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFFE4EDFF),
      Color(0xFFE2F8ED),
      Color(0xFFFFEEDC),
      Color(0xFFF0E7FF),
      Color(0xFFFFE6ED),
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // ERRORS
  // ============================================================

  Widget _buildInlineError() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _error!,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInitialError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.red,
              size: 45,
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _initialize();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
