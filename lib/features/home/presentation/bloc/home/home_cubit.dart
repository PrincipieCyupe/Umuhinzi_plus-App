import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    emit(
      state.copyWith(
        userName: prefs.getString('user_name'),
        userEmail: firebaseUser?.email ?? prefs.getString('user_email'),
        userCrop: prefs.getString('selected_crop'),
        userSeason: prefs.getString('selected_season'),
        userProvince: prefs.getString('selected_province'),
        userDistrict: prefs.getString('selected_district'),
      ),
    );
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }
}
