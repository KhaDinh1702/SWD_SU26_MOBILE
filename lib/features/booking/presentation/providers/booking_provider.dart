import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/order_model.dart';
import 'package:wave/core/models/service_model.dart';
import 'package:wave/core/models/vehicle_model.dart';

class BookingState {
  final int currentStep;
  final VehicleModel? selectedVehicle;
  final ServiceTypeModel? selectedService;
  final String? selectedDate; // YYYY-MM-DD
  final AvailableSlotModel? selectedSlot;
  final String? voucherId;
  final String note;
  final String paymentMethod; // 'online' or 'cash'

  BookingState({
    this.currentStep = 0,
    this.selectedVehicle,
    this.selectedService,
    this.selectedDate,
    this.selectedSlot,
    this.voucherId,
    this.note = '',
    this.paymentMethod = 'cash',
  });

  BookingState copyWith({
    int? currentStep,
    VehicleModel? selectedVehicle,
    ServiceTypeModel? selectedService,
    String? selectedDate,
    AvailableSlotModel? selectedSlot,
    String? voucherId,
    String? note,
    String? paymentMethod,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      voucherId: voucherId ?? this.voucherId,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  @override
  BookingState build() {
    return BookingState();
  }

  void setStep(int step) => state = state.copyWith(currentStep: step);
  
  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void selectVehicle(VehicleModel vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  void selectService(ServiceTypeModel service) {
    state = state.copyWith(selectedService: service);
  }

  void selectDate(String date) {
    state = state.copyWith(selectedDate: date, selectedSlot: null);
  }

  void selectSlot(AvailableSlotModel slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void setVoucher(String? voucherId) {
    state = state.copyWith(voucherId: voucherId);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void reset() {
    state = BookingState();
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});
