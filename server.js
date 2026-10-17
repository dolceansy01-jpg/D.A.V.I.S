const express = require("express");

const app = express();
app.use(express.json({ limit: "10kb" }));

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.OPENROUTER_API_KEY;

app.get("/", (req, res) => {
  res.json({
    app: "D.A.V.I.S. ULTRA JARVIS",
    status: "online"
  });
});

app.post("/chat", async (req, res) => {
  try {
    if (!API_KEY) {
      return res.status(500).json({
        error: "La clé API du serveur n'est pas configurée."
      });
    }

    const message = req.body.message;

    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        error: "Écris un message pour D.A.V.I.S."
      });
    }

    const response = await fetch(
      "https://openrouter.ai/api/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${API_KEY}`,
          "Content-Type": "application/json",
          "X-Title": "DAVIS ULTRA JARVIS"
        },
        body: JSON.stringify({
          model: "openrouter/free",
          messages: [
            {
              role: "system",
              content:
                "Tu es D.A.V.I.S., un assistant personnel intelligent, calme et professionnel. Tu aides Kim Dolce. Tu réponds en français ou en créole haïtien selon la langue utilisée."
            },
            {
              role: "user",
              content: message.trim()
            }
          ]
        })
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error("OpenRouter error:", response.status, data);

      return res.status(502).json({
        error: "Le service IA est indisponible. Réessaie plus tard."
      });
    }

    const answer = data.choices?.[0]?.message?.content;

    if (!answer) {
      return res.status(502).json({
        error: "L'IA n'a pas renvoyé de réponse."
      });
    }

    res.json({ reply: answer });
  } catch (error) {
    console.error("Server error:", error.message);

    res.status(500).json({
      error: "Une erreur est survenue sur le serveur."
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`D.A.V.I.S. server running on port ${PORT}`);
});
