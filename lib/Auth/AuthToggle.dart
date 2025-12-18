import 'package:flutter/material.dart';

class AuthToggle extends StatelessWidget {
  final bool login;
  final Function onToggle;
  const AuthToggle({required this.login,required this.onToggle ,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: login ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    color: login ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !login ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'REGISTER',
                  style: TextStyle(
                    color: !login ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}