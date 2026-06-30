import Foundation

/// The bundled seed catalogue that powers Svara's MVP offline. All content is
/// served through `LocalContentRepository`; swapping to Firestore later means
/// these arrays simply become the offline fallback.
enum SeedContent {

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day; c.hour = 9
        return Calendar.current.date(from: c) ?? Date()
    }

    // MARK: - Mantras

    static let mantras: [Mantra] = [
        Mantra(
            id: "mantra.om",
            title: "Om",
            sanskrit: "ॐ",
            transliteration: "om",
            translation: "The primordial sound.",
            meaning: "Often described as the sound from which all begins. A single syllable to gather attention and settle the breath before practice.",
            deity: "Universal",
            theme: .devotion,
            repetitions: 9,
            durationMinutes: 2,
            traditionNote: "Interpretations of Om are many; traditions vary by region and family.",
            reviewStatus: .humanReviewed
        ),
        Mantra(
            id: "mantra.vakratunda",
            title: "Vakratunda Mahakaya",
            sanskrit: "वक्रतुण्ड महाकाय सूर्यकोटि समप्रभ । निर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा ॥",
            transliteration: "vakratunda mahakaya suryakoti samaprabha, nirvighnam kuru me deva sarva-karyeshu sarvada",
            translation: "O Lord with the curved trunk and mighty form, bright as a million suns, make all my endeavours free of obstacles, always.",
            meaning: "A much-loved invocation to Ganesha said before starting something new — an exam, a journey, a venture — to steady the mind and clear the path.",
            deity: "Ganesha",
            theme: .courage,
            repetitions: 3,
            durationMinutes: 2,
            reviewStatus: .humanReviewed
        ),
        Mantra(
            id: "mantra.saraswatiNamastubhyam",
            title: "Saraswati Namastubhyam",
            sanskrit: "सरस्वति नमस्तुभ्यं वरदे कामरूपिणि ।",
            transliteration: "saraswati namastubhyam varade kama-rupini",
            translation: "Salutations to you, Saraswati, granter of boons and fulfiller of wishes.",
            meaning: "A student's prayer before study, inviting focus, learning, and the free flow of ideas.",
            deity: "Saraswati",
            theme: .knowledge,
            repetitions: 3,
            durationMinutes: 2,
            reviewStatus: .humanReviewed
        ),
        Mantra(
            id: "mantra.shiva",
            title: "Om Namah Shivaya",
            sanskrit: "ॐ नमः शिवाय",
            transliteration: "om namah shivaya",
            translation: "I bow to Shiva.",
            meaning: "The five-syllable mantra of Shiva, often chanted for stillness and inner quiet. A simple anchor for the breath.",
            deity: "Shiva",
            theme: .discipline,
            repetitions: 11,
            durationMinutes: 3,
            reviewStatus: .humanReviewed
        ),
        Mantra(
            id: "mantra.gayatri",
            title: "Gayatri Mantra",
            sanskrit: "ॐ भूर्भुवः स्वः । तत्सवितुर्वरेण्यं । भर्गो देवस्य धीमहि । धियो यो नः प्रचोदयात् ॥",
            transliteration: "Om bhur bhuvah svah, tat savitur varenyam, bhargo devasya dhimahi, dhiyo yo nah prachodayat.",
            translation: "We meditate on the radiant glory of the divine Sun; may it illuminate and inspire our minds.",
            meaning: "One of the oldest and most universal mantras, the Gayatri is a prayer for clarity of thought. It asks not for things, but for a brighter mind — making it a perfect way to begin the day.",
            deity: "Savitr (the Sun)",
            theme: .wisdom,
            repetitions: 9,
            durationMinutes: 3
        ),
        Mantra(
            id: "mantra.mahamrityunjaya",
            title: "Mahamrityunjaya Mantra",
            sanskrit: "ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् । उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात् ॥",
            transliteration: "Om tryambakam yajamahe sugandhim pushti-vardhanam, urvarukam iva bandhanan mrityor mukshiya maamritat.",
            translation: "We worship the three-eyed one who nourishes all beings; may we be freed from the bonds of suffering, like a ripe fruit from its stem.",
            meaning: "Known as the great healing mantra, it is chanted for strength, courage and recovery — a steadying presence in hard moments.",
            deity: "Shiva",
            theme: .protection,
            repetitions: 9,
            durationMinutes: 4
        ),
        Mantra(
            id: "mantra.ganesha",
            title: "Ganesha Mantra",
            sanskrit: "ॐ गं गणपतये नमः",
            transliteration: "Om gam ganapataye namaha.",
            translation: "Salutations to Ganesha, remover of obstacles.",
            meaning: "Chanted at the start of anything new — a journey, an exam, a venture — to clear the path ahead and steady the mind.",
            deity: "Ganesha",
            theme: .courage,
            repetitions: 11,
            durationMinutes: 2
        ),
        Mantra(
            id: "mantra.saraswati",
            title: "Saraswati Mantra",
            sanskrit: "ॐ ऐं सरस्वत्यै नमः",
            transliteration: "Om aim saraswatyai namaha.",
            translation: "Salutations to Saraswati, goddess of knowledge and the arts.",
            meaning: "A favourite of students and creators, this mantra invites focus, learning and the free flow of ideas.",
            deity: "Saraswati",
            theme: .knowledge,
            repetitions: 11,
            durationMinutes: 2
        ),
        Mantra(
            id: "mantra.lakshmi",
            title: "Lakshmi Mantra",
            sanskrit: "ॐ श्रीं महालक्ष्म्यै नमः",
            transliteration: "Om shreem mahalakshmyai namaha.",
            translation: "Salutations to Mahalakshmi, source of abundance and grace.",
            meaning: "Lakshmi represents not just wealth but well-being in every form. This mantra cultivates a mindset of gratitude and gentle abundance.",
            deity: "Lakshmi",
            theme: .prosperity,
            repetitions: 11,
            durationMinutes: 3
        ),
        Mantra(
            id: "mantra.shanti",
            title: "Shanti Mantra",
            sanskrit: "ॐ सर्वे भवन्तु सुखिनः सर्वे सन्तु निरामयाः । सर्वे भद्राणि पश्यन्तु मा कश्चिद्दुःखभाग्भवेत् ॥",
            transliteration: "Om sarve bhavantu sukhinah, sarve santu niramayah, sarve bhadrani pashyantu, ma kashchid duhkha-bhag bhavet.",
            translation: "May all be happy, may all be free from illness, may all see what is good; may none come to suffering.",
            meaning: "A prayer of universal goodwill. Chanting it at day's end softens the heart and turns attention outward, toward others.",
            deity: "Universal",
            theme: .compassion,
            repetitions: 3,
            durationMinutes: 3
        )
    ]

    // MARK: - Daily Practices

    static let dailyPractices: [DailyPractice] = [
        DailyPractice(
            id: "practice.morning.gayatri",
            title: "Morning Mantra",
            subtitle: "Greet the day with the Gayatri Mantra",
            kind: .mantra,
            timeOfDay: .morning,
            durationMinutes: 3,
            points: 15,
            mantraID: "mantra.gayatri",
            guidance: [
                "Sit comfortably and take three slow breaths.",
                "Chant along softly, following the transliteration.",
                "Let the meaning settle: a prayer for a clearer mind.",
                "Finish with a moment of stillness."
            ]
        ),
        DailyPractice(
            id: "practice.midday.breath",
            title: "Midday Reset",
            subtitle: "A one-minute breath to steady yourself",
            kind: .breathing,
            timeOfDay: .afternoon,
            durationMinutes: 2,
            points: 10,
            mantraID: nil,
            guidance: [
                "Breathe in for four counts.",
                "Hold gently for four counts.",
                "Breathe out for six counts.",
                "Repeat six times, letting your shoulders drop."
            ]
        ),
        DailyPractice(
            id: "practice.evening.prayer",
            title: "Evening Prayer",
            subtitle: "Close the day with the Shanti Mantra",
            kind: .prayer,
            timeOfDay: .evening,
            durationMinutes: 3,
            points: 15,
            mantraID: "mantra.shanti",
            guidance: [
                "Dim the lights and settle in.",
                "Chant the Shanti Mantra, wishing peace to all.",
                "Name one person you hope finds ease tonight.",
                "Rest in the quiet that follows."
            ]
        ),
        DailyPractice(
            id: "practice.evening.gratitude",
            title: "Three Gratitudes",
            subtitle: "Name three things you're grateful for today",
            kind: .gratitude,
            timeOfDay: .night,
            durationMinutes: 2,
            points: 10,
            mantraID: nil,
            guidance: [
                "Recall the day from morning to now.",
                "Choose three moments, however small, that you're thankful for.",
                "Hold each one in mind for a breath.",
                "Notice how gratitude feels in the body."
            ]
        )
    ]

    // MARK: - Lessons (the beginner Aaroh Path + beyond)
    //
    // Days 1–7 form the first guided path: Om → Vakratunda → Saraswati
    // Namastubhyam. Levels 8–9 continue beyond the path. Mirrors
    // seed_lessons.json (the authoring source of truth).

    static let lessons: [Lesson] = [
        Lesson(
            id: "lesson.om.sound",
            title: "The Sound of Om",
            subtitle: "Where every practice begins",
            theme: .devotion,
            level: 1,
            xp: 20,
            mantraID: "mantra.om",
            pathDay: 1,
            meaningOverview: "Om is a single syllable used to gather attention and settle the breath before anything else.",
            pronunciationTip: "Say it slowly as three soft sounds that melt together: a-u-m. Let the 'mmm' fade out gently.",
            insightTitle: "What Om means",
            insightBody: "One way to understand this: Om isn't a word with a fixed translation — it's a sound that marks a beginning, a way of arriving and settling before you practice. Traditions vary by family and region.",
            traditionNote: "Interpretations of Om are many; traditions vary by region and family.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "om1.s1", kind: .intro, prompt: "Meet Om",
                           detail: "Om is often the very first sound in a practice. You don't need to know anything yet — just arrive."),
                LessonStep(id: "om1.s2", kind: .listen, prompt: "Om",
                           detail: "Take a slow breath and say it softly three times. There's no perfect way — just let the sound settle you."),
                LessonStep(id: "om1.s3", kind: .matchMeaning, prompt: "Om is best described as…",
                           detail: "Choose the description that fits.",
                           options: ["A sound to gather attention", "A festival", "A type of food", "A river"],
                           correctIndex: 0,
                           hint: "Think about why it comes at the very start of a practice."),
                LessonStep(id: "om1.s4", kind: .reflection, prompt: "A small pause",
                           detail: "Notice your breath for one moment. That settling feeling is the whole point — nothing to get right.")
            ]
        ),
        Lesson(
            id: "lesson.om.breath",
            title: "Om & the Breath",
            subtitle: "Letting the sound carry the breath",
            theme: .devotion,
            level: 2,
            xp: 20,
            mantraID: "mantra.om",
            pathDay: 2,
            meaningOverview: "Om works best paired with a slow out-breath — the sound and the exhale steady each other.",
            pronunciationTip: "Begin the sound as you breathe out, and let the 'mmm' last as long as the breath does.",
            insightTitle: "Why Om and breath go together",
            insightBody: "One way to understand this: the long fading 'mmm' naturally slows your exhale, and a slower exhale calms the body. The sound is a gentle handle for the breath.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "om2.s1", kind: .intro, prompt: "Sound and breath",
                           detail: "Yesterday you met Om. Today, let it ride your out-breath."),
                LessonStep(id: "om2.s2", kind: .listen, prompt: "Breathe out on Om",
                           detail: "Breathe in quietly, then say Om as you breathe out. Repeat three unhurried times."),
                LessonStep(id: "om2.s3", kind: .fillBlank, prompt: "Om is easiest to say on the ______.",
                           detail: "Complete the line.",
                           options: ["out-breath", "in-breath", "tip-toes", "weekend"],
                           correctIndex: 0,
                           acceptedAnswers: ["out-breath", "out breath", "exhale"],
                           hint: "It pairs with letting air go, not taking it in."),
                LessonStep(id: "om2.s4", kind: .reflection, prompt: "Notice the after-quiet",
                           detail: "After the sound fades, there's a small stillness. You're building familiarity, not chasing perfection.")
            ]
        ),
        Lesson(
            id: "lesson.vakratunda.meet",
            title: "Meet Vakratunda",
            subtitle: "A prayer before beginnings",
            theme: .courage,
            level: 3,
            xp: 25,
            mantraID: "mantra.vakratunda",
            pathDay: 3,
            meaningOverview: "Vakratunda Mahakaya is a much-loved invocation to Ganesha, said before starting something new.",
            pronunciationTip: "Break it into gentle pieces: vak-ra-tun-da. No rush — one sound at a time.",
            insightTitle: "Who Vakratunda is",
            insightBody: "One way to understand this: 'Vakratunda' means the one with the curved trunk — an affectionate way of naming Ganesha. People often say this line before an exam, a journey, or any fresh start.",
            traditionNote: "Traditions vary by family and region.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "vk1.s1", kind: .intro, prompt: "A line for fresh starts",
                           detail: "Vakratunda Mahakaya is often said before beginning anything new — to steady the mind and clear the path."),
                LessonStep(id: "vk1.s2", kind: .listen, prompt: "Vakratunda Mahakaya",
                           detail: "Say it slowly, in four soft pieces: vak-ra-tun-da. Don't worry about speed."),
                LessonStep(id: "vk1.s3", kind: .matchMeaning, prompt: "People often say this line before…",
                           detail: "Choose what fits best.",
                           options: ["Starting something new", "Going to sleep", "A competition", "A meal"],
                           correctIndex: 0,
                           hint: "Think about exams, journeys, and beginnings."),
                LessonStep(id: "vk1.s4", kind: .reflection, prompt: "Your own beginning",
                           detail: "Bring to mind one thing you're about to start. Let this line keep it gentle company.")
            ]
        ),
        Lesson(
            id: "lesson.vakratunda.meaning",
            title: "What Vakratunda Means",
            subtitle: "Curved trunk, mighty form",
            theme: .courage,
            level: 4,
            xp: 25,
            mantraID: "mantra.vakratunda",
            pathDay: 4,
            meaningOverview: "The opening words describe Ganesha and ask for a path free of obstacles.",
            pronunciationTip: "'Mahakaya' is ma-ha-ka-ya — even and unhurried.",
            insightTitle: "What the words point to",
            insightBody: "One common translation: 'O Lord with the curved trunk and mighty form, make my endeavours free of obstacles.' One way to understand this: it isn't asking for an easy life, but for a clear, steady mind to meet what comes. Traditions vary by family and region.",
            sourceNote: "Translations vary; this is one widely-shared rendering.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "vk2.s1", kind: .meaning, prompt: "Curved trunk, mighty form",
                           detail: "'Vakratunda' is the curved trunk; 'Mahakaya' is the mighty form. Together they affectionately picture Ganesha."),
                LessonStep(id: "vk2.s2", kind: .matchMeaning, prompt: "'Vakratunda' refers to the…",
                           detail: "Choose the meaning.",
                           options: ["Curved trunk", "Bright sun", "Still lake", "Open road"],
                           correctIndex: 0,
                           hint: "It's the feature Ganesha is most known for."),
                LessonStep(id: "vk2.s3", kind: .fillBlank, prompt: "The line asks for a path free of ______.",
                           detail: "Complete the meaning.",
                           options: ["obstacles", "colour", "sound", "rain"],
                           correctIndex: 0,
                           acceptedAnswers: ["obstacles", "obstacle"],
                           hint: "Ganesha is fondly called the remover of these."),
                LessonStep(id: "vk2.s4", kind: .reflection, prompt: "Not an easy road, a clear mind",
                           detail: "Read the meaning once more, slowly. It's a wish for steadiness — not for everything to be simple.")
            ]
        ),
        Lesson(
            id: "lesson.vakratunda.smooth",
            title: "Saying It Smoothly",
            subtitle: "One sound at a time",
            theme: .courage,
            level: 5,
            xp: 30,
            mantraID: "mantra.vakratunda",
            pathDay: 5,
            meaningOverview: "Practising the syllables in order makes the line feel natural to say.",
            pronunciationTip: "Tap each piece in turn and say it aloud: vak · ra · tun · da.",
            insightTitle: "You can say it now",
            insightBody: "One way to understand this: fluency isn't about speed or a perfect accent — it's familiarity. Saying the syllables in order, a few times, is all it takes to make the line your own.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "vk3.s1", kind: .intro, prompt: "Build it up",
                           detail: "Let's put the sounds in order. There's no clock here — one sound at a time."),
                LessonStep(id: "vk3.s2", kind: .syllableOrder, prompt: "Arrange: Vakratunda",
                           detail: "Tap the syllables in order.",
                           syllables: ["vak", "ra", "tun", "da"],
                           hint: "It starts the same way the word looks: 'vak'."),
                LessonStep(id: "vk3.s3", kind: .syllableOrder, prompt: "Arrange: Mahakaya",
                           detail: "Tap the syllables in order.",
                           syllables: ["ma", "ha", "ka", "ya"],
                           hint: "Begin with 'ma'."),
                LessonStep(id: "vk3.s4", kind: .reflection, prompt: "Say the whole line",
                           detail: "Now say 'Vakratunda Mahakaya' once, softly, start to finish. That's it — you've got it.")
            ]
        ),
        Lesson(
            id: "lesson.saraswati.meet",
            title: "Meet Saraswati",
            subtitle: "The student's prayer",
            theme: .knowledge,
            level: 6,
            xp: 25,
            mantraID: "mantra.saraswatiNamastubhyam",
            pathDay: 6,
            meaningOverview: "Saraswati Namastubhyam is a short prayer said before study, inviting focus.",
            pronunciationTip: "Namastubhyam is na-mas-tu-bhyam — let the 'bhyam' stay soft.",
            insightTitle: "Who Saraswati is",
            insightBody: "One way to understand this: Saraswati is pictured with a veena and a book — music and learning flowing together. Students often greet her before opening their books.",
            traditionNote: "Traditions vary by family and region.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "sr1.s1", kind: .intro, prompt: "A greeting before study",
                           detail: "Saraswati Namastubhyam is a gentle hello to the spirit of learning, said before you begin to study."),
                LessonStep(id: "sr1.s2", kind: .listen, prompt: "Saraswati Namastubhyam",
                           detail: "Say it slowly: sa-ras-wa-ti na-mas-tu-bhyam. Soft and even."),
                LessonStep(id: "sr1.s3", kind: .matchMeaning, prompt: "Saraswati is associated with…",
                           detail: "Choose what fits.",
                           options: ["Knowledge and the arts", "The ocean", "Harvest", "Thunder"],
                           correctIndex: 0,
                           hint: "Think of a veena and a book."),
                LessonStep(id: "sr1.s4", kind: .reflection, prompt: "Your own learning",
                           detail: "Think of one thing you're trying to learn right now. This line is a kind way to begin.")
            ]
        ),
        Lesson(
            id: "lesson.saraswati.meaning",
            title: "What Saraswati Namastubhyam Means",
            subtitle: "Salutations, and a wish",
            theme: .knowledge,
            level: 7,
            xp: 30,
            mantraID: "mantra.saraswatiNamastubhyam",
            pathDay: 7,
            meaningOverview: "The line offers salutations to Saraswati and asks for focus and the free flow of learning.",
            pronunciationTip: "'Namastubhyam' simply means 'salutations to you' — say it warmly.",
            insightTitle: "What the words mean",
            insightBody: "One common translation: 'Salutations to you, Saraswati, granter of wishes.' One way to understand this: it's less a request for results and more a settling-in — a way to meet study with calm attention. Traditions vary by family and region.",
            sourceNote: "Translations vary; this is one widely-shared rendering.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "sr2.s1", kind: .meaning, prompt: "Namastubhyam — salutations to you",
                           detail: "'Namastubhyam' means 'salutations to you'. The line greets Saraswati and invites focus before study."),
                LessonStep(id: "sr2.s2", kind: .fillBlank, prompt: "'Namastubhyam' means salutations to ______.",
                           detail: "Complete the meaning.",
                           options: ["you", "the sky", "the past", "no one"],
                           correctIndex: 0,
                           acceptedAnswers: ["you"],
                           hint: "It's a warm, direct greeting."),
                LessonStep(id: "sr2.s3", kind: .syllableOrder, prompt: "Arrange: Namastubhyam",
                           detail: "Tap the syllables in order.",
                           syllables: ["na", "mas", "tu", "bhyam"],
                           hint: "It opens with 'na'."),
                LessonStep(id: "sr2.s4", kind: .reflection, prompt: "A calm way to begin",
                           detail: "You've reached the end of the first path. Say the whole line once, then notice how it feels to begin calmly.")
            ]
        ),
        Lesson(
            id: "lesson.gayatri.basics",
            title: "The Gayatri Mantra",
            subtitle: "A prayer for a clear mind",
            theme: .wisdom,
            level: 8,
            xp: 25,
            mantraID: "mantra.gayatri",
            meaningOverview: "An ancient dawn prayer asking not for things, but for a brighter, clearer mind.",
            pronunciationTip: "Take it phrase by phrase; the rhythm matters more than speed.",
            insightTitle: "What the Gayatri asks for",
            insightBody: "One way to understand this: it's a prayer for wisdom itself — for a mind clear enough to see well. Traditions vary by family and region.",
            sourceName: "Rig Veda 3.62.10",
            reviewStatus: .sourced,
            steps: [
                LessonStep(id: "l2.s1", kind: .intro, prompt: "The dawn prayer",
                           detail: "The Gayatri Mantra is among the oldest, traditionally said at sunrise."),
                LessonStep(id: "l2.s2", kind: .listen, prompt: "Om bhur bhuvah svah…",
                           detail: "Listen to the rhythm. Don't worry about perfect pronunciation."),
                LessonStep(id: "l2.s3", kind: .meaning, prompt: "What we ask for",
                           detail: "Not wealth or success — but a brighter, clearer mind. It is a prayer for wisdom itself."),
                LessonStep(id: "l2.s4", kind: .multipleChoice, prompt: "The Gayatri Mantra is a prayer for…",
                           options: ["A clear mind", "Rain", "Victory in battle", "Long hair"],
                           correctIndex: 0,
                           hint: "It asks for something within, not without.")
            ]
        ),
        Lesson(
            id: "lesson.shanti.peace",
            title: "A Prayer for All",
            subtitle: "The Shanti Mantra",
            theme: .compassion,
            level: 9,
            xp: 30,
            mantraID: "mantra.shanti",
            isPremium: true,
            meaningOverview: "A wish of happiness and freedom from suffering — for everyone, not just oneself.",
            pronunciationTip: "Let the repeated 'shanti' soften each time you say it.",
            insightTitle: "Widening the circle",
            insightBody: "One way to understand this: the prayer deliberately turns attention outward, wishing ease for all beings. Traditions vary by family and region.",
            reviewStatus: .humanReviewed,
            steps: [
                LessonStep(id: "l4.s1", kind: .intro, prompt: "Goodwill for everyone",
                           detail: "The Shanti Mantra wishes happiness and freedom from suffering for all beings."),
                LessonStep(id: "l4.s2", kind: .listen, prompt: "Sarve bhavantu sukhinah…",
                           detail: "Say it slowly, picturing the circle of care widening outward."),
                LessonStep(id: "l4.s3", kind: .fillBlank, prompt: "Sarve bhavantu ______ (happy)",
                           detail: "Complete the line.",
                           options: ["Sukhinah", "Niramayah", "Bhadrani", "Shanti"],
                           correctIndex: 0,
                           acceptedAnswers: ["sukhinah"],
                           hint: "It's the word glossed as 'happy'.")
            ]
        )
    ]

    // MARK: - Festivals

    static let festivals: [Festival] = [
        Festival(
            id: "festival.gurupurnima",
            name: "Guru Purnima",
            date: date(2026, 7, 29),
            tagline: "Honouring the teachers who light the way",
            significance: "A day to thank the mentors, guides and teachers — formal or not — who have shaped who you are.",
            story: "Traditions vary — here's one common story. Guru Purnima falls on the full moon honouring Sage Vyasa, traditionally credited with compiling the Vedas. The word 'guru' is often explained as 'one who dispels darkness'. The day reminds us that knowledge passed on with care is itself precious.",
            activities: [
                "Message a teacher or mentor to say thank you.",
                "Write down one lesson someone taught you that you still live by.",
                "Spend ten minutes learning something with full attention."
            ],
            theme: .knowledge,
            systemImage: "moon.circle.fill",
            shortDescription: "A full-moon day to thank the people who taught you something that stuck.",
            whyItMatters: "Most of who we are was quietly handed to us by someone. This is a moment to notice that, and say thanks.",
            symbols: [
                FestivalSymbol(name: "Full moon", meaning: "Often read as completeness and reflected light — wisdom passed from one to another."),
                FestivalSymbol(name: "Lamp", meaning: "A small light that lights other lamps without losing its own flame.")
            ],
            familyPrompt: "Ask someone in your family who their most memorable teacher was, and why.",
            regionTags: ["india", "global", "diaspora"],
            relatedPracticeID: "practice.morning.gayatri",
            relatedMantraID: "mantra.saraswati",
            tinyActivity: FestivalActivity(
                id: "festival.gurupurnima.activity",
                title: "Thank a teacher",
                durationMinutes: 3,
                steps: [
                    "Bring to mind one person who taught you something that stuck — a teacher, a coach, a relative, a friend.",
                    "Recall one specific thing they gave you.",
                    "If it feels right, send them a short message of thanks. If not, simply hold the gratitude for a moment."
                ],
                reflectionPrompt: "Who shaped you in a way they probably never knew?"
            ),
            isDateApproximate: true,
            sourceNote: "A widely-shared account; emphasis differs across lineages.",
            traditionNote: "Customs and dates can vary by region, lineage and family.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.rakshabandhan",
            name: "Raksha Bandhan",
            date: date(2026, 8, 28),
            tagline: "The thread that ties us together",
            significance: "A celebration of the bond between siblings — and of care, loyalty and looking out for one another.",
            story: "Traditions vary — here's one common story. Sisters tie a 'rakhi', a sacred thread, around their brothers' wrists, and brothers promise to look after them. Over time the festival has grown to celebrate every relationship built on protection and love, well beyond blood ties.",
            activities: [
                "Reach out to a sibling or a friend who feels like family.",
                "Tie or send a rakhi — even a digital one counts.",
                "Recall a time someone had your back, and thank them."
            ],
            theme: .protection,
            systemImage: "link.circle.fill",
            shortDescription: "A day for the people who have your back — siblings and chosen family alike.",
            whyItMatters: "Family isn't only who you're related to. This is a moment to honour whoever shows up for you.",
            symbols: [
                FestivalSymbol(name: "Rakhi thread", meaning: "A simple thread standing in for a promise to look out for each other."),
                FestivalSymbol(name: "Tied wrist", meaning: "A visible, wearable reminder of a bond that asks for nothing in return.")
            ],
            familyPrompt: "Ask someone in your family how they celebrated Raksha Bandhan growing up.",
            regionTags: ["india", "northIndia", "westIndia", "global", "diaspora"],
            relatedPracticeID: "practice.evening.gratitude",
            relatedMantraID: "mantra.shanti",
            tinyActivity: FestivalActivity(
                id: "festival.rakshabandhan.activity",
                title: "Reach out to someone who has your back",
                durationMinutes: 3,
                steps: [
                    "Think of one person — related or not — who has truly looked out for you.",
                    "Recall a specific time they showed up for you.",
                    "Send them a quick message, or simply send them a good wish in your mind."
                ],
                reflectionPrompt: "Who feels like family to you, beyond blood ties?"
            ),
            isDateApproximate: true,
            traditionNote: "Observance and dates can vary across regions and families.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.janmashtami",
            name: "Krishna Janmashtami",
            date: date(2026, 9, 4),
            deity: "Krishna",
            tagline: "The midnight birth of joy and mischief",
            significance: "Celebrating the birth of Krishna — playful, wise, and a reminder to act with love and courage even in difficult times.",
            story: "Traditions vary — here's one common story. Krishna was born at midnight in a prison cell, and his father is said to have carried him across a flooding river to safety. From butter-stealing child to the charioteer of the Bhagavad Gita, his life suggests that joy and duty can live side by side.",
            activities: [
                "Read one verse from the Bhagavad Gita.",
                "Do something playful and unselfconscious today.",
                "Reflect: where can you act with courage and lightness?"
            ],
            theme: .devotion,
            systemImage: "flame.circle.fill",
            shortDescription: "Celebrating Krishna — playful, wise, and a reminder that joy and duty can coexist.",
            whyItMatters: "Krishna's life suggests you can be lighthearted and serious at once — playful and still principled.",
            symbols: [
                FestivalSymbol(name: "Butter pot", meaning: "The playful, mischievous child — a reminder not to take ourselves too seriously."),
                FestivalSymbol(name: "Flute", meaning: "Often read as presence and charm — being fully where you are."),
                FestivalSymbol(name: "Peacock feather", meaning: "Colour and lightness worn even alongside great responsibility.")
            ],
            familyPrompt: "Ask someone in your family for their favourite Krishna story from childhood.",
            regionTags: ["india", "northIndia", "westIndia", "global", "diaspora"],
            relatedPracticeID: "practice.evening.prayer",
            tinyActivity: FestivalActivity(
                id: "festival.janmashtami.activity",
                title: "A moment of playful courage",
                durationMinutes: 3,
                steps: [
                    "Name one situation right now that feels heavy or serious.",
                    "Imagine meeting it with a little lightness — curiosity instead of dread.",
                    "Take one slow breath, and let your shoulders drop."
                ],
                reflectionPrompt: "Where could a little lightness help you act with courage?"
            ),
            isDateApproximate: true,
            traditionNote: "Dates and customs can vary by region and calendar.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.ganeshchaturthi",
            name: "Ganesh Chaturthi",
            date: date(2026, 9, 14),
            deity: "Ganesha",
            tagline: "Welcoming the remover of obstacles",
            significance: "A joyful start-of-things festival — good for setting intentions and clearing what stands in your way.",
            story: "Traditions vary — here's one common story. For several days, homes and streets welcome Ganesha, then lovingly return his clay form to the water — a reminder that beginnings and endings are part of one cycle, and nothing worth doing needs to be permanent or perfect.",
            activities: [
                "Name one obstacle you want to move past this month.",
                "Chant 'Om Gam Ganapataye Namaha' eleven times.",
                "Begin one small thing you've been putting off."
            ],
            theme: .courage,
            systemImage: "sparkles",
            shortDescription: "A joyful start-of-things festival — great for setting intentions.",
            whyItMatters: "Beginnings are hard. This is a warm nudge to start the small thing you've been circling.",
            symbols: [
                FestivalSymbol(name: "Curved trunk", meaning: "Adaptability — the strength to bend without breaking."),
                FestivalSymbol(name: "Clay form returned to water", meaning: "Letting go gracefully; nothing needs to last forever to matter.")
            ],
            familyPrompt: "Ask someone in your family how Ganesh Chaturthi was marked where they grew up.",
            regionTags: ["india", "westIndia", "southIndia", "global", "diaspora"],
            relatedMantraID: "mantra.ganesha",
            tinyActivity: FestivalActivity(
                id: "festival.ganeshchaturthi.activity",
                title: "Clear one small obstacle",
                durationMinutes: 4,
                steps: [
                    "Name one thing you've been putting off — keep it small.",
                    "Decide the very first tiny step (just the first one).",
                    "Do that one step now, or schedule it for today.",
                    "If you like, say 'Om Gam Ganapataye Namaha' once as you begin."
                ],
                reflectionPrompt: "What's the smallest first step you can actually take today?"
            ),
            isDateApproximate: true,
            traditionNote: "The length and form of celebration can vary widely by region.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.navaratri",
            name: "Navaratri",
            date: date(2026, 10, 11),
            deity: "Durga",
            tagline: "Nine nights of inner strength",
            significance: "Nine nights honouring the divine feminine and the strength to face what feels bigger than us.",
            story: "Traditions vary — here's one common story. Navaratri celebrates Durga's victory over a seemingly invincible foe — often read as the inner strength to meet our own fears. Across India it takes many forms: garba and dandiya in the west, Golu displays in the south, Durga Puja in the east.",
            activities: [
                "Name one fear you'd like to meet with courage this week.",
                "Move your body — dance, walk, stretch — for a few minutes.",
                "Notice a moment you were stronger than you expected."
            ],
            theme: .courage,
            systemImage: "moon.stars.fill",
            shortDescription: "Nine nights honouring the divine feminine and the courage to face hard things.",
            whyItMatters: "Sometimes you need a reminder that you're stronger than the thing in front of you. That's this.",
            symbols: [
                FestivalSymbol(name: "Nine nights", meaning: "Strength built gradually, one night at a time, rather than all at once."),
                FestivalSymbol(name: "Garba circle", meaning: "Community and rhythm — facing things together, in motion.")
            ],
            familyPrompt: "Ask someone in your family how Navaratri looks where your family is from.",
            regionTags: ["india", "westIndia", "eastIndia", "southIndia", "global", "diaspora"],
            relatedPracticeID: "practice.midday.breath",
            relatedMantraID: "mantra.mahamrityunjaya",
            tinyActivity: FestivalActivity(
                id: "festival.navaratri.activity",
                title: "Meet one fear, gently",
                durationMinutes: 4,
                steps: [
                    "Name one thing that feels bigger than you right now.",
                    "Recall a past moment you were stronger than you expected to be.",
                    "Take three slow breaths, standing tall.",
                    "Name one small, brave thing you could do this week."
                ],
                reflectionPrompt: "When have you surprised yourself with your own strength?"
            ),
            isDateApproximate: true,
            traditionNote: "Navaratri is observed very differently across regions and communities; dates can vary.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.diwali",
            name: "Diwali",
            date: date(2026, 11, 8),
            deity: "Lakshmi",
            tagline: "The festival of lights",
            significance: "The triumph of light over darkness and knowledge over ignorance — a time for renewal, gratitude and fresh starts.",
            story: "Traditions vary — here's one common story. Diwali is associated with Rama's return to Ayodhya after fourteen years, his path lit by rows of lamps. In many regions it also honours Lakshmi. Lighting a lamp is a quiet vow to keep an inner light burning.",
            activities: [
                "Light a diya or candle and set an intention.",
                "Clear and tidy one small space for a fresh start.",
                "Share food or time with someone you care about."
            ],
            theme: .prosperity,
            systemImage: "lightbulb.circle.fill",
            shortDescription: "Light over darkness — a warm reset for renewal, gratitude and fresh starts.",
            whyItMatters: "It's a yearly permission slip to clear out the old and begin again, gently.",
            symbols: [
                FestivalSymbol(name: "Diya (lamp)", meaning: "A small light kept burning — often read as hope and inner awareness."),
                FestivalSymbol(name: "Rangoli", meaning: "Patterns of welcome at the threshold; care taken to receive others."),
                FestivalSymbol(name: "Lakshmi", meaning: "Associated with well-being and grace, in every form — not money alone.")
            ],
            familyPrompt: "Ask someone in your family about a Diwali they remember most vividly, and why.",
            regionTags: ["india", "northIndia", "westIndia", "southIndia", "eastIndia", "global", "diaspora"],
            relatedPracticeID: "practice.evening.gratitude",
            relatedMantraID: "mantra.lakshmi",
            tinyActivity: FestivalActivity(
                id: "festival.diwali.activity",
                title: "Light and intention",
                durationMinutes: 4,
                steps: [
                    "Tidy one small space — a desk corner, a shelf, your phone's home screen.",
                    "If you have a candle or diya, light it. If not, picture a small steady flame.",
                    "Name one intention for the season ahead.",
                    "Sit with the light, or the image of it, for a few quiet breaths."
                ],
                reflectionPrompt: "What's one small light you want to keep burning this season?"
            ),
            isDateApproximate: true,
            traditionNote: "The legends, dates and rituals of Diwali can vary by region and family.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.makarsankranti",
            name: "Makar Sankranti & Pongal",
            date: date(2027, 1, 14),
            tagline: "A harvest of gratitude",
            significance: "Marking the sun's turn toward longer days — a harvest festival of thanks and new energy.",
            story: "Traditions vary — here's one common story. Celebrated as Makar Sankranti, Pongal, Lohri, Bihu and more, this is one of the few festivals tied to the solar calendar. Kites, sesame sweets, and the first harvest all mark a turn toward warmth and light.",
            activities: [
                "Name three things from the past season you're grateful for.",
                "Eat something seasonal and local today.",
                "Step outside and notice the sun a little longer than usual."
            ],
            theme: .prosperity,
            systemImage: "sun.max.fill",
            shortDescription: "The sun turns toward longer days — a harvest festival of thanks and new energy.",
            whyItMatters: "A natural moment to look back with gratitude and feel the days, quite literally, getting brighter.",
            symbols: [
                FestivalSymbol(name: "Kite", meaning: "Rising spirits and open skies as the days lengthen."),
                FestivalSymbol(name: "Sesame and jaggery", meaning: "Sweetness shared; warmth offered to others in the cold months."),
                FestivalSymbol(name: "First harvest", meaning: "Gratitude for what the season provided.")
            ],
            familyPrompt: "Ask someone in your family what this harvest festival is called where they're from.",
            regionTags: ["india", "southIndia", "westIndia", "northIndia", "eastIndia"],
            relatedPracticeID: "practice.evening.gratitude",
            relatedMantraID: "mantra.gayatri",
            tinyActivity: FestivalActivity(
                id: "festival.makarsankranti.activity",
                title: "A harvest of gratitude",
                durationMinutes: 3,
                steps: [
                    "Think back over the past season — the last few months.",
                    "Name three things, however small, that you're grateful for.",
                    "Step outside if you can, and notice the light for a moment."
                ],
                reflectionPrompt: "What did this past season quietly give you?"
            ),
            isDateApproximate: true,
            traditionNote: "Known by many names and customs across regions; Pongal spans several days in the south. Dates can vary.",
            reviewStatus: .humanReviewed
        ),
        Festival(
            id: "festival.holi",
            name: "Holi",
            date: date(2027, 3, 3),
            tagline: "Colour, renewal and letting go",
            significance: "The festival of colours: a joyful reset, a chance to repair bonds and start fresh.",
            story: "Traditions vary — here's one common story. Holi welcomes spring and is linked to the story of Prahlada and the burning away of arrogance. Playing with colour dissolves the usual distances between people — for a day, everyone meets as equals.",
            activities: [
                "Make peace with someone over a small grudge.",
                "Add a splash of colour to your day, however small.",
                "Let go of one thing that's been weighing on you."
            ],
            theme: .compassion,
            systemImage: "paintpalette.fill",
            shortDescription: "The festival of colours — a joyful reset and a chance to repair bonds.",
            whyItMatters: "A bright invitation to put down a grudge, mend a bond, and let yourself have fun.",
            symbols: [
                FestivalSymbol(name: "Colours", meaning: "Joy that levels differences — for a day, everyone meets as equals."),
                FestivalSymbol(name: "Bonfire (Holika)", meaning: "Often read as burning away what no longer serves us.")
            ],
            familyPrompt: "Ask someone in your family for a funny or messy Holi memory from their youth.",
            regionTags: ["india", "northIndia", "eastIndia", "global", "diaspora"],
            relatedPracticeID: "practice.evening.gratitude",
            relatedMantraID: "mantra.shanti",
            tinyActivity: FestivalActivity(
                id: "festival.holi.activity",
                title: "Let one thing go",
                durationMinutes: 3,
                steps: [
                    "Name one small grudge or worry you've been carrying.",
                    "Ask yourself: is this worth holding onto?",
                    "Picture setting it down, the way colour washes off after Holi.",
                    "If a bond needs mending, consider one small step toward it."
                ],
                reflectionPrompt: "What would feel lighter to let go of this spring?"
            ),
            isDateApproximate: true,
            traditionNote: "Holi's stories, dates and play can vary considerably by region.",
            reviewStatus: .humanReviewed
        )
    ]

    // MARK: - Stories & Symbols

    // Exact in-code mirror of seed_stories.json (10 items). Kept in lock-step
    // with the JSON by SeedParityTests; the JSON is the authoring source.
    static let stories: [StorySymbol] = [
        StorySymbol(
            id: "story.ganesha.beginnings",
            title: "Ganesha & the Art of Beginning",
            deity: "Ganesha",
            theme: .courage,
            summary: "Why so many things begin with Ganesha.",
            story: "Before a wedding, a journey, an exam, or even the first page of a book, many people pause to remember Ganesha. As the remover of obstacles, he is the one invoked at the threshold of anything new. There is a quiet wisdom in this: every beginning carries a little fear, and naming that fear is the first step through it.",
            symbolMeaning: "One way to understand this symbol: the hardest part of most things is starting. Invoking Ganesha is a ritual of permission — a way of saying 'I am allowed to begin, imperfectly, today.'",
            takeaway: "Beginning is a skill. Start small, start scared, just start.",
            readMinutes: 3,
            systemImage: "flag.checkered",
            traditionNote: "Interpretations of Ganesha are many; traditions vary by region and family.",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.saraswati.learning",
            title: "Saraswati's Veena",
            deity: "Saraswati",
            theme: .knowledge,
            summary: "Why the goddess of knowledge holds a musical instrument.",
            story: "Saraswati is pictured seated on a white lotus, holding a veena, a book and prayer beads. She carries no weapons and no gold. Her swan is said to be able to separate milk from water — to take in what nourishes and leave the rest.",
            symbolMeaning: "One way to understand this symbol: real learning is not dry memorisation; it should flow and resonate like music. The swan suggests that wisdom is the art of discernment — knowing what to keep and what to let go.",
            takeaway: "Real learning sings — and knows what to leave behind.",
            readMinutes: 3,
            systemImage: "music.note",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.hanuman.courage",
            title: "Hanuman's Leap",
            deity: "Hanuman",
            theme: .courage,
            summary: "He forgot his own strength — until someone reminded him.",
            story: "Tasked with crossing the ocean to find Sita, Hanuman hesitated at the shore. He had grown up being humble and had forgotten the immense power within him. Only when his friends reminded him of who he truly was did he gather himself and leap the entire ocean in a single bound.",
            symbolMeaning: "One way to understand this symbol: the obstacle was never the ocean — it was forgetting his own capacity. We often wait for permission to be as strong as we already are.",
            takeaway: "You are likely more capable than your self-doubt has told you.",
            readMinutes: 4,
            systemImage: "figure.gymnastics",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.lakshmi.gratitude",
            title: "Lakshmi & the Open Hand",
            deity: "Lakshmi",
            theme: .prosperity,
            summary: "Abundance is something you notice, not only something you get.",
            story: "Lakshmi is shown with coins flowing from one hand — but the other hand is open, palm out, in a gesture of giving and reassurance. She is rarely shown clutching. The image suggests that what flows in is meant, in part, to flow out again.",
            symbolMeaning: "One way to understand this symbol: gratitude is the practice that turns what we have into 'enough'. Abundance grows when we notice it and share it, not when we grip it tightly.",
            takeaway: "Name what you already have. Gratitude is its own wealth.",
            readMinutes: 3,
            systemImage: "hands.sparkles.fill",
            traditionNote: "Depictions and meanings of Lakshmi vary across regions and families.",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.shiva.stillness",
            title: "Shiva, the Stillness Within",
            deity: "Shiva",
            theme: .discipline,
            summary: "The dancer who is also perfectly still.",
            story: "Shiva is pictured deep in meditation on a mountain, utterly still — and also as Nataraja, dancing the universe into being. Both images are true at once. At the centre of all that motion is a point of stillness that never moves.",
            symbolMeaning: "One way to understand this symbol: stillness is not the absence of activity but a steadiness underneath it. We can be busy and calm at the same time if we keep a quiet centre.",
            takeaway: "Find one still point in a busy day. Return to it often.",
            readMinutes: 4,
            systemImage: "figure.mind.and.body",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.durga.innerstrength",
            title: "Durga & the Strength to Stand",
            deity: "Durga",
            theme: .protection,
            summary: "When no one else could, she stood.",
            story: "When a force arose that the gods could not defeat, they combined their energies and Durga emerged — riding a lion, calm and unafraid, to meet what seemed unbeatable. She is fierce, but her face is serene.",
            symbolMeaning: "One way to understand this symbol: inner strength is not the same as aggression. Durga's calm in the face of something overwhelming is the model — steady, protective, unshaken.",
            takeaway: "Strength can be calm. You can be soft and unshakeable.",
            readMinutes: 4,
            systemImage: "shield.fill",
            traditionNote: "Durga is understood and worshipped in many forms across India.",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.krishna.govardhan",
            title: "Lifting Govardhan Hill",
            deity: "Krishna",
            theme: .protection,
            summary: "A whole village sheltered under one raised finger.",
            story: "When torrential rains threatened his village, the young Krishna is said to have lifted the entire Govardhan Hill on his little finger, holding it as an umbrella for days while everyone sheltered beneath. The villagers, too, lent their staffs to help hold it up.",
            symbolMeaning: "One way to understand this symbol: notice the detail that the people raised their sticks too. Shelter is real, and it is also shared — protecting others can be a gift you give and a thing you do together.",
            takeaway: "Lend your strength to shelter others — and let them help.",
            readMinutes: 4,
            systemImage: "mountain.2.fill",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.prahlada.devotion",
            title: "Prahlada's Steadfast Heart",
            deity: "Narasimha",
            theme: .devotion,
            summary: "A child whose faith could not be frightened away.",
            story: "Prahlada, son of a tyrant king, loved the divine no matter how his father threatened him. When the king demanded to know where God was, Prahlada answered: everywhere, even in this pillar. The pillar split, and Narasimha emerged to protect him.",
            symbolMeaning: "One way to understand this symbol: Prahlada's faith wasn't loud or rebellious — it was simply unwavering. The story points to the quiet power of staying true to what you love when it would be easier to give it up.",
            takeaway: "Quiet steadiness is its own kind of strength.",
            readMinutes: 4,
            systemImage: "heart.circle.fill",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.ganesha.tusk",
            title: "The Broken Tusk",
            deity: "Ganesha",
            theme: .wisdom,
            summary: "When the pen broke, he used a piece of himself.",
            story: "As the sage Vyasa dictated the vast Mahabharata, Ganesha agreed to write it down — on one condition: that Vyasa never pause. Mid-epic, Ganesha's pen snapped. Rather than break the flow, he is said to have broken off his own tusk and kept writing.",
            symbolMeaning: "One way to understand this symbol: the single tusk speaks of sacrifice in service of something larger, and of finishing what you start. Sometimes commitment means improvising with what you have rather than waiting for perfect conditions.",
            takeaway: "Done with devotion beats waiting for the perfect tools.",
            readMinutes: 3,
            systemImage: "pencil.and.outline",
            reviewStatus: .humanReviewed
        ),
        StorySymbol(
            id: "story.samudra.manthan",
            title: "Churning the Ocean",
            deity: "Vishnu",
            theme: .discipline,
            summary: "Treasure rose only after the poison was faced.",
            story: "To win the nectar of immortality, gods and demons churned the cosmic ocean together for ages. Before any treasure surfaced, a deadly poison arose — which Shiva is said to have drunk to save creation, holding it in his throat. Only after that did the nectar finally appear.",
            symbolMeaning: "One way to understand this symbol: hard processes often surface the worst before the best. Patience, and the willingness to sit with discomfort, are what let the nectar rise.",
            takeaway: "The hardest part often comes right before the reward.",
            readMinutes: 5,
            systemImage: "tornado",
            isPremium: true,
            reviewStatus: .humanReviewed
        )
    ]

    // MARK: - Story Library (Phase 2D `Story` model)
    //
    // Exact in-code fallback for `StoriesService` (mirrors seed_story_library.json,
    // 7 stories). Kept in lock-step with the JSON by SeedParityTests.

    static let storyLibrary: [Story] = [
        Story(
            id: "story_ganesha_obstacle",
            deity: "Ganesha",
            title: "The Remover of Obstacles",
            theme: .beginnings,
            durationMinutes: 4,
            bodyMarkdown: "Long before he became the gentle, elephant-headed guardian of beginnings, Ganesha was simply a child shaped with love. In one widely told account, Parvati formed him from the earth and warmth of her own hands and asked him to watch the doorway while she bathed.\n\nWhen Shiva returned and found a boy he did not know guarding the threshold, neither would step aside. In the struggle that followed the child was gravely hurt, and to set things right Shiva gave him the head of an elephant and welcomed him as his own.\n\nWhat could have ended in sorrow became a beginning. From then on Ganesha was the one remembered first — before a journey, an exam, a new venture — not because he sweeps away every difficulty, but because he helps us meet the threshold of anything new with a steadier mind. An obstacle, in this reading, is simply part of the path, and meeting it is already the beginning.",
            moralOrMeaning: "One way many traditions understand this: what blocks us and what begins us are often the same threshold.",
            symbolism: [
                SymbolEntry(id: "sym_elephant_head", name: "Elephant Head", sanskritName: "Gaja",
                            meaning: "Large ears and a small mouth are often read as an invitation to listen more than we speak.",
                            associatedDeities: ["Ganesha"]),
                SymbolEntry(id: "sym_broken_tusk", name: "Broken Tusk", sanskritName: "Ekadanta",
                            meaning: "The single tusk is often seen as sacrifice in service of completing what we start.",
                            associatedDeities: ["Ganesha"])
            ],
            reflectionPrompt: "When has something that felt like an obstacle turned out to be the start of something?",
            relatedMantraId: "lesson.vakratunda.meet",
            relatedFestivalId: "festival.ganeshchaturthi",
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Puranic tradition (widely told)",
            sourceNote: "A composite of commonly shared tellings.",
            reviewStatus: "reviewed",
            region: ["pan-India"],
            tags: ["beginnings", "obstacles", "patience"]
        ),
        Story(
            id: "story_saraswati_knowledge",
            deity: "Saraswati",
            title: "The River of Knowledge",
            theme: .wisdom,
            durationMinutes: 4,
            bodyMarkdown: "Saraswati is often pictured on a white lotus, holding a veena, with a book and beads nearby. She carries no gold and no weapons — what she offers cannot be hoarded.\n\nHer name is tied to an ancient river, and that is no accident. Knowledge, in her telling, is not a treasure locked away but a current: always moving, always renewing, shaped by everyone it passes through. The veena suggests that real understanding has music in it — it should move you, not just fill you. The white lotus, rising clean from muddy water, reminds us that learning often grows out of confusion. Not knowing is not a flaw to hide; it is the soil the lotus needs.\n\nStudents greet her not to win favour but to settle the mind and remember why they are learning at all.",
            moralOrMeaning: "One reading of this story: knowledge is a current, not a possession — it stays alive only when it keeps moving through us and onward.",
            symbolism: [
                SymbolEntry(id: "sym_veena", name: "Veena", sanskritName: "Vina",
                            meaning: "The stringed instrument suggests understanding that has harmony and rhythm, not just accumulated information.",
                            associatedDeities: ["Saraswati"]),
                SymbolEntry(id: "sym_white_lotus", name: "White Lotus", sanskritName: "Padma",
                            meaning: "A bloom that rises clean from muddy water — clarity emerging out of confusion.",
                            associatedDeities: ["Saraswati"])
            ],
            reflectionPrompt: "What is something you are learning right now, simply for the joy of it?",
            relatedMantraId: "lesson.saraswati.meet",
            relatedFestivalId: "festival.navaratri",
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Vedic and Puranic tradition",
            sourceNote: "A composite of commonly shared tellings.",
            reviewStatus: "reviewed",
            region: ["pan-India", "South India"],
            tags: ["wisdom", "learning", "creativity"]
        ),
        Story(
            id: "story_hanuman_devotion",
            deity: "Hanuman",
            title: "The Devoted One",
            theme: .devotion,
            durationMinutes: 4,
            bodyMarkdown: "There is a moment in the Ramayana when everything depends on a single leap. Someone must cross the vast sea to find Sita, and the one who can is Hanuman — but at the shore, he hesitates.\n\nAs a child, the story goes, his great power was gently set aside so he would grow up humble, and over the years he simply forgot how much he carried within. Then his companions remind him who he is — not to flatter him, but to wake him. As he remembers, he grows vast and certain, and crosses the sea in a single bound.\n\nWhat makes the leap remarkable is not the distance but the reason. Hanuman does not jump to prove himself; he jumps because he loves Rama and cannot bear that Sita is suffering. Love, his story suggests, has a way of enlarging us — and we are often far more capable than our self-doubt has let us believe.",
            moralOrMeaning: "One way many traditions understand this: caring deeply is its own kind of strength, and can quietly enlarge what we are able to do.",
            symbolism: [
                SymbolEntry(id: "sym_leap", name: "The Leap",
                            meaning: "The crossing of the sea is often read as latent potential — strength we forget we hold, waiting for a reason to wake.",
                            associatedDeities: ["Hanuman"]),
                SymbolEntry(id: "sym_mace", name: "Mace", sanskritName: "Gada",
                            meaning: "Carried for protection rather than conquest — strength placed entirely in the service of others.",
                            associatedDeities: ["Hanuman"])
            ],
            reflectionPrompt: "When has caring about someone helped you do more than you thought you could?",
            relatedMantraId: nil,
            relatedFestivalId: nil,
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Ramayana (widely told)",
            sourceNote: "A composite of commonly shared tellings.",
            reviewStatus: "reviewed",
            region: ["pan-India"],
            tags: ["devotion", "courage", "service"]
        ),
        Story(
            id: "story_lakshmi_abundance",
            deity: "Lakshmi",
            title: "Abundance That Flows",
            theme: .abundance,
            durationMinutes: 3,
            bodyMarkdown: "Lakshmi is usually shown standing or seated on a lotus, with coins streaming gently from one open hand. It is worth pausing on that detail: the hand is open, and the coins are falling — outward, downward, away. She is not clutching anything.\n\nThis is the quiet heart of her story. Lakshmi is often called the figure of wealth, but the word does her a disservice. She represents abundance in its fullest sense — well-being, beauty, ease, enough-ness — and crucially, abundance that moves. Money that only piles up stops being wealth and starts being weight. What she models is prosperity that circulates: received with gratitude, passed on with grace.\n\nIn many tellings she rose from the churning of a vast cosmic ocean, emerging radiant after a long and difficult effort. Abundance, the image suggests, is not luck that lands from nowhere. It often follows patience, shared work, and the willingness to keep going through the murky middle.\n\nThe lotus she stands on grows in muddy water, yet is never stained by it — a familiar reminder that we can move through ordinary mess, even ordinary money, without letting it cloud who we are. The elephants often shown beside her, pouring water, suggest dignity and a kind of unhurried grace; abundance need not be anxious or grasping.\n\nThere is a gentleness to all of this that is easy to overlook. Lakshmi is not a figure of accumulation or status. She is honoured most where there is care — a tidy home, a welcomed guest, a meal shared, a kindness extended without expecting return. Where generosity flows, the old idea goes, she feels at home.\n\nCustoms around her differ widely by region and household, and the details of her story shift from one telling to the next. What stays steady is the invitation: to hold what we have a little more openly, and to let some of the good in our hands flow onward.",
            moralOrMeaning: "One reading of this story: true abundance circulates rather than accumulates — it stays alive in the giving, not only the having.",
            symbolism: [
                SymbolEntry(id: "sym_lotus_lakshmi", name: "Lotus", sanskritName: "Padma", meaning: "Rooted in mud yet unstained, the lotus suggests we can move through ordinary mess — even money — without letting it cloud who we are.", associatedDeities: ["Lakshmi", "Saraswati"]),
                SymbolEntry(id: "sym_flowing_coins", name: "Flowing Coins", meaning: "Coins falling from an open hand are often read as abundance that is meant to circulate and be shared, not gripped and stored.", associatedDeities: ["Lakshmi"]),
                SymbolEntry(id: "sym_elephants", name: "Elephants", sanskritName: "Gaja", meaning: "The elephants beside her, pouring water, are commonly seen as dignity and unhurried grace — abundance that is calm rather than anxious.", associatedDeities: ["Lakshmi"])
            ],
            reflectionPrompt: "What is one small way you could let something good flow onward this week?",
            relatedMantraId: nil,
            relatedFestivalId: "festival.diwali",
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Puranic tradition",
            sourceNote: "A composite of commonly shared tellings.",
            reviewStatus: "reviewed",
            region: ["pan-India"],
            tags: ["abundance", "generosity", "gratitude", "ease"]
        ),
        Story(
            id: "story_shiva_stillness",
            deity: "Shiva",
            title: "The Still Point",
            theme: .stillness,
            durationMinutes: 4,
            bodyMarkdown: "Of all the great figures in this tradition, Shiva is the one most often found doing nothing at all — and that is precisely the point. He is pictured high on a snow-quiet mountain, eyes half closed, utterly at rest, while the whole noisy world turns below him. He is the witness: the calm that watches everything without being swept away by it.\n\nAnd yet, in another famous image, the very same Shiva is dancing. As Nataraja, he moves inside a ring of fire, one foot raised, surrounded by motion and rhythm and even destruction. Look closely, though, and his face is serene. The dance is wild; the dancer is still. That is the riddle at the centre of him — perfect stillness and full movement, held in the same body at the same time.\n\nMost of us know only one or the other. We are either frantic or shut down, racing or collapsed. Shiva suggests a third way: to act fully in the world while keeping a quiet, unshaken centre. To be in the storm and also be its eye.\n\nThe crescent moon resting in his hair is often read as a calm holding of time — the cool, changing moon worn lightly, neither grasped nor feared. The small drum he holds, the damaru, keeps a rhythm said to mark beginnings and rests, the natural pulse of starting and pausing that runs through everything.\n\nThere is comfort in a figure who shows that stillness is not the same as doing nothing. His silence is not emptiness; it is fullness that does not need to announce itself. From that quiet centre, when he does move, the movement is clear and unhurried.\n\nHis stories take many forms across regions, and families hold their own understandings. But what he keeps pointing to is the same: a reminder that beneath the day's noise there is a still place in us too — and that we can learn, breath by breath, to return to it.",
            moralOrMeaning: "One way many traditions understand this: stillness is not the absence of action but a steady centre within it — we can move through the world without being swept away by it.",
            symbolism: [
                SymbolEntry(id: "sym_crescent_moon", name: "Crescent Moon", sanskritName: "Chandra", meaning: "Worn lightly in his hair, the changing moon is often read as a calm holding of time — neither grasping at it nor fearing it.", associatedDeities: ["Shiva"]),
                SymbolEntry(id: "sym_trishul", name: "Trishul", sanskritName: "Trishula", meaning: "The three-pronged form is commonly seen as three forces — creation, sustaining, and release — held together in balance rather than tension.", associatedDeities: ["Shiva", "Durga"]),
                SymbolEntry(id: "sym_damaru", name: "Damaru", sanskritName: "Damaru", meaning: "The small hand-drum keeps a rhythm often read as the natural pulse of beginnings and rests — starting and pausing as one motion.", associatedDeities: ["Shiva"])
            ],
            reflectionPrompt: "Where in your day could you return to one still breath?",
            relatedMantraId: "lesson.om.sound",
            relatedFestivalId: nil,
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Puranic and Shaiva tradition",
            sourceNote: "A composite of commonly shared tellings.",
            reviewStatus: "reviewed",
            region: ["pan-India"],
            tags: ["stillness", "calm", "balance", "presence"]
        ),
        Story(
            id: "story_durga_protector",
            deity: "Durga",
            title: "The Fierce Protector",
            theme: .strength,
            durationMinutes: 4,
            bodyMarkdown: "When a threat arose that none could meet alone, the story goes, the cosmos answered not with anger but with concentrated strength. The combined energies of many great figures gathered and took form as Durga — radiant, many-armed, seated on a lion, calm-faced even as she rode into difficulty.\n\nIt matters that she was called forth to protect, not to dominate. The danger she faced could shift its shape and could not be overcome by ordinary force. What was needed was something steadier: strength joined to clarity, power that knew exactly what it was for. Durga is that — fierceness in the service of care.\n\nLook at how she is pictured. She has many arms, each holding a different tool, and they are usually read not as raw power but as capacity: the ability to hold many things at once, to meet a complex moment from several directions without losing composure. A parent steadying a household, a friend holding space for someone in pain, a person carrying several hard responsibilities at once — all of this is in those arms.\n\nHer face is the surprising part. In most images it is serene. She is not contorted with rage. Her strength does not come from losing herself to fury; it comes from a centre that stays clear. The lion she sits on, a creature of obvious power, carries her calmly — strength that serves rather than rampages.\n\nThere is a kind of permission in her. So many of us are taught that to be gentle we must be soft and yielding always, that fierceness is a flaw. Durga suggests otherwise: that protecting what we love can call for real force, and that this force, when guided by care, is not aggression but devotion wearing a stronger face.\n\nHer forms and festivals vary widely across regions, especially in the east, and families understand her in their own ways. What stays constant is the feeling she leaves: that there is a fierce, protective strength available to us too — and that it is gentlest at its very centre.",
            moralOrMeaning: "One reading of this story: real strength is protective rather than aggressive — fierceness guided by care is a form of love, calm at its centre.",
            symbolism: [
                SymbolEntry(id: "sym_lion", name: "Lion", sanskritName: "Simha", meaning: "A creature of obvious power carrying her calmly, the lion is often read as strength that serves and steadies rather than rampages.", associatedDeities: ["Durga"]),
                SymbolEntry(id: "sym_many_arms", name: "Many Arms", meaning: "Often read not as raw power but as capacity — the ability to hold many things at once and meet a hard moment from several directions without losing composure.", associatedDeities: ["Durga"]),
                SymbolEntry(id: "sym_serene_face", name: "The Calm Face", meaning: "Her serene expression amid difficulty suggests that true strength comes from a clear centre, not from being overcome by fury.", associatedDeities: ["Durga"])
            ],
            reflectionPrompt: "What do you find yourself most fiercely protective of?",
            relatedMantraId: nil,
            relatedFestivalId: "festival.navaratri",
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Devi Mahatmya tradition",
            sourceNote: "A composite of commonly shared tellings; emphasis differs by region.",
            reviewStatus: "reviewed",
            region: ["pan-India", "East India"],
            tags: ["strength", "protection", "courage", "care"]
        ),
        Story(
            id: "story_arjuna_courage",
            deity: "Krishna",
            title: "The Courage to Act",
            theme: .courage,
            durationMinutes: 5,
            bodyMarkdown: "Two armies face each other across a field, and at the very moment the conflict is meant to begin, the warrior Arjuna sets down his bow. He looks across at the other side and sees not enemies but teachers, cousins, friends. The weight of what is being asked of him lands all at once, and he cannot move. He sits down in his chariot, overwhelmed.\n\nIt is one of the most human moments in all of these stories. Not a battle scene, but a standstill — the paralysis we all know when a choice feels too large, when every path seems to cost something dear.\n\nBeside Arjuna is Krishna, who has taken the humble role of his charioteer. He does not shout at Arjuna to pull himself together, nor does he pretend the difficulty away. He simply begins to talk with him, friend to friend, about how to act when acting is hard.\n\nThe heart of what he offers is gentle and surprisingly practical: do what is genuinely yours to do, and loosen your grip on the results. So much of our fear, the conversation suggests, comes from clutching at outcomes we cannot control — from needing a thing to turn out a certain way before we are willing to begin. When we give our sincere effort to the action itself and release the rest, the paralysis often eases. We become able to move again.\n\nThis is not a call to be careless, or to stop caring how things turn out. It is an invitation to act with full sincerity and a lighter hold — to take the next honest step without waiting for a guarantee.\n\nThe text these words come from is vast, and people across regions and generations read it in countless ways. Read gently, though, the scene speaks plainly to anyone who has ever frozen at a threshold. Courage here is not the absence of doubt. It is the willingness, doubt and all, to take one true step — and then the next.",
            moralOrMeaning: "One way many traditions understand this: courage is acting with sincerity while loosening our grip on the outcome — taking the next honest step without waiting for a guarantee.",
            symbolism: [
                SymbolEntry(id: "sym_chariot", name: "The Chariot", sanskritName: "Ratha", meaning: "The self in motion, steadied by a wise inner voice at the reins — often read as the mind guided by clarity rather than by panic.", associatedDeities: ["Krishna", "Arjuna"]),
                SymbolEntry(id: "sym_lowered_bow", name: "The Lowered Bow", meaning: "Arjuna setting down his bow is a tender image of the honest standstill — the moment of doubt that comes before any real act of courage.", associatedDeities: ["Arjuna"]),
                SymbolEntry(id: "sym_conch", name: "Conch", sanskritName: "Shankha", meaning: "Its sound is often read as a call to begin — a clear note that marks the turn from hesitation toward the next true step.", associatedDeities: ["Krishna", "Vishnu"])
            ],
            reflectionPrompt: "When you feel frozen by a hard choice, what helps you take the first small step?",
            relatedMantraId: "lesson.gayatri.basics",
            relatedFestivalId: "festival.janmashtami",
            traditionNote: "Stories vary by tradition, region, and family lineage.",
            sourceName: "Bhagavad Gita",
            sourceNote: "A brief, accessible retelling of the opening moment; many readings exist.",
            reviewStatus: "reviewed",
            region: ["pan-India"],
            tags: ["courage", "action", "clarity", "doubt"]
        )
    ]

    // MARK: - Achievements

    static let achievements: [Achievement] = [
        Achievement(id: "ach.firstStep", title: "First Step", detail: "Complete your first practice.", systemImage: "figure.walk", requirement: .totalPractices(1), bonusPoints: 25),
        Achievement(id: "ach.streak3", title: "Finding Rhythm", detail: "Reach a 3-day streak.", systemImage: "flame.fill", requirement: .streakDays(3), bonusPoints: 50),
        Achievement(id: "ach.streak7", title: "One Week Strong", detail: "Reach a 7-day streak.", systemImage: "flame.circle.fill", requirement: .streakDays(7), bonusPoints: 100),
        Achievement(id: "ach.streak30", title: "Devoted", detail: "Reach a 30-day streak.", systemImage: "crown.fill", requirement: .streakDays(30), bonusPoints: 300),
        Achievement(id: "ach.practices10", title: "Steady Practice", detail: "Complete 10 practices.", systemImage: "leaf.fill", requirement: .totalPractices(10), bonusPoints: 75),
        Achievement(id: "ach.practices50", title: "Inner Discipline", detail: "Complete 50 practices.", systemImage: "figure.mind.and.body", requirement: .totalPractices(50), bonusPoints: 200),
        Achievement(id: "ach.firstLesson", title: "Eager Learner", detail: "Finish your first lesson.", systemImage: "graduationcap.fill", requirement: .lessonsCompleted(1), bonusPoints: 30),
        Achievement(id: "ach.lessons5", title: "Scholar", detail: "Finish 5 lessons.", systemImage: "books.vertical.fill", requirement: .lessonsCompleted(5), bonusPoints: 120),
        Achievement(id: "ach.points500", title: "Five Hundred", detail: "Earn 500 Svara Points.", systemImage: "sparkles", requirement: .totalPoints(500), bonusPoints: 0),
        Achievement(id: "ach.festival", title: "In the Spirit", detail: "Observe your first festival.", systemImage: "party.popper.fill", requirement: .festivalsObserved(1), bonusPoints: 50)
    ]

    // MARK: - Shlokas of the Day
    //
    // In-code fallback mirroring seed_shlokas.json. Short verses with a humble,
    // plural framing of meaning (see ProductGuardrails §7).

    static let shlokas: [ShlokaOfDay] = [
        ShlokaOfDay(
            id: "shloka.gita.2.47",
            sanskritText: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।",
            transliteration: "karmanye vadhikaraste ma phaleshu kadachana",
            translation: "You have a right to your actions, but never to the fruits of your actions.",
            meaning: "One common reading: give your best to the work itself and loosen your grip on outcomes. It is a gentle antidote to anxiety about results.",
            theme: .discipline,
            sourceName: "Bhagavad Gita 2.47",
            traditionNote: "Translations vary; this is one widely-shared rendering.",
            reviewStatus: .sourced,
            deepLinkTarget: "today"
        ),
        ShlokaOfDay(
            id: "shloka.asato.ma",
            sanskritText: "असतो मा सद्गमय ।",
            transliteration: "asato ma sadgamaya",
            translation: "Lead me from the unreal to the real.",
            meaning: "A prayer for clarity — to move from confusion toward truth, from darkness toward light.",
            theme: .wisdom,
            sourceName: "Brihadaranyaka Upanishad 1.3.28",
            reviewStatus: .sourced,
            deepLinkTarget: "stories"
        ),
        ShlokaOfDay(
            id: "shloka.saha.navavatu",
            sanskritText: "सह नाववतु ।",
            transliteration: "saha navavatu",
            translation: "May we be protected together.",
            meaning: "One way to understand this: learning and growth are shared. A wish for goodwill between teacher and student, and among friends.",
            theme: .compassion,
            sourceName: "Taittiriya Upanishad",
            reviewStatus: .sourced,
            deepLinkTarget: "learn"
        ),
        ShlokaOfDay(
            id: "shloka.om",
            transliteration: "om",
            translation: "The primordial sound.",
            meaning: "Often described as the sound from which all begins — a single syllable to gather attention and settle the breath.",
            theme: .devotion,
            traditionNote: "Interpretations of Om are many; traditions vary by region and family.",
            reviewStatus: .humanReviewed,
            deepLinkTarget: "mantra:mantra.om"
        ),
        ShlokaOfDay(
            id: "shloka.vakratunda",
            sanskritText: "वक्रतुण्ड महाकाय ।",
            transliteration: "vakratunda mahakaya",
            translation: "O Lord with the curved trunk and mighty form…",
            meaning: "The opening of a much-loved invocation to Ganesha, asking for a clear path before beginning anything new.",
            theme: .courage,
            reviewStatus: .humanReviewed,
            deepLinkTarget: "story:story.ganesha.beginnings"
        ),
        ShlokaOfDay(
            id: "shloka.lokah.samastah",
            transliteration: "lokah samastah sukhino bhavantu",
            translation: "May all beings everywhere be happy and free.",
            meaning: "A closing prayer of universal goodwill — widening care beyond ourselves to everyone.",
            theme: .compassion,
            reviewStatus: .humanReviewed,
            deepLinkTarget: "today"
        ),
        ShlokaOfDay(
            id: "shloka.gita.6.5",
            transliteration: "uddhared atmanatmanam",
            translation: "Lift yourself by your own self.",
            meaning: "One reading: you are your own ally. Self-discipline is a form of self-kindness, not punishment.",
            theme: .discipline,
            sourceName: "Bhagavad Gita 6.5",
            reviewStatus: .sourced,
            deepLinkTarget: "profile"
        ),
        ShlokaOfDay(
            id: "shloka.saraswati",
            transliteration: "saraswati namastubhyam",
            translation: "Salutations to you, Saraswati.",
            meaning: "A student's invocation before study, inviting focus and the free flow of learning.",
            theme: .knowledge,
            reviewStatus: .humanReviewed,
            deepLinkTarget: "lesson:lesson.saraswati.meaning"
        ),
        ShlokaOfDay(
            id: "shloka.tat.tvam.asi",
            transliteration: "tat tvam asi",
            translation: "That thou art.",
            meaning: "One of the great Upanishadic sayings, pointing to a deep kinship between the self and all that is.",
            theme: .wisdom,
            sourceName: "Chandogya Upanishad 6.8.7",
            reviewStatus: .sourced,
            deepLinkTarget: "stories"
        ),
        ShlokaOfDay(
            id: "shloka.shanti",
            transliteration: "om shanti shanti shanti",
            translation: "Peace, peace, peace.",
            meaning: "Peace invoked three times — for body, mind, and the world around us. A calm way to close the day.",
            theme: .compassion,
            reviewStatus: .humanReviewed,
            deepLinkTarget: "mantra:mantra.shanti"
        )
    ]
}
