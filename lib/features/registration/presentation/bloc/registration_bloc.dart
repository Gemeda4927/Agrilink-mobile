import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/registration_usecases.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationUseCases useCases;

  RegistrationBloc(this.useCases) : super(RegistrationInitial()) {
    /// Load Regions
    on<LoadRegions>((event, emit) async {
      emit(RegistrationLoading());

      try {
        final regions = await useCases.getRegions();
        emit(RegionsLoaded(regions));
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });

    /// Load Zones
    on<LoadZones>((event, emit) async {
      emit(RegistrationLoading());

      try {
        final zones = await useCases.getZones(event.regionId);
        emit(ZonesLoaded(zones));
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });

    /// Load Woredas
    on<LoadWoredas>((event, emit) async {
      emit(RegistrationLoading());

      try {
        final woredas = await useCases.getWoredas(event.zoneId);
        emit(WoredasLoaded(woredas));
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });

    /// Load Kebeles
    on<LoadKebeles>((event, emit) async {
      emit(RegistrationLoading());

      try {
        final kebeles = await useCases.getKebeles(event.woredaId);
        emit(KebelesLoaded(kebeles));
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });

    /// Register User
    on<RegisterUser>((event, emit) async {
      emit(RegistrationLoading());

      try {
        await useCases.registerUser(event.data);
        emit(RegistrationSuccess());
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });

    /// Create Farmer
    on<CreateFarmer>((event, emit) async {
      emit(RegistrationLoading());

      try {
        final response = await useCases.createFarmer(
          email: event.email,
          password: event.password,
          confirmPassword: event.confirmPassword,
          phone: event.phone,
          role: event.role,
        );
        emit(CreateFarmerSuccess(message: response.message));
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });
  }
}