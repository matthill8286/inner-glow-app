-- Baseline schema for Inner Glow.
-- The first hosted project was built by hand and then deleted, so its base tables were never in a
-- migration. This file rebuilds them from tests/fixtures/schema.sql, which was dumped from that
-- database, and adds row level security to every table. Subscriptions come from 20260316.
CREATE TYPE journal_phase AS ENUM ('reflection','coping','awareness','general');
CREATE TABLE public."activity_logs" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"suggestion_id" uuid,
"category" text NOT NULL,
"title" text NOT NULL,
"description" text,
"duration_minutes" int4,
"points_earned" int4 NOT NULL DEFAULT 5,
"mood_before" text,
"mood_after" text,
"notes" text,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."activity_logs" ADD PRIMARY KEY(id);
CREATE TABLE public."ai_suggestions" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"freud_score_id" uuid,
"category" text NOT NULL,
"title" text NOT NULL,
"description" text,
"duration" text,
"completed" bool NOT NULL DEFAULT false,
"completed_at" timestamptz,
"points" int4 NOT NULL DEFAULT 5,
"created_at" timestamptz NOT NULL DEFAULT now(),
"difficulty" text DEFAULT 'easy'::text,
"template_id" uuid);
ALTER TABLE public."ai_suggestions" ADD PRIMARY KEY(id);
CREATE TABLE public."assessments" ("user_id" uuid NOT NULL,
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now(),
"goal" text,
"gender" text,
"age" text,
"weight" float8,
"weight_unit" text,
"mood" text,
"sought_help_before" text,
"physical_distress" text,
"physical_distress_notes" text,
"sleep_quality" int4,
"taking_meds" text,
"meds" text,
"other_symptoms" text,
"stress_level" int4,
"sound_check" jsonb,
"expression_check" jsonb);
ALTER TABLE public."assessments" ADD PRIMARY KEY(user_id);
CREATE TABLE public."chat_histories" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"issue_key" text NOT NULL,
"messages" jsonb NOT NULL DEFAULT '[]'::jsonb,
"is_read" bool NOT NULL DEFAULT false,
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."chat_histories" ADD PRIMARY KEY(id);
CREATE TABLE public."community_bookmarks" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"post_id" uuid NOT NULL,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_bookmarks" ADD PRIMARY KEY(id);
CREATE TABLE public."community_comments" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"post_id" uuid NOT NULL,
"user_id" uuid NOT NULL,
"content" text NOT NULL,
"likes_count" int4 NOT NULL DEFAULT 0,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_comments" ADD PRIMARY KEY(id);
CREATE TABLE public."community_followers" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"follower_id" uuid NOT NULL,
"following_id" uuid NOT NULL,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_followers" ADD PRIMARY KEY(id);
CREATE TABLE public."community_likes" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"post_id" uuid,
"comment_id" uuid,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_likes" ADD PRIMARY KEY(id);
CREATE TABLE public."community_notifications" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"recipient_id" uuid NOT NULL,
"actor_id" uuid,
"type" text NOT NULL,
"post_id" uuid,
"description" text NOT NULL,
"read" bool NOT NULL DEFAULT false,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_notifications" ADD PRIMARY KEY(id);
CREATE TABLE public."community_posts" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"category" text NOT NULL,
"post_type" text NOT NULL DEFAULT 'story'::text,
"content" text NOT NULL,
"image_key" text,
"is_hidden" bool NOT NULL DEFAULT false,
"likes_count" int4 NOT NULL DEFAULT 0,
"comments_count" int4 NOT NULL DEFAULT 0,
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_posts" ADD PRIMARY KEY(id);
CREATE TABLE public."community_profiles" ("user_id" uuid NOT NULL,
"display_name" text NOT NULL DEFAULT 'Anonymous'::text,
"avatar" text NOT NULL DEFAULT '🧑'::text,
"bio" text,
"verified" bool NOT NULL DEFAULT false,
"followers_count" int4 NOT NULL DEFAULT 0,
"following_count" int4 NOT NULL DEFAULT 0,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."community_profiles" ADD PRIMARY KEY(user_id);
CREATE TABLE public."freud_scores" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"score" int4 NOT NULL,
"label" text NOT NULL,
"breakdown" jsonb NOT NULL DEFAULT '{}'::jsonb,
"source" text DEFAULT 'auto'::text,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."freud_scores" ADD PRIMARY KEY(id);
CREATE TABLE public."journal_entries" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"prompt_id" uuid,
"topic_context" text,
"body" text NOT NULL,
"mood_log_id" uuid,
"created_at" timestamptz NOT NULL DEFAULT now(),
"title" text,
"mood" text,
"tags" text[] DEFAULT '{}'::text[],
"audio_url" text,
"recording_duration_ms" int4,
"is_voice_entry" bool NOT NULL DEFAULT false);
ALTER TABLE public."journal_entries" ADD PRIMARY KEY(id);
CREATE TABLE public."journal_prompts" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"topic_id" uuid,
"context_tag" text NOT NULL,
"question" text NOT NULL,
"phase" journal_phase NOT NULL DEFAULT 'general'::journal_phase);
ALTER TABLE public."journal_prompts" ADD PRIMARY KEY(id);
CREATE TABLE public."mindfulness" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"date_iso" timestamptz NOT NULL DEFAULT now(),
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now(),
"seconds" int4,
"note" text);
ALTER TABLE public."mindfulness" ADD PRIMARY KEY(id);
CREATE TABLE public."mood_logs" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"mood_score" int4 NOT NULL,
"energy_score" int4 NOT NULL,
"stress_score" int4 NOT NULL,
"topic_context" text,
"emotions" text[] DEFAULT '{}'::text[],
"note" text,
"logged_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."mood_logs" ADD PRIMARY KEY(id);
CREATE TABLE public."profiles" ("user_id" uuid NOT NULL,
"updated_at" timestamptz NOT NULL DEFAULT now(),
"name" text,
"intention" text,
"routine" text,
"selected_issues" jsonb,
"subscription_expiry" timestamptz,
"subscription_type" text);
ALTER TABLE public."profiles" ADD PRIMARY KEY(user_id);
CREATE TABLE public."sleep" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now(),
"start_iso" timestamptz,
"end_iso" timestamptz,
"quality" int4,
"awakenings" int4,
"duration" int4,
"notes" text);
ALTER TABLE public."sleep" ADD PRIMARY KEY(id);
CREATE TABLE public."stress_histories" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"user_id" uuid NOT NULL,
"type" text,
"date" timestamptz NOT NULL DEFAULT now(),
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now(),
"exercise_id" text,
"title" text);
ALTER TABLE public."stress_histories" ADD PRIMARY KEY(id);
CREATE TABLE public."stress_kits" ("user_id" uuid NOT NULL,
"created_at" timestamptz NOT NULL DEFAULT now(),
"updated_at" timestamptz NOT NULL DEFAULT now(),
"quick_phrase" text,
"triggers" jsonb,
"helpful_actions" jsonb,
"people" jsonb,
"notes" text,
"level" int4,
"last_check_in" timestamptz);
ALTER TABLE public."stress_kits" ADD PRIMARY KEY(user_id);
CREATE TABLE public."suggestion_templates" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"category" text NOT NULL,
"title" text NOT NULL,
"description" text,
"duration" text,
"points" int4 NOT NULL DEFAULT 5,
"min_score" int4 DEFAULT 0,
"max_score" int4 DEFAULT 100,
"target_weakness" text,
"difficulty" text DEFAULT 'easy'::text,
"active" bool DEFAULT true,
"created_at" timestamptz NOT NULL DEFAULT now());
ALTER TABLE public."suggestion_templates" ADD PRIMARY KEY(id);
CREATE TABLE public."topics" ("id" uuid NOT NULL DEFAULT gen_random_uuid(),
"name" text NOT NULL,
"icon" text,
"created_at" timestamptz NOT NULL DEFAULT now(),
"description" text,
"context_tags" text[] DEFAULT '{}'::text[]);
ALTER TABLE public."topics" ADD PRIMARY KEY(id);
ALTER TABLE public.profiles ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.assessments ADD CONSTRAINT assessments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.stress_kits ADD CONSTRAINT stress_kits_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.stress_histories ADD CONSTRAINT stress_histories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.mindfulness ADD CONSTRAINT mindfulness_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.sleep ADD CONSTRAINT sleep_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.chat_histories ADD CONSTRAINT chat_histories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.mood_logs ADD CONSTRAINT mood_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.journal_entries ADD CONSTRAINT journal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.journal_entries ADD CONSTRAINT journal_entries_prompt_id_fkey FOREIGN KEY (prompt_id) REFERENCES journal_prompts(id) ON DELETE SET NULL;
ALTER TABLE public.journal_entries ADD CONSTRAINT journal_entries_mood_log_id_fkey FOREIGN KEY (mood_log_id) REFERENCES mood_logs(id) ON DELETE SET NULL;
ALTER TABLE public.journal_prompts ADD CONSTRAINT journal_prompts_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id);
ALTER TABLE public.community_followers ADD CONSTRAINT community_followers_following_id_fkey FOREIGN KEY (following_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_posts ADD CONSTRAINT community_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_comments ADD CONSTRAINT community_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE;
ALTER TABLE public.community_comments ADD CONSTRAINT community_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_likes ADD CONSTRAINT community_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_likes ADD CONSTRAINT community_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE;
ALTER TABLE public.community_likes ADD CONSTRAINT community_likes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES community_comments(id) ON DELETE CASCADE;
ALTER TABLE public.community_bookmarks ADD CONSTRAINT community_bookmarks_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_bookmarks ADD CONSTRAINT community_bookmarks_post_id_fkey FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE;
ALTER TABLE public.community_followers ADD CONSTRAINT community_followers_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_notifications ADD CONSTRAINT community_notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.community_notifications ADD CONSTRAINT community_notifications_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.community_notifications ADD CONSTRAINT community_notifications_post_id_fkey FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE;
ALTER TABLE public.community_profiles ADD CONSTRAINT community_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.freud_scores ADD CONSTRAINT freud_scores_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.ai_suggestions ADD CONSTRAINT ai_suggestions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.ai_suggestions ADD CONSTRAINT ai_suggestions_freud_score_id_fkey FOREIGN KEY (freud_score_id) REFERENCES freud_scores(id) ON DELETE SET NULL;
ALTER TABLE public.activity_logs ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE public.activity_logs ADD CONSTRAINT activity_logs_suggestion_id_fkey FOREIGN KEY (suggestion_id) REFERENCES ai_suggestions(id);
ALTER TABLE public.ai_suggestions ADD CONSTRAINT ai_suggestions_template_id_fkey FOREIGN KEY (template_id) REFERENCES suggestion_templates(id);
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_assessments_updated_at BEFORE UPDATE ON public.assessments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_stress_kits_updated_at BEFORE UPDATE ON public.stress_kits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_stress_histories_updated_at BEFORE UPDATE ON public.stress_histories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_mindfulness_updated_at BEFORE UPDATE ON public.mindfulness FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_sleep_updated_at BEFORE UPDATE ON public.sleep FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_chat_histories_updated_at BEFORE UPDATE ON public.chat_histories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE OR REPLACE FUNCTION public.update_post_likes_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.post_id IS NOT NULL THEN
    UPDATE community_posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' AND OLD.post_id IS NOT NULL THEN
    UPDATE community_posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$function$
;
CREATE TRIGGER trg_post_likes_count AFTER INSERT OR DELETE ON public.community_likes FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();
CREATE OR REPLACE FUNCTION public.update_post_comments_count()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$function$
;
CREATE TRIGGER trg_post_comments_count AFTER INSERT OR DELETE ON public.community_comments FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();
CREATE OR REPLACE FUNCTION public.update_follow_counts()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_profiles SET following_count = following_count + 1 WHERE user_id = NEW.follower_id;
    UPDATE community_profiles SET followers_count = followers_count + 1 WHERE user_id = NEW.following_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_profiles SET following_count = GREATEST(following_count - 1, 0) WHERE user_id = OLD.follower_id;
    UPDATE community_profiles SET followers_count = GREATEST(followers_count - 1, 0) WHERE user_id = OLD.following_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$function$
;
CREATE TRIGGER trg_follow_counts AFTER INSERT OR DELETE ON public.community_followers FOR EACH ROW EXECUTE FUNCTION update_follow_counts();
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_followers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Comments viewable" ON public.community_comments FOR SELECT USING (true);
CREATE POLICY "Create comments" ON public.community_comments FOR INSERT WITH CHECK ((user_id = auth.uid()));
CREATE POLICY "Delete own comments" ON public.community_comments FOR DELETE USING ((user_id = auth.uid()));
CREATE POLICY "Create own posts" ON public.community_posts FOR INSERT WITH CHECK ((user_id = auth.uid()));
CREATE POLICY "Delete own posts" ON public.community_posts FOR DELETE USING ((user_id = auth.uid()));
CREATE POLICY "Posts viewable by auth" ON public.community_posts FOR SELECT USING (((is_hidden = false) OR (user_id = auth.uid())));
CREATE POLICY "Update own posts" ON public.community_posts FOR UPDATE USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));

-- Row level security for the tables the fixture left open.
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY activity_logs_self ON public.activity_logs FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.ai_suggestions ENABLE ROW LEVEL SECURITY;
CREATE POLICY ai_suggestions_self ON public.ai_suggestions FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
CREATE POLICY assessments_self ON public.assessments FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.chat_histories ENABLE ROW LEVEL SECURITY;
CREATE POLICY chat_histories_self ON public.chat_histories FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.freud_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY freud_scores_self ON public.freud_scores FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY journal_entries_self ON public.journal_entries FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.mindfulness ENABLE ROW LEVEL SECURITY;
CREATE POLICY mindfulness_self ON public.mindfulness FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.mood_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY mood_logs_self ON public.mood_logs FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY profiles_self ON public.profiles FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.sleep ENABLE ROW LEVEL SECURITY;
CREATE POLICY sleep_self ON public.sleep FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.stress_histories ENABLE ROW LEVEL SECURITY;
CREATE POLICY stress_histories_self ON public.stress_histories FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.stress_kits ENABLE ROW LEVEL SECURITY;
CREATE POLICY stress_kits_self ON public.stress_kits FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.community_bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_bookmarks_self ON public.community_bookmarks FOR ALL TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
CREATE POLICY topics_read ON public.topics FOR SELECT TO authenticated USING (true);
REVOKE INSERT, UPDATE, DELETE ON public.topics FROM anon, authenticated;
ALTER TABLE public.journal_prompts ENABLE ROW LEVEL SECURITY;
CREATE POLICY journal_prompts_read ON public.journal_prompts FOR SELECT TO authenticated USING (true);
REVOKE INSERT, UPDATE, DELETE ON public.journal_prompts FROM anon, authenticated;
ALTER TABLE public.suggestion_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY suggestion_templates_read ON public.suggestion_templates FOR SELECT TO authenticated USING (true);
REVOKE INSERT, UPDATE, DELETE ON public.suggestion_templates FROM anon, authenticated;
ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY community_likes_read ON public.community_likes FOR SELECT TO authenticated USING (true);
CREATE POLICY community_likes_add ON public.community_likes FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY community_likes_remove ON public.community_likes FOR DELETE TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY community_followers_read ON public.community_followers FOR SELECT TO authenticated USING (true);
CREATE POLICY community_followers_add ON public.community_followers FOR INSERT TO authenticated WITH CHECK (follower_id = (SELECT auth.uid()));
CREATE POLICY community_followers_remove ON public.community_followers FOR DELETE TO authenticated USING (follower_id = (SELECT auth.uid()));
CREATE POLICY community_notifications_read ON public.community_notifications FOR SELECT TO authenticated USING (recipient_id = (SELECT auth.uid()));
CREATE POLICY community_notifications_mark ON public.community_notifications FOR UPDATE TO authenticated USING (recipient_id = (SELECT auth.uid())) WITH CHECK (recipient_id = (SELECT auth.uid()));
CREATE POLICY community_notifications_remove ON public.community_notifications FOR DELETE TO authenticated USING (recipient_id = (SELECT auth.uid()));
CREATE POLICY community_notifications_send ON public.community_notifications FOR INSERT TO authenticated WITH CHECK (actor_id = (SELECT auth.uid()));
CREATE POLICY community_profiles_create ON public.community_profiles FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY community_profiles_update ON public.community_profiles FOR UPDATE TO authenticated USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));
ALTER TABLE public.community_bookmarks ADD CONSTRAINT community_bookmarks_user_post_key UNIQUE (user_id, post_id);
ALTER TABLE public.community_followers ADD CONSTRAINT community_followers_pair_key UNIQUE (follower_id, following_id);

-- The chat topics, matching data/issues.ts.
INSERT INTO public.topics (name, description, context_tags) VALUES
  ('Anxiety', 'Worry loops, overthinking, tension.', ARRAY['grounding','reframing']),
  ('Low mood', 'Low motivation, hopelessness, numbness.', ARRAY['tiny steps','self-compassion']),
  ('Stress', 'Overload, pressure, and edge-of-seat feelings.', ARRAY['breathing','boundaries']),
  ('Burnout', 'Exhaustion, cynicism, reduced effectiveness.', ARRAY['recovery','values']),
  ('Sleep', 'Falling asleep, staying asleep, quality.', ARRAY['sleep hygiene']),
  ('Relationships', 'Conflict, loneliness, communication.', ARRAY['communication']),
  ('Grief', 'Loss, mourning, waves of sadness.', ARRAY['processing']),
  ('Panic', 'Sudden fear, racing heart, dread.', ARRAY['panic cycle']);
