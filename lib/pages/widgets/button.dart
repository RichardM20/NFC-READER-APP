import 'package:flutter/material.dart';
import 'package:svg_flutter/svg_flutter.dart';

class CustomButtonAction extends StatelessWidget {
  const CustomButtonAction({
    super.key,
    required this.textButton,
    this.onTap,
  });
  final Function()? onTap;
  final String textButton;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 1,
              offset: const Offset(-0.0, -0.0),
            ),
          ],
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/nfc_icon.svg',
              color: Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(
              textButton,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
