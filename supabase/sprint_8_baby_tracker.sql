-- path: supabase/sprint_8_baby_tracker.sql

-- 1. Create Baby Profiles Table
CREATE TABLE IF NOT EXISTS public.baby_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID REFERENCES public.couples(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Unknown')),
    date_of_birth DATE NOT NULL,
    emoji VARCHAR(10) DEFAULT '👶' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Create Baby Vaccinations Table
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

-- 3. Enable RLS
ALTER TABLE public.baby_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baby_vaccinations ENABLE ROW LEVEL SECURITY;

-- 4. Policies
CREATE POLICY baby_profiles_all_for_couple ON public.baby_profiles
    FOR ALL USING (
        couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
    );

CREATE POLICY baby_vaccinations_all_for_couple ON public.baby_vaccinations
    FOR ALL USING (
        baby_id IN (
            SELECT id FROM public.baby_profiles 
            WHERE couple_id IN (SELECT couple_id FROM public.users WHERE id = auth.uid())
        )
    );

-- 5. Trigger to automatically generate the vaccination schedule
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
