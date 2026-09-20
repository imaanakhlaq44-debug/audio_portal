/** Everything about the product that lives outside this codebase. */

export const siteUrl = 'https://qissora.app';

export const appStoreLinks = {
  googlePlay:
    'https://play.google.com/store/apps/details?id=com.imaanakhlaq.qissora',
  appStore: '#',

  /**
   * Whether the store listings are live. Neither is yet — the Play URL above
   * answers 404 — so `AppCta` shows "coming soon" rather than linking to it.
   * Flip this to true on the day the app is published, and check both URLs
   * above resolve before you do.
   */
  published: false,
};

export const contact = {
  whatsappDisplay: '+92 333 5756028',
  whatsappUrl: 'https://wa.me/923335756028',
  email: 'imaanakhlaq44@gmail.com',
};

export const nav = [
  { href: '/', label: 'Home' },
  { href: '/stories', label: 'Stories' },
  { href: '/categories', label: 'Categories' },
  { href: '/about', label: 'About' },
  { href: '/parents', label: 'Parents' },
];
