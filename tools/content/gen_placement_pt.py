# -*- coding: utf-8 -*-
"""Genera el banco de PLACEMENT es->pt (curso ...0002), A1/A2/B1, reading+writing.
Espeja el banco es->en (mig 075) adaptado a portugués de Brasil. Calificación
server-side (placement_next / jz_grade). Guardas anti-colisión:
  - reading = multiple_choice (selección exacta; jz_near_match NO aplica).
  - writing = cloze (jz_near_match SÍ aplica): NINGÚN distractor a distancia-1
    (inserción/borrado) del correcto, y ninguno igual tras jz_normalize.
Emite la migración 20260702120093_placement_bank_pt.sql (uuid5 estable, idempotente).
"""
import uuid, json, io, os, sys

PT = '20000000-0000-0000-0000-000000000002'
NS = uuid.UUID('20000000-0000-0000-0000-0000000000aa')
DIFF = {'A1': 0.12, 'A2': 0.32, 'B1': 0.52, 'B2': 0.68}

# (skill, type, prompt, options, answer). type: 'w'=cloze(writing), 'r'=mc(reading).
BANK = {
'A1': [
 ('w', 'Eu ___ estudante.', ['sou', 'é', 'são'], 'sou'),
 ('w', 'Você ___ brasileiro?', ['é', 'sou', 'são'], 'é'),
 ('w', 'Nós ___ amigos.', ['somos', 'sou', 'é'], 'somos'),
 ('w', 'Eu ___ vinte anos.', ['tenho', 'sou', 'faço'], 'tenho'),
 ('w', 'Ela ___ um gato.', ['tem', 'tenho', 'ter'], 'tem'),
 ('w', 'Eu gosto ___ café.', ['de', 'em', 'para'], 'de'),
 ('w', 'Nós ___ português.', ['falamos', 'falo', 'falar'], 'falamos'),
 ('r', '"Obrigado" significa:', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '"Bom dia" costuma-se dizer:', ['de manhã', 'à noite', 'para se despedir'], 'de manhã'),
 ('r', 'Qual destas palavras é uma comida?', ['pão', 'mesa', 'azul'], 'pão'),
 ('r', '"A irmã da minha mãe" é a sua:', ['tia', 'tio', 'prima'], 'tia'),
 ('r', 'Que cor é o céu num dia claro?', ['azul', 'vermelho', 'verde'], 'azul'),
 ('r', 'Escolha a frase correta:', ['Eu tenho um cachorro.', 'Eu tem um cachorro.', 'Eu ter um cachorro.'], 'Eu tenho um cachorro.'),
 ('r', '"Onde você mora?" pergunta sobre um:', ['lugar', 'idade', 'comida'], 'lugar'),
],
'A2': [
 ('w', 'Ontem eu ___ ao cinema.', ['fui', 'vou', 'vá'], 'fui'),
 ('w', 'Amanhã ela ___ viajar.', ['vai', 'foi', 'vá'], 'vai'),
 ('w', 'Olha! As crianças ___ no jardim agora.', ['estão brincando', 'brincam', 'brincaram'], 'estão brincando'),
 ('w', 'Este livro é ___ interessante do que o outro.', ['mais', 'muito', 'tão'], 'mais'),
 ('w', 'Nós ___ a um filme ótimo ontem.', ['assistimos', 'assistir', 'assistindo'], 'assistimos'),
 ('w', 'Eu não fui à festa ___ estava doente.', ['porque', 'mas', 'e'], 'porque'),
 ('w', 'Ela ___ as chaves em casa na semana passada.', ['esqueceu', 'esquecer', 'esquecia'], 'esqueceu'),
 ('r', 'Leia: "Vou visitar minha avó no próximo fim de semana." A frase fala de:', ['um plano para o futuro', 'algo que acontece agora', 'algo de ontem'], 'um plano para o futuro'),
 ('r', 'Leia: "O Tom nunca toma café de manhã." Com que frequência o Tom toma café?', ['Nunca', 'Todo dia', 'Às vezes'], 'Nunca'),
 ('r', 'Escolha a frase correta:', ['Ontem eu comi pizza.', 'Ontem eu como pizza.', 'Ontem eu comer pizza.'], 'Ontem eu comi pizza.'),
 ('r', '"Estou com fome" significa:', ['Tengo hambre', 'Tengo sueño', 'Tengo frío'], 'Tengo hambre'),
 ('r', 'Qual destas é um meio de transporte?', ['ônibus', 'garfo', 'camisa'], 'ônibus'),
 ('r', 'Na frase "Ontem eu estudei muito", a ação aconteceu:', ['no passado', 'no futuro', 'agora'], 'no passado'),
 ('r', 'Escolha o comparativo correto:', ['mais rápido do que', 'mais rápido de', 'mais rápido que de'], 'mais rápido do que'),
],
'B1': [
 ('w', 'Quando eu era criança, eu ___ muito futebol.', ['jogava', 'joguei', 'jogo'], 'jogava'),
 ('w', 'Espero que você ___ bem.', ['esteja', 'está', 'estar'], 'esteja'),
 ('w', 'O livro ___ eu comprei ontem é ótimo.', ['que', 'onde', 'cujo'], 'que'),
 ('w', 'A cidade ___ eu moro é grande.', ['onde', 'que', 'quem'], 'onde'),
 ('w', 'Ontem, enquanto eu ___, o telefone tocou.', ['dormia', 'dormir', 'durmo'], 'dormia'),
 ('w', 'É importante que ele ___ cedo amanhã.', ['chegue', 'chega', 'chegar'], 'chegue'),
 ('w', 'O bolo ___ feito pela minha mãe na festa.', ['foi', 'é', 'está'], 'foi'),
 ('r', 'Leia: "O relatório será entregue amanhã." A frase está na:', ['voz passiva', 'voz ativa', 'forma de pergunta'], 'voz passiva'),
 ('r', 'Leia: "Ele disse que estava cansado." Isto é um exemplo de:', ['discurso indireto', 'discurso direto', 'uma pergunta'], 'discurso indireto'),
 ('r', '"Eu gostaria de um café, por favor" é uma forma:', ['educada', 'informal', 'de ordem'], 'educada'),
 ('r', 'Escolha a frase correta:', ['Talvez ele venha amanhã.', 'Talvez ele vem amanhã.', 'Talvez ele vir amanhã.'], 'Talvez ele venha amanhã.'),
 ('r', 'Leia: "Quando cheguei, ela já tinha saído." O que aconteceu primeiro?', ['ela saiu', 'eu cheguei', 'ao mesmo tempo'], 'ela saiu'),
 ('r', 'Leia: "Se eu tivesse dinheiro, viajaria." Isto expressa:', ['uma situação hipotética', 'um fato do passado', 'uma certeza'], 'uma situação hipotética'),
 ('r', 'Escolha a frase mais formal:', ['Poderia me informar o horário?', 'Me fala o horário.', 'Que horas são?'], 'Poderia me informar o horário?'),
],
}

# ── B2 (el curso pt ya llega a B2, mig 121). Autorado nativo pt-BR + guard near_match. ──
BANK['B2'] = [
 ('w', 'Quando eu ___ tempo, farei uma longa viagem pelo Nordeste.', ['tiver', 'tenho', 'terei'], 'tiver'),
 ('w', 'Se você ___ falar com o gerente, ligue depois das duas da tarde.', ['quiser', 'quer', 'quererá'], 'quiser'),
 ('w', 'Se eu ___ mais dinheiro, compraria aquele apartamento perto da praia.', ['tivesse', 'tenho', 'terei'], 'tivesse'),
 ('w', 'Embora ele ___ cansado, terminou o relatório antes da meia-noite.', ['estivesse', 'estava', 'estará'], 'estivesse'),
 ('w', 'Os documentos já ___ assinados pelo diretor na semana passada.', ['foram', 'estavam', 'seriam'], 'foram'),
 ('w', 'Ela disse que ___ ao médico no dia seguinte, mas acabou desistindo.', ['iria', 'vai', 'foi'], 'iria'),
 ('w', 'Caso a reunião ___ cancelada, avise a equipe por e-mail imediatamente.', ['seja', 'foi', 'era'], 'seja'),
 ('r', 'Escolha a frase correta:', ['Quando eu chegar, te aviso.', 'Quando eu chegue, te aviso.', 'Quando eu chegarei, te aviso.'], 'Quando eu chegar, te aviso.'),
 ('r', 'Escolha a frase correta (período hipotético):', ['Se eu tivesse estudado, teria passado.', 'Se eu tinha estudado, teria passado.', 'Se eu teria estudado, tinha passado.'], 'Se eu tivesse estudado, teria passado.'),
 ('r', 'Complete corretamente: "É bom que todos ___ presentes na cerimônia."', ['estejam', 'estão', 'estarão'], 'estejam'),
 ('r', 'Escolha a frase na voz passiva:', ['A ponte foi construída em 1920.', 'A ponte construiu em 1920.', 'A ponte tem construído em 1920.'], 'A ponte foi construída em 1920.'),
 ('r', 'Leia: "Ela perguntou se eu estava bem." O discurso direto correspondente é:', ['"Você está bem?"', '"Você estava bem?"', '"Eu estarei bem?"'], '"Você está bem?"'),
 ('r', 'Escolha a regência verbal correta:', ['Assisti ao jogo ontem.', 'Assisti o jogo ontem.', 'Assisti no jogo ontem.'], 'Assisti ao jogo ontem.'),
 ('r', 'Escolha a frase correta:', ['A menos que chova, faremos o piquenique.', 'A menos que chove, faremos o piquenique.', 'A menos que choveria, faremos o piquenique.'], 'A menos que chova, faremos o piquenique.'),
]

def sql_str(s):
    return "'" + s.replace("'", "''") + "'"

def main():
    # Modo: sin arg = A1/A2/B1 → mig 093 (histórico, ya aplicado). 'b2' = solo B2 → mig
    # nueva (pt ya llega a B2 desde mig 121; ampliar el techo del placement a B2).
    mode = sys.argv[1] if len(sys.argv) > 1 else 'low'
    if mode == 'b2':
        EMIT = {'B2'}
        OUT_NAME = '20260705120123_placement_bank_pt_b2.sql'
        HEADER = [
            "-- 20260705120123_placement_bank_pt_b2.sql",
            "-- Amplía el banco de PLACEMENT es->pt a B2 (el curso pt ya llega a B2, mig 121).",
            "-- reading=MC (exacto), writing=cloze (sin distractores a distancia-1 del correcto).",
            "-- Tag 'placement'. Calificación server-side (placement_next/jz_grade, 42501).",
            "-- placement_next(pt) es course-scoped → sembrar el banco sube el techo a B2. uuid5 idempotente.",
            "",
        ]
    else:
        EMIT = {'A1', 'A2', 'B1'}
        OUT_NAME = '20260702120093_placement_bank_pt.sql'
        HEADER = [
            "-- 20260702120093_placement_bank_pt.sql",
            "-- Banco de PLACEMENT es->pt (curso ...0002), A1/A2/B1, reading+writing.",
            "-- Espeja mig 075 (es->en) adaptado a portugués de Brasil. Tag 'placement'",
            "-- (excluido de los pools de lección/examen). Calificación server-side",
            "-- (placement_next/jz_grade, correct_answer 42501). Guardas: reading=MC",
            "-- (exacto), writing=cloze sin distractores a distancia-1 del correcto.",
            "-- Idempotente (uuid5 estable + on conflict do nothing).",
            "",
        ]
    lines = list(HEADER)
    rows = []
    n = 0
    for lvl, items in BANK.items():
        if lvl not in EMIT:
            continue
        for i, (kind, prompt, options, answer) in enumerate(items):
            assert answer in options, f"answer not in options: {answer} {options}"
            skill = 'writing' if kind == 'w' else 'reading'
            ctype = 'cloze' if kind == 'w' else 'multiple_choice'
            iid = str(uuid.uuid5(NS, f"pt-plc-{lvl}-{skill}-{i}"))
            if kind == 'w':
                payload = {'text': prompt, 'options': options}
            else:
                payload = {'options': options}
            ca = {'value': answer}
            tags = ['placement', lvl.lower(), skill, 'use_of_english']
            tags_sql = 'ARRAY[' + ', '.join(sql_str(t) for t in tags) + ']'
            rows.append(
                f"  ('{iid}'::uuid, '{PT}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, "
                f"'{ctype}'::content_item_type, {sql_str(prompt)}, "
                f"{sql_str(json.dumps(payload, ensure_ascii=False))}::jsonb, "
                f"{sql_str(json.dumps(ca, ensure_ascii=False))}::jsonb, {DIFF[lvl]}, {tags_sql})"
            )
            n += 1
    lines.append("insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values")
    lines.append(",\n".join(rows))
    lines.append("on conflict (id) do nothing;")
    lines.append("")
    out = os.path.join(os.path.dirname(__file__), '..', '..', 'supabase', 'migrations', OUT_NAME)
    with io.open(out, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))
    print(f"escrito: {out} ({n} items)")

if __name__ == '__main__':
    main()
