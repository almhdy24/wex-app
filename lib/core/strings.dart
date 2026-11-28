import 'utils/formatters.dart';

/// All user-facing Arabic copy, centralized. Modern Standard Arabic, warm,
/// Sudanese-friendly. Keep short and consistent.
abstract final class Ar {
  // Brand
  static const appName = 'ويكس تكنولوجي';

  // Nav
  static const navHome = 'الرئيسية';
  static const navStore = 'المتجر';
  static const navOrders = 'طلباتي';
  static const navAccount = 'حسابي';

  // Home
  static const heroTitle = 'لابتوب يناسب شغلك ودراستك';
  static const heroSubtitle =
      'أجهزة مستوردة بأسعار واضحة، ونثبّت لك السعر بعد الطلب';
  static const searchHint = 'ابحث عن لابتوب أو ماركة';
  static const seeAll = 'عرض الكل';
  static const sectionNewest = 'أحدث الأجهزة';
  static const catLaptops = 'الحواسيب';
  static const catPhones = 'الهواتف';
  static const catAccessories = 'الملحقات';
  static const notFoundTitle = 'ما لقيت اللي تبحث عنه؟';
  static const notFoundBody = 'كلّمنا على واتساب ونساعدك نلقى الجهاز المناسب.';
  static const contactWhatsapp = 'تواصل عبر واتساب';
  static const callStore = 'اتصل بالمحل';
  static const openMaps = 'الموقع على الخريطة';

  // Trust row (facts only)
  static const trustImported = 'أجهزة مستوردة';
  static const trustLock = 'تثبيت السعر ٤ ساعات';
  static const trustPickup = 'استلام من المحل';
  static const trustDelivery = 'توصيل حسب المنطقة';

  // Product
  static const condNew = 'جديد';
  static const condUsed = 'مستعمل مستورد';
  static const lowStock = 'كمية محدودة';
  static const outOfStock = 'غير متوفر';
  static const specs = 'المواصفات';
  static const pickupDelivery = 'الاستلام والتوصيل';
  static const compatible = 'ملحقات متوافقة';
  static const similar = 'أجهزة مشابهة';
  static const addToCart = 'أضف إلى السلة';
  static const added = 'أُضيف إلى السلة';
  static const viewCart = 'عرض السلة';
  static const orderNow = 'اطلب الآن';
  static const whatsappInquiry = 'استفسر عبر واتساب';
  static const share = 'مشاركة';
  static const compare = 'مقارنة';
  static const priceMayChange = 'السعر قابل للتغيير حتى تأكيد الطلب.';

  // Cart
  static const cart = 'السلة';
  static const cartEmpty = 'السلة فارغة';
  static const cartEmptyCta = 'تصفّح الأجهزة';
  static const subtotal = 'المجموع الفرعي';
  static const discountLine = 'خصم الطلب من التطبيق';
  static const deliveryLater = 'رسوم التوصيل تُحسب في الخطوة التالية';
  static const total = 'الإجمالي';
  static const youSave = 'وفّرت';
  static const continueLabel = 'متابعة';
  static const removed = 'تم حذف المنتج';
  static const undo = 'تراجع';

  // Checkout
  static const checkout = 'إتمام الطلب';
  static const stepCart = 'السلة';
  static const stepCheckout = 'إتمام الطلب';
  static const stepDone = 'تم';
  static const receiveMethod = 'طريقة الاستلام';
  static const pickup = 'الاستلام من المحل';
  static const pickupFree = 'مجانًا';
  static const delivery = 'التوصيل';
  static const deliveryByArea = 'حسب المنطقة';
  static const deliveryArea = 'منطقة التوصيل';
  static const chooseArea = 'اختر المنطقة';
  static const deliveryAddress = 'عنوان التوصيل بالتفصيل';
  static const phoneLabel = 'رقم الهاتف (واتساب)';
  static const phoneHint = '09XXXXXXXX';
  static const notesOptional = 'ملاحظات (اختياري)';
  static const confirmOrder = 'تأكيد الطلب';
  static const lockNotice = 'بعد التأكيد نثبّت لك السعر ٤ ساعات لتكمل التحويل';
  static const ordersClosed = 'استقبال الطلبات متوقف مؤقتًا.';

  // Order / success
  static const orderCreated = 'تم استلام طلبك';
  static const orderConfirmHint =
      'ثبّتنا لك السعر. حوّل المبلغ وارفع إشعار التحويل.';
  static const uploadProof = 'رفع إشعار التحويل';
  static const reupload = 'إعادة رفع الإشعار';
  static const proofUploaded = 'تم رفع إشعار التحويل';
  static const underReview = 'إشعارك قيد المراجعة، نؤكد الطلب بعد التحقق.';
  static const confirmed = 'تم تأكيد طلبك.';
  static const transferAccount = 'حساب التحويل';
  static const copied = 'تم النسخ';
  static const orderPath = 'مسار الطلب';
  static const reorder = 'أعد الطلب بالسعر الحالي';
  static const lockExpired = 'انتهت مهلة تثبيت السعر لهذا الطلب.';

  // Account
  static const myAccount = 'حسابي';
  static const sectionOrders = 'طلباتي';
  static const sectionSupport = 'الدعم والسياسات';
  static const notifications = 'الإشعارات';
  static const notifSettings = 'إعدادات الإشعارات';
  static const faq = 'الأسئلة الشائعة';
  static const terms = 'الشروط والأحكام';
  static const privacy = 'سياسة الخصوصية';
  static const returns = 'سياسة الاستلام والإرجاع';
  static const contactUs = 'تواصل معنا';
  static const logout = 'تسجيل الخروج';
  static const signedOut = 'سجّل الدخول للطلب والمتابعة';
  static const signIn = 'تسجيل الدخول';

  // Login
  static const loginTitle = 'أهلًا بك في ويكس';
  static const loginSubtitle = 'سجّل دخولك لتطلب وتتابع طلباتك';
  static const googleContinue = 'المتابعة بحساب Google';
  static const emailLogin = 'أو ادخل بالبريد الإلكتروني';
  static const emailHint = 'بريدك الإلكتروني';
  static const sendCode = 'أرسل لي الرمز';
  static const verifyTitle = 'أدخل رمز التحقق';
  static const resendIn = 'إعادة الإرسال خلال';
  static const resend = 'إعادة إرسال الرمز';
  static const nameHint = 'اسمك الكامل';
  static const confirmLogin = 'تأكيد الدخول';
  static const termsNote = 'بتسجيلك توافق على شروط الاستخدام وسياسة الخصوصية';

  // Common
  static const retry = 'إعادة المحاولة';
  static const loadError = 'تعذّر التحميل. حاول مرة أخرى.';
  static const noResults = 'لا توجد نتائج مطابقة';
  static const cancel = 'إلغاء';

  // Store / filters
  static const filterAll = 'الكل';
  static const filterLaptops = 'لابتوبات';
  static const filterPhones = 'هواتف';
  static const filterAccessories = 'ملحقات';
  static const sortNewest = 'الأحدث';
  static const sortPriceAsc = 'الأقل سعرًا';
  static const sortPriceDesc = 'الأعلى سعرًا';
  static const sortBy = 'ترتيب حسب';
  /// Arabic plural forms: 0 / نتيجة واحدة / نتيجتان / 3–10 نتائج / 11+ نتيجة.
  static String results(int n) {
    if (n <= 0) return 'لا توجد نتائج';
    if (n == 1) return 'نتيجة واحدة';
    if (n == 2) return 'نتيجتان';
    if (n <= 10) return '$n نتائج';
    return '$n نتيجة';
  }

  // Orders list / detail
  static const ordersSignedOut = 'سجّل الدخول لعرض طلباتك';
  static const ordersLoadError = 'تعذّر تحميل الطلبات';
  static const ordersEmpty = 'لا توجد طلبات بعد';
  static const stPending = 'بانتظار الدفع';
  static const stReview = 'مراجعة التحويل';
  static const stConfirmed = 'مؤكد';
  static const stCompleted = 'مكتمل';
  static const stCancelled = 'ملغي';
  static const stExpired = 'منتهي';
  static const orderDetails = 'تفاصيل الطلب';
  static const orderLoadError = 'تعذّر تحميل الطلب';
  static const uploadFailed = 'تعذّر رفع الإشعار';
  static const reorderFailed = 'تعذّر إعادة الطلب';
  static const lockHeading = 'السعر مثبّت — أكمل التحويل خلال';
  static const discount = 'الخصم';
  static const deliveryFee = 'رسوم التوصيل';
  static const accountCopied = 'تم نسخ رقم الحساب';

  // Notifications / content / push prefs
  static const markAllRead = 'قراءة الكل';
  static const notifEmpty = 'لا توجد إشعارات';
  static const pageFallbackTitle = 'صفحة المتجر';
  static const pageMissing = 'هذه الصفحة غير متوفرة حاليًا.';
  static const pushTitle = 'إشعارات التطبيق';
  static const prefOrders = 'تحديثات الطلب';
  static const prefPayments = 'تأكيد الدفع';
  static const prefPrices = 'تنبيهات الأسعار';
  static const prefOffers = 'العروض والإعلانات';
  static const testSent = 'تم إرسال إشعار تجريبي';
  static const sendTest = 'إرسال إشعار تجريبي';

  // Errors / validation / misc UI
  static const verifyCodeLen = 'الرمز مكوّن من 6 أرقام';
  static String verifySentTo(String email) => 'أرسلنا الرمز إلى\n$email';
  static String resendCountdown(int s) => '$resendIn $s ثانية';
  static const googleFailed =
      'تعذّر تسجيل الدخول عبر Google. جرّب البريد الإلكتروني.';
  static const invalidEmail = 'أدخل بريدًا إلكترونيًا صحيحًا';
  static const connectFailed = 'تعذّر الاتصال. حاول مرة أخرى.';
  static const orWord = 'أو';
  static const invalidPhone = 'أدخل رقم هاتف سوداني صحيح (مثال: 09XXXXXXXX)';
  static const pickZone = 'اختر منطقة التوصيل';
  static const addressNeeded = 'أدخل عنوان التوصيل بالتفصيل';
  static const orderFailed = 'تعذّر إنشاء الطلب. حاول مرة أخرى.';
  static const ordersPausedTitle = 'الطلبات متوقفة مؤقتًا';
  static const zonesLoadError = 'تعذّر تحميل مناطق التوصيل';
  static const contactHeading = 'التواصل';
  static String lockNoticeHours(String hours) =>
      'بعد التأكيد نثبّت لك السعر $hours لتكمل التحويل';
  static const deviceDetails = 'تفاصيل الجهاز';
  static const deviceLoadError = 'تعذّر تحميل الجهاز';
  static const description = 'الوصف';
  static const showLess = 'عرض أقل';
  static const showMore = 'عرض المزيد';
  static String waProductInquiry(String name) => 'مرحبًا، أسأل عن: $name';
  static const waLooking = 'مرحبًا، أبحث عن جهاز.';
  static const storeHeading = 'المتجر';
  static const whatsappLabel = 'واتساب';
  static const mapLabel = 'الخريطة';
  static const productsLoadError = 'تعذّر تحميل المنتجات';
  static const cartEmptyBody = 'أضف أجهزة إلى سلتك وتابع الطلب بسهولة.';
  static String versionLine(String v) => '$appName · الإصدار $v';
  static const condOpenBox = 'كرتونة مفتوحة';
  static const condRefurb = 'مجدد';
  static const chPayments = 'إشعارات الدفع';
  static const chOrders = 'تحديثات الطلبات';
  static const chOffers = 'العروض';
  static const serverUnexpected = 'استجابة غير متوقعة من الخادم';
  static const unexpectedError = 'حدث خطأ غير متوقع';

  // Order success
  static const orderNumberLabel = 'رقم الطلب';
  static const shareWhatsapp = 'مشاركة عبر واتساب';
  static String shareOrderText(String n) =>
      'طلبي من ويكس تكنولوجي — رقم الطلب: $n';
  static const nextStep = 'الخطوة التالية';

  // Product details (Round 2)
  static const inStock = 'متوفر';
  static const priceLabel = 'السعر';
  static const allSpecs = 'كل المواصفات';

  // Cart (Round 2)
  static String discountPercent(int pct) => 'خصم ${formatPercent(pct)}';
  static const completeSetup = 'أكمل جهازك';
  static const orderSummary = 'ملخص الطلب';
  static const itemsWord = 'منتجات';

  static String orderWaText(String n) => 'مرحبًا، بخصوص طلبي رقم $n';

  // Round 3 — orders list
  static const ordersAll = 'الكل';
  static const ordersProcessing = 'قيد التجهيز';
  static const ordersActiveHero = 'طلباتك النشطة';
  static String ordersActiveCount(int n) =>
      n == 0 ? 'لا طلبات نشطة الآن' : (n == 1 ? 'طلب واحد قيد المتابعة' : '$n طلبات قيد المتابعة');
  static const completeTransfer = 'أكمل التحويل';
  static const orderContactWa = 'تواصل عبر واتساب';
  static const orderAgain = 'اطلب مجددًا';
  static const browseStore = 'تصفّح المتجر';
  static String itemsChip(int n) => n == 1 ? 'قطعة واحدة' : (n == 2 ? 'قطعتان' : (n <= 10 ? '$n قطع' : '$n قطعة'));
  static String lockLeft(String t) => 'يتبقى $t';
  static const ordersEmptyTitle = 'لا طلبات بعد';
  static const ordersEmptyBody = 'اختر جهازك الأول وسنتولى الباقي.';
  static const ordersFilterEmpty = 'لا توجد طلبات في هذا التصنيف';

  // Round 3 — checkout sheet
  static const payMethod = 'وسيلة الدفع';
  static const bankTransfer = 'تحويل بنكي';
  static const bankTransferNote = 'ارفع إشعار التحويل بعد تأكيد الطلب';
  static String priceLockBadge(String d) => 'تثبيت السعر $d';
  static const confirmPickupBank = 'تأكيد الطلب · تحويل بنكي';
  static const confirmDeliveryBank = 'تأكيد الطلب والتوصيل · تحويل بنكي';
  static const close = 'إغلاق';
}
