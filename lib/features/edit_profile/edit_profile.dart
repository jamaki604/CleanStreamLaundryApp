import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'controller.dart';
import 'widgets/section_header.dart';
import 'widgets/info_card.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final controller = EditProfileController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Edit Profile")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SectionHeader(title: "Full Name"),
                  InfoCard(label: "Current", value: controller.currentName),
                  TextFormField(controller: controller.nameController),

                  SectionHeader(title: "Email"),
                  InfoCard(label: "Current", value: controller.currentEmail),
                  TextFormField(controller: controller.emailController),

                  ElevatedButton(
                    onPressed: controller.isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final emailChanged = await controller.saveChanges();
                            if (emailChanged) {
                              context.go('/change-email-verification');
                            }
                          },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
