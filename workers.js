export default {
  async fetch(request) {
    let url = new URL(request.url);

    // 仅允许 /dns-query
    if (url.pathname !== "/dns-query") {
      return new Response("Not Found", { status: 404 });
    }

    // 目标 DoH 服务器
    let targetURL = "https://dns.google/dns-query" + url.search;

    let modifiedRequest = new Request(targetURL, {
      method: request.method,
      headers: new Headers(request.headers),
      body: request.body,
      redirect: "follow"
    });

    // 设置正确的 Host 头，避免 Google 拒绝请求
    modifiedRequest.headers.set("Host", "dns.google");
    modifiedRequest.headers.set("Accept", "application/dns-message");

    let response = await fetch(modifiedRequest);

    let newHeaders = new Headers(response.headers);
    newHeaders.set("Access-Control-Allow-Origin", "*"); // 允许 CORS

    return new Response(response.body, {
      status: response.status,
      headers: newHeaders
    });
  }
}
