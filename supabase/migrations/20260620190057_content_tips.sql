-- ============================================================================
-- Jezici · Migración 057 · Capa "enseña, no solo evalúa" (content_tips + cuaderno)
-- Tips curados (autores como profesores → QA → adversarial → validador). Contenido
-- público (sin respuestas): RLS de lectura. Personalización por skill débil en RPC.
-- ============================================================================
begin;

create table if not exists content_tips (
  id         uuid primary key default gen_random_uuid(),
  course_id  uuid not null references courses(id) on delete cascade,
  unit_order int  not null,
  cefr_level text not null,
  skill      text not null,
  type       text not null,  -- tip_idioma|nota_cultural|error_comun|pronunciacion|mnemotecnia
  title      text not null,
  body       text not null,
  example    text,
  created_at timestamptz not null default now()
);
create index if not exists content_tips_unit_idx on content_tips (course_id, unit_order, skill);
alter table content_tips enable row level security;
do $p$ begin
  create policy content_tips_read on content_tips for select to anon, authenticated using (true);
exception when duplicate_object then null; end $p$;
grant select on content_tips to anon, authenticated;

-- Cuaderno: tips vistos por el usuario.
create table if not exists user_tip_progress (
  user_id    uuid not null references auth.users(id) on delete cascade,
  tip_id     uuid not null references content_tips(id) on delete cascade,
  seen_at    timestamptz not null default now(),
  times_seen int not null default 1,
  primary key (user_id, tip_id)
);
alter table user_tip_progress enable row level security;
do $p$ begin
  create policy utp_self on user_tip_progress for all
    using (user_id = auth.uid()) with check (user_id = auth.uid());
exception when duplicate_object then null; end $p$;

-- Re-siembra idempotente: limpia y reinserta los tips del curso.
delete from content_tips where course_id = '20000000-0000-0000-0000-000000000001';
insert into content_tips (course_id, unit_order, cefr_level, skill, type, title, body, example) values
 ('20000000-0000-0000-0000-000000000001',1,'A1','writing','tip_idioma',$t$A / An según el sonido$t$,$t$Usa 'a' antes de sonido de consonante y 'an' antes de sonido de vocal. Lo que manda es el SONIDO, no la letra escrita.$t$,$t$a book (un libro) · an apple (una manzana) · an hour (una hora; la 'h' es muda, suena vocal)$t$),
 ('20000000-0000-0000-0000-000000000001',1,'A1','speaking','error_comun',$t$Tu edad: be, no have$t$,$t$En español dices 'tengo 20 años', pero en inglés se usa el verbo 'to be'. Decir 'I have 20 years' es un error muy típico.$t$,$t$I am 20 (years old). = Tengo 20 años. (NO: I have 20 years)$t$),
 ('20000000-0000-0000-0000-000000000001',1,'A1','writing','mnemotecnia',$t$El sujeto nunca falta$t$,$t$En inglés siempre hay que poner el sujeto, aunque en español se omita. Recuerda: cada oración necesita su 'yo, tú, él...' delante.$t$,$t$Es profesor. → He is a teacher. (NO: Is a teacher)$t$),
 ('20000000-0000-0000-0000-000000000001',2,'A1','writing','tip_idioma',$t$El posesivo con 's$t$,$t$Para decir de quién es algo, añade 's al dueño y ponlo delante de la cosa, al revés que en español. Con personas no se usa 'of'.$t$,$t$el coche de Ana → Ana's car · la madre de mi amigo → my friend's mother$t$),
 ('20000000-0000-0000-0000-000000000001',2,'A1','writing','error_comun',$t$His / Her no cambian con la cosa$t$,$t$El posesivo concuerda con el dueño, no con el objeto. 'Her' siempre es 'de ella' y 'his' siempre es 'de él', sea singular o plural lo que poseen.$t$,$t$her brothers = sus hermanos (de ella) · his sister = su hermana (de él)$t$),
 ('20000000-0000-0000-0000-000000000001',2,'A1','listening','pronunciacion',$t$El plural suena de 3 formas$t$,$t$La -s del plural se pronuncia /s/, /z/ o /ɪz/ según el sonido anterior. Tras s, z, ch, sh, ge suena /ɪz/ y añade una sílaba.$t$,$t$cats /s/ · dogs /z/ · houses /ˈhaʊzɪz/ (casas)$t$),
 ('20000000-0000-0000-0000-000000000001',3,'A1','writing','error_comun',$t$La -s de he/she/it$t$,$t$En presente simple, con he, she e it el verbo lleva -s al final. Es el error más frecuente: olvidarla en la tercera persona.$t$,$t$She works in a bank. = Ella trabaja en un banco. (NO: She work)$t$),
 ('20000000-0000-0000-0000-000000000001',3,'A1','speaking','tip_idioma',$t$Negar con don't / doesn't$t$,$t$Para negar en presente usa 'don't' (I/you/we/they) o 'doesn't' (he/she/it). Ojo: con 'doesn't' el verbo principal pierde la -s.$t$,$t$He doesn't like coffee. = No le gusta el café. (NO: doesn't likes)$t$),
 ('20000000-0000-0000-0000-000000000001',3,'A1','writing','tip_idioma',$t$Adverbios de frecuencia: dónde van$t$,$t$Palabras como always, usually o never van antes del verbo principal, pero después de 'to be'. Indican cada cuánto haces algo.$t$,$t$I always have breakfast. = Siempre desayuno. · She is never late. = Nunca llega tarde.$t$),
 ('20000000-0000-0000-0000-000000000001',4,'A1','writing','tip_idioma',$t$Some en afirmativo, any en preguntas$t$,$t$Usa 'some' en frases afirmativas y 'any' en negativas y preguntas. Indican una cantidad indefinida ('algo de' / 'algún').$t$,$t$I have some bread. = Tengo (algo de) pan. · Do you have any milk? = ¿Tienes leche?$t$),
 ('20000000-0000-0000-0000-000000000001',4,'A1','writing','error_comun',$t$Contables vs incontables$t$,$t$Algunas comidas no se cuentan en inglés y no llevan plural ni 'a': bread, water, rice. Para medirlas usa 'a piece of', 'a glass of'.$t$,$t$a glass of water = un vaso de agua (NO: a water · waters)$t$),
 ('20000000-0000-0000-0000-000000000001',4,'A1','listening','pronunciacion',$t$El sonido 'th' de 'three'$t$,$t$La 'th' de 'three' no existe en español. Pon la lengua entre los dientes y sopla suave; no la cambies por 't' ni por 's'.$t$,$t$three /θriː/ = tres · thanks = gracias$t$),
 ('20000000-0000-0000-0000-000000000001',5,'A1','writing','tip_idioma',$t$In, on, at de lugar$t$,$t$Usa 'in' para espacios cerrados o áreas, 'on' para superficies y 'at' para puntos concretos. Es clave para ubicar cosas.$t$,$t$in the kitchen (en la cocina) · on the table (sobre la mesa) · at the door (en la puerta)$t$),
 ('20000000-0000-0000-0000-000000000001',5,'A1','speaking','tip_idioma',$t$Hay = There is / There are$t$,$t$Para decir que algo existe usa 'there is' (singular) o 'there are' (plural). No lo traduzcas con 'have'.$t$,$t$There is a park near my house. = Hay un parque cerca de mi casa. · There are two banks. = Hay dos bancos.$t$),
 ('20000000-0000-0000-0000-000000000001',5,'A1','reading','nota_cultural',$t$Planta baja: ground floor$t$,$t$En inglés británico la planta baja es 'ground floor' y el 'first floor' es el primer piso de arriba. En inglés americano 'first floor' es la planta baja.$t$,$t$the ground floor (UK) = la planta baja$t$),
 ('20000000-0000-0000-0000-000000000001',6,'A1','writing','tip_idioma',$t$Can: misma forma para todos$t$,$t$'Can' (poder/saber hacer) no cambia y va seguido del verbo en infinitivo sin 'to'. Nunca lleva -s, ni siquiera con he/she.$t$,$t$She can swim. = Ella sabe nadar. (NO: She can to swim · She cans)$t$),
 ('20000000-0000-0000-0000-000000000001',6,'A1','writing','error_comun',$t$El adjetivo va delante$t$,$t$En inglés el adjetivo se coloca antes del sustantivo y no cambia en plural, al revés que en español, donde suele ir detrás.$t$,$t$a red car = un coche rojo · two big houses = dos casas grandes (NO: cars red · bigs)$t$),
 ('20000000-0000-0000-0000-000000000001',6,'A1','speaking','mnemotecnia',$t$Gusta + -ing para hobbies$t$,$t$Para hablar de pasatiempos, tras 'like', 'love' o 'enjoy' el segundo verbo suele acabar en -ing. Piensa: 'me gusta EL nadar'.$t$,$t$I like reading. = Me gusta leer. · She loves dancing. = A ella le encanta bailar.$t$),
 ('20000000-0000-0000-0000-000000000001',7,'A2','speaking','pronunciacion',$t$La -ed tiene tres sonidos$t$,$t$En el pasado regular, la terminación -ed se pronuncia de tres formas según el sonido anterior. Suena /t/ tras sonido sordo, /d/ tras sonido sonoro, y solo añade una sílaba (/id/) cuando el verbo termina en t o d.$t$,$t$worked /workt/ · played /pleid/ · wanted /wantid/ (con sílaba extra)$t$),
 ('20000000-0000-0000-0000-000000000001',7,'A2','writing','error_comun',$t$En negativo, sin pasado doble$t$,$t$Un error muy típico es decir 'I didn't went'. Con didn't el verbo vuelve a su forma base, porque el pasado ya lo marca 'did'.$t$,$t$I didn't go yesterday (no 'didn't went') = No fui ayer$t$),
 ('20000000-0000-0000-0000-000000000001',7,'A2','reading','mnemotecnia',$t$Irregulares en grupos$t$,$t$Memoriza los verbos irregulares por patrones de sonido parecido, no de uno en uno. Así se te quedan más fácil.$t$,$t$sing-sang, ring-rang, swim-swam · think-thought, buy-bought, bring-brought$t$),
 ('20000000-0000-0000-0000-000000000001',8,'A2','writing','tip_idioma',$t$Will vs going to$t$,$t$Usa 'going to' para planes que ya tenías decididos, y 'will' para decisiones del momento o predicciones espontáneas. No siempre son intercambiables.$t$,$t$I'm going to study tonight (plan) · I'll help you! (decisión ahora) = Voy a estudiar / Te ayudaré$t$),
 ('20000000-0000-0000-0000-000000000001',8,'A2','speaking','error_comun',$t$No olvides el 'to'$t$,$t$Muchos hispanohablantes dicen 'I going study'. El futuro con going to siempre lleva: be + going + to + verbo en base.$t$,$t$I'm going to travel (no 'I going travel') = Voy a viajar$t$),
 ('20000000-0000-0000-0000-000000000001',8,'A2','listening','pronunciacion',$t$'Going to' suena 'gonna'$t$,$t$En el inglés hablado informal, 'going to' se reduce a 'gonna' delante de un verbo. Reconocerlo te ayuda mucho a entender conversaciones reales.$t$,$t$I'm gonna call you = I'm going to call you = Te voy a llamar$t$),
 ('20000000-0000-0000-0000-000000000001',9,'A2','speaking','tip_idioma',$t$Pedir direcciones con cortesía$t$,$t$Para preguntar cómo llegar, empieza con 'Excuse me'. Suena mucho más natural y educado que un 'where is' directo.$t$,$t$Excuse me, how do I get to the station? = Perdone, ¿cómo llego a la estación?$t$),
 ('20000000-0000-0000-0000-000000000001',9,'A2','reading','nota_cultural',$t$Las plantas: 'ground floor'$t$,$t$En inglés británico la planta baja es 'ground floor' y nuestro primer piso es 'first floor'. En EE. UU. la planta baja suele ser 'first floor', así que coincide con nuestra numeración.$t$,$t$Take the lift to the first floor (UK) = Sube a la primera planta (segunda altura)$t$),
 ('20000000-0000-0000-0000-000000000001',9,'A2','writing','error_comun',$t$'Go to' pero 'go home'$t$,$t$Decimos 'go to the airport', pero con home no se usa 'to'. Home funciona aquí como adverbio, por eso no lleva preposición.$t$,$t$I want to go home (no 'go to home') = Quiero ir a casa$t$),
 ('20000000-0000-0000-0000-000000000001',10,'A2','writing','tip_idioma',$t$Comparativos: cortos vs largos$t$,$t$Los adjetivos cortos añaden -er (cheaper), pero los largos usan 'more' delante. Nunca combines los dos a la vez.$t$,$t$cheaper, bigger · more expensive, more delicious (no 'more cheaper') = más barato / más caro$t$),
 ('20000000-0000-0000-0000-000000000001',10,'A2','speaking','error_comun',$t$'Than', no 'that'$t$,$t$Para comparar usamos 'than', no 'that'. Suenan parecido, pero confundirlos despista a quien te escucha.$t$,$t$This restaurant is better than that one = Este restaurante es mejor que aquel$t$),
 ('20000000-0000-0000-0000-000000000001',10,'A2','listening','nota_cultural',$t$La propina en EE. UU.$t$,$t$En EE. UU. dejar entre un 15% y un 20% de propina se da por hecho, no es opcional. A veces la cuenta ya sugiere el porcentaje.$t$,$t$Could we have the check, please? = ¿Nos trae la cuenta, por favor?$t$),
 ('20000000-0000-0000-0000-000000000001',11,'A2','writing','tip_idioma',$t$Ahora mismo: -ing$t$,$t$El presente continuo (be + verbo-ing) describe lo que pasa en este momento. Úsalo para acciones en curso, no para rutinas.$t$,$t$She is cooking right now = Ella está cocinando ahora mismo$t$),
 ('20000000-0000-0000-0000-000000000001',11,'A2','writing','error_comun',$t$Verbos de estado sin -ing$t$,$t$Verbos como like, want, know o need normalmente no van en -ing, aunque hables del momento presente. Es un fallo muy frecuente.$t$,$t$I want a coffee (no 'I am wanting') = Quiero un café$t$),
 ('20000000-0000-0000-0000-000000000001',11,'A2','speaking','pronunciacion',$t$El sonido -ing nasal$t$,$t$La terminación -ing acaba en un sonido nasal /ŋ/; no pronuncies una 'g' fuerte al final. Sale por la nariz, suave.$t$,$t$walking, talking, raining = suena /-iŋ/, sin 'g' dura$t$),
 ('20000000-0000-0000-0000-000000000001',12,'A2','speaking','tip_idioma',$t$'Should' para consejos$t$,$t$Usa 'should' para dar consejos y 'shouldn't' para lo que no conviene. Detrás siempre va el verbo en forma base, sin 'to'.$t$,$t$You should rest · You shouldn't drink coffee = Deberías descansar / No deberías tomar café$t$),
 ('20000000-0000-0000-0000-000000000001',12,'A2','writing','tip_idioma',$t$Ever / never con experiencias$t$,$t$El present perfect (have + participio) sirve para experiencias de vida sin decir cuándo. 'Ever' va en preguntas y 'never' significa ninguna vez.$t$,$t$Have you ever been to London? — No, I've never been = ¿Has estado alguna vez en Londres? — No, nunca$t$),
 ('20000000-0000-0000-0000-000000000001',12,'A2','reading','error_comun',$t$Tu edad: 'be', no 'have'$t$,$t$En español tenemos años, pero en inglés se usa el verbo 'be' para la edad. Decir 'I have 30 years' es un calco del español que conviene evitar.$t$,$t$I'm 30 (years old) (no 'I have 30 years') = Tengo 30 años$t$),
 ('20000000-0000-0000-0000-000000000001',13,'B1','writing','tip_idioma',$t$Just, already y yet$t$,$t$Con el present perfect, 'just' y 'already' van entre el auxiliar (have/has) y el participio. 'Yet' va al final de la frase y aparece sobre todo en preguntas y negaciones. Pista: 'yet' = algo que se espera pero todavia no ha pasado.$t$,$t$I've already eaten. / Have you finished yet? = Ya comi. / ¿Ya terminaste?$t$),
 ('20000000-0000-0000-0000-000000000001',13,'B1','writing','error_comun',$t$For y since no son lo mismo$t$,$t$Es un error muy comun. Usa 'for' con la duracion (cuanto tiempo: for three years) y 'since' con el punto de inicio (desde cuando: since 2021). Truco: 'desde hace' en español casi siempre es 'for'.$t$,$t$I've lived here for three years / since 2021 = Vivo aqui desde hace tres años / desde 2021$t$),
 ('20000000-0000-0000-0000-000000000001',13,'B1','speaking','mnemotecnia',$t$used to = antes solia$t$,$t$'Used to' describe habitos o estados del pasado que ya no son ciertos. Traducelo como 'antes' o 'solia' y veras que encaja. Ojo: en negativa y pregunta se pierde la -d: 'didn't use to', 'did you use to...?'.$t$,$t$I used to smoke = Antes fumaba / Solia fumar$t$),
 ('20000000-0000-0000-0000-000000000001',14,'B1','writing','tip_idioma',$t$If + presente, will + verbo$t$,$t$En el primer condicional, despues de 'if' NO uses 'will': el presente va en la parte del 'if' y el futuro (will) en la otra mitad. Es una regla muy fiable del ingles.$t$,$t$If it rains, I will stay home = Si llueve, me quedare en casa$t$),
 ('20000000-0000-0000-0000-000000000001',14,'B1','speaking','error_comun',$t$Will vs going to$t$,$t$Usa 'be going to' para planes ya decididos antes de hablar o para algo que ves venir por las pruebas. Usa 'will' para decisiones del momento, predicciones sin pruebas y promesas.$t$,$t$I'm going to study tonight (plan) / I'll help you! (decido ahora) = Voy a estudiar / ¡Te ayudo!$t$),
 ('20000000-0000-0000-0000-000000000001',14,'B1','reading','tip_idioma',$t$Llevo + tiempo = have been -ing$t$,$t$El present perfect continuous expresa una accion que empezo en el pasado y sigue ahora. Cuando en español dirias 'llevo trabajando...', en ingles suele ser 'I've been working...'.$t$,$t$I've been studying English for two years = Llevo dos años estudiando ingles$t$),
 ('20000000-0000-0000-0000-000000000001',15,'B1','speaking','tip_idioma',$t$So do I / Neither do I$t$,$t$Para coincidir, usa 'So...' tras una frase afirmativa y 'Neither...' tras una negativa, repitiendo el auxiliar e invirtiendo el orden (auxiliar + sujeto). El auxiliar debe concordar con el verbo original: con 'I love' usas 'do'; con 'I can' usarias 'can'.$t$,$t$I love coffee. — So do I. / I don't smoke. — Neither do I. = A mi tambien / A mi tampoco$t$),
 ('20000000-0000-0000-0000-000000000001',15,'B1','writing','error_comun',$t$Agree no lleva 'be'$t$,$t$'Agree' es un verbo que ya significa 'estar de acuerdo', asi que NO digas 'I am agree'. Lo correcto es 'I agree' o 'I don't agree'.$t$,$t$I agree with you (NO 'I am agree') = Estoy de acuerdo contigo$t$),
 ('20000000-0000-0000-0000-000000000001',15,'B1','reading','tip_idioma',$t$Verbos para dar opinion$t$,$t$Mas alla de 'I think', enriquece tus opiniones con 'In my opinion', 'I believe' o 'It seems to me'. Suenan mas naturales y variadas en una conversacion de nivel B1.$t$,$t$In my opinion, the film was too long = En mi opinion, la pelicula fue demasiado larga$t$),
 ('20000000-0000-0000-0000-000000000001',16,'B1','writing','tip_idioma',$t$While y when en el pasado$t$,$t$Usa el pasado continuo (was/were + -ing) para la accion larga de fondo y el pasado simple para la accion corta que la interrumpe. 'While' suele acompañar a la accion larga; 'when' a la corta.$t$,$t$I was cooking when the phone rang = Estaba cocinando cuando sono el telefono$t$),
 ('20000000-0000-0000-0000-000000000001',16,'B1','writing','error_comun',$t$Who para personas, which para cosas$t$,$t$En las oraciones de relativo, 'who' es para personas y 'which' para cosas; 'that' sirve para ambas en las especificativas. No uses 'which' para personas.$t$,$t$The man who called / The car which broke down = El hombre que llamo / El coche que se averio$t$),
 ('20000000-0000-0000-0000-000000000001',16,'B1','listening','pronunciacion',$t$La -ed tiene tres sonidos$t$,$t$La terminacion -ed del pasado suena de tres formas: /t/ tras sonido sordo (worked), /d/ tras sonido sonoro o vocal (played) y /ɪd/ solo tras los sonidos /t/ y /d/ (wanted). Entrenar el oido te ayuda a no perderte verbos al escuchar.$t$,$t$worked /t/, played /d/, wanted /ɪd/$t$),
 ('20000000-0000-0000-0000-000000000001',17,'B1','reading','tip_idioma',$t$Condicional 0 para verdades$t$,$t$El condicional cero (if + presente, presente) describe hechos siempre ciertos, no situaciones futuras concretas. Aqui 'if' equivale casi a 'cuando' o 'siempre que'.$t$,$t$If you heat ice, it melts = Si calientas el hielo, se derrite$t$),
 ('20000000-0000-0000-0000-000000000001',17,'B1','speaking','error_comun',$t$Must vs have to$t$,$t$'Must' suele expresar una obligacion que sientes tu mismo; 'have to' una regla externa. Cuidado con la negativa: 'mustn't' significa prohibido y 'don't have to' significa que no es necesario; no son lo mismo.$t$,$t$You mustn't park here (esta prohibido) / You don't have to come (no hace falta)$t$),
 ('20000000-0000-0000-0000-000000000001',17,'B1','writing','tip_idioma',$t$Should para consejos$t$,$t$Para sugerir o aconsejar sin imponer, usa 'should' / 'shouldn't' seguido del verbo en infinitivo sin 'to'. Es mas suave que 'must' y muy util al proponer soluciones.$t$,$t$You should see a doctor = Deberias ver a un medico$t$),
 ('20000000-0000-0000-0000-000000000001',18,'B1','writing','tip_idioma',$t$La pasiva: be + participio$t$,$t$La voz pasiva se forma con 'be' conjugado + participio pasado, y se usa cuando importa mas la accion que quien la hizo. El agente, si aparece, se introduce con 'by'.$t$,$t$The bridge was built in 1900 = El puente fue construido en 1900$t$),
 ('20000000-0000-0000-0000-000000000001',18,'B1','speaking','tip_idioma',$t$Segundo condicional: situaciones irreales$t$,$t$Para hablar de algo imaginario o improbable usa 'if + pasado simple, would + verbo'. Aunque el verbo va en pasado, te refieres al presente o a un futuro hipotetico.$t$,$t$If I won the lottery, I would travel = Si ganara la loteria, viajaria$t$),
 ('20000000-0000-0000-0000-000000000001',18,'B1','reading','mnemotecnia',$t$as ... as = tan ... como$t$,$t$Para comparar igualdad, encierra el adjetivo entre dos 'as': 'as + adjetivo + as'. Piensa en el sandwich 'tan...como' y nunca te faltara un 'as'.$t$,$t$She is as tall as her brother = Es tan alta como su hermano$t$),
 ('20000000-0000-0000-0000-000000000001',19,'B2','writing','tip_idioma',$t$Llevo + tiempo = present perfect continuous$t$,$t$Para decir 'llevo X tiempo haciendo algo' no se usa el presente simple, sino have/has been + verbo-ing. El foco esta en una accion que empezo en el pasado y sigue ahora. Fijate que en ingles necesitas 'for' o 'since' donde el espanol usa 'llevo'.$t$,$t$I have been working here for five years. (Llevo cinco anos trabajando aqui.)$t$),
 ('20000000-0000-0000-0000-000000000001',19,'B2','writing','error_comun',$t$For y since no son lo mismo$t$,$t$Usa 'for' con la duracion (cuanto tiempo) y 'since' con el punto de inicio (desde cuando). Ojo: el espanol 'desde hace dos horas' se dice 'for two hours', no 'since two hours'.$t$,$t$for two hours / since 2018 (durante dos horas / desde 2018)$t$),
 ('20000000-0000-0000-0000-000000000001',19,'B2','reading','tip_idioma',$t$Past perfect: lo anterior a lo pasado$t$,$t$El past perfect (had + participio) marca una accion que ocurrio ANTES de otro momento pasado. Te ayuda a ordenar los hechos cuando narras y dos cosas pasaron en momentos distintos.$t$,$t$When I arrived, the meeting had already started. (Cuando llegue, la reunion ya habia empezado.)$t$),
 ('20000000-0000-0000-0000-000000000001',20,'B2','writing','tip_idioma',$t$El tiempo retrocede un paso$t$,$t$En estilo indirecto, cuando el verbo introductor (said, told) esta en pasado, el verbo de la frase suele 'retroceder' un tiempo: present pasa a past, y past pasa a past perfect. Es el llamado backshift.$t$,$t$"I'm tired" -> She said she was tired. (Dijo que estaba cansada.)$t$),
 ('20000000-0000-0000-0000-000000000001',20,'B2','speaking','error_comun',$t$Say vs tell: ojo con el objeto$t$,$t$'Tell' lleva directamente a la persona (tell me, tell her); 'say' no lleva persona directa, y si la mencionas necesitas 'to' (say to me). Decir 'he said me' es un calco de 'me dijo' y es incorrecto.$t$,$t$He told me / He said to me (no: he said me)$t$),
 ('20000000-0000-0000-0000-000000000001',20,'B2','reading','tip_idioma',$t$Preguntas indirectas: orden de afirmacion$t$,$t$Al pasar una pregunta a estilo indirecto, se usa el orden de afirmacion: sujeto + verbo, sin el auxiliar 'do' y sin signo de interrogacion. Para preguntas de si/no usa 'if' o 'whether'.$t$,$t$"Where do you live?" -> She asked where I lived. (Me pregunto donde vivia.)$t$),
 ('20000000-0000-0000-0000-000000000001',21,'B2','writing','tip_idioma',$t$Pasiva: be + participio$t$,$t$La voz pasiva se forma con el verbo 'be' (en el tiempo que toque) + participio pasado. Se usa cuando importa mas la accion o el resultado que quien la hizo; es muy comun en textos formales.$t$,$t$The report was written last week. (El informe se escribio la semana pasada.)$t$),
 ('20000000-0000-0000-0000-000000000001',21,'B2','speaking','error_comun',$t$Have something done: que te lo hagan$t$,$t$'Have/get something done' significa que otra persona hace algo por ti, no que lo haces tu mismo. Fijate en el orden: objeto + participio. Muchos dicen 'I cut my hair' cuando en realidad fueron a la peluqueria.$t$,$t$I had my hair cut. (Me corte el pelo = me lo cortaron.)$t$),
 ('20000000-0000-0000-0000-000000000001',21,'B2','reading','tip_idioma',$t$El agente con 'by'$t$,$t$En la pasiva, si quieres decir quien hizo la accion, lo introduces con 'by'. A menudo se omite porque no importa o no se sabe quien fue.$t$,$t$The bridge was designed by a famous architect. (El puente fue disenado por un arquitecto famoso.)$t$),
 ('20000000-0000-0000-0000-000000000001',22,'B2','writing','tip_idioma',$t$Tercer condicional: el pasado imposible$t$,$t$El tercer condicional habla de un pasado que no ocurrio y su consecuencia imaginaria: If + had + participio, would have + participio. Sirve para arrepentimientos e hipotesis sobre lo que ya paso.$t$,$t$If I had studied, I would have passed. (Si hubiera estudiado, habria aprobado.)$t$),
 ('20000000-0000-0000-0000-000000000001',22,'B2','writing','error_comun',$t$Nunca 'would' en el if$t$,$t$En los condicionales no se pone 'would' en la clausula con 'if'. 'If I would have' es un error muy comun: la condicion lleva 'had + participio' y 'would have' va en la otra parte.$t$,$t$If I had known (no: if I would have known)$t$),
 ('20000000-0000-0000-0000-000000000001',22,'B2','reading','tip_idioma',$t$Condicionales mixtos: cruzar tiempos$t$,$t$Un condicional mixto cruza dos tiempos: lo mas tipico es una condicion pasada (If + had + participio) con una consecuencia en el presente (would + infinitivo). Sirve para imaginar como seria tu presente si el pasado hubiera sido distinto.$t$,$t$If I had saved money, I would be rich now. (Si hubiera ahorrado, ahora seria rico.)$t$),
 ('20000000-0000-0000-0000-000000000001',23,'B2','reading','tip_idioma',$t$Defining: sin comas, dan info clave$t$,$t$Las relativas especificativas (defining) identifican de cual hablas y no llevan comas. Si las quitas, la frase pierde sentido o cambia. Aqui puedes usar 'that' en lugar de who/which.$t$,$t$The man who called you is my boss. (El hombre que te llamo es mi jefe.)$t$),
 ('20000000-0000-0000-0000-000000000001',23,'B2','writing','tip_idioma',$t$Non-defining: van entre comas$t$,$t$Las relativas explicativas (non-defining) anaden informacion extra y se separan con comas; la frase tendria sentido sin ellas. Aqui no se puede usar 'that', solo who o which.$t$,$t$My boss, who is from Canada, called you. (Mi jefe, que es de Canada, te llamo.)$t$),
 ('20000000-0000-0000-0000-000000000001',23,'B2','writing','error_comun',$t$'What' no es pronombre relativo$t$,$t$Los hispanohablantes usan 'what' por el 'que' relativo, pero es incorrecto. Para personas usa who/that y para cosas which/that. 'What' significa 'lo que', no el 'que' que une dos frases.$t$,$t$The car that I bought (no: the car what I bought)$t$),
 ('20000000-0000-0000-0000-000000000001',24,'B2','speaking','tip_idioma',$t$Must / might / can't have para deducir$t$,$t$Para deducir sobre el pasado usa modal + have + participio: 'must have' (seguro que si), 'might/may have' (quiza), 'can't have' (imposible que). Expresan tu grado de certeza sobre algo que ya paso.$t$,$t$He must have left early. (Seguro que se fue temprano.)$t$),
 ('20000000-0000-0000-0000-000000000001',24,'B2','listening','error_comun',$t$En el habla suena 'must've'$t$,$t$Al escuchar, 'must have' se contrae a 'must've', que suena casi como 'must of'. No te dejes enganar: nunca se escribe 'must of'; es siempre 'have' o el contraido 've.$t$,$t$She might've forgotten. (Quiza se le olvido.)$t$),
 ('20000000-0000-0000-0000-000000000001',24,'B2','reading','tip_idioma',$t$Can't have vs mustn't have$t$,$t$Para decir 'es imposible que pasara' usa 'can't have' o 'couldn't have', no 'mustn't have'. 'Mustn't' es prohibicion (no debes), no deduccion. La deduccion negativa sobre el pasado es siempre can't/couldn't have.$t$,$t$She can't have seen us; she was asleep. (Es imposible que nos viera; estaba dormida.)$t$);

-- Tip post-lección: resuelve la unidad desde el lesson_id, elige un tip de esa
-- unidad PERSONALIZADO a la skill más débil del usuario, no visto recientemente;
-- lo marca como visto (cuaderno) y lo devuelve.
drop function if exists get_lesson_tip(int);
create or replace function get_lesson_tip(p_lesson_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid; v_unit int; v_weak text; v_tip content_tips%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  select u.order_index into v_unit from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_unit is null then return null; end if;
  select s into v_weak from unnest(array['reading','listening','writing','speaking']) s
    order by jz_reinforce_score(uid, v_course, s::skill) desc,
             array_position(array['reading','listening','writing','speaking'], s) limit 1;
  select * into v_tip from content_tips t
   where t.course_id = v_course and t.unit_order = v_unit
   order by (t.skill = v_weak) desc,
            (not exists (select 1 from user_tip_progress up where up.user_id = uid and up.tip_id = t.id)) desc,
            random()
   limit 1;
  if v_tip.id is null then return null; end if;
  insert into user_tip_progress(user_id, tip_id) values (uid, v_tip.id)
    on conflict (user_id, tip_id) do update set seen_at = now(), times_seen = user_tip_progress.times_seen + 1;
  return jsonb_build_object('id', v_tip.id, 'type', v_tip.type, 'skill', v_tip.skill,
    'cefr_level', v_tip.cefr_level, 'title', v_tip.title, 'body', v_tip.body,
    'example', v_tip.example, 'weak_skill', v_weak);
end $fn$;
grant execute on function get_lesson_tip(uuid) to authenticated;

-- Cuaderno: tips vistos del usuario (navegable).
create or replace function get_notebook()
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', t.id, 'type', t.type, 'skill', t.skill,
      'cefr_level', t.cefr_level, 'unit_order', t.unit_order, 'title', t.title, 'body', t.body,
      'example', t.example, 'seen_at', up.seen_at) order by up.seen_at desc)
    from user_tip_progress up join content_tips t on t.id = up.tip_id where up.user_id = uid), '[]'::jsonb);
end $fn$;
grant execute on function get_notebook() to authenticated;

commit;
