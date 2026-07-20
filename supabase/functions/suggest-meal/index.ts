// supabase/functions/suggest-meal/index.ts
//
// Edge Function นี้เป็นจุดเดียวที่แอปเรียกเพื่อขอคำแนะนำเมนูจาก AI (Claude)
// ANTHROPIC_API_KEY เก็บเป็น Supabase Function Secret เท่านั้น ไม่เคยส่งลงแอป Flutter
//
// Deploy: supabase functions deploy suggest-meal
// ตั้ง Secret: supabase secrets set ANTHROPIC_API_KEY=sk-ant-xxxxx

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY');
const ANTHROPIC_MODEL = Deno.env.get('ANTHROPIC_MODEL') ?? 'claude-sonnet-5';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface CandidateTemplate {
  id: string;
  name: string;
  category: string;
  price: number;
  prepMinutes: number;
  difficulty: string;
  requiredEquipment: string[];
  ingredients: string[];
}

interface RequestBody {
  mealType: string;
  peopleCount: number;
  maxPrice: number | null;
  allergies: string[];
  dislikedFoods: string[];
  availableEquipment: string[];
  preferredDifficulty: string;
  nearExpiryIngredients: string[];
  stockIngredients: string[];
  recentMealNames: string[];
  candidateTemplates: CandidateTemplate[];
}

function buildPrompt(body: RequestBody): string {
  return `คุณเป็นผู้ช่วยแนะนำเมนูอาหารสำหรับแอปวางแผนอาหารตามงบประมาณของคนไทย

เงื่อนไขของผู้ใช้:
- มื้อ: ${body.mealType}
- จำนวนคนทาน: ${body.peopleCount}
- งบสูงสุดต่อคน: ${body.maxPrice ?? 'ไม่จำกัด'} บาท
- แพ้วัตถุดิบเหล่านี้ (ห้ามแนะนำเด็ดขาด): ${body.allergies.join(', ') || 'ไม่มี'}
- ไม่ชอบกิน: ${body.dislikedFoods.join(', ') || 'ไม่มี'}
- อุปกรณ์ที่มี: ${body.availableEquipment.join(', ') || 'ไม่ระบุ'}
- ระดับความยากที่ชอบ: ${body.preferredDifficulty}
- วัตถุดิบใกล้หมดอายุในบ้าน (ควรพยายามใช้ก่อน): ${body.nearExpiryIngredients.join(', ') || 'ไม่มี'}
- วัตถุดิบที่มีอยู่แล้วในบ้าน: ${body.stockIngredients.join(', ') || 'ไม่มี'}
- เมนูที่ทานไปแล้วในช่วงนี้ (ควรเลี่ยงไม่ให้ซ้ำ): ${body.recentMealNames.join(', ') || 'ไม่มี'}

เมนูที่มีอยู่ในฐานข้อมูลแอป (เลือกจากลิสต์นี้ก่อนถ้ามีตัวที่เหมาะสม):
${JSON.stringify(body.candidateTemplates, null, 2)}

หน้าที่ของคุณ:
1. ถ้ามีเมนูในฐานข้อมูลที่เหมาะสม (ไม่แพ้, ไม่เกินงบ, มีอุปกรณ์ครบ, ไม่ซ้ำเมนูล่าสุด) ให้เลือกมา 1 เมนู
2. ถ้าไม่มีเมนูในฐานข้อมูลที่เหมาะสมเลย ให้คิดเมนูใหม่ที่เหมาะกับเงื่อนไขทั้งหมด โดยเฉพาะการใช้วัตถุดิบใกล้หมดอายุ
3. ห้ามแนะนำเมนูที่มีส่วนผสมตรงกับรายการแพ้อาหารเด็ดขาด ไม่ว่ากรณีใด

ตอบกลับเป็น JSON เท่านั้น ห้ามมีข้อความอื่นนอกเหนือจาก JSON ตามโครงสร้างนี้เป๊ะ:
{
  "source": "template" หรือ "custom",
  "templateId": "uuid ของเมนูที่เลือก หรือ null ถ้าเป็น custom",
  "name": "ชื่อเมนู",
  "reason": "เหตุผลสั้น ๆ ไม่เกิน 1 ประโยค เป็นภาษาไทย",
  "estimatedPricePerServing": ตัวเลขราคาประมาณต่อคน,
  "prepMinutes": ตัวเลขนาทีที่ใช้เตรียม,
  "difficulty": "easy" หรือ "medium" หรือ "hard",
  "ingredients": [{"name": "ชื่อวัตถุดิบ", "quantity": ตัวเลข, "unit": "หน่วย"}]
}`;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (!ANTHROPIC_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'ยังไม่ได้ตั้งค่า ANTHROPIC_API_KEY บน Supabase Function Secrets' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const body = (await req.json()) as RequestBody;

    const anthropicRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: ANTHROPIC_MODEL,
        max_tokens: 800,
        temperature: 0.4,
        messages: [{ role: 'user', content: buildPrompt(body) }],
      }),
    });

    if (!anthropicRes.ok) {
      const errText = await anthropicRes.text();
      return new Response(
        JSON.stringify({ error: `Anthropic API error: ${errText}` }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const anthropicData = await anthropicRes.json();
    const rawText: string = anthropicData?.content?.[0]?.text ?? '';

    // ตัดกรณี Claude ห่อ JSON ด้วย ```json ... ``` เผื่อไว้
    const cleaned = rawText.replace(/```json/g, '').replace(/```/g, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(cleaned);
    } catch {
      return new Response(
        JSON.stringify({ error: 'AI ตอบกลับไม่เป็น JSON ที่ถูกต้อง', raw: rawText }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // ตรวจสอบซ้ำฝั่งเซิร์ฟเวอร์ว่าไม่มีวัตถุดิบที่แพ้หลุดมา (Defense in depth)
    const ingredientNames: string[] = (parsed.ingredients ?? []).map((i: { name: string }) =>
      (i.name ?? '').toLowerCase(),
    );
    const hasAllergen = body.allergies.some((a) =>
      ingredientNames.some((name) => name.includes(a.toLowerCase())),
    );
    if (hasAllergen) {
      return new Response(
        JSON.stringify({ error: 'AI แนะนำเมนูที่มีวัตถุดิบที่แพ้ ระบบปฏิเสธคำแนะนำนี้เพื่อความปลอดภัย' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(JSON.stringify(parsed), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
