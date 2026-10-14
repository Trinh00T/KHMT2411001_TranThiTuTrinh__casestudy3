import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isExpense = true;
  String _category = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  static const Color _red = Color(0xFFFF503F);
  static const Color _purple = Color(0xFF5949F5);

  final List<String> _categories = [
    'Ăn uống',
    'Di chuyển',
    'Tiền lương',
    'Mua sắm',
    'Học tập',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.transaction;

    _category = (data['category'] ?? 'Ăn uống').toString();
    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }

    _isExpense = (data['isExpense'] ?? 1).toString() == '1';

    _amountController.text =
        (data['amount'] ?? '').toString();

    _noteController.text =
        (data['note'] ?? '').toString();

    final dateValue = data['date']?.toString();
    if (dateValue != null) {
      _selectedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.transaction['id'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy mã giao dịch cần sửa.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(
        _amountController.text.trim().replaceAll(',', ''),
      );

      await DatabaseHelper.instance.updateTransaction(
        id as int,
        {
          'title': _category,
          'amount': amount,
          'note': _noteController.text.trim(),
          'category': _category,
          'date': _selectedDate.toIso8601String(),
          'isExpense': _isExpense ? 1 : 0,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật giao dịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật giao dịch: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E5EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE1E5EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF28334D),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF28334D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: Color(0xFF28334D),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      text: 'Chi tiêu',
                      selected: _isExpense,
                      onTap: () => setState(() => _isExpense = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeButton(
                      text: 'Thu nhập',
                      selected: !_isExpense,
                      onTap: () => setState(() => _isExpense = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _label('Danh mục'),
              DropdownButtonFormField<String>(
                  initialValue: _category,
                decoration: _decoration(
                  hint: 'Chọn danh mục',
                  prefixIcon: const Icon(Icons.restaurant, color: _red),
                ),
                items: _categories
                    .map(
                      (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 20),
              _label('Số tiền'),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(
                  hint: 'Nhập số tiền',
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('₫'),
                  ),
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', ''),
                  );

                  if (amount == null || amount <= 0) {
                    return 'Vui lòng nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _label('Ngày giao dịch'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: _decoration(
                    hint: 'Chọn ngày',
                    suffixIcon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF65718A),
                    ),
                  ),
                  child: Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF28334D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Ghi chú'),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? _red : Colors.white,
          foregroundColor:
          selected ? Colors.white : const Color(0xFF28334D),
          side: BorderSide(
            color: selected ? _red : const Color(0xFFE1E5EF),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}