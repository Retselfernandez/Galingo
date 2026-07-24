/// Tipos de ejercicios disponibles en Galingo
enum ExerciseType {
  multipleChoice,
  fillBlank,
  matching,
  audio,
  translation;

  /// Convierte desde string JSON
  static ExerciseType fromJson(String value) {
    return switch (value) {
      'multiple_choice' => ExerciseType.multipleChoice,
      'fill_blank' => ExerciseType.fillBlank,
      'matching' => ExerciseType.matching,
      'audio' => ExerciseType.audio,
      'translation' => ExerciseType.translation,
      _ => ExerciseType.multipleChoice,
    };
  }

  String toJson() {
    return switch (this) {
      ExerciseType.multipleChoice => 'multiple_choice',
      ExerciseType.fillBlank => 'fill_blank',
      ExerciseType.matching => 'matching',
      ExerciseType.audio => 'audio',
      ExerciseType.translation => 'translation',
    };
  }
}

/// Modelo de ejercicio individual
class ExerciseModel {
  final String id;
  final ExerciseType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final List<Map<String, String>> matchingPairs;
  final String? hint;
  final String? audioAsset;
  final String? explanation;
  final int xpReward;

  const ExerciseModel({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    required this.correctAnswer,
    this.matchingPairs = const [],
    this.hint,
    this.audioAsset,
    this.explanation,
    this.xpReward = 5,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      type: ExerciseType.fromJson(json['type'] as String),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as String,
      matchingPairs: (json['matchingPairs'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      hint: json['hint'] as String?,
      audioAsset: json['audioAsset'] as String?,
      explanation: json['explanation'] as String?,
      xpReward: json['xpReward'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'matchingPairs': matchingPairs,
        'hint': hint,
        'audioAsset': audioAsset,
        'explanation': explanation,
        'xpReward': xpReward,
      };

  ExerciseModel copyWith({
    String? id,
    ExerciseType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    List<Map<String, String>>? matchingPairs,
    String? hint,
    String? audioAsset,
    String? explanation,
    int? xpReward,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      matchingPairs: matchingPairs ?? this.matchingPairs,
      hint: hint ?? this.hint,
      audioAsset: audioAsset ?? this.audioAsset,
      explanation: explanation ?? this.explanation,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  // ─── Localizador Dinámico de Ejercicios (Run-time Localization) ──────────

  static const Map<String, Map<String, String>> _dict = {
    // Saludos / Básicos
    "Hola": {
      "en": "Hello", "pt": "Olá", "fr": "Bonjour", "de": "Hallo", 
      "it": "Ciao", "ro": "Salut", "ar": "مرحبا", "zh": "你好"
    },
    "Adiós": {
      "en": "Goodbye", "pt": "Adeus", "fr": "Au revoir", "de": "Auf Wiedersehen", 
      "it": "Ciao", "ro": "La revedere", "ar": "وداعا", "zh": "再见"
    },
    "Gracias": {
      "en": "Thank you", "pt": "Obrigado", "fr": "Merci", "de": "Danke", 
      "it": "Grazie", "ro": "Mulțumesc", "ar": "شكرا", "zh": "谢谢"
    },
    "Por favor": {
      "en": "Please", "pt": "Por favor", "fr": "S'il vous plaît", "de": "Bitte", 
      "it": "Per favore", "ro": "Vă rog", "ar": "من فضلك", "zh": "请"
    },
    "Buenos días": {
      "en": "Good morning", "pt": "Bom dia", "fr": "Bonjour", "de": "Guten Morgen", 
      "it": "Buongiorno", "ro": "Bună dimineața", "ar": "صباح الخير", "zh": "早上好"
    },
    "Buenas tardes": {
      "en": "Good afternoon", "pt": "Boa tarde", "fr": "Bon après-midi", "de": "Guten Tag", 
      "it": "Buon pomeriggio", "ro": "Bună ziua", "ar": "مساء الخير", "zh": "下午好"
    },
    "Buenas noches": {
      "en": "Good night", "pt": "Boa noite", "fr": "Bonne nuit", "de": "Gute Nacht", 
      "it": "Buonanotte", "ro": "Noapte bună", "ar": "تصبح على خير", "zh": "晚安"
    },
    "Hasta luego": {
      "en": "See you later", "pt": "Até logo", "fr": "À bientôt", "de": "Bis bald", 
      "it": "A presto", "ro": "Pe curând", "ar": "أراك لاحقا", "zh": "回头见"
    },
    "Estoy bien, gracias": {
      "en": "I am fine, thank you", "pt": "Estou bem, obrigado", "fr": "Je vais bien, merci", "de": "Es geht mir gut, danke", 
      "it": "Sto bene, grazie", "ro": "Sunt bine, mulțumesc", "ar": "أنا بخير، شكرا", "zh": "我很好，谢谢"
    },
    
    // Medios de transporte
    "Tren": {
      "en": "Train", "pt": "Trem", "fr": "Train", "de": "Zug", 
      "it": "Treno", "ro": "Tren", "ar": "قطار", "zh": "火车"
    },
    "Autobús": {
      "en": "Bus", "pt": "Ônibus", "fr": "Bus", "de": "Bus", 
      "it": "Autobus", "ro": "Autobuz", "ar": "حافلة", "zh": "公交车"
    },
    "Avión": {
      "en": "Plane", "pt": "Avião", "fr": "Avion", "de": "Flugzeug", 
      "it": "Aereo", "ro": "Avion", "ar": "طائرة", "zh": "飞机"
    },
    "Coche": {
      "en": "Car", "pt": "Carro", "fr": "Voiture", "de": "Auto", 
      "it": "Auto", "ro": "Mașină", "ar": "سيارة", "zh": "汽车"
    },
    "Billete": {
      "en": "Ticket", "pt": "Bilhete", "fr": "Billet", "de": "Ticket", 
      "it": "Biglietto", "ro": "Bilet", "ar": "تذكرة", "zh": "票"
    },

    // Familia
    "Madre": {
      "en": "Mother", "pt": "Mãe", "fr": "Mère", "de": "Mutter", 
      "it": "Madre", "ro": "Mamă", "ar": "أم", "zh": "母亲"
    },
    "Padre": {
      "en": "Father", "pt": "Pai", "fr": "Père", "de": "Vater", 
      "it": "Padre", "ro": "Tată", "ar": "أب", "zh": "父亲"
    },
    "Hermano": {
      "en": "Brother", "pt": "Irmão", "fr": "Frère", "de": "Bruder", 
      "it": "Fratello", "ro": "Frate", "ar": "أخ", "zh": "兄弟"
    },
    "Hermana": {
      "en": "Sister", "pt": "Irmã", "fr": "Sœur", "de": "Schwester", 
      "it": "Sorella", "ro": "Soră", "ar": "أخت", "zh": "姐妹"
    },
    "Abuelo": {
      "en": "Grandfather", "pt": "Avô", "fr": "Grand-père", "de": "Großvater", 
      "it": "Nonno", "ro": "Bunic", "ar": "جد", "zh": "祖父"
    },
    "Abuela": {
      "en": "Grandmother", "pt": "Avó", "fr": "Grand-mère", "de": "Großmutter", 
      "it": "Nonna", "ro": "Bunică", "ar": "جدة", "zh": "祖母"
    },
    "Hijo": {
      "en": "Son", "pt": "Filho", "fr": "Fils", "de": "Sohn", 
      "it": "Figlio", "ro": "Fiu", "ar": "ابن", "zh": "儿子"
    },
    "Hija": {
      "en": "Daughter", "pt": "Filha", "fr": "Fille", "de": "Tochter", 
      "it": "Figlia", "ro": "Fiică", "ar": "ابنة", "zh": "女儿"
    },

    // Colores
    "Rojo": {
      "en": "Red", "pt": "Vermelho", "fr": "Rouge", "de": "Rot", 
      "it": "Rosso", "ro": "Roșu", "ar": "أحمر", "zh": "红色"
    },
    "Azul": {
      "en": "Blue", "pt": "Azul", "fr": "Bleu", "de": "Blau", 
      "it": "Blu", "ro": "Albastru", "ar": "أزرق", "zh": "蓝色"
    },
    "Verde": {
      "en": "Green", "pt": "Verde", "fr": "Vert", "de": "Grün", 
      "it": "Verde", "ro": "Verde", "ar": "أخضر", "zh": "绿色"
    },
    "Amarillo": {
      "en": "Yellow", "pt": "Amarelo", "fr": "Jaune", "de": "Gelb", 
      "it": "Giallo", "ro": "Galben", "ar": "أصفر", "zh": "黄色"
    },
    "Blanco": {
      "en": "White", "pt": "Branco", "fr": "Blanc", "de": "Weiß", 
      "it": "Bianco", "ro": "Alb", "ar": "أبيض", "zh": "白色"
    },
    "Negro": {
      "en": "Black", "pt": "Preto", "fr": "Noir", "de": "Schwarz", 
      "it": "Nero", "ro": "Negru", "ar": "أسود", "zh": "黑色"
    },

    // Comidas
    "Manzana": {
      "en": "Apple", "pt": "Maçã", "fr": "Pomme", "de": "Apfel", 
      "it": "Mela", "ro": "Măr", "ar": "تفاحة", "zh": "苹果"
    },
    "Pan": {
      "en": "Bread", "pt": "Pão", "fr": "Pain", "de": "Brot", 
      "it": "Pane", "ro": "Pâine", "ar": "خبز", "zh": "面包"
    },
    "Agua": {
      "en": "Water", "pt": "Água", "fr": "Eau", "de": "Wasser", 
      "it": "Acqua", "ro": "Apă", "ar": "ماء", "zh": "水"
    },
    "Leche": {
      "en": "Milk", "pt": "Leite", "fr": "Lait", "de": "Milch", 
      "it": "Latte", "ro": "Lapte", "ar": "حليب", "zh": "牛奶"
    },
    "Queso": {
      "en": "Cheese", "pt": "Queijo", "fr": "Fromage", "de": "Käse", 
      "it": "Formaggio", "ro": "Brânză", "ar": "جبن", "zh": "奶酪"
    },
    "Vino": {
      "en": "Wine", "pt": "Vinho", "fr": "Vin", "de": "Wein", 
      "it": "Vino", "ro": "Vin", "ar": "نبيذ", "zh": "葡萄酒"
    },

    // Animales
    "Perro": {
      "en": "Dog", "pt": "Cachorro", "fr": "Chien", "de": "Hund", 
      "it": "Cane", "ro": "Câine", "ar": "كلب", "zh": "狗"
    },
    "Gato": {
      "en": "Cat", "pt": "Gato", "fr": "Chat", "de": "Katze", 
      "it": "Gatto", "ro": "Pisică", "ar": "قط", "zh": "猫"
    },
    "Pájaro": {
      "en": "Bird", "pt": "Pássaro", "fr": "Oiseau", "de": "Vogel", 
      "it": "Uccello", "ro": "Pasăre", "ar": "طائر", "zh": "鸟"
    },
    "Caballo": {
      "en": "Horse", "pt": "Cavalo", "fr": "Cheval", "de": "Pferd", 
      "it": "Cavallo", "ro": "Cal", "ar": "حصان", "zh": "马"
    },
  };

  static String _translateWord(String word, String langCode) {
    if (_dict.containsKey(word)) {
      return _dict[word]![langCode] ?? word;
    }
    for (final key in _dict.keys) {
      if (key.toLowerCase() == word.toLowerCase()) {
        final val = _dict[key]![langCode] ?? word;
        if (word.isNotEmpty && word[0] == word[0].toUpperCase()) {
          return val.isNotEmpty ? "${val[0].toUpperCase()}${val.substring(1)}" : val;
        }
        return val;
      }
    }
    return word;
  }

  ExerciseModel localize(String langCode) {
    if (langCode == 'es') return this;

    final translatedOptions = options.map((opt) => _translateWord(opt, langCode)).toList();
    final translatedCorrect = _translateWord(correctAnswer, langCode);
    final translatedPairs = matchingPairs.map((pair) {
      final leftVal = pair['left'] ?? '';
      final rightVal = pair['right'] ?? '';
      return {
        'left': leftVal,
        'right': _translateWord(rightVal, langCode),
      };
    }).toList();

    String translatedQuestion = question;
    if (question.contains(" '") && question.contains("' en galego?")) {
      final parts = question.split("'");
      if (parts.length >= 3) {
        final quotedWord = parts[1];
        final translatedQuoted = _translateWord(quotedWord, langCode);
        translatedQuestion = switch (langCode) {
          'pt' => "Como se diz '$translatedQuoted' em galego?",
          'fr' => "Comment dit-on '$translatedQuoted' en galicien?",
          'de' => "Wie sagt man '$translatedQuoted' auf Galicisch?",
          'it' => "Come si dice '$translatedQuoted' in galiziano?",
          'ro' => "Cum se spune '$translatedQuoted' în galiciană?",
          'ar' => "كيف تقول '$translatedQuoted' باللغة الجاليكية؟",
          'zh' => "如何用加利西亚语说“$translatedQuoted”？",
          _ => "How do you say '$translatedQuoted' in Galician?"
        };
      }
    } else if (question.startsWith("Que significa '")) {
      final parts = question.split("'");
      if (parts.length >= 3) {
        final quotedWord = parts[1];
        translatedQuestion = switch (langCode) {
          'pt' => "O que significa '$quotedWord'?",
          'fr' => "Que signifie '$quotedWord'?",
          'de' => "Was bedeutet '$quotedWord'?",
          'it' => "Cosa significa '$quotedWord'?",
          'ro' => "Ce înseamnă '$quotedWord'?",
          'ar' => "ماذا يعني '$quotedWord'؟",
          'zh' => "“$quotedWord”是什么意思？",
          _ => "What does '$quotedWord' mean?"
        };
      }
    } else if (question.startsWith("Completa: '") && question.contains(" (")) {
      final parts = question.split("(");
      if (parts.length >= 2) {
        final wordInParens = parts[1].replaceAll(")", "").trim();
        final translatedWord = _translateWord(wordInParens, langCode);
        translatedQuestion = "${parts[0]}($translatedWord)";
      }
    } else if (question.startsWith("Empareja los ") || question.startsWith("Empareja os ")) {
      translatedQuestion = switch (langCode) {
        'pt' => "Emparelhe os elementos com o seu significado",
        'fr' => "Associez les éléments avec leur signification",
        'de' => "Ordnen Sie die Elemente ihrer Bedeutung zu",
        'it' => "Abbina gli elementi con il loro significato",
        'ro' => "Potriviți elementele cu semnificația lor",
        'ar' => "طابق العناصر بمعانيها",
        'zh' => "将元素与其含义配对",
        _ => "Match the items with their meaning"
      };
    }

    return copyWith(
      question: translatedQuestion,
      options: translatedOptions,
      correctAnswer: translatedCorrect,
      matchingPairs: translatedPairs,
    );
  }
}
