import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/appointment_provider.dart';
import '../../../../providers/auth_provider.dart';

class BookingDialog extends StatefulWidget {
  const BookingDialog({super.key, required this.doctor});

  final UserModel doctor;

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime;

  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Set<String> bookedTimes = {};
  bool isLoadingTimes = true;
  bool hasAvailabilityError = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    phoneController.text = authProvider.userData?.phone ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadBookedTimes();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  int? parseDoctorTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    String time = value.trim().toLowerCase();

    time = time
        .replaceAll('ص', ' am ')
        .replaceAll('م', ' pm ')
        .replaceAll('صباحًا', ' am ')
        .replaceAll('مساءً', ' pm ')
        .replaceAll('صباحا', ' am ')
        .replaceAll('مساء', ' pm ')
        .replaceAll('上午', ' am ')
        .replaceAll('下午', ' pm ')
        .replaceAll('am', ' am ')
        .replaceAll('pm', ' pm ')
        .replaceAll('.', ':');

    time = time.replaceAll(RegExp(r'\s+'), ' ').trim();

    final match = RegExp(
      r'^(\d{1,2})(?::(\d{1,2}))?\s*(am|pm)?$',
    ).firstMatch(time);

    if (match == null) {
      return null;
    }

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2) ?? '0');
    final period = match.group(3);

    if (hour > 23 || minute > 59) {
      return null;
    }

    if (period != null) {
      if (hour < 1 || hour > 12) {
        return null;
      }

      if (period == 'am') {
        hour = hour == 12 ? 0 : hour;
      } else {
        hour = hour == 12 ? 12 : hour + 12;
      }
    }

    return hour * 60 + minute;
  }

  String formatTime(int minutes) {
    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final period = hour < 12 ? 'ص' : 'م';

    int displayHour = hour % 12;
    if (displayHour == 0) {
      displayHour = 12;
    }

    return '${displayHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }

  bool get hasWorkingHours {
    int? start = parseDoctorTime(widget.doctor.startHour);
    int? end = parseDoctorTime(widget.doctor.endHour);

    if (start == null || end == null) {
      return false;
    }

    if (end <= start && end < 12 * 60) {
      end += 12 * 60;
    }

    return start < end;
  }

  List<String> get generatedTimes {
    int? start = parseDoctorTime(widget.doctor.startHour);
    int? end = parseDoctorTime(widget.doctor.endHour);

    if (start == null || end == null) {
      return [];
    }

    if (end <= start && end < 12 * 60) {
      end += 12 * 60;
    }

    if (start >= end) {
      return [];
    }

    final times = <String>[];

    for (int minutes = start; minutes + 60 <= end; minutes += 60) {
      final slotDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        minutes ~/ 60,
        minutes % 60,
      );

      if (slotDateTime.isAfter(DateTime.now())) {
        times.add(formatTime(minutes));
      }
    }

    return times;
  }

  Future<void> loadBookedTimes() async {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoadingTimes = true;
      hasAvailabilityError = false;
      selectedTime = null;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      final result = await appointmentProvider.getBookedTimesForDate(
        doctorId: widget.doctor.uid,
        date: formatDate(selectedDate),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        bookedTimes = result;
        isLoadingTimes = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        hasAvailabilityError = true;
        isLoadingTimes = false;
      });
    }
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(today) ? today : selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      helpText: 'اختر تاريخ الحجز',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      selectedDate = picked;
    });

    await loadBookedTimes();
  }

  Future<void> submitBooking() async {
    if (isSubmitting || !formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final currentUser = authProvider.userData;

    if (currentUser == null) {
      showMessage('يرجى تسجيل الدخول أولاً', isError: true);
      return;
    }

    if (isLoadingTimes || hasAvailabilityError) {
      showMessage('تعذر التحقق من المواعيد المتاحة.', isError: true);
      return;
    }

    if (selectedTime == null ||
        !generatedTimes.contains(selectedTime) ||
        bookedTimes.contains(selectedTime)) {
      showMessage('اختر موعدًا متاحًا أولاً.', isError: true);
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      final success = await appointmentProvider.bookAppointment(
        doctorId: widget.doctor.uid,
        doctorName: widget.doctor.name,
        doctorSpeciality: widget.doctor.speciality,
        patientId: currentUser.uid,
        patientName: currentUser.name,
        patientPhone: phoneController.text.trim(),
        date: formatDate(selectedDate),
        time: selectedTime!,
        location: widget.doctor.address ?? 'عيادة الدكتور',
      );

      if (!mounted) {
        return;
      }

      if (success) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حجز الموعد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        showMessage(
          appointmentProvider.errorMessage ?? 'تعذر حجز الموعد.',
          isError: true,
        );

        await loadBookedTimes();
      }
    } catch (e) {
      if (mounted) {
        showMessage('حدث خطأ أثناء الحجز. حاول مرة أخرى.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final times = generatedTimes;
    final validWorkingHours = hasWorkingHours;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'احجز موعد مع د. ${widget.doctor.name}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'تاريخ الحجز',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.calendar_month, color: AppColors.primary),
                        Text(
                          formatDate(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'المواعيد المتاحة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (!validWorkingHours)
                  const _BookingMessage(
                    icon: Icons.info_outline,
                    message: 'مواعيد عمل الدكتور غير محددة بشكل صحيح.',
                    color: Colors.red,
                  )
                else if (isLoadingTimes)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (hasAvailabilityError)
                  _BookingMessage(
                    icon: Icons.cloud_off_outlined,
                    message: 'تعذر تحميل الحجوزات من قاعدة البيانات.',
                    color: Colors.red,
                    onRetry: loadBookedTimes,
                  )
                else if (times.isEmpty)
                  const _BookingMessage(
                    icon: Icons.event_busy_outlined,
                    message: 'لا توجد مواعيد متاحة في هذا التاريخ.',
                    color: Colors.grey,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: times.map((time) {
                      final isBooked = bookedTimes.contains(time);
                      final isSelected = selectedTime == time;

                      return ChoiceChip(
                        label: Text(isBooked ? '$time - محجوز' : time),
                        selected: isSelected,
                        onSelected: isBooked || isSubmitting
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedTime = time;
                                  });
                                }
                              },
                        selectedColor: AppColors.primary,
                        disabledColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : isBooked
                              ? Colors.grey
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  enabled: !isSubmitting,
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف للتواصل';
                    }

                    final digits = phone.replaceAll(RegExp(r'[\s()+-]'), '');

                    if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) {
                      return 'أدخل رقم هاتف صحيحًا';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف للتأكيد',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed:
              isSubmitting ||
                  isLoadingTimes ||
                  hasAvailabilityError ||
                  !validWorkingHours ||
                  times.isEmpty
              ? null
              : submitBooking,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(isSubmitting ? 'جاري الحجز...' : 'تأكيد الحجز'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingMessage extends StatelessWidget {
  const _BookingMessage({
    required this.icon,
    required this.message,
    required this.color,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final Color color;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ],
      ),
    );
  }
}
