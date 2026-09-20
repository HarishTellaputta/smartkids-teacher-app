import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/assignment_model.dart';
import '../models/section_model.dart';
import '../services/assignment_service.dart';
import '../services/section_service.dart';
import '../auth/auth_storage.dart';

class AssignmentsScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;
  final int? subjectId;

  const AssignmentsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
    this.subjectId,
  });

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String? token;
  int? teacherId;

  late AssignmentService assignmentService;
  late SectionService sectionService;

  List<SectionModel> sections = [];
  List<AssignmentModel> assignments = [];

  int? selectedSectionId;

  bool loadingSections = true;
  bool loadingAssignments = false;

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

      assignmentService = AssignmentService(token!);
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
        await _loadAssignments();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSections = false;
      });

      _showMessage(e.toString());
    }
  }

  Future<void> _loadAssignments() async {
    if (selectedSectionId == null) return;

    setState(() {
      loadingAssignments = true;
    });

    try {
      final result = await assignmentService.getByClassAndSection(
        widget.classId,
        selectedSectionId!,
      );

      if (!mounted) return;

      setState(() {
        assignments = result;
        loadingAssignments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingAssignments = false;
      });

      _showMessage(e.toString());
    }
  }

  Future<void> _pickSection(int id) async {
    if (selectedSectionId == id) return;

    setState(() {
      selectedSectionId = id;
    });

    await _loadAssignments();
  }

  String _selectedSectionName() {
    for (final section in sections) {
      if (section.id == selectedSectionId) {
        return section.name;
      }
    }

    return '';
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

  Future<void> _showCreateAssignment() async {
    await _showAssignmentForm();
  }

  Future<void> _showEditAssignment(AssignmentModel assignment) async {
    await _showAssignmentForm(assignment: assignment);
  }

  Future<void> _showAssignmentForm({AssignmentModel? assignment}) async {
    final titleController = TextEditingController(
      text: assignment?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: assignment?.description ?? '',
    );

    final attachmentController = TextEditingController(
      text: assignment?.attachmentUrl ?? '',
    );

    final marksController = TextEditingController(
      text: assignment?.maxMarks?.toString() ?? '',
    );

    DateTime assignedDate = assignment?.assignedDate != null
        ? DateTime.tryParse(assignment!.assignedDate!) ?? DateTime.now()
        : DateTime.now();

    DateTime dueDate = assignment?.dueDate != null
        ? DateTime.tryParse(assignment!.dueDate!) ??
              DateTime.now().add(const Duration(days: 1))
        : DateTime.now().add(const Duration(days: 1));

    if (dueDate.isBefore(DateTime.now())) {
      dueDate = DateTime.now();
    }

    String selectedPriority = assignment?.priority ?? 'MEDIUM';

    String selectedStatus = assignment?.status ?? 'ASSIGNED';

    String selectedSubmissionType = assignment?.submissionType ?? 'ONLINE';

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
                      assignment == null
                          ? 'Create Assignment'
                          : 'Edit Assignment',
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

                    _field(
                      controller: titleController,
                      hint: 'Assignment title',
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller: descriptionController,
                      hint: 'Description',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 12),

                    _datePickerField(
                      context: context,
                      label: 'Assigned Date',
                      date: assignedDate,
                      minimum: DateTime(2000),
                      onChanged: (value) {
                        setSheetState(() {
                          assignedDate = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _datePickerField(
                      context: context,
                      label: 'Due Date',
                      date: dueDate,
                      minimum: DateTime.now(),
                      onChanged: (value) {
                        setSheetState(() {
                          dueDate = value;
                        });
                      },
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
                          value: 'ASSIGNED',
                          child: Text('Assigned'),
                        ),
                        DropdownMenuItem(
                          value: 'SUBMITTED',
                          child: Text('Submitted'),
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

                    DropdownButtonFormField<String>(
                      value: selectedSubmissionType,
                      decoration: _dropdownDecoration('Submission Type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'ONLINE',
                          child: Text('Online'),
                        ),
                        DropdownMenuItem(
                          value: 'OFFLINE',
                          child: Text('Offline'),
                        ),
                        DropdownMenuItem(
                          value: 'BOTH',
                          child: Text('Online + Offline'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            selectedSubmissionType = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    _field(
                      controller: marksController,
                      hint: 'Maximum Marks',
                      keyboardType: TextInputType.number,
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
                            _showMessage('Please enter assignment title');
                            return;
                          }

                          if (selectedSectionId == null || teacherId == null) {
                            _showMessage(
                              'Section or teacher information missing',
                            );
                            return;
                          }

                          if (dueDate.isBefore(assignedDate)) {
                            _showMessage(
                              'Due date cannot be before assigned date',
                            );
                            return;
                          }

                          final assignedDateString =
                              '${assignedDate.year}-'
                              '${assignedDate.month.toString().padLeft(2, '0')}-'
                              '${assignedDate.day.toString().padLeft(2, '0')}';

                          final dueDateString =
                              '${dueDate.year}-'
                              '${dueDate.month.toString().padLeft(2, '0')}-'
                              '${dueDate.day.toString().padLeft(2, '0')}';

                          final maxMarks = int.tryParse(
                            marksController.text.trim(),
                          );

                          try {
                            Navigator.pop(sheetContext);

                            if (assignment == null) {
                              await assignmentService.createAssignment(
                                classId: widget.classId,
                                sectionId: selectedSectionId!,
                                teacherId: teacherId!,
                                subjectId: widget.subjectId,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                assignedDate: assignedDateString,
                                dueDate: dueDateString,
                                status: selectedStatus,
                                attachmentUrl:
                                    attachmentController.text.trim().isEmpty
                                    ? null
                                    : attachmentController.text.trim(),
                                priority: selectedPriority,
                                submissionType: selectedSubmissionType,
                                maxMarks: maxMarks,
                              );
                            } else {
                              await assignmentService.updateAssignment(
                                id: assignment.id!,
                                classId: widget.classId,
                                sectionId: selectedSectionId!,
                                teacherId: teacherId!,
                                subjectId:
                                    assignment.subjectId ?? widget.subjectId,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                assignedDate: assignedDateString,
                                dueDate: dueDateString,
                                status: selectedStatus,
                                attachmentUrl:
                                    attachmentController.text.trim().isEmpty
                                    ? null
                                    : attachmentController.text.trim(),
                                priority: selectedPriority,
                                submissionType: selectedSubmissionType,
                                maxMarks: maxMarks,
                              );
                            }

                            await _loadAssignments();

                            if (!mounted) return;

                            _showMessage(
                              assignment == null
                                  ? 'Assignment created successfully'
                                  : 'Assignment updated successfully',
                            );
                          } catch (e) {
                            _showMessage(e.toString());
                          }
                        },
                        child: Text(
                          assignment == null ? 'Publish' : 'Update Assignment',
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _datePickerField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required DateTime minimum,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final initial = date.isBefore(minimum) ? minimum : date;

        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: minimum,
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xff1565C0)),
            const SizedBox(width: 12),
            Text(
              '$label: ${_formatDate(date.toIso8601String())}',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAssignment(AssignmentModel assignment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text('Delete "${assignment.title ?? 'this assignment'}"?'),
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

    if (shouldDelete != true || assignment.id == null) return;

    try {
      await assignmentService.deleteAssignment(assignment.id!);

      await _loadAssignments();

      _showMessage('Assignment deleted successfully');
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
          'Assignments',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                    'My Assignments',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: loadingAssignments
                        ? const Center(child: CircularProgressIndicator())
                        : assignments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.assignment_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No assignments for this section',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _showCreateAssignment,
                                  icon: const Icon(Icons.add),
                                  label: const Text('New Assignment'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAssignments,
                            child: ListView.builder(
                              itemCount: assignments.length,
                              itemBuilder: (context, index) {
                                return _assignmentCard(assignments[index]);
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
              onPressed: _showCreateAssignment,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'New Assignment',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
    );
  }

  Widget _assignmentCard(AssignmentModel assignment) {
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
                child: const Icon(Icons.assignment, color: Color(0xff1565C0)),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title ?? 'Untitled',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      assignment.subjectName ?? widget.subject,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditAssignment(assignment);
                  } else if (value == 'delete') {
                    _deleteAssignment(assignment);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          _detailRow(
            Icons.school,
            '${assignment.className ?? widget.className}'
            ' - ${assignment.sectionName ?? _selectedSectionName()}',
          ),

          _detailRow(
            Icons.calendar_month,
            'Due Date: ${_formatDate(assignment.dueDate)}',
          ),

          _detailRow(Icons.flag, 'Priority: ${assignment.priority ?? '-'}'),

          _detailRow(
            Icons.upload_file,
            'Submission: ${assignment.submissionType ?? '-'}',
          ),

          _detailRow(
            Icons.star_outline,
            'Max Marks: ${assignment.maxMarks?.toString() ?? '-'}',
          ),

          _detailRow(Icons.info_outline, 'Status: ${assignment.status ?? '-'}'),

          if ((assignment.description ?? '').isNotEmpty)
            _detailRow(Icons.notes, assignment.description!),
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
