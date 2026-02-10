import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/core/utils/responsive.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';
import 'package:operation_brotherhood/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:operation_brotherhood/features/challenge/data/models/challenge_model.dart';
import 'package:uuid/uuid.dart';

class HabitScreen extends HookConsumerWidget {
  final ChallengeModel? challengeToEdit;

  const HabitScreen({super.key, this.challengeToEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final noteController = useTextEditingController();
    final selectedCategory = useState('Fitness');
    final selectedIcon = useState(0xe24a); // Icons.fitness_center
    final selectedFrequency = useState('DAILY');
    final targetValue = useState(1);
    final targetUnit = useState('TIMES');
    final endDate = useState(DateTime.now().add(const Duration(days: 30)));
    final priority = useState('MEDIUM');

    final categories = useState([
      {'name': 'Fitness', 'icon': Icons.fitness_center},
      {'name': 'Study', 'icon': Icons.menu_book},
      {'name': 'Discipline', 'icon': Icons.verified_user},
      {'name': 'Sleep', 'icon': Icons.nights_stay},
    ]);

    void _showCustomCategoryDialog() {
      showDialog(
        context: context,
        builder: (context) => _CustomCategoryDialog(
          onAdded: (name, icon) {
            categories.value = [
              ...categories.value,
              {'name': name, 'icon': icon},
            ];
            selectedCategory.value = name;
            selectedIcon.value = icon.codePoint;
          },
        ),
      );
    }

    // Challenge Hooks
    final chNameController = useTextEditingController();
    final chDurationController = useTextEditingController(text: '30');
    final threatLevel = useState('MEDIUM');
    final chConsequenceType = useState('PHYSICAL');
    final specificConsequence = useState('COLD SHOWER');
    final roadmap = useState<List<ChallengeMilestone>>([]);

    final creationMode = useState('HABIT'); // 'HABIT' or 'CHALLENGE'

    useEffect(() {
      if (challengeToEdit != null) {
        creationMode.value = 'CHALLENGE';
        chNameController.text = challengeToEdit!.name;
        chDurationController.text = challengeToEdit!.duration.toString();
        threatLevel.value = challengeToEdit!.threatLevel;
        chConsequenceType.value = challengeToEdit!.consequenceType;
        specificConsequence.value = challengeToEdit!.specificConsequence;
        roadmap.value = challengeToEdit!.roadmap;
      }
      return null;
    }, []);

    void handleCreateHabit() {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a habit name')),
        );
        return;
      }

      ref
          .read(habitProvider.notifier)
          .addHabit(
            name: nameController.text,
            category: selectedCategory.value,
            categoryIcon: selectedIcon.value,
            frequency: selectedFrequency.value,
            targetValue: targetValue.value,
            targetUnit: targetUnit.value,
            reminderTime:
                null, // As per new requirement to replace reminder with date setter
            priority: priority.value,
            motivationNote: noteController.text,
            endDate: endDate.value,
          );

      Navigator.pop(context);
    }

    // Challenge limit logic
    final challenges = ref.watch(challengeProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeChallengesCount = challenges.where((challenge) {
      final endDate = challenge.startDate.add(
        Duration(days: challenge.duration),
      );
      return (challenge.startDate.isBefore(today) ||
              challenge.startDate.isAtSameMomentAs(today)) &&
          endDate.isAfter(today);
    }).length;

    final isChallengeLimitReached = activeChallengesCount >= 5;

    // Reset mode to HABIT if challenge was selected but limit reached (e.g. after adding one)
    // ONLY if we are NOT editing
    if (challengeToEdit == null &&
        isChallengeLimitReached &&
        creationMode.value == 'CHALLENGE') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        creationMode.value = 'HABIT';
      });
    }

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: AppColors.habitBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          challengeToEdit != null ? 'Edit Mission' : 'Create New',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // MODE TOGGLE
            if (challengeToEdit == null) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.habitSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _modeToggleItem(
                        'HABIT',
                        creationMode.value == 'HABIT',
                        () => creationMode.value = 'HABIT',
                      ),
                    ),
                    if (!isChallengeLimitReached)
                      Expanded(
                        child: _modeToggleItem(
                          'CHALLENGE',
                          creationMode.value == 'CHALLENGE',
                          () => creationMode.value = 'CHALLENGE',
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: context.h(3)),
            ],

            if (creationMode.value == 'HABIT') ...[
              // HABIT IDENTITY
              _sectionHeader('HABIT IDENTITY'),
              _customTextField(
                controller: nameController,
                hintText: 'e.g. Morning Meditation',
                label: 'Habit Name',
                maxLength: 30,
              ),

              SizedBox(height: context.h(3)),

              // CATEGORY
              _sectionHeader('CATEGORY'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...categories.value.map(
                      (cat) => _categoryChip(
                        context,
                        cat['name'] as String,
                        cat['icon'] as IconData,
                        selectedCategory.value == cat['name'],
                        () {
                          selectedCategory.value = cat['name'] as String;
                          selectedIcon.value =
                              (cat['icon'] as IconData).codePoint;
                        },
                      ),
                    ),
                    _categoryChip(
                      context,
                      'Custom',
                      Icons.add,
                      false,
                      _showCustomCategoryDialog,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(3)),

              // FREQUENCY & GOAL
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('FREQUENCY'),
                        _frequencyToggle(
                          context,
                          selectedFrequency.value,
                          (val) => selectedFrequency.value = val,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('GOAL/TARGET'),
                        _goalInput(
                          context,
                          targetValue.value,
                          targetUnit.value,
                          (val) => targetValue.value = val,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.h(3)),

              // END DATE SETTER
              _sectionHeader('HABIT DURATION'),
              _endDateSetter(
                context,
                endDate.value,
                (val) => endDate.value = val,
              ),

              SizedBox(height: context.h(3)),

              // PRIORITY LEVEL
              _sectionHeader('PRIORITY LEVEL'),
              _prioritySelector(
                context,
                priority.value,
                (val) => priority.value = val,
              ),

              SizedBox(height: context.h(3)),

              // MOTIVATION NOTE
              _sectionHeader('MOTIVATION NOTE'),
              _motivationField(noteController),

              SizedBox(height: context.h(4)),

              // CREATE HABIT BUTTON
              _createHabitButton(context, handleCreateHabit),

              SizedBox(height: context.h(5)),
            ] else ...[
              ..._buildChallengeForm(
                context,
                ref,
                chNameController,
                chDurationController,
                threatLevel,
                chConsequenceType,
                specificConsequence,
                roadmap,
                () => handleAcceptChallenge(
                  context,
                  ref,
                  chNameController,
                  chDurationController,
                  threatLevel,
                  chConsequenceType,
                  specificConsequence,
                  roadmap.value,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.habitIconGrey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required int maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '0/$maxLength',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 18),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
    BuildContext context,
    String name,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.habitCategoryBlue
              : AppColors.habitSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.habitBorder.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.habitPrimary.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.habitIconGrey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.habitIconGrey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frequencyToggle(
    BuildContext context,
    String selected,
    Function(String) onSelect,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: ['DAILY', 'WEEKLY'].map((freq) {
          bool isSel = selected == freq;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(freq),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.habitPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  freq,
                  style: TextStyle(
                    color: isSel ? Colors.white : AppColors.habitIconGrey,
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _goalInput(
    BuildContext context,
    int value,
    String unit,
    Function(int) onValueChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 1,
            color: Colors.white12,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: AppColors.habitIconGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.habitIconGrey,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _endDateSetter(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.habitPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.habitPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'HABIT DURATION RANGE',
                    style: TextStyle(
                      color: AppColors.habitIconGrey,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                onDateChange(DateTime.now().add(Duration(days: index + 1)));
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected =
                      date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;
                  return Center(
                    child: Text(
                      "${date.day} ${_getMonth(date.month)} ${date.year}",
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.habitPrimary
                            : Colors.white24,
                        fontSize: isSelected ? 24 : 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
                childCount: 365, // Max 1 year for now
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
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

  Widget _prioritySelector(
    BuildContext context,
    String selected,
    Function(String) onSelect,
  ) {
    return Row(
      children: [
        Expanded(
          child: _priorityChip(
            'LOW',
            AppColors.lowPriorityColor,
            selected == 'LOW',
            () => onSelect('LOW'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _priorityChip(
            'MEDIUM',
            AppColors.mediumPriorityColor,
            selected == 'MEDIUM',
            () => onSelect('MEDIUM'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _priorityChip(
            'HIGH',
            AppColors.highPriorityColor,
            selected == 'HIGH',
            () => onSelect('HIGH'),
          ),
        ),
      ],
    );
  }

  Widget _priorityChip(
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : AppColors.habitBorder.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.habitIconGrey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          hintText: "Define your 'Why'... Success is the only option.",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _createHabitButton(BuildContext context, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.habitPrimary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.habitPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.rocket_launch, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'CREATE HABIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.habitPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  void handleAcceptChallenge(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController durationController,
    ValueNotifier<String> threatLevel,
    ValueNotifier<String> consequenceType,
    ValueNotifier<String> specificConsequence,
    List<ChallengeMilestone> roadmap,
  ) {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a mission identification name'),
        ),
      );
      return;
    }

    final duration = int.tryParse(durationController.text) ?? 30;

    if (challengeToEdit != null) {
      final updatedChallenge = challengeToEdit!.copyWith(
        name: nameController.text.toUpperCase(),
        duration: duration,
        threatLevel: threatLevel.value,
        consequenceType: consequenceType.value,
        specificConsequence: specificConsequence.value,
        roadmap: roadmap,
      );
      ref.read(challengeProvider.notifier).updateChallenge(updatedChallenge);
    } else {
      ref
          .read(challengeProvider.notifier)
          .addChallenge(
            name: nameController.text.toUpperCase(),
            duration: duration,
            threatLevel: threatLevel.value,
            consequenceType: consequenceType.value,
            specificConsequence: specificConsequence.value,
            startDate: DateTime.now(),
            roadmap: roadmap,
          );
    }

    Navigator.pop(context);
  }

  List<Widget> _buildChallengeForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController durationController,
    ValueNotifier<String> threatLevel,
    ValueNotifier<String> consequenceType,
    ValueNotifier<String> specificConsequence,
    ValueNotifier<List<ChallengeMilestone>> roadmap,
    VoidCallback onAccept,
  ) {
    return [
      _buildChSectionHeader('MISSION IDENTIFICATION'),
      _buildChLabel('CHALLENGE NAME'),
      _buildChTextField(nameController, 'E.G. NO-SURRENDER-MARCH'),
      const SizedBox(height: 20),
      _buildChLabel('DURATION (DAYS)'),
      _buildChTextField(
        durationController,
        '30',
        keyboardType: TextInputType.number,
      ),

      const SizedBox(height: 30),
      _buildChSectionHeader('THREAT LEVEL'),
      Row(
        children: [
          Expanded(
            child: _buildChToggleItem(
              'EASY',
              threatLevel.value == 'EASY',
              () => threatLevel.value = 'EASY',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildChToggleItem(
              'MEDIUM',
              threatLevel.value == 'MEDIUM',
              () => threatLevel.value = 'MEDIUM',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildChToggleItem(
              'HARD',
              threatLevel.value == 'HARD',
              () => threatLevel.value = 'HARD',
            ),
          ),
        ],
      ),

      const SizedBox(height: 30),
      _buildChSectionHeader('FAILURE CONSEQUENCE'),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildChConsequenceTypeItem(
                'DONATE',
                consequenceType.value == 'DONATE',
                () => consequenceType.value = 'DONATE',
              ),
            ),
            Expanded(
              child: _buildChConsequenceTypeItem(
                'PHYSICAL',
                consequenceType.value == 'PHYSICAL',
                () => consequenceType.value = 'PHYSICAL',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: _buildChSpecificConsequenceCard(
              'COLD SHOWER',
              Icons.ac_unit,
              specificConsequence.value == 'COLD SHOWER',
              () => specificConsequence.value = 'COLD SHOWER',
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildChSpecificConsequenceCard(
              'PUSHUPS (50)',
              Icons.fitness_center,
              specificConsequence.value == 'PUSHUPS (50)',
              () => specificConsequence.value = 'PUSHUPS (50)',
            ),
          ),
        ],
      ),

      const SizedBox(height: 30),
      _buildChSectionHeader('MISSION ROADMAP'),
      ...roadmap.value.map(
        (m) => _buildMilestoneTile(m, () {
          roadmap.value = roadmap.value
              .where((item) => item.id != m.id)
              .toList();
        }),
      ),
      _buildAddMilestoneButton(() {
        _showAddMilestoneDialog(context, (m) {
          roadmap.value = [...roadmap.value, m];
        });
      }),

      const SizedBox(height: 40),
      _buildChWarningCard(),
      const SizedBox(height: 20),
      _buildChAcceptButton(onAccept),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildChSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.habitPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.habitPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.habitBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.habitPrimary.withOpacity(0.1)
              : AppColors.habitSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.habitPrimary : AppColors.habitBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.habitPrimary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChConsequenceTypeItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.habitPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChSpecificConsequenceCard(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.habitPrimary : AppColors.habitBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.habitPrimary : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChWarningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.highPriorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.highPriorityColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.highPriorityColor,
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BROTHERHOOD WARNING',
                  style: TextStyle(
                    color: AppColors.highPriorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once started, backing out has consequences. Your progress will be monitored by the brotherhood.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChAcceptButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.habitPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          shadowColor: AppColors.habitPrimary.withOpacity(0.5),
        ),
        child: const Text(
          'ACCEPT THE CHALLENGE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneTile(
    ChallengeMilestone milestone,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.habitBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.habitPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag,
              color: AppColors.habitPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${milestone.durationDays} Days • ${milestone.subtasks.length} Subtasks',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildAddMilestoneButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.habitPrimary,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.habitPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'ADD MILESTONE',
              style: TextStyle(
                color: AppColors.habitPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMilestoneDialog(
    BuildContext context,
    Function(ChallengeMilestone) onAdded,
  ) {
    showDialog(
      context: context,
      builder: (context) => _MilestoneAddDialog(onAdded: onAdded),
    );
  }
}

class _MilestoneAddDialog extends HookWidget {
  final Function(ChallengeMilestone) onAdded;
  const _MilestoneAddDialog({required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final durationController = useTextEditingController(text: '7');
    final subtaskController = useTextEditingController();
    final subtasks = useState<List<String>>([]);

    return Dialog(
      backgroundColor: AppColors.habitSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Milestone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _dialogTextField(titleController, 'Milestone Title (e.g. Phase 1)'),
            const SizedBox(height: 15),
            _dialogTextField(descController, 'Description', maxLines: 3),
            const SizedBox(height: 15),
            _dialogTextField(
              durationController,
              'Duration (Days)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            const Text(
              'SUBTASKS',
              style: TextStyle(
                color: AppColors.habitPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dialogTextField(subtaskController, 'Add subtask...'),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.habitPrimary,
                  ),
                  onPressed: () {
                    if (subtaskController.text.isNotEmpty) {
                      subtasks.value = [
                        ...subtasks.value,
                        subtaskController.text,
                      ];
                      subtaskController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...subtasks.value.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      onAdded(
                        ChallengeMilestone(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          description: descController.text,
                          durationDays:
                              int.tryParse(durationController.text) ?? 7,
                          subtasks: subtasks.value
                              .map(
                                (s) => ChallengeSubtask(
                                  id: const Uuid().v4(),
                                  title: s,
                                ),
                              )
                              .toList(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.habitPrimary,
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: AppColors.habitBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _CustomCategoryDialog extends HookWidget {
  final Function(String, IconData) onAdded;

  const _CustomCategoryDialog({required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final selectedIcon = useState(Icons.category);

    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.work,
      Icons.school,
      Icons.fitness_center,
      Icons.sports_basketball,
      Icons.music_note,
      Icons.brush,
      Icons.code,
      Icons.camera_alt,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.directions_run,
      Icons.directions_bike,
      Icons.flight,
      Icons.home,
      Icons.pets,
      Icons.book,
      Icons.event,
      Icons.access_time,
      Icons.lightbulb,
      Icons.money,
      Icons.account_balance,
      Icons.smartphone,
      Icons.tv,
      Icons.headset,
      Icons.videogame_asset,
      Icons.nature,
      Icons.pool,
    ];

    return Dialog(
      backgroundColor: AppColors.habitSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Custom Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Category Name',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppColors.habitBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Icon',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final icon = icons[index];
                  final isSelected = selectedIcon.value == icon;
                  return GestureDetector(
                    onTap: () => selectedIcon.value = icon,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.habitPrimary
                            : AppColors.habitBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : AppColors.habitIconGrey,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      onAdded(nameController.text, selectedIcon.value);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.habitPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
