import 'dart:math';

class ChatService {
  // Intent patterns mirrored from the Python intents.json
  static final List<Map<String, dynamic>> _intents = [
    {
      'tag': 'greeting',
      'patterns': ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'assalam o alaikum', 'salam'],
      'responses': [
        'Hello! Welcome to NTU NavBot. How can I help you today?',
        'Hi there! Need help navigating the campus?',
        'Hey! I\'m your NTU campus assistant. What do you need?',
      ],
    },
    {
      'tag': 'goodbye',
      'patterns': ['bye', 'goodbye', 'see you', 'later', 'thanks bye'],
      'responses': [
        'Goodbye! Have a great day on campus!',
        'See you later! Feel free to ask anytime.',
        'Bye! Stay safe on campus!',
      ],
    },
    {
      'tag': 'library',
      'patterns': ['where is the library', 'library location', 'how to get to library', 'library hours', 'library timings', 'books'],
      'responses': [
        'The Library is located near the Department of Textile Technology. It\'s open Mon-Fri 8 AM to 8 PM, and Sat 9 AM to 5 PM.',
        'You can find the library at coordinates (31.4618, 73.1476). Use the Map tab to navigate there!',
      ],
    },
    {
      'tag': 'cafeteria',
      'patterns': ['where is cafeteria', 'food', 'canteen', 'eat', 'lunch', 'hungry', 'cafe'],
      'responses': [
        'The Cafeteria is centrally located near the cricket ground. It\'s open from 8 AM to 6 PM with a variety of food options.',
        'Head to the Cafeteria for meals! Use the navigation tab — search for "Cafeteria" to find the quickest route.',
      ],
    },
    {
      'tag': 'parking',
      'patterns': ['where is parking', 'car park', 'parking lot', 'vehicle', 'bike parking'],
      'responses': [
        'The main Parking area is at the campus entrance, near coordinates (31.4608, 73.1471).',
        'Parking is located at the south entrance of NTU. Both car and bike parking are available.',
      ],
    },
    {
      'tag': 'hostel',
      'patterns': ['hostel', 'boys hostel', 'girls hostel', 'accommodation', 'dorm', 'residence'],
      'responses': [
        'NTU has both Boys and Girls Hostels. The New Boys Hostel is at the west side, Old Boys Hostel further west, and Girls Hostel is on the east side near the cricket ground.',
        'For hostel queries, the New Boys Hostel is near the soccer ground, and Girls Hostel is near the faculty hostel area.',
      ],
    },
    {
      'tag': 'admission',
      'patterns': ['admission', 'admissions', 'how to apply', 'apply', 'enrollment', 'registration'],
      'responses': [
        'The NTU Admission Office is near the main entrance. You can also visit https://admissions.ntu.edu.pk/ for online applications.',
        'For admissions info, visit the Admission Office on campus or check the NTU website for deadlines and requirements.',
      ],
    },
    {
      'tag': 'it_center',
      'patterns': ['it center', 'computer lab', 'internet', 'wifi', 'it department'],
      'responses': [
        'The IT Center is located at (31.4628, 73.1489), near the School of Arts and Design. WiFi is available campus-wide.',
        'Head to the IT Center for computer labs and tech support. It\'s open during regular campus hours.',
      ],
    },
    {
      'tag': 'weather',
      'patterns': ['weather', 'temperature', 'rain', 'hot', 'cold', 'forecast'],
      'responses': [
        'You can check real-time campus weather on the Home tab! Tap the weather card for detailed forecasts.',
        'For weather info, go to Home → Weather card. It shows live temperature, humidity, and wind data for NTU Faisalabad.',
      ],
    },
    {
      'tag': 'masjid',
      'patterns': ['masjid', 'mosque', 'prayer', 'namaz', 'jumma'],
      'responses': [
        'The campus Masjid is located at (31.4632, 73.1475), near the cricket ground. Jummah prayers are held every Friday.',
        'The Masjid is centrally located. Prayer times are displayed at the entrance. Friday prayers start at 1:00 PM.',
      ],
    },
    {
      'tag': 'sports',
      'patterns': ['sports', 'ground', 'play', 'cricket', 'football', 'hockey', 'gym', 'badminton'],
      'responses': [
        'NTU has Cricket Ground, Soccer Ground, Hockey Ground, Badminton courts, and an Open Gym! Check the Map tab for locations.',
        'Sports facilities: Play Ground (south), Cricket Ground (center), Soccer Ground (west), Hockey Ground (east), Open Gym (north-west).',
      ],
    },
    {
      'tag': 'rector',
      'patterns': ['rector', 'rector office', 'vice chancellor', 'vc office'],
      'responses': [
        'The Rector\'s Office is located at (31.4620, 73.1487), near the University Auditorium.',
        'You can find the Rector Office east of CECA building. Appointments can be scheduled through the admin office.',
      ],
    },
    {
      'tag': 'departments',
      'patterns': ['departments', 'textile', 'engineering', 'arts', 'fbs', 'business school', 'ceca', 'polymer'],
      'responses': [
        'NTU has several departments: School of Engineering & Technology, Textile Technology, CECA, School of Arts & Design, FBS, Polymer Engineering, and more. Use the Map tab to find any department!',
        'Major departments include: Textile Technology, CECA (Civil Engineering), FBS (Business School), School of Arts & Design, and School of Engineering & Technology.',
      ],
    },
    {
      'tag': 'dispensary',
      'patterns': ['dispensary', 'medical', 'doctor', 'health', 'clinic', 'sick', 'medicine'],
      'responses': [
        'The campus Dispensary is at (31.4629, 73.1497), near FBS. A doctor is available during campus hours for basic medical needs.',
        'For medical assistance, visit the Dispensary near the School of Arts and Design. Emergency contacts are posted at the entrance.',
      ],
    },
    {
      'tag': 'contact',
      'patterns': ['contact', 'phone', 'email', 'helpline', 'number'],
      'responses': [
        'NTU Contact: Phone: +92-41-9230081-85, Website: www.ntu.edu.pk, Email: info@ntu.edu.pk',
        'You can reach NTU at +92-41-9230081. Visit https://ntu.edu.pk/contact-us.php for more contact details.',
      ],
    },
    {
      'tag': 'thanks',
      'patterns': ['thanks', 'thank you', 'appreciate', 'helpful'],
      'responses': [
        'You\'re welcome! Happy to help. 😊',
        'Glad I could help! Feel free to ask anything else.',
        'Anytime! That\'s what I\'m here for. 🎓',
      ],
    },
  ];

  static final Random _random = Random();

  /// Processes user message and returns bot response (simulates API call)
  Future<String> getResponse(String userMessage) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400 + 200));

    final lower = userMessage.toLowerCase().trim();

    if (lower.isEmpty) {
      return 'Please type a message so I can help you!';
    }

    // Find matching intent
    double bestScore = 0;
    Map<String, dynamic>? bestIntent;

    for (final intent in _intents) {
      final patterns = intent['patterns'] as List<String>;
      for (final pattern in patterns) {
        final score = _similarity(lower, pattern.toLowerCase());
        if (score > bestScore) {
          bestScore = score;
          bestIntent = intent;
        }
      }
    }

    if (bestScore > 0.4 && bestIntent != null) {
      final responses = bestIntent['responses'] as List<String>;
      return responses[_random.nextInt(responses.length)];
    }

    return 'I\'m not sure how to answer that. Try asking about campus buildings, library, cafeteria, hostels, weather, sports, or admissions!';
  }

  /// Simple word-overlap similarity (simulates the bag-of-words approach from Python)
  double _similarity(String input, String pattern) {
    final inputWords = input.split(RegExp(r'\s+'));
    final patternWords = pattern.split(RegExp(r'\s+'));
    int matches = 0;
    for (final pw in patternWords) {
      if (inputWords.any((iw) => iw.contains(pw) || pw.contains(iw))) {
        matches++;
      }
    }
    return matches / patternWords.length;
  }
}
