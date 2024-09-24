import 'package:dio/dio.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:fav_qs_api/src/url_builder.dart';
import 'package:test/test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('Sign In Test:', () {
    final dio = Dio(BaseOptions());

    //Add the adapter that will stub the expected http response
    final dioAdapter = DioAdapter(dio: dio);

    //Initialize all the required variables, which are used when performing
    //sign-in request
    const email = 'email';
    const password = 'password';

    final remoteApi = FavQsApi(
      userTokenSupplier: () => Future.value(),
      dio: dio,
    );

    final url = const UrlBuilder().buildSignInUrl();

    final requestJsonBody = const SignInRequestRM(
        credentials: UserCredentialsRM(
      email: email,
      password: password,
    )).toJson();

    //Implementation of request stubbing
    test(
        'When a sign in request completes successfully, return an instance'
        ' of UserRM', () async {
      dioAdapter.onPost(
        url,
        (server) => server.reply(
          200,
          {"User-Token": "token", "login": "login", "email": "email"},
          delay: const Duration(seconds: 1),
        ),
        data: requestJsonBody,
      );

      expect(await remoteApi.signIn(email, password), isA<UserRM>());
    });
    test(
        'When a user submits incorrect credentials when signing in, throw '
        'a MockDioException', () async {
      final requestOptions = RequestOptions(baseUrl: url);
      final response = Response(
        requestOptions: requestOptions,
        statusCode: 404,
        statusMessage: "Invalid login or password",
      );
      final dioError = MockDioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );

      dioAdapter.onPost(
        url,
        (server) =>
            server.throws(404, dioError, delay: const Duration(seconds: 1)),
        data: requestJsonBody,
      );
      expect(() async => await remoteApi.signIn(email, password),
          throwsA(isA<MockDioException>()));
    });
    test(
        'When a user\'s account has been deactivated, throw a'
        ' MockDioException', () async {
      final requestOptions = RequestOptions(baseUrl: url);
      final response = Response(
          requestOptions: requestOptions,
          statusCode: 404,
          statusMessage: 'Account has been deactivated. Please contact '
              'support@favqs.com');
      final dioError = MockDioException(
        requestOptions: requestOptions,
        response: response,
        type: DioExceptionType.cancel,
      );

      dioAdapter.onPost(
          url,
          (server) =>
              server.throws(404, dioError, delay: const Duration(seconds: 1)),
          data: requestJsonBody);

      expect(() async => await remoteApi.signIn(email, password),
          throwsA(isA<MockDioException>()));
    });
  });
}
