import 'package:flutter/material.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/main.dart';

class LangButton extends StatefulWidget {
  const LangButton({super.key});

  @override
  State<LangButton> createState() => _LangButtonState();
}

class _LangButtonState extends State<LangButton> {
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title:  Text(
                  local.translate('choose_language'),
                  style:const TextStyle(color: AppColors.scondaryColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        color: AppColors.scondaryColor,
                      ),
                      title:  Text(local.translate('english')),
                      onTap: () {
                        SehhaApp.of(context).setLocale(const Locale('en'));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        color: AppColors.scondaryColor,
                      ),
                      title:  Text(local.translate('arabic')),
                      onTap: () {
                        SehhaApp.of(context).setLocale(const Locale('ar'));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient:const LinearGradient(
              colors: [AppColors.lightBlue, AppColors.scondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
            const  Icon(Icons.language, color: Colors.white),
            const  SizedBox(width: 12),
              Text(
                local.translate('choose_language'),
                style:const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
