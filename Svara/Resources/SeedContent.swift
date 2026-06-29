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

    // MARK: - Lessons (Duolingo-style)

    static let lessons: [Lesson] = [
        Lesson(
            id: "lesson.ganesha.intro",
            title: "Om Gam Ganapataye",
            subtitle: "Your very first mantra",
            theme: .courage,
            level: 1,
            xp: 20,
            mantraID: "mantra.ganesha",
            steps: [
                LessonStep(
                    id: "l1.s1", kind: .intro,
                    prompt: "Meet Ganesha",
                    detail: "Ganesha, the elephant-headed deity, is the remover of obstacles. His mantra is chanted before anything new."
                ),
                LessonStep(
                    id: "l1.s2", kind: .listen,
                    prompt: "Om Gam Ganapataye Namaha",
                    detail: "Chant it slowly three times. Feel the 'Gam' resonate."
                ),
                LessonStep(
                    id: "l1.s3", kind: .meaning,
                    prompt: "What it means",
                    detail: "“Salutations to Ganesha, remover of obstacles.” It clears the path before you begin."
                ),
                LessonStep(
                    id: "l1.s4", kind: .multipleChoice,
                    prompt: "Ganesha is known as the remover of…",
                    detail: nil,
                    options: ["Obstacles", "Rivers", "Mountains", "Stars"],
                    correctIndex: 0
                ),
                LessonStep(
                    id: "l1.s5", kind: .fillBlank,
                    prompt: "Om Gam Ganapataye ______",
                    detail: "Complete the mantra.",
                    options: ["Namaha", "Svaha", "Shanti", "Aim"],
                    correctIndex: 0
                )
            ]
        ),
        Lesson(
            id: "lesson.gayatri.basics",
            title: "The Gayatri Mantra",
            subtitle: "A prayer for a clear mind",
            theme: .wisdom,
            level: 2,
            xp: 25,
            mantraID: "mantra.gayatri",
            steps: [
                LessonStep(
                    id: "l2.s1", kind: .intro,
                    prompt: "The dawn prayer",
                    detail: "The Gayatri Mantra is among the oldest, traditionally chanted at sunrise."
                ),
                LessonStep(
                    id: "l2.s2", kind: .listen,
                    prompt: "Om bhur bhuvah svah…",
                    detail: "Listen to the rhythm. Don't worry about perfect pronunciation."
                ),
                LessonStep(
                    id: "l2.s3", kind: .meaning,
                    prompt: "What we ask for",
                    detail: "Not wealth or success — but a brighter, clearer mind. It is a prayer for wisdom itself."
                ),
                LessonStep(
                    id: "l2.s4", kind: .multipleChoice,
                    prompt: "The Gayatri Mantra is a prayer for…",
                    detail: nil,
                    options: ["A clear mind", "Rain", "Victory in battle", "Long hair"],
                    correctIndex: 0
                )
            ]
        ),
        Lesson(
            id: "lesson.saraswati.focus",
            title: "Saraswati & Focus",
            subtitle: "The student's mantra",
            theme: .knowledge,
            level: 3,
            xp: 25,
            mantraID: "mantra.saraswati",
            steps: [
                LessonStep(
                    id: "l3.s1", kind: .intro,
                    prompt: "Goddess of learning",
                    detail: "Saraswati holds a veena and a book — music and knowledge flowing together."
                ),
                LessonStep(
                    id: "l3.s2", kind: .listen,
                    prompt: "Om Aim Saraswatyai Namaha",
                    detail: "The seed sound 'Aim' is associated with speech and learning."
                ),
                LessonStep(
                    id: "l3.s3", kind: .multipleChoice,
                    prompt: "Saraswati is the goddess of…",
                    detail: nil,
                    options: ["Knowledge & arts", "War", "The sea", "Fire"],
                    correctIndex: 0
                )
            ]
        ),
        Lesson(
            id: "lesson.shanti.peace",
            title: "A Prayer for All",
            subtitle: "The Shanti Mantra",
            theme: .compassion,
            level: 4,
            xp: 30,
            mantraID: "mantra.shanti",
            steps: [
                LessonStep(
                    id: "l4.s1", kind: .intro,
                    prompt: "Goodwill for everyone",
                    detail: "The Shanti Mantra wishes happiness and freedom from suffering for all beings."
                ),
                LessonStep(
                    id: "l4.s2", kind: .listen,
                    prompt: "Sarve bhavantu sukhinah…",
                    detail: "Chant it slowly, picturing the circle of care widening outward."
                ),
                LessonStep(
                    id: "l4.s3", kind: .fillBlank,
                    prompt: "Sarve bhavantu ______ (happy)",
                    detail: "Complete the line.",
                    options: ["Sukhinah", "Niramayah", "Bhadrani", "Shanti"],
                    correctIndex: 0
                )
            ],
            isPremium: true
        )
    ]

    // MARK: - Festivals

    static let festivals: [Festival] = [
        Festival(
            id: "festival.gurupurnima",
            name: "Guru Purnima",
            date: date(2026, 7, 29),
            deity: nil,
            tagline: "Honouring the teachers who light the way",
            significance: "A day to thank the mentors, guides and teachers — formal or not — who have shaped who you are.",
            story: "Guru Purnima falls on the full-moon day honouring Sage Vyasa, who compiled the Vedas and authored the Mahabharata. The word 'guru' means 'one who dispels darkness'. The tradition reminds us that knowledge passed with care is itself sacred.",
            activities: [
                "Message a teacher or mentor to say thank you.",
                "Write down one lesson someone taught you that you still live by.",
                "Spend ten minutes learning something with full attention."
            ],
            theme: .knowledge,
            systemImage: "moon.circle.fill"
        ),
        Festival(
            id: "festival.rakshabandhan",
            name: "Raksha Bandhan",
            date: date(2026, 8, 28),
            deity: nil,
            tagline: "The thread that ties us together",
            significance: "A celebration of the bond between siblings — and of protection, loyalty and love between people who look out for each other.",
            story: "Sisters tie a 'rakhi' — a sacred thread — around their brothers' wrists, and brothers vow to protect them. Over time the festival has grown to celebrate every relationship built on care and protection, far beyond blood ties.",
            activities: [
                "Reach out to a sibling or a friend who feels like family.",
                "Tie or send a rakhi — even a digital one counts.",
                "Recall a time someone had your back, and thank them."
            ],
            theme: .protection,
            systemImage: "link.circle.fill"
        ),
        Festival(
            id: "festival.janmashtami",
            name: "Krishna Janmashtami",
            date: date(2026, 9, 4),
            deity: "Krishna",
            tagline: "The midnight birth of joy and mischief",
            significance: "Celebrating the birth of Krishna — playful, wise, and a reminder to act with love and courage even in difficult times.",
            story: "Krishna was born at midnight in a prison cell, and his father carried him across a flooding river to safety. His life — from butter-stealing child to the charioteer of the Bhagavad Gita — teaches that joy and duty can live side by side.",
            activities: [
                "Read one verse from the Bhagavad Gita.",
                "Do something playful and unselfconscious today.",
                "Reflect: where can you act with courage and lightness?"
            ],
            theme: .devotion,
            systemImage: "flame.circle.fill"
        ),
        Festival(
            id: "festival.ganeshchaturthi",
            name: "Ganesh Chaturthi",
            date: date(2026, 9, 14),
            deity: "Ganesha",
            tagline: "Welcoming the remover of obstacles",
            significance: "A joyful start-of-things festival — perfect for setting intentions and clearing what stands in your way.",
            story: "For ten days, homes and streets welcome Ganesha, then lovingly send his clay form back to the water — a reminder that beginnings and endings are part of one cycle, and nothing worth doing is permanent or perfect.",
            activities: [
                "Name one obstacle you want to move past this month.",
                "Chant 'Om Gam Ganapataye Namaha' eleven times.",
                "Begin one small thing you've been putting off."
            ],
            theme: .courage,
            systemImage: "sparkles"
        ),
        Festival(
            id: "festival.diwali",
            name: "Diwali",
            date: date(2026, 11, 8),
            deity: "Lakshmi",
            tagline: "The festival of lights",
            significance: "The triumph of light over darkness and knowledge over ignorance — a time for renewal, gratitude and fresh starts.",
            story: "Diwali marks Rama's return to Ayodhya after fourteen years of exile, his path lit by rows of lamps. Across India it also honours Lakshmi, goddess of abundance. Lighting a lamp is a quiet vow to keep an inner light burning.",
            activities: [
                "Light a diya or candle and set an intention.",
                "Clear and tidy one small space for a fresh start.",
                "Share something — food, a gift, your time — with someone."
            ],
            theme: .prosperity,
            systemImage: "lightbulb.circle.fill"
        )
    ]

    // MARK: - Stories & Symbols

    static let stories: [StorySymbol] = [
        StorySymbol(
            id: "story.hanuman.leap",
            title: "Hanuman's Leap",
            deity: "Hanuman",
            theme: .courage,
            summary: "He forgot his own strength — until someone reminded him.",
            story: "Tasked with crossing the ocean to find Sita, Hanuman hesitated at the shore. He had grown up being told to be humble and had forgotten the immense power within him. Only when his friends reminded him of who he truly was did he grow vast, gather himself, and leap the entire ocean in a single bound.",
            symbolMeaning: "Hanuman's leap is the classic image of latent potential. The obstacle was never the ocean — it was forgetting his own capacity. We often wait for permission to be as strong as we already are.",
            takeaway: "You are likely more capable than your self-doubt has told you.",
            readMinutes: 4,
            systemImage: "figure.gymnastics"
        ),
        StorySymbol(
            id: "story.ganesha.tusk",
            title: "The Broken Tusk",
            deity: "Ganesha",
            theme: .wisdom,
            summary: "When the pen broke, he used a piece of himself.",
            story: "As the sage Vyasa dictated the vast Mahabharata, Ganesha agreed to write it down — on one condition: that Vyasa never pause. Mid-epic, Ganesha's pen snapped. Rather than break the flow, he broke off his own tusk and kept writing.",
            symbolMeaning: "Ganesha's single tusk is a symbol of sacrifice in service of something larger, and of finishing what you start. Sometimes commitment asks you to improvise with what you have rather than wait for perfect conditions.",
            takeaway: "Done with devotion beats waiting for the perfect tools.",
            readMinutes: 3,
            systemImage: "pencil.and.outline"
        ),
        StorySymbol(
            id: "story.krishna.govardhan",
            title: "Lifting Govardhan Hill",
            deity: "Krishna",
            theme: .protection,
            summary: "A whole village sheltered under one raised finger.",
            story: "When torrential rains threatened his village, the young Krishna lifted the entire Govardhan Hill on his little finger, holding it as an umbrella for seven days while everyone sheltered beneath. The villagers, too, lent their staffs to help hold it up.",
            symbolMeaning: "The story is often read as divine protection, but notice the detail: the people raised their sticks too. Shelter is real, and it is also shared. Protecting others can be both a gift you give and a thing you do together.",
            takeaway: "Lend your strength to shelter others — and let them help.",
            readMinutes: 4,
            systemImage: "mountain.2.fill"
        ),
        StorySymbol(
            id: "story.prahlada.devotion",
            title: "Prahlada's Steadfast Heart",
            deity: "Narasimha",
            theme: .devotion,
            summary: "A child whose faith could not be frightened away.",
            story: "Prahlada, son of a tyrant king, loved the divine no matter how his father threatened him. When the king demanded to know where God was, Prahlada answered: everywhere, even in this pillar. The pillar split, and Narasimha emerged to protect him.",
            symbolMeaning: "Prahlada represents devotion that doesn't flinch under pressure. His faith wasn't loud or rebellious — it was simply unwavering. The lesson is the quiet power of staying true to what you love when it would be easier to abandon it.",
            takeaway: "Quiet steadiness is its own kind of strength.",
            readMinutes: 4,
            systemImage: "heart.circle.fill"
        ),
        StorySymbol(
            id: "story.saraswati.veena",
            title: "Saraswati's Veena",
            deity: "Saraswati",
            theme: .knowledge,
            summary: "Why the goddess of knowledge holds a musical instrument.",
            story: "Saraswati is pictured seated on a white lotus, holding a veena, a book and prayer beads. She does not hold weapons or gold. Her swan can, it is said, separate milk from water — discerning the essential from the rest.",
            symbolMeaning: "The veena tells us knowledge is not dry memorisation; it should flow and resonate like music. The swan reminds us that wisdom is the art of discernment — knowing what to keep and what to let go.",
            takeaway: "Real learning sings, and it knows what to leave behind.",
            readMinutes: 3,
            systemImage: "music.note"
        ),
        StorySymbol(
            id: "story.samudra.manthan",
            title: "Churning the Ocean",
            deity: "Vishnu",
            theme: .discipline,
            summary: "Treasure rose only after the poison was faced.",
            story: "To win the nectar of immortality, gods and demons churned the cosmic ocean together for ages. Before any treasure surfaced, a deadly poison arose — which Shiva drank to save creation, holding it in his throat. Only after that did the nectar finally appear.",
            symbolMeaning: "The churning is a symbol of sustained effort, and of the truth that hard processes often surface the worst before the best. Patience and the willingness to sit with discomfort are what let the nectar rise.",
            takeaway: "The hardest part often comes right before the reward.",
            readMinutes: 5,
            systemImage: "tornado",
            isPremium: true
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
            deepLinkTarget: "lesson:lesson.saraswati.focus"
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
