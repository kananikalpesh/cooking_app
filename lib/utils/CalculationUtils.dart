
import 'package:cooking_app/utils/AppStrings.dart';

class CalculationUtils {
  static RegExp regexToRemoveZeroAfterDecimal = RegExp(r"([.]*0)(?!.*\d)");

  static String calculateHours(int durationInMinutes) {
    return ((durationInMinutes)/60).toString().replaceAll(regexToRemoveZeroAfterDecimal, "")
        + AppStrings.hour;
  }

}
