class ApiConfig {
  static const bool isProduction = false;

  static String get baseUrl {
    if (isProduction) {
      return 'https://yourdeployedbackend.com/api/v1'; //production URL
    } else {
      return 'http://192.168.1.82:8080/api/v1'; //local development
    }
  }

  static Uri getLoginUri() => Uri.parse('$baseUrl/signin/');
  static Uri getSignupUri() => Uri.parse('$baseUrl/signup/');
  static Uri getForgotPasswordUri() => Uri.parse('$baseUrl/forgot-password/');
  static Uri getResetPasswordUri() => Uri.parse('$baseUrl/reset-password');
  static Uri getGoogleSignInUri() => Uri.parse('$baseUrl/google-signin');

  static Uri getUpdateGenderUri() => Uri.parse('$baseUrl/update-gender');

   static Uri getUserProfileUri(String username) {
    return Uri.parse('$baseUrl/api/user/profile/$username');
  }

  static Uri getUpdateProfileUri(String username) =>
      Uri.parse('$baseUrl/user/update-profile/$username');

  static Uri getUploadPhotoUri(String username) =>
      Uri.parse('$baseUrl/upload-photo/$username');

  static Uri getChangePasswordUri(String username) =>
      Uri.parse('$baseUrl/user/change-password/$username');

  static Uri getDeleteUserUri(String username) =>
      Uri.parse('$baseUrl/user/delete/$username');

  //google signin user photo upload by email
  static Uri getUploadPhotoByEmailUri(String email) =>
      Uri.parse('$baseUrl/user/upload-photo-by-email/$email');

  static Uri getIncrementPopularityUri(String hairstyleId) =>
      Uri.parse('$baseUrl/interactions/increment-popularity/$hairstyleId');

  static Uri getRecommendHairstylesUri(String faceShape, String gender) =>
      Uri.parse(
        '$baseUrl/interactions/recommend?faceShape=$faceShape&gender=$gender',
      );

  static Uri getTrendingHairstylesUri() =>
      Uri.parse('$baseUrl/interactions/trending');

  static Uri getInteractionTryUri() => Uri.parse('$baseUrl/interactions/try');

  static Uri getHistoryUri(String userId) =>
      Uri.parse('$baseUrl/interactions/history/$userId');

  static Uri getFavoritesUri(String userId) =>
      Uri.parse('$baseUrl/interactions/favorites/$userId');

  static Uri postFavoriteUri(String userId) =>
      Uri.parse('$baseUrl/interactions/favorite/$userId');

  static Uri postAddToHistoryUri(String userId) =>
      Uri.parse('$baseUrl/interactions/history/$userId');

  static Uri getRecommendGlassesUri(String faceShape, String gender) =>
      Uri.parse('$baseUrl/interactions/recommend-glasses?faceShape=$faceShape&gender=$gender');
}
