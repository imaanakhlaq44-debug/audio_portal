# qissora.app

The Qissora website: a Next.js static export, served by Cloudflare Workers at
[qissora.app](https://qissora.app).

It is built from the app's own design and content — the same palette, the same
covers, the same captions. Every series is browsable, the first episode of each
plays free in a mini player that follows you down the page, and the app's
privacy policy lives here at `/app-privacy`, which is the URL Google Play is
given.

## Running it

```bash
npm install
npm run dev
```

## Deploying

```bash
npm run deploy
```

That is `next build` followed by `wrangler deploy`. The static export lands in
`out/` and is uploaded as Cloudflare assets; `wrangler.jsonc` points both
`qissora.app` and `www.qissora.app` at the Worker, and Cloudflare issues the
certificates. Declaring those routes turns the `workers.dev` URL off on
purpose, so the site has one canonical address.

## Where things are

```
src/
  app/            one folder per route; app-privacy/ is the app's policy
  components/     Hero, StoryRail, StoryCard, the players, page furniture
    player/       PlayerProvider (one audio element for the whole site)
                  and the MiniPlayer that docks at the bottom
  data/
    stories.ts            helpers: covers, audio URLs, durations
    stories.generated.ts  the catalogue, generated from the app
  lib/site.ts     canonical URL, contact details, store links
scripts/
  gen-stories.mjs  regenerates stories.generated.ts from lib/models/series/
```

Content is **not** edited here. `npm run gen:stories` reads the app's generated
series files and rewrites `src/data/stories.generated.ts`, so the site and the
app can never disagree about what a series contains. Audio is streamed from
`audio.qissora.app`, the same bucket the app uses.

## Before launch day

The store listings are not live yet, so `appStoreLinks.published` in
`src/lib/site.ts` is `false` and every "get the app" button renders as "coming
soon" rather than linking to a 404. Flip it to `true` once the app is
published, after checking both store URLs in that file resolve.
