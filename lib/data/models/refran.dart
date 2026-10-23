/// Refrán galego coa súa tradución ao castelán.
///
/// A lista definitiva será revisada/ampliada polo autor; de momento só
/// inclúe refráns reais contrastados.
class Refran {
  final String gl;
  final String es;

  const Refran(this.gl, this.es);
}

const List<Refran> kRefrans = [
  Refran(
    'Non hai mal tempo, só mala roupa.',
    'No hay mal tiempo, solo mala ropa.',
  ),
  Refran(
    'Máis vale tarde que nunca.',
    'Más vale tarde que nunca.',
  ),
  Refran(
    'Pouco a pouco fíxose Roma.',
    'Poco a poco se hizo Roma.',
  ),
  Refran(
    'Cando o río soa, auga leva.',
    'Cuando el río suena, agua lleva.',
  ),
  Refran(
    'O saber non ocupa lugar.',
    'El saber no ocupa lugar.',
  ),
  Refran(
    'Ao mal tempo, boa cara.',
    'A mal tiempo, buena cara.',
  ),
  Refran(
    'Quen ten lingua, a Roma vai.',
    'Quien tiene lengua, a Roma va.',
  ),
];

/// Refrán determinista por data: todos ven o mesmo cada día.
Refran refranForDate(DateTime date) {
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime(2026, 1, 1))
      .inDays;
  final i = days % kRefrans.length;
  return kRefrans[i < 0 ? i + kRefrans.length : i];
}
