const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json({ limit: "1mb" }));

app.get("/", (req, res) => {
res.status(200).json({
app: "D.A.V.I.S. ULTRA JARVIS",
status: "online"
});
});

app.get("/health", (req, res) => {
res.status(200).json({
status: "ok",
apiKeyConfigured: Boolean(process.env.OPENROUTER_API_KEY)
});
});

app.post("/chat", async (req, res) => {
try {
const message = req.body?.message;

if (typeof message !== "string" || !message.trim()) {
  return res.status(400).json({
    error: "Mete yon mesaj anvan."
  });
}

const apiKey = process.env.OPENROUTER_API_KEY;

if (!apiKey) {
  console.error("OPENROUTER_API_KEY pa konfigire.");
  return res.status(500).json({
    error: "Sèvè a poko gen kle API a."
  });
}

const response = await fetch(
  "https://openrouter.ai/api/v1/chat/completions",
  {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "X-Title": "D.A.V.I.S. ULTRA JARVIS"
    },
    body: JSON.stringify({
      model: "openrouter/free",
      messages: [
        {
          role: "system",
          content:
            "Ou se D.A.V.I.S., yon asistan pèsonèl entèlijan, " +
            "pwofesyonèl, kalm, itil ak natirèl. " +
            "Ou ka reponn an kreyòl ayisyen oswa an franse, " +
            "selon lang moun nan itilize. Reponn klèman."
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
    error: "Sèvis AI a pa t kapab reponn. Eseye ankò."
  });
}

const answer = data?.choices?.[0]?.message?.content;

if (typeof answer !== "string" || !answer.trim()) {
  console.error("OpenRouter returned no answer:", data);

  return res.status(502).json({
    error: "AI a pa voye okenn repons."
  });
}

return res.status(200).json({
  reply: answer.trim()
});

} catch (error) {
console.error("Chat server error:", error);

return res.status(500).json({
  error: "Yon erè rive sou sèvè a."
});

}
});

app.listen(PORT, "0.0.0.0", () => {
console.log("D.A.V.I.S. ap koute sou pò ${PORT}");
});
