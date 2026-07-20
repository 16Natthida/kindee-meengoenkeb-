import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';

class _OnboardPage {
  final IconData icon;
  final String title;
  final String desc;
  const _OnboardPage(this.icon, this.title, this.desc);
}

const _pages = [
  _OnboardPage(
    Icons.pie_chart_rounded,
    'แบ่งเงินเดือนอัตโนมัติ',
    'กรอกเงินเดือนครั้งเดียว ระบบแบ่งเงินเป็นหมวดให้ทันที',
  ),
  _OnboardPage(
    Icons.receipt_long_rounded,
    'บันทึกรายจ่ายง่าย ๆ',
    'บันทึกทุกรายจ่ายและดูเงินคงเหลือแต่ละหมวดได้ทันที',
  ),
  _OnboardPage(
    Icons.restaurant_menu_rounded,
    'วางแผนเมนูตามงบ',
    'วางแผนอาหารให้พอดีกับงบ ลดของเหลือ ลดรายจ่ายเกินตัว',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _finish() {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('ข้าม'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 88, color: AppColors.seedGreen),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.desc,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.seedGreen
                        : AppColors.seedGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(_index == _pages.length - 1 ? 'เริ่มต้นใช้งาน' : 'ถัดไป'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
