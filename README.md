# 🚀 StarWireHub - منصة استكشاف مستودعات GitHub والبدائل الحرة

تطبيق **Flutter** احترافي وعصري مبني لاستكشاف ومتابعة أكثر مستودعات البرمجيات الحرة (FOSS) رواجاً ونمواً في مجتمع المطورين العالمي، مع ملخصات ذكية باللغة العربية، بدائل برمجية مفتوحة المصدر، ومزامنة ساعية مع إشعارات تفصيلية.

[![Google Play Ready](https://img.shields.io/badge/Google%20Play-Ready-success?logo=googleplay)](google_play_package)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Privacy Policy](https://img.shields.io/badge/Privacy%20Policy-Available-green)](PRIVACY_POLICY.md)

---

## 🔒 سياسة الخصوصية الرسمية (Privacy Policy)
* رابط سياسة الخصوصية المعتمد لمتجر Google Play:
  👉 **[عرض وثيقة سياسة الخصوصية (PRIVACY_POLICY.md)](PRIVACY_POLICY.md)**

---

## ✨ أبرز مزايا تطبيق StarWireHub

### 1. 🔍 استكشاف المشاريع الرائجة (Trending Velocity)
* شريط متحرك يعرض أسرع المشاريع نمواً وإقبالاً خلال الأسبوع الحالي.
* فرز متقدم: حسب معدل النمو الأسبوعي، الأكثر نجوماً، الأكثر تفرعاً (Forks)، أو الأحدث.
* بحث فوري ذكي باسم الأداة، لغة البرمجة، أو البديل التجاري.

### 2. ⚡ دليل البدائل الحرة (FOSS Alternatives)
* استبدل البرامج والخدمات التجارية المغلقة (مثل Notion, Figma, Slack, 1Password, CleanMyMac) ببدائل مجانية ومفتوحة المصدر وقابلة للاستضافة الذاتية (Self-Hosted).

### 3. 🤖 ملخصات ذكية باللغة العربية
* بطاقة ملخص مخصصة لكل مشروع باللغة العربية تشرح الفكرة الجوهرية، سبب تصدر المشروع، وتوفر إمكانية التبديل الفوري بين الشرح العربي والإنجليزي.

### 4. 📊 تكامل حي ومباشر مع GitHub
* إحصائيات حية وفورية تشمل: النجوم، التفرعات، المشاكل المفتوحة (Open Issues)، المتابعين، الترخيص، وحجم الكود.
* قارئ مدمج لملفات `README.md` مع دعم كامل لتنسيق الماركداون والشيفرات البرمجية.
* أوامر نسخ سريعة بلمسة واحدة للاستنساخ والتشغيل (`git clone`).

### 5. 🔔 مزامنة ساعية وإشعارات تفصيلية فخمة
* خدمة فحص دورية آلية في الخلفية كل 60 دقيقة لاكتشاف أي مشاريع جديدة أو إصدارات واعدة فور نزولها.
* إشعارات غنية وموسعة (`BigTextStyleInformation`) تعرض بطاقة المشروع الكاملة في شريط إشعارات الجهاز.

### 6. 📱 تصميم متجاوب (Responsive UI) وخطوط عربية عصرية
* دعم كامل للوضع النهاري فائق النقاء (Light Mode - Slate & Indigo).
* تجربة متكيفة مع الهواتف الذكية (Bottom Navigation) والأجهزة اللوحية (Tablet Persistent Sidebar & Multi-column Grid).
* مبدّل خطوط حي يتيح لك الاختيار بين: **كايرو (Cairo)**، **تجوّل (Tajawal)**، **المراعي (Almarai)**، و**الإسكندرية (Alexandria)**.

---

## 🛠️ البنية التقنية (Architecture)

```text
lib/
├── main.dart                      # نقطة الانطلاق، MultiProvider، والتهيئة
├── models/
│   ├── github_repo.dart           # نموذج بيانات مستودعات Starwire
│   └── github_live_details.dart   # بيانات GitHub الحية وإحصائيات الإصدارات
├── providers/
│   ├── repo_provider.dart         # إدارة حالة البحث والفلترة والمفضلة
│   └── theme_provider.dart        # إدارة الخطوط والثيم والتخزين المحلي
├── services/
│   ├── api_service.dart           # جلب فهرس البيانات وتخزينه محلياً
│   ├── github_service.dart        # واجهة API الحية لـ GitHub وقارئ README
│   ├── arabic_summary_service.dart# توليد وتخزين الملخصات العربية الذكية
│   └── sync_notification_service.dart # المزامنة الساعية والإشعارات التفصيلية
├── theme/
│   └── app_theme.dart             # الألوان والخطوط وتناسق الواجهات
├── utils/
│   └── responsive.dart            # كشف التابلت وحساب الأعمدة الشبكية
├── widgets/
│   ├── app_logo.dart              # الشعار الرسمي الموحد للتطبيق
│   ├── repo_card.dart             # بطاقة عرض المشروع الاحترافية
│   ├── trending_slider.dart       # شريط المشاريع الصاعدة
│   ├── stat_badge.dart            # شارات الأرقام والنجوم
│   └── filter_sheet.dart          # نافذة التصفية والفرز
└── screens/
    ├── splash_screen.dart         # شاشة البداية المتحركة
    ├── main_navigation_screen.dart# الشاشة الحاضنة المتجاوبة
    ├── explore_screen.dart        # واجهة الاستكشاف الرئيسية
    ├── alternatives_screen.dart   # واجهة البدائل الحرة
    ├── bookmarks_screen.dart      # واجهة المفضلة المحفوظة
    ├── repo_details_screen.dart   # واجهة تفاصيل المشروع الشاملة
    └── settings_screen.dart       # واجهة الإعدادات والخطوط والمزامنة
```

---

## 📦 حزمة النشر على Google Play

يتضمن المشروع مجلد `google_play_package/` المجهز بالكامل للنشر الفوري:
* **Package Name**: `com.starwirehub.app`
* **Release Bundle**: `google_play_package/release/app-release.aab`
* **Graphics**: الأيقونة 512x512، البنر الترويجي 1024x500، ولقطات شاشة الهاتف والتابلت.

---

## 📄 الترخيص (License)
هذا المشروع منشور تحت ترخيص [MIT License](LICENSE).
