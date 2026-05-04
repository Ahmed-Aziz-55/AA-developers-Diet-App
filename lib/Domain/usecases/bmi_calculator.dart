import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'generate_diet_plan.dart';

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<BmiCalculator> {
  final _pageController = PageController();
  int _pageIndex = 0;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final fullName = TextEditingController();
  final age = TextEditingController();

  // Height & weight as int/double state (not text controllers)
  int _heightCm = 170;
  double _weightKg = 70.0;

  String? gender;
  String? activityLevel;
  String? goalType;

  bool _isSaving = false;

  // ── navigation ──────────────────────────────────────────────
  void _nextPage() {
    final isValid = _getCurrentFormKey().currentState?.validate() ?? false;
    if (!isValid) return;

    if (_pageIndex < 2) {
      setState(() => _pageIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    if (_pageIndex > 0) {
      setState(() => _pageIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  GlobalKey<FormState> _getCurrentFormKey() {
    if (_pageIndex == 0) return _formKey1;
    if (_pageIndex == 1) return _formKey2;
    return _formKey3;
  }

  // ── save ────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showCenterSnackBar('Please login first', isError: true);
        return;
      }

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': fullName.text.trim(),
        'age': int.tryParse(age.text.trim()),
        'height_cm': _heightCm.toDouble(),
        'current_weight_kg': _weightKg,
        'gender': gender?.toLowerCase(),
        'activity_level': activityLevel?.toLowerCase(),
        'goal_type': goalType?.toLowerCase(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PreparingPlanScreen()),
      );
    } catch (e) {
      if (mounted) {
        _showCenterSnackBar('Save failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── snack bar ───────────────────────────────────────────────
  void _showCenterSnackBar(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  // ── build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text(
          'Profile Setup',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF77DD77),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _StepProgressBar(current: _pageIndex, total: 3),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _step1(),
                _step2(),
                _step3(),
              ],
            ),
          ),
          _BottomNavBar(
            pageIndex: _pageIndex,
            isSaving: _isSaving,
            onBack: _prevPage,
            onNext: _nextPage,
          ),
        ],
      ),
    );
  }

  // ── Step 1 : Basic Info ──────────────────────────────────────
  Widget _step1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Basic Info',
              subtitle: 'Tell us a bit about yourself',
            ),
            const SizedBox(height: 24),
            _AppTextField(
              controller: fullName,
              label: 'Full Name',
              icon: Icons.badge_outlined,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: age,
              label: 'Age',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your age';
                final n = int.tryParse(v);
                if (n == null || n < 5 || n > 120) return 'Enter a valid age';
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _GenderSelector(
              selected: gender,
              onChanged: (v) => setState(() => gender = v),
            ),
            FormField<String>(
              validator: (_) => gender == null ? 'Select gender' : null,
              builder: (state) => state.hasError
                  ? Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style:
                  const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2 : Body Details ────────────────────────────────────
  Widget _step2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.straighten_rounded,
              title: 'Body Details',
              subtitle: 'Used to calculate your BMR accurately',
            ),
            const SizedBox(height: 28),
            const _FieldLabel(text: 'Height'),
            const SizedBox(height: 12),
            _RulerHeightPicker(
              value: _heightCm,
              onChanged: (v) => setState(() => _heightCm = v),
            ),
            const SizedBox(height: 32),
            const _FieldLabel(text: 'Weight'),
            const SizedBox(height: 12),
            _DrumRollWeightPicker(
              value: _weightKg,
              onChanged: (v) => setState(() => _weightKg = v),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3 : Goal & Activity ─────────────────────────────────
  Widget _step3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.flag_outlined,
              title: 'Goal & Activity',
              subtitle: 'We\'ll personalise your plan',
            ),
            const SizedBox(height: 28),
            const _FieldLabel(text: 'Your Goal'),
            const SizedBox(height: 12),
            _GoalSelector(
              selected: goalType,
              onChanged: (v) => setState(() => goalType = v),
            ),
            FormField<String>(
              validator: (_) => goalType == null ? 'Select your goal' : null,
              builder: (state) => state.hasError
                  ? Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),
            const _FieldLabel(text: 'Activity Level'),
            const SizedBox(height: 12),
            _ActivitySelector(
              selected: activityLevel,
              onChanged: (v) => setState(() => activityLevel = v),
            ),
            FormField<String>(
              validator: (_) =>
              activityLevel == null ? 'Select activity level' : null,
              builder: (state) => state.hasError
                  ? Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Height picker
// ─────────────────────────────────────────────────────────────
class _RulerHeightPicker extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _RulerHeightPicker({required this.value, required this.onChanged});

  @override
  State<_RulerHeightPicker> createState() => _RulerHeightPickerState();
}

class _RulerHeightPickerState extends State<_RulerHeightPicker> {
  static const int _min = 120;
  static const int _max = 220;
  static const double _itemWidth = 18.0;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final offset = (widget.value - _min) * _itemWidth;
    _scrollController = ScrollController(initialScrollOffset: offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollEnd() {
    final offset = _scrollController.offset;
    final index = (offset / _itemWidth).round().clamp(0, _max - _min);
    final snappedOffset = index * _itemWidth;
    if (_scrollController.offset != snappedOffset) {
      _scrollController.animateTo(
        snappedOffset,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
    final newVal = _min + index;
    if (newVal != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final halfScreen = (screenW - 40) / 2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${widget.value}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'cm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF77DD77),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                NotificationListener<ScrollEndNotification>(
                  onNotification: (_) {
                    _onScrollEnd();
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: halfScreen),
                    itemCount: _max - _min + 1,
                    itemExtent: _itemWidth,
                    itemBuilder: (context, index) {
                      final val = _min + index;
                      final isMajor = val % 10 == 0;
                      final isMid = val % 5 == 0 && !isMajor;
                      final tickH = isMajor ? 40.0 : isMid ? 26.0 : 16.0;
                      final color = val == widget.value
                          ? const Color(0xFF77DD77)
                          : isMajor
                          ? const Color(0xFF374151)
                          : const Color(0xFFD1D5DB);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMajor)
                            Text(
                              '$val',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: val == widget.value
                                    ? const Color(0xFF77DD77)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          if (!isMajor) const SizedBox(height: 13),
                          const SizedBox(height: 2),
                          Container(
                            width: isMajor ? 2.5 : 1.5,
                            height: tickH,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 2,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF77DD77),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Weight picker
// ─────────────────────────────────────────────────────────────
class _DrumRollWeightPicker extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _DrumRollWeightPicker({required this.value, required this.onChanged});

  @override
  State<_DrumRollWeightPicker> createState() => _DrumRollWeightPickerState();
}

class _DrumRollWeightPickerState extends State<_DrumRollWeightPicker> {
  static const double _minW = 30;
  static const double _maxW = 150;
  static const double _step = 0.5;
  static const double _itemH = 44.0;
  static const int _visibleCount = 5;

  late FixedExtentScrollController _ctrl;

  int _valueToIndex(double v) =>
      ((v - _minW) / _step).round().clamp(0, ((_maxW - _minW) / _step).round());

  double _indexToValue(int i) => _minW + i * _step;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: _valueToIndex(widget.value));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = ((_maxW - _minW) / _step).round() + 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.value % 1 == 0
                          ? widget.value.toInt().toString()
                          : widget.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF77DD77),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BmiHint(weight: widget.value),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            height: _itemH * _visibleCount,
            child: Stack(
              children: [
                ListWheelScrollView.useDelegate(
                  controller: _ctrl,
                  itemExtent: _itemH,
                  diameterRatio: 1.8,
                  perspective: 0.003,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    HapticFeedback.selectionClick();
                    widget.onChanged(_indexToValue(i));
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index >= totalItems) return null;
                      final v = _indexToValue(index);
                      final isSelected = v == widget.value;
                      return Center(
                        child: Text(
                          v % 1 == 0
                              ? v.toInt().toString()
                              : v.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: isSelected ? 22 : 16,
                            fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF77DD77)
                                : const Color(0xFFADB5BD),
                          ),
                        ),
                      );
                    },
                    childCount: totalItems,
                  ),
                ),
                Positioned(
                  top: _itemH * ((_visibleCount - 1) / 2),
                  left: 0,
                  right: 0,
                  height: _itemH,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF77DD77).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF77DD77).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiHint extends StatelessWidget {
  final double weight;
  const _BmiHint({required this.weight});

  @override
  Widget build(BuildContext context) {
    final bmi = weight / (1.70 * 1.70);
    String label;
    Color color;

    if (bmi < 18.5) {
      label = 'Underweight';
      color = const Color(0xFF3B82F6);
    } else if (bmi < 25) {
      label = 'Normal range';
      color = const Color(0xFF22C55E);
    } else if (bmi < 30) {
      label = 'Overweight';
      color = const Color(0xFFF59E0B);
    } else {
      label = 'Obese';
      color = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Goal Selector, Activity Selector, Gender Selector, etc.
// (Keep your existing implementations from your file here.)
// ─────────────────────────────────────────────────────────────

class _GoalSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _GoalSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final goals = [
      _GoalOption(
        value: 'lose',
        label: 'Lose Weight',
        icon: Icons.trending_down_rounded,
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      ),
      _GoalOption(
        value: 'maintain',
        label: 'Maintain',
        icon: Icons.balance_rounded,
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _GoalOption(
        value: 'gain',
        label: 'Gain Muscle',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF22C55E),
        bgColor: const Color(0xFFF0FDF4),
      ),
    ];

    return Row(
      children: goals
          .map(
            (g) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(g.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: selected == g.value ? g.bgColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected == g.value
                        ? g.color
                        : const Color(0xFFE5E7EB),
                    width: selected == g.value ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected == g.value
                            ? g.color.withOpacity(0.15)
                            : const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(g.icon,
                          color: selected == g.value
                              ? g.color
                              : const Color(0xFF9CA3AF),
                          size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      g.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected == g.value
                            ? g.color
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _GoalOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _GoalOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _ActivitySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _ActivitySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final levels = [
      _ActivityLevel(
        value: 'low',
        label: 'Sedentary',
        sublabel: 'Little or no exercise',
        icon: '🛋️',
        bars: 1,
      ),
      _ActivityLevel(
        value: 'moderate',
        label: 'Moderate',
        sublabel: '3–5 days/week',
        icon: '🚶',
        bars: 2,
      ),
      _ActivityLevel(
        value: 'high',
        label: 'Very Active',
        sublabel: '6–7 days/week',
        icon: '🏋️',
        bars: 3,
      ),
    ];

    return Column(
      children: levels
          .map(
            (l) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => onChanged(l.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected == l.value
                    ? const Color(0xFFF0FDF4)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected == l.value
                      ? const Color(0xFF77DD77)
                      : const Color(0xFFE5E7EB),
                  width: selected == l.value ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  Text(l.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selected == l.value
                                ? const Color(0xFF166534)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          l.sublabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected == l.value
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      3,
                          (i) => Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 6,
                          height: 12.0 + i * 6,
                          decoration: BoxDecoration(
                            color: i < l.bars
                                ? (selected == l.value
                                ? const Color(0xFF77DD77)
                                : const Color(0xFFD1D5DB))
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _ActivityLevel {
  final String value;
  final String label;
  final String sublabel;
  final String icon;
  final int bars;

  const _ActivityLevel({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.bars,
  });
}

class _GenderSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Male', Icons.male_rounded, const Color(0xFF3B82F6),
      const Color(0xFFEFF6FF)),
      ('Female', Icons.female_rounded, const Color(0xFFEC4899),
      const Color(0xFFFDF2F8)),
      ('Other', Icons.people_outline_rounded, const Color(0xFF8B5CF6),
      const Color(0xFFF5F3FF)),
    ];

    return Row(
      children: options
          .map(
            (o) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected == o.$1 ? o.$4 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected == o.$1
                        ? o.$3
                        : const Color(0xFFE5E7EB),
                    width: selected == o.$1 ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(o.$2,
                        color: selected == o.$1
                            ? o.$3
                            : const Color(0xFF9CA3AF),
                        size: 28),
                    const SizedBox(height: 6),
                    Text(
                      o.$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected == o.$1
                            ? o.$3
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _StepProgressBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int current;
  final int total;

  const _StepProgressBar({required this.current, required this.total});

  @override
  Size get preferredSize => const Size.fromHeight(6);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (current + 1) / total,
      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.3),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      minHeight: 6,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF77DD77).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 26),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 1.0,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF77DD77), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF77DD77), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int pageIndex;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNavBar({
    required this.pageIndex,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (pageIndex > 0)
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (pageIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isSaving ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF77DD77),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1FAE5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pageIndex == 2 ? 'Save Profile' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    pageIndex == 2
                        ? Icons.check_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}