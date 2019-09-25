/*
Stillsuit
================================================================================
A Service Worker implementation designed to work out of the box with server-side
rendered progressive web apps.

Strategies
------------------------------------------------------------
NOTE: most of these are idealized, and not necessariliy reflected in the code below.  Consider this section one giant TODO.

### Static Caching

**Setup:** Generate files w/ hash in webpack.
  - Need to do this in webpack in order to properly test cache-busting in dev, since Elixir only makes the hash in prod via `mix phx.digest`.
  - Also to generate a manifest file in dev, for the same reason.

**Install:** Store in a static cache w/o versioning.  The hash does this for us.
  -  Adding new / modified files won't interfere with running service workers, since they will get a new path entry due to the changed hash.
  -  Also store the manifest for later.

**Activate:** Remove all files not included in the manifest.
  - Will only remove deleted files / old versions, since we're comparing to the saved manifest.

**Fetch:** Cache falling back to network.
  * https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#cache-falling-back-to-network
  * Need to cache & store google fonts here, since they load the actual font files in the stylesheet's fontface definition, and seem to change that URL a fair bit. https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#on-network-response
  * Is the web fallback necessary?  Since the service worker won't install if it couldn't load the files in the activate phase?
  * How do we detect / load changes to static files / changes to the manifest in currently-running service workers?  The service worker won't go thru another `activate` phase unless it is changed.

### Main Page Caching

TODO

**Setup:** none

**Install:** current page

**Activate:** none

**Fetch:** Network falling back to cache, w/ an "on network response" caching strategy.
  - https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#network-falling-back-to-cache
  - https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#on-network-response
  - Have a "go offline" button which grabs a copy of each page in the app.
  - If logout route is hit then clear the cache.  FUTURE: only clear logged in routes?
  - NOTE: cache, then network would be better: https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#network-falling-back-to-cache

### Dynamic Caching

Load pages from cache, rehydrate w/ server response when it comes in.

Use the requests thing to keep long-running pages fresh, w/ user notification (changes available).

### Form Submissions

Immediate when online.

Queue and replay when offline
.
*/

/*
Setup
------------------------------------------------------------
*/
const SITE = 'toolbox';
const CACHES = {
  static: 'cache:' + SITE + ':static',
  pages: 'cache:' + SITE + ':pages'
};

// returns a promise w/ a list of static asset paths to store
function getStaticAssetPaths() {
  console.log("getStaticAssetPaths()");

  return fetch('/cache_manifest.json')
    .then(function(response) {
      if (response.status === 404) {
        console.log("getStaticAssetPaths() => `cache_manifest.json` not found, probably in dev");

        // HACK: no cache manifest, we're probably in the dev environment
        //       ... or offline
        // TODO: use `process.env.MIX_ENV` in webpack to choose the manifest
        //       loading function, choosing this in dev
        // TODO: have webpack produce a manifest for all output files during
        //       dev builds?
        // TODO: just use that instead of elixir's cache_manifest.json
        //       instead? would require building the content hash in webpack
        return {
          version: 'dev',
          latest: {
            a: 'css/app.css',
            b: 'css/vendors~app.css',
            c: 'images/1x1.png',
            d: 'images/logos/DA_lettermark_blue.svg',
            e: 'js/app.js',
            f: 'js/vendors~app.js',
            g: 'favicon.ico'
          }
        };
      }
      else {
        console.log('getStaticAssetPaths() => received `cache_manifest.json`');
        return response.json();
      }
    })

    .then(function(cacheManifest) {
      var paths = Object.values(cacheManifest.latest).filter(function(path) {
        return path.match(/^(images|css|js|fonts)/);
      });

      paths.push('/offline-not-loaded');
      paths.push('/offline-not-supported');

      console.log('getStaticAssetPaths() => paths: ', paths);

      return paths;
    });

}

/*
Install
------------------------------------------------------------
*/
self.addEventListener('install', function(event) {
  console.log('SW::install');

  // based on: https://www.botsquad.com/2018/03/07/phoenix-sw/
  event.waitUntil(
    getStaticAssetPaths()
      .then(function(paths) {
        caches.open(CACHES.static).then(function(cache) {
          console.log('SW::install => opened static asset cache & added paths');
          return cache.addAll(paths);
        });
      })
  );
});

/*
Activate
------------------------------------------------------------
*/
self.addEventListener('activate', function(event) {
  console.log('SW::activate');

  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      // TODO: also clean out-of-date assets in each cache, since their newer
      // versions would be downloaded & cached in previous iterations?
      // TODO: can automate by comparing static cached files w/ the static cache
      // manifest above (same thing with whole caches- compare existing names
      // w/ names in `CACHES` above).
      return Promise.all(
        cacheNames.filter(function(cacheName) {
          // Return true if you want to remove this cache,
          // but remember that caches are shared across
          // the whole origin
        }).map(function(cacheName) {
          return caches.delete(cacheName);
        })
      );
    })
  );
});

/*
Fetch
------------------------------------------------------------
*/
self.addEventListener('fetch', function(event) {
  console.log('SW::fetch');

  console.log('EVENT: ', event.request.destination);

  event.respondWith(

    // try the static asset cache first
    caches.open(CACHES.static).then(function(cache) {
      console.log('SW::fetch => opened static assets');
      return cache.match(event.request);
    })

    .then(function(response) {
      // return a response from the static asset cache if we get it
      if (response) {
        console.log('SW::fetch => static assets match');
        return response;
      }

      // otherwise if it's a document implement the network => cache fallback strategy
      else if (event.request.destination == 'document') {
        console.log('SW::fetch => document - trying to fetch');
        return caches.open(CACHES.pages).then(function(cache) {
          return fetch(event.request)
            .then(function(response) {
              // save the latest copy
              console.log('SW::fetch => document - fetched, storing and returning');
              cache.put(event.request, response.clone());
              return response;
            })
            .catch(function() {
              console.log('SW::fetch => document - could not fetch, returning cached copy if it exists');
              return cache.match(event.request);
            });
        });
      }

      else {
        // if everything else fails try to grab it from the network
        // this is ok!  e.g. static assets use this part to implement the "network fallback" part of their approach
        console.log('SW::fetch => nothing else worked- try to fetch from network');
        return fetch(event.request);
      }
    })
  );
});
