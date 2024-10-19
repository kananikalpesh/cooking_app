
import 'package:connectycube_sdk/connectycube_custom_objects.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/constants/ConCubeConstants.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/video_chat/ConCubeRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:rxdart/rxdart.dart';

class ConCubeUtils {
  static const String TAG = "ConCubeUtils";

  static Future<CubeUser> registration(UserModel userModel) async {
    CubeUser user = getCubeUserObject(userModel);

    if (CubeSessionManager.instance.isActiveSessionValid()) {
      return await signUp(user);
    } else {
      await createSession();
      return await signUp(user);
    }
  }

  static Future<String> createSessionAndLogin(CubeUser cubeUser,
      {bool forceCreateSession = false}) async {
    try {
      if (CubeSessionManager.instance.isActiveSessionValid() &&
          forceCreateSession == false) {
        var s = await loginToCubeChat(cubeUser);
        AppData.cubeUser = cubeUser;
        return s;
      } else {

        await createSession(cubeUser);
        var s = await loginToCubeChat(cubeUser);
        AppData.cubeUser = cubeUser;
        return s;
      }
    } catch (e) {

      LogManager().log(TAG, "createSessionAndLogin",
          "Getting exception in createSessionAndLogin from createSession or loginToCubeChat.",
          e: e);
      return e.toString();
    }
  }

  static Future<String> loginToCubeChat(CubeUser user) async {
    try {

      AppData.cubeUser = await CubeChatConnection.instance.login(user);
      AppData.callClient = P2PClient.instance;
      AppData.callClient.init();
      return null;
    } catch (e) {

      LogManager().log(TAG, "loginToCubeChat",
          "Getting exception while CubeChatConnection login or callClient.init.",
          e: e);
      return e.toString();
    }
  }

  static CubeUser getCubeUserObject(UserModel userModel, {int ccId}) {
    return CubeUser(
        id: ccId,
        email: userModel.email,
        fullName: "${userModel.firstName}".trim(),
        password: ConCubeConstants.DEFAULT_PASS);
  }

  static Future<CubeUser> getUserByEmailId(String emailId) {
    Future<CubeUser> cubeUser = getUserByEmail(emailId);
    return cubeUser;
  }

  static handleRegisterCC(UserModel userModel,
      BehaviorSubject<ResultModel<bool>> obsRegisterCCId,) async {
    CubeUser conCubeUser;

    conCubeUser =
    await ConCubeUtils.registration(userModel).catchError((e) async {
      conCubeUser =
      await ConCubeUtils.getUserByEmailId(userModel.email).catchError((e) {
        LogManager().log(
            TAG, "handleRegisterCC", "Getting error while getUserByEmailId.",
            e: e);
        obsRegisterCCId.add(ResultModel(error: e.toString()));
      });
      loginCCAndUpdateCCId(userModel, conCubeUser, obsRegisterCCId);
    });

    loginCCAndUpdateCCId(userModel, conCubeUser, obsRegisterCCId);
  }

  static loginCCAndUpdateCCId(UserModel userModel, CubeUser conCubeUser,
      BehaviorSubject<ResultModel<bool>> obsRegisterCCId) async {
    if (conCubeUser != null) {
      conCubeUser.password = ConCubeConstants.DEFAULT_PASS;
      String error = await ConCubeUtils.createSessionAndLogin(conCubeUser,
          forceCreateSession: true);
      if (error != null) {
        LogManager().log(TAG, "loginCCAndUpdateCCId",
            "Getting error while createSessionAndLogin.",
            e: error);
        obsRegisterCCId.add(ResultModel(error: error));
      } else {
        ResultModel resultModel = await ConCubeRepository().updateCCUserId(userModel);
        obsRegisterCCId.add(resultModel);
      }
    }
  }

  static handleUpdateCCUserName(String fullName, {String emailId}) async {
    CubeUser user = (emailId != null)
        ? CubeUser(id: AppData.cubeUser.id, fullName: fullName, email: emailId)
        : CubeUser(id: AppData.cubeUser.id, fullName: fullName);

    CubeUser updatedUser = await updateUser(user).catchError((error) {
      LogManager().log(TAG, "handleUpdateCCUserName",
          "Getting error while updateUser CC user.",
          e: error);
    });
    AppData.cubeUser.fullName = updatedUser.fullName;
  }

  ///Not Used but helpful feature if needed for prod testing CC VoIP notifications.
  // static handleUpdateCCTags(String fullName) async {
  //   Set<String> tags = {fullName};
  //   CubeUser user = CubeUser(id: AppData.cubeUser.id, fullName: fullName, tags: tags);
  //
  //   CubeUser updatedUser = await updateUser(user).catchError((error) {
  //     LogManager().log(TAG, "handleUpdateCCTags",
  //         "Getting error while updateUser CC tags.", e: error);
  //   });
  //   AppData.cubeUser.fullName = updatedUser.fullName;
  //   AppData.cubeUser.tags = updatedUser.tags;
  // }

  static logoutConCube() async {
    try {
      AppData.cubeUser = null;
      CubeChatConnection?.instance?.logout();
    } catch (e) {
      LogManager().log(TAG, "logoutConCube",
          "Got exception while CubeChatConnection but Signing out of ConnectyCube.",
          e: e);
      try {
        LogManager().log(TAG, "logoutConCube", "Signing out of ConnectyCube.");
        signOut().then((voidValue) {
          CubeChatConnection?.instance?.destroy();
          P2PClient?.instance?.destroy();
        }).catchError(
              (onError) {
            LogManager().log(TAG, "logoutConCube",
                "Got error while Signing out of ConnectyCube.", e: onError);
            P2PClient?.instance?.destroy();
          },
        );
      } catch (e) {
        LogManager().log(TAG, "logoutConCube",
            "Getting exception while signOut the ConnectyCube.", e: e);
      }
    }
  }
}