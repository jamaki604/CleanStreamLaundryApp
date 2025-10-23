import 'package:clean_stream_laundry_app/Logic/Authentication/AuthenticationResponses.dart';
import 'package:clean_stream_laundry_app/Logic/Authentication/Authenticator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main(){
  late Authenticator authenticator;
  late SupabaseMock client;
  late GoTrueMock supabaseAuth;

  group("Authentication Tests", (){

    setUp((){
      client = SupabaseMock();
      supabaseAuth = GoTrueMock();
      when(() => client.auth).thenReturn(supabaseAuth);

      authenticator = Authenticator(client);

      final mockUser = User(
        id: '11111111-1111-1111-1111-111111111111',
        aud: 'authenticated',
        role: 'authenticated',
        email: 'testemail@test.com',
        emailConfirmedAt: null,
        phone: '',
        lastSignInAt: '',
        appMetadata: {},
        userMetadata: {},
        identities: [],
        createdAt: '',
        updatedAt: '',
      );
      when(() => supabaseAuth.currentUser).thenReturn(mockUser);

      when(() => supabaseAuth.refreshSession()).thenAnswer((_) async => AuthResponse());

    });

    test("Tests if login is successful",()async{

      when(() => supabaseAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => AuthResponse(
        user: const User(
          id: '11111111-1111-1111-1111-111111111111',
          aud: 'authenticated',
          role: 'authenticated',
          email: 'example@email.com',
          emailConfirmedAt: '2024-01-01T00:00:00Z',
          phone: '',
          lastSignInAt: '2024-01-01T00:00:00Z',
          appMetadata: {
            'provider': 'email',
            'providers': ['email']
          },
          userMetadata: {},
          identities: [
            UserIdentity(
              identityId: '22222222-2222-2222-2222-222222222222',
              id: '11111111-1111-1111-1111-111111111111',
              userId: '11111111-1111-1111-1111-111111111111',
              identityData: {
                'email': 'example@email.com',
                'email_verified': false,
                'phone_verified': false,
                'sub': '11111111-1111-1111-1111-111111111111'
              },
              provider: 'email',
              lastSignInAt: '2024-01-01T00:00:00Z',
              createdAt: '2024-01-01T00:00:00Z',
              updatedAt: '2024-01-01T00:00:00Z',
            ),
          ],
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
        session: Session(
          accessToken: '<ACCESS_TOKEN>',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: '<REFRESH_TOKEN>',
          user: const User(
            id: '11111111-1111-1111-1111-111111111111',
            aud: 'authenticated',
            role: 'authenticated',
            email: 'example@email.com',
            emailConfirmedAt: '2024-01-01T00:00:00Z',
            phone: '',
            lastSignInAt: '2024-01-01T00:00:00Z',
            appMetadata: {
              'provider': 'email',
              'providers': ['email']
            },
            userMetadata: {},
            identities: [
              UserIdentity(
                identityId: '22222222-2222-2222-2222-222222222222',
                id: '11111111-1111-1111-1111-111111111111',
                userId: '11111111-1111-1111-1111-111111111111',
                identityData: {
                  'email': 'example@email.com',
                  'email_verified': false,
                  'phone_verified': false,
                  'sub': '11111111-1111-1111-1111-111111111111'
                },
                provider: 'email',
                lastSignInAt: '2024-01-01T00:00:00Z',
                createdAt: '2024-01-01T00:00:00Z',
                updatedAt: '2024-01-01T00:00:00Z',
              )
            ],
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
          ),
        ),
      ),
      );

      final response = await authenticator.login("testemail@test.com","testpassword");

      expect(response, AuthenticationResponses.success);
    });

    test("Sign up test",() async{

      when(() => supabaseAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => // Some fields may be null if "confirm email" is enabled.
      AuthResponse(
        user: const User(
          id: '11111111-1111-1111-1111-111111111111',
          aud: 'authenticated',
          role: 'authenticated',
          email: 'example@email.com',
          emailConfirmedAt: '2024-01-01T00:00:00Z',
          phone: '',
          lastSignInAt: '2024-01-01T00:00:00Z',
          appMetadata: {
            'provider': 'email',
            'providers': ['email']
          },
          userMetadata: {},
          identities: [
            UserIdentity(
              identityId: '22222222-2222-2222-2222-222222222222',
              id: '11111111-1111-1111-1111-111111111111',
              userId: '11111111-1111-1111-1111-111111111111',
              identityData: {
                'email': 'example@email.com',
                'email_verified': false,
                'phone_verified': false,
                'sub': '11111111-1111-1111-1111-111111111111'
              },
              provider: 'email',
              lastSignInAt: '2024-01-01T00:00:00Z',
              createdAt: '2024-01-01T00:00:00Z',
              updatedAt: '2024-01-01T00:00:00Z',
            ),
          ],
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z',
        ),
        session: Session(
          accessToken: '<ACCESS_TOKEN>',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: '<REFRESH_TOKEN>',
          user: const User(
            id: '11111111-1111-1111-1111-111111111111',
            aud: 'authenticated',
            role: 'authenticated',
            email: 'example@email.com',
            emailConfirmedAt: '2024-01-01T00:00:00Z',
            phone: '',
            lastSignInAt: '2024-01-01T00:00:00Z',
            appMetadata: {
              'provider': 'email',
              'providers': ['email']
            },
            userMetadata: {},
            identities: [
              UserIdentity(
                identityId: '22222222-2222-2222-2222-222222222222',
                id: '11111111-1111-1111-1111-111111111111',
                userId: '11111111-1111-1111-1111-111111111111',
                identityData: {
                  'email': 'example@email.com',
                  'email_verified': false,
                  'phone_verified': false,
                  'sub': '11111111-1111-1111-1111-111111111111'
                },
                provider: 'email',
                lastSignInAt: '2024-01-01T00:00:00Z',
                createdAt: '2024-01-01T00:00:00Z',
                updatedAt: '2024-01-01T00:00:00Z',
              )
            ],
            createdAt: '2024-01-01T00:00:00Z',
            updatedAt: '2024-01-01T00:00:00Z',
          ),
        ),
      ),
      );

      final response = await authenticator.signUp("testemail", "testpassword");

      expect(response,AuthenticationResponses.success);
    });

    test("Tests if login is unsuccessful because of invalid credentials",()async{

      when(() =>
          supabaseAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => throw AuthException("Invalid password or username"));

      final response = await authenticator.login("testemail", "testpassword");

      expect(response,AuthenticationResponses.failure);
    });

    test("Tests if login is unsuccessful because email is not confirmed",()async{

      when(() =>
          supabaseAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException("Invalid password or username"));

      final response = await authenticator.login("testemail", "testpassword");

      expect(response,AuthenticationResponses.failure);
    });
    
    test("Resend verfication email unsuccesfully",() async{
      
      when(() => supabaseAuth.resend(
        type: OtpType.signup,
        email: any(named:"email")
      )).thenThrow(AuthException("Invalid email"));

      final response = await authenticator.resendVerification();
      expect(response,AuthenticationResponses.failure);
    });

    test("Resend verification email succesfully",() async{

      when(() => supabaseAuth.resend(
          type: OtpType.signup,
          email: any(named:"email")
      )).thenAnswer((_) async => ResendResponse());

      final response = await authenticator.resendVerification();
      expect(response,AuthenticationResponses.success);
    });

    test("User is logged in",() async{

      when(() => supabaseAuth.refreshSession()).thenAnswer((_) async => AuthResponse());

      final response = await authenticator.isLoggedIn();
      expect(response,AuthenticationResponses.success);
    });

    test("User is not logged in",() async{
      when(() => supabaseAuth.currentUser).thenReturn(null);

      final response = await authenticator.isLoggedIn();
      expect(response,AuthenticationResponses.failure);
    });

  });

}