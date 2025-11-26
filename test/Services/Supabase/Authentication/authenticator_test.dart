import 'dart:async';

import 'package:clean_stream_laundry_app/Logic/Enums/authentication_response_enum.dart';
import 'package:clean_stream_laundry_app/Services/Supabase/supabase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main(){
  late SupabaseAuthService authenticator;
  late SupabaseMock client;
  late GoTrueMock supabaseAuth;

  group("Authentication Tests", (){

    setUp((){
      client = SupabaseMock();
      supabaseAuth = GoTrueMock();
      when(() => client.auth).thenReturn(supabaseAuth);

      authenticator = SupabaseAuthService(client: client);

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
      when(() => supabaseAuth.signOut()).thenAnswer((_) async {});

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
          emailRedirectTo: 'clean-stream://email-verification'
      )).thenAnswer((_) async =>
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

      final response = await authenticator.signUp("testemail", "testpassword123G@");

      expect(response,AuthenticationResponses.success);
    });

    test("Sign up test has no digit",() async{

      when(() => supabaseAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: 'clean-stream://email-verification'
      )).thenAnswer((_) async =>
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

      final response = await authenticator.signUp("testemail", "testpasswordG");

      expect(response,AuthenticationResponses.noDigit);
    });

    test("Sign up test no special character",() async{

      when(() => supabaseAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: 'clean-stream://email-verification'
      )).thenAnswer((_) async =>
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

      final response = await authenticator.signUp("testemail", "testpassword123G");

      expect(response,AuthenticationResponses.noSpecialCharacter);
    });

    test("Sign up test no upper case",() async{

      when(() => supabaseAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: 'clean-stream://email-verification'
      )).thenAnswer((_) async =>
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

      final response = await authenticator.signUp("testemail", "testpassword123@");

      expect(response,AuthenticationResponses.noUppercase);
    });

    test("Sign up test no digit",() async{

      when(() => supabaseAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: 'clean-stream://email-verification'
      )).thenAnswer((_) async =>
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

      final response = await authenticator.signUp("testemail", "test");

      expect(response,AuthenticationResponses.lessThanMinLength);
    });

    test("Tests if login is unsuccessful because of invalid credentials", () async {
      when(() => supabaseAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => AuthResponse(
        user: null,
        session: null,
      ));

      final response = await authenticator.login("testemail", "testpassword");

      expect(response, AuthenticationResponses.failure);
    });


    test("Tests if login is unsuccessful because email is not confirmed",()async{

      when(() =>
          supabaseAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthApiException("Email Not Confirmed",code:'email_not_confirmed',statusCode:"400"));

      final response = await authenticator.login("testemail", "testpassword");

      expect(response,AuthenticationResponses.emailNotVerified);
    });

    test("Resend verification email unsuccessfully",() async{

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

    test("Verifying that the logged out logic was called",() async {
      await authenticator.logout();
      verify(() => client.auth.signOut());
    });

    test("Should return that an email is not verified",() async{
      when(() => supabaseAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthApiException(
        'Email not verified',
        code: 'email_not_confirmed',
      ));

      final result = await authenticator.login("testEmail","testPassword");
      expect(result, AuthenticationResponses.emailNotVerified);
    });

    test("Test if an exception is thrown with a different code",() async{
      when(() => supabaseAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthApiException(
        'Email not verified',
        code: 'random-test-code',
      ));

      final result = await authenticator.login("testEmail","testPassword");
      expect(result, AuthenticationResponses.failure);
    });

    test("Test if an exception is thrown with an unkown exception",() async{
      when(() => supabaseAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception("Unknown exception"));

      final result = await authenticator.login("testEmail","testPassword");
      expect(result, AuthenticationResponses.failure);
    });

    test("Test that correctID is returned",(){
      final result = authenticator.getCurrentUserId;
      expect(result, "11111111-1111-1111-1111-111111111111");
    });

    test("Test that null is returned for no user being able to be found",(){
      when(() => supabaseAuth.currentUser).thenReturn(null);
      final result = authenticator.getCurrentUserId;
      expect(result, null);
    });

    test("Tests if the email is verified",(){

      final testUser = User(
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
      );


      when(() => supabaseAuth.currentUser).thenReturn(testUser);
      var result = authenticator.isEmailVerified();
      expect(result, true);
    });

    test("Tests if the email is not verified",(){

      final testUser = User(
        id: '11111111-1111-1111-1111-111111111111',
        aud: 'authenticated',
        role: 'authenticated',
        email: 'example@email.com',
        emailConfirmedAt: null,
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
      );


      when(() => supabaseAuth.currentUser).thenReturn(testUser);
      var result = authenticator.isEmailVerified();
      expect(result, false);
    });

    test("onAuthChange emits true when a user exists", () async {
      final client = SupabaseMock();
      final auth = GoTrueMock();

      final controller = StreamController<AuthState>();

      when(() => supabaseAuth.onAuthStateChange)
          .thenAnswer((_) => Stream.value(AuthState(
        AuthChangeEvent.signedIn,
        Session(
          accessToken: '',
          tokenType: 'bearer',
          expiresIn: 3600,
          refreshToken: '',
          user: supabaseAuth.currentUser!,
        ),
      )));

      when(() => auth.onAuthStateChange).thenAnswer((_) => controller.stream);

      final fakeUser = User(
        id: "123",
        aud: "",
        role: "",
        email: "",
        phone: "",
        createdAt: "",
        updatedAt: "",
        appMetadata: {},
        userMetadata: {},
        identities: [],
      );

      final fakeSession = Session(
        accessToken: "",
        tokenType: "",
        user: fakeUser,
        expiresIn: 3600,
      );


      expectLater(authenticator.onAuthChange, emits(true));

      controller.add(AuthState(AuthChangeEvent.signedIn, fakeSession));
    });

    test("onAuthChange emits false when a user doesn't exist", () async {

      final controller = StreamController<AuthState>();
      when(() => supabaseAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

      expectLater(authenticator.onAuthChange, emits(false));

      controller.add(AuthState(AuthChangeEvent.signedOut, null));

    });

  });

}