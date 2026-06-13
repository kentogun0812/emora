-- supabase/sprint_3_policies.sql
-- Add Row-Level Security (RLS) policies for cycle_settings table

-- Enable RLS on cycle_settings if not already enabled
ALTER TABLE public.cycle_settings ENABLE ROW LEVEL SECURITY;

-- Policy: User can perform all actions on their own cycle settings
CREATE POLICY cycle_settings_self ON public.cycle_settings
    FOR ALL USING (auth.uid() = user_id);

-- Policy: Partner can read (select) user's cycle settings
CREATE POLICY cycle_settings_partner ON public.cycle_settings
    FOR SELECT USING (
        auth.uid() = (SELECT partner_id FROM public.users WHERE id = user_id)
    );
