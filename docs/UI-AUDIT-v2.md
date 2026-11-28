# UI audit v2 (before the premium redesign)

Date: 2026-11-28 · baseline = v1.0.7 (indigo/violet, Tajawal, Material defaults).

## File map (lib/)

| file | lines |
|---|---|
| `lib/app/app.dart` | 31 |
| `lib/app/env.dart` | 16 |
| `lib/app/providers.dart` | 74 |
| `lib/app/router.dart` | 152 |
| `lib/core/auth/auth_controller.dart` | 138 |
| `lib/core/auth/auth_repository.dart` | 48 |
| `lib/core/auth/token_store.dart` | 15 |
| `lib/core/design/spacing.dart` | 30 |
| `lib/core/design/theme.dart` | 157 |
| `lib/core/design/tones.dart` | 17 |
| `lib/core/design/typography.dart` | 25 |
| `lib/core/format/dates.dart` | 46 |
| `lib/core/format/money.dart` | 27 |
| `lib/core/format/plural.dart` | 21 |
| `lib/core/format/promo_schedule.dart` | 12 |
| `lib/core/format/store_status.dart` | 53 |
| `lib/core/network/api_client.dart` | 124 |
| `lib/core/network/api_envelope.dart` | 47 |
| `lib/core/network/api_exception.dart` | 13 |
| `lib/core/strings.dart` | 272 |
| `lib/core/utils/arabic_duration.dart` | 9 |
| `lib/core/utils/ascii_digits.dart` | 18 |
| `lib/core/utils/formatters.dart` | 51 |
| `lib/core/utils/idempotency.dart` | 15 |
| `lib/core/utils/launchers.dart` | 42 |
| `lib/core/utils/product_name.dart` | 70 |
| `lib/core/utils/server_time.dart` | 18 |
| `lib/core/utils/spec_normalizer.dart` | 162 |
| `lib/core/utils/sudan_phone.dart` | 10 |
| `lib/core/widgets/cart_button.dart` | 70 |
| `lib/core/widgets/fly_to_cart.dart` | 95 |
| `lib/core/widgets/illustrations.dart` | 187 |
| `lib/core/widgets/price_text.dart` | 53 |
| `lib/core/widgets/product_card.dart` | 208 |
| `lib/core/widgets/shimmer.dart` | 128 |
| `lib/core/widgets/wex_kit.dart` | 213 |
| `lib/core/widgets/wex_scaffold_shell.dart` | 52 |
| `lib/core/widgets/wex_widgets.dart` | 288 |
| `lib/core/widgets/whatsapp_glyph.dart` | 34 |
| `lib/data/models/app_notification.dart` | 34 |
| `lib/data/models/auth_tokens.dart` | 23 |
| `lib/data/models/cart_item.dart` | 90 |
| `lib/data/models/catalog_meta.dart` | 36 |
| `lib/data/models/content.dart` | 76 |
| `lib/data/models/order.dart` | 245 |
| `lib/data/models/product.dart` | 204 |
| `lib/data/models/shop.dart` | 45 |
| `lib/data/models/user.dart` | 32 |
| `lib/data/repositories/catalog_repository.dart` | 34 |
| `lib/data/repositories/content_repository.dart` | 33 |
| `lib/data/repositories/me_repository.dart` | 26 |
| `lib/data/repositories/notification_repository.dart` | 25 |
| `lib/data/repositories/order_repository.dart` | 83 |
| `lib/data/repositories/product_repository.dart` | 99 |
| `lib/data/repositories/push_repository.dart` | 51 |
| `lib/features/account/account_screen.dart` | 196 |
| `lib/features/account/push_preferences_screen.dart` | 66 |
| `lib/features/auth/login_screen.dart` | 234 |
| `lib/features/auth/verify_screen.dart` | 187 |
| `lib/features/cart/cart_controller.dart` | 91 |
| `lib/features/cart/cart_screen.dart` | 428 |
| `lib/features/catalog/catalog_controller.dart` | 133 |
| `lib/features/catalog/catalog_screen.dart` | 295 |
| `lib/features/checkout/checkout_screen.dart` | 553 |
| `lib/features/content/content_page_screen.dart` | 43 |
| `lib/features/content/faq_screen.dart` | 46 |
| `lib/features/home/home_screen.dart` | 403 |
| `lib/features/notifications/notifications_screen.dart` | 101 |
| `lib/features/orders/order_detail_screen.dart` | 511 |
| `lib/features/orders/orders_screen.dart` | 429 |
| `lib/features/product/product_detail_screen.dart` | 428 |
| `lib/features/push/push_service.dart` | 136 |
| `lib/firebase_options.dart` | 26 |
| `lib/main.dart` | 22 |
| `lib/ui/app_scaffold.dart` | 35 |
| `lib/ui/app_sheet.dart` | 39 |
| `lib/ui/app_top_bar.dart` | 51 |
| `lib/ui/bottom_nav.dart` | 95 |
| `lib/ui/buttons.dart` | 94 |
| `lib/ui/cart_action.dart` | 78 |
| `lib/ui/elevation.dart` | 10 |
| `lib/ui/gradients.dart` | 11 |
| `lib/ui/icons.dart` | 1 |
| `lib/ui/money_text.dart` | 40 |
| `lib/ui/product_card.dart` | 172 |
| `lib/ui/product_image.dart` | 55 |
| `lib/ui/qty_stepper.dart` | 55 |
| `lib/ui/section_header.dart` | 39 |
| `lib/ui/skeleton.dart` | 66 |
| `lib/ui/states.dart` | 48 |
| `lib/ui/tag.dart` | 66 |

## Architecture notes
- State: Riverpod (no codegen). Routing: go_router (StatefulShellRoute, 4 tabs). HTTP: dio via `ApiClient`.
- Theme: `core/design/*` (now token-driven: `tokens/tokens.json` -> `colors.g.dart`).
- Old widget layer `core/widgets/*` is being replaced by `lib/ui/*`.

## Defects found (confirmed from screenshots) and where they come from
**Home**: trust chips clipped/invisible (fixed-height horizontal chip row, `home_screen.dart` `_TrustRow` 44px); faded laptop icon over headline (`_Hero` decorative icon); cart badge detached/clipped (`CartButton` badge at `end:-2`); blank gap under "أحدث الأجهزة" (no skeleton/empty state, `featured.when(error: SizedBox)`); hero overlaps search (stacked negative offset).
**Store**: stray dark semicircle above the nav (leftover overlay/FAB-like widget in `catalog_screen.dart` / shell); blank area under results; oversized condition pill over image; photos cropped (`BoxFit.cover`); "+" gives no feedback.
**Product**: cart badge clipped; spec chips wrap unevenly; price shown twice (body + sticky bar); specs hidden behind sticky bar (no bottom inset).
**Cart**: line price ambiguous (no unit price); heavy vertical stepper; discount shown twice; bag icon on "continue"; dead area.
**Orders**: order number wraps + repeated truncated; red stripe clipped by radius; filter chips clipped; big gradient summary card for "no active orders".
**Order details**: every timeline step green check (even rejected); status title twice; timeline bottom clipped (no bottom inset).
**Account**: last card hidden under the nav (no bottom inset).
**Global**: radii 6/10/12/14/24 mixed; violet gradients; `Colors.*` and `Color(0x..)` literals in screens; BoxShadow in many widgets; Tajawal.

## Root-cause fixes in v2
- `AppScaffold.listPadding` supplies the bottom inset for every scroll view; `AppBottomNav` owns its own safe-area.
- One cart icon (`CartAction`) with the badge inside a 48px box.
- Contain-on-sunken `ProductPhoto`; content-driven two-column rows (no fixed aspect ratio).
- Skeleton / empty / error states for each list; hero removed (no overlap possible).
