import { GoogleGenAI } from "@google/genai";

const getClient = () => {
  const apiKey = process.env.API_KEY;
  if (!apiKey) return null;
  return new GoogleGenAI({ apiKey });
};

export const generateBriefing = async (wave: number, score: number): Promise<string> => {
  const ai = getClient();
  if (!ai) {
    return `Mission Briefing: Wave ${wave}. Enemy squadron incoming. Engage at will. Good luck, pilot!`;
  }

  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: `Generate a short, intense, and slightly funny military-style mission briefing for a dogfight game involving dogs flying WW1 airplanes.
      The player is "Commander Bark".
      Current Wave: ${wave}.
      Previous Score: ${score}.
      The enemy is the "Meow Luftwaffe" or "Squirrel Squadron".
      Keep it under 30 words.`,
    });
    return response.text || "Communication jammed. Scramble fighters!";
  } catch (error) {
    console.error("Gemini briefing failed:", error);
    return `Priority Message: Wave ${wave} inbound. Defend the fire hydrant!`;
  }
};
