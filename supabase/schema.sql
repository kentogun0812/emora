-- Emora Unified Database Schema
-- Path: supabase/schema.sql
-- Contains complete tables, trigger functions, RLS configuration, and security policies up to Sprint 10.

-- Enable extension for generating random UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================================================================
-- 1. CREATE TABLES
-- =========================================================================

-- 1.1. Couples Table
CREATE TABLE IF NOT EXISTS public.couples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_a_id UUID NOT NULL,
    user_b_id UUID,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Connected', 'Disconnected')),
    relationship_status VARCHAR(20) DEFAULT 'Dating' CHECK (relationship_status IN ('Dating', 'Married')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.2. Users Table (Extended user info from Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    partner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    couple_id UUID REFERENCES public.couples(id) ON DELETE SET NULL,
    current_mood VARCHAR(20) DEFAULT 'Calm' CHECK (current_mood IN ('Happy', 'Calm', 'Tired', 'Sad', 'Irritated', 'NeedAffection', 'NeedSpace')),
    mood_updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    bio_role VARCHAR(20) DEFAULT 'Other' CHECK (bio_role IN ('Male', 'Female', 'Other')),
    call_sign VARCHAR(50) DEFAULT 'Đối phương',
    partner_call_sign VARCHAR(50) DEFAULT 'Bạn',
    nickname VARCHAR(100),
    date_of_birth DATE,
    relationship_status VARCHAR(20) CHECK (relationship_status IN ('Dating', 'Married')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.3. Pairing Codes Table (Temporary codes - Expires after 15 minutes)
CREATE TABLE IF NOT EXISTS public.pairing_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(6) UNIQUE NOT NULL,
    creator_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.4. Period Logs Table
CREATE TABLE IF NOT EXISTS public.period_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_start_date UNIQUE (user_id, start_date)
);

-- 1.5. Cycle Settings Table (Cycle config & Privacy settings)
CREATE TABLE IF NOT EXISTS public.cycle_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    avg_cycle_length INT DEFAULT 28 NOT NULL CHECK (avg_cycle_length BETWEEN 15 AND 50),
    avg_period_length INT DEFAULT 5 NOT NULL CHECK (avg_period_length BETWEEN 3 AND 10),
    share_level VARCHAR(20) DEFAULT 'Summary' CHECK (share_level IN ('Full', 'Summary', 'None')) NOT NULL
);

-- 1.6. Relations Journal Table (Shared relation logs)
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

-- 1.7. Care Requests Table
CREATE TABLE IF NOT EXISTS public.care_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    template_id VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Accepted', 'Completed', 'Canceled')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.8. User Devices Table (Devices receiving FCM push notifications)
CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT UNIQUE NOT NULL,
    platform VARCHAR(10) CHECK (platform IN ('iOS', 'Android')) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.9. Baby Profiles Table
CREATE TABLE IF NOT EXISTS public.baby_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Unknown')),
    date_of_birth DATE NOT NULL,
    emoji VARCHAR(10) DEFAULT '👶' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 1.10. Baby Vaccinations Table
CREATE TABLE IF NOT EXISTS public.baby_vaccinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    baby_id UUID REFERENCES public.baby_profiles(id) ON DELETE CASCADE NOT NULL,
    vaccine_name VARCHAR(150) NOT NULL,
    disease_prevention VARCHAR(255) NOT NULL,
    recommended_age_months INT NOT NULL,
    planned_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' NOT NULL CHECK (status IN ('Pending', 'Done', 'Skipped')),
    administered_date DATE,
    notes TEXT,
    updated_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);


-- =========================================================================
-- 2. TRIGGER FUNCTIONS & TRIGGERS
-- =========================================================================

-- 2.1. Trigger function to automatically create profile in public.users on auth.users signup
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

-- 2.2. Trigger function to automatically generate the vaccination schedule on baby profile creation
CREATE OR REPLACE FUNCTION public.initialize_baby_vaccinations()
RETURNS TRIGGER AS $$
DECLARE
    dob DATE := NEW.date_of_birth;
BEGIN
    -- Milestone: At birth (0 months)
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, 'BCG', 'Lao (Tuberculosis)', 0, dob),
    (NEW.id, 'Hepatitis B (1st dose)', 'Viêm gan B (Hepatitis B)', 0, dob);

    -- Milestone: 2 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, '6-in-1 (1st dose)', 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 2, dob + INTERVAL '2 months'),
    (NEW.id, 'Rotavirus (1st dose)', 'Tiêu chảy do Rotavirus', 2, dob + INTERVAL '2 months'),
    (NEW.id, 'Pneumococcal (1st dose)', 'Phế cầu (Pneumococcus)', 2, dob + INTERVAL '2 months');

    -- Milestone: 3 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, '6-in-1 (2nd dose)', 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 3, dob + INTERVAL '3 months'),
    (NEW.id, 'Rotavirus (2nd dose)', 'Tiêu chảy do Rotavirus', 3, dob + INTERVAL '3 months');

    -- Milestone: 4 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, '6-in-1 (3rd dose)', 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 4, dob + INTERVAL '4 months'),
    (NEW.id, 'Pneumococcal (2nd dose)', 'Phế cầu (Pneumococcus)', 4, dob + INTERVAL '4 months');

    -- Milestone: 6 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, 'Influenza (1st dose)', 'Cúm mùa (Influenza)', 6, dob + INTERVAL '6 months'),
    (NEW.id, 'Meningococcal BC (1st dose)', 'Viêm màng não mô cầu BC', 6, dob + INTERVAL '6 months');

    -- Milestone: 9 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, 'Measles (1st dose)', 'Sởi (Measles)', 9, dob + INTERVAL '9 months'),
    (NEW.id, 'Japanese Encephalitis (1st dose)', 'Viêm não Nhật Bản', 9, dob + INTERVAL '9 months');

    -- Milestone: 12 months
    INSERT INTO public.baby_vaccinations (baby_id, vaccine_name, disease_prevention, recommended_age_months, planned_date)
    VALUES 
    (NEW.id, 'MMR (1st dose)', 'Sởi, Quai bị, Rubella', 12, dob + INTERVAL '12 months'),
    (NEW.id, 'Varicella (1st dose)', 'Thủy đậu (Chickenpox)', 12, dob + INTERVAL '12 months'),
    (NEW.id, 'Hepatitis A (1st dose)', 'Viêm gan A (Hepatitis A)', 12, dob + INTERVAL '12 months');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_baby_profile_created
    AFTER INSERT ON public.baby_profiles
    FOR EACH ROW EXECUTE FUNCTION public.initialize_baby_vaccinations();


-- =========================================================================
-- 3. ROW LEVEL SECURITY (RLS) & POLICIES
-- =========================================================================

-- Enable RLS on all tables
ALTER TABLE public.couples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pairing_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.period_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cycle_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relations_journal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.care_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_vaccinations ENABLE ROW LEVEL SECURITY;

-- 3.1. Users Table Policies
CREATE POLICY users_self_read_write ON public.users
    FOR ALL USING (auth.uid() = id);

CREATE POLICY users_partner_read ON public.users
    FOR SELECT USING (auth.uid() = partner_id);

-- 3.2. Couples Table Policies
CREATE POLICY couples_read_write ON public.couples
    FOR ALL USING (auth.uid() = user_a_id OR auth.uid() = user_b_id);

-- 3.3. Pairing Codes Table Policies
CREATE POLICY pairing_codes_all ON public.pairing_codes
    FOR ALL USING (auth.uid() = creator_id);

-- 3.4. Period Logs Table Policies
CREATE POLICY period_logs_self_all ON public.period_logs
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY period_logs_partner_select ON public.period_logs
    FOR SELECT USING (
        auth.uid() = (SELECT partner_id FROM public.users WHERE id = user_id)
        AND (SELECT share_level FROM public.cycle_settings WHERE user_id = user_id) = 'Full'
    );

-- 3.5. Cycle Settings Table Policies
CREATE POLICY cycle_settings_self ON public.cycle_settings
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY cycle_settings_partner ON public.cycle_settings
    FOR SELECT USING (
        auth.uid() = (SELECT partner_id FROM public.users WHERE id = user_id)
    );

-- 3.6. Relations Journal Table Policies
CREATE POLICY journal_all_for_couple ON public.relations_journal
    FOR ALL USING (
        couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
    );

-- 3.7. Care Requests Table Policies
CREATE POLICY care_requests_all_for_couple ON public.care_requests
    FOR ALL USING (
        couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
    );

-- 3.8. User Devices Table Policies
CREATE POLICY user_devices_self_all ON public.user_devices
    FOR ALL USING (auth.uid() = user_id);

-- 3.9. Baby Profiles Table Policies (Restricted to Married couples)
CREATE POLICY baby_profiles_all_for_couple ON public.baby_profiles
    FOR ALL USING (
        couple_id IN (
            SELECT id FROM public.couples 
            WHERE (user_a_id = auth.uid() OR user_b_id = auth.uid()) 
            AND relationship_status = 'Married'
        )
    );

-- 3.10. Baby Vaccinations Table Policies (Restricted to Married couples)
CREATE POLICY baby_vaccinations_all_for_couple ON public.baby_vaccinations
    FOR ALL USING (
        baby_id IN (
            SELECT id FROM public.baby_profiles 
            WHERE couple_id IN (
                SELECT id FROM public.couples 
                WHERE (user_a_id = auth.uid() OR user_b_id = auth.uid()) 
                AND relationship_status = 'Married'
            )
        )
    );
