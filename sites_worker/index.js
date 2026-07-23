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
    const assetUrl = new URL(assetPath, url.origin);
    const response = await env.ASSETS.fetch(new Request(assetUrl, request));

    if (response.status === 404 && !assetPath.includes(".")) {
      return env.ASSETS.fetch(new Request(new URL("/index.html", url.origin), request));
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
