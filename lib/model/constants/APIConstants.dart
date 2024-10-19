
class APIConstants{

  static const STATUS_CODE_API_SUCCESS = 200;
  static const STATUS_CODE_CREATED_SUCCESS = 201;
  static const STATUS_CODE_API_UNAUTHORIZED = 401;
  static const STATUS_CODE_INTERNAL_SERVER_ERROR = 500;
  static const STATUS_CODE_ADDRESS_NEEDED = 406;
  static const STATUS_CODE_COUNTRY_NOT_SUPPORTED = 405;

  static const BASE_URL = "https://api.inhomecooking.co/";

  static const TERMS_AND_CONDITIONS = "https://inhomecooking.co/terms-of-use";
  static const PRIVACY_POLICY = "https://inhomecooking.co/privacy-policy";
  static const PAYMENT_SUCCESS = "https://inhomecooking.co/payment-success";
  static const PAYMENT_FAIl = "https://inhomecooking.co/payment-fail";

  //LOGIN & REGISTER
  static const LOGIN_WITH_PASSWORD = BASE_URL + "login";
  static const VERIFY_OTP = BASE_URL + "_u/vrp";
  static const FORGOT_PASSWORD = BASE_URL + "_u/gpk";
  static const SET_PASSWORD = BASE_URL + "_u/rp";
  static const REGISTER_USER = BASE_URL + "_u/c";
  static const GET_COUNTRIES_LIST = BASE_URL + "_ms/cl";
  
  //User Profile
  static const CHANGE_PASSWORD = BASE_URL + "_u/cp";
  static const GET_PROFILE = BASE_URL + "_u/";
  static const UPDATE_PROFILE = BASE_URL + "_u/up";
  static const UPLOAD_PROFILE_PIC = BASE_URL + "_u/pi";
  static const GET_ADDRESS = BASE_URL + "_u/addr/g";
  static const UPDATE_ADDRESS = BASE_URL + "_u/addr/u";

  //User Home
  static const GET_CUISINE_DIET_LIST = BASE_URL + "_h/tags";
  static const GET_SEARCHED_LESSONS_LIST = BASE_URL + "_s/l";

  //Lesson Details
  static const GET_LESSON_DETAILS = BASE_URL + "_l/g";
  static const GET_OTHER_LESSONS_MINI = BASE_URL + "_l/gbyc_m";
  static const GET_OTHER_LESSONS = BASE_URL + "_l/gbyc";
  static const GET_BOOKING_DETAILS = BASE_URL + "_l/gbi";

  //Book Lesson
  static const GET_AVAILABLE_SLOTS = BASE_URL + "_lb/u/sl";
  static const BOOK_LESSON_REQUEST = BASE_URL + "_lb/u/r";

  //Cook Profile
  static const ADD_MEDIA = BASE_URL + "_u/c/i/a/";
  static const DELETE_MEDIA = BASE_URL + "_u/c/i/d/";
  static const ADD_AVAILABILITY = BASE_URL + "_u/ca/e";
  static const DELETE_AVAILABILITY = BASE_URL + "_u/ca/d/";
  static const UPDATE_AVAILABILITY = BASE_URL + "_u/ca/c";

  //Add ConnectyCube Id
  static const UPDATE_CC_ID = BASE_URL + "_u/uc";

  //Cook Lesson
  static const CREATE_LESSON = BASE_URL + "_l/c";
  static const GET_MY_LESSONS = BASE_URL + "_l/gbyc";
  static const UPDATE_MY_LESSONS = BASE_URL + "_l/u";
  static const UPLOAD_MY_LESSON_IMAGE = BASE_URL + "_l/ail";
  static const DELETE_MY_LESSON_IMAGE = BASE_URL + "_l/dil";
  static const DELETE_MY_LESSON = BASE_URL + "_l/d";

  //User Bookings
  static const GET_MY_LESSON_BOOKINGS = BASE_URL + "_lb/u/ls";

  //Cook Bookings
  static const GET_COOK_LESSON_BOOKINGS = BASE_URL + "_lb/c/ls";
  static const COOK_CANCEL_LESSON_BOOKING = BASE_URL + "_lb/c/c";
  static const COOK_APPROVE_LESSON_BOOKING = BASE_URL + "_lb/c/ap";

  //Reviews
  static const GET_OTHER_COOK_REVIEWS = BASE_URL + "_r/gc";
  static const GET_LESSON_REVIEWS = BASE_URL + "_r/gl";
  static const ADD_COOK_AND_LESSON_REVIEW = BASE_URL + "_r/acl";

  static const UPDATE_DEVICE_METADATA = BASE_URL + "_m/up";

  static const CANCEL_BOOKING_REQUEST = BASE_URL + "_lb/u/c";
  static const LESSON_BOOKING_PAYMENT = BASE_URL + "_pg/cs";

  //Cook Add Bank Account
  static const ON_BOARDING_CREATE_ACCOUNT = BASE_URL + "_pg/ol";

  //My Bookings- cook/User
  static const COOK_MY_BOOKINGS = BASE_URL + "_lb/c/ls";
  static const USER_MY_BOOKINGS = BASE_URL + "_lb/u/ls";

  //Calender Dates
  static const CALENDER_DATES = BASE_URL + "_lb/cal/dates";

  //Report User/Cook
  static const REPORT_USER_OR_COOK_TO_ADMIN = BASE_URL + "_ru/ru";

  //Reviews User
  static const ADD_USER_REVIEW = BASE_URL + "_r/au";
  static const GET_OTHER_USER_REVIEWS = BASE_URL + "_r/gu";

  //Admin
  static const GET_ANALYTICS_DETAILS = BASE_URL + "_ad/dash";
  static const GET_PAYMENTS_LIST = BASE_URL + "_ad/tf";
  static const GET_ALL_USERS_LIST = BASE_URL + "_ad/u/g";
  static const DELETE_USER = BASE_URL + "_ad/u/r";
  static const GET_FLAGGED_USERS_LIST = BASE_URL + "_ad/ru/g";
  static const BLOCK_FLAGGED_USER = BASE_URL + "_ad/ru/block";
  static const IGNORE_FLAGGED_USER = BASE_URL + "_ad/ru/ignore";

  static const LOGOUT = BASE_URL + "logout";
}