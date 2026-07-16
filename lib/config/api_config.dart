class ApiConfig {

  // URL del tuo Cloudflare Worker (proxy verso Gemini).
  // Sostituiscilo con l'URL vero che vedi nella dashboard Cloudflare.
  static const String proxyUrl =
      'solitary-bird-f26f.vmangieri27.workers.dev';

  // Deve essere IDENTICO al valore di APP_SHARED_SECRET
  // che hai impostato su Cloudflare in Settings > Variables and Secrets.
  static const String appSharedSecret =
      'solitary-bird-f26f.vmangieri27.workers.dev';

}