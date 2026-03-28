import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String? userName;
  final String? userEmail;
  final String? userCrop;
  final String? userSeason;
  final String? userProvince;
  final String? userDistrict;
  final String selectedCategory;

  const HomeState({
    this.userName,
    this.userEmail,
    this.userCrop,
    this.userSeason,
    this.userProvince,
    this.userDistrict,
    this.selectedCategory = 'All',
  });

  HomeState copyWith({
    String? userName,
    String? userEmail,
    String? userCrop,
    String? userSeason,
    String? userProvince,
    String? userDistrict,
    String? selectedCategory,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userCrop: userCrop ?? this.userCrop,
      userSeason: userSeason ?? this.userSeason,
      userProvince: userProvince ?? this.userProvince,
      userDistrict: userDistrict ?? this.userDistrict,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    userEmail,
    userCrop,
    userSeason,
    userProvince,
    userDistrict,
    selectedCategory,
  ];
}
