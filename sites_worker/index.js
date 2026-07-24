const cacheHeaders = {
  "Cache-Control": "public, max-age=31536000, immutable",
};

const htmlHeaders = {
  "Cache-Control": "no-cache",
  "Content-Type": "text/html; charset=utf-8",
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const assetPath = url.pathname === "/" ? "/index.html" : url.pathname;
    const response = await fetchAsset(env, request, url, assetPath);

    if (response.status === 404 && !assetPath.includes(".")) {
      return fetchAsset(env, request, url, "/index.html");
    }

    if (assetPath.endsWith(".html")) {
      return withHeaders(response, htmlHeaders);
    }

    if (assetPath.endsWith(".js") || assetPath.endsWith(".wasm")) {
      return withHeaders(response, cacheHeaders);
    }

    return response;
  },
};

async function fetchAsset(env, request, url, assetPath) {
  const normalized = assetPath.startsWith("/") ? assetPath : `/${assetPath}`;
  const candidates = [
    normalized,
    normalized.slice(1),
    `/client${normalized}`,
    `client${normalized}`,
    `/public${normalized}`,
    `public${normalized}`,
    `/dist${normalized}`,
    `dist${normalized}`,
  ];

  for (const candidate of candidates) {
    const response = await env.ASSETS.fetch(
      new Request(new URL(candidate, url.origin), request),
    );
    if (response.status !== 404) {
      return response;
    }
  }

  return env.ASSETS.fetch(new Request(new URL(normalized, url.origin), request));
}

function withHeaders(response, headers) {
  const nextHeaders = new Headers(response.headers);
  for (const [key, value] of Object.entries(headers)) {
    nextHeaders.set(key, value);
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: nextHeaders,
  });
}
