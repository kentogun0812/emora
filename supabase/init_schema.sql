-- Emora MVP Database Initial Schema
-- Path: supabase/init_schema.sql

-- Enable extension for generating random UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- 1. CREATE TABLES
-- =========================================================================

-- Couples Table
CREATE TABLE IF NOT EXISTS public.couples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_a_id UUID NOT NULL,
    user_b_id UUID,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Connected', 'Disconnected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Users Table (Extended user info from Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    partner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    couple_id UUID REFERENCES public.couples(id) ON DELETE SET NULL,
    current_mood VARCHAR(20) DEFAULT 'Calm' CHECK (current_mood IN ('Happy', 'Calm', 'Tired', 'Sad', 'Irritated', 'NeedAffection', 'NeedSpace')),
    mood_updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Pairing Codes Table (Temporary codes - Expires after 15 minutes)
CREATE TABLE IF NOT EXISTS public.pairing_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(6) UNIQUE NOT NULL,
    creator_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Period Logs Table
CREATE TABLE IF NOT EXISTS public.period_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_start_date UNIQUE (user_id, start_date)
);

-- Cycle Settings Table (Cycle config & Privacy settings)
CREATE TABLE IF NOT EXISTS public.cycle_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    avg_cycle_length INT DEFAULT 28 NOT NULL CHECK (avg_cycle_length BETWEEN 15 AND 50),
    avg_period_length INT DEFAULT 5 NOT NULL CHECK (avg_period_length BETWEEN 3 AND 10),
    share_level VARCHAR(20) DEFAULT 'Summary' CHECK (share_level IN ('Full', 'Summary', 'None')) NOT NULL
);

-- Relations Journal Table (Shared relation logs)
CREATE TABLE IF NOT EXISTS public.relations_journal (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE NOT NULL,
    created_by UUID REFERENCES public.users(id) NOT NULL,
    relation_date DATE NOT NULL,
    protection_type VARCHAR(20) CHECK (protection_type IN ('Protected', 'Unprotected')) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_couple_relation_date UNIQUE (couple_id, relation_date)
);

-- Care Requests Table
CREATE TABLE IF NOT EXISTS public.care_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    template_id VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Accepted', 'Completed', 'Canceled')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- User Devices Table (Devices receiving FCM push notifications)
CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT UNIQUE NOT NULL,
    platform VARCHAR(10) CHECK (platform IN ('iOS', 'Android')) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- 2. AUTO CREATE PROFILE ON SIGNUP (TRIGGERS)
-- =========================================================================

-- Function to automatically create profile in public.users on auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email)
    VALUES (new.id, new.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =========================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- =========================================================================

-- Enable RLS on all sensitive tables
ALTER TABLE public.couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pairing_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.period_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycle_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relations_journal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.care_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

-- 3.1 Security policies for Users table
CREATE POLICY users_self_read_write ON public.users
    FOR ALL USING (auth.uid() = id);

CREATE POLICY users_partner_read ON public.users
    FOR SELECT USING (auth.uid() = partner_id);

-- 3.2 Security policies for Couples table
CREATE POLICY couples_read_write ON public.couples
    FOR ALL USING (auth.uid() = user_a_id OR auth.uid() = user_b_id);

-- 3.3 Security policies for Pairing Codes table
CREATE POLICY pairing_codes_all ON public.pairing_codes
    FOR ALL USING (auth.uid() = creator_id);

-- 3.4 Security policies for Period Logs table
CREATE POLICY period_logs_self_all ON public.period_logs
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY period_logs_partner_select ON public.period_logs
    FOR SELECT USING (
        auth.uid() = (SELECT partner_id FROM public.users WHERE id = user_id)
        AND (SELECT share_level FROM public.cycle_settings WHERE user_id = user_id) = 'Full'
    );

-- 3.5 Security policies for Relations Journal table
CREATE POLICY journal_all_for_couple ON public.relations_journal
    FOR ALL USING (
        couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
    );

-- 3.6 Security policies for Care Requests table
CREATE POLICY care_requests_all_for_couple ON public.care_requests
    FOR ALL USING (
        couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
    );
