/// Data en formato ISO curto (yyyy-MM-dd), útil para comparacións por día.
String toIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String todayIsoDate() => toIsoDate(DateTime.now());
