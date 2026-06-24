-- ============================================================================
-- Jezici · Migración 069 · Tips RELEVANTES al tema de la lección + anti-repetición
-- ----------------------------------------------------------------------------
-- BUG (feedback usuario): en una lección de "de dónde eres" (países) salía el tip
-- "Tu edad: be, no have" (EDAD), y los primeros módulos repetían el mismo tip.
-- CAUSA: get_lesson_tip filtraba por unit_order, pero los tips están mal alineados
-- con dónde vive el concepto en el contenido (el tip de edad estaba en unit 1, pero
-- el contenido de 'edad' está en unit 2), y el desempate era random.
-- FIX: nueva columna content_tips.topic = el concepto que enseña el tip (alineado al
-- vocabulario de tags de content_items). get_lesson_tip ahora calcula los conceptos
-- REALES de la lección (tags de sus content_items) y un tip CON topic solo aplica si
-- calza con un concepto de la lección (course-wide); los tips SIN topic (generales)
-- sirven a su unidad. Conserva la personalización por skill flojo y refuerza la
-- anti-repetición (no visto > menos reciente > determinista).
-- ============================================================================
begin;

alter table content_tips add column if not exists topic text;
create index if not exists content_tips_topic_idx on content_tips (course_id, topic);

update content_tips set topic = $p$edad$p$ where id = '9bd5db3b-9850-47a1-9ef3-cd2a11ac7e9c';
update content_tips set topic = $p$numeros$p$ where id = '5844060d-05d7-4237-aefb-98784788f2ce';
update content_tips set topic = $p$have_posesivos$p$ where id = '07f9d975-fda5-493c-97a7-c177064dc275';
update content_tips set topic = $p$have_posesivos$p$ where id = '15076535-30d7-47cd-95c0-1b942cf93b59';
update content_tips set topic = $p$he_she$p$ where id = 'a2a7a40b-2254-4820-b839-d9007aaa5833';
update content_tips set topic = $p$he_she$p$ where id = '874073e0-31c9-46f6-9c3b-549dd7e886be';
update content_tips set topic = $p$rutina$p$ where id = '9bbb6d9f-2f30-42f9-b5c8-1debba867339';
update content_tips set topic = $p$comida$p$ where id = 'bc95cb4c-e461-49e5-aa34-d1231a1d5508';
update content_tips set topic = $p$comida$p$ where id = 'b74640c5-8a66-497f-b86c-1111b1c32e11';
update content_tips set topic = $p$lugares$p$ where id = '44fc80c8-28f4-4bed-bca9-8db0c2a5b9b3';
update content_tips set topic = $p$donde$p$ where id = '4089f6fb-9842-471d-9d00-23319a554616';
update content_tips set topic = $p$donde$p$ where id = 'b1672ed5-e215-4633-a14b-192fe52c2998';
update content_tips set topic = $p$want_like$p$ where id = '0811d1df-0fb2-4c9d-b2f6-9a05c8ed4ccb';
update content_tips set topic = $p$appearance$p$ where id = '924da8ae-922c-4d09-b2ff-4302d8aa154e';
update content_tips set topic = $p$irregular_past$p$ where id = '494e04b3-4ed6-49bc-9f1b-b83d5660e24d';
update content_tips set topic = $p$regular_past$p$ where id = 'b04dbf48-3210-4da1-98d3-52cb7590b049';
update content_tips set topic = $p$past_questions$p$ where id = '6120c383-9955-4385-a0a2-41ced270298c';
update content_tips set topic = $p$going_to$p$ where id = 'f69d1a8c-4072-49fc-96df-25a757e63ffd';
update content_tips set topic = $p$going_to$p$ where id = '7b643da2-1b1c-4df4-8895-ed2657650c1b';
update content_tips set topic = $p$going_to$p$ where id = '6d6bf207-c657-4e82-9f70-86ca892c7bfd';
update content_tips set topic = $p$hotel_airport$p$ where id = '4c08dadf-474d-47e9-a060-5783c977b3d3';
update content_tips set topic = $p$directions$p$ where id = '473d6590-89ce-4e2b-9ded-1ccea4a7c301';
update content_tips set topic = $p$transport$p$ where id = '31bf2672-def4-4a6a-838c-8fe67544d618';
update content_tips set topic = $p$restaurant$p$ where id = 'd73d8bd2-726d-4784-a35a-444a946e1cd7';
update content_tips set topic = $p$comparatives$p$ where id = '56cd0487-c666-4624-9887-2f5980cf2bb6';
update content_tips set topic = $p$comparatives$p$ where id = '10de013a-2c17-4fac-a82e-124fefda5ef6';
update content_tips set topic = $p$present_continuous$p$ where id = 'a3c0e4a6-7c8d-4522-bafc-16482eef1f71';
update content_tips set topic = $p$present_continuous$p$ where id = 'c8b1333c-ea13-4217-acde-4cf13bb11264';
update content_tips set topic = $p$present_continuous$p$ where id = '760945dd-4320-4c57-b017-52581da5a1be';
update content_tips set topic = $p$edad$p$ where id = '6f6c2ff4-eebd-4cac-b78b-50d0ed34aab3';
update content_tips set topic = $p$should_advice$p$ where id = 'c31957e4-bbfa-489a-b38a-cc1d2ffa9d31';
update content_tips set topic = $p$present_perfect_intro$p$ where id = '9c8b1127-ed16-4bf2-80e2-7cae9e8c18e8';
update content_tips set topic = $p$habitos_del_pasado_con_used_to_y_contraste_pasado_simple_vs_present_perfect$p$ where id = '5694ec50-6ab0-477a-8a3d-060cbfdc571b';
update content_tips set topic = $p$acciones_recientes_y_resultados_present_perfect_con_just_already_y_yet$p$ where id = '08c8fa5c-9019-45e8-b6d2-e36a3fb1fb5c';
update content_tips set topic = $p$duracion_con_present_perfect_for_durante_y_since_desde$p$ where id = 'd3323762-6839-42ed-b4d7-fede418f526b';
update content_tips set topic = $p$educacion_y_present_perfect_continuous_introduccion$p$ where id = '4dd8cdc9-cfc8-498e-8d2e-5a376bc7e1f8';
update content_tips set topic = $p$be_going_to_vs_will_para_planes_y_carrera$p$ where id = 'fb4ad6ad-edca-4b8b-a002-0e7d0f1b60f8';
update content_tips set topic = $p$rutinas_y_responsabilidades_laborales_con_primer_condicional$p$ where id = 'fb5f0f5d-0880-4839-ac8d-05dd316bef7f';
update content_tips set topic = $p$expresar_opiniones_con_think_believe_y_in_my_opinion$p$ where id = '73141ca2-4946-41b9-a27c-2d1e2a0d370f';
update content_tips set topic = $p$acuerdo_con_so_do_i_y_so_am_i$p$ where id = 'b96b4e36-7951-4755-a71b-ff550f007ce0';
update content_tips set topic = $p$expresar_opiniones_con_think_believe_y_in_my_opinion$p$ where id = '7027d452-459c-4e5b-a112-a53f5cd0df0c';
update content_tips set topic = $p$regular_past$p$ where id = '6575f08d-6724-4f5f-8e4e-ebe2181ce904';
update content_tips set topic = $p$pasado_continuo_vs_pasado_simple_con_while_when$p$ where id = '468b6acf-85fe-4fec-9701-7a54bcbb9f24';
update content_tips set topic = $p$clausulas_relativas_con_who_which_that_para_describir$p$ where id = 'eb487add-8137-40e4-98ab-fbaabd59e033';
update content_tips set topic = $p$condicional_cero_normas_y_reacciones_automaticas_ante_problemas_en_casa_y_con_aparatos$p$ where id = 'e5ef91d2-5c61-457b-9520-0be228e5995d';
update content_tips set topic = $p$modales_must_have_to_mustn_t_can_t_obligacion_y_prohibicion_en_el_trabajo_y_los_servicios$p$ where id = '9238c8d0-ddbe-4435-83a8-e8c86efe3468';
update content_tips set topic = $p$modales_should_shouldn_t_y_frases_para_quejarse_pedir_reembolso_y_resolver_el_problema$p$ where id = 'be90d5a7-a8ea-47ae-a890-e8ef0086e536';
update content_tips set topic = $p$comparativos_avanzados_con_as_as_y_not_as_as_para_comparar_peliculas_programas_y_medios$p$ where id = '7ae1d559-4d36-4807-8f8c-c082d6ef17f5';
update content_tips set topic = $p$segundo_condicional_para_imaginar_suenos_y_situaciones_hipoteticas_if_i_had_i_would$p$ where id = '6433d34e-c213-4323-a425-8357201ca69a';
update content_tips set topic = $p$voz_pasiva_en_presente_hablar_de_como_se_crean_y_producen_las_cosas_is_made_are_produced$p$ where id = 'b29546a7-a13f-4835-aa02-64c16c271f40';
update content_tips set topic = $p$past_perfect_had_participio_para_una_accion_anterior_a_otro_momento_del_pasado$p$ where id = '4a9f1466-1a6d-42bc-a19e-e7747aa9effa';
update content_tips set topic = $p$how_long_con_present_perfect_continuous_y_los_marcadores_for_periodo_y_since_punto_de_inicio$p$ where id = 'f3f04661-7336-4fef-b031-608e8f704f7a';
update content_tips set topic = $p$present_perfect_continuous_have_has_been_ing_para_acciones_que_empezaron_en_el_pasado_y_continuan$p$ where id = '75cf41db-70c6-4ab5-8585-004171bb6425';
update content_tips set topic = $p$reported_questions_with_if_whether_and_wh_words$p$ where id = '282301b3-6a8b-47b9-b8f4-29ec8a7862ed';
update content_tips set topic = $p$reported_statements_say_vs_tell_and_tense_backshift$p$ where id = 'bfb3dbe5-ef3e-46d5-a636-311076c77115';
update content_tips set topic = $p$reported_speech_shifts_in_time_and_place_expressions$p$ where id = '191cbc46-695b-4b85-8288-da822cadf116';
update content_tips set topic = $p$voz_pasiva_con_complemento_agente_by_para_senalar_quien_realiza_la_accion$p$ where id = 'e1945983-a00a-44fa-a39a-73c2f04d0a19';
update content_tips set topic = $p$causativo_have_something_done_para_acciones_que_mandamos_hacer_a_otros$p$ where id = '2e719ae4-932d-49cf-87a4-39ec100e483a';
update content_tips set topic = $p$voz_pasiva_en_presente_simple_am_is_are_participio_para_describir_procesos_y_hechos$p$ where id = '4bd2b9d2-34ad-4137-b2ee-517e92a32c1c';
update content_tips set topic = $p$condicionales_mixtos_causa_pasada_past_perfect_con_resultado_presente_would_infinitivo$p$ where id = 'bfe6ea25-ccd6-402f-8723-08970eb9b45b';
update content_tips set topic = $p$tercer_condicional_para_situaciones_pasadas_irreales_if_past_perfect_would_have_participio$p$ where id = '2749923a-a770-4add-ab0e-0c38c6d01f2e';
update content_tips set topic = $p$tercer_condicional_para_situaciones_pasadas_irreales_if_past_perfect_would_have_participio$p$ where id = 'f6c8cfe7-efaf-4986-94ff-f307f0b721c5';
update content_tips set topic = $p$relativas_especificativas_con_the_one_s_who_that_para_senalar_exactamente_a_quien_o_a_que_te_refieres$p$ where id = '3d6ddef0-15c2-4d38-9643-8be333cf311a';
update content_tips set topic = $p$relativas_explicativas_non_defining_entre_comas_que_solo_anaden_datos_adicionales_y_nunca_usan_that$p$ where id = 'a67ee47b-e64e-4e7a-8d43-f3b862632622';
update content_tips set topic = $p$elegir_el_relativo_correcto_segun_describas_personas_cosas_posesion_o_lugares_en_clausulas_especificativas$p$ where id = '160ee89c-a5fc-400a-8d57-0237b389823d';
update content_tips set topic = $p$deducir_lo_que_paso_con_must_might_could_can_t_have_participio$p$ where id = '591dfb92-6ddb-4dd4-9a2c-63e94dfe565b';
update content_tips set topic = $p$deducir_lo_que_paso_con_must_might_could_can_t_have_participio$p$ where id = '90fa025f-0399-43bd-9ecf-2b1b36fb35d8';
update content_tips set topic = $p$deducir_lo_que_paso_con_must_might_could_can_t_have_participio$p$ where id = 'da989a5f-1c88-42d2-b8ac-55c8270da6d7';

create or replace function get_lesson_tip(p_lesson_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid; v_unit int; v_level text; v_weak text; v_topics text[]; v_tip content_tips%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  select u.order_index, u.cefr_level::text into v_unit, v_level
    from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_unit is null then return null; end if;
  -- Conceptos REALES de la lección: tags de sus content_items (sin unidad/skill/cp).
  select coalesce(array_agg(distinct tg), '{}') into v_topics
  from (select unnest(ci.tags) tg from content_items ci
        join lesson_items li on li.item_id = ci.id where li.lesson_id = p_lesson_id) x
  where tg not like 'unidad%' and tg not like 'cp_%'
    and tg not in ('reading','listening','writing','speaking','checkpoint');
  -- Habilidad más floja (personalización; se conserva).
  select s into v_weak from unnest(array['reading','listening','writing','speaking']) s
    order by jz_reinforce_score(uid, v_course, s::skill) desc,
             array_position(array['reading','listening','writing','speaking'], s) limit 1;
  -- Candidatos: (a) tip cuyo topic calza con un concepto de la lección (course-wide),
  -- (b) tip GENERAL (sin topic) del mismo nivel — aplica a cualquier lección,
  -- (c) tip de la misma unidad (último recurso). NUNCA un tip de OTRO concepto/unidad.
  -- Orden: relevancia exacta > general > misma unidad > skill flojo > no visto >
  -- menos reciente (anti-repetición) > determinista.
  select t.* into v_tip from content_tips t
   left join user_tip_progress up on up.tip_id = t.id and up.user_id = uid
   where t.course_id = v_course
     and (t.topic = any(v_topics)
          or (t.topic is null and t.cefr_level = v_level)
          or t.unit_order = v_unit)
   order by coalesce(t.topic = any(v_topics), false) desc,  -- 1. relevancia exacta al tema
            (t.topic is null) desc,                          -- 2. general antes que otro-concepto
            (up.seen_at is null) desc,                       -- 3. no visto (anti-repetición fuerte)
            (t.unit_order = v_unit) desc,                    -- 4. preferir misma unidad
            (t.skill = v_weak) desc,                         -- 5. personalización por skill flojo
            up.seen_at asc nulls first,                      -- entre vistos, el menos reciente
            t.id                                             -- determinista
   limit 1;
  if v_tip.id is null then return null; end if;
  insert into user_tip_progress(user_id, tip_id) values (uid, v_tip.id)
    on conflict (user_id, tip_id) do update set seen_at = now(), times_seen = user_tip_progress.times_seen + 1;
  return jsonb_build_object('id', v_tip.id, 'type', v_tip.type, 'skill', v_tip.skill,
    'cefr_level', v_tip.cefr_level, 'title', v_tip.title, 'body', v_tip.body,
    'example', v_tip.example, 'weak_skill', v_weak);
end $fn$;
grant execute on function get_lesson_tip(uuid) to authenticated;

commit;
