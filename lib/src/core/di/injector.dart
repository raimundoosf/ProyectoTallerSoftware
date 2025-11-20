import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/src/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:flutter_app/src/features/auth/domain/usecases/get_user_role.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/save_user_role.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_in.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_up.dart';
import 'package:flutter_app/src/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_app/src/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:flutter_app/src/features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'package:flutter_app/src/features/company_profile/data/repositories/company_profile_repository_impl.dart';

import 'package:flutter_app/src/features/company_profile/domain/usecases/get_company_profile.dart';
import 'package:flutter_app/src/features/company_profile/domain/usecases/save_company_profile.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_app/src/features/user_profile/data/repositories/user_profile_repository_impl.dart';

import 'package:flutter_app/src/features/user_profile/domain/usecases/get_user_profile.dart';
import 'package:flutter_app/src/features/user_profile/domain/usecases/save_user_profile.dart';
import 'package:flutter_app/src/features/user_profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Products feature
import 'package:flutter_app/src/features/products/data/repositories/products_repository_impl.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/new_product_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/products_list_viewmodel.dart';

List<SingleChildWidget> get providers {
  // Infrastructure
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Repositories
  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore);
  final userProfileRepository = UserProfileRepositoryImpl(firestore);
  final companyProfileRepository = CompanyProfileRepositoryImpl(
    firestore,
    FirebaseStorage.instance,
  );
  final productsRepository = ProductsRepositoryImpl(
    firestore,
    FirebaseStorage.instance,
  );

  // Use Cases
  final signIn = SignIn(authRepository);
  final signUp = SignUp(authRepository);
  final signOut = SignOut(authRepository);
  final getUserRole = GetUserRole(authRepository);
  final saveUserRole = SaveUserRole(authRepository);
  final getUserProfile = GetUserProfile(userProfileRepository);
  final saveUserProfile = SaveUserProfile(userProfileRepository);
  final getCompanyProfile = GetCompanyProfile(companyProfileRepository);
  final saveCompanyProfile = SaveCompanyProfile(companyProfileRepository);

  // ViewModels
  return [
    ChangeNotifierProvider(create: (_) => LoginViewModel(signIn)),
    ChangeNotifierProvider(
      create: (_) => RegisterViewModel(signUp, saveUserRole),
    ),
    ChangeNotifierProvider(
      create: (_) => ProfileViewModel(getUserProfile, saveUserProfile),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          CompanyProfileViewModel(getCompanyProfile, saveCompanyProfile),
    ),
    ChangeNotifierProvider(create: (_) => HomeViewModel(signOut, getUserRole)),
    // Products
    ChangeNotifierProvider(
      create: (_) => NewProductViewModel(productsRepository),
    ),
    ChangeNotifierProvider(
      create: (_) => ProductsListViewModel(productsRepository),
    ),
  ];
}
