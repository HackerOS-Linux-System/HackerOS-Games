// Local briefing service to replace API dependency
const BRIEFINGS = [
  "Commander Bark! The Meow Luftwaffe is stealing our bones. Intercept them!",
"Squirrel Squadron spotted over the Atlantic. Try not to get distracted!",
"Enemy Ace 'Red Laser' is inbound. He's fast, but you're a good boy.",
"Protect the fire hydrants at all costs. Scramble!",
"Intelligence reports a large shipment of catnip. Shoot it down!",
"They called you a 'Bad Dog'. Show them who's a Good Boy.",
"Wave incoming! Remember: Aim for the tail!",
"Dogfight Night protocol engaged. Bark loud, bite hard.",
"The postman has joined the enemy fleet. This is personal.",
"Tailwinds are strong today. Use the clouds for cover!"
];

export const generateBriefing = async (wave: number, score: number): Promise<string> => {
  // Simulate a short "decoding" delay for effect
  await new Promise(resolve => setTimeout(resolve, 800));

  const randomMsg = BRIEFINGS[Math.floor(Math.random() * BRIEFINGS.length)];
  return `Wave ${wave} // ${randomMsg}`;
};
