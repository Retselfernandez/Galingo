/// Tipos de ejercicios disponibles en Galingo
enum ExerciseType {
  multipleChoice,
  fillBlank,
  matching,
  audio,
  translation,
  speech;

  /// Convierte desde string JSON
  static ExerciseType fromJson(String value) {
    return switch (value) {
      'multiple_choice' => ExerciseType.multipleChoice,
      'fill_blank' => ExerciseType.fillBlank,
      'matching' => ExerciseType.matching,
      'audio' => ExerciseType.audio,
      'translation' => ExerciseType.translation,
      'speech' => ExerciseType.speech,
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
      ExerciseType.speech => 'speech',
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
  /// Traducciones de los textos de prompt por idioma: {locale: {question, hint, explanation}}
  final Map<String, Map<String, String>> i18n;

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
    this.i18n = const {},
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
      i18n: (json['i18n'] as Map<String, dynamic>?)?.map(
            (locale, texts) => MapEntry(
              locale,
              (texts as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, v as String),
              ),
            ),
          ) ??
          {},
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
    Map<String, Map<String, String>>? i18n,
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
      i18n: i18n ?? this.i18n,
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
    "A la izquierda": {"en": "To the left", "pt": "À esquerda", "fr": "À gauche", "de": "Links", "it": "A sinistra", "ro": "La stânga", "zh": "在左边"},
    "Armario": {"en": "Wardrobe", "pt": "Armário", "fr": "Armoire", "de": "Schrank", "it": "Armadio", "ro": "Dulap", "zh": "衣柜"},
    "Baño": {"en": "Bathroom", "pt": "Banheiro", "fr": "Salle de bain", "de": "Badezimmer", "it": "Bagno", "ro": "Baie", "zh": "卫生间"},
    "Brazo": {"en": "Arm", "pt": "Braço", "fr": "Bras", "de": "Arm", "it": "Braccio", "ro": "Braț", "zh": "手臂"},
    "Bueno/a": {"en": "Good", "pt": "Bom", "fr": "Bon", "de": "Gut", "it": "Buono", "ro": "Bun", "zh": "好"},
    "Cama": {"en": "Bed", "pt": "Cama", "fr": "Lit", "de": "Bett", "it": "Letto", "ro": "Pat", "zh": "床"},
    "Caminar": {"en": "Walk", "pt": "Caminhar", "fr": "Marcher", "de": "Gehen", "it": "Camminare", "ro": "A merge", "zh": "走路"},
    "Carne": {"en": "Meat", "pt": "Carne", "fr": "Viande", "de": "Fleisch", "it": "Carne", "ro": "Carne", "zh": "肉"},
    "Catorce": {"en": "Fourteen", "pt": "Catorze", "fr": "Quatorze", "de": "Vierzehn", "it": "Quattordici", "ro": "Paisprezece", "zh": "十四"},
    "Cen": {"en": "Cen", "pt": "Cen", "fr": "Cen", "de": "Cen", "it": "Cen", "ro": "Cen", "zh": "Cen"},
    "Cerca": {"en": "Near", "pt": "Perto", "fr": "Près", "de": "Nah", "it": "Vicino", "ro": "Aproape", "zh": "近"},
    "Cinco": {"en": "Five", "pt": "Cinco", "fr": "Cinq", "de": "Fünf", "it": "Cinque", "ro": "Cinci", "zh": "五"},
    "Cincuenta": {"en": "Fifty", "pt": "Cinquenta", "fr": "Cinquante", "de": "Fünfzig", "it": "Cinquanta", "ro": "Cincizeci", "zh": "五十"},
    "Corenta e cinco": {"en": "Corenta e cinco", "pt": "Corenta e cinco", "fr": "Corenta e cinco", "de": "Corenta e cinco", "it": "Corenta e cinco", "ro": "Corenta e cinco", "zh": "Corenta e cinco"},
    "Dez": {"en": "Dez", "pt": "Dez", "fr": "Dez", "de": "Dez", "it": "Dez", "ro": "Dez", "zh": "Dez"},
    "Dezanove": {"en": "Dezanove", "pt": "Dezanove", "fr": "Dezanove", "de": "Dezanove", "it": "Dezanove", "ro": "Dezanove", "zh": "Dezanove"},
    "Dezasete": {"en": "Dezasete", "pt": "Dezasete", "fr": "Dezasete", "de": "Dezasete", "it": "Dezasete", "ro": "Dezasete", "zh": "Dezasete"},
    "Diciembre": {"en": "December", "pt": "Dezembro", "fr": "Décembre", "de": "Dezember", "it": "Dicembre", "ro": "Decembrie", "zh": "十二月"},
    "Dormir": {"en": "Sleep", "pt": "Dormir", "fr": "Dormir", "de": "Schlafen", "it": "Dormire", "ro": "A dormi", "zh": "睡觉"},
    "El correo electrónico": {"en": "Email", "pt": "E-mail", "fr": "E-mail", "de": "E-Mail", "it": "Email", "ro": "Email", "zh": "电子邮件"},
    "El cuchillo": {"en": "Knife", "pt": "Faca", "fr": "Couteau", "de": "Messer", "it": "Coltello", "ro": "Cuțit", "zh": "刀"},
    "El menú": {"en": "Menu", "pt": "Menu", "fr": "Menu", "de": "Menü", "it": "Menu", "ro": "Meniu", "zh": "菜单"},
    "El más...": {"en": "More...", "pt": "Mais...", "fr": "Plus...", "de": "Mehr...", "it": "Più...", "ro": "Mai...", "zh": "更..."},
    "El plato": {"en": "Plate", "pt": "Prato", "fr": "Assiette", "de": "Teller", "it": "Piatto", "ro": "Farfurie", "zh": "盘子"},
    "El teléfono": {"en": "Telephone", "pt": "Telefone", "fr": "Téléphone", "de": "Telefon", "it": "Telefono", "ro": "Telefon", "zh": "电话"},
    "El tenedor": {"en": "Fork", "pt": "Garfo", "fr": "Fourchette", "de": "Gabel", "it": "Forchetta", "ro": "Furculiță", "zh": "叉"},
    "Ellos hablaron": {"en": "They spoke", "pt": "Eles falaram", "fr": "Ils ont parlé", "de": "Sie sprachen", "it": "Loro hanno parlato", "ro": "Ei au vorbit", "zh": "他们说过"},
    "Ellos hablarán": {"en": "They will speak", "pt": "Eles falarão", "fr": "Ils parleront", "de": "Sie werden sprechen", "it": "Loro parleranno", "ro": "Ei vor vorbi", "zh": "他们会说"},
    "Ellos son": {"en": "They are", "pt": "Eles são", "fr": "Ils sont", "de": "Sie sind", "it": "Loro sono", "ro": "Ei sunt", "zh": "他们是"},
    "Ellos tienen": {"en": "They have", "pt": "Eles têm", "fr": "Ils ont", "de": "Sie haben", "it": "Loro hanno", "ro": "Ei au", "zh": "他们有"},
    "Ellos vivieron": {"en": "They lived", "pt": "Eles viveram", "fr": "Ils ont vécu", "de": "Sie lebten", "it": "Loro hanno vissuto", "ro": "Ei au trăit", "zh": "他们生活过"},
    "Escuchar música": {"en": "Listen to music", "pt": "Ouvir música", "fr": "Écouter de la musique", "de": "Musik hören", "it": "Ascoltare musica", "ro": "A asculta muzică", "zh": "听音乐"},
    "Estoy enfermo/a": {"en": "I am sick", "pt": "Estou doente", "fr": "Je suis malade", "de": "Ich bin krank", "it": "Sono malato", "ro": "Sunt bolnav", "zh": "我生病了"},
    "Gallina": {"en": "Hen", "pt": "Galinha", "fr": "Poule", "de": "Henne", "it": "Gallina", "ro": "Găină", "zh": "母鸡"},
    "Habitación": {"en": "Room", "pt": "Quarto", "fr": "Pièce", "de": "Zimmer", "it": "Stanza", "ro": "Cameră", "zh": "房间"},
    "Hablo gallego": {"en": "I speak Galician", "pt": "Eu falo galego", "fr": "Je parle galicien", "de": "Ich spreche Galicisch", "it": "Io parlo galiziano", "ro": "Eu vorbesc galego", "zh": "我说加利西亚语"},
    "Hace calor": {"en": "It's hot", "pt": "Está quente", "fr": "Il fait chaud", "de": "Es ist heiß", "it": "Fa caldo", "ro": "E cald", "zh": "天气热"},
    "Hace viento": {"en": "It's windy", "pt": "Está ventando", "fr": "Il y a du vent", "de": "Es ist windig", "it": "C'è vento", "ro": "E vânt", "zh": "有风"},
    "Huevo": {"en": "Egg", "pt": "Ovo", "fr": "Œuf", "de": "Ei", "it": "Uovo", "ro": "Ou", "zh": "鸡蛋"},
    "Internet": {"en": "Internet", "pt": "Internet", "fr": "Internet", "de": "Internet", "it": "Internet", "ro": "Internet", "zh": "互联网"},
    "Jardín": {"en": "Garden", "pt": "Jardim", "fr": "Jardin", "de": "Garten", "it": "Giardino", "ro": "Grădină", "zh": "花园"},
    "Jueves": {"en": "Thursday", "pt": "Quinta-feira", "fr": "Jeudi", "de": "Donnerstag", "it": "Giovedì", "ro": "Joi", "zh": "星期四"},
    "Jugar al fútbol": {"en": "Play football", "pt": "Jogar futebol", "fr": "Jouer au football", "de": "Fußball spielen", "it": "Giocare a calcio", "ro": "A juca fotbal", "zh": "踢足球"},
    "La pantalla": {"en": "Screen", "pt": "Ecrã", "fr": "Écran", "de": "Bildschirm", "it": "Schermo", "ro": "Ecran", "zh": "屏幕"},
    "Leer": {"en": "Read", "pt": "Ler", "fr": "Lire", "de": "Lesen", "it": "Leggere", "ro": "A citi", "zh": "阅读"},
    "Leer libros": {"en": "Read books", "pt": "Ler livros", "fr": "Lire des livres", "de": "Bücher lesen", "it": "Leggere libri", "ro": "A citi cărți", "zh": "读书"},
    "Lejos": {"en": "Far", "pt": "Longe", "fr": "Loin", "de": "Weit", "it": "Lontano", "ro": "Departe", "zh": "远"},
    "Llueve": {"en": "It's raining", "pt": "Está a chover", "fr": "Il pleut", "de": "Es regnet", "it": "Piove", "ro": "Plouă", "zh": "下雨"},
    "Malo/a": {"en": "Bad", "pt": "Mau", "fr": "Mauvais", "de": "Schlecht", "it": "Cattivo", "ro": "Rău", "zh": "坏"},
    "Mano": {"en": "Hand", "pt": "Mão", "fr": "Main", "de": "Hand", "it": "Mano", "ro": "Mână", "zh": "手"},
    "Martes": {"en": "Tuesday", "pt": "Terça-feira", "fr": "Mardi", "de": "Dienstag", "it": "Martedì", "ro": "Marți", "zh": "星期二"},
    "Marzo": {"en": "March", "pt": "Março", "fr": "Mars", "de": "März", "it": "Marzo", "ro": "Martie", "zh": "三月"},
    "Mayo": {"en": "May", "pt": "Maio", "fr": "Mai", "de": "Mai", "it": "Maggio", "ro": "Mai", "zh": "五月"},
    "Me duele la garganta": {"en": "My throat hurts", "pt": "Dói-me a garganta", "fr": "J'ai mal à la gorge", "de": "Mein Hals tut weh", "it": "Mi fa male la gola", "ro": "Mă doare gâtul", "zh": "我喉咙痛"},
    "Me llamo Ana": {"en": "My name is Ana", "pt": "Eu me chamo Ana", "fr": "Je m'appelle Ana", "de": "Ich heiße Ana", "it": "Mi chiamo Ana", "ro": "Eu mă numesc Ana", "zh": "我叫Ana"},
    "Menos... que": {"en": "Less... than", "pt": "Menos... que", "fr": "Moins... que", "de": "Weniger... als", "it": "Meno... di", "ro": "Mai puțin... decât", "zh": "比…少"},
    "Mesa": {"en": "Table", "pt": "Mesa", "fr": "Table", "de": "Tisch", "it": "Tavolo", "ro": "Masă", "zh": "桌子"},
    "Miércoles": {"en": "Wednesday", "pt": "Quarta-feira", "fr": "Mercredi", "de": "Mittwoch", "it": "Mercoledì", "ro": "Miercuri", "zh": "星期三"},
    "Más... que": {"en": "More... than", "pt": "Mais... que", "fr": "Plus... que", "de": "Mehr... als", "it": "Più... di", "ro": "Mai... decât", "zh": "比…多"},
    "Necesito un médico": {"en": "I need a doctor", "pt": "Preciso de um médico", "fr": "J'ai besoin d'un médecin", "de": "Ich brauche einen Arzt", "it": "Ho bisogno di un medico", "ro": "Am nevoie de un medic", "zh": "我需要医生"},
    "Nieva": {"en": "It's snowing", "pt": "Está a nevar", "fr": "Il neige", "de": "Es schneit", "it": "Nevica", "ro": "Ninge", "zh": "下雪"},
    "Nosotros hablamos": {"en": "We speak", "pt": "Nós falamos", "fr": "Nous parlons", "de": "Wir sprechen", "it": "Noi parliamo", "ro": "Noi vorbim", "zh": "我们说"},
    "Nosotros hablaremos": {"en": "We will speak", "pt": "Nós falaremos", "fr": "Nous parlerons", "de": "Wir werden sprechen", "it": "Noi parleremo", "ro": "Noi vom vorbi", "zh": "我们会说"},
    "Nosotros somos": {"en": "We are", "pt": "Nós somos", "fr": "Nous sommes", "de": "Wir sind", "it": "Noi siamo", "ro": "Noi suntem", "zh": "我们是"},
    "Nosotros tenemos": {"en": "We have", "pt": "Nós temos", "fr": "Nous avons", "de": "Wir haben", "it": "Noi abbiamo", "ro": "Noi avem", "zh": "我们有"},
    "Nosotros vivimos": {"en": "We live", "pt": "Nós vivemos", "fr": "Nous vivons", "de": "Wir leben", "it": "Noi viviamo", "ro": "Noi trăim", "zh": "我们住"},
    "Noventa": {"en": "Ninety", "pt": "Noventa", "fr": "Quatre-vingt-dix", "de": "Neunzig", "it": "Novanta", "ro": "Nouăzeci", "zh": "九十"},
    "Nuevo/a": {"en": "New", "pt": "Novo", "fr": "Nouveau", "de": "Neu", "it": "Nuovo", "ro": "Nou", "zh": "新"},
    "Oitenta": {"en": "Oitenta", "pt": "Oitenta", "fr": "Oitenta", "de": "Oitenta", "it": "Oitenta", "ro": "Oitenta", "zh": "Oitenta"},
    "Oito": {"en": "Oito", "pt": "Oito", "fr": "Oito", "de": "Oito", "it": "Oito", "ro": "Oito", "zh": "Oito"},
    "Pequeño/a": {"en": "Small", "pt": "Pequeno", "fr": "Petit", "de": "Klein", "it": "Piccolo", "ro": "Mic", "zh": "小"},
    "Pescado": {"en": "Fish", "pt": "Peixe", "fr": "Poisson", "de": "Fisch", "it": "Pesce", "ro": "Pește", "zh": "鱼"},
    "Pie": {"en": "Foot", "pt": "Pé", "fr": "Pied", "de": "Fuß", "it": "Piede", "ro": "Picior", "zh": "脚"},
    "Pierna": {"en": "Leg", "pt": "Perna", "fr": "Jambe", "de": "Bein", "it": "Gamba", "ro": "Picior", "zh": "腿"},
    "Recto/derecho": {"en": "Straight ahead", "pt": "Em frente", "fr": "Tout droit", "de": "Geradeaus", "it": "Dritto", "ro": "Drept", "zh": "直"},
    "Salón": {"en": "Living room", "pt": "Sala", "fr": "Salon", "de": "Wohnzimmer", "it": "Soggiorno", "ro": "Salon", "zh": "客厅"},
    "Septiembre": {"en": "September", "pt": "Setembro", "fr": "Septembre", "de": "September", "it": "Settembre", "ro": "Septembrie", "zh": "九月"},
    "Sesenta": {"en": "Sixty", "pt": "Sessenta", "fr": "Soixante", "de": "Sechzig", "it": "Sessanta", "ro": "Șaizeci", "zh": "六十"},
    "Setenta": {"en": "Seventy", "pt": "Setenta", "fr": "Soixante-dix", "de": "Siebzig", "it": "Settanta", "ro": "Șaptezeci", "zh": "七十"},
    "Setenta e dous": {"en": "Setenta e dous", "pt": "Setenta e dous", "fr": "Setenta e dous", "de": "Setenta e dous", "it": "Setenta e dous", "ro": "Setenta e dous", "zh": "Setenta e dous"},
    "Sofá": {"en": "Sofa", "pt": "Sofá", "fr": "Canapé", "de": "Sofa", "it": "Divano", "ro": "Canapea", "zh": "沙发"},
    "Soy de Vigo": {"en": "I am from Vigo", "pt": "Eu sou de Vigo", "fr": "Je viens de Vigo", "de": "Ich komme aus Vigo", "it": "Sono di Vigo", "ro": "Eu sunt din Vigo", "zh": "我来自维戈"},
    "Tan... como": {"en": "As... as", "pt": "Tão... como", "fr": "Aussi... que", "de": "So... wie", "it": "Così... come", "ro": "La fel de... ca", "zh": "像…一样"},
    "Tengo 25 años": {"en": "I am 25 years old", "pt": "Tenho 25 anos", "fr": "J'ai 25 ans", "de": "Ich bin 25 Jahre alt", "it": "Ho 25 anni", "ro": "Am 25 de ani", "zh": "我25岁"},
    "Tengo 25 years": {"en": "I am 25 years old", "pt": "Tenho 25 anos", "fr": "J'ai 25 ans", "de": "Ich bin 25 Jahre alt", "it": "Ho 25 anni", "ro": "Am 25 de ani", "zh": "我25岁"},
    "Tengo fiebre": {"en": "I have a fever", "pt": "Tenho febre", "fr": "J'ai de la fièvre", "de": "Ich habe Fieber", "it": "Ho la febbre", "ro": "Am febră", "zh": "我发烧了"},
    "Trabajar": {"en": "Work", "pt": "Trabalhar", "fr": "Travailler", "de": "Arbeiten", "it": "Lavorare", "ro": "A munci", "zh": "工作"},
    "Trinta": {"en": "Trinta", "pt": "Trinta", "fr": "Trinta", "de": "Trinta", "it": "Trinta", "ro": "Trinta", "zh": "Trinta"},
    "Tú eres": {"en": "You are", "pt": "Tu és", "fr": "Tu es", "de": "Du bist", "it": "Tu sei", "ro": "Tu ești", "zh": "你是"},
    "Tú hablarás": {"en": "You will speak", "pt": "Tu falarás", "fr": "Tu parleras", "de": "Du wirst sprechen", "it": "Tu parlerai", "ro": "Tu vei vorbi", "zh": "你会说"},
    "Tú hablaste": {"en": "You spoke", "pt": "Tu falaste", "fr": "Tu as parlé", "de": "Du sprachst", "it": "Tu hai parlato", "ro": "Tu ai vorbit", "zh": "你说过"},
    "Tú tienes": {"en": "You have", "pt": "Tu tens", "fr": "Tu as", "de": "Du hast", "it": "Tu hai", "ro": "Tu ai", "zh": "你有"},
    "Tú viviste": {"en": "You lived", "pt": "Tu viveste", "fr": "Tu as vécu", "de": "Du lebtest", "it": "Tu hai vissuto", "ro": "Tu ai trăit", "zh": "你住过"},
    "Un/Unha": {"en": "One/a", "pt": "Um/uma", "fr": "Un/une", "de": "Ein/eine", "it": "Uno/una", "ro": "Un/o", "zh": "一个"},
    "Vaca": {"en": "Cow", "pt": "Vaca", "fr": "Vache", "de": "Kuh", "it": "Vacca", "ro": "Vacă", "zh": "牛"},
    "Ver películas": {"en": "Watch movies", "pt": "Ver filmes", "fr": "Regarder des films", "de": "Filme sehen", "it": "Guardare film", "ro": "A viziona filme", "zh": "看电影"},
    "Viernes": {"en": "Friday", "pt": "Sexta-feira", "fr": "Vendredi", "de": "Freitag", "it": "Venerdì", "ro": "Vineri", "zh": "星期五"},
    "Él/Ella es": {"en": "He/She is", "pt": "Ele/Ela é", "fr": "Il/Elle est", "de": "Er/Sie ist", "it": "Lui/Lei è", "ro": "El/Ea este", "zh": "他/她是"},
    "Él/Ella hablará": {"en": "He/She will speak", "pt": "Ele/Ela falará", "fr": "Il/Elle parlera", "de": "Er/Sie wird sprechen", "it": "Lui/Lei parlerà", "ro": "El/Ea va vorbi", "zh": "他/她会说"},
    "Él/Ella habló": {"en": "He/She spoke", "pt": "Ele/Ela falou", "fr": "Il/Elle a parlé", "de": "Er/Sie sprach", "it": "Lui/Lei ha parlato", "ro": "El/Ea a vorbit", "zh": "他/她说过"},
    "Él/Ella tiene": {"en": "He/She has", "pt": "Ele/Ela tem", "fr": "Il/Elle a", "de": "Er/Sie hat", "it": "Lui/Lei ha", "ro": "El/Ea are", "zh": "他/她有"},
    "Él/Ella vivió": {"en": "He/She lived", "pt": "Ele/Ela viveu", "fr": "Il/Elle a vécu", "de": "Er/Sie lebte", "it": "Lui/Lei ha vissuto", "ro": "El/Ea a trăit", "zh": "他/她住过"},
  };

  /// Devuelve el ejercicio con los textos de prompt traducidos.
  /// options/correctAnswer/matchingPairs permanecen en gallego (lengua objetivo).
  static String _translateWord(String word, String langCode) {
    if (_dict.containsKey(word)) return _dict[word]![langCode] ?? word;
    for (final key in _dict.keys) {
      if (key.toLowerCase() == word.toLowerCase()) {
        return _dict[key]![langCode] ?? word;
      }
    }
    return word;
  }

  ExerciseModel localize(String langCode) {
    final texts = i18n[langCode] ?? i18n['es'];
    if (texts == null) return this;
    final translatedPairs = matchingPairs.map((pair) {
      final left = pair['left'] ?? '';
      final right = pair['right'] ?? '';
      return {
        'left': left, // la palabra gallega permanece
        'right': _translateWord(right, langCode), // la pista en el idioma del usuario
      };
    }).toList();

    // Heurística: si la pregunta pide el *significado* de una palabra gallega,
    // las opciones son traducidas (deben localizarse). Si pide *cómo se dice*,
    // las opciones son palabras en gallego (no se tocan).
    final qLower = question.toLowerCase();
    final optionsAreTranslations = qLower.contains('significa') ||
        qLower.contains('what does') ||
        qLower.contains('o que significa') ||
        qLower.contains('que signifie') ||
        qLower.contains('was bedeutet') ||
        qLower.contains('cosa significa') ||
        qLower.contains('ce înseamnă');

    final translatedOptions = optionsAreTranslations
        ? options.map((o) => _translateWord(o, langCode)).toList()
        : options;
    final translatedAnswer = optionsAreTranslations
        ? _translateWord(correctAnswer, langCode)
        : correctAnswer;

    return copyWith(
      question: texts['question'] ?? question,
      hint: texts['hint'] ?? hint,
      explanation: texts['explanation'] ?? explanation,
      options: translatedOptions,
      correctAnswer: translatedAnswer,
      matchingPairs: translatedPairs,
    );
  }

}
