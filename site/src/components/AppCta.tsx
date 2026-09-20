import { appStoreLinks } from '@/lib/site';

/**
 * A "get the app" button that tells the truth before the app is listed.
 *
 * Both store links pointed at listings that do not exist yet — the Play URL
 * answers 404 and the App Store one was "#" — across the navbar, the hero, the
 * footer, both players and two pages. Until `appStoreLinks.published` flips,
 * each of those renders as a plain "coming soon" label instead of a link that
 * throws a parent into a Google error page.
 */
export function AppCta({
  store = 'googlePlay',
  className = 'btn-primary',
  children,
}: {
  store?: 'googlePlay' | 'appStore';
  className?: string;
  children: React.ReactNode;
}) {
  if (!appStoreLinks.published) {
    return (
      <span
        className={`${className} cursor-default opacity-70 hover:translate-y-0`}
        aria-disabled="true"
      >
        {store === 'appStore'
          ? 'Coming soon on the App Store'
          : 'Coming soon on Google Play'}
      </span>
    );
  }

  return (
    <a href={appStoreLinks[store]} className={className}>
      {children}
    </a>
  );
}
