import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/homework_model.dart';
import '../models/section_model.dart';
import '../services/homework_service.dart';
import '../services/section_service.dart';

import '../auth/auth_storage.dart';

class HomeworkScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;
  final int? subjectId;

  const HomeworkScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
    this.subjectId,
  });

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String? token;
  int? teacherId;

  late HomeworkService homeworkService;
  late SectionService sectionService;

  List<SectionModel> sections = [];
  List<HomeworkModel> homeworkList = [];

  int? selectedSectionId;

  bool loadingSections = true;
  bool loadingHomework = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      token = await AuthStorage.getToken();
      teacherId = await AuthStorage.getTeacherId();

      if (token == null || teacherId == null) {
        throw Exception('Teacher session not found. Please login again.');
      }

      homeworkService = HomeworkService(token!);
      sectionService = SectionService(token!);

      await _loadSections();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSections = false;
      });

      _showMessage(e.toString());
    }
  }

  Future<void> _loadSections() async {
    try {
      final result = await sectionService.getSectionsByClassId(widget.classId);

      if (!mounted) return;

      setState(() {
        sections = result;
        loadingSections = false;

        if (sections.isNotEmpty) {
          selectedSectionId = sections.first.id;
        }
      });

      if (selectedSectionId != null) {
        await _loadHomework();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSections = false;
      });

      _showMessage(e.toString());
    }
  }

  Future<void> _loadHomework() async {
    if (selectedSectionId == null || teacherId == null) return;

    setState(() {
      loadingHomework = true;
    });

    try {
      final result = await homeworkService.getByTeacherClassAndSection(
        teacherId!,
        widget.classId,
        selectedSectionId!,
      );

      if (!mounted) return;

      setState(() {
        homeworkList = result;
        loadingHomework = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingHomework = false;
      });

      _showMessage(e.toString());
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';

    final parsed = DateTime.tryParse(date);

    if (parsed == null) return date;

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} '
        '${parsed.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  Future<void> _pickSection(int id) async {
    if (selectedSectionId == id) return;

    setState(() {
      selectedSectionId = id;
    });

    await _loadHomework();
  }

  Future<void> _showAddHomework() async {
    await _showHomeworkForm();
  }

  Future<void> _showEditHomework(HomeworkModel homework) async {
    await _showHomeworkForm(homework: homework);
  }

  Future<void> _showHomeworkForm({HomeworkModel? homework}) async {
    final titleController = TextEditingController(text: homework?.title ?? '');

    final descriptionController = TextEditingController(
      text: homework?.description ?? '',
    );

    final attachmentController = TextEditingController(
      text: homework?.attachmentUrl ?? '',
    );

    DateTime selectedDate = homework?.dueDate != null
        ? DateTime.tryParse(homework!.dueDate!) ?? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));

    String selectedPriority = homework?.priority ?? 'MEDIUM';
    String selectedStatus = homework?.status ?? 'ACTIVE';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      homework == null ? 'Create Homework' : 'Edit Homework',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${widget.className} - Section ${_selectedSectionName()}',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 20),

                    _field(controller: titleController, hint: 'Homework title'),

                    const SizedBox(height: 12),

                    _field(
                      controller: descriptionController,
                      hint: 'Description',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Due Date',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.isBefore(DateTime.now())
                              ? DateTime.now()
                              : selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setSheetState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xff1565C0),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatDate(selectedDate.toIso8601String()),
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: _dropdownDecoration('Priority'),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Low')),
                        DropdownMenuItem(
                          value: 'MEDIUM',
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(value: 'HIGH', child: Text('High')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: _dropdownDecoration('Status'),
                      items: const [
                        DropdownMenuItem(
                          value: 'ACTIVE',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'COMPLETED',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'CANCELLED',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller: attachmentController,
                      hint: 'Attachment URL (optional)',
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            _showMessage('Please enter homework title');
                            return;
                          }

                          if (selectedSectionId == null || teacherId == null) {
                            _showMessage(
                              'Section or teacher information missing',
                            );
                            return;
                          }

                          final dueDate =
                              '${selectedDate.year}-'
                              '${selectedDate.month.toString().padLeft(2, '0')}-'
                              '${selectedDate.day.toString().padLeft(2, '0')}';

                          try {
                            Navigator.pop(sheetContext);

                            if (homework == null) {
                              await homeworkService.createHomework(
                                classId: widget.classId,
                                sectionId: selectedSectionId!,
                                teacherId: teacherId!,
                                subjectId: widget.subjectId,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                dueDate: dueDate,
                                status: selectedStatus,
                                attachmentUrl:
                                    attachmentController.text.trim().isEmpty
                                    ? null
                                    : attachmentController.text.trim(),
                                priority: selectedPriority,
                              );
                            } else {
                              await homeworkService.updateHomework(
                                id: homework.id!,
                                classId: widget.classId,
                                sectionId: selectedSectionId!,
                                teacherId: teacherId!,
                                subjectId:
                                    homework.subjectId ?? widget.subjectId,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                dueDate: dueDate,
                                status: selectedStatus,
                                attachmentUrl:
                                    attachmentController.text.trim().isEmpty
                                    ? null
                                    : attachmentController.text.trim(),
                                priority: selectedPriority,
                              );
                            }

                            await _loadHomework();

                            if (!mounted) return;

                            _showMessage(
                              homework == null
                                  ? 'Homework created successfully'
                                  : 'Homework updated successfully',
                            );
                          } catch (e) {
                            _showMessage(e.toString());
                          }
                        },
                        child: Text(
                          homework == null
                              ? 'Publish Homework'
                              : 'Update Homework',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _selectedSectionName() {
    for (final section in sections) {
      if (section.id == selectedSectionId) {
        return section.name;
      }
    }

    return '';
  }

  Future<void> _deleteHomework(HomeworkModel homework) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Homework'),
          content: Text('Delete "${homework.title ?? 'this homework'}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || homework.id == null) return;

    try {
      await homeworkService.deleteHomework(homework.id!);
      await _loadHomework();

      _showMessage('Homework deleted successfully');
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Homework',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: selectedSectionId == null ? null : _showAddHomework,
          ),
        ],
      ),

      body: loadingSections
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.className,
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.subject,
                    style: GoogleFonts.poppins(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'Select Section',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: sections.map((section) {
                        final selected = section.id == selectedSectionId;

                        return GestureDetector(
                          onTap: () => _pickSection(section.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xff1565C0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xff1565C0)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              section.name,
                              style: GoogleFonts.poppins(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Assigned Homework',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: loadingHomework
                        ? const Center(child: CircularProgressIndicator())
                        : homeworkList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.menu_book_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No homework for this section',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _showAddHomework,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Homework'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHomework,
                            child: ListView.builder(
                              itemCount: homeworkList.length,
                              itemBuilder: (context, index) {
                                return _homeworkCard(homeworkList[index]);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),

      floatingActionButton: selectedSectionId == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xff1565C0),
              onPressed: _showAddHomework,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Homework',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
    );
  }

  Widget _homeworkCard(HomeworkModel homework) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Color(0xffE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book, color: Color(0xff1565C0)),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homework.title ?? 'Untitled',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      homework.subjectName ?? widget.subject,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditHomework(homework);
                  } else if (value == 'delete') {
                    _deleteHomework(homework);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          _detailRow(
            Icons.school,
            '${homework.className ?? widget.className}'
            ' - ${homework.sectionName ?? _selectedSectionName()}',
          ),

          _detailRow(
            Icons.calendar_month,
            'Due: ${_formatDate(homework.dueDate)}',
          ),

          _detailRow(Icons.flag, 'Priority: ${homework.priority ?? '-'}'),

          _detailRow(Icons.info_outline, 'Status: ${homework.status ?? '-'}'),

          if ((homework.description ?? '').isNotEmpty)
            _detailRow(Icons.notes, homework.description!),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xff1565C0)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
