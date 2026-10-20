const express = require("express");

const app = express();

app.use(express.json({ limit: "20kb" }));

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.OPENROUTER_API_KEY;

app.get("/", (req, res) => {
  res.status(200).json({
    app: "D.A.V.I.S. ULTRA JARVIS",
    status: "online",
    chat: "/chat"
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    apiConfigured: Boolean(API_KEY)
  });
});

app.post("/chat", async (req, res) => {
  try {
    if (!API_KEY) {
      console.error("OPENROUTER_API_KEY is missing.");

      return res.status(500).json({
        error: "La clé API OpenRouter n'est pas configurée."
      });
    }

    const message = req.body?.message;

    if (
      typeof message !== "string" ||
      message.trim().length === 0
    ) {
      return res.status(400).json({
        error: "Écris un message pour D.A.V.I.S."
      });
    }

    if (message.length > 10000) {
      return res.status(413).json({
        error: "Le message est trop long."
      });
    }

    const controller = new AbortController();

    const timeout = setTimeout(() => {
      controller.abort();
    }, 60000);

    let response;

    try {
      response = await fetch(
        "https://openrouter.ai/api/v1/chat/completions",
        {
          method: "POST",

          headers: {
            "Authorization": `Bearer ${API_KEY}`,
            "Content-Type": "application/json",
            "X-Title": "D.A.V.I.S. ULTRA JARVIS"
          },

          body: JSON.stringify({
            model: "openrouter/free",

            messages: [
              {
                role: "system",

                content:
                  "Tu es D.A.V.I.S., l'assistant personnel " +
                  "de Kim Dolce. Tu es intelligent, calme, " +
                  "professionnel, utile et respectueux. " +
                  "Réponds en français si l'utilisateur " +
                  "écrit en français, et en créole haïtien " +
                  "s'il écrit en créole haïtien. " +
                  "Donne des réponses claires et naturelles. " +
                  "Ne prétends pas avoir effectué une action " +
                  "sur le téléphone si tu ne l'as pas réellement " +
                  "effectuée. Tu es un assistant IA."
              },

              {
                role: "user",
                content: message.trim()
              }
            ]
          }),

          signal: controller.signal
        }
      );
    } finally {
      clearTimeout(timeout);
    }

    const data = await response.json();

    if (!response.ok) {
      console.error(
        "OpenRouter error:",
        response.status,
        JSON.stringify(data).slice(0, 2000)
      );

      return res.status(502).json({
        error:
          data?.error?.message ||
          "OpenRouter ne peut pas répondre actuellement."
      });
    }

    const answer =
      data?.choices?.[0]?.message?.content;

    if (
      typeof answer !== "string" ||
      answer.trim().length === 0
    ) {
      console.error(
        "OpenRouter returned no text:",
        JSON.stringify(data).slice(0, 2000)
      );

      return res.status(502).json({
        error: "L'IA n'a renvoyé aucune réponse textuelle."
      });
    }

    return res.status(200).json({
      reply: answer.trim()
    });
  } catch (error) {
    console.error("D.A.V.I.S. server error:", error);

    if (error.name === "AbortError") {
      return res.status(504).json({
        error: "Le délai de réponse de l'IA est dépassé."
      });
    }

    return res.status(500).json({
      error: "Erreur interne du serveur D.A.V.I.S."
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(
    `D.A.V.I.S. ULTRA JARVIS running on port ${PORT}`
  );
});
