# Egyptian Arabic Voice Guide — «كابتن كود»

All learner-facing UI, prompts, hints, and feedback use authentic, friendly Egyptian Arabic matching CodeHub's own tone (`TaskSupportNudge.tsx`, `DashboardPriorityStrip.tsx`, and the Basics lectures).

---

## 1. Persona: «كابتن كود»

- **Who**: A smart, encouraging Egyptian older-brother / senior developer sitting next to the student at a café with a laptop.
- **Rhythm**: Short punchy sentences (≤ 12 words in feedback toasts, ≤ 240 chars in coach bubbles).
- **Technical terms stay English** with Egyptian «الـ»:
  - Good: «الـ `<bdi>browser</bdi>`»، «الـ `<bdi>attribute</bdi>`»، «الـ `<bdi>closing tag</bdi>`»، «عشان الـ `<bdi>SEO</bdi>`»
  - Bad: «المتصفح الشبكي»، «السمة التوصيفية»، «وسم الإغلاق»
- **Digits**: Use **Arabic-Indic digits** (`٠١٢٣٤٥٦٧٨٩`) for UI counters and progress (`المستوى ٢ — المرحلة ٣ من ٥`), matching CodeHub's onboarding UI. Keep **Western digits** (`0-9`) inside code, HTML5, ports, CSS px, and XP/scores where mixed with Latin (`+10 XP`, `h1–h6`, `UTF-8`).
- **Diagnostic feedback**: A wrong answer ALWAYS names the exact misconception from `why`. Never output bare «غلط!» or «حاول مرة أخرى».

---

## 2. Banned Patterns (Zero Tolerance)

| Avoid | Why | Use Instead |
| :--- | :--- | :--- |
| «قم بإضافة…» / «يُرجى اختيار…» / «إن هذا الوسم…» | Stiff MSA — breaks the friendly CodeHub vibe | «ضيف…» / «اختار…» / «الـ tag ده…» |
| «دي سهلة جداً!» / «أي حد يعرفها» / «بسيطة» | Condescending if the student misses it | «فكرة صغيرة بس هتفرق معاك جداً» |
| «غلط» / «إجابة خاطئة» (alone) | Unhelpful, discouraging | «قرّبت! بس الـ `<span>` inline مش block» |
| Sarcasm, roasting, memes that age badly | Feels unprofessional | Warm hype: «عاش يا بطل!»، «دماغك شغالة 🔥» |
| English UI chrome (`Submit`, `Next`, `Hint`) | Breaks Arabic immersion | «اتأكد»، «اللي بعده»، «تلميحة» |

---

## 3. MSA → Egyptian Rewrite Table (15 Real Pairs)

| Formal MSA | Natural Egyptian («كابتن كود») |
| :--- | :--- |
| قم بسحب العنصر إلى مكانه الصحيح | اسحب العنصر وحطه في مكانه الصح |
| يُرجى التحقق من إجابتك | اتأكد من إجابتك |
| لاحظ أن هذا العنصر لا يحتاج إغلاقاً | خد بالك: العنصر ده مش محتاج closing tag |
| لقد أخطأت، حاول مجدداً | لأ مش دي، جرّب تاني وبص على التفاصيل |
| أحسنت، إجابة صحيحة | عاش يا وحش! بالظبط كده 🔥 |
| انتقل إلى المرحلة التالية | يلا على اللي بعده |
| استعرض التلميح | ورّيني تلميحة |
| أعد ضبط الكود | رجّع الكود من الأول |
| تم إكمال المستوى بنجاح | خلّصت المستوى! ⭐ |
| هذا الخطأ شائع بين المبتدئين | دي غلطة ناس كتير بتقع فيها |
| استكمل من حيث توقفت | كمّل من مكان ما وقفت |
| تذكّر القاعدة التالية | افتكر القاعدة الذهبية دي |
| اضغط على الجزء الخاطئ في الشيفرة | اضغط على الغلطة في الكود |
| اختر المخرج المتوقع | توقّع الصفحة هتطلع إزاي |
| اكتب ملخصك في لوحة التسليم بالأسفل | افتح «تقديم الحل» تحت واكتب ملخصك |

---

## 4. Built-in Phrase Bank (65+ Lines, 8 Slots)

Mirrored as `DEFAULT_VOICE` in `assets/lesson-shell.html` (engine picks without repeating the last line):

- **`ok` (Correct — 10)**:
  `عاش يا وحش! 🔥` · `بالظبط كده 👌` · `إيه الحلاوة دي!` · `دماغك شغالة ١٠/١٠ ⚡` · `معلّم! جبتها صح` · `صح الصح يا بطل 🎯` · `برافو عليك، مركّز النهارده!` · `شغل عالي أوي ✨` · `الله ينوّر عليك!` · `كسبت الجولة دي 💪`
- **`wrong` (Prefix before `why` — 8)**:
  `قرّبت جداً… ` · `مش دي، بص كده: ` · `حلو إنك جرّبت، بس ` · `استنى ثانية: ` · `قريبة! الفكرة إن ` · `فكّر فيها تاني: ` · `لا تقلق، خد بالك: ` · `تكة صغيرة فاتتك: `
- **`okSpot` (BugHunt valid-line tap — 5)**:
  `السطر ده سليم ١٠٠٪! دوّر في حتة تانية.` · `الكود هنا زي الفل، الغلطة مش هنا.` · `ده مظبوط، ركّز على باقي السطور.` · `الجزء ده بريء! بص حواليه.` · `تمام ده صح، فين الـ bug المستخبي؟`
- **`hint` (Prefix — 6)**:
  `تلميحة صغيرة: ` · `بص يا سيدي: ` · `مفتاح الحل: ` · `فكّر فيها كده: ` · `خد الغش ده مني: ` · `قرّب عينك هنا: `
- **`combo` (3+ first-try streak — 7)**:
  `🔥 كومبو! ٣ صح ورا بعض — النقط مضاعفة ×2!` · `🔥 إنت مولّعها النهارده! كومبو ×2 شغال!` · `🔥 مفيش حاجة توقفك! ×2 XP!` · `🔥 سلسة نار! كمّل كده!` · `🔥 تركيز أسطوري — نقط مضاعفة!` · `🔥 خطير يا بطل! الكومبو شغال!` · `🔥 واحد ورا التاني من غير غلطة!`
- **`reveal` (After 3 misses — 6)**:
  `ولا يهمك، المهم تفهمها! الإجابة الصح هنا:` · `عادي جداً، خلينا نشوف الصح وليه:` · `تعالى نثبتها سوا — ده الحل المظبوط:` · `مافيش مشكلة، بص على الحل الصح ده:` · `أهم حاجة الفهم — ده الصح:` · `احفظ الحركة دي عشان المرة الجاية:`
- **`bossIntro` (Boss start — 6)**:
  `جه وقت الوحش الكبير 👾 عندك ٣ قلوب — ورّينا شطارتك!` · `المعركة الأخيرة 👾 ٣ قلوب و١٠ تحديات، قدّها؟` · `الوحش صحى! 👾 ركّز كويس عندك ٣ قلوب.` · `يلا نختبر كل اللي اتعلمته ضد الوحش 👾` · `جاهز للتحدي النهائي؟ ٣ قلوب يا بطل 👾` · `ده امتحان الجدعان 👾 ٣ قلوب وانطلق!`
- **`levelDone` (Level clear — 9)**:
  `خلّصت المستوى بنجاح! ⭐ يلا على اللي بعده` · `مستوى كمان في الجيب! 🏆` · `إنت بتطير في الكورس ده 🚀` · `شغل فاخر! فتحت المستوى الجاي 🔓` · `عاش أوي! خطوة كمان ناحية الاحتراف 💪` · `أداء جامد! جاهز للتحدي اللي بعده؟` · `تم السيطرة على المستوى ده 🎯` · `كل مستوى بتبقى أقوى! ⭐` · `تمام التمام! يلا نكمّل الرحلة`
- **`resume` (Returning learner — 8)**:
  `أهلاً بيك تاني! نكمّل من مكان ما وقفت؟` · `رجعت يا بطل! مستعد نكمّل؟` · `حمدالله على السلامة 👋 يلا نكمّل الرحلة!` · `المستوى الجاي مستنيك — جاهز؟` · `كمّل من مكانك وخلي الإستريك شغال 🔥` · `يلا نرجع للعب ونتعلم أكتر!` · `وحشتنا! خلينا نكمّل اللي بدأناه` · `أهلاً يا نجم ⭐ نكمّل؟`
