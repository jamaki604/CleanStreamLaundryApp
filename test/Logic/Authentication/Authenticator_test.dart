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

    test("Tests if login is unsuccessful",()async{

      when(() =>
          supabaseAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => throw AuthException("Invalid password or username"));

      final response = await authenticator.login("testemail", "testpassword");

      expect(response,AuthenticationResponses.failure);
    });


  });

}