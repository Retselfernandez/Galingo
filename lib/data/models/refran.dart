/// Refrán galego adaptado como mensaxe de recordatorio.
///
/// `{nome}` substitúese polo nome do usuario no momento de programar
/// a notificación. Cada texto pode ter unha ou varias frases: a primeira
/// úsase como título e o resto como corpo.
class Refran {
  final String text;

  const Refran(this.text);
}

const List<Refran> kRefrans = [
  Refran('{nome}, nunca choveu que non escampara. Aínda que onte fallases, hoxe podes retomar a racha.'),
  Refran('Malo será, {nome}. Con cinco minutos de galego a lección de hoxe está feita.'),
  Refran('Éche o que hai, {nome}. A lección de hoxe segue sen facer, e Gabi agarda.'),
  Refran('Non sexa o demo, {nome}. Que se che perda a racha. Fai a lección agora!'),
  Refran('Amiguiños si, {nome}, pero a vaquiña polo que vale. Gabi é o teu amigo, pero a racha vale ouro. Non a perdas.'),
  Refran('Tanto ten Xan coma Perillán, {nome}. Tanto ten verbos ou vocabulario: practica algo hoxe.'),
  Refran('Galiña vella fai bo caldo, {nome}. A experiencia gáñase lección a lección. Hoxe toca unha máis.'),
  Refran('Tarde piaches, {nome}? Aínda non! Tes tempo ata a medianoite para salvar a racha.'),
  Refran('Sae máis caro a salsa có peixe, {nome}. Perder a racha custa máis ca facer unha lección de cinco minutos.'),
  Refran('{nome}, a todo porco lle chega o seu San Martiño. E á túa racha tamén, se hoxe non practicas.'),
  Refran('Xente nova e leña verde, todo é fume, {nome}. O entusiasmo do principio non abonda: o que funciona é a constancia.'),
  Refran('Fai o que o crego dixere, {nome}. Prometeches practicar galego cada día. Fai o que dixeches!'),
  Refran('Mexan por nós e hai que dicir que chove, {nome}. Mesmo nun día complicado, unha lección rápida cabe sempre.'),
  Refran('Quen ten cu, ten medo, {nome}. E Gabi ten medo de que perdas a túa racha.'),
  Refran('Chegar e encher, {nome}. Abre a app e remata a lección en cinco minutos.'),
  Refran('Se chove que chova, {nome}. Chova ou escampe, hoxe toca lección.'),
  Refran('Sogros e porcos, só son bos despois de mortos, {nome}. Pero o galego mellora con práctica diaria. Xa tes a lección de hoxe?'),
  Refran('A rañala, {nome}! Fóra escusas! A lección de hoxe está agardando.'),
  Refran('Marcho que teño que marchar, {nome}... Pero non sen facer antes a lección de hoxe.'),
  Refran('Xa caíches da burra, {nome}? Hoxe aínda non practicaches, pero estás a tempo.'),
  Refran('Vai pola sombra, {nome}. Sen presión: con unha lección curtiña xa vale.'),
  Refran('{nome}, es máis listo ca un allo. Demóstrao coa lección de hoxe.'),
  Refran('Outra vaca no millo, {nome}. Outro día sen practicar? Rompe a mala racha hoxe.'),
  Refran('{nome}, quedarás coma un Pepe. Cando remates a lección de hoxe, sentirás que mereceu a pena.'),
  Refran('Morra o conto, {nome}. Sen máis voltas: lección agora.'),
];

/// Refrán determinista por data: todos ven o mesmo cada día.
Refran refranForDate(DateTime date) {
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime(2026, 1, 1))
      .inDays;
  final i = days % kRefrans.length;
  return kRefrans[i < 0 ? i + kRefrans.length : i];
}

/// Separa o refrán (primeira frase) do resto da mensaxe.
({String title, String body}) refranParts(Refran refran, String userName) {
  final text = refran.text.replaceAll('{nome}', userName);
  final idx = text.indexOf('. ');
  if (idx < 0) {
    return (title: text, body: 'Fai a túa lección de hoxe en Galingo.');
  }
  return (
    title: text.substring(0, idx + 1),
    body: text.substring(idx + 2),
  );
}
